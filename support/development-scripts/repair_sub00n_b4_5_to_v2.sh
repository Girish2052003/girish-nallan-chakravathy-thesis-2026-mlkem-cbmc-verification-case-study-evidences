#!/usr/bin/env bash
set -euo pipefail
umask 077

OLD="${HOME}/sub00n_b4_5_build_inspect_goto_models.sh"
NEW="${HOME}/sub00n_b4_5_v2_build_inspect_goto_models.sh"

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"
FINAL="${B4}/SUB00N_B4_5_GOTO_PREFLIGHT_MLKEM768"

PATCH_RECORD="${B4}/SUB00N_B4_5_V1_FAILURE_AND_V2_REPAIR_RECORD.txt"
PATCH_RECORD_HASH="${PATCH_RECORD}.sha256"

echo "============================================================"
echo "SUB00N / BATCH 4 — B4.5-v2 REPAIR"
echo "============================================================"
echo

test -f "${OLD}" || {
    echo "ERROR: Original B4.5 script is missing:"
    echo "${OLD}"
    exit 1
}

test ! -e "${NEW}" || {
    echo "ERROR: Corrected B4.5-v2 script already exists:"
    echo "${NEW}"
    exit 1
}

test ! -e "${FINAL}" || {
    echo "ERROR: A finalized B4.5 directory already exists:"
    echo "${FINAL}"
    echo "Do not overwrite it."
    exit 1
}

test ! -e "${PATCH_RECORD}" || {
    echo "ERROR: Repair record already exists:"
    echo "${PATCH_RECORD}"
    exit 1
}

test ! -e "${PATCH_RECORD_HASH}" || {
    echo "ERROR: Repair-record hash already exists:"
    echo "${PATCH_RECORD_HASH}"
    exit 1
}

echo "=== R1: FAILED-STAGING CLEANUP CHECK ==="

mapfile -t STALE_STAGES < <(
    find "${B4}" \
        -maxdepth 1 \
        -type d \
        -name '.SUB00N_B4_5_GOTO_PREFLIGHT_MLKEM768.tmp.*' \
        -print |
    sort
)

echo "STALE_B4_5_STAGE_COUNT=${#STALE_STAGES[@]}"

if [ "${#STALE_STAGES[@]}" -ne 0 ]; then
    echo "ERROR: A stale failed-stage directory remains:"
    printf '%s\n' "${STALE_STAGES[@]}"
    echo
    echo "Nothing has been deleted automatically."
    exit 1
fi

echo "FAILED_STAGING_CLEANUP=PASS"
echo

OLD_HASH="$(sha256sum "${OLD}" | awk '{print $1}')"

python3 - "${OLD}" "${NEW}" <<'PY'
from pathlib import Path
import sys

source_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])

text = source_path.read_text()

replacements = []


def add_replacement(old: str, new: str, description: str) -> None:
    replacements.append((old, new, description))


add_replacement(
'''SUMMARY="${STAGE}/SUB00N_B4_5_PREFLIGHT_SUMMARY.txt"
FREEZE="${STAGE}/SUB00N_B4_5_EXECUTION_INPUT_FREEZE.md"
MANIFEST="${STAGE}/SUB00N_B4_5_PREFLIGHT_ARTIFACT_MANIFEST.sha256"
''',
'''SUMMARY="${STAGE}/SUB00N_B4_5_PREFLIGHT_SUMMARY.txt"
FREEZE="${STAGE}/SUB00N_B4_5_EXECUTION_INPUT_FREEZE.md"
CORRECTION="${STAGE}/SUB00N_B4_5_V1_FAILURE_AND_V2_CORRECTION.md"
MANIFEST="${STAGE}/SUB00N_B4_5_PREFLIGHT_ARTIFACT_MANIFEST.sha256"
''',
"add correction-record path",
)


