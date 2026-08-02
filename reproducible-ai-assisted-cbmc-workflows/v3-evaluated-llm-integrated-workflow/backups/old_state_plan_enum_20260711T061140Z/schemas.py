"""
agents/common/schemas.py

Strict, stage-specific JSON Schemas for the API-backed workflow.

Design goals:
- compatible with OpenAI Structured Outputs when ``strict=True``;
- every object declares ``additionalProperties: False``;
- every declared object property is required;
- optional/unknown scalar values use JSON null explicitly;
- stage schemas preserve the workflow trust boundary: candidate outputs are not proofs.
"""

from __future__ import annotations

from copy import deepcopy
from typing import Any, Dict, Mapping

from agents.common.property_catalog import property_family_ids, strategy_ids

JsonDict = Dict[str, Any]


def _obj(properties: Mapping[str, JsonDict], *, description: str | None = None) -> JsonDict:
    schema: JsonDict = {
        "type": "object",
        "properties": dict(properties),
        "required": list(properties.keys()),
        "additionalProperties": False,
    }
    if description:
        schema["description"] = description
    return schema


def _arr(item_schema: JsonDict, *, description: str | None = None) -> JsonDict:
    schema: JsonDict = {"type": "array", "items": deepcopy(item_schema)}
    if description:
        schema["description"] = description
    return schema


def _str(*, description: str | None = None, enum: list[str] | None = None) -> JsonDict:
    schema: JsonDict = {"type": "string"}
    if description:
        schema["description"] = description
    if enum is not None:
        schema["enum"] = enum
    return schema


def _bool(*, description: str | None = None) -> JsonDict:
    schema: JsonDict = {"type": "boolean"}
    if description:
        schema["description"] = description
    return schema


def _int(*, nullable: bool = False, description: str | None = None) -> JsonDict:
    schema: JsonDict = {"type": ["integer", "null"] if nullable else "integer"}
    if description:
        schema["description"] = description
    return schema


STRING_LIST = _arr(_str())

EVIDENCE_REFERENCE_SCHEMA = _obj(
    {
        "source_path": _str(description="File or handoff path containing the supporting evidence."),
        "locator": _str(description="Line, section, algorithm, symbol, property, or record locator."),
        "excerpt": _str(description="Short evidence excerpt or faithful summary."),
        "supports_claim": _str(description="The exact claim this evidence supports."),
        "confidence": _str(enum=["high", "medium", "low", "unknown"]),
    },
    description="Traceable evidence reference for one claim.",
)

UNCERTAINTY_SCHEMA = _obj(
    {
        "issue": _str(),
        "impact": _str(),
    }
)

DETERMINISTIC_DISAGREEMENT_SCHEMA = _obj(
    {
        "deterministic_claim": _str(),
        "primary_evidence_finding": _str(),
        "resolution": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
    }
)

DETERMINISTIC_ASSESSMENT_SCHEMA = _obj(
    {
        "used": _bool(),
        "status": _str(),
        "warning": _str(),
        "disagreements": _arr(DETERMINISTIC_DISAGREEMENT_SCHEMA),
    }
)

SOURCE_SCOPE_SCHEMA = _obj(
    {
        "primary_sources_used": _arr(_str()),
        "provided_material_complete": _bool(),
        "missing_or_unavailable_material": _arr(_str()),
    }
)

FACT_ITEM_SCHEMA = _obj(
    {
        "fact_id": _str(),
        "category": _str(),
        "statement": _str(),
        "verification_relevance": _str(),
        "confidence": _str(enum=["high", "medium", "low", "unknown"]),
        "uncertainty": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "limitations": _arr(_str()),
    }
)

TERMINOLOGY_ITEM_SCHEMA = _obj(
    {
        "term": _str(),
        "meaning": _str(),
        "preservation_rule": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
    }
)

