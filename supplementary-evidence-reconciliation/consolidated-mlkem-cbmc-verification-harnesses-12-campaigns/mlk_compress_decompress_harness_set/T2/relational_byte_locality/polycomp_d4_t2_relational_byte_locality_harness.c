/*
 * POLYCOMP-D4-T2 relational byte locality.
 *
 * For two arbitrary compressed inputs that agree at one symbolic byte k,
 * the two coefficients decoded from byte k must agree after the real
 * portable-C decompressor is called on both inputs.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assume(_Bool condition);

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

void harness(void)
{
#if MLKEM_K != 4
  uint8_t left_input[MLKEM_POLYCOMPRESSEDBYTES_D4];
  uint8_t right_input[MLKEM_POLYCOMPRESSEDBYTES_D4];

  mlk_poly left_output;
  mlk_poly right_output;

  unsigned k;

  __CPROVER_assume(
      k < MLKEM_POLYCOMPRESSEDBYTES_D4);

  __CPROVER_assume(
      left_input[k] == right_input[k]);

  mlk_poly_decompress_d4_c(
      &left_output,
      left_input);

  mlk_poly_decompress_d4_c(
      &right_output,
      right_input);

  __CPROVER_assert(
      left_output.coeffs[2u * k] ==
          right_output.coeffs[2u * k],
      "POLYCOMP-D4-T2 locality: equal packed byte gives equal low-nibble coefficient");

  __CPROVER_assert(
      left_output.coeffs[2u * k + 1u] ==
          right_output.coeffs[2u * k + 1u],
      "POLYCOMP-D4-T2 locality: equal packed byte gives equal high-nibble coefficient");
#endif
}
