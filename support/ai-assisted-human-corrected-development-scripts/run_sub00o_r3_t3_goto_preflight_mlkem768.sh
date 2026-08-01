#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
SRC="$ROOT/source"
POLY_C="$SRC/mlkem/src/poly.c"

T3FREEZE="$ROOT/SUB00N_BATCH3_T3_HARNESS_FREEZE_V1"
T3_HARNESS_DIR="$T3FREEZE/harnesses"
T3_MANIFEST="$T3FREEZE/SUB00N_ARTIFACT_MANIFEST.sha256"

DISCOVERY="$ROOT/SUB00O_BATCH3_T3_GOTO_PREFLIGHT_DISCOVERY"
DISCOVERY_MANIFEST="$DISCOVERY/SUB00O_DISCOVERY_MANIFEST.sha256"

T2_RUN="$ROOT/SUB00L_COMBINED_T2_BOUNDARY_EXECUTION_MLKEM768_RUN1"
SOURCE_ZEROIZE="$ROOT/sub00f_mode_a_execution_freeze_v1/adapter/sub00e_r1_fail_closed_zeroize.h"
SOURCE_PRAGMA="$T2_RUN/adapters/sub00l_verify_pragma_scope.h"
SOURCE_OPTBLOCKER="$T2_RUN/adapters/sub00l_optblocker_zero.c"

OUT="$ROOT/SUB00O_R3_BATCH3_T3_GOTO_PREFLIGHT_MLKEM768_V1"
BUILD="$OUT/build"
ADAPTERS="$OUT/adapters"
SUMMARY="$OUT/SUB00O_R3_PREFLIGHT_SUMMARY.txt"
CASE_MATRIX="$OUT/CASE_MATRIX.tsv"
MANIFEST="$OUT/SUB00O_R3_ARTIFACT_MANIFEST.sha256"

fail() {
  echo "SUB00O_R3_PREFLIGHT_STATUS=FAIL" >&2
  echo "REASON=$*" >&2
  exit 1
}

write_command() {
  local output="$1"
  shift
  {
    printf 'COMMAND:'
    printf ' %q' "$@"
    printf '\n'
  } > "$output"
}

require_file() {
  test -f "$1" || fail "required file missing: $1"
}

require_dir() {
  test -d "$1" || fail "required directory missing: $1"
}

require_dir "$ROOT"
require_dir "$SRC/mlkem/src"
require_file "$POLY_C"
require_dir "$T3FREEZE"
require_dir "$T3_HARNESS_DIR"
require_file "$T3_MANIFEST"
require_dir "$DISCOVERY"
require_file "$DISCOVERY_MANIFEST"
require_file "$SOURCE_ZEROIZE"
require_file "$SOURCE_PRAGMA"
require_file "$SOURCE_OPTBLOCKER"

test ! -e "$OUT" ||
  fail "output already exists; nothing overwritten: $OUT"

ACTIVE="$(
  pgrep -af 'cbmc|goto-cc|goto-gcc|goto-clang|goto-instrument' 2>/dev/null |
  awk -v self="$$" -v parent="$PPID" '$1 != self && $1 != parent' || true
)"
if test -n "$ACTIVE"; then
  printf '%s\n' "$ACTIVE" >&2
  fail "formal-tool process is active"
fi

echo "=== VERIFY SUB00N FREEZE MANIFEST ==="
(
  cd "$T3FREEZE"
  sha256sum -c "$(basename "$T3_MANIFEST")"
)

echo
echo "=== VERIFY SUB00O DISCOVERY MANIFEST ==="
(
  cd "$DISCOVERY"
  sha256sum -c "$(basename "$DISCOVERY_MANIFEST")"
)

mkdir -p "$BUILD" "$ADAPTERS"

cp "$SOURCE_ZEROIZE" "$ADAPTERS/sub00o_r2_fail_closed_zeroize.h"
cp "$SOURCE_PRAGMA" "$ADAPTERS/sub00o_r2_verify_pragma_scope.h"
cp "$SOURCE_OPTBLOCKER" "$ADAPTERS/sub00o_r2_optblocker_zero.c"

