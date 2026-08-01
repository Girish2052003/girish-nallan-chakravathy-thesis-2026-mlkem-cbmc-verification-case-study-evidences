#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_03A_CAPTURE_HASH="eaa0861b41de7973ccba8ec0dc79ab40871f821f3746a0114892c54194dbb3e6"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WT="$ROOT/MONT_T3_WORKTREE_af4c5abd"

MONT03A_CAPTURE="$ROOT/MONT03A_SOURCE_CAPTURE_20260726T221050Z/MONT03A_TERMINAL_CAPTURE_20260726T221050Z.txt"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT03B_HARNESS_FREEZE_$STAMP"
CAPTURE="$OUT/MONT03B_TERMINAL_CAPTURE_$STAMP.txt"

PARALLEL_BUILDS=2

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
harness_stem = sys.argv[2]
proof_uid = sys.argv[3]
text = path.read_text()

new_text, harness_count = re.subn(
    r'(?m)^HARNESS_FILE\s*=.*$',
    f'HARNESS_FILE = {harness_stem}',
    text,
)
new_text, uid_count = re.subn(
    r'(?m)^PROOF_UID\s*=.*$',
    f'PROOF_UID = {proof_uid}',
    new_text,
)

if harness_count != 1:
    raise SystemExit(f"HARNESS_FILE replacement count was {harness_count}, expected 1")
if uid_count != 1:
    raise SystemExit(f"PROOF_UID replacement count was {uid_count}, expected 1")

path.write_text(new_text)
PY
}

build_one()
{
    local proof_dir="$1"
    local stem="$2"
    local tag="$3"
    local log="$OUT/${tag}_BUILD.log"

    make -C "$proof_dir" MLKEM_K=3 clean >"$OUT/${tag}_CLEAN.log" 2>&1 || true
    timeout 420 make -C "$proof_dir" MLKEM_K=3 goto >"$log" 2>&1
    local rc=$?

    printf '%s\n' "$rc" >"$OUT/${tag}_BUILD.rc"

    if [[ -f "$proof_dir/gotos/${stem}.goto" ]]; then
        hash_file "$proof_dir/gotos/${stem}.goto" >"$OUT/${tag}_GOTO.sha256"
    fi
}

