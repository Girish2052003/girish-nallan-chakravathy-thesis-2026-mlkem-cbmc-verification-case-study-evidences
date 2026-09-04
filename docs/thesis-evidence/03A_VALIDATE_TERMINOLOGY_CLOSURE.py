#!/usr/bin/env python3
from __future__ import annotations

import argparse
import collections
import csv
import hashlib
import re
import shutil
import subprocess
import sys
import tempfile

from pathlib import Path

AUDITED_BASELINE = 'e18635c9d7f8ad16af1a63fb65f06dcf537e6121'
RENDER_BASELINE = 'f19654fbd05386769a852cc45fbd9ebb06690902'

EXPECTED_RESULTS = {'SUPPORTED': 215, 'RESOURCE_LIMITED_INCONCLUSIVE': 16, 'SUPPORTING_CONTROL': 7, 'SUPPORTED_DIAGNOSTIC': 6, 'SUPPORTED_WITH_PARTIAL_PRESERVATION': 5, 'ASSUMED_FROM_DOCUMENTED_GUARANTEE': 4, 'MEANINGFUL_NEGATIVE': 2, 'SUPPORTED_BY_CONSTRUCTION': 1, 'ABSTRACTION_LIMITED_INCONCLUSIVE': 1}
EXPECTED_CATEGORIES = {'MEANINGFUL_NEGATIVE': 2, 'PARTIAL_PRESERVATION': 4, 'NOT_TESTED': 1, 'EXCLUDED_TEMPLATE': 1, 'SUPPORTING_ONLY': 1, 'OUT_OF_SCOPE': 2, 'NOT_ESTABLISHED': 1, 'COUNTING_BOUNDARY': 1, 'NOT_CLAIMED': 1, 'ABSTRACTION_LIMITED_INCONCLUSIVE': 1, 'RESOURCE_LIMITED_INCONCLUSIVE': 3, 'EXCLUDED_INVALID': 1, 'NOT_DEMONSTRABLE': 2, 'SUPERSEDED_REPAIRED_FAILURE': 1, 'EXPECTED_FAILURE_CONTROL': 2, 'EVIDENCE_SOURCE_CONFLICT': 3}

EXPECTED_SECTIONS = {
    "Case 1 — Polynomial Addition": [
        "NEG-C01-PA03",
        "NEG-C01-PA04B",
        "LIM-C01-PA02B",
        "LIM-C01-PA06",
        "LIM-C01-PA07",
        "LIM-C01-PA08",
        "REP-C01-PA01V1"
    ],
    "Case 2 — Polynomial Subtraction": [
        "LIM-C02-T3M",
        "EXC-C02-T4TPL",
        "CTRL-C02-T4LOW",
        "CTRL-C02-T4UP"
    ],
    "Case 3 — Sequential Subtraction and Reduction": [
        "LIM-C03-REPLAY"
    ],
    "Case 4 — Message Extraction": [
        "CONFLICT-C04-NATIVE-DIR"
    ],
    "Case 5 — Message Embedding": [
        "CONFLICT-C05-NATIVE-HARNESS"
    ],
    "Case 6 — D4 Compression and Decompression": [
        "LIM-C06-BACKEND"
    ],
    "Case 7 — Signed-to-Canonical Conversion": [
        "CONFLICT-C07-NATIVE-DIR"
    ],
    "Case 8 — Barrett Reduction": [
        "LIM-C08-NOVELTY"
    ],
    "Case 9 — Zeroisation": [
        "LIM-C09-PHYSICAL"
    ],
    "Case 10 — Polynomial Serialisation": [
        "LIM-C10-COUNT"
    ],
    "Case 11 — Polynomial Deserialisation": [
        "LIM-C11-CANON"
    ],
    "Case 12 — Direct Codec Composition": [],
    "Case 13 — Public-Key Validation": [
        "INC-C13-SEED"
    ],
    "Case 14 — Montgomery Reduction": [
        "INC-C14-T2",
        "INC-C14-T3",
        "INC-C14-T4",
        "EXC-C14-SYN"
    ],
    "Skill-Available Addition": [
        "LIM-RQ2-ATTR",
        "LIM-RQ2-EFF"
    ],
    "Skill-Available Subtraction": [
        "LIM-RQ2-ATTR",
        "LIM-RQ2-EFF"
    ],
    "Skill-Available Barrett Reduction": [
        "LIM-RQ2-ATTR",
        "LIM-RQ2-EFF"
    ],
    "Skill-Available Zeroisation": [
        "LIM-RQ2-ATTR",
        "LIM-RQ2-EFF"
    ],
}

