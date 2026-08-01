#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PBCODEC-CV1.M2
 *
 * Integration mutation:
 *
 *   real mlk_poly_frombytes
 *          |
 *          v
 *   decoded coefficient zero is deliberately changed
 *          |
 *          v
 *   real mlk_poly_tobytes
 *
 * The mutation preserves the canonical tobytes precondition:
 *
 *   0 <= decoded.coeffs[0] < MLKEM_Q
 *
 * Expected result:
 * The original CV1.P2 byte-equality property must become falsifiable.
 *
 * Production source is not modified.
 */
void harness(void)
{
  uint8_t input[MLKEM_POLYBYTES];
  uint8_t reencoded[MLKEM_POLYBYTES];

  mlk_poly decoded;

  size_t byte_index;
  unsigned block_index;

  uint32_t packed_word;
  uint32_t even_field;
  uint32_t odd_field;

  __CPROVER_assume(byte_index < MLKEM_POLYBYTES);

  /*
   * Restrict arbitrary bytes to the canonical encoder image.
   * These expressions establish only the valid input domain.
   */
  for (block_index = 0u;
       block_index < (MLKEM_N / 2u);
       block_index++)
  {
    packed_word =
        (uint32_t)input[3u * block_index] +
        UINT32_C(256) *
            (uint32_t)input[3u * block_index + 1u] +
        UINT32_C(65536) *
            (uint32_t)input[3u * block_index + 2u];

    even_field = packed_word % UINT32_C(4096);
    odd_field = packed_word / UINT32_C(4096);

    __CPROVER_assume(even_field < MLKEM_Q);
    __CPROVER_assume(odd_field < MLKEM_Q);
  }

  mlk_poly_frombytes(&decoded, input);

  /*
   * Deliberate harness-side bridge mutation.
   * The changed coefficient remains canonical and differs from its
   * original value.
   */
  if (decoded.coeffs[0] == 0)
  {
    decoded.coeffs[0] = 1;
  }
  else
  {
    decoded.coeffs[0] =
        (int16_t)(decoded.coeffs[0] - 1);
  }

  mlk_poly_tobytes(reencoded, &decoded);

  __CPROVER_assert(
      reencoded[byte_index] == input[byte_index],
      "PBCODEC-CV1.M2 corrupted decoded bridge must break CV1.P2");
}
