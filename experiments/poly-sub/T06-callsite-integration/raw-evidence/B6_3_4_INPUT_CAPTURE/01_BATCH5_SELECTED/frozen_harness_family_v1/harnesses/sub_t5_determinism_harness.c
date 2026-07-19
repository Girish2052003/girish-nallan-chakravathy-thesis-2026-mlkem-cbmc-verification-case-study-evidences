/* SUB-T5 positive harness: T5.5 complete-output determinism. */
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
  mlk_poly saved_B1;
  unsigned i;

  sub_t5_check_machine_model();

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
  saved_A1 = A1;
  saved_B1 = B1;
  R1 = A1;
  R2 = A2;

  mlk_poly_sub(&R1, &B1);
  mlk_poly_sub(&R2, &B2);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)saved_A1.coeffs[i] - (int32_t)saved_B1.coeffs[i];
    __CPROVER_assert((int32_t)R1.coeffs[i] == d,
                     "SUB_T5_T5_5_EXACT_R1: first deterministic output must be exact");
    __CPROVER_assert((int32_t)R2.coeffs[i] == d,
                     "SUB_T5_T5_5_EXACT_R2: second deterministic output must be exact");
    __CPROVER_assert(R1.coeffs[i] == R2.coeffs[i],
                     "SUB_T5_T5_5_DETERMINISM: identical inputs must produce identical outputs");
    __CPROVER_assert(A1.coeffs[i] == A2.coeffs[i],
                     "SUB_T5_T5_5_INPUT_A_EQUALITY: independent A objects must retain equal values");
    __CPROVER_assert(B1.coeffs[i] == B2.coeffs[i],
                     "SUB_T5_T5_5_INPUT_B_EQUALITY: independent B objects must retain equal values");
  }

  return 0;
}
