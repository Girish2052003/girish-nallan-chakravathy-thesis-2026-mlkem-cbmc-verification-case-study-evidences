// CANON-T3 theorem-only clean-room harness.
// Modular addition, subtraction and negation compatibility.

#include <stdbool.h>
#include <stdint.h>

#include "common.h"
#include "params.h"

int16_t mlk_scalar_signed_to_unsigned_q(int16_t c);

/*
 * Independent mathematical oracle.
 *
 * This deliberately uses int32_t remainder arithmetic and does not reproduce
 * the production target's masking or selection implementation.
 */
static int16_t canon_q_i32(int32_t value)
{
  int32_t remainder =
      value % (int32_t)MLKEM_Q;

  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return (int16_t)remainder;
}

void harness(void)
{
  int16_t x;
  int16_t y;

  __CPROVER_assume((int32_t)x > -(int32_t)MLKEM_Q);
  __CPROVER_assume((int32_t)x <  (int32_t)MLKEM_Q);

  __CPROVER_assume((int32_t)y > -(int32_t)MLKEM_Q);
  __CPROVER_assume((int32_t)y <  (int32_t)MLKEM_Q);

  const int32_t sum32 =
      (int32_t)x + (int32_t)y;

  const int32_t difference32 =
      (int32_t)x - (int32_t)y;

  const int32_t negative_x32 =
      -(int32_t)x;

  const bool sum_in_domain =
      sum32 > -(int32_t)MLKEM_Q &&
      sum32 <  (int32_t)MLKEM_Q;

  const bool difference_in_domain =
      difference32 > -(int32_t)MLKEM_Q &&
      difference32 <  (int32_t)MLKEM_Q;

  const int16_t fx =
      mlk_scalar_signed_to_unsigned_q(x);

  const int16_t fy =
      mlk_scalar_signed_to_unsigned_q(y);

  int16_t fsum = 0;
  int16_t fdifference = 0;

  if (sum_in_domain)
  {
    fsum = mlk_scalar_signed_to_unsigned_q(
        (int16_t)sum32);
  }

  if (difference_in_domain)
  {
    fdifference = mlk_scalar_signed_to_unsigned_q(
        (int16_t)difference32);
  }

  const int16_t fnegative_x =
      mlk_scalar_signed_to_unsigned_q(
          (int16_t)negative_x32);

  const int16_t oracle_addition =
      canon_q_i32(
          (int32_t)fx + (int32_t)fy);

  const int16_t oracle_subtraction =
      canon_q_i32(
          (int32_t)fx - (int32_t)fy);

  const int16_t oracle_negation =
      canon_q_i32(-(int32_t)fx);

  __CPROVER_assert(
      !sum_in_domain ||
      fsum == oracle_addition,
      "CANON-T3.P1 modular addition compatibility");

  __CPROVER_assert(
      !difference_in_domain ||
      fdifference == oracle_subtraction,
      "CANON-T3.P2 modular subtraction compatibility");

  __CPROVER_assert(
      fnegative_x == oracle_negation,
      "CANON-T3.P3 modular negation compatibility");

  /*
   * Supporting output-range controls.
   * These are not additional semantic T3 theorem registrations.
   */
  __CPROVER_assert(
      (int32_t)fx >= 0 &&
      (int32_t)fx < (int32_t)MLKEM_Q,
      "CANON-CONTROL T3 output range fx");

  __CPROVER_assert(
      (int32_t)fy >= 0 &&
      (int32_t)fy < (int32_t)MLKEM_Q,
      "CANON-CONTROL T3 output range fy");

  __CPROVER_assert(
      !sum_in_domain ||
      ((int32_t)fsum >= 0 &&
       (int32_t)fsum < (int32_t)MLKEM_Q),
      "CANON-CONTROL T3 output range fsum");

  __CPROVER_assert(
      !difference_in_domain ||
      ((int32_t)fdifference >= 0 &&
       (int32_t)fdifference < (int32_t)MLKEM_Q),
      "CANON-CONTROL T3 output range fdifference");

  __CPROVER_assert(
      (int32_t)fnegative_x >= 0 &&
      (int32_t)fnegative_x < (int32_t)MLKEM_Q,
      "CANON-CONTROL T3 output range fnegative_x");

  __CPROVER_assert(
      (int32_t)oracle_addition >= 0 &&
      (int32_t)oracle_addition < (int32_t)MLKEM_Q,
      "CANON-CONTROL T3 oracle range addition");

  __CPROVER_assert(
      (int32_t)oracle_subtraction >= 0 &&
      (int32_t)oracle_subtraction < (int32_t)MLKEM_Q,
      "CANON-CONTROL T3 oracle range subtraction");

  __CPROVER_assert(
      (int32_t)oracle_negation >= 0 &&
      (int32_t)oracle_negation < (int32_t)MLKEM_Q,
      "CANON-CONTROL T3 oracle range negation");
}
