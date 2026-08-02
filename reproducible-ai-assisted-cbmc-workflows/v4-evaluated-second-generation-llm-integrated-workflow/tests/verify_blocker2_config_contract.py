#!/usr/bin/env python3
"""Blocker 2 verification suite: canonical config contract and path wiring."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.config_contract import (  # noqa: E402
    CONFIG_SCHEMA_VERSION,
    ConfigContractError,
    canonical_input_summary,
    load_normalized_config,
    validate_pipeline_config,
)

FIXTURE_ROOT = ROOT / "tests" / "fixtures" / "project"
CONFIGS = FIXTURE_ROOT / "configs"
RUNS = FIXTURE_ROOT / "runs"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def read_json(path: Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    require(isinstance(value, dict), f"Expected JSON object: {path}")
    return value


def run(cmd: list[str], *, cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=str(cwd), text=True, capture_output=True, check=False)


def main() -> int:
    print("[1/7] Canonical relative-path normalization from a foreign working directory...")
    previous = Path.cwd()
    os.chdir("/tmp")
    try:
        canonical = load_normalized_config(CONFIGS / "canonical.json")
    finally:
        os.chdir(previous)

    expected_spec = (FIXTURE_ROOT / "inputs/specs/fips203_excerpt.txt").resolve()
    expected_c = (FIXTURE_ROOT / "inputs/code/poly.c").resolve()
    expected_h = (FIXTURE_ROOT / "inputs/code/poly.h").resolve()
    expected_inc = (FIXTURE_ROOT / "inputs/code/zetas.inc").resolve()
    expected_run = (FIXTURE_ROOT / "runs/blocker2_canonical_run").resolve()

    require(canonical["config_schema_version"] == CONFIG_SCHEMA_VERSION, "Wrong schema version")
    require(Path(canonical["project_root"]) == FIXTURE_ROOT.resolve(), "Wrong inferred project root")
    require(Path(canonical["spec_file"]) == expected_spec, "Wrong canonical spec_file")
    require(Path(canonical["source_file"]) == expected_c, "Wrong canonical source_file")
    require(Path(canonical["run_dir"]) == expected_run, "Wrong canonical run_dir")
    require(
        [Path(p) for p in canonical["inputs"]["code_paths"]] == [expected_c, expected_h, expected_inc],
        "Code paths were not deterministic/de-duplicated",
    )
    report = validate_pipeline_config(canonical, check_input_files=True)
    report.raise_for_errors()
    print("  PASS canonical config, project-root path resolution, directory discovery, and validation")

    print("[2/7] Legacy top-level aliases normalize to the same canonical shape...")
    legacy = load_normalized_config(CONFIGS / "legacy.json")
    legacy_report = validate_pipeline_config(legacy, check_input_files=True)
    legacy_report.raise_for_errors()
    require(legacy["inputs"]["primary_spec"] == legacy["spec_file"], "Legacy spec alias not synchronized")
    require(legacy["inputs"]["primary_source"] == legacy["source_file"], "Legacy source alias not synchronized")
    require(legacy["inputs"]["spec_paths"] == [str(expected_spec)], "Legacy spec list incorrect")
    require(legacy["inputs"]["code_paths"] == [str(expected_c)], "Legacy code list incorrect")
    print("  PASS supported legacy aliases remain backwards compatible")

    print("[3/7] Conflicting aliases are rejected instead of silently choosing one...")
    conflict = load_normalized_config(CONFIGS / "conflict.json")
    conflict_report = validate_pipeline_config(conflict, check_input_files=False)
    require(not conflict_report.valid, "Conflicting config unexpectedly validated")
    rendered_conflicts = "\n".join(conflict_report.errors)
    require("Conflicting primary specification aliases" in rendered_conflicts, "Spec conflict not reported")
    require("Conflicting primary source aliases" in rendered_conflicts, "Source conflict not reported")
    try:
        conflict_report.raise_for_errors()
    except ConfigContractError:
        pass
    else:
        raise AssertionError("Conflicting config did not raise ConfigContractError")
    print("  PASS contradictory primary paths fail closed with explicit diagnostics")

    print("[4/7] Missing files and invalid input evidence are rejected...")
    missing = load_normalized_config(CONFIGS / "missing.json")
    missing_report = validate_pipeline_config(missing, check_input_files=True)
    require(not missing_report.valid, "Missing files unexpectedly validated")
    rendered_missing = "\n".join(missing_report.errors)
    require("does not exist" in rendered_missing, "Missing-file diagnostics absent")

    invalid_iterations = dict(canonical)
    invalid_iterations["max_iterations"] = "2"
    iteration_report = validate_pipeline_config(invalid_iterations, check_input_files=False)
    require(not iteration_report.valid, "String max_iterations unexpectedly validated")
    require(any("max_iterations" in error for error in iteration_report.errors), "Iteration type diagnostic absent")

    invalid_inputs_path = CONFIGS / "invalid_inputs_runtime.json"
    invalid_inputs_path.write_text(json.dumps({"inputs": ["not", "an", "object"]}), encoding="utf-8")
    try:
        load_normalized_config(invalid_inputs_path)
    except ConfigContractError:
        pass
    else:
        raise AssertionError("Non-object inputs unexpectedly normalized")
    finally:
        invalid_inputs_path.unlink(missing_ok=True)
    print("  PASS missing evidence and invalid field types are detected before agent execution")

    print("[5/7] Orchestrator dry-run writes one canonical resolved config and snapshots all inputs...")
    shutil.rmtree(RUNS, ignore_errors=True)
    orchestrator_cmd = [
        sys.executable,
        str(ROOT / "agents/master_orchestrator.py"),
        "--config",
        str(CONFIGS / "canonical.json"),
        "--dry-run",
        "--strict-outputs",
    ]
    proc = run(orchestrator_cmd, cwd=Path("/tmp"))
    require(proc.returncode == 2, f"Dry-run should exit 2, got {proc.returncode}:\n{proc.stderr}")

    resolved_path = expected_run / "run_config.resolved.json"
    require(resolved_path.exists(), "Orchestrator did not write resolved config")
    resolved = read_json(resolved_path)
    resolved_report = validate_pipeline_config(resolved, check_input_files=True)
    resolved_report.raise_for_errors()
    require(Path(resolved["project_root"]) == FIXTURE_ROOT.resolve(), "Resolved config lost project root")
    require(Path(resolved["run_dir"]) == expected_run, "Resolved config lost run directory")
    summary = resolved.get("canonical_input_summary", canonical_input_summary(resolved))
    require(summary["primary_spec"] == str(expected_spec), "Resolved primary spec incorrect")
    require(summary["primary_source"] == str(expected_c), "Resolved primary source incorrect")

    snapshot = expected_run / "stages/01_master_orchestrator/control/input_snapshot"
    names = sorted(path.name for path in snapshot.iterdir() if path.is_file())
    require("canonical.json" in names, "Original config was not snapshotted")
    require(any(name.startswith("spec_01_") for name in names), "Specification snapshot missing")
    require(any(name.startswith("code_01_") for name in names), "Primary source snapshot missing")
    require(any(name.endswith("poly.h") for name in names), "Header snapshot missing")
    require(any(name.endswith("zetas.inc") for name in names), "Include snapshot missing")
    print("  PASS resolved config and complete deterministic input snapshot")

    print("[6/7] Agents 2 and 3 consume the same resolved canonical config...")
    agent2 = run(
        [
            sys.executable,
            str(ROOT / "agents/spec_extraction_agent.py"),
            "--config",
            str(resolved_path),
            "--run-dir",
            str(expected_run),
            "--llm-mode",
            "mock",
        ],
        cwd=Path("/tmp"),
    )
    require(agent2.returncode == 0, f"Agent 2 failed:\nSTDOUT:\n{agent2.stdout}\nSTDERR:\n{agent2.stderr}")

    agent3 = run(
        [
            sys.executable,
            str(ROOT / "agents/code_understanding_agent.py"),
            "--config",
            str(resolved_path),
            "--run-dir",
            str(expected_run),
            "--llm-mode",
            "mock",
        ],
        cwd=Path("/tmp"),
    )
    require(agent3.returncode == 0, f"Agent 3 failed:\nSTDOUT:\n{agent3.stdout}\nSTDERR:\n{agent3.stderr}")

    handoff2 = expected_run / "stages/02_spec_extraction/handoff/handoff_manifest.json"
    handoff3 = expected_run / "stages/03_code_understanding/handoff/handoff_manifest.json"
    require(handoff2.exists(), "Agent 2 handoff missing")
    require(handoff3.exists(), "Agent 3 handoff missing")
    h2 = read_json(handoff2)
    h3 = read_json(handoff3)
    require("spec_summary" in h2.get("handoff_outputs", {}), "Agent 2 spec_summary handoff missing")
    require("code_summary" in h3.get("handoff_outputs", {}), "Agent 3 code_summary handoff missing")
    print("  PASS Agents 2 and 3 agree on the canonical run/input paths from any CWD")

    print("[7/7] All production agents import the shared contract...")
    expected_agents = {
        "spec_extraction_agent.py",
        "code_understanding_agent.py",
        "property_discovery_agent.py",
        "artifact_generation_agent.py",
        "review_critic_agent.py",
        "tool_execution_agent.py",
        "counterexample_analysis_agent.py",
        "repair_agent.py",
        "experiment_logger.py",
        "evaluation_reporter.py",
    }
    for name in sorted(expected_agents):
        text = (ROOT / "agents" / name).read_text(encoding="utf-8")
        require("load_normalized_config" in text, f"{name} is not wired to the common config contract")
    print("  PASS all ten stage agents use agents.common.config_contract")

    shutil.rmtree(RUNS, ignore_errors=True)
    print("\nBLOCKER 2 PASSED")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"\nBLOCKER 2 FAILED: {type(exc).__name__}: {exc}", file=sys.stderr)
        raise
