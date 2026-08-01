// PBYTES-T4.P3
//
// For one arbitrary pair position, compare two actual output blocks
// generated from two independently symbolic canonical polynomials.
//
// The block equality relation must be exactly equivalent to equality
// of the corresponding coefficient pairs.

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

  uint16_t selected_pair;

  unsigned base;
  unsigned even_index;
  unsigned odd_index;
  unsigned i;

  _Bool block_equal;
  _Bool pair_equal;

  __CPROVER_assume(selected_pair < PBYTES_PAIR_COUNT);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input_a.coeffs[i] >= 0);
    __CPROVER_assume(input_a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(input_b.coeffs[i] >= 0);
    __CPROVER_assume(input_b.coeffs[i] < MLKEM_Q);
  }

  mlk_poly_tobytes(output_a, &input_a);
  mlk_poly_tobytes(output_b, &input_b);

  base = 3u * (unsigned)selected_pair;

  even_index = 2u * (unsigned)selected_pair;
  odd_index = even_index + 1u;

  block_equal =
    output_a[base] == output_b[base] &&
    output_a[base + 1u] == output_b[base + 1u] &&
    output_a[base + 2u] == output_b[base + 2u];

  pair_equal =
    input_a.coeffs[even_index] ==
      input_b.coeffs[even_index] &&
    input_a.coeffs[odd_index] ==
      input_b.coeffs[odd_index];

  __CPROVER_assert(
    block_equal == pair_equal,
    "PBYTES-T4.P3 block equality iff coefficient-pair equality");
}
