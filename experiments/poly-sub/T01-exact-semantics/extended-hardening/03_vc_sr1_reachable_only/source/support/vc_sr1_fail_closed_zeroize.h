#ifndef SUB00E_R1_FAIL_CLOSED_ZEROIZE_H
#define SUB00E_R1_FAIL_CLOSED_ZEROIZE_H

/*
 * Model-construction adapter only.
 *
 * mlkem-native requires an application-supplied zeroization hook when
 * MLK_CONFIG_NO_ASM disables its inline-assembly implementation.
 *
 * The selected poly_sub/poly_reduce call paths must never call zeroization.
 * This deliberately fail-closed body ensures that any unexpected reachable
 * call is reported as a verification failure instead of being hidden by a
 * permissive no-op model.
 */

#include <stddef.h>

static void mlk_zeroize(void *ptr, size_t len)
{
  (void)ptr;
  (void)len;

  __CPROVER_assert(
      0,
      "SUB00E_R1_ADAPTER: mlk_zeroize must be unreachable from the selected harness");
}

#endif /* SUB00E_R1_FAIL_CLOSED_ZEROIZE_H */
