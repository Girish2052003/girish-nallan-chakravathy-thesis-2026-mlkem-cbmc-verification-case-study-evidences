#!/usr/bin/env python3
"""
Evaluation and Reporting Agent
==============================

Agent 11 in the thesis-agent-workflow pipeline.

Purpose
-------
This agent converts a completed run folder into thesis-friendly evaluation
evidence. It does NOT prove the cryptographic implementation. It evaluates
the usefulness, tool compatibility, assumption quality, failure modes, repair
history, reproducibility, and human-review needs of candidate formal-
verification artifacts.

Expected inputs inside run directory
------------------------------------
01_spec_summary.json
02_code_summary.json
03_candidate_properties.json
04_artifact_manifest.json
04_generated_harness.c
05_critic_review.json
06_cbmc_status.json
06_cbmc_property_results.json
07_counterexample_analysis.json
08_repair_notes.json
09_experiment_log.json
events.jsonl
human_notes.md

Optional v2-rich inputs
-----------------------
selected_spec_excerpt.txt
01_algorithm_blocks.json
01_symbol_table.json
01_parameter_table.json
01_equations_constraints.json
01_preconditions_postconditions.json
01_spec_to_code_hints.json
03_property_evidence_matrix.csv
03_spec_code_traceability.json
03_agent2v2_integration_report.json
04_spec_grounding_report.json
04_spec_grounded_assertion_plan.json
04_harness_assumption_traceability.csv
05_spec_grounding_review.json
05_assumption_evidence_review.csv
05_assertion_algorithm_alignment.csv
05_symbol_uncertainty_review.json

Outputs
-------
10_evaluation_report.json
10_evaluation_report.md
final_report.md
evaluation/evaluation_table.csv
evaluation/property_coverage.csv
evaluation/failure_taxonomy.csv
evaluation/human_review_checklist.md
evaluation/run_quality_scorecard.json
evaluation/spec_parsing_quality.json
evaluation/spec_parsing_quality.csv
evaluation/algorithm_extraction_coverage.csv
evaluation/symbol_extraction_coverage.csv
evaluation/parameter_extraction_confidence.csv
evaluation/spec_claim_human_review_status.csv
agent_status/10_evaluation_reporter_status.json
llm_prompts/10_evaluation_reporter_prompt.txt

Scientific guardrail
--------------------
The output must always say:
- LLM agents generate candidate formal-verification artifacts.
- CBMC/formal tools check selected properties under stated assumptions.
- Human review remains necessary.
- A selected CBMC pass is not a proof of full ML-KEM correctness.

Author: Thesis Agent Workflow
"""

from __future__ import annotations

import argparse
import csv
import datetime as _dt
import hashlib
import json
import os
import platform
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

AGENT_NAME = "evaluation_reporter"
AGENT_NUMBER = 11
OUTPUT_PREFIX = "10"  # file sequence after 09_experiment_logger

SCIENTIFIC_GUARDRAIL = (
    "This report evaluates candidate formal-verification artifacts generated "
    "by an LLM-assisted workflow. It does not claim full automatic proof of "
    "ML-KEM or any complete cryptographic implementation. Formal-tool results "
    "apply only to the selected harness, selected properties, and stated "
    "assumptions. Human review remains required."
)

EXPECTED_RUN_FILES = [
    "01_spec_summary.json",
    "02_code_summary.json",
    "03_candidate_properties.json",
    "04_artifact_manifest.json",
    "04_generated_harness.c",
    "05_critic_review.json",
    "06_cbmc_status.json",
    "06_cbmc_property_results.json",
    "07_counterexample_analysis.json",
    "08_repair_notes.json",
    "09_experiment_log.json",
    "events.jsonl",
    "human_notes.md",
]

CRITERIA = [
    "correctness",
    "tool_compatibility",
    "specification_relevance",
    "code_relevance",
    "assumption_quality",
    "assertion_quality",
    "failure_usefulness",
    "human_correction_effort",
    "reproducibility",
    "spec_parsing_quality",
    "algorithm_extraction_coverage",
    "symbol_extraction_coverage",
    "parameter_extraction_confidence",
    "spec_claim_human_review_status",
]


# ---------------------------------------------------------------------------
# Data models
# ---------------------------------------------------------------------------

@dataclass
class CriterionScore:
    criterion: str
    score: int
    max_score: int
    level: str
    rationale: str
    evidence: List[str]


@dataclass
class PropertyEvaluation:
    property_id: str
    property_type: str
    description: str
    priority: str
    selected_for_harness: bool
    evidence_in_harness: bool
    cbmc_status: str
    critic_concerns: List[str]
    evaluation_note: str


@dataclass
class FailureTaxonomyItem:
    category: str
    severity: str
    source_agent: str
    evidence: str
    likely_meaning: str
    recommended_action: str


@dataclass
class RunSummary:
    run_id: str
    target_scheme: str
    target_function: str
    verification_tool: str
    artifact_type: str
    final_status: str
    cbmc_status: str
    highest_critic_severity: str
    repair_attempted: bool
    human_review_required: bool
    overall_usefulness: str
    overall_score_percent: float


# ---------------------------------------------------------------------------
# Basic IO helpers
# ---------------------------------------------------------------------------

def utc_now_iso() -> str:
    return _dt.datetime.now(_dt.timezone.utc).replace(microsecond=0).isoformat()


def read_text(path: Path, default: str = "") -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return default


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def read_json(path: Path, default: Any = None) -> Any:
    if default is None:
        default = {}
    try:
        return json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except FileNotFoundError:
        return default
    except json.JSONDecodeError as exc:
        return {
            "_json_error": True,
            "path": str(path),
            "error": str(exc),
            "raw_preview": read_text(path)[:1000],
        }


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")


def read_csv_rows(path: Path) -> List[Dict[str, str]]:
    if not path.exists():
        return []
    try:
        with path.open("r", encoding="utf-8", newline="") as f:
            return list(csv.DictReader(f))
    except Exception:
        return []


def flatten_text(value: Any) -> str:
    if isinstance(value, str):
        return value
    try:
        return json.dumps(value, ensure_ascii=False, sort_keys=True)
    except Exception:
        return str(value)


def text_contains_human_review_marker(value: Any) -> bool:
    text = flatten_text(value).lower()
    markers = [
        "human review", "human_review", "manual review", "needs review",
        "review required", "uncertain", "candidate", "not final",
        "must be checked",
    ]
    return any(marker in text for marker in markers)


def numeric_confidence(value: Any) -> Optional[float]:
    if isinstance(value, (int, float)):
        v = float(value)
        if 0 <= v <= 1:
            return v
        if 0 <= v <= 100:
            return v / 100.0
    if isinstance(value, str):
        s = value.strip().lower()
        mapping = {"high": 0.85, "medium": 0.6, "moderate": 0.6, "low": 0.35, "uncertain": 0.25, "unknown": 0.0}
        if s in mapping:
            return mapping[s]
        try:
            return numeric_confidence(float(s))
        except Exception:
            return None
    return None


def iter_dict_items(data: Any, preferred_keys: Optional[List[str]] = None) -> List[Any]:
    if isinstance(data, list):
        return data
    if not isinstance(data, dict):
        return []
    keys = preferred_keys or [
        "items", "entries", "rows", "records", "algorithm_blocks", "algorithms",
        "blocks", "symbols", "parameters", "constants", "equations", "constraints",
        "preconditions", "postconditions", "input_requirements", "output_guarantees",
    ]
    out: List[Any] = []
    for key in keys:
        if key in data:
            out.extend(as_list(data.get(key)))
    return out


def append_jsonl(path: Path, event: Dict[str, Any]) -> None:
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


def safe_get(obj: Any, path: Iterable[Any], default: Any = None) -> Any:
    cur = obj
    for key in path:
        try:
            if isinstance(cur, dict):
                cur = cur[key]
            elif isinstance(cur, list) and isinstance(key, int):
                cur = cur[key]
            else:
                return default
        except (KeyError, IndexError, TypeError):
            return default
    return cur


def as_list(value: Any) -> List[Any]:
    if value is None:
        return []
    if isinstance(value, list):
        return value
    return [value]


def normalize_status(value: Any) -> str:
    if value is None:
        return "unknown"
    s = str(value).strip().lower()
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
    if "error" in s:
        return "tool_error"
    return s


# ---------------------------------------------------------------------------
# Config and run discovery
# ---------------------------------------------------------------------------

def load_config(config_path: Optional[Path]) -> Dict[str, Any]:
    if not config_path:
        return {}
    return read_json(config_path, {})


def infer_run_dir(config: Dict[str, Any], config_path: Optional[Path], run_dir_arg: Optional[Path]) -> Path:
    if run_dir_arg:
        return run_dir_arg.resolve()

    candidates = [
        safe_get(config, ["run_dir"]),
        safe_get(config, ["output", "run_dir"]),
        safe_get(config, ["paths", "run_dir"]),
    ]
    for candidate in candidates:
        if candidate:
            p = Path(str(candidate)).expanduser()
            if not p.is_absolute() and config_path:
                p = (config_path.parent.parent / p).resolve()
            return p

    run_id = (
        safe_get(config, ["run_id"])
        or safe_get(config, ["experiment", "run_id"])
        or f"run_001_{safe_get(config, ['target_function'], 'unknown')}"
    )
    base = safe_get(config, ["runs_dir"]) or safe_get(config, ["paths", "runs_dir"]) or "runs"
    if config_path:
        return (config_path.parent.parent / base / str(run_id)).resolve()
    return (Path.cwd() / base / str(run_id)).resolve()


