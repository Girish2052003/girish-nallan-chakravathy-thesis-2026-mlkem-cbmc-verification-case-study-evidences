/*
 * PA-02B: Signed/non-canonical modulo-q refinement CBMC harness
 *          for mlk_poly_add
 *
 * Derived from the authoritative parent harness:
 *   pa02_mlk_poly_add_full_signed_contract_valid_harness.c
 *
 * Companion decomposition:
 *   PA-02A proves the primary exact signed-addition theorem.
 *   PA-02B directly proves the corresponding Z_q refinement properties.
 *
 * Target repository:
 *   pq-code-package/mlkem-native
 * Target commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 *
 * Primary verification objective:
 *   Verify the portable production mlk_poly_add implementation for every
 *   pair of signed int16_t coefficient arrays whose coefficient-wise exact
 *   mathematical sums are representable in int16_t, including negative and
 *   non-canonical representatives.
 *
 * Directly encoded properties:
 *   P1. The concrete result equals the exact signed mathematical sum.
 *       This bridge keeps PA-02B self-contained and prevents the modulo-q
 *       claims from depending on an external PA-02A result.
 *   P2. The concrete result is congruent modulo q to the exact mathematical
 *       sum of the original signed/non-canonical operands.
 *   P3. The concrete result's canonical residue equals addition in Z_q of
 *       the canonical residues of both original operands.
 *   P4. The reference canonicalisation helper is verified once over every
 *       int16_t representative: its output is canonical and congruent to
 *       its input modulo q.
 *   P5. Both independent source objects remain unchanged.
 *
 * Retained proof strength:
 *   - all MLKEM_N == 256 coefficients are symbolic;
 *   - each operand coefficient ranges over the complete int16_t domain;
 *   - the sole semantic restriction is the necessary representability
 *     precondition for mlk_poly_add's int16_t result;
 *   - the real portable production function body is executed once;
 *   - target/source object separation is explicit;
 *   - the runner enables bounds, pointer, overflow, conversion, division,
 *     shift, and complete-loop-unwinding checks.
 *
 * Decomposition boundary:
 *   Commutativity and additive identity remain separate relational proof
 *   obligations. Excluding their additional production calls here reduces
 *   solver growth without narrowing PA-02B's input domain or modulo-q claim.
 *
 * Important scope:
 *   This harness does not claim representability when an exact mathematical
 *   sum lies outside [INT16_MIN, INT16_MAX]. PA-03 is the unrestricted
 *   negative-control experiment for that excluded domain.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * CBMC treats the uninitialised local value as symbolic. A real function
 * body avoids a "no body for callee" verification failure.
 */
static int16_t pa02b_nondet_int16(void)
{
  int16_t value;
  return value;
}

/*
 * Map a signed representative to its unique canonical residue in [0, q-1].
 * C remainder may be negative, so one q is added exactly when required.
 */
