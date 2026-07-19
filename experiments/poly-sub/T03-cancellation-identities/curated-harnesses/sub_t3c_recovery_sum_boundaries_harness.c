#include "sub_t3_common.h"

int main(void)
{
  mlk_poly A;
  mlk_poly B;
  mlk_poly X;
  mlk_poly NB;
  mlk_poly NA;
  int32_t sum0;
  int32_t sum1;
  int32_t sum2;
  int32_t sum255;

  sub_t3_check_machine_model();
  sub_t3_zero_poly(&A);
  sub_t3_zero_poly(&B);

  A.coeffs[0] = 0;
  B.coeffs[0] = 0;

  A.coeffs[1] = -1;
  B.coeffs[1] = 0;

  A.coeffs[2] = 0;
  B.coeffs[2] = 1;

  A.coeffs[MLKEM_N - 1u] = -2;
  B.coeffs[MLKEM_N - 1u] = -1;

  X = A;
  NB = B;
  NA = A;

  mlk_poly_sub(&X, &B);
  mlk_poly_reduce(&X);
  mlk_poly_reduce(&NB);

  sum0 = (int32_t)X.coeffs[0] + NB.coeffs[0];
  sum1 = (int32_t)X.coeffs[1] + NB.coeffs[1];
  sum2 = (int32_t)X.coeffs[2] + NB.coeffs[2];
  sum255 = (int32_t)X.coeffs[MLKEM_N - 1u] +
           NB.coeffs[MLKEM_N - 1u];

  __CPROVER_assert(sum0 == 0,
                   "SUB_T3C_BOUNDARY: recovery sum 0 reachable");
  __CPROVER_assert(sum1 == SUB_T3_FIPS_Q - 1,
                   "SUB_T3C_BOUNDARY: recovery sum q-1 reachable");
  __CPROVER_assert(sum2 == SUB_T3_FIPS_Q,
                   "SUB_T3C_BOUNDARY: recovery sum q reachable");
  __CPROVER_assert(sum255 == 2 * (SUB_T3_FIPS_Q - 1),
                   "SUB_T3C_BOUNDARY: recovery sum 2q-2 reachable");

  mlk_poly_add(&X, &NB);
  mlk_poly_reduce(&X);
  mlk_poly_reduce(&NA);

  __CPROVER_assert(X.coeffs[0] == NA.coeffs[0],
                   "SUB_T3C_BOUNDARY: cancellation at sum 0");
  __CPROVER_assert(X.coeffs[1] == NA.coeffs[1],
                   "SUB_T3C_BOUNDARY: cancellation at sum q-1");
  __CPROVER_assert(X.coeffs[2] == NA.coeffs[2],
                   "SUB_T3C_BOUNDARY: cancellation at sum q");
  __CPROVER_assert(X.coeffs[MLKEM_N - 1u] ==
                       NA.coeffs[MLKEM_N - 1u],
                   "SUB_T3C_BOUNDARY: cancellation at sum 2q-2");

  return 0;
}
