#!/usr/bin/env bash

# Clear any inherited errexit state. This matters when the script is pasted or
# sourced after an earlier `set -euo pipefail` command.
set +e
set -uo pipefail
umask 022

ROOT="$HOME/THESIS-2026"
AUTH="$ROOT/mlkem-native_af4c5abd"
WT="$ROOT/_cbmc_work/mlkem-native_pfb_af4c5abd"
PROOF="$WT/proofs/cbmc/pfb_t1_exact_raw_decode"

HARNESS="$PROOF/pfb_t1_exact_raw_decode_harness.c"
MAKEFILE="$PROOF/Makefile"
GOTO="$PROOF/gotos/pfb_t1_exact_raw_decode_harness.goto"

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_TREE="54805daff6a91a010c05467ea678117c42a71559"
EXPECTED_HARNESS_SHA256="9a3288855782f7aee718d51c7904608763bd480635a63d25cd05956d408007a8"
EXPECTED_MAKEFILE_SHA256="9e56741090a6634baddbe2ea9fe13637bbeed9a1ce62f93e2f228185cfe41526"
EXPECTED_GOTO_SHA256="13dd5ba4e64b4dd3c54a3d4e7c82ec0e3c1b09a397584cfa1a13309f60ceeb83"
EXPECTED_COMPRESS_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN="$ROOT/mlk_poly_frombytes_cleanroom/PFB_01S_T1_SAT_SEMANTIC_RUN2_${STAMP}"
OUT="/tmp/PFB_01S_T1_SAT_SEMANTIC_RUN2.txt"

mkdir -p "$RUN"/{results,binding}
exec > >(tee "$OUT") 2>&1

fail()
{
  echo "FATAL_BINDING_FAILURE=$1"
  echo "RUNNER_STATUS=ABORTED_BEFORE_CBMC_COMPLETION"
  exit 1
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

require_command()
{
  command -v "$1" >/dev/null 2>&1 || fail "COMMAND_NOT_FOUND_$1"
}

require_command git
require_command sha256sum
require_command goto-instrument
require_command cbmc
require_command python3
require_command timeout

printf '%s\n' "============================================================"
printf '%s\n' "PFB-01S — T1 SAT SEMANTIC PROOF AND COMPLETE-CHECK RUN"
printf '%s\n' "============================================================"
echo "STARTED_AT_UTC=$STAMP"
echo "RUN_DIRECTORY=$RUN"
echo "TERMINAL_OUTPUT=$OUT"

echo
echo "============================================================"
echo "PART 1 — IMMUTABLE ARTIFACT BINDING"
echo "============================================================"

[ -f "$HARNESS" ] || fail "HARNESS_ABSENT"
[ -f "$MAKEFILE" ] || fail "MAKEFILE_ABSENT"
[ -f "$GOTO" ] || fail "GOTO_ABSENT"
[ -f "$WT/mlkem/src/compress.c" ] || fail "COMPRESS_SOURCE_ABSENT"

AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null)" || fail "AUTHORITATIVE_HEAD_READ_FAILED"
AUTH_TREE="$(git -C "$AUTH" rev-parse 'HEAD^{tree}' 2>/dev/null)" || fail "AUTHORITATIVE_TREE_READ_FAILED"
WT_HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null)" || fail "WORKTREE_HEAD_READ_FAILED"
WT_TREE="$(git -C "$WT" rev-parse 'HEAD^{tree}' 2>/dev/null)" || fail "WORKTREE_TREE_READ_FAILED"

HARNESS_SHA256="$(sha256sum "$HARNESS" | awk '{print $1}')"
MAKEFILE_SHA256="$(sha256sum "$MAKEFILE" | awk '{print $1}')"
GOTO_SHA256="$(sha256sum "$GOTO" | awk '{print $1}')"
COMPRESS_SHA256="$(sha256sum "$WT/mlkem/src/compress.c" | awk '{print $1}')"

