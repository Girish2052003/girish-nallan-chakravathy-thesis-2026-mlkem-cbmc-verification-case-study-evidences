#!/usr/bin/env bash
set -uo pipefail

WORKTREE="$HOME/THESIS-2026/_cbmc_work/mlkem-native_frommsg_native_20260724T131455Z"
SOURCE="$WORKTREE/mlkem/src/compress.c"
HEADER="$WORKTREE/mlkem/src/compress.h"
CBMC_ROOT="$WORKTREE/proofs/cbmc"
NATIVE_PROOF="$CBMC_ROOT/poly_frommsg"

CAMPAIGN="$HOME/THESIS-2026/mlk_poly_frommsg_cleanroom"
P0_STAGE="$CAMPAIGN/FROMSGT1P0_DIRECT_BODY_PREFLIGHT"
P0R2_STAGE="$CAMPAIGN/FROMSGT1P0R2_ANNOTATION_DISABLED_MODEL"
STAGE="$CAMPAIGN/FROMSGT1_AUTHORITATIVE_COMBINED_R2"

mkdir -p "$STAGE"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="$STAGE/FROMSGT1_AUTHORITATIVE_${STAMP}.txt"

PROOF_HARNESS="$P0_STAGE/frommsg_t1_exact_binary_embedding_harness.c"
SOURCE_GOTO="$P0R2_STAGE/frommsg_t1_source.goto"
DIRECT_GOTO="$P0R2_STAGE/frommsg_t1_direct_body.goto"

UNWINDSET="mlk_poly_frommsg.0:9,mlk_poly_frommsg.1:33,mlk_poly_frommsg.2:2"

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_SOURCE_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_HEADER_SHA256="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"
EXPECTED_HARNESS_SHA256="657afc885742ee6bbef421dbf336c07ed0b40f95a92ff251ffb56122dc285266"
EXPECTED_SOURCE_GOTO_SHA256="80fa8ed5df96a8df6dc9ae5cc1d47ca62993eb45b206e5b3cf371fc36ff7dd15"
EXPECTED_DIRECT_GOTO_SHA256="7c2de4baa9e780e1c438fb2fd7931299d430fdbad9d4a92e2f8eaffc3e4d6b52"

fatal()
{
    echo "FATAL=$1"
    exit 1
}

expect_hash()
{
    FILE="$1"
    EXPECTED="$2"
    LABEL="$3"

    [ -f "$FILE" ] || fatal "MISSING_${LABEL}=$FILE"

    ACTUAL="$(sha256sum "$FILE" | awk '{print $1}')"

    echo "EXPECTED_${LABEL}_SHA256=$EXPECTED"
    echo "ACTUAL_${LABEL}_SHA256=$ACTUAL"

    [ "$ACTUAL" = "$EXPECTED" ] ||
        fatal "${LABEL}_HASH_MISMATCH"
}

