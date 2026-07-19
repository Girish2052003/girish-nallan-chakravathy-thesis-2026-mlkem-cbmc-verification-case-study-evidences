#!/usr/bin/env bash
set -euo pipefail
umask 0022

BASE="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B5="$BASE/SUB00Q_BATCH5_T5_RELATIONAL"
FAMILY="$B5/frozen_harness_family_v1"
B54="$B5/B5_4_GOTO_PREFLIGHT_MLKEM768"
RUN="$B5/B5_5_POSITIVE_RELATIONAL_EXECUTION_MLKEM768_RUN1"

RESULTS="$RUN/results"
COMMANDS="$RUN/commands"
LOGS="$RUN/logs"
EXITS="$RUN/exit_codes"
RESOURCES="$RUN/resource_usage"
FROZEN="$RUN/frozen_inputs"
SUMMARY="$RUN/SUB00Q_B5_5_POSITIVE_EXECUTION_SUMMARY.txt"
BINDING="$RUN/SUB00Q_B5_5_EXECUTION_INPUT_BINDING.txt"
MANIFEST="$RUN/SUB00Q_B5_5_ARTIFACT_MANIFEST.sha256"

CASES=(
  "positive_frame"
  "positive_locality"
  "positive_noninterference_exact"
  "positive_determinism"
)

EXPECTED_MARKERS_positive_frame=(
  "SUB_T5_FRAME_ANCHOR_R1"
  "SUB_T5_FRAME_ANCHOR_R2"
  "SUB_T5_T5_1_FRAME_A1"
  "SUB_T5_T5_1_FRAME_A2"
  "SUB_T5_T5_1_FRAME_B1"
  "SUB_T5_T5_1_FRAME_B2"
  "SUB_T5_T5_1_SNAPSHOT_A1"
  "SUB_T5_T5_1_SNAPSHOT_A2"
  "SUB_T5_T5_1_SNAPSHOT_B1"
  "SUB_T5_T5_1_SNAPSHOT_B2"
  "SUB_T5_T5_6_GUARD_1"
  "SUB_T5_T5_6_GUARD_2"
)

EXPECTED_MARKERS_positive_locality=(
  "SUB_T5_T5_2_EXACT_R1_K"
  "SUB_T5_T5_2_EXACT_R2_K"
  "SUB_T5_T5_2_LOCALITY"
)

EXPECTED_MARKERS_positive_noninterference_exact=(
  "SUB_T5_T5_4_EXACT_R1"
  "SUB_T5_T5_4_EXACT_R2"
  "SUB_T5_T5_3_NONINTERFERENCE"
  "SUB_T5_T5_4_CHANGED_R1"
  "SUB_T5_T5_4_CHANGED_R2"
  "SUB_T5_T5_4_RELATIONAL_EFFECT"
)

EXPECTED_MARKERS_positive_determinism=(
  "SUB_T5_T5_5_EXACT_R1"
  "SUB_T5_T5_5_EXACT_R2"
  "SUB_T5_T5_5_DETERMINISM"
  "SUB_T5_T5_5_INPUT_A_EQUALITY"
  "SUB_T5_T5_5_INPUT_B_EQUALITY"
)

die()
{
  echo "ERROR: $*" >&2
  exit 1
}

SUCCESS=0
cleanup()
{
  rc=$?
  if [ "$SUCCESS" -ne 1 ] && [ -d "$RUN" ]; then
    failed="${RUN}_FAILED_$(date -u +%Y%m%dT%H%M%SZ)"
    chmod -R u+rwX "$RUN" 2>/dev/null || true
    mv "$RUN" "$failed" 2>/dev/null || true
    echo "FAILED_ATTEMPT_PRESERVED=$failed" >&2
  fi
  exit "$rc"
}
trap cleanup EXIT

echo "============================================================"
echo "SUB-T5 / B5.5 POSITIVE RELATIONAL EXECUTION"
echo "============================================================"

[ -d "$FAMILY" ] || die "frozen harness family missing: $FAMILY"
[ -d "$B54" ] || die "B5.4 preflight missing: $B54"
[ -f "$B54/SUB00Q_B5_4_PREFLIGHT_ARTIFACT_MANIFEST.sha256" ] ||
  die "B5.4 manifest missing"
[ ! -e "$RUN" ] || die "B5.5 run directory already exists: $RUN"

for tool in sha256sum cbmc timeout python3 find sort grep awk sed wc readlink
do
  command -v "$tool" >/dev/null 2>&1 ||
    die "required tool missing: $tool"
