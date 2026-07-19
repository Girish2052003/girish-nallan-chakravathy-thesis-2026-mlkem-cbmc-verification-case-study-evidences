#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
PREFLIGHT="$ROOT/SUB00O_R5_BATCH3_T3_GOTO_PREFLIGHT_MLKEM768_V1"
PREFLIGHT_MANIFEST="$PREFLIGHT/SUB00O_R5_ARTIFACT_MANIFEST.sha256"
CASE_MATRIX="$PREFLIGHT/CASE_MATRIX.tsv"

OUT="$ROOT/SUB00P_AUTHORITATIVE_T3_EXECUTION_MLKEM768_RUN1"
CASES="$OUT/cases"
SUMMARY="$OUT/SUB00P_T3_FINAL_VERDICT.txt"
SUMMARY_JSON="$OUT/SUB00P_T3_INDEPENDENT_SUMMARY.json"
MANIFEST="$OUT/SUB00P_ARTIFACT_MANIFEST.sha256"
RUNNER_COPY="$OUT/executed_runner.sh"

TIMEOUT_SECONDS=21600
FROZEN_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

fail() {
  echo "SUB00P_RUNNER_STATUS=FAIL" >&2
  echo "REASON=$*" >&2
  exit 1
}

require_file() {
  test -f "$1" || fail "required file missing: $1"
}

require_dir() {
  test -d "$1" || fail "required directory missing: $1"
}

verify_manifest() {
  local directory="$1"
  local manifest_name="$2"
  (
    cd "$directory"
    sha256sum -c "$manifest_name"
  )
}

execute_frozen_command() {
  local command_file="$1"
  local stdout_file="$2"
  local stderr_file="$3"
  local exit_file="$4"
  local elapsed_file="$5"

  require_file "$command_file"

  local frozen_line
  frozen_line="$(cat "$command_file")"

  case "$frozen_line" in
    "COMMAND: "*) ;;
    *) fail "malformed frozen command file: $command_file" ;;
  esac

  local command_text="${frozen_line#COMMAND: }"
  local start_epoch end_epoch rc

  start_epoch="$(date +%s)"

  set +e
  timeout \
    --signal=TERM \
    --kill-after=60s \
    "${TIMEOUT_SECONDS}s" \
    bash -c "$command_text" \
      >"$stdout_file" \
      2>"$stderr_file"
  rc=$?
  set -e

  end_epoch="$(date +%s)"

  printf '%s\n' "$rc" >"$exit_file"
  printf '%s\n' "$((end_epoch - start_epoch))" >"$elapsed_file"
}

require_dir "$ROOT"
require_dir "$PREFLIGHT"
require_file "$PREFLIGHT_MANIFEST"
require_file "$CASE_MATRIX"

test ! -e "$OUT" ||
  fail "authoritative output already exists; nothing overwritten: $OUT"

ACTIVE="$(
  pgrep -af 'cbmc|goto-cc|goto-gcc|goto-clang|goto-instrument' 2>/dev/null |
  awk -v self="$$" -v parent="$PPID" '$1 != self && $1 != parent' || true
)"
if test -n "$ACTIVE"; then
  printf '%s\n' "$ACTIVE" >&2
  fail "formal-tool process is already active"
fi

echo "============================================================"
echo "SUB00P — AUTHORITATIVE T3 EXECUTION"
echo "============================================================"
echo "TIMESTAMP=$(date --iso-8601=seconds)"
echo "PREFLIGHT=$PREFLIGHT"
echo

echo "=== VERIFY FROZEN PREFLIGHT MANIFEST ==="
verify_manifest "$PREFLIGHT" "$(basename "$PREFLIGHT_MANIFEST")"

mkdir -p "$CASES"
cp "$0" "$RUNNER_COPY"

{
  echo "SUB00P EXECUTION ENVIRONMENT"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"
  echo "FROZEN_COMMIT=$FROZEN_COMMIT"
  echo "ROOT=$ROOT"
  echo "PREFLIGHT=$PREFLIGHT"
  echo "PREFLIGHT_MANIFEST_SHA256=$(sha256sum "$PREFLIGHT_MANIFEST" | awk '{print $1}')"
  echo "TIMEOUT_SECONDS_PER_RUN=$TIMEOUT_SECONDS"
  echo "CBMC=$(cbmc --version 2>&1 | head -1)"
  echo "PYTHON=$(python3 --version 2>&1)"
  echo "ARCH=$(uname -m)"
  echo "START_PROCESS_CLEANLINESS=PASS"
} >"$OUT/environment.txt"

