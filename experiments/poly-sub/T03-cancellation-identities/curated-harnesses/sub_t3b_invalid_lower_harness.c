#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  int32_t s;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[0] = INT16_MIN;
  B.coeffs[0] = -1;
  s = (int32_t)R.coeffs[0] + (int32_t)B.coeffs[0];
  __CPROVER_assert(s >= INT16_MIN,
                   "SUB_T3B_INVALID_LOWER_CONTROL: deliberately outside domain");
  mlk_poly_add(&R, &B);
  return 0;
}
