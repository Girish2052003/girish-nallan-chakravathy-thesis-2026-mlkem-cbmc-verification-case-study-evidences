#!/usr/bin/env python3
from __future__ import annotations
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.common.workflow_policy import critic_transition, normalise_critic_gate, tool_transition

def main()->int:
    assert normalise_critic_gate({"final_gate":"approved_for_tool_execution","tool_execution_allowed":True})=="approved_for_tool_execution"
    assert normalise_critic_gate({"final_gate":"approved_for_tool_execution","tool_execution_allowed":False})=="missing_gate"
    assert critic_transition("human_review_required",iteration=0,max_iterations=1).action=="stop_for_human_review"
    assert critic_transition("blocked_due_to_deterministic_critical_issue",iteration=0,max_iterations=1).action=="repair_then_rereview"
    assert critic_transition("blocked_due_to_deterministic_critical_issue",iteration=1,max_iterations=1).action=="stop_iteration_limit"
    assert critic_transition("approved_for_tool_execution",iteration=0,max_iterations=0).action=="execute_tool"
    assert tool_transition(result_classification="analysis_only_no_formal_tool_claim",selected_property_verified=False,iteration=0,max_iterations=0).action=="stop_analysis_only"
    assert tool_transition(result_classification="selected_property_verified_under_recorded_model",selected_property_verified=True,iteration=0,max_iterations=0).action=="stop_verified"
    failed = {"result_classification":"verification_failed_or_unknown","emitted_failure_count":1,"emitted_unknown_count":0}
    unknown = {"result_classification":"verification_failed_or_unknown","emitted_failure_count":0,"emitted_unknown_count":1}
    assert tool_transition(result_classification=failed,selected_property_verified=False,iteration=0,max_iterations=1).action=="repair_from_tool_evidence"
    assert tool_transition(result_classification=failed,selected_property_verified=False,iteration=1,max_iterations=1).action=="stop_iteration_limit"
    assert tool_transition(result_classification=unknown,selected_property_verified=False,iteration=0,max_iterations=1).action=="stop_model_or_evidence_investigation"
    print("WORKFLOW STATE POLICY REGRESSION: PASS")
    return 0
if __name__=='__main__': raise SystemExit(main())
