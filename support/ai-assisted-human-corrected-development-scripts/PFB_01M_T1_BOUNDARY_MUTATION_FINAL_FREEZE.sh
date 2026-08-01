#!/usr/bin/env bash

# PFB-01M
# Final PFB-T1 boundary, mutation-sensitivity, fail-closed acceptance, and freeze.

set -uo pipefail
umask 022

ROOT="$HOME/THESIS-2026"
AUTH="$ROOT/mlkem-native_af4c5abd"
WT="$ROOT/_cbmc_work/mlkem-native_pfb_af4c5abd"
CAMPAIGN="$ROOT/mlk_poly_frombytes_cleanroom"

FREEZE_00C="$CAMPAIGN/PFB_00C_THEOREM_FREEZE_af4c5abd"
BASELINE_01S="$CAMPAIGN/PFB_01S_T1_SAT_SEMANTIC_RUN2_20260729T040920Z"
CONTROL_01C="$CAMPAIGN/PFB_01C_T1_CONTROL_SUITE_20260729T042046Z"

THEOREM_PROOF="$WT/proofs/cbmc/pfb_t1_exact_raw_decode"
THEOREM_HARNESS="$THEOREM_PROOF/pfb_t1_exact_raw_decode_harness.c"
THEOREM_MAKEFILE="$THEOREM_PROOF/Makefile"
THEOREM_GOTO="$THEOREM_PROOF/gotos/pfb_t1_exact_raw_decode_harness.goto"

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_TREE="54805daff6a91a010c05467ea678117c42a71559"
EXPECTED_HARNESS_SHA256="9a3288855782f7aee718d51c7904608763bd480635a63d25cd05956d408007a8"
EXPECTED_MAKEFILE_SHA256="9e56741090a6634baddbe2ea9fe13637bbeed9a1ce62f93e2f228185cfe41526"
EXPECTED_GOTO_SHA256="13dd5ba4e64b4dd3c54a3d4e7c82ec0e3c1b09a397584cfa1a13309f60ceeb83"
EXPECTED_COMPRESS_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN="$CAMPAIGN/PFB_01M_T1_BOUNDARY_MUTATION_RUN_${STAMP}"
FINAL_FREEZE="$CAMPAIGN/PFB_T1_FINAL_FREEZE_af4c5abd_${STAMP}"
ARCHIVE="$CAMPAIGN/PFB_T1_FINAL_FREEZE_af4c5abd_${STAMP}.tar.gz"
OUT="/tmp/PFB_01M_T1_BOUNDARY_MUTATION_FINAL_FREEZE.txt"

BOUNDARY_PROOF="$WT/proofs/cbmc/pfb_t1_boundaries"
BOUNDARY_HARNESS="$BOUNDARY_PROOF/pfb_t1_boundaries_harness.c"
BOUNDARY_MAKEFILE="$BOUNDARY_PROOF/Makefile"
BOUNDARY_GOTO="$BOUNDARY_PROOF/gotos/pfb_t1_boundaries_harness.goto"

MUT_E_WT="$ROOT/_cbmc_work/mlkem-native_pfb_t1_mut_even_af4c5abd"
MUT_O_WT="$ROOT/_cbmc_work/mlkem-native_pfb_t1_mut_odd_af4c5abd"

mkdir -p "$RUN"/{binding,baseline_replay,boundary,mutants/even,mutants/odd,integrity}
exec > >(tee "$OUT") 2>&1

fail()
{
  local reason="$1"
  echo
  echo "FATAL_FAILURE=$reason"
  echo "PFB_T1_FINAL_ACCEPTANCE=NO"
  echo "RUNNER_STATUS=FAIL_CLOSED"
  echo "PARTIAL_RUN_DIRECTORY=$RUN"
  echo "TERMINAL_OUTPUT=$OUT"
  exit 1
}

