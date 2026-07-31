/*
 * FROMMSG-T2 relational reachability companion.
 *
 * Each assertion is deliberately false on a specifically constrained,
 * satisfiable relational execution.
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
  unsigned mode;

  unsigned byte_index;
  unsigned bit_index;

  uint8_t mask;
  uint8_t original_bit;

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(j < MLKEM_N);
  __CPROVER_assume(mode < 5u);

  m2 = m1;

  byte_index = k >> 3;
  bit_index = k & 7u;
  mask = (uint8_t)(1u << bit_index);

  original_bit =
      (uint8_t)((m1.bytes[byte_index] >> bit_index) & 1u);

  m2.bytes[byte_index] =
      (uint8_t)(m2.bytes[byte_index] ^ mask);

  mlk_poly_frommsg(&r1, m1.bytes);
  mlk_poly_frommsg(&r2, m2.bytes);

  if (mode == 0u)
  {
    __CPROVER_assert(
        0,
        "FROMMSG_T2_R1_AFTER_TWO_PRODUCTION_CALLS_REACHABLE");
  }

  if (mode == 1u)
  {
    __CPROVER_assume(original_bit == 0u);

    __CPROVER_assert(
        0,
        "FROMMSG_T2_R2_ORIGINAL_ZERO_BIT_REACHABLE");
  }

  if (mode == 2u)
  {
    __CPROVER_assume(original_bit == 1u);

    __CPROVER_assert(
        0,
        "FROMMSG_T2_R3_ORIGINAL_ONE_BIT_REACHABLE");
  }

  if (mode == 3u)
  {
    __CPROVER_assume(j == k);

    __CPROVER_assert(
        0,
        "FROMMSG_T2_R4_TARGET_COORDINATE_REACHABLE");
  }

  if (mode == 4u)
  {
    __CPROVER_assume(j != k);

    __CPROVER_assert(
        0,
        "FROMMSG_T2_R5_OFF_TARGET_COORDINATE_REACHABLE");
  }
}
