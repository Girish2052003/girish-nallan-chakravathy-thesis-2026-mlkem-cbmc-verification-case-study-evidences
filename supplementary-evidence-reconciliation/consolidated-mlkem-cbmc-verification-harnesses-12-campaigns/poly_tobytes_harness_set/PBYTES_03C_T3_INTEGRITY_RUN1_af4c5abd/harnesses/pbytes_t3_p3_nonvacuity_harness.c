// PBYTES-T3.P3 canonical-block realizability witnesses.
//
// Concrete canonical pairs cover zero, q-1 and packing-transition values.

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
  unsigned even_index;
  unsigned odd_index;
  unsigned i;

  __CPROVER_assume(scenario < 4u);

  selected_pair =
    (scenario == 0u || scenario == 2u)
      ? 0u
      : PBYTES_PAIR_COUNT - 1u;

  even_index = 2u * selected_pair;
  odd_index = even_index + 1u;

  for (i = 0u; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 0;
  }

  if (scenario == 0u)
  {
    input.coeffs[even_index] = 0;
    input.coeffs[odd_index] = 0;
  }

  if (scenario == 1u)
  {
    input.coeffs[even_index] = MLKEM_Q - 1;
    input.coeffs[odd_index] = MLKEM_Q - 1;
  }

  if (scenario == 2u)
  {
    input.coeffs[even_index] = 255;
    input.coeffs[odd_index] = 15;
  }

  if (scenario == 3u)
  {
    input.coeffs[even_index] = 256;
    input.coeffs[odd_index] = 16;
  }

  mlk_poly_tobytes(output, &input);

  if (scenario == 0u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV05 canonical zero block witness");
  }

  if (scenario == 1u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV06 canonical q-minus-one block witness");
  }

  if (scenario == 2u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV07 canonical 255-and-15 block witness");
  }

  if (scenario == 3u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV08 canonical 256-and-16 block witness");
  }
}
