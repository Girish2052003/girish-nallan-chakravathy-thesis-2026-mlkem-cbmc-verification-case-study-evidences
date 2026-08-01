#!/usr/bin/env bash
set -euo pipefail
umask 0022

BASE="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B5="$BASE/SUB00Q_BATCH5_T5_RELATIONAL"
FAMILY="$B5/frozen_harness_family_v1"
SRC="$BASE/source/mlkem"
B54="$B5/B5_4_GOTO_PREFLIGHT_MLKEM768"
BUILD="$B54/build"
COMMANDS="$B54/commands"
LOGS="$B54/logs"
INSPECT="$B54/inspection"
EXITS="$B54/exit_codes"
SUMMARY="$B54/SUB00Q_B5_4_PREFLIGHT_SUMMARY.txt"
FREEZE="$B54/SUB00Q_B5_4_EXECUTION_INPUT_FREEZE.md"
MANIFEST="$B54/SUB00Q_B5_4_PREFLIGHT_ARTIFACT_MANIFEST.sha256"

EXPECTED_POLYC_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_POLYH_SHA="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"

CASES=(
  "positive_frame"
  "positive_locality"
  "positive_noninterference_exact"
  "positive_determinism"
  "reachability_locality"
  "reachability_changed_index"
  "reachability_identical_inputs"
  "expected_failure_off_target"
  "expected_failure_nondeterminism"
)

CLASSES=(
  "positive"
  "positive"
  "positive"
  "positive"
  "reachability"
  "reachability"
  "reachability"
  "expected_failure"
  "expected_failure"
)

HARNESSES=(
  "sub_t5_frame_preservation_harness.c"
  "sub_t5_coefficient_locality_harness.c"
  "sub_t5_noninterference_exact_effect_harness.c"
  "sub_t5_determinism_harness.c"
  "sub_t5_reachability_locality_harness.c"
  "sub_t5_reachability_changed_index_harness.c"
  "sub_t5_reachability_identical_inputs_harness.c"
  "sub_t5_expected_failure_off_target_harness.c"
  "sub_t5_expected_failure_nondeterminism_harness.c"
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
  if [ "$SUCCESS" -ne 1 ] && [ -d "$B54" ]; then
    failed="${B54}_FAILED_$(date -u +%Y%m%dT%H%M%SZ)"
    chmod -R u+rwX "$B54" 2>/dev/null || true
    mv "$B54" "$failed" 2>/dev/null || true
    echo "FAILED_ATTEMPT_PRESERVED=$failed" >&2
  fi
  exit "$rc"
}
trap cleanup EXIT

echo "============================================================"
echo "SUB-T5 / B5.4 GOTO-MODEL CONSTRUCTION AND LOOP PREFLIGHT"
echo "============================================================"

[ -d "$B5" ] || die "Batch-5 root missing: $B5"
[ -d "$FAMILY" ] || die "frozen harness family missing: $FAMILY"
[ -d "$SRC" ] || die "clean-room source snapshot missing: $SRC"
[ -f "$SRC/src/poly.c" ] || die "poly.c missing from clean-room source"
[ -f "$SRC/src/poly.h" ] || die "poly.h missing from clean-room source"
[ ! -e "$B54" ] || die "B5.4 directory already exists: $B54"

for tool in \
  sha256sum goto-cc goto-instrument cbmc gcc python3 \
  awk grep sed find sort head wc readlink
do
  command -v "$tool" >/dev/null 2>&1 || die "required tool missing: $tool"
done

POLYC_SHA="$(sha256sum "$SRC/src/poly.c" | awk '{print $1}')"
POLYH_SHA="$(sha256sum "$SRC/src/poly.h" | awk '{print $1}')"

[ "$POLYC_SHA" = "$EXPECTED_POLYC_SHA" ] ||
  die "clean-room poly.c hash does not match the B5.1 binding"
[ "$POLYH_SHA" = "$EXPECTED_POLYH_SHA" ] ||
  die "clean-room poly.h hash does not match the B5.1 binding"

CBMC_VERSION="$(cbmc --version | sed -n '1p')"
GOTOCC_VERSION="$(goto-cc --version 2>&1 | sed -n '1p')"
GOTOINSTRUMENT_VERSION="$(goto-instrument --version 2>&1 | sed -n '1p')"

echo "$CBMC_VERSION" | grep -q '6\.9\.0' ||
  die "CBMC is not the frozen 6.9.0 toolchain"