{
    section "MONT-03B — FULL LOCKED T3 HARNESS FREEZE + GOTO BUILD"
    echo "UTC_TIME=$STAMP"
    echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
    echo "AUTHORITATIVE_SOURCE=$AUTH"
    echo "DETACHED_T3_WORKTREE=$WT"
    echo "OUTPUT_DIRECTORY=$OUT"
    echo "PARALLEL_BUILDS=$PARALLEL_BUILDS"

    section "B0 — BIND SOURCE AND ACCEPTED MONT-03A CAPTURE"

    [[ -f "$MONT03A_CAPTURE" ]] ||
        fail "MONT03A_CAPTURE_PRESENT=NO" 20

    ACTUAL_03A_HASH="$(hash_file "$MONT03A_CAPTURE")"
    [[ "$ACTUAL_03A_HASH" == "$EXPECTED_03A_CAPTURE_HASH" ]] ||
        fail "MONT03A_CAPTURE_HASH_GATE=FAIL" 21

    grep -Fxq "MONT03A_CAPTURE_GATE=PASS" "$MONT03A_CAPTURE" ||
        fail "MONT03A_CAPTURE_MARKER_GATE=FAIL" 22

    AUTH_IS_WORKTREE="$(git -C "$AUTH" rev-parse --is-inside-work-tree 2>/dev/null || true)"
    AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null || true)"
    AUTH_STATUS="$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

    [[ "$AUTH_IS_WORKTREE" == "true" &&
       "$AUTH_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$AUTH_STATUS" ]] ||
        fail "AUTHORITATIVE_SOURCE_GATE=FAIL" 23

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "AUTHORITATIVE_HASH_GATE=FAIL" 24

    echo "MONT03A_CAPTURE_HASH_GATE=PASS"
    echo "AUTHORITATIVE_SOURCE_GATE=PASS"
    echo "AUTHORITATIVE_HASH_GATE=PASS"

    section "B1 — CREATE OR VERIFY SEPARATE DETACHED T3 WORKTREE"

    if [[ ! -e "$WT" ]]; then
        git -C "$AUTH" worktree add --detach "$WT" "$EXPECTED_COMMIT" \
            >"$OUT/WORKTREE_ADD.log" 2>&1 ||
            fail "T3_WORKTREE_CREATE_GATE=FAIL" 25
        echo "T3_WORKTREE_CREATED=YES"
    else
        echo "T3_WORKTREE_CREATED=NO_ALREADY_PRESENT"
    fi

    WT_IS_WORKTREE="$(git -C "$WT" rev-parse --is-inside-work-tree 2>/dev/null || true)"
    WT_HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null || true)"

    [[ "$WT_IS_WORKTREE" == "true" &&
       "$WT_HEAD" == "$EXPECTED_COMMIT" ]] ||
        fail "T3_WORKTREE_BINDING_GATE=FAIL" 26

    # Preserve and remove only known campaign-owned T3 prototype/proof
    # directories. Never reset or clean the whole worktree.
    PRE_CLEAN_STATUS="$(git -C "$WT" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"
    if [[ -n "$PRE_CLEAN_STATUS" ]]; then
        echo "T3_WORKTREE_PRE_CLEAN_STATUS_BEGIN"
        printf '%s\n' "$PRE_CLEAN_STATUS"
        echo "T3_WORKTREE_PRE_CLEAN_STATUS_END"
    fi

    STALE_RELATIVE_DIRS=(
        "proofs/cbmc/mont_t3_semantic_refinement"
        "proofs/cbmc/mont_t3_normalized_algebra"
        "proofs/cbmc/mont_t3_false_control"
        "proofs/cbmc/mont_t3_p1_refinement"
        "proofs/cbmc/mont_t3_p2_p3_relational"
        "proofs/cbmc/mont_t3_p4_montgomery_one"
        "proofs/cbmc/mont_t3_p5_distributivity"
        "proofs/cbmc/mont_t3_p6_associativity"
    )

    EXISTING_STALE_DIRS=()

    for rel in "${STALE_RELATIVE_DIRS[@]}"
    do
        existing="$WT/$rel"

        # Refuse archival/removal if any tracked file exists anywhere below
        # the named directory.
        TRACKED_BELOW="$(git -C "$WT" ls-files -- "$rel/" 2>/dev/null || true)"
        if [[ -n "$TRACKED_BELOW" ]]; then
            echo "T3_STALE_DIRECTORY_TRACKED_FILES_BEGIN=$rel"
            printf '%s\n' "$TRACKED_BELOW"
            echo "T3_STALE_DIRECTORY_TRACKED_FILES_END=$rel"
            fail "T3_STALE_DIRECTORY_TRACKED_FILE_GUARD=FAIL:$rel" 27
        fi

        if [[ -e "$existing" ]]; then
            EXISTING_STALE_DIRS+=("$rel")
        fi
    done

    if [[ "${#EXISTING_STALE_DIRS[@]}" -gt 0 ]]; then
        ARCHIVE="$OUT/PREEXISTING_T3_PROTOTYPES_$STAMP.tar.gz"
        MANIFEST="$OUT/PREEXISTING_T3_PROTOTYPES_$STAMP.manifest"

        : >"$MANIFEST"

        for rel in "${EXISTING_STALE_DIRS[@]}"
        do
            printf '%s\n' "$rel" >>"$MANIFEST"
            find "$WT/$rel" -type f -print0 |
                sort -z |
                xargs -0 -r sha256sum >>"$MANIFEST"
        done

        tar -C "$WT" -czf "$ARCHIVE" "${EXISTING_STALE_DIRS[@]}" ||
            fail "T3_STALE_DIRECTORY_ARCHIVE_GATE=FAIL" 27

        echo "T3_PREEXISTING_PROTOTYPE_DIRECTORY_COUNT=${#EXISTING_STALE_DIRS[@]}"
        echo "T3_PREEXISTING_PROTOTYPE_ARCHIVE=$ARCHIVE"
        echo "T3_PREEXISTING_PROTOTYPE_ARCHIVE_SHA256=$(hash_file "$ARCHIVE")"
        echo "T3_PREEXISTING_PROTOTYPE_MANIFEST_SHA256=$(hash_file "$MANIFEST")"

        for rel in "${EXISTING_STALE_DIRS[@]}"
        do
            rm -rf "$WT/$rel"
            echo "T3_STALE_DIRECTORY_ARCHIVED_AND_REMOVED=$rel"
        done

        echo "T3_STALE_DIRECTORY_ARCHIVE_GATE=PASS"
    else
        echo "T3_PREEXISTING_PROTOTYPE_DIRECTORY_COUNT=0"
        echo "T3_STALE_DIRECTORY_ARCHIVE_GATE=PASS_NOTHING_TO_ARCHIVE"
    fi

    # Recompute status after exact campaign-owned cleanup. Any remaining
    # change is unrelated and must stop the gate rather than be ignored.
    WT_STATUS="$(git -C "$WT" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"
    if [[ -n "$WT_STATUS" ]]; then
        echo "T3_WORKTREE_REMAINING_STATUS_BEGIN"
        printf '%s\n' "$WT_STATUS"
        echo "T3_WORKTREE_REMAINING_STATUS_END"
        fail "T3_WORKTREE_INITIAL_CLEAN_GATE=FAIL" 27
    fi

    [[ "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "T3_WORKTREE_SOURCE_HASH_GATE=FAIL" 28

    echo "T3_WORKTREE_BINDING_GATE=PASS"
    echo "T3_WORKTREE_INITIAL_CLEAN_GATE=PASS"
    echo "T3_WORKTREE_SOURCE_HASH_GATE=PASS"

    section "B2 — FREEZE NATIVE OVERLAP BASELINE"

    NATIVE_DIR="$WT/proofs/cbmc/fqmul"
    NATIVE_HARNESS="$NATIVE_DIR/fqmul_harness.c"
    NATIVE_MAKEFILE="$NATIVE_DIR/Makefile"

    [[ -f "$NATIVE_HARNESS" && -f "$NATIVE_MAKEFILE" ]] ||
        fail "NATIVE_FQMUL_BASELINE_PRESENT=NO" 29

    cp "$NATIVE_HARNESS" "$OUT/NATIVE_fqmul_harness.c"
    cp "$NATIVE_MAKEFILE" "$OUT/NATIVE_fqmul_Makefile"

    echo "NATIVE_FQMUL_HARNESS_SHA256=$(hash_file "$NATIVE_HARNESS")"
    echo "NATIVE_FQMUL_MAKEFILE_SHA256=$(hash_file "$NATIVE_MAKEFILE")"
    echo "NATIVE_FQMUL_CALL_COUNT=$(grep -Ec 'mlk_fqmul[[:space:]]*\(' "$NATIVE_HARNESS" || true)"
    echo "NATIVE_EXPLICIT_ASSERTION_COUNT=$(grep -Ec '__CPROVER_assert[[:space:]]*\(' "$NATIVE_HARNESS" || true)"

    section "B3 — FREEZE FULL T3 THEOREM REGISTRY"

    REGISTRY="$OUT/MONT03B_T3_THEOREM_REGISTRY.txt"

    cat >"$REGISTRY" <<'REGISTRY'
MONT-T3 TARGET
==============
Target function: mlk_fqmul
Pinned commit: af4c5abdd5958bdc65a03cd5ee86708264f93304
Production modification: forbidden
Native proof duplication: forbidden

COMMON CONSTANTS
================
q = 3329
R = 65536
signed-canonical domain = -1664 .. 1664
Montgomery representation of one = R mod q = 2285

P1 — INDEPENDENT MULTIPLICATION SEMANTIC REFINEMENT
====================================================
Domain:
  a: every int16_t
  b: signed canonical, -1664 <= b <= 1664
Direct obligations:
  P1.1 output is strictly between -q and q
  P1.2 exact implementation-independent decomposition:
       R * mlk_fqmul(a,b) + q * t_math = a*b
       where t_math is the signed representative of
       ((a*b mod R) * q^{-1}) mod R
No call to mlk_montgomery_reduce is used as the oracle.

P2 — EXACT COMMUTATIVITY
========================
Domain:
  a,b: independently nondeterministic signed-canonical int16_t values
Direct obligation:
  mlk_fqmul(a,b) == mlk_fqmul(b,a)

P3 — ZERO ANNIHILATION AND ZERO-PRODUCT REFLECTION
===================================================
Domains:
  left zero law: a is every int16_t
  right zero law: b is signed canonical
  reflection: a,b are independently signed canonical
Direct obligations:
  mlk_fqmul(a,0) == 0
  mlk_fqmul(0,b) == 0
  mlk_fqmul(a,b) == 0 iff a == 0 or b == 0

P4 — MONTGOMERY-ONE IDENTITY AFTER NORMALIZATION
=================================================
Domain:
  x: signed canonical
Direct obligation:
  normalize_q(mlk_fqmul(2285,x)) == x

P5 — DISTRIBUTIVITY AFTER NORMALIZATION
=======================================
Domain:
  a,b,c: independently signed canonical
Direct obligation:
  normalize_q(mlk_fqmul(a+b,c))
    ==
  normalize_q(mlk_fqmul(a,c) + mlk_fqmul(b,c))
The mathematical sum a+b lies in [-3328,3328] and fits int16_t.

P6 — ASSOCIATIVITY AFTER NORMALIZATION
======================================
Domain:
  a,b,c: independently signed canonical
Direct obligation:
  normalize_q(mlk_fqmul(mlk_fqmul(a,b),c))
    ==
  normalize_q(mlk_fqmul(a,normalize_q(mlk_fqmul(b,c))))

SOLVER-PACKAGING RULE
=====================
P1, P2/P3, P4, P5 and P6 are placed in five separate harnesses.
This is execution partitioning only. Every frozen property remains mandatory.
REGISTRY

    echo "T3_REGISTRY_SHA256=$(hash_file "$REGISTRY")"
    grep -Fq "P1 — INDEPENDENT" "$REGISTRY" &&
    grep -Fq "P2 — EXACT COMMUTATIVITY" "$REGISTRY" &&
    grep -Fq "P3 — ZERO ANNIHILATION" "$REGISTRY" &&
    grep -Fq "P4 — MONTGOMERY-ONE" "$REGISTRY" &&
    grep -Fq "P5 — DISTRIBUTIVITY" "$REGISTRY" &&
    grep -Fq "P6 — ASSOCIATIVITY" "$REGISTRY" ||
        fail "T3_REGISTRY_COMPLETENESS_GATE=FAIL" 30

    python3 - <<'PY'
q = 3329
R = 1 << 16
assert R % q == 2285
print("MONTGOMERY_ONE_CONSTANT_GATE=PASS")
PY

    echo "T3_REGISTRY_COMPLETENESS_GATE=PASS"

    section "B4 — CREATE FIVE FULL-STRENGTH T3 HARNESSES"

    P1_DIR="$WT/proofs/cbmc/mont_t3_p1_refinement"
    P23_DIR="$WT/proofs/cbmc/mont_t3_p2_p3_relational"
    P4_DIR="$WT/proofs/cbmc/mont_t3_p4_montgomery_one"
    P5_DIR="$WT/proofs/cbmc/mont_t3_p5_distributivity"
    P6_DIR="$WT/proofs/cbmc/mont_t3_p6_associativity"

    mkdir -p "$P1_DIR" "$P23_DIR" "$P4_DIR" "$P5_DIR" "$P6_DIR"

    cat >"$P1_DIR/mont_t3_p1_refinement_harness.c" <<'C'
#include <stdint.h>
#include <limits.h>

#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_QINV ((uint32_t)62209)

extern int16_t nondet_int16_t(void);
int16_t mlk_fqmul(int16_t a, int16_t b);

void harness(void)
{
  int16_t a;
  int16_t b;
  int16_t result;
  int32_t product;
  uint16_t product_low;
  uint32_t inverted_low;
  int32_t witness_t;

  a = nondet_int16_t();
  b = nondet_int16_t();

  __CPROVER_assume(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF);

  product = (int32_t)a * (int32_t)b;
  result = mlk_fqmul(a, b);

  product_low = (uint16_t)product;
  inverted_low =
      (((uint32_t)product_low * MONT_QINV) & (uint32_t)UINT16_MAX);

  witness_t =
      (inverted_low <= (uint32_t)INT16_MAX)
          ? (int32_t)inverted_low
          : (int32_t)inverted_low - (int32_t)65536;

  __CPROVER_assert(
      result > -MLKEM_Q && result < MLKEM_Q,
      "MONT-T3.P1.1.independent_output_bound");

  __CPROVER_assert(
      ((int64_t)result * MONT_R) +
              ((int64_t)witness_t * (int64_t)MLKEM_Q) ==
          (int64_t)product,
      "MONT-T3.P1.2.independent_exact_multiplication_refinement");
}
C

    cat >"$P23_DIR/mont_t3_p2_p3_relational_harness.c" <<'C'
#include <stdint.h>

#include "../../../mlkem/src/poly.h"

extern int16_t nondet_int16_t(void);
int16_t mlk_fqmul(int16_t a, int16_t b);

void harness(void)
{
  int16_t a_any;
  int16_t a;
  int16_t b;
  int16_t ab;
  int16_t ba;
  int16_t a_zero;
  int16_t zero_b;

  a_any = nondet_int16_t();
  a = nondet_int16_t();
  b = nondet_int16_t();

  __CPROVER_assume(a > -MLKEM_Q_HALF && a < MLKEM_Q_HALF);
  __CPROVER_assume(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF);

  ab = mlk_fqmul(a, b);
  ba = mlk_fqmul(b, a);
  a_zero = mlk_fqmul(a_any, 0);
  zero_b = mlk_fqmul(0, b);

  __CPROVER_assert(
      ab == ba,
      "MONT-T3.P2.exact_commutativity");

  __CPROVER_assert(
      a_zero == 0,
      "MONT-T3.P3.1.left_zero_annihilation_full_first_operand_domain");

  __CPROVER_assert(
      zero_b == 0,
      "MONT-T3.P3.2.right_zero_annihilation");

  __CPROVER_assert(
      (ab == 0) == ((a == 0) || (b == 0)),
      "MONT-T3.P3.3.zero_product_reflection");
}
C

    cat >"$P4_DIR/mont_t3_p4_montgomery_one_harness.c" <<'C'
#include <stdint.h>

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
  int16_t x;
  int16_t product;
  int16_t normalized;

  x = nondet_int16_t();
  __CPROVER_assume(x > -MLKEM_Q_HALF && x < MLKEM_Q_HALF);

  product = mlk_fqmul(MONT_ONE, x);
  normalized = normalize_q_once((int32_t)product);

  __CPROVER_assert(
      normalized == x,
      "MONT-T3.P4.Montgomery_one_identity_after_normalization");
}
C

    cat >"$P5_DIR/mont_t3_p5_distributivity_harness.c" <<'C'
#include <stdint.h>

#include "../../../mlkem/src/poly.h"

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

static int16_t normalize_q_twice(int32_t value)
{
  if (value >= MLKEM_Q_HALF)
  {
    value -= MLKEM_Q;
  }
  if (value >= MLKEM_Q_HALF)
  {
    value -= MLKEM_Q;
  }

  if (value <= -MLKEM_Q_HALF)
  {
    value += MLKEM_Q;
  }
  if (value <= -MLKEM_Q_HALF)
  {
    value += MLKEM_Q;
  }

  return (int16_t)value;
}

void harness(void)
{
  int16_t a;
  int16_t b;
  int16_t c;
  int16_t sum_ab;
  int16_t left_raw;
  int16_t right_a;
  int16_t right_b;
  int16_t left_normalized;
  int16_t right_normalized;

  a = nondet_int16_t();
  b = nondet_int16_t();
  c = nondet_int16_t();

  __CPROVER_assume(a > -MLKEM_Q_HALF && a < MLKEM_Q_HALF);
  __CPROVER_assume(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF);
  __CPROVER_assume(c > -MLKEM_Q_HALF && c < MLKEM_Q_HALF);

  sum_ab = (int16_t)((int32_t)a + (int32_t)b);

  left_raw = mlk_fqmul(sum_ab, c);
  right_a = mlk_fqmul(a, c);
  right_b = mlk_fqmul(b, c);

  left_normalized = normalize_q_once((int32_t)left_raw);
  right_normalized =
      normalize_q_twice((int32_t)right_a + (int32_t)right_b);

  __CPROVER_assert(
      left_normalized == right_normalized,
      "MONT-T3.P5.distributivity_after_normalization");
}
C

    cat >"$P6_DIR/mont_t3_p6_associativity_harness.c" <<'C'
#include <stdint.h>

#include "../../../mlkem/src/poly.h"

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
  int16_t a;
  int16_t b;
  int16_t c;
  int16_t ab;
  int16_t bc;
  int16_t bc_normalized;
  int16_t left_raw;
  int16_t right_raw;
  int16_t left_normalized;
  int16_t right_normalized;

  a = nondet_int16_t();
  b = nondet_int16_t();
  c = nondet_int16_t();

  __CPROVER_assume(a > -MLKEM_Q_HALF && a < MLKEM_Q_HALF);
  __CPROVER_assume(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF);
  __CPROVER_assume(c > -MLKEM_Q_HALF && c < MLKEM_Q_HALF);

  ab = mlk_fqmul(a, b);
  left_raw = mlk_fqmul(ab, c);

  bc = mlk_fqmul(b, c);
  bc_normalized = normalize_q_once((int32_t)bc);
  right_raw = mlk_fqmul(a, bc_normalized);

  left_normalized = normalize_q_once((int32_t)left_raw);
  right_normalized = normalize_q_once((int32_t)right_raw);

  __CPROVER_assert(
      left_normalized == right_normalized,
      "MONT-T3.P6.associativity_after_normalization");
}
C

    prepare_makefile "$NATIVE_MAKEFILE" \
        "$P1_DIR/Makefile" \
        "mont_t3_p1_refinement_harness" \
        "mont_t3_p1_refinement"

    prepare_makefile "$NATIVE_MAKEFILE" \
        "$P23_DIR/Makefile" \
        "mont_t3_p2_p3_relational_harness" \
        "mont_t3_p2_p3_relational"

    prepare_makefile "$NATIVE_MAKEFILE" \
        "$P4_DIR/Makefile" \
        "mont_t3_p4_montgomery_one_harness" \
        "mont_t3_p4_montgomery_one"

    prepare_makefile "$NATIVE_MAKEFILE" \
        "$P5_DIR/Makefile" \
        "mont_t3_p5_distributivity_harness" \
        "mont_t3_p5_distributivity"

    prepare_makefile "$NATIVE_MAKEFILE" \
        "$P6_DIR/Makefile" \
        "mont_t3_p6_associativity_harness" \
        "mont_t3_p6_associativity"

    declare -a TAGS=("P1" "P23" "P4" "P5" "P6")
    declare -a DIRS=("$P1_DIR" "$P23_DIR" "$P4_DIR" "$P5_DIR" "$P6_DIR")
    declare -a STEMS=(
        "mont_t3_p1_refinement_harness"
        "mont_t3_p2_p3_relational_harness"
        "mont_t3_p4_montgomery_one_harness"
        "mont_t3_p5_distributivity_harness"
        "mont_t3_p6_associativity_harness"
    )

    for i in "${!TAGS[@]}"
    do
        echo "T3_${TAGS[$i]}_HARNESS_SHA256=$(hash_file "${DIRS[$i]}/${STEMS[$i]}.c")"
        echo "T3_${TAGS[$i]}_MAKEFILE_SHA256=$(hash_file "${DIRS[$i]}/Makefile")"
    done

    TOTAL_EXPLICIT_ASSERTIONS="$(
        grep -hEc '__CPROVER_assert[[:space:]]*\(' \
            "$P1_DIR/mont_t3_p1_refinement_harness.c" \
            "$P23_DIR/mont_t3_p2_p3_relational_harness.c" \
            "$P4_DIR/mont_t3_p4_montgomery_one_harness.c" \
            "$P5_DIR/mont_t3_p5_distributivity_harness.c" \
            "$P6_DIR/mont_t3_p6_associativity_harness.c" |
        awk '{sum += $1} END {print sum + 0}'
    )"

    echo "T3_HARNESS_COUNT=5"
    echo "T3_EXPLICIT_ASSERTION_COUNT=$TOTAL_EXPLICIT_ASSERTIONS"

    [[ "$TOTAL_EXPLICIT_ASSERTIONS" -eq 9 ]] ||
        fail "T3_ASSERTION_FREEZE_GATE=FAIL" 31

    echo "T3_ASSERTION_FREEZE_GATE=PASS"

    section "B5 — BUILD ALL FIVE GOTO TARGETS WITH LIMITED PARALLELISM"

    declare -a ACTIVE_PIDS=()
    declare -a ACTIVE_TAGS=()

    for i in "${!TAGS[@]}"
    do
        build_one "${DIRS[$i]}" "${STEMS[$i]}" "${TAGS[$i]}" &
        ACTIVE_PIDS+=("$!")
        ACTIVE_TAGS+=("${TAGS[$i]}")

        if [[ "${#ACTIVE_PIDS[@]}" -ge "$PARALLEL_BUILDS" ]]; then
            wait "${ACTIVE_PIDS[0]}" || true
            ACTIVE_PIDS=("${ACTIVE_PIDS[@]:1}")
            ACTIVE_TAGS=("${ACTIVE_TAGS[@]:1}")
        fi
    done

    for pid in "${ACTIVE_PIDS[@]}"
    do
        wait "$pid" || true
    done

    BUILD_PASS_COUNT=0

    for i in "${!TAGS[@]}"
    do
        TAG="${TAGS[$i]}"
        RC="$(cat "$OUT/${TAG}_BUILD.rc" 2>/dev/null || echo 999)"
        GOTO_FILE="${DIRS[$i]}/gotos/${STEMS[$i]}.goto"

        echo "T3_${TAG}_BUILD_RC=$RC"

        if [[ "$RC" -eq 0 && -f "$GOTO_FILE" ]]; then
            echo "T3_${TAG}_GOTO_PRESENT=YES"
            echo "T3_${TAG}_GOTO_SHA256=$(hash_file "$GOTO_FILE")"
            BUILD_PASS_COUNT=$((BUILD_PASS_COUNT + 1))
        else
            echo "T3_${TAG}_GOTO_PRESENT=NO"
            tail -n 80 "$OUT/${TAG}_BUILD.log" || true
        fi
    done

    echo "T3_GOTO_BUILD_PASS_COUNT=$BUILD_PASS_COUNT"

    [[ "$BUILD_PASS_COUNT" -eq 5 ]] ||
        fail "MONT03B_GOTO_BUILD_GATE=FAIL" 32

    section "B6 — FINAL INTEGRITY AND FREEZE VERDICT"

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "FINAL_SOURCE_INTEGRITY=FAIL" 33

    FINAL_AUTH_STATUS="$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all)"
    [[ -z "$FINAL_AUTH_STATUS" ]] ||
        fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 34

    echo "FINAL_SOURCE_INTEGRITY=PASS"
    echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
    echo "MONT_T3_THEOREM_FAMILIES_FROZEN=6_OF_6"
    echo "MONT_T3_HARNESSES_FROZEN=5"
    echo "MONT_T3_ASSERTIONS_FROZEN=9"
    echo "MONT_T3_THEOREM_WEAKENED=NO"
    echo "MONT_T3_NATIVE_SOURCE_MODIFIED=NO"
    echo "MONT03B_HARNESS_FREEZE_GATE=PASS"
    echo "MONT03B_GOTO_BUILD_GATE=PASS_5_OF_5"
    echo "NEXT_GATE=MONT-03C_FUNCTIONAL_NONVACUITY"
    echo "MONT03B_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
