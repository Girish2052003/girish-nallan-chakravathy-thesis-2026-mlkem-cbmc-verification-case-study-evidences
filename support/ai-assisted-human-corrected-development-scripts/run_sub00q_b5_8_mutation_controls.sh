#!/usr/bin/env bash
set -euo pipefail
umask 0022

BASE="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B5="$BASE/SUB00Q_BATCH5_T5_RELATIONAL"
FAMILY="$B5/frozen_harness_family_v1"
SRC="$BASE/source/mlkem"
B54="$B5/B5_4_GOTO_PREFLIGHT_MLKEM768"
RUN="$B5/B5_8_MUTATION_CONTROLS_MLKEM768_RUN1"

MUTATIONS="$RUN/mutations"
BUILD="$RUN/build"
INSPECT="$RUN/inspection"
RESULTS="$RUN/full_model_results"
WITNESSES="$RUN/targeted_witnesses"
COMMANDS="$RUN/commands"
LOGS="$RUN/logs"
EXITS="$RUN/exit_codes"
RESOURCES="$RUN/resource_usage"
FROZEN="$RUN/frozen_inputs"

SUMMARY="$RUN/SUB00Q_B5_8_MUTATION_SUMMARY.txt"
BINDING="$RUN/SUB00Q_B5_8_EXECUTION_INPUT_BINDING.txt"
CATALOG="$RUN/SUB00Q_B5_8_MUTATION_CATALOG.tsv"
MANIFEST="$RUN/SUB00Q_B5_8_ARTIFACT_MANIFEST.sha256"

EXPECTED_POLYC_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_POLYH_SHA="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"

MUTANTS=(
  "M1_NEXT_B_SAFE"
  "M2_WRITE_B"
  "M3_PREVIOUS_B_SAFE"
  "M4_SKIP_COEFFICIENT_255"
)

HARNESSES=(
  "sub_t5_coefficient_locality_harness.c"
  "sub_t5_frame_preservation_harness.c"
  "sub_t5_coefficient_locality_harness.c"
  "sub_t5_noninterference_exact_effect_harness.c"
)

NAMESPACES=(
  "mlk_sub00q_b5_m1"
  "mlk_sub00q_b5_m2"
  "mlk_sub00q_b5_m3"
  "mlk_sub00q_b5_m4"
)

PRIMARY_MARKERS=(
  "SUB_T5_T5_2_LOCALITY"
  "SUB_T5_T5_1_FRAME_B1"
  "SUB_T5_T5_2_LOCALITY"
  "SUB_T5_T5_4_EXACT_R1"
)

ALLOWED_MARKER_SETS=(
  "SUB_T5_T5_2_EXACT_R1_K;SUB_T5_T5_2_EXACT_R2_K;SUB_T5_T5_2_LOCALITY"
  "SUB_T5_T5_1_FRAME_B1;SUB_T5_T5_1_FRAME_B2"
  "SUB_T5_T5_2_EXACT_R1_K;SUB_T5_T5_2_EXACT_R2_K;SUB_T5_T5_2_LOCALITY"
  "SUB_T5_T5_4_EXACT_R1;SUB_T5_T5_4_EXACT_R2;SUB_T5_T5_4_CHANGED_R1;SUB_T5_T5_4_CHANGED_R2;SUB_T5_T5_4_RELATIONAL_EFFECT"
)

DESCRIPTIONS=(
  "Use B[i+1] instead of B[i], retaining B[i] at the final boundary"
  "Compute the destination correctly, then illegally overwrite source operand B"
  "Use B[i-1] instead of B[i], retaining B[0] at the first boundary"
  "Execute the subtraction loop only through coefficient 254"
)

die()
{
  echo "ERROR: $*" >&2
  exit 1
}

