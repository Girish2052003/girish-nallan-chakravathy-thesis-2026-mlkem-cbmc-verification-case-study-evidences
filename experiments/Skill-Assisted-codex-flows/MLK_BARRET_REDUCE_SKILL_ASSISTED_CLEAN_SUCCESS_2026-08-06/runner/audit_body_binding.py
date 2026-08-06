#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import sys


def main() -> int:
    if len(sys.argv) != 6:
        print('usage: audit_body_binding.py EXPOSURE_REPORT PROOF_FUNCTIONS COVER_FUNCTIONS FAIL_FUNCTIONS OUTPUT', file=sys.stderr)
        return 2
    exposure = json.loads(Path(sys.argv[1]).read_text())
    function_files = [Path(p) for p in sys.argv[2:5]]
    function_checks = {}
    for path in function_files:
        text = path.read_text(errors='ignore')
        function_checks[path.name] = 'mlk_barrett_reduce' in text
    passed = (
        exposure.get('signature_matches') == 1
        and exposure.get('body_byte_identical') is True
        and exposure.get('required_literals_present') is True
        and exposure.get('production_code_modified') is False
        and all(function_checks.values())
    )
    result = {
        'target': 'mlk_barrett_reduce',
        'source_body_sha256': exposure.get('original_body_sha256'),
        'exposed_body_sha256': exposure.get('exposed_body_sha256'),
        'function_inventory_checks': function_checks,
        'body_binding': 'PASS' if passed else 'FAIL',
    }
    Path(sys.argv[5]).write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
