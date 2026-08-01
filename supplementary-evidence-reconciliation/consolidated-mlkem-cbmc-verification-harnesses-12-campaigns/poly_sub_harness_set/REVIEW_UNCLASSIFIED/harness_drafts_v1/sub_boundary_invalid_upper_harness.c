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
