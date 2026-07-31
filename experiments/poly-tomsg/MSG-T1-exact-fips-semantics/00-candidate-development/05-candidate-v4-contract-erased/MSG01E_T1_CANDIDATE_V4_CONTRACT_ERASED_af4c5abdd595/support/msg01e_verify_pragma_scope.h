#ifndef MSG01E_VERIFY_PRAGMA_SCOPE_H
#define MSG01E_VERIFY_PRAGMA_SCOPE_H

#ifdef CBMC
#error "MSG-01E requires CBMC to be initially undefined"
#endif

/*
 * Load cbmc.h while CBMC is undefined. This keeps __contract__
 * and __loop__ annotations erased for the direct bounded model.
 */
#include "common.h"
#include "cbmc.h"

/*
 * Enable only the production verification pragmas in verify.h.
 */
#define CBMC 1
#include "verify.h"
#undef CBMC

#endif
