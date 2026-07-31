/*
 * POLYCOMP-D4-T2 — Portable-C decompressor refinement.
 *
 * Clean-room repository-level semantic harness.
 *
 * For every arbitrary 128-byte compressed input, verify that every one
 * of the 256 output coefficients equals an independent nibble-extraction
 * and exact integer decompression specification.
 *
 * No production source is modified.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

static int16_t polycomp_d4_spec_decompress_scalar(
    uint8_t nibble)
{
  uint32_t numerator;

  numerator =
      ((uint32_t)nibble * (uint32_t)MLKEM_Q) +
      (uint32_t)8u;

  return (int16_t)(
      numerator / (uint32_t)16u);
}

void harness(void)
{
#if MLKEM_K != 4
  uint8_t input[MLKEM_POLYCOMPRESSEDBYTES_D4];

  /*
   * Intentionally left nondeterministic before the call.
   * The assertions therefore also require complete output overwrite.
   */
  mlk_poly actual;

  unsigned i;

  mlk_poly_decompress_d4_c(
      &actual,
      input);

  for (i = 0; i < MLKEM_N; i++)
  {
    uint8_t packed_byte;
    uint8_t nibble;
    int16_t expected;

    packed_byte = input[i / 2u];

    if ((i & 1u) == 0u)
    {
      nibble =
          (uint8_t)(
              packed_byte &
              (uint8_t)0x0Fu);
    }
    else
    {
      nibble =
          (uint8_t)(
              packed_byte >>
              4);
    }

    expected =
        polycomp_d4_spec_decompress_scalar(
            nibble);

    __CPROVER_assert(
        actual.coeffs[i] == expected,
        "POLYCOMP-D4-T2: every coefficient equals the independent nibble-decompression specification");

    __CPROVER_assert(
        actual.coeffs[i] >= 0 &&
            actual.coeffs[i] < MLKEM_Q,
        "POLYCOMP-D4-T2: every decompressed coefficient lies in the canonical range");
  }
#endif
}
