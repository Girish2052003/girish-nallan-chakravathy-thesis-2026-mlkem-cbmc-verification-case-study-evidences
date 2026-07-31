// PBYTES-T3.P3
//
// Every canonical pair of 12-bit fields is realizable as an actual
// three-byte output block at every symbolic pair position.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly input;
  uint8_t output[MLKEM_POLYBYTES];

  uint16_t selected_pair;
  uint16_t even_field;
  uint16_t odd_field;

  uint8_t expected_b0;
  uint8_t expected_b1;
  uint8_t expected_b2;

  unsigned base;
  unsigned i;

  __CPROVER_assume(selected_pair < PBYTES_PAIR_COUNT);

  __CPROVER_assume(even_field < MLKEM_Q);
  __CPROVER_assume(odd_field < MLKEM_Q);

  for (i = 0u; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 0;
  }

  input.coeffs[2u * (unsigned)selected_pair] =
    (int16_t)even_field;

  input.coeffs[2u * (unsigned)selected_pair + 1u] =
    (int16_t)odd_field;

  expected_b0 =
    (uint8_t)((unsigned)even_field % 256u);

  expected_b1 =
    (uint8_t)(
      ((unsigned)even_field / 256u) +
      16u * ((unsigned)odd_field % 16u));

  expected_b2 =
    (uint8_t)((unsigned)odd_field / 16u);

  mlk_poly_tobytes(output, &input);

  base = 3u * (unsigned)selected_pair;

  __CPROVER_assert(
    output[base] == expected_b0 &&
    output[base + 1u] == expected_b1 &&
    output[base + 2u] == expected_b2,
    "PBYTES-T3.P3 every canonical 24-bit block is realizable");
}
