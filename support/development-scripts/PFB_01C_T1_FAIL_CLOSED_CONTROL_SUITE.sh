set +e
set -uo pipefail
umask 022

ROOT="$HOME/THESIS-2026"
AUTH="$ROOT/mlkem-native_af4c5abd"
WT="$ROOT/_cbmc_work/mlkem-native_pfb_af4c5abd"
BASE="$ROOT/mlk_poly_frombytes_cleanroom/PFB_01S_T1_SAT_SEMANTIC_RUN2_20260729T040920Z"
THEOREM_PROOF="$WT/proofs/cbmc/pfb_t1_exact_raw_decode"
CONTROL_PROOF="$WT/proofs/cbmc/pfb_t1_controls"

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_TREE="54805daff6a91a010c05467ea678117c42a71559"
EXPECTED_HARNESS_SHA256="9a3288855782f7aee718d51c7904608763bd480635a63d25cd05956d408007a8"
EXPECTED_MAKEFILE_SHA256="9e56741090a6634baddbe2ea9fe13637bbeed9a1ce62f93e2f228185cfe41526"
EXPECTED_GOTO_SHA256="13dd5ba4e64b4dd3c54a3d4e7c82ec0e3c1b09a397584cfa1a13309f60ceeb83"
EXPECTED_COMPRESS_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN="$ROOT/mlk_poly_frombytes_cleanroom/PFB_01C_T1_CONTROL_SUITE_${STAMP}"
OUT="/tmp/PFB_01C_T1_CONTROL_SUITE.txt"

mkdir -p "$RUN"/{baseline_seal,build,results,binding,artifacts}
exec > >(tee "$OUT") 2>&1

fail()
{
  echo "FATAL=$1"
  echo "PFB_01C_STATUS=FAIL"
  echo "TERMINAL_OUTPUT=$OUT"
  exit 1
}

read_value()
{
  local file="$1"
  local key="$2"
  awk -F= -v wanted="$key" '$1 == wanted {sub(/^[^=]*=/, ""); print; exit}' "$file" 2>/dev/null
}

for command in git sha256sum python3 cbmc goto-instrument make timeout; do
  command -v "$command" >/dev/null 2>&1 || fail "COMMAND_NOT_FOUND_$command"
done

echo "============================================================"
echo "PFB-01C — T1 FAIL-CLOSED BASELINE SEAL AND CONTROL SUITE"
echo "============================================================"
echo "STARTED_AT_UTC=$STAMP"
echo "RUN_DIRECTORY=$RUN"
echo "TERMINAL_OUTPUT=$OUT"

echo
echo "============================================================"
echo "PART 1 — FAIL-CLOSED PFB-01S BASELINE SEAL"
echo "============================================================"

[ -d "$BASE" ] || fail "BASELINE_RUN_DIRECTORY_ABSENT"
[ -f "$BASE/SHA256SUMS.txt" ] || fail "BASELINE_SHA256SUMS_ABSENT"
[ -f "$BASE/PFB_01S_RESULT.txt" ] || fail "BASELINE_RESULT_ABSENT"
[ -f "$BASE/results/theorem_only.xml" ] || fail "THEOREM_XML_ABSENT"
[ -f "$BASE/results/all_properties.xml" ] || fail "ALL_PROPERTIES_XML_ABSENT"

(
  cd "$BASE" || exit 1
  sha256sum -c SHA256SUMS.txt
) > "$RUN/baseline_seal/sha256_check.txt" 2>&1
BASE_SHA_EXIT=$?
cat "$RUN/baseline_seal/sha256_check.txt"
[ "$BASE_SHA_EXIT" -eq 0 ] || fail "BASELINE_SHA256_VERIFICATION_FAILED"

BASE_RESULT="$BASE/PFB_01S_RESULT.txt"

