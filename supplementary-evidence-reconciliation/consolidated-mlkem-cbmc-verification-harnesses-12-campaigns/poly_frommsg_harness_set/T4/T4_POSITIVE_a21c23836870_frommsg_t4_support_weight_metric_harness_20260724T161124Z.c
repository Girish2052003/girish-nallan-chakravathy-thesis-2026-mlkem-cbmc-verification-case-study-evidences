/*
 * FROMMSG-T4 — Codebook support, weight and metric preservation.
 *
 * This single harness proves all four registered T4 components:
 *
 * T4.1 Coordinate support and XOR preservation.
 * T4.2 Global codebook-weight preservation.
 * T4.3 Global pairwise Hamming-metric preservation.
 * T4.4 Global scaled absolute-distance preservation.
 *
 * Two arbitrary symbolic ML-KEM messages are passed through two
 * real production executions of mlk_poly_frommsg.
 *
 * No target-function implementation logic is reproduced.
 */

#include <stdint.h>

#include "compress.h"

#if (8 * MLKEM_INDCPA_MSGBYTES) != MLKEM_N
#error "FROMMSG-T4 requires the message/codeword coordinate bijection"
#endif

typedef struct
{
  uint8_t bytes[MLKEM_INDCPA_MSGBYTES];
} frommsg_t4_message;

static uint32_t frommsg_t4_popcount_u8(uint8_t value)
{
  return
      (uint32_t)((value >> 0) & 1u) +
      (uint32_t)((value >> 1) & 1u) +
      (uint32_t)((value >> 2) & 1u) +
      (uint32_t)((value >> 3) & 1u) +
      (uint32_t)((value >> 4) & 1u) +
      (uint32_t)((value >> 5) & 1u) +
      (uint32_t)((value >> 6) & 1u) +
      (uint32_t)((value >> 7) & 1u);
}

static uint32_t frommsg_t4_abs_difference(
    int16_t first,
    int16_t second)
{
  int32_t difference;

  difference =
      (int32_t)first -
      (int32_t)second;

  return
      (uint32_t)(
          difference < 0
              ? -difference
              : difference);
}

