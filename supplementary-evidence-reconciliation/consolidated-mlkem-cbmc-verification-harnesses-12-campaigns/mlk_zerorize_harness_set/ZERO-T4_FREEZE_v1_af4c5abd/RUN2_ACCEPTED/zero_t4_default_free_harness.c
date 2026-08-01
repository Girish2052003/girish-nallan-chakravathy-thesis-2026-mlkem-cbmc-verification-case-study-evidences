#include <stddef.h>
#include <stdint.h>

#include "src/verify.h"

#define ZERO_T4_BYTES 8u

uint8_t nondet_uint8_t(void);

void harness(void)
{
  size_t i;

  /*
   * Under zero_t4_default_config.h this expands to:
   *
   *   uint8_t mlk_alloc_secret[8];
   *   uint8_t *secret = mlk_alloc_secret;
   */
  MLK_ALLOC(secret, uint8_t, ZERO_T4_BYTES, 0);

  for (i = 0u; i < ZERO_T4_BYTES; i++)
  {
    secret[i] = nondet_uint8_t();
  }

  /*
   * Explicit non-vacuity witness.
   */
  secret[3] = 0xA5u;

  MLK_FREE(secret, uint8_t, ZERO_T4_BYTES, 0);

  for (i = 0u; i < ZERO_T4_BYTES; i++)
  {
    __CPROVER_assert(
        mlk_alloc_secret[i] == 0u,
        "ZERO-T4.P1: default MLK_FREE zeroizes the full backing allocation");
  }

  __CPROVER_assert(
      secret == NULL,
      "ZERO-T4.P2: default MLK_FREE sets the exposed pointer to NULL");

  __CPROVER_assert(
      mlk_alloc_secret[3] == 0u,
      "ZERO-T4.NV1: default branch wipes an initially nonzero backing byte");
}