SPEC_SUMMARY_SCHEMA: JsonDict = _obj(
    {
        "stage": _str(enum=["02_spec_extraction"]),
        "mock": _bool(),
        "llm_call_executed": _bool(),
        "source_scope": SOURCE_SCOPE_SCHEMA,
        "spec_facts": _arr(FACT_ITEM_SCHEMA),
        "constants_and_parameters": _arr(FACT_ITEM_SCHEMA),
        "algorithms_or_steps": _arr(FACT_ITEM_SCHEMA),
        "equations_and_bounds": _arr(FACT_ITEM_SCHEMA),
        "candidate_preconditions": _arr(FACT_ITEM_SCHEMA),
        "candidate_postconditions": _arr(FACT_ITEM_SCHEMA),
        "candidate_verification_relevance": _arr(FACT_ITEM_SCHEMA),
        "terminology_to_preserve": _arr(TERMINOLOGY_ITEM_SCHEMA),
        "deterministic_reference_assessment": DETERMINISTIC_ASSESSMENT_SCHEMA,
        "uncertainties": _arr(UNCERTAINTY_SCHEMA),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "limitations": _arr(_str()),
    },
    description="Agent 2 candidate specification summary. It is not proof or a compliance determination.",
)

CODE_SOURCE_SCOPE_SCHEMA = _obj(
    {
        "primary_sources_used": _arr(_str()),
        "provided_material_complete": _bool(),
        "missing_or_unavailable_material": _arr(_str()),
        "previous_spec_summary_available": _bool(),
    }
)

FUNCTION_ITEM_SCHEMA = _obj(
    {
        "name": _str(),
        "signature": _str(),
        "role": _str(),
        "inputs": _arr(_str()),
        "outputs": _arr(_str()),
        "modified_memory": _arr(_str()),
        "preconditions_or_contracts": _arr(_str()),
        "postconditions_or_contracts": _arr(_str()),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "uncertainty": _str(),
        "limitations": _arr(_str()),
    }
)

CODE_SUMMARY_SCHEMA: JsonDict = _obj(
    {
        "stage": _str(enum=["03_code_understanding"]),
        "mock": _bool(),
        "llm_call_executed": _bool(),
        "source_scope": CODE_SOURCE_SCOPE_SCHEMA,
        "functions": _arr(FUNCTION_ITEM_SCHEMA),
        "macros_constants_types": _arr(FACT_ITEM_SCHEMA),
        "loops_and_indexing": _arr(FACT_ITEM_SCHEMA),
        "memory_and_pointer_facts": _arr(FACT_ITEM_SCHEMA),
        "arithmetic_and_range_facts": _arr(FACT_ITEM_SCHEMA),
        "existing_contracts_assertions_annotations": _arr(FACT_ITEM_SCHEMA),
        "input_output_mutation_facts": _arr(FACT_ITEM_SCHEMA),
        "candidate_code_level_facts": _arr(FACT_ITEM_SCHEMA),
        "deterministic_reference_assessment": DETERMINISTIC_ASSESSMENT_SCHEMA,
        "uncertainties": _arr(UNCERTAINTY_SCHEMA),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "limitations": _arr(_str()),
    },
    description="Agent 3 candidate code-understanding summary. It is not proof.",
)

CANDIDATE_PROPERTY_ITEM_SCHEMA = _obj(
    {
        "property_id": _str(),
        "property_family_id": _str(enum=property_family_ids()),
        "title": _str(),
        "category": _str(),
        "verification_strategy": _str(enum=strategy_ids()),
        "proof_obligation_kind": _str(enum=["safety", "range", "functional", "relational", "frame", "loop_contract", "function_contract", "analysis_only"]),
        "support_classification": _str(enum=["production_supported", "production_supported_scoped", "stretch_supported", "analysis_only", "test_or_relational_supported"]),
        "required_tool_capabilities": _arr(_str()),
        "candidate_statement": _str(),
        "supporting_evidence": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "required_assumptions": _arr(_str()),
        "cbmc_feasibility": _str(enum=["high", "medium", "low", "unknown"]),
        "risk_level": _str(enum=["low", "medium", "high", "critical", "unknown"]),
        "expected_artifact_type": _str(),
        "out_of_scope_boundaries": _arr(_str()),
        "uncertainty": _str(),
        "limitations": _arr(_str()),
    }
)

REJECTED_PROPERTY_ITEM_SCHEMA = _obj(
    {
        "property_id": _str(),
        "title": _str(),
        "reason": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
    }
)

ASSUMPTION_CATALOGUE_ITEM_SCHEMA = _obj(
    {
        "assumption_id": _str(),
        "statement": _str(),
        "justification": _str(),
        "risk_if_wrong": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
    }
)

