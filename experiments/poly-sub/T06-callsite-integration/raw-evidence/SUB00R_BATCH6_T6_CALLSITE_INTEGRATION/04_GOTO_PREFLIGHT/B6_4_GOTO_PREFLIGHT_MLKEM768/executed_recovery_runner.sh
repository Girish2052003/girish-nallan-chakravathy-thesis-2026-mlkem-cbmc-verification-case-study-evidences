#!/usr/bin/env bash
set -euo pipefail
umask 0022

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
SRC="$ROOT/source/mlkem"

FAMILY="$B6/03_HARNESS_FREEZE/frozen_harness_family_v1"
PREFLIGHT_PARENT="$B6/04_GOTO_PREFLIGHT"
PREFLIGHT="$PREFLIGHT_PARENT/B6_4_GOTO_PREFLIGHT_MLKEM768"
PACKAGE="$HOME/Downloads/SUB_T6_B6_3_4_HARNESS_GOTO_PREFLIGHT.tar.gz"

EXPECTED_POLYC_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_POLYH_SHA="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_COMPRESSC_SHA="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESSH_SHA="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"

echo "============================================================"
echo "SUB-T6 B6.4 REACHABILITY-AWARE GOTO PREFLIGHT RECOVERY"
echo "============================================================"
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "ROOT=$ROOT"
echo "FAMILY=$FAMILY"
echo "PREFLIGHT=$PREFLIGHT"
echo "PACKAGE=$PACKAGE"

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

SUCCESS=0

cleanup()
{
    rc=$?

    if [ "$SUCCESS" -ne 1 ] && [ -d "$PREFLIGHT" ]; then
        stamp="$(date -u +%Y%m%dT%H%M%SZ)"
        chmod -R u+rwX "$PREFLIGHT" 2>/dev/null || true
        failed="${PREFLIGHT}_FAILED_RECOVERY_${stamp}"
        mv "$PREFLIGHT" "$failed" 2>/dev/null || true
        echo "FAILED_RECOVERY_PREFLIGHT_PRESERVED=$failed" >&2
    fi

    exit "$rc"
}
trap cleanup EXIT

for path in "$ROOT" "$B6" "$SRC" "$FAMILY" "$PREFLIGHT_PARENT"; do
    [ -d "$path" ] || die "required directory missing: $path"
done

[ -f "$FAMILY/SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256" ] ||
    die "frozen B6.3 manifest missing"

[ ! -e "$PREFLIGHT" ] ||
    die "new B6.4 preflight directory already exists: $PREFLIGHT"

[ ! -e "$PACKAGE" ] ||
    die "final B6.3+B6.4 package already exists: $PACKAGE"

for tool in \
    sha256sum goto-cc goto-instrument cbmc python3 \
    awk grep sed find sort wc readlink tar
do
    command -v "$tool" >/dev/null 2>&1 ||
        die "required tool missing: $tool"
done

CBMC_VERSION="$(cbmc --version | sed -n '1p')"
GOTOCC_VERSION="$(goto-cc --version 2>&1 | sed -n '1p')"
GOTOINSTRUMENT_VERSION="$(goto-instrument --version 2>&1 | sed -n '1p')"

echo "$CBMC_VERSION" | grep -q '6\.9\.0' ||
    die "CBMC version is not 6.9.0"
echo "$GOTOCC_VERSION" | grep -q '6\.9\.0' ||
    die "goto-cc version is not 6.9.0"
echo "$GOTOINSTRUMENT_VERSION" | grep -q '6\.9\.0' ||
    die "goto-instrument version is not 6.9.0"

check_hash()
{
    file="$1"
    expected="$2"

    [ -f "$file" ] || die "source file missing: $file"

    actual="$(sha256sum "$file" | awk '{print $1}')"
    [ "$actual" = "$expected" ] ||
        die "source hash mismatch: $file"
}