def resolve_config_metadata(config: Dict[str, Any], run_dir: Path) -> Dict[str, str]:
    resolved = read_json(run_dir / "run_config.resolved.json", {})
    merged = {}
    merged.update(config if isinstance(config, dict) else {})
    if isinstance(resolved, dict):
        merged.update({k: v for k, v in resolved.items() if v not in (None, "", [])})

    return {
        "run_id": str(
            safe_get(merged, ["run_id"])
            or safe_get(merged, ["experiment", "run_id"])
            or run_dir.name
        ),
        "target_scheme": str(
            safe_get(merged, ["target_scheme"])
            or safe_get(merged, ["scheme"])
            or safe_get(merged, ["experiment", "target_scheme"])
            or "unknown"
        ),
        "target_function": str(
            safe_get(merged, ["target_function"])
            or safe_get(merged, ["function"])
            or safe_get(merged, ["experiment", "target_function"])
            or "unknown"
        ),
        "verification_tool": str(
            safe_get(merged, ["verification_tool"])
            or safe_get(merged, ["tool"])
            or "CBMC"
        ),
        "artifact_type": str(
            safe_get(merged, ["artifact_type"])
            or safe_get(merged, ["verification", "artifact_type"])
            or "CBMC harness"
        ),
    }


# ---------------------------------------------------------------------------
# Analysis helpers
# ---------------------------------------------------------------------------

def count_regex(pattern: str, text: str) -> int:
    return len(re.findall(pattern, text, flags=re.MULTILINE))


def extract_candidate_properties(properties_json: Dict[str, Any]) -> List[Dict[str, Any]]:
    candidates = safe_get(properties_json, ["candidate_properties"], [])
    if isinstance(candidates, list):
        return [p for p in candidates if isinstance(p, dict)]

    # Some earlier agents may save nested output.
    for key in ("properties", "selected_properties", "cbmc_property_plan"):
        candidate = safe_get(properties_json, [key], [])
        if isinstance(candidate, list):
            return [p for p in candidate if isinstance(p, dict)]

    return []


def extract_selected_properties(manifest: Dict[str, Any], properties_json: Dict[str, Any]) -> List[str]:
    selected: List[str] = []

    for path in [
        ["selected_properties"],
        ["artifact", "selected_properties"],
        ["cbmc_plan", "selected_properties"],
        ["properties_covered"],
    ]:
        value = safe_get(manifest, path, [])
        for item in as_list(value):
            if isinstance(item, dict):
                pid = item.get("id") or item.get("property_id")
                if pid:
                    selected.append(str(pid))
            elif item:
                selected.append(str(item))

    plan = safe_get(properties_json, ["cbmc_property_plan", "selected_properties"], [])
    for item in as_list(plan):
        if isinstance(item, dict):
            pid = item.get("id") or item.get("property_id")
            if pid:
                selected.append(str(pid))
        elif item:
            selected.append(str(item))

    # Deduplicate preserving order.
    out: List[str] = []
    seen = set()
    for x in selected:
        if x not in seen:
            out.append(x)
            seen.add(x)
    return out


def collect_critic_issues(critic_json: Dict[str, Any]) -> List[Dict[str, Any]]:
    issues = safe_get(critic_json, ["issues"], [])
    if isinstance(issues, list):
        return [i for i in issues if isinstance(i, dict)]

    findings = safe_get(critic_json, ["findings"], [])
    if isinstance(findings, list):
        return [i for i in findings if isinstance(i, dict)]

    return []


def highest_severity(issues: List[Dict[str, Any]]) -> str:
    order = {"critical": 5, "high": 4, "medium": 3, "low": 2, "info": 1, "unknown": 0}
    best = "unknown"
    best_score = 0
    for issue in issues:
        sev = str(issue.get("severity", "unknown")).lower()
        if order.get(sev, 0) > best_score:
            best = sev
            best_score = order.get(sev, 0)
    return best


def status_from_cbmc(cbmc_status_json: Dict[str, Any]) -> str:
    for path in [
        ["status"],
        ["verification_status"],
        ["cbmc_status"],
        ["result"],
        ["tool_status"],
    ]:
        value = safe_get(cbmc_status_json, path)
        if value is not None:
            return normalize_status(value)
    return "unknown"


def cbmc_failed_properties(property_results_json: Any) -> List[str]:
    failed: List[str] = []
    if isinstance(property_results_json, list):
        iterable = property_results_json
    elif isinstance(property_results_json, dict):
        iterable = safe_get(property_results_json, ["property_results"], [])
        if not iterable and "failed_properties" in property_results_json:
            return [str(x) for x in as_list(property_results_json.get("failed_properties"))]
    else:
        iterable = []

    for item in as_list(iterable):
        if not isinstance(item, dict):
            continue
        status = normalize_status(item.get("status") or item.get("result"))
        if status == "failed":
            failed.append(str(item.get("property") or item.get("name") or item.get("id") or "unknown_property"))
    return failed


def find_property_evidence_in_harness(prop: Dict[str, Any], harness_text: str) -> bool:
    ptype = str(prop.get("type", "")).lower()
    desc = str(prop.get("description", "")).lower()

    if "pointer" in ptype or "pointer" in desc:
        return "__CPROVER_assume" in harness_text and ("&" in harness_text or "!= NULL" in harness_text)
    if "memory" in ptype or "bounds" in ptype or "array" in desc:
        return "for" in harness_text and ("assert" in harness_text or "__CPROVER_assume" in harness_text)
    if "overflow" in ptype or "overflow" in desc:
        return "INT" in harness_text or "int32_t" in harness_text or "overflow" in harness_text.lower()
    if "functional" in ptype or "equals" in desc or "match" in desc:
        return "assert" in harness_text and ("==" in harness_text or "memcmp" in harness_text)
    if "range" in ptype or "range" in desc:
        return "<=" in harness_text or ">=" in harness_text
    return "assert" in harness_text


def classify_overall_usefulness(score_percent: float, cbmc_status: str, highest_sev: str) -> str:
    if cbmc_status == "passed" and score_percent >= 75 and highest_sev not in {"critical", "high"}:
        return "high"
    if score_percent >= 55 and highest_sev != "critical":
        return "medium"
    if cbmc_status in {"tool_unavailable", "tool_error"} and score_percent >= 45:
        return "limited_but_useful_for_workflow_debugging"
    return "low_or_needs_revision"



# ---------------------------------------------------------------------------
# v2 FIPS-aware spec parsing evaluation helpers
# ---------------------------------------------------------------------------

def load_v2_rich_inputs(run_dir: Path) -> Dict[str, Any]:
    return {
        "selected_spec_excerpt_text": read_text(run_dir / "selected_spec_excerpt.txt"),
        "spec_sections_index": read_json(run_dir / "01_spec_sections_index.json", {}),
        "algorithm_blocks": read_json(run_dir / "01_algorithm_blocks.json", {}),
        "symbol_table": read_json(run_dir / "01_symbol_table.json", {}),
        "parameter_table": read_json(run_dir / "01_parameter_table.json", {}),
        "equations_constraints": read_json(run_dir / "01_equations_constraints.json", {}),
        "preconditions_postconditions": read_json(run_dir / "01_preconditions_postconditions.json", {}),
        "spec_to_code_hints": read_json(run_dir / "01_spec_to_code_hints.json", {}),
        "property_evidence_matrix_rows": read_csv_rows(run_dir / "03_property_evidence_matrix.csv"),
        "spec_code_traceability": read_json(run_dir / "03_spec_code_traceability.json", {}),
        "agent2v2_integration_report": read_json(run_dir / "03_agent2v2_integration_report.json", {}),
        "spec_grounding_report": read_json(run_dir / "04_spec_grounding_report.json", {}),
        "spec_grounded_assertion_plan": read_json(run_dir / "04_spec_grounded_assertion_plan.json", {}),
        "harness_assumption_traceability_rows": read_csv_rows(run_dir / "04_harness_assumption_traceability.csv"),
        "spec_grounding_review": read_json(run_dir / "05_spec_grounding_review.json", {}),
        "assumption_evidence_review_rows": read_csv_rows(run_dir / "05_assumption_evidence_review.csv"),
        "assertion_algorithm_alignment_rows": read_csv_rows(run_dir / "05_assertion_algorithm_alignment.csv"),
        "symbol_uncertainty_review": read_json(run_dir / "05_symbol_uncertainty_review.json", {}),
        "experiment_log": read_json(run_dir / "09_experiment_log.json", {}),
    }


def v2_file_presence(run_dir: Path) -> Dict[str, bool]:
    files = [
        "selected_spec_excerpt.txt", "01_spec_sections_index.json", "01_algorithm_blocks.json",
        "01_symbol_table.json", "01_parameter_table.json", "01_equations_constraints.json",
        "01_preconditions_postconditions.json", "01_spec_to_code_hints.json",
        "03_property_evidence_matrix.csv", "03_spec_code_traceability.json",
        "03_agent2v2_integration_report.json", "04_spec_grounding_report.json",
        "04_spec_grounded_assertion_plan.json", "04_harness_assumption_traceability.csv",
        "05_spec_grounding_review.json", "05_assumption_evidence_review.csv",
        "05_assertion_algorithm_alignment.csv", "05_symbol_uncertainty_review.json",
    ]
    return {name: (run_dir / name).exists() for name in files}


