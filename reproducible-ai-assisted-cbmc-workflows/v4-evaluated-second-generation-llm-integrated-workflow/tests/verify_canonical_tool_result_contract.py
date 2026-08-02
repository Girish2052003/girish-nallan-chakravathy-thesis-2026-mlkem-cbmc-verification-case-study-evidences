#!/usr/bin/env python3
"""Directly verify Agent 7 result propagation through Agents 8, 9 and 11."""
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
    SELECTED_PROPERTY_VERIFIED,
    SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED,
    SKIPPED_BY_REVIEW_GATE,
    TOOL_ERROR_NO_PROPERTY_EVIDENCE,
    TOOL_EXECUTION_OR_EVIDENCE_INCONSISTENT,
    TOOL_OUTPUT_NOT_STRUCTURED_JSON,
    TOOL_SUCCESS_NO_EMITTED_EVIDENCE,
    TOOL_SUCCESS_NO_SELECTED_EVIDENCE,
    TOOL_TIMEOUT,
    TOOL_UNAVAILABLE,
    VERIFICATION_FAILED_OR_UNKNOWN,
    interpret_tool_result,
)
from agents.tool_execution_agent import diagnostic_recommendation
from agents.counterexample_analysis_agent import classify_failure_mode
from agents.repair_agent import RepairRefinementConfig, deterministic_repair_triage
from agents.evaluation_reporter import classify_tool_outcome, build_failure_mode_taxonomy


def case(result: str, semantic: str, severity: str, repair: bool, triage: str,
         outcome: str, taxonomy: set[str], failures: int = 0, unknowns: int = 0) -> dict:
    selected_success = result in {SELECTED_PROPERTY_VERIFIED, SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED}
    status = {
        "result_classification": result,
        "emitted_property_count": failures + unknowns + (1 if selected_success else 0),
        "emitted_failure_count": failures,
        "emitted_unknown_count": unknowns,
        "selected_claim_result": "passed" if selected_success else None,
        "selected_failed_property_count": 0 if result == SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED else failures,
        "selected_unknown_property_count": 0 if result == SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED else unknowns,
        "auxiliary_property_result": "failed" if result == SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED else None,
        "auxiliary_failed_property_count": failures if result == SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED else 0,
        "auxiliary_unknown_property_count": unknowns if result == SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED else 0,
    }
    return {
        "status": status,
        "semantic": semantic,
        "severity": severity,
        "repair": repair,
        "triage": triage,
        "outcome": outcome,
        "taxonomy": taxonomy,
    }


CASES = [
    case(SELECTED_PROPERTY_VERIFIED, "bounded_selected_property_success", "none", False,
         "no_repair_recommended_evaluate_scope", "bounded_selected_property_success", {"FM_SCOPE_001"}),
    case(SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED,
         "selected_property_passed_auxiliary_failed_or_unknown", "high", True,
         "repair_auxiliary_model_or_safety_checks_without_rewriting_selected_claim",
         "selected_property_passed_but_auxiliary_checks_failed_or_unknown", {"FM_AUX_001"}, failures=1),
    case(VERIFICATION_FAILED_OR_UNKNOWN, "property_failed", "high", True,
         "candidate_repair_needed", "property_failure_with_counterexample_or_failed_claim", {"FM_PROP_001"}, failures=1),
    case(VERIFICATION_FAILED_OR_UNKNOWN, "property_unknown", "medium", False,
         "manual_model_or_evidence_investigation", "property_result_unknown", {"FM_PROP_002"}, unknowns=1),
    case(VERIFICATION_FAILED_OR_UNKNOWN, "property_failed_and_unknown", "high", True,
         "candidate_repair_and_unknown_investigation", "property_failure_and_unknown",
         {"FM_PROP_001", "FM_PROP_002", "FM_PROP_003"}, failures=1, unknowns=1),
    case(TOOL_OUTPUT_NOT_STRUCTURED_JSON, "structured_evidence_missing", "high", True,
         "repair_harness_tool_or_evidence_pipeline_first", "structured_evidence_missing", {"FM_EVIDENCE_001"}),
    case(TOOL_SUCCESS_NO_EMITTED_EVIDENCE, "structured_evidence_missing", "high", True,
         "repair_harness_tool_or_evidence_pipeline_first", "structured_evidence_missing", {"FM_EVIDENCE_002"}),
    case(TOOL_ERROR_NO_PROPERTY_EVIDENCE, "tool_or_build_failure", "high", True,
         "repair_harness_tool_or_evidence_pipeline_first", "tool_or_build_failure", {"FM_TOOL_002"}),
    case(TOOL_SUCCESS_NO_SELECTED_EVIDENCE, "selected_property_traceability_incomplete", "high", True,
         "repair_harness_tool_or_evidence_pipeline_first", "selected_property_traceability_incomplete", {"FM_SCOPE_002"}),
    case(TOOL_EXECUTION_OR_EVIDENCE_INCONSISTENT, "tool_evidence_inconsistent", "high", True,
         "repair_harness_tool_or_evidence_pipeline_first", "tool_evidence_inconsistent", {"FM_EVIDENCE_003"}),
    case(TOOL_TIMEOUT, "tool_or_build_failure", "medium", True,
         "repair_or_tune_unwind_timeout", "tool_or_build_failure", {"FM_TOOL_002"}),
    case(CONTRACT_BUILD_FAILED, "tool_or_build_failure", "infrastructure_or_modeling", True,
         "repair_harness_tool_or_evidence_pipeline_first", "tool_or_build_failure", {"FM_TOOL_002"}),
    case(TOOL_UNAVAILABLE, "no_formal_execution", "not_applicable", False,
         "no_harness_repair_until_tool_execution_available", "no_formal_execution", {"FM_TOOL_001"}),
    case(SKIPPED_BY_REVIEW_GATE, "no_formal_execution", "not_applicable", False,
         "no_harness_repair_until_tool_execution_available", "no_formal_execution", {"FM_TOOL_001"}),
    case(DRY_RUN_NOT_EXECUTED, "no_formal_execution", "not_applicable", False,
         "no_harness_repair_until_tool_execution_available", "no_formal_execution", {"FM_TOOL_001"}),
    case(ANALYSIS_ONLY, "analysis_only", "not_applicable", False,
         "no_formal_repair_analysis_only", "analysis_only", {"FM_ANALYSIS_001"}),
]


