#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_T4_REGISTRY_HASH="ce047652781b05fdb892fd85d30ac7713952374876455eb5bdcff8eee734f4d9"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
WT="$ROOT/MONT_T4_WORKTREE_af4c5abd_$STAMP"
OUT="$ROOT/MONT04B_T4_HARNESS_FREEZE_$STAMP"
CAPTURE="$OUT/MONT04B_TERMINAL_CAPTURE_$STAMP.txt"

P14_NAME="mont_t4_p1_p4_roundtrip_zero"
P235_NAME="mont_t4_p2_p3_p5_bijection_locality"

P14_DIR="$WT/proofs/cbmc/$P14_NAME"
P235_DIR="$WT/proofs/cbmc/$P235_NAME"

P14_STEM="${P14_NAME}_harness"
P235_STEM="${P235_NAME}_harness"

NATIVE_DIR="$WT/proofs/cbmc/poly_tomont_c"
NATIVE_MAKEFILE="$NATIVE_DIR/Makefile"
NATIVE_HARNESS="$NATIVE_DIR/poly_tomont_c_harness.c"

PARALLEL_BUILDS=2
BUILD_TIMEOUT=600

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

discover_mont04a_capture()
{
    local directory capture sidecar actual recorded

    while IFS= read -r directory
    do
        capture="$(
            find "$directory" -maxdepth 1 -type f \
                -name 'MONT04A_TERMINAL_CAPTURE_*.txt' |
            head -n 1
        )"

        [[ -n "$capture" && -f "$capture" ]] || continue

        if ! grep -Fxq "MONT04A_CAPTURE_GATE=PASS" "$capture" ||
           ! grep -Fxq "MONT_T4_PROPERTY_COUNT=5" "$capture" ||
           ! grep -Fxq "MONT_T4_THEOREM_WEAKENED=NO" "$capture" ||
           ! grep -Fxq "MONT_T4_SOURCE_MODIFIED=NO" "$capture" ||
           ! grep -Fxq "MONT04A_CAPTURE_END=YES" "$capture"
        then
            continue
        fi

        if ! grep -Fxq \
            "MONT04A_T4_REGISTRY_SHA256=$EXPECTED_T4_REGISTRY_HASH" \
            "$capture"
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
            -name 'MONT04A_T4_SOURCE_CAPTURE_*' \
            -printf '%T@ %p\n' |
        sort -nr |
        cut -d' ' -f2-
    )

    return 1
}

