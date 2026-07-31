#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T2.P5 — arbitrary one-block locality.
 *
 * The second input is constructed from the first and then the selected
 * 3-byte block is replaced by three unrestricted bytes. The observed output
 * coefficient is arbitrary. Thus the assertion covers every coefficient
 * outside the selected output pair and permits unrestricted change inside it.
 */
void harness(void)
{
  uint8_t first_input[MLKEM_POLYBYTES];
  uint8_t second_input[MLKEM_POLYBYTES];

  mlk_poly first_output;
  mlk_poly second_output;

  uint8_t replacement0;
  uint8_t replacement1;
  uint8_t replacement2;

  uint32_t block_index;
  uint32_t coeff_index;
  uint32_t i;

  __CPROVER_assume(block_index < (MLKEM_N / 2u));
  __CPROVER_assume(coeff_index < MLKEM_N);

  for (i = 0u; i < MLKEM_POLYBYTES; i++)
  {
    second_input[i] = first_input[i];
  }

  second_input[3u * block_index] = replacement0;
  second_input[3u * block_index + 1u] = replacement1;
  second_input[3u * block_index + 2u] = replacement2;

  mlk_poly_frombytes(&first_output, first_input);
  mlk_poly_frombytes(&second_output, second_input);

  __CPROVER_assert(
      (coeff_index / 2u == block_index) ||
          (first_output.coeffs[coeff_index] ==
           second_output.coeffs[coeff_index]),
      "PFB-T2.P5 arbitrary one-block change leaves all other pairs unchanged");
}
