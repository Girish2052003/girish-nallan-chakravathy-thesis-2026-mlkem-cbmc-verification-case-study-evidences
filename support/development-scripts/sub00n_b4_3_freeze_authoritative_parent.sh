#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

B42="${B4}/SUB00N_B4_2_AUTHORITATIVE_PARENT_SELECTION.txt"
B42_HASH="${B42}.sha256"

SELECTED_MANIFEST="${ROOT}/sub00f_mode_a_execution_freeze_v1/SUB00F_MODE_A_EXECUTION_MANIFEST.md"
DUPLICATE_MANIFEST="${ROOT}/SUB00F_MODE_A_EXECUTION_MANIFEST.md"

SELECTED_HARNESS="${ROOT}/sub00f_mode_a_execution_freeze_v1/harnesses/sub_t1_semantic_harness.c"
SUCCESS_RESULT="${ROOT}/SUB00H_T1_PRAGMA_SCOPED_MODE_A_MLKEM768_RUN1/cbmc_result.json"
SUCCESS_RUN_DIR="${ROOT}/SUB00H_T1_PRAGMA_SCOPED_MODE_A_MLKEM768_RUN1"

EXPECTED_MANIFEST_HASH="20f392542441c996ba58e9caddc950ca7d5dd9ed222dc9858077b1a187cb782a"
EXPECTED_HARNESS_HASH="42c09c2f004d567d8b886058bd2304d960a219d36f0f6605b015966db3bc5682"
EXPECTED_RESULT_HASH="3e78e8c95ccaaedbf3f1b0fc9420192807f4576beec7350dd26a0095ace7f7ba"

OUT="${B4}/SUB00N_B4_3_AUTHORITATIVE_PARENT_BINDING.md"
OUT_HASH="${OUT}.sha256"

EXTRACT="${B4}/SUB00N_B4_3_SUCCESSFUL_COMMAND_EXTRACTION.txt"
EXTRACT_HASH="${EXTRACT}.sha256"

OUT_TMP="${B4}/.SUB00N_B4_3_AUTHORITATIVE_PARENT_BINDING.tmp"
EXTRACT_TMP="${B4}/.SUB00N_B4_3_SUCCESSFUL_COMMAND_EXTRACTION.tmp"

echo "============================================================"
echo "SUB00N / BATCH 4 — B4.3 AUTHORITATIVE PARENT FREEZE"
echo "============================================================"
echo

for required in \
    "${B42}" \
    "${B42_HASH}" \
    "${SELECTED_MANIFEST}" \
    "${DUPLICATE_MANIFEST}" \
    "${SELECTED_HARNESS}" \
    "${SUCCESS_RESULT}"
do
    if [ ! -f "${required}" ]; then
        echo "ERROR: Required parent artefact missing:"
        echo "${required}"
        exit 1
    fi
done

for new_file in \
    "${OUT}" \
    "${OUT_HASH}" \
    "${EXTRACT}" \
    "${EXTRACT_HASH}"
do
    if [ -e "${new_file}" ]; then
        echo "ERROR: B4.3 artefact already exists."
        echo "Nothing was overwritten:"
        echo "${new_file}"
        exit 1
    fi
done

FAIL=0

check_exact_hash()
{
    local file="$1"
    local expected="$2"
    local label="$3"
    local actual

    actual="$(sha256sum "${file}" | awk '{print $1}')"

    echo "${label}_PATH=$(realpath "${file}")"
    echo "${label}_EXPECTED_SHA256=${expected}"
    echo "${label}_ACTUAL_SHA256=${actual}"

    if [ "${actual}" = "${expected}" ]; then
        echo "${label}_HASH_CHECK=PASS"
    else
        echo "${label}_HASH_CHECK=FAIL"
        FAIL=1
    fi
}

