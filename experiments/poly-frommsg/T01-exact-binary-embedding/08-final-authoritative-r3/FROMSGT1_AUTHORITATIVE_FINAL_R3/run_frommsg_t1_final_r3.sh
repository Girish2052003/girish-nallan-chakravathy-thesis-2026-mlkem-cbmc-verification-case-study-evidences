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
R2_STAGE="$CAMPAIGN/FROMSGT1_AUTHORITATIVE_COMBINED_R2"
STAGE="$CAMPAIGN/FROMSGT1_AUTHORITATIVE_FINAL_R3"
PACKAGE_DIR="$CAMPAIGN/FROMSGT1_FINAL_PACKAGE"

mkdir -p "$STAGE" "$PACKAGE_DIR"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG="$STAGE/FROMSGT1_FINAL_R3_${STAMP}.txt"

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

BUILT_VARIANT_GOTO=""

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

    [ -f "$FILE" ] ||
        fatal "MISSING_${LABEL}=$FILE"

    ACTUAL="$(sha256sum "$FILE" | awk '{print $1}')"

    echo "EXPECTED_${LABEL}_SHA256=$EXPECTED"
    echo "ACTUAL_${LABEL}_SHA256=$ACTUAL"

    [ "$ACTUAL" = "$EXPECTED" ] ||
        fatal "${LABEL}_HASH_MISMATCH"
}

summarize_xml()
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

if not xml_path.exists():
    raise SystemExit("XML_MISSING")

if xml_path.stat().st_size == 0:
    raise SystemExit("XML_EMPTY")

root = ET.parse(xml_path).getroot()

status_node = root.find(".//cprover-status")
status = (
    status_node.text.strip()
    if status_node is not None and status_node.text
    else "NOT_FOUND"
)

results = root.findall(".//result")
counts = collections.Counter(
    result.attrib.get("status", "MISSING")
    for result in results
)

failure_properties = []
non_success_properties = []
unwind_failure_count = 0
harness_success = 0
harness_failure = 0

pairs = []

for result in results:
    prop = result.attrib.get("property", "UNKNOWN")
    result_status = result.attrib.get("status", "MISSING")
    description = result.findtext("description", default="").strip()

    pairs.append((prop, result_status))

    if result_status != "SUCCESS":
        non_success_properties.append(
            (prop, result_status, description)
        )

    if result_status == "FAILURE":
        failure_properties.append(prop)

        combined = f"{prop} {description}".lower()

        if "unwind" in combined or "unwinding" in combined:
            unwind_failure_count += 1

    if prop == "harness.assertion.1":
        if result_status == "SUCCESS":
            harness_success += 1

        if result_status == "FAILURE":
            harness_failure += 1

with summary_path.open("w") as out:
    print(f"CPROVER_STATUS={status}", file=out)
    print(f"RESULT_COUNT={len(results)}", file=out)

    print(
        f"SUCCESS_COUNT={counts.get('SUCCESS', 0)}",
        file=out,
    )

    print(
        f"FAILURE_COUNT={counts.get('FAILURE', 0)}",
        file=out,
    )

    print(
        f"ERROR_COUNT={counts.get('ERROR', 0)}",
        file=out,
    )

    print(
        f"NON_SUCCESS_COUNT={len(non_success_properties)}",
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
        f"UNWIND_FAILURE_COUNT={unwind_failure_count}",
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

    for index, (prop, result_status, description) in enumerate(
        non_success_properties,
        start=1,
    ):
        print(
            f"NON_SUCCESS_{index}_PROPERTY={prop}",
            file=out,
        )

        print(
            f"NON_SUCCESS_{index}_STATUS={result_status}",
            file=out,
        )

        print(
            f"NON_SUCCESS_{index}_DESCRIPTION={description}",
            file=out,
        )

with pairs_path.open("w") as out:
    for prop, result_status in sorted(pairs):
        print(f"{prop}|{result_status}", file=out)
PY
}

verify_success_xml()
{
    NAME="$1"
    XML="$2"

    SUMMARY="$STAGE/${NAME}.verified.summary.txt"
    PAIRS="$STAGE/${NAME}.verified.pairs.txt"

    summarize_xml "$XML" "$SUMMARY" "$PAIRS" ||
        fatal "${NAME}_XML_PARSE_FAILED"

    echo
    echo "===== VERIFY $NAME ====="
    cat "$SUMMARY"

    grep -qx 'CPROVER_STATUS=SUCCESS' "$SUMMARY" ||
        fatal "${NAME}_STATUS_NOT_SUCCESS"

    grep -qx 'FAILURE_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_HAS_FAILURE"

    grep -qx 'ERROR_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_HAS_ERROR"

    grep -qx 'NON_SUCCESS_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_HAS_NON_SUCCESS"

    grep -qx 'HARNESS_ASSERTION_SUCCESS_COUNT=1' "$SUMMARY" ||
        fatal "${NAME}_T1_ASSERTION_NOT_SUCCESS"
}