check_hash "$SRC/src/poly.c" "$EXPECTED_POLYC_SHA"
check_hash "$SRC/src/poly.h" "$EXPECTED_POLYH_SHA"
check_hash "$SRC/src/compress.c" "$EXPECTED_COMPRESSC_SHA"
check_hash "$SRC/src/compress.h" "$EXPECTED_COMPRESSH_SHA"

echo
echo "--- Revalidating frozen B6.3 family ---"
(
    cd "$FAMILY"
    sha256sum -c SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256
)

[ "$(stat -c '%a' "$FAMILY")" = "555" ] ||
    die "B6.3 family directory is not frozen mode 555"

bad_mode_count=0

while IFS= read -r -d '' path; do
    mode="$(stat -c '%a' "$path")"

    case "$mode" in
        444|555)
            ;;
        *)
            echo "UNEXPECTED_FROZEN_FILE_MODE=$mode FILE=$path" >&2
            bad_mode_count=$((bad_mode_count + 1))
            ;;
    esac
done < <(find "$FAMILY" -type f -print0)

[ "$bad_mode_count" -eq 0 ] ||
    die "one or more B6.3 files have modes other than 444 or 555"

bad_directory_mode_count=0

while IFS= read -r -d '' path; do
    mode="$(stat -c '%a' "$path")"

    if [ "$mode" != "555" ]; then
        echo "UNEXPECTED_FROZEN_DIRECTORY_MODE=$mode DIRECTORY=$path" >&2
        bad_directory_mode_count=$((bad_directory_mode_count + 1))
    fi
done < <(find "$FAMILY" -type d -print0)

[ "$bad_directory_mode_count" -eq 0 ] ||
    die "one or more B6.3 directories are not mode 555"

echo "B6_3_FILE_MODE_AUDIT=PASS"
echo "B6_3_DIRECTORY_MODE_AUDIT=PASS"

mkdir -p \
    "$PREFLIGHT/build" \
    "$PREFLIGHT/commands" \
    "$PREFLIGHT/logs" \
    "$PREFLIGHT/inspection" \
    "$PREFLIGHT/exit_codes"

RUNNER_PATH="$(readlink -f "$0")"
cp "$RUNNER_PATH" "$PREFLIGHT/executed_recovery_runner.sh"

CASES=(
    "callsite_precondition"
    "callsite_exactness"
    "callsite_frame"
    "sub_reduce_handoff"
    "tomsg_precondition"
)

HARNESSES=(
    "sub_t6_callsite_precondition_harness.c"
    "sub_t6_callsite_exactness_harness.c"
    "sub_t6_callsite_frame_harness.c"
    "sub_t6_sub_reduce_handoff_harness.c"
    "sub_t6_tomsg_precondition_harness.c"
)

REQUIRE_REDUCE=(
    "no"
    "no"
    "no"
    "yes"
    "yes"
)

REQUIRE_TOMSG=(
    "no"
    "no"
    "no"
    "no"
    "yes"
)

SUMMARY="$PREFLIGHT/SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt"
FREEZE="$PREFLIGHT/SUB_T6_B6_4_EXECUTION_INPUT_FREEZE.md"
MANIFEST="$PREFLIGHT/SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256"

cat > "$FREEZE" <<EOF
# SUB-T6 B6.4 — Reachability-Aware Execution Input Freeze

Captured UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)

Frozen B6.3 family: $FAMILY

Source root: $SRC
poly.c SHA-256: $EXPECTED_POLYC_SHA
poly.h SHA-256: $EXPECTED_POLYH_SHA
compress.c SHA-256: $EXPECTED_COMPRESSC_SHA
compress.h SHA-256: $EXPECTED_COMPRESSH_SHA

CBMC: $CBMC_VERSION
goto-cc: $GOTOCC_VERSION
goto-instrument: $GOTOINSTRUMENT_VERSION

Correction from the preserved failed preflight:
global --show-loops output is not treated as reachability evidence.
For each case, the transitive closure rooted at main is derived from
--reachable-call-graph. Only loops whose owning functions occur in that
reachable closure are included in the frozen unwindset.

This stage constructs and inspects GOTO binaries and inventories properties.
It does not execute proof solving.
EOF

