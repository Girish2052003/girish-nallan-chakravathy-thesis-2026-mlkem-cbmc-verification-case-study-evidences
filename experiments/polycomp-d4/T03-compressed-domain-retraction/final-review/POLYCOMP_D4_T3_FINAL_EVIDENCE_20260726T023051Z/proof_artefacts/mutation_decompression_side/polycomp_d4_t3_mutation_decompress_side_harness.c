/*
 * POLYCOMP-D4-T3 decompression-side fault injection.
 *
 * The real decompressor is called, then the two coefficients decoded from
 * byte zero are swapped before the real compressor is called. The registered
 * byte-retraction assertion must detect this one-sided perturbation.
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
  int16_t temporary;
  unsigned i;

  mlk_poly_decompress_d4_c(
      &intermediate,
      input);

  temporary = intermediate.coeffs[0];
  intermediate.coeffs[0] = intermediate.coeffs[1];
  intermediate.coeffs[1] = temporary;

  mlk_poly_compress_d4_c(
      reconstructed,
      &intermediate);

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
