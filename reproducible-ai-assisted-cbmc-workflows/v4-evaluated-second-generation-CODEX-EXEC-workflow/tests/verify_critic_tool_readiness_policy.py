#!/usr/bin/env python3

from pathlib import Path
import sys
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

import json
import tempfile
from pathlib import Path
from types import SimpleNamespace

from agents.review_critic_agent import derive_gate_decision
from agents.master_orchestrator import MasterOrchestrator


cfg = SimpleNamespace(target_function="mlk_poly_add")


def derive(deterministic_gate, deterministic_issues, llm_gate, llm_blockers):
    return derive_gate_decision(
        cfg=cfg,
        deterministic_review_obj={
            "recommended_gate": deterministic_gate,
            "issues": deterministic_issues,
        },
        critic_review={
            "gate_recommendation": llm_gate,
            "blocking_issues": llm_blockers,
        },
        harness_path=None,
        artifact_plan_path=None,
        independence_audit_path=None,
        llm_mode="real",
    )


# 1. Warnings/human caveats must not block CBMC.
gate = derive(
    "approved_for_tool_execution",
    [],
    "human_review_required",
    [],
)
assert gate["final_gate"] == "approved_for_tool_execution", gate
assert gate["tool_execution_allowed"] is True, gate


# 2. Deterministic hard blockers must still stop CBMC.
gate = derive(
    "blocked",
    [{
        "severity": "major",
        "blocks_tool_execution": True,
        "message": "missing harness entry",
    }],
    "approved_for_tool_execution",
    [],
)
assert gate["final_gate"] == "blocked_semantic_fidelity_defect", gate
assert gate["tool_execution_allowed"] is False, gate


# 3. LLM hard blockers must still stop CBMC.
gate = derive(
    "approved_for_tool_execution",
    [],
    "blocked_due_to_critical_issue",
    [{"issue": "invalid target binding"}],
)
assert gate["final_gate"] == "blocked_semantic_fidelity_defect", gate
assert gate["tool_execution_allowed"] is False, gate


# 4. Orchestrator must distinguish human review from repair.
with tempfile.TemporaryDirectory() as tmp:
    gate_path = Path(tmp) / "gate.json"

    class DummyLayout:
        def get_handoff(self, stage, key):
            assert stage == "06_review_critic"
            assert key == "review_gate_decision"
            return gate_path

    orchestrator = object.__new__(MasterOrchestrator)
    orchestrator.layout = DummyLayout()

    gate_path.write_text(json.dumps({
        "content": {
            "final_gate": "human_review_required",
            "tool_execution_allowed": False,
        }
    }), encoding="utf-8")

    assert orchestrator.critic_gate_state() == "human_review_required"
    assert orchestrator.critic_requires_repair() is False

    gate_path.write_text(json.dumps({
        "content": {
            "final_gate": "needs_revision_before_tool_execution",
            "tool_execution_allowed": False,
        }
    }), encoding="utf-8")

    assert orchestrator.critic_gate_state() == \
        "blocked_semantic_fidelity_defect"
    assert orchestrator.critic_requires_repair() is True


print("CRITIC TOOL-READINESS POLICY REGRESSION: PASS")
