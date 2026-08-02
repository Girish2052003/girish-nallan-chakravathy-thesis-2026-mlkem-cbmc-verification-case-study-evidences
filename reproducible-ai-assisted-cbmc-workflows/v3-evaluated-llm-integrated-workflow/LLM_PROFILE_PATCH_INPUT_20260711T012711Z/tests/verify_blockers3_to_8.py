#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, Iterable

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))
PYTHON = sys.executable


def run(cmd: list[str], *, expect: Iterable[int] = (0,), cwd: Path = ROOT) -> subprocess.CompletedProcess[str]:
    proc = subprocess.run(cmd, cwd=str(cwd), text=True, capture_output=True, check=False)
    if proc.returncode not in set(expect):
        raise AssertionError(
            f"Command failed (rc={proc.returncode}, expected={tuple(expect)}): {' '.join(cmd)}\n"
            f"STDOUT:\n{proc.stdout}\nSTDERR:\n{proc.stderr}"
        )
    return proc


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def sha(path: Path) -> str:
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


def hash_tree(path: Path) -> Dict[str, str]:
    if not path.exists():
        return {}
    return {str(p.relative_to(path)): sha(p) for p in sorted(path.rglob("*")) if p.is_file()}


def handoff_path(run_dir: Path, stage: str, key: str) -> Path:
    stage_dir = run_dir / "stages" / stage
    manifest = read_json(stage_dir / "handoff" / "handoff_manifest.json")
    rel = manifest["handoff_outputs"][key]
    return (stage_dir / rel).resolve()


def base_config(tmp: Path, *, run_id: str, fake_cbmc: Path | None = None, dry_run: bool = True, max_iterations: int = 1) -> dict:
    inputs = tmp / "inputs"
    spec_dir = inputs / "specs"
    code_dir = inputs / "code"
    spec_dir.mkdir(parents=True, exist_ok=True)
    code_dir.mkdir(parents=True, exist_ok=True)
    (spec_dir / "fips203_excerpt.txt").write_text(
        "ML-KEM polynomial coefficients are represented modulo q. This is a controlled wiring-test excerpt.\n",
        encoding="utf-8",
    )
    (code_dir / "poly.h").write_text(
        "#include <stdint.h>\nvoid mlk_poly_add(int16_t r[256], const int16_t a[256], const int16_t b[256]);\n",
        encoding="utf-8",
    )
    (code_dir / "poly.c").write_text(
        '#include "poly.h"\nvoid mlk_poly_add(int16_t r[256], const int16_t a[256], const int16_t b[256]) {\n'
        '  for (int i = 0; i < 256; ++i) r[i] = a[i] + b[i];\n}\n',
        encoding="utf-8",
    )
    return {
        "project_root": str(ROOT),
        "run_id": run_id,
        "output_root": str(tmp / "runs"),
        "target_scheme": "ML-KEM",
        "target_function": "mlk_poly_add",
        "target_topic": "ML-KEM polynomial addition",
        "verification_tool": "CBMC",
        "artifact_type": "CBMC verification harness",
        "max_iterations": max_iterations,
        "parallel_initial_agents": False,
        "strict_outputs": True,
        "inputs": {
            "spec_paths": [str(spec_dir / "fips203_excerpt.txt")],
            "code_dir": str(code_dir),
            "code_paths": [str(code_dir / "poly.c"), str(code_dir / "poly.h")],
        },
        "llm": {"mode": "mock", "model": "mock-model"},
        "tool_execution": {
            "cbmc_binary": str(fake_cbmc) if fake_cbmc else "cbmc",
            "cbmc_function": "harness",
            "dry_run": dry_run,
            "force_run": True,
            "require_gate_approval": True,
            "timeout_seconds": 30,
        },
        "counterexample_analysis": {"allow_missing_tool_outputs": False},
        "repair_refinement": {"allow_missing_inputs": False, "render_candidate_repaired_harness": True},
        "experiment_logger": {"strict_required_stages": False, "allow_missing_previous_stages": True},
        "evaluation_reporter": {"allow_missing_experiment_log": False},
    }


