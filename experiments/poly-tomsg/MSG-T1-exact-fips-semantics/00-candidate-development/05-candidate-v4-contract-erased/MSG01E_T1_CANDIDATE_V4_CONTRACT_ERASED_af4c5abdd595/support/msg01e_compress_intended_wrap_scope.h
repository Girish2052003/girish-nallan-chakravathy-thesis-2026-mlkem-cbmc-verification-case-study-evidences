#ifndef MSG01E_COMPRESS_INTENDED_WRAP_SCOPE_H
#define MSG01E_COMPRESS_INTENDED_WRAP_SCOPE_H

#ifdef CBMC
#error "MSG-01E compression adapter requires CBMC initially undefined"
#endif

/*
 * cbmc.h has already been loaded with contracts erased.
 *
 * Reload-time CBMC visibility here activates the unchanged production
 * push/disable/pop pragmas around compression helpers. The include guard
 * then prevents later harness and compress.c includes from redefining them.
 */
#define CBMC 1
#include "compress.h"
#undef CBMC

#endif
