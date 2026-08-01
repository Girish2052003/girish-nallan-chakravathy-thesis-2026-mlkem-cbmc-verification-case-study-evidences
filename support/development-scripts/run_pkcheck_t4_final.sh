#!/usr/bin/env bash
set -euo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_HARNESS_SHA="4872ed08ac4d6407281f3871bf82ad388d8a88877e30c334398852a24fbc78f9"
EXPECTED_MAKEFILE_SHA="17cd78f14c378f856eb1d03aa83c7e755677d6f9e033683d3d905b56b6c59cbb"

STAGE="$HOME/THESIS-2026/mlk_kem_check_pk_cleanroom/PKCHECK_T2_00A_SEED_FRAME_20260730T031357Z"
SOURCE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
WORKTREE="$STAGE/mlkem-native_af4c5abd_t2"
PROOF="$WORKTREE/proofs/cbmc/pkcheck_t4_guard_dominance"
HARNESS="$PROOF/pkcheck_t4_guard_dominance_harness.c"
MAKEFILE="$PROOF/Makefile"
GOTO="$PROOF/gotos/pkcheck_t4_guard_dominance_harness.goto"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN="$STAGE/PKCHECK_T4_FINAL_${STAMP}"
mkdir -p "$PROOF" "$RUN/shards"

exec > >(tee "$RUN/PKCHECK_T4_FINAL_SUMMARY.txt") 2>&1

echo "============================================================"
echo "PKCHECK-T4 — ENCAPSULATION GUARD DOMINANCE"
echo "============================================================"
echo "RUN_DIR=$RUN"

cat > "$HARNESS" <<'EOF'
#include <cbmc.h>
#include <stddef.h>
#include <stdint.h>

#include "kem.h"
#include "params.h"

static int t4_check_pk_calls;

/*
 * Deliberate lower-function stub for this control-flow theorem.
 * The production mlk_kem_enc_derand body remains concrete.
 */
int mlk_kem_check_pk(const uint8_t pk[MLKEM_INDCCA_PUBLICKEYBYTES],
                     MLK_CONFIG_CONTEXT_PARAMETER_TYPE context)
{
  (void)pk;
  (void)context;
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
    t4_check_pk_calls == 1,
    "PKCHECK-T4.CHECK_EXECUTED: the public-key validation guard is reached exactly once");

  __CPROVER_assert(
    result == MLK_ERR_FAIL,
    "PKCHECK-T4.FAIL_PROPAGATION: validation failure is returned unchanged");

  __CPROVER_assert(
    ct[ct_index] == ct_before,
    "PKCHECK-T4.CIPHERTEXT_FRAME: validation failure preserves every ciphertext-output byte");

  __CPROVER_assert(
    ss[ss_index] == ss_before,
    "PKCHECK-T4.SHARED_SECRET_FRAME: validation failure preserves every shared-secret-output byte");

  __CPROVER_assert(
    pk[pk_index] == pk_before,
    "PKCHECK-T4.PUBLIC_KEY_FRAME: validation failure preserves every public-key byte");

  __CPROVER_assert(
    coins[coins_index] == coins_before,
    "PKCHECK-T4.COINS_FRAME: validation failure preserves every coins byte");
}
EOF

cat > "$MAKEFILE" <<'EOF'
HARNESS_FILE = pkcheck_t4_guard_dominance_harness
HARNESS_ENTRY = harness

PROOF_UID = pkcheck_t4_guard_dominance
PROOF_DESCRIPTION = mlk_kem_enc_derand public-key validation guard dominance

PROJECT = mlkem
MLKEM_K = 3

INCLUDES +=

# Replace only the lower public-key checker with the harness stub.
# The mlk_kem_enc_derand target body remains concrete.
REMOVE_FUNCTION_BODY += mlk_kem_check_pk

UNWINDSET += mlk_kem_enc_derand.0:1
UNWINDSET += mlk_kem_enc_derand.1:1

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/kem.c

USE_FUNCTION_CONTRACTS += mlk_zeroize
APPLY_LOOP_CONTRACTS = on

EXTERNAL_SAT_SOLVER =

include ../Makefile.common
EOF