require_command()
{
  command -v "$1" >/dev/null 2>&1 || fail "COMMAND_NOT_FOUND_$1"
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

require_kv()
{
  local file="$1"
  local key="$2"
  local expected="$3"
  local actual

  actual="$(read_value "$file" "$key")"
  if [ "$actual" = "$expected" ]; then
    echo "GATE[$key=$expected]=PASS"
  else
    echo "GATE[$key=$expected]=FAIL"
    echo "ACTUAL[$key]=${actual:-ABSENT}"
    fail "KEY_VALUE_GATE_${key}"
  fi
}

parse_xml()
{
  local xml_file="$1"
  local summary_file="$2"

  python3 - "$xml_file" "$summary_file" <<'PY'
from __future__ import annotations

import collections
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
}

for number in range(1, 8):
    values[f"H{number}_STATUS"] = "ABSENT"

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

        status_nodes = [
            " ".join((element.text or "").split())
            for element in root.iter()
            if local_name(element.tag) == "cprover-status"
        ]
        if status_nodes:
            values["CPROVER_STATUS"] = "|".join(status_nodes)

        for result in results:
            property_id = result.attrib.get("property", "")
            for number in range(1, 8):
                if property_id == f"harness.assertion.{number}":
                    values[f"H{number}_STATUS"] = result.attrib.get(
                        "status", "MISSING"
                    )

        print("----- NON-SUCCESS PROPERTIES -----")
        non_success = [
            result
            for result in results
            if result.attrib.get("status") != "SUCCESS"
        ]
        if not non_success:
            print("NONE")
        else:
            for index, result in enumerate(non_success, start=1):
                print(
                    f"{index}:"
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

run_cbmc_xml()
{
  local name="$1"
  local goto_file="$2"
  local timeout_seconds="$3"
  shift 3

  local dir="$RUN/$name"
  local xml="$dir/result.xml"
  local stderr="$dir/result.stderr.txt"
  local command="$dir/command.txt"
  local summary="$dir/summary.txt"
  local exit_file="$dir/exit.txt"
  local cbmc_exit

  mkdir -p "$dir"

  {
    printf 'cbmc '
    printf '%q ' "${COMMON_FLAGS[@]}"
    printf '%q ' "$@"
    printf '%q ' --xml-ui "$goto_file"
    printf '\n'
  } > "$command"

  echo "CBMC_COMMAND[$name]=$(cat "$command")"

  if /usr/bin/timeout \
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

  printf '%s\n' "$cbmc_exit" > "$exit_file"
  echo "CBMC_EXIT[$name]=$cbmc_exit"
  echo "XML_SIZE[$name]=$(stat -c '%s' "$xml" 2>/dev/null || echo 0)"
  echo "STDERR_SIZE[$name]=$(stat -c '%s' "$stderr" 2>/dev/null || echo 0)"

  parse_xml "$xml" "$summary"

  if [ -s "$stderr" ]; then
    echo "----- STDERR[$name] -----"
    cat "$stderr"
  fi
}

patch_proof_makefile()
{
  local makefile="$1"
  local old_harness="$2"
  local new_harness="$3"
  local old_uid="$4"
  local new_uid="$5"

  python3 - "$makefile" "$old_harness" "$new_harness" "$old_uid" "$new_uid" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
old_harness = sys.argv[2]
new_harness = sys.argv[3]
old_uid = sys.argv[4]
new_uid = sys.argv[5]
text = path.read_text(encoding="utf-8")

replacements = [
    (f"HARNESS_FILE = {old_harness}", f"HARNESS_FILE = {new_harness}"),
    (f"PROOF_UID = {old_uid}", f"PROOF_UID = {new_uid}"),
    ("CBMCFLAGS=--bitwuzla", "CBMCFLAGS="),
]

for old, new in replacements:
    count = text.count(old)
    print(f"REPLACEMENT_COUNT[{old}]={count}")
    if count != 1:
        raise SystemExit(
            f"Expected exactly one occurrence of {old!r}; found {count}"
        )
    text = text.replace(old, new, 1)

path.write_text(text, encoding="utf-8")
PY
}

build_goto()
{
  local proof_dir="$1"
  local goto_file="$2"
  local label="$3"
  local build_dir="$RUN/$label/build"
  local make_exit

  mkdir -p "$build_dir"

  if /usr/bin/timeout 300 make -C "$proof_dir" -j1 \
    > "$build_dir/make.stdout.txt" \
    2> "$build_dir/make.stderr.txt"
  then
    make_exit=0
  else
    make_exit=$?
  fi

  echo "MAKE_EXIT[$label]=$make_exit"
  echo "NOTE[$label]=Make/Litani final status is not an acceptance gate; GOTO creation and direct CBMC are authoritative."

  if [ ! -f "$goto_file" ]; then
    echo "----- MAKE STDOUT TAIL[$label] -----"
    tail -n 120 "$build_dir/make.stdout.txt" || true
    echo "----- MAKE STDERR TAIL[$label] -----"
    tail -n 120 "$build_dir/make.stderr.txt" || true
    fail "GOTO_NOT_CREATED_$label"
  fi

  echo "GOTO_CREATED[$label]=YES"
  echo "GOTO_SHA256[$label]=$(sha256sum "$goto_file" | awk '{print $1}')"
}

prepare_mutant()
{
  local label="$1"
  local mutant_wt="$2"
  local mutation_kind="$3"
  local expected_h1="$4"
  local expected_h2="$5"

  local mutant_proof="$mutant_wt/proofs/cbmc/pfb_t1_mut_${label}"
  local mutant_harness_name="pfb_t1_mut_${label}_harness"
  local mutant_harness="$mutant_proof/${mutant_harness_name}.c"
  local mutant_makefile="$mutant_proof/Makefile"
  local mutant_goto="$mutant_proof/gotos/${mutant_harness_name}.goto"
  local result_dir="$RUN/mutants/$label"
  local summary="$result_dir/summary.txt"
  local cbmc_exit
  local h1_status
  local h2_status
  local cprover_status
  local property_count
  local success_count
  local failure_count
  local error_count
  local unknown_count

  echo
  echo "---------------- MUTANT=$label ----------------"

  [ ! -e "$mutant_wt" ] || fail "MUTANT_WORKTREE_ALREADY_EXISTS_$label"

  git -C "$AUTH" worktree add --detach "$mutant_wt" "$EXPECTED_COMMIT" \
    > "$result_dir/worktree_add.stdout.txt" \
    2> "$result_dir/worktree_add.stderr.txt" \
    || fail "MUTANT_WORKTREE_CREATION_FAILED_$label"

  mkdir -p "$mutant_proof"
  cp "$THEOREM_HARNESS" "$mutant_harness"
  cp "$THEOREM_MAKEFILE" "$mutant_makefile"

  patch_proof_makefile \
    "$mutant_makefile" \
    "pfb_t1_exact_raw_decode_harness" \
    "$mutant_harness_name" \
    "pfb_t1_exact_raw_decode" \
    "pfb_t1_mut_${label}"

  python3 - "$mutant_wt/mlkem/src/compress.c" "$mutation_kind" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
kind = sys.argv[2]
text = path.read_text(encoding="utf-8")

start_marker = "MLK_STATIC_TESTABLE void mlk_poly_frombytes_c"
end_marker = "void mlk_poly_frombytes("

start = text.find(start_marker)
end = text.find(end_marker, start + 1)
if start < 0 or end < 0 or end <= start:
    raise SystemExit("Could not isolate mlk_poly_frombytes_c source region")

prefix = text[:start]
body = text[start:end]
suffix = text[end:]

if kind == "even_shift_8_to_7":
    old = "(uint16_t)t1 << 8"
    new = "(uint16_t)t1 << 7"
elif kind == "odd_shift_4_to_3":
    old = "t2 << 4"
    new = "t2 << 3"
else:
    raise SystemExit(f"Unknown mutation kind: {kind}")

count = body.count(old)
print(f"MUTATION_PATTERN_COUNT[{old}]={count}")
if count != 1:
    raise SystemExit(
        f"Expected one mutation location for {old!r}; found {count}"
    )

body = body.replace(old, new, 1)
path.write_text(prefix + body + suffix, encoding="utf-8")
print(f"MUTATION_APPLIED={kind}")
PY

  git -C "$mutant_wt" diff -- mlkem/src/compress.c \
    > "$result_dir/compress_mutation.diff"

  [ -s "$result_dir/compress_mutation.diff" ] \
    || fail "EMPTY_MUTATION_DIFF_$label"

  echo "MUTANT_SOURCE_SHA256[$label]=$(
    sha256sum "$mutant_wt/mlkem/src/compress.c" | awk '{print $1}'
  )"

  echo "MUTATION_DIFF[$label]_BEGIN"
  cat "$result_dir/compress_mutation.diff"
  echo "MUTATION_DIFF[$label]_END"

  build_goto "$mutant_proof" "$mutant_goto" "mutants/$label"

  run_cbmc_xml \
    "mutants/$label" \
    "$mutant_goto" \
    300 \
    --property harness.assertion.1 \
    --property harness.assertion.2

  cbmc_exit="$(cat "$result_dir/exit.txt" 2>/dev/null || true)"
  h1_status="$(read_value "$summary" H1_STATUS)"
  h2_status="$(read_value "$summary" H2_STATUS)"
  cprover_status="$(read_value "$summary" CPROVER_STATUS)"
  property_count="$(read_value "$summary" PROPERTY_COUNT)"
  success_count="$(read_value "$summary" SUCCESS_COUNT)"
  failure_count="$(read_value "$summary" FAILURE_COUNT)"
  error_count="$(read_value "$summary" ERROR_COUNT)"
  unknown_count="$(read_value "$summary" UNKNOWN_COUNT)"

  echo "MUTANT_RESULT[$label].CBMC_EXIT=$cbmc_exit"
  echo "MUTANT_RESULT[$label].H1_STATUS=$h1_status"
  echo "MUTANT_RESULT[$label].H2_STATUS=$h2_status"
  echo "MUTANT_RESULT[$label].CPROVER_STATUS=$cprover_status"
  echo "MUTANT_RESULT[$label].PROPERTY_COUNT=$property_count"
  echo "MUTANT_RESULT[$label].SUCCESS_COUNT=$success_count"
  echo "MUTANT_RESULT[$label].FAILURE_COUNT=$failure_count"
  echo "MUTANT_RESULT[$label].ERROR_COUNT=$error_count"
  echo "MUTANT_RESULT[$label].UNKNOWN_COUNT=$unknown_count"

  [ "$cbmc_exit" != "0" ] || fail "MUTANT_NOT_KILLED_EXIT_ZERO_$label"
  [ "$cprover_status" = "FAILURE" ] || fail "MUTANT_CPROVER_NOT_FAILURE_$label"
  [ "$property_count" = "2" ] || fail "MUTANT_PROPERTY_COUNT_$label"
  [ "$success_count" = "1" ] || fail "MUTANT_SUCCESS_COUNT_$label"
  [ "$failure_count" = "1" ] || fail "MUTANT_FAILURE_COUNT_$label"
  [ "$error_count" = "0" ] || fail "MUTANT_ERROR_COUNT_$label"
  [ "$unknown_count" = "0" ] || fail "MUTANT_UNKNOWN_COUNT_$label"
  [ "$h1_status" = "$expected_h1" ] || fail "MUTANT_H1_STATUS_$label"
  [ "$h2_status" = "$expected_h2" ] || fail "MUTANT_H2_STATUS_$label"

  echo "MUTANT_KILLED[$label]=YES"
}

for command in \
  git sha256sum python3 cbmc goto-instrument make timeout tar gzip awk grep sed
 do
  require_command "$command"
 done

printf '%s\n' "============================================================"
printf '%s\n' "PFB-01M — T1 BOUNDARY, MUTATION, AND FINAL FREEZE"
printf '%s\n' "============================================================"
echo "STARTED_AT_UTC=$STAMP"
echo "RUN_DIRECTORY=$RUN"
echo "FINAL_FREEZE_DIRECTORY=$FINAL_FREEZE"
echo "FINAL_ARCHIVE=$ARCHIVE"
echo "TERMINAL_OUTPUT=$OUT"

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

echo
echo "============================================================"
echo "PART 1 — PRIOR EVIDENCE FAIL-CLOSED RE-BINDING"
echo "============================================================"

[ -d "$FREEZE_00C" ] || fail "PFB_00C_FREEZE_ABSENT"
[ -d "$BASELINE_01S" ] || fail "PFB_01S_BASELINE_ABSENT"
[ -d "$CONTROL_01C" ] || fail "PFB_01C_CONTROL_ABSENT"

(
  cd "$FREEZE_00C" || exit 1
  sha256sum -c SHA256SUMS.txt
) > "$RUN/integrity/PFB_00C_sha256_check.txt" 2>&1 \
  || fail "PFB_00C_HASH_CHECK_FAILED"

echo "PFB_00C_HASH_CHECK=PASS"

(
  cd "$BASELINE_01S" || exit 1
  sha256sum -c SHA256SUMS.txt
) > "$RUN/integrity/PFB_01S_sha256_check.txt" 2>&1 \
  || fail "PFB_01S_HASH_CHECK_FAILED"

echo "PFB_01S_HASH_CHECK=PASS"

(
  cd "$CONTROL_01C" || exit 1
  sha256sum -c SHA256SUMS.txt
) > "$RUN/integrity/PFB_01C_sha256_check.txt" 2>&1 \
  || fail "PFB_01C_HASH_CHECK_FAILED"

echo "PFB_01C_HASH_CHECK=PASS"

BASELINE_RESULT="$BASELINE_01S/PFB_01S_RESULT.txt"
CONTROL_RESULT="$CONTROL_01C/PFB_01C_RESULT.txt"

[ -f "$BASELINE_RESULT" ] || fail "PFB_01S_RESULT_ABSENT"
[ -f "$CONTROL_RESULT" ] || fail "PFB_01C_RESULT_ABSENT"

require_kv "$BASELINE_RESULT" "THEOREM_CBMC_EXIT" "0"
require_kv "$BASELINE_RESULT" "PFB_T1_P1_STATUS" "SUCCESS"
require_kv "$BASELINE_RESULT" "PFB_T1_P2_STATUS" "SUCCESS"
require_kv "$BASELINE_RESULT" "THEOREM_ONLY_PASS" "YES"
require_kv "$BASELINE_RESULT" "ALL_PROPERTIES_CBMC_EXIT" "0"
require_kv "$BASELINE_RESULT" "ALL_PROPERTIES_PROPERTY_COUNT" "113"
require_kv "$BASELINE_RESULT" "ALL_PROPERTIES_SUCCESS_COUNT" "113"
require_kv "$BASELINE_RESULT" "ALL_PROPERTIES_NON_SUCCESS_COUNT" "0"
require_kv "$BASELINE_RESULT" "ALL_PROPERTIES_PASS" "YES"
require_kv "$BASELINE_RESULT" "UNWIND_PASS" "YES"
require_kv "$BASELINE_RESULT" "NON_SEMANTIC_COMPLETE_CHECK_PASS" "YES"
require_kv "$BASELINE_RESULT" "POST_RUN_HASH_BINDING" "PASS"
require_kv "$BASELINE_RESULT" "PFB_T1_SEMANTIC_BASELINE_STATUS" "PASS"

require_kv "$CONTROL_RESULT" "PFB_01S_FAIL_CLOSED_RECHECK" "PASS"
require_kv "$CONTROL_RESULT" "PFB_T1_SEMANTIC_BASELINE_STATUS" "PASS"
require_kv "$CONTROL_RESULT" "CONTROL_CBMC_EXIT" "0"
require_kv "$CONTROL_RESULT" "PFB_T1_INPUT_FRAME_CONTROL" "PASS"
require_kv "$CONTROL_RESULT" "PFB_T1_OUTPUT_CANARY_CONTROL" "PASS"
require_kv "$CONTROL_RESULT" "PFB_T1_COMPLETE_OVERWRITE_CONTROL" "PASS"
require_kv "$CONTROL_RESULT" "PFB_T1_NONCONSTANT_OUTPUT_CONTROL" "PASS"
require_kv "$CONTROL_RESULT" "PFB_T1_CONTROL_SUITE" "PASS"
require_kv "$CONTROL_RESULT" "THEOREM_ARTIFACTS_UNCHANGED" "YES"
require_kv "$CONTROL_RESULT" "PRODUCTION_SOURCE_MODIFIED" "NO"
require_kv "$CONTROL_RESULT" "AUTHORITATIVE_TREE_CLEAN" "YES"

echo "PRIOR_EVIDENCE_FAIL_CLOSED_REBINDING=PASS"

echo
echo "============================================================"
echo "PART 2 — IMMUTABLE SOURCE, HARNESS, MAKEFILE, AND GOTO BINDING"
echo "============================================================"

[ -f "$THEOREM_HARNESS" ] || fail "THEOREM_HARNESS_ABSENT"
[ -f "$THEOREM_MAKEFILE" ] || fail "THEOREM_MAKEFILE_ABSENT"
[ -f "$THEOREM_GOTO" ] || fail "THEOREM_GOTO_ABSENT"

AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null)" \
  || fail "AUTHORITATIVE_HEAD_READ_FAILED"
