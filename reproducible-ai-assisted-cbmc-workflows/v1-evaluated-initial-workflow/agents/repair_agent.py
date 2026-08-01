#!/usr/bin/env python3
"""
Repair / Refinement Agent v2 (Agent 9)
======================================

Purpose
-------
Agent 9 reads the generated/repaired CBMC harness, critic review, formal-tool
execution result, counterexample analysis, and v2 traceability files. It then
creates a controlled repaired candidate artifact and logs exactly what changed.

This agent is deterministic-first and standard-library only. It does not prove
the implementation correct. It does not hide failures. It produces candidate
repair artifacts that must still be checked by CBMC/formal tools and reviewed
by a human.

Backward-compatible legacy outputs
----------------------------------
08_repaired_harness.c
08_repair_notes.json
08_repair_notes.md
08_repair_patch.diff
llm_prompts/08_repair_prompt.txt
agent_status/08_repair_status.json
repairs/iteration_XX/...

New v2 outputs
--------------
08_repair_decision_log.json
08_repair_traceability.json
08_assumption_changes.csv
08_assertion_changes.csv
08_repair_safety_review.json
08_repair_input_snapshot.json
08_repair_manifest_update.json
08_repair_action_plan_consumed.json

Scientific guardrail
--------------------
A repaired harness is still only a candidate formal-verification artifact.
CBMC/formal tools and human review remain the authority. A repaired harness
must never be reported as full proof of ML-KEM or the full implementation.
"""

from __future__ import annotations

import argparse
import csv
import datetime as _dt
import difflib
import hashlib
import json
import os
import re
import shutil
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

AGENT_NAME = "repair_refinement_agent"
AGENT_VERSION = "2.0.0"
AGENT_NUMBER = 9
DEFAULT_TARGET_FUNCTION = "poly_add"

SCIENTIFIC_GUARDRAIL = (
    "The repaired harness is a candidate formal-verification artifact only. "
    "It must be checked by CBMC/formal tools and reviewed by a human. "
    "It is not a proof of full ML-KEM correctness or full implementation correctness."
)

JsonDict = Dict[str, Any]


# ---------------------------------------------------------------------------
# Small utilities
# ---------------------------------------------------------------------------

def utc_now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).replace(microsecond=0).isoformat()


def load_json(path: Path, default: Any = None) -> Any:
    if not path.exists():
        return default
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except json.JSONDecodeError as exc:
        return {
            "_load_error": f"Invalid JSON in {path}: {exc}",
            "_path": str(path),
        }
    except OSError as exc:
        return {
            "_load_error": f"Could not read {path}: {exc}",
            "_path": str(path),
        }


def save_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    tmp.replace(path)


def read_text(path: Path, default: str = "") -> str:
    if not path.exists():
        return default
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return default


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


def append_jsonl(path: Path, event: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False) + "\n")


def as_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    if isinstance(value, tuple):
        return list(value)
    return [value]


def flatten_text(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, (int, float, bool)):
        return str(value)
    if isinstance(value, dict):
        return "\n".join(f"{k}: {flatten_text(v)}" for k, v in value.items())
    if isinstance(value, (list, tuple, set)):
        return "\n".join(flatten_text(v) for v in value)
    return str(value)


def normalize_name(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]+", "_", value or "").strip("_")


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
    seen: set[str] = set()
    out: List[Any] = []
    for item in items:
        key = json.dumps(item, sort_keys=True, default=str, ensure_ascii=False) if isinstance(item, (dict, list)) else str(item)
        if key not in seen:
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


def write_csv(path: Path, rows: List[Dict[str, Any]], fieldnames: Optional[List[str]] = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if fieldnames is None:
        fieldnames = []
        for row in rows:
            for key in row:
                if key not in fieldnames:
                    fieldnames.append(key)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames or ["empty"])
        writer.writeheader()
        for row in rows:
            writer.writerow({k: stringify_csv(row.get(k, "")) for k in (fieldnames or ["empty"])})


def read_csv_rows(path: Path) -> List[Dict[str, str]]:
    if not path.exists():
        return []
    try:
        with path.open("r", encoding="utf-8", newline="") as f:
            return list(csv.DictReader(f))
    except Exception:
        return []


def stringify_csv(value: Any) -> str:
    if isinstance(value, (dict, list, tuple)):
        return json.dumps(value, ensure_ascii=False)
    if value is None:
        return ""
    return str(value)


def has_any(text: str, needles: Iterable[str]) -> bool:
    lower = text.lower()
    return any(n.lower() in lower for n in needles)


def line_numbered_findings(text: str, patterns: Sequence[str], max_hits: int = 200) -> List[Dict[str, Any]]:
    findings: List[Dict[str, Any]] = []
    compiled = [re.compile(p, flags=re.IGNORECASE) for p in patterns]
    for idx, line in enumerate(text.splitlines(), start=1):
        stripped = line.strip()
        if not stripped:
            continue
        for pat in compiled:
            if pat.search(stripped):
                findings.append({"line": idx, "pattern": pat.pattern, "text": stripped[:600]})
                break
        if len(findings) >= max_hits:
            break
    return findings


def unified_diff(original: str, repaired: str, from_name: str, to_name: str) -> str:
    return "".join(
        difflib.unified_diff(
            original.splitlines(keepends=True),
            repaired.splitlines(keepends=True),
            fromfile=from_name,
            tofile=to_name,
        )
    )


# ---------------------------------------------------------------------------
# Settings and dataclasses
# ---------------------------------------------------------------------------

@dataclass
class RepairSettings:
    allow_cbmc_compatibility_patches: bool = True
    allow_assertion_rewrite: bool = True
    allow_candidate_overflow_preconditions: bool = True
    allow_assumption_commenting: bool = True
    allow_manifest_command_update: bool = True
    allow_guidance_driven_repairs: bool = True
    allow_include_dir_manifest_notes: bool = True
    strict_no_unsupported_assumption_narrowing: bool = False
    write_iteration_snapshot: bool = True
    require_human_review: bool = True
    max_iterations: int = 3
    default_unwind: Optional[int] = None
    dry_run: bool = False

    @classmethod
    def from_config(cls, config: Dict[str, Any], args: argparse.Namespace) -> "RepairSettings":
        raw = config.get("repair_settings", {}) or {}
        if not isinstance(raw, dict):
            raw = {}
        tool_raw = config.get("tool_settings", {}) or {}
        if not isinstance(tool_raw, dict):
            tool_raw = {}
        cbmc_raw = config.get("cbmc_settings", {}) or {}
        if not isinstance(cbmc_raw, dict):
            cbmc_raw = {}
        max_iter = raw.get("max_iterations", config.get("max_iterations", 3))
        return cls(
            allow_cbmc_compatibility_patches=bool(raw.get("allow_cbmc_compatibility_patches", True)),
            allow_assertion_rewrite=bool(raw.get("allow_assertion_rewrite", True)),
            allow_candidate_overflow_preconditions=bool(raw.get("allow_candidate_overflow_preconditions", True)),
            allow_assumption_commenting=bool(raw.get("allow_assumption_commenting", True)),
            allow_manifest_command_update=bool(raw.get("allow_manifest_command_update", True)),
            allow_guidance_driven_repairs=bool(raw.get("allow_guidance_driven_repairs", True)),
            allow_include_dir_manifest_notes=bool(raw.get("allow_include_dir_manifest_notes", True)),
            strict_no_unsupported_assumption_narrowing=bool(raw.get("strict_no_unsupported_assumption_narrowing", False)),
            write_iteration_snapshot=bool(raw.get("write_iteration_snapshot", True)),
            require_human_review=bool(raw.get("require_human_review", True)),
            max_iterations=int(max_iter if max_iter is not None else 3),
            default_unwind=tool_raw.get("unwind", cbmc_raw.get("unwind", raw.get("default_unwind"))),
            dry_run=bool(getattr(args, "dry_run", False)),
        )


@dataclass
class RepairAction:
    action_id: str
    category: str
    description: str
    applied: bool
    confidence: str
    reason: str
    evidence: List[Dict[str, Any]] = field(default_factory=list)
    human_review_note: Optional[str] = None
    source_stage: Optional[str] = None
    safety_level: str = "candidate_safe"


@dataclass
class RepairResult:
    source_artifact: str
    repaired_artifact: str
    status: str
    tool_execution_recommended: bool
    human_review_required: bool
    actions: List[RepairAction]
    warnings: List[str]
    limitations: List[str]
    next_step: str


@dataclass
class RepairContext:
    config_path: Path
    config: Dict[str, Any]
    resolved_config_path: Optional[Path]
    run_dir: Path
    project_root: Path
    iteration: int
    target_function: str
    source_artifact_path: Path
    repaired_artifact_path: Path
    spec_summary: Dict[str, Any]
    code_summary: Dict[str, Any]
    properties: Dict[str, Any]
    artifact_manifest: Dict[str, Any]
    critic_review: Dict[str, Any]
    cbmc_status: Dict[str, Any]
    cbmc_output: str
    property_results: Any
    counterexample_analysis: Dict[str, Any]
    settings: RepairSettings
    v2_inputs: Dict[str, Any]


