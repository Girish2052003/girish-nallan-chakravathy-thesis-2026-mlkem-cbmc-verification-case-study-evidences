#include <stdint.h>

int16_t mlk_barrett_reduce(int16_t a);

static int32_t br_af4_formula_quotient(int16_t a)
{
  const int32_t magic = 20159;
  return (magic * (int32_t)a + ((int32_t)1 << 25)) >> 26;
}

void harness(void)
{
  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-31626) == -10 &&
      mlk_barrett_reduce((int16_t)-31626) == (int16_t)1664,
      "BR-AF4-C3.1 transition left -31626 maps to quotient -10");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-31625) == -9 &&
      mlk_barrett_reduce((int16_t)-31625) == (int16_t)-1664,
      "BR-AF4-C3.2 transition right -31625 maps to quotient -9");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-28297) == -9 &&
      mlk_barrett_reduce((int16_t)-28297) == (int16_t)1664,
      "BR-AF4-C3.3 transition left -28297 maps to quotient -9");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-28296) == -8 &&
      mlk_barrett_reduce((int16_t)-28296) == (int16_t)-1664,
      "BR-AF4-C3.4 transition right -28296 maps to quotient -8");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-24968) == -8 &&
      mlk_barrett_reduce((int16_t)-24968) == (int16_t)1664,
      "BR-AF4-C3.5 transition left -24968 maps to quotient -8");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-24967) == -7 &&
      mlk_barrett_reduce((int16_t)-24967) == (int16_t)-1664,
      "BR-AF4-C3.6 transition right -24967 maps to quotient -7");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-21639) == -7 &&
      mlk_barrett_reduce((int16_t)-21639) == (int16_t)1664,
      "BR-AF4-C3.7 transition left -21639 maps to quotient -7");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-21638) == -6 &&
      mlk_barrett_reduce((int16_t)-21638) == (int16_t)-1664,
      "BR-AF4-C3.8 transition right -21638 maps to quotient -6");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-18310) == -6 &&
      mlk_barrett_reduce((int16_t)-18310) == (int16_t)1664,
      "BR-AF4-C3.9 transition left -18310 maps to quotient -6");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-18309) == -5 &&
      mlk_barrett_reduce((int16_t)-18309) == (int16_t)-1664,
      "BR-AF4-C3.10 transition right -18309 maps to quotient -5");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-14981) == -5 &&
      mlk_barrett_reduce((int16_t)-14981) == (int16_t)1664,
      "BR-AF4-C3.11 transition left -14981 maps to quotient -5");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-14980) == -4 &&
      mlk_barrett_reduce((int16_t)-14980) == (int16_t)-1664,
      "BR-AF4-C3.12 transition right -14980 maps to quotient -4");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-11652) == -4 &&
      mlk_barrett_reduce((int16_t)-11652) == (int16_t)1664,
      "BR-AF4-C3.13 transition left -11652 maps to quotient -4");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-11651) == -3 &&
      mlk_barrett_reduce((int16_t)-11651) == (int16_t)-1664,
      "BR-AF4-C3.14 transition right -11651 maps to quotient -3");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-8323) == -3 &&
      mlk_barrett_reduce((int16_t)-8323) == (int16_t)1664,
      "BR-AF4-C3.15 transition left -8323 maps to quotient -3");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-8322) == -2 &&
      mlk_barrett_reduce((int16_t)-8322) == (int16_t)-1664,
      "BR-AF4-C3.16 transition right -8322 maps to quotient -2");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-4994) == -2 &&
      mlk_barrett_reduce((int16_t)-4994) == (int16_t)1664,
      "BR-AF4-C3.17 transition left -4994 maps to quotient -2");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-4993) == -1 &&
      mlk_barrett_reduce((int16_t)-4993) == (int16_t)-1664,
      "BR-AF4-C3.18 transition right -4993 maps to quotient -1");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-1665) == -1 &&
      mlk_barrett_reduce((int16_t)-1665) == (int16_t)1664,
      "BR-AF4-C3.19 transition left -1665 maps to quotient -1");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)-1664) == 0 &&
      mlk_barrett_reduce((int16_t)-1664) == (int16_t)-1664,
      "BR-AF4-C3.20 transition right -1664 maps to quotient 0");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)1664) == 0 &&
      mlk_barrett_reduce((int16_t)1664) == (int16_t)1664,
      "BR-AF4-C3.21 transition left 1664 maps to quotient 0");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)1665) == 1 &&
      mlk_barrett_reduce((int16_t)1665) == (int16_t)-1664,
      "BR-AF4-C3.22 transition right 1665 maps to quotient 1");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)4993) == 1 &&
      mlk_barrett_reduce((int16_t)4993) == (int16_t)1664,
      "BR-AF4-C3.23 transition left 4993 maps to quotient 1");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)4994) == 2 &&
      mlk_barrett_reduce((int16_t)4994) == (int16_t)-1664,
      "BR-AF4-C3.24 transition right 4994 maps to quotient 2");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)8322) == 2 &&
      mlk_barrett_reduce((int16_t)8322) == (int16_t)1664,
      "BR-AF4-C3.25 transition left 8322 maps to quotient 2");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)8323) == 3 &&
      mlk_barrett_reduce((int16_t)8323) == (int16_t)-1664,
      "BR-AF4-C3.26 transition right 8323 maps to quotient 3");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)11651) == 3 &&
      mlk_barrett_reduce((int16_t)11651) == (int16_t)1664,
      "BR-AF4-C3.27 transition left 11651 maps to quotient 3");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)11652) == 4 &&
      mlk_barrett_reduce((int16_t)11652) == (int16_t)-1664,
      "BR-AF4-C3.28 transition right 11652 maps to quotient 4");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)14980) == 4 &&
      mlk_barrett_reduce((int16_t)14980) == (int16_t)1664,
      "BR-AF4-C3.29 transition left 14980 maps to quotient 4");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)14981) == 5 &&
      mlk_barrett_reduce((int16_t)14981) == (int16_t)-1664,
      "BR-AF4-C3.30 transition right 14981 maps to quotient 5");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)18309) == 5 &&
      mlk_barrett_reduce((int16_t)18309) == (int16_t)1664,
      "BR-AF4-C3.31 transition left 18309 maps to quotient 5");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)18310) == 6 &&
      mlk_barrett_reduce((int16_t)18310) == (int16_t)-1664,
      "BR-AF4-C3.32 transition right 18310 maps to quotient 6");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)21638) == 6 &&
      mlk_barrett_reduce((int16_t)21638) == (int16_t)1664,
      "BR-AF4-C3.33 transition left 21638 maps to quotient 6");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)21639) == 7 &&
      mlk_barrett_reduce((int16_t)21639) == (int16_t)-1664,
      "BR-AF4-C3.34 transition right 21639 maps to quotient 7");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)24967) == 7 &&
      mlk_barrett_reduce((int16_t)24967) == (int16_t)1664,
      "BR-AF4-C3.35 transition left 24967 maps to quotient 7");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)24968) == 8 &&
      mlk_barrett_reduce((int16_t)24968) == (int16_t)-1664,
      "BR-AF4-C3.36 transition right 24968 maps to quotient 8");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)28296) == 8 &&
      mlk_barrett_reduce((int16_t)28296) == (int16_t)1664,
      "BR-AF4-C3.37 transition left 28296 maps to quotient 8");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)28297) == 9 &&
      mlk_barrett_reduce((int16_t)28297) == (int16_t)-1664,
      "BR-AF4-C3.38 transition right 28297 maps to quotient 9");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)31625) == 9 &&
      mlk_barrett_reduce((int16_t)31625) == (int16_t)1664,
      "BR-AF4-C3.39 transition left 31625 maps to quotient 9");

  __CPROVER_assert(
      br_af4_formula_quotient((int16_t)31626) == 10 &&
      mlk_barrett_reduce((int16_t)31626) == (int16_t)-1664,
      "BR-AF4-C3.40 transition right 31626 maps to quotient 10");

  __CPROVER_assert(
      br_af4_formula_quotient(INT16_MIN) == -10 &&
      mlk_barrett_reduce(INT16_MIN) == 522,
      "BR-AF4-C3.41 INT16_MIN endpoint cell");

  __CPROVER_assert(
      br_af4_formula_quotient(INT16_MAX) == 10 &&
      mlk_barrett_reduce(INT16_MAX) == -523,
      "BR-AF4-C3.42 INT16_MAX endpoint cell");
}
