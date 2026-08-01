#!/usr/bin/env python3
"""
Counterexample Analysis Agent (Agent 8)
=======================================

Purpose
-------
Analyzes a non-passing CBMC/formal-tool result produced by Agent 7 and explains
why the verification attempt failed or could not be completed.

This agent is intentionally conservative:
- It does not treat every CBMC failure as a code bug.
- It separates harness problems, bad assumptions, too-strong assertions,
  tool/configuration failures, and possible implementation issues.
- It records evidence from the tool output, generated harness, critic review,
  and candidate properties.
- It produces machine-readable repair guidance for Agent 9.
- It never claims full ML-KEM verification or full implementation failure from
  one function-level candidate harness.

Expected inputs in run directory
--------------------------------
- 06_cbmc_status.json
- 06_cbmc_output.txt
- 06_cbmc_property_results.json, if available
- 04_generated_harness.c or 08_repaired_harness.c
- 04_artifact_manifest.json, if available
- 05_critic_review.json, if available
- 03_candidate_properties.json, if available
- 02_code_summary.json, if available
- 01_spec_summary.json, if available

Expected outputs in run directory
---------------------------------
- 07_counterexample_analysis.json
- 07_counterexample_analysis.md
- llm_prompts/07_counterexample_analysis_prompt.txt
- agent_status/07_counterexample_analysis_status.json

CLI example
-----------
python3 agents/counterexample_analysis_agent.py \
  --config configs/poly_add_run.json \
  --run-dir runs/run_001_poly_add \
  --iteration 0
"""

from __future__ import annotations

import argparse
import dataclasses
import datetime as _dt
import hashlib
import json
import re
import textwrap
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

JsonDict = Dict[str, Any]


# ---------------------------------------------------------------------------
# Basic helpers
# ---------------------------------------------------------------------------


def utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat(timespec="seconds")


def read_text(path: Path, default: str = "") -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return default


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def read_json(path: Path, default: Optional[JsonDict] = None) -> JsonDict:
    if default is None:
        default = {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError):
        return dict(default)


def write_json(path: Path, data: JsonDict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")


def append_jsonl(path: Path, event: JsonDict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False) + "\n")


def sha256_file(path: Path) -> Optional[str]:
    if not path.exists() or not path.is_file():
        return None
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def unique_preserve_order(items: Iterable[Any]) -> List[Any]:
    seen = set()
    out: List[Any] = []
    for item in items:
        key = json.dumps(item, sort_keys=True, ensure_ascii=False) if isinstance(item, (dict, list)) else str(item)
        if key in seen:
            continue
        seen.add(key)
        out.append(item)
    return out


def safe_get(data: Any, *keys: str, default: Any = None) -> Any:
    cur = data
    for key in keys:
        if not isinstance(cur, dict) or key not in cur:
            return default
        cur = cur[key]
    return cur


def as_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def line_numbered_matches(text: str, patterns: Sequence[str], max_hits: int = 20) -> List[JsonDict]:
    hits: List[JsonDict] = []
    compiled = [re.compile(p, flags=re.IGNORECASE) for p in patterns]
    for idx, line in enumerate(text.splitlines(), start=1):
        stripped = line.strip()
        if not stripped:
            continue
        for pat in compiled:
            if pat.search(stripped):
                hits.append({"line": idx, "text": stripped[:500], "pattern": pat.pattern})
                break
        if len(hits) >= max_hits:
            break
    return hits


def clip(text: str, limit: int = 4000) -> str:
    if len(text) <= limit:
        return text
    return text[:limit] + "\n...[clipped for report]..."


# ---------------------------------------------------------------------------
# Data models
# ---------------------------------------------------------------------------


@dataclasses.dataclass
class FailureSignal:
    signal_type: str
    severity: str
    confidence: float
    evidence: List[str]
    explanation: str


@dataclasses.dataclass
class FailedProperty:
    property_id: Optional[str]
    description: str
    property_type: str
    status: str
    raw_line: str
    source: str = "cbmc_output"


@dataclasses.dataclass
class TraceAssignment:
    variable: str
    value: str
    line: Optional[int]
    raw_line: str


# ---------------------------------------------------------------------------
# Main agent
# ---------------------------------------------------------------------------


