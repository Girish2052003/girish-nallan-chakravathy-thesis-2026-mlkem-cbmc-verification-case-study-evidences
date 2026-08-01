#!/usr/bin/env bash
#
# PFB-04F — PFB-T4 two-sided raw-domain bijection final campaign.
#
# Frozen obligations:
#   PFB-T4.P1 — For arbitrary 384 input bytes:
#                real mlk_poly_frombytes decode followed by an independent
#                arithmetic raw encoder reproduces every original byte.
#
#   PFB-T4.P2 — For an arbitrary raw polynomial with every coefficient in
#                [0, 4096):
#                independent arithmetic raw encoding followed by the real
#                mlk_poly_frombytes path reproduces every coefficient.
#
# The independent encoder uses division and remainder:
#   c0 = x mod 256
#   c1 = floor(x / 256) + 16 * (y mod 16)
#   c2 = floor(y / 16)
#
# It never calls mlk_poly_tobytes or mlk_poly_frombytes inside an oracle.
# The authoritative source and all prior proof artifacts remain unchanged.

set -uo pipefail
umask 022

ROOT="$HOME/THESIS-2026"
AUTH="$ROOT/mlkem-native_af4c5abd"
WT="$ROOT/_cbmc_work/mlkem-native_pfb_af4c5abd"
CAMPAIGN="$ROOT/mlk_poly_frombytes_cleanroom"
FREEZE_00C="$CAMPAIGN/PFB_00C_THEOREM_FREEZE_af4c5abd"

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_TREE="54805daff6a91a010c05467ea678117c42a71559"

EXPECTED_COMPRESS_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESS_H_SHA256="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"
EXPECTED_PARAMS_SHA256="450fe3e0e50496921920473ae4321660f178c23d51f1453f3c537ee63c4158cb"

EXPECTED_T1_HARNESS_SHA256="9a3288855782f7aee718d51c7904608763bd480635a63d25cd05956d408007a8"
EXPECTED_T1_MAKEFILE_SHA256="9e56741090a6634baddbe2ea9fe13637bbeed9a1ce62f93e2f228185cfe41526"
EXPECTED_T1_GOTO_SHA256="13dd5ba4e64b4dd3c54a3d4e7c82ec0e3c1b09a397584cfa1a13309f60ceeb83"

EXPECTED_T2_BIT_HARNESS_SHA256="7cd0a8e512283677d3a191e0a714bca7f0b481600b3905ef4f3759ab4b1f9aff"
EXPECTED_T2_BIT_MAKEFILE_SHA256="52c8a9b74ed60073766822d0ace381d6bf0b61c0e0da596e488e86122d982ad0"
EXPECTED_T2_BIT_GOTO_SHA256="7e379a693c5c4050751e2f4f7ee695a812016bc20be03fe042818c37713fb7ef"

EXPECTED_T2_LOCAL_HARNESS_SHA256="b52a5e2eefe10204563539c38cc9332d7571ca99ec785c887b3c407488120dfd"
EXPECTED_T2_LOCAL_MAKEFILE_SHA256="bc967aa5116b4c81c6abb192ac7f1d736e682f0bd21d8f83bf6300287482afc6"
EXPECTED_T2_LOCAL_GOTO_SHA256="4e0b7038eadd97d8c4efac19cb0d090f00cd8349cae1b6b98f19b538486c74fe"

T1_PROOF="$WT/proofs/cbmc/pfb_t1_exact_raw_decode"
T1_HARNESS="$T1_PROOF/pfb_t1_exact_raw_decode_harness.c"
T1_MAKEFILE="$T1_PROOF/Makefile"
T1_GOTO="$T1_PROOF/gotos/pfb_t1_exact_raw_decode_harness.goto"

T2_BIT_PROOF="$WT/proofs/cbmc/pfb_t2_bit_routes"
T2_BIT_HARNESS="$T2_BIT_PROOF/pfb_t2_bit_routes_harness.c"
T2_BIT_MAKEFILE="$T2_BIT_PROOF/Makefile"
T2_BIT_GOTO="$T2_BIT_PROOF/gotos/pfb_t2_bit_routes_harness.goto"

T2_LOCAL_PROOF="$WT/proofs/cbmc/pfb_t2_block_locality"
T2_LOCAL_HARNESS="$T2_LOCAL_PROOF/pfb_t2_block_locality_harness.c"
T2_LOCAL_MAKEFILE="$T2_LOCAL_PROOF/Makefile"
T2_LOCAL_GOTO="$T2_LOCAL_PROOF/gotos/pfb_t2_block_locality_harness.goto"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

P1_UID="pfb_t4_bytes_roundtrip_${STAMP}"
P1_PROOF="$WT/proofs/cbmc/$P1_UID"
P1_HARNESS="$P1_PROOF/${P1_UID}_harness.c"
P1_MAKEFILE="$P1_PROOF/Makefile"
P1_GOTO="$P1_PROOF/gotos/${P1_UID}_harness.goto"

P2_UID="pfb_t4_raw_poly_roundtrip_${STAMP}"
P2_PROOF="$WT/proofs/cbmc/$P2_UID"
P2_HARNESS="$P2_PROOF/${P2_UID}_harness.c"
P2_MAKEFILE="$P2_PROOF/Makefile"
P2_GOTO="$P2_PROOF/gotos/${P2_UID}_harness.goto"

CONTROL_UID="pfb_t4_nonvacuity_${STAMP}"
CONTROL_PROOF="$WT/proofs/cbmc/$CONTROL_UID"
CONTROL_HARNESS="$CONTROL_PROOF/${CONTROL_UID}_harness.c"
CONTROL_MAKEFILE="$CONTROL_PROOF/Makefile"
CONTROL_GOTO="$CONTROL_PROOF/gotos/${CONTROL_UID}_harness.goto"

RUN="$CAMPAIGN/PFB_04F_T4_FINAL_RUN_${STAMP}"
FINAL_FREEZE="$CAMPAIGN/PFB_T4_FINAL_FREEZE_af4c5abd_${STAMP}"
FINAL_ARCHIVE="${FINAL_FREEZE}.tar.gz"
OUT="/tmp/PFB_04F_T4_FINAL_RUN.txt"

mkdir -p \
  "$RUN/binding" \
  "$RUN/p1_bytes_roundtrip" \
  "$RUN/p2_raw_poly_roundtrip" \
  "$RUN/control" \
  "$RUN/mutants" \
  "$RUN/source_binding"

exec > >(tee "$OUT") 2>&1

fail()
{
  echo "FATAL_FAILURE=$1"
  echo "PFB_T4_FINAL_ACCEPTANCE=NO"
  echo "SCRIPT_FINAL_EXIT=1"
  exit 1
}

require_command()
{
  command -v "$1" >/dev/null 2>&1 || fail "COMMAND_NOT_FOUND_$1"
}

for cmd in \
  git sha256sum python3 goto-instrument cbmc make timeout grep awk \
  stat tar find sort xargs cp diff
do
  require_command "$cmd"
done

latest_directory()
{
  local base="$1"
  local pattern="$2"

  find "$base" \
    -maxdepth 1 \
    -type d \
    -name "$pattern" \
    -printf '%T@ %p\n' |
  sort -nr |
  head -n 1 |
  cut -d' ' -f2-
}

read_value()
{
  local file="$1"
  local key="$2"

  awk -F= -v wanted="$key" '
    $1 == wanted {
      sub(/^[^=]*=/, "")
      print
      exit
    }
  ' "$file" 2>/dev/null
}

T1_FINAL_FREEZE="$(latest_directory "$CAMPAIGN" 'PFB_T1_FINAL_FREEZE_af4c5abd_*')"
T2_FINAL_FREEZE="$(latest_directory "$CAMPAIGN" 'PFB_T2_FINAL_FREEZE_af4c5abd_*')"
T3_FINAL_FREEZE="$(latest_directory "$CAMPAIGN" 'PFB_T3_FINAL_FREEZE_af4c5abd_*')"
T3_PROOF="$(latest_directory "$WT/proofs/cbmc" 'pfb_t3_differential_*')"

[ -n "$T1_FINAL_FREEZE" ] || fail "PFB_T1_FINAL_FREEZE_NOT_FOUND"
[ -n "$T2_FINAL_FREEZE" ] || fail "PFB_T2_FINAL_FREEZE_NOT_FOUND"
[ -n "$T3_FINAL_FREEZE" ] || fail "PFB_T3_FINAL_FREEZE_NOT_FOUND"
[ -n "$T3_PROOF" ] || fail "PFB_T3_LIVE_PROOF_NOT_FOUND"

T3_UID="$(basename "$T3_PROOF")"
T3_HARNESS="$T3_PROOF/${T3_UID}_harness.c"
T3_MAKEFILE="$T3_PROOF/Makefile"
T3_GOTO="$T3_PROOF/gotos/${T3_UID}_harness.goto"
T3_SOURCE_IDENTITY="$T3_FINAL_FREEZE/source_binding/SOURCE_IDENTITY.txt"

[ -f "$T3_SOURCE_IDENTITY" ] || fail "PFB_T3_SOURCE_IDENTITY_NOT_FOUND"