for expected in \
  "THEOREM_CBMC_EXIT=0" \
  "PFB_T1_P1_STATUS=SUCCESS" \
  "PFB_T1_P2_STATUS=SUCCESS" \
  "THEOREM_CPROVER_STATUS=SUCCESS" \
  "THEOREM_ONLY_PASS=YES" \
  "ALL_PROPERTIES_CBMC_EXIT=0" \
  "ALL_PROPERTIES_CPROVER_STATUS=SUCCESS" \
  "ALL_PROPERTIES_PROPERTY_COUNT=113" \
  "ALL_PROPERTIES_SUCCESS_COUNT=113" \
  "ALL_PROPERTIES_ERROR_COUNT=0" \
  "ALL_PROPERTIES_FAILURE_COUNT=0" \
  "ALL_PROPERTIES_UNKNOWN_COUNT=0" \
  "ALL_PROPERTIES_NON_SUCCESS_COUNT=0" \
  "ALL_PROPERTIES_P1_STATUS=SUCCESS" \
  "ALL_PROPERTIES_P2_STATUS=SUCCESS" \
  "ALL_PROPERTIES_PASS=YES" \
  "UNWIND_PASS=YES" \
  "NON_SEMANTIC_NON_SUCCESS_COUNT=0" \
  "NON_SEMANTIC_COMPLETE_CHECK_PASS=YES" \
  "POST_RUN_HASH_BINDING=PASS" \
  "PFB_T1_SEMANTIC_BASELINE_STATUS=PASS"
do
  grep -Fxq "$expected" "$BASE_RESULT" || fail "BASELINE_RESULT_MISSING_${expected//[^A-Za-z0-9]/_}"
  echo "BASELINE_GATE[$expected]=PASS"
done

python3 - \
  "$BASE/results/theorem_only.xml" \
  "$BASE/results/all_properties.xml" \
  > "$RUN/baseline_seal/xml_recheck.txt" <<'PY'
import collections
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]

for label, raw_path in zip(("THEOREM", "ALL"), sys.argv[1:]):
    path = Path(raw_path)
    root = ET.parse(path).getroot()
    results = [node for node in root.iter() if local_name(node.tag) == "result"]
    counts = collections.Counter(node.attrib.get("status", "MISSING") for node in results)
    statuses = [
        " ".join((node.text or "").split())
        for node in root.iter()
        if local_name(node.tag) == "cprover-status"
    ]
    print(f"{label}_XML_PROPERTY_COUNT={len(results)}")
    print(f"{label}_XML_SUCCESS_COUNT={counts.get('SUCCESS', 0)}")
    print(f"{label}_XML_NON_SUCCESS_COUNT={sum(v for k, v in counts.items() if k != 'SUCCESS')}")
    print(f"{label}_XML_CPROVER_STATUS={'|'.join(statuses) if statuses else 'NONE'}")
    for prop in ("harness.assertion.1", "harness.assertion.2"):
        matches = [node.attrib.get("status", "MISSING") for node in results if node.attrib.get("property") == prop]
        print(f"{label}_{prop.replace('.', '_').upper()}={'|'.join(matches) if matches else 'ABSENT'}")
PY

cat "$RUN/baseline_seal/xml_recheck.txt"

