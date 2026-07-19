#!/usr/bin/env bash
set -euo pipefail

DIR="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
ARCH="${DIR}/SUB00C_INDEPENDENT_HARNESS_ARCHITECTURE.md"
EXPECTED_ARCH_SHA256="a1d11264cf27038fed35ccddced2c6f79c5e28f42382e5000ce7fe7a44689d84"

OUTDIR="${DIR}/harness_drafts_v1"
MANIFEST="${DIR}/SUB00C_HARNESS_DRAFT_MANIFEST.sha256"
PACKET="${DIR}/SUB00C_HARNESS_DRAFT_REVIEW_PACKET.txt"
PACKET_HASH="${PACKET}.sha256"

test -d "${DIR}" || {
    echo "ERROR: Missing clean-room directory:"
    echo "${DIR}"
    exit 1
}

test -f "${ARCH}" || {
    echo "ERROR: Missing SUB-00C architecture:"
    echo "${ARCH}"
    exit 1
}

ACTUAL_ARCH_SHA256="$(sha256sum "${ARCH}" | awk '{print $1}')"

test "${ACTUAL_ARCH_SHA256}" = "${EXPECTED_ARCH_SHA256}" || {
    echo "ERROR: SUB-00C architecture integrity check failed."
    echo "Expected: ${EXPECTED_ARCH_SHA256}"
    echo "Actual:   ${ACTUAL_ARCH_SHA256}"
    exit 1
}

for path in "${OUTDIR}" "${MANIFEST}" "${PACKET}" "${PACKET_HASH}"; do
    test ! -e "${path}" || {
        echo "ERROR: Draft output already exists:"
        echo "${path}"
        echo "Nothing was overwritten."
        exit 1
    }
done

mkdir -p "${OUTDIR}"

cat > "${OUTDIR}/sub_t1_semantic_harness.c" <<'EOF_SUB_T1_SEMANTIC_HARNESS_C'
/*
 * SUB-T1 draft: full signed-domain modular refinement.
 * Independently authored from the frozen SUB-00B/SUB-00C records.
 */
#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

extern int16_t nondet_int16_t(void);

