#!/usr/bin/env bash
set -uo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"

WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t1_20260725T152707Z"

POSITIVE_PROOF_NAME="polycomp_d4_t1_packed_refinement"
POSITIVE_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${POSITIVE_PROOF_NAME}"

POSITIVE_HARNESS="${POSITIVE_PROOF_DIR}/polycomp_d4_t1_packed_refinement_harness.c"
POSITIVE_GOTO="${POSITIVE_PROOF_DIR}/gotos/polycomp_d4_t1_packed_refinement_harness.goto"

EXPECTED_HARNESS_SHA256="90deb2c5942fe71af658552a608efa3179715d267396c25be6e0fb469637e21d"
EXPECTED_GOTO_SHA256="cebb58e934cdff4c717bcef0273a937d22f4a4c08f1ace957da81ac25f3800b7"

UNWINDSET="harness.0:257,harness.1:257,mlk_poly_compress_d4_c.0:33,mlk_poly_compress_d4_c.1:33"

CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"
STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_00E_T1_NONVACUITY_MUTATION"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_00E_T1_NONVACUITY_MUTATION_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

COVERAGE_JSON="${STAGE_DIR}/T1_COVERAGE_${UTC_STAMP}.json"
COVERAGE_STDERR="${STAGE_DIR}/T1_COVERAGE_STDERR_${UTC_STAMP}.txt"
COVERAGE_SUMMARY="${STAGE_DIR}/T1_COVERAGE_SUMMARY_${UTC_STAMP}.txt"

REACH_GOTO="${STAGE_DIR}/T1_END_REACHABILITY_${UTC_STAMP}.goto"
REACH_PROPERTIES="${STAGE_DIR}/T1_END_REACHABILITY_PROPERTIES_${UTC_STAMP}.txt"
REACH_JSON="${STAGE_DIR}/T1_END_REACHABILITY_RESULT_${UTC_STAMP}.json"
REACH_STDERR="${STAGE_DIR}/T1_END_REACHABILITY_STDERR_${UTC_STAMP}.txt"
REACH_SUMMARY="${STAGE_DIR}/T1_END_REACHABILITY_SUMMARY_${UTC_STAMP}.txt"

MUTANT_PROOF_NAME="polycomp_d4_t1_mutation_flipbit_${UTC_STAMP}"
MUTANT_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${MUTANT_PROOF_NAME}"

MUTANT_HARNESS_NAME="polycomp_d4_t1_mutation_flipbit_harness"
MUTANT_HARNESS="${MUTANT_PROOF_DIR}/${MUTANT_HARNESS_NAME}.c"
MUTANT_MAKEFILE="${MUTANT_PROOF_DIR}/Makefile"

MUTANT_RUNNER_JSON="${STAGE_DIR}/T1_MUTANT_RUNNER_${UTC_STAMP}.json"
MUTANT_RUNNER_LOG="${STAGE_DIR}/T1_MUTANT_RUNNER_${UTC_STAMP}.txt"

MUTANT_GOTO="${MUTANT_PROOF_DIR}/gotos/${MUTANT_HARNESS_NAME}.goto"
MUTANT_LOOPS="${STAGE_DIR}/T1_MUTANT_LOOPS_${UTC_STAMP}.txt"
MUTANT_PROPERTIES="${STAGE_DIR}/T1_MUTANT_PROPERTIES_${UTC_STAMP}.txt"

MUTANT_JSON="${STAGE_DIR}/T1_MUTANT_RESULT_${UTC_STAMP}.json"
MUTANT_STDERR="${STAGE_DIR}/T1_MUTANT_STDERR_${UTC_STAMP}.txt"
MUTANT_SUMMARY="${STAGE_DIR}/T1_MUTANT_SUMMARY_${UTC_STAMP}.txt"

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

