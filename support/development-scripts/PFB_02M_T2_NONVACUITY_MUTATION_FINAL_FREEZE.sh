#!/usr/bin/env bash
#
# PFB-02M — PFB-T2 nonvacuity, targeted mutation sensitivity, final acceptance,
# evidence freeze, and deterministic archive creation.
#
# Frozen obligations:
#   PFB-T2.P1 — first-byte bit j routes exactly to even bit j.
#   PFB-T2.P2 — second-byte low-nibble bit j routes exactly to even bit 8+j.
#   PFB-T2.P3 — second-byte high-nibble bit j routes exactly to odd bit j.
#   PFB-T2.P4 — third-byte bit j routes exactly to odd bit 4+j.
#   PFB-T2.P5 — arbitrary change in one 3-byte block leaves all other
#                coefficient pairs unchanged.
#
# This runner:
#   1. Rebinds PFB-00C, PFB-T1, PFB-02A and PFB-02R evidence.
#   2. Proves concrete boundary/nonvacuity witnesses using the real public path.
#   3. Creates five isolated detached source mutants, one for each obligation.
#   4. Requires the corresponding frozen assertion to detect each mutant.
#   5. Rechecks authoritative and original-worktree integrity.
#   6. Creates a fail-closed PFB-T2 final freeze and tar.gz archive.
#
# The authoritative source and original proof artifacts are never modified.

set -uo pipefail
umask 022

ROOT="$HOME/THESIS-2026"
AUTH="$ROOT/mlkem-native_af4c5abd"
WT="$ROOT/_cbmc_work/mlkem-native_pfb_af4c5abd"
CAMPAIGN="$ROOT/mlk_poly_frombytes_cleanroom"
FREEZE_00C="$CAMPAIGN/PFB_00C_THEOREM_FREEZE_af4c5abd"

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

EXPECTED_BIT_HARNESS_SHA256="7cd0a8e512283677d3a191e0a714bca7f0b481600b3905ef4f3759ab4b1f9aff"
EXPECTED_BIT_MAKEFILE_SHA256="52c8a9b74ed60073766822d0ace381d6bf0b61c0e0da596e488e86122d982ad0"
EXPECTED_BIT_GOTO_SHA256="7e379a693c5c4050751e2f4f7ee695a812016bc20be03fe042818c37713fb7ef"

EXPECTED_LOCAL_HARNESS_SHA256="b52a5e2eefe10204563539c38cc9332d7571ca99ec785c887b3c407488120dfd"
EXPECTED_LOCAL_MAKEFILE_SHA256="bc967aa5116b4c81c6abb192ac7f1d736e682f0bd21d8f83bf6300287482afc6"
EXPECTED_LOCAL_GOTO_SHA256="4e0b7038eadd97d8c4efac19cb0d090f00cd8349cae1b6b98f19b538486c74fe"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN="$CAMPAIGN/PFB_02M_T2_FINAL_MUTATION_RUN_${STAMP}"
FINAL_FREEZE="$CAMPAIGN/PFB_T2_FINAL_FREEZE_af4c5abd_${STAMP}"
FINAL_ARCHIVE="${FINAL_FREEZE}.tar.gz"
OUT="/tmp/PFB_02M_T2_FINAL_MUTATION_FREEZE.txt"

CONTROL_UID="pfb_t2_nonvacuity_${STAMP}"
CONTROL_PROOF="$WT/proofs/cbmc/$CONTROL_UID"
CONTROL_HARNESS="$CONTROL_PROOF/${CONTROL_UID}_harness.c"
CONTROL_MAKEFILE="$CONTROL_PROOF/Makefile"
CONTROL_GOTO="$CONTROL_PROOF/gotos/${CONTROL_UID}_harness.goto"

mkdir -p "$RUN"/{binding,control,mutants,results,source_binding}
exec > >(tee "$OUT") 2>&1

fail()
{
  echo "FATAL_FAILURE=$1"
  echo "PFB_T2_FINAL_ACCEPTANCE=NO"
  echo "SCRIPT_FINAL_EXIT=1"
  exit 1
}

require_command()
{
  command -v "$1" >/dev/null 2>&1 || fail "COMMAND_NOT_FOUND_$1"
}

for cmd in \
  git sha256sum python3 goto-instrument cbmc make timeout grep awk sed \
  stat tar find sort xargs cp diff seq
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

