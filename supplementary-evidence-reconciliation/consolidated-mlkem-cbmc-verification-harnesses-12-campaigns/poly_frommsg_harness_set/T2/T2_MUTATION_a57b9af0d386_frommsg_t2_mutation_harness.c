/*
 * FROMMSG-T2 relational semantic mutations.
 *
 * Every assertion is deliberately incorrect and must be rejected.
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
  mlk_poly r3;

  frommsg_message_box m1;
  frommsg_message_box m2;
  frommsg_message_box m3;

  unsigned k;
  unsigned j;

  unsigned byte_index;
  unsigned bit_index;

  unsigned second_k;
  unsigned second_byte_index;
  unsigned second_bit_index;

  unsigned shifted_k;
  unsigned msb_first_k;

  uint8_t mask;
  uint8_t second_mask;

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(j < MLKEM_N);

  m2 = m1;
  m3 = m1;

  byte_index = k >> 3;
  bit_index = k & 7u;
  mask = (uint8_t)(1u << bit_index);

  second_k = (k + 1u) % MLKEM_N;
  second_byte_index = second_k >> 3;
  second_bit_index = second_k & 7u;
  second_mask = (uint8_t)(1u << second_bit_index);

  /*
   * m2 differs from m1 in exactly bit k.
   */
  m2.bytes[byte_index] =
      (uint8_t)(m2.bytes[byte_index] ^ mask);

  /*
   * m3 differs from m1 in exactly two distinct bits:
   * k and (k + 1) mod MLKEM_N.
   */
  m3.bytes[byte_index] =
      (uint8_t)(m3.bytes[byte_index] ^ mask);

  m3.bytes[second_byte_index] =
      (uint8_t)(m3.bytes[second_byte_index] ^ second_mask);

  mlk_poly_frommsg(&r1, m1.bytes);
  mlk_poly_frommsg(&r2, m2.bytes);
  mlk_poly_frommsg(&r3, m3.bytes);

  shifted_k = (k + 1u) % MLKEM_N;

  msb_first_k =
      (k & ~7u) |
      (7u - (k & 7u));

  __CPROVER_assert(
      (r1.coeffs[j] != r2.coeffs[j]) ==
      (j == shifted_k),
      "FROMMSG_T2_M1_WRONG_SHIFTED_COORDINATE");

  __CPROVER_assert(
      (r1.coeffs[j] != r3.coeffs[j]) ==
      (j == k),
      "FROMMSG_T2_M2_TWO_BIT_CHANGE_AS_SINGLE_BIT_LOCALITY");

  __CPROVER_assert(
      (r1.coeffs[j] != r2.coeffs[j]) ==
      (j == msb_first_k),
      "FROMMSG_T2_M3_WRONG_MSB_FIRST_COORDINATE");

  __CPROVER_assert(
      r1.coeffs[j] == r2.coeffs[j],
      "FROMMSG_T2_M4_FALSE_NO_OUTPUT_CHANGE");
}