add_replacement(
'''mkdir -p "${STAGE}"

CASE_IDS="
''',
'''mkdir -p "${STAGE}"

cat > "${CORRECTION}" <<'EOF'
# SUB00N B4.5 — V1 Failure and V2 Correction Record

## V1 outcome

The first B4.5 preflight attempt stopped during the POSITIVE case's
loop-identifier comparison.

This was not a theorem, coverage, or negative-control failure.

No verification solver was executed.

The temporary POSITIVE GOTO model and inspection outputs were held only
inside the fail-closed staging directory and were removed by the cleanup
trap after the preflight script exited unsuccessfully.

## V1 script defects

The original script incorrectly applied loop discovery to the complete
linked GOTO model. That model intentionally retained unrelated production
functions, so loops from NTT, reduction, multiplication, poly_add and other
functions appeared even though they were unreachable from main.

The original parser also searched every output line with an unanchored
regular expression. It therefore misclassified the staging-path suffix
".tmp.<pid>" as a loop identifier.

## V2 correction

V2 keeps two models per case:

1. The authoritative original GOTO model.
   This remains the later verification input.

2. A reachable-only inspection model produced with:
       goto-instrument --drop-unused-functions

Loop discovery is applied only to the reachable-only inspection model.

The parser accepts only explicit loop-declaration lines beginning with:
       Loop

Paths, diagnostics and unrelated numeric suffixes cannot become loop IDs.

## Integrity boundary

The B4.4 frozen harnesses are unchanged.

The production poly.c source is unchanged.

Batch 3 is untouched.

The failed V1 attempt produced no theorem result and may not be reported
as scientific evidence.
EOF

CASE_IDS="
''',
"add scientific correction record",
)


add_replacement(
'''    MODEL_NAME="$(case_model_name "${CASE_ID}")"
    MODEL="${BUILD_DIR}/${MODEL_NAME}"

    BUILD_COMMAND="${BUILD_DIR}/goto_build_command.txt"
''',
'''    MODEL_NAME="$(case_model_name "${CASE_ID}")"
    MODEL="${BUILD_DIR}/${MODEL_NAME}"
    REACHABLE_MODEL="${BUILD_DIR}/${MODEL_NAME%.goto}_reachable_only.goto"

    BUILD_COMMAND="${BUILD_DIR}/goto_build_command.txt"
''',
"add reachable-only model path",
)


add_replacement(
'''    VALIDATE_COMMAND="${BUILD_DIR}/validate_command.txt"
    VALIDATE_STDOUT="${BUILD_DIR}/validate_stdout.txt"
    VALIDATE_STDERR="${BUILD_DIR}/validate_stderr.txt"
    VALIDATE_EXIT="${BUILD_DIR}/validate_exit_code.txt"

    SYMBOL_COMMAND="${BUILD_DIR}/show_symbol_table_command.txt"
''',
'''    VALIDATE_COMMAND="${BUILD_DIR}/validate_command.txt"
    VALIDATE_STDOUT="${BUILD_DIR}/validate_stdout.txt"
    VALIDATE_STDERR="${BUILD_DIR}/validate_stderr.txt"
    VALIDATE_EXIT="${BUILD_DIR}/validate_exit_code.txt"

    DROP_UNUSED_COMMAND="${BUILD_DIR}/drop_unused_functions_command.txt"
    DROP_UNUSED_STDOUT="${BUILD_DIR}/drop_unused_functions_stdout.txt"
    DROP_UNUSED_STDERR="${BUILD_DIR}/drop_unused_functions_stderr.txt"
    DROP_UNUSED_EXIT="${BUILD_DIR}/drop_unused_functions_exit_code.txt"

    REACHABLE_VALIDATE_COMMAND="${BUILD_DIR}/validate_reachable_model_command.txt"
    REACHABLE_VALIDATE_STDOUT="${BUILD_DIR}/validate_reachable_model_stdout.txt"
    REACHABLE_VALIDATE_STDERR="${BUILD_DIR}/validate_reachable_model_stderr.txt"
    REACHABLE_VALIDATE_EXIT="${BUILD_DIR}/validate_reachable_model_exit_code.txt"

    SYMBOL_COMMAND="${BUILD_DIR}/show_symbol_table_command.txt"
''',
"add reachable-model command artefacts",
)


