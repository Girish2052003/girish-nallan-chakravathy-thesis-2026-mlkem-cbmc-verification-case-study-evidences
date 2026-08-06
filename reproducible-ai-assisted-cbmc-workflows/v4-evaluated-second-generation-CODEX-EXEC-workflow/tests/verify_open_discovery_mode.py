#!/usr/bin/env python3
from __future__ import annotations

import copy
import json
import tempfile
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.config_contract import ConfigContractError, normalize_config, validate_pipeline_config
from agents.common.llm_client import validate_json_schema
from agents.common.property_discovery_mode import (
    OPEN_DISCOVERY,
    PropertyDiscoveryModeError,
    classify_open_candidates,
    select_open_candidate,
)
from agents.common.schemas import CANDIDATE_PROPERTIES_SCHEMA, OPEN_CANDIDATE_PROPERTIES_SCHEMA
from agents.common.property_catalog import property_family_ids, strategy_ids, PROPERTY_FAMILIES
from agents.spec_extraction_agent import SpecExtractionConfig, build_agent2_prompt
from agents.code_understanding_agent import CodeUnderstandingConfig, build_agent3_prompt
from agents.property_discovery_agent import PropertyDiscoveryConfig, build_agent4_prompt

open_template = ROOT / "configs" / "CONFIG_TEMPLATE_OPEN_DISCOVERY.json"
targeted_template = ROOT / "configs" / "CONFIG_TEMPLATE_MUTABLE_WORKSPACE.json"
open_raw = json.loads(open_template.read_text(encoding="utf-8"))
targeted_raw = json.loads(targeted_template.read_text(encoding="utf-8"))

open_cfg = normalize_config(open_raw, config_path=open_template, project_root=ROOT)
targeted_cfg = normalize_config(targeted_raw, config_path=targeted_template, project_root=ROOT)
assert open_cfg["property_discovery"]["mode"] == OPEN_DISCOVERY
assert open_cfg["property_campaign"]["property_family_id"] == "UNMAPPED"
assert open_cfg["property_campaign"]["verification_strategy"] == "UNSELECTED"
assert targeted_cfg["property_discovery"]["mode"] == "targeted_campaign"
assert targeted_cfg["property_campaign"]["property_family_id"] == "P16"
assert not validate_pipeline_config(open_cfg, check_input_files=False).errors
assert not validate_pipeline_config(targeted_cfg, check_input_files=False).errors

# Resolved open configs are reloaded independently by Agents 2--11. Normalization
# must therefore be idempotent while still rejecting a genuine preselection.
open_cfg_twice = normalize_config(open_cfg, config_path=open_template, project_root=ROOT)
assert open_cfg_twice["property_discovery"]["mode"] == OPEN_DISCOVERY
assert open_cfg_twice["property_campaign"]["schema_version"] == "property_campaign.v2.open_unselected"
for forbidden_campaign in (
    {"property_family_id": "P16"},
    {"verification_strategy": "standard_cbmc_harness"},
):
    invalid = copy.deepcopy(open_raw)
    invalid["property_campaign"] = forbidden_campaign
    try:
        normalize_config(invalid, config_path=open_template, project_root=ROOT)
    except ConfigContractError:
        pass
    else:
        raise AssertionError("Open discovery accepted a user-preselected targeted campaign.")

# Every existing P01--P26 campaign fragment must remain valid without rewriting.
fragments = sorted((ROOT / "configs" / "property_campaigns").glob("P*.json"))
assert len(fragments) == 26, len(fragments)
for fragment_path in fragments:
    fragment = json.loads(fragment_path.read_text(encoding="utf-8"))
    candidate = copy.deepcopy(targeted_raw)
    candidate["property_campaign"] = fragment["property_campaign"]
    normalized = normalize_config(candidate, config_path=targeted_template, project_root=ROOT)
    validation = validate_pipeline_config(normalized, check_input_files=False)
    assert not validation.errors, (fragment_path.name, validation.errors)

with tempfile.TemporaryDirectory() as td:
    run = Path(td)
    prompts = [
        build_agent2_prompt(cfg=SpecExtractionConfig(run_dir=run, spec_paths=[], discovery_mode=OPEN_DISCOVERY, property_family_id="UNMAPPED", property_family_title="", verification_strategy="UNSELECTED")),
        build_agent3_prompt(cfg=CodeUnderstandingConfig(run_dir=run, code_paths=[], discovery_mode=OPEN_DISCOVERY, property_family_id="UNMAPPED", property_family_title="", verification_strategy="UNSELECTED"), spec_summary_available=True),
        build_agent4_prompt(cfg=PropertyDiscoveryConfig(run_dir=run, discovery_mode=OPEN_DISCOVERY, property_family_id="UNMAPPED", verification_strategy="UNSELECTED", property_support_level="unclassified"), spec_available=True, code_available=True),
    ]
