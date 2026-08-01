#include <cbmc.h>
#include <stddef.h>
#include <stdint.h>

#include "kem.h"
#include "params.h"

static int t4_check_pk_calls;

/*
 * Deliberate lower-function stub for this control-flow theorem.
 * The production mlk_kem_enc_derand body remains concrete.
 *
 * The frozen CBMC configuration has no application-context parameter,
 * so the internal symbol has the one-argument signature below.
 */
int mlk_check_pk(const uint8_t pk[MLKEM_INDCCA_PUBLICKEYBYTES])
{
  (void)pk;
  t4_check_pk_calls++;
  return MLK_ERR_FAIL;
}

void harness(void)
{
  uint8_t ct[MLKEM_INDCCA_CIPHERTEXTBYTES];
  uint8_t ss[MLKEM_SSBYTES];
  uint8_t pk[MLKEM_INDCCA_PUBLICKEYBYTES];
  uint8_t coins[MLKEM_SYMBYTES];

  size_t ct_index;
  size_t ss_index;
  size_t pk_index;
  size_t coins_index;

  uint8_t ct_before;
  uint8_t ss_before;
  uint8_t pk_before;
  uint8_t coins_before;
  int result;

  __CPROVER_assume(ct_index < MLKEM_INDCCA_CIPHERTEXTBYTES);
  __CPROVER_assume(ss_index < MLKEM_SSBYTES);
  __CPROVER_assume(pk_index < MLKEM_INDCCA_PUBLICKEYBYTES);
  __CPROVER_assume(coins_index < MLKEM_SYMBYTES);

  ct_before = ct[ct_index];
  ss_before = ss[ss_index];
  pk_before = pk[pk_index];
  coins_before = coins[coins_index];

  t4_check_pk_calls = 0;

  result = mlk_kem_enc_derand(ct, ss, pk, coins, NULL);

  __CPROVER_assert(
    t4_check_pk_calls <= 1,
    "PKCHECK-T4.CHECK_AT_MOST_ONCE: public-key validation executes at most once");

  __CPROVER_assert(
    (t4_check_pk_calls == 0 && result == MLK_ERR_OUT_OF_MEMORY) ||
      (t4_check_pk_calls == 1 && result == MLK_ERR_FAIL),
    "PKCHECK-T4.GUARD_RESULT_SPLIT: allocation failure precedes validation, otherwise validation failure is propagated");

  __CPROVER_assert(
    ct[ct_index] == ct_before,
    "PKCHECK-T4.CIPHERTEXT_FRAME: pre-validation exit preserves every ciphertext-output byte");

  __CPROVER_assert(
    ss[ss_index] == ss_before,
    "PKCHECK-T4.SHARED_SECRET_FRAME: pre-validation exit preserves every shared-secret-output byte");

  __CPROVER_assert(
    pk[pk_index] == pk_before,
    "PKCHECK-T4.PUBLIC_KEY_FRAME: pre-validation exit preserves every public-key byte");

  __CPROVER_assert(
    coins[coins_index] == coins_before,
    "PKCHECK-T4.COINS_FRAME: pre-validation exit preserves every coins byte");

  __CPROVER_cover(t4_check_pk_calls == 1);
}
