#!/usr/bin/env bash
#
# PFB-03F — PFB-T3 arbitrary differential conservation:
# semantic baseline, complete property run, nonvacuity controls,
# mutation sensitivity, final acceptance, and evidence freeze.
#
# Frozen obligations:
#   PFB-T3.P1 — For an arbitrary selected block and two arbitrary byte arrays,
#                packed-output XOR equals the input 24-bit block XOR.
#   PFB-T3.P2 — For that arbitrary block, the three input bytes differ iff
#                the corresponding decoded coefficient pair differs.
#
# Logical relationship:
#   P1 implies blockwise injectivity, so a mutant that breaks P2 will
#   necessarily also break P1. The mutation campaign therefore uses:
#     * a bijective low-byte permutation: P1 fails while P2 remains true;
#     * an information-loss mutation: both P1 and P2 fail.
#
# The authoritative source and prior proof artifacts are never modified.

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
THEOREM_UID="pfb_t3_differential_${STAMP}"
THEOREM_PROOF="$WT/proofs/cbmc/$THEOREM_UID"
THEOREM_HARNESS="$THEOREM_PROOF/${THEOREM_UID}_harness.c"
THEOREM_MAKEFILE="$THEOREM_PROOF/Makefile"
THEOREM_GOTO="$THEOREM_PROOF/gotos/${THEOREM_UID}_harness.goto"

CONTROL_UID="pfb_t3_nonvacuity_${STAMP}"
CONTROL_PROOF="$WT/proofs/cbmc/$CONTROL_UID"
CONTROL_HARNESS="$CONTROL_PROOF/${CONTROL_UID}_harness.c"
CONTROL_MAKEFILE="$CONTROL_PROOF/Makefile"
CONTROL_GOTO="$CONTROL_PROOF/gotos/${CONTROL_UID}_harness.goto"

RUN="$CAMPAIGN/PFB_03F_T3_FINAL_RUN_${STAMP}"
FINAL_FREEZE="$CAMPAIGN/PFB_T3_FINAL_FREEZE_af4c5abd_${STAMP}"
FINAL_ARCHIVE="${FINAL_FREEZE}.tar.gz"
OUT="/tmp/PFB_03F_T3_FINAL_RUN.txt"

mkdir -p \
  "$RUN/binding" \
  "$RUN/baseline" \
  "$RUN/control" \
  "$RUN/mutants" \
  "$RUN/source_binding"

exec > >(tee "$OUT") 2>&1

fail()
{
  echo "FATAL_FAILURE=$1"
  echo "PFB_T3_FINAL_ACCEPTANCE=NO"
  echo "SCRIPT_FINAL_EXIT=1"
  exit 1
}

require_command()
{
  command -v "$1" >/dev/null 2>&1 || fail "COMMAND_NOT_FOUND_$1"
}

for cmd in \
  git sha256sum python3 goto-instrument cbmc make timeout grep awk \
  stat tar find sort xargs cp diff seq tail
do
  require_command "$cmd"
done

latest_directory()
{
  local pattern="$1"

  find "$CAMPAIGN" \
    -maxdepth 1 \
    -type d \
    -name "$pattern" \
    -printf '%T@ %p\n' |
  sort -nr |
  head -n 1 |
  cut -d' ' -f2-
}

T1_FINAL_FREEZE="$(latest_directory 'PFB_T1_FINAL_FREEZE_af4c5abd_*')"
T2_FINAL_FREEZE="$(latest_directory 'PFB_T2_FINAL_FREEZE_af4c5abd_*')"

[ -n "$T1_FINAL_FREEZE" ] || fail "PFB_T1_FINAL_FREEZE_NOT_FOUND"
[ -n "$T2_FINAL_FREEZE" ] || fail "PFB_T2_FINAL_FREEZE_NOT_FOUND"
[ -f "$T1_FINAL_FREEZE/SHA256SUMS.txt" ] ||
  fail "PFB_T1_FINAL_MANIFEST_NOT_FOUND"
[ -f "$T2_FINAL_FREEZE/SHA256SUMS.txt" ] ||
  fail "PFB_T2_FINAL_MANIFEST_NOT_FOUND"

echo "============================================================"
echo "PFB-03F — T3 DIFFERENTIAL CONSERVATION FINAL CAMPAIGN"
echo "============================================================"
echo "STARTED_AT_UTC=$STAMP"
echo "RUN_DIRECTORY=$RUN"
echo "PFB_T1_FINAL_FREEZE=$T1_FINAL_FREEZE"
echo "PFB_T2_FINAL_FREEZE=$T2_FINAL_FREEZE"
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

grep -Fq '"PFB-T3.P1"' "$FREEZE_00C/registry/verification_intent.json" ||
  fail "PFB_T3_P1_NOT_FROZEN"
grep -Fq '"PFB-T3.P2"' "$FREEZE_00C/registry/verification_intent.json" ||
  fail "PFB_T3_P2_NOT_FROZEN"