verify_low_bound_xml()
{
    NAME="$1"
    XML="$2"
    EXPECTED_PROPERTY="$3"

    SUMMARY="$STAGE/${NAME}.verified.summary.txt"
    PAIRS="$STAGE/${NAME}.verified.pairs.txt"

    summarize_xml "$XML" "$SUMMARY" "$PAIRS" ||
        fatal "${NAME}_XML_PARSE_FAILED"

    echo
    echo "===== VERIFY $NAME ====="
    cat "$SUMMARY"

    grep -qx 'CPROVER_STATUS=FAILURE' "$SUMMARY" ||
        fatal "${NAME}_STATUS_NOT_FAILURE"

    grep -qx 'FAILURE_COUNT=1' "$SUMMARY" ||
        fatal "${NAME}_EXPECTED_ONE_FAILURE"

    grep -qx 'ERROR_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_HAS_ERROR"

    grep -qx 'HARNESS_ASSERTION_SUCCESS_COUNT=1' "$SUMMARY" ||
        fatal "${NAME}_T1_ASSERTION_NOT_SUCCESS"

    grep -qx 'HARNESS_ASSERTION_FAILURE_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_T1_ASSERTION_FAILED"

    grep -qx 'UNWIND_FAILURE_COUNT=1' "$SUMMARY" ||
        fatal "${NAME}_EXPECTED_UNWIND_FAILURE"

    grep -qx \
        "FAILURE_PROPERTIES=$EXPECTED_PROPERTY" \
        "$SUMMARY" ||
        fatal "${NAME}_UNEXPECTED_FAILURE_PROPERTY"
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

    cbmc \
        --show-goto-functions \
        "$FINAL_GOTO" \
        >"$STAGE/${NAME}_goto_body.txt" \
        2>&1 ||
        fatal "${NAME}_SHOW_GOTO_FAILED"

    CONTRACT_COUNT="$(
        grep -c \
            '__CPROVER_contracts_write_set_havoc_object_whole' \
            "$STAGE/${NAME}_goto_body.txt" ||
        true
    )"

    echo "${NAME}_CONTRACT_HAVOC_COUNT=$CONTRACT_COUNT"

    [ "$CONTRACT_COUNT" -eq 0 ] ||
        fatal "${NAME}_CONTRACT_HAVOC_PRESENT"

    BUILT_VARIANT_GOTO="$FINAL_GOTO"
}

run_expected_witness()
{
    NAME="$1"
    HARNESS="$2"

    build_variant "$NAME" "$HARNESS"

    FINAL_GOTO="$BUILT_VARIANT_GOTO"
    XML="$STAGE/${NAME}.xml"
    ERR="$STAGE/${NAME}.stderr.txt"
    SUMMARY="$STAGE/${NAME}.summary.txt"
    PAIRS="$STAGE/${NAME}.pairs.txt"
    CMD="$STAGE/${NAME}.command.txt"

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
        "$FINAL_GOTO"
    )

    {
        printf '%q ' "${COMMAND[@]}"
        printf '\n'
    } >"$CMD"

    echo
    echo "============================================================"
    echo "EXPECTED_WITNESS=$NAME"
    echo "FINAL_GOTO=$FINAL_GOTO"
    echo "============================================================"

    set +e

    timeout \
        --signal=TERM \
        --kill-after=15s \
        900s \
        "${COMMAND[@]}" \
        >"$XML" \
        2>"$ERR"

    RC="$?"

    set -e

    echo "${NAME}_RETURN_CODE=$RC"
    echo "${NAME}_XML_SIZE=$(wc -c < "$XML")"
    echo "${NAME}_STDERR_SIZE=$(wc -c < "$ERR")"

    [ "$RC" -eq 10 ] ||
        fatal "${NAME}_EXPECTED_RETURN_10_GOT_$RC"

    summarize_xml "$XML" "$SUMMARY" "$PAIRS" ||
        fatal "${NAME}_XML_PARSE_FAILED"

    cat "$SUMMARY"

    grep -qx 'CPROVER_STATUS=FAILURE' "$SUMMARY" ||
        fatal "${NAME}_EXPECTED_FAILURE_STATUS"

    grep -qx 'FAILURE_COUNT=1' "$SUMMARY" ||
        fatal "${NAME}_EXPECTED_ONE_FAILURE"

    grep -qx 'ERROR_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_HAS_ERROR"

    grep -qx 'HARNESS_ASSERTION_FAILURE_COUNT=1' "$SUMMARY" ||
        fatal "${NAME}_EXPECTED_HARNESS_FAILURE"

    grep -qx 'HARNESS_ASSERTION_SUCCESS_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_UNEXPECTED_HARNESS_SUCCESS"

    grep -qx 'UNWIND_FAILURE_COUNT=0' "$SUMMARY" ||
        fatal "${NAME}_UNWIND_FAILURE"

    grep -qx \
        'FAILURE_PROPERTIES=harness.assertion.1' \
        "$SUMMARY" ||
        fatal "${NAME}_UNEXPECTED_FAILURE_PROPERTY"

    TRACE_COUNT="$(
        awk -F= \
            '/^GOTO_TRACE_COUNT=/{print $2}' \
            "$SUMMARY"
    )"

    [ "${TRACE_COUNT:-0}" -ge 1 ] ||
        fatal "${NAME}_TRACE_MISSING"

    sha256sum \
        "$HARNESS" \
        "$FINAL_GOTO" \
        "$XML" \
        "$ERR" \
        "$SUMMARY" \
        "$PAIRS" \
        "$CMD" \
        >"$STAGE/${NAME}.sha256"
}