echo "===== GATE 1 — SOURCE AND ARTEFACT BINDING ====="
test "$(git -C "$SOURCE" rev-parse HEAD)" = "$EXPECTED_COMMIT"
test "$(git -C "$WORKTREE" rev-parse HEAD)" = "$EXPECTED_COMMIT"
test -z "$(git -C "$SOURCE" status --porcelain=v1)"
git -C "$WORKTREE" diff --quiet "$EXPECTED_COMMIT" -- mlkem

HARNESS_SHA="$(sha256sum "$HARNESS" | awk '{print $1}')"
MAKEFILE_SHA="$(sha256sum "$MAKEFILE" | awk '{print $1}')"
echo "HARNESS_SHA=$HARNESS_SHA"
echo "MAKEFILE_SHA=$MAKEFILE_SHA"
test "$HARNESS_SHA" = "$EXPECTED_HARNESS_SHA"
test "$MAKEFILE_SHA" = "$EXPECTED_MAKEFILE_SHA"
echo "EXACT_BINDING=PASS"

echo "===== GATE 2 — PIPELINE POLICY ====="
make -C "$PROOF" -n -B _goto > "$RUN/dry-run.txt" 2>&1

grep -n -- '--remove-function-body mlk_kem_check_pk' "$RUN/dry-run.txt"
grep -n -- '--unwindset mlk_kem_enc_derand.0:1,mlk_kem_enc_derand.1:1' "$RUN/dry-run.txt"

if grep -Fq -- '--replace-call-with-contract mlk_kem_enc_derand' "$RUN/dry-run.txt"; then
  echo "TARGET_REPLACEMENT=YES"
  exit 1
fi
if grep -Fq -- '--replace-call-with-contract mlk_kem_check_pk' "$RUN/dry-run.txt"; then
  echo "CHECK_PK_CONTRACT_REPLACEMENT=YES"
  exit 1
fi
if grep -Fq -- '--dfcc' "$RUN/dry-run.txt"; then
  echo "DFCC_PRESENT=YES"
  exit 1
fi

echo "TARGET_REPLACEMENT=NO"
echo "CHECK_PK_CONTRACT_REPLACEMENT=NO"
echo "DFCC_PRESENT=NO"

echo "===== GATE 3 — BUILD GOTO ONLY ====="
rm -rf "$PROOF/gotos" "$PROOF/logs" "$PROOF/report" \
       "$PROOF/.litani_cache_dir" "$PROOF/.ninja_log"

set +e
timeout 300s make -C "$PROOF" -j1 goto > "$RUN/build.log" 2>&1
BUILD_EXIT=$?
set -e

echo "BUILD_EXIT=$BUILD_EXIT"
tail -n 100 "$RUN/build.log"

if [ "$BUILD_EXIT" -ne 0 ] || [ ! -f "$GOTO" ]; then
  echo "PKCHECK_T4_CLASSIFICATION=MODEL_BUILD_FAILED"
  exit 0
fi

GOTO_SHA="$(sha256sum "$GOTO" | awk '{print $1}')"
echo "GOTO_SHA=$GOTO_SHA"
echo "GOTO_SIZE=$(stat -c '%s' "$GOTO")"

echo "===== GATE 4 — STRUCTURAL AUDIT ====="
goto-instrument --show-loops "$GOTO" > "$RUN/loops.txt" 2>&1
goto-instrument --show-goto-functions "$GOTO" > "$RUN/functions.txt" 2>&1

cat "$RUN/loops.txt"
LOOP_COUNT="$(grep -c '^Loop ' "$RUN/loops.txt" || true)"
TARGET_LOOP_COUNT="$(grep -c '^Loop mlk_kem_enc_derand\.' "$RUN/loops.txt" || true)"
echo "FINAL_LOOP_COUNT=$LOOP_COUNT"
echo "FINAL_TARGET_LOOP_COUNT=$TARGET_LOOP_COUNT"
test "$LOOP_COUNT" -eq 0
test "$TARGET_LOOP_COUNT" -eq 0

grep -Fq 'mlk_kem_enc_derand' "$RUN/functions.txt"
grep -Fq 't4_check_pk_calls' "$RUN/functions.txt"
grep -Fq 'pkcheck_t4_guard_dominance_harness.c' "$RUN/functions.txt"

