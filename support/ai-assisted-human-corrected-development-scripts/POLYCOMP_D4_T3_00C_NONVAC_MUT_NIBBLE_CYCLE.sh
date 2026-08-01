#!/usr/bin/env bash
set -uo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t3_20260726T020556Z"
CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"

POSITIVE_PROOF_NAME="polycomp_d4_t3_compressed_domain_retraction"
POSITIVE_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${POSITIVE_PROOF_NAME}"
POSITIVE_HARNESS_NAME="polycomp_d4_t3_compressed_domain_retraction_harness"
POSITIVE_HARNESS="${POSITIVE_PROOF_DIR}/${POSITIVE_HARNESS_NAME}.c"
POSITIVE_MAKEFILE="${POSITIVE_PROOF_DIR}/Makefile"
POSITIVE_GOTO="${POSITIVE_PROOF_DIR}/gotos/${POSITIVE_HARNESS_NAME}.goto"

EXPECTED_POSITIVE_HARNESS_SHA256="caf64341e43db7abf668241e4012d4ab1064536fd3237d0577826e4728c7ea8f"
EXPECTED_POSITIVE_MAKEFILE_SHA256="02ef8132f84ade6447e7139d1ea1840443e349eb88a6fef74983a54f6ef21654"
EXPECTED_POSITIVE_GOTO_SHA256="6d35b9b1dac6fabf8f7fd207e9f9b116912e0351f30a543066dfd48d98bcc9c8"

UNWINDSET="harness.0:129,mlk_poly_compress_d4_c.0:129,mlk_poly_compress_d4_c.1:257,mlk_poly_decompress_d4_c.0:129"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_T3_00C_NONVAC_MUT_NIBBLE_CYCLE"

COVERAGE_JSON="${STAGE_DIR}/T3_LOCATION_COVERAGE_${UTC_STAMP}.json"
COVERAGE_STDERR="${STAGE_DIR}/T3_LOCATION_COVERAGE_STDERR_${UTC_STAMP}.txt"
COVERAGE_SUMMARY="${STAGE_DIR}/T3_LOCATION_COVERAGE_SUMMARY_${UTC_STAMP}.txt"

POSITIVE_REACH_GOTO="${STAGE_DIR}/T3_POSITIVE_END_REACHABILITY_${UTC_STAMP}.goto"
POSITIVE_REACH_JSON="${STAGE_DIR}/T3_POSITIVE_END_REACHABILITY_${UTC_STAMP}.json"
POSITIVE_REACH_STDERR="${STAGE_DIR}/T3_POSITIVE_END_REACHABILITY_STDERR_${UTC_STAMP}.txt"
POSITIVE_REACH_SUMMARY="${STAGE_DIR}/T3_POSITIVE_END_REACHABILITY_SUMMARY_${UTC_STAMP}.txt"

NIBBLE_PROOF_NAME="polycomp_d4_t3_nibble_preservation_${UTC_STAMP}"
NIBBLE_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${NIBBLE_PROOF_NAME}"
NIBBLE_HARNESS_NAME="polycomp_d4_t3_nibble_preservation_harness"
NIBBLE_HARNESS="${NIBBLE_PROOF_DIR}/${NIBBLE_HARNESS_NAME}.c"
NIBBLE_GOTO="${NIBBLE_PROOF_DIR}/gotos/${NIBBLE_HARNESS_NAME}.goto"
NIBBLE_RUNNER_LOG="${STAGE_DIR}/T3_NIBBLE_RUNNER_${UTC_STAMP}.txt"
NIBBLE_RUNNER_JSON="${STAGE_DIR}/T3_NIBBLE_RUNNER_${UTC_STAMP}.json"
NIBBLE_LOOP_REPORT="${STAGE_DIR}/T3_NIBBLE_LOOP_REPORT_${UTC_STAMP}.txt"
NIBBLE_PROPERTY_REPORT="${STAGE_DIR}/T3_NIBBLE_PROPERTY_REPORT_${UTC_STAMP}.txt"
NIBBLE_SEMANTIC_JSON="${STAGE_DIR}/T3_NIBBLE_SEMANTIC_${UTC_STAMP}.json"
NIBBLE_SEMANTIC_STDERR="${STAGE_DIR}/T3_NIBBLE_SEMANTIC_STDERR_${UTC_STAMP}.txt"
NIBBLE_SEMANTIC_SUMMARY="${STAGE_DIR}/T3_NIBBLE_SEMANTIC_SUMMARY_${UTC_STAMP}.txt"
NIBBLE_STRICT_JSON="${STAGE_DIR}/T3_NIBBLE_STRICT_${UTC_STAMP}.json"
NIBBLE_STRICT_STDERR="${STAGE_DIR}/T3_NIBBLE_STRICT_STDERR_${UTC_STAMP}.txt"
NIBBLE_STRICT_SUMMARY="${STAGE_DIR}/T3_NIBBLE_STRICT_SUMMARY_${UTC_STAMP}.txt"

CYCLE_PROOF_NAME="polycomp_d4_t3_cycle_stability_${UTC_STAMP}"
CYCLE_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${CYCLE_PROOF_NAME}"
CYCLE_HARNESS_NAME="polycomp_d4_t3_cycle_stability_harness"
CYCLE_HARNESS="${CYCLE_PROOF_DIR}/${CYCLE_HARNESS_NAME}.c"
CYCLE_GOTO="${CYCLE_PROOF_DIR}/gotos/${CYCLE_HARNESS_NAME}.goto"
CYCLE_RUNNER_LOG="${STAGE_DIR}/T3_CYCLE_RUNNER_${UTC_STAMP}.txt"
CYCLE_RUNNER_JSON="${STAGE_DIR}/T3_CYCLE_RUNNER_${UTC_STAMP}.json"
CYCLE_LOOP_REPORT="${STAGE_DIR}/T3_CYCLE_LOOP_REPORT_${UTC_STAMP}.txt"
CYCLE_PROPERTY_REPORT="${STAGE_DIR}/T3_CYCLE_PROPERTY_REPORT_${UTC_STAMP}.txt"
CYCLE_SEMANTIC_JSON="${STAGE_DIR}/T3_CYCLE_SEMANTIC_${UTC_STAMP}.json"
CYCLE_SEMANTIC_STDERR="${STAGE_DIR}/T3_CYCLE_SEMANTIC_STDERR_${UTC_STAMP}.txt"
CYCLE_SEMANTIC_SUMMARY="${STAGE_DIR}/T3_CYCLE_SEMANTIC_SUMMARY_${UTC_STAMP}.txt"
CYCLE_STRICT_JSON="${STAGE_DIR}/T3_CYCLE_STRICT_${UTC_STAMP}.json"
CYCLE_STRICT_STDERR="${STAGE_DIR}/T3_CYCLE_STRICT_STDERR_${UTC_STAMP}.txt"
CYCLE_STRICT_SUMMARY="${STAGE_DIR}/T3_CYCLE_STRICT_SUMMARY_${UTC_STAMP}.txt"

