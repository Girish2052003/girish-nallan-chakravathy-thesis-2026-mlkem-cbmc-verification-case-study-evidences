#include <stdint.h>
#include <limits.h>
#include <string.h>
#include "cbmc.h"
#include "params.h"
#include "poly.h"

void harness_mlk_poly_add_int16_safe_sum(void)
{
  mlk_poly *r = 0;
  mlk_poly *b = 0;

  __CPROVER_assume(memory_no_alias(r, sizeof(mlk_poly)));
  __CPROVER_assume(memory_no_alias(b, sizeof(mlk_poly)));

  for(uint32_t k = 0; k < MLKEM_N; ++k)
  {
    __CPROVER_assume(((int32_t)r->coeffs[k] + (int32_t)b->coeffs[k]) <= INT16_MAX);
    __CPROVER_assume(((int32_t)r->coeffs[k] + (int32_t)b->coeffs[k]) >= INT16_MIN);
  }

  mlk_poly old_r;
  memcpy(&old_r, r, sizeof(mlk_poly));

  mlk_poly_add(r, b);

  for(uint32_t k = 0; k < MLKEM_N; ++k)
  {
    int32_t expected = (int32_t)old_r.coeffs[k] + (int32_t)b->coeffs[k];
    __CPROVER_assert(r->coeffs[k] == (int16_t)expected,
                     "mlk_poly_add stores the exact coefficient-wise sum under int16-safe preconditions");
    __CPROVER_assert((int32_t)r->coeffs[k] == expected,
                     "mlk_poly_add cast preserves the mathematical sum when the sum is within INT16 range");
  }
}
