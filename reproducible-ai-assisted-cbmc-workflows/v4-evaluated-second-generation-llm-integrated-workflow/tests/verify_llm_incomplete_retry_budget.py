#!/usr/bin/env python3
"""Behavioral regressions for incomplete responses, retries, redaction and budgets."""
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

import agents.common.llm_client as lc
from agents.common.llm_client import (
    IncompleteResponseError,
    LLMClient,
    LLMClientConfig,
    LLMStageRequest,
    redact_secrets,
    reserve_run_input_budget,
    with_json_retry_instruction,
)


class Layout:
    def __init__(self, root: Path):
        self.run_dir = root
    def prompt_package_dir(self, stage: str) -> Path:
        p = self.run_dir / stage / "prompt_package"; p.mkdir(parents=True, exist_ok=True); return p
    def llm_authoritative_dir(self, stage: str) -> Path:
        p = self.run_dir / stage / "llm_authoritative"; p.mkdir(parents=True, exist_ok=True); return p
    def write_prompt_package(self, stage: str, **kwargs):
        p = self.prompt_package_dir(stage) / "prompt.txt"; p.write_text(str(kwargs.get("prompt_text") or ""), encoding="utf-8")
        m = self.prompt_package_dir(stage) / "metadata.json"; m.write_text(json.dumps(kwargs.get("extra_metadata") or {}), encoding="utf-8")
        return {"prompt": p, "prompt_metadata": m}
    def write_validation_json(self, stage: str, name: str, value):
        p = self.run_dir / stage / "validation" / name; p.parent.mkdir(parents=True, exist_ok=True); p.write_text(json.dumps(value, indent=2), encoding="utf-8"); return p
    def write_llm_authoritative_json(self, stage: str, name: str, value):
        p = self.llm_authoritative_dir(stage) / name; p.write_text(json.dumps(value), encoding="utf-8"); return p


class Usage:
    input_tokens = 123
    output_tokens = 456
    total_tokens = 579
    def model_dump(self):
        return {"input_tokens": 123, "output_tokens": 456, "total_tokens": 579}


class IncompleteResponse:
    id = "resp_incomplete"
    status = "incomplete"
    incomplete_details = {"reason": "max_output_tokens"}
    output_text = ""
    usage = Usage()
    def model_dump(self):
        return {
            "id": self.id,
            "status": self.status,
            "incomplete_details": self.incomplete_details,
            "output": [{"type": "reasoning", "summary": "no final JSON"}],
            "usage": {"input_tokens": 123, "output_tokens": 456, "total_tokens": 579},
        }


class FakeOpenAI:
    calls = 0
    def __init__(self, **kwargs):
        self.responses = self
    def create(self, **kwargs):
        type(self).calls += 1
        return IncompleteResponse()


