#!/usr/bin/env python3
"""Run the actual orchestrator end to end against local fake LLM and CBMC services.

This is a wiring/control regression only.  It deliberately uses LLM mode ``real``
so that every API-backed agent executes the production Responses API path, while
``base_url`` points at a local HTTP fixture and no paid/network service is used.
"""
from __future__ import annotations

import contextlib
import io
import json
import os
import shutil
import stat
import subprocess
import sys
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents import artifact_generation_agent as a5
from agents import code_understanding_agent as a3
from agents import counterexample_analysis_agent as a8
from agents import evaluation_reporter as a11
from agents import property_discovery_agent as a4
from agents import review_critic_agent as a6
from agents import spec_extraction_agent as a2
from agents.common.config_contract import load_normalized_config
from agents.common.llm_client import validate_json_schema
from agents.common.property_discovery_mode import classify_open_candidates, select_open_candidate
from agents.common.semantic_property import normalize_semantic_property
from agents.common.schemas import (
    ARTIFACT_PLAN_SCHEMA,
    CANDIDATE_PROPERTIES_SCHEMA,
    OPEN_CANDIDATE_PROPERTIES_SCHEMA,
    CODE_SUMMARY_SCHEMA,
    COUNTEREXAMPLE_ANALYSIS_SCHEMA,
    CRITIC_REVIEW_SCHEMA,
    EVALUATION_REPORT_SCHEMA,
    SPEC_SUMMARY_SCHEMA,
)


def deterministic_advice_off() -> dict[str, Any]:
    return {
        "used": False,
        "status": "not_provided_in_semantic_advisory_off_mode",
        "warning": "No deterministic semantic advice was provided.",
        "disagreements": [],
    }



def semantic_property(property_id: str) -> dict[str, Any]:
    return {
        "schema_version": "semantic_property.v2",
        "property_id": property_id,
        "statement": "The configured CBMC pointer and bounds checks for the selected target call succeed.",
        "target_call": {"function": "mlk_poly_add", "arguments": ["&r", "&a", "&b"], "call_count": 1},
        "pre_state_objects": [],
        "post_state_objects": [],
        "observed_memory": ["r", "a", "b"],
        "permitted_writes": [],
        "required_assumptions": [],
        "success_predicate": "the exact generated CBMC property identified for the selected bounds claim succeeds",
        "quantified_domain": {"variable": "", "lower_bound": "", "upper_bound_exclusive": ""},
        "requires_pre_state_snapshot": False,
        "requires_modular_call_replacement": False,
        "requires_loop_reasoning": False,
        "requires_relational_execution": False,
        "analysis_only": False,
        "evidence_references": [],
        "uncertainty": "Offline fixture only; the exact generated property identity remains decisive.",
        "semantic_completeness": {
            "complete": True,
            "missing_fields": [],
            "claim_boundary": "The fixture claim is structurally complete; this does not establish real verification evidence.",
        },
    }

def candidate_property() -> dict[str, Any]:
    return {
        "property_id": "P16_FAKE_BOUNDS",
        "property_family_id": "P16",
        "title": "Array-bounds safety for mlk_poly_add",
        "category": "array_bounds",
        "verification_strategy": "standard_cbmc_harness",
        "proof_obligation_kind": "safety",
        "support_classification": "production_supported_scoped",
        "required_tool_capabilities": ["cbmc"],
        "candidate_statement": (
            "CBMC built-in bounds and pointer checks report no violation for the exact "
            "target call under the emitted object model."
        ),
        "supporting_evidence": [{
            "source_path": "poly.c",
            "locator": "mlk_poly_add",
            "excerpt": "The target iterates over the fixed coefficient array.",
            "supports_claim": "A bounded memory-safety candidate is relevant to the target loop.",
            "confidence": "high",
        }],
        "required_assumptions": [],
        "cbmc_feasibility": "high",
        "risk_level": "low",
        "expected_artifact_type": "standard_cbmc_harness",
        "out_of_scope_boundaries": ["No functional equality or full-correctness claim."],
        "uncertainty": "Offline fixture candidate only.",
        "limitations": ["Bounded model and fake CBMC evidence only."],
        "semantic_property": semantic_property("P16_FAKE_BOUNDS"),
    }


