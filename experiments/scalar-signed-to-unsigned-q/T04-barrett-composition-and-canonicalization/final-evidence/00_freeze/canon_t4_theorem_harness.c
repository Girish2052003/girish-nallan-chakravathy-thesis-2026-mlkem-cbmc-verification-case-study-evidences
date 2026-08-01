// CANON-T4 theorem-only clean-room harness.
// Actual-body composition of Barrett reduction and unsigned normalization.

#include <stdbool.h>
#include <stdint.h>

#include "common.h"
#include "params.h"

int16_t mlk_barrett_reduce(int16_t a);
int16_t mlk_scalar_signed_to_unsigned_q(int16_t c);

/*
 * Independent mathematical oracle.
 *
 * This implementation uses int32_t remainder arithmetic and does not copy
 * either production implementation.
 */
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

/*
 * Composition under examination:
 *
 * C(a) = F(B(a))
 *
 * Both calls must bind to their actual production bodies.
 */
static int16_t compose_canon_i16(int16_t value)
{
  const int16_t centered =
      mlk_barrett_reduce(value);

  return mlk_scalar_signed_to_unsigned_q(centered);
}

void harness(void)
{
  /*
   * Unrestricted int16_t input for T4.P1, P2, P3 and P6.
   */
  int16_t a;

  /*
   * Independent periodicity input and direction for T4.P4.
   */
  int16_t periodic_a;
  int32_t k;

  /*
   * Legal F-domain input for T4.P5.
   */
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
   * CANON-T4.P1:
   * Barrett output remains in the legal input domain of F.
   */
  __CPROVER_assert(
      (int32_t)ba > -(int32_t)MLKEM_Q &&
      (int32_t)ba < (int32_t)MLKEM_Q,
      "CANON-T4.P1 Barrett-to-normalizer domain bridge");

  /*
   * CANON-T4.P2:
   * actual-body composition equals the independent canonical oracle.
   */
  __CPROVER_assert(
      ca == oracle_a,
      "CANON-T4.P2 full int16 canonicalization");

  /*
   * CANON-T4.P3:
   * composition preserves the input residue class modulo q.
   */
  __CPROVER_assert(
      ((int32_t)ca - (int32_t)a) %
          (int32_t)MLKEM_Q == 0,
      "CANON-T4.P3 composition modular congruence");

  /*
   * CANON-T4.P4:
   * representable translations by plus or minus q do not change C.
   */
  __CPROVER_assert(
      c_translated == c_periodic,
      "CANON-T4.P4 representable q-periodicity");

  /*
   * CANON-T4.P5:
   * on the original legal F-domain, preliminary Barrett reduction does not
   * change the final unsigned representative.
   */
  __CPROVER_assert(
      cc == fc,
      "CANON-T4.P5 agreement with direct normalization on D");

  /*
   * CANON-T4.P6:
   * the complete composition is idempotent.
   */
  __CPROVER_assert(
      c2 == ca,
      "CANON-T4.P6 composition idempotence");

  /*
   * Supporting range controls.
   * These are not additional semantic T4 registrations.
   */
  __CPROVER_assert(
      (int32_t)ca >= 0 &&
      (int32_t)ca < (int32_t)MLKEM_Q,
      "CANON-CONTROL T4 output range ca");

  __CPROVER_assert(
      (int32_t)c_periodic >= 0 &&
      (int32_t)c_periodic < (int32_t)MLKEM_Q,
      "CANON-CONTROL T4 output range periodic");

  __CPROVER_assert(
      (int32_t)c_translated >= 0 &&
      (int32_t)c_translated < (int32_t)MLKEM_Q,
      "CANON-CONTROL T4 output range translated");

  __CPROVER_assert(
      (int32_t)cc >= 0 &&
      (int32_t)cc < (int32_t)MLKEM_Q,
      "CANON-CONTROL T4 output range domain composition");

  __CPROVER_assert(
      (int32_t)c2 >= 0 &&
      (int32_t)c2 < (int32_t)MLKEM_Q,
      "CANON-CONTROL T4 output range second composition");
}