grep -Fxq 'PFB_T1_FINAL_ACCEPTANCE=YES' \
  "$T1_FINAL_FREEZE/PFB_T1_FINAL_ACCEPTANCE_REPORT.txt" ||
  fail "PFB_T1_FINAL_ACCEPTANCE_GATE_FAILED"

grep -Fxq 'PFB_T2_FINAL_ACCEPTANCE=YES' \
  "$T2_FINAL_FREEZE/PFB_T2_FINAL_ACCEPTANCE_REPORT.txt" ||
  fail "PFB_T2_FINAL_ACCEPTANCE_GATE_FAILED"

echo "PFB_00C_HASH_CHECK=PASS"
echo "PFB_T1_FINAL_HASH_CHECK=PASS"
echo "PFB_T2_FINAL_HASH_CHECK=PASS"
echo "PFB_T1_FINAL_ACCEPTANCE_REBOUND=YES"
echo "PFB_T2_FINAL_ACCEPTANCE_REBOUND=YES"
echo "FROZEN_INTENT_AND_PRIOR_EVIDENCE_BINDING=PASS"

echo
echo "============================================================"
echo "PART 2 — IMMUTABLE SOURCE AND PRIOR ARTIFACT BINDING"
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

echo "IMMUTABLE_SOURCE_AND_PRIOR_ARTIFACT_BINDING=PASS"

echo
echo "============================================================"
echo "PART 3 — CREATE AND AUDIT THE TWO-OBLIGATION PFB-T3 HARNESS"
echo "============================================================"

[ ! -e "$THEOREM_PROOF" ] || fail "THEOREM_PROOF_DIRECTORY_ALREADY_EXISTS"
mkdir -p "$THEOREM_PROOF"

cat > "$THEOREM_HARNESS" <<'EOF_THEOREM'
#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T3 arbitrary differential conservation.
 *
 * Two unrestricted input byte arrays are decoded by the real public
 * mlk_poly_frombytes path. The selected block is unrestricted subject only
 * to its valid range. The arithmetic oracle uses widened byte composition
 * and never calls the target or a production encoder.
 */
void harness(void)
{
  uint8_t first_input[MLKEM_POLYBYTES];
  uint8_t second_input[MLKEM_POLYBYTES];

  mlk_poly first_output;
  mlk_poly second_output;

  size_t block_index;

  uint32_t first_word24;
  uint32_t second_word24;
  uint32_t first_packed_output;
  uint32_t second_packed_output;

  uint8_t input_block_differs;
  uint8_t output_pair_differs;

  __CPROVER_assume(block_index < (MLKEM_N / 2u));

  mlk_poly_frombytes(&first_output, first_input);
  mlk_poly_frombytes(&second_output, second_input);

  first_word24 =
      (uint32_t)first_input[3u * block_index] +
      UINT32_C(256) *
          (uint32_t)first_input[3u * block_index + 1u] +
      UINT32_C(65536) *
          (uint32_t)first_input[3u * block_index + 2u];

  second_word24 =
      (uint32_t)second_input[3u * block_index] +
      UINT32_C(256) *
          (uint32_t)second_input[3u * block_index + 1u] +
      UINT32_C(65536) *
          (uint32_t)second_input[3u * block_index + 2u];

  first_packed_output =
      (uint32_t)(uint16_t)first_output.coeffs[2u * block_index] +
      UINT32_C(4096) *
          (uint32_t)(uint16_t)
              first_output.coeffs[2u * block_index + 1u];

  second_packed_output =
      (uint32_t)(uint16_t)second_output.coeffs[2u * block_index] +
      UINT32_C(4096) *
          (uint32_t)(uint16_t)
              second_output.coeffs[2u * block_index + 1u];

  __CPROVER_assert(
      (first_packed_output ^ second_packed_output) ==
          (first_word24 ^ second_word24),
      "PFB-T3.P1 packed-output XOR equals input 24-bit block XOR");

  input_block_differs =
      (uint8_t)(
          (first_input[3u * block_index] !=
           second_input[3u * block_index]) ||
          (first_input[3u * block_index + 1u] !=
           second_input[3u * block_index + 1u]) ||
          (first_input[3u * block_index + 2u] !=
           second_input[3u * block_index + 2u]));

  output_pair_differs =
      (uint8_t)(
          (first_output.coeffs[2u * block_index] !=
           second_output.coeffs[2u * block_index]) ||
          (first_output.coeffs[2u * block_index + 1u] !=
           second_output.coeffs[2u * block_index + 1u]));

  __CPROVER_assert(
      input_block_differs == output_pair_differs,
      "PFB-T3.P2 input block differs iff decoded pair differs");
}
EOF_THEOREM

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

path.write_text(text, encoding="utf-8")
PY
}

derive_makefile \
  "$THEOREM_MAKEFILE" \
  "${THEOREM_UID}_harness" \
  "$THEOREM_UID" ||
  fail "THEOREM_MAKEFILE_DERIVATION_FAILED"

