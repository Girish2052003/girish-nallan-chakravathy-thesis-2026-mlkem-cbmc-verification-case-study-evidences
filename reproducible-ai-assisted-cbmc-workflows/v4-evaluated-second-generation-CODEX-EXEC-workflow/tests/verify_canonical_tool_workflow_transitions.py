#!/usr/bin/env python3
"""Every canonical Agent 7 result must have one explicit workflow transition."""
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.tool_result_contract import (
    ANALYSIS_ONLY,
    CANONICAL_RESULT_CLASSIFICATIONS,
    CONTRACT_BUILD_FAILED,
    DRY_RUN_NOT_EXECUTED,
    SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED,
    SELECTED_PROPERTY_VERIFIED,
    SKIPPED_BY_REVIEW_GATE,
    TOOL_ERROR_NO_PROPERTY_EVIDENCE,
    TOOL_EXECUTION_OR_EVIDENCE_INCONSISTENT,
    TOOL_OUTPUT_NOT_STRUCTURED_JSON,
    TOOL_SUCCESS_NO_EMITTED_EVIDENCE,
    TOOL_SUCCESS_NO_SELECTED_EVIDENCE,
    TOOL_TIMEOUT,
    TOOL_UNAVAILABLE,
    VERIFICATION_FAILED_OR_UNKNOWN,
)
from agents.common.workflow_policy import tool_transition
from agents.master_orchestrator import MasterOrchestrator
from agents.master_orchestrator import MasterOrchestrator


def status(result: str, failures: int = 0, unknowns: int = 0, verified: bool = False) -> dict:
    return {
        "result_classification": result,
        "selected_property_verified_under_model": verified,
        "emitted_property_count": failures + unknowns + (1 if verified else 0),
        "emitted_failure_count": failures,
        "emitted_unknown_count": unknowns,
    }


def assert_transition(row: dict, action: str, terminal: bool, consumes: bool, *, iteration: int = 0, maximum: int = 1) -> None:
    policy_transition = tool_transition(
        result_classification=row,
        selected_property_verified=bool(row.get("selected_property_verified_under_model", False)),
        iteration=iteration,
        max_iterations=maximum,
    )
    orchestrator = MasterOrchestrator.__new__(MasterOrchestrator)
    orchestrator.max_iterations = maximum
    orchestrator.tool_status = lambda: dict(row)
    master_transition = orchestrator.canonical_tool_transition(iteration=iteration)
    assert master_transition == policy_transition, (row, master_transition, policy_transition)
    assert master_transition.action == action, (row, master_transition)
    assert master_transition.terminal is terminal, (row, master_transition)
    assert master_transition.consumes_repair_iteration is consumes, (row, master_transition)


def orchestrator_transition(row: dict, *, iteration: int = 0, maximum: int = 1):
    orchestrator = MasterOrchestrator.__new__(MasterOrchestrator)
    orchestrator.max_iterations = maximum
    orchestrator.tool_status = lambda: dict(row)
    return orchestrator.canonical_tool_transition(iteration=iteration)


def assert_orchestrator_matches(row: dict, action: str, terminal: bool, consumes: bool, *, iteration: int = 0, maximum: int = 1) -> None:
    transition = orchestrator_transition(row, iteration=iteration, maximum=maximum)
    assert transition.action == action, (row, transition)
    assert transition.terminal is terminal, (row, transition)
    assert transition.consumes_repair_iteration is consumes, (row, transition)


