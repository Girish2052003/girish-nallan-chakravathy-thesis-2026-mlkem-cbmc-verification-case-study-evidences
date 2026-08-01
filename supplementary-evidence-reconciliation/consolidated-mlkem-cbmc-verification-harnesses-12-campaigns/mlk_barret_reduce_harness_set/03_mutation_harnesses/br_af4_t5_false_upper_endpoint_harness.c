#include <stdint.h>
#include <limits.h>

extern int16_t nondet_int16_t(void);
extern int32_t nondet_int32_t(void);

int16_t mlk_barrett_reduce(int16_t a);

static int32_t br_af4_centered_oracle(
    int16_t a)
{
  int32_t value =
      ((int32_t)a) % 3329;

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

static int64_t br_af4_offset_numerator(
    int32_t offset,
    int16_t a)
{
  return
      INT64_C(20159) * (int64_t)a +
      (int64_t)offset;
}

static int64_t br_af4_offset_quotient(
    int32_t offset,
    int16_t a)
{
  return
      br_af4_offset_numerator(
          offset,
          a)
      >> 26;
}

static int64_t br_af4_offset_candidate_result(
    int32_t offset,
    int16_t a)
{
  return
      (int64_t)a -
      br_af4_offset_quotient(
          offset,
          a) *
      INT64_C(3329);
}

void harness(void)
{
  int16_t a =
      nondet_int16_t();

  int32_t offset =
      nondet_int32_t();

  int offset_is_in_design_domain =
      offset >= 0 &&
      offset <= 67108863;

  int offset_is_admissible =
      offset >= 33548599 &&
      offset <= 33560264;

  int offset_is_below_interval =
      offset >= 0 &&
      offset < 33548599;

  int offset_is_above_interval =
      offset > 33560264 &&
      offset <= 67108863;

  int64_t symbolic_numerator =
      br_af4_offset_numerator(
          offset,
          a);

  int64_t symbolic_wide_shift =
      symbolic_numerator >> 26;

  int32_t centered =
      br_af4_centered_oracle(a);

  int64_t candidate =
      br_af4_offset_candidate_result(
          offset,
          a);

  int64_t lower_witness_candidate =
      br_af4_offset_candidate_result(
          offset,
          (int16_t)-31625);

  int64_t upper_witness_candidate =
      br_af4_offset_candidate_result(
          offset,
          (int16_t)31625);

  int64_t lower_witness_expected =
      br_af4_centered_oracle(
          (int16_t)-31625);

  int64_t upper_witness_expected =
      br_af4_centered_oracle(
          (int16_t)31625);

  int64_t production_offset_candidate =
      br_af4_offset_candidate_result(
          33554432,
          a);

  int16_t production_result =
      mlk_barrett_reduce(a);

  __CPROVER_assert(
      !offset_is_in_design_domain ||
      (
        symbolic_numerator >= INT32_MIN &&
        symbolic_numerator <= INT32_MAX &&
        symbolic_wide_shift ==
          (int64_t)(
            ((int32_t)symbolic_numerator)
            >> 26)
      ),
      "BR-AF4-T5.P19 complete offset-domain numerator safety");

  __CPROVER_assert(
      !(offset >= 33548599 &&
        offset <= 33560265) ||
      candidate == (int64_t)centered,
      "BR-AF4-T5.P20 admissible interval full-domain sufficiency");

  __CPROVER_assert(
      !offset_is_below_interval ||
      lower_witness_candidate !=
        lower_witness_expected,
      "BR-AF4-T5.P21 every lower offset rejected");

  __CPROVER_assert(
      !offset_is_above_interval ||
      upper_witness_candidate !=
        upper_witness_expected,
      "BR-AF4-T5.P22 every upper offset rejected");

  __CPROVER_assert(
      !offset_is_in_design_domain ||
      (
        (
          lower_witness_candidate ==
            lower_witness_expected &&
          upper_witness_candidate ==
            upper_witness_expected
        ) ==
        offset_is_admissible
      ),
      "BR-AF4-T5.P23 exact two-witness interval characterization");

  __CPROVER_assert(
      production_offset_candidate ==
        (int64_t)centered &&
      (int64_t)production_result ==
        production_offset_candidate,
      "BR-AF4-T5.P24 production offset full-domain sufficiency and binding");
}