done

TIME_TOOL=""
if [ -x /usr/bin/time ]; then
  TIME_TOOL="/usr/bin/time"
fi

CBMC_VERSION="$(cbmc --version | sed -n '1p')"
echo "$CBMC_VERSION" | grep -q '6\.9\.0' ||
  die "CBMC is not the frozen 6.9.0 toolchain"

(
  cd "$FAMILY"
  sha256sum -c SUB00Q_B5_2_ARTIFACT_MANIFEST.sha256
  bash scripts/validate_frozen_family.sh
)

(
  cd "$B54"
  sha256sum -c SUB00Q_B5_4_PREFLIGHT_ARTIFACT_MANIFEST.sha256
)

grep -q '^B5_4_STATUS=PASS$' \
  "$B54/SUB00Q_B5_4_PREFLIGHT_SUMMARY.txt" ||
  die "B5.4 does not contain a PASS verdict"

mkdir -p "$RESULTS" "$COMMANDS" "$LOGS" "$EXITS" "$RESOURCES" "$FROZEN"

RUNNER_PATH="$(readlink -f "$0")"
cp "$RUNNER_PATH" "$RUN/executed_runner.sh"

cp "$B54/SUB00Q_B5_4_PREFLIGHT_SUMMARY.txt" \
   "$FROZEN/B5_4_PREFLIGHT_SUMMARY.txt"
cp "$B54/SUB00Q_B5_4_PREFLIGHT_ARTIFACT_MANIFEST.sha256" \
   "$FROZEN/B5_4_ARTIFACT_MANIFEST.sha256"
cp "$FAMILY/SUB00Q_B5_2_ARTIFACT_MANIFEST.sha256" \
   "$FROZEN/B5_2_ARTIFACT_MANIFEST.sha256"

{
  echo "SUB-T5 / B5.5 POSITIVE EXECUTION INPUT BINDING"
  echo
  echo "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "CBMC_VERSION=$CBMC_VERSION"
  echo "FROZEN_HARNESS_FAMILY=$FAMILY"
  echo "GOTO_PREFLIGHT=$B54"
  echo "CASE_COUNT=${#CASES[@]}"
  echo
  echo "Only the four positive relational cases are executed in this gate."
  echo "Reachability, expected-failure, and mutation cases are excluded."
  echo
  echo "CBMC_PROOF_EXECUTION=YES"
  echo "REACHABILITY_EXECUTION=NO"
  echo "EXPECTED_FAILURE_EXECUTION=NO"
  echo "MUTATION_EXECUTION=NO"
  echo "PRODUCTION_SOURCE_MODIFICATION=NO"
  echo "EARLIER_BATCH_MODIFICATION=NO"
} > "$BINDING"

printf '%s\n' \
  "SUB-T5 / B5.5 POSITIVE RELATIONAL EXECUTION SUMMARY" \
  "" \
  "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "CBMC_VERSION=$CBMC_VERSION" \
  "" \
  "CASE|EXIT|SUCCESS|FAILURE|UNKNOWN|TOTAL_RESULTS|EXPECTED_MARKERS|FOUND_MARKERS|VERDICT" \
  > "$SUMMARY"

