/*
 * MSG-T2-R3A reachability companion.
 *
 * The selected coefficients are forced numerically different while their
 * independent Compress1 decisions are equal. All unrelated coefficient pairs
 * remain unrestricted.
 */

#include <stdint.h>
#include "compress.h"

uint8_t msg_t2_r3a_cov_oracle(int16_t u)
{
  return (uint8_t)((u >= 833) && (u <= 2496));
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;

  uint8_t msg_a[MLKEM_INDCPA_MSGBYTES];
  uint8_t msg_b[MLKEM_INDCPA_MSGBYTES];

  unsigned i;
  unsigned k;
  unsigned m;

  uint8_t decision_a;
  uint8_t decision_b;
  uint8_t bit_a;
  uint8_t bit_b;

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(m < MLKEM_N);
  __CPROVER_assume(m != k);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(a.coeffs[i] >= 0);
    __CPROVER_assume(a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[i] >= 0);
    __CPROVER_assume(b.coeffs[i] < MLKEM_Q);
  }

  decision_a =
      msg_t2_r3a_cov_oracle(a.coeffs[k]);

  decision_b =
      msg_t2_r3a_cov_oracle(b.coeffs[k]);

  __CPROVER_assume(a.coeffs[k] != b.coeffs[k]);
  __CPROVER_assume(decision_a == decision_b);

  /* Goal 1: distinct same-decision selected values are satisfiable. */
  __CPROVER_cover(1);

  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  /* Goal 2: both real production executions return. */
  __CPROVER_cover(1);

  bit_a =
      (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

  bit_b =
      (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

  /* Goals 3–4: boundary selected positions are reachable. */
  __CPROVER_cover(k == 0u);
  __CPROVER_cover(k == MLKEM_N - 1u);

  /* Goals 5–6: both same-decision regions are reachable. */
  __CPROVER_cover(
      decision_a == 0u &&
      decision_b == 0u);

  __CPROVER_cover(
      decision_a == 1u &&
      decision_b == 1u);

  /*
   * Goal 7: an unrelated coefficient pair may differ simultaneously.
   */
  __CPROVER_cover(a.coeffs[m] != b.coeffs[m]);

  /* Goals 8–9: both equal production output-bit values are reachable. */
  __CPROVER_cover(bit_a == 0u && bit_b == 0u);
  __CPROVER_cover(bit_a == 1u && bit_b == 1u);

  return 0;
}