main()
{
    local authoritative_head
    local work_head
    local authoritative_status
    local production_status

    section "POLYCOMP-D4-00E — T1 COVERAGE / NON-VACUITY / MUTATION"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'POSITIVE_HARNESS=%s\n' "$POSITIVE_HARNESS"
    printf 'POSITIVE_GOTO=%s\n' "$POSITIVE_GOTO"
    printf 'UNWINDSET=%s\n' "$UNWINDSET"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "00E.1 — FROZEN POSITIVE ARTEFACT REBINDING"

    if [[ ! -d "$AUTHORITATIVE_SOURCE_PATH" ]]; then
        mark_fail "authoritative source directory is missing"
        return 20
    fi

    if [[ ! -d "$WORK_REPO" ]]; then
        mark_fail "isolated work repository is missing"
        return 21
    fi

    if [[ ! -f "$POSITIVE_HARNESS" ]]; then
        mark_fail "frozen positive harness is missing"
        return 22
    fi

    if [[ ! -f "$POSITIVE_GOTO" ]]; then
        mark_fail "frozen positive GOTO binary is missing"
        return 23
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

    HARNESS_SHA256="$(
        sha256sum "$POSITIVE_HARNESS" |
        awk '{print $1}'
    )"

    GOTO_SHA256="$(
        sha256sum "$POSITIVE_GOTO" |
        awk '{print $1}'
    )"

    printf 'POSITIVE_HARNESS_SHA256=%s\n' "$HARNESS_SHA256"
    printf 'EXPECTED_HARNESS_SHA256=%s\n' "$EXPECTED_HARNESS_SHA256"

    printf 'POSITIVE_GOTO_SHA256=%s\n' "$GOTO_SHA256"
    printf 'EXPECTED_GOTO_SHA256=%s\n' "$EXPECTED_GOTO_SHA256"

    if [[ "$HARNESS_SHA256" != "$EXPECTED_HARNESS_SHA256" ]]; then
        mark_fail "positive harness differs from 00D"
    fi

    if [[ "$GOTO_SHA256" != "$EXPECTED_GOTO_SHA256" ]]; then
        mark_fail "positive GOTO binary differs from 00D"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 24
    fi

    printf 'FROZEN_POSITIVE_ARTEFACT_BINDING=PASS\n'

    section "00E.2 — DEDICATED LOCATION COVERAGE"

    printf 'COVERAGE_COMMAND_BEGIN\n'

    printf 'cbmc %q \\\n' "$POSITIVE_GOTO"
    printf '  --object-bits 8 \\\n'
    printf '  --slice-formula \\\n'
    printf '  --unwind 1 \\\n'
    printf '  --unwindset %q \\\n' "$UNWINDSET"
    printf '  --no-unwinding-assertions \\\n'
    printf '  --no-standard-checks \\\n'
    printf '  --cover location --json-ui\n'

    printf 'COVERAGE_COMMAND_END\n'

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
    printf 'COVERAGE_STDERR=%s\n' "$COVERAGE_STDERR"

    printf 'COVERAGE_JSON_SIZE=%s\n' \
        "$(stat -c '%s' "$COVERAGE_JSON" 2>/dev/null || printf unknown)"

    printf 'COVERAGE_JSON_SHA256=%s\n' \
        "$(sha256sum "$COVERAGE_JSON" | awk '{print $1}')"

    printf '\n--- coverage stderr ---\n'
    cat "$COVERAGE_STDERR" 2>/dev/null || true

    python3 - \
        "$COVERAGE_JSON" \
        "$COVERAGE_SUMMARY" <<'PY'
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
        "COVERAGE_PARSE_STATUS=FAIL\n"
        f"COVERAGE_PARSE_ERROR={type(error).__name__}: {error}\n",
        encoding="utf-8",
    )
    print(summary_path.read_text(encoding="utf-8"), end="")
    raise SystemExit(2)

entries = payload if isinstance(payload, list) else [payload]

results = []
cprover_statuses = []

for entry in entries:
    if not isinstance(entry, dict):
        continue

    if "cProverStatus" in entry:
        cprover_statuses.append(str(entry["cProverStatus"]))

    result = entry.get("result")

    if isinstance(result, list):
        results.extend(
            item for item in result
            if isinstance(item, dict)
        )

statuses = Counter(
    str(item.get("status", "UNKNOWN"))
    for item in results
)

selected = []

for item in results:
    location = item.get("sourceLocation") or {}

    if not isinstance(location, dict):
        continue

    function = str(location.get("function", ""))
    file_name = str(location.get("file", ""))

    try:
        line = int(str(location.get("line", "0")))
    except ValueError:
        line = 0

    status = str(item.get("status", ""))

    if (
        function == "harness"
        and file_name.endswith(
            "polycomp_d4_t1_packed_refinement_harness.c"
        )
        and line >= 68
        and status in {"SATISFIED", "SUCCESS"}
    ):
        selected.append((line, item))

