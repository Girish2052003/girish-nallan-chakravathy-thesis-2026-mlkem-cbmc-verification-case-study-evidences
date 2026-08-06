#!/usr/bin/env python3
"""Run the generic fixture using real GCC and CBMC.

This test is intentionally separate from local controlled-tool tests. It does not
claim that a status difference proves property quality.
"""
from __future__ import annotations
import argparse, hashlib, json, pathlib, shutil, subprocess, sys, tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "run_controlled_mutation.py"
FIXTURE = ROOT / "tests" / "fixtures" / "project"

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--cbmc',default='/usr/bin/cbmc'); ap.add_argument('--gcc',default='/usr/bin/gcc'); ns=ap.parse_args()
    for exe in (pathlib.Path(ns.cbmc), pathlib.Path(ns.gcc)):
        if not exe.exists():
            print(f"MISSING EXECUTABLE: {exe}", file=sys.stderr); return 2
    tmp=pathlib.Path(tempfile.mkdtemp(prefix='real-controlled-mutation-'))
    try:
        work=tmp/'workspace'; shutil.copytree(FIXTURE,work)
        req=json.loads((ROOT/'examples/request.example.json').read_text())
        req['execution']['cbmc']['executable']=str(pathlib.Path(ns.cbmc).resolve())
        req['execution']['syntax_check']['executable']=str(pathlib.Path(ns.gcc).resolve())
        # Do not assume a version-specific property identifier in the smoke test.
        req['expected_transition']=None
        reqp=tmp/'request.json'; reqp.write_text(json.dumps(req,indent=2,sort_keys=True)+'\n')
        out=tmp/'evidence'
        cp=subprocess.run([sys.executable,str(SCRIPT),'--request',str(reqp),'--workspace-root',str(work),'--output-dir',str(out)],text=True)
        if not (out/'comparison_report.json').exists(): return cp.returncode or 2
        report=json.loads((out/'comparison_report.json').read_text())
        print(json.dumps({
            'process_exit':cp.returncode,
            'baseline_cbmc_outcome':report['baseline_cbmc_outcome'],
            'mutant_cbmc_outcome':report['mutant_cbmc_outcome'],
            'authoritative_tree_unchanged':json.loads((out/'authoritative_integrity_comparison.json').read_text())['authoritative_tree_unchanged'],
            'disposable_workspaces_removed':json.loads((out/'cleanup_and_restoration_report.json').read_text())['disposable_workspaces_removed'],
        },indent=2,sort_keys=True))
        return cp.returncode
    finally:
        shutil.rmtree(tmp,ignore_errors=True)

if __name__=='__main__': raise SystemExit(main())