FEASIBILITY_ITEM_SCHEMA = _obj(
    {
        "property_id": _str(),
        "rank": _int(),
        "feasibility": _str(enum=["high", "medium", "low", "unknown"]),
        "rationale": _str(),
    }
)

PROPERTY_SOURCE_SCOPE_SCHEMA = _obj(
    {
        "previous_spec_summary_available": _bool(),
        "previous_code_summary_available": _bool(),
        "provided_material_complete": _bool(),
        "missing_or_unavailable_material": _arr(_str()),
    }
)

CANDIDATE_PROPERTIES_SCHEMA: JsonDict = _obj(
    {
        "stage": _str(enum=["04_property_discovery"]),
        "mock": _bool(),
        "llm_call_executed": _bool(),
        "source_scope": PROPERTY_SOURCE_SCOPE_SCHEMA,
        "candidate_properties": _arr(CANDIDATE_PROPERTY_ITEM_SCHEMA),
        "rejected_or_downgraded_properties": _arr(REJECTED_PROPERTY_ITEM_SCHEMA),
        "assumptions_catalogue": _arr(ASSUMPTION_CATALOGUE_ITEM_SCHEMA),
        "feasibility_ranking": _arr(FEASIBILITY_ITEM_SCHEMA),
        "uncertainty_register": _arr(UNCERTAINTY_SCHEMA),
        "deterministic_reference_assessment": DETERMINISTIC_ASSESSMENT_SCHEMA,
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "limitations": _arr(_str()),
    },
    description="Agent 4 candidate property catalogue. No property is claimed as proven.",
)

SELECTED_PROPERTY_SCHEMA = _obj(
    {
        "selected": _bool(),
        "selection_method": _str(),
        "property": CANDIDATE_PROPERTY_ITEM_SCHEMA,
    }
)

ASSUMPTION_PLAN_ITEM_SCHEMA = _obj(
    {
        "assumption_id": _str(),
        "assumption": _str(),
        "justification": _str(),
        "risk_of_overconstraint": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
    }
)

ASSERTION_PLAN_ITEM_SCHEMA = _obj(
    {
        "assertion_id": _str(),
        "assertion": _str(),
        "checked_property_relation": _str(),
        "non_triviality_reason": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
    }
)

OLD_STATE_PLAN_SCHEMA = _obj(
    {
        "required": _str(),
        "reason": _str(),
        "snapshot_items": _arr(_str()),
    }
)

VALIDATION_EXPECTATION_SCHEMA = _obj(
    {
        "check": _str(),
        "expected": _bool(),
    }
)

INDEPENDENCE_STATEMENT_SCHEMA = _obj(
    {
        "existing_artefacts_consulted": _arr(_str()),
        "deterministic_hints_consulted": _arr(_str()),
        "unavoidable_similarities": _arr(_str()),
        "intentional_differences": _arr(_str()),
        "copying_risk": _str(),
        "requires_human_similarity_review": _bool(),
    }
)

CONTRACT_PATCH_OPERATION_SCHEMA = _obj(
    {
        "patch_id": _str(),
        "operation_kind": _str(enum=["insert_loop_contract_after_guard"]),
        "target_source_path": _str(),
        "purpose": _str(),
        "expected_original": _str(),
        "replacement": _str(),
        "expected_occurrences": _int(),
        "requires_human_review": _bool(),
    }
)

CONTRACT_PLAN_SCHEMA = _obj(
    {
        "enabled": _bool(),
        "contract_mode": _str(enum=["none", "loop", "function", "loop_and_function"]),
        "target_symbol": _str(),
        "function_declaration": _str(),
        "requires_clauses": _arr(_str()),
        "ensures_clauses": _arr(_str()),
        "assigns_clauses": _arr(_str()),
        "frees_clauses": _arr(_str()),
        "loop_invariant_clauses": _arr(_str()),
        "decreases_clauses": _arr(_str()),
        "loop_assigns_clauses": _arr(_str()),
        "loop_frees_clauses": _arr(_str()),
        "source_patch_operations": _arr(CONTRACT_PATCH_OPERATION_SCHEMA),
        "apply_loop_contracts": _bool(),
        "enforce_contract": _bool(),
        "replace_calls_with_contract": _arr(_str()),
        "use_dfcc": _bool(),
        "invariant_initialization_argument": _str(),
        "invariant_preservation_argument": _str(),
        "postcondition_use_argument": _str(),
        "frame_condition_argument": _str(),
        "history_variable_usage": _arr(_str()),
    }
)

