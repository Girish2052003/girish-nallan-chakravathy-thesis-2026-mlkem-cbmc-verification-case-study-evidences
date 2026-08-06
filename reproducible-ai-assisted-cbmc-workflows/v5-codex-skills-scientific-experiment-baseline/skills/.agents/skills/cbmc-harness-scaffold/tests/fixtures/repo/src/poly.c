#include "poly.h"

void mlk_poly_sub(mlk_poly *r, const mlk_poly *a, const mlk_poly *b)
{
  int i;
  for (i = 0; i < MLKEM_N; ++i) {
    r->coeffs[i] = a->coeffs[i] - b->coeffs[i];
  }
}