find_accepted_dir()
{
  local summary_name="$1"
  local verdict_line="$2"
  local candidate

  for candidate in "$B5"/*/"$summary_name"
  do
    [ -f "$candidate" ] || continue
    if grep -q "^${verdict_line}$" "$candidate"; then
      dirname "$candidate"
      return 0
    fi
  done

  return 0
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
echo "SUB-T5 / B5.8 MUTATION CONTROLS"
echo "============================================================"

[ -d "$FAMILY" ] || die "frozen harness family missing: $FAMILY"
[ -d "$SRC" ] || die "clean-room source missing: $SRC"
[ -f "$SRC/src/poly.c" ] || die "clean-room poly.c missing"
[ -f "$SRC/src/poly.h" ] || die "clean-room poly.h missing"
[ -d "$B54" ] || die "B5.4 preflight missing: $B54"
[ ! -e "$RUN" ] || die "B5.8 run directory already exists: $RUN"

for tool in \
  sha256sum goto-cc goto-instrument cbmc timeout python3 \
  diff find sort grep awk sed wc readlink tr
do
  command -v "$tool" >/dev/null 2>&1 ||
    die "required tool missing: $tool"
done

TIME_TOOL=""
if [ -x /usr/bin/time ]; then
  TIME_TOOL="/usr/bin/time"
fi

CBMC_VERSION="$(cbmc --version | sed -n '1p')"
GOTOCC_VERSION="$(goto-cc --version 2>&1 | sed -n '1p')"

echo "$CBMC_VERSION" | grep -q '6\.9\.0' ||
  die "CBMC is not the frozen 6.9.0 toolchain"
echo "$GOTOCC_VERSION" | grep -q '6\.9\.0' ||
  die "goto-cc is not the frozen 6.9.0 toolchain"

POLYC_SHA_BEFORE="$(sha256sum "$SRC/src/poly.c" | awk '{print $1}')"
POLYH_SHA_BEFORE="$(sha256sum "$SRC/src/poly.h" | awk '{print $1}')"

[ "$POLYC_SHA_BEFORE" = "$EXPECTED_POLYC_SHA" ] ||
  die "clean-room poly.c no longer matches the frozen B5.1 binding"
[ "$POLYH_SHA_BEFORE" = "$EXPECTED_POLYH_SHA" ] ||
  die "clean-room poly.h no longer matches the frozen B5.1 binding"

B55="$(find_accepted_dir \
  'SUB00Q_B5_5_POSITIVE_EXECUTION_SUMMARY.txt' \
  'B5_5_STATUS=PASS')"
B56="$(find_accepted_dir \
  'SUB00Q_B5_6_REACHABILITY_SUMMARY.txt' \
  'B5_6_STATUS=PASS')"
B57="$(find_accepted_dir \
  'SUB00Q_B5_7_EXPECTED_FAILURE_SUMMARY.txt' \
  'B5_7_STATUS=PASS')"

[ -n "${B55:-}" ] || die "accepted B5.5 run not found"
[ -n "${B56:-}" ] || die "accepted B5.6 run not found"
[ -n "${B57:-}" ] || die "accepted B5.7 run not found"

B54_MANIFEST="$(find_manifest "$B54")"
B55_MANIFEST="$(find_manifest "$B55")"
B56_MANIFEST="$(find_manifest "$B56")"
B57_MANIFEST="$(find_manifest "$B57")"

[ -n "${B54_MANIFEST:-}" ] || die "B5.4 manifest not found"
[ -n "${B55_MANIFEST:-}" ] || die "B5.5 manifest not found"
[ -n "${B56_MANIFEST:-}" ] || die "B5.6 manifest not found"
[ -n "${B57_MANIFEST:-}" ] || die "B5.7 manifest not found"

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

(
  cd "$B57"
  sha256sum -c "$(basename "$B57_MANIFEST")"
)

mkdir -p \
  "$MUTATIONS" "$BUILD" "$INSPECT" "$RESULTS" "$WITNESSES" \
  "$COMMANDS" "$LOGS" "$EXITS" "$RESOURCES" "$FROZEN"

RUNNER_PATH="$(readlink -f "$0")"
cp "$RUNNER_PATH" "$RUN/executed_runner.sh"

cp "$B54/SUB00Q_B5_4_PREFLIGHT_SUMMARY.txt" \
   "$FROZEN/B5_4_PREFLIGHT_SUMMARY.txt"
cp "$B54_MANIFEST" "$FROZEN/B5_4_MANIFEST.sha256"
cp "$B55/SUB00Q_B5_5_POSITIVE_EXECUTION_SUMMARY.txt" \
   "$FROZEN/B5_5_POSITIVE_EXECUTION_SUMMARY.txt"
cp "$B55_MANIFEST" "$FROZEN/B5_5_MANIFEST.sha256"
cp "$B56/SUB00Q_B5_6_REACHABILITY_SUMMARY.txt" \
   "$FROZEN/B5_6_REACHABILITY_SUMMARY.txt"
cp "$B56_MANIFEST" "$FROZEN/B5_6_MANIFEST.sha256"
cp "$B57/SUB00Q_B5_7_EXPECTED_FAILURE_SUMMARY.txt" \
   "$FROZEN/B5_7_EXPECTED_FAILURE_SUMMARY.txt"
cp "$B57_MANIFEST" "$FROZEN/B5_7_MANIFEST.sha256"
cp "$FAMILY/SUB00Q_B5_2_ARTIFACT_MANIFEST.sha256" \
   "$FROZEN/B5_2_ARTIFACT_MANIFEST.sha256"

{
  echo "SUB-T5 / B5.8 MUTATION EXECUTION INPUT BINDING"
  echo
  echo "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "CBMC_VERSION=$CBMC_VERSION"
  echo "GOTOCC_VERSION=$GOTOCC_VERSION"
  echo "FROZEN_HARNESS_FAMILY=$FAMILY"
  echo "CLEANROOM_SOURCE=$SRC"
  echo "POLYC_SHA256=$POLYC_SHA_BEFORE"
  echo "POLYH_SHA256=$POLYH_SHA_BEFORE"
  echo "ACCEPTED_B5_5_PARENT=$B55"
  echo "ACCEPTED_B5_6_PARENT=$B56"
  echo "ACCEPTED_B5_7_PARENT=$B57"
  echo "MUTANT_COUNT=${#MUTANTS[@]}"
  echo
  echo "Every mutant must:"
  echo "- differ from the frozen source;"
  echo "- compile into a valid GOTO binary;"
  echo "- make the production poly_sub reachable;"
  echo "- fail at least one pre-registered relevant T5 assertion;"
  echo "- produce no unrelated failed or unknown properties;"
  echo "- yield a targeted counterexample witness."
  echo
  echo "Compilation failure alone is not accepted as a semantic kill."
  echo "All mutation source files are private copies under the B5.8 run."
  echo
  echo "MUTATION_EXECUTION=YES"
  echo "FROZEN_HARNESS_MODIFICATION=NO"
  echo "CLEANROOM_SOURCE_MODIFICATION=NO"
  echo "PRODUCTION_REPOSITORY_MODIFICATION=NO"
  echo "EARLIER_BATCH_MODIFICATION=NO"
} > "$BINDING"

printf '%s\n' \
  "MUTANT_ID\tDESCRIPTION\tDETECTOR_HARNESS\tPRIMARY_MARKER\tALLOWED_MARKERS" \
  > "$CATALOG"

for idx in "${!MUTANTS[@]}"
do
  printf '%s\t%s\t%s\t%s\t%s\n' \
    "${MUTANTS[$idx]}" \
    "${DESCRIPTIONS[$idx]}" \
    "${HARNESSES[$idx]}" \
    "${PRIMARY_MARKERS[$idx]}" \
    "${ALLOWED_MARKER_SETS[$idx]}" \
    >> "$CATALOG"
done

python3 - "$SRC/src/poly.c" "$MUTATIONS" "$CATALOG" <<'PY'
from pathlib import Path
import difflib
import hashlib
import sys

source_path = Path(sys.argv[1])
mutation_root = Path(sys.argv[2])
catalog_path = Path(sys.argv[3])

source = source_path.read_text(encoding="utf-8")
start_token = "void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)"
end_token = '\n}\n\n#include "zetas.inc"'

start = source.find(start_token)
if start < 0:
    raise SystemExit("MLK_POLY_SUB_START_NOT_FOUND")

end_marker = source.find(end_token, start)
if end_marker < 0:
    raise SystemExit("MLK_POLY_SUB_END_NOT_FOUND")

end = end_marker + 2
function = source[start:end]

assignment = (
    "    r->coeffs[i] = "
    "(int16_t)(r->coeffs[i] - b->coeffs[i]);"
)
loop_header = "  for (i = 0; i < MLKEM_N; i++)"

if function.count(assignment) != 1:
    raise SystemExit(
        f"EXPECTED_ONE_SUB_ASSIGNMENT_FOUND={function.count(assignment)}"
    )
if function.count(loop_header) != 1:
    raise SystemExit(
        f"EXPECTED_ONE_SUB_LOOP_FOUND={function.count(loop_header)}"
    )

mutated_functions = {
    "M1_NEXT_B_SAFE": function.replace(
        assignment,
        """    {
      int16_t selected_b;
      selected_b =
          b->coeffs[(i + 1u < MLKEM_N) ? (i + 1u) : i];
      r->coeffs[i] = (int16_t)(r->coeffs[i] - selected_b);
    }""",
    ),
    "M2_WRITE_B": function.replace(
        assignment,
        """    {
      int16_t original_b;
      original_b = b->coeffs[i];
      r->coeffs[i] = (int16_t)(r->coeffs[i] - original_b);
      ((mlk_poly *)b)->coeffs[i] = r->coeffs[i];
    }""",
    ),
    "M3_PREVIOUS_B_SAFE": function.replace(
        assignment,
        """    {
      int16_t selected_b;
      selected_b =
          b->coeffs[(i == 0u) ? 0u : (i - 1u)];
      r->coeffs[i] = (int16_t)(r->coeffs[i] - selected_b);
    }""",
    ),
    "M4_SKIP_COEFFICIENT_255": function.replace(
        loop_header,
        "  for (i = 0; i < MLKEM_N - 1u; i++)",
    ),
}

catalog_ids = []
for line in catalog_path.read_text(encoding="utf-8").splitlines()[1:]:
    if line.strip():
        catalog_ids.append(line.split("\t", 1)[0])

if catalog_ids != list(mutated_functions):
    raise SystemExit(
        f"CATALOG_MUTATION_ORDER_MISMATCH={catalog_ids}"
    )

source_hash = hashlib.sha256(source.encode("utf-8")).hexdigest()

for mutant_id, mutant_function in mutated_functions.items():
    if mutant_function == function:
        raise SystemExit(f"MUTATION_DID_NOT_CHANGE_FUNCTION={mutant_id}")

    mutant_source = source[:start] + mutant_function + source[end:]
    if mutant_source[:start] != source[:start]:
        raise SystemExit(f"PREFIX_CHANGED_OUTSIDE_FUNCTION={mutant_id}")
    if mutant_source[
        start + len(mutant_function):
    ] != source[end:]:
        raise SystemExit(f"SUFFIX_CHANGED_OUTSIDE_FUNCTION={mutant_id}")

    directory = mutation_root / mutant_id
    directory.mkdir(parents=True, exist_ok=False)

    poly_path = directory / "poly.c"
    poly_path.write_text(mutant_source, encoding="utf-8")

    mutant_hash = hashlib.sha256(
        mutant_source.encode("utf-8")
    ).hexdigest()
    if mutant_hash == source_hash:
        raise SystemExit(f"MUTANT_HASH_EQUALS_SOURCE={mutant_id}")

    diff = "".join(
        difflib.unified_diff(
            source.splitlines(True),
            mutant_source.splitlines(True),
            fromfile="frozen_source/poly.c",
            tofile=f"{mutant_id}/poly.c",
        )
    )
    if not diff:
        raise SystemExit(f"EMPTY_DIFF={mutant_id}")

    (directory / "mutation.diff").write_text(
        diff,
        encoding="utf-8",
    )
    (directory / "mutation_identity.txt").write_text(
        "\n".join(
            [
                f"MUTANT_ID={mutant_id}",
                f"FROZEN_SOURCE_SHA256={source_hash}",
                f"MUTANT_SOURCE_SHA256={mutant_hash}",
                "MUTATION_SCOPE=MLK_POLY_SUB_FUNCTION_ONLY",
                "BUILD_LEVEL_CONTROL=NO",
                "SEMANTIC_MUTANT=YES",
                "",
            ]
        ),
        encoding="utf-8",
    )
PY

printf '%s\n' \
  "SUB-T5 / B5.8 MUTATION CONTROL SUMMARY" \
  "" \
  "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "CBMC_VERSION=$CBMC_VERSION" \
  "" \
  "MUTANT|BUILD_EXIT|VALIDATED|TARGET_FAILURES|UNEXPECTED_FAILURES|UNKNOWN|PRIMARY_MARKER_FAILED|WITNESS_EXIT|WITNESS_MARKER|VERDICT" \
  > "$SUMMARY"

for idx in "${!MUTANTS[@]}"
do
  mutant="${MUTANTS[$idx]}"
  harness_name="${HARNESSES[$idx]}"
  namespace="${NAMESPACES[$idx]}"
  primary_marker="${PRIMARY_MARKERS[$idx]}"
  allowed_markers="${ALLOWED_MARKER_SETS[$idx]}"

  mutant_dir="$MUTATIONS/$mutant"
  mutant_source="$mutant_dir/poly.c"
  detector="$FAMILY/harnesses/$harness_name"
  goto_file="$BUILD/${mutant}.goto"

  build_command="$COMMANDS/${mutant}_goto_build_command.txt"
  build_stdout="$LOGS/${mutant}_goto_build_stdout.txt"
  build_stderr="$LOGS/${mutant}_goto_build_stderr.txt"
  build_exit="$EXITS/${mutant}_goto_build_exit_code.txt"

  validate_file="$INSPECT/${mutant}_validate_goto_binary.txt"
  loops_file="$INSPECT/${mutant}_show_loops.txt"
  functions_file="$INSPECT/${mutant}_list_goto_functions.txt"
  callgraph_file="$INSPECT/${mutant}_reachable_call_graph.txt"
  undefined_file="$INSPECT/${mutant}_undefined_functions.txt"
  properties_file="$INSPECT/${mutant}_show_properties.txt"
  properties_stderr="$INSPECT/${mutant}_show_properties_stderr.txt"
  unwind_file="$INSPECT/${mutant}_frozen_unwindset.txt"

  full_json="$RESULTS/${mutant}_full_model_result.json"
  full_stderr="$LOGS/${mutant}_full_model_stderr.txt"
  full_exit="$EXITS/${mutant}_full_model_exit_code.txt"
  full_resource="$RESOURCES/${mutant}_full_model_resource_usage.txt"
  full_command="$COMMANDS/${mutant}_full_model_command.txt"
  parsed="$RESULTS/${mutant}_parsed_result.txt"
  kill_audit="$RESULTS/${mutant}_kill_audit.txt"

  witness_stdout="$WITNESSES/${mutant}_targeted_witness.txt"
  witness_stderr="$LOGS/${mutant}_targeted_witness_stderr.txt"
  witness_exit="$EXITS/${mutant}_targeted_witness_exit_code.txt"
  witness_resource="$RESOURCES/${mutant}_targeted_witness_resource_usage.txt"
  witness_command="$COMMANDS/${mutant}_targeted_witness_command.txt"

  [ -s "$mutant_source" ] || die "mutant source missing: $mutant"
  [ -f "$detector" ] || die "detector harness missing: $detector"

  mutant_sha="$(sha256sum "$mutant_source" | awk '{print $1}')"
  [ "$mutant_sha" != "$POLYC_SHA_BEFORE" ] ||
    die "mutant is byte-identical to frozen source: $mutant"

  build_cmd=(
    goto-cc
    -std=c90
    -DMLK_CONFIG_PARAMETER_SET=768
    -DMLK_CONFIG_NAMESPACE_PREFIX="$namespace"
    -DMLK_CONFIG_NO_ASM=1
    -DMLK_CONFIG_CUSTOM_ZEROIZE=1
    -include "$FAMILY/support/sub00q_b5_fail_closed_zeroize.h"
    -include "$FAMILY/support/sub00q_b5_verify_pragma_scope.h"
    -I"$SRC"
    -I"$SRC/src"
    -I"$FAMILY/support"
    "$detector"
    "$mutant_source"
    "$FAMILY/support/sub00q_b5_optblocker_zero.c"
    -o "$goto_file"
  )

  {
    printf 'COMMAND:'
    printf ' %q' "${build_cmd[@]}"
    printf '\n'
  } > "$build_command"

  echo "MUTANT=$mutant PHASE=BUILD STATUS=RUNNING"

  set +e
  "${build_cmd[@]}" >"$build_stdout" 2>"$build_stderr"
  rc_build=$?
  set -e

  printf '%s\n' "$rc_build" > "$build_exit"

  [ "$rc_build" -eq 0 ] ||
    die "semantic mutant failed to compile: $mutant"
  [ -s "$goto_file" ] ||
    die "mutant GOTO binary missing: $mutant"

  sha256sum "$goto_file" > "$goto_file.sha256"

  goto-instrument --validate-goto-binary "$goto_file" \
    >"$validate_file" 2>&1

  goto-instrument --show-loops "$goto_file" \
    >"$loops_file" 2>&1

  goto-instrument --list-goto-functions "$goto_file" \
    >"$functions_file" 2>&1

  goto-instrument --reachable-call-graph "$goto_file" \
    >"$callgraph_file" 2>&1

  goto-instrument --list-undefined-functions "$goto_file" \
    >"$undefined_file" 2>&1

  production_function="${namespace}_poly_sub"
  grep -q "$production_function" "$callgraph_file" ||
    die "mutated production poly_sub is unreachable: $mutant"

  mapfile -t loop_ids < <(
    awk -v production="$production_function" '
      /^Loop[[:space:]]+/ {
        id=$2
        sub(/:$/, "", id)
        if(id ~ /^main\./ || index(id, production ".") == 1)
          print id
      }
    ' "$loops_file" | sort -u
  )

  [ "${#loop_ids[@]}" -ge 2 ] ||
    die "too few reachable loop IDs for mutant: $mutant"

  unwindset=""
  main_loop_count=0
  production_loop_count=0

  for loop_id in "${loop_ids[@]}"
  do
    case "$loop_id" in
      main.*)
        main_loop_count=$((main_loop_count + 1))
        ;;
      "${production_function}".*)
        production_loop_count=$((production_loop_count + 1))
        ;;
    esac

    if [ -n "$unwindset" ]; then
      unwindset="${unwindset},"
    fi
    unwindset="${unwindset}${loop_id}:257"
  done

  [ "$main_loop_count" -ge 1 ] ||
    die "no detector main loop found: $mutant"
  [ "$production_loop_count" -eq 1 ] ||
    die "expected one mutated production loop: $mutant"

  printf '%s\n' "$unwindset" > "$unwind_file"

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

  "${property_cmd[@]}" >"$properties_file" 2>"$properties_stderr"

  grep -Fq "$primary_marker" "$properties_file" ||
    die "primary detector property absent from mutant model: $mutant"

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

  echo "MUTANT=$mutant PHASE=FULL_MODEL STATUS=RUNNING"

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
    die "mutant did not produce expected verification-failure exit: $mutant"
  [ -s "$full_json" ] ||
    die "empty mutant CBMC JSON: $mutant"

  python3 - \
    "$full_json" \
    "$parsed" \
    "$primary_marker" \
    "$allowed_markers" <<'PY'
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
primary = sys.argv[3]
allowed = [item for item in sys.argv[4].split(";") if item]

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
        unique.append(key)

def matches(marker, prop, desc):
    return marker in prop or marker in desc

success = sum(1 for _, status, _ in unique if status == "SUCCESS")
unknown = sum(
    1 for _, status, _ in unique
    if status not in {"SUCCESS", "FAILURE"}
)

target_failures = []
unexpected_failures = []

for prop, status, desc in unique:
    if status != "FAILURE":
        continue
    if any(matches(marker, prop, desc) for marker in allowed):
        target_failures.append((prop, status, desc))
    else:
        unexpected_failures.append((prop, status, desc))

primary_failures = [
    item for item in target_failures
    if matches(primary, item[0], item[2])
]

target_property = ""
if primary_failures:
    target_property = primary_failures[0][0]
elif target_failures:
    target_property = target_failures[0][0]

lines = [
    f"SUCCESS={success}",
    f"TARGET_FAILURES={len(target_failures)}",
    f"UNEXPECTED_FAILURES={len(unexpected_failures)}",
    f"UNKNOWN={unknown}",
    f"PRIMARY_MARKER_FAILED={1 if primary_failures else 0}",
    f"TARGET_PROPERTY={target_property}",
    f"TOTAL_RESULTS={len(unique)}",
]

for prop, status, desc in unique:
    lines.append(
        f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}"
    )

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if not unique:
    raise SystemExit("NO_PROPERTY_RESULTS")
if not target_failures:
    raise SystemExit("NO_RELEVANT_T5_FAILURE")
if not primary_failures:
    raise SystemExit("PRIMARY_MARKER_DID_NOT_FAIL")
if unexpected_failures:
    raise SystemExit(
        f"UNEXPECTED_FAILURE_COUNT={len(unexpected_failures)}"
    )
if unknown:
    raise SystemExit(f"UNKNOWN_COUNT={unknown}")
if not target_property:
    raise SystemExit("TARGET_PROPERTY_MISSING")
PY

  target_failures="$(
    awk -F= '/^TARGET_FAILURES=/{print $2}' "$parsed"
  )"
  unexpected_failures="$(
    awk -F= '/^UNEXPECTED_FAILURES=/{print $2}' "$parsed"
  )"
  unknown_count="$(
    awk -F= '/^UNKNOWN=/{print $2}' "$parsed"
  )"
  primary_failed="$(
    awk -F= '/^PRIMARY_MARKER_FAILED=/{print $2}' "$parsed"
  )"
  target_property="$(
    sed -n 's/^TARGET_PROPERTY=//p' "$parsed"
  )"

  [ "$target_failures" -ge 1 ] ||
    die "no relevant theorem failure killed mutant: $mutant"
  [ "$unexpected_failures" -eq 0 ] ||
    die "unrelated property failure detected: $mutant"
  [ "$unknown_count" -eq 0 ] ||
    die "unknown property result detected: $mutant"
  [ "$primary_failed" -eq 1 ] ||
    die "primary mutation detector did not fail: $mutant"
  [ -n "$target_property" ] ||
    die "targeted witness property missing: $mutant"

  {
    echo "MUTANT=$mutant"
    echo "DETECTOR_HARNESS=$harness_name"
    echo "PRIMARY_MARKER=$primary_marker"
    echo "ALLOWED_MARKERS=$allowed_markers"
    echo "TARGET_FAILURES=$target_failures"
    echo "UNEXPECTED_FAILURES=$unexpected_failures"
    echo "UNKNOWN=$unknown_count"
    echo "PRIMARY_MARKER_FAILED=$primary_failed"
    echo "TARGET_PROPERTY=$target_property"
  } > "$kill_audit"

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

  echo "MUTANT=$mutant PHASE=TARGETED_WITNESS STATUS=RUNNING"

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
    die "targeted mutant witness did not fail as expected: $mutant"
  [ -s "$witness_stdout" ] ||
    die "empty targeted mutant witness: $mutant"

  grep -Fq "$primary_marker" "$witness_stdout" ||
    die "primary marker missing from targeted witness: $mutant"
  grep -q 'Violated property' "$witness_stdout" ||
    die "violated-property heading absent from witness: $mutant"
  grep -q 'VERIFICATION FAILED' "$witness_stdout" ||
    die "targeted witness did not report verification failure: $mutant"

  witness_marker=1
  sha256sum "$witness_stdout" > "$witness_stdout.sha256"

  printf '%s|%s|1|%s|%s|%s|%s|%s|%s|PASS\n' \
    "$mutant" \
    "$rc_build" \
    "$target_failures" \
    "$unexpected_failures" \
    "$unknown_count" \
    "$primary_failed" \
    "$rc_witness" \
    "$witness_marker" \
    >> "$SUMMARY"

  echo "MUTANT=$mutant STATUS=KILLED TARGET_FAILURES=$target_failures WITNESS=PASS"
done

POLYC_SHA_AFTER="$(sha256sum "$SRC/src/poly.c" | awk '{print $1}')"
POLYH_SHA_AFTER="$(sha256sum "$SRC/src/poly.h" | awk '{print $1}')"

[ "$POLYC_SHA_AFTER" = "$POLYC_SHA_BEFORE" ] ||
  die "clean-room poly.c changed during mutation execution"
[ "$POLYH_SHA_AFTER" = "$POLYH_SHA_BEFORE" ] ||
  die "clean-room poly.h changed during mutation execution"

build_zero_count="$(
  grep -l '^0$' "$EXITS"/*_goto_build_exit_code.txt | wc -l
)"
full_expected_exit_count="$(
  grep -l '^10$' "$EXITS"/*_full_model_exit_code.txt | wc -l
)"
witness_expected_exit_count="$(
  grep -l '^10$' "$EXITS"/*_targeted_witness_exit_code.txt | wc -l
)"
killed_count="$(
  awk -F'|' '/^M[1-4]_/ && $10 == "PASS" {count++} END {print count+0}' \
    "$SUMMARY"
)"
target_failure_total="$(
  awk -F'|' '/^M[1-4]_/ {sum += $4} END {print sum+0}' "$SUMMARY"
)"
unexpected_failure_total="$(
  awk -F'|' '/^M[1-4]_/ {sum += $5} END {print sum+0}' "$SUMMARY"
)"
unknown_total="$(
  awk -F'|' '/^M[1-4]_/ {sum += $6} END {print sum+0}' "$SUMMARY"
)"
primary_failure_count="$(
  awk -F'|' '/^M[1-4]_/ {sum += $7} END {print sum+0}' "$SUMMARY"
)"
witness_marker_count="$(
  awk -F'|' '/^M[1-4]_/ {sum += $9} END {print sum+0}' "$SUMMARY"
)"

{
  echo
  echo "=== B5.8 FINAL VERDICT ==="
  echo "MUTANT_COUNT=${#MUTANTS[@]}"
  echo "MUTANT_SOURCE_COUNT=$(find "$MUTATIONS" -mindepth 2 -maxdepth 2 -type f -name 'poly.c' | wc -l)"
  echo "MUTATION_DIFF_COUNT=$(find "$MUTATIONS" -mindepth 2 -maxdepth 2 -type f -name 'mutation.diff' | wc -l)"
  echo "GOTO_BUILD_ZERO_EXIT_COUNT=$build_zero_count"
  echo "VALIDATED_GOTO_COUNT=$(find "$INSPECT" -maxdepth 1 -type f -name '*_validate_goto_binary.txt' | wc -l)"
  echo "REACHABLE_MUTATED_PRODUCTION_COUNT=$(find "$INSPECT" -maxdepth 1 -type f -name '*_reachable_call_graph.txt' | wc -l)"
  echo "FULL_MODEL_EXPECTED_EXIT_COUNT=$full_expected_exit_count"
  echo "RELEVANT_T5_FAILURE_TOTAL=$target_failure_total"
  echo "UNEXPECTED_FAILURE_TOTAL=$unexpected_failure_total"
  echo "UNKNOWN_PROPERTY_TOTAL=$unknown_total"
  echo "PRIMARY_DETECTOR_FAILURE_COUNT=$primary_failure_count"
  echo "TARGETED_WITNESS_EXPECTED_EXIT_COUNT=$witness_expected_exit_count"
  echo "TARGETED_WITNESS_MARKER_COUNT=$witness_marker_count"
  echo "MUTANTS_KILLED=$killed_count"
  echo "MUTATION_SCORE=${killed_count}_OF_${#MUTANTS[@]}"
  echo "M1_NEXT_B_SAFE=KILLED_BY_T5_2_LOCALITY"
  echo "M2_WRITE_B=KILLED_BY_T5_1_FRAME"
  echo "M3_PREVIOUS_B_SAFE=KILLED_BY_T5_2_LOCALITY"
  echo "M4_SKIP_COEFFICIENT_255=KILLED_BY_T5_4_EXACT_EFFECT"
  echo "ALL_MUTANTS_COMPILED=PASS"
  echo "ALL_MUTANTS_SEMANTICALLY_KILLED=PASS"
  echo "ALL_MUTATION_FAILURES_RELEVANT=PASS"
  echo "ALL_COUNTEREXAMPLE_WITNESSES_CAPTURED=PASS"
  echo "CLEANROOM_SOURCE_HASH_UNCHANGED=PASS"
  echo "FROZEN_HARNESS_MANIFEST_UNCHANGED=PASS"
  echo "B5_8_STATUS=PASS"
  echo
  echo "=== OPERATION BOUNDARY ==="
  echo "MUTATION_EXECUTION=YES"
  echo "FROZEN_HARNESS_MODIFICATION=NO"
  echo "CLEANROOM_SOURCE_MODIFICATION=NO"
  echo "PRODUCTION_REPOSITORY_MODIFICATION=NO"
  echo "EARLIER_BATCH_MODIFICATION=NO"
} >> "$SUMMARY"

[ "$build_zero_count" -eq 4 ] ||
  die "not all semantic mutants compiled"
[ "$full_expected_exit_count" -eq 4 ] ||
  die "not all mutant full-model runs failed as expected"
[ "$witness_expected_exit_count" -eq 4 ] ||
  die "not all targeted mutant witnesses failed as expected"
[ "$killed_count" -eq 4 ] ||
  die "mutation score is not 4/4"
[ "$target_failure_total" -ge 4 ] ||
  die "too few relevant T5 mutation failures"
[ "$unexpected_failure_total" -eq 0 ] ||
  die "unrelated mutation failures detected"
[ "$unknown_total" -eq 0 ] ||
  die "unknown mutation property results detected"
[ "$primary_failure_count" -eq 4 ] ||
  die "not every primary detector failed"
[ "$witness_marker_count" -eq 4 ] ||
  die "not every targeted witness contains its detector marker"

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
echo "=== B5.8 FINAL SUMMARY ==="
grep -E \
  'MUTANT_COUNT=|MUTANT_SOURCE_COUNT=|MUTATION_DIFF_COUNT=|GOTO_BUILD_ZERO_EXIT_COUNT=|VALIDATED_GOTO_COUNT=|REACHABLE_MUTATED_PRODUCTION_COUNT=|FULL_MODEL_EXPECTED_EXIT_COUNT=|RELEVANT_T5_FAILURE_TOTAL=|UNEXPECTED_FAILURE_TOTAL=|UNKNOWN_PROPERTY_TOTAL=|PRIMARY_DETECTOR_FAILURE_COUNT=|TARGETED_WITNESS_EXPECTED_EXIT_COUNT=|TARGETED_WITNESS_MARKER_COUNT=|MUTANTS_KILLED=|MUTATION_SCORE=|M1_NEXT_B_SAFE=|M2_WRITE_B=|M3_PREVIOUS_B_SAFE=|M4_SKIP_COEFFICIENT_255=|ALL_MUTANTS_COMPILED=|ALL_MUTANTS_SEMANTICALLY_KILLED=|ALL_MUTATION_FAILURES_RELEVANT=|ALL_COUNTEREXAMPLE_WITNESSES_CAPTURED=|CLEANROOM_SOURCE_HASH_UNCHANGED=|FROZEN_HARNESS_MANIFEST_UNCHANGED=|B5_8_STATUS=|MUTATION_EXECUTION=|FROZEN_HARNESS_MODIFICATION=|CLEANROOM_SOURCE_MODIFICATION=|PRODUCTION_REPOSITORY_MODIFICATION=|EARLIER_BATCH_MODIFICATION=' \
  "$SUMMARY"

echo
echo "B5_8_DIRECTORY=$RUN"
echo "B5_8_SUMMARY=$SUMMARY"
echo "============================================================"