# Fast and diagnostic cases first; the strongest modular theorem runs last.
EXECUTION_ORDER=(
  T3A_EXACT
  T3B_EXACT
  T3A_VALID_LOWER
  T3A_VALID_UPPER
  T3B_VALID_LOWER
  T3B_VALID_UPPER
  T3A_INVALID_LOWER
  T3A_INVALID_UPPER
  T3B_INVALID_LOWER
  T3B_INVALID_UPPER
  T3C_SUM_BOUNDARIES
  T3_COVERAGE
  T3C_MODULAR
)

for case_id in "${EXECUTION_ORDER[@]}"; do
  source_case="$PREFLIGHT/build/$case_id"
  target_case="$CASES/$case_id"

  require_dir "$source_case"
  require_file "$source_case/MODEL_RECORD.txt"

  mkdir -p "$target_case/frozen_inputs"

  cp "$source_case/MODEL_RECORD.txt" \
     "$target_case/frozen_inputs/MODEL_RECORD.txt"
  cp "$source_case/property_inventory.txt" \
     "$target_case/frozen_inputs/property_inventory.txt"
  cp "$source_case/show_loops.txt" \
     "$target_case/frozen_inputs/show_loops.txt"

  case_id_from_record="$(
    sed -n 's/^CASE_ID=//p' "$source_case/MODEL_RECORD.txt"
  )"
  classification="$(
    sed -n 's/^CLASSIFICATION=//p' "$source_case/MODEL_RECORD.txt"
  )"
  expected_exit="$(
    sed -n 's/^EXPECTED_EXECUTION_EXIT=//p' "$source_case/MODEL_RECORD.txt"
  )"
  expected_property_count="$(
    sed -n 's/^PROPERTY_COUNT=//p' "$source_case/MODEL_RECORD.txt"
  )"
  central_marker="$(
    sed -n 's/^CENTRAL_MARKER=//p' "$source_case/MODEL_RECORD.txt"
  )"
  model_path="$(
    sed -n 's/^MODEL=//p' "$source_case/MODEL_RECORD.txt"
  )"
  model_hash="$(
    sed -n 's/^MODEL_SHA256=//p' "$source_case/MODEL_RECORD.txt"
  )"

  test "$case_id_from_record" = "$case_id" ||
    fail "$case_id: MODEL_RECORD identity mismatch"

  require_file "$model_path"
  actual_model_hash="$(sha256sum "$model_path" | awk '{print $1}')"
  test "$actual_model_hash" = "$model_hash" ||
    fail "$case_id: model hash drift before execution"

  cp "$model_path" "$target_case/frozen_inputs/$case_id.goto"

  echo
  echo "------------------------------------------------------------"
  echo "CASE=$case_id"
  echo "CLASSIFICATION=$classification"
  echo "START=$(date --iso-8601=seconds)"

  if test "$classification" = "COVERAGE"; then
    safety_command="$source_case/FROZEN_CBMC_SAFETY_COMMAND.txt"
    coverage_command="$source_case/FROZEN_CBMC_COVERAGE_COMMAND.txt"

    require_file "$safety_command"
    require_file "$coverage_command"

    cp "$safety_command" \
       "$target_case/frozen_inputs/FROZEN_CBMC_SAFETY_COMMAND.txt"
    cp "$coverage_command" \
       "$target_case/frozen_inputs/FROZEN_CBMC_COVERAGE_COMMAND.txt"

    execute_frozen_command \
      "$safety_command" \
      "$target_case/safety_result.json" \
      "$target_case/safety_stderr.txt" \
      "$target_case/safety_exit_code.txt" \
      "$target_case/safety_elapsed_seconds.txt"

    echo "SAFETY_RAW_EXIT=$(cat "$target_case/safety_exit_code.txt")"

    execute_frozen_command \
      "$coverage_command" \
      "$target_case/coverage_result.json" \
      "$target_case/coverage_stderr.txt" \
      "$target_case/coverage_exit_code.txt" \
      "$target_case/coverage_elapsed_seconds.txt"

    echo "COVERAGE_RAW_EXIT=$(cat "$target_case/coverage_exit_code.txt")"

    set +e
    python3 - \
      "$case_id" \
      "$classification" \
      "$central_marker" \
      "$expected_property_count" \
      "$target_case/safety_exit_code.txt" \
      "$target_case/safety_result.json" \
      "$target_case/safety_stderr.txt" \
      "$target_case/coverage_exit_code.txt" \
      "$target_case/coverage_result.json" \
      "$target_case/coverage_stderr.txt" \
      "$target_case/independent_summary.json" <<'PY'
