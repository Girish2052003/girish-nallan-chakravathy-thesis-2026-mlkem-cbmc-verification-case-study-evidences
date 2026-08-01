// CANON-T2 theorem-only clean-room harness.
// Retraction and normalization-stability characterization.

#include <stdbool.h>
#include <stdint.h>

#include "common.h"
#include "params.h"

int16_t mlk_scalar_signed_to_unsigned_q(int16_t c);

void harness(void)
{
  int16_t u;
  int16_t v;
  int16_t c;

  /*
   * u and v range over the canonical set U = {0, ..., q-1}.
   */
  __CPROVER_assume((int32_t)u >= 0);
  __CPROVER_assume((int32_t)u < (int32_t)MLKEM_Q);

  __CPROVER_assume((int32_t)v >= 0);
  __CPROVER_assume((int32_t)v < (int32_t)MLKEM_Q);

  /*
   * c ranges over the legal target domain D = {-q+1, ..., q-1}.
   */
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
   * CANON-T2.P1:
   * every canonical representative is a fixed point.
   */
  __CPROVER_assert(
      fu == u,
      "CANON-T2.P1 canonical retraction");

  /*
   * CANON-T2.P2:
   * applying normalization twice is equivalent to applying it once.
   */
  __CPROVER_assert(
      ffc == fc,
      "CANON-T2.P2 normalization idempotence");

  /*
   * CANON-T2.P3:
   * the fixed points inside D are exactly the nonnegative inputs.
   */
  __CPROVER_assert(
      (fc == c) == (c >= 0),
      "CANON-T2.P3 exact fixed-point characterization");

  /*
   * CANON-T2.P4:
   * normalization is injective when restricted to U.
   */
  __CPROVER_assert(
      fu != fv || u == v,
      "CANON-T2.P4 canonical-set injectivity");

  /*
   * Supporting safety/range controls.
   * These are not additional CANON semantic theorem registrations.
   */
  __CPROVER_assert(
      (int32_t)fu >= 0 &&
      (int32_t)fu < (int32_t)MLKEM_Q,
      "CANON-CONTROL T2 output range fu");

  __CPROVER_assert(
      (int32_t)fv >= 0 &&
      (int32_t)fv < (int32_t)MLKEM_Q,
      "CANON-CONTROL T2 output range fv");

  __CPROVER_assert(
      (int32_t)fc >= 0 &&
      (int32_t)fc < (int32_t)MLKEM_Q,
      "CANON-CONTROL T2 output range fc");

  __CPROVER_assert(
      (int32_t)ffc >= 0 &&
      (int32_t)ffc < (int32_t)MLKEM_Q,
      "CANON-CONTROL T2 output range ffc");
}
