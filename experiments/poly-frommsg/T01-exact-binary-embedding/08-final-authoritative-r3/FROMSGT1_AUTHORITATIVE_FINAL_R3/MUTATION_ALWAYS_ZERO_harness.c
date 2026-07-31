#include <assert.h>
#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;

  mlk_poly_frommsg(&r, msg);

  assert(r.coeffs[(unsigned)k] == 0);
}