chmod a-w "$ADAPTERS"/*

ZEROIZE="$ADAPTERS/sub00o_r2_fail_closed_zeroize.h"
PRAGMA="$ADAPTERS/sub00o_r2_verify_pragma_scope.h"
OPTBLOCKER="$ADAPTERS/sub00o_r2_optblocker_zero.c"

cat > "$CASE_MATRIX" <<'EOF'
case_id	harness	namespace	classification	required_calls	central_marker
T3A_EXACT	sub_t3a_exact_sub_add_harness.c	mlk_sub00o_t3a	POSITIVE_THEOREM	add,sub	SUB_T3A_CANCELLATION
T3B_EXACT	sub_t3b_exact_add_sub_harness.c	mlk_sub00o_t3b	POSITIVE_THEOREM	add,sub	SUB_T3B_CANCELLATION
T3C_MODULAR	sub_t3c_modular_cancellation_harness.c	mlk_sub00o_t3c	POSITIVE_THEOREM	add,sub,reduce	SUB_T3C_CANCELLATION
T3_COVERAGE	sub_t3_coverage_harness.c	mlk_sub00o_cov	COVERAGE	sub,reduce	__CPROVER_cover
T3A_VALID_LOWER	sub_t3a_valid_lower_harness.c	mlk_sub00o_a_vl	POSITIVE_BOUNDARY	add,sub	SUB_T3A_VALID_LOWER
T3A_VALID_UPPER	sub_t3a_valid_upper_harness.c	mlk_sub00o_a_vu	POSITIVE_BOUNDARY	add,sub	SUB_T3A_VALID_UPPER
T3A_INVALID_LOWER	sub_t3a_invalid_lower_harness.c	mlk_sub00o_a_il	NEGATIVE_CONTROL	sub	SUB_T3A_INVALID_LOWER_CONTROL
T3A_INVALID_UPPER	sub_t3a_invalid_upper_harness.c	mlk_sub00o_a_iu	NEGATIVE_CONTROL	sub	SUB_T3A_INVALID_UPPER_CONTROL
T3B_VALID_LOWER	sub_t3b_valid_lower_harness.c	mlk_sub00o_b_vl	POSITIVE_BOUNDARY	add,sub	SUB_T3B_VALID_LOWER
T3B_VALID_UPPER	sub_t3b_valid_upper_harness.c	mlk_sub00o_b_vu	POSITIVE_BOUNDARY	add,sub	SUB_T3B_VALID_UPPER
T3B_INVALID_LOWER	sub_t3b_invalid_lower_harness.c	mlk_sub00o_b_il	NEGATIVE_CONTROL	add	SUB_T3B_INVALID_LOWER_CONTROL
T3B_INVALID_UPPER	sub_t3b_invalid_upper_harness.c	mlk_sub00o_b_iu	NEGATIVE_CONTROL	add	SUB_T3B_INVALID_UPPER_CONTROL
T3C_SUM_BOUNDARIES	sub_t3c_recovery_sum_boundaries_harness.c	mlk_sub00o_c_bound	POSITIVE_BOUNDARY	add,sub,reduce	SUB_T3C_BOUNDARY
EOF

COMMON_FLAGS=(
  -std=c90
  -DMLK_CONFIG_PARAMETER_SET=768
  -DMLK_CONFIG_NO_ASM=1
  -DMLK_CONFIG_CUSTOM_ZEROIZE=1
  -include "$ZEROIZE"
  -include "$PRAGMA"
  -I"$T3_HARNESS_DIR"
  -I"$SRC/mlkem"
  -I"$SRC/mlkem/src"
)

SAFETY_FLAGS=(
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
)

case_count=0

while IFS=$'\t' read -r case_id harness_name namespace classification required_calls central_marker; do
  if test "$case_id" = "case_id"; then
    continue
  fi

  case_count=$((case_count + 1))

  harness="$T3_HARNESS_DIR/$harness_name"
  require_file "$harness"

  case_dir="$BUILD/$case_id"
  mkdir -p "$case_dir/frozen_inputs"

  model="$case_dir/$case_id.goto"
  reachable="$case_dir/${case_id}_reachable_only.goto"

  build_command=(
    goto-cc
    "${COMMON_FLAGS[@]}"
    -DMLK_CONFIG_NAMESPACE_PREFIX="$namespace"
    "$harness"
    "$POLY_C"
    "$OPTBLOCKER"
    -o "$model"
  )

  write_command "$case_dir/goto_build_command.txt" "${build_command[@]}"

  set +e
  "${build_command[@]}" \
    >"$case_dir/goto_build_stdout.txt" \
    2>"$case_dir/goto_build_stderr.txt"
  build_rc=$?
  set -e
  printf '%s\n' "$build_rc" > "$case_dir/goto_build_exit_code.txt"
  test "$build_rc" -eq 0 ||
    fail "$case_id: goto-cc failed with exit $build_rc"

  require_file "$model"

  validated_original="$case_dir/${case_id}_validated.goto"
  validate_command=(
    goto-instrument
    --validate-goto-model
    "$model"
    "$validated_original"
  )
  write_command "$case_dir/validate_original_command.txt" "${validate_command[@]}"
  "${validate_command[@]}" \
    >"$case_dir/validate_original.txt" 2>&1
  require_file "$validated_original"

  drop_command=(
    goto-instrument
    --drop-unused-functions
    "$model"
    "$reachable"
  )
  write_command "$case_dir/drop_unused_functions_command.txt" "${drop_command[@]}"
  "${drop_command[@]}" \
    >"$case_dir/drop_unused_functions.txt" 2>&1

  require_file "$reachable"

  validated_reachable="$case_dir/${case_id}_reachable_validated.goto"
  validate_reachable_command=(
    goto-instrument
    --validate-goto-model
    "$reachable"
    "$validated_reachable"
  )
  write_command \
    "$case_dir/validate_reachable_command.txt" \
    "${validate_reachable_command[@]}"
  "${validate_reachable_command[@]}" \
    >"$case_dir/validate_reachable.txt" 2>&1
  require_file "$validated_reachable"

  list_functions_command=(
    goto-instrument
    --list-goto-functions
    "$reachable"
  )
  write_command \
    "$case_dir/list_goto_functions_command.txt" \
    "${list_functions_command[@]}"
  "${list_functions_command[@]}" \
    >"$case_dir/reachable_functions.txt" 2>&1

  call_sequences_command=(
    goto-instrument
    --show-call-sequences
    "$reachable"
  )
  write_command \
    "$case_dir/show_call_sequences_command.txt" \
    "${call_sequences_command[@]}"
  "${call_sequences_command[@]}" \
    >"$case_dir/reachable_call_sequences.txt" 2>&1 || true

  show_loops_command=(
    goto-instrument
    --show-loops
    "$reachable"
  )
  write_command "$case_dir/show_loops_command.txt" "${show_loops_command[@]}"
  "${show_loops_command[@]}" \
    >"$case_dir/show_loops.txt" 2>&1

  show_properties_command=(
    cbmc
    "$reachable"
    --function main
    --show-properties
  )
  write_command \
    "$case_dir/show_properties_command.txt" \
    "${show_properties_command[@]}"
  "${show_properties_command[@]}" \
    >"$case_dir/property_inventory.txt" 2>&1

  grep -qF "$central_marker" "$case_dir/property_inventory.txt" ||
    fail "$case_id: central marker absent from property inventory: $central_marker"

  IFS=',' read -r -a calls <<< "$required_calls"
  for call_name in "${calls[@]}"; do
    case "$call_name" in
      add)
        grep -qF "${namespace}_poly_add" "$case_dir/reachable_functions.txt" ||
          fail "$case_id: production poly_add body is not reachable"
        ;;
      sub)
        grep -qF "${namespace}_poly_sub" "$case_dir/reachable_functions.txt" ||
          fail "$case_id: production poly_sub body is not reachable"
        ;;
      reduce)
        grep -qF "${namespace}_poly_reduce" "$case_dir/reachable_functions.txt" ||
          fail "$case_id: production poly_reduce entry is not reachable"
        grep -qF "mlk_poly_reduce_c" "$case_dir/reachable_functions.txt" ||
          fail "$case_id: portable poly_reduce_c body is not reachable"
        ;;
      *)
        fail "$case_id: unknown required call token: $call_name"
        ;;
    esac
  done

  python3 - "$case_dir/show_loops.txt" "$namespace" \
    "$case_dir/loop_ids.txt" "$case_dir/unwindset.txt" <<'PY'
import pathlib
import re
import sys

loop_file = pathlib.Path(sys.argv[1])
namespace = sys.argv[2]
ids_out = pathlib.Path(sys.argv[3])
unwind_out = pathlib.Path(sys.argv[4])

text = loop_file.read_text(encoding="utf-8", errors="replace")

loop_ids = []
for line in text.splitlines():
    match = re.match(r"\s*Loop\s+([^:\s]+):?\s*$", line)
    if match:
        loop_ids.append(match.group(1).rstrip(":"))

loop_ids = list(dict.fromkeys(loop_ids))

if not loop_ids:
    raise SystemExit("ERROR: no reachable loop identifiers discovered")

def bound_for(loop_id: str) -> int:
    if re.fullmatch(r"main\.\d+", loop_id):
        return 257

    if re.fullmatch(r"sub_t3_zero_poly\.\d+", loop_id):
        return 257

    if re.fullmatch(re.escape(namespace) + r"_poly_(add|sub)\.\d+", loop_id):
        return 257

    if re.fullmatch(r"mlk_poly_reduce_c\.\d+", loop_id):
        return 257

    if re.fullmatch(r"mlk_barrett_reduce\.\d+", loop_id):
        return 2

    if re.fullmatch(r"mlk_scalar_signed_to_unsigned_q\.\d+", loop_id):
        return 2

    raise SystemExit(
        f"ERROR: unknown reachable loop identifier; no bound invented: {loop_id}"
    )

pairs = [(loop_id, bound_for(loop_id)) for loop_id in loop_ids]

ids_out.write_text(
    "\n".join(loop_id for loop_id, _ in pairs) + "\n",
    encoding="utf-8",
)

unwind_out.write_text(
    ",".join(f"{loop_id}:{bound}" for loop_id, bound in pairs) + "\n",
    encoding="utf-8",
)
PY

  unwindset="$(tr -d '\n' < "$case_dir/unwindset.txt")"
  test -n "$unwindset" ||
    fail "$case_id: generated unwindset is empty"

  if test "$classification" = "COVERAGE"; then
    final_command=(
      cbmc
      "$model"
      "${SAFETY_FLAGS[@]}"
      --unwindset "$unwindset"
      --cover cover
      --sat-solver minisat2
      --trace
      --json-ui
    )
  else
    final_command=(
      cbmc
      "$model"
      "${SAFETY_FLAGS[@]}"
      --unwindset "$unwindset"
      --slice-formula
      --sat-solver minisat2
      --trace
      --json-ui
    )
  fi

  write_command "$case_dir/FROZEN_CBMC_COMMAND.txt" "${final_command[@]}"

  property_count="$(
    grep -c '^Property ' "$case_dir/property_inventory.txt" || true
  )"
  loop_count="$(wc -l < "$case_dir/loop_ids.txt")"

  if test "$classification" = "NEGATIVE_CONTROL"; then
    expected_exit=10
  else
    expected_exit=0
  fi

  {
    echo "CASE_ID=$case_id"
    echo "HARNESS=$harness"
    echo "HARNESS_SHA256=$(sha256sum "$harness" | awk '{print $1}')"
    echo "NAMESPACE=$namespace"
    echo "CLASSIFICATION=$classification"
    echo "CENTRAL_MARKER=$central_marker"
    echo "REQUIRED_CALLS=$required_calls"
    echo "EXPECTED_EXECUTION_EXIT=$expected_exit"
    echo "GOTO_BUILD_EXIT=0"
    echo "MODEL=$model"
    echo "MODEL_SHA256=$(sha256sum "$model" | awk '{print $1}')"
    echo "REACHABLE_MODEL=$reachable"
    echo "REACHABLE_MODEL_SHA256=$(sha256sum "$reachable" | awk '{print $1}')"
    echo "PROPERTY_COUNT=$property_count"
    echo "REACHABLE_LOOP_COUNT=$loop_count"
    echo "EXACT_UNWINDSET=$unwindset"
    echo "MODEL_VALIDATION=PASS"
    echo "CENTRAL_PROPERTY_MARKER_PRESENT=YES"
    echo "PRODUCTION_BODY_REACHABILITY=PASS"
    echo "CBMC_THEOREM_EXECUTED=NO"
  } > "$case_dir/MODEL_RECORD.txt"

  cp "$harness" "$case_dir/frozen_inputs/$harness_name"
  cp "$model" "$case_dir/frozen_inputs/$case_id.goto"
  cp "$reachable" \
    "$case_dir/frozen_inputs/${case_id}_reachable_only.goto"
  cp "$case_dir/FROZEN_CBMC_COMMAND.txt" \
    "$case_dir/frozen_inputs/FROZEN_CBMC_COMMAND.txt"
  cp "$case_dir/MODEL_RECORD.txt" \
    "$case_dir/frozen_inputs/MODEL_RECORD.txt"
  cp "$case_dir/property_inventory.txt" \
    "$case_dir/frozen_inputs/property_inventory.txt"
  cp "$case_dir/show_loops.txt" \
    "$case_dir/frozen_inputs/show_loops.txt"
done < "$CASE_MATRIX"

test "$case_count" -eq 13 ||
  fail "expected 13 cases, processed $case_count"

python3 - "$BUILD" "$OUT/PREFLIGHT_AUDIT.json" <<'PY'
import json
import pathlib
import sys

build = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])

cases = []
for record in sorted(build.glob("*/MODEL_RECORD.txt")):
    values = {}
    for line in record.read_text(encoding="utf-8").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            values[key] = value
    cases.append(values)

