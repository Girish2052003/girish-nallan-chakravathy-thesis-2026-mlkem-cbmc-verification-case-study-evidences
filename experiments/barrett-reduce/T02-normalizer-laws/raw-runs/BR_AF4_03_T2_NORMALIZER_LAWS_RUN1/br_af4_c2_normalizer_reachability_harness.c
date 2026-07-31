#include <stdint.h>

int16_t mlk_barrett_reduce(int16_t a);

void harness(void)
{
  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)-1664) == -1664,
      "BR-AF4-C2.1 lower centered fixed-point witness");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)1664) == 1664,
      "BR-AF4-C2.2 upper centered fixed-point witness");

  __CPROVER_assert(
      mlk_barrett_reduce(
          mlk_barrett_reduce(INT16_MIN)) ==
      mlk_barrett_reduce(INT16_MIN),
      "BR-AF4-C2.3 INT16_MIN idempotence witness");

  __CPROVER_assert(
      mlk_barrett_reduce(
          mlk_barrett_reduce(INT16_MAX)) ==
      mlk_barrett_reduce(INT16_MAX),
      "BR-AF4-C2.4 INT16_MAX idempotence witness");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)0) ==
      mlk_barrett_reduce((int16_t)3329),
      "BR-AF4-C2.5 residue pair 0 and 3329");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)-3329) ==
      mlk_barrett_reduce((int16_t)0),
      "BR-AF4-C2.6 residue pair -3329 and 0");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)1665) ==
      mlk_barrett_reduce((int16_t)-1664),
      "BR-AF4-C2.7 residue pair 1665 and -1664");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)-1665) ==
      mlk_barrett_reduce((int16_t)1664),
      "BR-AF4-C2.8 residue pair -1665 and 1664");
}
