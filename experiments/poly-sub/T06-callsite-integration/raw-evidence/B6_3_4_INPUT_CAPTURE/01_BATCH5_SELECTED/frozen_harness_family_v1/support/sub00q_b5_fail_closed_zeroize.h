#ifndef SUB00Q_B5_FAIL_CLOSED_ZEROIZE_H
#define SUB00Q_B5_FAIL_CLOSED_ZEROIZE_H

#include <stddef.h>

/*
 * Model-construction adapter only. The selected poly_sub path must never call
 * zeroization. Any unexpected reachable call therefore fails closed.
 */
static void mlk_zeroize(void *ptr, size_t len)
{
  (void)ptr;
  (void)len;
  __CPROVER_assert(
      0,
      "SUB_T5_ADAPTER: mlk_zeroize must be unreachable from this harness");
}

#endif /* SUB00Q_B5_FAIL_CLOSED_ZEROIZE_H */