grep -Fxq 'THEOREM_XML_PROPERTY_COUNT=2' "$RUN/baseline_seal/xml_recheck.txt" || fail "THEOREM_XML_COUNT_MISMATCH"
grep -Fxq 'THEOREM_XML_SUCCESS_COUNT=2' "$RUN/baseline_seal/xml_recheck.txt" || fail "THEOREM_XML_SUCCESS_MISMATCH"
grep -Fxq 'THEOREM_XML_NON_SUCCESS_COUNT=0' "$RUN/baseline_seal/xml_recheck.txt" || fail "THEOREM_XML_NON_SUCCESS"
grep -Fxq 'THEOREM_XML_CPROVER_STATUS=SUCCESS' "$RUN/baseline_seal/xml_recheck.txt" || fail "THEOREM_XML_STATUS_NOT_SUCCESS"
grep -Fxq 'ALL_XML_PROPERTY_COUNT=113' "$RUN/baseline_seal/xml_recheck.txt" || fail "ALL_XML_COUNT_MISMATCH"
grep -Fxq 'ALL_XML_SUCCESS_COUNT=113' "$RUN/baseline_seal/xml_recheck.txt" || fail "ALL_XML_SUCCESS_MISMATCH"
grep -Fxq 'ALL_XML_NON_SUCCESS_COUNT=0' "$RUN/baseline_seal/xml_recheck.txt" || fail "ALL_XML_NON_SUCCESS"
grep -Fxq 'ALL_XML_CPROVER_STATUS=SUCCESS' "$RUN/baseline_seal/xml_recheck.txt" || fail "ALL_XML_STATUS_NOT_SUCCESS"

echo "PFB_01S_FAIL_CLOSED_RECHECK=PASS"

echo
echo "============================================================"
echo "PART 2 — IMMUTABLE SOURCE AND THEOREM ARTIFACT BINDING"
echo "============================================================"

THEOREM_HARNESS="$THEOREM_PROOF/pfb_t1_exact_raw_decode_harness.c"
THEOREM_MAKEFILE="$THEOREM_PROOF/Makefile"
THEOREM_GOTO="$THEOREM_PROOF/gotos/pfb_t1_exact_raw_decode_harness.goto"

[ "$(git -C "$AUTH" rev-parse HEAD)" = "$EXPECTED_COMMIT" ] || fail "AUTHORITATIVE_COMMIT_MISMATCH"
[ "$(git -C "$AUTH" rev-parse 'HEAD^{tree}')" = "$EXPECTED_TREE" ] || fail "AUTHORITATIVE_TREE_MISMATCH"
[ -z "$(git -C "$AUTH" status --porcelain=v1)" ] || fail "AUTHORITATIVE_TREE_DIRTY"
[ "$(git -C "$WT" rev-parse HEAD)" = "$EXPECTED_COMMIT" ] || fail "WORKTREE_COMMIT_MISMATCH"
[ "$(git -C "$WT" rev-parse 'HEAD^{tree}')" = "$EXPECTED_TREE" ] || fail "WORKTREE_TREE_MISMATCH"

[ "$(sha256sum "$THEOREM_HARNESS" | awk '{print $1}')" = "$EXPECTED_HARNESS_SHA256" ] || fail "THEOREM_HARNESS_HASH_MISMATCH"
[ "$(sha256sum "$THEOREM_MAKEFILE" | awk '{print $1}')" = "$EXPECTED_MAKEFILE_SHA256" ] || fail "THEOREM_MAKEFILE_HASH_MISMATCH"
[ "$(sha256sum "$THEOREM_GOTO" | awk '{print $1}')" = "$EXPECTED_GOTO_SHA256" ] || fail "THEOREM_GOTO_HASH_MISMATCH"
[ "$(sha256sum "$WT/mlkem/src/compress.c" | awk '{print $1}')" = "$EXPECTED_COMPRESS_SHA256" ] || fail "COMPRESS_HASH_MISMATCH"

echo "AUTHORITATIVE_HEAD=$EXPECTED_COMMIT"
echo "AUTHORITATIVE_TREE=$EXPECTED_TREE"
echo "THEOREM_HARNESS_SHA256=$EXPECTED_HARNESS_SHA256"
echo "THEOREM_MAKEFILE_SHA256=$EXPECTED_MAKEFILE_SHA256"
echo "THEOREM_GOTO_SHA256=$EXPECTED_GOTO_SHA256"
echo "COMPRESS_SOURCE_SHA256=$EXPECTED_COMPRESS_SHA256"
echo "IMMUTABLE_BINDING=PASS"

echo
echo "============================================================"
echo "PART 3 — CREATE SEPARATE CONTROL HARNESS"
echo "============================================================"

