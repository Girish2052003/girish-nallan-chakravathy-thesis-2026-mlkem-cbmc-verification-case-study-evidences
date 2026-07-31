/*
 * MSG-T2-R2A reachability companion.
 *
 * The selected coefficients are equal, while one distinct symbolic
 * coefficient is forced to differ. This demonstrates that R2A is not relying
 * on complete equality of the two input polynomials.
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
  unsigned m;

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

  __CPROVER_assume(a.coeffs[k] == b.coeffs[k]);
  __CPROVER_assume(a.coeffs[m] != b.coeffs[m]);

  /* Goal 1: nontrivial R2A antecedent is satisfiable. */
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

  /* Goals 5–6: both equal selected-bit decisions are reachable. */
  __CPROVER_cover(bit_a == 0u && bit_b == 0u);
  __CPROVER_cover(bit_a == 1u && bit_b == 1u);

  return 0;
}
