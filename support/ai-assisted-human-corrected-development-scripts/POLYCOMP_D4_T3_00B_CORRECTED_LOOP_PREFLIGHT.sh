#!/usr/bin/env bash
set -uo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t3_20260726T020556Z"
CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"

PROOF_NAME="polycomp_d4_t3_compressed_domain_retraction"
PROOF_DIR="${WORK_REPO}/proofs/cbmc/${PROOF_NAME}"
HARNESS_FILE="${PROOF_DIR}/polycomp_d4_t3_compressed_domain_retraction_harness.c"
MAKEFILE="${PROOF_DIR}/Makefile"
GOTO_FILE="${PROOF_DIR}/gotos/polycomp_d4_t3_compressed_domain_retraction_harness.goto"

EXPECTED_HARNESS_SHA256="caf64341e43db7abf668241e4012d4ab1064536fd3237d0577826e4728c7ea8f"
EXPECTED_MAKEFILE_SHA256="02ef8132f84ade6447e7139d1ea1840443e349eb88a6fef74983a54f6ef21654"
EXPECTED_GOTO_SHA256="6d35b9b1dac6fabf8f7fd207e9f9b116912e0351f30a543066dfd48d98bcc9c8"

STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_T3_00B_CORRECTED_LOOP_PREFLIGHT"
UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

SOURCE_LOOP_CONTEXT="${STAGE_DIR}/T3_COMPRESSOR_LOOP_CONTEXT_${UTC_STAMP}.txt"
LOOP_REPORT="${STAGE_DIR}/T3_LOOP_REPORT_${UTC_STAMP}.txt"
LOOP_MAP="${STAGE_DIR}/T3_LOOP_MAP_${UTC_STAMP}.txt"
PROPERTY_REPORT="${STAGE_DIR}/T3_PROPERTY_REPORT_${UTC_STAMP}.txt"

SEMANTIC_JSON="${STAGE_DIR}/T3_SEMANTIC_RESULT_${UTC_STAMP}.json"
SEMANTIC_STDERR="${STAGE_DIR}/T3_SEMANTIC_STDERR_${UTC_STAMP}.txt"
SEMANTIC_SUMMARY="${STAGE_DIR}/T3_SEMANTIC_SUMMARY_${UTC_STAMP}.txt"

STRICT_JSON="${STAGE_DIR}/T3_STRICT_RESULT_${UTC_STAMP}.json"
STRICT_STDERR="${STAGE_DIR}/T3_STRICT_STDERR_${UTC_STAMP}.txt"
STRICT_SUMMARY="${STAGE_DIR}/T3_STRICT_SUMMARY_${UTC_STAMP}.txt"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_T3_00B_CORRECTED_LOOP_PREFLIGHT_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

UNWINDSET="harness.0:129,mlk_poly_compress_d4_c.0:129,mlk_poly_compress_d4_c.1:257,mlk_poly_decompress_d4_c.0:129"

FAIL=0
mkdir -p "$STAGE_DIR"

