/*
 * PA-03: Unrestricted signed-domain negative-control harness
 *         for mlk_poly_add
 *
 * Scientific purpose:
 *   Demonstrate that exact mathematical addition cannot hold for every
 *   arbitrary pair of int16_t coefficient arrays because some sums are
 *   outside the representable int16_t range.
 *
 * Expected CBMC outcome:
 *   VERIFICATION FAILED
 *
 * Expected campaign interpretation:
 *   EXPECTED_COUNTEREXAMPLE_CONFIRMED
 *
 * This expected failure is the successful scientific result of PA-03.
 * It validates that the representability precondition used by PA-02 is
 * necessary rather than an arbitrary assumption added to force success.
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * CBMC treats the uninitialised local value as symbolic.
 * A concrete function body avoids a no-body verification failure.
 */
static int16_t pa03_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;

  mlk_poly a_before;
  mlk_poly b_before;
  mlk_poly result;

  unsigned i;
  int32_t mathematical_sum;

  /*
   * Bind the experiment to the intended ML-KEM and integer
   * representation parameters. These are assertions, not assumptions.
   */
  __CPROVER_assert(
      MLKEM_N == 256,
      "PA03_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA03_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA03_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA03_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Generate completely unrestricted signed int16_t arrays.
   *
   * Deliberately absent:
   *   - no canonical FIPS-domain assumptions;
   *   - no non-negative assumptions;
   *   - no safe-sum or representability assumptions;
   *   - no restriction preventing a mathematical sum from lying
   *     outside [INT16_MIN, INT16_MAX].
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa03_nondet_int16();
    b.coeffs[i] = pa03_nondet_int16();
  }

  a_before = a;
  b_before = b;
  result = a;

  /*
   * Keep the target call legal with respect to object separation.
   * PA-03 changes only the arithmetic input domain; it does not mix the
   * later aliasing diagnostic into this negative-control experiment.
   */
  __CPROVER_assert(
      &result != &b,
      "PA03_DISJOINTNESS: result and b are distinct objects");

  /*
   * Directly execute the production portable-C implementation.
   */
  mlk_poly_add(&result, &b);

  for (i = 0; i < MLKEM_N; i++)
  {
    /*
     * int32_t can represent every exact sum of two int16_t values.
     */
    mathematical_sum =
        (int32_t)a_before.coeffs[i] +
        (int32_t)b_before.coeffs[i];

    /*
     * PA03-P1 is intentionally too strong over the unrestricted domain.
     *
     * CBMC is expected to refute it using a pair whose exact sum is
     * outside the int16_t range. For example, a value equivalent to
     * INT16_MAX + 1 or INT16_MIN - 1 is sufficient.
     */
    __CPROVER_assert(
        (int32_t)result.coeffs[i] == mathematical_sum,
        "PA03_P1_UNRESTRICTED_EXACT_SUM: exact addition for every arbitrary int16_t pair");

    /*
     * This frame property should remain valid even though PA03-P1 fails.
     * It helps distinguish the intended arithmetic-domain failure from
     * unintended mutation of the read-only operand.
     */
    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "PA03_P2_RIGHT_INPUT_FRAME: b remains unchanged");
  }

  return 0;
}
