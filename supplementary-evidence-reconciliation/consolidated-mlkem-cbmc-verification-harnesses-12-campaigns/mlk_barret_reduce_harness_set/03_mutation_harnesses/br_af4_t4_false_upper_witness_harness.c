#include <stdint.h>
#include <limits.h>

extern int16_t nondet_int16_t(void);
extern int32_t nondet_int32_t(void);

int16_t mlk_barrett_reduce(int16_t a);

static int32_t br_af4_centered_oracle(int16_t a)
{
  int32_t value = ((int32_t)a) % 3329;

  if (value < 0)
  {
    value += 3329;
  }

  if (value > 1664)
  {
    value -= 3329;
  }

  return value;
}

static int64_t br_af4_candidate_numerator(
    int32_t multiplier,
    int16_t a)
{
  return
      (int64_t)multiplier * (int64_t)a +
      ((int64_t)1 << 25);
}

static int64_t br_af4_candidate_quotient(
    int32_t multiplier,
    int16_t a)
{
  return
      br_af4_candidate_numerator(multiplier, a)
      >> 26;
}

static int64_t br_af4_candidate_result(
    int32_t multiplier,
    int16_t a)
{
  return
      (int64_t)a -
      br_af4_candidate_quotient(multiplier, a)
          * 3329;
}

void harness(void)
{
  int16_t a = nondet_int16_t();
  int32_t multiplier = nondet_int32_t();

  int multiplier_is_numerator_safe =
      multiplier >= 0 &&
      multiplier <= 64513;

  int multiplier_is_below_production =
      multiplier >= 0 &&
      multiplier < 20159;

  int multiplier_is_above_production =
      multiplier > 20159 &&
      multiplier <= 64513;

  int64_t symbolic_numerator =
      br_af4_candidate_numerator(multiplier, a);

  int64_t symbolic_wide_shift =
      symbolic_numerator >> 26;

  int64_t candidate_at_production_multiplier =
      br_af4_candidate_result(20159, a);

  int32_t centered =
      br_af4_centered_oracle(a);

  int16_t production_result =
      mlk_barrett_reduce(a);

  int64_t lower_witness_candidate =
      br_af4_candidate_result(
          multiplier,
          (int16_t)-31626);

  int64_t upper_witness_candidate =
      br_af4_candidate_result(
          multiplier,
          (int16_t)-31626);

  int64_t lower_witness_expected =
      br_af4_centered_oracle(
          (int16_t)-31626);

  int64_t upper_witness_expected =
      br_af4_centered_oracle(
          (int16_t)-31626);

  /*
   * The cast and int32 shift are reached only after the representability
   * condition, due to C short-circuit evaluation.
   */
  __CPROVER_assert(
      !multiplier_is_numerator_safe ||
      (
        symbolic_numerator >= INT32_MIN &&
        symbolic_numerator <= INT32_MAX &&
        symbolic_wide_shift ==
          (int64_t)(
            ((int32_t)symbolic_numerator) >> 26)
      ),
      "BR-AF4-T4.P14 complete numerator-safe multiplier domain");

  __CPROVER_assert(
      candidate_at_production_multiplier ==
        (int64_t)centered &&
      (int64_t)production_result ==
        candidate_at_production_multiplier,
      "BR-AF4-T4.P15 production multiplier full-domain sufficiency and binding");

  __CPROVER_assert(
      !multiplier_is_below_production ||
      lower_witness_candidate !=
        lower_witness_expected,
      "BR-AF4-T4.P16 every smaller safe multiplier rejected");

  __CPROVER_assert(
      !multiplier_is_above_production ||
      upper_witness_candidate !=
        upper_witness_expected,
      "BR-AF4-T4.P17 every larger safe multiplier rejected");

  __CPROVER_assert(
      !multiplier_is_numerator_safe ||
      (
        (
          lower_witness_candidate ==
            lower_witness_expected &&
          upper_witness_candidate ==
            upper_witness_expected
        ) ==
        (multiplier == 20159)
      ),
      "BR-AF4-T4.P18 two-witness uniqueness of multiplier 20159");
}
