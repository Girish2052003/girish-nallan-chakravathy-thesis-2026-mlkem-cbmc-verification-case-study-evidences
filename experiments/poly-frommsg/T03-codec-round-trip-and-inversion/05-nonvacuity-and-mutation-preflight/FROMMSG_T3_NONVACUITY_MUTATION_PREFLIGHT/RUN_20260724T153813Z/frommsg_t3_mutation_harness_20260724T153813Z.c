/*
 * FROMMSG-T3 semantic mutation companion.
 *
 * Every assertion below is deliberately incorrect and must be
 * rejected with a concrete CBMC counterexample.
 */

#include <stdint.h>

#include "compress.h"

typedef struct
{
  uint8_t bytes[MLKEM_INDCPA_MSGBYTES];
} frommsg_t3_message;

void harness(void)
{
  mlk_poly encoded1;
  mlk_poly encoded2;
  mlk_poly encoded3;

  frommsg_t3_message input;
  frommsg_t3_message decoded;
  frommsg_t3_message corrupted;

  unsigned byte_index;
  unsigned bit_index;
  unsigned coefficient_index;

  unsigned selected_coefficient;
  unsigned shifted_coefficient;
  unsigned wrong_bit_index;

  uint8_t decoded_bit;
  uint8_t wrong_input_bit;
  uint8_t bit_mask;

  __CPROVER_assume(
      byte_index < MLKEM_INDCPA_MSGBYTES);

  __CPROVER_assume(
      bit_index < 8u);

  __CPROVER_assume(
      coefficient_index < MLKEM_N);

  selected_coefficient =
      8u * byte_index + bit_index;

  shifted_coefficient =
      (coefficient_index + 1u) % MLKEM_N;

  wrong_bit_index =
      7u - bit_index;

  bit_mask =
      (uint8_t)(1u << bit_index);

  mlk_poly_frommsg(&encoded1, input.bytes);
  mlk_poly_tomsg(decoded.bytes, &encoded1);
  mlk_poly_frommsg(&encoded2, decoded.bytes);

  corrupted = decoded;

  corrupted.bytes[byte_index] =
      (uint8_t)(
          corrupted.bytes[byte_index] ^ bit_mask);

  mlk_poly_frommsg(&encoded3, corrupted.bytes);

  decoded_bit =
      (uint8_t)(
          (decoded.bytes[byte_index] >> bit_index) & 1u);

  wrong_input_bit =
      (uint8_t)(
          (input.bytes[byte_index] >> wrong_bit_index) & 1u);

  __CPROVER_assert(
      decoded.bytes[byte_index] ==
      (uint8_t)(input.bytes[byte_index] ^ 1u),
      "FROMMSG_T3_M1_ALTERED_BYTE_ROUND_TRIP");

  __CPROVER_assert(
      decoded_bit == wrong_input_bit,
      "FROMMSG_T3_M2_WRONG_MSB_FIRST_BIT_ORDER");

  __CPROVER_assert(
      encoded2.coeffs[coefficient_index] ==
      encoded1.coeffs[shifted_coefficient],
      "FROMMSG_T3_M3_SHIFTED_FIXED_POINT_COORDINATE");

  __CPROVER_assert(
      (decoded_bit == 1u) ==
      (
        encoded1.coeffs[selected_coefficient] ==
        MLKEM_Q_HALF - 1
      ),
      "FROMMSG_T3_M4_WRONG_CODEBOOK_AMPLITUDE");

  __CPROVER_assert(
      encoded3.coeffs[coefficient_index] ==
      encoded1.coeffs[coefficient_index],
      "FROMMSG_T3_M5_CORRUPTED_MESSAGE_FALSE_FIXED_POINT");
}
