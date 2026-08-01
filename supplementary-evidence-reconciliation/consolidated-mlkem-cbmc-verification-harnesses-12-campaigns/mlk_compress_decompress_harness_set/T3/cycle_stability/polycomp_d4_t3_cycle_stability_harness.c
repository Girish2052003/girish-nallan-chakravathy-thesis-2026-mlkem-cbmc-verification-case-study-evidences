/*
 * POLYCOMP-D4-T3 cycle stability.
 *
 * Applying the real decompress/compress cycle twice is stable:
 *
 *   C(D(C(D(input)))) == C(D(input)).
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
  mlk_poly first_poly;
  uint8_t first_cycle[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly second_poly;
  uint8_t second_cycle[MLKEM_POLYCOMPRESSEDBYTES_D4];
  unsigned i;

  mlk_poly_decompress_d4_c(
      &first_poly,
      input);

  mlk_poly_compress_d4_c(
      first_cycle,
      &first_poly);

  mlk_poly_decompress_d4_c(
      &second_poly,
      first_cycle);

  mlk_poly_compress_d4_c(
      second_cycle,
      &second_poly);

  for (i = 0;
       i < MLKEM_POLYCOMPRESSEDBYTES_D4;
       i++)
  {
    __CPROVER_assert(
        second_cycle[i] == first_cycle[i],
        "POLYCOMP-D4-T3 cycle stability: a second real decompression-compression cycle is byte-stable");
  }
#endif
}
