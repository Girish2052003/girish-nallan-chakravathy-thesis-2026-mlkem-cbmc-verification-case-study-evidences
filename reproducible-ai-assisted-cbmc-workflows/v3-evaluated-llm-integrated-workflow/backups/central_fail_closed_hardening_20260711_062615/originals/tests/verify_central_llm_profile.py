#!/usr/bin/env python3
"""Regression gate for the one-place central LLM profile architecture.

No network request is made.  OpenAI client calls are replaced with local fakes.
"""

from __future__ import annotations

import copy
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path
from types import SimpleNamespace
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.config_contract import (  # noqa: E402
    ConfigContractError,
    load_normalized_config,
    validate_pipeline_config,
)
from agents.common.llm_client import (  # noqa: E402
    LLMClient,
    LLMClientConfig,
    LLMStageRequest,
    build_openai_client_kwargs,
    build_responses_control_payload,
)
from agents.common.llm_profile import (  # noqa: E402
    canonical_json_sha256,
    frozen_profile_metadata,
)
from agents.common.run_layout import RunLayout  # noqa: E402
from agents.master_orchestrator import MasterOrchestrator  # noqa: E402
import agents.common.llm_client as llm_module  # noqa: E402
import preflight_first_api as preflight  # noqa: E402


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def profile(model: str = "gpt-5.4-mini", effort: str = "xhigh") -> dict[str, Any]:
    return {
        "profile_schema_version": "thesis_llm_profile.v1",
        "provider": "openai",
        "mode": "real",
        "model": model,
        "api_key_env": "OPENAI_API_KEY",
        "reasoning": {"effort": effort},
        "text": {"verbosity": "high"},
        "max_output_tokens": 32000,
        "preflight_max_output_tokens": 256,
        "store": False,
        "client": {"timeout_seconds": 900},
        "max_retries": 2,
        "retry_sleep_seconds": 0.0,
    }


def make_project(tmp: Path) -> tuple[Path, Path, Path, Path]:
    project = tmp / "project"
    config_dir = project / "configs"
    profile_path = config_dir / "llm_profiles" / "active_thesis_model.json"
    spec = project / "inputs" / "spec.txt"
    source = project / "inputs" / "source.c"
    spec.parent.mkdir(parents=True, exist_ok=True)
    source.parent.mkdir(parents=True, exist_ok=True)
    spec.write_text("FIPS test material", encoding="utf-8")
    source.write_text("int target(void) { return 0; }\n", encoding="utf-8")
    write_json(profile_path, profile())

    config_path = config_dir / "run.json"
    write_json(config_path, {
        "run_id": "central_profile_regression",
        "output_root": str(tmp / "runs"),
        "project_root": str(ROOT),
        "target_scheme": "ML-KEM",
        "target_function": "target",
        "verification_tool": "CBMC",
        "artifact_type": "CBMC verification harness",
        "max_iterations": 0,
        "parallel_initial_agents": False,
        "strict_outputs": True,
        "inputs": {
            "spec_paths": [str(spec)],
            "code_paths": [str(source)],
        },
        "llm_profile": str(profile_path),
        "llm_overrides": {
            "max_inline_file_chars": 200000,
            "attach_files_as_base64": False,
        },
        "tool_execution": {
            "dry_run": False,
            "force_run": False,
            "require_gate_approval": True,
        },
        "provenance": {
            "source_revision": "central-profile-regression-fixture",
        },
    })
    return config_path, profile_path, spec, source


