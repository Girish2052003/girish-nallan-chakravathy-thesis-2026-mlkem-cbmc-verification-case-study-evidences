#include "sub00r_b6_harness_common.h"

extern unsigned nondet_unsigned(void);

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  mlk_poly sub_result;
  unsigned i;
  unsigned k;

  sub_t6_check_machine_model();

  k = nondet_unsigned();
  __CPROVER_assume(k < MLKEM_N);

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

    __CPROVER_assert(
        (int32_t)sub_result.coeffs[i] == expected,
        "SUB_T6_REACH_ANCHOR_EXACT: subtraction must remain exact");
  }

  __CPROVER_cover(
      v_before.coeffs[k] == 0 &&
      sb_before.coeffs[k] == 26631 &&
      sub_result.coeffs[k] == -26631);

  __CPROVER_cover(
      v_before.coeffs[k] == 3328 &&
      sb_before.coeffs[k] == -26631 &&
      sub_result.coeffs[k] == 29959);

  __CPROVER_cover(
      v_before.coeffs[k] == 0 &&
      sb_before.coeffs[k] == 0 &&
      sub_result.coeffs[k] == 0);

  __CPROVER_cover(sb_before.coeffs[k] > 0);
  __CPROVER_cover(sb_before.coeffs[k] < 0);

  __CPROVER_cover(sub_result.coeffs[k] < 0);
  __CPROVER_cover(sub_result.coeffs[k] == 0);

  __CPROVER_cover(
      sub_result.coeffs[k] > 0 &&
      sub_result.coeffs[k] < SUB_T6_FIPS_Q);

  __CPROVER_cover(
      sub_result.coeffs[k] >= SUB_T6_FIPS_Q);

  __CPROVER_cover(k == 0u);
  __CPROVER_cover(k == 127u);
  __CPROVER_cover(k == 255u);

  mlk_poly_reduce(&v);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        v.coeffs[i] >= 0,
        "SUB_T6_REACH_REDUCE_LOWER: reduced coefficient must be nonnegative");
    __CPROVER_assert(
        v.coeffs[i] < SUB_T6_FIPS_Q,
        "SUB_T6_REACH_REDUCE_UPPER: reduced coefficient must be below q");
  }

  return 0;
}
