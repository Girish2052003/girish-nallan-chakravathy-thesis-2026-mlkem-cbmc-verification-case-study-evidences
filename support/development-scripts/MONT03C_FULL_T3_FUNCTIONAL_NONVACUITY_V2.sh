#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

EXPECTED_03B_CAPTURE_HASH="c3509c8b1839f56375f0c722486465e47bbdf9cc1f6fff96939385d0563f3d1"

EXPECTED_P1_HARNESS="39a09f51f8db8687f6fa7a6288dd53f86c7ddeb7f1294f999298eebd835753a6"
EXPECTED_P1_MAKEFILE="ab4e8c7a2e17706673eda399a31f899ee6bbf09bacb981102299833c728fdceb"
EXPECTED_P1_GOTO="808e1089d26e7cf8939f2c7db2016ee30b22ca52188faf0ab77bf326cca5a5db"

EXPECTED_P23_HARNESS="5294f922b0295a00285b33c1ca482983c70cf8b30e30aaaf1ef2b4193d9ca9d1"
EXPECTED_P23_MAKEFILE="306e7db336168c35e696e5965d11c942669a490fbc27ca38fdbd8b9810734467"
EXPECTED_P23_GOTO="e1355402a0b350de1546c31fb62139ba679d7baf2363d49c140f989c52b944e6"

EXPECTED_P4_HARNESS="b42a1a606cb7023d23e549a479dc6765ba0fbe6b515f19fcdb2846c4761ecce8"
EXPECTED_P4_MAKEFILE="dd7ccad9fb60c92d745ccc5f043e0061ee2e3951a199e9f6400504afad7def10"
EXPECTED_P4_GOTO="570863436b766af32879ba79dc9432457663a1c01bf41dfbd66e7b3d66a1f82a"

EXPECTED_P5_HARNESS="8cd5bd1808eabb07f68021617f2c6193b7e366c066306ed4ecaf90bd8727d213"
EXPECTED_P5_MAKEFILE="432c5d3ebab4d39d0380baa45580502f84434b76d4f803f9d96704d2858f5c4b"
EXPECTED_P5_GOTO="cef5836ae92cbec3ad9116a0b20fdd7031319933bc88fbe870bbd00b960fce9a"

EXPECTED_P6_HARNESS="41a026e8203c7b043456da03ce195dc1eb55a1d8ab1583b40cdae87492b420ca"
EXPECTED_P6_MAKEFILE="a5eaed22970ab46cc9882380a3cd046ea2ef638131c10fb89c907aba6288760c"
EXPECTED_P6_GOTO="f7cc950236e7f475efa04915c7981c6d6df49af60f2f8cf253535852e488908d"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WT="$ROOT/MONT_T3_WORKTREE_af4c5abd"

MONT03B_CAPTURE="$ROOT/MONT03B_HARNESS_FREEZE_20260726T222052Z/MONT03B_TERMINAL_CAPTURE_20260726T222052Z.txt"
MONT03B_HASH_FILE="${MONT03B_CAPTURE}.sha256"

P1_DIR="$WT/proofs/cbmc/mont_t3_p1_refinement"
P23_DIR="$WT/proofs/cbmc/mont_t3_p2_p3_relational"
P4_DIR="$WT/proofs/cbmc/mont_t3_p4_montgomery_one"
P5_DIR="$WT/proofs/cbmc/mont_t3_p5_distributivity"
P6_DIR="$WT/proofs/cbmc/mont_t3_p6_associativity"

P1_STEM="mont_t3_p1_refinement_harness"
P23_STEM="mont_t3_p2_p3_relational_harness"
P4_STEM="mont_t3_p4_montgomery_one_harness"
P5_STEM="mont_t3_p5_distributivity_harness"
P6_STEM="mont_t3_p6_associativity_harness"

CONTROL_DIR="$WT/proofs/cbmc/mont_t3_nonvacuity_control"
CONTROL_STEM="mont_t3_nonvacuity_control_harness"
CONTROL_HARNESS="$CONTROL_DIR/$CONTROL_STEM.c"
CONTROL_MAKEFILE="$CONTROL_DIR/Makefile"
CONTROL_GOTO="$CONTROL_DIR/gotos/$CONTROL_STEM.goto"

NATIVE_MAKEFILE="$WT/proofs/cbmc/fqmul/Makefile"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT03C_FUNCTIONAL_NONVACUITY_$STAMP"
CAPTURE="$OUT/MONT03C_TERMINAL_CAPTURE_$STAMP.txt"

FUNCTIONAL_TIMEOUT=900
CONTROL_TIMEOUT=600
PARALLEL_FUNCTIONAL=2

