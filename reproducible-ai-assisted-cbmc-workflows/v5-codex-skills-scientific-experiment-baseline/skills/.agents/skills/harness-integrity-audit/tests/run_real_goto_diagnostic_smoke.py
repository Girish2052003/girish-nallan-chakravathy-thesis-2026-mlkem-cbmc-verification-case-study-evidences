#!/usr/bin/env python3
"""Optional Ubuntu integration smoke test for goto-cc/goto-instrument evidence.

This is not part of the deterministic audit core. It creates a disposable GOTO
binary from the synthetic fixture, captures --list-undefined-functions output,
updates a temporary request, and runs the audit.
"""
from __future__ import annotations
import argparse, hashlib, json, shutil, subprocess, tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def sha(p: Path) -> str: return hashlib.sha256(p.read_bytes()).hexdigest()

def main() -> int:
    ap=argparse.ArgumentParser()
    ap.add_argument('--goto-cc', default='goto-cc')
    ap.add_argument('--goto-instrument', default='goto-instrument')
    args=ap.parse_args()
    if shutil.which(args.goto_cc) is None or shutil.which(args.goto_instrument) is None:
        print('SKIP: goto-cc and/or goto-instrument not available')
        return 4
    with tempfile.TemporaryDirectory() as td:
        td=Path(td); repo=td/'repository'; shutil.copytree(ROOT/'tests/fixtures/repository',repo)
        gb=td/'fixture.gb'
        cc=[args.goto_cc,'-I',str(repo/'include'),str(repo/'harness.c'),str(repo/'src/vector.c'),'-o',str(gb)]
        cp=subprocess.run(cc,text=True,capture_output=True)
        if cp.returncode != 0:
            print(cp.stdout); print(cp.stderr); return 2
        diag=repo/'diagnostics/undefined_functions.txt'
        dp=subprocess.run([args.goto_instrument,'--list-undefined-functions',str(gb)],text=True,capture_output=True)
        diag.write_text(dp.stdout,encoding='utf-8')
        if dp.returncode != 0:
            print(dp.stdout); print(dp.stderr); return 2
        req=json.loads((ROOT/'tests/fixtures/request_valid.json').read_text())
        req['diagnostics']['undefined_functions']['expected_sha256']=sha(diag)
        reqp=td/'request.json'; reqp.write_text(json.dumps(req,sort_keys=True,indent=2)+'\n')
        out=td/'out'
        cp=subprocess.run(['python3',str(ROOT/'scripts/audit_harness_integrity.py'),'--request',str(reqp),'--audit-root',str(repo),'--output-dir',str(out)],text=True,capture_output=True)
        print(cp.stdout); print(cp.stderr)
        if cp.returncode != 0: return cp.returncode
        report=json.loads((out/'harness_integrity_audit_report.json').read_text())
        print(json.dumps({'report_status':report['report_status'],'finding_counts':report['finding_counts']},sort_keys=True))
        return 0

if __name__=='__main__': raise SystemExit(main())