parse_proof_xml()
{
    XML="$1"
    SUMMARY="$2"
    PAIRS="$3"

    python3 - "$XML" "$SUMMARY" "$PAIRS" <<'PY'
import collections
import pathlib
import sys
import xml.etree.ElementTree as ET

xml_path = pathlib.Path(sys.argv[1])
summary_path = pathlib.Path(sys.argv[2])
pairs_path = pathlib.Path(sys.argv[3])

root = ET.parse(xml_path).getroot()

status_node = root.find(".//cprover-status")
cprover_status = (
    status_node.text.strip()
    if status_node is not None and status_node.text
    else "NOT_FOUND"
)

results = root.findall(".//result")
counts = collections.Counter(
    result.attrib.get("status", "MISSING")
    for result in results
)

pairs = []
non_success = []
unwind_results = []
unwind_non_success = []
harness_success = 0
harness_failure = 0
failure_properties = []

for result in results:
    prop = result.attrib.get("property", "UNKNOWN")
    status = result.attrib.get("status", "MISSING")
    description = result.findtext("description", default="").strip()

    pairs.append((prop, status))

    if status != "SUCCESS":
        non_success.append((prop, status, description))

    combined = f"{prop} {description}".lower()

    if "unwind" in combined:
        unwind_results.append((prop, status))

        if status != "SUCCESS":
            unwind_non_success.append((prop, status))

    if prop == "harness.assertion.1":
        if status == "SUCCESS":
            harness_success += 1
        if status == "FAILURE":
            harness_failure += 1

    if status == "FAILURE":
        failure_properties.append(prop)

with summary_path.open("w") as out:
    print(f"CPROVER_STATUS={cprover_status}", file=out)
    print(f"RESULT_COUNT={len(results)}", file=out)

    for status, count in sorted(counts.items()):
        print(f"RESULT_STATUS_{status}={count}", file=out)

    print(f"NON_SUCCESS_COUNT={len(non_success)}", file=out)
    print(f"FAILURE_COUNT={counts.get('FAILURE', 0)}", file=out)
    print(f"ERROR_COUNT={counts.get('ERROR', 0)}", file=out)
    print(f"UNWIND_RESULT_COUNT={len(unwind_results)}", file=out)
    print(
        f"UNWIND_NON_SUCCESS_COUNT={len(unwind_non_success)}",
        file=out,
    )
    print(
        f"HARNESS_ASSERTION_SUCCESS_COUNT={harness_success}",
        file=out,
    )
    print(
        f"HARNESS_ASSERTION_FAILURE_COUNT={harness_failure}",
        file=out,
    )
    print(
        "FAILURE_PROPERTIES="
        + ",".join(failure_properties),
        file=out,
    )
    print(
        f"GOTO_TRACE_COUNT={len(root.findall('.//goto_trace'))}",
        file=out,
    )

    for index, (prop, status, description) in enumerate(
        non_success,
        start=1,
    ):
        print(f"NON_SUCCESS_{index}_PROPERTY={prop}", file=out)
        print(f"NON_SUCCESS_{index}_STATUS={status}", file=out)
        print(
            f"NON_SUCCESS_{index}_DESCRIPTION={description}",
            file=out,
        )

with pairs_path.open("w") as out:
    for prop, status in sorted(pairs):
        print(f"{prop}|{status}", file=out)
PY
}

run_authoritative_proof()
{
    NAME="$1"

    XML="$STAGE/${NAME}.xml"
    ERR="$STAGE/${NAME}.stderr.txt"
    CMD="$STAGE/${NAME}.command.txt"
    META="$STAGE/${NAME}.meta.txt"
    SUMMARY="$STAGE/${NAME}.summary.txt"
    PAIRS="$STAGE/${NAME}.pairs.txt"

    COMMAND=(
        cbmc
        --flush
        --object-bits 9
        --slice-formula
        --validate-goto-model
        --validate-ssa-equation
        --conversion-check
        --float-overflow-check
        --nan-check
        --pointer-overflow-check
        --unsigned-overflow-check
        --unwindset "$UNWINDSET"
        --unwinding-assertions
        --trace
        --xml-ui
        "$DIRECT_GOTO"
    )

    {
        printf '%q ' "${COMMAND[@]}"
        printf '\n'
    } >"$CMD"

    echo
    echo "============================================================"
    echo "PROOF_RUN=$NAME"
    echo "UNWINDSET=$UNWINDSET"
    echo "COMMAND=$(cat "$CMD")"
    echo "============================================================"

    START="$(date +%s)"

    set +e
    timeout \
        --signal=TERM \
        --kill-after=15s \
        1800s \
        "${COMMAND[@]}" \
        >"$XML" \
        2>"$ERR"
    RC="$?"
    set -e

    END="$(date +%s)"

    {
        echo "PROOF_RUN=$NAME"
        echo "RETURN_CODE=$RC"
        echo "ELAPSED_SECONDS=$((END - START))"
        echo "UNWINDSET=$UNWINDSET"
        echo "XML_FILE=$XML"
        echo "STDERR_FILE=$ERR"
    } >"$META"

    echo "RETURN_CODE=$RC"
    echo "ELAPSED_SECONDS=$((END - START))"
    echo "XML_SIZE=$(wc -c < "$XML")"
    echo "STDERR_SIZE=$(wc -c < "$ERR")"

    [ "$RC" -eq 0 ] ||
        fatal "${NAME}_RETURN_CODE_$RC"

    parse_proof_xml "$XML" "$SUMMARY" "$PAIRS" ||
        fatal "${NAME}_XML_PARSE_FAILED"

    cat "$SUMMARY"

    grep -qx 'CPROVER_STATUS=SUCCESS' "$SUMMARY" ||
        fatal "${NAME}_CPROVER_NOT_SUCCESS"

    grep -qx 'NON_SUCCESS_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_HAS_NON_SUCCESS_PROPERTIES"

    grep -qx 'UNWIND_NON_SUCCESS_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_UNWIND_FAILURE"

    grep -qx 'HARNESS_ASSERTION_SUCCESS_COUNT=1' "$SUMMARY" ||
        fatal "${NAME}_HARNESS_ASSERTION_NOT_PROVED"

    UNWIND_COUNT="$(
        awk -F= '/^UNWIND_RESULT_COUNT=/{print $2}' "$SUMMARY"
    )"

    echo "${NAME}_UNWIND_RESULT_COUNT_REPORTED=${UNWIND_COUNT:-0}"
    echo "${NAME}_UNWIND_COMPLETENESS=ESTABLISHED_BY_BOUND_CALIBRATION"

    sha256sum \
        "$XML" \
        "$ERR" \
        "$CMD" \
        "$META" \
        "$SUMMARY" \
        "$PAIRS" \
        >"$STAGE/${NAME}.sha256"
}