EXPECTED_T3_HARNESS_SHA256="$(
  read_value "$T3_SOURCE_IDENTITY" THEOREM_HARNESS_SHA256
)"
EXPECTED_T3_MAKEFILE_SHA256="$(
  read_value "$T3_SOURCE_IDENTITY" THEOREM_MAKEFILE_SHA256
)"
EXPECTED_T3_GOTO_SHA256="$(
  read_value "$T3_SOURCE_IDENTITY" THEOREM_GOTO_SHA256
)"

[ -n "$EXPECTED_T3_HARNESS_SHA256" ] || fail "T3_HARNESS_HASH_NOT_RECORDED"
[ -n "$EXPECTED_T3_MAKEFILE_SHA256" ] || fail "T3_MAKEFILE_HASH_NOT_RECORDED"
[ -n "$EXPECTED_T3_GOTO_SHA256" ] || fail "T3_GOTO_HASH_NOT_RECORDED"

echo "============================================================"
echo "PFB-04F — T4 TWO-SIDED RAW-DOMAIN BIJECTION FINAL CAMPAIGN"
echo "============================================================"
echo "STARTED_AT_UTC=$STAMP"
echo "RUN_DIRECTORY=$RUN"
echo "PFB_T1_FINAL_FREEZE=$T1_FINAL_FREEZE"
echo "PFB_T2_FINAL_FREEZE=$T2_FINAL_FREEZE"
echo "PFB_T3_FINAL_FREEZE=$T3_FINAL_FREEZE"
echo "PFB_T3_LIVE_PROOF=$T3_PROOF"
echo "FINAL_FREEZE_DIRECTORY=$FINAL_FREEZE"
echo "FINAL_ARCHIVE=$FINAL_ARCHIVE"
echo "TERMINAL_OUTPUT=$OUT"

echo
echo "============================================================"
echo "PART 1 — FROZEN INTENT AND PRIOR FINAL-EVIDENCE RE-BINDING"
echo "============================================================"

[ -d "$FREEZE_00C" ] || fail "PFB_00C_FREEZE_ABSENT"

(
  cd "$FREEZE_00C" || exit 1
  sha256sum -c SHA256SUMS.txt
) || fail "PFB_00C_HASH_CHECK_FAILED"

(
  cd "$T1_FINAL_FREEZE" || exit 1
  sha256sum -c SHA256SUMS.txt
) || fail "PFB_T1_FINAL_HASH_CHECK_FAILED"

(
  cd "$T2_FINAL_FREEZE" || exit 1
  sha256sum -c SHA256SUMS.txt
) || fail "PFB_T2_FINAL_HASH_CHECK_FAILED"

(
  cd "$T3_FINAL_FREEZE" || exit 1
  sha256sum -c SHA256SUMS.txt
) || fail "PFB_T3_FINAL_HASH_CHECK_FAILED"

grep -Fq '"PFB-T4.P1"' "$FREEZE_00C/registry/verification_intent.json" ||
  fail "PFB_T4_P1_NOT_FROZEN"
grep -Fq '"PFB-T4.P2"' "$FREEZE_00C/registry/verification_intent.json" ||
  fail "PFB_T4_P2_NOT_FROZEN"

grep -Fxq 'PFB_T1_FINAL_ACCEPTANCE=YES' \
  "$T1_FINAL_FREEZE/PFB_T1_FINAL_ACCEPTANCE_REPORT.txt" ||
  fail "PFB_T1_FINAL_ACCEPTANCE_GATE_FAILED"

grep -Fxq 'PFB_T2_FINAL_ACCEPTANCE=YES' \
  "$T2_FINAL_FREEZE/PFB_T2_FINAL_ACCEPTANCE_REPORT.txt" ||
  fail "PFB_T2_FINAL_ACCEPTANCE_GATE_FAILED"

grep -Fxq 'PFB_T3_FINAL_ACCEPTANCE=YES' \
  "$T3_FINAL_FREEZE/PFB_T3_FINAL_ACCEPTANCE_REPORT.txt" ||
  fail "PFB_T3_FINAL_ACCEPTANCE_GATE_FAILED"

echo "PFB_00C_HASH_CHECK=PASS"
echo "PFB_T1_FINAL_HASH_CHECK=PASS"
echo "PFB_T2_FINAL_HASH_CHECK=PASS"
echo "PFB_T3_FINAL_HASH_CHECK=PASS"
echo "PFB_T1_FINAL_ACCEPTANCE_REBOUND=YES"
echo "PFB_T2_FINAL_ACCEPTANCE_REBOUND=YES"
echo "PFB_T3_FINAL_ACCEPTANCE_REBOUND=YES"
echo "FROZEN_INTENT_AND_PRIOR_EVIDENCE_BINDING=PASS"

echo
echo "============================================================"
echo "PART 2 — IMMUTABLE SOURCE AND PRIOR LIVE-ARTIFACT BINDING"
echo "============================================================"

AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null)" ||
  fail "AUTHORITATIVE_HEAD_READ_FAILED"
AUTH_TREE="$(git -C "$AUTH" rev-parse 'HEAD^{tree}' 2>/dev/null)" ||
  fail "AUTHORITATIVE_TREE_READ_FAILED"
WT_HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null)" ||
  fail "WORKTREE_HEAD_READ_FAILED"
WT_TREE="$(git -C "$WT" rev-parse 'HEAD^{tree}' 2>/dev/null)" ||
  fail "WORKTREE_TREE_READ_FAILED"

echo "AUTHORITATIVE_HEAD=$AUTH_HEAD"
echo "AUTHORITATIVE_TREE=$AUTH_TREE"
echo "WORKTREE_HEAD=$WT_HEAD"
echo "WORKTREE_TREE=$WT_TREE"

[ "$AUTH_HEAD" = "$EXPECTED_COMMIT" ] || fail "AUTHORITATIVE_COMMIT_MISMATCH"
[ "$AUTH_TREE" = "$EXPECTED_TREE" ] || fail "AUTHORITATIVE_TREE_MISMATCH"
[ "$WT_HEAD" = "$EXPECTED_COMMIT" ] || fail "WORKTREE_COMMIT_MISMATCH"
[ "$WT_TREE" = "$EXPECTED_TREE" ] || fail "WORKTREE_TREE_MISMATCH"
[ -z "$(git -C "$AUTH" status --porcelain=v1)" ] ||
  fail "AUTHORITATIVE_TREE_DIRTY"

bind_hash()
{
  local label="$1"
  local file="$2"
  local expected="$3"
  local actual

  [ -f "$file" ] || fail "MISSING_${label}"
  actual="$(sha256sum "$file" | awk '{print $1}')"
  echo "${label}_SHA256=$actual"
  [ "$actual" = "$expected" ] || fail "HASH_MISMATCH_${label}"
}

bind_hash "COMPRESS_SOURCE" "$WT/mlkem/src/compress.c" "$EXPECTED_COMPRESS_SHA256"
bind_hash "COMPRESS_HEADER" "$WT/mlkem/src/compress.h" "$EXPECTED_COMPRESS_H_SHA256"
bind_hash "PARAMS_HEADER" "$WT/mlkem/src/params.h" "$EXPECTED_PARAMS_SHA256"

bind_hash "T1_HARNESS" "$T1_HARNESS" "$EXPECTED_T1_HARNESS_SHA256"
bind_hash "T1_MAKEFILE" "$T1_MAKEFILE" "$EXPECTED_T1_MAKEFILE_SHA256"
bind_hash "T1_GOTO" "$T1_GOTO" "$EXPECTED_T1_GOTO_SHA256"

bind_hash "T2_BIT_HARNESS" "$T2_BIT_HARNESS" "$EXPECTED_T2_BIT_HARNESS_SHA256"
bind_hash "T2_BIT_MAKEFILE" "$T2_BIT_MAKEFILE" "$EXPECTED_T2_BIT_MAKEFILE_SHA256"
bind_hash "T2_BIT_GOTO" "$T2_BIT_GOTO" "$EXPECTED_T2_BIT_GOTO_SHA256"

bind_hash "T2_LOCAL_HARNESS" "$T2_LOCAL_HARNESS" "$EXPECTED_T2_LOCAL_HARNESS_SHA256"
bind_hash "T2_LOCAL_MAKEFILE" "$T2_LOCAL_MAKEFILE" "$EXPECTED_T2_LOCAL_MAKEFILE_SHA256"
bind_hash "T2_LOCAL_GOTO" "$T2_LOCAL_GOTO" "$EXPECTED_T2_LOCAL_GOTO_SHA256"

bind_hash "T3_HARNESS" "$T3_HARNESS" "$EXPECTED_T3_HARNESS_SHA256"
bind_hash "T3_MAKEFILE" "$T3_MAKEFILE" "$EXPECTED_T3_MAKEFILE_SHA256"
bind_hash "T3_GOTO" "$T3_GOTO" "$EXPECTED_T3_GOTO_SHA256"

echo "IMMUTABLE_SOURCE_AND_PRIOR_ARTIFACT_BINDING=PASS"

