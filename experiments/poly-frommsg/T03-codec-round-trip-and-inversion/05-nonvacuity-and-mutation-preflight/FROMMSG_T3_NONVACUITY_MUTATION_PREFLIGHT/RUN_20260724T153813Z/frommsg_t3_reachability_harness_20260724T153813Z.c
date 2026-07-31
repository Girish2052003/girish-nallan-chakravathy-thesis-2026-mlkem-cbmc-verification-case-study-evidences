/*
 * FROMMSG-T3 reachability companion.
 *
 * Each selected assertion is deliberately false on a satisfiable
 * execution of the real codec composition.
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

  frommsg_t3_message input;
  frommsg_t3_message decoded;

  unsigned byte_index;
  unsigned bit_index;
  unsigned coefficient_index;
  unsigned mode;

  uint8_t input_bit;

  __CPROVER_assume(
      byte_index < MLKEM_INDCPA_MSGBYTES);

  __CPROVER_assume(
      bit_index < 8u);

  __CPROVER_assume(
      coefficient_index < MLKEM_N);

  __CPROVER_assume(mode < 6u);

  mlk_poly_frommsg(&encoded1, input.bytes);
  mlk_poly_tomsg(decoded.bytes, &encoded1);
  mlk_poly_frommsg(&encoded2, decoded.bytes);

  input_bit =
      (uint8_t)(
          (input.bytes[byte_index] >> bit_index) & 1u);

  if (mode == 0u)
  {
    __CPROVER_assert(
        0,
        "FROMMSG_T3_R1_FULL_COMPOSITION_REACHABLE");
  }

  if (mode == 1u)
  {
    __CPROVER_assume(input_bit == 0u);

    __CPROVER_assert(
        0,
        "FROMMSG_T3_R2_INPUT_ZERO_BIT_REACHABLE");
  }

  if (mode == 2u)
  {
    __CPROVER_assume(input_bit == 1u);

    __CPROVER_assert(
        0,
        "FROMMSG_T3_R3_INPUT_ONE_BIT_REACHABLE");
  }

  if (mode == 3u)
  {
    __CPROVER_assume(
        byte_index == MLKEM_INDCPA_MSGBYTES - 1u);

    __CPROVER_assume(bit_index == 7u);

    __CPROVER_assert(
        0,
        "FROMMSG_T3_R4_FINAL_MESSAGE_BIT_REACHABLE");
  }

  if (mode == 4u)
  {
    __CPROVER_assume(coefficient_index == 0u);

    __CPROVER_assert(
        0,
        "FROMMSG_T3_R5_FIRST_COEFFICIENT_REACHABLE");
  }

  if (mode == 5u)
  {
    __CPROVER_assume(
        coefficient_index == MLKEM_N - 1u);

    __CPROVER_assert(
        0,
        "FROMMSG_T3_R6_FINAL_COEFFICIENT_REACHABLE");
  }
}
