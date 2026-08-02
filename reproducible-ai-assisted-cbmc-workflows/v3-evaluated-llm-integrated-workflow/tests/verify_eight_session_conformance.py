#!/usr/bin/env python3
"""Override-aware conformance checks derived from the eight-session planning document."""
from __future__ import annotations

import json
import os
import tempfile
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
import sys
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.run_layout import DEFAULT_STAGES, RunLayout
from agents.common.schemas import ALL_STAGE_SCHEMAS, EVALUATION_REPORT_SCHEMA
from agents import evaluation_reporter as a11
from agents import experiment_logger as a10
from agents import repair_agent as a9


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def write_json(path: Path, value: dict[str, Any]) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")
    return path


def test_roles_and_structured_disagreements() -> None:
    expected = {
        "01_master_orchestrator": "deterministic_only",
        "02_spec_extraction": "llm_backed",
        "03_code_understanding": "llm_backed",
        "04_property_discovery": "llm_backed",
        "05_artifact_generation": "mixed",
        "06_review_critic": "llm_backed",
        "07_tool_execution": "tool_execution",
        "08_counterexample_analysis": "llm_backed",
        "09_repair_refinement": "mixed",
        "10_experiment_logger": "deterministic_only",
        "11_evaluation_reporter": "mixed",
    }
    actual = {s.stage_key: s.stage_type for s in DEFAULT_STAGES}
    require(actual == expected, f"Agent-role registry diverges from frozen architecture: {actual}")

    reasoning_schemas = [
        "SPEC_SUMMARY_SCHEMA", "CODE_SUMMARY_SCHEMA", "CANDIDATE_PROPERTIES_SCHEMA",
        "ARTIFACT_PLAN_SCHEMA", "CRITIC_REVIEW_SCHEMA", "COUNTEREXAMPLE_ANALYSIS_SCHEMA",
        "REPAIR_PLAN_SCHEMA", "EVALUATION_REPORT_SCHEMA",
    ]
    for name in reasoning_schemas:
        props = ALL_STAGE_SCHEMAS[name]["properties"]
        require("deterministic_reference_assessment" in props, f"{name} cannot record advisory disagreements")
        assessment = props["deterministic_reference_assessment"]
        require("disagreements" in assessment["properties"], f"{name} lacks structured disagreement records")

    eval_props = EVALUATION_REPORT_SCHEMA["properties"]
    for key in ["measured_facts", "llm_interpretation", "limitations", "threats_to_validity", "human_review_required"]:
        require(key in eval_props, f"Agent 11 required separation missing: {key}")
    require("evaluation_interpretation" not in eval_props, "Legacy Agent 11 field survived instead of llm_interpretation")


def test_single_physical_iteration_manifests() -> None:
    with tempfile.TemporaryDirectory(prefix="session8_pointer_gate_") as td:
        run = Path(td) / "run"
        RunLayout(run, create=True)
        layout = RunLayout(run, create=False, active_iteration=3, active_reason="counterexample_analysis")
        output = layout.validation_dir("06_review_critic") / "gate.json"
        write_json(output, {"tool_execution_allowed": False})
        root_handoff = layout.write_handoff_manifest(
            "06_review_critic",
            outputs={"review_gate_decision": output},
            authoritative_source="llm_authoritative_plus_deterministic_gate",
            next_stage_consumers=["07_tool_execution"],
        )
        root_stage = layout.write_stage_manifest(
            "06_review_critic", validation_outputs={"review_gate_decision": output}
        )
        iter_handoff = layout.iteration_handoff_manifest_path("06_review_critic")
        iter_stage = layout.iteration_stage_manifest_path("06_review_critic")
        require(iter_handoff is not None and iter_handoff.is_file(), "Canonical iteration handoff missing")
        require(iter_stage is not None and iter_stage.is_file(), "Canonical iteration stage manifest missing")
        require(root_handoff.exists() and root_stage.exists(), "Latest manifest pointers missing")

        if root_handoff.is_symlink():
            require(os.path.samefile(root_handoff, iter_handoff), "Root handoff is not a pointer to canonical iteration manifest")
        else:
            pointer = json.loads(root_handoff.read_text(encoding="utf-8"))
            require(pointer.get("schema_version") == "manifest_pointer.v1", "Fallback root handoff is a copied full manifest")
        if root_stage.is_symlink():
            require(os.path.samefile(root_stage, iter_stage), "Root stage manifest is not a pointer to canonical iteration manifest")
        else:
            pointer = json.loads(root_stage.read_text(encoding="utf-8"))
            require(pointer.get("schema_version") == "manifest_pointer.v1", "Fallback root stage manifest is a copied full manifest")

        resolved = layout.read_handoff_manifest("06_review_critic")
        require(resolved["iteration"] == 3, "Manifest pointer resolver lost iteration identity")
        require("review_gate_decision" in resolved["handoff_outputs"], "Manifest pointer resolver lost handoff output")


