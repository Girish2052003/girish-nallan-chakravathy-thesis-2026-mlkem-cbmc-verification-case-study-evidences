#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A;
  mlk_poly saved_B;
  mlk_poly R;
  mlk_poly RB;
  mlk_poly D;
  mlk_poly D_snapshot;
  uint32_t i;

  sub_t3_check_machine_model();

  for (i = 0u; i < MLKEM_N; i++)
  {
    int16_t a_i;
    int16_t b_i;
    int32_t d;

    A0.coeffs[i] = a_i;
    B0.coeffs[i] = b_i;

    d = (int32_t)a_i - (int32_t)b_i;
    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);
  }

  saved_A = A0;
  saved_B = B0;
  R = A0;
  RB = B0;

  mlk_poly_sub(&R, &RB);
  D = R;
  D_snapshot = D;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected_difference =
        (int32_t)saved_A.coeffs[i] - (int32_t)saved_B.coeffs[i];

    __CPROVER_assert((int32_t)D.coeffs[i] == expected_difference,
                     "SUB_T3A_INTERMEDIATE: subtraction must be exact");
    __CPROVER_assert(RB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3A_FRAME: B copy unchanged after subtraction");
  }

  mlk_poly_add(&R, &RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(R.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3A_CANCELLATION: (A-B)+B must equal A");
    __CPROVER_assert(RB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3A_FRAME: B copy unchanged after recovery addition");
    __CPROVER_assert(D.coeffs[i] == D_snapshot.coeffs[i],
                     "SUB_T3A_FRAME: saved difference remains unchanged");
    __CPROVER_assert(A0.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3A_FRAME: original A remains unchanged");
    __CPROVER_assert(B0.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3A_FRAME: original B remains unchanged");
  }

  return 0;
}
