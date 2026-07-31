#ifndef MSG02B_COMPRESS_DIRECT_WRAP_SCOPE_H
#define MSG02B_COMPRESS_DIRECT_WRAP_SCOPE_H

#ifdef CBMC
#error "MSG02B direct-wrap scope requires CBMC initially undefined"
#endif

/*
 * Parse the production compression helpers under their intended
 * unsigned-wrap verification scope without replacing any implementation.
 */
#pragma CPROVER check push
#pragma CPROVER check disable "unsigned-overflow"
#include "compress.h"
#pragma CPROVER check pop

#endif
