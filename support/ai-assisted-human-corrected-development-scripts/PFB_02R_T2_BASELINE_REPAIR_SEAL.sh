#!/usr/bin/env bash
#
# PFB-02R — Repair/seal the already completed PFB-02A CBMC baseline.
#
# The original PFB-02A runner completed all four authoritative CBMC runs,
# but its XML parser only registered expected property IDs when --property
# arguments were supplied. The two unfiltered runs therefore had empty
# per-assertion fields even though their XML files recorded complete success.
#
# This script does not rebuild or rerun CBMC. It reparses the existing XML
# directly, rebinds immutable artifacts, and emits a fail-closed corrected
# baseline result.

set -uo pipefail
umask 022

ROOT="$HOME/THESIS-2026"
AUTH="$ROOT/mlkem-native_af4c5abd"
WT="$ROOT/_cbmc_work/mlkem-native_pfb_af4c5abd"

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_TREE="54805daff6a91a010c05467ea678117c42a71559"
EXPECTED_COMPRESS_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"

EXPECTED_T1_HARNESS_SHA256="9a3288855782f7aee718d51c7904608763bd480635a63d25cd05956d408007a8"
EXPECTED_T1_MAKEFILE_SHA256="9e56741090a6634baddbe2ea9fe13637bbeed9a1ce62f93e2f228185cfe41526"
EXPECTED_T1_GOTO_SHA256="13dd5ba4e64b4dd3c54a3d4e7c82ec0e3c1b09a397584cfa1a13309f60ceeb83"

EXPECTED_BIT_HARNESS_SHA256="7cd0a8e512283677d3a191e0a714bca7f0b481600b3905ef4f3759ab4b1f9aff"
EXPECTED_BIT_MAKEFILE_SHA256="52c8a9b74ed60073766822d0ace381d6bf0b61c0e0da596e488e86122d982ad0"
EXPECTED_BIT_GOTO_SHA256="7e379a693c5c4050751e2f4f7ee695a812016bc20be03fe042818c37713fb7ef"

EXPECTED_LOCAL_HARNESS_SHA256="b52a5e2eefe10204563539c38cc9332d7571ca99ec785c887b3c407488120dfd"
EXPECTED_LOCAL_MAKEFILE_SHA256="bc967aa5116b4c81c6abb192ac7f1d736e682f0bd21d8f83bf6300287482afc6"
EXPECTED_LOCAL_GOTO_SHA256="4e0b7038eadd97d8c4efac19cb0d090f00cd8349cae1b6b98f19b538486c74fe"

T1_PROOF="$WT/proofs/cbmc/pfb_t1_exact_raw_decode"
BIT_PROOF="$WT/proofs/cbmc/pfb_t2_bit_routes"
LOCAL_PROOF="$WT/proofs/cbmc/pfb_t2_block_locality"

RUN="$(
  find "$ROOT/mlk_poly_frombytes_cleanroom" \
    -maxdepth 1 \
    -type d \
    -name 'PFB_02A_T2_SEMANTIC_BASELINE_*' \
    -printf '%T@ %p\n' |
  sort -nr |
  head -n 1 |
  cut -d' ' -f2-
)"

OUT="/tmp/PFB_02R_T2_BASELINE_REPAIR_SEAL.txt"

fail()
{
  echo "FATAL_FAILURE=$1"
  echo "PFB_T2_SEMANTIC_BASELINE=NO"
  echo "SCRIPT_FINAL_EXIT=1"
  exit 1
}

[ -n "$RUN" ] || fail "PFB_02A_RUN_DIRECTORY_NOT_FOUND"
[ -d "$RUN" ] || fail "PFB_02A_RUN_DIRECTORY_INVALID"

exec > >(tee "$OUT") 2>&1

