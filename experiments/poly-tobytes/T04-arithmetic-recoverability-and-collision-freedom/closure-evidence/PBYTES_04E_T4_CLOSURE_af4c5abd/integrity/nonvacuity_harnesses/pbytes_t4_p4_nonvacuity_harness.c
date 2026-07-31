// PBYTES-T4.P4 full-injectivity non-vacuity companion.
//
// NV09 and NV10 exercise complete equal-input/equal-output cases.
// NV11 and NV12 exercise complete unequal-input/unequal-output cases.
//
// The NVC3 assertion is a concrete injectivity control and must succeed.
// NV09--NV12 are deliberately false reachability witnesses.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

void harness(void)
{
  mlk_poly input_a;
  mlk_poly input_b;

  uint8_t output_a[MLKEM_POLYBYTES];
  uint8_t output_b[MLKEM_POLYBYTES];

  uint8_t scenario;

  unsigned i;

  _Bool expected_inputs_equal;
  _Bool outputs_equal = 1;

  __CPROVER_assume(scenario < 4u);

  /*
   * Scenario zero: both polynomials are all zero.
   * Scenario one: both polynomials are all q-1.
   * Scenarios two and three begin as all zero and are then separated.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    if (scenario == 1u)
    {
      input_a.coeffs[i] = MLKEM_Q - 1;
      input_b.coeffs[i] = MLKEM_Q - 1;
    }
    else
    {
      input_a.coeffs[i] = 0;
      input_b.coeffs[i] = 0;
    }
  }

  /*
   * Unequal at the first coefficient.
   */
  if (scenario == 2u)
  {
    input_a.coeffs[0] = 0;
    input_b.coeffs[0] = 1;
  }

  /*
   * Unequal at the last coefficient and upper canonical boundary.
   */
  if (scenario == 3u)
  {
    input_a.coeffs[MLKEM_N - 1u] = MLKEM_Q - 2;
    input_b.coeffs[MLKEM_N - 1u] = MLKEM_Q - 1;
  }

  expected_inputs_equal =
    scenario == 0u || scenario == 1u;

  mlk_poly_tobytes(output_a, &input_a);
  mlk_poly_tobytes(output_b, &input_b);

  for (i = 0u; i < MLKEM_POLYBYTES; i++)
  {
    if (output_a[i] != output_b[i])
    {
      outputs_equal = 0;
    }
  }

  __CPROVER_assert(
    outputs_equal == expected_inputs_equal,
    "PBYTES-T4.NVC3 concrete full-injectivity control");

  if (scenario == 0u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV09 full equal-zero-polynomial witness");
  }

  if (scenario == 1u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV10 full equal-q-minus-one-polynomial witness");
  }

  if (scenario == 2u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV11 first-coefficient inequality witness");
  }

  if (scenario == 3u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV12 last-coefficient inequality witness");
  }
}
