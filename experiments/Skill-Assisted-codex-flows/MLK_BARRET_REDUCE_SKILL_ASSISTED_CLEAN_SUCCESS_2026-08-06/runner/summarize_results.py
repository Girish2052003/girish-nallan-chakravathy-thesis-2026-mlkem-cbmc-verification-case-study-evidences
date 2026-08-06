#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import sys

THEOREMS = {
    'SA_BR_T1': {
        'assertions': [
            'SA_BR_T1_SIGN_CONJUGATE_REDUCTION',
            'SA_BR_T1_ABSOLUTE_REMAINDER_PRESERVED',
            'SA_BR_T1_POSITIVE_QUOTIENT_INTEGRAL',
            'SA_BR_T1_NEGATIVE_QUOTIENT_INTEGRAL',
            'SA_BR_T1_EXACT_QUOTIENT_REVERSAL',
        ],
        'covers': [
            'SA_BR_T1_ASSUMPTIONS_FEASIBLE',
            'SA_BR_T1_POSITIVE_NONTRIVIAL_INPUT',
            'SA_BR_T1_NEGATIVE_NONTRIVIAL_INPUT',
            'SA_BR_T1_TARGET_1_REACHED',
            'SA_BR_T1_TARGET_2_REACHED',
            'SA_BR_T1_ASSERTION_BLOCK_REACHED',
        ],
        'fail_control': 'SA_BR_T1_FC_FALSE_EVEN_SYMMETRY',
    },
    'SA_BR_T2': {
        'assertions': [
            'SA_BR_T2_INTERMEDIATE_SUM_REPRESENTABLE',
            'SA_BR_T2_CORRECTION_COEFFICIENT_BOUND',
            'SA_BR_T2_EXACT_ONE_CORRECTION_LAW',
            'SA_BR_T2_FULL_SUM_CENTERED_ORACLE_EQUIVALENCE',
            'SA_BR_T2_REDUCED_OPERAND_SUM_RESIDUE_PRESERVATION',
            'SA_BR_T2_FULL_SUM_CONGRUENCE',
            'SA_BR_T2_FINAL_CENTERED_RANGE',
        ],
        'covers': [
            'SA_BR_T2_ASSUMPTIONS_FEASIBLE',
            'SA_BR_T2_POSITIVE_CORRECTION_FEASIBLE',
            'SA_BR_T2_NEGATIVE_CORRECTION_FEASIBLE',
            'SA_BR_T2_ZERO_CORRECTION_FEASIBLE',
            'SA_BR_T2_TARGET_1_REACHED',
            'SA_BR_T2_TARGET_2_REACHED',
            'SA_BR_T2_TARGET_3_REACHED',
            'SA_BR_T2_ASSERTION_BLOCK_REACHED',
        ],
        'fail_control': 'SA_BR_T2_FC_FALSE_NO_WRAP_CORRECTION',
    },
}

REQUIRED = [
    'harness.c', 'proof_model.goto', 'cover_model.goto', 'fail_control_model.goto',
    'proof_build_command.txt', 'proof_build.log', 'proof_build_exit_code.txt',
    'cover_build_command.txt', 'cover_build.log', 'cover_build_exit_code.txt',
    'fail_control_build_command.txt', 'fail_control_build.log',
    'fail_control_build_exit_code.txt', 'proof_functions.txt', 'cover_functions.txt',
    'fail_control_functions.txt', 'proof_symbols.txt', 'proof_loops.txt',
    'cover_loops.txt', 'proof_properties.txt', 'cover_properties.txt',
    'fail_control_properties.txt', 'body_binding.json', 'proof_command.txt',
    'proof.json', 'proof.stderr', 'proof_exit_code.txt', 'cover_command.txt',
    'cover.json', 'cover.stderr', 'cover_exit_code.txt', 'fail_control_command.txt',
    'fail_control.json', 'fail_control.stderr', 'fail_control_exit_code.txt',
    'sha256.txt',
]

QUIET = {
    'proof_build.log', 'cover_build.log', 'fail_control_build.log',
    'proof.stderr', 'cover.stderr', 'fail_control.stderr',
}


def records(value):
    if isinstance(value, dict):
        if 'status' in value:
            yield value
        for child in value.values():
            yield from records(child)
    elif isinstance(value, list):
        for child in value:
            yield from records(child)


