#!/usr/bin/env python3
from __future__ import annotations
import argparse,hashlib,json,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.tool_execution_agent import ToolExecutionConfig,materialize_execution_plan,load_config
from agents.common.formal_build import sha256_json

reviewed={
 'schema_version':'formal_build_plan.v3.strategy_reconciled_readiness_bound',
 'extra_cbmc_args':['--unwind','10','--json-ui'],
 'argument_provenance':{'extra_cbmc_args':[
  {'argument':'--unwind','source':'reviewed_config','position':0},
  {'argument':'10','source':'reviewed_config','position':1},
  {'argument':'--json-ui','source':'reviewed_config','position':2},
 ]},
 'execution_mode':'reviewed','unwind':10,
}
with tempfile.TemporaryDirectory(prefix='override_provenance_') as td:
 cfg=ToolExecutionConfig(
  run_dir=Path(td),execution_mode='user_forced_review_bypass',force_run=True,
  extra_cbmc_args=['--unwind','20','--xml-ui','--custom-flag'],
  extra_cbmc_arg_records=[
   {'argument':'--unwind','source':'cli.--cbmc-arg','position':0},
   {'argument':'20','source':'cli.--cbmc-arg','position':1},
   {'argument':'--xml-ui','source':'cli.--cbmc-arg','position':2},
   {'argument':'--custom-flag','source':'cli.--cbmc-arg','position':3},
  ],
  argument_conflict_policy='record_and_continue',unwind=20,
 )
 plan,record=materialize_execution_plan(reviewed,cfg)
 assert plan['extra_cbmc_args']==['--unwind','10','--json-ui','--unwind','20','--xml-ui','--custom-flag']
 assert plan['execution_mode']=='user_forced_review_bypass' and plan['unwind']==20
 assert record['reviewed_plan_sha256']==sha256_json(reviewed)
 assert record['executed_plan_sha256']==sha256_json(plan)
 assert record['plan_changed_after_review'] is True
 assert record['semantic_provenance_reduced'] is True and record['force_run'] is True
 assert record['argument_conflicts'],record
 options={row['option'] for row in record['argument_conflicts']}
 assert {'--unwind','__ui_mode__'}<=options,options
 assert len(record['record_sha256'])==64
 # User records retain their source and final position.
 rows=plan['argument_provenance']['extra_cbmc_args']
 assert any(r.get('source')=='cli.--cbmc-arg' and r.get('user_override') is True for r in rows)

 cfg.argument_conflict_policy='error'
 try: materialize_execution_plan(reviewed,cfg)
 except ValueError as exc: assert 'Conflicting user CBMC arguments' in str(exc)
 else: raise AssertionError('conflict policy=error did not fail closed')

 # CLI freedom flags outrank a template's reviewed default and are never silent.
 config=Path(td)/'config.json'
 config.write_text(json.dumps({
  'project_root':td,'run_id':'r','output_root':'runs',
  'tool_execution':{'execution_mode':'reviewed','extra_cbmc_args':['--bounds-check']},
  'inputs':{'spec_paths':[],'code_paths':[]},
  'property_discovery':{'mode':'targeted_campaign'},
  'property_campaign':{'property_family_id':'P16','verification_strategy':'standard_cbmc_harness'},
  'llm':{'mode':'mock','model':'mock'},'max_iterations':0,
 }))
 def args(**changes):
  values=dict(config=str(config),run_dir=None,cbmc_arg=None,unwind=None,target_function=None,target_topic=None,
   working_directory=None,force_run=False,allow_missing_gate=False,allow_missing_harness=False,
   dry_run=True,cbmc_binary=None,cbmc_function=None,timeout_seconds=None,pipeline_timeout_seconds=None,
   iteration=0,artifact=None)
  values.update(changes); return argparse.Namespace(**values)
 _,forced=load_config(args(force_run=True,cbmc_arg='--pointer-check'))
 assert forced.execution_mode=='user_forced_review_bypass'
 assert forced.extra_cbmc_args==['--bounds-check','--pointer-check']
 assert forced.extra_cbmc_arg_records[-1]['source']=='cli.--cbmc-arg'
 _,raw=load_config(args(allow_missing_harness=True))
 assert raw.execution_mode=='raw_manual' and raw.allow_missing_harness is True
print('USER OVERRIDE COMMAND PROVENANCE: PASS')
