#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T1 raw-domain boundary reachability.
 *
 * For an arbitrary valid block index, this control reaches both endpoint
 * decoded pairs: (0,0) and (4095,4095). Other input bytes remain arbitrary.
 */
void harness(void)
{
  uint8_t low_input[MLKEM_POLYBYTES];
  uint8_t high_input[MLKEM_POLYBYTES];
  mlk_poly low_output;
  mlk_poly high_output;
  size_t block_index;

  __CPROVER_assume(block_index < (MLKEM_N / 2u));

  low_input[3u * block_index + 0u] = UINT8_C(0);
  low_input[3u * block_index + 1u] = UINT8_C(0);
  low_input[3u * block_index + 2u] = UINT8_C(0);

  high_input[3u * block_index + 0u] = UINT8_C(255);
  high_input[3u * block_index + 1u] = UINT8_C(255);
  high_input[3u * block_index + 2u] = UINT8_C(255);

  mlk_poly_frombytes(&low_output, low_input);
  mlk_poly_frombytes(&high_output, high_input);

  __CPROVER_assert(
      low_output.coeffs[2u * block_index] == 0,
      "PFB-B1 raw even lower endpoint is reachable");

  __CPROVER_assert(
      low_output.coeffs[2u * block_index + 1u] == 0,
      "PFB-B2 raw odd lower endpoint is reachable");

  __CPROVER_assert(
      high_output.coeffs[2u * block_index] == 4095,
      "PFB-B3 raw even upper endpoint is reachable");

  __CPROVER_assert(
      high_output.coeffs[2u * block_index + 1u] == 4095,
      "PFB-B4 raw odd upper endpoint is reachable");
}
