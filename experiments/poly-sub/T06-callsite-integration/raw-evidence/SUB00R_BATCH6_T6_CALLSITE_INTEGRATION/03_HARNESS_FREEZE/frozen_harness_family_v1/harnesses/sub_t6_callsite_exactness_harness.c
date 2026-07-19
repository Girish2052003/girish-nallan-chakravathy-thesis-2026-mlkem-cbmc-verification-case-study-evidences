/* SUB-T6 positive harness: T6.3. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
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

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == expected,
        "SUB_T6_T6_3: production result must equal widened caller-domain subtraction");
  }

  return 0;
}
