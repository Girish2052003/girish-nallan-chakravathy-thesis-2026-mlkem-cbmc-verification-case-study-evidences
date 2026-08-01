/*
 * MSG-T2-R3B expected-failure mutation.
 *
 * Correct determinism theorem:
 *
 *   equal complete polynomial values
 *     imply
 *   equal complete message outputs.
 *
 * Deliberately corrupted theorem:
 *
 *   two polynomial values differ at exactly one coefficient k,
 *   but their complete message outputs are still asserted equal.
 *
 * All coefficients outside k are held equal. The selected coefficients are
 * fixed to canonical values that produce opposite message-bit decisions:
 *
 *   RUN_A[k] = 0
 *   RUN_B[k] = 1665
 *
 * CBMC must reject complete output equality.
 *
 * This is functional mutation evidence. It is not a timing, scheduling,
 * microarchitectural, leakage, or constant-time claim.
 */

#include <stdint.h>
#include "compress.h"

int main(void)
{
  mlk_poly run_a;
  mlk_poly run_b;

  uint8_t msg_a[MLKEM_INDCPA_MSGBYTES];
  uint8_t msg_b[MLKEM_INDCPA_MSGBYTES];

  unsigned i;
  unsigned k;
  unsigned byte_index;

  __CPROVER_assume(k < MLKEM_N);

  /*
   * Both inputs are canonical. Every coefficient pair outside k is equal.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(run_a.coeffs[i] >= 0);
    __CPROVER_assume(run_a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(run_b.coeffs[i] >= 0);
    __CPROVER_assume(run_b.coeffs[i] < MLKEM_Q);

    if (i != k)
    {
      __CPROVER_assume(
          run_a.coeffs[i] == run_b.coeffs[i]);
    }
  }

  /*
   * Deliberately violate the equal-input antecedent at exactly k.
   */
  __CPROVER_assume(run_a.coeffs[k] == 0);
  __CPROVER_assume(run_b.coeffs[k] == 1665);

  /*
   * Two executions of the real frozen production implementation.
   */
  mlk_poly_tomsg(msg_a, &run_a);
  mlk_poly_tomsg(msg_b, &run_b);

  /*
   * Corrupted claim: unequal inputs still produce equal complete messages.
   */
  for (byte_index = 0u;
       byte_index < MLKEM_INDCPA_MSGBYTES;
       byte_index++)
  {
    __CPROVER_assert(
        msg_a[byte_index] == msg_b[byte_index],
        "MSG_T2_R3B_MUTATION_UNEQUAL_INPUT: complete input equality is necessary for determinism");
  }

  return 0;
}
