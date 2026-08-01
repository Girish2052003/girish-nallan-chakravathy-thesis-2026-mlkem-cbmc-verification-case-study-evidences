#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"

FUNCTIONAL_TIMEOUT=1800
CONTROL_BUILD_TIMEOUT=600
CONTROL_TIMEOUT=1200
UNWIND_BOUND=257

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT04C_T4_FUNCTIONAL_NONVACUITY_$STAMP"
CAPTURE="$OUT/MONT04C_TERMINAL_CAPTURE_$STAMP.txt"

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

get_binding_value()
{
    local file="$1"
    local key="$2"

    awk -F= -v wanted="$key" '
        $1 == wanted {
            sub(/^[^=]*=/, "", $0)
            print $0
            exit
        }
    ' "$file"
}

discover_mont04b_capture()
{
    local directory capture sidecar actual recorded

    while IFS= read -r directory
    do
        capture="$(
            find "$directory" -maxdepth 1 -type f \
                -name 'MONT04B_TERMINAL_CAPTURE_*.txt' |
            head -n 1
        )"

        [[ -n "$capture" && -f "$capture" ]] || continue

        if ! grep -Fxq "MONT_T4_CORE_PROPERTIES_FROZEN=5_OF_5" "$capture" ||
           ! grep -Fxq "MONT_T4_SUPPORTING_ASSERTIONS_FROZEN=1" "$capture" ||
           ! grep -Fxq "MONT_T4_HARNESSES_FROZEN=2" "$capture" ||
           ! grep -Fxq "MONT_T4_EXPLICIT_ASSERTIONS_FROZEN=6" "$capture" ||
           ! grep -Fxq "MONT_T4_STRONGER_LOCAL_P2_P3_FORMS=YES" "$capture" ||
           ! grep -Fxq "MONT_T4_THEOREM_WEAKENED=NO" "$capture" ||
           ! grep -Fxq "MONT04B_HARNESS_FREEZE_GATE=PASS" "$capture" ||
           ! grep -Fxq "MONT04B_GOTO_BUILD_GATE=PASS_2_OF_2" "$capture" ||
           ! grep -Fxq "MONT04B_CAPTURE_END=YES" "$capture"
        then
            continue
        fi

        actual="$(hash_file "$capture")"
        sidecar="${capture}.sha256"

        [[ -f "$sidecar" ]] || continue
        recorded="$(awk 'NR == 1 {print $1}' "$sidecar")"
        [[ "$recorded" == "$actual" ]] || continue

        printf '%s\n' "$capture"
        return 0

    done < <(
        find "$ROOT" -maxdepth 1 -type d \
            -name 'MONT04B_T4_HARNESS_FREEZE_*' \
            -printf '%T@ %p\n' |
        sort -nr |
        cut -d' ' -f2-
    )

    return 1
}

