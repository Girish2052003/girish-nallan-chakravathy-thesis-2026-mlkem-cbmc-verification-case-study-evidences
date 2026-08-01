/*
 * Human-corrected CBMC harness for thesis run:
 * run_002_mlk_poly_add_human_corrected_cbmc
 *
 * Target: mlk_poly_add
 *
 * Purpose:
 * Check the local in-place coefficient-wise update behaviour of mlk_poly_add
 * under the function preconditions documented in poly.h.
 *
 * Research guardrail:
 * This is a selected local CBMC harness only. It is not a proof of full ML-KEM,
 * full FIPS 203 conformance, or complete mlkem-native correctness.
 */

#include <assert.h>
#include <stdint.h>
#include <limits.h>

#include "poly.h"
#include "params.h"
#include "cbmc.h"
#include "common.h"

extern int16_t nondet_int16_t(void);

void harness_mlk_poly_add(void)
{
  mlk_poly r;
  mlk_poly b;
  int16_t old_r_coeffs[MLKEM_N];

  for (unsigned int i = 0; i < MLKEM_N; i++)
  {
    r.coeffs[i] = nondet_int16_t();
    b.coeffs[i] = nondet_int16_t();

    /*
     * Function precondition from poly.h:
     * the coefficient-wise addition must not overflow int16_t.
     */
    __CPROVER_assume((int32_t)r.coeffs[i] + (int32_t)b.coeffs[i] <= INT16_MAX);
    __CPROVER_assume((int32_t)r.coeffs[i] + (int32_t)b.coeffs[i] >= INT16_MIN);

    old_r_coeffs[i] = r.coeffs[i];
  }

  mlk_poly_add(&r, &b);

  for (unsigned int i = 0; i < MLKEM_N; i++)
  {
    assert(r.coeffs[i] ==
           (int16_t)((int32_t)old_r_coeffs[i] + (int32_t)b.coeffs[i]));
  }
}