derive_makefile()
{
  local destination="$1"
  local harness_name="$2"
  local proof_uid="$3"

  cp "$T1_MAKEFILE" "$destination"

  python3 - "$destination" "$harness_name" "$proof_uid" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
harness_name = sys.argv[2]
proof_uid = sys.argv[3]
text = path.read_text(encoding="utf-8")

replacements = [
    (
        "HARNESS_FILE = pfb_t1_exact_raw_decode_harness",
        f"HARNESS_FILE = {harness_name}",
    ),
    (
        "PROOF_UID = pfb_t1_exact_raw_decode",
        f"PROOF_UID = {proof_uid}",
    ),
    (
        "CBMCFLAGS=--bitwuzla",
        "CBMCFLAGS=",
    ),
]

for old, new in replacements:
    count = text.count(old)
    print(f"MAKEFILE_REPLACEMENT_COUNT[{old}]={count}")
    if count != 1:
        raise SystemExit(
            f"Expected one occurrence of {old!r}, found {count}"
        )
    text = text.replace(old, new, 1)

unwind_count = text.count("--unwind 129")
print(f"MAKEFILE_UNWIND_REPLACEMENT_COUNT={unwind_count}")
if unwind_count != 4:
    raise SystemExit(
        f"Expected four inherited unwind settings, found {unwind_count}"
    )

text = text.replace("--unwind 129", "--unwind 257")
path.write_text(text, encoding="utf-8")
PY
}

echo
echo "============================================================"
echo "PART 3 — CREATE AND AUDIT PFB-T4.P1 BYTE-ROUNDTRIP HARNESS"
echo "============================================================"

[ ! -e "$P1_PROOF" ] || fail "P1_PROOF_DIRECTORY_ALREADY_EXISTS"
mkdir -p "$P1_PROOF"

cat > "$P1_HARNESS" <<'EOF_P1'
#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T4.P1 — arbitrary bytes -> real decoder -> independent raw encoder.
 *
 * The independent encoder uses only widened division and remainder. It does
 * not call mlk_poly_tobytes, mlk_poly_frombytes, or copy the decoder's
 * mask/shift expressions. An arbitrary byte index makes the assertion cover
 * all MLKEM_POLYBYTES bytes.
 */
void harness(void)
{
  uint8_t input[MLKEM_POLYBYTES];
  uint8_t recovered[MLKEM_POLYBYTES];

  mlk_poly decoded;

  size_t byte_index;
  uint32_t block_index;
  uint32_t x;
  uint32_t y;

  __CPROVER_assume(byte_index < MLKEM_POLYBYTES);

  mlk_poly_frombytes(&decoded, input);

  for (block_index = 0u;
       block_index < (MLKEM_N / 2u);
       block_index++)
  {
    x =
        (uint32_t)(uint16_t)
            decoded.coeffs[2u * block_index];
    y =
        (uint32_t)(uint16_t)
            decoded.coeffs[2u * block_index + 1u];

    recovered[3u * block_index] =
        (uint8_t)(x % UINT32_C(256));

    recovered[3u * block_index + 1u] =
        (uint8_t)(
            (x / UINT32_C(256)) +
            UINT32_C(16) * (y % UINT32_C(16)));

    recovered[3u * block_index + 2u] =
        (uint8_t)(y / UINT32_C(16));
  }

  __CPROVER_assert(
      recovered[byte_index] == input[byte_index],
      "PFB-T4.P1 arbitrary bytes survive decode and independent raw encode");
}
EOF_P1

derive_makefile "$P1_MAKEFILE" "${P1_UID}_harness" "$P1_UID" ||
  fail "P1_MAKEFILE_DERIVATION_FAILED"

P1_HARNESS_SHA256="$(sha256sum "$P1_HARNESS" | awk '{print $1}')"
P1_MAKEFILE_SHA256="$(sha256sum "$P1_MAKEFILE" | awk '{print $1}')"
P1_PUBLIC_CALL_COUNT="$(
  grep -Ec '^[[:space:]]*mlk_poly_frombytes\(' "$P1_HARNESS" || true
)"
P1_ASSERTION_COUNT="$(
  grep -c '__CPROVER_assert' "$P1_HARNESS" || true
)"
P1_ASSUME_COUNT="$(
  grep -c '__CPROVER_assume' "$P1_HARNESS" || true
)"

echo "P1_HARNESS_SHA256=$P1_HARNESS_SHA256"
echo "P1_MAKEFILE_SHA256=$P1_MAKEFILE_SHA256"
echo "P1_PUBLIC_CALL_COUNT=$P1_PUBLIC_CALL_COUNT"
echo "P1_ASSERTION_COUNT=$P1_ASSERTION_COUNT"
echo "P1_ASSUME_COUNT=$P1_ASSUME_COUNT"

[ "$P1_PUBLIC_CALL_COUNT" = "1" ] || fail "P1_PUBLIC_CALL_COUNT_WRONG"
[ "$P1_ASSERTION_COUNT" = "1" ] || fail "P1_ASSERTION_COUNT_WRONG"
[ "$P1_ASSUME_COUNT" = "1" ] || fail "P1_ASSUME_COUNT_WRONG"

if grep -Eq '(^|[^[:alnum:]_])mlk_poly_tobytes[[:space:]]*\(' "$P1_HARNESS"; then
  fail "P1_PRODUCTION_ENCODER_USED"
fi

if grep -Fq 'mlk_poly_frombytes_c(' "$P1_HARNESS"; then
  fail "P1_PORTABLE_BODY_CALLED_DIRECTLY"
fi

if grep -Eq \
  '\&[[:space:]]*0xFFF|<<[[:space:]]*8|>>[[:space:]]*4|<<[[:space:]]*4' \
  "$P1_HARNESS"
then
  fail "P1_COPIED_DECODER_EXPRESSION_PRESENT"
fi

cp "$P1_HARNESS" "$RUN/p1_bytes_roundtrip/"
cp "$P1_MAKEFILE" "$RUN/p1_bytes_roundtrip/Makefile"

echo "PFB_T4_P1_HARNESS_AUDIT=PASS"

echo
echo "============================================================"
echo "PART 4 — CREATE AND AUDIT PFB-T4.P2 RAW-POLY ROUNDTRIP HARNESS"
echo "============================================================"

[ ! -e "$P2_PROOF" ] || fail "P2_PROOF_DIRECTORY_ALREADY_EXISTS"
mkdir -p "$P2_PROOF"

cat > "$P2_HARNESS" <<'EOF_P2'
#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T4.P2 — arbitrary raw polynomial -> independent raw encoder ->
 * real decoder.
 *
 * Every source coefficient is restricted only to the frozen raw domain
 * [0, 4096). The independent encoder uses widened division and remainder.
 * An arbitrary coefficient index makes the assertion cover all MLKEM_N
 * coefficients.
 */
void harness(void)
{
  mlk_poly raw_input;
  mlk_poly decoded;

  uint8_t encoded[MLKEM_POLYBYTES];

  size_t coeff_index;
  uint32_t index;
  uint32_t block_index;
  uint32_t x;
  uint32_t y;

  __CPROVER_assume(coeff_index < MLKEM_N);

  for (index = 0u; index < MLKEM_N; index++)
  {
    __CPROVER_assume(raw_input.coeffs[index] >= 0);
    __CPROVER_assume(
        (uint16_t)raw_input.coeffs[index] < UINT16_C(4096));
  }

  for (block_index = 0u;
       block_index < (MLKEM_N / 2u);
       block_index++)
  {
    x =
        (uint32_t)(uint16_t)
            raw_input.coeffs[2u * block_index];
    y =
        (uint32_t)(uint16_t)
            raw_input.coeffs[2u * block_index + 1u];

    encoded[3u * block_index] =
        (uint8_t)(x % UINT32_C(256));

    encoded[3u * block_index + 1u] =
        (uint8_t)(
            (x / UINT32_C(256)) +
            UINT32_C(16) * (y % UINT32_C(16)));

    encoded[3u * block_index + 2u] =
        (uint8_t)(y / UINT32_C(16));
  }

  mlk_poly_frombytes(&decoded, encoded);

  __CPROVER_assert(
      decoded.coeffs[coeff_index] ==
          raw_input.coeffs[coeff_index],
      "PFB-T4.P2 arbitrary raw polynomial survives independent encode and real decode");
}
EOF_P2

derive_makefile "$P2_MAKEFILE" "${P2_UID}_harness" "$P2_UID" ||
  fail "P2_MAKEFILE_DERIVATION_FAILED"

P2_HARNESS_SHA256="$(sha256sum "$P2_HARNESS" | awk '{print $1}')"
P2_MAKEFILE_SHA256="$(sha256sum "$P2_MAKEFILE" | awk '{print $1}')"
P2_PUBLIC_CALL_COUNT="$(
  grep -Ec '^[[:space:]]*mlk_poly_frombytes\(' "$P2_HARNESS" || true
)"
P2_ASSERTION_COUNT="$(
  grep -c '__CPROVER_assert' "$P2_HARNESS" || true
)"
P2_ASSUME_COUNT="$(
  grep -c '__CPROVER_assume' "$P2_HARNESS" || true
)"

