/* Candidate CBMC function contract — generated for review; not proof. */
#include "poly.h"
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
__CPROVER_requires(r points to a live writable mlk_poly object with MLKEM_N accessible int16_t coefficients)
__CPROVER_requires(b points to a live readable mlk_poly object with MLKEM_N accessible int16_t coefficients)
__CPROVER_assigns(r->coeffs[0 .. MLKEM_N - 1])
;
