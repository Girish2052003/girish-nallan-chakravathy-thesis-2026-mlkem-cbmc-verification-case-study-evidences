#!/usr/bin/env bash
set -euo pipefail
umask 0022

BASE="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B5="$BASE/SUB00Q_BATCH5_T5_RELATIONAL"
FAMILY="$B5/frozen_harness_family_v1"
B54="$B5/B5_4_GOTO_PREFLIGHT_MLKEM768"
RUN="$B5/B5_7_EXPECTED_FAILURE_CONTROLS_MLKEM768_RUN1"

RESULTS="$RUN/full_model_results"
WITNESSES="$RUN/targeted_witnesses"
COMMANDS="$RUN/commands"
LOGS="$RUN/logs"
EXITS="$RUN/exit_codes"
RESOURCES="$RUN/resource_usage"
FROZEN="$RUN/frozen_inputs"

SUMMARY="$RUN/SUB00Q_B5_7_EXPECTED_FAILURE_SUMMARY.txt"
BINDING="$RUN/SUB00Q_B5_7_EXECUTION_INPUT_BINDING.txt"
MANIFEST="$RUN/SUB00Q_B5_7_ARTIFACT_MANIFEST.sha256"

CASES=(
  "expected_failure_off_target"
  "expected_failure_nondeterminism"
)

MARKERS=(
  "SUB_T5_EF_T5_1_EXPECTED_FAILURE"
  "SUB_T5_EF_T5_2_EXPECTED_FAILURE"
)

LABELS=(
  "EF_T5_1_OFF_TARGET_CONTROL"
  "EF_T5_2_NONDETERMINISM_CONTROL"
)

die()
{
  echo "ERROR: $*" >&2
  exit 1
}

find_accepted_dir()
{
  local summary_name="$1"
  find "$B5" -maxdepth 2 -type f -name "$summary_name" -printf '%h\n' |
    sort |
    sed -n '1p'
}

