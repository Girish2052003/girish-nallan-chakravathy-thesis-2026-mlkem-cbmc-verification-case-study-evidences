#!/usr/bin/env bash
#
# PFB-02A — PFB-T2 exact bit-routing and block-locality semantic baseline.
#
# This script:
#   * re-binds the frozen intent and authoritative source,
#   * creates two separate proof harnesses in the existing isolated worktree,
#   * proves PFB-T2.P1..P4 with an arbitrary block, bit and coefficient index,
#   * proves PFB-T2.P5 with arbitrary replacement bytes and coefficient index,
#   * runs theorem-only and complete-property CBMC checks with the default SAT backend,
#   * refuses function/loop-contract transformations and native dispatch,
#   * leaves production source and all PFB-T1 theorem artifacts unchanged.
#
# Terminal-first stage: no archive upload is required after this baseline run.

set +e
set -uo pipefail
umask 022

ROOT="$HOME/THESIS-2026"
AUTH="$ROOT/mlkem-native_af4c5abd"
WT="$ROOT/_cbmc_work/mlkem-native_pfb_af4c5abd"
FREEZE="$ROOT/mlk_poly_frombytes_cleanroom/PFB_00C_THEOREM_FREEZE_af4c5abd"

T1_PROOF="$WT/proofs/cbmc/pfb_t1_exact_raw_decode"
T1_HARNESS="$T1_PROOF/pfb_t1_exact_raw_decode_harness.c"
T1_MAKEFILE="$T1_PROOF/Makefile"
T1_GOTO="$T1_PROOF/gotos/pfb_t1_exact_raw_decode_harness.goto"

BIT_PROOF="$WT/proofs/cbmc/pfb_t2_bit_routes"
BIT_HARNESS="$BIT_PROOF/pfb_t2_bit_routes_harness.c"
BIT_MAKEFILE="$BIT_PROOF/Makefile"
BIT_GOTO="$BIT_PROOF/gotos/pfb_t2_bit_routes_harness.goto"

LOCAL_PROOF="$WT/proofs/cbmc/pfb_t2_block_locality"
LOCAL_HARNESS="$LOCAL_PROOF/pfb_t2_block_locality_harness.c"
LOCAL_MAKEFILE="$LOCAL_PROOF/Makefile"
LOCAL_GOTO="$LOCAL_PROOF/gotos/pfb_t2_block_locality_harness.goto"

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_TREE="54805daff6a91a010c05467ea678117c42a71559"
EXPECTED_COMPRESS_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESS_H_SHA256="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"
EXPECTED_PARAMS_SHA256="450fe3e0e50496921920473ae4321660f178c23d51f1453f3c537ee63c4158cb"
EXPECTED_T1_HARNESS_SHA256="9a3288855782f7aee718d51c7904608763bd480635a63d25cd05956d408007a8"
EXPECTED_T1_MAKEFILE_SHA256="9e56741090a6634baddbe2ea9fe13637bbeed9a1ce62f93e2f228185cfe41526"
EXPECTED_T1_GOTO_SHA256="13dd5ba4e64b4dd3c54a3d4e7c82ec0e3c1b09a397584cfa1a13309f60ceeb83"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN="$ROOT/mlk_poly_frombytes_cleanroom/PFB_02A_T2_SEMANTIC_BASELINE_${STAMP}"
OUT="/tmp/PFB_02A_T2_SEMANTIC_BASELINE.txt"

mkdir -p "$RUN"/{binding,artifacts,build,results}
exec > >(tee "$OUT") 2>&1

fail()
{
  echo "FATAL_FAILURE=$1"
  echo "PFB_T2_SEMANTIC_BASELINE=NO"
  echo "SCRIPT_FINAL_EXIT=1"
  exit 1
}

require_command()
{
  command -v "$1" >/dev/null 2>&1 || fail "COMMAND_NOT_FOUND_$1"
}

for cmd in git sha256sum python3 goto-instrument cbmc make timeout grep awk sed stat; do
  require_command "$cmd"
done

