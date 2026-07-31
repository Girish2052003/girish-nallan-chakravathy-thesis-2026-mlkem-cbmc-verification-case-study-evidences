/*
 * MSG-T2-R3B determinism reachability companion.
 *
 * A single arbitrary canonical source is copied into two distinct polynomial
 * objects. Two independent production calls use separate destination buffers.
 *
 * The goals demonstrate that both output-bit values and complete all-zero and
 * all-one bytes are reachable at both ends of the 32-byte message.
 */

#include <stdint.h>
#include "compress.h"

int main(void)
{
  mlk_poly source;
  mlk_poly run_a;
  mlk_poly run_b;

  uint8_t msg_a[MLKEM_INDCPA_MSGBYTES];
  uint8_t msg_b[MLKEM_INDCPA_MSGBYTES];

  unsigned i;
  unsigned k;

  uint8_t bit_a;
  uint8_t bit_b;

  __CPROVER_assume(k < MLKEM_N);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(source.coeffs[i] >= 0);
    __CPROVER_assume(source.coeffs[i] < MLKEM_Q);
  }

  run_a = source;
  run_b = source;

  /* Goal 1: equal-value distinct input objects are reachable. */
  __CPROVER_cover(1);

  mlk_poly_tomsg(msg_a, &run_a);

  /* Goal 2: the first production call returns. */
  __CPROVER_cover(1);

  mlk_poly_tomsg(msg_b, &run_b);

  /* Goal 3: the second production call returns. */
  __CPROVER_cover(1);

  bit_a =
      (uint8_t)((msg_a[k >> 3] >> (k & 7u)) & 1u);

  bit_b =
      (uint8_t)((msg_b[k >> 3] >> (k & 7u)) & 1u);

  /* Goals 4–5: boundary selected positions are reachable. */
  __CPROVER_cover(k == 0u);
  __CPROVER_cover(k == MLKEM_N - 1u);

  /* Goals 6–7: both deterministic selected-bit values are reachable. */
  __CPROVER_cover(bit_a == 0u && bit_b == 0u);
  __CPROVER_cover(bit_a == 1u && bit_b == 1u);

  /* Goals 8–9: both complete byte patterns are reachable at byte zero. */
  __CPROVER_cover(msg_a[0] == 0u && msg_b[0] == 0u);
  __CPROVER_cover(msg_a[0] == 255u && msg_b[0] == 255u);

  /* Goals 10–11: both patterns are reachable at the final message byte. */
  __CPROVER_cover(
      msg_a[MLKEM_INDCPA_MSGBYTES - 1u] == 0u &&
      msg_b[MLKEM_INDCPA_MSGBYTES - 1u] == 0u);

  __CPROVER_cover(
      msg_a[MLKEM_INDCPA_MSGBYTES - 1u] == 255u &&
      msg_b[MLKEM_INDCPA_MSGBYTES - 1u] == 255u);

  return 0;
}
