#ifndef SUB_T3_COMMON_H
#define SUB_T3_COMMON_H

#include <limits.h>
#include <stdint.h>

#include "poly.h"

enum
{
  SUB_T3_FIPS_N = 256,
  SUB_T3_FIPS_Q = 3329
};

static void sub_t3_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T3_MACHINE: CHAR_BIT must equal 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T3_MACHINE: short must be 16 bits");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T3_MACHINE: int must be 32 bits");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T3_MACHINE: int16_t must be 16 bits");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T3_MACHINE: int32_t must be 32 bits");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T3_MACHINE: pointer width must be 64 bits");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T3_MACHINE: negative right shift must preserve sign");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T3_MACHINE: negative right shift must round arithmetically");

  __CPROVER_assert(MLKEM_N == SUB_T3_FIPS_N,
                   "SUB_T3_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == SUB_T3_FIPS_Q,
                   "SUB_T3_PARAMETER: MLKEM_Q must equal FIPS_Q");
}

static void sub_t3_zero_poly(mlk_poly *p)
{
  uint32_t i;
  for (i = 0u; i < MLKEM_N; i++)
  {
    p->coeffs[i] = 0;
  }
}

#endif
