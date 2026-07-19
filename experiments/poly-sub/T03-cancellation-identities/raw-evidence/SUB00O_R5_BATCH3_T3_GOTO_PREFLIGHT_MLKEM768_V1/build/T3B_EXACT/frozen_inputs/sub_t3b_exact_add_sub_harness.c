#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A;
  mlk_poly saved_B;
  mlk_poly R;
  mlk_poly RB;
  mlk_poly S;
  mlk_poly S_snapshot;
  uint32_t i;

  sub_t3_check_machine_model();

  for (i = 0u; i < MLKEM_N; i++)
  {
    int16_t a_i;
    int16_t b_i;
    int32_t s;

    A0.coeffs[i] = a_i;
    B0.coeffs[i] = b_i;

    s = (int32_t)a_i + (int32_t)b_i;
    __CPROVER_assume(s >= (int32_t)INT16_MIN);
    __CPROVER_assume(s <= (int32_t)INT16_MAX);
  }

  saved_A = A0;
  saved_B = B0;
  R = A0;
  RB = B0;

  mlk_poly_add(&R, &RB);
  S = R;
  S_snapshot = S;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected_sum =
        (int32_t)saved_A.coeffs[i] + (int32_t)saved_B.coeffs[i];

    __CPROVER_assert((int32_t)S.coeffs[i] == expected_sum,
                     "SUB_T3B_INTERMEDIATE: addition must be exact");
    __CPROVER_assert(RB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3B_FRAME: B copy unchanged after addition");
  }

  mlk_poly_sub(&R, &RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(R.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3B_CANCELLATION: (A+B)-B must equal A");
    __CPROVER_assert(RB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3B_FRAME: B copy unchanged after recovery subtraction");
    __CPROVER_assert(S.coeffs[i] == S_snapshot.coeffs[i],
                     "SUB_T3B_FRAME: saved sum remains unchanged");
    __CPROVER_assert(A0.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3B_FRAME: original A remains unchanged");
    __CPROVER_assert(B0.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3B_FRAME: original B remains unchanged");
  }

  return 0;
}
