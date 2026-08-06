#!/usr/bin/env python3
"""Blocker 1 verification: imports, JSON Schema validity, strictness, and mock-output validation."""

from __future__ import annotations

from pathlib import Path
import sys

try:
    import jsonschema
    from jsonschema.validators import Draft202012Validator
except ImportError as exc:
    raise SystemExit("Install test dependency first: python -m pip install jsonschema") from exc

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from agents.common.schemas import (  # noqa: E402
    ALL_STAGE_SCHEMAS,
    SPEC_SUMMARY_SCHEMA,
    CODE_SUMMARY_SCHEMA,
    CANDIDATE_PROPERTIES_SCHEMA,
    ARTIFACT_PLAN_SCHEMA,
    CRITIC_REVIEW_SCHEMA,
    COUNTEREXAMPLE_ANALYSIS_SCHEMA,
    REPAIR_PLAN_SCHEMA,
    EVALUATION_REPORT_SCHEMA,
)
from agents import (  # noqa: E402
    spec_extraction_agent as a2,
    code_understanding_agent as a3,
    property_discovery_agent as a4,
    artifact_generation_agent as a5,
    review_critic_agent as a6,
    counterexample_analysis_agent as a8,
    repair_agent as a9,
    evaluation_reporter as a11,
)


def check_strict_objects(node, path="schema"):
    errors = []
    if isinstance(node, dict):
        node_type = node.get("type")
        is_object = node_type == "object" or (isinstance(node_type, list) and "object" in node_type)
        if is_object:
            properties = node.get("properties", {})
            if node.get("additionalProperties") is not False:
                errors.append(f"{path}: additionalProperties must be false")
            if set(node.get("required", [])) != set(properties):
                errors.append(f"{path}: required fields must exactly match properties")
        for key, value in node.items():
            errors.extend(check_strict_objects(value, f"{path}/{key}"))
    elif isinstance(node, list):
        for index, value in enumerate(node):
            errors.extend(check_strict_objects(value, f"{path}/{index}"))
    return errors


def main() -> int:
    print("[1/4] Checking JSON Schema definitions...")
    strict_errors = []
    for name, schema in ALL_STAGE_SCHEMAS.items():
        Draft202012Validator.check_schema(schema)
        strict_errors.extend(check_strict_objects(schema, name))
        print(f"  PASS {name}")
    if strict_errors:
        for error in strict_errors:
            print(f"  FAIL {error}")
        return 1

    print("[2/4] Building schema-compatible mock outputs...")
    run_dir = PROJECT_ROOT / ".schema_test_run"
    source_meta = {
        "source_records": [],
        "combined_text_chars": 0,
        "combined_text_available": False,
    }
    code_meta = {**source_meta, "file_count": 0}
    classification = {
        "result_classification": "dry_run_not_executed",
        "failure_categories": ["no_tool_execution_dry_run"],
        "severity": "not_applicable",
        "repair_needed": False,
        "no_formal_tool_result": True,
        "parsed_failure_count": 0,
        "interpretation_boundary": "Raw Agent 7 evidence remains primary.",
    }
    deterministic_cex = {"classification": classification, "repair_guidance": {}}
    triage = {
        "result_classification": "dry_run_not_executed",
        "triage_decision": "no_semantic_repair_without_tool_result",
        "allowed_repair_scope": ["tooling"],
    }
    measured = {
        "target_function": "mlk_poly_add",
        "target_topic": "schema wiring test",
        "counts": {"llm_call_executed_count": 0, "missing_expected_output_count": 0},
        "llm_mode_counts": {"mock": 8},
        "tool_evidence": {
            "cbmc_result_classification": "dry_run_not_executed",
            "cbmc_tool_executed": False,
            "tool_outcome_category": "no_formal_tool_result_for_property",
        },
        "integrity": {"validation_status": "test", "missing_expected_output_count": 0},
    }
    taxonomy = {
        "result_classification": "dry_run_not_executed",
        "tool_outcome_category": "no_formal_tool_result_for_property",
        "rows": [],
        "limitations": [],
    }
    rq_mapping = {"rows": []}
    threats = {"threats": []}

    a4_output = a4.build_mock_candidate_properties(a4.PropertyDiscoveryConfig(run_dir), False, False)
    selected = a5.select_candidate_property(a4_output, None)
    cases = [
        ("Agent 2", a2.build_mock_spec_summary(a2.SpecExtractionConfig(run_dir, []), source_meta), SPEC_SUMMARY_SCHEMA),
        ("Agent 3", a3.build_mock_code_summary(a3.CodeUnderstandingConfig(run_dir, []), code_meta, False), CODE_SUMMARY_SCHEMA),
        ("Agent 4", a4_output, CANDIDATE_PROPERTIES_SCHEMA),
        ("Agent 5", a5.build_mock_artifact_plan(a5.ArtifactGenerationConfig(run_dir), selected), ARTIFACT_PLAN_SCHEMA),
        ("Agent 6", a6.build_mock_critic_review(a6.ReviewCriticConfig(run_dir), {"recommended_gate": "human_review_required"}), CRITIC_REVIEW_SCHEMA),
        ("Agent 8", a8.build_mock_counterexample_analysis(a8.CounterexampleAnalysisConfig(run_dir), deterministic_cex), COUNTEREXAMPLE_ANALYSIS_SCHEMA),
        ("Agent 9", a9.build_mock_repair_plan(a9.RepairRefinementConfig(run_dir), triage), REPAIR_PLAN_SCHEMA),
        ("Agent 11", a11.build_mock_evaluation_report(measured, taxonomy, rq_mapping, threats), EVALUATION_REPORT_SCHEMA),
    ]

    print("[3/4] Validating mock outputs...")
    for label, instance, schema in cases:
        jsonschema.validate(instance=instance, schema=schema)
        print(f"  PASS {label}")

    print("[4/4] Result: BLOCKER 1 PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
