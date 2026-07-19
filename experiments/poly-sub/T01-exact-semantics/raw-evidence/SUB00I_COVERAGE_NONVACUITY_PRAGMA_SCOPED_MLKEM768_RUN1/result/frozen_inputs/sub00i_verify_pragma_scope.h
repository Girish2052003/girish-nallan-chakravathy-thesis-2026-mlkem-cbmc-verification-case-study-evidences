#ifndef SUB00I_VERIFY_PRAGMA_SCOPE_H
#define SUB00I_VERIFY_PRAGMA_SCOPE_H

/*
 * Activate only verify.h's CBMC-specific conversion-check pragma while
 * keeping function contracts and loop contracts disabled.
 *
 * cbmc.h is first included while CBMC is undefined, fixing its normal
 * no-contract macro definitions behind the include guard. CBMC is then
 * defined only while verify.h is parsed and is immediately undefined again.
 */

#ifdef CBMC
#error "SUB-00I requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00I_VERIFY_PRAGMA_SCOPE_H */
