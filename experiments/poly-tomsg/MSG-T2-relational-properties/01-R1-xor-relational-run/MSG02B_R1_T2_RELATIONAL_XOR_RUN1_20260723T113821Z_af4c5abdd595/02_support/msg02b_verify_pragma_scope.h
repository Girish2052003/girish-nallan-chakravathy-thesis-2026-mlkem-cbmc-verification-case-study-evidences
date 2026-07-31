#ifndef MSG02B_VERIFY_PRAGMA_SCOPE_H
#define MSG02B_VERIFY_PRAGMA_SCOPE_H

#ifdef CBMC
#error "MSG02B requires CBMC to be initially undefined"
#endif

/*
 * Load contract and loop-annotation macros while CBMC is undefined.
 * The production contracts and loop contracts therefore remain erased.
 */
#include "common.h"
#include "cbmc.h"

/*
 * Retain the portable verification utilities and their intended pragmas.
 */
#define CBMC 1
#include "verify.h"
#undef CBMC

#endif
