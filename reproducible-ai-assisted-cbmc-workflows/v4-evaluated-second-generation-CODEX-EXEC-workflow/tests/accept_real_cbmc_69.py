#!/usr/bin/env python3
"""Mandatory real CBMC 6.9.0 grammar/transformation acceptance.

Default developer containers may skip when the binaries are unavailable. The
final Ubuntu release gate MUST invoke this with REQUIRE_REAL_CBMC=1.
"""
from __future__ import annotations
import hashlib,json,os,shutil,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path: sys.path.insert(0,str(ROOT))
from agents.common.cbmc_capability import normalize_clause_record,validate_clause_record

REQUIRED=os.environ.get('REQUIRE_REAL_CBMC','0')=='1'
REPORT=Path(os.environ.get('CBMC_ACCEPTANCE_REPORT',str(ROOT/'reports/FINAL_REAL_CBMC_6_9_ACCEPTANCE.json')))
TOOLS={name:shutil.which(name) for name in ('goto-cc','goto-instrument','cbmc')}
if not all(TOOLS.values()):
 msg='missing tools: '+', '.join(k for k,v in TOOLS.items() if not v)
 if REQUIRED:
  raise SystemExit('REAL CBMC ACCEPTANCE FAILED: '+msg)
 print('REAL CBMC 6.9.0 ACCEPTANCE: SKIPPED ('+msg+'; final Ubuntu gate must set REQUIRE_REAL_CBMC=1)')
 raise SystemExit(0)

records=[]
def sha(path:Path)->str: return hashlib.sha256(path.read_bytes()).hexdigest()
def run(case,cmd,expect_success=True,cwd=None):
 proc=subprocess.run([str(x) for x in cmd],cwd=cwd,text=True,capture_output=True,timeout=90,check=False)
 rec={'case':case,'command':[str(x) for x in cmd],'exit_code':proc.returncode,'stdout':proc.stdout,'stderr':proc.stderr}
 records.append(rec)
 ok=proc.returncode==0
 if ok!=expect_success:
  raise AssertionError(f"{case}: expected success={expect_success}, exit={proc.returncode}\nSTDOUT:\n{proc.stdout}\nSTDERR:\n{proc.stderr}")
 return proc

versions={}
for name,path in TOOLS.items():
 proc=run('version_'+name,[path,'--version'])
 text=(proc.stdout or proc.stderr).strip(); versions[name]=text.splitlines()[0] if text else ''
 assert '6.9.0' in text,(name,text)

# Static gate and real frontend must agree on the known Run 002 pseudo-slice.
valid_assign=normalize_clause_record({
 'clause_id':'A','clause_kind':'assigns','description':'whole range',
 'executable_expression':'__CPROVER_object_upto(p, sizeof(int) * n)',
 'bound_symbols':['p','n'],'evidence_references':[],'expected_property_identity':'TRACE_CLAIM::REAL::ASSIGNS'
},clause_kind='assigns',index=0)
assert validate_clause_record(valid_assign,strict_typed=True)['valid'] is True
for bad in ('p[0 .. n - 1]','p[0:n]','__CPROVER_object_upto(p)'):
 rec=normalize_clause_record({'clause_id':'B','clause_kind':'assigns','executable_expression':bad},clause_kind='assigns',index=0)
 assert validate_clause_record(rec,strict_typed=True)['valid'] is False,bad

