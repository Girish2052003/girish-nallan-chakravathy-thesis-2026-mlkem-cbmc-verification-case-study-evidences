#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A;
  mlk_poly saved_B;
  mlk_poly X;
  mlk_poly XB;
  mlk_poly NB;
  mlk_poly NA;
  mlk_poly X_after_first_normalization;
  mlk_poly NB_after_normalization;
  mlk_poly X_after_recovery_addition;
  mlk_poly final_X_snapshot;
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
  X = A0;
  XB = B0;
  NB = B0;
  NA = A0;

  mlk_poly_sub(&X, &XB);
  mlk_poly_reduce(&X);
  X_after_first_normalization = X;

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(XB.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3C_FRAME: subtraction operand remains unchanged");
    __CPROVER_assert(X.coeffs[i] >= 0,
                     "SUB_T3C_RANGE: first normalized difference is nonnegative");
    __CPROVER_assert(X.coeffs[i] < SUB_T3_FIPS_Q,
                     "SUB_T3C_RANGE: first normalized difference is below q");
  }

  mlk_poly_reduce(&NB);
  NB_after_normalization = NB;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t recovery_sum =
        (int32_t)X.coeffs[i] + (int32_t)NB.coeffs[i];

    __CPROVER_assert(X.coeffs[i] ==
                         X_after_first_normalization.coeffs[i],
                     "SUB_T3C_FRAME: X unchanged while B is normalized");
    __CPROVER_assert(NB.coeffs[i] >= 0,
                     "SUB_T3C_RANGE: normalized B is nonnegative");
    __CPROVER_assert(NB.coeffs[i] < SUB_T3_FIPS_Q,
                     "SUB_T3C_RANGE: normalized B is below q");
    __CPROVER_assert(recovery_sum >= 0,
                     "SUB_T3C_ADD_BOUND: recovery sum is nonnegative");
    __CPROVER_assert(recovery_sum <=
                         2 * (SUB_T3_FIPS_Q - 1),
                     "SUB_T3C_ADD_BOUND: recovery sum is at most 6656");
    __CPROVER_assert(recovery_sum <= (int32_t)INT16_MAX,
                     "SUB_T3C_ADD_BOUND: recovery sum fits int16_t");
  }

  mlk_poly_add(&X, &NB);
  X_after_recovery_addition = X;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t exact_recovery_sum =
        (int32_t)X_after_first_normalization.coeffs[i] +
        (int32_t)NB_after_normalization.coeffs[i];

    __CPROVER_assert((int32_t)X.coeffs[i] == exact_recovery_sum,
                     "SUB_T3C_INTERMEDIATE: recovery addition must be exact");
    __CPROVER_assert(NB.coeffs[i] ==
                         NB_after_normalization.coeffs[i],
                     "SUB_T3C_FRAME: normalized B unchanged by recovery addition");
  }

  mlk_poly_reduce(&X);
  final_X_snapshot = X;

  mlk_poly_reduce(&NA);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t a32 = (int32_t)saved_A.coeffs[i];
    uint32_t shifted =
        (uint32_t)(a32 + 10 * SUB_T3_FIPS_Q);
    uint32_t expected_A =
        shifted % (uint32_t)SUB_T3_FIPS_Q;

    __CPROVER_assert(shifted >= 522u,
                     "SUB_T3C_ORACLE: shifted A lower bound");
    __CPROVER_assert(shifted <= 66057u,
                     "SUB_T3C_ORACLE: shifted A upper bound");

    __CPROVER_assert(X.coeffs[i] == NA.coeffs[i],
                     "SUB_T3C_CANCELLATION: N(N(A-B)+N(B)) must equal N(A)");
    __CPROVER_assert((uint32_t)X.coeffs[i] == expected_A,
                     "SUB_T3C_ORACLE: recovered result must equal FIPS oracle");
    __CPROVER_assert((uint32_t)NA.coeffs[i] == expected_A,
                     "SUB_T3C_ORACLE: normalized A must equal FIPS oracle");

    __CPROVER_assert(X.coeffs[i] >= 0,
                     "SUB_T3C_FINAL_RANGE: recovered result nonnegative");
    __CPROVER_assert(X.coeffs[i] < SUB_T3_FIPS_Q,
                     "SUB_T3C_FINAL_RANGE: recovered result below q");
    __CPROVER_assert(NA.coeffs[i] >= 0,
                     "SUB_T3C_FINAL_RANGE: normalized A nonnegative");
    __CPROVER_assert(NA.coeffs[i] < SUB_T3_FIPS_Q,
                     "SUB_T3C_FINAL_RANGE: normalized A below q");

    __CPROVER_assert(X.coeffs[i] == final_X_snapshot.coeffs[i],
                     "SUB_T3C_FRAME: final X unchanged while A is normalized");
    __CPROVER_assert(NB.coeffs[i] ==
                         NB_after_normalization.coeffs[i],
                     "SUB_T3C_FRAME: normalized B remains unchanged");
    __CPROVER_assert(A0.coeffs[i] == saved_A.coeffs[i],
                     "SUB_T3C_FRAME: original A remains unchanged");
    __CPROVER_assert(B0.coeffs[i] == saved_B.coeffs[i],
                     "SUB_T3C_FRAME: original B remains unchanged");
    __CPROVER_assert(X_after_recovery_addition.coeffs[i] >= 0,
                     "SUB_T3C_SNAPSHOT: recovery-addition snapshot retained");
  }

  return 0;
}
