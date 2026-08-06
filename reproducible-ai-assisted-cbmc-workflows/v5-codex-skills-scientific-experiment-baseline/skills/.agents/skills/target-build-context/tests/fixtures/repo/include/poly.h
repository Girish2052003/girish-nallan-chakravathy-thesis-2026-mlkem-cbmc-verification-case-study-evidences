#ifndef FIXTURE_POLY_H
#define FIXTURE_POLY_H

#define MLKEM_N 4

typedef struct {
    int coeffs[MLKEM_N];
} poly;

void mlk_poly_sub(poly *r, const poly *a, const poly *b);
void helper_touch(poly *r);

#endif
