#include <stddef.h>
#include <stdint.h>

#include "src/verify.h"

#define ZERO_T2_HOST_BYTES 16u
#define ZERO_T2_WITNESS_BYTES 8u

size_t nondet_size_t(void);
uint8_t nondet_uint8_t(void);

void harness(void)
{
  uint8_t buffer[ZERO_T2_HOST_BYTES];
  uint8_t before[ZERO_T2_HOST_BYTES];

  uint8_t unrelated[ZERO_T2_HOST_BYTES];
  uint8_t unrelated_before[ZERO_T2_HOST_BYTES];

  uint8_t zero_buffer[ZERO_T2_HOST_BYTES];
  uint8_t zero_before[ZERO_T2_HOST_BYTES];

  uint8_t frame_witness[ZERO_T2_WITNESS_BYTES] = {
      0x11u, 0x22u, 0xA1u, 0xB2u,
      0xC3u, 0xD4u, 0x77u, 0x88u};

  size_t offset;
  size_t length;
  size_t end;
  size_t zero_offset;
  size_t i;

  for (i = 0u; i < ZERO_T2_HOST_BYTES; i++)
  {
    buffer[i] = nondet_uint8_t();
    before[i] = buffer[i];

    unrelated[i] = nondet_uint8_t();
    unrelated_before[i] = unrelated[i];

    zero_buffer[i] = nondet_uint8_t();
    zero_before[i] = zero_buffer[i];
  }

  /*
   * Arbitrary valid interval, including zero length.
   * The pointer itself always remains within the host object.
   */
  offset = nondet_size_t();
  length = nondet_size_t();

  __CPROVER_assume(offset < ZERO_T2_HOST_BYTES);
  __CPROVER_assume(length <= ZERO_T2_HOST_BYTES - offset);

  end = offset + length;

  mlk_zeroize(&buffer[offset], length);

  for (i = 0u; i < ZERO_T2_HOST_BYTES; i++)
  {
    if (i < offset)
    {
      __CPROVER_assert(
          buffer[i] == before[i],
          "ZERO-T2.P1: every prefix byte remains unchanged");
    }

    if (i >= end)
    {
      __CPROVER_assert(
          buffer[i] == before[i],
          "ZERO-T2.P2: every suffix byte remains unchanged");
    }

    __CPROVER_assert(
        unrelated[i] == unrelated_before[i],
        "ZERO-T2.P3: separate unrelated object remains unchanged");
  }

  /*
   * Dedicated zero-length identity execution.
   */
  zero_offset = nondet_size_t();
  __CPROVER_assume(zero_offset < ZERO_T2_HOST_BYTES);

  mlk_zeroize(&zero_buffer[zero_offset], 0u);

  for (i = 0u; i < ZERO_T2_HOST_BYTES; i++)
  {
    __CPROVER_assert(
        zero_buffer[i] == zero_before[i],
        "ZERO-T2.P4: zero-length invocation preserves the complete object");
  }

  /*
   * Concrete non-vacuity and frame witnesses.
   * The middle four bytes are wiped; both guards must remain intact.
   */
  mlk_zeroize(&frame_witness[2], 4u);

  __CPROVER_assert(
      frame_witness[0] == 0x11u &&
      frame_witness[1] == 0x22u,
      "ZERO-T2.NV1: concrete prefix guard remains reachable and unchanged");

  __CPROVER_assert(
      frame_witness[6] == 0x77u &&
      frame_witness[7] == 0x88u,
      "ZERO-T2.NV2: concrete suffix guard remains reachable and unchanged");

  __CPROVER_assert(
      frame_witness[2] == 0u &&
      frame_witness[3] == 0u &&
      frame_witness[4] == 0u &&
      frame_witness[5] == 0u,
      "ZERO-T2.NV3: concrete selected middle interval is actually wiped");
}