lines = [
    "COVERAGE_PARSE_STATUS=PASS",
    "CPROVER_STATUSES="
    + (
        ",".join(cprover_statuses)
        if cprover_statuses
        else "<NOT_EXTRACTED>"
    ),
    f"COVERAGE_RESULT_COUNT={len(results)}",
]

for status, count in sorted(statuses.items()):
    lines.append(f"COVERAGE_STATUS_{status}={count}")

lines.append(
    f"SELECTED_LATE_HARNESS_SATISFIED_COUNT={len(selected)}"
)

for index, (line, item) in enumerate(selected[:40]):
    lines.append(
        f"SELECTED_COVERAGE_{index}="
        f"line:{line}|"
        f"{item.get('status', '')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

status_ok = (
    not cprover_statuses
    or all(
        status.lower() == "success"
        for status in cprover_statuses
    )
)

if status_ok and selected:
    lines.append("SELECTED_LOCATION_COVERAGE_STATUS=PASS")
else:
    lines.append("SELECTED_LOCATION_COVERAGE_STATUS=FAIL")

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")

if not (status_ok and selected):
    raise SystemExit(1)
PY

    COVERAGE_PARSE_EXIT=$?

    printf 'COVERAGE_PARSE_EXIT=%s\n' "$COVERAGE_PARSE_EXIT"
    printf 'COVERAGE_SUMMARY=%s\n' "$COVERAGE_SUMMARY"

    printf '\n--- coverage JSON tail ---\n'
    tail -n 140 "$COVERAGE_JSON" 2>/dev/null || true

    if [[ "$COVERAGE_EXIT" -ne 0 ]]; then
        mark_fail "dedicated coverage run failed"
    fi

    if [[ "$COVERAGE_PARSE_EXIT" -ne 0 ]]; then
        mark_fail "late harness locations were not shown reachable"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 30
    fi

    printf 'T1_SELECTED_LOCATION_COVERAGE=PASS\n'

    section "00E.3 — END-OF-HARNESS REACHABILITY MUTANT"

    goto-instrument \
        --insert-final-assert-false harness \
        "$POSITIVE_GOTO" \
        "$REACH_GOTO" \
        > "${STAGE_DIR}/reachability_instrument_stdout_${UTC_STAMP}.txt" \
        2> "${STAGE_DIR}/reachability_instrument_stderr_${UTC_STAMP}.txt"

    REACH_INSTRUMENT_EXIT=$?

    printf 'REACHABILITY_INSTRUMENT_EXIT=%s\n' \
        "$REACH_INSTRUMENT_EXIT"

    printf 'REACHABILITY_GOTO=%s\n' "$REACH_GOTO"

    cat \
        "${STAGE_DIR}/reachability_instrument_stdout_${UTC_STAMP}.txt" \
        2>/dev/null ||
        true

    cat \
        "${STAGE_DIR}/reachability_instrument_stderr_${UTC_STAMP}.txt" \
        2>/dev/null ||
        true

    if [[ "$REACH_INSTRUMENT_EXIT" -ne 0 ||
          ! -f "$REACH_GOTO" ]]
    then
        mark_fail "could not create reachability GOTO mutant"
        return 40
    fi

    printf 'REACHABILITY_GOTO_SHA256=%s\n' \
        "$(sha256sum "$REACH_GOTO" | awk '{print $1}')"

    cbmc \
        "$REACH_GOTO" \
        --show-properties \
        > "$REACH_PROPERTIES" 2>&1

    printf 'REACHABILITY_PROPERTIES=%s\n' "$REACH_PROPERTIES"

    grep -n -B 4 -A 8 \
        -E 'assert\(false\)|harness\.assertion' \
        "$REACH_PROPERTIES" \
        2>/dev/null ||
        true

    cbmc \
        "$REACH_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$REACH_JSON" \
        2> "$REACH_STDERR"

    REACH_EXIT=$?

    printf 'REACHABILITY_CBMC_EXIT=%s\n' "$REACH_EXIT"
    printf 'REACHABILITY_JSON=%s\n' "$REACH_JSON"
    printf 'REACHABILITY_STDERR=%s\n' "$REACH_STDERR"

    printf '\n--- reachability stderr ---\n'
    cat "$REACH_STDERR" 2>/dev/null || true

    python3 - \
        "$REACH_JSON" \
        "$REACH_SUMMARY" <<'PY'
import json
import sys
from pathlib import Path

result_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])

