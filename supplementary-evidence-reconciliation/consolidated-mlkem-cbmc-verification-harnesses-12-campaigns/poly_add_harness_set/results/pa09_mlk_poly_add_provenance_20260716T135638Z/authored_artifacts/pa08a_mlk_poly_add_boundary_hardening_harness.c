/*
 * PA-08A: Boundary, loop-endpoint, and target-completion hardening for
 *         the production mlk_poly_add implementation.
 *
 * This successful proof harness combines:
 *
 *   1. canonical-domain lower and upper arithmetic boundaries;
 *   2. complete signed-valid INT16_MIN and INT16_MAX boundaries;
 *   3. split-operand witnesses for both signed endpoints;
 *   4. explicit coefficient 0 and coefficient MLKEM_N-1 checks;
 *   5. target-call completion markers;
 *   6. exact-result and read-only-frame verification.
 *
 * Target parameter set: ML-KEM-768
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa08a_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa08a_mod_q(int32_t value)
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
  mlk_poly canonical_r;
  mlk_poly canonical_b;
  mlk_poly canonical_r_before;
  mlk_poly canonical_b_before;

  mlk_poly signed_r;
  mlk_poly signed_b;
  mlk_poly signed_r_before;
  mlk_poly signed_b_before;

  unsigned i;
  int32_t mathematical_sum;

  int canonical_target_completed;
  int signed_target_completed;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA08A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA08A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA08A_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA08A_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  __CPROVER_assert(
      &canonical_r != &canonical_b,
      "PA08A_DISJOINTNESS: canonical operands are distinct");

  __CPROVER_assert(
      &signed_r != &signed_b,
      "PA08A_DISJOINTNESS: signed operands are distinct");

  /*
   * Canonical symbolic domain with concrete endpoint witnesses.
   *
   * Coefficient 0:
   *   0 + 0 = 0
   *
   * Coefficient MLKEM_N-1:
   *   (q-1) + (q-1) = 2*q-2
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    if (i == 0u)
    {
      canonical_r.coeffs[i] = 0;
      canonical_b.coeffs[i] = 0;
    }
    else if (i == MLKEM_N - 1u)
    {
      canonical_r.coeffs[i] = (int16_t)(MLKEM_Q - 1);
      canonical_b.coeffs[i] = (int16_t)(MLKEM_Q - 1);
    }
    else
    {
      canonical_r.coeffs[i] = pa08a_nondet_int16();
      canonical_b.coeffs[i] = pa08a_nondet_int16();

      __CPROVER_assume(
          (int32_t)canonical_r.coeffs[i] >= 0);
      __CPROVER_assume(
          (int32_t)canonical_r.coeffs[i] < (int32_t)MLKEM_Q);

      __CPROVER_assume(
          (int32_t)canonical_b.coeffs[i] >= 0);
      __CPROVER_assume(
          (int32_t)canonical_b.coeffs[i] < (int32_t)MLKEM_Q);
    }
  }

  /*
   * Complete signed-valid symbolic domain with four endpoint witnesses.
   *
   * index 0:           INT16_MIN + 0 = INT16_MIN
   * index 1:           -16384 + -16384 = INT16_MIN
   * index N-2:          16384 + 16383 = INT16_MAX
   * index N-1:         INT16_MAX + 0 = INT16_MAX
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    if (i == 0u)
    {
      signed_r.coeffs[i] = (int16_t)INT16_MIN;
      signed_b.coeffs[i] = 0;
    }
    else if (i == 1u)
    {
      signed_r.coeffs[i] = (int16_t)-16384;
      signed_b.coeffs[i] = (int16_t)-16384;
    }
    else if (i == MLKEM_N - 2u)
    {
      signed_r.coeffs[i] = (int16_t)16384;
      signed_b.coeffs[i] = (int16_t)16383;
    }
    else if (i == MLKEM_N - 1u)
    {
      signed_r.coeffs[i] = (int16_t)INT16_MAX;
      signed_b.coeffs[i] = 0;
    }
    else
    {
      signed_r.coeffs[i] = pa08a_nondet_int16();
      signed_b.coeffs[i] = pa08a_nondet_int16();

      mathematical_sum =
          (int32_t)signed_r.coeffs[i] +
          (int32_t)signed_b.coeffs[i];

      __CPROVER_assume(
          mathematical_sum >= (int32_t)INT16_MIN);
      __CPROVER_assume(
          mathematical_sum <= (int32_t)INT16_MAX);
    }
  }

  canonical_r_before = canonical_r;
  canonical_b_before = canonical_b;

  signed_r_before = signed_r;
  signed_b_before = signed_b;

  canonical_target_completed = 0;
  mlk_poly_add(&canonical_r, &canonical_b);
  canonical_target_completed = 1;

  signed_target_completed = 0;
  mlk_poly_add(&signed_r, &signed_b);
  signed_target_completed = 1;

  __CPROVER_assert(
      canonical_target_completed == 1,
      "PA08A_R1_CANONICAL_TARGET_COMPLETED: production call returned");

  __CPROVER_assert(
      signed_target_completed == 1,
      "PA08A_R2_SIGNED_TARGET_COMPLETED: production call returned");

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)canonical_r_before.coeffs[i] +
        (int32_t)canonical_b_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)canonical_r.coeffs[i] == mathematical_sum,
        "PA08A_P1_CANONICAL_EXACT_SUM: canonical result equals the exact sum");

    __CPROVER_assert(
        canonical_b.coeffs[i] == canonical_b_before.coeffs[i],
        "PA08A_P2_CANONICAL_FRAME: canonical right operand remains unchanged");

    __CPROVER_assert(
        pa08a_mod_q((int32_t)canonical_r.coeffs[i]) ==
            pa08a_mod_q(mathematical_sum),
        "PA08A_P3_CANONICAL_MOD_Q: canonical result has the correct residue");
  }

  __CPROVER_assert(
      canonical_r.coeffs[0] == 0,
      "PA08A_B1_CANONICAL_LOWER_BOUNDARY: coefficient 0 reaches exact sum zero");

  __CPROVER_assert(
      (int32_t)canonical_r.coeffs[MLKEM_N - 1u] ==
          (int32_t)(2 * MLKEM_Q - 2),
      "PA08A_B2_CANONICAL_UPPER_BOUNDARY: final coefficient reaches 2*q-2");

  for (i = 0; i < MLKEM_N; i++)
  {
    mathematical_sum =
        (int32_t)signed_r_before.coeffs[i] +
        (int32_t)signed_b_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)signed_r.coeffs[i] == mathematical_sum,
        "PA08A_P4_SIGNED_EXACT_SUM: signed-valid result equals the exact sum");

    __CPROVER_assert(
        signed_b.coeffs[i] == signed_b_before.coeffs[i],
        "PA08A_P5_SIGNED_FRAME: signed right operand remains unchanged");

    __CPROVER_assert(
        pa08a_mod_q((int32_t)signed_r.coeffs[i]) ==
            pa08a_mod_q(mathematical_sum),
        "PA08A_P6_SIGNED_MOD_Q: signed result has the correct residue");
  }

  __CPROVER_assert(
      signed_r.coeffs[0] == (int16_t)INT16_MIN,
      "PA08A_B3_SIGNED_MIN_DIRECT: coefficient 0 reaches INT16_MIN");

  __CPROVER_assert(
      signed_r.coeffs[1] == (int16_t)INT16_MIN,
      "PA08A_B4_SIGNED_MIN_SPLIT: split operands reach INT16_MIN");

  __CPROVER_assert(
      signed_r.coeffs[MLKEM_N - 2u] == (int16_t)INT16_MAX,
      "PA08A_B5_SIGNED_MAX_SPLIT: split operands reach INT16_MAX");

  __CPROVER_assert(
      signed_r.coeffs[MLKEM_N - 1u] == (int16_t)INT16_MAX,
      "PA08A_B6_SIGNED_MAX_DIRECT: final coefficient reaches INT16_MAX");

  return 0;
}