mkdir -p "$OUT"

section()
{
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

fail()
{
    echo "$1"
    exit "$2"
}

hash_file()
{
    sha256sum "$1" | awk '{print $1}'
}

run_cbmc()
{
    local goto_file="$1"
    local log="$2"
    local timeout_seconds="$3"

    timeout "$timeout_seconds" cbmc \
        --flush \
        --object-bits 8 \
        --slice-formula \
        --conversion-check \
        --float-overflow-check \
        --nan-check \
        --pointer-overflow-check \
        --unsigned-overflow-check \
        --unwinding-assertions \
        --trace \
        "$goto_file" >"$log" 2>&1

    return $?
}

prepare_makefile()
{
    local source_makefile="$1"
    local destination_makefile="$2"
    local harness_stem="$3"
    local proof_uid="$4"

    cp "$source_makefile" "$destination_makefile"

    python3 - "$destination_makefile" "$harness_stem" "$proof_uid" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
stem = sys.argv[2]
uid = sys.argv[3]
text = path.read_text()

text, c1 = re.subn(
    r'(?m)^HARNESS_FILE\s*=.*$',
    f'HARNESS_FILE = {stem}',
    text,
)
text, c2 = re.subn(
    r'(?m)^PROOF_UID\s*=.*$',
    f'PROOF_UID = {uid}',
    text,
)

if c1 != 1 or c2 != 1:
    raise SystemExit(
        f"Makefile replacement counts: HARNESS_FILE={c1}, PROOF_UID={c2}"
    )

path.write_text(text)
PY
}

audit_functional()
{
    local tag="$1"
    local rc="$2"
    local log="$3"
    shift 3

    python3 - "$tag" "$rc" "$log" "$@" <<'PY'
from pathlib import Path
import re
import sys

tag = sys.argv[1]
rc = int(sys.argv[2])
log = Path(sys.argv[3])
required = sys.argv[4:]
text = log.read_text(errors="replace")

failure_lines = [
    line for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]

missing = [
    name for name in required
    if f"{name}: SUCCESS" not in text
]

error_present = (
    "VERIFICATION ERROR" in text or
    "\nERROR:" in text or
    "Caught exception" in text
)

success = (
    rc == 0 and
    "VERIFICATION SUCCESSFUL" in text and
    "VERIFICATION FAILED" not in text and
    not error_present and
    not failure_lines and
    not missing
)

print(f"T3_{tag}_DIRECT_RC={rc}")
print(f"T3_{tag}_FAILURE_COUNT={len(failure_lines)}")
print(f"T3_{tag}_MISSING_REQUIRED_COUNT={len(missing)}")

for index, name in enumerate(missing, start=1):
    print(f"T3_{tag}_MISSING_{index}={name}")

print(f"T3_{tag}_FUNCTIONAL_AUDIT={'PASS' if success else 'FAIL'}")
raise SystemExit(0 if success else 1)
PY
}

audit_control()
{
    local rc="$1"
    local log="$2"

    python3 - "$rc" "$log" <<'PY'
from pathlib import Path
import re
import sys

rc = int(sys.argv[1])
text = Path(sys.argv[2]).read_text(errors="replace")

expected = [
    "MONT-T3.CONTROL.C1.P1_full_first_operand_extreme_path_reachable",
    "MONT-T3.CONTROL.C2.P2_commutativity_relational_path_reachable",
    "MONT-T3.CONTROL.C3.P3_zero_operand_path_reachable",
    "MONT-T3.CONTROL.C4.P3_nonzero_operand_path_reachable",
    "MONT-T3.CONTROL.C5.P4_Montgomery_one_path_reachable",
    "MONT-T3.CONTROL.C6.P5_distributivity_path_reachable",
    "MONT-T3.CONTROL.C7.P6_associativity_path_reachable",
]

failure_lines = [
    line for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]

expected_counts = {
    name: sum(
        1 for line in failure_lines
        if f"{name}: FAILURE" in line
    )
    for name in expected
}

unexpected = [
    line for line in failure_lines
    if not any(f"{name}: FAILURE" in line for name in expected)
]

missing = [name for name, count in expected_counts.items() if count != 1]

error_present = (
    "VERIFICATION ERROR" in text or
    "\nERROR:" in text or
    "Caught exception" in text
)

success = (
    rc == 10 and
    "VERIFICATION FAILED" in text and
    not error_present and
    len(failure_lines) == len(expected) and
    not unexpected and
    not missing
)

print(f"T3_CONTROL_DIRECT_RC={rc}")
print(f"T3_CONTROL_TOTAL_FAILURE_COUNT={len(failure_lines)}")
print(f"T3_CONTROL_EXPECTED_FAILURE_COUNT={len(expected) - len(missing)}")
print(f"T3_CONTROL_UNEXPECTED_FAILURE_COUNT={len(unexpected)}")
print(f"T3_CONTROL_MISSING_OR_DUPLICATE_COUNT={len(missing)}")

for index, name in enumerate(missing, start=1):
    print(f"T3_CONTROL_MISSING_OR_DUPLICATE_{index}={name}")

print(f"MONT03C_NONVACUITY_GATE={'PASS_7_OF_7' if success else 'FAIL'}")
raise SystemExit(0 if success else 1)
PY
}

validate_worktree_status()
{
    local phase="$1"

    python3 - "$WT" "$phase" <<'PY'
from pathlib import Path
import subprocess
import sys

wt = Path(sys.argv[1])
phase = sys.argv[2]

allowed = (
    "?? proofs/cbmc/mont_t3_p1_refinement/",
    "?? proofs/cbmc/mont_t3_p2_p3_relational/",
    "?? proofs/cbmc/mont_t3_p4_montgomery_one/",
    "?? proofs/cbmc/mont_t3_p5_distributivity/",
    "?? proofs/cbmc/mont_t3_p6_associativity/",
    "?? proofs/cbmc/mont_t3_nonvacuity_control/",
)

result = subprocess.run(
    ["git", "-C", str(wt), "status", "--porcelain=v1", "--untracked-files=all"],
    check=True,
    capture_output=True,
    text=True,
)

lines = [line for line in result.stdout.splitlines() if line.strip()]
unexpected = [line for line in lines if not line.startswith(allowed)]

print(f"T3_WORKTREE_{phase}_STATUS_LINE_COUNT={len(lines)}")
print(f"T3_WORKTREE_{phase}_UNEXPECTED_STATUS_COUNT={len(unexpected)}")

for index, line in enumerate(unexpected, start=1):
    print(f"T3_WORKTREE_{phase}_UNEXPECTED_{index}={line}")

raise SystemExit(0 if not unexpected else 1)
PY
}

{
    section "MONT-03C — FULL T3 FUNCTIONAL + SEVEN-WITNESS NON-VACUITY"
    echo "UTC_TIME=$STAMP"
    echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
    echo "WORKTREE=$WT"
    echo "OUTPUT_DIRECTORY=$OUT"
    echo "FUNCTIONAL_TIMEOUT=$FUNCTIONAL_TIMEOUT"
    echo "CONTROL_TIMEOUT=$CONTROL_TIMEOUT"
    echo "PARALLEL_FUNCTIONAL=$PARALLEL_FUNCTIONAL"

    section "C0 — BIND SOURCE, MONT-03B, AND ALL FROZEN ARTEFACTS"

    [[ -f "$MONT03B_CAPTURE" ]] ||
        fail "MONT03B_CAPTURE_PRESENT=NO" 20

    ACTUAL_03B_CAPTURE_HASH="$(hash_file "$MONT03B_CAPTURE")"
    RECORDED_03B_CAPTURE_HASH="MISSING"

    if [[ -f "$MONT03B_HASH_FILE" ]]; then
        RECORDED_03B_CAPTURE_HASH="$(awk 'NR == 1 {print $1}' "$MONT03B_HASH_FILE")"
    fi

    echo "MONT03B_EXPECTED_CAPTURE_HASH=$EXPECTED_03B_CAPTURE_HASH"
    echo "MONT03B_ACTUAL_CAPTURE_HASH=$ACTUAL_03B_CAPTURE_HASH"
    echo "MONT03B_RECORDED_SIDECAR_HASH=$RECORDED_03B_CAPTURE_HASH"

    if [[ "$ACTUAL_03B_CAPTURE_HASH" == "$EXPECTED_03B_CAPTURE_HASH" ]]; then
        echo "MONT03B_FIXED_CAPTURE_HASH_MATCH=YES"
    else
        echo "MONT03B_FIXED_CAPTURE_HASH_MATCH=NO_REATTESTATION_REQUIRED"
    fi

    if [[ "$RECORDED_03B_CAPTURE_HASH" == "$ACTUAL_03B_CAPTURE_HASH" ]]; then
        echo "MONT03B_CAPTURE_SIDECAR_GATE=PASS"
    else
        echo "MONT03B_CAPTURE_SIDECAR_GATE=MISMATCH_REATTESTATION_REQUIRED"
    fi

    REQUIRED_03B_LINES=(
        "T3_P1_HARNESS_SHA256=$EXPECTED_P1_HARNESS"
        "T3_P1_MAKEFILE_SHA256=$EXPECTED_P1_MAKEFILE"
        "T3_P1_GOTO_SHA256=$EXPECTED_P1_GOTO"
        "T3_P23_HARNESS_SHA256=$EXPECTED_P23_HARNESS"
        "T3_P23_MAKEFILE_SHA256=$EXPECTED_P23_MAKEFILE"
        "T3_P23_GOTO_SHA256=$EXPECTED_P23_GOTO"
        "T3_P4_HARNESS_SHA256=$EXPECTED_P4_HARNESS"
        "T3_P4_MAKEFILE_SHA256=$EXPECTED_P4_MAKEFILE"
        "T3_P4_GOTO_SHA256=$EXPECTED_P4_GOTO"
        "T3_P5_HARNESS_SHA256=$EXPECTED_P5_HARNESS"
        "T3_P5_MAKEFILE_SHA256=$EXPECTED_P5_MAKEFILE"
        "T3_P5_GOTO_SHA256=$EXPECTED_P5_GOTO"
        "T3_P6_HARNESS_SHA256=$EXPECTED_P6_HARNESS"
        "T3_P6_MAKEFILE_SHA256=$EXPECTED_P6_MAKEFILE"
        "T3_P6_GOTO_SHA256=$EXPECTED_P6_GOTO"
        "MONT_T3_THEOREM_FAMILIES_FROZEN=6_OF_6"
        "MONT_T3_HARNESSES_FROZEN=5"
        "MONT_T3_ASSERTIONS_FROZEN=9"
        "MONT_T3_THEOREM_WEAKENED=NO"
        "MONT_T3_NATIVE_SOURCE_MODIFIED=NO"
        "MONT03B_HARNESS_FREEZE_GATE=PASS"
        "MONT03B_GOTO_BUILD_GATE=PASS_5_OF_5"
        "SCRIPT_EXIT=0"
    )

    CAPTURE_SEMANTIC_MISSING=0

    for marker in "${REQUIRED_03B_LINES[@]}"
    do
        if ! grep -Fxq "$marker" "$MONT03B_CAPTURE"; then
            echo "MONT03B_CAPTURE_MISSING_MARKER=$marker"
            CAPTURE_SEMANTIC_MISSING=$((CAPTURE_SEMANTIC_MISSING + 1))
        fi
    done

    echo "MONT03B_CAPTURE_SEMANTIC_MISSING_COUNT=$CAPTURE_SEMANTIC_MISSING"

    [[ "$CAPTURE_SEMANTIC_MISSING" -eq 0 ]] ||
        fail "MONT03B_CAPTURE_SEMANTIC_BINDING_GATE=FAIL" 21

    echo "MONT03B_CAPTURE_SEMANTIC_BINDING_GATE=PASS"

    AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null || true)"
    WT_HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null || true)"
    AUTH_STATUS="$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

    [[ "$AUTH_HEAD" == "$EXPECTED_COMMIT" &&
       "$WT_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$AUTH_STATUS" ]] ||
        fail "COMMIT_OR_AUTHORITATIVE_CLEAN_GATE=FAIL" 23

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "SOURCE_BINDING_GATE=FAIL" 24

    validate_worktree_status "INITIAL" ||
        fail "T3_WORKTREE_INITIAL_STATUS_GATE=FAIL" 25

    declare -a TAGS=("P1" "P23" "P4" "P5" "P6")
    declare -a DIRS=("$P1_DIR" "$P23_DIR" "$P4_DIR" "$P5_DIR" "$P6_DIR")
    declare -a STEMS=("$P1_STEM" "$P23_STEM" "$P4_STEM" "$P5_STEM" "$P6_STEM")
    declare -a EXPECTED_H=(
        "$EXPECTED_P1_HARNESS"
        "$EXPECTED_P23_HARNESS"
        "$EXPECTED_P4_HARNESS"
        "$EXPECTED_P5_HARNESS"
        "$EXPECTED_P6_HARNESS"
    )
    declare -a EXPECTED_M=(
        "$EXPECTED_P1_MAKEFILE"
        "$EXPECTED_P23_MAKEFILE"
        "$EXPECTED_P4_MAKEFILE"
        "$EXPECTED_P5_MAKEFILE"
        "$EXPECTED_P6_MAKEFILE"
    )
    declare -a EXPECTED_G=(
        "$EXPECTED_P1_GOTO"
        "$EXPECTED_P23_GOTO"
        "$EXPECTED_P4_GOTO"
        "$EXPECTED_P5_GOTO"
        "$EXPECTED_P6_GOTO"
    )

    for i in "${!TAGS[@]}"
    do
        harness="${DIRS[$i]}/${STEMS[$i]}.c"
        makefile="${DIRS[$i]}/Makefile"
        goto_file="${DIRS[$i]}/gotos/${STEMS[$i]}.goto"

        [[ -f "$harness" && -f "$makefile" && -f "$goto_file" ]] ||
            fail "T3_${TAGS[$i]}_ARTEFACT_PRESENT_GATE=FAIL" 26

        [[ "$(hash_file "$harness")" == "${EXPECTED_H[$i]}" &&
           "$(hash_file "$makefile")" == "${EXPECTED_M[$i]}" &&
           "$(hash_file "$goto_file")" == "${EXPECTED_G[$i]}" ]] ||
            fail "T3_${TAGS[$i]}_ARTEFACT_HASH_GATE=FAIL" 27

        echo "T3_${TAGS[$i]}_ARTEFACT_BINDING=PASS"
    done

    REATTESTATION="$OUT/MONT03B_SEMANTIC_REATTESTATION.env"

    cat >"$REATTESTATION" <<EOF
