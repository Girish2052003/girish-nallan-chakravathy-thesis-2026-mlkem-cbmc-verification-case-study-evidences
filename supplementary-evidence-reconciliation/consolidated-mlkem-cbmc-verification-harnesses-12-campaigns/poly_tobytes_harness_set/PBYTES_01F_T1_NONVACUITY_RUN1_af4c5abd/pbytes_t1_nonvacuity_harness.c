// PBYTES-T1 non-vacuity companion.
//
// These four assertions are deliberately false. Each must produce a
// counterexample, demonstrating that the corresponding canonical input
// scenario reaches and returns from the real mlk_poly_tobytes call.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

void harness(void)
{
  mlk_poly input;
  uint8_t output[MLKEM_POLYBYTES];

  uint8_t scenario;
  unsigned i;

  __CPROVER_assume(scenario < 4u);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);

    /*
     * Scenario 0:
     *   Unrestricted canonical witness.
     *
     * Scenario 1:
     *   Entire polynomial at the lower canonical boundary.
     *
     * Scenario 2:
     *   Entire polynomial at the upper canonical boundary.
     *
     * Scenario 3:
     *   Explicit byte/nibble carry-transition witnesses:
     *     c0 = 255, c1 = 15, c2 = 256, c3 = 16.
     */
    if (scenario == 1u)
    {
      __CPROVER_assume(input.coeffs[i] == 0);
    }

    if (scenario == 2u)
    {
      __CPROVER_assume(input.coeffs[i] == MLKEM_Q - 1);
    }

    if (scenario == 3u)
    {
      if (i == 0u)
      {
        __CPROVER_assume(input.coeffs[i] == 255);
      }
      else if (i == 1u)
      {
        __CPROVER_assume(input.coeffs[i] == 15);
      }
      else if (i == 2u)
      {
        __CPROVER_assume(input.coeffs[i] == 256);
      }
      else if (i == 3u)
      {
        __CPROVER_assume(input.coeffs[i] == 16);
      }
    }
  }

  mlk_poly_tobytes(output, &input);

  if (scenario == 0u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T1.NV1 unrestricted canonical call-return witness");
  }

  if (scenario == 1u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T1.NV2 all-zero lower-boundary witness");
  }

  if (scenario == 2u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T1.NV3 all-q-minus-one upper-boundary witness");
  }

  if (scenario == 3u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T1.NV4 carry-transition boundary witness");
  }
}