echo "============================================================"
echo "PFB-02A — T2 BIT-ROUTING AND BLOCK-LOCALITY BASELINE"
echo "============================================================"
echo "STARTED_AT_UTC=$STAMP"
echo "RUN_DIRECTORY=$RUN"
echo "TERMINAL_OUTPUT=$OUT"

echo
echo "============================================================"
echo "PART 1 — FROZEN INTENT AND AUTHORITATIVE SOURCE BINDING"
echo "============================================================"

[ -d "$FREEZE" ] || fail "PFB_00C_FREEZE_ABSENT"
(
  cd "$FREEZE" || exit 1
  sha256sum -c SHA256SUMS.txt
) || fail "PFB_00C_HASH_CHECK_FAILED"

grep -Fq '"PFB-T2.P1"' "$FREEZE/registry/verification_intent.json" ||
  fail "PFB_T2_P1_NOT_FROZEN"
grep -Fq '"PFB-T2.P2"' "$FREEZE/registry/verification_intent.json" ||
  fail "PFB_T2_P2_NOT_FROZEN"
grep -Fq '"PFB-T2.P3"' "$FREEZE/registry/verification_intent.json" ||
  fail "PFB_T2_P3_NOT_FROZEN"
grep -Fq '"PFB-T2.P4"' "$FREEZE/registry/verification_intent.json" ||
  fail "PFB_T2_P4_NOT_FROZEN"
grep -Fq '"PFB-T2.P5"' "$FREEZE/registry/verification_intent.json" ||
  fail "PFB_T2_P5_NOT_FROZEN"

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

COMPRESS_SHA256="$(sha256sum "$WT/mlkem/src/compress.c" | awk '{print $1}')"
COMPRESS_H_SHA256="$(sha256sum "$WT/mlkem/src/compress.h" | awk '{print $1}')"
PARAMS_SHA256="$(sha256sum "$WT/mlkem/src/params.h" | awk '{print $1}')"

echo "COMPRESS_SOURCE_SHA256=$COMPRESS_SHA256"
echo "COMPRESS_HEADER_SHA256=$COMPRESS_H_SHA256"
echo "PARAMS_HEADER_SHA256=$PARAMS_SHA256"

[ "$COMPRESS_SHA256" = "$EXPECTED_COMPRESS_SHA256" ] ||
  fail "COMPRESS_SOURCE_HASH_MISMATCH"
[ "$COMPRESS_H_SHA256" = "$EXPECTED_COMPRESS_H_SHA256" ] ||
  fail "COMPRESS_HEADER_HASH_MISMATCH"
[ "$PARAMS_SHA256" = "$EXPECTED_PARAMS_SHA256" ] ||
  fail "PARAMS_HEADER_HASH_MISMATCH"

echo "FROZEN_INTENT_AND_SOURCE_BINDING=PASS"

echo
echo "============================================================"
echo "PART 2 — PFB-T1 ARTIFACT NONREGRESSION BINDING"
echo "============================================================"

[ -f "$T1_HARNESS" ] || fail "T1_HARNESS_ABSENT"
[ -f "$T1_MAKEFILE" ] || fail "T1_MAKEFILE_ABSENT"
[ -f "$T1_GOTO" ] || fail "T1_GOTO_ABSENT"

T1_HARNESS_BEFORE="$(sha256sum "$T1_HARNESS" | awk '{print $1}')"
T1_MAKEFILE_BEFORE="$(sha256sum "$T1_MAKEFILE" | awk '{print $1}')"
T1_GOTO_BEFORE="$(sha256sum "$T1_GOTO" | awk '{print $1}')"

echo "T1_HARNESS_SHA256=$T1_HARNESS_BEFORE"
echo "T1_MAKEFILE_SHA256=$T1_MAKEFILE_BEFORE"
echo "T1_GOTO_SHA256=$T1_GOTO_BEFORE"

[ "$T1_HARNESS_BEFORE" = "$EXPECTED_T1_HARNESS_SHA256" ] ||
  fail "T1_HARNESS_HASH_MISMATCH"
[ "$T1_MAKEFILE_BEFORE" = "$EXPECTED_T1_MAKEFILE_SHA256" ] ||
  fail "T1_MAKEFILE_HASH_MISMATCH"