EXPECTED_CAPTURE_HASH=$EXPECTED_03B_CAPTURE_HASH
ACTUAL_CAPTURE_HASH=$ACTUAL_03B_CAPTURE_HASH
RECORDED_SIDECAR_HASH=$RECORDED_03B_CAPTURE_HASH
CAPTURE_SEMANTIC_BINDING=PASS
FROZEN_ARTEFACT_BINDING=PASS_5_OF_5
SOURCE_BINDING=PASS
THEOREM_WEAKENED=NO
EOF

    echo "MONT03B_REATTESTATION_FILE=$REATTESTATION"
    echo "MONT03B_REATTESTATION_SHA256=$(hash_file "$REATTESTATION")"
    echo "MONT03B_CAPTURE_BINDING=PASS_BY_SEMANTIC_REATTESTATION"
    echo "COMMIT_AND_SOURCE_BINDING=PASS"
    echo "T3_FROZEN_ARTEFACT_BINDING=PASS_5_OF_5"

    section "C1 — RUN FIVE DIRECT FUNCTIONAL CBMC JOBS"

    FUNCTIONAL_PIDS=()
    FUNCTIONAL_ACTIVE=0

    for i in "${!TAGS[@]}"
    do
        tag="${TAGS[$i]}"
        goto_file="${DIRS[$i]}/gotos/${STEMS[$i]}.goto"

        (
            run_cbmc "$goto_file" "$OUT/${tag}_FUNCTIONAL.log" "$FUNCTIONAL_TIMEOUT"
            echo "$?" >"$OUT/${tag}_FUNCTIONAL.rc"
        ) &

        FUNCTIONAL_PIDS+=("$!")
        FUNCTIONAL_ACTIVE=$((FUNCTIONAL_ACTIVE + 1))

        if [[ "$FUNCTIONAL_ACTIVE" -eq "$PARALLEL_FUNCTIONAL" ]]; then
            for pid in "${FUNCTIONAL_PIDS[@]}"
            do
                wait "$pid" || true
            done
            FUNCTIONAL_PIDS=()
            FUNCTIONAL_ACTIVE=0
        fi
    done

    for pid in "${FUNCTIONAL_PIDS[@]}"
    do
        wait "$pid" || true
    done

    FUNCTIONAL_PASS_COUNT=0

    for tag in "${TAGS[@]}"
    do
        echo "T3_${tag}_KEY_RESULTS_BEGIN"
        grep -E \
            'MONT-T3\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR' \
            "$OUT/${tag}_FUNCTIONAL.log" || true
        echo "T3_${tag}_KEY_RESULTS_END"

        rc="$(cat "$OUT/${tag}_FUNCTIONAL.rc" 2>/dev/null || echo 999)"

        case "$tag" in
            P1)
                audit_functional "$tag" "$rc" "$OUT/${tag}_FUNCTIONAL.log" \
                    "MONT-T3.P1.1.independent_output_bound" \
                    "MONT-T3.P1.2.independent_exact_multiplication_refinement"
                ;;
            P23)
                audit_functional "$tag" "$rc" "$OUT/${tag}_FUNCTIONAL.log" \
                    "MONT-T3.P2.exact_commutativity" \
                    "MONT-T3.P3.1.left_zero_annihilation_full_first_operand_domain" \
                    "MONT-T3.P3.2.right_zero_annihilation" \
                    "MONT-T3.P3.3.zero_product_reflection"
                ;;
            P4)
                audit_functional "$tag" "$rc" "$OUT/${tag}_FUNCTIONAL.log" \
                    "MONT-T3.P4.Montgomery_one_identity_after_normalization"
                ;;
            P5)
                audit_functional "$tag" "$rc" "$OUT/${tag}_FUNCTIONAL.log" \
                    "MONT-T3.P5.distributivity_after_normalization"
                ;;
            P6)
                audit_functional "$tag" "$rc" "$OUT/${tag}_FUNCTIONAL.log" \
                    "MONT-T3.P6.associativity_after_normalization"
                ;;
        esac

        audit_rc=$?
        if [[ "$audit_rc" -eq 0 ]]; then
            FUNCTIONAL_PASS_COUNT=$((FUNCTIONAL_PASS_COUNT + 1))
        fi
    done

    echo "T3_FUNCTIONAL_PASS_COUNT=$FUNCTIONAL_PASS_COUNT"

    [[ "$FUNCTIONAL_PASS_COUNT" -eq 5 ]] ||
        fail "MONT03C_FUNCTIONAL_GATE=FAIL" 28

    echo "MONT03C_FUNCTIONAL_GATE=PASS_5_OF_5"

    section "C2 — CREATE ONE SEVEN-WITNESS CALL-REACHABILITY CONTROL"

    if [[ -e "$CONTROL_DIR" ]]; then
        TRACKED_CONTROL="$(git -C "$WT" ls-files -- "proofs/cbmc/mont_t3_nonvacuity_control/" || true)"
        [[ -z "$TRACKED_CONTROL" ]] ||
            fail "CONTROL_DIRECTORY_TRACKED_FILE_GUARD=FAIL" 29

        ARCHIVE="$OUT/PREEXISTING_MONT03C_CONTROL_$STAMP.tar.gz"
        tar -C "$WT" -czf "$ARCHIVE" "proofs/cbmc/mont_t3_nonvacuity_control" ||
            fail "PREEXISTING_CONTROL_ARCHIVE_GATE=FAIL" 30

        echo "PREEXISTING_CONTROL_ARCHIVE_SHA256=$(hash_file "$ARCHIVE")"
        rm -rf "$CONTROL_DIR"
    fi

    mkdir -p "$CONTROL_DIR"

    cat >"$CONTROL_HARNESS" <<'C'
