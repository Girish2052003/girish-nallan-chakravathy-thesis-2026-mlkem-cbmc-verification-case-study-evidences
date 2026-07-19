/*
 * PA-05B: Production call-site obligation for
 *         mlk_poly_add(v, epp) in mlkem/src/indcpa.c.
 *
 * Purpose:
 *   Starting only from the documented postconditions of the two producer
 *   operations immediately relevant to the call site, prove that the exact
 *   sum is representable in int16_t and that production mlk_poly_add is safe
 *   and functionally correct at this call.
 *
 * Producer guarantees modelled:
 *   mlk_poly_invntt_tomont(v):
 *       abs(v[i]) < MLK_INVNTT_BOUND = 8 * MLKEM_Q
 *
 *   mlk_enc_getnoise_eta1_eta2(..., epp, ...):
 *       abs(epp[i]) < MLKEM_ETA2 + 1
 *
 * No safe-sum assumption is made. The call-site representability condition
 * is asserted and must be derived by CBMC from the producer guarantees.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa05b_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa05b_mod_q(int32_t value)
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
  mlk_poly v;
  mlk_poly epp;
  mlk_poly v_before;
  mlk_poly epp_before;

  unsigned i;
  int32_t mathematical_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA05B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA05B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA05B_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA05B_BOUND_BINDING: inverse NTT bound must equal 8*q");

  __CPROVER_assert(
      &v != &epp,
      "PA05B_OBJECT_SEPARATION: v and epp are distinct allocated objects");

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa05b_nondet_int16();
    epp.coeffs[i] = pa05b_nondet_int16();

    /*
     * Producer postcondition from mlk_poly_invntt_tomont(v).
     */
    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    /*
     * Producer postcondition from mlk_enc_getnoise_eta1_eta2(..., epp, ...).
     */
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    mathematical_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    /*
     * These are call-site proof obligations, not assumptions.
     */
    __CPROVER_assert(
        mathematical_sum >= (int32_t)INT16_MIN,
        "PA05B_P1_CALL_PRECONDITION_LOWER: v+epp is representable in int16_t");

    __CPROVER_assert(
        mathematical_sum <= (int32_t)INT16_MAX,
        "PA05B_P1_CALL_PRECONDITION_UPPER: v+epp is representable in int16_t");
  }

  v_before = v;
  epp_before = epp;

  /*
   * Execute the exact production target used at indcpa.c:571.
   */
  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)v_before.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == mathematical_sum,
        "PA05B_P2_EXACT_CALL_RESULT: indcpa v+epp call computes the exact sum");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA05B_P3_RIGHT_INPUT_FRAME: epp remains unchanged");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] >
            -(int32_t)(MLK_INVNTT_BOUND + MLKEM_ETA2),
        "PA05B_P4_DERIVED_OUTPUT_LOWER: result satisfies the derived strict lower bound");

    __CPROVER_assert(
        (int32_t)v.coeffs[i] <
            (int32_t)(MLK_INVNTT_BOUND + MLKEM_ETA2),
        "PA05B_P4_DERIVED_OUTPUT_UPPER: result satisfies the derived strict upper bound");

    __CPROVER_assert(
        pa05b_mod_q((int32_t)v.coeffs[i]) ==
            pa05b_mod_q(mathematical_sum),
        "PA05B_P5_MOD_Q_REFINEMENT: concrete call result represents the correct residue");
  }

  return 0;
}
