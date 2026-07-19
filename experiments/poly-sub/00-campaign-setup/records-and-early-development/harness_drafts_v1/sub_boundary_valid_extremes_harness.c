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