AUTH_TREE="$(git -C "$AUTH" rev-parse 'HEAD^{tree}' 2>/dev/null)" \
  || fail "AUTHORITATIVE_TREE_READ_FAILED"
WT_HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null)" \
  || fail "WORKTREE_HEAD_READ_FAILED"
WT_TREE="$(git -C "$WT" rev-parse 'HEAD^{tree}' 2>/dev/null)" \
  || fail "WORKTREE_TREE_READ_FAILED"

HARNESS_SHA256="$(sha256sum "$THEOREM_HARNESS" | awk '{print $1}')"
MAKEFILE_SHA256="$(sha256sum "$THEOREM_MAKEFILE" | awk '{print $1}')"
GOTO_SHA256="$(sha256sum "$THEOREM_GOTO" | awk '{print $1}')"
COMPRESS_SHA256="$(sha256sum "$WT/mlkem/src/compress.c" | awk '{print $1}')"

echo "AUTHORITATIVE_HEAD=$AUTH_HEAD"
echo "AUTHORITATIVE_TREE=$AUTH_TREE"
echo "WORKTREE_HEAD=$WT_HEAD"
echo "WORKTREE_TREE=$WT_TREE"
echo "THEOREM_HARNESS_SHA256=$HARNESS_SHA256"
echo "THEOREM_MAKEFILE_SHA256=$MAKEFILE_SHA256"
echo "THEOREM_GOTO_SHA256=$GOTO_SHA256"
echo "COMPRESS_SOURCE_SHA256=$COMPRESS_SHA256"

