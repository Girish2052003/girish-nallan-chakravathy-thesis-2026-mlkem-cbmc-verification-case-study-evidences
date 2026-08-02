#!/usr/bin/env python3
"""Final pre-API deployment gate for the controlled LLM/CBMC workflow."""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

try:
    import httpx
    from openai import OpenAI as SDKOpenAI
except ImportError as exc:
    raise SystemExit("Install pinned dependencies first: python -m pip install -r requirements.txt") from exc

from agents.common import llm_client as lc
from agents.common.formal_build import (
    build_cbmc_command_from_plan,
    create_formal_build_plan,
    validate_formal_build_plan,
)
from agents.common.run_layout import RunLayout
from agents.common.schemas import SPEC_SUMMARY_SCHEMA
from agents import spec_extraction_agent as a2
from agents import artifact_generation_agent as a5
from agents import review_critic_agent as a6
from agents import experiment_logger as a10
import preflight_first_api as preflight

PYTHON = sys.executable


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def read_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    require(isinstance(value, dict), f"Expected object: {path}")
    return value


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(cmd: list[str], *, cwd: Path = ROOT, expect: tuple[int, ...] = (0,), env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    proc = subprocess.run(cmd, cwd=str(cwd), text=True, capture_output=True, check=False, env=env)
    if proc.returncode not in expect:
        raise AssertionError(
            f"Command failed rc={proc.returncode}, expected={expect}: {' '.join(cmd)}\n"
            f"STDOUT:\n{proc.stdout}\nSTDERR:\n{proc.stderr}"
        )
    return proc


def sdk_response(text: str, response_id: str) -> httpx.Response:
    return httpx.Response(200, json={
        "id": response_id,
        "object": "response",
        "created_at": 1,
        "status": "completed",
        "error": None,
        "incomplete_details": None,
        "instructions": None,
        "max_output_tokens": 1200,
        "model": "deployment-test-model",
        "output": [{
            "id": f"msg_{response_id}",
            "type": "message",
            "status": "completed",
            "role": "assistant",
            "content": [{"type": "output_text", "text": text, "annotations": [], "logprobs": []}],
        }],
        "parallel_tool_calls": True,
        "previous_response_id": None,
        "reasoning": {"effort": None, "summary": None},
        "store": False,
        "temperature": 1.0,
        "text": {"format": {"type": "text"}, "verbosity": "medium"},
        "tool_choice": "auto",
        "tools": [],
        "top_p": 1.0,
        "truncation": "disabled",
        "usage": {
            "input_tokens": 10,
            "input_tokens_details": {"cached_tokens": 0},
            "output_tokens": 10,
            "output_tokens_details": {"reasoning_tokens": 0},
            "total_tokens": 20,
        },
        "user": None,
        "metadata": {},
    })


def test_real_sdk_path() -> None:
    captured: list[dict[str, Any]] = []
    call_count = 0

    with tempfile.TemporaryDirectory(prefix="real_sdk_gate_") as td:
        tmp = Path(td)
        evidence = tmp / "fips_excerpt.txt"
        prior = tmp / "agent1_candidate.json"
        fact = tmp / "measured_fact.json"
        evidence.write_text("RAW_PRIMARY_SENTINEL q=3329", encoding="utf-8")
        prior.write_text('{"candidate":"PRIOR_CONTEXT_SENTINEL"}', encoding="utf-8")
        fact.write_text('{"measured":"TRUSTED_FACT_SENTINEL"}', encoding="utf-8")

        cfg = a2.SpecExtractionConfig(tmp / "run", [evidence])
        valid = a2.build_mock_spec_summary(cfg, {"source_records": [], "combined_text_chars": 1, "combined_text_available": True})
        valid["mock"] = False
        valid["llm_call_executed"] = True
        valid["source_scope"]["provided_material_complete"] = True
        valid["source_scope"]["missing_or_unavailable_material"] = []
        valid["limitations"] = ["Synthetic local SDK transport test; not research evidence."]

        def handler(request: httpx.Request) -> httpx.Response:
            nonlocal call_count
            call_count += 1
            body = json.loads(request.content.decode("utf-8"))
            captured.append(body)
            return sdk_response("{}" if call_count == 1 else json.dumps(valid), f"resp_{call_count}")

        http_client = httpx.Client(transport=httpx.MockTransport(handler))
        original_openai = lc.OpenAI
        lc.OpenAI = lambda api_key: SDKOpenAI(api_key=api_key, http_client=http_client)
        previous_key = os.environ.get("OPENAI_API_KEY")
        os.environ["OPENAI_API_KEY"] = "sk-local-deployment-test-secret"
        try:
            layout = RunLayout(tmp / "run", create=True)
            client = lc.LLMClient({
                "mode": "real",
                "model": "deployment-test-model",
                "api_key_env": "OPENAI_API_KEY",
                "max_retries": 1,
                "retry_sleep_seconds": 0,
                "max_output_tokens": 1200,
                "attach_files_as_base64": False,
            })
            request = lc.LLMStageRequest(
                stage="02_spec_extraction",
                prompt_text="DEPLOYMENT_PROMPT_SENTINEL",
                output_filename="01_spec_summary.json",
                json_schema=SPEC_SUMMARY_SCHEMA,
                primary_evidence_files=[evidence],
                prior_authoritative_context_files=[prior],
                trusted_deterministic_fact_files=[fact],
                prior_authoritative_context_bundle={"candidate": "PRIOR_BUNDLE_SENTINEL"},
                trusted_deterministic_facts_bundle={"measured": "FACT_BUNDLE_SENTINEL"},
                deterministic_reference_bundle={"hint": "ADVISORY_SENTINEL"},
            )
            result = client.run_stage(layout, request)
        finally:
            lc.OpenAI = original_openai
            if previous_key is None:
                os.environ.pop("OPENAI_API_KEY", None)
            else:
                os.environ["OPENAI_API_KEY"] = previous_key
            http_client.close()

        require(result.success and result.llm_call_executed, f"Real SDK path failed: {result.error}")
        require(result.attempts == 2 and len(captured) == 2, "Retry path did not preserve two attempts")
        first_text = captured[0]["input"][0]["content"][0]["text"]
        second_text = captured[1]["input"][0]["content"][0]["text"]
        for sentinel in [
            "DEPLOYMENT_PROMPT_SENTINEL", "RAW_PRIMARY_SENTINEL", "PRIOR_CONTEXT_SENTINEL",
            "TRUSTED_FACT_SENTINEL", "PRIOR_BUNDLE_SENTINEL", "FACT_BUNDLE_SENTINEL", "ADVISORY_SENTINEL",
        ]:
            require(sentinel in first_text, f"API input omitted evidence sentinel: {sentinel}")
        require("[RETRY INSTRUCTION]" in second_text, "Retry request was not the exact corrected prompt")
        require(captured[1]["text"]["format"]["type"] == "json_schema", "Structured Outputs was not requested")
        require(captured[1]["text"]["format"]["strict"] is True, "Strict schema mode was not enabled")

        request_files = sorted((tmp / "run/stages/02_spec_extraction/prompt_package/api_requests").glob("*.json"))
        response_files = sorted((tmp / "run/stages/02_spec_extraction/llm_authoritative/api_responses").glob("*.json"))
        require(len(request_files) == 2 and len(response_files) == 2, "Per-attempt request/response records missing")
        snapshots_text = "\n".join(p.read_text(encoding="utf-8") for p in request_files)
        require("sk-local-deployment-test-secret" not in snapshots_text, "API key leaked into request snapshot")
        final_snapshot = read_json(request_files[-1])
        payload_bytes = json.dumps(final_snapshot["api_payload"], ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
        require(hashlib.sha256(payload_bytes).hexdigest() == final_snapshot["request_sha256"], "Exact request hash mismatch")
        require(Path(result.output_path).parent.name == "llm_authoritative", "Validated LLM output is not canonical authoritative output")
        manifest_path = layout.write_stage_manifest(
            "02_spec_extraction",
            primary_evidence_inputs=[evidence],
            prompt_package_outputs={},
            llm_authoritative_outputs={"spec_summary": Path(result.output_path)},
            validation_outputs={"llm_call_validation": Path(result.validation_path)},
        )
        stage_manifest = read_json(manifest_path)
        prompt_paths = set(stage_manifest["prompt_package_outputs"].values())
        response_paths = set(stage_manifest["llm_authoritative_outputs"].values())
        require(any("api_requests/attempt_01_request.json" in x for x in prompt_paths), "Stage manifest omitted exact API request attempt 1")
        require(any("api_requests/attempt_02_request.json" in x for x in prompt_paths), "Stage manifest omitted exact API request attempt 2")
        require(any("api_responses/attempt_01_response.json" in x for x in response_paths), "Stage manifest omitted raw API response attempt 1")
        require(any("api_responses/attempt_02_response.json" in x for x in response_paths), "Stage manifest omitted raw API response attempt 2")


def test_agent_roles_and_prompt_contract() -> None:
    llm_agents = [
        "spec_extraction_agent.py", "code_understanding_agent.py", "property_discovery_agent.py",
        "artifact_generation_agent.py", "review_critic_agent.py", "counterexample_analysis_agent.py",
        "repair_agent.py", "evaluation_reporter.py",
    ]
    for name in llm_agents:
        text = (ROOT / "agents" / name).read_text(encoding="utf-8")
        require("LLMStageRequest(" in text and "client.run_stage" in text, f"{name} is not API-backed")
    for name in ["master_orchestrator.py", "tool_execution_agent.py", "experiment_logger.py"]:
        text = (ROOT / "agents" / name).read_text(encoding="utf-8")
        require("client.run_stage" not in text, f"Deterministic stage unexpectedly calls the LLM: {name}")
    prompt = (ROOT / "agents/common/prompt_templates.py").read_text(encoding="utf-8")
    for phrase in [
        "authoritative LLM reasoning component", "Primary evidence outranks deterministic advisory material",
        "Do not claim proof", "Return only valid JSON",
    ]:
        require(phrase in prompt, f"Global prompt guardrail missing: {phrase}")

    orchestrator = (ROOT / "agents/master_orchestrator.py").read_text(encoding="utf-8")
    tool_call = orchestrator.index('self.run_agent("tool_execution", extra_args=tool_args)')
    analysis_call = orchestrator.index('self.run_agent("counterexample_analysis", extra_args=["--iteration", str(iteration)])', tool_call)
    pass_check = orchestrator.index("if self.cbmc_passed():", tool_call)
    require(tool_call < analysis_call < pass_check, "Agent 8 is not invoked for every completed tool result before success/failure branching")
    agent8 = (ROOT / "agents/counterexample_analysis_agent.py").read_text(encoding="utf-8")
    require("If CBMC succeeded, explain only what was checked" in agent8, "Agent 8 success-scope analysis guardrail missing")


def test_formal_build_and_review_semantics() -> None:
    with tempfile.TemporaryDirectory(prefix="formal_build_gate_") as td:
        tmp = Path(td)
        src = tmp / "poly.c"
        hdr = tmp / "poly.h"
        stub = tmp / "stub.c"
        harness = tmp / "harness.c"
        src.write_text('#include "poly.h"\nvoid mlk_poly_add(void){}\n', encoding="utf-8")
        hdr.write_text("void mlk_poly_add(void);\n", encoding="utf-8")
        stub.write_text("void external_stub(void){}\n", encoding="utf-8")
        harness.write_text('#include <assert.h>\nvoid mlk_poly_add(void);\nvoid harness(void){ mlk_poly_add(); assert(sizeof(int)>0); }\n', encoding="utf-8")
        config = {
            "project_root": str(tmp),
            "inputs": {"code_dir": str(tmp), "code_paths": [str(src), str(hdr)]},
            "tool_execution": {
                "source_files": [str(src)], "stub_files": [str(stub)], "include_paths": [str(tmp)],
                "defines": {"MLK_TEST": 1}, "working_directory": str(tmp), "cbmc_function": "harness",
                "unwind": 7, "extra_cbmc_args": ["--object-bits", "16"],
            },
        }
        plan = create_formal_build_plan(config, harness, target_function="mlk_poly_add")
        require(plan["validation"]["valid"], f"Formal build plan invalid: {plan['validation']}")
        cmd = build_cbmc_command_from_plan("cbmc", plan, default_checks=["--bounds-check"])
        for token in [str(harness), str(src), str(stub), "-I", str(tmp), "-D", "MLK_TEST=1", "--function", "harness", "--unwind", "7", "--unwinding-assertions", "--bounds-check"]:
            require(token in cmd, f"Formal CBMC command omitted: {token}")
        harness.write_text(harness.read_text() + "/* tampered */\n", encoding="utf-8")
        require(not validate_formal_build_plan(plan, harness)["valid"], "Harness tampering was not detected")

        harness.write_text('void mlk_poly_add(void); void harness(void){ mlk_poly_add(); }\n', encoding="utf-8")
        cfg = a6.ReviewCriticConfig(tmp, target_function="mlk_poly_add")
        base_plan = {"old_state_snapshot_plan": {"required": "not_required_for_selected_property", "reason": "local call check", "snapshot_items": []}}
        review = a6.deterministic_review(
            cfg=cfg, harness_path=harness, artifact_plan=base_plan,
            artifact_manifest={}, independence_audit={"copying_risk": "low_similarity_risk"},
        )
        require(not any(x.get("check") == "missing_old_state_snapshot" for x in review["issues"]), "Snapshot falsely required from field name")
        base_plan["old_state_snapshot_plan"]["required"] = "required_for_selected_property"
        review_required = a6.deterministic_review(
            cfg=cfg, harness_path=harness, artifact_plan=base_plan,
            artifact_manifest={}, independence_audit={"copying_risk": "low_similarity_risk"},
        )
        require(any(x.get("check") == "missing_old_state_snapshot" for x in review_required["issues"]), "Explicit snapshot requirement was not enforced")


def test_anti_copy_gate() -> None:
    with tempfile.TemporaryDirectory(prefix="copy_gate_") as td:
        tmp = Path(td)
        run = tmp / "run"
        layout = RunLayout(run, create=True)
        generated = tmp / "generated.c"
        reference = tmp / "existing_harness.c"
        code = "void mlk_poly_add(void); void harness(void){ mlk_poly_add(); }\n"
        generated.write_text(code, encoding="utf-8")
        reference.write_text(code, encoding="utf-8")
        cfg = a5.ArtifactGenerationConfig(run, target_function="mlk_poly_add")
        _, _, audit = a5.run_similarity_audit(layout, cfg, generated, [reference])
        require(audit["copying_risk"] == "high_similarity_risk", "Near-copy was not classified high risk")
        review = a6.deterministic_review(
            cfg=a6.ReviewCriticConfig(run, target_function="mlk_poly_add"),
            harness_path=generated,
            artifact_plan={"old_state_snapshot_plan": {"required": "not_required", "reason": "", "snapshot_items": []}},
            artifact_manifest={}, independence_audit=audit,
        )
        require(review["recommended_gate"] == "blocked", "Agent 6 did not block high similarity risk")


def mini_config(tmp: Path, run_id: str) -> Path:
    spec = tmp / "inputs/specs/fips.txt"
    code = tmp / "inputs/code/poly.c"
    header = tmp / "inputs/code/poly.h"
    spec.parent.mkdir(parents=True, exist_ok=True)
    code.parent.mkdir(parents=True, exist_ok=True)
    spec.write_text("ML-KEM controlled excerpt q=3329.\n", encoding="utf-8")
    header.write_text("void mlk_poly_add(void);\n", encoding="utf-8")
    code.write_text('#include "poly.h"\nvoid mlk_poly_add(void){}\n', encoding="utf-8")
    cfg = {
        "project_root": str(ROOT), "run_id": run_id, "output_root": str(tmp / "runs"),
        "target_scheme": "ML-KEM", "target_function": "mlk_poly_add", "target_topic": "deployment gate",
        "verification_tool": "CBMC", "artifact_type": "CBMC verification harness", "max_iterations": 0,
        "parallel_initial_agents": False, "strict_outputs": True,
        "inputs": {"spec_paths": [str(spec)], "code_dir": str(code.parent), "code_paths": [str(code), str(header)]},
        "llm": {"mode": "mock", "model": "mock-model"},
        "tool_execution": {"cbmc_binary": "cbmc", "cbmc_function": "harness", "dry_run": True, "force_run": False, "require_gate_approval": True},
        "experiment_logger": {"strict_required_stages": False, "allow_missing_previous_stages": True},
        "evaluation_reporter": {"allow_missing_experiment_log": False},
    }
    path = tmp / "config.json"
    write_json(path, cfg)
    return path


def test_layout_integrity_and_failed_run_provenance() -> None:
    with tempfile.TemporaryDirectory(prefix="layout_gate_") as td:
        tmp = Path(td)
        config = mini_config(tmp, "deployment_layout")
        run([PYTHON, str(ROOT / "agents/master_orchestrator.py"), "--config", str(config), "--dry-run"], expect=(2,))
        run_dir = tmp / "runs/deployment_layout"
        manifest = run_dir / "run_manifest.json"
        manifest_hash = sha(manifest)
        resolved = run_dir / "run_config.resolved.json"
        run([PYTHON, str(ROOT / "agents/spec_extraction_agent.py"), "--config", str(resolved), "--run-dir", str(run_dir), "--llm-mode", "mock"])
        run([PYTHON, str(ROOT / "agents/code_understanding_agent.py"), "--config", str(resolved), "--run-dir", str(run_dir), "--llm-mode", "mock"])
        require(sha(manifest) == manifest_hash, "Downstream agents rewrote mutable run_manifest.json")
        repo = run_dir / "stages/01_master_orchestrator/control/repository_provenance.json"
        require(repo.is_file(), "Repository provenance snapshot missing")
        for stage in ["01_master_orchestrator", "02_spec_extraction", "03_code_understanding"]:
            hdir = run_dir / "stages" / stage / "handoff"
            require(sorted(p.name for p in hdir.iterdir() if p.is_file()) == ["handoff_manifest.json"], f"Duplicate handoff files found in {stage}")
        allowed_root = {"events.jsonl", "run_config.resolved.json", "run_manifest.json", "status.json", "workflow_plan.json"}
        require({p.name for p in run_dir.iterdir() if p.is_file()} == allowed_root, "Unexpected root-level stage outputs")

        write_json(run_dir / "status.json", {"status": "orchestrator_failed", "run_id": "deployment_layout"})
        run([PYTHON, str(ROOT / "agents/experiment_logger.py"), "--config", str(resolved), "--run-dir", str(run_dir)])
        integrity_path = run_dir / "stages/10_experiment_logger/validation/09_log_integrity_validation.json"
        integrity = read_json(integrity_path)["content"]
        require(integrity["validation_status"] == "invalid", "Failed/manual run was not marked invalid")
        kinds = {x["kind"] for x in integrity["errors"]}
        require("orchestrator_failed_run" in kinds and "manual_or_external_logger_invocation" in kinds, "Failure provenance was not elevated")
        run([PYTHON, str(ROOT / "agents/evaluation_reporter.py"), "--config", str(resolved), "--run-dir", str(run_dir), "--llm-mode", "mock"])
        summary = read_json(run_dir / "stages/11_evaluation_reporter/final_report/10_evaluation_summary.json")
        require(summary["integrity_validation_status"] == "invalid", "Evaluator lost invalid integrity status")
        require(summary["candidate_llm_narrative_promoted"] is False, "Invalid run promoted LLM narrative")
        paragraph = (run_dir / "stages/11_evaluation_reporter/final_report/10_thesis_safe_paragraph.txt").read_text(encoding="utf-8").lower()
        require("invalid" in paragraph and "must not be presented" in paragraph, "Evaluator did not block thesis-result wording")


def test_logger_manifest_resolution() -> None:
    with tempfile.TemporaryDirectory(prefix="logger_manifest_gate_") as td:
        run = Path(td) / "run"
        RunLayout(run, create=True)
        tool_layout = RunLayout(run, create=False, active_iteration=2)
        status = tool_layout.tool_outputs_dir("07_tool_execution") / "06_cbmc_status.json"
        diag = tool_layout.diagnostics_dir("07_tool_execution") / "06_cbmc_diagnostics.json"
        write_json(status, {"result_classification": "verification_failed"})
        write_json(diag, {"result_classification": "verification_failed"})
        tool_layout.write_handoff_manifest(
            "07_tool_execution", outputs={"cbmc_status": status, "cbmc_diagnostics": diag},
            authoritative_source="deterministic_formal_tool_execution", next_stage_consumers=["10_experiment_logger"],
        )
        review_layout = RunLayout(run, create=False, active_iteration=2)
        gate = review_layout.validation_dir("06_review_critic") / "05_review_gate_decision.json"
        build = review_layout.validation_dir("06_review_critic") / "05_formal_build_plan.json"
        write_json(gate, {"final_gate": "approved_for_tool_execution", "tool_execution_allowed": True})
        write_json(build, {"validation": {"valid": True}})
        review_layout.write_handoff_manifest(
            "06_review_critic", outputs={"review_gate_decision": gate, "formal_build_plan": build},
            authoritative_source="llm_authoritative_plus_deterministic_gate", next_stage_consumers=["10_experiment_logger"],
        )
        tool_index = a10.build_tool_evidence_index(run)
        status_row = next(x for x in tool_index["evidence_files"] if x["evidence_key"] == "cbmc_status")
        require(status_row["exists"] and Path(status_row["path"]) == status.resolve(), "Logger did not resolve iteration tool output through manifest")
        require(tool_index["iteration_evidence"], "Logger omitted immutable tool iterations")
        gate_index = a10.build_gate_and_repair_index(run)
        require(gate_index["items"]["review_gate_decision"]["exists"], "Logger did not resolve iteration review gate")
        require(gate_index["items"]["formal_build_plan"]["exists"], "Logger did not resolve formal build plan")



def test_operational_preflight() -> None:
    class FakeUsage:
        def model_dump(self) -> dict[str, int]:
            return {"input_tokens": 5, "output_tokens": 1, "total_tokens": 6}

    class FakeResponse:
        id = "resp_operational_preflight"
        status = "completed"
        error = None
        model = "deployment-test-model"
        usage = FakeUsage()

    class FakeResponses:
        def create(self, **kwargs: Any) -> FakeResponse:
            require(kwargs.get("model") == "deployment-test-model", "Preflight used the wrong model")
            require(kwargs.get("store") is False, "Preflight connectivity response must not be stored remotely")
            return FakeResponse()

    class FakeOpenAI:
        def __init__(self, **kwargs: Any):
            require(bool(kwargs.get("api_key")), "Preflight omitted the API key from the SDK client")
            self.responses = FakeResponses()

    with tempfile.TemporaryDirectory(prefix="operational_preflight_gate_") as td:
        tmp = Path(td)
        repo = tmp / "mlkem-native"
        code_dir = repo / "src"
        spec_dir = tmp / "specs"
        code_dir.mkdir(parents=True)
        spec_dir.mkdir(parents=True)
        (code_dir / "poly.h").write_text("void mlk_poly_add(void);\n", encoding="utf-8")
        (code_dir / "poly.c").write_text('#include "poly.h"\nvoid mlk_poly_add(void){}\n', encoding="utf-8")
        (spec_dir / "fips.txt").write_text("Controlled preflight fixture.\n", encoding="utf-8")
        run(["git", "init", "-q", str(repo)], cwd=tmp)
        run(["git", "-C", str(repo), "config", "user.email", "deployment@example.invalid"], cwd=tmp)
        run(["git", "-C", str(repo), "config", "user.name", "Deployment Gate"], cwd=tmp)
        run(["git", "-C", str(repo), "add", "."], cwd=tmp)
        run(["git", "-C", str(repo), "commit", "-qm", "fixture"], cwd=tmp)
        revision = run(["git", "-C", str(repo), "rev-parse", "HEAD"], cwd=tmp).stdout.strip()
        fake_cbmc = tmp / "cbmc"
        fake_cbmc.write_text(
            "#!/usr/bin/env bash\n"
            "if [[ ${1:-} == --version ]]; then echo 'CBMC deployment-fixture'; exit 0; fi\n"
            "echo 'VERIFICATION SUCCESSFUL'\n"
            "exit 0\n",
            encoding="utf-8",
        )
        fake_cbmc.chmod(0o755)
        cfg = {
            "project_root": str(tmp), "run_id": "first_real_preflight", "output_root": "runs",
            "target_scheme": "ML-KEM", "target_function": "mlk_poly_add", "target_topic": "preflight",
            "verification_tool": "CBMC", "artifact_type": "CBMC verification harness", "max_iterations": 0,
            "parallel_initial_agents": False, "strict_outputs": True,
            "inputs": {
                "spec_paths": [str(spec_dir / "fips.txt")],
                "code_dir": str(code_dir),
                "code_paths": [str(code_dir / "poly.c"), str(code_dir / "poly.h")],
            },
            "llm": {"mode": "real", "model": "deployment-test-model", "api_key_env": "OPENAI_API_KEY"},
            "tool_execution": {
                "cbmc_binary": str(fake_cbmc), "cbmc_function": "harness", "dry_run": False,
                "force_run": False, "require_gate_approval": True, "source_files": [str(code_dir / "poly.c")],
                "stub_files": [], "include_paths": [str(code_dir)], "defines": [],
                "working_directory": str(repo), "extra_cbmc_args": [], "unwind": 3,
            },
            "provenance": {"repository_paths": [str(repo)], "source_revision": revision},
        }
        cfg_path = tmp / "config.json"
        write_json(cfg_path, cfg)
        previous_key = os.environ.get("OPENAI_API_KEY")
        os.environ["OPENAI_API_KEY"] = "sk-local-preflight-test"
        try:
            rc, result = preflight.run_preflight(cfg_path, api_client_factory=FakeOpenAI)
        finally:
            if previous_key is None:
                os.environ.pop("OPENAI_API_KEY", None)
            else:
                os.environ["OPENAI_API_KEY"] = previous_key
        require(rc == 0, f"Operational preflight failed: {result['errors']}")
        require(result["approved_for_one_controlled_first_experiment"] is True, "Valid preflight was not authorized")
        require(result["checks"]["live_api_access"]["passed"] is True, "Live API access logic was not exercised")
        require(result["checks"]["live_cbmc_smoke"]["passed"] is True, "Live CBMC smoke logic was not exercised")
        require(result["checks"]["live_api_access"]["thesis_evidence_sent"] is False, "Connectivity probe sent thesis evidence")


def test_package_contract() -> None:
    req = ROOT / "requirements.txt"
    bootstrap = ROOT / "bootstrap_ubuntu.sh"
    preflight = ROOT / "preflight_first_api.py"
    require(req.is_file() and bootstrap.is_file() and preflight.is_file(), "Pinned dependency/bootstrap/preflight files missing")
    text = req.read_text(encoding="utf-8")
    for pin in ["openai==", "httpx==", "jsonschema==", "pypdf=="]:
        require(pin in text, f"Dependency is not pinned: {pin}")
    for cfg_name in ["CONFIG_TEMPLATE_CANONICAL.json", "CONFIG_TEMPLATE_FIRST_API_PREFLIGHT.json"]:
        cfg = read_json(ROOT / "configs" / cfg_name)
        tool = cfg.get("tool_execution", {})
        for key in ["source_files", "include_paths", "defines", "working_directory"]:
            require(key in tool, f"{cfg_name} lacks formal-build field {key}")
        require("provenance" in cfg, f"{cfg_name} lacks repository provenance block")


def main() -> int:
    tests = [
        ("Actual OpenAI SDK path, retries, exact request/response evidence", test_real_sdk_path),
        ("Agent roles and global prompt/evidence contract", test_agent_roles_and_prompt_contract),
        ("Formal build plan, binding, and old-state review semantics", test_formal_build_and_review_semantics),
        ("Anti-copy similarity and critic blocking", test_anti_copy_gate),
        ("Canonical layout, stable control hashes, failed-run provenance", test_layout_integrity_and_failed_run_provenance),
        ("Logger manifest resolution for iteration evidence", test_logger_manifest_resolution),
        ("Operational first-API preflight", test_operational_preflight),
        ("Installable package and pinned dependency contract", test_package_contract),
    ]
    for index, (label, func) in enumerate(tests, start=1):
        print(f"[{index}/{len(tests)}] {label}...")
        func()
        print("  PASS")
    print("\nFINAL DEPLOYMENT GATE PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
