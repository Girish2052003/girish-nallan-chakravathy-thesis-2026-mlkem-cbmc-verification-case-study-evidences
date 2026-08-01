#ifndef ZERO_T4_DEFAULT_CONFIG_H
#define ZERO_T4_DEFAULT_CONFIG_H

/*
 * Import all authoritative native CBMC settings first.
 */
#include "mlkem_native_config_cbmc.h"

/*
 * T4 default-branch experiment:
 * remove only the CBMC test configuration's custom allocator selection.
 *
 * This causes common.h to instantiate the repository's unmodified
 * stack-backed MLK_ALLOC and MLK_FREE definitions.
 */
#ifdef MLK_CONFIG_CUSTOM_ALLOC_FREE
#undef MLK_CONFIG_CUSTOM_ALLOC_FREE
#endif

#ifdef MLK_CUSTOM_ALLOC
#undef MLK_CUSTOM_ALLOC
#endif

#ifdef MLK_CUSTOM_FREE
#undef MLK_CUSTOM_FREE
#endif

#endif
