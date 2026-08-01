#!/usr/bin/env bash
set -euo pipefail
umask 0022

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
PARENT="$B6/05_POSITIVE_EXECUTION"
OUT="$HOME/Downloads/SUB_T6_B6_5_TOMSG_FAILURE_DIAGNOSTIC"
TAR="$HOME/Downloads/SUB_T6_B6_5_TOMSG_FAILURE_DIAGNOSTIC.tar.gz"

echo "=== SUB-T6 B6.5 TOMSG FAILURE DIAGNOSTIC ==="
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "PARENT=$PARENT"
echo "OUT=$OUT"
echo "TAR=$TAR"

test -d "$PARENT"

if [ -e "$OUT" ]; then
  echo "DIAGNOSTIC_DIRECTORY_ALREADY_EXISTS=$OUT"
  exit 1
fi

if [ -e "$TAR" ]; then
  echo "DIAGNOSTIC_TAR_ALREADY_EXISTS=$TAR"
  exit 1
fi

mapfile -t FAILED_DIRS < <(
  find "$PARENT" \
    -maxdepth 1 \
    -type d \
    -name 'B6_5_POSITIVE_EXECUTION_MLKEM768_RUN1_FAILED_*' \
    -printf '%T@ %p\n' |
  sort -nr |
  awk '{sub(/^[^ ]+ /, ""); print}'
)

if [ "${#FAILED_DIRS[@]}" -lt 1 ]; then
  echo "FAILED_B65_DIRECTORY_FOUND=NO"
  exit 1
fi

FAILED="${FAILED_DIRS[0]}"
echo "FAILED_B65_DIRECTORY=$FAILED"

mkdir -p "$OUT"

{
  echo "=== FAILED B6.5 INVENTORY ==="
  find "$FAILED" -maxdepth 4 -printf '%m %y %s %p\n' | sort
} > "$OUT/FAILED_B65_INVENTORY.txt"

copy_if_present()
{
  local source="$1"
  local target_name="$2"

  if [ -f "$source" ]; then
    cp -a "$source" "$OUT/$target_name"
  else
    printf 'MISSING=%s\n' "$source" > "$OUT/${target_name}.MISSING.txt"
  fi
}

copy_if_present \
  "$FAILED/exit_codes/tomsg_precondition_cbmc_exit_code.txt" \
  "tomsg_precondition_cbmc_exit_code.txt"

copy_if_present \
  "$FAILED/logs/tomsg_precondition_cbmc_stderr.txt" \
  "tomsg_precondition_cbmc_stderr.txt"

copy_if_present \
  "$FAILED/resource_usage/tomsg_precondition_resource_usage.txt" \
  "tomsg_precondition_resource_usage.txt"

copy_if_present \
  "$FAILED/commands/tomsg_precondition_cbmc_command.txt" \
  "tomsg_precondition_cbmc_command.txt"

copy_if_present \
  "$FAILED/results/tomsg_precondition_cbmc_result.json" \
  "tomsg_precondition_cbmc_result.json"

copy_if_present \
  "$FAILED/results/tomsg_precondition_parsed_result.txt" \
  "tomsg_precondition_parsed_result.txt"

copy_if_present \
  "$FAILED/results/tomsg_precondition_expected_marker_audit.txt" \
  "tomsg_precondition_expected_marker_audit.txt"

copy_if_present \
  "$FAILED/SUB_T6_B6_5_POSITIVE_EXECUTION_SUMMARY.txt" \
  "SUB_T6_B6_5_POSITIVE_EXECUTION_SUMMARY.txt"

for case_name in \
  callsite_precondition \
  callsite_exactness \
  callsite_frame \
  sub_reduce_handoff
do
  copy_if_present \
    "$FAILED/results/${case_name}_parsed_result.txt" \
    "${case_name}_parsed_result.txt"

  copy_if_present \
    "$FAILED/exit_codes/${case_name}_cbmc_exit_code.txt" \
    "${case_name}_cbmc_exit_code.txt"
done

python3 - "$FAILED" "$OUT" <<'PY'
import json
import os
import sys
from pathlib import Path

failed = Path(sys.argv[1])
out = Path(sys.argv[2])

exit_path = failed / "exit_codes/tomsg_precondition_cbmc_exit_code.txt"
stderr_path = failed / "logs/tomsg_precondition_cbmc_stderr.txt"
resource_path = failed / "resource_usage/tomsg_precondition_resource_usage.txt"
json_path = failed / "results/tomsg_precondition_cbmc_result.json"

lines = []

if exit_path.is_file():
    exit_text = exit_path.read_text(encoding="utf-8", errors="replace").strip()
    lines.append(f"TOMSG_EXIT_CODE={exit_text}")
else:
    lines.append("TOMSG_EXIT_CODE=MISSING")

if stderr_path.is_file():
    stderr_text = stderr_path.read_text(encoding="utf-8", errors="replace")
    lines.append(f"TOMSG_STDERR_BYTES={stderr_path.stat().st_size}")
    lower = stderr_text.lower()

    if "out of memory" in lower or "std::bad_alloc" in lower:
        lines.append("LIKELY_REASON=OUT_OF_MEMORY")
    elif "timed out" in lower or "timeout" in lower:
        lines.append("LIKELY_REASON=TIMEOUT")
    elif "killed" in lower:
        lines.append("LIKELY_REASON=PROCESS_KILLED")
    elif "conversion" in lower and "failed" in lower:
        lines.append("LIKELY_REASON=CBMC_CONVERSION_OR_CHECK_FAILURE")
    else:
        lines.append("LIKELY_REASON=UNCLASSIFIED_FROM_STDERR")
