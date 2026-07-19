/*
 * PA-08D: Negative just-outside-boundary negative control.
 *
 * Boundary witness:
 *   INT16_MIN + (-1) = -32769
 *
 * The exact mathematical sum is one less than the smallest representable
 * int16_t value.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Required evidence:
 *   - exact-result assertion failure;
 *   - target signed-conversion failure;
 *   - no missing-body failure.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

int main(void)
{
  mlk_poly r;
  mlk_poly b;
  mlk_poly r_before;

  unsigned i;
  int32_t mathematical_sum;

  for (i = 0; i < MLKEM_N; i++)
  {
    r.coeffs[i] = 0;
    b.coeffs[i] = 0;
  }

  r.coeffs[MLKEM_N - 1u] = (int16_t)INT16_MIN;
  b.coeffs[MLKEM_N - 1u] = (int16_t)-1;

  r_before = r;

  __CPROVER_assert(
      &r != &b,
      "PA08D_DISJOINTNESS: negative-boundary operands are distinct");

  mlk_poly_add(&r, &b);

  mathematical_sum =
      (int32_t)r_before.coeffs[MLKEM_N - 1u] +
      (int32_t)b.coeffs[MLKEM_N - 1u];

  __CPROVER_assert(
      mathematical_sum == (int32_t)INT16_MIN - 1,
      "PA08D_BOUNDARY_BINDING: mathematical sum is INT16_MIN-1");

  __CPROVER_assert(
      (int32_t)r.coeffs[MLKEM_N - 1u] == mathematical_sum,
      "PA08D_P1_NEGATIVE_JUST_OUTSIDE_EXACT_SUM: INT16_MIN-1 cannot be stored exactly");

  return 0;
}