THEOREM_HARNESS_SHA256="$(sha256sum "$THEOREM_HARNESS" | awk '{print $1}')"
THEOREM_MAKEFILE_SHA256="$(sha256sum "$THEOREM_MAKEFILE" | awk '{print $1}')"
THEOREM_PUBLIC_CALL_COUNT="$(
  grep -Ec '^[[:space:]]*mlk_poly_frombytes\(' "$THEOREM_HARNESS" || true
)"
THEOREM_ASSERTION_COUNT="$(
  grep -c '__CPROVER_assert' "$THEOREM_HARNESS" || true
)"
THEOREM_ASSUME_COUNT="$(
  grep -c '__CPROVER_assume' "$THEOREM_HARNESS" || true
)"

echo "THEOREM_HARNESS_SHA256=$THEOREM_HARNESS_SHA256"
echo "THEOREM_MAKEFILE_SHA256=$THEOREM_MAKEFILE_SHA256"
echo "THEOREM_PUBLIC_CALL_COUNT=$THEOREM_PUBLIC_CALL_COUNT"
echo "THEOREM_ASSERTION_COUNT=$THEOREM_ASSERTION_COUNT"
echo "THEOREM_ASSUME_COUNT=$THEOREM_ASSUME_COUNT"

[ "$THEOREM_PUBLIC_CALL_COUNT" = "2" ] ||
  fail "THEOREM_PUBLIC_CALL_COUNT_WRONG"
[ "$THEOREM_ASSERTION_COUNT" = "2" ] ||
  fail "THEOREM_ASSERTION_COUNT_WRONG"
[ "$THEOREM_ASSUME_COUNT" = "1" ] ||
  fail "THEOREM_ASSUME_COUNT_WRONG"

if grep -Eq \
  'assume[[:space:]]*\([[:space:]]*(false|0)[[:space:]]*\)' \
  "$THEOREM_HARNESS"
then
  fail "ASSUME_FALSE_PRESENT"
fi

if grep -Fq 'mlk_poly_tobytes' "$THEOREM_HARNESS"; then
  fail "PRODUCTION_ENCODER_USED"
fi

if grep -Fq 'mlk_poly_frombytes_c(' "$THEOREM_HARNESS"; then
  fail "PORTABLE_BODY_CALLED_DIRECTLY"
fi

if grep -Eq \
  'USE_FUNCTION_CONTRACTS[[:space:]]*=[[:space:]]*[^[:space:]]|CHECK_FUNCTION_CONTRACTS[[:space:]]*=[[:space:]]*[^[:space:]]|APPLY_LOOP_CONTRACTS[[:space:]]*=[[:space:]]*on|USE_DYNAMIC_FRAMES[[:space:]]*=[[:space:]]*1|--bitwuzla' \
  "$THEOREM_MAKEFILE"
then
  fail "FORBIDDEN_THEOREM_TRANSFORMATION_PRESENT"
fi

cp "$THEOREM_HARNESS" "$RUN/baseline/"
cp "$THEOREM_MAKEFILE" "$RUN/baseline/Makefile"

echo "PFB_T3_THEOREM_HARNESS_AUDIT=PASS"

echo
echo "============================================================"
echo "PART 4 — BUILD, CALL-CHAIN BIND, AND RUN PFB-T3 BASELINE"
echo "============================================================"

set +e
make -C "$THEOREM_PROOF" -j1 \
  > "$RUN/baseline/make.stdout.txt" \
  2> "$RUN/baseline/make.stderr.txt"
THEOREM_MAKE_EXIT=$?

echo "THEOREM_MAKE_EXIT=$THEOREM_MAKE_EXIT"
echo "----- THEOREM MAKE STDOUT TAIL -----"
tail -n 100 "$RUN/baseline/make.stdout.txt" || true
echo "----- THEOREM MAKE STDERR TAIL -----"
tail -n 100 "$RUN/baseline/make.stderr.txt" || true

[ -f "$THEOREM_GOTO" ] || fail "THEOREM_GOTO_NOT_CREATED"

THEOREM_GOTO_SHA256="$(sha256sum "$THEOREM_GOTO" | awk '{print $1}')"
echo "THEOREM_GOTO_SHA256=$THEOREM_GOTO_SHA256"

goto-instrument \
  --show-goto-functions \
  "$THEOREM_GOTO" \
  > "$RUN/binding/theorem.goto_functions.txt" \
  2> "$RUN/binding/theorem.goto_functions.stderr.txt" ||
  fail "THEOREM_GOTO_DUMP_FAILED"

THEOREM_GOTO_PUBLIC_CALLS="$(
  grep -c 'CALL mlk_poly_frombytes(' \
    "$RUN/binding/theorem.goto_functions.txt" || true
)"
THEOREM_GOTO_PORTABLE_CALLS="$(
  grep -c 'CALL mlk_poly_frombytes_c(' \
    "$RUN/binding/theorem.goto_functions.txt" || true
)"

echo "THEOREM_GOTO_PUBLIC_CALL_COUNT=$THEOREM_GOTO_PUBLIC_CALLS"
echo "THEOREM_GOTO_PORTABLE_BODY_CALL_COUNT=$THEOREM_GOTO_PORTABLE_CALLS"

