#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PBCODEC-CV1.P2
 *
 * Canonical 384-byte representation
 *   -> real public mlk_poly_frombytes
 *   -> real public mlk_poly_tobytes
 *   -> identical byte representation.
 *
 * The arithmetic expressions below are used only to restrict the input
 * to the canonical encoder image. They do not calculate the expected
 * final byte result.
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
  mlk_poly_tobytes(reencoded, &decoded);

  __CPROVER_assert(
      reencoded[byte_index] == input[byte_index],
      "PBCODEC-CV1.P2 canonical bytes survive real decode-encode");
}