# ---------------------------------------------------------------------------
# Context loading
# ---------------------------------------------------------------------------

def determine_project_root(config_path: Path, config: Dict[str, Any]) -> Path:
    explicit = config.get("project_root") or config.get("workspace_root")
    if explicit:
        return Path(str(explicit)).expanduser().resolve()
    if config_path.parent.name == "configs":
        return config_path.parent.parent.resolve()
    return Path.cwd().resolve()


def resolve_project_path(value: Any, project_root: Path, run_dir: Optional[Path] = None) -> Path:
    p = Path(str(value)).expanduser()
    if p.is_absolute():
        return p.resolve()
    if run_dir is not None:
        candidate = (run_dir / p).resolve()
        if candidate.exists():
            return candidate
    return (project_root / p).resolve()


def infer_run_dir(config: Dict[str, Any], project_root: Path, run_dir_arg: Optional[str]) -> Path:
    if run_dir_arg:
        p = Path(run_dir_arg).expanduser()
        if p.is_absolute():
            return p.resolve()
        return (project_root / p).resolve()
    configured = (
        config.get("run_dir")
        or safe_get(config, "output", "run_dir")
        or safe_get(config, "paths", "run_dir")
        or config.get("output_dir")
    )
    if configured:
        p = Path(str(configured)).expanduser()
        if p.is_absolute():
            return p.resolve()
        return (project_root / p).resolve()
    run_id = config.get("run_id") or f"run_001_{normalize_name(config.get('target_function', DEFAULT_TARGET_FUNCTION))}"
    output_root = config.get("output_root", "runs")
    return (project_root / str(output_root) / str(run_id)).resolve()


def merge_resolved_config(config: Dict[str, Any], run_dir: Path) -> Tuple[Dict[str, Any], Optional[Path]]:
    resolved_path = run_dir / "run_config.resolved.json"
    resolved = load_json(resolved_path, default={}) or {}
    if isinstance(resolved, dict) and resolved:
        merged = dict(config)
        merged.update(resolved)
        return merged, resolved_path
    return config, None


def determine_source_artifact(run_dir: Path, project_root: Path, config: Dict[str, Any], args: argparse.Namespace, iteration: int) -> Path:
    candidates: List[Any] = []
    if getattr(args, "source_artifact", None):
        candidates.append(args.source_artifact)
    if getattr(args, "artifact", None):
        candidates.append(args.artifact)
    if config.get("current_artifact"):
        candidates.append(config.get("current_artifact"))
    if iteration > 0:
        candidates.append("08_repaired_harness.c")
    candidates.append("04_generated_harness.c")

    for value in candidates:
        p = Path(str(value)).expanduser()
        if not p.is_absolute():
            in_run = (run_dir / p).resolve()
            in_project = (project_root / p).resolve()
            if in_run.exists():
                return in_run
            if in_project.exists():
                return in_project
            # For explicit args/current_artifact, prefer run dir even if missing.
            if value in [getattr(args, "source_artifact", None), getattr(args, "artifact", None), config.get("current_artifact")]:
                return in_run
        elif p.exists() or value in [getattr(args, "source_artifact", None), getattr(args, "artifact", None), config.get("current_artifact")]:
            return p.resolve()
    return (run_dir / "04_generated_harness.c").resolve()


def load_manifest(run_dir: Path) -> Dict[str, Any]:
    for name in ["04_artifact_manifest.json", "04_generated_artifact_notes.json", "artifact_manifest.json"]:
        p = run_dir / name
        data = load_json(p, default={}) or {}
        if isinstance(data, dict) and data:
            data["_manifest_path"] = str(p)
            return data
    return {}


def load_v2_inputs(run_dir: Path) -> Dict[str, Any]:
    json_files = [
        "04_spec_grounding_report.json",
        "04_spec_grounded_assertion_plan.json",
        "05_critic_review.json",
        "05_spec_grounding_review.json",
        "05_symbol_uncertainty_review.json",
        "06_tool_command_manifest.json",
        "06_tool_environment_snapshot.json",
        "06_critic_gate_decision.json",
        "06_cbmc_diagnostics.json",
        "06_cbmc_trace_summary.json",
        "06_failed_property_mapping.json",
        "06_tool_execution_traceability.json",
        "07_cbmc_trace_summary.json",
        "07_repair_guidance.json",
        "07_failed_property_mapping.json",
        "07_tool_vs_harness_vs_code_diagnosis.json",
        "07_repair_action_plan.json",
        "07_agent7v2_integration_report.json",
    ]
    csv_files = [
        "04_harness_assumption_traceability.csv",
        "05_assumption_evidence_review.csv",
        "05_assertion_algorithm_alignment.csv",
        "06_property_mapping.csv",
        "07_failure_classification_matrix.csv",
        "07_assumption_assertion_failure_map.csv",
    ]
    out: Dict[str, Any] = {"json": {}, "csv": {}, "presence": {}}
    for name in json_files:
        p = run_dir / name
        out["presence"][name] = p.exists()
        out["json"][name] = load_json(p, default={}) or {}
    for name in csv_files:
        p = run_dir / name
        out["presence"][name] = p.exists()
        out["csv"][name] = read_csv_rows(p)
    return out


def load_context(args: argparse.Namespace) -> RepairContext:
    config_path = Path(args.config).expanduser().resolve()
    config = load_json(config_path, default={}) or {}
    if not isinstance(config, dict):
        raise SystemExit(f"Config must be a JSON object: {config_path}")

    project_root = determine_project_root(config_path, config)
    run_dir = infer_run_dir(config, project_root, getattr(args, "run_dir", None))
    config, resolved_path = merge_resolved_config(config, run_dir)
    # Recompute project root if resolved config has it.
    project_root = determine_project_root(config_path, config)
    run_dir = infer_run_dir(config, project_root, getattr(args, "run_dir", None))

    iteration = int(getattr(args, "iteration", 0) or 0)
    target_function = (
        config.get("target_function")
        or config.get("function")
        or safe_get(config, "target", "function")
        or DEFAULT_TARGET_FUNCTION
    )

    settings = RepairSettings.from_config(config, args)
    source_artifact = determine_source_artifact(run_dir, project_root, config, args, iteration).resolve()
    repaired_artifact = (run_dir / "08_repaired_harness.c").resolve()

    return RepairContext(
        config_path=config_path,
        config=config,
        resolved_config_path=resolved_path,
        run_dir=run_dir,
        project_root=project_root,
        iteration=iteration,
        target_function=str(target_function),
        source_artifact_path=source_artifact,
        repaired_artifact_path=repaired_artifact,
        spec_summary=load_json(run_dir / "01_spec_summary.json", default={}) or {},
        code_summary=load_json(run_dir / "02_code_summary.json", default={}) or {},
        properties=load_json(run_dir / "03_candidate_properties.json", default={}) or {},
        artifact_manifest=load_manifest(run_dir),
        critic_review=load_json(run_dir / "05_critic_review.json", default={}) or {},
        cbmc_status=load_json(run_dir / "06_cbmc_status.json", default={}) or {},
        cbmc_output=read_text(run_dir / "06_cbmc_output.txt", default=""),
        property_results=load_json(run_dir / "06_cbmc_property_results.json", default={}) or {},
        counterexample_analysis=load_json(run_dir / "07_counterexample_analysis.json", default={}) or {},
        settings=settings,
        v2_inputs=load_v2_inputs(run_dir),
    )


# ---------------------------------------------------------------------------
# Evidence extraction and planning helpers
# ---------------------------------------------------------------------------

def collect_critic_issues(critic_review: Dict[str, Any]) -> List[Dict[str, Any]]:
    candidate_keys = [
        "issues", "findings", "problems", "review_issues", "critic_issues",
        "blocking_issues", "warnings",
    ]
    issues: List[Dict[str, Any]] = []
    for key in candidate_keys:
        for item in as_list(critic_review.get(key)):
            if isinstance(item, dict):
                issues.append(item)
            elif isinstance(item, str):
                issues.append({"message": item, "type": key})
    for nested_key in ["review", "critic_context"]:
        nested = critic_review.get(nested_key)
        if isinstance(nested, dict):
            issues.extend(collect_critic_issues(nested))
    return unique_preserve_order(issues)