[ "$THEOREM_GOTO_PUBLIC_CALLS" -ge 1 ] ||
  fail "THEOREM_PUBLIC_WRAPPER_CALL_ABSENT"
[ "$THEOREM_GOTO_PORTABLE_CALLS" -ge 1 ] ||
  fail "THEOREM_PORTABLE_BODY_CALL_ABSENT"

if grep -Eq \
  'mlk_poly_frombytes_native|MLK_USE_NATIVE_POLY_FROMBYTES' \
  "$RUN/binding/theorem.goto_functions.txt"
then
  fail "NATIVE_FROMBYTES_PRESENT"
fi

cbmc \
  --unwind 129 \
  --unwinding-assertions \
  --show-properties \
  "$THEOREM_GOTO" \
  > "$RUN/binding/theorem.show_properties.txt" \
  2> "$RUN/binding/theorem.show_properties.stderr.txt" ||
  fail "THEOREM_SHOW_PROPERTIES_FAILED"

grep -Fq 'PFB-T3.P1' "$RUN/binding/theorem.show_properties.txt" ||
  fail "PFB_T3_P1_PROPERTY_ABSENT"
grep -Fq 'PFB-T3.P2' "$RUN/binding/theorem.show_properties.txt" ||
  fail "PFB_T3_P2_PROPERTY_ABSENT"

COMMON_FLAGS=(
  --flush
  --object-bits 8
  --slice-formula
  --unwind 129
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
  local expected_count="$3"

  python3 - "$xml" "$summary" "$expected_count" <<'PY'
from __future__ import annotations

import collections
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

xml_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
expected_count = int(sys.argv[3])

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

for number in range(1, expected_count + 1):
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

    for number in range(1, expected_count + 1):
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

run_cbmc()
{
  local name="$1"
  local timeout_seconds="$2"
  shift 2

  local xml="$RUN/baseline/${name}.xml"
  local stderr="$RUN/baseline/${name}.stderr.txt"
  local summary="$RUN/baseline/${name}.summary.txt"
  local command="$RUN/baseline/${name}.command.txt"
  local exit_file="$RUN/baseline/${name}.exit.txt"
  local cbmc_exit

  {
    printf 'cbmc '
    printf '%q ' "${COMMON_FLAGS[@]}"
    printf '%q ' "$@"
    printf '%q %q\n' --xml-ui "$THEOREM_GOTO"
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
    "$THEOREM_GOTO" \
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

  parse_xml "$xml" "$summary" 2

  echo "----- STDERR[$name] -----"
  cat "$stderr" || true
}

run_cbmc \
  "theorem_only" \
  1800 \
  --property harness.assertion.1 \
  --property harness.assertion.2

run_cbmc \
  "all_properties" \
  1800

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

check_successful_run()
{
  local name="$1"
  local expected_property_count="$2"
  local summary="$RUN/baseline/${name}.summary.txt"
  local exit_file="$RUN/baseline/${name}.exit.txt"

  local cbmc_exit
  local cprover
  local property_count
  local success_count
  local non_success
  local h1
  local h2

  cbmc_exit="$(cat "$exit_file" 2>/dev/null || true)"
  cprover="$(read_value "$summary" CPROVER_STATUS)"
  property_count="$(read_value "$summary" PROPERTY_COUNT)"
  success_count="$(read_value "$summary" SUCCESS_COUNT)"
  non_success="$(read_value "$summary" NON_SUCCESS_COUNT)"
  h1="$(read_value "$summary" H1_STATUS)"
  h2="$(read_value "$summary" H2_STATUS)"

  echo "CHECK[$name].CBMC_EXIT=$cbmc_exit"
  echo "CHECK[$name].CPROVER_STATUS=$cprover"
  echo "CHECK[$name].PROPERTY_COUNT=$property_count"
  echo "CHECK[$name].SUCCESS_COUNT=$success_count"
  echo "CHECK[$name].NON_SUCCESS_COUNT=$non_success"
  echo "CHECK[$name].H1_STATUS=$h1"
  echo "CHECK[$name].H2_STATUS=$h2"

  [ "$cbmc_exit" = "0" ] || fail "CBMC_EXIT_NONZERO_$name"
  [ "$cprover" = "SUCCESS" ] || fail "CPROVER_NOT_SUCCESS_$name"
  [ "$non_success" = "0" ] || fail "NON_SUCCESS_PRESENT_$name"
  [ "$success_count" = "$property_count" ] ||
    fail "NOT_ALL_PROPERTIES_SUCCESS_$name"
  [ "$h1" = "SUCCESS" ] || fail "PFB_T3_P1_NOT_SUCCESS_$name"
  [ "$h2" = "SUCCESS" ] || fail "PFB_T3_P2_NOT_SUCCESS_$name"

  if [ "$expected_property_count" != "ANY" ]; then
    [ "$property_count" = "$expected_property_count" ] ||
      fail "PROPERTY_COUNT_WRONG_$name"
  fi
}

check_successful_run "theorem_only" "2"
check_successful_run "all_properties" "ANY"

ALL_PROPERTY_COUNT="$(
  read_value "$RUN/baseline/all_properties.summary.txt" PROPERTY_COUNT
)"
ALL_SUCCESS_COUNT="$(
  read_value "$RUN/baseline/all_properties.summary.txt" SUCCESS_COUNT
)"

