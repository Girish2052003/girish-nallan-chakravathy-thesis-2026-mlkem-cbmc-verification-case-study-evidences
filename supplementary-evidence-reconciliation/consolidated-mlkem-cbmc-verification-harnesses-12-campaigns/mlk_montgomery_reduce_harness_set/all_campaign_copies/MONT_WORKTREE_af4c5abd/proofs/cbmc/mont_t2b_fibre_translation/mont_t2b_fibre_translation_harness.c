#include <stdint.h>
#include <limits.h>
#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
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
  int32_t k = nondet_int32_t();
  int64_t b_wide;
  int32_t b;
  int16_t ra;
  int16_t rb;
  int64_t out_delta;

  __CPROVER_assume((int64_t)a < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)a > -DOMAIN_LIMIT);

  b_wide = (int64_t)a + ((int64_t)k * MONT_R);

  __CPROVER_assume(b_wide < DOMAIN_LIMIT);
  __CPROVER_assume(b_wide > -DOMAIN_LIMIT);

  b = (int32_t)b_wide;

  ra = mlk_montgomery_reduce(a);
  rb = mlk_montgomery_reduce(b);
  out_delta = (int64_t)rb - (int64_t)ra;

  __CPROVER_assert(
      low_word(a) == low_word(b),
      "MONT-T2B.P1.shifted_input_same_low_word");

  __CPROVER_assert(
      (int64_t)rb == (int64_t)ra + (int64_t)k,
      "MONT-T2B.P2.general_fibre_translation");

  __CPROVER_assert(
      out_delta == (int64_t)k,
      "MONT-T2B.P3.exact_output_delta_equals_k");

  if (k == 0)
  {
    __CPROVER_assert(
        rb == ra,
        "MONT-T2B.P4.zero_shift_identity");
  }

  if (k != 0)
  {
    __CPROVER_assert(
        rb != ra,
        "MONT-T2B.P5.nonzero_shift_changes_output");
  }

  /* C2_CONTROL */
}