def extract_algorithm_items(v2: Dict[str, Any]) -> List[Dict[str, Any]]:
    data = v2.get("algorithm_blocks", {})
    raw = iter_dict_items(data, ["algorithm_blocks", "algorithms", "blocks", "items"])
    out: List[Dict[str, Any]] = []
    for idx, item in enumerate(raw, start=1):
        if isinstance(item, dict):
            text = item.get("text") or item.get("body") or item.get("algorithm_text") or item.get("raw") or flatten_text(item)
            steps = as_list(item.get("steps")) + as_list(item.get("operations")) + as_list(item.get("assignments"))
            io_text = flatten_text([item.get("inputs"), item.get("outputs"), item.get("input"), item.get("output")])
            has_io = bool(io_text.strip()) or bool(re.search(r"\b(input|output|return)\b", flatten_text(item), re.I))
            has_assignment = bool(steps) or bool(re.search(r"(<-|←|:=|=)", str(text)))
            has_loop = bool(re.search(r"\b(for|while|repeat|for each)\b", str(text), re.I))
            has_evidence = bool(item.get("evidence") or item.get("source") or item.get("start_line") or item.get("section"))
            name = str(item.get("name") or item.get("algorithm_name") or item.get("id") or f"algorithm_{idx}")
        else:
            text = str(item)
            has_io = bool(re.search(r"\b(input|output|return)\b", text, re.I))
            has_assignment = bool(re.search(r"(<-|←|:=|=)", text))
            has_loop = bool(re.search(r"\b(for|while|repeat|for each)\b", text, re.I))
            has_evidence = False
            name = f"algorithm_{idx}"
        out.append({
            "algorithm_id": name,
            "has_text": bool(str(text).strip()),
            "has_steps_or_assignments": has_assignment,
            "has_input_output": has_io,
            "has_loop_or_range": has_loop,
            "has_source_evidence": has_evidence,
            "review_required": text_contains_human_review_marker(item),
            "text_preview": str(text)[:240],
        })
    return out


def extract_symbol_items(v2: Dict[str, Any]) -> List[Dict[str, Any]]:
    data = v2.get("symbol_table", {})
    raw = iter_dict_items(data, ["symbols", "entries", "items", "rows"])
    if isinstance(data, dict) and not raw:
        for key, value in data.items():
            if str(key).startswith("_"):
                continue
            if isinstance(value, dict):
                row = dict(value)
                row.setdefault("symbol", key)
                raw.append(row)
            else:
                raw.append({"symbol": key, "meaning": value})
    out: List[Dict[str, Any]] = []
    for idx, item in enumerate(raw, start=1):
        if isinstance(item, dict):
            symbol = str(item.get("symbol") or item.get("name") or item.get("id") or f"symbol_{idx}")
            meaning = item.get("meaning") or item.get("description") or item.get("text") or item.get("role")
            value = item.get("value")
            confidence = numeric_confidence(item.get("confidence") or item.get("confidence_score") or item.get("certainty"))
            has_evidence = bool(item.get("evidence") or item.get("source") or item.get("start_line") or item.get("section"))
            review_required = bool(item.get("human_review_required")) or text_contains_human_review_marker(item)
        else:
            symbol = str(item)
            meaning = ""
            value = None
            confidence = None
            has_evidence = False
            review_required = False
        out.append({
            "symbol": symbol,
            "meaning_present": bool(str(meaning or "").strip()),
            "value": value,
            "confidence": confidence,
            "has_source_evidence": has_evidence,
            "human_review_required": review_required,
        })
    return out


def extract_parameter_items(v2: Dict[str, Any], spec_json: Dict[str, Any]) -> List[Dict[str, Any]]:
    data = v2.get("parameter_table", {})
    raw = iter_dict_items(data, ["parameters", "constants", "rows", "items", "entries"])
    constants = safe_get(spec_json, ["constants"], {})
    if isinstance(constants, dict):
        for name, value in constants.items():
            if isinstance(value, dict):
                row = dict(value)
                row.setdefault("name", name)
                row.setdefault("source", "01_spec_summary.json")
                raw.append(row)
            else:
                raw.append({"name": name, "value": value, "source": "01_spec_summary.json"})

    out: List[Dict[str, Any]] = []
    seen = set()
    for idx, item in enumerate(raw, start=1):
        if isinstance(item, dict):
            name = str(item.get("name") or item.get("symbol") or item.get("parameter") or item.get("id") or f"parameter_{idx}")
            value = item.get("value")
            confidence = numeric_confidence(item.get("confidence") or item.get("confidence_score") or item.get("certainty"))
            has_evidence = bool(item.get("evidence") or item.get("source") or item.get("start_line") or item.get("section"))
            review_required = bool(item.get("human_review_required")) or text_contains_human_review_marker(item)
        else:
            name = str(item)
            value = None
            confidence = None
            has_evidence = False
            review_required = False
        key = (name, str(value))
        if key in seen:
            continue
        seen.add(key)
        if confidence is None:
            if value not in (None, "") and has_evidence:
                confidence = 0.8
            elif value not in (None, ""):
                confidence = 0.6
            else:
                confidence = 0.25
        out.append({
            "parameter": name,
            "value": value,
            "confidence": confidence,
            "has_source_evidence": has_evidence,
            "human_review_required": review_required,
        })
    return out


def collect_spec_claims_for_human_review(spec_json: Dict[str, Any], v2: Dict[str, Any]) -> List[Dict[str, Any]]:
    claims: List[Dict[str, Any]] = []
    for source_name, bucket in [
        ("01_spec_summary.json", "input_assumptions"),
        ("01_spec_summary.json", "candidate_output_guarantees"),
        ("01_spec_summary.json", "candidate_safety_properties"),
        ("01_spec_summary.json", "candidate_functional_properties"),
        ("01_spec_summary.json", "uncertainties"),
    ]:
        for idx, item in enumerate(as_list(spec_json.get(bucket)), start=1):
            claims.append({
                "claim_id": f"{bucket}_{idx}",
                "source_file": source_name,
                "claim_type": bucket,
                "text": flatten_text(item)[:500],
                "has_evidence": bool(isinstance(item, dict) and (item.get("evidence") or item.get("source") or item.get("start_line"))),
                "human_review_required": bool(isinstance(item, dict) and item.get("human_review_required")) or text_contains_human_review_marker(item),
            })

    for source_name, key in [
        ("01_equations_constraints.json", "equations_constraints"),
        ("01_preconditions_postconditions.json", "preconditions_postconditions"),
        ("01_spec_to_code_hints.json", "spec_to_code_hints"),
    ]:
        for idx, item in enumerate(iter_dict_items(v2.get(key, {})), start=1):
            claims.append({
                "claim_id": f"{key}_{idx}",
                "source_file": source_name,
                "claim_type": key,
                "text": flatten_text(item)[:500],
                "has_evidence": bool(isinstance(item, dict) and (item.get("evidence") or item.get("source") or item.get("start_line") or item.get("section"))),
                "human_review_required": bool(isinstance(item, dict) and item.get("human_review_required")) or text_contains_human_review_marker(item),
            })

    uncertainty_review = v2.get("symbol_uncertainty_review", {})
    if isinstance(uncertainty_review, dict) and uncertainty_review:
        claims.append({
            "claim_id": "critic_symbol_uncertainty_review",
            "source_file": "05_symbol_uncertainty_review.json",
            "claim_type": "critic_uncertainty_review",
            "text": flatten_text(uncertainty_review)[:500],
            "has_evidence": True,
            "human_review_required": True,
        })
    return claims


def evaluate_spec_parsing_quality(run_dir: Path, spec_json: Dict[str, Any], v2: Dict[str, Any]) -> Dict[str, Any]:
    presence = v2_file_presence(run_dir)
    agent2_core = [
        "selected_spec_excerpt.txt", "01_algorithm_blocks.json", "01_symbol_table.json",
        "01_parameter_table.json", "01_equations_constraints.json",
        "01_preconditions_postconditions.json", "01_spec_to_code_hints.json",
    ]
    present_core = [name for name in agent2_core if presence.get(name)]
    algorithms = extract_algorithm_items(v2)
    symbols = extract_symbol_items(v2)
    parameters = extract_parameter_items(v2, spec_json)
    claims = collect_spec_claims_for_human_review(spec_json, v2)

    algorithm_quality = 0.0
    if algorithms:
        components = [
            sum(1 for a in algorithms if a["has_text"]) / len(algorithms),
            sum(1 for a in algorithms if a["has_steps_or_assignments"]) / len(algorithms),
            sum(1 for a in algorithms if a["has_input_output"]) / len(algorithms),
            sum(1 for a in algorithms if a["has_source_evidence"]) / len(algorithms),
        ]
        algorithm_quality = round(sum(components) / len(components), 3)

    symbol_quality = 0.0
    if symbols:
        symbol_quality = round((
            sum(1 for s in symbols if s["meaning_present"]) / len(symbols) +
            sum(1 for s in symbols if s["has_source_evidence"]) / len(symbols)
        ) / 2, 3)

    parameter_quality = 0.0
    avg_confidence = 0.0
    if parameters:
        avg_confidence = round(sum(float(p.get("confidence") or 0) for p in parameters) / len(parameters), 3)
        evidence_ratio = sum(1 for p in parameters if p["has_source_evidence"]) / len(parameters)
        parameter_quality = round((avg_confidence + evidence_ratio) / 2, 3)

    reviewed_claims = [c for c in claims if c["human_review_required"] or c["has_evidence"]]
    human_review_coverage = round(len(reviewed_claims) / len(claims), 3) if claims else 0.0
    core_file_coverage = len(present_core) / len(agent2_core)

    overall = round((
        0.25 * core_file_coverage +
        0.20 * algorithm_quality +
        0.15 * symbol_quality +
        0.20 * parameter_quality +
        0.20 * human_review_coverage
    ), 3)

    if overall >= 0.80:
        level = "strong"
    elif overall >= 0.60:
        level = "moderate"
    elif overall >= 0.35:
        level = "weak_but_useful"
    else:
        level = "insufficient_or_legacy_run"

    return {
        "schema_version": "1.0",
        "overall_spec_parsing_quality_score_0_to_1": overall,
        "level": level,
        "agent2_v2_core_file_coverage": {
            "present": len(present_core),
            "total": len(agent2_core),
            "ratio": round(core_file_coverage, 3),
            "present_files": present_core,
            "missing_files": [name for name in agent2_core if name not in present_core],
        },
        "algorithm_extraction": {"count": len(algorithms), "quality_score_0_to_1": algorithm_quality, "items": algorithms},
        "symbol_extraction": {"count": len(symbols), "quality_score_0_to_1": symbol_quality, "items": symbols},
        "parameter_extraction": {"count": len(parameters), "average_confidence_0_to_1": avg_confidence, "quality_score_0_to_1": parameter_quality, "items": parameters},
        "spec_claim_human_review_status": {"claim_count": len(claims), "review_or_evidence_coverage_0_to_1": human_review_coverage, "items": claims},
        "file_presence": presence,
        "interpretation": "This evaluates whether Agent 2 v2 produced usable, traceable structured parsing evidence. It does not certify that parsing is flawless; it measures coverage, evidence, confidence, and human-review visibility.",
    }


