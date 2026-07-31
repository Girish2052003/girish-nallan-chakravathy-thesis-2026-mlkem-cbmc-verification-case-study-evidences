/*
 * FROMMSG-T1 — Exact binary embedding and coordinate semantics.
 *
 * Clean-room candidate harness.
 *
 * This harness does not reproduce the native poly_frommsg harness.
 * It supplies concrete, separate input/output objects and asserts an
 * exact semantic relationship absent from the native broad contract.
 */

#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  unsigned k;

  /*
   * k is otherwise unconstrained. This single symbolic coordinate
   * represents every coefficient index from 0 through 255.
   */
  __CPROVER_assume(k < MLKEM_N);

  /*
   * Exercise the real production implementation.
   */
  mlk_poly_frommsg(&r, msg);

  {
    const unsigned byte_index = k >> 3;
    const unsigned bit_index = k & 7u;

    const uint8_t selected_bit =
        (uint8_t)((msg[byte_index] >> bit_index) & 1u);

    const int16_t expected =
        (selected_bit != 0u) ? MLKEM_Q_HALF : 0;

    __CPROVER_assert(
        r.coeffs[k] == expected,
        "FROMMSG_T1_P1_EXACT_COORDINATE_EQUATION");

    __CPROVER_assert(
        r.coeffs[k] == 0 ||
        r.coeffs[k] == MLKEM_Q_HALF,
        "FROMMSG_T1_P2_EXACT_BINARY_OUTPUT_ALPHABET");

    __CPROVER_assert(
        (r.coeffs[k] == MLKEM_Q_HALF) ==
        (selected_bit == 1u),
        "FROMMSG_T1_P3_ONE_BIT_SUPPORT_EQUIVALENCE");

    __CPROVER_assert(
        (r.coeffs[k] == 0) ==
        (selected_bit == 0u),
        "FROMMSG_T1_P4_ZERO_BIT_SUPPORT_EQUIVALENCE");
  }
}
