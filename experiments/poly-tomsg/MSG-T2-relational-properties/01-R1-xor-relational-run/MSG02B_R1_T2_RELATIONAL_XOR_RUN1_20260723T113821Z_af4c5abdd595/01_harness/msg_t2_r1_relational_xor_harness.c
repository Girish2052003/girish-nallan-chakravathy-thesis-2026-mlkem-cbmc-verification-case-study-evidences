/*
 * MSG-T2-R1 — exact two-execution relational XOR law.
 *
 * For arbitrary canonical polynomials A and B:
 *
 *   bit_k(tomsg(A) XOR tomsg(B))
 *     =
 *   Compress1(A[k]) XOR Compress1(B[k])
 *
 * for every k in 0..255.
 *
 * This is a functional self-composition property. It does not claim timing,
 * leakage, constant-time, or compiler-level side-channel non-interference.
 */

#include <stdint.h>
#include "compress.h"

/*
 * Independent canonical Compress1 decision oracle:
 *
 *   0..832     -> 0
 *   833..2496  -> 1
 *   2497..3328 -> 0
 */
uint8_t msg_t2_threshold_oracle(int16_t u)
{
  return (uint8_t)((u >= 833) && (u <= 2496));
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;
  uint8_t msg_a[MLKEM_INDCPA_MSGBYTES];
  uint8_t msg_b[MLKEM_INDCPA_MSGBYTES];
  unsigned k;

  __CPROVER_assert(
      MLKEM_N == 256,
      "MSG_T2_MODEL: polynomial degree must be 256");

  __CPROVER_assert(
      MLKEM_INDCPA_MSGBYTES == 32,
      "MSG_T2_MODEL: message size must be 32 bytes");

  for (k = 0u; k < MLKEM_N; k++)
  {
    __CPROVER_assume(a.coeffs[k] >= 0);
    __CPROVER_assume(a.coeffs[k] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[k] >= 0);
    __CPROVER_assume(b.coeffs[k] < MLKEM_Q);
  }

  /*
   * Two executions of the real frozen production function.
   */
  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  for (k = 0u; k < MLKEM_N; k++)
  {
    uint8_t actual_a;
    uint8_t actual_b;
    uint8_t expected_a;
    uint8_t expected_b;
    uint8_t actual_xor;
    uint8_t expected_xor;

    actual_a =
        (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

    actual_b =
        (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

    expected_a =
        msg_t2_threshold_oracle(a.coeffs[k]);

    expected_b =
        msg_t2_threshold_oracle(b.coeffs[k]);

    actual_xor =
        (uint8_t)(actual_a ^ actual_b);

    expected_xor =
        (uint8_t)(expected_a ^ expected_b);

    __CPROVER_assert(
        actual_xor == expected_xor,
        "MSG_T2_R1: output-bit XOR must equal independent Compress1-decision XOR");
  }

  return 0;
}
