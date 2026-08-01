#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T4.P1 — arbitrary bytes -> real decoder -> independent raw encoder.
 *
 * The independent encoder uses only widened division and remainder. It does
 * not call mlk_poly_tobytes, mlk_poly_frombytes, or copy the decoder's
 * mask/shift expressions. An arbitrary byte index makes the assertion cover
 * all MLKEM_POLYBYTES bytes.
 */
void harness(void)
{
  uint8_t input[MLKEM_POLYBYTES];
  uint8_t recovered[MLKEM_POLYBYTES];

  mlk_poly decoded;

  size_t byte_index;
  uint32_t block_index;
  uint32_t x;
  uint32_t y;

  __CPROVER_assume(byte_index < MLKEM_POLYBYTES);

  mlk_poly_frombytes(&decoded, input);

  for (block_index = 0u;
       block_index < (MLKEM_N / 2u);
       block_index++)
  {
    x =
        (uint32_t)(uint16_t)
            decoded.coeffs[2u * block_index];
    y =
        (uint32_t)(uint16_t)
            decoded.coeffs[2u * block_index + 1u];

    recovered[3u * block_index] =
        (uint8_t)(x % UINT32_C(256));

    recovered[3u * block_index + 1u] =
        (uint8_t)(
            (x / UINT32_C(256)) +
            UINT32_C(16) * (y % UINT32_C(16)));

    recovered[3u * block_index + 2u] =
        (uint8_t)(y / UINT32_C(16));
  }

  __CPROVER_assert(
      recovered[byte_index] == input[byte_index],
      "PFB-T4.P1 arbitrary bytes survive decode and independent raw encode");
}