def collect_failure_modes(context: RepairContext) -> List[str]:
    text = "\n".join([
        flatten_text(context.counterexample_analysis),
        flatten_text(context.cbmc_status),
        flatten_text(context.property_results),
        context.cbmc_output,
        flatten_text(context.v2_inputs.get("json", {}).get("07_repair_guidance.json", {})),
        flatten_text(context.v2_inputs.get("json", {}).get("07_tool_vs_harness_vs_code_diagnosis.json", {})),
        flatten_text(context.v2_inputs.get("json", {}).get("07_repair_action_plan.json", {})),
    ]).lower()

    checks = [
        ("critic_blocked", ["critic_blocked", "critic gate", "tool_execution_allowed: false"]),
        ("tool_unavailable", ["tool_unavailable", "cbmc binary not found", "cbmc not installed"]),
        ("tool_error", ["parse error", "syntax error", "compilation", "failed to parse", "typecheck", "undefined reference", "conversion error"]),
        ("timeout", ["timeout", "timed out"]),
        ("pointer_validity", ["pointer", "dereference failure", "invalid pointer", "null pointer"]),
        ("bounds", ["array bounds", "bounds check", "out of bounds", "object bounds", "buffer overflow"]),
        ("signed_overflow", ["signed overflow", "arithmetic overflow"]),
        ("unsigned_overflow", ["unsigned overflow"]),
        ("overflow", ["overflow"]),
        ("unwinding", ["unwinding assertion", "unwind", "loop unwinding"]),
        ("assertion_failure", ["assertion", "assert", "violated property", "verification failed"]),
        ("assumption_issue", ["assumption", "too broad", "too weak", "unsupported assumption", "vacuous", "over-constraining"]),
        ("missing_source_or_include", ["missing source", "missing include", "failed to open", "file not found"]),
    ]
    modes: List[str] = []
    for mode, needles in checks:
        if any(n in text for n in needles):
            modes.append(mode)

    for key in ["failure_type", "primary_failure_type", "classification", "primary_classification"]:
        val = context.counterexample_analysis.get(key)
        if isinstance(val, str) and val and val not in modes:
            modes.insert(0, val)

    for key in ["detected_failure_modes", "failure_modes", "classifications"]:
        for val in as_list(context.counterexample_analysis.get(key)):
            name = val if isinstance(val, str) else (val.get("type") or val.get("name") or val.get("classification") if isinstance(val, dict) else None)
            if name and str(name) not in modes:
                modes.append(str(name))

    plan = context.v2_inputs.get("json", {}).get("07_repair_action_plan.json", {})
    for item in as_list(plan.get("recommended_actions") or plan.get("actions") or plan.get("guidance")):
        if isinstance(item, dict):
            action = item.get("action") or item.get("type") or item.get("category")
            if action and str(action) not in modes:
                modes.append(str(action))

    return unique_preserve_order(modes)


def extract_constants(summary: Dict[str, Any]) -> Dict[str, Any]:
    constants: Dict[str, Any] = {}
    for key in ["constants", "known_constants", "extracted_constants", "parameter_table"]:
        val = summary.get(key)
        if isinstance(val, dict):
            for k, v in val.items():
                if isinstance(v, dict) and "value" in v:
                    constants[str(k)] = v.get("value")
                else:
                    constants[str(k)] = v
        elif isinstance(val, list):
            for item in val:
                if isinstance(item, dict):
                    name = item.get("name") or item.get("constant") or item.get("key") or item.get("symbol") or item.get("parameter")
                    value = item.get("value")
                    if name is not None:
                        constants[str(name)] = value
    return constants


def detect_loop_bound(code: str, context: RepairContext) -> str:
    # Prefer Agent 3 v2 loop-bound table if available.
    loop_json = load_json(context.run_dir / "02_loop_bounds_array_accesses.json", default={}) or {}
    for item in as_list(loop_json.get("loop_bounds") or loop_json.get("loops")):
        if isinstance(item, dict):
            val = item.get("resolved_bound") or item.get("upper_bound") or item.get("bound") or item.get("condition")
            if val:
                m = re.search(r"<\s*([A-Za-z_][A-Za-z0-9_]*|\d+)", str(val))
                return m.group(1) if m else str(val)

    for key in ["loops", "loop_structure", "loop_structures"]:
        for loop in as_list(context.code_summary.get(key)):
            if isinstance(loop, dict):
                for k in ["resolved_bound", "bound", "upper_bound", "condition", "loop_condition"]:
                    val = loop.get(k)
                    if isinstance(val, (str, int)):
                        s = str(val).strip()
                        m = re.search(r"<\s*([A-Za-z_][A-Za-z0-9_]*|\d+)", s)
                        if m:
                            return m.group(1)
                        if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*|\d+", s):
                            return s

    m = re.search(r"for\s*\([^;]*;\s*[A-Za-z_][A-Za-z0-9_]*\s*<\s*([^;\)]+)\s*;", code)
    if m:
        return m.group(1).strip()

    constants = extract_constants(context.spec_summary)
    for key in ["N", "KYBER_N", "MLKEM_N", "MLK_N", "n"]:
        if key in constants:
            value = constants[key]
            return str(value if str(value).isdigit() else key)
    return "256"


def extract_harness_observations(code: str) -> Dict[str, Any]:
    return {
        "line_count": len(code.splitlines()),
        "includes": line_numbered_findings(code, [r"^\s*#\s*include"], max_hits=200),
        "assumptions": line_numbered_findings(code, [r"__CPROVER_assume\s*\(", r"\bassume\s*\("], max_hits=200),
        "assertions": line_numbered_findings(code, [r"\bassert\s*\(", r"__CPROVER_assert\s*\("], max_hits=200),
        "nondet_calls": line_numbered_findings(code, [r"\bnondet_[A-Za-z0-9_]+\s*\(", r"__CPROVER_nondet"], max_hits=200),
        "loops": line_numbered_findings(code, [r"\bfor\s*\(", r"\bwhile\s*\("], max_hits=200),
        "target_calls": [],
    }


def detect_target_call_line(code: str, target_function: str) -> Optional[int]:
    """Return the line index of an actual target-function call inside the harness.

    This intentionally skips prototypes and function definitions such as
    `void poly_add(...);` because inserting repair assumptions before a prototype
    would create invalid C.
    """
    lines = code.splitlines()
    call_re = re.compile(rf"\b{re.escape(target_function)}\s*\(")
    prototype_re = re.compile(
        rf"^\s*(?:[A-Za-z_][A-Za-z0-9_]*|\s|\*|const|volatile|static|extern|inline|unsigned|signed|struct|enum)+\b"
        rf"{re.escape(target_function)}\s*\([^;{{}}]*\)\s*;\s*$"
    )
    definition_re = re.compile(
        rf"^\s*(?:[A-Za-z_][A-Za-z0-9_]*|\s|\*|const|volatile|static|extern|inline|unsigned|signed|struct|enum)+\b"
        rf"{re.escape(target_function)}\s*\("
    )
    harness_def_re = re.compile(r"\b(?:void|int)\s+harness_[A-Za-z0-9_]*\s*\(")
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if not call_re.search(stripped):
            continue
        if stripped.startswith("//") or stripped.startswith("/*"):
            continue
        if prototype_re.match(stripped):
            continue
        if definition_re.match(stripped) and stripped.endswith("{"):
            continue
        if harness_def_re.search(stripped):
            continue
        if ";" in stripped:
            return idx
    return None


def detect_functional_assertion_pattern(code: str) -> Optional[Dict[str, str]]:
    # Common generated pattern:
    # assert(r.coeffs[i] == (a.coeffs[i] + b.coeffs[i]));
    # assert(r->coeffs[i] == a->coeffs[i] + b->coeffs[i]);
    access = r"([A-Za-z_]\w*)\s*(\.|->)\s*([A-Za-z_]\w*)\s*\[\s*i\s*\]"
    pattern = re.compile(
        r"assert\s*\(\s*"
        + access
        + r"\s*==\s*\(?\s*"
        + access
        + r"\s*([+\-])\s*"
        + access
        + r"\s*\)?\s*\)\s*;"
    )
    m = pattern.search(code)
    if not m:
        return None
    return {
        "full": m.group(0),
        "out_obj": m.group(1),
        "out_op": m.group(2),
        "out_field": m.group(3),
        "lhs_obj": m.group(4),
        "lhs_op": m.group(5),
        "lhs_field": m.group(6),
        "operator": m.group(7),
        "rhs_obj": m.group(8),
        "rhs_op": m.group(9),
        "rhs_field": m.group(10),
    }


def c_access(obj: str, op: str, field_name: str) -> str:
    return f"{obj}{op}{field_name}"


# ---------------------------------------------------------------------------
# C patch helpers
# ---------------------------------------------------------------------------

def ensure_include(code: str, include: str) -> Tuple[str, bool]:
    include_line = f"#include {include}"
    if include_line in code:
        return code, False
    lines = code.splitlines()
    insert_at = 0
    for idx, line in enumerate(lines):
        if line.strip().startswith("#include"):
            insert_at = idx + 1
    lines.insert(insert_at, include_line)
    suffix = "\n" if code.endswith("\n") else ""
    return "\n".join(lines) + suffix, True


def ensure_cbmc_nondet_declarations(code: str) -> Tuple[str, bool, List[str]]:
    calls = sorted(set(re.findall(r"\b(nondet_[A-Za-z0-9_]+)\s*\(", code)))
    if not calls:
        return code, False, []

    return_type = {
        "nondet_int": "int",
        "nondet_int8_t": "int8_t",
        "nondet_int16_t": "int16_t",
        "nondet_int32_t": "int32_t",
        "nondet_int64_t": "int64_t",
        "nondet_uint": "unsigned int",
        "nondet_unsigned_int": "unsigned int",
        "nondet_uint8_t": "uint8_t",
        "nondet_uint16_t": "uint16_t",
        "nondet_uint32_t": "uint32_t",
        "nondet_uint64_t": "uint64_t",
        "nondet_size_t": "size_t",
        "nondet_bool": "bool",
    }

    missing: List[str] = []
    declarations: List[str] = []
    for call in calls:
        # Conservative declaration detection.
        decl_re = re.compile(rf"\b[A-Za-z_][\w\s\*]+\s+{re.escape(call)}\s*\(\s*void\s*\)\s*;")
        if decl_re.search(code):
            continue
        rtype = return_type.get(call, "int")
        declarations.append(f"extern {rtype} {call}(void);")
        missing.append(call)

    if not declarations:
        return code, False, []

    marker = "/* [Repair Agent v2] CBMC nondeterministic input declarations. */"
    if marker in code:
        return code, False, []

    block = "\n" + marker + "\n" + "\n".join(declarations) + "\n"

    lines = code.splitlines()
    insert_at = 0
    for idx, line in enumerate(lines):
        if line.strip().startswith("#include"):
            insert_at = idx + 1
    lines.insert(insert_at, block)
    suffix = "\n" if code.endswith("\n") else ""
    return "\n".join(lines) + suffix, True, missing