echo "AUTHORITATIVE_HEAD=$AUTH_HEAD"
echo "AUTHORITATIVE_TREE=$AUTH_TREE"
echo "WORKTREE_HEAD=$WT_HEAD"
echo "WORKTREE_TREE=$WT_TREE"
echo "HARNESS_SHA256=$HARNESS_SHA256"
echo "MAKEFILE_SHA256=$MAKEFILE_SHA256"
echo "GOTO_SHA256=$GOTO_SHA256"
echo "COMPRESS_SOURCE_SHA256=$COMPRESS_SHA256"

[ "$AUTH_HEAD" = "$EXPECTED_COMMIT" ] || fail "AUTHORITATIVE_COMMIT_MISMATCH"
[ "$AUTH_TREE" = "$EXPECTED_TREE" ] || fail "AUTHORITATIVE_TREE_MISMATCH"
[ "$WT_HEAD" = "$EXPECTED_COMMIT" ] || fail "WORKTREE_COMMIT_MISMATCH"
[ "$WT_TREE" = "$EXPECTED_TREE" ] || fail "WORKTREE_TREE_MISMATCH"
[ "$HARNESS_SHA256" = "$EXPECTED_HARNESS_SHA256" ] || fail "HARNESS_HASH_MISMATCH"
[ "$MAKEFILE_SHA256" = "$EXPECTED_MAKEFILE_SHA256" ] || fail "MAKEFILE_HASH_MISMATCH"
[ "$GOTO_SHA256" = "$EXPECTED_GOTO_SHA256" ] || fail "GOTO_HASH_MISMATCH"
[ "$COMPRESS_SHA256" = "$EXPECTED_COMPRESS_SHA256" ] || fail "COMPRESS_SOURCE_HASH_MISMATCH"
[ -z "$(git -C "$AUTH" status --porcelain=v1)" ] || fail "AUTHORITATIVE_TREE_DIRTY"

echo "IMMUTABLE_ARTIFACT_BINDING=PASS"

echo
echo "============================================================"
echo "PART 2 — GOTO CALL-CHAIN AND PROPERTY INVENTORY"
echo "============================================================"

if goto-instrument \
  --show-goto-functions \
  "$GOTO" \
  > "$RUN/binding/goto_functions.txt" \
  2> "$RUN/binding/goto_functions.stderr.txt"
then
  GOTO_DUMP_EXIT=0
else
  GOTO_DUMP_EXIT=$?
fi

echo "GOTO_DUMP_EXIT=$GOTO_DUMP_EXIT"
[ "$GOTO_DUMP_EXIT" = "0" ] || fail "GOTO_DUMP_FAILED"

HARNESS_TO_PUBLIC_CALL_COUNT="$(
  grep -c 'CALL mlk_poly_frombytes(' "$RUN/binding/goto_functions.txt" || true
)"
PUBLIC_TO_PORTABLE_CALL_COUNT="$(
  grep -c 'CALL mlk_poly_frombytes_c(' "$RUN/binding/goto_functions.txt" || true
)"
PORTABLE_BODY_OCCURRENCE_COUNT="$(
  grep -c 'function mlk_poly_frombytes_c' "$RUN/binding/goto_functions.txt" || true
)"

echo "HARNESS_TO_PUBLIC_CALL_COUNT=$HARNESS_TO_PUBLIC_CALL_COUNT"
echo "PUBLIC_TO_PORTABLE_CALL_COUNT=$PUBLIC_TO_PORTABLE_CALL_COUNT"
echo "PORTABLE_BODY_OCCURRENCE_COUNT=$PORTABLE_BODY_OCCURRENCE_COUNT"

[ "$HARNESS_TO_PUBLIC_CALL_COUNT" -ge 1 ] || fail "PUBLIC_WRAPPER_CALL_NOT_FOUND"
[ "$PUBLIC_TO_PORTABLE_CALL_COUNT" -ge 1 ] || fail "PORTABLE_BODY_CALL_NOT_FOUND"

