#ifndef ZERO_T4_CUSTOM_CONFIG_H
#define ZERO_T4_CUSTOM_CONFIG_H

/*
 * Import the complete authoritative native CBMC configuration.
 */
#include "mlkem_native_config_cbmc.h"

/*
 * Keep custom allocation mode enabled, but replace the CBMC configuration's
 * generic malloc/free hooks with T4 observational hooks.
 */
#ifndef MLK_CONFIG_CUSTOM_ALLOC_FREE
#define MLK_CONFIG_CUSTOM_ALLOC_FREE
#endif

#ifdef MLK_CUSTOM_ALLOC
#undef MLK_CUSTOM_ALLOC
#endif

#ifdef MLK_CUSTOM_FREE
#undef MLK_CUSTOM_FREE
#endif

#define MLK_CUSTOM_ALLOC(v, T, N) \
  T *v = (T *)zero_t4_custom_alloc(sizeof(T) * (N))

#define MLK_CUSTOM_FREE(v, T, N) \
  zero_t4_custom_free((void *)(v), sizeof(T) * (N))

#endif
