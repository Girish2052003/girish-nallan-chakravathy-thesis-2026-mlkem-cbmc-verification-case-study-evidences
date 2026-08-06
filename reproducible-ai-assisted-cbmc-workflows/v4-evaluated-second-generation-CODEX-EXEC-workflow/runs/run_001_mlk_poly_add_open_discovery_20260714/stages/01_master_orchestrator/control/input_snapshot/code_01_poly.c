#include "poly.h"

/*
 * Implementation semantics preserved from mlkem-native commit
 * d9613cf60de3132d32475c102d8c2781d84feb34.
 *
 * Existing target-specific function contracts, loop contracts, proof
 * harnesses, and comments disclosing formal assumptions are intentionally
 * excluded from the LLM-visible experiment snapshot.
 */
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] = (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }
}
