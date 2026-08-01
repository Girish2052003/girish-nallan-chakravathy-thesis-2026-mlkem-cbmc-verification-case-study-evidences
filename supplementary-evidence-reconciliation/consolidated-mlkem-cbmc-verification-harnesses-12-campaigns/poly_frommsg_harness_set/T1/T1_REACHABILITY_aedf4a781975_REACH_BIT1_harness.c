#include <assert.h>
#include <stdint.h>

#include "compress.h"

void __CPROVER_assume(_Bool condition);

#if MLKEM_N != 256
#error "FROMMSG-T1 requires MLKEM_N == 256"
#endif

#if MLKEM_INDCPA_MSGBYTES != 32
#error "FROMMSG-T1 requires 32 message bytes"
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

  __CPROVER_assume(bit == 1u);

  assert(0);
}
