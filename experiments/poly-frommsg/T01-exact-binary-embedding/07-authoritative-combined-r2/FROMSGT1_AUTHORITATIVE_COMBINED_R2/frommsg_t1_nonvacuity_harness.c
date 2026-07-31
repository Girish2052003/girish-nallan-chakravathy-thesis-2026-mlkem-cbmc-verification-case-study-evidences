#include <stdint.h>

#include "compress.h"

void __CPROVER_cover(_Bool condition);

#if MLKEM_N != 256
#error "FROMMSG-T1 coverage requires MLKEM_N == 256"
#endif

#if MLKEM_INDCPA_MSGBYTES != 32
#error "FROMMSG-T1 coverage requires 32 message bytes"
#endif

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;
  uint8_t bit;
  int16_t expected;

  mlk_poly_frommsg(&r, msg);

  bit = (uint8_t)((msg[(unsigned)k / 8u] >>
                   ((unsigned)k % 8u)) &
                  1u);

  expected = (bit != 0u ? MLKEM_Q_HALF : 0);

  __CPROVER_cover(1);
  __CPROVER_cover(bit == 0u);
  __CPROVER_cover(bit == 1u);
  __CPROVER_cover(r.coeffs[(unsigned)k] == expected);
}