def add_repair_banner(code: str, context: RepairContext) -> Tuple[str, bool]:
    marker = "[Repair Agent v2] Candidate repaired harness"
    if marker in code or "[Repair Agent] Candidate repaired harness" in code:
        return code, False
    banner = f"""/*
 * [Repair Agent v2] Candidate repaired harness
 * Agent: {AGENT_NAME} v{AGENT_VERSION}
 * Iteration: {context.iteration}
 * Target function: {context.target_function}
 * Generated at: {utc_now_iso()}
 *
 * Research guardrail:
 * This file is a candidate formal-verification artifact. It must still be
 * checked by CBMC/formal tools and reviewed by a human researcher. It is not
 * a proof of the full ML-KEM implementation.
 */
"""
    return banner + code, True


def comment_assumptions(code: str) -> Tuple[str, bool, List[Dict[str, Any]]]:
    if "[Repair Agent v2] Candidate precondition" in code or "[Repair Agent] Candidate precondition" in code:
        return code, False, []
    lines = code.splitlines()
    out: List[str] = []
    changed = False
    changes: List[Dict[str, Any]] = []
    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()
        if "__CPROVER_assume" in stripped:
            prev = out[-1].strip() if out else ""
            if "Candidate precondition" not in prev and not prev.startswith("/*"):
                indent = line[: len(line) - len(line.lstrip())]
                comment = indent + "/* [Repair Agent v2] Candidate precondition: keep only if justified by spec/code review. */"
                out.append(comment)
                changed = True
                changes.append({
                    "line_before": idx,
                    "old": "",
                    "new": comment.strip(),
                    "assumption_line": stripped,
                    "change_type": "assumption_comment_added",
                    "reason": "Make candidate assumption review-visible.",
                })
        out.append(line)
    suffix = "\n" if code.endswith("\n") else ""
    return "\n".join(out) + suffix, changed, changes


def annotate_assertions(code: str) -> Tuple[str, bool, List[Dict[str, Any]]]:
    if "[Repair Agent v2] Candidate assertion" in code:
        return code, False, []
    lines = code.splitlines()
    out: List[str] = []
    changes: List[Dict[str, Any]] = []
    changed = False
    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()
        if re.search(r"\bassert\s*\(", stripped) or "__CPROVER_assert" in stripped:
            prev = out[-1].strip() if out else ""
            if "Candidate assertion" not in prev and not prev.startswith("/*"):
                indent = line[: len(line) - len(line.lstrip())]
                comment = indent + "/* [Repair Agent v2] Candidate assertion: review against selected property and spec evidence. */"
                out.append(comment)
                changes.append({
                    "line_before": idx,
                    "old": "",
                    "new": comment.strip(),
                    "assertion_line": stripped,
                    "change_type": "assertion_comment_added",
                    "reason": "Make candidate assertion review-visible.",
                })
                changed = True
        out.append(line)
    suffix = "\n" if code.endswith("\n") else ""
    return "\n".join(out) + suffix, changed, changes


def rewrite_functional_assertion_casts(code: str) -> Tuple[str, bool, Optional[Dict[str, str]], Dict[str, Any]]:
    pattern_info = detect_functional_assertion_pattern(code)
    metadata: Dict[str, Any] = {}
    if not pattern_info:
        return code, False, None, metadata
    original = pattern_info["full"]
    lhs_access = f"{c_access(pattern_info['lhs_obj'], pattern_info['lhs_op'], pattern_info['lhs_field'])}[i]"
    rhs_access = f"{c_access(pattern_info['rhs_obj'], pattern_info['rhs_op'], pattern_info['rhs_field'])}[i]"
    out_access = f"{c_access(pattern_info['out_obj'], pattern_info['out_op'], pattern_info['out_field'])}[i]"
    op = pattern_info["operator"]
    replacement = (
        "/* [Repair Agent v2] Use int32_t casts in the assertion expression to reduce assertion-side overflow noise. */\n"
        f"    assert((int32_t){out_access} == ((int32_t){lhs_access} {op} (int32_t){rhs_access}));"
    )
    repaired = code.replace(original, replacement, 1)
    metadata = {
        "old": original,
        "new": replacement,
        "lhs_access": lhs_access,
        "rhs_access": rhs_access,
        "out_access": out_access,
        "operator": op,
    }
    return repaired, True, pattern_info, metadata


def insert_overflow_precondition_loop(code: str, context: RepairContext, pattern_info: Dict[str, str]) -> Tuple[str, bool, List[Dict[str, Any]]]:
    marker = "[Repair Agent v2] Candidate overflow precondition"
    if marker in code or "[Repair Agent] Candidate overflow precondition" in code:
        return code, False, []

    call_line = detect_target_call_line(code, context.target_function)
    if call_line is None:
        return code, False, []

    loop_bound = detect_loop_bound(code, context)
    lhs_access = f"{c_access(pattern_info['lhs_obj'], pattern_info['lhs_op'], pattern_info['lhs_field'])}[i]"
    rhs_access = f"{c_access(pattern_info['rhs_obj'], pattern_info['rhs_op'], pattern_info['rhs_field'])}[i]"
    op = pattern_info["operator"]

    block = [
        "  /* [Repair Agent v2] Candidate overflow precondition.",
        "   * Purpose: make the selected functional assertion meaningful for int16_t-style",
        "   * coefficient storage by excluding inputs whose mathematical result cannot fit.",
        "   * This is a candidate assumption and requires human/spec review.",
        "   */",
        f"  for (unsigned int i = 0; i < {loop_bound}; i++) {{",
        f"    int32_t repair_expected_i = (int32_t){lhs_access} {op} (int32_t){rhs_access};",
        "    __CPROVER_assume(repair_expected_i >= INT16_MIN);",
        "    __CPROVER_assume(repair_expected_i <= INT16_MAX);",
        "  }",
        "",
    ]

    lines = code.splitlines()
    lines[call_line:call_line] = block
    suffix = "\n" if code.endswith("\n") else ""
    changes = [
        {
            "line_before": call_line + 1,
            "old": "",
            "new": "\\n".join(block),
            "change_type": "candidate_overflow_precondition_loop_inserted",
            "reason": "Constrain assertion-side representability only as candidate precondition; requires human/spec review.",
            "loop_bound": loop_bound,
        }
    ]
    return "\n".join(lines) + suffix, True, changes


def update_unwind_recommendation(manifest: Dict[str, Any], context: RepairContext) -> Tuple[Dict[str, Any], bool, Dict[str, Any]]:
    if not context.settings.allow_manifest_command_update:
        return manifest, False, {}
    if not isinstance(manifest, dict):
        manifest = {}
    changed = False
    before = dict(manifest)
    recommended = manifest.get("recommended_cbmc_command") or manifest.get("cbmc_command")
    default_unwind = context.settings.default_unwind
    if default_unwind is None:
        constants = extract_constants(context.spec_summary)
        n_val = constants.get("N") or constants.get("KYBER_N") or constants.get("MLKEM_N") or constants.get("MLK_N")
        try:
            default_unwind = int(n_val)
        except Exception:
            default_unwind = None
    if isinstance(recommended, str) and default_unwind:
        if "--unwind" not in recommended:
            manifest["recommended_cbmc_command"] = recommended.strip() + f" --unwind {default_unwind} --unwinding-assertions"
            changed = True
        elif "--unwinding-assertions" not in recommended:
            manifest["recommended_cbmc_command"] = recommended.strip() + " --unwinding-assertions"
            changed = True
    elif default_unwind and not recommended:
        manifest["recommended_cbmc_command_note"] = (
            f"Repair Agent v2 recommends CBMC loop unwinding with --unwind {default_unwind} "
            "and --unwinding-assertions for the selected loop-bound experiment."
        )
        changed = True

    if changed:
        manifest.setdefault("repair_manifest_history", []).append({
            "updated_at": utc_now_iso(),
            "agent": AGENT_NAME,
            "version": AGENT_VERSION,
            "reason": "unwind recommendation update",
            "default_unwind": default_unwind,
        })
    return manifest, changed, {"before": before, "after": manifest, "default_unwind": default_unwind}


