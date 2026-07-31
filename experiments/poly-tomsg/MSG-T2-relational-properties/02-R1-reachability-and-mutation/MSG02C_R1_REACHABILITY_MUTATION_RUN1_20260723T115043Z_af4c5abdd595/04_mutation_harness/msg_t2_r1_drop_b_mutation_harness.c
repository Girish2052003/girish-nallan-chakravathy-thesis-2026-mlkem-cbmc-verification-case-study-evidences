/*
 * MSG-T2-R1 expected-failure mutation.
 *
 * Correct relational law:
 *
 *   bit_k(tomsg(A) XOR tomsg(B))
 *     =
 *   Compress1(A[k]) XOR Compress1(B[k])
 *
 * Deliberately corrupted law:
 *
 *   bit_k(tomsg(A) XOR tomsg(B))
 *     =
 *   Compress1(A[k])
 *
 * This mutation removes B[k]'s functional contribution. CBMC must find a
 * canonical counterexample.
 */

#include <stdint.h>
#include "compress.h"

uint8_t msg_t2_r1_mutation_oracle(int16_t u)
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

  uint8_t actual_a;
  uint8_t actual_b;
  uint8_t actual_xor;
  uint8_t mutated_expected;

  /*
   * Both polynomials range over the complete canonical domain.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(a.coeffs[i] >= 0);
    __CPROVER_assume(a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[i] >= 0);
    __CPROVER_assume(b.coeffs[i] < MLKEM_Q);
  }

  /*
   * Two executions of the actual frozen production implementation.
   */
  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  /*
   * Select an arbitrary valid coefficient position.
   */
  __CPROVER_assume(k < MLKEM_N);

  actual_a =
      (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

  actual_b =
      (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

  actual_xor =
      (uint8_t)(actual_a ^ actual_b);

  /*
   * Deliberate defect: omit the decision contributed by B[k].
   */
  mutated_expected =
      msg_t2_r1_mutation_oracle(a.coeffs[k]);

  __CPROVER_assert(
      actual_xor == mutated_expected,
      "MSG_T2_R1_MUTATION_DROP_B: corrupted relation must be rejected");

  return 0;
}
