#ifndef SUB00E_MODEL_ONLY_ZEROIZE_H
#define SUB00E_MODEL_ONLY_ZEROIZE_H

/*
 * External SUB-00E model-construction adapter.
 *
 * This file is not part of the frozen mlkem-native source tree.
 * It satisfies the MLK_CONFIG_NO_ASM platform requirement by providing
 * an explicit volatile byte-wise clearing operation.
 *
 * It is not a proof of secure zeroization and is not part of the
 * SUB-T1 or SUB-T2 subtraction theorem.
 */

#define MLK_CONFIG_CUSTOM_ZEROIZE

#include <stddef.h>
#include "src/sys.h"

static MLK_INLINE void mlk_zeroize(void *ptr, size_t len)
{
    volatile unsigned char *p;

    p = (volatile unsigned char *)ptr;

    while (len > 0U)
    {
        *p = 0U;
        p++;
        len--;
    }
}

#endif /* SUB00E_MODEL_ONLY_ZEROIZE_H */
