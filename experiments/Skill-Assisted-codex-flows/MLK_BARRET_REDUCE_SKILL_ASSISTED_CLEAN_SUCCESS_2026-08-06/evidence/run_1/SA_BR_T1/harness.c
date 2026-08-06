/*
 * SA-BR-T1: sign-conjugate centered reduction and quotient reversal.
 *
 * Domain: every int16_t a except INT16_MIN, because -INT16_MIN is not
 * representable as int16_t. The real exposed production body is called twice.
 */
#include <stdint.h>

#define SA_BR_Q 3329
#define SA_BR_INT16_MIN (-32767 - 1)

#if defined(CBMC)
extern void __CPROVER_assume(_Bool condition);
extern void __CPROVER_assert(_Bool condition, const char *description);
extern void __CPROVER_cover(_Bool condition);
#else
extern void __CPROVER_assume(int condition);
extern void __CPROVER_assert(int condition, const char *description);
extern void __CPROVER_cover(int condition);
#endif

#if defined(CBMC)
typedef _Bool sa_cover_bool_t;
#else
typedef int sa_cover_bool_t;
#endif

int16_t mlk_barrett_reduce(int16_t a);

#if defined(SKILL_REACHABILITY_MODE)
#define SA_COVER(condition) \
  __CPROVER_assert(!((condition) != 0), #condition)
#else
#define SA_COVER(condition) ((void)(condition))
#endif
static int16_t sa_br_t1_nondet_i16(void)
{
  int16_t value;
  return value;
}

static int32_t sa_br_t1_abs_i32(int32_t value)
{
  return value < 0 ? -value : value;
}

int main(void)
{
  int16_t a;
  int16_t neg_a;
  int16_t r_a;
  int16_t r_neg_a;
  int32_t neg_a_wide;
  int32_t q_a;
  int32_t q_neg_a;
  unsigned target_calls;
  sa_cover_bool_t SA_BR_T1_ASSUMPTIONS_FEASIBLE;
  sa_cover_bool_t SA_BR_T1_POSITIVE_NONTRIVIAL_INPUT;
  sa_cover_bool_t SA_BR_T1_NEGATIVE_NONTRIVIAL_INPUT;
  sa_cover_bool_t SA_BR_T1_TARGET_1_REACHED;
  sa_cover_bool_t SA_BR_T1_TARGET_2_REACHED;
  sa_cover_bool_t SA_BR_T1_ASSERTION_BLOCK_REACHED;

  a = sa_br_t1_nondet_i16();
  __CPROVER_assume((int32_t)a != (int32_t)SA_BR_INT16_MIN);

#ifdef SKILL_FAIL_CONTROL
  __CPROVER_assume(a == (int16_t)1);
#endif

  neg_a_wide = -(int32_t)a;
  neg_a = (int16_t)neg_a_wide;
  target_calls = 0U;

  SA_BR_T1_ASSUMPTIONS_FEASIBLE = 1;
  SA_BR_T1_POSITIVE_NONTRIVIAL_INPUT = ((int32_t)a >= 1665);
  SA_BR_T1_NEGATIVE_NONTRIVIAL_INPUT = ((int32_t)a <= -1665);
  SA_BR_T1_TARGET_1_REACHED = 0;
  SA_BR_T1_TARGET_2_REACHED = 0;
  SA_BR_T1_ASSERTION_BLOCK_REACHED = 0;

  SA_COVER(SA_BR_T1_ASSUMPTIONS_FEASIBLE);
  SA_COVER(SA_BR_T1_POSITIVE_NONTRIVIAL_INPUT);
  SA_COVER(SA_BR_T1_NEGATIVE_NONTRIVIAL_INPUT);

  r_a = mlk_barrett_reduce(a);
  target_calls++;
  SA_BR_T1_TARGET_1_REACHED = (target_calls == 1U);
  SA_COVER(SA_BR_T1_TARGET_1_REACHED);

  r_neg_a = mlk_barrett_reduce(neg_a);
  target_calls++;
  SA_BR_T1_TARGET_2_REACHED = (target_calls == 2U);
  SA_COVER(SA_BR_T1_TARGET_2_REACHED);

  SA_BR_T1_ASSERTION_BLOCK_REACHED = 1;
  SA_COVER(SA_BR_T1_ASSERTION_BLOCK_REACHED);

  __CPROVER_assert(target_calls == 2U,
                   "SA_BR_T1_TARGET_CALL_COUNT");
  __CPROVER_assert(neg_a_wide >= -32768 && neg_a_wide <= 32767,
                   "SA_BR_T1_NEGATED_INPUT_REPRESENTABLE");
  __CPROVER_assert((int32_t)r_neg_a == -(int32_t)r_a,
                   "SA_BR_T1_SIGN_CONJUGATE_REDUCTION");
  __CPROVER_assert(sa_br_t1_abs_i32((int32_t)r_neg_a) ==
                       sa_br_t1_abs_i32((int32_t)r_a),
                   "SA_BR_T1_ABSOLUTE_REMAINDER_PRESERVED");

  __CPROVER_assert(((int32_t)a - (int32_t)r_a) % SA_BR_Q == 0,
                   "SA_BR_T1_POSITIVE_QUOTIENT_INTEGRAL");
  __CPROVER_assert((neg_a_wide - (int32_t)r_neg_a) % SA_BR_Q == 0,
                   "SA_BR_T1_NEGATIVE_QUOTIENT_INTEGRAL");

  q_a = ((int32_t)a - (int32_t)r_a) / SA_BR_Q;
  q_neg_a = (neg_a_wide - (int32_t)r_neg_a) / SA_BR_Q;
  __CPROVER_assert(q_neg_a == -q_a,
                   "SA_BR_T1_EXACT_QUOTIENT_REVERSAL");

#ifdef SKILL_FAIL_CONTROL
  __CPROVER_assert(r_neg_a == r_a,
                   "SA_BR_T1_FC_FALSE_EVEN_SYMMETRY");
#endif

  return 0;
}