[ "$T1_GOTO_BEFORE" = "$EXPECTED_T1_GOTO_SHA256" ] ||
  fail "T1_GOTO_HASH_MISMATCH"

echo "PFB_T1_ARTIFACT_BINDING=PASS"

echo
echo "============================================================"
echo "PART 3 — CREATE TWO DISTINCT PFB-T2 HARNESS FAMILIES"
echo "============================================================"

[ ! -e "$BIT_PROOF" ] || fail "BIT_ROUTE_PROOF_DIRECTORY_ALREADY_EXISTS"
[ ! -e "$LOCAL_PROOF" ] || fail "LOCALITY_PROOF_DIRECTORY_ALREADY_EXISTS"

mkdir -p "$BIT_PROOF" "$LOCAL_PROOF"

cat > "$BIT_HARNESS" <<'EOF_BIT'
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
EOF_BIT

cat > "$LOCAL_HARNESS" <<'EOF_LOCAL'
#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T2.P5 — arbitrary one-block locality.
 *
 * The second input is constructed from the first and then the selected
 * 3-byte block is replaced by three unrestricted bytes. The observed output
 * coefficient is arbitrary. Thus the assertion covers every coefficient
 * outside the selected output pair and permits unrestricted change inside it.
 */
void harness(void)
{
  uint8_t first_input[MLKEM_POLYBYTES];
  uint8_t second_input[MLKEM_POLYBYTES];

  mlk_poly first_output;
  mlk_poly second_output;

  uint8_t replacement0;
  uint8_t replacement1;
  uint8_t replacement2;

  uint32_t block_index;
  uint32_t coeff_index;
  uint32_t i;

  __CPROVER_assume(block_index < (MLKEM_N / 2u));
  __CPROVER_assume(coeff_index < MLKEM_N);

  for (i = 0u; i < MLKEM_POLYBYTES; i++)
  {
    second_input[i] = first_input[i];
  }

  second_input[3u * block_index] = replacement0;
  second_input[3u * block_index + 1u] = replacement1;
  second_input[3u * block_index + 2u] = replacement2;

  mlk_poly_frombytes(&first_output, first_input);
  mlk_poly_frombytes(&second_output, second_input);

  __CPROVER_assert(
      (coeff_index / 2u == block_index) ||
          (first_output.coeffs[coeff_index] ==
           second_output.coeffs[coeff_index]),
      "PFB-T2.P5 arbitrary one-block change leaves all other pairs unchanged");
}
EOF_LOCAL

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
        1,
    ),
    (
        "PROOF_UID = pfb_t1_exact_raw_decode",
        f"PROOF_UID = {proof_uid}",
        1,
    ),
    (
        "CBMCFLAGS=--bitwuzla",
        "CBMCFLAGS=",
        1,
    ),
]

for old, new, expected in replacements:
    actual = text.count(old)
    print(f"MAKEFILE_REPLACEMENT_COUNT[{old}]={actual}")
    if actual != expected:
        raise SystemExit(
            f"Expected {expected} occurrence of {old!r}, found {actual}"
        )
    text = text.replace(old, new, expected)

unwind_count = text.count("--unwind 129")
print(f"MAKEFILE_UNWIND_REPLACEMENT_COUNT={unwind_count}")
if unwind_count != 4:
    raise SystemExit(
        f"Expected four inherited --unwind 129 occurrences, found {unwind_count}"
    )

text = text.replace("--unwind 129", "--unwind 385")
path.write_text(text, encoding="utf-8")
PY
}

derive_makefile "$BIT_MAKEFILE" "pfb_t2_bit_routes_harness" "pfb_t2_bit_routes" ||
  fail "BIT_ROUTE_MAKEFILE_DERIVATION_FAILED"
derive_makefile "$LOCAL_MAKEFILE" "pfb_t2_block_locality_harness" "pfb_t2_block_locality" ||
  fail "LOCALITY_MAKEFILE_DERIVATION_FAILED"