RELATIONAL_PLAN_SCHEMA = _obj(
    {
        "enabled": _bool(),
        "relation_kind": _str(enum=["none", "round_trip", "packing_consistency", "determinism", "two_run_equivalence", "custom"]),
        "first_call": _str(),
        "second_call": _str(),
        "state_reset_or_snapshot": _arr(_str()),
        "relation_assertions": _arr(_str()),
        "normalization_assumptions": _arr(_str()),
    }
)

ANALYSIS_ONLY_PLAN_SCHEMA = _obj(
    {
        "enabled": _bool(),
        "analysis_kind": _str(enum=["none", "secret_dependent_control_flow", "secret_dependent_memory_access", "external_test_support", "manual_review_support"]),
        "evidence_to_collect": _arr(_str()),
        "external_tools_or_tests": _arr(_str()),
        "formal_claim_prohibited": _bool(),
    }
)

ARTIFACT_PLAN_SCHEMA: JsonDict = _obj(
    {
        "stage": _str(enum=["05_artifact_generation"]),
        "mock": _bool(),
        "llm_call_executed": _bool(),
        "target_function": _str(),
        "selected_property": SELECTED_PROPERTY_SCHEMA,
        "artefact_kind": _str(),
        "verification_strategy": _str(enum=strategy_ids()),
        "intended_check": _str(),
        "non_goals": _arr(_str()),
        "required_includes": _arr(_str()),
        "required_types_and_macros": _arr(_str()),
        "assumption_plan": _arr(ASSUMPTION_PLAN_ITEM_SCHEMA),
        "assertion_plan": _arr(ASSERTION_PLAN_ITEM_SCHEMA),
        "old_state_snapshot_plan": OLD_STATE_PLAN_SCHEMA,
        "contract_plan": CONTRACT_PLAN_SCHEMA,
        "relational_plan": RELATIONAL_PLAN_SCHEMA,
        "analysis_only_plan": ANALYSIS_ONLY_PLAN_SCHEMA,
        "generated_harness_code": _str(),
        "validation_expectations": _arr(VALIDATION_EXPECTATION_SCHEMA),
        "independence_statement": INDEPENDENCE_STATEMENT_SCHEMA,
        "deterministic_reference_assessment": DETERMINISTIC_ASSESSMENT_SCHEMA,
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "limitations": _arr(_str()),
    },
    description="Agent 5 candidate artefact plan and candidate harness source. Not a proof result.",
)

REVIEWED_ARTEFACTS_SCHEMA = _obj(
    {
        "target_function": _str(),
        "deterministic_recommended_gate": {"type": ["string", "null"]},
    }
)

REVIEW_ISSUE_SCHEMA = _obj(
    {
        "issue": _str(),
        "impact": _str(),
    }
)

REVIEW_SECTION_SCHEMA = _obj(
    {
        "status": _str(),
        "findings": _arr(REVIEW_ISSUE_SCHEMA),
    }
)

CRITIC_REVIEW_SCHEMA: JsonDict = _obj(
    {
        "stage": _str(enum=["06_review_critic"]),
        "mock": _bool(),
        "llm_call_executed": _bool(),
        "reviewed_artefacts": REVIEWED_ARTEFACTS_SCHEMA,
        "overall_assessment": _str(),
        "gate_recommendation": _str(
            enum=[
                "approved_for_tool_execution",
                "approved_for_analysis_only",
                "needs_revision_before_tool_execution",
                "blocked_due_to_critical_issue",
                "human_review_required",
            ]
        ),
        "blocking_issues": _arr(REVIEW_ISSUE_SCHEMA),
        "warnings": _arr(REVIEW_ISSUE_SCHEMA),
        "minor_issues": _arr(REVIEW_ISSUE_SCHEMA),
        "assumption_review": REVIEW_SECTION_SCHEMA,
        "assertion_review": REVIEW_SECTION_SCHEMA,
        "old_state_new_state_review": REVIEW_SECTION_SCHEMA,
        "contract_review": REVIEW_SECTION_SCHEMA,
        "verification_strategy_review": REVIEW_SECTION_SCHEMA,
        "independence_review": REVIEW_SECTION_SCHEMA,
        "scope_and_overclaim_review": REVIEW_SECTION_SCHEMA,
        "deterministic_reference_assessment": DETERMINISTIC_ASSESSMENT_SCHEMA,
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "limitations": _arr(_str()),
    },
    description="Agent 6 critic review and pre-tool gate recommendation. Not a proof result.",
)

