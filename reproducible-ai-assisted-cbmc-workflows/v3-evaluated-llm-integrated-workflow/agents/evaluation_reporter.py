#!/usr/bin/env python3
"""
evaluation_reporter_agent_refactored.py

Agent 11 — Evaluation Reporter Agent, refactored for the new thesis workflow.

Architecture implemented:
- Mixed evaluation stage:
  - Deterministic measured facts come from Agent 10 experiment log and prior manifests.
  - Optional LLM-backed narrative/reporting produces thesis-safe interpretation.
- Consumes Agent 10 reproducibility/evidence indexes through handoff manifest.
- Does not invent facts.
- Does not reinterpret raw CBMC output beyond logged evidence.
- Separates measured facts, candidate interpretation, limitations, and thesis wording.
- Produces:
    stages/11_evaluation_reporter/deterministic_reference/10_measured_evaluation_facts.json
    stages/11_evaluation_reporter/llm_authoritative/10_evaluation_report.json
    stages/11_evaluation_reporter/final_report/10_evaluation_report.md
- Downstream consumers use manifest-declared outputs only.
- No root-level output dumping.
- No duplicate output copies.

Trust boundary:
- Agent 11 does not prove anything.
- Agent 11 does not claim full ML-KEM correctness, FIPS compliance, cryptographic security,
  or whole-program verification.
- Evaluation statements are bounded by the recorded run evidence.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import platform
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
    from agents.common.llm_client import LLMClient, LLMStageRequest
    from agents.common.prompt_templates import build_common_stage_prompt
    from agents.common.schemas import EVALUATION_REPORT_SCHEMA
except Exception as import_exc:  # pragma: no cover
    raise SystemExit(
        "Failed to import shared workflow modules. Ensure these files exist and schemas.py includes EVALUATION_REPORT_SCHEMA:\n"
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


def sha256_file(path: PathLike) -> Optional[str]:
    import hashlib
    p = Path(path)
    if not p.exists() or not p.is_file():
        return None
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


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


def safe_relative(path: Path, base: Path) -> str:
    try:
        return str(path.relative_to(base))
    except Exception:
        return str(path)


# Agent 11 receives a curated but direct view of the underlying run evidence.
# Agent 10 indexes remain trusted measured facts; they do not replace the raw
# model responses, artefacts, tool output, or previous candidate-stage outputs.
# Exact request snapshots remain preserved and indexed for reproducibility audit.
_AGENT11_PRIOR_CANDIDATE_KEYS = {
    "spec_summary", "code_summary", "candidate_properties", "artifact_plan",
    "critic_review", "counterexample_analysis", "repair_guidance",
    "repair_action_plan", "repair_plan",
}
_AGENT11_RAW_ARTEFACT_KEYS = {
    "generated_harness", "artifact_manifest", "repaired_harness", "repair_diff",
}
_AGENT11_TRUSTED_CONTROL_KEYS = {
    "review_gate_decision", "formal_build_plan", "independence_audit",
    "repair_manifest_update", "repair_safety_review",
}
_AGENT11_RAW_TOOL_KEYS = {
    "cbmc_status", "cbmc_output", "cbmc_stderr", "tool_command_manifest",
    "tool_environment_snapshot",
}


def _path_from_record(value: Any) -> Optional[Path]:
    if isinstance(value, str) and value:
        p = Path(value).expanduser().resolve()
        return p if p.exists() and p.is_file() else None
    if isinstance(value, Mapping):
        for key in ("path", "resolved_path", "request_snapshot_path", "response_path"):
            candidate = value.get(key)
            if isinstance(candidate, str) and candidate:
                p = Path(candidate).expanduser().resolve()
                if p.exists() and p.is_file():
                    return p
    return None


def collect_agent11_direct_evidence(
    *,
    config_data: Mapping[str, Any],
    run_dir: Path,
    handoff_index: JsonDict,
    llm_index: JsonDict,
    tool_index: JsonDict,
) -> Tuple[List[Path], List[Path], List[Path]]:
    """Return (raw_primary, prior_candidate_context, trusted_control_facts).

    This is intentionally selective: Agent 10's indexes are still the compact
    measured-fact authority, while Agent 11 receives the underlying high-value
    files needed to verify narrative claims against raw run evidence.
    """
    raw_primary: List[Path] = list(canonical_raw_evidence_files(config_data))
    prior_context: List[Path] = []
    trusted_control: List[Path] = []

    rows = handoff_index.get("handoff_outputs", []) if isinstance(handoff_index, Mapping) else []
    if isinstance(rows, list):
        for row in rows:
            if not isinstance(row, Mapping) or not row.get("exists"):
                continue
            key = str(row.get("output_key") or "")
            producer = str(row.get("producer_stage") or "")
            if producer in {"10_experiment_logger", "11_evaluation_reporter"}:
                continue
            path = _path_from_record(row.get("resolved_path"))
            if path is None:
                continue
            if key in _AGENT11_PRIOR_CANDIDATE_KEYS:
                prior_context.append(path)
            elif key in _AGENT11_RAW_ARTEFACT_KEYS:
                raw_primary.append(path)
            elif key in _AGENT11_TRUSTED_CONTROL_KEYS:
                trusted_control.append(path)

    tool_rows = tool_index.get("evidence_files", []) if isinstance(tool_index, Mapping) else []
    if isinstance(tool_rows, list):
        for row in tool_rows:
            if not isinstance(row, Mapping) or not row.get("exists"):
                continue
            if str(row.get("evidence_key") or "") not in _AGENT11_RAW_TOOL_KEYS:
                continue
            path = _path_from_record(row.get("path"))
            if path is not None:
                raw_primary.append(path)

    # Raw API responses are direct model-output evidence.
    #
    # Exact request snapshots remain preserved unchanged and indexed by
    # Agent 10 for reproducibility and human audit. They are deliberately not
    # re-transmitted recursively as Agent 11 raw primary evidence because each
    # request envelope embeds earlier prompts and evidence, can be very large,
    # and does not constitute an independent additional evidence source.
    llm_rows = llm_index.get("rows", []) if isinstance(llm_index, Mapping) else []
    if isinstance(llm_rows, list):
        for row in llm_rows:
            if not isinstance(row, Mapping):
                continue
            response = _path_from_record(row.get("raw_response_path"))
            if response is not None:
                raw_primary.append(response)

    # Human-review notes, when present, are direct run evidence rather than
    # model-generated interpretation.
    for human_dir in sorted(run_dir.glob("stages/*/human_review")):
        if human_dir.is_dir():
            raw_primary.extend(p for p in sorted(human_dir.rglob("*")) if p.is_file())

    return (
        existing_unique_paths(raw_primary),
        existing_unique_paths(prior_context),
        existing_unique_paths(trusted_control),
    )


# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

@dataclass
class EvaluationReporterConfig:
    run_dir: Path
    target_function: str = "mlk_poly_add"
    target_topic: str = "ML-KEM workflow evaluation"
    property_family_id: str = "P16"
    verification_strategy: str = "standard_cbmc_harness"
    property_support_classification: str = "production_supported"
    llm_mode_override: Optional[str] = None
    allow_missing_experiment_log: bool = False
    allow_empty_handoff_on_failure: bool = True
    include_thesis_wording: bool = True
    include_rq_mapping: bool = True
    include_failure_taxonomy: bool = True
    include_threats_to_validity: bool = True
    max_report_context_chars: int = 220_000


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


def load_config(args: argparse.Namespace) -> Tuple[JsonDict, EvaluationReporterConfig]:
    config_data: JsonDict = {}
    if args.config:
        config_path = Path(args.config).expanduser().resolve()
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        config_data = load_normalized_config(config_path)

    er = config_data.get("evaluation_reporter", {})
    if not isinstance(er, dict):
        er = {}

    target_function = (
        args.target_function
        or str(config_data.get("target_function") or "")
        or str(config_data.get("function_name") or "")
        or "mlk_poly_add"
    )

    target_topic = (
        args.target_topic
        or str(config_data.get("target_topic") or "")
        or f"Workflow evaluation for {target_function}"
    )

    campaign = config_data.get("property_campaign", {}) if isinstance(config_data.get("property_campaign"), dict) else {}

    cfg = EvaluationReporterConfig(
        run_dir=resolve_run_dir(config_data, args),
        target_function=target_function,
        target_topic=target_topic,
        property_family_id=str(campaign.get("property_family_id") or "P16"),
        verification_strategy=str(campaign.get("verification_strategy") or "standard_cbmc_harness"),
        property_support_classification=str(campaign.get("support_level") or "production_supported"),
        llm_mode_override=args.llm_mode,
        allow_missing_experiment_log=bool(args.allow_missing_experiment_log or er.get("allow_missing_experiment_log")),
        include_thesis_wording=bool(er.get("include_thesis_wording", True)),
        include_rq_mapping=bool(er.get("include_rq_mapping", True)),
        include_failure_taxonomy=bool(er.get("include_failure_taxonomy", True)),
        include_threats_to_validity=bool(er.get("include_threats_to_validity", True)),
        max_report_context_chars=int(er.get("max_report_context_chars", 220_000)),
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
# Evaluation extraction
# ---------------------------------------------------------------------------

def get_item_summary(index: Optional[JsonDict], key: str) -> Optional[Any]:
    if not isinstance(index, dict):
        return None
    items = index.get("items")
    if isinstance(items, dict) and isinstance(items.get(key), dict):
        return items[key].get("summary")
    return None


def get_tool_summary(tool_index: Optional[JsonDict]) -> JsonDict:
    if not isinstance(tool_index, dict):
        return {}
    status = tool_index.get("cbmc_status_summary") or {}
    if isinstance(status, dict) and isinstance(status.get("content"), dict):
        status = status["content"]
    return status if isinstance(status, dict) else {}


def build_measured_evaluation_facts(
    *,
    cfg: EvaluationReporterConfig,
    experiment_log: Optional[JsonDict],
    run_record: Optional[JsonDict],
    stage_index: Optional[JsonDict],
    handoff_index: Optional[JsonDict],
    checksum_manifest: Optional[JsonDict],
    llm_index: Optional[JsonDict],
    tool_index: Optional[JsonDict],
    gate_and_repair_index: Optional[JsonDict],
    failure_mode_log: Optional[JsonDict],
    integrity_validation: Optional[JsonDict],
    missing_outputs: Optional[JsonDict],
) -> JsonDict:
    exp_summary = {}
    if isinstance(experiment_log, dict):
        exp_summary = experiment_log.get("summary") if isinstance(experiment_log.get("summary"), dict) else {}

    stage_rows = stage_index.get("rows", []) if isinstance(stage_index, dict) else []
    handoff_rows = handoff_index.get("handoff_outputs", []) if isinstance(handoff_index, dict) else []
    checksum_rows = checksum_manifest.get("rows", []) if isinstance(checksum_manifest, dict) else []
    llm_rows = llm_index.get("rows", []) if isinstance(llm_index, dict) else []

    tool_summary = get_tool_summary(tool_index)
    gate_summary = get_item_summary(gate_and_repair_index, "review_gate_decision")
    independence_summary = get_item_summary(gate_and_repair_index, "independence_audit")
    cex_summary = get_item_summary(gate_and_repair_index, "counterexample_analysis")
    repair_summary = get_item_summary(gate_and_repair_index, "repair_plan")
    repair_manifest_summary = get_item_summary(gate_and_repair_index, "repair_manifest_update")
    repair_safety_summary = get_item_summary(gate_and_repair_index, "repair_safety_review")

    llm_mode_counts: Dict[str, int] = {}
    llm_validation_success_count = 0
    llm_executed_count = 0
    for row in llm_rows:
        mode = str(row.get("mode") or "unknown")
        llm_mode_counts[mode] = llm_mode_counts.get(mode, 0) + 1
        if row.get("llm_call_executed"):
            llm_executed_count += 1
        if row.get("success") or row.get("schema_validation_success"):
            llm_validation_success_count += 1

    missing_count = missing_outputs.get("missing_count") if isinstance(missing_outputs, dict) else None
    integrity_status = integrity_validation.get("validation_status") if isinstance(integrity_validation, dict) else None

    cbmc_result = tool_summary.get("result_classification")
    cbmc_executed = tool_summary.get("tool_executed")

    # Deterministic usefulness classification.
    if cbmc_result == "verification_successful":
        tool_outcome_category = "property_checked_successfully_under_recorded_scope"
    elif cbmc_result == "verification_failed":
        tool_outcome_category = "counterexample_or_check_failure_available_for_analysis"
    elif cbmc_result == "analysis_only_no_formal_tool_claim":
        tool_outcome_category = "analysis_only_evidence_no_formal_result"
    elif cbmc_result in {"skipped_by_review_gate", "dry_run_not_executed", "tool_unavailable"}:
        tool_outcome_category = "no_formal_tool_result_for_property"
    elif cbmc_result in {"tool_error_or_nonzero_exit", "tool_timeout", "contract_build_or_instrumentation_failed"}:
        tool_outcome_category = "tool_or_model_transformation_problem"
    else:
        tool_outcome_category = "unknown_or_incomplete_tool_outcome"

    measured = {
        "schema_version": "measured_evaluation_facts.v1",
        "created_utc": utc_now_iso(),
        "stage": "11_evaluation_reporter",
        "target_function": cfg.target_function,
        "target_topic": cfg.target_topic,
        "property_family_id": cfg.property_family_id,
        "verification_strategy": cfg.verification_strategy,
        "property_support_classification": cfg.property_support_classification,
        "source": "Agent 10 experiment log and run indexes",
        "run_summary": exp_summary,
        "counts": {
            "expected_stage_count": len(stage_rows),
            "indexed_stage_record_count": len(stage_rows),
            "stage_manifest_count": sum(1 for row in stage_rows if row.get("manifest_exists")),
            "missing_stage_manifest_count": sum(1 for row in stage_rows if not row.get("manifest_exists")),
            "handoff_output_count": len(handoff_rows),
            "checksum_count": len(checksum_rows),
            "llm_stage_count": len(llm_rows),
            "llm_call_executed_count": llm_executed_count,
            "llm_validation_success_or_schema_success_count": llm_validation_success_count,
            "missing_expected_output_count": missing_count,
        },
        "llm_mode_counts": llm_mode_counts,
        "tool_evidence": {
            "cbmc_result_classification": cbmc_result,
            "cbmc_tool_executed": cbmc_executed,
            "tool_outcome_category": tool_outcome_category,
            "exit_code": tool_summary.get("exit_code"),
            "execution_skipped": tool_summary.get("execution_skipped"),
            "dry_run": tool_summary.get("dry_run"),
            "tool_unavailable": tool_summary.get("tool_unavailable"),
            "timeout": tool_summary.get("timeout"),
            "formal_claim_boundary": tool_summary.get("formal_claim_boundary"),
        },
        "review_and_repair_evidence": {
            "review_gate": gate_summary,
            "independence_audit": independence_summary,
            "counterexample_analysis_summary": cex_summary,
            "repair_plan_summary": repair_summary,
            "repair_manifest_update": repair_manifest_summary,
            "repair_safety_review": repair_safety_summary,
        },
        "integrity": {
            "validation_status": integrity_status,
            "warning_count": integrity_validation.get("warning_count") if isinstance(integrity_validation, dict) else None,
            "error_count": integrity_validation.get("error_count") if isinstance(integrity_validation, dict) else None,
            "missing_expected_output_count": missing_count,
        },
        "report_eligibility": {
            "scientific_result_reporting_allowed": (
                integrity_status in {"valid", "valid_with_warnings"}
                and llm_executed_count > 0
            ),
            # Even a successful CBMC result must remain explicitly scoped to the
            # recorded harness, assertions, assumptions, unwind bounds, and build.
            "unqualified_success_wording_allowed": False,
            "diagnostic_or_wiring_reporting_allowed": True,
            "human_review_required": True,
            "reason": (
                "Run provenance/integrity is invalid; report may describe diagnostic evidence only."
                if integrity_status == "invalid"
                else (
                    "No real LLM/API stage executed; this run may be reported only as mock, disabled, or wiring evidence."
                    if llm_executed_count == 0
                    else "Real API-backed evidence is present, but reporting remains bounded and requires human review."
                )
            ),
        },
        "evidence_availability": {
            "experiment_log_available": bool(experiment_log),
            "run_record_available": bool(run_record),
            "stage_index_available": bool(stage_index),
            "handoff_index_available": bool(handoff_index),
            "checksum_manifest_available": bool(checksum_manifest),
            "llm_index_available": bool(llm_index),
            "tool_index_available": bool(tool_index),
            "gate_and_repair_index_available": bool(gate_and_repair_index),
            "failure_mode_log_available": bool(failure_mode_log),
            "integrity_validation_available": bool(integrity_validation),
        },
        "claim_boundary": {
            "facts_are_logged_measurements": True,
            "interpretation_is_candidate": True,
            "proof_claimed": False,
            "full_correctness_claimed": False,
            "fips_compliance_claimed": False,
            "cryptographic_security_claimed": False,
            "whole_program_verification_claimed": False,
        },
    }

    return measured


def build_failure_mode_taxonomy(measured: JsonDict, failure_mode_log: Optional[JsonDict]) -> JsonDict:
    tool = measured.get("tool_evidence", {})
    result = tool.get("cbmc_result_classification")
    category = tool.get("tool_outcome_category")

    rows = []

    def add(tax_id: str, label: str, observed: bool, evidence: str, implication: str):
        rows.append({
            "taxonomy_id": tax_id,
            "label": label,
            "observed_in_run": observed,
            "evidence_basis": evidence,
            "evaluation_implication": implication,
        })

    add(
        "FM_TOOL_001",
        "No formal-tool result because execution was skipped, dry-run, or unavailable",
        result in {"skipped_by_review_gate", "dry_run_not_executed", "tool_unavailable"},
        f"cbmc_result_classification={result}",
        "The run cannot be used as CBMC verification evidence for the candidate property."
    )
    add(
        "FM_TOOL_002",
        "CBMC/tool execution error or timeout",
        result in {"tool_error_or_nonzero_exit", "tool_timeout"},
        f"cbmc_result_classification={result}",
        "The next step should address build/tool/unwind/environment problems before semantic conclusions."
    )
    add(
        "FM_PROP_001",
        "Verification failure/counterexample available",
        result == "verification_failed",
        f"cbmc_result_classification={result}",
        "The counterexample analysis and repair/refinement stages become relevant."
    )
    add(
        "FM_SCOPE_001",
        "Verification success is property-specific and scope-limited",
        result == "verification_successful",
        f"cbmc_result_classification={result}",
        "The success supports only the harness/property/assumption scope, not full ML-KEM correctness."
    )

    gate = measured.get("review_and_repair_evidence", {}).get("review_gate") or {}
    add(
        "FM_REVIEW_001",
        "Review gate prevented tool execution",
        isinstance(gate, dict) and gate.get("tool_execution_allowed") is False,
        f"review_gate={gate}",
        "Human review or artefact revision is required before claiming a real tool-execution attempt."
    )

    return {
        "schema_version": "failure_mode_taxonomy.v1",
        "created_utc": utc_now_iso(),
        "result_classification": result,
        "tool_outcome_category": category,
        "rows": rows,
        "limitations": [
            "This taxonomy is derived from logged run evidence.",
            "It does not infer implementation bugs without supporting CBMC/tool evidence.",
        ],
    }


def build_rq_mapping(measured: JsonDict, taxonomy: JsonDict) -> JsonDict:
    tool = measured.get("tool_evidence", {})
    counts = measured.get("counts", {})
    llm_modes = measured.get("llm_mode_counts", {})

    rows = [
        {
            "research_question": "RQ1",
            "question_focus": "Transform selected PQC specification/code context into candidate CBMC-style artefacts using an API-backed LLM workflow.",
            "run_evidence": [
                f"LLM-stage records indexed: {counts.get('llm_stage_count')}",
                f"LLM-call executed count: {counts.get('llm_call_executed_count')}",
                f"LLM modes observed: {llm_modes}",
                "Agent 5 artefact plan and rendered harness are indexed when available.",
            ],
            "supported_statement": (
                "The run can support a bounded statement about whether the workflow produced candidate intermediate artefacts, "
                "subject to whether stages were real API mode or mock mode."
            ),
            "not_supported_statement": (
                "The run does not establish that the artefacts are correct, complete, verified, or generally reusable."
            ),
        },
        {
            "research_question": "RQ2",
            "question_focus": "Use high-assurance PQC/formal-methods workflow ideas to structure the ML-KEM/CBMC case study.",
            "run_evidence": [
                "Stages separate candidate generation, review, formal-tool execution, repair, logging, and evaluation.",
                "Agent 7 records property-specific CBMC evidence separately from LLM interpretation.",
                "Agent 10 records checksums/manifests for reproducibility.",
            ],
            "supported_statement": (
                "The run can support evaluation of the workflow structure and trust boundaries."
            ),
            "not_supported_statement": (
                "The run does not compare against all high-assurance PQC verification frameworks or prove equivalence to them."
            ),
        },
        {
            "research_question": "RQ3",
            "question_focus": "Evaluate usefulness, failure modes, and human-correction needs after review, correction, and CBMC checking.",
            "run_evidence": [
                f"CBMC result classification: {tool.get('cbmc_result_classification')}",
                f"Tool executed: {tool.get('cbmc_tool_executed')}",
                f"Failure-mode taxonomy entries: {len(taxonomy.get('rows', []))}",
                "Review gate, counterexample analysis, repair, and logger outputs are indexed where available.",
            ],
            "supported_statement": (
                "The run can support a case-study evaluation of observed workflow usefulness and failure modes."
            ),
            "not_supported_statement": (
                "The run does not support broad statistical claims unless repeated over multiple functions/runs."
            ),
        },
    ]

    return {
        "schema_version": "rq_mapping.v1",
        "created_utc": utc_now_iso(),
        "rows": rows,
    }


def build_threats_to_validity(measured: JsonDict) -> JsonDict:
    tool = measured.get("tool_evidence", {})
    llm_modes = measured.get("llm_mode_counts", {})
    integrity = measured.get("integrity", {})

    threats = [
        {
            "threat_id": "TV_SCOPE_001",
            "category": "scope",
            "threat": "The run is a selected-function case study, not whole-implementation verification.",
            "mitigation": "Report the exact target function, property, harness, assumptions, and CBMC command.",
        },
        {
            "threat_id": "TV_TOOL_001",
            "category": "tool evidence",
            "threat": "CBMC output is property-specific and harness-specific.",
            "mitigation": "Use Agent 7 command/status/output and avoid full-correctness claims.",
        },
        {
            "threat_id": "TV_LLM_001",
            "category": "LLM usage",
            "threat": f"Some or all LLM stages may be mock/disabled rather than real API mode: {llm_modes}.",
            "mitigation": "Separate mock wiring tests from real API-backed experimental runs.",
        },
        {
            "threat_id": "TV_REPRO_001",
            "category": "reproducibility",
            "threat": f"Integrity validation status is {integrity.get('validation_status')}.",
            "mitigation": "Use Agent 10 checksums, handoff index, and replay manifest.",
        },
        {
            "threat_id": "TV_GENERAL_001",
            "category": "generalisation",
            "threat": "A single target function/run cannot justify broad claims about all ML-KEM or PQC code.",
            "mitigation": "Frame findings as case-study evidence and discuss need for more functions/runs.",
        },
    ]

    if tool.get("cbmc_tool_executed") is False:
        threats.append({
            "threat_id": "TV_NO_TOOL_001",
            "category": "tool execution",
            "threat": "The run did not execute CBMC successfully, so it cannot provide verification evidence.",
            "mitigation": "Use the run as workflow/gating evidence only, or rerun after fixing gate/tool conditions.",
        })

    return {
        "schema_version": "threats_to_validity.v1",
        "created_utc": utc_now_iso(),
        "threats": threats,
    }


def build_thesis_safe_deterministic_report(
    *,
    cfg: EvaluationReporterConfig,
    measured: JsonDict,
    taxonomy: JsonDict,
    rq_mapping: JsonDict,
    threats: JsonDict,
) -> str:
    tool = measured.get("tool_evidence", {})
    counts = measured.get("counts", {})
    integrity = measured.get("integrity", {})
    llm_modes = measured.get("llm_mode_counts", {})

    lines = [
        "# Agent 11 Evaluation Report",
        "",
        "## Evaluation boundary",
        "",
        "This report summarises the evidence recorded by the workflow. It does not claim full implementation correctness, FIPS 203 compliance, cryptographic security, or whole-program verification.",
        "",
        "## Measured run facts",
        "",
        f"- Target function: `{cfg.target_function}`",
        f"- Target topic: `{cfg.target_topic}`",
        f"- Expected workflow stages: `{counts.get('expected_stage_count')}`",
        f"- Indexed stage records: `{counts.get('indexed_stage_record_count')}`",
        f"- Existing stage manifests: `{counts.get('stage_manifest_count')}`",
        f"- Missing stage manifests: `{counts.get('missing_stage_manifest_count')}`",
        f"- Handoff outputs indexed: `{counts.get('handoff_output_count')}`",
        f"- Checksums indexed: `{counts.get('checksum_count')}`",
        f"- LLM stages indexed: `{counts.get('llm_stage_count')}`",
        f"- LLM calls executed: `{counts.get('llm_call_executed_count')}`",
        f"- LLM mode counts: `{llm_modes}`",
        f"- CBMC result classification: `{tool.get('cbmc_result_classification')}`",
        f"- CBMC tool executed: `{tool.get('cbmc_tool_executed')}`",
        f"- Integrity status: `{integrity.get('validation_status')}`",
        f"- Integrity warnings: `{integrity.get('warning_count')}`",
        f"- Integrity errors: `{integrity.get('error_count')}`",
        "",
        "## Tool-evidence interpretation boundary",
        "",
        f"The recorded tool outcome category is `{tool.get('tool_outcome_category')}`. This category is derived from logged Agent 7 status and is not a broader correctness claim.",
        "",
        "## RQ mapping",
        "",
    ]

    for row in rq_mapping.get("rows", []):
        lines.extend([
            f"### {row.get('research_question')}",
            "",
            row.get("question_focus", ""),
            "",
            "**Supported by this run:** " + row.get("supported_statement", ""),
            "",
            "**Not supported by this run:** " + row.get("not_supported_statement", ""),
            "",
        ])

    lines.extend([
        "## Failure-mode taxonomy",
        "",
    ])
    for row in taxonomy.get("rows", []):
        lines.append(f"- `{row.get('taxonomy_id')}` — {row.get('label')}: observed = `{row.get('observed_in_run')}`.")
    lines.append("")

    lines.extend([
        "## Threats to validity",
        "",
    ])
    for threat in threats.get("threats", []):
        lines.append(f"- `{threat.get('threat_id')}` ({threat.get('category')}): {threat.get('threat')} Mitigation: {threat.get('mitigation')}")
    lines.append("")

    lines.extend([
        "## Thesis-safe conclusion",
        "",
        "The run should be described as a bounded case-study execution of a controlled LLM-assisted formal-methods workflow. The evidence supports statements about artefact generation, review gates, tool-execution status, reproducibility logging, and observed failure modes within the recorded run. It does not support claims of full ML-KEM correctness, FIPS 203 compliance, cryptographic security, or general performance across all PQC implementations.",
        "",
    ])

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Prompt and mock output
# ---------------------------------------------------------------------------

def build_agent11_prompt(cfg: EvaluationReporterConfig, availability: Mapping[str, bool]) -> str:
    responsibilities = """