# Static property inventory. Generated unwinding assertions are not selected by
# guessing a property ID; completeness is checked in the unfiltered full run.
if cbmc \
  --unwind 129 \
  --unwinding-assertions \
  --show-properties \
  "$GOTO" \
  > "$RUN/binding/show_properties.txt" \
  2> "$RUN/binding/show_properties.stderr.txt"
then
  SHOW_PROPERTIES_EXIT=0
else
  SHOW_PROPERTIES_EXIT=$?
fi

echo "SHOW_PROPERTIES_EXIT=$SHOW_PROPERTIES_EXIT"
[ "$SHOW_PROPERTIES_EXIT" = "0" ] || fail "SHOW_PROPERTIES_FAILED"

grep -nE \
  'CALL mlk_poly_frombytes|CALL mlk_poly_frombytes_c|PFB-T1\.P[12]' \
  "$RUN/binding/goto_functions.txt" || true

echo
echo "STATIC_PROPERTY_MATCHES"
grep -nE \
  'Property harness\.assertion\.[12]:|PFB-T1\.P[12]|unwind' \
  "$RUN/binding/show_properties.txt" || true

echo
echo "============================================================"
echo "PART 3 — COMMON EXACT-BODY CBMC CONFIGURATION"
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

printf 'COMMON_CBMC_FLAGS='
printf '%q ' "${COMMON_FLAGS[@]}"
printf '\n'

echo "SMT_OR_BITWUZLA_FLAG_PRESENT=NO"
echo "DUPLICATE_UNWIND_FLAG_PRESENT=NO"
echo "FUNCTION_CONTRACT_TRANSFORMATION_PRESENT=NO"
echo "LOOP_CONTRACT_TRANSFORMATION_PRESENT=NO"
echo "HARDCODED_UNWIND_PROPERTY_SELECTION_PRESENT=NO"

