// CANON-T1 coverage-only companion.
// This binary is not used as the theorem result.

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

  const int32_t negative_representative =
      (int32_t)u - (int32_t)MLKEM_Q;

  __CPROVER_cover(x < 0);
  __CPROVER_cover(x == 0);
  __CPROVER_cover(x > 0);

  __CPROVER_cover(
      difference == -(int32_t)MLKEM_Q &&
      fx == fy);

  __CPROVER_cover(
      difference == 0 &&
      fx == fy);

  __CPROVER_cover(
      difference == (int32_t)MLKEM_Q &&
      fx == fy);

  __CPROVER_cover(
      c == u &&
      fc == u);

  __CPROVER_cover(
      (int32_t)c == negative_representative &&
      fc == u);
}
