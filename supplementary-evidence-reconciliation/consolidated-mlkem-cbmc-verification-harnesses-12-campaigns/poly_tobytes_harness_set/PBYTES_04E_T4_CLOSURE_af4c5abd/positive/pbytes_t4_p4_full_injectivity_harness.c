// PBYTES-T4.P4
//
// Direct full-array injectivity:
//
//   serialize(A) = serialize(B)  ==>  A = B
//
// Both inputs range independently over all canonical polynomials.
// Both outputs are produced through the real public wrapper.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

void harness(void)
{
  mlk_poly input_a;
  mlk_poly input_b;

  uint8_t output_a[MLKEM_POLYBYTES];
  uint8_t output_b[MLKEM_POLYBYTES];

  unsigned i;

  _Bool inputs_equal = 1;
  _Bool outputs_equal = 1;

  /*
   * Range over two arbitrary complete canonical polynomials while also
   * recording their exact full-array equality relation.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input_a.coeffs[i] >= 0);
    __CPROVER_assume(input_a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(input_b.coeffs[i] >= 0);
    __CPROVER_assume(input_b.coeffs[i] < MLKEM_Q);

    if (input_a.coeffs[i] != input_b.coeffs[i])
    {
      inputs_equal = 0;
    }
  }

  mlk_poly_tobytes(output_a, &input_a);
  mlk_poly_tobytes(output_b, &input_b);

  /*
   * Record complete 384-byte output equality.
   */
  for (i = 0u; i < MLKEM_POLYBYTES; i++)
  {
    if (output_a[i] != output_b[i])
    {
      outputs_equal = 0;
    }
  }

  __CPROVER_assert(
    !outputs_equal || inputs_equal,
    "PBYTES-T4.P4 full canonical-polynomial injectivity");
}