prepare_semantic_makefile()
{
    local source_makefile="$1"
    local destination="$2"
    local harness_stem="$3"
    local proof_uid="$4"

    cp "$source_makefile" "$destination"

    python3 - "$destination" "$harness_stem" "$proof_uid" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
stem = sys.argv[2]
uid = sys.argv[3]
text = path.read_text()

replacements = [
    (
        r'(?m)^HARNESS_FILE\s*=.*$',
        f'HARNESS_FILE = {stem}',
        'HARNESS_FILE',
    ),
    (
        r'(?m)^PROOF_UID\s*=.*$',
        f'PROOF_UID = {uid}',
        'PROOF_UID',
    ),
    (
        r'(?m)^CHECK_FUNCTION_CONTRACTS\s*=.*$',
        'CHECK_FUNCTION_CONTRACTS=',
        'CHECK_FUNCTION_CONTRACTS',
    ),
    (
        r'(?m)^USE_FUNCTION_CONTRACTS\s*=.*$',
        'USE_FUNCTION_CONTRACTS=',
        'USE_FUNCTION_CONTRACTS',
    ),
    (
        r'(?m)^APPLY_LOOP_CONTRACTS\s*=.*$',
        'APPLY_LOOP_CONTRACTS=',
        'APPLY_LOOP_CONTRACTS',
    ),
    (
        r'(?m)^USE_DYNAMIC_FRAMES\s*=.*$',
        'USE_DYNAMIC_FRAMES=',
        'USE_DYNAMIC_FRAMES',
    ),
    (
        r'(?m)^CBMCFLAGS\s*=.*$',
        'CBMCFLAGS=',
        'CBMCFLAGS',
    ),
]

for pattern, replacement, label in replacements:
    text, count = re.subn(pattern, replacement, text)
    if count != 1:
        raise SystemExit(
            f"{label} replacement count was {count}, expected 1"
        )

path.write_text(text)
PY
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
        --signed-overflow-check \
        --unsigned-overflow-check \
        --undefined-shift-check \
        --unwind "$UNWIND_BOUND" \
        --unwinding-assertions \
        --trace \
        "$goto_file" >"$log" 2>&1

    return $?
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
text = Path(sys.argv[3]).read_text(errors="replace")
required = sys.argv[4:]

failure_lines = [
    line for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]

missing = [
    description
    for description in required
    if f"{description}: SUCCESS" not in text
]

error_present = (
    "VERIFICATION ERROR" in text
    or "\nERROR:" in text
    or "Caught exception" in text
)

success = (
    rc == 0
    and "VERIFICATION SUCCESSFUL" in text
    and "VERIFICATION FAILED" not in text
    and not error_present
    and not failure_lines
    and not missing
)

print(f"T4_{tag}_DIRECT_RC={rc}")
print(f"T4_{tag}_FAILURE_COUNT={len(failure_lines)}")
print(f"T4_{tag}_MISSING_REQUIRED_COUNT={len(missing)}")

for index, description in enumerate(missing, start=1):
    print(f"T4_{tag}_MISSING_{index}={description}")

print(
    f"T4_{tag}_FUNCTIONAL_AUDIT="
    f"{'PASS' if success else 'FAIL'}"
)

raise SystemExit(0 if success else 1)
PY
}

audit_control()
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
text = Path(sys.argv[3]).read_text(errors="replace")
expected = sys.argv[4:]

failure_lines = [
    line for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]

counts = {
    description: sum(
        1
        for line in failure_lines
        if f"{description}: FAILURE" in line
    )
    for description in expected
}

missing_or_duplicate = [
    description
    for description, count in counts.items()
    if count != 1
]

unexpected = [
    line
    for line in failure_lines
    if not any(
        f"{description}: FAILURE" in line
        for description in expected
    )
]

error_present = (
    "VERIFICATION ERROR" in text
    or "\nERROR:" in text
    or "Caught exception" in text
)

success = (
    rc == 10
    and "VERIFICATION FAILED" in text
    and "VERIFICATION SUCCESSFUL" not in text
    and not error_present
    and len(failure_lines) == len(expected)
    and not missing_or_duplicate
    and not unexpected
)

print(f"T4_{tag}_DIRECT_RC={rc}")
print(f"T4_{tag}_TOTAL_FAILURE_COUNT={len(failure_lines)}")
print(
    f"T4_{tag}_EXPECTED_FAILURE_COUNT="
    f"{len(expected) - len(missing_or_duplicate)}"
)
print(
    f"T4_{tag}_UNEXPECTED_FAILURE_COUNT={len(unexpected)}"
)
print(
    f"T4_{tag}_MISSING_OR_DUPLICATE_COUNT="
    f"{len(missing_or_duplicate)}"
)

for index, description in enumerate(
    missing_or_duplicate,
    start=1,
):
    print(
        f"T4_{tag}_MISSING_OR_DUPLICATE_{index}="
        f"{description}"
    )

print(
    f"T4_{tag}_NONVACUITY_AUDIT="
    f"{'PASS' if success else 'FAIL'}"
)

raise SystemExit(0 if success else 1)
PY
}

