/*
 * SUB-T1 draft: full signed-domain modular refinement.
 * Independently authored from the frozen SUB-00B/SUB-00C records.
 */
#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

extern int16_t nondet_int16_t(void);

static void sub_t1_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T1_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T1_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T1_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T1_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T1_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T1_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T1_MODEL: negative signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T1_MODEL: negative odd right shift must preserve sign");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A0;
  mlk_poly saved_B0;
  mlk_poly L;
  mlk_poly LB;
  mlk_poly LB_before_sub;
  mlk_poly LB_before_reduce;
  unsigned i;

  sub_t1_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T1_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T1_PARAMETER: MLKEM_Q must equal FIPS_Q");

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
  LB_before_sub = LB;

  mlk_poly_sub(&L, &LB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(LB.coeffs[i] == LB_before_sub.coeffs[i],
                     "SUB_T1_FRAME: subtraction must not modify LB");
    __CPROVER_assert(A0.coeffs[i] == saved_A0.coeffs[i],
                     "SUB_T1_FRAME: subtraction must not modify A0");
    __CPROVER_assert(B0.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T1_FRAME: subtraction must not modify B0");
  }

  LB_before_reduce = LB;

  mlk_poly_reduce(&L);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;
    uint32_t shifted;
    uint32_t expected;

    d = (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];
    shifted = (uint32_t)(d + (int32_t)(10 * FIPS_Q));
    expected = shifted % (uint32_t)FIPS_Q;

    __CPROVER_assert(L.coeffs[i] >= 0,
                     "SUB_T1_SEMANTIC: output must be non-negative");
    __CPROVER_assert(L.coeffs[i] < FIPS_Q,
                     "SUB_T1_SEMANTIC: output must be below FIPS_Q");
    __CPROVER_assert(((uint32_t)L.coeffs[i]) == (((uint32_t)(expected) + 1U) % 3329U),
                     "SUB_T1_SEMANTIC: output must equal independent canonical oracle");

    __CPROVER_assert(LB.coeffs[i] == LB_before_reduce.coeffs[i],
                     "SUB_T1_FRAME: reduction must not modify LB");
    __CPROVER_assert(LB.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T1_FRAME: final LB must equal saved B0");
    __CPROVER_assert(A0.coeffs[i] == saved_A0.coeffs[i],
                     "SUB_T1_FRAME: final A0 must equal saved A0");
    __CPROVER_assert(B0.coeffs[i] == saved_B0.coeffs[i],
                     "SUB_T1_FRAME: final B0 must equal saved B0");
  }

  return 0;
}