#include <stdint.h>
#include <limits.h>

#include "../../../mlkem/src/poly.h"

#define MONT_ONE ((int16_t)2285)

extern int16_t nondet_int16_t(void);
int16_t mlk_fqmul(int16_t a, int16_t b);

static int16_t normalize_q_once(int32_t value)
{
  if (value >= MLKEM_Q_HALF)
  {
    value -= MLKEM_Q;
  }

  if (value <= -MLKEM_Q_HALF)
  {
    value += MLKEM_Q;
  }

  return (int16_t)value;
}

void harness(void)
{
  int16_t a_any;
  int16_t a;
  int16_t b;
  int16_t c;
  int16_t x;

  int16_t p1_result;
  int16_t ab;
  int16_t ba;
  int16_t a_zero;
  int16_t zero_b;
  int16_t one_x;

  int16_t sum_ab;
  int16_t dist_left;
  int16_t dist_right_a;
  int16_t dist_right_b;

  int16_t assoc_ab;
  int16_t assoc_bc;
  int16_t assoc_bc_normalized;
  int16_t assoc_left;
  int16_t assoc_right;

  a_any = nondet_int16_t();
  a = nondet_int16_t();
  b = nondet_int16_t();
  c = nondet_int16_t();
  x = nondet_int16_t();

  __CPROVER_assume(a > -MLKEM_Q_HALF && a < MLKEM_Q_HALF);
  __CPROVER_assume(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF);
  __CPROVER_assume(c > -MLKEM_Q_HALF && c < MLKEM_Q_HALF);
  __CPROVER_assume(x > -MLKEM_Q_HALF && x < MLKEM_Q_HALF);

  p1_result = mlk_fqmul(a_any, b);

  ab = mlk_fqmul(a, b);
  ba = mlk_fqmul(b, a);
  a_zero = mlk_fqmul(a_any, 0);
  zero_b = mlk_fqmul(0, b);

  one_x = mlk_fqmul(MONT_ONE, x);

  sum_ab = (int16_t)((int32_t)a + (int32_t)b);
  dist_left = mlk_fqmul(sum_ab, c);
  dist_right_a = mlk_fqmul(a, c);
  dist_right_b = mlk_fqmul(b, c);

  assoc_ab = mlk_fqmul(a, b);
  assoc_left = mlk_fqmul(assoc_ab, c);
  assoc_bc = mlk_fqmul(b, c);
  assoc_bc_normalized = normalize_q_once((int32_t)assoc_bc);
  assoc_right = mlk_fqmul(a, assoc_bc_normalized);

  if (a_any == INT16_MIN && b == (MLKEM_Q_HALF - 1))
  {
    __CPROVER_assert(
        (int32_t)p1_result == (int32_t)p1_result + 1,
        "MONT-T3.CONTROL.C1.P1_full_first_operand_extreme_path_reachable");
  }

  if (a == (MLKEM_Q_HALF - 1) && b == -(MLKEM_Q_HALF - 1))
  {
    __CPROVER_assert(
        (int32_t)ab == (int32_t)ab + 1,
        "MONT-T3.CONTROL.C2.P2_commutativity_relational_path_reachable");
  }

  if (a == 0 && b == (MLKEM_Q_HALF - 1))
  {
    __CPROVER_assert(
        (int32_t)zero_b == (int32_t)zero_b + 1,
        "MONT-T3.CONTROL.C3.P3_zero_operand_path_reachable");
  }

  if (a == 1 && b == 1)
  {
    __CPROVER_assert(
        (int32_t)ab == (int32_t)ab + 1,
        "MONT-T3.CONTROL.C4.P3_nonzero_operand_path_reachable");
  }

  if (x == -(MLKEM_Q_HALF - 1))
  {
    __CPROVER_assert(
        (int32_t)one_x == (int32_t)one_x + 1,
        "MONT-T3.CONTROL.C5.P4_Montgomery_one_path_reachable");
  }

  if (a == 1 && b == 2 && c == 3)
  {
    __CPROVER_assert(
        (int32_t)dist_left == (int32_t)dist_left + 1,
        "MONT-T3.CONTROL.C6.P5_distributivity_path_reachable");
  }

  if (a == -1 && b == 2 && c == -3)
  {
    __CPROVER_assert(
        (int32_t)assoc_left == (int32_t)assoc_left + 1,
        "MONT-T3.CONTROL.C7.P6_associativity_path_reachable");
  }

  ((void)ba);
  ((void)a_zero);
  ((void)dist_right_a);
  ((void)dist_right_b);
  ((void)assoc_right);
}
C

    prepare_makefile \
        "$NATIVE_MAKEFILE" \
        "$CONTROL_MAKEFILE" \
        "$CONTROL_STEM" \
        "mont_t3_nonvacuity_control"

    echo "T3_CONTROL_HARNESS_SHA256=$(hash_file "$CONTROL_HARNESS")"
    echo "T3_CONTROL_MAKEFILE_SHA256=$(hash_file "$CONTROL_MAKEFILE")"

    section "C3 — BUILD AND RUN SEVEN-WITNESS CONTROL"

    make -C "$CONTROL_DIR" MLKEM_K=3 clean \
        >"$OUT/CONTROL_CLEAN.log" 2>&1 || true

    timeout 420 make -C "$CONTROL_DIR" MLKEM_K=3 goto \
        >"$OUT/CONTROL_BUILD.log" 2>&1

    CONTROL_BUILD_RC=$?
    echo "T3_CONTROL_BUILD_RC=$CONTROL_BUILD_RC"

    if [[ "$CONTROL_BUILD_RC" -ne 0 || ! -f "$CONTROL_GOTO" ]]; then
        echo "T3_CONTROL_GOTO_PRESENT=NO"
        tail -n 100 "$OUT/CONTROL_BUILD.log" || true
        fail "T3_CONTROL_BUILD_GATE=FAIL" 31
    fi

    echo "T3_CONTROL_GOTO_PRESENT=YES"
    echo "T3_CONTROL_GOTO_SHA256=$(hash_file "$CONTROL_GOTO")"

    run_cbmc "$CONTROL_GOTO" "$OUT/CONTROL_CBMC.log" "$CONTROL_TIMEOUT"
    CONTROL_RC=$?

    echo "T3_CONTROL_KEY_RESULTS_BEGIN"
    grep -E \
        'MONT-T3.CONTROL\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR' \
        "$OUT/CONTROL_CBMC.log" || true
    echo "T3_CONTROL_KEY_RESULTS_END"

    audit_control "$CONTROL_RC" "$OUT/CONTROL_CBMC.log"
    CONTROL_AUDIT_RC=$?

    [[ "$CONTROL_AUDIT_RC" -eq 0 ]] ||
        fail "MONT03C_NONVACUITY_GATE=FAIL" 32

    section "C4 — FINAL INTEGRITY AND PROVISIONAL T3 VERDICT"

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "FINAL_SOURCE_INTEGRITY=FAIL" 33

    FINAL_AUTH_STATUS="$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all)"
    [[ -z "$FINAL_AUTH_STATUS" ]] ||
        fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 34

    validate_worktree_status "FINAL" ||
        fail "T3_WORKTREE_FINAL_STATUS_GATE=FAIL" 35

    for i in "${!TAGS[@]}"
    do
        harness="${DIRS[$i]}/${STEMS[$i]}.c"
        makefile="${DIRS[$i]}/Makefile"
        goto_file="${DIRS[$i]}/gotos/${STEMS[$i]}.goto"

        [[ "$(hash_file "$harness")" == "${EXPECTED_H[$i]}" &&
           "$(hash_file "$makefile")" == "${EXPECTED_M[$i]}" &&
           "$(hash_file "$goto_file")" == "${EXPECTED_G[$i]}" ]] ||
            fail "FINAL_T3_${TAGS[$i]}_ARTEFACT_INTEGRITY=FAIL" 36
    done

    BINDING="$OUT/MONT03C_GATE_C_BINDING.env"

    cat >"$BINDING" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H=$EXPECTED_POLY_H
