#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys

TOKENS = [
    'SA_BR_T1_SIGN_CONJUGATE_REDUCTION',
    'SA_BR_T1_EXACT_QUOTIENT_REVERSAL',
    'SA_BR_T2_EXACT_ONE_CORRECTION_LAW',
    'SA_BR_T2_FULL_SUM_CENTERED_ORACLE_EQUIVALENCE',
    'sa_br_t1_sign_conjugacy_harness.c',
    'sa_br_t2_centered_addition_carry_harness.c',
]


def main() -> int:
    if len(sys.argv) != 3:
        print('usage: audit_repository_distinctness.py REPO_ROOT OUTPUT_JSON', file=sys.stderr)
        return 2
    repo = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2]).resolve()
    matches = {}
    for token in TOKENS:
        proc = subprocess.run(
            ['git', '-C', str(repo), 'grep', '-n', '-F', '--', token],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        if proc.returncode not in (0, 1):
            raise RuntimeError(f'git grep failed for {token}: {proc.stderr.strip()}')
        lines = [line for line in proc.stdout.splitlines() if line.strip()]
        matches[token] = lines
    supported = all(not lines for lines in matches.values())
    result = {
        'scope': 'tracked files at the pinned mlkem-native commit',
        'method': 'exact-token and exact-filename git grep',
        'matches': matches,
        'exact_match_count': sum(len(v) for v in matches.values()),
        'repository_distinctness': 'SUPPORTED' if supported else 'NOT_SUPPORTED',
        'qualification': 'This establishes repository-level distinctness for the named claims, not universal mathematical novelty.',
    }
    output.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    return 0 if supported else 1


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        raise SystemExit(1)
