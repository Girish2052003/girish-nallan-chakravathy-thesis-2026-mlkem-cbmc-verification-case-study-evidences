#include <stddef.h>
#include <stdint.h>

#include "src/verify.h"

/*
 * ZERO-00B2 intentional expected-failure control.
 *
 * The assertion deliberately claims that a wiped byte keeps its
 * previous nonzero value. CBMC must reject this assertion.
 */
void harness(void)
{
  uint8_t buffer[4] = {0xA5u, 0x5Au, 0xFFu, 0x01u};

  mlk_zeroize(buffer, sizeof(buffer));

  __CPROVER_assert(
      buffer[0] == 0xA5u,
      "ZERO-00B2.FAIL-CONTROL: intentionally false retained-byte claim");
}