parse_xml()
{
  local xml_file="$1"
  local summary_file="$2"

  python3 - "$xml_file" "$summary_file" <<'PY'
from __future__ import annotations

import collections
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

xml_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])

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
    "P1_STATUS": "ABSENT",
    "P2_STATUS": "ABSENT",
    "UNWIND_PROPERTY_COUNT": "0",
    "UNWIND_SUCCESS_COUNT": "0",
    "UNWIND_FAILURE_COUNT": "0",
    "UNWIND_ERROR_COUNT": "0",
    "UNWIND_UNKNOWN_COUNT": "0",
    "UNWIND_NON_SUCCESS_COUNT": "0",
    "NON_SEMANTIC_PROPERTY_COUNT": "0",
    "NON_SEMANTIC_NON_SUCCESS_COUNT": "0",
}

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

        non_success = [
            result
            for result in results
            if result.attrib.get("status") != "SUCCESS"
        ]
        values["NON_SUCCESS_COUNT"] = str(len(non_success))

        status_nodes = [
            " ".join((element.text or "").split())
            for element in root.iter()
            if local_name(element.tag) == "cprover-status"
        ]
        if status_nodes:
            values["CPROVER_STATUS"] = "|".join(status_nodes)

        semantic_ids = {
            "harness.assertion.1": "P1_STATUS",
            "harness.assertion.2": "P2_STATUS",
        }

        for result in results:
            property_id = result.attrib.get("property", "")
            if property_id in semantic_ids:
                values[semantic_ids[property_id]] = result.attrib.get(
                    "status",
                    "MISSING",
                )

        unwind_results = []
        for result in results:
            property_id = result.attrib.get("property", "")
            if re.search(r"(^|\.)unwind(\.|$)", property_id, flags=re.I):
                unwind_results.append(result)

        unwind_counts = collections.Counter(
            result.attrib.get("status", "MISSING")
            for result in unwind_results
        )
        values["UNWIND_PROPERTY_COUNT"] = str(len(unwind_results))
        values["UNWIND_SUCCESS_COUNT"] = str(
            unwind_counts.get("SUCCESS", 0)
        )
        values["UNWIND_FAILURE_COUNT"] = str(
            unwind_counts.get("FAILURE", 0)
        )
        values["UNWIND_ERROR_COUNT"] = str(
            unwind_counts.get("ERROR", 0)
        )
        values["UNWIND_UNKNOWN_COUNT"] = str(
            unwind_counts.get("UNKNOWN", 0)
        )
        values["UNWIND_NON_SUCCESS_COUNT"] = str(
            sum(
                1
                for result in unwind_results
                if result.attrib.get("status") != "SUCCESS"
            )
        )

        non_semantic = [
            result
            for result in results
            if result.attrib.get("property", "")
            not in {"harness.assertion.1", "harness.assertion.2"}
        ]
        values["NON_SEMANTIC_PROPERTY_COUNT"] = str(len(non_semantic))
        values["NON_SEMANTIC_NON_SUCCESS_COUNT"] = str(
            sum(
                1
                for result in non_semantic
                if result.attrib.get("status") != "SUCCESS"
            )
        )

        print("----- NON-SUCCESS PROPERTIES -----")
        if not non_success:
            print("NONE")
        else:
            for number, result in enumerate(non_success, start=1):
                print(
                    f"{number}:"
                    f"{result.attrib.get('property', 'MISSING')}:"
                    f"{result.attrib.get('status', 'MISSING')}"
                )

        print("----- UNWINDING PROPERTY RESULTS -----")
        if not unwind_results:
            print("NONE_MATERIALIZED_IN_XML")
        else:
            for number, result in enumerate(unwind_results, start=1):
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
  shift 2

  local xml="$RUN/results/${name}.xml"
  local stderr="$RUN/results/${name}.stderr.txt"
  local command="$RUN/results/${name}.command.txt"
  local summary="$RUN/results/${name}.summary.txt"
  local exit_file="$RUN/results/${name}.exit.txt"
  local cbmc_exit

  {
    printf 'cbmc '
    printf '%q ' "${COMMON_FLAGS[@]}"
    printf '%q ' "$@"
    printf '%q\n' --xml-ui "$GOTO"
  } > "$command"

  echo
  echo "---------------- RUN=$name ----------------"
  cat "$command"

  # The command is deliberately inside an if-condition. Therefore even an
  # inherited `errexit` setting cannot terminate the evidence runner before the
  # CBMC exit code, XML and stderr are recorded.
  if /usr/bin/timeout \
    --signal=TERM \
    "$timeout_seconds" \
    cbmc \
    "${COMMON_FLAGS[@]}" \
    "$@" \
    --xml-ui \
    "$GOTO" \
    > "$xml" \
    2> "$stderr"
  then
    cbmc_exit=0
  else
    cbmc_exit=$?
  fi

  printf '%s\n' "$cbmc_exit" > "$exit_file"

  echo "CBMC_EXIT[$name]=$cbmc_exit"
  echo "XML_SIZE[$name]=$(stat -c '%s' "$xml" 2>/dev/null || echo 0)"
  echo "STDERR_SIZE[$name]=$(stat -c '%s' "$stderr" 2>/dev/null || echo 0)"

  parse_xml "$xml" "$summary"

  echo "---------------- STDERR=$name ----------------"
  cat "$stderr" || true
}

echo
echo "============================================================"
echo "PART 4 — PRIMARY SEMANTIC ASSERTIONS"
echo "============================================================"

run_cbmc \
  theorem_only \
  300 \
  --property harness.assertion.1 \
  --property harness.assertion.2

echo
echo "============================================================"
echo "PART 5 — UNFILTERED COMPLETE PROPERTY SET"
echo "============================================================"
echo "NOTE=No guessed .unwind.0 property is selected."
echo "NOTE=The full run checks generated unwinding assertions together with all enabled semantic and safety properties."

run_cbmc \
  all_properties \
  600

THEOREM_SUMMARY="$RUN/results/theorem_only.summary.txt"
ALL_SUMMARY="$RUN/results/all_properties.summary.txt"

