/*
 * POLYCOMP-D4-T1 relational nibble locality.
 *
 * If two canonical input polynomials agree at one symbolic coefficient k,
 * then the corresponding packed output nibble must be equal.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assume(_Bool condition);
void __CPROVER_assert(_Bool condition, const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly left_input;
  mlk_poly right_input;

  uint8_t left_output[MLKEM_POLYCOMPRESSEDBYTES_D4];
  uint8_t right_output[MLKEM_POLYCOMPRESSEDBYTES_D4];

  unsigned i;
  unsigned k;
  unsigned byte_index;

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(left_input.coeffs[i] >= 0);
    __CPROVER_assume(left_input.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(right_input.coeffs[i] >= 0);
    __CPROVER_assume(right_input.coeffs[i] < MLKEM_Q);
  }

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(
      left_input.coeffs[k] == right_input.coeffs[k]);

  mlk_poly_compress_d4_c(left_output, &left_input);
  mlk_poly_compress_d4_c(right_output, &right_input);

  byte_index = k / 2u;

  if ((k & 1u) == 0u)
  {
    __CPROVER_assert(
        (left_output[byte_index] & (uint8_t)0x0Fu) ==
            (right_output[byte_index] & (uint8_t)0x0Fu),
        "POLYCOMP-D4-T1 locality: equal even coefficient gives equal low nibble");
  }
  else
  {
    __CPROVER_assert(
        (left_output[byte_index] & (uint8_t)0xF0u) ==
            (right_output[byte_index] & (uint8_t)0xF0u),
        "POLYCOMP-D4-T1 locality: equal odd coefficient gives equal high nibble");
  }
#endif
}