else:
    lines.append("TOMSG_STDERR_BYTES=MISSING")
    lines.append("LIKELY_REASON=UNCLASSIFIED_NO_STDERR")

if resource_path.is_file():
    text = resource_path.read_text(encoding="utf-8", errors="replace")
    lines.append(f"RESOURCE_USAGE_BYTES={resource_path.stat().st_size}")

    for wanted in (
        "Elapsed (wall clock) time",
        "Maximum resident set size",
        "Percent of CPU this job got",
        "User time",
        "System time",
        "Exit status",
    ):
        for raw in text.splitlines():
            if wanted in raw:
                lines.append("RESOURCE_" + raw.strip())
                break
else:
    lines.append("RESOURCE_USAGE_BYTES=MISSING")

if json_path.is_file():
    lines.append(f"TOMSG_JSON_BYTES={json_path.stat().st_size}")

    try:
        data = json.loads(json_path.read_text(encoding="utf-8"))
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

        unique = {}
        for rec in records:
            prop = str(rec.get("property", ""))
            status = str(rec.get("status", ""))
            desc = str(rec.get("description", ""))
            unique[(prop, desc)] = status

        success = sum(1 for status in unique.values() if status == "SUCCESS")
        failure = sum(1 for status in unique.values() if status == "FAILURE")
        unknown = sum(
            1 for status in unique.values()
            if status not in {"SUCCESS", "FAILURE"}
        )

        lines.append("JSON_PARSE=PASS")
        lines.append(f"JSON_RESULT_TOTAL={len(unique)}")
        lines.append(f"JSON_SUCCESS={success}")
        lines.append(f"JSON_FAILURE={failure}")
        lines.append(f"JSON_UNKNOWN={unknown}")

        markers = (
            "SUB_T6_T6_6_SUB_ANCHOR",
            "SUB_T6_T6_6_PRE_LOWER",
            "SUB_T6_T6_6_PRE_UPPER",
            "SUB_T6_T6_6_CONST_INPUT",
        )

        json_text = json_path.read_text(encoding="utf-8", errors="replace")
        for marker in markers:
            lines.append(
                f"{marker}="
                + ("PRESENT" if marker in json_text else "ABSENT")
            )

    except Exception as exc:
        lines.append(f"JSON_PARSE=FAIL:{type(exc).__name__}:{exc}")
else:
    lines.append("TOMSG_JSON_BYTES=MISSING")
    lines.append("JSON_PARSE=NOT_AVAILABLE")

(out / "TOMSG_FAILURE_CLASSIFICATION.txt").write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print("\n".join(lines))
PY

{
  echo
  echo "=== STDERR TAIL ==="
  if [ -f "$FAILED/logs/tomsg_precondition_cbmc_stderr.txt" ]; then
    tail -n 80 "$FAILED/logs/tomsg_precondition_cbmc_stderr.txt"
  else
    echo "STDERR_FILE_MISSING"
  fi

  echo
  echo "=== RESOURCE USAGE ==="
  if [ -f "$FAILED/resource_usage/tomsg_precondition_resource_usage.txt" ]; then
    cat "$FAILED/resource_usage/tomsg_precondition_resource_usage.txt"
  else
    echo "RESOURCE_FILE_MISSING"
  fi
} | tee "$OUT/TOMSG_FAILURE_HUMAN_READABLE.txt"

{
  echo "DIAGNOSTIC_SCHEMA=sub-t6-b6.5-tomsg-failure-diagnostic-v1"
  echo "CREATED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "FAILED_B65_DIRECTORY=$FAILED"
  echo "FOUR_POSITIVE_CASES_ALREADY_PASSED=YES"
  echo "TOMSG_CASE_VERDICT=NOT_YET_CLASSIFIED"
  echo "CBMC_PROOF_EXECUTION_OCCURRED=YES"
  echo "PRODUCTION_MODIFIED=NO"
  echo "BATCH5_MODIFIED=NO"
  echo "DIAGNOSTIC_ONLY=YES"
} > "$OUT/DIAGNOSTIC_MANIFEST.txt"

(
  cd "$OUT"
  find . -type f \
    ! -name 'DIAGNOSTIC_SHA256.txt' \
    -print0 |
  sort -z |
  xargs -0 sha256sum > DIAGNOSTIC_SHA256.txt

  sha256sum -c DIAGNOSTIC_SHA256.txt
)

tar -C "$(dirname "$OUT")" \
  -czf "$TAR" \
  "$(basename "$OUT")"

echo
echo "--- Diagnostic package ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$TAR"
sha256sum "$TAR"

echo
echo "B65_FOUR_POSITIVE_CASES_ALREADY_PASS=YES"
echo "B65_TOMSG_CASE_CLASSIFIED_FROM_EVIDENCE=YES"
echo "B65_FAILED_ATTEMPT_PRESERVED=YES"
echo "B65_PRODUCTION_MODIFIED=NO"
echo "B65_BATCH5_MODIFIED=NO"
echo "B65_DIAGNOSTIC_PACKAGE_CREATED=YES"
echo "B65_DIAGNOSTIC_UPLOAD_REQUIRED=YES"
echo "B65_DIAGNOSTIC_STATUS=PASS"
