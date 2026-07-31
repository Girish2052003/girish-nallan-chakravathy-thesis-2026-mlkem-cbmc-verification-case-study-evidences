#include <cbmc.h>
#include <stddef.h>
#include <stdint.h>

#include "kem.h"
#include "params.h"

#define PKCHECK_T2_REDZONE_BYTES 16u

/*
 * ML-KEM public-key layout:
 *
 *   encoded polynomial-vector prefix || public-seed suffix
 *
 * All fields have byte alignment. The static assertions bind the harness
 * representation to the repository parameter macros.
 */
typedef struct
{
  uint8_t encoded_vector[MLKEM_POLYVECBYTES];
  uint8_t public_seed[MLKEM_SYMBYTES];
} pkcheck_t2_payload;

typedef struct
{
  uint8_t left_redzone[PKCHECK_T2_REDZONE_BYTES];
  pkcheck_t2_payload payload;
  uint8_t right_redzone[PKCHECK_T2_REDZONE_BYTES];
} pkcheck_t2_frame;

_Static_assert(
  sizeof(pkcheck_t2_payload) == MLKEM_INDCCA_PUBLICKEYBYTES,
  "T2 public-key payload layout mismatch");

_Static_assert(
  offsetof(pkcheck_t2_frame, payload) == PKCHECK_T2_REDZONE_BYTES,
  "T2 left red-zone layout mismatch");

_Static_assert(
  offsetof(pkcheck_t2_frame, right_redzone) ==
    PKCHECK_T2_REDZONE_BYTES + MLKEM_INDCCA_PUBLICKEYBYTES,
  "T2 right red-zone layout mismatch");

void harness(void)
{
  pkcheck_t2_frame first;
  pkcheck_t2_frame second;

  pkcheck_t2_frame first_before;
  pkcheck_t2_frame second_before;

  int first_result;
  int second_result;

  /*
   * Permitted relational input assumption:
   *
   * Both public keys have exactly the same encoded polynomial-vector
   * prefix. Their public-seed suffixes remain independently symbolic.
   *
   * This assumption constrains only the theorem's input relation. It
   * does not constrain either function result.
   */
  __CPROVER_assume(
    __CPROVER_array_equal(
      first.payload.encoded_vector,
      second.payload.encoded_vector));

  first_before = first;
  second_before = second;

  first_result =
    mlk_kem_check_pk(
      (const uint8_t *)&first.payload,
      NULL);

  second_result =
    mlk_kem_check_pk(
      (const uint8_t *)&second.payload,
      NULL);

  /*
   * Allocation failure is independently nondeterministic for the two
   * calls. Therefore semantic equality is required whenever both actual
   * executions complete their allocations.
   */
  __CPROVER_assert(
    first_result == MLK_ERR_OUT_OF_MEMORY ||
    second_result == MLK_ERR_OUT_OF_MEMORY ||
    first_result == second_result,
    "PKCHECK-T2.SEED_NONINTERFERENCE: equal polynomial prefixes imply equal non-OOM decisions for arbitrary public seeds");

  __CPROVER_assert(
    __CPROVER_array_equal(
      first.payload.encoded_vector,
      first_before.payload.encoded_vector) &&
    __CPROVER_array_equal(
      first.payload.public_seed,
      first_before.payload.public_seed),
    "PKCHECK-T2.FIRST_INPUT_FRAME: first public key is unchanged");

  __CPROVER_assert(
    __CPROVER_array_equal(
      second.payload.encoded_vector,
      second_before.payload.encoded_vector) &&
    __CPROVER_array_equal(
      second.payload.public_seed,
      second_before.payload.public_seed),
    "PKCHECK-T2.SECOND_INPUT_FRAME: second public key is unchanged");

  __CPROVER_assert(
    __CPROVER_array_equal(
      first.left_redzone,
      first_before.left_redzone) &&
    __CPROVER_array_equal(
      first.right_redzone,
      first_before.right_redzone) &&
    __CPROVER_array_equal(
      second.left_redzone,
      second_before.left_redzone) &&
    __CPROVER_array_equal(
      second.right_redzone,
      second_before.right_redzone),
    "PKCHECK-T2.REDZONE_PRESERVATION: all public-key red zones are unchanged");

  /*
   * Non-vacuity witnesses for the later coverage run:
   *
   * 1. Different public seeds are reachable.
   * 2. Different public seeds with two non-OOM executions are reachable.
   */
  __CPROVER_cover(
    !__CPROVER_array_equal(
      first.payload.public_seed,
      second.payload.public_seed));

  __CPROVER_cover(
    !__CPROVER_array_equal(
      first.payload.public_seed,
      second.payload.public_seed) &&
    first_result != MLK_ERR_OUT_OF_MEMORY &&
    second_result != MLK_ERR_OUT_OF_MEMORY);
}