echo "PFB_T3_P1_STATUS=SUCCESS"
echo "PFB_T3_P2_STATUS=SUCCESS"
echo "PFB_T3_SEMANTIC_BASELINE=PASS"
echo "PFB_T3_COMPLETE_PROPERTY_RUN=PASS"

echo
echo "============================================================"
echo "PART 5 — CONCRETE NONVACUITY AND BOUNDARY CONTROLS"
echo "============================================================"

[ ! -e "$CONTROL_PROOF" ] || fail "CONTROL_PROOF_DIRECTORY_ALREADY_EXISTS"
mkdir -p "$CONTROL_PROOF"

cat > "$CONTROL_HARNESS" <<'EOF_CONTROL'
#include <stdint.h>

#include "compress.h"

static uint32_t pack_pair(const mlk_poly *p, uint32_t block_index)
{
  return
      (uint32_t)(uint16_t)p->coeffs[2u * block_index] +
      UINT32_C(4096) *
          (uint32_t)(uint16_t)p->coeffs[2u * block_index + 1u];
}

/*
 * Concrete witnesses cover:
 *   * equal inputs and equal outputs at block 0;
 *   * a first-byte difference at block 0;
 *   * a middle-byte difference at block 127;
 *   * a third-byte difference at block 127.
 *
 * There are no assumptions in this control harness.
 */
void harness(void)
{
  uint8_t zero_input[MLKEM_POLYBYTES] = {0};
  uint8_t same_input[MLKEM_POLYBYTES] = {0};
  uint8_t first_byte_input[MLKEM_POLYBYTES] = {0};
  uint8_t middle_byte_input[MLKEM_POLYBYTES] = {0};
  uint8_t third_byte_input[MLKEM_POLYBYTES] = {0};

  mlk_poly zero_output;
  mlk_poly same_output;
  mlk_poly first_byte_output;
  mlk_poly middle_byte_output;
  mlk_poly third_byte_output;

  first_byte_input[0] = 0x01u;
  middle_byte_input[3u * 127u + 1u] = 0xF0u;
  third_byte_input[3u * 127u + 2u] = 0x80u;

  mlk_poly_frombytes(&zero_output, zero_input);
  mlk_poly_frombytes(&same_output, same_input);
  mlk_poly_frombytes(&first_byte_output, first_byte_input);
  mlk_poly_frombytes(&middle_byte_output, middle_byte_input);
  mlk_poly_frombytes(&third_byte_output, third_byte_input);

  __CPROVER_assert(
      (pack_pair(&zero_output, 0u) ^
       pack_pair(&same_output, 0u)) == UINT32_C(0),
      "PFB-T3 control equal block has zero packed-output XOR");

  __CPROVER_assert(
      (zero_output.coeffs[0] == same_output.coeffs[0]) &&
          (zero_output.coeffs[1] == same_output.coeffs[1]),
      "PFB-T3 control equal input block has equal decoded pair");

  __CPROVER_assert(
      (pack_pair(&zero_output, 0u) ^
       pack_pair(&first_byte_output, 0u)) == UINT32_C(1),
      "PFB-T3 control block-0 first-byte XOR is conserved");

  __CPROVER_assert(
      (zero_output.coeffs[0] != first_byte_output.coeffs[0]) ||
          (zero_output.coeffs[1] != first_byte_output.coeffs[1]),
      "PFB-T3 control block-0 first-byte change changes pair");

  __CPROVER_assert(
      (pack_pair(&zero_output, 127u) ^
       pack_pair(&middle_byte_output, 127u)) == UINT32_C(61440),
      "PFB-T3 control block-127 middle-byte XOR is conserved");

  __CPROVER_assert(
      (zero_output.coeffs[254] != middle_byte_output.coeffs[254]) ||
          (zero_output.coeffs[255] != middle_byte_output.coeffs[255]),
      "PFB-T3 control block-127 middle-byte change changes pair");

  __CPROVER_assert(
      (pack_pair(&zero_output, 127u) ^
       pack_pair(&third_byte_output, 127u)) == UINT32_C(8388608),
      "PFB-T3 control block-127 third-byte XOR is conserved");

  __CPROVER_assert(
      (zero_output.coeffs[254] != third_byte_output.coeffs[254]) ||
          (zero_output.coeffs[255] != third_byte_output.coeffs[255]),
      "PFB-T3 control block-127 third-byte change changes pair");
}
EOF_CONTROL

derive_makefile \
  "$CONTROL_MAKEFILE" \
  "${CONTROL_UID}_harness" \
  "$CONTROL_UID" ||
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

