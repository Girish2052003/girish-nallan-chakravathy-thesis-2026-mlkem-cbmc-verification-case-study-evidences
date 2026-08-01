#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  unsigned i;
  int outside_exists;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  mlk_poly_sub(&v, &sb);
  mlk_poly_reduce(&v);

  outside_exists = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        v.coeffs[i] >= 0,
        "SUB_T6_EF_T6_2_ANCHOR_LOWER: reduced output must be nonnegative");

    __CPROVER_assert(
        v.coeffs[i] < SUB_T6_FIPS_Q,
        "SUB_T6_EF_T6_2_ANCHOR_UPPER: reduced output must be below q");

    if (v.coeffs[i] < 0 ||
        v.coeffs[i] >= SUB_T6_FIPS_Q)
    {
      outside_exists = 1;
    }
  }

  __CPROVER_assert(
      outside_exists,
      "SUB_T6_EF_T6_2_EXPECTED_FAILURE: reduction leaves a noncanonical coefficient");

  return 0;
}
