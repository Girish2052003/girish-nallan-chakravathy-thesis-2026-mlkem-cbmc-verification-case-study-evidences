#!/usr/bin/env python3
"""End-to-end mock routing for native-contract and analysis-only campaigns."""
from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON = sys.executable


def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def read_content(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))
    content = data.get("content")
    return content if isinstance(content, dict) else data


def make_config(tmp: Path, family: str, target: str, source: Path, spec: Path) -> Path:
    analysis_only = family == "P19"
    config = {
        "project_root": str(ROOT),
        "run_id": f"campaign_{family.lower()}_mock",
        "output_root": str(tmp / "runs"),
        "target_scheme": "ML-KEM",
        "target_function": target,
        "target_topic": "native loop contract" if family == "P12" else "secret-independent analysis support",
        "verification_tool": "CBMC",
        "artifact_type": "candidate property campaign artefact",
        "max_iterations": 0,
        "parallel_initial_agents": False,
        "strict_outputs": True,
        "inputs": {
            "spec_paths": [str(spec)],
            "code_dir": str(source.parent),
            "code_paths": [str(source)],
        },
        "property_campaign": {
            "property_family_id": family,
            "verification_strategy": "auto",
            "allow_analysis_only": analysis_only,
        },
        "llm": {
            "mode": "mock",
            "model": "mock-model",
            "max_retries": 1,
            "max_output_tokens": 2000,
        },
        "tool_execution": {
            "cbmc_binary": "cbmc",
            "goto_cc_binary": "goto-cc",
            "goto_instrument_binary": "goto-instrument",
            "cbmc_function": "harness",
            "dry_run": True,
            "force_run": False,
            "require_gate_approval": True,
            "timeout_seconds": 30,
            "source_files": [str(source)],
            "stub_files": [],
            "include_paths": [str(source.parent)],
            "defines": [],
            "working_directory": str(source.parent),
            "extra_cbmc_args": [],
            "unwind": None,
        },
    }
    path = tmp / f"{family.lower()}.json"
    write_json(path, config)
    return path


def run_campaign(tmp: Path, family: str) -> Path:
    inputs = tmp / family / "inputs"
    code = inputs / "code"
    specs = inputs / "specs"
    code.mkdir(parents=True)
    specs.mkdir(parents=True)
    spec = specs / "fips.txt"
    spec.write_text("Controlled FIPS 203 evidence for mock routing only.\n", encoding="utf-8")
    source = code / "target.c"
    if family == "P12":
        target = "poly_add"
        source.write_text(
            "void poly_add(int *r, const int *a, const int *b) { "
            "for (int i=0; i<4; ++i) { r[i]=a[i]+b[i]; } }\n",
            encoding="utf-8",
        )
    else:
        target = "selected_C_functions"
        source.write_text(
            "int selected_C_functions(const unsigned char *s) { return s[0] ? 1 : 0; }\n",
            encoding="utf-8",
        )
    config = make_config(tmp / family, family, target, source, spec)
    proc = subprocess.run(
        [PYTHON, str(ROOT / "agents/master_orchestrator.py"), "--config", str(config)],
        cwd=str(ROOT), text=True, capture_output=True, check=False,
    )
    if proc.returncode != 2:
        raise AssertionError(
            f"{family} mock campaign expected exit 2, got {proc.returncode}\n"
            f"STDOUT:\n{proc.stdout}\nSTDERR:\n{proc.stderr}"
        )
    return tmp / family / "runs" / f"campaign_{family.lower()}_mock"


def assert_common(
    run: Path,
    family: str,
    *,
    expected_stopped_reason: str = (
        "critic_requested_repair_but_iteration_limit_reached"
    ),
) -> None:
    summary = json.loads((run / "final/final_run_summary.json").read_text(encoding="utf-8"))
    assert summary["verification_passed_selected_properties"] is False
    assert summary["final_status"] == "completed_with_failures_or_unresolved_items"
    assert summary["stopped_reason"] == expected_stopped_reason, (
        family,
        summary["stopped_reason"],
        expected_stopped_reason,
    )
    for stage in ["02_spec_extraction", "03_code_understanding", "04_property_discovery", "05_artifact_generation", "06_review_critic", "10_experiment_logger", "11_evaluation_reporter"]:
        assert (run / "stages" / stage / "handoff" / "handoff_manifest.json").exists(), stage
    for rel in [
        "stages/04_property_discovery/validation/03_property_campaign_validation.json",
        "stages/05_artifact_generation/validation/04_property_campaign_artifact_validation.json",
        "stages/06_review_critic/iterations/iteration_00/validation/05_property_campaign_review_validation.json",
    ]:
        value = read_content(run / rel)
        assert value["valid"] is True, (family, rel, value)
    assert not (run / "stages/07_tool_execution/stage_manifest.json").exists()


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="property_campaign_orchestration_") as td:
        tmp = Path(td)
        print("[1/2] Native loop-contract campaign routing...")
        p12 = run_campaign(tmp, "P12")
        assert_common(p12, "P12")
        plan12 = read_content(p12 / "stages/05_artifact_generation/llm_authoritative/04_artifact_plan.json")
        assert plan12["verification_strategy"] == "native_loop_contract"
        assert plan12["selected_property"]["property"]["property_family_id"] == "P12"
        contract_validation = read_content(p12 / "stages/05_artifact_generation/validation/04_contract_plan_validation.json")
        assert contract_validation["valid"] is False
        print("  PASS campaign identity preserved; mock incomplete contract is review-blocked, not executed")

        print("[2/2] Analysis-only constant-time support routing...")
        p19 = run_campaign(tmp, "P19")
        assert_common(
            p19,
            "P19",
            expected_stopped_reason=(
                "critic_requested_human_review_before_tool"
            ),
        )
        plan19 = read_content(p19 / "stages/05_artifact_generation/llm_authoritative/04_artifact_plan.json")
        assert plan19["verification_strategy"] == "analysis_only_no_formal_claim"
        assert plan19["analysis_only_plan"]["enabled"] is True
        assert plan19["analysis_only_plan"]["formal_claim_prohibited"] is True
        print("  PASS analysis-only campaign cannot silently become a CBMC proof claim")

    print("\nPROPERTY CAMPAIGN ORCHESTRATION PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
