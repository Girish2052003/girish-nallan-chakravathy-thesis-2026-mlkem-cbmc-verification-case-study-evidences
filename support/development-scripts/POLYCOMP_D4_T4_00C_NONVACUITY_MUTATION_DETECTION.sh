#!/usr/bin/env bash
set -uo pipefail
shopt -s nullglob

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t4_20260726T024145Z"
CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"

POSITIVE_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_projection_distortion"
POSITIVE_HARNESS="${POSITIVE_PROOF}/polycomp_d4_t4_projection_distortion_harness.c"
POSITIVE_MAKEFILE="${POSITIVE_PROOF}/Makefile"
POSITIVE_GOTO="${POSITIVE_PROOF}/gotos/polycomp_d4_t4_projection_distortion_harness.goto"

WITNESS_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_sharp_witness_20260726T024847Z"
WITNESS_HARNESS="${WITNESS_PROOF}/polycomp_d4_t4_sharp_witness_harness.c"
WITNESS_GOTO="${WITNESS_PROOF}/gotos/polycomp_d4_t4_sharp_witness_harness.goto"

FIXED_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_fixed_point_characterization_20260726T024847Z"
FIXED_HARNESS="${FIXED_PROOF}/polycomp_d4_t4_fixed_point_characterization_harness.c"
FIXED_GOTO="${FIXED_PROOF}/gotos/polycomp_d4_t4_fixed_point_characterization_harness.goto"

IDEMP_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_projection_idempotence_20260726T024847Z"
IDEMP_HARNESS="${IDEMP_PROOF}/polycomp_d4_t4_projection_idempotence_harness.c"
IDEMP_GOTO="${IDEMP_PROOF}/gotos/polycomp_d4_t4_projection_idempotence_harness.goto"

LOCALITY_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_coordinate_locality_20260726T024847Z"
LOCALITY_HARNESS="${LOCALITY_PROOF}/polycomp_d4_t4_coordinate_locality_harness.c"
LOCALITY_GOTO="${LOCALITY_PROOF}/gotos/polycomp_d4_t4_coordinate_locality_harness.goto"

EXPECTED_POSITIVE_HARNESS_SHA256="f9b385228c2bed2eb5c5f8be075f0a12c604cba5e8265fd632aab49d525dae1c"
EXPECTED_POSITIVE_MAKEFILE_SHA256="0044f48f8df604a7c1504b9b2cd4c8ec566fa3403c483cf93771a2eafcf796e2"
EXPECTED_POSITIVE_GOTO_SHA256="e9c0f8031f3e7edbcdde441743f12d87cb0b23d09853c2d3458fae04db1483eb"

EXPECTED_WITNESS_HARNESS_SHA256="40d27b75240e706f787588036a04a22c05dbb0af0ec03535bf0e6a70b3a7e13d"
EXPECTED_WITNESS_GOTO_SHA256="126ef34338a0ea64a72140f0f09a07c946659fbd36d3a1d32e9832dd5a956cda"

EXPECTED_FIXED_HARNESS_SHA256="9aca8dd8a1e16b969deb6cf2fa0ace521149e523c3c9003171345a897eeab83d"
EXPECTED_FIXED_GOTO_SHA256="da603bee77516f5f09e1eb529eeefa1dec7d5f412cc64d712bbaeb464d74930c"

EXPECTED_IDEMP_HARNESS_SHA256="2cf6a4a2ed3a1478a33490554e287347730e86b6343c9775ea62b625dd75be99"
EXPECTED_IDEMP_GOTO_SHA256="19197be2f2c9ba7da6b5243cae2b687479b22275d291394d7738efe3fc976e4e"

EXPECTED_LOCALITY_HARNESS_SHA256="ce2c744230eb74c35a8228771c1e90bbdbd407f4bd11066782ebbcf22841af76"
EXPECTED_LOCALITY_GOTO_SHA256="7803688fc57b7804fa29c51217c94ce5da579baa9658d87a3329c781cbe0362a"

POSITIVE_UNWINDSET="harness.0:257,harness.1:257,mlk_poly_compress_d4_c.0:129,mlk_poly_compress_d4_c.1:257,mlk_poly_decompress_d4_c.0:129"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_T4_00C_NONVACUITY_MUTATION_DETECTION"

