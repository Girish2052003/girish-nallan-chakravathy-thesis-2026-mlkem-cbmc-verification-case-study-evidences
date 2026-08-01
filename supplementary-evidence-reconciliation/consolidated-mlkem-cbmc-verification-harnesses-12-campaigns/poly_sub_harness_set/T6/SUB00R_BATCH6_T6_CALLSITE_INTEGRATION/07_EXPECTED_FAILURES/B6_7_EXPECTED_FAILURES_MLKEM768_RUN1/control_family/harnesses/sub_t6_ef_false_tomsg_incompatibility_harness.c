#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly reduced_before_tomsg;
  uint8_t message[MLKEM_INDCPA_MSGBYTES];
  unsigned i;
  int incompatible;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  mlk_poly_sub(&v, &sb);
  mlk_poly_reduce(&v);

  reduced_before_tomsg = v;
  incompatible = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        v.coeffs[i] >= 0,
        "SUB_T6_EF_T6_3_ANCHOR_LOWER: tomsg input must be nonnegative");

    __CPROVER_assert(
        v.coeffs[i] < SUB_T6_FIPS_Q,
        "SUB_T6_EF_T6_3_ANCHOR_UPPER: tomsg input must be below q");

    if (v.coeffs[i] < 0 ||
        v.coeffs[i] >= SUB_T6_FIPS_Q)
    {
      incompatible = 1;
    }
  }

  mlk_poly_tomsg(message, &v);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        v.coeffs[i] == reduced_before_tomsg.coeffs[i],
        "SUB_T6_EF_T6_3_CONST_INPUT: tomsg must preserve the polynomial");
  }

  __CPROVER_assert(
      incompatible,
      "SUB_T6_EF_T6_3_EXPECTED_FAILURE: reduced tomsg input is incompatible");

  return 0;
}
