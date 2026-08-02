#!/usr/bin/env python3
"""Tool-execution approval must accept only a real JSON Boolean true."""
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from agents.common.workflow_policy import normalise_critic_gate
from agents.tool_execution_agent import get_gate_value


def main() -> int:
    approved = {"final_gate": "approved_for_tool_execution", "tool_execution_allowed": True}
    assert normalise_critic_gate(approved) == "approved_for_tool_execution"
    gate, allowed, reason = get_gate_value(approved)
    assert gate == "approved_for_tool_execution" and allowed is True and "invalid_non_boolean" not in reason

    malformed_values = ["true", "false", "1", 1, 0, None, [], {}]
    for value in malformed_values:
        row = {"final_gate": "approved_for_tool_execution", "tool_execution_allowed": value}
        assert normalise_critic_gate(row) == "missing_gate", (value, normalise_critic_gate(row))
        gate, allowed, reason = get_gate_value(row)
        assert gate == "approved_for_tool_execution", (value, gate)
        assert allowed is False, (value, allowed)
        assert "invalid_non_boolean_tool_execution_allowed" in reason, (value, reason)

    denied = {"final_gate": "approved_for_tool_execution", "tool_execution_allowed": False}
    assert normalise_critic_gate(denied) == "missing_gate"
    _, allowed, reason = get_gate_value(denied)
    assert allowed is False and "invalid_non_boolean" not in reason

    print("GATE BOOLEAN FAIL-CLOSED REGRESSION: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
