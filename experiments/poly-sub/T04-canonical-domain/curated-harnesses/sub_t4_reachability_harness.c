/*
 * SUB-T4 canonical-domain reachability harness.
 *
 * These are satisfiability controls, not additional theorem claims.
 */

#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

extern int16_t nondet_int16_t(void);

static void sub_t4_cov_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T4_COV_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T4_COV_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T4_COV_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T4_COV_MODEL: pointer width must be 64");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A0;
  mlk_poly saved_B0;
  mlk_poly R;
  mlk_poly RB;
  unsigned i;
  int has_maximum_positive;
  int has_maximum_negative;
  int has_zero;
  int has_interior_positive;
  int has_interior_negative;

  sub_t4_cov_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T4_COV_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T4_COV_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = nondet_int16_t();
    B0.coeffs[i] = nondet_int16_t();

    __CPROVER_assume(A0.coeffs[i] >= 0);
    __CPROVER_assume(A0.coeffs[i] < FIPS_Q);
    __CPROVER_assume(B0.coeffs[i] >= 0);
    __CPROVER_assume(B0.coeffs[i] < FIPS_Q);
  }

  saved_A0 = A0;
  saved_B0 = B0;
  R = A0;
  RB = B0;

  mlk_poly_sub(&R, &RB);

  has_maximum_positive = 0;
  has_maximum_negative = 0;
  has_zero = 0;
  has_interior_positive = 0;
  has_interior_negative = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];

    if (d == (int32_t)(FIPS_Q - 1))
    {
      has_maximum_positive = 1;
    }

    if (d == -(int32_t)(FIPS_Q - 1))
    {
      has_maximum_negative = 1;
    }

    if (d == 0)
    {
      has_zero = 1;
    }

    if (d > 0 && d < (int32_t)(FIPS_Q - 1))
    {
      has_interior_positive = 1;
    }

    if (d < 0 && d > -(int32_t)(FIPS_Q - 1))
    {
      has_interior_negative = 1;
    }

    __CPROVER_assert(
        (int32_t)R.coeffs[i] == d,
        "SUB_T4_COV_EXACTNESS: production output must equal mathematical difference");

    __CPROVER_assert(
        RB.coeffs[i] == saved_B0.coeffs[i],
        "SUB_T4_COV_FRAME: RB must remain unchanged");
  }

  __CPROVER_cover(has_maximum_positive);
  __CPROVER_cover(has_maximum_negative);
  __CPROVER_cover(has_zero);
  __CPROVER_cover(has_interior_positive);
  __CPROVER_cover(has_interior_negative);

  return 0;
}
