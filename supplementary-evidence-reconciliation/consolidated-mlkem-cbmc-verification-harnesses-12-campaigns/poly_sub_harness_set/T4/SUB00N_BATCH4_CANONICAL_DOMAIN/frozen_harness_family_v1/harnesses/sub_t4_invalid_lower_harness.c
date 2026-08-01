/*
 * SUB-T4 negative control B4-NC2.
 *
 * The admissible canonical witness A[0]=0, B[0]=3328 produces -3328.
 * Therefore, the deliberately stricter universal bound >=-3327 must fail.
 */

#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_B0;
  mlk_poly R;
  mlk_poly RB;
  unsigned i;

  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T4_NC2_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T4_NC2_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T4_NC2_MODEL: int32_t width must be 32");
  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T4_NC2_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T4_NC2_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = 0;
    B0.coeffs[i] = 0;
  }

  A0.coeffs[0] = 0;
  B0.coeffs[0] = (int16_t)(FIPS_Q - 1);

  R = A0;
  RB = B0;
  saved_B0 = RB;

  mlk_poly_sub(&R, &RB);

  __CPROVER_assert(
      A0.coeffs[0] >= 0 && A0.coeffs[0] < FIPS_Q,
      "SUB_T4_NC2_ADMISSIBILITY: A witness must be canonical");

  __CPROVER_assert(
      B0.coeffs[0] >= 0 && B0.coeffs[0] < FIPS_Q,
      "SUB_T4_NC2_ADMISSIBILITY: B witness must be canonical");

  __CPROVER_assert(
      R.coeffs[0] == -(int16_t)(FIPS_Q - 1),
      "SUB_T4_NC2_WITNESS: production output must reach -3328");

  __CPROVER_assert(
      RB.coeffs[0] == saved_B0.coeffs[0],
      "SUB_T4_NC2_FRAME: RB must remain unchanged");

  __CPROVER_assert(
      R.coeffs[0] >= -(FIPS_Q - 2),
      "SUB_T4_NC2_INTENDED_FAILURE: false stricter lower bound -3327");

  return 0;
}