echo "P2_HARNESS_SHA256=$P2_HARNESS_SHA256"
echo "P2_MAKEFILE_SHA256=$P2_MAKEFILE_SHA256"
echo "P2_PUBLIC_CALL_COUNT=$P2_PUBLIC_CALL_COUNT"
echo "P2_ASSERTION_COUNT=$P2_ASSERTION_COUNT"
echo "P2_ASSUME_COUNT=$P2_ASSUME_COUNT"

[ "$P2_PUBLIC_CALL_COUNT" = "1" ] || fail "P2_PUBLIC_CALL_COUNT_WRONG"
[ "$P2_ASSERTION_COUNT" = "1" ] || fail "P2_ASSERTION_COUNT_WRONG"
[ "$P2_ASSUME_COUNT" = "3" ] || fail "P2_ASSUME_COUNT_WRONG"

if grep -Eq '(^|[^[:alnum:]_])mlk_poly_tobytes[[:space:]]*\(' "$P2_HARNESS"; then
  fail "P2_PRODUCTION_ENCODER_USED"
fi

if grep -Fq 'mlk_poly_frombytes_c(' "$P2_HARNESS"; then
  fail "P2_PORTABLE_BODY_CALLED_DIRECTLY"
fi

if grep -Eq \
  '\&[[:space:]]*0xFFF|<<[[:space:]]*8|>>[[:space:]]*4|<<[[:space:]]*4' \
  "$P2_HARNESS"
then
  fail "P2_COPIED_DECODER_EXPRESSION_PRESENT"
fi

cp "$P2_HARNESS" "$RUN/p2_raw_poly_roundtrip/"
cp "$P2_MAKEFILE" "$RUN/p2_raw_poly_roundtrip/Makefile"

echo "PFB_T4_P2_HARNESS_AUDIT=PASS"

COMMON_FLAGS=(
  --flush
  --object-bits 8
  --slice-formula
  --unwind 257
  --unwinding-assertions
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --undefined-shift-check
  --div-by-zero-check
  --float-overflow-check
  --nan-check
)

parse_xml()
{
  local xml="$1"
  local summary="$2"
  local expected_assertions="$3"

  python3 - "$xml" "$summary" "$expected_assertions" <<'PY'
from __future__ import annotations

import collections
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

xml_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
expected_assertions = int(sys.argv[3])

values = {
    "XML_PARSE": "FAIL",
    "CPROVER_STATUS": "NONE",
    "PROPERTY_COUNT": "0",
    "SUCCESS_COUNT": "0",
    "FAILURE_COUNT": "0",
    "ERROR_COUNT": "0",
    "UNKNOWN_COUNT": "0",
    "NON_SUCCESS_COUNT": "0",
}

for number in range(1, expected_assertions + 1):
    values[f"H{number}_STATUS"] = "ABSENT"

try:
    root = ET.parse(xml_path).getroot()

    def local_name(tag: str) -> str:
        return tag.rsplit("}", 1)[-1]

    results = [
        element
        for element in root.iter()
        if local_name(element.tag) == "result"
    ]

    counts = collections.Counter(
        element.attrib.get("status", "MISSING")
        for element in results
    )

    statuses = {
        element.attrib.get("property", ""):
            element.attrib.get("status", "MISSING")
        for element in results
    }

    cprover_nodes = [
        " ".join((element.text or "").split())
        for element in root.iter()
        if local_name(element.tag) == "cprover-status"
    ]

    values["XML_PARSE"] = "PASS"
    values["CPROVER_STATUS"] = (
        "|".join(cprover_nodes) if cprover_nodes else "NONE"
    )
    values["PROPERTY_COUNT"] = str(len(results))
    values["SUCCESS_COUNT"] = str(counts.get("SUCCESS", 0))
    values["FAILURE_COUNT"] = str(counts.get("FAILURE", 0))
    values["ERROR_COUNT"] = str(counts.get("ERROR", 0))
    values["UNKNOWN_COUNT"] = str(counts.get("UNKNOWN", 0))
    values["NON_SUCCESS_COUNT"] = str(
        sum(
            1
            for result in results
            if result.attrib.get("status") != "SUCCESS"
        )
    )

    for number in range(1, expected_assertions + 1):
        values[f"H{number}_STATUS"] = statuses.get(
            f"harness.assertion.{number}",
            "ABSENT",
        )

except Exception as exc:
    print(f"XML_PARSE_EXCEPTION={exc!r}")

summary_path.write_text(
    "".join(f"{key}={value}\n" for key, value in values.items()),
    encoding="utf-8",
)

for key, value in values.items():
    print(f"{key}={value}")
PY
}

build_and_bind()
{
  local name="$1"
  local proof="$2"
  local goto_file="$3"

  set +e
  make -C "$proof" -j1 \
    > "$RUN/$name/make.stdout.txt" \
    2> "$RUN/$name/make.stderr.txt"
  local make_exit=$?
  set -e 2>/dev/null || true

  echo "MAKE_EXIT[$name]=$make_exit"
  echo "----- MAKE STDOUT TAIL[$name] -----"
  tail -n 80 "$RUN/$name/make.stdout.txt" || true
  echo "----- MAKE STDERR TAIL[$name] -----"
  tail -n 80 "$RUN/$name/make.stderr.txt" || true

  [ -f "$goto_file" ] || fail "GOTO_NOT_CREATED_$name"

  echo "GOTO_SHA256[$name]=$(
    sha256sum "$goto_file" | awk '{print $1}'
  )"

  goto-instrument \
    --show-goto-functions \
    "$goto_file" \
    > "$RUN/binding/${name}.goto_functions.txt" \
    2> "$RUN/binding/${name}.goto_functions.stderr.txt" ||
    fail "GOTO_DUMP_FAILED_$name"

  local public_calls
  local portable_calls

  public_calls="$(
    grep -c 'CALL mlk_poly_frombytes(' \
      "$RUN/binding/${name}.goto_functions.txt" || true
  )"
  portable_calls="$(
    grep -c 'CALL mlk_poly_frombytes_c(' \
      "$RUN/binding/${name}.goto_functions.txt" || true
  )"

  echo "GOTO_PUBLIC_WRAPPER_CALL_COUNT[$name]=$public_calls"
  echo "GOTO_PORTABLE_BODY_CALL_COUNT[$name]=$portable_calls"

  [ "$public_calls" -ge 1 ] || fail "PUBLIC_WRAPPER_CALL_ABSENT_$name"
  [ "$portable_calls" -ge 1 ] || fail "PORTABLE_BODY_CALL_ABSENT_$name"

  if grep -Eq \
    'mlk_poly_frombytes_native|MLK_USE_NATIVE_POLY_FROMBYTES' \
    "$RUN/binding/${name}.goto_functions.txt"
  then
    fail "NATIVE_FROMBYTES_PRESENT_$name"
  fi
}

run_baseline()
{
  local name="$1"
  local goto_file="$2"
  local timeout_seconds="$3"
  local property_label="$4"

  local theorem_xml="$RUN/$name/theorem.xml"
  local theorem_stderr="$RUN/$name/theorem.stderr.txt"
  local theorem_summary="$RUN/$name/theorem.summary.txt"
  local theorem_exit

  local all_xml="$RUN/$name/all_properties.xml"
  local all_stderr="$RUN/$name/all_properties.stderr.txt"
  local all_summary="$RUN/$name/all_properties.summary.txt"
  local all_exit

  if timeout \
    --signal=TERM \
    "$timeout_seconds" \
    cbmc \
    "${COMMON_FLAGS[@]}" \
    --property harness.assertion.1 \
    --xml-ui \
    "$goto_file" \
    > "$theorem_xml" \
    2> "$theorem_stderr"
  then
    theorem_exit=0
  else
    theorem_exit=$?
  fi

  echo "CBMC_EXIT[${name}_theorem]=$theorem_exit"
  parse_xml "$theorem_xml" "$theorem_summary" 1

  if timeout \
    --signal=TERM \
    "$timeout_seconds" \
    cbmc \
    "${COMMON_FLAGS[@]}" \
    --xml-ui \
    "$goto_file" \
    > "$all_xml" \
    2> "$all_stderr"
  then
    all_exit=0
  else
    all_exit=$?
  fi

  echo "CBMC_EXIT[${name}_all]=$all_exit"
  parse_xml "$all_xml" "$all_summary" 1

  local theorem_status
  local theorem_non_success
  local theorem_h1
  local all_status
  local all_non_success
  local all_h1
  local all_count
  local all_success

  theorem_status="$(read_value "$theorem_summary" CPROVER_STATUS)"
  theorem_non_success="$(read_value "$theorem_summary" NON_SUCCESS_COUNT)"
  theorem_h1="$(read_value "$theorem_summary" H1_STATUS)"

  all_status="$(read_value "$all_summary" CPROVER_STATUS)"
  all_non_success="$(read_value "$all_summary" NON_SUCCESS_COUNT)"
  all_h1="$(read_value "$all_summary" H1_STATUS)"
  all_count="$(read_value "$all_summary" PROPERTY_COUNT)"
  all_success="$(read_value "$all_summary" SUCCESS_COUNT)"

  [ "$theorem_exit" = "0" ] || fail "THEOREM_EXIT_NONZERO_$name"
  [ "$theorem_status" = "SUCCESS" ] || fail "THEOREM_CPROVER_NOT_SUCCESS_$name"
  [ "$theorem_non_success" = "0" ] || fail "THEOREM_NON_SUCCESS_$name"
  [ "$theorem_h1" = "SUCCESS" ] || fail "${property_label}_NOT_SUCCESS"

  [ "$all_exit" = "0" ] || fail "ALL_EXIT_NONZERO_$name"
  [ "$all_status" = "SUCCESS" ] || fail "ALL_CPROVER_NOT_SUCCESS_$name"
  [ "$all_non_success" = "0" ] || fail "ALL_NON_SUCCESS_$name"
  [ "$all_h1" = "SUCCESS" ] || fail "${property_label}_NOT_SUCCESS_IN_ALL"
  [ "$all_count" = "$all_success" ] || fail "ALL_NOT_COMPLETE_$name"

  echo "${property_label}_STATUS=SUCCESS"
  echo "COMPLETE_PROPERTY_SET[$name]=${all_success}_OF_${all_count}_SUCCESS"

  if [ "$name" = "p1_bytes_roundtrip" ]; then
    P1_ALL_PROPERTY_COUNT="$all_count"
    P1_ALL_SUCCESS_COUNT="$all_success"
  else
    P2_ALL_PROPERTY_COUNT="$all_count"
    P2_ALL_SUCCESS_COUNT="$all_success"
  fi
}