def recommend_include_path_notes(manifest: Dict[str, Any], context: RepairContext) -> Tuple[Dict[str, Any], bool, Dict[str, Any]]:
    if not context.settings.allow_include_dir_manifest_notes:
        return manifest, False, {}
    tool_diag = context.v2_inputs.get("json", {}).get("06_cbmc_diagnostics.json", {})
    missing = []
    for item in as_list(tool_diag.get("missing_source_files")):
        missing.append(str(item))
    for item in as_list(context.cbmc_status.get("missing_source_files")):
        missing.append(str(item))
    if not missing:
        return manifest, False, {}
    manifest.setdefault("repair_agent_tool_notes", [])
    note = {
        "created_at": utc_now_iso(),
        "type": "missing_source_or_include_note",
        "missing_files": unique_preserve_order(missing),
        "recommendation": "Check tool_execution_settings.source_files/include_dirs or Agent 5 manifest input_files before rerunning CBMC.",
    }
    if note not in manifest["repair_agent_tool_notes"]:
        manifest["repair_agent_tool_notes"].append(note)
        return manifest, True, note
    return manifest, False, note


# ---------------------------------------------------------------------------
# V2 traceability and safety review helpers
# ---------------------------------------------------------------------------

def build_repair_prompt(context: RepairContext) -> str:
    v2_present = [name for name, present in context.v2_inputs.get("presence", {}).items() if present]
    return f"""You are the Repair / Refinement Agent v2 for an AI-assisted formal-verification workflow.

Task:
Read the generated harness, critic review, CBMC status/output, counterexample analysis,
and v2 traceability files. Create a controlled candidate repair. Do not hide failures.
Do not claim proof.

Target function: {context.target_function}
Iteration: {context.iteration}
Source artifact: {context.source_artifact_path.name}

Repair rules:
1. Fix CBMC compatibility issues only when safe: missing includes, nondet declarations, missing comments.
2. If overflow/assertion failure is detected, prefer explicit casts and candidate preconditions over silent claim changes.
3. Do not remove assertions just to make CBMC pass.
4. Do not invent specification facts.
5. Mark every new assumption as a candidate precondition requiring human/spec review.
6. Link every repair decision to critic/tool/counterexample/spec/code evidence when available.
7. Save repaired artifact, repair notes, diff, decision log, traceability, assumption/assertion changes, and safety review.
8. Human review and formal-tool re-check remain mandatory.

Legacy context files:
- 01_spec_summary.json
- 02_code_summary.json
- 03_candidate_properties.json
- 04_generated_harness.c or previous repaired harness
- 05_critic_review.json
- 06_cbmc_status.json
- 06_cbmc_output.txt
- 07_counterexample_analysis.json

Detected v2 context files:
{json.dumps(v2_present, indent=2, ensure_ascii=False)}

Scientific guardrail:
{SCIENTIFIC_GUARDRAIL}
"""


def build_input_snapshot(context: RepairContext, source_code: str) -> Dict[str, Any]:
    files = [
        "01_spec_summary.json", "02_code_summary.json", "03_candidate_properties.json",
        "04_artifact_manifest.json", "04_generated_harness.c", "05_critic_review.json",
        "06_cbmc_status.json", "06_cbmc_output.txt", "06_cbmc_property_results.json",
        "07_counterexample_analysis.json", "07_repair_guidance.json", "07_repair_action_plan.json",
    ]
    snapshot: Dict[str, Any] = {
        "created_at": utc_now_iso(),
        "agent": AGENT_NAME,
        "agent_version": AGENT_VERSION,
        "config_path": str(context.config_path),
        "resolved_config_path": str(context.resolved_config_path) if context.resolved_config_path else None,
        "run_dir": str(context.run_dir),
        "project_root": str(context.project_root),
        "iteration": context.iteration,
        "target_function": context.target_function,
        "source_artifact": str(context.source_artifact_path),
        "source_artifact_exists": context.source_artifact_path.exists(),
        "source_artifact_sha256": sha256_file(context.source_artifact_path),
        "source_artifact_text_sha256": sha256_text(source_code) if source_code else None,
        "files": {},
        "v2_presence": context.v2_inputs.get("presence", {}),
    }
    for name in files:
        p = context.run_dir / name
        snapshot["files"][name] = {
            "exists": p.exists(),
            "sha256": sha256_file(p),
            "size_bytes": p.stat().st_size if p.exists() and p.is_file() else None,
        }
    return snapshot


def actions_to_json(actions: List[RepairAction]) -> List[Dict[str, Any]]:
    return [
        {
            "action_id": a.action_id,
            "category": a.category,
            "description": a.description,
            "applied": a.applied,
            "confidence": a.confidence,
            "reason": a.reason,
            "evidence": a.evidence,
            "human_review_note": a.human_review_note,
            "source_stage": a.source_stage,
            "safety_level": a.safety_level,
        }
        for a in actions
    ]


def build_repair_traceability(context: RepairContext, result: RepairResult, failures: List[str]) -> Dict[str, Any]:
    critic_issues = collect_critic_issues(context.critic_review)
    failed_mapping = context.v2_inputs.get("json", {}).get("07_failed_property_mapping.json", {}) or context.v2_inputs.get("json", {}).get("06_failed_property_mapping.json", {})
    repair_plan = context.v2_inputs.get("json", {}).get("07_repair_action_plan.json", {})
    diagnosis = context.v2_inputs.get("json", {}).get("07_tool_vs_harness_vs_code_diagnosis.json", {})
    return {
        "created_at": utc_now_iso(),
        "agent": AGENT_NAME,
        "agent_version": AGENT_VERSION,
        "traceability_goal": "Connect repair actions to critic issues, tool failures, counterexample diagnosis, and spec/code evidence.",
        "source_artifact": result.source_artifact,
        "repaired_artifact": result.repaired_artifact,
        "failure_modes_seen": failures,
        "critic_issues_used": critic_issues,
        "agent7_status": {
            "status": context.cbmc_status.get("status"),
            "execution_status": context.cbmc_status.get("execution_status"),
            "failed_property": context.cbmc_status.get("failed_property"),
            "failed_properties_count": context.cbmc_status.get("failed_properties_count"),
        },
        "agent8_primary_classification": context.counterexample_analysis.get("primary_classification"),
        "agent8_failure_source": context.counterexample_analysis.get("failure_source"),
        "agent8_repair_guidance_file": "07_repair_guidance.json" if (context.run_dir / "07_repair_guidance.json").exists() else None,
        "agent8_repair_action_plan": repair_plan,
        "failed_property_mapping": failed_mapping,
        "tool_vs_harness_vs_code_diagnosis": diagnosis,
        "actions": actions_to_json(result.actions),
        "guardrail": SCIENTIFIC_GUARDRAIL,
    }


def build_safety_review(
    context: RepairContext,
    result: RepairResult,
    original_code: str,
    repaired_code: str,
    assumption_changes: List[Dict[str, Any]],
    assertion_changes: List[Dict[str, Any]],
    failures: List[str],
) -> Dict[str, Any]:
    removed_assertions = max(0, len(re.findall(r"\bassert\s*\(", original_code)) - len(re.findall(r"\bassert\s*\(", repaired_code)))
    added_assumptions = max(0, len(re.findall(r"__CPROVER_assume\s*\(", repaired_code)) - len(re.findall(r"__CPROVER_assume\s*\(", original_code)))
    unsupported_warning = any(
        "unsupported" in flatten_text(a).lower() or "human/spec review" in flatten_text(a).lower()
        for a in actions_to_json(result.actions)
    )
    risk_items: List[Dict[str, Any]] = []

    if removed_assertions > 0:
        risk_items.append({
            "risk": "assertion_removed",
            "severity": "critical",
            "message": "A repair removed assertion(s). This can hide a failing property and must be manually reviewed.",
        })
    if added_assumptions > 0:
        risk_items.append({
            "risk": "assumption_strengthening",
            "severity": "high",
            "message": "The repaired harness added assumptions. They must be justified by specification/code evidence, not used merely to force a pass.",
        })
    if "tool_unavailable" in failures:
        risk_items.append({
            "risk": "tool_not_executed",
            "severity": "high",
            "message": "CBMC was unavailable, so code repair cannot validate the artifact.",
        })
    if result.status == "no_code_change_repair_notes_only":
        risk_items.append({
            "risk": "no_automatic_repair",
            "severity": "medium",
            "message": "No safe deterministic code-level repair was applicable.",
        })
    if unsupported_warning:
        risk_items.append({
            "risk": "candidate_only_assumptions_or_assertions",
            "severity": "medium",
            "message": "Some repairs are intentionally marked candidate-only and need human review.",
        })

    passes = {
        "does_not_claim_proof": True,
        "keeps_human_review_required": result.human_review_required,
        "does_not_remove_assertions": removed_assertions == 0,
        "tracks_assumption_changes": bool(assumption_changes) or added_assumptions == 0,
        "tracks_assertion_changes": bool(assertion_changes) or removed_assertions == 0,
        "recheck_recommended_when_code_changed": result.tool_execution_recommended if any(a.applied for a in result.actions) else True,
    }
    overall = "needs_human_review"
    if risk_items:
        if any(r["severity"] == "critical" for r in risk_items):
            overall = "blocked_until_manual_review"
        else:
            overall = "candidate_safe_with_review"
    elif result.status in {"repaired_candidate_generated", "dry_run_repair_planned"}:
        overall = "candidate_safe_requires_cbmc_rerun"
    elif result.status == "no_code_change_repair_notes_only":
        overall = "notes_only_manual_review_needed"

    return {
        "created_at": utc_now_iso(),
        "agent": AGENT_NAME,
        "agent_version": AGENT_VERSION,
        "overall_safety_status": overall,
        "checks": passes,
        "risk_items": risk_items,
        "removed_assertions_estimate": removed_assertions,
        "added_assumptions_estimate": added_assumptions,
        "assumption_changes_count": len(assumption_changes),
        "assertion_changes_count": len(assertion_changes),
        "human_review_required": True,
        "formal_tool_rerun_required": bool(result.tool_execution_recommended),
        "guardrail": SCIENTIFIC_GUARDRAIL,
    }


