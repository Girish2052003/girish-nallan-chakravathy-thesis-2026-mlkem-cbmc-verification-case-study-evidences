#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

DISCOVERY="${B4}/SUB00N_B4_0_DISCOVERY_PACKET.txt"
DISCOVERY_HASH="${DISCOVERY}.sha256"
PREREG="${B4}/SUB00N_B4_0_THEOREM_PREREGISTRATION.md"
PREREG_HASH="${PREREG}.sha256"

OUT="${B4}/SUB00N_B4_1_BUILD_BINDING_EXTRACTION.txt"
OUT_HASH="${OUT}.sha256"
TMP="${B4}/.SUB00N_B4_1_BUILD_BINDING_EXTRACTION.tmp"

echo "============================================================"
echo "SUB00N / BATCH 4 — B4.1 BUILD-BINDING EXTRACTION"
echo "============================================================"
echo "ROOT=${ROOT}"
echo "B4=${B4}"
echo

for required in \
    "${DISCOVERY}" \
    "${DISCOVERY_HASH}" \
    "${PREREG}" \
    "${PREREG_HASH}"
do
    if [ ! -f "${required}" ]; then
        echo "ERROR: Required frozen artefact missing:"
        echo "${required}"
        exit 1
    fi
done

if [ -e "${OUT}" ] || [ -e "${OUT_HASH}" ]; then
    echo "ERROR: B4.1 extraction already exists."
    echo "Nothing was overwritten."
    echo "${OUT}"
    echo "${OUT_HASH}"
    exit 1
fi

FAIL=0

