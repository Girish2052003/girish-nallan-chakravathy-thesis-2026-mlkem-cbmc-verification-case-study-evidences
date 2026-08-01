/*
 * Expected-failure mutation:
 *
 * Expand the accepted interval downward by one offset:
 *
 *   c = 1073417799.
 *
 * The corrupted claim asserts that this adjacent offset remains correct for
 * every canonical coefficient. CBMC must reject the assertion. The predicted
 * boundary counterexample is u = 2497.
 */

#include <stdint.h>
#include "compress.h"

#define MSG_T5_FIXED_MULTIPLIER ((uint32_t)1290168u)
#define MSG_T5_MUTATED_LOWER_OFFSET ((uint32_t)1073417799u)

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
  int16_t u;

  uint8_t model_bit;
  uint8_t oracle_bit;

  __CPROVER_assume(u >= 0);
  __CPROVER_assume(u < MLKEM_Q);

  model_bit =
      msg_t5_offset_model(
          u,
          MSG_T5_MUTATED_LOWER_OFFSET);

  oracle_bit =
      msg_t5_threshold_oracle(u);

  __CPROVER_assert(
      model_bit == oracle_bit,
      "MSG_T5_LOWER_ENDPOINT_MUTATION: extending the interval downward by one must be rejected");

  return 0;
}
