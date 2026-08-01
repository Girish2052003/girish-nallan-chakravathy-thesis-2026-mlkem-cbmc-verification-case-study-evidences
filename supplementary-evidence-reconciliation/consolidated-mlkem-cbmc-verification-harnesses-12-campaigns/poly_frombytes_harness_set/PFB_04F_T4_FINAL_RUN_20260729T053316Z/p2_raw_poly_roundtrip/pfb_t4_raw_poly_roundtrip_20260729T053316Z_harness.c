#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T4.P2 — arbitrary raw polynomial -> independent raw encoder ->
 * real decoder.
 *
 * Every source coefficient is restricted only to the frozen raw domain
 * [0, 4096). The independent encoder uses widened division and remainder.
 * An arbitrary coefficient index makes the assertion cover all MLKEM_N
 * coefficients.
 */
void harness(void)
{
  mlk_poly raw_input;
  mlk_poly decoded;

  uint8_t encoded[MLKEM_POLYBYTES];

  size_t coeff_index;
  uint32_t index;
  uint32_t block_index;
  uint32_t x;
  uint32_t y;

  __CPROVER_assume(coeff_index < MLKEM_N);

  for (index = 0u; index < MLKEM_N; index++)
  {
    __CPROVER_assume(raw_input.coeffs[index] >= 0);
    __CPROVER_assume(
        (uint16_t)raw_input.coeffs[index] < UINT16_C(4096));
  }

  for (block_index = 0u;
       block_index < (MLKEM_N / 2u);
       block_index++)
  {
    x =
        (uint32_t)(uint16_t)
            raw_input.coeffs[2u * block_index];
    y =
        (uint32_t)(uint16_t)
            raw_input.coeffs[2u * block_index + 1u];

    encoded[3u * block_index] =
        (uint8_t)(x % UINT32_C(256));

    encoded[3u * block_index + 1u] =
        (uint8_t)(
            (x / UINT32_C(256)) +
            UINT32_C(16) * (y % UINT32_C(16)));

    encoded[3u * block_index + 2u] =
        (uint8_t)(y / UINT32_C(16));
  }

  mlk_poly_frombytes(&decoded, encoded);

  __CPROVER_assert(
      decoded.coeffs[coeff_index] ==
          raw_input.coeffs[coeff_index],
      "PFB-T4.P2 arbitrary raw polynomial survives independent encode and real decode");
}
