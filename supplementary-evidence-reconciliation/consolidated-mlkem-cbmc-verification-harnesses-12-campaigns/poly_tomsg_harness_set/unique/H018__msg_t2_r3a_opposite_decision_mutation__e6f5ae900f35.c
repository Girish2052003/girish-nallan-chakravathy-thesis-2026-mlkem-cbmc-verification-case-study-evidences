/*
 * MSG-T2-R3A expected-failure mutation.
 *
 * Correct theorem:
 *
 *   equal Compress1 decisions
 *     imply
 *   equal output bit k.
 *
 * Deliberately corrupted theorem:
 *
 *   opposite Compress1 decisions
 *     but still assert
 *   equal output bit k.
 *
 * Every coefficient outside k is held equal. The selected coefficients are:
 *
 *   A[k] = 0
 *   B[k] = 1665
 *
 * Both are canonical, but they belong to opposite Compress1 decision regions.
 * CBMC must reject the corrupted equality assertion.
 *
 * This is functional mutation evidence, not a timing or leakage claim.
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
   * Deliberately force opposite Compress1 decisions.
   */
  __CPROVER_assume(a.coeffs[k] == 0);
  __CPROVER_assume(b.coeffs[k] == 1665);

  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  bit_a =
      (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

  bit_b =
      (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

  __CPROVER_assert(
      bit_a == bit_b,
      "MSG_T2_R3A_MUTATION_OPPOSITE_DECISION: equal-decision antecedent is necessary");

  return 0;
}