BIT_HARNESS_SHA256="$(sha256sum "$BIT_HARNESS" | awk '{print $1}')"
BIT_MAKEFILE_SHA256="$(sha256sum "$BIT_MAKEFILE" | awk '{print $1}')"
LOCAL_HARNESS_SHA256="$(sha256sum "$LOCAL_HARNESS" | awk '{print $1}')"
LOCAL_MAKEFILE_SHA256="$(sha256sum "$LOCAL_MAKEFILE" | awk '{print $1}')"

echo "BIT_ROUTE_HARNESS_SHA256=$BIT_HARNESS_SHA256"
echo "BIT_ROUTE_MAKEFILE_SHA256=$BIT_MAKEFILE_SHA256"
echo "LOCALITY_HARNESS_SHA256=$LOCAL_HARNESS_SHA256"
echo "LOCALITY_MAKEFILE_SHA256=$LOCAL_MAKEFILE_SHA256"

BIT_PUBLIC_CALL_COUNT="$(
  grep -Ec '^[[:space:]]*mlk_poly_frombytes\(' "$BIT_HARNESS" || true
)"
BIT_ASSERTION_COUNT="$(
  grep -c '__CPROVER_assert' "$BIT_HARNESS" || true
)"
BIT_ASSUME_COUNT="$(
  grep -c '__CPROVER_assume' "$BIT_HARNESS" || true
)"
LOCAL_PUBLIC_CALL_COUNT="$(
  grep -Ec '^[[:space:]]*mlk_poly_frombytes\(' "$LOCAL_HARNESS" || true
)"
LOCAL_ASSERTION_COUNT="$(
  grep -c '__CPROVER_assert' "$LOCAL_HARNESS" || true
)"
LOCAL_ASSUME_COUNT="$(
  grep -c '__CPROVER_assume' "$LOCAL_HARNESS" || true
)"

echo "BIT_ROUTE_PUBLIC_CALL_COUNT=$BIT_PUBLIC_CALL_COUNT"
echo "BIT_ROUTE_ASSERTION_COUNT=$BIT_ASSERTION_COUNT"
echo "BIT_ROUTE_ASSUME_COUNT=$BIT_ASSUME_COUNT"
echo "LOCALITY_PUBLIC_CALL_COUNT=$LOCAL_PUBLIC_CALL_COUNT"
echo "LOCALITY_ASSERTION_COUNT=$LOCAL_ASSERTION_COUNT"
echo "LOCALITY_ASSUME_COUNT=$LOCAL_ASSUME_COUNT"

[ "$BIT_PUBLIC_CALL_COUNT" = "5" ] || fail "BIT_ROUTE_PUBLIC_CALL_COUNT_WRONG"
[ "$BIT_ASSERTION_COUNT" = "4" ] || fail "BIT_ROUTE_ASSERTION_COUNT_WRONG"
[ "$BIT_ASSUME_COUNT" = "4" ] || fail "BIT_ROUTE_ASSUME_COUNT_WRONG"
[ "$LOCAL_PUBLIC_CALL_COUNT" = "2" ] || fail "LOCALITY_PUBLIC_CALL_COUNT_WRONG"
[ "$LOCAL_ASSERTION_COUNT" = "1" ] || fail "LOCALITY_ASSERTION_COUNT_WRONG"
[ "$LOCAL_ASSUME_COUNT" = "2" ] || fail "LOCALITY_ASSUME_COUNT_WRONG"

if grep -Eq \
  'assume[[:space:]]*\([[:space:]]*(false|0)[[:space:]]*\)' \
  "$BIT_HARNESS" "$LOCAL_HARNESS"
then
  fail "ASSUME_FALSE_PRESENT"
fi

if grep -Fq 'mlk_poly_tobytes' "$BIT_HARNESS" "$LOCAL_HARNESS"; then
  fail "PRODUCTION_ENCODER_USED"
fi

if grep -Fq 'mlk_poly_frombytes_c(' "$BIT_HARNESS" "$LOCAL_HARNESS"; then
  fail "PORTABLE_BODY_CALLED_DIRECTLY"
fi