echo
echo "============================================================"
echo "PART 5 — BUILD, BIND, AND PROVE BOTH PFB-T4 OBLIGATIONS"
echo "============================================================"

build_and_bind "p1_bytes_roundtrip" "$P1_PROOF" "$P1_GOTO"
build_and_bind "p2_raw_poly_roundtrip" "$P2_PROOF" "$P2_GOTO"

P1_GOTO_SHA256="$(sha256sum "$P1_GOTO" | awk '{print $1}')"
P2_GOTO_SHA256="$(sha256sum "$P2_GOTO" | awk '{print $1}')"

run_baseline \
  "p1_bytes_roundtrip" \
  "$P1_GOTO" \
  2400 \
  "PFB_T4_P1"

run_baseline \
  "p2_raw_poly_roundtrip" \
  "$P2_GOTO" \
  3600 \
  "PFB_T4_P2"

echo "PFB_T4_P1_BYTES_ROUNDTRIP=PROVED"
echo "PFB_T4_P2_RAW_POLY_ROUNDTRIP=PROVED"
echo "PFB_T4_SEMANTIC_BASELINE=PASS"
echo "PFB_T4_COMPLETE_PROPERTY_RUNS=PASS"

echo
echo "============================================================"
echo "PART 6 — CONCRETE RAW-DOMAIN NONVACUITY CONTROLS"
echo "============================================================"

[ ! -e "$CONTROL_PROOF" ] || fail "CONTROL_PROOF_DIRECTORY_ALREADY_EXISTS"
mkdir -p "$CONTROL_PROOF"

cat > "$CONTROL_HARNESS" <<'EOF_CONTROL'
#include <stdint.h>

#include "compress.h"

static void encode_raw_pair(
    uint8_t *out,
    uint32_t x,
    uint32_t y)
{
  out[0] =
      (uint8_t)(x % UINT32_C(256));

  out[1] =
      (uint8_t)(
          (x / UINT32_C(256)) +
          UINT32_C(16) * (y % UINT32_C(16)));

  out[2] =
      (uint8_t)(y / UINT32_C(16));
}

void harness(void)
{
  uint8_t zero_bytes[MLKEM_POLYBYTES] = {0};
  uint8_t max_boundary_bytes[MLKEM_POLYBYTES] = {0};
  uint8_t encoded_zero[MLKEM_POLYBYTES] = {0};
  uint8_t encoded_max[MLKEM_POLYBYTES] = {0};

  mlk_poly decoded_zero_bytes;
  mlk_poly decoded_max_bytes;
  mlk_poly decoded_raw_zero;
  mlk_poly decoded_raw_max;

  uint32_t first_x;
  uint32_t last_y;

  max_boundary_bytes[0] = UINT8_C(255);
  max_boundary_bytes[1] = UINT8_C(255);
  max_boundary_bytes[2] = UINT8_C(255);

  max_boundary_bytes[MLKEM_POLYBYTES - 3u] = UINT8_C(255);
  max_boundary_bytes[MLKEM_POLYBYTES - 2u] = UINT8_C(255);
  max_boundary_bytes[MLKEM_POLYBYTES - 1u] = UINT8_C(255);

  mlk_poly_frombytes(&decoded_zero_bytes, zero_bytes);
  mlk_poly_frombytes(&decoded_max_bytes, max_boundary_bytes);

  first_x =
      (uint32_t)(uint16_t)decoded_zero_bytes.coeffs[0];

  last_y =
      (uint32_t)(uint16_t)
          decoded_zero_bytes.coeffs[MLKEM_N - 1u];

  __CPROVER_assert(
      (uint8_t)(first_x % UINT32_C(256)) == UINT8_C(0),
      "PFB-T4 control zero-byte first boundary roundtrips");

  __CPROVER_assert(
      (uint8_t)(last_y / UINT32_C(16)) == UINT8_C(0),
      "PFB-T4 control zero-byte last boundary roundtrips");

  first_x =
      (uint32_t)(uint16_t)decoded_max_bytes.coeffs[0];

  last_y =
      (uint32_t)(uint16_t)
          decoded_max_bytes.coeffs[MLKEM_N - 1u];

  __CPROVER_assert(
      (uint8_t)(first_x % UINT32_C(256)) == UINT8_C(255),
      "PFB-T4 control max-byte first boundary roundtrips");

  __CPROVER_assert(
      (uint8_t)(last_y / UINT32_C(16)) == UINT8_C(255),
      "PFB-T4 control max-byte last boundary roundtrips");

  encode_raw_pair(
      &encoded_zero[0],
      UINT32_C(0),
      UINT32_C(0));

  encode_raw_pair(
      &encoded_zero[MLKEM_POLYBYTES - 3u],
      UINT32_C(0),
      UINT32_C(0));

  encode_raw_pair(
      &encoded_max[0],
      UINT32_C(4095),
      UINT32_C(4095));

  encode_raw_pair(
      &encoded_max[MLKEM_POLYBYTES - 3u],
      UINT32_C(4095),
      UINT32_C(4095));

  mlk_poly_frombytes(&decoded_raw_zero, encoded_zero);
  mlk_poly_frombytes(&decoded_raw_max, encoded_max);

  __CPROVER_assert(
      decoded_raw_zero.coeffs[0] == INT16_C(0),
      "PFB-T4 control raw-zero first coefficient roundtrips");

  __CPROVER_assert(
      decoded_raw_zero.coeffs[MLKEM_N - 1u] == INT16_C(0),
      "PFB-T4 control raw-zero last coefficient roundtrips");

  __CPROVER_assert(
      decoded_raw_max.coeffs[0] == INT16_C(4095),
      "PFB-T4 control raw-4095 first coefficient roundtrips");

  __CPROVER_assert(
      decoded_raw_max.coeffs[MLKEM_N - 1u] == INT16_C(4095),
      "PFB-T4 control raw-4095 last coefficient roundtrips");
}
EOF_CONTROL

derive_makefile "$CONTROL_MAKEFILE" "${CONTROL_UID}_harness" "$CONTROL_UID" ||
  fail "CONTROL_MAKEFILE_DERIVATION_FAILED"

CONTROL_HARNESS_SHA256="$(sha256sum "$CONTROL_HARNESS" | awk '{print $1}')"
CONTROL_MAKEFILE_SHA256="$(sha256sum "$CONTROL_MAKEFILE" | awk '{print $1}')"
CONTROL_PUBLIC_CALL_COUNT="$(
  grep -Ec '^[[:space:]]*mlk_poly_frombytes\(' "$CONTROL_HARNESS" || true
)"
CONTROL_ASSERTION_COUNT="$(
  grep -c '__CPROVER_assert' "$CONTROL_HARNESS" || true
)"
CONTROL_ASSUME_COUNT="$(
  grep -c '__CPROVER_assume' "$CONTROL_HARNESS" || true
)"

echo "CONTROL_HARNESS_SHA256=$CONTROL_HARNESS_SHA256"
echo "CONTROL_MAKEFILE_SHA256=$CONTROL_MAKEFILE_SHA256"
echo "CONTROL_PUBLIC_CALL_COUNT=$CONTROL_PUBLIC_CALL_COUNT"
echo "CONTROL_ASSERTION_COUNT=$CONTROL_ASSERTION_COUNT"
echo "CONTROL_ASSUME_COUNT=$CONTROL_ASSUME_COUNT"

