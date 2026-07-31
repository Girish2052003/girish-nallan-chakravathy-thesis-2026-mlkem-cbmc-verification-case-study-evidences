#!/usr/bin/env bash
set -uo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"

WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t1_20260725T152707Z"

PROOF_NAME="polycomp_d4_t1_packed_refinement"

PROOF_DIR="${WORK_REPO}/proofs/cbmc/${PROOF_NAME}"

HARNESS_FILE="${PROOF_DIR}/polycomp_d4_t1_packed_refinement_harness.c"

GOTO_FILE="${PROOF_DIR}/gotos/polycomp_d4_t1_packed_refinement_harness.goto"

EXPECTED_GOTO_SHA256="cebb58e934cdff4c717bcef0273a937d22f4a4c08f1ace957da81ac25f3800b7"

CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"

STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_00D_T1_VALID_DIRECT_RUN"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_00D_T1_VALID_DIRECT_RUN_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

LOOP_REPORT="${STAGE_DIR}/POLYCOMP_D4_T1_SHOW_LOOPS_${UTC_STAMP}.txt"
LOOP_MAP="${STAGE_DIR}/POLYCOMP_D4_T1_UNWIND_MAP_${UTC_STAMP}.txt"

PROPERTY_REPORT="${STAGE_DIR}/POLYCOMP_D4_T1_PROPERTY_REPORT_${UTC_STAMP}.txt"

SEMANTIC_JSON="${STAGE_DIR}/POLYCOMP_D4_T1_SEMANTIC_RESULT_${UTC_STAMP}.json"
SEMANTIC_STDERR="${STAGE_DIR}/POLYCOMP_D4_T1_SEMANTIC_STDERR_${UTC_STAMP}.txt"
SEMANTIC_SUMMARY="${STAGE_DIR}/POLYCOMP_D4_T1_SEMANTIC_SUMMARY_${UTC_STAMP}.txt"

STRICT_JSON="${STAGE_DIR}/POLYCOMP_D4_T1_STRICT_RESULT_${UTC_STAMP}.json"
STRICT_STDERR="${STAGE_DIR}/POLYCOMP_D4_T1_STRICT_STDERR_${UTC_STAMP}.txt"
STRICT_SUMMARY="${STAGE_DIR}/POLYCOMP_D4_T1_STRICT_SUMMARY_${UTC_STAMP}.txt"

FAIL=0
SEMANTIC_EXIT=99
STRICT_EXIT=99
UNWINDSET=""

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