def score_from_v2_metric(name: str, score_0_to_1: float, rationale_good: str, rationale_weak: str, evidence: List[str]) -> CriterionScore:
    if score_0_to_1 >= 0.80:
        score = 5
        rationale = rationale_good
    elif score_0_to_1 >= 0.60:
        score = 4
        rationale = rationale_good + " Some review is still needed."
    elif score_0_to_1 >= 0.35:
        score = 3
        rationale = rationale_weak + " Still useful as partial evidence."
    elif score_0_to_1 > 0:
        score = 2
        rationale = rationale_weak
    else:
        score = 1
        rationale = "No usable evidence was found for this v2 evaluation dimension."
    return CriterionScore(name, score, 5, level_from_score(score), rationale, evidence)


def build_v2_quality_scores(spec_parsing_eval: Dict[str, Any]) -> List[CriterionScore]:
    alg = spec_parsing_eval.get("algorithm_extraction", {})
    sym = spec_parsing_eval.get("symbol_extraction", {})
    param = spec_parsing_eval.get("parameter_extraction", {})
    review = spec_parsing_eval.get("spec_claim_human_review_status", {})
    overall = float(spec_parsing_eval.get("overall_spec_parsing_quality_score_0_to_1", 0) or 0)
    return [
        score_from_v2_metric("spec_parsing_quality", overall, "Agent 2 v2 produced traceable structured parsing evidence across the selected spec material.", "Spec parsing evidence is incomplete or mostly legacy-mode.", [f"Overall v2 spec parsing score: {overall}", f"Agent 2 v2 core file coverage: {safe_get(spec_parsing_eval, ['agent2_v2_core_file_coverage', 'ratio'], 0)}"]),
        score_from_v2_metric("algorithm_extraction_coverage", float(alg.get("quality_score_0_to_1", 0) or 0), "Algorithm blocks include useful structure such as steps, assignments, I/O, and evidence.", "Algorithm extraction coverage is limited.", [f"Algorithm blocks: {alg.get('count', 0)}", f"Quality: {alg.get('quality_score_0_to_1', 0)}"]),
        score_from_v2_metric("symbol_extraction_coverage", float(sym.get("quality_score_0_to_1", 0) or 0), "Symbol extraction includes meanings and evidence for parsed spec symbols.", "Symbol extraction lacks enough meaning/evidence.", [f"Symbols: {sym.get('count', 0)}", f"Quality: {sym.get('quality_score_0_to_1', 0)}"]),
        score_from_v2_metric("parameter_extraction_confidence", float(param.get("quality_score_0_to_1", 0) or 0), "Parameter extraction includes values, confidence, and evidence.", "Parameter extraction confidence/evidence is limited.", [f"Parameters: {param.get('count', 0)}", f"Average confidence: {param.get('average_confidence_0_to_1', 0)}"]),
        score_from_v2_metric("spec_claim_human_review_status", float(review.get("review_or_evidence_coverage_0_to_1", 0) or 0), "Extracted spec claims include evidence and/or explicit human-review status.", "Extracted spec claims are not sufficiently review-visible.", [f"Claims: {review.get('claim_count', 0)}", f"Coverage: {review.get('review_or_evidence_coverage_0_to_1', 0)}"]),
    ]



# ---------------------------------------------------------------------------
# Scoring
# ---------------------------------------------------------------------------

def score_correctness(cbmc_status: str, highest_sev: str, critic_issues: List[Dict[str, Any]]) -> CriterionScore:
    evidence = [f"CBMC status: {cbmc_status}", f"Highest critic severity: {highest_sev}"]

    if highest_sev == "critical":
        score = 1
        rationale = "Critical critic issue means the artifact is not scientifically reliable yet."
    elif cbmc_status == "passed":
        score = 4
        rationale = "Selected CBMC checks passed, but this does not prove full implementation correctness."
    elif cbmc_status == "failed":
        score = 3
        rationale = "Failure can still be useful if it exposes a property, assumption, or harness issue."
    elif cbmc_status in {"tool_unavailable", "tool_error", "timeout"}:
        score = 2
        rationale = "Tool result was not conclusive, so correctness cannot be established for selected properties."
    else:
        score = 2
        rationale = "Correctness evidence is incomplete."

    if highest_sev == "high":
        score = min(score, 2)
        rationale += " High-severity critic findings limit confidence."

    return CriterionScore("correctness", score, 5, level_from_score(score), rationale, evidence)


def score_tool_compatibility(cbmc_status: str, cbmc_output: str, command_text: str) -> CriterionScore:
    evidence = []
    if command_text.strip():
        evidence.append("CBMC command recorded.")
    if cbmc_output.strip():
        evidence.append("CBMC output recorded.")
    evidence.append(f"Tool status: {cbmc_status}")

    if cbmc_status in {"passed", "failed"}:
        score = 5
        rationale = "The formal tool ran and produced a verification result."
    elif cbmc_status == "timeout":
        score = 3
        rationale = "The tool started but did not complete within the configured time."
    elif cbmc_status == "tool_unavailable":
        score = 2
        rationale = "The workflow handled missing CBMC safely, but no formal check was run."
    elif cbmc_status == "tool_error":
        score = 2
        rationale = "The tool command or artifact needs compatibility repair."
    else:
        score = 1
        rationale = "Tool compatibility evidence is missing or unknown."

    return CriterionScore("tool_compatibility", score, 5, level_from_score(score), rationale, evidence)


def score_spec_relevance(properties: List[Dict[str, Any]], spec_json: Dict[str, Any]) -> CriterionScore:
    constants = safe_get(spec_json, ["constants"], {})
    assumptions = safe_get(spec_json, ["input_assumptions"], [])
    guarantees = safe_get(spec_json, ["candidate_output_guarantees"], [])
    evidence = [
        f"Candidate properties: {len(properties)}",
        f"Extracted constants: {len(constants) if isinstance(constants, dict) else 0}",
        f"Input assumptions: {len(as_list(assumptions))}",
        f"Output guarantees: {len(as_list(guarantees))}",
    ]

    if len(properties) >= 3 and (constants or assumptions or guarantees):
        score = 4
        rationale = "Properties are connected to extracted specification information."
    elif properties:
        score = 3
        rationale = "Properties exist, but specification grounding is partial."
    else:
        score = 1
        rationale = "No candidate properties were available for evaluation."

    uncertainties = as_list(safe_get(spec_json, ["uncertainties"], []))
    if len(uncertainties) > 5:
        score = max(1, score - 1)
        rationale += " Many specification uncertainties reduce confidence."

    return CriterionScore("specification_relevance", score, 5, level_from_score(score), rationale, evidence)


def score_code_relevance(code_json: Dict[str, Any], manifest: Dict[str, Any], target_function: str) -> CriterionScore:
    detected_fn = (
        safe_get(code_json, ["function"])
        or safe_get(code_json, ["target_function"])
        or safe_get(code_json, ["function_name"])
        or ""
    )
    calls = safe_get(manifest, ["target_function_call"], "") or safe_get(manifest, ["target_function"], "")
    arrays = as_list(safe_get(code_json, ["array_accesses"], []))
    loops = as_list(safe_get(code_json, ["loops"], []))
    evidence = [
        f"Configured target function: {target_function}",
        f"Detected function: {detected_fn}",
        f"Harness/manifest target call: {calls}",
        f"Array accesses detected: {len(arrays)}",
        f"Loops detected: {len(loops)}",
    ]

    function_match = target_function and (target_function in str(detected_fn) or target_function in str(calls))
    if function_match and (arrays or loops):
        score = 5
        rationale = "The artifact is strongly connected to the selected implementation behavior."
    elif function_match:
        score = 4
        rationale = "The artifact targets the correct function, but code-structure evidence is limited."
    elif detected_fn or calls:
        score = 2
        rationale = "Some function evidence exists, but target-function alignment is uncertain."
    else:
        score = 1
        rationale = "The selected code target could not be confirmed."

    return CriterionScore("code_relevance", score, 5, level_from_score(score), rationale, evidence)


