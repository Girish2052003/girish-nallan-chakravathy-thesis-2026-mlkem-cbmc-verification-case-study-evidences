/*
 * FROMMSG-T4 integrated integrity companion.
 *
 * One harness and one GOTO binary contain:
 *
 *   10 reachability/non-vacuity witnesses;
 *    6 deliberately false semantic mutations.
 *
 * All calculations cover the complete 256-bit message and the
 * complete 256-coefficient frommsg codeword.
 */

#include <stdint.h>

#include "compress.h"

#if (8 * MLKEM_INDCPA_MSGBYTES) != MLKEM_N
#error "FROMMSG-T4 requires 256 message/codeword coordinates"
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
  unsigned mode;

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
  __CPROVER_assume(mode < 16u);

  mlk_poly_frommsg(&output1, message1.bytes);
  mlk_poly_frommsg(&output2, message2.bytes);

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
        (uint32_t)(output1.coeffs[base + 0u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(output1.coeffs[base + 1u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(output1.coeffs[base + 2u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(output1.coeffs[base + 3u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(output1.coeffs[base + 4u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(output1.coeffs[base + 5u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(output1.coeffs[base + 6u] != 0);
    output1_nonzero_weight +=
        (uint32_t)(output1.coeffs[base + 7u] != 0);

    output2_nonzero_weight +=
        (uint32_t)(output2.coeffs[base + 0u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(output2.coeffs[base + 1u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(output2.coeffs[base + 2u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(output2.coeffs[base + 3u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(output2.coeffs[base + 4u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(output2.coeffs[base + 5u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(output2.coeffs[base + 6u] != 0);
    output2_nonzero_weight +=
        (uint32_t)(output2.coeffs[base + 7u] != 0);

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

  if (mode == 0u)
  {
    __CPROVER_assert(
        0,
        "FROMMSG_T4_R1_FULL_EXECUTION_REACHABLE");
  }

  if (mode == 1u)
  {
    __CPROVER_assume(coordinate_bit1 == 0u);
    __CPROVER_assume(coordinate_bit2 == 0u);

    __CPROVER_assert(
        0,
        "FROMMSG_T4_R2_COORDINATE_PAIR_00_REACHABLE");
  }

  if (mode == 2u)
  {
    __CPROVER_assume(coordinate_bit1 == 1u);
    __CPROVER_assume(coordinate_bit2 == 1u);

    __CPROVER_assert(
        0,
        "FROMMSG_T4_R3_COORDINATE_PAIR_11_REACHABLE");
  }

  if (mode == 3u)
  {
    __CPROVER_assume(coordinate_bit1 == 0u);
    __CPROVER_assume(coordinate_bit2 == 1u);

    __CPROVER_assert(
        0,
        "FROMMSG_T4_R4_COORDINATE_PAIR_01_REACHABLE");
  }

  if (mode == 4u)
  {
    __CPROVER_assume(coordinate_bit1 == 1u);
    __CPROVER_assume(coordinate_bit2 == 0u);

    __CPROVER_assert(
        0,
        "FROMMSG_T4_R5_COORDINATE_PAIR_10_REACHABLE");
  }

  if (mode == 5u)
  {
    __CPROVER_assume(message1_bit_weight == 0u);

    __CPROVER_assert(
        0,
        "FROMMSG_T4_R6_ZERO_CODEBOOK_WEIGHT_REACHABLE");
  }

  if (mode == 6u)
  {
    __CPROVER_assume(
        message1_bit_weight == MLKEM_N);

    __CPROVER_assert(
        0,
        "FROMMSG_T4_R7_MAXIMUM_CODEBOOK_WEIGHT_REACHABLE");
  }

  if (mode == 7u)
  {
    __CPROVER_assume(input_hamming_distance == 0u);

    __CPROVER_assert(
        0,
        "FROMMSG_T4_R8_ZERO_HAMMING_DISTANCE_REACHABLE");
  }

  if (mode == 8u)
  {
    __CPROVER_assume(input_hamming_distance == 1u);

    __CPROVER_assert(
        0,
        "FROMMSG_T4_R9_SINGLE_BIT_HAMMING_DISTANCE_REACHABLE");
  }

  if (mode == 9u)
  {
    __CPROVER_assume(
        input_hamming_distance == MLKEM_N);

    __CPROVER_assert(
        0,
        "FROMMSG_T4_R10_MAXIMUM_HAMMING_DISTANCE_REACHABLE");
  }

  if (mode == 10u)
  {
    __CPROVER_assert(
        (
          coordinate_coefficient1 !=
          coordinate_coefficient2
        ) ==
        (
          coordinate_bit1 ==
          coordinate_bit2
        ),
        "FROMMSG_T4_M1_INVERTED_COORDINATE_SUPPORT");
  }

  if (mode == 11u)
  {
    __CPROVER_assert(
        coordinate_coefficient1 ==
            (
              coordinate_bit1 == 1u
                  ? (int32_t)MLKEM_Q_HALF - 1
                  : 0
            ),
        "FROMMSG_T4_M2_WRONG_CODEBOOK_AMPLITUDE");
  }

  if (mode == 12u)
  {
    __CPROVER_assert(
        output1_nonzero_weight ==
            message2_bit_weight,
        "FROMMSG_T4_M3_CROSS_MESSAGE_WEIGHT");
  }

  if (mode == 13u)
  {
    __CPROVER_assert(
        output1_nonzero_weight ==
            message1_bit_weight + 1u,
        "FROMMSG_T4_M4_WEIGHT_OFF_BY_ONE");
  }

  if (mode == 14u)
  {
    __CPROVER_assert(
        output_hamming_distance ==
            input_hamming_distance + 1u,
        "FROMMSG_T4_M5_HAMMING_DISTANCE_OFF_BY_ONE");
  }

  if (mode == 15u)
  {
    __CPROVER_assert(
        output_absolute_distance ==
            (
              (
                (uint32_t)MLKEM_Q_HALF - 1u
              ) *
              input_hamming_distance
            ),
        "FROMMSG_T4_M6_WRONG_SCALED_DISTANCE_FACTOR");
  }
}