with tempfile.TemporaryDirectory(prefix='real_cbmc_69_') as td:
 t=Path(td)
 def write(name,text): p=t/name; p.write_text(text); return p
 valid=write('valid_contract.c',r'''
#include <stddef.h>
void target(int *p)
  __CPROVER_requires(p != 0)
  __CPROVER_requires(__CPROVER_rw_ok(p, sizeof(*p)))
  __CPROVER_assigns(*p)
  __CPROVER_ensures(*p == __CPROVER_old(*p) + 1)
{
  *p = *p + 1;
}
void range_target(int *p, size_t n)
  __CPROVER_requires(__CPROVER_rw_ok(p, n * sizeof(*p)))
  __CPROVER_assigns(__CPROVER_object_upto(p, n * sizeof(*p)))
{
  for(size_t i=0; i<n; ++i) p[i]=0;
}
void harness(void)
{
  int x;
  /* TRACE_TARGET_CALL::REAL_FUNCTION */
  target(&x);
  __CPROVER_assert(1, "TRACE_CLAIM::REAL_FUNCTION::C01");
}
''')
 valid_gb=t/'valid.gb'; run('valid_requires_ensures_assigns_object_upto',[TOOLS['goto-cc'],'--function','harness','-o',valid_gb,valid])
 assert valid_gb.is_file()
 transformed=t/'function_contract.gb'
 run('function_contract_transformation',[TOOLS['goto-instrument'],'--dfcc','harness','--enforce-contract','target',valid_gb,transformed])
 assert transformed.is_file()
 listing=run('function_contract_property_listing',[TOOLS['cbmc'],transformed,'--function','harness','--show-properties','--json-ui'])
 json.loads(listing.stdout)
 assert 'TRACE_CLAIM::REAL_FUNCTION::C01' in listing.stdout

 invalid_cases={
  'invalid_prose_requires':r'''void f(int *p) __CPROVER_requires(p points to writable memory) { }''',
  'invalid_dotdot_assigns':r'''void f(int *p) __CPROVER_assigns(p[0 .. 3]) { }''',
  'invalid_colon_assigns':r'''void f(int *p) __CPROVER_assigns(p[0:3]) { }''',
  'invalid_object_upto_arity':r'''void f(int *p) __CPROVER_assigns(__CPROVER_object_upto(p)) { }''',
  'invalid_undefined_symbol':r'''void f(int *p) __CPROVER_requires(undefined_symbol > 0) { }''',
 }
 for name,source in invalid_cases.items():
  path=write(name+'.c',source+'\n'); run(name,[TOOLS['goto-cc'],'--function','f','-o',t/(name+'.gb'),path],expect_success=False)

 loop=write('loop_contract.c',r'''
void loop_harness(void)
{
  int a[4];
  int i;
  for(i=0; i<4; ++i)
    __CPROVER_assigns(i, __CPROVER_object_upto(a, sizeof(a)))
    __CPROVER_loop_invariant(0 <= i && i <= 4)
    __CPROVER_decreases(4 - i)
  {
    a[i]=i;
  }
  __CPROVER_assert(i == 4, "TRACE_CLAIM::REAL_LOOP::C01");
}
''')
 loop_gb=t/'loop.gb'; run('valid_loop_invariant_decreases',[TOOLS['goto-cc'],'--function','loop_harness','-o',loop_gb,loop])
 loop_tx=t/'loop_tx.gb'; run('loop_contract_transformation',[TOOLS['goto-instrument'],'--apply-loop-contracts',loop_gb,loop_tx])
 loop_listing=run('loop_property_listing',[TOOLS['cbmc'],loop_tx,'--function','loop_harness','--show-properties','--json-ui'])
 json.loads(loop_listing.stdout); assert 'TRACE_CLAIM::REAL_LOOP::C01' in loop_listing.stdout

 hybrid=write('hybrid_contract.c',r'''
void target(int *p)
  __CPROVER_requires(p != 0)
  __CPROVER_assigns(*p)
  __CPROVER_ensures(*p == 7)
{ *p=7; }
void hybrid_harness(void)
{
  int a[2]; int i; int x;
  for(i=0; i<2; ++i)
    __CPROVER_assigns(i, __CPROVER_object_upto(a, sizeof(a)))
    __CPROVER_loop_invariant(0 <= i && i <= 2)
    __CPROVER_decreases(2-i)
  { a[i]=i; }
  target(&x);
  __CPROVER_assert(x == 7, "TRACE_CLAIM::REAL_HYBRID::C01");
}
''')
 h0=t/'hybrid0.gb'; h1=t/'hybrid1.gb'; h2=t/'hybrid2.gb'
 run('hybrid_compile',[TOOLS['goto-cc'],'--function','hybrid_harness','-o',h0,hybrid])
 run('hybrid_loop_transformation',[TOOLS['goto-instrument'],'--apply-loop-contracts',h0,h1])
 run('hybrid_function_transformation',[TOOLS['goto-instrument'],'--dfcc','hybrid_harness','--enforce-contract','target',h1,h2])
 hlist=run('hybrid_property_listing',[TOOLS['cbmc'],h2,'--function','hybrid_harness','--show-properties','--json-ui'])
 json.loads(hlist.stdout); assert 'TRACE_CLAIM::REAL_HYBRID::C01' in hlist.stdout

 artifacts={p.name:sha(p) for p in t.iterdir() if p.is_file()}

report={
 'schema_version':'real_cbmc_6_9_acceptance.v1','required':REQUIRED,'passed':True,
 'versions':versions,'tools':TOOLS,'cases':records,'artifact_sha256':artifacts,
 'claim_boundary':'This validates real CBMC 6.9.0 grammar, transformation and property listing; it does not prove the thesis target property.'
}
REPORT.parent.mkdir(parents=True,exist_ok=True); REPORT.write_text(json.dumps(report,indent=2)+'\n')
print('REAL CBMC 6.9.0 ACCEPTANCE: PASS')
print('Report:',REPORT)
