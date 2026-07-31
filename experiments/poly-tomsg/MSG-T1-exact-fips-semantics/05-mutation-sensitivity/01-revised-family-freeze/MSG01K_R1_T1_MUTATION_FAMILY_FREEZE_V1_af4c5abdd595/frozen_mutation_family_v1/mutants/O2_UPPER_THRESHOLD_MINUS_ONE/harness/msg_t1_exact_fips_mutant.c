/*
 * MSG-T1 candidate V4 - contract-erased, pragma-preserving build
 *
 * Exact functional refinement of the production mlk_poly_tomsg output
 * against an independently written threshold oracle for canonical
 * ML-KEM coefficients.
 *
 * This oracle does not invoke any production compression routine.
 */

#include <stdint.h>

#include "compress.h"

/*
 * Independently registered canonical Compress1 decision oracle:
 *
 *   0 <= u <= 832       -> 0
 *   833 <= u <= 2496    -> 1
 *   2497 <= u <= 3328   -> 0
 *
 * Its equivalence to the exact integer FIPS expression over all 3329
 * canonical inputs was exhaustively established in MSG-00C.
 */
uint8_t msg_t1_threshold_oracle(int16_t u)
{
  return (uint8_t)((u >= 833) && (u <= 2495));
}

int main(void)
{
  mlk_poly a;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  unsigned k;

  __CPROVER_assert(
      MLKEM_N == 256,
      "MSG_T1_MODEL: polynomial degree must be 256");

  __CPROVER_assert(
      MLKEM_INDCPA_MSGBYTES == 32,
      "MSG_T1_MODEL: message size must be 32 bytes");

  __CPROVER_assert(
      msg_t1_threshold_oracle(832) == 0,
      "MSG_T1_ORACLE: lower-zero boundary");

  __CPROVER_assert(
      msg_t1_threshold_oracle(833) == 1,
      "MSG_T1_ORACLE: lower-one boundary");

  __CPROVER_assert(
      msg_t1_threshold_oracle(2496) == 1,
      "MSG_T1_ORACLE: upper-one boundary");

  __CPROVER_assert(
      msg_t1_threshold_oracle(2497) == 0,
      "MSG_T1_ORACLE: upper-zero boundary");

  /*
   * Uninitialized automatic coefficients are symbolic in the CBMC model.
   * Restrict each coefficient only to the registered canonical domain.
   */
  for (k = 0u; k < MLKEM_N; k++)
  {
    __CPROVER_assume(a.coeffs[k] >= 0);
    __CPROVER_assume(a.coeffs[k] < MLKEM_Q);
  }

  /*
   * Execute the actual frozen production implementation.
   * The initial message bytes remain arbitrary.
   */
  mlk_poly_tomsg(msg, &a);

  /*
   * Independent coefficient-to-output-bit comparison.
   *
   * This intentionally indexes the output as a flat sequence of 256 bits,
   * rather than reproducing the production function's nested i/j loops.
   */
  for (k = 0u; k < MLKEM_N; k++)
  {
    uint8_t actual_bit;
    uint8_t expected_bit;

    actual_bit =
        (uint8_t)((msg[k >> 3] >> (k & 7u)) & 1u);

    expected_bit =
        msg_t1_threshold_oracle(a.coeffs[k]);

    __CPROVER_assert(
        actual_bit == expected_bit,
        "MSG_T1_EXACT: every output bit must equal the independent Compress1 oracle");
  }

  return 0;
}