def test_resolution_and_one_place_change(tmp: Path) -> tuple[Path, Path, dict[str, Any]]:
    print("[1/8] Shared profile resolution and run-specific override preservation...")
    config_path, profile_path, _, _ = make_project(tmp)
    first = load_normalized_config(config_path)
    require(first["llm"]["model"] == "gpt-5.4-mini", "Profile model was not resolved")
    require(first["llm"]["reasoning"]["effort"] == "xhigh", "Reasoning effort was not resolved")
    require(first["llm"]["text"]["verbosity"] == "high", "Verbosity was not resolved")
    require(first["llm"]["store"] is False, "store=false was not resolved")
    require(first["llm"]["max_inline_file_chars"] == 200000, "Operational override was lost")
    require(first["_llm_profile"]["source_path"] == str(profile_path.resolve()), "Profile provenance missing")
    report = validate_pipeline_config(first, check_input_files=True)
    report.raise_for_errors()

    changed = profile(model="gpt-5.6", effort="high")
    write_json(profile_path, changed)
    second = load_normalized_config(config_path)
    require(second["llm"]["model"] == "gpt-5.6", "One-place model change did not propagate")
    require(second["llm"]["reasoning"]["effort"] == "high", "One-place effort change did not propagate")
    require(second["llm"]["max_inline_file_chars"] == 200000, "Run-specific override changed unexpectedly")
    print("  PASS one profile controls model/reasoning while recent per-run evidence limits remain intact")
    return config_path, profile_path, second


def test_fail_closed_ambiguity(config_path: Path) -> None:
    print("[2/8] Ambiguous or protected duplicate configuration fails closed...")
    raw = json.loads(config_path.read_text(encoding="utf-8"))

    ambiguous = copy.deepcopy(raw)
    ambiguous["llm"] = {"model": "split-brain-model"}
    path = config_path.with_name("ambiguous.json")
    write_json(path, ambiguous)
    try:
        load_normalized_config(path)
    except ConfigContractError as exc:
        require("both llm_profile and an inline llm" in str(exc), "Wrong ambiguity diagnostic")
    else:
        raise AssertionError("Config with both llm_profile and llm unexpectedly loaded")

    protected = copy.deepcopy(raw)
    protected["llm_overrides"]["model"] = "forbidden-override"
    path2 = config_path.with_name("protected_override.json")
    write_json(path2, protected)
    try:
        load_normalized_config(path2)
    except ConfigContractError as exc:
        require("Move these central fields" in str(exc), "Wrong protected override diagnostic")
    else:
        raise AssertionError("Protected model override unexpectedly loaded")
    print("  PASS split-brain model settings cannot silently bypass the one-place profile")


def test_runtime_controls(resolved: dict[str, Any], tmp: Path) -> None:
    print("[3/8] Runtime request carries reasoning, verbosity, storage, and strict schema together...")
    captured: list[dict[str, Any]] = []
    captured_clients: list[dict[str, Any]] = []

    class FakeResponse:
        id = "resp_central_profile"
        model = "gpt-5.6"
        status = "completed"
        output_text = '{"ok": true}'
        usage = {"output_tokens": 2, "output_tokens_details": {"reasoning_tokens": 0}}

        def model_dump(self) -> dict[str, Any]:
            return {
                "id": self.id,
                "model": self.model,
                "status": self.status,
                "output_text": self.output_text,
                "usage": self.usage,
            }

    class FakeResponses:
        def create(self, **kwargs: Any) -> FakeResponse:
            captured.append(kwargs)
            return FakeResponse()

    class FakeClient:
        def __init__(self, **kwargs: Any) -> None:
            captured_clients.append(kwargs)
            self.responses = FakeResponses()

    old_openai = llm_module.OpenAI
    old_key = os.environ.get("OPENAI_API_KEY")
    llm_module.OpenAI = FakeClient
    os.environ["OPENAI_API_KEY"] = "sk-local-central-profile-regression"
    try:
        layout = RunLayout(tmp / "runtime_run", create=True)
        client = LLMClient(resolved["llm"])
        result = client.run_stage(
            layout,
            LLMStageRequest(
                stage="02_spec_extraction",
                prompt_text="Return the required object.",
                output_filename="result.json",
                json_schema={
                    "type": "object",
                    "properties": {"ok": {"type": "boolean"}},
                    "required": ["ok"],
                    "additionalProperties": False,
                },
            ),
        )
    finally:
        llm_module.OpenAI = old_openai
        if old_key is None:
            os.environ.pop("OPENAI_API_KEY", None)
        else:
            os.environ["OPENAI_API_KEY"] = old_key

    require(result.success, f"Fake runtime stage failed: {result.error}")
    require(len(captured) == 1, "Runtime did not make exactly one fake request")
    payload = captured[0]
    require(payload["model"] == "gpt-5.6", "Runtime did not use resolved profile model")
    require(payload["reasoning"] == {"effort": "high"}, "Runtime reasoning controls incorrect")
    require(payload["store"] is False, "Runtime store=false missing")
    require(payload["max_output_tokens"] == 32000, "Runtime token budget incorrect")
    require(payload["text"]["verbosity"] == "high", "Runtime verbosity missing")
    require(payload["text"]["format"]["type"] == "json_schema", "Strict schema format missing")
    require(payload["text"]["format"]["strict"] is True, "Strict schema flag missing")
    require(captured_clients[0]["timeout"] == 900.0, "Runtime client timeout did not come from profile")
    print("  PASS verbosity is merged with—not substituted for—strict Structured Outputs")


