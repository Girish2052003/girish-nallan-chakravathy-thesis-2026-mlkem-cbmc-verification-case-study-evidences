#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A;
  mlk_poly B;
  mlk_poly X;
  mlk_poly NB;
  uint32_t i;

  int has_positive_b = 0;
  int has_negative_b = 0;
  int has_zero_b = 0;
  int has_positive_difference = 0;
  int has_negative_difference = 0;
  int has_zero_difference = 0;
  int has_noncanonical_positive_a = 0;
  int has_noncanonical_negative_a = 0;
  int has_noncanonical_positive_b = 0;
  int has_noncanonical_negative_b = 0;
  int has_valid_difference_min = 0;
  int has_valid_difference_max = 0;
  int has_valid_addition_min = 0;
  int has_valid_addition_max = 0;
  int coefficient_0_nontrivial = 0;
  int coefficient_255_nontrivial = 0;
  int recovery_sum_0 = 0;
  int recovery_sum_q_minus_1 = 0;
  int recovery_sum_q = 0;
  int recovery_sum_2q_minus_2 = 0;
  int recovery_without_wrap = 0;
  int recovery_with_wrap = 0;

  sub_t3_check_machine_model();

  for (i = 0u; i < MLKEM_N; i++)
  {
    int16_t a_i;
    int16_t b_i;
    int32_t d;
    int32_t s;

    A.coeffs[i] = a_i;
    B.coeffs[i] = b_i;

    d = (int32_t)a_i - (int32_t)b_i;
    s = (int32_t)a_i + (int32_t)b_i;

    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);
    __CPROVER_assume(s >= (int32_t)INT16_MIN);
    __CPROVER_assume(s <= (int32_t)INT16_MAX);

    if (b_i > 0) has_positive_b = 1;
    if (b_i < 0) has_negative_b = 1;
    if (b_i == 0) has_zero_b = 1;
    if (d > 0) has_positive_difference = 1;
    if (d < 0) has_negative_difference = 1;
    if (d == 0) has_zero_difference = 1;
    if (a_i >= SUB_T3_FIPS_Q) has_noncanonical_positive_a = 1;
    if (a_i < 0) has_noncanonical_negative_a = 1;
    if (b_i >= SUB_T3_FIPS_Q) has_noncanonical_positive_b = 1;
    if (b_i < 0) has_noncanonical_negative_b = 1;
    if (d == (int32_t)INT16_MIN) has_valid_difference_min = 1;
    if (d == (int32_t)INT16_MAX) has_valid_difference_max = 1;
    if (s == (int32_t)INT16_MIN) has_valid_addition_min = 1;
    if (s == (int32_t)INT16_MAX) has_valid_addition_max = 1;
  }

  if (A.coeffs[0] != B.coeffs[0]) coefficient_0_nontrivial = 1;
  if (A.coeffs[MLKEM_N - 1u] != B.coeffs[MLKEM_N - 1u])
    coefficient_255_nontrivial = 1;

  X = A;
  NB = B;
  mlk_poly_sub(&X, &B);
  mlk_poly_reduce(&X);
  mlk_poly_reduce(&NB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t recovery_sum =
        (int32_t)X.coeffs[i] + (int32_t)NB.coeffs[i];

    if (recovery_sum == 0) recovery_sum_0 = 1;
    if (recovery_sum == SUB_T3_FIPS_Q - 1) recovery_sum_q_minus_1 = 1;
    if (recovery_sum == SUB_T3_FIPS_Q) recovery_sum_q = 1;
    if (recovery_sum == 2 * (SUB_T3_FIPS_Q - 1))
      recovery_sum_2q_minus_2 = 1;
    if (recovery_sum < SUB_T3_FIPS_Q) recovery_without_wrap = 1;
    if (recovery_sum >= SUB_T3_FIPS_Q) recovery_with_wrap = 1;
  }

  __CPROVER_cover(has_positive_b);
  __CPROVER_cover(has_negative_b);
  __CPROVER_cover(has_zero_b);
  __CPROVER_cover(has_positive_difference);
  __CPROVER_cover(has_negative_difference);
  __CPROVER_cover(has_zero_difference);
  __CPROVER_cover(has_noncanonical_positive_a);
  __CPROVER_cover(has_noncanonical_negative_a);
  __CPROVER_cover(has_noncanonical_positive_b);
  __CPROVER_cover(has_noncanonical_negative_b);
  __CPROVER_cover(has_valid_difference_min);
  __CPROVER_cover(has_valid_difference_max);
  __CPROVER_cover(has_valid_addition_min);
  __CPROVER_cover(has_valid_addition_max);
  __CPROVER_cover(coefficient_0_nontrivial);
  __CPROVER_cover(coefficient_255_nontrivial);
  __CPROVER_cover(recovery_sum_0);
  __CPROVER_cover(recovery_sum_q_minus_1);
  __CPROVER_cover(recovery_sum_q);
  __CPROVER_cover(recovery_sum_2q_minus_2);
  __CPROVER_cover(recovery_without_wrap);
  __CPROVER_cover(recovery_with_wrap);
  __CPROVER_cover(1);

  return 0;
}
