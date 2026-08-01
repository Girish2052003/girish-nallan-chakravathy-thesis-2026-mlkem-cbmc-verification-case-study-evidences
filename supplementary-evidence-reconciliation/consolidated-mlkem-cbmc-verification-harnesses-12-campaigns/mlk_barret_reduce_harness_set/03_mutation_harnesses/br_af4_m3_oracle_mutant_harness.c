#include <stdint.h>

extern int16_t nondet_int16_t(void);
int16_t mlk_barrett_reduce(int16_t a);

static int32_t br_af4_mutation_oracle(int16_t a)
{
  int32_t u = ((int32_t)a) % 3329;

  if (u < 0)
  {
    u += 3329;
  }

  if (u > 1663)
  {
    u -= 3329;
  }

  return u;
}

void harness(void)
{
  int16_t a = nondet_int16_t();
  int16_t r = mlk_barrett_reduce(a);
  int32_t expected = br_af4_mutation_oracle(a);

  __CPROVER_assert(
      ((int32_t)r == expected),
      "BR-AF4-M3 false-oracle mutation rejected");
}
