#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$ROOT/provenance/barrett-reduce-classification/BARRETT_REDUCE_OVERLAY_SHA256SUMS.txt"
cd "$ROOT"
sha256sum -c "$MANIFEST"
python3 - <<'PY2'
from pathlib import Path
import csv, json
root=Path.cwd()
mp=root/'provenance/barrett-reduce-classification/original-to-retained-map.tsv'
with mp.open(encoding='utf-8') as f:
    rows=list(csv.DictReader(f,delimiter='	'))
missing=[r for r in rows if not (root/r['retained_path']).is_file()]
print(f'ORIGINAL_FILE_ROWS={len(rows)}')
print(f'MISSING_RETAINED_TARGETS={len(missing)}')
if missing:
    for r in missing[:20]: print(r['original_path'], '->', r['retained_path'])
    raise SystemExit(1)
print('BARRETT_CLASSIFICATION_VERIFY=PASS')
PY2
