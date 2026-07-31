// PBYTES-T3.P1 and PBYTES-T3.P2
//
// Decode one arbitrary actual output block using independent arithmetic.
// The selected pair is symbolic, so the proof covers all 128 blocks.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly input;
  uint8_t output[MLKEM_POLYBYTES];

  uint16_t selected_pair;

  unsigned base;
  unsigned i;

  uint8_t b0;
  uint8_t b1;
  uint8_t b2;

  uint16_t even_field;
  uint16_t odd_field;

  __CPROVER_assume(selected_pair < PBYTES_PAIR_COUNT);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);
  }

  mlk_poly_tobytes(output, &input);

  base = 3u * (unsigned)selected_pair;

  b0 = output[base];
  b1 = output[base + 1u];
  b2 = output[base + 2u];

  even_field =
    (uint16_t)b0 +
    (uint16_t)(256u * (uint16_t)(b1 & 0x0Fu));

  odd_field =
    (uint16_t)(b1 >> 4) +
    (uint16_t)(16u * (uint16_t)b2);

  __CPROVER_assert(
    even_field < MLKEM_Q,
    "PBYTES-T3.P1 every produced even field is below MLKEM_Q");

  __CPROVER_assert(
    odd_field < MLKEM_Q,
    "PBYTES-T3.P2 every produced odd field is below MLKEM_Q");
}
