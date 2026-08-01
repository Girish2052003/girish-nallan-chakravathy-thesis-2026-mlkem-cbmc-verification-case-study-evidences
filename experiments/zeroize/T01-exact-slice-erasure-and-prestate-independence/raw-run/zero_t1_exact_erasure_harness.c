#include <stddef.h>
#include <stdint.h>

#include "src/verify.h"

#define ZERO_T1_HOST_BYTES 16u

size_t nondet_size_t(void);
uint8_t nondet_uint8_t(void);

void harness(void)
{
  uint8_t a[ZERO_T1_HOST_BYTES];
  uint8_t b[ZERO_T1_HOST_BYTES];
  uint8_t witness_buffer[ZERO_T1_HOST_BYTES];

  size_t offset;
  size_t length;
  size_t end;
  size_t i;

  size_t witness_offset;
  size_t witness_length;
  size_t witness_end;
  size_t witness_index;

  uint8_t witness_before;

  /*
   * Arbitrary independent pre-states.
   */
  for (i = 0u; i < ZERO_T1_HOST_BYTES; i++)
  {
    a[i] = nondet_uint8_t();
    b[i] = nondet_uint8_t();
    witness_buffer[i] = nondet_uint8_t();
  }

  /*
   * Arbitrary valid non-empty interval.
   */
  offset = nondet_size_t();
  length = nondet_size_t();

  __CPROVER_assume(offset < ZERO_T1_HOST_BYTES);
  __CPROVER_assume(length > 0u);
  __CPROVER_assume(length <= ZERO_T1_HOST_BYTES - offset);

  end = offset + length;

  /*
   * Two executions over independently initialized buffers.
   */
  mlk_zeroize(&a[offset], length);
  mlk_zeroize(&b[offset], length);

  for (i = 0u; i < ZERO_T1_HOST_BYTES; i++)
  {
    if (i >= offset && i < end)
    {
      __CPROVER_assert(
          a[i] == 0u,
          "ZERO-T1.P1: every selected byte in arbitrary buffer A is zero");

      __CPROVER_assert(
          b[i] == 0u,
          "ZERO-T1.P2: every selected byte in arbitrary buffer B is zero");

      __CPROVER_assert(
          a[i] == b[i],
          "ZERO-T1.P3: selected post-state is independent of pre-state");
    }
  }

  /*
   * Explicit non-vacuity witness:
   * choose one valid selected byte and require it to be nonzero initially.
   */
  witness_offset = nondet_size_t();
  witness_length = nondet_size_t();
  witness_index = nondet_size_t();

  __CPROVER_assume(witness_offset < ZERO_T1_HOST_BYTES);
  __CPROVER_assume(witness_length > 0u);
  __CPROVER_assume(
      witness_length <= ZERO_T1_HOST_BYTES - witness_offset);

  witness_end = witness_offset + witness_length;

  __CPROVER_assume(witness_index >= witness_offset);
  __CPROVER_assume(witness_index < witness_end);

  witness_before = witness_buffer[witness_index];

  __CPROVER_assume(witness_before != 0u);

  mlk_zeroize(&witness_buffer[witness_offset], witness_length);

  __CPROVER_assert(
      witness_buffer[witness_index] == 0u,
      "ZERO-T1.NV1: selected nonzero witness byte becomes zero");

  __CPROVER_assert(
      witness_buffer[witness_index] != witness_before,
      "ZERO-T1.NV2: execution changes the selected nonzero witness");
}
