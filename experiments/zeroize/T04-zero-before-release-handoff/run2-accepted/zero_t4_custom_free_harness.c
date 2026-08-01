#include <stddef.h>
#include <stdint.h>

/*
 * These declarations must appear before verify.h imports the custom
 * configuration wrapper whose macros refer to these functions.
 */
void *zero_t4_custom_alloc(size_t n);
void zero_t4_custom_free(void *ptr, size_t n);

#include "src/verify.h"

#define ZERO_T4_BYTES 8u

uint8_t nondet_uint8_t(void);

uint8_t zero_t4_storage[ZERO_T4_BYTES];

size_t zero_t4_free_calls;
size_t zero_t4_observed_size;
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
  zero_t4_observed_size = n;
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
  zero_t4_observed_size = 0u;
  zero_t4_observed_all_zero = 0u;

  MLK_ALLOC(secret, uint8_t, ZERO_T4_BYTES, 0);

  __CPROVER_assert(
      secret == zero_t4_storage,
      "ZERO-T4.NV2: custom allocation returns the observational backing object");

  for (i = 0u; i < ZERO_T4_BYTES; i++)
  {
    secret[i] = nondet_uint8_t();
  }

  /*
   * Explicit non-vacuity witness.
   */
  secret[3] = 0xA5u;

  MLK_FREE(secret, uint8_t, ZERO_T4_BYTES, 0);

  __CPROVER_assert(
      zero_t4_observed_all_zero == 1u,
      "ZERO-T4.P3: custom free hook observes an all-zero allocation");

  __CPROVER_assert(
      zero_t4_free_calls == 1u,
      "ZERO-T4.P4: custom free hook executes exactly once for non-null memory");

  __CPROVER_assert(
      zero_t4_observed_size == ZERO_T4_BYTES,
      "ZERO-T4.NV3: custom free hook receives the complete allocation size");

  __CPROVER_assert(
      secret == NULL,
      "ZERO-T4.NV4: custom MLK_FREE resets the exposed pointer");

  calls_before_null = zero_t4_free_calls;

  MLK_FREE(null_secret, uint8_t, ZERO_T4_BYTES, 0);

  __CPROVER_assert(
      zero_t4_free_calls == calls_before_null,
      "ZERO-T4.P5: custom free hook is not called for a null pointer");

  __CPROVER_assert(
      null_secret == NULL,
      "ZERO-T4.NV5: null input remains null");
}
