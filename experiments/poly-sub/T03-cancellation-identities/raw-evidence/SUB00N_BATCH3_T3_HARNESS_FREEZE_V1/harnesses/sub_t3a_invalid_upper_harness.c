#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  int32_t d;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[0] = INT16_MAX;
  B.coeffs[0] = -1;
  d = (int32_t)R.coeffs[0] - (int32_t)B.coeffs[0];
  __CPROVER_assert(d <= INT16_MAX,
                   "SUB_T3A_INVALID_UPPER_CONTROL: deliberately outside domain");
  mlk_poly_sub(&R, &B);
  return 0;
}