def build_action_plan_consumed(context: RepairContext, actions: List[RepairAction]) -> Dict[str, Any]:
    plan = context.v2_inputs.get("json", {}).get("07_repair_action_plan.json", {})
    guidance = context.v2_inputs.get("json", {}).get("07_repair_guidance.json", {})
    return {
        "created_at": utc_now_iso(),
        "agent": AGENT_NAME,
        "agent_version": AGENT_VERSION,
        "repair_action_plan_present": bool(plan),
        "repair_guidance_present": bool(guidance),
        "input_plan": plan,
        "input_guidance": guidance,
        "actions_applied_or_considered": actions_to_json(actions),
        "interpretation": "Agent 9 v2 consumed Agent 8 v2 guidance as repair evidence, but deterministic safety rules decided what could actually be applied.",
    }


# ---------------------------------------------------------------------------
# Repair executor
# ---------------------------------------------------------------------------

def perform_repair(context: RepairContext) -> Tuple[RepairResult, Dict[str, Any]]:
    actions: List[RepairAction] = []
    warnings: List[str] = []
    limitations: List[str] = []
    decision_log: List[Dict[str, Any]] = []
    assumption_changes: List[Dict[str, Any]] = []
    assertion_changes: List[Dict[str, Any]] = []
    manifest_update: Dict[str, Any] = {}

    original_code = read_text(context.source_artifact_path, default="")
    if not original_code:
        status = "repair_not_possible"
        limitations.append(f"Source artifact not found or empty: {context.source_artifact_path}")
        result = RepairResult(
            source_artifact=str(context.source_artifact_path),
            repaired_artifact=str(context.repaired_artifact_path),
            status=status,
            tool_execution_recommended=False,
            human_review_required=True,
            actions=actions,
            warnings=warnings,
            limitations=limitations,
            next_step="Fix artifact generation or file path before repair.",
        )
        extra = {
            "decision_log": decision_log,
            "assumption_changes": assumption_changes,
            "assertion_changes": assertion_changes,
            "manifest_update": manifest_update,
            "failures": [],
            "original_code": original_code,
            "repaired_code": original_code,
        }
        return result, extra

    critic_issues = collect_critic_issues(context.critic_review)
    failures = collect_failure_modes(context)
    all_issue_text = "\n".join([
        flatten_text(critic_issues),
        "\n".join(failures),
        flatten_text(context.counterexample_analysis),
        flatten_text(context.v2_inputs.get("json", {}).get("07_repair_action_plan.json", {})),
        flatten_text(context.v2_inputs.get("json", {}).get("07_repair_guidance.json", {})),
    ]).lower()

    code = original_code

    def record_decision(action: RepairAction) -> None:
        decision_log.append({
            "timestamp": utc_now_iso(),
            "action_id": action.action_id,
            "category": action.category,
            "applied": action.applied,
            "confidence": action.confidence,
            "reason": action.reason,
            "source_stage": action.source_stage,
            "safety_level": action.safety_level,
            "human_review_note": action.human_review_note,
        })

    # 1. Provenance banner.
    code, changed = add_repair_banner(code, context)
    action = RepairAction(
        action_id="R001",
        category="traceability",
        description="Add repair provenance and research guardrail banner to the harness.",
        applied=changed,
        confidence="high",
        reason="Reproducibility requires repaired artifacts to be clearly marked.",
        human_review_note="Banner does not affect verification semantics.",
        source_stage="agent9_v2",
    )
    actions.append(action); record_decision(action)

    # 2. CBMC/C compatibility includes and declarations.
    if context.settings.allow_cbmc_compatibility_patches:
        for include in ["<assert.h>", "<stdint.h>", "<limits.h>"]:
            code, inc_changed = ensure_include(code, include)
            if inc_changed:
                action = RepairAction(
                    action_id=f"R_INC_{include.strip('<>').replace('.', '_').upper()}",
                    category="cbmc_compatibility",
                    description=f"Add missing include {include}.",
                    applied=True,
                    confidence="high",
                    reason="Harness uses assertions, fixed-width integer casts, or INT16_MIN/INT16_MAX-style guards.",
                    source_stage="agent9_v2",
                )
                actions.append(action); record_decision(action)

        code, decl_changed, missing_calls = ensure_cbmc_nondet_declarations(code)
        action = RepairAction(
            action_id="R002",
            category="cbmc_compatibility",
            description="Add external declarations for CBMC nondeterministic input functions used by the harness.",
            applied=decl_changed,
            confidence="high",
            reason="CBMC harnesses commonly use nondet_* symbols; explicit declarations reduce type/parsing problems.",
            evidence=[{"missing_nondet_function": x} for x in missing_calls],
            source_stage="agent9_v2",
        )
        actions.append(action); record_decision(action)

    # 3. Transparency comments for assumptions and assertions.
    if context.settings.allow_assumption_commenting:
        code, assumption_changed, assumption_comment_changes = comment_assumptions(code)
        assumption_changes.extend(assumption_comment_changes)
        action = RepairAction(
            action_id="R003",
            category="assumption_transparency",
            description="Annotate CPROVER assumptions as candidate preconditions requiring spec/code review.",
            applied=assumption_changed,
            confidence="high",
            reason="Generated assumptions can be too strong or unsupported; comments make the limitation explicit.",
            evidence=[{"assumptions_commented": len(assumption_comment_changes)}],
            human_review_note="Every generated assumption must be checked against selected specification and implementation context.",
            source_stage="agent6_agent8_agent9_v2",
        )
        actions.append(action); record_decision(action)

    code, assertion_comment_changed, assertion_comment_changes = annotate_assertions(code)
    assertion_changes.extend(assertion_comment_changes)
    action = RepairAction(
        action_id="R003B",
        category="assertion_transparency",
        description="Annotate assertions as candidate assertions requiring property/spec review.",
        applied=assertion_comment_changed,
        confidence="high",
        reason="Candidate assertions need traceability to Agent 4 properties and Agent 5 assertion plan.",
        evidence=[{"assertions_commented": len(assertion_comment_changes)}],
        human_review_note="Every assertion must be checked against the selected candidate property and spec/code evidence.",
        source_stage="agent5_agent6_agent8_agent9_v2",
    )
    actions.append(action); record_decision(action)

    # 4. Failure-guided assertion / overflow repair.
    overflow_related = (
        "signed_overflow" in failures
        or "unsigned_overflow" in failures
        or "overflow" in failures
        or has_any(all_issue_text, ["overflow", "too broad", "input range", "assertion may", "assertion too strong"])
    )
    assertion_related = (
        "assertion_failure" in failures
        or has_any(all_issue_text, ["assert", "functional equality", "too strong", "failed property"])
    )

    pattern_info: Optional[Dict[str, str]] = None
    if context.settings.allow_assertion_rewrite and (overflow_related or assertion_related):
        code, assertion_changed, pattern_info, assertion_rewrite_meta = rewrite_functional_assertion_casts(code)
        if assertion_changed:
            assertion_changes.append({
                "change_type": "assertion_rewritten_with_int32_casts",
                "old": assertion_rewrite_meta.get("old"),
                "new": assertion_rewrite_meta.get("new"),
                "reason": "Reduce assertion-side arithmetic overflow noise while preserving equality shape.",
                "requires_human_review": True,
            })
        action = RepairAction(
            action_id="R004",
            category="assertion_rewrite",
            description="Rewrite simple coefficient functional assertion with int32_t casts to reduce assertion-side overflow noise.",
            applied=assertion_changed,
            confidence="medium" if assertion_changed else "low",
            reason="CBMC failures involving signed overflow/equality assertions often come from expression semantics or over-broad input ranges.",
            evidence=[assertion_rewrite_meta] if assertion_changed else [],
            human_review_note="This preserves the intended equality check shape but does not prove the specification-level property by itself.",
            source_stage="agent7_agent8_agent9_v2",
        )
        actions.append(action); record_decision(action)

        if assertion_changed and pattern_info and context.settings.allow_candidate_overflow_preconditions:
            code, guard_changed, guard_changes = insert_overflow_precondition_loop(code, context, pattern_info)
            assumption_changes.extend(guard_changes)
            action = RepairAction(
                action_id="R005",
                category="candidate_precondition",
                description="Insert candidate overflow precondition before the target call for int16_t-style coefficient storage.",
                applied=guard_changed,
                confidence="medium" if guard_changed else "low",
                reason="The previous harness may allow inputs whose mathematical result cannot fit the output coefficient representation.",
                evidence=[{"failure_modes": failures}, {"guard_changes": guard_changes}],
                human_review_note="This is intentionally marked as a candidate assumption. It must be justified or rejected during human/spec review.",
                source_stage="agent2_agent3_agent7_agent8_agent9_v2",
            )
            actions.append(action); record_decision(action)
        elif assertion_changed and not context.settings.allow_candidate_overflow_preconditions:
            warnings.append("Overflow precondition insertion is disabled by repair_settings.allow_candidate_overflow_preconditions=false.")

    # 5. Tool command / manifest notes.
    manifest = dict(context.artifact_manifest) if isinstance(context.artifact_manifest, dict) else {}
    if "unwinding" in failures or has_any(all_issue_text, ["unwind", "unwinding"]):
        manifest, manifest_changed, meta = update_unwind_recommendation(manifest, context)
        manifest_update["unwind_recommendation"] = meta
        action = RepairAction(
            action_id="R006",
            category="tool_command_recommendation",
            description="Update or add CBMC unwinding recommendation in the artifact manifest.",
            applied=manifest_changed,
            confidence="medium",
            reason="Loop-based harnesses need appropriate unwinding and unwinding assertions.",
            evidence=[meta] if meta else [],
            source_stage="agent3_agent7_agent8_agent9_v2",
        )
        actions.append(action); record_decision(action)

    if "missing_source_or_include" in failures or "tool_error" in failures:
        manifest, include_note_changed, include_note = recommend_include_path_notes(manifest, context)
        manifest_update["include_source_note"] = include_note
        action = RepairAction(
            action_id="R007",
            category="tool_command_recommendation",
            description="Record missing source/include diagnostic note in artifact manifest.",
            applied=include_note_changed,
            confidence="medium",
            reason="CBMC tool errors may require source list/include-dir repair outside the C harness.",
            evidence=[include_note] if include_note else [],
            human_review_note="This does not modify C semantics; check project paths and CBMC command before rerun.",
            source_stage="agent7_agent9_v2",
        )
        actions.append(action); record_decision(action)

    # 6. Warning policies.
    if "tool_unavailable" in failures:
        warnings.append("CBMC appears unavailable. Code repair alone cannot fix missing tool installation/PATH setup.")
    if "critic_blocked" in failures:
        warnings.append("Agent 7/critic gate indicates tool execution was blocked. Review Agent 6 issues before relying on repair.")
    if "tool_error" in failures or "missing_source_or_include" in failures:
        warnings.append("CBMC/tool parsing or missing-source error detected. Some issues may require include paths, source list, or build-command updates outside this C file.")
    if has_any(all_issue_text, ["unsupported assumption", "too strong", "vacuous", "over-constraining"]):
        warnings.append("Critic/counterexample analysis mentions unsupported/too-strong assumptions. The repaired harness remains candidate-only.")
        if context.settings.strict_no_unsupported_assumption_narrowing:
            limitations.append("Strict mode enabled: the agent did not narrow assumptions using unsupported specification facts.")

    if code == original_code:
        limitations.append("No safe deterministic code-level repair pattern was applicable. Repair notes and v2 logs were still generated.")

    applied_count = sum(1 for a in actions if a.applied)
    if context.settings.dry_run:
        status = "dry_run_repair_planned"
    elif applied_count > 0:
        status = "repaired_candidate_generated"
    else:
        status = "no_code_change_repair_notes_only"

    tool_recommended = applied_count > 0 and "tool_unavailable" not in failures
    if status == "no_code_change_repair_notes_only":
        tool_recommended = False

    # Write changed harness and manifest unless dry-run.
    if not context.settings.dry_run:
        write_text(context.repaired_artifact_path, code)
        if manifest:
            manifest["repair_agent_updated_at"] = utc_now_iso()
            manifest["repair_agent_version"] = AGENT_VERSION
            manifest["latest_repaired_artifact"] = context.repaired_artifact_path.name
            manifest.setdefault("scientific_guardrails", {})
            manifest["scientific_guardrails"]["repaired_artifact_is_candidate_only"] = True
            save_json(context.run_dir / "04_artifact_manifest.json", manifest)

    next_step = (
        "Run Formal Tool Execution Agent on 08_repaired_harness.c, then re-run counterexample analysis if CBMC fails."
        if tool_recommended
        else "Human review is recommended before another tool run."
    )

    result = RepairResult(
        source_artifact=str(context.source_artifact_path),
        repaired_artifact=str(context.repaired_artifact_path),
        status=status,
        tool_execution_recommended=tool_recommended,
        human_review_required=context.settings.require_human_review,
        actions=actions,
        warnings=unique_preserve_order(warnings),
        limitations=unique_preserve_order(limitations),
        next_step=next_step,
    )
    extra = {
        "decision_log": decision_log,
        "assumption_changes": assumption_changes,
        "assertion_changes": assertion_changes,
        "manifest_update": manifest_update,
        "failures": failures,
        "original_code": original_code,
        "repaired_code": code,
    }
    return result, extra


