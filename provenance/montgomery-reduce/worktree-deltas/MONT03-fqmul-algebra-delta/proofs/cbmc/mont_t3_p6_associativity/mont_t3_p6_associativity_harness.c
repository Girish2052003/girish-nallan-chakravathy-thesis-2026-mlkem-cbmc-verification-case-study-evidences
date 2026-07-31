#include <stdint.h>

#include "../../../mlkem/src/poly.h"

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
  int16_t a;
  int16_t b;
  int16_t c;
  int16_t ab;
  int16_t bc;
  int16_t bc_normalized;
  int16_t left_raw;
  int16_t right_raw;
  int16_t left_normalized;
  int16_t right_normalized;

  a = nondet_int16_t();
  b = nondet_int16_t();
  c = nondet_int16_t();

  __CPROVER_assume(a > -MLKEM_Q_HALF && a < MLKEM_Q_HALF);
  __CPROVER_assume(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF);
  __CPROVER_assume(c > -MLKEM_Q_HALF && c < MLKEM_Q_HALF);

  ab = mlk_fqmul(a, b);
  left_raw = mlk_fqmul(ab, c);

  bc = mlk_fqmul(b, c);
  bc_normalized = normalize_q_once((int32_t)bc);
  right_raw = mlk_fqmul(a, bc_normalized);

  left_normalized = normalize_q_once((int32_t)left_raw);
  right_normalized = normalize_q_once((int32_t)right_raw);

  __CPROVER_assert(
      left_normalized == right_normalized,
      "MONT-T3.P6.associativity_after_normalization");
}