- Produce a thesis-safe evaluation report from logged evidence.
- Separate measured facts from interpretation.
- Use Agent 10 experiment log and indexes as trusted measured facts for what happened.
- Verify important narrative claims against the supplied raw prompts/responses, candidate artefacts, raw tool output, and previous candidate-stage outputs.
- State whether LLM stages were real, mock, disabled, or unknown.
- State CBMC/tool result classification exactly as logged.
- Map evidence to RQ1, RQ2, and RQ3.
- Discuss usefulness only within the case-study scope.
- Discuss failure modes and human-correction needs only when supported by logged evidence.
- Include threats to validity.
- Include claim boundaries and non-goals.
- Avoid overclaiming proof, correctness, compliance, or security.
- Identify evidence gaps and missing outputs.
""".strip()

    prohibitions = """
- Do not claim full ML-KEM correctness.
- Do not claim FIPS 203 compliance.
- Do not claim cryptographic security or IND-CCA security.
- Do not claim whole-program verification.
- Do not treat mock-mode runs as real API-backed evidence.
- Do not treat CBMC skipped/dry-run/tool-unavailable as verification evidence.
- Do not invent metrics not present in Agent 10 indexes.
- Do not hide limitations, missing evidence, or integrity warnings.
- Do not present candidate LLM interpretation as formal truth.
""".strip()

    task = f"""
