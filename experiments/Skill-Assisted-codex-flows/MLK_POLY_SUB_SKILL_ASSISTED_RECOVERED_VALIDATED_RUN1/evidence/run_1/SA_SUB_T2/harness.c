/*
 * SA-SUB-T2: sequential-subtrahend aggregation equivalence.
 * Selected claim: (a-b)-c = a-(b+c), coefficient-wise.
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

static int16_t sa_sub_t2_nondet_i16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;
  mlk_poly c;
  mlk_poly aggregate;
  mlk_poly sequential;
  mlk_poly direct;
  unsigned i;
  unsigned target_calls;
  int SA_SUB_T2_ASSUMPTIONS_FEASIBLE;
  int SA_SUB_T2_NONTRIVIAL_WITNESS;
  int SA_SUB_T2_TARGET_1_REACHED;
  int SA_SUB_T2_TARGET_2_REACHED;
  int SA_SUB_T2_TARGET_3_REACHED;
  int SA_SUB_T2_ASSERTION_BLOCK_REACHED;

  target_calls = 0;
  SA_SUB_T2_ASSUMPTIONS_FEASIBLE = 0;
  SA_SUB_T2_NONTRIVIAL_WITNESS = 0;
  SA_SUB_T2_TARGET_1_REACHED = 0;
  SA_SUB_T2_TARGET_2_REACHED = 0;
  SA_SUB_T2_TARGET_3_REACHED = 0;
  SA_SUB_T2_ASSERTION_BLOCK_REACHED = 0;

  __CPROVER_assert(MLKEM_N == 256, "SA_SUB_T2_BINDING_N_256");
  __CPROVER_assert(MLKEM_Q == 3329, "SA_SUB_T2_BINDING_Q_3329");
  __CPROVER_assert(INT16_MIN == -32768 && INT16_MAX == 32767,
                   "SA_SUB_T2_BINDING_INT16");

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t first;
    int32_t aggregated;
    int32_t final_value;

    a.coeffs[i] = sa_sub_t2_nondet_i16();
    b.coeffs[i] = sa_sub_t2_nondet_i16();
    c.coeffs[i] = sa_sub_t2_nondet_i16();

    first = (int32_t)a.coeffs[i] - (int32_t)b.coeffs[i];
    aggregated = (int32_t)b.coeffs[i] + (int32_t)c.coeffs[i];
    final_value = (int32_t)a.coeffs[i] - aggregated;

    __CPROVER_assume(first >= INT16_MIN && first <= INT16_MAX);
    __CPROVER_assume(aggregated >= INT16_MIN && aggregated <= INT16_MAX);
    __CPROVER_assume(final_value >= INT16_MIN && final_value <= INT16_MAX);

    aggregate.coeffs[i] = (int16_t)aggregated;
    sequential.coeffs[i] = a.coeffs[i];
    direct.coeffs[i] = a.coeffs[i];
  }

  SA_SUB_T2_ASSUMPTIONS_FEASIBLE = 1;
  SA_SUB_T2_NONTRIVIAL_WITNESS =
      (b.coeffs[0] != 0) &&
      (c.coeffs[0] != 0) &&
      (aggregate.coeffs[255] != 0);
  SA_COVER(SA_SUB_T2_ASSUMPTIONS_FEASIBLE);
  SA_COVER(SA_SUB_T2_NONTRIVIAL_WITNESS);

  mlk_poly_sub(&sequential, &b);
  target_calls++;
  SA_SUB_T2_TARGET_1_REACHED = (target_calls == 1);
  SA_COVER(SA_SUB_T2_TARGET_1_REACHED);

  mlk_poly_sub(&sequential, &c);
  target_calls++;
  SA_SUB_T2_TARGET_2_REACHED = (target_calls == 2);
  SA_COVER(SA_SUB_T2_TARGET_2_REACHED);

  mlk_poly_sub(&direct, &aggregate);
  target_calls++;
  SA_SUB_T2_TARGET_3_REACHED = (target_calls == 3);
  SA_COVER(SA_SUB_T2_TARGET_3_REACHED);

  SA_SUB_T2_ASSERTION_BLOCK_REACHED = 1;
  SA_COVER(SA_SUB_T2_ASSERTION_BLOCK_REACHED);

  __CPROVER_assert(target_calls == 3,
                   "SA_SUB_T2_TARGET_CALL_COUNT");

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t aggregate_oracle;
    int32_t sequential_oracle;
    int32_t direct_oracle;

    aggregate_oracle =
        (int32_t)b.coeffs[i] + (int32_t)c.coeffs[i];
    sequential_oracle =
        ((int32_t)a.coeffs[i] - (int32_t)b.coeffs[i]) -
        (int32_t)c.coeffs[i];
    direct_oracle = (int32_t)a.coeffs[i] - aggregate_oracle;

    __CPROVER_assert((int32_t)aggregate.coeffs[i] == aggregate_oracle,
        "SA_SUB_T2_AGGREGATE_CONSTRUCTION");
    __CPROVER_assert(sequential.coeffs[i] == direct.coeffs[i],
        "SA_SUB_T2_SEQUENTIAL_SUBTRAHEND_AGGREGATION_EQUIVALENCE");
    __CPROVER_assert((int32_t)sequential.coeffs[i] == sequential_oracle,
        "SA_SUB_T2_SEQUENTIAL_EXECUTION_ORACLE_BRIDGE");
    __CPROVER_assert((int32_t)direct.coeffs[i] == direct_oracle,
        "SA_SUB_T2_DIRECT_EXECUTION_ORACLE_BRIDGE");
  }

  return 0;
}
