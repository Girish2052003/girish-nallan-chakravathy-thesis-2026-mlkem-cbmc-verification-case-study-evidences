#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import sys

THEOREMS = {
    'SA_SUB_T1': {
        'assertions': [
            'SA_SUB_T1_COMMON_MINUEND_DIFFERENCE_REVERSAL',
            'SA_SUB_T1_NESTED_EXECUTION_ORACLE_BRIDGE',
            'SA_SUB_T1_DIRECT_EXECUTION_ORACLE_BRIDGE',
        ],
        'covers': [
            'SA_SUB_T1_ASSUMPTIONS_FEASIBLE',
            'SA_SUB_T1_NONTRIVIAL_WITNESS',
            'SA_SUB_T1_TARGET_1_REACHED',
            'SA_SUB_T1_TARGET_2_REACHED',
            'SA_SUB_T1_TARGET_3_REACHED',
            'SA_SUB_T1_TARGET_4_REACHED',
            'SA_SUB_T1_ASSERTION_BLOCK_REACHED',
        ],
    },
    'SA_SUB_T2': {
        'assertions': [
            'SA_SUB_T2_AGGREGATE_CONSTRUCTION',
            'SA_SUB_T2_SEQUENTIAL_SUBTRAHEND_AGGREGATION_EQUIVALENCE',
            'SA_SUB_T2_SEQUENTIAL_EXECUTION_ORACLE_BRIDGE',
            'SA_SUB_T2_DIRECT_EXECUTION_ORACLE_BRIDGE',
        ],
        'covers': [
            'SA_SUB_T2_ASSUMPTIONS_FEASIBLE',
            'SA_SUB_T2_NONTRIVIAL_WITNESS',
            'SA_SUB_T2_TARGET_1_REACHED',
            'SA_SUB_T2_TARGET_2_REACHED',
            'SA_SUB_T2_TARGET_3_REACHED',
            'SA_SUB_T2_ASSERTION_BLOCK_REACHED',
        ],
    },
}

PER_THEOREM_REQUIRED = [
    'harness.c', 'proof_model.goto', 'cover_model.goto',
    'proof_build_command.txt', 'proof_build.log', 'proof_build_exit_code.txt',
    'cover_build_command.txt', 'cover_build.log', 'cover_build_exit_code.txt',
    'proof_functions.txt', 'cover_functions.txt', 'proof_loops.txt',
    'cover_loops.txt', 'proof_properties.txt', 'cover_properties.txt',
    'proof_command.txt', 'proof.json', 'proof.stderr', 'proof_exit_code.txt',
    'cover_command.txt', 'cover.json', 'cover.stderr', 'cover_exit_code.txt',
    'sha256.txt',
]


def records(value):
    if isinstance(value, dict):
        if 'status' in value:
            yield value
        for child in value.values():
            yield from records(child)
    elif isinstance(value, list):
        for child in value:
            yield from records(child)


def require_nonempty(path: Path) -> None:
    if not path.is_file() or path.stat().st_size == 0:
        raise RuntimeError(f'missing or empty artefact: {path}')


def main() -> int:
    if len(sys.argv) != 2:
        print('usage: summarize_results.py RUN_DIR', file=sys.stderr)
        return 2
    run_dir = Path(sys.argv[1]).resolve()
    theorem_results = {}
    total_success = 0
    total_cover = 0

    for label, spec in THEOREMS.items():
        d = run_dir / label
        quiet_files = {'proof_build.log', 'cover_build.log', 'proof.stderr', 'cover.stderr'}
        for rel in PER_THEOREM_REQUIRED:
            path = d / rel
            if not path.is_file():
                raise RuntimeError(f'missing artefact: {path}')
            if rel not in quiet_files and path.stat().st_size == 0:
                raise RuntimeError(f'empty required artefact: {path}')
        if (d / 'proof_exit_code.txt').read_text().strip() != '0':
            raise RuntimeError(f'{label}: proof exit code is nonzero')
        if (d / 'cover_exit_code.txt').read_text().strip() != '0':
            raise RuntimeError(f'{label}: cover exit code is nonzero')

        props = (d / 'proof_properties.txt').read_text(errors='ignore')
        missing_assertions = [x for x in spec['assertions'] if x not in props]
        if missing_assertions:
            raise RuntimeError(f'{label}: missing assertion mappings: {missing_assertions}')

        functions = (d / 'proof_functions.txt').read_text(errors='ignore')
        if 'poly_sub' not in functions:
            raise RuntimeError(f'{label}: production poly_sub absent from GOTO function inventory')

        proof_data = json.loads((d / 'proof.json').read_text())
        proof_records = list(records(proof_data))
        proof_statuses = [str(r.get('status', '')).upper() for r in proof_records]
        if not proof_statuses:
            raise RuntimeError(f'{label}: no proof property statuses found')
        bad = [s for s in proof_statuses if s in {'FAILURE', 'FAILED', 'UNKNOWN', 'ERROR'}]
        if bad:
            raise RuntimeError(f'{label}: unacceptable proof statuses: {bad}')
        success_count = sum(s in {'SUCCESS', 'SATISFIED', 'PASS', 'PASSED'} for s in proof_statuses)
        if success_count == 0:
            raise RuntimeError(f'{label}: no successful proof properties found')

        cover_text = (d / 'cover.json').read_text(errors='ignore')
        cover_data = json.loads(cover_text)
        cover_records = list(records(cover_data))
        satisfied_tokens = []
        for token in spec['covers']:
            matching = []
            for rec in cover_records:
                blob = json.dumps(rec, sort_keys=True)
                if token in blob:
                    matching.append(str(rec.get('status', '')).upper())
            if not matching:
                raise RuntimeError(f'{label}: cover token not found in result: {token}')
            if not any(s in {'SATISFIED', 'SUCCESS', 'COVERED', 'PASS', 'PASSED'} for s in matching):
                raise RuntimeError(f'{label}: cover goal not satisfied: {token} statuses={matching}')
            satisfied_tokens.append(token)

        theorem_results[label] = {
            'proof': 'PASS',
            'successful_property_records': success_count,
            'selected_claim_mapping': 'YES',
            'target_reachability': 'YES',
            'assertion_reachability': 'YES',
            'assumption_feasibility': 'YES',
            'satisfied_cover_goals': satisfied_tokens,
        }
        total_success += success_count
        total_cover += len(satisfied_tokens)

    distinctness = json.loads((run_dir / 'repository_distinctness.json').read_text())
    if distinctness.get('repository_distinctness') != 'SUPPORTED':
        raise RuntimeError('repository distinctness audit did not pass')

    final = {
        'campaign': 'MLK_POLY_SUB_SKILL ASSISTED',
        'runs_occurred': 1,
        'theorems': theorem_results,
        'successful_property_records_total': total_success,
        'satisfied_named_cover_goals_total': total_cover,
        'Selected-claim mapping': 'YES',
        'Target reachability': 'YES',
        'Assertion reachability': 'YES',
        'Assumption feasibility': 'YES',
        'Evidence completeness': 'COMPLETE',
        'Repository distinctness': 'SUPPORTED',
        'Contamination': 'NONE KNOWN',
        'overall_verdict': 'PASS_COMPLETE_SKILL_ASSISTED_POLY_SUB_CORPUS'
    }
    (run_dir / 'final_status.json').write_text(
        json.dumps(final, indent=2) + '\n', encoding='utf-8')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        raise SystemExit(1)