FAILURE_CLASSIFICATION_SCHEMA = _obj(
    {
        "result_classification": _str(),
        "failure_categories": _arr(_str()),
        "severity": _str(),
        "repair_needed": _bool(),
        "no_formal_tool_result": _bool(),
        "parsed_failure_count": _int(),
        "interpretation_boundary": _str(),
    }
)

TOOL_RESULT_SUMMARY_SCHEMA = _obj(
    {
        "result_classification": _str(),
        "tool_executed": _bool(),
        "exit_code": _int(nullable=True),
        "summary": _str(),
    }
)

EXECUTION_INTERPRETATION_SCHEMA = _obj(
    {
        "status": _str(),
        "formal_tool_result_exists": _bool(),
        "interpretation": _str(),
    }
)

ANALYSIS_FINDING_SCHEMA = _obj(
    {
        "finding_id": _str(),
        "category": _str(),
        "finding": _str(),
        "evidence_basis": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "uncertainty": _str(),
    }
)

COUNTEREXAMPLE_SECTION_SCHEMA = _obj(
    {
        "status": _str(),
        "findings": _arr(ANALYSIS_FINDING_SCHEMA),
    }
)

DIAGNOSIS_SCHEMA = _obj(
    {
        "status": _str(),
        "root_cause_category": _str(),
        "findings": _arr(ANALYSIS_FINDING_SCHEMA),
    }
)

REPAIR_ACTION_SCHEMA = _obj(
    {
        "action_id": _str(),
        "action_type": _str(),
        "priority": _str(),
        "target_stage": _str(),
        "proposed_change": _str(),
        "evidence_basis": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "risk_if_applied": _str(),
        "evidence_strength_lost_if_any": _str(),
    }
)

REPAIR_GUIDANCE_SCHEMA = _obj(
    {
        "status": _str(),
        "guidance_items": _arr(REPAIR_ACTION_SCHEMA),
    }
)

SUCCESS_SCOPE_SCHEMA = _obj(
    {
        "status": _str(),
        "checked_scope": _arr(_str()),
        "not_checked": _arr(_str()),
        "limitations": _arr(_str()),
    }
)

COUNTEREXAMPLE_ANALYSIS_SCHEMA: JsonDict = _obj(
    {
        "stage": _str(enum=["08_counterexample_analysis"]),
        "mock": _bool(),
        "llm_call_executed": _bool(),
        "tool_result_summary": TOOL_RESULT_SUMMARY_SCHEMA,
        "execution_status_interpretation": EXECUTION_INTERPRETATION_SCHEMA,
        "counterexample_analysis": COUNTEREXAMPLE_SECTION_SCHEMA,
        "failure_classification": FAILURE_CLASSIFICATION_SCHEMA,
        "harness_vs_property_vs_tool_diagnosis": DIAGNOSIS_SCHEMA,
        "repair_guidance": REPAIR_GUIDANCE_SCHEMA,
        "repair_action_plan": _arr(REPAIR_ACTION_SCHEMA),
        "success_scope_analysis": SUCCESS_SCOPE_SCHEMA,
        "deterministic_reference_assessment": DETERMINISTIC_ASSESSMENT_SCHEMA,
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "limitations": _arr(_str()),
    },
    description="Agent 8 analysis of Agent 7 evidence. It must not invent tool results.",
)

REPAIR_DECISION_SCHEMA = _obj(
    {
        "decision": _str(),
        "based_on_result_classification": _str(),
        "deterministic_triage_decision": _str(),
    }
)

REPAIR_SCOPE_SCHEMA = _obj(
    {
        "allowed": _arr(_str()),
        "source_code_repair_allowed": _bool(),
        "apply_repair_requested": _bool(),
        "note": _str(),
    }
)

PROPOSED_REPAIR_SCHEMA = _obj(
    {
        "repair_id": _str(),
        "repair_type": _str(),
        "target_file_or_stage": _str(),
        "proposed_change": _str(),
        "evidence_basis": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "preserves_property_strength": _bool(),
        "risk_if_applied": _str(),
        "evidence_strength_lost_if_any": _str(),
        "requires_human_review": _bool(),
    }
)

