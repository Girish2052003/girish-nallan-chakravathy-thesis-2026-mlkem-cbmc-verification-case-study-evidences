/*
 * SUB-T5 positive harness: T5.1 and T5.6.
 * Proves preservation of source operands, saved snapshots, and unrelated
 * harness-owned guards across two production mlk_poly_sub executions.
 */
#include "sub00q_b5_harness_common.h"

int main(void)
{
  mlk_poly A1;
  mlk_poly A2;
  mlk_poly B1;
  mlk_poly B2;
  mlk_poly R1;
  mlk_poly R2;
  mlk_poly saved_A1;
  mlk_poly saved_A2;
  mlk_poly saved_B1;
  mlk_poly saved_B2;
  mlk_poly witness_saved_A1;
  mlk_poly witness_saved_A2;
  mlk_poly witness_saved_B1;
  mlk_poly witness_saved_B2;
  mlk_poly guard_1;
  mlk_poly guard_2;
  mlk_poly guard_1_before;
  mlk_poly guard_2_before;
  unsigned i;

  sub_t5_check_machine_model();

  for (i = 0u; i < MLKEM_N; i++)
  {
    A1.coeffs[i] = nondet_int16_t();
    A2.coeffs[i] = nondet_int16_t();
    B1.coeffs[i] = nondet_int16_t();
    B2.coeffs[i] = nondet_int16_t();
    guard_1.coeffs[i] = (int16_t)i;
    guard_2.coeffs[i] = (int16_t)(255 - (int)i);

    __CPROVER_assume(A1.coeffs[i] >= 0);
    __CPROVER_assume(A1.coeffs[i] < SUB_T5_FIPS_Q);
    __CPROVER_assume(A2.coeffs[i] >= 0);
    __CPROVER_assume(A2.coeffs[i] < SUB_T5_FIPS_Q);
    __CPROVER_assume(B1.coeffs[i] >= 0);
    __CPROVER_assume(B1.coeffs[i] < SUB_T5_FIPS_Q);
    __CPROVER_assume(B2.coeffs[i] >= 0);
    __CPROVER_assume(B2.coeffs[i] < SUB_T5_FIPS_Q);
  }

  saved_A1 = A1;
  saved_A2 = A2;
  saved_B1 = B1;
  saved_B2 = B2;
  witness_saved_A1 = saved_A1;
  witness_saved_A2 = saved_A2;
  witness_saved_B1 = saved_B1;
  witness_saved_B2 = saved_B2;
  guard_1_before = guard_1;
  guard_2_before = guard_2;
  R1 = A1;
  R2 = A2;

  mlk_poly_sub(&R1, &B1);
  mlk_poly_sub(&R2, &B2);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d1;
    int32_t d2;

    d1 = (int32_t)saved_A1.coeffs[i] - (int32_t)saved_B1.coeffs[i];
    d2 = (int32_t)saved_A2.coeffs[i] - (int32_t)saved_B2.coeffs[i];

    __CPROVER_assert((int32_t)R1.coeffs[i] == d1,
                     "SUB_T5_FRAME_ANCHOR_R1: first production result must be exact");
    __CPROVER_assert((int32_t)R2.coeffs[i] == d2,
                     "SUB_T5_FRAME_ANCHOR_R2: second production result must be exact");

    __CPROVER_assert(A1.coeffs[i] == saved_A1.coeffs[i],
                     "SUB_T5_T5_1_FRAME_A1: A1 must remain unchanged");
    __CPROVER_assert(A2.coeffs[i] == saved_A2.coeffs[i],
                     "SUB_T5_T5_1_FRAME_A2: A2 must remain unchanged");
    __CPROVER_assert(B1.coeffs[i] == saved_B1.coeffs[i],
                     "SUB_T5_T5_1_FRAME_B1: B1 must remain unchanged");
    __CPROVER_assert(B2.coeffs[i] == saved_B2.coeffs[i],
                     "SUB_T5_T5_1_FRAME_B2: B2 must remain unchanged");

    __CPROVER_assert(saved_A1.coeffs[i] == witness_saved_A1.coeffs[i],
                     "SUB_T5_T5_1_SNAPSHOT_A1: saved A1 snapshot must remain unchanged");
    __CPROVER_assert(saved_A2.coeffs[i] == witness_saved_A2.coeffs[i],
                     "SUB_T5_T5_1_SNAPSHOT_A2: saved A2 snapshot must remain unchanged");
    __CPROVER_assert(saved_B1.coeffs[i] == witness_saved_B1.coeffs[i],
                     "SUB_T5_T5_1_SNAPSHOT_B1: saved B1 snapshot must remain unchanged");
    __CPROVER_assert(saved_B2.coeffs[i] == witness_saved_B2.coeffs[i],
                     "SUB_T5_T5_1_SNAPSHOT_B2: saved B2 snapshot must remain unchanged");

    __CPROVER_assert(guard_1.coeffs[i] == guard_1_before.coeffs[i],
                     "SUB_T5_T5_6_GUARD_1: unrelated guard 1 must remain unchanged");
    __CPROVER_assert(guard_2.coeffs[i] == guard_2_before.coeffs[i],
                     "SUB_T5_T5_6_GUARD_2: unrelated guard 2 must remain unchanged");
  }

  return 0;
}
