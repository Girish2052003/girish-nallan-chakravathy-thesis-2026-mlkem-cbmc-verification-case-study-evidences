#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[0] = (int16_t)(INT16_MIN + 1);
  B.coeffs[0] = 1;
  __CPROVER_assert((int32_t)R.coeffs[0] - B.coeffs[0] == INT16_MIN,
                   "SUB_T3A_VALID_LOWER: difference equals INT16_MIN");
  mlk_poly_sub(&R, &B);
  mlk_poly_add(&R, &B);
  __CPROVER_assert(R.coeffs[0] == (int16_t)(INT16_MIN + 1),
                   "SUB_T3A_VALID_LOWER: cancellation succeeds");
  return 0;
}
