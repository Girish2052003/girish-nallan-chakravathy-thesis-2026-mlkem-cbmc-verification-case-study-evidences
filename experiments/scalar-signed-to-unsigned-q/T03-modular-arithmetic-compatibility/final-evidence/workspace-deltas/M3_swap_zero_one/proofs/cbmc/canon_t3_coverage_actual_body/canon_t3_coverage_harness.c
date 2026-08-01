// CANON-T3 non-vacuity coverage companion.
// No theorem assertions are included in this binary.

#include <stdbool.h>
#include <stdint.h>

#include "common.h"
#include "params.h"

int16_t mlk_scalar_signed_to_unsigned_q(int16_t c);

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

  /*
   * Addition-domain boundary and wrap witnesses.
   */
  __CPROVER_cover(
      sum32 == -((int32_t)MLKEM_Q - 1) &&
      fsum == oracle_addition);

  __CPROVER_cover(
      sum32 == 0 &&
      fsum == oracle_addition);

  __CPROVER_cover(
      sum32 == (int32_t)MLKEM_Q - 1 &&
      fsum == oracle_addition);

  __CPROVER_cover(
      sum_in_domain &&
      (int32_t)fx + (int32_t)fy ==
          (int32_t)MLKEM_Q &&
      fsum == oracle_addition);

  /*
   * Subtraction-domain boundary and negative-oracle witnesses.
   */
  __CPROVER_cover(
      difference32 == -((int32_t)MLKEM_Q - 1) &&
      fdifference == oracle_subtraction);

  __CPROVER_cover(
      difference32 == 0 &&
      fdifference == oracle_subtraction);

  __CPROVER_cover(
      difference32 == (int32_t)MLKEM_Q - 1 &&
      fdifference == oracle_subtraction);

  __CPROVER_cover(
      difference_in_domain &&
      fx < fy &&
      fdifference == oracle_subtraction);

  /*
   * Negation witnesses for all input-sign classes.
   */
  __CPROVER_cover(
      x < 0 &&
      fnegative_x == oracle_negation);

  __CPROVER_cover(
      x == 0 &&
      fnegative_x == oracle_negation);

  __CPROVER_cover(
      x > 0 &&
      fnegative_x == oracle_negation);
}
