#include <stdint.h>

#include "src/verify.h"

void harness(void)
{
  uint8_t once[8] = {
      0x11u, 0x22u, 0xA1u, 0xB2u,
      0xC3u, 0xD4u, 0x77u, 0x88u};

  uint8_t twice[8] = {
      0x11u, 0x22u, 0xA1u, 0xB2u,
      0xC3u, 0xD4u, 0x77u, 0x88u};

  mlk_zeroize(&once[2], 4u);

  mlk_zeroize(&twice[2], 4u);
  mlk_zeroize(&twice[2], 4u);

  /*
   * Intentionally false: one and two applications have identical results.
   */
  __CPROVER_assert(
      once[2] != twice[2],
      "ZERO-T3.FAIL-CONTROL: idempotent outcomes are falsely claimed different");
}
