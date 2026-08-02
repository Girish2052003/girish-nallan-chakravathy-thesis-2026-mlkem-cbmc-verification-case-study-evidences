#!/usr/bin/env python3

from pathlib import Path
import sys
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from agents.property_discovery_agent import (
    normalize_candidate_properties_for_campaign,
)
from agents.common.property_campaign import (
    validate_candidate_properties_for_campaign,
)


def candidate(
    property_id: str,
    strategy: str,
    *,
    proof_kind: str = "safety",
    support: str = "production_supported",
    category: str = "array_bounds",
):
    return {
        "property_id": property_id,
        "property_family_id": "P16",
        "title": property_id,
        "category": category,
        "verification_strategy": strategy,
        "proof_obligation_kind": proof_kind,
        "support_classification": support,
        "required_tool_capabilities": [strategy],
        "candidate_statement": "Candidate local property.",
        "supporting_evidence": [],
        "required_assumptions": [],
        "cbmc_feasibility": "high",
        "risk_level": "low",
        "expected_artifact_type": "CBMC harness",
        "out_of_scope_boundaries": [],
        "uncertainty": "Candidate only.",
        "limitations": [],
        "semantic_property": {
            "semantic_property_version": "semantic_property.v2.strategy_neutral",
            "property_id": property_id,
            "statement": "Candidate local property.",
            "target_call": {"function": "mlk_poly_add", "arguments": ["&r", "&b"]},
            "pre_state_objects": ["b"],
            "post_state_objects": ["r", "b"],
            "observed_memory": ["r.coeffs", "b.coeffs"],
            "permitted_writes": ["r.coeffs"],
            "required_assumptions": [],
            "success_predicate": "r.coeffs[0] == r.coeffs[0]",
            "quantified_domain": {
                "variable": "i",
                "lower_bound": "0",
                "upper_bound_exclusive": "MLKEM_N",
            },
            "requires_pre_state_snapshot": False,
            "requires_modular_call_replacement": False,
            "requires_loop_reasoning": False,
            "requires_relational_execution": False,
            "analysis_only": proof_kind == "analysis_only",
            "evidence_references": [],
            "uncertainty": "Campaign-separation fixture only.",
            "semantic_complete": proof_kind != "analysis_only",
        },
    }


campaign = {
    "property_family_id": "P16",
    "verification_strategy": "standard_cbmc_harness",
    "allowed_strategies": [
        "standard_cbmc_harness",
        "native_function_contract",
        "native_loop_contract",
        "hybrid_contract_and_harness",
    ],
}

payload = {
    "stage": "04_property_discovery",
    "candidate_properties": [
        candidate("P16_VALID", "standard_cbmc_harness"),
        candidate(
            "P16_ANALYSIS_NOTE",
            "analysis_only_no_formal_claim",
            proof_kind="analysis_only",
            support="analysis_only",
            category="analysis_only_no_formal_claim",
        ),
    ],
    "rejected_or_downgraded_properties": [],
}

normalized, audit = normalize_candidate_properties_for_campaign(
    payload,
    campaign,
)

ids = [
    item["property_id"]
    for item in normalized["candidate_properties"]
]

assert ids == ["P16_VALID"], ids
assert audit["moved_count"] == 1
assert audit["moved_property_ids"] == ["P16_ANALYSIS_NOTE"]
assert normalized["rejected_or_downgraded_properties"][0][
    "property_id"
] == "P16_ANALYSIS_NOTE"

validation = validate_candidate_properties_for_campaign(
    normalized,
    campaign,
)

assert validation["valid"] is True, validation

bad_payload = {
    "stage": "04_property_discovery",
    "candidate_properties": [
        candidate("P16_BAD_FORMAL", "relational_cbmc_harness"),
    ],
    "rejected_or_downgraded_properties": [],
}

bad_normalized, bad_audit = normalize_candidate_properties_for_campaign(
    bad_payload,
    campaign,
)

assert bad_audit["moved_count"] == 0
assert bad_normalized["candidate_properties"][0][
    "property_id"
] == "P16_BAD_FORMAL"

bad_validation = validate_candidate_properties_for_campaign(
    bad_normalized,
    campaign,
)

assert bad_validation["valid"] is False, bad_validation

source = open(
    "agents/property_discovery_agent.py",
    encoding="utf-8",
).read()

assert "CAMPAIGN-CANDIDATE SEPARATION — MANDATORY:" in source
assert "non_analysis_strategy_mismatches_are_not_repaired" in source

print("AGENT 4 CAMPAIGN-CANDIDATE SEPARATION REGRESSION: PASS")