def test_agent11_raw_evidence_selection_and_fail_closed_handoff() -> None:
    with tempfile.TemporaryDirectory(prefix="agent11_document_gate_") as td:
        tmp = Path(td)
        run = tmp / "run"
        layout = RunLayout(run, create=True)

        spec = tmp / "fips.txt"; spec.write_text("FIPS RAW", encoding="utf-8")
        code = tmp / "poly.c"; code.write_text("void mlk_poly_add(void){}", encoding="utf-8")
        prior = tmp / "05_critic_review.json"; write_json(prior, {"stage": "06_review_critic"})
        harness = tmp / "04_generated_harness.c"; harness.write_text("void harness(void){}", encoding="utf-8")
        gate = tmp / "05_review_gate_decision.json"; write_json(gate, {"tool_execution_allowed": False})
        cbmc_stdout = tmp / "06_cbmc_output.txt"; cbmc_stdout.write_text("VERIFICATION FAILED", encoding="utf-8")
        request_snapshot = tmp / "attempt_01_request.json"; write_json(request_snapshot, {"input": "raw sent prompt"})
        response_snapshot = tmp / "attempt_01_response.json"; write_json(response_snapshot, {"output": "raw model response"})

        handoff_index = {
            "handoff_outputs": [
                {"producer_stage": "06_review_critic", "output_key": "critic_review", "resolved_path": str(prior), "exists": True},
                {"producer_stage": "05_artifact_generation", "output_key": "generated_harness", "resolved_path": str(harness), "exists": True},
                {"producer_stage": "06_review_critic", "output_key": "review_gate_decision", "resolved_path": str(gate), "exists": True},
            ]
        }
        llm_index = {"rows": [{
            "raw_response_path": str(response_snapshot),
            "exact_request_snapshots": [str(request_snapshot)],
        }]}
        tool_index = {"evidence_files": [{
            "evidence_key": "cbmc_output", "path": str(cbmc_stdout), "exists": True,
        }]}
        config = {"inputs": {"spec_paths": [str(spec)], "code_paths": [str(code)]}}
        raw, prior_context, trusted = a11.collect_agent11_direct_evidence(
            config_data=config, run_dir=run, handoff_index=handoff_index,
            llm_index=llm_index, tool_index=tool_index,
        )
        raw_set, prior_set, trusted_set = map(lambda xs: {p.resolve() for p in xs}, (raw, prior_context, trusted))
        for expected in [spec, code, harness, cbmc_stdout, response_snapshot]:
            require(expected.resolve() in raw_set, f"Agent 11 omitted raw evidence: {expected.name}")
        require(
            request_snapshot.resolve() not in raw_set,
            "Agent 11 recursively re-transmitted an exact API request snapshot",
        )
        require(prior.resolve() in prior_set, "Agent 11 omitted previous authoritative candidate output")
        require(gate.resolve() in trusted_set, "Agent 11 omitted trusted deterministic gate fact")

        # Build minimal Agent 10 canonical handoff and force a real-mode missing-key failure.
        exp_dir = layout.stage_dir("10_experiment_logger") / "experiment_log"
        val_dir = layout.validation_dir("10_experiment_logger")
        files = {
            "experiment_log": write_json(exp_dir / "09_experiment_log.json", {"summary": {"status": "test"}}),
            "run_reproducibility_record": write_json(exp_dir / "09_run_reproducibility_record.json", {}),
            "stage_manifest_index": write_json(exp_dir / "09_stage_manifest_index.json", {"rows": []}),
            "handoff_index": write_json(exp_dir / "09_handoff_index.json", handoff_index),
            "checksum_manifest": write_json(exp_dir / "09_checksum_manifest.json", {"rows": []}),
            "llm_call_index": write_json(exp_dir / "09_llm_call_index.json", llm_index),
            "tool_evidence_index": write_json(exp_dir / "09_tool_evidence_index.json", tool_index),
            "gate_and_repair_index": write_json(exp_dir / "09_gate_and_repair_index.json", {"items": {}}),
            "failure_mode_log": write_json(exp_dir / "09_failure_mode_log.json", {}),
            "log_integrity_validation": write_json(val_dir / "09_log_integrity_validation.json", {"validation_status": "valid", "warning_count": 0, "error_count": 0}),
            "missing_expected_outputs": write_json(val_dir / "09_missing_expected_outputs.json", {"missing_count": 0}),
        }
        md = exp_dir / "09_experiment_log.md"; md.write_text("Measured run evidence", encoding="utf-8")
        files["experiment_log_markdown"] = md
        layout.write_handoff_manifest(
            "10_experiment_logger", outputs=files,
            authoritative_source="deterministic_evidence_logger", next_stage_consumers=["11_evaluation_reporter"],
        )

        config.update({
            "llm": {"mode": "real", "model": "unused-test-model", "api_key_env": "EIGHT_SESSION_MISSING_KEY"},
            "target_function": "mlk_poly_add", "target_topic": "document conformance",
        })
        os.environ.pop("EIGHT_SESSION_MISSING_KEY", None)
        cfg = a11.EvaluationReporterConfig(run_dir=run, target_function="mlk_poly_add", target_topic="document conformance", llm_mode_override="real")
        rc = a11.run_agent11(config, cfg)
        require(rc == 1, "Agent 11 did not fail closed when its real LLM output was unavailable")
        manifest = layout.read_handoff_manifest("11_evaluation_reporter")
        require("evaluation_report" not in manifest["handoff_outputs"], "Deterministic facts were substituted as authoritative evaluation_report")
        require("measured_evaluation_facts" in manifest["handoff_outputs"], "Diagnostic measured facts were not preserved")
        status = json.loads((layout.logs_dir("11_evaluation_reporter") / "11_evaluation_reporter_status.json").read_text(encoding="utf-8"))
        require(status["success"] is False, "Agent 11 status hid the unavailable authoritative narrative")

        pdir = layout.prompt_package_dir("11_evaluation_reporter")
        primary_manifest = json.loads((pdir / "primary_evidence_manifest.json").read_text(encoding="utf-8"))
        prior_manifest = json.loads((pdir / "prior_authoritative_context_manifest.json").read_text(encoding="utf-8"))
        primary_files = primary_manifest.get("content", primary_manifest).get("files", [])
        prior_files = prior_manifest.get("content", prior_manifest).get("files", [])
        primary_paths = {Path(x["path"]).resolve() for x in primary_files if x.get("path") and not x.get("warning")}
        prior_paths = {Path(x["path"]).resolve() for x in prior_files if x.get("path") and not x.get("warning")}
        require(cbmc_stdout.resolve() in primary_paths and harness.resolve() in primary_paths, "Agent 11 prompt package omitted raw tool/artefact evidence")
        require(prior.resolve() in prior_paths, "Agent 11 prompt package omitted previous candidate context")



