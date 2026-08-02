#!/usr/bin/env python3
"""
counterexample_analysis_agent_refactored.py

Agent 8 — Counterexample Analysis Agent, refactored for the new thesis workflow.

Architecture implemented:
- LLM-backed stage.
- Consumes Agent 7 deterministic CBMC/tool outputs through handoff manifest.
- Also consumes relevant Agent 5/6 artefact/review context when available.
- Python deterministic trace/failure classification is advisory diagnostic only.
- Raw CBMC output remains primary tool evidence.
- The shared LLM client produces the authoritative stage candidate output:
    stages/08_counterexample_analysis/llm_authoritative/07_counterexample_analysis.json
- Python derives repair guidance/action-plan helper files from the LLM output where possible.
- Downstream agents consume only manifest-declared handoff outputs.
- No root-level output dumping.
- No duplicate output copies.

Trust boundary:
- Agent 8 does not prove any property.
- Agent 8 does not override raw CBMC evidence.
- Agent 8 explains likely causes, scope, and repair directions.
- If CBMC succeeded, Agent 8 analyses what was checked and what was not checked.
- If CBMC was skipped/dry-run/tool-unavailable, Agent 8 records that no formal-tool result exists.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import sys
import traceback
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple, Union


# ---------------------------------------------------------------------------
# Import path hardening
# ---------------------------------------------------------------------------

THIS_FILE = Path(__file__).resolve()
PROJECT_ROOT = THIS_FILE.parents[1] if THIS_FILE.parent.name == "agents" else Path.cwd()
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))


try:
    from agents.common.run_layout import RunLayout, atomic_write_json, atomic_write_text, ensure_dir
    from agents.common.config_contract import load_normalized_config
    from agents.common.evidence_contract import canonical_raw_evidence_files, existing_unique_paths, without_keys
    from agents.common.llm_client import LLMClient, LLMStageRequest, record_llm_stage_failure
    from agents.common.prompt_templates import build_common_stage_prompt
    from agents.common.schemas import COUNTEREXAMPLE_ANALYSIS_SCHEMA
    from agents.common.tool_result_contract import CONTRACT_BUILD_FAILED, interpret_tool_result
except Exception as import_exc:  # pragma: no cover
    raise SystemExit(
        "Failed to import shared workflow modules. Ensure these files exist and schemas.py includes COUNTEREXAMPLE_ANALYSIS_SCHEMA:\n"
        "  agents/common/run_layout.py\n"
        "  agents/common/llm_client.py\n"
        "  agents/common/prompt_templates.py\n"
        "  agents/common/schemas.py\n"
        f"Original import error: {type(import_exc).__name__}: {import_exc}"
    )


JsonDict = Dict[str, Any]
PathLike = Union[str, Path]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def read_json_file(path: PathLike) -> JsonDict:
    p = Path(path)
    with p.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected JSON object in {p}")
    return data


def extract_content_wrapper(data: JsonDict) -> JsonDict:
    content = data.get("content")
    if isinstance(content, dict):
        return content
    return data


def safe_read_text(path: PathLike, *, max_chars: Optional[int] = None) -> str:
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    if max_chars is not None and len(text) > max_chars:
        return text[:max_chars] + "\n[TRUNCATED]\n"
    return text


def parse_list_arg(value: Optional[str]) -> List[str]:
    if not value:
        return []
    return [p.strip() for p in re.split(r"[,;]", value) if p.strip()]


def write_csv(path: PathLike, rows: List[Mapping[str, Any]], fieldnames: Optional[List[str]] = None) -> Path:
    p = Path(path)
    ensure_dir(p.parent)
    if fieldnames is None:
        keys = []
        for row in rows:
            for key in row.keys():
                if key not in keys:
                    keys.append(key)
        fieldnames = keys or ["empty"]
    with p.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: row.get(k, "") for k in fieldnames})
    return p


def sha256_file(path: PathLike) -> str:
    import hashlib
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

@dataclass
class CounterexampleAnalysisConfig:
    run_dir: Path
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM CBMC counterexample analysis"
    llm_mode_override: Optional[str] = None
    allow_missing_tool_outputs: bool = False
    allow_empty_handoff_on_failure: bool = True
    max_cbmc_output_chars: int = 200_000
    max_harness_chars: int = 120_000
    iteration: int = 0


def resolve_run_dir(config_data: JsonDict, args: argparse.Namespace) -> Path:
    if args.run_dir:
        return Path(args.run_dir).expanduser().resolve()
    for key in ["run_dir", "output_dir"]:
        if config_data.get(key):
            return Path(str(config_data[key])).expanduser().resolve()
    run = config_data.get("run", {})
    if isinstance(run, dict):
        for key in ["run_dir", "output_dir"]:
            if run.get(key):
                return Path(str(run[key])).expanduser().resolve()
    runs_dir = Path(str(config_data.get("runs_dir", "runs"))).expanduser()
    run_id = str(config_data.get("run_id", "run_001_refactored"))
    return (runs_dir / run_id).resolve()


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, CounterexampleAnalysisConfig]:
    config_data: JsonDict = {}
    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        config_data = load_normalized_config(config_path)

    ce = config_data.get("counterexample_analysis", {})
    if not isinstance(ce, dict):
        ce = {}

    target_function = (
        args.target_function
        or str(config_data.get("target_function") or "")
        or str(config_data.get("function_name") or "")
        or "mlk_poly_add"
    )

    target_topic = (
        args.target_topic
        or str(config_data.get("target_topic") or "")
        or f"CBMC counterexample analysis for {target_function}"
    )

    cfg = CounterexampleAnalysisConfig(
        run_dir=resolve_run_dir(config_data, args),
        target_function=target_function,
        target_topic=target_topic,
        llm_mode_override=args.llm_mode,
        allow_missing_tool_outputs=bool(args.allow_missing_tool_outputs or ce.get("allow_missing_tool_outputs")),
        max_cbmc_output_chars=int(ce.get("max_cbmc_output_chars", 200_000)),
        max_harness_chars=int(ce.get("max_harness_chars", 120_000)),
        iteration=int(args.iteration),
    )
    return config_data, cfg


# ---------------------------------------------------------------------------
# Handoff loading
# ---------------------------------------------------------------------------

def load_handoff_path(layout: RunLayout, producer_stage: str, output_key: str) -> Tuple[Optional[Path], JsonDict]:
    status = {
        "producer_stage": producer_stage,
        "output_key": output_key,
        "available": False,
        "path": None,
        "warning": None,
    }
    try:
        path = layout.get_handoff(producer_stage, output_key)
        status["path"] = str(path)
        if not path.exists():
            status["warning"] = "Handoff path exists in manifest but file is missing."
            return path, status
        status["available"] = True
        return path, status
    except Exception as exc:
        status["warning"] = f"Could not load handoff path: {type(exc).__name__}: {exc}"
        return None, status


def load_handoff_json(layout: RunLayout, producer_stage: str, output_key: str) -> Tuple[Optional[Path], Optional[JsonDict], JsonDict]:
    path, status = load_handoff_path(layout, producer_stage, output_key)
    if not path or not path.exists():
        return path, None, status
    try:
        data = extract_content_wrapper(read_json_file(path))
        status["available"] = True
        return path, data, status
    except Exception as exc:
        status["available"] = False
        status["warning"] = f"Could not parse JSON handoff: {type(exc).__name__}: {exc}"
        return path, None, status


def load_handoff_text(layout: RunLayout, producer_stage: str, output_key: str, *, max_chars: Optional[int] = None) -> Tuple[Optional[Path], Optional[str], JsonDict]:
    path, status = load_handoff_path(layout, producer_stage, output_key)
    if not path or not path.exists():
        return path, None, status
    try:
        text = safe_read_text(path, max_chars=max_chars)
        status["available"] = True
        return path, text, status
    except Exception as exc:
        status["available"] = False
        status["warning"] = f"Could not read text handoff: {type(exc).__name__}: {exc}"
        return path, None, status


# ---------------------------------------------------------------------------
# Deterministic diagnostic analysis
# ---------------------------------------------------------------------------

def classify_readiness_failure(readiness: Mapping[str, Any]) -> JsonDict:
    """Classify objective pre-Agent-7 readiness evidence without inventing a solver result."""
    classification = str(readiness.get("classification") or "readiness_failed_before_tool_execution")
    stderr = str(readiness.get("stderr") or "")
    combined = (classification + "\n" + stderr).lower()
    categories: List[str] = []
    if any(token in combined for token in ("tool_unavailable", "not found", "no such file or directory")) and not any(
        token in combined for token in ("source", "header", "include")
    ):
        categories.append("capability_or_tool_unavailable")
    if any(token in combined for token in ("syntax error", "parse error", "parsing error")):
        categories.append("frontend_parser_error")
    if any(token in combined for token in ("[0 ..", "[0:", "unsupported", "unknown builtin")):
        categories.append("unsupported_or_invented_syntax")
    if any(token in combined for token in ("failed to open", "missing source", "missing header", "missing include", "no such file")):
        categories.append("missing_source_or_include")
    if any(token in combined for token in ("goto-instrument", "transformation", "dfcc", "enforce-contract", "loop-contract")):
        categories.append("goto_transformation_failure")
    selected_generated = readiness.get("selected_claim_generated")
    if selected_generated is False or any(token in combined for token in ("missing_selected_claim", "claim mapping", "property listing")):
        categories.append("selected_claim_generation_or_mapping_failure")
    if not categories:
        categories.append("unclassified_route_readiness_failure")
    return {
        "schema_version": "pre_agent7_readiness_diagnosis.v1",
        "readiness_classification": classification,
        "failure_categories": sorted(set(categories)),
        "formal_property_evaluated": False,
        "cbmc_solving_attempted": False,
        "claim_boundary": "This diagnoses compile/transform/property-listing readiness only; it is not a CBMC solving result.",
    }


def classify_failure_mode(cbmc_status: Optional[JsonDict], cbmc_output: str, cbmc_stderr: str, property_results: Optional[JsonDict]) -> JsonDict:
    status = cbmc_status or {}
    interpretation = interpret_tool_result(status, property_results)
    result = str(interpretation["result_classification"])
    semantic_outcome = str(interpretation["semantic_outcome"])
    counterexample_scope = str(interpretation.get("counterexample_scope") or "none")
    combined = (cbmc_output + "\n" + cbmc_stderr).lower()
    categories = list(interpretation["failure_categories"])

    selected_failures = [
        dict(row) for row in status.get("selected_failed_properties", [])
        if isinstance(row, Mapping)
    ]
    auxiliary_failures = [
        dict(row) for row in status.get("auxiliary_failed_properties", [])
        if isinstance(row, Mapping)
    ]
    # Backward compatibility for old result records: only a selected-failure
    # classification may borrow the undifferentiated failed-property rows.
    if not selected_failures and not auxiliary_failures and semantic_outcome in {"property_failed", "property_failed_and_unknown"}:
        if property_results and isinstance(property_results.get("failed_properties"), list):
            selected_failures = [row for row in property_results.get("failed_properties", []) if isinstance(row, dict)]

    if selected_failures:
        categories.append("parsed_selected_failed_properties_available")
    if auxiliary_failures:
        categories.append("parsed_auxiliary_failed_properties_available")

    relevant_failures = selected_failures if counterexample_scope == "selected_claims" else auxiliary_failures
    actual_selected_failure = semantic_outcome in {"property_failed", "property_failed_and_unknown"}
    if relevant_failures:
        failure_evidence_text = json.dumps(relevant_failures, sort_keys=True).lower()
    elif actual_selected_failure:
        failure_markers = ("failure", "failed", "counterexample", "violated")
        failure_evidence_text = "\n".join(
            line for line in combined.splitlines()
            if any(marker in line for marker in failure_markers)
        )
    else:
        failure_evidence_text = ""

    prefix = "auxiliary_" if counterexample_scope == "auxiliary_properties" else "selected_"
    if "dereference failure" in failure_evidence_text or "pointer" in failure_evidence_text:
        categories.append(prefix + "possible_pointer_or_memory_safety_failure")
    if "array bounds" in failure_evidence_text or "bounds" in failure_evidence_text:
        categories.append(prefix + "possible_array_bounds_failure")
    if "overflow" in failure_evidence_text:
        categories.append(prefix + "possible_arithmetic_overflow_failure")
    if "unwinding assertion" in failure_evidence_text or "unwind" in failure_evidence_text:
        categories.append(prefix + "possible_unwinding_bound_issue")
    if "assertion" in failure_evidence_text and (relevant_failures or actual_selected_failure):
        categories.append(prefix + "assertion_violation")

    infrastructure_outcome = semantic_outcome in {
        "structured_evidence_missing", "tool_or_build_failure", "tool_evidence_inconsistent",
        "selected_property_traceability_incomplete",
    }
    if infrastructure_outcome:
        if "parse error" in combined or "syntax error" in combined:
            categories.append("possible_harness_syntax_or_compile_error")
        if "failed to open" in combined or "no such file" in combined:
            categories.append("missing_include_or_file_issue")

    return {
        "result_classification": result,
        "semantic_outcome": semantic_outcome,
        "canonical_result_valid": interpretation["canonical_result_valid"],
        "failure_categories": sorted(set(categories)),
        "severity": interpretation["severity"],
        "repair_needed": interpretation["repair_needed"],
        "no_formal_tool_result": interpretation["no_formal_tool_result"],
        "counterexample_relevant": interpretation["counterexample_relevant"],
        "counterexample_scope": counterexample_scope,
        "selected_claim_result": interpretation.get("selected_claim_result"),
        "auxiliary_property_result": interpretation.get("auxiliary_property_result"),
        "selected_failed_property_count": len(selected_failures),
        "auxiliary_failed_property_count": len(auxiliary_failures),
        "emitted_failure_count": interpretation["emitted_failure_count"],
        "emitted_unknown_count": interpretation["emitted_unknown_count"],
        "parsed_failure_count": len(selected_failures) + len(auxiliary_failures),
        "failure_hint_evidence_scope": (
            "exact_selected_failed_property_rows" if counterexample_scope == "selected_claims" and selected_failures else
            "exact_auxiliary_failed_property_rows" if counterexample_scope == "auxiliary_properties" and auxiliary_failures else
            "failure_context_lines" if actual_selected_failure and failure_evidence_text else
            "no_property_specific_failure_evidence"
        ),
        "interpretation_boundary": (
            "Selected-claim and auxiliary failures are classified independently. "
            "Textual hints are scoped only to the exact failed rows relevant to the canonical outcome; raw CBMC output remains primary evidence."
        ),
    }


def extract_cbmc_failure_snippets(cbmc_output: str, cbmc_stderr: str, max_snippets: int = 80) -> List[JsonDict]:
    combined_lines = (cbmc_output + "\n" + cbmc_stderr).splitlines()
    keywords = [
        "VERIFICATION FAILED",
        "Violated property",
        "Counterexample",
        "Trace for",
        "FAILURE",
        "dereference failure",
        "array bounds",
        "overflow",
        "unwinding assertion",
        "syntax error",
        "parse error",
        "No such file",
        "failed to open",
        "conversion",
        "undefined shift",
    ]

    snippets: List[JsonDict] = []
    seen = set()

    for idx, line in enumerate(combined_lines, start=1):
        if any(k.lower() in line.lower() for k in keywords):
            start = max(1, idx - 3)
            end = min(len(combined_lines), idx + 8)
            text = "\n".join(f"{j}: {combined_lines[j-1]}" for j in range(start, end + 1))
            key = (start, end, text)
            if key in seen:
                continue
            seen.add(key)
            snippets.append({
                "start_line": start,
                "end_line": end,
                "trigger_line": idx,
                "trigger_text": line,
                "snippet": text,
                "trust_boundary": "deterministic_diagnostic_excerpt",
            })
            if len(snippets) >= max_snippets:
                break

    return snippets


def diagnose_harness_against_failure(
    harness_text: Optional[str],
    cbmc_output: str,
    property_results: Optional[JsonDict],
    classification: Optional[Mapping[str, Any]] = None,
) -> JsonDict:
    harness_text = harness_text or ""
    findings = []
    if not harness_text:
        findings.append({
            "kind": "missing_harness_text",
            "message": "Harness text was unavailable, so harness-level diagnosis is limited.",
            "severity": "major",
        })
        return {
            "findings": findings,
            "assertion_lines": [],
            "assumption_lines": [],
            "call_lines": [],
            "old_state_lines": [],
        }

    assertion_lines = []
    assumption_lines = []
    call_lines = []
    old_state_lines = []

    for i, line in enumerate(harness_text.splitlines(), start=1):
        stripped = line.strip()
        if "assert" in stripped or "__CPROVER_assert" in stripped:
            assertion_lines.append({"line": i, "text": stripped})
        if "__CPROVER_assume" in stripped or "assume" in stripped:
            assumption_lines.append({"line": i, "text": stripped})
        if "(" in stripped and ")" in stripped and not stripped.startswith("#"):
            if "mlk_" in stripped or "harness" not in stripped:
                call_lines.append({"line": i, "text": stripped})
        if any(t in stripped for t in ["old_", "_old", "pre_", "_pre", "snapshot", "before"]):
            old_state_lines.append({"line": i, "text": stripped})

    if not assertion_lines:
        findings.append({
            "kind": "no_assertions_detected",
            "message": "No assertion lines were detected in the harness.",
            "severity": "major",
        })
    failure_scope = str((classification or {}).get("counterexample_scope") or "none")
    if "VERIFICATION FAILED" in cbmc_output and assertion_lines and failure_scope == "selected_claims":
        findings.append({
            "kind": "selected_assertion_failure_possible",
            "message": "The canonical result maps failed evidence to the selected claim; inspect the selected assertion and its assumptions.",
            "severity": "high",
        })
    elif "VERIFICATION FAILED" in cbmc_output and failure_scope == "auxiliary_properties":
        findings.append({
            "kind": "auxiliary_property_failure_only",
            "message": "The selected claim passed; failed evidence is scoped to auxiliary checks and must not trigger selected-claim rewriting.",
            "severity": "high",
        })
    if not old_state_lines and ("old" in cbmc_output.lower() or "functional" in cbmc_output.lower()):
        findings.append({
            "kind": "old_state_snapshot_not_obvious",
            "message": "No obvious old-state snapshot lines detected.",
            "severity": "medium",
        })

    selected_failed = int((classification or {}).get("selected_failed_property_count") or 0)
    auxiliary_failed = int((classification or {}).get("auxiliary_failed_property_count") or 0)
    if selected_failed or auxiliary_failed:
        findings.append({
            "kind": "failed_properties_parsed_by_scope",
            "message": f"Parsed failures: selected={selected_failed}, auxiliary={auxiliary_failed}.",
            "severity": "high",
            "selected_failed_property_count": selected_failed,
            "auxiliary_failed_property_count": auxiliary_failed,
        })

    return {
        "findings": findings,
        "assertion_lines": assertion_lines[:200],
        "assumption_lines": assumption_lines[:200],
        "call_lines": call_lines[:200],
        "old_state_lines": old_state_lines[:200],
    }


def build_repair_guidance_diagnostic(classification: JsonDict, harness_diag: JsonDict) -> JsonDict:
    categories = set(classification.get("failure_categories", []))
    guidance = []

    if classification.get("no_formal_tool_result"):
        guidance.append({
            "repair_type": "no_formal_tool_result",
            "priority": "high",
            "guidance": "Do not repair the property from CBMC evidence because CBMC did not execute. Fix gate/tool availability/dry-run status first.",
        })
    if "tool_or_compilation_error" in categories or "possible_harness_syntax_or_compile_error" in categories:
        guidance.append({
            "repair_type": "harness_compile_or_syntax_fix",
            "priority": "high",
            "guidance": "Check includes, type declarations, function declarations, and generated C syntax before changing the property.",
        })
    if categories & {"structured_evidence_format_failure", "no_emitted_property_evidence"}:
        guidance.append({
            "repair_type": "structured_evidence_pipeline_fix",
            "priority": "high",
            "guidance": "Repair JSON evidence generation or property instrumentation before changing the selected property.",
        })
    if "selected_property_traceability_incomplete" in categories:
        guidance.append({
            "repair_type": "selected_claim_traceability_fix",
            "priority": "high",
            "guidance": "Restore the selected-property-to-CBMC claim mapping before interpreting successful emitted properties.",
        })
    if "tool_execution_or_evidence_inconsistent" in categories:
        guidance.append({
            "repair_type": "tool_evidence_consistency_fix",
            "priority": "high",
            "guidance": "Reconcile exit status, structured property rows and selected-property coverage before semantic repair.",
        })
    if classification.get("semantic_outcome") == "selected_property_passed_auxiliary_failed_or_unknown":
        guidance.append({
            "repair_type": "auxiliary_checks_only_preserve_selected_claim",
            "priority": "high",
            "guidance": (
                "The selected claim passed. Diagnose only the failed/unknown auxiliary safety or model checks; "
                "do not weaken, replace, or rewrite the selected claim unless a separate user-authorized semantic change is recorded."
            ),
        })
    if "property_result_unknown" in categories:
        guidance.append({
            "repair_type": "unknown_property_model_investigation",
            "priority": "medium",
            "guidance": "Investigate bounds, model completeness and unknown CBMC statuses separately from failed claims.",
        })
    if "missing_include_or_file_issue" in categories:
        guidance.append({
            "repair_type": "include_path_or_build_context_fix",
            "priority": "high",
            "guidance": "Add missing include paths/source context or adjust the harness to use available headers.",
        })
    if categories & {"selected_possible_pointer_or_memory_safety_failure", "auxiliary_possible_pointer_or_memory_safety_failure", "possible_pointer_or_memory_safety_failure"}:
        guidance.append({
            "repair_type": "memory_assumption_or_pointer_model_fix",
            "priority": "medium",
            "guidance": "Review pointer validity, object allocation, writable/readable memory assumptions, and aliasing assumptions.",
        })
    if categories & {"selected_possible_array_bounds_failure", "auxiliary_possible_array_bounds_failure", "possible_array_bounds_failure"}:
        guidance.append({
            "repair_type": "array_bound_or_loop_assumption_fix",
            "priority": "medium",
            "guidance": "Review loop bounds, array length macros, and coefficient-array object sizes.",
        })
    if categories & {"selected_possible_arithmetic_overflow_failure", "auxiliary_possible_arithmetic_overflow_failure", "possible_arithmetic_overflow_failure"}:
        guidance.append({
            "repair_type": "range_assumption_or_arithmetic_property_fix",
            "priority": "medium",
            "guidance": "Review coefficient range assumptions and C integer promotion/cast behaviour.",
        })
    if "contract_build_or_instrumentation_failure" in categories:
        guidance.append({
            "repair_type": "native_contract_build_or_instrumentation_fix",
            "priority": "high",
            "guidance": "Inspect goto-cc/goto-instrument stdout, exact patch diff, contract syntax, target symbol and DFCC/enforce options before changing the property.",
        })
    if "analysis_only_no_formal_tool_claim" in categories:
        guidance.append({
            "repair_type": "no_formal_repair_analysis_only",
            "priority": "none",
            "guidance": "Do not manufacture a CBMC proof claim; preserve the analysis-only classification and use configured external/manual evidence.",
        })
    if categories & {"selected_possible_unwinding_bound_issue", "auxiliary_possible_unwinding_bound_issue", "possible_unwinding_bound_issue"}:
        guidance.append({
            "repair_type": "unwind_bound_fix",
            "priority": "medium",
            "guidance": "Increase or correctly set unwinding bounds, or avoid false conclusions from insufficient unwinding.",
        })
    if categories & {"selected_assertion_violation", "assertion_violation", "counterexample_or_property_failure"}:
        guidance.append({
            "repair_type": "assertion_or_property_semantics_review",
            "priority": "high",
            "guidance": "Check whether the assertion matches the intended property and whether assumptions accidentally allow counterexamples.",
        })
    if not guidance and classification.get("semantic_outcome") == "bounded_selected_property_success":
        guidance.append({
            "repair_type": "no_repair_from_success",
            "priority": "none",
            "guidance": "No counterexample repair is suggested. Evaluate scope, assumptions, and limitations instead.",
        })
    if not guidance:
        guidance.append({
            "repair_type": "manual_investigation_required",
            "priority": "medium",
            "guidance": "The result is not clearly classified; inspect raw CBMC output manually.",
        })

    return {
        "schema_version": "repair_guidance_diagnostic.v1",
        "created_utc": utc_now_iso(),
        "guidance_items": guidance,
        "trust_boundary": "deterministic_repair_guidance_advisory_only",
    }


def deterministic_counterexample_analysis(
    *,
    cbmc_status: Optional[JsonDict],
    cbmc_output: str,
    cbmc_stderr: str,
    property_results: Optional[JsonDict],
    trace_summary: Optional[JsonDict],
    failed_mapping: Optional[JsonDict],
    harness_text: Optional[str],
) -> JsonDict:
    classification = classify_failure_mode(cbmc_status, cbmc_output, cbmc_stderr, property_results)
    diagnostic_failure_evidence_relevant = bool(
        classification.get("counterexample_relevant") or classification.get("repair_needed")
    )
    snippets = (
        extract_cbmc_failure_snippets(cbmc_output, cbmc_stderr)
        if diagnostic_failure_evidence_relevant else []
    )
    harness_diag = (
        diagnose_harness_against_failure(harness_text, cbmc_output, property_results, classification)
        if diagnostic_failure_evidence_relevant else {
            "findings": [], "assertion_lines": [], "assumption_lines": [],
            "call_lines": [], "old_state_lines": [],
            "status": "failure_diagnosis_not_applicable_to_canonical_outcome",
        }
    )
    repair_guidance = build_repair_guidance_diagnostic(classification, harness_diag)

    return {
        "schema_version": "deterministic_counterexample_analysis.v1",
        "created_utc": utc_now_iso(),
        "classification": classification,
        "failure_snippets": snippets,
        "harness_diagnosis": harness_diag,
        "repair_guidance": repair_guidance,
        "tool_result_scope": {
            "cbmc_status_available": bool(cbmc_status),
            "property_results_available": bool(property_results),
            "trace_summary_available": bool(trace_summary),
            "failed_mapping_available": bool(failed_mapping),
            "raw_output_chars": len(cbmc_output),
            "raw_stderr_chars": len(cbmc_stderr),
        },
        "trust_boundary": "deterministic_diagnostic_not_authoritative_llm_analysis",
        "limitations": [
            "This diagnostic classification does not override raw CBMC output.",
            "It may misclassify CBMC messages depending on output format.",
            "The LLM analysis and human review must use raw output as primary evidence.",
        ],
    }


def write_deterministic_files(layout: RunLayout, det: JsonDict) -> Dict[str, Path]:
    stage = "08_counterexample_analysis"
    paths: Dict[str, Path] = {}

    paths["counterexample_analysis_deterministic"] = layout.write_deterministic_reference_json(
        stage,
        "07_counterexample_analysis.deterministic.json",
        det,
    )
    paths["cbmc_trace_summary_diagnostic"] = layout.write_deterministic_reference_json(
        stage,
        "07_cbmc_trace_summary.diagnostic.json",
        {
            "failure_snippets": det.get("failure_snippets", []),
            "trust_boundary": "deterministic_diagnostic_excerpt",
        },
    )
    paths["failure_classification_matrix"] = layout.write_deterministic_reference_json(
        stage,
        "07_failure_classification_matrix.deterministic.json",
        det.get("classification", {}),
    )
    paths["tool_vs_harness_vs_code_diagnosis"] = layout.write_deterministic_reference_json(
        stage,
        "07_tool_vs_harness_vs_code_diagnosis.deterministic.json",
        det.get("harness_diagnosis", {}),
    )
    paths["repair_guidance_deterministic"] = layout.write_deterministic_reference_json(
        stage,
        "07_repair_guidance.deterministic.json",
        det.get("repair_guidance", {}),
    )

    rows = []
    for cat in det.get("classification", {}).get("failure_categories", []):
        rows.append({
            "category": cat,
            "severity": det.get("classification", {}).get("severity"),
            "repair_needed": det.get("classification", {}).get("repair_needed"),
            "no_formal_tool_result": det.get("classification", {}).get("no_formal_tool_result"),
        })
    paths["failure_classification_matrix_csv"] = write_csv(
        layout.deterministic_reference_dir(stage) / "07_failure_classification_matrix.deterministic.csv",
        rows,
        fieldnames=["category", "severity", "repair_needed", "no_formal_tool_result"],
    )

    guidance_rows = det.get("repair_guidance", {}).get("guidance_items", [])
    paths["repair_action_plan_csv"] = write_csv(
        layout.deterministic_reference_dir(stage) / "07_repair_action_plan.deterministic.csv",
        guidance_rows,
    )

    return paths


# ---------------------------------------------------------------------------
# Prompt and mock output
# ---------------------------------------------------------------------------

def build_agent8_prompt(cfg: CounterexampleAnalysisConfig, availability: Mapping[str, bool], result_classification: str) -> str:
    responsibilities = """