PFB_02A_RUN="$(latest_directory 'PFB_02A_T2_SEMANTIC_BASELINE_*')"
[ -n "$PFB_02A_RUN" ] || fail "PFB_02A_RUN_NOT_FOUND"
[ -f "$PFB_02A_RUN/PFB_02R_CORRECTED_RESULT.txt" ] ||
  fail "PFB_02R_CORRECTED_RESULT_NOT_FOUND"
[ -f "$PFB_02A_RUN/SHA256SUMS.PFB_02R.txt" ] ||
  fail "PFB_02R_MANIFEST_NOT_FOUND"

echo "============================================================"
echo "PFB-02M — T2 NONVACUITY, MUTATION, AND FINAL FREEZE"
echo "============================================================"
echo "STARTED_AT_UTC=$STAMP"
echo "RUN_DIRECTORY=$RUN"
echo "SOURCE_PFB_02A_DIRECTORY=$PFB_02A_RUN"
echo "FINAL_FREEZE_DIRECTORY=$FINAL_FREEZE"
echo "FINAL_ARCHIVE=$FINAL_ARCHIVE"
echo "TERMINAL_OUTPUT=$OUT"

echo
echo "============================================================"
echo "PART 1 — PRIOR EVIDENCE FAIL-CLOSED RE-BINDING"
echo "============================================================"

[ -d "$FREEZE_00C" ] || fail "PFB_00C_FREEZE_ABSENT"
(
  cd "$FREEZE_00C" || exit 1
  sha256sum -c SHA256SUMS.txt
) || fail "PFB_00C_HASH_CHECK_FAILED"

(
  cd "$PFB_02A_RUN" || exit 1
  sha256sum -c SHA256SUMS.PFB_02R.txt
) || fail "PFB_02R_HASH_CHECK_FAILED"

require_gate()
{
  local file="$1"
  local key="$2"
  local value="$3"

  if grep -Fxq "${key}=${value}" "$file"; then
    echo "GATE[${key}=${value}]=PASS"
  else
    fail "PRIOR_GATE_MISSING_${key}_${value}"
  fi
}

CORRECTED="$PFB_02A_RUN/PFB_02R_CORRECTED_RESULT.txt"

require_gate "$CORRECTED" "PFB_T2_P1_STATUS" "SUCCESS"
require_gate "$CORRECTED" "PFB_T2_P2_STATUS" "SUCCESS"
require_gate "$CORRECTED" "PFB_T2_P3_STATUS" "SUCCESS"
require_gate "$CORRECTED" "PFB_T2_P4_STATUS" "SUCCESS"
require_gate "$CORRECTED" "PFB_T2_P5_STATUS" "SUCCESS"
require_gate "$CORRECTED" "BIT_ROUTES_THEOREM_PROPERTY_COUNT" "4"
require_gate "$CORRECTED" "BIT_ROUTES_THEOREM_SUCCESS_COUNT" "4"
require_gate "$CORRECTED" "BIT_ROUTES_COMPLETE_PROPERTY_COUNT" "170"
require_gate "$CORRECTED" "BIT_ROUTES_COMPLETE_SUCCESS_COUNT" "170"
require_gate "$CORRECTED" "BLOCK_LOCALITY_THEOREM_PROPERTY_COUNT" "1"
require_gate "$CORRECTED" "BLOCK_LOCALITY_THEOREM_SUCCESS_COUNT" "1"
require_gate "$CORRECTED" "BLOCK_LOCALITY_COMPLETE_PROPERTY_COUNT" "102"
require_gate "$CORRECTED" "BLOCK_LOCALITY_COMPLETE_SUCCESS_COUNT" "102"
require_gate "$CORRECTED" "ALL_NON_SUCCESS_COUNT" "0"
require_gate "$CORRECTED" "DEFAULT_SAT_BACKEND" "YES"
require_gate "$CORRECTED" "FUNCTION_CONTRACT_SUBSTITUTION" "NO"
require_gate "$CORRECTED" "LOOP_CONTRACT_APPLICATION" "NO"
require_gate "$CORRECTED" "PFB_T1_ARTIFACTS_UNCHANGED" "YES"
require_gate "$CORRECTED" "PRODUCTION_SOURCE_MODIFIED" "NO"
require_gate "$CORRECTED" "AUTHORITATIVE_TREE_CLEAN" "YES"
require_gate "$CORRECTED" "PFB_T2_SEMANTIC_BASELINE" "PASS"

echo "PRIOR_EVIDENCE_FAIL_CLOSED_REBINDING=PASS"

echo
echo "============================================================"
echo "PART 2 — IMMUTABLE SOURCE AND PROOF-ARTIFACT BINDING"
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