def test_reporting_counts_and_mock_promotion_precision() -> None:
    with tempfile.TemporaryDirectory(prefix="reporting_precision_gate_") as td:
        run = Path(td) / "run"
        layout = RunLayout(run, create=True)
        # Create exactly two real manifests while the registry still contains all 11 planned stages.
        layout.write_stage_manifest("01_master_orchestrator", notes={"test": True})
        layout.write_stage_manifest("02_spec_extraction", notes={"test": True})
        index = a10.build_stage_manifest_index(run)
        require(index["expected_stage_count"] == 11, "Expected-stage count is inaccurate")
        require(index["indexed_stage_record_count"] == 11, "Indexed-stage record count is inaccurate")
        require(index["stage_manifest_count"] == 2, "Existing manifest count incorrectly includes missing manifests")
        require(index["missing_stage_manifest_count"] == 9, "Missing manifest count is inaccurate")

    # The implementation must require a genuine API call before saying a candidate LLM narrative was promoted.
    source = (ROOT / "agents" / "evaluation_reporter.py").read_text(encoding="utf-8")
    require("and result.llm_call_executed" in source, "Mock output can still be marked as promoted LLM narrative")
    require('and result.mode == "real"' in source, "Non-real mode can still be marked as promoted LLM narrative")
    require("mock_or_non_api_narrative_used_for_wiring_only" in source, "Mock narrative status is not explicitly separated")
    require("and llm_executed_count > 0" in source, "Mock/no-API run can still be marked eligible for scientific-result reporting")
    require('"unqualified_success_wording_allowed": False' in source, "Unqualified success wording remains possible")

