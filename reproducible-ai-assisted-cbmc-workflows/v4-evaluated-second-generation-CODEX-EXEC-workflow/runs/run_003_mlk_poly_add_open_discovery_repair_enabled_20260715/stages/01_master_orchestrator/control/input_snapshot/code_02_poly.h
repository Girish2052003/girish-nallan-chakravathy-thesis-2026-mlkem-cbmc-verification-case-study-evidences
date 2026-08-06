#ifndef MLK_POLY_ADD_EXPERIMENT_POLY_H
#define MLK_POLY_ADD_EXPERIMENT_POLY_H

#include <stdint.h>

#include "params.h"

/*
 * Polynomial representation preserved from the selected mlkem-native source.
 */
typedef struct
{
  int16_t coeffs[MLKEM_N];
} mlk_poly;

/*
 * Existing formal contracts are intentionally excluded from this
 * LLM-visible experiment snapshot.
 */
void mlk_poly_add(mlk_poly *r, const mlk_poly *b);

#endif