{
    echo "============================================================"
    echo "SUB00N / BATCH 4 — AUTHORITATIVE BUILD BINDING"
    echo "============================================================"
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "ROOT=${ROOT}"
    echo "B4=${B4}"
    echo

    echo "=== B4.1-A: PARENT INTEGRITY ==="

    if sha256sum -c "${PREREG_HASH}"; then
        echo "PREREGISTRATION_INTEGRITY=PASS"
    else
        echo "PREREGISTRATION_INTEGRITY=FAIL"
        FAIL=1
    fi

    if sha256sum -c "${DISCOVERY_HASH}"; then
        echo "DISCOVERY_PACKET_INTEGRITY=PASS"
    else
        echo "DISCOVERY_PACKET_INTEGRITY=FAIL"
        FAIL=1
    fi
    echo

    echo "=== B4.1-B: TOOL BINDING ==="

    if command -v cbmc >/dev/null 2>&1; then
        echo "CBMC_PATH=$(command -v cbmc)"
        echo "CBMC_VERSION=$(cbmc --version 2>&1 | head -n 1)"
    else
        echo "CBMC_FOUND=NO"
        FAIL=1
    fi

    if command -v goto-cc >/dev/null 2>&1; then
        echo "GOTO_COMPILER_KIND=goto-cc"
        echo "GOTO_COMPILER_PATH=$(command -v goto-cc)"
    elif command -v goto-clang >/dev/null 2>&1; then
        echo "GOTO_COMPILER_KIND=goto-clang"
        echo "GOTO_COMPILER_PATH=$(command -v goto-clang)"
    else
        echo "GOTO_COMPILER_FOUND=NO"
        FAIL=1
    fi

    echo "CC_PATH=$(command -v cc 2>/dev/null || echo NOT_FOUND)"
    echo "MACHINE=$(uname -m)"
    echo "HOST=$(uname -a)"
    echo

    echo "=== B4.1-C: PORTABLE PRODUCTION SOURCE CANDIDATES ==="

    mapfile -t POLY_C_FILES < <(
        find "${ROOT}" -type f \
            -path '*/mlkem/src/poly.c' \
            ! -path '*/proofs/*' \
            ! -path "${B4}/*" \
            -print |
        sort -u
    )

    echo "POLY_C_CANDIDATE_COUNT=${#POLY_C_FILES[@]}"

    if [ "${#POLY_C_FILES[@]}" -eq 0 ]; then
        echo "POLY_C_BINDING=FAIL_NO_CANDIDATE"
        FAIL=1
    else
        for f in "${POLY_C_FILES[@]}"; do
            echo
            echo "POLY_C_PATH=$(realpath "${f}")"
            stat --printf='POLY_C_MODE=%A\nPOLY_C_SIZE=%s\n' "${f}"
            sha256sum "${f}"
        done
    fi
    echo

    echo "=== B4.1-D: PRODUCTION FUNCTION EXCERPT ==="

    for f in "${POLY_C_FILES[@]}"; do
        echo
        echo "--- SOURCE: $(realpath "${f}")"
        grep -n -A25 -B10 \
            'mlk_poly_sub' "${f}" |
            head -n 120 || true
    done
    echo

    echo "=== B4.1-E: REFERENCE HARNESS BINDING ==="

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
        echo "REFERENCE_HARNESS_BINDING=FAIL"
        FAIL=1
    else
        for f in "${HARNESS_FILES[@]}"; do
            echo
            echo "REFERENCE_HARNESS_PATH=$(realpath "${f}")"
            stat --printf='REFERENCE_HARNESS_MODE=%A\nREFERENCE_HARNESS_SIZE=%s\n' "${f}"
            sha256sum "${f}"

            echo "--- STRUCTURE"
            grep -nE \
                '^[[:space:]]*#include|^[[:space:]]*#define|int main|void harness|__CPROVER_assume|__CPROVER_assert|__CPROVER_cover|mlk_poly_sub|mlk_poly_reduce|FIPS_N|FIPS_Q|MLKEM_N|MLKEM_Q' \
                "${f}" |
                head -n 220 || true
        done
    fi
    echo

    echo "=== B4.1-F: MODE-A MANIFEST BINDING ==="

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
        echo "MODE_A_MANIFEST_BINDING=FAIL"
        FAIL=1
    else
        for f in "${MODE_A_FILES[@]}"; do
            echo
            echo "MODE_A_MANIFEST_PATH=$(realpath "${f}")"
            stat --printf='MODE_A_MANIFEST_MODE=%A\nMODE_A_MANIFEST_SIZE=%s\n' "${f}"
            sha256sum "${f}"

            echo "--- COMMAND-RELEVANT MANIFEST LINES"
            grep -nEi \
                'goto-cc|goto-clang|goto-instrument|cbmc|--function|--unwind|--unwindset|--unwinding-assertions|--conversion-check|--signed-overflow-check|--bounds-check|--pointer-check|--object-bits|loop-contract|function-contract|MLK_CONFIG|MLKEM_K|MLK_NAMESPACE' \
                "${f}" |
                head -n 260 || true
        done
    fi
    echo

    echo "=== B4.1-G: PRIOR AUTHORITATIVE BUILD FILES ==="

    mapfile -t BUILD_FILES < <(
        grep -RIl \
            --exclude-dir=.git \
            --exclude-dir=proofs \
            --exclude-dir="${B4##*/}" \
            --include='*.sh' \
            --include='*.md' \
            --include='*.txt' \
            --include='*.command' \
            'sub_t1_semantic_harness.c' \
            "${ROOT}" 2>/dev/null |
        sort -u |
        head -n 20
    )

    echo "BUILD_REFERENCE_FILE_COUNT=${#BUILD_FILES[@]}"

    for f in "${BUILD_FILES[@]}"; do
        echo
        echo "--- BUILD REFERENCE: $(realpath "${f}")"
        stat --printf='MODE=%A SIZE=%s\n' "${f}"

        grep -nEi \
            'sub_t1_semantic_harness|goto-cc|goto-clang|goto-instrument|cbmc|--function|--unwind|--unwindset|--unwinding-assertions|--conversion-check|--signed-overflow-check|--bounds-check|--pointer-check|--object-bits|MLK_CONFIG|MLKEM_K|MLK_NAMESPACE|mlkem/src/poly.c' \
            "${f}" |
            head -n 220 || true
    done
    echo

    echo "=== B4.1-H: INCLUDE AND CONFIGURATION CANDIDATES ==="

    mapfile -t CONFIG_FILES < <(
        find "${ROOT}" -type f \
            \( -name 'config.h' \
               -o -name 'params.h' \
               -o -name 'poly.h' \
               -o -name 'common.h' \) \
            ! -path '*/proofs/*' \
            ! -path "${B4}/*" \
            -print |
        sort -u
    )

    echo "CONFIG_CANDIDATE_COUNT=${#CONFIG_FILES[@]}"

    for f in "${CONFIG_FILES[@]}"; do
        case "${f}" in
            */mlkem/*)
                echo "CONFIG_PATH=$(realpath "${f}")"
                ;;
        esac
    done
    echo

    echo "=== B4.1-I: FROZEN DISCOVERY COMMAND EXCERPTS ==="

    grep -nEi \
        'goto-cc|goto-clang|goto-instrument|(^|[[:space:]])cbmc([[:space:]]|$)|--function|--unwind|--unwindset|--unwinding-assertions|--conversion-check|--signed-overflow-check|--bounds-check|--pointer-check|--object-bits|MODE.A|sub_t1_semantic_harness' \
        "${DISCOVERY}" |
        head -n 320 || true
    echo

    echo "=== B4.1-J: AMBIGUITY ASSESSMENT ==="

    echo "POLY_C_CANDIDATE_COUNT=${#POLY_C_FILES[@]}"
    echo "REFERENCE_HARNESS_COUNT=${#HARNESS_FILES[@]}"
    echo "MODE_A_MANIFEST_COUNT=${#MODE_A_FILES[@]}"
    echo "BUILD_REFERENCE_FILE_COUNT=${#BUILD_FILES[@]}"

    if [ "${#POLY_C_FILES[@]}" -eq 1 ]; then
        echo "PRODUCTION_SOURCE_AMBIGUITY=NONE"
    else
        echo "PRODUCTION_SOURCE_AMBIGUITY=REVIEW_REQUIRED"
    fi

    if [ "${#MODE_A_FILES[@]}" -eq 1 ]; then
        echo "MODE_A_MANIFEST_AMBIGUITY=NONE"
    else
        echo "MODE_A_MANIFEST_AMBIGUITY=REVIEW_REQUIRED"
    fi
    echo

    echo "=== B4.1-K: SCIENTIFIC ACTION RECORD ==="
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
        echo "SUB00N_B4_1_EXTRACTION_VERDICT=PASS"
    else
        echo "SUB00N_B4_1_EXTRACTION_VERDICT=FAIL"
    fi
} > "${TMP}" 2>&1

mv "${TMP}" "${OUT}"
sha256sum "${OUT}" > "${OUT_HASH}"

chmod a-w "${OUT}" "${OUT_HASH}"

cat "${OUT}"

echo
echo "============================================================"
echo "SUB00N / BATCH 4 — B4.1 CREATED ARTEFACTS"
echo "============================================================"
stat --printf='MODE=%A SIZE=%s PATH=%n\n' \
    "${OUT}" \
    "${OUT_HASH}"

echo
echo "=== SHA-256 ==="
cat "${OUT_HASH}"

echo
if [ "${FAIL}" -eq 0 ]; then
    echo "BATCH4_BUILD_BINDING_GATE=PASS"
    echo "NO_CBMC_EXECUTION_OCCURRED=YES"
    exit 0
else
    echo "BATCH4_BUILD_BINDING_GATE=FAIL"
    echo "NO_CBMC_EXECUTION_OCCURRED=YES"
    exit 1
fi