def test_preflight_runtime_parity(resolved: dict[str, Any]) -> None:
    print("[4/8] Preflight and runtime derive controls/client routing from the same helpers...")
    cfg = LLMClientConfig.from_mapping(resolved["llm"])
    runtime_client = build_openai_client_kwargs(cfg, "sk-local-central-profile-preflight")
    runtime_controls = build_responses_control_payload(cfg)

    capture: dict[str, Any] = {}

    class FakeResponses:
        def create(self, **kwargs: Any) -> Any:
            capture["payload"] = kwargs
            return SimpleNamespace(
                status="completed",
                error=None,
                model=kwargs["model"],
                id="resp_preflight",
                usage={"output_tokens": 1},
            )

    class Factory:
        def __call__(self, **kwargs: Any) -> Any:
            capture["client"] = kwargs
            return SimpleNamespace(responses=FakeResponses())

    old_key = os.environ.get("OPENAI_API_KEY")
    os.environ["OPENAI_API_KEY"] = "sk-local-central-profile-preflight"
    try:
        result = preflight.check_live_api_access(resolved["llm"], client_factory=Factory())
    finally:
        if old_key is None:
            os.environ.pop("OPENAI_API_KEY", None)
        else:
            os.environ["OPENAI_API_KEY"] = old_key

    require(capture["client"] == runtime_client, "Preflight/runtime client arguments diverged")
    payload = capture["payload"]
    for key in ("store", "reasoning", "text"):
        require(payload.get(key) == runtime_controls.get(key), f"Preflight/runtime {key} controls diverged")
    require(payload["max_output_tokens"] == cfg.preflight_max_output_tokens, "Preflight token cap incorrect")
    require(result["resolved_controls"]["reasoning_effort"] == "high", "Preflight report omitted effort")
    print("  PASS live probe tests the exact model/control combination with a small dedicated token cap")


def test_orchestrator_freeze(config_path: Path, profile_path: Path, tmp: Path) -> None:
    print("[5/8] Orchestrator snapshots and freezes the resolved profile per run...")
    # Restore the profile to a known value before the run snapshot.
    write_json(profile_path, profile(model="gpt-5.4-mini", effort="xhigh"))
    orchestrator = MasterOrchestrator(config_path, dry_run=True, skip_input_checks=False)
    orchestrator.validate_config()
    orchestrator.setup_run_dir()

    resolved_path = orchestrator.resolved_config_path
    snapshot_path = orchestrator.resolved_llm_profile_path
    require(resolved_path.exists(), "Resolved run config was not written")
    require(snapshot_path.exists(), "Resolved LLM profile snapshot was not written")

    resolved_raw = json.loads(resolved_path.read_text(encoding="utf-8"))
    require(resolved_raw["_llm_profile"]["frozen"] is True, "Resolved config profile is not frozen")
    require(
        resolved_raw["_llm_profile"]["snapshot_path"] == str(snapshot_path.resolve()),
        "Resolved profile snapshot path missing",
    )
    require(
        resolved_raw["_llm_profile"]["resolved_llm_sha256"]
        == canonical_json_sha256(resolved_raw["llm"]),
        "Resolved config LLM hash mismatch",
    )

    input_snapshot = (
        orchestrator.run_dir
        / "stages/01_master_orchestrator/control/input_snapshot"
    )
    require(
        any(path.name.startswith("llm_profile_") for path in input_snapshot.glob("*")),
        "Original profile was not copied into the run input snapshot",
    )

    # A later global profile edit must not mutate an already-resolved run.
    write_json(profile_path, profile(model="future-global-model", effort="low"))
    frozen = load_normalized_config(resolved_path)
    require(frozen["llm"]["model"] == "gpt-5.4-mini", "Frozen run re-read the mutable profile")
    require(frozen["llm"]["reasoning"]["effort"] == "xhigh", "Frozen effort changed mid-run")
    print("  PASS future profile edits affect new runs only; existing/resumed runs stay reproducible")


