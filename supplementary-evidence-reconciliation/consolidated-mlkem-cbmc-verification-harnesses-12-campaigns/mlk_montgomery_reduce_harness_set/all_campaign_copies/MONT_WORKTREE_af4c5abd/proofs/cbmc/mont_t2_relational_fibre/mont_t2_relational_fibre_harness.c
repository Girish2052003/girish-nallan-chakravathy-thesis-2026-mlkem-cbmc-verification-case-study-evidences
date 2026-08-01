#include <stdint.h>
#include <limits.h>

#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_Q ((int64_t)MLKEM_Q)
#define MONT_DOMAIN_LIMIT                                                   \
  ((int64_t)INT32_MAX - (((int64_t)1 << 15) * (int64_t)MLKEM_Q))

extern int32_t nondet_int32_t(void);

static int64_t mont_canonical_low_word(int32_t value)
{
  int64_t low;

  low = (int64_t)value % MONT_R;

  if (low < 0)
  {
    low += MONT_R;
  }

  return low;
}

void harness(void)
{
  int32_t first;
  int32_t second;
  int16_t first_result;
  int16_t second_result;
  int64_t first_low;
  int64_t second_low;
  int64_t input_delta;
  int64_t output_delta;

  int32_t base;
  int32_t fibre_shift;
  int64_t shifted_value_wide;
  int32_t shifted_value;
  int16_t base_result;
  int16_t shifted_result;

  first = nondet_int32_t();
  second = nondet_int32_t();

  __CPROVER_assume((int64_t)first < MONT_DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)first > -MONT_DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)second < MONT_DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)second > -MONT_DOMAIN_LIMIT);

  first_result = mlk_montgomery_reduce(first);
  second_result = mlk_montgomery_reduce(second);

  first_low = mont_canonical_low_word(first);
  second_low = mont_canonical_low_word(second);

  __CPROVER_assert(
      first_low >= 0 && first_low < MONT_R,
      "MONT-T2.P1.first_low_word_normalized");

  __CPROVER_assert(
      second_low >= 0 && second_low < MONT_R,
      "MONT-T2.P1.second_low_word_normalized");

  input_delta =
      (int64_t)second - (int64_t)first;

  output_delta =
      (int64_t)second_result - (int64_t)first_result;

  __CPROVER_assert(
      ((output_delta * MONT_R - input_delta) % MONT_Q) == 0,
      "MONT-T2.P2.relational_scaled_residue_congruence");

  if (first_low == second_low)
  {
    __CPROVER_assert(
        input_delta % MONT_R == 0,
        "MONT-T2.P3.same_low_word_delta_divisible_by_R");

    __CPROVER_assert(
        output_delta == input_delta / MONT_R,
        "MONT-T2.P3.same_low_word_exact_affine_output_difference");

    __CPROVER_assert(
        (((int64_t)first_result == (int64_t)second_result) ==
         (first == second)),
        "MONT-T2.P4.same_fibre_output_injectivity");

    /* MONT_T2_CONTROL_SAME_FIBRE */
  }

  base = nondet_int32_t();
  fibre_shift = nondet_int32_t();

  __CPROVER_assume((int64_t)base < MONT_DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)base > -MONT_DOMAIN_LIMIT);

  shifted_value_wide =
      (int64_t)base +
      ((int64_t)fibre_shift * MONT_R);

  __CPROVER_assume(
      shifted_value_wide < MONT_DOMAIN_LIMIT);

  __CPROVER_assume(
      shifted_value_wide > -MONT_DOMAIN_LIMIT);

  shifted_value = (int32_t)shifted_value_wide;

  base_result =
      mlk_montgomery_reduce(base);

  shifted_result =
      mlk_montgomery_reduce(shifted_value);

  __CPROVER_assert(
      mont_canonical_low_word(base) ==
          mont_canonical_low_word(shifted_value),
      "MONT-T2.P5.shifted_input_remains_same_low_word");

  __CPROVER_assert(
      (int64_t)shifted_result ==
          (int64_t)base_result +
              (int64_t)fibre_shift,
      "MONT-T2.P5.general_R_fibre_translation");

  /* MONT_T2_CONTROL_SHIFT_PATH */
}