echo "ACTUAL_TARGET_BODY_PRESENT=YES"
echo "HARNESS_CHECK_PK_STUB_PRESENT=YES"
echo "FINAL_MODEL_LOOP_FREE=YES"

echo "===== GATE 5 — PROPERTY FREEZE ====="
cbmc --show-properties --xml-ui "$GOTO" \
  > "$RUN/property.xml" 2> "$RUN/property.stderr.txt"

python3 - "$RUN/property.xml" "$RUN/properties.tsv" <<'PY'
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

root = ET.parse(Path(sys.argv[1])).getroot()
out = Path(sys.argv[2])


def local(tag):
    return tag.rsplit("}", 1)[-1]


records = []
for element in root.iter():
    prop = (
        element.attrib.get("name")
        or element.attrib.get("property")
        or element.attrib.get("id")
    )
    if not prop:
        continue

    description = ""
    function = ""
    for child in element.iter():
        tag = local(child.tag)
        if tag == "description" and not description:
            description = " ".join(
                text.strip() for text in child.itertext() if text.strip()
            )
        if tag == "location" and not function:
            function = child.attrib.get("function", "")

    mode = None
    if "PKCHECK-T4." in description:
        mode = "custom"
    elif "unwind" in prop and "mlk_kem_enc_derand" in (prop + " " + function):
        mode = "unwind"

    if mode:
        records.append((prop, mode, description, function))

custom = [record for record in records if record[1] == "custom"]
unwind = [record for record in records if record[1] == "unwind"]

print(f"T4_CUSTOM_PROPERTY_COUNT={len(custom)}")
print(f"T4_TARGET_UNWIND_PROPERTY_COUNT={len(unwind)}")

for prop, mode, description, function in records:
    print(
        f"T4_PROPERTY={prop} MODE={mode} "
        f"FUNCTION={function} DESCRIPTION={description}"
    )

if len(custom) != 6:
    raise SystemExit("Expected exactly six T4 custom properties")
if len(unwind) != 2:
    raise SystemExit("Expected exactly two target unwind properties")

with out.open("w") as stream:
    for prop, mode, description, _ in records:
        stream.write(f"{prop}\t{mode}\t{description.replace(chr(9), ' ')}\n")
PY

echo "===== GATE 6 — EIGHT PROPERTY SHARDS ====="
printf 'property\tmode\texit\tstatus\tcprover\tclassification\tmax_rss_kb\tseconds\n' > "$RUN/results.tsv"

while IFS=$'\t' read -r PROPERTY MODE DESCRIPTION; do
  SAFE_NAME="$(printf '%s' "$PROPERTY" | tr -c 'A-Za-z0-9._-' '_')"
  DIR="$RUN/shards/$SAFE_NAME"
  mkdir -p "$DIR"

  FLAGS=(--flush --object-bits 10 --slice-formula --property "$PROPERTY" --xml-ui)
  if [ "$MODE" = "custom" ]; then
    FLAGS+=(--no-standard-checks)
  fi

  echo "PROPERTY=$PROPERTY MODE=$MODE"
  START="$(date +%s)"
  set +e
  /usr/bin/time -v -o "$DIR/time.txt" \
    timeout --signal=TERM --kill-after=20s 180s \
    cbmc "${FLAGS[@]}" "$GOTO" \
    > "$DIR/result.xml" 2> "$DIR/stderr.txt"
  EXIT_CODE=$?
  set -e
  SECONDS_USED=$(($(date +%s) - START))

  python3 - "$DIR/result.xml" "$DIR/time.txt" "$PROPERTY" "$MODE" \
    "$EXIT_CODE" "$SECONDS_USED" "$RUN/results.tsv" <<'PY'
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

result_path = Path(sys.argv[1])
time_path = Path(sys.argv[2])
expected = sys.argv[3]
mode = sys.argv[4]
exit_code = int(sys.argv[5])
seconds = sys.argv[6]
summary_path = Path(sys.argv[7])

status = "NO_RESULT"
cprover = "NONE"
classification = "INCONCLUSIVE"
max_rss = "UNKNOWN"

if time_path.exists():
    match = re.search(
        r"Maximum resident set size \(kbytes\):\s*(\d+)",
        time_path.read_text(errors="replace"),
    )
    if match:
        max_rss = match.group(1)