bind_hash "BIT_HARNESS" "$BIT_HARNESS" "$EXPECTED_BIT_HARNESS_SHA256"
bind_hash "BIT_MAKEFILE" "$BIT_MAKEFILE" "$EXPECTED_BIT_MAKEFILE_SHA256"
bind_hash "BIT_GOTO" "$BIT_GOTO" "$EXPECTED_BIT_GOTO_SHA256"

bind_hash "LOCAL_HARNESS" "$LOCAL_HARNESS" "$EXPECTED_LOCAL_HARNESS_SHA256"
bind_hash "LOCAL_MAKEFILE" "$LOCAL_MAKEFILE" "$EXPECTED_LOCAL_MAKEFILE_SHA256"
bind_hash "LOCAL_GOTO" "$LOCAL_GOTO" "$EXPECTED_LOCAL_GOTO_SHA256"

echo "IMMUTABLE_ARTIFACT_BINDING=PASS"

echo
echo "============================================================"
echo "PART 3 — CREATE CONCRETE NONVACUITY AND BOUNDARY CONTROL"
echo "============================================================"

[ ! -e "$CONTROL_PROOF" ] || fail "CONTROL_PROOF_DIRECTORY_ALREADY_EXISTS"
mkdir -p "$CONTROL_PROOF"

cat > "$CONTROL_HARNESS" <<'EOF_CONTROL'
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
EOF_CONTROL

cp "$BIT_MAKEFILE" "$CONTROL_MAKEFILE"

python3 - \
  "$CONTROL_MAKEFILE" \
  "$CONTROL_UID" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
uid = sys.argv[2]
text = path.read_text(encoding="utf-8")

replacements = [
    (
        "HARNESS_FILE = pfb_t2_bit_routes_harness",
        f"HARNESS_FILE = {uid}_harness",
    ),
    (
        "PROOF_UID = pfb_t2_bit_routes",
        f"PROOF_UID = {uid}",
    ),
]

for old, new in replacements:
    count = text.count(old)
    print(f"CONTROL_MAKEFILE_REPLACEMENT_COUNT[{old}]={count}")
    if count != 1:
        raise SystemExit(
            f"Expected one occurrence of {old!r}, found {count}"
        )
    text = text.replace(old, new, 1)

path.write_text(text, encoding="utf-8")
PY
[ "$?" = "0" ] || fail "CONTROL_MAKEFILE_DERIVATION_FAILED"

CONTROL_HARNESS_SHA256="$(sha256sum "$CONTROL_HARNESS" | awk '{print $1}')"
CONTROL_MAKEFILE_SHA256="$(sha256sum "$CONTROL_MAKEFILE" | awk '{print $1}')"
CONTROL_CALL_COUNT="$(
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
echo "CONTROL_PUBLIC_CALL_COUNT=$CONTROL_CALL_COUNT"
echo "CONTROL_ASSERTION_COUNT=$CONTROL_ASSERTION_COUNT"
echo "CONTROL_ASSUME_COUNT=$CONTROL_ASSUME_COUNT"

[ "$CONTROL_CALL_COUNT" = "6" ] || fail "CONTROL_CALL_COUNT_WRONG"
[ "$CONTROL_ASSERTION_COUNT" = "7" ] || fail "CONTROL_ASSERTION_COUNT_WRONG"
[ "$CONTROL_ASSUME_COUNT" = "0" ] || fail "CONTROL_ASSUME_COUNT_WRONG"

if grep -Eq \
  'USE_FUNCTION_CONTRACTS[[:space:]]*=[[:space:]]*[^[:space:]]|CHECK_FUNCTION_CONTRACTS[[:space:]]*=[[:space:]]*[^[:space:]]|APPLY_LOOP_CONTRACTS[[:space:]]*=[[:space:]]*on|USE_DYNAMIC_FRAMES[[:space:]]*=[[:space:]]*1|--bitwuzla' \
  "$CONTROL_MAKEFILE"
then
  fail "FORBIDDEN_CONTROL_TRANSFORMATION_PRESENT"
fi

cp "$CONTROL_HARNESS" "$RUN/control/"
cp "$CONTROL_MAKEFILE" "$RUN/control/Makefile"

echo "CONTROL_HARNESS_AUDIT=PASS"

echo
echo "============================================================"
echo "PART 4 — BUILD AND RUN COMPLETE NONVACUITY CONTROL"
echo "============================================================"

set +e
make -C "$CONTROL_PROOF" -j1 \
  > "$RUN/control/make.stdout.txt" \
  2> "$RUN/control/make.stderr.txt"
