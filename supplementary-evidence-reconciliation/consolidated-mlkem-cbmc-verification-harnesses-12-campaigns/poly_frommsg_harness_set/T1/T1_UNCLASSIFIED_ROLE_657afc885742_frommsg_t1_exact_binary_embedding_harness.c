/*
 * Clean-room CBMC harness for mlk_poly_frommsg.
 *
 * Theorem FROMMSG-T1:
 * For every message and every coefficient index k in [0, 255],
 * the output coefficient is exactly MLKEM_Q_HALF when message bit k
 * is one, and exactly zero when message bit k is zero.
 *
 * This harness was not copied from the native poly_frommsg harness.
 */

#include <assert.h>
#include <stdint.h>

#include "compress.h"

#if MLKEM_N != 256
#error "FROMMSG-T1 requires MLKEM_N == 256"
#endif

#if MLKEM_INDCPA_MSGBYTES != 32
#error "FROMMSG-T1 requires a 32-byte message"
#endif

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;
  uint8_t bit;

  mlk_poly_frommsg(&r, msg);

  bit = (uint8_t)((msg[(unsigned)k / 8u] >>
                   ((unsigned)k % 8u)) &
                  1u);

  assert(
    r.coeffs[(unsigned)k] ==
    (bit != 0u ? MLKEM_Q_HALF : 0));
}
