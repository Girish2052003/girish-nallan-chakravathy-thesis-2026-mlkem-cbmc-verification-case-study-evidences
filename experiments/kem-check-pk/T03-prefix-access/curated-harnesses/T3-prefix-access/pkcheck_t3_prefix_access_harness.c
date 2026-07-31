#include <cbmc.h>
#include <stdint.h>

#include "kem.h"
#include "params.h"

void harness(void)
{
  /*
   * This object ends exactly at MLKEM_POLYVECBYTES.
   *
   * Therefore any access by mlk_kem_check_pk to the public-seed suffix
   * would be reported by CBMC as an out-of-bounds memory access.
   */
  uint8_t public_key_prefix[MLKEM_POLYVECBYTES];

  int result =
    mlk_kem_check_pk(
      public_key_prefix,
      NULL);

  __CPROVER_assert(
    result == 0 ||
    result == MLK_ERR_FAIL ||
    result == MLK_ERR_OUT_OF_MEMORY,
    "PKCHECK-T3.RESULT_DOMAIN: the result is success, rejection, or allocation failure");

  __CPROVER_cover(
    result != MLK_ERR_OUT_OF_MEMORY);
}
