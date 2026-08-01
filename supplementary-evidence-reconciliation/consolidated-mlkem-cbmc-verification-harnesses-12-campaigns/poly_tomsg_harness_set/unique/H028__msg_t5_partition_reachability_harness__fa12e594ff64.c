#include <stdint.h>
#include "compress.h"

#define MSG_T5_FIXED_MULTIPLIER ((uint32_t)1290168u)
#define MSG_T5_LOWER ((uint32_t)1073417800u)
#define MSG_T5_UPPER ((uint32_t)1074063871u)
#define MSG_T5_LOWER_MINUS_ONE ((uint32_t)1073417799u)
#define MSG_T5_UPPER_PLUS_ONE ((uint32_t)1074063872u)
#define MSG_T5_HIGH_HALF ((uint32_t)2147483648u)
#define MSG_T5_UINT32_MAXIMUM ((uint32_t)0xFFFFFFFFu)

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

  __CPROVER_assume(
      c < MSG_T5_LOWER ||
      c > MSG_T5_UPPER);

  if (c < MSG_T5_LOWER)
  {
    witness_u = 2497;
    witness_region = 1u;
  }
  else if (c < MSG_T5_HIGH_HALF)
  {
    witness_u = 832;
    witness_region = 2u;
  }
  else
  {
    witness_u = 0;
    witness_region = 3u;
  }

  model_bit =
      msg_t5_offset_model(
          witness_u,
          c);

  oracle_bit =
      msg_t5_threshold_oracle(
          witness_u);

  /* Goals 1–3: all three outside partitions are reachable. */
  __CPROVER_cover(c < MSG_T5_LOWER);

  __CPROVER_cover(
      c > MSG_T5_UPPER &&
      c < MSG_T5_HIGH_HALF);

  __CPROVER_cover(
      c >= MSG_T5_HIGH_HALF);

  /* Goals 4–7: exact outside boundary values are reachable. */
  __CPROVER_cover(c == MSG_T5_LOWER_MINUS_ONE);
  __CPROVER_cover(c == MSG_T5_UPPER_PLUS_ONE);
  __CPROVER_cover(c == MSG_T5_HIGH_HALF);
  __CPROVER_cover(c == MSG_T5_UINT32_MAXIMUM);

  /* Goals 8–10: each witness region reaches a real disagreement. */
  __CPROVER_cover(
      witness_region == 1u &&
      witness_u == 2497 &&
      model_bit != oracle_bit);

  __CPROVER_cover(
      witness_region == 2u &&
      witness_u == 832 &&
      model_bit != oracle_bit);

  __CPROVER_cover(
      witness_region == 3u &&
      witness_u == 0 &&
      model_bit != oracle_bit);

  return 0;
}
