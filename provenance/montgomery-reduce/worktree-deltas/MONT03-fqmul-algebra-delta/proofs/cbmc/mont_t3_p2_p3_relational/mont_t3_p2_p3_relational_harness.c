#include <stdint.h>

#include "../../../mlkem/src/poly.h"

extern int16_t nondet_int16_t(void);
int16_t mlk_fqmul(int16_t a, int16_t b);

void harness(void)
{
  int16_t a_any;
  int16_t a;
  int16_t b;
  int16_t ab;
  int16_t ba;
  int16_t a_zero;
  int16_t zero_b;

  a_any = nondet_int16_t();
  a = nondet_int16_t();
  b = nondet_int16_t();

  __CPROVER_assume(a > -MLKEM_Q_HALF && a < MLKEM_Q_HALF);
  __CPROVER_assume(b > -MLKEM_Q_HALF && b < MLKEM_Q_HALF);

  ab = mlk_fqmul(a, b);
  ba = mlk_fqmul(b, a);
  a_zero = mlk_fqmul(a_any, 0);
  zero_b = mlk_fqmul(0, b);

  __CPROVER_assert(
      ab == ba,
      "MONT-T3.P2.exact_commutativity");

  __CPROVER_assert(
      a_zero == 0,
      "MONT-T3.P3.1.left_zero_annihilation_full_first_operand_domain");

  __CPROVER_assert(
      zero_b == 0,
      "MONT-T3.P3.2.right_zero_annihilation");

  __CPROVER_assert(
      (ab == 0) == ((a == 0) || (b == 0)),
      "MONT-T3.P3.3.zero_product_reflection");
}