prepare_semantic_makefile()
{
    local destination="$1"
    local harness_stem="$2"
    local proof_uid="$3"

    cp "$NATIVE_MAKEFILE" "$destination"

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

build_one()
{
    local tag="$1"
    local proof_dir="$2"
    local stem="$3"

    make -C "$proof_dir" MLKEM_K=3 clean \
        >"$OUT/${tag}_CLEAN.log" 2>&1 || true

    timeout "$BUILD_TIMEOUT" \
        make -C "$proof_dir" MLKEM_K=3 goto \
        >"$OUT/${tag}_BUILD.log" 2>&1

    local rc=$?
    printf '%s\n' "$rc" >"$OUT/${tag}_BUILD.rc"

    local goto_file="$proof_dir/gotos/${stem}.goto"

    if [[ -f "$goto_file" ]]; then
        hash_file "$goto_file" >"$OUT/${tag}_GOTO.sha256"
    fi
}

{
    section "MONT-04B — FULL LOCKED T4 HARNESS FREEZE + GOTO BUILD"
    echo "UTC_TIME=$STAMP"
    echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
    echo "AUTHORITATIVE_SOURCE=$AUTH"
    echo "FRESH_DETACHED_T4_WORKTREE=$WT"
    echo "OUTPUT_DIRECTORY=$OUT"
    echo "PARALLEL_BUILDS=$PARALLEL_BUILDS"
    echo "BUILD_TIMEOUT=$BUILD_TIMEOUT"

    section "B0 — BIND SOURCE AND ACCEPTED MONT-04A CAPTURE"

    MONT04A_CAPTURE="$(discover_mont04a_capture)" ||
        fail "MONT04A_SUCCESSFUL_CAPTURE_DISCOVERY=FAIL" 20

    echo "MONT04A_CAPTURE=$MONT04A_CAPTURE"
    echo "MONT04A_CAPTURE_SHA256=$(hash_file "$MONT04A_CAPTURE")"
    echo "MONT04A_SUCCESSFUL_CAPTURE_BINDING=PASS"

    AUTH_IS_WORKTREE="$(
        git -C "$AUTH" rev-parse --is-inside-work-tree 2>/dev/null || true
    )"
    AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null || true)"
    AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all \
            2>/dev/null || true
    )"

    [[ "$AUTH_IS_WORKTREE" == "true" &&
       "$AUTH_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$AUTH_STATUS" ]] ||
        fail "AUTHORITATIVE_SOURCE_GATE=FAIL" 21

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "AUTHORITATIVE_SOURCE_HASH_GATE=FAIL" 22

    echo "AUTHORITATIVE_SOURCE_GATE=PASS"
    echo "AUTHORITATIVE_SOURCE_HASH_GATE=PASS"

    section "B1 — CREATE FRESH DETACHED T4 WORKTREE"

    [[ ! -e "$WT" ]] ||
        fail "FRESH_T4_WORKTREE_PATH_COLLISION=FAIL" 23

    git -C "$AUTH" worktree add --detach "$WT" "$EXPECTED_COMMIT" \
        >"$OUT/WORKTREE_ADD.log" 2>&1 ||
        fail "T4_WORKTREE_CREATE_GATE=FAIL" 24

    WT_IS_WORKTREE="$(
        git -C "$WT" rev-parse --is-inside-work-tree 2>/dev/null || true
    )"
    WT_HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null || true)"
    WT_STATUS="$(
        git -C "$WT" status --porcelain=v1 --untracked-files=all \
            2>/dev/null || true
    )"

    [[ "$WT_IS_WORKTREE" == "true" &&
       "$WT_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$WT_STATUS" ]] ||
        fail "T4_WORKTREE_BINDING_GATE=FAIL" 25

    [[ "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "T4_WORKTREE_SOURCE_HASH_GATE=FAIL" 26

    echo "T4_WORKTREE_CREATE_GATE=PASS"
    echo "T4_WORKTREE_BINDING_GATE=PASS"
    echo "T4_WORKTREE_SOURCE_HASH_GATE=PASS"

    section "B2 — FREEZE NATIVE CBMC OVERLAP BASELINE"

    [[ -f "$NATIVE_HARNESS" && -f "$NATIVE_MAKEFILE" ]] ||
        fail "NATIVE_POLY_TOMONT_C_BASELINE_PRESENT=NO" 27

    cp "$NATIVE_HARNESS" "$OUT/NATIVE_poly_tomont_c_harness.c"
    cp "$NATIVE_MAKEFILE" "$OUT/NATIVE_poly_tomont_c_Makefile"

    echo "NATIVE_TOMONT_HARNESS_SHA256=$(hash_file "$NATIVE_HARNESS")"
    echo "NATIVE_TOMONT_MAKEFILE_SHA256=$(hash_file "$NATIVE_MAKEFILE")"
    echo "NATIVE_TOMONT_EXPLICIT_ASSERTION_COUNT=$(
        grep -Ec '__CPROVER_assert[[:space:]]*\(' \
            "$NATIVE_HARNESS" || true
    )"
    echo "NATIVE_TOMONT_CALL_COUNT=$(
        grep -Ec 'mlk_poly_tomont_c[[:space:]]*\(' \
            "$NATIVE_HARNESS" || true
    )"

    section "B3 — FREEZE FULL T4 REGISTRY AND STRONGER LOCAL FORMS"

    REGISTRY="$OUT/MONT04B_T4_THEOREM_REGISTRY.txt"

    cat >"$REGISTRY" <<'EOF'
MONT-T4 — PORTABLE-C ROUND TRIP, BIJECTION AND LOCALITY
========================================================

Pinned target:
  mlk_poly_tomont_c

Pinned commit:
  af4c5abdd5958bdc65a03cd5ee86708264f93304

Core theorem count:
  5

T4-P1 — De-Montgomery round trip
  For an arbitrary int16_t polynomial A and arbitrary valid index k:
    canonical_q(montgomery_reduce(T(A)[k]))
      ==
    canonical_q(A_before[k])

T4-P2 — Residue-vector equivalence preservation
  Old vector theorem:
    whole-vector input residue equivalence implies whole-vector output
    residue equivalence.

  Direct stronger local form used by CBMC:
    for arbitrary A, D and valid k,
    canonical_q(A[k]) == canonical_q(D[k])
      implies
    canonical_q(T(A)[k]) == canonical_q(T(D)[k]),
    regardless of all unrelated coefficients.

T4-P3 — Residue-vector equivalence reflection
  Old vector theorem:
    whole-vector output residue equivalence implies whole-vector input
    residue equivalence.

  Direct stronger local form used by CBMC:
    for arbitrary A, D and valid k,
    canonical_q(T(A)[k]) == canonical_q(T(D)[k])
      implies
    canonical_q(A[k]) == canonical_q(D[k]),
    regardless of all unrelated coefficients.