try:
    payload = json.loads(result_path.read_text(encoding="utf-8"))
except Exception as error:
    summary_path.write_text(
        "REACHABILITY_PARSE_STATUS=FAIL\n"
        f"REACHABILITY_PARSE_ERROR={type(error).__name__}: {error}\n",
        encoding="utf-8",
    )
    print(summary_path.read_text(encoding="utf-8"), end="")
    raise SystemExit(2)

entries = payload if isinstance(payload, list) else [payload]
results = []

for entry in entries:
    if (
        isinstance(entry, dict)
        and isinstance(entry.get("result"), list)
    ):
        results.extend(
            item for item in entry["result"]
            if isinstance(item, dict)
        )

positive = [
    item for item in results
    if str(item.get("property", "")) == "harness.assertion.1"
]

inserted_failures = []

for item in results:
    property_id = str(item.get("property", ""))
    status = str(item.get("status", ""))

    location = item.get("sourceLocation") or {}

    function = (
        str(location.get("function", ""))
        if isinstance(location, dict)
        else ""
    )

    if (
        function == "harness"
        and property_id != "harness.assertion.1"
        and status == "FAILURE"
    ):
        inserted_failures.append(item)

positive_success = any(
    str(item.get("status", "")) == "SUCCESS"
    for item in positive
)

lines = [
    "REACHABILITY_PARSE_STATUS=PASS",
    f"PROPERTY_RESULT_COUNT={len(results)}",
    f"POSITIVE_PROPERTY_RESULT_COUNT={len(positive)}",
    f"INSERTED_FAILURE_COUNT={len(inserted_failures)}",
]

for index, item in enumerate(positive):
    lines.append(
        f"POSITIVE_PROPERTY_{index}="
        f"{item.get('status', '')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

for index, item in enumerate(inserted_failures):
    lines.append(
        f"INSERTED_FAILURE_{index}="
        f"{item.get('status', '')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

if positive_success and inserted_failures:
    lines.append("END_OF_HARNESS_REACHABILITY=PASS")
else:
    lines.append("END_OF_HARNESS_REACHABILITY=FAIL")

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")

if not (positive_success and inserted_failures):
    raise SystemExit(1)
PY

    REACH_PARSE_EXIT=$?

    printf 'REACHABILITY_PARSE_EXIT=%s\n' "$REACH_PARSE_EXIT"
    printf 'REACHABILITY_SUMMARY=%s\n' "$REACH_SUMMARY"

    printf '\n--- reachability JSON tail ---\n'
    tail -n 160 "$REACH_JSON" 2>/dev/null || true

    if [[ "$REACH_EXIT" -eq 0 ]]; then
        mark_fail "end-of-harness assert(false) unexpectedly verified"
    fi

    if [[ "$REACH_PARSE_EXIT" -ne 0 ]]; then
        mark_fail "end-of-harness reachability was not demonstrated"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 41
    fi

    printf 'T1_END_OF_HARNESS_REACHABILITY=PASS\n'

    section "00E.4 — BIT-FLIP ORACLE MUTATION CREATION"

    if [[ -e "$MUTANT_PROOF_DIR" ]]; then
        mark_fail "mutation proof directory already exists"
        return 50
    fi

    mkdir -p "$MUTANT_PROOF_DIR"

    python3 - \
        "$POSITIVE_HARNESS" \
        "$MUTANT_HARNESS" <<'PY'
import sys
from pathlib import Path

source_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])

text = source_path.read_text(encoding="utf-8")

needle = """    expected_byte =
        (uint8_t)(
            expected_low |
            (uint8_t)(expected_high << 4));

    __CPROVER_assert(
"""