validate_worktree_status()
{
    local wt="$1"
    local phase="$2"

    python3 - "$wt" "$phase" <<'PY'
from pathlib import Path
import subprocess
import sys

wt = Path(sys.argv[1])
phase = sys.argv[2]

allowed_prefixes = (
    "?? proofs/cbmc/mont_t4_p1_p4_roundtrip_zero/",
    "?? proofs/cbmc/mont_t4_p2_p3_p5_bijection_locality/",
    "?? proofs/cbmc/mont_t4_control_p1_p4/",
    "?? proofs/cbmc/mont_t4_control_p2_p3_p5/",
)

result = subprocess.run(
    [
        "git",
        "-C",
        str(wt),
        "status",
        "--porcelain=v1",
        "--untracked-files=all",
    ],
    check=True,
    capture_output=True,
    text=True,
)

lines = [
    line
    for line in result.stdout.splitlines()
    if line.strip()
]

unexpected = [
    line
    for line in lines
    if not line.startswith(allowed_prefixes)
]

print(f"T4_WORKTREE_{phase}_STATUS_LINE_COUNT={len(lines)}")
print(
    f"T4_WORKTREE_{phase}_UNEXPECTED_STATUS_COUNT="
    f"{len(unexpected)}"
)

for index, line in enumerate(unexpected, start=1):
    print(f"T4_WORKTREE_{phase}_UNEXPECTED_{index}={line}")

raise SystemExit(0 if not unexpected else 1)
PY
}