DECOMP_MUT_PROOF_NAME="polycomp_d4_t3_mutation_decompress_side_${UTC_STAMP}"
DECOMP_MUT_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${DECOMP_MUT_PROOF_NAME}"
DECOMP_MUT_HARNESS_NAME="polycomp_d4_t3_mutation_decompress_side_harness"
DECOMP_MUT_HARNESS="${DECOMP_MUT_PROOF_DIR}/${DECOMP_MUT_HARNESS_NAME}.c"
DECOMP_MUT_GOTO="${DECOMP_MUT_PROOF_DIR}/gotos/${DECOMP_MUT_HARNESS_NAME}.goto"
DECOMP_MUT_RUNNER_LOG="${STAGE_DIR}/T3_DECOMP_MUT_RUNNER_${UTC_STAMP}.txt"
DECOMP_MUT_RUNNER_JSON="${STAGE_DIR}/T3_DECOMP_MUT_RUNNER_${UTC_STAMP}.json"
DECOMP_MUT_LOOP_REPORT="${STAGE_DIR}/T3_DECOMP_MUT_LOOP_REPORT_${UTC_STAMP}.txt"
DECOMP_MUT_JSON="${STAGE_DIR}/T3_DECOMP_MUT_RESULT_${UTC_STAMP}.json"
DECOMP_MUT_STDERR="${STAGE_DIR}/T3_DECOMP_MUT_STDERR_${UTC_STAMP}.txt"
DECOMP_MUT_SUMMARY="${STAGE_DIR}/T3_DECOMP_MUT_SUMMARY_${UTC_STAMP}.txt"

COMP_MUT_PROOF_NAME="polycomp_d4_t3_mutation_compress_side_${UTC_STAMP}"
COMP_MUT_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${COMP_MUT_PROOF_NAME}"
COMP_MUT_HARNESS_NAME="polycomp_d4_t3_mutation_compress_side_harness"
COMP_MUT_HARNESS="${COMP_MUT_PROOF_DIR}/${COMP_MUT_HARNESS_NAME}.c"
COMP_MUT_GOTO="${COMP_MUT_PROOF_DIR}/gotos/${COMP_MUT_HARNESS_NAME}.goto"
COMP_MUT_RUNNER_LOG="${STAGE_DIR}/T3_COMP_MUT_RUNNER_${UTC_STAMP}.txt"
COMP_MUT_RUNNER_JSON="${STAGE_DIR}/T3_COMP_MUT_RUNNER_${UTC_STAMP}.json"
COMP_MUT_LOOP_REPORT="${STAGE_DIR}/T3_COMP_MUT_LOOP_REPORT_${UTC_STAMP}.txt"
COMP_MUT_JSON="${STAGE_DIR}/T3_COMP_MUT_RESULT_${UTC_STAMP}.json"
COMP_MUT_STDERR="${STAGE_DIR}/T3_COMP_MUT_STDERR_${UTC_STAMP}.txt"
COMP_MUT_SUMMARY="${STAGE_DIR}/T3_COMP_MUT_SUMMARY_${UTC_STAMP}.txt"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_T3_00C_NONVAC_MUT_NIBBLE_CYCLE_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

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

write_makefile()
{
    local proof_dir="$1"
    local proof_name="$2"
    local harness_name="$3"

    cat > "${proof_dir}/Makefile" <<MAKEFILE_EOF
include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = ${harness_name}
PROOF_UID = ${proof_name}

DEFINES +=
INCLUDES +=
REMOVE_FUNCTION_BODY +=

CHECK_FUNCTION_CONTRACTS =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

PROOF_SOURCES += \$(PROOFDIR)/\$(HARNESS_FILE).c
PROJECT_SOURCES += \$(SRCDIR)/mlkem/src/compress.c

UNWINDSET +=
CBMCFLAGS = --smt2
EXTERNAL_SAT_SOLVER =

FUNCTION_NAME = mlk_poly_compress_d4_c
CBMC_OBJECT_BITS = 8

include ../Makefile.common
MAKEFILE_EOF
}

build_goto()
{
    local proof_name="$1"
    local goto_file="$2"
    local runner_log="$3"
    local runner_json="$4"

    (
        cd "$WORK_REPO/proofs/cbmc" || exit 90

        MLKEM_K=3 \
        ./run-cbmc-proofs.py \
            --summarize \
            -j1 \
            -p "$proof_name" \
            --output-result-json "$runner_json"
    ) > "$runner_log" 2>&1

    local runner_exit=$?

    printf 'RUNNER_PROOF=%s\n' "$proof_name"
    printf 'RUNNER_EXIT=%s\n' "$runner_exit"
    printf 'RUNNER_LOG=%s\n' "$runner_log"
    printf 'RUNNER_JSON=%s\n' "$runner_json"
    printf 'RUNNER_NONZERO_ACCEPTABLE_WHEN_GOTO_EXISTS=YES\n'

    tail -n 90 "$runner_log" 2>/dev/null || true

    if [[ ! -f "$goto_file" ]]; then
        mark_fail "runner did not produce GOTO for $proof_name"
        return 1
    fi

    printf 'GOTO_FILE=%s\n' "$goto_file"
    printf 'GOTO_SIZE=%s\n' "$(stat -c '%s' "$goto_file")"
    printf 'GOTO_SHA256=%s\n' "$(
        sha256sum "$goto_file" |
        awk '{print $1}'
    )"

    return 0
}