if grep -Eq \
  'USE_FUNCTION_CONTRACTS[[:space:]]*=[[:space:]]*[^[:space:]]|CHECK_FUNCTION_CONTRACTS[[:space:]]*=[[:space:]]*[^[:space:]]|APPLY_LOOP_CONTRACTS[[:space:]]*=[[:space:]]*on|USE_DYNAMIC_FRAMES[[:space:]]*=[[:space:]]*1' \
  "$BIT_MAKEFILE" "$LOCAL_MAKEFILE"
then
  fail "FORBIDDEN_PROOF_TRANSFORMATION_PRESENT"
fi

cp "$BIT_HARNESS" "$RUN/artifacts/"
cp "$BIT_MAKEFILE" "$RUN/artifacts/Makefile.pfb_t2_bit_routes"
cp "$LOCAL_HARNESS" "$RUN/artifacts/"
cp "$LOCAL_MAKEFILE" "$RUN/artifacts/Makefile.pfb_t2_block_locality"

echo "PFB_T2_HARNESS_CREATION_AND_AUDIT=PASS"

echo
echo "============================================================"
echo "PART 4 — BUILD AND BIND BOTH GOTO PROGRAMS"
echo "============================================================"

build_goto()
{
  local name="$1"
  local proof="$2"
  local goto_file="$3"

  set +e
  make -C "$proof" -j1 \
    > "$RUN/build/${name}.make.stdout.txt" \
    2> "$RUN/build/${name}.make.stderr.txt"
  local make_exit=$?
  set -e 2>/dev/null || true

  echo "MAKE_EXIT[$name]=$make_exit"
  echo "----- MAKE STDOUT TAIL[$name] -----"
  tail -n 80 "$RUN/build/${name}.make.stdout.txt" || true
  echo "----- MAKE STDERR TAIL[$name] -----"
  tail -n 80 "$RUN/build/${name}.make.stderr.txt" || true

  [ -f "$goto_file" ] || fail "GOTO_NOT_CREATED_$name"

  echo "GOTO_CREATED[$name]=YES"
  echo "GOTO_SHA256[$name]=$(sha256sum "$goto_file" | awk '{print $1}')"

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

  cbmc \
    --unwind 385 \
    --unwinding-assertions \
    --show-properties \
    "$goto_file" \
    > "$RUN/binding/${name}.show_properties.txt" \
    2> "$RUN/binding/${name}.show_properties.stderr.txt" ||
    fail "SHOW_PROPERTIES_FAILED_$name"
}

build_goto "bit_routes" "$BIT_PROOF" "$BIT_GOTO"
build_goto "block_locality" "$LOCAL_PROOF" "$LOCAL_GOTO"

grep -Fq 'PFB-T2.P1' "$RUN/binding/bit_routes.show_properties.txt" ||
  fail "PFB_T2_P1_PROPERTY_ABSENT"
grep -Fq 'PFB-T2.P2' "$RUN/binding/bit_routes.show_properties.txt" ||
  fail "PFB_T2_P2_PROPERTY_ABSENT"
grep -Fq 'PFB-T2.P3' "$RUN/binding/bit_routes.show_properties.txt" ||
  fail "PFB_T2_P3_PROPERTY_ABSENT"
grep -Fq 'PFB-T2.P4' "$RUN/binding/bit_routes.show_properties.txt" ||
  fail "PFB_T2_P4_PROPERTY_ABSENT"
grep -Fq 'PFB-T2.P5' "$RUN/binding/block_locality.show_properties.txt" ||
  fail "PFB_T2_P5_PROPERTY_ABSENT"

echo "PFB_T2_GOTO_BINDING=PASS"

echo
echo "============================================================"
echo "PART 5 — FAIL-CLOSED DEFAULT-SAT CBMC RUNS"
echo "============================================================"

