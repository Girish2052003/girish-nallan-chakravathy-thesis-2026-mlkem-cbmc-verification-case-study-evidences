#include <stdint.h>
#include <limits.h>

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

static int64_t br_af4_offset_candidate_result(
    int32_t offset,
    int16_t a)
{
  int64_t quotient =
      br_af4_offset_numerator(
          offset,
          a)
      >> 26;

  return
      (int64_t)a -
      quotient * INT64_C(3329);
}

void harness(void)
{
  __CPROVER_assert(
      br_af4_offset_candidate_result(
          33548598,
          (int16_t)-31625) == 1665,
      "BR-AF4-C5.1 lower outside offset rejected");

  __CPROVER_assert(
      br_af4_offset_candidate_result(
          33548599,
          (int16_t)-31625) == -1664,
      "BR-AF4-C5.2 lower admissible endpoint");

  __CPROVER_assert(
      br_af4_offset_candidate_result(
          33560264,
          (int16_t)31625) == 1664,
      "BR-AF4-C5.3 upper admissible endpoint");

  __CPROVER_assert(
      br_af4_offset_candidate_result(
          33560265,
          (int16_t)31625) == -1665,
      "BR-AF4-C5.4 upper outside offset rejected");

  __CPROVER_assert(
      br_af4_offset_candidate_result(
          33554432,
          (int16_t)-31625) == -1664,
      "BR-AF4-C5.5 production offset lower witness");

  __CPROVER_assert(
      br_af4_offset_candidate_result(
          33554432,
          (int16_t)31625) == 1664,
      "BR-AF4-C5.6 production offset upper witness");

  __CPROVER_assert(
      33554432 - 33548599 == 5833,
      "BR-AF4-C5.7 production lower robustness margin");

  __CPROVER_assert(
      33560264 - 33554432 == 5832,
      "BR-AF4-C5.8 production upper robustness margin");

  __CPROVER_assert(
      33560264 - 33548599 + 1 == 11666,
      "BR-AF4-C5.9 admissible offset count");

  __CPROVER_assert(
      br_af4_offset_numerator(
          0,
          INT16_MIN) ==
        INT64_C(-660570112) &&
      br_af4_offset_numerator(
          0,
          INT16_MIN) >= INT32_MIN,
      "BR-AF4-C5.10 minimum design-domain numerator");

  __CPROVER_assert(
      br_af4_offset_numerator(
          67108863,
          INT16_MAX) ==
        INT64_C(727658816) &&
      br_af4_offset_numerator(
          67108863,
          INT16_MAX) <= INT32_MAX,
      "BR-AF4-C5.11 maximum design-domain numerator");

  __CPROVER_assert(
      (int64_t)mlk_barrett_reduce(
          INT16_MIN) ==
        br_af4_offset_candidate_result(
          33554432,
          INT16_MIN) &&
      mlk_barrett_reduce(
          INT16_MIN) == 522 &&
      (int64_t)mlk_barrett_reduce(
          INT16_MAX) ==
        br_af4_offset_candidate_result(
          33554432,
          INT16_MAX) &&
      mlk_barrett_reduce(
          INT16_MAX) == -523,
      "BR-AF4-C5.12 production binding at int16 endpoints");
}