THEOREM_EXIT="$(cat "$RUN/results/theorem_only.exit.txt" 2>/dev/null || true)"
ALL_EXIT="$(cat "$RUN/results/all_properties.exit.txt" 2>/dev/null || true)"

P1_STATUS="$(read_value "$THEOREM_SUMMARY" P1_STATUS)"
P2_STATUS="$(read_value "$THEOREM_SUMMARY" P2_STATUS)"
THEOREM_CPROVER="$(read_value "$THEOREM_SUMMARY" CPROVER_STATUS)"
THEOREM_NON_SUCCESS="$(read_value "$THEOREM_SUMMARY" NON_SUCCESS_COUNT)"

ALL_P1_STATUS="$(read_value "$ALL_SUMMARY" P1_STATUS)"
ALL_P2_STATUS="$(read_value "$ALL_SUMMARY" P2_STATUS)"
ALL_CPROVER="$(read_value "$ALL_SUMMARY" CPROVER_STATUS)"
ALL_PROPERTY_COUNT="$(read_value "$ALL_SUMMARY" PROPERTY_COUNT)"
ALL_SUCCESS_COUNT="$(read_value "$ALL_SUMMARY" SUCCESS_COUNT)"
ALL_ERROR_COUNT="$(read_value "$ALL_SUMMARY" ERROR_COUNT)"
ALL_FAILURE_COUNT="$(read_value "$ALL_SUMMARY" FAILURE_COUNT)"
ALL_UNKNOWN_COUNT="$(read_value "$ALL_SUMMARY" UNKNOWN_COUNT)"
ALL_NON_SUCCESS="$(read_value "$ALL_SUMMARY" NON_SUCCESS_COUNT)"
UNWIND_PROPERTY_COUNT="$(read_value "$ALL_SUMMARY" UNWIND_PROPERTY_COUNT)"
UNWIND_SUCCESS_COUNT="$(read_value "$ALL_SUMMARY" UNWIND_SUCCESS_COUNT)"
UNWIND_NON_SUCCESS_COUNT="$(read_value "$ALL_SUMMARY" UNWIND_NON_SUCCESS_COUNT)"
NON_SEMANTIC_PROPERTY_COUNT="$(read_value "$ALL_SUMMARY" NON_SEMANTIC_PROPERTY_COUNT)"
NON_SEMANTIC_NON_SUCCESS_COUNT="$(read_value "$ALL_SUMMARY" NON_SEMANTIC_NON_SUCCESS_COUNT)"

THEOREM_PASS=NO
if [ "$THEOREM_EXIT" = "0" ] &&
   [ "$P1_STATUS" = "SUCCESS" ] &&
   [ "$P2_STATUS" = "SUCCESS" ] &&
   [ "$THEOREM_CPROVER" = "SUCCESS" ] &&
   [ "$THEOREM_NON_SUCCESS" = "0" ]
then
  THEOREM_PASS=YES
fi

ALL_PROPERTIES_PASS=NO
if [ "$ALL_EXIT" = "0" ] &&
   [ "$ALL_CPROVER" = "SUCCESS" ] &&
   [ "$ALL_NON_SUCCESS" = "0" ] &&
   [ "$ALL_P1_STATUS" = "SUCCESS" ] &&
   [ "$ALL_P2_STATUS" = "SUCCESS" ]
then
  ALL_PROPERTIES_PASS=YES
fi

# With --unwinding-assertions enabled and no --property filter, a successful
# complete run establishes that the chosen bound is sufficient. XML unwind IDs
# are recorded when CBMC materializes them, but acceptance does not depend on a
# guessed static property identifier.
UNWIND_PASS=NO
UNWIND_EVIDENCE_MODE="FULL_RUN_DID_NOT_PASS"
if [ "$ALL_PROPERTIES_PASS" = "YES" ]; then
  UNWIND_PASS=YES
  if [ "${UNWIND_PROPERTY_COUNT:-0}" -gt 0 ] 2>/dev/null; then
    UNWIND_EVIDENCE_MODE="MATERIALIZED_XML_UNWIND_PROPERTIES"
  else
    UNWIND_EVIDENCE_MODE="FULL_SUCCESS_WITH_UNWINDING_ASSERTIONS_ENABLED"
  fi
