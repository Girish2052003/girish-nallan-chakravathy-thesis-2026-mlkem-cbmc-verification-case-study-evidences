// CANON-T2 non-vacuity coverage companion.
// This binary contains no theorem assertions.

#include <stdint.h>

#include "common.h"
#include "params.h"

int16_t mlk_scalar_signed_to_unsigned_q(int16_t c);

void harness(void)
{
  int16_t u;
  int16_t v;
  int16_t c;

  __CPROVER_assume((int32_t)u >= 0);
  __CPROVER_assume((int32_t)u < (int32_t)MLKEM_Q);

  __CPROVER_assume((int32_t)v >= 0);
  __CPROVER_assume((int32_t)v < (int32_t)MLKEM_Q);

  __CPROVER_assume((int32_t)c > -(int32_t)MLKEM_Q);
  __CPROVER_assume((int32_t)c <  (int32_t)MLKEM_Q);

  const int16_t fu =
      mlk_scalar_signed_to_unsigned_q(u);

  const int16_t fv =
      mlk_scalar_signed_to_unsigned_q(v);

  const int16_t fc =
      mlk_scalar_signed_to_unsigned_q(c);

  const int16_t ffc =
      mlk_scalar_signed_to_unsigned_q(fc);

  /*
   * Canonical endpoints.
   */
  __CPROVER_cover(
      u == 0 &&
      fu == 0);

  __CPROVER_cover(
      (int32_t)u == (int32_t)MLKEM_Q - 1 &&
      fu == u);

  /*
   * Negative, zero and positive target-domain classes.
   */
  __CPROVER_cover(
      c < 0 &&
      fc != c);

  __CPROVER_cover(
      c == 0 &&
      fc == 0);

  __CPROVER_cover(
      c > 0 &&
      fc == c);

  /*
   * Idempotence witness.
   */
  __CPROVER_cover(
      ffc == fc);

  /*
   * Equal and distinct canonical-input cases.
   */
  __CPROVER_cover(
      u == v &&
      fu == fv);

  __CPROVER_cover(
      u != v &&
      fu != fv);
}
