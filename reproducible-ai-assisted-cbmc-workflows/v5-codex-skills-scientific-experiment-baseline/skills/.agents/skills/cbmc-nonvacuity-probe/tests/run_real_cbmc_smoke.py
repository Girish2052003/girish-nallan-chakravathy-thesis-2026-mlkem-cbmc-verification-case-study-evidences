#!/usr/bin/env python3
"""Run the frozen skill against a real local CBMC executable.

This test is intentionally separate from the synthetic unit suite. It creates a
fresh temporary copy of the generic fixture, runs two disposable coverage probes,
and requires the skill to parse real CBMC JSON without changing the fixture.
"""
from __future__ import annotations
import argparse, hashlib, json, shutil, subprocess, sys, tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
SCRIPT=ROOT/'scripts/run_nonvacuity_probe.py'
FIXTURE=ROOT/'tests/fixtures/repository'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--cbmc', default='/usr/bin/cbmc')
    ns=ap.parse_args()
    cbmc=Path(ns.cbmc).resolve()
    if cbmc.name!='cbmc' or not cbmc.is_file():
        print(f'REAL_CBMC_SMOKE_SKIPPED: executable not found: {cbmc}', file=sys.stderr)
        return 77
    with tempfile.TemporaryDirectory(prefix='skill07-real-cbmc-') as td:
        td=Path(td); repo=td/'repo'; shutil.copytree(FIXTURE,repo); out=td/'evidence'; request=td/'request.json'
        req={
          'schema_version':'1.0','skill_version':'1.0.0-rc1','target_symbol':'vector_subtract',
          'tracked_inputs':[
            {'path':'harness.c','sha256':sha(repo/'harness.c'),'role':'candidate-harness'},
            {'path':'include/vector.h','sha256':sha(repo/'include/vector.h'),'role':'header'},
            {'path':'src/vector.c','sha256':sha(repo/'src/vector.c'),'role':'production-source'}],
          'analysis_source_files':['harness.c','src/vector.c'],
          'build_context':{'include_dirs':['include'],'defines':[],'undefines':[],'extra_arguments':['--unwind','5'],'entry_function':'main'},
          'cbmc':{'executable':str(cbmc),'timeout_seconds':60,'environment':{}},
          'probes':[
            {'id':'target-call','kind':'TARGET_CALL_REACHABILITY','source_path':'harness.c','anchor_line':'vector_subtract(result, left, right);','occurrence':1,'insertion_position':'before','required':True,'note':'Real CBMC target-call reachability smoke.'},
            {'id':'assertion-location','kind':'ASSERTION_LOCATION_REACHABILITY','source_path':'harness.c','anchor_line':'__CPROVER_assert(result[0] == left[0] - right[0], "component zero");','occurrence':1,'insertion_position':'before','required':True,'note':'Real CBMC assertion-location reachability smoke.'}
          ],'notes':'Real CBMC smoke test.'}
        request.write_text(json.dumps(req,sort_keys=True,indent=2)+'\n')
        cp=subprocess.run([sys.executable,str(SCRIPT),'--request',str(request),'--probe-root',str(repo),'--output-dir',str(out)],text=True)
        if cp.returncode != 0:
            print(f'REAL_CBMC_SMOKE_FAIL: wrapper exit {cp.returncode}', file=sys.stderr)
            if (out/'nonvacuity_probe_report.json').exists(): print((out/'nonvacuity_probe_report.json').read_text(), file=sys.stderr)
            return 1
        report=json.loads((out/'nonvacuity_probe_report.json').read_text())
        statuses={p['probe_id']:p['reachability_status'] for p in report['probe_results']}
        if any(v!='REACHED_REPORTED_BY_CBMC' for v in statuses.values()):
            print('REAL_CBMC_SMOKE_FAIL: expected both fixture probes to be reported reached', statuses, file=sys.stderr)
            return 1
        if not report['authoritative_inputs_unchanged']:
            print('REAL_CBMC_SMOKE_FAIL: authoritative inputs changed', file=sys.stderr); return 1
        print('REAL_CBMC_SMOKE_PASS')
        print(json.dumps({'cbmc':str(cbmc),'statuses':statuses},sort_keys=True))
        return 0
if __name__=='__main__': raise SystemExit(main())