static void sub_t1_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T1_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T1_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T1_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T1_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T1_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T1_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T1_MODEL: negative signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T1_MODEL: negative odd right shift must preserve sign");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A0;
  mlk_poly saved_B0;
  mlk_poly L;
  mlk_poly LB;
  mlk_poly LB_before_sub;
  mlk_poly LB_before_reduce;
  unsigned i;

  sub_t1_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T1_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T1_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = nondet_int16_t();
    B0.coeffs[i] = nondet_int16_t();
  }

  saved_A0 = A0;
  saved_B0 = B0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];

    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);
  }

  L = A0;
  LB = B0;
  LB_before_sub = LB;

  mlk_poly_sub(&L, &LB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(LB.coeffs[i] == LB_before_sub.coeffs[i],
                     "SUB_T1_FRAME: subtraction must not modify LB");
    __CPROVER_assert(A0.coeffs[i] == saved_A0.coeffs[i],
                     "SUB_T1_FRAME: subtraction must not modify A0");
    __CPROVER_assert(B0.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T1_FRAME: subtraction must not modify B0");
  }

  LB_before_reduce = LB;

  mlk_poly_reduce(&L);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;
    uint32_t shifted;
    uint32_t expected;

    d = (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];
    shifted = (uint32_t)(d + (int32_t)(10 * FIPS_Q));
    expected = shifted % (uint32_t)FIPS_Q;

    __CPROVER_assert(L.coeffs[i] >= 0,
                     "SUB_T1_SEMANTIC: output must be non-negative");
    __CPROVER_assert(L.coeffs[i] < FIPS_Q,
                     "SUB_T1_SEMANTIC: output must be below FIPS_Q");
    __CPROVER_assert((uint32_t)L.coeffs[i] == expected,
                     "SUB_T1_SEMANTIC: output must equal independent canonical oracle");

    __CPROVER_assert(LB.coeffs[i] == LB_before_reduce.coeffs[i],
                     "SUB_T1_FRAME: reduction must not modify LB");
    __CPROVER_assert(LB.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T1_FRAME: final LB must equal saved B0");
    __CPROVER_assert(A0.coeffs[i] == saved_A0.coeffs[i],
                     "SUB_T1_FRAME: final A0 must equal saved A0");
    __CPROVER_assert(B0.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T1_FRAME: final B0 must equal saved B0");
  }

  return 0;
}
EOF_SUB_T1_SEMANTIC_HARNESS_C

cat > "${OUTDIR}/sub_t2_relational_harness.c" <<'EOF_SUB_T2_RELATIONAL_HARNESS_C'
/*
 * SUB-T2 draft: normalization commutes with production subtraction.
 * Independently authored from the frozen SUB-00B/SUB-00C records.
 */
#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

extern int16_t nondet_int16_t(void);

static void sub_t2_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T2_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T2_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T2_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T2_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T2_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T2_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T2_MODEL: negative signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T2_MODEL: negative odd right shift must preserve sign");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A0;
  mlk_poly saved_B0;
  mlk_poly L;
  mlk_poly LB;
  mlk_poly RA;
  mlk_poly RB;
  mlk_poly RA_before_left;
  mlk_poly RB_before_left;
  mlk_poly completed_L;
  mlk_poly completed_LB;
  mlk_poly RB_before_RA_reduce_first;
  mlk_poly RA_before_RB_reduce;
  mlk_poly RB_before_sub;
  mlk_poly RB_before_RA_reduce_final;
  unsigned i;

  sub_t2_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T2_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T2_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = nondet_int16_t();
    B0.coeffs[i] = nondet_int16_t();
  }

  saved_A0 = A0;
  saved_B0 = B0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];

    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);
  }

  L = A0;
  LB = B0;
  RA = A0;
  RB = B0;

  RA_before_left = RA;
  RB_before_left = RB;

  mlk_poly_sub(&L, &LB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RA.coeffs[i] == RA_before_left.coeffs[i],
                     "SUB_T2_FRAME: left subtraction must not modify RA");
    __CPROVER_assert(RB.coeffs[i] == RB_before_left.coeffs[i],
                     "SUB_T2_FRAME: left subtraction must not modify RB");
    __CPROVER_assert(LB.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T2_FRAME: left subtraction must not modify LB");
  }

  mlk_poly_reduce(&L);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RA.coeffs[i] == RA_before_left.coeffs[i],
                     "SUB_T2_FRAME: left reduction must not modify RA");
    __CPROVER_assert(RB.coeffs[i] == RB_before_left.coeffs[i],
                     "SUB_T2_FRAME: left reduction must not modify RB");
    __CPROVER_assert(LB.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T2_FRAME: left reduction must not modify LB");
  }

  completed_L = L;
  completed_LB = LB;

  RB_before_RA_reduce_first = RB;
  mlk_poly_reduce(&RA);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RB.coeffs[i] ==
                         RB_before_RA_reduce_first.coeffs[i],
                     "SUB_T2_FRAME: reducing RA must not modify RB");
    __CPROVER_assert(L.coeffs[i] == completed_L.coeffs[i],
                     "SUB_T2_FRAME: reducing RA must not modify completed L");
    __CPROVER_assert(LB.coeffs[i] == completed_LB.coeffs[i],
                     "SUB_T2_FRAME: reducing RA must not modify completed LB");
  }

  RA_before_RB_reduce = RA;
  mlk_poly_reduce(&RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RA.coeffs[i] == RA_before_RB_reduce.coeffs[i],
                     "SUB_T2_FRAME: reducing RB must not modify RA");
    __CPROVER_assert(L.coeffs[i] == completed_L.coeffs[i],
                     "SUB_T2_FRAME: reducing RB must not modify completed L");
    __CPROVER_assert(LB.coeffs[i] == completed_LB.coeffs[i],
                     "SUB_T2_FRAME: reducing RB must not modify completed LB");
  }

  RB_before_sub = RB;
  mlk_poly_sub(&RA, &RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RB.coeffs[i] == RB_before_sub.coeffs[i],
                     "SUB_T2_FRAME: right subtraction must not modify RB");
    __CPROVER_assert(L.coeffs[i] == completed_L.coeffs[i],
                     "SUB_T2_FRAME: right subtraction must not modify completed L");
    __CPROVER_assert(LB.coeffs[i] == completed_LB.coeffs[i],
                     "SUB_T2_FRAME: right subtraction must not modify completed LB");
  }

  RB_before_RA_reduce_final = RB;
  mlk_poly_reduce(&RA);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RB.coeffs[i] ==
                         RB_before_RA_reduce_final.coeffs[i],
                     "SUB_T2_FRAME: final RA reduction must not modify RB");
    __CPROVER_assert(L.coeffs[i] == completed_L.coeffs[i],
                     "SUB_T2_FRAME: final RA reduction must not modify completed L");
    __CPROVER_assert(LB.coeffs[i] == completed_LB.coeffs[i],
                     "SUB_T2_FRAME: final RA reduction must not modify completed LB");

    __CPROVER_assert(A0.coeffs[i] == saved_A0.coeffs[i],
                     "SUB_T2_FRAME: final A0 must equal saved A0");
    __CPROVER_assert(B0.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T2_FRAME: final B0 must equal saved B0");
    __CPROVER_assert(LB.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T2_FRAME: final LB must equal saved B0");

    __CPROVER_assert(L.coeffs[i] == RA.coeffs[i],
                     "SUB_T2_RELATIONAL: left and right canonical results must agree");
    __CPROVER_assert(L.coeffs[i] >= 0,
                     "SUB_T2_RELATIONAL: left result must be non-negative");
    __CPROVER_assert(L.coeffs[i] < FIPS_Q,
                     "SUB_T2_RELATIONAL: left result must be below FIPS_Q");
    __CPROVER_assert(RA.coeffs[i] >= 0,
                     "SUB_T2_RELATIONAL: right result must be non-negative");
    __CPROVER_assert(RA.coeffs[i] < FIPS_Q,
                     "SUB_T2_RELATIONAL: right result must be below FIPS_Q");
  }

  return 0;
}
EOF_SUB_T2_RELATIONAL_HARNESS_C

