#include <stdint.h>

#include "compress.h"

static void encode_raw_pair(
    uint8_t *out,
    uint32_t x,
    uint32_t y)
{
  out[0] =
      (uint8_t)(x % UINT32_C(256));

  out[1] =
      (uint8_t)(
          (x / UINT32_C(256)) +
          UINT32_C(16) * (y % UINT32_C(16)));

  out[2] =
      (uint8_t)(y / UINT32_C(16));
}

void harness(void)
{
  uint8_t zero_bytes[MLKEM_POLYBYTES] = {0};
  uint8_t max_boundary_bytes[MLKEM_POLYBYTES] = {0};
  uint8_t encoded_zero[MLKEM_POLYBYTES] = {0};
  uint8_t encoded_max[MLKEM_POLYBYTES] = {0};

  mlk_poly decoded_zero_bytes;
  mlk_poly decoded_max_bytes;
  mlk_poly decoded_raw_zero;
  mlk_poly decoded_raw_max;

  uint32_t first_x;
  uint32_t last_y;

  max_boundary_bytes[0] = UINT8_C(255);
  max_boundary_bytes[1] = UINT8_C(255);
  max_boundary_bytes[2] = UINT8_C(255);

  max_boundary_bytes[MLKEM_POLYBYTES - 3u] = UINT8_C(255);
  max_boundary_bytes[MLKEM_POLYBYTES - 2u] = UINT8_C(255);
  max_boundary_bytes[MLKEM_POLYBYTES - 1u] = UINT8_C(255);

  mlk_poly_frombytes(&decoded_zero_bytes, zero_bytes);
  mlk_poly_frombytes(&decoded_max_bytes, max_boundary_bytes);

  first_x =
      (uint32_t)(uint16_t)decoded_zero_bytes.coeffs[0];

  last_y =
      (uint32_t)(uint16_t)
          decoded_zero_bytes.coeffs[MLKEM_N - 1u];

  __CPROVER_assert(
      (uint8_t)(first_x % UINT32_C(256)) == UINT8_C(0),
      "PFB-T4 control zero-byte first boundary roundtrips");

  __CPROVER_assert(
      (uint8_t)(last_y / UINT32_C(16)) == UINT8_C(0),
      "PFB-T4 control zero-byte last boundary roundtrips");

  first_x =
      (uint32_t)(uint16_t)decoded_max_bytes.coeffs[0];

  last_y =
      (uint32_t)(uint16_t)
          decoded_max_bytes.coeffs[MLKEM_N - 1u];

  __CPROVER_assert(
      (uint8_t)(first_x % UINT32_C(256)) == UINT8_C(255),
      "PFB-T4 control max-byte first boundary roundtrips");

  __CPROVER_assert(
      (uint8_t)(last_y / UINT32_C(16)) == UINT8_C(255),
      "PFB-T4 control max-byte last boundary roundtrips");

  encode_raw_pair(
      &encoded_zero[0],
      UINT32_C(0),
      UINT32_C(0));

  encode_raw_pair(
      &encoded_zero[MLKEM_POLYBYTES - 3u],
      UINT32_C(0),
      UINT32_C(0));

  encode_raw_pair(
      &encoded_max[0],
      UINT32_C(4095),
      UINT32_C(4095));

  encode_raw_pair(
      &encoded_max[MLKEM_POLYBYTES - 3u],
      UINT32_C(4095),
      UINT32_C(4095));

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