def main() -> int:
    print("[1/8] CLI contracts for Agents 6-9...")
    cli_expectations = {
        "review_critic_agent.py": ["--iteration", "--artifact"],
        "tool_execution_agent.py": ["--iteration", "--artifact"],
        "counterexample_analysis_agent.py": ["--iteration"],
        "repair_agent.py": ["--iteration", "--reason", "critic_review", "counterexample_analysis"],
    }
    for script, needles in cli_expectations.items():
        proc = run([PYTHON, str(ROOT / "agents" / script), "--help"])
        text = proc.stdout + proc.stderr
        for needle in needles:
            assert needle in text, f"{script} missing {needle}"
    neg = run([PYTHON, str(ROOT / "agents" / "review_critic_agent.py"), "--iteration", "-1"], expect=(2,))
    assert "must be >= 0" in (neg.stdout + neg.stderr)
    print("  PASS arguments are accepted, documented, and range-checked")

    with tempfile.TemporaryDirectory(prefix="blockers3_8_") as td:
        tmp = Path(td)
        configs = tmp / "configs"
        configs.mkdir()

        print("[2/8] Conservative mock pipeline and Agent 10 handoff contract...")
        mock_cfg_path = configs / "full_mock.json"
        mock_cfg = base_config(tmp, run_id="full_mock", dry_run=True, max_iterations=1)
        write_json(mock_cfg_path, mock_cfg)
        proc = run(
            [PYTHON, str(ROOT / "agents/master_orchestrator.py"), "--config", str(mock_cfg_path)],
            expect=(2,),
        )
        mock_run = tmp / "runs" / "full_mock"
        summary = read_json(mock_run / "final" / "final_run_summary.json")
        results = {x["name"]: x for x in summary["agent_results"]}
        expected_agents = {
            "spec_extraction", "code_understanding", "property_discovery", "artifact_generation",
            "critic_review", "repair", "experiment_logger", "evaluation_reporter",
        }
        assert expected_agents.issubset(results)
        assert all(results[name]["status"] == "passed" for name in expected_agents)
        assert "tool_execution" not in results, "Mock critic must not authorize CBMC execution"
        assert "counterexample_analysis" not in results, "Counterexample analysis must not run without tool evidence"
        assert results["experiment_logger"]["missing_handoff_outputs"] == []
        logger_manifest = read_json(mock_run / "stages/10_experiment_logger/handoff/handoff_manifest.json")
        assert {"experiment_log", "artifact_inventory", "file_index", "checksum_manifest", "checksums"}.issubset(logger_manifest["handoff_outputs"])
        assert logger_manifest["handoff_outputs"]["artifact_inventory"] == logger_manifest["handoff_outputs"]["file_index"]
        assert logger_manifest["handoff_outputs"]["checksum_manifest"] == logger_manifest["handoff_outputs"]["checksums"]
        evaluator_manifest = read_json(mock_run / "stages/11_evaluation_reporter/handoff/handoff_manifest.json")
        assert evaluator_manifest["handoff_outputs"]["evaluation_report_markdown"] == evaluator_manifest["handoff_outputs"]["final_report"]
        assert summary["final_status"] == "completed_with_failures_or_unresolved_items"
        allowed_root = {"events.jsonl", "run_config.resolved.json", "run_manifest.json", "status.json", "workflow_plan.json"}
        assert {p.name for p in mock_run.iterdir() if p.is_file()} == allowed_root
        for handoff_dir in (mock_run / "stages").rglob("handoff"):
            if handoff_dir.is_dir():
                handoff_files = sorted(p.name for p in handoff_dir.iterdir() if p.is_file())
                assert handoff_files in ([], ["handoff_manifest.json"]), (handoff_dir, handoff_files)
        print("  PASS mock review blocks invalid downstream execution; finalizers, logger contract, and pointer-only handoffs remain intact")

        print("[3/8] CBMC result_classification success parsing...")
        from agents.master_orchestrator import MasterOrchestrator
        from agents.common.run_layout import RunLayout
        fake_status_dir = mock_run / "stages/07_tool_execution/tool_outputs"
        fake_status_dir.mkdir(parents=True, exist_ok=True)
        fake_status = fake_status_dir / "06_cbmc_status.json"
        write_json(fake_status, {"result_classification": "verification_successful"})
        RunLayout(mock_run, create=False).write_handoff_manifest(
            "07_tool_execution",
            outputs={"cbmc_status": fake_status},
            authoritative_source="deterministic_formal_tool_execution",
            next_stage_consumers=["01_master_orchestrator"],
        )
        checker = MasterOrchestrator(mock_run / "run_config.resolved.json")
        checker.layout = RunLayout(mock_run, create=False)
        assert checker.cbmc_passed() is True
        write_json(fake_status, {"result_classification": "verification_failed"})
        RunLayout(mock_run, create=False).write_handoff_manifest(
            "07_tool_execution",
            outputs={"cbmc_status": fake_status},
            authoritative_source="deterministic_formal_tool_execution",
            next_stage_consumers=["01_master_orchestrator"],
        )
        assert checker.cbmc_passed() is False
        print("  PASS orchestrator consumes Agent 7 result_classification correctly")

        print("[4/8] Repaired-harness propagation through review and tool execution...")
        iteration0_review = mock_run / "stages/06_review_critic/iterations/iteration_00"
        iteration0_tool = mock_run / "stages/07_tool_execution/iterations/iteration_00"
        review_hashes_before = hash_tree(iteration0_review)
        tool_hashes_before = hash_tree(iteration0_tool)

        repaired = tmp / "candidate_repaired_harness.c"
        repaired.write_text(
            "/* UNIQUE_REPAIRED_ARTIFACT_MARKER */\n"
            "#include <stdint.h>\n"
            "void mlk_poly_add(int16_t r[256], const int16_t a[256], const int16_t b[256]);\n"
            "void harness(void) {\n"
            "  int16_t r[256] = {0}, a[256] = {0}, b[256] = {0};\n"
            "  mlk_poly_add(r, a, b);\n"
            "}\n",
            encoding="utf-8",
        )
        resolved_cfg = mock_run / "run_config.resolved.json"
        run([
            PYTHON, str(ROOT / "agents/review_critic_agent.py"),
            "--config", str(resolved_cfg), "--run-dir", str(mock_run),
            "--iteration", "1", "--artifact", str(repaired), "--llm-mode", "mock",
        ])
        reviewed = handoff_path(mock_run, "06_review_critic", "generated_harness_under_review")
        assert reviewed == repaired.resolve()
        run([
            PYTHON, str(ROOT / "agents/tool_execution_agent.py"),
            "--config", str(resolved_cfg), "--run-dir", str(mock_run),
            "--iteration", "1", "--artifact", str(repaired), "--dry-run", "--force-run",
        ])
        tool_input = read_json(
            mock_run / "stages/07_tool_execution/iterations/iteration_01/tool_inputs/06_harness_input_manifest.json"
        )
        assert Path(tool_input["harness_path"]).resolve() == repaired.resolve()
        assert tool_input["harness_sha256"] == sha(repaired)
        command_manifest = read_json(
            mock_run / "stages/07_tool_execution/iterations/iteration_01/tool_inputs/06_tool_command_manifest.json"
        )
        assert command_manifest["artifact_review_binding"]["paths_match"] is True
        print("  PASS the exact repaired file reviewed by Agent 6 is the file selected by Agent 7")

        print("[5/8] Review-to-tool artifact binding rejects substitutions...")
        substituted = tmp / "unreviewed_substitution.c"
        substituted.write_text("void harness(void){}\n", encoding="utf-8")
        bad = run([
            PYTHON, str(ROOT / "agents/tool_execution_agent.py"),
            "--config", str(resolved_cfg), "--run-dir", str(mock_run),
            "--iteration", "2", "--artifact", str(substituted), "--dry-run", "--force-run",
        ], expect=(1,))
        status = read_json(mock_run / "stages/07_tool_execution/iterations/iteration_02/logs/07_tool_execution_status.json")
        assert status["success"] is False
        assert "Artifact-review binding violation" in status["errors"][0]["message"]
        print("  PASS Agent 7 fails closed when --artifact differs from Agent 6's reviewed harness")

        print("[6/8] Dual repair modes with branch-specific required evidence...")
        stage7 = mock_run / "stages/07_tool_execution"
        stage8 = mock_run / "stages/08_counterexample_analysis"
        stage7_saved = tmp / "stage7_saved"
        stage8_saved = tmp / "stage8_saved"
        stage7.rename(stage7_saved)
        stage8.rename(stage8_saved)
        try:
            run([
                PYTHON, str(ROOT / "agents/repair_agent.py"),
                "--config", str(resolved_cfg), "--run-dir", str(mock_run),
                "--iteration", "3", "--reason", "critic_review", "--llm-mode", "mock",
            ])
            critic_repair_manifest = read_json(mock_run / "stages/09_repair_refinement/handoff/handoff_manifest.json")
            assert critic_repair_manifest["iteration_reason"] == "critic_review"
            assert "repair_plan" in critic_repair_manifest["handoff_outputs"]
            run([
                PYTHON, str(ROOT / "agents/repair_agent.py"),
                "--config", str(resolved_cfg), "--run-dir", str(mock_run),
                "--iteration", "4", "--reason", "counterexample_analysis", "--llm-mode", "mock",
            ], expect=(1,))
            cex_status = read_json(
                mock_run / "stages/09_repair_refinement/iterations/iteration_04/logs/09_repair_refinement_status.json"
            )
            assert "counterexample_analysis" in cex_status["errors"][0]["message"]
        finally:
            if stage7.exists():
                shutil.rmtree(stage7)
            if stage8.exists():
                shutil.rmtree(stage8)
            stage7_saved.rename(stage7)
            stage8_saved.rename(stage8)
        print("  PASS critic-triggered repair works without Agent 8; counterexample mode still requires Agent 8")

        print("[7/8] Iteration evidence is immutable and separately addressable...")
        assert review_hashes_before == hash_tree(iteration0_review), "Agent 6 iteration 00 evidence changed"
        assert tool_hashes_before == hash_tree(iteration0_tool), "Agent 7 iteration 00 evidence changed"
        assert (mock_run / "stages/06_review_critic/iterations/iteration_00/handoff/handoff_manifest.json").exists()
        assert (mock_run / "stages/06_review_critic/iterations/iteration_01/handoff/handoff_manifest.json").exists()
        assert (mock_run / "stages/07_tool_execution/iterations/iteration_01/handoff/handoff_manifest.json").exists()
        assert (mock_run / "stages/07_tool_execution/iterations/iteration_02/logs/07_tool_execution_status.json").exists()
        print("  PASS prior evidence remains byte-identical while later review/tool attempts are preserved separately")

        print("[8/8] Regression gates for Blockers 1 and 2...")
        run([PYTHON, str(ROOT / "tests/verify_blocker1_schemas.py")])
        run([PYTHON, str(ROOT / "tests/verify_blocker2_config_contract.py")])
        print("  PASS previous schema and configuration guarantees remain intact")

    print("\nBLOCKERS 3-8 PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