def main() -> int:
    covered = set()

    success = status(SELECTED_PROPERTY_VERIFIED, verified=True)
    assert_transition(success, "stop_verified", True, False)
    assert_orchestrator_matches(success, "stop_verified", True, False)
    covered.add(SELECTED_PROPERTY_VERIFIED)

    auxiliary = status(SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED)
    auxiliary.update({
        "selected_claim_result": "passed",
        "auxiliary_property_result": "failed",
        "auxiliary_failed_property_count": 1,
        "selected_failed_property_count": 0,
        "selected_unknown_property_count": 0,
    })
    assert_transition(auxiliary, "repair_from_tool_evidence", False, True)
    assert_orchestrator_matches(auxiliary, "repair_from_tool_evidence", False, True)
    assert_transition(auxiliary, "stop_iteration_limit", True, False, iteration=1, maximum=1)
    covered.add(SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED)

    failed = status(VERIFICATION_FAILED_OR_UNKNOWN, failures=1)
    assert_transition(failed, "repair_from_tool_evidence", False, True)
    assert_orchestrator_matches(failed, "repair_from_tool_evidence", False, True)
    assert_transition(failed, "stop_iteration_limit", True, False, iteration=1, maximum=1)
    assert_orchestrator_matches(failed, "stop_iteration_limit", True, False, iteration=1, maximum=1)

    unknown = status(VERIFICATION_FAILED_OR_UNKNOWN, unknowns=1)
    assert_transition(unknown, "stop_model_or_evidence_investigation", True, False)
    assert_orchestrator_matches(unknown, "stop_model_or_evidence_investigation", True, False)

    mixed = status(VERIFICATION_FAILED_OR_UNKNOWN, failures=1, unknowns=1)
    assert_transition(mixed, "repair_from_tool_evidence", False, True)
    assert_orchestrator_matches(mixed, "repair_from_tool_evidence", False, True)
    covered.add(VERIFICATION_FAILED_OR_UNKNOWN)

    repairable = {
        TOOL_OUTPUT_NOT_STRUCTURED_JSON,
        TOOL_SUCCESS_NO_EMITTED_EVIDENCE,
        TOOL_ERROR_NO_PROPERTY_EVIDENCE,
        TOOL_SUCCESS_NO_SELECTED_EVIDENCE,
        TOOL_EXECUTION_OR_EVIDENCE_INCONSISTENT,
        TOOL_TIMEOUT,
        CONTRACT_BUILD_FAILED,
    }
    for result in repairable:
        row = status(result)
        assert_transition(row, "repair_from_tool_evidence", False, True)
        assert_orchestrator_matches(row, "repair_from_tool_evidence", False, True)
        assert_transition(row, "stop_iteration_limit", True, False, iteration=1, maximum=1)
        assert_orchestrator_matches(row, "stop_iteration_limit", True, False, iteration=1, maximum=1)
        covered.add(result)

    assert_transition(status(TOOL_UNAVAILABLE), "stop_tool_unavailable", True, False)
    assert_orchestrator_matches(status(TOOL_UNAVAILABLE), "stop_tool_unavailable", True, False)
    assert_transition(status(SKIPPED_BY_REVIEW_GATE), "stop_review_gate_skip", True, False)
    assert_orchestrator_matches(status(SKIPPED_BY_REVIEW_GATE), "stop_review_gate_skip", True, False)
    assert_transition(status(DRY_RUN_NOT_EXECUTED), "stop_dry_run", True, False)
    assert_orchestrator_matches(status(DRY_RUN_NOT_EXECUTED), "stop_dry_run", True, False)
    assert_transition(status(ANALYSIS_ONLY), "stop_analysis_only", True, False)
    assert_orchestrator_matches(status(ANALYSIS_ONLY), "stop_analysis_only", True, False)
    covered |= {TOOL_UNAVAILABLE, SKIPPED_BY_REVIEW_GATE, DRY_RUN_NOT_EXECUTED, ANALYSIS_ONLY}

    assert covered == set(CANONICAL_RESULT_CLASSIFICATIONS), (covered, CANONICAL_RESULT_CLASSIFICATIONS)

    # Count-free failed-or-unknown is ambiguous and must not spend a repair iteration.
    ambiguous = status(VERIFICATION_FAILED_OR_UNKNOWN)
    assert_transition(ambiguous, "stop_model_or_evidence_investigation", True, False)

    # Contradictory success booleans fail closed rather than claiming success or repairing.
    inconsistent_success = status(SELECTED_PROPERTY_VERIFIED, verified=False)
    assert_transition(inconsistent_success, "stop_result_contract_investigation", True, False)
    inconsistent_failure = status(VERIFICATION_FAILED_OR_UNKNOWN, failures=1, verified=True)
    assert_transition(inconsistent_failure, "stop_result_contract_investigation", True, False)
    assert_orchestrator_matches(inconsistent_failure, "stop_result_contract_investigation", True, False)

    # Only a real JSON boolean may establish the selected-property success flag.
    string_false = status(SELECTED_PROPERTY_VERIFIED, verified=False)
    string_false["selected_property_verified_under_model"] = "false"
    assert_orchestrator_matches(string_false, "stop_result_contract_investigation", True, False)

    print("CANONICAL TOOL WORKFLOW TRANSITIONS REGRESSION: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