run_final_proof()
{
    XML="$STAGE/FINAL_AUTHORITATIVE_PROOF.xml"
    ERR="$STAGE/FINAL_AUTHORITATIVE_PROOF.stderr.txt"
    SUMMARY="$STAGE/FINAL_AUTHORITATIVE_PROOF.summary.txt"
    PAIRS="$STAGE/FINAL_AUTHORITATIVE_PROOF.pairs.txt"
    CMD="$STAGE/FINAL_AUTHORITATIVE_PROOF.command.txt"

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

    echo "FINAL_PROOF_RETURN_CODE=$RC"

    [ "$RC" -eq 0 ] ||
        fatal "FINAL_PROOF_RETURN_CODE_$RC"

    summarize_xml "$XML" "$SUMMARY" "$PAIRS" ||
        fatal "FINAL_PROOF_XML_PARSE_FAILED"

    cat "$SUMMARY"

    grep -qx 'CPROVER_STATUS=SUCCESS' "$SUMMARY" ||
        fatal "FINAL_PROOF_NOT_SUCCESS"

    grep -qx 'RESULT_COUNT=36' "$SUMMARY" ||
        fatal "FINAL_PROOF_UNEXPECTED_PROPERTY_COUNT"

    grep -qx 'SUCCESS_COUNT=36' "$SUMMARY" ||
        fatal "FINAL_PROOF_NOT_ALL_SUCCESS"

    grep -qx 'NON_SUCCESS_COUNT=0' "$SUMMARY" ||
        fatal "FINAL_PROOF_HAS_NON_SUCCESS"

    grep -qx 'HARNESS_ASSERTION_SUCCESS_COUNT=1' "$SUMMARY" ||
        fatal "FINAL_PROOF_T1_NOT_SUCCESS"

    grep -qx 'UNWIND_FAILURE_COUNT=0' "$SUMMARY" ||
        fatal "FINAL_PROOF_UNWIND_FAILURE"

    sha256sum \
        "$XML" \
        "$ERR" \
        "$SUMMARY" \
        "$PAIRS" \
        "$CMD" \
        >"$STAGE/FINAL_AUTHORITATIVE_PROOF.sha256"
}

