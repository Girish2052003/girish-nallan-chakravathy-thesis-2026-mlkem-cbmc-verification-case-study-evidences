#include <stdint.h>

/*
 * CBMC models the return value of this bodyless nondeterministic function
 * symbolically. Therefore a ranges over every int16_t value.
 */
extern int16_t nondet_int16_t(void);

/*
 * The real body is supplied from the frozen mlkem/src/poly.c.
 * The build exposes the file-local function in the same manner as the
 * repository's native CBMC proof infrastructure.
 */
int16_t mlk_barrett_reduce(int16_t a);

/*
 * Independent mathematical oracle.
 *
 * It deliberately does not use the production magic constant, rounding
 * offset, shift width, or Barrett multiplication formula.
 */
int32_t br_af4_centered_oracle(int16_t a)
{
  int32_t u = ((int32_t)a) % 3329;

  if (u < 0)
  {
    u += 3329;
  }

  if (u > 1664)
  {
    u -= 3329;
  }

  return u;
}

void harness(void)
{
  int16_t a = nondet_int16_t();
  int16_t r = mlk_barrett_reduce(a);
  int32_t expected = br_af4_centered_oracle(a);

  __CPROVER_assert(
      ((int32_t)r >= -1664) && ((int32_t)r <= 1664),
      "BR-AF4-T1.P2 centered output range");

  __CPROVER_assert(
      (((int32_t)a - (int32_t)r) % 3329) == 0,
      "BR-AF4-T1.P3 congruence modulo 3329");

  __CPROVER_assert(
      ((int32_t)r == expected),
      "BR-AF4-T1.P4 independent centered-oracle equivalence");
}
