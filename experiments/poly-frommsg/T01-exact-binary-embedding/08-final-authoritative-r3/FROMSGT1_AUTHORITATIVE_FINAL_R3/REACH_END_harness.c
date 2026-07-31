#include <assert.h>
#include <stdint.h>

#include "compress.h"

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

  mlk_poly_frommsg(&r, msg);

  assert(0);
}