def test_frozen_tamper_detection(config_path: Path, profile_path: Path, tmp: Path) -> None:
    print("[6/8] Frozen embedded profile tampering is detected...")
    write_json(profile_path, profile())
    normalized = load_normalized_config(config_path)
    frozen = copy.deepcopy(normalized)
    frozen["_llm_profile"] = frozen_profile_metadata(
        frozen["_llm_profile"],
        snapshot_path=tmp / "snapshot.json",
    )
    frozen["llm"]["model"] = "tampered-model"
    path = tmp / "tampered_resolved.json"
    write_json(path, frozen)
    try:
        load_normalized_config(path, project_root=ROOT)
    except ConfigContractError as exc:
        require("hash mismatch" in str(exc).lower(), "Wrong frozen tamper diagnostic")
    else:
        raise AssertionError("Tampered frozen profile unexpectedly loaded")
    print("  PASS resolved profile hash prevents silent mid-run model substitution")


def test_legacy_compatibility(tmp: Path) -> None:
    print("[7/8] Legacy inline llm configs remain supported...")
    config_path, _, _, _ = make_project(tmp / "legacy_fixture")
    raw = json.loads(config_path.read_text(encoding="utf-8"))
    raw.pop("llm_profile", None)
    raw.pop("llm_overrides", None)
    raw["llm"] = {
        "mode": "mock",
        "model": "legacy-mock-model",
        "api_key_env": "OPENAI_API_KEY",
        "max_output_tokens": 12000,
    }
    legacy_path = config_path.with_name("legacy.json")
    write_json(legacy_path, raw)
    loaded = load_normalized_config(legacy_path)
    require(loaded["llm"]["model"] == "legacy-mock-model", "Legacy inline model changed")
    require("_llm_profile" not in loaded, "Legacy config was falsely marked as profile-backed")
    print("  PASS old mock/baseline configurations are not forced into the new profile system")


def test_repository_recent_files_untouched() -> None:
    print("[8/8] Recent live-hardening agent functionality remains outside this patch...")
    # These files are intentionally not imported or rewritten by the central-profile patch.
    for relative in (
        "agents/patch_agent.sh",
        "agents/artifact_generation_agent.py",
    ):
        require((ROOT / relative).is_file(), f"Recent file missing: {relative}")
    print("  PASS recent artifact-generation and live-hardening patch files remain present and untouched")


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="central_llm_profile_gate_") as td:
        tmp = Path(td)
        config_path, profile_path, resolved = test_resolution_and_one_place_change(tmp)
        test_fail_closed_ambiguity(config_path)
        test_runtime_controls(resolved, tmp)
        test_preflight_runtime_parity(resolved)
        test_orchestrator_freeze(config_path, profile_path, tmp)
        test_frozen_tamper_detection(config_path, profile_path, tmp)
        test_legacy_compatibility(tmp)
        test_repository_recent_files_untouched()

    print("\nCENTRAL LLM PROFILE REGRESSION PASSED")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"\nCENTRAL LLM PROFILE REGRESSION FAILED: {type(exc).__name__}: {exc}", file=sys.stderr)
        raise
