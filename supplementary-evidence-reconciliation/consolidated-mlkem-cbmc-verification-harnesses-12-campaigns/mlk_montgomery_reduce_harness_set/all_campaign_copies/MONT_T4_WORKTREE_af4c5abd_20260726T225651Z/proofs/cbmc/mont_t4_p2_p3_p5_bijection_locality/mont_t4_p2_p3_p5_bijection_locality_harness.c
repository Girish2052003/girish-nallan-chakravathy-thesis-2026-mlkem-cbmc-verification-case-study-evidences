#include <stdint.h>

#include "poly.h"

extern mlk_poly nondet_mlk_poly(void);
extern unsigned nondet_unsigned(void);

void mlk_poly_tomont_c(mlk_poly *r);

static int32_t canonical_q(int32_t value)
{
  int32_t residue = value % MLKEM_Q;

  if (residue < 0)
  {
    residue += MLKEM_Q;
  }

  return residue;
}

void harness(void)
{
  mlk_poly left;
  mlk_poly right;
  mlk_poly left_before;
  mlk_poly right_before;
  unsigned k;
  __CPROVER_bool input_residues_equal;
  __CPROVER_bool output_residues_equal;

  left = nondet_mlk_poly();
  right = nondet_mlk_poly();

  left_before = left;
  right_before = right;

  k = nondet_unsigned();
  __CPROVER_assume(k < MLKEM_N);

  mlk_poly_tomont_c(&left);
  mlk_poly_tomont_c(&right);

  input_residues_equal =
      canonical_q((int32_t)left_before.coeffs[k]) ==
      canonical_q((int32_t)right_before.coeffs[k]);

  output_residues_equal =
      canonical_q((int32_t)left.coeffs[k]) ==
      canonical_q((int32_t)right.coeffs[k]);

  __CPROVER_assert(
      !input_residues_equal || output_residues_equal,
      "MONT-T4.P2.residue_equivalence_preservation_stronger_local_form");

  __CPROVER_assert(
      !output_residues_equal || input_residues_equal,
      "MONT-T4.P3.residue_equivalence_reflection_stronger_local_form");

  __CPROVER_assert(
      left_before.coeffs[k] != right_before.coeffs[k] ||
          left.coeffs[k] == right.coeffs[k],
      "MONT-T4.P5.coefficient_locality_no_cross_talk");
}