if len(cases) != 13:
    raise SystemExit(f"ERROR: expected 13 model records, found {len(cases)}")

positive = sum(
    c.get("CLASSIFICATION") in {"POSITIVE_THEOREM", "POSITIVE_BOUNDARY"}
    for c in cases
)
negative = sum(c.get("CLASSIFICATION") == "NEGATIVE_CONTROL" for c in cases)
coverage = sum(c.get("CLASSIFICATION") == "COVERAGE" for c in cases)

audit = {
    "case_count": len(cases),
    "positive_case_count": positive,
    "negative_control_count": negative,
    "coverage_case_count": coverage,
    "all_builds_passed": all(c.get("GOTO_BUILD_EXIT") == "0" for c in cases),
    "all_models_validated": all(
        c.get("MODEL_VALIDATION") == "PASS" for c in cases
    ),
    "all_central_markers_present": all(
        c.get("CENTRAL_PROPERTY_MARKER_PRESENT") == "YES" for c in cases
    ),
    "all_required_production_bodies_reachable": all(
        c.get("PRODUCTION_BODY_REACHABILITY") == "PASS" for c in cases
    ),
    "cbmc_theorem_executed": False,
    "cases": cases,
}

if positive != 8 or negative != 4 or coverage != 1:
    raise SystemExit(
        "ERROR: classification counts differ from frozen design: "
        f"positive={positive}, negative={negative}, coverage={coverage}"
    )

