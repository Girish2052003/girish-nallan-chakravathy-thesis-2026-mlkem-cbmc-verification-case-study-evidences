/*
 * POLYCOMP-D4-T4 relational coordinate locality.
 *
 * For two canonical polynomials A and B and any valid coordinate k:
 *
 *   A[k] == B[k]  implies  Q(A)[k] == Q(B)[k].
 *
 * Both complete real portable-C projections are executed.
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
  mlk_poly input_a;
  mlk_poly input_b;
  uint8_t compressed_a[MLKEM_POLYCOMPRESSEDBYTES_D4];
  uint8_t compressed_b[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly projected_a;
  mlk_poly projected_b;
  unsigned i;
  unsigned k;

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(
        input_a.coeffs[i] >= 0 &&
        input_a.coeffs[i] < MLKEM_Q &&
        input_b.coeffs[i] >= 0 &&
        input_b.coeffs[i] < MLKEM_Q);
  }

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(
      input_a.coeffs[k] ==
      input_b.coeffs[k]);

  mlk_poly_compress_d4_c(
      compressed_a,
      &input_a);

  mlk_poly_decompress_d4_c(
      &projected_a,
      compressed_a);

  mlk_poly_compress_d4_c(
      compressed_b,
      &input_b);

  mlk_poly_decompress_d4_c(
      &projected_b,
      compressed_b);

  __CPROVER_assert(
      projected_a.coeffs[k] ==
          projected_b.coeffs[k],
      "POLYCOMP-D4-T4 locality: equal canonical input coefficients at one coordinate produce equal projected coefficients there");
#endif
}