[ "$AUTH_HEAD" = "$EXPECTED_COMMIT" ] || fail "AUTHORITATIVE_COMMIT_MISMATCH"
[ "$AUTH_TREE" = "$EXPECTED_TREE" ] || fail "AUTHORITATIVE_TREE_MISMATCH"
[ "$WT_HEAD" = "$EXPECTED_COMMIT" ] || fail "WORKTREE_COMMIT_MISMATCH"
[ "$WT_TREE" = "$EXPECTED_TREE" ] || fail "WORKTREE_TREE_MISMATCH"
[ "$HARNESS_SHA256" = "$EXPECTED_HARNESS_SHA256" ] || fail "THEOREM_HARNESS_HASH_MISMATCH"
[ "$MAKEFILE_SHA256" = "$EXPECTED_MAKEFILE_SHA256" ] || fail "THEOREM_MAKEFILE_HASH_MISMATCH"
[ "$GOTO_SHA256" = "$EXPECTED_GOTO_SHA256" ] || fail "THEOREM_GOTO_HASH_MISMATCH"
[ "$COMPRESS_SHA256" = "$EXPECTED_COMPRESS_SHA256" ] || fail "COMPRESS_SOURCE_HASH_MISMATCH"
[ -z "$(git -C "$AUTH" status --porcelain=v1)" ] || fail "AUTHORITATIVE_TREE_DIRTY"