CONTROL_MAKE_EXIT=$?

echo "CONTROL_MAKE_EXIT=$CONTROL_MAKE_EXIT"
echo "----- CONTROL MAKE STDOUT TAIL -----"
tail -n 100 "$RUN/control/make.stdout.txt" || true
echo "----- CONTROL MAKE STDERR TAIL -----"
tail -n 100 "$RUN/control/make.stderr.txt" || true

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
echo "CONTROL_XML_SIZE=$(stat -c '%s' "$RUN/control/result.xml" 2>/dev/null || echo 0)"
echo "CONTROL_STDERR_SIZE=$(stat -c '%s' "$RUN/control/result.stderr.txt" 2>/dev/null || echo 0)"

python3 - "$RUN/control/result.xml" "$RUN/control/summary.txt" <<'PY'
from __future__ import annotations

import collections
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

xml_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])

values = {
    "XML_PARSE": "FAIL",
    "CPROVER_STATUS": "NONE",
    "PROPERTY_COUNT": "0",
    "SUCCESS_COUNT": "0",
    "NON_SUCCESS_COUNT": "0",
    "HARNESS_ASSERTION_COUNT": "0",
    "HARNESS_ASSERTION_SUCCESS_COUNT": "0",
}

for number in range(1, 8):
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

    harness_results = [
        element
        for element in results
        if element.attrib.get("property", "").startswith("harness.assertion.")
    ]

    values["XML_PARSE"] = "PASS"
    values["CPROVER_STATUS"] = (
        "|".join(cprover_nodes) if cprover_nodes else "NONE"
    )
    values["PROPERTY_COUNT"] = str(len(results))
    values["SUCCESS_COUNT"] = str(counts.get("SUCCESS", 0))
    values["NON_SUCCESS_COUNT"] = str(
        sum(
            1
            for result in results
            if result.attrib.get("status") != "SUCCESS"
        )
    )
    values["HARNESS_ASSERTION_COUNT"] = str(len(harness_results))
    values["HARNESS_ASSERTION_SUCCESS_COUNT"] = str(
        sum(
            1
            for result in harness_results
            if result.attrib.get("status") == "SUCCESS"
        )
    )

    for number in range(1, 8):
        values[f"H{number}_STATUS"] = statuses.get(
            f"harness.assertion.{number}",
            "ABSENT",
        )

except Exception as exc:
    print(f"CONTROL_XML_PARSE_EXCEPTION={exc!r}")

summary_path.write_text(
    "".join(f"{key}={value}\n" for key, value in values.items()),
    encoding="utf-8",
)

for key, value in values.items():
    print(f"CONTROL_{key}={value}")
PY

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

CONTROL_SUMMARY="$RUN/control/summary.txt"

[ "$CONTROL_CBMC_EXIT" = "0" ] || fail "CONTROL_CBMC_EXIT_NONZERO"
[ "$(read_value "$CONTROL_SUMMARY" XML_PARSE)" = "PASS" ] ||
  fail "CONTROL_XML_PARSE_FAILED"
[ "$(read_value "$CONTROL_SUMMARY" CPROVER_STATUS)" = "SUCCESS" ] ||
  fail "CONTROL_CPROVER_NOT_SUCCESS"
[ "$(read_value "$CONTROL_SUMMARY" NON_SUCCESS_COUNT)" = "0" ] ||
  fail "CONTROL_NON_SUCCESS_PRESENT"
[ "$(read_value "$CONTROL_SUMMARY" HARNESS_ASSERTION_COUNT)" = "7" ] ||
  fail "CONTROL_HARNESS_ASSERTION_COUNT_WRONG"
[ "$(read_value "$CONTROL_SUMMARY" HARNESS_ASSERTION_SUCCESS_COUNT)" = "7" ] ||
  fail "CONTROL_HARNESS_ASSERTIONS_NOT_ALL_SUCCESS"

for number in 1 2 3 4 5 6 7; do
  [ "$(read_value "$CONTROL_SUMMARY" "H${number}_STATUS")" = "SUCCESS" ] ||
    fail "CONTROL_ASSERTION_${number}_NOT_SUCCESS"
done

echo "PFB_T2_NONVACUITY_AND_BOUNDARY_CONTROL=PASS"

echo
echo "============================================================"
echo "PART 5 — FIVE OBLIGATION-SPECIFIC SOURCE MUTANTS"
echo "============================================================"

parse_mutant_xml()
{
  local xml="$1"
  local output="$2"
  local property_count="$3"

  python3 - "$xml" "$output" "$property_count" <<'PY'
from __future__ import annotations

import collections
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

xml_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])
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
    print(f"MUTANT_XML_PARSE_EXCEPTION={exc!r}")

