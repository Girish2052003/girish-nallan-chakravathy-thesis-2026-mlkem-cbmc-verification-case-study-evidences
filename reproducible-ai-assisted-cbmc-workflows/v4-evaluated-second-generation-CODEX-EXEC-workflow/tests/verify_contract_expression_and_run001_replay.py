#!/usr/bin/env python3
from pathlib import Path
import json, tempfile, sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from agents.common.contract_artifacts import validate_contract_plan, build_contract_header
from agents.common.formal_build import create_formal_build_plan

def content(p):
 d=json.loads(p.read_text()); return d.get('content',d)
fix=ROOT/'tests/fixtures/run001_contract_parse_failure'
plan=content(fix/'artifact_plan.json.fixture')
validation=validate_contract_plan(plan['contract_plan'],plan['verification_strategy'])
assert not validation['valid'], validation
assert any('natural-language prose' in x for x in validation['errors'])
try:
 build_contract_header(plan['contract_plan'], required_includes=plan.get('required_includes',[]))
 raise AssertionError('renderer accepted Run001 prose')
except ValueError as exc:
 assert 'not safely renderable' in str(exc)
with tempfile.TemporaryDirectory() as td:
 root=Path(td); harness=root/'harness.c'; harness.write_bytes((fix/'generated_harness.c').read_bytes())
 source=root/'poly.c'; source.write_text('void mlk_poly_add(void *r,const void*b){}\n')
 cfg={'project_root':str(root),'inputs':{'code_paths':[str(source)]},'tool_execution':{'source_files':[str(source)],'include_paths':[str(root)]},'formal_strategy_reconciliation':{'mode':'evidence_bound','allow_optional_contract_to_harness_fallback':True},'property_campaign':{}}
 fb=create_formal_build_plan(cfg,harness,target_function='mlk_poly_add',artifact_plan=plan,artifact_manifest={})
 assert fb['requested_verification_strategy']=='native_function_contract'
 recon=fb['strategy_reconciliation']
 assert fb['effective_execution_strategy']=='native_function_contract', recon
 assert recon['strategy_reconciliation_applied'] is False
 assert recon['fallback_conditions_satisfied'] is False
 assert recon['silent_strategy_substitution_performed'] is False
 assert recon['contract_valid'] is False
 assert recon['harness_complete'] is False
print('CONTRACT EXPRESSION + EXACT RUN001 REPLAY PASSED')