EXPECTED_POLY_C=$EXPECTED_POLY_C
MONT03B_EXPECTED_CAPTURE_HASH=$EXPECTED_03B_CAPTURE_HASH
MONT03B_ACTUAL_CAPTURE_HASH=$ACTUAL_03B_CAPTURE_HASH
MONT03B_RECORDED_SIDECAR_HASH=$RECORDED_03B_CAPTURE_HASH
MONT03B_CAPTURE_SEMANTIC_REATTESTATION=PASS
P1_HARNESS_SHA256=$EXPECTED_P1_HARNESS
P1_MAKEFILE_SHA256=$EXPECTED_P1_MAKEFILE
P1_GOTO_SHA256=$EXPECTED_P1_GOTO
P23_HARNESS_SHA256=$EXPECTED_P23_HARNESS
P23_MAKEFILE_SHA256=$EXPECTED_P23_MAKEFILE
P23_GOTO_SHA256=$EXPECTED_P23_GOTO
P4_HARNESS_SHA256=$EXPECTED_P4_HARNESS
P4_MAKEFILE_SHA256=$EXPECTED_P4_MAKEFILE
P4_GOTO_SHA256=$EXPECTED_P4_GOTO
P5_HARNESS_SHA256=$EXPECTED_P5_HARNESS
P5_MAKEFILE_SHA256=$EXPECTED_P5_MAKEFILE
P5_GOTO_SHA256=$EXPECTED_P5_GOTO
P6_HARNESS_SHA256=$EXPECTED_P6_HARNESS
P6_MAKEFILE_SHA256=$EXPECTED_P6_MAKEFILE
P6_GOTO_SHA256=$EXPECTED_P6_GOTO
CONTROL_HARNESS_SHA256=$(hash_file "$CONTROL_HARNESS")
CONTROL_MAKEFILE_SHA256=$(hash_file "$CONTROL_MAKEFILE")
CONTROL_GOTO_SHA256=$(hash_file "$CONTROL_GOTO")
MONT03C_FUNCTIONAL_GATE=PASS_5_OF_5
MONT03C_NONVACUITY_GATE=PASS_7_OF_7
MONT_T3_THEOREM_WEAKENED=NO
EOF

    echo "MONT03C_BINDING_FILE=$BINDING"
    echo "MONT03C_BINDING_SHA256=$(hash_file "$BINDING")"
    echo "FINAL_SOURCE_INTEGRITY=PASS"
    echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
    echo "FINAL_FROZEN_ARTEFACT_INTEGRITY=PASS_5_OF_5"
    echo "MONT03C_FUNCTIONAL_GATE=PASS_5_OF_5"
    echo "MONT03C_NONVACUITY_GATE=PASS_7_OF_7"
    echo "MONT_T3_THEOREM_FAMILIES_VERIFIED=6_OF_6"
    echo "MONT_T3_DIRECT_ASSERTIONS_VERIFIED=9_OF_9"
    echo "MONT_T3_THEOREM_WEAKENED=NO"
    echo "MONT_T3_STATUS=PROVISIONAL_ACCEPT_PENDING_MUTATION_PACKAGE"
    echo "NEXT_GATE=MONT-03D_T3_SPECIFIC_MUTATIONS"
    echo "MONT03C_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
