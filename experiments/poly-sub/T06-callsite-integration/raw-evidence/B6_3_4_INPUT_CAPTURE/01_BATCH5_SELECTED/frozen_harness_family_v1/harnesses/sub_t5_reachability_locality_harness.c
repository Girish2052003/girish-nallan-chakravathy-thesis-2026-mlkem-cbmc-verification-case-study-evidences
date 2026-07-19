/* SUB-T5 reachability companion: symbolic locality antecedents. */
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
  unsigned k;
  int has_non_target_difference;

  sub_t5_check_machine_model();
  k = nondet_unsigned();
  __CPROVER_assume(k < MLKEM_N);
  has_non_target_difference = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    A1.coeffs[i] = nondet_int16_t();
    A2.coeffs[i] = nondet_int16_t();
    B1.coeffs[i] = nondet_int16_t();
    B2.coeffs[i] = nondet_int16_t();

    __CPROVER_assume(A1.coeffs[i] >= 0);
    __CPROVER_assume(A1.coeffs[i] < SUB_T5_FIPS_Q);
    __CPROVER_assume(A2.coeffs[i] >= 0);
    __CPROVER_assume(A2.coeffs[i] < SUB_T5_FIPS_Q);
    __CPROVER_assume(B1.coeffs[i] >= 0);
    __CPROVER_assume(B1.coeffs[i] < SUB_T5_FIPS_Q);
    __CPROVER_assume(B2.coeffs[i] >= 0);
    __CPROVER_assume(B2.coeffs[i] < SUB_T5_FIPS_Q);
  }

  __CPROVER_assume(A1.coeffs[k] == A2.coeffs[k]);
  __CPROVER_assume(B1.coeffs[k] == B2.coeffs[k]);

  for (i = 0u; i < MLKEM_N; i++)
  {
    if (i != k &&
        (A1.coeffs[i] != A2.coeffs[i] || B1.coeffs[i] != B2.coeffs[i]))
    {
      has_non_target_difference = 1;
    }
  }

  R1 = A1;
  R2 = A2;
  mlk_poly_sub(&R1, &B1);
  mlk_poly_sub(&R2, &B2);

  __CPROVER_assert(R1.coeffs[k] == R2.coeffs[k],
                   "SUB_T5_REACH_LOCALITY_ANCHOR: local equality must hold");

  __CPROVER_cover(has_non_target_difference);
  __CPROVER_cover(k == 0u && has_non_target_difference);
  __CPROVER_cover(k == 127u && has_non_target_difference);
  __CPROVER_cover(k == 255u && has_non_target_difference);

  return 0;
}
