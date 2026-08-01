#include <stddef.h>
#include <stdint.h>

#include "src/verify.h"

void harness(void)
{
  uint8_t buffer[8] = {
      0x11u, 0x22u, 0xA1u, 0xB2u,
      0xC3u, 0xD4u, 0x77u, 0x88u};

  uint8_t prefix_before = buffer[0];

  mlk_zeroize(&buffer[2], 4u);

  /*
   * Intentionally false: the byte lies outside the selected interval.
   */
  __CPROVER_assert(
      buffer[0] != prefix_before,
      "ZERO-T2.FAIL-CONTROL: untouched prefix is falsely claimed modified");
}