# ---------------------------------------------------------------------------
# Output formatting
# ---------------------------------------------------------------------------

def build_notes_json(context: RepairContext, result: RepairResult, diff_text: str, extra: Dict[str, Any]) -> Dict[str, Any]:
    critic_issues = collect_critic_issues(context.critic_review)
    failures = extra.get("failures", [])
    return {
        "agent_name": AGENT_NAME,
        "agent_number": AGENT_NUMBER,
        "agent_version": AGENT_VERSION,
        "created_at": utc_now_iso(),
        "target_function": context.target_function,
        "iteration": context.iteration,
        "status": result.status,
        "source_artifact": result.source_artifact,
        "repaired_artifact": result.repaired_artifact,
        "tool_execution_recommended": result.tool_execution_recommended,
        "human_review_required": result.human_review_required,
        "research_guardrail": SCIENTIFIC_GUARDRAIL,
        "inputs_used": {
            "spec_summary": "01_spec_summary.json",
            "code_summary": "02_code_summary.json",
            "candidate_properties": "03_candidate_properties.json",
            "artifact_manifest": "04_artifact_manifest.json",
            "critic_review": "05_critic_review.json",
            "cbmc_status": "06_cbmc_status.json",
            "cbmc_output": "06_cbmc_output.txt",
            "counterexample_analysis": "07_counterexample_analysis.json",
            "agent8_v2_repair_guidance": "07_repair_guidance.json",
            "agent8_v2_repair_action_plan": "07_repair_action_plan.json",
        },
        "failure_modes_seen": failures,
        "critic_issue_count": len(critic_issues),
        "repair_actions": actions_to_json(result.actions),
        "warnings": result.warnings,
        "limitations": result.limitations,
        "next_step": result.next_step,
        "diff_summary": {
            "diff_file": "08_repair_patch.diff",
            "changed": bool(diff_text.strip()),
            "added_lines_estimate": sum(1 for line in diff_text.splitlines() if line.startswith("+") and not line.startswith("+++")),
            "removed_lines_estimate": sum(1 for line in diff_text.splitlines() if line.startswith("-") and not line.startswith("---")),
        },
        "v2_outputs": {
            "repair_decision_log": "08_repair_decision_log.json",
            "repair_traceability": "08_repair_traceability.json",
            "assumption_changes": "08_assumption_changes.csv",
            "assertion_changes": "08_assertion_changes.csv",
            "repair_safety_review": "08_repair_safety_review.json",
            "repair_input_snapshot": "08_repair_input_snapshot.json",
            "repair_manifest_update": "08_repair_manifest_update.json",
            "repair_action_plan_consumed": "08_repair_action_plan_consumed.json",
        },
        "iteration_control": {
            "max_iterations": context.settings.max_iterations,
            "current_iteration": context.iteration,
            "continue_allowed": context.iteration + 1 < context.settings.max_iterations,
        },
    }