build_variant()
{
    NAME="$1"
    HARNESS="$2"

    HARNESS_GOTO="$STAGE/${NAME}_harness.goto"
    LINKED_GOTO="$STAGE/${NAME}_linked.goto"
    FINAL_GOTO="$STAGE/${NAME}.goto"

    COMMON_FLAGS=(
        -Wall
        -Werror
        --native-compiler
        gcc
        -I"$STAGE"
        -I"$NATIVE_PROOF"
        -I"$CBMC_ROOT"
        -I"$WORKTREE/mlkem"
        -I"$WORKTREE/mlkem/src"
        -I"$WORKTREE/mlkem/src/fips202"
        -DCBMC_OBJECT_BITS=9
        '-DCBMC_MAX_OBJECT_SIZE=(SIZE_MAX>>(CBMC_OBJECT_BITS+1))'
        '-DMLK_CONFIG_FILE="mlkem_native_config_cbmc.h"'
        -DMLK_CONFIG_PARAMETER_SET=768
        -Dstatic=
        -DMLK_INLINE=
        -DMLK_ALWAYS_INLINE=
    )

    goto-cc \
        "${COMMON_FLAGS[@]}" \
        "$HARNESS" \
        -o "$HARNESS_GOTO" ||
        fatal "${NAME}_HARNESS_COMPILE_FAILED"

    goto-cc \
        --function harness \
        "$HARNESS_GOTO" \
        "$SOURCE_GOTO" \
        -Wall \
        -Werror \
        -o "$LINKED_GOTO" ||
        fatal "${NAME}_LINK_FAILED"

    goto-instrument \
        --drop-unused-functions \
        "$LINKED_GOTO" \
        "$FINAL_GOTO" \
        >"$STAGE/${NAME}_prune.stdout.txt" \
        2>"$STAGE/${NAME}_prune.stderr.txt" ||
        fatal "${NAME}_PRUNE_FAILED"

    cbmc \
        --validate-goto-model \
        --show-properties \
        "$FINAL_GOTO" \
        >"$STAGE/${NAME}_properties.txt" \
        2>"$STAGE/${NAME}_validation.stderr.txt" ||
        fatal "${NAME}_MODEL_VALIDATION_FAILED"

    CONTRACT_COUNT="$(
        cbmc --show-goto-functions "$FINAL_GOTO" 2>&1 |
        grep -c '__CPROVER_contracts_write_set_havoc_object_whole' ||
        true
    )"

    echo "${NAME}_CONTRACT_HAVOC_COUNT=$CONTRACT_COUNT" >&2

    [ "$CONTRACT_COUNT" -eq 0 ] ||
        fatal "${NAME}_CONTRACT_HAVOC_PRESENT"

    BUILT_VARIANT_GOTO="$FINAL_GOTO"
}

