#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PBCODEC-CV1.M1
 *
 * Integration mutation:
 *
 *   real mlk_poly_tobytes
 *          |
 *          v
 *   encoded[0] is deliberately corrupted
 *          |
 *          v
 *   real mlk_poly_frombytes
 *
 * Expected result:
 * The original CV1.P1 equality property must become falsifiable.
 *
 * Production source is not modified.
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

  /*
   * Deliberate harness-side bridge mutation.
   * Flipping bit zero changes the first decoded coefficient.
   */
  encoded[0] ^= 1u;

  mlk_poly_frombytes(&recovered, encoded);

  __CPROVER_assert(
      recovered.coeffs[coefficient_index] ==
          input.coeffs[coefficient_index],
      "PBCODEC-CV1.M1 corrupted encoded bridge must break CV1.P1");
}