main()
{
    echo "============================================================"
    echo "FROMMSG-T1 — FINAL AUTHORITATIVE R3"
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
    echo "===== FROZEN SOURCE AND MODEL BINDING ====="

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
    echo "===== VERIFY EXISTING COMPLETE-BOUND EVIDENCE ====="

    verify_success_xml \
        "BOUND_EXACT" \
        "$R2_STAGE/BOUND_EXACT.xml"

    verify_low_bound_xml \
        "BOUND_INNER_TOO_LOW" \
        "$R2_STAGE/BOUND_INNER_TOO_LOW.xml" \
        "mlk_poly_frommsg.unwind.0"

    verify_low_bound_xml \
        "BOUND_OUTER_TOO_LOW" \
        "$R2_STAGE/BOUND_OUTER_TOO_LOW.xml" \
        "mlk_poly_frommsg.unwind.1"

    verify_success_xml \
        "AUTHORITATIVE_RUN1" \
        "$R2_STAGE/AUTHORITATIVE_RUN1.xml"

    verify_success_xml \
        "AUTHORITATIVE_RUN2" \
        "$R2_STAGE/AUTHORITATIVE_RUN2.xml"

    cmp -s \
        "$STAGE/AUTHORITATIVE_RUN1.verified.pairs.txt" \
        "$STAGE/AUTHORITATIVE_RUN2.verified.pairs.txt" ||
        fatal "REPEATED_RESULT_SET_MISMATCH"

    echo "REPEATED_RESULT_SET_MATCH=PASS"

    echo
    echo "===== RECORD ABORTED COVERAGE PATH ====="

    COVERAGE_ERR="$R2_STAGE/NONVACUITY.stderr.txt"
    COVERAGE_XML="$R2_STAGE/NONVACUITY.xml"

    [ -f "$COVERAGE_ERR" ] ||
        fatal "COVERAGE_STDERR_MISSING"

    [ -f "$COVERAGE_XML" ] ||
        fatal "COVERAGE_XML_MISSING"

    echo "COVERAGE_PATH_PRIOR_RETURN_CODE=134"

    echo "COVERAGE_STDERR_BEGIN"
    cat "$COVERAGE_ERR" || true
    echo "COVERAGE_STDERR_END"

    sha256sum \
        "$COVERAGE_ERR" \
        "$COVERAGE_XML" \
        >"$STAGE/COVERAGE_ABORT_ARTIFACTS.sha256"

    echo
    echo "===== FINAL EXACT-BOUND PROOF ====="

    run_final_proof

    echo
    echo "===== NON-VACUITY WITNESS: FUNCTION RETURN REACHABLE ====="

    REACH_END_HARNESS="$STAGE/REACH_END_harness.c"

    cat >"$REACH_END_HARNESS" <<'EOF'
#include <assert.h>
#include <stdint.h>

#include "compress.h"

#if MLKEM_N != 256
#error "FROMMSG-T1 requires MLKEM_N == 256"
#endif

#if MLKEM_INDCPA_MSGBYTES != 32
#error "FROMMSG-T1 requires 32 message bytes"
#endif

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];

  mlk_poly_frommsg(&r, msg);

  assert(0);
}
EOF

    run_expected_witness \
        "REACH_END" \
        "$REACH_END_HARNESS"

    echo
    echo "===== NON-VACUITY WITNESS: BIT ZERO REACHABLE ====="

    REACH_BIT0_HARNESS="$STAGE/REACH_BIT0_harness.c"

    cat >"$REACH_BIT0_HARNESS" <<'EOF'
#include <assert.h>
#include <stdint.h>

#include "compress.h"

void __CPROVER_assume(_Bool condition);

#if MLKEM_N != 256
#error "FROMMSG-T1 requires MLKEM_N == 256"
#endif

#if MLKEM_INDCPA_MSGBYTES != 32
#error "FROMMSG-T1 requires 32 message bytes"
#endif

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;
  uint8_t bit;

  mlk_poly_frommsg(&r, msg);

  bit = (uint8_t)((msg[(unsigned)k / 8u] >>
                   ((unsigned)k % 8u)) &
                  1u);

  __CPROVER_assume(bit == 0u);

  assert(0);
}
EOF

    run_expected_witness \
        "REACH_BIT0" \
        "$REACH_BIT0_HARNESS"

    echo
    echo "===== NON-VACUITY WITNESS: BIT ONE REACHABLE ====="

    REACH_BIT1_HARNESS="$STAGE/REACH_BIT1_harness.c"

    cat >"$REACH_BIT1_HARNESS" <<'EOF'
#include <assert.h>
#include <stdint.h>

#include "compress.h"

void __CPROVER_assume(_Bool condition);

#if MLKEM_N != 256
#error "FROMMSG-T1 requires MLKEM_N == 256"
#endif

#if MLKEM_INDCPA_MSGBYTES != 32
#error "FROMMSG-T1 requires 32 message bytes"
#endif

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;
  uint8_t bit;

  mlk_poly_frommsg(&r, msg);

  bit = (uint8_t)((msg[(unsigned)k / 8u] >>
                   ((unsigned)k % 8u)) &
                  1u);

  __CPROVER_assume(bit == 1u);

  assert(0);
}
EOF

    run_expected_witness \
        "REACH_BIT1" \
        "$REACH_BIT1_HARNESS"

    echo
    echo "===== MUTATION: FALSE ALWAYS-ZERO CLAIM ====="

    MUT_ZERO_HARNESS="$STAGE/MUTATION_ALWAYS_ZERO_harness.c"

    cat >"$MUT_ZERO_HARNESS" <<'EOF'
