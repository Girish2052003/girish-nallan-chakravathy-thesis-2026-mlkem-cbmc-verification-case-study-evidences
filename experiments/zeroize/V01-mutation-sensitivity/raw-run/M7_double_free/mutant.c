#include <stddef.h>
#include <stdint.h>

size_t zero_v1_free_calls_M7;

void zero_v1_wipe_M7(void *ptr, size_t len)
{
  uint8_t *bytes = (uint8_t *)ptr;
  size_t i;

  for (i = 0u; i < len; i++)
  {
    bytes[i] = 0u;
  }
}

void zero_v1_observe_free_M7(void *ptr, size_t len)
{
  (void)ptr;
  (void)len;
  zero_v1_free_calls_M7++;
}

void zero_v1_mutant_M7(uint8_t **ptr, size_t len)
{
  if (*ptr != NULL)
  {
    zero_v1_wipe_M7(*ptr, len);

    /*
     * M7: release the same non-null allocation twice.
     */
    zero_v1_observe_free_M7(*ptr, len);
    zero_v1_observe_free_M7(*ptr, len);

    *ptr = NULL;
  }
}

void harness(void)
{
  uint8_t storage[8] = {
      0x11u, 0x22u, 0xA1u, 0xB2u,
      0xC3u, 0xD4u, 0x77u, 0x88u};

  uint8_t *secret = storage;

  zero_v1_free_calls_M7 = 0u;

  zero_v1_mutant_M7(&secret, 8u);

  __CPROVER_assert(
      zero_v1_free_calls_M7 == 1u,
      "ZERO-V1.M7: ZERO-T4.P4 rejects the double-free mutant");
}
