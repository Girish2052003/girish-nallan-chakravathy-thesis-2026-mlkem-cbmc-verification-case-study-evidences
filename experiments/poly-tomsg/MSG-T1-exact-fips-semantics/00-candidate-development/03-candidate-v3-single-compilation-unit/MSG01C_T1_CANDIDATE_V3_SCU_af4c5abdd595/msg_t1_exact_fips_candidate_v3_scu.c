/*
 * MSG-T1 candidate V3 — single-compilation-unit verification adapter.
 *
 * The frozen production implementation below is included directly from:
 *
 *   /home/girish/THESIS-2026/mlkem-native_af4c5abd/mlkem/src/compress.c
 *
 * Expected production-source SHA-256:
 *
 *   9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad
 *
 * The production file itself is not modified.
 */

#include "/home/girish/THESIS-2026/mlkem-native_af4c5abd/mlkem/src/compress.c"

/*
 * Independent canonical Compress1 decision oracle:
 *
 *   0 <= u <= 832       -> 0
 *   833 <= u <= 2496    -> 1
 *   2497 <= u <= 3328   -> 0
 */
uint8_t msg_t1_threshold_oracle(int16_t u)
{
  return (uint8_t)((u >= 833) && (u <= 2496));
}

int main(void)
{
  mlk_poly a;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  unsigned k;

  __CPROVER_assert(
      MLKEM_N == 256,
      "MSG_T1_MODEL: polynomial degree must be 256");

  __CPROVER_assert(
      MLKEM_INDCPA_MSGBYTES == 32,
      "MSG_T1_MODEL: message size must be 32 bytes");

  __CPROVER_assert(
      msg_t1_threshold_oracle(832) == 0,
      "MSG_T1_ORACLE: lower-zero boundary");

  __CPROVER_assert(
      msg_t1_threshold_oracle(833) == 1,
      "MSG_T1_ORACLE: lower-one boundary");

  __CPROVER_assert(
      msg_t1_threshold_oracle(2496) == 1,
      "MSG_T1_ORACLE: upper-one boundary");

  __CPROVER_assert(
      msg_t1_threshold_oracle(2497) == 0,
      "MSG_T1_ORACLE: upper-zero boundary");

  for (k = 0u; k < MLKEM_N; k++)
  {
    __CPROVER_assume(a.coeffs[k] >= 0);
    __CPROVER_assume(a.coeffs[k] < MLKEM_Q);
  }

  mlk_poly_tomsg(msg, &a);

  for (k = 0u; k < MLKEM_N; k++)
  {
    uint8_t actual_bit;
    uint8_t expected_bit;

    actual_bit =
        (uint8_t)((msg[k >> 3] >> (k & 7u)) & 1u);

    expected_bit =
        msg_t1_threshold_oracle(a.coeffs[k]);

    __CPROVER_assert(
        actual_bit == expected_bit,
        "MSG_T1_EXACT: every output bit must equal the independent Compress1 oracle");
  }

  return 0;
}