{
    echo "============================================================"
    echo "SUB00N / BATCH 4 — AUTHORITATIVE PARENT BINDING EVIDENCE"
    echo "============================================================"
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "ROOT=${ROOT}"
    echo "B4=${B4}"
    echo

    echo "=== B4.3-A: COMPARISON-PACKET INTEGRITY ==="

    if sha256sum -c "${B42_HASH}"; then
        echo "B4_2_COMPARISON_INTEGRITY=PASS"
    else
        echo "B4_2_COMPARISON_INTEGRITY=FAIL"
        FAIL=1
    fi
    echo

    echo "=== B4.3-B: DUPLICATE-MANIFEST RESOLUTION ==="

    check_exact_hash \
        "${SELECTED_MANIFEST}" \
        "${EXPECTED_MANIFEST_HASH}" \
        "SELECTED_MANIFEST"

    echo

    check_exact_hash \
        "${DUPLICATE_MANIFEST}" \
        "${EXPECTED_MANIFEST_HASH}" \
        "DUPLICATE_MANIFEST"

    echo

    if cmp -s "${SELECTED_MANIFEST}" "${DUPLICATE_MANIFEST}"; then
        echo "MANIFESTS_BYTE_IDENTICAL=YES"
        echo "MANIFEST_AMBIGUITY_CLASSIFICATION=DUPLICATE_COPY_NOT_SEMANTIC_CONFLICT"
    else
        echo "MANIFESTS_BYTE_IDENTICAL=NO"
        echo "MANIFEST_AMBIGUITY_CLASSIFICATION=UNRESOLVED_CONFLICT"
        FAIL=1
    fi
    echo

    echo "=== B4.3-C: AUTHORITATIVE HARNESS BINDING ==="

    check_exact_hash \
        "${SELECTED_HARNESS}" \
        "${EXPECTED_HARNESS_HASH}" \
        "SELECTED_HARNESS"

    if [ -w "${SELECTED_HARNESS}" ]; then
        echo "SELECTED_HARNESS_READ_ONLY=NO"
        FAIL=1
    else
        echo "SELECTED_HARNESS_READ_ONLY=YES"
    fi
    echo

    echo "=== B4.3-D: SUCCESSFUL RESULT BINDING ==="

    check_exact_hash \
        "${SUCCESS_RESULT}" \
        "${EXPECTED_RESULT_HASH}" \
        "SUCCESS_RESULT"

    if grep -Fq "$(realpath "${SELECTED_HARNESS}")" "${SUCCESS_RESULT}"; then
        echo "SUCCESS_RESULT_REFERENCES_SELECTED_HARNESS=YES"
    else
        echo "SUCCESS_RESULT_REFERENCES_SELECTED_HARNESS=NO"
        FAIL=1
    fi

    if grep -Fq '"program": "CBMC 6.9.0' "${SUCCESS_RESULT}"; then
        echo "SUCCESS_RESULT_CBMC_VERSION_BINDING=PASS"
    else
        echo "SUCCESS_RESULT_CBMC_VERSION_BINDING=FAIL"
        FAIL=1
    fi

    SUCCESS_COUNT="$(
        grep -c '"status": "SUCCESS"' "${SUCCESS_RESULT}" || true
    )"

    FAILURE_COUNT="$(
        grep -c '"status": "FAILURE"' "${SUCCESS_RESULT}" || true
    )"

    echo "SUCCESS_STATUS_COUNT=${SUCCESS_COUNT}"
    echo "FAILURE_STATUS_COUNT=${FAILURE_COUNT}"

    if [ "${SUCCESS_COUNT}" -eq 361 ] &&
       [ "${FAILURE_COUNT}" -eq 0 ]; then
        echo "SUCCESS_RESULT_PROPERTY_SUMMARY=PASS_361_OF_361"
    else
        echo "SUCCESS_RESULT_PROPERTY_SUMMARY=REVIEW_REQUIRED"
        FAIL=1
    fi
    echo

    echo "=== B4.3-E: GOTO-PARENT EXTRACTION ==="

    GOTO_PATH="$(
        grep -m1 'Reading GOTO program from file ' "${SUCCESS_RESULT}" |
        sed -E \
          's/.*Reading GOTO program from file ([^"]+)".*/\1/'
    )"

    echo "SUCCESSFUL_GOTO_PATH=${GOTO_PATH}"

    if [ -n "${GOTO_PATH}" ] && [ -f "${GOTO_PATH}" ]; then
        echo "SUCCESSFUL_GOTO_FOUND=YES"
        stat --printf='GOTO_MODE=%A\nGOTO_SIZE=%s\n' "${GOTO_PATH}"
        echo "GOTO_SHA256=$(sha256sum "${GOTO_PATH}" | awk '{print $1}')"
    else
        echo "SUCCESSFUL_GOTO_FOUND=NO"
        FAIL=1
    fi

    if [ -n "${GOTO_PATH}" ]; then
        GOTO_BUILD_DIR="$(dirname "${GOTO_PATH}")"
        GOTO_PARENT_DIR="$(dirname "${GOTO_BUILD_DIR}")"
    else
        GOTO_BUILD_DIR=""
        GOTO_PARENT_DIR=""
    fi

    echo "GOTO_BUILD_DIR=${GOTO_BUILD_DIR}"
    echo "GOTO_PARENT_DIR=${GOTO_PARENT_DIR}"
    echo

    echo "=== B4.3-F: FROZEN SELECTION DECISION ==="
    echo "AUTHORITATIVE_MODE_A_MANIFEST=$(realpath "${SELECTED_MANIFEST}")"
    echo "AUTHORITATIVE_REFERENCE_HARNESS=$(realpath "${SELECTED_HARNESS}")"
    echo "AUTHORITATIVE_SUCCESS_RESULT=$(realpath "${SUCCESS_RESULT}")"
    echo "AUTHORITATIVE_SUCCESS_RUN_DIR=$(realpath "${SUCCESS_RUN_DIR}")"
    echo "AUTHORITATIVE_GOTO_MODEL=${GOTO_PATH}"
    echo
    echo "SELECTION_RATIONALE_1=Both_manifest_candidates_are_byte_identical"
    echo "SELECTION_RATIONALE_2=The_selected_manifest_is_inside_the_original_freeze_directory"
    echo "SELECTION_RATIONALE_3=The_successful_CBMC_result_references_the_selected_harness_path"
    echo "SELECTION_RATIONALE_4=The_selected_harness_is_read_only_and_matches_the_successful_run"
    echo "AUTOMATIC_GUESSING_USED=NO"
    echo

    echo "=== B4.3-G: SCIENTIFIC ACTION RECORD ==="
    echo "CBMC_THEOREM_EXECUTED=NO"
    echo "GOTO_MODEL_CREATED=NO"
    echo "NEW_THEOREM_HARNESS_CREATED=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "EXISTING_HARNESS_MODIFIED=NO"
    echo "BATCH3_TOUCHED=NO"
    echo "BATCH3_PROCESS_ACTION=NONE"
    echo "SUB_T1_RESULT_MODIFIED=NO"
    echo "SUB_T2_RESULT_MODIFIED=NO"
    echo

    if [ "${FAIL}" -eq 0 ]; then
        echo "SUB00N_B4_3_PARENT_BINDING_VERDICT=PASS"
    else
        echo "SUB00N_B4_3_PARENT_BINDING_VERDICT=FAIL"
    fi
} > "${EXTRACT_TMP}" 2>&1