def score_assumption_quality(harness_text: str, critic_issues: List[Dict[str, Any]], spec_json: Dict[str, Any]) -> CriterionScore:
    assume_count = count_regex(r"\b__CPROVER_assume\s*\(", harness_text)
    assumption_lines = [line.strip() for line in harness_text.splitlines() if "__CPROVER_assume" in line]
    unsupported = [
        i for i in critic_issues
        if "assumption" in str(i.get("type", "")).lower()
        or "assumption" in str(i.get("message", "")).lower()
    ]
    spec_assumptions = as_list(safe_get(spec_json, ["input_assumptions"], []))

    evidence = [
        f"CBMC assumptions in harness: {assume_count}",
        f"Spec assumptions extracted: {len(spec_assumptions)}",
        f"Critic assumption concerns: {len(unsupported)}",
    ]

    if assume_count == 0:
        score = 2
        rationale = "No explicit CBMC assumptions were found; the harness may be too unconstrained."
    elif unsupported:
        max_sev = highest_severity(unsupported)
        score = 2 if max_sev in {"high", "critical"} else 3
        rationale = "Some assumptions need stronger justification or repair."
    elif spec_assumptions:
        score = 4
        rationale = "Assumptions exist and appear connected to extracted specification assumptions."
    else:
        score = 3
        rationale = "Assumptions exist, but explicit specification justification is limited."

    if any("candidate" in line.lower() or "human" in line.lower() for line in assumption_lines):
        evidence.append("Harness marks some assumptions as candidate/human-review items.")
        score = max(score, 3)

    return CriterionScore("assumption_quality", score, 5, level_from_score(score), rationale, evidence)


def score_assertion_quality(harness_text: str, critic_issues: List[Dict[str, Any]]) -> CriterionScore:
    assert_count = count_regex(r"\bassert\s*\(", harness_text)
    risky = [
        i for i in critic_issues
        if "assert" in str(i.get("type", "")).lower()
        or "assert" in str(i.get("message", "")).lower()
        or "trivial" in str(i.get("message", "")).lower()
    ]
    evidence = [
        f"Assertions in harness: {assert_count}",
        f"Critic assertion concerns: {len(risky)}",
    ]

    if assert_count == 0:
        score = 1
        rationale = "No assertions were found; the harness does not check a meaningful property yet."
    elif risky:
        max_sev = highest_severity(risky)
        score = 2 if max_sev in {"critical", "high"} else 3
        rationale = "Assertions exist but critic identified possible weakness or over-strength."
    elif assert_count >= 2:
        score = 4
        rationale = "Multiple assertions exist with no major critic concern."
    else:
        score = 3
        rationale = "At least one checkable assertion exists."

    return CriterionScore("assertion_quality", score, 5, level_from_score(score), rationale, evidence)


def score_failure_usefulness(cbmc_status: str, analysis_json: Dict[str, Any]) -> CriterionScore:
    categories = as_list(safe_get(analysis_json, ["failure_categories"], []))
    failure_type = safe_get(analysis_json, ["failure_type"])
    suggested = as_list(safe_get(analysis_json, ["suggested_fix"], [])) + as_list(
        safe_get(analysis_json, ["repair_guidance"], [])
    )

    evidence = [
        f"CBMC status: {cbmc_status}",
        f"Failure type: {failure_type or 'none'}",
        f"Failure categories: {len(categories)}",
        f"Suggested fixes: {len(suggested)}",
    ]

    if cbmc_status == "failed" and (categories or failure_type) and suggested:
        score = 5
        rationale = "Failure was classified and produced actionable repair guidance."
    elif cbmc_status == "failed" and (categories or failure_type):
        score = 4
        rationale = "Failure was classified, but repair guidance is limited."
    elif cbmc_status == "passed":
        score = 3
        rationale = "No failure to analyze; usefulness comes from success evidence rather than counterexample learning."
    elif cbmc_status in {"tool_unavailable", "tool_error", "timeout"}:
        score = 3
        rationale = "Tool issue is still useful for workflow debugging and reproducibility."
    else:
        score = 2
        rationale = "Failure usefulness evidence is incomplete."

    return CriterionScore("failure_usefulness", score, 5, level_from_score(score), rationale, evidence)


def score_human_correction_effort(repair_json: Dict[str, Any], critic_issues: List[Dict[str, Any]], cbmc_status: str) -> CriterionScore:
    changes = as_list(safe_get(repair_json, ["changes_made"], []))
    repair_status = safe_get(repair_json, ["repair_status"]) or safe_get(repair_json, ["status"])
    high_issues = [i for i in critic_issues if str(i.get("severity", "")).lower() in {"critical", "high"}]

    evidence = [
        f"Repair status: {repair_status or 'not_recorded'}",
        f"Repair changes recorded: {len(changes)}",
        f"High/critical critic issues: {len(high_issues)}",
        f"CBMC status: {cbmc_status}",
    ]

    if high_issues:
        score = 2
        rationale = "High-severity findings indicate significant human review/correction is likely needed."
    elif changes:
        score = 3
        rationale = "Automated repair made changes, but human review is still required."
    elif cbmc_status == "passed":
        score = 4
        rationale = "Selected checks passed without recorded repair, but human validation of assumptions remains necessary."
    else:
        score = 3
        rationale = "Human correction effort appears moderate or not fully known."

    return CriterionScore("human_correction_effort", score, 5, level_from_score(score), rationale, evidence)


def score_reproducibility(run_dir: Path) -> CriterionScore:
    present = [name for name in EXPECTED_RUN_FILES if (run_dir / name).exists()]
    missing = [name for name in EXPECTED_RUN_FILES if not (run_dir / name).exists()]
    has_events = (run_dir / "events.jsonl").exists()
    has_prompts = (run_dir / "llm_prompts").exists()
    has_status = (run_dir / "agent_status").exists()
    has_logger = (run_dir / "09_experiment_log.json").exists()

    evidence = [
        f"Expected files present: {len(present)}/{len(EXPECTED_RUN_FILES)}",
        f"Events log present: {has_events}",
        f"Prompt directory present: {has_prompts}",
        f"Agent status directory present: {has_status}",
        f"Experiment log present: {has_logger}",
    ]

    ratio = len(present) / len(EXPECTED_RUN_FILES)
    if ratio >= 0.85 and has_events and has_prompts and has_status:
        score = 5
        rationale = "Run is highly reproducible with files, prompts, statuses, and events recorded."
    elif ratio >= 0.65 and (has_events or has_logger):
        score = 4
        rationale = "Run has strong reproducibility evidence, with some missing files."
    elif ratio >= 0.4:
        score = 3
        rationale = "Run has partial reproducibility evidence."
    else:
        score = 2
        rationale = "Important reproducibility artifacts are missing."

    if missing:
        evidence.append("Missing: " + ", ".join(missing[:12]))

    return CriterionScore("reproducibility", score, 5, level_from_score(score), rationale, evidence)


def level_from_score(score: int) -> str:
    if score >= 5:
        return "excellent"
    if score == 4:
        return "good"
    if score == 3:
        return "moderate"
    if score == 2:
        return "weak"
    return "poor"


def calculate_scores(
    run_dir: Path,
    metadata: Dict[str, str],
    spec_json: Dict[str, Any],
    code_json: Dict[str, Any],
    properties_json: Dict[str, Any],
    manifest_json: Dict[str, Any],
    critic_json: Dict[str, Any],
    cbmc_status_json: Dict[str, Any],
    cbmc_output: str,
    cbmc_command: str,
    analysis_json: Dict[str, Any],
    repair_json: Dict[str, Any],
    harness_text: str,
    spec_parsing_eval: Optional[Dict[str, Any]] = None,
) -> List[CriterionScore]:
    properties = extract_candidate_properties(properties_json)
    issues = collect_critic_issues(critic_json)
    high = highest_severity(issues)
    cbmc_status = status_from_cbmc(cbmc_status_json)

    scores = [
        score_correctness(cbmc_status, high, issues),
        score_tool_compatibility(cbmc_status, cbmc_output, cbmc_command),
        score_spec_relevance(properties, spec_json),
        score_code_relevance(code_json, manifest_json, metadata["target_function"]),
        score_assumption_quality(harness_text, issues, spec_json),
        score_assertion_quality(harness_text, issues),
        score_failure_usefulness(cbmc_status, analysis_json),
        score_human_correction_effort(repair_json, issues, cbmc_status),
        score_reproducibility(run_dir),
    ]
    if spec_parsing_eval is not None:
        scores.extend(build_v2_quality_scores(spec_parsing_eval))
    return scores


# ---------------------------------------------------------------------------
# Tables and reports
# ---------------------------------------------------------------------------

def build_property_evaluations(
    properties_json: Dict[str, Any],
    manifest_json: Dict[str, Any],
    critic_json: Dict[str, Any],
    property_results_json: Any,
    harness_text: str,
) -> List[PropertyEvaluation]:
    properties = extract_candidate_properties(properties_json)
    selected_ids = set(extract_selected_properties(manifest_json, properties_json))
    failed_props = set(cbmc_failed_properties(property_results_json))
    issues = collect_critic_issues(critic_json)

    out: List[PropertyEvaluation] = []
    for idx, prop in enumerate(properties, start=1):
        pid = str(prop.get("id") or prop.get("property_id") or f"P{idx}")
        ptype = str(prop.get("type") or "unknown")
        desc = str(prop.get("description") or prop.get("text") or "")
        priority = str(prop.get("priority") or "unknown")

        selected = pid in selected_ids or not selected_ids and idx <= 4
        evidence = find_property_evidence_in_harness(prop, harness_text)
        cbmc_status = "failed" if pid in failed_props else "not_failed_or_not_individually_reported"

        related_concerns: List[str] = []
        for issue in issues:
            msg = str(issue.get("message") or issue.get("description") or "")
            itype = str(issue.get("type") or "")
            if pid.lower() in msg.lower() or ptype.lower() in msg.lower() or ptype.lower() in itype.lower():
                related_concerns.append(msg[:300])

        if selected and evidence and not related_concerns:
            note = "Selected and appears represented in the generated harness."
        elif selected and not evidence:
            note = "Selected, but direct harness evidence is weak or not detected."
        elif related_concerns:
            note = "Critic raised concerns related to this property."
        else:
            note = "Candidate property retained for possible future harness refinement."

        out.append(PropertyEvaluation(
            property_id=pid,
            property_type=ptype,
            description=desc,
            priority=priority,
            selected_for_harness=selected,
            evidence_in_harness=evidence,
            cbmc_status=cbmc_status,
            critic_concerns=related_concerns,
            evaluation_note=note,
        ))

    return out


