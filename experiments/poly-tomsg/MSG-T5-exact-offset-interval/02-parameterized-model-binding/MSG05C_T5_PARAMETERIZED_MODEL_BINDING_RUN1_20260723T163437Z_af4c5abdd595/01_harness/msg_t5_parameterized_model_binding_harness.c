/*
 * MSG-T5 model-binding theorem.
 *
 * The real frozen helper computes:
 *
 *   d0 = uint32(u * 1290168)
 *   return uint8((d0 + 2^30) >> 31)
 *
 * where uint32 addition uses modulo-2^32 semantics.
 *
 * The evidence-local model below replaces only the offset 2^30 with a
 * parameter c. This stage sets c back to 2^30 and proves that the model equals:
 *
 *   1. the real frozen mlk_scalar_compress_d1 helper; and
 *   2. the selected output bit of the real frozen mlk_poly_tomsg function.
 *
 * This stage does not yet prove interval sufficiency or necessity.
 */

#include <stdint.h>
#include "compress.h"

#define MSG_T5_FIXED_MULTIPLIER ((uint32_t)1290168u)
#define MSG_T5_PRODUCTION_OFFSET ((uint32_t)1073741824u)
#define MSG_T5_ADMISSIBLE_LOWER ((uint32_t)1073417800u)
#define MSG_T5_ADMISSIBLE_UPPER ((uint32_t)1074063871u)

/*
 * Source-faithful parameterized model.
 *
 * uint64_t intermediates and an explicit low-32-bit mask express the same
 * modulo-2^32 behavior without relying on implicit unsigned overflow in this
 * evidence-local helper.
 */
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

int main(void)
{
  mlk_poly input;

  uint8_t msg[MLKEM_INDCPA_MSGBYTES];

  unsigned i;
  unsigned k;

  uint8_t model_bit;
  uint8_t helper_bit;
  uint8_t tomsg_bit;

  __CPROVER_assert(
      MLKEM_N == 256,
      "MSG_T5_MODEL_CONFIGURATION: polynomial degree must be 256");

  __CPROVER_assert(
      MLKEM_INDCPA_MSGBYTES == 32,
      "MSG_T5_MODEL_CONFIGURATION: message size must be 32 bytes");

  __CPROVER_assert(
      MSG_T5_ADMISSIBLE_LOWER <= MSG_T5_PRODUCTION_OFFSET &&
      MSG_T5_PRODUCTION_OFFSET <= MSG_T5_ADMISSIBLE_UPPER,
      "MSG_T5_PRODUCTION_MEMBERSHIP: production offset must lie in the derived interval");

  __CPROVER_assume(k < MLKEM_N);

  /*
   * The complete canonical polynomial domain remains symbolic.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);
  }

  /*
   * Evaluate the parameterized evidence-local model at the real production
   * offset.
   */
  model_bit =
      msg_t5_offset_model(
          input.coeffs[k],
          MSG_T5_PRODUCTION_OFFSET);

  /*
   * Independently call the real frozen scalar helper.
   */
  helper_bit =
      mlk_scalar_compress_d1(
          input.coeffs[k]);

  /*
   * Execute the real frozen production mlk_poly_tomsg implementation.
   */
  mlk_poly_tomsg(msg, &input);

  tomsg_bit =
      (uint8_t)(
          (msg[k >> 3] >> (k & 7u)) &
          1u);

  __CPROVER_assert(
      model_bit == helper_bit,
      "MSG_T5_MODEL_HELPER_BINDING: parameterized model at 2^30 must equal the real scalar helper");

  __CPROVER_assert(
      model_bit == tomsg_bit,
      "MSG_T5_MODEL_TOMSG_BINDING: parameterized model at 2^30 must equal the real tomsg output bit");

  return 0;
}
