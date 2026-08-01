#include <stdint.h>

#include "poly.h"

#define MONT_R_MOD_Q ((int32_t)2285)

extern mlk_poly nondet_mlk_poly(void);
extern unsigned nondet_unsigned(void);

void mlk_poly_tomont_c(mlk_poly *r);

static int32_t canonical_q(int32_t value)
{
  int32_t residue = value % MLKEM_Q;

  if (residue < 0)
  {
    residue += MLKEM_Q;
  }

  return residue;
}

void harness(void)
{
  mlk_poly state;
  mlk_poly before;
  unsigned k;
  int16_t demontgomery_value;

  state = nondet_mlk_poly();
  before = state;
  k = nondet_unsigned();

  __CPROVER_assume(k < MLKEM_N);

  mlk_poly_tomont_c(&state);

  demontgomery_value =
      mlk_montgomery_reduce((int32_t)state.coeffs[k]);

  __CPROVER_assert(
      canonical_q((int32_t)demontgomery_value) ==
          canonical_q((int32_t)before.coeffs[k]),
      "MONT-T4.P1.de_Montgomery_round_trip");

  __CPROVER_assert(
      (canonical_q((int32_t)state.coeffs[k]) == 0) ==
          (canonical_q((int32_t)before.coeffs[k]) == 0),
      "MONT-T4.P4.zero_support_preservation");

  __CPROVER_assert(
      canonical_q((int32_t)state.coeffs[k]) ==
          canonical_q(
              (int32_t)before.coeffs[k] * MONT_R_MOD_Q),
      "MONT-T4.SUPPORT.forward_representation_congruence");
}
