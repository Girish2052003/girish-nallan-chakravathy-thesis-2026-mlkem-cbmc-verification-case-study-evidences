// PBYTES-T3.P5 — reverse image direction.
//
// The forward direction of the image equivalence is P1 plus P2:
//
//   actual serialization => all 256 decoded fields are canonical.
//
// This harness proves the reverse direction:
//
//   all 256 decoded fields canonical => the complete byte array is
//   produced by mlk_poly_tobytes for the independently decoded polynomial.
//
// No mlk_poly_frombytes call is used.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly decoded_input;

  uint8_t candidate[MLKEM_POLYBYTES];
  uint8_t actual_output[MLKEM_POLYBYTES];

  uint16_t even_field;
  uint16_t odd_field;

  unsigned base;
  unsigned i;

  _Bool complete_equality = 1;

  /*
   * Independently decode all 128 blocks.
   *
   * The candidate byte array is arbitrary. The assumptions restrict it
   * precisely to arrays whose 256 decoded fields are canonical.
   */
  for (i = 0u; i < PBYTES_PAIR_COUNT; i++)
  {
    base = 3u * i;

    even_field =
      (uint16_t)candidate[base] +
      (uint16_t)(
        256u *
        (uint16_t)(candidate[base + 1u] & 0x0Fu));

    odd_field =
      (uint16_t)(candidate[base + 1u] >> 4) +
      (uint16_t)(
        16u * (uint16_t)candidate[base + 2u]);

    __CPROVER_assume(even_field < MLKEM_Q);
    __CPROVER_assume(odd_field < MLKEM_Q);

    decoded_input.coeffs[2u * i] =
      (int16_t)even_field;

    decoded_input.coeffs[2u * i + 1u] =
      (int16_t)odd_field;
  }

  mlk_poly_tobytes(actual_output, &decoded_input);

  for (i = 0u; i < MLKEM_POLYBYTES; i++)
  {
    if (actual_output[i] != candidate[i])
    {
      complete_equality = 0;
    }
  }

  __CPROVER_assert(
    complete_equality,
    "PBYTES-T3.P5 full-array image iff all 256 fields are canonical");
}
