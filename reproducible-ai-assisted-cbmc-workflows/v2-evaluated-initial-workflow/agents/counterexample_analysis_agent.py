#!/usr/bin/env python3
"""
Counterexample Analysis Agent v2 (Agent 8)
==========================================

Purpose
-------
Analyzes a non-passing CBMC/formal-tool result produced by Agent 7 and explains
why the verification attempt failed or could not be completed.

This v2 upgrade is designed for the fully automated thesis-agent workflow. It
preserves the old Agent 8 output contract while adding richer traceability for
Agent 9 Repair, Agent 10 Logger, and Agent 11 Evaluation.

Scientific guardrail
--------------------
This agent never treats one CBMC failure as a complete implementation bug and
never treats one CBMC pass as a full proof of ML-KEM. It classifies the selected
candidate harness/tool result only. Human review remains mandatory.

Expected legacy inputs in run directory
---------------------------------------
- 06_cbmc_status.json
- 06_cbmc_output.txt
- 06_cbmc_property_results.json, if available
- 04_generated_harness.c or 08_repaired_harness.c
- 04_artifact_manifest.json, if available
- 05_critic_review.json, if available
- 03_candidate_properties.json, if available
- 02_code_summary.json, if available
- 01_spec_summary.json, if available

Optional v2 inputs
------------------
- 06_tool_command_manifest.json
- 06_tool_environment_snapshot.json
- 06_critic_gate_decision.json
- 06_cbmc_diagnostics.json
- 06_cbmc_trace_summary.json
- 06_failed_property_mapping.json
- 06_tool_execution_traceability.json
- 05_spec_grounding_review.json
- 05_assumption_evidence_review.csv
- 05_assertion_algorithm_alignment.csv
- 05_symbol_uncertainty_review.json
- 04_spec_grounding_report.json
- 04_spec_grounded_assertion_plan.json
- 04_harness_assumption_traceability.csv
- 03_spec_code_traceability.json
- 03_property_evidence_matrix.csv
- 01_algorithm_blocks.json
- 01_symbol_table.json
- 01_parameter_table.json
- 01_equations_constraints.json
- 01_preconditions_postconditions.json
- 01_spec_to_code_hints.json

Legacy outputs preserved
------------------------
- 07_counterexample_analysis.json
- 07_counterexample_analysis.md
- llm_prompts/07_counterexample_analysis_prompt.txt
- agent_status/07_counterexample_analysis_status.json

New v2 outputs
--------------
- 07_failure_classification_matrix.csv
- 07_cbmc_trace_summary.json
- 07_repair_guidance.json
- 07_failed_property_mapping.json
- 07_tool_vs_harness_vs_code_diagnosis.json
- 07_assumption_assertion_failure_map.csv
- 07_repair_action_plan.json
- 07_agent7v2_integration_report.json

Python: 3.10+
Dependencies: standard library only.
"""

from __future__ import annotations

import argparse
import csv
import dataclasses
import datetime as _dt
import hashlib
import json
import os
import platform
import re
import shutil
import subprocess
import textwrap
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

JsonDict = Dict[str, Any]

AGENT_NAME = "counterexample_analysis_agent"
AGENT_VERSION = "2.0.0"
AGENT_NUMBER = 8
OUTPUT_PREFIX = "07"

SCIENTIFIC_GUARDRAIL = (
    "This analysis applies only to the selected candidate formal-verification "
    "artifact, selected CBMC/formal-tool command, selected properties, and stated "
    "assumptions. It is not a proof or disproof of full ML-KEM correctness. "
    "CBMC/formal tools and human review remain authoritative."
)

SEVERITY_RANK = {
    "critical": 5,
    "high": 4,
    "medium": 3,
    "low": 2,
    "info": 1,
    "unknown": 0,
}


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
    except OSError as exc:
        return f"[READ_ERROR: {type(exc).__name__}: {exc}]"


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


def read_json(path: Path, default: Optional[Any] = None) -> Any:
    if default is None:
        default = {}
    try:
        return json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except FileNotFoundError:
        if isinstance(default, dict):
            return dict(default)
        if isinstance(default, list):
            return list(default)
        return default
    except json.JSONDecodeError as exc:
        return {
            "_json_error": True,
            "path": str(path),
            "error": str(exc),
            "raw_preview": read_text(path)[:1000],
        }
    except OSError as exc:
        return {
            "_read_error": True,
            "path": str(path),
            "error": f"{type(exc).__name__}: {exc}",
        }


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    tmp.replace(path)


def write_csv(path: Path, rows: List[Dict[str, Any]], fieldnames: Optional[List[str]] = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if fieldnames is None:
        fieldnames = []
        for row in rows:
            for key in row:
                if key not in fieldnames:
                    fieldnames.append(key)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({key: csv_value(row.get(key, "")) for key in fieldnames})


def read_csv_rows(path: Path) -> List[Dict[str, str]]:
    if not path.exists():
        return []
    try:
        with path.open("r", encoding="utf-8", newline="") as f:
            return list(csv.DictReader(f))
    except Exception:
        return []


def csv_value(value: Any) -> str:
    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False)
    if value is None:
        return ""
    return str(value)


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


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="replace")).hexdigest()


def unique_preserve_order(items: Iterable[Any]) -> List[Any]:
    seen = set()
    out: List[Any] = []
    for item in items:
        if isinstance(item, (dict, list)):
            key = json.dumps(item, sort_keys=True, ensure_ascii=False, default=str)
        else:
            key = str(item)
        if key in seen:
            continue
        seen.add(key)
        out.append(item)
    return out


def as_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    if isinstance(value, tuple):
        return list(value)
    return [value]


def safe_get(data: Any, *keys: Any, default: Any = None) -> Any:
    cur = data
    for key in keys:
        if isinstance(cur, dict):
            if key not in cur:
                return default
            cur = cur[key]
        elif isinstance(cur, list) and isinstance(key, int):
            if key < 0 or key >= len(cur):
                return default
            cur = cur[key]
        else:
            return default
    return cur


def flatten_text(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, (int, float, bool)):
        return str(value)
    try:
        return json.dumps(value, ensure_ascii=False, sort_keys=True, default=str)
    except Exception:
        return str(value)


def compact_ws(text: str) -> str:
    return re.sub(r"\s+", " ", str(text)).strip()


def clip(text: str, limit: int = 4000) -> str:
    if len(text) <= limit:
        return text
    return text[:limit] + f"\n...[clipped after {limit} chars]..."


def line_numbered_matches(text: str, patterns: Sequence[str], max_hits: int = 20) -> List[JsonDict]:
    hits: List[JsonDict] = []
    compiled = [re.compile(p, flags=re.IGNORECASE) for p in patterns]
    for idx, line in enumerate(text.splitlines(), start=1):
        stripped = line.strip()
        if not stripped:
            continue
        for pat in compiled:
            if pat.search(stripped):
                hits.append({"line": idx, "text": stripped[:700], "pattern": pat.pattern})
                break
        if len(hits) >= max_hits:
            break
    return hits


def highest_severity(items: List[Dict[str, Any]]) -> str:
    best = "unknown"
    score = -1
    for item in items:
        sev = str(item.get("severity") or item.get("level") or "unknown").lower()
        val = SEVERITY_RANK.get(sev, 0)
        if val > score:
            score = val
            best = sev
    return best


def normalize_status(value: Any) -> str:
    s = str(value or "").strip().lower()
    if not s:
        return "unknown"
    if s in {"pass", "passed", "success", "successful", "verification_successful"}:
        return "passed"
    if s in {"fail", "failed", "failure", "verification_failed"}:
        return "failed"
    if "unavailable" in s:
        return "tool_unavailable"
    if "timeout" in s:
        return "timeout"
    if "artifact_missing" in s:
        return "artifact_missing"
    if "critic_blocked" in s or "blocked" in s:
        return "critic_blocked"
    if "error" in s:
        return "tool_error"
    return s


def bool_like(value: Any) -> Optional[bool]:
    if isinstance(value, bool):
        return value
    if value is None:
        return None
    if isinstance(value, (int, float)):
        return bool(value)
    s = str(value).strip().lower()
    if s in {"true", "yes", "1", "y", "allowed", "allow"}:
        return True
    if s in {"false", "no", "0", "n", "blocked", "deny", "denied"}:
        return False
    return None


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
    likely_source: str
    recommended_action: str