fi

NON_SEMANTIC_PASS=NO
if [ "$ALL_PROPERTIES_PASS" = "YES" ] &&
   [ "${NON_SEMANTIC_NON_SUCCESS_COUNT:-1}" = "0" ]
then
  NON_SEMANTIC_PASS=YES
fi

SEMANTIC_BASELINE_STATUS=NOT_PASS
if [ "$THEOREM_PASS" = "YES" ] &&
   [ "$ALL_PROPERTIES_PASS" = "YES" ] &&
   [ "$UNWIND_PASS" = "YES" ]
then
  SEMANTIC_BASELINE_STATUS=PASS
fi

echo
echo "============================================================"
echo "PART 6 — POST-RUN SOURCE INTEGRITY"
echo "============================================================"

HARNESS_SHA256_AFTER="$(sha256sum "$HARNESS" | awk '{print $1}')"
MAKEFILE_SHA256_AFTER="$(sha256sum "$MAKEFILE" | awk '{print $1}')"
GOTO_SHA256_AFTER="$(sha256sum "$GOTO" | awk '{print $1}')"
COMPRESS_SHA256_AFTER="$(sha256sum "$WT/mlkem/src/compress.c" | awk '{print $1}')"

echo "HARNESS_SHA256_AFTER=$HARNESS_SHA256_AFTER"
echo "MAKEFILE_SHA256_AFTER=$MAKEFILE_SHA256_AFTER"
echo "GOTO_SHA256_AFTER=$GOTO_SHA256_AFTER"
echo "COMPRESS_SOURCE_SHA256_AFTER=$COMPRESS_SHA256_AFTER"

POST_RUN_HASH_BINDING=PASS
[ "$HARNESS_SHA256_AFTER" = "$EXPECTED_HARNESS_SHA256" ] || POST_RUN_HASH_BINDING=FAIL
[ "$MAKEFILE_SHA256_AFTER" = "$EXPECTED_MAKEFILE_SHA256" ] || POST_RUN_HASH_BINDING=FAIL
[ "$GOTO_SHA256_AFTER" = "$EXPECTED_GOTO_SHA256" ] || POST_RUN_HASH_BINDING=FAIL
[ "$COMPRESS_SHA256_AFTER" = "$EXPECTED_COMPRESS_SHA256" ] || POST_RUN_HASH_BINDING=FAIL

echo "POST_RUN_HASH_BINDING=$POST_RUN_HASH_BINDING"

if git -C "$WT" diff --quiet -- \
  mlkem/src/compress.c \
  mlkem/src/compress.h \
  mlkem/src/params.h
then
  echo "WORKTREE_PRODUCTION_SOURCE_MODIFIED=NO"
else
  echo "WORKTREE_PRODUCTION_SOURCE_MODIFIED=YES"
fi

if [ -z "$(git -C "$AUTH" status --porcelain=v1)" ]; then
  echo "AUTHORITATIVE_TREE_CLEAN_AFTER_RUN=YES"
else
  echo "AUTHORITATIVE_TREE_CLEAN_AFTER_RUN=NO"
fi

