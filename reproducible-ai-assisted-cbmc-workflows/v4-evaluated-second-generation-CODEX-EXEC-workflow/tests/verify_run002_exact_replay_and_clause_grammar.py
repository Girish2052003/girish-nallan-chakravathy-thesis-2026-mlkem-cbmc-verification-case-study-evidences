#!/usr/bin/env python3
from __future__ import annotations
import hashlib,json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.common.contract_artifacts import build_contract_header, validate_contract_plan
from agents.common.exact_traceability import build_traceability_record

FIX=ROOT/'tests/fixtures/run002_contract_and_traceability_failure'
def sha(p:Path)->str: return hashlib.sha256(p.read_bytes()).hexdigest()
def content(name:str):
 d=json.loads((FIX/name).read_text()); return d.get('content',d)
# Fixture self-integrity and exact source provenance.
for line in (FIX/'SHA256SUMS').read_text().splitlines():
 digest,name=line.split('  ',1); assert sha(FIX/name)==digest,(name,digest,sha(FIX/name))
manifest=json.loads((FIX/'SOURCE_MANIFEST.json').read_text())
assert manifest['copy_only'] is True and manifest['source_run_modified'] is False
for row in manifest['files']:
 src=ROOT/row['source_path']; assert src.is_file(),src
 assert sha(src)==row['sha256']==sha(FIX/row['fixture_path'])

plan=content('artifact_plan.json.fixture')
contract=plan['contract_plan']
validation=validate_contract_plan(contract,plan['verification_strategy'],strict_typed=True)
assert validation['valid'] is False,validation
errors='\n'.join(validation['errors'])
assert 'typed clause records' in errors
assert "Unsupported mathematical/ACSL-style array range '[start .. end]'" in errors
try:
 build_contract_header(contract)
except ValueError as exc:
 assert 'Unsupported mathematical/ACSL-style array range' in str(exc)
else:
 raise AssertionError('Run 002 pseudo-slice contract was rendered instead of rejected.')

harness=(FIX/'generated_harness.c').read_text()
trace=build_traceability_record(
 harness_text=harness,target_function='mlk_poly_add',property_id='OPEN_CAND_002',
 claim_ids=['C01','C02'],assumption_ids=['A01'],
)
assert trace['valid'] is False,trace
joined='\n'.join(trace['errors'])
assert 'TRACE_TARGET_CALL::OPEN_CAND_002' in joined
assert 'TRACE_CLAIM::OPEN_CAND_002::C01' in joined
assert 'TRACE_CLAIM::OPEN_CAND_002::C02' in joined

historic_trace=content('traceability_validation.json.fixture')
assert historic_trace['valid'] is False
issue_ids={row['issue_id'] for row in historic_trace.get('hard_blockers',[])}
assert {'target_call_missing_or_irrelevant','selected_property_unreachable'} <= issue_ids
readiness=content('frontend_readiness.json.fixture')
assert readiness['frontend_parse_and_build_ready'] is False
assert readiness['formal_property_evaluated'] is False
assert readiness['classification']=='hard_frontend_parse_or_build_defect'
stderr=(FIX/'frontend_readiness.stderr.txt.fixture').read_text()
assert "syntax error before '.'" in stderr and 'PARSING ERROR' in stderr
gate=content('review_gate.json.fixture')
assert gate['tool_execution_allowed'] is False
assert gate['final_gate']=='blocked_hard_tool_readiness_defect'
print('RUN 002 EXACT REPLAY + CLAUSE GRAMMAR REGRESSION: PASS')
