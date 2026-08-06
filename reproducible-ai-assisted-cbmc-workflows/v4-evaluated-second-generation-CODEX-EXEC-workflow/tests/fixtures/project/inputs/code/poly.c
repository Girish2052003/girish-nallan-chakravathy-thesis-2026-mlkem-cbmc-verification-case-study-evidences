#include "poly.h"
void mlk_poly_add(int16_t r[256], const int16_t a[256], const int16_t b[256]) {
  for (int i = 0; i < 256; ++i) r[i] = a[i] + b[i];
}