def build_stage_outputs(fixture_root: Path, discovery_mode: str = "targeted_campaign") -> dict[str, dict[str, Any]]:
    spec_path = fixture_root / "spec.txt"
    code_path = fixture_root / "poly.c"

    agent2 = a2.build_mock_spec_summary(
        a2.SpecExtractionConfig(fixture_root, [spec_path]), {"source_records": []}
    )
    agent2.update(mock=False, llm_call_executed=True)
    agent2["source_scope"].update(provided_material_complete=True, missing_or_unavailable_material=[])
    agent2["deterministic_reference_assessment"] = deterministic_advice_off()
    agent2["limitations"] = ["Offline local-provider fixture; not thesis evidence."]

    agent3 = a3.build_mock_code_summary(
        a3.CodeUnderstandingConfig(fixture_root, [code_path]), {"files": []}, True
    )
    agent3.update(mock=False, llm_call_executed=True)
    agent3["source_scope"].update(provided_material_complete=True, missing_or_unavailable_material=[])
    agent3["deterministic_reference_assessment"] = deterministic_advice_off()
    agent3["limitations"] = ["Offline local-provider fixture; not thesis evidence."]

    if discovery_mode == "open_discovery":
        raw_candidate = {
            "property_id": "OPEN_FAKE_BOUNDS",
            "title": "Array-bounds safety for the selected target",
            "category": "array_bounds",
            "proof_obligation_kind": "safety",
            "candidate_statement": "All modeled coefficient accesses remain in bounds for the exact target call.",
            "supporting_evidence": [{
                "source_path": "poly.c", "locator": "mlk_poly_add",
                "excerpt": "The target iterates over a fixed coefficient array.",
                "supports_claim": "A local array-bounds candidate is relevant.", "confidence": "high",
            }],
            "required_assumptions": [], "cbmc_feasibility": "high", "risk_level": "low",
            "out_of_scope_boundaries": ["No full functional-correctness claim."],
            "uncertainty": "Offline fixture candidate only.",
            "limitations": ["Fake provider and fake CBMC only."],
            "semantic_property": semantic_property("OPEN_FAKE_BOUNDS"),
        }
        agent4 = a4.build_mock_candidate_properties(
            a4.PropertyDiscoveryConfig(fixture_root, discovery_mode="open_discovery", property_family_id="UNMAPPED", verification_strategy="UNSELECTED", property_support_level="unclassified"),
            True, True,
        )
        agent4.update(mock=False, llm_call_executed=True)
        agent4["source_scope"].update(provided_material_complete=True, missing_or_unavailable_material=[])
        agent4["candidate_properties"] = [raw_candidate]
        agent4["feasibility_ranking"] = [{"property_id": raw_candidate["property_id"], "rank": 1, "feasibility": "high", "rationale": "Small direct-CBMC safety fixture."}]
        agent4["limitations"] = ["Offline local-provider fixture; not thesis evidence."]
        classified, _ = classify_open_candidates(agent4)
        selected_handoff = select_open_candidate(classified)
        candidate = selected_handoff["property"]
    else:
        candidate = candidate_property()
        selected_handoff = candidate
        agent4 = a4.build_mock_candidate_properties(a4.PropertyDiscoveryConfig(fixture_root), True, True)
        agent4.update(mock=False, llm_call_executed=True)
        agent4["source_scope"].update(provided_material_complete=True, missing_or_unavailable_material=[])
        agent4["candidate_properties"] = [candidate]
        agent4["feasibility_ranking"] = [{
            "property_id": candidate["property_id"],
            "rank": 1,
            "feasibility": "high",
            "rationale": "Small direct-CBMC safety fixture.",
        }]
        agent4["deterministic_reference_assessment"] = deterministic_advice_off()
        agent4["limitations"] = ["Offline local-provider fixture; not thesis evidence."]

    property_id = str(candidate["property_id"])
    target_identity = f"TRACE_TARGET_CALL::{property_id}"
    claim_identity = f"TRACE_CLAIM::{property_id}::C01"
    target_expression = "mlk_poly_add(&r, &a, &b)"
    harness = f"""#include \"poly.h\"
void harness(void)
{{
  poly r;
  poly a;
  poly b;
  /* {target_identity} */
  mlk_poly_add(&r, &a, &b);
}}
"""
    agent5 = a5.build_mock_artifact_plan(
        a5.ArtifactGenerationConfig(
            fixture_root, project_root=fixture_root, discovery_mode=discovery_mode,
            property_family_id=str(candidate.get("property_family_id") or "P16"),
            verification_strategy=str(candidate.get("verification_strategy") or "standard_cbmc_harness"),
        ), selected_handoff
    )
    agent5.update(
        mock=False,
        llm_call_executed=True,
        intended_check="Only CBMC built-in pointer and array-bounds checks for the exact target call.",
        generated_harness_code=harness,
    )
    if discovery_mode != "open_discovery":
        agent5["selected_property"]["selection_method"] = "configured_property_campaign"
    agent5["old_state_snapshot_plan"] = {
        "required": "not_required_for_selected_property",
        "reason": "The selected claim is memory safety, not a functional relation.",
        "snapshot_items": [],
    }
    agent5["semantic_property"] = normalize_semantic_property(candidate, target_function="mlk_poly_add")
    agent5["traceability_manifest"] = {
        "selected_property_id": property_id,
        "target_call_marker": target_identity,
        "target_call_identity": target_identity,
        "target_call_expression": target_expression,
        "expected_claim_count": 1,
        "assumption_map": [],
        "claim_map": [{
            "assertion_id": "C01",
            "implementation_kind": "cbmc_builtin",
            "code_marker": claim_identity,
            "expected_property_identity": claim_identity,
            "expression_sha256": "",
            "rationale": "The selected built-in safety claim is mapped by exact generated-property identity.",
        }],
        "non_vacuity_strategy": [
            "Mutate a target access and require the exact selected built-in property to fail."
        ],
    }
    agent5["validation_expectations"] = [
        {"check": "exact target call is present", "expected": True},
        {"check": "selected claim mapping is non-empty", "expected": True},
    ]
    agent5["independence_statement"] = {
        "existing_artefacts_consulted": [],
        "deterministic_hints_consulted": [],
        "unavoidable_similarities": ["The required target symbol and C entry signature appear."],
        "intentional_differences": ["No deterministic harness template was consulted."],
        "copying_risk": "low_similarity_risk",
        "requires_human_similarity_review": False,
    }
    agent5["deterministic_reference_assessment"] = deterministic_advice_off()
    agent5["limitations"] = ["Offline local-provider fixture; no real LLM or CBMC evidence."]

    agent6 = a6.build_mock_critic_review(
        a6.ReviewCriticConfig(fixture_root),
        {"recommended_gate": "approved_for_tool_execution", "issues": []},
    )
    agent6.update(
        mock=False,
        llm_call_executed=True,
        overall_assessment="The candidate is structurally ready for the offline fake-CBMC check.",
        gate_recommendation="approved_for_tool_execution",
    )
    agent6["warnings"] = []
    agent6["deterministic_reference_assessment"] = deterministic_advice_off()
    agent6["limitations"] = ["Offline local-provider fixture; not thesis evidence."]

    canonical_status = {
        "result_classification": "selected_property_verified_under_recorded_model",
        "emitted_property_count": 1,
        "emitted_failure_count": 0,
        "emitted_unknown_count": 0,
    }
    derived_agent8_classification = a8.classify_failure_mode(
        canonical_status, "", "", {"failure_count": 0, "unknown_count": 0, "failed_properties": []}
    )
    agent8 = a8.build_mock_counterexample_analysis(
        a8.CounterexampleAnalysisConfig(fixture_root), canonical_status,
    )
    agent8.update(mock=False, llm_call_executed=True)
    agent8["tool_result_summary"] = {
        "result_classification": "selected_property_verified_under_recorded_model",
        "tool_executed": True,
        "exit_code": 0,
        "summary": "Fake CBMC returned one mapped successful bounds property.",
    }
    agent8["execution_status_interpretation"] = {
        "status": "success",
        "formal_tool_result_exists": True,
        "interpretation": "The fake structured evidence covers the selected fixture claim.",
    }
    agent8["failure_classification"] = {
        key: derived_agent8_classification[key]
        for key in (
            "result_classification", "failure_categories", "severity", "repair_needed",
            "no_formal_tool_result", "parsed_failure_count", "interpretation_boundary",
        )
    }
    agent8["success_scope_analysis"] = {
        "status": "bounded_success",
        "checked_scope": ["One mapped fake bounds property."],
        "not_checked": ["Real implementation correctness."],
        "limitations": ["Fake tool fixture only."],
    }
    agent8["deterministic_reference_assessment"] = deterministic_advice_off()
    agent8["limitations"] = ["Offline local-provider fixture; not thesis evidence."]

    measured = {
        "target_function": "mlk_poly_add",
        "target_topic": "offline fixture",
        "property_family_id": str(candidate.get("property_family_id") or "P16"),
        "verification_strategy": str(agent5.get("verification_strategy") or "standard_cbmc_harness"),
        "property_support_classification": str(candidate.get("support_classification") or "production_supported_scoped"),
        "property_discovery": {
            "mode": discovery_mode,
            "catalogue_visible_during_llm_discovery": discovery_mode != "open_discovery",
            "raw_candidate_count": 1,
            "classified_candidate_count": 1,
            "selected_property_id": candidate["property_id"],
            "selection_method": ("open_discovery_feasibility_then_risk_then_rank" if discovery_mode == "open_discovery" else "configured_targeted_campaign"),
        },
        "counts": {"llm_call_executed_count": 6, "missing_expected_output_count": 0},
        "tool_evidence": {
            "cbmc_result_classification": "selected_property_verified_under_recorded_model",
            "cbmc_tool_executed": True,
            "tool_outcome_category": a11.classify_tool_outcome(canonical_status),
            "emitted_property_count": 1,
            "emitted_failure_count": 0,
            "emitted_unknown_count": 0,
        },
        "integrity": {"validation_status": "valid", "missing_expected_output_count": 0},
        "llm_mode_counts": {"real": 6},
    }
    derived_taxonomy = a11.build_failure_mode_taxonomy(
        {"tool_evidence": measured["tool_evidence"], "review_and_repair_evidence": {"review_gate": {}}}, None
    )
    agent11 = a11.build_mock_evaluation_report(
        measured,
        derived_taxonomy,
        {"rows": []},
        {"threats": []},
    )
    agent11.update(mock=False, llm_call_executed=True)
    agent11["llm_interpretation"] = {
        "status": "bounded_offline_fixture",
        "summary": "The full orchestrator completed with a local fake provider and fake CBMC.",
    }
    agent11["usefulness_assessment"] = {
        "status": "offline_wiring_validated",
        "bounded_statement": "Only workflow wiring and controls were exercised.",
        "supporting_observations": ["Required stages and mapped evidence completed."],
    }
    agent11["human_review_required"] = {
        "required": True,
        "status": "required_before_real_claim",
        "items": ["Review the first real run and raw CBMC evidence."],
    }
    agent11["deterministic_reference_assessment"] = deterministic_advice_off()
    agent11["thesis_safe_wording"] = {
        "status": "offline_fixture_only",
        "paragraph": "The offline fixture validates workflow integration only; it is not real evidence.",
    }
    agent11["evidence_gaps"] = [{
        "gap": "No post-patch paid API or real CBMC experiment.",
        "impact": "Real-run findings remain pending.",
    }]
    agent11["claim_boundaries"] = {
        "proof_claimed": False,
        "full_correctness_claimed": False,
        "fips_compliance_claimed": False,
        "cryptographic_security_claimed": False,
        "mock_output": False,
    }
    agent11["limitations"] = ["Offline local provider and fake CBMC only."]

    outputs = {
        "02_spec_extraction_schema": agent2,
        "03_code_understanding_schema": agent3,
        "04_property_discovery_schema": agent4,
        "05_artifact_generation_schema": agent5,
        "06_review_critic_schema": agent6,
        "08_counterexample_analysis_schema": agent8,
        "11_evaluation_reporter_schema": agent11,
    }
    schemas = {
        "02_spec_extraction_schema": SPEC_SUMMARY_SCHEMA,
        "03_code_understanding_schema": CODE_SUMMARY_SCHEMA,
        "04_property_discovery_schema": (OPEN_CANDIDATE_PROPERTIES_SCHEMA if discovery_mode == "open_discovery" else CANDIDATE_PROPERTIES_SCHEMA),
        "05_artifact_generation_schema": ARTIFACT_PLAN_SCHEMA,
        "06_review_critic_schema": CRITIC_REVIEW_SCHEMA,
        "08_counterexample_analysis_schema": COUNTEREXAMPLE_ANALYSIS_SCHEMA,
        "11_evaluation_reporter_schema": EVALUATION_REPORT_SCHEMA,
    }
    for name, value in outputs.items():
        validation = validate_json_schema(value, schemas[name])
        if not validation["valid"]:
            raise AssertionError({name: validation["errors"]})
    return outputs


