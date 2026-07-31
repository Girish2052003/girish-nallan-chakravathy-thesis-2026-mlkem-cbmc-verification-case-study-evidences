/*
 * FROMMSG-T2 — Relational single-bit locality.
 *
 * Two real executions of mlk_poly_frommsg are compared.
 *
 * The second message is obtained from the first by flipping exactly
 * one symbolic input bit k. A second symbolic index j represents every
 * possible output coordinate.
 */

#include <stdint.h>

#include "compress.h"

typedef struct
{
  uint8_t bytes[MLKEM_INDCPA_MSGBYTES];
} frommsg_message_box;

void harness(void)
{
  mlk_poly r1;
  mlk_poly r2;

  frommsg_message_box m1;
  frommsg_message_box m2;

  unsigned k;
  unsigned j;
  unsigned byte_index;
  unsigned bit_index;

  uint8_t mask;
  uint8_t original_bit;

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(j < MLKEM_N);

  /*
   * Struct assignment copies every byte. Therefore m1 and m2 are
   * initially identical without introducing a harness loop.
   */
  m2 = m1;

  byte_index = k >> 3;
  bit_index = k & 7u;
  mask = (uint8_t)(1u << bit_index);

  original_bit =
      (uint8_t)((m1.bytes[byte_index] >> bit_index) & 1u);

  /*
   * Flip exactly the selected LSB-first input bit.
   */
  m2.bytes[byte_index] =
      (uint8_t)(m2.bytes[byte_index] ^ mask);

  /*
   * Exercise the real production implementation twice.
   */
  mlk_poly_frommsg(&r1, m1.bytes);
  mlk_poly_frommsg(&r2, m2.bytes);

  __CPROVER_assert(
      (
        original_bit == 0u &&
        r1.coeffs[k] == 0 &&
        r2.coeffs[k] == MLKEM_Q_HALF
      ) ||
      (
        original_bit == 1u &&
        r1.coeffs[k] == MLKEM_Q_HALF &&
        r2.coeffs[k] == 0
      ),
      "FROMMSG_T2_P1_EXACT_TARGET_TOGGLE_PAIR");

  __CPROVER_assert(
      (int32_t)r1.coeffs[k] +
      (int32_t)r2.coeffs[k] ==
      (int32_t)MLKEM_Q_HALF,
      "FROMMSG_T2_P2_TARGET_TOGGLE_SUM");

  /*
   * Central T2 locality theorem:
   *
   * The two output polynomials differ at coordinate j exactly when
   * j is the coefficient corresponding to the flipped input bit.
   */
  __CPROVER_assert(
      (r1.coeffs[j] != r2.coeffs[j]) ==
      (j == k),
      "FROMMSG_T2_P3_DIFFERENCE_IFF_FLIPPED_COORDINATE");

  __CPROVER_assert(
      (
        (r1.coeffs[k] == MLKEM_Q_HALF) ==
        (original_bit == 1u)
      ) &&
      (
        (r2.coeffs[k] == MLKEM_Q_HALF) ==
        (original_bit == 0u)
      ),
      "FROMMSG_T2_P4_BOOLEAN_COMPLEMENT_PRESERVATION");
}
