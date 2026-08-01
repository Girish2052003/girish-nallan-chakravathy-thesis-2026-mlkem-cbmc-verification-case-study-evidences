/*
 * PKCHECK-T1R2
 *
 * Actual-body malformed-public-key rejection under arbitrary context.
 *
 * One symbolic non-canonical 12-bit coefficient is inserted into an
 * otherwise fully symbolic ML-KEM-768 public key. The neighbouring
 * coefficient nibble, all other polynomial-vector bytes, and the complete
 * public-seed suffix remain arbitrary.
 */

#include <stdint.h>

#include <cbmc.h>
#include <kem.h>
#include <params.h>

#define PKCHECK_COEFFICIENT_COUNT \
  ((unsigned)MLKEM_K * (unsigned)MLKEM_N)

#define PKCHECK_POLYVEC_BYTE_COUNT \
  ((unsigned)MLKEM_POLYVECBYTES)

#define PKCHECK_UINT12_LIMIT 4096u

_Static_assert(
    MLKEM_INDCCA_PUBLICKEYBYTES ==
        MLKEM_POLYVECBYTES + MLKEM_SYMBYTES,
    "PKCHECK-T1R2 public-key layout mismatch");

void harness(void)
{
  uint8_t pk[MLKEM_INDCCA_PUBLICKEYBYTES];

  unsigned coefficient_index;
  unsigned pair_index;
  unsigned byte_index;

  uint16_t malformed_value;
  uint32_t value32;
  uint16_t independently_decoded;

  int result;

  __CPROVER_havoc_object(&pk);
  __CPROVER_havoc_object(&coefficient_index);
  __CPROVER_havoc_object(&malformed_value);

  __CPROVER_assume(
      coefficient_index < PKCHECK_COEFFICIENT_COUNT);

  __CPROVER_assume(
      malformed_value >= (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      malformed_value < (uint16_t)PKCHECK_UINT12_LIMIT);

  pair_index = coefficient_index / 2u;

  __CPROVER_assert(
      pair_index < (PKCHECK_COEFFICIENT_COUNT / 2u),
      "PKCHECK-T1R2.INDEX_PAIR_BOUND: pair index is in range");

  byte_index = pair_index * 3u;

  __CPROVER_assert(
      byte_index <= PKCHECK_POLYVEC_BYTE_COUNT - 3u,
      "PKCHECK-T1R2.INDEX_BYTE_BOUND: three-byte block is in range");

  value32 = (uint32_t)malformed_value;

  /*
   * Independent ByteEncode_12 insertion. The unrelated nibble belonging to
   * the neighbouring coefficient is preserved from the arbitrary context.
   */
  if ((coefficient_index & 1u) == 0u)
  {
    pk[byte_index] =
        (uint8_t)(value32 & UINT32_C(0xFF));

    pk[byte_index + 1u] =
        (uint8_t)(
            ((uint32_t)pk[byte_index + 1u] &
             UINT32_C(0xF0)) |
            ((value32 >> 8) & UINT32_C(0x0F)));
  }
  else
  {
    pk[byte_index + 1u] =
        (uint8_t)(
            ((uint32_t)pk[byte_index + 1u] &
             UINT32_C(0x0F)) |
            ((value32 & UINT32_C(0x0F)) << 4));

    pk[byte_index + 2u] =
        (uint8_t)((value32 >> 4) & UINT32_C(0xFF));
  }

  /*
   * Independent ByteDecode_12 oracle for the selected coefficient.
   */
  if ((coefficient_index & 1u) == 0u)
  {
    independently_decoded =
        (uint16_t)(
            (uint16_t)pk[byte_index] |
            ((uint16_t)(
                 pk[byte_index + 1u] & UINT8_C(0x0F))
             << 8));
  }
  else
  {
    independently_decoded =
        (uint16_t)(
            ((uint16_t)pk[byte_index + 1u] >> 4) |
            ((uint16_t)pk[byte_index + 2u] << 4));
  }

  __CPROVER_assert(
      independently_decoded == malformed_value,
      "PKCHECK-T1R2.ORACLE_PACKING: independently packed coefficient decodes exactly");

  result = mlk_kem_check_pk(
      pk,
      NULL /* context removed by preprocessing */);

  __CPROVER_assert(
      result == MLK_ERR_FAIL ||
          result == MLK_ERR_OUT_OF_MEMORY,
      "PKCHECK-T1R2.ARBITRARY_CONTEXT_REJECTION: a non-canonical coefficient cannot be accepted in arbitrary context");

  __CPROVER_cover(
      result == MLK_ERR_FAIL);
}