# Recover the selected GOTO parent from the generated evidence.
GOTO_PATH="$(
    grep '^SUCCESSFUL_GOTO_PATH=' "${EXTRACT_TMP}" |
    cut -d= -f2-
)"

if [ -n "${GOTO_PATH}" ]; then
    GOTO_PARENT_DIR="$(dirname "$(dirname "${GOTO_PATH}")")"
else
    GOTO_PARENT_DIR=""
fi

{
    echo
    echo "============================================================"
    echo "SUB00N / BATCH 4 — SUCCESSFUL COMMAND EXTRACTION"
    echo "============================================================"
    echo

    echo "=== B4.3-H: AUTHORITATIVE MANIFEST CONTENT ==="
    sed -n '1,240p' "${SELECTED_MANIFEST}"
    echo

    echo "=== B4.3-I: AUTHORITATIVE T1 HARNESS CONTENT ==="
    sed -n '1,260p' "${SELECTED_HARNESS}"
    echo

    echo "=== B4.3-J: SUCCESSFUL PREFLIGHT COMMAND FILES ==="

    if [ -n "${GOTO_PARENT_DIR}" ] &&
       [ -d "${GOTO_PARENT_DIR}" ]; then

        echo "GOTO_PARENT_DIR=${GOTO_PARENT_DIR}"

        mapfile -t PREFLIGHT_COMMAND_FILES < <(
            grep -RIl \
              --exclude='*.goto' \
              --exclude='*.json' \
              --include='*.sh' \
              --include='*.txt' \
              --include='*.md' \
              --include='*.command' \
              --include='*.env' \
              -E 'goto-cc|goto-clang|goto-instrument|--unwindset|--function[[:space:]]+main' \
              "${GOTO_PARENT_DIR}" 2>/dev/null |
            sort -u
        )

        echo "PREFLIGHT_COMMAND_FILE_COUNT=${#PREFLIGHT_COMMAND_FILES[@]}"

        for file in "${PREFLIGHT_COMMAND_FILES[@]}"; do
            echo
            echo "------------------------------------------------------------"
            echo "PREFLIGHT_COMMAND_FILE=$(realpath "${file}")"
            stat --printf='MODE=%A SIZE=%s\n' "${file}"
            echo "SHA256=$(sha256sum "${file}" | awk '{print $1}')"
            echo "--- COMMAND-RELEVANT LINES"

            grep -nEi \
              'goto-cc|goto-clang|goto-instrument|cbmc|--function|--unwind|--unwindset|--unwinding-assertions|--object-bits|--bounds-check|--pointer-check|--conversion-check|--signed-overflow-check|MLK_CONFIG|MLKEM_K|MLK_NAMESPACE|poly\.c|sub_t1_semantic_harness' \
              "${file}" |
              head -n 240 || true
        done
    else
        echo "GOTO_PARENT_DIRECTORY_AVAILABLE=NO"
        FAIL=1
    fi
    echo

    echo "=== B4.3-K: SUCCESSFUL EXECUTION COMMAND FILES ==="

    if [ -d "${SUCCESS_RUN_DIR}" ]; then
        mapfile -t RUN_COMMAND_FILES < <(
            grep -RIl \
              --exclude='*.goto' \
              --exclude='cbmc_result.json' \
              --include='*.sh' \
              --include='*.txt' \
              --include='*.md' \
              --include='*.command' \
              --include='*.env' \
              -E '(^|[[:space:]])cbmc([[:space:]]|$)|--unwindset|--unwinding-assertions|--function[[:space:]]+main' \
              "${SUCCESS_RUN_DIR}" 2>/dev/null |
            sort -u
        )

        echo "RUN_COMMAND_FILE_COUNT=${#RUN_COMMAND_FILES[@]}"

        for file in "${RUN_COMMAND_FILES[@]}"; do
            echo
            echo "------------------------------------------------------------"
            echo "RUN_COMMAND_FILE=$(realpath "${file}")"
            stat --printf='MODE=%A SIZE=%s\n' "${file}"
            echo "SHA256=$(sha256sum "${file}" | awk '{print $1}')"
            echo "--- COMMAND-RELEVANT LINES"

            grep -nEi \
              '(^|[[:space:]])cbmc([[:space:]]|$)|--function|--unwind|--unwindset|--unwinding-assertions|--object-bits|--bounds-check|--pointer-check|--conversion-check|--signed-overflow-check|goto|result|exit' \
              "${file}" |
              head -n 260 || true
        done
    else
        echo "SUCCESS_RUN_DIRECTORY_AVAILABLE=NO"
        FAIL=1
    fi
    echo

    echo "=== B4.3-L: DIRECT COMMAND INVENTORY ==="

    if [ -n "${GOTO_PARENT_DIR}" ] &&
       [ -d "${GOTO_PARENT_DIR}" ]; then
        grep -RInE \
          --exclude='*.goto' \
          --exclude='*.json' \
          --include='*.sh' \
          --include='*.txt' \
          --include='*.md' \
          --include='*.command' \
          'goto-cc|goto-clang|goto-instrument|--unwindset|--unwinding-assertions' \
          "${GOTO_PARENT_DIR}" 2>/dev/null |
          head -n 360 || true
    fi

    grep -RInE \
      --exclude='cbmc_result.json' \
      --include='*.sh' \
      --include='*.txt' \
      --include='*.md' \
      --include='*.command' \
      '(^|[[:space:]])cbmc([[:space:]]|$)|--unwindset|--unwinding-assertions' \
      "${SUCCESS_RUN_DIR}" 2>/dev/null |
      head -n 360 || true

    echo
    echo "=== B4.3-M: EXTRACTION ACTION RECORD ==="
    echo "COMMANDS_EXECUTED=NO"
    echo "CBMC_EXECUTED=NO"
    echo "GOTO_MODEL_CREATED=NO"
    echo "SOURCE_FILES_MODIFIED=NO"
    echo "BATCH3_TOUCHED=NO"
} >> "${EXTRACT_TMP}"