COVERAGE_JSON="${STAGE_DIR}/T4_LOCATION_COVERAGE_${UTC_STAMP}.json"
COVERAGE_STDERR="${STAGE_DIR}/T4_LOCATION_COVERAGE_STDERR_${UTC_STAMP}.txt"
COVERAGE_SUMMARY="${STAGE_DIR}/T4_LOCATION_COVERAGE_SUMMARY_${UTC_STAMP}.txt"

REACH_GOTO="${STAGE_DIR}/T4_POSITIVE_END_REACHABILITY_${UTC_STAMP}.goto"
REACH_JSON="${STAGE_DIR}/T4_POSITIVE_END_REACHABILITY_${UTC_STAMP}.json"
REACH_STDERR="${STAGE_DIR}/T4_POSITIVE_END_REACHABILITY_STDERR_${UTC_STAMP}.txt"
REACH_SUMMARY="${STAGE_DIR}/T4_POSITIVE_END_REACHABILITY_SUMMARY_${UTC_STAMP}.txt"

CODEBOOK_MUT_PROOF_NAME="polycomp_d4_t4_mutation_codebook_${UTC_STAMP}"
CODEBOOK_MUT_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${CODEBOOK_MUT_PROOF_NAME}"
CODEBOOK_MUT_HARNESS_NAME="polycomp_d4_t4_mutation_codebook_harness"
CODEBOOK_MUT_HARNESS="${CODEBOOK_MUT_PROOF_DIR}/${CODEBOOK_MUT_HARNESS_NAME}.c"
CODEBOOK_MUT_GOTO="${CODEBOOK_MUT_PROOF_DIR}/gotos/${CODEBOOK_MUT_HARNESS_NAME}.goto"
CODEBOOK_MUT_RUNNER_LOG="${STAGE_DIR}/T4_CODEBOOK_MUT_RUNNER_${UTC_STAMP}.txt"
CODEBOOK_MUT_RUNNER_JSON="${STAGE_DIR}/T4_CODEBOOK_MUT_RUNNER_${UTC_STAMP}.json"
CODEBOOK_MUT_LOOP_REPORT="${STAGE_DIR}/T4_CODEBOOK_MUT_LOOP_REPORT_${UTC_STAMP}.txt"
CODEBOOK_MUT_JSON="${STAGE_DIR}/T4_CODEBOOK_MUT_RESULT_${UTC_STAMP}.json"
CODEBOOK_MUT_STDERR="${STAGE_DIR}/T4_CODEBOOK_MUT_STDERR_${UTC_STAMP}.txt"
CODEBOOK_MUT_SUMMARY="${STAGE_DIR}/T4_CODEBOOK_MUT_SUMMARY_${UTC_STAMP}.txt"

DIST_MUT_PROOF_NAME="polycomp_d4_t4_mutation_distortion_${UTC_STAMP}"
DIST_MUT_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${DIST_MUT_PROOF_NAME}"
DIST_MUT_HARNESS_NAME="polycomp_d4_t4_mutation_distortion_harness"
DIST_MUT_HARNESS="${DIST_MUT_PROOF_DIR}/${DIST_MUT_HARNESS_NAME}.c"
DIST_MUT_GOTO="${DIST_MUT_PROOF_DIR}/gotos/${DIST_MUT_HARNESS_NAME}.goto"
DIST_MUT_RUNNER_LOG="${STAGE_DIR}/T4_DIST_MUT_RUNNER_${UTC_STAMP}.txt"
DIST_MUT_RUNNER_JSON="${STAGE_DIR}/T4_DIST_MUT_RUNNER_${UTC_STAMP}.json"
DIST_MUT_LOOP_REPORT="${STAGE_DIR}/T4_DIST_MUT_LOOP_REPORT_${UTC_STAMP}.txt"
DIST_MUT_JSON="${STAGE_DIR}/T4_DIST_MUT_RESULT_${UTC_STAMP}.json"
DIST_MUT_STDERR="${STAGE_DIR}/T4_DIST_MUT_STDERR_${UTC_STAMP}.txt"
DIST_MUT_SUMMARY="${STAGE_DIR}/T4_DIST_MUT_SUMMARY_${UTC_STAMP}.txt"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_T4_00C_NONVACUITY_MUTATION_DETECTION_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