{
  echo "PFB_STAGE=PFB-01S-RUN2"
  echo "RUNNER_STATUS=COMPLETE"
  echo "STARTED_AT_UTC=$STAMP"
  echo "SOURCE_COMMIT=$EXPECTED_COMMIT"
  echo "SOURCE_TREE=$EXPECTED_TREE"

  echo "THEOREM_CBMC_EXIT=$THEOREM_EXIT"
  echo "PFB_T1_P1_STATUS=$P1_STATUS"
  echo "PFB_T1_P2_STATUS=$P2_STATUS"
  echo "THEOREM_CPROVER_STATUS=$THEOREM_CPROVER"
  echo "THEOREM_ONLY_PASS=$THEOREM_PASS"

  echo "ALL_PROPERTIES_CBMC_EXIT=$ALL_EXIT"
  echo "ALL_PROPERTIES_CPROVER_STATUS=$ALL_CPROVER"
  echo "ALL_PROPERTIES_PROPERTY_COUNT=$ALL_PROPERTY_COUNT"
  echo "ALL_PROPERTIES_SUCCESS_COUNT=$ALL_SUCCESS_COUNT"
  echo "ALL_PROPERTIES_ERROR_COUNT=$ALL_ERROR_COUNT"
  echo "ALL_PROPERTIES_FAILURE_COUNT=$ALL_FAILURE_COUNT"
  echo "ALL_PROPERTIES_UNKNOWN_COUNT=$ALL_UNKNOWN_COUNT"
  echo "ALL_PROPERTIES_NON_SUCCESS_COUNT=$ALL_NON_SUCCESS"
  echo "ALL_PROPERTIES_P1_STATUS=$ALL_P1_STATUS"
  echo "ALL_PROPERTIES_P2_STATUS=$ALL_P2_STATUS"
  echo "ALL_PROPERTIES_PASS=$ALL_PROPERTIES_PASS"

  echo "UNWIND_PROPERTY_COUNT=$UNWIND_PROPERTY_COUNT"
  echo "UNWIND_SUCCESS_COUNT=$UNWIND_SUCCESS_COUNT"
  echo "UNWIND_NON_SUCCESS_COUNT=$UNWIND_NON_SUCCESS_COUNT"
  echo "UNWIND_EVIDENCE_MODE=$UNWIND_EVIDENCE_MODE"
  echo "UNWIND_PASS=$UNWIND_PASS"

  echo "NON_SEMANTIC_PROPERTY_COUNT=$NON_SEMANTIC_PROPERTY_COUNT"
  echo "NON_SEMANTIC_NON_SUCCESS_COUNT=$NON_SEMANTIC_NON_SUCCESS_COUNT"
  echo "NON_SEMANTIC_COMPLETE_CHECK_PASS=$NON_SEMANTIC_PASS"

  echo "POST_RUN_HASH_BINDING=$POST_RUN_HASH_BINDING"
  echo "PFB_T1_SEMANTIC_BASELINE_STATUS=$SEMANTIC_BASELINE_STATUS"
  echo "PFB_T1_FINAL_ACCEPTANCE=NO"
  echo "NONVACUITY_AND_MUTATION_CONTROLS_PENDING=YES"
  echo "RUN_DIRECTORY=$RUN"
  echo "TERMINAL_OUTPUT=$OUT"
} > "$RUN/PFB_01S_RESULT.txt"

(
  cd "$RUN" || exit 1
  find . \
    -type f \
    ! -name SHA256SUMS.txt \
    -print0 |
    sort -z |
    xargs -0 sha256sum \
    > SHA256SUMS.txt
)

echo
echo "============================================================"
echo "PFB-01S RUN2 RESULT"
echo "============================================================"
cat "$RUN/PFB_01S_RESULT.txt"

echo "RUN_SHA256SUMS_SHA256=$(sha256sum "$RUN/SHA256SUMS.txt" | awk '{print $1}')"

echo
echo "============================================================"
echo "PFB-01S RUN2 COMPLETE"
echo "RUNNER_STATUS=COMPLETE"
echo "DEFAULT SAT BACKEND USED"
echo "NO BITWUZLA OR SMT BACKEND USED"
echo "NO GUESSED UNWIND PROPERTY ID USED"
echo "NO HARNESS MODIFIED"
echo "NO MAKEFILE MODIFIED"
echo "NO GOTO BINARY MODIFIED"
echo "NO PRODUCTION SOURCE MODIFIED"
echo "SCRIPT_FINAL_EXIT=0"
echo "============================================================"

exit 0
