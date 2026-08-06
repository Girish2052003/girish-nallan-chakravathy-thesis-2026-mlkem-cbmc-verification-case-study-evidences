#include "poly.h"

void use_sub(poly *out, const poly *left, const poly *right)
{
    mlk_poly_sub(out, left, right);
}