out.write_text(json.dumps(audit, indent=2) + "\n", encoding="utf-8")
PY

{
  echo "============================================================"
  echo "SUB00O R3 — T3 GOTO PREFLIGHT SUMMARY"
  echo "============================================================"
  echo "TIMESTAMP=$(date --iso-8601=seconds)"
  echo "ROOT=$ROOT"
  echo "OUT=$OUT"
  echo "PARAMETER_SET=768"
  echo "CASE_COUNT=13"
  echo "POSITIVE_CASE_COUNT=8"
  echo "NEGATIVE_CONTROL_COUNT=4"
  echo "COVERAGE_CASE_COUNT=1"
  echo

  echo "=== TOOL IDENTITIES ==="
  echo "CBMC=$(cbmc --version 2>&1 | head -1)"
  echo "GOTO_CC=$(goto-cc --version 2>&1 | head -1)"
  echo "GOTO_INSTRUMENT=$(goto-instrument --version 2>&1 | head -1)"
  echo

  echo "=== ADAPTER IDENTITIES ==="
  sha256sum "$ZEROIZE" "$PRAGMA" "$OPTBLOCKER"
  echo

  echo "=== CASE RECORDS ==="
  for record in "$BUILD"/*/MODEL_RECORD.txt; do
    echo "------------------------------------------------------------"
    cat "$record"
  done
  echo

  echo "=== GLOBAL VERDICT ==="
  echo "SUB00O_R3_PREFLIGHT_STATUS=PASS"
  echo "ALL_13_GOTO_MODELS_BUILT=YES"
  echo "ALL_13_GOTO_MODELS_VALIDATED=YES"
  echo "ALL_CENTRAL_PROPERTY_MARKERS_PRESENT=YES"
  echo "ALL_REQUIRED_PRODUCTION_BODIES_REACHABLE=YES"
  echo "EXACT_LOOP_IDS_FROZEN=YES"
  echo "EXACT_UNWINDSETS_FROZEN=YES"
  echo "FINAL_CBMC_COMMANDS_FROZEN=YES"
  echo "CBMC_THEOREM_EXECUTED=NO"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "SUB00N_HARNESS_MODIFIED=NO"
  echo "NEXT_STAGE=SUB00P_AUTHORITATIVE_T3_EXECUTION"
  echo "============================================================"
} | tee "$SUMMARY"

(
  cd "$OUT"
  find . -type f \
    ! -name "$(basename "$MANIFEST")" \
    -print0 |
  sort -z |
  xargs -0 sha256sum > "$(basename "$MANIFEST")"
)

chmod -R a-w "$OUT"

echo
echo "=== SUB00O R3 MANIFEST VERIFICATION ==="
(
  cd "$OUT"
  sha256sum -c "$(basename "$MANIFEST")"
)

echo
echo "SUB00O_R3_PREFLIGHT_EXIT=0"
echo "OUT=$OUT"
echo
echo "Upload:"
echo "$SUMMARY"
echo "$OUT/PREFLIGHT_AUDIT.json"
echo "$CASE_MATRIX"
echo "$MANIFEST"
