#!/usr/bin/env python3
"""Objective semantic/traceability gate for generated verification artefacts.

The gate does not decide whether a property is true.  It verifies that the
selected semantic claim is represented exactly in the emitted artefact, that
trace identities bind to real C constructs rather than comments/strings, and
that obvious vacuity/scope defects are not mislabeled as CBMC-ready.
"""
from __future__ import annotations

import re
from typing import Any, Dict, List, Mapping, Optional, Sequence

from agents.common.exact_traceability import (
    build_traceability_record,
    exact_property_coverage,
    expected_assumption_identity,
    expected_claim_identity,
    expected_target_identity,
    find_function_calls,
)
from agents.common.semantic_property import normalize_semantic_property, semantic_completeness
from agents.common.semantic_gate_diagnostics import (
    append_legacy_compatibility_issues as _append_legacy_compatibility_issues,
    loop_guard_tautologies as _loop_guard_tautologies,
    trivial_assertions as _trivial_assertions,
    vacuity_findings as _vacuity_findings,
)
from agents.common.semantic_gate_claims import (
    validate_assumption_semantics as _validate_assumption_semantics,
    validate_claim_semantics as _validate_claim_semantics,
)

JsonDict = Dict[str, Any]
HARD = "critical"
WARNING = "warning"


def _issue(
    issue_id: str,
    message: str,
    *,
    severity: str = HARD,
    category: str = "semantic_fidelity",
    evidence: Optional[JsonDict] = None,
    affected_claim_ids: Sequence[str] = (),
) -> JsonDict:
    return {
        "issue_id": issue_id,
        "severity": severity,
        "category": category,
        "message": message,
        "blocks_tool_execution": severity == HARD,
        "affected_claim_ids": list(affected_claim_ids),
        "evidence": evidence or {},
    }


def _dict_list(value: Any) -> List[JsonDict]:
    return [dict(item) for item in value] if isinstance(value, list) else []


