/*
 * POLYCOMP-D4-T4 sharp modular-distortion witness.
 *
 * Every input coefficient is the concrete canonical value 104.
 * The real D4 projection maps each coefficient to zero, so the modular
 * distortion is exactly 104. This proves the verified upper bound is sharp.
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
  mlk_poly input;
  uint8_t compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly projected;
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 104;
  }

  mlk_poly_compress_d4_c(
      compressed,
      &input);

  mlk_poly_decompress_d4_c(
      &projected,
      compressed);

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        projected.coeffs[i] == 0 &&
        (int32_t)input.coeffs[i] -
            (int32_t)projected.coeffs[i] == 104,
        "POLYCOMP-D4-T4 sharpness: canonical witness 104 attains modular distortion exactly 104");
  }
#endif
}
