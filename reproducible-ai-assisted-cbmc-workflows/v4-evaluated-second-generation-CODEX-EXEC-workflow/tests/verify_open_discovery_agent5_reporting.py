#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.artifact_generation_agent import ArtifactGenerationConfig, build_mock_artifact_plan
from agents.common.llm_client import validate_json_schema
from agents.common.property_discovery_mode import validate_plan_against_open_selection
from agents.common.semantic_property import possible_encodings
from agents.common.schemas import ARTIFACT_PLAN_SCHEMA, EVALUATION_REPORT_SCHEMA
from agents.evaluation_reporter import EvaluationReporterConfig, build_measured_evaluation_facts, build_mock_evaluation_report

semantic = {
    "schema_version": "semantic_property.v2",
    "property_id": "OPEN_CAND_007",
    "statement": "The selected source-defined representation relation is preserved by mlk_poly_add.",
    "target_call": {"function": "mlk_poly_add", "arguments": ["&r", "&a", "&b"], "call_count": 1},
    "pre_state_objects": ["a", "b"],
    "post_state_objects": ["r"],
    "observed_memory": ["r", "a", "b"],
    "permitted_writes": ["r"],
    "required_assumptions": ["source-defined representation relation"],
    "success_predicate": "the source-defined representation relation holds for r after the exact target call",
    "quantified_domain": {"variable": "", "lower_bound": "", "upper_bound_exclusive": ""},
    "requires_pre_state_snapshot": False,
    "requires_modular_call_replacement": False,
    "requires_loop_reasoning": False,
    "requires_relational_execution": False,
    "analysis_only": False,
    "evidence_references": [],
    "uncertainty": "The exact source-defined relation must be instantiated by Agent 5 from primary evidence.",
    "semantic_completeness": {
        "complete": True,
        "missing_fields": [],
        "claim_boundary": "Structural completeness is not proof or frontend readiness.",
    },
}

selected = {
    "schema_version": "selected_property_handoff.v1",
    "discovery_mode": "open_discovery",
    "selected": True,
    "selection_method": "open_discovery_feasibility_then_risk_then_rank",
    "property": {
        "property_id": "OPEN_CAND_007",
        "property_family_id": "UNMAPPED",
        "title": "Repository-specific representation coherence",
        "category": "representation_coherence",
        "verification_strategy": "UNSELECTED",
        "proof_obligation_kind": "functional",
        "support_classification": "uncatalogued_candidate",
        "required_tool_capabilities": ["standard_cbmc_harness"],
        "candidate_statement": "The selected representation relation is preserved.",
        "supporting_evidence": [],
        "required_assumptions": ["source-defined representation relation"],
        "cbmc_feasibility": "medium",
        "risk_level": "medium",
        "expected_artifact_type": "CBMC harness",
        "out_of_scope_boundaries": [],
        "uncertainty": "novel candidate",
        "limitations": [],
        "semantic_property": semantic,
        "proposed_strategy": "UNSELECTED",
        "family_recommendation": "standard_cbmc_harness",
        "selection_authority": "not_selected_before_agent5",
        "possible_encodings": possible_encodings(semantic),
    },
    "selection_reason": "Selected after raw output persistence.",
    "catalogue_mapping_status": "unmapped_new",
}
cfg = ArtifactGenerationConfig(run_dir=ROOT / "runs" / "test", discovery_mode="open_discovery", property_family_id="UNMAPPED", verification_strategy="standard_cbmc_harness")
plan = build_mock_artifact_plan(cfg, selected)
plan_validation = validate_json_schema(plan, ARTIFACT_PLAN_SCHEMA)
assert plan_validation["valid"], plan_validation
binding = validate_plan_against_open_selection(plan, selected)
assert binding["valid"], binding
mutated = dict(plan)
mutated["selected_property"] = dict(plan["selected_property"])
mutated["selected_property"]["property"] = dict(plan["selected_property"]["property"])
mutated["selected_property"]["property"]["candidate_statement"] = "Agent 5 silently changed the property."
assert validate_plan_against_open_selection(mutated, selected)["valid"] is False

discovery_evidence = {
    "discovery_mode": "open_discovery",
    "catalogue_visible_during_llm_discovery": False,
    "raw_candidate_set": [{"property_id": "OPEN_CAND_007"}, {"property_id": "OPEN_CAND_008"}],
    "classified_candidate_set": [selected["property"], {**selected["property"], "property_id": "OPEN_CAND_008"}],
    "selected_property": selected,
    "selection_reason": selected["selection_reason"],
    "selection_method": selected["selection_method"],
    "selected_verification_strategy": "standard_cbmc_harness",
}
measured = build_measured_evaluation_facts(
    cfg=EvaluationReporterConfig(run_dir=ROOT / "runs" / "test", property_discovery_mode="open_discovery", property_family_id="UNMAPPED", verification_strategy="UNSELECTED", property_support_classification="unclassified"),
    experiment_log={"summary": {}}, run_record={}, stage_index={"rows": []}, handoff_index={"handoff_outputs": []}, checksum_manifest={"rows": []}, llm_index={"rows": []}, tool_index={}, gate_and_repair_index={}, property_discovery_evidence=discovery_evidence, failure_mode_log={}, integrity_validation={"validation_status": "valid", "warning_count": 0, "error_count": 0}, missing_outputs={"missing_count": 0},
)
assert measured["property_family_id"] == "UNMAPPED"
assert measured["verification_strategy"] == "standard_cbmc_harness"
assert measured["property_discovery"]["mode"] == "open_discovery"
assert measured["property_discovery"]["raw_candidate_count"] == 2
assert measured["property_discovery"]["selected_property_id"] == "OPEN_CAND_007"
report = build_mock_evaluation_report(measured, {"rows": [], "result_classification": "unknown", "tool_outcome_category": "unknown", "limitations": []}, {"rows": []}, {"threats": []})
validation = validate_json_schema(report, EVALUATION_REPORT_SCHEMA)
assert validation["valid"], validation
assert report["measured_facts"]["property_discovery_mode"] == "open_discovery"
assert report["measured_facts"]["catalogue_visible_during_llm_discovery"] is False
print("OPEN DISCOVERY AGENT 5 BINDING AND AGENT 10/11 REPORTING: PASS")
