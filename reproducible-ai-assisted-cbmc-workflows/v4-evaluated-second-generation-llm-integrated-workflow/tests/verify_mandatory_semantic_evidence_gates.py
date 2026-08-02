#!/usr/bin/env python3
"""Behavioral regressions for historical vacuity and formal-evidence defects."""
from __future__ import annotations

import json
import stat
import sys
import tempfile
import time
from copy import deepcopy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.cbmc_evidence import classify_evidence, parse_cbmc_json_output
from agents.common.semantic_gate import selected_property_coverage, validate_artifact_semantics
from agents.tool_execution_agent import execute_tool_pipeline


def plan(*, required_assumptions=None, claim_kind="cbmc_builtin") -> dict:
    property_id = "P16_BOUNDS"
    target_identity = f"TRACE_TARGET_CALL::{property_id}"
    claim_identity = f"TRACE_CLAIM::{property_id}::C01"
    return {
        "semantic_property": {
            "schema_version": "semantic_property.v2",
            "property_id": property_id,
            "statement": "The configured CBMC bounds checks for the selected target call succeed.",
            "target_call": {"function": "mlk_poly_add", "arguments": ["r", "a", "b"], "call_count": 1},
            "pre_state_objects": [],
            "post_state_objects": [],
            "observed_memory": ["r", "a", "b"],
            "permitted_writes": [],
            "required_assumptions": list(required_assumptions or []),
            "success_predicate": "all configured CBMC bounds checks for the selected target call succeed",
            "quantified_domain": {"variable": "", "lower_bound": "", "upper_bound_exclusive": ""},
            "requires_pre_state_snapshot": False,
            "requires_modular_call_replacement": False,
            "requires_loop_reasoning": False,
            "requires_relational_execution": False,
            "analysis_only": False,
            "evidence_references": [],
            "uncertainty": "The exact generated CBMC property identity remains decisive.",
        },
        "selected_property": {
            "selected": True,
            "selection_method": "fixture",
            "property": {
                "property_id": property_id,
                "property_family_id": "P16",
                "proof_obligation_kind": "array_bounds",
                "required_assumptions": list(required_assumptions or []),
            },
        },
        "verification_strategy": "standard_cbmc_harness",
        "assumption_plan": [],
        "assertion_plan": [],
        "old_state_snapshot_plan": {"required": "no", "reason": "bounds-only", "snapshot_items": []},
        "traceability_manifest": {
            "selected_property_id": property_id,
            "target_call_identity": target_identity,
            "target_call_marker": target_identity,
            "expected_claim_count": 1,
            "assumption_map": [],
            "claim_map": [{
                "assertion_id": "C01",
                "implementation_kind": claim_kind,
                "code_marker": claim_identity,
                "expected_property_identity": claim_identity,
                "rationale": "Selected bounds claim is mapped by exact generated-property identity.",
            }],
            "non_vacuity_strategy": ["Remove the target call and require the gate to block.", "Mutate the target access and require a CBMC failure."],
        },
    }


def issue_ids(result: dict) -> set[str]:
    return {str(x.get("issue_id")) for x in result.get("blocking_issues", [])}