echo "$GOTOCC_VERSION" | grep -q '6\.9\.0' ||
  die "goto-cc is not the frozen 6.9.0 toolchain"
echo "$GOTOINSTRUMENT_VERSION" | grep -q '6\.9\.0' ||
  die "goto-instrument is not the frozen 6.9.0 toolchain"

(
  cd "$FAMILY"
  sha256sum -c SUB00Q_B5_2_ARTIFACT_MANIFEST.sha256
  bash scripts/validate_frozen_family.sh
)

if [ -f "$B5/SUB00Q_B5_0_THEOREM_PREREGISTRATION.md.sha256" ]; then
  sha256sum -c "$B5/SUB00Q_B5_0_THEOREM_PREREGISTRATION.md.sha256"
fi

if [ -f "$B5/B5_1_PRODUCTION_AND_PARENT_BINDING/SUB00Q_B5_1_AUTHORITATIVE_BINDING.md.sha256" ]; then
  sha256sum -c \
    "$B5/B5_1_PRODUCTION_AND_PARENT_BINDING/SUB00Q_B5_1_AUTHORITATIVE_BINDING.md.sha256"
fi

if [ -f "$B5/B5_3_STRUCTURAL_DISTINCTNESS_AUDIT/SUB00Q_B5_3_STRUCTURAL_DISTINCTNESS_AUDIT.txt.sha256" ]; then
  sha256sum -c \
    "$B5/B5_3_STRUCTURAL_DISTINCTNESS_AUDIT/SUB00Q_B5_3_STRUCTURAL_DISTINCTNESS_AUDIT.txt.sha256"
fi

mkdir -p "$BUILD" "$COMMANDS" "$LOGS" "$INSPECT" "$EXITS"

RUNNER_PATH="$(readlink -f "$0")"
cp "$RUNNER_PATH" "$B54/executed_runner.sh"

