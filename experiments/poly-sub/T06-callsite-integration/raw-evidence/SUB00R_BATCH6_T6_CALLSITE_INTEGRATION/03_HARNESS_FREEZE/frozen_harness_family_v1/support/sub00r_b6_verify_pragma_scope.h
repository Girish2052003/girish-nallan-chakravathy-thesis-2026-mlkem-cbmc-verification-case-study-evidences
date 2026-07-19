#ifndef SUB00R_B6_VERIFY_PRAGMA_SCOPE_H
#define SUB00R_B6_VERIFY_PRAGMA_SCOPE_H

#ifdef CBMC
#error "SUB00R B6 requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00R_B6_VERIFY_PRAGMA_SCOPE_H */
