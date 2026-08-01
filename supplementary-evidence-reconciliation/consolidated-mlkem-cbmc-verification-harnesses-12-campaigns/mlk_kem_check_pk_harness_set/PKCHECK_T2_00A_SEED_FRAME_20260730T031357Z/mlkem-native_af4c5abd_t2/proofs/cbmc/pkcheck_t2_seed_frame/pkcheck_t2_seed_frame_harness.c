#include <cbmc.h>
#include <stddef.h>
#include <stdint.h>

#include "kem.h"
#include "params.h"

#define PKCHECK_T2_REDZONE_BYTES 16u

/*
 * A structure wrapper allows public seeds to be replaced using an ordinary
 * structure assignment. This avoids the unsupported DFCC treatment of
 * __CPROVER_array_equal and introduces no helper loops.
 */
typedef struct
{
  uint8_t bytes[MLKEM_SYMBYTES];
} pkcheck_t2_seed_block;

typedef struct
{
  uint8_t encoded_vector[MLKEM_POLYVECBYTES];
  pkcheck_t2_seed_block public_seed;
} pkcheck_t2_payload;

typedef struct
{
  uint8_t left_redzone[PKCHECK_T2_REDZONE_BYTES];
  pkcheck_t2_payload payload;
  uint8_t right_redzone[PKCHECK_T2_REDZONE_BYTES];
} pkcheck_t2_frame;

_Static_assert(
  sizeof(pkcheck_t2_seed_block) == MLKEM_SYMBYTES,
  "T2 seed-block layout mismatch");

_Static_assert(
  sizeof(pkcheck_t2_payload) == MLKEM_INDCCA_PUBLICKEYBYTES,
  "T2 public-key payload layout mismatch");

_Static_assert(
  offsetof(pkcheck_t2_frame, payload) ==
    PKCHECK_T2_REDZONE_BYTES,
  "T2 left red-zone layout mismatch");

_Static_assert(
  offsetof(pkcheck_t2_frame, right_redzone) ==
    PKCHECK_T2_REDZONE_BYTES +
      MLKEM_INDCCA_PUBLICKEYBYTES,
  "T2 right red-zone layout mismatch");

void harness(void)
{
  pkcheck_t2_frame frame;

  pkcheck_t2_seed_block first_seed;
  pkcheck_t2_seed_block second_seed;

  uint8_t *payload_bytes;

  size_t payload_index;
  size_t redzone_index;
  size_t seed_difference_index;

  uint8_t first_payload_byte_before;
  uint8_t second_payload_byte_before;

  uint8_t left_redzone_before;
  uint8_t right_redzone_before;

  uint8_t left_redzone_after_first;
  uint8_t right_redzone_after_first;

  int first_result;
  int second_result;

  payload_bytes = (uint8_t *)&frame.payload;

  /*
   * A nondeterministic index followed by a range assumption universally
   * represents every byte position across separate CBMC executions.
   */
  __CPROVER_assume(
    payload_index < sizeof(frame.payload));

  __CPROVER_assume(
    redzone_index < PKCHECK_T2_REDZONE_BYTES);

  __CPROVER_assume(
    seed_difference_index < MLKEM_SYMBYTES);

  /*
   * First execution.
   *
   * The encoded polynomial-vector prefix is fully symbolic. The first
   * public seed is independently symbolic.
   */
  frame.payload.public_seed = first_seed;

  first_payload_byte_before =
    payload_bytes[payload_index];

  left_redzone_before =
    frame.left_redzone[redzone_index];

  right_redzone_before =
    frame.right_redzone[redzone_index];

  first_result =
    mlk_kem_check_pk(
      (const uint8_t *)&frame.payload,
      NULL);

  left_redzone_after_first =
    frame.left_redzone[redzone_index];

  right_redzone_after_first =
    frame.right_redzone[redzone_index];

  __CPROVER_assert(
    payload_bytes[payload_index] ==
      first_payload_byte_before,
    "PKCHECK-T2.FIRST_INPUT_FRAME: every byte of the first public-key input is unchanged");

  /*
   * Second execution over the same polynomial-vector prefix.
   *
   * Only the public-seed suffix is replaced. The separately proved first
   * input-frame property establishes that the first target call preserves
   * the shared polynomial-vector prefix.
   */
  frame.payload.public_seed = second_seed;

  second_payload_byte_before =
    payload_bytes[payload_index];

  second_result =
    mlk_kem_check_pk(
      (const uint8_t *)&frame.payload,
      NULL);

  __CPROVER_assert(
    payload_bytes[payload_index] ==
      second_payload_byte_before,
    "PKCHECK-T2.SECOND_INPUT_FRAME: every byte of the second public-key input is unchanged");

  __CPROVER_assert(
    left_redzone_after_first ==
      left_redzone_before &&
    right_redzone_after_first ==
      right_redzone_before &&
    frame.left_redzone[redzone_index] ==
      left_redzone_before &&
    frame.right_redzone[redzone_index] ==
      right_redzone_before,
    "PKCHECK-T2.REDZONE_PRESERVATION: every left and right red-zone byte is unchanged after both calls");

  /*
   * Allocation failure is independently nondeterministic. Therefore,
   * equal decision results are required whenever both executions are
   * non-OOM.
   */
  __CPROVER_assert(
    first_result == MLK_ERR_OUT_OF_MEMORY ||
    second_result == MLK_ERR_OUT_OF_MEMORY ||
    first_result == second_result,
    "PKCHECK-T2.SEED_NONINTERFERENCE: changing only the public-seed suffix cannot change a non-OOM decision");

  /*
   * Non-vacuity witness for the companion coverage run:
   *
   * There exists a public-seed byte position that differs while both
   * target executions complete without allocation failure.
   */
  __CPROVER_cover(
    first_seed.bytes[seed_difference_index] !=
      second_seed.bytes[seed_difference_index] &&
    first_result != MLK_ERR_OUT_OF_MEMORY &&
    second_result != MLK_ERR_OUT_OF_MEMORY);
}
