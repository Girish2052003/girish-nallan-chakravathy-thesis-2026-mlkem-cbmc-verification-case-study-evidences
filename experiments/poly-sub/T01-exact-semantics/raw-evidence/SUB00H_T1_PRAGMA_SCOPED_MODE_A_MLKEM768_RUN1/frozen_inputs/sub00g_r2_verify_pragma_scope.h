#ifndef SUB00G_R2_VERIFY_PRAGMA_SCOPE_H
#define SUB00G_R2_VERIFY_PRAGMA_SCOPE_H

/*
 * Purpose:
 *   Activate only verify.h's CBMC-specific conversion-check pragma while
 *   keeping mlkem-native function contracts and loop contracts disabled.
 *
 * Mechanism:
 *   1. Include common.h and cbmc.h while CBMC is undefined. This selects the
 *      normal no-contract macro definitions and fixes them behind cbmc.h's
 *      include guard.
 *   2. Define CBMC only while verify.h is parsed. At the frozen source commit,
 *      verify.h uses this macro for the push/disable/pop conversion pragma
 *      around mlk_cast_uint16_to_int16.
 *   3. Undefine CBMC before the production translation unit is parsed.
 *
 * This adapter does not replace a function body and does not add a theorem
 * assumption.
 */

#ifdef CBMC
#error "SUB-00G-R2 requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00G_R2_VERIFY_PRAGMA_SCOPE_H */