[ "$CONTROL_PUBLIC_CALL_COUNT" = "4" ] ||
  fail "CONTROL_PUBLIC_CALL_COUNT_WRONG"
[ "$CONTROL_ASSERTION_COUNT" = "8" ] ||
  fail "CONTROL_ASSERTION_COUNT_WRONG"
[ "$CONTROL_ASSUME_COUNT" = "0" ] ||
  fail "CONTROL_ASSUME_COUNT_WRONG"

if grep -Eq '(^|[^[:alnum:]_])mlk_poly_tobytes[[:space:]]*\(' "$CONTROL_HARNESS"; then
  fail "CONTROL_PRODUCTION_ENCODER_USED"
fi

cp "$CONTROL_HARNESS" "$RUN/control/"
cp "$CONTROL_MAKEFILE" "$RUN/control/Makefile"

set +e
make -C "$CONTROL_PROOF" -j1 \
  > "$RUN/control/make.stdout.txt" \
  2> "$RUN/control/make.stderr.txt"
CONTROL_MAKE_EXIT=$?
set -e 2>/dev/null || true

echo "CONTROL_MAKE_EXIT=$CONTROL_MAKE_EXIT"
[ -f "$CONTROL_GOTO" ] || fail "CONTROL_GOTO_NOT_CREATED"

CONTROL_GOTO_SHA256="$(sha256sum "$CONTROL_GOTO" | awk '{print $1}')"
echo "CONTROL_GOTO_SHA256=$CONTROL_GOTO_SHA256"

goto-instrument \
  --show-goto-functions \
  "$CONTROL_GOTO" \
  > "$RUN/control/goto_functions.txt" \
  2> "$RUN/control/goto_functions.stderr.txt" ||
  fail "CONTROL_GOTO_DUMP_FAILED"

CONTROL_PUBLIC_GOTO_CALLS="$(
  grep -c 'CALL mlk_poly_frombytes(' "$RUN/control/goto_functions.txt" || true
)"
CONTROL_PORTABLE_GOTO_CALLS="$(
  grep -c 'CALL mlk_poly_frombytes_c(' "$RUN/control/goto_functions.txt" || true
)"

echo "CONTROL_GOTO_PUBLIC_CALL_COUNT=$CONTROL_PUBLIC_GOTO_CALLS"
echo "CONTROL_GOTO_PORTABLE_BODY_CALL_COUNT=$CONTROL_PORTABLE_GOTO_CALLS"

[ "$CONTROL_PUBLIC_GOTO_CALLS" -ge 1 ] ||
  fail "CONTROL_PUBLIC_WRAPPER_CALL_ABSENT"
[ "$CONTROL_PORTABLE_GOTO_CALLS" -ge 1 ] ||
  fail "CONTROL_PORTABLE_BODY_CALL_ABSENT"

if timeout \
  --signal=TERM \
  2400 \
  cbmc \
  "${COMMON_FLAGS[@]}" \
  --xml-ui \
  "$CONTROL_GOTO" \
  > "$RUN/control/result.xml" \
  2> "$RUN/control/result.stderr.txt"
then
  CONTROL_CBMC_EXIT=0
else
  CONTROL_CBMC_EXIT=$?
fi

echo "CONTROL_CBMC_EXIT=$CONTROL_CBMC_EXIT"

parse_xml "$RUN/control/result.xml" "$RUN/control/summary.txt" 8

[ "$CONTROL_CBMC_EXIT" = "0" ] || fail "CONTROL_CBMC_EXIT_NONZERO"
[ "$(read_value "$RUN/control/summary.txt" CPROVER_STATUS)" = "SUCCESS" ] ||
  fail "CONTROL_CPROVER_NOT_SUCCESS"
[ "$(read_value "$RUN/control/summary.txt" NON_SUCCESS_COUNT)" = "0" ] ||
  fail "CONTROL_NON_SUCCESS_PRESENT"

for number in 1 2 3 4 5 6 7 8; do
  [ "$(read_value "$RUN/control/summary.txt" "H${number}_STATUS")" = "SUCCESS" ] ||
    fail "CONTROL_ASSERTION_${number}_NOT_SUCCESS"
done

echo "PFB_T4_NONVACUITY_AND_BOUNDARY_CONTROL=PASS"
echo "PFB_T4_CONTROL_ASSERTIONS=8_OF_8_SUCCESS"

echo
echo "============================================================"
echo "PART 7 — TARGETED SOURCE-MUTATION SENSITIVITY"
echo "============================================================"

mutate_exact()
{
  local source_file="$1"
  local old_text="$2"
  local new_text="$3"
  local label="$4"

  python3 - "$source_file" "$old_text" "$new_text" "$label" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
old = sys.argv[2]
new = sys.argv[3]
label = sys.argv[4]

text = path.read_text(encoding="utf-8")
count = text.count(old)
print(f"MUTATION_PATTERN_COUNT[{label}]={count}")

if count != 1:
    raise SystemExit(
        f"Expected one occurrence for {label}, found {count}"
    )

path.write_text(
    text.replace(old, new, 1),
    encoding="utf-8",
)
PY
}

run_mutant()
{
  local mutant_name="$1"
  local source_harness="$2"
  local old_text="$3"
  local new_text="$4"

  local mut_wt="$ROOT/_cbmc_work/mlkem-native_pfb_t4_${mutant_name}_${STAMP}"
  local mut_uid="pfb_t4_${mutant_name}_${STAMP}"
  local mut_proof="$mut_wt/proofs/cbmc/$mut_uid"
  local mut_harness="$mut_proof/${mut_uid}_harness.c"
  local mut_makefile="$mut_proof/Makefile"
  local mut_goto="$mut_proof/gotos/${mut_uid}_harness.goto"
  local mut_record="$RUN/mutants/$mutant_name"

  mkdir -p "$mut_record"

  echo
  echo "---------------- MUTANT=$mutant_name ----------------"

  [ ! -e "$mut_wt" ] || fail "MUTANT_WORKTREE_EXISTS_$mutant_name"

  git -C "$AUTH" worktree add \
    --detach \
    "$mut_wt" \
    "$EXPECTED_COMMIT" \
    > "$mut_record/worktree_add.stdout.txt" \
    2> "$mut_record/worktree_add.stderr.txt" ||
    fail "MUTANT_WORKTREE_ADD_FAILED_$mutant_name"

  mkdir -p "$mut_proof"
  cp "$source_harness" "$mut_harness"

  derive_makefile "$mut_makefile" "${mut_uid}_harness" "$mut_uid" ||
    fail "MUTANT_MAKEFILE_DERIVATION_FAILED_$mutant_name"

  mutate_exact \
    "$mut_wt/mlkem/src/compress.c" \
    "$old_text" \
    "$new_text" \
    "$mutant_name" ||
    fail "MUTATION_APPLICATION_FAILED_$mutant_name"

  echo "MUTANT_SOURCE_SHA256[$mutant_name]=$(
    sha256sum "$mut_wt/mlkem/src/compress.c" | awk '{print $1}'
  )"

  git -C "$mut_wt" diff -- mlkem/src/compress.c \
    > "$mut_record/source.diff"

  echo "MUTATION_DIFF[$mutant_name]_BEGIN"
  cat "$mut_record/source.diff"
  echo "MUTATION_DIFF[$mutant_name]_END"

  [ -s "$mut_record/source.diff" ] ||
    fail "MUTATION_DIFF_EMPTY_$mutant_name"

  set +e
  make -C "$mut_proof" -j1 \
    > "$mut_record/make.stdout.txt" \
    2> "$mut_record/make.stderr.txt"
  local make_exit=$?
  set -e 2>/dev/null || true

  echo "MAKE_EXIT[$mutant_name]=$make_exit"
  [ -f "$mut_goto" ] || fail "MUTANT_GOTO_NOT_CREATED_$mutant_name"

  echo "MUTANT_GOTO_SHA256[$mutant_name]=$(
    sha256sum "$mut_goto" | awk '{print $1}'
  )"

  if timeout \
    --signal=TERM \
    2400 \
    cbmc \
    "${COMMON_FLAGS[@]}" \
    --property harness.assertion.1 \
    --xml-ui \
    "$mut_goto" \
    > "$mut_record/result.xml" \
    2> "$mut_record/result.stderr.txt"
  then
    MUTANT_CBMC_EXIT=0
  else
    MUTANT_CBMC_EXIT=$?
  fi

  echo "MUTANT_CBMC_EXIT[$mutant_name]=$MUTANT_CBMC_EXIT"

  parse_xml "$mut_record/result.xml" "$mut_record/summary.txt" 1

  local cprover
  local property_count
  local failure_count
  local error_count
  local unknown_count
  local non_success
  local h1

  cprover="$(read_value "$mut_record/summary.txt" CPROVER_STATUS)"
  property_count="$(read_value "$mut_record/summary.txt" PROPERTY_COUNT)"
  failure_count="$(read_value "$mut_record/summary.txt" FAILURE_COUNT)"
  error_count="$(read_value "$mut_record/summary.txt" ERROR_COUNT)"
  unknown_count="$(read_value "$mut_record/summary.txt" UNKNOWN_COUNT)"
  non_success="$(read_value "$mut_record/summary.txt" NON_SUCCESS_COUNT)"
  h1="$(read_value "$mut_record/summary.txt" H1_STATUS)"

  echo "MUTANT_RESULT[$mutant_name].CPROVER_STATUS=$cprover"
  echo "MUTANT_RESULT[$mutant_name].PROPERTY_COUNT=$property_count"
  echo "MUTANT_RESULT[$mutant_name].FAILURE_COUNT=$failure_count"
  echo "MUTANT_RESULT[$mutant_name].ERROR_COUNT=$error_count"
  echo "MUTANT_RESULT[$mutant_name].UNKNOWN_COUNT=$unknown_count"
  echo "MUTANT_RESULT[$mutant_name].NON_SUCCESS_COUNT=$non_success"
  echo "MUTANT_RESULT[$mutant_name].H1_STATUS=$h1"

  [ "$MUTANT_CBMC_EXIT" = "10" ] ||
    fail "MUTANT_EXIT_NOT_10_$mutant_name"
  [ "$cprover" = "FAILURE" ] ||
    fail "MUTANT_CPROVER_NOT_FAILURE_$mutant_name"
  [ "$property_count" = "1" ] ||
    fail "MUTANT_PROPERTY_COUNT_WRONG_$mutant_name"
  [ "$failure_count" = "1" ] ||
    fail "MUTANT_FAILURE_COUNT_WRONG_$mutant_name"
  [ "$error_count" = "0" ] ||
    fail "MUTANT_ERROR_PRESENT_$mutant_name"
  [ "$unknown_count" = "0" ] ||
    fail "MUTANT_UNKNOWN_PRESENT_$mutant_name"
  [ "$non_success" = "1" ] ||
    fail "MUTANT_NON_SUCCESS_COUNT_WRONG_$mutant_name"
  [ "$h1" = "FAILURE" ] ||
    fail "MUTANT_ASSERTION_DID_NOT_FAIL_$mutant_name"

  echo "MUTANT_KILLED[$mutant_name]=YES"

  git -C "$AUTH" worktree remove \
    --force \
    "$mut_wt" \
    > "$mut_record/worktree_remove.stdout.txt" \
    2> "$mut_record/worktree_remove.stderr.txt" ||
    fail "MUTANT_WORKTREE_REMOVE_FAILED_$mutant_name"

  [ ! -e "$mut_wt" ] ||
    fail "MUTANT_WORKTREE_STILL_PRESENT_$mutant_name"
}

