/*
 * MSG-T5 exact admissible-offset interval — sufficiency theorem.
 *
 * For every canonical coefficient:
 *
 *   0 <= u <= 3328
 *
 * and every uint32 offset in the derived closed interval:
 *
 *   1073417800 <= c <= 1074063871
 *
 * prove that the source-faithful parameterized model equals the independent
 * canonical threshold oracle:
 *
 *   oracle(u) = 1 iff 833 <= u <= 2496.
 *
 * The parameterized model was formally bound to the real frozen scalar helper
 * and the real frozen mlk_poly_tomsg output bit at c = 2^30 in MSG05C.
 *
 * This stage proves interval sufficiency. It does not yet prove that every
 * offset outside the interval is inadmissible.
 */

#include <stdint.h>
#include "compress.h"

#define MSG_T5_FIXED_MULTIPLIER ((uint32_t)1290168u)
#define MSG_T5_ADMISSIBLE_LOWER ((uint32_t)1073417800u)
#define MSG_T5_ADMISSIBLE_UPPER ((uint32_t)1074063871u)
#define MSG_T5_ADMISSIBLE_COUNT ((uint32_t)646072u)
#define MSG_T5_PRODUCTION_OFFSET ((uint32_t)1073741824u)

static uint8_t msg_t5_offset_model(int16_t u, uint32_t c)
{
  uint64_t product;
  uint32_t d0;
  uint64_t wide_sum;
  uint32_t wrapped_sum;

  product =
      (uint64_t)(uint32_t)u *
      (uint64_t)MSG_T5_FIXED_MULTIPLIER;

  d0 =
      (uint32_t)(
          product &
          (uint64_t)0xFFFFFFFFu);

  wide_sum =
      (uint64_t)d0 +
      (uint64_t)c;

  wrapped_sum =
      (uint32_t)(
          wide_sum &
          (uint64_t)0xFFFFFFFFu);

  return (uint8_t)(wrapped_sum >> 31);
}

/*
 * Independent semantic oracle already established for the canonical domain:
 *
 *   output bit = 1 iff 833 <= u <= 2496.
 *
 * It does not call the parameterized model, the scalar helper or poly_tomsg.
 */
static uint8_t msg_t5_threshold_oracle(int16_t u)
{
  return (uint8_t)((u >= 833) && (u <= 2496));
}

int main(void)
{
  int16_t u;
  uint32_t c;

  uint8_t model_bit;
  uint8_t oracle_bit;

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "MSG_T5_SUFFICIENCY_CONFIGURATION: MLKEM_Q must be 3329");

  __CPROVER_assert(
      MSG_T5_ADMISSIBLE_LOWER <= MSG_T5_ADMISSIBLE_UPPER,
      "MSG_T5_SUFFICIENCY_INTERVAL_ORDER: lower endpoint must not exceed upper endpoint");

  __CPROVER_assert(
      ((uint64_t)MSG_T5_ADMISSIBLE_UPPER -
       (uint64_t)MSG_T5_ADMISSIBLE_LOWER +
       (uint64_t)1u) ==
          (uint64_t)MSG_T5_ADMISSIBLE_COUNT,
      "MSG_T5_SUFFICIENCY_CARDINALITY: closed interval must contain exactly 646072 offsets");

  __CPROVER_assert(
      MSG_T5_ADMISSIBLE_LOWER <= MSG_T5_PRODUCTION_OFFSET &&
      MSG_T5_PRODUCTION_OFFSET <= MSG_T5_ADMISSIBLE_UPPER,
      "MSG_T5_SUFFICIENCY_PRODUCTION_MEMBERSHIP: production offset must belong to the interval");

  /*
   * Universal canonical coefficient and universal admissible offset.
   */
  __CPROVER_assume(u >= 0);
  __CPROVER_assume(u < MLKEM_Q);

  __CPROVER_assume(c >= MSG_T5_ADMISSIBLE_LOWER);
  __CPROVER_assume(c <= MSG_T5_ADMISSIBLE_UPPER);

  model_bit =
      msg_t5_offset_model(u, c);

  oracle_bit =
      msg_t5_threshold_oracle(u);

  __CPROVER_assert(
      model_bit < 2u,
      "MSG_T5_SUFFICIENCY_MODEL_RANGE: model result must be one bit");

  __CPROVER_assert(
      oracle_bit < 2u,
      "MSG_T5_SUFFICIENCY_ORACLE_RANGE: oracle result must be one bit");

  __CPROVER_assert(
      model_bit == oracle_bit,
      "MSG_T5_INTERVAL_SUFFICIENCY: every offset in the derived closed interval must match the canonical threshold oracle");

  return 0;
}
