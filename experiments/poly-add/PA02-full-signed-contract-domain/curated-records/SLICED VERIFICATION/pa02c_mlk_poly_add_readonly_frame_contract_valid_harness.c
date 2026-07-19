/*
 * PA-02C: Read-only operand and write-footprint CBMC harness
 *          for mlk_poly_add over the full signed/non-canonical
 *          contract-valid int16_t domain
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
 *   Verify that the portable production mlk_poly_add implementation changes
 *   only its writable first polynomial object and preserves its read-only
 *   second polynomial object, for every pair of signed int16_t coefficient
 *   arrays whose coefficient-wise exact sums are representable in int16_t.
 *
 * Retained proof strength:
 *   - all MLKEM_N == 256 coefficients are symbolic;
 *   - each coefficient ranges over the complete signed int16_t domain;
 *   - negative and non-canonical representatives are included;
 *   - the only arithmetic-domain restriction is the necessary condition
 *     that every exact coefficient sum fits in int16_t;
 *   - the real portable production mlk_poly_add body executes exactly once;
 *   - the target post-state is tied to the exact signed mathematical sum;
 *   - the complete read-only operand is proved coefficient-wise unchanged;
 *   - symbolic guard words before and after both polynomial objects are
 *     proved unchanged, strengthening the explicit write-footprint evidence;
 *   - the runner enables bounds, pointer, overflow, conversion, division,
 *     shift, and complete-loop-unwinding checks.
 *
 * Decomposition boundary:
 *   PA-02C isolates the frame/write-footprint theorem from the original
 *   combined PA-02 harness. PA-02A separately records the primary exact-sum
 *   proof and PA-02B separately records the modulo-q refinement proof.
 *   PA-02C nevertheless retains an exact-sum effect assertion so that its
 *   frame result is tied to a semantically correct production execution and
 *   is not merely a no-write observation.
 *
 * Important scope:
 *   This harness does not claim defined signed addition when an exact sum is
 *   outside [INT16_MIN, INT16_MAX]. PA-03 is the negative-control experiment
 *   for that excluded domain.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * Guarded wrappers provide direct, symbolic canaries around each polynomial.
 * CBMC's pointer and bounds checks remain authoritative; the guards provide
 * additional explicit frame/write-footprint properties in the result set.
 */
typedef struct
{
  uint32_t guard_before;
  mlk_poly value;
  uint32_t guard_after;
} pa02c_guarded_poly;

/* CBMC treats uninitialised locals returned by these bodies as symbolic. */
static int16_t pa02c_nondet_int16(void)
{
  int16_t value;
  return value;
}

static uint32_t pa02c_nondet_uint32(void)
{
  uint32_t value;
  return value;
}

int main(void)
{
  pa02c_guarded_poly target_box;
  pa02c_guarded_poly operand_box;

  mlk_poly target_before;
  mlk_poly operand_before;

  uint32_t target_guard_before_snapshot;
  uint32_t target_guard_after_snapshot;
  uint32_t operand_guard_before_snapshot;
  uint32_t operand_guard_after_snapshot;

  unsigned i;
  int32_t mathematical_sum;

  /*
   * Bind the experiment to the intended representation and FIPS ring
   * parameters. Assertions make an incompatible build fail visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PA02C_PARAMETER_BINDING: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PA02C_PARAMETER_BINDING: MLKEM_Q must equal 3329");
  __CPROVER_assert(INT16_MIN == -32768,
                   "PA02C_REPRESENTATION_BINDING: INT16_MIN must equal -32768");
  __CPROVER_assert(INT16_MAX == 32767,
                   "PA02C_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /* A concrete witness records that the contract-valid domain is non-empty. */
  __CPROVER_assert(
      ((int32_t)0 + (int32_t)0) >= (int32_t)INT16_MIN &&
          ((int32_t)0 + (int32_t)0) <= (int32_t)INT16_MAX,
      "PA02C_DOMAIN_WITNESS: zero plus zero is contract-valid");

  /* Symbolic canaries make the surrounding frame obligations universal. */
  target_box.guard_before = pa02c_nondet_uint32();
  target_box.guard_after = pa02c_nondet_uint32();
  operand_box.guard_before = pa02c_nondet_uint32();
  operand_box.guard_after = pa02c_nondet_uint32();

  target_guard_before_snapshot = target_box.guard_before;
  target_guard_after_snapshot = target_box.guard_after;
  operand_guard_before_snapshot = operand_box.guard_before;
  operand_guard_after_snapshot = operand_box.guard_after;

  /*
   * Generate arbitrary signed/non-canonical coefficients. The only semantic
   * assumptions are the necessary representability conditions, stated in
   * int32_t so the assumptions themselves cannot overflow.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    target_box.value.coeffs[i] = pa02c_nondet_int16();
    operand_box.value.coeffs[i] = pa02c_nondet_int16();

    mathematical_sum =
        (int32_t)target_box.value.coeffs[i] +
        (int32_t)operand_box.value.coeffs[i];

    __CPROVER_assume(mathematical_sum >= (int32_t)INT16_MIN);
    __CPROVER_assume(mathematical_sum <= (int32_t)INT16_MAX);
  }

  /* Preserve complete pre-states for post-state and frame comparisons. */
  target_before = target_box.value;
  operand_before = operand_box.value;

  /*
   * Make the legal non-aliasing boundary explicit. The writable target and
   * read-only operand are distinct objects with independently symbolic data.
   */
  __CPROVER_assert(
      &target_box.value != &operand_box.value,
      "PA02C_DISJOINTNESS: writable target and read-only operand are distinct");

  /* Execute the real portable production implementation exactly once. */
  mlk_poly_add(&target_box.value, &operand_box.value);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)target_before.coeffs[i] +
        (int32_t)operand_before.coeffs[i];

    /*
     * P1: Semantic effect bridge. The writable target has exactly the
     * required post-state, so the frame proof concerns a correct execution.
     */
    __CPROVER_assert(
        (int32_t)target_box.value.coeffs[i] == mathematical_sum,
        "PA02C_P1_EXACT_SIGNED_EFFECT: target post-state equals the exact mathematical sum");

    /*
     * P2: The complete second operand, which is read-only by the API, remains
     * coefficient-wise identical to its pre-state.
     */
    __CPROVER_assert(
        operand_box.value.coeffs[i] == operand_before.coeffs[i],
        "PA02C_P2_READONLY_OPERAND_FRAME: second operand remains unchanged");
  }

  /*
   * P3-P6: Symbolic guard words around both objects remain unchanged. These
   * assertions provide explicit local write-footprint evidence in addition
   * to CBMC's enabled pointer and bounds properties.
   */
  __CPROVER_assert(
      target_box.guard_before == target_guard_before_snapshot,
      "PA02C_P3_TARGET_PREFIX_GUARD_FRAME: memory before target is unchanged");
  __CPROVER_assert(
      target_box.guard_after == target_guard_after_snapshot,
      "PA02C_P4_TARGET_SUFFIX_GUARD_FRAME: memory after target is unchanged");
  __CPROVER_assert(
      operand_box.guard_before == operand_guard_before_snapshot,
      "PA02C_P5_OPERAND_PREFIX_GUARD_FRAME: memory before operand is unchanged");
  __CPROVER_assert(
      operand_box.guard_after == operand_guard_after_snapshot,
      "PA02C_P6_OPERAND_SUFFIX_GUARD_FRAME: memory after operand is unchanged");

  return 0;
}
