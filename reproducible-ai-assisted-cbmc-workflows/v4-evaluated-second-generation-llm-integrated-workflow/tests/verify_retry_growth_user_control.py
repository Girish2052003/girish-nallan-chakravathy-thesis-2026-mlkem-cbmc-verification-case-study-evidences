#!/usr/bin/env python3
"""Prove retry-growth percentage is user-controlled with no hidden 10% ceiling."""
from __future__ import annotations

import json
import os
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import agents.common.llm_client as lc
from agents.common.experiment_protocol import (
    build_experiment_protocol,
    validate_experiment_protocol,
)
from agents.common.llm_client import (
    LLMClient,
    LLMClientConfig,
    LLMMode,
    LLMStageRequest,
    retry_request_size_limit,
)


class Layout:
    def __init__(self, root: Path):
        self.run_dir = root

    def prompt_package_dir(self, stage: str) -> Path:
        path = self.run_dir / stage / "prompt_package"
        path.mkdir(parents=True, exist_ok=True)
        return path

    def llm_authoritative_dir(self, stage: str) -> Path:
        path = self.run_dir / stage / "llm_authoritative"
        path.mkdir(parents=True, exist_ok=True)
        return path

    def write_prompt_package(self, stage: str, **kwargs):
        prompt = self.prompt_package_dir(stage) / "prompt.txt"
        prompt.write_text(str(kwargs.get("prompt_text") or ""), encoding="utf-8")
        metadata = self.prompt_package_dir(stage) / "metadata.json"
        metadata.write_text(json.dumps(kwargs.get("extra_metadata") or {}), encoding="utf-8")
        return {"prompt": prompt, "prompt_metadata": metadata}

    def write_validation_json(self, stage: str, name: str, value):
        path = self.run_dir / stage / "validation" / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(value, indent=2), encoding="utf-8")
        return path

    def write_llm_authoritative_json(self, stage: str, name: str, value):
        path = self.llm_authoritative_dir(stage) / name
        path.write_text(json.dumps(value), encoding="utf-8")
        return path


class Usage:
    input_tokens = 1
    output_tokens = 1
    total_tokens = 2

    def model_dump(self):
        return {"input_tokens": 1, "output_tokens": 1, "total_tokens": 2}


class CompleteResponse:
    status = "completed"
    incomplete_details = None
    usage = Usage()

    def __init__(self, response_id: str, output_text: str):
        self.id = response_id
        self.output_text = output_text

    def model_dump(self):
        return {
            "id": self.id,
            "status": self.status,
            "output": [{"type": "output_text", "text": self.output_text}],
            "usage": self.usage.model_dump(),
        }


class RetryThenSuccessOpenAI:
    calls = 0

    def __init__(self, **kwargs):
        self.responses = self

    def create(self, **kwargs):
        type(self).calls += 1
        if type(self).calls == 1:
            return CompleteResponse("retry-1", '{"stage": 7}')
        return CompleteResponse("retry-2", '{"stage": "ok"}')


def protocol_with_growth(percent: object) -> dict:
    config = {
        "max_iterations": 0,
        "property_discovery": {"mode": "targeted_campaign"},
        "property_campaign": {
            "property_family_id": "P16",
            "verification_strategy": "standard_cbmc_harness",
        },
        "experiment_protocol": {
            "semantic_advisory_mode": "off",
            "prompt_budget": {
                "max_request_bytes": 100_000,
                "max_retry_growth_percent": percent,
                "max_stage_input_tokens_estimate": 30_000,
                "max_total_input_tokens_estimate": 100_000,
            },
        },
    }
    config["experiment_protocol"] = build_experiment_protocol(config)
    return config


def main() -> int:
    print("[1/5] Values above the former 10% ceiling validate...")
    for percent in (0, 10, 100, 150, 500, 2_000_000):
        errors = validate_experiment_protocol(protocol_with_growth(percent))
        assert not errors, (percent, errors)
    print("  PASS")

    print("[2/5] Invalid negative and Boolean values fail closed...")
    for invalid in (-1, True, False, "150", None):
        errors = validate_experiment_protocol(protocol_with_growth(invalid))
        assert any("max_retry_growth_percent" in error for error in errors), (invalid, errors)
    print("  PASS")

    print("[3/5] Exact runtime limit calculation honours user values...")
    assert retry_request_size_limit(1_000, 0) == 1_000
    assert retry_request_size_limit(1_000, 10) == 1_100
    assert retry_request_size_limit(1_000, 100) == 2_000
    assert retry_request_size_limit(1_000, 150) == 2_500
    assert retry_request_size_limit(1_000, 500) == 6_000
    for invalid in (-1, True, 1.5, "150"):
        try:
            retry_request_size_limit(1_000, invalid)  # type: ignore[arg-type]
        except ValueError:
            pass
        else:
            raise AssertionError(f"Invalid growth value was accepted: {invalid!r}")
    print("  PASS")

    print("[4/5] Run-config wiring preserves 150% exactly...")
    run_config = protocol_with_growth(150)
    run_config["llm"] = {"mode": "mock", "model": "mock-model"}
    client = LLMClient.from_run_config(run_config)
    assert client.config.max_retry_growth_percent == 150
    print("  PASS")

    print("[5/5] A real retry growing by >10% succeeds when configured to 150%...")
    with tempfile.TemporaryDirectory(prefix="retry_growth_user_control_") as td:
        layout = Layout(Path(td))
        old_openai = lc.OpenAI
        old_key = os.environ.get("OPENAI_API_KEY")
        lc.OpenAI = RetryThenSuccessOpenAI
        os.environ["OPENAI_API_KEY"] = "sk-test-not-real-retry-growth"
        RetryThenSuccessOpenAI.calls = 0
        try:
            runtime_client = LLMClient(
                LLMClientConfig(
                    mode=LLMMode.REAL,
                    model="fake-model",
                    max_retries=1,
                    retry_sleep_seconds=0,
                    semantic_advisory_mode="off",
                    max_request_bytes=100_000,
                    max_retry_growth_percent=150,
                    max_stage_input_tokens_estimate=30_000,
                    max_total_input_tokens_estimate=100_000,
                )
            )
            request = LLMStageRequest(
                stage="02_spec_extraction",
                prompt_text="X",
                output_filename="out.json",
                json_schema={
                    "type": "object",
                    "properties": {"stage": {"type": "string"}},
                    "required": ["stage"],
                    "additionalProperties": False,
                },
            )
            result = runtime_client.run_stage(layout, request)
            assert result.success is True, result.error
            assert result.attempts == 2
            first = json.loads(
                (layout.prompt_package_dir("02_spec_extraction") / "api_requests/attempt_01_request.json").read_text()
            )
            second = json.loads(
                (layout.prompt_package_dir("02_spec_extraction") / "api_requests/attempt_02_request.json").read_text()
            )
            first_size = int(first["request_size_bytes"])
            second_size = int(second["request_size_bytes"])
            assert second_size > retry_request_size_limit(first_size, 10), (first_size, second_size)
            assert second_size <= retry_request_size_limit(first_size, 150), (first_size, second_size)
        finally:
            lc.OpenAI = old_openai
            if old_key is None:
                os.environ.pop("OPENAI_API_KEY", None)
            else:
                os.environ["OPENAI_API_KEY"] = old_key
    print("  PASS")

    print("RETRY GROWTH USER CONTROL REGRESSION: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
