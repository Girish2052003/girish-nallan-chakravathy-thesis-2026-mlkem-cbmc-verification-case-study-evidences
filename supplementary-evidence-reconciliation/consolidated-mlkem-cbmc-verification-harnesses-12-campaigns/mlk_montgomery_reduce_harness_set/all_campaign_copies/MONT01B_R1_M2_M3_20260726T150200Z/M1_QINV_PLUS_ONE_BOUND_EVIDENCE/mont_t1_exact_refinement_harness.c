// Clean-room CBMC functional harness for mlk_montgomery_reduce.
// No production source is modified.

#include <limits.h>
#include <stdint.h>

#include "cbmc.h"
#include "poly.h"

#define MONT_Q ((int64_t)3329)
#define MONT_R ((int64_t)65536)
#define MONT_QINV_UNSIGNED ((uint64_t)62209)

#define MONT_CONTRACT_LIMIT \
  ((int32_t)(INT32_MAX - (((int32_t)1 << 15) * MLKEM_Q)))

/*
 * Independent mathematical oracle:
 *
 * 1. Obtain the canonical low word using well-defined unsigned conversion.
 * 2. Multiply by q^{-1} modulo 2^16.
 * 3. Convert the witness independently to the signed interval.
 * 4. Divide the exactly divisible numerator using int64_t arithmetic.
 */
static int64_t mont_oracle_t(int32_t a)
{
  int64_t low_signed;
  uint64_t low;
  uint64_t raw_t;

  /*
   * Compute the canonical residue in [0, R) without a value-changing
   * negative-signed-to-unsigned conversion.
   */
  low_signed = (int64_t)a % MONT_R;

  if (low_signed < 0)
  {
    low_signed += MONT_R;
  }

  __CPROVER_assert(
      low_signed >= 0 && low_signed < MONT_R,
      "MONT-T1.ORACLE.low_word_normalized");

  low = (uint64_t)low_signed;
  raw_t = (low * MONT_QINV_UNSIGNED) % (uint64_t)MONT_R;

  if (raw_t >= (uint64_t)(MONT_R / 2))
  {
    return (int64_t)raw_t - MONT_R;
  }

  return (int64_t)raw_t;
}

static int64_t mont_oracle_result(int32_t a, int64_t *witness_t)
{
  int64_t t;
  int64_t numerator;

  t = mont_oracle_t(a);
  numerator = (int64_t)a - t * MONT_Q;

  __CPROVER_assert(
      numerator % MONT_R == 0,
      "MONT-T1.P2.oracle_numerator_exactly_divisible_by_R");

  *witness_t = t;
  return numerator / MONT_R;
}

void harness(void)
{
  int32_t a;

  int16_t implementation_result;
  int64_t oracle_result;
  int64_t oracle_t;
  int64_t reconstructed;

  int16_t alternative_result;
  int16_t alternative_t;

  /*
   * Exact source-contract domain:
   *
   *   -2038398974 <= a <= 2038398974
   */
  __CPROVER_assume(a < MONT_CONTRACT_LIMIT);
  __CPROVER_assume(a > -MONT_CONTRACT_LIMIT);

  implementation_result = mlk_montgomery_reduce(a);
  oracle_result = mont_oracle_result(a, &oracle_t);

  __CPROVER_assert(
      oracle_t >= INT16_MIN && oracle_t <= INT16_MAX,
      "MONT-T1.P2.oracle_witness_is_signed16");

  __CPROVER_assert(
      oracle_result >= INT16_MIN && oracle_result <= INT16_MAX,
      "MONT-T1.P1.oracle_result_fits_int16");

  __CPROVER_assert(
      (int64_t)implementation_result == oracle_result,
      "MONT-T1.P1.full_domain_exact_oracle_equality");

  reconstructed =
      MONT_R * (int64_t)implementation_result + MONT_Q * oracle_t;

  __CPROVER_assert(
      reconstructed == (int64_t)a,
      "MONT-T1.P2.exact_signed_witness_reconstruction");

  __CPROVER_assert(
      (((int64_t)implementation_result * MONT_R - (int64_t)a) %
       MONT_Q) == 0,
      "MONT-T1.P2.scaled_modular_congruence_divisibility");

  /*
   * Uniqueness:
   * any other signed-16 pair satisfying the same decomposition must equal
   * the implementation result and independently constructed witness.
   */
  __CPROVER_assume(
      (int64_t)a ==
      MONT_R * (int64_t)alternative_result +
          MONT_Q * (int64_t)alternative_t);

  __CPROVER_assert(
      alternative_result == implementation_result,
      "MONT-T1.P3.unique_result_in_signed16_decomposition");

  __CPROVER_assert(
      (int64_t)alternative_t == oracle_t,
      "MONT-T1.P3.unique_witness_in_signed16_decomposition");

  __CPROVER_assert(
      implementation_result >= -32767 &&
          implementation_result <= 32767,
      "MONT-T1.P4.full_contract_domain_sharp_output_bound");

  /*
   * Concrete endpoint witnesses establish that the universal bound cannot
   * be tightened.
   */
  __CPROVER_assert(
      mlk_montgomery_reduce((int32_t)-2038363401) == (int16_t)-32767,
      "MONT-T1.P5.minimum_output_is_attainable");

  __CPROVER_assert(
      mlk_montgomery_reduce((int32_t)2038366730) == (int16_t)32767,
      "MONT-T1.P5.maximum_output_is_attainable");
}
