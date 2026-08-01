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
