/*
 * Clean-room, FIPS-domain, relational CBMC harness for mlk_poly_add
 *
 * Target repository:
 *   pq-code-package/mlkem-native
 * Target commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 *
 * Research scope:
 *   - independently authored harness;
 *   - does not require or invoke an existing mlk_poly_add harness;
 *   - exercises the real two-argument in-place implementation;
 *   - uses canonical FIPS 203 representatives: 0 <= coefficient < q;
 *   - checks implementation-level addition and its modulo-q meaning;
 *   - adds relational/metamorphic checks (commutativity and identity);
 *   - keeps all target-call objects disjoint by construction.
 *
 * Important limitation:
 *   This is a FIPS-canonical input-domain harness. It does not yet cover
 *   every non-canonical signed int16_t representation that production
 *   call sites may use internally.
 *
 * Integration:
 *   Compile this harness with the repository's production poly.c and the
 *   same configuration/include flags used by the selected ML-KEM build.
 *   Do not enable function-contract replacement or loop-contract
 *   transformation for the clean-room BMC run.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * A local automatic object without an initializer is nondeterministic in CBMC.
 * Providing a function body avoids CBMC's "no body for callee" property while
 * preserving symbolic input generation.
 */
static int16_t cleanroom_nondet_int16(void)
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

  mlk_poly sum_ab;
  mlk_poly sum_ba;

  mlk_poly zero;
  mlk_poly identity_result;

  unsigned i;
  int32_t expected_integer_sum;
  int32_t expected_fips_residue;

  /*
   * Bind the experiment to the FIPS 203 ring parameters used by this
   * target. These are assertions, not assumptions: a configuration drift
   * must make the experiment fail visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PARAMETER_BINDING: MLKEM_N must equal FIPS n=256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PARAMETER_BINDING: MLKEM_Q must equal FIPS q=3329");

  /*
   * Generate two arbitrary polynomials using unsigned canonical
   * representatives of Z_q. The bounds imply:
   *
   *   0 <= a[i] + b[i] <= 2*q - 2 = 6656,
   *
   * so the implementation's in-place int16_t result cannot overflow.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = cleanroom_nondet_int16();
    b.coeffs[i] = cleanroom_nondet_int16();

    __CPROVER_assume(a.coeffs[i] >= 0);
    __CPROVER_assume(a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[i] >= 0);
    __CPROVER_assume(b.coeffs[i] < MLKEM_Q);

    zero.coeffs[i] = 0;
  }

  /*
   * Freeze the mathematical inputs before any target call.
   */
  a_before = a;
  b_before = b;

  /*
   * Three distinct-object experiments:
   *
   *   sum_ab          := a + b
   *   sum_ba          := b + a
   *   identity_result := a + 0
   *
   * Every output object is disjoint from its read-only operand.
   */
  sum_ab = a;
  sum_ba = b;
  identity_result = a;

  mlk_poly_add(&sum_ab, &b);
  mlk_poly_add(&sum_ba, &a);
  mlk_poly_add(&identity_result, &zero);

  for (i = 0; i < MLKEM_N; i++)
  {
    expected_integer_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)b_before.coeffs[i];

    expected_fips_residue = expected_integer_sum % (int32_t)MLKEM_Q;

    /*
     * P1: Exact accumulator semantics before modular normalization.
     */
    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] == expected_integer_sum,
        "P1_EXACT_SUM: output coefficient equals the mathematical integer sum");

    /*
     * P2: Derived implementation bound for canonical FIPS inputs.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] >= 0,
        "P2_LOWER_BOUND: canonical-input sum is nonnegative");

    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] <=
            (2 * (int32_t)MLKEM_Q) - 2,
        "P2_UPPER_BOUND: canonical-input sum is at most 2*q-2");

    /*
     * P3: Refinement to FIPS polynomial addition.
     *
     * mlk_poly_add intentionally need not reduce its stored coefficient.
     * Its residue modulo q must nevertheless equal FIPS addition in Z_q.
     */
    __CPROVER_assert(
        ((int32_t)sum_ab.coeffs[i] % (int32_t)MLKEM_Q) ==
            expected_fips_residue,
        "P3_FIPS_RESIDUE: stored sum represents coefficient addition modulo q");

    /*
     * P4: Read-only operands and frozen inputs are not modified.
     */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "P4_LEFT_INPUT_FRAME: read-only use of a leaves a unchanged");

    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "P4_RIGHT_INPUT_FRAME: read-only use of b leaves b unchanged");

    __CPROVER_assert(
        zero.coeffs[i] == 0,
        "P4_ZERO_FRAME: zero operand remains unchanged");

    /*
     * P5: Relational/metamorphic commutativity.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] == sum_ba.coeffs[i],
        "P5_COMMUTATIVITY: a+b equals b+a coefficient-wise");

    /*
     * P6: Relational/metamorphic additive identity.
     */
    __CPROVER_assert(
        identity_result.coeffs[i] == a_before.coeffs[i],
        "P6_IDENTITY: a+0 equals a coefficient-wise");
  }

  return 0;
}
