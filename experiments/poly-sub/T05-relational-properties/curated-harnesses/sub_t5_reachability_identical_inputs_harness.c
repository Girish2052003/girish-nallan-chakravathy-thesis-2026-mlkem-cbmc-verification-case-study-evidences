/* SUB-T5 reachability companion: identical complete inputs. */
#include "sub00q_b5_harness_common.h"

int main(void)
{
  mlk_poly A1;
  mlk_poly A2;
  mlk_poly B1;
  mlk_poly B2;
  mlk_poly R1;
  mlk_poly R2;
  unsigned i;
  int has_nontrivial_input;
  int outputs_identical;

  sub_t5_check_machine_model();
  has_nontrivial_input = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    A1.coeffs[i] = nondet_int16_t();
    B1.coeffs[i] = nondet_int16_t();

    __CPROVER_assume(A1.coeffs[i] >= 0);
    __CPROVER_assume(A1.coeffs[i] < SUB_T5_FIPS_Q);
    __CPROVER_assume(B1.coeffs[i] >= 0);
    __CPROVER_assume(B1.coeffs[i] < SUB_T5_FIPS_Q);

    if (A1.coeffs[i] != 0 || B1.coeffs[i] != 0)
    {
      has_nontrivial_input = 1;
    }
  }

  A2 = A1;
  B2 = B1;
  R1 = A1;
  R2 = A2;
  mlk_poly_sub(&R1, &B1);
  mlk_poly_sub(&R2, &B2);

  outputs_identical = 1;
  for (i = 0u; i < MLKEM_N; i++)
  {
    if (R1.coeffs[i] != R2.coeffs[i])
    {
      outputs_identical = 0;
    }
    __CPROVER_assert(R1.coeffs[i] == R2.coeffs[i],
                     "SUB_T5_REACH_DETERMINISM_ANCHOR: identical inputs must yield identical outputs");
  }

  __CPROVER_cover(has_nontrivial_input);
  __CPROVER_cover(has_nontrivial_input && outputs_identical);

  return 0;
}