parse_coverage_xml()
{
    XML="$1"
    SUMMARY="$2"

    python3 - "$XML" "$SUMMARY" <<'PY'
import collections
import pathlib
import sys
import xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()
summary = pathlib.Path(sys.argv[2])

def local(tag):
    return tag.rsplit("}", 1)[-1]

goals = [
    node
    for node in root.iter()
    if local(node.tag).lower() == "goal"
    and "status" in node.attrib
]

statuses = collections.Counter(
    node.attrib.get("status", "MISSING")
    for node in goals
)

with summary.open("w") as out:
    print(f"GOAL_COUNT={len(goals)}", file=out)
    print(
        f"SATISFIED_COUNT={statuses.get('SATISFIED', 0)}",
        file=out,
    )
    print(
        f"UNSATISFIED_COUNT={statuses.get('UNSATISFIED', 0)}",
        file=out,
    )
    print(
        f"FAILED_COUNT={statuses.get('FAILED', 0)}",
        file=out,
    )

    for index, goal in enumerate(goals, start=1):
        goal_id = (
            goal.attrib.get("id")
            or goal.attrib.get("goal")
            or "UNKNOWN"
        )
        status = goal.attrib.get("status", "MISSING")
        description = " ".join(
            "".join(goal.itertext()).split()
        )

        print(f"GOAL_{index}_ID={goal_id}", file=out)
        print(f"GOAL_{index}_STATUS={status}", file=out)
        print(
            f"GOAL_{index}_DESCRIPTION={description}",
            file=out,
        )
PY
}

run_coverage_gate()
{
    HARNESS="$STAGE/frommsg_t1_nonvacuity_harness.c"

    cat >"$HARNESS" <<'EOF'
#include <stdint.h>

#include "compress.h"

void __CPROVER_cover(_Bool condition);

#if MLKEM_N != 256
#error "FROMMSG-T1 coverage requires MLKEM_N == 256"
#endif

#if MLKEM_INDCPA_MSGBYTES != 32
#error "FROMMSG-T1 coverage requires 32 message bytes"
#endif

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;
  uint8_t bit;
  int16_t expected;

  mlk_poly_frommsg(&r, msg);

  bit = (uint8_t)((msg[(unsigned)k / 8u] >>
                   ((unsigned)k % 8u)) &
                  1u);

  expected = (bit != 0u ? MLKEM_Q_HALF : 0);

  __CPROVER_cover(1);
  __CPROVER_cover(bit == 0u);
  __CPROVER_cover(bit == 1u);
  __CPROVER_cover(r.coeffs[(unsigned)k] == expected);
}
EOF

    build_variant "NONVACUITY" "$HARNESS"
    FINAL_GOTO="$BUILT_VARIANT_GOTO"

    XML="$STAGE/NONVACUITY.xml"
    ERR="$STAGE/NONVACUITY.stderr.txt"
    SUMMARY="$STAGE/NONVACUITY.summary.txt"

    echo
    echo "============================================================"
    echo "NONVACUITY_COVERAGE_GATE"
    echo "FINAL_GOTO=$FINAL_GOTO"
    echo "============================================================"

    set +e
    timeout \
        --signal=TERM \
        --kill-after=15s \
        900s \
        cbmc \
        --flush \
        --object-bits 9 \
        --no-standard-checks \
        --no-unwinding-assertions \
        --unwindset "$UNWINDSET" \
        --cover cover \
        --show-test-suite \
        --xml-ui \
        "$FINAL_GOTO" \
        >"$XML" \
        2>"$ERR"
    RC="$?"
    set -e

    echo "NONVACUITY_RETURN_CODE=$RC"

    [ "$RC" -eq 0 ] ||
        fatal "NONVACUITY_RETURN_CODE_$RC"

    parse_coverage_xml "$XML" "$SUMMARY" ||
        fatal "NONVACUITY_XML_PARSE_FAILED"

    cat "$SUMMARY"

    grep -qx 'GOAL_COUNT=4' "$SUMMARY" ||
        fatal "NONVACUITY_EXPECTED_FOUR_GOALS"

    grep -qx 'SATISFIED_COUNT=4' "$SUMMARY" ||
        fatal "NONVACUITY_NOT_ALL_GOALS_SATISFIED"

    grep -qx 'UNSATISFIED_COUNT=0' "$SUMMARY" ||
        fatal "NONVACUITY_UNSATISFIED_GOAL"

    grep -qx 'FAILED_COUNT=0' "$SUMMARY" ||
        fatal "NONVACUITY_FAILED_GOAL"

    sha256sum \
        "$HARNESS" \
        "$FINAL_GOTO" \
        "$XML" \
        "$ERR" \
        "$SUMMARY" \
        >"$STAGE/NONVACUITY.sha256"
}

