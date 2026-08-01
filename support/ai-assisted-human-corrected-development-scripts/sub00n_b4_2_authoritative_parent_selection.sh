#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

B41="${B4}/SUB00N_B4_1_BUILD_BINDING_EXTRACTION.txt"
B41_HASH="${B41}.sha256"

OUT="${B4}/SUB00N_B4_2_AUTHORITATIVE_PARENT_SELECTION.txt"
OUT_HASH="${OUT}.sha256"
TMP="${B4}/.SUB00N_B4_2_AUTHORITATIVE_PARENT_SELECTION.tmp"

FROZEN_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

echo "============================================================"
echo "SUB00N / BATCH 4 — B4.2 AUTHORITATIVE PARENT SELECTION"
echo "============================================================"
echo

for required in "${B41}" "${B41_HASH}"; do
    if [ ! -f "${required}" ]; then
        echo "ERROR: Required B4.1 artefact missing:"
        echo "${required}"
        exit 1
    fi
done

if [ -e "${OUT}" ] || [ -e "${OUT_HASH}" ]; then
    echo "ERROR: B4.2 output already exists."
    echo "Nothing was overwritten:"
    echo "${OUT}"
    echo "${OUT_HASH}"
    exit 1
fi

FAIL=0

{
    echo "============================================================"
    echo "SUB00N / BATCH 4 — AUTHORITATIVE PARENT COMPARISON"
    echo "============================================================"
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "ROOT=${ROOT}"
    echo "B4=${B4}"
    echo

    echo "=== B4.2-A: PARENT INTEGRITY ==="

    if sha256sum -c "${B41_HASH}"; then
        echo "B4_1_INTEGRITY=PASS"
    else
        echo "B4_1_INTEGRITY=FAIL"
        FAIL=1
    fi
    echo

    echo "=== B4.2-B: PROCESS ISOLATION ==="

    ACTIVE_B4="$(
        pgrep -af \
          '(^|/)(cbmc|goto-cc|goto-clang|goto-instrument)([[:space:]]|.*)(SUB00N|sub_t4|batch4_canonical)' \
          || true
    )"

    if [ -n "${ACTIVE_B4}" ]; then
        echo "ACTIVE_BATCH4_PROCESS=YES"
        printf '%s\n' "${ACTIVE_B4}"
        FAIL=1
    else
        echo "ACTIVE_BATCH4_PROCESS=NO"
    fi

    echo "BATCH3_PROCESS_ACTION=NONE"
    echo

    echo "=== B4.2-C: MODE-A MANIFEST CANDIDATES ==="

    mapfile -t MODE_A_FILES < <(
        find "${ROOT}" -type f \
          \( -name 'SUB00F_MODE_A_EXECUTION_MANIFEST.md' \
             -o -iname '*MODE*A*EXECUTION*MANIFEST*' \) \
          ! -path "${B4}/*" \
          -print |
        sort -u
    )

    echo "MODE_A_MANIFEST_COUNT=${#MODE_A_FILES[@]}"

    if [ "${#MODE_A_FILES[@]}" -eq 0 ]; then
        echo "MODE_A_MANIFESTS_FOUND=NO"
        FAIL=1
    fi

    MANIFEST_INDEX=0

    for manifest in "${MODE_A_FILES[@]}"; do
        MANIFEST_INDEX=$((MANIFEST_INDEX + 1))

        echo
        echo "------------------------------------------------------------"
        echo "MANIFEST_CANDIDATE=${MANIFEST_INDEX}"
        echo "PATH=$(realpath "${manifest}")"
        stat --printf='MODE=%A\nSIZE=%s\nMTIME=%y\n' "${manifest}"
        echo "SHA256=$(sha256sum "${manifest}" | awk '{print $1}')"

        if grep -Fq "${FROZEN_COMMIT}" "${manifest}"; then
            echo "HAS_FROZEN_COMMIT=YES"
        else
            echo "HAS_FROZEN_COMMIT=NO"
        fi

        if grep -Eiq 'SUB[-_]?T1|sub_t1_semantic' "${manifest}"; then
            echo "HAS_SUB_T1_BINDING=YES"
        else
            echo "HAS_SUB_T1_BINDING=NO"
        fi

        if grep -Eq '361[[:space:]]*/[[:space:]]*361|361.*SUCCESS|SUCCESS.*361' "${manifest}"; then
            echo "HAS_361_SUCCESS_RECORD=YES"
        else
            echo "HAS_361_SUCCESS_RECORD=NO"
        fi

        if grep -Eiq 'VERIFICATION SUCCESSFUL|RESULT[=:[:space:]]*PASS|VERDICT[=:[:space:]]*PASS' "${manifest}"; then
            echo "HAS_PASS_RECORD=YES"
        else
            echo "HAS_PASS_RECORD=NO"
        fi

        if grep -Eq -- '--unwinding-assertions' "${manifest}"; then
            echo "HAS_UNWINDING_ASSERTIONS=YES"
        else
            echo "HAS_UNWINDING_ASSERTIONS=NO"
        fi

        if grep -Eq -- '--unwindset|--unwind([=[:space:]]|$)' "${manifest}"; then
            echo "HAS_EXPLICIT_UNWIND_BINDING=YES"
        else
            echo "HAS_EXPLICIT_UNWIND_BINDING=NO"
        fi

        if grep -Eiq 'loop.contract.*(off|disabled|none)|APPLY_LOOP_CONTRACTS[=:[:space:]]*(off|0|no)' "${manifest}"; then
            echo "HAS_MODE_A_LOOP_CONTRACT_DISABLE_RECORD=YES"
        else
            echo "HAS_MODE_A_LOOP_CONTRACT_DISABLE_RECORD=NOT_EXPLICITLY_FOUND"
        fi

        echo
        echo "--- RELEVANT MANIFEST LINES"

        grep -nEi \
          'd9613cf60de3132d32475c102d8c2781d84feb34|SUB[-_]?T1|sub_t1_semantic|361|VERIFICATION SUCCESSFUL|RESULT|VERDICT|PASS|goto-cc|goto-clang|goto-instrument|(^|[[:space:]])cbmc([[:space:]]|$)|--function|--unwind|--unwindset|--unwinding-assertions|--conversion-check|--signed-overflow-check|--bounds-check|--pointer-check|--object-bits|loop.contract|APPLY_LOOP_CONTRACTS|MLK_CONFIG|MLKEM_K|MLK_NAMESPACE' \
          "${manifest}" |
          head -n 180 || true
    done

    echo
    echo "=== B4.2-D: REFERENCE HARNESS CANDIDATES ==="

    mapfile -t HARNESS_FILES < <(
        find "${ROOT}" -type f \
          \( -name 'sub_t1_semantic_harness.c' \
             -o -name 'sub_t2_relational_harness.c' \) \
          ! -path "${B4}/*" \
          -print |
        sort -u
    )

    echo "REFERENCE_HARNESS_COUNT=${#HARNESS_FILES[@]}"

    if [ "${#HARNESS_FILES[@]}" -eq 0 ]; then
        echo "REFERENCE_HARNESSES_FOUND=NO"
        FAIL=1
    fi

    HARNESS_INDEX=0

    for harness in "${HARNESS_FILES[@]}"; do
        HARNESS_INDEX=$((HARNESS_INDEX + 1))
        ABS_HARNESS="$(realpath "${harness}")"
        BASE_HARNESS="$(basename "${harness}")"
        HASH_HARNESS="$(sha256sum "${harness}" | awk '{print $1}')"

        REFERENCE_COUNT=0

        for manifest in "${MODE_A_FILES[@]}"; do
            if grep -Fq "${ABS_HARNESS}" "${manifest}" ||
               grep -Fq "${BASE_HARNESS}" "${manifest}"; then
                REFERENCE_COUNT=$((REFERENCE_COUNT + 1))
            fi
        done

        echo
        echo "------------------------------------------------------------"
        echo "HARNESS_CANDIDATE=${HARNESS_INDEX}"
        echo "PATH=${ABS_HARNESS}"
        echo "BASENAME=${BASE_HARNESS}"
        stat --printf='MODE=%A\nSIZE=%s\nMTIME=%y\n' "${harness}"
        echo "SHA256=${HASH_HARNESS}"
        echo "MODE_A_MANIFEST_REFERENCE_COUNT=${REFERENCE_COUNT}"

        if [ -w "${harness}" ]; then
            echo "READ_ONLY=NO"
        else
            echo "READ_ONLY=YES"
        fi

        if grep -Eiq 'FIPS_N|FIPS_Q' "${harness}"; then
            echo "HAS_INDEPENDENT_FIPS_BINDING=YES"
        else
            echo "HAS_INDEPENDENT_FIPS_BINDING=NO"
        fi

        if grep -Eq 'mlk_poly_sub[[:space:]]*\(' "${harness}"; then
            echo "CALLS_PRODUCTION_SUB=YES"
        else
            echo "CALLS_PRODUCTION_SUB=NO"
        fi

        if grep -Eq 'mlk_poly_reduce[[:space:]]*\(' "${harness}"; then
            echo "CALLS_PRODUCTION_REDUCE=YES"
        else
            echo "CALLS_PRODUCTION_REDUCE=NO"
        fi

        ASSERT_COUNT="$(
            grep -Ec '__CPROVER_assert|assert[[:space:]]*\(' "${harness}" || true
        )"
        ASSUME_COUNT="$(
            grep -Ec '__CPROVER_assume' "${harness}" || true
        )"

        echo "ASSERTION_SOURCE_LINE_COUNT=${ASSERT_COUNT}"
        echo "ASSUMPTION_SOURCE_LINE_COUNT=${ASSUME_COUNT}"

        echo "--- STRUCTURAL LINES"

        grep -nE \
          '^[[:space:]]*#include|^[[:space:]]*#define|int main|void harness|__CPROVER_assume|__CPROVER_assert|mlk_poly_sub|mlk_poly_reduce|FIPS_N|FIPS_Q|MLKEM_N|MLKEM_Q' \
          "${harness}" |
          head -n 100 || true
    done

    echo
    echo "=== B4.2-E: HASH GROUPING OF HARNESS COPIES ==="

    if [ "${#HARNESS_FILES[@]}" -gt 0 ]; then
        for harness in "${HARNESS_FILES[@]}"; do
            printf '%s  %s\n' \
              "$(sha256sum "${harness}" | awk '{print $1}')" \
              "$(realpath "${harness}")"
        done |
        sort
    fi

    echo
    echo "=== B4.2-F: MANIFEST-TO-HARNESS REFERENCES ==="

    for manifest in "${MODE_A_FILES[@]}"; do
        echo
        echo "--- MANIFEST: $(realpath "${manifest}")"

        grep -nEi \
          'sub_t1_semantic_harness\.c|sub_t2_relational_harness\.c|HARNESS(_FILE|_PATH)?[=:[:space:]]|ENTRY(_FUNCTION)?[=:[:space:]]|--function' \
          "${manifest}" |
          head -n 100 || true
    done

    echo
    echo "=== B4.2-G: AUTHORITATIVE RESULT EVIDENCE SEARCH ==="

    mapfile -t RESULT_FILES < <(
        grep -RIl \
          --exclude-dir=.git \
          --exclude-dir=proofs \
          --exclude-dir="${B4##*/}" \
          --include='*.txt' \
          --include='*.md' \
          --include='*.log' \
          --include='*.json' \
          -E '361[[:space:]]*/[[:space:]]*361|SUB[-_]?T1.*PASS|VERIFICATION SUCCESSFUL' \
          "${ROOT}" 2>/dev/null |
        sort -u |
        head -n 30
    )

    echo "AUTHORITATIVE_RESULT_CANDIDATE_COUNT=${#RESULT_FILES[@]}"

    for result_file in "${RESULT_FILES[@]}"; do
        echo
        echo "--- RESULT CANDIDATE: $(realpath "${result_file}")"
        stat --printf='MODE=%A SIZE=%s MTIME=%y\n' "${result_file}"
        echo "SHA256=$(sha256sum "${result_file}" | awk '{print $1}')"

        grep -nEi \
          'SUB[-_]?T1|361[[:space:]]*/[[:space:]]*361|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|FAILURE|SUCCESS|unwinding|command|harness|goto|cbmc' \
          "${result_file}" |
          head -n 80 || true
    done

    echo
    echo "=== B4.2-H: SELECTION STATUS ==="
    echo "PRODUCTION_SOURCE_SELECTION=UNAMBIGUOUS"
    echo "MODE_A_MANIFEST_SELECTION=AWAITING_COMPARISON"
    echo "REFERENCE_HARNESS_SELECTION=AWAITING_COMPARISON"
    echo "AUTOMATIC_SELECTION_PERFORMED=NO"
    echo

    echo "=== B4.2-I: SCIENTIFIC ACTION RECORD ==="
    echo "CBMC_THEOREM_EXECUTED=NO"
    echo "GOTO_MODEL_CREATED=NO"
    echo "NEW_HARNESS_CREATED=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "EXISTING_HARNESS_MODIFIED=NO"
    echo "BATCH3_TOUCHED=NO"
    echo "BATCH3_PROCESS_ACTION=NONE"
    echo "SUB_T1_RESULT_MODIFIED=NO"
    echo "SUB_T2_RESULT_MODIFIED=NO"
    echo

    if [ "${FAIL}" -eq 0 ]; then
        echo "SUB00N_B4_2_COMPARISON_VERDICT=PASS"
    else
        echo "SUB00N_B4_2_COMPARISON_VERDICT=FAIL"
    fi
} > "${TMP}" 2>&1

mv "${TMP}" "${OUT}"
sha256sum "${OUT}" > "${OUT_HASH}"

chmod a-w "${OUT}" "${OUT_HASH}"

cat "${OUT}"

echo
echo "============================================================"
echo "SUB00N / BATCH 4 — B4.2 CREATED ARTEFACTS"
echo "============================================================"
stat --printf='MODE=%A SIZE=%s PATH=%n\n' \
    "${OUT}" \
    "${OUT_HASH}"

echo
echo "=== SHA-256 ==="
cat "${OUT_HASH}"

echo
if [ "${FAIL}" -eq 0 ]; then
    echo "BATCH4_PARENT_COMPARISON_GATE=PASS"
    echo "NO_CBMC_EXECUTION_OCCURRED=YES"
    exit 0
else
    echo "BATCH4_PARENT_COMPARISON_GATE=FAIL"
    echo "NO_CBMC_EXECUTION_OCCURRED=YES"
    exit 1
fi