add_replacement(
'''    if ! run_and_record \\
        "${VALIDATE_STDOUT}" \\
        "${VALIDATE_STDERR}" \\
        "${VALIDATE_EXIT}" \\
        "${VALIDATE_CMD[@]}"
    then
        cat "${VALIDATE_STDERR}" >&2 || true
        fail "${CASE_ID}: GOTO validation failed"
    fi

    SYMBOL_CMD=(
''',
'''    if ! run_and_record \\
        "${VALIDATE_STDOUT}" \\
        "${VALIDATE_STDERR}" \\
        "${VALIDATE_EXIT}" \\
        "${VALIDATE_CMD[@]}"
    then
        cat "${VALIDATE_STDERR}" >&2 || true
        fail "${CASE_ID}: GOTO validation failed"
    fi

    DROP_UNUSED_CMD=(
        goto-instrument
        --drop-unused-functions
        "${MODEL}"
        "${REACHABLE_MODEL}"
    )

    write_command "${DROP_UNUSED_COMMAND}" "${DROP_UNUSED_CMD[@]}"

    if ! run_and_record \\
        "${DROP_UNUSED_STDOUT}" \\
        "${DROP_UNUSED_STDERR}" \\
        "${DROP_UNUSED_EXIT}" \\
        "${DROP_UNUSED_CMD[@]}"
    then
        cat "${DROP_UNUSED_STDERR}" >&2 || true
        fail "${CASE_ID}: dropping unused functions failed"
    fi

    test -s "${REACHABLE_MODEL}" ||
        fail "${CASE_ID}: reachable-only inspection model was not created"

    REACHABLE_VALIDATE_CMD=(
        goto-instrument
        --validate-goto-binary
        "${REACHABLE_MODEL}"
    )

    write_command \\
        "${REACHABLE_VALIDATE_COMMAND}" \\
        "${REACHABLE_VALIDATE_CMD[@]}"

    if ! run_and_record \\
        "${REACHABLE_VALIDATE_STDOUT}" \\
        "${REACHABLE_VALIDATE_STDERR}" \\
        "${REACHABLE_VALIDATE_EXIT}" \\
        "${REACHABLE_VALIDATE_CMD[@]}"
    then
        cat "${REACHABLE_VALIDATE_STDERR}" >&2 || true
        fail "${CASE_ID}: reachable-only GOTO validation failed"
    fi

    SYMBOL_CMD=(
''',
"create and validate reachable-only model",
)


add_replacement(
'''    LOOPS_CMD=(
        cbmc
        "${MODEL}"
        --function main
        --show-loops
    )
''',
'''    LOOPS_CMD=(
        goto-instrument
        --show-loops
        "${REACHABLE_MODEL}"
    )
''',
"inspect loops only in reachable model",
)


add_replacement(
'''    {
        grep -Eo \\
            '[A-Za-z_][A-Za-z0-9_]*\\.[0-9]+' \\
            "${LOOPS_STDOUT}" ||
            true
    } |
        sort -u > "${ACTUAL_LOOPS}"
''',
'''    {
        sed -nE \\
            's/^[[:space:]]*Loop[[:space:]]+([A-Za-z_][A-Za-z0-9_]*\\.[0-9]+):?.*$/\\1/p' \\
            "${LOOPS_STDOUT}" ||
            true
    } |
        sort -u > "${ACTUAL_LOOPS}"

    if [ ! -s "${ACTUAL_LOOPS}" ]; then
        echo "${CASE_ID}: no anchored loop declarations were parsed"
        echo "--- raw show-loops output"
        cat "${LOOPS_STDOUT}"
        fail "${CASE_ID}: reachable-loop parser produced an empty set"
    fi
''',
"replace loose regex with anchored Loop parser",
)


add_replacement(
'''        echo "MODEL=$(readlink -f "${MODEL}")"
        echo "MODEL_SHA256=$(sha256sum "${MODEL}" | awk '{print $1}')"
        echo "MODEL_SIZE=$(stat -c '%s' "${MODEL}")"
        echo "BUILD_EXIT_CODE=$(cat "${BUILD_EXIT}")"
        echo "VALIDATION_EXIT_CODE=$(cat "${VALIDATE_EXIT}")"
        echo "LOOP_EXTRACTION_EXIT_CODE=$(cat "${LOOPS_EXIT}")"
''',
'''        echo "AUTHORITATIVE_MODEL=$(readlink -f "${MODEL}")"
        echo "AUTHORITATIVE_MODEL_SHA256=$(sha256sum "${MODEL}" | awk '{print $1}')"
        echo "AUTHORITATIVE_MODEL_SIZE=$(stat -c '%s' "${MODEL}")"
        echo "REACHABLE_ONLY_MODEL=$(readlink -f "${REACHABLE_MODEL}")"
        echo "REACHABLE_ONLY_MODEL_SHA256=$(sha256sum "${REACHABLE_MODEL}" | awk '{print $1}')"
        echo "REACHABLE_ONLY_MODEL_SIZE=$(stat -c '%s' "${REACHABLE_MODEL}")"
        echo "BUILD_EXIT_CODE=$(cat "${BUILD_EXIT}")"
        echo "AUTHORITATIVE_VALIDATION_EXIT_CODE=$(cat "${VALIDATE_EXIT}")"
        echo "DROP_UNUSED_FUNCTIONS_EXIT_CODE=$(cat "${DROP_UNUSED_EXIT}")"
        echo "REACHABLE_VALIDATION_EXIT_CODE=$(cat "${REACHABLE_VALIDATE_EXIT}")"
        echo "LOOP_EXTRACTION_EXIT_CODE=$(cat "${LOOPS_EXIT}")"
        echo "LOOP_DISCOVERY_MODEL=REACHABLE_ONLY"
        echo "LATER_VERIFICATION_MODEL=AUTHORITATIVE_ORIGINAL"
''',
"expand case model binding",
)


