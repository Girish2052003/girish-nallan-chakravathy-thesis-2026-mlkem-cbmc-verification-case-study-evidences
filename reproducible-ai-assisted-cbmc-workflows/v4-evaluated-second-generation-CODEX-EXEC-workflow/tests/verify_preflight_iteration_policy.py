#!/usr/bin/env python3
"""Behavioural regression for canonical iteration/advisory preflight policy."""
from __future__ import annotations

from copy import deepcopy
import json
from pathlib import Path
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.config_contract import normalize_config, validate_pipeline_config
from preflight_first_api import run_preflight


def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def base_config(tmp: Path) -> dict:
    spec = tmp / "fips.txt"
    source = tmp / "target.c"
    spec.write_text("controlled specification fixture\n", encoding="utf-8")
    source.write_text("void target(void){}\n", encoding="utf-8")
    return {
        "project_root": str(tmp),
        "run_id": "policy_fixture",
        "output_root": str(tmp / "runs"),
        "target_scheme": "ML-KEM",
        "target_function": "target",
        "target_topic": "policy fixture",
        "verification_tool": "CBMC",
        "artifact_type": "candidate CBMC harness",
        "max_iterations": 0,
        "inputs": {"spec_paths": [str(spec)], "code_paths": [str(source)]},
        "property_campaign": {
            "property_family_id": "P16",
            "verification_strategy": "standard_cbmc_harness",
        },
        "llm": {
            "mode": "real",
            "model": "policy-test-model",
            "api_key_env": "OPENAI_API_KEY",
        },
        "provenance": {"source_revision": "0123456789abcdef0123456789abcdef01234567"},
        "tool_execution": {
            "cbmc_binary": "/bin/true",
            "cbmc_function": "harness",
            "dry_run": False,
            "force_run": False,
            "require_gate_approval": True,
            "step_timeout_seconds": 30,
            "pipeline_timeout_seconds": 60,
            "structured_json_required": True,
        },
        "experiment_protocol": {
            "protocol_version": "llm-first-v1",
            "semantic_advisory_mode": "off",
            "repair_policy": "none_initial_run",
        },
    }


with tempfile.TemporaryDirectory(prefix="preflight_policy_") as td:
    tmp = Path(td)
    initial = base_config(tmp)
    normalized = normalize_config(initial, config_path=tmp / "initial.json", project_root=tmp)
    assert not validate_pipeline_config(normalized).errors
    assert normalized["max_iterations"] == 0
    assert normalized["experiment_protocol"]["repair_policy"] == "none_initial_run"

    followup = deepcopy(initial)
    followup["run_id"] = "policy_followup"
    followup["max_iterations"] = 1
    followup["experiment_protocol"]["repair_policy"] = "single_repair_followup"
    normalized_followup = normalize_config(followup, config_path=tmp / "followup.json", project_root=tmp)
    assert not validate_pipeline_config(normalized_followup).errors

    mismatch = deepcopy(initial)
    mismatch["max_iterations"] = 1
    mismatch["experiment_protocol"]["repair_policy"] = "none_initial_run"
    normalized_mismatch = normalize_config(mismatch, config_path=tmp / "mismatch.json", project_root=tmp)
    errors = validate_pipeline_config(normalized_mismatch).errors
    assert any("require max_iterations=0" in item for item in errors), errors

    comparison = deepcopy(initial)
    comparison["experiment_protocol"]["semantic_advisory_mode"] = "reference_only"
    comparison_path = tmp / "comparison.json"
    write_json(comparison_path, comparison)
    rc, report = run_preflight(
        comparison_path,
        mode="local_only",
    )
    assert rc == 1
    assert any("semantic_advisory_mode='off'" in item for item in report["errors"]), report["errors"]

print("PREFLIGHT CONTROLLED-ITERATION POLICY REGRESSION: PASS")
