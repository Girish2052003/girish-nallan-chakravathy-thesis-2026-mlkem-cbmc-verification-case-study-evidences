/*
 * PA-02: Full signed/non-canonical contract-valid CBMC harness
 *         for mlk_poly_add
 *
 * Target repository:
 *   pq-code-package/mlkem-native
 * Target commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 *
 * Verification objective:
 *   Verify the portable C mlk_poly_add implementation for every pair of
 *   signed int16_t coefficient arrays whose coefficient-wise mathematical
 *   sums are representable in int16_t.
 *
 * This is broader than the PA-01 canonical FIPS-domain harness:
 *   - coefficients may be negative;
 *   - coefficients may be greater than or equal to q;
 *   - coefficients may be any int16_t value;
 *   - the only arithmetic-domain restriction is that each exact sum fits
 *     in int16_t, which is the function's necessary representability
 *     precondition.
 *
 * The harness:
 *   - directly executes the production function body;
 *   - keeps target-call objects disjoint by construction;
 *   - proves exact signed addition;
 *   - proves modulo-q congruence for signed/non-canonical representatives;
 *   - proves read-only operand preservation;
 *   - checks commutativity and additive identity;
 *   - relies on CBMC safety instrumentation for bounds, pointers,
 *     overflows, conversions, shifts, and complete loop unwinding.
 *
 * Important scope:
 *   This harness does not claim that an exact mathematical sum can be
 *   represented when it is outside [INT16_MIN, INT16_MAX]. PA-03 will be
 *   the unrestricted negative-control experiment demonstrating why that
 *   precondition is necessary.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * CBMC treats the uninitialised local value as symbolic. Supplying a real
 * function body avoids a "no body for callee" verification failure.
 */
static int16_t pa02_nondet_int16(void)
{
  int16_t value;
  return value;
}

/*
 * Convert any signed integer representative to the canonical residue
 * 0..q-1. C remainder may be negative, so one q is added when needed.
 */
static int32_t pa02_mod_q(int32_t value)
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
  mlk_poly a;
  mlk_poly b;

  mlk_poly a_before;
  mlk_poly b_before;

  mlk_poly sum_ab;
  mlk_poly sum_ba;

  mlk_poly zero;
  mlk_poly identity_result;

  unsigned i;
  int32_t mathematical_sum;
  int32_t actual_residue;
  int32_t expected_residue;
  int32_t canonical_operand_sum_residue;

  /*
   * Bind the experiment to the intended representation and FIPS ring
   * parameters. These are assertions rather than assumptions so that an
   * incompatible build fails visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PA02_PARAMETER_BINDING: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PA02_PARAMETER_BINDING: MLKEM_Q must equal 3329");
  __CPROVER_assert(INT16_MIN == -32768,
                   "PA02_REPRESENTATION_BINDING: INT16_MIN must equal -32768");
  __CPROVER_assert(INT16_MAX == 32767,
                   "PA02_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Generate arbitrary signed int16_t coefficients.
   *
   * The only semantic assumption is the necessary contract-validity
   * condition:
   *
   *   INT16_MIN <= a[i] + b[i] <= INT16_MAX.
   *
   * The addition used to state the assumption is performed in int32_t,
   * where every sum of two int16_t values is representable.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa02_nondet_int16();
    b.coeffs[i] = pa02_nondet_int16();

    mathematical_sum =
        (int32_t)a.coeffs[i] + (int32_t)b.coeffs[i];

    __CPROVER_assume(mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(mathematical_sum <= (int32_t)INT16_MAX);

    zero.coeffs[i] = 0;
  }

  a_before = a;
  b_before = b;

  sum_ab = a;
  sum_ba = b;
  identity_result = a;

  /*
   * PA-02 uses legal, disjoint target calls. The explicit pointer
   * assertions make the object-separation boundary visible in the result.
   */
  __CPROVER_assert(&sum_ab != &b,
                   "PA02_DISJOINTNESS: sum_ab and b are distinct objects");
  __CPROVER_assert(&sum_ba != &a,
                   "PA02_DISJOINTNESS: sum_ba and a are distinct objects");
  __CPROVER_assert(&identity_result != &zero,
                   "PA02_DISJOINTNESS: identity_result and zero are distinct");

  mlk_poly_add(&sum_ab, &b);
  mlk_poly_add(&sum_ba, &a);
  mlk_poly_add(&identity_result, &zero);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)b_before.coeffs[i];

    actual_residue = pa02_mod_q((int32_t)sum_ab.coeffs[i]);
    expected_residue = pa02_mod_q(mathematical_sum);

    canonical_operand_sum_residue =
        pa02_mod_q(
            pa02_mod_q((int32_t)a_before.coeffs[i]) +
            pa02_mod_q((int32_t)b_before.coeffs[i]));

    /*
     * P1: Exact implementation-level signed addition over the complete
     * contract-valid int16_t domain.
     */
    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] == mathematical_sum,
        "PA02_P1_EXACT_SIGNED_SUM: result equals the exact int32 mathematical sum");

    /*
     * P2: The concrete signed/non-canonical result represents the correct
     * abstract element of Z_q.
     */
    __CPROVER_assert(
        actual_residue == expected_residue,
        "PA02_P2_MOD_Q_CONGRUENCE: result is congruent to the exact sum modulo q");

    /*
     * P3: The same result agrees with addition of the canonical residues
     * of both potentially signed/non-canonical operands.
     */
    __CPROVER_assert(
        actual_residue == canonical_operand_sum_residue,
        "PA02_P3_CANONICAL_RESIDUE_REFINEMENT: result matches canonical operand addition");

    /*
     * P4: Read-only operands remain unchanged across the target calls.
     */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "PA02_P4_LEFT_INPUT_FRAME: a remains unchanged when used read-only");

    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "PA02_P4_RIGHT_INPUT_FRAME: b remains unchanged when used read-only");

    __CPROVER_assert(
        zero.coeffs[i] == 0,
        "PA02_P4_ZERO_FRAME: zero remains unchanged when used read-only");

    /*
     * P5: Relational commutativity over every contract-valid signed pair.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] == sum_ba.coeffs[i],
        "PA02_P5_COMMUTATIVITY: a+b equals b+a coefficient-wise");

    /*
     * P6: Additive identity over the complete int16_t domain.
     */
    __CPROVER_assert(
        identity_result.coeffs[i] == a_before.coeffs[i],
        "PA02_P6_IDENTITY: a+0 equals a coefficient-wise");
  }

  return 0;
}
