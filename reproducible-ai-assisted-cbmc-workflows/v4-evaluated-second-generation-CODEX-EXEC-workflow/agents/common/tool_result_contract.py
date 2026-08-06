#!/usr/bin/env python3
"""Canonical interpretation contract for Agent 7 formal-tool results.

Agent 7 emits one canonical ``result_classification`` plus structured evidence
counts.  Agents 8, 9 and 11 must derive their diagnostics, repair triage and
reporting categories from this module instead of maintaining independent
string vocabularies.
"""
from __future__ import annotations

from typing import Any, Dict, Mapping, Optional, Union

JsonDict = Dict[str, Any]
ResultInput = Union[str, Mapping[str, Any], None]

SELECTED_PROPERTY_VERIFIED = "selected_property_verified_under_recorded_model"
SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED = "selected_property_passed_auxiliary_properties_failed_or_unknown"
VERIFICATION_FAILED_OR_UNKNOWN = "verification_failed_or_unknown"
TOOL_OUTPUT_NOT_STRUCTURED_JSON = "tool_output_not_structured_json"
TOOL_SUCCESS_NO_EMITTED_EVIDENCE = "tool_success_no_emitted_property_evidence"
TOOL_ERROR_NO_PROPERTY_EVIDENCE = "tool_error_no_property_evidence"
TOOL_SUCCESS_NO_SELECTED_EVIDENCE = "tool_success_no_selected_property_evidence"
TOOL_EXECUTION_OR_EVIDENCE_INCONSISTENT = "tool_execution_or_evidence_inconsistent"
TOOL_TIMEOUT = "tool_timeout"
CONTRACT_BUILD_FAILED = "contract_build_or_instrumentation_failed"
TOOL_UNAVAILABLE = "tool_unavailable"
SKIPPED_BY_REVIEW_GATE = "skipped_by_review_gate"
DRY_RUN_NOT_EXECUTED = "dry_run_not_executed"
ANALYSIS_ONLY = "analysis_only_no_formal_tool_claim"

CANONICAL_RESULT_CLASSIFICATIONS = frozenset({
    SELECTED_PROPERTY_VERIFIED,
    SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED,
    VERIFICATION_FAILED_OR_UNKNOWN,
    TOOL_OUTPUT_NOT_STRUCTURED_JSON,
    TOOL_SUCCESS_NO_EMITTED_EVIDENCE,
    TOOL_ERROR_NO_PROPERTY_EVIDENCE,
    TOOL_SUCCESS_NO_SELECTED_EVIDENCE,
    TOOL_EXECUTION_OR_EVIDENCE_INCONSISTENT,
    TOOL_TIMEOUT,
    CONTRACT_BUILD_FAILED,
    TOOL_UNAVAILABLE,
    SKIPPED_BY_REVIEW_GATE,
    DRY_RUN_NOT_EXECUTED,
    ANALYSIS_ONLY,
})


def _mapping(value: ResultInput) -> Mapping[str, Any]:
    return value if isinstance(value, Mapping) else {}


def _result(value: ResultInput) -> str:
    if isinstance(value, str):
        return value.strip()
    if isinstance(value, Mapping):
        return str(value.get("result_classification") or value.get("cbmc_result_classification") or "").strip()
    return ""


def _nonnegative_count(*values: Any) -> int:
    for value in values:
        if value is None or isinstance(value, bool):
            continue
        try:
            return max(0, int(value))
        except (TypeError, ValueError):
            continue
    return 0


def validate_result_classification(value: ResultInput) -> JsonDict:
    result = _result(value)
    return {
        "valid": result in CANONICAL_RESULT_CLASSIFICATIONS,
        "result_classification": result or "missing_result_classification",
        "allowed_result_classifications": sorted(CANONICAL_RESULT_CLASSIFICATIONS),
    }