{
    section "MONT-04C — FULL T4 FUNCTIONAL + SIX-WITNESS NON-VACUITY"
    echo "UTC_TIME=$STAMP"
    echo "OUTPUT_DIRECTORY=$OUT"
    echo "FUNCTIONAL_TIMEOUT=$FUNCTIONAL_TIMEOUT"
    echo "CONTROL_BUILD_TIMEOUT=$CONTROL_BUILD_TIMEOUT"
    echo "CONTROL_TIMEOUT=$CONTROL_TIMEOUT"
    echo "UNWIND_BOUND=$UNWIND_BOUND"
    echo "FUNCTIONAL_EXECUTION_MODE=SEQUENTIAL"

    section "C0 — DISCOVER AND BIND ACCEPTED MONT-04B PACKAGE"

    MONT04B_CAPTURE="$(discover_mont04b_capture)" ||
        fail "MONT04B_SUCCESSFUL_CAPTURE_DISCOVERY=FAIL" 20

    MONT04B_CAPTURE_HASH="$(hash_file "$MONT04B_CAPTURE")"

    BINDING_FILE="$(
        grep '^MONT04B_BINDING_FILE=' "$MONT04B_CAPTURE" |
        tail -n 1 |
        cut -d= -f2-
    )"

    BINDING_HASH_RECORDED="$(
        grep '^MONT04B_BINDING_SHA256=' "$MONT04B_CAPTURE" |
        tail -n 1 |
        cut -d= -f2-
    )"

    [[ -n "$BINDING_FILE" && -f "$BINDING_FILE" ]] ||
        fail "MONT04B_BINDING_FILE_PRESENT=NO" 21

    [[ "$(hash_file "$BINDING_FILE")" == "$BINDING_HASH_RECORDED" ]] ||
        fail "MONT04B_BINDING_HASH_GATE=FAIL" 22

    T4_WORKTREE="$(get_binding_value "$BINDING_FILE" "T4_WORKTREE")"

    H14_HARNESS_HASH="$(
        get_binding_value "$BINDING_FILE" "H14_HARNESS_SHA256"
    )"
    H14_MAKEFILE_HASH="$(
        get_binding_value "$BINDING_FILE" "H14_MAKEFILE_SHA256"
    )"
    H14_GOTO_HASH="$(
        get_binding_value "$BINDING_FILE" "H14_GOTO_SHA256"
    )"

    H235_HARNESS_HASH="$(
        get_binding_value "$BINDING_FILE" "H235_HARNESS_SHA256"
    )"
    H235_MAKEFILE_HASH="$(
        get_binding_value "$BINDING_FILE" "H235_MAKEFILE_SHA256"
    )"
    H235_GOTO_HASH="$(
        get_binding_value "$BINDING_FILE" "H235_GOTO_SHA256"
    )"

    [[ -n "$T4_WORKTREE" && -d "$T4_WORKTREE" ]] ||
        fail "T4_WORKTREE_PRESENT=NO" 23

    P14_NAME="mont_t4_p1_p4_roundtrip_zero"
    P235_NAME="mont_t4_p2_p3_p5_bijection_locality"

    P14_DIR="$T4_WORKTREE/proofs/cbmc/$P14_NAME"
    P235_DIR="$T4_WORKTREE/proofs/cbmc/$P235_NAME"

    P14_STEM="${P14_NAME}_harness"
    P235_STEM="${P235_NAME}_harness"

    P14_HARNESS="$P14_DIR/$P14_STEM.c"
    P14_MAKEFILE="$P14_DIR/Makefile"
    P14_GOTO="$P14_DIR/gotos/$P14_STEM.goto"

    P235_HARNESS="$P235_DIR/$P235_STEM.c"
    P235_MAKEFILE="$P235_DIR/Makefile"
    P235_GOTO="$P235_DIR/gotos/$P235_STEM.goto"

    NATIVE_MAKEFILE="$T4_WORKTREE/proofs/cbmc/poly_tomont_c/Makefile"

    echo "MONT04B_CAPTURE=$MONT04B_CAPTURE"
    echo "MONT04B_CAPTURE_SHA256=$MONT04B_CAPTURE_HASH"
    echo "MONT04B_BINDING_FILE=$BINDING_FILE"
    echo "MONT04B_BINDING_SHA256=$BINDING_HASH_RECORDED"
    echo "T4_WORKTREE=$T4_WORKTREE"

    section "C1 — REBIND SOURCE AND FROZEN ARTEFACTS"

    AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null || true)"
    WT_HEAD="$(
        git -C "$T4_WORKTREE" rev-parse HEAD 2>/dev/null || true
    )"
    AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all \
            2>/dev/null || true
    )"

    [[ "$AUTH_HEAD" == "$EXPECTED_COMMIT" &&
       "$WT_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$AUTH_STATUS" ]] ||
        fail "COMMIT_OR_AUTHORITATIVE_CLEAN_GATE=FAIL" 24

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$T4_WORKTREE/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$T4_WORKTREE/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "SOURCE_BINDING_GATE=FAIL" 25

    validate_worktree_status "$T4_WORKTREE" "INITIAL" ||
        fail "T4_WORKTREE_INITIAL_STATUS_GATE=FAIL" 26

    [[ -f "$P14_HARNESS" &&
       -f "$P14_MAKEFILE" &&
       -f "$P14_GOTO" &&
       -f "$P235_HARNESS" &&
       -f "$P235_MAKEFILE" &&
       -f "$P235_GOTO" ]] ||
        fail "T4_FROZEN_ARTEFACT_PRESENT_GATE=FAIL" 27

    [[ "$(hash_file "$P14_HARNESS")" == "$H14_HARNESS_HASH" &&
       "$(hash_file "$P14_MAKEFILE")" == "$H14_MAKEFILE_HASH" &&
       "$(hash_file "$P14_GOTO")" == "$H14_GOTO_HASH" &&
       "$(hash_file "$P235_HARNESS")" == "$H235_HARNESS_HASH" &&
       "$(hash_file "$P235_MAKEFILE")" == "$H235_MAKEFILE_HASH" &&
       "$(hash_file "$P235_GOTO")" == "$H235_GOTO_HASH" ]] ||
        fail "T4_FROZEN_ARTEFACT_HASH_GATE=FAIL" 28

    echo "COMMIT_AND_SOURCE_BINDING=PASS"
    echo "T4_FROZEN_ARTEFACT_BINDING=PASS_2_OF_2"

    section "C2 — RUN H14 DIRECT FUNCTIONAL CBMC"

    run_cbmc "$P14_GOTO" "$OUT/H14_FUNCTIONAL.log" "$FUNCTIONAL_TIMEOUT"
    H14_RC=$?

    echo "T4_H14_KEY_RESULTS_BEGIN"
    grep -E \
        'MONT-T4\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR' \
        "$OUT/H14_FUNCTIONAL.log" || true
    echo "T4_H14_KEY_RESULTS_END"

    audit_functional \
        "H14" \
        "$H14_RC" \
        "$OUT/H14_FUNCTIONAL.log" \
        "MONT-T4.P1.de_Montgomery_round_trip" \
        "MONT-T4.P4.zero_support_preservation" \
        "MONT-T4.SUPPORT.forward_representation_congruence" ||
        fail "T4_H14_FUNCTIONAL_GATE=FAIL" 29

    echo "T4_H14_FUNCTIONAL_GATE=PASS"

    section "C3 — RUN H235 DIRECT FUNCTIONAL CBMC"

    run_cbmc "$P235_GOTO" "$OUT/H235_FUNCTIONAL.log" "$FUNCTIONAL_TIMEOUT"
    H235_RC=$?

    echo "T4_H235_KEY_RESULTS_BEGIN"
    grep -E \
        'MONT-T4\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR' \
        "$OUT/H235_FUNCTIONAL.log" || true
    echo "T4_H235_KEY_RESULTS_END"

    audit_functional \
        "H235" \
        "$H235_RC" \
        "$OUT/H235_FUNCTIONAL.log" \
        "MONT-T4.P2.residue_equivalence_preservation_stronger_local_form" \
        "MONT-T4.P3.residue_equivalence_reflection_stronger_local_form" \
        "MONT-T4.P5.coefficient_locality_no_cross_talk" ||
        fail "T4_H235_FUNCTIONAL_GATE=FAIL" 30

    echo "T4_H235_FUNCTIONAL_GATE=PASS"
    echo "MONT04C_FUNCTIONAL_GATE=PASS_2_OF_2"
    echo "MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5"
    echo "MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1"

    section "C4 — CREATE H14 THREE-WITNESS NON-VACUITY CONTROL"

    CONTROL14_NAME="mont_t4_control_p1_p4"
    CONTROL14_DIR="$T4_WORKTREE/proofs/cbmc/$CONTROL14_NAME"
    CONTROL14_STEM="${CONTROL14_NAME}_harness"
    CONTROL14_HARNESS="$CONTROL14_DIR/$CONTROL14_STEM.c"
    CONTROL14_MAKEFILE="$CONTROL14_DIR/Makefile"
    CONTROL14_GOTO="$CONTROL14_DIR/gotos/$CONTROL14_STEM.goto"

    [[ ! -e "$CONTROL14_DIR" ]] ||
        fail "T4_CONTROL14_PATH_ALREADY_EXISTS=YES" 31

    mkdir -p "$CONTROL14_DIR"

    cat >"$CONTROL14_HARNESS" <<'C'
