#ifndef SUB00L_VERIFY_PRAGMA_SCOPE_H
#define SUB00L_VERIFY_PRAGMA_SCOPE_H

/*
 * Activate only verify.h's CBMC-specific conversion-check pragma while
 * keeping function contracts and loop contracts disabled.
 */

#ifdef CBMC
#error "SUB-00L requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00L_VERIFY_PRAGMA_SCOPE_H */
