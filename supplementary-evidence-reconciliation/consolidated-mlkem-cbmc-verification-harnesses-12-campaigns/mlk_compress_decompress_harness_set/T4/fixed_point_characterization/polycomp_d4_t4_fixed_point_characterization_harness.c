/*
 * POLYCOMP-D4-T4 fixed-point characterization.
 *
 * For every canonical coefficient:
 *
 *   projection(a) == a
 *
 * if and only if a belongs to the exact D4 codebook.
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
    __CPROVER_assert(
        (projected.coeffs[i] == input.coeffs[i]) ==
            t4_is_codebook_value(input.coeffs[i]),
        "POLYCOMP-D4-T4 fixed points: a canonical coefficient is unchanged exactly when it is a D4 codebook value");
  }
#endif
}