for case_name in "${CASES[@]}"
do
  goto_file="$B54/build/${case_name}.goto"
  goto_sum="$goto_file.sha256"
  unwind_file="$B54/inspection/${case_name}_frozen_unwindset.txt"
  result_json="$RESULTS/${case_name}_cbmc_result.json"
  result_stderr="$LOGS/${case_name}_cbmc_stderr.txt"
  exit_file="$EXITS/${case_name}_cbmc_exit_code.txt"
  resource_file="$RESOURCES/${case_name}_resource_usage.txt"
  command_file="$COMMANDS/${case_name}_cbmc_command.txt"
  parse_file="$RESULTS/${case_name}_parsed_result.txt"
  marker_file="$RESULTS/${case_name}_expected_marker_audit.txt"

  [ -s "$goto_file" ] || die "GOTO binary missing: $goto_file"
  [ -f "$goto_sum" ] || die "GOTO checksum missing: $goto_sum"
  [ -s "$unwind_file" ] || die "unwindset missing: $unwind_file"

  sha256sum -c "$goto_sum"
  unwindset="$(tr -d '\r\n' < "$unwind_file")"
  [ -n "$unwindset" ] || die "empty unwindset for $case_name"

  cp "$unwind_file" "$FROZEN/${case_name}_frozen_unwindset.txt"
  cp "$goto_sum" "$FROZEN/${case_name}_goto.sha256"

  cmd=(
    cbmc
    "$goto_file"
    --function main
    --object-bits 8
    --bounds-check
    --pointer-check
    --pointer-overflow-check
    --pointer-primitive-check
    --signed-overflow-check
    --unsigned-overflow-check
    --conversion-check
    --undefined-shift-check
    --div-by-zero-check
    --unwinding-assertions
    --unwindset "$unwindset"
    --slice-formula
    --sat-solver minisat2
    --trace
    --json-ui
  )

  {
    printf 'COMMAND:'
    printf ' %q' "${cmd[@]}"
    printf '\n'
  } > "$command_file"

  echo "CASE=$case_name STATUS=RUNNING"

  set +e
  if [ -n "$TIME_TOOL" ]; then
    "$TIME_TOOL" -v -o "$resource_file" \
      timeout --signal=TERM --kill-after=60s 21600s \
      "${cmd[@]}" >"$result_json" 2>"$result_stderr"
    rc=$?
  else
    timeout --signal=TERM --kill-after=60s 21600s \
      "${cmd[@]}" >"$result_json" 2>"$result_stderr"
    rc=$?
    echo "RESOURCE_TOOL=UNAVAILABLE" > "$resource_file"
  fi
  set -e

  printf '%s\n' "$rc" > "$exit_file"

  [ "$rc" -eq 0 ] ||
    die "positive CBMC execution failed for $case_name with exit $rc"

  [ -s "$result_json" ] ||
    die "empty CBMC JSON result for $case_name"

  python3 - "$result_json" "$parse_file" <<'PY'
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])

try:
    data = json.loads(src.read_text(encoding="utf-8"))
except Exception as exc:
    raise SystemExit(f"JSON_PARSE_ERROR={exc}")

records = []

def walk(obj):
    if isinstance(obj, dict):
        if "property" in obj and "status" in obj:
            records.append(obj)
        for value in obj.values():
            walk(value)
    elif isinstance(obj, list):
        for value in obj:
            walk(value)

walk(data)

# De-duplicate exact property/status/description triples while preserving order.
seen = set()
unique = []
for rec in records:
    item = (
        str(rec.get("property", "")),
        str(rec.get("status", "")),
        str(rec.get("description", "")),
    )
    if item not in seen:
        seen.add(item)
        unique.append(item)

success = sum(1 for _, status, _ in unique if status == "SUCCESS")
failure = sum(1 for _, status, _ in unique if status == "FAILURE")
unknown = sum(1 for _, status, _ in unique if status not in {"SUCCESS", "FAILURE"})
total = len(unique)

lines = [
    f"SUCCESS={success}",
    f"FAILURE={failure}",
    f"UNKNOWN={unknown}",
    f"TOTAL_RESULTS={total}",
]
for prop, status, desc in unique:
    lines.append(f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}")

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if total < 1:
    raise SystemExit("NO_PROPERTY_RESULTS")
if failure != 0:
    raise SystemExit(f"FAILURE_RESULTS={failure}")
if unknown != 0:
    raise SystemExit(f"UNKNOWN_RESULTS={unknown}")
PY

  success_count="$(awk -F= '/^SUCCESS=/{print $2}' "$parse_file")"
  failure_count="$(awk -F= '/^FAILURE=/{print $2}' "$parse_file")"
  unknown_count="$(awk -F= '/^UNKNOWN=/{print $2}' "$parse_file")"
  total_count="$(awk -F= '/^TOTAL_RESULTS=/{print $2}' "$parse_file")"

  marker_var="EXPECTED_MARKERS_${case_name}[@]"
  expected_markers=( "${!marker_var}" )
  expected_count="${#expected_markers[@]}"
  found_count=0
  : > "$marker_file"

  for marker in "${expected_markers[@]}"
  do
    if grep -Fq "$marker" "$parse_file"; then
      echo "$marker=FOUND" >> "$marker_file"
      found_count=$((found_count + 1))
    else
      echo "$marker=MISSING" >> "$marker_file"
    fi
  done

  [ "$found_count" -eq "$expected_count" ] ||
    die "expected theorem markers missing for $case_name; inspect $marker_file"

  [ "$failure_count" -eq 0 ] ||
    die "failure results found for $case_name"
  [ "$unknown_count" -eq 0 ] ||
    die "unknown results found for $case_name"
  [ "$success_count" -eq "$total_count" ] ||
    die "not every property succeeded for $case_name"

  sha256sum "$result_json" > "$result_json.sha256"

  printf '%s|%s|%s|%s|%s|%s|%s|%s|PASS\n' \
    "$case_name" \
    "$rc" \
    "$success_count" \
    "$failure_count" \
    "$unknown_count" \
    "$total_count" \
    "$expected_count" \
    "$found_count" \
    >> "$SUMMARY"

  echo "CASE=$case_name STATUS=PASS SUCCESS=$success_count TOTAL=$total_count MARKERS=$found_count/$expected_count"
