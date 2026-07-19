#include "sub_t3_common.h"
int main(void)
{
  mlk_poly R, B;
  sub_t3_check_machine_model();
  sub_t3_zero_poly(&R);
  sub_t3_zero_poly(&B);
  R.coeffs[MLKEM_N - 1u] = (int16_t)(INT16_MAX - 1);
  B.coeffs[MLKEM_N - 1u] = -1;
  __CPROVER_assert((int32_t)R.coeffs[MLKEM_N - 1u] -
                       B.coeffs[MLKEM_N - 1u] == INT16_MAX,
                   "SUB_T3A_VALID_UPPER: difference equals INT16_MAX");
  mlk_poly_sub(&R, &B);
  mlk_poly_add(&R, &B);
  __CPROVER_assert(R.coeffs[MLKEM_N - 1u] ==
                       (int16_t)(INT16_MAX - 1),
                   "SUB_T3A_VALID_UPPER: cancellation succeeds");
  return 0;
}