def build_failure_taxonomy(
    critic_json: Dict[str, Any],
    cbmc_status_json: Dict[str, Any],
    cbmc_output: str,
    analysis_json: Dict[str, Any],
    repair_json: Dict[str, Any],
) -> List[FailureTaxonomyItem]:
    items: List[FailureTaxonomyItem] = []

    for issue in collect_critic_issues(critic_json):
        category = str(issue.get("type") or "critic_issue")
        severity = str(issue.get("severity") or "unknown")
        message = str(issue.get("message") or issue.get("description") or "")
        fix = issue.get("recommended_fix") or issue.get("recommendation") or "Review and repair before relying on the artifact."
        items.append(FailureTaxonomyItem(
            category=category,
            severity=severity,
            source_agent="review_critic_agent",
            evidence=message[:500],
            likely_meaning="The generated artifact may be weak, unsupported, too strong, or disconnected from the intended property.",
            recommended_action=str(fix)[:500],
        ))

    cbmc_status = status_from_cbmc(cbmc_status_json)
    if cbmc_status in {"tool_error", "tool_unavailable", "timeout"}:
        items.append(FailureTaxonomyItem(
            category=cbmc_status,
            severity="high" if cbmc_status == "tool_error" else "medium",
            source_agent="tool_execution_agent",
            evidence=(safe_get(cbmc_status_json, ["message"]) or cbmc_output[:500] or cbmc_status),
            likely_meaning="The formal tool did not produce a conclusive selected-property verification result.",
            recommended_action="Fix tool installation/command/artifact compatibility and rerun Agent 7.",
        ))

    failure_type = safe_get(analysis_json, ["failure_type"])
    explanation = safe_get(analysis_json, ["explanation"]) or safe_get(analysis_json, ["summary"])
    if failure_type or explanation:
        items.append(FailureTaxonomyItem(
            category=str(failure_type or "counterexample_analysis"),
            severity=str(safe_get(analysis_json, ["severity"]) or "medium"),
            source_agent="counterexample_analysis_agent",
            evidence=str(explanation or "")[:500],
            likely_meaning=str(safe_get(analysis_json, ["likely_cause"]) or "Failure needs interpretation before claiming code or artifact defect.")[:500],
            recommended_action=", ".join(str(x) for x in as_list(safe_get(analysis_json, ["suggested_fix"], []))[:5]) or
                               "Use analysis output to guide repair.",
        ))

    repair_status = safe_get(repair_json, ["repair_status"]) or safe_get(repair_json, ["status"])
    if repair_status and str(repair_status).lower() not in {"success", "completed", "repaired"}:
        items.append(FailureTaxonomyItem(
            category="repair_limitation",
            severity="medium",
            source_agent="repair_agent",
            evidence=str(repair_status),
            likely_meaning="Automated repair was limited or incomplete.",
            recommended_action="Inspect repair notes and perform human-guided correction.",
        ))

    # Deduplicate simple exact evidence/category pairs.
    seen = set()
    unique: List[FailureTaxonomyItem] = []
    for item in items:
        key = (item.category, item.source_agent, item.evidence[:100])
        if key not in seen:
            unique.append(item)
            seen.add(key)
    return unique


def build_run_summary(
    metadata: Dict[str, str],
    scores: List[CriterionScore],
    critic_json: Dict[str, Any],
    cbmc_status_json: Dict[str, Any],
    repair_json: Dict[str, Any],
) -> RunSummary:
    issues = collect_critic_issues(critic_json)
    high = highest_severity(issues)
    cbmc_status = status_from_cbmc(cbmc_status_json)
    score_percent = round(sum(s.score for s in scores) / (len(scores) * 5) * 100, 2) if scores else 0.0
    usefulness = classify_overall_usefulness(score_percent, cbmc_status, high)
    repair_attempted = bool(repair_json and not repair_json.get("_json_error"))

    if high == "critical":
        final = "needs_major_revision"
    elif cbmc_status == "passed" and high not in {"critical", "high"}:
        final = "selected_properties_passed_with_review_required"
    elif cbmc_status == "failed":
        final = "verification_failed_but_analysis_available"
    elif cbmc_status in {"tool_unavailable", "tool_error", "timeout"}:
        final = "tool_execution_incomplete"
    else:
        final = "inconclusive"

    return RunSummary(
        run_id=metadata["run_id"],
        target_scheme=metadata["target_scheme"],
        target_function=metadata["target_function"],
        verification_tool=metadata["verification_tool"],
        artifact_type=metadata["artifact_type"],
        final_status=final,
        cbmc_status=cbmc_status,
        highest_critic_severity=high,
        repair_attempted=repair_attempted,
        human_review_required=True,
        overall_usefulness=usefulness,
        overall_score_percent=score_percent,
    )


def build_harness_metrics(harness_text: str) -> Dict[str, Any]:
    return {
        "line_count": len(harness_text.splitlines()),
        "assert_count": count_regex(r"\bassert\s*\(", harness_text),
        "assume_count": count_regex(r"\b__CPROVER_assume\s*\(", harness_text),
        "nondet_count": len(re.findall(r"\bnondet_[A-Za-z0-9_]+\s*\(", harness_text)),
        "loop_count": count_regex(r"\bfor\s*\(|\bwhile\s*\(", harness_text),
        "includes": re.findall(r"^\s*#\s*include\s+[<\"].+[>\"]", harness_text, flags=re.MULTILINE),
        "has_guardrail_comment": "candidate" in harness_text.lower() or "human review" in harness_text.lower(),
    }


def write_csv(path: Path, rows: List[Dict[str, Any]], fieldnames: Optional[List[str]] = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if fieldnames is None:
        keys: List[str] = []
        for row in rows:
            for k in row.keys():
                if k not in keys:
                    keys.append(k)
        fieldnames = keys
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: stringify_csv(row.get(k, "")) for k in fieldnames})


def stringify_csv(value: Any) -> str:
    if isinstance(value, (list, dict)):
        return json.dumps(value, ensure_ascii=False)
    return "" if value is None else str(value)


def render_spec_parsing_markdown(spec_parsing_eval: Optional[Dict[str, Any]]) -> str:
    if not spec_parsing_eval:
        return "_No v2 spec-parsing evaluation was available._"
    core = spec_parsing_eval.get("agent2_v2_core_file_coverage", {})
    alg = spec_parsing_eval.get("algorithm_extraction", {})
    sym = spec_parsing_eval.get("symbol_extraction", {})
    param = spec_parsing_eval.get("parameter_extraction", {})
    review = spec_parsing_eval.get("spec_claim_human_review_status", {})
    return f"""| Metric | Value |
|---|---:|
| Overall spec parsing quality | `{spec_parsing_eval.get('overall_spec_parsing_quality_score_0_to_1')}` |
| Level | `{spec_parsing_eval.get('level')}` |
| Agent 2 v2 core file coverage | `{core.get('present')}` / `{core.get('total')}` |
| Algorithm blocks extracted | `{alg.get('count')}` |
| Algorithm extraction quality | `{alg.get('quality_score_0_to_1')}` |
| Symbols extracted | `{sym.get('count')}` |
| Symbol extraction quality | `{sym.get('quality_score_0_to_1')}` |
| Parameters extracted | `{param.get('count')}` |
| Average parameter confidence | `{param.get('average_confidence_0_to_1')}` |
| Spec claims tracked for review | `{review.get('claim_count')}` |
| Review/evidence coverage | `{review.get('review_or_evidence_coverage_0_to_1')}` |

Interpretation: {spec_parsing_eval.get('interpretation')}
"""


