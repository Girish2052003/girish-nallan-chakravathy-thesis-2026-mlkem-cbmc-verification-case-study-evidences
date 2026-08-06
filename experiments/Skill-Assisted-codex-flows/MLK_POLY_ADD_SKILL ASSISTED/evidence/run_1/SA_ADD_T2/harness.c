/*
 * SA-ADD-T2: arbitrary disjoint-support decomposition equivalence.
 * Target: mlkem-native commit d9613cf60de3132d32475c102d8c2781d84feb34.
 * Parameter set: ML-KEM-768.  Production source is linked by the runner.
 */
#include <limits.h>
#include <stdint.h>
#include "mlkem/src/poly.h"

static int16_t sa_t2_nondet_i16(void)
{
  int16_t value;
  return value;
}

static int sa_t2_nondet_int(void)
{
  int value;
  return value;
}

int main(void)
{
  mlk_poly direct;
  mlk_poly split;
  mlk_poly operand;
  mlk_poly part_left;
  mlk_poly part_right;
  mlk_poly a_before;
  unsigned i;
  unsigned target_calls = 0;

  __CPROVER_assert(MLKEM_N == 256,
                   "SA_T2_BINDING_N_256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "SA_T2_BINDING_Q_3329");
  __CPROVER_assert(INT16_MIN == -32768 && INT16_MAX == 32767,
                   "SA_T2_BINDING_INT16");

  for (i = 0; i < MLKEM_N; i++)
  {
    int16_t a = sa_t2_nondet_i16();
    int16_t b = sa_t2_nondet_i16();
    int choose_left = sa_t2_nondet_int();
    int32_t sum = (int32_t)a + (int32_t)b;

    __CPROVER_assume(sum >= INT16_MIN && sum <= INT16_MAX);

    direct.coeffs[i] = a;
    split.coeffs[i] = a;
    a_before.coeffs[i] = a;
    operand.coeffs[i] = b;
    part_left.coeffs[i] = choose_left ? b : 0;
    part_right.coeffs[i] = choose_left ? 0 : b;

    __CPROVER_assert(
        (int32_t)part_left.coeffs[i] + (int32_t)part_right.coeffs[i] ==
        (int32_t)operand.coeffs[i],
        "SA_T2_PARTITION_RECOMPOSES_OPERAND");
    __CPROVER_assert(
        part_left.coeffs[i] == 0 || part_right.coeffs[i] == 0,
        "SA_T2_PARTITION_SUPPORTS_ARE_DISJOINT");
  }

  __CPROVER_cover(1); /* SA_T2_ASSUMPTIONS_FEASIBLE */

  mlk_poly_add(&direct, &operand);
  target_calls++;
  __CPROVER_cover(target_calls == 1); /* SA_T2_DIRECT_TARGET_RETURNED */

  mlk_poly_add(&split, &part_left);
  target_calls++;
  __CPROVER_cover(target_calls == 2); /* SA_T2_FIRST_SPLIT_TARGET_RETURNED */

  mlk_poly_add(&split, &part_right);
  target_calls++;
  __CPROVER_cover(target_calls == 3); /* SA_T2_THIRD_TARGET_RETURNED */
  __CPROVER_cover(1); /* SA_T2_ASSERTION_BLOCK_REACHED */

  __CPROVER_assert(target_calls == 3,
                   "SA_T2_TARGET_CALL_COUNT");

  for (i = 0; i < MLKEM_N; i++)
  {
    int32_t oracle =
        (int32_t)a_before.coeffs[i] + (int32_t)operand.coeffs[i];

    __CPROVER_assert(direct.coeffs[i] == split.coeffs[i],
        "SA_T2_DISJOINT_SUPPORT_DECOMPOSITION_EQUIVALENCE");
    __CPROVER_assert((int32_t)direct.coeffs[i] == oracle,
        "SA_T2_DIRECT_EXECUTION_ORACLE_BRIDGE");
    __CPROVER_assert((int32_t)split.coeffs[i] == oracle,
        "SA_T2_SPLIT_EXECUTION_ORACLE_BRIDGE");
  }

  return 0;
}
