#ifndef MSG01E_FAIL_CLOSED_ZEROIZE_H
#define MSG01E_FAIL_CLOSED_ZEROIZE_H

#include <stddef.h>

static void mlk_zeroize(void *ptr, size_t len)
{
  (void)ptr;
  (void)len;

  __CPROVER_assert(
      0,
      "MSG_T1_ADAPTER: mlk_zeroize must be unreachable");
}

#endif
