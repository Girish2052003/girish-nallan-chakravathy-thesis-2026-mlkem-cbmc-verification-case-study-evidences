// PBYTES-T2 positive relational harness.
//
// This harness compares two real mlk_poly_tobytes executions.
//
// Input B is identical to input A except that one selected canonical
// coefficient is incremented by exactly one.
//
// Four scenarios partition the possible packing transitions:
//   0: even coefficient without a low-byte carry
//   1: even coefficient with a 255 -> 256 carry
//   2: odd coefficient without a low-nibble carry
//   3: odd coefficient with a 15 -> 16 carry

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly input_a;
  mlk_poly input_b;

  uint8_t output_a[MLKEM_POLYBYTES];
  uint8_t output_b[MLKEM_POLYBYTES];

  uint16_t selected_pair;
  uint8_t scenario;

  unsigned selected_index;
  unsigned base;
  unsigned i;

  __CPROVER_assume(selected_pair < PBYTES_PAIR_COUNT);
  __CPROVER_assume(scenario < 4u);

  /*
   * Establish one arbitrary canonical polynomial and initially copy it.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input_a.coeffs[i] >= 0);
    __CPROVER_assume(input_a.coeffs[i] < MLKEM_Q);

    input_b.coeffs[i] = input_a.coeffs[i];
  }

  /*
   * Scenarios zero and one select an even coefficient.
   * Scenarios two and three select an odd coefficient.
   */
  selected_index =
    2u * (unsigned)selected_pair +
    (scenario >= 2u ? 1u : 0u);

  base = 3u * (unsigned)selected_pair;

  /*
   * Incrementing must remain in the canonical domain.
   */
  __CPROVER_assume(
    input_a.coeffs[selected_index] < MLKEM_Q - 1);

  if (scenario == 0u)
  {
    __CPROVER_assume(
      ((uint16_t)input_a.coeffs[selected_index] % 256u) != 255u);
  }

  if (scenario == 1u)
  {
    __CPROVER_assume(
      ((uint16_t)input_a.coeffs[selected_index] % 256u) == 255u);
  }

  if (scenario == 2u)
  {
    __CPROVER_assume(
      ((uint16_t)input_a.coeffs[selected_index] % 16u) != 15u);
  }

  if (scenario == 3u)
  {
    __CPROVER_assume(
      ((uint16_t)input_a.coeffs[selected_index] % 16u) == 15u);
  }

  input_b.coeffs[selected_index] =
    (int16_t)(input_a.coeffs[selected_index] + 1);

  /*
   * Two real public-wrapper executions.
   */
  mlk_poly_tobytes(output_a, &input_a);
  mlk_poly_tobytes(output_b, &input_b);

  /*
   * P1 — even coefficient, no low-byte carry.
   */
  if (scenario == 0u)
  {
    __CPROVER_assert(
      (unsigned)output_b[base] ==
        (unsigned)output_a[base] + 1u &&
      output_b[base + 1u] == output_a[base + 1u] &&
      output_b[base + 2u] == output_a[base + 2u],
      "PBYTES-T2.P1 even noncarry successor transition");
  }

  /*
   * P2 — even coefficient, 255 -> 256 carry.
   */
  if (scenario == 1u)
  {
    __CPROVER_assert(
      output_a[base] == 255u &&
      output_b[base] == 0u &&

      (unsigned)(output_b[base + 1u] & 0x0Fu) ==
        (unsigned)(output_a[base + 1u] & 0x0Fu) + 1u &&

      (output_b[base + 1u] & 0xF0u) ==
        (output_a[base + 1u] & 0xF0u) &&

      output_b[base + 2u] == output_a[base + 2u],
      "PBYTES-T2.P2 even 255-to-256 carry transition");
  }

  /*
   * P3 — odd coefficient, no low-nibble carry.
   */
  if (scenario == 2u)
  {
    __CPROVER_assert(
      output_b[base] == output_a[base] &&

      (output_b[base + 1u] & 0x0Fu) ==
        (output_a[base + 1u] & 0x0Fu) &&

      (unsigned)(output_b[base + 1u] & 0xF0u) ==
        (unsigned)(output_a[base + 1u] & 0xF0u) + 0x10u &&

      output_b[base + 2u] == output_a[base + 2u],
      "PBYTES-T2.P3 odd noncarry successor transition");
  }

  /*
   * P4 — odd coefficient, 15 -> 16 carry.
   */
  if (scenario == 3u)
  {
    __CPROVER_assert(
      output_b[base] == output_a[base] &&

      (output_b[base + 1u] & 0x0Fu) ==
        (output_a[base + 1u] & 0x0Fu) &&

      (output_a[base + 1u] & 0xF0u) == 0xF0u &&
      (output_b[base + 1u] & 0xF0u) == 0u &&

      (unsigned)output_b[base + 2u] ==
        (unsigned)output_a[base + 2u] + 1u,
      "PBYTES-T2.P4 odd 15-to-16 carry transition");
  }
}
