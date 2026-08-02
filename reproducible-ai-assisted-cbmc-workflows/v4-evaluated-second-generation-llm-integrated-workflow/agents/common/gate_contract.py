"""Canonical gate, stage-outcome, and user-execution-mode vocabulary."""
from __future__ import annotations

import hashlib
import json
from typing import Any, Dict, Mapping

JsonDict = Dict[str, Any]

GATES = {
    "approved_for_tool_execution",
    "approved_for_analysis_only",
    "blocked_invalid_artifact",
    "blocked_semantic_fidelity_defect",
    "blocked_frontend_readiness_defect",
    "blocked_transformation_readiness_defect",
    "blocked_missing_selected_claim",
    "user_forced_execution",
    "not_applicable",
    "human_review_required",
    "missing_gate",
}

FORMAL_EXECUTION_GATES = {"approved_for_tool_execution", "user_forced_execution"}
ANALYSIS_GATES = {"approved_for_analysis_only"}
BLOCKING_GATES = {
    "blocked_invalid_artifact",
    "blocked_semantic_fidelity_defect",
    "blocked_frontend_readiness_defect",
    "blocked_transformation_readiness_defect",
    "blocked_missing_selected_claim",
    "missing_gate",
}
EXECUTION_MODES = {"reviewed", "user_forced_review_bypass", "raw_manual"}

LEGACY_ALIASES = {
    "blocked_hard_tool_readiness_defect": "blocked_frontend_readiness_defect",
    "blocked_due_to_deterministic_critical_issue": "blocked_semantic_fidelity_defect",
    "blocked_due_to_llm_critical_issue": "blocked_semantic_fidelity_defect",
    "needs_revision_before_tool_execution": "blocked_semantic_fidelity_defect",
    "blocked": "blocked_invalid_artifact",
    "repair_required_before_tool": "blocked_invalid_artifact",
}


def canonical_gate(value: Any) -> str:
    text = str(value or "missing_gate").strip().lower()
    text = LEGACY_ALIASES.get(text, text)
    return text if text in GATES else "missing_gate"


def gate_hash(record: Mapping[str, Any]) -> str:
    payload = {
        "final_gate": canonical_gate(record.get("final_gate")),
        "formal_tool_execution_allowed": bool(record.get("formal_tool_execution_allowed")),
        "analysis_stage_execution_allowed": bool(record.get("analysis_stage_execution_allowed")),
        "selected_claim_formally_checkable": bool(record.get("selected_claim_formally_checkable")),
        "execution_mode": str(record.get("execution_mode") or "reviewed"),
    }
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def build_gate_record(
    *,
    final_gate: str,
    stage_output_valid: bool,
    process_completed: bool = True,
    process_return_code: int = 0,
    execution_mode: str = "reviewed",
    reason: str = "",
) -> JsonDict:
    gate = canonical_gate(final_gate)
    mode = execution_mode if execution_mode in EXECUTION_MODES else "reviewed"
    formal = gate in FORMAL_EXECUTION_GATES
    analysis = gate in ANALYSIS_GATES or formal
    record: JsonDict = {
        "schema_version": "canonical_gate_record.v1",
        "final_gate": gate,
        "process_completed": bool(process_completed),
        "process_return_code": int(process_return_code),
        "stage_output_valid": bool(stage_output_valid),
        "stage_outcome": gate,
        "execution_mode": mode,
        "formal_tool_execution_allowed": formal,
        "analysis_stage_execution_allowed": analysis,
        "selected_claim_formally_checkable": gate == "approved_for_tool_execution",
        "reason": str(reason or ""),
    }
    record["gate_sha256"] = gate_hash(record)
    return record


__all__ = [
    "ANALYSIS_GATES",
    "BLOCKING_GATES",
    "EXECUTION_MODES",
    "FORMAL_EXECUTION_GATES",
    "GATES",
    "build_gate_record",
    "canonical_gate",
    "gate_hash",
]