#include <stdint.h>
#include <limits.h>

#include "poly.h"

extern mlk_poly nondet_mlk_poly(void);
extern unsigned nondet_unsigned(void);

void mlk_poly_tomont_c(mlk_poly *r);

void harness(void)
{
  mlk_poly state;
  mlk_poly before;
  unsigned k;

  state = nondet_mlk_poly();
  before = state;
  k = nondet_unsigned();

  __CPROVER_assume(k < MLKEM_N);

  mlk_poly_tomont_c(&state);

  if (before.coeffs[k] == 0)
  {
    __CPROVER_assert(
        (int32_t)state.coeffs[k] ==
            (int32_t)state.coeffs[k] + 1,
        "MONT-T4.CONTROL.C1.zero_input_path_reachable");
  }

  if (before.coeffs[k] == 1)
  {
    __CPROVER_assert(
        (int32_t)state.coeffs[k] ==
            (int32_t)state.coeffs[k] + 1,
        "MONT-T4.CONTROL.C2.nonzero_input_path_reachable");
  }

  if (before.coeffs[k] == INT16_MIN)
  {
    __CPROVER_assert(
        (int32_t)state.coeffs[k] ==
            (int32_t)state.coeffs[k] + 1,
        "MONT-T4.CONTROL.C3.full_int16_extreme_path_reachable");
  }
}
C

    prepare_semantic_makefile \
        "$NATIVE_MAKEFILE" \
        "$CONTROL14_MAKEFILE" \
        "$CONTROL14_STEM" \
        "mont_t4_control_p1_p4"

    echo "T4_CONTROL14_HARNESS_SHA256=$(
        hash_file "$CONTROL14_HARNESS"
    )"
    echo "T4_CONTROL14_MAKEFILE_SHA256=$(
        hash_file "$CONTROL14_MAKEFILE"
    )"

    make -C "$CONTROL14_DIR" MLKEM_K=3 clean \
        >"$OUT/CONTROL14_CLEAN.log" 2>&1 || true

    timeout "$CONTROL_BUILD_TIMEOUT" \
        make -C "$CONTROL14_DIR" MLKEM_K=3 goto \
        >"$OUT/CONTROL14_BUILD.log" 2>&1

    CONTROL14_BUILD_RC=$?
    echo "T4_CONTROL14_BUILD_RC=$CONTROL14_BUILD_RC"

    if [[ "$CONTROL14_BUILD_RC" -ne 0 || ! -f "$CONTROL14_GOTO" ]]; then
        echo "T4_CONTROL14_GOTO_PRESENT=NO"
        tail -n 120 "$OUT/CONTROL14_BUILD.log" || true
        fail "T4_CONTROL14_BUILD_GATE=FAIL" 32
    fi

    echo "T4_CONTROL14_GOTO_PRESENT=YES"
    echo "T4_CONTROL14_GOTO_SHA256=$(hash_file "$CONTROL14_GOTO")"

    section "C5 — RUN H14 THREE-WITNESS CONTROL"

    run_cbmc \
        "$CONTROL14_GOTO" \
        "$OUT/CONTROL14_CBMC.log" \
        "$CONTROL_TIMEOUT"

    CONTROL14_RC=$?

    echo "T4_CONTROL14_KEY_RESULTS_BEGIN"
    grep -E \
        'MONT-T4.CONTROL\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR' \
        "$OUT/CONTROL14_CBMC.log" || true
    echo "T4_CONTROL14_KEY_RESULTS_END"

    audit_control \
        "CONTROL14" \
        "$CONTROL14_RC" \
        "$OUT/CONTROL14_CBMC.log" \
        "MONT-T4.CONTROL.C1.zero_input_path_reachable" \
        "MONT-T4.CONTROL.C2.nonzero_input_path_reachable" \
        "MONT-T4.CONTROL.C3.full_int16_extreme_path_reachable" ||
        fail "T4_CONTROL14_NONVACUITY_GATE=FAIL" 33

    echo "T4_CONTROL14_NONVACUITY_GATE=PASS_3_OF_3"

    section "C6 — CREATE H235 THREE-WITNESS NON-VACUITY CONTROL"

    CONTROL235_NAME="mont_t4_control_p2_p3_p5"
    CONTROL235_DIR="$T4_WORKTREE/proofs/cbmc/$CONTROL235_NAME"
    CONTROL235_STEM="${CONTROL235_NAME}_harness"
    CONTROL235_HARNESS="$CONTROL235_DIR/$CONTROL235_STEM.c"
    CONTROL235_MAKEFILE="$CONTROL235_DIR/Makefile"
    CONTROL235_GOTO="$CONTROL235_DIR/gotos/$CONTROL235_STEM.goto"

    [[ ! -e "$CONTROL235_DIR" ]] ||
        fail "T4_CONTROL235_PATH_ALREADY_EXISTS=YES" 34

    mkdir -p "$CONTROL235_DIR"

    cat >"$CONTROL235_HARNESS" <<'C'