replacement = """    expected_byte =
        (uint8_t)(
            expected_low |
            (uint8_t)(expected_high << 4));

    /*
     * Intentional semantic mutation:
     * flip the least-significant expected bit.
     */
    expected_byte =
        (uint8_t)(expected_byte ^ (uint8_t)1u);

    __CPROVER_assert(
"""

occurrences = text.count(needle)

if occurrences != 1:
    raise SystemExit(
        "expected exactly one mutation insertion point; "
        f"found {occurrences}"
    )

text = text.replace(needle, replacement)

text = text.replace(
    "POLYCOMP-D4-T1 positive semantic preflight.",
    "POLYCOMP-D4-T1 intentional bit-flip oracle mutation.",
    1,
)

target_path.write_text(text, encoding="utf-8")
PY

    MUTANT_CREATE_EXIT=$?

    if [[ "$MUTANT_CREATE_EXIT" -ne 0 ||
          ! -f "$MUTANT_HARNESS" ]]
    then
        mark_fail "could not create bit-flip mutation harness"
        return 51
    fi

    cat > "$MUTANT_MAKEFILE" <<MAKEFILE_EOF
# POLYCOMP-D4-T1 intentional bit-flip oracle mutation

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = ${MUTANT_HARNESS_NAME}

PROOF_UID = ${MUTANT_PROOF_NAME}

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

    printf 'MUTANT_PROOF_DIR=%s\n' "$MUTANT_PROOF_DIR"
    printf 'MUTANT_HARNESS=%s\n' "$MUTANT_HARNESS"

    printf 'MUTANT_HARNESS_SHA256=%s\n' \
        "$(sha256sum "$MUTANT_HARNESS" | awk '{print $1}')"

    printf 'MUTANT_MAKEFILE_SHA256=%s\n' \
        "$(sha256sum "$MUTANT_MAKEFILE" | awk '{print $1}')"

    printf '\n--- mutation excerpt ---\n'

    grep -n -B 8 -A 14 \
        'Intentional semantic mutation' \
        "$MUTANT_HARNESS" ||
        true

    if ! grep -Fq \
        'expected_byte ^ (uint8_t)1u' \
        "$MUTANT_HARNESS"
    then
        mark_fail "bit-flip mutation is absent"
        return 52
    fi

    TARGET_CALL_COUNT="$(
        grep -c \
            'mlk_poly_compress_d4_c(actual, &input)' \
            "$MUTANT_HARNESS" ||
        true
    )"

    printf 'MUTANT_TARGET_CALL_COUNT=%s\n' "$TARGET_CALL_COUNT"

    if [[ "$TARGET_CALL_COUNT" != "1" ]]; then
        mark_fail "mutant does not contain exactly one real target call"
        return 53
    fi

    if grep -Eq \
        '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)[[:space:]]*\)' \
        "$MUTANT_HARNESS"
    then
        mark_fail "mutant contains assume(false)"
        return 54
    fi

    printf 'MUTANT_STATIC_FIREWALL=PASS\n'

    section "00E.5 — MUTANT GOTO BUILD"

    (
        cd "$WORK_REPO/proofs/cbmc" || exit 70

        MLKEM_K=3 \
        ./run-cbmc-proofs.py \
            --summarize \
            --no-coverage \
            -j1 \
            -p "$MUTANT_PROOF_NAME" \
            --output-result-json "$MUTANT_RUNNER_JSON"
    ) > "$MUTANT_RUNNER_LOG" 2>&1

    MUTANT_RUNNER_EXIT=$?

    printf 'MUTANT_RUNNER_EXIT=%s\n' "$MUTANT_RUNNER_EXIT"
    printf 'MUTANT_RUNNER_LOG=%s\n' "$MUTANT_RUNNER_LOG"
    printf 'MUTANT_RUNNER_JSON=%s\n' "$MUTANT_RUNNER_JSON"

    printf '%s\n' \
        'MUTANT_RUNNER_NONZERO_IS_EXPECTED_IF_MUTATION_IS_DETECTED=YES'

    tail -n 160 "$MUTANT_RUNNER_LOG" 2>/dev/null || true

    if [[ ! -f "$MUTANT_GOTO" ]]; then
        mark_fail "starter kit did not produce the mutant GOTO binary"
        return 60
    fi

    printf 'MUTANT_GOTO=%s\n' "$MUTANT_GOTO"

    printf 'MUTANT_GOTO_SIZE=%s\n' \
        "$(stat -c '%s' "$MUTANT_GOTO" 2>/dev/null || printf unknown)"

    printf 'MUTANT_GOTO_SHA256=%s\n' \
        "$(sha256sum "$MUTANT_GOTO" | awk '{print $1}')"

    goto-instrument \
        --show-loops \
        "$MUTANT_GOTO" \
        > "$MUTANT_LOOPS" 2>&1

    MUTANT_LOOP_EXIT=$?

    printf 'MUTANT_LOOP_DISCOVERY_EXIT=%s\n' \
        "$MUTANT_LOOP_EXIT"

    printf 'MUTANT_LOOPS=%s\n' "$MUTANT_LOOPS"

    cat "$MUTANT_LOOPS"

    if [[ "$MUTANT_LOOP_EXIT" -ne 0 ]]; then
        mark_fail "could not display mutant loop IDs"
        return 61
    fi

    for expected_loop in \
        "Loop harness.0:" \
        "Loop harness.1:" \
        "Loop mlk_poly_compress_d4_c.0:" \
        "Loop mlk_poly_compress_d4_c.1:"
    do
        if ! grep -Fq \
            "$expected_loop" \
            "$MUTANT_LOOPS"
        then
            mark_fail "mutant loop map is missing $expected_loop"
        fi
    done

    MUTANT_LOOP_COUNT="$(
        grep -c '^Loop ' "$MUTANT_LOOPS" ||
        true
    )"

    printf 'MUTANT_TOTAL_LOOP_COUNT=%s\n' \
        "$MUTANT_LOOP_COUNT"

    if [[ "$MUTANT_LOOP_COUNT" != "4" ]]; then
        mark_fail "mutant loop inventory is not exactly four"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 62
    fi

    cbmc \
        "$MUTANT_GOTO" \
        --show-properties \
        > "$MUTANT_PROPERTIES" 2>&1

    printf 'MUTANT_PROPERTIES=%s\n' "$MUTANT_PROPERTIES"

    grep -n -B 5 -A 10 \
        'POLYCOMP-D4-T1' \
        "$MUTANT_PROPERTIES" \
        2>/dev/null ||
        true

    if ! grep -q \
        'harness.assertion.1' \
        "$MUTANT_PROPERTIES"
    then
        mark_fail "mutated semantic property is absent"
        return 63
    fi

    printf 'MUTANT_GOTO_PROPERTY_BINDING=PASS\n'

    section "00E.6 — DIRECT MUTATION DETECTION"

    printf 'MUTANT_COMMAND_BEGIN\n'

    printf 'cbmc %q \\\n' "$MUTANT_GOTO"
    printf '  --object-bits 8 \\\n'
    printf '  --slice-formula \\\n'
    printf '  --unwind 1 \\\n'
    printf '  --unwindset %q \\\n' "$UNWINDSET"
    printf '  --unwinding-assertions \\\n'
    printf '  --no-standard-checks \\\n'
    printf '  --trace --json-ui\n'

    printf 'MUTANT_COMMAND_END\n'

    cbmc \
        "$MUTANT_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$MUTANT_JSON" \
        2> "$MUTANT_STDERR"

    MUTANT_DIRECT_EXIT=$?

    printf 'MUTANT_DIRECT_CBMC_EXIT=%s\n' \
        "$MUTANT_DIRECT_EXIT"

    printf 'MUTANT_JSON=%s\n' "$MUTANT_JSON"
    printf 'MUTANT_STDERR=%s\n' "$MUTANT_STDERR"

    printf 'MUTANT_JSON_SHA256=%s\n' \
        "$(sha256sum "$MUTANT_JSON" | awk '{print $1}')"

    printf '\n--- mutant stderr ---\n'
    cat "$MUTANT_STDERR" 2>/dev/null || true

    python3 - \
        "$MUTANT_JSON" \
        "$MUTANT_SUMMARY" <<'PY'
