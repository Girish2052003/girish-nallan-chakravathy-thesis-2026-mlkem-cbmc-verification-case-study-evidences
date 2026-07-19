/*
 * PA-02E: Full signed/non-canonical additive-identity CBMC harness
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
 *   Verify the additive-identity law for the portable production
 *   mlk_poly_add implementation:
 *
 *     a + 0 = a
 *
 *   for every signed/non-canonical int16_t polynomial a.
 *
 * Retained and strengthened proof scope:
 *   - all MLKEM_N == 256 coefficients of a are symbolic;
 *   - each coefficient ranges over the complete int16_t domain;
 *   - negative and non-canonical representatives are included;
 *   - no semantic input assumptions are required, because a + 0 is
 *     representable in int16_t for every int16_t value a;
 *   - the real portable production mlk_poly_add body is executed once;
 *   - the exact signed target effect is proved independently;
 *   - additive identity is proved directly coefficient-wise;
 *   - the independent source a and the read-only zero operand are proved
 *     unchanged;
 *   - target/source object separation is explicit;
 *   - the runner enables bounds, pointer, arithmetic, conversion, shift,
 *     division, and complete-loop-unwinding checks.
 *
 * Decomposition boundary:
 *   PA-02E isolates the additive-identity branch from the original combined
 *   PA-02 harness. Exact signed addition, modulo-q refinement, frame/write
 *   footprint, and commutativity are handled independently by PA-02A through
 *   PA-02D. No result from those experiments is assumed here.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/* CBMC treats the uninitialised local returned by this body as symbolic. */
static int16_t pa02e_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly a;
  mlk_poly a_before;
  mlk_poly zero;
  mlk_poly identity_result;

  unsigned i;
  int32_t mathematical_sum;

  /*
   * Bind the experiment to the intended representation and FIPS ring
   * parameters. Assertions make incompatible builds fail visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PA02E_PARAMETER_BINDING: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PA02E_PARAMETER_BINDING: MLKEM_Q must equal 3329");
  __CPROVER_assert(INT16_MIN == -32768,
                   "PA02E_REPRESENTATION_BINDING: INT16_MIN must equal -32768");
  __CPROVER_assert(INT16_MAX == 32767,
                   "PA02E_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Generate an arbitrary full-range signed/non-canonical polynomial.
   * No __CPROVER_assume is used: adding zero preserves every int16_t value.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa02e_nondet_int16();
    zero.coeffs[i] = 0;
  }

  /* Preserve the complete symbolic source pre-state. */
  a_before = a;

  /* mlk_poly_add is in-place in its first argument. */
  identity_result = a_before;

  /* Make the legal disjoint-object boundary explicit in the proof. */
  __CPROVER_assert(
      &identity_result != &zero,
      "PA02E_DISJOINTNESS: writable target and zero operand are distinct");
  __CPROVER_assert(
      &identity_result != &a,
      "PA02E_DISJOINTNESS: writable target and independent source are distinct");
  __CPROVER_assert(
      &a != &zero,
      "PA02E_DISJOINTNESS: source and zero operand are distinct");

  /* Execute the real portable production implementation exactly once. */
  mlk_poly_add(&identity_result, &zero);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)zero.coeffs[i];

    /*
     * P1: Exact semantic bridge. The production result equals the exact
     * mathematical signed sum a[i] + 0.
     */
    __CPROVER_assert(
        (int32_t)identity_result.coeffs[i] == mathematical_sum,
        "PA02E_P1_EXACT_ZERO_SUM_BRIDGE: production result equals exact a plus zero");

    /*
     * P2: Primary additive-identity theorem over the complete int16_t domain.
     */
    __CPROVER_assert(
        identity_result.coeffs[i] == a_before.coeffs[i],
        "PA02E_P2_ADDITIVE_IDENTITY: production a plus zero equals a coefficient-wise");

    /*
     * P3: The independent symbolic source remains equal to its pre-state.
     */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "PA02E_P3_SOURCE_FRAME: independent source a remains unchanged");

    /*
     * P4: The read-only zero operand remains zero after the production call.
     */
    __CPROVER_assert(
        zero.coeffs[i] == 0,
        "PA02E_P4_ZERO_OPERAND_FRAME: zero operand remains unchanged");
  }

  return 0;
}