[ "$CONTROL_PUBLIC_CALL_COUNT" = "5" ] ||
  fail "CONTROL_PUBLIC_CALL_COUNT_WRONG"
[ "$CONTROL_ASSERTION_COUNT" = "8" ] ||
  fail "CONTROL_ASSERTION_COUNT_WRONG"
[ "$CONTROL_ASSUME_COUNT" = "0" ] ||
  fail "CONTROL_ASSUME_COUNT_WRONG"

cp "$CONTROL_HARNESS" "$RUN/control/"
cp "$CONTROL_MAKEFILE" "$RUN/control/Makefile"

set +e
make -C "$CONTROL_PROOF" -j1 \
  > "$RUN/control/make.stdout.txt" \
  2> "$RUN/control/make.stderr.txt"
CONTROL_MAKE_EXIT=$?

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
  1800 \
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
[ "$(read_value "$RUN/control/summary.txt" XML_PARSE)" = "PASS" ] ||
  fail "CONTROL_XML_PARSE_FAILED"
[ "$(read_value "$RUN/control/summary.txt" CPROVER_STATUS)" = "SUCCESS" ] ||
  fail "CONTROL_CPROVER_NOT_SUCCESS"
[ "$(read_value "$RUN/control/summary.txt" NON_SUCCESS_COUNT)" = "0" ] ||
  fail "CONTROL_NON_SUCCESS_PRESENT"

for number in 1 2 3 4 5 6 7 8; do
  [ "$(read_value "$RUN/control/summary.txt" "H${number}_STATUS")" = "SUCCESS" ] ||
    fail "CONTROL_ASSERTION_${number}_NOT_SUCCESS"
done

echo "PFB_T3_NONVACUITY_AND_BOUNDARY_CONTROL=PASS"
echo "PFB_T3_CONTROL_ASSERTIONS=8_OF_8_SUCCESS"

echo
echo "============================================================"
echo "PART 6 — LOGIC-AWARE TARGETED MUTATION SENSITIVITY"
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
  local old_text="$2"
  local new_text="$3"
  local expected_h1="$4"
  local expected_h2="$5"

  local mut_wt="$ROOT/_cbmc_work/mlkem-native_pfb_t3_${mutant_name}_${STAMP}"
  local mut_uid="pfb_t3_${mutant_name}_${STAMP}"
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
  cp "$THEOREM_HARNESS" "$mut_harness"

  derive_makefile \
    "$mut_makefile" \
    "${mut_uid}_harness" \
    "$mut_uid" ||
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
  
  echo "MAKE_EXIT[$mutant_name]=$make_exit"
  [ -f "$mut_goto" ] || fail "MUTANT_GOTO_NOT_CREATED_$mutant_name"

  echo "MUTANT_GOTO_SHA256[$mutant_name]=$(
    sha256sum "$mut_goto" | awk '{print $1}'
  )"

  if timeout \
    --signal=TERM \
    1800 \
    cbmc \
    "${COMMON_FLAGS[@]}" \
    --property harness.assertion.1 \
    --property harness.assertion.2 \
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

  parse_xml "$mut_record/result.xml" "$mut_record/summary.txt" 2

  local cprover
  local property_count
  local failure_count
  local error_count
  local unknown_count
  local non_success
  local h1
  local h2

  cprover="$(read_value "$mut_record/summary.txt" CPROVER_STATUS)"
  property_count="$(read_value "$mut_record/summary.txt" PROPERTY_COUNT)"
  failure_count="$(read_value "$mut_record/summary.txt" FAILURE_COUNT)"
  error_count="$(read_value "$mut_record/summary.txt" ERROR_COUNT)"
  unknown_count="$(read_value "$mut_record/summary.txt" UNKNOWN_COUNT)"
  non_success="$(read_value "$mut_record/summary.txt" NON_SUCCESS_COUNT)"
  h1="$(read_value "$mut_record/summary.txt" H1_STATUS)"
  h2="$(read_value "$mut_record/summary.txt" H2_STATUS)"

  echo "MUTANT_RESULT[$mutant_name].CPROVER_STATUS=$cprover"
  echo "MUTANT_RESULT[$mutant_name].PROPERTY_COUNT=$property_count"
  echo "MUTANT_RESULT[$mutant_name].FAILURE_COUNT=$failure_count"
  echo "MUTANT_RESULT[$mutant_name].ERROR_COUNT=$error_count"
  echo "MUTANT_RESULT[$mutant_name].UNKNOWN_COUNT=$unknown_count"
  echo "MUTANT_RESULT[$mutant_name].NON_SUCCESS_COUNT=$non_success"
  echo "MUTANT_RESULT[$mutant_name].H1_STATUS=$h1"
  echo "MUTANT_RESULT[$mutant_name].H2_STATUS=$h2"

  [ "$MUTANT_CBMC_EXIT" = "10" ] ||
    fail "MUTANT_EXIT_NOT_10_$mutant_name"
  [ "$cprover" = "FAILURE" ] ||
    fail "MUTANT_CPROVER_NOT_FAILURE_$mutant_name"
  [ "$property_count" = "2" ] ||
    fail "MUTANT_PROPERTY_COUNT_WRONG_$mutant_name"
  [ "$error_count" = "0" ] ||
    fail "MUTANT_ERROR_PRESENT_$mutant_name"
  [ "$unknown_count" = "0" ] ||
    fail "MUTANT_UNKNOWN_PRESENT_$mutant_name"
  [ "$h1" = "$expected_h1" ] ||
    fail "MUTANT_H1_STATUS_WRONG_$mutant_name"
  [ "$h2" = "$expected_h2" ] ||
    fail "MUTANT_H2_STATUS_WRONG_$mutant_name"

  if [ "$expected_h1" = "FAILURE" ] &&
     [ "$expected_h2" = "SUCCESS" ]; then
    [ "$failure_count" = "1" ] ||
      fail "MUTANT_FAILURE_COUNT_WRONG_$mutant_name"
    [ "$non_success" = "1" ] ||
      fail "MUTANT_NON_SUCCESS_COUNT_WRONG_$mutant_name"
  elif [ "$expected_h1" = "FAILURE" ] &&
       [ "$expected_h2" = "FAILURE" ]; then
    [ "$failure_count" = "2" ] ||
      fail "MUTANT_FAILURE_COUNT_WRONG_$mutant_name"
    [ "$non_success" = "2" ] ||
      fail "MUTANT_NON_SUCCESS_COUNT_WRONG_$mutant_name"
  else
    fail "UNSUPPORTED_MUTANT_EXPECTATION_$mutant_name"
  fi

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
BIJECTIVE_NEW='r->coeffs[2 * i + 0] = (int16_t)((((((uint16_t)t0 << 1) | ((uint16_t)t0 >> 7)) & 0xFF) | (((uint16_t)t1 << 8) & 0xFFF)));'

