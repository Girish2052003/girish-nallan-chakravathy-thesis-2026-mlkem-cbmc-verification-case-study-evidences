/*
 * PA-08B: Expected-failure reachability sentinel for mlk_poly_add.
 *
 * Purpose:
 *   Demonstrate that the canonical and complete signed-valid assumptions
 *   admit concrete executions that reach and return from production
 *   mlk_poly_add.
 *
 * The two deliberately false assertions occur only after their respective
 * target calls. Their expected failure is evidence that the paths are
 * reachable and the assumptions are not contradictory.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Expected campaign interpretation:
 *   BOTH_REACHABILITY_SENTINELS_CONFIRMED
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa08b_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly canonical_r;
  mlk_poly canonical_b;

  mlk_poly signed_r;
  mlk_poly signed_b;

  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA08B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA08B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  for (i = 0; i < MLKEM_N; i++)
  {
    canonical_r.coeffs[i] = pa08b_nondet_int16();
    canonical_b.coeffs[i] = pa08b_nondet_int16();

    __CPROVER_assume(
        (int32_t)canonical_r.coeffs[i] >= 0);
    __CPROVER_assume(
        (int32_t)canonical_r.coeffs[i] < (int32_t)MLKEM_Q);

    __CPROVER_assume(
        (int32_t)canonical_b.coeffs[i] >= 0);
    __CPROVER_assume(
        (int32_t)canonical_b.coeffs[i] < (int32_t)MLKEM_Q);
  }

  mlk_poly_add(&canonical_r, &canonical_b);

  /*
   * Expected FAILURE proves that at least one canonical execution reaches
   * this point after the production target returns.
   */
  __CPROVER_assert(
      0,
      "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET");

  for (i = 0; i < MLKEM_N; i++)
  {
    signed_r.coeffs[i] = pa08b_nondet_int16();
    signed_b.coeffs[i] = pa08b_nondet_int16();

    mathematical_sum =
        (int32_t)signed_r.coeffs[i] +
        (int32_t)signed_b.coeffs[i];

    __CPROVER_assume(
        mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(
        mathematical_sum <= (int32_t)INT16_MAX);
  }

  mlk_poly_add(&signed_r, &signed_b);

  /*
   * Expected FAILURE proves that at least one complete signed-valid
   * execution reaches this point after the production target returns.
   */
  __CPROVER_assert(
      0,
      "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET");

  return 0;
}