T4-P4 — Zero-support preservation
  For arbitrary A and valid k:
    canonical_q(T(A)[k]) == 0
      iff
    canonical_q(A_before[k]) == 0

T4-P5 — Coefficient locality and no cross-talk
  For arbitrary A, D and valid k:
    A[k] == D[k]
      implies
    T(A)[k] == T(D)[k],
    regardless of differences at all other coefficients.

Supporting overlap lemma — not counted as a new theorem
  For arbitrary A and valid k:
    canonical_q(T(A)[k])
      ==
    canonical_q(A_before[k] * (2^16 mod q))

  This is supporting evidence only because native HOL Light proofs already
  cover basic forward Montgomery conversion congruence.

Solver packaging:
  Harness H14: P1, P4, and the supporting forward law.
  Harness H235: P2, P3, and P5.

No weakening:
  The stronger arbitrary-index local forms imply the originally frozen
  vector-level P2 and P3 statements.
  No core property is deleted, narrowed, or accepted solely from T1-T3.
EOF

    echo "T4_REGISTRY_SHA256=$(hash_file "$REGISTRY")"

    REQUIRED_MARKERS=(
        "T4-P1 — De-Montgomery round trip"
        "T4-P2 — Residue-vector equivalence preservation"
        "T4-P3 — Residue-vector equivalence reflection"
        "T4-P4 — Zero-support preservation"
        "T4-P5 — Coefficient locality and no cross-talk"
        "No core property is deleted"
    )

    REGISTRY_MISSING=0

    for marker in "${REQUIRED_MARKERS[@]}"
    do
        if ! grep -Fq "$marker" "$REGISTRY"; then
            echo "T4_REGISTRY_MISSING=$marker"
            REGISTRY_MISSING=$((REGISTRY_MISSING + 1))
        fi
    done

    echo "T4_REGISTRY_MISSING_COUNT=$REGISTRY_MISSING"

    [[ "$REGISTRY_MISSING" -eq 0 ]] ||
        fail "T4_REGISTRY_COMPLETENESS_GATE=FAIL" 28

    python3 - <<'PY'
q = 3329
R = 1 << 16
assert R % q == 2285
assert (R * R) % q == 1353
print("T4_CONSTANT_CENSUS_GATE=PASS")
print("T4_R_MOD_Q=2285")
print("T4_R2_MOD_Q=1353")
PY

    echo "T4_REGISTRY_COMPLETENESS_GATE=PASS"

    section "B4 — CREATE TWO FULL-STRENGTH SEMANTIC HARNESSES"

    mkdir -p "$P14_DIR" "$P235_DIR"

    cat >"$P14_DIR/$P14_STEM.c" <<'C'
#include <stdint.h>

#include "poly.h"