add_replacement(
'''    echo "GOTO_MODELS_CREATED=4"
    echo "GOTO_MODELS_VALIDATED=4"
    echo "PRODUCTION_POLY_SUB_BODY_CONFIRMED=4_OF_4"
''',
'''    echo "AUTHORITATIVE_GOTO_MODELS_CREATED=4"
    echo "REACHABLE_ONLY_INSPECTION_MODELS_CREATED=4"
    echo "TOTAL_GOTO_MODELS_VALIDATED=8"
    echo "PRODUCTION_POLY_SUB_BODY_CONFIRMED=4_OF_4"
    echo "V1_PREFLIGHT_FAILURE_CLASSIFICATION=SCRIPT_LOOP_DISCOVERY_DEFECT"
    echo "V1_THEOREM_OR_COVERAGE_SOLVER_EXECUTED=NO"
    echo "V2_REPAIR_RECORD_INCLUDED=YES"
''',
"correct model counts and disclose V1",
)


add_replacement(
'''echo "=== MODEL HASHES ==="
''',
'''echo "=== AUTHORITATIVE AND REACHABLE-ONLY MODEL HASHES ==="
''',
"rename model-hash section",
)


for old, new, description in replacements:
    count = text.count(old)

    if count != 1:
        raise SystemExit(
            f"PATCH FAILURE: {description}: expected exactly one match, found {count}"
        )

    text = text.replace(old, new, 1)

target_path.write_text(text)
PY

chmod 0700 "${NEW}"

echo "=== R2: SCRIPT SYNTAX CHECK ==="

bash -n "${NEW}"

echo "CORRECTED_SCRIPT_SYNTAX=PASS"
echo

NEW_HASH="$(sha256sum "${NEW}" | awk '{print $1}')"

cat > "${PATCH_RECORD}" <<EOF
SUB00N B4.5 V1 FAILURE AND V2 REPAIR RECORD
DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

ORIGINAL_SCRIPT=${OLD}
ORIGINAL_SCRIPT_SHA256=${OLD_HASH}

CORRECTED_SCRIPT=${NEW}
CORRECTED_SCRIPT_SHA256=${NEW_HASH}

V1_FAILURE_CLASSIFICATION=SCRIPT_LOOP_DISCOVERY_DEFECT
V1_THEOREM_SOLVER_EXECUTED=NO
V1_COVERAGE_SOLVER_EXECUTED=NO
V1_NEGATIVE_CONTROL_SOLVER_EXECUTED=NO
V1_TEMPORARY_PREFLIGHT_MODEL_CREATED=YES
V1_TEMPORARY_STAGE_REMOVED=YES

DEFECT_1=Loop_discovery_was_applied_to_the_complete_linked_model
DEFECT_2=Unanchored_regex_captured_a_staging_path_suffix_as_a_loop_ID

V2_CORRECTION_1=Create_reachable_only_model_with_drop_unused_functions
V2_CORRECTION_2=Validate_reachable_only_model
V2_CORRECTION_3=Run_show_loops_only_on_reachable_only_model
V2_CORRECTION_4=Parse_only_lines_beginning_with_Loop
V2_CORRECTION_5=Keep_original_GOTO_model_as_later_verification_input

FROZEN_B4_4_HARNESSES_MODIFIED=NO
PRODUCTION_SOURCE_MODIFIED=NO
BATCH3_TOUCHED=NO
SUB_T1_RESULT_MODIFIED=NO
SUB_T2_RESULT_MODIFIED=NO
EOF

sha256sum "${PATCH_RECORD}" > "${PATCH_RECORD_HASH}"

chmod a-w "${PATCH_RECORD}" "${PATCH_RECORD_HASH}"

echo "=== R3: REPAIR ARTEFACTS ==="
stat --printf='MODE=%A SIZE=%s PATH=%n\n' \
    "${OLD}" \
    "${NEW}" \
    "${PATCH_RECORD}" \
    "${PATCH_RECORD_HASH}"

echo
echo "ORIGINAL_SCRIPT_SHA256=${OLD_HASH}"
echo "CORRECTED_SCRIPT_SHA256=${NEW_HASH}"
cat "${PATCH_RECORD_HASH}"

echo
echo "=== R4: EXECUTE CORRECTED B4.5-v2 PREFLIGHT ==="
echo

"${NEW}"