FAIL=0
mkdir -p "$STAGE_DIR"

CODEBOOK_DESCRIPTION="POLYCOMP-D4-T4: every projected coefficient belongs to the exact D4 codebook"
DISTORTION_DESCRIPTION="POLYCOMP-D4-T4: every canonical coefficient has modular projection distortion at most 104"

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

verify_hash()
{
    local path="$1"
    local expected="$2"
    local label="$3"
    local actual

    if [[ ! -f "$path" ]]; then
        mark_fail "$label missing: $path"
        return 1
    fi

    actual="$(sha256sum "$path" | awk '{print $1}')"

    printf '%s_SHA256=%s\n' "$label" "$actual"
    printf '%s_EXPECTED_SHA256=%s\n' "$label" "$expected"

    if [[ "$actual" != "$expected" ]]; then
        mark_fail "$label hash mismatch"
        return 1
    fi

    return 0
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
    local label="$5"

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

    printf '%s_RUNNER_EXIT=%s\n' "$label" "$runner_exit"
    printf '%s_RUNNER_LOG=%s\n' "$label" "$runner_log"
    printf '%s_RUNNER_JSON=%s\n' "$label" "$runner_json"
    printf '%s_RUNNER_NONZERO_ACCEPTABLE_WHEN_GOTO_EXISTS=YES\n' "$label"

    tail -n 90 "$runner_log" 2>/dev/null || true

    if [[ ! -f "$goto_file" ]]; then
        mark_fail "$label runner did not produce GOTO"
        return 1
    fi

    printf '%s_GOTO_FILE=%s\n' "$label" "$goto_file"
    printf '%s_GOTO_SIZE=%s\n' "$label" "$(stat -c '%s' "$goto_file")"
    printf '%s_GOTO_SHA256=%s\n' "$label" "$(
        sha256sum "$goto_file" |
        awk '{print $1}'
    )"

    return 0
}

check_five_loops()
{
    local goto_file="$1"
    local loop_report="$2"
    local label="$3"

    goto-instrument \
        --show-loops \
        "$goto_file" \
        > "$loop_report" 2>&1

    local discovery_exit=$?

    printf '%s_LOOP_DISCOVERY_EXIT=%s\n' "$label" "$discovery_exit"
    printf '%s_LOOP_REPORT=%s\n' "$label" "$loop_report"

    cat "$loop_report"

    if [[ "$discovery_exit" -ne 0 ]]; then
        mark_fail "$label loop discovery failed"
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
    "harness.1",
    "mlk_poly_compress_d4_c.0",
    "mlk_poly_compress_d4_c.1",
    "mlk_poly_decompress_d4_c.0",
}

accepted = (
    len(loop_ids) == 5
    and set(loop_ids) == expected
)

print(f"TOTAL_LOOP_COUNT={len(loop_ids)}")
print(f"UNIQUE_LOOP_COUNT={len(set(loop_ids))}")
print(
    "FIVE_LOOP_INVENTORY="
    + ("PASS" if accepted else "FAIL")
)

if not accepted:
    raise SystemExit(1)
PY

    local parse_exit=$?

    printf '%s_LOOP_PARSE_EXIT=%s\n' "$label" "$parse_exit"

    if [[ "$parse_exit" -ne 0 ]]; then
        mark_fail "$label loop inventory mismatch"
        return 1
    fi

    return 0
}