if git -C "$WT" diff --quiet -- \
  mlkem/src/compress.c \
  mlkem/src/compress.h \
  mlkem/src/params.h
then
  echo "ORIGINAL_WORKTREE_PRODUCTION_SOURCE_MODIFIED=NO"
else
  fail "ORIGINAL_WORKTREE_PRODUCTION_SOURCE_MODIFIED"
fi

echo "IMMUTABLE_ARTIFACT_BINDING=PASS"

echo
echo "============================================================"
echo "PART 3 — ORIGINAL THEOREM REPLAY"
echo "============================================================"

run_cbmc_xml \
  "baseline_replay" \
  "$THEOREM_GOTO" \
  300 \
  --property harness.assertion.1 \
  --property harness.assertion.2

BASELINE_REPLAY_SUMMARY="$RUN/baseline_replay/summary.txt"
BASELINE_REPLAY_EXIT="$(cat "$RUN/baseline_replay/exit.txt" 2>/dev/null || true)"

[ "$BASELINE_REPLAY_EXIT" = "0" ] || fail "BASELINE_REPLAY_EXIT"
[ "$(read_value "$BASELINE_REPLAY_SUMMARY" CPROVER_STATUS)" = "SUCCESS" ] \
  || fail "BASELINE_REPLAY_CPROVER_STATUS"
[ "$(read_value "$BASELINE_REPLAY_SUMMARY" PROPERTY_COUNT)" = "2" ] \
  || fail "BASELINE_REPLAY_PROPERTY_COUNT"
[ "$(read_value "$BASELINE_REPLAY_SUMMARY" SUCCESS_COUNT)" = "2" ] \
  || fail "BASELINE_REPLAY_SUCCESS_COUNT"
[ "$(read_value "$BASELINE_REPLAY_SUMMARY" NON_SUCCESS_COUNT)" = "0" ] \
  || fail "BASELINE_REPLAY_NON_SUCCESS_COUNT"
[ "$(read_value "$BASELINE_REPLAY_SUMMARY" H1_STATUS)" = "SUCCESS" ] \
  || fail "BASELINE_REPLAY_P1"
[ "$(read_value "$BASELINE_REPLAY_SUMMARY" H2_STATUS)" = "SUCCESS" ] \
  || fail "BASELINE_REPLAY_P2"

echo "ORIGINAL_THEOREM_REPLAY=PASS"

echo
echo "============================================================"
echo "PART 4 — RAW-DOMAIN BOUNDARY REACHABILITY CONTROL"
echo "============================================================"

[ ! -e "$BOUNDARY_PROOF" ] || fail "BOUNDARY_PROOF_DIRECTORY_ALREADY_EXISTS"
mkdir -p "$BOUNDARY_PROOF"
cp "$THEOREM_MAKEFILE" "$BOUNDARY_MAKEFILE"

patch_proof_makefile \
  "$BOUNDARY_MAKEFILE" \
  "pfb_t1_exact_raw_decode_harness" \
  "pfb_t1_boundaries_harness" \
  "pfb_t1_exact_raw_decode" \
  "pfb_t1_boundaries"

cat > "$BOUNDARY_HARNESS" <<'EOF_BOUNDARY'
#include <stddef.h>
#include <stdint.h>

#include "compress.h"

/*
 * PFB-T1 raw-domain boundary reachability.
 *
 * For an arbitrary valid block index, this control reaches both endpoint
 * decoded pairs: (0,0) and (4095,4095). Other input bytes remain arbitrary.
 */
void harness(void)
{
  uint8_t low_input[MLKEM_POLYBYTES];
  uint8_t high_input[MLKEM_POLYBYTES];
  mlk_poly low_output;
  mlk_poly high_output;
  size_t block_index;

  __CPROVER_assume(block_index < (MLKEM_N / 2u));

  low_input[3u * block_index + 0u] = UINT8_C(0);
  low_input[3u * block_index + 1u] = UINT8_C(0);
  low_input[3u * block_index + 2u] = UINT8_C(0);

  high_input[3u * block_index + 0u] = UINT8_C(255);
  high_input[3u * block_index + 1u] = UINT8_C(255);
  high_input[3u * block_index + 2u] = UINT8_C(255);

  mlk_poly_frombytes(&low_output, low_input);
  mlk_poly_frombytes(&high_output, high_input);

  __CPROVER_assert(
      low_output.coeffs[2u * block_index] == 0,
      "PFB-B1 raw even lower endpoint is reachable");

  __CPROVER_assert(
      low_output.coeffs[2u * block_index + 1u] == 0,
      "PFB-B2 raw odd lower endpoint is reachable");

  __CPROVER_assert(
      high_output.coeffs[2u * block_index] == 4095,
      "PFB-B3 raw even upper endpoint is reachable");

  __CPROVER_assert(
      high_output.coeffs[2u * block_index + 1u] == 4095,
      "PFB-B4 raw odd upper endpoint is reachable");
}
EOF_BOUNDARY

