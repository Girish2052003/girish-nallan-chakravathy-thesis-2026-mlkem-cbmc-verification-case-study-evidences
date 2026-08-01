/*
 * PA-06A: Cross-parameter production-caller verification for the
 *         mlk_poly_add calls inside mlk_polyvec_add.
 *
 * This harness is parameter-set neutral. It is compiled separately for:
 *   ML-KEM-512  (MLKEM_K = 2)
 *   ML-KEM-768  (MLKEM_K = 3)
 *   ML-KEM-1024 (MLKEM_K = 4)
 *
 * It directly executes production mlk_polyvec_add from poly_k.c, which
 * directly invokes production mlk_poly_add for each vector component.
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly_k.h"

static int16_t pa06a_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_polyvec r;
  mlk_polyvec b;
  mlk_polyvec r_before;
  mlk_polyvec b_before;

  unsigned j;
  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA06A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA06A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

#if MLK_CONFIG_PARAMETER_SET == 512
  __CPROVER_assert(
      MLKEM_K == 2,
      "PA06A_PARAMETER_BINDING: ML-KEM-512 must use MLKEM_K equal to 2");
#elif MLK_CONFIG_PARAMETER_SET == 768
  __CPROVER_assert(
      MLKEM_K == 3,
      "PA06A_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");
#elif MLK_CONFIG_PARAMETER_SET == 1024
  __CPROVER_assert(
      MLKEM_K == 4,
      "PA06A_PARAMETER_BINDING: ML-KEM-1024 must use MLKEM_K equal to 4");
#else
#error PA-06A requires ML-KEM-512, ML-KEM-768, or ML-KEM-1024
#endif

  __CPROVER_assert(
      &r != &b,
      "PA06A_OBJECT_SEPARATION: caller vector objects are distinct");

  /*
   * Exact documented mlk_polyvec_add input contract:
   * every nested coefficient sum must be representable in int16_t.
   */
  for (j = 0; j < MLKEM_K; j++)
  {
    __CPROVER_assert(
        &r.vec[j] != &b.vec[j],
        "PA06A_COMPONENT_SEPARATION: nested target operands are distinct");

    for (i = 0; i < MLKEM_N; i++)
    {
      r.vec[j].coeffs[i] = pa06a_nondet_int16();
      b.vec[j].coeffs[i] = pa06a_nondet_int16();

      mathematical_sum =
          (int32_t)r.vec[j].coeffs[i] +
          (int32_t)b.vec[j].coeffs[i];

      __CPROVER_assume(
          mathematical_sum >= (int32_t)INT16_MIN);

      __CPROVER_assume(
          mathematical_sum <= (int32_t)INT16_MAX);
    }
  }

  r_before = r;
  b_before = b;

  /*
   * Direct production caller execution.
   */
  mlk_polyvec_add(&r, &b);

  for (j = 0; j < MLKEM_K; j++)
  {
    for (i = 0; i < MLKEM_N; i++)
    {
      mathematical_sum =
          (int32_t)r_before.vec[j].coeffs[i] +
          (int32_t)b_before.vec[j].coeffs[i];

      __CPROVER_assert(
          (int32_t)r.vec[j].coeffs[i] == mathematical_sum,
          "PA06A_P1_CROSS_PARAMETER_EXACT_SUM: every production component call computes the exact sum");

      __CPROVER_assert(
          b.vec[j].coeffs[i] == b_before.vec[j].coeffs[i],
          "PA06A_P2_CROSS_PARAMETER_FRAME: production caller preserves the read-only vector");
    }
  }

  return 0;
}
