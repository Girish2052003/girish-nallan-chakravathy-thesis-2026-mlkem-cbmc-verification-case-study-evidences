/*
 * POLYCOMP-D4-T3 nibble preservation.
 *
 * For every possible 128-byte input, real decompression followed by real
 * compression preserves the low and high nibble of every byte.
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
  unsigned i;

  mlk_poly_decompress_d4_c(
      &intermediate,
      input);

  mlk_poly_compress_d4_c(
      reconstructed,
      &intermediate);

  for (i = 0;
       i < MLKEM_POLYCOMPRESSEDBYTES_D4;
       i++)
  {
    __CPROVER_assert(
        (reconstructed[i] & (uint8_t)0x0Fu) ==
            (input[i] & (uint8_t)0x0Fu),
        "POLYCOMP-D4-T3 nibble preservation: every low nibble is preserved");

    __CPROVER_assert(
        (reconstructed[i] >> 4) ==
            (input[i] >> 4),
        "POLYCOMP-D4-T3 nibble preservation: every high nibble is preserved");
  }
#endif
}
