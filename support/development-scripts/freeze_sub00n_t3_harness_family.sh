#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
PREREG_DIR="$ROOT/SUB00M_BATCH3_T3_CANCELLATION_PREREGISTRATION"
PREREG_MANIFEST="$PREREG_DIR/SUB00M_ARTIFACT_MANIFEST.sha256"
SOURCE="$ROOT/source"
POLY_H="$SOURCE/mlkem/src/poly.h"
POLY_C="$SOURCE/mlkem/src/poly.c"

OUT="$ROOT/SUB00N_BATCH3_T3_HARNESS_FREEZE_V1"
HARNESS_DIR="$OUT/harnesses"
PROVENANCE_DIR="$OUT/provenance"

EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

test -d "$ROOT" || fail "Missing campaign root: $ROOT"
test -d "$PREREG_DIR" || fail "Missing SUB00M preregistration directory: $PREREG_DIR"
test -f "$PREREG_MANIFEST" || fail "Missing SUB00M manifest: $PREREG_MANIFEST"
test -f "$POLY_H" || fail "Missing production header: $POLY_H"
test -f "$POLY_C" || fail "Missing production source: $POLY_C"
test ! -e "$OUT" || fail "Output already exists; nothing overwritten: $OUT"

echo "=== VERIFY SUB00M PARENT MANIFEST ==="
(
  cd "$PREREG_DIR"
  sha256sum -c "$(basename "$PREREG_MANIFEST")"
)

mkdir -p "$HARNESS_DIR" "$PROVENANCE_DIR"

ACTIVE_PROCESSES="$(
  pgrep -af 'cbmc|goto-cc|goto-gcc|goto-clang|run_sub00l|run_sub00m|run_sub00n' 2>/dev/null |
  awk -v self="$$" -v parent="$PPID" '$1 != self && $1 != parent' || true
)"

{
  echo "SUB00N T3 HARNESS-FREEZE ENVIRONMENT"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"
  echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
  echo "ROOT=$ROOT"
  echo "SOURCE=$SOURCE"
  echo "OUT=$OUT"
  echo "CBMC=$(cbmc --version 2>&1 | head -1 || true)"
  echo "GOTO_CC=$(command -v goto-cc || true)"
  echo "GCC=$(gcc --version 2>&1 | head -1 || true)"
  echo "ARCH=$(uname -m)"
  echo "BYTE_ORDER=$(python3 -c 'import sys; print(sys.byteorder)')"
  echo
  echo "ACTIVE_RELATED_PROCESSES_AT_FREEZE:"
  if [ -n "$ACTIVE_PROCESSES" ]; then
    printf '%s\n' "$ACTIVE_PROCESSES"
    echo "T3_EXECUTION_PERMISSION=DENIED_WHILE_RELATED_PROCESS_ACTIVE"
  else
    echo "NONE"
    echo "T3_EXECUTION_PERMISSION=ELIGIBLE_AFTER_SEPARATE_PREFLIGHT"
  fi
} > "$OUT/ENVIRONMENT.txt"

cp "$PREREG_DIR/SUB00M_T3_THEOREM_PREREGISTRATION.md" \
   "$PROVENANCE_DIR/SUB00M_T3_THEOREM_PREREGISTRATION.md"
cp "$PREREG_DIR/ENVIRONMENT.txt" \
   "$PROVENANCE_DIR/SUB00M_ENVIRONMENT.txt"
cp "$PREREG_DIR/PRODUCTION_SOURCE_DISCOVERY.txt" \
   "$PROVENANCE_DIR/SUB00M_PRODUCTION_SOURCE_DISCOVERY.txt"
cp "$PREREG_MANIFEST" \
   "$PROVENANCE_DIR/SUB00M_ARTIFACT_MANIFEST.sha256"

cat > "$HARNESS_DIR/sub_t3_common.h" <<'EOF'
#ifndef SUB_T3_COMMON_H
#define SUB_T3_COMMON_H

#include <limits.h>
#include <stdint.h>

#include "poly.h"

enum
{
  SUB_T3_FIPS_N = 256,
  SUB_T3_FIPS_Q = 3329
};

static void sub_t3_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T3_MACHINE: CHAR_BIT must equal 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T3_MACHINE: short must be 16 bits");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T3_MACHINE: int must be 32 bits");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T3_MACHINE: int16_t must be 16 bits");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T3_MACHINE: int32_t must be 32 bits");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T3_MACHINE: pointer width must be 64 bits");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T3_MACHINE: negative right shift must preserve sign");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T3_MACHINE: negative right shift must round arithmetically");

  __CPROVER_assert(MLKEM_N == SUB_T3_FIPS_N,
                   "SUB_T3_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == SUB_T3_FIPS_Q,
                   "SUB_T3_PARAMETER: MLKEM_Q must equal FIPS_Q");
}

