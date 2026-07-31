#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T1 exact raw-decoding semantics.
 *
 * The input byte array and selected block index are nondeterministic.
 * The only assumption restricts the selected block to the valid range.
 *
 * The oracle uses widened arithmetic, multiplication, division and
 * remainder. It does not reuse the production shift-and-mask formulas.
 */
void harness(void)
{
  uint8_t input[MLKEM_POLYBYTES];
  mlk_poly output;
  size_t block_index;

  uint32_t word24;
  uint32_t even_oracle;
  uint32_t odd_oracle;

  __CPROVER_assume(block_index < (MLKEM_N / 2u));

  /*
   * Required real proof target:
   * public wrapper, not the file-local portable helper.
   */
  mlk_poly_frombytes(&output, input);

  word24 =
      (uint32_t)input[3u * block_index] +
      UINT32_C(256) *
          (uint32_t)input[3u * block_index + 1u] +
      UINT32_C(65536) *
          (uint32_t)input[3u * block_index + 2u];

  even_oracle = word24 % UINT32_C(4096);
  odd_oracle = word24 / UINT32_C(4096);

  __CPROVER_assert(
      (uint32_t)(uint16_t)output.coeffs[2u * block_index] ==
          even_oracle,
      "PFB-T1.P1 exact even raw-decoding semantics");

  __CPROVER_assert(
      (uint32_t)(uint16_t)output.coeffs[2u * block_index + 1u] ==
          odd_oracle,
      "PFB-T1.P2 exact odd raw-decoding semantics");
}