EVEN_OLD='r->coeffs[2 * i + 0] = (int16_t)(t0 | (((uint16_t)t1 << 8) & 0xFFF));'
EVEN_NEW='r->coeffs[2 * i + 0] = (int16_t)(t0 | (((uint16_t)t1 << 7) & 0xFFF));'

ODD_OLD='r->coeffs[2 * i + 1] = (int16_t)((t1 >> 4) | (t2 << 4));'
ODD_NEW='r->coeffs[2 * i + 1] = (int16_t)((t1 >> 4) | (t2 << 3));'

run_mutant \
  "p1_even_decode_shift" \
  "$P1_HARNESS" \
  "$EVEN_OLD" \
  "$EVEN_NEW"

run_mutant \
  "p2_odd_decode_shift" \
  "$P2_HARNESS" \
  "$ODD_OLD" \
  "$ODD_NEW"

echo "PFB_T4_P1_MUTANT_KILLED=YES"
echo "PFB_T4_P2_MUTANT_KILLED=YES"
echo "PFB_T4_MUTATION_SENSITIVITY=PASS"

echo
echo "============================================================"
echo "PART 8 — POST-MUTATION IMMUTABILITY"
echo "============================================================"

bind_hash "COMPRESS_SOURCE_AFTER" "$WT/mlkem/src/compress.c" "$EXPECTED_COMPRESS_SHA256"
bind_hash "COMPRESS_HEADER_AFTER" "$WT/mlkem/src/compress.h" "$EXPECTED_COMPRESS_H_SHA256"
bind_hash "PARAMS_HEADER_AFTER" "$WT/mlkem/src/params.h" "$EXPECTED_PARAMS_SHA256"

bind_hash "T1_HARNESS_AFTER" "$T1_HARNESS" "$EXPECTED_T1_HARNESS_SHA256"
bind_hash "T1_MAKEFILE_AFTER" "$T1_MAKEFILE" "$EXPECTED_T1_MAKEFILE_SHA256"
bind_hash "T1_GOTO_AFTER" "$T1_GOTO" "$EXPECTED_T1_GOTO_SHA256"

bind_hash "T2_BIT_HARNESS_AFTER" "$T2_BIT_HARNESS" "$EXPECTED_T2_BIT_HARNESS_SHA256"
bind_hash "T2_BIT_MAKEFILE_AFTER" "$T2_BIT_MAKEFILE" "$EXPECTED_T2_BIT_MAKEFILE_SHA256"
bind_hash "T2_BIT_GOTO_AFTER" "$T2_BIT_GOTO" "$EXPECTED_T2_BIT_GOTO_SHA256"

bind_hash "T2_LOCAL_HARNESS_AFTER" "$T2_LOCAL_HARNESS" "$EXPECTED_T2_LOCAL_HARNESS_SHA256"
bind_hash "T2_LOCAL_MAKEFILE_AFTER" "$T2_LOCAL_MAKEFILE" "$EXPECTED_T2_LOCAL_MAKEFILE_SHA256"
bind_hash "T2_LOCAL_GOTO_AFTER" "$T2_LOCAL_GOTO" "$EXPECTED_T2_LOCAL_GOTO_SHA256"

bind_hash "T3_HARNESS_AFTER" "$T3_HARNESS" "$EXPECTED_T3_HARNESS_SHA256"
bind_hash "T3_MAKEFILE_AFTER" "$T3_MAKEFILE" "$EXPECTED_T3_MAKEFILE_SHA256"
bind_hash "T3_GOTO_AFTER" "$T3_GOTO" "$EXPECTED_T3_GOTO_SHA256"

P1_HARNESS_AFTER="$(sha256sum "$P1_HARNESS" | awk '{print $1}')"
P1_MAKEFILE_AFTER="$(sha256sum "$P1_MAKEFILE" | awk '{print $1}')"
P1_GOTO_AFTER="$(sha256sum "$P1_GOTO" | awk '{print $1}')"

P2_HARNESS_AFTER="$(sha256sum "$P2_HARNESS" | awk '{print $1}')"
P2_MAKEFILE_AFTER="$(sha256sum "$P2_MAKEFILE" | awk '{print $1}')"
P2_GOTO_AFTER="$(sha256sum "$P2_GOTO" | awk '{print $1}')"

echo "P1_HARNESS_SHA256_AFTER=$P1_HARNESS_AFTER"
echo "P1_MAKEFILE_SHA256_AFTER=$P1_MAKEFILE_AFTER"
echo "P1_GOTO_SHA256_AFTER=$P1_GOTO_AFTER"
echo "P2_HARNESS_SHA256_AFTER=$P2_HARNESS_AFTER"
echo "P2_MAKEFILE_SHA256_AFTER=$P2_MAKEFILE_AFTER"
echo "P2_GOTO_SHA256_AFTER=$P2_GOTO_AFTER"

[ "$P1_HARNESS_AFTER" = "$P1_HARNESS_SHA256" ] || fail "P1_HARNESS_CHANGED"
[ "$P1_MAKEFILE_AFTER" = "$P1_MAKEFILE_SHA256" ] || fail "P1_MAKEFILE_CHANGED"
[ "$P1_GOTO_AFTER" = "$P1_GOTO_SHA256" ] || fail "P1_GOTO_CHANGED"

[ "$P2_HARNESS_AFTER" = "$P2_HARNESS_SHA256" ] || fail "P2_HARNESS_CHANGED"
[ "$P2_MAKEFILE_AFTER" = "$P2_MAKEFILE_SHA256" ] || fail "P2_MAKEFILE_CHANGED"
[ "$P2_GOTO_AFTER" = "$P2_GOTO_SHA256" ] || fail "P2_GOTO_CHANGED"

if git -C "$WT" diff --quiet -- \
  mlkem/src/compress.c \
  mlkem/src/compress.h \
  mlkem/src/params.h
then
  echo "ORIGINAL_WORKTREE_PRODUCTION_SOURCE_MODIFIED=NO"
else
  fail "ORIGINAL_WORKTREE_PRODUCTION_SOURCE_MODIFIED"
fi

[ -z "$(git -C "$AUTH" status --porcelain=v1)" ] ||
  fail "AUTHORITATIVE_TREE_DIRTY_AFTER_MUTANTS"

echo "AUTHORITATIVE_TREE_CLEAN_AFTER_MUTANTS=YES"
echo "PFB_T1_ARTIFACTS_UNCHANGED=YES"
echo "PFB_T2_ARTIFACTS_UNCHANGED=YES"
echo "PFB_T3_ARTIFACTS_UNCHANGED=YES"
echo "PFB_T4_BASELINE_ARTIFACTS_UNCHANGED=YES"
echo "MUTATIONS_ISOLATED_TO_DETACHED_WORKTREES=YES"