done

{
  echo
  echo "=== B5.5 FINAL VERDICT ==="
  echo "POSITIVE_CASE_COUNT=${#CASES[@]}"
  echo "ZERO_EXIT_CASE_COUNT=$(grep -l '^0$' "$EXITS"/*_cbmc_exit_code.txt | wc -l)"
  echo "RESULT_JSON_COUNT=$(find "$RESULTS" -maxdepth 1 -type f -name '*_cbmc_result.json' | wc -l)"
  echo "RESULT_CHECKSUM_COUNT=$(find "$RESULTS" -maxdepth 1 -type f -name '*_cbmc_result.json.sha256' | wc -l)"
  echo "PARSED_RESULT_COUNT=$(find "$RESULTS" -maxdepth 1 -type f -name '*_parsed_result.txt' | wc -l)"
  echo "MARKER_AUDIT_COUNT=$(find "$RESULTS" -maxdepth 1 -type f -name '*_expected_marker_audit.txt' | wc -l)"
  echo "FAILED_PROPERTY_TOTAL=$(awk -F'|' 'NR>5 && $1 !~ /^$/ {sum += $4} END {print sum+0}' "$SUMMARY")"
  echo "UNKNOWN_PROPERTY_TOTAL=$(awk -F'|' 'NR>5 && $1 !~ /^$/ {sum += $5} END {print sum+0}' "$SUMMARY")"
  echo "ALL_POSITIVE_CBMC_EXITS_ZERO=PASS"
  echo "ALL_POSITIVE_PROPERTIES_SUCCESS=PASS"
  echo "ALL_EXPECTED_T5_MARKERS_PRESENT=PASS"
  echo "B5_5_STATUS=PASS"
  echo
  echo "=== OPERATION BOUNDARY ==="
  echo "CBMC_PROOF_EXECUTION=YES"
  echo "REACHABILITY_EXECUTION=NO"
  echo "EXPECTED_FAILURE_EXECUTION=NO"
  echo "MUTATION_EXECUTION=NO"
  echo "PRODUCTION_SOURCE_MODIFICATION=NO"
  echo "EARLIER_BATCH_MODIFICATION=NO"
} >> "$SUMMARY"

(
  cd "$RUN"
  find . -type f \
    ! -name "$(basename "$MANIFEST")" \
    -print0 |
    sort -z |
    xargs -0 sha256sum > "$MANIFEST"
  sha256sum -c "$MANIFEST"
)

find "$RUN" -type f -exec chmod 0444 {} +
chmod 0555 "$RUN/executed_runner.sh"
find "$RUN" -type d -exec chmod 0555 {} +

SUCCESS=1
trap - EXIT

echo
echo "=== B5.5 FINAL SUMMARY ==="
grep -E \
  'POSITIVE_CASE_COUNT=|ZERO_EXIT_CASE_COUNT=|RESULT_JSON_COUNT=|RESULT_CHECKSUM_COUNT=|PARSED_RESULT_COUNT=|MARKER_AUDIT_COUNT=|FAILED_PROPERTY_TOTAL=|UNKNOWN_PROPERTY_TOTAL=|ALL_POSITIVE_CBMC_EXITS_ZERO=|ALL_POSITIVE_PROPERTIES_SUCCESS=|ALL_EXPECTED_T5_MARKERS_PRESENT=|B5_5_STATUS=|CBMC_PROOF_EXECUTION=|REACHABILITY_EXECUTION=|EXPECTED_FAILURE_EXECUTION=|MUTATION_EXECUTION=|PRODUCTION_SOURCE_MODIFICATION=|EARLIER_BATCH_MODIFICATION=' \
  "$SUMMARY"

echo
echo "B5_5_DIRECTORY=$RUN"
echo "B5_5_SUMMARY=$SUMMARY"
echo "============================================================"
