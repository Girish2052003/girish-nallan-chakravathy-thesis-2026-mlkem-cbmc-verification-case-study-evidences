#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import sys

SIGNATURE = 'static MLK_INLINE int16_t mlk_barrett_reduce(int16_t a)'
EXPOSED = 'int16_t mlk_barrett_reduce(int16_t a)'


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def extract_function(text: str) -> tuple[str, str]:
    start = text.find(SIGNATURE)
    if start < 0:
        raise RuntimeError('exact production Barrett signature not found')
    if text.find(SIGNATURE, start + 1) >= 0:
        raise RuntimeError('production Barrett signature is not unique')
    brace = text.find('{', start)
    if brace < 0:
        raise RuntimeError('function opening brace not found')
    depth = 0
    end = None
    for index in range(brace, len(text)):
        char = text[index]
        if char == '{':
            depth += 1
        elif char == '}':
            depth -= 1
            if depth == 0:
                end = index + 1
                break
    if end is None:
        raise RuntimeError('function closing brace not found')
    return text[start:end], text[brace:end]


def main() -> int:
    if len(sys.argv) != 4:
        print('usage: expose_barrett.py ORIGINAL_POLY_C OUTPUT_C REPORT_JSON', file=sys.stderr)
        return 2
    original_path = Path(sys.argv[1]).resolve()
    output_path = Path(sys.argv[2]).resolve()
    report_path = Path(sys.argv[3]).resolve()
    original_bytes = original_path.read_bytes()
    original_text = original_bytes.decode('utf-8')
    fragment, body = extract_function(original_text)
    exposed_fragment = fragment.replace(SIGNATURE, EXPOSED, 1)
    if exposed_fragment.count(EXPOSED) != 1:
        raise RuntimeError('exposure replacement count is not exactly one')
    exposed_body = exposed_fragment[exposed_fragment.find('{'):]
    if body != exposed_body:
        raise RuntimeError('function body changed during exposure')
    generated = (
        '/* Generated exposure-only translation unit. The arithmetic body below is byte-identical\n'
        ' * to the pinned production function; only static/inline linkage is removed. */\n'
        '#include "common.h"\n'
        '#include "cbmc.h"\n'
        '#include "debug.h"\n'
        '#include "params.h"\n\n'
        + exposed_fragment + '\n'
    )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(generated, encoding='utf-8', newline='\n')
    report = {
        'source': str(original_path),
        'source_sha256': sha256_bytes(original_bytes),
        'signature_matches': 1,
        'exposure_change': SIGNATURE + ' -> ' + EXPOSED,
        'original_fragment_sha256': sha256_bytes(fragment.encode()),
        'original_body_sha256': sha256_bytes(body.encode()),
        'exposed_body_sha256': sha256_bytes(exposed_body.encode()),
        'body_byte_identical': body == exposed_body,
        'required_literals_present': all(
            token in body for token in ('20159', '((int32_t)1 << 25)', '>> 26', 'MLKEM_Q')
        ),
        'production_code_modified': False,
        'generated_copy_linkage_only': True,
    }
    report_path.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        raise SystemExit(1)
