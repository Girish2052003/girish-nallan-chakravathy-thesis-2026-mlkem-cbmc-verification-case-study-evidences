/*
 * SUB-T2 draft: normalization commutes with production subtraction.
 * Independently authored from the frozen SUB-00B/SUB-00C records.
 */
#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

extern int16_t nondet_int16_t(void);

static void sub_t2_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T2_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T2_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T2_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T2_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T2_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T2_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T2_MODEL: negative signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T2_MODEL: negative odd right shift must preserve sign");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A0;
  mlk_poly saved_B0;
  mlk_poly L;
  mlk_poly LB;
  mlk_poly RA;
  mlk_poly RB;
  mlk_poly RA_before_left;
  mlk_poly RB_before_left;
  mlk_poly completed_L;
  mlk_poly completed_LB;
  mlk_poly RB_before_RA_reduce_first;
  mlk_poly RA_before_RB_reduce;
  mlk_poly RB_before_sub;
  mlk_poly RB_before_RA_reduce_final;
  unsigned i;

  sub_t2_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T2_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T2_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = nondet_int16_t();
    B0.coeffs[i] = nondet_int16_t();
  }

  saved_A0 = A0;
  saved_B0 = B0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];

    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);
  }

  L = A0;
  LB = B0;
  RA = A0;
  RB = B0;

  RA_before_left = RA;
  RB_before_left = RB;

  mlk_poly_sub(&L, &LB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RA.coeffs[i] == RA_before_left.coeffs[i],
                     "SUB_T2_FRAME: left subtraction must not modify RA");
    __CPROVER_assert(RB.coeffs[i] == RB_before_left.coeffs[i],
                     "SUB_T2_FRAME: left subtraction must not modify RB");
    __CPROVER_assert(LB.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T2_FRAME: left subtraction must not modify LB");
  }

  mlk_poly_reduce(&L);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RA.coeffs[i] == RA_before_left.coeffs[i],
                     "SUB_T2_FRAME: left reduction must not modify RA");
    __CPROVER_assert(RB.coeffs[i] == RB_before_left.coeffs[i],
                     "SUB_T2_FRAME: left reduction must not modify RB");
    __CPROVER_assert(LB.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T2_FRAME: left reduction must not modify LB");
  }

  completed_L = L;
  completed_LB = LB;

  RB_before_RA_reduce_first = RB;
  mlk_poly_reduce(&RA);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RB.coeffs[i] ==
                         RB_before_RA_reduce_first.coeffs[i],
                     "SUB_T2_FRAME: reducing RA must not modify RB");
    __CPROVER_assert(L.coeffs[i] == completed_L.coeffs[i],
                     "SUB_T2_FRAME: reducing RA must not modify completed L");
    __CPROVER_assert(LB.coeffs[i] == completed_LB.coeffs[i],
                     "SUB_T2_FRAME: reducing RA must not modify completed LB");
  }

  RA_before_RB_reduce = RA;
  mlk_poly_reduce(&RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RA.coeffs[i] == RA_before_RB_reduce.coeffs[i],
                     "SUB_T2_FRAME: reducing RB must not modify RA");
    __CPROVER_assert(L.coeffs[i] == completed_L.coeffs[i],
                     "SUB_T2_FRAME: reducing RB must not modify completed L");
    __CPROVER_assert(LB.coeffs[i] == completed_LB.coeffs[i],
                     "SUB_T2_FRAME: reducing RB must not modify completed LB");
  }

  RB_before_sub = RB;
  mlk_poly_sub(&RA, &RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RB.coeffs[i] == RB_before_sub.coeffs[i],
                     "SUB_T2_FRAME: right subtraction must not modify RB");
    __CPROVER_assert(L.coeffs[i] == completed_L.coeffs[i],
                     "SUB_T2_FRAME: right subtraction must not modify completed L");
    __CPROVER_assert(LB.coeffs[i] == completed_LB.coeffs[i],
                     "SUB_T2_FRAME: right subtraction must not modify completed LB");
  }

  RB_before_RA_reduce_final = RB;
  mlk_poly_reduce(&RA);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(RB.coeffs[i] ==
                         RB_before_RA_reduce_final.coeffs[i],
                     "SUB_T2_FRAME: final RA reduction must not modify RB");
    __CPROVER_assert(L.coeffs[i] == completed_L.coeffs[i],
                     "SUB_T2_FRAME: final RA reduction must not modify completed L");
    __CPROVER_assert(LB.coeffs[i] == completed_LB.coeffs[i],
                     "SUB_T2_FRAME: final RA reduction must not modify completed LB");

    __CPROVER_assert(A0.coeffs[i] == saved_A0.coeffs[i],
                     "SUB_T2_FRAME: final A0 must equal saved A0");
    __CPROVER_assert(B0.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T2_FRAME: final B0 must equal saved B0");
    __CPROVER_assert(LB.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T2_FRAME: final LB must equal saved B0");

    __CPROVER_assert(L.coeffs[i] == RA.coeffs[i],
                     "SUB_T2_RELATIONAL: left and right canonical results must agree");
    __CPROVER_assert(L.coeffs[i] >= 0,
                     "SUB_T2_RELATIONAL: left result must be non-negative");
    __CPROVER_assert(L.coeffs[i] < FIPS_Q,
                     "SUB_T2_RELATIONAL: left result must be below FIPS_Q");
    __CPROVER_assert(RA.coeffs[i] >= 0,
                     "SUB_T2_RELATIONAL: right result must be non-negative");
    __CPROVER_assert(RA.coeffs[i] < FIPS_Q,
                     "SUB_T2_RELATIONAL: right result must be below FIPS_Q");
  }

  return 0;
}