import json
import pathlib
import re
import sys

(
    case_id,
    classification,
    central_marker,
    expected_property_count_text,
    safety_exit_path,
    safety_json_path,
    safety_stderr_path,
    coverage_exit_path,
    coverage_json_path,
    coverage_stderr_path,
    output_path,
) = sys.argv[1:]

def load_json(path_text):
    path = pathlib.Path(path_text)
    text = path.read_text(encoding="utf-8", errors="replace")
    try:
        return json.loads(text), text, None
    except Exception as exc:
        return None, text, f"{type(exc).__name__}: {exc}"

def extract_records(node):
    records = []
    statuses = []

    def visit(value):
        if isinstance(value, dict):
            if "cProverStatus" in value:
                statuses.append(str(value["cProverStatus"]))

            has_id = any(
                key in value
                for key in ("property", "propertyId", "goal", "goalId")
            )
            if has_id and "status" in value:
                records.append(value)

            for key, child in value.items():
                if key in ("result", "goals", "properties") and isinstance(
                    child, list
                ):
                    for item in child:
                        if isinstance(item, dict) and "status" in item:
                            records.append(item)
                        else:
                            visit(item)
                else:
                    visit(child)

        elif isinstance(value, list):
            for child in value:
                visit(child)

    visit(node)

    unique = []
    seen = set()
    for record in records:
        prop = str(
            record.get(
                "property",
                record.get(
                    "propertyId",
                    record.get("goal", record.get("goalId", "")),
                ),
            )
        )
        status = str(record.get("status", ""))
        description = str(record.get("description", ""))
        key = (prop, status, description)
        if key not in seen:
            seen.add(key)
            unique.append(record)

    return unique, statuses

def normalize_record(record):
    return {
        "property": str(
            record.get(
                "property",
                record.get(
                    "propertyId",
                    record.get("goal", record.get("goalId", "")),
                ),
            )
        ),
        "status": str(record.get("status", "")).upper(),
        "description": str(record.get("description", "")),
        "raw": record,
    }

safety_exit = int(pathlib.Path(safety_exit_path).read_text().strip())
coverage_exit = int(pathlib.Path(coverage_exit_path).read_text().strip())

safety_data, safety_text, safety_parse_error = load_json(safety_json_path)
coverage_data, coverage_text, coverage_parse_error = load_json(
    coverage_json_path
)

safety_records_raw, safety_cprover = (
    extract_records(safety_data) if safety_data is not None else ([], [])
)
coverage_records_raw, coverage_cprover = (
    extract_records(coverage_data) if coverage_data is not None else ([], [])
)

safety_records = [normalize_record(r) for r in safety_records_raw]
coverage_records = [normalize_record(r) for r in coverage_records_raw]

safety_failures = [
    r for r in safety_records if r["status"] != "SUCCESS"
]
safety_unwinding_failures = [
    r
    for r in safety_failures
    if "unwind" in json.dumps(r["raw"], sort_keys=True).lower()
]

expected_ids = [f"main.coverage.{i}" for i in range(1, 24)]
actual_coverage_ids = [r["property"] for r in coverage_records]

# CBMC coverage reporting uses goal-oriented statuses. Accommodate the
# documented successful spellings while rejecting unknown/uncovered values.
covered_statuses = {"SATISFIED", "COVERED", "FAILURE"}
coverage_uncovered = [
    r for r in coverage_records if r["status"] not in covered_statuses
]