[ ! -e "$CONTROL_PROOF" ] || fail "CONTROL_PROOF_DIRECTORY_ALREADY_EXISTS"
mkdir -p "$CONTROL_PROOF"
cp "$THEOREM_MAKEFILE" "$CONTROL_PROOF/Makefile"

python3 - "$CONTROL_PROOF/Makefile" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
replacements = {
    "HARNESS_FILE = pfb_t1_exact_raw_decode_harness": "HARNESS_FILE = pfb_t1_controls_harness",
    "PROOF_UID = pfb_t1_exact_raw_decode": "PROOF_UID = pfb_t1_controls",
    "CBMCFLAGS=--bitwuzla": "CBMCFLAGS=",
}
for old, new in replacements.items():
    count = text.count(old)
    print(f"MAKEFILE_REPLACEMENT_COUNT[{old}]={count}")
    if count != 1:
        raise SystemExit(f"Expected exactly one occurrence of {old!r}, found {count}")
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
[ "$?" -eq 0 ] || fail "CONTROL_MAKEFILE_PATCH_FAILED"

cat > "$CONTROL_PROOF/pfb_t1_controls_harness.c" <<'EOF_HARNESS'
#include <stddef.h>
#include <stdint.h>

#include "compress.h"

typedef struct
{
  uint32_t before;
  mlk_poly value;
  uint32_t after;
} pfb_guarded_poly;

void harness(void)
{
  uint8_t input[MLKEM_POLYBYTES];
  size_t byte_index;
  size_t coeff_index;
  uint8_t saved_input_byte;

  pfb_guarded_poly first;
  pfb_guarded_poly second;

  uint8_t zero_input[MLKEM_POLYBYTES] = {0};
  uint8_t one_input[MLKEM_POLYBYTES] = {0};
  mlk_poly zero_output;
  mlk_poly one_output;

  __CPROVER_assume(byte_index < MLKEM_POLYBYTES);
  __CPROVER_assume(coeff_index < MLKEM_N);

  saved_input_byte = input[byte_index];

  first.before = UINT32_C(0x13579BDF);
  first.after = UINT32_C(0x2468ACE0);
  second.before = UINT32_C(0x89ABCDEF);
  second.after = UINT32_C(0x10203040);

  one_input[0] = UINT8_C(1);

  mlk_poly_frombytes(&first.value, input);
  mlk_poly_frombytes(&second.value, input);
  mlk_poly_frombytes(&zero_output, zero_input);
  mlk_poly_frombytes(&one_output, one_input);

  __CPROVER_assert(
      input[byte_index] == saved_input_byte,
      "PFB-C1 arbitrary selected input byte is preserved");

  __CPROVER_assert(
      first.before == UINT32_C(0x13579BDF) &&
          first.after == UINT32_C(0x2468ACE0),
      "PFB-C2 first output canaries are preserved");

  __CPROVER_assert(
      second.before == UINT32_C(0x89ABCDEF) &&
          second.after == UINT32_C(0x10203040),
      "PFB-C3 second output canaries are preserved");

  __CPROVER_assert(
      first.value.coeffs[coeff_index] ==
          second.value.coeffs[coeff_index],
      "PFB-C4 complete overwrite and deterministic selected coefficient");

  __CPROVER_assert(
      zero_output.coeffs[0] == 0,
      "PFB-C5 zero-input concrete output witness");

  __CPROVER_assert(
      one_output.coeffs[0] == 1,
      "PFB-C6 one-input concrete output witness");

  __CPROVER_assert(
      one_output.coeffs[0] != zero_output.coeffs[0],
      "PFB-C7 nonconstant-output witness");
}
EOF_HARNESS

CONTROL_HARNESS="$CONTROL_PROOF/pfb_t1_controls_harness.c"
CONTROL_MAKEFILE="$CONTROL_PROOF/Makefile"

