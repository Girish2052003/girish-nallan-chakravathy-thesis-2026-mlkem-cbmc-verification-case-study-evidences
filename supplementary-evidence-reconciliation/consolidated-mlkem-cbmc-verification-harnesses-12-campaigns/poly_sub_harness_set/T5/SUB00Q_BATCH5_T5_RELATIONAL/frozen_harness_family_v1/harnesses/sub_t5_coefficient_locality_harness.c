/* SUB-T5 positive harness: T5.2 symbolic coefficient locality. */
#include "sub00q_b5_harness_common.h"

int main(void)
{
  mlk_poly A1;
  mlk_poly A2;
  mlk_poly B1;
  mlk_poly B2;
  mlk_poly R1;
  mlk_poly R2;
  mlk_poly saved_A1;
  mlk_poly saved_A2;
  mlk_poly saved_B1;
  mlk_poly saved_B2;
  unsigned i;
  unsigned k;
  int32_t d1;
  int32_t d2;

  sub_t5_check_machine_model();
  k = nondet_unsigned();
  __CPROVER_assume(k < MLKEM_N);

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

  saved_A1 = A1;
  saved_A2 = A2;
  saved_B1 = B1;
  saved_B2 = B2;
  R1 = A1;
  R2 = A2;

  mlk_poly_sub(&R1, &B1);
  mlk_poly_sub(&R2, &B2);

  d1 = (int32_t)saved_A1.coeffs[k] - (int32_t)saved_B1.coeffs[k];
  d2 = (int32_t)saved_A2.coeffs[k] - (int32_t)saved_B2.coeffs[k];

  __CPROVER_assert((int32_t)R1.coeffs[k] == d1,
                   "SUB_T5_T5_2_EXACT_R1_K: first local output must be exact");
  __CPROVER_assert((int32_t)R2.coeffs[k] == d2,
                   "SUB_T5_T5_2_EXACT_R2_K: second local output must be exact");
  __CPROVER_assert(R1.coeffs[k] == R2.coeffs[k],
                   "SUB_T5_T5_2_LOCALITY: equal local inputs must imply equal local outputs");

  return 0;
}
