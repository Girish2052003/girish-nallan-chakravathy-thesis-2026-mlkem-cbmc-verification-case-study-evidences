// CANON-T1 clean-room relational harness.
// This is not copied from the native scalar harness.

#include <stdbool.h>
#include <stdint.h>

#include "common.h"
#include "params.h"

int16_t mlk_scalar_signed_to_unsigned_q(int16_t c);

void harness(void)
{
  int16_t x;
  int16_t y;
  int16_t c;
  int16_t u;

  __CPROVER_assume((int32_t)x > -(int32_t)MLKEM_Q);
  __CPROVER_assume((int32_t)x <  (int32_t)MLKEM_Q);

  __CPROVER_assume((int32_t)y > -(int32_t)MLKEM_Q);
  __CPROVER_assume((int32_t)y <  (int32_t)MLKEM_Q);

  __CPROVER_assume((int32_t)c > -(int32_t)MLKEM_Q);
  __CPROVER_assume((int32_t)c <  (int32_t)MLKEM_Q);

  __CPROVER_assume((int32_t)u >= 1);
  __CPROVER_assume((int32_t)u < (int32_t)MLKEM_Q);

  const int16_t fx = mlk_scalar_signed_to_unsigned_q(x);
  const int16_t fy = mlk_scalar_signed_to_unsigned_q(y);
  const int16_t fc = mlk_scalar_signed_to_unsigned_q(c);

  const int32_t difference =
      (int32_t)x - (int32_t)y;

  const bool same_q_class =
      difference == -(int32_t)MLKEM_Q ||
      difference == 0 ||
      difference == (int32_t)MLKEM_Q;

  const bool same_output =
      fx == fy;

  const int32_t negative_representative =
      (int32_t)u - (int32_t)MLKEM_Q;

  const bool fibre_left =
      fc == u;

  const bool fibre_right =
      (int32_t)c == (int32_t)u ||
      (int32_t)c == negative_representative;

  __CPROVER_assert(
      !same_output || same_q_class,
      "CANON-T1.P1 collision necessity");

  __CPROVER_assert(
      !same_q_class || same_output,
      "CANON-T1.P2 collision sufficiency");

  __CPROVER_assert(
      (fc == 0) == (c == 0),
      "CANON-T1.P3 exact zero fibre");

  __CPROVER_assert(
      fibre_left == fibre_right,
      "CANON-T1.P4 exact nonzero fibres");

  /*
   * Supporting controls.
   * These are not counted as new CANON semantic theorems.
   */
  __CPROVER_assert(
      (int32_t)fx >= 0 && (int32_t)fx < (int32_t)MLKEM_Q,
      "CANON-CONTROL output range x");

  __CPROVER_assert(
      (int32_t)fy >= 0 && (int32_t)fy < (int32_t)MLKEM_Q,
      "CANON-CONTROL output range y");

  __CPROVER_assert(
      (int32_t)fc >= 0 && (int32_t)fc < (int32_t)MLKEM_Q,
      "CANON-CONTROL output range c");

  /*
   * Non-vacuity coverage goals.
   */
  __CPROVER_cover(x < 0);
  __CPROVER_cover(x == 0);
  __CPROVER_cover(x > 0);

  __CPROVER_cover(difference == -(int32_t)MLKEM_Q);
  __CPROVER_cover(difference == 0);
  __CPROVER_cover(difference == (int32_t)MLKEM_Q);

  __CPROVER_cover(c == u);
  __CPROVER_cover((int32_t)c == negative_representative);
}
