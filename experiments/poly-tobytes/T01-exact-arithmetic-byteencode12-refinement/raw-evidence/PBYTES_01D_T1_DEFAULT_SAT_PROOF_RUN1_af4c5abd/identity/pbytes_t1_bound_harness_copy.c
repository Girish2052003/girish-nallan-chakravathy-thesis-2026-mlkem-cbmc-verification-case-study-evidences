// PBYTES-T1 positive semantic harness.
//
// Target:
//   mlk_poly_tobytes
//
// Portable implementation required:
//   mlk_poly_tobytes_c
//
// The oracle deliberately uses arithmetic division and remainder rather than
// copying the production shift-and-mask expressions.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_GUARD_BYTES 8u
#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

typedef struct
{
  uint8_t left[PBYTES_GUARD_BYTES];
  uint8_t output[MLKEM_POLYBYTES];
  uint8_t right[PBYTES_GUARD_BYTES];
} pbytes_guarded_output;

void harness(void)
{
  mlk_poly input;
  int16_t input_before[MLKEM_N];

  pbytes_guarded_output guarded;
  uint8_t left_before[PBYTES_GUARD_BYTES];
  uint8_t right_before[PBYTES_GUARD_BYTES];

  uint8_t oracle[MLKEM_POLYBYTES];

  uint16_t selected_pair;
  uint16_t c0;
  uint16_t c1;

  uint32_t packed_output;
  uint32_t packed_input;

  unsigned base;
  unsigned i;

  /*
   * Frozen canonical input domain.
   *
   * No result-shaped assumption is permitted.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);

    input_before[i] = input.coeffs[i];
  }

  /*
   * Preserve arbitrary symbolic guard values.
   */
  for (i = 0u; i < PBYTES_GUARD_BYTES; i++)
  {
    left_before[i] = guarded.left[i];
    right_before[i] = guarded.right[i];
  }

  /*
   * Independent arithmetic ByteEncode12 oracle.
   *
   * For each coefficient pair:
   *
   *   oracle[3i]     = c0 mod 256
   *   oracle[3i + 1] = floor(c0 / 256) + 16 * (c1 mod 16)
   *   oracle[3i + 2] = floor(c1 / 16)
   */
  for (i = 0u; i < PBYTES_PAIR_COUNT; i++)
  {
    c0 = (uint16_t)input.coeffs[2u * i];
    c1 = (uint16_t)input.coeffs[2u * i + 1u];

    oracle[3u * i] =
      (uint8_t)(c0 % 256u);

    oracle[3u * i + 1u] =
      (uint8_t)((c0 / 256u) + 16u * (c1 % 16u));

    oracle[3u * i + 2u] =
      (uint8_t)(c1 / 16u);
  }

  /*
   * The selected pair makes P1-P5 independently visible as five stable
   * assertion locations.
   */
  __CPROVER_assume(selected_pair < PBYTES_PAIR_COUNT);

  /*
   * Real frozen public function call.
   *
   * The linked GOTO model must contain the actual public wrapper and actual
   * mlk_poly_tobytes_c body. Neither may be replaced by a contract.
   */
  mlk_poly_tobytes(guarded.output, &input);

  base = 3u * (unsigned)selected_pair;

  c0 = (uint16_t)input_before[2u * (unsigned)selected_pair];
  c1 = (uint16_t)input_before[2u * (unsigned)selected_pair + 1u];

  __CPROVER_assert(
    guarded.output[base] == (uint8_t)(c0 % 256u),
    "PBYTES-T1.P1 exact low byte of even coefficient");

  __CPROVER_assert(
    (uint8_t)(guarded.output[base + 1u] % 16u) ==
      (uint8_t)(c0 / 256u),
    "PBYTES-T1.P2 exact high nibble of even coefficient");

  __CPROVER_assert(
    (uint8_t)(guarded.output[base + 1u] / 16u) ==
      (uint8_t)(c1 % 16u),
    "PBYTES-T1.P3 exact low nibble of odd coefficient");

  __CPROVER_assert(
    guarded.output[base + 2u] == (uint8_t)(c1 / 16u),
    "PBYTES-T1.P4 exact high byte of odd coefficient");

  packed_output =
    (uint32_t)guarded.output[base] +
    256u * (uint32_t)guarded.output[base + 1u] +
    65536u * (uint32_t)guarded.output[base + 2u];

  packed_input =
    (uint32_t)c0 +
    4096u * (uint32_t)c1;

  __CPROVER_assert(
    packed_output == packed_input,
    "PBYTES-T1.P5 exact 24-bit packed-word equality");

  /*
   * Full 384-byte theorem.
   *
   * guarded.output was unconstrained before the call. Therefore this also
   * detects an output byte that was not completely overwritten.
   */
  for (i = 0u; i < MLKEM_POLYBYTES; i++)
  {
    __CPROVER_assert(
      guarded.output[i] == oracle[i],
      "PBYTES-T1.P6 complete 384-byte arithmetic-oracle equality");
  }

  /*
   * Mandatory supporting controls. These are not counted as additional
   * mathematical theorem families.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
      input.coeffs[i] == input_before[i],
      "PBYTES-T1.C1 input-frame preservation");
  }

  for (i = 0u; i < PBYTES_GUARD_BYTES; i++)
  {
    __CPROVER_assert(
      guarded.left[i] == left_before[i],
      "PBYTES-T1.C2 left output canary preservation");

    __CPROVER_assert(
      guarded.right[i] == right_before[i],
      "PBYTES-T1.C3 right output canary preservation");
  }
}