run_mutation_gate()
{
    NAME="$1"
    ASSERTION="$2"

    HARNESS="$STAGE/${NAME}_harness.c"

    cat >"$HARNESS" <<EOF
#include <assert.h>
#include <stdint.h>

#include "compress.h"

#if MLKEM_N != 256
#error "FROMMSG-T1 mutation requires MLKEM_N == 256"
#endif

#if MLKEM_INDCPA_MSGBYTES != 32
#error "FROMMSG-T1 mutation requires 32 message bytes"
#endif

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;

  mlk_poly_frommsg(&r, msg);

  assert($ASSERTION);
}
EOF

    build_variant "$NAME" "$HARNESS"
    FINAL_GOTO="$BUILT_VARIANT_GOTO"

    XML="$STAGE/${NAME}.xml"
    ERR="$STAGE/${NAME}.stderr.txt"
    SUMMARY="$STAGE/${NAME}.summary.txt"
    PAIRS="$STAGE/${NAME}.pairs.txt"

    echo
    echo "============================================================"
    echo "MUTATION_GATE=$NAME"
    echo "FINAL_GOTO=$FINAL_GOTO"
    echo "============================================================"

    set +e
    timeout \
        --signal=TERM \
        --kill-after=15s \
        900s \
        cbmc \
        --flush \
        --object-bits 9 \
        --slice-formula \
        --validate-goto-model \
        --validate-ssa-equation \
        --conversion-check \
        --pointer-overflow-check \
        --unsigned-overflow-check \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --trace \
        --xml-ui \
        "$FINAL_GOTO" \
        >"$XML" \
        2>"$ERR"
    RC="$?"
    set -e

    echo "${NAME}_RETURN_CODE=$RC"

    [ "$RC" -eq 10 ] ||
        fatal "${NAME}_EXPECTED_RETURN_10_GOT_$RC"

    parse_proof_xml "$XML" "$SUMMARY" "$PAIRS" ||
        fatal "${NAME}_XML_PARSE_FAILED"

    cat "$SUMMARY"

    grep -qx 'CPROVER_STATUS=FAILURE' "$SUMMARY" ||
        fatal "${NAME}_EXPECTED_FAILURE_STATUS"

    grep -qx 'HARNESS_ASSERTION_FAILURE_COUNT=1' "$SUMMARY" ||
        fatal "${NAME}_HARNESS_MUTATION_DID_NOT_FAIL"

    grep -qx 'UNWIND_NON_SUCCESS_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_UNWIND_FAILURE_INVALIDATES_MUTATION"

    TRACE_COUNT="$(
        awk -F= '/^GOTO_TRACE_COUNT=/{print $2}' "$SUMMARY"
    )"

    [ "${TRACE_COUNT:-0}" -ge 1 ] ||
        fatal "${NAME}_EXPECTED_COUNTEREXAMPLE_TRACE"

    sha256sum \
        "$HARNESS" \
        "$FINAL_GOTO" \
        "$XML" \
        "$ERR" \
        "$SUMMARY" \
        "$PAIRS" \
        >"$STAGE/${NAME}.sha256"
}