#include <assert.h>
#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;

  mlk_poly_frommsg(&r, msg);

  assert(r.coeffs[(unsigned)k] == 0);
}
EOF

    run_expected_witness \
        "MUTATION_ALWAYS_ZERO" \
        "$MUT_ZERO_HARNESS"

    echo
    echo "===== MUTATION: FALSE ALWAYS-HALF CLAIM ====="

    MUT_HALF_HARNESS="$STAGE/MUTATION_ALWAYS_HALF_harness.c"

    cat >"$MUT_HALF_HARNESS" <<'EOF'
#include <assert.h>
#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;

  mlk_poly_frommsg(&r, msg);

  assert(r.coeffs[(unsigned)k] == MLKEM_Q_HALF);
}
EOF

    run_expected_witness \
        "MUTATION_ALWAYS_HALF" \
        "$MUT_HALF_HARNESS"

    echo
    echo "===== FINAL WORKTREE IMMUTABILITY ====="

    FINAL_STATUS="$(git -C "$WORKTREE" status --porcelain)"

    echo "FINAL_WORKTREE_STATUS_BEGIN"
    printf '%s\n' "$FINAL_STATUS"
    echo "FINAL_WORKTREE_STATUS_END"

    [ "$FINAL_STATUS" = "$INITIAL_STATUS" ] ||
        fatal "WORKTREE_STATUS_CHANGED"

    echo
    echo "============================================================"
    echo "FROMMSG-T1 FINAL AUTHORITATIVE R3 COMPLETE"
    echo "EXACT_BOUND_PROOF=PASS"
    echo "LOW_BOUND_CALIBRATION=PASS"
    echo "REPEATED_PROOF=PASS"
    echo "FUNCTION_RETURN_REACHABLE=PASS"
    echo "BIT_ZERO_REACHABLE=PASS"
    echo "BIT_ONE_REACHABLE=PASS"
    echo "MUTATION_ALWAYS_ZERO_REJECTED=PASS"
    echo "MUTATION_ALWAYS_HALF_REJECTED=PASS"
    echo "CONTRACT_HAVOC_PRESENT=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "============================================================"
}

main 2>&1 | tee "$LOG"
MAIN_RC="${PIPESTATUS[0]}"

sha256sum "$LOG" >"${LOG}.sha256"

echo
echo "MAIN_RETURN_CODE=$MAIN_RC"
echo "LOG_FILE=$LOG"
echo "LOG_HASH_FILE=${LOG}.sha256"

if [ "$MAIN_RC" -ne 0 ]; then
    echo "FINAL_PACKET=NOT_CREATED"
    exit "$MAIN_RC"
fi

MANIFEST="$PACKAGE_DIR/FROMSGT1_FINAL_MANIFEST_${STAMP}.txt"
PACKET="$PACKAGE_DIR/FROMSGT1_AUTHORITATIVE_FINAL_${STAMP}.tar.gz"

(
    cd "$CAMPAIGN"

    find \
        FROMSGT1P0_DIRECT_BODY_PREFLIGHT \
        FROMSGT1P0R2_ANNOTATION_DISABLED_MODEL \
        FROMSGT1_AUTHORITATIVE_COMBINED_R2 \
        FROMSGT1_AUTHORITATIVE_FINAL_R3 \
        -type f \
        -print0 |
        sort -z |
        xargs -0 sha256sum
) >"$MANIFEST"

tar -czf "$PACKET" \
    -C "$CAMPAIGN" \
    FROMSGT1P0_DIRECT_BODY_PREFLIGHT \
    FROMSGT1P0R2_ANNOTATION_DISABLED_MODEL \
    FROMSGT1_AUTHORITATIVE_COMBINED_R2 \
    FROMSGT1_AUTHORITATIVE_FINAL_R3 \
    -C "$PACKAGE_DIR" \
    "$(basename "$MANIFEST")"

sha256sum "$MANIFEST" "$PACKET"

echo
echo "FINAL_PACKET=$PACKET"
echo "FINAL_PACKET_SIZE=$(wc -c < "$PACKET")"
echo "UPLOAD_REQUIRED=YES"
echo "UPLOAD_ONLY_THIS_FILE=$PACKET"

exit 0