if exit_code == 124:
    classification = "TIMEOUT"
elif exit_code in {137, 143}:
    classification = "PROCESS_KILLED"
else:
    try:
        root = ET.parse(result_path).getroot()
        results = []
        statuses = []
        for element in root.iter():
            tag = element.tag.rsplit("}", 1)[-1]
            if tag == "result":
                results.append(
                    (
                        element.attrib.get("property", "UNNAMED"),
                        element.attrib.get("status", "UNKNOWN"),
                    )
                )
            elif tag == "cprover-status":
                value = " ".join(
                    text.strip() for text in element.itertext() if text.strip()
                )
                if value:
                    statuses.append(value)

        if results:
            status = results[0][1]
        if statuses:
            cprover = ",".join(statuses)

        if (
            exit_code == 0
            and results == [(expected, "SUCCESS")]
            and "SUCCESS" in statuses
        ):
            classification = "SUCCESS"
        elif any(item_status == "FAILURE" for _, item_status in results):
            classification = "PROPERTY_FAILURE"
        else:
            classification = "MALFORMED_OR_UNEXPECTED_RESULT"
    except Exception:
        classification = "MALFORMED_RESULT"

print(f"RUN_EXIT={exit_code}")
print(f"RESULT_STATUS={status}")
print(f"CPROVER_STATUS={cprover}")
print(f"CLASSIFICATION={classification}")
print(f"MAX_RSS_KB={max_rss}")
print(f"ELAPSED_SECONDS={seconds}")

with summary_path.open("a") as stream:
    stream.write(
        f"{expected}\t{mode}\t{exit_code}\t{status}\t{cprover}\t"
        f"{classification}\t{max_rss}\t{seconds}\n"
    )
PY

done < "$RUN/properties.tsv"

echo "===== FINAL AGGREGATION ====="
column -t -s $'\t' "$RUN/results.tsv" || cat "$RUN/results.tsv"

python3 - "$RUN/results.tsv" <<'PY'
import csv
import sys
from pathlib import Path

with Path(sys.argv[1]).open() as stream:
    rows = list(csv.DictReader(stream, delimiter="\t"))

success = [row for row in rows if row["classification"] == "SUCCESS"]
failure = [row for row in rows if row["classification"] == "PROPERTY_FAILURE"]
other = [
    row for row in rows
    if row["classification"] not in {"SUCCESS", "PROPERTY_FAILURE"}
]

print(f"T4_SHARD_COUNT={len(rows)}")
print(f"T4_SUCCESS_COUNT={len(success)}")
print(f"T4_PROPERTY_FAILURE_COUNT={len(failure)}")
print(f"T4_INCONCLUSIVE_COUNT={len(other)}")

if len(rows) == 8 and len(success) == 8:
    print(
        "PKCHECK_T4_FINAL_CLASSIFICATION="
        "T4_STUB_BACKED_GUARD_DOMINANCE_VERIFICATION_SUCCESSFUL"
    )
elif failure:
    print("PKCHECK_T4_FINAL_CLASSIFICATION=T4_PROPERTY_FAILURE_FOUND")
else:
    print("PKCHECK_T4_FINAL_CLASSIFICATION=T4_NOT_CLOSED")
PY

echo "===== SOURCE INTEGRITY ====="
test -z "$(git -C "$SOURCE" status --porcelain=v1)"
git -C "$WORKTREE" diff --quiet "$EXPECTED_COMMIT" -- mlkem
echo "AUTHORITATIVE_TREE_CLEAN_AFTER=YES"
echo "WORKTREE_PRODUCTION_SOURCE_DIFF_EMPTY_AFTER=YES"

echo "===== EVIDENCE HASHES ====="
sha256sum "$RUN/PKCHECK_T4_FINAL_SUMMARY.txt" "$HARNESS" "$MAKEFILE" "$GOTO" \
  "$RUN/dry-run.txt" "$RUN/build.log" "$RUN/loops.txt" "$RUN/functions.txt" \
  "$RUN/property.xml" "$RUN/properties.tsv" "$RUN/results.tsv" 2>/dev/null || true

echo "RUN_DIR=$RUN"
echo "GOTO_SHA=$GOTO_SHA"
echo "PKCHECK_T4_FINAL_CAPTURE_COMPLETE=YES"