- Treat raw CBMC output, status, command, property results, and trace summaries as primary tool evidence.
- Explain whether CBMC executed, skipped, timed out, failed, succeeded, or was unavailable.
- If CBMC failed, identify likely failure categories and separate harness errors from property failures where possible.
- If CBMC succeeded, explain only what was checked under the harness and assumptions, and explicitly state what was not checked.
- If CBMC was skipped/dry-run/tool-unavailable, clearly state that no formal-tool verification result exists.
- Identify whether repair is needed and what type of repair is appropriate.
- Produce a repair guidance section and repair action plan suitable for Agent 9.
- Preserve uncertainty and avoid over-interpreting incomplete traces.
- Provide evidence references to CBMC status, raw output, property results, trace summary, harness, and command manifest.
""".strip()

    prohibitions = """
- Do not claim proof or implementation correctness.
- Do not claim FIPS 203 compliance.
- Do not claim cryptographic security.
- Do not treat deterministic diagnostics as stronger than raw CBMC output.
- Do not invent counterexample details that are not present in the raw output.
- Do not repair by simply weakening the property unless the loss of evidence is explicitly recorded.
- Do not assume verification success when CBMC did not execute.
- Do not hide tool-unavailable, dry-run, skipped-gate, or timeout results.
""".strip()

    task = f"""