visible_surface = "\n".join(prompts) + "\n" + json.dumps(OPEN_CANDIDATE_PROPERTIES_SCHEMA, sort_keys=True)
for forbidden in [
    *property_family_ids(),
    *strategy_ids(),
    "PROPERTY_SUPPORT_CATALOGUE",
    "property_family_id",
    "verification_strategy",
    "support_classification",
    "required_tool_capabilities",
    "expected_artifact_type",
]:
    assert forbidden not in visible_surface, (forbidden, visible_surface[:2000])
for family in PROPERTY_FAMILIES:
    assert str(family.get("title") or "") not in visible_surface

def semantic_property(
    property_id: str,
    statement: str,
    assumptions: list[str],
    success_predicate: str,
    *,
    observed_memory: list[str] | None = None,
    permitted_writes: list[str] | None = None,
) -> dict:
    return {
        "schema_version": "semantic_property.v2",
        "property_id": property_id,
        "statement": statement,
        "target_call": {
            "function": "mlk_poly_add",
            "arguments": ["&r", "&a", "&b"],
            "call_count": 1,
        },
        "pre_state_objects": [],
        "post_state_objects": [],
        "observed_memory": observed_memory or ["r", "a", "b"],
        "permitted_writes": permitted_writes or [],
        "required_assumptions": assumptions,
        "success_predicate": success_predicate,
        "quantified_domain": {
            "variable": "",
            "lower_bound": "",
            "upper_bound_exclusive": "",
        },
        "requires_pre_state_snapshot": False,
        "requires_modular_call_replacement": False,
        "requires_loop_reasoning": False,
        "requires_relational_execution": False,
        "analysis_only": False,
        "evidence_references": [],
        "uncertainty": "Open-discovery test fixture only.",
        "semantic_completeness": {
            "complete": True,
            "missing_fields": [],
            "claim_boundary": "Structural completeness is not proof or frontend readiness.",
        },
    }


raw = {
    "stage": "04_property_discovery",
    "mock": False,
    "llm_call_executed": True,
    "source_scope": {"previous_spec_summary_available": True, "previous_code_summary_available": True, "provided_material_complete": True, "missing_or_unavailable_material": []},
    "candidate_properties": [
        {"property_id": "OPEN_CAND_001", "title": "Array access safety", "category": "array_bounds", "proof_obligation_kind": "safety", "candidate_statement": "All modeled coefficient accesses remain in bounds.", "supporting_evidence": [], "required_assumptions": ["valid polynomial objects"], "cbmc_feasibility": "high", "risk_level": "low", "out_of_scope_boundaries": [], "uncertainty": "candidate only", "limitations": [], "semantic_property": semantic_property("OPEN_CAND_001", "All modeled coefficient accesses remain in bounds.", ["valid polynomial objects"], "all modeled coefficient accesses for the exact target call remain within valid object bounds")},
        {"property_id": "OPEN_CAND_002", "title": "Novel representation phase coherence", "category": "representation_phase_coherence", "proof_obligation_kind": "functional", "candidate_statement": "A repository-specific phase tag remains coherent across the helper call.", "supporting_evidence": [], "required_assumptions": ["phase tag semantics are supplied by source evidence"], "cbmc_feasibility": "medium", "risk_level": "medium", "out_of_scope_boundaries": [], "uncertainty": "not present in the planned catalogue", "limitations": [], "semantic_property": semantic_property("OPEN_CAND_002", "A repository-specific phase tag remains coherent across the helper call.", ["phase tag semantics are supplied by source evidence"], "the repository-specific phase tag remains coherent after the exact target call", observed_memory=["r", "phase_tag"])},
    ],
    "rejected_or_downgraded_properties": [],
    "assumptions_catalogue": [],
    "feasibility_ranking": [
        {"property_id": "OPEN_CAND_001", "rank": 1, "feasibility": "high", "rationale": "local safety"},
        {"property_id": "OPEN_CAND_002", "rank": 2, "feasibility": "medium", "rationale": "repository-specific"},
    ],
    "uncertainty_register": [],
    "evidence_references": [],
    "limitations": [],
}
assert validate_json_schema(raw, OPEN_CANDIDATE_PROPERTIES_SCHEMA)["valid"]
original = copy.deepcopy(raw)
derived, audit = classify_open_candidates(raw)
assert raw == original, "Post-classification mutated the raw authoritative candidate set."
assert len(derived["candidate_properties"]) == 2
assert len(audit["classifications"]) == 2
assert any(c["property_family_id"] == "UNMAPPED" for c in derived["candidate_properties"]), derived
assert audit["candidate_deletion_permitted"] is False
assert audit["candidate_rewrite_permitted"] is False
validation = validate_json_schema(derived, CANDIDATE_PROPERTIES_SCHEMA)
assert validation["valid"], validation
selected = select_open_candidate(derived)
assert selected["selected"] is True
assert selected["property"]["property_id"] == "OPEN_CAND_001"
try:
    select_open_candidate({"candidate_properties": []})
except PropertyDiscoveryModeError:
    pass
else:
    raise AssertionError("Missing open-discovery selection did not fail closed before Agent 5.")
print("OPEN DISCOVERY CONFIG, PROMPT ISOLATION, CLASSIFICATION AND SELECTION: PASS")