def validate_artifact_semantics(
    artifact_plan: Optional[Mapping[str, Any]],
    harness_text: str,
    *,
    target_function: str,
    property_campaign: Optional[Mapping[str, Any]] = None,
) -> JsonDict:
    plan: JsonDict = dict(artifact_plan or {})
    issues: List[JsonDict] = []
    selected = plan.get("selected_property") if isinstance(plan.get("selected_property"), Mapping) else {}
    prop = selected.get("property") if isinstance(selected, Mapping) and isinstance(selected.get("property"), Mapping) else {}
    semantic_source = (
        plan.get("semantic_property")
        if isinstance(plan.get("semantic_property"), Mapping)
        else prop
    )
    semantic = normalize_semantic_property(
        {"semantic_property": semantic_source, "property_id": prop.get("property_id")},
        target_function=target_function,
    )
    completeness = semantic_completeness(semantic)
    property_id = str(semantic.get("property_id") or prop.get("property_id") or "")
    strategy = str(plan.get("verification_strategy") or "")
    analysis_only = strategy == "analysis_only_no_formal_claim"
    trace = dict(plan.get("traceability_manifest") or {}) if isinstance(plan.get("traceability_manifest"), Mapping) else {}
    claim_map = _dict_list(trace.get("claim_map"))
    assumption_map = _dict_list(trace.get("assumption_map"))

    if not completeness.get("complete"):
        issues.append(_issue(
            "semantic_property_incomplete",
            "The selected property lacks a complete strategy-neutral semantic record.",
            evidence=completeness,
        ))
    if str(trace.get("selected_property_id") or "") != property_id:
        issues.append(_issue(
            "selected_property_identity_mismatch",
            "Traceability selected_property_id does not match the selected semantic property.",
            evidence={"semantic_property_id": property_id, "traceability_property_id": trace.get("selected_property_id")},
        ))

    expected_target = expected_target_identity(property_id)
    if str(trace.get("target_call_identity") or trace.get("target_call_marker") or "") != expected_target:
        issues.append(_issue(
            "target_marker_identity_mismatch",
            "The target-call identity is not the exact engine-defined identity.",
            evidence={"expected": expected_target, "observed": trace.get("target_call_identity") or trace.get("target_call_marker")},
        ))

    harness_claim_ids = [
        str(row.get("assertion_id") or "")
        for row in claim_map
        if str(row.get("implementation_kind") or "") in {"harness_assertion", "relational_assertion"}
    ]
    harness_assumption_ids = [
        str(row.get("assumption_id") or "")
        for row in assumption_map
        if str(row.get("implementation_kind") or "") == "harness_assume"
    ]
    exact = build_traceability_record(
        harness_text=harness_text,
        target_function=target_function,
        property_id=property_id,
        claim_ids=[item for item in harness_claim_ids if item],
        assumption_ids=[item for item in harness_assumption_ids if item],
    )
    target_binding = exact.get("target_call_binding", {})
    if not target_binding.get("valid"):
        if not target_binding.get("call_count"):
            issue_id = "target_function_call_absent"
            message = f"The real target function call {target_function!r} is absent outside comments/literals."
        elif not target_binding.get("marker_count"):
            issue_id = "target_call_marker_absent"
            message = "The exact target-call marker is absent."
        else:
            issue_id = "target_call_marker_misplaced"
            message = "The exact target-call marker is not uniquely bound immediately to the real target call."
        issues.append(_issue(issue_id, message, evidence=target_binding))

    if not exact.get("claim_bindings", {}).get("valid"):
        issues.append(_issue(
            "harness_claim_binding_invalid",
            "One or more selected harness claims are absent, duplicated, or not identified by an exact assertion message.",
            evidence=exact.get("claim_bindings", {}),
            affected_claim_ids=harness_claim_ids,
        ))
    if not exact.get("assumption_bindings", {}).get("valid"):
        issues.append(_issue(
            "harness_assumption_binding_invalid",
            "One or more harness assumptions are absent, duplicated, or not exactly marker-bound.",
            evidence=exact.get("assumption_bindings", {}),
        ))

    issues.extend(_validate_assumption_semantics(
        plan, assumption_map, analysis_only=analysis_only
    ))
    claim_issues, meaningful, expected_count = _validate_claim_semantics(
        plan, claim_map, exact, property_id=property_id, analysis_only=analysis_only
    )
    issues.extend(claim_issues)

    call_count = len(find_function_calls(harness_text, target_function))
    relational = strategy == "relational_cbmc_harness"
    if call_count > 1 and not relational:
        issues.append(_issue(
            "unexpected_multiple_target_calls",
            f"The harness calls {target_function} {call_count} times but the selected strategy is not relational.",
            severity=WARNING,
            category="scientific_caveat",
        ))

    for finding in _vacuity_findings(harness_text):
        issues.append(_issue(
            "contradictory_or_vacuous_assumption",
            "A harness assumption makes the selected claim unreachable or vacuous.",
            evidence=finding,
        ))
    for finding in _loop_guard_tautologies(harness_text):
        issues.append(_issue(
            "loop_guard_tautology",
            "An assertion repeats or is directly implied by the enclosing loop guard.",
            evidence=finding,
        ))
    for finding in _trivial_assertions(harness_text):
        issues.append(_issue("trivial_selected_assertion", "The harness contains a trivial assertion.", evidence=finding))

    # Semantic requirements, not category words, determine route fidelity.
    if bool(semantic.get("requires_modular_call_replacement")) and strategy not in {"native_function_contract", "hybrid_contract_and_harness"}:
        issues.append(_issue("required_modular_strategy_missing", "The semantic record requires modular call replacement but the selected encoding does not provide it."))
    if bool(semantic.get("requires_loop_reasoning")) and strategy not in {"native_loop_contract", "hybrid_contract_and_harness"}:
        issues.append(_issue("required_loop_strategy_missing", "The semantic record requires loop reasoning but the selected encoding does not provide it."))
    if bool(semantic.get("requires_relational_execution")) and strategy not in {"relational_cbmc_harness", "hybrid_contract_and_harness"}:
        issues.append(_issue("required_relational_strategy_missing", "The semantic record requires relational execution but the selected encoding does not provide it."))

    _append_legacy_compatibility_issues(issues, plan, harness_text, analysis_only=analysis_only)
    blockers = [row for row in issues if row.get("blocks_tool_execution")]
    warnings = [row for row in issues if not row.get("blocks_tool_execution")]
    return {
        "schema_version": "artifact_semantic_gate.v2.exact",
        "valid": not blockers,
        "recommended_gate": "approved_for_tool_execution" if not blockers and not analysis_only else ("approved_for_analysis_only" if not blockers else "blocked_semantic_fidelity_defect"),
        "target_function": target_function,
        "selected_property_id": property_id,
        "verification_strategy": strategy,
        "semantic_property": semantic,
        "semantic_completeness": completeness,
        "exact_traceability": exact,
        "expected_claim_count": expected_count,
        "meaningful_mapped_claim_count": meaningful,
        "issues": issues,
        "blocking_issues": blockers,
        "hard_blockers": blockers,
        "formal_tool_execution_allowed": not blockers and not analysis_only,
        "analysis_stage_execution_allowed": not blockers and analysis_only,
        "selected_claim_formally_checkable": not analysis_only and expected_count > 0 and meaningful == expected_count,
        "approved_for_tool_execution": not blockers and not analysis_only,
        "warnings": warnings,
        "blocking_issue_count": len(blockers),
        "warning_count": len(warnings),
        "mapping_authority": "exact_identity_and_typed_clause_binding",
    }


def selected_property_coverage(
    traceability_manifest: Optional[Mapping[str, Any]],
    property_rows: Sequence[Mapping[str, Any]],
) -> JsonDict:
    """Map selected claims only by exact generated property identity."""
    trace = dict(traceability_manifest or {})
    claim_map = _dict_list(trace.get("claim_map"))
    expected = [
        {
            "identity": str(row.get("expected_property_identity") or row.get("code_marker") or ""),
            "claim_id": str(row.get("assertion_id") or ""),
            "implementation_kind": str(row.get("implementation_kind") or ""),
            "expression_sha256": str(row.get("expression_sha256") or ""),
        }
        for row in claim_map
    ]
    result = exact_property_coverage(expected, property_rows)
    expected_count = trace.get("expected_claim_count")
    if isinstance(expected_count, int) and not isinstance(expected_count, bool):
        result["declared_expected_claim_count"] = expected_count
        result["coverage_complete"] = bool(result.get("coverage_complete")) and expected_count == len(expected)
    return result


__all__ = ["selected_property_coverage", "validate_artifact_semantics"]