find_manifest()
{
  local directory="$1"
  find "$directory" -maxdepth 1 -type f \
    -name '*MANIFEST*.sha256' -print |
    sort |
    sed -n '1p'
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
echo "SUB-T5 / B5.7 EXPECTED-FAILURE CONTROLS"
echo "============================================================"

[ -d "$FAMILY" ] || die "frozen harness family missing: $FAMILY"
[ -d "$B54" ] || die "B5.4 preflight missing: $B54"
[ ! -e "$RUN" ] || die "B5.7 run directory already exists: $RUN"

for tool in \
  sha256sum cbmc timeout python3 find sort grep awk sed wc readlink tr
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

B55="$(find_accepted_dir 'SUB00Q_B5_5_POSITIVE_EXECUTION_SUMMARY.txt')"
B56="$(find_accepted_dir 'SUB00Q_B5_6_REACHABILITY_SUMMARY.txt')"

[ -n "${B55:-}" ] || die "accepted B5.5 run not found"
[ -n "${B56:-}" ] || die "accepted B5.6 run not found"
[ -d "$B55" ] || die "accepted B5.5 directory missing: $B55"
[ -d "$B56" ] || die "accepted B5.6 directory missing: $B56"

B54_MANIFEST="$(find_manifest "$B54")"
B55_MANIFEST="$(find_manifest "$B55")"
B56_MANIFEST="$(find_manifest "$B56")"

[ -n "${B54_MANIFEST:-}" ] || die "B5.4 manifest not found"
[ -n "${B55_MANIFEST:-}" ] || die "B5.5 manifest not found"
[ -n "${B56_MANIFEST:-}" ] || die "B5.6 manifest not found"

(
  cd "$FAMILY"
  sha256sum -c SUB00Q_B5_2_ARTIFACT_MANIFEST.sha256
  bash scripts/validate_frozen_family.sh
)

(
  cd "$B54"
  sha256sum -c "$(basename "$B54_MANIFEST")"
)

(
  cd "$B55"
  sha256sum -c "$(basename "$B55_MANIFEST")"
)

(
  cd "$B56"
  sha256sum -c "$(basename "$B56_MANIFEST")"
)

grep -q '^B5_4_STATUS=PASS$' \
  "$B54/SUB00Q_B5_4_PREFLIGHT_SUMMARY.txt" ||
  die "B5.4 PASS verdict missing"

grep -q '^B5_5_STATUS=PASS$' \
  "$B55/SUB00Q_B5_5_POSITIVE_EXECUTION_SUMMARY.txt" ||
  die "B5.5 PASS verdict missing"

grep -q '^B5_6_STATUS=PASS$' \
  "$B56/SUB00Q_B5_6_REACHABILITY_SUMMARY.txt" ||
  die "B5.6 PASS verdict missing"

mkdir -p \
  "$RESULTS" "$WITNESSES" "$COMMANDS" "$LOGS" \
  "$EXITS" "$RESOURCES" "$FROZEN"

RUNNER_PATH="$(readlink -f "$0")"
cp "$RUNNER_PATH" "$RUN/executed_runner.sh"

cp "$B54/SUB00Q_B5_4_PREFLIGHT_SUMMARY.txt" \
   "$FROZEN/B5_4_PREFLIGHT_SUMMARY.txt"
cp "$B54_MANIFEST" \
   "$FROZEN/B5_4_MANIFEST.sha256"
cp "$B55/SUB00Q_B5_5_POSITIVE_EXECUTION_SUMMARY.txt" \
   "$FROZEN/B5_5_POSITIVE_EXECUTION_SUMMARY.txt"
cp "$B55_MANIFEST" \
   "$FROZEN/B5_5_MANIFEST.sha256"
cp "$B56/SUB00Q_B5_6_REACHABILITY_SUMMARY.txt" \
   "$FROZEN/B5_6_REACHABILITY_SUMMARY.txt"
cp "$B56_MANIFEST" \
   "$FROZEN/B5_6_MANIFEST.sha256"
cp "$FAMILY/SUB00Q_B5_2_ARTIFACT_MANIFEST.sha256" \
   "$FROZEN/B5_2_ARTIFACT_MANIFEST.sha256"

{
  echo "SUB-T5 / B5.7 EXPECTED-FAILURE EXECUTION INPUT BINDING"
  echo
  echo "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "CBMC_VERSION=$CBMC_VERSION"
  echo "FROZEN_HARNESS_FAMILY=$FAMILY"
  echo "GOTO_PREFLIGHT=$B54"
  echo "ACCEPTED_POSITIVE_PARENT=$B55"
  echo "ACCEPTED_REACHABILITY_PARENT=$B56"
  echo "EXPECTED_FAILURE_CASE_COUNT=${#CASES[@]}"
  echo
  echo "Acceptance requires exactly one registered deliberate assertion failure"
  echo "per full-model run, no other failed or unknown properties, and a"
  echo "separate targeted counterexample witness for that same property."
  echo
  echo "EXPECTED_CBMC_EXIT_CODE=10"
  echo "POSITIVE_PROOF_EXECUTION=NO"
  echo "REACHABILITY_EXECUTION=NO"
  echo "EXPECTED_FAILURE_EXECUTION=YES"
  echo "MUTATION_EXECUTION=NO"
  echo "PRODUCTION_SOURCE_MODIFICATION=NO"
  echo "EARLIER_BATCH_MODIFICATION=NO"
} > "$BINDING"

printf '%s\n' \
  "SUB-T5 / B5.7 EXPECTED-FAILURE CONTROL SUMMARY" \
  "" \
  "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "CBMC_VERSION=$CBMC_VERSION" \
  "" \
  "CASE|FULL_EXIT|SUCCESS|TARGET_FAILURE|OTHER_FAILURE|UNKNOWN|TARGET_PROPERTY|WITNESS_EXIT|WITNESS_MARKER|VERDICT" \
  > "$SUMMARY"

for idx in "${!CASES[@]}"
do
  case_name="${CASES[$idx]}"
  marker="${MARKERS[$idx]}"
  label="${LABELS[$idx]}"

  goto_file="$B54/build/${case_name}.goto"
  goto_sum="$goto_file.sha256"
  unwind_file="$B54/inspection/${case_name}_frozen_unwindset.txt"

  full_json="$RESULTS/${case_name}_full_model_result.json"
  full_stderr="$LOGS/${case_name}_full_model_stderr.txt"
  full_exit="$EXITS/${case_name}_full_model_exit_code.txt"
  full_resource="$RESOURCES/${case_name}_full_model_resource_usage.txt"
  full_command="$COMMANDS/${case_name}_full_model_command.txt"
  parsed="$RESULTS/${case_name}_parsed_result.txt"
  failure_audit="$RESULTS/${case_name}_failure_isolation_audit.txt"

  witness_stdout="$WITNESSES/${case_name}_targeted_witness.txt"
  witness_stderr="$LOGS/${case_name}_targeted_witness_stderr.txt"
  witness_exit="$EXITS/${case_name}_targeted_witness_exit_code.txt"
  witness_resource="$RESOURCES/${case_name}_targeted_witness_resource_usage.txt"
  witness_command="$COMMANDS/${case_name}_targeted_witness_command.txt"

  [ -s "$goto_file" ] || die "GOTO binary missing: $goto_file"
  [ -f "$goto_sum" ] || die "GOTO checksum missing: $goto_sum"
  [ -s "$unwind_file" ] || die "unwindset missing: $unwind_file"

  sha256sum -c "$goto_sum"

  unwindset="$(tr -d '\r\n' < "$unwind_file")"
  [ -n "$unwindset" ] || die "empty unwindset for $case_name"

  cp "$unwind_file" "$FROZEN/${case_name}_frozen_unwindset.txt"
  cp "$goto_sum" "$FROZEN/${case_name}_goto.sha256"

  full_cmd=(
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
    printf ' %q' "${full_cmd[@]}"
    printf '\n'
  } > "$full_command"

  echo "CASE=$case_name PHASE=FULL_MODEL STATUS=RUNNING"

  set +e
  if [ -n "$TIME_TOOL" ]; then
    "$TIME_TOOL" -v -o "$full_resource" \
      timeout --signal=TERM --kill-after=60s 21600s \
      "${full_cmd[@]}" >"$full_json" 2>"$full_stderr"
    rc_full=$?
  else
    timeout --signal=TERM --kill-after=60s 21600s \
      "${full_cmd[@]}" >"$full_json" 2>"$full_stderr"
    rc_full=$?
    echo "RESOURCE_TOOL=UNAVAILABLE" > "$full_resource"
  fi
  set -e

  printf '%s\n' "$rc_full" > "$full_exit"

  [ "$rc_full" -eq 10 ] ||
    die "unexpected full-model exit for $case_name: $rc_full, expected 10"
  [ -s "$full_json" ] ||
    die "empty full-model JSON result for $case_name"

  python3 - "$full_json" "$parsed" "$marker" <<'PY'
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
marker = sys.argv[3]

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

seen = set()
unique = []
for rec in records:
    prop = str(rec.get("property", ""))
    status = str(rec.get("status", ""))
    desc = str(rec.get("description", ""))
    key = (prop, status, desc)
    if key not in seen:
        seen.add(key)
        unique.append((prop, status, desc))

success = sum(1 for _, status, _ in unique if status == "SUCCESS")
unknown = sum(
    1 for _, status, _ in unique
    if status not in {"SUCCESS", "FAILURE"}
)
target = [
    (prop, status, desc)
    for prop, status, desc in unique
    if marker in prop or marker in desc
]
target_failures = sum(1 for _, status, _ in target if status == "FAILURE")
other_failures = sum(
    1 for prop, status, desc in unique
    if status == "FAILURE" and marker not in prop and marker not in desc
)
total = len(unique)

target_property = ""
for prop, status, _ in target:
    if status == "FAILURE":
        target_property = prop
        break

lines = [
    f"SUCCESS={success}",
    f"TARGET_FAILURE={target_failures}",
    f"OTHER_FAILURE={other_failures}",
    f"UNKNOWN={unknown}",
    f"TOTAL_RESULTS={total}",
    f"TARGET_PROPERTY={target_property}",
]
for prop, status, desc in unique:
    lines.append(f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}")

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if total < 1:
    raise SystemExit("NO_PROPERTY_RESULTS")
if len(target) != 1:
    raise SystemExit(f"TARGET_RECORD_COUNT={len(target)}")
if target_failures != 1:
    raise SystemExit(f"TARGET_FAILURE_COUNT={target_failures}")
if other_failures != 0:
    raise SystemExit(f"OTHER_FAILURE_COUNT={other_failures}")
if unknown != 0:
    raise SystemExit(f"UNKNOWN_COUNT={unknown}")
if not target_property:
    raise SystemExit("TARGET_PROPERTY_MISSING")
PY

  success_count="$(awk -F= '/^SUCCESS=/{print $2}' "$parsed")"
  target_failure="$(awk -F= '/^TARGET_FAILURE=/{print $2}' "$parsed")"
  other_failure="$(awk -F= '/^OTHER_FAILURE=/{print $2}' "$parsed")"
  unknown_count="$(awk -F= '/^UNKNOWN=/{print $2}' "$parsed")"
  target_property="$(sed -n 's/^TARGET_PROPERTY=//p' "$parsed")"

  [ -n "$target_property" ] ||
    die "target property identifier missing for $case_name"

  {
    echo "MARKER=$marker"
    echo "TARGET_PROPERTY=$target_property"
    echo "TARGET_FAILURE=$target_failure"
    echo "OTHER_FAILURE=$other_failure"
    echo "UNKNOWN=$unknown_count"
  } > "$failure_audit"

  sha256sum "$full_json" > "$full_json.sha256"

  witness_cmd=(
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
    --property "$target_property"
    --trace
  )

  {
    printf 'COMMAND:'
    printf ' %q' "${witness_cmd[@]}"
    printf '\n'
  } > "$witness_command"

  echo "CASE=$case_name PHASE=TARGETED_WITNESS STATUS=RUNNING"

  set +e
  if [ -n "$TIME_TOOL" ]; then
    "$TIME_TOOL" -v -o "$witness_resource" \
      timeout --signal=TERM --kill-after=60s 21600s \
      "${witness_cmd[@]}" >"$witness_stdout" 2>"$witness_stderr"
    rc_witness=$?
  else
    timeout --signal=TERM --kill-after=60s 21600s \
      "${witness_cmd[@]}" >"$witness_stdout" 2>"$witness_stderr"
    rc_witness=$?
    echo "RESOURCE_TOOL=UNAVAILABLE" > "$witness_resource"
  fi
  set -e

  printf '%s\n' "$rc_witness" > "$witness_exit"

  [ "$rc_witness" -eq 10 ] ||
    die "unexpected targeted-witness exit for $case_name: $rc_witness"
  [ -s "$witness_stdout" ] ||
    die "empty targeted witness for $case_name"

  grep -Fq "$marker" "$witness_stdout" ||
    die "registered marker missing from targeted witness for $case_name"
  grep -q 'Violated property' "$witness_stdout" ||
    die "violation trace heading missing for $case_name"
  grep -q 'VERIFICATION FAILED' "$witness_stdout" ||
    die "targeted witness did not report verification failure for $case_name"

  witness_marker=1
  sha256sum "$witness_stdout" > "$witness_stdout.sha256"

  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|PASS\n' \
    "$case_name" \
    "$rc_full" \
    "$success_count" \
    "$target_failure" \
    "$other_failure" \
    "$unknown_count" \
    "$target_property" \
    "$rc_witness" \
    "$witness_marker" \
    >> "$SUMMARY"

  echo "CASE=$case_name STATUS=PASS TARGET_FAILURE=1 OTHER_FAILURE=0 UNKNOWN=0 WITNESS=PASS"
done

target_failure_total="$(
  awk -F'|' '/^expected_failure_/ {sum += $4} END {print sum+0}' "$SUMMARY"
)"
other_failure_total="$(
  awk -F'|' '/^expected_failure_/ {sum += $5} END {print sum+0}' "$SUMMARY"
)"
unknown_total="$(
  awk -F'|' '/^expected_failure_/ {sum += $6} END {print sum+0}' "$SUMMARY"
)"
witness_marker_total="$(
  awk -F'|' '/^expected_failure_/ {sum += $9} END {print sum+0}' "$SUMMARY"
)"