{
  printf '%s\n' \
    '# SUB-T5 / B5.4 — Execution Input Freeze' \
    '' \
    "Captured UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '' \
    '## Frozen source inputs' \
    '' \
    "Clean-room source root: \`$SRC\`" \
    "poly.c SHA-256: \`$POLYC_SHA\`" \
    "poly.h SHA-256: \`$POLYH_SHA\`" \
    '' \
    '## Frozen harness family' \
    '' \
    "Harness root: \`$FAMILY\`" \
    'Harness count: 9' \
    'Each harness is compiled into a separate linked GOTO binary.' \
    '' \
    '## Frozen toolchain' \
    '' \
    "CBMC: \`$CBMC_VERSION\`" \
    "goto-cc: \`$GOTOCC_VERSION\`" \
    "goto-instrument: \`$GOTOINSTRUMENT_VERSION\`" \
    '' \
    '## Preflight boundary' \
    '' \
    'This stage constructs and inspects GOTO binaries.' \
    'It does not run positive, reachability, expected-failure, or mutation proofs.' \
    'Case-specific unwindsets are derived from each constructed model using --show-loops.' \
    '' \
    'CBMC proof execution: NO' \
    'Production-source modification: NO' \
    'Earlier-batch modification: NO'
} > "$FREEZE"

printf '%s\n' \
  "SUB-T5 / B5.4 GOTO PREFLIGHT SUMMARY" \
  "" \
  "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "CBMC_VERSION=$CBMC_VERSION" \
  "GOTOCC_VERSION=$GOTOCC_VERSION" \
  "GOTOINSTRUMENT_VERSION=$GOTOINSTRUMENT_VERSION" \
  "POLYC_SHA256=$POLYC_SHA" \
  "POLYH_SHA256=$POLYH_SHA" \
  "" \
  "CASE|CLASS|GOTO_SHA256|REACHABLE_LOOP_IDS|UNWINDSET|PROPERTY_COUNT" \
  > "$SUMMARY"

for idx in "${!CASES[@]}"
do
  case_name="${CASES[$idx]}"
  case_class="${CLASSES[$idx]}"
  harness_name="${HARNESSES[$idx]}"
  harness="$FAMILY/harnesses/$harness_name"
  goto_file="$BUILD/${case_name}.goto"
  command_file="$COMMANDS/${case_name}_goto_build_command.txt"
  stdout_file="$LOGS/${case_name}_goto_build_stdout.txt"
  stderr_file="$LOGS/${case_name}_goto_build_stderr.txt"
  exit_file="$EXITS/${case_name}_goto_build_exit_code.txt"

  [ -f "$harness" ] || die "harness missing: $harness"

  cmd=(
    goto-cc
    -std=c90
    -DMLK_CONFIG_PARAMETER_SET=768
    -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00q_b5
    -DMLK_CONFIG_NO_ASM=1
    -DMLK_CONFIG_CUSTOM_ZEROIZE=1
    -include "$FAMILY/support/sub00q_b5_fail_closed_zeroize.h"
    -include "$FAMILY/support/sub00q_b5_verify_pragma_scope.h"
    -I"$SRC"
    -I"$SRC/src"
    -I"$FAMILY/support"
    "$harness"
    "$SRC/src/poly.c"
    "$FAMILY/support/sub00q_b5_optblocker_zero.c"
    -o "$goto_file"
  )

  {
    printf 'COMMAND:'
    printf ' %q' "${cmd[@]}"
    printf '\n'
  } > "$command_file"

  set +e
  "${cmd[@]}" >"$stdout_file" 2>"$stderr_file"
  rc=$?
  set -e
  printf '%s\n' "$rc" > "$exit_file"

  [ "$rc" -eq 0 ] ||
    die "goto-cc failed for $case_name; inspect $stderr_file"
  [ -s "$goto_file" ] ||
    die "goto binary missing or empty for $case_name"

  sha256sum "$goto_file" > "$goto_file.sha256"

  goto-instrument --validate-goto-binary "$goto_file" \
    >"$INSPECT/${case_name}_validate_goto_binary.txt" 2>&1

  goto-instrument --show-loops "$goto_file" \
    >"$INSPECT/${case_name}_show_loops.txt" 2>&1

  goto-instrument --list-goto-functions "$goto_file" \
    >"$INSPECT/${case_name}_list_goto_functions.txt" 2>&1

  goto-instrument --show-goto-functions "$goto_file" \
    >"$INSPECT/${case_name}_show_goto_functions.txt" 2>&1

  goto-instrument --list-symbols "$goto_file" \
    >"$INSPECT/${case_name}_list_symbols.txt" 2>&1

  goto-instrument --list-undefined-functions "$goto_file" \
    >"$INSPECT/${case_name}_undefined_functions.txt" 2>&1

  goto-instrument --list-calls-args "$goto_file" \
    >"$INSPECT/${case_name}_calls_and_arguments.txt" 2>&1

  goto-instrument --reachable-call-graph "$goto_file" \
    >"$INSPECT/${case_name}_reachable_call_graph.txt" 2>&1

  grep -q 'mlk_sub00q_b5_poly_sub' \
    "$INSPECT/${case_name}_reachable_call_graph.txt" ||
    die "production poly_sub is not reachable from main in $case_name"

  mapfile -t reachable_loop_ids < <(
    awk '
      /^Loop[[:space:]]+/ {
        id=$2
        sub(/:$/, "", id)
        if(id ~ /^main\./ || id ~ /^mlk_sub00q_b5_poly_sub\./)
          print id
      }
    ' "$INSPECT/${case_name}_show_loops.txt" | sort -u
  )

  [ "${#reachable_loop_ids[@]}" -ge 2 ] ||
    die "too few reachable main/poly_sub loops detected for $case_name"

  production_loop_count=0
  main_loop_count=0
  unwindset=""
  loop_csv=""

  for loop_id in "${reachable_loop_ids[@]}"
  do
    case "$loop_id" in
      main.*)
        main_loop_count=$((main_loop_count + 1))
        ;;
      mlk_sub00q_b5_poly_sub.*)
        production_loop_count=$((production_loop_count + 1))
        ;;
    esac

    if [ -n "$unwindset" ]; then
      unwindset="${unwindset},"
      loop_csv="${loop_csv},"
    fi
    unwindset="${unwindset}${loop_id}:257"
    loop_csv="${loop_csv}${loop_id}"
  done

  [ "$main_loop_count" -ge 1 ] ||
    die "no main loop detected for $case_name"
  [ "$production_loop_count" -eq 1 ] ||
    die "expected exactly one production loop ID for $case_name, found $production_loop_count"

  printf '%s\n' "$unwindset" \
    > "$INSPECT/${case_name}_frozen_unwindset.txt"

  property_cmd=(
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
    --show-properties
  )

  {
    printf 'COMMAND:'
    printf ' %q' "${property_cmd[@]}"
    printf '\n'
  } > "$COMMANDS/${case_name}_show_properties_command.txt"

  "${property_cmd[@]}" \
    >"$INSPECT/${case_name}_show_properties.txt" \
    2>"$INSPECT/${case_name}_show_properties_stderr.txt"

  property_count="$(
    grep -Ec '^Property[[:space:]]+' \
      "$INSPECT/${case_name}_show_properties.txt" || true
  )"

  [ "$property_count" -ge 1 ] ||
    die "no properties discovered for $case_name"

  goto_sha="$(awk '{print $1}' "$goto_file.sha256")"

  printf '%s|%s|%s|%s|%s|%s\n' \
    "$case_name" \
    "$case_class" \
    "$goto_sha" \
    "$loop_csv" \
    "$unwindset" \
    "$property_count" \
    >> "$SUMMARY"

  echo "CASE=$case_name BUILD=PASS VALIDATE=PASS LOOPS=$loop_csv PROPERTIES=$property_count"
done

{
  echo
  echo "=== PREFLIGHT VERDICT ==="
  echo "CASE_COUNT=${#CASES[@]}"
  echo "GOTO_BINARY_COUNT=$(find "$BUILD" -maxdepth 1 -type f -name '*.goto' | wc -l)"
  echo "GOTO_CHECKSUM_COUNT=$(find "$BUILD" -maxdepth 1 -type f -name '*.goto.sha256' | wc -l)"
  echo "BUILD_EXIT_ZERO_COUNT=$(grep -l '^0$' "$EXITS"/*_goto_build_exit_code.txt | wc -l)"
  echo "CASE_SPECIFIC_UNWINDSET_COUNT=$(find "$INSPECT" -maxdepth 1 -type f -name '*_frozen_unwindset.txt' | wc -l)"
  echo "POSITIVE_CASE_COUNT=4"
  echo "REACHABILITY_CASE_COUNT=3"
  echo "EXPECTED_FAILURE_CASE_COUNT=2"
  echo "ALL_GOTO_BUILDS=PASS"
  echo "ALL_GOTO_BINARY_VALIDATIONS=PASS"
  echo "ALL_PRODUCTION_CALL_GRAPHS=REACHABLE"
  echo "ALL_LOOP_IDS_DERIVED_FROM_GOTO_MODELS=PASS"
  echo "ALL_PROPERTY_INVENTORIES_PRESENT=PASS"
  echo "B5_4_STATUS=PASS"
  echo
  echo "=== OPERATION BOUNDARY ==="
  echo "GOTO_MODEL_CREATION=YES"
  echo "CBMC_PROOF_EXECUTION=NO"
  echo "PRODUCTION_SOURCE_MODIFICATION=NO"
  echo "EARLIER_BATCH_MODIFICATION=NO"
} >> "$SUMMARY"

(
  cd "$B54"
  find . -type f \
    ! -name "$(basename "$MANIFEST")" \
    -print0 |
    sort -z |
    xargs -0 sha256sum > "$MANIFEST"
  sha256sum -c "$MANIFEST"
)

find "$B54" -type f -exec chmod 0444 {} +
chmod 0555 "$B54/executed_runner.sh"
find "$B54" -type d -exec chmod 0555 {} +

SUCCESS=1
trap - EXIT

echo
echo "=== B5.4 FINAL SUMMARY ==="
grep -E \
  'CASE_COUNT=|GOTO_BINARY_COUNT=|GOTO_CHECKSUM_COUNT=|BUILD_EXIT_ZERO_COUNT=|CASE_SPECIFIC_UNWINDSET_COUNT=|POSITIVE_CASE_COUNT=|REACHABILITY_CASE_COUNT=|EXPECTED_FAILURE_CASE_COUNT=|ALL_GOTO_BUILDS=|ALL_GOTO_BINARY_VALIDATIONS=|ALL_PRODUCTION_CALL_GRAPHS=|ALL_LOOP_IDS_DERIVED_FROM_GOTO_MODELS=|ALL_PROPERTY_INVENTORIES_PRESENT=|B5_4_STATUS=|GOTO_MODEL_CREATION=|CBMC_PROOF_EXECUTION=|PRODUCTION_SOURCE_MODIFICATION=|EARLIER_BATCH_MODIFICATION=' \
  "$SUMMARY"

echo
echo "B5_4_DIRECTORY=$B54"
echo "B5_4_SUMMARY=$SUMMARY"
echo "============================================================"
