#include "poly.h"

void harness(void)
{
  mlk_poly r;
  mlk_poly b;
  mlk_poly b_before;
  unsigned i;

  __CPROVER_havoc_object(&r);
  __CPROVER_havoc_object(&b);
  b_before = b;

  /* TRACE_ASSUMPTION:A01: distinct local mlk_poly objects are used, with a pre-call snapshot of the source object, and no NULL or fresh-pointer model is introduced. */
  /* TRACE_CALL:MLK_POLY_ADD */ mlk_poly_add(&r, &b);

  for (i = 0; i < MLKEM_N; ++i)
  {
    /* TRACE_CLAIM:C01: source polynomial coefficients remain unchanged in this local-object frame check. */
    __CPROVER_assert(b.coeffs[i] == b_before.coeffs[i], "TRACE_CLAIM:C01");
  }
}