def render_markdown_report(
    summary: RunSummary,
    scores: List[CriterionScore],
    property_evals: List[PropertyEvaluation],
    taxonomy: List[FailureTaxonomyItem],
    harness_metrics: Dict[str, Any],
    missing_files: List[str],
    human_notes: str,
    spec_parsing_eval: Optional[Dict[str, Any]] = None,
) -> str:
    score_table = "\n".join(
        f"| {s.criterion} | {s.score}/5 | {s.level} | {s.rationale} |"
        for s in scores
    )

    prop_rows = "\n".join(
        f"| {p.property_id} | {p.property_type} | {p.priority} | "
        f"{'yes' if p.selected_for_harness else 'no'} | "
        f"{'yes' if p.evidence_in_harness else 'no'} | {p.cbmc_status} | {p.evaluation_note} |"
        for p in property_evals
    ) or "| - | - | - | - | - | - | No candidate properties found. |"

    tax_rows = "\n".join(
        f"| {t.category} | {t.severity} | {t.source_agent} | {t.likely_meaning} | {t.recommended_action} |"
        for t in taxonomy
    ) or "| - | - | - | No failures or concerns were recorded. | - |"

    missing = "\n".join(f"- `{m}`" for m in missing_files) or "- None from the expected list."

    notes_section = human_notes.strip() if human_notes.strip() else "_No human notes have been added yet._"

    return f"""# Evaluation and Reporting Agent Final Report

Generated: `{utc_now_iso()}`

## Scientific Guardrail

{SCIENTIFIC_GUARDRAIL}

## Run Summary

| Field | Value |
|---|---|
| Run ID | `{summary.run_id}` |
| Target scheme | `{summary.target_scheme}` |
| Target function | `{summary.target_function}` |
| Verification tool | `{summary.verification_tool}` |
| Artifact type | `{summary.artifact_type}` |
| Final status | `{summary.final_status}` |
| CBMC status | `{summary.cbmc_status}` |
| Highest critic severity | `{summary.highest_critic_severity}` |
| Repair attempted | `{summary.repair_attempted}` |
| Human review required | `{summary.human_review_required}` |
| Overall usefulness | `{summary.overall_usefulness}` |
| Overall score | `{summary.overall_score_percent}%` |

## Quality Scorecard

| Criterion | Score | Level | Rationale |
|---|---:|---|---|
{score_table}

## Harness Metrics

| Metric | Value |
|---|---:|
| Lines | {harness_metrics.get("line_count", 0)} |
| Assertions | {harness_metrics.get("assert_count", 0)} |
| Assumptions | {harness_metrics.get("assume_count", 0)} |
| Nondeterministic calls | {harness_metrics.get("nondet_count", 0)} |
| Loops | {harness_metrics.get("loop_count", 0)} |
| Guardrail comment present | {harness_metrics.get("has_guardrail_comment", False)} |

## FIPS-Aware Specification Parsing Evaluation

{render_spec_parsing_markdown(spec_parsing_eval)}

## Property Coverage

| Property ID | Type | Priority | Selected | Evidence in harness | CBMC status | Note |
|---|---|---|---|---|---|---|
{prop_rows}

## Failure / Limitation Taxonomy

| Category | Severity | Source agent | Likely meaning | Recommended action |
|---|---|---|---|---|
{tax_rows}

## Missing Expected Run Files

{missing}

## Human Notes

{notes_section}

## Thesis-Safe Interpretation

This run should be described as an evaluation of an AI-assisted workflow for generating,
reviewing, testing, repairing, and logging candidate formal-verification artifacts. A pass from
CBMC means only that the selected CBMC harness and selected assertions passed under the
stated assumptions. It must not be written as a full proof of ML-KEM or the complete
implementation.

## Suggested Thesis Wording

The workflow generated candidate formal-verification artifacts for the selected implementation
component, reviewed them using a critic stage, checked them using the configured formal tool,
and logged the result for reproducibility. The evaluation considered tool compatibility,
property relevance, assumption quality, assertion quality, repair effort, and failure usefulness.
Human review remains necessary to judge whether the assumptions and checked properties are
scientifically meaningful.
"""


def render_human_review_checklist(summary: RunSummary, property_evals: List[PropertyEvaluation], taxonomy: List[FailureTaxonomyItem], spec_parsing_eval: Optional[Dict[str, Any]] = None) -> str:
    property_lines = "\n".join(
        f"- [ ] Review `{p.property_id}` ({p.property_type}): {p.description}"
        for p in property_evals[:30]
    ) or "- [ ] No properties were found; inspect Agent 4 output."

    taxonomy_lines = "\n".join(
        f"- [ ] Inspect `{t.category}` from `{t.source_agent}`: {t.recommended_action}"
        for t in taxonomy[:30]
    ) or "- [ ] No recorded failure taxonomy items."

    return f"""# Human Review Checklist

Run: `{summary.run_id}`
Target: `{summary.target_scheme}` / `{summary.target_function}`

## Mandatory Guardrail

- [ ] Confirm the thesis does not claim full automatic proof of ML-KEM.
- [ ] Confirm the report says artifacts are candidate formal-verification artifacts.
- [ ] Confirm CBMC results are interpreted only for selected harness/properties/assumptions.
- [ ] Confirm human review is explicitly stated as necessary.

## Specification Grounding

- [ ] Check that every assumption is supported by the selected specification excerpt or code context.
- [ ] Check that constants such as polynomial size and modulus are correct for the selected target.
- [ ] Check that unsupported assumptions are not silently used to make CBMC pass.
- [ ] Review Agent 2 v2 spec parsing quality score: `{safe_get(spec_parsing_eval or {}, ['overall_spec_parsing_quality_score_0_to_1'], 'not_available')}`.
- [ ] Review algorithm extraction coverage and confirm parsed algorithm steps match the selected FIPS/spec section.
- [ ] Review symbol extraction coverage and confirm symbols such as q, n, k, eta, du/dv are not misused.
- [ ] Review parameter extraction confidence and confirm numerical values are correct for the selected parameter set.
- [ ] Review human-review status for extracted spec claims.

## Code Grounding

- [ ] Check that the harness calls the correct target function.
- [ ] Check that pointer parameters are initialized safely.
- [ ] Check that all required headers/source files are included in the CBMC command.
- [ ] Check that loop unwinding matches the implementation loop bound.

## Properties

{property_lines}

## Failures / Limitations

{taxonomy_lines}

## Final Decision

- [ ] Accept this run as useful evidence.
- [ ] Accept only after manual correction.
- [ ] Reject this run from final evaluation.
- [ ] Rerun after repairing tool/harness/configuration issues.

Reviewer notes:

```text

```
"""


# ---------------------------------------------------------------------------
# Main agent
# ---------------------------------------------------------------------------

