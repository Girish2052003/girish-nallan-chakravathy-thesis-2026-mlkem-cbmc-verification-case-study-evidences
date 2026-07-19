#ifndef SUB00R_B6_FAIL_CLOSED_ZEROIZE_H
#define SUB00R_B6_FAIL_CLOSED_ZEROIZE_H

#include <stddef.h>

static void mlk_zeroize(void *ptr, size_t len)
{
  (void)ptr;
  (void)len;
  __CPROVER_assert(
      0,
      "SUB_T6_ADAPTER: mlk_zeroize must be unreachable from this slice");
}

#endif /* SUB00R_B6_FAIL_CLOSED_ZEROIZE_H */