This stage analyses Agent 7 tool execution output.

Target function: {cfg.target_function}
Target topic: {cfg.target_topic}
Agent 7 result classification: {result_classification}

Available evidence:
- cbmc_status: {availability.get("cbmc_status")}
- cbmc_output: {availability.get("cbmc_output")}
- cbmc_stderr: {availability.get("cbmc_stderr")}
- cbmc_property_results: {availability.get("cbmc_property_results")}
- cbmc_trace_summary: {availability.get("cbmc_trace_summary")}
- failed_property_mapping: {availability.get("failed_property_mapping")}
- tool_command_manifest: {availability.get("tool_command_manifest")}
- tool_environment_snapshot: {availability.get("tool_environment_snapshot")}
- generated_harness: {availability.get("generated_harness")}
- artifact_plan: {availability.get("artifact_plan")}
- critic_review: {availability.get("critic_review")}

Your output is a counterexample/tool-result analysis, not a proof result.

If CBMC reported success, analyse scope and limitations rather than inventing repairs.
If CBMC reported failure, identify plausible failure root causes and repair actions.
If CBMC did not run, state that no CBMC verification evidence exists and recommend infrastructure/review-gate actions.
""".strip()

    schema_summary = """
Top-level required fields:
- stage
- tool_result_summary
- execution_status_interpretation
- counterexample_analysis
- failure_classification
- harness_vs_property_vs_tool_diagnosis
- repair_guidance
- repair_action_plan
- success_scope_analysis
- deterministic_reference_assessment
- evidence_references
- limitations

