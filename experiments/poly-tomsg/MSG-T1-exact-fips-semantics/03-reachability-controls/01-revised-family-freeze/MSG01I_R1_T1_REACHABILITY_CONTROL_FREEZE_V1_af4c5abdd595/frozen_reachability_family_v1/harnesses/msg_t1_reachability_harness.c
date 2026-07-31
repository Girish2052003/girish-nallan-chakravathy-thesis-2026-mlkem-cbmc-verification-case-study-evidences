/*
 * MSG-T1 reachability and non-vacuity control harness.
 *
 * This is separate from the frozen positive theorem harness.
 */

#include <stdint.h>
#include "compress.h"

uint8_t msg_t1_reach_oracle(int16_t u)
{
  return (uint8_t)((u >= 833) && (u <= 2496));
}

int main(void)
{
  mlk_poly a;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  unsigned k;
  unsigned selected;
  int16_t selected_coeff;
  uint8_t selected_bit;

  __CPROVER_assert(
      MLKEM_N == 256,
      "MSG_T1_REACH_MODEL: polynomial degree must be 256");

  __CPROVER_assert(
      MLKEM_INDCPA_MSGBYTES == 32,
      "MSG_T1_REACH_MODEL: message size must be 32 bytes");

  for (k = 0u; k < MLKEM_N; k++)
  {
    __CPROVER_assume(a.coeffs[k] >= 0);
    __CPROVER_assume(a.coeffs[k] < MLKEM_Q);
  }

  mlk_poly_tomsg(msg, &a);

  for (k = 0u; k < MLKEM_N; k++)
  {
    uint8_t actual_bit;
    uint8_t expected_bit;

    actual_bit =
        (uint8_t)((msg[k >> 3] >> (k & 7u)) & 1u);

    expected_bit =
        msg_t1_reach_oracle(a.coeffs[k]);

    __CPROVER_assert(
        actual_bit == expected_bit,
        "MSG_T1_REACH_ANCHOR_EXACT: every output bit must match independent oracle");
  }

  /*
   * An uninitialised automatic scalar is symbolic in CBMC.
   * Restrict it to one valid coefficient index.
   */
  __CPROVER_assume(selected < MLKEM_N);

  selected_coeff = a.coeffs[selected];

  selected_bit =
      (uint8_t)((msg[selected >> 3] >> (selected & 7u)) & 1u);

  /* C1: minimum canonical input and lower zero class. */
  __CPROVER_cover(
      selected_coeff == 0 &&
      selected_bit == 0);

  /* C2: final coefficient below the lower one-threshold. */
  __CPROVER_cover(
      selected_coeff == 832 &&
      selected_bit == 0);

  /* C3: first coefficient in the one-region. */
  __CPROVER_cover(
      selected_coeff == 833 &&
      selected_bit == 1);

  /* C4: final coefficient in the one-region. */
  __CPROVER_cover(
      selected_coeff == 2496 &&
      selected_bit == 1);

  /* C5: first coefficient in the upper zero-region. */
  __CPROVER_cover(
      selected_coeff == 2497 &&
      selected_bit == 0);

  /* C6: maximum canonical coefficient. */
  __CPROVER_cover(
      selected_coeff == 3328 &&
      selected_bit == 0);

  /* C7: interior witness for the lower zero-region. */
  __CPROVER_cover(
      selected_coeff > 0 &&
      selected_coeff < 832 &&
      selected_bit == 0);

  /* C8: interior witness for the one-region. */
  __CPROVER_cover(
      selected_coeff > 833 &&
      selected_coeff < 2496 &&
      selected_bit == 1);

  /* C9: interior witness for the upper zero-region. */
  __CPROVER_cover(
      selected_coeff > 2497 &&
      selected_coeff < 3328 &&
      selected_bit == 0);

  /* C10-C12: first, middle and final flat output positions. */
  __CPROVER_cover(selected == 0u);
  __CPROVER_cover(selected == 127u);
  __CPROVER_cover(selected == 255u);

  return 0;
}