echo "============================================================"
echo "PFB-02R — T2 BASELINE PARSER REPAIR AND FAIL-CLOSED SEAL"
echo "============================================================"
echo "STARTED_AT_UTC=$(date -u +%Y%m%dT%H%M%SZ)"
echo "SOURCE_RUN_DIRECTORY=$RUN"
echo "TERMINAL_OUTPUT=$OUT"

echo
echo "============================================================"
echo "PART 1 — EXPLAIN AND BIND THE REPAIR"
echo "============================================================"
echo "ORIGINAL_FAILURE_CLASS=EVIDENCE_PARSER_ONLY"
echo "ORIGINAL_CBMC_THEOREM_RUNS_COMPLETED=YES"
echo "ORIGINAL_CBMC_COMPLETE_RUNS_COMPLETED=YES"
echo "REBUILD_PERFORMED=NO"
echo "CBMC_RERUN_PERFORMED=NO"

echo
echo "============================================================"
echo "PART 2 — IMMUTABLE SOURCE AND ARTIFACT RE-BINDING"
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

bind_hash \
  "COMPRESS_SOURCE" \
  "$WT/mlkem/src/compress.c" \
  "$EXPECTED_COMPRESS_SHA256"

bind_hash \
  "T1_HARNESS" \
  "$T1_PROOF/pfb_t1_exact_raw_decode_harness.c" \
  "$EXPECTED_T1_HARNESS_SHA256"
bind_hash \
  "T1_MAKEFILE" \
  "$T1_PROOF/Makefile" \
  "$EXPECTED_T1_MAKEFILE_SHA256"
bind_hash \
  "T1_GOTO" \
  "$T1_PROOF/gotos/pfb_t1_exact_raw_decode_harness.goto" \
  "$EXPECTED_T1_GOTO_SHA256"

bind_hash \
  "BIT_HARNESS" \
  "$BIT_PROOF/pfb_t2_bit_routes_harness.c" \
  "$EXPECTED_BIT_HARNESS_SHA256"
bind_hash \
  "BIT_MAKEFILE" \
  "$BIT_PROOF/Makefile" \
  "$EXPECTED_BIT_MAKEFILE_SHA256"
bind_hash \
  "BIT_GOTO" \
  "$BIT_PROOF/gotos/pfb_t2_bit_routes_harness.goto" \
  "$EXPECTED_BIT_GOTO_SHA256"

bind_hash \
  "LOCAL_HARNESS" \
  "$LOCAL_PROOF/pfb_t2_block_locality_harness.c" \
  "$EXPECTED_LOCAL_HARNESS_SHA256"
bind_hash \
  "LOCAL_MAKEFILE" \
  "$LOCAL_PROOF/Makefile" \
  "$EXPECTED_LOCAL_MAKEFILE_SHA256"
bind_hash \
  "LOCAL_GOTO" \
  "$LOCAL_PROOF/gotos/pfb_t2_block_locality_harness.goto" \
  "$EXPECTED_LOCAL_GOTO_SHA256"

echo "IMMUTABLE_ARTIFACT_BINDING=PASS"

echo
echo "============================================================"
echo "PART 3 — DIRECT XML REPARSE"
echo "============================================================"

python3 - "$RUN" <<'PY'
from __future__ import annotations

import sys
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

run = Path(sys.argv[1])

specs = {
    "bit_routes_theorem": {
        "expected_count": 4,
        "expected_properties": [
            "harness.assertion.1",
            "harness.assertion.2",
            "harness.assertion.3",
            "harness.assertion.4",
        ],
    },
    "bit_routes_all": {
        "expected_count": 170,
        "expected_properties": [
            "harness.assertion.1",
            "harness.assertion.2",
            "harness.assertion.3",
            "harness.assertion.4",
        ],
    },
    "block_locality_theorem": {
        "expected_count": 1,
        "expected_properties": [
            "harness.assertion.1",
        ],
    },
    "block_locality_all": {
        "expected_count": 102,
        "expected_properties": [
            "harness.assertion.1",
        ],
    },
}


def local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


overall_pass = True
summary_lines: list[str] = []