#include <stdint.h>

#include "poly.h"

extern mlk_poly nondet_mlk_poly(void);
extern unsigned nondet_unsigned(void);

void mlk_poly_tomont_c(mlk_poly *r);

static int32_t canonical_q(int32_t value)
{
  int32_t residue = value % MLKEM_Q;

  if (residue < 0)
  {
    residue += MLKEM_Q;
  }

  return residue;
}

void harness(void)
{
  mlk_poly left;
  mlk_poly right;
  mlk_poly left_before;
  mlk_poly right_before;
  unsigned k;
  unsigned j;

  left = nondet_mlk_poly();
  right = nondet_mlk_poly();

  left_before = left;
  right_before = right;

  k = nondet_unsigned();
  j = nondet_unsigned();

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(j < MLKEM_N);
  __CPROVER_assume(j != k);

  mlk_poly_tomont_c(&left);
  mlk_poly_tomont_c(&right);

  if (canonical_q((int32_t)left_before.coeffs[k]) ==
          canonical_q((int32_t)right_before.coeffs[k]) &&
      left_before.coeffs[k] != right_before.coeffs[k])
  {
    __CPROVER_assert(
        (int32_t)left.coeffs[k] ==
            (int32_t)left.coeffs[k] + 1,
        "MONT-T4.CONTROL.C4.input_residue_equivalence_antecedent_reachable");
  }

  if (canonical_q((int32_t)left.coeffs[k]) ==
          canonical_q((int32_t)right.coeffs[k]) &&
      left_before.coeffs[k] != right_before.coeffs[k])
  {
    __CPROVER_assert(
        (int32_t)right.coeffs[k] ==
            (int32_t)right.coeffs[k] + 1,
        "MONT-T4.CONTROL.C5.output_residue_equivalence_antecedent_reachable");
  }

  if (left_before.coeffs[k] == right_before.coeffs[k] &&
      left_before.coeffs[j] != right_before.coeffs[j])
  {
    __CPROVER_assert(
        (int32_t)left.coeffs[k] ==
            (int32_t)left.coeffs[k] + 1,
        "MONT-T4.CONTROL.C6.local_equality_with_unrelated_difference_reachable");
  }
}
C

    prepare_semantic_makefile \
        "$NATIVE_MAKEFILE" \
        "$CONTROL235_MAKEFILE" \
        "$CONTROL235_STEM" \
        "mont_t4_control_p2_p3_p5"

    echo "T4_CONTROL235_HARNESS_SHA256=$(
        hash_file "$CONTROL235_HARNESS"
    )"
    echo "T4_CONTROL235_MAKEFILE_SHA256=$(
        hash_file "$CONTROL235_MAKEFILE"
    )"

    make -C "$CONTROL235_DIR" MLKEM_K=3 clean \
        >"$OUT/CONTROL235_CLEAN.log" 2>&1 || true

    timeout "$CONTROL_BUILD_TIMEOUT" \
        make -C "$CONTROL235_DIR" MLKEM_K=3 goto \
        >"$OUT/CONTROL235_BUILD.log" 2>&1

    CONTROL235_BUILD_RC=$?
    echo "T4_CONTROL235_BUILD_RC=$CONTROL235_BUILD_RC"

    if [[ "$CONTROL235_BUILD_RC" -ne 0 || ! -f "$CONTROL235_GOTO" ]]; then
        echo "T4_CONTROL235_GOTO_PRESENT=NO"
        tail -n 120 "$OUT/CONTROL235_BUILD.log" || true
        fail "T4_CONTROL235_BUILD_GATE=FAIL" 35
    fi

    echo "T4_CONTROL235_GOTO_PRESENT=YES"
    echo "T4_CONTROL235_GOTO_SHA256=$(hash_file "$CONTROL235_GOTO")"

    section "C7 — RUN H235 THREE-WITNESS CONTROL"

    run_cbmc \
        "$CONTROL235_GOTO" \
        "$OUT/CONTROL235_CBMC.log" \
        "$CONTROL_TIMEOUT"

    CONTROL235_RC=$?

    echo "T4_CONTROL235_KEY_RESULTS_BEGIN"
    grep -E \
        'MONT-T4.CONTROL\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR' \
        "$OUT/CONTROL235_CBMC.log" || true
    echo "T4_CONTROL235_KEY_RESULTS_END"

    audit_control \
        "CONTROL235" \
        "$CONTROL235_RC" \
        "$OUT/CONTROL235_CBMC.log" \
        "MONT-T4.CONTROL.C4.input_residue_equivalence_antecedent_reachable" \
        "MONT-T4.CONTROL.C5.output_residue_equivalence_antecedent_reachable" \
        "MONT-T4.CONTROL.C6.local_equality_with_unrelated_difference_reachable" ||
        fail "T4_CONTROL235_NONVACUITY_GATE=FAIL" 36

    echo "T4_CONTROL235_NONVACUITY_GATE=PASS_3_OF_3"
    echo "MONT04C_NONVACUITY_GATE=PASS_6_OF_6"

    section "C8 — FINAL INTEGRITY AND PROVISIONAL T4 VERDICT"

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$T4_WORKTREE/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$T4_WORKTREE/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "FINAL_SOURCE_INTEGRITY=FAIL" 37

    FINAL_AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all
    )"

    [[ -z "$FINAL_AUTH_STATUS" ]] ||
        fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 38

    validate_worktree_status "$T4_WORKTREE" "FINAL" ||
        fail "T4_WORKTREE_FINAL_STATUS_GATE=FAIL" 39

    [[ "$(hash_file "$P14_HARNESS")" == "$H14_HARNESS_HASH" &&
       "$(hash_file "$P14_MAKEFILE")" == "$H14_MAKEFILE_HASH" &&
       "$(hash_file "$P14_GOTO")" == "$H14_GOTO_HASH" &&
       "$(hash_file "$P235_HARNESS")" == "$H235_HARNESS_HASH" &&
       "$(hash_file "$P235_MAKEFILE")" == "$H235_MAKEFILE_HASH" &&
       "$(hash_file "$P235_GOTO")" == "$H235_GOTO_HASH" ]] ||
        fail "FINAL_FROZEN_ARTEFACT_INTEGRITY=FAIL" 40

    BINDING_OUT="$OUT/MONT04C_T4_GATE_C_BINDING.env"

    cat >"$BINDING_OUT" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H=$EXPECTED_POLY_H
