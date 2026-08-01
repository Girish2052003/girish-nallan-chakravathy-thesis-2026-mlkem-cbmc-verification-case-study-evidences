#include <stdint.h>
#include <limits.h>
#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_Q ((int64_t)MLKEM_Q)
#define FROZEN_QINV ((uint32_t)62209)
#define DOMAIN_LIMIT \
  ((int64_t)INT32_MAX - (((int64_t)1 << 15) * (int64_t)MLKEM_Q))

extern int32_t nondet_int32_t(void);

static int16_t independent_signed_witness(int32_t x)
{
  uint16_t low;
  uint16_t inverted;

  low = mlk_cast_int32_to_uint16(x);
  inverted = (uint16_t)(((uint32_t)low * FROZEN_QINV) & UINT16_MAX);
  return mlk_cast_uint16_to_int16(inverted);
}

void harness(void)
{
  int32_t x;
  int16_t result;
  int16_t witness;

  x = nondet_int32_t();

  __CPROVER_assume((int64_t)x < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)x > -DOMAIN_LIMIT);

  result = mlk_montgomery_reduce(x);
  witness = independent_signed_witness(x);

  __CPROVER_assert(
      ((int64_t)result * MONT_R) +
              ((int64_t)witness * MONT_Q) ==
          (int64_t)x,
      "MONT-T2A.P3L1.universal_single_call_exact_decomposition");
}