@dataclasses.dataclass
class FailedProperty:
    property_id: Optional[str]
    description: str
    property_type: str
    status: str
    raw_line: str
    source: str = "cbmc_output"
    mapped_candidate_property_id: Optional[str] = None
    mapped_harness_evidence: Optional[str] = None


@dataclasses.dataclass
class TraceAssignment:
    variable: str
    value: str
    line: Optional[int]
    raw_line: str
    source: str = "06_cbmc_output.txt"


# ---------------------------------------------------------------------------
# Main Agent 8 v2
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
        output_prefix: str = OUTPUT_PREFIX,
    ) -> None:
        self.config_path = config_path.expanduser().resolve()
        self.project_root = self.infer_project_root(self.config_path)
        self.config = read_json(self.config_path, default={})
        if not isinstance(self.config, dict):
            self.config = {}

        initial_run_dir = self.resolve_run_dir(run_dir)
        resolved_config = read_json(initial_run_dir / "run_config.resolved.json", default={})
        if isinstance(resolved_config, dict) and resolved_config:
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

        # New v2 paths.
        self.failure_matrix_path = self.run_dir / "07_failure_classification_matrix.csv"
        self.trace_summary_path = self.run_dir / "07_cbmc_trace_summary.json"
        self.repair_guidance_path = self.run_dir / "07_repair_guidance.json"
        self.failed_property_mapping_path = self.run_dir / "07_failed_property_mapping.json"
        self.diagnosis_path = self.run_dir / "07_tool_vs_harness_vs_code_diagnosis.json"
        self.assumption_assertion_map_path = self.run_dir / "07_assumption_assertion_failure_map.csv"
        self.repair_action_plan_path = self.run_dir / "07_repair_action_plan.json"
        self.agent7v2_integration_path = self.run_dir / "07_agent7v2_integration_report.json"

        self.spec_summary = read_json(self.run_dir / "01_spec_summary.json", default={})
        self.code_summary = read_json(self.run_dir / "02_code_summary.json", default={})
        self.properties = read_json(self.run_dir / "03_candidate_properties.json", default={})
        self.manifest = self.load_manifest()
        self.critic_review = read_json(self.run_dir / "05_critic_review.json", default={})
        self.cbmc_status = read_json(self.cbmc_status_path, default={})
        self.cbmc_property_results = read_json(self.cbmc_properties_path, default={})
        self.raw_output = read_text(self.cbmc_output_path, default="")

        # Rich v2 context.
        self.tool_command_manifest = read_json(self.run_dir / "06_tool_command_manifest.json", default={})
        self.tool_environment_snapshot = read_json(self.run_dir / "06_tool_environment_snapshot.json", default={})
        self.critic_gate_decision = read_json(self.run_dir / "06_critic_gate_decision.json", default={})
        self.cbmc_diagnostics = read_json(self.run_dir / "06_cbmc_diagnostics.json", default={})
        self.agent7_trace_summary = read_json(self.run_dir / "06_cbmc_trace_summary.json", default={})
        self.agent7_failed_mapping = read_json(self.run_dir / "06_failed_property_mapping.json", default={})
        self.tool_execution_traceability = read_json(self.run_dir / "06_tool_execution_traceability.json", default={})

        self.spec_grounding_review = read_json(self.run_dir / "05_spec_grounding_review.json", default={})
        self.assumption_evidence_review_rows = read_csv_rows(self.run_dir / "05_assumption_evidence_review.csv")
        self.assertion_alignment_rows = read_csv_rows(self.run_dir / "05_assertion_algorithm_alignment.csv")
        self.symbol_uncertainty_review = read_json(self.run_dir / "05_symbol_uncertainty_review.json", default={})
        self.spec_grounding_report = read_json(self.run_dir / "04_spec_grounding_report.json", default={})
        self.assertion_plan = read_json(self.run_dir / "04_spec_grounded_assertion_plan.json", default={})
        self.harness_assumption_traceability_rows = read_csv_rows(self.run_dir / "04_harness_assumption_traceability.csv")
        self.spec_code_traceability = read_json(self.run_dir / "03_spec_code_traceability.json", default={})
        self.property_evidence_matrix_rows = read_csv_rows(self.run_dir / "03_property_evidence_matrix.csv")
        self.algorithm_blocks = read_json(self.run_dir / "01_algorithm_blocks.json", default={})
        self.symbol_table = read_json(self.run_dir / "01_symbol_table.json", default={})
        self.parameter_table = read_json(self.run_dir / "01_parameter_table.json", default={})
        self.equations_constraints = read_json(self.run_dir / "01_equations_constraints.json", default={})
        self.prepost = read_json(self.run_dir / "01_preconditions_postconditions.json", default={})
        self.spec_to_code_hints = read_json(self.run_dir / "01_spec_to_code_hints.json", default={})

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
            if isinstance(data, dict) and data:
                data["_manifest_path"] = str(self.run_dir / name)
                return data
        return {}

    def resolve_artifact_path(self) -> Path:
        candidates: List[Any] = []
        if self.artifact_arg:
            candidates.append(self.artifact_arg)
        for key in ["artifact_file", "artifact_path"]:
            if isinstance(self.cbmc_status, dict) and self.cbmc_status.get(key):
                candidates.append(self.cbmc_status.get(key))
        for name in ["08_repaired_harness.c", "04_generated_harness.c"]:
            candidates.append(self.run_dir / name)

        for candidate in candidates:
            p = Path(str(candidate)).expanduser()
            if not p.is_absolute():
                in_run = (self.run_dir / p).resolve()
                in_project = (self.project_root / p).resolve()
                p = in_run if in_run.exists() else in_project
            if p.exists():
                return p.resolve()

        fallback = self.artifact_arg or "04_generated_harness.c"
        p = Path(str(fallback)).expanduser()
        if p.is_absolute():
            return p.resolve()
        return (self.run_dir / p).resolve()

    def log_event(self, event_type: str, payload: JsonDict, status: str = "info") -> None:
        append_jsonl(
            self.events_path,
            {
                "ts": utc_now(),
                "agent": AGENT_NAME,
                "agent_version": AGENT_VERSION,
                "event": event_type,
                "status": status,
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

    def candidate_properties(self) -> List[Dict[str, Any]]:
        candidates = safe_get(self.properties, "candidate_properties", default=[])
        if isinstance(candidates, list):
            return [p for p in candidates if isinstance(p, dict)]
        for key in ["properties", "selected_properties", "cbmc_property_plan"]:
            value = safe_get(self.properties, key, default=[])
            if isinstance(value, list):
                return [p for p in value if isinstance(p, dict)]
        return []

    def parse_failed_properties(self, raw_output: str) -> List[JsonDict]:
        failed: List[FailedProperty] = []

        # Prefer structured property results from Agent 7 v2 status.
        for source_name, items in [
            ("06_cbmc_status.json", as_list(safe_get(self.cbmc_status, "property_results", default=[]))),
            ("06_cbmc_property_results.json", as_list(safe_get(self.cbmc_property_results, "property_results", default=[]))),
        ]:
            for item in items:
                if not isinstance(item, dict):
                    continue
                status = str(item.get("status") or item.get("result") or "").upper()
                if status not in {"FAILURE", "FAILED", "FALSE"}:
                    continue
                raw_line = str(item.get("raw_line") or item.get("description") or item.get("property_id") or "")
                prop_id = item.get("property_id") or item.get("id") or item.get("name")
                failed.append(
                    FailedProperty(
                        property_id=str(prop_id) if prop_id else None,
                        description=str(item.get("description") or raw_line),
                        property_type=str(item.get("property_type") or self.classify_property_type(raw_line)),
                        status="FAILURE",
                        raw_line=raw_line,
                        source=source_name,
                    )
                )

        # Agent 7 v2 may already have a mapping file.
        if isinstance(self.agent7_failed_mapping, dict):
            mappings = self.agent7_failed_mapping.get("mappings") or self.agent7_failed_mapping.get("failed_property_mappings") or []
            for item in as_list(mappings):
                if not isinstance(item, dict):
                    continue
                status = str(item.get("status") or item.get("cbmc_status") or "FAILURE").upper()
                if "FAIL" not in status:
                    continue
                raw_line = str(item.get("raw_line") or item.get("cbmc_property_id") or item.get("property_id") or "")
                failed.append(
                    FailedProperty(
                        property_id=str(item.get("cbmc_property_id") or item.get("property_id") or "") or None,
                        description=str(item.get("description") or item.get("mapped_description") or raw_line),
                        property_type=str(item.get("property_type") or self.classify_property_type(raw_line)),
                        status="FAILURE",
                        raw_line=raw_line,
                        source="06_failed_property_mapping.json",
                        mapped_candidate_property_id=str(item.get("candidate_property_id") or "") or None,
                        mapped_harness_evidence=str(item.get("harness_evidence") or "") or None,
                    )
                )

        # Parse raw CBMC output directly as fallback.
        for line in raw_output.splitlines():
            stripped = line.strip()
            m = re.match(r"^\[([^\]]+)\]\s*(.*?):\s*(FAILURE|FAILED)\s*$", stripped, flags=re.IGNORECASE)
            if m:
                failed.append(
                    FailedProperty(
                        property_id=m.group(1),
                        description=m.group(2).strip(),
                        property_type=self.classify_property_type(stripped),
                        status="FAILURE",
                        raw_line=stripped,
                        source="06_cbmc_output.txt",
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
                        source="06_cbmc_output.txt",
                    )
                )

        # Deduplicate and map to candidate properties.
        out: List[JsonDict] = []
        for fp in unique_preserve_order([dataclasses.asdict(x) for x in failed]):
            if not fp.get("mapped_candidate_property_id"):
                mapped = self.map_failed_property_to_candidate(fp)
                if mapped:
                    fp["mapped_candidate_property_id"] = mapped.get("id") or mapped.get("property_id")
                    fp["mapped_candidate_property_type"] = mapped.get("type")
                    fp["mapping_confidence"] = mapped.get("mapping_confidence", "heuristic")
            out.append(fp)
        return out

    def map_failed_property_to_candidate(self, failed_property: JsonDict) -> Optional[Dict[str, Any]]:
        text = flatten_text(failed_property).lower()
        fp_type = str(failed_property.get("property_type") or "").lower()
        candidates = self.candidate_properties()
        if not candidates:
            return None

        best: Optional[Dict[str, Any]] = None
        best_score = 0
        for cand in candidates:
            score = 0
            ctype = str(cand.get("type") or "").lower()
            desc = str(cand.get("description") or cand.get("text") or "").lower()
            cid = str(cand.get("id") or cand.get("property_id") or "").lower()
            tags = flatten_text(cand.get("tags") or "").lower()
            if cid and cid in text:
                score += 10
            if fp_type and fp_type in ctype:
                score += 6
            for token in ["pointer", "bounds", "array", "overflow", "assert", "unwind", "memory", "range", "functional"]:
                if token in text and (token in ctype or token in desc or token in tags):
                    score += 3
            # CBMC property names often contain assertion/bounds/pointer.
            for word in re.findall(r"[A-Za-z_][A-Za-z0-9_]+", text):
                if len(word) > 4 and word in desc:
                    score += 1
            if score > best_score:
                best_score = score
                best = dict(cand)
        if best and best_score > 0:
            best["mapping_score"] = best_score
            best["mapping_confidence"] = "high" if best_score >= 10 else "medium" if best_score >= 5 else "low"
            return best
        return None

    def extract_trace_assignments(self, raw_output: str, max_hits: int = 80) -> List[JsonDict]:
        assignments: List[TraceAssignment] = []
        patterns = [
            re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_\-\.\[\]>]*)\s*=\s*(.+?)\s*$"),
            re.compile(r"^\s*value\s*:\s*(.+?)\s*$", re.IGNORECASE),
            re.compile(r"^\s*assignment\s*\(?\s*([^\)]*)\)?\s*:\s*(.+?)\s*$", re.IGNORECASE),
            re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_\-\.\[\]>]*)\s*:=\s*(.+?)\s*$"),
        ]
        for line_no, line in enumerate(raw_output.splitlines(), start=1):
            stripped = line.strip()
            if not stripped or len(assignments) >= max_hits:
                break
            if stripped.startswith("[") or re.search(r"\b(SUCCESS|FAILURE|UNKNOWN)\b", stripped):
                continue
            for pat in patterns:
                m = pat.match(stripped)
                if not m:
                    continue
                if pat.pattern.startswith("^\\s*value"):
                    assignments.append(TraceAssignment(variable="value", value=m.group(1).strip(), line=line_no, raw_line=stripped))
                elif len(m.groups()) >= 2:
                    variable = compact_ws(m.group(1))
                    value = compact_ws(m.group(2))
                    if variable and value:
                        assignments.append(TraceAssignment(variable=variable, value=value, line=line_no, raw_line=stripped))
                break
        return [dataclasses.asdict(x) for x in assignments]

    def extract_relevant_output_evidence(self, raw_output: str) -> JsonDict:
        patterns = {
            "failure_lines": [r"\bFAILURE\b", r"verification failed", r"violated property", r"counterexample", r"Violated property"],
            "overflow_lines": [r"overflow", r"arithmetic overflow", r"signed", r"unsigned"],
            "bounds_lines": [r"array", r"bounds", r"out of bounds", r"buffer", r"object bounds"],
            "pointer_lines": [r"pointer", r"dereference", r"NULL", r"invalid pointer"],
            "unwind_lines": [r"unwind", r"unwinding", r"unwinding assertion"],
            "tool_error_lines": [r"ERROR:", r"parse error", r"syntax error", r"failed to open", r"not found", r"conversion error", r"tool unavailable", r"PARSING ERROR", r"CONVERSION ERROR"],
            "assertion_lines": [r"assert", r"assertion", r"__CPROVER_assert"],
        }
        out = {name: line_numbered_matches(raw_output, pats, max_hits=20) for name, pats in patterns.items()}
        if isinstance(self.cbmc_diagnostics, dict) and self.cbmc_diagnostics:
            out["agent7_v2_diagnostics"] = self.cbmc_diagnostics
        return out

    def extract_harness_evidence(self, harness_text: str) -> JsonDict:
        target = str(self.config.get("target_function") or self.manifest.get("target_function") or "")
        return {
            "assumptions": line_numbered_matches(harness_text, [r"__CPROVER_assume\s*\(", r"assume\s*\("], max_hits=50),
            "assertions": line_numbered_matches(harness_text, [r"\bassert\s*\(", r"__CPROVER_assert\s*\("], max_hits=50),
            "nondet_inputs": line_numbered_matches(harness_text, [r"nondet_[A-Za-z0-9_]+\s*\(", r"__CPROVER_nondet"], max_hits=50),
            "target_calls": line_numbered_matches(harness_text, [re.escape(target) + r"\s*\("], max_hits=30) if target else [],
            "loop_lines": line_numbered_matches(harness_text, [r"\bfor\s*\(", r"\bwhile\s*\("], max_hits=30),
            "includes": line_numbered_matches(harness_text, [r"^\s*#\s*include"], max_hits=50),
            "repair_markers": line_numbered_matches(harness_text, [r"Repair Agent", r"candidate precondition", r"human review"], max_hits=50),
        }

    def read_critic_issues(self) -> List[JsonDict]:
        issues: List[JsonDict] = []
        for key in ["issues", "findings", "review_issues", "blocking_issues", "warnings"]:
            for issue in as_list(safe_get(self.critic_review, key, default=[])):
                if isinstance(issue, dict):
                    issues.append(issue)
                elif isinstance(issue, str):
                    issues.append({"message": issue, "severity": "unknown", "source": key})
        if isinstance(self.spec_grounding_review, dict):
            for issue in as_list(self.spec_grounding_review.get("issues")):
                if isinstance(issue, dict):
                    item = dict(issue)
                    item.setdefault("source", "05_spec_grounding_review.json")
                    issues.append(item)
        return unique_preserve_order(issues)

    # ------------------------------------------------------------------
    # Classification
    # ------------------------------------------------------------------

    def build_failure_signals(self, raw_output: str, harness_text: str, failed_properties: List[JsonDict]) -> List[FailureSignal]:
        lower = (raw_output or "").lower()
        harness_lower = (harness_text or "").lower()
        status = normalize_status(safe_get(self.cbmc_status, "status", default=""))
        result = normalize_status(safe_get(self.cbmc_status, "result", default=""))
        execution_status = normalize_status(safe_get(self.cbmc_status, "execution_status", default=""))
        gate_status = normalize_status(safe_get(self.critic_gate_decision, "decision", default=""))
        detected_errors = [str(x) for x in as_list(safe_get(self.cbmc_status, "detected_errors", default=[]))]
        critic_issues = self.read_critic_issues()
        signals: List[FailureSignal] = []

        def add(
            signal_type: str,
            severity: str,
            confidence: float,
            evidence: List[str],
            explanation: str,
            likely_source: str,
            recommended_action: str,
        ) -> None:
            signals.append(FailureSignal(signal_type, severity, confidence, unique_preserve_order(evidence), explanation, likely_source, recommended_action))

        if status == "passed" or result == "passed" or self.cbmc_status.get("verification_passed") is True:
            add(
                "no_counterexample_to_analyze",
                "info",
                0.98,
                ["06_cbmc_status.json reports verification_passed=true/status=passed."],
                "The formal tool reported success for the selected harness/properties, so no counterexample analysis is needed for this iteration.",
                "no_failure_detected",
                "Proceed to evaluation/reporting, but keep the selected-harness-only guardrail.",
            )
            return signals

        if status == "critic_blocked" or execution_status == "critic_blocked" or gate_status == "blocked":
            add(
                "critic_blocked_tool_execution",
                "high",
                0.96,
                [flatten_text(self.critic_gate_decision)[:1000] or "Critic gate blocked formal tool execution."],
                "Agent 7 did not run CBMC because the critic gate decided the generated artifact should be repaired or reviewed first.",
                "critic_gate_or_harness_quality",
                "Send the artifact to Agent 9 Repair or human review before running CBMC again.",
            )

        if status == "tool_unavailable" or execution_status == "tool_unavailable" or "cbmc binary not found" in lower:
            add(
                "tool_unavailable",
                "high",
                0.98,
                detected_errors or ["CBMC binary was not found or command was not executed."],
                "The verification attempt did not run because the formal tool is missing or not visible in PATH.",
                "environment_or_tool_configuration",
                "Install/configure CBMC or set cbmc_binary, then rerun Agent 7.",
            )

        if status == "artifact_missing" or "artifact file not found" in lower:
            add(
                "artifact_missing",
                "critical",
                0.98,
                detected_errors or ["Harness/artifact file not found."],
                "The selected harness file is missing, so CBMC could not check anything.",
                "pipeline_file_contract",
                "Regenerate Agent 5 artifact or check current_artifact in run_config.resolved.json.",
            )

        if status == "timeout" or "[timeout]" in lower or "timed out" in lower:
            add(
                "tool_timeout",
                "high",
                0.90,
                ["CBMC execution timed out."],
                "The tool did not finish within the configured time. The harness may be too broad, unwind bound may be too high, or the command may need simplification.",
                "tool_configuration_or_state_space",
                "Reduce experiment scope, check unwind, and rerun with a focused property.",
            )

        if detected_errors or any(s in lower for s in ["parse error", "syntax error", "conversion error", "failed to open", "file not found", "compilation failed"]):
            add(
                "tool_configuration_or_compilation_problem",
                "high",
                0.88,
                detected_errors[:10] or ["CBMC output contains parsing/conversion/file errors."],
                "CBMC appears to have failed before a clean verification result. This usually means missing include paths, missing source files, generated C syntax problems, or unsupported constructs.",
                "tool_command_or_c_compatibility",
                "Fix include paths/source list/generated C syntax first; do not change the property yet.",
            )

        if failed_properties:
            prop_types = sorted({str(p.get("property_type") or "unknown") for p in failed_properties})
            add(
                "formal_property_failure",
                "medium",
                0.85,
                [str(p.get("raw_line") or p.get("description")) for p in failed_properties[:10]],
                f"CBMC reported one or more failed properties. Failed property categories detected: {', '.join(prop_types)}.",
                "selected_property_failed_under_current_assumptions",
                "Map each failed property to the harness assertion/assumption and repair only with evidence.",
            )

        if "overflow" in lower or any("overflow" in str(p.get("property_type") or "") for p in failed_properties):
            evidence = [str(p.get("raw_line") or p.get("description")) for p in failed_properties if "overflow" in str(p.get("property_type") or "")]
            if not evidence:
                evidence = [h["text"] for h in line_numbered_matches(raw_output, [r"overflow"], max_hits=10)]
            add(
                "integer_overflow_risk",
                "high",
                0.87,
                evidence or ["CBMC output mentions overflow."],
                "The failed check is related to arithmetic overflow. In ML-KEM polynomial code this often means the harness allowed input ranges that are too broad, or the assertion performs arithmetic in a type-sensitive way.",
                "harness_assumption_or_integer_semantics_or_code_review",
                "Separate overflow-safety properties from functional-equality properties; add only spec/code-justified range assumptions.",
            )

        if any(word in lower for word in ["array bounds", "out of bounds", "bounds check", "object bounds", "buffer"]):
            add(
                "memory_bounds_failure",
                "high",
                0.84,
                [h["text"] for h in line_numbered_matches(raw_output, [r"bounds", r"out of bounds", r"array", r"object bounds"], max_hits=10)],
                "CBMC reported an array/bounds-related failure. This may be a real bounds issue, a bad loop/unwind setup, or a harness object-size problem.",
                "harness_object_size_or_loop_bound_or_code_review",
                "Check object setup, array sizes, loop bounds, and unwind value before calling it an implementation bug.",
            )

        if any(word in lower for word in ["pointer", "dereference failure", "invalid pointer", "null pointer"]):
            add(
                "pointer_validity_failure",
                "high",
                0.84,
                [h["text"] for h in line_numbered_matches(raw_output, [r"pointer", r"dereference", r"null"], max_hits=10)],
                "CBMC reported a pointer/dereference-related failure. For generated harnesses this often means local objects or pointer assumptions were not set up correctly.",
                "harness_pointer_setup_or_code_review",
                "Use concrete local objects and valid addresses; avoid nondeterministic raw pointers unless justified.",
            )

        if "unwinding assertion" in lower or "unwind" in lower:
            add(
                "unwinding_configuration_problem",
                "medium",
                0.78,
                [h["text"] for h in line_numbered_matches(raw_output, [r"unwind", r"unwinding"], max_hits=10)],
                "The failure may involve loop unwinding. The unwind bound may be too low/high or the loop bound macro may not match the implementation loop.",
                "tool_configuration_or_loop_bound",
                "Set unwind according to Agent 3 loop-bound evidence and keep --unwinding-assertions enabled.",
            )

        risky_asserts = line_numbered_matches(harness_text, [r"assert\s*\([^;]*[+\-*][^;]*\)", r"__CPROVER_assert\s*\([^;]*[+\-*][^;]*,"], max_hits=10)
        if risky_asserts and ("overflow" in lower or any("overflow" in flatten_text(i).lower() for i in critic_issues)):
            add(
                "assertion_may_be_too_strong_or_type_sensitive",
                "medium",
                0.80,
                [f"harness line {x['line']}: {x['text']}" for x in risky_asserts[:10]],
                "The harness assertion itself performs arithmetic. CBMC may be failing due to the assertion expression or missing input preconditions, not necessarily because the implementation is wrong.",
                "harness_assertion_design",
                "Split assertion checks and use wider comparison expressions only when semantically justified.",
            )

        has_nondet = bool(re.search(r"nondet_|__CPROVER_nondet", harness_text))
        has_assume = bool(re.search(r"__CPROVER_assume\s*\(", harness_text))
        if has_nondet and not has_assume and any(x in lower for x in ["overflow", "assertion", "verification failed", "failure"]):
            add(
                "assumptions_too_weak_or_missing",
                "medium",
                0.76,
                ["Harness uses nondeterministic inputs but no __CPROVER_assume preconditions were found."],
                "The generated harness may allow values outside the selected function's intended preconditions.",
                "harness_assumption_design",
                "Add only justified assumptions from spec/code evidence; avoid over-constraining to force success.",
            )

        for issue in critic_issues[:30]:
            sev = str(issue.get("severity") or issue.get("level") or "unknown").lower()
            typ = str(issue.get("type") or issue.get("category") or "critic_issue")
            msg = str(issue.get("message") or issue.get("description") or issue)
            if sev in {"critical", "high", "medium"}:
                add(
                    f"critic_prior_warning_{typ}",
                    sev,
                    0.70,
                    [msg[:1000]],
                    "The Critic Agent already identified this issue before tool execution, so it is relevant to the failure analysis.",
                    "critic_detected_artifact_quality_issue",
                    "Repair the critic issue before relying on any tool result.",
                )

        if isinstance(self.symbol_uncertainty_review, dict) and self.symbol_uncertainty_review:
            if "uncertain" in flatten_text(self.symbol_uncertainty_review).lower() or "misuse" in flatten_text(self.symbol_uncertainty_review).lower():
                add(
                    "symbol_or_parameter_uncertainty",
                    "medium",
                    0.62,
                    [flatten_text(self.symbol_uncertainty_review)[:1000]],
                    "The critic/spec-grounding review recorded symbol or parameter uncertainty that may affect the harness assumptions/assertions.",
                    "spec_grounding_uncertainty",
                    "Review symbols, constants, and parameter values before repairing assumptions.",
                )

        if not signals:
            add(
                "unknown_or_unclassified_failure",
                "medium",
                0.40,
                [clip(raw_output, 1000) or "No CBMC output was available."],
                "The agent could not classify the failure confidently.",
                "unknown_requires_human_review",
                "Inspect raw CBMC output, command manifest, generated harness, and critic review manually.",
            )

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
            "critic_blocked_tool_execution": 97,
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
            "symbol_or_parameter_uncertainty": 64,
            "formal_property_failure": 60,
            "unknown_or_unclassified_failure": 10,
        }
        if not signals:
            return "unknown_or_unclassified_failure", "Could not classify the failure.", 0.0
        best = max(signals, key=lambda s: (priority.get(s.signal_type, 50), SEVERITY_RANK.get(s.severity, 0), s.confidence))
        return best.signal_type, best.explanation, best.confidence

    def infer_failure_source(self, primary_type: str) -> str:
        if primary_type in {"tool_unavailable", "tool_timeout", "tool_configuration_or_compilation_problem"}:
            return "environment_or_tool_configuration"
        if primary_type == "artifact_missing":
            return "pipeline_file_contract"
        if primary_type == "critic_blocked_tool_execution":
            return "critic_gate_or_harness_quality"
        if primary_type in {"assumptions_too_weak_or_missing", "assertion_may_be_too_strong_or_type_sensitive", "unwinding_configuration_problem"}:
            return "harness_or_property_issue"
        if primary_type in {"integer_overflow_risk", "memory_bounds_failure", "pointer_validity_failure"}:
            return "requires_harness_and_code_review"
        if primary_type == "symbol_or_parameter_uncertainty":
            return "spec_grounding_uncertainty"
        if primary_type == "formal_property_failure":
            return "selected_property_failed_under_current_assumptions"
        if primary_type == "no_counterexample_to_analyze":
            return "no_failure_detected"
        return "unknown_requires_human_review"

    # ------------------------------------------------------------------
    # v2 diagnosis and repair guidance
    # ------------------------------------------------------------------

    def build_trace_summary(self, raw_output: str, trace_assignments: List[JsonDict], failed_properties: List[JsonDict]) -> JsonDict:
        return {
            "schema_version": "1.0",
            "agent": AGENT_NAME,
            "created_at": utc_now(),
            "source_files": {
                "cbmc_status": str(self.cbmc_status_path),
                "cbmc_output": str(self.cbmc_output_path),
                "agent7_trace_summary_present": bool(self.agent7_trace_summary),
            },
            "agent7_v2_trace_summary": self.agent7_trace_summary if isinstance(self.agent7_trace_summary, dict) else {},
            "failed_property_count": len(failed_properties),
            "failed_properties": failed_properties,
            "assignment_sample_count": len(trace_assignments),
            "trace_assignments_sample": trace_assignments[:80],
            "raw_output_hash_sha256": sha256_text(raw_output or ""),
            "raw_output_line_count": len((raw_output or "").splitlines()),
            "counterexample_available": bool(
                safe_get(self.cbmc_status, "counterexample_available", default=False)
                or failed_properties
                or "counterexample" in (raw_output or "").lower()
            ),
            "interpretation_limit": "Trace extraction is heuristic. Human review should inspect 06_cbmc_output.txt before treating values as semantic facts.",
        }

    def build_failed_property_mapping(self, failed_properties: List[JsonDict], harness_evidence: JsonDict) -> JsonDict:
        mappings: List[JsonDict] = []
        assertions = harness_evidence.get("assertions") or []
        assumptions = harness_evidence.get("assumptions") or []
        candidates = self.candidate_properties()

        for fp in failed_properties:
            desc = str(fp.get("description") or fp.get("raw_line") or "")
            fp_type = str(fp.get("property_type") or "unknown")
            candidate = self.map_failed_property_to_candidate(fp)
            assertion_match = self.choose_harness_line_for_failure(desc, assertions)
            assumption_matches = self.related_assumptions_for_failure(fp_type, assumptions)
            mappings.append({
                "cbmc_property_id": fp.get("property_id"),
                "cbmc_property_type": fp_type,
                "cbmc_description": desc,
                "cbmc_source": fp.get("source"),
                "candidate_property_id": safe_get(candidate, "id") or safe_get(candidate, "property_id") if candidate else fp.get("mapped_candidate_property_id"),
                "candidate_property_type": safe_get(candidate, "type") if candidate else fp.get("mapped_candidate_property_type"),
                "candidate_property_description": safe_get(candidate, "description") or safe_get(candidate, "text") if candidate else None,
                "candidate_mapping_confidence": safe_get(candidate, "mapping_confidence") if candidate else fp.get("mapping_confidence", "none"),
                "harness_assertion_match": assertion_match,
                "related_assumptions": assumption_matches[:10],
                "property_evidence_from_agent4_rows": self.find_property_evidence_rows(candidate),
                "repair_relevance": self.repair_relevance_for_type(fp_type),
            })

        return {
            "schema_version": "1.0",
            "agent": AGENT_NAME,
            "created_at": utc_now(),
            "mapping_count": len(mappings),
            "candidate_properties_available": len(candidates),
            "mappings": mappings,
            "note": "Mappings are evidence-guided heuristics. Human review must confirm exact property-to-assertion alignment.",
        }

    def choose_harness_line_for_failure(self, failure_text: str, assertions: List[JsonDict]) -> Optional[JsonDict]:
        if not assertions:
            return None
        lower = failure_text.lower()
        scored: List[Tuple[int, JsonDict]] = []
        for item in assertions:
            text = str(item.get("text") or "").lower()
            score = 0
            if "assert" in lower:
                score += 1
            for token in ["coeff", "range", "bound", "pointer", "overflow", "==", "!=", "<", ">"]:
                if token in lower and token in text:
                    score += 2
            common = set(re.findall(r"[A-Za-z_][A-Za-z0-9_]+", lower)) & set(re.findall(r"[A-Za-z_][A-Za-z0-9_]+", text))
            score += min(len(common), 5)
            scored.append((score, item))
        scored.sort(key=lambda x: x[0], reverse=True)
        if scored and scored[0][0] > 0:
            return scored[0][1]
        return assertions[0]

    def related_assumptions_for_failure(self, fp_type: str, assumptions: List[JsonDict]) -> List[JsonDict]:
        if not assumptions:
            return []
        keywords: List[str] = []
        if "overflow" in fp_type:
            keywords = ["range", "min", "max", "int", "<=", ">="]
        elif "bounds" in fp_type or "array" in fp_type:
            keywords = ["bound", "size", "len", "n", "<=", "<"]
        elif "pointer" in fp_type:
            keywords = ["null", "valid", "pointer", "!="]
        elif "unwind" in fp_type:
            keywords = ["loop", "n", "bound"]
        out = []
        for item in assumptions:
            text = str(item.get("text") or "").lower()
            if not keywords or any(k in text for k in keywords):
                out.append(item)
        return out

    def find_property_evidence_rows(self, candidate: Optional[Dict[str, Any]]) -> List[Dict[str, str]]:
        if not candidate:
            return []
        cid = str(candidate.get("id") or candidate.get("property_id") or "")
        if not cid:
            return []
        rows = []
        for row in self.property_evidence_matrix_rows:
            if cid in flatten_text(row):
                rows.append(row)
        return rows[:10]

    def repair_relevance_for_type(self, fp_type: str) -> str:
        lower = fp_type.lower()
        if "pointer" in lower:
            return "Repair pointer object setup, initialization, or validity assumptions first."
        if "bounds" in lower or "array" in lower:
            return "Repair object sizes, loop bounds, and unwind configuration first."
        if "overflow" in lower:
            return "Separate overflow-safety from functional assertions and review input range assumptions."
        if "unwind" in lower:
            return "Repair CBMC unwind setting and loop-bound evidence."
        if "assert" in lower:
            return "Review whether assertion is too strong, trivial, or not aligned with selected property."
        return "Review harness/property/tool evidence before repair."

    def build_assumption_assertion_failure_map(self, failed_properties: List[JsonDict], harness_evidence: JsonDict) -> List[Dict[str, Any]]:
        rows: List[Dict[str, Any]] = []
        assumptions = harness_evidence.get("assumptions") or []
        assertions = harness_evidence.get("assertions") or []
        if not failed_properties:
            failed_properties = [{"property_id": None, "property_type": "none_or_unknown", "description": "No failed property extracted"}]
        for fp in failed_properties:
            fp_type = str(fp.get("property_type") or "unknown")
            assertion = self.choose_harness_line_for_failure(str(fp.get("description") or fp.get("raw_line") or ""), assertions)
            related_assumptions = self.related_assumptions_for_failure(fp_type, assumptions)
            if not related_assumptions:
                rows.append({
                    "failed_property_id": fp.get("property_id"),
                    "failed_property_type": fp_type,
                    "failure_description": fp.get("description") or fp.get("raw_line"),
                    "assertion_line": safe_get(assertion or {}, "line"),
                    "assertion_text": safe_get(assertion or {}, "text"),
                    "assumption_line": "",
                    "assumption_text": "",
                    "diagnosis_hint": self.repair_relevance_for_type(fp_type),
                    "human_review_required": True,
                })
            else:
                for assumption in related_assumptions[:10]:
                    rows.append({
                        "failed_property_id": fp.get("property_id"),
                        "failed_property_type": fp_type,
                        "failure_description": fp.get("description") or fp.get("raw_line"),
                        "assertion_line": safe_get(assertion or {}, "line"),
                        "assertion_text": safe_get(assertion or {}, "text"),
                        "assumption_line": safe_get(assumption, "line"),
                        "assumption_text": safe_get(assumption, "text"),
                        "diagnosis_hint": self.repair_relevance_for_type(fp_type),
                        "human_review_required": True,
                    })
        return rows

    def build_tool_vs_harness_vs_code_diagnosis(self, primary_type: str, signals: List[FailureSignal], failed_properties: List[JsonDict], harness_evidence: JsonDict) -> JsonDict:
        buckets = {
            "tool_or_environment": [],
            "harness_or_assumption": [],
            "property_or_assertion": [],
            "possible_code_behavior": [],
            "spec_grounding_or_symbol_uncertainty": [],
            "unknown_or_human_review": [],
        }
        for s in signals:
            src = s.likely_source
            item = dataclasses.asdict(s)
            if src in {"environment_or_tool_configuration", "tool_command_or_c_compatibility", "tool_configuration_or_state_space"}:
                buckets["tool_or_environment"].append(item)
            elif "harness" in src or "assumption" in src or "pointer_setup" in src or "object_size" in src:
                buckets["harness_or_assumption"].append(item)
            elif "property" in src or "assertion" in src:
                buckets["property_or_assertion"].append(item)
            elif "code_review" in src:
                buckets["possible_code_behavior"].append(item)
            elif "spec" in src or "symbol" in src:
                buckets["spec_grounding_or_symbol_uncertainty"].append(item)
            else:
                buckets["unknown_or_human_review"].append(item)

        likely_primary_bucket = "unknown_or_human_review"
        if primary_type in {"tool_unavailable", "tool_timeout", "tool_configuration_or_compilation_problem"}:
            likely_primary_bucket = "tool_or_environment"
        elif primary_type in {"critic_blocked_tool_execution", "assumptions_too_weak_or_missing", "pointer_validity_failure", "memory_bounds_failure"}:
            likely_primary_bucket = "harness_or_assumption"
        elif primary_type in {"assertion_may_be_too_strong_or_type_sensitive", "formal_property_failure", "integer_overflow_risk"}:
            likely_primary_bucket = "property_or_assertion"
        elif primary_type == "symbol_or_parameter_uncertainty":
            likely_primary_bucket = "spec_grounding_or_symbol_uncertainty"
        elif primary_type == "no_counterexample_to_analyze":
            likely_primary_bucket = "no_failure_detected"

        return {
            "schema_version": "1.0",
            "agent": AGENT_NAME,
            "created_at": utc_now(),
            "primary_classification": primary_type,
            "likely_primary_bucket": likely_primary_bucket,
            "bucket_counts": {k: len(v) for k, v in buckets.items()},
            "buckets": buckets,
            "harness_metrics": {
                "assumption_count": len(harness_evidence.get("assumptions") or []),
                "assertion_count": len(harness_evidence.get("assertions") or []),
                "nondet_input_count": len(harness_evidence.get("nondet_inputs") or []),
                "target_call_count": len(harness_evidence.get("target_calls") or []),
                "loop_line_count": len(harness_evidence.get("loop_lines") or []),
            },
            "failed_property_count": len(failed_properties),
            "conservative_interpretation": "Do not classify this as a code bug without confirming harness setup, assumptions, assertions, tool command, and spec grounding.",
        }

    def build_repair_guidance(self, primary_type: str, failed_properties: List[JsonDict], harness_evidence: JsonDict, output_evidence: JsonDict, signals: List[FailureSignal]) -> JsonDict:
        target = str(self.config.get("target_function", "target_function"))
        guidance: List[JsonDict] = []

        def rec(action: str, priority: str, reason: str, concrete_steps: List[str], safe: bool = True, evidence: Optional[List[str]] = None) -> None:
            guidance.append({
                "action": action,
                "priority": priority,
                "reason": reason,
                "concrete_steps": concrete_steps,
                "safe_for_automatic_repair": safe,
                "evidence": evidence or [],
                "human_review_required": True,
            })

        if primary_type == "critic_blocked_tool_execution":
            rec(
                "respect_critic_gate_before_tool_execution",
                "high",
                "Agent 7 was blocked by the critic gate, so the immediate repair target is the critic issue, not a CBMC counterexample.",
                [
                    "Read 05_critic_review.json and 06_critic_gate_decision.json.",
                    "Repair or justify every high/critical critic issue before running CBMC.",
                    "Do not use --force unless the human researcher explicitly wants to collect a tool result despite critic warnings.",
                ],
                safe=True,
                evidence=[flatten_text(self.critic_gate_decision)[:1000]],
            )
        elif primary_type == "tool_unavailable":
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
                    "Ensure the orchestrator promotes 08_repaired_harness.c only after it exists.",
                ],
                safe=True,
            )
        elif primary_type == "tool_configuration_or_compilation_problem":
            rec(
                "fix_tool_command_and_includes",
                "high",
                "CBMC failed before clean verification, likely due to source/header/config problems.",
                [
                    "Check 06_cbmc_command.txt and 06_tool_command_manifest.json.",
                    "Ensure all source files and include directories exist.",
                    "If generated C has syntax errors, repair only syntax/headers first; do not change the property yet.",
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
                    "Reduce the first experiment to one property category, such as memory/bounds before functional equality.",
                    "Use the implementation loop bound extracted by Agent 3.",
                    "Avoid unnecessary helper calls or large nondeterministic object graphs in the first harness.",
                ],
                safe=True,
            )

        # Add property-specific repairs regardless of primary type, because one run may contain multiple issues.
        if any(str(p.get("property_type")) == "integer_overflow" for p in failed_properties) or output_evidence.get("overflow_lines"):
            rec(
                "separate_overflow_from_functional_assertion",
                "high",
                "Overflow-related failures often come from too-broad nondeterministic inputs or arithmetic inside the assertion.",
                [
                    "Do not silently narrow input bounds unless spec/code summary justifies them.",
                    "Move expected arithmetic into wider temporary types only when this matches the semantics being tested.",
                    "Create one harness for overflow safety and another harness for functional equality under documented preconditions.",
                    "Record every range assumption with evidence from 01_spec_summary.json, 02_code_summary.json, or human notes.",
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
                    "Ensure local objects allocated in the harness have the same struct type expected by the target function.",
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
                    "Avoid nondeterministic raw pointers for first harnesses unless pointer-validity assumptions are explicitly added.",
                    "Initialize input object fields before calling the target function.",
                ],
                safe=True,
            )
        if output_evidence.get("unwind_lines"):
            rec(
                "adjust_unwind_configuration",
                "medium",
                "Loop unwinding may be insufficient or mismatched with implementation loop bounds.",
                [
                    "Set tool_execution_settings.unwind to the extracted implementation loop bound.",
                    "Keep --unwinding-assertions enabled so incomplete unwinding is not hidden.",
                ],
                safe=True,
            )
        if primary_type in {"assumptions_too_weak_or_missing", "assertion_may_be_too_strong_or_type_sensitive", "formal_property_failure", "integer_overflow_risk", "memory_bounds_failure", "pointer_validity_failure", "symbol_or_parameter_uncertainty"}:
            rec(
                "repair_harness_assumptions_and_assertions",
                "medium",
                "The selected property failed or was blocked under the current candidate assumptions/assertions.",
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
                    "Compare failed property with 03_candidate_properties.json and 04_spec_grounded_assertion_plan.json.",
                    "Ask whether the failure is due to harness design, assumptions, tool command, or possible code behavior.",
                ],
                safe=False,
            )

        repair_required = primary_type != "no_counterexample_to_analyze"
        return {
            "schema_version": "1.0",
            "agent": AGENT_NAME,
            "created_at": utc_now(),
            "primary_classification": primary_type,
            "repair_required": repair_required,
            "preferred_next_agent": "repair_agent" if repair_required else "evaluation_reporter",
            "guidance": guidance,
            "guardrails_for_repair_agent": [
                "Do not remove a failing assertion only to force CBMC success.",
                "Do not add assumptions unless justified by specification summary, code summary, traceability files, or human notes.",
                "Do not claim a repaired harness proves full ML-KEM correctness.",
                "Keep original failure evidence and repaired artifact both logged.",
                "If critic gate blocked execution, fix critic issues before treating this as a CBMC counterexample.",
            ],
            "signals_used": [dataclasses.asdict(s) for s in signals],
        }

    def build_repair_action_plan(self, repair_guidance: JsonDict, failed_property_mapping: JsonDict, diagnosis: JsonDict) -> JsonDict:
        actions = []
        for idx, item in enumerate(as_list(repair_guidance.get("guidance")), start=1):
            if not isinstance(item, dict):
                continue
            actions.append({
                "step_id": f"A8_REPAIR_{idx:02d}",
                "action": item.get("action"),
                "priority": item.get("priority"),
                "safe_for_automatic_repair": item.get("safe_for_automatic_repair"),
                "human_review_required": True,
                "reason": item.get("reason"),
                "concrete_steps": item.get("concrete_steps"),
                "expected_agent9_use": self.agent9_hint_for_action(str(item.get("action") or "")),
            })
        return {
            "schema_version": "1.0",
            "agent": AGENT_NAME,
            "created_at": utc_now(),
            "preferred_next_agent": repair_guidance.get("preferred_next_agent"),
            "repair_required": repair_guidance.get("repair_required"),
            "primary_diagnosis_bucket": diagnosis.get("likely_primary_bucket"),
            "failed_property_mapping_file": "07_failed_property_mapping.json",
            "actions": actions,
            "agent9_input_contract": {
                "must_read": [
                    "07_counterexample_analysis.json",
                    "07_repair_guidance.json",
                    "07_repair_action_plan.json",
                    "07_failed_property_mapping.json",
                    "07_tool_vs_harness_vs_code_diagnosis.json",
                ],
                "must_preserve_guardrails": True,
            },
        }

    @staticmethod
    def agent9_hint_for_action(action: str) -> str:
        if "tool" in action or "include" in action or "command" in action:
            return "Repair Agent should patch command/include/source compatibility only; avoid changing the property."
        if "pointer" in action:
            return "Repair Agent should create concrete objects and valid addresses rather than raw nondet pointers."
        if "overflow" in action or "assumption" in action:
            return "Repair Agent should add only evidence-backed range assumptions and keep them marked as candidate preconditions."
        if "unwind" in action or "loop" in action:
            return "Repair Agent should update manifest/config recommendation for CBMC unwind while keeping unwinding assertions enabled."
        if "critic" in action:
            return "Repair Agent should fix critic-reported blocking issues before CBMC rerun."
        return "Repair Agent should perform conservative patching and record human-review needs."

    def build_agent7v2_integration_report(self) -> JsonDict:
        expected = [
            "06_tool_command_manifest.json",
            "06_tool_environment_snapshot.json",
            "06_critic_gate_decision.json",
            "06_cbmc_diagnostics.json",
            "06_cbmc_trace_summary.json",
            "06_failed_property_mapping.json",
            "06_tool_execution_traceability.json",
        ]
        present = [name for name in expected if (self.run_dir / name).exists()]
        return {
            "schema_version": "1.0",
            "agent": AGENT_NAME,
            "created_at": utc_now(),
            "agent7_v2_files_expected": expected,
            "agent7_v2_files_present": present,
            "agent7_v2_coverage": {
                "present": len(present),
                "total": len(expected),
                "complete": len(present) == len(expected),
            },
            "used_tool_command_manifest": bool(self.tool_command_manifest),
            "used_tool_environment_snapshot": bool(self.tool_environment_snapshot),
            "used_critic_gate_decision": bool(self.critic_gate_decision),
            "used_cbmc_diagnostics": bool(self.cbmc_diagnostics),
            "used_agent7_trace_summary": bool(self.agent7_trace_summary),
            "used_agent7_failed_property_mapping": bool(self.agent7_failed_mapping),
            "used_tool_execution_traceability": bool(self.tool_execution_traceability),
            "note": "Missing Agent 7 v2 files are tolerated for legacy runs, but richer diagnosis is available when they exist.",
        }

    # ------------------------------------------------------------------
    # Prompt/report rendering
    # ------------------------------------------------------------------

    def build_prompt_record(self, artifact_path: Path, harness_text: str) -> str:
        target = self.config.get("target_function", "unknown")
        status_summary = {k: self.cbmc_status.get(k) for k in ["status", "verification_passed", "counterexample_available", "failed_property", "summary", "execution_status"]}
        return textwrap.dedent(f"""
        Agent 8 Counterexample Analysis v2 Task Record
        ==============================================

        Target function: {target}
        Iteration: {self.iteration}
        Artifact: {artifact_path}
        Agent version: {AGENT_VERSION}

        Task:
        1. Read CBMC status, command, diagnostics, raw output, and property results.
        2. Classify whether the issue is tool/environment, critic-gate, harness setup,
           assumption weakness, assertion weakness, property failure, spec-grounding
           uncertainty, or possible code behavior.
        3. Use only recorded evidence from Agent 1-7 outputs.
        4. Produce repair-safe guidance for Agent 9.
        5. Do not claim full ML-KEM verification or full ML-KEM failure.

        Scientific guardrail:
        {SCIENTIFIC_GUARDRAIL}

        CBMC status summary:
        {json.dumps(status_summary, indent=2, ensure_ascii=False)}

        Critic gate summary:
        {json.dumps(self.critic_gate_decision if isinstance(self.critic_gate_decision, dict) else {}, indent=2, ensure_ascii=False)[:2500]}

        Harness excerpt:
        ```c
        {clip(harness_text, 3000)}
        ```

        Raw CBMC output excerpt:
        ```text
        {clip(self.raw_output, 3500)}
        ```
        """).strip() + "\n"

    def render_markdown(self, analysis: JsonDict) -> str:
        lines: List[str] = [
            "# Agent 8 — Counterexample Analysis Report v2",
            "",
            f"- **Created at:** {analysis.get('created_at')}",
            f"- **Target function:** `{analysis.get('target_function')}`",
            f"- **Iteration:** `{analysis.get('iteration')}`",
            f"- **Tool status:** `{safe_get(analysis, 'tool_result', 'status')}`",
            f"- **Primary classification:** `{analysis.get('primary_classification')}`",
            f"- **Failure source:** `{analysis.get('failure_source')}`",
            f"- **Confidence:** `{analysis.get('classification_confidence')}`",
            "",
            "## Scientific Guardrail",
            "",
            SCIENTIFIC_GUARDRAIL,
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
            for p in failed[:30]:
                lines.append(f"- `{p.get('property_id')}` — **{p.get('property_type')}** — {p.get('description')} — mapped candidate: `{p.get('mapped_candidate_property_id')}`")
        else:
            lines.append("- No failed property lines were extracted.")
        lines.append("")

        signals = analysis.get("failure_signals") or []
        lines.extend(["## Failure Signals", ""])
        for s in signals[:30]:
            lines.append(f"- **{s.get('signal_type')}** ({s.get('severity')}, confidence {s.get('confidence')}): {s.get('explanation')}")
        if not signals:
            lines.append("- No signals extracted.")
        lines.append("")

        diagnosis = analysis.get("tool_vs_harness_vs_code_diagnosis") or {}
        if diagnosis:
            lines.extend(["## Tool vs Harness vs Code Diagnosis", ""])
            lines.append(f"- Likely primary bucket: `{diagnosis.get('likely_primary_bucket')}`")
            lines.append(f"- Bucket counts: `{diagnosis.get('bucket_counts')}`")
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

        lines.extend([
            "## New v2 Output Files",
            "",
            "- `07_failure_classification_matrix.csv`",
            "- `07_cbmc_trace_summary.json`",
            "- `07_repair_guidance.json`",
            "- `07_failed_property_mapping.json`",
            "- `07_tool_vs_harness_vs_code_diagnosis.json`",
            "- `07_assumption_assertion_failure_map.csv`",
            "- `07_repair_action_plan.json`",
            "- `07_agent7v2_integration_report.json`",
            "",
        ])
        return "\n".join(lines).rstrip() + "\n"

    # ------------------------------------------------------------------
    # Main execution
    # ------------------------------------------------------------------

    def analyze(self) -> JsonDict:
        self.run_dir.mkdir(parents=True, exist_ok=True)
        (self.run_dir / "llm_prompts").mkdir(parents=True, exist_ok=True)
        (self.run_dir / "agent_status").mkdir(parents=True, exist_ok=True)
        self.log_event("agent_start", {"iteration": self.iteration}, status="started")

        artifact_path = self.resolve_artifact_path()
        harness_text = read_text(artifact_path, default="")
        failed_properties = self.parse_failed_properties(self.raw_output)
        output_evidence = self.extract_relevant_output_evidence(self.raw_output)
        harness_evidence = self.extract_harness_evidence(harness_text)
        trace_assignments = self.extract_trace_assignments(self.raw_output)
        signals = self.build_failure_signals(self.raw_output, harness_text, failed_properties)
        primary_type, explanation, confidence = self.choose_primary_classification(signals)
        failure_source = self.infer_failure_source(primary_type)

        trace_summary = self.build_trace_summary(self.raw_output, trace_assignments, failed_properties)
        failed_property_mapping = self.build_failed_property_mapping(failed_properties, harness_evidence)
        assumption_assertion_rows = self.build_assumption_assertion_failure_map(failed_properties, harness_evidence)
        diagnosis = self.build_tool_vs_harness_vs_code_diagnosis(primary_type, signals, failed_properties, harness_evidence)
        repair_guidance = self.build_repair_guidance(primary_type, failed_properties, harness_evidence, output_evidence, signals)
        repair_action_plan = self.build_repair_action_plan(repair_guidance, failed_property_mapping, diagnosis)
        agent7_report = self.build_agent7v2_integration_report()

        status = normalize_status(self.cbmc_status.get("status", "missing_status"))
        tool_result = {
            "status": status,
            "execution_status": self.cbmc_status.get("execution_status"),
            "verification_passed": self.cbmc_status.get("verification_passed"),
            "counterexample_available": self.cbmc_status.get("counterexample_available"),
            "failed_property": self.cbmc_status.get("failed_property"),
            "failed_properties_count": self.cbmc_status.get("failed_properties_count"),
            "returncode": self.cbmc_status.get("returncode"),
            "summary": self.cbmc_status.get("summary"),
            "output_file": str(self.cbmc_output_path),
            "status_file": str(self.cbmc_status_path),
        }

        if primary_type == "no_counterexample_to_analyze":
            plain = "CBMC reported success for the selected candidate harness/properties, so this agent did not find a counterexample to explain. The result still only applies under the recorded harness assumptions."
        elif primary_type in {"tool_unavailable", "artifact_missing", "tool_configuration_or_compilation_problem", "tool_timeout", "critic_blocked_tool_execution"}:
            plain = explanation
        else:
            plain = (
                explanation
                + " This does not automatically mean the ML-KEM implementation is wrong. The safer interpretation is that the current candidate harness/property/assumption/tool setup needs review and possibly repair before making any correctness claim."
            )

        analysis: JsonDict = {
            "schema_version": "2.0",
            "agent": AGENT_NAME,
            "agent_version": AGENT_VERSION,
            "agent_number": AGENT_NUMBER,
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
            "trace_assignments_sample": trace_assignments[:80],
            "output_evidence": output_evidence,
            "harness_evidence": harness_evidence,
            "critic_context": {
                "review_status": self.critic_review.get("review_status") or self.critic_review.get("status"),
                "highest_severity": self.critic_review.get("highest_severity") or highest_severity(self.read_critic_issues()),
                "issues": self.read_critic_issues()[:50],
                "critic_gate_decision": self.critic_gate_decision,
            },
            "property_context": {
                "candidate_properties_file": str(self.run_dir / "03_candidate_properties.json"),
                "candidate_properties_count": len(self.candidate_properties()),
                "selected_properties": self.properties.get("selected_properties") or self.properties.get("cbmc_property_plan") or [],
                "agent4_property_evidence_rows_available": len(self.property_evidence_matrix_rows),
            },
            "failure_signals": [dataclasses.asdict(s) for s in signals],
            "tool_vs_harness_vs_code_diagnosis": diagnosis,
            "failed_property_mapping": failed_property_mapping,
            "repair_guidance": repair_guidance,
            "repair_action_plan": repair_action_plan,
            "agent7v2_integration_report": agent7_report,
            "next_required_agent": repair_guidance.get("preferred_next_agent"),
            "human_review_required": True,
            "scientific_guardrails": {
                "candidate_artifact_only": True,
                "formal_tool_checks_selected_harness_only": True,
                "do_not_claim_full_mlkem_failure": True,
                "do_not_claim_full_mlkem_proof": True,
                "cbmc_failure_may_be_harness_or_assumption_problem": True,
                "critic_gate_may_block_tool_before_cbmc": True,
                "human_review_required": True,
            },
            "v2_output_files": {
                "failure_classification_matrix_csv": str(self.failure_matrix_path),
                "trace_summary_json": str(self.trace_summary_path),
                "repair_guidance_json": str(self.repair_guidance_path),
                "failed_property_mapping_json": str(self.failed_property_mapping_path),
                "diagnosis_json": str(self.diagnosis_path),
                "assumption_assertion_failure_map_csv": str(self.assumption_assertion_map_path),
                "repair_action_plan_json": str(self.repair_action_plan_path),
                "agent7v2_integration_report_json": str(self.agent7v2_integration_path),
            },
        }

        prompt_record = self.build_prompt_record(artifact_path, harness_text)
        markdown = self.render_markdown(analysis)

        # Legacy outputs.
        write_text(self.prompt_path, prompt_record)
        write_json(self.analysis_path, analysis)
        write_text(self.md_path, markdown)

        # New v2 outputs.
        write_csv(self.failure_matrix_path, [dataclasses.asdict(s) for s in signals], fieldnames=["signal_type", "severity", "confidence", "likely_source", "explanation", "recommended_action", "evidence"])
        write_json(self.trace_summary_path, trace_summary)
        write_json(self.repair_guidance_path, repair_guidance)
        write_json(self.failed_property_mapping_path, failed_property_mapping)
        write_json(self.diagnosis_path, diagnosis)
        write_csv(self.assumption_assertion_map_path, assumption_assertion_rows)
        write_json(self.repair_action_plan_path, repair_action_plan)
        write_json(self.agent7v2_integration_path, agent7_report)

        status_data = {
            "agent": AGENT_NAME,
            "agent_version": AGENT_VERSION,
            "status": "completed",
            "created_at": utc_now(),
            "iteration": self.iteration,
            "primary_classification": primary_type,
            "failure_source": failure_source,
            "classification_confidence": round(float(confidence), 3),
            "repair_required": repair_guidance.get("repair_required"),
            "next_required_agent": repair_guidance.get("preferred_next_agent"),
            "human_review_required": True,
            "outputs": {
                "analysis_json": str(self.analysis_path),
                "analysis_markdown": str(self.md_path),
                "prompt_record": str(self.prompt_path),
                **analysis["v2_output_files"],
            },
        }
        write_json(self.agent_status_path, status_data)

        self.log_event(
            "agent_finish",
            {
                "iteration": self.iteration,
                "primary_classification": primary_type,
                "failure_source": failure_source,
                "repair_required": repair_guidance.get("repair_required"),
                "analysis_file": str(self.analysis_path),
            },
            status="completed",
        )

        print(f"[OK] Counterexample Analysis Agent v2 wrote: {self.analysis_path}")
        print(f"[OK] Markdown report: {self.md_path}")
        print(f"[OK] Repair guidance: {self.repair_guidance_path}")
        print(f"[CLASSIFICATION] {primary_type}")
        print(f"[NEXT] {repair_guidance.get('preferred_next_agent')}")
        print("[NOTE] Analysis is for the selected candidate artifact only; human review remains required.")
        return analysis


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Agent 8 v2: Counterexample Analysis Agent for AI-assisted formal-verification artifact workflow."
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
