/*
 * PA-02D: Relational commutativity CBMC harness for mlk_poly_add
 *          over the full signed/non-canonical contract-valid int16_t domain
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
 *   Verify relational commutativity of the portable production
 *   mlk_poly_add implementation for every pair of signed int16_t
 *   coefficient arrays whose coefficient-wise exact mathematical sums are
 *   representable in int16_t:
 *
 *     mlk_poly_add(a, b) == mlk_poly_add(b, a)
 *
 *   coefficient-wise, when each call uses legal, disjoint writable and
 *   read-only objects.
 *
 * Retained proof strength:
 *   - all MLKEM_N == 256 coefficients are symbolic;
 *   - each input coefficient ranges over the complete signed int16_t domain;
 *   - negative and non-canonical representatives are included;
 *   - the only arithmetic-domain restriction is the necessary condition
 *     that every exact coefficient sum fits in int16_t;
 *   - the real portable production mlk_poly_add body executes twice, once
 *     for each operand order;
 *   - each directional result is independently tied to its exact int32_t
 *     mathematical sum before the relational equality is asserted;
 *   - both original source objects are proved unchanged;
 *   - the runner enables bounds, pointer, overflow, conversion, division,
 *     shift, and complete-loop-unwinding checks.
 *
 * Decomposition boundary:
 *   PA-02D isolates the commutativity theorem from the original combined
 *   PA-02 harness. PA-02A records the primary exact-addition theorem,
 *   PA-02B records modulo-q refinement, and PA-02C records frame/write-
 *   footprint behaviour. PA-02D is nevertheless self-contained: it proves
 *   exact signed addition independently in both operand orders and does not
 *   assume that any prior campaign succeeded.
 *
 * Important scope:
 *   This harness does not claim defined signed addition when an exact sum is
 *   outside [INT16_MIN, INT16_MAX]. PA-03 is the negative-control experiment
 *   for that excluded domain.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/* CBMC treats the uninitialised local returned by this body as symbolic. */
static int16_t pa02d_nondet_int16(void)
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

  unsigned i;
  int32_t forward_mathematical_sum;
  int32_t reverse_mathematical_sum;

  /*
   * Bind the experiment to the intended representation and FIPS ring
   * parameters. Assertions make an incompatible build fail visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PA02D_PARAMETER_BINDING: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PA02D_PARAMETER_BINDING: MLKEM_Q must equal 3329");
  __CPROVER_assert(INT16_MIN == -32768,
                   "PA02D_REPRESENTATION_BINDING: INT16_MIN must equal -32768");
  __CPROVER_assert(INT16_MAX == 32767,
                   "PA02D_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /* A concrete witness records that the contract-valid domain is non-empty. */
  __CPROVER_assert(
      ((int32_t)0 + (int32_t)0) >= (int32_t)INT16_MIN &&
          ((int32_t)0 + (int32_t)0) <= (int32_t)INT16_MAX,
      "PA02D_DOMAIN_WITNESS: zero plus zero is contract-valid");

  /*
   * Generate arbitrary signed/non-canonical coefficients. The only semantic
   * assumptions are the necessary representability conditions, stated in
   * int32_t so the assumptions themselves cannot overflow.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa02d_nondet_int16();
    b.coeffs[i] = pa02d_nondet_int16();

    forward_mathematical_sum =
        (int32_t)a.coeffs[i] + (int32_t)b.coeffs[i];

    __CPROVER_assume(
        forward_mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(
        forward_mathematical_sum <= (int32_t)INT16_MAX);
  }

  /* Preserve the complete symbolic source pre-states. */
  a_before = a;
  b_before = b;

  /*
   * Prepare independent writable targets for the two operand orders. The
   * source objects remain read-only across both production executions.
   */
  sum_ab = a_before;
  sum_ba = b_before;

  /* Make the legal disjoint-object boundary explicit in the result set. */
  __CPROVER_assert(
      &sum_ab != &b,
      "PA02D_DISJOINTNESS: forward writable target and operand are distinct");
  __CPROVER_assert(
      &sum_ba != &a,
      "PA02D_DISJOINTNESS: reverse writable target and operand are distinct");
  __CPROVER_assert(
      &sum_ab != &sum_ba,
      "PA02D_DISJOINTNESS: forward and reverse targets are distinct");
  __CPROVER_assert(
      &a != &b,
      "PA02D_DISJOINTNESS: original source objects are distinct");

  /* Execute the real portable production implementation in both orders. */
  mlk_poly_add(&sum_ab, &b);
  mlk_poly_add(&sum_ba, &a);

  for (i = 0; i < MLKEM_N; i++)
  {
    forward_mathematical_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)b_before.coeffs[i];
    reverse_mathematical_sum =
        (int32_t)b_before.coeffs[i] + (int32_t)a_before.coeffs[i];

    /*
     * P1: Forward semantic bridge. The a+b production execution equals the
     * exact signed mathematical sum for every contract-valid coefficient.
     */
    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] == forward_mathematical_sum,
        "PA02D_P1_FORWARD_EXACT_SIGNED_SUM: a+b equals the exact mathematical sum");

    /*
     * P2: Reverse semantic bridge. The b+a production execution is checked
     * independently and is not inferred from the forward execution.
     */
    __CPROVER_assert(
        (int32_t)sum_ba.coeffs[i] == reverse_mathematical_sum,
        "PA02D_P2_REVERSE_EXACT_SIGNED_SUM: b+a equals the exact mathematical sum");

    /*
     * P3: Primary relational theorem. Executing production mlk_poly_add in
     * either legal operand order yields the same concrete coefficient.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] == sum_ba.coeffs[i],
        "PA02D_P3_COMMUTATIVITY: production a+b equals production b+a coefficient-wise");

    /*
     * P4-P5: The original symbolic source arrays are read-only across both
     * target executions and remain identical to their complete pre-states.
     */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "PA02D_P4_LEFT_SOURCE_FRAME: a remains unchanged across both calls");
    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "PA02D_P5_RIGHT_SOURCE_FRAME: b remains unchanged across both calls");
  }

  return 0;
}
