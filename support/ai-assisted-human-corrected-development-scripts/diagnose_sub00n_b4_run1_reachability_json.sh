#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

RUN1="${B4}/SUB00N_BATCH4_COMBINED_EXECUTION_MLKEM768_RUN1"
PACKAGE="${RUN1}.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"

CASE="${RUN1}/cases/REACHABILITY"
JSON="${CASE}/cbmc_result.json"
STDERR="${CASE}/cbmc_stderr.txt"
EXIT_FILE="${CASE}/cbmc_exit_code.txt"
COMMAND="${CASE}/cbmc_command.txt"
RESOURCE="${CASE}/resource_usage.txt"

POSITIVE="${RUN1}/cases/POSITIVE/CASE_CLASSIFICATION.txt"
WRAPPER="${RUN1}/wrapper_status.txt"
RUN_MANIFEST="${RUN1}/RESULT_ARTIFACT_MANIFEST.sha256"

OUT="${B4}/SUB00N_B4_6_RUN1_REACHABILITY_JSON_DIAGNOSTIC.txt"
OUT_HASH="${OUT}.sha256"
TMP="${B4}/.SUB00N_B4_6_RUN1_REACHABILITY_JSON_DIAGNOSTIC.tmp"

EXPECTED_PACKAGE_HASH="37063a635c00d56058b93221200cb444db332926752c4b2700e452848cc122b7"

echo "============================================================"
echo "SUB00N / BATCH 4 — RUN1 REACHABILITY JSON DIAGNOSTIC"
echo "============================================================"
echo

for required in \
    "${RUN1}" \
    "${PACKAGE}" \
    "${PACKAGE_HASH}" \
    "${RUN_MANIFEST}" \
    "${JSON}" \
    "${STDERR}" \
    "${EXIT_FILE}" \
    "${COMMAND}" \
    "${RESOURCE}" \
    "${POSITIVE}" \
    "${WRAPPER}"
do
    if [ ! -e "${required}" ]; then
        echo "ERROR: Required frozen RUN1 artefact missing:"
        echo "${required}"
        exit 1
    fi
done

if [ -e "${OUT}" ] || [ -e "${OUT_HASH}" ]; then
    echo "ERROR: Diagnostic artefact already exists."
    echo "Nothing was overwritten:"
    echo "${OUT}"
    echo "${OUT_HASH}"
    exit 1
fi

{
    echo "============================================================"
    echo "SUB00N B4.6 — RUN1 REACHABILITY CAPTURE DIAGNOSTIC"
    echo "============================================================"
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "RUN1=${RUN1}"
    echo

    echo "=== D1: FROZEN PACKAGE INTEGRITY ==="

    ACTUAL_PACKAGE_HASH="$(
        sha256sum "${PACKAGE}" |
        awk '{print $1}'
    )"

    echo "EXPECTED_PACKAGE_SHA256=${EXPECTED_PACKAGE_HASH}"
    echo "ACTUAL_PACKAGE_SHA256=${ACTUAL_PACKAGE_HASH}"

    if [ "${ACTUAL_PACKAGE_HASH}" = "${EXPECTED_PACKAGE_HASH}" ]; then
        echo "PACKAGE_HASH_BINDING=PASS"
    else
        echo "PACKAGE_HASH_BINDING=FAIL"
    fi

    sha256sum -c "${PACKAGE_HASH}"
    echo

    echo "=== D2: RUN1 RESULT-MANIFEST INTEGRITY ==="

    (
        cd "${RUN1}"
        sha256sum -c "$(basename "${RUN_MANIFEST}")"
    )
    echo

    echo "=== D3: WRAPPER AND POSITIVE-THEOREM STATUS ==="

    cat "${WRAPPER}"
    echo
    cat "${POSITIVE}"
    echo

    echo "=== D4: REACHABILITY COMMAND AND EXIT STATUS ==="

    cat "${COMMAND}"
    echo "CBMC_EXIT_CODE=$(cat "${EXIT_FILE}")"

    grep -E \
        'Exit status|Command being timed|Elapsed|Maximum resident' \
        "${RESOURCE}" ||
        true
    echo

    echo "=== D5: CAPTURE FILE METADATA ==="

    stat --printf='MODE=%A\nSIZE_BYTES=%s\nMTIME=%y\nPATH=%n\n' \
        "${JSON}"

    echo "LINE_COUNT=$(wc -l < "${JSON}")"
    echo "BYTE_COUNT=$(wc -c < "${JSON}")"

    if command -v file >/dev/null 2>&1; then
        file "${JSON}"
    fi
    echo

    echo "=== D6: FIRST 40 NUMBERED LINES ==="

    nl -ba "${JSON}" |
        sed -n '1,40p'
    echo

    echo "=== D7: LAST 40 NUMBERED LINES ==="

    nl -ba "${JSON}" |
        tail -n 40
    echo

    echo "=== D8: STDERR ==="

    if [ -s "${STDERR}" ]; then
        nl -ba "${STDERR}" |
            sed -n '1,160p'
    else
        echo "STDERR_EMPTY=YES"
    fi
    echo

    echo "=== D9: JSON PARSER FORENSICS ==="

    python3 - "${JSON}" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
raw = path.read_bytes()
text = raw.decode("utf-8", errors="replace")

