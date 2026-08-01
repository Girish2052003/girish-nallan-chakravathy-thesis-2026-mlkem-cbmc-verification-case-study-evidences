/*
 * MSG-T2-R3A — same-decision invariance.
 *
 * For arbitrary canonical polynomials A and B and arbitrary k:
 *
 *   Compress1(A[k]) == Compress1(B[k])
 *
 * implies:
 *
 *   bit_k(tomsg(A)) == bit_k(tomsg(B)).
 *
 * A[k] and B[k] need not be numerically equal. Every coefficient outside k
 * also remains unrestricted between A and B.
 *
 * The decision predicate is expressed independently as the exact canonical
 * interval established for Compress1:
 *
 *   decision(u) = 1 iff 833 <= u <= 2496.
 *
 * This is a functional invariance theorem. It is not a timing,
 * microarchitectural, leakage, or constant-time claim.
 */

#include <stdint.h>
#include "compress.h"

uint8_t msg_t2_r3a_decision_oracle(int16_t u)
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

  uint8_t decision_a;
  uint8_t decision_b;
  uint8_t bit_a;
  uint8_t bit_b;

  __CPROVER_assert(
      MLKEM_N == 256,
      "MSG_T2_R3A_MODEL: polynomial degree must be 256");

  __CPROVER_assert(
      MLKEM_INDCPA_MSGBYTES == 32,
      "MSG_T2_R3A_MODEL: message size must be 32 bytes");

  __CPROVER_assume(k < MLKEM_N);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(a.coeffs[i] >= 0);
    __CPROVER_assume(a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[i] >= 0);
    __CPROVER_assume(b.coeffs[i] < MLKEM_Q);
  }

  decision_a =
      msg_t2_r3a_decision_oracle(a.coeffs[k]);

  decision_b =
      msg_t2_r3a_decision_oracle(b.coeffs[k]);

  /*
   * Only the independent Compress1 decisions are equated. The selected
   * coefficient values themselves remain unrestricted.
   */
  __CPROVER_assume(decision_a == decision_b);

  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  bit_a =
      (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

  bit_b =
      (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

  __CPROVER_assert(
      bit_a == bit_b,
      "MSG_T2_R3A_SAME_DECISION: equal Compress1 decisions must produce equal output bit k");

  return 0;
}
