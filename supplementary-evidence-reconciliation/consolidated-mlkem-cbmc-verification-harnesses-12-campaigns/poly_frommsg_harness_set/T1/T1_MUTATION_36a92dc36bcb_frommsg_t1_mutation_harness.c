/*
 * FROMMSG-T1 semantic mutation harness.
 *
 * All four assertions are intentionally incorrect. Each mutation is
 * queried independently and must be rejected with a counterexample.
 */

#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  unsigned k;

  __CPROVER_assume(k < MLKEM_N);

  mlk_poly_frommsg(&r, msg);

  {
    const unsigned byte_index = k >> 3;
    const unsigned bit_index = k & 7u;

    const uint8_t selected_bit =
        (uint8_t)((msg[byte_index] >> bit_index) & 1u);

    const uint8_t reversed_bit =
        (uint8_t)((msg[byte_index] >>
                   (7u - bit_index)) & 1u);

    const int16_t expected =
        (selected_bit != 0u) ? MLKEM_Q_HALF : 0;

    const int16_t wrong_amplitude =
        (selected_bit != 0u) ?
            (int16_t)(MLKEM_Q_HALF - 1) :
            0;

    const int16_t reversed_expected =
        (reversed_bit != 0u) ? MLKEM_Q_HALF : 0;

    const int16_t inverted_expected =
        (selected_bit != 0u) ? 0 : MLKEM_Q_HALF;

    const unsigned shifted_k =
        (k + 1u) % MLKEM_N;

    __CPROVER_assert(
        r.coeffs[k] == wrong_amplitude,
        "FROMMSG_T1_M1_WRONG_AMPLITUDE_1664");

    __CPROVER_assert(
        r.coeffs[k] == reversed_expected,
        "FROMMSG_T1_M2_MSB_FIRST_BIT_ORDER");

    __CPROVER_assert(
        r.coeffs[k] == inverted_expected,
        "FROMMSG_T1_M3_INVERTED_ZERO_ONE_MAPPING");

    __CPROVER_assert(
        r.coeffs[shifted_k] == expected,
        "FROMMSG_T1_M4_SHIFTED_COORDINATE_MAPPING");
  }
}