CHANGE_ITEM_SCHEMA = _obj(
    {
        "change_id": _str(),
        "target": _str(),
        "proposed_change": _str(),
        "justification": _str(),
        "risk": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
    }
)

EVIDENCE_IMPACT_SCHEMA = _obj(
    {
        "status": _str(),
        "evidence_strength_lost_if_any": _str(),
    }
)

SAFETY_REVIEW_SCHEMA = _obj(
    {
        "status": _str(),
        "blocks_silent_application": _bool(),
    }
)

RERUN_RECOMMENDATION_SCHEMA = _obj(
    {
        "recommend_rerun": _bool(),
        "reason": _str(),
        "next_stage": _str(),
    }
)

REPAIR_PLAN_SCHEMA: JsonDict = _obj(
    {
        "stage": _str(enum=["09_repair_refinement"]),
        "mock": _bool(),
        "llm_call_executed": _bool(),
        "repair_decision": REPAIR_DECISION_SCHEMA,
        "repair_scope": REPAIR_SCOPE_SCHEMA,
        "proposed_repairs": _arr(PROPOSED_REPAIR_SCHEMA),
        "assumption_changes": _arr(CHANGE_ITEM_SCHEMA),
        "assertion_changes": _arr(CHANGE_ITEM_SCHEMA),
        "harness_changes": _arr(CHANGE_ITEM_SCHEMA),
        "contract_changes": _arr(CHANGE_ITEM_SCHEMA),
        "command_or_environment_changes": _arr(CHANGE_ITEM_SCHEMA),
        "source_code_changes": _arr(CHANGE_ITEM_SCHEMA),
        "evidence_strength_impact": EVIDENCE_IMPACT_SCHEMA,
        "safety_review": SAFETY_REVIEW_SCHEMA,
        "rerun_recommendation": RERUN_RECOMMENDATION_SCHEMA,
        "candidate_repaired_harness_code": _str(),
        "candidate_repaired_contract_plan": CONTRACT_PLAN_SCHEMA,
        "candidate_repaired_relational_plan": RELATIONAL_PLAN_SCHEMA,
        "candidate_repaired_analysis_only_plan": ANALYSIS_ONLY_PLAN_SCHEMA,
        "deterministic_reference_assessment": DETERMINISTIC_ASSESSMENT_SCHEMA,
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "limitations": _arr(_str()),
    },
    description="Agent 9 candidate repair plan. A repair is not automatically trusted or applied.",
)

MEASURED_FACTS_SCHEMA = _obj(
    {
        "target_function": _str(),
        "target_topic": _str(),
        "property_family_id": _str(enum=property_family_ids()),
        "verification_strategy": _str(enum=strategy_ids()),
        "property_support_classification": _str(),
        "llm_modes_observed": _arr(_str()),
        "llm_call_executed_count": _int(),
        "cbmc_result_classification": _str(),
        "cbmc_tool_executed": _bool(),
        "tool_outcome_category": _str(),
        "integrity_status": _str(),
        "missing_expected_output_count": _int(),
        "summary": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
    }
)

LLM_INTERPRETATION_SCHEMA = _obj(
    {
        "status": _str(),
        "summary": _str(),
    }
)

RQ_ITEM_SCHEMA = _obj(
    {
        "research_question": _str(),
        "question_focus": _str(),
        "run_evidence": _arr(_str()),
        "supported_statement": _str(),
        "not_supported_statement": _str(),
    }
)

RQ_MAPPING_SCHEMA = _obj({"rows": _arr(RQ_ITEM_SCHEMA)})

USEFULNESS_SCHEMA = _obj(
    {
        "status": _str(),
        "bounded_statement": _str(),
        "supporting_observations": _arr(_str()),
    }
)

FAILURE_MODE_ITEM_SCHEMA = _obj(
    {
        "taxonomy_id": _str(),
        "label": _str(),
        "observed_in_run": _bool(),
        "evidence_basis": _str(),
        "evaluation_implication": _str(),
    }
)

FAILURE_MODE_ASSESSMENT_SCHEMA = _obj(
    {
        "result_classification": _str(),
        "tool_outcome_category": _str(),
        "rows": _arr(FAILURE_MODE_ITEM_SCHEMA),
        "limitations": _arr(_str()),
    }
)

