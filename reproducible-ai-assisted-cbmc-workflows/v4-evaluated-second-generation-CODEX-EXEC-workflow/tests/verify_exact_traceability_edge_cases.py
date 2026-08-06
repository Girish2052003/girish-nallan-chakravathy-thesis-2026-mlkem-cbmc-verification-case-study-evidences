#!/usr/bin/env python3
from __future__ import annotations
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.common.exact_traceability import (
    bind_target_call, bind_harness_claims, bind_harness_assumptions,
    exact_property_coverage, expected_claim_identity, sha256_text,
)

PROP='EDGE_PROP'; CLAIM='C01'; ASSUME='A01'
TARGET=f'TRACE_TARGET_CALL::{PROP}'
CLAIM_ID=expected_claim_identity(PROP,CLAIM)

# Comments, literals and declarations must never count as executable target calls.
text='''
void target(int x);                    /* declaration, not call */
const char *s = "target(7);";           /* literal, not call */
/* target(8); */                        /* comment, not call */
void harness(void) {
  /* TRACE_TARGET_CALL::EDGE_PROP */
  target((1 + (2 * 3)));
  __CPROVER_assert(((1 + 2) * (3 + 4)) == 21,
                   "TRACE_CLAIM::EDGE_PROP::C01");
  /* TRACE_ASSUMPTION::EDGE_PROP::A01 */
  __CPROVER_assume((1 && (2 > 1)));
}
'''
target=bind_target_call(text,function_name='target',property_id=PROP)
assert target['valid'] is True,target
assert target['call_count']==1,target
claims=bind_harness_claims(text,property_id=PROP,expected_claim_ids=[CLAIM])
assert claims['valid'] is True,claims
assert claims['bindings'][0]['expression']=='((1 + 2) * (3 + 4)) == 21'
assumptions=bind_harness_assumptions(text,property_id=PROP,expected_assumption_ids=[ASSUME])
assert assumptions['valid'] is True,assumptions

# Marker must be immediately and uniquely bound; arbitrary code in between is rejected.
misplaced='''
void target(void);
void h(void){
 /* TRACE_TARGET_CALL::EDGE_PROP */
 int unrelated = 1;
 target();
}
'''
record=bind_target_call(misplaced,function_name='target',property_id=PROP)
assert record['valid'] is False,record
assert any('found 0' in e for e in record['errors'])

# Multiple exact bindings are ambiguous and must fail closed.
duplicate_targets='''
void target(void);
void h(void){
 /* TRACE_TARGET_CALL::EDGE_PROP */ target();
 /* TRACE_TARGET_CALL::EDGE_PROP */ target();
}
'''
record=bind_target_call(duplicate_targets,function_name='target',property_id=PROP)
assert record['valid'] is False,record
assert record['call_count']==2 and record['marker_count']==2

# Duplicate exact claim identities are rejected even if expressions differ.
duplicate_claims=f'''
void h(void){{
 __CPROVER_assert(1, "{CLAIM_ID}");
 __CPROVER_assert(0, "{CLAIM_ID}");
}}
'''
record=bind_harness_claims(duplicate_claims,property_id=PROP,expected_claim_ids=[CLAIM])
assert record['valid'] is False,record
assert any('Duplicate exact claim identities' in e for e in record['errors'])

# Exact property mapping may use identity or exact normalized expression hash, never regex.
binding={'identity':CLAIM_ID,'expression_sha256':sha256_text('x == y'),'implementation_kind':'harness_assertion'}
coverage=exact_property_coverage([binding],[{'property':CLAIM_ID,'status':'SUCCESS'}])
assert coverage['coverage_complete'] is True,coverage
assert coverage['mapped_claims'][0]['matches'][0]['authority']=='exact_identity'

# One claim with duplicate matching rows is ambiguous.
coverage=exact_property_coverage([binding],[
 {'property':CLAIM_ID,'status':'SUCCESS'},
 {'description':CLAIM_ID,'status':'SUCCESS'},
])
assert coverage['coverage_complete'] is False,coverage
assert coverage['ambiguous_claim_count']==1

# One physical row cannot satisfy two unrelated selected claims.
second={'identity':'TRACE_CLAIM::EDGE_PROP::C02','expression_sha256':sha256_text('x == y'),'implementation_kind':'harness_assertion'}
coverage=exact_property_coverage([binding,second],[{'condition':'x == y','status':'SUCCESS'}])
assert coverage['coverage_complete'] is False,coverage
assert coverage['ambiguous_claim_count']>=1,coverage

# Regex-like model text is inert unless it is an exact identity/expression.
coverage=exact_property_coverage([binding],[{'description':'.*TRACE_CLAIM.*','status':'SUCCESS'}])
assert coverage['coverage_complete'] is False,coverage
assert coverage['missing_claim_count']==1

print('EXACT TRACEABILITY EDGE CASES: PASS')