for name, spec in specs.items():
    xml_path = run / "results" / f"{name}.xml"
    exit_path = run / "results" / f"{name}.exit.txt"

    if not xml_path.is_file():
        print(f"XML_PRESENT[{name}]=NO")
        overall_pass = False
        continue

    if not exit_path.is_file():
        print(f"EXIT_FILE_PRESENT[{name}]=NO")
        overall_pass = False
        continue

    exit_code = exit_path.read_text(encoding="utf-8").strip()
    print(f"CBMC_EXIT[{name}]={exit_code}")
    if exit_code != "0":
        overall_pass = False

    try:
        root = ET.parse(xml_path).getroot()
    except Exception as exc:
        print(f"XML_PARSE[{name}]=FAIL")
        print(f"XML_PARSE_EXCEPTION[{name}]={exc!r}")
        overall_pass = False
        continue

    print(f"XML_PARSE[{name}]=PASS")

    results = [
        element
        for element in root.iter()
        if local_name(element.tag) == "result"
    ]
    counts = Counter(
        element.attrib.get("status", "MISSING")
        for element in results
    )

    statuses = {
        element.attrib.get("property", ""):
            element.attrib.get("status", "MISSING")
        for element in results
    }

    cprover_statuses = [
        " ".join((element.text or "").split())
        for element in root.iter()
        if local_name(element.tag) == "cprover-status"
    ]
    cprover_status = "|".join(cprover_statuses) if cprover_statuses else "NONE"

    property_count = len(results)
    success_count = counts.get("SUCCESS", 0)
    non_success_count = sum(
        1
        for element in results
        if element.attrib.get("status") != "SUCCESS"
    )

    print(f"CPROVER_STATUS[{name}]={cprover_status}")
    print(f"PROPERTY_COUNT[{name}]={property_count}")
    print(f"SUCCESS_COUNT[{name}]={success_count}")
    print(f"NON_SUCCESS_COUNT[{name}]={non_success_count}")

    if cprover_status != "SUCCESS":
        overall_pass = False
    if property_count != spec["expected_count"]:
        overall_pass = False
    if success_count != property_count:
        overall_pass = False
    if non_success_count != 0:
        overall_pass = False

    for property_id in spec["expected_properties"]:
        status = statuses.get(property_id, "ABSENT")
        print(f"STATUS[{name}][{property_id}]={status}")
        if status != "SUCCESS":
            overall_pass = False

    summary_lines.extend(
        [
            f"{name}.CBMC_EXIT={exit_code}",
            f"{name}.CPROVER_STATUS={cprover_status}",
            f"{name}.PROPERTY_COUNT={property_count}",
            f"{name}.SUCCESS_COUNT={success_count}",
            f"{name}.NON_SUCCESS_COUNT={non_success_count}",
        ]
    )

(run / "PFB_02R_XML_REPARSE_SUMMARY.txt").write_text(
    "\n".join(summary_lines) + "\n",
    encoding="utf-8",
)

print(
    "PFB_02R_XML_REPARSE="
    + ("PASS" if overall_pass else "FAIL")
)

if not overall_pass:
    raise SystemExit(1)
PY

REPARSE_EXIT=$?
[ "$REPARSE_EXIT" = "0" ] || fail "XML_REPARSE_FAILED"

echo
echo "============================================================"
echo "PART 4 — GOTO CALL-CHAIN RECHECK"
echo "============================================================"

goto-instrument \
  --show-goto-functions \
  "$BIT_PROOF/gotos/pfb_t2_bit_routes_harness.goto" \
  > "$RUN/binding/PFB_02R_bit_routes.goto_functions.txt" \
  2> "$RUN/binding/PFB_02R_bit_routes.goto_functions.stderr.txt" ||
  fail "BIT_GOTO_DUMP_FAILED"