check_four_loops()
{
    local goto_file="$1"
    local loop_report="$2"

    goto-instrument \
        --show-loops \
        "$goto_file" \
        > "$loop_report" 2>&1

    local exit_code=$?

    printf 'LOOP_DISCOVERY_EXIT=%s\n' "$exit_code"
    printf 'LOOP_REPORT=%s\n' "$loop_report"

    cat "$loop_report"

    if [[ "$exit_code" -ne 0 ]]; then
        mark_fail "loop discovery failed"
        return 1
    fi

    python3 - "$loop_report" <<'PY'
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(
    encoding="utf-8",
    errors="replace",
)

loop_ids = re.findall(
    r"^Loop ([^:]+):$",
    text,
    flags=re.MULTILINE,
)

expected = {
    "harness.0",
    "mlk_poly_compress_d4_c.0",
    "mlk_poly_compress_d4_c.1",
    "mlk_poly_decompress_d4_c.0",
}

print(f"TOTAL_LOOP_COUNT={len(loop_ids)}")
print(f"UNIQUE_LOOP_COUNT={len(set(loop_ids))}")
print(
    "FOUR_LOOP_INVENTORY="
    + ("PASS" if set(loop_ids) == expected and len(loop_ids) == 4 else "FAIL")
)

if set(loop_ids) != expected or len(loop_ids) != 4:
    raise SystemExit(1)
PY

    local parse_exit=$?

    printf 'LOOP_PARSE_EXIT=%s\n' "$parse_exit"

    if [[ "$parse_exit" -ne 0 ]]; then
        mark_fail "unexpected four-loop inventory"
        return 1
    fi

    return 0
}

parse_success_descriptions()
{
    local json_file="$1"
    local summary_file="$2"
    local require_all="$3"
    shift 3
    local descriptions=("$@")

    python3 - \
        "$json_file" \
        "$summary_file" \
        "$require_all" \
        "${descriptions[@]}" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
require_all = sys.argv[3] == "yes"
descriptions = sys.argv[4:]

payload = json.loads(
    json_path.read_text(encoding="utf-8")
)

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

description_results = {}

for description in descriptions:
    matches = [
        item
        for item in results
        if str(item.get("description", "")) == description
    ]

    description_results[description] = matches

target_success = all(
    len(matches) == 1
    and matches[0].get("status") == "SUCCESS"
    for matches in description_results.values()
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
]

for index, description in enumerate(descriptions):
    matches = description_results[description]
    lines.append(
        f"TARGET_{index}_COUNT={len(matches)}"
    )

    if matches:
        lines.append(
            f"TARGET_{index}_RESULT="
            f"{matches[0].get('status', '')}|"
            f"{matches[0].get('property', '')}|"
            f"{description}"
        )

lines.append(
    "TARGET_PROPERTIES="
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

parse_mutation()
{
    local json_file="$1"
    local summary_file="$2"
    local label="$3"

    python3 - \
        "$json_file" \
        "$summary_file" \
        "$label" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
label = sys.argv[3]

description = (
    "POLYCOMP-D4-T3: compressing the real D4 decompression "
    "reconstructs every original input byte"
)

payload = json.loads(
    json_path.read_text(encoding="utf-8")
)

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

targets = [
    item
    for item in results
    if str(item.get("description", "")) == description
]

target_failure = (
    len(targets) == 1
    and targets[0].get("status") == "FAILURE"
)

other_success = all(
    item.get("status") == "SUCCESS"
    for item in results
    if str(item.get("description", "")) != description
)

cprover_failure = any(
    status.lower() == "failure"
    for status in statuses
)

accepted = (
    target_failure
    and other_success
    and cprover_failure
    and not errors
)

lines = [
    "MUTATION_PARSE_STATUS=PASS",
    f"MUTATION_LABEL={label}",
    f"PROPERTY_RESULT_COUNT={len(results)}",
    "CPROVER_STATUSES="
    + (",".join(statuses) if statuses else "<MISSING>"),
    f"ERROR_MESSAGE_COUNT={len(errors)}",
    f"TARGET_RESULT_COUNT={len(targets)}",
    "TARGET_STATUS="
    + (
        str(targets[0].get("status"))
        if targets
        else "MISSING"
    ),
    "NON_TARGET_PROPERTIES="
    + ("PASS" if other_success else "FAIL"),
    f"{label}_DETECTED="
    + ("PASS" if accepted else "FAIL"),
]

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
    section "POLYCOMP-D4-T3-00C — NON-VACUITY, MUTATIONS, NIBBLE PRESERVATION AND CYCLE STABILITY"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "T3-00C.1 — POSITIVE ARTEFACT REBINDING"

    for required in \
        "$POSITIVE_HARNESS" \
        "$POSITIVE_MAKEFILE" \
        "$POSITIVE_GOTO"
    do
        if [[ ! -f "$required" ]]; then
            mark_fail "required positive artefact missing: $required"
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

    POSITIVE_HARNESS_HASH="$(
        sha256sum "$POSITIVE_HARNESS" |
        awk '{print $1}'
    )"

    POSITIVE_MAKEFILE_HASH="$(
        sha256sum "$POSITIVE_MAKEFILE" |
        awk '{print $1}'
    )"

    POSITIVE_GOTO_HASH="$(
        sha256sum "$POSITIVE_GOTO" |
        awk '{print $1}'
    )"

    printf 'POSITIVE_HARNESS_SHA256=%s\n' "$POSITIVE_HARNESS_HASH"
    printf 'POSITIVE_MAKEFILE_SHA256=%s\n' "$POSITIVE_MAKEFILE_HASH"
    printf 'POSITIVE_GOTO_SHA256=%s\n' "$POSITIVE_GOTO_HASH"

    if [[ "$POSITIVE_HARNESS_HASH" != "$EXPECTED_POSITIVE_HARNESS_SHA256" ||
          "$POSITIVE_MAKEFILE_HASH" != "$EXPECTED_POSITIVE_MAKEFILE_SHA256" ||
          "$POSITIVE_GOTO_HASH" != "$EXPECTED_POSITIVE_GOTO_SHA256" ]]
    then
        mark_fail "positive T3 artefact hash mismatch"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 21
    fi

    printf 'T3_POSITIVE_ARTEFACT_REBINDING=PASS\n'

    section "T3-00C.2 — COMPLETE LOCATION COVERAGE"

    cbmc \
        "$POSITIVE_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --no-unwinding-assertions \
        --no-standard-checks \
        --cover location \
        --json-ui \
        > "$COVERAGE_JSON" \
        2> "$COVERAGE_STDERR"

    COVERAGE_EXIT=$?

    printf 'COVERAGE_CBMC_EXIT=%s\n' "$COVERAGE_EXIT"
    printf 'COVERAGE_JSON=%s\n' "$COVERAGE_JSON"
    printf 'COVERAGE_JSON_SHA256=%s\n' "$(
        sha256sum "$COVERAGE_JSON" |
        awk '{print $1}'
    )"

    cat "$COVERAGE_STDERR" 2>/dev/null || true

    python3 - \
        "$COVERAGE_JSON" \
        "$COVERAGE_SUMMARY" \
        "$(basename "$POSITIVE_HARNESS")" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