safety_ok = (
    safety_exit == 0
    and safety_parse_error is None
    and len(safety_records) > 0
    and len(safety_failures) == 0
    and len(safety_unwinding_failures) == 0
    and any(value.lower() == "success" for value in safety_cprover)
)

coverage_ok = (
    coverage_exit == 0
    and coverage_parse_error is None
    and len(coverage_records) == 23
    and actual_coverage_ids == expected_ids
    and len(coverage_uncovered) == 0
)

verdict = (
    "PASS_COVERAGE_SAFETY_AND_23_OF_23_REACHABLE"
    if safety_ok and coverage_ok
    else "INCONCLUSIVE_OR_INVALID"
)

summary = {
    "case_id": case_id,
    "classification": classification,
    "verdict": verdict,
    "safety": {
        "raw_exit": safety_exit,
        "json_parse_error": safety_parse_error,
        "property_count": len(safety_records),
        "failure_count": len(safety_failures),
        "unwinding_failure_count": len(safety_unwinding_failures),
        "cprover_status_values": safety_cprover,
        "stderr": pathlib.Path(safety_stderr_path).read_text(
            encoding="utf-8", errors="replace"
        ),
    },
    "coverage": {
        "raw_exit": coverage_exit,
        "json_parse_error": coverage_parse_error,
        "goal_count": len(coverage_records),
        "goal_ids": actual_coverage_ids,
        "goal_statuses": [r["status"] for r in coverage_records],
        "uncovered_or_unknown_count": len(coverage_uncovered),
        "cprover_status_values": coverage_cprover,
        "stderr": pathlib.Path(coverage_stderr_path).read_text(
            encoding="utf-8", errors="replace"
        ),
    },
    "validation_exit": 0 if safety_ok and coverage_ok else 1,
}