classify_json()
{
    local result_file="$1"
    local summary_file="$2"
    local expected_property="$3"

    python3 - \
        "$result_file" \
        "$summary_file" \
        "$expected_property" <<'PY'
import json
import sys
from collections import Counter
from pathlib import Path

result_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
expected_property = sys.argv[3]

try:
    payload = json.loads(result_path.read_text(encoding="utf-8"))
except Exception as error:
    summary_path.write_text(
        "JSON_PARSE_STATUS=FAIL\n"
        f"JSON_PARSE_ERROR={type(error).__name__}: {error}\n",
        encoding="utf-8",
    )
    print(summary_path.read_text(encoding="utf-8"), end="")
    raise SystemExit(2)

entries = payload if isinstance(payload, list) else [payload]

properties = []
cprover_statuses = []
messages = []

for entry in entries:
    if not isinstance(entry, dict):
        continue

    if "cProverStatus" in entry:
        cprover_statuses.append(str(entry["cProverStatus"]))

    if "cproverStatus" in entry:
        cprover_statuses.append(str(entry["cproverStatus"]))

    message = entry.get("message")

    if isinstance(message, dict):
        text = message.get("text")

        if text is not None:
            messages.append(str(text))

    result = entry.get("result")

    if isinstance(result, list):
        for item in result:
            if isinstance(item, dict):
                properties.append(item)

statuses = Counter(
    str(item.get("status", "UNKNOWN"))
    for item in properties
)

semantic_results = [
    item
    for item in properties
    if (
        expected_property in str(item.get("property", ""))
        or "POLYCOMP-D4-T1"
        in (
            str(item.get("description", ""))
            + " "
            + str(item.get("property", ""))
        )
    )
]

unwinding_results = [
    item
    for item in properties
    if "unwind"
    in (
        str(item.get("description", ""))
        + " "
        + str(item.get("property", ""))
    ).lower()
]

lines = [
    "JSON_PARSE_STATUS=PASS",
    f"PROPERTY_RESULT_COUNT={len(properties)}",
    "CPROVER_STATUSES="
    + (
        ",".join(cprover_statuses)
        if cprover_statuses
        else "<NOT_EXTRACTED>"
    ),
]

for status, count in sorted(statuses.items()):
    lines.append(f"STATUS_{status}={count}")

lines.append(
    f"T1_SEMANTIC_RESULT_COUNT={len(semantic_results)}"
)

for index, item in enumerate(semantic_results):
    lines.append(
        f"T1_SEMANTIC_RESULT_{index}="
        f"{item.get('status', 'UNKNOWN')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

lines.append(
    f"UNWINDING_RESULT_COUNT={len(unwinding_results)}"
)

for index, item in enumerate(unwinding_results):
    lines.append(
        f"UNWINDING_RESULT_{index}="
        f"{item.get('status', 'UNKNOWN')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

error_messages = [
    message
    for message in messages
    if "error" in message.lower()
]

lines.append(f"ERROR_MESSAGE_COUNT={len(error_messages)}")

for index, message in enumerate(error_messages[:20]):
    lines.append(f"ERROR_MESSAGE_{index}={message}")

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")
PY
}

main()
{
    local authoritative_head
    local work_head
    local authoritative_status
    local production_status
    local goto_sha256
    local harness_sha256
    local loop_parse_exit
    local property_exit
    local semantic_property_count

    section "POLYCOMP-D4-00D — VALID DIRECT T1 SEMANTIC AND SAFETY RUN"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'PROOF_DIR=%s\n' "$PROOF_DIR"
    printf 'HARNESS_FILE=%s\n' "$HARNESS_FILE"
    printf 'GOTO_FILE=%s\n' "$GOTO_FILE"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "00D.1 — SOURCE / HARNESS / GOTO REBINDING"

    if [[ ! -d "$AUTHORITATIVE_SOURCE_PATH" ]]; then
        mark_fail "authoritative source directory is missing"
        return 20
    fi

    if [[ ! -d "$WORK_REPO" ]]; then
        mark_fail "isolated work repository is missing"
        return 21
    fi

    if [[ ! -f "$HARNESS_FILE" ]]; then
        mark_fail "frozen T1 harness is missing"
        return 22
    fi

    if [[ ! -f "$GOTO_FILE" ]]; then
        mark_fail "frozen T1 GOTO binary is missing"
        return 23
    fi

    authoritative_head="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            rev-parse HEAD 2>/dev/null ||
        true
    )"

    work_head="$(
        git -C "$WORK_REPO" \
            rev-parse HEAD 2>/dev/null ||
        true
    )"

    printf 'AUTHORITATIVE_HEAD=%s\n' "$authoritative_head"
    printf 'WORK_REPO_HEAD=%s\n' "$work_head"

    if [[ "$authoritative_head" != "$EXPECTED_COMMIT" ]]; then
        mark_fail "authoritative repository is at the wrong commit"
    fi

    if [[ "$work_head" != "$EXPECTED_COMMIT" ]]; then
        mark_fail "work repository is at the wrong commit"
    fi

    authoritative_status="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            status --porcelain=v1 --untracked-files=all \
            2>/dev/null ||
        true
    )"

    if [[ -n "$authoritative_status" ]]; then
        printf '%s\n' "$authoritative_status"
        mark_fail "authoritative repository is dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE_BEFORE=CLEAN\n'
    fi

    production_status="$(
        git -C "$WORK_REPO" \
            status --porcelain=v1 -- \
            mlkem/src \
            2>/dev/null ||
        true
    )"

    if [[ -n "$production_status" ]]; then
        printf '%s\n' "$production_status"
        mark_fail "work-repository production source is modified"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_BEFORE=CLEAN\n'
    fi

    goto_sha256="$(
        sha256sum "$GOTO_FILE" |
        awk '{print $1}'
    )"

    harness_sha256="$(
        sha256sum "$HARNESS_FILE" |
        awk '{print $1}'
    )"

    printf 'GOTO_FILE_SIZE=%s\n' \
        "$(stat -c '%s' "$GOTO_FILE" 2>/dev/null || printf unknown)"

    printf 'GOTO_FILE_SHA256=%s\n' "$goto_sha256"
    printf 'EXPECTED_GOTO_SHA256=%s\n' "$EXPECTED_GOTO_SHA256"
    printf 'HARNESS_SHA256=%s\n' "$harness_sha256"

    if [[ "$goto_sha256" != "$EXPECTED_GOTO_SHA256" ]]; then
        mark_fail "GOTO binary differs from the 00C-bound binary"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 24
    fi

    printf 'SOURCE_HARNESS_GOTO_BINDING=PASS\n'

    section "00D.2 — CORRECT LOOP DISCOVERY"

    goto-instrument \
        --show-loops \
        "$GOTO_FILE" \
        > "$LOOP_REPORT" 2>&1

    LOOP_DISCOVERY_EXIT=$?

    printf 'LOOP_DISCOVERY_EXIT=%s\n' "$LOOP_DISCOVERY_EXIT"
    printf 'LOOP_REPORT=%s\n' "$LOOP_REPORT"

    cat "$LOOP_REPORT"

    if [[ "$LOOP_DISCOVERY_EXIT" -ne 0 ]]; then
        mark_fail "goto-instrument --show-loops failed"
        return 30
    fi

    python3 - \
        "$LOOP_REPORT" \
        "$LOOP_MAP" <<'PY'