section()
{
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

mark_fail()
{
    printf 'GATE_FAILURE: %s\n' "$1"
    FAIL=1
}

classify_positive()
{
    local json_file="$1"
    local summary_file="$2"
    local require_all="$3"

    python3 - \
        "$json_file" \
        "$summary_file" \
        "$require_all" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
require_all = sys.argv[3] == "yes"

description = (
    "POLYCOMP-D4-T3: compressing the real D4 decompression "
    "reconstructs every original input byte"
)

try:
    payload = json.loads(
        json_path.read_text(encoding="utf-8")
    )
except Exception as error:
    summary_path.write_text(
        "JSON_PARSE_STATUS=FAIL\n"
        f"JSON_PARSE_ERROR={type(error).__name__}: {error}\n",
        encoding="utf-8",
    )
    print(summary_path.read_text(encoding="utf-8"), end="")
    raise SystemExit(2)

entries = payload if isinstance(payload, list) else [payload]

results = []
statuses = []
errors = []

for entry in entries:
    if not isinstance(entry, dict):
        continue

    if "cProverStatus" in entry:
        statuses.append(str(entry["cProverStatus"]))

    if isinstance(entry.get("result"), list):
        results.extend(
            item
            for item in entry["result"]
            if isinstance(item, dict)
        )

    if (
        entry.get("messageType") == "ERROR"
        and isinstance(entry.get("messageText"), str)
    ):
        errors.append(entry["messageText"])

target_results = [
    item
    for item in results
    if str(item.get("description", "")) == description
]

target_success = (
    len(target_results) == 1
    and target_results[0].get("status") == "SUCCESS"
)

cprover_success = (
    bool(statuses)
    and all(
        status.lower() == "success"
        for status in statuses
    )
)

all_success = (
    bool(results)
    and all(
        item.get("status") == "SUCCESS"
        for item in results
    )
)

accepted = (
    target_success
    and cprover_success
    and not errors
    and (all_success if require_all else True)
)

lines = [
    "JSON_PARSE_STATUS=PASS",
    f"PROPERTY_RESULT_COUNT={len(results)}",
    "CPROVER_STATUSES="
    + (",".join(statuses) if statuses else "<MISSING>"),
    f"ERROR_MESSAGE_COUNT={len(errors)}",
    f"T3_RETRACTION_RESULT_COUNT={len(target_results)}",
]

for index, item in enumerate(target_results):
    lines.append(
        f"T3_RETRACTION_RESULT_{index}="
        f"{item.get('status', '')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

lines.append(
    "T3_COMPRESSED_DOMAIN_RETRACTION="
    + ("PASS" if target_success else "FAIL")
)

if require_all:
    lines.append(
        "ALL_REPORTED_PROPERTIES="
        + ("PASS" if all_success else "FAIL")
    )

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")

if not accepted:
    raise SystemExit(1)
PY
}

main()
{
    section "POLYCOMP-D4-T3-00B — CORRECTED FOUR-LOOP POSITIVE PREFLIGHT"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'PROOF_DIR=%s\n' "$PROOF_DIR"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "T3-00B.1 — SOURCE AND ARTEFACT REBINDING"

    for required in \
        "$HARNESS_FILE" \
        "$MAKEFILE" \
        "$GOTO_FILE"
    do
        if [[ ! -f "$required" ]]; then
            mark_fail "required artefact missing: $required"
        fi
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 20
    fi

    AUTHORITATIVE_HEAD="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD 2>/dev/null ||
        true
    )"

    WORK_HEAD="$(
        git -C "$WORK_REPO" rev-parse HEAD 2>/dev/null ||
        true
    )"

    printf 'AUTHORITATIVE_HEAD=%s\n' "$AUTHORITATIVE_HEAD"
    printf 'WORK_REPO_HEAD=%s\n' "$WORK_HEAD"

    if [[ "$AUTHORITATIVE_HEAD" != "$EXPECTED_COMMIT" ||
          "$WORK_HEAD" != "$EXPECTED_COMMIT" ]]
    then
        mark_fail "repository commit mismatch"
    fi

    if [[ -n "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            status --porcelain=v1 --untracked-files=all
    )" ]]
    then
        mark_fail "authoritative source is dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE_BEFORE=CLEAN\n'
    fi

    if [[ -n "$(
        git -C "$WORK_REPO" \
            status --porcelain=v1 -- mlkem/src
    )" ]]
    then
        mark_fail "T3 production source is modified"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_BEFORE=CLEAN\n'
    fi

    HARNESS_HASH="$(sha256sum "$HARNESS_FILE" | awk '{print $1}')"
    MAKEFILE_HASH="$(sha256sum "$MAKEFILE" | awk '{print $1}')"
    GOTO_HASH="$(sha256sum "$GOTO_FILE" | awk '{print $1}')"

    printf 'HARNESS_SHA256=%s\n' "$HARNESS_HASH"
    printf 'EXPECTED_HARNESS_SHA256=%s\n' "$EXPECTED_HARNESS_SHA256"
    printf 'MAKEFILE_SHA256=%s\n' "$MAKEFILE_HASH"
    printf 'EXPECTED_MAKEFILE_SHA256=%s\n' "$EXPECTED_MAKEFILE_SHA256"
    printf 'GOTO_SHA256=%s\n' "$GOTO_HASH"
    printf 'EXPECTED_GOTO_SHA256=%s\n' "$EXPECTED_GOTO_SHA256"

    if [[ "$HARNESS_HASH" != "$EXPECTED_HARNESS_SHA256" ||
          "$MAKEFILE_HASH" != "$EXPECTED_MAKEFILE_SHA256" ||
          "$GOTO_HASH" != "$EXPECTED_GOTO_SHA256" ]]
    then
        mark_fail "T3 artefact hash mismatch"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 21
    fi

    printf 'T3_SOURCE_AND_ARTEFACT_REBINDING=PASS\n'

    section "T3-00B.2 — PRODUCTION LOOP SOURCE CONTEXT"

    {
        printf '=== NUMBERED COMPRESSOR SOURCE CONTEXT ===\n'
        nl -ba "$WORK_REPO/mlkem/src/compress.c" |
            sed -n '38,66p'

        printf '\n=== NUMBERED DECOMPRESSOR SOURCE CONTEXT ===\n'
        nl -ba "$WORK_REPO/mlkem/src/compress.c" |
            sed -n '166,188p'
    } > "$SOURCE_LOOP_CONTEXT"

    cat "$SOURCE_LOOP_CONTEXT"

    printf 'SOURCE_LOOP_CONTEXT=%s\n' "$SOURCE_LOOP_CONTEXT"
    printf 'SOURCE_LOOP_CONTEXT_SHA256=%s\n' "$(
        sha256sum "$SOURCE_LOOP_CONTEXT" |
        awk '{print $1}'
    )"

    if ! grep -Eq \
        '^[[:space:]]*48[[:space:]].*for[[:space:]]*\(' \
        "$SOURCE_LOOP_CONTEXT"
    then
        mark_fail "expected compressor loop at source line 48 was not found"
    fi

    if ! grep -Eq \
        '^[[:space:]]*54[[:space:]].*for[[:space:]]*\(' \
        "$SOURCE_LOOP_CONTEXT"
    then
        mark_fail "expected compressor loop at source line 54 was not found"
    fi

    if ! grep -Eq \
        '^[[:space:]]*173[[:space:]].*for[[:space:]]*\(' \
        "$SOURCE_LOOP_CONTEXT"
    then
        mark_fail "expected decompressor loop at source line 173 was not found"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 30
    fi

    printf 'T3_PRODUCTION_LOOP_SOURCE_CONTEXT=PASS\n'

    section "T3-00B.3 — CORRECTED LOOP INVENTORY AND EXACT UNWINDSET"

    goto-instrument \
        --show-loops \
        "$GOTO_FILE" \
        > "$LOOP_REPORT" 2>&1

    LOOP_DISCOVERY_EXIT=$?

    printf 'LOOP_DISCOVERY_EXIT=%s\n' "$LOOP_DISCOVERY_EXIT"
    printf 'LOOP_REPORT=%s\n' "$LOOP_REPORT"

    cat "$LOOP_REPORT"

    if [[ "$LOOP_DISCOVERY_EXIT" -ne 0 ]]; then
        mark_fail "T3 loop discovery failed"
        return 40
    fi

    python3 - \
        "$LOOP_REPORT" \
        "$LOOP_MAP" \
        "$UNWINDSET" <<'PY'
import re
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
map_path = Path(sys.argv[2])
expected_unwindset = sys.argv[3]

text = report_path.read_text(
    encoding="utf-8",
    errors="replace",
)

loop_ids = re.findall(
    r"^Loop ([^:]+):$",
    text,
    flags=re.MULTILINE,
)

expected_ids = {
    "harness.0",
    "mlk_poly_compress_d4_c.0",
    "mlk_poly_compress_d4_c.1",
    "mlk_poly_decompress_d4_c.0",
}

expected_locations = {
    "mlk_poly_compress_d4_c.0": 54,
    "mlk_poly_compress_d4_c.1": 48,
    "mlk_poly_decompress_d4_c.0": 173,
}

locations = {}

blocks = re.split(
    r"(?=^Loop [^:]+:$)",
    text,
    flags=re.MULTILINE,
)

for block in blocks:
    match = re.match(
        r"^Loop ([^:]+):$",
        block,
        flags=re.MULTILINE,
    )

    if not match:
        continue

    loop_id = match.group(1)

    line_match = re.search(
        r"\bline ([0-9]+)\b",
        block,
    )

    if line_match:
        locations[loop_id] = int(line_match.group(1))

location_ok = all(
    locations.get(loop_id) == line
    for loop_id, line in expected_locations.items()
)

accepted = (
    len(loop_ids) == 4
    and set(loop_ids) == expected_ids
    and location_ok
)

lines = [
    f"TOTAL_LOOP_COUNT={len(loop_ids)}",
    f"UNIQUE_LOOP_COUNT={len(set(loop_ids))}",
    f"HARNESS_LOOP_COUNT={sum(x.startswith('harness.') for x in loop_ids)}",
    f"COMPRESSOR_LOOP_COUNT={sum(x.startswith('mlk_poly_compress_d4_c.') for x in loop_ids)}",
    f"DECOMPRESSOR_LOOP_COUNT={sum(x.startswith('mlk_poly_decompress_d4_c.') for x in loop_ids)}",
    f"UNEXPECTED_LOOP_COUNT={len(set(loop_ids) - expected_ids)}",
]

for loop_id in loop_ids:
    lines.append(
        f"DISCOVERED_LOOP={loop_id}|"
        f"SOURCE_LINE={locations.get(loop_id, 'UNKNOWN')}"
    )

lines.extend(
    [
        "LOOP_BOUND=harness.0|129|128-byte comparison loop",
        "LOOP_BOUND=mlk_poly_compress_d4_c.0|129|128-byte packing loop at line 54",
        "LOOP_BOUND=mlk_poly_compress_d4_c.1|257|256-coefficient quantization loop at line 48",
        "LOOP_BOUND=mlk_poly_decompress_d4_c.0|129|128-byte decompression loop",
        f"UNWINDSET={expected_unwindset}",
        "LOOP_LOCATION_BINDING="
        + ("PASS" if location_ok else "FAIL"),
        "LOOP_MAP_STATUS="
        + ("PASS" if accepted else "FAIL"),
    ]
)

map_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(map_path.read_text(encoding="utf-8"), end="")

if not accepted:
    raise SystemExit(1)
PY

    LOOP_PARSE_EXIT=$?

    printf 'LOOP_PARSE_EXIT=%s\n' "$LOOP_PARSE_EXIT"
    printf 'LOOP_MAP=%s\n' "$LOOP_MAP"
    printf 'CONSTRUCTED_UNWINDSET=%s\n' "$UNWINDSET"

    if [[ "$LOOP_PARSE_EXIT" -ne 0 ]]; then
        mark_fail "corrected T3 loop map did not bind"
        return 41
    fi

    printf 'T3_CORRECTED_LOOP_COMPLETENESS_PLAN=PASS\n'

    section "T3-00B.4 — PROPERTY BINDING"

    cbmc \
        "$GOTO_FILE" \
        --show-properties \
        > "$PROPERTY_REPORT" 2>&1

    PROPERTY_EXIT=$?

    printf 'PROPERTY_REPORT_EXIT=%s\n' "$PROPERTY_EXIT"
    printf 'PROPERTY_REPORT=%s\n' "$PROPERTY_REPORT"

    grep -n -B 5 -A 10 \
        'POLYCOMP-D4-T3:' \
        "$PROPERTY_REPORT" ||
        true

    T3_PROPERTY_COUNT="$(
        grep -c \
            'POLYCOMP-D4-T3: compressing the real D4 decompression reconstructs every original input byte' \
            "$PROPERTY_REPORT" ||
        true
    )"

    printf 'T3_RETRACTION_PROPERTY_COUNT=%s\n' "$T3_PROPERTY_COUNT"

    if [[ "$PROPERTY_EXIT" -ne 0 ||
          "$T3_PROPERTY_COUNT" != "1" ]]
    then
        mark_fail "T3 property binding failed"
        return 50
    fi

    printf 'T3_PROPERTY_BINDING=PASS\n'

    section "T3-00B.5 — DIRECT SEMANTIC PREFLIGHT"

    printf 'SEMANTIC_COMMAND_BEGIN\n'
    printf 'cbmc %q --object-bits 8 --slice-formula --unwind 1 --unwindset %q --unwinding-assertions --no-standard-checks --trace --json-ui\n' \
        "$GOTO_FILE" "$UNWINDSET"
    printf 'SEMANTIC_COMMAND_END\n'

    cbmc \
        "$GOTO_FILE" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$SEMANTIC_JSON" \
        2> "$SEMANTIC_STDERR"

    SEMANTIC_EXIT=$?

    printf 'SEMANTIC_CBMC_EXIT=%s\n' "$SEMANTIC_EXIT"
    printf 'SEMANTIC_JSON=%s\n' "$SEMANTIC_JSON"
    printf 'SEMANTIC_STDERR=%s\n' "$SEMANTIC_STDERR"
    printf 'SEMANTIC_JSON_SHA256=%s\n' "$(
        sha256sum "$SEMANTIC_JSON" |
        awk '{print $1}'
    )"

    cat "$SEMANTIC_STDERR" 2>/dev/null || true

    classify_positive \
        "$SEMANTIC_JSON" \
        "$SEMANTIC_SUMMARY" \
        "no"

    SEMANTIC_PARSE_EXIT=$?

    printf 'SEMANTIC_PARSE_EXIT=%s\n' "$SEMANTIC_PARSE_EXIT"
    printf 'SEMANTIC_SUMMARY=%s\n' "$SEMANTIC_SUMMARY"

    tail -n 120 "$SEMANTIC_JSON" 2>/dev/null || true

    if [[ "$SEMANTIC_EXIT" -ne 0 ||
          "$SEMANTIC_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "T3 semantic preflight failed"
        return 60
    fi

    printf 'T3_SEMANTIC_UNWINDING_PREFLIGHT=PASS\n'

    section "T3-00B.6 — STRICT SAFETY PLUS SEMANTIC PREFLIGHT"

    printf 'STRICT_COMMAND_BEGIN\n'
    printf 'cbmc %q --object-bits 8 --slice-formula --unwind 1 --unwindset %q --unwinding-assertions --bounds-check --pointer-check --div-by-zero-check --signed-overflow-check --unsigned-overflow-check --undefined-shift-check --conversion-check --pointer-overflow-check --trace --json-ui\n' \
        "$GOTO_FILE" "$UNWINDSET"
    printf 'STRICT_COMMAND_END\n'

    cbmc \
        "$GOTO_FILE" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --bounds-check \
        --pointer-check \
        --div-by-zero-check \
        --signed-overflow-check \
        --unsigned-overflow-check \
        --undefined-shift-check \
        --conversion-check \
        --pointer-overflow-check \
        --trace \
        --json-ui \
        > "$STRICT_JSON" \
        2> "$STRICT_STDERR"

    STRICT_EXIT=$?

    printf 'STRICT_CBMC_EXIT=%s\n' "$STRICT_EXIT"
    printf 'STRICT_JSON=%s\n' "$STRICT_JSON"
    printf 'STRICT_STDERR=%s\n' "$STRICT_STDERR"
    printf 'STRICT_JSON_SHA256=%s\n' "$(
        sha256sum "$STRICT_JSON" |
        awk '{print $1}'
    )"

    cat "$STRICT_STDERR" 2>/dev/null || true

    classify_positive \
        "$STRICT_JSON" \
        "$STRICT_SUMMARY" \
        "yes"

    STRICT_PARSE_EXIT=$?

    printf 'STRICT_PARSE_EXIT=%s\n' "$STRICT_PARSE_EXIT"
    printf 'STRICT_SUMMARY=%s\n' "$STRICT_SUMMARY"

    tail -n 140 "$STRICT_JSON" 2>/dev/null || true

    if [[ "$STRICT_EXIT" -ne 0 ||
          "$STRICT_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "T3 strict preflight failed"
        return 70
    fi

    printf 'T3_STRICT_SAFETY_SEMANTIC_PREFLIGHT=PASS\n'

    section "T3-00B.7 — POST-RUN SOURCE IMMUTABILITY"

    if [[ -n "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            status --porcelain=v1 --untracked-files=all
    )" ]]
    then
        mark_fail "authoritative source became dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE_AFTER=CLEAN\n'
    fi

    if [[ -n "$(
        git -C "$WORK_REPO" \
            status --porcelain=v1 -- mlkem/src
    )" ]]
    then
        mark_fail "T3 production source became dirty"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_AFTER=CLEAN\n'
    fi

    printf 'AUTHORITATIVE_HEAD_AFTER=%s\n' "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD
    )"

    printf 'WORK_REPO_HEAD_AFTER=%s\n' "$(
        git -C "$WORK_REPO" rev-parse HEAD
    )"

    section "POLYCOMP-D4-T3-00B VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_T3_00B_STATUS=PASS\n'
        printf 'T3_SOURCE_AND_ARTEFACT_REBINDING=PASS\n'
        printf 'T3_CORRECTED_LOOP_COMPLETENESS_PLAN=PASS\n'
        printf 'T3_PROPERTY_BINDING=PASS\n'
        printf 'T3_SEMANTIC_UNWINDING_PREFLIGHT=PASS\n'
        printf 'T3_STRICT_SAFETY_SEMANTIC_PREFLIGHT=PASS\n'
        printf 'T3_THEOREM_STATUS=POSITIVE_PREFLIGHT_VERIFIED_NOT_FINAL\n'
        printf 'NEXT_GATE=T3_COVERAGE_REACHABILITY_AND_ONE_SIDED_MUTATIONS\n'
    else
        printf 'POLYCOMP_D4_T3_00B_STATUS=FAIL\n'
        printf 'T3_THEOREM_STATUS=NOT_VERIFIED\n'
        printf 'NEXT_GATE=CLASSIFY_EXACT_T3_CBMC_FAILURE\n'
    fi

    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'HARNESS_FILE=%s\n' "$HARNESS_FILE"
    printf 'HARNESS_SHA256=%s\n' "$HARNESS_HASH"
    printf 'MAKEFILE=%s\n' "$MAKEFILE"
    printf 'MAKEFILE_SHA256=%s\n' "$MAKEFILE_HASH"
    printf 'GOTO_FILE=%s\n' "$GOTO_FILE"
    printf 'GOTO_SHA256=%s\n' "$GOTO_HASH"
    printf 'UNWINDSET=%s\n' "$UNWINDSET"
    printf 'LOOP_MAP=%s\n' "$LOOP_MAP"
    printf 'SEMANTIC_JSON=%s\n' "$SEMANTIC_JSON"
    printf 'STRICT_JSON=%s\n' "$STRICT_JSON"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-T3-00B CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