echo
echo "============================================================"
echo "PART 9 — FINAL PFB-T4 ACCEPTANCE AND EVIDENCE FREEZE"
echo "============================================================"

mkdir -p \
  "$FINAL_FREEZE/prior_evidence" \
  "$FINAL_FREEZE/p1_bytes_roundtrip" \
  "$FINAL_FREEZE/p2_raw_poly_roundtrip" \
  "$FINAL_FREEZE/control" \
  "$FINAL_FREEZE/mutants" \
  "$FINAL_FREEZE/source_binding"

cp "$FREEZE_00C/registry/PFB_THEOREM_REGISTRY_V1.md" \
  "$FINAL_FREEZE/prior_evidence/"
cp "$FREEZE_00C/registry/PFB_SCOPE_AND_NONCLAIMS_V1.md" \
  "$FINAL_FREEZE/prior_evidence/"
cp "$FREEZE_00C/registry/verification_intent.json" \
  "$FINAL_FREEZE/prior_evidence/"

cp "$T1_FINAL_FREEZE/PFB_T1_FINAL_ACCEPTANCE_REPORT.txt" \
  "$FINAL_FREEZE/prior_evidence/"
cp "$T2_FINAL_FREEZE/PFB_T2_FINAL_ACCEPTANCE_REPORT.txt" \
  "$FINAL_FREEZE/prior_evidence/"
cp "$T3_FINAL_FREEZE/PFB_T3_FINAL_ACCEPTANCE_REPORT.txt" \
  "$FINAL_FREEZE/prior_evidence/"

cp -a "$RUN/p1_bytes_roundtrip/." \
  "$FINAL_FREEZE/p1_bytes_roundtrip/"
cp "$P1_GOTO" \
  "$FINAL_FREEZE/p1_bytes_roundtrip/${P1_UID}_harness.goto"

cp -a "$RUN/p2_raw_poly_roundtrip/." \
  "$FINAL_FREEZE/p2_raw_poly_roundtrip/"
cp "$P2_GOTO" \
  "$FINAL_FREEZE/p2_raw_poly_roundtrip/${P2_UID}_harness.goto"

cp -a "$RUN/control/." "$FINAL_FREEZE/control/"
cp -a "$RUN/mutants/." "$FINAL_FREEZE/mutants/"

cat > "$FINAL_FREEZE/source_binding/SOURCE_IDENTITY.txt" <<EOF_SOURCE
SOURCE_COMMIT=$EXPECTED_COMMIT
SOURCE_TREE=$EXPECTED_TREE
COMPRESS_SOURCE_SHA256=$EXPECTED_COMPRESS_SHA256
COMPRESS_HEADER_SHA256=$EXPECTED_COMPRESS_H_SHA256
PARAMS_HEADER_SHA256=$EXPECTED_PARAMS_SHA256
P1_HARNESS_SHA256=$P1_HARNESS_SHA256
P1_MAKEFILE_SHA256=$P1_MAKEFILE_SHA256
P1_GOTO_SHA256=$P1_GOTO_SHA256
P2_HARNESS_SHA256=$P2_HARNESS_SHA256
P2_MAKEFILE_SHA256=$P2_MAKEFILE_SHA256
P2_GOTO_SHA256=$P2_GOTO_SHA256
EOF_SOURCE

cat > "$FINAL_FREEZE/PFB_T4_FINAL_ACCEPTANCE_REPORT.txt" <<EOF_REPORT
PFB_STAGE=PFB-T4-FINAL
PFB_T4_FINAL_ACCEPTANCE=YES
FROZEN_AT_UTC=$STAMP
SOURCE_COMMIT=$EXPECTED_COMMIT
SOURCE_TREE=$EXPECTED_TREE
INITIAL_CONFIGURATION=portable ML-KEM-768
PUBLIC_TARGET=mlk_poly_frombytes
PORTABLE_BODY=mlk_poly_frombytes_c
PFB_T4_P1_ARBITRARY_BYTES_DECODE_INDEPENDENT_ENCODE=PROVED
PFB_T4_P2_ARBITRARY_RAW_POLY_INDEPENDENT_ENCODE_DECODE=PROVED
PFB_T4_P1_DOMAIN=ALL_${MLKEM_POLYBYTES:-384}_BYTE_ARRAYS
PFB_T4_P2_DOMAIN=ALL_${MLKEM_N:-256}_COEFFICIENT_POLYNOMIALS_WITH_COEFFICIENTS_0_TO_4095
P1_THEOREM_SET=1_OF_1_SUCCESS
P1_COMPLETE_PROPERTY_SET=${P1_ALL_SUCCESS_COUNT}_OF_${P1_ALL_PROPERTY_COUNT}_SUCCESS
P2_THEOREM_SET=1_OF_1_SUCCESS
P2_COMPLETE_PROPERTY_SET=${P2_ALL_SUCCESS_COUNT}_OF_${P2_ALL_PROPERTY_COUNT}_SUCCESS
INDEPENDENT_RAW_ENCODER=DIVISION_AND_REMAINDER_ONLY
PRODUCTION_TOBYTES_USED=NO
TARGET_CALLED_INSIDE_ORACLE=NO
NONVACUITY_AND_BOUNDARY_CONTROL=PASS
NONVACUITY_CONTROL_ASSERTIONS=8_OF_8_SUCCESS
PFB_T4_P1_MUTANT_KILLED=YES
PFB_T4_P2_MUTANT_KILLED=YES
MUTATION_SENSITIVITY=PASS
FUNCTION_CONTRACT_SUBSTITUTION=NO
LOOP_CONTRACT_APPLICATION=NO
DEFAULT_SAT_BACKEND=YES
NATIVE_BACKEND_CLAIM=EXCLUDED
PFB_T1_ARTIFACTS_UNCHANGED=YES
PFB_T2_ARTIFACTS_UNCHANGED=YES
PFB_T3_ARTIFACTS_UNCHANGED=YES
PFB_T4_BASELINE_ARTIFACTS_UNCHANGED=YES
PRODUCTION_SOURCE_MODIFIED=NO
AUTHORITATIVE_TREE_CLEAN=YES
MATHEMATICAL_WORLD_FIRST_CLAIM=NO
ALLOWED_CLAIM=At commit af4c5abd, the portable public mlk_poly_frombytes path was verified by CBMC for the two frozen PFB-T4 two-sided raw-domain inverse obligations: arbitrary 384-byte inputs round-trip through the real decoder and an independent arithmetic raw encoder, and arbitrary raw polynomials with coefficients in [0,4096) round-trip through that encoder and the real decoder, under the recorded machine model and proof configuration.
FINAL_FREEZE_DIRECTORY=$FINAL_FREEZE
TERMINAL_OUTPUT=$OUT
EOF_REPORT

cp "$OUT" "$FINAL_FREEZE/PFB_04F_TERMINAL_OUTPUT.txt"

(
  cd "$FINAL_FREEZE" || exit 1
  find . \
    -type f \
    ! -name SHA256SUMS.txt \
    -print0 |
  sort -z |
  xargs -0 sha256sum \
    > SHA256SUMS.txt
) || fail "FINAL_MANIFEST_CREATION_FAILED"

FINAL_MANIFEST_SHA256="$(
  sha256sum "$FINAL_FREEZE/SHA256SUMS.txt" | awk '{print $1}'
)"

tar \
  --sort=name \
  --mtime='UTC 1970-01-01' \
  --owner=0 \
  --group=0 \
  --numeric-owner \
  -czf "$FINAL_ARCHIVE" \
  -C "$CAMPAIGN" \
  "$(basename "$FINAL_FREEZE")" ||
  fail "FINAL_ARCHIVE_CREATION_FAILED"

FINAL_ARCHIVE_SHA256="$(
  sha256sum "$FINAL_ARCHIVE" | awk '{print $1}'
)"

cat "$FINAL_FREEZE/PFB_T4_FINAL_ACCEPTANCE_REPORT.txt"

echo "FINAL_MANIFEST_SHA256=$FINAL_MANIFEST_SHA256"
echo "FINAL_ARCHIVE=$FINAL_ARCHIVE"
echo "FINAL_ARCHIVE_SHA256=$FINAL_ARCHIVE_SHA256"

echo
echo "============================================================"
echo "PFB-04F COMPLETE"
echo "PFB-T4 FINAL ACCEPTANCE=YES"
echo "BOTH FROZEN TWO-SIDED RAW-DOMAIN OBLIGATIONS PROVED"
echo "ALL EIGHT NONVACUITY CONTROL ASSERTIONS PASSED"
echo "BOTH TARGETED SOURCE MUTANTS KILLED"
echo "FAIL-CLOSED EVIDENCE FREEZE CREATED"
echo "NO PRIOR OR PFB-T4 BASELINE ARTIFACT MODIFIED"
echo "NO AUTHORITATIVE PRODUCTION SOURCE MODIFIED"
echo "SCRIPT_FINAL_EXIT=0"
echo "============================================================"

exit 0
