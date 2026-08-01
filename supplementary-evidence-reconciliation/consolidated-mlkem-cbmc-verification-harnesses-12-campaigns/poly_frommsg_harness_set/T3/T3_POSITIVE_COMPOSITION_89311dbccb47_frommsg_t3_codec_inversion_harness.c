/*
 * FROMMSG-T3 — Codec inversion and codebook fixed point.
 *
 * The harness composes the real production implementations:
 *
 *   input -> mlk_poly_frommsg -> encoded1
 *   encoded1 -> mlk_poly_tomsg -> decoded
 *   decoded -> mlk_poly_frommsg -> encoded2
 *
 * No implementation logic is reproduced in the harness.
 */

#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly encoded1;
  mlk_poly encoded2;

  uint8_t input[MLKEM_INDCPA_MSGBYTES];
  uint8_t decoded[MLKEM_INDCPA_MSGBYTES];

  unsigned byte_index;
  unsigned bit_index;
  unsigned coefficient_index;
  unsigned selected_coefficient;

  uint8_t input_bit;
  uint8_t decoded_bit;

  __CPROVER_assume(
      byte_index < MLKEM_INDCPA_MSGBYTES);

  __CPROVER_assume(
      bit_index < 8u);

  __CPROVER_assume(
      coefficient_index < MLKEM_N);

  selected_coefficient =
      8u * byte_index + bit_index;

  mlk_poly_frommsg(&encoded1, input);
  mlk_poly_tomsg(decoded, &encoded1);
  mlk_poly_frommsg(&encoded2, decoded);

  input_bit =
      (uint8_t)(
          (input[byte_index] >> bit_index) & 1u);

  decoded_bit =
      (uint8_t)(
          (decoded[byte_index] >> bit_index) & 1u);

  /*
   * Central round-trip theorem. Since byte_index is arbitrary and
   * constrained to all 32 message positions, this proves equality
   * for every message byte.
   */
  __CPROVER_assert(
      decoded[byte_index] == input[byte_index],
      "FROMMSG_T3_P1_EXACT_BYTE_ROUND_TRIP");

  /*
   * Diagnostic bit-level projection of the byte theorem.
   */
  __CPROVER_assert(
      decoded_bit == input_bit,
      "FROMMSG_T3_P2_EXACT_BIT_ROUND_TRIP");

  /*
   * Codebook fixed point. Re-encoding the decoded message must
   * reproduce every coefficient of the first encoding.
   */
  __CPROVER_assert(
      encoded2.coeffs[coefficient_index] ==
      encoded1.coeffs[coefficient_index],
      "FROMMSG_T3_P3_CODEBOOK_FIXED_POINT");

  /*
   * Exact decoding relation on the frommsg codebook.
   */
  __CPROVER_assert(
      (decoded_bit == 1u) ==
      (
        encoded1.coeffs[selected_coefficient] ==
        MLKEM_Q_HALF
      ),
      "FROMMSG_T3_P4_EXACT_CODEBOOK_DECODING");
}
