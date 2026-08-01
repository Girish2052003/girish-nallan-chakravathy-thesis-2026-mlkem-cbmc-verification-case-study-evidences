/* SUB-T6 positive harness: T6.6 and T6.7 slice boundary. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  mlk_poly reduced_before_tomsg;
  uint8_t message[MLKEM_INDCPA_MSGBYTES];
  unsigned i;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  v_before = v;
  sb_before = sb;

  mlk_poly_sub(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert((int32_t)v.coeffs[i] == expected,
                     "SUB_T6_T6_6_SUB_ANCHOR: subtraction before reduction must be exact");
  }

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(v.coeffs[i] >= 0,
                     "SUB_T6_T6_6_PRE_LOWER: tomsg input must be nonnegative");
    __CPROVER_assert(v.coeffs[i] < SUB_T6_FIPS_Q,
                     "SUB_T6_T6_6_PRE_UPPER: tomsg input must be below q");
  }

  reduced_before_tomsg = v;
  mlk_poly_tomsg(message, &v);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(v.coeffs[i] == reduced_before_tomsg.coeffs[i],
                     "SUB_T6_T6_6_CONST_INPUT: tomsg must preserve its polynomial input");
  }

  return 0;
}
