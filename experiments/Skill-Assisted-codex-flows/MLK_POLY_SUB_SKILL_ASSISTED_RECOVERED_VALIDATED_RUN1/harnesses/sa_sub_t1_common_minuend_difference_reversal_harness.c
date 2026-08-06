/*
 * SA-SUB-T1: common-minuend difference reversal.
 * Selected claim: (a-b)-(a-c) = c-b, coefficient-wise.
 * Target: unchanged production mlk_poly_sub, ML-KEM-768.
 */
#include <limits.h>
#include <stdint.h>
#include "mlkem/src/poly.h"

#ifdef SKILL_COVER_MODE
#define SA_COVER(condition) __CPROVER_cover(condition)
#else
#define SA_COVER(condition) ((void)(condition))
#endif

static int16_t sa_sub_t1_nondet_i16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;
  mlk_poly c;
  mlk_poly a_minus_b;
  mlk_poly a_minus_c;
  mlk_poly nested;
  mlk_poly direct;
  unsigned i;
  unsigned target_calls;
  int SA_SUB_T1_ASSUMPTIONS_FEASIBLE;
  int SA_SUB_T1_NONTRIVIAL_WITNESS;
  int SA_SUB_T1_TARGET_1_REACHED;
  int SA_SUB_T1_TARGET_2_REACHED;
  int SA_SUB_T1_TARGET_3_REACHED;
  int SA_SUB_T1_TARGET_4_REACHED;
  int SA_SUB_T1_ASSERTION_BLOCK_REACHED;

  target_calls = 0;
  SA_SUB_T1_ASSUMPTIONS_FEASIBLE = 0;
  SA_SUB_T1_NONTRIVIAL_WITNESS = 0;
  SA_SUB_T1_TARGET_1_REACHED = 0;
  SA_SUB_T1_TARGET_2_REACHED = 0;
  SA_SUB_T1_TARGET_3_REACHED = 0;
  SA_SUB_T1_TARGET_4_REACHED = 0;
  SA_SUB_T1_ASSERTION_BLOCK_REACHED = 0;

  __CPROVER_assert(MLKEM_N == 256, "SA_SUB_T1_BINDING_N_256");
  __CPROVER_assert(MLKEM_Q == 3329, "SA_SUB_T1_BINDING_Q_3329");
  __CPROVER_assert(INT16_MIN == -32768 && INT16_MAX == 32767,
                   "SA_SUB_T1_BINDING_INT16");

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t ab;
    int32_t ac;
    int32_t cb;

    a.coeffs[i] = sa_sub_t1_nondet_i16();
    b.coeffs[i] = sa_sub_t1_nondet_i16();
    c.coeffs[i] = sa_sub_t1_nondet_i16();

    ab = (int32_t)a.coeffs[i] - (int32_t)b.coeffs[i];
    ac = (int32_t)a.coeffs[i] - (int32_t)c.coeffs[i];
    cb = (int32_t)c.coeffs[i] - (int32_t)b.coeffs[i];

    __CPROVER_assume(ab >= INT16_MIN && ab <= INT16_MAX);
    __CPROVER_assume(ac >= INT16_MIN && ac <= INT16_MAX);
    __CPROVER_assume(cb >= INT16_MIN && cb <= INT16_MAX);

    a_minus_b.coeffs[i] = a.coeffs[i];
    a_minus_c.coeffs[i] = a.coeffs[i];
    direct.coeffs[i] = c.coeffs[i];
  }

  SA_SUB_T1_ASSUMPTIONS_FEASIBLE = 1;
  SA_SUB_T1_NONTRIVIAL_WITNESS =
      (b.coeffs[0] != c.coeffs[0]) &&
      (a.coeffs[255] != b.coeffs[255]);
  SA_COVER(SA_SUB_T1_ASSUMPTIONS_FEASIBLE);
  SA_COVER(SA_SUB_T1_NONTRIVIAL_WITNESS);

  mlk_poly_sub(&a_minus_b, &b);
  target_calls++;
  SA_SUB_T1_TARGET_1_REACHED = (target_calls == 1);
  SA_COVER(SA_SUB_T1_TARGET_1_REACHED);

  mlk_poly_sub(&a_minus_c, &c);
  target_calls++;
  SA_SUB_T1_TARGET_2_REACHED = (target_calls == 2);
  SA_COVER(SA_SUB_T1_TARGET_2_REACHED);

  nested = a_minus_b;
  mlk_poly_sub(&nested, &a_minus_c);
  target_calls++;
  SA_SUB_T1_TARGET_3_REACHED = (target_calls == 3);
  SA_COVER(SA_SUB_T1_TARGET_3_REACHED);

  mlk_poly_sub(&direct, &b);
  target_calls++;
  SA_SUB_T1_TARGET_4_REACHED = (target_calls == 4);
  SA_COVER(SA_SUB_T1_TARGET_4_REACHED);

  SA_SUB_T1_ASSERTION_BLOCK_REACHED = 1;
  SA_COVER(SA_SUB_T1_ASSERTION_BLOCK_REACHED);

  __CPROVER_assert(target_calls == 4,
                   "SA_SUB_T1_TARGET_CALL_COUNT");

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t oracle;

    oracle = (int32_t)c.coeffs[i] - (int32_t)b.coeffs[i];

    __CPROVER_assert(nested.coeffs[i] == direct.coeffs[i],
        "SA_SUB_T1_COMMON_MINUEND_DIFFERENCE_REVERSAL");
    __CPROVER_assert((int32_t)nested.coeffs[i] == oracle,
        "SA_SUB_T1_NESTED_EXECUTION_ORACLE_BRIDGE");
    __CPROVER_assert((int32_t)direct.coeffs[i] == oracle,
        "SA_SUB_T1_DIRECT_EXECUTION_ORACLE_BRIDGE");
  }

  return 0;
}