printf '%s\n' \
    "SUB-T6 B6.4 REACHABILITY-AWARE GOTO PREFLIGHT SUMMARY" \
    "" \
    "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "CBMC_VERSION=$CBMC_VERSION" \
    "GOTOCC_VERSION=$GOTOCC_VERSION" \
    "GOTOINSTRUMENT_VERSION=$GOTOINSTRUMENT_VERSION" \
    "POLYC_SHA256=$EXPECTED_POLYC_SHA" \
    "POLYH_SHA256=$EXPECTED_POLYH_SHA" \
    "COMPRESSC_SHA256=$EXPECTED_COMPRESSC_SHA" \
    "COMPRESSH_SHA256=$EXPECTED_COMPRESSH_SHA" \
    "" \
    "CASE|GOTO_SHA256|REACHABLE_FUNCTION_COUNT|GLOBAL_LOOP_COUNT|REACHABLE_LOOP_COUNT|PROPERTY_COUNT|UNWINDSET" \
    > "$SUMMARY"

for idx in "${!CASES[@]}"; do
    case_name="${CASES[$idx]}"
    harness_name="${HARNESSES[$idx]}"
    require_reduce="${REQUIRE_REDUCE[$idx]}"
    require_tomsg="${REQUIRE_TOMSG[$idx]}"

    harness="$FAMILY/harnesses/$harness_name"
    goto_file="$PREFLIGHT/build/${case_name}.goto"

    [ -f "$harness" ] || die "harness missing: $harness"

    build_cmd=(
        goto-cc
        -std=c90
        -DMLK_CONFIG_PARAMETER_SET=768
        -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00r_b6
        -DMLK_CONFIG_NO_ASM=1
        -DMLK_CONFIG_CUSTOM_ZEROIZE=1
        -include "$FAMILY/support/sub00r_b6_fail_closed_zeroize.h"
        -include "$FAMILY/support/sub00r_b6_verify_pragma_scope.h"
        -I"$SRC"
        -I"$SRC/src"
        -I"$FAMILY/support"
        "$harness"
        "$SRC/src/poly.c"
    )

    if [ "$require_tomsg" = "yes" ]; then
        build_cmd+=("$SRC/src/compress.c")
    fi

    build_cmd+=(
        "$FAMILY/support/sub00r_b6_optblocker_zero.c"
        -o "$goto_file"
    )

    {
        printf 'COMMAND:'
        printf ' %q' "${build_cmd[@]}"
        printf '\n'
    } > "$PREFLIGHT/commands/${case_name}_goto_build_command.txt"

    set +e
    "${build_cmd[@]}" \
        >"$PREFLIGHT/logs/${case_name}_goto_build_stdout.txt" \
        2>"$PREFLIGHT/logs/${case_name}_goto_build_stderr.txt"
    rc=$?
    set -e

    printf '%s\n' "$rc" \
        > "$PREFLIGHT/exit_codes/${case_name}_goto_build_exit_code.txt"

    [ "$rc" -eq 0 ] ||
        die "goto-cc failed for $case_name"

    [ -s "$goto_file" ] ||
        die "GOTO binary missing or empty for $case_name"

    sha256sum "$goto_file" > "$goto_file.sha256"

    goto-instrument --validate-goto-binary "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_validate_goto_binary.txt" 2>&1

    goto-instrument --show-loops "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_show_loops.txt" 2>&1

    goto-instrument --reachable-call-graph "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_reachable_call_graph.txt" 2>&1

    goto-instrument --list-goto-functions "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_list_goto_functions.txt" 2>&1

    goto-instrument --list-undefined-functions "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_undefined_functions.txt" 2>&1

    goto-instrument --list-calls-args "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_calls_and_arguments.txt" 2>&1

    python3 - \
        "$case_name" \
        "$PREFLIGHT/inspection/${case_name}_reachable_call_graph.txt" \
        "$PREFLIGHT/inspection/${case_name}_show_loops.txt" \
        "$PREFLIGHT/inspection/${case_name}_undefined_functions.txt" \
        "$PREFLIGHT/inspection/${case_name}_reachable_functions.txt" \
        "$PREFLIGHT/inspection/${case_name}_reachable_loops.tsv" \
        "$PREFLIGHT/inspection/${case_name}_frozen_unwindset.txt" \
        "$require_reduce" \
        "$require_tomsg" <<'PY'