This final stage turns logged run evidence into a thesis-safe evaluation report.

Target function: {cfg.target_function}
Target topic: {cfg.target_topic}

Available Agent 10 evidence:
- experiment_log: {availability.get("experiment_log")}
- run_reproducibility_record: {availability.get("run_reproducibility_record")}
- stage_manifest_index: {availability.get("stage_manifest_index")}
- handoff_index: {availability.get("handoff_index")}
- checksum_manifest: {availability.get("checksum_manifest")}
- llm_call_index: {availability.get("llm_call_index")}
- tool_evidence_index: {availability.get("tool_evidence_index")}
- gate_and_repair_index: {availability.get("gate_and_repair_index")}
- failure_mode_log: {availability.get("failure_mode_log")}
- log_integrity_validation: {availability.get("log_integrity_validation")}

The output must be useful for Chapter 4/5 results-discussion style writing, but must remain evidence-bounded.

Use this structure:
1. measured_facts,
2. llm_interpretation,
3. rq_mapping,
4. usefulness_assessment,
5. failure_mode_assessment,
6. human_review_required,
7. deterministic_reference_assessment,
8. threats_to_validity,
9. thesis_safe_wording,
10. limitations.
""".strip()

    schema_summary = """
Top-level required fields:
- stage
- measured_facts
- llm_interpretation
- rq_mapping
- usefulness_assessment
- failure_mode_assessment
- human_review_required
- deterministic_reference_assessment
- threats_to_validity
- thesis_safe_wording
- evidence_gaps
- claim_boundaries
- limitations
""".strip()

    return build_common_stage_prompt(
        stage_name="Agent 11 — Evaluation Reporter Agent",
        task_description=task,
        responsibilities=responsibilities,
        prohibitions=prohibitions,
        schema_summary=schema_summary,
        include_non_copying_rule=False,
    )


def build_mock_evaluation_report(measured: JsonDict, taxonomy: JsonDict, rq_mapping: JsonDict, threats: JsonDict) -> JsonDict:
    counts = measured.get("counts", {}) if isinstance(measured.get("counts"), dict) else {}
    tool = measured.get("tool_evidence", {}) if isinstance(measured.get("tool_evidence"), dict) else {}
    integrity = measured.get("integrity", {}) if isinstance(measured.get("integrity"), dict) else {}
    llm_modes = measured.get("llm_mode_counts", {}) if isinstance(measured.get("llm_mode_counts"), dict) else {}

    return {
        "stage": "11_evaluation_reporter",
        "mock": True,
        "llm_call_executed": False,
        "measured_facts": {
            "target_function": str(measured.get("target_function") or "unknown"),
            "target_topic": str(measured.get("target_topic") or "unknown"),
            "property_family_id": str(measured.get("property_family_id") or "P16"),
            "verification_strategy": str(measured.get("verification_strategy") or "standard_cbmc_harness"),
            "property_support_classification": str(measured.get("property_support_classification") or "production_supported"),
            "llm_modes_observed": sorted(str(k) for k in llm_modes.keys()),
            "llm_call_executed_count": int(counts.get("llm_call_executed_count") or 0),
            "cbmc_result_classification": str(tool.get("cbmc_result_classification") or "unknown"),
            "cbmc_tool_executed": bool(tool.get("cbmc_tool_executed", False)),
            "tool_outcome_category": str(tool.get("tool_outcome_category") or "unknown"),
            "integrity_status": str(integrity.get("validation_status") or "unknown"),
            "missing_expected_output_count": int(
                counts.get("missing_expected_output_count")
                if counts.get("missing_expected_output_count") is not None
                else integrity.get("missing_expected_output_count") or 0
            ),
            "summary": "Mock wiring-test measurements normalized from deterministic Agent 10 evidence.",
            "evidence_references": []
        },
        "llm_interpretation": {
            "status": "mock_output_only",
            "summary": "Mock mode only; no real LLM evaluation narrative was produced."
        },
        "rq_mapping": {
            "rows": rq_mapping.get("rows", []) if isinstance(rq_mapping, dict) else []
        },
        "usefulness_assessment": {
            "status": "not_assessed_by_real_llm",
            "bounded_statement": "Mock wiring test only.",
            "supporting_observations": []
        },
        "failure_mode_assessment": {
            "result_classification": str(taxonomy.get("result_classification") or "unknown"),
            "tool_outcome_category": str(taxonomy.get("tool_outcome_category") or "unknown"),
            "rows": taxonomy.get("rows", []) if isinstance(taxonomy.get("rows"), list) else [],
            "limitations": taxonomy.get("limitations", []) if isinstance(taxonomy.get("limitations"), list) else []
        },
        "human_review_required": {
            "required": True,
            "status": "not_assessed_by_real_llm",
            "items": []
        },
        "deterministic_reference_assessment": {
            "used": True,
            "status": "not_assessed_by_real_llm",
            "warning": "Mock output only.",
            "disagreements": []
        },
        "threats_to_validity": {
            "threats": threats.get("threats", []) if isinstance(threats, dict) else []
        },
        "thesis_safe_wording": {
            "status": "mock_output_only",
            "paragraph": (
                "This mock output is suitable only for pipeline wiring tests and should not be used as thesis evidence."
            )
        },
        "evidence_gaps": [
            {
                "gap": "No real LLM evaluation was executed.",
                "impact": "Narrative evaluation is unavailable."
            }
        ],
        "claim_boundaries": {
            "proof_claimed": False,
            "full_correctness_claimed": False,
            "fips_compliance_claimed": False,
            "cryptographic_security_claimed": False,
            "mock_output": True
        },
        "limitations": [
            "Mock mode output only.",
            "Do not use this output as thesis evidence for LLM evaluation performance.",
        ],
    }


def derive_final_markdown_from_llm_or_fallback(
    *,
    cfg: EvaluationReporterConfig,
    llm_report: Optional[JsonDict],
    fallback_markdown: str,
) -> str:
    if not llm_report:
        return fallback_markdown

    wording = llm_report.get("thesis_safe_wording")
    parts = [
        "# Agent 11 Evaluation Report",
        "",
        "## Claim boundary",
        "",
        "This report is evidence-bounded. It does not claim full ML-KEM correctness, FIPS 203 compliance, cryptographic security, or whole-program verification.",
        "",
    ]

    if isinstance(wording, dict):
        paragraph = wording.get("paragraph") or wording.get("summary") or wording.get("text")
        if paragraph:
            parts.extend(["## Thesis-safe wording", "", str(paragraph), ""])

    interpretation = llm_report.get("llm_interpretation")
    if isinstance(interpretation, dict):
        parts.extend(["## Evaluation interpretation", "", json.dumps(interpretation, indent=2, ensure_ascii=False), ""])

    usefulness = llm_report.get("usefulness_assessment")
    if isinstance(usefulness, dict):
        parts.extend(["## Usefulness assessment", "", json.dumps(usefulness, indent=2, ensure_ascii=False), ""])

    failure = llm_report.get("failure_mode_assessment")
    if isinstance(failure, dict):
        parts.extend(["## Failure-mode assessment", "", json.dumps(failure, indent=2, ensure_ascii=False), ""])

    human = llm_report.get("human_review_required")
    if isinstance(human, dict):
        parts.extend(["## Human review and correction needs", "", json.dumps(human, indent=2, ensure_ascii=False), ""])

    threats = llm_report.get("threats_to_validity")
    if isinstance(threats, dict):
        parts.extend(["## Threats to validity", "", json.dumps(threats, indent=2, ensure_ascii=False), ""])

    limitations = llm_report.get("limitations")
    if isinstance(limitations, list):
        parts.extend(["## Limitations", ""])
        for item in limitations:
            parts.append(f"- {item}")
        parts.append("")

    parts.extend([
        "## Deterministic fallback facts",
        "",
        fallback_markdown,
    ])

    return "\n".join(parts)


def write_evaluation_tables(layout: RunLayout, measured: JsonDict, taxonomy: JsonDict, rq_mapping: JsonDict, threats: JsonDict) -> Dict[str, Path]:
    stage = "11_evaluation_reporter"
    outputs: Dict[str, Path] = {}

    outputs["rq_mapping_csv"] = write_csv(
        layout.validation_dir(stage) / "10_rq_mapping.csv",
        rq_mapping.get("rows", []),
    )
    outputs["failure_mode_taxonomy_csv"] = write_csv(
        layout.validation_dir(stage) / "10_failure_mode_taxonomy.csv",
        taxonomy.get("rows", []),
    )
    outputs["threats_to_validity_csv"] = write_csv(
        layout.validation_dir(stage) / "10_threats_to_validity.csv",
        threats.get("threats", []),
    )

    fact_rows = []
    for group, value in measured.items():
        if isinstance(value, dict):
            for k, v in value.items():
                fact_rows.append({"group": group, "key": k, "value": json.dumps(v, ensure_ascii=False)})
        elif group not in {"schema_version"}:
            fact_rows.append({"group": "top_level", "key": group, "value": json.dumps(value, ensure_ascii=False)})
    outputs["measured_facts_csv"] = write_csv(
        layout.validation_dir(stage) / "10_measured_facts.csv",
        fact_rows,
        fieldnames=["group", "key", "value"],
    )

    return outputs


# ---------------------------------------------------------------------------
# Main runner
# ---------------------------------------------------------------------------

def run_agent11(config_data: JsonDict, cfg: EvaluationReporterConfig) -> int:
    stage = "11_evaluation_reporter"
    layout = RunLayout(cfg.run_dir, create=False)
    layout.log_event(
        event_type="stage_started",
        stage=stage,
        message="Agent 11 Evaluation Reporter started.",
        data={"target_function": cfg.target_function, "target_topic": cfg.target_topic},
    )

    stage_status: JsonDict = {
        "schema_version": "agent_status.v1",
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
        # 1. Load Agent 10 evidence.
        # --------------------------------------------------------------
        experiment_log_path, experiment_log, experiment_log_status = load_handoff_json(layout, "10_experiment_logger", "experiment_log")
        run_record_path, run_record, run_record_status = load_handoff_json(layout, "10_experiment_logger", "run_reproducibility_record")
        stage_index_path, stage_index, stage_index_status = load_handoff_json(layout, "10_experiment_logger", "stage_manifest_index")
        handoff_index_path, handoff_index, handoff_index_status = load_handoff_json(layout, "10_experiment_logger", "handoff_index")
        checksum_manifest_path, checksum_manifest, checksum_manifest_status = load_handoff_json(layout, "10_experiment_logger", "checksum_manifest")
        llm_index_path, llm_index, llm_index_status = load_handoff_json(layout, "10_experiment_logger", "llm_call_index")
        tool_index_path, tool_index, tool_index_status = load_handoff_json(layout, "10_experiment_logger", "tool_evidence_index")
        gate_repair_path, gate_repair_index, gate_repair_status = load_handoff_json(layout, "10_experiment_logger", "gate_and_repair_index")
        failure_log_path, failure_mode_log, failure_log_status = load_handoff_json(layout, "10_experiment_logger", "failure_mode_log")
        integrity_path, integrity_validation, integrity_status = load_handoff_json(layout, "10_experiment_logger", "log_integrity_validation")
        missing_path, missing_outputs, missing_status = load_handoff_json(layout, "10_experiment_logger", "missing_expected_outputs")
        exp_md_path, exp_md_text, exp_md_status = load_handoff_text(layout, "10_experiment_logger", "experiment_log_markdown", max_chars=cfg.max_report_context_chars)

        statuses = {
            "experiment_log": experiment_log_status,
            "run_reproducibility_record": run_record_status,
            "stage_manifest_index": stage_index_status,
            "handoff_index": handoff_index_status,
            "checksum_manifest": checksum_manifest_status,
            "llm_call_index": llm_index_status,
            "tool_evidence_index": tool_index_status,
            "gate_and_repair_index": gate_repair_status,
            "failure_mode_log": failure_log_status,
            "log_integrity_validation": integrity_status,
            "missing_expected_outputs": missing_status,
            "experiment_log_markdown": exp_md_status,
        }
        availability = {k: bool(v.get("available")) for k, v in statuses.items()}

        if not experiment_log and not cfg.allow_missing_experiment_log:
            raise FileNotFoundError(
                f"Agent 11 requires Agent 10 experiment_log. Status: {experiment_log_status}. "
                "Use --allow-missing-experiment-log only for wiring tests."
            )

        for k, st in statuses.items():
            if not st.get("available"):
                stage_status["warnings"].append(f"{k} unavailable: {st.get('warning')}")

        previous_inputs_record = layout.write_deterministic_reference_json(
            stage,
            "10_previous_stage_input_status.json",
            {
                "trust_boundary": "agent10_log_is_primary_evidence_for_evaluation",
                "statuses": statuses,
                "availability": availability,
            },
        )

        # --------------------------------------------------------------
        # 2. Deterministic measured facts and thesis-safe scaffolding.
        # --------------------------------------------------------------
        measured = build_measured_evaluation_facts(
            cfg=cfg,
            experiment_log=experiment_log,
            run_record=run_record,
            stage_index=stage_index,
            handoff_index=handoff_index,
            checksum_manifest=checksum_manifest,
            llm_index=llm_index,
            tool_index=tool_index,
            gate_and_repair_index=gate_repair_index,
            failure_mode_log=failure_mode_log,
            integrity_validation=integrity_validation,
            missing_outputs=missing_outputs,
        )
        taxonomy = build_failure_mode_taxonomy(measured, failure_mode_log)
        rq_mapping = build_rq_mapping(measured, taxonomy)
        threats = build_threats_to_validity(measured)

        deterministic_paths: Dict[str, Path] = {}
        deterministic_paths["previous_stage_input_status"] = previous_inputs_record
        deterministic_paths["measured_evaluation_facts"] = layout.write_deterministic_reference_json(
            stage,
            "10_measured_evaluation_facts.json",
            measured,
        )
        deterministic_paths["failure_mode_taxonomy"] = layout.write_deterministic_reference_json(
            stage,
            "10_failure_mode_taxonomy.json",
            taxonomy,
        )
        deterministic_paths["rq_mapping"] = layout.write_deterministic_reference_json(
            stage,
            "10_rq_mapping.json",
            rq_mapping,
        )
        deterministic_paths["threats_to_validity"] = layout.write_deterministic_reference_json(
            stage,
            "10_threats_to_validity.json",
            threats,
        )

        fallback_markdown = build_thesis_safe_deterministic_report(
            cfg=cfg,
            measured=measured,
            taxonomy=taxonomy,
            rq_mapping=rq_mapping,
            threats=threats,
        )
        deterministic_paths["deterministic_evaluation_report_md"] = layout.deterministic_reference_dir(stage) / "10_evaluation_report.deterministic.md"
        atomic_write_text(deterministic_paths["deterministic_evaluation_report_md"], fallback_markdown)

        table_paths = write_evaluation_tables(layout, measured, taxonomy, rq_mapping, threats)

        deterministic_bundle = {
            "measured_evaluation_facts": measured,
            "failure_mode_taxonomy": taxonomy,
            "rq_mapping": rq_mapping,
            "threats_to_validity": threats,
            "agent10_experiment_log": experiment_log,
            "agent10_integrity_validation": integrity_validation,
            "agent10_missing_outputs": missing_outputs,
            "agent10_markdown_summary": exp_md_text,
        }

        # --------------------------------------------------------------
        # 3. LLM evaluation report.
        # --------------------------------------------------------------
        prompt_text = build_agent11_prompt(cfg, availability)

        run_config_for_client = dict(config_data)
        if cfg.llm_mode_override:
            llm_cfg = dict(run_config_for_client.get("llm") or {})
            llm_cfg["mode"] = cfg.llm_mode_override
            run_config_for_client["llm"] = llm_cfg

        client = LLMClient.from_run_config(run_config_for_client)

        trusted_fact_files: List[Path] = []
        for p in [
            experiment_log_path, run_record_path, stage_index_path, handoff_index_path,
            checksum_manifest_path, llm_index_path, tool_index_path, gate_repair_path,
            failure_log_path, integrity_path, missing_path, exp_md_path,
        ]:
            if p and Path(p).exists():
                trusted_fact_files.append(Path(p))

        raw_primary_files, prior_candidate_files, trusted_control_files = collect_agent11_direct_evidence(
            config_data=config_data,
            run_dir=cfg.run_dir,
            handoff_index=handoff_index,
            llm_index=llm_index,
            tool_index=tool_index,
        )
        trusted_fact_files = existing_unique_paths([*trusted_fact_files, *trusted_control_files])

        request = LLMStageRequest(
            stage=stage,
            prompt_text=prompt_text,
            output_filename="10_evaluation_report.json",
            json_schema=EVALUATION_REPORT_SCHEMA,
            primary_evidence_files=raw_primary_files,
            prior_authoritative_context_files=prior_candidate_files,
            trusted_deterministic_fact_files=trusted_fact_files,
            trusted_deterministic_facts_bundle=deterministic_bundle,
            deterministic_reference_bundle={
                "policy": "No measured number or status may be invented or changed by the model.",
                "interpretation_only": True,
            },
            extra_prompt_metadata={
                "agent": "Agent 11 Evaluation Reporter",
                "target_function": cfg.target_function,
                "target_topic": cfg.target_topic,
                "available_inputs": availability,
                "trust_boundary": {
                    "raw_run_evidence": "highest_priority_for_narrative_claims",
                    "previous_llm_outputs": "candidate_context_not_formal_truth",
                    "agent10_experiment_log": "trusted_measured_fact_index_for_what_happened",
                    "measured_facts": "deterministic_facts",
                    "llm_output": "authoritative_stage_candidate_evaluation_narrative_not_formal_truth",
                    "formal_truth": "not_claimed",
                },
            },
            mock_response_content=build_mock_evaluation_report(measured, taxonomy, rq_mapping, threats),
        )

        result = client.run_stage(layout, request)
        stage_status["llm_call_executed"] = result.llm_call_executed
        stage_status["llm_mode"] = result.mode
        stage_status["llm_success"] = result.success
        stage_status["llm_result"] = result.to_dict()

        # --------------------------------------------------------------
        # 4. Final Markdown/summary outputs.
        # --------------------------------------------------------------
        final_report_dir = layout.stage_dir(stage) / "final_report"
        ensure_dir(final_report_dir)

        llm_report = None
        if result.success and result.output_path:
            try:
                llm_report = extract_content_wrapper(read_json_file(result.output_path))
            except Exception as exc:
                stage_status["warnings"].append(f"Could not parse LLM evaluation output for final Markdown: {exc}")

        integrity_is_invalid = measured.get("integrity", {}).get("validation_status") == "invalid"
        if integrity_is_invalid and llm_report is not None:
            stage_status["warnings"].append(
                "Agent 10 integrity validation is invalid; LLM narrative is retained as a candidate record "
                "but is not promoted into the final Markdown or thesis-safe paragraph."
            )
        final_md = derive_final_markdown_from_llm_or_fallback(
            cfg=cfg,
            llm_report=None if integrity_is_invalid else llm_report,
            fallback_markdown=fallback_markdown,
        )

        final_outputs: Dict[str, Path] = {}
        final_outputs["evaluation_report_markdown"] = final_report_dir / "10_evaluation_report.md"
        atomic_write_text(final_outputs["evaluation_report_markdown"], final_md)

        final_outputs["evaluation_summary_json"] = final_report_dir / "10_evaluation_summary.json"
        atomic_write_json(final_outputs["evaluation_summary_json"], {
            "schema_version": "evaluation_summary.v1",
            "created_utc": utc_now_iso(),
            "target_function": cfg.target_function,
            "target_topic": cfg.target_topic,
            "property_family_id": cfg.property_family_id,
            "verification_strategy": cfg.verification_strategy,
            "property_support_classification": cfg.property_support_classification,
            "llm_mode": result.mode,
            "llm_call_executed": result.llm_call_executed,
            "cbmc_result_classification": measured.get("tool_evidence", {}).get("cbmc_result_classification"),
            "cbmc_tool_executed": measured.get("tool_evidence", {}).get("cbmc_tool_executed"),
            "integrity_validation_status": measured.get("integrity", {}).get("validation_status"),
            "report_eligibility": measured.get("report_eligibility"),
            "candidate_llm_narrative_promoted": (
                not integrity_is_invalid
                and result.llm_call_executed
                and result.mode == "real"
                and llm_report is not None
            ),
            "mock_or_non_api_narrative_used_for_wiring_only": (
                llm_report is not None and not result.llm_call_executed
            ),
            "claim_boundary": measured.get("claim_boundary"),
        })

        # A concise thesis paragraph file, deterministic fallback if LLM did not supply one.
        thesis_paragraph = None
        if integrity_is_invalid:
            thesis_paragraph = (
                "This run is classified as invalid for unqualified scientific result reporting because the "
                "deterministic integrity/provenance gate detected errors. Its files may be used only for "
                "diagnosis and workflow debugging. They must not be presented as a successful API-backed or "
                "CBMC-verified thesis experiment. Human review and a clean rerun are required."
            )
        elif llm_report and isinstance(llm_report.get("thesis_safe_wording"), dict):
            thesis_paragraph = (
                llm_report["thesis_safe_wording"].get("paragraph")
                or llm_report["thesis_safe_wording"].get("summary")
                or llm_report["thesis_safe_wording"].get("text")
            )
        if not thesis_paragraph:
            thesis_paragraph = (
                "This case-study run provides bounded evidence about the behaviour of the controlled "
                "LLM-assisted workflow for the selected target and recorded artefacts. The logged evidence "
                "supports discussion of candidate artefact generation, review gates, tool-execution status, "
                "reproducibility records, and observed workflow limitations. It does not establish full ML-KEM "
                "correctness, FIPS 203 compliance, cryptographic security, or whole-program verification."
            )
        final_outputs["thesis_safe_paragraph"] = final_report_dir / "10_thesis_safe_paragraph.txt"
        atomic_write_text(final_outputs["thesis_safe_paragraph"], str(thesis_paragraph).strip() + "\n")

        # --------------------------------------------------------------
        # 5. Handoff manifest.
        # --------------------------------------------------------------
        llm_outputs: Dict[str, Path] = {}
        validation_outputs: Dict[str, Path] = {}
        prompt_outputs: Dict[str, Path] = {}

        if result.output_path:
            llm_outputs["evaluation_report"] = Path(result.output_path)
        if result.raw_response_path:
            llm_outputs["raw_llm_response"] = Path(result.raw_response_path)
        if result.validation_path:
            validation_outputs["llm_call_validation"] = Path(result.validation_path)
        if result.prompt_path:
            prompt_outputs["prompt"] = Path(result.prompt_path)
        if result.metadata_path:
            prompt_outputs["prompt_metadata"] = Path(result.metadata_path)

        pdir = layout.prompt_package_dir(stage)
        for name in [
            "deterministic_reference_bundle.json",
            "trusted_deterministic_facts_bundle.json",
            "trusted_deterministic_facts_manifest.json",
            "primary_evidence_manifest.json",
        ]:
            p = pdir / name
            if p.exists():
                prompt_outputs[name.replace(".json", "")] = p

        validation_outputs.update(table_paths)

        handoff_outputs: Dict[str, Path] = {
            "evaluation_report_markdown": final_outputs["evaluation_report_markdown"],
            "final_report": final_outputs["evaluation_report_markdown"],
            "evaluation_summary": final_outputs["evaluation_summary_json"],
            "thesis_safe_paragraph": final_outputs["thesis_safe_paragraph"],
            "measured_evaluation_facts": deterministic_paths["measured_evaluation_facts"],
            "failure_mode_taxonomy": deterministic_paths["failure_mode_taxonomy"],
            "rq_mapping": deterministic_paths["rq_mapping"],
            "threats_to_validity": deterministic_paths["threats_to_validity"],
            "deterministic_evaluation_report_markdown": deterministic_paths["deterministic_evaluation_report_md"],
        }
        semantic_report_available = bool(result.success and result.output_path)
        if semantic_report_available:
            handoff_outputs["evaluation_report"] = Path(result.output_path)
        if result.validation_path:
            handoff_outputs["evaluation_report_validation"] = Path(result.validation_path)

        layout.write_handoff_manifest(
            stage,
            outputs=handoff_outputs,
            authoritative_source="deterministic_measured_facts_plus_llm_evaluation_narrative",
            next_stage_consumers=[
                "human_thesis_writer",
                "chapter_results_discussion",
            ],
            notes={
                "handoff_policy": (
                    "Measured facts are deterministic and come from Agent 10. "
                    "LLM evaluation report is candidate thesis-safe narrative, not formal truth."
                ),
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
                "authoritative_evaluation_report_available": semantic_report_available,
                "deterministic_fallback_promoted_as_evaluation_report": False,
                "mock_output": result.mode == "mock",
                "formal_truth_claimed": False,
                "full_correctness_claimed": False,
                "fips_compliance_claimed": False,
                "cryptographic_security_claimed": False,
            },
        )

        # --------------------------------------------------------------
        # 6. Stage manifest/status.
        # --------------------------------------------------------------
        layout.write_stage_manifest(
            stage,
            primary_evidence_inputs=[str(p) for p in raw_primary_files],
            deterministic_reference_outputs=deterministic_paths,
            prompt_package_outputs=prompt_outputs,
            llm_authoritative_outputs=llm_outputs,
            validation_outputs=validation_outputs,
            rendered_outputs=final_outputs,
            notes={
                "agent_version": "agent11_evaluation_reporter_refactored.v1",
                "stage_type": "mixed_deterministic_facts_plus_optional_llm_narrative",
                "root_level_outputs_written": False,
                "duplicate_outputs_written": False,
                "formal_truth_claimed": False,
                "full_correctness_claimed": False,
                "fips_compliance_claimed": False,
                "cryptographic_security_claimed": False,
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
                "authoritative_evaluation_report_available": semantic_report_available,
                "raw_primary_evidence_count": len(raw_primary_files),
                "prior_candidate_context_count": len(prior_candidate_files),
                "trusted_deterministic_fact_count": len(trusted_fact_files),
            },
        )

        stage_status["success"] = semantic_report_available
        stage_status["handoff_available"] = semantic_report_available
        stage_status["authoritative_evaluation_report_available"] = semantic_report_available
        if not semantic_report_available:
            stage_status["errors"].append({
                "type": "AuthoritativeEvaluationUnavailable",
                "message": (
                    "No schema-valid LLM evaluation report was produced. Deterministic measured facts and "
                    "fallback Markdown were preserved, but were not substituted for the authoritative evaluation_report handoff."
                ),
            })
        stage_status["completed_utc"] = utc_now_iso()
        atomic_write_json(layout.logs_dir(stage) / "11_evaluation_reporter_status.json", stage_status)

        layout.log_event(
            event_type="stage_completed",
            stage=stage,
            message="Agent 11 Evaluation Reporter completed.",
            data={
                "success": semantic_report_available,
                "handoff_available": semantic_report_available,
                "llm_mode": result.mode,
                "llm_call_executed": result.llm_call_executed,
                "cbmc_result_classification": measured.get("tool_evidence", {}).get("cbmc_result_classification"),
            },
        )

        return 0 if semantic_report_available else 1

    except Exception as exc:
        stage_status["completed_utc"] = utc_now_iso()
        stage_status["success"] = False
        stage_status["errors"].append({
            "type": type(exc).__name__,
            "message": str(exc),
            "traceback": traceback.format_exc(),
        })

        ensure_dir(layout.logs_dir(stage))
        atomic_write_json(layout.logs_dir(stage) / "11_evaluation_reporter_status.json", stage_status)

        layout.log_event(
            event_type="stage_failed",
            stage=stage,
            message=f"Agent 11 failed: {type(exc).__name__}: {exc}",
            data={"traceback": traceback.format_exc()},
        )

        try:
            layout.write_stage_manifest(
                stage,
                notes={
                    "agent_version": "agent11_evaluation_reporter_refactored.v1",
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
    parser = argparse.ArgumentParser(description="Agent 11 — refactored Evaluation Reporter Agent")
    parser.add_argument("--config", help="Path to run config JSON.")
    parser.add_argument("--run-dir", help="Override run directory.")
    parser.add_argument("--target-function", help="Implementation function name, e.g. mlk_poly_add.")
    parser.add_argument("--target-topic", help="Human-readable target topic.")
    parser.add_argument("--allow-missing-experiment-log", action="store_true", help="Allow missing Agent 10 log only for wiring tests.")
    parser.add_argument("--llm-mode", choices=["real", "mock", "disabled"], help="Override llm.mode from config.")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)
    config_data, cfg = load_config(args)
    return run_agent11(config_data, cfg)


if __name__ == "__main__":
    raise SystemExit(main())