Repair action items should include:
- action_id
- action_type
- priority
- target_stage
- proposed_change
- evidence_basis
- risk_if_applied
- evidence_strength_lost_if_any
""".strip()

    return build_common_stage_prompt(
        stage_name="Agent 8 — Counterexample Analysis Agent",
        task_description=task,
        responsibilities=responsibilities,
        prohibitions=prohibitions,
        schema_summary=schema_summary,
        include_non_copying_rule=False,
    )


def build_mock_counterexample_analysis(cfg: CounterexampleAnalysisConfig, det: JsonDict) -> JsonDict:
    classification = det.get("classification", {})
    result = str(classification.get("result_classification") or "unknown")
    no_formal_result = bool(classification.get("no_formal_tool_result", False))
    return {
        "stage": "08_counterexample_analysis",
        "mock": True,
        "llm_call_executed": False,
        "tool_result_summary": {
            "result_classification": result,
            "tool_executed": not no_formal_result,
            "exit_code": None,
            "summary": "Mock mode only; no real LLM counterexample analysis was executed."
        },
        "execution_status_interpretation": {
            "status": result,
            "formal_tool_result_exists": not no_formal_result,
            "interpretation": "Mock output only."
        },
        "counterexample_analysis": {
            "status": "not_analyzed_in_mock_mode",
            "findings": []
        },
        "failure_classification": {
            "result_classification": result,
            "failure_categories": [str(x) for x in classification.get("failure_categories", [])],
            "severity": str(classification.get("severity") or "unknown"),
            "repair_needed": bool(classification.get("repair_needed", False)),
            "no_formal_tool_result": no_formal_result,
            "parsed_failure_count": int(classification.get("parsed_failure_count") or 0),
            "interpretation_boundary": str(
                classification.get("interpretation_boundary")
                or "Mock output only; raw Agent 7 evidence remains primary."
            )
        },
        "harness_vs_property_vs_tool_diagnosis": {
            "status": "not_analyzed_in_mock_mode",
            "root_cause_category": "unknown_in_mock_mode",
            "findings": []
        },
        "repair_guidance": {
            "status": "not_generated_in_mock_mode",
            "guidance_items": []
        },
        "repair_action_plan": [],
        "success_scope_analysis": {
            "status": "not_analyzed_in_mock_mode",
            "checked_scope": [],
            "not_checked": [],
            "limitations": []
        },
        "deterministic_reference_assessment": {
            "used": True,
            "status": "not_assessed_by_real_llm",
            "warning": "Mock output only.",
            "disagreements": []
        },
        "evidence_references": [],
        "limitations": [
            "Mock mode output only.",
            "No API-backed counterexample analysis was performed.",
            "Do not use this output as thesis evidence for LLM counterexample analysis performance.",
        ],
    }


def derive_repair_files_from_llm(layout: RunLayout, analysis: JsonDict) -> Dict[str, Path]:
    stage = "08_counterexample_analysis"
    outputs: Dict[str, Path] = {}

    repair_guidance = analysis.get("repair_guidance")
    if repair_guidance is None:
        repair_guidance = {
            "status": "missing_from_llm_output",
            "guidance_items": [],
        }

    repair_action_plan = analysis.get("repair_action_plan")
    if repair_action_plan is None:
        repair_action_plan = []

    outputs["repair_guidance"] = atomic_write_json(
        layout.llm_authoritative_dir(stage) / "07_repair_guidance.json",
        {
            "schema_version": "llm_derived_repair_guidance.v1",
            "created_utc": utc_now_iso(),
            "source": "07_counterexample_analysis.json",
            "content": repair_guidance,
            "trust_boundary": "llm_candidate_repair_guidance_not_applied",
        },
    )

    outputs["repair_action_plan"] = atomic_write_json(
        layout.llm_authoritative_dir(stage) / "07_repair_action_plan.json",
        {
            "schema_version": "llm_derived_repair_action_plan.v1",
            "created_utc": utc_now_iso(),
            "source": "07_counterexample_analysis.json",
            "content": repair_action_plan,
            "trust_boundary": "llm_candidate_repair_plan_not_applied",
        },
    )

    if isinstance(repair_action_plan, list):
        rows = []
        for item in repair_action_plan:
            if isinstance(item, dict):
                rows.append({
                    "action_id": item.get("action_id", ""),
                    "action_type": item.get("action_type", ""),
                    "priority": item.get("priority", ""),
                    "target_stage": item.get("target_stage", ""),
                    "proposed_change": item.get("proposed_change", ""),
                    "risk_if_applied": item.get("risk_if_applied", ""),
                })
        outputs["repair_action_plan_csv"] = write_csv(
            layout.validation_dir(stage) / "07_repair_action_plan.llm_summary.csv",
            rows,
        )

    return outputs


# ---------------------------------------------------------------------------
# Main runner
# ---------------------------------------------------------------------------

def _pre_agent7_readiness_context(
    frontend_readiness: Mapping[str, Any],
    review_gate: Mapping[str, Any],
    readiness_path: Optional[Path],
) -> Tuple[JsonDict, str, JsonDict, JsonDict]:
    readiness_class = str(
        frontend_readiness.get("classification") or "readiness_failed_before_tool_execution"
    )
    diagnosis = classify_readiness_failure(frontend_readiness)
    stderr = str(frontend_readiness.get("stderr") or "")
    status = {
        "schema_version": "pre_agent7_readiness_status.v2",
        "result_classification": CONTRACT_BUILD_FAILED,
        "tool_executed": False,
        "cbmc_tool_executed": False,
        "formal_property_evaluated": False,
        "selected_claim_result": "not_generated",
        "auxiliary_property_result": "unknown",
        "overall_model_result": "incomplete",
        "selected_property_verified_under_model": False,
        "repair_needed": True,
        "readiness_failure_before_agent7": True,
        "readiness_failure_classification": readiness_class,
        "readiness_failure_categories": diagnosis["failure_categories"],
        "readiness_diagnosis": diagnosis,
        "readiness_evidence": dict(frontend_readiness),
        "review_gate": dict(review_gate),
    }
    status_source = {
        "producer_stage": "06_review_critic",
        "output_key": "synthetic_pre_agent7_readiness_status",
        "available": True,
        "path": str(readiness_path) if readiness_path else None,
        "warning": None,
    }
    stderr_source = {
        "producer_stage": "06_review_critic",
        "output_key": "frontend_readiness_stderr",
        "available": bool(stderr),
        "path": str(readiness_path) if readiness_path else None,
        "warning": None if stderr else "Readiness record contained no stderr text.",
    }
    return status, stderr, status_source, stderr_source


def run_agent8(config_data: JsonDict, cfg: CounterexampleAnalysisConfig) -> int:
    stage = "08_counterexample_analysis"
    layout = RunLayout(cfg.run_dir, create=False, active_iteration=cfg.iteration)
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 8 Counterexample Analysis started.",
        data={"target_function": cfg.target_function, "target_topic": cfg.target_topic},
    )

    stage_status: JsonDict = {
        "schema_version": "agent_status.v1",
        **layout.protocol_context(),
        "stage": stage,
        "started_utc": utc_now_iso(),
        "completed_utc": None,
        "success": False,
        "llm_call_executed": False,
        "handoff_available": False,
        "errors": [],
        "warnings": [],
    }

    try:
        # --------------------------------------------------------------
        # 1. Load Agent 7 tool outputs.
        # --------------------------------------------------------------
        cbmc_status_path, cbmc_status, cbmc_status_status = load_handoff_json(layout, "07_tool_execution", "cbmc_status")
        cbmc_output_path, cbmc_output, cbmc_output_status = load_handoff_text(layout, "07_tool_execution", "cbmc_output", max_chars=cfg.max_cbmc_output_chars)
        cbmc_stderr_path, cbmc_stderr, cbmc_stderr_status = load_handoff_text(layout, "07_tool_execution", "cbmc_stderr", max_chars=cfg.max_cbmc_output_chars)
        property_results_path, property_results, property_results_status = load_handoff_json(layout, "07_tool_execution", "cbmc_property_results")
        trace_summary_path, trace_summary, trace_summary_status = load_handoff_json(layout, "07_tool_execution", "cbmc_trace_summary")
        failed_mapping_path, failed_mapping, failed_mapping_status = load_handoff_json(layout, "07_tool_execution", "failed_property_mapping")
        command_manifest_path, command_manifest, command_manifest_status = load_handoff_json(layout, "07_tool_execution", "tool_command_manifest")
        env_snapshot_path, env_snapshot, env_snapshot_status = load_handoff_json(layout, "07_tool_execution", "tool_environment_snapshot")
        diagnostics_path, cbmc_diagnostics, diagnostics_status = load_handoff_json(layout, "07_tool_execution", "cbmc_diagnostics")

        # Context from earlier stages, if available.
        harness_path, harness_text, harness_status = load_handoff_text(layout, "06_review_critic", "generated_harness_under_review", max_chars=cfg.max_harness_chars)
        artifact_plan_path, artifact_plan, artifact_plan_status = load_handoff_json(layout, "05_artifact_generation", "artifact_plan")
        critic_review_path, critic_review, critic_review_status = load_handoff_json(layout, "06_review_critic", "critic_review")
        gate_path, review_gate, gate_status = load_handoff_json(layout, "06_review_critic", "review_gate_decision")
        readiness_path, frontend_readiness, readiness_status = load_handoff_json(
            layout, "06_review_critic", "frontend_parse_and_build_readiness"
        )
        formal_plan_path, formal_plan, formal_plan_status = load_handoff_json(
            layout, "06_review_critic", "formal_build_plan"
        )

        # Agent 8 also diagnoses hard readiness failures that occur before Agent 7.
        # This is objective tool evidence, not a fabricated CBMC solving result.
        readiness_diagnosis_mode = bool(not cbmc_status and frontend_readiness)
        if readiness_diagnosis_mode:
            cbmc_status, cbmc_stderr, cbmc_status_status, cbmc_stderr_status = (
                _pre_agent7_readiness_context(frontend_readiness, review_gate, readiness_path)
            )
            cbmc_output = ""

        statuses = {
            "cbmc_status": cbmc_status_status,
            "cbmc_output": cbmc_output_status,
            "cbmc_stderr": cbmc_stderr_status,
            "cbmc_property_results": property_results_status,
            "cbmc_trace_summary": trace_summary_status,
            "failed_property_mapping": failed_mapping_status,
            "tool_command_manifest": command_manifest_status,
            "tool_environment_snapshot": env_snapshot_status,
            "cbmc_diagnostics": diagnostics_status,
            "generated_harness": harness_status,
            "artifact_plan": artifact_plan_status,
            "critic_review": critic_review_status,
            "review_gate_decision": gate_status,
            "frontend_parse_and_build_readiness": readiness_status,
            "formal_build_plan": formal_plan_status,
        }
        availability = {k: bool(v.get("available")) for k, v in statuses.items()}

        required = ["cbmc_status"]
        missing_required = [k for k in required if not availability.get(k)]
        if missing_required and not cfg.allow_missing_tool_outputs:
            raise FileNotFoundError(
                f"Agent 8 requires Agent 7 tool outputs. Missing: {missing_required}. "
                "Use --allow-missing-tool-outputs only for wiring tests."
            )

        for k, st in statuses.items():
            if not st.get("available"):
                stage_status["warnings"].append(f"{k} unavailable: {st.get('warning')}")

        # --------------------------------------------------------------
        # 2. Deterministic diagnostic analysis.
        # --------------------------------------------------------------
        cbmc_output = cbmc_output or ""
        cbmc_stderr = cbmc_stderr or ""

        det = deterministic_counterexample_analysis(
            cbmc_status=cbmc_status,
            cbmc_output=cbmc_output,
            cbmc_stderr=cbmc_stderr,
            property_results=property_results,
            trace_summary=trace_summary,
            failed_mapping=failed_mapping,
            harness_text=harness_text,
        )

        previous_inputs_record = layout.write_deterministic_reference_json(
            stage,
            "07_previous_stage_input_status.json",
            {
                "trust_boundary": "tool_outputs_are_primary_evidence_previous_llm_outputs_are_context",
                "statuses": statuses,
                "availability": availability,
                "result_classification": det.get("classification", {}).get("result_classification"),
            },
        )

        deterministic_paths = write_deterministic_files(layout, det)
        deterministic_paths["previous_stage_input_status"] = previous_inputs_record

        deterministic_bundle = {
            "deterministic_counterexample_analysis": det,
            "previous_stage_input_status": {
                "statuses": statuses,
                "availability": availability,
            },
            "tool_evidence_preview": {
                "cbmc_status": cbmc_status,
                "cbmc_property_results": property_results,
                "cbmc_trace_summary": trace_summary,
                "failed_property_mapping": failed_mapping,
                "cbmc_diagnostics": cbmc_diagnostics,
                "command_manifest": command_manifest,
                "review_gate": review_gate,
                "artifact_plan": artifact_plan,
                "critic_review": critic_review,
                "frontend_parse_and_build_readiness": frontend_readiness,
                "formal_build_plan": formal_plan,
                "readiness_diagnosis_mode": readiness_diagnosis_mode,
            },
        }

        # --------------------------------------------------------------
        # 3. LLM analysis.
        # --------------------------------------------------------------
        result_classification = det.get("classification", {}).get("result_classification", "unknown")
        prompt_text = build_agent8_prompt(cfg, availability, result_classification)

        run_config_for_client = dict(config_data)
        if cfg.llm_mode_override:
            llm_cfg = dict(run_config_for_client.get("llm") or {})
            llm_cfg["mode"] = cfg.llm_mode_override
            run_config_for_client["llm"] = llm_cfg

        client = LLMClient.from_run_config(run_config_for_client)

        primary_files = existing_unique_paths(
            canonical_raw_evidence_files(config_data, include_specs=True, include_code=True)
            + [p for p in [
                cbmc_status_path, cbmc_output_path, cbmc_stderr_path,
                command_manifest_path, env_snapshot_path, readiness_path, formal_plan_path,
            ] if p]
        )
        # Parsed property/trace/failure summaries and diagnostics are deliberately
        # carried only in deterministic_reference_bundle as fallible advisory data.
        prior_context_files = existing_unique_paths(
            [p for p in [harness_path, artifact_plan_path, critic_review_path, gate_path] if p]
        )
        prior_authoritative_context = {
            "artifact_plan": artifact_plan,
            "critic_review": critic_review,
            "review_gate": review_gate,
            "frontend_parse_and_build_readiness": frontend_readiness,
            "formal_build_plan": formal_plan,
        }

        request = LLMStageRequest(
            stage=stage,
            prompt_text=prompt_text,
            output_filename="07_counterexample_analysis.json",
            json_schema=COUNTEREXAMPLE_ANALYSIS_SCHEMA,
            primary_evidence_files=primary_files,
            prior_authoritative_context_files=prior_context_files,
            prior_authoritative_context_bundle=prior_authoritative_context,
            deterministic_reference_bundle=deterministic_bundle,
            extra_prompt_metadata={
                "agent": "Agent 8 Counterexample Analysis",
                "target_function": cfg.target_function,
                "target_topic": cfg.target_topic,
                "result_classification": result_classification,
                "available_inputs": availability,
                "readiness_diagnosis_mode": readiness_diagnosis_mode,
                "trust_boundary": {
                    "raw_cbmc_output": "primary_tool_evidence",
                    "cbmc_status": "primary_tool_status_record",
                    "deterministic_diagnostics": "advisory_only",
                    "llm_output": "authoritative_stage_candidate_analysis_not_formal_truth",
                    "formal_truth": "not_claimed",
                },
            },
            mock_response_content=build_mock_counterexample_analysis(cfg, det),
        )

        result = client.run_stage(layout, request)
        stage_status["llm_call_executed"] = result.llm_call_executed
        stage_status["llm_mode"] = result.mode
        stage_status["llm_success"] = result.success
        record_llm_stage_failure(stage_status, result)

        # --------------------------------------------------------------
        # 4. Derive repair guidance/action plan files from LLM output.
        # --------------------------------------------------------------
        llm_outputs: Dict[str, Path] = {}
        validation_outputs: Dict[str, Path] = {}
        prompt_outputs: Dict[str, Path] = {}
        derived_outputs: Dict[str, Path] = {}

        if result.success and result.output_path:
            try:
                analysis_wrapped = read_json_file(result.output_path)
                analysis = extract_content_wrapper(analysis_wrapped)
                derived_outputs = derive_repair_files_from_llm(layout, analysis)
            except Exception as exc:
                validation_outputs["repair_derivation_error"] = layout.write_validation_json(
                    stage,
                    "07_repair_derivation_error.json",
                    {"error": f"{type(exc).__name__}: {exc}"},
                )

        # --------------------------------------------------------------
        # 5. Handoff manifest.
        # --------------------------------------------------------------
        if result.success and result.output_path:
            handoff_outputs: Dict[str, Path] = {
                "counterexample_analysis": Path(result.output_path),
            }
            if result.validation_path:
                handoff_outputs["counterexample_analysis_validation"] = Path(result.validation_path)

            for key in ["repair_guidance", "repair_action_plan", "repair_action_plan_csv"]:
                if key in derived_outputs:
                    handoff_outputs[key] = derived_outputs[key]

            # Diagnostics for Agent 9 context.
            handoff_outputs["deterministic_counterexample_diagnostics"] = deterministic_paths["counterexample_analysis_deterministic"]
            handoff_outputs["failure_classification_matrix"] = deterministic_paths["failure_classification_matrix"]
            handoff_outputs["tool_vs_harness_vs_code_diagnosis"] = deterministic_paths["tool_vs_harness_vs_code_diagnosis"]

            layout.write_handoff_manifest(
                stage,
                outputs=handoff_outputs,
                authoritative_source="llm_authoritative",
                next_stage_consumers=[
                    "09_repair_refinement",
                    "10_experiment_logger",
                    "11_evaluation_reporter",
                ],
                notes={
                    "handoff_policy": (
                        "counterexample_analysis is LLM-authoritative stage candidate analysis. "
                        "repair_guidance/action_plan are LLM-derived candidate guidance, not applied repairs."
                    ),
                    "llm_mode": result.mode,
                    "llm_call_executed": result.llm_call_executed,
                    "mock_output": result.mode == "mock",
                    "result_classification": result_classification,
                    "raw_cbmc_output_remains_primary_evidence": True,
                    "formal_truth_claimed": False,
                },
            )
            stage_status["handoff_available"] = True
            stage_status["success"] = True
        else:
            message = "No authoritative LLM counterexample analysis was produced."
            stage_status["warnings"].append(message)
            if cfg.allow_empty_handoff_on_failure:
                layout.write_handoff_manifest(
                    stage,
                    outputs={
                        "deterministic_counterexample_diagnostics": deterministic_paths["counterexample_analysis_deterministic"]
                    },
                    authoritative_source="deterministic_diagnostics_only_llm_failed_or_disabled",
                    next_stage_consumers=["10_experiment_logger", "11_evaluation_reporter"],
                    notes={
                        "handoff_policy": "LLM counterexample analysis unavailable; only deterministic diagnostics handed off.",
                        "llm_result": result.to_dict(),
                        "formal_truth_claimed": False,
                    },
                )

        # --------------------------------------------------------------
        # 6. Stage manifest.
        # --------------------------------------------------------------
        if result.output_path:
            llm_outputs["counterexample_analysis"] = Path(result.output_path)
        if result.raw_response_path:
            llm_outputs["raw_llm_response"] = Path(result.raw_response_path)
        if result.validation_path:
            validation_outputs["llm_call_validation"] = Path(result.validation_path)
        for k, p in derived_outputs.items():
            if p.exists():
                llm_outputs[k] = p

        if result.prompt_path:
            prompt_outputs["prompt"] = Path(result.prompt_path)
        if result.metadata_path:
            prompt_outputs["prompt_metadata"] = Path(result.metadata_path)
        pdir = layout.prompt_package_dir(stage)
        for name in ["deterministic_reference_bundle.json", "primary_evidence_manifest.json"]:
            p = pdir / name
            if p.exists():
                prompt_outputs[name.replace(".json", "")] = p

        layout.write_stage_manifest(
            stage,
            primary_evidence_inputs=[str(p) for p in primary_files],
            deterministic_reference_outputs=deterministic_paths,
            prompt_package_outputs=prompt_outputs,
            llm_authoritative_outputs=llm_outputs,
            validation_outputs=validation_outputs,
            notes={
                "agent_version": "agent8_counterexample_analysis_refactored.v2.iteration_contract",
                "iteration": cfg.iteration,
                "deterministic_reference_policy": "diagnostic_advisory_only",
                "raw_cbmc_output_primary": True,
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
                "formal_truth_claimed": False,
                "result_classification": result_classification,
            },
        )

        stage_status["completed_utc"] = utc_now_iso()
        atomic_write_json(layout.logs_dir(stage) / "08_counterexample_analysis_status.json", stage_status)

        layout.log_event(
            event_type="stage_completed" if stage_status["success"] else "stage_completed_without_llm_analysis",
            stage=stage,
            message="Agent 8 Counterexample Analysis completed.",
            data={
                "success": stage_status["success"],
                "handoff_available": stage_status["handoff_available"],
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
                "result_classification": result_classification,
            },
        )

        return 0 if stage_status["success"] else 2

    except Exception as exc:
        stage_status["completed_utc"] = utc_now_iso()
        stage_status["success"] = False
        stage_status["errors"].append({
            "type": type(exc).__name__,
            "message": str(exc),
            "traceback": traceback.format_exc(),
        })

        ensure_dir(layout.logs_dir(stage))
        atomic_write_json(layout.logs_dir(stage) / "08_counterexample_analysis_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 8 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        try:
            layout.write_stage_manifest(
                stage,
                notes={
                    "agent_version": "agent8_counterexample_analysis_refactored.v1",
                    "failed": True,
                    "error": f"{type(exc).__name__}: {exc}",
                },
            )
        except Exception:
            pass

        return 1


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Agent 8 — refactored LLM-backed Counterexample Analysis Agent")
    parser.add_argument("--config", help="Path to run config JSON.")
    parser.add_argument("--run-dir", help="Override run directory.")
    parser.add_argument("--target-function", help="Implementation function name, e.g. mlk_poly_add.")
    parser.add_argument("--target-topic", help="Human-readable target topic.")
    parser.add_argument("--allow-missing-tool-outputs", action="store_true", help="Allow missing Agent 7 outputs only for wiring tests.")
    parser.add_argument("--llm-mode", choices=["real", "mock", "disabled"], help="Override llm.mode from config.")
    parser.add_argument("--iteration", type=int, default=0, help="Counterexample-analysis iteration number (>= 0).")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    if args.iteration < 0:
        parser.error("--iteration must be >= 0")
    config_data, cfg = load_config(args)
    return run_agent8(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
