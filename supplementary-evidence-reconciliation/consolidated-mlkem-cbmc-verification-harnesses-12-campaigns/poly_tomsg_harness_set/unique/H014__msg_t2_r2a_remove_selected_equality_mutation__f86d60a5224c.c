/*
 * MSG-T2-R2A expected-failure mutation.
 *
 * Correct theorem:
 *
 *   A[k] == B[k]
 *     implies
 *   bit_k(tomsg(A)) == bit_k(tomsg(B)).
 *
 * Deliberately corrupted theorem:
 *
 *   A[k] != B[k]
 *     but still assert
 *   bit_k(tomsg(A)) == bit_k(tomsg(B)).
 *
 * Every coefficient other than k is held equal. Therefore a counterexample
 * is isolated to the selected coefficient and cannot be attributed to an
 * unrelated polynomial coefficient.
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

  /*
   * Deliberate antecedent mutation: selected coefficients are different
   * rather than equal.
   */
  __CPROVER_assume(a.coeffs[k] != b.coeffs[k]);

  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  bit_a =
      (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

  bit_b =
      (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

  __CPROVER_assert(
      bit_a == bit_b,
      "MSG_T2_R2A_MUTATION_REMOVE_EQUALITY: selected equality antecedent is necessary");

  return 0;
}