def norm(s):
    return re.sub(
        r'[^a-z0-9]+',
        '',
        s.lower()
    )

def findcol(fields, *wanted):
    m = {
        norm(x): x
        for x in fields
    }

    for w in wanted:
        if norm(w) in m:
            return m[norm(w)]

    for f in fields:
        nf = norm(f)

        if any(
            norm(w) in nf
            for w in wanted
        ):
            return f

    raise AssertionError(
        f'cannot locate column {wanted} in {fields}'
    )

def readcsv(p):
    with p.open(
        newline='',
        encoding='utf-8-sig'
    ) as f:
        r = csv.DictReader(f)
        rows = list(r)

        return (
            r.fieldnames or [],
            rows
        )

def math_surface(files):
    display = []
    inline = []

    for p in files:
        t = p.read_text(
            encoding='utf-8'
        )

        display += [
            (p.name, x)
            for x in re.findall(
                r'(?ms)^\$\$\s*\n(.*?)\n\$\$\s*$',
                t
            )
        ]

        inline += [
            (p.name, x)
            for x in re.findall(
                r'\$`(.*?)`\$',
                t,
                flags=re.S
            )
        ]

    payload = '\n'.join(
        f'{k}\t{n}\t{x}'
        for k, rows in [
            ('DISPLAY', display),
            ('INLINE', inline)
        ]
        for n, x in rows
    )

    return (
        display,
        inline,
        hashlib.sha256(
            payload.encode()
        ).hexdigest()
    )

def gitshow(root, commit, rel):
    cp = subprocess.run(
        [
            'git',
            '-C',
            str(root),
            'show',
            f'{commit}:{rel.as_posix()}'
        ],
        capture_output=True,
        text=True
    )

    if cp.returncode:
        raise AssertionError(
            cp.stderr.strip()
            or
            f'git show failed: {rel}'
        )

    return cp.stdout