{
  echo
  echo "=== B5.7 FINAL VERDICT ==="
  echo "EXPECTED_FAILURE_CASE_COUNT=${#CASES[@]}"
  echo "FULL_MODEL_EXPECTED_EXIT_COUNT=$(grep -l '^10$' "$EXITS"/*_full_model_exit_code.txt | wc -l)"
  echo "TARGET_FAILURE_TOTAL=$target_failure_total"
  echo "UNEXPECTED_FAILURE_TOTAL=$other_failure_total"
  echo "UNKNOWN_PROPERTY_TOTAL=$unknown_total"
  echo "TARGET_PROPERTY_COUNT=$(find "$RESULTS" -maxdepth 1 -type f -name '*_failure_isolation_audit.txt' | wc -l)"
  echo "TARGETED_WITNESS_EXPECTED_EXIT_COUNT=$(grep -l '^10$' "$EXITS"/*_targeted_witness_exit_code.txt | wc -l)"
  echo "TARGETED_WITNESS_MARKER_COUNT=$witness_marker_total"
  echo "EF_T5_1_OFF_TARGET_CONTROL=REJECTED_AS_EXPECTED"
  echo "EF_T5_2_NONDETERMINISM_CONTROL=REJECTED_AS_EXPECTED"
  echo "ALL_NON_TARGET_PROPERTIES_SUCCESS=PASS"
  echo "EXPECTED_FAILURE_ISOLATION=PASS"
  echo "COUNTEREXAMPLE_WITNESSES_CAPTURED=PASS"
  echo "B5_7_STATUS=PASS"
  echo
  echo "=== OPERATION BOUNDARY ==="
  echo "POSITIVE_PROOF_EXECUTION=NO"
  echo "REACHABILITY_EXECUTION=NO"
  echo "EXPECTED_FAILURE_EXECUTION=YES"
  echo "MUTATION_EXECUTION=NO"
  echo "PRODUCTION_SOURCE_MODIFICATION=NO"
  echo "EARLIER_BATCH_MODIFICATION=NO"
} >> "$SUMMARY"

