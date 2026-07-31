#ifndef MSG01F_VERIFY_PRAGMA_SCOPE_H
#define MSG01F_VERIFY_PRAGMA_SCOPE_H

#ifdef CBMC
#error "MSG-01F requires CBMC to be initially undefined"
#endif

/*
 * Load annotations with CBMC undefined.
 * Production contracts and loop contracts remain erased.
 */
#include "common.h"
#include "cbmc.h"

/*
 * Retain verification pragmas and portable verification utilities.
 * CBMC is undefined again before compress.h is parsed.
 */
#define CBMC 1
#include "verify.h"
#undef CBMC

#endif
