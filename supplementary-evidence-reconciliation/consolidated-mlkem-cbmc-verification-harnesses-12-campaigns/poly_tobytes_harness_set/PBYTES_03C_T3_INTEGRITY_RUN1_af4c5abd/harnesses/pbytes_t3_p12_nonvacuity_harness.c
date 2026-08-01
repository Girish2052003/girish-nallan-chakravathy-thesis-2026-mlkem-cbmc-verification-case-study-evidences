// PBYTES-T3 P1/P2 non-vacuity companion.
//
// Four deliberately false assertions establish concrete call-return
// executions for lower/upper even and odd canonical boundaries.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly input;
  uint8_t output[MLKEM_POLYBYTES];

  uint8_t scenario;
  unsigned selected_pair;
  unsigned selected_index;
  unsigned i;

  __CPROVER_assume(scenario < 4u);

  selected_pair =
    (scenario == 0u || scenario == 2u)
      ? 0u
      : PBYTES_PAIR_COUNT - 1u;

  selected_index =
    2u * selected_pair +
    (scenario >= 2u ? 1u : 0u);

  for (i = 0u; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 0;
  }

  if (scenario == 0u)
  {
    input.coeffs[selected_index] = 0;
  }

  if (scenario == 1u)
  {
    input.coeffs[selected_index] = MLKEM_Q - 1;
  }

  if (scenario == 2u)
  {
    input.coeffs[selected_index] = 0;
  }

  if (scenario == 3u)
  {
    input.coeffs[selected_index] = MLKEM_Q - 1;
  }

  mlk_poly_tobytes(output, &input);

  if (scenario == 0u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV01 first-pair even zero witness");
  }

  if (scenario == 1u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV02 last-pair even q-minus-one witness");
  }

  if (scenario == 2u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV03 first-pair odd zero witness");
  }

  if (scenario == 3u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV04 last-pair odd q-minus-one witness");
  }
}
