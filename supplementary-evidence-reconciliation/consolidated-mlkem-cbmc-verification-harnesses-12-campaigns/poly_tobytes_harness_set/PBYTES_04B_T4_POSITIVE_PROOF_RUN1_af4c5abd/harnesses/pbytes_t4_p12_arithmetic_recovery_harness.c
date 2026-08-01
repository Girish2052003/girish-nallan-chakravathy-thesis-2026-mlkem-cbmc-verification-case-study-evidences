// PBYTES-T4.P1 and PBYTES-T4.P2
//
// Independently decode one arbitrary actual output block using:
//
//   W = b0 + 256*b1 + 65536*b2
//   even = W mod 4096
//   odd  = W / 4096
//
// The selected pair is symbolic, so all 128 blocks are covered.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly input;
  uint8_t output[MLKEM_POLYBYTES];

  uint16_t selected_pair;

  uint32_t packed_word;
  uint16_t recovered_even;
  uint16_t recovered_odd;

  unsigned base;
  unsigned even_index;
  unsigned odd_index;
  unsigned i;

  __CPROVER_assume(selected_pair < PBYTES_PAIR_COUNT);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);
  }

  mlk_poly_tobytes(output, &input);

  base = 3u * (unsigned)selected_pair;

  even_index = 2u * (unsigned)selected_pair;
  odd_index = even_index + 1u;

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
      (uint16_t)input.coeffs[even_index],
    "PBYTES-T4.P1 arithmetic recovery of the even coefficient");

  __CPROVER_assert(
    recovered_odd ==
      (uint16_t)input.coeffs[odd_index],
    "PBYTES-T4.P2 arithmetic recovery of the odd coefficient");
}
