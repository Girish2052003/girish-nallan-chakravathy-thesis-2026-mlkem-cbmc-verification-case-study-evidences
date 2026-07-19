#ifndef SUB00R_B6_HARNESS_COMMON_H
#define SUB00R_B6_HARNESS_COMMON_H

#include <limits.h>
#include <stdint.h>
#include "poly.h"
#include "compress.h"

#define SUB_T6_FIPS_N 256u
#define SUB_T6_FIPS_Q 3329
#define SUB_T6_INVNTT_BOUND (8 * SUB_T6_FIPS_Q)

extern int16_t nondet_int16_t(void);

static void sub_t6_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T6_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T6_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T6_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T6_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T6_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T6_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T6_MODEL: signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T6_MODEL: negative odd shift must preserve sign");
  __CPROVER_assert(MLKEM_N == SUB_T6_FIPS_N,
                   "SUB_T6_PARAMETER: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == SUB_T6_FIPS_Q,
                   "SUB_T6_PARAMETER: MLKEM_Q must equal 3329");
  __CPROVER_assert(MLK_INVNTT_BOUND == SUB_T6_INVNTT_BOUND,
                   "SUB_T6_PARAMETER: inverse-NTT bound must equal 26632");
}

static void sub_t6_assume_callsite_inputs(mlk_poly *v, mlk_poly *sb)
{
  unsigned i;

  for (i = 0u; i < MLKEM_N; i++)
  {
    v->coeffs[i] = nondet_int16_t();
    sb->coeffs[i] = nondet_int16_t();

    __CPROVER_assume(v->coeffs[i] >= 0);
    __CPROVER_assume(v->coeffs[i] < SUB_T6_FIPS_Q);
    __CPROVER_assume(sb->coeffs[i] > -SUB_T6_INVNTT_BOUND);
    __CPROVER_assume(sb->coeffs[i] < SUB_T6_INVNTT_BOUND);
  }
}

#endif /* SUB00R_B6_HARNESS_COMMON_H */
