#!/usr/bin/env python3
"""Regression suite for the 26-property and native-contract extension."""
from __future__ import annotations

import json
import os
import stat
import tempfile
from copy import deepcopy
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[1]
import sys
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.config_contract import normalize_config, validate_pipeline_config
from agents.common.contract_artifacts import (
    apply_contract_source_patches,
    build_contract_header,
    validate_contract_plan,
    sha256_file,
)
from agents.common.formal_build import create_formal_build_plan, build_tool_pipeline_from_plan
from agents.common.property_catalog import (
    ANALYSIS_ONLY,
    FUNCTION_CONTRACT,
    HYBRID,
    LOOP_CONTRACT,
    PROPERTY_FAMILIES,
    RELATIONAL,
    STANDARD,
    get_property_family,
    property_family_ids,
    resolve_strategy,
    strategy_ids,
    validate_catalogue,
)
from agents.common.run_layout import RunLayout
from agents.common.property_campaign import (
    validate_candidate_properties_for_campaign,
    validate_artifact_plan_for_campaign,
    validate_repair_plan_for_campaign,
)
from agents.common.schemas import ARTIFACT_PLAN_SCHEMA, REPAIR_PLAN_SCHEMA
from agents.tool_execution_agent import execute_tool_pipeline
from agents.repair_agent import RepairRefinementConfig, render_candidate_repair_outputs

BASELINE_SHA256 = "17cbc5bb9d30c960513bde4688ae18146a731b9aa43b5bb7c6df308302bffdf6"