parse_mutation()
{
    local json_file="$1"
    local summary_file="$2"
    local expected_failure="$3"
    local expected_success="$4"
    local label="$5"

    python3 - \
        "$json_file" \
        "$summary_file" \
        "$expected_failure" \
        "$expected_success" \
        "$label" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
failure_description = sys.argv[3]
success_description = sys.argv[4]
label = sys.argv[5]

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

failure_matches = [
    item
    for item in results
    if str(item.get("description", "")) == failure_description
]

success_matches = [
    item
    for item in results
    if str(item.get("description", "")) == success_description
]

failure_ok = (
    len(failure_matches) == 1
    and failure_matches[0].get("status") == "FAILURE"
)

success_ok = (
    len(success_matches) == 1
    and success_matches[0].get("status") == "SUCCESS"
)

other_success = all(
    item.get("status") == "SUCCESS"
    for item in results
    if str(item.get("description", ""))
    not in {
        failure_description,
        success_description,
    }
)

cprover_failure = any(
    status.lower() == "failure"
    for status in statuses
)

accepted = (
    failure_ok
    and success_ok
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
    f"EXPECTED_FAILURE_COUNT={len(failure_matches)}",
    "EXPECTED_FAILURE_STATUS="
    + (
        str(failure_matches[0].get("status"))
        if failure_matches
        else "MISSING"
    ),
    f"EXPECTED_SUCCESS_COUNT={len(success_matches)}",
    "EXPECTED_SUCCESS_STATUS="
    + (
        str(success_matches[0].get("status"))
        if success_matches
        else "MISSING"
    ),
    "OTHER_PROPERTIES="
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
    section "POLYCOMP-D4-T4-00C — COVERAGE, REACHABILITY AND ISOLATED MUTATION DETECTION"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "T4-00C.1 — ALL FROZEN ARTEFACT REBINDING"

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
        mark_fail "T4 production source is modified"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_BEFORE=CLEAN\n'
    fi

    verify_hash "$POSITIVE_HARNESS" "$EXPECTED_POSITIVE_HARNESS_SHA256" "POSITIVE_HARNESS"
    verify_hash "$POSITIVE_MAKEFILE" "$EXPECTED_POSITIVE_MAKEFILE_SHA256" "POSITIVE_MAKEFILE"
    verify_hash "$POSITIVE_GOTO" "$EXPECTED_POSITIVE_GOTO_SHA256" "POSITIVE_GOTO"

    verify_hash "$WITNESS_HARNESS" "$EXPECTED_WITNESS_HARNESS_SHA256" "WITNESS_HARNESS"
    verify_hash "$WITNESS_GOTO" "$EXPECTED_WITNESS_GOTO_SHA256" "WITNESS_GOTO"

    verify_hash "$FIXED_HARNESS" "$EXPECTED_FIXED_HARNESS_SHA256" "FIXED_HARNESS"
    verify_hash "$FIXED_GOTO" "$EXPECTED_FIXED_GOTO_SHA256" "FIXED_GOTO"

    verify_hash "$IDEMP_HARNESS" "$EXPECTED_IDEMP_HARNESS_SHA256" "IDEMP_HARNESS"
    verify_hash "$IDEMP_GOTO" "$EXPECTED_IDEMP_GOTO_SHA256" "IDEMP_GOTO"

    verify_hash "$LOCALITY_HARNESS" "$EXPECTED_LOCALITY_HARNESS_SHA256" "LOCALITY_HARNESS"
    verify_hash "$LOCALITY_GOTO" "$EXPECTED_LOCALITY_GOTO_SHA256" "LOCALITY_GOTO"

    if [[ "$FAIL" -ne 0 ]]; then
        return 20
    fi

    printf 'T4_ALL_FROZEN_ARTEFACT_REBINDING=PASS\n'

    section "T4-00C.2 — COMPLETE LOCATION COVERAGE"

    cbmc \
        "$POSITIVE_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$POSITIVE_UNWINDSET" \
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
        mark_fail "T4 complete location coverage failed"
        return 30
    fi

    printf 'T4_COMPLETE_LOCATION_COVERAGE=PASS\n'

    section "T4-00C.3 — POSITIVE END-OF-HARNESS REACHABILITY"

    goto-instrument \
        --insert-final-assert-false harness \
        "$POSITIVE_GOTO" \
        "$REACH_GOTO" \
        > "${STAGE_DIR}/T4_REACH_INSTRUMENT_STDOUT_${UTC_STAMP}.txt" \
        2> "${STAGE_DIR}/T4_REACH_INSTRUMENT_STDERR_${UTC_STAMP}.txt"

    if [[ "$?" -ne 0 || ! -f "$REACH_GOTO" ]]; then
        mark_fail "could not create T4 reachability GOTO"
        return 40
    fi

    cbmc \
        "$REACH_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$POSITIVE_UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$REACH_JSON" \
        2> "$REACH_STDERR"

    REACH_EXIT=$?

    printf 'REACHABILITY_CBMC_EXIT=%s\n' "$REACH_EXIT"

    python3 - \
        "$REACH_JSON" \
        "$REACH_SUMMARY" \
        "$CODEBOOK_DESCRIPTION" \
        "$DISTORTION_DESCRIPTION" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
descriptions = sys.argv[3:]

payload = json.loads(
    json_path.read_text(encoding="utf-8")
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

targets = {}

for description in descriptions:
    targets[description] = [
        item
        for item in results
        if str(item.get("description", "")) == description
    ]

targets_success = all(
    len(matches) == 1
    and matches[0].get("status") == "SUCCESS"
    for matches in targets.values()
)

inserted_failures = [
    item
    for item in results
    if (
        item.get("status") == "FAILURE"
        and str(item.get("description", ""))
        not in set(descriptions)
    )
]

accepted = (
    targets_success
    and bool(inserted_failures)
)

lines = [
    "REACHABILITY_PARSE_STATUS=PASS",
    f"PROPERTY_RESULT_COUNT={len(results)}",
]

for index, description in enumerate(descriptions):
    matches = targets[description]
    lines.append(
        f"TARGET_{index}_COUNT={len(matches)}"
    )
    lines.append(
        f"TARGET_{index}_STATUS="
        + (
            str(matches[0].get("status"))
            if matches
            else "MISSING"
        )
    )

lines.extend(
    [
        f"INSERTED_FINAL_FAILURE_COUNT={len(inserted_failures)}",
        "POSITIVE_END_REACHABILITY="
        + ("PASS" if accepted else "FAIL"),
    ]
)

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")

if not accepted:
    raise SystemExit(1)
PY

    REACH_PARSE_EXIT=$?

    printf 'REACHABILITY_PARSE_EXIT=%s\n' "$REACH_PARSE_EXIT"

    if [[ "$REACH_EXIT" -eq 0 ||
          "$REACH_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "T4 positive end reachability failed"
        return 41
    fi

    printf 'T4_POSITIVE_END_REACHABILITY=PASS\n'

    section "T4-00C.4 — ISOLATED CODEBOOK-MEMBERSHIP MUTATION"

    mkdir -p "$CODEBOOK_MUT_PROOF_DIR"

    cat > "$CODEBOOK_MUT_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T4 isolated codebook-membership fault injection.
 *
 * The real projection of the all-zero polynomial is computed. One projected
 * coefficient is then changed from codebook value 0 to non-codebook value 1.
 *
 * Expected:
 *   - codebook-membership assertion fails;
 *   - distortion <= 104 assertion remains true.
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

static _Bool t4_is_codebook_value(
    int16_t value)
{
  return
      value == 0 ||
      value == 208 ||
      value == 416 ||
      value == 624 ||
      value == 832 ||
      value == 1040 ||
      value == 1248 ||
      value == 1456 ||
      value == 1665 ||
      value == 1873 ||
      value == 2081 ||
      value == 2289 ||
      value == 2497 ||
      value == 2705 ||
      value == 2913 ||
      value == 3121;
}

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input;
  uint8_t compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly projected;
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 0;
  }

  mlk_poly_compress_d4_c(
      compressed,
      &input);

  mlk_poly_decompress_d4_c(
      &projected,
      compressed);

  projected.coeffs[0] = 1;

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t difference =
        (int32_t)input.coeffs[i] -
        (int32_t)projected.coeffs[i];

    int32_t modular_distance;

    if (difference < 0)
    {
      difference = -difference;
    }

    modular_distance = difference;

    if (modular_distance > MLKEM_Q / 2)
    {
      modular_distance =
          MLKEM_Q - modular_distance;
    }

    __CPROVER_assert(
        t4_is_codebook_value(
            projected.coeffs[i]),
        "POLYCOMP-D4-T4: every projected coefficient belongs to the exact D4 codebook");

    __CPROVER_assert(
        modular_distance <= 104,
        "POLYCOMP-D4-T4: every canonical coefficient has modular projection distortion at most 104");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$CODEBOOK_MUT_PROOF_DIR" \
        "$CODEBOOK_MUT_PROOF_NAME" \
        "$CODEBOOK_MUT_HARNESS_NAME"

    printf 'CODEBOOK_MUT_HARNESS=%s\n' "$CODEBOOK_MUT_HARNESS"
    printf 'CODEBOOK_MUT_HARNESS_SHA256=%s\n' "$(
        sha256sum "$CODEBOOK_MUT_HARNESS" |
        awk '{print $1}'
    )"

    CODEBOOK_MUT_COMPRESS_CALLS="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_compress_d4_c[[:space:]]*\(' \
            "$CODEBOOK_MUT_HARNESS" ||
        true
    )"

    CODEBOOK_MUT_DECOMPRESS_CALLS="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_decompress_d4_c[[:space:]]*\(' \
            "$CODEBOOK_MUT_HARNESS" ||
        true
    )"

    CODEBOOK_MUT_ASSERTS="$(
        grep -Ec \
            '^[[:space:]]*__CPROVER_assert[[:space:]]*\(' \
            "$CODEBOOK_MUT_HARNESS" ||
        true
    )"

    CODEBOOK_MUT_ASSUMES="$(
        grep -c '__CPROVER_assume' \
            "$CODEBOOK_MUT_HARNESS" ||
        true
    )"

    printf 'CODEBOOK_MUT_COMPRESS_CALL_COUNT=%s\n' \
        "$CODEBOOK_MUT_COMPRESS_CALLS"

    printf 'CODEBOOK_MUT_DECOMPRESS_CALL_COUNT=%s\n' \
        "$CODEBOOK_MUT_DECOMPRESS_CALLS"

    printf 'CODEBOOK_MUT_ASSERT_SITE_COUNT=%s\n' \
        "$CODEBOOK_MUT_ASSERTS"

    printf 'CODEBOOK_MUT_ASSUME_COUNT=%s\n' \
        "$CODEBOOK_MUT_ASSUMES"

    if [[ "$CODEBOOK_MUT_COMPRESS_CALLS" != "1" ||
          "$CODEBOOK_MUT_DECOMPRESS_CALLS" != "1" ||
          "$CODEBOOK_MUT_ASSERTS" != "2" ||
          "$CODEBOOK_MUT_ASSUMES" != "0" ]]
    then
        mark_fail "codebook mutation static firewall failed"
        return 50
    fi

    printf 'T4_CODEBOOK_MUTATION_STATIC_FIREWALL=PASS\n'

    build_goto \
        "$CODEBOOK_MUT_PROOF_NAME" \
        "$CODEBOOK_MUT_GOTO" \
        "$CODEBOOK_MUT_RUNNER_LOG" \
        "$CODEBOOK_MUT_RUNNER_JSON" \
        "T4_CODEBOOK_MUT" ||
        return 51

    check_five_loops \
        "$CODEBOOK_MUT_GOTO" \
        "$CODEBOOK_MUT_LOOP_REPORT" \
        "T4_CODEBOOK_MUT" ||
        return 52

    cbmc \
        "$CODEBOOK_MUT_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$POSITIVE_UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$CODEBOOK_MUT_JSON" \
        2> "$CODEBOOK_MUT_STDERR"

    CODEBOOK_MUT_EXIT=$?

    printf 'CODEBOOK_MUT_CBMC_EXIT=%s\n' "$CODEBOOK_MUT_EXIT"

    parse_mutation \
        "$CODEBOOK_MUT_JSON" \
        "$CODEBOOK_MUT_SUMMARY" \
        "$CODEBOOK_DESCRIPTION" \
        "$DISTORTION_DESCRIPTION" \
        "CODEBOOK_MEMBERSHIP_FAULT"

    CODEBOOK_MUT_PARSE_EXIT=$?

    printf 'CODEBOOK_MUT_PARSE_EXIT=%s\n' \
        "$CODEBOOK_MUT_PARSE_EXIT"

    if [[ "$CODEBOOK_MUT_EXIT" -eq 0 ||
          "$CODEBOOK_MUT_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "isolated codebook mutation was not detected correctly"
        return 53
    fi

    printf 'T4_CODEBOOK_MEMBERSHIP_MUTATION_DETECTION=PASS\n'

    section "T4-00C.5 — ISOLATED DISTORTION-BOUND MUTATION"

    mkdir -p "$DIST_MUT_PROOF_DIR"

    cat > "$DIST_MUT_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T4 isolated distortion-bound fault injection.
 *
 * The real projection of the all-zero polynomial is computed. One projected
 * coefficient is then changed from codebook value 0 to codebook value 208.
 *
 * Expected:
 *   - codebook-membership assertion remains true;
 *   - modular distortion <= 104 assertion fails with distance 208.
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

static _Bool t4_is_codebook_value(
    int16_t value)
{
  return
      value == 0 ||
      value == 208 ||
      value == 416 ||
      value == 624 ||
      value == 832 ||
      value == 1040 ||
      value == 1248 ||
      value == 1456 ||
      value == 1665 ||
      value == 1873 ||
      value == 2081 ||
      value == 2289 ||
      value == 2497 ||
      value == 2705 ||
      value == 2913 ||
      value == 3121;
}

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input;
  uint8_t compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly projected;
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 0;
  }

  mlk_poly_compress_d4_c(
      compressed,
      &input);

  mlk_poly_decompress_d4_c(
      &projected,
      compressed);

  projected.coeffs[0] = 208;

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t difference =
        (int32_t)input.coeffs[i] -
        (int32_t)projected.coeffs[i];

    int32_t modular_distance;

    if (difference < 0)
    {
      difference = -difference;
    }

    modular_distance = difference;

    if (modular_distance > MLKEM_Q / 2)
    {
      modular_distance =
          MLKEM_Q - modular_distance;
    }

    __CPROVER_assert(
        t4_is_codebook_value(
            projected.coeffs[i]),
        "POLYCOMP-D4-T4: every projected coefficient belongs to the exact D4 codebook");

    __CPROVER_assert(
        modular_distance <= 104,
        "POLYCOMP-D4-T4: every canonical coefficient has modular projection distortion at most 104");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$DIST_MUT_PROOF_DIR" \
        "$DIST_MUT_PROOF_NAME" \
        "$DIST_MUT_HARNESS_NAME"

    printf 'DIST_MUT_HARNESS=%s\n' "$DIST_MUT_HARNESS"
    printf 'DIST_MUT_HARNESS_SHA256=%s\n' "$(
        sha256sum "$DIST_MUT_HARNESS" |
        awk '{print $1}'
    )"

    DIST_MUT_COMPRESS_CALLS="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_compress_d4_c[[:space:]]*\(' \
            "$DIST_MUT_HARNESS" ||
        true
    )"

    DIST_MUT_DECOMPRESS_CALLS="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_decompress_d4_c[[:space:]]*\(' \
            "$DIST_MUT_HARNESS" ||
        true
    )"

    DIST_MUT_ASSERTS="$(
        grep -Ec \
            '^[[:space:]]*__CPROVER_assert[[:space:]]*\(' \
            "$DIST_MUT_HARNESS" ||
        true
    )"

    DIST_MUT_ASSUMES="$(
        grep -c '__CPROVER_assume' \
            "$DIST_MUT_HARNESS" ||
        true
    )"

    printf 'DIST_MUT_COMPRESS_CALL_COUNT=%s\n' \
        "$DIST_MUT_COMPRESS_CALLS"

    printf 'DIST_MUT_DECOMPRESS_CALL_COUNT=%s\n' \
        "$DIST_MUT_DECOMPRESS_CALLS"

    printf 'DIST_MUT_ASSERT_SITE_COUNT=%s\n' \
        "$DIST_MUT_ASSERTS"

    printf 'DIST_MUT_ASSUME_COUNT=%s\n' \
        "$DIST_MUT_ASSUMES"

    if [[ "$DIST_MUT_COMPRESS_CALLS" != "1" ||
          "$DIST_MUT_DECOMPRESS_CALLS" != "1" ||
          "$DIST_MUT_ASSERTS" != "2" ||
          "$DIST_MUT_ASSUMES" != "0" ]]
    then
        mark_fail "distortion mutation static firewall failed"
        return 60
    fi

    printf 'T4_DISTORTION_MUTATION_STATIC_FIREWALL=PASS\n'

    build_goto \
        "$DIST_MUT_PROOF_NAME" \
        "$DIST_MUT_GOTO" \
        "$DIST_MUT_RUNNER_LOG" \
        "$DIST_MUT_RUNNER_JSON" \
        "T4_DIST_MUT" ||
        return 61

    check_five_loops \
        "$DIST_MUT_GOTO" \
        "$DIST_MUT_LOOP_REPORT" \
        "T4_DIST_MUT" ||
        return 62

    cbmc \
        "$DIST_MUT_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$POSITIVE_UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$DIST_MUT_JSON" \
        2> "$DIST_MUT_STDERR"

    DIST_MUT_EXIT=$?

    printf 'DIST_MUT_CBMC_EXIT=%s\n' "$DIST_MUT_EXIT"

    parse_mutation \
        "$DIST_MUT_JSON" \
        "$DIST_MUT_SUMMARY" \
        "$DISTORTION_DESCRIPTION" \
        "$CODEBOOK_DESCRIPTION" \
        "DISTORTION_BOUND_FAULT"

    DIST_MUT_PARSE_EXIT=$?

    printf 'DIST_MUT_PARSE_EXIT=%s\n' \
        "$DIST_MUT_PARSE_EXIT"

    if [[ "$DIST_MUT_EXIT" -eq 0 ||
          "$DIST_MUT_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "isolated distortion mutation was not detected correctly"
        return 63
    fi

    printf 'T4_DISTORTION_BOUND_MUTATION_DETECTION=PASS\n'

    section "T4-00C.6 — POST-RUN SOURCE IMMUTABILITY"

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
        mark_fail "T4 production source became dirty"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_AFTER=CLEAN\n'
    fi

    printf 'AUTHORITATIVE_HEAD_AFTER=%s\n' "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD
    )"

    printf 'WORK_REPO_HEAD_AFTER=%s\n' "$(
        git -C "$WORK_REPO" rev-parse HEAD
    )"

    section "POLYCOMP-D4-T4-00C VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_T4_00C_STATUS=PASS\n'
        printf 'T4_COMPLETE_LOCATION_COVERAGE=PASS\n'
        printf 'T4_POSITIVE_END_REACHABILITY=PASS\n'
        printf 'T4_CODEBOOK_MEMBERSHIP_MUTATION_DETECTION=PASS\n'
        printf 'T4_DISTORTION_BOUND_MUTATION_DETECTION=PASS\n'
        printf 'T4_THEOREM_STATUS=ALL_REGISTERED_T4_OBLIGATIONS_CHECKED\n'
        printf 'NEXT_GATE=T4_FINAL_EVIDENCE_FREEZE_AND_PACKAGE\n'
    else
        printf 'POLYCOMP_D4_T4_00C_STATUS=FAIL\n'
        printf 'T4_THEOREM_STATUS=NOT_FINAL\n'
        printf 'NEXT_GATE=CLASSIFY_EXACT_T4_NONVACUITY_OR_MUTATION_FAILURE\n'
    fi

    printf 'COVERAGE_JSON=%s\n' "$COVERAGE_JSON"
    printf 'REACHABILITY_JSON=%s\n' "$REACH_JSON"
    printf 'CODEBOOK_MUT_HARNESS=%s\n' "$CODEBOOK_MUT_HARNESS"
    printf 'CODEBOOK_MUT_GOTO=%s\n' "$CODEBOOK_MUT_GOTO"
    printf 'CODEBOOK_MUT_JSON=%s\n' "$CODEBOOK_MUT_JSON"
    printf 'DIST_MUT_HARNESS=%s\n' "$DIST_MUT_HARNESS"
    printf 'DIST_MUT_GOTO=%s\n' "$DIST_MUT_GOTO"
    printf 'DIST_MUT_JSON=%s\n' "$DIST_MUT_JSON"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-T4-00C CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