import re
import sys
from collections import defaultdict, deque
from pathlib import Path

(
    case_name,
    graph_path,
    loops_path,
    undefined_path,
    reachable_out,
    loops_out,
    unwind_out,
    require_reduce,
    require_tomsg,
) = sys.argv[1:]

graph_text = Path(graph_path).read_text(encoding="utf-8", errors="replace")
loops_text = Path(loops_path).read_text(encoding="utf-8", errors="replace")
undefined_text = Path(undefined_path).read_text(encoding="utf-8", errors="replace")

edges = defaultdict(set)

for line in graph_text.splitlines():
    match = re.fullmatch(r"(\S+)\s+->\s+(\S+)", line.strip())
    if match:
        edges[match.group(1)].add(match.group(2))

reachable = set()
queue = deque(["main"])

while queue:
    function = queue.popleft()
    if function in reachable:
        continue
    reachable.add(function)
    for target in sorted(edges.get(function, ())):
        if target not in reachable:
            queue.append(target)

required = {"main", "mlk_sub00r_b6_poly_sub"}

if require_reduce == "yes":
    required.add("mlk_sub00r_b6_poly_reduce")

if require_tomsg == "yes":
    required.add("mlk_sub00r_b6_poly_tomsg")

missing_required = sorted(required - reachable)

if missing_required:
    raise SystemExit(
        f"{case_name}: required reachable functions missing: "
        + ",".join(missing_required)
    )

if require_reduce == "no":
    forbidden_reduce = {
        "mlk_sub00r_b6_poly_reduce",
        "mlk_poly_reduce_c",
    }
    unexpected = sorted(forbidden_reduce & reachable)
    if unexpected:
        raise SystemExit(
            f"{case_name}: unexpected reachable reduction functions: "
            + ",".join(unexpected)
        )

if require_tomsg == "no":
    forbidden_tomsg = {"mlk_sub00r_b6_poly_tomsg"}
    unexpected = sorted(forbidden_tomsg & reachable)
    if unexpected:
        raise SystemExit(
            f"{case_name}: unexpected reachable tomsg functions: "
            + ",".join(unexpected)
        )

loop_records = []
current_id = None

for line in loops_text.splitlines():
    match_loop = re.fullmatch(r"Loop\s+(\S+):", line.strip())
    if match_loop:
        current_id = match_loop.group(1)
        continue

    if current_id is not None:
        match_function = re.search(r"\bfunction\s+(\S+)\s*$", line)
        if match_function:
            loop_records.append(
                (current_id, match_function.group(1))
            )
            current_id = None

reachable_loops = sorted(
    (loop_id, function)
    for loop_id, function in loop_records
    if function in reachable
)

if not reachable_loops:
    raise SystemExit(f"{case_name}: no reachable loops found")

loop_ids = [loop_id for loop_id, _ in reachable_loops]

if len(loop_ids) != len(set(loop_ids)):
    raise SystemExit(f"{case_name}: duplicate reachable loop IDs")

required_loop_owners = {
    "sub_t6_assume_callsite_inputs",
    "mlk_sub00r_b6_poly_sub",
}

owners = {function for _, function in reachable_loops}
missing_owners = sorted(required_loop_owners - owners)

if missing_owners:
    raise SystemExit(
        f"{case_name}: required reachable loop owners missing: "
        + ",".join(missing_owners)
    )

if require_reduce == "yes" and not (
    {"mlk_sub00r_b6_poly_reduce", "mlk_poly_reduce_c"} & owners
):
    raise SystemExit(
        f"{case_name}: reachable reduction loop owner missing"
    )

