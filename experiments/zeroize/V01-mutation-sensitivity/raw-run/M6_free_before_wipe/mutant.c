#include <stddef.h>
#include <stdint.h>

uint8_t zero_v1_observed_all_zero_M6;

void zero_v1_wipe_M6(void *ptr, size_t len)
{
  uint8_t *bytes = (uint8_t *)ptr;
  size_t i;

  for (i = 0u; i < len; i++)
  {
    bytes[i] = 0u;
  }
}

void zero_v1_observe_free_M6(void *ptr, size_t len)
{
  uint8_t *bytes = (uint8_t *)ptr;
  size_t i;

  zero_v1_observed_all_zero_M6 = 1u;

  for (i = 0u; i < len; i++)
  {
    if (bytes[i] != 0u)
    {
      zero_v1_observed_all_zero_M6 = 0u;
    }
  }
}

void zero_v1_mutant_M6(uint8_t **ptr, size_t len)
{
  if (*ptr != NULL)
  {
    /*
     * M6: expose the allocation to the release observer before wiping it.
     */
    zero_v1_observe_free_M6(*ptr, len);
    zero_v1_wipe_M6(*ptr, len);
    *ptr = NULL;
  }
}

void harness(void)
{
  uint8_t storage[8] = {
      0x11u, 0x22u, 0xA1u, 0xB2u,
      0xC3u, 0xD4u, 0x77u, 0x88u};

  uint8_t *secret = storage;

  zero_v1_observed_all_zero_M6 = 0u;

  zero_v1_mutant_M6(&secret, 8u);

  __CPROVER_assert(
      zero_v1_observed_all_zero_M6 == 1u,
      "ZERO-V1.M6: ZERO-T4.P3 rejects the free-before-wipe mutant");
}
