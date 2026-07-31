#!/usr/bin/env bash
set -uo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"

WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t1_20260725T152707Z"

PROOF_NAME="polycomp_d4_t1_packed_refinement"

PROOF_DIR="${WORK_REPO}/proofs/cbmc/${PROOF_NAME}"

GOTO_FILE="${PROOF_DIR}/gotos/polycomp_d4_t1_packed_refinement_harness.goto"

CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"

STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_00C_T1_DIRECT_DIAG"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_00C_T1_DIRECT_DIAG_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

LOOP_REPORT="${STAGE_DIR}/POLYCOMP_D4_T1_LOOP_IDS_${UTC_STAMP}.txt"
PROPERTY_REPORT="${STAGE_DIR}/POLYCOMP_D4_T1_PROPERTIES_${UTC_STAMP}.txt"

DIRECT_RESULT_JSON="${STAGE_DIR}/POLYCOMP_D4_T1_DIRECT_RESULT_${UTC_STAMP}.json"
DIRECT_STDERR="${STAGE_DIR}/POLYCOMP_D4_T1_DIRECT_STDERR_${UTC_STAMP}.txt"
DIRECT_SUMMARY="${STAGE_DIR}/POLYCOMP_D4_T1_DIRECT_SUMMARY_${UTC_STAMP}.txt"

FAIL=0
DIRECT_CBMC_EXIT=99

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