if require_tomsg == "yes" and (
    "mlk_sub00r_b6_poly_tomsg" not in owners
):
    raise SystemExit(
        f"{case_name}: reachable tomsg loop owner missing"
    )

undefined = []
for raw_line in undefined_text.splitlines():
    line = raw_line.strip()
    if not line or line.startswith("Reading GOTO program"):
        continue
    undefined.append(line)

unexpected_undefined = sorted(
    name for name in undefined
    if name != "nondet_int16_t"
    and not name.startswith("__CPROVER_")
)

if unexpected_undefined:
    raise SystemExit(
        f"{case_name}: unexpected undefined functions: "
        + ",".join(unexpected_undefined)
    )

Path(reachable_out).write_text(
    "\n".join(sorted(reachable)) + "\n",
    encoding="utf-8",
)

Path(loops_out).write_text(
    "LOOP_ID\tOWNER_FUNCTION\n"
    + "".join(
        f"{loop_id}\t{function}\n"
        for loop_id, function in reachable_loops
    ),
    encoding="utf-8",
)

unwindset = ",".join(
    f"{loop_id}:257"
    for loop_id in loop_ids
)

Path(unwind_out).write_text(
    unwindset + "\n",
    encoding="utf-8",
)

print(f"REACHABLE_FUNCTION_COUNT={len(reachable)}")
print(f"GLOBAL_LOOP_COUNT={len(loop_records)}")
print(f"REACHABLE_LOOP_COUNT={len(reachable_loops)}")
print(f"UNEXPECTED_UNDEFINED_FUNCTION_COUNT={len(unexpected_undefined)}")
print(f"UNWINDSET={unwindset}")
PY

    parser_output="$(
        python3 - \
            "$case_name" \
            "$PREFLIGHT/inspection/${case_name}_reachable_call_graph.txt" \
            "$PREFLIGHT/inspection/${case_name}_show_loops.txt" \
            "$PREFLIGHT/inspection/${case_name}_undefined_functions.txt" \
            /dev/null /dev/null /dev/null \
            "$require_reduce" "$require_tomsg" <<'PY'
import re
import sys
from collections import defaultdict, deque
from pathlib import Path

case_name, graph_path, loops_path, undefined_path, _, _, _, require_reduce, require_tomsg = sys.argv[1:]

graph_text = Path(graph_path).read_text(errors="replace")
loops_text = Path(loops_path).read_text(errors="replace")
edges = defaultdict(set)

for line in graph_text.splitlines():
    m = re.fullmatch(r"(\S+)\s+->\s+(\S+)", line.strip())
    if m:
        edges[m.group(1)].add(m.group(2))

reachable = set()
queue = deque(["main"])
while queue:
    f = queue.popleft()
    if f in reachable:
        continue
    reachable.add(f)
    queue.extend(sorted(edges.get(f, set()) - reachable))

loops = []
current = None
for line in loops_text.splitlines():
    m = re.fullmatch(r"Loop\s+(\S+):", line.strip())
    if m:
        current = m.group(1)
        continue
    if current is not None:
        m = re.search(r"\bfunction\s+(\S+)\s*$", line)
        if m:
            loops.append((current, m.group(1)))
            current = None

reachable_loops = sorted(
    (loop_id, owner)
    for loop_id, owner in loops
    if owner in reachable
)

