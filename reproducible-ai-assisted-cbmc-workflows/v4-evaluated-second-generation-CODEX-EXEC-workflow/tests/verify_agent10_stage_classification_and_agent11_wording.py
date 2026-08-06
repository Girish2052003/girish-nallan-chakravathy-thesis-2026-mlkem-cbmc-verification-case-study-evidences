#!/usr/bin/env python3
from __future__ import annotations
import json,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.experiment_logger import classify_stage_presence
from agents.evaluation_reporter import tool_outcome_explanation,build_agent11_prompt

with tempfile.TemporaryDirectory(prefix='stage_presence_') as td:
 run=Path(td); (run/'stages').mkdir()
 def write(status,config):
  (run/'status.json').write_text(json.dumps(status)); (run/'run_config.resolved.json').write_text(json.dumps(config))
 write({'stopped_reason':'critic_requested_repair_but_iteration_limit_reached','status':'completed_with_failures_or_unresolved_items'},{'max_iterations':0})
 assert classify_stage_presence(run,'09_repair_refinement',manifest_exists=False,stage_dir_exists=False)=='not_applicable'
 assert classify_stage_presence(run,'07_tool_execution',manifest_exists=False,stage_dir_exists=False)=='blocked_upstream'
 assert classify_stage_presence(run,'08_counterexample_analysis',manifest_exists=False,stage_dir_exists=False)=='blocked_upstream'
 write({'stopped_reason':'iteration_limit_reached','status':'completed_with_failures_or_unresolved_items'},{'max_iterations':1})
 assert classify_stage_presence(run,'09_repair_refinement',manifest_exists=False,stage_dir_exists=False)=='skipped_by_policy'
 assert classify_stage_presence(run,'05_artifact_generation',manifest_exists=False,stage_dir_exists=True)=='failed_to_write'
 assert classify_stage_presence(run,'05_artifact_generation',manifest_exists=False,stage_dir_exists=False)=='unexpectedly_missing'
 assert classify_stage_presence(run,'05_artifact_generation',manifest_exists=True,stage_dir_exists=True)=='completed'

cases={
 'contract_build_failed':'transformation failed',
 'skipped_by_review_gate':'solving was not attempted',
 'tool_success_no_selected_evidence':'selected claim was not generated',
 'selected_property_passed_auxiliary_failed_or_unknown':'selected claim passed',
 'verification_failed_or_unknown':'selected claim failed or remained unknown',
 'selected_property_verified':'selected claim passed for the recorded bounded model',
}
for classification,needle in cases.items():
 text=tool_outcome_explanation({
  'result_classification':classification,'selected_claim_result':'x',
  'auxiliary_property_result':'y','overall_model_result':'z',
 }).lower()
 assert needle in text,(classification,text)
 assert 'selected claim=x' in text and 'auxiliary properties=y' in text and 'overall model=z' in text
prompt=build_agent11_prompt(type('Cfg',(),{'target_function':'f','target_topic':'t'})(),{})
for phrase in ('solving was not attempted','auxiliary-property failure','frontend parsing failed','GOTO transformation failed'):
 assert phrase.lower() in prompt.lower(),phrase
print('AGENT10 STAGE CLASSIFICATION + AGENT11 WORDING: PASS')
