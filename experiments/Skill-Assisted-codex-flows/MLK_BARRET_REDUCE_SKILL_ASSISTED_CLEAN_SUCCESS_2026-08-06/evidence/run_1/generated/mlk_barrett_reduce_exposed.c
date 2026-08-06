/* Generated exposure-only translation unit. The arithmetic body below is byte-identical
 * to the pinned production function; only static/inline linkage is removed. */
#include "common.h"
#include "cbmc.h"
#include "debug.h"
#include "params.h"

int16_t mlk_barrett_reduce(int16_t a)
__contract__(
  ensures(return_value > -MLKEM_Q_HALF && return_value < MLKEM_Q_HALF)
)
{
  /* Barrett reduction approximates
   * ```
   *     round(a/MLKEM_Q)
   *   = round(a*(2^N/MLKEM_Q))/2^N)
   *  ~= round(a*round(2^N/MLKEM_Q)/2^N)
   * ```
   * Here, we pick N=26.
   */
  const int32_t magic = 20159; /* check-magic: 20159 == round(2^26 / MLKEM_Q) */

  /*
   * PORTABILITY: Right-shift on a signed integer is
   * implementation-defined for negative left argument.
   * Here, we assume it's sign-preserving "arithmetic" shift right.
   * See (C99 6.5.7 (5))
   */
  const int32_t t = (magic * a + ((int32_t)1 << 25)) >> 26;

  /*
   * t is in -10 .. +10, so we need 32-bit math to
   * evaluate t * MLKEM_Q and the subsequent subtraction
   */
  int16_t res = (int16_t)(a - t * MLKEM_Q);

  mlk_assert_abs_bound(&res, 1, MLKEM_Q_HALF);
  return res;
}