#define MONT_R_MOD_Q ((int32_t)2285)

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
  mlk_poly state;
  mlk_poly before;
  unsigned k;
  int16_t demontgomery_value;

  state = nondet_mlk_poly();
  before = state;
  k = nondet_unsigned();

  __CPROVER_assume(k < MLKEM_N);

  mlk_poly_tomont_c(&state);

  demontgomery_value =
      mlk_montgomery_reduce((int32_t)state.coeffs[k]);

  __CPROVER_assert(
      canonical_q((int32_t)demontgomery_value) ==
          canonical_q((int32_t)before.coeffs[k]),
      "MONT-T4.P1.de_Montgomery_round_trip");

  __CPROVER_assert(
      (canonical_q((int32_t)state.coeffs[k]) == 0) ==
          (canonical_q((int32_t)before.coeffs[k]) == 0),
      "MONT-T4.P4.zero_support_preservation");

  __CPROVER_assert(
      canonical_q((int32_t)state.coeffs[k]) ==
          canonical_q(
              (int32_t)before.coeffs[k] * MONT_R_MOD_Q),
      "MONT-T4.SUPPORT.forward_representation_congruence");
}
C

    cat >"$P235_DIR/$P235_STEM.c" <<'C'
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
  __CPROVER_bool input_residues_equal;
  __CPROVER_bool output_residues_equal;

  left = nondet_mlk_poly();
  right = nondet_mlk_poly();

  left_before = left;
  right_before = right;

  k = nondet_unsigned();
  __CPROVER_assume(k < MLKEM_N);

  mlk_poly_tomont_c(&left);
  mlk_poly_tomont_c(&right);

  input_residues_equal =
      canonical_q((int32_t)left_before.coeffs[k]) ==
      canonical_q((int32_t)right_before.coeffs[k]);

  output_residues_equal =
      canonical_q((int32_t)left.coeffs[k]) ==
      canonical_q((int32_t)right.coeffs[k]);

  __CPROVER_assert(
      !input_residues_equal || output_residues_equal,
      "MONT-T4.P2.residue_equivalence_preservation_stronger_local_form");

  __CPROVER_assert(
      !output_residues_equal || input_residues_equal,
      "MONT-T4.P3.residue_equivalence_reflection_stronger_local_form");

  __CPROVER_assert(
      left_before.coeffs[k] != right_before.coeffs[k] ||
          left.coeffs[k] == right.coeffs[k],
      "MONT-T4.P5.coefficient_locality_no_cross_talk");
}
C

    prepare_semantic_makefile \
        "$P14_DIR/Makefile" \
        "$P14_STEM" \
        "mont_t4_p1_p4_roundtrip_zero"

    prepare_semantic_makefile \
        "$P235_DIR/Makefile" \
        "$P235_STEM" \
        "mont_t4_p2_p3_p5_bijection_locality"

    P14_HARNESS="$P14_DIR/$P14_STEM.c"
    P235_HARNESS="$P235_DIR/$P235_STEM.c"

    echo "T4_H14_HARNESS_SHA256=$(hash_file "$P14_HARNESS")"
    echo "T4_H14_MAKEFILE_SHA256=$(hash_file "$P14_DIR/Makefile")"
    echo "T4_H235_HARNESS_SHA256=$(hash_file "$P235_HARNESS")"
    echo "T4_H235_MAKEFILE_SHA256=$(hash_file "$P235_DIR/Makefile")"

    CORE_ASSERTION_COUNT="$(
        grep -h -E \
            'MONT-T4\.P[1-5]\.' \
            "$P14_HARNESS" "$P235_HARNESS" |
        wc -l
    )"

    SUPPORT_ASSERTION_COUNT="$(
        grep -h -E \
            'MONT-T4\.SUPPORT\.' \
            "$P14_HARNESS" "$P235_HARNESS" |
        wc -l
    )"

    EXPLICIT_ASSERTION_COUNT="$(
        grep -h -E \
            '__CPROVER_assert[[:space:]]*\(' \
            "$P14_HARNESS" "$P235_HARNESS" |
        wc -l
    )"

    echo "T4_HARNESS_COUNT=2"
    echo "T4_CORE_ASSERTION_COUNT=$CORE_ASSERTION_COUNT"
    echo "T4_SUPPORT_ASSERTION_COUNT=$SUPPORT_ASSERTION_COUNT"
    echo "T4_EXPLICIT_ASSERTION_COUNT=$EXPLICIT_ASSERTION_COUNT"

    [[ "$CORE_ASSERTION_COUNT" -eq 5 &&
       "$SUPPORT_ASSERTION_COUNT" -eq 1 &&
       "$EXPLICIT_ASSERTION_COUNT" -eq 6 ]] ||
        fail "T4_ASSERTION_FREEZE_GATE=FAIL" 29

    echo "T4_ASSERTION_FREEZE_GATE=PASS"

    section "B5 — VERIFY SEMANTIC MAKEFILE MODE"

    for makefile in "$P14_DIR/Makefile" "$P235_DIR/Makefile"
    do
        grep -Fxq "CHECK_FUNCTION_CONTRACTS=" "$makefile" ||
            fail "SEMANTIC_MAKEFILE_CHECK_CONTRACTS_GATE=FAIL" 30
        grep -Fxq "USE_FUNCTION_CONTRACTS=" "$makefile" ||
            fail "SEMANTIC_MAKEFILE_USE_CONTRACTS_GATE=FAIL" 31
        grep -Fxq "APPLY_LOOP_CONTRACTS=" "$makefile" ||
            fail "SEMANTIC_MAKEFILE_LOOP_CONTRACTS_GATE=FAIL" 32
        grep -Fxq "USE_DYNAMIC_FRAMES=" "$makefile" ||
            fail "SEMANTIC_MAKEFILE_DYNAMIC_FRAMES_GATE=FAIL" 33
        grep -Fxq "CBMCFLAGS=" "$makefile" ||
            fail "SEMANTIC_MAKEFILE_CBMCFLAGS_GATE=FAIL" 34
    done

    echo "T4_SEMANTIC_INLINE_FQMUL=YES"
    echo "T4_SEMANTIC_DIRECT_LOOP_EXECUTION=YES"
    echo "T4_CONTRACT_ONLY_ABSTRACTION=NO"
    echo "T4_SEMANTIC_MAKEFILE_GATE=PASS"

    section "B6 — BUILD BOTH GOTO TARGETS"

    build_one "H14" "$P14_DIR" "$P14_STEM" &
    PID_H14=$!

    build_one "H235" "$P235_DIR" "$P235_STEM" &
    PID_H235=$!

    wait "$PID_H14" || true
    wait "$PID_H235" || true

    BUILD_PASS_COUNT=0

    for record in \
        "H14|$P14_DIR|$P14_STEM" \
        "H235|$P235_DIR|$P235_STEM"
    do
        IFS='|' read -r tag proof_dir stem <<<"$record"

        rc="$(cat "$OUT/${tag}_BUILD.rc" 2>/dev/null || echo 999)"
        goto_file="$proof_dir/gotos/${stem}.goto"

        echo "T4_${tag}_BUILD_RC=$rc"

        if [[ "$rc" -eq 0 && -f "$goto_file" ]]; then
            echo "T4_${tag}_GOTO_PRESENT=YES"
            echo "T4_${tag}_GOTO_SHA256=$(hash_file "$goto_file")"
            BUILD_PASS_COUNT=$((BUILD_PASS_COUNT + 1))
        else
            echo "T4_${tag}_GOTO_PRESENT=NO"
            tail -n 120 "$OUT/${tag}_BUILD.log" || true
        fi
    done

    echo "T4_GOTO_BUILD_PASS_COUNT=$BUILD_PASS_COUNT"

    [[ "$BUILD_PASS_COUNT" -eq 2 ]] ||
        fail "MONT04B_GOTO_BUILD_GATE=FAIL" 35

    section "B7 — FINAL INTEGRITY AND FREEZE VERDICT"

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "FINAL_SOURCE_INTEGRITY=FAIL" 36

    FINAL_AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all
    )"

    [[ -z "$FINAL_AUTH_STATUS" ]] ||
        fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 37

    BINDING="$OUT/MONT04B_T4_FREEZE_BINDING.env"

    cat >"$BINDING" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
