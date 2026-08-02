/* Candidate CBMC function contract — generated for review; not proof. */
#include "poly.h"
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
__CPROVER_requires(__CPROVER_w_ok(r, sizeof(mlk_poly)))
__CPROVER_requires(__CPROVER_r_ok(b, sizeof(mlk_poly)))
__CPROVER_assigns(r->coeffs[0 .. MLKEM_N - 1])
;