output_path.write_text(
    "".join(f"{key}={value}\n" for key, value in values.items()),
    encoding="utf-8",
)

for key, value in values.items():
    print(f"MUTANT_{key}={value}")
PY
}

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
  local proof_kind="$2"
  local old_text="$3"
  local new_text="$4"
  local expected_failure="$5"

  local mut_wt="$ROOT/_cbmc_work/mlkem-native_pfb_t2_${mutant_name}_${STAMP}"
  local mut_record="$RUN/mutants/$mutant_name"
  local mut_proof
  local mut_harness
  local mut_makefile
  local mut_goto
  local property_count
  local source_proof
  local source_harness
  local source_makefile

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

  if [ "$proof_kind" = "bit" ]; then
    source_proof="$BIT_PROOF"
    source_harness="$BIT_HARNESS"
    source_makefile="$BIT_MAKEFILE"
    mut_proof="$mut_wt/proofs/cbmc/pfb_t2_bit_routes"
    mut_harness="$mut_proof/pfb_t2_bit_routes_harness.c"
    mut_makefile="$mut_proof/Makefile"
    mut_goto="$mut_proof/gotos/pfb_t2_bit_routes_harness.goto"
    property_count=4
  elif [ "$proof_kind" = "local" ]; then
    source_proof="$LOCAL_PROOF"
    source_harness="$LOCAL_HARNESS"
    source_makefile="$LOCAL_MAKEFILE"
    mut_proof="$mut_wt/proofs/cbmc/pfb_t2_block_locality"
    mut_harness="$mut_proof/pfb_t2_block_locality_harness.c"
    mut_makefile="$mut_proof/Makefile"
    mut_goto="$mut_proof/gotos/pfb_t2_block_locality_harness.goto"
    property_count=1
  else
    fail "UNKNOWN_PROOF_KIND_$mutant_name"
  fi

  mkdir -p "$mut_proof"
  cp "$source_harness" "$mut_harness"
  cp "$source_makefile" "$mut_makefile"

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

  local property_args=()
  local number

  for number in $(seq 1 "$property_count"); do
    property_args+=(--property "harness.assertion.${number}")
  done

  if timeout \
    --signal=TERM \
    1800 \
    cbmc \
    "${COMMON_FLAGS[@]}" \
    "${property_args[@]}" \
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

  parse_mutant_xml \
    "$mut_record/result.xml" \
    "$mut_record/summary.txt" \
    "$property_count"

  local cprover_status
  local actual_count
  local failure_count
  local error_count
  local unknown_count
  local non_success_count
  local status
  local expected_failure_count=0

  cprover_status="$(read_value "$mut_record/summary.txt" CPROVER_STATUS)"
  actual_count="$(read_value "$mut_record/summary.txt" PROPERTY_COUNT)"
  failure_count="$(read_value "$mut_record/summary.txt" FAILURE_COUNT)"
  error_count="$(read_value "$mut_record/summary.txt" ERROR_COUNT)"
  unknown_count="$(read_value "$mut_record/summary.txt" UNKNOWN_COUNT)"
  non_success_count="$(read_value "$mut_record/summary.txt" NON_SUCCESS_COUNT)"

  echo "MUTANT_RESULT[$mutant_name].CPROVER_STATUS=$cprover_status"
  echo "MUTANT_RESULT[$mutant_name].PROPERTY_COUNT=$actual_count"
  echo "MUTANT_RESULT[$mutant_name].FAILURE_COUNT=$failure_count"
  echo "MUTANT_RESULT[$mutant_name].ERROR_COUNT=$error_count"
  echo "MUTANT_RESULT[$mutant_name].UNKNOWN_COUNT=$unknown_count"
  echo "MUTANT_RESULT[$mutant_name].NON_SUCCESS_COUNT=$non_success_count"

  [ "$MUTANT_CBMC_EXIT" = "10" ] ||
    fail "MUTANT_EXIT_NOT_10_$mutant_name"
  [ "$cprover_status" = "FAILURE" ] ||
    fail "MUTANT_CPROVER_NOT_FAILURE_$mutant_name"
  [ "$actual_count" = "$property_count" ] ||
    fail "MUTANT_PROPERTY_COUNT_WRONG_$mutant_name"
  [ "$error_count" = "0" ] ||
    fail "MUTANT_ERROR_PRESENT_$mutant_name"
  [ "$unknown_count" = "0" ] ||
    fail "MUTANT_UNKNOWN_PRESENT_$mutant_name"

  for number in $(seq 1 "$property_count"); do
    status="$(read_value "$mut_record/summary.txt" "H${number}_STATUS")"
    echo "MUTANT_RESULT[$mutant_name].H${number}_STATUS=$status"

    if [ "$number" = "$expected_failure" ]; then
      [ "$status" = "FAILURE" ] ||
        fail "EXPECTED_ASSERTION_DID_NOT_FAIL_${mutant_name}_H${number}"
      expected_failure_count=$((expected_failure_count + 1))
    else
      [ "$status" = "SUCCESS" ] ||
        fail "UNRELATED_ASSERTION_NOT_SUCCESS_${mutant_name}_H${number}"
    fi
  done

  [ "$expected_failure_count" = "1" ] ||
    fail "EXPECTED_FAILURE_COUNT_WRONG_$mutant_name"
  [ "$failure_count" = "1" ] ||
    fail "TOTAL_FAILURE_COUNT_WRONG_$mutant_name"
  [ "$non_success_count" = "1" ] ||
    fail "TOTAL_NON_SUCCESS_COUNT_WRONG_$mutant_name"

  echo "MUTANT_KILLED[$mutant_name]=YES"

  git -C "$AUTH" worktree remove \
    --force \
    "$mut_wt" \
    > "$mut_record/worktree_remove.stdout.txt" \
    2> "$mut_record/worktree_remove.stderr.txt" ||
    fail "MUTANT_WORKTREE_REMOVE_FAILED_$mutant_name"

  [ ! -e "$mut_wt" ] || fail "MUTANT_WORKTREE_STILL_PRESENT_$mutant_name"
}

