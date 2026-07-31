/*
 * MSG-T2-R2B reachability companion.
 *
 * Every coefficient other than k is equal. Coefficient k is forced to differ.
 * The companion demonstrates that a real selected-coefficient change may
 * either preserve or change its own output decision.
 */

#include <stdint.h>
#include "compress.h"

int main(void)
{
  mlk_poly a;
  mlk_poly b;

  uint8_t msg_a[MLKEM_INDCPA_MSGBYTES];
  uint8_t msg_b[MLKEM_INDCPA_MSGBYTES];

  unsigned i;
  unsigned k;

  uint8_t bit_a;
  uint8_t bit_b;

  __CPROVER_assume(k < MLKEM_N);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(a.coeffs[i] >= 0);
    __CPROVER_assume(a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[i] >= 0);
    __CPROVER_assume(b.coeffs[i] < MLKEM_Q);

    if (i != k)
    {
      __CPROVER_assume(a.coeffs[i] == b.coeffs[i]);
    }
  }

  __CPROVER_assume(a.coeffs[k] != b.coeffs[k]);

  /* Goal 1: a genuine selected-coefficient change is satisfiable. */
  __CPROVER_cover(1);

  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  /* Goal 2: both production executions return. */
  __CPROVER_cover(1);

  bit_a =
      (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

  bit_b =
      (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

  /* Goals 3–4: boundary coefficient positions are reachable. */
  __CPROVER_cover(k == 0u);
  __CPROVER_cover(k == MLKEM_N - 1u);

  /*
   * Goals 5–6:
   * Distinct canonical coefficients may remain in the same Compress1 region
   * or may cross a Compress1 decision boundary.
   */
  __CPROVER_cover(bit_a == bit_b);
  __CPROVER_cover(bit_a != bit_b);

  return 0;
}
