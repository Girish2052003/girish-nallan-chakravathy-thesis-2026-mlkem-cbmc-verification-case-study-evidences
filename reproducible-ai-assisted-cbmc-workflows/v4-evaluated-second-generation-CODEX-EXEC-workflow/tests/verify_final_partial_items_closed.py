#!/usr/bin/env python3
"""Close the two locally testable items from the final 38-requirement audit."""
from agents.common.cbmc_capability import normalize_clause_record, validate_clause_record
from agents.common.property_discovery_mode import normalize_property_discovery
from agents.common.semantic_property import SELECTION_POLICIES, choose_property


def candidate(pid: str):
    return {
        "property_id": pid,
        "candidate_statement": "The input object is unchanged.",
        "semantic_property": {
            "schema_version": "semantic_property.v2",
            "property_id": pid,
            "statement": "The input object is unchanged.",
            "target_call": {"function": "target", "arguments": ["&out", "&in"], "call_count": 1},
            "pre_state_objects": ["in"],
            "post_state_objects": ["in"],
            "observed_memory": ["in"],
            "permitted_writes": [],
            "required_assumptions": [],
            "success_predicate": "in == old_in",
            "quantified_domain": {"variable": "", "lower_bound": "", "upper_bound_exclusive": ""},
            "requires_pre_state_snapshot": True,
            "requires_modular_call_replacement": False,
            "requires_loop_reasoning": False,
            "requires_relational_execution": False,
            "analysis_only": False,
            "evidence_references": [],
            "uncertainty": "",
        },
    }


# The misleading name is no longer canonical execution policy.
assert "frontend_ready_first" not in SELECTION_POLICIES
assert "harness_expressibility_first" in SELECTION_POLICIES
normalized = normalize_property_discovery(
    {"property_discovery": {"mode": "open_discovery", "catalogue_visibility": "hidden",
      "allow_uncatalogued_properties": True, "selection_policy": "frontend_ready_first"}},
    campaign_explicit=False,
)
assert normalized["selection_policy"] == "harness_expressibility_first"
assert normalized["selection_policy_migrated_from"] == "frontend_ready_first"
selected, authority = choose_property([candidate("P1")], policy="frontend_ready_first")
assert selected["property_id"] == "P1"
assert "migrated_from:frontend_ready_first" in authority

# Memory predicates and history-variable constructs have first-class records.
requires = normalize_clause_record({
    "clause_id": "R1", "clause_kind": "requires",
    "executable_expression": "__CPROVER_rw_ok(p, sizeof(*p))",
}, clause_kind="requires", index=0)
rcheck = validate_clause_record(requires, strict_typed=True)
assert rcheck["valid"] is True
assert rcheck["memory_predicate_validation"]["used"] == ["__CPROVER_rw_ok"]
assert rcheck["memory_predicate_validation"]["valid"] is True
assert rcheck["history_variable_validation"]["used"] == []

ensures = normalize_clause_record({
    "clause_id": "E1", "clause_kind": "ensures",
    "executable_expression": "*p == __CPROVER_old(*p) + 1",
}, clause_kind="ensures", index=0)
echeck = validate_clause_record(ensures, strict_typed=True)
assert echeck["valid"] is True
assert echeck["history_variable_validation"]["used"] == ["__CPROVER_old"]
assert echeck["history_variable_validation"]["valid"] is True

bad = dict(ensures); bad["clause_kind"] = "requires"
bcheck = validate_clause_record(bad, strict_typed=True)
assert bcheck["valid"] is False
assert bcheck["history_variable_validation"]["valid"] is False
assert bcheck["history_variable_validation"]["errors"]
print("FINAL PARTIAL ITEMS CLOSED: PASS")
