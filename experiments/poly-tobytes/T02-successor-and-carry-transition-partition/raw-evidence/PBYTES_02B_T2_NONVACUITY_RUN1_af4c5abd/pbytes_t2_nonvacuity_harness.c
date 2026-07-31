// PBYTES-T2 concrete non-vacuity companion.
//
// Each deliberately false assertion must produce a counterexample.
// This establishes that all four T2 successor/carry scenarios can
// satisfy their input conditions, reach both real public-wrapper calls,
// return from the portable implementation and reach the assertion.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly input_a;
  mlk_poly input_b;

  uint8_t output_a[MLKEM_POLYBYTES];
  uint8_t output_b[MLKEM_POLYBYTES];

  uint8_t scenario;

  unsigned selected_pair;
  unsigned selected_index;
  unsigned i;

  __CPROVER_assume(scenario < 4u);

  /*
   * Use both array boundaries:
   *
   * NV1 and NV3 select the first coefficient pair.
   * NV2 and NV4 select the last coefficient pair.
   */
  if (scenario == 0u || scenario == 2u)
  {
    selected_pair = 0u;
  }
  else
  {
    selected_pair = PBYTES_PAIR_COUNT - 1u;
  }

  /*
   * NV1 and NV2 select the even coefficient.
   * NV3 and NV4 select the odd coefficient.
   */
  selected_index =
    2u * selected_pair +
    (scenario >= 2u ? 1u : 0u);

  /*
   * Initialise both polynomials to a concrete canonical value.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    input_a.coeffs[i] = 0;
    input_b.coeffs[i] = 0;
  }

  /*
   * NV1: even coefficient, non-carry transition 0 -> 1.
   */
  if (scenario == 0u)
  {
    input_a.coeffs[selected_index] = 0;
  }

  /*
   * NV2: even coefficient, low-byte carry transition 255 -> 256.
   */
  if (scenario == 1u)
  {
    input_a.coeffs[selected_index] = 255;
  }

  /*
   * NV3: odd coefficient, non-carry transition 0 -> 1.
   */
  if (scenario == 2u)
  {
    input_a.coeffs[selected_index] = 0;
  }

  /*
   * NV4: odd coefficient, low-nibble carry transition 15 -> 16.
   */
  if (scenario == 3u)
  {
    input_a.coeffs[selected_index] = 15;
  }

  input_b.coeffs[selected_index] =
    (int16_t)(input_a.coeffs[selected_index] + 1);

  mlk_poly_tobytes(output_a, &input_a);
  mlk_poly_tobytes(output_b, &input_b);

  if (scenario == 0u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T2.NV1 first-pair even 0-to-1 witness");
  }

  if (scenario == 1u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T2.NV2 last-pair even 255-to-256 witness");
  }

  if (scenario == 2u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T2.NV3 first-pair odd 0-to-1 witness");
  }

  if (scenario == 3u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T2.NV4 last-pair odd 15-to-16 witness");
  }
}
