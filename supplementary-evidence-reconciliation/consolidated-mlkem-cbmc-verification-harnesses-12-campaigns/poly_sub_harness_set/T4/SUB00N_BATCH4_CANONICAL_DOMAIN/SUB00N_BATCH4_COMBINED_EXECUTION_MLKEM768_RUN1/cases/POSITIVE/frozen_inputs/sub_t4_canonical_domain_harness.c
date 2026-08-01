/*
 * SUB-T4 positive theorem:
 *
 * Canonical ML-KEM coefficients imply that production subtraction:
 *
 *   - is automatically representable in int16_t;
 *   - equals the mathematical coefficient-wise difference; and
 *   - lies in the exact interval [-3328, 3328].
 *
 * No direct subtraction-representability assumption is permitted.
 */

#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

extern int16_t nondet_int16_t(void);

static void sub_t4_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T4_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T4_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T4_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T4_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T4_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T4_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T4_MODEL: signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T4_MODEL: negative odd shift must preserve sign");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A0;
  mlk_poly saved_B0;
  mlk_poly R;
  mlk_poly RB;
  mlk_poly RB_before_sub;
  unsigned i;

  sub_t4_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T4_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T4_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = nondet_int16_t();
    B0.coeffs[i] = nondet_int16_t();
  }

  saved_A0 = A0;
  saved_B0 = B0;

  /*
   * These are the only mathematical-domain assumptions.
   *
   * There is intentionally no assumption that A-B is int16_t
   * representable. SUB-T4 must prove that consequence.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(saved_A0.coeffs[i] >= 0);
    __CPROVER_assume(saved_A0.coeffs[i] < FIPS_Q);
    __CPROVER_assume(saved_B0.coeffs[i] >= 0);
    __CPROVER_assume(saved_B0.coeffs[i] < FIPS_Q);
  }

  R = A0;
  RB = B0;
  RB_before_sub = RB;

  mlk_poly_sub(&R, &RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t mathematical_difference;

    mathematical_difference =
        (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];

    __CPROVER_assert(
        mathematical_difference >= (int32_t)INT16_MIN,
        "SUB_T4_REPRESENTABILITY: canonical difference must be above INT16_MIN");

    __CPROVER_assert(
        mathematical_difference <= (int32_t)INT16_MAX,
        "SUB_T4_REPRESENTABILITY: canonical difference must be below INT16_MAX");

    __CPROVER_assert(
        mathematical_difference >= -(int32_t)(FIPS_Q - 1),
        "SUB_T4_RANGE: mathematical difference must be at least -3328");

    __CPROVER_assert(
        mathematical_difference <= (int32_t)(FIPS_Q - 1),
        "SUB_T4_RANGE: mathematical difference must be at most 3328");

    __CPROVER_assert(
        (int32_t)R.coeffs[i] == mathematical_difference,
        "SUB_T4_EXACTNESS: production output must equal mathematical difference");

    __CPROVER_assert(
        R.coeffs[i] >= -(FIPS_Q - 1),
        "SUB_T4_PRODUCTION_RANGE: output must be at least -3328");

    __CPROVER_assert(
        R.coeffs[i] <= FIPS_Q - 1,
        "SUB_T4_PRODUCTION_RANGE: output must be at most 3328");

    __CPROVER_assert(
        RB.coeffs[i] == RB_before_sub.coeffs[i],
        "SUB_T4_FRAME: production subtraction must not modify RB");

    __CPROVER_assert(
        RB.coeffs[i] == saved_B0.coeffs[i],
        "SUB_T4_FRAME: final RB must equal saved B0");

    __CPROVER_assert(
        A0.coeffs[i] == saved_A0.coeffs[i],
        "SUB_T4_FRAME: original A0 must remain unchanged");

    __CPROVER_assert(
        B0.coeffs[i] == saved_B0.coeffs[i],
        "SUB_T4_FRAME: original B0 must remain unchanged");
  }

  return 0;
}
