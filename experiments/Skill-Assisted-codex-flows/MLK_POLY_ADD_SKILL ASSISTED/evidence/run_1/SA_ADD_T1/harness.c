/*
 * SA-ADD-T1: common-addend translation invariance for mlk_poly_add.
 * Target: mlkem-native commit d9613cf60de3132d32475c102d8c2781d84feb34.
 * Parameter set: ML-KEM-768.  Production source is linked by the runner.
 */
#include <limits.h>
#include <stdint.h>
#include "mlkem/src/poly.h"

static int16_t sa_t1_nondet_i16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly x;
  mlk_poly y;
  mlk_poly common;
  mlk_poly x_before;
  mlk_poly y_before;
  unsigned i;
  unsigned target_calls = 0;

  __CPROVER_assert(MLKEM_N == 256,
                   "SA_T1_BINDING_N_256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "SA_T1_BINDING_Q_3329");
  __CPROVER_assert(INT16_MIN == -32768 && INT16_MAX == 32767,
                   "SA_T1_BINDING_INT16");

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t sx;
    int32_t sy;

    x.coeffs[i] = sa_t1_nondet_i16();
    y.coeffs[i] = sa_t1_nondet_i16();
    common.coeffs[i] = sa_t1_nondet_i16();
    x_before.coeffs[i] = x.coeffs[i];
    y_before.coeffs[i] = y.coeffs[i];

    sx = (int32_t)x.coeffs[i] + (int32_t)common.coeffs[i];
    sy = (int32_t)y.coeffs[i] + (int32_t)common.coeffs[i];
    __CPROVER_assume(sx >= INT16_MIN && sx <= INT16_MAX);
    __CPROVER_assume(sy >= INT16_MIN && sy <= INT16_MAX);
  }

  __CPROVER_cover(1); /* SA_T1_ASSUMPTIONS_FEASIBLE */

  mlk_poly_add(&x, &common);
  target_calls++;
  __CPROVER_cover(target_calls == 1); /* SA_T1_FIRST_TARGET_RETURNED */

  mlk_poly_add(&y, &common);
  target_calls++;
  __CPROVER_cover(target_calls == 2); /* SA_T1_SECOND_TARGET_RETURNED */
  __CPROVER_cover(1); /* SA_T1_ASSERTION_BLOCK_REACHED */

  __CPROVER_assert(target_calls == 2,
                   "SA_T1_TARGET_CALL_COUNT");

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t delta_before =
        (int32_t)x_before.coeffs[i] - (int32_t)y_before.coeffs[i];
    int32_t delta_after =
        (int32_t)x.coeffs[i] - (int32_t)y.coeffs[i];

    __CPROVER_assert(delta_after == delta_before,
        "SA_T1_TRANSLATION_DIFFERENCE_PRESERVED");
    __CPROVER_assert((x.coeffs[i] == y.coeffs[i]) ==
                     (x_before.coeffs[i] == y_before.coeffs[i]),
        "SA_T1_COMMON_ADDEND_EQUALITY_PRESERVED_AND_REFLECTED");
  }

  return 0;
}