def response_envelope(text: str, response_id: str, model: str) -> dict[str, Any]:
    return {
        "id": response_id,
        "object": "response",
        "created_at": 1,
        "status": "completed",
        "error": None,
        "incomplete_details": None,
        "instructions": None,
        "max_output_tokens": 4096,
        "model": model,
        "output": [{
            "id": f"msg_{response_id}",
            "type": "message",
            "status": "completed",
            "role": "assistant",
            "content": [{
                "type": "output_text",
                "text": text,
                "annotations": [],
                "logprobs": [],
            }],
        }],
        "parallel_tool_calls": True,
        "previous_response_id": None,
        "reasoning": {"effort": None, "summary": None},
        "store": False,
        "temperature": 1.0,
        "text": {"format": {"type": "text"}, "verbosity": "low"},
        "tool_choice": "auto",
        "tools": [],
        "top_p": 1.0,
        "truncation": "disabled",
        "usage": {
            "input_tokens": 50,
            "input_tokens_details": {"cached_tokens": 0},
            "output_tokens": 50,
            "output_tokens_details": {"reasoning_tokens": 0},
            "total_tokens": 100,
        },
        "user": None,
        "metadata": {},
    }


class FixtureServer(ThreadingHTTPServer):
    outputs: dict[str, dict[str, Any]]
    calls: list[dict[str, Any]]