import json
import sys
from pathlib import Path

result_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])

try:
    payload = json.loads(result_path.read_text(encoding="utf-8"))
except Exception as error:
    summary_path.write_text(
        "MUTATION_PARSE_STATUS=FAIL\n"
        f"MUTATION_PARSE_ERROR={type(error).__name__}: {error}\n",
        encoding="utf-8",
    )
    print(summary_path.read_text(encoding="utf-8"), end="")
    raise SystemExit(2)

entries = payload if isinstance(payload, list) else [payload]
results = []

for entry in entries:
    if (
        isinstance(entry, dict)
        and isinstance(entry.get("result"), list)
    ):
        results.extend(
            item for item in entry["result"]
            if isinstance(item, dict)
        )

semantic = [
    item for item in results
    if str(item.get("property", "")) == "harness.assertion.1"
]

mutation_detected = any(
    str(item.get("status", "")) == "FAILURE"
    for item in semantic
)

lines = [
    "MUTATION_PARSE_STATUS=PASS",
    f"PROPERTY_RESULT_COUNT={len(results)}",
    f"MUTATED_SEMANTIC_RESULT_COUNT={len(semantic)}",
]

for index, item in enumerate(semantic):
    lines.append(
        f"MUTATED_SEMANTIC_RESULT_{index}="
        f"{item.get('status', '')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

if mutation_detected:
    lines.append("BIT_FLIP_MUTATION_DETECTED=PASS")
else:
    lines.append("BIT_FLIP_MUTATION_DETECTED=FAIL")

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")

if not mutation_detected:
    raise SystemExit(1)
PY

    MUTANT_PARSE_EXIT=$?

    printf 'MUTATION_PARSE_EXIT=%s\n' \
        "$MUTANT_PARSE_EXIT"

    printf 'MUTATION_SUMMARY=%s\n' \
        "$MUTANT_SUMMARY"

    printf '\n--- mutant JSON tail ---\n'
    tail -n 180 "$MUTANT_JSON" 2>/dev/null || true

    if [[ "$MUTANT_DIRECT_EXIT" -eq 0 ]]; then
        mark_fail "intentional bit-flip mutation unexpectedly verified"
    fi

    if [[ "$MUTANT_PARSE_EXIT" -ne 0 ]]; then
        mark_fail "intentional bit-flip mutation was not detected"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 70
    fi

    printf 'T1_BIT_FLIP_MUTATION_DETECTION=PASS\n'

    section "00E.7 — POST-RUN SOURCE IMMUTABILITY"

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

    printf 'WORK_REPO_HEAD_AFTER=%s\n' "$(
        git -C "$WORK_REPO" rev-parse HEAD
    )"

    section "POLYCOMP-D4-00E VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_00E_STATUS=PASS\n'
        printf 'T1_SELECTED_LOCATION_COVERAGE=PASS\n'
        printf 'T1_END_OF_HARNESS_REACHABILITY=PASS\n'
        printf 'T1_BIT_FLIP_MUTATION_DETECTION=PASS\n'
        printf 'T1_THEOREM_STATUS=POSITIVE_NONVACUITY_MUTATION_PREFLIGHT_COMPLETE\n'
        printf 'NEXT_GATE=T1_FINAL_HARNESS_FREEZE_AND_EVIDENCE_PACKAGE\n'
    else
        printf 'POLYCOMP_D4_00E_STATUS=FAIL\n'
        printf 'T1_THEOREM_STATUS=NOT_FINAL\n'
        printf 'NEXT_GATE=CLASSIFY_COVERAGE_OR_MUTATION_FAILURE\n'
    fi

    printf 'COVERAGE_JSON=%s\n' "$COVERAGE_JSON"
    printf 'COVERAGE_SUMMARY=%s\n' "$COVERAGE_SUMMARY"

    printf 'REACHABILITY_GOTO=%s\n' "$REACH_GOTO"
    printf 'REACHABILITY_JSON=%s\n' "$REACH_JSON"
    printf 'REACHABILITY_SUMMARY=%s\n' "$REACH_SUMMARY"

    printf 'MUTANT_HARNESS=%s\n' "$MUTANT_HARNESS"
    printf 'MUTANT_GOTO=%s\n' "$MUTANT_GOTO"
    printf 'MUTANT_JSON=%s\n' "$MUTANT_JSON"
    printf 'MUTANT_SUMMARY=%s\n' "$MUTANT_SUMMARY"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-00E CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