echo "CONTROL_HARNESS_SHA256=$(sha256sum "$CONTROL_HARNESS" | awk '{print $1}')"
echo "CONTROL_MAKEFILE_SHA256=$(sha256sum "$CONTROL_MAKEFILE" | awk '{print $1}')"
echo "CONTROL_PUBLIC_CALL_COUNT=$(grep -c 'mlk_poly_frombytes(' "$CONTROL_HARNESS" || true)"
echo "CONTROL_ASSERTION_COUNT=$(grep -c '__CPROVER_assert' "$CONTROL_HARNESS" || true)"
echo "CONTROL_ASSUME_COUNT=$(grep -c '__CPROVER_assume' "$CONTROL_HARNESS" || true)"

[ "$(grep -c 'mlk_poly_frombytes(' "$CONTROL_HARNESS" || true)" -eq 4 ] || fail "CONTROL_TARGET_CALL_COUNT_MISMATCH"
[ "$(grep -c '__CPROVER_assert' "$CONTROL_HARNESS" || true)" -eq 7 ] || fail "CONTROL_ASSERTION_COUNT_MISMATCH"
[ "$(grep -c '__CPROVER_assume' "$CONTROL_HARNESS" || true)" -eq 2 ] || fail "CONTROL_ASSUME_COUNT_MISMATCH"

grep -q 'USE_FUNCTION_CONTRACTS[[:space:]]*=[[:space:]]*$' "$CONTROL_MAKEFILE" || fail "CONTROL_FUNCTION_CONTRACTS_NOT_EMPTY"
grep -q 'APPLY_LOOP_CONTRACTS=[[:space:]]*$' "$CONTROL_MAKEFILE" || fail "CONTROL_LOOP_CONTRACTS_NOT_EMPTY"
grep -q 'USE_DYNAMIC_FRAMES=[[:space:]]*$' "$CONTROL_MAKEFILE" || fail "CONTROL_DYNAMIC_FRAMES_NOT_EMPTY"

echo "CONTROL_HARNESS_AUDIT=PASS"

cp "$CONTROL_HARNESS" "$RUN/artifacts/"
cp "$CONTROL_MAKEFILE" "$RUN/artifacts/Control_Makefile"

echo
echo "============================================================"
echo "PART 4 — BUILD CONTROL GOTO"
echo "============================================================"

(
  cd "$CONTROL_PROOF" || exit 1
  make -j1
) > "$RUN/build/make.stdout.txt" 2> "$RUN/build/make.stderr.txt"
MAKE_EXIT=$?

echo "CONTROL_MAKE_EXIT=$MAKE_EXIT"
echo "---------------- MAKE STDOUT TAIL ----------------"
tail -n 80 "$RUN/build/make.stdout.txt" || true
echo "---------------- MAKE STDERR TAIL ----------------"
tail -n 80 "$RUN/build/make.stderr.txt" || true

CONTROL_GOTO="$CONTROL_PROOF/gotos/pfb_t1_controls_harness.goto"
[ -f "$CONTROL_GOTO" ] || fail "CONTROL_GOTO_NOT_CREATED"

echo "CONTROL_GOTO_SHA256=$(sha256sum "$CONTROL_GOTO" | awk '{print $1}')"

goto-instrument --show-goto-functions "$CONTROL_GOTO" \
  > "$RUN/binding/control_goto_functions.txt" \
  2> "$RUN/binding/control_goto_functions.stderr.txt"
[ "$?" -eq 0 ] || fail "CONTROL_GOTO_DUMP_FAILED"

echo "CONTROL_PUBLIC_TO_PORTABLE_CALL_COUNT=$(grep -c 'CALL mlk_poly_frombytes_c(' "$RUN/binding/control_goto_functions.txt" || true)"
echo "CONTROL_WRAPPER_CALL_COUNT=$(grep -c 'CALL mlk_poly_frombytes(' "$RUN/binding/control_goto_functions.txt" || true)"