def observed_taxonomy(status: dict) -> set[str]:
    measured = {
        "tool_evidence": {
            **status,
            "cbmc_result_classification": status["result_classification"],
            "tool_outcome_category": classify_tool_outcome(status),
        },
        "review_and_repair_evidence": {"review_gate": {}},
    }
    taxonomy = build_failure_mode_taxonomy(measured, None)
    return {row["taxonomy_id"] for row in taxonomy["rows"] if row["observed_in_run"]}


def main() -> int:
    tested = {row["status"]["result_classification"] for row in CASES}
    assert tested == set(CANONICAL_RESULT_CLASSIFICATIONS), (tested, CANONICAL_RESULT_CLASSIFICATIONS)
    cfg = RepairRefinementConfig(run_dir=ROOT / "runs" / "contract_test")

    for row in CASES:
        status = row["status"]
        interpretation = interpret_tool_result(status)
        assert interpretation["canonical_result_valid"] is True, interpretation
        assert interpretation["semantic_outcome"] == row["semantic"], interpretation
        assert diagnostic_recommendation(status) == interpretation["diagnostic_recommendation"]

        agent8 = classify_failure_mode(status, "", "", {
            "failure_count": status.get("emitted_failure_count", 0),
            "unknown_count": status.get("emitted_unknown_count", 0),
            "failed_properties": ([{"property_id": "p"}] if status.get("emitted_failure_count") else []),
        })
        assert agent8["semantic_outcome"] == row["semantic"], agent8
        assert agent8["severity"] == row["severity"], agent8
        assert agent8["repair_needed"] is row["repair"], agent8

        agent9 = deterministic_repair_triage(
            cfg=cfg,
            cbmc_status=status,
            counterexample_analysis={"failure_classification": agent8},
            repair_guidance=None,
            repair_action_plan=None,
            original_harness_text=None,
        )
        assert agent9["semantic_outcome"] == row["semantic"], agent9
        assert agent9["triage_decision"] == row["triage"], agent9
        assert agent9["repair_needed"] is row["repair"], agent9

        assert classify_tool_outcome(status) == row["outcome"], status
        assert observed_taxonomy(status) == row["taxonomy"], (status, observed_taxonomy(status), row["taxonomy"])

    # A label outside the shared contract fails closed across downstream interpretation.
    bad = {"result_classification": "verification_successful"}
    interpreted = interpret_tool_result(bad)
    assert interpreted["canonical_result_valid"] is False
    assert interpreted["semantic_outcome"] == "unrecognized_result_classification"
    assert classify_tool_outcome(bad) == "unknown_or_incomplete_tool_outcome"

    obsolete = {
        '"verification_successful"', '"verification_failed"',
        '"tool_error_or_nonzero_exit"', '"tool_exit_zero_unknown_verification_text"',
    }
    production = [
        ROOT / "agents/tool_execution_agent.py",
        ROOT / "agents/counterexample_analysis_agent.py",
        ROOT / "agents/repair_agent.py",
        ROOT / "agents/evaluation_reporter.py",
        ROOT / "docs/COMPLETE_26_PROPERTY_CAMPAIGN_GUIDE.md",
    ]
    for path in production:
        text = path.read_text(encoding="utf-8")
        assert not any(label in text for label in obsolete), (path, obsolete)

    print("CANONICAL TOOL RESULT CONTRACT REGRESSION: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
