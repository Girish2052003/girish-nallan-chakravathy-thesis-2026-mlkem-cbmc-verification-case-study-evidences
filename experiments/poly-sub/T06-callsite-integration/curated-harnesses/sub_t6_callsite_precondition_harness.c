/* SUB-T6 positive harness: T6.1 and T6.2. */
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

  __CPROVER_assert((void *)&v != (void *)&sb,
                   "SUB_T6_T6_1: v and sb must be distinct objects");
  __CPROVER_assert(sizeof(v) == sizeof(mlk_poly),
                   "SUB_T6_T6_1: v must be a complete polynomial object");
  __CPROVER_assert(sizeof(sb) == sizeof(mlk_poly),
                   "SUB_T6_T6_1: sb must be a complete polynomial object");

  v_before = v;
  sb_before = sb;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)v_before.coeffs[i] -
        (int32_t)sb_before.coeffs[i];

    __CPROVER_assert(d >= INT16_MIN,
                     "SUB_T6_T6_2_LOWER: subtraction must fit int16_t");
    __CPROVER_assert(d <= INT16_MAX,
                     "SUB_T6_T6_2_UPPER: subtraction must fit int16_t");
  }

  mlk_poly_sub(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)v_before.coeffs[i] -
        (int32_t)sb_before.coeffs[i];

    __CPROVER_assert((int32_t)v.coeffs[i] == d,
                     "SUB_T6_T6_2_ANCHOR: actual call must realize derived subtraction");
  }

  return 0;
}