cat > "${OUTDIR}/sub_cov_reachability_harness.c" <<'EOF_SUB_COV_REACHABILITY_HARNESS_C'
/*
 * SUB-COV draft: satisfiability and reachability evidence.
 * Independently authored from the frozen SUB-00B/SUB-00C records.
 */
#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

extern int16_t nondet_int16_t(void);

static void sub_cov_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_COV_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_COV_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_COV_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_COV_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_COV_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_COV_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_COV_MODEL: negative signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_COV_MODEL: negative odd right shift must preserve sign");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A0;
  mlk_poly saved_B0;
  mlk_poly L;
  mlk_poly LB;
  unsigned i;
  int has_positive_difference;
  int has_negative_difference;
  int has_zero_difference;
  int has_noncanonical_positive_input;
  int has_noncanonical_negative_input;
  int has_int16_min_difference;
  int has_int16_max_difference;

  sub_cov_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_COV_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_COV_PARAMETER: MLKEM_Q must equal FIPS_Q");

  has_positive_difference = 0;
  has_negative_difference = 0;
  has_zero_difference = 0;
  has_noncanonical_positive_input = 0;
  has_noncanonical_negative_input = 0;
  has_int16_min_difference = 0;
  has_int16_max_difference = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = nondet_int16_t();
    B0.coeffs[i] = nondet_int16_t();
  }

  saved_A0 = A0;
  saved_B0 = B0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];

    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);

    if (d > 0)
    {
      has_positive_difference = 1;
    }
    if (d < 0)
    {
      has_negative_difference = 1;
    }
    if (d == 0)
    {
      has_zero_difference = 1;
    }
    if (saved_A0.coeffs[i] >= FIPS_Q ||
        saved_B0.coeffs[i] >= FIPS_Q)
    {
      has_noncanonical_positive_input = 1;
    }
    if (saved_A0.coeffs[i] < 0 ||
        saved_B0.coeffs[i] < 0)
    {
      has_noncanonical_negative_input = 1;
    }
    if (d == (int32_t)INT16_MIN)
    {
      has_int16_min_difference = 1;
    }
    if (d == (int32_t)INT16_MAX)
    {
      has_int16_max_difference = 1;
    }
  }

  L = A0;
  LB = B0;

  mlk_poly_sub(&L, &LB);
  mlk_poly_reduce(&L);

  __CPROVER_cover(has_positive_difference);
  __CPROVER_cover(has_negative_difference);
  __CPROVER_cover(has_zero_difference);
  __CPROVER_cover(has_noncanonical_positive_input);
  __CPROVER_cover(has_noncanonical_negative_input);
  __CPROVER_cover(has_int16_min_difference);
  __CPROVER_cover(has_int16_max_difference);
  __CPROVER_cover(1);

  return 0;
}
EOF_SUB_COV_REACHABILITY_HARNESS_C

