#include <stddef.h>
#include <stdint.h>

void zero_v1_mutant_M1(void *ptr, size_t len)
{
  uint8_t *bytes = (uint8_t *)ptr;
  size_t i;

  for (i = 0u; i < len; i++)
  {
    bytes[i] = 0u;
  }
}

void harness(void)
{
  uint8_t buffer[8] = {
      0x11u, 0x22u, 0xA1u, 0xB2u,
      0xC3u, 0xD4u, 0x77u, 0x88u};

  zero_v1_mutant_M1(&buffer[2], 4u);

  __CPROVER_assert(
      buffer[2] == 0u,
      "ZERO-V1.M1: ZERO-T1.P1 rejects the remove-wipe mutant");
}
