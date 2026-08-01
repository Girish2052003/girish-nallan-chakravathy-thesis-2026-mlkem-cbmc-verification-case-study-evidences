/*
 * MSG-T2-R2A — symbolic coefficient locality.
 *
 * For arbitrary canonical polynomials A and B and arbitrary k:
 *
 *   A[k] == B[k]
 *
 * implies:
 *
 *   bit_k(tomsg(A)) == bit_k(tomsg(B)).
 *
 * All coefficients other than k remain mutually unrestricted. Therefore the
 * output bit at position k is proved to depend only on coefficient k, not on
 * any other polynomial coefficient.
 *
 * This is functional non-interference/locality. It is not a timing,
 * microarchitectural, leakage, or constant-time claim.
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

  __CPROVER_assert(
      MLKEM_N == 256,
      "MSG_T2_R2A_MODEL: polynomial degree must be 256");

  __CPROVER_assert(
      MLKEM_INDCPA_MSGBYTES == 32,
      "MSG_T2_R2A_MODEL: message size must be 32 bytes");

  /*
   * Both input polynomials range independently over the complete canonical
   * domain.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(a.coeffs[i] >= 0);
    __CPROVER_assume(a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[i] >= 0);
    __CPROVER_assume(b.coeffs[i] < MLKEM_Q);
  }

  /*
   * Select an arbitrary coefficient position and equate only that
   * coefficient. All other A/B coefficient pairs remain unrestricted.
   */
  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(a.coeffs[k] == b.coeffs[k]);

  /*
   * Two executions of the real frozen production implementation.
   */
  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  bit_a =
      (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

  bit_b =
      (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

  __CPROVER_assert(
      bit_a == bit_b,
      "MSG_T2_R2A_LOCALITY: equal coefficient k must produce equal output bit k");

  return 0;
}