static int32_t pa02b_mod_q(int32_t value)
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
  mlk_poly result;

  unsigned i;
  int32_t mathematical_sum;
  int32_t actual_residue;
  int32_t exact_sum_residue;
  int32_t canonical_left_residue;
  int32_t canonical_right_residue;
  int32_t canonical_operand_sum_residue;
  int32_t helper_input;
  int32_t helper_residue;

  /*
   * Bind the experiment to the intended ML-KEM ring and signed coefficient
   * representation. Assertions make an incompatible build fail visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PA02B_PARAMETER_BINDING: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PA02B_PARAMETER_BINDING: MLKEM_Q must equal 3329");
  __CPROVER_assert(INT16_MIN == -32768,
                   "PA02B_REPRESENTATION_BINDING: INT16_MIN must equal -32768");
  __CPROVER_assert(INT16_MAX == 32767,
                   "PA02B_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Concrete witnesses document that the contract-valid domain contains
   * canonical, negative, and non-canonical signed representatives.
   */
  __CPROVER_assert(
      ((int32_t)0 + (int32_t)0) >= (int32_t)INT16_MIN &&
          ((int32_t)0 + (int32_t)0) <= (int32_t)INT16_MAX,
      "PA02B_DOMAIN_WITNESS_CANONICAL: zero plus zero is contract-valid");
  __CPROVER_assert(
      ((int32_t)-1 + (int32_t)1) >= (int32_t)INT16_MIN &&
          ((int32_t)-1 + (int32_t)1) <= (int32_t)INT16_MAX,
      "PA02B_DOMAIN_WITNESS_SIGNED: negative plus positive is contract-valid");
  __CPROVER_assert(
      ((int32_t)MLKEM_Q + (int32_t)(-MLKEM_Q)) >= (int32_t)INT16_MIN &&
          ((int32_t)MLKEM_Q + (int32_t)(-MLKEM_Q)) <= (int32_t)INT16_MAX,
      "PA02B_DOMAIN_WITNESS_NONCANONICAL: non-canonical representatives are contract-valid");

  /*
   * P4 helper lemma: verify the reference abstraction once for every signed
   * int16_t representative. All later helper inputs are within this range:
   * operands and contract-valid results are int16_t, while a sum of two
   * canonical residues is in [0, 2q-2] and therefore also fits in int16_t.
   */
  helper_input = (int32_t)pa02b_nondet_int16();
  helper_residue = pa02b_mod_q(helper_input);

  __CPROVER_assert(
      helper_residue >= 0 && helper_residue < (int32_t)MLKEM_Q,
      "PA02B_P4_HELPER_RANGE: canonicalisation returns a residue in [0,q-1]");
  __CPROVER_assert(
      (helper_input - helper_residue) % (int32_t)MLKEM_Q == 0,
      "PA02B_P4_HELPER_CONGRUENCE: canonicalisation preserves the residue class modulo q");

  /*
   * Generate arbitrary signed int16_t coefficients.
   *
   * The only semantic assumption is the necessary contract-validity rule:
   *
   *   INT16_MIN <= a[i] + b[i] <= INT16_MAX.
   *
   * It is stated in int32_t, where every sum of two int16_t values is
   * representable, so the assumption expression itself cannot overflow.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa02b_nondet_int16();
    b.coeffs[i] = pa02b_nondet_int16();

    mathematical_sum =
        (int32_t)a.coeffs[i] + (int32_t)b.coeffs[i];

    __CPROVER_assume(mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(mathematical_sum <= (int32_t)INT16_MAX);
  }

  /* Preserve the complete symbolic operands for post-state comparison. */
  a_before = a;
  b_before = b;

  /* mlk_poly_add is in-place in its first argument, so result starts as a. */
  result = a;

  /* Explicitly state the legal object-separation boundary. */
  __CPROVER_assert(&result != &a,
                   "PA02B_DISJOINTNESS: result and a are distinct objects");
  __CPROVER_assert(&result != &b,
                   "PA02B_DISJOINTNESS: result and b are distinct objects");
  __CPROVER_assert(&a != &b,
                   "PA02B_DISJOINTNESS: a and b are distinct objects");

  /* Execute the portable production implementation exactly once. */
  mlk_poly_add(&result, &b);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)b_before.coeffs[i];

    actual_residue = pa02b_mod_q((int32_t)result.coeffs[i]);
    exact_sum_residue = pa02b_mod_q(mathematical_sum);
    canonical_left_residue =
        pa02b_mod_q((int32_t)a_before.coeffs[i]);
    canonical_right_residue =
        pa02b_mod_q((int32_t)b_before.coeffs[i]);
    canonical_operand_sum_residue =
        pa02b_mod_q(canonical_left_residue + canonical_right_residue);

    /*
     * P1: Self-contained exact-addition bridge over the full contract-valid
     * signed domain. PA-02B therefore does not assume PA-02A's conclusion.
     */
    __CPROVER_assert(
        (int32_t)result.coeffs[i] == mathematical_sum,
        "PA02B_P1_EXACT_SIGNED_BRIDGE: result equals the exact mathematical sum");

    /*
     * P2: The concrete signed/non-canonical result represents the same
     * element of Z_q as the exact mathematical sum.
     */
    __CPROVER_assert(
        actual_residue == exact_sum_residue,
        "PA02B_P2_MOD_Q_CONGRUENCE: result is congruent to the exact sum modulo q");

    /*
     * P3: The result agrees with addition in Z_q after independently
     * canonicalising both original signed/non-canonical operands.
     */
    __CPROVER_assert(
        actual_residue == canonical_operand_sum_residue,
        "PA02B_P3_CANONICAL_RESIDUE_REFINEMENT: result matches canonical operand addition");

    /* P5: Both independent source objects retain their original values. */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "PA02B_P5_LEFT_SOURCE_FRAME: a remains unchanged");
    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "PA02B_P5_RIGHT_OPERAND_FRAME: b remains unchanged");
  }

  return 0;
}