def interpret_tool_result(
    status_or_result: ResultInput,
    property_results: Optional[Mapping[str, Any]] = None,
) -> JsonDict:
    """Return one cross-agent interpretation of Agent 7 evidence.

    ``property_results`` is used only to recover structured counts when an
    older status summary did not copy them.  It never replaces or rewrites the
    authoritative Agent 7 result classification.
    """
    status = _mapping(status_or_result)
    props = property_results if isinstance(property_results, Mapping) else {}
    result = _result(status_or_result)
    failure_count = _nonnegative_count(
        status.get("emitted_failure_count"),
        status.get("failure_count"),
        status.get("property_failure_count"),
        props.get("failure_count"),
    )
    unknown_count = _nonnegative_count(
        status.get("emitted_unknown_count"),
        status.get("unknown_count"),
        status.get("property_unknown_count"),
        props.get("unknown_count"),
    )
    selected_failure_count = _nonnegative_count(
        status.get("selected_failed_property_count"),
        failure_count if result == VERIFICATION_FAILED_OR_UNKNOWN else None,
    )
    selected_unknown_count = _nonnegative_count(
        status.get("selected_unknown_property_count"),
        unknown_count if result == VERIFICATION_FAILED_OR_UNKNOWN else None,
    )
    auxiliary_failure_count = _nonnegative_count(status.get("auxiliary_failed_property_count"))
    auxiliary_unknown_count = _nonnegative_count(status.get("auxiliary_unknown_property_count"))
    emitted_count = _nonnegative_count(
        status.get("emitted_property_count"),
        status.get("property_result_count"),
        props.get("property_result_count"),
    )

    base = {
        "contract_schema_version": "tool_result_contract.v1",
        "result_classification": result or "missing_result_classification",
        "canonical_result_valid": result in CANONICAL_RESULT_CLASSIFICATIONS,
        "emitted_property_count": emitted_count,
        "emitted_failure_count": failure_count,
        "emitted_unknown_count": unknown_count,
        "selected_claim_result": status.get("selected_claim_result"),
        "selected_failed_property_count": selected_failure_count,
        "selected_unknown_property_count": selected_unknown_count,
        "auxiliary_property_result": status.get("auxiliary_property_result"),
        "auxiliary_failed_property_count": auxiliary_failure_count,
        "auxiliary_unknown_property_count": auxiliary_unknown_count,
        "overall_model_result": status.get("overall_model_result"),
        "counterexample_relevant": False,
        "counterexample_scope": "none",
        "no_formal_tool_result": False,
    }

    if result == SELECTED_PROPERTY_VERIFIED:
        details = _details(
            "bounded_selected_property_success", [], "none", False,
            "no_repair_recommended_evaluate_scope", "bounded_selected_property_success",
            ["FM_SCOPE_001"],
            "Proceed to bounded evaluation/reporting while preserving the recorded assumptions and scope limitations.",
        )
    elif result == SELECTED_PROPERTY_PASSED_AUXILIARY_FAILED:
        details = _details(
            "selected_property_passed_auxiliary_failed_or_unknown",
            ["auxiliary_property_failure_or_unknown"], "high", True,
            "repair_auxiliary_model_or_safety_checks_without_rewriting_selected_claim",
            "selected_property_passed_but_auxiliary_checks_failed_or_unknown",
            ["FM_AUX_001"],
            "Preserve the passing selected claim while diagnosing failed or unknown auxiliary safety/model properties separately.",
            counterexample_relevant=auxiliary_failure_count > 0,
            counterexample_scope="auxiliary_properties" if auxiliary_failure_count > 0 else "none",
        )
    elif result == VERIFICATION_FAILED_OR_UNKNOWN:
        details = _failed_or_unknown_details(selected_failure_count, selected_unknown_count)
    elif result == TOOL_OUTPUT_NOT_STRUCTURED_JSON:
        details = _details(
            "structured_evidence_missing", ["structured_evidence_format_failure"], "high", True,
            "repair_harness_tool_or_evidence_pipeline_first", "structured_evidence_missing",
            ["FM_EVIDENCE_001"],
            "Repair the structured-evidence path before making any scientific property conclusion.",
        )
    elif result == TOOL_SUCCESS_NO_EMITTED_EVIDENCE:
        details = _details(
            "structured_evidence_missing", ["no_emitted_property_evidence"], "high", True,
            "repair_harness_tool_or_evidence_pipeline_first", "structured_evidence_missing",
            ["FM_EVIDENCE_002"],
            "CBMC ran but emitted no property evidence; inspect harness instrumentation, command options and JSON output.",
        )
    elif result == TOOL_ERROR_NO_PROPERTY_EVIDENCE:
        details = _details(
            "tool_or_build_failure", ["tool_or_compilation_error", "no_emitted_property_evidence"], "high", True,
            "repair_harness_tool_or_evidence_pipeline_first", "tool_or_build_failure",
            ["FM_TOOL_002"],
            "Resolve the tool/build error before semantic property repair or reporting.",
        )
    elif result == TOOL_SUCCESS_NO_SELECTED_EVIDENCE:
        details = _details(
            "selected_property_traceability_incomplete", ["selected_property_traceability_incomplete"], "high", True,
            "repair_harness_tool_or_evidence_pipeline_first", "selected_property_traceability_incomplete",
            ["FM_SCOPE_002"],
            "Restore selected-property-to-CBMC claim coverage before treating successful emitted properties as the selected result.",
        )
    elif result == TOOL_EXECUTION_OR_EVIDENCE_INCONSISTENT:
        details = _details(
            "tool_evidence_inconsistent", ["tool_execution_or_evidence_inconsistent"], "high", True,
            "repair_harness_tool_or_evidence_pipeline_first", "tool_evidence_inconsistent",
            ["FM_EVIDENCE_003"],
            "Investigate the contradiction between tool exit status, emitted properties and selected-property coverage.",
        )
    elif result == TOOL_TIMEOUT:
        details = _details(
            "tool_or_build_failure", ["tool_timeout"], "medium", True,
            "repair_or_tune_unwind_timeout", "tool_or_build_failure", ["FM_TOOL_002"],
            "Inspect harness complexity, unwind bounds and timeout configuration before rerunning.",
        )
    elif result == CONTRACT_BUILD_FAILED:
        details = _details(
            "tool_or_build_failure", ["contract_build_or_instrumentation_failure"], "infrastructure_or_modeling", True,
            "repair_harness_tool_or_evidence_pipeline_first", "tool_or_build_failure", ["FM_TOOL_002"],
            "Inspect goto-cc/goto-instrument output, contract syntax and transformation options before any property conclusion.",
        )
    elif result in {TOOL_UNAVAILABLE, SKIPPED_BY_REVIEW_GATE, DRY_RUN_NOT_EXECUTED}:
        category = {
            TOOL_UNAVAILABLE: "no_tool_execution_tool_unavailable",
            SKIPPED_BY_REVIEW_GATE: "no_tool_execution_skipped_by_gate",
            DRY_RUN_NOT_EXECUTED: "no_tool_execution_dry_run",
        }[result]
        details = _details(
            "no_formal_execution", [category], "not_applicable", False,
            "no_harness_repair_until_tool_execution_available", "no_formal_execution", ["FM_TOOL_001"],
            "Obtain an approved real tool execution before drawing a formal result or proposing evidence-driven repair.",
            no_formal_tool_result=True,
        )
    elif result == ANALYSIS_ONLY:
        details = _details(
            "analysis_only", ["analysis_only_no_formal_tool_claim"], "not_applicable", False,
            "no_formal_repair_analysis_only", "analysis_only", ["FM_ANALYSIS_001"],
            "Preserve the analysis-only boundary; do not claim CBMC verification.",
            no_formal_tool_result=True,
        )
    else:
        details = _details(
            "unrecognized_result_classification", ["unrecognized_tool_result_classification"], "high", False,
            "manual_result_contract_investigation", "unknown_or_incomplete_tool_outcome", ["FM_CONTRACT_001"],
            "The Agent 7 result label is missing or outside the canonical contract; inspect the handoff before continuing.",
            no_formal_tool_result=True,
        )

    base.update(details)
    return base