def build_markdown_report(notes: Dict[str, Any]) -> str:
    lines: List[str] = []
    lines.append("# 08 Repair / Refinement Report")
    lines.append("")
    lines.append(f"- **Agent:** `{notes['agent_name']}` v{notes['agent_version']}")
    lines.append(f"- **Target function:** `{notes['target_function']}`")
    lines.append(f"- **Iteration:** `{notes['iteration']}`")
    lines.append(f"- **Status:** `{notes['status']}`")
    lines.append(f"- **Source artifact:** `{Path(notes['source_artifact']).name}`")
    lines.append(f"- **Repaired artifact:** `{Path(notes['repaired_artifact']).name}`")
    lines.append(f"- **Tool execution recommended:** `{notes['tool_execution_recommended']}`")
    lines.append(f"- **Human review required:** `{notes['human_review_required']}`")
    lines.append("")
    lines.append("## Research Guardrail")
    lines.append("")
    lines.append(notes["research_guardrail"])
    lines.append("")
    lines.append("## Failure Modes Seen")
    lines.append("")
    if notes["failure_modes_seen"]:
        for mode in notes["failure_modes_seen"]:
            lines.append(f"- `{mode}`")
    else:
        lines.append("- No explicit failure mode was detected from the available status/output files.")
    lines.append("")
    lines.append("## Repair Actions")
    lines.append("")
    for action in notes["repair_actions"]:
        applied = "yes" if action["applied"] else "no"
        lines.append(f"### {action['action_id']} — {action['category']}")
        lines.append(f"- **Applied:** {applied}")
        lines.append(f"- **Confidence:** {action['confidence']}")
        lines.append(f"- **Description:** {action['description']}")
        lines.append(f"- **Reason:** {action['reason']}")
        if action.get("source_stage"):
            lines.append(f"- **Evidence source stage:** `{action['source_stage']}`")
        if action.get("human_review_note"):
            lines.append(f"- **Human review note:** {action['human_review_note']}")
        lines.append("")
    lines.append("## Warnings")
    lines.append("")
    if notes["warnings"]:
        for warning in notes["warnings"]:
            lines.append(f"- {warning}")
    else:
        lines.append("- None recorded.")
    lines.append("")
    lines.append("## Limitations")
    lines.append("")
    if notes["limitations"]:
        for limitation in notes["limitations"]:
            lines.append(f"- {limitation}")
    else:
        lines.append("- No additional limitation recorded beyond mandatory human/formal-tool review.")
    lines.append("")
    lines.append("## New v2 Evidence Files")
    lines.append("")
    for label, filename in notes.get("v2_outputs", {}).items():
        lines.append(f"- `{filename}`")
    lines.append("")
    lines.append("## Next Step")
    lines.append("")
    lines.append(notes["next_step"])
    lines.append("")
    return "\n".join(lines)


def write_iteration_snapshot(context: RepairContext, notes: Dict[str, Any], diff_text: str) -> None:
    if not context.settings.write_iteration_snapshot or context.settings.dry_run:
        return
    snap_dir = context.run_dir / "repairs" / f"iteration_{context.iteration:02d}"
    snap_dir.mkdir(parents=True, exist_ok=True)
    for name in [
        "08_repaired_harness.c", "08_repair_notes.json", "08_repair_notes.md",
        "08_repair_patch.diff", "08_repair_decision_log.json", "08_repair_traceability.json",
        "08_repair_safety_review.json", "08_assumption_changes.csv", "08_assertion_changes.csv",
        "08_repair_input_snapshot.json", "08_repair_manifest_update.json", "08_repair_action_plan_consumed.json",
    ]:
        p = context.run_dir / name
        if p.exists():
            shutil.copy2(p, snap_dir / name)
    save_json(snap_dir / "08_repair_notes.json", notes)
    write_text(snap_dir / "08_repair_patch.diff", diff_text)


# ---------------------------------------------------------------------------
# Main CLI
# ---------------------------------------------------------------------------

def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Agent 9 v2: Repair / Refinement Agent for candidate CBMC formal-verification artifacts."
    )
    parser.add_argument("--config", required=True, help="Path to run configuration JSON.")
    parser.add_argument("--run-dir", required=False, help="Run directory, e.g. runs/run_001_poly_add.")
    parser.add_argument("--iteration", type=int, default=0, help="Repair iteration number.")
    parser.add_argument("--source-artifact", required=False, help="Artifact to repair, relative to run-dir or absolute.")
    parser.add_argument("--artifact", required=False, help="Alias for --source-artifact for orchestrator compatibility.")
    parser.add_argument("--reason", required=False, default="unspecified", help="Reason repair was invoked, such as critic_review or counterexample_analysis. Accepted for orchestrator compatibility.")
    parser.add_argument("--dry-run", action="store_true", help="Plan repair and write reports without changing the harness.")
    parser.add_argument("--strict", action="store_true", help="Fail with non-zero exit if no code repair was possible.")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    context = load_context(args)
    context.run_dir.mkdir(parents=True, exist_ok=True)
    (context.run_dir / "llm_prompts").mkdir(parents=True, exist_ok=True)
    (context.run_dir / "agent_status").mkdir(parents=True, exist_ok=True)
    (context.run_dir / "repairs").mkdir(parents=True, exist_ok=True)

    event_base = {
        "agent_name": AGENT_NAME,
        "agent_version": AGENT_VERSION,
        "time": utc_now_iso(),
        "iteration": context.iteration,
        "target_function": context.target_function,
    }
    append_jsonl(context.run_dir / "events.jsonl", {**event_base, "event": "started"})

    original_code_for_snapshot = read_text(context.source_artifact_path, default="")
    input_snapshot = build_input_snapshot(context, original_code_for_snapshot)
    save_json(context.run_dir / "08_repair_input_snapshot.json", input_snapshot)

    prompt_text = build_repair_prompt(context)
    write_text(context.run_dir / "llm_prompts" / "08_repair_prompt.txt", prompt_text)

    result, extra = perform_repair(context)

    original_code = extra.get("original_code", original_code_for_snapshot)
    repaired_code = extra.get("repaired_code", original_code)
    if context.settings.dry_run:
        # Keep reports, but do not write repaired artifact.
        repaired_code_for_diff = repaired_code
    else:
        repaired_code_for_diff = read_text(context.repaired_artifact_path, default=repaired_code)

    diff_text = unified_diff(
        original_code,
        repaired_code_for_diff,
        from_name=Path(result.source_artifact).name,
        to_name=Path(result.repaired_artifact).name,
    )

    if not context.settings.dry_run:
        write_text(context.run_dir / "08_repair_patch.diff", diff_text)

    notes = build_notes_json(context, result, diff_text, extra)
    if context.settings.dry_run:
        notes["dry_run"] = True
        notes["dry_run_note"] = "Reports were written, but no repaired harness was written because --dry-run was used."

    # v2 evidence outputs.
    repair_traceability = build_repair_traceability(context, result, extra.get("failures", []))
    safety_review = build_safety_review(
        context=context,
        result=result,
        original_code=original_code,
        repaired_code=repaired_code_for_diff,
        assumption_changes=extra.get("assumption_changes", []),
        assertion_changes=extra.get("assertion_changes", []),
        failures=extra.get("failures", []),
    )
    action_plan_consumed = build_action_plan_consumed(context, result.actions)

    save_json(context.run_dir / "08_repair_decision_log.json", {
        "created_at": utc_now_iso(),
        "agent": AGENT_NAME,
        "agent_version": AGENT_VERSION,
        "decisions": extra.get("decision_log", []),
    })
    save_json(context.run_dir / "08_repair_traceability.json", repair_traceability)
    save_json(context.run_dir / "08_repair_safety_review.json", safety_review)
    save_json(context.run_dir / "08_repair_manifest_update.json", extra.get("manifest_update", {}))
    save_json(context.run_dir / "08_repair_action_plan_consumed.json", action_plan_consumed)

    assumption_rows = extra.get("assumption_changes", [])
    assertion_rows = extra.get("assertion_changes", [])
    write_csv(
        context.run_dir / "08_assumption_changes.csv",
        assumption_rows,
        fieldnames=["change_type", "line_before", "old", "new", "assumption_line", "reason", "requires_human_review", "loop_bound"],
    )
    write_csv(
        context.run_dir / "08_assertion_changes.csv",
        assertion_rows,
        fieldnames=["change_type", "line_before", "old", "new", "assertion_line", "reason", "requires_human_review"],
    )

    save_json(context.run_dir / "08_repair_notes.json", notes)
    write_text(context.run_dir / "08_repair_notes.md", build_markdown_report(notes))
    save_json(context.run_dir / "agent_status" / "08_repair_status.json", {
        "agent_name": AGENT_NAME,
        "agent_number": AGENT_NUMBER,
        "agent_version": AGENT_VERSION,
        "status": result.status,
        "created_at": utc_now_iso(),
        "iteration": context.iteration,
        "source_artifact": result.source_artifact,
        "repaired_artifact": result.repaired_artifact,
        "tool_execution_recommended": result.tool_execution_recommended,
        "human_review_required": result.human_review_required,
        "actions_applied": sum(1 for a in result.actions if a.applied),
        "warnings_count": len(result.warnings),
        "limitations_count": len(result.limitations),
        "v2_outputs": notes.get("v2_outputs", {}),
        "safety_review_status": safety_review.get("overall_safety_status"),
    })

    write_iteration_snapshot(context, notes, diff_text)

    append_jsonl(context.run_dir / "events.jsonl", {
        **event_base,
        "time": utc_now_iso(),
        "event": "finished",
        "status": result.status,
        "tool_execution_recommended": result.tool_execution_recommended,
        "safety_review_status": safety_review.get("overall_safety_status"),
    })

    print(f"[OK] Repair / Refinement Agent v2 wrote: {context.run_dir / '08_repair_notes.json'}")
    if not context.settings.dry_run and context.repaired_artifact_path.exists():
        print(f"[OK] Repaired candidate harness: {context.repaired_artifact_path}")
    elif context.settings.dry_run:
        print("[DRY-RUN] No repaired harness was written.")
    print(f"[STATUS] {result.status}")
    print(f"[SAFETY] {safety_review.get('overall_safety_status')}")
    print("[NOTE] Repaired artifacts are candidate verification inputs; CBMC and human review remain required.")

    if args.strict and result.status in {"repair_not_possible", "no_code_change_repair_notes_only"}:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
