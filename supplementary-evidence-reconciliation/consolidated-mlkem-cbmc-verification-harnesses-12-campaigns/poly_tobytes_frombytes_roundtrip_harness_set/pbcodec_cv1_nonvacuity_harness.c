#include <stdint.h>

#include "compress.h"

/*
 * PBCODEC-CV1 non-vacuity companion.
 *
 * Expected result: both labelled assertions are reachable and therefore
 * fail. This is an integrity control, not a positive semantic theorem.
 */
void harness(void)
{
  mlk_poly input;
  mlk_poly decoded;

  uint8_t encoded[MLKEM_POLYBYTES];
  uint8_t reencoded[MLKEM_POLYBYTES];

  unsigned i;

  for (i = 0u; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 0;
  }

  input.coeffs[0] = 0;
  input.coeffs[1] = 1;
  input.coeffs[2] = 15;
  input.coeffs[3] = 16;
  input.coeffs[4] = 255;
  input.coeffs[5] = 256;
  input.coeffs[6] = MLKEM_Q - 1;

  mlk_poly_tobytes(encoded, &input);
  mlk_poly_frombytes(&decoded, encoded);

  __CPROVER_assert(
      0,
      "PBCODEC-CV1.NV1 encode-decode endpoint is reachable");

  mlk_poly_tobytes(reencoded, &decoded);

  __CPROVER_assert(
      0,
      "PBCODEC-CV1.NV2 decode-encode endpoint is reachable");
}
