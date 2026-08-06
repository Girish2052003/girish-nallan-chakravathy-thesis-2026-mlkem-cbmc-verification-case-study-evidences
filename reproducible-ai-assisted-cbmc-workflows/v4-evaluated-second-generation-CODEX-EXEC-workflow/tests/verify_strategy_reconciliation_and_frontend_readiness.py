#!/usr/bin/env python3
from pathlib import Path
import tempfile, json, stat, sys
ROOT=Path(__file__).resolve().parents[1]; sys.path.insert(0,str(ROOT))
from agents.common.formal_build import create_formal_build_plan, run_frontend_readiness_check, sha256_json, validate_formal_build_plan
from agents.common.run_layout import RunLayout
from agents.tool_execution_agent import load_handoff_path

def exe(p,text): p.write_text(text); p.chmod(p.stat().st_mode|stat.S_IXUSR)
with tempfile.TemporaryDirectory() as td:
 t=Path(td); h=t/'h.c'; s=t/'s.c'
 property_id='TEST_PROP'; claim_id='C01'
 claim_identity=f'TRACE_CLAIM::{property_id}::{claim_id}'
 h.write_text(
  'void target(void);\n'
  'void harness(void){\n'
  f'  /* TRACE_TARGET_CALL::{property_id} */\n'
  '  target();\n'
  f'  __CPROVER_assert(1, "{claim_identity}");\n'
  '}\n'
 )
 s.write_text('void target(void){}\n')
 semantic={
  'schema_version':'semantic_property.v2','property_id':property_id,
  'statement':'The exact harness assertion holds after the exact target call.',
  'target_call':{'function':'target','arguments':[],'call_count':1},
  'pre_state_objects':[],'post_state_objects':[],'observed_memory':[],
  'permitted_writes':[],'required_assumptions':[],'success_predicate':'1',
  'quantified_domain':{'variable':'','lower_bound':'','upper_bound_exclusive':''},
  'requires_pre_state_snapshot':False,'requires_modular_call_replacement':False,
  'requires_loop_reasoning':False,'requires_relational_execution':False,
  'analysis_only':False,'evidence_references':[],'uncertainty':'Regression fixture.',
  'semantic_completeness':{'complete':True,'missing_fields':[],'claim_boundary':'Structural completeness is not proof.'},
 }
 base={
  'project_root':str(t),'inputs':{'code_paths':[str(s)]},
  'tool_execution':{'source_files':[str(s)],'include_paths':[str(t)]},
  'formal_artifact_policy':{'require_typed_contract_clauses':True,'require_explicit_source_units':True},
  'formal_strategy_reconciliation':{
   'mode':'evidence_bound','allow_optional_contract_to_harness_fallback':True,
   'request_optional_contract_to_harness_fallback':True,
  },'property_campaign':{}
 }
 invalid_clause={
  'clause_id':'REQ01','clause_kind':'requires','description':'Malformed prose fixture.',
  'executable_expression':'target is valid prose','bound_symbols':['target'],
  'evidence_references':[],'expected_property_identity':'',
 }
 optional={
  'verification_strategy':'native_function_contract','semantic_property':semantic,
  'contract_plan':{
   'enabled':True,'contract_mode':'function','target_symbol':'target',
   'function_declaration':'void target(void)','requires_clauses':[invalid_clause],
   'ensures_clauses':[],'assigns_clauses':[],'frees_clauses':[],
   'loop_invariant_clauses':[],'decreases_clauses':[],
   'loop_assigns_clauses':[],'loop_frees_clauses':[],
   'source_patch_operations':[],'apply_loop_contracts':False,
   'enforce_contract':True,'replace_calls_with_contract':[],'use_dfcc':True,
  },
  'traceability_manifest':{
   'selected_property_id':property_id,
   'target_call_marker':f'TRACE_TARGET_CALL::{property_id}',
   'target_call_identity':f'TRACE_TARGET_CALL::{property_id}',
   'target_call_expression':'target()',
   'expected_claim_count':1,'assumption_map':[],
   'claim_map':[{
    'assertion_id':claim_id,'implementation_kind':'harness_assertion',
    'code_marker':claim_identity,'expected_property_identity':claim_identity,
    'expression_sha256':'','rationale':'Exact selected claim in the harness.',
   }],
   'non_vacuity_strategy':['Exact assertion is generated after the target call.'],
  },
 }
 p=create_formal_build_plan(base,h,target_function='target',artifact_plan=optional,artifact_manifest={})
 assert p['effective_execution_strategy']=='standard_cbmc_harness', p['strategy_reconciliation']
 assert p['strategy_reconciliation']['fallback_conditions_satisfied'] is True
 assert p['strategy_reconciliation']['strategy_reconciliation_applied'] is True
 dependent=json.loads(json.dumps(optional))
 dependent['traceability_manifest']['claim_map'][0]['implementation_kind']='contract_ensures'
 p2=create_formal_build_plan(base,h,target_function='target',artifact_plan=dependent,artifact_manifest={})
 assert p2['effective_execution_strategy']=='native_function_contract'
 assert not p2['validation']['valid']
 # Legacy/mock compatibility may use a clearly labelled host-C syntax fallback.
 fallback=run_frontend_readiness_check(p,output_dir=t/'fallback',goto_cc_binary='definitely-missing-goto-cc',timeout_seconds=5,working_directory=t)
 assert fallback['frontend_parse_and_build_ready'] is True, fallback
 assert fallback['cbmc_frontend_confirmed'] is False and fallback['fallback_used'] is True
 # Production policy must fail closed when the actual CBMC/GOTO frontend is absent.
 strict_missing=run_frontend_readiness_check(p,output_dir=t/'strict-missing',goto_cc_binary='definitely-missing-goto-cc',timeout_seconds=5,working_directory=t,require_cbmc_frontend=True)
 assert strict_missing['frontend_parse_and_build_ready'] is False, strict_missing
 assert strict_missing['classification']=='hard_frontend_tool_unavailable'
 # A fake GOTO frontend plus exact structured property listing satisfies strict route readiness.
 fake_goto=t/'goto-cc'; exe(fake_goto,"""#!/usr/bin/env python3
import pathlib,sys
args=sys.argv[1:]
out=pathlib.Path(args[args.index('-o')+1]); out.parent.mkdir(parents=True,exist_ok=True); out.write_bytes(b'GB')
raise SystemExit(0)
""")
 fake_cbmc=t/'cbmc'; exe(fake_cbmc,f"""#!/usr/bin/env python3
import json
print(json.dumps([{{'property':'{claim_identity}','description':'{claim_identity}'}}]))
raise SystemExit(0)
""")
 strict_ready=run_frontend_readiness_check(
  p,output_dir=t/'strict-ready',goto_cc_binary=str(fake_goto),cbmc_binary=str(fake_cbmc),
  timeout_seconds=5,working_directory=t,require_cbmc_frontend=True,require_full_route=True,
 )
 assert strict_ready['execution_ready'] is True, strict_ready
 assert strict_ready['full_route_ready'] is True
 assert strict_ready['cbmc_frontend_confirmed'] is True and strict_ready['fallback_used'] is False
 assert strict_ready['formal_build_plan_semantic_sha256']==sha256_json(p)
 # Agent 7 binding must reject source mutation after Agent 6 readiness.
 s.write_text('void target(void){int changed=1;(void)changed;}\n')
 rebound=validate_formal_build_plan(p,h,expected_cbmc_function='harness',expected_target_function='target')
 assert rebound['valid'] is False and any('checksum differs' in x for x in rebound['errors']), rebound
 # Agent 7 must also reject a readiness record changed after Agent 6 handoff.
 run=t/'run'; layout=RunLayout(run,create=True,active_iteration=0)
 readiness_file=layout.validation_dir('06_review_critic')/'ready.json'; readiness_file.parent.mkdir(parents=True,exist_ok=True); readiness_file.write_text('{}')
 layout.write_handoff_manifest('06_review_critic',outputs={'frontend_parse_and_build_readiness':readiness_file},authoritative_source='test',next_stage_consumers=['07_tool_execution'])
 readiness_file.write_text('{"tampered":true}')
 _, status=load_handoff_path(layout,'06_review_critic','frontend_parse_and_build_readiness')
 assert status['available'] is False and 'checksum differs' in status['warning']
print('STRATEGY RECONCILIATION + FRONTEND READINESS PASSED')
