#ifndef SUB00Q_B5_VERIFY_PRAGMA_SCOPE_H
#define SUB00Q_B5_VERIFY_PRAGMA_SCOPE_H

/*
 * Activate verify.h's CBMC-specific conversion-check pragma while leaving
 * mlkem-native function contracts and loop contracts disabled. This is the
 * same pragma-scoped mechanism accepted in the authoritative Batch-4 parent.
 */

#ifdef CBMC
#error "SUB00Q B5 requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00Q_B5_VERIFY_PRAGMA_SCOPE_H */
