/*
 * PKCHECK-T1R3
 *
 * Actual-body canonical-public-key acceptance.
 *
 * The complete polynomial-vector prefix is symbolic. Independent ByteDecode_12
 * assumptions constrain every one of its 768 coefficients to the canonical
 * range 0..MLKEM_Q-1. The public-seed suffix remains arbitrary.
 */

#include <stdint.h>

#include <cbmc.h>
#include <kem.h>
#include <params.h>

#define PKCHECK_PAIR_COUNT \
  (((unsigned)MLKEM_K * (unsigned)MLKEM_N) / 2u)

_Static_assert(
    MLKEM_INDCCA_PUBLICKEYBYTES ==
        MLKEM_POLYVECBYTES + MLKEM_SYMBYTES,
    "PKCHECK-T1R3 public-key layout mismatch");

_Static_assert(
    MLKEM_POLYVECBYTES == PKCHECK_PAIR_COUNT * 3u,
    "PKCHECK-T1R3 ByteEncode_12 layout mismatch");

void harness(void)
{
  uint8_t pk[MLKEM_INDCCA_PUBLICKEYBYTES];
  int result;

  __CPROVER_havoc_object(&pk);

  /*
   * Independent ByteDecode_12 canonicality constraints.
   * These statements are generated without a helper loop, so the theorem
   * introduces no harness-loop unwind assumption.
   */
  __CPROVER_assume(
      ((uint16_t)pk[0u] |
       ((uint16_t)(pk[1u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1u] >> 4) |
       ((uint16_t)pk[2u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[3u] |
       ((uint16_t)(pk[4u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[4u] >> 4) |
       ((uint16_t)pk[5u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[6u] |
       ((uint16_t)(pk[7u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[7u] >> 4) |
       ((uint16_t)pk[8u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[9u] |
       ((uint16_t)(pk[10u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[10u] >> 4) |
       ((uint16_t)pk[11u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[12u] |
       ((uint16_t)(pk[13u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[13u] >> 4) |
       ((uint16_t)pk[14u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[15u] |
       ((uint16_t)(pk[16u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[16u] >> 4) |
       ((uint16_t)pk[17u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[18u] |
       ((uint16_t)(pk[19u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[19u] >> 4) |
       ((uint16_t)pk[20u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[21u] |
       ((uint16_t)(pk[22u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[22u] >> 4) |
       ((uint16_t)pk[23u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[24u] |
       ((uint16_t)(pk[25u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[25u] >> 4) |
       ((uint16_t)pk[26u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[27u] |
       ((uint16_t)(pk[28u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[28u] >> 4) |
       ((uint16_t)pk[29u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[30u] |
       ((uint16_t)(pk[31u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[31u] >> 4) |
       ((uint16_t)pk[32u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[33u] |
       ((uint16_t)(pk[34u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[34u] >> 4) |
       ((uint16_t)pk[35u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[36u] |
       ((uint16_t)(pk[37u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[37u] >> 4) |
       ((uint16_t)pk[38u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[39u] |
       ((uint16_t)(pk[40u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[40u] >> 4) |
       ((uint16_t)pk[41u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[42u] |
       ((uint16_t)(pk[43u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[43u] >> 4) |
       ((uint16_t)pk[44u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[45u] |
       ((uint16_t)(pk[46u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[46u] >> 4) |
       ((uint16_t)pk[47u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[48u] |
       ((uint16_t)(pk[49u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[49u] >> 4) |
       ((uint16_t)pk[50u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[51u] |
       ((uint16_t)(pk[52u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[52u] >> 4) |
       ((uint16_t)pk[53u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[54u] |
       ((uint16_t)(pk[55u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[55u] >> 4) |
       ((uint16_t)pk[56u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[57u] |
       ((uint16_t)(pk[58u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[58u] >> 4) |
       ((uint16_t)pk[59u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[60u] |
       ((uint16_t)(pk[61u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[61u] >> 4) |
       ((uint16_t)pk[62u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[63u] |
       ((uint16_t)(pk[64u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[64u] >> 4) |
       ((uint16_t)pk[65u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[66u] |
       ((uint16_t)(pk[67u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[67u] >> 4) |
       ((uint16_t)pk[68u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[69u] |
       ((uint16_t)(pk[70u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[70u] >> 4) |
       ((uint16_t)pk[71u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[72u] |
       ((uint16_t)(pk[73u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[73u] >> 4) |
       ((uint16_t)pk[74u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[75u] |
       ((uint16_t)(pk[76u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[76u] >> 4) |
       ((uint16_t)pk[77u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[78u] |
       ((uint16_t)(pk[79u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[79u] >> 4) |
       ((uint16_t)pk[80u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[81u] |
       ((uint16_t)(pk[82u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[82u] >> 4) |
       ((uint16_t)pk[83u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[84u] |
       ((uint16_t)(pk[85u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[85u] >> 4) |
       ((uint16_t)pk[86u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[87u] |
       ((uint16_t)(pk[88u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[88u] >> 4) |
       ((uint16_t)pk[89u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[90u] |
       ((uint16_t)(pk[91u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[91u] >> 4) |
       ((uint16_t)pk[92u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[93u] |
       ((uint16_t)(pk[94u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[94u] >> 4) |
       ((uint16_t)pk[95u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[96u] |
       ((uint16_t)(pk[97u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[97u] >> 4) |
       ((uint16_t)pk[98u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[99u] |
       ((uint16_t)(pk[100u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[100u] >> 4) |
       ((uint16_t)pk[101u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[102u] |
       ((uint16_t)(pk[103u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[103u] >> 4) |
       ((uint16_t)pk[104u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[105u] |
       ((uint16_t)(pk[106u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[106u] >> 4) |
       ((uint16_t)pk[107u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[108u] |
       ((uint16_t)(pk[109u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[109u] >> 4) |
       ((uint16_t)pk[110u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[111u] |
       ((uint16_t)(pk[112u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[112u] >> 4) |
       ((uint16_t)pk[113u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[114u] |
       ((uint16_t)(pk[115u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[115u] >> 4) |
       ((uint16_t)pk[116u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[117u] |
       ((uint16_t)(pk[118u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[118u] >> 4) |
       ((uint16_t)pk[119u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[120u] |
       ((uint16_t)(pk[121u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[121u] >> 4) |
       ((uint16_t)pk[122u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[123u] |
       ((uint16_t)(pk[124u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[124u] >> 4) |
       ((uint16_t)pk[125u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[126u] |
       ((uint16_t)(pk[127u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[127u] >> 4) |
       ((uint16_t)pk[128u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[129u] |
       ((uint16_t)(pk[130u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[130u] >> 4) |
       ((uint16_t)pk[131u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[132u] |
       ((uint16_t)(pk[133u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[133u] >> 4) |
       ((uint16_t)pk[134u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[135u] |
       ((uint16_t)(pk[136u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[136u] >> 4) |
       ((uint16_t)pk[137u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[138u] |
       ((uint16_t)(pk[139u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[139u] >> 4) |
       ((uint16_t)pk[140u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[141u] |
       ((uint16_t)(pk[142u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[142u] >> 4) |
       ((uint16_t)pk[143u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[144u] |
       ((uint16_t)(pk[145u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[145u] >> 4) |
       ((uint16_t)pk[146u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[147u] |
       ((uint16_t)(pk[148u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[148u] >> 4) |
       ((uint16_t)pk[149u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[150u] |
       ((uint16_t)(pk[151u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[151u] >> 4) |
       ((uint16_t)pk[152u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[153u] |
       ((uint16_t)(pk[154u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[154u] >> 4) |
       ((uint16_t)pk[155u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[156u] |
       ((uint16_t)(pk[157u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[157u] >> 4) |
       ((uint16_t)pk[158u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[159u] |
       ((uint16_t)(pk[160u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[160u] >> 4) |
       ((uint16_t)pk[161u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[162u] |
       ((uint16_t)(pk[163u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[163u] >> 4) |
       ((uint16_t)pk[164u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[165u] |
       ((uint16_t)(pk[166u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[166u] >> 4) |
       ((uint16_t)pk[167u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[168u] |
       ((uint16_t)(pk[169u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[169u] >> 4) |
       ((uint16_t)pk[170u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[171u] |
       ((uint16_t)(pk[172u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[172u] >> 4) |
       ((uint16_t)pk[173u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[174u] |
       ((uint16_t)(pk[175u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[175u] >> 4) |
       ((uint16_t)pk[176u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[177u] |
       ((uint16_t)(pk[178u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[178u] >> 4) |
       ((uint16_t)pk[179u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[180u] |
       ((uint16_t)(pk[181u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[181u] >> 4) |
       ((uint16_t)pk[182u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[183u] |
       ((uint16_t)(pk[184u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[184u] >> 4) |
       ((uint16_t)pk[185u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[186u] |
       ((uint16_t)(pk[187u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[187u] >> 4) |
       ((uint16_t)pk[188u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[189u] |
       ((uint16_t)(pk[190u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[190u] >> 4) |
       ((uint16_t)pk[191u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[192u] |
       ((uint16_t)(pk[193u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[193u] >> 4) |
       ((uint16_t)pk[194u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[195u] |
       ((uint16_t)(pk[196u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[196u] >> 4) |
       ((uint16_t)pk[197u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[198u] |
       ((uint16_t)(pk[199u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[199u] >> 4) |
       ((uint16_t)pk[200u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[201u] |
       ((uint16_t)(pk[202u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[202u] >> 4) |
       ((uint16_t)pk[203u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[204u] |
       ((uint16_t)(pk[205u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[205u] >> 4) |
       ((uint16_t)pk[206u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[207u] |
       ((uint16_t)(pk[208u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[208u] >> 4) |
       ((uint16_t)pk[209u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[210u] |
       ((uint16_t)(pk[211u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[211u] >> 4) |
       ((uint16_t)pk[212u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[213u] |
       ((uint16_t)(pk[214u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[214u] >> 4) |
       ((uint16_t)pk[215u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[216u] |
       ((uint16_t)(pk[217u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[217u] >> 4) |
       ((uint16_t)pk[218u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[219u] |
       ((uint16_t)(pk[220u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[220u] >> 4) |
       ((uint16_t)pk[221u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[222u] |
       ((uint16_t)(pk[223u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[223u] >> 4) |
       ((uint16_t)pk[224u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[225u] |
       ((uint16_t)(pk[226u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[226u] >> 4) |
       ((uint16_t)pk[227u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[228u] |
       ((uint16_t)(pk[229u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[229u] >> 4) |
       ((uint16_t)pk[230u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[231u] |
       ((uint16_t)(pk[232u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[232u] >> 4) |
       ((uint16_t)pk[233u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[234u] |
       ((uint16_t)(pk[235u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[235u] >> 4) |
       ((uint16_t)pk[236u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[237u] |
       ((uint16_t)(pk[238u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[238u] >> 4) |
       ((uint16_t)pk[239u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[240u] |
       ((uint16_t)(pk[241u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[241u] >> 4) |
       ((uint16_t)pk[242u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[243u] |
       ((uint16_t)(pk[244u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[244u] >> 4) |
       ((uint16_t)pk[245u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[246u] |
       ((uint16_t)(pk[247u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[247u] >> 4) |
       ((uint16_t)pk[248u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[249u] |
       ((uint16_t)(pk[250u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[250u] >> 4) |
       ((uint16_t)pk[251u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[252u] |
       ((uint16_t)(pk[253u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[253u] >> 4) |
       ((uint16_t)pk[254u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[255u] |
       ((uint16_t)(pk[256u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[256u] >> 4) |
       ((uint16_t)pk[257u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[258u] |
       ((uint16_t)(pk[259u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[259u] >> 4) |
       ((uint16_t)pk[260u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[261u] |
       ((uint16_t)(pk[262u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[262u] >> 4) |
       ((uint16_t)pk[263u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[264u] |
       ((uint16_t)(pk[265u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[265u] >> 4) |
       ((uint16_t)pk[266u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[267u] |
       ((uint16_t)(pk[268u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[268u] >> 4) |
       ((uint16_t)pk[269u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[270u] |
       ((uint16_t)(pk[271u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[271u] >> 4) |
       ((uint16_t)pk[272u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[273u] |
       ((uint16_t)(pk[274u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[274u] >> 4) |
       ((uint16_t)pk[275u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[276u] |
       ((uint16_t)(pk[277u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[277u] >> 4) |
       ((uint16_t)pk[278u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[279u] |
       ((uint16_t)(pk[280u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[280u] >> 4) |
       ((uint16_t)pk[281u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[282u] |
       ((uint16_t)(pk[283u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[283u] >> 4) |
       ((uint16_t)pk[284u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[285u] |
       ((uint16_t)(pk[286u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[286u] >> 4) |
       ((uint16_t)pk[287u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[288u] |
       ((uint16_t)(pk[289u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[289u] >> 4) |
       ((uint16_t)pk[290u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[291u] |
       ((uint16_t)(pk[292u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[292u] >> 4) |
       ((uint16_t)pk[293u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[294u] |
       ((uint16_t)(pk[295u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[295u] >> 4) |
       ((uint16_t)pk[296u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[297u] |
       ((uint16_t)(pk[298u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[298u] >> 4) |
       ((uint16_t)pk[299u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[300u] |
       ((uint16_t)(pk[301u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[301u] >> 4) |
       ((uint16_t)pk[302u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[303u] |
       ((uint16_t)(pk[304u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[304u] >> 4) |
       ((uint16_t)pk[305u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[306u] |
       ((uint16_t)(pk[307u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[307u] >> 4) |
       ((uint16_t)pk[308u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[309u] |
       ((uint16_t)(pk[310u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[310u] >> 4) |
       ((uint16_t)pk[311u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[312u] |
       ((uint16_t)(pk[313u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[313u] >> 4) |
       ((uint16_t)pk[314u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[315u] |
       ((uint16_t)(pk[316u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[316u] >> 4) |
       ((uint16_t)pk[317u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[318u] |
       ((uint16_t)(pk[319u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[319u] >> 4) |
       ((uint16_t)pk[320u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[321u] |
       ((uint16_t)(pk[322u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[322u] >> 4) |
       ((uint16_t)pk[323u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[324u] |
       ((uint16_t)(pk[325u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[325u] >> 4) |
       ((uint16_t)pk[326u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[327u] |
       ((uint16_t)(pk[328u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[328u] >> 4) |
       ((uint16_t)pk[329u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[330u] |
       ((uint16_t)(pk[331u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[331u] >> 4) |
       ((uint16_t)pk[332u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[333u] |
       ((uint16_t)(pk[334u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[334u] >> 4) |
       ((uint16_t)pk[335u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[336u] |
       ((uint16_t)(pk[337u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[337u] >> 4) |
       ((uint16_t)pk[338u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[339u] |
       ((uint16_t)(pk[340u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[340u] >> 4) |
       ((uint16_t)pk[341u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[342u] |
       ((uint16_t)(pk[343u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[343u] >> 4) |
       ((uint16_t)pk[344u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[345u] |
       ((uint16_t)(pk[346u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[346u] >> 4) |
       ((uint16_t)pk[347u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[348u] |
       ((uint16_t)(pk[349u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[349u] >> 4) |
       ((uint16_t)pk[350u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[351u] |
       ((uint16_t)(pk[352u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[352u] >> 4) |
       ((uint16_t)pk[353u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[354u] |
       ((uint16_t)(pk[355u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[355u] >> 4) |
       ((uint16_t)pk[356u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[357u] |
       ((uint16_t)(pk[358u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[358u] >> 4) |
       ((uint16_t)pk[359u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[360u] |
       ((uint16_t)(pk[361u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[361u] >> 4) |
       ((uint16_t)pk[362u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[363u] |
       ((uint16_t)(pk[364u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[364u] >> 4) |
       ((uint16_t)pk[365u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[366u] |
       ((uint16_t)(pk[367u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[367u] >> 4) |
       ((uint16_t)pk[368u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[369u] |
       ((uint16_t)(pk[370u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[370u] >> 4) |
       ((uint16_t)pk[371u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[372u] |
       ((uint16_t)(pk[373u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[373u] >> 4) |
       ((uint16_t)pk[374u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[375u] |
       ((uint16_t)(pk[376u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[376u] >> 4) |
       ((uint16_t)pk[377u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[378u] |
       ((uint16_t)(pk[379u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[379u] >> 4) |
       ((uint16_t)pk[380u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[381u] |
       ((uint16_t)(pk[382u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[382u] >> 4) |
       ((uint16_t)pk[383u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[384u] |
       ((uint16_t)(pk[385u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[385u] >> 4) |
       ((uint16_t)pk[386u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[387u] |
       ((uint16_t)(pk[388u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[388u] >> 4) |
       ((uint16_t)pk[389u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[390u] |
       ((uint16_t)(pk[391u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[391u] >> 4) |
       ((uint16_t)pk[392u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[393u] |
       ((uint16_t)(pk[394u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[394u] >> 4) |
       ((uint16_t)pk[395u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[396u] |
       ((uint16_t)(pk[397u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[397u] >> 4) |
       ((uint16_t)pk[398u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[399u] |
       ((uint16_t)(pk[400u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[400u] >> 4) |
       ((uint16_t)pk[401u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[402u] |
       ((uint16_t)(pk[403u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[403u] >> 4) |
       ((uint16_t)pk[404u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[405u] |
       ((uint16_t)(pk[406u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[406u] >> 4) |
       ((uint16_t)pk[407u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[408u] |
       ((uint16_t)(pk[409u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[409u] >> 4) |
       ((uint16_t)pk[410u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[411u] |
       ((uint16_t)(pk[412u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[412u] >> 4) |
       ((uint16_t)pk[413u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[414u] |
       ((uint16_t)(pk[415u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[415u] >> 4) |
       ((uint16_t)pk[416u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[417u] |
       ((uint16_t)(pk[418u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[418u] >> 4) |
       ((uint16_t)pk[419u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[420u] |
       ((uint16_t)(pk[421u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[421u] >> 4) |
       ((uint16_t)pk[422u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[423u] |
       ((uint16_t)(pk[424u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[424u] >> 4) |
       ((uint16_t)pk[425u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[426u] |
       ((uint16_t)(pk[427u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[427u] >> 4) |
       ((uint16_t)pk[428u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[429u] |
       ((uint16_t)(pk[430u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[430u] >> 4) |
       ((uint16_t)pk[431u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[432u] |
       ((uint16_t)(pk[433u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[433u] >> 4) |
       ((uint16_t)pk[434u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[435u] |
       ((uint16_t)(pk[436u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[436u] >> 4) |
       ((uint16_t)pk[437u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[438u] |
       ((uint16_t)(pk[439u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[439u] >> 4) |
       ((uint16_t)pk[440u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[441u] |
       ((uint16_t)(pk[442u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[442u] >> 4) |
       ((uint16_t)pk[443u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[444u] |
       ((uint16_t)(pk[445u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[445u] >> 4) |
       ((uint16_t)pk[446u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[447u] |
       ((uint16_t)(pk[448u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[448u] >> 4) |
       ((uint16_t)pk[449u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[450u] |
       ((uint16_t)(pk[451u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[451u] >> 4) |
       ((uint16_t)pk[452u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[453u] |
       ((uint16_t)(pk[454u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[454u] >> 4) |
       ((uint16_t)pk[455u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[456u] |
       ((uint16_t)(pk[457u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[457u] >> 4) |
       ((uint16_t)pk[458u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[459u] |
       ((uint16_t)(pk[460u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[460u] >> 4) |
       ((uint16_t)pk[461u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[462u] |
       ((uint16_t)(pk[463u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[463u] >> 4) |
       ((uint16_t)pk[464u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[465u] |
       ((uint16_t)(pk[466u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[466u] >> 4) |
       ((uint16_t)pk[467u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[468u] |
       ((uint16_t)(pk[469u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[469u] >> 4) |
       ((uint16_t)pk[470u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[471u] |
       ((uint16_t)(pk[472u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[472u] >> 4) |
       ((uint16_t)pk[473u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[474u] |
       ((uint16_t)(pk[475u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[475u] >> 4) |
       ((uint16_t)pk[476u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[477u] |
       ((uint16_t)(pk[478u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[478u] >> 4) |
       ((uint16_t)pk[479u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[480u] |
       ((uint16_t)(pk[481u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[481u] >> 4) |
       ((uint16_t)pk[482u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[483u] |
       ((uint16_t)(pk[484u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[484u] >> 4) |
       ((uint16_t)pk[485u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[486u] |
       ((uint16_t)(pk[487u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[487u] >> 4) |
       ((uint16_t)pk[488u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[489u] |
       ((uint16_t)(pk[490u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[490u] >> 4) |
       ((uint16_t)pk[491u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[492u] |
       ((uint16_t)(pk[493u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[493u] >> 4) |
       ((uint16_t)pk[494u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[495u] |
       ((uint16_t)(pk[496u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[496u] >> 4) |
       ((uint16_t)pk[497u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[498u] |
       ((uint16_t)(pk[499u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[499u] >> 4) |
       ((uint16_t)pk[500u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[501u] |
       ((uint16_t)(pk[502u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[502u] >> 4) |
       ((uint16_t)pk[503u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[504u] |
       ((uint16_t)(pk[505u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[505u] >> 4) |
       ((uint16_t)pk[506u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[507u] |
       ((uint16_t)(pk[508u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[508u] >> 4) |
       ((uint16_t)pk[509u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[510u] |
       ((uint16_t)(pk[511u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[511u] >> 4) |
       ((uint16_t)pk[512u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[513u] |
       ((uint16_t)(pk[514u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[514u] >> 4) |
       ((uint16_t)pk[515u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[516u] |
       ((uint16_t)(pk[517u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[517u] >> 4) |
       ((uint16_t)pk[518u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[519u] |
       ((uint16_t)(pk[520u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[520u] >> 4) |
       ((uint16_t)pk[521u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[522u] |
       ((uint16_t)(pk[523u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[523u] >> 4) |
       ((uint16_t)pk[524u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[525u] |
       ((uint16_t)(pk[526u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[526u] >> 4) |
       ((uint16_t)pk[527u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[528u] |
       ((uint16_t)(pk[529u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[529u] >> 4) |
       ((uint16_t)pk[530u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[531u] |
       ((uint16_t)(pk[532u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[532u] >> 4) |
       ((uint16_t)pk[533u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[534u] |
       ((uint16_t)(pk[535u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[535u] >> 4) |
       ((uint16_t)pk[536u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[537u] |
       ((uint16_t)(pk[538u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[538u] >> 4) |
       ((uint16_t)pk[539u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[540u] |
       ((uint16_t)(pk[541u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[541u] >> 4) |
       ((uint16_t)pk[542u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[543u] |
       ((uint16_t)(pk[544u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[544u] >> 4) |
       ((uint16_t)pk[545u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[546u] |
       ((uint16_t)(pk[547u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[547u] >> 4) |
       ((uint16_t)pk[548u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[549u] |
       ((uint16_t)(pk[550u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[550u] >> 4) |
       ((uint16_t)pk[551u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[552u] |
       ((uint16_t)(pk[553u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[553u] >> 4) |
       ((uint16_t)pk[554u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[555u] |
       ((uint16_t)(pk[556u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[556u] >> 4) |
       ((uint16_t)pk[557u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[558u] |
       ((uint16_t)(pk[559u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[559u] >> 4) |
       ((uint16_t)pk[560u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[561u] |
       ((uint16_t)(pk[562u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[562u] >> 4) |
       ((uint16_t)pk[563u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[564u] |
       ((uint16_t)(pk[565u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[565u] >> 4) |
       ((uint16_t)pk[566u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[567u] |
       ((uint16_t)(pk[568u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[568u] >> 4) |
       ((uint16_t)pk[569u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[570u] |
       ((uint16_t)(pk[571u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[571u] >> 4) |
       ((uint16_t)pk[572u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[573u] |
       ((uint16_t)(pk[574u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[574u] >> 4) |
       ((uint16_t)pk[575u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[576u] |
       ((uint16_t)(pk[577u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[577u] >> 4) |
       ((uint16_t)pk[578u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[579u] |
       ((uint16_t)(pk[580u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[580u] >> 4) |
       ((uint16_t)pk[581u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[582u] |
       ((uint16_t)(pk[583u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[583u] >> 4) |
       ((uint16_t)pk[584u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[585u] |
       ((uint16_t)(pk[586u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[586u] >> 4) |
       ((uint16_t)pk[587u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[588u] |
       ((uint16_t)(pk[589u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[589u] >> 4) |
       ((uint16_t)pk[590u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[591u] |
       ((uint16_t)(pk[592u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[592u] >> 4) |
       ((uint16_t)pk[593u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[594u] |
       ((uint16_t)(pk[595u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[595u] >> 4) |
       ((uint16_t)pk[596u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[597u] |
       ((uint16_t)(pk[598u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[598u] >> 4) |
       ((uint16_t)pk[599u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[600u] |
       ((uint16_t)(pk[601u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[601u] >> 4) |
       ((uint16_t)pk[602u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[603u] |
       ((uint16_t)(pk[604u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[604u] >> 4) |
       ((uint16_t)pk[605u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[606u] |
       ((uint16_t)(pk[607u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[607u] >> 4) |
       ((uint16_t)pk[608u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[609u] |
       ((uint16_t)(pk[610u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[610u] >> 4) |
       ((uint16_t)pk[611u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[612u] |
       ((uint16_t)(pk[613u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[613u] >> 4) |
       ((uint16_t)pk[614u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[615u] |
       ((uint16_t)(pk[616u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[616u] >> 4) |
       ((uint16_t)pk[617u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[618u] |
       ((uint16_t)(pk[619u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[619u] >> 4) |
       ((uint16_t)pk[620u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[621u] |
       ((uint16_t)(pk[622u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[622u] >> 4) |
       ((uint16_t)pk[623u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[624u] |
       ((uint16_t)(pk[625u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[625u] >> 4) |
       ((uint16_t)pk[626u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[627u] |
       ((uint16_t)(pk[628u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[628u] >> 4) |
       ((uint16_t)pk[629u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[630u] |
       ((uint16_t)(pk[631u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[631u] >> 4) |
       ((uint16_t)pk[632u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[633u] |
       ((uint16_t)(pk[634u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[634u] >> 4) |
       ((uint16_t)pk[635u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[636u] |
       ((uint16_t)(pk[637u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[637u] >> 4) |
       ((uint16_t)pk[638u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[639u] |
       ((uint16_t)(pk[640u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[640u] >> 4) |
       ((uint16_t)pk[641u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[642u] |
       ((uint16_t)(pk[643u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[643u] >> 4) |
       ((uint16_t)pk[644u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[645u] |
       ((uint16_t)(pk[646u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[646u] >> 4) |
       ((uint16_t)pk[647u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[648u] |
       ((uint16_t)(pk[649u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[649u] >> 4) |
       ((uint16_t)pk[650u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[651u] |
       ((uint16_t)(pk[652u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[652u] >> 4) |
       ((uint16_t)pk[653u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[654u] |
       ((uint16_t)(pk[655u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[655u] >> 4) |
       ((uint16_t)pk[656u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[657u] |
       ((uint16_t)(pk[658u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[658u] >> 4) |
       ((uint16_t)pk[659u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[660u] |
       ((uint16_t)(pk[661u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[661u] >> 4) |
       ((uint16_t)pk[662u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[663u] |
       ((uint16_t)(pk[664u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[664u] >> 4) |
       ((uint16_t)pk[665u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[666u] |
       ((uint16_t)(pk[667u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[667u] >> 4) |
       ((uint16_t)pk[668u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[669u] |
       ((uint16_t)(pk[670u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[670u] >> 4) |
       ((uint16_t)pk[671u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[672u] |
       ((uint16_t)(pk[673u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[673u] >> 4) |
       ((uint16_t)pk[674u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[675u] |
       ((uint16_t)(pk[676u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[676u] >> 4) |
       ((uint16_t)pk[677u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[678u] |
       ((uint16_t)(pk[679u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[679u] >> 4) |
       ((uint16_t)pk[680u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[681u] |
       ((uint16_t)(pk[682u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[682u] >> 4) |
       ((uint16_t)pk[683u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[684u] |
       ((uint16_t)(pk[685u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[685u] >> 4) |
       ((uint16_t)pk[686u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[687u] |
       ((uint16_t)(pk[688u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[688u] >> 4) |
       ((uint16_t)pk[689u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[690u] |
       ((uint16_t)(pk[691u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[691u] >> 4) |
       ((uint16_t)pk[692u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[693u] |
       ((uint16_t)(pk[694u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[694u] >> 4) |
       ((uint16_t)pk[695u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[696u] |
       ((uint16_t)(pk[697u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[697u] >> 4) |
       ((uint16_t)pk[698u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[699u] |
       ((uint16_t)(pk[700u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[700u] >> 4) |
       ((uint16_t)pk[701u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[702u] |
       ((uint16_t)(pk[703u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[703u] >> 4) |
       ((uint16_t)pk[704u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[705u] |
       ((uint16_t)(pk[706u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[706u] >> 4) |
       ((uint16_t)pk[707u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[708u] |
       ((uint16_t)(pk[709u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[709u] >> 4) |
       ((uint16_t)pk[710u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[711u] |
       ((uint16_t)(pk[712u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[712u] >> 4) |
       ((uint16_t)pk[713u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[714u] |
       ((uint16_t)(pk[715u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[715u] >> 4) |
       ((uint16_t)pk[716u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[717u] |
       ((uint16_t)(pk[718u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[718u] >> 4) |
       ((uint16_t)pk[719u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[720u] |
       ((uint16_t)(pk[721u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[721u] >> 4) |
       ((uint16_t)pk[722u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[723u] |
       ((uint16_t)(pk[724u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[724u] >> 4) |
       ((uint16_t)pk[725u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[726u] |
       ((uint16_t)(pk[727u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[727u] >> 4) |
       ((uint16_t)pk[728u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[729u] |
       ((uint16_t)(pk[730u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[730u] >> 4) |
       ((uint16_t)pk[731u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[732u] |
       ((uint16_t)(pk[733u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[733u] >> 4) |
       ((uint16_t)pk[734u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[735u] |
       ((uint16_t)(pk[736u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[736u] >> 4) |
       ((uint16_t)pk[737u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[738u] |
       ((uint16_t)(pk[739u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[739u] >> 4) |
       ((uint16_t)pk[740u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[741u] |
       ((uint16_t)(pk[742u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[742u] >> 4) |
       ((uint16_t)pk[743u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[744u] |
       ((uint16_t)(pk[745u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[745u] >> 4) |
       ((uint16_t)pk[746u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[747u] |
       ((uint16_t)(pk[748u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[748u] >> 4) |
       ((uint16_t)pk[749u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[750u] |
       ((uint16_t)(pk[751u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[751u] >> 4) |
       ((uint16_t)pk[752u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[753u] |
       ((uint16_t)(pk[754u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[754u] >> 4) |
       ((uint16_t)pk[755u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[756u] |
       ((uint16_t)(pk[757u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[757u] >> 4) |
       ((uint16_t)pk[758u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[759u] |
       ((uint16_t)(pk[760u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[760u] >> 4) |
       ((uint16_t)pk[761u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[762u] |
       ((uint16_t)(pk[763u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[763u] >> 4) |
       ((uint16_t)pk[764u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[765u] |
       ((uint16_t)(pk[766u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[766u] >> 4) |
       ((uint16_t)pk[767u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[768u] |
       ((uint16_t)(pk[769u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[769u] >> 4) |
       ((uint16_t)pk[770u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[771u] |
       ((uint16_t)(pk[772u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[772u] >> 4) |
       ((uint16_t)pk[773u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[774u] |
       ((uint16_t)(pk[775u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[775u] >> 4) |
       ((uint16_t)pk[776u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[777u] |
       ((uint16_t)(pk[778u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[778u] >> 4) |
       ((uint16_t)pk[779u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[780u] |
       ((uint16_t)(pk[781u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[781u] >> 4) |
       ((uint16_t)pk[782u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[783u] |
       ((uint16_t)(pk[784u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[784u] >> 4) |
       ((uint16_t)pk[785u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[786u] |
       ((uint16_t)(pk[787u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[787u] >> 4) |
       ((uint16_t)pk[788u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[789u] |
       ((uint16_t)(pk[790u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[790u] >> 4) |
       ((uint16_t)pk[791u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[792u] |
       ((uint16_t)(pk[793u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[793u] >> 4) |
       ((uint16_t)pk[794u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[795u] |
       ((uint16_t)(pk[796u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[796u] >> 4) |
       ((uint16_t)pk[797u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[798u] |
       ((uint16_t)(pk[799u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[799u] >> 4) |
       ((uint16_t)pk[800u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[801u] |
       ((uint16_t)(pk[802u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[802u] >> 4) |
       ((uint16_t)pk[803u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[804u] |
       ((uint16_t)(pk[805u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[805u] >> 4) |
       ((uint16_t)pk[806u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[807u] |
       ((uint16_t)(pk[808u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[808u] >> 4) |
       ((uint16_t)pk[809u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[810u] |
       ((uint16_t)(pk[811u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[811u] >> 4) |
       ((uint16_t)pk[812u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[813u] |
       ((uint16_t)(pk[814u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[814u] >> 4) |
       ((uint16_t)pk[815u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[816u] |
       ((uint16_t)(pk[817u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[817u] >> 4) |
       ((uint16_t)pk[818u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[819u] |
       ((uint16_t)(pk[820u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[820u] >> 4) |
       ((uint16_t)pk[821u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[822u] |
       ((uint16_t)(pk[823u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[823u] >> 4) |
       ((uint16_t)pk[824u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[825u] |
       ((uint16_t)(pk[826u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[826u] >> 4) |
       ((uint16_t)pk[827u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[828u] |
       ((uint16_t)(pk[829u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[829u] >> 4) |
       ((uint16_t)pk[830u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[831u] |
       ((uint16_t)(pk[832u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[832u] >> 4) |
       ((uint16_t)pk[833u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[834u] |
       ((uint16_t)(pk[835u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[835u] >> 4) |
       ((uint16_t)pk[836u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[837u] |
       ((uint16_t)(pk[838u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[838u] >> 4) |
       ((uint16_t)pk[839u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[840u] |
       ((uint16_t)(pk[841u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[841u] >> 4) |
       ((uint16_t)pk[842u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[843u] |
       ((uint16_t)(pk[844u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[844u] >> 4) |
       ((uint16_t)pk[845u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[846u] |
       ((uint16_t)(pk[847u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[847u] >> 4) |
       ((uint16_t)pk[848u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[849u] |
       ((uint16_t)(pk[850u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[850u] >> 4) |
       ((uint16_t)pk[851u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[852u] |
       ((uint16_t)(pk[853u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[853u] >> 4) |
       ((uint16_t)pk[854u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[855u] |
       ((uint16_t)(pk[856u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[856u] >> 4) |
       ((uint16_t)pk[857u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[858u] |
       ((uint16_t)(pk[859u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[859u] >> 4) |
       ((uint16_t)pk[860u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[861u] |
       ((uint16_t)(pk[862u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[862u] >> 4) |
       ((uint16_t)pk[863u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[864u] |
       ((uint16_t)(pk[865u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[865u] >> 4) |
       ((uint16_t)pk[866u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[867u] |
       ((uint16_t)(pk[868u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[868u] >> 4) |
       ((uint16_t)pk[869u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[870u] |
       ((uint16_t)(pk[871u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[871u] >> 4) |
       ((uint16_t)pk[872u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[873u] |
       ((uint16_t)(pk[874u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[874u] >> 4) |
       ((uint16_t)pk[875u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[876u] |
       ((uint16_t)(pk[877u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[877u] >> 4) |
       ((uint16_t)pk[878u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[879u] |
       ((uint16_t)(pk[880u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[880u] >> 4) |
       ((uint16_t)pk[881u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[882u] |
       ((uint16_t)(pk[883u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[883u] >> 4) |
       ((uint16_t)pk[884u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[885u] |
       ((uint16_t)(pk[886u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[886u] >> 4) |
       ((uint16_t)pk[887u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[888u] |
       ((uint16_t)(pk[889u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[889u] >> 4) |
       ((uint16_t)pk[890u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[891u] |
       ((uint16_t)(pk[892u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[892u] >> 4) |
       ((uint16_t)pk[893u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[894u] |
       ((uint16_t)(pk[895u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[895u] >> 4) |
       ((uint16_t)pk[896u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[897u] |
       ((uint16_t)(pk[898u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[898u] >> 4) |
       ((uint16_t)pk[899u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[900u] |
       ((uint16_t)(pk[901u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[901u] >> 4) |
       ((uint16_t)pk[902u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[903u] |
       ((uint16_t)(pk[904u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[904u] >> 4) |
       ((uint16_t)pk[905u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[906u] |
       ((uint16_t)(pk[907u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[907u] >> 4) |
       ((uint16_t)pk[908u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[909u] |
       ((uint16_t)(pk[910u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[910u] >> 4) |
       ((uint16_t)pk[911u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[912u] |
       ((uint16_t)(pk[913u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[913u] >> 4) |
       ((uint16_t)pk[914u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[915u] |
       ((uint16_t)(pk[916u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[916u] >> 4) |
       ((uint16_t)pk[917u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[918u] |
       ((uint16_t)(pk[919u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[919u] >> 4) |
       ((uint16_t)pk[920u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[921u] |
       ((uint16_t)(pk[922u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[922u] >> 4) |
       ((uint16_t)pk[923u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[924u] |
       ((uint16_t)(pk[925u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[925u] >> 4) |
       ((uint16_t)pk[926u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[927u] |
       ((uint16_t)(pk[928u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[928u] >> 4) |
       ((uint16_t)pk[929u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[930u] |
       ((uint16_t)(pk[931u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[931u] >> 4) |
       ((uint16_t)pk[932u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[933u] |
       ((uint16_t)(pk[934u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[934u] >> 4) |
       ((uint16_t)pk[935u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[936u] |
       ((uint16_t)(pk[937u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[937u] >> 4) |
       ((uint16_t)pk[938u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[939u] |
       ((uint16_t)(pk[940u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[940u] >> 4) |
       ((uint16_t)pk[941u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[942u] |
       ((uint16_t)(pk[943u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[943u] >> 4) |
       ((uint16_t)pk[944u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[945u] |
       ((uint16_t)(pk[946u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[946u] >> 4) |
       ((uint16_t)pk[947u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[948u] |
       ((uint16_t)(pk[949u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[949u] >> 4) |
       ((uint16_t)pk[950u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[951u] |
       ((uint16_t)(pk[952u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[952u] >> 4) |
       ((uint16_t)pk[953u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[954u] |
       ((uint16_t)(pk[955u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[955u] >> 4) |
       ((uint16_t)pk[956u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[957u] |
       ((uint16_t)(pk[958u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[958u] >> 4) |
       ((uint16_t)pk[959u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[960u] |
       ((uint16_t)(pk[961u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[961u] >> 4) |
       ((uint16_t)pk[962u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[963u] |
       ((uint16_t)(pk[964u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[964u] >> 4) |
       ((uint16_t)pk[965u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[966u] |
       ((uint16_t)(pk[967u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[967u] >> 4) |
       ((uint16_t)pk[968u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[969u] |
       ((uint16_t)(pk[970u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[970u] >> 4) |
       ((uint16_t)pk[971u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[972u] |
       ((uint16_t)(pk[973u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[973u] >> 4) |
       ((uint16_t)pk[974u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[975u] |
       ((uint16_t)(pk[976u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[976u] >> 4) |
       ((uint16_t)pk[977u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[978u] |
       ((uint16_t)(pk[979u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[979u] >> 4) |
       ((uint16_t)pk[980u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[981u] |
       ((uint16_t)(pk[982u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[982u] >> 4) |
       ((uint16_t)pk[983u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[984u] |
       ((uint16_t)(pk[985u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[985u] >> 4) |
       ((uint16_t)pk[986u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[987u] |
       ((uint16_t)(pk[988u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[988u] >> 4) |
       ((uint16_t)pk[989u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[990u] |
       ((uint16_t)(pk[991u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[991u] >> 4) |
       ((uint16_t)pk[992u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[993u] |
       ((uint16_t)(pk[994u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[994u] >> 4) |
       ((uint16_t)pk[995u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[996u] |
       ((uint16_t)(pk[997u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[997u] >> 4) |
       ((uint16_t)pk[998u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[999u] |
       ((uint16_t)(pk[1000u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1000u] >> 4) |
       ((uint16_t)pk[1001u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1002u] |
       ((uint16_t)(pk[1003u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1003u] >> 4) |
       ((uint16_t)pk[1004u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1005u] |
       ((uint16_t)(pk[1006u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1006u] >> 4) |
       ((uint16_t)pk[1007u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1008u] |
       ((uint16_t)(pk[1009u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1009u] >> 4) |
       ((uint16_t)pk[1010u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1011u] |
       ((uint16_t)(pk[1012u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1012u] >> 4) |
       ((uint16_t)pk[1013u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1014u] |
       ((uint16_t)(pk[1015u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1015u] >> 4) |
       ((uint16_t)pk[1016u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1017u] |
       ((uint16_t)(pk[1018u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1018u] >> 4) |
       ((uint16_t)pk[1019u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1020u] |
       ((uint16_t)(pk[1021u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1021u] >> 4) |
       ((uint16_t)pk[1022u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1023u] |
       ((uint16_t)(pk[1024u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1024u] >> 4) |
       ((uint16_t)pk[1025u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1026u] |
       ((uint16_t)(pk[1027u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1027u] >> 4) |
       ((uint16_t)pk[1028u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1029u] |
       ((uint16_t)(pk[1030u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1030u] >> 4) |
       ((uint16_t)pk[1031u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1032u] |
       ((uint16_t)(pk[1033u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1033u] >> 4) |
       ((uint16_t)pk[1034u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1035u] |
       ((uint16_t)(pk[1036u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1036u] >> 4) |
       ((uint16_t)pk[1037u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1038u] |
       ((uint16_t)(pk[1039u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1039u] >> 4) |
       ((uint16_t)pk[1040u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1041u] |
       ((uint16_t)(pk[1042u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1042u] >> 4) |
       ((uint16_t)pk[1043u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1044u] |
       ((uint16_t)(pk[1045u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1045u] >> 4) |
       ((uint16_t)pk[1046u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1047u] |
       ((uint16_t)(pk[1048u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1048u] >> 4) |
       ((uint16_t)pk[1049u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1050u] |
       ((uint16_t)(pk[1051u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1051u] >> 4) |
       ((uint16_t)pk[1052u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1053u] |
       ((uint16_t)(pk[1054u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1054u] >> 4) |
       ((uint16_t)pk[1055u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1056u] |
       ((uint16_t)(pk[1057u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1057u] >> 4) |
       ((uint16_t)pk[1058u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1059u] |
       ((uint16_t)(pk[1060u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1060u] >> 4) |
       ((uint16_t)pk[1061u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1062u] |
       ((uint16_t)(pk[1063u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1063u] >> 4) |
       ((uint16_t)pk[1064u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1065u] |
       ((uint16_t)(pk[1066u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1066u] >> 4) |
       ((uint16_t)pk[1067u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1068u] |
       ((uint16_t)(pk[1069u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1069u] >> 4) |
       ((uint16_t)pk[1070u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1071u] |
       ((uint16_t)(pk[1072u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1072u] >> 4) |
       ((uint16_t)pk[1073u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1074u] |
       ((uint16_t)(pk[1075u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1075u] >> 4) |
       ((uint16_t)pk[1076u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1077u] |
       ((uint16_t)(pk[1078u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1078u] >> 4) |
       ((uint16_t)pk[1079u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1080u] |
       ((uint16_t)(pk[1081u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1081u] >> 4) |
       ((uint16_t)pk[1082u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1083u] |
       ((uint16_t)(pk[1084u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1084u] >> 4) |
       ((uint16_t)pk[1085u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1086u] |
       ((uint16_t)(pk[1087u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1087u] >> 4) |
       ((uint16_t)pk[1088u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1089u] |
       ((uint16_t)(pk[1090u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1090u] >> 4) |
       ((uint16_t)pk[1091u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1092u] |
       ((uint16_t)(pk[1093u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1093u] >> 4) |
       ((uint16_t)pk[1094u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1095u] |
       ((uint16_t)(pk[1096u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1096u] >> 4) |
       ((uint16_t)pk[1097u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1098u] |
       ((uint16_t)(pk[1099u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1099u] >> 4) |
       ((uint16_t)pk[1100u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1101u] |
       ((uint16_t)(pk[1102u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1102u] >> 4) |
       ((uint16_t)pk[1103u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1104u] |
       ((uint16_t)(pk[1105u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1105u] >> 4) |
       ((uint16_t)pk[1106u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1107u] |
       ((uint16_t)(pk[1108u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1108u] >> 4) |
       ((uint16_t)pk[1109u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1110u] |
       ((uint16_t)(pk[1111u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1111u] >> 4) |
       ((uint16_t)pk[1112u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1113u] |
       ((uint16_t)(pk[1114u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1114u] >> 4) |
       ((uint16_t)pk[1115u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1116u] |
       ((uint16_t)(pk[1117u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1117u] >> 4) |
       ((uint16_t)pk[1118u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1119u] |
       ((uint16_t)(pk[1120u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1120u] >> 4) |
       ((uint16_t)pk[1121u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1122u] |
       ((uint16_t)(pk[1123u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1123u] >> 4) |
       ((uint16_t)pk[1124u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1125u] |
       ((uint16_t)(pk[1126u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1126u] >> 4) |
       ((uint16_t)pk[1127u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1128u] |
       ((uint16_t)(pk[1129u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1129u] >> 4) |
       ((uint16_t)pk[1130u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1131u] |
       ((uint16_t)(pk[1132u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1132u] >> 4) |
       ((uint16_t)pk[1133u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1134u] |
       ((uint16_t)(pk[1135u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1135u] >> 4) |
       ((uint16_t)pk[1136u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1137u] |
       ((uint16_t)(pk[1138u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1138u] >> 4) |
       ((uint16_t)pk[1139u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1140u] |
       ((uint16_t)(pk[1141u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1141u] >> 4) |
       ((uint16_t)pk[1142u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1143u] |
       ((uint16_t)(pk[1144u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1144u] >> 4) |
       ((uint16_t)pk[1145u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1146u] |
       ((uint16_t)(pk[1147u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1147u] >> 4) |
       ((uint16_t)pk[1148u] << 4)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)pk[1149u] |
       ((uint16_t)(pk[1150u] & UINT8_C(0x0F)) << 8)) <
          (uint16_t)MLKEM_Q);

  __CPROVER_assume(
      ((uint16_t)(pk[1150u] >> 4) |
       ((uint16_t)pk[1151u] << 4)) <
          (uint16_t)MLKEM_Q);

  result = mlk_kem_check_pk(
      pk,
      NULL /* context removed by preprocessing */);

  __CPROVER_assert(
      result == 0 ||
          result == MLK_ERR_OUT_OF_MEMORY,
      "PKCHECK-T1R3.CANONICAL_ACCEPTANCE: every canonical polynomial-vector encoding is accepted unless allocation fails");

  __CPROVER_cover(
      result == 0);
}
