#!/usr/bin/env python3
"""Regression: every API schema must pass the local OpenAI subset preflight."""
from __future__ import annotations

import json
import os
import tempfile
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import agents.common.llm_client as lc
from agents.common.llm_client import (
    LLMClient,
    LLMClientConfig,
    LLMStageRequest,
    validate_openai_structured_output_schema,
)
from agents.common.schemas import ALL_STAGE_SCHEMAS, ARTIFACT_PLAN_SCHEMA


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


class NeverConstructedOpenAI:
    constructed = 0

    def __init__(self, **kwargs):
        type(self).constructed += 1
        raise AssertionError("OpenAI client must not be constructed for a locally invalid schema")


class ProviderRejectsSchemaOpenAI:
    calls = 0

    def __init__(self, **kwargs):
        self.responses = self

    def create(self, **kwargs):
        type(self).calls += 1
        raise RuntimeError(
            "Error code: 400 - invalid_json_schema: Invalid schema for response_format"
        )


def config() -> LLMClientConfig:
    return LLMClientConfig.from_mapping(
        {
            "mode": "real",
            "model": "schema-preflight-test",
            "retry_sleep_seconds": 0,
            "max_request_bytes": 500000,
            "max_retry_growth_percent": 1000,
            "max_stage_input_tokens_estimate": 200000,
            "max_total_input_tokens_estimate": 1000000,
            "retry_policy": {
                "schema": {"enabled": True, "max_retries": 1},
                "incomplete_response": {"enabled": True, "max_retries": 1},
                "provider_error": {"enabled": True, "max_retries": 1},
            },
        }
    )


def main() -> int:
    # The exact production schema that failed must now use supported nested anyOf.
    selected_property_schema = ARTIFACT_PLAN_SCHEMA["properties"]["selected_property"]["properties"]["property"]
    assert "anyOf" in selected_property_schema, selected_property_schema
    assert "oneOf" not in selected_property_schema, selected_property_schema

    for name, schema in ALL_STAGE_SCHEMAS.items():
        result = validate_openai_structured_output_schema(schema)
        assert result["valid"], (name, result)

    invalid_one_of = {
        "type": "object",
        "properties": {
            "value": {
                "oneOf": [{"type": "string"}, {"type": "integer"}],
            }
        },
        "required": ["value"],
        "additionalProperties": False,
    }
    rejected = validate_openai_structured_output_schema(invalid_one_of)
    assert rejected["valid"] is False, rejected
    assert any("oneOf" in item for item in rejected["errors"]), rejected

    invalid_required = {
        "type": "object",
        "properties": {"value": {"type": "string"}},
        "required": [],
        "additionalProperties": False,
    }
    assert validate_openai_structured_output_schema(invalid_required)["valid"] is False

    old_openai = lc.OpenAI
    old_key = os.environ.get("OPENAI_API_KEY")
    os.environ["OPENAI_API_KEY"] = "sk-test-not-real"
    try:
        with tempfile.TemporaryDirectory(prefix="schema_preflight_") as td:
            NeverConstructedOpenAI.constructed = 0
            lc.OpenAI = NeverConstructedOpenAI
            request = LLMStageRequest(
                stage="05_artifact_generation",
                prompt_text="Return JSON.",
                output_filename="out.json",
                json_schema=invalid_one_of,
            )
            result = LLMClient(config()).run_stage(Layout(Path(td)), request)
            assert result.success is False, result
            assert result.llm_call_executed is False, result
            assert result.attempts == 0, result
            assert NeverConstructedOpenAI.constructed == 0
            validation = json.loads(
                (Path(td) / "05_artifact_generation/validation/llm_call_validation.json").read_text()
            )
            assert validation["structured_output_schema_preflight"]["valid"] is False

        # Defence in depth: a provider-side invalid_json_schema rejection is not retryable.
        with tempfile.TemporaryDirectory(prefix="schema_provider_reject_") as td:
            ProviderRejectsSchemaOpenAI.calls = 0
            lc.OpenAI = ProviderRejectsSchemaOpenAI
            valid_schema = {
                "type": "object",
                "properties": {"value": {"type": "string"}},
                "required": ["value"],
                "additionalProperties": False,
            }
            request = LLMStageRequest(
                stage="02_spec_extraction",
                prompt_text="Return JSON.",
                output_filename="out.json",
                json_schema=valid_schema,
            )
            result = LLMClient(config()).run_stage(Layout(Path(td)), request)
            assert result.success is False, result
            assert ProviderRejectsSchemaOpenAI.calls == 1, ProviderRejectsSchemaOpenAI.calls
            assert result.attempts == 1, result
    finally:
        lc.OpenAI = old_openai
        if old_key is None:
            os.environ.pop("OPENAI_API_KEY", None)
        else:
            os.environ["OPENAI_API_KEY"] = old_key

    print("OPENAI STRUCTURED OUTPUT SCHEMA PREFLIGHT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
