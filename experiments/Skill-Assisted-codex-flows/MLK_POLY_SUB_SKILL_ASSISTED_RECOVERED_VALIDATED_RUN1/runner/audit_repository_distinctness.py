#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys

NEEDLES = [
    'Common-minuend difference reversal',
    'Sequential-subtrahend aggregation equivalence',
    'sa_sub_t1_common_minuend_difference_reversal_harness.c',
    'sa_sub_t2_sequential_subtrahend_aggregation_harness.c',
    'SA_SUB_T1_COMMON_MINUEND_DIFFERENCE_REVERSAL',
    'SA_SUB_T2_SEQUENTIAL_SUBTRAHEND_AGGREGATION_EQUIVALENCE',
]


def main() -> int:
    if len(sys.argv) != 3:
        print('usage: audit_repository_distinctness.py REPO_ROOT OUTPUT_JSON', file=sys.stderr)
        return 2
    repo = Path(sys.argv[1]).resolve()
    out = Path(sys.argv[2]).resolve()
    raw = subprocess.check_output(['git', '-C', str(repo), 'ls-files', '-z'])
    files = [p.decode('utf-8', 'surrogateescape') for p in raw.split(b'\0') if p]
    matches = []
    scanned_text_files = 0
    for rel in files:
        path = repo / rel
        try:
            if not path.is_file() or path.stat().st_size > 5_000_000:
                continue
            data = path.read_text(encoding='utf-8', errors='ignore')
        except OSError:
            continue
        scanned_text_files += 1
        for needle in NEEDLES:
            if needle in data:
                matches.append({'file': rel, 'token': needle})
    result = {
        'tracked_files': len(files),
        'scanned_text_files': scanned_text_files,
        'unique_tokens': NEEDLES,
        'matches': matches,
        'repository_distinctness': 'SUPPORTED' if not matches else 'NOT_SUPPORTED',
        'contamination': 'NONE KNOWN' if not matches else 'POSSIBLE',
        'scope': 'Exact-token scan of the frozen tracked repository; mathematical global novelty is not claimed.'
    }
    out.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    return 0 if not matches else 1


if __name__ == '__main__':
    raise SystemExit(main())