def test_repair_never_modifies_production_source_by_default() -> None:
    with tempfile.TemporaryDirectory(prefix="repair_source_guard_") as td:
        tmp = Path(td)
        run = tmp / "run"
        layout = RunLayout(run, create=True, active_iteration=1, active_reason="counterexample_analysis")
        original = tmp / "original_harness.c"
        original_text = "void harness(void){}\n"
        original.write_text(original_text, encoding="utf-8")
        cfg = a9.RepairRefinementConfig(run_dir=run, allow_source_code_repair=False)
        plan = {
            "candidate_repaired_harness_code": "void harness(void){ /* candidate */ }\n",
            "source_code_changes": [{"target": "poly.c", "proposed_change": "modify production implementation"}],
        }
        outputs, safety = a9.render_candidate_repair_outputs(
            layout=layout, cfg=cfg, repair_plan=plan,
            original_harness_path=original, original_harness_text=original_text,
        )
        require(original.read_text(encoding="utf-8") == original_text, "Original harness was silently overwritten")
        flags = {x.get("flag") for x in safety.get("safety_flags", [])}
        require("production_source_changes_proposed_but_not_allowed" in flags, "Forbidden production-code proposal was not elevated")
        require(outputs.get("repaired_harness") is not None, "Candidate repaired harness was not preserved separately")


def main() -> int:
    tests = [
        ("Frozen agent roles, exact Agent 11 structure, and structured disagreements", test_roles_and_structured_disagreements),
        ("Session 8 one-physical-file iteration manifest pointers", test_single_physical_iteration_manifests),
        ("Agent 11 raw-evidence grounding and fail-closed authoritative handoff", test_agent11_raw_evidence_selection_and_fail_closed_handoff),
        ("Reporting counts and mock-narrative promotion precision", test_reporting_counts_and_mock_promotion_precision),
        ("Agent 9 production-code and silent-overwrite guard", test_repair_never_modifies_production_source_by_default),
    ]
    for i, (label, func) in enumerate(tests, 1):
        print(f"[{i}/{len(tests)}] {label}...")
        func()
        print("  PASS")
    print("\nEIGHT-SESSION ARCHITECTURE CONFORMANCE PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