[ "$(grep -c 'CALL mlk_poly_frombytes(' "$RUN/binding/control_goto_functions.txt" || true)" -ge 4 ] || fail "CONTROL_WRAPPER_CALLS_NOT_BOUND"
[ "$(grep -c 'CALL mlk_poly_frombytes_c(' "$RUN/binding/control_goto_functions.txt" || true)" -ge 1 ] || fail "CONTROL_PORTABLE_BODY_NOT_BOUND"

echo "CONTROL_GOTO_BINDING=PASS"

echo
echo "============================================================"
echo "PART 5 — DEFAULT-SAT COMPLETE CONTROL RUN"
echo "============================================================"

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

printf 'CONTROL_CBMC_COMMAND=cbmc '
printf '%q ' "${COMMON_FLAGS[@]}"
printf '%q\n' --xml-ui "$CONTROL_GOTO"

timeout 600 cbmc \
  "${COMMON_FLAGS[@]}" \
  --xml-ui \
  "$CONTROL_GOTO" \
  > "$RUN/results/control_all.xml" \
  2> "$RUN/results/control_all.stderr.txt"
CONTROL_CBMC_EXIT=$?

echo "CONTROL_CBMC_EXIT=$CONTROL_CBMC_EXIT"
echo "CONTROL_XML_SIZE=$(stat -c '%s' "$RUN/results/control_all.xml" 2>/dev/null || echo 0)"
echo "CONTROL_STDERR_SIZE=$(stat -c '%s' "$RUN/results/control_all.stderr.txt" 2>/dev/null || echo 0)"

python3 - "$RUN/results/control_all.xml" > "$RUN/results/control_summary.txt" <<'PY'
import collections
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

path = Path(sys.argv[1])
root = ET.parse(path).getroot()
local = lambda tag: tag.rsplit("}", 1)[-1]
results = [node for node in root.iter() if local(node.tag) == "result"]
counts = collections.Counter(node.attrib.get("status", "MISSING") for node in results)
statuses = [" ".join((node.text or "").split()) for node in root.iter() if local(node.tag) == "cprover-status"]
control = [node for node in results if node.attrib.get("property", "").startswith("harness.assertion.")]
print(f"CONTROL_PROPERTY_COUNT={len(results)}")
print(f"CONTROL_SUCCESS_COUNT={counts.get('SUCCESS', 0)}")
print(f"CONTROL_NON_SUCCESS_COUNT={sum(v for k, v in counts.items() if k != 'SUCCESS')}")
print(f"CONTROL_CPROVER_STATUS={'|'.join(statuses) if statuses else 'NONE'}")
print(f"CONTROL_HARNESS_ASSERTION_COUNT={len(control)}")
print(f"CONTROL_HARNESS_ASSERTION_SUCCESS_COUNT={sum(node.attrib.get('status') == 'SUCCESS' for node in control)}")
for node in control:
    print(f"CONTROL_ASSERTION[{node.attrib.get('property', 'MISSING')}]={node.attrib.get('status', 'MISSING')}")
PY

cat "$RUN/results/control_summary.txt"
cat "$RUN/results/control_all.stderr.txt" || true

[ "$CONTROL_CBMC_EXIT" -eq 0 ] || fail "CONTROL_CBMC_NONZERO_EXIT"
grep -Fxq 'CONTROL_CPROVER_STATUS=SUCCESS' "$RUN/results/control_summary.txt" || fail "CONTROL_CPROVER_NOT_SUCCESS"
grep -Fxq 'CONTROL_NON_SUCCESS_COUNT=0' "$RUN/results/control_summary.txt" || fail "CONTROL_NON_SUCCESS_PRESENT"
grep -Fxq 'CONTROL_HARNESS_ASSERTION_COUNT=7' "$RUN/results/control_summary.txt" || fail "CONTROL_ASSERTION_RESULT_COUNT_MISMATCH"
grep -Fxq 'CONTROL_HARNESS_ASSERTION_SUCCESS_COUNT=7' "$RUN/results/control_summary.txt" || fail "CONTROL_ASSERTION_FAILURE"