main()
{
    local authoritative_head
    local authoritative_status
    local work_head
    local production_status

    section "POLYCOMP-D4-00C — T1 RUNNER DIAGNOSIS AND DIRECT CBMC"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'PROOF_DIR=%s\n' "$PROOF_DIR"
    printf 'GOTO_FILE=%s\n' "$GOTO_FILE"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "00C.1 — SOURCE AND WORK-REPOSITORY REBINDING"

    if [[ ! -d "$AUTHORITATIVE_SOURCE_PATH" ]]; then
        mark_fail "authoritative source directory is missing"
        return 20
    fi

    if [[ ! -d "$WORK_REPO" ]]; then
        mark_fail "00B isolated work repository is missing"
        return 21
    fi

    authoritative_head="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD 2>/dev/null ||
        true
    )"

    work_head="$(
        git -C "$WORK_REPO" rev-parse HEAD 2>/dev/null ||
        true
    )"

    printf 'AUTHORITATIVE_HEAD=%s\n' "$authoritative_head"
    printf 'WORK_REPO_HEAD=%s\n' "$work_head"

    if [[ "$authoritative_head" != "$EXPECTED_COMMIT" ]]; then
        mark_fail "authoritative source is at the wrong commit"
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
        mark_fail "authoritative source is dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE=CLEAN\n'
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
        printf 'WORK_REPO_PRODUCTION_SOURCE=CLEAN\n'
    fi

    if [[ ! -f "$GOTO_FILE" ]]; then
        mark_fail "expected GOTO binary was not produced by 00B"
    else
        printf 'GOTO_FILE_PRESENT=PASS\n'
        printf 'GOTO_FILE_SIZE=%s\n' \
            "$(stat -c '%s' "$GOTO_FILE" 2>/dev/null || printf unknown)"
        printf 'GOTO_FILE_SHA256=%s\n' \
            "$(sha256sum "$GOTO_FILE" | awk '{print $1}')"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 22
    fi

    section "00C.2 — ORIGINAL RUNNER FAILURE LOGS"

    for diagnostic_file in \
        "${PROOF_DIR}/logs/coverage-err-log.txt" \
        "${PROOF_DIR}/logs/result-err-log.txt" \
        "${PROOF_DIR}/logs/coverage.xml" \
        "${PROOF_DIR}/logs/result.xml"
    do
        printf '\n------------------------------------------------------------\n'
        printf 'DIAGNOSTIC_FILE=%s\n' "$diagnostic_file"
        printf '%s\n' '------------------------------------------------------------'

        if [[ -f "$diagnostic_file" ]]; then
            printf 'SIZE=%s\n' \
                "$(stat -c '%s' "$diagnostic_file" 2>/dev/null ||
                   printf unknown)"

            printf 'SHA256=%s\n' \
                "$(sha256sum "$diagnostic_file" | awk '{print $1}')"

            if [[ "$diagnostic_file" == *.xml ]]; then
                printf '%s\n' '--- relevant XML lines ---'

                grep -Ein \
                    'unwind|failure|failed|error|property|reason|exception|solver' \
                    "$diagnostic_file" 2>/dev/null |
                    sed -n '1,260p' ||
                    true

                printf '%s\n' '--- XML tail ---'
                tail -n 100 "$diagnostic_file" 2>/dev/null || true
            else
                cat "$diagnostic_file" 2>/dev/null || true
            fi
        else
            printf 'NOT_FOUND\n'
        fi
    done

    section "00C.3 — GOTO LOOP-ID DISCOVERY"

    goto-instrument \
        --show-loop-ids \
        "$GOTO_FILE" \
        > "$LOOP_REPORT" 2>&1

    LOOP_DISCOVERY_EXIT=$?

    printf 'LOOP_DISCOVERY_EXIT=%s\n' "$LOOP_DISCOVERY_EXIT"
    printf 'LOOP_REPORT=%s\n' "$LOOP_REPORT"

    cat "$LOOP_REPORT"

    if [[ "$LOOP_DISCOVERY_EXIT" -ne 0 ]]; then
        mark_fail "goto-instrument could not display loop IDs"
        return 30
    fi

    mapfile -t LOOP_IDS < <(
        sed -n \
            's/^[[:space:]]*Loop[[:space:]]\+\([^:[:space:]]\+\):.*/\1/p' \
            "$LOOP_REPORT"
    )

    if [[ "${#LOOP_IDS[@]}" -eq 0 ]]; then
        mapfile -t LOOP_IDS < <(
            grep -Eo \
                '[A-Za-z_][A-Za-z0-9_:$.]*\.[0-9]+' \
                "$LOOP_REPORT" |
            sort -u
        )
    fi

    printf 'DISCOVERED_LOOP_COUNT=%s\n' "${#LOOP_IDS[@]}"

    if [[ "${#LOOP_IDS[@]}" -eq 0 ]]; then
        mark_fail "no loop IDs could be extracted"
        return 31
    fi

    UNWINDSET=""

    for loop_id in "${LOOP_IDS[@]}"
    do
        bound=""

        case "$loop_id" in
            *harness*)
                # Covers both harness loops: 256 assumptions and 128 checks.
                bound="257"
                ;;

            *poly_compress_d4_c*)
                # Covers both implementation loops: outer 32 and inner 8.
                bound="33"
                ;;

            *)
                # Fail closed rather than silently guessing a bound.
                printf 'UNEXPECTED_LOOP_ID=%s\n' "$loop_id"
                mark_fail "unexpected loop ID requires inspection"
                ;;
        esac

        if [[ -n "$bound" ]]; then
            if [[ -n "$UNWINDSET" ]]; then
                UNWINDSET="${UNWINDSET},"
            fi

            UNWINDSET="${UNWINDSET}${loop_id}:${bound}"

            printf 'LOOP_BOUND %s=%s\n' "$loop_id" "$bound"
        fi
    done

    printf 'CONSTRUCTED_UNWINDSET=%s\n' "$UNWINDSET"

    if [[ "$FAIL" -ne 0 ]]; then
        return 32
    fi

    section "00C.4 — PROPERTY INVENTORY"

    cbmc \
        "$GOTO_FILE" \
        --show-properties \
        > "$PROPERTY_REPORT" 2>&1

    PROPERTY_REPORT_EXIT=$?

    printf 'PROPERTY_REPORT_EXIT=%s\n' "$PROPERTY_REPORT_EXIT"
    printf 'PROPERTY_REPORT=%s\n' "$PROPERTY_REPORT"

    grep -n -B 4 -A 8 \
        'POLYCOMP-D4-T1' \
        "$PROPERTY_REPORT" 2>/dev/null ||
        true

    SEMANTIC_PROPERTY_COUNT="$(
        grep -c \
            'POLYCOMP-D4-T1' \
            "$PROPERTY_REPORT" 2>/dev/null ||
        true
    )"

    printf 'SEMANTIC_PROPERTY_COUNT=%s\n' "$SEMANTIC_PROPERTY_COUNT"

    if [[ "$SEMANTIC_PROPERTY_COUNT" -lt 1 ]]; then
        mark_fail "T1 semantic assertion is absent from the GOTO binary"
        return 40
    fi

    printf 'SEMANTIC_PROPERTY_BINDING=PASS\n'

    section "00C.5 — DIRECT CBMC POSITIVE SEMANTIC RUN"

    printf 'DIRECT_COMMAND_BEGIN\n'
    printf 'cbmc %q \\\n' "$GOTO_FILE"
    printf '  --object-bits 8 \\\n'
    printf '  --slice-formula \\\n'
    printf '  --unwind 1 \\\n'
    printf '  --unwindset %q \\\n' "$UNWINDSET"
    printf '  --unwinding-assertions \\\n'
    printf '  --conversion-check \\\n'
    printf '  --float-overflow-check \\\n'
    printf '  --nan-check \\\n'
    printf '  --pointer-overflow-check \\\n'
    printf '  --unsigned-overflow-check \\\n'
    printf '  --trace --json-ui\n'
    printf 'DIRECT_COMMAND_END\n'

    cbmc \
        "$GOTO_FILE" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --conversion-check \
        --float-overflow-check \
        --nan-check \
        --pointer-overflow-check \
        --unsigned-overflow-check \
        --trace \
        --json-ui \
        > "$DIRECT_RESULT_JSON" \
        2> "$DIRECT_STDERR"

    DIRECT_CBMC_EXIT=$?

    printf 'DIRECT_CBMC_EXIT=%s\n' "$DIRECT_CBMC_EXIT"
    printf 'DIRECT_RESULT_JSON=%s\n' "$DIRECT_RESULT_JSON"
    printf 'DIRECT_STDERR=%s\n' "$DIRECT_STDERR"

    printf 'DIRECT_RESULT_JSON_SIZE=%s\n' \
        "$(stat -c '%s' "$DIRECT_RESULT_JSON" 2>/dev/null ||
           printf unknown)"

    printf 'DIRECT_RESULT_JSON_SHA256=%s\n' \
        "$(sha256sum "$DIRECT_RESULT_JSON" | awk '{print $1}')"

    printf 'DIRECT_STDERR_SHA256=%s\n' \
        "$(sha256sum "$DIRECT_STDERR" | awk '{print $1}')"

    printf '\n--- direct CBMC stderr ---\n'
    cat "$DIRECT_STDERR" 2>/dev/null || true

    section "00C.6 — DIRECT RESULT CLASSIFICATION"

    python3 - \
        "$DIRECT_RESULT_JSON" \
        "$DIRECT_SUMMARY" <<'PY'
