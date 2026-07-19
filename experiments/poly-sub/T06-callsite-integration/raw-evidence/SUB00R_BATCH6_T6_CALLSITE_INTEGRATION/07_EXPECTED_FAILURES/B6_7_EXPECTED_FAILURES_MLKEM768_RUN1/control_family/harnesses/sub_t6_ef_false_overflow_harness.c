#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  unsigned i;
  int overflow_exists;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  v_before = v;
  sb_before = sb;
  overflow_exists = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)v_before.coeffs[i] -
        (int32_t)sb_before.coeffs[i];

    if (d < INT16_MIN || d > INT16_MAX)
    {
      overflow_exists = 1;
    }
  }

  mlk_poly_sub(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == expected,
        "SUB_T6_EF_T6_1_ANCHOR: actual subtraction must be exact");
  }

  __CPROVER_assert(
      overflow_exists,
      "SUB_T6_EF_T6_1_EXPECTED_FAILURE: some allowed subtraction exceeds int16_t");

  return 0;
}
