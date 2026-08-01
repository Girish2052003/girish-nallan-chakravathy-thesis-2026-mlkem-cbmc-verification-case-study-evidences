#include <stddef.h>
#include <stdint.h>

#include "src/verify.h"

/*
 * ZERO-00B2 positive body-binding preflight.
 *
 * This is not a theorem harness. It merely confirms that the real
 * mlk_zeroize body can be compiled and that one concrete nonzero
 * buffer reaches the expected all-zero post-state.
 */
void harness(void)
{
  uint8_t buffer[4] = {0xA5u, 0x5Au, 0xFFu, 0x01u};

  mlk_zeroize(buffer, sizeof(buffer));

  __CPROVER_assert(
      buffer[0] == 0u &&
      buffer[1] == 0u &&
      buffer[2] == 0u &&
      buffer[3] == 0u,
      "ZERO-00B2.PASS: real mlk_zeroize body clears four concrete bytes");
}
