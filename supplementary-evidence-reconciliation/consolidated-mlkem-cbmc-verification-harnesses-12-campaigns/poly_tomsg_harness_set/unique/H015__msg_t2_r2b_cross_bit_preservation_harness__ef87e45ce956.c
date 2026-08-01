/*
 * MSG-T2-R2B — symbolic cross-bit preservation.
 *
 * Let A and B be arbitrary canonical polynomials and let k be an arbitrary
 * coefficient index.
 *
 * Assume:
 *
 *   A[i] == B[i] for every i != k.
 *
 * Coefficient k remains unrestricted and may either remain equal or change.
 *
 * The theorem establishes that changing at most coefficient k cannot change:
 *
 *   1. any output byte outside byte floor(k / 8);
 *   2. any of the other seven bits inside byte floor(k / 8);
 *   3. equivalently, any output bit j where j != k.
 *
 * This is functional cross-bit non-interference. It is not a timing,
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
  unsigned j;
  unsigned k;
  unsigned byte_index;

  uint8_t selected_bit_mask;
  uint8_t preserved_bit_mask;

  __CPROVER_assert(
      MLKEM_N == 256,
      "MSG_T2_R2B_MODEL: polynomial degree must be 256");

  __CPROVER_assert(
      MLKEM_INDCPA_MSGBYTES == 32,
      "MSG_T2_R2B_MODEL: message size must be 32 bytes");

  /*
   * Select an arbitrary valid coefficient before imposing relational input
   * constraints.
   */
  __CPROVER_assume(k < MLKEM_N);

  /*
   * Both polynomials are canonical. Every coefficient pair except the
   * selected pair k is constrained equal.
   */
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
   * Two executions of the actual frozen production implementation.
   */
  mlk_poly_tomsg(msg_a, &a);
  mlk_poly_tomsg(msg_b, &b);

  selected_bit_mask =
      (uint8_t)(1u << (k & 7u));

  preserved_bit_mask =
      (uint8_t)(255u ^ (unsigned)selected_bit_mask);

  /*
   * The other seven bits in the selected output byte must be preserved.
   */
  __CPROVER_assert(
      (uint8_t)(msg_a[k >> 3] & preserved_bit_mask) ==
          (uint8_t)(msg_b[k >> 3] & preserved_bit_mask),
      "MSG_T2_R2B_SAME_BYTE: all seven non-selected bits in k's byte must be preserved");

  /*
   * Every byte outside k's output byte must remain exactly equal.
   */
  for (byte_index = 0u;
       byte_index < MLKEM_INDCPA_MSGBYTES;
       byte_index++)
  {
    if (byte_index != (k >> 3))
    {
      __CPROVER_assert(
          msg_a[byte_index] == msg_b[byte_index],
          "MSG_T2_R2B_OTHER_BYTES: every byte outside k's byte must be preserved");
    }
  }

  /*
   * Flat bit-level statement of the complete cross-bit theorem.
   */
  for (j = 0u; j < MLKEM_N; j++)
  {
    if (j != k)
    {
      uint8_t bit_a;
      uint8_t bit_b;

      bit_a =
          (uint8_t)((msg_a[j >> 3] >> (j & 7u)) & 1u);

      bit_b =
          (uint8_t)((msg_b[j >> 3] >> (j & 7u)) & 1u);

      __CPROVER_assert(
          bit_a == bit_b,
          "MSG_T2_R2B_ALL_OTHER_BITS: every output bit j different from k must be preserved");
    }
  }

  return 0;
}
