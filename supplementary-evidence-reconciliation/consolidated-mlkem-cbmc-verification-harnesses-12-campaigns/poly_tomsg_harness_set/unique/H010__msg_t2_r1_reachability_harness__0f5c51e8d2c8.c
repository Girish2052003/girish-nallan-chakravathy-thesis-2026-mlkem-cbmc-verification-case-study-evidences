/*
 * MSG-T2-R1 reachability and non-vacuity companion.
 *
 * This companion does not replace the positive theorem proof. It establishes
 * that the relational construction reaches both production executions, both
 * ends of the comparison loop, every pair of Compress1 decisions, and both
 * possible XOR results.
 */

#include <stdint.h>
#include "compress.h"

uint8_t msg_t2_r1_cover_oracle(int16_t u)
{
  return (uint8_t)((u >= 833) && (u <= 2496));
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;
  uint8_t msg_a[MLKEM_INDCPA_MSGBYTES];
  uint8_t msg_b[MLKEM_INDCPA_MSGBYTES];

  unsigned k;

  uint8_t actual_a;
  uint8_t actual_b;
  uint8_t expected_a;
  uint8_t expected_b;
  uint8_t actual_xor;

  for (k = 0u; k < MLKEM_N; k++)
  {
    __CPROVER_assume(a.coeffs[k] >= 0);
    __CPROVER_assume(a.coeffs[k] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[k] >= 0);
    __CPROVER_assume(b.coeffs[k] < MLKEM_Q);
  }

  /* Cover 1: canonical assumptions completed. */
  __CPROVER_cover(1);

  mlk_poly_tomsg(msg_a, &a);

  /* Cover 2: first production execution returned. */
  __CPROVER_cover(1);

  mlk_poly_tomsg(msg_b, &b);

  /* Cover 3: second production execution returned. */
  __CPROVER_cover(1);

  for (k = 0u; k < MLKEM_N; k++)
  {
    actual_a =
        (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

    actual_b =
        (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

    expected_a =
        msg_t2_r1_cover_oracle(a.coeffs[k]);

    expected_b =
        msg_t2_r1_cover_oracle(b.coeffs[k]);

    actual_xor =
        (uint8_t)(actual_a ^ actual_b);

    /* Cover 4: first compared coefficient is reachable. */
    __CPROVER_cover(k == 0u);

    /* Cover 5: final compared coefficient is reachable. */
    __CPROVER_cover(k == MLKEM_N - 1u);

    /* Covers 6–9: every pair of Compress1 decisions is reachable. */
    __CPROVER_cover(expected_a == 0u && expected_b == 0u);
    __CPROVER_cover(expected_a == 0u && expected_b == 1u);
    __CPROVER_cover(expected_a == 1u && expected_b == 0u);
    __CPROVER_cover(expected_a == 1u && expected_b == 1u);

    /* Covers 10–11: both relational XOR outcomes are reachable. */
    __CPROVER_cover(actual_xor == 0u);
    __CPROVER_cover(actual_xor == 1u);
  }

  return 0;
}