AUTHORITATIVE_SOURCE=$AUTH
T4_WORKTREE=$WT
MONT04A_CAPTURE=$MONT04A_CAPTURE
MONT04A_CAPTURE_SHA256=$(hash_file "$MONT04A_CAPTURE")
T4_REGISTRY_SHA256=$(hash_file "$REGISTRY")
H14_HARNESS_SHA256=$(hash_file "$P14_HARNESS")
H14_MAKEFILE_SHA256=$(hash_file "$P14_DIR/Makefile")
H14_GOTO_SHA256=$(hash_file "$P14_DIR/gotos/${P14_STEM}.goto")
H235_HARNESS_SHA256=$(hash_file "$P235_HARNESS")
H235_MAKEFILE_SHA256=$(hash_file "$P235_DIR/Makefile")
H235_GOTO_SHA256=$(hash_file "$P235_DIR/gotos/${P235_STEM}.goto")
T4_CORE_PROPERTY_COUNT=5
T4_SUPPORTING_ASSERTION_COUNT=1
T4_THEOREM_WEAKENED=NO
T4_SOURCE_MODIFIED=NO
MONT04B_HARNESS_FREEZE_GATE=PASS
MONT04B_GOTO_BUILD_GATE=PASS_2_OF_2
EOF

    echo "MONT04B_BINDING_FILE=$BINDING"
    echo "MONT04B_BINDING_SHA256=$(hash_file "$BINDING")"
    echo "FINAL_SOURCE_INTEGRITY=PASS"
    echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
    echo "MONT_T4_CORE_PROPERTIES_FROZEN=5_OF_5"
    echo "MONT_T4_SUPPORTING_ASSERTIONS_FROZEN=1"
    echo "MONT_T4_HARNESSES_FROZEN=2"
    echo "MONT_T4_EXPLICIT_ASSERTIONS_FROZEN=6"
    echo "MONT_T4_STRONGER_LOCAL_P2_P3_FORMS=YES"
    echo "MONT_T4_THEOREM_WEAKENED=NO"
    echo "MONT_T4_NATIVE_SOURCE_MODIFIED=NO"
    echo "MONT04B_HARNESS_FREEZE_GATE=PASS"
    echo "MONT04B_GOTO_BUILD_GATE=PASS_2_OF_2"
    echo "NEXT_GATE=MONT-04C_FUNCTIONAL_NONVACUITY"
    echo "MONT04B_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
