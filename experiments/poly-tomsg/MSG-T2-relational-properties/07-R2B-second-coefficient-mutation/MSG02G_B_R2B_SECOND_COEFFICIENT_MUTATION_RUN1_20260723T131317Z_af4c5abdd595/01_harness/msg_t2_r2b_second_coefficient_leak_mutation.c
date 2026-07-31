/*
 * MSG-T2-R2B expected-failure mutation.
 *
 * Correct theorem antecedent:
 *
 *   A[i] == B[i] for every i != k.
 *
 * Coefficient k alone may differ.
 *
 * Deliberately corrupted antecedent:
 *
 *   coefficient k differs, and one additional coefficient m differs.
 *
 * The second differing coefficient m is selected from a different output
 * byte. The corrupted relation nevertheless claims that output bit m remains
 * equal. CBMC must reject that claim.
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
  unsigned m;

  uint8_t bit_a_m;
  uint8_t bit_b_m;

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(m < MLKEM_N);
  __CPROVER_assume(m != k);

  /*
   * Ensure m belongs to a different output byte from k. The mutation
   * therefore directly attacks other-byte and all-other-bit preservation.
   */
  __CPROVER_assume((m >> 3) != (k >> 3));

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(a.coeffs[i] >= 0);
    __CPROVER_assume(a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[i] >= 0);
    __CPROVER_assume(b.coeffs[i] < MLKEM_Q);

    if (i != k && i != m)
    {
      __CPROVER_assume(a.coeffs[i] == b.coeffs[i]);
    }
  }

  /*
   * The selected coefficient k is the difference permitted by R2B.
   */
  __CPROVER_assume(a.coeffs[k] != b.coeffs[k]);

  /*
   * Deliberate second difference:
   *
   * 0 and 1665 are canonical coefficients that drive opposite message-bit
   * decisions in the production implementation.
   */
  __CPROVER_assume(a.coeffs[m] == 0);
  __CPROVER_assume(b.coeffs[m] == 1665);

  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  bit_a_m =
      (uint8_t)((msg_a[m >> 3] >> (m & 7u)) & 1u);

  bit_b_m =
      (uint8_t)((msg_b[m >> 3] >> (m & 7u)) & 1u);

  __CPROVER_assert(
      bit_a_m == bit_b_m,
      "MSG_T2_R2B_MUTATION_SECOND_COEFFICIENT: every non-k coefficient equality is necessary");

  return 0;
}
