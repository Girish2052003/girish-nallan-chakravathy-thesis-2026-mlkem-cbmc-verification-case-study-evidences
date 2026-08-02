#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import sys
import tempfile
from pathlib import Path
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.formal_build import create_formal_build_plan, validate_formal_build_plan
from agents.common.llm_client import (
    LLMClient,
    LLMClientConfig,
    LLMStageRequest,
    PrimaryEvidenceCompletenessError,
    build_primary_evidence_transmission_manifest,
    build_responses_api_input,
    enforce_primary_evidence_completeness,
    summarise_responses_api_input,
)
import agents.common.llm_client as llm_module
import preflight_first_api as preflight


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def main() -> int:
    print("[1/6] Primary evidence truncation fails closed...")
    with tempfile.TemporaryDirectory(prefix="primary_evidence_gate_") as td:
        tmp = Path(td)
        large = tmp / "fips.txt"
        large.write_text("A" * 101, encoding="utf-8")
        try:
            LLMClientConfig.from_mapping({"fail_on_primary_evidence_truncation": False})
        except ValueError:
            pass
        else:
            raise AssertionError("Primary-evidence fail-closed policy could be disabled")
        cfg = LLMClientConfig(max_inline_file_chars=100)
        manifest = build_primary_evidence_transmission_manifest([large], config=cfg)
        require(manifest["all_primary_evidence_complete"] is False, "Oversized evidence was treated as complete")
        try:
            enforce_primary_evidence_completeness(manifest)
        except PrimaryEvidenceCompletenessError:
            pass
        else:
            raise AssertionError("Oversized primary evidence did not fail closed")
        print("  PASS")

        print("[2/6] Runtime blocks an incomplete exact stage request before the API call...")
        class FakeLayout:
            def __init__(self, root: Path):
                self.root = root
            def prompt_package_dir(self, stage: str) -> Path:
                path = self.root / stage / "prompt_package"
                path.mkdir(parents=True, exist_ok=True)
                return path
            def llm_authoritative_dir(self, stage: str) -> Path:
                path = self.root / stage / "llm_authoritative"
                path.mkdir(parents=True, exist_ok=True)
                return path
            def write_prompt_package(self, stage: str, **kwargs):
                prompt = self.prompt_package_dir(stage) / "prompt.txt"
                prompt.write_text(str(kwargs.get("prompt_text") or ""), encoding="utf-8")
                metadata = self.prompt_package_dir(stage) / "metadata.json"
                metadata.write_text("{}\n", encoding="utf-8")
                return {"prompt": prompt, "prompt_metadata": metadata}
            def write_validation_json(self, stage: str, name: str, value):
                path = self.root / stage / "validation" / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")
                return path

        calls = {"count": 0}
        class NeverCalledOpenAI:
            def __init__(self, **kwargs):
                calls["count"] += 1
                raise AssertionError("API client must not be created for incomplete primary evidence")

        old_openai = llm_module.OpenAI
        old_key = os.environ.get("OPENAI_API_KEY")
        llm_module.OpenAI = NeverCalledOpenAI
        os.environ["OPENAI_API_KEY"] = "sk-local-runtime-block-test"
        try:
            result = LLMClient({
                "mode": "real", "model": "test-model",
                "max_inline_file_chars": 100,
            }).run_stage(
                FakeLayout(tmp / "runtime"),
                LLMStageRequest(
                    stage="02_spec_extraction",
                    prompt_text="test",
                    output_filename="out.json",
                    primary_evidence_files=[large],
                ),
            )
        finally:
            llm_module.OpenAI = old_openai
            if old_key is None:
                os.environ.pop("OPENAI_API_KEY", None)
            else:
                os.environ["OPENAI_API_KEY"] = old_key
        require(result.success is False, "Incomplete runtime request unexpectedly succeeded")
        require(result.llm_call_executed is False, "Incomplete runtime request was marked as executed")
        require(result.attempts == 0, "Incomplete runtime request consumed an API attempt")
        require(calls["count"] == 0, "API client was created before completeness rejection")
        print("  PASS")

        print("[3/6] Complete primary evidence reaches the exact shared input without markers...")
        cfg = LLMClientConfig(max_inline_file_chars=200)
        manifest = build_primary_evidence_transmission_manifest([large], config=cfg)
        enforce_primary_evidence_completeness(manifest)
        api_input = build_responses_api_input("probe", [large], config=cfg)
        summary = summarise_responses_api_input(api_input)
        require(not summary["contains_primary_truncation_marker"], "Complete input contains truncation marker")
        require(summary["input_text_chars"] > 101, "Evidence was not included in shared input")
        print("  PASS")

        print("[4/6] Live preflight uses full evidence and records provider input tokens...")
        capture = {}
        class Responses:
            def create(self, **kwargs):
                capture.update(kwargs)
                return SimpleNamespace(
                    status="completed", error=None, model=kwargs["model"], id="resp",
                    usage={"input_tokens": 777, "output_tokens": 1},
                )
        class Factory:
            def __call__(self, **kwargs):
                return SimpleNamespace(responses=Responses())
        old = os.environ.get("OPENAI_API_KEY")
        os.environ["OPENAI_API_KEY"] = "sk-local-fail-closed-test"
        try:
            result = preflight.check_live_api_access(
                {
                    "mode": "real", "model": "test-model", "api_key_env": "OPENAI_API_KEY",
                    "max_inline_file_chars": 200, "preflight_max_output_tokens": 16,
                },
                primary_evidence_files=[large],
                client_factory=Factory(),
            )
        finally:
            if old is None:
                os.environ.pop("OPENAI_API_KEY", None)
            else:
                os.environ["OPENAI_API_KEY"] = old
        require(result["thesis_evidence_sent"] is True, "Preflight omitted configured evidence")
        require(result["input_token_check"]["provider_reported_input_tokens"] == 777, "Input tokens not recorded")
        require(capture["max_output_tokens"] == 16, "Preflight output cap changed")
        print("  PASS")

        print("[5/6] Formal-build binding rejects Run 001 entry and target-call defects...")
        harness = tmp / "harness.c"
        config = {
            "project_root": str(tmp),
            "target_function": "target",
            "property_campaign": {"verification_strategy": "standard_cbmc_harness"},
            "tool_execution": {
                "cbmc_function": "harness", "source_files": [], "stub_files": [],
                "include_paths": [], "defines": [], "working_directory": str(tmp),
            },
        }
        harness.write_text("void target(void);\nvoid custom(void) { }\n", encoding="utf-8")
        plan = create_formal_build_plan(config, harness, target_function="target")
        bad = validate_formal_build_plan(
            plan, harness, expected_cbmc_function="harness", expected_target_function="target"
        )
        require(not bad["valid"], "Renamed entry/missing target call passed")
        print("  PASS")

        print("[6/6] Formal-build binding rejects null-plus-freshness and accepts hardened shape...")
        harness.write_text(
            "typedef struct X { int v; } X;\n"
            "int memory_no_alias(void *, unsigned long);\n"
            "void target(X *, X *);\n"
            "void harness(void) { X *r = 0; X *b; memory_no_alias(r, sizeof(X)); target(r, b); }\n",
            encoding="utf-8",
        )
        plan = create_formal_build_plan(config, harness, target_function="target")
        bad = validate_formal_build_plan(
            plan, harness, expected_cbmc_function="harness", expected_target_function="target"
        )
        require(not bad["valid"], "Null-plus-freshness pattern passed")
        harness.write_text(
            "typedef struct X { int v; } X;\n"
            "X *nondet_X_ptr(void);\n"
            "void target(X *, X *);\n"
            "void harness(void) { X *r = nondet_X_ptr(); X *b = nondet_X_ptr(); target(r, b); }\n",
            encoding="utf-8",
        )
        plan = create_formal_build_plan(config, harness, target_function="target")
        good = validate_formal_build_plan(
            plan, harness, expected_cbmc_function="harness", expected_target_function="target"
        )
        require(good["valid"], f"Hardened harness shape failed: {good['errors']}")
        print("  PASS")

    print("\nCENTRAL FAIL-CLOSED HARDENING REGRESSION PASSED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
