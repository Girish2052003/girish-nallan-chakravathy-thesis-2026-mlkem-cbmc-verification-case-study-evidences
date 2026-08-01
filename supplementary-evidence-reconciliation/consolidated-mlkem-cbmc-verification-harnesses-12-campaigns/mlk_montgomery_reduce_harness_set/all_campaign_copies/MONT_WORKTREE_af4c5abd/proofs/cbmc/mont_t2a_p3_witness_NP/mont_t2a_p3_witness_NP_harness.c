#include <stdint.h>
#include <limits.h>
#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_Q ((int64_t)MLKEM_Q)
#define MONT_QINV_UNSIGNED ((int64_t)62209)
#define DOMAIN_LIMIT ((int64_t)INT32_MAX - (((int64_t)1 << 15) * (int64_t)MLKEM_Q))

extern int32_t nondet_int32_t(void);

/*
 * Independent signed Montgomery witness. All arithmetic is int64_t and
 * remains far inside its range on the full source-contract domain.
 */
static int64_t mont_signed_witness(int32_t value)
{
  int64_t low;
  int64_t raw;

  low = (int64_t)value % MONT_R;
  if (low < 0)
  {
    low += MONT_R;
  }

  raw = (low * MONT_QINV_UNSIGNED) % MONT_R;
  if (raw >= (MONT_R / 2))
  {
    raw -= MONT_R;
  }

  return raw;
}

void harness(void)
{
  int32_t a = nondet_int32_t();
  int32_t b = nondet_int32_t();
  int16_t ra;
  int16_t rb;
  int64_t ta;
  int64_t tb;
  int64_t input_delta;
  int64_t output_delta;
  int64_t scaled_difference;
  int64_t exact_q_multiple;

  __CPROVER_assume((int64_t)a < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)a > -DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b > -DOMAIN_LIMIT);

  __CPROVER_assume((int64_t)a < 0);
  __CPROVER_assume((int64_t)b >= 0);

  ra = mlk_montgomery_reduce(a);
  rb = mlk_montgomery_reduce(b);

  ta = mont_signed_witness(a);
  tb = mont_signed_witness(b);

  input_delta = (int64_t)b - (int64_t)a;
  output_delta = (int64_t)rb - (int64_t)ra;
  scaled_difference = output_delta * MONT_R - input_delta;
  exact_q_multiple = -MONT_Q * (tb - ta);

  /*
   * Stronger exact-witness encoding of the original locked theorem:
   *
   *   R*(reduce(b)-reduce(a)) - (b-a) is an exact multiple of q.
   *
   * Exact equality to q times an independently computed witness directly
   * implies the original modulo-congruence assertion without assuming T1.
   */
  __CPROVER_assert(
      scaled_difference == exact_q_multiple,
      "MONT-T2A.P3.arbitrary_pair_scaled_congruence");
}
