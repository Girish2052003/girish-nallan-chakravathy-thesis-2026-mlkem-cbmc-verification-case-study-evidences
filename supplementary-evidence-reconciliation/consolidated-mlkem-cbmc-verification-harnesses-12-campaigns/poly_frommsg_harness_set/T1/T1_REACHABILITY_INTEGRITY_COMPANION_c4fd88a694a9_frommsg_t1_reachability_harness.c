/*
 * FROMMSG-T1 reachability companion.
 *
 * Each assertion is deliberately false on a specifically constrained,
 * satisfiable execution. Each property is queried separately.
 */

#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  unsigned k;
  unsigned mode;

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(mode < 4u);

  mlk_poly_frommsg(&r, msg);

  {
    const unsigned byte_index = k >> 3;
    const unsigned bit_index = k & 7u;
    const uint8_t selected_bit =
        (uint8_t)((msg[byte_index] >> bit_index) & 1u);

    if (mode == 0u)
    {
      __CPROVER_assert(
          0,
          "FROMMSG_T1_R1_AFTER_PRODUCTION_CALL_REACHABLE");
    }

    if (mode == 1u)
    {
      __CPROVER_assume(selected_bit == 0u);

      __CPROVER_assert(
          0,
          "FROMMSG_T1_R2_ZERO_BIT_CASE_REACHABLE");
    }

    if (mode == 2u)
    {
      __CPROVER_assume(selected_bit == 1u);

      __CPROVER_assert(
          0,
          "FROMMSG_T1_R3_ONE_BIT_CASE_REACHABLE");
    }

    if (mode == 3u)
    {
      __CPROVER_assume(k == MLKEM_N - 1u);

      __CPROVER_assert(
          0,
          "FROMMSG_T1_R4_FINAL_COORDINATE_REACHABLE");
    }
  }
}
