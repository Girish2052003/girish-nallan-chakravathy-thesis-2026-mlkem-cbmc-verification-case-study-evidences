#include <stdint.h>

extern int16_t nondet_int16_t(void);
int16_t mlk_barrett_reduce(int16_t a);

void harness(void)
{
  int16_t a = nondet_int16_t();
  int16_t b = nondet_int16_t();

  int16_t reduced_a = mlk_barrett_reduce(a);
  int16_t reduced_b = mlk_barrett_reduce(b);
  int16_t reduced_twice = mlk_barrett_reduce(reduced_a);

  int a_is_centered =
      ((int32_t)a >= -1664) &&
      ((int32_t)a <= 1664);

  int32_t difference =
      (int32_t)a - (int32_t)b;

  int same_residue =
      ((difference % 3329) == 0);

  __CPROVER_assert(
      !a_is_centered ||
      (reduced_a == a),
      "BR-AF4-T2.P6 centered fixed point");

  __CPROVER_assert(
      reduced_twice == reduced_a,
      "BR-AF4-T2.P7 idempotence");

  __CPROVER_assert(
      !same_residue ||
      (reduced_a == reduced_b),
      "BR-AF4-T2.P8 residue-class invariance");
}
