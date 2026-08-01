#include <stdint.h>

int16_t mlk_barrett_reduce(int16_t a);

void harness(void)
{
  __CPROVER_assert(
      mlk_barrett_reduce(INT16_MIN) == 522,
      "BR-AF4-C1.1 INT16_MIN maps to 522");

  __CPROVER_assert(
      mlk_barrett_reduce(INT16_MAX) == -523,
      "BR-AF4-C1.2 INT16_MAX maps to -523");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)-3329) == 0,
      "BR-AF4-C1.3 negative modulus maps to zero");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)0) == 0,
      "BR-AF4-C1.4 zero maps to zero");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)3329) == 0,
      "BR-AF4-C1.5 positive modulus maps to zero");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)-1665) == 1664,
      "BR-AF4-C1.6 lower outside boundary wraps to 1664");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)-1664) == -1664,
      "BR-AF4-C1.7 lower centered boundary is fixed");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)1664) == 1664,
      "BR-AF4-C1.8 upper centered boundary is fixed");

  __CPROVER_assert(
      mlk_barrett_reduce((int16_t)1665) == -1664,
      "BR-AF4-C1.9 upper outside boundary wraps to -1664");
}
