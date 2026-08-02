#!/usr/bin/env python3
"""Behavioral acceptance tests for the mandatory A-to-Z repair wave."""
from __future__ import annotations

import json
import os
import stat
import tempfile
import time
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.config_contract import normalize_config, validate_pipeline_config
from agents.common.experiment_protocol import semantic_advisory_enabled
from agents.common.llm_client import (
    IncompleteResponseError,
    LLMClient,
    LLMStageRequest,
    _response_to_text,
    redact_secrets,
    with_json_retry_instruction,
)
from agents.common.run_layout import RunLayout
from agents.common.semantic_gate import selected_property_coverage, validate_artifact_semantics
from agents.common.cbmc_evidence import classify_evidence, parse_cbmc_json_output
from agents.common.workflow_policy import critic_transition, tool_transition
from agents.tool_execution_agent import execute_tool_pipeline


def check(condition: bool, message: object) -> None:
    if not condition:
        raise AssertionError(message)


def executable(path: Path, text: str) -> Path:
    path.write_text(text, encoding="utf-8")
    path.chmod(path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    return path


def disabled_contract() -> dict:
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


def base_plan() -> dict:
    return {
        "stage": "05_artifact_generation",
        "mock": False,
        "llm_call_executed": True,
        "target_function": "mlk_poly_add",
        "selected_property": {
            "selected": True,
            "selection_method": "configured_property_campaign",
            "property": {
                "property_id": "P16_BOUNDS",
                "property_family_id": "P16",
                "title": "Array-bounds safety",
                "category": "memory_safety",
                "verification_strategy": "standard_cbmc_harness",
                "proof_obligation_kind": "array_bounds",
                "support_classification": "production_supported",
                "required_tool_capabilities": ["cbmc"],
                "candidate_statement": "Built-in bounds checks remain valid for the target call.",
                "supporting_evidence": [],
                "required_assumptions": ["Input objects are valid."],
                "cbmc_feasibility": "high",
                "risk_level": "medium",
                "expected_artifact_type": "standard_cbmc_harness",
                "out_of_scope_boundaries": ["No functional equality claim."],
                "uncertainty": "Candidate only.",
                "limitations": ["Selected local target only."],
            },
        },
        "artefact_kind": "candidate_cbmc_artifact",
        "verification_strategy": "standard_cbmc_harness",
        "intended_check": "Bounds and pointer safety only.",
        "non_goals": ["No functional equality claim."],
        "required_includes": [],
        "required_types_and_macros": [],
        "assumption_plan": [{
            "assumption_id": "A01",
            "assumption": "Input objects are valid.",
            "justification": "Required by target API.",
            "risk_of_overconstraint": "Must be reviewed.",
            "evidence_references": [],
        }],
        "assertion_plan": [],
        "old_state_snapshot_plan": {"required": "no", "reason": "bounds only", "snapshot_items": []},
        "contract_plan": disabled_contract(),
        "relational_plan": {"enabled": False, "relation_kind": "none", "first_call": "", "second_call": "", "state_reset_or_snapshot": [], "relation_assertions": [], "normalization_assumptions": []},
        "analysis_only_plan": {"enabled": False, "analysis_kind": "none", "evidence_to_collect": [], "external_tools_or_tests": [], "formal_claim_prohibited": True},
        "traceability_manifest": {
            "selected_property_id": "P16_BOUNDS",
            "target_call_marker": "TRACE_TARGET_CALL:C01",
            "expected_claim_count": 1,
            "assumption_map": [{
                "assumption_id": "A01",
                "implementation_kind": "harness_assume",
                "code_marker": "TRACE_ASSUMPTION:A01",
                "code_locator": "harness",
                "rationale": "Valid object model prerequisite.",
            }],
            "claim_map": [{
                "assertion_id": "C01",
                "implementation_kind": "cbmc_builtin",
                "code_marker": "",
                "cbmc_property_patterns": ["bounds", "pointer"],
                "rationale": "CBMC built-in checks implement the selected safety claim.",
            }],
            "non_vacuity_strategy": ["Mutate the target access and require a mapped bounds property failure."],
        },
    }


def main() -> int:
    print("[1/12] Canonical protocol is mandatory and LLM-first...")
    for path in sorted((ROOT / "configs").glob("CONFIG_TEMPLATE*.json")):
        raw = json.loads(path.read_text(encoding="utf-8"))
        campaign = raw.setdefault("property_campaign", {})
        if str(campaign.get("property_family_id") or "").startswith("SET_TO_"):
            campaign["property_family_id"] = "P16"
        if campaign.get("verification_strategy") == "auto":
            campaign["verification_strategy"] = "standard_cbmc_harness"
        raw.setdefault("provenance", {})["source_revision"] = "test-revision"
        raw.pop("llm_profile", None)
        raw.pop("llm_overrides", None)
        raw["llm"] = {"mode": "mock", "model": "mock-model", "provider": "openai", "api_key_env": "OPENAI_API_KEY", "store": False}
        normalized = normalize_config(raw, config_path=path, project_root=ROOT)
        check(normalized["max_iterations"] == 0, path)
        check(normalized["experiment_protocol"]["semantic_advisory_mode"] == "off", path)
        check(not semantic_advisory_enabled(normalized), path)
        check(normalized["tool_execution"]["structured_json_required"] is True, path)
        report = validate_pipeline_config(normalized, check_input_files=False)
        check(report.valid, {path.name: report.errors})
    print("  PASS templates, preflight policy, and normalized protocol agree")

    print("[2/12] semantic_advisory_mode=off prevents advisory transmission...")
    import agents.common.llm_client as llm_mod

    calls: list[dict] = []

    class FakeResponse:
        status = "completed"
        incomplete_details = None
        output_text = '{"stage":"02_spec_extraction"}'
        id = "fake_response"
        usage = {"input_tokens": 17, "output_tokens": 4, "total_tokens": 21}

        def model_dump(self):
            return {"status": self.status, "output_text": self.output_text, "usage": self.usage}

    class FakeResponses:
        def create(self, **kwargs):
            calls.append(kwargs)
            return FakeResponse()

    class FakeOpenAI:
        def __init__(self, **kwargs):
            self.responses = FakeResponses()

    previous_openai = llm_mod.OpenAI
    previous_key = os.environ.get("OPENAI_API_KEY")
    llm_mod.OpenAI = FakeOpenAI
    os.environ["OPENAI_API_KEY"] = "sk-test-secret-1234567890"
    try:
        with tempfile.TemporaryDirectory(prefix="advisory_off_") as td:
            run = Path(td) / "run"
            layout = RunLayout(run, create=True)
            evidence = Path(td) / "evidence.txt"
            evidence.write_text("primary evidence", encoding="utf-8")
            client = LLMClient({
                "mode": "real",
                "model": "fake-model",
                "api_key_env": "OPENAI_API_KEY",
                "max_retries": 0,
                "retry_sleep_seconds": 0,
                "semantic_advisory_mode": "off",
                "max_request_bytes": 100000,
                "max_stage_input_tokens_estimate": 25000,
                "max_total_input_tokens_estimate": 25000,
            })
            request = LLMStageRequest(
                stage="02_spec_extraction",
                prompt_text="Return JSON.",
                output_filename="02_spec_summary.json",
                json_schema={
                    "type": "object",
                    "properties": {"stage": {"type": "string"}},
                    "required": ["stage"],
                    "additionalProperties": False,
                },
                primary_evidence_files=[evidence],
                deterministic_reference_bundle={"forbidden_marker": "DETERMINISTIC_SEMANTIC_ADVICE_ABC"},
            )
            result = client.run_stage(layout, request)
            check(result.success, result.to_dict())
            payload = json.dumps(calls[-1], ensure_ascii=False)
            check("DETERMINISTIC_SEMANTIC_ADVICE_ABC" not in payload, payload)
            snapshot = json.loads((layout.prompt_package_dir("02_spec_extraction") / "api_requests" / "attempt_01_request.json").read_text())
            check(snapshot["evidence_categories"]["deterministic_advisory_bundle_present"] is False, snapshot)
    finally:
        llm_mod.OpenAI = previous_openai
        if previous_key is None:
            os.environ.pop("OPENAI_API_KEY", None)
        else:
            os.environ["OPENAI_API_KEY"] = previous_key
    print("  PASS deterministic semantic advice is absent from exact API input")

    print("[3/12] Incomplete provider responses are typed before JSON parsing...")
    class Incomplete:
        status = "incomplete"
        incomplete_details = {"reason": "max_output_tokens"}
        output_text = ""

        def model_dump(self):
            return {"status": self.status, "incomplete_details": self.incomplete_details, "output": [{"type": "reasoning"}]}

    try:
        _response_to_text(Incomplete())
        raise AssertionError("Incomplete response was not rejected")
    except IncompleteResponseError as exc:
        check(exc.reason == "max_output_tokens", exc)
    print("  PASS no provider envelope is reinterpreted as stage JSON")

    print("[4/12] Retry prompts stay compact and usage metrics survive redaction...")
    original = "X" * 10000
    huge_schema = {"type": "object", "properties": {f"field_{i}": {"type": "string"} for i in range(1000)}, "required": ["field_0"]}
    retried = with_json_retry_instruction(original, huge_schema, "bad\n" + "E" * 10000)
    check(len(retried.encode()) <= int(len(original.encode()) * 1.10), len(retried))
    check(json.dumps(huge_schema) not in retried, "Full schema was duplicated into retry")
    redacted = redact_secrets({
        "api_key": "sk-secret-1234567890",
        "authorization": "Bearer abcdefghijklmnop",
        "input_tokens": 101,
        "output_tokens": 22,
        "total_tokens": 123,
    })
    check(redacted["api_key"] == "[REDACTED]", redacted)
    check(redacted["authorization"] == "[REDACTED]", redacted)
    check(redacted["input_tokens"] == 101 and redacted["total_tokens"] == 123, redacted)
    print("  PASS compact retry and evidence-preserving secret redaction")

    print("[5/12] Historical weak harness is blocked with stable issue IDs...")
    plan = base_plan()
    weak_harness = """
void mlk_poly_add(void *r, const void *a, const void *b);
void harness(void) {
  int i;
  void *r = 0, *a = 0, *b = 0;
  /* TRACE_ASSUMPTION:A01 */
  for (i = 0; i < 256; ++i) {
    __CPROVER_assert(i < 256, "coefficient index within bounds");
  }
  __CPROVER_assert(i == i, "functional equality drift");
  /* TRACE_TARGET_CALL:C01 */ mlk_poly_add(r, a, b);
}
"""
    semantic = validate_artifact_semantics(plan, weak_harness, target_function="mlk_poly_add", property_campaign={"verification_strategy": "standard_cbmc_harness"})
    ids = {item["issue_id"] for item in semantic["blocking_issues"]}
    check("loop_guard_tautology" in ids, ids)
    check("missing_required_assumption" in ids, ids)
    check("selected_property_scope_drift" in ids, ids)
    check("trivial_assertion" in ids, ids)
    check("missing_selected_property_claim" in ids, ids)
    print("  PASS tautology, missing assumption, scope drift, and vacuity are hard blockers")

    print("[6/12] Canonical state transitions preserve human-review and repair policy...")
    check(critic_transition("human_review_required", iteration=0, max_iterations=1).action == "stop_for_human_review", "human review")
    check(critic_transition("needs_revision_before_tool_execution", iteration=0, max_iterations=1).action == "repair_then_rereview", "repair")
    check(critic_transition("needs_revision_before_tool_execution", iteration=1, max_iterations=1).action == "stop_iteration_limit", "limit")
    check(critic_transition("approved_for_tool_execution", iteration=0, max_iterations=0).action == "execute_tool", "execute")
    failed_status = {"result_classification": "verification_failed_or_unknown", "emitted_failure_count": 1, "emitted_unknown_count": 0}
    unknown_status = {"result_classification": "verification_failed_or_unknown", "emitted_failure_count": 0, "emitted_unknown_count": 1}
    check(tool_transition(result_classification=failed_status, selected_property_verified=False, iteration=0, max_iterations=1).action == "repair_from_tool_evidence", "post tool repair")
    check(tool_transition(result_classification=failed_status, selected_property_verified=False, iteration=1, max_iterations=1).action == "stop_iteration_limit", "post tool stop")
    check(tool_transition(result_classification=unknown_status, selected_property_verified=False, iteration=0, max_iterations=1).action == "stop_model_or_evidence_investigation", "post tool unknown investigation")
    print("  PASS state machine matches the controlled experimental policy")

    print("[7/12] Structured CBMC output and selected-property coverage are separate...")
    exact_claim_identity = "TRACE_CLAIM::P16_BOUNDS::C01"
    plan["traceability_manifest"]["claim_map"][0]["expected_property_identity"] = exact_claim_identity
    cbmc_json = json.dumps([{
        "result": [
            {"property": exact_claim_identity, "status": "SUCCESS", "description": "array bounds"},
            {"property": "harness.pointer.1", "status": "SUCCESS", "description": "pointer check"},
        ]
    }])
    parsed = parse_cbmc_json_output(cbmc_json)
    coverage = selected_property_coverage(plan["traceability_manifest"], parsed["property_results"])
    classification = classify_evidence(
        executed=True, exit_code=0, timeout=False, skipped=False, dry_run=False,
        unavailable=False, analysis_only=False, pipeline_setup_failed=False,
        structured=parsed, coverage=coverage,
    )
    check(parsed["json_valid"] and parsed["property_result_count"] == 2, parsed)
    check(coverage["coverage_complete"], coverage)
    check(classification["selected_property_verified_under_model"], classification)
    print("  PASS tool execution, emitted-property success, coverage, and scientific status remain distinct")

    print("[8/12] Zero-property success cannot become scientific verification...")
    empty = parse_cbmc_json_output("[]")
    empty_cov = selected_property_coverage(plan["traceability_manifest"], empty["property_results"])
    empty_class = classify_evidence(
        executed=True, exit_code=0, timeout=False, skipped=False, dry_run=False,
        unavailable=False, analysis_only=False, pipeline_setup_failed=False,
        structured=empty, coverage=empty_cov,
    )
    check(empty_class["result_classification"] == "tool_success_no_emitted_property_evidence", empty_class)
    check(not empty_class["selected_property_verified_under_model"], empty_class)
    print("  PASS non-zero mapped claim evidence is mandatory")

    print("[9/12] Fake-CBMC mutation sensitivity produces a failing mapped claim...")
    with tempfile.TemporaryDirectory(prefix="fake_cbmc_") as td:
        tmp = Path(td)
        fake = executable(tmp / "cbmc", """#!/usr/bin/env python3
import json,sys
mode = 'mutated' if 'mutated' in sys.argv else 'safe'
status = 'FAILURE' if mode == 'mutated' else 'SUCCESS'
print(json.dumps([{'result':[{'property':'harness.bounds.1','status':status,'description':'array bounds'}]}]))
""")
        safe_result = execute_tool_pipeline([
            {"step_id": "cbmc", "tool": "cbmc", "command": [str(fake), "safe"], "authoritative_result_step": True}
        ], cwd=tmp, output_dir=tmp / "safe_logs", step_timeout_seconds=5, pipeline_timeout_seconds=5)
        mut_result = execute_tool_pipeline([
            {"step_id": "cbmc", "tool": "cbmc", "command": [str(fake), "mutated"], "authoritative_result_step": True}
        ], cwd=tmp, output_dir=tmp / "mut_logs", step_timeout_seconds=5, pipeline_timeout_seconds=5)
        safe_parsed = parse_cbmc_json_output(safe_result["authoritative"]["stdout"])
        mut_parsed = parse_cbmc_json_output(mut_result["authoritative"]["stdout"])
        check(safe_parsed["success_count"] == 1, safe_parsed)
        check(mut_parsed["failure_count"] == 1, mut_parsed)
    print("  PASS mutation changes the formal-tool evidence instead of remaining vacuously green")

    print("[10/12] Overall pipeline timeout caps sequential formal-tool steps...")
    with tempfile.TemporaryDirectory(prefix="pipeline_timeout_") as td:
        tmp = Path(td)
        sleeper = executable(tmp / "sleeper", """#!/usr/bin/env python3
import time
time.sleep(0.8)
print('[]')
""")
        steps = [
            {"step_id": f"s{i}", "tool": "fake", "command": [str(sleeper)], "authoritative_result_step": i == 3}
            for i in range(1, 4)
        ]
        started = time.monotonic()
        result = execute_tool_pipeline(steps, cwd=tmp, output_dir=tmp / "logs", step_timeout_seconds=1, pipeline_timeout_seconds=1)
        elapsed = time.monotonic() - started
        check(result["timeout"], result)
        check(elapsed < 2.0, elapsed)
        check(result["completed_step_count"] < 3, result)
    print("  PASS total deadline prevents per-step timeout multiplication")

    print("[11/12] Protocol hash is embedded in run, stage, and handoff records...")
    with tempfile.TemporaryDirectory(prefix="protocol_hash_") as td:
        run = Path(td) / "runs" / "r1"
        layout = RunLayout(run, create=True)
        protocol = {
            "protocol_version": "llm-first-v1",
            "semantic_advisory_mode": "off",
            "protocol_sha256": "abc123",
        }
        (run / "run_config.resolved.json").write_text(json.dumps({"experiment_protocol": protocol}), encoding="utf-8")
        evidence = run / "evidence.txt"
        evidence.write_text("evidence", encoding="utf-8")
        manifest = layout.write_stage_manifest("02_spec_extraction", primary_evidence_inputs=[evidence])
        handoff = layout.write_handoff_manifest("02_spec_extraction", outputs={"x": evidence}, authoritative_source="test", next_stage_consumers=[])
        manifest_obj = json.loads(manifest.read_text())
        handoff_obj = json.loads(handoff.read_text())
        check(manifest_obj["experiment_protocol_sha256"] == "abc123", manifest_obj)
        check(handoff_obj["experiment_protocol_sha256"] == "abc123", handoff_obj)
        # Final deterministic reports must retain the same immutable identity.
        from agents.master_orchestrator import MasterOrchestrator
        orchestrator = MasterOrchestrator.__new__(MasterOrchestrator)
        orchestrator.layout = layout
        orchestrator.run_id = "r1"
        orchestrator.final_status = "passed_selected_properties"
        orchestrator.target_scheme = "ML-KEM"
        orchestrator.target_function = "mlk_poly_add"
        orchestrator.config = {"verification_tool": "CBMC", "artifact_type": "harness"}
        orchestrator.max_iterations = 0
        orchestrator.current_iteration = 0
        orchestrator.plan_path = run / "workflow_plan.json"
        orchestrator.status_path = run / "status.json"
        orchestrator.event_log_path = run / "events.jsonl"
        orchestrator.agent_results = []
        orchestrator.final_summary_path = run / "final" / "final_run_summary.json"
        orchestrator.write_final_summary(final_status="passed_selected_properties", verification_passed=True, stopped_reason="fixture")
        final_obj = json.loads(orchestrator.final_summary_path.read_text())
        check(final_obj["experiment_protocol_sha256"] == "abc123", final_obj)
    print("  PASS immutable protocol identity follows every stage handoff and final report")

    print("[12/12] Fake LLM -> semantic gate -> fake CBMC path works end to end...")
    import agents.common.llm_client as llm_mod_e2e
    e2e_plan = base_plan()
    property_id = "P16_BOUNDS"
    target_identity = f"TRACE_TARGET_CALL::{property_id}"
    assumption_identity = f"TRACE_ASSUMPTION::{property_id}::A01"
    claim_identity = f"TRACE_CLAIM::{property_id}::C01"
    e2e_plan["semantic_property"] = {
        "schema_version": "semantic_property.v2",
        "property_id": property_id,
        "statement": "The configured CBMC bounds checks for the selected target call succeed.",
        "target_call": {
            "function": "mlk_poly_add",
            "arguments": ["r", "a", "b"],
            "call_count": 1,
        },
        "pre_state_objects": [],
        "post_state_objects": [],
        "observed_memory": ["r", "a", "b"],
        "permitted_writes": [],
        "required_assumptions": ["Input objects are valid."],
        "success_predicate": "all configured CBMC bounds checks for the selected target call succeed",
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
        "uncertainty": "The exact generated CBMC property identity remains decisive.",
    }
    trace = e2e_plan["traceability_manifest"]
    trace["target_call_identity"] = target_identity
    trace["target_call_marker"] = target_identity
    trace["assumption_map"][0]["code_marker"] = assumption_identity
    trace["claim_map"][0]["expected_property_identity"] = claim_identity
    trace["claim_map"][0]["code_marker"] = claim_identity
    trace["claim_map"][0].pop("cbmc_property_patterns", None)
    e2e_harness = f"""
void mlk_poly_add(void *r, const void *a, const void *b);
void harness(void) {{
  int r_obj = 0, a_obj = 0, b_obj = 0;
  void *r = &r_obj; const void *a = &a_obj; const void *b = &b_obj;
  /* {assumption_identity} */ __CPROVER_assume(r != 0 && a != 0 && b != 0);
  /* {target_identity} */ mlk_poly_add(r, a, b);
}}
"""
    e2e_output = {"artifact_plan": e2e_plan, "harness": e2e_harness}
    e2e_calls: list[dict] = []

    class E2EResponse:
        status = "completed"
        incomplete_details = None
        output_text = json.dumps(e2e_output)
        id = "fake_e2e_response"
        usage = {"input_tokens": 50, "output_tokens": 50, "total_tokens": 100}
        def model_dump(self):
            return {"status": self.status, "output_text": self.output_text, "usage": self.usage}

    class E2EResponses:
        def create(self, **kwargs):
            e2e_calls.append(kwargs)
            return E2EResponse()

    class E2EOpenAI:
        def __init__(self, **kwargs):
            self.responses = E2EResponses()

    previous_openai = llm_mod_e2e.OpenAI
    previous_key = os.environ.get("OPENAI_API_KEY")
    llm_mod_e2e.OpenAI = E2EOpenAI
    os.environ["OPENAI_API_KEY"] = "sk-test-e2e-secret-1234567890"
    try:
        with tempfile.TemporaryDirectory(prefix="fake_e2e_") as td:
            tmp = Path(td)
            layout = RunLayout(tmp / "run", create=True)
            evidence = tmp / "primary.c"
            evidence.write_text("void mlk_poly_add(void*,const void*,const void*);", encoding="utf-8")
            client = LLMClient({
                "mode": "real", "model": "fake-model", "api_key_env": "OPENAI_API_KEY",
                "max_retries": 0, "retry_sleep_seconds": 0, "semantic_advisory_mode": "off",
                "max_request_bytes": 200000, "max_stage_input_tokens_estimate": 50000,
                "max_total_input_tokens_estimate": 50000,
            })
            request = LLMStageRequest(
                stage="05_artifact_generation", prompt_text="Generate one candidate.",
                output_filename="05_artifact.json",
                json_schema={
                    "type": "object",
                    "properties": {
                        "artifact_plan": {"type": "object"},
                        "harness": {"type": "string"},
                    },
                    "required": ["artifact_plan", "harness"],
                    "additionalProperties": False,
                },
                primary_evidence_files=[evidence],
                deterministic_reference_bundle={"forbidden": "MUST_NOT_REACH_API"},
            )
            llm_result = client.run_stage(layout, request)
            check(llm_result.success and llm_result.parsed_json, llm_result.to_dict())
            generated = llm_result.parsed_json
            gate = validate_artifact_semantics(
                generated["artifact_plan"], generated["harness"],
                target_function="mlk_poly_add",
                property_campaign={"verification_strategy": "standard_cbmc_harness"},
            )
            check(gate["valid"], gate)
            fake_cbmc = executable(tmp / "cbmc", """#!/usr/bin/env python3
import json
print(json.dumps([{'result':[{'property':'TRACE_CLAIM::P16_BOUNDS::C01','status':'SUCCESS','description':'selected bounds claim'}]}]))
""")
            tool = execute_tool_pipeline([
                {"step_id": "cbmc", "tool": "cbmc", "command": [str(fake_cbmc)], "authoritative_result_step": True}
            ], cwd=tmp, output_dir=tmp / "tool_logs", step_timeout_seconds=5, pipeline_timeout_seconds=5)
            structured = parse_cbmc_json_output(tool["authoritative"]["stdout"])
            cov = selected_property_coverage(generated["artifact_plan"]["traceability_manifest"], structured["property_results"])
            final = classify_evidence(
                executed=True, exit_code=0, timeout=False, skipped=False, dry_run=False,
                unavailable=False, analysis_only=False, pipeline_setup_failed=False,
                structured=structured, coverage=cov,
            )
            check(final["selected_property_verified_under_model"], final)
            check("MUST_NOT_REACH_API" not in json.dumps(e2e_calls[-1]), e2e_calls[-1])
    finally:
        llm_mod_e2e.OpenAI = previous_openai
        if previous_key is None:
            os.environ.pop("OPENAI_API_KEY", None)
        else:
            os.environ["OPENAI_API_KEY"] = previous_key
    print("  PASS integrated fake-provider candidate reaches mapped structured formal evidence")

    print("\nMANDATORY A-TO-Z BEHAVIORAL REPAIR SUITE PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
