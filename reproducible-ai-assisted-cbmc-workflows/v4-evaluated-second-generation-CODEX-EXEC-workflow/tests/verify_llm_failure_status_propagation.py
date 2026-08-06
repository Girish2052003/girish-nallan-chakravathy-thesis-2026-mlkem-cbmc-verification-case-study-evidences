#!/usr/bin/env python3
"""Regression: every LLM-backed stage must expose LLM failures in status errors."""
from __future__ import annotations

from pathlib import Path
from types import SimpleNamespace
import sys

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.llm_client import record_llm_stage_failure


LLM_BACKED_AGENTS = [
    "spec_extraction_agent.py",
    "code_understanding_agent.py",
    "property_discovery_agent.py",
    "artifact_generation_agent.py",
    "review_critic_agent.py",
    "counterexample_analysis_agent.py",
    "repair_agent.py",
    "evaluation_reporter.py",
]


def main() -> int:
    status = {"errors": []}
    failed = SimpleNamespace(
        success=False,
        error="Invalid structured-output schema",
        validation_path="validation/llm_call_validation.json",
        attempts=0,
        llm_call_executed=False,
        to_dict=lambda: {"success": False, "error": "Invalid structured-output schema"},
    )
    record_llm_stage_failure(status, failed)
    assert len(status["errors"]) == 1, status
    error = status["errors"][0]
    assert error["type"] == "LLMStageError", error
    assert error["message"] == failed.error, error
    assert error["validation_path"] == failed.validation_path, error
    assert error["attempts"] == 0, error
    assert error["llm_call_executed"] is False, error

    # Re-recording the same failure must not duplicate the authoritative error.
    record_llm_stage_failure(status, failed)
    assert len(status["errors"]) == 1, status
    record_llm_stage_failure(status, SimpleNamespace(success=True, to_dict=lambda: {"success": True}))
    assert len(status["errors"]) == 1, status

    fallback = {"errors": []}
    record_llm_stage_failure(
        fallback,
        SimpleNamespace(
            success=False, error=None, validation_path=None, attempts=1, llm_call_executed=True,
            to_dict=lambda: {"success": False, "error": None},
        ),
    )
    assert fallback["errors"][0]["message"], fallback

    for filename in LLM_BACKED_AGENTS:
        text = (ROOT / "agents" / filename).read_text(encoding="utf-8")
        assert "record_llm_stage_failure(stage_status, result)" in text, filename

    print("LLM FAILURE STATUS PROPAGATION: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