harness_name = sys.argv[3]

payload = json.loads(
    json_path.read_text(encoding="utf-8")
)

entries = payload if isinstance(payload, list) else [payload]

goals = []
reported_covered = None
reported_total = None

for entry in entries:
    if not isinstance(entry, dict):
        continue

    if isinstance(entry.get("goals"), list):
        goals.extend(
            goal
            for goal in entry["goals"]
            if isinstance(goal, dict)
        )

    if isinstance(entry.get("goalsCovered"), int):
        reported_covered = entry["goalsCovered"]

    if isinstance(entry.get("totalGoals"), int):
        reported_total = entry["totalGoals"]

satisfied = [
    goal
    for goal in goals
    if str(goal.get("status", "")).lower() == "satisfied"
]

unsatisfied = [
    goal
    for goal in goals
    if str(goal.get("status", "")).lower() != "satisfied"
]

harness_goals = [
    goal
    for goal in goals
    if harness_name in json.dumps(goal, sort_keys=True)
]

accepted = (
    bool(goals)
    and len(satisfied) == len(goals)
    and not unsatisfied
    and bool(harness_goals)
    and (
        reported_covered is None
        or reported_covered == len(goals)
    )
    and (
        reported_total is None
        or reported_total == len(goals)
    )
)

lines = [
    "COVERAGE_PARSE_STATUS=PASS",
    f"COVERAGE_GOAL_COUNT={len(goals)}",
    f"SATISFIED_GOAL_COUNT={len(satisfied)}",
    f"UNSATISFIED_GOAL_COUNT={len(unsatisfied)}",
    f"REPORTED_GOALS_COVERED={reported_covered}",
    f"REPORTED_TOTAL_GOALS={reported_total}",
    f"HARNESS_GOAL_COUNT={len(harness_goals)}",
    "COMPLETE_LOCATION_COVERAGE="
    + ("PASS" if accepted else "FAIL"),
]

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")

if not accepted:
    raise SystemExit(1)