goto-instrument \
  --show-goto-functions \
  "$LOCAL_PROOF/gotos/pfb_t2_block_locality_harness.goto" \
  > "$RUN/binding/PFB_02R_block_locality.goto_functions.txt" \
  2> "$RUN/binding/PFB_02R_block_locality.goto_functions.stderr.txt" ||
  fail "LOCAL_GOTO_DUMP_FAILED"

BIT_PUBLIC_CALLS="$(
  grep -c 'CALL mlk_poly_frombytes(' \
    "$RUN/binding/PFB_02R_bit_routes.goto_functions.txt" || true
)"
BIT_PORTABLE_CALLS="$(
  grep -c 'CALL mlk_poly_frombytes_c(' \
    "$RUN/binding/PFB_02R_bit_routes.goto_functions.txt" || true
)"
LOCAL_PUBLIC_CALLS="$(
  grep -c 'CALL mlk_poly_frombytes(' \
    "$RUN/binding/PFB_02R_block_locality.goto_functions.txt" || true
)"
LOCAL_PORTABLE_CALLS="$(
  grep -c 'CALL mlk_poly_frombytes_c(' \
    "$RUN/binding/PFB_02R_block_locality.goto_functions.txt" || true
)"

echo "BIT_GOTO_PUBLIC_WRAPPER_CALL_COUNT=$BIT_PUBLIC_CALLS"
echo "BIT_GOTO_PORTABLE_BODY_CALL_COUNT=$BIT_PORTABLE_CALLS"
echo "LOCAL_GOTO_PUBLIC_WRAPPER_CALL_COUNT=$LOCAL_PUBLIC_CALLS"
echo "LOCAL_GOTO_PORTABLE_BODY_CALL_COUNT=$LOCAL_PORTABLE_CALLS"

[ "$BIT_PUBLIC_CALLS" -ge 1 ] || fail "BIT_PUBLIC_WRAPPER_CALL_ABSENT"
[ "$BIT_PORTABLE_CALLS" -ge 1 ] || fail "BIT_PORTABLE_BODY_CALL_ABSENT"
[ "$LOCAL_PUBLIC_CALLS" -ge 1 ] || fail "LOCAL_PUBLIC_WRAPPER_CALL_ABSENT"
[ "$LOCAL_PORTABLE_CALLS" -ge 1 ] || fail "LOCAL_PORTABLE_BODY_CALL_ABSENT"

if grep -Eq \
  'mlk_poly_frombytes_native|MLK_USE_NATIVE_POLY_FROMBYTES' \
  "$RUN/binding/PFB_02R_bit_routes.goto_functions.txt" \
  "$RUN/binding/PFB_02R_block_locality.goto_functions.txt"
then
  fail "NATIVE_FROMBYTES_PRESENT"
fi

echo "GOTO_CALL_CHAIN_RECHECK=PASS"

echo
echo "============================================================"
echo "PART 5 — POST-REPAIR INTEGRITY AND CORRECTED RESULT"
echo "============================================================"

[ "$(sha256sum "$WT/mlkem/src/compress.c" | awk '{print $1}')" = \
  "$EXPECTED_COMPRESS_SHA256" ] ||
  fail "PRODUCTION_SOURCE_CHANGED"

[ "$(sha256sum "$T1_PROOF/pfb_t1_exact_raw_decode_harness.c" | awk '{print $1}')" = \
  "$EXPECTED_T1_HARNESS_SHA256" ] ||
  fail "T1_HARNESS_CHANGED"

[ "$(sha256sum "$T1_PROOF/Makefile" | awk '{print $1}')" = \
  "$EXPECTED_T1_MAKEFILE_SHA256" ] ||
  fail "T1_MAKEFILE_CHANGED"

[ "$(sha256sum "$T1_PROOF/gotos/pfb_t1_exact_raw_decode_harness.goto" | awk '{print $1}')" = \
  "$EXPECTED_T1_GOTO_SHA256" ] ||
  fail "T1_GOTO_CHANGED"

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
  fail "AUTHORITATIVE_TREE_DIRTY_AFTER_REPAIR"