[ "$target_failure_total" -eq 2 ] ||
  die "aggregate target-failure count mismatch"
[ "$other_failure_total" -eq 0 ] ||
  die "unexpected failed properties detected"
[ "$unknown_total" -eq 0 ] ||
  die "unknown property results detected"
[ "$witness_marker_total" -eq 2 ] ||
  die "targeted witness marker count mismatch"

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
echo "=== B5.7 FINAL SUMMARY ==="
grep -E \
  'EXPECTED_FAILURE_CASE_COUNT=|FULL_MODEL_EXPECTED_EXIT_COUNT=|TARGET_FAILURE_TOTAL=|UNEXPECTED_FAILURE_TOTAL=|UNKNOWN_PROPERTY_TOTAL=|TARGET_PROPERTY_COUNT=|TARGETED_WITNESS_EXPECTED_EXIT_COUNT=|TARGETED_WITNESS_MARKER_COUNT=|EF_T5_1_OFF_TARGET_CONTROL=|EF_T5_2_NONDETERMINISM_CONTROL=|ALL_NON_TARGET_PROPERTIES_SUCCESS=|EXPECTED_FAILURE_ISOLATION=|COUNTEREXAMPLE_WITNESSES_CAPTURED=|B5_7_STATUS=|POSITIVE_PROOF_EXECUTION=|REACHABILITY_EXECUTION=|EXPECTED_FAILURE_EXECUTION=|MUTATION_EXECUTION=|PRODUCTION_SOURCE_MODIFICATION=|EARLIER_BATCH_MODIFICATION=' \
  "$SUMMARY"

echo
echo "B5_7_DIRECTORY=$RUN"
echo "B5_7_SUMMARY=$SUMMARY"
echo "============================================================"