def main() -> int:
    print("[1/5] Incomplete provider response is typed before JSON extraction...")
    try:
        lc._response_to_text(IncompleteResponse())
    except IncompleteResponseError as exc:
        assert exc.reason == "max_output_tokens"
    else:
        raise AssertionError("Incomplete response was not typed")
    print("  PASS")

    print("[2/5] Runtime performs one cause-aware attempt and never parses the envelope...")
    with tempfile.TemporaryDirectory(prefix="llm_incomplete_") as td:
        layout = Layout(Path(td))
        old_openai, old_extract = lc.OpenAI, lc.extract_json_object
        old_key = os.environ.get("OPENAI_API_KEY")
        called = {"extract": 0}
        def forbidden_extract(text: str):
            called["extract"] += 1
            raise AssertionError("provider envelope must not reach stage JSON extraction")
        lc.OpenAI = FakeOpenAI
        lc.extract_json_object = forbidden_extract
        os.environ["OPENAI_API_KEY"] = "sk-test-not-real-123456789"
        FakeOpenAI.calls = 0
        try:
            client = LLMClient(LLMClientConfig(
                mode=lc.LLMMode.REAL,
                model="fake-model",
                max_retries=2,
                retry_sleep_seconds=0,
                semantic_advisory_mode="off",
                max_request_bytes=100_000,
                max_stage_input_tokens_estimate=30_000,
                max_total_input_tokens_estimate=50_000,
            ))
            request = LLMStageRequest(
                stage="02_spec_extraction",
                prompt_text="Return strict JSON.",
                output_filename="out.json",
                json_schema={"type": "object", "properties": {"stage": {"type": "string"}}, "required": ["stage"], "additionalProperties": False},
                deterministic_reference_bundle={"UNIQUE_FORBIDDEN_SEMANTIC_HINT": "must never be transmitted"},
            )
            result = client.run_stage(layout, request)
            assert result.success is False
            assert "IncompleteResponseError" in str(result.error)
            assert FakeOpenAI.calls == 1, FakeOpenAI.calls
            assert called["extract"] == 0
            snap = json.loads((layout.prompt_package_dir("02_spec_extraction") / "api_requests/attempt_01_request.json").read_text())
            rendered = json.dumps(snap)
            assert "UNIQUE_FORBIDDEN_SEMANTIC_HINT" not in rendered
            assert snap["evidence_categories"]["deterministic_advisory_bundle_present"] is False
            raw = json.loads((layout.llm_authoritative_dir("02_spec_extraction") / "api_responses/attempt_01_response.json").read_text())
            assert raw["provider_status"] == "incomplete"
            assert raw["incomplete_reason"] == "max_output_tokens"
            assert raw["usage"]["input_tokens"] == 123
        finally:
            lc.OpenAI = old_openai
            lc.extract_json_object = old_extract
            if old_key is None: os.environ.pop("OPENAI_API_KEY", None)
            else: os.environ["OPENAI_API_KEY"] = old_key
    print("  PASS")

    print("[3/5] Retry instruction remains compact and does not duplicate schema...")
    prompt = "P" * 20_000
    schema = {"required": [f"field_{i}" for i in range(100)]}
    retry = with_json_retry_instruction(prompt, schema, "E" * 20_000)
    assert len(retry) <= int(len(prompt) * 1.05), (len(prompt), len(retry))
    assert "field_99" not in retry
    assert "properties" not in retry
    print("  PASS")

    print("[4/5] Secret redaction preserves token-usage evidence...")
    redacted = redact_secrets({
        "api_key": "sk-test-redaction-secret-1234567890",
        "authorization": "Bearer abcdefghijklmnopqrstuvwxyz",
        "usage": {"input_tokens": 10, "output_tokens": 20, "total_tokens": 30},
    })
    assert redacted["api_key"] == "[REDACTED]"
    assert redacted["authorization"] == "[REDACTED]"
    assert redacted["usage"] == {"input_tokens": 10, "output_tokens": 20, "total_tokens": 30}
    print("  PASS")

    print("[5/5] Run-level input budget blocks a future paid request before sending...")
    with tempfile.TemporaryDirectory(prefix="run_budget_") as td:
        layout = Layout(Path(td))
        reserve_run_input_budget(layout, stage="02", attempt=1, request_bytes=400, estimated_input_tokens=100, max_total_input_tokens_estimate=150)
        try:
            reserve_run_input_budget(layout, stage="03", attempt=1, request_bytes=240, estimated_input_tokens=60, max_total_input_tokens_estimate=150)
        except ValueError as exc:
            assert "run_input_token_budget_exceeded" in str(exc)
        else:
            raise AssertionError("Run-level budget did not fail closed")
        ledger = json.loads((Path(td) / "runtime_input_budget_ledger.json").read_text())
        assert ledger["reserved_input_tokens_estimate"] == 100
        assert len(ledger["requests"]) == 1
    print("  PASS")

    print("LLM INCOMPLETE/RETRY/BUDGET REGRESSION: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
