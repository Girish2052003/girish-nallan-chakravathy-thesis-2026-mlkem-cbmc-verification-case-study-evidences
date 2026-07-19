/*
 * SUB-T5 positive harness: T5.3 cross-coefficient non-interference and
 * T5.4 exact changed-coordinate effect.
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
  mlk_poly saved_A1;
  mlk_poly saved_A2;
  mlk_poly saved_B1;
  mlk_poly saved_B2;
  unsigned i;
  unsigned j;
  int32_t changed_d1;
  int32_t changed_d2;

  sub_t5_check_machine_model();
  j = nondet_unsigned();
  __CPROVER_assume(j < MLKEM_N);

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

    if (i != j)
    {
      __CPROVER_assume(A1.coeffs[i] == A2.coeffs[i]);
      __CPROVER_assume(B1.coeffs[i] == B2.coeffs[i]);
    }
  }

  __CPROVER_assume(A1.coeffs[j] != A2.coeffs[j] ||
                   B1.coeffs[j] != B2.coeffs[j]);

  saved_A1 = A1;
  saved_A2 = A2;
  saved_B1 = B1;
  saved_B2 = B2;
  R1 = A1;
  R2 = A2;

  mlk_poly_sub(&R1, &B1);
  mlk_poly_sub(&R2, &B2);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d1;
    int32_t d2;

    d1 = (int32_t)saved_A1.coeffs[i] - (int32_t)saved_B1.coeffs[i];
    d2 = (int32_t)saved_A2.coeffs[i] - (int32_t)saved_B2.coeffs[i];

    __CPROVER_assert((int32_t)R1.coeffs[i] == d1,
                     "SUB_T5_T5_4_EXACT_R1: first output must equal its matching subtraction");
    __CPROVER_assert((int32_t)R2.coeffs[i] == d2,
                     "SUB_T5_T5_4_EXACT_R2: second output must equal its matching subtraction");

    if (i != j)
    {
      __CPROVER_assert(R1.coeffs[i] == R2.coeffs[i],
                       "SUB_T5_T5_3_NONINTERFERENCE: changing j must not change output i != j");
    }
  }

  changed_d1 = (int32_t)saved_A1.coeffs[j] -
               (int32_t)saved_B1.coeffs[j];
  changed_d2 = (int32_t)saved_A2.coeffs[j] -
               (int32_t)saved_B2.coeffs[j];

  __CPROVER_assert((int32_t)R1.coeffs[j] == changed_d1,
                   "SUB_T5_T5_4_CHANGED_R1: changed coordinate R1 must be exact");
  __CPROVER_assert((int32_t)R2.coeffs[j] == changed_d2,
                   "SUB_T5_T5_4_CHANGED_R2: changed coordinate R2 must be exact");
  __CPROVER_assert(
      (int32_t)R1.coeffs[j] - (int32_t)R2.coeffs[j] ==
          changed_d1 - changed_d2,
      "SUB_T5_T5_4_RELATIONAL_EFFECT: widened changed-coordinate effect must be exact");

  return 0;
}
