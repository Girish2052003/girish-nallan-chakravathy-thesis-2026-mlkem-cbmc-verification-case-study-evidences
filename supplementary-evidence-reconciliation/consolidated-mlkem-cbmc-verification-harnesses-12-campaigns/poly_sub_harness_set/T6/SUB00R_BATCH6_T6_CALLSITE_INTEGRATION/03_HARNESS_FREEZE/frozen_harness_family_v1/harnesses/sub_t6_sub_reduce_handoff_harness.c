/* SUB-T6 positive harness: T6.5. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  mlk_poly sub_result;
  unsigned i;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  v_before = v;
  sb_before = sb;

  mlk_poly_sub(&v, &sb);
  sub_result = v;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert((int32_t)sub_result.coeffs[i] == expected,
                     "SUB_T6_T6_5_SUB: handoff input must be the exact subtraction");
  }

  mlk_poly_reduce(&v);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(v.coeffs[i] >= 0,
                     "SUB_T6_T6_5_REDUCE_LOWER: reduction output must be nonnegative");
    __CPROVER_assert(v.coeffs[i] < SUB_T6_FIPS_Q,
                     "SUB_T6_T6_5_REDUCE_UPPER: reduction output must be below q");
  }

  return 0;
}