mv "${EXTRACT_TMP}" "${EXTRACT}"
sha256sum "${EXTRACT}" > "${EXTRACT_HASH}"

{
    echo "# SUB00N B4.3 — Frozen Authoritative Parent Selection"
    echo
    echo "## Frozen campaign root"
    echo
    echo "\`${ROOT}\`"
    echo
    echo "## Selected MODE-A manifest"
    echo
    echo "\`${SELECTED_MANIFEST}\`"
    echo
    echo "SHA-256:"
    echo
    echo "\`${EXPECTED_MANIFEST_HASH}\`"
    echo
    echo "## Selected successful reference harness"
    echo
    echo "\`${SELECTED_HARNESS}\`"
    echo
    echo "SHA-256:"
    echo
    echo "\`${EXPECTED_HARNESS_HASH}\`"
    echo
    echo "## Selected successful result"
    echo
    echo "\`${SUCCESS_RESULT}\`"
    echo
    echo "SHA-256:"
    echo
    echo "\`${EXPECTED_RESULT_HASH}\`"
    echo
    echo "## Selection decision"
    echo
    echo "The two discovered MODE-A manifests are byte-identical copies."
    echo
    echo "The manifest inside the original SUB00F freeze directory is selected."
    echo
    echo "The successful SUB-T1 CBMC result explicitly references the"
    echo "read-only harness inside that same freeze directory."
    echo
    echo "No theorem execution or source modification occurred during B4.3."
} > "${OUT_TMP}"

mv "${OUT_TMP}" "${OUT}"
sha256sum "${OUT}" > "${OUT_HASH}"

chmod a-w \
    "${OUT}" \
    "${OUT_HASH}" \
    "${EXTRACT}" \
    "${EXTRACT_HASH}"

cat "${EXTRACT}"

echo
echo "============================================================"
echo "SUB00N / BATCH 4 — B4.3 CREATED ARTEFACTS"
echo "============================================================"

stat --printf='MODE=%A SIZE=%s PATH=%n\n' \
    "${OUT}" \
    "${OUT_HASH}" \
    "${EXTRACT}" \
    "${EXTRACT_HASH}"

echo
echo "=== SHA-256 ==="
cat "${OUT_HASH}"
cat "${EXTRACT_HASH}"

echo
if [ "${FAIL}" -eq 0 ]; then
    echo "BATCH4_AUTHORITATIVE_PARENT_FREEZE_GATE=PASS"
    echo "NO_CBMC_EXECUTION_OCCURRED=YES"
    exit 0
else
    echo "BATCH4_AUTHORITATIVE_PARENT_FREEZE_GATE=FAIL"
    echo "NO_CBMC_EXECUTION_OCCURRED=YES"
    exit 1
fi
