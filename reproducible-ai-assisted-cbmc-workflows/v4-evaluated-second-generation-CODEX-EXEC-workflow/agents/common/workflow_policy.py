#!/usr/bin/env python3
"""Canonical workflow state transitions for review, tool and repair control."""
from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any, Mapping

from agents.common.gate_contract import (
    ANALYSIS_GATES,
    BLOCKING_GATES,
    FORMAL_EXECUTION_GATES,
    canonical_gate,
)
from agents.common.tool_result_contract import (
    ANALYSIS_ONLY,
    DRY_RUN_NOT_EXECUTED,
    SELECTED_PROPERTY_VERIFIED,
    SKIPPED_BY_REVIEW_GATE,
    TOOL_UNAVAILABLE,
    interpret_tool_result,
)

APPROVED_GATES = set(FORMAL_EXECUTION_GATES) | set(ANALYSIS_GATES)
REPAIR_GATES = set(BLOCKING_GATES)
HUMAN_REVIEW_GATE = "human_review_required"


@dataclass(frozen=True)
class Transition:
    action: str
    reason: str
    terminal: bool
    consumes_repair_iteration: bool = False

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


def normalise_critic_gate(gate: Mapping[str, Any] | None) -> str:
    """Return one canonical gate while failing closed on malformed booleans."""
    row = dict(gate or {})
    raw_gate = str(row.get("final_gate") or "missing_gate").strip().lower()
    if raw_gate == HUMAN_REVIEW_GATE:
        return HUMAN_REVIEW_GATE
    final_gate = canonical_gate(raw_gate)

    legacy_allowed = row.get("tool_execution_allowed")
    formal_allowed = row.get("formal_tool_execution_allowed", legacy_allowed)
    analysis_allowed = row.get("analysis_stage_execution_allowed", legacy_allowed)

    if final_gate in FORMAL_EXECUTION_GATES:
        return final_gate if type(formal_allowed) is bool and formal_allowed else "missing_gate"
    if final_gate in ANALYSIS_GATES:
        return final_gate if type(analysis_allowed) is bool and analysis_allowed else "missing_gate"
    if final_gate in BLOCKING_GATES:
        return final_gate
    return "missing_gate"


def critic_transition(gate_state: str, *, iteration: int, max_iterations: int) -> Transition:
    raw = str(gate_state or "missing_gate").strip().lower()
    if raw == HUMAN_REVIEW_GATE:
        return Transition("stop_for_human_review", "critic_requested_human_review_before_tool", True)
    state = canonical_gate(raw)
    if state in APPROVED_GATES:
        return Transition("execute_tool", "artifact_acceptable_for_tool_execution", False)
    if state in REPAIR_GATES:
        if iteration < max_iterations:
            return Transition("repair_then_rereview", f"critic_required_pre_tool_repair:{state}", False, True)
        return Transition("stop_iteration_limit", f"critic_requested_repair_but_iteration_limit_reached:{state}", True)
    return Transition("stop_for_human_review", "unrecognised_critic_state", True)


def tool_transition(
    *,
    result_classification: str | Mapping[str, Any],
    selected_property_verified: bool | None = None,
    iteration: int,
    max_iterations: int,
) -> Transition:
    """Route Agent 7 evidence using the shared canonical result contract.

    A complete Agent 7 status mapping is preferred because
    ``verification_failed_or_unknown`` requires structured counts and bounded
    success requires the explicit JSON boolean
    ``selected_property_verified_under_model: true``.  String-only input is
    retained for compatibility but cannot establish bounded success without
    the explicit Boolean argument.
    """
    status = result_classification if isinstance(result_classification, Mapping) else None

    if selected_property_verified is not None and type(selected_property_verified) is not bool:
        return Transition(
            "stop_result_contract_investigation",
            "selected_property_verified_argument_not_boolean",
            True,
        )

    effective_verified = selected_property_verified
    if status is not None and "selected_property_verified_under_model" in status:
        raw_verified = status.get("selected_property_verified_under_model")
        if type(raw_verified) is not bool:
            return Transition(
                "stop_result_contract_investigation",
                "selected_property_verified_flag_not_boolean",
                True,
            )
        if selected_property_verified is not None and selected_property_verified is not raw_verified:
            return Transition(
                "stop_result_contract_investigation",
                "selected_property_verified_sources_inconsistent",
                True,
            )
        effective_verified = raw_verified

    interpretation = interpret_tool_result(result_classification)
    classification = str(interpretation["result_classification"])
    semantic_outcome = str(interpretation["semantic_outcome"])

    if semantic_outcome == "bounded_selected_property_success":
        if effective_verified is not True:
            return Transition(
                "stop_result_contract_investigation",
                "selected_property_success_flag_missing_or_inconsistent",
                True,
            )
        return Transition("stop_verified", "formal_tool_passed_selected_properties", True)

    if effective_verified is True:
        return Transition(
            "stop_result_contract_investigation",
            "selected_property_verified_flag_conflicts_with_canonical_result",
            True,
        )

    if classification == ANALYSIS_ONLY:
        return Transition("stop_analysis_only", "analysis_only_stage_completed_no_formal_claim", True)
    if semantic_outcome == "property_unknown":
        return Transition(
            "stop_model_or_evidence_investigation",
            "property_unknown_requires_model_or_evidence_investigation",
            True,
        )
    if classification == TOOL_UNAVAILABLE:
        return Transition("stop_tool_unavailable", "formal_tool_unavailable_environment_setup_required", True)
    if classification == SKIPPED_BY_REVIEW_GATE:
        return Transition("stop_review_gate_skip", "formal_tool_execution_skipped_by_review_gate", True)
    if classification == DRY_RUN_NOT_EXECUTED:
        return Transition("stop_dry_run", "dry_run_completed_without_formal_tool_execution", True)
    if semantic_outcome == "unrecognized_result_classification":
        return Transition(
            "stop_result_contract_investigation",
            "unrecognized_agent7_result_contract",
            True,
        )

    if interpretation["repair_needed"]:
        if iteration < max_iterations:
            return Transition("repair_from_tool_evidence", "canonical_tool_result_requires_repair", False, True)
        return Transition("stop_iteration_limit", "canonical_tool_result_requires_repair_but_iteration_limit_reached", True)

    return Transition(
        "stop_result_contract_investigation",
        "canonical_tool_result_requires_manual_contract_investigation",
        True,
    )


__all__ = [
    "APPROVED_GATES",
    "HUMAN_REVIEW_GATE",
    "REPAIR_GATES",
    "Transition",
    "critic_transition",
    "normalise_critic_gate",
    "tool_transition",
]
