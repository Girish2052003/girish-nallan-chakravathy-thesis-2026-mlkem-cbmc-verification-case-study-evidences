// CANON-T4 non-vacuity coverage companion.
// This binary deliberately contains no theorem assertions.

#include <stdbool.h>
#include <stdint.h>

#include "common.h"
#include "params.h"

int16_t mlk_barrett_reduce(int16_t a);
int16_t mlk_scalar_signed_to_unsigned_q(int16_t c);

static int16_t canon_q_i32(int32_t value)
{
  int32_t remainder =
      value % (int32_t)MLKEM_Q;

  if (remainder < 0)
  {
    remainder += (int32_t)MLKEM_Q;
  }

  return (int16_t)remainder;
}

static int16_t compose_canon_i16(int16_t value)
{
  const int16_t centered =
      mlk_barrett_reduce(value);

  return mlk_scalar_signed_to_unsigned_q(centered);
}

void harness(void)
{
  int16_t a;
  int16_t periodic_a;
  int32_t k;
  int16_t c;

  __CPROVER_assume(k == -1 || k == 1);

  const int32_t translated32 =
      (int32_t)periodic_a +
      k * (int32_t)MLKEM_Q;

  __CPROVER_assume(
      translated32 >= (int32_t)INT16_MIN);

  __CPROVER_assume(
      translated32 <= (int32_t)INT16_MAX);

  __CPROVER_assume(
      (int32_t)c > -(int32_t)MLKEM_Q);

  __CPROVER_assume(
      (int32_t)c < (int32_t)MLKEM_Q);

  const int16_t ba =
      mlk_barrett_reduce(a);

  const int16_t ca =
      mlk_scalar_signed_to_unsigned_q(ba);

  const int16_t oracle_a =
      canon_q_i32((int32_t)a);

  const int16_t c_periodic =
      compose_canon_i16(periodic_a);

  const int16_t c_translated =
      compose_canon_i16((int16_t)translated32);

  const int16_t cc =
      compose_canon_i16(c);

  const int16_t fc =
      mlk_scalar_signed_to_unsigned_q(c);

  const int16_t c2 =
      compose_canon_i16(ca);

  /*
   * Full int16_t boundary witnesses.
   */
  __CPROVER_cover(
      a == INT16_MIN &&
      ca == oracle_a);

  __CPROVER_cover(
      a == INT16_MAX &&
      ca == oracle_a);

  /*
   * All Barrett output sign classes.
   */
  __CPROVER_cover(
      ba < 0 &&
      ca == oracle_a);

  __CPROVER_cover(
      ba == 0 &&
      ca == oracle_a);

  __CPROVER_cover(
      ba > 0 &&
      ca == oracle_a);

  /*
   * Canonical output boundaries.
   */
  __CPROVER_cover(
      ca == 0 &&
      ca == oracle_a);

  __CPROVER_cover(
      (int32_t)ca ==
          (int32_t)MLKEM_Q - 1 &&
      ca == oracle_a);

  /*
   * Nontrivial modular-congruence witness.
   */
  __CPROVER_cover(
      ca != a &&
      ((int32_t)ca - (int32_t)a) %
          (int32_t)MLKEM_Q == 0);

  /*
   * Both periodicity directions.
   */
  __CPROVER_cover(
      k == -1 &&
      c_translated == c_periodic);

  __CPROVER_cover(
      k == 1 &&
      c_translated == c_periodic);

  /*
   * Agreement on negative, zero and positive D inputs.
   */
  __CPROVER_cover(
      c < 0 &&
      cc == fc);

  __CPROVER_cover(
      c == 0 &&
      cc == fc);

  __CPROVER_cover(
      c > 0 &&
      cc == fc);

  /*
   * Composition-idempotence witness.
   */
  __CPROVER_cover(
      c2 == ca);
}
