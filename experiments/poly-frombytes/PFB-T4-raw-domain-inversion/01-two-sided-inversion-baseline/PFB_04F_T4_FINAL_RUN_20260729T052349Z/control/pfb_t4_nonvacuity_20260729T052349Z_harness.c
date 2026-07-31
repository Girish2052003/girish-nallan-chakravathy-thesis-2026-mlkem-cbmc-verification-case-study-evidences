#include <stdint.h>

#include "compress.h"

static void encode_raw(
    uint8_t out[MLKEM_POLYBYTES],
    const mlk_poly *p)
{
  uint32_t block_index;
  uint32_t x;
  uint32_t y;

  for (block_index = 0u;
       block_index < (MLKEM_N / 2u);
       block_index++)
  {
    x =
        (uint32_t)(uint16_t)
            p->coeffs[2u * block_index];
    y =
        (uint32_t)(uint16_t)
            p->coeffs[2u * block_index + 1u];

    out[3u * block_index] =
        (uint8_t)(x % UINT32_C(256));

    out[3u * block_index + 1u] =
        (uint8_t)(
            (x / UINT32_C(256)) +
            UINT32_C(16) * (y % UINT32_C(16)));

    out[3u * block_index + 2u] =
        (uint8_t)(y / UINT32_C(16));
  }
}

void harness(void)
{
  uint8_t zero_bytes[MLKEM_POLYBYTES] = {0};
  uint8_t max_bytes[MLKEM_POLYBYTES];
  uint8_t recovered_zero[MLKEM_POLYBYTES];
  uint8_t recovered_max[MLKEM_POLYBYTES];

  uint8_t encoded_zero[MLKEM_POLYBYTES];
  uint8_t encoded_max[MLKEM_POLYBYTES];

  mlk_poly decoded_zero_bytes;
  mlk_poly decoded_max_bytes;
  mlk_poly raw_zero = {{0}};
  mlk_poly raw_max;
  mlk_poly decoded_raw_zero;
  mlk_poly decoded_raw_max;

  uint32_t index;

  for (index = 0u; index < MLKEM_POLYBYTES; index++)
  {
    max_bytes[index] = UINT8_C(255);
  }

  for (index = 0u; index < MLKEM_N; index++)
  {
    raw_max.coeffs[index] = INT16_C(4095);
  }

  mlk_poly_frombytes(&decoded_zero_bytes, zero_bytes);
  mlk_poly_frombytes(&decoded_max_bytes, max_bytes);

  encode_raw(recovered_zero, &decoded_zero_bytes);
  encode_raw(recovered_max, &decoded_max_bytes);

  __CPROVER_assert(
      recovered_zero[0] == UINT8_C(0),
      "PFB-T4 control zero-byte first boundary roundtrips");

  __CPROVER_assert(
      recovered_zero[MLKEM_POLYBYTES - 1u] == UINT8_C(0),
      "PFB-T4 control zero-byte last boundary roundtrips");

  __CPROVER_assert(
      recovered_max[0] == UINT8_C(255),
      "PFB-T4 control max-byte first boundary roundtrips");

  __CPROVER_assert(
      recovered_max[MLKEM_POLYBYTES - 1u] == UINT8_C(255),
      "PFB-T4 control max-byte last boundary roundtrips");

  encode_raw(encoded_zero, &raw_zero);
  encode_raw(encoded_max, &raw_max);

  mlk_poly_frombytes(&decoded_raw_zero, encoded_zero);
  mlk_poly_frombytes(&decoded_raw_max, encoded_max);

  __CPROVER_assert(
      decoded_raw_zero.coeffs[0] == INT16_C(0),
      "PFB-T4 control raw-zero first coefficient roundtrips");

  __CPROVER_assert(
      decoded_raw_zero.coeffs[MLKEM_N - 1u] == INT16_C(0),
      "PFB-T4 control raw-zero last coefficient roundtrips");

  __CPROVER_assert(
      decoded_raw_max.coeffs[0] == INT16_C(4095),
      "PFB-T4 control raw-4095 first coefficient roundtrips");

  __CPROVER_assert(
      decoded_raw_max.coeffs[MLKEM_N - 1u] == INT16_C(4095),
      "PFB-T4 control raw-4095 last coefficient roundtrips");
}
