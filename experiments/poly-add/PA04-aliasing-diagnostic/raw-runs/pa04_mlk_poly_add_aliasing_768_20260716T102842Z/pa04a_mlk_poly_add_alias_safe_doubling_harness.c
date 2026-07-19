/*
 * PA-04A: Safe-domain aliasing diagnostic for mlk_poly_add
 *
 * This is an out-of-contract implementation diagnostic. A successful
 * result does not amend the API contract or establish that production
 * callers may alias r and b.
 *
 * Expected CBMC result: VERIFICATION SUCCESSFUL
 *
 * Target repository commit:
 * d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa04a_nondet_int16(void)
{
  int16_t value;
  return value;
}

static int32_t pa04a_mod_q(int32_t value)
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
  mlk_poly aliased;
  mlk_poly aliased_before;

  mlk_poly disjoint_accumulator;
  mlk_poly disjoint_operand;
  mlk_poly disjoint_operand_before;

  mlk_poly *r_alias;
  const mlk_poly *b_alias;

  unsigned i;
  int32_t exact_double;
  int32_t actual_residue;
  int32_t expected_residue;
  int32_t canonical_double_residue;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA04A_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA04A_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA04A_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA04A_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Exact safe-doubling domain:
   *
   *   -16384 <= x <= 16383
   *
   * Therefore:
   *
   *   -32768 <= 2*x <= 32766
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    aliased.coeffs[i] = pa04a_nondet_int16();

    __CPROVER_assume(
        (int32_t)aliased.coeffs[i] >= -16384);

    __CPROVER_assume(
        (int32_t)aliased.coeffs[i] <= 16383);
  }

  aliased_before = aliased;

  /*
   * Construct a legal disjoint execution from the same pre-state.
   * This allows comparison between:
   *
   *   mlk_poly_add(&a, &a)
   *
   * and a legal equal-valued disjoint call.
   */
  disjoint_accumulator = aliased_before;
  disjoint_operand = aliased_before;
  disjoint_operand_before = disjoint_operand;

  r_alias = &aliased;
  b_alias = &aliased;

  __CPROVER_assert(
      r_alias == b_alias,
      "PA04A_ALIAS_BINDING: r and b designate the same object");

  mlk_poly_add(r_alias, b_alias);

  __CPROVER_assert(
      &disjoint_accumulator != &disjoint_operand,
      "PA04A_DISJOINT_REFERENCE: comparison operands are distinct");

  mlk_poly_add(&disjoint_accumulator, &disjoint_operand);

  for (i = 0; i < MLKEM_N; i++)
  {
    exact_double =
        (int32_t)aliased_before.coeffs[i] * (int32_t)2;

    actual_residue =
        pa04a_mod_q((int32_t)aliased.coeffs[i]);

    expected_residue =
        pa04a_mod_q(exact_double);

    canonical_double_residue =
        pa04a_mod_q(
            pa04a_mod_q((int32_t)aliased_before.coeffs[i]) *
            (int32_t)2);

    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] == exact_double,
        "PA04A_P1_ALIAS_EXACT_DOUBLING: aliased a+a equals exact 2*a");

    __CPROVER_assert(
        actual_residue == expected_residue,
        "PA04A_P2_ALIAS_MOD_Q: alias result is congruent to exact doubling");

    __CPROVER_assert(
        actual_residue == canonical_double_residue,
        "PA04A_P3_CANONICAL_RESIDUE_DOUBLING: alias result matches canonical doubling");

    __CPROVER_assert(
        aliased.coeffs[i] == disjoint_accumulator.coeffs[i],
        "PA04A_P4_ALIAS_DISJOINT_EQUIVALENCE: alias result matches legal equal-operand call");

    __CPROVER_assert(
        disjoint_operand.coeffs[i] ==
            disjoint_operand_before.coeffs[i],
        "PA04A_P5_REFERENCE_INPUT_FRAME: disjoint read-only operand remains unchanged");

    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] >= (int32_t)INT16_MIN,
        "PA04A_P6_OUTPUT_LOWER_BOUND: result is at least INT16_MIN");

    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] <= 32766,
        "PA04A_P6_OUTPUT_UPPER_BOUND: result is at most 32766");
  }

  return 0;
}