EXPECTED_POLY_C=$EXPECTED_POLY_C
T4_WORKTREE=$T4_WORKTREE
MONT04B_CAPTURE=$MONT04B_CAPTURE
MONT04B_CAPTURE_SHA256=$MONT04B_CAPTURE_HASH
MONT04B_BINDING_FILE=$BINDING_FILE
MONT04B_BINDING_SHA256=$BINDING_HASH_RECORDED
H14_HARNESS_SHA256=$H14_HARNESS_HASH
H14_MAKEFILE_SHA256=$H14_MAKEFILE_HASH
H14_GOTO_SHA256=$H14_GOTO_HASH
H235_HARNESS_SHA256=$H235_HARNESS_HASH
H235_MAKEFILE_SHA256=$H235_MAKEFILE_HASH
H235_GOTO_SHA256=$H235_GOTO_HASH
CONTROL14_HARNESS_SHA256=$(hash_file "$CONTROL14_HARNESS")
CONTROL14_MAKEFILE_SHA256=$(hash_file "$CONTROL14_MAKEFILE")
CONTROL14_GOTO_SHA256=$(hash_file "$CONTROL14_GOTO")
CONTROL235_HARNESS_SHA256=$(hash_file "$CONTROL235_HARNESS")
CONTROL235_MAKEFILE_SHA256=$(hash_file "$CONTROL235_MAKEFILE")
CONTROL235_GOTO_SHA256=$(hash_file "$CONTROL235_GOTO")
MONT04C_FUNCTIONAL_GATE=PASS_2_OF_2
MONT04C_NONVACUITY_GATE=PASS_6_OF_6
MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5
MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1
MONT_T4_THEOREM_WEAKENED=NO
EOF

    echo "MONT04C_BINDING_FILE=$BINDING_OUT"
    echo "MONT04C_BINDING_SHA256=$(hash_file "$BINDING_OUT")"
    echo "FINAL_SOURCE_INTEGRITY=PASS"
    echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
    echo "FINAL_FROZEN_ARTEFACT_INTEGRITY=PASS_2_OF_2"
    echo "MONT04C_FUNCTIONAL_GATE=PASS_2_OF_2"
    echo "MONT04C_NONVACUITY_GATE=PASS_6_OF_6"
    echo "MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5"
    echo "MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1"
    echo "MONT_T4_STRONGER_LOCAL_P2_P3_FORMS=VERIFIED"
    echo "MONT_T4_THEOREM_WEAKENED=NO"
    echo "MONT_T4_STATUS=PROVISIONAL_ACCEPT_PENDING_MUTATION_PACKAGE"
    echo "NEXT_GATE=MONT-04D_T4_SPECIFIC_MUTATIONS"
    echo "MONT04C_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
