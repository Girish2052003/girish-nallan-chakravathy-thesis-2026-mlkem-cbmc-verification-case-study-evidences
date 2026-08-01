#include <stddef.h>
#include <stdint.h>

void zero_v1_wipe_M8(void *ptr, size_t len)
{
  uint8_t *bytes = (uint8_t *)ptr;
  size_t i;

  for (i = 0u; i < len; i++)
  {
    bytes[i] = 0u;
  }
}

void zero_v1_mutant_M8(
    uint8_t *buffer,
    size_t offset,
    size_t length_1,
    size_t length_2)
{
  /*
   * M8: perform only the first adjacent partition.
   */
  zero_v1_wipe_M8(&buffer[offset], length_1);
  (void)length_2;
}

void harness(void)
{
  uint8_t sequence[8] = {
      0x11u, 0x22u, 0xA1u, 0xB2u,
      0xC3u, 0xD4u, 0x77u, 0x88u};

  uint8_t combined[8] = {
      0x11u, 0x22u, 0xA1u, 0xB2u,
      0xC3u, 0xD4u, 0x77u, 0x88u};

  zero_v1_mutant_M8(sequence, 2u, 2u, 2u);
  zero_v1_wipe_M8(&combined[2], 4u);

  __CPROVER_assert(
      sequence[4] == combined[4],
      "ZERO-V1.M8: ZERO-T3.P2 rejects the omitted-partition mutant");
}