COMMON_FLAGS=(
  --flush
  --object-bits 8
  --slice-formula
  --unwind 385
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

printf 'COMMON_CBMC_FLAGS='
printf '%q ' "${COMMON_FLAGS[@]}"
printf '\n'
echo "DEFAULT_SAT_BACKEND=YES"
echo "SMT_OR_BITWUZLA_FLAG_PRESENT=NO"
echo "FUNCTION_CONTRACT_TRANSFORMATION=NO"
echo "LOOP_CONTRACT_APPLICATION=NO"

parse_xml()
{
  local xml="$1"
  local summary="$2"
  shift 2

  python3 - "$xml" "$summary" "$@" <<'PY'
from __future__ import annotations

import collections
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

xml_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
expected_ids = sys.argv[3:]

values = {
    "XML_PRESENT": "NO",
    "XML_PARSE": "FAIL",
    "CPROVER_STATUS": "NONE",
    "PROPERTY_COUNT": "0",
    "SUCCESS_COUNT": "0",
    "FAILURE_COUNT": "0",
    "ERROR_COUNT": "0",
    "UNKNOWN_COUNT": "0",
    "NON_SUCCESS_COUNT": "0",
}

for property_id in expected_ids:
    values[f"STATUS[{property_id}]"] = "ABSENT"

if xml_path.is_file():
    values["XML_PRESENT"] = "YES"
    try:
        root = ET.parse(xml_path).getroot()
        values["XML_PARSE"] = "PASS"

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

        statuses = [
            " ".join((element.text or "").split())
            for element in root.iter()
            if local_name(element.tag) == "cprover-status"
        ]
        if statuses:
            values["CPROVER_STATUS"] = "|".join(statuses)

        for result in results:
            property_id = result.attrib.get("property", "")
            key = f"STATUS[{property_id}]"
            if key in values:
                values[key] = result.attrib.get("status", "MISSING")

        print("----- NON-SUCCESS PROPERTIES -----")
        non_success = [
            result
            for result in results
            if result.attrib.get("status") != "SUCCESS"
        ]
        if not non_success:
            print("NONE")
        else:
            for number, result in enumerate(non_success, start=1):
                print(
                    f"{number}:"
                    f"{result.attrib.get('property', 'MISSING')}:"
                    f"{result.attrib.get('status', 'MISSING')}"
                )

    except Exception as exc:
        print(f"XML_PARSE_EXCEPTION={exc!r}")

summary_path.write_text(
    "".join(f"{key}={value}\n" for key, value in values.items()),
    encoding="utf-8",
)

print("----- XML SUMMARY -----")
for key, value in values.items():
    print(f"{key}={value}")
PY
}

run_cbmc()
{
  local name="$1"
  local timeout_seconds="$2"
  local goto_file="$3"
  shift 3

  local xml="$RUN/results/${name}.xml"
  local stderr="$RUN/results/${name}.stderr.txt"
  local summary="$RUN/results/${name}.summary.txt"
  local exit_file="$RUN/results/${name}.exit.txt"
  local command="$RUN/results/${name}.command.txt"
  local cbmc_exit

  {
    printf 'cbmc '
    printf '%q ' "${COMMON_FLAGS[@]}"
    printf '%q ' "$@"
    printf '%q %q\n' --xml-ui "$goto_file"
  } > "$command"

  echo
  echo "---------------- RUN=$name ----------------"
  cat "$command"

  if timeout \
    --signal=TERM \
    "$timeout_seconds" \
    cbmc \
    "${COMMON_FLAGS[@]}" \
    "$@" \
    --xml-ui \
    "$goto_file" \
    > "$xml" \
    2> "$stderr"
  then
    cbmc_exit=0
  else
    cbmc_exit=$?
  fi

  echo "$cbmc_exit" > "$exit_file"
  echo "CBMC_EXIT[$name]=$cbmc_exit"
  echo "XML_SIZE[$name]=$(stat -c '%s' "$xml" 2>/dev/null || echo 0)"
  echo "STDERR_SIZE[$name]=$(stat -c '%s' "$stderr" 2>/dev/null || echo 0)"

  parse_xml "$xml" "$summary" "$@"

  echo "----- STDERR[$name] -----"
  cat "$stderr" || true
}

run_cbmc \
  "bit_routes_theorem" \
  1800 \
  "$BIT_GOTO" \
  --property harness.assertion.1 \
  --property harness.assertion.2 \
  --property harness.assertion.3 \
  --property harness.assertion.4

run_cbmc \
  "bit_routes_all" \
  1800 \
  "$BIT_GOTO"

run_cbmc \
  "block_locality_theorem" \
  1200 \
  "$LOCAL_GOTO" \
  --property harness.assertion.1

run_cbmc \
  "block_locality_all" \
  1200 \
  "$LOCAL_GOTO"

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

check_run()
{
  local name="$1"
  local expected_property_count="$2"
  shift 2

  local summary="$RUN/results/${name}.summary.txt"
  local exit_file="$RUN/results/${name}.exit.txt"
  local cbmc_exit
  local cprover
  local property_count
  local non_success

  cbmc_exit="$(cat "$exit_file" 2>/dev/null || true)"
  cprover="$(read_value "$summary" CPROVER_STATUS)"
  property_count="$(read_value "$summary" PROPERTY_COUNT)"
  non_success="$(read_value "$summary" NON_SUCCESS_COUNT)"

  echo "CHECK[$name].CBMC_EXIT=$cbmc_exit"
  echo "CHECK[$name].CPROVER_STATUS=$cprover"
  echo "CHECK[$name].PROPERTY_COUNT=$property_count"
  echo "CHECK[$name].NON_SUCCESS_COUNT=$non_success"

  [ "$cbmc_exit" = "0" ] || fail "CBMC_EXIT_NONZERO_$name"
  [ "$cprover" = "SUCCESS" ] || fail "CPROVER_STATUS_NOT_SUCCESS_$name"
  [ "$non_success" = "0" ] || fail "NON_SUCCESS_PROPERTIES_$name"

  if [ "$expected_property_count" != "ANY" ]; then
    [ "$property_count" = "$expected_property_count" ] ||
      fail "PROPERTY_COUNT_WRONG_$name"
  fi

  local property_id
  local status
  for property_id in "$@"; do
    status="$(read_value "$summary" "STATUS[$property_id]")"
    echo "CHECK[$name].STATUS[$property_id]=$status"
    [ "$status" = "SUCCESS" ] ||
      fail "EXPECTED_PROPERTY_NOT_SUCCESS_${name}_${property_id}"
  done
}

check_run \
  "bit_routes_theorem" \
  "4" \
  "harness.assertion.1" \
  "harness.assertion.2" \
  "harness.assertion.3" \
  "harness.assertion.4"

check_run \
  "bit_routes_all" \
  "ANY" \
  "harness.assertion.1" \
  "harness.assertion.2" \
  "harness.assertion.3" \
  "harness.assertion.4"

check_run \
  "block_locality_theorem" \
  "1" \
  "harness.assertion.1"

check_run \
  "block_locality_all" \
  "ANY" \
  "harness.assertion.1"

echo "PFB_T2_P1_STATUS=SUCCESS"
echo "PFB_T2_P2_STATUS=SUCCESS"
echo "PFB_T2_P3_STATUS=SUCCESS"
echo "PFB_T2_P4_STATUS=SUCCESS"
echo "PFB_T2_P5_STATUS=SUCCESS"
echo "PFB_T2_COMPLETE_PROPERTY_RUNS=PASS"

echo
echo "============================================================"
echo "PART 6 — POST-RUN INTEGRITY AND FAIL-CLOSED RESULT"
echo "============================================================"

T1_HARNESS_AFTER="$(sha256sum "$T1_HARNESS" | awk '{print $1}')"
T1_MAKEFILE_AFTER="$(sha256sum "$T1_MAKEFILE" | awk '{print $1}')"
T1_GOTO_AFTER="$(sha256sum "$T1_GOTO" | awk '{print $1}')"
COMPRESS_AFTER="$(sha256sum "$WT/mlkem/src/compress.c" | awk '{print $1}')"

echo "T1_HARNESS_SHA256_AFTER=$T1_HARNESS_AFTER"
echo "T1_MAKEFILE_SHA256_AFTER=$T1_MAKEFILE_AFTER"
echo "T1_GOTO_SHA256_AFTER=$T1_GOTO_AFTER"
echo "COMPRESS_SOURCE_SHA256_AFTER=$COMPRESS_AFTER"

[ "$T1_HARNESS_AFTER" = "$T1_HARNESS_BEFORE" ] ||
  fail "T1_HARNESS_CHANGED"
[ "$T1_MAKEFILE_AFTER" = "$T1_MAKEFILE_BEFORE" ] ||
  fail "T1_MAKEFILE_CHANGED"
[ "$T1_GOTO_AFTER" = "$T1_GOTO_BEFORE" ] ||
  fail "T1_GOTO_CHANGED"
[ "$COMPRESS_AFTER" = "$EXPECTED_COMPRESS_SHA256" ] ||
  fail "PRODUCTION_SOURCE_CHANGED"

if git -C "$WT" diff --quiet -- \
  mlkem/src/compress.c \
  mlkem/src/compress.h \
  mlkem/src/params.h
then
  echo "WORKTREE_PRODUCTION_SOURCE_MODIFIED=NO"
else
  fail "WORKTREE_PRODUCTION_SOURCE_MODIFIED"
fi

[ -z "$(git -C "$AUTH" status --porcelain=v1)" ] ||
  fail "AUTHORITATIVE_TREE_DIRTY_AFTER_RUN"

echo "AUTHORITATIVE_TREE_CLEAN_AFTER_RUN=YES"
echo "PFB_T1_ARTIFACTS_UNCHANGED=YES"

{
  echo "PFB_STAGE=PFB-02A"
  echo "RUNNER_STATUS=COMPLETE"
  echo "SOURCE_COMMIT=$EXPECTED_COMMIT"
  echo "SOURCE_TREE=$EXPECTED_TREE"
  echo "INITIAL_CONFIGURATION=portable ML-KEM-768"
  echo "PFB_T2_P1_STATUS=SUCCESS"
  echo "PFB_T2_P2_STATUS=SUCCESS"
  echo "PFB_T2_P3_STATUS=SUCCESS"
  echo "PFB_T2_P4_STATUS=SUCCESS"
  echo "PFB_T2_P5_STATUS=SUCCESS"
  echo "PFB_T2_THEOREM_ONLY_RUNS=PASS"
  echo "PFB_T2_COMPLETE_PROPERTY_RUNS=PASS"
  echo "DEFAULT_SAT_BACKEND=YES"
  echo "FUNCTION_CONTRACT_SUBSTITUTION=NO"
  echo "LOOP_CONTRACT_APPLICATION=NO"
  echo "NATIVE_BACKEND_CLAIM=EXCLUDED"
  echo "PFB_T1_ARTIFACTS_UNCHANGED=YES"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "AUTHORITATIVE_TREE_CLEAN=YES"
  echo "PFB_T2_SEMANTIC_BASELINE=PASS"
  echo "PFB_T2_FINAL_ACCEPTANCE=NO"
  echo "NONVACUITY_AND_MUTATION_CONTROLS_PENDING=YES"
  echo "RUN_DIRECTORY=$RUN"
  echo "TERMINAL_OUTPUT=$OUT"
} > "$RUN/PFB_02A_RESULT.txt"

(
  cd "$RUN" || exit 1
  find . \
    -type f \
    ! -name SHA256SUMS.txt \
    -print0 |
    sort -z |
    xargs -0 sha256sum \
    > SHA256SUMS.txt
) || fail "RUN_HASH_MANIFEST_FAILED"

echo "RUN_SHA256SUMS_SHA256=$(
  sha256sum "$RUN/SHA256SUMS.txt" | awk '{print $1}'
)"

echo
echo "============================================================"
echo "PFB-02A RESULT"
echo "============================================================"
cat "$RUN/PFB_02A_RESULT.txt"

echo
echo "============================================================"
echo "PFB-02A COMPLETE"
echo "ALL FIVE PFB-T2 SEMANTIC OBLIGATIONS PASSED"
echo "BOTH COMPLETE PROPERTY RUNS PASSED"
echo "NO PFB-T1 THEOREM ARTIFACT MODIFIED"
echo "NO PRODUCTION SOURCE MODIFIED"
echo "PFB-T2 FINAL ACCEPTANCE=NO"
echo "MUTATION AND NONVACUITY CONTROLS PENDING"
echo "SCRIPT_FINAL_EXIT=0"
echo "============================================================"

exit 0
