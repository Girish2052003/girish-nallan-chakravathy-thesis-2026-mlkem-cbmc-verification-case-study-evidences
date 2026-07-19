/*
 * PA-06B: Cross-parameter call-site verification for
 *         mlk_poly_add(v, epp) in mlk_indcpa_enc.
 *
 * Compiled separately for ML-KEM-512, ML-KEM-768, and ML-KEM-1024.
 *
 * The harness assumes only the documented producer guarantees:
 *   abs(v[i])   < MLK_INVNTT_BOUND
 *   abs(epp[i]) < MLKEM_ETA2 + 1
 *
 * The target representability condition is asserted, not assumed.
 * The production mlk_poly_add body is executed directly.
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa06b_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa06b_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly v;
  mlk_poly epp;
  mlk_poly v_before;
  mlk_poly epp_before;

  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA06B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA06B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA06B_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA06B_BOUND_BINDING: inverse NTT bound must equal 8*q");

#if MLK_CONFIG_PARAMETER_SET == 512
  __CPROVER_assert(
      MLKEM_K == 2,
      "PA06B_PARAMETER_BINDING: ML-KEM-512 must use MLKEM_K equal to 2");
#elif MLK_CONFIG_PARAMETER_SET == 768
  __CPROVER_assert(
      MLKEM_K == 3,
      "PA06B_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");
#elif MLK_CONFIG_PARAMETER_SET == 1024
  __CPROVER_assert(
      MLKEM_K == 4,
      "PA06B_PARAMETER_BINDING: ML-KEM-1024 must use MLKEM_K equal to 4");
#else
#error PA-06B requires ML-KEM-512, ML-KEM-768, or ML-KEM-1024
#endif

  __CPROVER_assert(
      &v != &epp,
      "PA06B_OBJECT_SEPARATION: v and epp are distinct objects");

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa06b_nondet_int16();
    epp.coeffs[i] = pa06b_nondet_int16();

    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    mathematical_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    __CPROVER_assert(
        mathematical_sum >= (int32_t)INT16_MIN,
        "PA06B_P1_CROSS_PARAMETER_CALL_LOWER: v+epp is representable");

    __CPROVER_assert(
        mathematical_sum <= (int32_t)INT16_MAX,
        "PA06B_P1_CROSS_PARAMETER_CALL_UPPER: v+epp is representable");
  }

  v_before = v;
  epp_before = epp;

  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)v_before.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == mathematical_sum,
        "PA06B_P2_CROSS_PARAMETER_EXACT_RESULT: production v+epp call is exact");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA06B_P3_CROSS_PARAMETER_FRAME: epp remains unchanged");

    __CPROVER_assert(
        pa06b_mod_q((int32_t)v.coeffs[i]) ==
            pa06b_mod_q(mathematical_sum),
        "PA06B_P4_CROSS_PARAMETER_MOD_Q: result has the correct residue");
  }

  return 0;
}
