#include <stddef.h>
#include <stdint.h>

void *zero_t4_custom_alloc(size_t n);
void zero_t4_custom_free(void *ptr, size_t n);

#include "src/verify.h"

#define ZERO_T4_BYTES 8u

uint8_t zero_t4_storage[ZERO_T4_BYTES];

size_t zero_t4_free_calls;
uint8_t zero_t4_observed_all_zero;

void *zero_t4_custom_alloc(size_t n)
{
  (void)n;
  return (void *)zero_t4_storage;
}

void zero_t4_custom_free(void *ptr, size_t n)
{
  size_t i;
  uint8_t *bytes = (uint8_t *)ptr;

  zero_t4_free_calls++;
  zero_t4_observed_all_zero = 1u;

  for (i = 0u; i < n; i++)
  {
    if (bytes[i] != 0u)
    {
      zero_t4_observed_all_zero = 0u;
    }
  }
}

void harness(void)
{
  size_t i;
  size_t calls_before_null;

  uint8_t *null_secret = NULL;

  zero_t4_free_calls = 0u;
  zero_t4_observed_all_zero = 0u;

  MLK_ALLOC(secret, uint8_t, ZERO_T4_BYTES, 0);

  for (i = 0u; i < ZERO_T4_BYTES; i++)
  {
    secret[i] = (uint8_t)(i + 1u);
  }

  MLK_FREE(secret, uint8_t, ZERO_T4_BYTES, 0);

  __CPROVER_assert(
      zero_t4_observed_all_zero == 0u,
      "ZERO-T4.FC1: all-zero handoff observation is intentionally denied");

  __CPROVER_assert(
      zero_t4_free_calls == 2u,
      "ZERO-T4.FC2: exactly-once custom free is falsely claimed to run twice");

  __CPROVER_assert(
      secret != NULL,
      "ZERO-T4.FC3: pointer reset is intentionally denied");

  calls_before_null = zero_t4_free_calls;

  MLK_FREE(null_secret, uint8_t, ZERO_T4_BYTES, 0);

  __CPROVER_assert(
      zero_t4_free_calls == calls_before_null + 1u,
      "ZERO-T4.FC4: null input is falsely claimed to invoke custom free");
}