cat > "${OUTDIR}/sub_boundary_valid_extremes_harness.c" <<'EOF_SUB_BOUNDARY_VALID_EXTREMES_HARNESS_C'
/*
 * SUB boundary draft: valid INT16_MIN and INT16_MAX differences.
 * Independently authored from the frozen SUB-00B/SUB-00C records.
 */
#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

static void sub_boundary_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_BOUNDARY_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_BOUNDARY_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_BOUNDARY_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_BOUNDARY_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_BOUNDARY_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_BOUNDARY_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_BOUNDARY_MODEL: negative signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_BOUNDARY_MODEL: negative odd right shift must preserve sign");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly L;
  mlk_poly LB;
  unsigned i;

  sub_boundary_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_BOUNDARY_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_BOUNDARY_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = 0;
    B0.coeffs[i] = 0;
  }

  A0.coeffs[0] = INT16_MIN;
  B0.coeffs[0] = 0;

  A0.coeffs[MLKEM_N - 1u] = INT16_MAX;
  B0.coeffs[MLKEM_N - 1u] = 0;

  L = A0;
  LB = B0;

  mlk_poly_sub(&L, &LB);
  mlk_poly_reduce(&L);

  __CPROVER_assert(L.coeffs[0] == 522,
                   "SUB_BOUNDARY_VALID: INT16_MIN canonical result must be 522");
  __CPROVER_assert(L.coeffs[MLKEM_N - 1u] == 2806,
                   "SUB_BOUNDARY_VALID: INT16_MAX canonical result must be 2806");

  for (i = 1u; i + 1u < MLKEM_N; i++)
  {
    __CPROVER_assert(L.coeffs[i] == 0,
                     "SUB_BOUNDARY_VALID: untouched zero coefficients must remain zero");
  }

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(LB.coeffs[i] == B0.coeffs[i],
                     "SUB_BOUNDARY_FRAME: B working copy must remain unchanged");
  }

  return 0;
}
EOF_SUB_BOUNDARY_VALID_EXTREMES_HARNESS_C

cat > "${OUTDIR}/sub_boundary_invalid_lower_harness.c" <<'EOF_SUB_BOUNDARY_INVALID_LOWER_HARNESS_C'
/*
 * SUB negative-control draft: invalid lower representability boundary.
 * Expected to fail conversion/precondition checking when executed.
 */
#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