echo "BOUNDARY_HARNESS_SHA256=$(sha256sum "$BOUNDARY_HARNESS" | awk '{print $1}')"
echo "BOUNDARY_MAKEFILE_SHA256=$(sha256sum "$BOUNDARY_MAKEFILE" | awk '{print $1}')"
echo "BOUNDARY_PUBLIC_CALL_COUNT=$(grep -c 'mlk_poly_frombytes(' "$BOUNDARY_HARNESS" || true)"
echo "BOUNDARY_ASSERTION_COUNT=$(grep -c '__CPROVER_assert' "$BOUNDARY_HARNESS" || true)"
echo "BOUNDARY_ASSUME_COUNT=$(grep -c '__CPROVER_assume' "$BOUNDARY_HARNESS" || true)"

[ "$(grep -c 'mlk_poly_frombytes(' "$BOUNDARY_HARNESS" || true)" = "2" ] \
  || fail "BOUNDARY_PUBLIC_CALL_COUNT"
[ "$(grep -c '__CPROVER_assert' "$BOUNDARY_HARNESS" || true)" = "4" ] \
  || fail "BOUNDARY_ASSERTION_COUNT"
[ "$(grep -c '__CPROVER_assume' "$BOUNDARY_HARNESS" || true)" = "1" ] \
  || fail "BOUNDARY_ASSUME_COUNT"

build_goto "$BOUNDARY_PROOF" "$BOUNDARY_GOTO" "boundary"

run_cbmc_xml \
  "boundary" \
  "$BOUNDARY_GOTO" \
  600

BOUNDARY_SUMMARY="$RUN/boundary/summary.txt"
BOUNDARY_EXIT="$(cat "$RUN/boundary/exit.txt" 2>/dev/null || true)"

[ "$BOUNDARY_EXIT" = "0" ] || fail "BOUNDARY_CBMC_EXIT"
[ "$(read_value "$BOUNDARY_SUMMARY" CPROVER_STATUS)" = "SUCCESS" ] \
  || fail "BOUNDARY_CPROVER_STATUS"
[ "$(read_value "$BOUNDARY_SUMMARY" NON_SUCCESS_COUNT)" = "0" ] \
  || fail "BOUNDARY_NON_SUCCESS_COUNT"
[ "$(read_value "$BOUNDARY_SUMMARY" ERROR_COUNT)" = "0" ] \
  || fail "BOUNDARY_ERROR_COUNT"
[ "$(read_value "$BOUNDARY_SUMMARY" UNKNOWN_COUNT)" = "0" ] \
  || fail "BOUNDARY_UNKNOWN_COUNT"

for number in 1 2 3 4
 do
  [ "$(read_value "$BOUNDARY_SUMMARY" "H${number}_STATUS")" = "SUCCESS" ] \
    || fail "BOUNDARY_ASSERTION_${number}"
 done

echo "PFB_T1_BOUNDARY_REACHABILITY=PASS"

echo
echo "============================================================"
echo "PART 5 — TARGETED SOURCE-MUTATION SENSITIVITY"
echo "============================================================"

prepare_mutant \
  "even" \
  "$MUT_E_WT" \
  "even_shift_8_to_7" \
  "FAILURE" \
  "SUCCESS"

prepare_mutant \
  "odd" \
  "$MUT_O_WT" \
  "odd_shift_4_to_3" \
  "SUCCESS" \
  "FAILURE"

echo "PFB_T1_EVEN_MUTANT_KILLED=YES"
echo "PFB_T1_ODD_MUTANT_KILLED=YES"
echo "PFB_T1_MUTATION_SENSITIVITY=PASS"

echo
echo "============================================================"
echo "PART 6 — POST-MUTATION INTEGRITY"
echo "============================================================"

POST_HARNESS_SHA256="$(sha256sum "$THEOREM_HARNESS" | awk '{print $1}')"
POST_MAKEFILE_SHA256="$(sha256sum "$THEOREM_MAKEFILE" | awk '{print $1}')"
POST_GOTO_SHA256="$(sha256sum "$THEOREM_GOTO" | awk '{print $1}')"
POST_COMPRESS_SHA256="$(sha256sum "$WT/mlkem/src/compress.c" | awk '{print $1}')"

echo "THEOREM_HARNESS_SHA256_AFTER=$POST_HARNESS_SHA256"
echo "THEOREM_MAKEFILE_SHA256_AFTER=$POST_MAKEFILE_SHA256"
echo "THEOREM_GOTO_SHA256_AFTER=$POST_GOTO_SHA256"
echo "ORIGINAL_COMPRESS_SOURCE_SHA256_AFTER=$POST_COMPRESS_SHA256"

[ "$POST_HARNESS_SHA256" = "$EXPECTED_HARNESS_SHA256" ] \
  || fail "POST_THEOREM_HARNESS_HASH_MISMATCH"
[ "$POST_MAKEFILE_SHA256" = "$EXPECTED_MAKEFILE_SHA256" ] \
  || fail "POST_THEOREM_MAKEFILE_HASH_MISMATCH"
[ "$POST_GOTO_SHA256" = "$EXPECTED_GOTO_SHA256" ] \
  || fail "POST_THEOREM_GOTO_HASH_MISMATCH"
[ "$POST_COMPRESS_SHA256" = "$EXPECTED_COMPRESS_SHA256" ] \
  || fail "POST_ORIGINAL_COMPRESS_HASH_MISMATCH"

if git -C "$WT" diff --quiet -- \
  mlkem/src/compress.c \
  mlkem/src/compress.h \
  mlkem/src/params.h
then
  echo "ORIGINAL_WORKTREE_PRODUCTION_SOURCE_MODIFIED=NO"
