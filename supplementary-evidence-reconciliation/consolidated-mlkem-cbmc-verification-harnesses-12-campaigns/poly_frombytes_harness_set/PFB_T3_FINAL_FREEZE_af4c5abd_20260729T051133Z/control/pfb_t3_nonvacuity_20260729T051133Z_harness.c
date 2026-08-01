#include <stdint.h>

#include "compress.h"

static uint32_t pack_pair(const mlk_poly *p, uint32_t block_index)
{
  return
      (uint32_t)(uint16_t)p->coeffs[2u * block_index] +
      UINT32_C(4096) *
          (uint32_t)(uint16_t)p->coeffs[2u * block_index + 1u];
}

/*
 * Concrete witnesses cover:
 *   * equal inputs and equal outputs at block 0;
 *   * a first-byte difference at block 0;
 *   * a middle-byte difference at block 127;
 *   * a third-byte difference at block 127.
 *
 * There are no assumptions in this control harness.
 */
void harness(void)
{
  uint8_t zero_input[MLKEM_POLYBYTES] = {0};
  uint8_t same_input[MLKEM_POLYBYTES] = {0};
  uint8_t first_byte_input[MLKEM_POLYBYTES] = {0};
  uint8_t middle_byte_input[MLKEM_POLYBYTES] = {0};
  uint8_t third_byte_input[MLKEM_POLYBYTES] = {0};

  mlk_poly zero_output;
  mlk_poly same_output;
  mlk_poly first_byte_output;
  mlk_poly middle_byte_output;
  mlk_poly third_byte_output;

  first_byte_input[0] = 0x01u;
  middle_byte_input[3u * 127u + 1u] = 0xF0u;
  third_byte_input[3u * 127u + 2u] = 0x80u;

  mlk_poly_frombytes(&zero_output, zero_input);
  mlk_poly_frombytes(&same_output, same_input);
  mlk_poly_frombytes(&first_byte_output, first_byte_input);
  mlk_poly_frombytes(&middle_byte_output, middle_byte_input);
  mlk_poly_frombytes(&third_byte_output, third_byte_input);

  __CPROVER_assert(
      (pack_pair(&zero_output, 0u) ^
       pack_pair(&same_output, 0u)) == UINT32_C(0),
      "PFB-T3 control equal block has zero packed-output XOR");

  __CPROVER_assert(
      (zero_output.coeffs[0] == same_output.coeffs[0]) &&
          (zero_output.coeffs[1] == same_output.coeffs[1]),
      "PFB-T3 control equal input block has equal decoded pair");

  __CPROVER_assert(
      (pack_pair(&zero_output, 0u) ^
       pack_pair(&first_byte_output, 0u)) == UINT32_C(1),
      "PFB-T3 control block-0 first-byte XOR is conserved");

  __CPROVER_assert(
      (zero_output.coeffs[0] != first_byte_output.coeffs[0]) ||
          (zero_output.coeffs[1] != first_byte_output.coeffs[1]),
      "PFB-T3 control block-0 first-byte change changes pair");

  __CPROVER_assert(
      (pack_pair(&zero_output, 127u) ^
       pack_pair(&middle_byte_output, 127u)) == UINT32_C(61440),
      "PFB-T3 control block-127 middle-byte XOR is conserved");

  __CPROVER_assert(
      (zero_output.coeffs[254] != middle_byte_output.coeffs[254]) ||
          (zero_output.coeffs[255] != middle_byte_output.coeffs[255]),
      "PFB-T3 control block-127 middle-byte change changes pair");

  __CPROVER_assert(
      (pack_pair(&zero_output, 127u) ^
       pack_pair(&third_byte_output, 127u)) == UINT32_C(8388608),
      "PFB-T3 control block-127 third-byte XOR is conserved");

  __CPROVER_assert(
      (zero_output.coeffs[254] != third_byte_output.coeffs[254]) ||
          (zero_output.coeffs[255] != third_byte_output.coeffs[255]),
      "PFB-T3 control block-127 third-byte change changes pair");
}