def check(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def write_executable(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8")
    path.chmod(path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def clause(clause_id: str, kind: str, expression: str, description: str = "fixture clause") -> dict:
    return {
        "clause_id": clause_id,
        "clause_kind": kind,
        "description": description,
        "executable_expression": expression,
        "bound_symbols": [],
        "evidence_references": [],
        "expected_property_identity": f"TRACE_CLAIM::P12_LOOP::{clause_id}",
    }


def semantic_property() -> dict:
    record = {
        "schema_version": "semantic_property.v2",
        "property_id": "P12_LOOP",
        "statement": "The selected loop preserves its index and processed-prefix obligations.",
        "target_call": {"function": "poly_add", "arguments": [], "call_count": 1},
        "pre_state_objects": ["r"],
        "post_state_objects": ["r"],
        "observed_memory": ["r"],
        "permitted_writes": ["r"],
        "required_assumptions": [],
        "success_predicate": "0 <= i && i <= 4",
        "quantified_domain": {"variable": "i", "lower_bound": "0", "upper_bound_exclusive": "4"},
        "requires_pre_state_snapshot": False,
        "requires_modular_call_replacement": False,
        "requires_loop_reasoning": True,
        "requires_relational_execution": False,
        "analysis_only": False,
        "evidence_references": [],
        "uncertainty": "Candidate requires tool and human review.",
    }
    from agents.common.semantic_property import semantic_completeness
    record["semantic_completeness"] = semantic_completeness(record)
    return record


def disabled_contract_plan() -> dict:
    return {
        "enabled": False,
        "contract_mode": "none",
        "target_symbol": "",
        "function_declaration": "",
        "requires_clauses": [],
        "ensures_clauses": [],
        "assigns_clauses": [],
        "frees_clauses": [],
        "loop_invariant_clauses": [],
        "decreases_clauses": [],
        "loop_assigns_clauses": [],
        "loop_frees_clauses": [],
        "source_patch_operations": [],
        "apply_loop_contracts": False,
        "enforce_contract": False,
        "replace_calls_with_contract": [],
        "use_dfcc": False,
        "invariant_initialization_argument": "",
        "invariant_preservation_argument": "",
        "postcondition_use_argument": "",
        "frame_condition_argument": "",
        "history_variable_usage": [],
    }


def disabled_relational_plan() -> dict:
    return {
        "enabled": False,
        "relation_kind": "none",
        "first_call": "",
        "second_call": "",
        "state_reset_or_snapshot": [],
        "relation_assertions": [],
        "normalization_assumptions": [],
    }


def disabled_analysis_plan() -> dict:
    return {
        "enabled": False,
        "analysis_kind": "none",
        "evidence_to_collect": [],
        "external_tools_or_tests": [],
        "formal_claim_prohibited": True,
    }


def loop_contract_plan(source: Path) -> dict:
    return {
        "enabled": True,
        "contract_mode": "loop",
        "target_symbol": "poly_add",
        "function_declaration": "",
        "requires_clauses": [],
        "ensures_clauses": [],
        "assigns_clauses": [],
        "frees_clauses": [],
        "loop_invariant_clauses": [clause("C01", "loop_invariant", "0 <= i && i <= 4")],
        "decreases_clauses": [clause("D01", "decreases", "4 - i")],
        "loop_assigns_clauses": [clause("A01", "loop_assigns", "__CPROVER_object_upto(r, sizeof(r))")],
        "loop_frees_clauses": [],
        "source_patch_operations": [{
            "patch_id": "loop_1",
            "operation_kind": "insert_loop_contract_after_guard",
            "target_source_path": str(source),
            "purpose": "Annotate the selected finite coefficient loop in a copied source file.",
            "expected_original": "  for (int i = 0; i < 4; ++i)",
            "replacement": "",
            "expected_occurrences": 1,
            "requires_human_review": True,
        }],
        "apply_loop_contracts": True,
        "enforce_contract": False,
        "replace_calls_with_contract": [],
        "use_dfcc": False,
        "invariant_initialization_argument": "i starts at zero, so the range invariant holds.",
        "invariant_preservation_argument": "The loop increments i by one while i < 4.",
        "postcondition_use_argument": "Loop exit plus i <= 4 implies i == 4.",
        "frame_condition_argument": "Only r[0:4] is assigned by the loop.",
        "history_variable_usage": ["No history variable is required for this smoke candidate."],
    }


def function_contract_plan() -> dict:
    return {
        "enabled": True,
        "contract_mode": "function",
        "target_symbol": "barrett_reduce",
        "function_declaration": "int barrett_reduce(int a)",
        "requires_clauses": [clause("R01", "requires", "-10000 <= a && a <= 10000")],
        "ensures_clauses": [clause("E01", "ensures", "-3329 <= __CPROVER_return_value && __CPROVER_return_value <= 3329")],
        "assigns_clauses": [],
        "frees_clauses": [],
        "loop_invariant_clauses": [],
        "decreases_clauses": [],
        "loop_assigns_clauses": [],
        "loop_frees_clauses": [],
        "source_patch_operations": [],
        "apply_loop_contracts": False,
        "enforce_contract": True,
        "replace_calls_with_contract": [],
        "use_dfcc": True,
        "invariant_initialization_argument": "not_applicable",
        "invariant_preservation_argument": "not_applicable",
        "postcondition_use_argument": "The candidate postcondition states the implementation-specific range obligation.",
        "frame_condition_argument": "Pure scalar return; no assigns target required.",
        "history_variable_usage": ["__CPROVER_return_value is used in the ensures clause."],
    }


def base_artifact_plan(strategy: str, contract: dict | None = None) -> dict:
    return {
        "stage": "05_artifact_generation",
        "mock": False,
        "llm_call_executed": True,
        "target_function": "poly_add",
        "selected_property": {
            "selected": True,
            "selection_method": "configured_property_campaign",
            "property": {
                "property_id": "P12_LOOP",
                "property_family_id": "P12",
                "title": "Candidate loop invariant",
                "category": "loop_contract",
                "verification_strategy": strategy,
                "proof_obligation_kind": "loop_contract",
                "support_classification": "production_supported",
                "required_tool_capabilities": ["goto-cc", "goto-instrument", "cbmc"],
                "candidate_statement": "The selected loop preserves its index and processed-prefix obligations.",
                "supporting_evidence": [],
                "required_assumptions": [],
                "cbmc_feasibility": "medium",
                "risk_level": "medium",
                "expected_artifact_type": "native_cbmc_loop_contract",
                "out_of_scope_boundaries": ["No whole-scheme correctness claim."],
                "uncertainty": "Candidate requires tool and human review.",
                "limitations": ["Selected loop only."],
                "semantic_property": semantic_property(),
            },
        },
        "semantic_property": semantic_property(),
        "artefact_kind": "candidate_cbmc_artifact",
        "verification_strategy": strategy,
        "strategy_selection": {
            "requested_strategy": strategy,
            "selected_strategy": strategy,
            "selection_authority": "explicit_test_fixture",
            "selection_reason": "Fixture explicitly selects the tested route.",
            "family_recommendation_considered": strategy,
            "family_recommendation_was_authoritative": False,
            "llm_feasibility_was_authoritative": False,
        },
        "encoding_candidates": [{
            "strategy": strategy, "expressible": True, "required": True,
            "reason": "Fixture encoding", "authority": "explicit_test_fixture"
        }],
        "intended_check": "Check the selected local property only.",
        "non_goals": ["No full ML-KEM proof."],
        "required_includes": ["assert.h"],
        "required_types_and_macros": [],
        "assumption_plan": [],
        "assertion_plan": [],
        "old_state_snapshot_plan": {"required": "no", "reason": "not needed", "snapshot_items": []},
        "contract_plan": deepcopy(contract or disabled_contract_plan()),
        "relational_plan": disabled_relational_plan(),
        "analysis_only_plan": disabled_analysis_plan(),
        "traceability_manifest": {
            "selected_property_id": "P12_LOOP",
            "target_call_marker": "TRACE_TARGET_CALL::P12_LOOP",
            "target_call_identity": "TRACE_TARGET_CALL::P12_LOOP",
            "target_call_expression": "poly_add()",
            "expected_claim_count": 1,
            "assumption_map": [],
            "claim_map": [{
                "assertion_id": "C01",
                "implementation_kind": "loop_invariant",
                "code_marker": "TRACE_CLAIM::P12_LOOP::C01",
                "expected_property_identity": "TRACE_CLAIM::P12_LOOP::C01",
                "expression_sha256": "fixture-expression-sha256",
                "rationale": "Fixture maps its selected local contract claim."
            }],
            "non_vacuity_strategy": ["Mutate the loop body and require the mapped claim to fail."],
        },
        "generated_harness_code": "void poly_add(void);\nvoid harness(void) { /* TRACE_TARGET_CALL::P12_LOOP */ poly_add(); }\n",
        "validation_expectations": [],
        "independence_statement": {
            "existing_artefacts_consulted": [],
            "deterministic_hints_consulted": [],
            "unavoidable_similarities": ["target symbol"],
            "intentional_differences": ["independently structured candidate"],
            "copying_risk": "low_candidate",
            "requires_human_similarity_review": True,
        },
        "deterministic_reference_assessment": {
            "used": True,
            "status": "independently_checked",
            "warning": "advisory_only",
            "disagreements": [],
        },
        "evidence_references": [],
        "limitations": ["Candidate only."],
    }


def repair_plan_with_contract(contract: dict) -> dict:
    return {
        "stage": "09_repair_refinement",
        "mock": False,
        "llm_call_executed": True,
        "repair_decision": {
            "decision": "revise_contract_candidate",
            "based_on_result_classification": "contract_build_or_instrumentation_failed",
            "deterministic_triage_decision": "repair_contract",
        },
        "repair_scope": {
            "allowed": ["candidate contract plan", "copied source annotation"],
            "source_code_repair_allowed": False,
            "apply_repair_requested": False,
            "note": "Re-review required.",
        },
        "proposed_repairs": [],
        "assumption_changes": [],
        "assertion_changes": [],
        "harness_changes": [],
        "contract_changes": [],
        "command_or_environment_changes": [],
        "source_code_changes": [],
        "evidence_strength_impact": {"status": "preserved_candidate", "evidence_strength_lost_if_any": "none identified"},
        "safety_review": {"status": "requires_agent6_review", "blocks_silent_application": True},
        "rerun_recommendation": {"recommend_rerun": True, "reason": "Review revised contract first.", "next_stage": "06_review_critic"},
        "candidate_repaired_harness_code": "",
        "candidate_repaired_semantic_property": semantic_property(),
        "candidate_repaired_strategy_selection": {
            "requested_strategy": "native_loop_contract",
            "selected_strategy": "native_loop_contract",
            "selection_authority": "explicit_test_fixture",
            "selection_reason": "Fixture preserves route.",
            "family_recommendation_considered": "native_loop_contract",
            "family_recommendation_was_authoritative": False,
            "llm_feasibility_was_authoritative": False,
        },
        "semantic_property_change_acknowledgement": {
            "semantic_property_changed": False,
            "potential_weakening": False,
            "user_authorized_weakening": False,
            "authorization_reference": "",
            "reason": "Fixture preserves the selected semantic claim.",
        },
        "candidate_repaired_traceability_manifest": {
            "selected_property_id": "P12_LOOP",
            "target_call_marker": "TRACE_TARGET_CALL::P12_LOOP",
            "target_call_identity": "TRACE_TARGET_CALL::P12_LOOP",
            "target_call_expression": "poly_add()",
            "expected_claim_count": 1,
            "assumption_map": [],
            "claim_map": [{
                "assertion_id": "C01",
                "implementation_kind": "loop_invariant",
                "code_marker": "TRACE_CLAIM::P12_LOOP::C01",
                "expected_property_identity": "TRACE_CLAIM::P12_LOOP::C01",
                "expression_sha256": "fixture-expression-sha256",
                "rationale": "Repaired fixture preserves claim mapping."
            }],
            "non_vacuity_strategy": ["Mutate the loop body and require failure."],
        },
        "candidate_repaired_contract_plan": deepcopy(contract),
        "candidate_repaired_relational_plan": disabled_relational_plan(),
        "candidate_repaired_analysis_only_plan": disabled_analysis_plan(),
        "deterministic_reference_assessment": {"used": True, "status": "independently_checked", "warning": "advisory_only", "disagreements": []},
        "evidence_references": [],
        "limitations": ["Candidate contract repair; not proof."],
    }


def make_project(tmp: Path) -> tuple[Path, Path, Path]:
    spec = tmp / "fips.txt"
    source = tmp / "poly.c"
    header = tmp / "poly.h"
    spec.write_text("Controlled FIPS evidence for a test fixture.\n", encoding="utf-8")
    header.write_text("void poly_add(void);\n", encoding="utf-8")
    source.write_text(
        "#include \"poly.h\"\n"
        "int r[4];\n"
        "void poly_add(void) {\n"
        "  for (int i = 0; i < 4; ++i)\n"
        "  { r[i] = i; }\n"
        "}\n",
        encoding="utf-8",
    )
    return spec, source, header


def make_config(tmp: Path, spec: Path, source: Path, header: Path, family: str, strategy: str = "auto") -> dict:
    raw = {
        "run_id": f"test_{family.lower()}",
        "output_root": str(tmp / "runs"),
        "target_scheme": "ML-KEM",
        "target_function": "poly_add",
        "target_topic": "property campaign test",
        "verification_tool": "CBMC",
        "artifact_type": "candidate formal artefact",
        "max_iterations": 0,
        "inputs": {
            "spec_paths": [str(spec)],
            "code_paths": [str(source), str(header)],
            "code_dir": str(tmp),
        },
        "property_campaign": {
            "property_family_id": family,
            "verification_strategy": strategy,
            "allow_analysis_only": family == "P19",
        },
        "llm": {"mode": "mock", "model": "mock", "api_key_env": "OPENAI_API_KEY"},
        "tool_execution": {
            "cbmc_binary": "cbmc",
            "goto_cc_binary": "goto-cc",
            "goto_instrument_binary": "goto-instrument",
            "cbmc_function": "harness",
            "dry_run": True,
            "force_run": False,
            "require_gate_approval": True,
            "source_files": [str(source)],
            "stub_files": [],
            "include_paths": [str(tmp)],
            "defines": [],
            "working_directory": str(tmp),
            "extra_cbmc_args": [],
            "extra_goto_cc_args": ["--verbosity", "4"],
            "extra_goto_instrument_args": ["--verbosity", "4"],
            "unwind": 5,
        },
    }
    return normalize_config(raw, project_root=tmp)


def main() -> int:
    print("[1/10] Baseline provenance and complete property catalogue...")
    check(len(BASELINE_SHA256) == 64, "Baseline hash malformed")
    check(property_family_ids() == [f"P{i:02d}" for i in range(1, 27)], "Property IDs are not exactly P01..P26")
    check(len(PROPERTY_FAMILIES) == 26, "Catalogue must contain exactly 26 families")
    check(not validate_catalogue(), f"Catalogue validation failed: {validate_catalogue()}")
    check(set(strategy_ids()) == {STANDARD, FUNCTION_CONTRACT, LOOP_CONTRACT, RELATIONAL, ANALYSIS_ONLY, HYBRID}, "Strategy set mismatch")
    for row in PROPERTY_FAMILIES:
        check(row["default_strategy"] in row["allowed_strategies"], f"Invalid default for {row['id']}")
        check(bool(row["claim_boundary"]), f"Missing claim boundary for {row['id']}")
        check(bool(row["targets"]), f"Missing targets for {row['id']}")
    check(get_property_family("P19")["allowed_strategies"] == [ANALYSIS_ONLY], "P19 must remain analysis-only")
    print("  PASS 26 unique property families, strategies, and claim boundaries")

    with tempfile.TemporaryDirectory(prefix="property26_contract_test_") as td:
        tmp = Path(td)
        spec, source, header = make_project(tmp)

        print("[2/10] Canonical property-campaign configuration and backwards compatibility...")
        p12 = make_config(tmp, spec, source, header, "P12")
        check(p12["property_campaign"]["verification_strategy"] == LOOP_CONTRACT, "P12 auto strategy must be native loop contract")
        check(not validate_pipeline_config(p12).errors, validate_pipeline_config(p12).errors)
        p19 = make_config(tmp, spec, source, header, "P19")
        check(p19["property_campaign"]["verification_strategy"] == ANALYSIS_ONLY, "P19 auto strategy mismatch")
        check(not validate_pipeline_config(p19).errors, validate_pipeline_config(p19).errors)
        legacy = deepcopy(p12)
        legacy.pop("property_campaign", None)
        legacy = normalize_config(legacy, project_root=tmp)
        check(legacy["property_campaign"]["legacy_compatibility_default"] is True, "Legacy default not marked")
        check(legacy["property_campaign"]["verification_strategy"] == STANDARD, "Legacy config behavior changed")
        print("  PASS strategy routing, P19 guard, and legacy direct-CBMC behavior")

        print("[3/10] Strict schemas include complete contract-aware repair artefacts...")
        Draft202012Validator.check_schema(ARTIFACT_PLAN_SCHEMA)
        Draft202012Validator.check_schema(REPAIR_PLAN_SCHEMA)
        contract = loop_contract_plan(source)
        artifact = base_artifact_plan(LOOP_CONTRACT, contract)
        repair = repair_plan_with_contract(contract)
        check(not list(Draft202012Validator(ARTIFACT_PLAN_SCHEMA).iter_errors(artifact)), "Artifact fixture invalid")
        check(not list(Draft202012Validator(REPAIR_PLAN_SCHEMA).iter_errors(repair)), "Repair fixture invalid")
        print("  PASS strict artefact and repair schemas")

        print("[4/10] Native loop/function contract validation and fail-closed guards...")
        check(validate_contract_plan(contract, LOOP_CONTRACT)["valid"], validate_contract_plan(contract, LOOP_CONTRACT))
        fcontract = function_contract_plan()
        check(validate_contract_plan(fcontract, FUNCTION_CONTRACT)["valid"], validate_contract_plan(fcontract, FUNCTION_CONTRACT))
        header_text = build_contract_header(fcontract)
        check("__CPROVER_requires" in header_text and "__CPROVER_ensures" in header_text, "Function contract header incomplete")
        bad = deepcopy(contract); bad["loop_invariant_clauses"] = ["true"]
        check(not validate_contract_plan(bad, LOOP_CONTRACT)["valid"], "Trivial loop invariant was accepted")
        bad = deepcopy(contract); bad["loop_invariant_clauses"] = ["__CPROVER_old(i) <= 4"]
        check(not validate_contract_plan(bad, LOOP_CONTRACT)["valid"], "Invalid loop history operator accepted")
        bad = deepcopy(contract); bad["source_patch_operations"][0]["operation_kind"] = "exact_replacement"; bad["source_patch_operations"][0]["replacement"] = "while(1){}"
        check(not validate_contract_plan(bad, LOOP_CONTRACT)["valid"], "Unrestricted loop body rewrite accepted")
        print("  PASS useful-clause, history-variable, and controlled-patch checks")

        print("[5/10] Controlled source annotation never changes repository evidence...")
        original = source.read_bytes()
        rendered, manifest, diff = apply_contract_source_patches(
            contract,
            project_root=tmp,
            output_dir=tmp / "rendered_contract",
            allowed_source_paths=[source, header],
        )
        check(source.read_bytes() == original, "Original source was modified")
        check(len(rendered) == 1 and rendered[0].is_file(), "Instrumented source missing")
        instrumented_text = rendered[0].read_text(encoding="utf-8")
        check("__CPROVER_loop_invariant" in instrumented_text, "Invariant not inserted")
        check("__CPROVER_decreases" in instrumented_text, "Decreases clause not inserted")
        check(manifest["production_source_modified"] is False, "Manifest claims source modification")
        check("+++" in diff and "__CPROVER_loop_invariant" in diff, "Unified diff missing")

        inline_source = tmp / "poly_inline.c"
        inline_source.write_text(
            "int out[4];\nvoid inline_loop(void) {\n  for (int i = 0; i < 4; ++i) {\n    out[i] = i;\n  }\n}\n",
            encoding="utf-8",
        )
        inline_contract = deepcopy(contract)
        inline_contract["source_patch_operations"][0]["target_source_path"] = str(inline_source)
        inline_contract["source_patch_operations"][0]["expected_original"] = "  for (int i = 0; i < 4; ++i) {"
        inline_original = inline_source.read_bytes()
        inline_rendered, inline_manifest, _ = apply_contract_source_patches(
            inline_contract,
            project_root=tmp,
            output_dir=tmp / "rendered_inline_contract",
            allowed_source_paths=[inline_source],
        )
        inline_text = inline_rendered[0].read_text(encoding="utf-8")
        check(inline_source.read_bytes() == inline_original, "Same-line loop rendering modified original source")
        check("for (int i = 0; i < 4; ++i)\n  __CPROVER_assigns" in inline_text, inline_text)
        check("\n  {\n    out[i] = i;" in inline_text, "Same-line opening brace was not preserved safely")
        check(inline_manifest["production_source_modified"] is False, inline_manifest)
        outside = tmp.parent / "outside.c"; outside.write_text("void x(void){}\n", encoding="utf-8")
        escaped = deepcopy(contract); escaped["source_patch_operations"][0]["target_source_path"] = str(outside)
        try:
            apply_contract_source_patches(escaped, project_root=tmp, output_dir=tmp / "escaped", allowed_source_paths=[source])
        except PermissionError:
            pass
        else:
            raise AssertionError("Patch outside approved evidence was accepted")
        print("  PASS exact-anchor copy, diff/hash evidence, and path confinement")

        print("[6/10] Direct, relational, loop, function/DFCC, hybrid, and analysis execution profiles...")
        harness = tmp / "harness.c"; harness.write_text("void poly_add(void); void harness(void){ /* TRACE_TARGET_CALL::P12_LOOP */ poly_add(); }\n", encoding="utf-8")
        contract_manifest_path = tmp / "contract_manifest.json"
        contract_manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
        loop_manifest = {"contract_summary": {"contract_instrumentation_manifest": str(contract_manifest_path), "contract_header": None}}
        loop_build = create_formal_build_plan(p12, harness, target_function="poly_add", artifact_plan=artifact, artifact_manifest=loop_manifest)
        check(loop_build["validation"]["valid"], loop_build["validation"])
        loop_steps = build_tool_pipeline_from_plan(loop_build, output_dir=tmp / "loop_pipeline")
        check("--function" not in loop_steps[0]["command"], "goto-cc compile step must not receive CBMC entry-selection flags")
        check([s["step_id"] for s in loop_steps] == ["goto_compile", "apply_loop_contracts", "cbmc_contract_check"], loop_steps)
        check("--verbosity" in loop_steps[0]["command"], "extra_goto_cc_args missing from compile step")
        check("--verbosity" in loop_steps[1]["command"], "extra_goto_instrument_args missing from instrumentation step")

        p02 = make_config(tmp, spec, source, header, "P02")
        function_artifact = base_artifact_plan(FUNCTION_CONTRACT, fcontract)
        contract_header = tmp / "contract.h"; contract_header.write_text(header_text, encoding="utf-8")
        fmanifest = {"contract_summary": {"contract_instrumentation_manifest": None, "contract_header": str(contract_header)}}
        fbuild = create_formal_build_plan(p02, harness, target_function="barrett_reduce", artifact_plan=function_artifact, artifact_manifest=fmanifest)
        check(fbuild["validation"]["valid"], fbuild["validation"])
        fsteps = build_tool_pipeline_from_plan(fbuild, output_dir=tmp / "function_pipeline")
        check([s["step_id"] for s in fsteps] == ["goto_compile", "apply_function_contracts", "cbmc_contract_check"], fsteps)
        check("--dfcc" in fsteps[1]["command"] and "--enforce-contract" in fsteps[1]["command"], fsteps[1])

        p06 = make_config(tmp, spec, source, header, "P06")
        relational_artifact = base_artifact_plan(RELATIONAL)
        relational_artifact["relational_plan"] = {
            "enabled": True,
            "relation_kind": "round_trip",
            "first_call": "poly_tobytes",
            "second_call": "poly_frombytes",
            "state_reset_or_snapshot": ["snapshot normalized input"],
            "relation_assertions": ["decoded equals normalized input"],
            "normalization_assumptions": ["coefficients are canonical"],
        }
        rbuild = create_formal_build_plan(p06, harness, target_function="harness", artifact_plan=relational_artifact, artifact_manifest={})
        check(rbuild["execution_profile"]["mode"] == "direct_cbmc", rbuild)
        check(build_tool_pipeline_from_plan(rbuild, output_dir=tmp / "relational_pipeline")[0]["step_id"] == "cbmc_direct", "Relational profile must use direct CBMC harness")

        analysis_artifact = base_artifact_plan(ANALYSIS_ONLY)
        analysis_artifact["analysis_only_plan"] = {
            "enabled": True,
            "analysis_kind": "secret_dependent_control_flow",
            "evidence_to_collect": ["branch predicates", "memory-index expressions"],
            "external_tools_or_tests": ["manual classification"],
            "formal_claim_prohibited": True,
        }
        abuild = create_formal_build_plan(p19, harness, target_function="harness", artifact_plan=analysis_artifact, artifact_manifest={})
        check(abuild["execution_profile"]["mode"] == "analysis_only", abuild)
        check(build_tool_pipeline_from_plan(abuild, output_dir=tmp / "analysis_pipeline") == [], "Analysis-only produced a formal command")
        print("  PASS all six strategy profiles and command routing")

        print("[7/10] Multi-step GOTO execution preserves intermediate models and hashes...")
        tools = tmp / "tools"; tools.mkdir()
        goto_cc = tools / "goto-cc"
        goto_instrument = tools / "goto-instrument"
        cbmc = tools / "cbmc"
        write_executable(goto_cc, """#!/usr/bin/env python3
import pathlib,sys
args=sys.argv[1:]
out=pathlib.Path(args[args.index('-o')+1]); out.parent.mkdir(parents=True,exist_ok=True); out.write_text('compiled')
print('goto-cc ok')
""")
        write_executable(goto_instrument, """#!/usr/bin/env python3
import pathlib,sys
out=pathlib.Path(sys.argv[-1]); out.parent.mkdir(parents=True,exist_ok=True); out.write_text('instrumented')
print('goto-instrument ok')
""")
        write_executable(cbmc, """#!/usr/bin/env python3
print('VERIFICATION SUCCESSFUL')
""")
        executable_steps = build_tool_pipeline_from_plan(
            loop_build,
            output_dir=tmp / "executed_pipeline",
            goto_cc_binary=str(goto_cc),
            goto_instrument_binary=str(goto_instrument),
            cbmc_binary=str(cbmc),
        )
        result = execute_tool_pipeline(executable_steps, cwd=tmp, timeout_seconds=15, output_dir=tmp / "tool_logs")
        check(not result["pipeline_setup_failed"], result)
        check(result["all_planned_steps_completed"], result)
        check(result["authoritative"]["exit_code"] == 0, result)
        for record in result["steps"][:-1]:
            check(record["output_model_exists"], record)
            check(bool(record["output_model_sha256"]), record)
        print("  PASS sequential execution, output existence checks, and model hashing")

        print("[8/10] Contract-aware Agent 9 repair bundle remains review-gated...")
        run = tmp / "repair_run"
        layout = RunLayout(run, create=True, active_iteration=1)
        repair_cfg = RepairRefinementConfig(run_dir=run, target_function="poly_add", iteration=1)
        repair_outputs, safety = render_candidate_repair_outputs(
            layout=layout,
            cfg=repair_cfg,
            config_data=p12,
            repair_plan=repair,
            original_artifact_plan=artifact,
            original_harness_path=harness,
            original_harness_text=harness.read_text(encoding="utf-8"),
        )
        check("repaired_artifact_plan" in repair_outputs, repair_outputs)
        check("repaired_artifact_manifest" in repair_outputs, repair_outputs)
        check("repaired_independence_audit" in repair_outputs, repair_outputs)
        check("repaired_similarity_audit_details" in repair_outputs, repair_outputs)
        check("repaired_contract_instrumentation_manifest" in repair_outputs, repair_outputs)
        check(safety["requires_human_review"] is True, safety)
        check(safety["applied_to_original"] is False, safety)
        check(source.read_bytes() == original, "Contract repair modified original source")
        repaired_manifest = json.loads(repair_outputs["repaired_artifact_manifest"].read_text(encoding="utf-8"))
        repaired_audit_path = repair_outputs["repaired_independence_audit"]
        repaired_audit = json.loads(repaired_audit_path.read_text(encoding="utf-8"))
        check(repaired_audit["schema_version"].startswith("independence_audit.v2"), repaired_audit)
        check(str(repaired_audit_path) == repaired_manifest["artefacts"]["independence_audit"], repaired_manifest)
        check(sha256_file(repaired_audit_path) == repaired_manifest["checksums_sha256"]["independence_audit"], repaired_manifest)
        check(repaired_manifest["trust_boundary"]["independence_audit"] == "fresh_deterministic_similarity_screen_for_this_bundle", repaired_manifest)
        check(repaired_manifest["contract_summary"]["contract_enabled"] is True, repaired_manifest)
        check(repaired_manifest["repair_provenance"]["production_source_modified"] is False, repaired_manifest)
        print("  PASS complete repaired plan/manifest, controlled copies, and mandatory re-review")

        print("[9/10] Claim boundaries are explicit for all twenty-six families...")
        for family_id in property_family_ids():
            family = get_property_family(family_id)
            resolved = resolve_strategy(family, "auto")
            check(resolved == family["default_strategy"], f"Auto strategy mismatch for {family_id}")
            if family_id == "P19":
                check("no CBMC" in family["claim_boundary"] or "no CBMC" in family["claim_boundary"].replace("formal", "CBMC") or family["support_level"] == "analysis_only", "P19 boundary weak")
            else:
                boundary = family["claim_boundary"].strip().lower()
                check(len(boundary) >= 35, f"Claim boundary too short for {family_id}")
                check("proves full ml-kem" not in boundary and "guarantees cryptographic security" not in boundary, f"Claim boundary overclaims for {family_id}")
        print("  PASS no property family is represented as automatically or universally proved")

        print("[10/10] Semantic campaign gates fail closed for real mismatches and preserve mock wiring...")
        campaign = p12["property_campaign"]
        real_candidates = {
            "mock": False,
            "llm_call_executed": True,
            "candidate_properties": [artifact["selected_property"]["property"]],
        }
        check(validate_candidate_properties_for_campaign(real_candidates, campaign)["valid"], "Matching Agent 4 candidate rejected")
        wrong_candidates = deepcopy(real_candidates)
        wrong_candidates["candidate_properties"][0]["property_family_id"] = "P16"
        check(not validate_candidate_properties_for_campaign(wrong_candidates, campaign)["valid"], "Wrong Agent 4 family accepted")
        check(validate_artifact_plan_for_campaign(artifact, campaign)["valid"], "Matching Agent 5 plan rejected")
        wrong_artifact = deepcopy(artifact); wrong_artifact["verification_strategy"] = STANDARD
        check(not validate_artifact_plan_for_campaign(wrong_artifact, campaign)["valid"], "Wrong Agent 5 strategy accepted")
        mock_artifact = deepcopy(artifact)
        mock_artifact["mock"] = True; mock_artifact["llm_call_executed"] = False; mock_artifact["contract_plan"] = disabled_contract_plan()
        mock_validation = validate_artifact_plan_for_campaign(mock_artifact, campaign)
        check(mock_validation["valid"] and mock_validation["mock_wiring_only"], "Mock wiring plan was not conservatively accepted")
        check(not mock_validation["valid_for_real_experiment"], "Mock plan became real-experiment eligible")
        check(validate_repair_plan_for_campaign(repair, campaign)["valid"], "Matching Agent 9 repair rejected")
        wrong_repair = deepcopy(repair); wrong_repair["candidate_repaired_contract_plan"] = disabled_contract_plan()
        check(not validate_repair_plan_for_campaign(wrong_repair, campaign)["valid"], "Incomplete real contract repair accepted")
        print("  PASS Agent 4/5/9 semantic handoff compatibility and mock-vs-real boundary")

    print("\nPROPERTY-26 AND NATIVE-CONTRACT EXTENSION PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