else
  fail "ORIGINAL_WORKTREE_PRODUCTION_SOURCE_MODIFIED_AFTER_MUTANTS"
fi

[ -z "$(git -C "$AUTH" status --porcelain=v1)" ] \
  || fail "AUTHORITATIVE_TREE_DIRTY_AFTER_MUTANTS"

echo "AUTHORITATIVE_TREE_CLEAN_AFTER_MUTANTS=YES"
echo "THEOREM_ARTIFACTS_UNCHANGED=YES"
echo "MUTATIONS_ISOLATED_TO_DETACHED_WORKTREES=YES"

echo
echo "============================================================"
echo "PART 7 — FINAL T1 ACCEPTANCE AND EVIDENCE FREEZE"
echo "============================================================"

[ ! -e "$FINAL_FREEZE" ] || fail "FINAL_FREEZE_DIRECTORY_ALREADY_EXISTS"
[ ! -e "$ARCHIVE" ] || fail "FINAL_ARCHIVE_ALREADY_EXISTS"

{
  echo "PFB_STAGE=PFB-01M-GATE"
  echo "RUNNER_STATUS=ALL_ACCEPTANCE_GATES_PASSED"
  echo "SOURCE_COMMIT=$EXPECTED_COMMIT"
  echo "SOURCE_TREE=$EXPECTED_TREE"
  echo "PRIOR_EVIDENCE_FAIL_CLOSED_REBINDING=PASS"
  echo "IMMUTABLE_ARTIFACT_BINDING=PASS"
  echo "ORIGINAL_THEOREM_REPLAY=PASS"
  echo "PFB_T1_BOUNDARY_REACHABILITY=PASS"
  echo "PFB_T1_EVEN_MUTANT_KILLED=YES"
  echo "PFB_T1_ODD_MUTANT_KILLED=YES"
  echo "PFB_T1_MUTATION_SENSITIVITY=PASS"
  echo "THEOREM_ARTIFACTS_UNCHANGED=YES"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "AUTHORITATIVE_TREE_CLEAN=YES"
  echo "PFB_T1_FINAL_ACCEPTANCE=YES"
} > "$RUN/PFB_01M_GATE_RESULT.txt"

mkdir -p "$FINAL_FREEZE"/{input_evidence,theorem_artifacts,boundary_artifacts,mutation_evidence,source_binding}

cp -a "$FREEZE_00C" "$FINAL_FREEZE/input_evidence/PFB_00C"
cp -a "$BASELINE_01S" "$FINAL_FREEZE/input_evidence/PFB_01S"
cp -a "$CONTROL_01C" "$FINAL_FREEZE/input_evidence/PFB_01C"
cp -a "$RUN" "$FINAL_FREEZE/input_evidence/PFB_01M"

cp "$THEOREM_HARNESS" "$FINAL_FREEZE/theorem_artifacts/"
cp "$THEOREM_MAKEFILE" "$FINAL_FREEZE/theorem_artifacts/Makefile"
cp "$THEOREM_GOTO" "$FINAL_FREEZE/theorem_artifacts/"

cp "$BOUNDARY_HARNESS" "$FINAL_FREEZE/boundary_artifacts/"
cp "$BOUNDARY_MAKEFILE" "$FINAL_FREEZE/boundary_artifacts/Makefile"
cp "$BOUNDARY_GOTO" "$FINAL_FREEZE/boundary_artifacts/"

cp "$RUN/mutants/even/compress_mutation.diff" \
  "$FINAL_FREEZE/mutation_evidence/even_mutation.diff"
cp "$RUN/mutants/even/result.xml" \
  "$FINAL_FREEZE/mutation_evidence/even_result.xml"
cp "$RUN/mutants/even/summary.txt" \
  "$FINAL_FREEZE/mutation_evidence/even_summary.txt"
cp "$RUN/mutants/even/command.txt" \
  "$FINAL_FREEZE/mutation_evidence/even_command.txt"

cp "$RUN/mutants/odd/compress_mutation.diff" \
  "$FINAL_FREEZE/mutation_evidence/odd_mutation.diff"
cp "$RUN/mutants/odd/result.xml" \
  "$FINAL_FREEZE/mutation_evidence/odd_result.xml"
cp "$RUN/mutants/odd/summary.txt" \
  "$FINAL_FREEZE/mutation_evidence/odd_summary.txt"
cp "$RUN/mutants/odd/command.txt" \
  "$FINAL_FREEZE/mutation_evidence/odd_command.txt"

{
  echo "SCHEMA=PFB-T1-final-source-binding-v1"
  echo "FROZEN_AT_UTC=$STAMP"
  echo "SOURCE_COMMIT=$EXPECTED_COMMIT"
  echo "SOURCE_TREE=$EXPECTED_TREE"
  echo "AUTHORITATIVE_REPOSITORY=$AUTH"
  echo "THEOREM_WORKTREE=$WT"
  echo "THEOREM_HARNESS_SHA256=$EXPECTED_HARNESS_SHA256"
  echo "THEOREM_MAKEFILE_SHA256=$EXPECTED_MAKEFILE_SHA256"
  echo "THEOREM_GOTO_SHA256=$EXPECTED_GOTO_SHA256"
  echo "COMPRESS_SOURCE_SHA256=$EXPECTED_COMPRESS_SHA256"
  echo "MUTANT_EVEN_WORKTREE=$MUT_E_WT"
  echo "MUTANT_ODD_WORKTREE=$MUT_O_WT"
} > "$FINAL_FREEZE/source_binding/SOURCE_IDENTITY.txt"

