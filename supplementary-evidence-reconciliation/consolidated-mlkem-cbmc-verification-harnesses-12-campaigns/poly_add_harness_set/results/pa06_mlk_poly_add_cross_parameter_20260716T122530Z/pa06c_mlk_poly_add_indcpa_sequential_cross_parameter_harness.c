/*
 * PA-06C: Cross-parameter sequential call-site verification for
 *
 *         mlk_poly_add(v, epp);
 *         mlk_poly_add(v, k);
 *
 * in mlk_indcpa_enc.
 *
 * Compiled separately for ML-KEM-512, ML-KEM-768, and ML-KEM-1024.
 *
 * The safe-sum conditions for both calls are assertions derived from:
 *   abs(v_initial[i]) < MLK_INVNTT_BOUND
 *   abs(epp[i])       < MLKEM_ETA2 + 1
 *   k[i]              in {0, MLKEM_Q_HALF}
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa06c_nondet_int16(void)
{
  int16_t value;
  return value;
}

static uint8_t pa06c_nondet_uint8(void)
{
  uint8_t value;
  return value;
}

static int32_t pa06c_mod_q(int32_t value)
{
  int32_t remainder;

  remainder = value % (int32_t)MLKEM_Q;
  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return remainder;
}

int main(void)
{
  mlk_poly v;
  mlk_poly epp;
  mlk_poly k;

  mlk_poly v_initial;
  mlk_poly epp_before;
  mlk_poly k_before;

  uint8_t message[MLKEM_N / 8];

  unsigned i;
  unsigned byte_index;
  unsigned bit_index;
  uint8_t message_bit;

  int32_t first_sum;
  int32_t cumulative_sum;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA06C_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA06C_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      MLKEM_Q_HALF == 1665,
      "PA06C_PARAMETER_BINDING: MLKEM_Q_HALF must equal 1665");

  __CPROVER_assert(
      MLKEM_ETA2 == 2,
      "PA06C_PARAMETER_BINDING: MLKEM_ETA2 must equal 2");

  __CPROVER_assert(
      MLK_INVNTT_BOUND == 8 * MLKEM_Q,
      "PA06C_BOUND_BINDING: inverse NTT bound must equal 8*q");

#if MLK_CONFIG_PARAMETER_SET == 512
  __CPROVER_assert(
      MLKEM_K == 2,
      "PA06C_PARAMETER_BINDING: ML-KEM-512 must use MLKEM_K equal to 2");
#elif MLK_CONFIG_PARAMETER_SET == 768
  __CPROVER_assert(
      MLKEM_K == 3,
      "PA06C_PARAMETER_BINDING: ML-KEM-768 must use MLKEM_K equal to 3");
#elif MLK_CONFIG_PARAMETER_SET == 1024
  __CPROVER_assert(
      MLKEM_K == 4,
      "PA06C_PARAMETER_BINDING: ML-KEM-1024 must use MLKEM_K equal to 4");
#else
#error PA-06C requires ML-KEM-512, ML-KEM-768, or ML-KEM-1024
#endif

  __CPROVER_assert(
      &v != &epp,
      "PA06C_OBJECT_SEPARATION: v and epp are distinct");

  __CPROVER_assert(
      &v != &k,
      "PA06C_OBJECT_SEPARATION: v and k are distinct");

  __CPROVER_assert(
      &epp != &k,
      "PA06C_OBJECT_SEPARATION: epp and k are distinct");

  for (i = 0; i < (MLKEM_N / 8); i++)
  {
    message[i] = pa06c_nondet_uint8();
  }

  for (i = 0; i < MLKEM_N; i++)
  {
    v.coeffs[i] = pa06c_nondet_int16();
    epp.coeffs[i] = pa06c_nondet_int16();

    __CPROVER_assume(
        (int32_t)v.coeffs[i] > -(int32_t)MLK_INVNTT_BOUND);
    __CPROVER_assume(
        (int32_t)v.coeffs[i] < (int32_t)MLK_INVNTT_BOUND);

    __CPROVER_assume(
        (int32_t)epp.coeffs[i] > -(int32_t)(MLKEM_ETA2 + 1));
    __CPROVER_assume(
        (int32_t)epp.coeffs[i] < (int32_t)(MLKEM_ETA2 + 1));

    byte_index = i >> 3;
    bit_index = i & 7u;
    message_bit =
        (uint8_t)((message[byte_index] >> bit_index) & (uint8_t)1);

    k.coeffs[i] =
        (message_bit == (uint8_t)0) ?
        (int16_t)0 :
        (int16_t)MLKEM_Q_HALF;

    __CPROVER_assert(
        k.coeffs[i] == 0 ||
            k.coeffs[i] == (int16_t)MLKEM_Q_HALF,
        "PA06C_MESSAGE_IMAGE: k coefficient is 0 or MLKEM_Q_HALF");

    first_sum =
        (int32_t)v.coeffs[i] +
        (int32_t)epp.coeffs[i];

    __CPROVER_assert(
        first_sum >= (int32_t)INT16_MIN,
        "PA06C_P1_FIRST_CALL_LOWER: v+epp is representable");

    __CPROVER_assert(
        first_sum <= (int32_t)INT16_MAX,
        "PA06C_P1_FIRST_CALL_UPPER: v+epp is representable");

    cumulative_sum =
        first_sum +
        (int32_t)k.coeffs[i];

    __CPROVER_assert(
        cumulative_sum >= (int32_t)INT16_MIN,
        "PA06C_P2_SECOND_CALL_LOWER: (v+epp)+k is representable");

    __CPROVER_assert(
        cumulative_sum <= (int32_t)INT16_MAX,
        "PA06C_P2_SECOND_CALL_UPPER: (v+epp)+k is representable");
  }

  v_initial = v;
  epp_before = epp;
  k_before = k;

  mlk_poly_add(&v, &epp);

  for (i = 0; i < MLKEM_N; i++)
  {
    first_sum =
        (int32_t)v_initial.coeffs[i] +
        (int32_t)epp_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == first_sum,
        "PA06C_P3_FIRST_CALL_EXACT: first production call is exact");
  }

  mlk_poly_add(&v, &k);

  for (i = 0; i < MLKEM_N; i++)
  {
    cumulative_sum =
        (int32_t)v_initial.coeffs[i] +
        (int32_t)epp_before.coeffs[i] +
        (int32_t)k_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == cumulative_sum,
        "PA06C_P4_CUMULATIVE_EXACT: sequential production calls compute the cumulative sum");

    __CPROVER_assert(
        epp.coeffs[i] == epp_before.coeffs[i],
        "PA06C_P5_EPP_FRAME: epp remains unchanged");

    __CPROVER_assert(
        k.coeffs[i] == k_before.coeffs[i],
        "PA06C_P6_K_FRAME: k remains unchanged");

    __CPROVER_assert(
        pa06c_mod_q((int32_t)v.coeffs[i]) ==
            pa06c_mod_q(cumulative_sum),
        "PA06C_P7_CROSS_PARAMETER_MOD_Q: cumulative result has the correct residue");
  }

  return 0;
}
