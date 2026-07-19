/* SUB-T5 reachability companion: genuinely changed index j. */
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
  unsigned j;
  int a_changed;
  int b_changed;

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

  a_changed = (A1.coeffs[j] != A2.coeffs[j]);
  b_changed = (B1.coeffs[j] != B2.coeffs[j]);
  __CPROVER_assume(a_changed || b_changed);

  R1 = A1;
  R2 = A2;
  mlk_poly_sub(&R1, &B1);
  mlk_poly_sub(&R2, &B2);

  for (i = 0u; i < MLKEM_N; i++)
  {
    if (i != j)
    {
      __CPROVER_assert(R1.coeffs[i] == R2.coeffs[i],
                       "SUB_T5_REACH_CHANGED_ANCHOR: off-target output must remain equal");
    }
  }

  __CPROVER_cover(j == 0u && (a_changed || b_changed));
  __CPROVER_cover(j == 255u && (a_changed || b_changed));
  __CPROVER_cover(a_changed && !b_changed);
  __CPROVER_cover(!a_changed && b_changed);
  __CPROVER_cover(a_changed && b_changed);

  return 0;
}
