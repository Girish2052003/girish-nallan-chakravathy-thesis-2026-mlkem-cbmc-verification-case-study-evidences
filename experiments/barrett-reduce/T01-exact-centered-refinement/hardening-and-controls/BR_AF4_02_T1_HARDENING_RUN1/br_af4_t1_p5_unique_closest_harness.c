#include <stdint.h>

extern int16_t nondet_int16_t(void);
int16_t mlk_barrett_reduce(int16_t a);

static int32_t br_af4_abs_int16_widened(int16_t x)
{
  int32_t v = (int32_t)x;
  return v < 0 ? -v : v;
}

void harness(void)
{
  int16_t a = nondet_int16_t();
  int16_t y = nondet_int16_t();

  int16_t r = mlk_barrett_reduce(a);

  int32_t difference = (int32_t)a - (int32_t)y;
  int32_t abs_r = br_af4_abs_int16_widened(r);
  int32_t abs_y = br_af4_abs_int16_widened(y);

  int same_residue = ((difference % 3329) == 0);

  /*
   * Whenever y is another int16_t representative of the same residue:
   *
   *   y == r, or |r| is strictly smaller than |y|.
   *
   * This combines minimum absolute value and uniqueness in one obligation.
   */
  __CPROVER_assert(
      !same_residue ||
      (y == r) ||
      (abs_r < abs_y),
      "BR-AF4-T1.P5 unique closest int16 representative");
}