(
    echo "============================================================"
    echo "FROMMSG-T1 — AUTHORITATIVE COMBINED CAMPAIGN"
    echo "============================================================"
    echo "UTC_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "WORKTREE=$WORKTREE"
    echo "STAGE=$STAGE"
    echo "UNWINDSET=$UNWINDSET"
    echo

    for TOOL in \
        git \
        gcc \
        goto-cc \
        goto-instrument \
        cbmc \
        timeout \
        sha256sum \
        python3 \
        tar
    do
        command -v "$TOOL" >/dev/null 2>&1 ||
            fatal "MISSING_TOOL_$TOOL"
    done

    echo "===== TOOL IDENTITY ====="

    gcc --version | head -n 1
    goto-cc --version
    goto-instrument --version
    cbmc --version

    echo
    echo "===== FROZEN INPUT BINDING ====="

    ACTUAL_COMMIT="$(git -C "$WORKTREE" rev-parse HEAD)"

    echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
    echo "ACTUAL_COMMIT=$ACTUAL_COMMIT"

    [ "$ACTUAL_COMMIT" = "$EXPECTED_COMMIT" ] ||
        fatal "COMMIT_MISMATCH"

    expect_hash \
        "$SOURCE" \
        "$EXPECTED_SOURCE_SHA256" \
        "SOURCE"

    expect_hash \
        "$HEADER" \
        "$EXPECTED_HEADER_SHA256" \
        "HEADER"

    expect_hash \
        "$PROOF_HARNESS" \
        "$EXPECTED_HARNESS_SHA256" \
        "HARNESS"

    expect_hash \
        "$SOURCE_GOTO" \
        "$EXPECTED_SOURCE_GOTO_SHA256" \
        "SOURCE_GOTO"

    expect_hash \
        "$DIRECT_GOTO" \
        "$EXPECTED_DIRECT_GOTO_SHA256" \
        "DIRECT_GOTO"

    INITIAL_STATUS="$(git -C "$WORKTREE" status --porcelain)"

    echo "INITIAL_WORKTREE_STATUS_BEGIN"
    printf '%s\n' "$INITIAL_STATUS"
    echo "INITIAL_WORKTREE_STATUS_END"

    [ -z "$INITIAL_STATUS" ] ||
        fatal "WORKTREE_NOT_CLEAN"

    echo
    echo "===== GATE T1-G1 — COMPLETE AUTHORITATIVE PROOF ====="

    run_authoritative_proof "AUTHORITATIVE_RUN1"

    echo
    echo "===== GATE T1-G2 — INDEPENDENT REPEAT ====="

    run_authoritative_proof "AUTHORITATIVE_RUN2"

    cmp -s \
        "$STAGE/AUTHORITATIVE_RUN1.pairs.txt" \
        "$STAGE/AUTHORITATIVE_RUN2.pairs.txt" ||
        fatal "REPEATED_PROPERTY_RESULTS_DIFFER"

    echo "REPEATED_PROPERTY_RESULT_SET_MATCH=PASS"

    echo
    echo "===== GATE T1-G3 — NON-VACUITY ====="

    run_coverage_gate

    echo
    echo "===== GATE T1-G4 — MUTATION SENSITIVITY ====="

    run_mutation_gate \
        "MUTATION_ALWAYS_ZERO" \
        'r.coeffs[(unsigned)k] == 0'

    run_mutation_gate \
        "MUTATION_ALWAYS_HALF" \
        'r.coeffs[(unsigned)k] == MLKEM_Q_HALF'

    echo
    echo "===== GATE T1-G5 — IMMUTABILITY ====="

    FINAL_STATUS="$(git -C "$WORKTREE" status --porcelain)"

    echo "FINAL_WORKTREE_STATUS_BEGIN"
    printf '%s\n' "$FINAL_STATUS"
    echo "FINAL_WORKTREE_STATUS_END"

    [ "$FINAL_STATUS" = "$INITIAL_STATUS" ] ||
        fatal "WORKTREE_STATUS_CHANGED"

    echo
    echo "============================================================"
    echo "FROMMSG-T1 AUTHORITATIVE COMBINED CAMPAIGN COMPLETE"
    echo "COMPLETE_UNWIND_PROOF=PASS"
    echo "REPEATED_PROOF=PASS"
    echo "NONVACUITY=PASS"
    echo "BIT_ZERO_REACHABLE=PASS"
    echo "BIT_ONE_REACHABLE=PASS"
    echo "MUTATION_ALWAYS_ZERO_REJECTED=PASS"
    echo "MUTATION_ALWAYS_HALF_REJECTED=PASS"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "============================================================"

) 2>&1 | tee "$LOG"

CAPTURE_EXIT="${PIPESTATUS[0]}"

sha256sum "$LOG" >"${LOG}.sha256"

echo
echo "CAPTURE_EXIT=$CAPTURE_EXIT"
echo "CAPTURE_FILE=$LOG"
echo "CAPTURE_HASH_FILE=${LOG}.sha256"

if [ "$CAPTURE_EXIT" -eq 0 ]; then
    MANIFEST="$STAGE/FROMSGT1_SHA256SUMS_${STAMP}.txt"
    PACKET="$STAGE/FROMSGT1_AUTHORITATIVE_PACKET_${STAMP}.tar.gz"

    find "$STAGE" \
        -maxdepth 1 \
        -type f \
        ! -name '*.tar.gz' \
        ! -name "$(basename "$MANIFEST")" \
        -print0 |
        sort -z |
        xargs -0 sha256sum \
        >"$MANIFEST"

    tar -czf "$PACKET" \
        -C "$STAGE" \
        --exclude="$(basename "$PACKET")" \
        .

    sha256sum "$MANIFEST" "$PACKET"

    echo
    echo "FINAL_PACKET=$PACKET"
    echo "FINAL_PACKET_SIZE=$(wc -c < "$PACKET")"
    echo "UPLOAD_REQUIRED_AFTER_SUCCESS=YES"
else
    echo "FINAL_PACKET=NOT_CREATED"
fi

exit "$CAPTURE_EXIT"