print(f"REACHABLE_FUNCTION_COUNT={len(reachable)}")
print(f"GLOBAL_LOOP_COUNT={len(loops)}")
print(f"REACHABLE_LOOP_COUNT={len(reachable_loops)}")
PY
    )"

    reachable_function_count="$(
        printf '%s\n' "$parser_output" |
        awk -F= '/^REACHABLE_FUNCTION_COUNT=/{print $2}'
    )"
    global_loop_count="$(
        printf '%s\n' "$parser_output" |
        awk -F= '/^GLOBAL_LOOP_COUNT=/{print $2}'
    )"
    reachable_loop_count="$(
        printf '%s\n' "$parser_output" |
        awk -F= '/^REACHABLE_LOOP_COUNT=/{print $2}'
    )"

    unwindset="$(
        cat "$PREFLIGHT/inspection/${case_name}_frozen_unwindset.txt"
    )"

    [ -n "$unwindset" ] ||
        die "empty reachability-derived unwindset for $case_name"

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
    } > "$PREFLIGHT/commands/${case_name}_show_properties_command.txt"

    "${property_cmd[@]}" \
        >"$PREFLIGHT/inspection/${case_name}_show_properties.txt" \
        2>"$PREFLIGHT/inspection/${case_name}_show_properties_stderr.txt"

    property_count="$(
        grep -Ec '^Property[[:space:]]+' \
            "$PREFLIGHT/inspection/${case_name}_show_properties.txt" ||
        true
    )"

    [ "$property_count" -ge 1 ] ||
        die "no properties discovered for $case_name"

    goto_sha="$(awk '{print $1}' "$goto_file.sha256")"

    printf '%s|%s|%s|%s|%s|%s|%s\n' \
        "$case_name" \
        "$goto_sha" \
        "$reachable_function_count" \
        "$global_loop_count" \
        "$reachable_loop_count" \
        "$property_count" \
        "$unwindset" \
        >> "$SUMMARY"

    echo \
      "CASE=$case_name BUILD=PASS VALIDATE=PASS REACHABLE_FUNCTIONS=$reachable_function_count GLOBAL_LOOPS=$global_loop_count REACHABLE_LOOPS=$reachable_loop_count PROPERTIES=$property_count"
done

