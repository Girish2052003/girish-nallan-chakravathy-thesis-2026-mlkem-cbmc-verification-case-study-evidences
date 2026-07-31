/*
 * POLYCOMP-D4-T4 projection idempotence.
 *
 * For every canonical polynomial:
 *
 *   Q(Q(A)) == Q(A),
 *
 * where Q is the real portable-C compress/decompress projection.
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

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input;
  uint8_t first_compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly first_projection;
  uint8_t second_compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly second_projection;
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(
        input.coeffs[i] >= 0 &&
        input.coeffs[i] < MLKEM_Q);
  }

  mlk_poly_compress_d4_c(
      first_compressed,
      &input);

  mlk_poly_decompress_d4_c(
      &first_projection,
      first_compressed);

  mlk_poly_compress_d4_c(
      second_compressed,
      &first_projection);

  mlk_poly_decompress_d4_c(
      &second_projection,
      second_compressed);

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        second_projection.coeffs[i] ==
            first_projection.coeffs[i],
        "POLYCOMP-D4-T4 idempotence: applying the real D4 projection twice equals applying it once");
  }
#endif
}
