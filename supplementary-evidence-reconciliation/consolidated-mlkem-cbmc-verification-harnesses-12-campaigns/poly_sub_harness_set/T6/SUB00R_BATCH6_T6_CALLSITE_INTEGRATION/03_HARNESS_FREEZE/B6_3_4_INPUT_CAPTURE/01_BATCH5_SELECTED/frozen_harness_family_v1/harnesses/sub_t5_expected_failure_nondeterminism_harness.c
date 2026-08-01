/*
 * SUB-T5 expected-failure control EF-T5-2.
 * The final assertion is deliberately false and must be rejected.
 */
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
  unsigned target_i;

  sub_t5_check_machine_model();
  target_i = nondet_unsigned();
  __CPROVER_assume(target_i < MLKEM_N);

  for (i = 0u; i < MLKEM_N; i++)
  {
    A1.coeffs[i] = nondet_int16_t();
    B1.coeffs[i] = nondet_int16_t();
    __CPROVER_assume(A1.coeffs[i] >= 0);
    __CPROVER_assume(A1.coeffs[i] < SUB_T5_FIPS_Q);
    __CPROVER_assume(B1.coeffs[i] >= 0);
    __CPROVER_assume(B1.coeffs[i] < SUB_T5_FIPS_Q);
  }

  A2 = A1;
  B2 = B1;
  R1 = A1;
  R2 = A2;
  mlk_poly_sub(&R1, &B1);
  mlk_poly_sub(&R2, &B2);

  __CPROVER_assert(
      R1.coeffs[target_i] != R2.coeffs[target_i],
      "SUB_T5_EF_T5_2_EXPECTED_FAILURE: identical inputs falsely produce different outputs");

  return 0;
}
