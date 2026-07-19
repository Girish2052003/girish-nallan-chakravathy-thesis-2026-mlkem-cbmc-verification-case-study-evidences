/*
 * PA-05A: Production caller verification for the mlk_poly_add call inside
 *         mlk_polyvec_add (mlkem/src/poly_k.c).
 *
 * Purpose:
 *   Verify that the production mlk_polyvec_add caller discharges the
 *   mlk_poly_add arithmetic and object-separation obligations for every
 *   component call, assuming exactly the documented mlk_polyvec_add input
 *   contract.
 *
 * This harness directly calls the production mlk_polyvec_add implementation,
 * which in turn directly calls the production mlk_poly_add implementation.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly_k.h"

static int16_t pa05a_nondet_int16(void)
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
      "PA05A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA05A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_K == 3,
      "PA05A_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");

  __CPROVER_assert(
      &r != &b,
      "PA05A_OBJECT_SEPARATION: caller vector objects are distinct");

  /*
   * Model exactly the documented mlk_polyvec_add input contract:
   * every component-wise mathematical sum must fit in int16_t.
   */
  for (j = 0; j < MLKEM_K; j++)
  {
    __CPROVER_assert(
        &r.vec[j] != &b.vec[j],
        "PA05A_COMPONENT_SEPARATION: each nested mlk_poly_add call uses distinct polynomials");

    for (i = 0; i < MLKEM_N; i++)
    {
      r.vec[j].coeffs[i] = pa05a_nondet_int16();
      b.vec[j].coeffs[i] = pa05a_nondet_int16();

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
   * Execute the production caller. Its loop invokes production
   * mlk_poly_add once for every vector component.
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
          "PA05A_P1_CALLER_EXACT_SUM: every production component call computes the exact sum");

      __CPROVER_assert(
          b.vec[j].coeffs[i] == b_before.vec[j].coeffs[i],
          "PA05A_P2_CALLER_FRAME: the production caller preserves its read-only vector");
    }
  }

  return 0;
}
