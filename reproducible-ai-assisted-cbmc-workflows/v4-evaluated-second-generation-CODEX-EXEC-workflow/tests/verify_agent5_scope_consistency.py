#!/usr/bin/env python3

from pathlib import Path
import sys
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from types import SimpleNamespace
from agents.artifact_generation_agent import validate_rendered_harness

cfg = SimpleNamespace(
    target_function="mlk_poly_add",
    cbmc_function="harness",
)

plan = {
    "selected_property": {
        "property": {
            "title": "Coefficient-array bounds safety",
            "category": "array_bounds",
            "proof_obligation_kind": "safety",
            "candidate_statement": "Check coefficient index bounds.",
            "expected_artifact_type": "CBMC bounds harness",
        }
    }
}

harness = r'''
#include "poly.h"

void harness(void)
{
    mlk_poly r_obj;
    mlk_poly b_obj;
    mlk_poly *r = &r_obj;
    mlk_poly *b = &b_obj;
    int16_t pre_r[MLKEM_N];

    mlk_poly_add(r, b);

    for (int i = 0; i < MLKEM_N; i++) {
        __CPROVER_assert(
            r->coeffs[i] == (int16_t)(pre_r[i] + b->coeffs[i]),
            "functional relation"
        );
    }
}
'''

result = validate_rendered_harness(harness, cfg, plan)

assert result["valid_for_handoff"] is False, result
assert result["scope_consistency_status"] == "blocked_selected_property_scope_drift", result
assert (
    "bounds_only_property_contains_functional_postcondition"
    in result["scope_consistency_warnings"]
), result
assert "selected_property_scope_drift" in result["blocking_patterns"], result
assert result["requires_human_review"] is True, result

print("AGENT 5 PROPERTY-SCOPE REGRESSION: PASS")
