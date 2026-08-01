/*
 * MSG-T5 exact admissible-offset interval — necessity theorem.
 *
 * Let c be an arbitrary uint32 offset outside:
 *
 *   [1073417800, 1074063871].
 *
 * This harness chooses a canonical counterexample coefficient according to the
 * complete outside-domain partition:
 *
 *   Region 1: 0 <= c < 1073417800
 *             witness u = 2497
 *
 *   Region 2: 1074063871 < c < 2^31
 *             witness u = 832
 *
 *   Region 3: 2^31 <= c <= UINT32_MAX
 *             witness u = 0
 *
 * It proves that the source-faithful parameterized model disagrees with the
 * independent canonical threshold oracle for the chosen witness.
 *
 * Together with MSG05D sufficiency, this proves exactness of the closed
 * admissible interval. Reachability and boundary-mutation hardening remain
 * separate later stages.
 */

#include <stdint.h>
#include "compress.h"

#define MSG_T5_FIXED_MULTIPLIER ((uint32_t)1290168u)
#define MSG_T5_ADMISSIBLE_LOWER ((uint32_t)1073417800u)
#define MSG_T5_ADMISSIBLE_UPPER ((uint32_t)1074063871u)
#define MSG_T5_UINT32_HIGH_HALF ((uint32_t)2147483648u)

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

static uint8_t msg_t5_threshold_oracle(int16_t u)
{
  return (uint8_t)((u >= 833) && (u <= 2496));
}

int main(void)
{
  uint32_t c;

  int16_t witness_u;
  uint8_t witness_region;

  uint8_t model_bit;
  uint8_t oracle_bit;

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "MSG_T5_NECESSITY_CONFIGURATION: MLKEM_Q must be 3329");

  __CPROVER_assert(
      MSG_T5_ADMISSIBLE_LOWER <= MSG_T5_ADMISSIBLE_UPPER,
      "MSG_T5_NECESSITY_INTERVAL_ORDER: lower endpoint must not exceed upper endpoint");

  __CPROVER_assert(
      MSG_T5_ADMISSIBLE_UPPER < MSG_T5_UINT32_HIGH_HALF,
      "MSG_T5_NECESSITY_PARTITION_ORDER: upper endpoint must lie below the uint32 high half");

  /*
   * Universal uint32 offset outside the candidate interval.
   */
  __CPROVER_assume(
      c < MSG_T5_ADMISSIBLE_LOWER ||
      c > MSG_T5_ADMISSIBLE_UPPER);

  if (c < MSG_T5_ADMISSIBLE_LOWER)
  {
    witness_u = 2497;
    witness_region = 1u;
  }
  else if (c < MSG_T5_UINT32_HIGH_HALF)
  {
    witness_u = 832;
    witness_region = 2u;
  }
  else
  {
    witness_u = 0;
    witness_region = 3u;
  }

  __CPROVER_assert(
      witness_u >= 0 &&
      witness_u < MLKEM_Q,
      "MSG_T5_NECESSITY_WITNESS_DOMAIN: selected witness must be canonical");

  __CPROVER_assert(
      (witness_region == 1u &&
       c < MSG_T5_ADMISSIBLE_LOWER) ||
      (witness_region == 2u &&
       c > MSG_T5_ADMISSIBLE_UPPER &&
       c < MSG_T5_UINT32_HIGH_HALF) ||
      (witness_region == 3u &&
       c >= MSG_T5_UINT32_HIGH_HALF),
      "MSG_T5_NECESSITY_PARTITION_COMPLETE: every outside offset must enter exactly one witness region");

  model_bit =
      msg_t5_offset_model(
          witness_u,
          c);

  oracle_bit =
      msg_t5_threshold_oracle(
          witness_u);

  __CPROVER_assert(
      model_bit < 2u &&
      oracle_bit < 2u,
      "MSG_T5_NECESSITY_BIT_RANGE: model and oracle outputs must be bits");

  __CPROVER_assert(
      model_bit != oracle_bit,
      "MSG_T5_OUTSIDE_INTERVAL_NECESSITY: every uint32 offset outside the derived interval must have a canonical counterexample");

  return 0;
}