cat > "$RUN/PFB_02R_CORRECTED_RESULT.txt" <<EOF_RESULT
PFB_STAGE=PFB-02R
SOURCE_STAGE=PFB-02A
RUNNER_STATUS=COMPLETE
REPAIR_CLASS=EVIDENCE_PARSER_ONLY
CBMC_RERUN_PERFORMED=NO
SOURCE_COMMIT=$EXPECTED_COMMIT
SOURCE_TREE=$EXPECTED_TREE
INITIAL_CONFIGURATION=portable ML-KEM-768
PFB_T2_P1_STATUS=SUCCESS
PFB_T2_P2_STATUS=SUCCESS
PFB_T2_P3_STATUS=SUCCESS
PFB_T2_P4_STATUS=SUCCESS
PFB_T2_P5_STATUS=SUCCESS
BIT_ROUTES_THEOREM_PROPERTY_COUNT=4
BIT_ROUTES_THEOREM_SUCCESS_COUNT=4
BIT_ROUTES_COMPLETE_PROPERTY_COUNT=170
BIT_ROUTES_COMPLETE_SUCCESS_COUNT=170
BLOCK_LOCALITY_THEOREM_PROPERTY_COUNT=1
BLOCK_LOCALITY_THEOREM_SUCCESS_COUNT=1
BLOCK_LOCALITY_COMPLETE_PROPERTY_COUNT=102
BLOCK_LOCALITY_COMPLETE_SUCCESS_COUNT=102
ALL_NON_SUCCESS_COUNT=0
DEFAULT_SAT_BACKEND=YES
FUNCTION_CONTRACT_SUBSTITUTION=NO
LOOP_CONTRACT_APPLICATION=NO
NATIVE_BACKEND_CLAIM=EXCLUDED
PFB_T1_ARTIFACTS_UNCHANGED=YES
PRODUCTION_SOURCE_MODIFIED=NO
AUTHORITATIVE_TREE_CLEAN=YES
PFB_T2_SEMANTIC_BASELINE=PASS
PFB_T2_FINAL_ACCEPTANCE=NO
NONVACUITY_AND_MUTATION_CONTROLS_PENDING=YES
SOURCE_RUN_DIRECTORY=$RUN
TERMINAL_OUTPUT=$OUT
EOF_RESULT

(
  cd "$RUN" || exit 1
  find . \
    -type f \
    ! -name SHA256SUMS.PFB_02R.txt \
    -print0 |
    sort -z |
    xargs -0 sha256sum \
    > SHA256SUMS.PFB_02R.txt
) || fail "REPAIR_HASH_MANIFEST_FAILED"

echo "PFB_02R_MANIFEST_SHA256=$(
  sha256sum "$RUN/SHA256SUMS.PFB_02R.txt" | awk '{print $1}'
)"

echo
echo "============================================================"
echo "PFB-02R CORRECTED RESULT"
echo "============================================================"
cat "$RUN/PFB_02R_CORRECTED_RESULT.txt"

echo
echo "============================================================"
echo "PFB-02R COMPLETE"
echo "ORIGINAL FAILURE WAS PARSER-ONLY"
echo "ALL FIVE PFB-T2 SEMANTIC OBLIGATIONS PASSED"
echo "BIT-ROUTE COMPLETE SET: 170 OF 170 SUCCESS"
echo "BLOCK-LOCALITY COMPLETE SET: 102 OF 102 SUCCESS"
echo "NO CBMC RERUN REQUIRED"
echo "NO PFB-T1 ARTIFACT MODIFIED"
echo "NO PRODUCTION SOURCE MODIFIED"
echo "PFB-T2 FINAL ACCEPTANCE=NO"
echo "MUTATION AND NONVACUITY CONTROLS PENDING"
echo "SCRIPT_FINAL_EXIT=0"
echo "============================================================"

exit 0
