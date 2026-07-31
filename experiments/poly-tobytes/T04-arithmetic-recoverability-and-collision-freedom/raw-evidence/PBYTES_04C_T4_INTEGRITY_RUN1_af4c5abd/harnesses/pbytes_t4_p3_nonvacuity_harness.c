// PBYTES-T4.P3 block-equivalence non-vacuity companion.
//
// NV05 and NV06 exercise pair-equal/block-equal cases.
// NV07 and NV08 exercise pair-different/block-different cases.
//
// The NVC2 assertion is a real control and must succeed.
// NV05--NV08 are deliberately false reachability witnesses.

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
  unsigned even_index;
  unsigned odd_index;
  unsigned base;
  unsigned i;

  _Bool pair_equal;
  _Bool block_equal;

  __CPROVER_assume(scenario < 4u);

  selected_pair =
    (scenario == 0u || scenario == 2u)
      ? 0u
      : PBYTES_PAIR_COUNT - 1u;

  even_index = 2u * selected_pair;
  odd_index = even_index + 1u;

  for (i = 0u; i < MLKEM_N; i++)
  {
    input_a.coeffs[i] = 0;
    input_b.coeffs[i] = 0;
  }

  /*
   * Equal pair at the first position.
   */
  if (scenario == 0u)
  {
    input_a.coeffs[even_index] = 0;
    input_a.coeffs[odd_index] = 0;

    input_b.coeffs[even_index] = 0;
    input_b.coeffs[odd_index] = 0;
  }

  /*
   * Equal pair at the last position.
   */
  if (scenario == 1u)
  {
    input_a.coeffs[even_index] = MLKEM_Q - 1;
    input_a.coeffs[odd_index] = MLKEM_Q - 1;

    input_b.coeffs[even_index] = MLKEM_Q - 1;
    input_b.coeffs[odd_index] = MLKEM_Q - 1;
  }

  /*
   * Pair differs only in the even coefficient.
   */
  if (scenario == 2u)
  {
    input_a.coeffs[even_index] = 255;
    input_a.coeffs[odd_index] = 15;

    input_b.coeffs[even_index] = 256;
    input_b.coeffs[odd_index] = 15;
  }

  /*
   * Pair differs only in the odd coefficient.
   */
  if (scenario == 3u)
  {
    input_a.coeffs[even_index] = 256;
    input_a.coeffs[odd_index] = 15;

    input_b.coeffs[even_index] = 256;
    input_b.coeffs[odd_index] = 16;
  }

  mlk_poly_tobytes(output_a, &input_a);
  mlk_poly_tobytes(output_b, &input_b);

  base = 3u * selected_pair;

  pair_equal =
    input_a.coeffs[even_index] ==
      input_b.coeffs[even_index] &&
    input_a.coeffs[odd_index] ==
      input_b.coeffs[odd_index];

  block_equal =
    output_a[base] == output_b[base] &&
    output_a[base + 1u] == output_b[base + 1u] &&
    output_a[base + 2u] == output_b[base + 2u];

  __CPROVER_assert(
    pair_equal == block_equal,
    "PBYTES-T4.NVC2 block-equivalence control");

  if (scenario == 0u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV05 first-pair equal-zero witness");
  }

  if (scenario == 1u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV06 last-pair equal-q-minus-one witness");
  }

  if (scenario == 2u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV07 first-pair even-difference witness");
  }

  if (scenario == 3u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T4.NV08 last-pair odd-difference witness");
  }
}