static void sub_t3_zero_poly(mlk_poly *p)
{
  uint32_t i;
  for (i = 0u; i < MLKEM_N; i++)
  {
    p->coeffs[i] = 0;
  }
}

#endif
EOF

cat > "$HARNESS_DIR/sub_t3a_exact_sub_add_harness.c" <<'EOF'
#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A;
  mlk_poly saved_B;
  mlk_poly R;
  mlk_poly RB;
  mlk_poly D;
  mlk_poly D_snapshot;
  uint32_t i;

  sub_t3_check_machine_model();

  for (i = 0u; i < MLKEM_N; i++)
  {
    int16_t a_i;
    int16_t b_i;
    int32_t d;

    A0.coeffs[i] = a_i;
    B0.coeffs[i] = b_i;

    d = (int32_t)a_i - (int32_t)b_i;
    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);
  }

  saved_A = A0;
  saved_B = B0;
  R = A0;
  RB = B0;

  mlk_poly_sub(&R, &RB);
  D = R;
  D_snapshot = D;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected_difference =
        (int32_t)saved_A.coeffs[i] - (int32_t)saved_B.coeffs[i];

    __CPROVER_assert((int32_t)D.coeffs[i] == expected_difference,
                     "SUB_T3A_INTERMEDIATE: subtraction must be exact");
    __CPROVER_assert(RB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3A_FRAME: B copy unchanged after subtraction");
  }

  mlk_poly_add(&R, &RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(R.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3A_CANCELLATION: (A-B)+B must equal A");
    __CPROVER_assert(RB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3A_FRAME: B copy unchanged after recovery addition");
    __CPROVER_assert(D.coeffs[i] == D_snapshot.coeffs[i],
                     "SUB_T3A_FRAME: saved difference remains unchanged");
    __CPROVER_assert(A0.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3A_FRAME: original A remains unchanged");
    __CPROVER_assert(B0.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3A_FRAME: original B remains unchanged");
  }

  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3b_exact_add_sub_harness.c" <<'EOF'
#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A;
  mlk_poly saved_B;
  mlk_poly R;
  mlk_poly RB;
  mlk_poly S;
  mlk_poly S_snapshot;
  uint32_t i;

  sub_t3_check_machine_model();

  for (i = 0u; i < MLKEM_N; i++)
  {
    int16_t a_i;
    int16_t b_i;
    int32_t s;

    A0.coeffs[i] = a_i;
    B0.coeffs[i] = b_i;

    s = (int32_t)a_i + (int32_t)b_i;
    __CPROVER_assume(s >= (int32_t)INT16_MIN);
    __CPROVER_assume(s <= (int32_t)INT16_MAX);
  }

  saved_A = A0;
  saved_B = B0;
  R = A0;
  RB = B0;

  mlk_poly_add(&R, &RB);
  S = R;
  S_snapshot = S;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected_sum =
        (int32_t)saved_A.coeffs[i] + (int32_t)saved_B.coeffs[i];

    __CPROVER_assert((int32_t)S.coeffs[i] == expected_sum,
                     "SUB_T3B_INTERMEDIATE: addition must be exact");
    __CPROVER_assert(RB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3B_FRAME: B copy unchanged after addition");
  }

  mlk_poly_sub(&R, &RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(R.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3B_CANCELLATION: (A+B)-B must equal A");
    __CPROVER_assert(RB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3B_FRAME: B copy unchanged after recovery subtraction");
    __CPROVER_assert(S.coeffs[i] == S_snapshot.coeffs[i],
                     "SUB_T3B_FRAME: saved sum remains unchanged");
    __CPROVER_assert(A0.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3B_FRAME: original A remains unchanged");
    __CPROVER_assert(B0.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3B_FRAME: original B remains unchanged");
  }

  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3c_modular_cancellation_harness.c" <<'EOF'
#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A;
  mlk_poly saved_B;
  mlk_poly X;
  mlk_poly XB;
  mlk_poly NB;
  mlk_poly NA;
  mlk_poly X_after_first_normalization;
  mlk_poly NB_after_normalization;
  mlk_poly X_after_recovery_addition;
  mlk_poly final_X_snapshot;
  uint32_t i;

  sub_t3_check_machine_model();

  for (i = 0u; i < MLKEM_N; i++)
  {
    int16_t a_i;
    int16_t b_i;
    int32_t d;

    A0.coeffs[i] = a_i;
    B0.coeffs[i] = b_i;

    d = (int32_t)a_i - (int32_t)b_i;
    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);
  }

  saved_A = A0;
  saved_B = B0;
  X = A0;
  XB = B0;
  NB = B0;
  NA = A0;

  mlk_poly_sub(&X, &XB);
  mlk_poly_reduce(&X);
  X_after_first_normalization = X;

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(XB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3C_FRAME: subtraction operand remains unchanged");
    __CPROVER_assert(X.coeffs[i] >= 0,
                     "SUB_T3C_RANGE: first normalized difference is nonnegative");
    __CPROVER_assert(X.coeffs[i] < SUB_T3_FIPS_Q,
                     "SUB_T3C_RANGE: first normalized difference is below q");
  }

  mlk_poly_reduce(&NB);
  NB_after_normalization = NB;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t recovery_sum =
        (int32_t)X.coeffs[i] + (int32_t)NB.coeffs[i];

    __CPROVER_assert(X.coeffs[i] ==
                         X_after_first_normalization.coeffs[i],
                     "SUB_T3C_FRAME: X unchanged while B is normalized");
    __CPROVER_assert(NB.coeffs[i] >= 0,
                     "SUB_T3C_RANGE: normalized B is nonnegative");
    __CPROVER_assert(NB.coeffs[i] < SUB_T3_FIPS_Q,
                     "SUB_T3C_RANGE: normalized B is below q");
    __CPROVER_assert(recovery_sum >= 0,
                     "SUB_T3C_ADD_BOUND: recovery sum is nonnegative");
    __CPROVER_assert(recovery_sum <=
                         2 * (SUB_T3_FIPS_Q - 1),
                     "SUB_T3C_ADD_BOUND: recovery sum is at most 6656");
    __CPROVER_assert(recovery_sum <= (int32_t)INT16_MAX,
                     "SUB_T3C_ADD_BOUND: recovery sum fits int16_t");
  }

  mlk_poly_add(&X, &NB);
  X_after_recovery_addition = X;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t exact_recovery_sum =
        (int32_t)X_after_first_normalization.coeffs[i] +
        (int32_t)NB_after_normalization.coeffs[i];

    __CPROVER_assert((int32_t)X.coeffs[i] == exact_recovery_sum,
                     "SUB_T3C_INTERMEDIATE: recovery addition must be exact");
    __CPROVER_assert(NB.coeffs[i] ==
                         NB_after_normalization.coeffs[i],
                     "SUB_T3C_FRAME: normalized B unchanged by recovery addition");
  }

  mlk_poly_reduce(&X);
  final_X_snapshot = X;

  mlk_poly_reduce(&NA);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t a32 = (int32_t)saved_A.coeffs[i];
    uint32_t shifted =
        (uint32_t)(a32 + 10 * SUB_T3_FIPS_Q);
    uint32_t expected_A =
        shifted % (uint32_t)SUB_T3_FIPS_Q;

    __CPROVER_assert(shifted >= 522u,
                     "SUB_T3C_ORACLE: shifted A lower bound");
    __CPROVER_assert(shifted <= 66057u,
                     "SUB_T3C_ORACLE: shifted A upper bound");

    __CPROVER_assert(X.coeffs[i] == NA.coeffs[i],
                     "SUB_T3C_CANCELLATION: N(N(A-B)+N(B)) must equal N(A)");
    __CPROVER_assert((uint32_t)X.coeffs[i] == expected_A,
                     "SUB_T3C_ORACLE: recovered result must equal FIPS oracle");
    __CPROVER_assert((uint32_t)NA.coeffs[i] == expected_A,
                     "SUB_T3C_ORACLE: normalized A must equal FIPS oracle");

    __CPROVER_assert(X.coeffs[i] >= 0,
                     "SUB_T3C_FINAL_RANGE: recovered result nonnegative");
    __CPROVER_assert(X.coeffs[i] < SUB_T3_FIPS_Q,
                     "SUB_T3C_FINAL_RANGE: recovered result below q");
    __CPROVER_assert(NA.coeffs[i] >= 0,
                     "SUB_T3C_FINAL_RANGE: normalized A nonnegative");
    __CPROVER_assert(NA.coeffs[i] < SUB_T3_FIPS_Q,
                     "SUB_T3C_FINAL_RANGE: normalized A below q");

    __CPROVER_assert(X.coeffs[i] == final_X_snapshot.coeffs[i],
                     "SUB_T3C_FRAME: final X unchanged while A is normalized");
    __CPROVER_assert(NB.coeffs[i] ==
                         NB_after_normalization.coeffs[i],
                     "SUB_T3C_FRAME: normalized B remains unchanged");
    __CPROVER_assert(A0.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3C_FRAME: original A remains unchanged");
    __CPROVER_assert(B0.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3C_FRAME: original B remains unchanged");
    __CPROVER_assert(X_after_recovery_addition.coeffs[i] >= 0,
                     "SUB_T3C_SNAPSHOT: recovery-addition snapshot retained");
  }

  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3_coverage_harness.c" <<'EOF'
#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A;
  mlk_poly B;
  mlk_poly X;
  mlk_poly NB;
  uint32_t i;

  int has_positive_b = 0;
  int has_negative_b = 0;
  int has_zero_b = 0;
  int has_positive_difference = 0;
  int has_negative_difference = 0;
  int has_zero_difference = 0;
  int has_noncanonical_positive_a = 0;
  int has_noncanonical_negative_a = 0;
  int has_noncanonical_positive_b = 0;
  int has_noncanonical_negative_b = 0;
  int has_valid_difference_min = 0;
  int has_valid_difference_max = 0;
  int has_valid_addition_min = 0;
  int has_valid_addition_max = 0;
  int coefficient_0_nontrivial = 0;
  int coefficient_255_nontrivial = 0;
  int recovery_sum_0 = 0;
  int recovery_sum_q_minus_1 = 0;
  int recovery_sum_q = 0;
  int recovery_sum_2q_minus_2 = 0;
  int recovery_without_wrap = 0;
  int recovery_with_wrap = 0;

  sub_t3_check_machine_model();

  for (i = 0u; i < MLKEM_N; i++)
  {
    int16_t a_i;
    int16_t b_i;
    int32_t d;
    int32_t s;

    A.coeffs[i] = a_i;
    B.coeffs[i] = b_i;

    d = (int32_t)a_i - (int32_t)b_i;
    s = (int32_t)a_i + (int32_t)b_i;

    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);
    __CPROVER_assume(s >= (int32_t)INT16_MIN);
    __CPROVER_assume(s <= (int32_t)INT16_MAX);

    if (b_i > 0) has_positive_b = 1;
    if (b_i < 0) has_negative_b = 1;
    if (b_i == 0) has_zero_b = 1;
    if (d > 0) has_positive_difference = 1;
    if (d < 0) has_negative_difference = 1;
    if (d == 0) has_zero_difference = 1;
    if (a_i >= SUB_T3_FIPS_Q) has_noncanonical_positive_a = 1;
    if (a_i < 0) has_noncanonical_negative_a = 1;
    if (b_i >= SUB_T3_FIPS_Q) has_noncanonical_positive_b = 1;
    if (b_i < 0) has_noncanonical_negative_b = 1;
    if (d == (int32_t)INT16_MIN) has_valid_difference_min = 1;
    if (d == (int32_t)INT16_MAX) has_valid_difference_max = 1;
    if (s == (int32_t)INT16_MIN) has_valid_addition_min = 1;
    if (s == (int32_t)INT16_MAX) has_valid_addition_max = 1;
  }

  if (A.coeffs[0] != B.coeffs[0]) coefficient_0_nontrivial = 1;
  if (A.coeffs[MLKEM_N - 1u] != B.coeffs[MLKEM_N - 1u])
    coefficient_255_nontrivial = 1;

  X = A;
  NB = B;
  mlk_poly_sub(&X, &B);
  mlk_poly_reduce(&X);
  mlk_poly_reduce(&NB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t recovery_sum =
        (int32_t)X.coeffs[i] + (int32_t)NB.coeffs[i];

    if (recovery_sum == 0) recovery_sum_0 = 1;
    if (recovery_sum == SUB_T3_FIPS_Q - 1) recovery_sum_q_minus_1 = 1;
    if (recovery_sum == SUB_T3_FIPS_Q) recovery_sum_q = 1;
    if (recovery_sum == 2 * (SUB_T3_FIPS_Q - 1))
      recovery_sum_2q_minus_2 = 1;
    if (recovery_sum < SUB_T3_FIPS_Q) recovery_without_wrap = 1;
    if (recovery_sum >= SUB_T3_FIPS_Q) recovery_with_wrap = 1;
  }

  __CPROVER_cover(has_positive_b);
  __CPROVER_cover(has_negative_b);
  __CPROVER_cover(has_zero_b);
  __CPROVER_cover(has_positive_difference);
  __CPROVER_cover(has_negative_difference);
  __CPROVER_cover(has_zero_difference);
  __CPROVER_cover(has_noncanonical_positive_a);
  __CPROVER_cover(has_noncanonical_negative_a);
  __CPROVER_cover(has_noncanonical_positive_b);
  __CPROVER_cover(has_noncanonical_negative_b);
  __CPROVER_cover(has_valid_difference_min);
  __CPROVER_cover(has_valid_difference_max);
  __CPROVER_cover(has_valid_addition_min);
  __CPROVER_cover(has_valid_addition_max);
  __CPROVER_cover(coefficient_0_nontrivial);
  __CPROVER_cover(coefficient_255_nontrivial);
  __CPROVER_cover(recovery_sum_0);
  __CPROVER_cover(recovery_sum_q_minus_1);
  __CPROVER_cover(recovery_sum_q);
  __CPROVER_cover(recovery_sum_2q_minus_2);
  __CPROVER_cover(recovery_without_wrap);
  __CPROVER_cover(recovery_with_wrap);
  __CPROVER_cover(1);

  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3a_valid_lower_harness.c" <<'EOF'
#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[0] = (int16_t)(INT16_MIN + 1);
  B.coeffs[0] = 1;
  __CPROVER_assert((int32_t)R.coeffs[0] - B.coeffs[0] == INT16_MIN,
                   "SUB_T3A_VALID_LOWER: difference equals INT16_MIN");
  mlk_poly_sub(&R, &B);
  mlk_poly_add(&R, &B);
  __CPROVER_assert(R.coeffs[0] == (int16_t)(INT16_MIN + 1),
                   "SUB_T3A_VALID_LOWER: cancellation succeeds");
  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3a_valid_upper_harness.c" <<'EOF'
#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[MLKEM_N - 1u] = (int16_t)(INT16_MAX - 1);
  B.coeffs[MLKEM_N - 1u] = -1;
  __CPROVER_assert((int32_t)R.coeffs[MLKEM_N - 1u] -
                       B.coeffs[MLKEM_N - 1u] == INT16_MAX,
                   "SUB_T3A_VALID_UPPER: difference equals INT16_MAX");
  mlk_poly_sub(&R, &B);
  mlk_poly_add(&R, &B);
  __CPROVER_assert(R.coeffs[MLKEM_N - 1u] ==
                       (int16_t)(INT16_MAX - 1),
                   "SUB_T3A_VALID_UPPER: cancellation succeeds");
  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3a_invalid_lower_harness.c" <<'EOF'
#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  int32_t d;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[0] = INT16_MIN;
  B.coeffs[0] = 1;
  d = (int32_t)R.coeffs[0] - (int32_t)B.coeffs[0];
  __CPROVER_assert(d >= INT16_MIN,
                   "SUB_T3A_INVALID_LOWER_CONTROL: deliberately outside domain");
  mlk_poly_sub(&R, &B);
  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3a_invalid_upper_harness.c" <<'EOF'
#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  int32_t d;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[0] = INT16_MAX;
  B.coeffs[0] = -1;
  d = (int32_t)R.coeffs[0] - (int32_t)B.coeffs[0];
  __CPROVER_assert(d <= INT16_MAX,
                   "SUB_T3A_INVALID_UPPER_CONTROL: deliberately outside domain");
  mlk_poly_sub(&R, &B);
  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3b_valid_lower_harness.c" <<'EOF'
#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[0] = (int16_t)(INT16_MIN + 1);
  B.coeffs[0] = -1;
  __CPROVER_assert((int32_t)R.coeffs[0] + B.coeffs[0] == INT16_MIN,
                   "SUB_T3B_VALID_LOWER: sum equals INT16_MIN");
  mlk_poly_add(&R, &B);
  mlk_poly_sub(&R, &B);
  __CPROVER_assert(R.coeffs[0] == (int16_t)(INT16_MIN + 1),
                   "SUB_T3B_VALID_LOWER: cancellation succeeds");
  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3b_valid_upper_harness.c" <<'EOF'
#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[MLKEM_N - 1u] = (int16_t)(INT16_MAX - 1);
  B.coeffs[MLKEM_N - 1u] = 1;
  __CPROVER_assert((int32_t)R.coeffs[MLKEM_N - 1u] +
                       B.coeffs[MLKEM_N - 1u] == INT16_MAX,
                   "SUB_T3B_VALID_UPPER: sum equals INT16_MAX");
  mlk_poly_add(&R, &B);
  mlk_poly_sub(&R, &B);
  __CPROVER_assert(R.coeffs[MLKEM_N - 1u] ==
                       (int16_t)(INT16_MAX - 1),
                   "SUB_T3B_VALID_UPPER: cancellation succeeds");
  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3b_invalid_lower_harness.c" <<'EOF'
#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  int32_t s;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[0] = INT16_MIN;
  B.coeffs[0] = -1;
  s = (int32_t)R.coeffs[0] + (int32_t)B.coeffs[0];
  __CPROVER_assert(s >= INT16_MIN,
                   "SUB_T3B_INVALID_LOWER_CONTROL: deliberately outside domain");
  mlk_poly_add(&R, &B);
  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3b_invalid_upper_harness.c" <<'EOF'
#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  int32_t s;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[0] = INT16_MAX;
  B.coeffs[0] = 1;
  s = (int32_t)R.coeffs[0] + (int32_t)B.coeffs[0];
  __CPROVER_assert(s <= INT16_MAX,
                   "SUB_T3B_INVALID_UPPER_CONTROL: deliberately outside domain");
  mlk_poly_add(&R, &B);
  return 0;
}
EOF

cat > "$HARNESS_DIR/sub_t3c_recovery_sum_boundaries_harness.c" <<'EOF'
#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A;
  mlk_poly B;
  mlk_poly X;
  mlk_poly NB;
  mlk_poly NA;
  int32_t sum0;
  int32_t sum1;
  int32_t sum2;
  int32_t sum255;

  sub_t3_check_machine_model();
  sub_t3_zero_poly(&A);
  sub_t3_zero_poly(&B);

  A.coeffs[0] = 0;
  B.coeffs[0] = 0;

  A.coeffs[1] = -1;
  B.coeffs[1] = 0;

  A.coeffs[2] = 0;
  B.coeffs[2] = 1;

  A.coeffs[MLKEM_N - 1u] = -2;
  B.coeffs[MLKEM_N - 1u] = -1;

  X = A;
  NB = B;
  NA = A;

  mlk_poly_sub(&X, &B);
  mlk_poly_reduce(&X);
  mlk_poly_reduce(&NB);

  sum0 = (int32_t)X.coeffs[0] + NB.coeffs[0];
  sum1 = (int32_t)X.coeffs[1] + NB.coeffs[1];
  sum2 = (int32_t)X.coeffs[2] + NB.coeffs[2];
  sum255 = (int32_t)X.coeffs[MLKEM_N - 1u] +
           NB.coeffs[MLKEM_N - 1u];

  __CPROVER_assert(sum0 == 0,
                   "SUB_T3C_BOUNDARY: recovery sum 0 reachable");
  __CPROVER_assert(sum1 == SUB_T3_FIPS_Q - 1,
                   "SUB_T3C_BOUNDARY: recovery sum q-1 reachable");
  __CPROVER_assert(sum2 == SUB_T3_FIPS_Q,
                   "SUB_T3C_BOUNDARY: recovery sum q reachable");
  __CPROVER_assert(sum255 == 2 * (SUB_T3_FIPS_Q - 1),
                   "SUB_T3C_BOUNDARY: recovery sum 2q-2 reachable");

  mlk_poly_add(&X, &NB);
  mlk_poly_reduce(&X);
  mlk_poly_reduce(&NA);

  __CPROVER_assert(X.coeffs[0] == NA.coeffs[0],
                   "SUB_T3C_BOUNDARY: cancellation at sum 0");
  __CPROVER_assert(X.coeffs[1] == NA.coeffs[1],
                   "SUB_T3C_BOUNDARY: cancellation at sum q-1");
  __CPROVER_assert(X.coeffs[2] == NA.coeffs[2],
                   "SUB_T3C_BOUNDARY: cancellation at sum q");
  __CPROVER_assert(X.coeffs[MLKEM_N - 1u] ==
                       NA.coeffs[MLKEM_N - 1u],
                   "SUB_T3C_BOUNDARY: cancellation at sum 2q-2");

  return 0;
}
EOF

cat > "$OUT/BOUNDARY_CONTROL_MATRIX.md" <<'EOF'
# SUB00N T3 Boundary-Control Matrix

| Control | Constructed arithmetic | Expected classification |
|---|---:|---|
| T3A valid lower | A-B = INT16_MIN | verification success |
| T3A valid upper | A-B = INT16_MAX | verification success |
| T3A invalid lower | A-B = INT16_MIN-1 | expected failure |
| T3A invalid upper | A-B = INT16_MAX+1 | expected failure |
| T3B valid lower | A+B = INT16_MIN | verification success |
| T3B valid upper | A+B = INT16_MAX | verification success |
| T3B invalid lower | A+B = INT16_MIN-1 | expected failure |
| T3B invalid upper | A+B = INT16_MAX+1 | expected failure |
| T3C recovery sums | 0, q-1, q, 2q-2 | verification success |

Negative controls are outside the theorem domain. They must not be
reported as failed positive theorems.
EOF

cat > "$OUT/MUTATION_PREFLIGHT_MATRIX.md" <<'EOF'
# SUB00N T3 Mutation-Preflight Matrix

| ID | Mutation | Primary expected detector |
|---|---|---|
| T3-M1 | replace recovery add with subtraction | T3C cancellation/oracle assertion |
| T3-M2 | omit recovery addition | T3C cancellation/oracle assertion |
| T3-M3 | use the wrong recovery operand | T3C cancellation/oracle assertion |
| T3-M4 | skip coefficient 255 | coefficient-255 cancellation mismatch |
| T3-M5 | omit final T3C reduction | canonical range or oracle assertion |
| T3-M6 | perturb independent expected value by +1 mod q | independent oracle assertion |

The actual mutant models and exact expected property identifiers must
be frozen only after the original T3 GOTO models and property
inventories have passed preflight.
EOF

cat > "$OUT/HARNESS_ARCHITECTURE.md" <<'EOF'
# SUB00N T3 Harness Architecture

## Universal theorem harnesses

1. `sub_t3a_exact_sub_add_harness.c`
2. `sub_t3b_exact_add_sub_harness.c`
3. `sub_t3c_modular_cancellation_harness.c`

## Reachability harness

4. `sub_t3_coverage_harness.c`

## Boundary controls

5. `sub_t3a_valid_lower_harness.c`
6. `sub_t3a_valid_upper_harness.c`
7. `sub_t3a_invalid_lower_harness.c`
8. `sub_t3a_invalid_upper_harness.c`
9. `sub_t3b_valid_lower_harness.c`
10. `sub_t3b_valid_upper_harness.c`
11. `sub_t3b_invalid_lower_harness.c`
12. `sub_t3b_invalid_upper_harness.c`
13. `sub_t3c_recovery_sum_boundaries_harness.c`

The common header contains only machine-model checks, FIPS parameter
bindings, and a deterministic zero-initialization helper. It does not
encode any cancellation conclusion.
EOF

{
  echo "SUB00N STATIC ASSUMPTION AND ASSERTION AUDIT"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"
  echo
  for f in "$HARNESS_DIR"/*.c "$HARNESS_DIR"/*.h; do
    echo "============================================================"
    echo "FILE=$f"
    echo "SHA256=$(sha256sum "$f" | awk '{print $1}')"
    echo
    grep -nE '__CPROVER_(assume|assert|cover)|mlk_poly_(add|sub|reduce)|INT16_(MIN|MAX)|SUB_T3_FIPS_(N|Q)' \
      "$f" 2>/dev/null || true
    echo
  done
} > "$OUT/STATIC_PROPERTY_AUDIT.txt"

{
  echo "SUB00N EXISTING BUILD-CONTEXT REFERENCES"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"
  echo
  find "$ROOT" -maxdepth 7 -type f \
    \( -name 'executed_runner.sh' -o -name '*command*.txt' -o -name '*MODEL_RECORD*.txt' \) \
    -print 2>/dev/null |
  sort |
  while IFS= read -r f; do
    if grep -qiE 'goto-cc|cbmc|MLK_NAMESPACE|MLKEM_K|MLKEM768|poly_sub|poly_reduce' "$f" 2>/dev/null; then
      echo "------------------------------------------------------------"
      echo "FILE=$f"
      sha256sum "$f"
      grep -nEi 'goto-cc|cbmc|MLK_NAMESPACE|MLKEM_K|MLKEM768|object-bits|unwindset|poly_sub|poly_add|poly_reduce' \
        "$f" 2>/dev/null | head -250 || true
    fi
  done
} > "$OUT/BUILD_CONTEXT_REFERENCE_PACKET.txt"

python3 - "$HARNESS_DIR" "$OUT/HARNESS_INVENTORY.json" <<'PY'
import hashlib
import json
import pathlib
import sys

harness_dir = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])

records = []
for path in sorted(harness_dir.iterdir()):
    if path.is_file():
        data = path.read_bytes()
        text = data.decode("utf-8", errors="replace")
        records.append(
            {
                "file": path.name,
                "bytes": len(data),
                "sha256": hashlib.sha256(data).hexdigest(),
                "assume_count": text.count("__CPROVER_assume"),
                "assert_count": text.count("__CPROVER_assert"),
                "cover_count": text.count("__CPROVER_cover"),
                "poly_add_calls": text.count("mlk_poly_add("),
                "poly_sub_calls": text.count("mlk_poly_sub("),
                "poly_reduce_calls": text.count("mlk_poly_reduce("),
            }
        )

out.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
PY

{
  echo "SUB00N FREEZE VALIDATION"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"

  C_COUNT="$(find "$HARNESS_DIR" -maxdepth 1 -type f -name '*.c' | wc -l)"
  H_COUNT="$(find "$HARNESS_DIR" -maxdepth 1 -type f -name '*.h' | wc -l)"

  echo "C_HARNESS_COUNT=$C_COUNT"
  echo "HEADER_COUNT=$H_COUNT"

  test "$C_COUNT" -eq 13
  test "$H_COUNT" -eq 1

  test "$(grep -c '__CPROVER_assume' \
    "$HARNESS_DIR/sub_t3a_exact_sub_add_harness.c")" -eq 2
  test "$(grep -c '__CPROVER_assume' \
    "$HARNESS_DIR/sub_t3b_exact_add_sub_harness.c")" -eq 2
  test "$(grep -c '__CPROVER_assume' \
    "$HARNESS_DIR/sub_t3c_modular_cancellation_harness.c")" -eq 2

  if grep -n '__CPROVER_assume.*recovery' \
       "$HARNESS_DIR/sub_t3c_modular_cancellation_harness.c"; then
    echo "FAIL_RECOVERY_REPRESENTABILITY_ASSUMED"
    exit 1
  else
    echo "PASS_NO_RECOVERY_REPRESENTABILITY_ASSUMPTION"
  fi

  grep -q 'SUB_T3C_CANCELLATION' \
    "$HARNESS_DIR/sub_t3c_modular_cancellation_harness.c"
  grep -q 'expected_A' \
    "$HARNESS_DIR/sub_t3c_modular_cancellation_harness.c"
  grep -q '__CPROVER_cover(recovery_sum_2q_minus_2)' \
    "$HARNESS_DIR/sub_t3_coverage_harness.c"

  echo "STATIC_FREEZE_VALIDATION=PASS"
  echo "CBMC_EXECUTION_PERFORMED=NO"
  echo "GOTO_MODEL_GENERATED=NO"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "PRIOR_RESULT_MODIFIED=NO"
} > "$OUT/FREEZE_VALIDATION.txt"

(
  cd "$OUT"
  find . -type f \
    ! -name 'SUB00N_ARTIFACT_MANIFEST.sha256' \
    -print0 |
  sort -z |
  xargs -0 sha256sum > SUB00N_ARTIFACT_MANIFEST.sha256
)

chmod -R a-w "$OUT"

echo
echo "============================================================"
echo "SUB00N T3 HARNESS FAMILY FROZEN"
echo "============================================================"
echo "OUT=$OUT"
echo
cat "$OUT/FREEZE_VALIDATION.txt"
echo
echo "=== MANIFEST VERIFICATION ==="
(
  cd "$OUT"
  sha256sum -c SUB00N_ARTIFACT_MANIFEST.sha256
)
echo
echo "=== TOP-LEVEL HASHES ==="
sha256sum "$OUT/FREEZE_VALIDATION.txt"
sha256sum "$OUT/HARNESS_INVENTORY.json"
sha256sum "$OUT/SUB00N_ARTIFACT_MANIFEST.sha256"
echo
echo "Upload:"
echo "$OUT/FREEZE_VALIDATION.txt"
echo "$OUT/HARNESS_INVENTORY.json"
echo "$OUT/STATIC_PROPERTY_AUDIT.txt"
echo "$OUT/BUILD_CONTEXT_REFERENCE_PACKET.txt"
echo "$OUT/SUB00N_ARTIFACT_MANIFEST.sha256"
