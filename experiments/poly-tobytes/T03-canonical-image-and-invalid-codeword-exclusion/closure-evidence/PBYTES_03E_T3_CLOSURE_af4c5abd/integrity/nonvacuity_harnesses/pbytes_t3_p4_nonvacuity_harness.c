// PBYTES-T3.P4 invalid-codeword feasibility witnesses.
//
// Four concrete candidate blocks contain invalid 12-bit fields.
// The true control assertion confirms the invalid-domain construction.
// The four false assertions establish post-call reachability.

#include <stdint.h>

#include "cbmc.h"
#include "compress.h"

#define PBYTES_PAIR_COUNT (MLKEM_N / 2u)

void harness(void)
{
  mlk_poly input;
  uint8_t output[MLKEM_POLYBYTES];

  uint8_t scenario;

  uint16_t invalid_even;
  uint16_t invalid_odd;

  uint8_t candidate_b0;
  uint8_t candidate_b1;
  uint8_t candidate_b2;

  uint16_t decoded_even;
  uint16_t decoded_odd;

  unsigned selected_pair;
  unsigned i;

  __CPROVER_assume(scenario < 4u);

  selected_pair =
    (scenario == 0u || scenario == 2u)
      ? 0u
      : PBYTES_PAIR_COUNT - 1u;

  for (i = 0u; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 0;
  }

  invalid_even = 0u;
  invalid_odd = 0u;

  if (scenario == 0u)
  {
    invalid_even = MLKEM_Q;
    invalid_odd = 0u;
  }

  if (scenario == 1u)
  {
    invalid_even = 0u;
    invalid_odd = MLKEM_Q;
  }

  if (scenario == 2u)
  {
    invalid_even = MLKEM_Q;
    invalid_odd = MLKEM_Q;
  }

  if (scenario == 3u)
  {
    invalid_even = 4095u;
    invalid_odd = 4095u;
  }

  candidate_b0 =
    (uint8_t)((unsigned)invalid_even % 256u);

  candidate_b1 =
    (uint8_t)(
      ((unsigned)invalid_even / 256u) +
      16u * ((unsigned)invalid_odd % 16u));

  candidate_b2 =
    (uint8_t)((unsigned)invalid_odd / 16u);

  decoded_even =
    (uint16_t)candidate_b0 +
    (uint16_t)(
      256u * (uint16_t)(candidate_b1 & 0x0Fu));

  decoded_odd =
    (uint16_t)(candidate_b1 >> 4) +
    (uint16_t)(
      16u * (uint16_t)candidate_b2);

  __CPROVER_assert(
    decoded_even >= MLKEM_Q ||
    decoded_odd >= MLKEM_Q,
    "PBYTES-T3.NVC1 invalid candidate construction control");

  mlk_poly_tobytes(output, &input);

  if (scenario == 0u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV09 invalid even-field q witness");
  }

  if (scenario == 1u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV10 invalid odd-field q witness");
  }

  if (scenario == 2u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV11 both-fields-q witness");
  }

  if (scenario == 3u)
  {
    __CPROVER_assert(
      0,
      "PBYTES-T3.NV12 both-fields-4095 witness");
  }

  (void)selected_pair;
}
