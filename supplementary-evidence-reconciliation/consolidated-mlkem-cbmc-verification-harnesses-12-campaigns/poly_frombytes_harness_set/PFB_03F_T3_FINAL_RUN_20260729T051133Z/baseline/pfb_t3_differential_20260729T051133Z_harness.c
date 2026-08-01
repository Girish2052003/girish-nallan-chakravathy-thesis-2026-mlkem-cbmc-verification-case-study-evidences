#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T3 arbitrary differential conservation.
 *
 * Two unrestricted input byte arrays are decoded by the real public
 * mlk_poly_frombytes path. The selected block is unrestricted subject only
 * to its valid range. The arithmetic oracle uses widened byte composition
 * and never calls the target or a production encoder.
 */
void harness(void)
{
  uint8_t first_input[MLKEM_POLYBYTES];
  uint8_t second_input[MLKEM_POLYBYTES];

  mlk_poly first_output;
  mlk_poly second_output;

  size_t block_index;

  uint32_t first_word24;
  uint32_t second_word24;
  uint32_t first_packed_output;
  uint32_t second_packed_output;

  uint8_t input_block_differs;
  uint8_t output_pair_differs;

  __CPROVER_assume(block_index < (MLKEM_N / 2u));

  mlk_poly_frombytes(&first_output, first_input);
  mlk_poly_frombytes(&second_output, second_input);

  first_word24 =
      (uint32_t)first_input[3u * block_index] +
      UINT32_C(256) *
          (uint32_t)first_input[3u * block_index + 1u] +
      UINT32_C(65536) *
          (uint32_t)first_input[3u * block_index + 2u];

  second_word24 =
      (uint32_t)second_input[3u * block_index] +
      UINT32_C(256) *
          (uint32_t)second_input[3u * block_index + 1u] +
      UINT32_C(65536) *
          (uint32_t)second_input[3u * block_index + 2u];

  first_packed_output =
      (uint32_t)(uint16_t)first_output.coeffs[2u * block_index] +
      UINT32_C(4096) *
          (uint32_t)(uint16_t)
              first_output.coeffs[2u * block_index + 1u];

  second_packed_output =
      (uint32_t)(uint16_t)second_output.coeffs[2u * block_index] +
      UINT32_C(4096) *
          (uint32_t)(uint16_t)
              second_output.coeffs[2u * block_index + 1u];

  __CPROVER_assert(
      (first_packed_output ^ second_packed_output) ==
          (first_word24 ^ second_word24),
      "PFB-T3.P1 packed-output XOR equals input 24-bit block XOR");

  input_block_differs =
      (uint8_t)(
          (first_input[3u * block_index] !=
           second_input[3u * block_index]) ||
          (first_input[3u * block_index + 1u] !=
           second_input[3u * block_index + 1u]) ||
          (first_input[3u * block_index + 2u] !=
           second_input[3u * block_index + 2u]));

  output_pair_differs =
      (uint8_t)(
          (first_output.coeffs[2u * block_index] !=
           second_output.coeffs[2u * block_index]) ||
          (first_output.coeffs[2u * block_index + 1u] !=
           second_output.coeffs[2u * block_index + 1u]));

  __CPROVER_assert(
      input_block_differs == output_pair_differs,
      "PFB-T3.P2 input block differs iff decoded pair differs");
}
