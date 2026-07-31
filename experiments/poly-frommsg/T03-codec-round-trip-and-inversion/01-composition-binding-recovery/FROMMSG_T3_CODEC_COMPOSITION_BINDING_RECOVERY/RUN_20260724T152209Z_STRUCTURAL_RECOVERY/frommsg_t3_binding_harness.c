#include <stdint.h>

#include "compress.h"

void harness(void)
{
  mlk_poly encoded;
  uint8_t input[MLKEM_INDCPA_MSGBYTES];
  uint8_t decoded[MLKEM_INDCPA_MSGBYTES];

  mlk_poly_frommsg(&encoded, input);
  mlk_poly_tomsg(decoded, &encoded);
}
