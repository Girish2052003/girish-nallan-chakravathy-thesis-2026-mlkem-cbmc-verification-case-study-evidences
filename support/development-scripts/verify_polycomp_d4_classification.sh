#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$ROOT/provenance/polycomp-d4-classification/POLYCOMP_D4_OVERLAY_SHA256SUMS.txt"
cd "$ROOT"
sha256sum -c "$MANIFEST"
python3 - <<'PY2'
from pathlib import Path
import csv, json, hashlib
root=Path.cwd()
mp=root/'provenance/polycomp-d4-classification/original-to-retained-map.tsv'
with mp.open(encoding='utf-8') as f:
    rows=list(csv.DictReader(f,delimiter='	'))
missing=[]; different=[]
for r in rows:
    p=root/r['retained_path']
    if not p.is_file():
        missing.append(r)
        continue
    h=hashlib.sha256()
    with p.open('rb') as fh:
        for b in iter(lambda:fh.read(1024*1024),b''): h.update(b)
    if h.hexdigest()!=r['sha256']: different.append(r)
print(f'ORIGINAL_FILE_ROWS={len(rows)}')
print(f'MISSING_RETAINED_TARGETS={len(missing)}')
print(f'HASH_DIFFERENT_RETAINED_TARGETS={len(different)}')
if missing or different:
    for r in (missing+different)[:20]: print(r['original_path'],'->',r['retained_path'])
    raise SystemExit(1)
summary=json.loads((root/'provenance/polycomp-d4-classification/classification-summary.json').read_text())
if len(rows)!=summary['original_regular_files'] or not summary['all_original_files_accounted_for']:
    raise SystemExit('classification summary accounting mismatch')
print('POLYCOMP_D4_CLASSIFICATION_VERIFY=PASS')
PY2
