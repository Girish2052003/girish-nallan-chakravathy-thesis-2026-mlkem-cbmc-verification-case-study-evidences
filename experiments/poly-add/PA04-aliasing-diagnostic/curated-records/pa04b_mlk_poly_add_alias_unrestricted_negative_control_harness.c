/*
 * PA-04B: Unrestricted aliasing negative control for mlk_poly_add
 *
 * Scientific purpose:
 *   Show that aliasing does not remove the int16_t representability
 *   boundary. Exact doubling cannot hold for every arbitrary int16_t
 *   coefficient.
 *
 * Expected low-level CBMC result:
 *   VERIFICATION FAILED
 *
 * Expected campaign interpretation:
 *   EXPECTED_ALIAS_COUNTEREXAMPLE_CONFIRMED
 *
 * This remains an out-of-contract implementation diagnostic.
 *
 * Target repository commit:
 * d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

static int16_t pa04b_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly aliased;
  mlk_poly aliased_before;

  mlk_poly *r_alias;
  const mlk_poly *b_alias;

  unsigned i;
  int32_t exact_double;

  __CPROVER_assert(
      MLKEM_N == 256,
      "PA04B_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA04B_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA04B_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA04B_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Completely unrestricted signed int16_t coefficients.
   * No safe-doubling or representability assumption is present.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    aliased.coeffs[i] = pa04b_nondet_int16();
  }

  aliased_before = aliased;

  r_alias = &aliased;
  b_alias = &aliased;

  __CPROVER_assert(
      r_alias == b_alias,
      "PA04B_ALIAS_BINDING: r and b designate the same object");

  mlk_poly_add(r_alias, b_alias);

  for (i = 0; i < MLKEM_N; i++)
  {
    exact_double =
        (int32_t)aliased_before.coeffs[i] * (int32_t)2;

    /*
     * Intentionally false over the unrestricted domain.
     * For example, 16384 doubled is 32768, which is not representable
     * in int16_t.
     */
    __CPROVER_assert(
        (int32_t)aliased.coeffs[i] == exact_double,
        "PA04B_P1_UNRESTRICTED_ALIAS_EXACT_DOUBLING: exact a+a for every int16_t value");
  }

  return 0;
}
