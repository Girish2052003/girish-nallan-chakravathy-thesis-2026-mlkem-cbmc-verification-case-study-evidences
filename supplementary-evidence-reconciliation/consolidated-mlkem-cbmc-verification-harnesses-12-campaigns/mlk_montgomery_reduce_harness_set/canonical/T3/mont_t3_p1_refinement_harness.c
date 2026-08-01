#include <stdint.h>
#include <limits.h>

#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_QINV ((uint32_t)62209)

extern int16_t nondet_int16_t(void);
int16_t mlk_fqmul(int16_t a, int16_t b);

void harness(void)
{
  int16_t a;
  int16_t b;
  int16_t result;
  int32_t product;
  uint16_t product_low;
  uint32_t inverted_low;
  int32_t witness_t;

  a = nondet_int16_t();
  b = nondet_int16_t();

  __CPROVER_assume(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF);

  product = (int32_t)a * (int32_t)b;
  result = mlk_fqmul(a, b);

  product_low = (uint16_t)product;
  inverted_low =
      (((uint32_t)product_low * MONT_QINV) & (uint32_t)UINT16_MAX);

  witness_t =
      (inverted_low <= (uint32_t)INT16_MAX)
          ? (int32_t)inverted_low
          : (int32_t)inverted_low - (int32_t)65536;

  __CPROVER_assert(
      result > -MLKEM_Q && result < MLKEM_Q,
      "MONT-T3.P1.1.independent_output_bound");

  __CPROVER_assert(
      ((int64_t)result * MONT_R) +
              ((int64_t)witness_t * (int64_t)MLKEM_Q) ==
          (int64_t)product,
      "MONT-T3.P1.2.independent_exact_multiplication_refinement");
}
