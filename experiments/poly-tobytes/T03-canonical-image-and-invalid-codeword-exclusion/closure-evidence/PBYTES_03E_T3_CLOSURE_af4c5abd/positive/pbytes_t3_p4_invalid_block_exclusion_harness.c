// PBYTES-T3.P4
//
// An arbitrary candidate block with at least one invalid decoded field
// cannot equal any block produced by a canonical input polynomial.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly input;
  uint8_t output[MLKEM_POLYBYTES];

  uint16_t selected_pair;

  uint8_t candidate_b0;
  uint8_t candidate_b1;
  uint8_t candidate_b2;

  uint16_t candidate_even_field;
  uint16_t candidate_odd_field;

  unsigned base;
  unsigned i;

  __CPROVER_assume(selected_pair < PBYTES_PAIR_COUNT);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);
  }

  candidate_even_field =
    (uint16_t)candidate_b0 +
    (uint16_t)(
      256u * (uint16_t)(candidate_b1 & 0x0Fu));

  candidate_odd_field =
    (uint16_t)(candidate_b1 >> 4) +
    (uint16_t)(16u * (uint16_t)candidate_b2);

  __CPROVER_assume(
    candidate_even_field >= MLKEM_Q ||
    candidate_odd_field >= MLKEM_Q);

  mlk_poly_tobytes(output, &input);

  base = 3u * (unsigned)selected_pair;

  __CPROVER_assert(
    output[base] != candidate_b0 ||
    output[base + 1u] != candidate_b1 ||
    output[base + 2u] != candidate_b2,
    "PBYTES-T3.P4 a block with either invalid field is not realizable");
}