import re
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
map_path = Path(sys.argv[2])

text = report_path.read_text(
    encoding="utf-8",
    errors="replace",
)

loop_ids = []

for line in text.splitlines():
    match = re.match(
        r"^\s*Loop\s+([^:]+):\s*$",
        line,
    )

    if match:
        loop_ids.append(match.group(1).strip())

loop_ids = list(dict.fromkeys(loop_ids))

harness_loops = [
    loop_id
    for loop_id in loop_ids
    if "harness" in loop_id
]

compressor_loops = [
    loop_id
    for loop_id in loop_ids
    if "poly_compress_d4_c" in loop_id
]

recognized = set(harness_loops + compressor_loops)

unexpected = [
    loop_id
    for loop_id in loop_ids
    if loop_id not in recognized
]

lines = [
    f"TOTAL_LOOP_COUNT={len(loop_ids)}",
    f"HARNESS_LOOP_COUNT={len(harness_loops)}",
    f"COMPRESSOR_LOOP_COUNT={len(compressor_loops)}",
    f"UNEXPECTED_LOOP_COUNT={len(unexpected)}",
]

for loop_id in loop_ids:
    lines.append(f"DISCOVERED_LOOP={loop_id}")

for loop_id in unexpected:
    lines.append(f"UNEXPECTED_LOOP={loop_id}")

if (
    len(loop_ids) != 4
    or len(harness_loops) != 2
    or len(compressor_loops) != 2
    or unexpected
):
    lines.append("LOOP_MAP_STATUS=FAIL")

    map_path.write_text(
        "\n".join(lines) + "\n",
        encoding="utf-8",
    )

    print(map_path.read_text(encoding="utf-8"), end="")
    raise SystemExit(1)

mapping = []

for loop_id in harness_loops:
    mapping.append((loop_id, 257, "harness-loop"))

for loop_id in compressor_loops:
    mapping.append((loop_id, 33, "portable-compressor-loop"))

unwindset = ",".join(
    f"{loop_id}:{bound}"
    for loop_id, bound, _ in mapping
)

for loop_id, bound, role in mapping:
    lines.append(
        f"LOOP_BOUND={loop_id}|{bound}|{role}"
    )

lines.append(f"UNWINDSET={unwindset}")
lines.append("LOOP_MAP_STATUS=PASS")

