// PBYTES-T4.P1/P2 arithmetic-recovery non-vacuity companion.
//
// Four concrete scenarios cover lower, upper and packing-transition
// boundaries at both the first and last coefficient-pair positions.
//
// The NVC1 assertion is a real control and must succeed.
// NV01--NV04 are deliberately false reachability witnesses.

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
  unsigned base;
  unsigned i;

  uint32_t packed_word;
  uint16_t recovered_even;
  uint16_t recovered_odd;

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

  base = 3u * selected_pair;

  packed_word =
    (uint32_t)output[base] +
    256u * (uint32_t)output[base + 1u] +
    65536u * (uint32_t)output[base + 2u];

  recovered_even =
    (uint16_t)(packed_word % 4096u);

  recovered_odd =
    (uint16_t)(packed_word / 4096u);

  __CPROVER_assert(
    recovered_even ==
      (uint16_t)input.coeffs[even_index] &&
    recovered_odd ==
      (uint16_t)input.coeffs[odd_index],
    "PBYTES-T4.NVC1 arithmetic recovery control");

  if (scenario == 0u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV01 first-pair zero recovery witness");
  }

  if (scenario == 1u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV02 last-pair q-minus-one recovery witness");
  }

  if (scenario == 2u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV03 first-pair 255-and-15 recovery witness");
  }

  if (scenario == 3u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV04 last-pair 256-and-16 recovery witness");
  }
}