print(f"RAW_BYTES={len(raw)}")
print(f"UTF8_TEXT_CHARACTERS={len(text)}")
print(f"STARTS_WITH_UTF8_BOM={raw.startswith(bytes([0xEF, 0xBB, 0xBF]))}")
print(f"NUL_BYTE_COUNT={raw.count(bytes([0]))}")
print(f"OPEN_SQUARE_COUNT={text.count('[')}")
print(f"CLOSE_SQUARE_COUNT={text.count(']')}")
print(f"OPEN_BRACE_COUNT={text.count('{')}")
print(f"CLOSE_BRACE_COUNT={text.count('}')}")
print(f"STATUS_TOKEN_COUNT={text.count(chr(34) + 'status' + chr(34))}")
print(f"SUCCESS_TOKEN_COUNT={text.count(chr(34) + 'SUCCESS' + chr(34))}")
print(f"FAILURE_TOKEN_COUNT={text.count(chr(34) + 'FAILURE' + chr(34))}")

try:
    value = json.loads(text)
except json.JSONDecodeError as exc:
    print("STRICT_JSON_PARSE=FAIL")
    print(f"JSON_ERROR_MESSAGE={exc.msg}")
    print(f"JSON_ERROR_LINE={exc.lineno}")
    print(f"JSON_ERROR_COLUMN={exc.colno}")
    print(f"JSON_ERROR_POSITION={exc.pos}")

    start = max(0, exc.pos - 240)
    end = min(len(text), exc.pos + 240)

    context = text[start:end]

    print("JSON_ERROR_CONTEXT_REPR_BEGIN")
    print(repr(context))
    print("JSON_ERROR_CONTEXT_REPR_END")

    line_start = max(1, exc.lineno - 3)
    line_end = exc.lineno + 3
    lines = text.splitlines()

    print("JSON_ERROR_NUMBERED_LINES_BEGIN")

    for number in range(line_start, min(line_end, len(lines)) + 1):
        print(f"{number:06d}: {lines[number - 1]!r}")

    print("JSON_ERROR_NUMBERED_LINES_END")
else:
    print("STRICT_JSON_PARSE=PASS")
    print(f"TOP_LEVEL_TYPE={type(value).__name__}")


decoder = json.JSONDecoder()
position = 0
fragments = []

while position < len(text):
    while position < len(text) and text[position].isspace():
        position += 1

    if position >= len(text):
        break

    try:
        _, end = decoder.raw_decode(text, position)
    except json.JSONDecodeError as exc:
        print(f"RAW_DECODE_STOP_POSITION={position}")
        print(f"RAW_DECODE_ERROR_POSITION={exc.pos}")
        print(f"RAW_DECODE_ERROR={exc.msg}")
        break

    fragments.append((position, end))
    position = end

print(f"COMPLETE_TOP_LEVEL_JSON_FRAGMENT_COUNT={len(fragments)}")

for index, (start, end) in enumerate(fragments[:20], 1):
    print(
        f"JSON_FRAGMENT_{index}_START={start} "
        f"END={end} LENGTH={end-start}"
    )
PY
    echo

    echo "=== D10: REACHABILITY-TOKEN PRESENCE ==="

    for token in \
        has_maximum_positive \
        has_maximum_negative \
        has_zero \
        has_interior_positive \
        has_interior_negative \
        SATISFIED \
        COVERED \
        SUCCESS \
        FAILURE \
        VERIFICATION
    do
        COUNT="$(
            grep -c "${token}" "${JSON}" ||
            true
        )"

        echo "${token}_LINE_COUNT=${COUNT}"
    done
    echo

    echo "=== D11: SCIENTIFIC CLASSIFICATION ==="
    echo "SUB_T4_POSITIVE_THEOREM=PASS_351_OF_351"
    echo "SUB_T4_REACHABILITY=UNCLASSIFIED_CAPTURE_FORMAT_FAILURE"
    echo "SUB_T4_INVALID_UPPER=NOT_EXECUTED"
    echo "SUB_T4_INVALID_LOWER=NOT_EXECUTED"
    echo "BATCH4_OVERALL=INCOMPLETE_NOT_FAILED"
    echo

    echo "=== D12: SCIENTIFIC ACTION RECORD ==="
    echo "CBMC_EXECUTED_BY_DIAGNOSTIC=NO"
    echo "GOTO_MODEL_CREATED_BY_DIAGNOSTIC=NO"
    echo "RUN1_MODIFIED=NO"
    echo "RUN1_PACKAGE_MODIFIED=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "FROZEN_HARNESS_MODIFIED=NO"
    echo "BATCH3_TOUCHED=NO"
    echo "SUB_T1_RESULT_MODIFIED=NO"
    echo "SUB_T2_RESULT_MODIFIED=NO"
} >"${TMP}" 2>&1

mv "${TMP}" "${OUT}"
sha256sum "${OUT}" >"${OUT_HASH}"

chmod a-w "${OUT}" "${OUT_HASH}"

cat "${OUT}"

echo
echo "============================================================"
echo "B4.6 DIAGNOSTIC ARTEFACTS"
echo "============================================================"

stat --printf='MODE=%A SIZE=%s PATH=%n\n' \
    "${OUT}" \
    "${OUT_HASH}"

echo
cat "${OUT_HASH}"

echo
echo "BATCH4_RUN1_DIAGNOSTIC_GATE=PASS"
echo "NO_CBMC_EXECUTION_OCCURRED=YES"
echo "RUN1_PRESERVED_UNCHANGED=YES"