HUMAN_REVIEW_REQUIRED_SCHEMA = _obj(
    {
        "required": _bool(),
        "status": _str(),
        "items": _arr(_str()),
    }
)

THREAT_ITEM_SCHEMA = _obj(
    {
        "threat_id": _str(),
        "category": _str(),
        "threat": _str(),
        "mitigation": _str(),
    }
)

THREATS_SCHEMA = _obj({"threats": _arr(THREAT_ITEM_SCHEMA)})

THESIS_WORDING_SCHEMA = _obj(
    {
        "status": _str(),
        "paragraph": _str(),
    }
)

EVIDENCE_GAP_SCHEMA = _obj(
    {
        "gap": _str(),
        "impact": _str(),
    }
)

CLAIM_BOUNDARIES_SCHEMA = _obj(
    {
        "proof_claimed": _bool(),
        "full_correctness_claimed": _bool(),
        "fips_compliance_claimed": _bool(),
        "cryptographic_security_claimed": _bool(),
        "mock_output": _bool(),
    }
)

EVALUATION_REPORT_SCHEMA: JsonDict = _obj(
    {
        "stage": _str(enum=["11_evaluation_reporter"]),
        "mock": _bool(),
        "llm_call_executed": _bool(),
        "measured_facts": MEASURED_FACTS_SCHEMA,
        "llm_interpretation": LLM_INTERPRETATION_SCHEMA,
        "rq_mapping": RQ_MAPPING_SCHEMA,
        "usefulness_assessment": USEFULNESS_SCHEMA,
        "failure_mode_assessment": FAILURE_MODE_ASSESSMENT_SCHEMA,
        "human_review_required": HUMAN_REVIEW_REQUIRED_SCHEMA,
        "deterministic_reference_assessment": DETERMINISTIC_ASSESSMENT_SCHEMA,
        "threats_to_validity": THREATS_SCHEMA,
        "thesis_safe_wording": THESIS_WORDING_SCHEMA,
        "evidence_gaps": _arr(EVIDENCE_GAP_SCHEMA),
        "claim_boundaries": CLAIM_BOUNDARIES_SCHEMA,
        "limitations": _arr(_str()),
    },
    description="Agent 11 evidence-bounded evaluation narrative. It must not overclaim proof or security.",
)

GENERIC_STAGE_SCHEMA: JsonDict = _obj(
    {
        "stage": _str(),
        "summary": _str(),
        "evidence_references": _arr(EVIDENCE_REFERENCE_SCHEMA),
        "limitations": _arr(_str()),
    }
)

ALL_STAGE_SCHEMAS: Dict[str, JsonDict] = {
    "SPEC_SUMMARY_SCHEMA": SPEC_SUMMARY_SCHEMA,
    "CODE_SUMMARY_SCHEMA": CODE_SUMMARY_SCHEMA,
    "CANDIDATE_PROPERTIES_SCHEMA": CANDIDATE_PROPERTIES_SCHEMA,
    "ARTIFACT_PLAN_SCHEMA": ARTIFACT_PLAN_SCHEMA,
    "CRITIC_REVIEW_SCHEMA": CRITIC_REVIEW_SCHEMA,
    "COUNTEREXAMPLE_ANALYSIS_SCHEMA": COUNTEREXAMPLE_ANALYSIS_SCHEMA,
    "REPAIR_PLAN_SCHEMA": REPAIR_PLAN_SCHEMA,
    "EVALUATION_REPORT_SCHEMA": EVALUATION_REPORT_SCHEMA,
    "GENERIC_STAGE_SCHEMA": GENERIC_STAGE_SCHEMA,
}

__all__ = [
    "JsonDict",
    "SPEC_SUMMARY_SCHEMA",
    "CODE_SUMMARY_SCHEMA",
    "CANDIDATE_PROPERTIES_SCHEMA",
    "ARTIFACT_PLAN_SCHEMA",
    "CRITIC_REVIEW_SCHEMA",
    "COUNTEREXAMPLE_ANALYSIS_SCHEMA",
    "REPAIR_PLAN_SCHEMA",
    "EVALUATION_REPORT_SCHEMA",
    "GENERIC_STAGE_SCHEMA",
    "ALL_STAGE_SCHEMAS",
]
