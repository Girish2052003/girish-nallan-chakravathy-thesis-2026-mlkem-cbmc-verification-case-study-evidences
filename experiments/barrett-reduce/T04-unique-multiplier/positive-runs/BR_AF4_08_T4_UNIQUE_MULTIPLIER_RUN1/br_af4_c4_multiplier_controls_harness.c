#include <stdint.h>
#include <limits.h>

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

static int64_t br_af4_candidate_result(
    int32_t multiplier,
    int16_t a)
{
  int64_t quotient =
      br_af4_candidate_numerator(multiplier, a)
      >> 26;

  return (int64_t)a - quotient * 3329;
}

void harness(void)
{
  __CPROVER_assert(
      br_af4_candidate_result(0, (int16_t)-31626) !=
        br_af4_centered_oracle((int16_t)-31626),
      "BR-AF4-C4.1 multiplier zero is rejected");

  __CPROVER_assert(
      br_af4_candidate_result(20158, (int16_t)-31626) == -1665,
      "BR-AF4-C4.2 multiplier 20158 lower witness");

  __CPROVER_assert(
      br_af4_candidate_result(20159, (int16_t)-31626) == 1664,
      "BR-AF4-C4.3 multiplier 20159 lower witness");

  __CPROVER_assert(
      br_af4_candidate_result(20159, (int16_t)-31625) == -1664,
      "BR-AF4-C4.4 multiplier 20159 upper witness");

  __CPROVER_assert(
      br_af4_candidate_result(20160, (int16_t)-31625) == 1665,
      "BR-AF4-C4.5 multiplier 20160 upper witness");

  __CPROVER_assert(
      br_af4_candidate_result(64513, (int16_t)-31625) == 68245,
      "BR-AF4-C4.6 maximum safe multiplier is rejected");

  __CPROVER_assert(
      br_af4_candidate_numerator(64513, INT16_MAX) ==
        INT64_C(2147451903) &&
      br_af4_candidate_numerator(64513, INT16_MAX) <=
        INT32_MAX,
      "BR-AF4-C4.7 multiplier 64513 numerator boundary");

  __CPROVER_assert(
      br_af4_candidate_numerator(64514, INT16_MAX) ==
        INT64_C(2147484670) &&
      br_af4_candidate_numerator(64514, INT16_MAX) >
        INT32_MAX,
      "BR-AF4-C4.8 multiplier 64514 is outside safe domain");

  __CPROVER_assert(
      (int64_t)mlk_barrett_reduce(INT16_MIN) ==
        br_af4_candidate_result(20159, INT16_MIN) &&
      mlk_barrett_reduce(INT16_MIN) == 522,
      "BR-AF4-C4.9 production binding at INT16_MIN");

  __CPROVER_assert(
      (int64_t)mlk_barrett_reduce(INT16_MAX) ==
        br_af4_candidate_result(20159, INT16_MAX) &&
      mlk_barrett_reduce(INT16_MAX) == -523,
      "BR-AF4-C4.10 production binding at INT16_MAX");
}
