#include "poly.h"

static int16_t nd16(void)
{
  return (int16_t)__CPROVER_nondet_int();
}

void harness(void)
{
  mlk_poly r_obj;
  mlk_poly b_obj;
  mlk_poly witness_obj;
  mlk_poly witness_before;
  unsigned i;

  for (i = 0; i < MLKEM_N; ++i)
  {
    r_obj.coeffs[i] = nd16();
    b_obj.coeffs[i] = nd16();
    witness_obj.coeffs[i] = nd16();
  }

  /* TRACE_ASSUMPTION:A01 */
  __CPROVER_assume(&witness_obj != &r_obj && &witness_obj != &b_obj);

  witness_before = witness_obj;

  mlk_poly_add(&r_obj, &b_obj); /* TRACE_TARGET_CALL:OPEN_CAND_002 */

  for (i = 0; i < MLKEM_N; ++i)
  {
    /* TRACE_CLAIM:C01 */
    __CPROVER_assert(
      witness_obj.coeffs[i] == witness_before.coeffs[i],
      "disjoint witness object remains unchanged"
    );
  }
}