ODD_OLD='r->coeffs[2 * i + 1] = (int16_t)((t1 >> 4) | (t2 << 4));'
LOSSY_NEW='r->coeffs[2 * i + 1] = (int16_t)((t1 >> 4) | ((t2 & 0x7F) << 4));'

run_mutant \
  "p1_bijective_permutation" \
  "$EVEN_OLD" \
  "$BIJECTIVE_NEW" \
  "FAILURE" \
  "SUCCESS"

run_mutant \
  "p2_information_loss" \
  "$ODD_OLD" \
  "$LOSSY_NEW" \
  "FAILURE" \
  "FAILURE"

echo "PFB_T3_P1_BIJECTIVE_MUTANT_KILLED=YES"
echo "PFB_T3_P2_INFORMATION_LOSS_MUTANT_KILLED=YES"
echo "PFB_T3_MUTATION_SENSITIVITY=PASS"
echo "PFB_T3_LOGICAL_DEPENDENCY_RECORDED=P1_IMPLIES_P2"

echo
echo "============================================================"
echo "PART 7 — POST-MUTATION IMMUTABILITY"
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

THEOREM_HARNESS_AFTER="$(sha256sum "$THEOREM_HARNESS" | awk '{print $1}')"
THEOREM_MAKEFILE_AFTER="$(sha256sum "$THEOREM_MAKEFILE" | awk '{print $1}')"
THEOREM_GOTO_AFTER="$(sha256sum "$THEOREM_GOTO" | awk '{print $1}')"

echo "THEOREM_HARNESS_SHA256_AFTER=$THEOREM_HARNESS_AFTER"
echo "THEOREM_MAKEFILE_SHA256_AFTER=$THEOREM_MAKEFILE_AFTER"
echo "THEOREM_GOTO_SHA256_AFTER=$THEOREM_GOTO_AFTER"

[ "$THEOREM_HARNESS_AFTER" = "$THEOREM_HARNESS_SHA256" ] ||
  fail "THEOREM_HARNESS_CHANGED"
[ "$THEOREM_MAKEFILE_AFTER" = "$THEOREM_MAKEFILE_SHA256" ] ||
  fail "THEOREM_MAKEFILE_CHANGED"
[ "$THEOREM_GOTO_AFTER" = "$THEOREM_GOTO_SHA256" ] ||
  fail "THEOREM_GOTO_CHANGED"

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
echo "PFB_T3_BASELINE_ARTIFACTS_UNCHANGED=YES"
echo "MUTATIONS_ISOLATED_TO_DETACHED_WORKTREES=YES"

echo
echo "============================================================"
echo "PART 8 — FINAL PFB-T3 ACCEPTANCE AND EVIDENCE FREEZE"
echo "============================================================"

mkdir -p \
  "$FINAL_FREEZE/prior_evidence" \
  "$FINAL_FREEZE/baseline" \
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

cp -a "$RUN/baseline/." "$FINAL_FREEZE/baseline/"
cp -a "$RUN/control/." "$FINAL_FREEZE/control/"
cp -a "$RUN/mutants/." "$FINAL_FREEZE/mutants/"