def _details(
    semantic_outcome: str,
    failure_categories: list[str],
    severity: str,
    repair_needed: bool,
    triage_decision: str,
    agent11_outcome: str,
    taxonomy_ids: list[str],
    recommendation: str,
    *,
    no_formal_tool_result: bool = False,
    counterexample_relevant: bool = False,
    counterexample_scope: str = "none",
) -> JsonDict:
    return {
        "semantic_outcome": semantic_outcome,
        "failure_categories": failure_categories,
        "severity": severity,
        "repair_needed": repair_needed,
        "triage_decision": triage_decision,
        "agent11_outcome": agent11_outcome,
        "taxonomy_ids": taxonomy_ids,
        "diagnostic_recommendation": recommendation,
        "no_formal_tool_result": no_formal_tool_result,
        "counterexample_relevant": counterexample_relevant,
        "counterexample_scope": counterexample_scope,
    }


def _failed_or_unknown_details(failure_count: int, unknown_count: int) -> JsonDict:
    if failure_count > 0 and unknown_count == 0:
        details = _details(
            "property_failed", ["counterexample_or_property_failure"], "high", True,
            "candidate_repair_needed", "property_failure_with_counterexample_or_failed_claim",
            ["FM_PROP_001"],
            "Proceed to counterexample analysis and candidate repair while preserving the failed claim and model scope.",
        )
        details["counterexample_relevant"] = True
        details["counterexample_scope"] = "selected_claims"
        return details
    if failure_count == 0 and unknown_count > 0:
        return _details(
            "property_unknown", ["property_result_unknown"], "medium", False,
            "manual_model_or_evidence_investigation", "property_result_unknown",
            ["FM_PROP_002"],
            "Investigate the model, bounds and unknown CBMC results before attempting semantic repair.",
        )
    if failure_count > 0 and unknown_count > 0:
        details = _details(
            "property_failed_and_unknown", ["counterexample_or_property_failure", "property_result_unknown"], "high", True,
            "candidate_repair_and_unknown_investigation", "property_failure_and_unknown",
            ["FM_PROP_001", "FM_PROP_002", "FM_PROP_003"],
            "Analyse the failed claims and separately investigate unknown claims; do not collapse the two outcomes.",
        )
        details["counterexample_relevant"] = True
        details["counterexample_scope"] = "selected_claims"
        return details
    return _details(
        "property_unknown", ["failed_or_unknown_counts_missing"], "medium", False,
        "manual_model_or_evidence_investigation", "property_result_unknown",
        ["FM_PROP_002"],
        "The failed-or-unknown label lacks supporting counts; inspect structured evidence before repair or reporting.",
    )