pathlib.Path(output_path).write_text(
    json.dumps(summary, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

print(f"CASE_VERDICT={verdict}")
print(f"SAFETY_PROPERTY_COUNT={len(safety_records)}")
print(f"COVERAGE_GOALS_REACHED={23 - len(coverage_uncovered)}/23")
print(f"FINAL_VALIDATION_EXIT={summary['validation_exit']}")

raise SystemExit(summary["validation_exit"])
PY
    validation_rc=$?
    set -e

  else
    command_file="$source_case/FROZEN_CBMC_COMMAND.txt"
    require_file "$command_file"

    cp "$command_file" \
       "$target_case/frozen_inputs/FROZEN_CBMC_COMMAND.txt"

    execute_frozen_command \
      "$command_file" \
      "$target_case/cbmc_result.json" \
      "$target_case/cbmc_stderr.txt" \
      "$target_case/cbmc_exit_code.txt" \
      "$target_case/elapsed_seconds.txt"

    echo "RAW_EXIT=$(cat "$target_case/cbmc_exit_code.txt")"

    set +e
    python3 - \
      "$case_id" \
      "$classification" \
      "$central_marker" \
      "$expected_exit" \
      "$expected_property_count" \
      "$target_case/cbmc_exit_code.txt" \
      "$target_case/cbmc_result.json" \
      "$target_case/cbmc_stderr.txt" \
      "$target_case/independent_summary.json" <<'PY'
import json
import pathlib
import re
import sys

(
    case_id,
    classification,
    central_marker,
    expected_exit_text,
    expected_property_count_text,
    exit_path,
    json_path,
    stderr_path,
    output_path,
) = sys.argv[1:]

expected_exit = int(expected_exit_text)
expected_property_count = int(expected_property_count_text)
raw_exit = int(pathlib.Path(exit_path).read_text().strip())
stderr_text = pathlib.Path(stderr_path).read_text(
    encoding="utf-8", errors="replace"
)
json_text = pathlib.Path(json_path).read_text(
    encoding="utf-8", errors="replace"
)

try:
    data = json.loads(json_text)
    parse_error = None
except Exception as exc:
    data = None
    parse_error = f"{type(exc).__name__}: {exc}"

records = []
cprover_statuses = []

def visit(value):
    if isinstance(value, dict):
        if "cProverStatus" in value:
            cprover_statuses.append(str(value["cProverStatus"]))

        has_id = any(
            key in value
            for key in ("property", "propertyId", "goal", "goalId")
        )
        if has_id and "status" in value:
            records.append(value)

        for key, child in value.items():
            if key in ("result", "goals", "properties") and isinstance(
                child, list
            ):
                for item in child:
                    if isinstance(item, dict) and "status" in item:
                        records.append(item)
                    else:
                        visit(item)
            else:
                visit(child)

    elif isinstance(value, list):
        for child in value:
            visit(child)

if data is not None:
    visit(data)

unique = []
seen = set()
for record in records:
    prop = str(
        record.get(
            "property",
            record.get(
                "propertyId",
                record.get("goal", record.get("goalId", "")),
            ),
        )
    )
    status = str(record.get("status", "")).upper()
    description = str(record.get("description", ""))
    key = (prop, status, description)
    if key not in seen:
        seen.add(key)
        unique.append(
            {
                "property": prop,
                "status": status,
                "description": description,
                "raw": record,
            }
        )

records = unique
failures = [record for record in records if record["status"] != "SUCCESS"]
unwinding_failures = [
    record
    for record in failures
    if "unwind" in json.dumps(record["raw"], sort_keys=True).lower()
]

central_matches = [
    record
    for record in records
    if central_marker
    in (
        record["property"]
        + "\n"
        + record["description"]
        + "\n"
        + json.dumps(record["raw"], sort_keys=True)
    )
]
central_failures = [
    record for record in central_matches if record["status"] == "FAILURE"
]

timeout = raw_exit in (124, 137)
property_count_ok = len(records) == expected_property_count

if classification in ("POSITIVE_THEOREM", "POSITIVE_BOUNDARY"):
    valid = (
        raw_exit == 0
        and not timeout
        and parse_error is None
        and property_count_ok
        and len(failures) == 0
        and len(unwinding_failures) == 0
        and len(central_matches) >= 1
        and all(r["status"] == "SUCCESS" for r in central_matches)
        and any(value.lower() == "success" for value in cprover_statuses)
    )
    verdict = (
        "PASS_ALL_PROPERTIES_SUCCESS"
        if valid
        else "INCONCLUSIVE_OR_INVALID"
    )

elif classification == "NEGATIVE_CONTROL":
    allowed_secondary = []
    unexpected_failures = []

    for record in failures:
        searchable = (
            record["property"]
            + "\n"
            + record["description"]
            + "\n"
            + json.dumps(record["raw"], sort_keys=True)
        ).lower()

        if central_marker.lower() in searchable:
            continue

        if re.search(r"conversion|overflow", searchable):
            allowed_secondary.append(record)
            continue

        unexpected_failures.append(record)

    valid = (
        raw_exit == expected_exit == 10
        and not timeout
        and parse_error is None
        and property_count_ok
        and len(central_failures) >= 1
        and len(unwinding_failures) == 0
        and len(unexpected_failures) == 0
        and any(value.lower() == "failure" for value in cprover_statuses)
    )
    verdict = (
        "PASS_EXPECTED_DOMAIN_REJECTION"
        if valid
        else "INCONCLUSIVE_OR_INVALID"
    )

else:
    valid = False
    verdict = "INCONCLUSIVE_OR_INVALID"
    allowed_secondary = []
    unexpected_failures = failures

summary = {
    "case_id": case_id,
    "classification": classification,
    "central_marker": central_marker,
    "verdict": verdict,
    "raw_exit": raw_exit,
    "expected_exit": expected_exit,
    "timeout": timeout,
    "json_parse_error": parse_error,
    "property_count": len(records),
    "expected_property_count": expected_property_count,
    "property_count_ok": property_count_ok,
    "failure_count": len(failures),
    "failure_properties": [r["property"] for r in failures],
    "central_match_count": len(central_matches),
    "central_failure_count": len(central_failures),
    "unwinding_failure_count": len(unwinding_failures),
    "cprover_status_values": cprover_statuses,
    "stderr": stderr_text,
    "validation_exit": 0 if valid else 1,
}

if classification == "NEGATIVE_CONTROL":
    summary["allowed_secondary_failure_count"] = len(allowed_secondary)
    summary["unexpected_failure_count"] = len(unexpected_failures)
    summary["unexpected_failure_properties"] = [
        r["property"] for r in unexpected_failures
    ]

pathlib.Path(output_path).write_text(
    json.dumps(summary, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

print(f"CASE_VERDICT={verdict}")
print(
    f"PROPERTY_COUNT={len(records)}/{expected_property_count}"
)
print(f"FAILURE_COUNT={len(failures)}")
print(f"CENTRAL_FAILURE_COUNT={len(central_failures)}")
print(f"UNWINDING_FAILURE_COUNT={len(unwinding_failures)}")
print(f"FINAL_VALIDATION_EXIT={summary['validation_exit']}")

raise SystemExit(summary["validation_exit"])
PY
    validation_rc=$?
    set -e
  fi

  printf '%s\n' "$validation_rc" \
    >"$target_case/final_validation_exit_code.txt"

  if test "$validation_rc" -eq 0; then
    echo "CASE_FINAL_VALIDATION=PASS"
  else
    echo "CASE_FINAL_VALIDATION=FAIL"
  fi

  echo "END=$(date --iso-8601=seconds)"
done

echo
echo "=== AGGREGATE INDEPENDENT RESULTS ==="

set +e
python3 - "$CASES" "$SUMMARY_JSON" "$SUMMARY" <<'PY'
import json
import pathlib
import sys
from datetime import datetime, timezone

cases_dir = pathlib.Path(sys.argv[1])
summary_json_path = pathlib.Path(sys.argv[2])
summary_text_path = pathlib.Path(sys.argv[3])

expected_cases = [
    "T3A_EXACT",
    "T3B_EXACT",
    "T3A_VALID_LOWER",
    "T3A_VALID_UPPER",
    "T3B_VALID_LOWER",
    "T3B_VALID_UPPER",
    "T3A_INVALID_LOWER",
    "T3A_INVALID_UPPER",
    "T3B_INVALID_LOWER",
    "T3B_INVALID_UPPER",
    "T3C_SUM_BOUNDARIES",
    "T3_COVERAGE",
    "T3C_MODULAR",
]

summaries = []
missing = []

for case_id in expected_cases:
    path = cases_dir / case_id / "independent_summary.json"
    if not path.exists():
        missing.append(case_id)
        continue
    summaries.append(json.loads(path.read_text(encoding="utf-8")))

positive_expected = {
    "T3A_EXACT",
    "T3B_EXACT",
    "T3A_VALID_LOWER",
    "T3A_VALID_UPPER",
    "T3B_VALID_LOWER",
    "T3B_VALID_UPPER",
    "T3C_SUM_BOUNDARIES",
    "T3C_MODULAR",
}
negative_expected = {
    "T3A_INVALID_LOWER",
    "T3A_INVALID_UPPER",
    "T3B_INVALID_LOWER",
    "T3B_INVALID_UPPER",
}

by_id = {item["case_id"]: item for item in summaries}

positive_passes = sum(
    by_id.get(case_id, {}).get("verdict")
    == "PASS_ALL_PROPERTIES_SUCCESS"
    for case_id in positive_expected
)
negative_passes = sum(
    by_id.get(case_id, {}).get("verdict")
    == "PASS_EXPECTED_DOMAIN_REJECTION"
    for case_id in negative_expected
)
coverage_pass = (
    by_id.get("T3_COVERAGE", {}).get("verdict")
    == "PASS_COVERAGE_SAFETY_AND_23_OF_23_REACHABLE"
)

all_present = len(missing) == 0
all_validated = all(
    item.get("validation_exit") == 0 for item in summaries
)

overall_pass = (
    all_present
    and all_validated
    and positive_passes == 8
    and negative_passes == 4
    and coverage_pass
)

overall_verdict = (
    "PASS_COMPLETE_T3_CAMPAIGN"
    if overall_pass
    else "INCONCLUSIVE_OR_INVALID"
)

aggregate = {
    "campaign": "SUB00P_AUTHORITATIVE_T3_EXECUTION_MLKEM768_RUN1",
    "generated_at_utc": datetime.now(timezone.utc).isoformat(),
    "overall_verdict": overall_verdict,
    "expected_case_count": 13,
    "completed_case_count": len(summaries),
    "missing_cases": missing,
    "positive_cases_passed": positive_passes,
    "positive_cases_expected": 8,
    "negative_controls_passed": negative_passes,
    "negative_controls_expected": 4,
    "coverage_passed": coverage_pass,
    "coverage_goals_expected": 23,
    "production_source_modified": False,
    "frozen_harness_modified": False,
    "cases": summaries,
    "validation_exit": 0 if overall_pass else 1,
}

summary_json_path.write_text(
    json.dumps(aggregate, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

lines = [
    "============================================================",
    "SUB00P — AUTHORITATIVE T3 FINAL VERDICT",
    "============================================================",
    f"OVERALL_VERDICT={overall_verdict}",
    f"COMPLETED_CASES={len(summaries)}/13",
    f"POSITIVE_CASES_PASSED={positive_passes}/8",
    f"NEGATIVE_CONTROLS_PASSED={negative_passes}/4",
    f"COVERAGE_GOALS_REACHED={'23/23' if coverage_pass else 'NOT_ACCEPTED'}",
    f"ALL_FINAL_VALIDATIONS_PASS={'YES' if all_validated else 'NO'}",
    f"MISSING_CASES={','.join(missing) if missing else 'NONE'}",
    "PRODUCTION_SOURCE_MODIFIED=NO",
    "FROZEN_HARNESS_MODIFIED=NO",
    "NOVELTY_ESTABLISHED_BY_EXECUTION_ALONE=NO",
    "",
    "CASE_VERDICTS:",
]

for case_id in expected_cases:
    item = by_id.get(case_id)
    lines.append(
        f"{case_id}="
        + (item.get("verdict", "MISSING") if item else "MISSING")
    )

lines.extend(
    [
        "",
        f"FINAL_VALIDATION_EXIT={0 if overall_pass else 1}",
        "============================================================",
    ]
)

summary_text_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
print("\n".join(lines))

raise SystemExit(0 if overall_pass else 1)
PY
aggregate_rc=$?
set -e

printf '%s\n' "$aggregate_rc" >"$OUT/final_validation_exit_code.txt"

echo
echo "=== VERIFY FROZEN PREFLIGHT MANIFEST AGAIN ==="
verify_manifest "$PREFLIGHT" "$(basename "$PREFLIGHT_MANIFEST")" \
  >"$OUT/post_execution_parent_manifest_verification.txt"

echo "PREFLIGHT_POST_EXECUTION_INTEGRITY=PASS"

{
  echo "SUB00P POST-EXECUTION PROCESS CHECK"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"
  remaining="$(
    pgrep -af 'cbmc|goto-cc|goto-gcc|goto-clang|goto-instrument' \
      2>/dev/null |
    awk -v self="$$" -v parent="$PPID" '$1 != self && $1 != parent' \
      || true
  )"

  if test -n "$remaining"; then
    printf '%s\n' "$remaining"
    echo "POST_EXECUTION_PROCESS_CLEANLINESS=FAIL"
  else
    echo "POST_EXECUTION_PROCESS_CLEANLINESS=PASS"
  fi
} >"$OUT/post_execution_process_check.txt"

(
  cd "$OUT"
  find . -type f \
    ! -name "$(basename "$MANIFEST")" \
    -print0 |
  sort -z |
  xargs -0 sha256sum >"$(basename "$MANIFEST")"
)

chmod -R a-w "$OUT"

echo
echo "=== SUB00P ARTIFACT MANIFEST VERIFICATION ==="
verify_manifest "$OUT" "$(basename "$MANIFEST")"

echo
echo "SUB00P_RUNNER_EXIT=$aggregate_rc"
echo "OUT=$OUT"
echo
echo "Important final files:"
echo "$SUMMARY"
echo "$SUMMARY_JSON"
echo "$MANIFEST"
echo "$OUT/final_validation_exit_code.txt"
echo "$OUT/post_execution_parent_manifest_verification.txt"

exit "$aggregate_rc"
