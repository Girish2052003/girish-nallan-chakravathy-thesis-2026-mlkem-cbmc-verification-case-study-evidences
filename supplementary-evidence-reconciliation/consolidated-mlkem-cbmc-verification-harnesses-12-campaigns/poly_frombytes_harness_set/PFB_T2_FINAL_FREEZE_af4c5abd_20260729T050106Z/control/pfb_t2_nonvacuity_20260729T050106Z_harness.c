#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * Concrete nonvacuity and boundary witnesses for PFB-T2.
 *
 * All input arrays are explicitly initialised. The route witnesses exercise:
 *   P1 at block 0 and bit 0;
 *   P2 at block 127 and low-nibble bit 3;
 *   P3 at block 0 and high-nibble bit 3;
 *   P4 at block 127 and third-byte bit 7.
 *
 * The locality witness changes all three bytes in middle block 64, proves that
 * its selected pair changes, and proves that coefficients directly outside
 * that pair remain unchanged.
 */
void harness(void)
{
  uint8_t zero_input[MLKEM_POLYBYTES];
  uint8_t variant_input[MLKEM_POLYBYTES];
  uint8_t locality_input[MLKEM_POLYBYTES];

  mlk_poly zero_output;
  mlk_poly variant_output;
  mlk_poly locality_output;

  uint32_t i;

  for (i = 0u; i < MLKEM_POLYBYTES; i++)
  {
    zero_input[i] = 0u;
    variant_input[i] = 0u;
    locality_input[i] = 0u;
  }

  mlk_poly_frombytes(&zero_output, zero_input);

  variant_input[0] = 0x01u;
  mlk_poly_frombytes(&variant_output, variant_input);
  __CPROVER_assert(
      (uint16_t)variant_output.coeffs[0] == UINT16_C(1),
      "PFB-T2 control P1 block-0 bit-0 reaches even bit 0");
  variant_input[0] = 0u;

  variant_input[3u * 127u + 1u] = 0x08u;
  mlk_poly_frombytes(&variant_output, variant_input);
  __CPROVER_assert(
      (uint16_t)variant_output.coeffs[254] == UINT16_C(2048),
      "PFB-T2 control P2 block-127 low-bit-3 reaches even bit 11");
  variant_input[3u * 127u + 1u] = 0u;

  variant_input[1] = 0x80u;
  mlk_poly_frombytes(&variant_output, variant_input);
  __CPROVER_assert(
      (uint16_t)variant_output.coeffs[1] == UINT16_C(8),
      "PFB-T2 control P3 block-0 high-bit-3 reaches odd bit 3");
  variant_input[1] = 0u;

  variant_input[3u * 127u + 2u] = 0x80u;
  mlk_poly_frombytes(&variant_output, variant_input);
  __CPROVER_assert(
      (uint16_t)variant_output.coeffs[255] == UINT16_C(2048),
      "PFB-T2 control P4 block-127 bit-7 reaches odd bit 11");

  locality_input[3u * 64u] = 0xA5u;
  locality_input[3u * 64u + 1u] = 0x5Au;
  locality_input[3u * 64u + 2u] = 0xFFu;

  mlk_poly_frombytes(&locality_output, locality_input);

  __CPROVER_assert(
      (locality_output.coeffs[128] != zero_output.coeffs[128]) ||
          (locality_output.coeffs[129] != zero_output.coeffs[129]),
      "PFB-T2 control P5 selected block causes a nonconstant selected pair");

  __CPROVER_assert(
      locality_output.coeffs[127] == zero_output.coeffs[127],
      "PFB-T2 control P5 coefficient before selected pair is unchanged");

  __CPROVER_assert(
      locality_output.coeffs[130] == zero_output.coeffs[130],
      "PFB-T2 control P5 coefficient after selected pair is unchanged");
}