map_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(map_path.read_text(encoding="utf-8"), end="")
PY

    loop_parse_exit=$?

    printf 'LOOP_PARSE_EXIT=%s\n' "$loop_parse_exit"
    printf 'LOOP_MAP=%s\n' "$LOOP_MAP"

    if [[ "$loop_parse_exit" -ne 0 ]]; then
        mark_fail "loop inventory differs from the expected four-loop model"
        return 31
    fi

    UNWINDSET="$(
        sed -n 's/^UNWINDSET=//p' "$LOOP_MAP"
    )"

    if [[ -z "$UNWINDSET" ]]; then
        mark_fail "constructed unwindset is empty"
        return 32
    fi

    printf 'CONSTRUCTED_UNWINDSET=%s\n' "$UNWINDSET"
    printf 'LOOP_COMPLETENESS_PLAN=PASS\n'

    section "00D.3 — PROPERTY BINDING"

    cbmc \
        "$GOTO_FILE" \
        --show-properties \
        > "$PROPERTY_REPORT" 2>&1

    property_exit=$?

    printf 'PROPERTY_REPORT_EXIT=%s\n' "$property_exit"
    printf 'PROPERTY_REPORT=%s\n' "$PROPERTY_REPORT"

    if [[ "$property_exit" -ne 0 ]]; then
        cat "$PROPERTY_REPORT" || true
        mark_fail "CBMC could not display properties"
        return 40
    fi

    printf '\n--- T1 property excerpt ---\n'

    grep -n -B 5 -A 10 \
        'POLYCOMP-D4-T1' \
        "$PROPERTY_REPORT" ||
        true

    semantic_property_count="$(
        grep -c \
            'POLYCOMP-D4-T1' \
            "$PROPERTY_REPORT" ||
        true
    )"

    printf 'SEMANTIC_PROPERTY_DESCRIPTION_COUNT=%s\n' \
        "$semantic_property_count"

    if [[ "$semantic_property_count" -lt 1 ]]; then
        mark_fail "T1 semantic property is absent from the GOTO binary"
        return 41
    fi

    if ! grep -q \
        'harness.assertion.1' \
        "$PROPERTY_REPORT"
    then
        mark_fail "expected semantic property ID harness.assertion.1 is absent"
        return 42
    fi

    printf 'SEMANTIC_PROPERTY_ID=harness.assertion.1\n'
    printf 'SEMANTIC_PROPERTY_BINDING=PASS\n'

    section "00D.4 — SEMANTIC AND UNWINDING PREFLIGHT"

    printf 'SEMANTIC_COMMAND_BEGIN\n'

    printf 'cbmc %q \\\n' "$GOTO_FILE"
    printf '  --object-bits 8 \\\n'
    printf '  --slice-formula \\\n'
    printf '  --unwind 1 \\\n'
    printf '  --unwindset %q \\\n' "$UNWINDSET"
    printf '  --unwinding-assertions \\\n'
    printf '  --no-standard-checks \\\n'
    printf '  --trace --json-ui\n'

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

    printf 'SEMANTIC_JSON_SIZE=%s\n' \
        "$(stat -c '%s' "$SEMANTIC_JSON" 2>/dev/null ||
           printf unknown)"

    printf 'SEMANTIC_JSON_SHA256=%s\n' \
        "$(sha256sum "$SEMANTIC_JSON" | awk '{print $1}')"

    printf 'SEMANTIC_STDERR_SHA256=%s\n' \
        "$(sha256sum "$SEMANTIC_STDERR" | awk '{print $1}')"

    printf '\n--- semantic stderr ---\n'
    cat "$SEMANTIC_STDERR" 2>/dev/null || true

    printf '\n--- semantic classification ---\n'

    classify_json \
        "$SEMANTIC_JSON" \
        "$SEMANTIC_SUMMARY" \
        "harness.assertion.1"

    SEMANTIC_CLASSIFY_EXIT=$?

    printf 'SEMANTIC_CLASSIFY_EXIT=%s\n' \
        "$SEMANTIC_CLASSIFY_EXIT"

    printf 'SEMANTIC_SUMMARY=%s\n' \
        "$SEMANTIC_SUMMARY"

    printf '\n--- semantic JSON tail ---\n'
    tail -n 140 "$SEMANTIC_JSON" 2>/dev/null || true

    if [[ "$SEMANTIC_CLASSIFY_EXIT" -ne 0 ]]; then
        mark_fail "semantic JSON classification failed"
    fi

    if [[ "$SEMANTIC_EXIT" -ne 0 ]]; then
        mark_fail "semantic or unwinding preflight did not verify"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        section "00D.5 — STRICT RUN SKIPPED"

        printf 'STRICT_RUN_STATUS=SKIPPED_BECAUSE_SEMANTIC_PREFLIGHT_FAILED\n'

    else
        section "00D.5 — STRICT SAFETY PLUS SEMANTIC RUN"

        printf '%s\n' \
            'UNSIGNED_OVERFLOW_POLICY=NOT_GLOBALLY_CHECKED_BECAUSE_PRODUCTION_SCALAR_COMPRESSOR_REQUIRES_UINT32_WRAP'

        printf 'STRICT_COMMAND_BEGIN\n'

        printf 'cbmc %q \\\n' "$GOTO_FILE"
        printf '  --object-bits 8 \\\n'
        printf '  --slice-formula \\\n'
        printf '  --unwind 1 \\\n'
        printf '  --unwindset %q \\\n' "$UNWINDSET"
        printf '  --unwinding-assertions \\\n'
        printf '  --bounds-check \\\n'
        printf '  --pointer-check \\\n'
        printf '  --div-by-zero-check \\\n'
        printf '  --signed-overflow-check \\\n'
        printf '  --undefined-shift-check \\\n'
        printf '  --conversion-check \\\n'
        printf '  --pointer-overflow-check \\\n'
        printf '  --trace --json-ui\n'

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

        printf 'STRICT_JSON_SIZE=%s\n' \
            "$(stat -c '%s' "$STRICT_JSON" 2>/dev/null ||
               printf unknown)"

        printf 'STRICT_JSON_SHA256=%s\n' \
            "$(sha256sum "$STRICT_JSON" | awk '{print $1}')"

        printf 'STRICT_STDERR_SHA256=%s\n' \
            "$(sha256sum "$STRICT_STDERR" | awk '{print $1}')"

        printf '\n--- strict stderr ---\n'
        cat "$STRICT_STDERR" 2>/dev/null || true

        printf '\n--- strict classification ---\n'

        classify_json \
            "$STRICT_JSON" \
            "$STRICT_SUMMARY" \
            "harness.assertion.1"

        STRICT_CLASSIFY_EXIT=$?

        printf 'STRICT_CLASSIFY_EXIT=%s\n' \
            "$STRICT_CLASSIFY_EXIT"

        printf 'STRICT_SUMMARY=%s\n' \
            "$STRICT_SUMMARY"

        printf '\n--- strict JSON tail ---\n'
        tail -n 160 "$STRICT_JSON" 2>/dev/null || true

        if [[ "$STRICT_CLASSIFY_EXIT" -ne 0 ]]; then
            mark_fail "strict-result JSON classification failed"
        fi

        if [[ "$STRICT_EXIT" -ne 0 ]]; then
            mark_fail "strict safety-plus-semantic run did not verify"
        fi
    fi

    section "00D.6 — POST-RUN IMMUTABILITY"

    authoritative_status="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            status --porcelain=v1 --untracked-files=all \
            2>/dev/null ||
        true
    )"

    if [[ -n "$authoritative_status" ]]; then
        printf '%s\n' "$authoritative_status"
        mark_fail "authoritative repository became dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE_AFTER=CLEAN\n'
    fi

    production_status="$(
        git -C "$WORK_REPO" \
            status --porcelain=v1 -- \
            mlkem/src \
            2>/dev/null ||
        true
    )"

    if [[ -n "$production_status" ]]; then
        printf '%s\n' "$production_status"
        mark_fail "work-repository production source became dirty"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_AFTER=CLEAN\n'
    fi

    printf 'AUTHORITATIVE_HEAD_AFTER=%s\n' "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD
    )"

    printf 'WORK_REPO_HEAD_AFTER=%s\n' "$(
        git -C "$WORK_REPO" rev-parse HEAD
    )"

    section "POLYCOMP-D4-00D VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_00D_STATUS=PASS\n'
        printf 'T1_SEMANTIC_UNWINDING_PREFLIGHT=PASS\n'
        printf 'T1_STRICT_SAFETY_SEMANTIC_PREFLIGHT=PASS\n'
        printf 'T1_THEOREM_STATUS=POSITIVE_PREFLIGHT_VERIFIED_NOT_FINAL\n'
        printf 'NEXT_GATE=T1_COVERAGE_NONVACUITY_AND_MUTATION\n'
    else
        printf 'POLYCOMP_D4_00D_STATUS=FAIL\n'
        printf 'T1_THEOREM_STATUS=NOT_YET_ACCEPTED\n'
        printf 'NEXT_GATE=CLASSIFY_EXACT_REPORTED_PROPERTY_WITHOUT_SOURCE_MODIFICATION\n'
    fi

    printf 'LOOP_REPORT=%s\n' "$LOOP_REPORT"
    printf 'LOOP_MAP=%s\n' "$LOOP_MAP"
    printf 'PROPERTY_REPORT=%s\n' "$PROPERTY_REPORT"
    printf 'SEMANTIC_JSON=%s\n' "$SEMANTIC_JSON"
    printf 'SEMANTIC_SUMMARY=%s\n' "$SEMANTIC_SUMMARY"
    printf 'STRICT_JSON=%s\n' "$STRICT_JSON"
    printf 'STRICT_SUMMARY=%s\n' "$STRICT_SUMMARY"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-00D CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
