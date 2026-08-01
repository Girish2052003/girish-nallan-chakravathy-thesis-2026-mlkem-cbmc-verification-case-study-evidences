/*
 * MSG-T2-R3B — determinism and input-frame preservation.
 *
 * Let SOURCE be an arbitrary canonical polynomial. Construct two independent
 * polynomial objects RUN_A and RUN_B with identical initial contents:
 *
 *   RUN_A_before == RUN_B_before == SOURCE.
 *
 * Execute the real production function once on each object, using separate
 * destination buffers whose initial contents are not constrained equal.
 *
 * The theorem establishes:
 *
 *   1. RUN_A remains equal to SOURCE after execution;
 *   2. RUN_B remains equal to SOURCE after execution;
 *   3. every byte of MSG_A equals the corresponding byte of MSG_B.
 *
 * Thus equal polynomial values produce equal complete message values,
 * independent of input-object identity and destination-buffer identity.
 *
 * This is functional determinism. It is not a timing, scheduling,
 * microarchitectural, leakage, or constant-time claim.
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
  unsigned byte_index;

  __CPROVER_assert(
      MLKEM_N == 256,
      "MSG_T2_R3B_MODEL: polynomial degree must be 256");

  __CPROVER_assert(
      MLKEM_INDCPA_MSGBYTES == 32,
      "MSG_T2_R3B_MODEL: message size must be 32 bytes");

  /*
   * SOURCE ranges over the complete canonical polynomial domain.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(source.coeffs[i] >= 0);
    __CPROVER_assume(source.coeffs[i] < MLKEM_Q);
  }

  /*
   * Two distinct input objects begin with the same polynomial value.
   */
  run_a = source;
  run_b = source;

  /*
   * Two executions of the real frozen production implementation.
   *
   * MSG_A and MSG_B are separate destination objects and are not assumed to
   * have equal initial contents.
   */
  mlk_poly_tomsg(msg_a, &run_a);
  mlk_poly_tomsg(msg_b, &run_b);

  /*
   * Input-frame preservation for both independent executions.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        run_a.coeffs[i] == source.coeffs[i],
        "MSG_T2_R3B_INPUT_FRAME_A: first execution must preserve its input polynomial");

    __CPROVER_assert(
        run_b.coeffs[i] == source.coeffs[i],
        "MSG_T2_R3B_INPUT_FRAME_B: second execution must preserve its input polynomial");
  }

  /*
   * Full output determinism across all 32 message bytes.
   */
  for (byte_index = 0u;
       byte_index < MLKEM_INDCPA_MSGBYTES;
       byte_index++)
  {
    __CPROVER_assert(
        msg_a[byte_index] == msg_b[byte_index],
        "MSG_T2_R3B_DETERMINISM: equal polynomial values must produce equal complete messages");
  }

  return 0;
}