def run_evaluation_reporter(
    config_path: Optional[Path],
    run_dir_arg: Optional[Path],
    strict: bool = False,
) -> Dict[str, Any]:
    config = load_config(config_path)
    run_dir = infer_run_dir(config, config_path, run_dir_arg)
    run_dir.mkdir(parents=True, exist_ok=True)

    event_path = run_dir / "events.jsonl"
    append_jsonl(event_path, {
        "timestamp": utc_now_iso(),
        "agent": AGENT_NAME,
        "event": "started",
        "run_dir": str(run_dir),
    })

    metadata = resolve_config_metadata(config, run_dir)

    # Load files.
    spec_json = read_json(run_dir / "01_spec_summary.json", {})
    code_json = read_json(run_dir / "02_code_summary.json", {})
    properties_json = read_json(run_dir / "03_candidate_properties.json", {})
    manifest_json = read_json(run_dir / "04_artifact_manifest.json", {})
    critic_json = read_json(run_dir / "05_critic_review.json", {})
    cbmc_status_json = read_json(run_dir / "06_cbmc_status.json", {})
    property_results_json = read_json(run_dir / "06_cbmc_property_results.json", {})
    analysis_json = read_json(run_dir / "07_counterexample_analysis.json", {})
    repair_json = read_json(run_dir / "08_repair_notes.json", {})
    experiment_log_json = read_json(run_dir / "09_experiment_log.json", {})

    harness_text = read_text(run_dir / "08_repaired_harness.c")
    harness_used = "08_repaired_harness.c"
    if not harness_text.strip():
        harness_text = read_text(run_dir / "04_generated_harness.c")
        harness_used = "04_generated_harness.c"

    cbmc_output = read_text(run_dir / "06_cbmc_output.txt")
    cbmc_command = read_text(run_dir / "06_cbmc_command.txt")
    human_notes = read_text(run_dir / "human_notes.md")

    missing_files = [name for name in EXPECTED_RUN_FILES if not (run_dir / name).exists()]
    if strict and missing_files:
        raise RuntimeError(f"Strict mode: missing expected run files: {missing_files}")

    v2_rich_inputs = load_v2_rich_inputs(run_dir)
    spec_parsing_eval = evaluate_spec_parsing_quality(run_dir, spec_json, v2_rich_inputs)

    scores = calculate_scores(
        run_dir=run_dir,
        metadata=metadata,
        spec_json=spec_json,
        code_json=code_json,
        properties_json=properties_json,
        manifest_json=manifest_json,
        critic_json=critic_json,
        cbmc_status_json=cbmc_status_json,
        cbmc_output=cbmc_output,
        cbmc_command=cbmc_command,
        analysis_json=analysis_json,
        repair_json=repair_json,
        harness_text=harness_text,
        spec_parsing_eval=spec_parsing_eval,
    )

    property_evals = build_property_evaluations(
        properties_json=properties_json,
        manifest_json=manifest_json,
        critic_json=critic_json,
        property_results_json=property_results_json,
        harness_text=harness_text,
    )

    taxonomy = build_failure_taxonomy(
        critic_json=critic_json,
        cbmc_status_json=cbmc_status_json,
        cbmc_output=cbmc_output,
        analysis_json=analysis_json,
        repair_json=repair_json,
    )

    summary = build_run_summary(
        metadata=metadata,
        scores=scores,
        critic_json=critic_json,
        cbmc_status_json=cbmc_status_json,
        repair_json=repair_json,
    )

    harness_metrics = build_harness_metrics(harness_text)

    output = {
        "agent": AGENT_NAME,
        "agent_number": AGENT_NUMBER,
        "generated_at": utc_now_iso(),
        "scientific_guardrail": SCIENTIFIC_GUARDRAIL,
        "run_summary": asdict(summary),
        "quality_scores": [asdict(s) for s in scores],
        "property_evaluations": [asdict(p) for p in property_evals],
        "failure_taxonomy": [asdict(t) for t in taxonomy],
        "harness_metrics": harness_metrics,
        "harness_used": harness_used,
        "spec_parsing_quality_evaluation": spec_parsing_eval,
        "missing_expected_files": missing_files,
        "input_file_hashes": {
            name: sha256_file(run_dir / name)
            for name in EXPECTED_RUN_FILES
            if (run_dir / name).exists()
        },
        "environment": {
            "python": sys.version,
            "platform": platform.platform(),
            "cwd": os.getcwd(),
        },
        "source_files_loaded": {
            "spec_summary": not bool(spec_json.get("_json_error")) and bool(spec_json),
            "code_summary": not bool(code_json.get("_json_error")) and bool(code_json),
            "candidate_properties": not bool(properties_json.get("_json_error")) and bool(properties_json),
            "artifact_manifest": not bool(manifest_json.get("_json_error")) and bool(manifest_json),
            "critic_review": not bool(critic_json.get("_json_error")) and bool(critic_json),
            "cbmc_status": not bool(cbmc_status_json.get("_json_error")) and bool(cbmc_status_json),
            "counterexample_analysis": not bool(analysis_json.get("_json_error")) and bool(analysis_json),
            "repair_notes": not bool(repair_json.get("_json_error")) and bool(repair_json),
            "experiment_log": not bool(experiment_log_json.get("_json_error")) and bool(experiment_log_json),
        },
    }

    # Ensure output directories.
    evaluation_dir = run_dir / "evaluation"
    status_dir = run_dir / "agent_status"
    prompt_dir = run_dir / "llm_prompts"
    evaluation_dir.mkdir(parents=True, exist_ok=True)
    status_dir.mkdir(parents=True, exist_ok=True)
    prompt_dir.mkdir(parents=True, exist_ok=True)

    # JSON report.
    write_json(run_dir / f"{OUTPUT_PREFIX}_evaluation_report.json", output)

    # Markdown reports.
    md = render_markdown_report(
        summary=summary,
        scores=scores,
        property_evals=property_evals,
        taxonomy=taxonomy,
        harness_metrics=harness_metrics,
        missing_files=missing_files,
        human_notes=human_notes,
        spec_parsing_eval=spec_parsing_eval,
    )
    write_text(run_dir / f"{OUTPUT_PREFIX}_evaluation_report.md", md)
    write_text(run_dir / "final_report.md", md)

    # CSV/JSON scorecard outputs.
    write_csv(
        evaluation_dir / "evaluation_table.csv",
        [asdict(s) for s in scores],
        fieldnames=["criterion", "score", "max_score", "level", "rationale", "evidence"],
    )
    write_csv(
        evaluation_dir / "property_coverage.csv",
        [asdict(p) for p in property_evals],
        fieldnames=[
            "property_id",
            "property_type",
            "description",
            "priority",
            "selected_for_harness",
            "evidence_in_harness",
            "cbmc_status",
            "critic_concerns",
            "evaluation_note",
        ],
    )
    write_csv(
        evaluation_dir / "failure_taxonomy.csv",
        [asdict(t) for t in taxonomy],
        fieldnames=[
            "category",
            "severity",
            "source_agent",
            "evidence",
            "likely_meaning",
            "recommended_action",
        ],
    )
    write_json(evaluation_dir / "run_quality_scorecard.json", {
        "run_summary": asdict(summary),
        "quality_scores": [asdict(s) for s in scores],
        "overall_score_percent": summary.overall_score_percent,
    })

    write_json(evaluation_dir / "spec_parsing_quality.json", spec_parsing_eval)
    write_csv(
        evaluation_dir / "spec_parsing_quality.csv",
        [
            {"metric": "overall_spec_parsing_quality_score_0_to_1", "value": spec_parsing_eval.get("overall_spec_parsing_quality_score_0_to_1"), "level": spec_parsing_eval.get("level")},
            {"metric": "agent2_v2_core_file_coverage_ratio", "value": safe_get(spec_parsing_eval, ["agent2_v2_core_file_coverage", "ratio"]), "level": spec_parsing_eval.get("level")},
            {"metric": "algorithm_extraction_quality_score_0_to_1", "value": safe_get(spec_parsing_eval, ["algorithm_extraction", "quality_score_0_to_1"]), "level": ""},
            {"metric": "symbol_extraction_quality_score_0_to_1", "value": safe_get(spec_parsing_eval, ["symbol_extraction", "quality_score_0_to_1"]), "level": ""},
            {"metric": "parameter_extraction_quality_score_0_to_1", "value": safe_get(spec_parsing_eval, ["parameter_extraction", "quality_score_0_to_1"]), "level": ""},
            {"metric": "spec_claim_review_or_evidence_coverage_0_to_1", "value": safe_get(spec_parsing_eval, ["spec_claim_human_review_status", "review_or_evidence_coverage_0_to_1"]), "level": ""},
        ],
        fieldnames=["metric", "value", "level"],
    )
    write_csv(evaluation_dir / "algorithm_extraction_coverage.csv", safe_get(spec_parsing_eval, ["algorithm_extraction", "items"], []))
    write_csv(evaluation_dir / "symbol_extraction_coverage.csv", safe_get(spec_parsing_eval, ["symbol_extraction", "items"], []))
    write_csv(evaluation_dir / "parameter_extraction_confidence.csv", safe_get(spec_parsing_eval, ["parameter_extraction", "items"], []))
    write_csv(evaluation_dir / "spec_claim_human_review_status.csv", safe_get(spec_parsing_eval, ["spec_claim_human_review_status", "items"], []))

    checklist = render_human_review_checklist(summary, property_evals, taxonomy, spec_parsing_eval=spec_parsing_eval)
    write_text(evaluation_dir / "human_review_checklist.md", checklist)

    prompt_text = f"""You are the Evaluation and Reporting Agent for an AI-assisted formal-verification workflow.

Inputs:
- Specification summary
- Code summary
- Candidate properties
- Generated/repaired harness
- Critic review
- CBMC status/output
- Counterexample analysis
- Repair notes
- Experiment log

Task:
Evaluate the run using these criteria:
{", ".join(CRITERIA)}

Additional v2 evaluation:
- spec parsing quality
- algorithm extraction coverage
- symbol extraction coverage
- parameter extraction confidence
- human review status for extracted spec claims

Mandatory guardrail:
{SCIENTIFIC_GUARDRAIL}

Produce:
- evaluation report
- evaluation table
- property coverage table
- failure taxonomy
- human review checklist
"""
    write_text(prompt_dir / f"{OUTPUT_PREFIX}_evaluation_reporter_prompt.txt", prompt_text)

    status = {
        "agent": AGENT_NAME,
        "agent_number": AGENT_NUMBER,
        "status": "completed",
        "generated_at": utc_now_iso(),
        "run_dir": str(run_dir),
        "outputs": [
            f"{OUTPUT_PREFIX}_evaluation_report.json",
            f"{OUTPUT_PREFIX}_evaluation_report.md",
            "final_report.md",
            "evaluation/evaluation_table.csv",
            "evaluation/property_coverage.csv",
            "evaluation/failure_taxonomy.csv",
            "evaluation/human_review_checklist.md",
            "evaluation/run_quality_scorecard.json",
            "evaluation/spec_parsing_quality.json",
            "evaluation/spec_parsing_quality.csv",
            "evaluation/algorithm_extraction_coverage.csv",
            "evaluation/symbol_extraction_coverage.csv",
            "evaluation/parameter_extraction_confidence.csv",
            "evaluation/spec_claim_human_review_status.csv",
        ],
        "final_status": summary.final_status,
        "overall_score_percent": summary.overall_score_percent,
        "human_review_required": True,
        "missing_expected_files": missing_files,
    }
    write_json(status_dir / f"{OUTPUT_PREFIX}_evaluation_reporter_status.json", status)

    append_jsonl(event_path, {
        "timestamp": utc_now_iso(),
        "agent": AGENT_NAME,
        "event": "completed",
        "final_status": summary.final_status,
        "overall_score_percent": summary.overall_score_percent,
        "outputs": status["outputs"],
    })

    print(f"[OK] Evaluation and Reporting Agent wrote: {run_dir / f'{OUTPUT_PREFIX}_evaluation_report.json'}")
    print(f"[OK] Markdown report: {run_dir / f'{OUTPUT_PREFIX}_evaluation_report.md'}")
    print(f"[OK] Final report: {run_dir / 'final_report.md'}")
    print(f"[OK] Evaluation CSV: {evaluation_dir / 'evaluation_table.csv'}")
    print(f"[OK] Spec parsing quality: {evaluation_dir / 'spec_parsing_quality.json'}")
    print("[NOTE] This report evaluates candidate artifacts only; human review remains required.")

    return output


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Agent 11: Evaluation and Reporting Agent for thesis-agent-workflow."
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=None,
        help="Path to workflow config JSON, for example configs/poly_add_run.json.",
    )
    parser.add_argument(
        "--run-dir",
        type=Path,
        default=None,
        help="Path to the current run directory, for example runs/run_001_poly_add.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail if expected run files are missing. Default is to report missing files and continue.",
    )
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> int:
    args = parse_args(argv)
    try:
        run_evaluation_reporter(
            config_path=args.config,
            run_dir_arg=args.run_dir,
            strict=args.strict,
        )
        return 0
    except Exception as exc:
        # Try to write a status file if run directory can be resolved.
        try:
            config = load_config(args.config)
            run_dir = infer_run_dir(config, args.config, args.run_dir)
            status_dir = run_dir / "agent_status"
            status_dir.mkdir(parents=True, exist_ok=True)
            write_json(status_dir / f"{OUTPUT_PREFIX}_evaluation_reporter_status.json", {
                "agent": AGENT_NAME,
                "agent_number": AGENT_NUMBER,
                "status": "failed",
                "generated_at": utc_now_iso(),
                "error": str(exc),
                "human_review_required": True,
            })
            append_jsonl(run_dir / "events.jsonl", {
                "timestamp": utc_now_iso(),
                "agent": AGENT_NAME,
                "event": "failed",
                "error": str(exc),
            })
        except Exception:
            pass
        print(f"[ERROR] Evaluation and Reporting Agent failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
