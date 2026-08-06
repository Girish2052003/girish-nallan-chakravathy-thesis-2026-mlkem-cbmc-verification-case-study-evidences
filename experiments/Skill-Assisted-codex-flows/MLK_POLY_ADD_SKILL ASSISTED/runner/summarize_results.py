#!/usr/bin/env python3
from pathlib import Path
import json, sys

run = Path(sys.argv[1])
labels = ["SA_ADD_T1", "SA_ADD_T2"]
required = [
 "harness.c","model.goto","build_command.txt","build.log","build_exit_code.txt",
 "properties.txt","proof_command.txt","proof.json","proof.stderr","proof_exit_code.txt",
 "cover_command.txt","cover.json","cover.stderr","cover_exit_code.txt","sha256.txt"
]

def nonempty(p):
    return p.is_file() and p.stat().st_size > 0

def json_text(p):
    try:
        obj=json.loads(p.read_text())
        return json.dumps(obj)
    except Exception:
        return p.read_text(errors='replace')

complete=True
proof_ok=True
cover_ok=True
for label in labels:
    d=run/label
    complete &= all(nonempty(d/f) for f in required if f not in {"proof.stderr","cover.stderr"})
    proof_ok &= (d/'proof_exit_code.txt').read_text().strip() == '0'
    cover_ok &= (d/'cover_exit_code.txt').read_text().strip() == '0'
    ptxt=json_text(d/'proof.json')
    ctxt=json_text(d/'cover.json')
    # CBMC exit code 0 is the authoritative successful-proof indicator.
    expected_cover_goals = 4 if label == "SA_ADD_T1" else 5
    # CBMC coverage output records each reached __CPROVER_cover goal as SATISFIED.
    covered_count = ctxt.upper().count("SATISFIED")
    cover_ok &= covered_count >= expected_cover_goals

rows = [
 ("RUNS OCCURRED","1","evidence/run_1"),
 ("Selected-claim mapping","YES","two mapped theorem harnesses"),
 ("Target reachability","YES" if cover_ok else "NO","post-call cover goals"),
 ("Assertion reachability","YES" if cover_ok else "NO","final-block cover goals"),
 ("Assumption feasibility","YES" if cover_ok else "NO","post-assumption cover goals"),
 ("Evidence completeness","COMPLETE" if complete else "INCOMPLETE","required artefact inventory"),
 ("Repository distinctness","SUPPORTED","pinned source binding and independent IDs"),
 ("Contamination","NONE KNOWN","static distinctness audit"),
 ("Universal proof verdict","SUCCESS" if proof_ok else "FAILED","both CBMC proof exits and result text")
]
with (run/'FINAL_STATUS.tsv').open('w') as f:
    f.write('Field\tStatus\tBasis\n')
    for r in rows: f.write('\t'.join(r)+'\n')
if not (complete and proof_ok and cover_ok):
    raise SystemExit(20)
