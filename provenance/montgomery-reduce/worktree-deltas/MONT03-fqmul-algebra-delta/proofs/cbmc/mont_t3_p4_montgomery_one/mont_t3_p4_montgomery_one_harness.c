#include <stdint.h>

#include "../../../mlkem/src/poly.h"

#define MONT_ONE ((int16_t)2285)

extern int16_t nondet_int16_t(void);
int16_t mlk_fqmul(int16_t a, int16_t b);

static int16_t normalize_q_once(int32_t value)
{
  if (value >= MLKEM_Q_HALF)
  {
    value -= MLKEM_Q;
  }

  if (value <= -MLKEM_Q_HALF)
  {
    value += MLKEM_Q;
  }

  return (int16_t)value;
}

void harness(void)
{
  int16_t x;
  int16_t product;
  int16_t normalized;

  x = nondet_int16_t();
  __CPROVER_assume(x > -MLKEM_Q_HALF && x < MLKEM_Q_HALF);

  product = mlk_fqmul(MONT_ONE, x);
  normalized = normalize_q_once((int32_t)product);

  __CPROVER_assert(
      normalized == x,
      "MONT-T3.P4.Montgomery_one_identity_after_normalization");
}