PY

    COVERAGE_PARSE_EXIT=$?

    printf 'COVERAGE_PARSE_EXIT=%s\n' "$COVERAGE_PARSE_EXIT"
    printf 'COVERAGE_SUMMARY=%s\n' "$COVERAGE_SUMMARY"

    if [[ "$COVERAGE_EXIT" -ne 0 ||
          "$COVERAGE_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "T3 complete location coverage failed"
        return 30
    fi

    printf 'T3_COMPLETE_LOCATION_COVERAGE=PASS\n'

    section "T3-00C.3 — POSITIVE END-OF-HARNESS REACHABILITY"

    goto-instrument \
        --insert-final-assert-false harness \
        "$POSITIVE_GOTO" \
        "$POSITIVE_REACH_GOTO" \
        > "${STAGE_DIR}/T3_POSITIVE_REACH_INSTRUMENT_STDOUT_${UTC_STAMP}.txt" \
        2> "${STAGE_DIR}/T3_POSITIVE_REACH_INSTRUMENT_STDERR_${UTC_STAMP}.txt"

    if [[ "$?" -ne 0 || ! -f "$POSITIVE_REACH_GOTO" ]]; then
        mark_fail "could not create positive reachability GOTO"
        return 40
    fi

    cbmc \
        "$POSITIVE_REACH_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$POSITIVE_REACH_JSON" \
        2> "$POSITIVE_REACH_STDERR"

    POSITIVE_REACH_EXIT=$?

    printf 'POSITIVE_REACHABILITY_CBMC_EXIT=%s\n' \
        "$POSITIVE_REACH_EXIT"

    python3 - \
        "$POSITIVE_REACH_JSON" \
        "$POSITIVE_REACH_SUMMARY" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(
    Path(sys.argv[1]).read_text(encoding="utf-8")
)

entries = payload if isinstance(payload, list) else [payload]
results = []

for entry in entries:
    if (
        isinstance(entry, dict)
        and isinstance(entry.get("result"), list)
    ):
        results.extend(
            item
            for item in entry["result"]
            if isinstance(item, dict)
        )

main_description = (
    "POLYCOMP-D4-T3: compressing the real D4 decompression "
    "reconstructs every original input byte"
)

main_matches = [
    item
    for item in results
    if str(item.get("description", "")) == main_description
]

inserted_failures = [
    item
    for item in results
    if item.get("status") == "FAILURE"
    and str(item.get("description", "")) != main_description
]

accepted = (
    len(main_matches) == 1
    and main_matches[0].get("status") == "SUCCESS"
    and bool(inserted_failures)
)

lines = [
    "POSITIVE_REACHABILITY_PARSE_STATUS=PASS",
    f"MAIN_ASSERTION_COUNT={len(main_matches)}",
    "MAIN_ASSERTION_STATUS="
    + (
        str(main_matches[0].get("status"))
        if main_matches
        else "MISSING"
    ),
    f"INSERTED_FINAL_FAILURE_COUNT={len(inserted_failures)}",
    "POSITIVE_END_REACHABILITY="
    + ("PASS" if accepted else "FAIL"),
]

Path(sys.argv[2]).write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(Path(sys.argv[2]).read_text(encoding="utf-8"), end="")

if not accepted:
    raise SystemExit(1)
PY

    POSITIVE_REACH_PARSE_EXIT=$?

    printf 'POSITIVE_REACHABILITY_PARSE_EXIT=%s\n' \
        "$POSITIVE_REACH_PARSE_EXIT"

    if [[ "$POSITIVE_REACH_EXIT" -eq 0 ||
          "$POSITIVE_REACH_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "positive end reachability failed"
        return 41
    fi

    printf 'T3_POSITIVE_END_REACHABILITY=PASS\n'

    section "T3-00C.4 — NIBBLE-PRESERVATION HARNESS"

    mkdir -p "$NIBBLE_PROOF_DIR"

    cat > "$NIBBLE_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T3 nibble preservation.
 *
 * For every possible 128-byte input, real decompression followed by real
 * compression preserves the low and high nibble of every byte.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

void harness(void)
{
#if MLKEM_K != 4
  uint8_t input[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly intermediate;
  uint8_t reconstructed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  unsigned i;

  mlk_poly_decompress_d4_c(
      &intermediate,
      input);

  mlk_poly_compress_d4_c(
      reconstructed,
      &intermediate);

  for (i = 0;
       i < MLKEM_POLYCOMPRESSEDBYTES_D4;
       i++)
  {
    __CPROVER_assert(
        (reconstructed[i] & (uint8_t)0x0Fu) ==
            (input[i] & (uint8_t)0x0Fu),
        "POLYCOMP-D4-T3 nibble preservation: every low nibble is preserved");

    __CPROVER_assert(
        (reconstructed[i] >> 4) ==
            (input[i] >> 4),
        "POLYCOMP-D4-T3 nibble preservation: every high nibble is preserved");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$NIBBLE_PROOF_DIR" \
        "$NIBBLE_PROOF_NAME" \
        "$NIBBLE_HARNESS_NAME"

    printf 'NIBBLE_HARNESS=%s\n' "$NIBBLE_HARNESS"
    printf 'NIBBLE_HARNESS_SHA256=%s\n' "$(
        sha256sum "$NIBBLE_HARNESS" |
        awk '{print $1}'
    )"

    NIBBLE_CALL_D="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_decompress_d4_c[[:space:]]*\(' \
            "$NIBBLE_HARNESS" ||
        true
    )"

    NIBBLE_CALL_C="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_compress_d4_c[[:space:]]*\(' \
            "$NIBBLE_HARNESS" ||
        true
    )"

    NIBBLE_ASSERTS="$(
        grep -Ec \
            '^[[:space:]]*__CPROVER_assert[[:space:]]*\(' \
            "$NIBBLE_HARNESS" ||
        true
    )"

    NIBBLE_ASSUMES="$(
        grep -c '__CPROVER_assume' "$NIBBLE_HARNESS" ||
        true
    )"

    printf 'NIBBLE_DECOMPRESS_CALL_COUNT=%s\n' "$NIBBLE_CALL_D"
    printf 'NIBBLE_COMPRESS_CALL_COUNT=%s\n' "$NIBBLE_CALL_C"
    printf 'NIBBLE_ASSERT_SITE_COUNT=%s\n' "$NIBBLE_ASSERTS"
    printf 'NIBBLE_ASSUME_COUNT=%s\n' "$NIBBLE_ASSUMES"

    if [[ "$NIBBLE_CALL_D" != "1" ||
          "$NIBBLE_CALL_C" != "1" ||
          "$NIBBLE_ASSERTS" != "2" ||
          "$NIBBLE_ASSUMES" != "0" ]]
    then
        mark_fail "nibble-preservation static firewall failed"
        return 50
    fi

    printf 'T3_NIBBLE_STATIC_FIREWALL=PASS\n'

    build_goto \
        "$NIBBLE_PROOF_NAME" \
        "$NIBBLE_GOTO" \
        "$NIBBLE_RUNNER_LOG" \
        "$NIBBLE_RUNNER_JSON" ||
        return 51

    check_four_loops \
        "$NIBBLE_GOTO" \
        "$NIBBLE_LOOP_REPORT" ||
        return 52

    cbmc \
        "$NIBBLE_GOTO" \
        --show-properties \
        > "$NIBBLE_PROPERTY_REPORT" 2>&1

    NIBBLE_LOW_COUNT="$(
        grep -c \
            'POLYCOMP-D4-T3 nibble preservation: every low nibble is preserved' \
            "$NIBBLE_PROPERTY_REPORT" ||
        true
    )"

    NIBBLE_HIGH_COUNT="$(
        grep -c \
            'POLYCOMP-D4-T3 nibble preservation: every high nibble is preserved' \
            "$NIBBLE_PROPERTY_REPORT" ||
        true
    )"

    printf 'NIBBLE_LOW_PROPERTY_COUNT=%s\n' "$NIBBLE_LOW_COUNT"
    printf 'NIBBLE_HIGH_PROPERTY_COUNT=%s\n' "$NIBBLE_HIGH_COUNT"

    if [[ "$NIBBLE_LOW_COUNT" != "1" ||
          "$NIBBLE_HIGH_COUNT" != "1" ]]
    then
        mark_fail "nibble properties were not bound exactly once"
        return 53
    fi

    printf 'T3_NIBBLE_PROPERTY_BINDING=PASS\n'

    cbmc \
        "$NIBBLE_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$NIBBLE_SEMANTIC_JSON" \
        2> "$NIBBLE_SEMANTIC_STDERR"

    NIBBLE_SEMANTIC_EXIT=$?

    printf 'NIBBLE_SEMANTIC_CBMC_EXIT=%s\n' \
        "$NIBBLE_SEMANTIC_EXIT"

    parse_success_descriptions \
        "$NIBBLE_SEMANTIC_JSON" \
        "$NIBBLE_SEMANTIC_SUMMARY" \
        "no" \
        "POLYCOMP-D4-T3 nibble preservation: every low nibble is preserved" \
        "POLYCOMP-D4-T3 nibble preservation: every high nibble is preserved"

    NIBBLE_SEMANTIC_PARSE_EXIT=$?

    printf 'NIBBLE_SEMANTIC_PARSE_EXIT=%s\n' \
        "$NIBBLE_SEMANTIC_PARSE_EXIT"

    if [[ "$NIBBLE_SEMANTIC_EXIT" -ne 0 ||
          "$NIBBLE_SEMANTIC_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "nibble semantic proof failed"
        return 54
    fi

    printf 'T3_NIBBLE_PRESERVATION_SEMANTIC=PASS\n'

    cbmc \
        "$NIBBLE_GOTO" \
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
        > "$NIBBLE_STRICT_JSON" \
        2> "$NIBBLE_STRICT_STDERR"

    NIBBLE_STRICT_EXIT=$?

    printf 'NIBBLE_STRICT_CBMC_EXIT=%s\n' "$NIBBLE_STRICT_EXIT"

    parse_success_descriptions \
        "$NIBBLE_STRICT_JSON" \
        "$NIBBLE_STRICT_SUMMARY" \
        "yes" \
        "POLYCOMP-D4-T3 nibble preservation: every low nibble is preserved" \
        "POLYCOMP-D4-T3 nibble preservation: every high nibble is preserved"

    NIBBLE_STRICT_PARSE_EXIT=$?

    printf 'NIBBLE_STRICT_PARSE_EXIT=%s\n' \
        "$NIBBLE_STRICT_PARSE_EXIT"

    if [[ "$NIBBLE_STRICT_EXIT" -ne 0 ||
          "$NIBBLE_STRICT_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "nibble strict proof failed"
        return 55
    fi

    printf 'T3_NIBBLE_PRESERVATION_STRICT=PASS\n'

    section "T3-00C.5 — CYCLE-STABILITY HARNESS"

    mkdir -p "$CYCLE_PROOF_DIR"

    cat > "$CYCLE_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T3 cycle stability.
 *
 * Applying the real decompress/compress cycle twice is stable:
 *
 *   C(D(C(D(input)))) == C(D(input)).
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

void harness(void)
{
#if MLKEM_K != 4
  uint8_t input[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly first_poly;
  uint8_t first_cycle[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly second_poly;
  uint8_t second_cycle[MLKEM_POLYCOMPRESSEDBYTES_D4];
  unsigned i;

  mlk_poly_decompress_d4_c(
      &first_poly,
      input);

  mlk_poly_compress_d4_c(
      first_cycle,
      &first_poly);

  mlk_poly_decompress_d4_c(
      &second_poly,
      first_cycle);

  mlk_poly_compress_d4_c(
      second_cycle,
      &second_poly);

  for (i = 0;
       i < MLKEM_POLYCOMPRESSEDBYTES_D4;
       i++)
  {
    __CPROVER_assert(
        second_cycle[i] == first_cycle[i],
        "POLYCOMP-D4-T3 cycle stability: a second real decompression-compression cycle is byte-stable");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$CYCLE_PROOF_DIR" \
        "$CYCLE_PROOF_NAME" \
        "$CYCLE_HARNESS_NAME"

    printf 'CYCLE_HARNESS=%s\n' "$CYCLE_HARNESS"
    printf 'CYCLE_HARNESS_SHA256=%s\n' "$(
        sha256sum "$CYCLE_HARNESS" |
        awk '{print $1}'
    )"

    CYCLE_CALL_D="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_decompress_d4_c[[:space:]]*\(' \
            "$CYCLE_HARNESS" ||
        true
    )"

    CYCLE_CALL_C="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_compress_d4_c[[:space:]]*\(' \
            "$CYCLE_HARNESS" ||
        true
    )"

    CYCLE_ASSERTS="$(
        grep -Ec \
            '^[[:space:]]*__CPROVER_assert[[:space:]]*\(' \
            "$CYCLE_HARNESS" ||
        true
    )"

    CYCLE_ASSUMES="$(
        grep -c '__CPROVER_assume' "$CYCLE_HARNESS" ||
        true
    )"

    printf 'CYCLE_DECOMPRESS_CALL_COUNT=%s\n' "$CYCLE_CALL_D"
    printf 'CYCLE_COMPRESS_CALL_COUNT=%s\n' "$CYCLE_CALL_C"
    printf 'CYCLE_ASSERT_SITE_COUNT=%s\n' "$CYCLE_ASSERTS"
    printf 'CYCLE_ASSUME_COUNT=%s\n' "$CYCLE_ASSUMES"

    if [[ "$CYCLE_CALL_D" != "2" ||
          "$CYCLE_CALL_C" != "2" ||
          "$CYCLE_ASSERTS" != "1" ||
          "$CYCLE_ASSUMES" != "0" ]]
    then
        mark_fail "cycle-stability static firewall failed"
        return 60
    fi

    printf 'T3_CYCLE_STATIC_FIREWALL=PASS\n'

    build_goto \
        "$CYCLE_PROOF_NAME" \
        "$CYCLE_GOTO" \
        "$CYCLE_RUNNER_LOG" \
        "$CYCLE_RUNNER_JSON" ||
        return 61

    check_four_loops \
        "$CYCLE_GOTO" \
        "$CYCLE_LOOP_REPORT" ||
        return 62

    cbmc \
        "$CYCLE_GOTO" \
        --show-properties \
        > "$CYCLE_PROPERTY_REPORT" 2>&1

    CYCLE_PROPERTY_COUNT="$(
        grep -c \
            'POLYCOMP-D4-T3 cycle stability: a second real decompression-compression cycle is byte-stable' \
            "$CYCLE_PROPERTY_REPORT" ||
        true
    )"

    printf 'CYCLE_PROPERTY_COUNT=%s\n' "$CYCLE_PROPERTY_COUNT"

    if [[ "$CYCLE_PROPERTY_COUNT" != "1" ]]; then
        mark_fail "cycle property was not bound exactly once"
        return 63
    fi

    printf 'T3_CYCLE_PROPERTY_BINDING=PASS\n'

    cbmc \
        "$CYCLE_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$CYCLE_SEMANTIC_JSON" \
        2> "$CYCLE_SEMANTIC_STDERR"

    CYCLE_SEMANTIC_EXIT=$?

    printf 'CYCLE_SEMANTIC_CBMC_EXIT=%s\n' \
        "$CYCLE_SEMANTIC_EXIT"

    parse_success_descriptions \
        "$CYCLE_SEMANTIC_JSON" \
        "$CYCLE_SEMANTIC_SUMMARY" \
        "no" \
        "POLYCOMP-D4-T3 cycle stability: a second real decompression-compression cycle is byte-stable"

    CYCLE_SEMANTIC_PARSE_EXIT=$?

    printf 'CYCLE_SEMANTIC_PARSE_EXIT=%s\n' \
        "$CYCLE_SEMANTIC_PARSE_EXIT"

    if [[ "$CYCLE_SEMANTIC_EXIT" -ne 0 ||
          "$CYCLE_SEMANTIC_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "cycle semantic proof failed"
        return 64
    fi

    printf 'T3_CYCLE_STABILITY_SEMANTIC=PASS\n'

    cbmc \
        "$CYCLE_GOTO" \
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
        > "$CYCLE_STRICT_JSON" \
        2> "$CYCLE_STRICT_STDERR"

    CYCLE_STRICT_EXIT=$?

    printf 'CYCLE_STRICT_CBMC_EXIT=%s\n' "$CYCLE_STRICT_EXIT"

    parse_success_descriptions \
        "$CYCLE_STRICT_JSON" \
        "$CYCLE_STRICT_SUMMARY" \
        "yes" \
        "POLYCOMP-D4-T3 cycle stability: a second real decompression-compression cycle is byte-stable"

    CYCLE_STRICT_PARSE_EXIT=$?

    printf 'CYCLE_STRICT_PARSE_EXIT=%s\n' \
        "$CYCLE_STRICT_PARSE_EXIT"

    if [[ "$CYCLE_STRICT_EXIT" -ne 0 ||
          "$CYCLE_STRICT_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "cycle strict proof failed"
        return 65
    fi

    printf 'T3_CYCLE_STABILITY_STRICT=PASS\n'

    section "T3-00C.6 — DECOMPRESSION-SIDE FAULT INJECTION"

    mkdir -p "$DECOMP_MUT_PROOF_DIR"

    cat > "$DECOMP_MUT_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T3 decompression-side fault injection.
 *
 * The real decompressor is called, then the two coefficients decoded from
 * byte zero are swapped before the real compressor is called. The registered
 * byte-retraction assertion must detect this one-sided perturbation.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

void harness(void)
{
#if MLKEM_K != 4
  uint8_t input[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly intermediate;
  uint8_t reconstructed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  int16_t temporary;
  unsigned i;

  mlk_poly_decompress_d4_c(
      &intermediate,
      input);

  temporary = intermediate.coeffs[0];
  intermediate.coeffs[0] = intermediate.coeffs[1];
  intermediate.coeffs[1] = temporary;

  mlk_poly_compress_d4_c(
      reconstructed,
      &intermediate);

  for (i = 0;
       i < MLKEM_POLYCOMPRESSEDBYTES_D4;
       i++)
  {
    __CPROVER_assert(
        reconstructed[i] == input[i],
        "POLYCOMP-D4-T3: compressing the real D4 decompression reconstructs every original input byte");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$DECOMP_MUT_PROOF_DIR" \
        "$DECOMP_MUT_PROOF_NAME" \
        "$DECOMP_MUT_HARNESS_NAME"

    printf 'DECOMP_MUT_HARNESS=%s\n' "$DECOMP_MUT_HARNESS"
    printf 'DECOMP_MUT_HARNESS_SHA256=%s\n' "$(
        sha256sum "$DECOMP_MUT_HARNESS" |
        awk '{print $1}'
    )"

    build_goto \
        "$DECOMP_MUT_PROOF_NAME" \
        "$DECOMP_MUT_GOTO" \
        "$DECOMP_MUT_RUNNER_LOG" \
        "$DECOMP_MUT_RUNNER_JSON" ||
        return 70

    check_four_loops \
        "$DECOMP_MUT_GOTO" \
        "$DECOMP_MUT_LOOP_REPORT" ||
        return 71

    cbmc \
        "$DECOMP_MUT_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$DECOMP_MUT_JSON" \
        2> "$DECOMP_MUT_STDERR"

    DECOMP_MUT_EXIT=$?

    printf 'DECOMP_MUT_CBMC_EXIT=%s\n' "$DECOMP_MUT_EXIT"

    parse_mutation \
        "$DECOMP_MUT_JSON" \
        "$DECOMP_MUT_SUMMARY" \
        "DECOMPRESSION_SIDE_FAULT"

    DECOMP_MUT_PARSE_EXIT=$?

    printf 'DECOMP_MUT_PARSE_EXIT=%s\n' \
        "$DECOMP_MUT_PARSE_EXIT"

    if [[ "$DECOMP_MUT_EXIT" -eq 0 ||
          "$DECOMP_MUT_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "decompression-side fault was not detected"
        return 72
    fi

    printf 'T3_DECOMPRESSION_SIDE_MUTATION_DETECTION=PASS\n'

    section "T3-00C.7 — COMPRESSION-SIDE FAULT INJECTION"

    mkdir -p "$COMP_MUT_PROOF_DIR"

    cat > "$COMP_MUT_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T3 compression-side fault injection.
 *
 * Both real production functions are called, then the nibbles of output byte
 * zero are swapped. The registered byte-retraction assertion must detect this
 * one-sided perturbation.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

void harness(void)
{
#if MLKEM_K != 4
  uint8_t input[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly intermediate;
  uint8_t reconstructed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  uint8_t byte_zero;
  unsigned i;

  mlk_poly_decompress_d4_c(
      &intermediate,
      input);

  mlk_poly_compress_d4_c(
      reconstructed,
      &intermediate);

  byte_zero = reconstructed[0];
  reconstructed[0] =
      (uint8_t)(
          (byte_zero >> 4) |
          (uint8_t)(byte_zero << 4));

  for (i = 0;
       i < MLKEM_POLYCOMPRESSEDBYTES_D4;
       i++)
  {
    __CPROVER_assert(
        reconstructed[i] == input[i],
        "POLYCOMP-D4-T3: compressing the real D4 decompression reconstructs every original input byte");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$COMP_MUT_PROOF_DIR" \
        "$COMP_MUT_PROOF_NAME" \
        "$COMP_MUT_HARNESS_NAME"

    printf 'COMP_MUT_HARNESS=%s\n' "$COMP_MUT_HARNESS"
    printf 'COMP_MUT_HARNESS_SHA256=%s\n' "$(
        sha256sum "$COMP_MUT_HARNESS" |
        awk '{print $1}'
    )"

    build_goto \
        "$COMP_MUT_PROOF_NAME" \
        "$COMP_MUT_GOTO" \
        "$COMP_MUT_RUNNER_LOG" \
        "$COMP_MUT_RUNNER_JSON" ||
        return 80

    check_four_loops \
        "$COMP_MUT_GOTO" \
        "$COMP_MUT_LOOP_REPORT" ||
        return 81

    cbmc \
        "$COMP_MUT_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$COMP_MUT_JSON" \
        2> "$COMP_MUT_STDERR"

    COMP_MUT_EXIT=$?

    printf 'COMP_MUT_CBMC_EXIT=%s\n' "$COMP_MUT_EXIT"

    parse_mutation \
        "$COMP_MUT_JSON" \
        "$COMP_MUT_SUMMARY" \
        "COMPRESSION_SIDE_FAULT"

    COMP_MUT_PARSE_EXIT=$?

    printf 'COMP_MUT_PARSE_EXIT=%s\n' \
        "$COMP_MUT_PARSE_EXIT"

    if [[ "$COMP_MUT_EXIT" -eq 0 ||
          "$COMP_MUT_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "compression-side fault was not detected"
        return 82
    fi

    printf 'T3_COMPRESSION_SIDE_MUTATION_DETECTION=PASS\n'

    section "T3-00C.8 — POST-RUN SOURCE IMMUTABILITY"

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

    section "POLYCOMP-D4-T3-00C VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_T3_00C_STATUS=PASS\n'
        printf 'T3_COMPLETE_LOCATION_COVERAGE=PASS\n'
        printf 'T3_POSITIVE_END_REACHABILITY=PASS\n'
        printf 'T3_NIBBLE_PRESERVATION=PASS\n'
        printf 'T3_CYCLE_STABILITY=PASS\n'
        printf 'T3_DECOMPRESSION_SIDE_MUTATION_DETECTION=PASS\n'
        printf 'T3_COMPRESSION_SIDE_MUTATION_DETECTION=PASS\n'
        printf 'T3_THEOREM_STATUS=ALL_REGISTERED_T3_OBLIGATIONS_CHECKED\n'
        printf 'NEXT_GATE=T3_FINAL_EVIDENCE_FREEZE_AND_PACKAGE\n'
    else
        printf 'POLYCOMP_D4_T3_00C_STATUS=FAIL\n'
        printf 'T3_THEOREM_STATUS=NOT_FINAL\n'
        printf 'NEXT_GATE=CLASSIFY_EXACT_T3_NONVACUITY_MUTATION_OR_OBLIGATION_FAILURE\n'
    fi

    printf 'COVERAGE_JSON=%s\n' "$COVERAGE_JSON"
    printf 'POSITIVE_REACHABILITY_JSON=%s\n' "$POSITIVE_REACH_JSON"
    printf 'NIBBLE_HARNESS=%s\n' "$NIBBLE_HARNESS"
    printf 'NIBBLE_GOTO=%s\n' "$NIBBLE_GOTO"
    printf 'NIBBLE_SEMANTIC_JSON=%s\n' "$NIBBLE_SEMANTIC_JSON"
    printf 'NIBBLE_STRICT_JSON=%s\n' "$NIBBLE_STRICT_JSON"
    printf 'CYCLE_HARNESS=%s\n' "$CYCLE_HARNESS"
    printf 'CYCLE_GOTO=%s\n' "$CYCLE_GOTO"
    printf 'CYCLE_SEMANTIC_JSON=%s\n' "$CYCLE_SEMANTIC_JSON"
    printf 'CYCLE_STRICT_JSON=%s\n' "$CYCLE_STRICT_JSON"
    printf 'DECOMP_MUT_HARNESS=%s\n' "$DECOMP_MUT_HARNESS"
    printf 'DECOMP_MUT_GOTO=%s\n' "$DECOMP_MUT_GOTO"
    printf 'DECOMP_MUT_JSON=%s\n' "$DECOMP_MUT_JSON"
    printf 'COMP_MUT_HARNESS=%s\n' "$COMP_MUT_HARNESS"
    printf 'COMP_MUT_GOTO=%s\n' "$COMP_MUT_GOTO"
    printf 'COMP_MUT_JSON=%s\n' "$COMP_MUT_JSON"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-T3-00C CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