import json
import sys
from collections import Counter
from pathlib import Path

result_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])

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

for entry in entries:
    if not isinstance(entry, dict):
        continue

    result = entry.get("result")

    if isinstance(result, list):
        for property_result in result:
            if isinstance(property_result, dict):
                properties.append(property_result)

statuses = Counter(
    str(item.get("status", "UNKNOWN"))
    for item in properties
)

semantic_properties = [
    item
    for item in properties
    if "POLYCOMP-D4-T1"
    in (
        str(item.get("description", ""))
        + " "
        + str(item.get("property", ""))
    )
]

unwinding_properties = [
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
]

for status, count in sorted(statuses.items()):
    lines.append(f"STATUS_{status}={count}")

lines.append(
    f"T1_SEMANTIC_RESULT_COUNT={len(semantic_properties)}"
)

for index, item in enumerate(semantic_properties):
    lines.append(
        "T1_SEMANTIC_RESULT_"
        f"{index}="
        f"{item.get('status', 'UNKNOWN')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

lines.append(
    f"UNWINDING_RESULT_COUNT={len(unwinding_properties)}"
)

for index, item in enumerate(unwinding_properties):
    lines.append(
        "UNWINDING_RESULT_"
        f"{index}="
        f"{item.get('status', 'UNKNOWN')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")
PY

    SUMMARY_EXIT=$?

    printf 'DIRECT_SUMMARY_EXIT=%s\n' "$SUMMARY_EXIT"
    printf 'DIRECT_SUMMARY=%s\n' "$DIRECT_SUMMARY"

    if [[ "$SUMMARY_EXIT" -ne 0 ]]; then
        mark_fail "direct-result JSON could not be classified"
    fi

    printf '\n--- direct result tail ---\n'
    tail -n 160 "$DIRECT_RESULT_JSON" 2>/dev/null || true

    if [[ "$DIRECT_CBMC_EXIT" -ne 0 ]]; then
        mark_fail "direct CBMC positive run did not verify successfully"
    fi

    section "00C.7 — POST-RUN IMMUTABILITY"

    authoritative_status="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            status --porcelain=v1 --untracked-files=all \
            2>/dev/null ||
        true
    )"

    if [[ -n "$authoritative_status" ]]; then
        printf '%s\n' "$authoritative_status"
        mark_fail "authoritative source became dirty"
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

    section "POLYCOMP-D4-00C VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_00C_STATUS=PASS\n'
        printf 'T1_DIRECT_POSITIVE_PREFLIGHT=PASS\n'
        printf 'RUNNER_FAILURE_CLASSIFICATION=STARTER_KIT_UNWIND_CONFIGURATION\n'
        printf 'NEXT_GATE=T1_RUNNER_REPAIR_AND_NONVACUITY\n'
    else
        printf 'POLYCOMP_D4_00C_STATUS=FAIL\n'
        printf 'T1_DIRECT_POSITIVE_PREFLIGHT=NOT_ACCEPTED\n'
        printf 'NEXT_GATE=CLASSIFY_REPORTED_PROPERTY_OR_LOOP_FAILURE\n'
    fi

    printf 'LOOP_REPORT=%s\n' "$LOOP_REPORT"
    printf 'PROPERTY_REPORT=%s\n' "$PROPERTY_REPORT"
    printf 'DIRECT_RESULT_JSON=%s\n' "$DIRECT_RESULT_JSON"
    printf 'DIRECT_STDERR=%s\n' "$DIRECT_STDERR"
    printf 'DIRECT_SUMMARY=%s\n' "$DIRECT_SUMMARY"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-00C CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
