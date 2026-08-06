#!/usr/bin/env python3
"""Run the complete final trust-chain release gate.

This runner keeps ordinary/fake-tool regressions separate from the mandatory
real CBMC 6.9.0 acceptance, so a missing formal tool can never be counted as a
passing regression.
"""
from __future__ import annotations
import argparse,hashlib,json,os,subprocess,sys,tempfile
from datetime import datetime,timezone
from pathlib import Path

def sha(p:Path)->str:
 h=hashlib.sha256();
 with p.open('rb') as f:
  for chunk in iter(lambda:f.read(1024*1024),b''): h.update(chunk)
 return h.hexdigest()

def run(cmd,env=None):
 print('+',' '.join(str(x) for x in cmd),flush=True)
 return subprocess.run([str(x) for x in cmd],env=env,check=False).returncode

def main()->int:
 ap=argparse.ArgumentParser(description=__doc__)
 ap.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1])
 ap.add_argument('--python',default=sys.executable)
 ap.add_argument('--output-dir',type=Path)
 ap.add_argument('--timeout-seconds',type=int,default=300)
 ap.add_argument('--allow-real-cbmc-pending',action='store_true',help='Development only: do not claim final real-tool acceptance.')
 args=ap.parse_args(); root=args.root.resolve()
 out=(args.output_dir or Path(tempfile.mkdtemp(prefix='final_trust_chain_'))).resolve(); out.mkdir(parents=True,exist_ok=True)
 regression_dir=out/'regressions'
 rc=run([args.python,root/'scripts/run_regressions.py','--root',root,'--python',args.python,'--timeout-seconds',args.timeout_seconds,'--output-dir',regression_dir])
 if rc: return rc
 env=os.environ.copy(); env['PYTHONDONTWRITEBYTECODE']='1'
 env['CBMC_ACCEPTANCE_REPORT']=str(out/'real_cbmc_6_9_acceptance.json')
 env['REQUIRE_REAL_CBMC']='0' if args.allow_real_cbmc_pending else '1'
 real=run([args.python,root/'tests/accept_real_cbmc_69.py'],env=env)
 real_passed=real==0 and (out/'real_cbmc_6_9_acceptance.json').is_file()
 status='passed' if real_passed else ('pending' if args.allow_real_cbmc_pending else 'failed')
 report={
  'schema_version':'final_trust_chain_acceptance.v1','created_utc':datetime.now(timezone.utc).isoformat(),
  'root':str(root),'root_test_inventory_sha256':sha(regression_dir/'regression_results.json'),
  'ordinary_regressions_passed':rc==0,'real_cbmc_6_9_status':status,
  'real_cbmc_report':str(out/'real_cbmc_6_9_acceptance.json') if real_passed else None,
  'all_mandatory_gates_passed':rc==0 and real_passed,
  'claim_boundary':'Final release acceptance requires both ordinary regressions and a real installed CBMC 6.9.0 grammar/transformation/property-listing report.'
 }
 (out/'final_acceptance.json').write_text(json.dumps(report,indent=2)+'\n')
 print('Final acceptance report:',out/'final_acceptance.json')
 if report['all_mandatory_gates_passed']:
  print('FINAL TRUST-CHAIN ACCEPTANCE: PASS'); return 0
 if args.allow_real_cbmc_pending:
  print('FINAL TRUST-CHAIN ACCEPTANCE: REAL CBMC 6.9.0 PENDING'); return 75
 print('FINAL TRUST-CHAIN ACCEPTANCE: FAILED',file=sys.stderr); return 1
if __name__=='__main__': raise SystemExit(main())
