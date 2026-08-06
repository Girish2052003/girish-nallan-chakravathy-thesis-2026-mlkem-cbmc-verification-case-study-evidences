#!/usr/bin/env python3
"""Successful CBMC descriptions must never create semantic failure hints."""
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.counterexample_analysis_agent import (
    build_repair_guidance_diagnostic,
    classify_failure_mode,
)
from agents.common.tool_result_contract import SELECTED_PROPERTY_VERIFIED, VERIFICATION_FAILED_OR_UNKNOWN


def main() -> int:
    successful_text = (
        '[{"result":[{"property":"p.pointer","status":"SUCCESS",'
        '"description":"pointer dereference array bounds arithmetic overflow unwinding assertion"}]}]'
    )
    success_status = {
        "result_classification": SELECTED_PROPERTY_VERIFIED,
        "selected_property_verified_under_model": True,
        "emitted_property_count": 1,
        "emitted_failure_count": 0,
        "emitted_unknown_count": 0,
    }
    success_props = {
        "property_result_count": 1,
        "failure_count": 0,
        "unknown_count": 0,
        "failed_properties": [],
    }
    classified = classify_failure_mode(success_status, successful_text, "", success_props)
    assert classified["semantic_outcome"] == "bounded_selected_property_success", classified
    assert classified["failure_categories"] == [], classified
    assert classified["repair_needed"] is False, classified
    guidance = build_repair_guidance_diagnostic(classified, {})
    assert guidance["guidance_items"] == [{
        "repair_type": "no_repair_from_success",
        "priority": "none",
        "guidance": "No counterexample repair is suggested. Evaluate scope, assumptions, and limitations instead.",
    }], guidance

    # Positive control: the same terms in a failed-property row must still
    # produce the corresponding evidence-linked hints and repair guidance.
    failed_status = {
        "result_classification": VERIFICATION_FAILED_OR_UNKNOWN,
        "emitted_property_count": 1,
        "emitted_failure_count": 1,
        "emitted_unknown_count": 0,
    }
    failed_props = {
        "property_result_count": 1,
        "failure_count": 1,
        "unknown_count": 0,
        "failed_properties": [{
            "property_id": "p.failed",
            "status": "FAILURE",
            "description": "pointer dereference array bounds arithmetic overflow unwinding assertion",
        }],
    }
    failed = classify_failure_mode(failed_status, successful_text, "", failed_props)
    expected = {
        "selected_possible_pointer_or_memory_safety_failure",
        "selected_possible_array_bounds_failure",
        "selected_possible_arithmetic_overflow_failure",
        "selected_possible_unwinding_bound_issue",
        "selected_assertion_violation",
        "parsed_selected_failed_properties_available",
        "counterexample_or_property_failure",
    }
    assert expected <= set(failed["failure_categories"]), failed
    # Adjacent safety case: when structured failed rows are unavailable, an
    # unrelated generic failure must not cause successful pointer/bounds text
    # elsewhere in the same output to become semantic repair guidance.
    mixed_output = (
        successful_text + "\n"
        + "property p.actual FAILURE: user assertion violated"
    )
    failed_without_rows = classify_failure_mode(
        failed_status, mixed_output, "",
        {"property_result_count": 1, "failure_count": 1, "unknown_count": 0, "failed_properties": []},
    )
    mixed_categories = set(failed_without_rows["failure_categories"])
    assert "selected_assertion_violation" in mixed_categories, failed_without_rows
    assert "selected_possible_pointer_or_memory_safety_failure" not in mixed_categories, failed_without_rows
    assert "selected_possible_array_bounds_failure" not in mixed_categories, failed_without_rows
    assert "selected_possible_arithmetic_overflow_failure" not in mixed_categories, failed_without_rows
    assert "selected_possible_unwinding_bound_issue" not in mixed_categories, failed_without_rows

    failed_guidance = build_repair_guidance_diagnostic(failed, {})
    repair_types = {row["repair_type"] for row in failed_guidance["guidance_items"]}
    assert {
        "memory_assumption_or_pointer_model_fix",
        "array_bound_or_loop_assumption_fix",
        "range_assumption_or_arithmetic_property_fix",
        "unwind_bound_fix",
        "assertion_or_property_semantics_review",
    } <= repair_types, failed_guidance

    print("SUCCESS TEXT FAILURE-HINT GATING REGRESSION: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
