#include <stdint.h>
#include <limits.h>
#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_Q ((int64_t)MLKEM_Q)
#define DOMAIN_LIMIT ((int64_t)INT32_MAX - (((int64_t)1 << 15) * (int64_t)MLKEM_Q))

extern int32_t nondet_int32_t(void);

static int64_t low_word(int32_t x)
{
  int64_t r = (int64_t)x % MONT_R;
  if (r < 0)
  {
    r += MONT_R;
  }
  return r;
}

void harness(void)
{
  int32_t a = nondet_int32_t();
  int32_t b = nondet_int32_t();
  int16_t ra;
  int16_t rb;
  int64_t la;
  int64_t lb;
  int64_t in_delta;
  int64_t out_delta;

  __CPROVER_assume((int64_t)a < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)a > -DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b > -DOMAIN_LIMIT);

  ra = mlk_montgomery_reduce(a);
  rb = mlk_montgomery_reduce(b);

  la = low_word(a);
  lb = low_word(b);
  in_delta = (int64_t)b - (int64_t)a;
  out_delta = (int64_t)rb - (int64_t)ra;

  __CPROVER_assert(
      la >= 0 && la < MONT_R,
      "MONT-T2A.P1.first_low_word_normalized");

  __CPROVER_assert(
      lb >= 0 && lb < MONT_R,
      "MONT-T2A.P2.second_low_word_normalized");

  __CPROVER_assert(
      ((out_delta * MONT_R - in_delta) % MONT_Q) == 0,
      "MONT-T2A.P3.arbitrary_pair_scaled_congruence");

  if (la == lb)
  {
    __CPROVER_assert(
        in_delta % MONT_R == 0,
        "MONT-T2A.P4.same_low_word_input_delta_divisible_by_R");

    __CPROVER_assert(
        out_delta == in_delta / MONT_R,
        "MONT-T2A.P5.same_low_word_exact_output_delta");

    __CPROVER_assert(
        (((int64_t)ra == (int64_t)rb) == (a == b)),
        "MONT-T2A.P6.same_fibre_injectivity");

    /* C1_CONTROL */
  }
}