void harness(void)
{
  frommsg_t4_message message1;
  frommsg_t4_message message2;

  mlk_poly output1;
  mlk_poly output2;

  unsigned coordinate;
  unsigned coordinate_byte;
  unsigned coordinate_bit;

  uint8_t coordinate_bit1;
  uint8_t coordinate_bit2;

  int32_t coordinate_coefficient1;
  int32_t coordinate_coefficient2;

  unsigned i;
  unsigned base;

  uint8_t byte1;
  uint8_t byte2;
  uint8_t byte_xor;

  uint32_t message1_bit_weight;
  uint32_t message2_bit_weight;

  uint32_t output1_nonzero_weight;
  uint32_t output2_nonzero_weight;

  uint32_t input_hamming_distance;
  uint32_t output_hamming_distance;

  uint32_t output_absolute_distance;

  __CPROVER_assume(coordinate < MLKEM_N);

  mlk_poly_frommsg(
      &output1,
      message1.bytes);

  mlk_poly_frommsg(
      &output2,
      message2.bytes);

  coordinate_byte =
      coordinate / 8u;

  coordinate_bit =
      coordinate % 8u;

  coordinate_bit1 =
      (uint8_t)(
          (
            message1.bytes[coordinate_byte] >>
            coordinate_bit
          ) &
          1u);

  coordinate_bit2 =
      (uint8_t)(
          (
            message2.bytes[coordinate_byte] >>
            coordinate_bit
          ) &
          1u);

  coordinate_coefficient1 =
      (int32_t)output1.coeffs[coordinate];

  coordinate_coefficient2 =
      (int32_t)output2.coeffs[coordinate];

  message1_bit_weight = 0u;
  message2_bit_weight = 0u;

  output1_nonzero_weight = 0u;
  output2_nonzero_weight = 0u;

  input_hamming_distance = 0u;
  output_hamming_distance = 0u;

  output_absolute_distance = 0u;

  for (
      i = 0u;
      i < MLKEM_INDCPA_MSGBYTES;
      i++)
  {
    base = 8u * i;

    byte1 = message1.bytes[i];
    byte2 = message2.bytes[i];

    byte_xor =
        (uint8_t)(byte1 ^ byte2);

    message1_bit_weight +=
        frommsg_t4_popcount_u8(byte1);

    message2_bit_weight +=
        frommsg_t4_popcount_u8(byte2);

    input_hamming_distance +=
        frommsg_t4_popcount_u8(byte_xor);

    output1_nonzero_weight +=
        (uint32_t)(
            output1.coeffs[base + 0u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(
            output1.coeffs[base + 1u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(
            output1.coeffs[base + 2u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(
            output1.coeffs[base + 3u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(
            output1.coeffs[base + 4u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(
            output1.coeffs[base + 5u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(
            output1.coeffs[base + 6u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(
            output1.coeffs[base + 7u] != 0);

    output2_nonzero_weight +=
        (uint32_t)(
            output2.coeffs[base + 0u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(
            output2.coeffs[base + 1u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(
            output2.coeffs[base + 2u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(
            output2.coeffs[base + 3u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(
            output2.coeffs[base + 4u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(
            output2.coeffs[base + 5u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(
            output2.coeffs[base + 6u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(
            output2.coeffs[base + 7u] != 0);

    output_hamming_distance +=
        (uint32_t)(
            output1.coeffs[base + 0u] !=
            output2.coeffs[base + 0u]);
    output_hamming_distance +=
        (uint32_t)(
            output1.coeffs[base + 1u] !=
            output2.coeffs[base + 1u]);
    output_hamming_distance +=
        (uint32_t)(
            output1.coeffs[base + 2u] !=
            output2.coeffs[base + 2u]);
    output_hamming_distance +=
        (uint32_t)(
            output1.coeffs[base + 3u] !=
            output2.coeffs[base + 3u]);
    output_hamming_distance +=
        (uint32_t)(
            output1.coeffs[base + 4u] !=
            output2.coeffs[base + 4u]);
    output_hamming_distance +=
        (uint32_t)(
            output1.coeffs[base + 5u] !=
            output2.coeffs[base + 5u]);
    output_hamming_distance +=
        (uint32_t)(
            output1.coeffs[base + 6u] !=
            output2.coeffs[base + 6u]);
    output_hamming_distance +=
        (uint32_t)(
            output1.coeffs[base + 7u] !=
            output2.coeffs[base + 7u]);

    output_absolute_distance +=
        frommsg_t4_abs_difference(
            output1.coeffs[base + 0u],
            output2.coeffs[base + 0u]);
    output_absolute_distance +=
        frommsg_t4_abs_difference(
            output1.coeffs[base + 1u],
            output2.coeffs[base + 1u]);
    output_absolute_distance +=
        frommsg_t4_abs_difference(
            output1.coeffs[base + 2u],
            output2.coeffs[base + 2u]);
    output_absolute_distance +=
        frommsg_t4_abs_difference(
            output1.coeffs[base + 3u],
            output2.coeffs[base + 3u]);
    output_absolute_distance +=
        frommsg_t4_abs_difference(
            output1.coeffs[base + 4u],
            output2.coeffs[base + 4u]);
    output_absolute_distance +=
        frommsg_t4_abs_difference(
            output1.coeffs[base + 5u],
            output2.coeffs[base + 5u]);
    output_absolute_distance +=
        frommsg_t4_abs_difference(
            output1.coeffs[base + 6u],
            output2.coeffs[base + 6u]);
    output_absolute_distance +=
        frommsg_t4_abs_difference(
            output1.coeffs[base + 7u],
            output2.coeffs[base + 7u]);
  }

  /*
   * T4.1
   *
   * At every arbitrary coordinate, the exact coefficient pair
   * agrees with the two corresponding message bits, and coefficient
   * inequality is equivalent to XOR of those bits.
   */
  __CPROVER_assert(
      coordinate_coefficient1 ==
          (
            coordinate_bit1 == 1u
                ? (int32_t)MLKEM_Q_HALF
                : 0
          ) &&
      coordinate_coefficient2 ==
          (
            coordinate_bit2 == 1u
                ? (int32_t)MLKEM_Q_HALF
                : 0
          ) &&
      (
        coordinate_coefficient1 !=
        coordinate_coefficient2
      ) ==
      (
        coordinate_bit1 !=
        coordinate_bit2
      ),
      "FROMMSG_T4_P1_COORDINATE_SUPPORT_PRESERVATION");

  /*
   * T4.2
   *
   * For both arbitrary messages, the number of nonzero codeword
   * coefficients is exactly the popcount of the 256 message bits.
   */
  __CPROVER_assert(
      output1_nonzero_weight ==
          message1_bit_weight &&
      output2_nonzero_weight ==
          message2_bit_weight,
      "FROMMSG_T4_P2_GLOBAL_CODEBOOK_WEIGHT_PRESERVATION");

  /*
   * T4.3
   *
   * The number of differing codeword coefficients is exactly the
   * Hamming distance between the two complete input messages.
   */
  __CPROVER_assert(
      output_hamming_distance ==
          input_hamming_distance,
      "FROMMSG_T4_P3_GLOBAL_HAMMING_METRIC_PRESERVATION");

  /*
   * T4.4
   *
   * The coefficient-space L1 distance equals MLKEM_Q_HALF times
   * the input-message Hamming distance.
   */
  __CPROVER_assert(
      output_absolute_distance ==
          (
            (uint32_t)MLKEM_Q_HALF *
            input_hamming_distance
          ),
      "FROMMSG_T4_P4_GLOBAL_SCALED_DISTANCE_PRESERVATION");
}
