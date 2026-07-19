/*
 * PA-02A: Exact signed/non-canonical contract-valid CBMC harness
 *          for mlk_poly_add
 *
 * Derived from:
 *   pa02_mlk_poly_add_full_signed_contract_valid_harness.c
 *
 * Target repository:
 *   pq-code-package/mlkem-native
 * Target commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 *
 * Primary verification objective:
 *   Verify the portable C mlk_poly_add implementation for every pair of
 *   signed int16_t coefficient arrays whose coefficient-wise mathematical
 *   sums are representable in int16_t.
 *
 * Retained proof strength:
 *   - all MLKEM_N == 256 coefficients are symbolic;
 *   - each operand coefficient ranges over the complete int16_t domain;
 *   - negative and non-canonical representatives are included;
 *   - the only arithmetic-domain restriction is the necessary condition
 *     that each exact mathematical sum fits in int16_t;
 *   - the production mlk_poly_add body is executed directly;
 *   - exact coefficient-wise signed addition is asserted;
 *   - both source operands are asserted unchanged;
 *   - target/source object separation is asserted;
 *   - the runner enables bounds, pointer, overflow, conversion, shift,
 *     division, and complete-loop-unwinding checks.
 *
 * Decomposition boundary:
 *   PA-02A isolates the strongest core functional theorem: exact addition
 *   over the complete contract-valid signed domain. The parent PA-02
 *   combined harness remains the record for directly encoded relational
 *   corollaries such as commutativity, additive identity, and modulo-q
 *   refinement. Those corollaries are not assumed by this harness.
 *
 * Important scope:
 *   This harness does not claim representability when an exact mathematical
 *   sum is outside [INT16_MIN, INT16_MAX]. PA-03 is the unrestricted
 *   negative-control experiment for that excluded domain.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * CBMC treats the uninitialised local value as symbolic. Supplying a real
 * function body avoids a "no body for callee" verification failure.
 */
static int16_t pa02a_nondet_int16(void)
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
   * Bind the experiment to the intended representation and FIPS ring
   * parameters. These are assertions rather than assumptions so that an
   * incompatible build fails visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PA02A_PARAMETER_BINDING: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PA02A_PARAMETER_BINDING: MLKEM_Q must equal 3329");
  __CPROVER_assert(INT16_MIN == -32768,
                   "PA02A_REPRESENTATION_BINDING: INT16_MIN must equal -32768");
  __CPROVER_assert(INT16_MAX == 32767,
                   "PA02A_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Concrete sanity witness that the contract-valid input domain is not
   * empty: the coefficient pair (0, 0) has a representable exact sum.
   */
  __CPROVER_assert(
      ((int32_t)0 + (int32_t)0) >= (int32_t)INT16_MIN &&
          ((int32_t)0 + (int32_t)0) <= (int32_t)INT16_MAX,
      "PA02A_DOMAIN_WITNESS: zero plus zero is contract-valid");

  /*
   * Generate arbitrary signed int16_t coefficients.
   *
   * The only semantic assumption is the necessary contract-validity
   * condition:
   *
   *   INT16_MIN <= a[i] + b[i] <= INT16_MAX.
   *
   * The assumption expression is evaluated in int32_t, where every sum of
   * two int16_t values is representable.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa02a_nondet_int16();
    b.coeffs[i] = pa02a_nondet_int16();

    mathematical_sum =
        (int32_t)a.coeffs[i] + (int32_t)b.coeffs[i];

    __CPROVER_assume(mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(mathematical_sum <= (int32_t)INT16_MAX);
  }

  /* Preserve the complete symbolic inputs for post-state comparison. */
  a_before = a;
  b_before = b;

  /* mlk_poly_add is in-place in its first argument, so result starts as a. */
  result = a;

  /*
   * The target and both source objects are distinct by construction. These
   * assertions make the object-separation boundary explicit in the proof.
   */
  __CPROVER_assert(&result != &a,
                   "PA02A_DISJOINTNESS: result and a are distinct objects");
  __CPROVER_assert(&result != &b,
                   "PA02A_DISJOINTNESS: result and b are distinct objects");
  __CPROVER_assert(&a != &b,
                   "PA02A_DISJOINTNESS: a and b are distinct objects");

  /* Execute the portable production implementation exactly once. */
  mlk_poly_add(&result, &b);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)b_before.coeffs[i];

    /*
     * P1: Exact implementation-level signed addition over the complete
     * contract-valid int16_t domain.
     */
    __CPROVER_assert(
        (int32_t)result.coeffs[i] == mathematical_sum,
        "PA02A_P1_EXACT_SIGNED_SUM: result equals the exact int32 mathematical sum");

    /*
     * P2: The independent left source object remains unchanged.
     */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "PA02A_P2_LEFT_SOURCE_FRAME: a remains unchanged");

    /*
     * P3: The read-only second operand remains unchanged by mlk_poly_add.
     */
    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "PA02A_P3_RIGHT_OPERAND_FRAME: b remains unchanged");
  }

  return 0;
}
