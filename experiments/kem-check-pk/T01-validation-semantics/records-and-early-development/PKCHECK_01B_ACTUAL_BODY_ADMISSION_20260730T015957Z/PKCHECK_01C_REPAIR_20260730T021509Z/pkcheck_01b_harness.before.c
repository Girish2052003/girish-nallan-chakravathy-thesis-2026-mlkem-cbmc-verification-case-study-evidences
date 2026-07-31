/*
 * PKCHECK-01B
 *
 * Actual-body admission shard for mlk_kem_check_pk.
 *
 * The harness independently inserts one symbolic non-canonical 12-bit
 * coefficient into an otherwise zero polynomial-vector encoding.
 *
 * Retained production bodies:
 *   - mlk_kem_check_pk
 *   - mlk_polyvec_frombytes
 *   - mlk_polyvec_reduce
 *   - mlk_polyvec_tobytes
 *
 * This shard does not claim the final arbitrary-neighbour theorem.
 */

#include <stddef.h>
#include <stdint.h>

#include <cbmc.h>
#include <kem.h>
#include <params.h>

#define PKCHECK_COEFFICIENT_COUNT \
  ((size_t)MLKEM_K * (size_t)MLKEM_N)

#define PKCHECK_UINT12_LIMIT 4096u

static uint16_t pkcheck_decode12_at(
    const uint8_t pk[MLKEM_INDCCA_PUBLICKEYBYTES],
    size_t coefficient_index)
{
  const size_t pair_index = coefficient_index / 2u;
  const size_t byte_index = 3u * pair_index;

  if ((coefficient_index & 1u) == 0u)
  {
    return (uint16_t)(
        (uint16_t)pk[byte_index] |
        ((uint16_t)(pk[byte_index + 1u] & 0x0Fu) << 8));
  }

  return (uint16_t)(
      ((uint16_t)pk[byte_index + 1u] >> 4) |
      ((uint16_t)pk[byte_index + 2u] << 4));
}

static void pkcheck_store12_at(
    uint8_t pk[MLKEM_INDCCA_PUBLICKEYBYTES],
    size_t coefficient_index,
    uint16_t value)
{
  const size_t pair_index = coefficient_index / 2u;
  const size_t byte_index = 3u * pair_index;

  if ((coefficient_index & 1u) == 0u)
  {
    pk[byte_index] = (uint8_t)value;
    pk[byte_index + 1u] =
        (uint8_t)((pk[byte_index + 1u] & 0xF0u) |
                  ((value >> 8) & 0x0Fu));
  }
  else
  {
    pk[byte_index + 1u] =
        (uint8_t)((pk[byte_index + 1u] & 0x0Fu) |
                  ((value & 0x0Fu) << 4));
    pk[byte_index + 2u] = (uint8_t)(value >> 4);
  }
}

void harness(void)
{
  uint8_t pk[MLKEM_INDCCA_PUBLICKEYBYTES] = {0};
  size_t coefficient_index = 0;
  uint16_t malformed_value = MLKEM_Q;
  uint16_t independently_decoded;
  int result;

  /*
   * Explicit havoc avoids relying on implicit treatment of uninitialized
   * automatic variables.
   */
  __CPROVER_havoc_object(&coefficient_index);
  __CPROVER_havoc_object(&malformed_value);

  __CPROVER_assume(
      coefficient_index < PKCHECK_COEFFICIENT_COUNT);

  __CPROVER_assume(
      malformed_value >= (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      malformed_value < (uint16_t)PKCHECK_UINT12_LIMIT);

  /*
   * Every other polynomial-vector coefficient remains zero and canonical.
   * The 32-byte public-seed suffix also remains zero.
   */
  pkcheck_store12_at(
      pk,
      coefficient_index,
      malformed_value);

  independently_decoded =
      pkcheck_decode12_at(pk, coefficient_index);

  __CPROVER_assert(
      independently_decoded == malformed_value,
      "PKCHECK-01B.ORACLE_PACKING: independently packed coefficient decodes exactly");

  result = mlk_kem_check_pk(
      pk,
      NULL /* context removed by preprocessing */);

  /*
   * The CBMC configuration permits malloc failure. Therefore:
   *
   *   successful allocation path -> MLK_ERR_FAIL
   *   allocation failure path    -> MLK_ERR_OUT_OF_MEMORY
   *
   * Returning success is forbidden.
   */
  __CPROVER_assert(
      result == MLK_ERR_FAIL ||
          result == MLK_ERR_OUT_OF_MEMORY,
      "PKCHECK-01B.REJECTION: one non-canonical coefficient cannot be accepted");
}
