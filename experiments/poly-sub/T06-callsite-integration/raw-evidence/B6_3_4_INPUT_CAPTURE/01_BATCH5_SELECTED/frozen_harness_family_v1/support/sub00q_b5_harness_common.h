#ifndef SUB00Q_B5_HARNESS_COMMON_H
#define SUB00Q_B5_HARNESS_COMMON_H

#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define SUB_T5_FIPS_N 256u
#define SUB_T5_FIPS_Q 3329

extern int16_t nondet_int16_t(void);
extern unsigned nondet_unsigned(void);

static void sub_t5_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T5_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T5_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T5_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T5_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T5_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T5_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T5_MODEL: signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T5_MODEL: negative odd shift must preserve sign");
  __CPROVER_assert(MLKEM_N == SUB_T5_FIPS_N,
                   "SUB_T5_PARAMETER: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == SUB_T5_FIPS_Q,
                   "SUB_T5_PARAMETER: MLKEM_Q must equal 3329");
}

#endif /* SUB00Q_B5_HARNESS_COMMON_H */
