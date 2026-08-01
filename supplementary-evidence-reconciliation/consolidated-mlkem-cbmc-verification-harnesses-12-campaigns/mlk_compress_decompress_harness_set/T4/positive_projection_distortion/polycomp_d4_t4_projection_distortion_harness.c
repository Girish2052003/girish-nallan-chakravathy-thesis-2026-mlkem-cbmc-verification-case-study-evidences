/*
 * POLYCOMP-D4-T4 quantizer projection and distortion.
 *
 * Domain:
 *   every polynomial whose 256 coefficients satisfy
 *   0 <= coeff < 3329.
 *
 * Construction:
 *   projected = decompress_d4(compress_d4(input)).
 *
 * Claims:
 *   1. Every projected coefficient belongs to the exact 16-value D4 codebook.
 *   2. The modular distance from each input coefficient to its projection
 *      is at most 104.
 *
 * Both real portable-C production functions are called. No production source
 * is modified. The only assumptions define the frozen canonical domain.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void __CPROVER_assume(
    _Bool condition);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

static _Bool t4_is_codebook_value(
    int16_t value)
{
  return
      value == 0 ||
      value == 208 ||
      value == 416 ||
      value == 624 ||
      value == 832 ||
      value == 1040 ||
      value == 1248 ||
      value == 1456 ||
      value == 1665 ||
      value == 1873 ||
      value == 2081 ||
      value == 2289 ||
      value == 2497 ||
      value == 2705 ||
      value == 2913 ||
      value == 3121;
}

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input;
  uint8_t compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly projected;
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(
        input.coeffs[i] >= 0 &&
        input.coeffs[i] < MLKEM_Q);
  }

  mlk_poly_compress_d4_c(
      compressed,
      &input);

  mlk_poly_decompress_d4_c(
      &projected,
      compressed);

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t difference =
        (int32_t)input.coeffs[i] -
        (int32_t)projected.coeffs[i];

    int32_t modular_distance;

    if (difference < 0)
    {
      difference = -difference;
    }

    modular_distance = difference;

    if (modular_distance > MLKEM_Q / 2)
    {
      modular_distance =
          MLKEM_Q - modular_distance;
    }

    __CPROVER_assert(
        t4_is_codebook_value(
            projected.coeffs[i]),
        "POLYCOMP-D4-T4: every projected coefficient belongs to the exact D4 codebook");

    __CPROVER_assert(
        modular_distance <= 104,
        "POLYCOMP-D4-T4: every canonical coefficient has modular projection distortion at most 104");
  }
#endif
}
