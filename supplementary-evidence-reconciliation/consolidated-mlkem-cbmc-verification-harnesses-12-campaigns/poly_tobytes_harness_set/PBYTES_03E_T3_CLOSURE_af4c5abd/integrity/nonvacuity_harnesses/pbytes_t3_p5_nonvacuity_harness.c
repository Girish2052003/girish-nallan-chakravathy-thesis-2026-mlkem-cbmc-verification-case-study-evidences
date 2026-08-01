// PBYTES-T3.P5 full-array reverse-image non-vacuity witnesses.
//
// Four concrete canonical full arrays are independently constructed,
// decoded into a polynomial and passed through the real public wrapper.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly decoded_input;

  uint8_t candidate[MLKEM_POLYBYTES];
  uint8_t output[MLKEM_POLYBYTES];

  uint8_t scenario;

  uint16_t even_field;
  uint16_t odd_field;

  unsigned base;
  unsigned i;

  __CPROVER_assume(scenario < 4u);

  for (i = 0u; i < PBYTES_PAIR_COUNT; i++)
  {
    if (scenario == 0u)
    {
      even_field = 0u;
      odd_field = 0u;
    }
    else if (scenario == 1u)
    {
      even_field = MLKEM_Q - 1u;
      odd_field = MLKEM_Q - 1u;
    }
    else if (scenario == 2u)
    {
      even_field = 255u;
      odd_field = 15u;
    }
    else
    {
      even_field = 256u;
      odd_field = 16u;
    }

    base = 3u * i;

    candidate[base] =
      (uint8_t)((unsigned)even_field % 256u);

    candidate[base + 1u] =
      (uint8_t)(
        ((unsigned)even_field / 256u) +
        16u * ((unsigned)odd_field % 16u));

    candidate[base + 2u] =
      (uint8_t)((unsigned)odd_field / 16u);

    decoded_input.coeffs[2u * i] =
      (int16_t)even_field;

    decoded_input.coeffs[2u * i + 1u] =
      (int16_t)odd_field;
  }

  mlk_poly_tobytes(output, &decoded_input);

  if (scenario == 0u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV13 full zero-array image witness");
  }

  if (scenario == 1u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV14 full q-minus-one-array image witness");
  }

  if (scenario == 2u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV15 full 255-and-15 image witness");
  }

  if (scenario == 3u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV16 full 256-and-16 image witness");
  }
}
