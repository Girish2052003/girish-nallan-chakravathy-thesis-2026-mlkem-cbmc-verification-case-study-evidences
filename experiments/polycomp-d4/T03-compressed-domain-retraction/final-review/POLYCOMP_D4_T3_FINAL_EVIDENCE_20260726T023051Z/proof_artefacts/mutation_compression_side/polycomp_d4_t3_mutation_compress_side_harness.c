/*
 * POLYCOMP-D4-T3 compression-side fault injection.
 *
 * Both real production functions are called, then the nibbles of output byte
 * zero are swapped. The registered byte-retraction assertion must detect this
 * one-sided perturbation.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

void harness(void)
{
#if MLKEM_K != 4
  uint8_t input[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly intermediate;
  uint8_t reconstructed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  uint8_t byte_zero;
  unsigned i;

  mlk_poly_decompress_d4_c(
      &intermediate,
      input);

  mlk_poly_compress_d4_c(
      reconstructed,
      &intermediate);

  byte_zero = reconstructed[0];
  reconstructed[0] =
      (uint8_t)(
          (byte_zero >> 4) |
          (uint8_t)(byte_zero << 4));

  for (i = 0;
       i < MLKEM_POLYCOMPRESSEDBYTES_D4;
       i++)
  {
    __CPROVER_assert(
        reconstructed[i] == input[i],
        "POLYCOMP-D4-T3: compressing the real D4 decompression reconstructs every original input byte");
  }
#endif
}
