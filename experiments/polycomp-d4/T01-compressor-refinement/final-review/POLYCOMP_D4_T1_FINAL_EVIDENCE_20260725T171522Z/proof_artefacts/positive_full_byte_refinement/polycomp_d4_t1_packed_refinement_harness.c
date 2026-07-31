/*
 * POLYCOMP-D4-T1 positive semantic preflight.
 *
 * Clean-room property harness.
 *
 * This harness does not modify mlkem-native production code and does not
 * reproduce the native CBMC harness. It executes the portable-C compressor
 * and compares every produced byte against a division-based mathematical
 * specification.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assume(_Bool condition);
void __CPROVER_assert(_Bool condition, const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

static uint8_t polycomp_d4_spec_compress_scalar(int16_t value)
{
  uint32_t numerator;

  /*
   * Independent specification:
   *
   *   round(16 * value / q) mod 16
   *
   * Production uses a multiplication by a precomputed constant and shift.
   * This specification deliberately uses exact integer division instead.
   */
  numerator =
      ((uint32_t)(uint16_t)value * (uint32_t)16u) +
      (uint32_t)(MLKEM_Q / 2);

  return (uint8_t)(
      (numerator / (uint32_t)MLKEM_Q) %
      (uint32_t)16u);
}

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input;
  uint8_t actual[MLKEM_POLYCOMPRESSEDBYTES_D4];

  unsigned i;

  uint8_t expected_low;
  uint8_t expected_high;
  uint8_t expected_byte;

  /*
   * Domain required by the production compressor:
   * every coefficient is unsigned canonical modulo q.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);
  }

  /*
   * Execute the real portable-C implementation.
   * No wrapper dispatch and no native backend are involved.
   */
  mlk_poly_compress_d4_c(actual, &input);

  /*
   * Full 128-byte packed refinement.
   *
   * Byte i contains:
   *   low nibble  = Compress_4(input[2*i])
   *   high nibble = Compress_4(input[2*i+1])
   */
  for (i = 0; i < MLKEM_POLYCOMPRESSEDBYTES_D4; i++)
  {
    expected_low =
        polycomp_d4_spec_compress_scalar(
            input.coeffs[2u * i]);

    expected_high =
        polycomp_d4_spec_compress_scalar(
            input.coeffs[2u * i + 1u]);

    expected_byte =
        (uint8_t)(
            expected_low |
            (uint8_t)(expected_high << 4));

    __CPROVER_assert(
        actual[i] == expected_byte,
        "POLYCOMP-D4-T1: every packed byte equals the independent specification");
  }
#endif
}