cat > "$FINAL_FREEZE/source_binding/SOURCE_IDENTITY.txt" <<EOF_SOURCE
SOURCE_COMMIT=$EXPECTED_COMMIT
SOURCE_TREE=$EXPECTED_TREE
COMPRESS_SOURCE_SHA256=$EXPECTED_COMPRESS_SHA256
COMPRESS_HEADER_SHA256=$EXPECTED_COMPRESS_H_SHA256
PARAMS_HEADER_SHA256=$EXPECTED_PARAMS_SHA256
THEOREM_HARNESS_SHA256=$THEOREM_HARNESS_SHA256
THEOREM_MAKEFILE_SHA256=$THEOREM_MAKEFILE_SHA256
THEOREM_GOTO_SHA256=$THEOREM_GOTO_SHA256
EOF_SOURCE

cat > "$FINAL_FREEZE/PFB_T3_FINAL_ACCEPTANCE_REPORT.txt" <<EOF_REPORT
PFB_STAGE=PFB-T3-FINAL
PFB_T3_FINAL_ACCEPTANCE=YES
FROZEN_AT_UTC=$STAMP
SOURCE_COMMIT=$EXPECTED_COMMIT
SOURCE_TREE=$EXPECTED_TREE
INITIAL_CONFIGURATION=portable ML-KEM-768
PUBLIC_TARGET=mlk_poly_frombytes
PORTABLE_BODY=mlk_poly_frombytes_c
PFB_T3_P1_PACKED_OUTPUT_XOR_CONSERVATION=PROVED
PFB_T3_P2_BLOCK_DIFFERENCE_IFF_PAIR_DIFFERENCE=PROVED
THEOREM_SET=2_OF_2_SUCCESS
COMPLETE_PROPERTY_SET=${ALL_SUCCESS_COUNT}_OF_${ALL_PROPERTY_COUNT}_SUCCESS
NONVACUITY_AND_BOUNDARY_CONTROL=PASS
NONVACUITY_CONTROL_ASSERTIONS=8_OF_8_SUCCESS
PFB_T3_P1_BIJECTIVE_MUTANT_KILLED=YES
PFB_T3_P1_BIJECTIVE_MUTANT_P2_STATUS=SUCCESS
PFB_T3_P2_INFORMATION_LOSS_MUTANT_KILLED=YES
PFB_T3_P2_INFORMATION_LOSS_MUTANT_P1_STATUS=FAILURE
PFB_T3_P2_INFORMATION_LOSS_MUTANT_P2_STATUS=FAILURE
LOGICAL_DEPENDENCY=PFB-T3.P1_IMPLIES_PFB-T3.P2
MUTATION_SENSITIVITY=PASS
FUNCTION_CONTRACT_SUBSTITUTION=NO
LOOP_CONTRACT_APPLICATION=NO
DEFAULT_SAT_BACKEND=YES
NATIVE_BACKEND_CLAIM=EXCLUDED
PFB_T1_ARTIFACTS_UNCHANGED=YES
PFB_T2_ARTIFACTS_UNCHANGED=YES
PFB_T3_BASELINE_ARTIFACTS_UNCHANGED=YES
PRODUCTION_SOURCE_MODIFIED=NO
AUTHORITATIVE_TREE_CLEAN=YES
MATHEMATICAL_WORLD_FIRST_CLAIM=NO
ALLOWED_CLAIM=At commit af4c5abd, the portable public mlk_poly_frombytes path was verified by CBMC for the two frozen PFB-T3 arbitrary differential-conservation obligations over two arbitrary input byte arrays and an arbitrary valid block index, under the recorded machine model and proof configuration.
FINAL_FREEZE_DIRECTORY=$FINAL_FREEZE
TERMINAL_OUTPUT=$OUT
EOF_REPORT

cp "$OUT" "$FINAL_FREEZE/PFB_03F_TERMINAL_OUTPUT.txt"

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

cat "$FINAL_FREEZE/PFB_T3_FINAL_ACCEPTANCE_REPORT.txt"

echo "FINAL_MANIFEST_SHA256=$FINAL_MANIFEST_SHA256"
echo "FINAL_ARCHIVE=$FINAL_ARCHIVE"
echo "FINAL_ARCHIVE_SHA256=$FINAL_ARCHIVE_SHA256"

echo
echo "============================================================"
echo "PFB-03F COMPLETE"
echo "PFB-T3 FINAL ACCEPTANCE=YES"
echo "BOTH FROZEN PFB-T3 OBLIGATIONS PROVED"
echo "ALL EIGHT NONVACUITY CONTROL ASSERTIONS PASSED"
echo "BIJECTIVE AND INFORMATION-LOSS MUTANTS KILLED"
echo "FAIL-CLOSED EVIDENCE FREEZE CREATED"
echo "NO PRIOR OR PFB-T3 BASELINE ARTIFACT MODIFIED"
echo "NO AUTHORITATIVE PRODUCTION SOURCE MODIFIED"
echo "SCRIPT_FINAL_EXIT=0"
echo "============================================================"

exit 0