P1_OLD='r->coeffs[2 * i + 0] = (int16_t)(t0 | (((uint16_t)t1 << 8) & 0xFFF));'
P1_NEW='r->coeffs[2 * i + 0] = (int16_t)((t0 >> 1) | (((uint16_t)t1 << 8) & 0xFFF));'

P2_OLD='r->coeffs[2 * i + 0] = (int16_t)(t0 | (((uint16_t)t1 << 8) & 0xFFF));'
P2_NEW='r->coeffs[2 * i + 0] = (int16_t)(t0 | (((uint16_t)t1 << 9) & 0xFFF));'

P3_OLD='r->coeffs[2 * i + 1] = (int16_t)((t1 >> 4) | (t2 << 4));'
P3_NEW='r->coeffs[2 * i + 1] = (int16_t)((t1 >> 5) | (t2 << 4));'

P4_OLD='r->coeffs[2 * i + 1] = (int16_t)((t1 >> 4) | (t2 << 4));'
P4_NEW='r->coeffs[2 * i + 1] = (int16_t)((t1 >> 4) | (t2 << 5));'

P5_OLD='uint8_t t0 = a[3 * i + 0];'
P5_NEW='uint8_t t0 = (uint8_t)(a[3 * i + 0] ^ a[(3 * (i + 1)) % MLKEM_POLYBYTES]);'

run_mutant "p1_first_byte_route" "bit" "$P1_OLD" "$P1_NEW" "1"
run_mutant "p2_low_nibble_route" "bit" "$P2_OLD" "$P2_NEW" "2"
run_mutant "p3_high_nibble_route" "bit" "$P3_OLD" "$P3_NEW" "3"
run_mutant "p4_third_byte_route" "bit" "$P4_OLD" "$P4_NEW" "4"
run_mutant "p5_cross_block_dependency" "local" "$P5_OLD" "$P5_NEW" "1"

echo "PFB_T2_P1_MUTANT_KILLED=YES"
echo "PFB_T2_P2_MUTANT_KILLED=YES"
echo "PFB_T2_P3_MUTANT_KILLED=YES"
echo "PFB_T2_P4_MUTANT_KILLED=YES"
echo "PFB_T2_P5_MUTANT_KILLED=YES"
echo "PFB_T2_MUTATION_SENSITIVITY=PASS"

echo
echo "============================================================"
echo "PART 6 — POST-MUTATION IMMUTABILITY"
echo "============================================================"

bind_hash "COMPRESS_SOURCE_AFTER" "$WT/mlkem/src/compress.c" "$EXPECTED_COMPRESS_SHA256"
bind_hash "COMPRESS_HEADER_AFTER" "$WT/mlkem/src/compress.h" "$EXPECTED_COMPRESS_H_SHA256"
bind_hash "PARAMS_HEADER_AFTER" "$WT/mlkem/src/params.h" "$EXPECTED_PARAMS_SHA256"