static void sub_invalid_lower_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_INVALID_LOWER_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_INVALID_LOWER_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_INVALID_LOWER_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_INVALID_LOWER_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_INVALID_LOWER_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_INVALID_LOWER_MODEL: pointer width must be 64");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly L;
  mlk_poly LB;
  unsigned i;

  sub_invalid_lower_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_INVALID_LOWER_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_INVALID_LOWER_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = 0;
    B0.coeffs[i] = 0;
  }

  A0.coeffs[0] = INT16_MIN;
  B0.coeffs[0] = 1;

  L = A0;
  LB = B0;

  /*
   * No representability assumption is permitted here.
   * The mathematical result at coefficient 0 is INT16_MIN - 1.
   */
  mlk_poly_sub(&L, &LB);

  return 0;
}
EOF_SUB_BOUNDARY_INVALID_LOWER_HARNESS_C

cat > "${OUTDIR}/sub_boundary_invalid_upper_harness.c" <<'EOF_SUB_BOUNDARY_INVALID_UPPER_HARNESS_C'
/*
 * SUB negative-control draft: invalid upper representability boundary.
 * Expected to fail conversion/precondition checking when executed.
 */
#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

static void sub_invalid_upper_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_INVALID_UPPER_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_INVALID_UPPER_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_INVALID_UPPER_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_INVALID_UPPER_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_INVALID_UPPER_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_INVALID_UPPER_MODEL: pointer width must be 64");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly L;
  mlk_poly LB;
  unsigned i;

  sub_invalid_upper_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_INVALID_UPPER_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_INVALID_UPPER_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = 0;
    B0.coeffs[i] = 0;
  }

  A0.coeffs[0] = INT16_MAX;
  B0.coeffs[0] = -1;

  L = A0;
  LB = B0;

  /*
   * No representability assumption is permitted here.
   * The mathematical result at coefficient 0 is INT16_MAX + 1.
   */
  mlk_poly_sub(&L, &LB);

  return 0;
}
EOF_SUB_BOUNDARY_INVALID_UPPER_HARNESS_C

(
  cd "${OUTDIR}"
  sha256sum \
    sub_t1_semantic_harness.c \
    sub_t2_relational_harness.c \
    sub_cov_reachability_harness.c \
    sub_boundary_valid_extremes_harness.c \
    sub_boundary_invalid_lower_harness.c \
    sub_boundary_invalid_upper_harness.c
) > "${MANIFEST}"

{
  echo "============================================================"
  echo "SUB-00C INDEPENDENT HARNESS DRAFT REVIEW PACKET"
  echo "============================================================"
  echo
  echo "Repository commit:"
  echo "d9613cf60de3132d32475c102d8c2781d84feb34"
  echo
  echo "Parent architecture SHA-256:"
  echo "${EXPECTED_ARCH_SHA256}"
  echo
  echo "Draft generation time UTC:"
  date -u +%Y-%m-%dT%H:%M:%SZ
  echo
  echo "STATUS:"
  echo "Draft sources only. No theorem proof was executed."
  echo "These hashes are review-integrity hashes, not the final execution freeze."
  echo
  echo "Existing proofs/cbmc/poly_sub/poly_sub_harness.c was not used."
  echo
  echo "============================================================"
  echo "DRAFT SOURCE SHA-256 MANIFEST"
  echo "============================================================"
  cat "${MANIFEST}"

  for file in \
    sub_t1_semantic_harness.c \
    sub_t2_relational_harness.c \
    sub_cov_reachability_harness.c \
    sub_boundary_valid_extremes_harness.c \
    sub_boundary_invalid_lower_harness.c \
    sub_boundary_invalid_upper_harness.c
  do
    echo
    echo "============================================================"
    echo "FILE: ${file}"
    echo "============================================================"
    nl -ba "${OUTDIR}/${file}"
  done
} > "${PACKET}"

sha256sum "${PACKET}" > "${PACKET_HASH}"

echo
echo "============================================================"
echo "SUB-00C HARNESS DRAFTS CREATED SUCCESSFULLY"
echo "============================================================"
echo
echo "No CBMC theorem proof was run."
echo
echo "Upload these three files:"
echo
echo "1. ${PACKET}"
echo "2. ${PACKET_HASH}"
echo "3. ${MANIFEST}"
echo
echo "Do not open proofs/cbmc/poly_sub/poly_sub_harness.c."
echo "Do not run CBMC yet."