case_count="${#CASES[@]}"
goto_count="$(
    find "$PREFLIGHT/build" -maxdepth 1 -type f -name '*.goto' |
    wc -l
)"
checksum_count="$(
    find "$PREFLIGHT/build" -maxdepth 1 -type f -name '*.goto.sha256' |
    wc -l
)"
zero_exit_count="$(
    grep -l '^0$' "$PREFLIGHT/exit_codes"/*_goto_build_exit_code.txt |
    wc -l
)"
unwindset_count="$(
    find "$PREFLIGHT/inspection" -maxdepth 1 \
        -type f -name '*_frozen_unwindset.txt' |
    wc -l
)"
reachable_files_count="$(
    find "$PREFLIGHT/inspection" -maxdepth 1 \
        -type f -name '*_reachable_functions.txt' |
    wc -l
)"
property_files_count="$(
    find "$PREFLIGHT/inspection" -maxdepth 1 \
        -type f -name '*_show_properties.txt' |
    wc -l
)"

[ "$goto_count" -eq 5 ] || die "expected five GOTO binaries"
[ "$checksum_count" -eq 5 ] || die "expected five GOTO checksums"
[ "$zero_exit_count" -eq 5 ] || die "expected five zero build exits"
[ "$unwindset_count" -eq 5 ] || die "expected five unwindsets"
[ "$reachable_files_count" -eq 5 ] || die "expected five reachable-function files"
[ "$property_files_count" -eq 5 ] || die "expected five property inventories"

{
    echo
    echo "=== PREFLIGHT VERDICT ==="
    echo "CASE_COUNT=$case_count"
    echo "GOTO_BINARY_COUNT=$goto_count"
    echo "GOTO_CHECKSUM_COUNT=$checksum_count"
    echo "BUILD_EXIT_ZERO_COUNT=$zero_exit_count"
    echo "REACHABILITY_DERIVED_UNWINDSET_COUNT=$unwindset_count"
    echo "REACHABLE_FUNCTION_INVENTORY_COUNT=$reachable_files_count"
    echo "PROPERTY_INVENTORY_COUNT=$property_files_count"
    echo "POSITIVE_HARNESS_COUNT=5"
    echo "ALL_GOTO_BUILDS=PASS"
    echo "ALL_GOTO_BINARY_VALIDATIONS=PASS"
    echo "ALL_REQUIRED_PRODUCTION_CALLS_REACHABLE=PASS"
    echo "ALL_UNEXPECTED_REDUCTION_REACHABILITY_CHECKS=PASS"
    echo "ALL_REACHABLE_LOOP_FILTERS=PASS"
    echo "ALL_UNDEFINED_FUNCTION_AUDITS=PASS"
    echo "ALL_PROPERTY_INVENTORIES_PRESENT=PASS"
    echo "B6_4_STATUS=PASS"
    echo
    echo "=== OPERATION BOUNDARY ==="
    echo "B6_3_REUSED_WITHOUT_MODIFICATION=YES"
    echo "GOTO_MODEL_CREATION=YES"
    echo "CBMC_PROOF_EXECUTION=NO"
    echo "PRODUCTION_SOURCE_MODIFICATION=NO"
    echo "BATCH5_MODIFICATION=NO"
} >> "$SUMMARY"

(
    cd "$PREFLIGHT"
    find . -type f \
        ! -name "$(basename "$MANIFEST")" \
        -print0 |
    sort -z |
    xargs -0 sha256sum > "$MANIFEST"

    sha256sum -c "$MANIFEST"
)

find "$PREFLIGHT" -type f -exec chmod 0444 {} +
chmod 0555 "$PREFLIGHT/executed_recovery_runner.sh"
find "$PREFLIGHT" -type d -exec chmod 0555 {} +

tar -C "$B6" -czf "$PACKAGE" \
    "03_HARNESS_FREEZE/frozen_harness_family_v1" \
    "04_GOTO_PREFLIGHT/B6_4_GOTO_PREFLIGHT_MLKEM768"

SUCCESS=1
trap - EXIT

echo
echo "=== FINAL B6.4 RECOVERY SUMMARY ==="
grep -E \
  'CASE_COUNT=|GOTO_BINARY_COUNT=|GOTO_CHECKSUM_COUNT=|BUILD_EXIT_ZERO_COUNT=|REACHABILITY_DERIVED_UNWINDSET_COUNT=|REACHABLE_FUNCTION_INVENTORY_COUNT=|PROPERTY_INVENTORY_COUNT=|POSITIVE_HARNESS_COUNT=|ALL_GOTO_BUILDS=|ALL_GOTO_BINARY_VALIDATIONS=|ALL_REQUIRED_PRODUCTION_CALLS_REACHABLE=|ALL_UNEXPECTED_REDUCTION_REACHABILITY_CHECKS=|ALL_REACHABLE_LOOP_FILTERS=|ALL_UNDEFINED_FUNCTION_AUDITS=|ALL_PROPERTY_INVENTORIES_PRESENT=|B6_4_STATUS=|B6_3_REUSED_WITHOUT_MODIFICATION=|GOTO_MODEL_CREATION=|CBMC_PROOF_EXECUTION=|PRODUCTION_SOURCE_MODIFICATION=|BATCH5_MODIFICATION=' \
  "$SUMMARY"

echo
echo "--- Final B6.3+B6.4 package ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$PACKAGE"
sha256sum "$PACKAGE"

echo
echo "B63_FROZEN_FAMILY_REVALIDATED=PASS"
echo "B63_REUSED_WITHOUT_MODIFICATION=YES"
echo "B64_GOTO_BINARY_COUNT=5"
echo "B64_ALL_GOTO_BUILDS=PASS"
echo "B64_ALL_GOTO_VALIDATIONS=PASS"
echo "B64_ALL_REQUIRED_CALLS_REACHABLE=PASS"
echo "B64_REACHABILITY_AWARE_LOOP_FILTER=PASS"
echo "B64_ALL_UNWINDSETS_MODEL_DERIVED=PASS"
echo "B64_ALL_UNDEFINED_FUNCTION_AUDITS=PASS"
echo "B64_ALL_PROPERTY_INVENTORIES=PASS"
echo "B64_GOTO_CONSTRUCTED=YES"
echo "B64_CBMC_PROOF_EXECUTED=NO"
echo "B64_PRODUCTION_MODIFIED=NO"
echo "B64_BATCH5_MODIFIED=NO"
echo "B64_UPLOAD_REQUIRED=YES"
echo "B64_STATUS=PASS"
