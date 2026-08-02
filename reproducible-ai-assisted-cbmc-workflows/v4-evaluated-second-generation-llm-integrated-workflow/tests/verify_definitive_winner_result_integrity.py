#!/usr/bin/env python3
"""Adversarial proof for the definitive Agent 7 result-integration contract."""
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.tool_result_contract import (
    SELECTED_PROPERTY_VERIFIED,
    VERIFICATION_FAILED_OR_UNKNOWN,
    interpret_tool_result,
)
from agents.common.workflow_policy import tool_transition
from agents.counterexample_analysis_agent import (
    build_repair_guidance_diagnostic,
    classify_failure_mode,
    deterministic_counterexample_analysis,
)
from agents.master_orchestrator import MasterOrchestrator

SPECIFIC_HINTS = {
    "selected_possible_pointer_or_memory_safety_failure",
    "selected_possible_array_bounds_failure",
    "selected_possible_arithmetic_overflow_failure",
    "selected_possible_unwinding_bound_issue",
}


def status(result: str, *, verified=False, failures=0, unknowns=0):
    return {
        "result_classification": result,
        "selected_property_verified_under_model": verified,
        "emitted_property_count": max(1, failures + unknowns),
        "emitted_failure_count": failures,
        "emitted_unknown_count": unknowns,
    }


def master_transition(row: dict):
    orchestrator = MasterOrchestrator.__new__(MasterOrchestrator)
    orchestrator.max_iterations = 1
    orchestrator.tool_status = lambda: dict(row)
    return orchestrator.canonical_tool_transition(iteration=0)


def master_passed(row: dict) -> bool:
    orchestrator = MasterOrchestrator.__new__(MasterOrchestrator)
    orchestrator.tool_status = lambda: dict(row)
    return orchestrator.cbmc_passed()


def main() -> int:
    success = status(SELECTED_PROPERTY_VERIFIED, verified=True)
    assert interpret_tool_result(success)["failure_categories"] == []

    success_text = (
        "SUCCESS pointer dereference array bounds arithmetic overflow unwinding assertion\n"
        "SUCCESS all selected properties covered"
    )
    success_props = {
        "failure_count": 0,
        "unknown_count": 0,
        "failed_properties": [],
        "property_results": [{
            "property_id": "p.success",
            "status": "SUCCESS",
            "description": "pointer dereference array bounds overflow unwinding assertion",
        }],
    }
    classified = classify_failure_mode(success, success_text, "", success_props)
    assert classified["failure_categories"] == [], classified
    assert classified["repair_needed"] is False, classified
    guidance = build_repair_guidance_diagnostic(classified, {})
    assert [row["repair_type"] for row in guidance["guidance_items"]] == ["no_repair_from_success"], guidance
    deterministic = deterministic_counterexample_analysis(
        cbmc_status=success,
        cbmc_output=success_text,
        cbmc_stderr="",
        property_results=success_props,
        trace_summary=None,
        failed_mapping=None,
        harness_text="void harness(void) { /* successful pointer/bounds checks */ }",
    )
    assert deterministic["failure_snippets"] == [], deterministic
    assert deterministic["harness_diagnosis"]["findings"] == [], deterministic

    failed = status(VERIFICATION_FAILED_OR_UNKNOWN, verified=False, failures=1)
    structured_failed = {
        "failure_count": 1,
        "unknown_count": 0,
        "failed_properties": [{
            "property_id": "p.failed",
            "status": "FAILURE",
            "description": "pointer dereference array bounds arithmetic overflow unwinding assertion",
        }],
    }
    structured = classify_failure_mode(failed, success_text, "", structured_failed)
    assert SPECIFIC_HINTS <= set(structured["failure_categories"]), structured

    # With no preserved failed rows, successful descriptions elsewhere must not
    # leak into repair hints. Only the explicit failure-context line is used.
    mixed_output = success_text + "\nproperty p.actual FAILURE: user assertion violated"
    mixed = classify_failure_mode(
        failed,
        mixed_output,
        "",
        {"failure_count": 1, "unknown_count": 0, "failed_properties": []},
    )
    assert "selected_assertion_violation" in mixed["failure_categories"], mixed
    assert not (SPECIFIC_HINTS & set(mixed["failure_categories"])), mixed

    # Positive fallback control: the failure-context line itself may carry the
    # property-specific evidence when structured rows are unavailable.
    explicit_failure = (
        "property p.actual FAILURE: pointer dereference array bounds "
        "arithmetic overflow unwinding assertion violated"
    )
    fallback = classify_failure_mode(
        failed,
        explicit_failure,
        "",
        {"failure_count": 1, "unknown_count": 0, "failed_properties": []},
    )
    assert SPECIFIC_HINTS <= set(fallback["failure_categories"]), fallback

    assert master_transition(success).action == "stop_verified"
    for bad_success in (
        {k: v for k, v in success.items() if k != "selected_property_verified_under_model"},
        {**success, "selected_property_verified_under_model": False},
        {**success, "selected_property_verified_under_model": "false"},
    ):
        transition = master_transition(bad_success)
        assert transition.action == "stop_result_contract_investigation", transition
        assert transition.consumes_repair_iteration is False

    contradictory_failure = {**failed, "selected_property_verified_under_model": True}
    transition = master_transition(contradictory_failure)
    assert transition.action == "stop_result_contract_investigation", transition
    assert transition.consumes_repair_iteration is False

    non_boolean_failure = {**failed, "selected_property_verified_under_model": "true"}
    transition = master_transition(non_boolean_failure)
    assert transition.action == "stop_result_contract_investigation", transition
    assert transition.consumes_repair_iteration is False

    assert master_passed(success) is True
    assert master_passed({**success, "selected_property_verified_under_model": False}) is False
    assert master_passed({**success, "selected_property_verified_under_model": "false"}) is False

    # Direct policy calls must enforce the same explicit-Boolean rule.
    direct_missing = tool_transition(
        result_classification=SELECTED_PROPERTY_VERIFIED,
        iteration=0,
        max_iterations=1,
    )
    assert direct_missing.action == "stop_result_contract_investigation", direct_missing

    print("DEFINITIVE WINNER RESULT INTEGRITY REGRESSION: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
