/*
 * SA-BR-T2: centered-addition closure with one exact correction.
 *
 * Solver-oriented refinement:
 * the independent centered oracle for full_sum is represented by the complete
 * finite partition of int16_t + int16_t into 41 centered residue intervals.
 * No division or remainder operator is used. The theorem is unchanged.
 */
#include <stdint.h>

#define SA_BR_Q 3329
#define SA_BR_CENTERED_MAX 1664

#if !defined(__CPROVER__)
extern void __CPROVER_assume(int condition);
extern void __CPROVER_assert(int condition, const char *description);
#endif

int16_t mlk_barrett_reduce(int16_t a);

#if defined(SKILL_REACHABILITY_MODE)
#define SA_REACH(condition) \
  __CPROVER_assert(!((condition) != 0), #condition)
#else
#define SA_REACH(condition) ((void)(condition))
#endif

static int16_t sa_br_t2_nondet_i16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  int16_t a;
  int16_t b;
  int16_t r_a;
  int16_t r_b;
  int16_t r_sum;
  int16_t centered_sum_i16;
  int32_t centered_sum;
  int32_t full_sum;
  int32_t correction;
  int32_t oracle_case_matches;
  unsigned target_calls;
  int SA_BR_T2_ASSUMPTIONS_FEASIBLE;
  int SA_BR_T2_POSITIVE_CORRECTION_FEASIBLE;
  int SA_BR_T2_NEGATIVE_CORRECTION_FEASIBLE;
  int SA_BR_T2_ZERO_CORRECTION_FEASIBLE;
  int SA_BR_T2_TARGET_1_REACHED;
  int SA_BR_T2_TARGET_2_REACHED;
  int SA_BR_T2_TARGET_3_REACHED;
  int SA_BR_T2_ASSERTION_BLOCK_REACHED;

  a = sa_br_t2_nondet_i16();
  b = sa_br_t2_nondet_i16();
  target_calls = 0U;

  r_a = mlk_barrett_reduce(a);
  target_calls++;
  SA_BR_T2_TARGET_1_REACHED = (target_calls == 1U);

  r_b = mlk_barrett_reduce(b);
  target_calls++;
  SA_BR_T2_TARGET_2_REACHED = (target_calls == 2U);

  centered_sum = (int32_t)r_a + (int32_t)r_b;
  __CPROVER_assert(centered_sum >= -3328 && centered_sum <= 3328,
                   "SA_BR_T2_INTERMEDIATE_SUM_REPRESENTABLE");
  centered_sum_i16 = (int16_t)centered_sum;

#if defined(SKILL_FAIL_CONTROL)
  __CPROVER_assume(centered_sum > SA_BR_CENTERED_MAX);
#endif

  r_sum = mlk_barrett_reduce(centered_sum_i16);
  target_calls++;
  SA_BR_T2_TARGET_3_REACHED = (target_calls == 3U);

  full_sum = (int32_t)a + (int32_t)b;

  if (centered_sum > SA_BR_CENTERED_MAX)
  {
    correction = 1;
  }
  else if (centered_sum < -SA_BR_CENTERED_MAX)
  {
    correction = -1;
  }
  else
  {
    correction = 0;
  }

  SA_BR_T2_ASSUMPTIONS_FEASIBLE = 1;
  SA_BR_T2_POSITIVE_CORRECTION_FEASIBLE = (correction == 1);
  SA_BR_T2_NEGATIVE_CORRECTION_FEASIBLE = (correction == -1);
  SA_BR_T2_ZERO_CORRECTION_FEASIBLE = (correction == 0);
  SA_BR_T2_ASSERTION_BLOCK_REACHED = 1;

  SA_REACH(SA_BR_T2_ASSUMPTIONS_FEASIBLE);
  SA_REACH(SA_BR_T2_POSITIVE_CORRECTION_FEASIBLE);
  SA_REACH(SA_BR_T2_NEGATIVE_CORRECTION_FEASIBLE);
  SA_REACH(SA_BR_T2_ZERO_CORRECTION_FEASIBLE);
  SA_REACH(SA_BR_T2_TARGET_1_REACHED);
  SA_REACH(SA_BR_T2_TARGET_2_REACHED);
  SA_REACH(SA_BR_T2_TARGET_3_REACHED);
  SA_REACH(SA_BR_T2_ASSERTION_BLOCK_REACHED);

  __CPROVER_assert(target_calls == 3U,
                   "SA_BR_T2_TARGET_CALL_COUNT");
  __CPROVER_assert(correction >= -1 && correction <= 1,
                   "SA_BR_T2_CORRECTION_COEFFICIENT_BOUND");
  __CPROVER_assert((int32_t)r_sum ==
                       centered_sum - correction * SA_BR_Q,
                   "SA_BR_T2_EXACT_ONE_CORRECTION_LAW");
  __CPROVER_assert(centered_sum - (int32_t)r_sum ==
                       correction * SA_BR_Q,
                   "SA_BR_T2_REDUCED_OPERAND_SUM_RESIDUE_PRESERVATION");
  __CPROVER_assert(full_sum >= -65536 && full_sum <= 65534,
                   "SA_BR_T2_FULL_SUM_DOMAIN_BOUND");

  oracle_case_matches = 0;
  if (full_sum >= -65536 && full_sum <= -64916)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -65536 && full_sum <= -64916) ||
          (int32_t)r_sum == full_sum - (-20) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M20");
  if (full_sum >= -64915 && full_sum <= -61587)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -64915 && full_sum <= -61587) ||
          (int32_t)r_sum == full_sum - (-19) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M19");
  if (full_sum >= -61586 && full_sum <= -58258)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -61586 && full_sum <= -58258) ||
          (int32_t)r_sum == full_sum - (-18) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M18");
  if (full_sum >= -58257 && full_sum <= -54929)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -58257 && full_sum <= -54929) ||
          (int32_t)r_sum == full_sum - (-17) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M17");
  if (full_sum >= -54928 && full_sum <= -51600)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -54928 && full_sum <= -51600) ||
          (int32_t)r_sum == full_sum - (-16) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M16");
  if (full_sum >= -51599 && full_sum <= -48271)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -51599 && full_sum <= -48271) ||
          (int32_t)r_sum == full_sum - (-15) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M15");
  if (full_sum >= -48270 && full_sum <= -44942)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -48270 && full_sum <= -44942) ||
          (int32_t)r_sum == full_sum - (-14) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M14");
  if (full_sum >= -44941 && full_sum <= -41613)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -44941 && full_sum <= -41613) ||
          (int32_t)r_sum == full_sum - (-13) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M13");
  if (full_sum >= -41612 && full_sum <= -38284)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -41612 && full_sum <= -38284) ||
          (int32_t)r_sum == full_sum - (-12) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M12");
  if (full_sum >= -38283 && full_sum <= -34955)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -38283 && full_sum <= -34955) ||
          (int32_t)r_sum == full_sum - (-11) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M11");
  if (full_sum >= -34954 && full_sum <= -31626)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -34954 && full_sum <= -31626) ||
          (int32_t)r_sum == full_sum - (-10) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M10");
  if (full_sum >= -31625 && full_sum <= -28297)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -31625 && full_sum <= -28297) ||
          (int32_t)r_sum == full_sum - (-9) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M09");
  if (full_sum >= -28296 && full_sum <= -24968)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -28296 && full_sum <= -24968) ||
          (int32_t)r_sum == full_sum - (-8) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M08");
  if (full_sum >= -24967 && full_sum <= -21639)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -24967 && full_sum <= -21639) ||
          (int32_t)r_sum == full_sum - (-7) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M07");
  if (full_sum >= -21638 && full_sum <= -18310)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -21638 && full_sum <= -18310) ||
          (int32_t)r_sum == full_sum - (-6) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M06");
  if (full_sum >= -18309 && full_sum <= -14981)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -18309 && full_sum <= -14981) ||
          (int32_t)r_sum == full_sum - (-5) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M05");
  if (full_sum >= -14980 && full_sum <= -11652)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -14980 && full_sum <= -11652) ||
          (int32_t)r_sum == full_sum - (-4) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M04");
  if (full_sum >= -11651 && full_sum <= -8323)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -11651 && full_sum <= -8323) ||
          (int32_t)r_sum == full_sum - (-3) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M03");
  if (full_sum >= -8322 && full_sum <= -4994)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -8322 && full_sum <= -4994) ||
          (int32_t)r_sum == full_sum - (-2) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M02");
  if (full_sum >= -4993 && full_sum <= -1665)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -4993 && full_sum <= -1665) ||
          (int32_t)r_sum == full_sum - (-1) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_M01");
  if (full_sum >= -1664 && full_sum <= 1664)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= -1664 && full_sum <= 1664) ||
          (int32_t)r_sum == full_sum - (0) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P00");
  if (full_sum >= 1665 && full_sum <= 4993)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 1665 && full_sum <= 4993) ||
          (int32_t)r_sum == full_sum - (1) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P01");
  if (full_sum >= 4994 && full_sum <= 8322)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 4994 && full_sum <= 8322) ||
          (int32_t)r_sum == full_sum - (2) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P02");
  if (full_sum >= 8323 && full_sum <= 11651)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 8323 && full_sum <= 11651) ||
          (int32_t)r_sum == full_sum - (3) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P03");
  if (full_sum >= 11652 && full_sum <= 14980)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 11652 && full_sum <= 14980) ||
          (int32_t)r_sum == full_sum - (4) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P04");
  if (full_sum >= 14981 && full_sum <= 18309)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 14981 && full_sum <= 18309) ||
          (int32_t)r_sum == full_sum - (5) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P05");
  if (full_sum >= 18310 && full_sum <= 21638)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 18310 && full_sum <= 21638) ||
          (int32_t)r_sum == full_sum - (6) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P06");
  if (full_sum >= 21639 && full_sum <= 24967)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 21639 && full_sum <= 24967) ||
          (int32_t)r_sum == full_sum - (7) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P07");
  if (full_sum >= 24968 && full_sum <= 28296)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 24968 && full_sum <= 28296) ||
          (int32_t)r_sum == full_sum - (8) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P08");
  if (full_sum >= 28297 && full_sum <= 31625)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 28297 && full_sum <= 31625) ||
          (int32_t)r_sum == full_sum - (9) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P09");
  if (full_sum >= 31626 && full_sum <= 34954)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 31626 && full_sum <= 34954) ||
          (int32_t)r_sum == full_sum - (10) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P10");
  if (full_sum >= 34955 && full_sum <= 38283)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 34955 && full_sum <= 38283) ||
          (int32_t)r_sum == full_sum - (11) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P11");
  if (full_sum >= 38284 && full_sum <= 41612)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 38284 && full_sum <= 41612) ||
          (int32_t)r_sum == full_sum - (12) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P12");
  if (full_sum >= 41613 && full_sum <= 44941)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 41613 && full_sum <= 44941) ||
          (int32_t)r_sum == full_sum - (13) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P13");
  if (full_sum >= 44942 && full_sum <= 48270)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 44942 && full_sum <= 48270) ||
          (int32_t)r_sum == full_sum - (14) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P14");
  if (full_sum >= 48271 && full_sum <= 51599)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 48271 && full_sum <= 51599) ||
          (int32_t)r_sum == full_sum - (15) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P15");
  if (full_sum >= 51600 && full_sum <= 54928)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 51600 && full_sum <= 54928) ||
          (int32_t)r_sum == full_sum - (16) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P16");
  if (full_sum >= 54929 && full_sum <= 58257)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 54929 && full_sum <= 58257) ||
          (int32_t)r_sum == full_sum - (17) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P17");
  if (full_sum >= 58258 && full_sum <= 61586)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 58258 && full_sum <= 61586) ||
          (int32_t)r_sum == full_sum - (18) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P18");
  if (full_sum >= 61587 && full_sum <= 64915)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 61587 && full_sum <= 64915) ||
          (int32_t)r_sum == full_sum - (19) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P19");
  if (full_sum >= 64916 && full_sum <= 65534)
  {
    oracle_case_matches++;
  }
  __CPROVER_assert(
      !(full_sum >= 64916 && full_sum <= 65534) ||
          (int32_t)r_sum == full_sum - (20) * SA_BR_Q,
      "SA_BR_T2_ORACLE_AND_CONGRUENCE_CASE_P20");

  __CPROVER_assert(oracle_case_matches == 1,
                   "SA_BR_T2_ORACLE_PARTITION_TOTAL_AND_UNIQUE");
  __CPROVER_assert((int32_t)r_sum >= -SA_BR_CENTERED_MAX &&
                       (int32_t)r_sum <= SA_BR_CENTERED_MAX,
                   "SA_BR_T2_FINAL_CENTERED_RANGE");

#if defined(SKILL_FAIL_CONTROL)
  __CPROVER_assert((int32_t)r_sum == centered_sum,
                   "SA_BR_T2_FC_FALSE_NO_WRAP_CORRECTION");
#endif

  return 0;
}