def statuses_for_token(data, token: str):
    found = []
    for rec in records(data):
        if token in json.dumps(rec, sort_keys=True):
            found.append(str(rec.get('status', '')).upper())
    return found


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
        for rel in REQUIRED:
            path = d / rel
            if not path.is_file():
                raise RuntimeError(f'missing artefact: {path}')
            if rel not in QUIET and path.stat().st_size == 0:
                raise RuntimeError(f'empty required artefact: {path}')

        for rel in ('proof_build_exit_code.txt', 'cover_build_exit_code.txt',
                    'fail_control_build_exit_code.txt', 'proof_exit_code.txt'):
            if (d / rel).read_text().strip() != '0':
                raise RuntimeError(f'{label}: expected zero in {rel}')
        if (d / 'cover_exit_code.txt').read_text().strip() != '10':
            raise RuntimeError(f'{label}: expected reachability-witness exit 10')
        if (d / 'fail_control_exit_code.txt').read_text().strip() != '10':
            raise RuntimeError(f'{label}: expected fail control exit 10')

        props = (d / 'proof_properties.txt').read_text(errors='ignore')
        missing = [token for token in spec['assertions'] if token not in props]
        if missing:
            raise RuntimeError(f'{label}: selected claims missing from property inventory: {missing}')

        binding = json.loads((d / 'body_binding.json').read_text())
        if binding.get('body_binding') != 'PASS':
            raise RuntimeError(f'{label}: target body binding failed')

        proof_data = json.loads((d / 'proof.json').read_text())
        proof_statuses = [str(r.get('status', '')).upper() for r in records(proof_data)]
        if not proof_statuses:
            raise RuntimeError(f'{label}: no proof property statuses')
        if any(s in {'FAILURE', 'FAILED', 'UNKNOWN', 'ERROR'} for s in proof_statuses):
            raise RuntimeError(f'{label}: proof contains non-success status')
        success_count = sum(s in {'SUCCESS', 'SATISFIED', 'PASS', 'PASSED'} for s in proof_statuses)
        if success_count == 0:
            raise RuntimeError(f'{label}: no successful proof records')

        cover_data = json.loads((d / 'cover.json').read_text())
        witnessed = []
        for token in spec['covers']:
            statuses = statuses_for_token(cover_data, token)
            if not statuses or not any(s in {'FAILURE', 'FAILED'} for s in statuses):
                raise RuntimeError(f'{label}: reachability goal lacks witness: {token} {statuses}')
            witnessed.append(token)

        fail_data = json.loads((d / 'fail_control.json').read_text())
        fail_statuses = statuses_for_token(fail_data, spec['fail_control'])
        if not fail_statuses or not any(s in {'FAILURE', 'FAILED'} for s in fail_statuses):
            raise RuntimeError(f'{label}: exact planned fail control not rejected')

        theorem_results[label] = {
            'proof': 'PASS',
            'target_body_binding': 'PASS',
            'expected_failure_control': 'PASS',
            'successful_property_records': success_count,
            'selected_claim_mapping': 'YES',
            'target_reachability': 'YES',
            'assertion_reachability': 'YES',
            'assumption_feasibility': 'YES',
            'witnessed_reachability_goals': witnessed,
        }
        total_success += success_count
        total_cover += len(witnessed)

    distinctness = json.loads((run_dir / 'repository_distinctness.json').read_text())
    if distinctness.get('repository_distinctness') != 'SUPPORTED':
        raise RuntimeError('repository distinctness did not pass')

    final = {
        'campaign': 'MLK_BARRET_REDUCE_SKILL ASSISTED',
        'technical_target': 'mlk_barrett_reduce',
        'pinned_commit': 'af4c5abdd5958bdc65a03cd5ee86708264f93304',
        'runs_occurred': 1,
        'theorems': theorem_results,
        'successful_property_records_total': total_success,
        'witnessed_named_reachability_goals_total': total_cover,
        'Selected-claim mapping': 'YES',
        'Target reachability': 'YES',
        'Assertion reachability': 'YES',
        'Assumption feasibility': 'YES',
        'Evidence completeness': 'COMPLETE',
        'Repository distinctness': 'SUPPORTED',
        'Contamination': 'NONE KNOWN',
        'overall_verdict': 'PASS_COMPLETE_SKILL_ASSISTED_MLK_BARRETT_REDUCE_CORPUS',
    }
    (run_dir / 'final_status.json').write_text(json.dumps(final, indent=2) + '\n', encoding='utf-8')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        raise SystemExit(1)
