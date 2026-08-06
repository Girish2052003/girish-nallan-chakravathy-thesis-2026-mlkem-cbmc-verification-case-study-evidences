#include "poly.h"

#define LOCAL_ADJUSTMENT 0

void helper_touch(poly *r)
{
    r->coeffs[0] = r->coeffs[0] + LOCAL_ADJUSTMENT;
}

void mlk_poly_sub(poly *r, const poly *a, const poly *b)
{
    unsigned i;
    for (i = 0; i < MLKEM_N; i++) {
        r->coeffs[i] = a->coeffs[i] - b->coeffs[i];
    }
    helper_touch(r);
}