class Handler(BaseHTTPRequestHandler):
    server: FixtureServer

    def do_POST(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler API
        length = int(self.headers.get("Content-Length", "0"))
        body = json.loads(self.rfile.read(length).decode("utf-8"))
        format_obj = ((body.get("text") or {}).get("format") or {})
        schema_name = str(format_obj.get("name") or "")
        self.server.calls.append({"path": self.path, "schema_name": schema_name, "body": body})
        if schema_name not in self.server.outputs:
            payload = {"error": {"message": f"Unexpected schema name: {schema_name}"}}
            raw = json.dumps(payload).encode("utf-8")
            self.send_response(400)
        else:
            output_text = json.dumps(self.server.outputs[schema_name], separators=(",", ":"))
            payload = response_envelope(output_text, f"fixture_{len(self.server.calls)}", str(body.get("model") or "fixture"))
            raw = json.dumps(payload).encode("utf-8")
            self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def log_message(self, format: str, *args: object) -> None:  # noqa: A002
        return


def read_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(value, dict) and isinstance(value.get("content"), dict):
        return value["content"]
    if not isinstance(value, dict):
        raise AssertionError(f"Expected object in {path}")
    return value


def main(discovery_mode: str = "targeted_campaign") -> int:
    with tempfile.TemporaryDirectory(prefix="full_offline_orchestrator_") as td:
        fixture = Path(td)
        release_root = fixture / "offline-e2e-release"
        release_specs = release_root / "inputs" / "specs"
        release_specs.mkdir(parents=True)
        shutil.copytree(
            ROOT / "agents",
            release_root / "agents",
            ignore=shutil.ignore_patterns("__pycache__", "*.pyc"),
        )
        full_spec = release_specs / "fips203_clean.txt"
        archival_pdf = release_specs / "fips203.pdf"
        full_spec.write_text("ML-KEM polynomial coefficients use fixed degree 256.\n", encoding="utf-8")
        archival_pdf.write_bytes(b"%PDF-1.4\noffline archival fixture\n")
        spec = fixture / "spec.txt"
        header = fixture / "poly.h"
        source = fixture / "poly.c"
        spec.write_text("ML-KEM polynomial coefficients use fixed degree 256.\n", encoding="utf-8")
        header.write_text(
            "#include <stdint.h>\n#define MLKEM_N 256\n"
            "typedef struct { int16_t coeffs[MLKEM_N]; } poly;\n"
            "void mlk_poly_add(poly *r, const poly *a, const poly *b);\n",
            encoding="utf-8",
        )
        source.write_text(
            '#include "poly.h"\n'
            "void mlk_poly_add(poly *r, const poly *a, const poly *b) {\n"
            "  for (int i = 0; i < MLKEM_N; ++i) r->coeffs[i] = a->coeffs[i] + b->coeffs[i];\n"
            "}\n",
            encoding="utf-8",
        )

        cbmc_log = fixture / "fake_cbmc_invocations.jsonl"
        fake_goto_cc = fixture / "goto-cc"
        fake_goto_cc.write_text(
            """#!/usr/bin/env python3
import sys
from pathlib import Path
if '--version' in sys.argv:
    print('goto-cc fake-offline-e2e 1.0')
    raise SystemExit(0)
args=sys.argv[1:]
if '-o' not in args:
    print('missing -o', file=sys.stderr)
    raise SystemExit(2)
out=Path(args[args.index('-o')+1])
out.parent.mkdir(parents=True,exist_ok=True)
out.write_text('fake goto model',encoding='utf-8')
raise SystemExit(0)
""",
            encoding="utf-8",
        )
        fake_goto_cc.chmod(fake_goto_cc.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP)
        fake_cbmc = fixture / "cbmc"
        expected_property_id = "OPEN_FAKE_BOUNDS" if discovery_mode == "open_discovery" else "P16_FAKE_BOUNDS"
        expected_claim_identity = f"TRACE_CLAIM::{expected_property_id}::C01"
        fake_cbmc.write_text(
            """#!/usr/bin/env python3
import json,os,sys
from pathlib import Path
log=Path(os.environ['FAKE_CBMC_LOG'])
with log.open('a',encoding='utf-8') as f: f.write(json.dumps(sys.argv[1:])+'\\n')
if '--version' in sys.argv:
    print('CBMC fake-offline-e2e 1.0')
    raise SystemExit(0)
print(json.dumps([{'result':[{
 'property':'__CLAIM_ID__',
 'description':'selected bounds claim for mlk_poly_add target call',
 'status':'SUCCESS'
}]}]))
raise SystemExit(0)
""".replace("__CLAIM_ID__", expected_claim_identity),
            encoding="utf-8",
        )
        fake_cbmc.chmod(fake_cbmc.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP)

        server = FixtureServer(("127.0.0.1", 0), Handler)
        server.outputs = build_stage_outputs(fixture, discovery_mode)
        server.calls = []
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        try:
            run_id = "offline_full_orchestrator_" + discovery_mode
            config = {
                "project_root": str(release_root),
                "run_id": run_id,
                "output_root": "runs",
                "target_scheme": "ML-KEM",
                "target_function": "mlk_poly_add",
                "target_topic": "offline full-orchestrator fixture",
                "verification_tool": "CBMC",
                "artifact_type": "CBMC verification harness",
                "max_iterations": 0,
                "parallel_initial_agents": True,
                "strict_outputs": True,
                "inputs": {
                    "spec_paths": ["inputs/specs/fips203_clean.txt"],
                    "archival_spec_paths": ["inputs/specs/fips203.pdf"],
                    "code_dir": str(fixture),
                    "code_paths": [str(source), str(header)],
                },
                "llm": {
                    "provider": "openai",
                    "mode": "real",
                    "model": "local-fixture-model",
                    "api_key_env": "OPENAI_API_KEY",
                    "base_url": f"http://127.0.0.1:{server.server_port}/v1",
                    "reasoning": {"effort": "none"},
                    "text": {"verbosity": "low"},
                    "max_output_tokens": 4096,
                    "max_retries": 0,
                    "retry_sleep_seconds": 0,
                    "store": False,
                    "attach_files_as_base64": False,
                    "timeout_seconds": 30,
                },
                "tool_execution": {
                    "cbmc_binary": str(fake_cbmc),
                    "cbmc_function": "harness",
                    "dry_run": False,
                    "force_run": False,
                    "require_gate_approval": True,
                    "source_files": [str(source)],
                    "stub_files": [],
                    "include_paths": [str(fixture)],
                    "defines": [],
                    "working_directory": str(fixture),
                    "extra_cbmc_args": [],
                    "unwind": 256,
                    "goto_cc_binary": str(fake_goto_cc),
                    "goto_instrument_binary": "goto-instrument-not-used",
                    "extra_goto_cc_args": [],
                    "extra_goto_instrument_args": [],
                    "step_timeout_seconds": 20,
                    "pipeline_timeout_seconds": 30,
                    "structured_json_required": True,
                },
                "formal_strategy_reconciliation": {
                    "mode": "evidence_bound",
                    "allow_optional_contract_to_harness_fallback": True,
                    "require_cbmc_frontend_readiness": True,
                    "require_full_route_readiness": True,
                },
                "counterexample_analysis": {"allow_missing_tool_outputs": False},
                "repair_refinement": {"allow_missing_inputs": False, "render_candidate_repaired_harness": True},
                "experiment_logger": {
                    "strict_required_stages": False,
                    "allow_missing_previous_stages": True,
                    "include_checksums": True,
                    "include_file_inventory": True,
                },
                "evaluation_reporter": {
                    "allow_missing_experiment_log": False,
                    "include_thesis_wording": True,
                    "include_rq_mapping": True,
                    "include_failure_taxonomy": True,
                    "include_threats_to_validity": True,
                },
                "provenance": {"repository_paths": [str(ROOT)], "source_revision": "offline-fixture-revision"},
                "property_discovery": ({
                    "mode": "open_discovery",
                    "catalogue_visibility": "hidden",
                    "allow_uncatalogued_properties": True,
                    "selection_policy": "feasibility_then_risk_then_rank",
                } if discovery_mode == "open_discovery" else {
                    "mode": "targeted_campaign",
                    "catalogue_visibility": "configured_family_only",
                    "allow_uncatalogued_properties": False,
                }),
                "experiment_protocol": {
                    "protocol_version": "llm-first-v1",
                    "semantic_advisory_mode": "off",
                    "repair_policy": "none_initial_run",
                    "prompt_budget": {
                        "max_request_bytes": 500000,
                        "max_retry_growth_percent": 10,
                        "max_stage_input_tokens_estimate": 125000,
                        "max_total_input_tokens_estimate": 700000,
                    },
                    "initial_run_requires_zero_repairs": True,
                    "selected_property_claims_required": True,
                    "structured_cbmc_json_required": True,
                    "mutation_non_vacuity_required": True,
                },
            }
            if discovery_mode != "open_discovery":
                config["property_campaign"] = {
                    "property_family_id": "P16",
                    "verification_strategy": "standard_cbmc_harness",
                    "allow_analysis_only": False,
                    "support_level": "production_supported_scoped",
                }
            config_dir = release_root / "configs"
            config_dir.mkdir(parents=True, exist_ok=True)
            config_path = config_dir / "offline_config.json"
            config_path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
            env = os.environ.copy()
            env["OPENAI_API_KEY"] = "sk-local-test-fixture-not-real-1234567890"
            env["FAKE_CBMC_LOG"] = str(cbmc_log)
            # Agent subprocesses share a cache inside the disposable fixture.
            # This preserves source-tree cleanliness while avoiding repeated
            # compilation of the same pinned SDK/schema modules in every stage.
            env.pop("PYTHONDONTWRITEBYTECODE", None)
            env["PYTHONPYCACHEPREFIX"] = str(fixture / "pycache")
            test_pydeps = Path(os.environ.get("THESIS_TEST_PYDEPS", "/mnt/data/open_discovery_pydeps"))
            env["PYTHONPATH"] = os.pathsep.join(
                part for part in (
                    str(test_pydeps) if test_pydeps.is_dir() else "",
                    str(release_root),
                    str(ROOT),
                    env.get("PYTHONPATH", ""),
                ) if part
            )
            # Invoke the production orchestrator class in this process. Agent
            # stages still execute through its normal subprocess path; avoiding a
            # redundant outer Python startup keeps this full E2E fixture within
            # constrained-host command limits without bypassing workflow logic.
            from agents.master_orchestrator import MasterOrchestrator

            previous_env = os.environ.copy()
            stdout_buffer = io.StringIO()
            stderr_buffer = io.StringIO()
            try:
                os.environ.clear()
                os.environ.update(env)
                with contextlib.redirect_stdout(stdout_buffer), contextlib.redirect_stderr(stderr_buffer):
                    orchestrator = MasterOrchestrator(
                        config_path,
                        strict_outputs=True,
                        stop_on_optional_failure=True,
                    )
                    returncode = orchestrator.run_pipeline()
            finally:
                os.environ.clear()
                os.environ.update(previous_env)

            class Result:
                pass
            proc = Result()
            proc.returncode = returncode
            proc.stdout = stdout_buffer.getvalue()
            proc.stderr = stderr_buffer.getvalue()
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=5)

        if proc.returncode != 0:
            debug_files = {}
            candidate_run = release_root / "runs" / run_id
            if candidate_run.exists():
                for path in candidate_run.rglob("*stderr.txt"):
                    debug_files[str(path.relative_to(candidate_run))] = path.read_text(encoding="utf-8", errors="replace")
                for path in candidate_run.rglob("*status.json"):
                    try:
                        debug_files[str(path.relative_to(candidate_run))] = path.read_text(encoding="utf-8", errors="replace")
                    except OSError:
                        pass
            raise AssertionError(
                f"Full offline orchestrator failed rc={proc.returncode}\nSTDOUT:\n{proc.stdout}\nSTDERR:\n{proc.stderr}\nDEBUG:\n{json.dumps(debug_files, indent=2)}"
            )

        expected_schemas = [
            "02_spec_extraction_schema",
            "03_code_understanding_schema",
            "04_property_discovery_schema",
            "05_artifact_generation_schema",
            "06_review_critic_schema",
            "08_counterexample_analysis_schema",
            "11_evaluation_reporter_schema",
        ]
        observed_schemas = [call["schema_name"] for call in server.calls]
        assert len(observed_schemas) == len(expected_schemas), observed_schemas
        assert set(observed_schemas[:2]) == set(expected_schemas[:2]), observed_schemas
        assert observed_schemas[2:] == expected_schemas[2:], observed_schemas

        run_dir = release_root / "runs" / run_id
        resolved = read_json(run_dir / "run_config.resolved.json")
        protocol_hash = resolved["experiment_protocol"]["protocol_sha256"]
        assert protocol_hash
        assert resolved["property_discovery"]["mode"] == discovery_mode
        if discovery_mode == "open_discovery":
            assert resolved["property_campaign"]["property_family_id"] == "UNMAPPED"
            raw_a4 = read_json(next((run_dir / "stages/04_property_discovery/llm_authoritative").glob("03_candidate_properties.json")))
            assert "property_family_id" not in raw_a4["candidate_properties"][0]
            classification = read_json(next((run_dir / "stages/04_property_discovery/validation").glob("04_open_discovery_catalogue_classification.json")))
            assert classification["raw_authoritative_output_byte_identical"] is True
            selection = read_json(next((run_dir / "stages/04_property_discovery/validation").glob("06_open_discovery_selected_property.json")))
            assert selection["selected"] is True
            for stage_name in ("02_spec_extraction", "03_code_understanding", "04_property_discovery"):
                request_path = next((run_dir / "stages" / stage_name).rglob("attempt_01_request.json"))
                request_text = request_path.read_text(encoding="utf-8")
                for forbidden in ("P16", "Polynomial addition/subtraction bounds", "PROPERTY_SUPPORT_CATALOGUE", "standard_cbmc_harness"):
                    assert forbidden not in request_text, (stage_name, forbidden)
        assert "pipeline_release" not in resolved
        archival_snapshot = run_dir / "stages/01_master_orchestrator/control/input_snapshot/archival_spec_01_fips203.pdf"
        assert archival_snapshot.read_bytes() == archival_pdf.read_bytes(), archival_snapshot

        final_summary = read_json(run_dir / "final/final_run_summary.json")
        assert final_summary["final_status"] == "passed_selected_properties", final_summary
        assert final_summary["verification_passed_selected_properties"] is True, final_summary
        assert final_summary["experiment_protocol_sha256"] == protocol_hash, final_summary
        assert "pipeline_release_zip_sha256" not in final_summary, final_summary

        cbmc_status = read_json(next((run_dir / "stages/07_tool_execution").rglob("06_cbmc_status.json")))
        assert cbmc_status["tool_execution_successful"] is True, cbmc_status
        assert cbmc_status["selected_property_coverage_complete"] is True, cbmc_status
        assert cbmc_status["selected_property_verified_under_model"] is True, cbmc_status
        assert cbmc_status["result_classification"] == "selected_property_verified_under_recorded_model", cbmc_status
        assert cbmc_status["emitted_failure_count"] == 0, cbmc_status
        assert cbmc_status["emitted_unknown_count"] == 0, cbmc_status
        a8_matrix_record = read_json(next((run_dir / "stages/08_counterexample_analysis").rglob("07_failure_classification_matrix.deterministic.json")))
        a8_matrix = a8_matrix_record.get("content", a8_matrix_record)
        assert a8_matrix["semantic_outcome"] == "bounded_selected_property_success", a8_matrix
        assert a8_matrix["severity"] == "none" and a8_matrix["repair_needed"] is False, a8_matrix

        invocation_rows = [json.loads(line) for line in cbmc_log.read_text(encoding="utf-8").splitlines()]
        formal_invocations = [row for row in invocation_rows if "--version" not in row]
        assert len(formal_invocations) >= 2, invocation_rows
        readiness_invocations = [row for row in formal_invocations if "--show-properties" in row]
        solving_invocations = [row for row in formal_invocations if "--show-properties" not in row]
        assert len(readiness_invocations) == 2, formal_invocations
        assert len(solving_invocations) == 1, formal_invocations
        assert "--json-ui" in readiness_invocations[0], readiness_invocations
        assert "--json-ui" in solving_invocations[0], solving_invocations
        assert any(str(source) == arg for arg in solving_invocations[0]), solving_invocations

        # Every executed agent status, final evaluation summary and Agent 10
        # reproducibility record must be bound to the same immutable protocol.
        executed_stages = {
            "02_spec_extraction", "03_code_understanding", "04_property_discovery",
            "05_artifact_generation", "06_review_critic", "07_tool_execution",
            "08_counterexample_analysis", "10_experiment_logger", "11_evaluation_reporter",
        }
        for stage in executed_stages:
            agent_statuses = []
            for status_path in sorted((run_dir / "stages" / stage).rglob("*status.json")):
                candidate = read_json(status_path)
                if candidate.get("schema_version") == "agent_status.v1":
                    agent_statuses.append((status_path, candidate))
            assert agent_statuses, stage
            for status_path, authoritative in agent_statuses:
                assert authoritative["experiment_protocol_sha256"] == protocol_hash, (stage, status_path, authoritative)
        assert not (run_dir / "stages/09_repair_refinement/handoff/handoff_manifest.json").exists()

        evaluation_paths = sorted(run_dir.rglob("10_evaluation_summary.json"))
        assert evaluation_paths, "Agent 11 evaluation summary is missing"
        measured_record = read_json(next((run_dir / "stages/11_evaluation_reporter").rglob("10_measured_evaluation_facts.json")))
        measured_facts = measured_record.get("content", measured_record)
        assert measured_facts["tool_evidence"]["tool_outcome_category"] == "bounded_selected_property_success", measured_facts
        taxonomy_record = read_json(next((run_dir / "stages/11_evaluation_reporter").rglob("10_failure_mode_taxonomy.json")))
        taxonomy = taxonomy_record.get("content", taxonomy_record)
        observed_taxonomy = {row["taxonomy_id"] for row in taxonomy["rows"] if row["observed_in_run"]}
        assert "FM_SCOPE_001" in observed_taxonomy, taxonomy
        evaluation_summary = read_json(evaluation_paths[-1])
        assert evaluation_summary["experiment_protocol_sha256"] == protocol_hash, evaluation_summary
        assert "pipeline_release" not in evaluation_summary, evaluation_summary
        report_paths = sorted(run_dir.rglob("10_evaluation_report.md"))
        assert report_paths, "Agent 11 final Markdown is missing"
        report_text = report_paths[-1].read_text(encoding="utf-8")
        assert "Pipeline release provenance" not in report_text
        logger_handoff_path = run_dir / "stages/10_experiment_logger/handoff/handoff_manifest.json"
        logger_handoff = read_json(logger_handoff_path)
        logger_outputs = logger_handoff.get("handoff_outputs") or {}
        reproducibility_rel = logger_outputs.get("run_reproducibility_record")
        if not reproducibility_rel:
            stage_files = sorted(str(p.relative_to(run_dir)) for p in (run_dir / "stages/10_experiment_logger").rglob("*"))
            raise AssertionError(
                "Agent 10 handoff does not expose run_reproducibility_record; "
                f"handoff={logger_handoff}; stage_files={stage_files}"
            )
        reproducibility_path = (run_dir / "stages/10_experiment_logger" / reproducibility_rel).resolve()
        assert reproducibility_path.is_file(), (reproducibility_path, logger_handoff)
        run_repro = read_json(reproducibility_path)
        assert run_repro["experiment_protocol_sha256"] == protocol_hash, run_repro
        if discovery_mode == "open_discovery":
            discovery_rel = logger_outputs.get("property_discovery_evidence")
            assert discovery_rel, logger_outputs
            discovery_record = read_json((run_dir / "stages/10_experiment_logger" / discovery_rel).resolve())
            assert discovery_record["discovery_mode"] == "open_discovery"
            assert discovery_record["catalogue_visible_during_llm_discovery"] is False
            assert discovery_record["selected_property"]["selected"] is True
            eval_report_json = read_json(next((run_dir / "stages/11_evaluation_reporter").rglob("10_evaluation_report.json")))
            assert eval_report_json["measured_facts"]["property_discovery_mode"] == "open_discovery"
            assert eval_report_json["measured_facts"]["catalogue_visible_during_llm_discovery"] is False

        request_snapshots = sorted(run_dir.rglob("attempt_01_request.json"))
        assert len(request_snapshots) == len(expected_schemas), request_snapshots
        for snapshot_path in request_snapshots:
            snapshot_text = snapshot_path.read_text(encoding="utf-8")
            assert "sk-local-test-fixture-not-real-1234567890" not in snapshot_text
            snapshot = json.loads(snapshot_text)
            assert snapshot["evidence_categories"]["deterministic_advisory_bundle_present"] is False, snapshot_path

        # The provider usage evidence must remain numeric after secret redaction.
        response_snapshots = sorted(run_dir.rglob("attempt_01_response.json"))
        assert len(response_snapshots) == len(expected_schemas), response_snapshots
        for response_path in response_snapshots:
            payload = json.loads(response_path.read_text(encoding="utf-8"))
            rendered = json.dumps(payload)
            assert '"input_tokens": 50' in rendered, response_path
            assert '"total_tokens": 100' in rendered, response_path

    print(f"FULL OFFLINE {discovery_mode} ORCHESTRATOR + FAKE RESPONSES API + FAKE CBMC E2E: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