def main() -> int:
    print("[1/6] Historical weak mlk_poly_add harness is blocked...")
    weak = plan(required_assumptions=["Every mathematical coefficient sum is representable in int16_t"], claim_kind="harness_assertion")
    weak["assumption_plan"] = [{"assumption_id": "A01", "assumption": "sum range", "justification": "avoid overflow", "risk_of_overconstraint": "medium", "evidence_references": []}]
    weak["assertion_plan"] = [{
        "assertion_id": "C01",
        "assertion": "r[i] == (int16_t)(a[i] + b[i])",
        "checked_property_relation": "functional postcondition equality",
        "placement": "after target call",
        "non_triviality_reason": "functional output relation",
        "evidence_references": [],
    }]
    harness = '''
#include <stdint.h>
#define MLKEM_N 256
void mlk_poly_add(int16_t r[MLKEM_N], const int16_t a[MLKEM_N], const int16_t b[MLKEM_N]);
void harness(void) {
  int16_t r[MLKEM_N], a[MLKEM_N], b[MLKEM_N];
  /* TRACE_TARGET_CALL::P16_BOUNDS */ mlk_poly_add(r, a, b);
  for (int i = 0; i < MLKEM_N; ++i) {
    __CPROVER_assert(i < MLKEM_N, "TRACE_CLAIM::P16_BOUNDS::C01");
    __CPROVER_assert(r[i] == (int16_t)(a[i] + b[i]), "unselected functional equality");
  }
}
'''
    result = validate_artifact_semantics(weak, harness, target_function="mlk_poly_add", property_campaign={"verification_strategy": "standard_cbmc_harness"})
    ids = issue_ids(result)
    required = {"missing_required_assumption", "loop_guard_tautology", "selected_property_scope_drift"}
    assert required.issubset(ids), (required, ids, result)
    assert result["valid"] is False
    print("  PASS", sorted(required))

    print("[2/6] Valid bounds-only target-call model remains tool-ready...")
    valid_harness = '''
#include <stdint.h>
void mlk_poly_add(int16_t r[256], const int16_t a[256], const int16_t b[256]);
void harness(void) {
  int16_t r[256], a[256], b[256];
  /* TRACE_TARGET_CALL::P16_BOUNDS */ mlk_poly_add(r, a, b);
}
'''
    valid = validate_artifact_semantics(plan(), valid_harness, target_function="mlk_poly_add", property_campaign={"verification_strategy": "standard_cbmc_harness"})
    assert valid["valid"] is True, valid
    assert valid["meaningful_mapped_claim_count"] == 1
    print("  PASS")

    print("[3/6] Missing target, zero claim, and contradictory assumptions fail closed...")
    no_call = validate_artifact_semantics(plan(), valid_harness.replace("mlk_poly_add(r, a, b);", "(void)r;"), target_function="mlk_poly_add")
    assert "target_call_missing_or_irrelevant" in issue_ids(no_call)
    zero = plan(); zero["traceability_manifest"]["expected_claim_count"] = 0; zero["traceability_manifest"]["claim_map"] = []
    zero_result = validate_artifact_semantics(zero, valid_harness, target_function="mlk_poly_add")
    assert {"zero_selected_claims", "missing_selected_property_claim"}.issubset(issue_ids(zero_result))
    contradictory = validate_artifact_semantics(plan(), valid_harness.replace("/* TRACE_TARGET_CALL::P16_BOUNDS */", "__CPROVER_assume(0); /* TRACE_TARGET_CALL::P16_BOUNDS */"), target_function="mlk_poly_add")
    assert "contradictory_or_vacuous_assumption" in issue_ids(contradictory)
    print("  PASS")

    print("[4/6] Structured CBMC JSON and selected-property coverage remain separate...")
    success_json = json.dumps([{"result": [{"property": "TRACE_CLAIM::P16_BOUNDS::C01", "description": "array bounds", "status": "SUCCESS"}]}])
    parsed = parse_cbmc_json_output(success_json)
    assert parsed["json_valid"] and parsed["property_result_count"] == 1
    coverage = selected_property_coverage(plan()["traceability_manifest"], parsed["property_results"])
    assert coverage["coverage_complete"] is True, coverage
    classified = classify_evidence(executed=True, exit_code=0, timeout=False, skipped=False, dry_run=False, unavailable=False, analysis_only=False, pipeline_setup_failed=False, structured=parsed, coverage=coverage)
    assert classified["result_classification"] == "selected_property_verified_under_recorded_model", classified

    empty = parse_cbmc_json_output("[]")
    no_evidence = classify_evidence(executed=True, exit_code=0, timeout=False, skipped=False, dry_run=False, unavailable=False, analysis_only=False, pipeline_setup_failed=False, structured=empty, coverage={"coverage_complete": False})
    assert no_evidence["result_classification"] == "tool_success_no_emitted_property_evidence"
    print("  PASS")

    print("[5/6] Mutation fixture changes formal classification from success to failure...")
    failure_json = json.dumps([{"result": [{"property": "TRACE_CLAIM::P16_BOUNDS::C01", "description": "array bounds mutation", "status": "FAILURE", "trace": [{"stepType": "failure"}]}]}])
    mutant = parse_cbmc_json_output(failure_json)
    mutant_cov = selected_property_coverage(plan()["traceability_manifest"], mutant["property_results"])
    mutant_class = classify_evidence(executed=True, exit_code=10, timeout=False, skipped=False, dry_run=False, unavailable=False, analysis_only=False, pipeline_setup_failed=False, structured=mutant, coverage=mutant_cov)
    assert mutant_class["result_classification"] == "verification_failed_or_unknown"
    assert mutant["failure_count"] == 1
    print("  PASS")

    print("[6/6] Overall pipeline deadline overrides per-step allowance...")
    with tempfile.TemporaryDirectory(prefix="pipeline_timeout_") as td:
        tmp = Path(td)
        sleeper = tmp / "sleep_tool.py"
        sleeper.write_text("#!/usr/bin/env python3\nimport time\ntime.sleep(0.7)\n", encoding="utf-8")
        sleeper.chmod(sleeper.stat().st_mode | stat.S_IXUSR)
        started = time.monotonic()
        execution = execute_tool_pipeline(
            [
                {"step_id": "sleep_1", "tool": "fake", "command": [str(sleeper)], "authoritative_result_step": False},
                {"step_id": "sleep_2", "tool": "fake", "command": [str(sleeper)], "authoritative_result_step": True},
            ],
            cwd=tmp,
            step_timeout_seconds=1,
            pipeline_timeout_seconds=1,
            output_dir=tmp / "logs",
        )
        elapsed = time.monotonic() - started
        assert execution["timeout"] is True, execution
        assert elapsed < 2.5, elapsed
    print("  PASS")

    print("MANDATORY SEMANTIC AND EVIDENCE GATES: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
