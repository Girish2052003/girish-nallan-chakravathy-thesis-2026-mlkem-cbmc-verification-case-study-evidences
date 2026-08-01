#include <stddef.h>
#include <stdint.h>

#include "compress.h"

typedef struct
{
  uint32_t before;
  mlk_poly value;
  uint32_t after;
} pfb_guarded_poly;

void harness(void)
{
  uint8_t input[MLKEM_POLYBYTES];
  size_t byte_index;
  size_t coeff_index;
  uint8_t saved_input_byte;

  pfb_guarded_poly first;
  pfb_guarded_poly second;

  uint8_t zero_input[MLKEM_POLYBYTES] = {0};
  uint8_t one_input[MLKEM_POLYBYTES] = {0};
  mlk_poly zero_output;
  mlk_poly one_output;

  __CPROVER_assume(byte_index < MLKEM_POLYBYTES);
  __CPROVER_assume(coeff_index < MLKEM_N);

  saved_input_byte = input[byte_index];

  first.before = UINT32_C(0x13579BDF);
  first.after = UINT32_C(0x2468ACE0);
  second.before = UINT32_C(0x89ABCDEF);
  second.after = UINT32_C(0x10203040);

  one_input[0] = UINT8_C(1);

  mlk_poly_frombytes(&first.value, input);
  mlk_poly_frombytes(&second.value, input);
  mlk_poly_frombytes(&zero_output, zero_input);
  mlk_poly_frombytes(&one_output, one_input);

  __CPROVER_assert(
      input[byte_index] == saved_input_byte,
      "PFB-C1 arbitrary selected input byte is preserved");

  __CPROVER_assert(
      first.before == UINT32_C(0x13579BDF) &&
          first.after == UINT32_C(0x2468ACE0),
      "PFB-C2 first output canaries are preserved");

  __CPROVER_assert(
      second.before == UINT32_C(0x89ABCDEF) &&
          second.after == UINT32_C(0x10203040),
      "PFB-C3 second output canaries are preserved");

  __CPROVER_assert(
      first.value.coeffs[coeff_index] ==
          second.value.coeffs[coeff_index],
      "PFB-C4 complete overwrite and deterministic selected coefficient");

  __CPROVER_assert(
      zero_output.coeffs[0] == 0,
      "PFB-C5 zero-input concrete output witness");

  __CPROVER_assert(
      one_output.coeffs[0] == 1,
      "PFB-C6 one-input concrete output witness");

  __CPROVER_assert(
      one_output.coeffs[0] != zero_output.coeffs[0],
      "PFB-C7 nonconstant-output witness");
}