echo "PFB_T1_CONTROL_SUITE=PASS"

echo
echo "============================================================"
echo "PART 6 — POST-RUN INTEGRITY AND FAIL-CLOSED RESULT"
echo "============================================================"

[ "$(sha256sum "$THEOREM_HARNESS" | awk '{print $1}')" = "$EXPECTED_HARNESS_SHA256" ] || fail "THEOREM_HARNESS_CHANGED"
[ "$(sha256sum "$THEOREM_MAKEFILE" | awk '{print $1}')" = "$EXPECTED_MAKEFILE_SHA256" ] || fail "THEOREM_MAKEFILE_CHANGED"
[ "$(sha256sum "$THEOREM_GOTO" | awk '{print $1}')" = "$EXPECTED_GOTO_SHA256" ] || fail "THEOREM_GOTO_CHANGED"
[ "$(sha256sum "$WT/mlkem/src/compress.c" | awk '{print $1}')" = "$EXPECTED_COMPRESS_SHA256" ] || fail "PRODUCTION_SOURCE_CHANGED"
[ -z "$(git -C "$AUTH" status --porcelain=v1)" ] || fail "AUTHORITATIVE_TREE_DIRTY_AFTER_CONTROL"

if ! git -C "$WT" diff --quiet -- mlkem/src/compress.c mlkem/src/compress.h mlkem/src/params.h; then
  fail "WORKTREE_PRODUCTION_SOURCE_MODIFIED"
fi

{
  echo "PFB_STAGE=PFB-01C"
  echo "RUNNER_STATUS=COMPLETE"
  echo "SOURCE_COMMIT=$EXPECTED_COMMIT"
  echo "SOURCE_TREE=$EXPECTED_TREE"
  echo "PFB_01S_FAIL_CLOSED_RECHECK=PASS"
  echo "PFB_T1_SEMANTIC_BASELINE_STATUS=PASS"
  echo "CONTROL_CBMC_EXIT=$CONTROL_CBMC_EXIT"
  echo "PFB_T1_INPUT_FRAME_CONTROL=PASS"
  echo "PFB_T1_OUTPUT_CANARY_CONTROL=PASS"
  echo "PFB_T1_COMPLETE_OVERWRITE_CONTROL=PASS"
  echo "PFB_T1_NONCONSTANT_OUTPUT_CONTROL=PASS"
  echo "PFB_T1_CONTROL_SUITE=PASS"
  echo "THEOREM_ARTIFACTS_UNCHANGED=YES"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "AUTHORITATIVE_TREE_CLEAN=YES"
  echo "PFB_T1_FINAL_ACCEPTANCE=NO"
  echo "MUTATION_SENSITIVITY_PENDING=YES"
  echo "RUN_DIRECTORY=$RUN"
  echo "TERMINAL_OUTPUT=$OUT"
} > "$RUN/PFB_01C_RESULT.txt"

(
  cd "$RUN" || exit 1
  find . -type f ! -name SHA256SUMS.txt -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS.txt
)
[ "$?" -eq 0 ] || fail "RUN_HASH_MANIFEST_FAILED"

echo "RUN_SHA256SUMS_SHA256=$(sha256sum "$RUN/SHA256SUMS.txt" | awk '{print $1}')"
cat "$RUN/PFB_01C_RESULT.txt"

echo "============================================================"
echo "PFB-01C COMPLETE"
echo "FAIL-CLOSED BASELINE SEAL PASSED"
echo "ALL SEVEN CONTROL ASSERTIONS PASSED"
echo "NO THEOREM ARTIFACT MODIFIED"
echo "NO PRODUCTION SOURCE MODIFIED"
echo "SCRIPT_FINAL_EXIT=0"
echo "============================================================"

exit 0