bind_hash "T1_HARNESS_AFTER" "$T1_HARNESS" "$EXPECTED_T1_HARNESS_SHA256"
bind_hash "T1_MAKEFILE_AFTER" "$T1_MAKEFILE" "$EXPECTED_T1_MAKEFILE_SHA256"
bind_hash "T1_GOTO_AFTER" "$T1_GOTO" "$EXPECTED_T1_GOTO_SHA256"

bind_hash "BIT_HARNESS_AFTER" "$BIT_HARNESS" "$EXPECTED_BIT_HARNESS_SHA256"
bind_hash "BIT_MAKEFILE_AFTER" "$BIT_MAKEFILE" "$EXPECTED_BIT_MAKEFILE_SHA256"
bind_hash "BIT_GOTO_AFTER" "$BIT_GOTO" "$EXPECTED_BIT_GOTO_SHA256"

bind_hash "LOCAL_HARNESS_AFTER" "$LOCAL_HARNESS" "$EXPECTED_LOCAL_HARNESS_SHA256"
bind_hash "LOCAL_MAKEFILE_AFTER" "$LOCAL_MAKEFILE" "$EXPECTED_LOCAL_MAKEFILE_SHA256"
bind_hash "LOCAL_GOTO_AFTER" "$LOCAL_GOTO" "$EXPECTED_LOCAL_GOTO_SHA256"

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
echo "PFB_T2_BASELINE_ARTIFACTS_UNCHANGED=YES"
echo "MUTATIONS_ISOLATED_TO_DETACHED_WORKTREES=YES"

echo
echo "============================================================"
echo "PART 7 — FINAL PFB-T2 ACCEPTANCE AND EVIDENCE FREEZE"
echo "============================================================"

mkdir -p \
  "$FINAL_FREEZE/prior_evidence" \
  "$FINAL_FREEZE/baseline_artifacts" \
  "$FINAL_FREEZE/control" \
  "$FINAL_FREEZE/mutants" \
  "$FINAL_FREEZE/source_binding"

cp "$CORRECTED" \
  "$FINAL_FREEZE/prior_evidence/PFB_02R_CORRECTED_RESULT.txt"
cp "$PFB_02A_RUN/PFB_02R_XML_REPARSE_SUMMARY.txt" \
  "$FINAL_FREEZE/prior_evidence/"
cp "$PFB_02A_RUN/SHA256SUMS.PFB_02R.txt" \
  "$FINAL_FREEZE/prior_evidence/"
cp "$FREEZE_00C/registry/PFB_THEOREM_REGISTRY_V1.md" \
  "$FINAL_FREEZE/prior_evidence/"
cp "$FREEZE_00C/registry/PFB_SCOPE_AND_NONCLAIMS_V1.md" \
  "$FINAL_FREEZE/prior_evidence/"
cp "$FREEZE_00C/registry/verification_intent.json" \
  "$FINAL_FREEZE/prior_evidence/"

cp "$BIT_HARNESS" "$FINAL_FREEZE/baseline_artifacts/"
cp "$BIT_MAKEFILE" \
  "$FINAL_FREEZE/baseline_artifacts/Makefile.pfb_t2_bit_routes"
cp "$LOCAL_HARNESS" "$FINAL_FREEZE/baseline_artifacts/"
cp "$LOCAL_MAKEFILE" \
  "$FINAL_FREEZE/baseline_artifacts/Makefile.pfb_t2_block_locality"

cp -a "$RUN/control/." "$FINAL_FREEZE/control/"
cp -a "$RUN/mutants/." "$FINAL_FREEZE/mutants/"

cat > "$FINAL_FREEZE/source_binding/SOURCE_IDENTITY.txt" <<EOF_SOURCE
SOURCE_COMMIT=$EXPECTED_COMMIT
SOURCE_TREE=$EXPECTED_TREE
COMPRESS_SOURCE_SHA256=$EXPECTED_COMPRESS_SHA256
COMPRESS_HEADER_SHA256=$EXPECTED_COMPRESS_H_SHA256
PARAMS_HEADER_SHA256=$EXPECTED_PARAMS_SHA256
BIT_HARNESS_SHA256=$EXPECTED_BIT_HARNESS_SHA256
BIT_MAKEFILE_SHA256=$EXPECTED_BIT_MAKEFILE_SHA256
BIT_GOTO_SHA256=$EXPECTED_BIT_GOTO_SHA256
LOCAL_HARNESS_SHA256=$EXPECTED_LOCAL_HARNESS_SHA256
LOCAL_MAKEFILE_SHA256=$EXPECTED_LOCAL_MAKEFILE_SHA256
LOCAL_GOTO_SHA256=$EXPECTED_LOCAL_GOTO_SHA256
EOF_SOURCE