def main():
    ap = argparse.ArgumentParser(
        description='Fail-closed 03A terminology/boundary closure validator'
    )

    ap.add_argument(
        '--repo-root',
        default=None
    )

    ap.add_argument(
        '--require-pandoc',
        action='store_true'
    )

    args = ap.parse_args()

    root = (
        Path(args.repo_root).resolve()
        if args.repo_root
        else Path(__file__).resolve().parents[2]
    )

    D = root / 'docs/thesis-evidence'

    master = D / '03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md'
    bcsv = D / '06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv'
    bmd = D / '06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.md'
    pcsv = D / '02_COMPLETE_PROPERTY_LEDGER.csv'
    term = D / '11_TERMINOLOGY_AND_CLAIM_POLICY.md'
    cross = D / '06_BOUNDARY_TO_SUBSTANTIVE_SCOPE_CROSSWALK.csv'

    details = sorted(
        (D / '03A_RENDERED_CATALOGUE_CASES').glob('*.md')
    )

    assert len(details) == 18,         f'detail files={len(details)}'

    for c in [
        AUDITED_BASELINE,
        RENDER_BASELINE
    ]:
        cp = subprocess.run([
            'git',
            '-C',
            str(root),
            'merge-base',
            '--is-ancestor',
            c,
            'HEAD'
        ])

        assert cp.returncode == 0,             f'{c} is not an ancestor of HEAD'

    pf, prows = readcsv(pcsv)

    rcol = findcol(
        pf,
        'result'
    )

    assert len(prows) == 257,         len(prows)

    rc = collections.Counter(
        (r.get(rcol) or '').strip()
        for r in prows
    )

    assert dict(rc) == EXPECTED_RESULTS,         f'property result vocabulary/count drift: {dict(rc)}'

    bf, brows = readcsv(bcsv)

    idc = findcol(
        bf,
        'record'
    )

    catc = findcol(
        bf,
        'category'
    )

    assert len(brows) == 27,         len(brows)

    bmap = {
        r[idc].strip(): r[catc].strip()
        for r in brows
    }

    assert len(bmap) == 27

    cc = collections.Counter(
        bmap.values()
    )

    assert dict(cc) == EXPECTED_CATEGORIES,         f'boundary category vocabulary/count drift: {dict(cc)}'

    cf, crows = readcsv(cross)

    cid = findcol(
        cf,
        'boundary_record_id',
        'record'
    )

    rel = findcol(
        cf,
        'relationship_type'
    )

    scope = findcol(
        cf,
        'related_property_or_scope'
    )

    rule = findcol(
        cf,
        'interpretation_rule'
    )

    assert len(crows) == 27

    cmap = {
        r[cid].strip(): r
        for r in crows
    }

    assert set(cmap) == set(bmap),         f'crosswalk ID drift missing={set(bmap)-set(cmap)} extra={set(cmap)-set(bmap)}'

    for bid, r in cmap.items():
        assert (
            r[rel].strip()
            and
            r[scope].strip()
            and
            r[rule].strip()
        ), f'incomplete crosswalk: {bid}'

    mt = master.read_text(
        encoding='utf-8'
    )

    bt = bmd.read_text(
        encoding='utf-8'
    )

    tt = term.read_text(
        encoding='utf-8'
    )

    ri = mt.index(
        '## Result-class inventory'
    )

    ci = mt.index(
        '## Controlled vocabulary and classification namespaces'
    )

    casei = mt.index(
        '## Case index'
    )

    assert ri < ci < casei

    for label in EXPECTED_RESULTS:
        first = mt.find(
            f'`{label}`'
        )

        assert ri <= first < ci,             f'result {label} first use is not in the authoritative inventory'

    for label in EXPECTED_CATEGORIES:
        token = f'| `{label}` |'

        pos = mt.find(token, ci, casei)

        assert ci <= pos < casei,             f'boundary category definition missing/before-use failure: {label}'

        assert token in bt,             f'file06 reusable definition missing: {label}'

        assert f'`{label}`' in tt,             f'terminology policy omits boundary category: {label}'

    assert (
        '`PARTIAL_PRESERVATION` and '
        '`SUPPORTED_WITH_PARTIAL_PRESERVATION`'
        in mt
    )

    assert (
        '`PARTIAL_PRESERVATION` is a material-boundary/preservation category'
        in tt
    )

    for pref in [
        'NEG-',
        'LIM-',
        'EXC-',
        'CTRL-',
        'INC-',
        'REP-',
        'CONFLICT-'
    ]:
        assert (
            f'`{pref}`' in mt
            and
            f'`{pref}`' in tt
        ), f'prefix undefined: {pref}'

    for token in [
        '`COMPLETE`',
        '`PARTIAL`',
        '`UA`',
        '`SA`',
        '`UNASSISTED`',
        '`SKILL_AVAILABLE`',
        '`SUPPORTED_WITHIN_INSPECTED_CORPUS`',
        '`RESOLVED`',
        '`RESOLVED_AND_HASHED`',
        '`PENDING`',
        '`UNRESOLVED_UNTIL_FINALIZER`',
        '`RESOLVED_HASH_MATCH`'
    ]:
        assert token in mt,             f'master central vocabulary missing {token}'

    assert (
        '17_NATIVE_BASELINE_EVIDENCE_CENSUS'
        in mt
    )

    assert (
        '05_LITERATURE_ASSURANCE_RELATIONSHIP_MATRIX'
        in mt
    )

    headings = []

    for m in re.finditer(
        r'^## (Case \d+ — .+|Skill-Available .+)$',
        mt,
        flags=re.M
    ):
        headings.append(
            (
                m.group(1),
                m.start()
            )
        )

    hmap = {
        h: p
        for h, p in headings
        if h in EXPECTED_SECTIONS
    }

    assert set(hmap) == set(EXPECTED_SECTIONS),         f'section heading drift missing={set(EXPECTED_SECTIONS)-set(hmap)}'

    occurrences = []

    for h, expected in EXPECTED_SECTIONS.items():
        s = hmap[h]

        nxt = min(
            [
                p
                for hh, p in headings
                if p > s
            ]
            + [len(mt)]
        )

        sec = mt[s:nxt]

        lines = [
            ln
            for ln in sec.splitlines()
            if ln.startswith(
                '**Material boundary records (see [boundary ledger]'
            )
        ]

        assert len(lines) == 1,             f'{h} material-boundary lines={len(lines)}'

        ln = lines[0]

        pairs = re.findall(
            r'`([A-Z]+-[A-Z0-9-]+)` \(([A-Z0-9_]+)\)',
            ln
        )

        ids = [
            x
            for x, _ in pairs
        ]

        assert ids == expected,             f'{h} IDs {ids} != {expected}'

        if not expected:
            assert (
                'None recorded for this investigation.'
                in ln
            )

        for bid, cat in pairs:
            assert bid in bmap,                 f'unknown boundary ID {bid}'

            assert bmap[bid] == cat,                 f'{bid} category {cat} != ledger {bmap[bid]}'

            occurrences.append(bid)

    assert set(occurrences) == set(bmap),         f'master unique coverage mismatch missing={set(bmap)-set(occurrences)} extra={set(occurrences)-set(bmap)}'

    oc = collections.Counter(
        occurrences
    )

    for bid in bmap:
        expected_n = (
            4
            if bid in {
                'LIM-RQ2-ATTR',
                'LIM-RQ2-EFF'
            }
            else 1
        )

        assert oc[bid] == expected_n,             f'{bid} master occurrence count {oc[bid]} != {expected_n}'

    current_files = [
        master
    ] + details

    d, i, current_digest = math_surface(
        current_files
    )

    assert (
        len(d),
        len(i)
    ) == (
        395,
        668
    ), (
        len(d),
        len(i)
    )

    with tempfile.TemporaryDirectory() as td:
        td = Path(td)

        baseline_files = []

        rels = [
            p.relative_to(root)
            for p in current_files
        ]

        for relp in rels:
            p = td / relp.name

            p.write_text(
                gitshow(
                    root,
                    AUDITED_BASELINE,
                    relp
                ),
                encoding='utf-8'
            )

            baseline_files.append(p)

        bd, bi, baseline_digest = math_surface(
            baseline_files
        )

        assert (
            len(bd),
            len(bi)
        ) == (
            395,
            668
        )

        assert current_digest == baseline_digest,             f'math surface changed: current={current_digest} baseline={baseline_digest}'

    math_text = '\n'.join(
        x
        for _, x in d + i
    )

    assert '\\operatorname' not in math_text,         'blocked operatorname macro returned to math surface'

    pandoc = shutil.which(
        'pandoc'
    )

    if args.require_pandoc:
        assert pandoc,             'pandoc is required but unavailable'

    if pandoc:
        synthetic = (
            '\n\n'.join(
                [
                    '$$\n'
                    + x
                    + '\n$$'
                    for _, x in d
                ]
                +
                [
                    '$'
                    + x
                    + '$'
                    for _, x in i
                ]
            )
            + '\n'
        )

        cp = subprocess.run(
            [
                pandoc,
                '-f',
                'markdown+tex_math_dollars',
                '-t',
                'html',
                '--mathjax'
            ],
            input=synthetic,
            text=True,
            capture_output=True
        )

        assert cp.returncode == 0,             cp.stderr

        assert not cp.stderr.strip(),             'Pandoc emitted warning(s): ' + cp.stderr.strip()

    print(
        '# 03A terminology and boundary closure validation'
    )

    print(
        f'- Property rows: {len(prows)}; result classes: {len(rc)}'
    )

    print(
        f'- Boundary rows: {len(brows)}; boundary categories: {len(cc)}'
    )

    print(
        f'- Master investigation sections explicitly boundary-closed: {len(EXPECTED_SECTIONS)}/18'
    )

    print(
        f'- Unique master boundary coverage: {len(set(occurrences))}/27'
    )

    print(
        '- Shared RQ2 limits: 2/2 present in each of 4/4 skill sections'
    )

    print(
        '- Boundary-to-substantive-scope crosswalk: 27/27'
    )

    print(
        '- Definition-before-first-use: PASS'
    )

    print(
        '- Preservation near-collision crosswalk: PASS'
    )

    print(
        f'- Math surface unchanged from audited {AUDITED_BASELINE}: 1063/1063'
    )

    if pandoc:
        print(
            '- Pandoc current math parse: PASS with zero warnings'
        )

    print(
        '## PASS'
    )

    return 0

if __name__ == '__main__':
    try:
        raise SystemExit(
            main()
        )
    except AssertionError as e:
        print(
            '## FAIL',
            file=sys.stderr
        )

        print(
            str(e),
            file=sys.stderr
        )

        raise SystemExit(1)
