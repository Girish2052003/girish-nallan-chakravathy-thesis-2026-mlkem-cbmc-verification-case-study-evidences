#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PBCODEC-CV1.P1
 *
 * Canonical polynomial
 *   -> real public mlk_poly_tobytes
 *   -> real public mlk_poly_frombytes
 *   -> identical polynomial.
 *
 * This is direct production-to-production composition evidence.
 * No independent encoder or decoder is used.
 */
void harness(void)
{
  mlk_poly input;
  mlk_poly recovered;

  uint8_t encoded[MLKEM_POLYBYTES];

  size_t coefficient_index;
  unsigned i;

  __CPROVER_assume(coefficient_index < MLKEM_N);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);
  }

  mlk_poly_tobytes(encoded, &input);
  mlk_poly_frombytes(&recovered, encoded);

  __CPROVER_assert(
      recovered.coeffs[coefficient_index] ==
          input.coeffs[coefficient_index],
      "PBCODEC-CV1.P1 canonical polynomial survives real encode-decode");
}
