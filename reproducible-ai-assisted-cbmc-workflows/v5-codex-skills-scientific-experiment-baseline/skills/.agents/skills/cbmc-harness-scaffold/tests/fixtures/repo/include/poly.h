#ifndef POLY_H
#define POLY_H

#define MLKEM_N 4

typedef struct {
  int coeffs[MLKEM_N];
} mlk_poly;

void mlk_poly_sub(mlk_poly *r, const mlk_poly *a, const mlk_poly *b);

#endif