{
  echo "PFB_STAGE=PFB-T1-FINAL"
  echo "PFB_T1_FINAL_ACCEPTANCE=YES"
  echo "FROZEN_AT_UTC=$STAMP"
  echo "SOURCE_COMMIT=$EXPECTED_COMMIT"
  echo "SOURCE_TREE=$EXPECTED_TREE"
  echo "INITIAL_CONFIGURATION=portable ML-KEM-768"
  echo "PUBLIC_TARGET=mlk_poly_frombytes"
  echo "PORTABLE_BODY=mlk_poly_frombytes_c"
  echo "PFB_T1_P1_EXACT_EVEN_RAW_DECODING=PROVED"
  echo "PFB_T1_P2_EXACT_ODD_RAW_DECODING=PROVED"
  echo "COMPLETE_PROPERTY_SET=113_OF_113_SUCCESS"
  echo "UNWINDING_ASSERTIONS=ENABLED_AND_COMPLETE_RUN_SUCCESSFUL"
  echo "INPUT_FRAME_CONTROL=PASS"
  echo "OUTPUT_CANARY_CONTROL=PASS"
  echo "COMPLETE_OVERWRITE_CONTROL=PASS"
  echo "NONCONSTANT_OUTPUT_CONTROL=PASS"
  echo "RAW_BOUNDARY_0_AND_4095_REACHABILITY=PASS"
  echo "EVEN_DECODER_MUTANT_KILLED=YES"
  echo "ODD_DECODER_MUTANT_KILLED=YES"
  echo "MUTATION_SENSITIVITY=PASS"
  echo "FUNCTION_CONTRACT_SUBSTITUTION=NO"
  echo "LOOP_CONTRACT_APPLICATION=NO"
  echo "NATIVE_BACKEND_CLAIM=EXCLUDED"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "AUTHORITATIVE_TREE_CLEAN=YES"
  echo "MATHEMATICAL_WORLD_FIRST_CLAIM=NO"
  echo "ALLOWED_CLAIM=At commit af4c5abd, the portable public mlk_poly_frombytes path was verified by CBMC for the two frozen PFB-T1 exact raw-decoding obligations over arbitrary input bytes and an arbitrary valid block index, under the recorded machine model and proof configuration."
  echo "FINAL_FREEZE_DIRECTORY=$FINAL_FREEZE"
  echo "TERMINAL_OUTPUT=$OUT"
} > "$FINAL_FREEZE/PFB_T1_FINAL_ACCEPTANCE_REPORT.txt"

(
  cd "$FINAL_FREEZE" || exit 1
  find . \
    -type f \
    ! -name SHA256SUMS.txt \
    -print0 \
  | sort -z \
  | xargs -0 sha256sum \
    > SHA256SUMS.txt
) || fail "FINAL_FREEZE_HASH_MANIFEST_FAILED"

FINAL_MANIFEST_SHA256="$(
  sha256sum "$FINAL_FREEZE/SHA256SUMS.txt" | awk '{print $1}'
)"

(
  cd "$CAMPAIGN" || exit 1
  tar \
    --sort=name \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    --mtime='UTC 2026-07-29 00:00:00' \
    -cf - \
    "$(basename "$FINAL_FREEZE")" \
  | gzip -n > "$ARCHIVE"
) || fail "FINAL_ARCHIVE_CREATION_FAILED"

ARCHIVE_SHA256="$(sha256sum "$ARCHIVE" | awk '{print $1}')"

{
  echo "PFB_STAGE=PFB-01M"
  echo "RUNNER_STATUS=COMPLETE"
  echo "SOURCE_COMMIT=$EXPECTED_COMMIT"
  echo "SOURCE_TREE=$EXPECTED_TREE"
  echo "PRIOR_EVIDENCE_FAIL_CLOSED_REBINDING=PASS"
  echo "IMMUTABLE_ARTIFACT_BINDING=PASS"
  echo "ORIGINAL_THEOREM_REPLAY=PASS"
  echo "PFB_T1_BOUNDARY_REACHABILITY=PASS"
  echo "PFB_T1_EVEN_MUTANT_KILLED=YES"
  echo "PFB_T1_ODD_MUTANT_KILLED=YES"
  echo "PFB_T1_MUTATION_SENSITIVITY=PASS"
  echo "THEOREM_ARTIFACTS_UNCHANGED=YES"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "AUTHORITATIVE_TREE_CLEAN=YES"
  echo "PFB_T1_FINAL_ACCEPTANCE=YES"
  echo "FINAL_FREEZE_DIRECTORY=$FINAL_FREEZE"
  echo "FINAL_MANIFEST_SHA256=$FINAL_MANIFEST_SHA256"
  echo "FINAL_ARCHIVE=$ARCHIVE"
  echo "FINAL_ARCHIVE_SHA256=$ARCHIVE_SHA256"
  echo "TERMINAL_OUTPUT=$OUT"
} > "$RUN/PFB_01M_RESULT.txt"

echo "PFB_T1_FINAL_ACCEPTANCE_REPORT_BEGIN"
cat "$FINAL_FREEZE/PFB_T1_FINAL_ACCEPTANCE_REPORT.txt"
echo "PFB_T1_FINAL_ACCEPTANCE_REPORT_END"

echo "FINAL_MANIFEST_SHA256=$FINAL_MANIFEST_SHA256"
echo "FINAL_ARCHIVE=$ARCHIVE"
echo "FINAL_ARCHIVE_SHA256=$ARCHIVE_SHA256"

echo
echo "============================================================"
echo "PFB-01M COMPLETE"
echo "PFB-T1 FINAL ACCEPTANCE=YES"
echo "RAW ENDPOINT BOUNDARIES PROVED"
echo "EVEN AND ODD TARGETED MUTANTS KILLED"
echo "FAIL-CLOSED EVIDENCE FREEZE CREATED"
echo "NO THEOREM ARTIFACT MODIFIED"
echo "NO AUTHORITATIVE PRODUCTION SOURCE MODIFIED"
echo "SCRIPT_FINAL_EXIT=0"
echo "============================================================"

exit 0
