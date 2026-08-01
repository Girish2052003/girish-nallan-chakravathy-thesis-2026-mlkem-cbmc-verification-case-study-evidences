#include <stdint.h>

extern int16_t nondet_int16_t(void);
extern int32_t nondet_int32_t(void);

int16_t mlk_barrett_reduce(int16_t a);

/*
 * Independent centered-modulo oracle.
 *
 * This function deliberately does not use:
 *   - 20159,
 *   - the 2^25 rounding offset,
 *   - a right shift by 26,
 *   - the production Barrett formula.
 */
static int32_t br_af4_centered_oracle(int16_t a)
{
  int32_t u = ((int32_t)a) % 3329;

  if (u < 0)
  {
    u += 3329;
  }

  if (u > 1664)
  {
    u -= 3329;
  }

  return u;
}

/*
 * Exact arithmetic expression whose quotient-cell structure T3 characterizes.
 * This is intentionally formula-specific rather than an independent oracle.
 */
static int32_t br_af4_formula_quotient(int16_t a)
{
  const int32_t magic = 20159;

  return (
      magic * (int32_t)a +
      ((int32_t)1 << 25)) >> 26;
}

void harness(void)
{
  int16_t a = nondet_int16_t();
  int32_t candidate_k = nondet_int32_t();

  int16_t production_result =
      mlk_barrett_reduce(a);

  int32_t centered =
      br_af4_centered_oracle(a);

  int32_t formula_quotient =
      br_af4_formula_quotient(a);

  int32_t oracle_quotient =
      ((int32_t)a - centered) / 3329;

  int32_t reconstructed_result =
      (int32_t)a -
      formula_quotient * 3329;

  int64_t actual_cell_lower =
      (int64_t)formula_quotient * 3329 - 1664;

  int64_t actual_cell_upper =
      (int64_t)formula_quotient * 3329 + 1664;

  int64_t candidate_cell_lower =
      (int64_t)candidate_k * 3329 - 1664;

  int64_t candidate_cell_upper =
      (int64_t)candidate_k * 3329 + 1664;

  int candidate_k_is_valid =
      candidate_k >= -10 &&
      candidate_k <= 10;

  int a_is_in_candidate_cell =
      (int64_t)a >= candidate_cell_lower &&
      (int64_t)a <= candidate_cell_upper;

  __CPROVER_assert(
      formula_quotient == oracle_quotient,
      "BR-AF4-T3.P9 exact quotient equivalence");

  __CPROVER_assert(
      (int32_t)production_result ==
      reconstructed_result,
      "BR-AF4-T3.P10 production affine decomposition");

  __CPROVER_assert(
      formula_quotient >= -10 &&
      formula_quotient <= 10,
      "BR-AF4-T3.P11 tight quotient range");

  __CPROVER_assert(
      (
        (int64_t)a >= actual_cell_lower &&
        (int64_t)a <= actual_cell_upper
      ) &&
      (
        !(candidate_k_is_valid &&
          a_is_in_candidate_cell) ||
        formula_quotient == candidate_k
      ),
      "BR-AF4-T3.P12 exact and unique quotient-cell membership");

  __CPROVER_assert(
      (
        (formula_quotient == -10) ==
        ((int32_t)a <= -31625)
      ) &&
      (
        (formula_quotient == 10) ==
        ((int32_t)a >= 31626)
      ) &&
      (
        (
          formula_quotient >= -9 &&
          formula_quotient <= 9
        ) ==
        (
          (int32_t)a >= -31625 &&
          (int32_t)a <= 31625
        )
      ),
      "BR-AF4-T3.P13 clipped endpoint-cell characterization");
}
