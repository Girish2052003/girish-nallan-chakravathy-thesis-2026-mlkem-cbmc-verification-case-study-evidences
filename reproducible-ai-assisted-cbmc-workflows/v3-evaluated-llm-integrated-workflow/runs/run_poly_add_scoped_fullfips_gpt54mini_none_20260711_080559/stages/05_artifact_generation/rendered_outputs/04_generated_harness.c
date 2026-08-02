#include <stdint.h>
#include <stddef.h>
#include "cbmc.h"
#include "common.h"
#include "params.h"
#include "poly.h"

void harness(void)
{
  mlk_poly *r;
  mlk_poly *b;
  mlk_poly r_obj;
  mlk_poly b_obj;
  int16_t pre_r[MLKEM_N];
  unsigned i;

  r = &r_obj;
  b = &b_obj;

  __CPROVER_assume(r != b);

  for (i = 0; i < MLKEM_N; ++i)
  {
    r->coeffs[i] = (int16_t)__CPROVER_nondet_int();
    b->coeffs[i] = (int16_t)__CPROVER_nondet_int();
    pre_r[i] = r->coeffs[i];
  }

  mlk_poly_add(r, b);

  for (i = 0; i < MLKEM_N; ++i)
  {
    __CPROVER_assert(i < MLKEM_N, "coefficient index within bounds");
    __CPROVER_assert(r->coeffs[i] == (int16_t)(pre_r[i] + b->coeffs[i]),
                     "post-state coefficient relation");
  }
}
