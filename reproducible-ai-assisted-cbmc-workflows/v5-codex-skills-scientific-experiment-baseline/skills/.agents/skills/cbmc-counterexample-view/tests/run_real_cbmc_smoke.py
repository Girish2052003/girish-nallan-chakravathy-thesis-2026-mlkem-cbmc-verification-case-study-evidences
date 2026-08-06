#!/usr/bin/env python3
"""Pending Ubuntu smoke test using a real CBMC executable."""
from __future__ import annotations
import argparse, hashlib, json, subprocess, sys, tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "build_counterexample_view.py"

def walk(v):
    if isinstance(v, dict):
        yield v
        for x in v.values(): yield from walk(x)
    elif isinstance(v, list):
        for x in v: yield from walk(x)

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--cbmc',default='/usr/bin/cbmc'); args=ap.parse_args()
    cbmc=Path(args.cbmc)
    if not cbmc.is_file():
        print(f"PENDING: CBMC not found at {cbmc}"); return 4
    with tempfile.TemporaryDirectory() as td:
        td=Path(td); inp=td/'input'; inp.mkdir(); out=td/'view'
        c=inp/'smoke.c'
        c.write_text('int main(void){int x; __CPROVER_assume(x==1); __CPROVER_assert(x==2,"smoke failure"); return 0;}\n')
        raw=inp/'analysis.stdout.json'
        run=subprocess.run([str(cbmc),'--json-ui','--trace',str(c)],stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
        raw.write_bytes(run.stdout)
        try: doc=json.loads(run.stdout.decode('utf-8'))
        except Exception as e:
            print('FAIL: real CBMC output was not JSON:',e); print(run.stderr.decode(errors='replace')); return 2
        recs=[o for o in walk(doc) if isinstance(o,dict) and o.get('property') and isinstance(o.get('trace'),list) and str(o.get('status','')).lower() in {'failure','failed','fail','violated'}]
        if not recs:
            print('FAIL: no failed property with trace found'); return 2
        pid=str(recs[0]['property'])
        req={"schema_version":"1.0","request_id":"real-cbmc-smoke","trace_source":{"path":"analysis.stdout.json","expected_sha256":hashlib.sha256(raw.read_bytes()).hexdigest(),"format":"cbmc-json-ui"},"failed_property_id":pid,"selection":{"target_variables":["x"],"target_function":"main","source_files":[str(c)],"context_steps":1,"max_selected_steps":100,"tail_steps_when_unfocused":50,"include_hidden_steps":False,"include_function_steps":True,"include_assumption_steps":True,"include_location_steps":False}}
        rp=td/'request.json'; rp.write_text(json.dumps(req,sort_keys=True,indent=2)+'\n')
        view=subprocess.run([sys.executable,str(SCRIPT),'--request',str(rp),'--input-root',str(inp),'--output-dir',str(out)],check=False)
        if view.returncode != 0:
            print('FAIL: view script returned',view.returncode); return 2
        report=json.loads((out/'counterexample_view_report.json').read_text())
        print('REAL_CBMC_SMOKE_PASS')
        print(json.dumps({"cbmc":str(cbmc),"property":pid,"report_status":report['report_status'],"selected_steps":report['trace_counts']['selected']},sort_keys=True))
        return 0
if __name__=='__main__': raise SystemExit(main())