class CounterexampleAnalysisAgent:
    """Classifies and explains CBMC/tool failures for repair and thesis evidence."""

    PROPERTY_TYPE_KEYWORDS: List[Tuple[str, List[str]]] = [
        ("pointer_safety", ["pointer", "dereference", "null pointer", "invalid pointer"]),
        ("bounds_safety", ["array", "bounds", "out of bounds", "object bounds", "buffer"]),
        ("integer_overflow", ["overflow", "arithmetic", "signed", "unsigned"]),
        ("loop_unwinding", ["unwind", "unwinding", "loop"]),
        ("assertion", ["assert", "assertion", "property"]),
        ("memory_safety", ["memory", "malloc", "free", "leak"]),
        ("division", ["division", "divide", "zero"]),
        ("shift", ["shift", "undefined shift"]),
        ("conversion", ["conversion", "typecast", "cast"]),
    ]

    def __init__(
        self,
        config_path: Path,
        run_dir: Optional[Path] = None,
        iteration: int = 0,
        artifact: Optional[str] = None,
        output_prefix: str = "07",
    ) -> None:
        self.config_path = config_path.resolve()
        self.project_root = self.infer_project_root(self.config_path)
        self.config = read_json(self.config_path)

        initial_run_dir = self.resolve_run_dir(run_dir)
        resolved_config = read_json(initial_run_dir / "run_config.resolved.json", default={})
        if resolved_config:
            merged = dict(self.config)
            merged.update(resolved_config)
            self.config = merged

        self.run_dir = self.resolve_run_dir(run_dir)
        self.iteration = int(iteration)
        self.artifact_arg = artifact or self.config.get("current_artifact")
        self.output_prefix = output_prefix

        self.cbmc_status_path = self.run_dir / "06_cbmc_status.json"
        self.cbmc_output_path = self.run_dir / "06_cbmc_output.txt"
        self.cbmc_properties_path = self.run_dir / "06_cbmc_property_results.json"
        self.analysis_path = self.run_dir / f"{output_prefix}_counterexample_analysis.json"
        self.md_path = self.run_dir / f"{output_prefix}_counterexample_analysis.md"
        self.prompt_path = self.run_dir / "llm_prompts" / f"{output_prefix}_counterexample_analysis_prompt.txt"
        self.agent_status_path = self.run_dir / "agent_status" / f"{output_prefix}_counterexample_analysis_status.json"
        self.events_path = self.run_dir / "events.jsonl"

        self.spec_summary = read_json(self.run_dir / "01_spec_summary.json", default={})
        self.code_summary = read_json(self.run_dir / "02_code_summary.json", default={})
        self.properties = read_json(self.run_dir / "03_candidate_properties.json", default={})
        self.manifest = self.load_manifest()
        self.critic_review = read_json(self.run_dir / "05_critic_review.json", default={})
        self.cbmc_status = read_json(self.cbmc_status_path, default={})
        self.cbmc_property_results = read_json(self.cbmc_properties_path, default={})
        self.raw_output = read_text(self.cbmc_output_path, default="")

    # ------------------------------------------------------------------
    # Path/config resolution
    # ------------------------------------------------------------------

    @staticmethod
    def infer_project_root(config_path: Path) -> Path:
        if config_path.parent.name == "configs":
            return config_path.parent.parent.resolve()
        return Path.cwd().resolve()

    def resolve_project_path(self, maybe_path: Any) -> Path:
        p = Path(str(maybe_path)).expanduser()
        if p.is_absolute():
            return p.resolve()
        return (self.project_root / p).resolve()

    def resolve_run_dir(self, run_dir: Optional[Path]) -> Path:
        if run_dir is not None:
            p = Path(run_dir).expanduser()
            if p.is_absolute():
                return p.resolve()
            return (self.project_root / p).resolve()
        configured = self.config.get("run_dir")
        if configured:
            return self.resolve_project_path(configured)
        output_root = self.config.get("output_root", "runs")
        run_id = self.config.get("run_id", "run_001")
        return (self.project_root / str(output_root) / str(run_id)).resolve()

    def load_manifest(self) -> JsonDict:
        for name in ["04_artifact_manifest.json", "04_generated_artifact_notes.json", "artifact_manifest.json"]:
            data = read_json(self.run_dir / name, default={})
            if data:
                data["_manifest_path"] = str(self.run_dir / name)
                return data
        return {}

    def resolve_artifact_path(self) -> Path:
        candidates: List[Any] = []
        if self.artifact_arg:
            candidates.append(self.artifact_arg)
        for key in ["artifact_file", "artifact_path"]:
            if self.cbmc_status.get(key):
                candidates.append(self.cbmc_status.get(key))
        for name in ["08_repaired_harness.c", "04_generated_harness.c"]:
            candidates.append(self.run_dir / name)

        for c in candidates:
            p = Path(str(c)).expanduser()
            if not p.is_absolute():
                p = (self.run_dir / p).resolve() if (self.run_dir / p).exists() else (self.project_root / p).resolve()
            if p.exists():
                return p.resolve()

        # Prefer current artifact in run dir even if missing, so report is explicit.
        fallback = self.artifact_arg or "04_generated_harness.c"
        p = Path(str(fallback)).expanduser()
        if p.is_absolute():
            return p.resolve()
        return (self.run_dir / p).resolve()

    def log_event(self, event_type: str, payload: JsonDict) -> None:
        append_jsonl(
            self.events_path,
            {
                "ts": utc_now(),
                "agent": "counterexample_analysis_agent",
                "event": event_type,
                **payload,
            },
        )

    # ------------------------------------------------------------------
    # Parsing helpers
    # ------------------------------------------------------------------

    @classmethod
    def classify_property_type(cls, text: str) -> str:
        lower = text.lower()
        for prop_type, keywords in cls.PROPERTY_TYPE_KEYWORDS:
            if any(k in lower for k in keywords):
                return prop_type
        return "unknown"

    def parse_failed_properties(self, raw_output: str) -> List[FailedProperty]:
        failed: List[FailedProperty] = []

        # Prefer structured property results from Agent 7 if available.
        for item in as_list(self.cbmc_status.get("property_results")):
            if not isinstance(item, dict):
                continue
            status = str(item.get("status", "")).upper()
            if status != "FAILURE":
                continue
            raw_line = str(item.get("raw_line") or item.get("description") or "")
            failed.append(
                FailedProperty(
                    property_id=item.get("property_id"),
                    description=str(item.get("description") or raw_line),
                    property_type=str(item.get("property_type") or self.classify_property_type(raw_line)),
                    status=status,
                    raw_line=raw_line,
                    source="06_cbmc_status.json",
                )
            )

        if failed:
            return unique_preserve_order([dataclasses.asdict(x) for x in failed])  # type: ignore[return-value]

        # Parse CBMC text lines directly.
        for line in raw_output.splitlines():
            stripped = line.strip()
            m = re.match(r"^\[([^\]]+)\]\s*(.*?):\s*(FAILURE)\s*$", stripped, flags=re.IGNORECASE)
            if m:
                failed.append(
                    FailedProperty(
                        property_id=m.group(1),
                        description=m.group(2).strip(),
                        property_type=self.classify_property_type(stripped),
                        status="FAILURE",
                        raw_line=stripped,
                    )
                )
                continue

            if re.search(r"\bviolated property\b", stripped, flags=re.IGNORECASE):
                failed.append(
                    FailedProperty(
                        property_id=None,
                        description="Violated property reported by CBMC",
                        property_type=self.classify_property_type(stripped),
                        status="FAILURE",
                        raw_line=stripped,
                    )
                )

        return [dataclasses.asdict(x) for x in failed]

    def extract_trace_assignments(self, raw_output: str, max_hits: int = 40) -> List[JsonDict]:
        """Extract common CBMC trace assignment/value lines conservatively."""
        assignments: List[TraceAssignment] = []
        patterns = [
            re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_\-\.\[\]>]*)\s*=\s*(.+?)\s*$"),
            re.compile(r"^\s*value\s*:\s*(.+?)\s*$", re.IGNORECASE),
            re.compile(r"^\s*assignment\s*\(?\s*([^\)]*)\)?\s*:\s*(.+?)\s*$", re.IGNORECASE),
        ]
        for line_no, line in enumerate(raw_output.splitlines(), start=1):
            stripped = line.strip()
            if not stripped:
                continue
            if len(assignments) >= max_hits:
                break

            # Avoid parsing CBMC result lines as assignments.
            if stripped.startswith("[") or "SUCCESS" in stripped or "FAILURE" in stripped:
                continue

            for pat in patterns:
                m = pat.match(stripped)
                if not m:
                    continue
                if pat.pattern.startswith("^\\s*value"):
                    assignments.append(TraceAssignment(variable="value", value=m.group(1).strip(), line=line_no, raw_line=stripped))
                elif len(m.groups()) >= 2:
                    assignments.append(TraceAssignment(variable=m.group(1).strip(), value=m.group(2).strip(), line=line_no, raw_line=stripped))
                break
        return [dataclasses.asdict(x) for x in assignments]

    def extract_relevant_output_evidence(self, raw_output: str) -> JsonDict:
        patterns = {
            "failure_lines": [r"\bFAILURE\b", r"verification failed", r"violated property", r"counterexample"],
            "overflow_lines": [r"overflow", r"arithmetic overflow", r"signed", r"unsigned"],
            "bounds_lines": [r"array", r"bounds", r"out of bounds", r"buffer"],
            "pointer_lines": [r"pointer", r"dereference", r"NULL", r"invalid pointer"],
            "unwind_lines": [r"unwind", r"unwinding", r"unwinding assertion"],
            "tool_error_lines": [r"ERROR:", r"parse error", r"syntax error", r"failed to open", r"not found", r"conversion error", r"tool unavailable"],
        }
        return {name: line_numbered_matches(raw_output, pats, max_hits=12) for name, pats in patterns.items()}

    def extract_harness_evidence(self, harness_text: str) -> JsonDict:
        return {
            "assumptions": line_numbered_matches(harness_text, [r"__CPROVER_assume\s*\(", r"assume\s*\("], max_hits=30),
            "assertions": line_numbered_matches(harness_text, [r"\bassert\s*\(", r"__CPROVER_assert\s*\("], max_hits=30),
            "nondet_inputs": line_numbered_matches(harness_text, [r"nondet_[A-Za-z0-9_]+\s*\(", r"__CPROVER_nondet"], max_hits=30),
            "target_calls": line_numbered_matches(harness_text, [re.escape(str(self.config.get("target_function", ""))) + r"\s*\("], max_hits=20) if self.config.get("target_function") else [],
            "loop_lines": line_numbered_matches(harness_text, [r"\bfor\s*\(", r"\bwhile\s*\("], max_hits=20),
        }

    def read_critic_issues(self) -> List[JsonDict]:
        issues: List[JsonDict] = []
        for issue in as_list(self.critic_review.get("issues")):
            if isinstance(issue, dict):
                issues.append(issue)
        return issues

    # ------------------------------------------------------------------
    # Classification
    # ------------------------------------------------------------------

    def build_failure_signals(self, raw_output: str, harness_text: str, failed_properties: List[JsonDict]) -> List[FailureSignal]:
        lower = raw_output.lower()
        harness_lower = harness_text.lower()
        signals: List[FailureSignal] = []
        critic_issues = self.read_critic_issues()

        def add(signal_type: str, severity: str, confidence: float, evidence: List[str], explanation: str) -> None:
            signals.append(FailureSignal(signal_type, severity, confidence, unique_preserve_order(evidence), explanation))

        status = str(self.cbmc_status.get("status", "")).lower()
        execution_status = str(self.cbmc_status.get("execution_status", "")).lower()
        detected_errors = [str(x) for x in as_list(self.cbmc_status.get("detected_errors"))]

        if status == "passed" or self.cbmc_status.get("verification_passed") is True:
            add(
                "no_counterexample_to_analyze",
                "info",
                0.98,
                ["06_cbmc_status.json reports verification_passed=true/status=passed."],
                "The formal tool reported success for the selected harness/properties, so no counterexample analysis is needed for this iteration.",
            )
            return signals

        if status == "tool_unavailable" or execution_status == "tool_unavailable" or "cbmc binary not found" in lower:
            add(
                "tool_unavailable",
                "high",
                0.98,
                detected_errors or ["CBMC binary was not found or command was not executed."],
                "The verification attempt did not run because the formal tool is missing or not visible in PATH. This is environment setup, not a proof failure.",
            )

        if status == "artifact_missing" or "artifact file not found" in lower:
            add(
                "artifact_missing",
                "critical",
                0.98,
                detected_errors or ["Harness/artifact file not found."],
                "The selected harness file is missing, so CBMC could not check anything.",
            )

        if status == "timeout" or "[timeout]" in lower or "timed out" in lower:
            add(
                "tool_timeout",
                "high",
                0.90,
                ["CBMC execution timed out."],
                "The tool did not finish within the configured time. The harness may be too broad, unwind bound may be too high, or the command may need simplification.",
            )

        if detected_errors or any(s in lower for s in ["parse error", "syntax error", "conversion error", "failed to open", "file not found"]):
            add(
                "tool_configuration_or_compilation_problem",
                "high",
                0.88,
                detected_errors[:10] or ["CBMC output contains parsing/conversion/file errors."],
                "CBMC appears to have failed before a clean verification result. This usually means missing include paths, missing source files, generated C syntax problems, or unsupported constructs.",
            )

        if failed_properties:
            prop_types = sorted({str(p.get("property_type") or "unknown") for p in failed_properties})
            add(
                "formal_property_failure",
                "medium",
                0.85,
                [str(p.get("raw_line") or p.get("description")) for p in failed_properties[:8]],
                f"CBMC reported one or more failed properties. Failed property categories detected: {', '.join(prop_types)}.",
            )

        if "overflow" in lower or any(str(p.get("property_type")) == "integer_overflow" for p in failed_properties):
            evidence = [str(p.get("raw_line") or p.get("description")) for p in failed_properties if str(p.get("property_type")) == "integer_overflow"]
            if not evidence:
                evidence = [h["text"] for h in line_numbered_matches(raw_output, [r"overflow"], max_hits=8)]
            add(
                "integer_overflow_risk",
                "high",
                0.87,
                evidence or ["CBMC output mentions overflow."],
                "The failed check is related to arithmetic overflow. In ML-KEM polynomial code this often means the harness allowed input ranges that are too broad, or the assertion performs arithmetic in a type-sensitive way.",
            )

        if any(word in lower for word in ["array bounds", "out of bounds", "bounds check", "object bounds", "buffer"]):
            add(
                "memory_bounds_failure",
                "high",
                0.84,
                [h["text"] for h in line_numbered_matches(raw_output, [r"bounds", r"out of bounds", r"array"], max_hits=8)],
                "CBMC reported an array/bounds-related failure. This may be a real bounds issue, a bad loop/unwind setup, or a harness object-size problem.",
            )

        if any(word in lower for word in ["pointer", "dereference failure", "invalid pointer", "null pointer"]):
            add(
                "pointer_validity_failure",
                "high",
                0.84,
                [h["text"] for h in line_numbered_matches(raw_output, [r"pointer", r"dereference", r"null"], max_hits=8)],
                "CBMC reported a pointer/dereference-related failure. For harnesses this often means local objects or pointer assumptions were not set up correctly.",
            )

        if "unwinding assertion" in lower or "unwind" in lower:
            add(
                "unwinding_configuration_problem",
                "medium",
                0.78,
                [h["text"] for h in line_numbered_matches(raw_output, [r"unwind", r"unwinding"], max_hits=8)],
                "The failure may involve loop unwinding. The unwind bound may be too low/high or the loop bound macro may not match the actual implementation loop.",
            )

        # Harness-specific signal: risky assertion arithmetic.
        risky_asserts = line_numbered_matches(harness_text, [r"assert\s*\([^;]*[+\-*][^;]*\)", r"__CPROVER_assert\s*\([^;]*[+\-*][^;]*,"], max_hits=10)
        if risky_asserts and ("overflow" in lower or any("overflow" in str(i).lower() for i in critic_issues)):
            add(
                "assertion_may_be_too_strong_or_type_sensitive",
                "medium",
                0.80,
                [f"harness line {x['line']}: {x['text']}" for x in risky_asserts[:8]],
                "The harness assertion itself performs arithmetic. CBMC may be failing due to the assertion expression or missing input preconditions, not necessarily because the implementation is wrong.",
            )

        # Harness-specific signal: no assumptions but nondet values.
        has_nondet = bool(re.search(r"nondet_|__CPROVER_nondet", harness_text))
        has_assume = bool(re.search(r"__CPROVER_assume\s*\(", harness_text))
        if has_nondet and not has_assume and any(x in lower for x in ["overflow", "assertion", "verification failed"]):
            add(
                "assumptions_too_weak_or_missing",
                "medium",
                0.76,
                ["Harness uses nondeterministic inputs but no __CPROVER_assume preconditions were found."],
                "The generated harness may allow values outside the selected function's intended preconditions. Repair should add only justified assumptions from the specification/code context.",
            )

        # Critic already warned: elevate it into analysis context.
        for issue in critic_issues[:20]:
            sev = str(issue.get("severity", "")).lower()
            typ = str(issue.get("type", "critic_issue"))
            msg = str(issue.get("message") or issue.get("description") or issue)
            if sev in {"critical", "high", "medium"}:
                add(
                    f"critic_prior_warning_{typ}",
                    sev,
                    0.70,
                    [msg],
                    "The Critic Agent already identified this issue before tool execution, so it is relevant to the failure analysis.",
                )

        if not signals:
            add(
                "unknown_or_unclassified_failure",
                "medium",
                0.40,
                [clip(raw_output, 1000) or "No CBMC output was available."],
                "The agent could not classify the failure confidently. Human review should inspect the raw CBMC output and generated harness.",
            )

        # Deduplicate by type + explanation.
        unique: List[FailureSignal] = []
        seen = set()
        for s in signals:
            key = (s.signal_type, s.explanation)
            if key in seen:
                continue
            seen.add(key)
            unique.append(s)
        return unique

    def choose_primary_classification(self, signals: List[FailureSignal]) -> Tuple[str, str, float]:
        priority = {
            "artifact_missing": 100,
            "tool_unavailable": 95,
            "tool_configuration_or_compilation_problem": 90,
            "tool_timeout": 85,
            "no_counterexample_to_analyze": 80,
            "pointer_validity_failure": 75,
            "memory_bounds_failure": 74,
            "integer_overflow_risk": 73,
            "unwinding_configuration_problem": 70,
            "assertion_may_be_too_strong_or_type_sensitive": 68,
            "assumptions_too_weak_or_missing": 66,
            "formal_property_failure": 60,
            "unknown_or_unclassified_failure": 10,
        }
        if not signals:
            return "unknown_or_unclassified_failure", "Could not classify the failure.", 0.0
        best = max(signals, key=lambda s: (priority.get(s.signal_type, 50), s.confidence))
        return best.signal_type, best.explanation, best.confidence

    def infer_failure_source(self, primary_type: str, signals: List[FailureSignal]) -> str:
        if primary_type in {"tool_unavailable", "tool_timeout", "tool_configuration_or_compilation_problem", "artifact_missing"}:
            return "environment_or_tool_configuration"
        if primary_type in {"assumptions_too_weak_or_missing", "assertion_may_be_too_strong_or_type_sensitive", "unwinding_configuration_problem"}:
            return "harness_or_property_issue"
        if primary_type in {"integer_overflow_risk", "memory_bounds_failure", "pointer_validity_failure"}:
            # Conservative: could be harness or code; do not call it code bug directly.
            return "requires_harness_and_code_review"
        if primary_type == "formal_property_failure":
            return "selected_property_failed_under_current_assumptions"
        if primary_type == "no_counterexample_to_analyze":
            return "no_failure_detected"
        return "unknown_requires_human_review"

    # ------------------------------------------------------------------
    # Repair guidance
    # ------------------------------------------------------------------

    def build_repair_guidance(
        self,
        primary_type: str,
        failed_properties: List[JsonDict],
        harness_evidence: JsonDict,
        output_evidence: JsonDict,
    ) -> JsonDict:
        target = str(self.config.get("target_function", "target_function"))
        guidance: List[JsonDict] = []

        def rec(action: str, priority: str, reason: str, concrete_steps: List[str], safe: bool = True) -> None:
            guidance.append(
                {
                    "action": action,
                    "priority": priority,
                    "reason": reason,
                    "concrete_steps": concrete_steps,
                    "safe_for_automatic_repair": safe,
                }
            )

        if primary_type == "tool_unavailable":
            rec(
                "configure_formal_tool",
                "high",
                "CBMC did not run, so repairing the harness alone is not enough.",
                [
                    "Install CBMC or configure cbmc_binary in cbmc_settings/tool_execution_settings.",
                    "Run `which cbmc` in the same shell used by the pipeline.",
                    "Re-run Agent 7 before changing the verification property.",
                ],
                safe=False,
            )
        elif primary_type == "artifact_missing":
            rec(
                "regenerate_or_locate_artifact",
                "critical",
                "The harness file is missing.",
                [
                    "Re-run Agent 5 Formal Artifact Generation.",
                    "Check current_artifact in run_config.resolved.json.",
                    "Ensure Master Orchestrator promotes 08_repaired_harness.c only after it exists.",
                ],
                safe=True,
            )
        elif primary_type == "tool_configuration_or_compilation_problem":
            rec(
                "fix_tool_command_and_includes",
                "high",
                "CBMC failed before clean verification, likely due to source/header/config problems.",
                [
                    "Check 06_cbmc_command.txt and make sure all included source files exist.",
                    "Add missing include directories to tool_execution_settings.include_dirs.",
                    "If the generated harness has syntax errors, repair only syntax/headers first; do not change the property yet.",
                    "Keep the same target function and rerun CBMC after command repair.",
                ],
                safe=True,
            )
        elif primary_type == "tool_timeout":
            rec(
                "simplify_harness_or_bound_unwinding",
                "medium",
                "The tool timed out; the verification search space may be too large.",
                [
                    "Reduce the first experiment to one property category, e.g., memory/bounds before functional equality.",
                    "Use the implementation loop bound exactly; for ML-KEM polynomial loops this is usually 256 only when justified by code constants.",
                    "Avoid unnecessary helper calls or large nondeterministic object graphs in the first harness.",
                ],
                safe=True,
            )
        else:
            if any(str(p.get("property_type")) == "integer_overflow" for p in failed_properties) or output_evidence.get("overflow_lines"):
                rec(
                    "separate_overflow_from_functional_assertion",
                    "high",
                    "Overflow-related failures often come from too-broad nondeterministic inputs or arithmetic inside the assertion.",
                    [
                        "Do not silently narrow input bounds unless the spec/code summary justifies the bounds.",
                        "Move expected arithmetic into a wider temporary type when checking equality, if that matches C semantics being tested.",
                        "Create one harness for overflow safety and another harness for functional equality under documented preconditions.",
                        "Record every range assumption with evidence from 01_spec_summary.json or code constants.",
                    ],
                    safe=True,
                )
            if output_evidence.get("bounds_lines"):
                rec(
                    "review_loop_bound_and_object_size",
                    "high",
                    "Bounds failure may mean the harness object size, macro definition, or unwind setting does not match the implementation.",
                    [
                        f"Confirm the loop bound used by `{target}` in 02_code_summary.json.",
                        "Ensure the local objects allocated in the harness have the same struct type expected by the target function.",
                        "Ensure CBMC command uses --unwind equal to or larger than the real loop iterations and keeps --unwinding-assertions enabled.",
                    ],
                    safe=True,
                )
            if output_evidence.get("pointer_lines"):
                rec(
                    "fix_pointer_object_setup",
                    "high",
                    "Pointer failures often occur when the harness passes invalid or uninitialized objects.",
                    [
                        "Use concrete local objects such as `poly r; poly a; poly b;` and pass their addresses.",
                        "Avoid nondeterministic raw pointers for first harnesses unless pointer validity assumptions are explicitly added.",
                        "Initialize input object fields before calling the target function.",
                    ],
                    safe=True,
                )
            if output_evidence.get("unwind_lines"):
                rec(
                    "adjust_unwind_configuration",
                    "medium",
                    "Loop unwinding may be insufficient or not matched to the implementation loop.",
                    [
                        "Set tool_execution_settings.unwind to the extracted loop bound, e.g., 256 for polynomial coefficient loops when justified.",
                        "Keep --unwinding-assertions so incomplete unwinding is not hidden.",
                    ],
                    safe=True,
                )
            if primary_type in {"assumptions_too_weak_or_missing", "assertion_may_be_too_strong_or_type_sensitive", "formal_property_failure", "integer_overflow_risk", "memory_bounds_failure", "pointer_validity_failure"}:
                rec(
                    "repair_harness_assumptions_and_assertions",
                    "medium",
                    "The selected property failed under the current candidate assumptions.",
                    [
                        "List each assumption and link it to spec/code evidence before keeping it.",
                        "Split large assertions into smaller checkable assertions.",
                        "Avoid proving a trivial property by over-constraining inputs.",
                        "Keep failed and repaired harnesses in the log for thesis evaluation.",
                    ],
                    safe=True,
                )

        if not guidance:
            rec(
                "manual_review_required",
                "medium",
                "The failure was not confidently classified.",
                [
                    "Inspect 06_cbmc_output.txt manually.",
                    "Compare failed property with 03_candidate_properties.json.",
                    "Ask whether the failure is due to harness design, assumptions, tool command, or possible code behavior.",
                ],
                safe=False,
            )

        return {
            "repair_required": primary_type != "no_counterexample_to_analyze",
            "preferred_next_agent": "repair_agent" if primary_type != "no_counterexample_to_analyze" else "evaluation_reporter",
            "guidance": guidance,
            "guardrails_for_repair_agent": [
                "Do not remove a failing assertion only to force CBMC success.",
                "Do not add assumptions unless justified by specification summary, code summary, or human notes.",
                "Do not claim a repaired harness proves full ML-KEM correctness.",
                "Keep original failure evidence and repaired artifact both logged.",
            ],
        }

    # ------------------------------------------------------------------
    # Prompt/report rendering
    # ------------------------------------------------------------------

    def build_prompt_record(self, artifact_path: Path, harness_text: str) -> str:
        target = self.config.get("target_function", "unknown")
        return textwrap.dedent(
            f"""
            You are the Counterexample Analysis Agent for an AI-assisted formal-verification artifact workflow.

            Target function: {target}
            Iteration: {self.iteration}
            Artifact: {artifact_path}

            Task:
            1. Read the CBMC status and raw output.
            2. Identify whether the result is a proof failure, harness problem, assumption problem, assertion problem, tool setup problem, or possible implementation issue.
            3. Use only evidence from the tool output, generated harness, critic review, specification summary, and code summary.
            4. Do not claim the whole implementation is wrong from one candidate harness.
            5. Do not claim full ML-KEM verification from one passing harness.
            6. Produce repair guidance that preserves scientific honesty and reproducibility.

            CBMC status summary:
            {json.dumps({k: self.cbmc_status.get(k) for k in ['status', 'verification_passed', 'counterexample_available', 'failed_property', 'summary']}, indent=2, ensure_ascii=False)}

            Harness excerpt:
            {clip(harness_text, 2500)}

            Raw CBMC output excerpt:
            {clip(self.raw_output, 3000)}
            """
        ).strip() + "\n"

    def render_markdown(self, analysis: JsonDict) -> str:
        lines: List[str] = [
            "# Agent 8 — Counterexample Analysis Report",
            "",
            f"- **Created at:** {analysis.get('created_at')}",
            f"- **Target function:** `{analysis.get('target_function')}`",
            f"- **Iteration:** {analysis.get('iteration')}",
            f"- **Tool status:** `{safe_get(analysis, 'tool_result', 'status')}`",
            f"- **Primary classification:** `{analysis.get('primary_classification')}`",
            f"- **Failure source:** `{analysis.get('failure_source')}`",
            f"- **Confidence:** {analysis.get('classification_confidence')}",
            "",
            "## Plain-English Explanation",
            "",
            str(analysis.get("plain_english_explanation") or "No explanation available."),
            "",
            "## Failed Properties",
            "",
        ]

        failed = analysis.get("failed_properties") or []
        if failed:
            for p in failed[:20]:
                lines.append(f"- `{p.get('property_id')}` — **{p.get('property_type')}** — {p.get('description')}")
        else:
            lines.append("- No failed property lines were extracted.")
        lines.append("")

        signals = analysis.get("failure_signals") or []
        lines.extend(["## Failure Signals", ""])
        for s in signals[:20]:
            lines.append(f"- **{s.get('signal_type')}** ({s.get('severity')}, confidence {s.get('confidence')}): {s.get('explanation')}")
        if not signals:
            lines.append("- No signals extracted.")
        lines.append("")

        lines.extend(["## Suggested Repair Guidance", ""])
        repair = analysis.get("repair_guidance") or {}
        guidance = repair.get("guidance") or []
        for item in guidance:
            lines.append(f"### {item.get('action')} — {item.get('priority')}")
            lines.append("")
            lines.append(str(item.get("reason") or ""))
            lines.append("")
            for step in item.get("concrete_steps") or []:
                lines.append(f"- {step}")
            lines.append("")
        if not guidance:
            lines.append("- No automatic guidance generated.")
            lines.append("")

        lines.extend(
            [
                "## Scientific Guardrail",
                "",
                "This analysis explains one selected CBMC run for one candidate artifact. It must not be reported as a full proof or full disproof of ML-KEM. Human review remains required.",
                "",
                "## Output Files",
                "",
                "- `07_counterexample_analysis.json`",
                "- `07_counterexample_analysis.md`",
                "- `llm_prompts/07_counterexample_analysis_prompt.txt`",
                "",
            ]
        )
        return "\n".join(lines)

    # ------------------------------------------------------------------
    # Main execution
    # ------------------------------------------------------------------

    def analyze(self) -> JsonDict:
        self.log_event("agent_start", {"iteration": self.iteration})

        artifact_path = self.resolve_artifact_path()
        harness_text = read_text(artifact_path, default="")
        failed_properties = self.parse_failed_properties(self.raw_output)
        output_evidence = self.extract_relevant_output_evidence(self.raw_output)
        harness_evidence = self.extract_harness_evidence(harness_text)
        trace_assignments = self.extract_trace_assignments(self.raw_output)
        signals = self.build_failure_signals(self.raw_output, harness_text, failed_properties)
        primary_type, explanation, confidence = self.choose_primary_classification(signals)
        failure_source = self.infer_failure_source(primary_type, signals)
        repair_guidance = self.build_repair_guidance(primary_type, failed_properties, harness_evidence, output_evidence)

        status = str(self.cbmc_status.get("status", "missing_status"))
        tool_result = {
            "status": status,
            "verification_passed": self.cbmc_status.get("verification_passed"),
            "counterexample_available": self.cbmc_status.get("counterexample_available"),
            "failed_property": self.cbmc_status.get("failed_property"),
            "failed_properties_count": self.cbmc_status.get("failed_properties_count"),
            "returncode": self.cbmc_status.get("returncode"),
            "summary": self.cbmc_status.get("summary"),
            "output_file": str(self.cbmc_output_path),
            "status_file": str(self.cbmc_status_path),
        }

        # A careful sentence for thesis logs.
        if primary_type == "no_counterexample_to_analyze":
            plain = "CBMC reported success for the selected candidate harness/properties, so this agent did not find a counterexample to explain. The result still only applies under the recorded harness assumptions."
        elif primary_type in {"tool_unavailable", "artifact_missing", "tool_configuration_or_compilation_problem", "tool_timeout"}:
            plain = explanation
        else:
            plain = (
                explanation
                + " This does not automatically mean the ML-KEM implementation is wrong. The safer interpretation is that the current candidate harness/property/assumption set needs review and possibly repair before making any correctness claim."
            )

        analysis: JsonDict = {
            "agent": "counterexample_analysis_agent",
            "agent_number": 8,
            "created_at": utc_now(),
            "iteration": self.iteration,
            "target_scheme": self.config.get("target_scheme"),
            "target_function": self.config.get("target_function"),
            "verification_tool": self.config.get("verification_tool", "CBMC"),
            "artifact_file": str(artifact_path),
            "artifact_exists": artifact_path.exists(),
            "artifact_sha256": sha256_file(artifact_path),
            "tool_result": tool_result,
            "primary_classification": primary_type,
            "failure_source": failure_source,
            "classification_confidence": round(float(confidence), 3),
            "plain_english_explanation": plain,
            "failed_properties": failed_properties,
            "trace_assignments_sample": trace_assignments[:40],
            "output_evidence": output_evidence,
            "harness_evidence": harness_evidence,
            "critic_context": {
                "review_status": self.critic_review.get("review_status") or self.critic_review.get("status"),
                "highest_severity": self.critic_review.get("highest_severity"),
                "issues": self.read_critic_issues()[:30],
            },
            "property_context": {
                "candidate_properties_file": str(self.run_dir / "03_candidate_properties.json"),
                "candidate_properties_count": len(as_list(self.properties.get("candidate_properties"))),
                "selected_properties": self.properties.get("selected_properties") or self.properties.get("cbmc_property_plan") or [],
            },
            "failure_signals": [dataclasses.asdict(s) for s in signals],
            "repair_guidance": repair_guidance,
            "next_required_agent": repair_guidance.get("preferred_next_agent"),
            "human_review_required": True,
            "scientific_guardrails": {
                "candidate_artifact_only": True,
                "formal_tool_checks_selected_harness_only": True,
                "do_not_claim_full_mlkem_failure": True,
                "do_not_claim_full_mlkem_proof": True,
                "cbmc_failure_may_be_harness_or_assumption_problem": True,
                "human_review_required": True,
            },
        }

        prompt_record = self.build_prompt_record(artifact_path, harness_text)
        markdown = self.render_markdown(analysis)

        write_text(self.prompt_path, prompt_record)
        write_json(self.analysis_path, analysis)
        write_text(self.md_path, markdown)
        write_json(
            self.agent_status_path,
            {
                "agent": "counterexample_analysis_agent",
                "status": "completed",
                "created_at": utc_now(),
                "iteration": self.iteration,
                "primary_classification": primary_type,
                "failure_source": failure_source,
                "repair_required": repair_guidance.get("repair_required"),
                "outputs": {
                    "analysis_json": str(self.analysis_path),
                    "analysis_markdown": str(self.md_path),
                    "prompt_record": str(self.prompt_path),
                },
            },
        )

        self.log_event(
            "agent_finish",
            {
                "iteration": self.iteration,
                "primary_classification": primary_type,
                "failure_source": failure_source,
                "repair_required": repair_guidance.get("repair_required"),
                "analysis_file": str(self.analysis_path),
            },
        )

        print(f"[OK] Counterexample Analysis Agent wrote: {self.analysis_path}")
        print(f"[OK] Markdown report: {self.md_path}")
        print(f"[CLASSIFICATION] {primary_type}")
        print(f"[NEXT] {repair_guidance.get('preferred_next_agent')}")
        print("[NOTE] Analysis is for the selected candidate artifact only; human review remains required.")
        return analysis


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Counterexample Analysis Agent for AI-assisted formal-verification artifact workflow."
    )
    parser.add_argument("--config", required=True, help="Path to config JSON or run_config.resolved.json")
    parser.add_argument("--run-dir", required=True, help="Run directory, e.g., runs/run_001_poly_add")
    parser.add_argument("--iteration", type=int, default=0, help="Refinement iteration number")
    parser.add_argument("--artifact", default=None, help="Optional artifact path/name to analyze")
    parser.add_argument("--output-prefix", default="07", help="Output prefix; default 07")
    return parser


def main(argv: Optional[List[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    agent = CounterexampleAnalysisAgent(
        config_path=Path(args.config),
        run_dir=Path(args.run_dir),
        iteration=args.iteration,
        artifact=args.artifact,
        output_prefix=args.output_prefix,
    )
    agent.analyze()
    # Return 0 even for verification failure: this agent's job is to classify it.
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