cat > "$FINAL_FREEZE/PFB_T2_FINAL_ACCEPTANCE_REPORT.txt" <<EOF_REPORT
PFB_STAGE=PFB-T2-FINAL
PFB_T2_FINAL_ACCEPTANCE=YES
FROZEN_AT_UTC=$STAMP
SOURCE_COMMIT=$EXPECTED_COMMIT
SOURCE_TREE=$EXPECTED_TREE
INITIAL_CONFIGURATION=portable ML-KEM-768
PUBLIC_TARGET=mlk_poly_frombytes
PORTABLE_BODY=mlk_poly_frombytes_c
PFB_T2_P1_FIRST_BYTE_BIT_ROUTING=PROVED
PFB_T2_P2_LOW_NIBBLE_BIT_ROUTING=PROVED
PFB_T2_P3_HIGH_NIBBLE_BIT_ROUTING=PROVED
PFB_T2_P4_THIRD_BYTE_BIT_ROUTING=PROVED
PFB_T2_P5_ARBITRARY_ONE_BLOCK_LOCALITY=PROVED
BIT_ROUTE_THEOREM_SET=4_OF_4_SUCCESS
BIT_ROUTE_COMPLETE_PROPERTY_SET=170_OF_170_SUCCESS
BLOCK_LOCALITY_THEOREM_SET=1_OF_1_SUCCESS
BLOCK_LOCALITY_COMPLETE_PROPERTY_SET=102_OF_102_SUCCESS
NONVACUITY_AND_BOUNDARY_CONTROL=PASS
NONVACUITY_CONTROL_ASSERTIONS=7_OF_7_SUCCESS
PFB_T2_P1_MUTANT_KILLED=YES
PFB_T2_P2_MUTANT_KILLED=YES
PFB_T2_P3_MUTANT_KILLED=YES
PFB_T2_P4_MUTANT_KILLED=YES
PFB_T2_P5_MUTANT_KILLED=YES
MUTATION_SENSITIVITY=PASS
FUNCTION_CONTRACT_SUBSTITUTION=NO
LOOP_CONTRACT_APPLICATION=NO
DEFAULT_SAT_BACKEND=YES
NATIVE_BACKEND_CLAIM=EXCLUDED
PFB_T1_ARTIFACTS_UNCHANGED=YES
PFB_T2_BASELINE_ARTIFACTS_UNCHANGED=YES
PRODUCTION_SOURCE_MODIFIED=NO
AUTHORITATIVE_TREE_CLEAN=YES
MATHEMATICAL_WORLD_FIRST_CLAIM=NO
ALLOWED_CLAIM=At commit af4c5abd, the portable public mlk_poly_frombytes path was verified by CBMC for the five frozen PFB-T2 exact bit-routing and arbitrary one-block locality obligations, under the recorded machine model and proof configuration.
FINAL_FREEZE_DIRECTORY=$FINAL_FREEZE
TERMINAL_OUTPUT=$OUT
EOF_REPORT

cp "$OUT" "$FINAL_FREEZE/PFB_02M_TERMINAL_OUTPUT.txt"

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

cat "$FINAL_FREEZE/PFB_T2_FINAL_ACCEPTANCE_REPORT.txt"

echo "FINAL_MANIFEST_SHA256=$FINAL_MANIFEST_SHA256"
echo "FINAL_ARCHIVE=$FINAL_ARCHIVE"
echo "FINAL_ARCHIVE_SHA256=$FINAL_ARCHIVE_SHA256"

echo
echo "============================================================"
echo "PFB-02M COMPLETE"
echo "PFB-T2 FINAL ACCEPTANCE=YES"
echo "ALL FIVE FROZEN PFB-T2 OBLIGATIONS PROVED"
echo "ALL SEVEN NONVACUITY CONTROL ASSERTIONS PASSED"
echo "ALL FIVE OBLIGATION-SPECIFIC MUTANTS KILLED"
echo "FAIL-CLOSED EVIDENCE FREEZE CREATED"
echo "NO PFB-T1 OR PFB-T2 BASELINE ARTIFACT MODIFIED"
echo "NO AUTHORITATIVE PRODUCTION SOURCE MODIFIED"
echo "SCRIPT_FINAL_EXIT=0"
echo "============================================================"

exit 0
