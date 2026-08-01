#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T2.P1..P4 — exact single-bit routing.
 *
 * The proof chooses:
 *   * an arbitrary 3-byte input block,
 *   * an arbitrary observed output coefficient,
 *   * an arbitrary bit in an 8-bit field,
 *   * an arbitrary bit in a 4-bit nibble.
 *
 * One independently constructed variant is decoded at a time. After each
 * assertion the flipped byte is restored before the next route is tested.
 * Therefore every assertion compares inputs differing in exactly one bit.
 */
void harness(void)
{
  uint8_t base_input[MLKEM_POLYBYTES];
  uint8_t variant_input[MLKEM_POLYBYTES];

  mlk_poly base_output;
  mlk_poly variant_output;

  uint32_t block_index;
  uint32_t coeff_index;
  uint32_t bit8;
  uint32_t bit4;
  uint32_t i;

  uint16_t expected;

  __CPROVER_assume(block_index < (MLKEM_N / 2u));
  __CPROVER_assume(coeff_index < MLKEM_N);
  __CPROVER_assume(bit8 < 8u);
  __CPROVER_assume(bit4 < 4u);

  for (i = 0u; i < MLKEM_POLYBYTES; i++)
  {
    variant_input[i] = base_input[i];
  }

  mlk_poly_frombytes(&base_output, base_input);

  /*
   * PFB-T2.P1:
   * first-byte bit j routes only to even-coefficient bit j.
   */
  variant_input[3u * block_index] =
      (uint8_t)(variant_input[3u * block_index] ^
                (uint8_t)(UINT32_C(1) << bit8));

  mlk_poly_frombytes(&variant_output, variant_input);

  expected = (uint16_t)base_output.coeffs[coeff_index];
  if (coeff_index == 2u * block_index)
  {
    expected =
        (uint16_t)(expected ^ (uint16_t)(UINT32_C(1) << bit8));
  }

  __CPROVER_assert(
      (uint16_t)variant_output.coeffs[coeff_index] == expected,
      "PFB-T2.P1 first-byte bit routes exactly to even bit j");

  variant_input[3u * block_index] =
      (uint8_t)(variant_input[3u * block_index] ^
                (uint8_t)(UINT32_C(1) << bit8));

  /*
   * PFB-T2.P2:
   * second-byte low-nibble bit j routes only to even bit 8+j.
   */
  variant_input[3u * block_index + 1u] =
      (uint8_t)(variant_input[3u * block_index + 1u] ^
                (uint8_t)(UINT32_C(1) << bit4));

  mlk_poly_frombytes(&variant_output, variant_input);

  expected = (uint16_t)base_output.coeffs[coeff_index];
  if (coeff_index == 2u * block_index)
  {
    expected =
        (uint16_t)(expected ^
                   (uint16_t)(UINT32_C(1) << (8u + bit4)));
  }

  __CPROVER_assert(
      (uint16_t)variant_output.coeffs[coeff_index] == expected,
      "PFB-T2.P2 low-nibble bit routes exactly to even bit 8+j");

  variant_input[3u * block_index + 1u] =
      (uint8_t)(variant_input[3u * block_index + 1u] ^
                (uint8_t)(UINT32_C(1) << bit4));

  /*
   * PFB-T2.P3:
   * second-byte high-nibble bit 4+j routes only to odd bit j.
   */
  variant_input[3u * block_index + 1u] =
      (uint8_t)(variant_input[3u * block_index + 1u] ^
                (uint8_t)(UINT32_C(1) << (4u + bit4)));

  mlk_poly_frombytes(&variant_output, variant_input);

  expected = (uint16_t)base_output.coeffs[coeff_index];
  if (coeff_index == 2u * block_index + 1u)
  {
    expected =
        (uint16_t)(expected ^ (uint16_t)(UINT32_C(1) << bit4));
  }

  __CPROVER_assert(
      (uint16_t)variant_output.coeffs[coeff_index] == expected,
      "PFB-T2.P3 high-nibble bit routes exactly to odd bit j");

  variant_input[3u * block_index + 1u] =
      (uint8_t)(variant_input[3u * block_index + 1u] ^
                (uint8_t)(UINT32_C(1) << (4u + bit4)));

  /*
   * PFB-T2.P4:
   * third-byte bit j routes only to odd bit 4+j.
   */
  variant_input[3u * block_index + 2u] =
      (uint8_t)(variant_input[3u * block_index + 2u] ^
                (uint8_t)(UINT32_C(1) << bit8));

  mlk_poly_frombytes(&variant_output, variant_input);

  expected = (uint16_t)base_output.coeffs[coeff_index];
  if (coeff_index == 2u * block_index + 1u)
  {
    expected =
        (uint16_t)(expected ^
                   (uint16_t)(UINT32_C(1) << (4u + bit8)));
  }

  __CPROVER_assert(
      (uint16_t)variant_output.coeffs[coeff_index] == expected,
      "PFB-T2.P4 third-byte bit routes exactly to odd bit 4+j");
}
