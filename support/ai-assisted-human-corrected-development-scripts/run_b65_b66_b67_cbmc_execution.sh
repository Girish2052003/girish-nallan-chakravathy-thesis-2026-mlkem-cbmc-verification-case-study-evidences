#!/usr/bin/env bash
set -euo pipefail
umask 0022

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
SRC="$ROOT/source/mlkem"

FAMILY="$B6/03_HARNESS_FREEZE/frozen_harness_family_v1"
PREFLIGHT="$B6/04_GOTO_PREFLIGHT/B6_4_GOTO_PREFLIGHT_MLKEM768"

B65="$B6/05_POSITIVE_EXECUTION/B6_5_POSITIVE_EXECUTION_MLKEM768_RUN1"
B66="$B6/06_REACHABILITY/B6_6_REACHABILITY_MLKEM768_RUN1"
B67="$B6/07_EXPECTED_FAILURES/B6_7_EXPECTED_FAILURES_MLKEM768_RUN1"

PACKAGE="$HOME/Downloads/SUB_T6_B6_5_6_7_CBMC_EXECUTION.tar.gz"

EXPECTED_POLYC_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_POLYH_SHA="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_COMPRESSC_SHA="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESSH_SHA="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"

echo "============================================================"
echo "SUB-T6 COMBINED B6.5 + B6.6 + B6.7 CBMC EXECUTION"
echo "============================================================"
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "ROOT=$ROOT"
echo "FAMILY=$FAMILY"
echo "PREFLIGHT=$PREFLIGHT"
echo "B65=$B65"
echo "B66=$B66"
echo "B67=$B67"
echo "PACKAGE=$PACKAGE"

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

SUCCESS=0
ACTIVE_RUN=""

cleanup()
{
    rc=$?

    if [ "$SUCCESS" -ne 1 ] && [ -n "$ACTIVE_RUN" ] && [ -d "$ACTIVE_RUN" ]; then
        stamp="$(date -u +%Y%m%dT%H%M%SZ)"
        chmod -R u+rwX "$ACTIVE_RUN" 2>/dev/null || true
        failed="${ACTIVE_RUN}_FAILED_${stamp}"
        mv "$ACTIVE_RUN" "$failed" 2>/dev/null || true
        echo "FAILED_ATTEMPT_PRESERVED=$failed" >&2
    fi

    exit "$rc"
}
trap cleanup EXIT

for path in \
    "$ROOT" "$B6" "$SRC" "$FAMILY" "$PREFLIGHT" \
    "$B6/05_POSITIVE_EXECUTION" \
    "$B6/06_REACHABILITY" \
    "$B6/07_EXPECTED_FAILURES"
do
    [ -d "$path" ] || die "required directory missing: $path"
done

[ ! -e "$B65" ] || die "B6.5 run already exists: $B65"
[ ! -e "$B66" ] || die "B6.6 run already exists: $B66"
[ ! -e "$B67" ] || die "B6.7 run already exists: $B67"
[ ! -e "$PACKAGE" ] || die "output package already exists: $PACKAGE"

for tool in \
    sha256sum cbmc goto-cc goto-instrument timeout python3 \
    find sort grep awk sed wc readlink tar cmp tr
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
GOTOINSTRUMENT_VERSION="$(goto-instrument --version 2>&1 | sed -n '1p')"

echo "$CBMC_VERSION" | grep -q '6\.9\.0' ||
    die "CBMC is not frozen version 6.9.0"
echo "$GOTOCC_VERSION" | grep -q '6\.9\.0' ||
    die "goto-cc is not frozen version 6.9.0"
echo "$GOTOINSTRUMENT_VERSION" | grep -q '6\.9\.0' ||
    die "goto-instrument is not frozen version 6.9.0"

check_hash()
{
    local file="$1"
    local expected="$2"
    local actual

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
echo "--- Revalidating frozen B6.3 and B6.4 evidence ---"

(
    cd "$FAMILY"
    sha256sum -c SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256
)

(
    cd "$PREFLIGHT"
    sha256sum -c SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256
)

grep -q '^B6_4_STATUS=PASS$' \
    "$PREFLIGHT/SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt" ||
    die "B6.4 PASS verdict missing"

[ "$(find "$FAMILY/harnesses" -maxdepth 1 -type f -name '*.c' | wc -l)" -eq 5 ] ||
    die "frozen positive harness count is not five"

[ "$(find "$PREFLIGHT/build" -maxdepth 1 -type f -name '*.goto' | wc -l)" -eq 5 ] ||
    die "frozen GOTO binary count is not five"

# ---------------------------------------------------------------------------
# Shared Python auditor for successful JSON proof results.
# ---------------------------------------------------------------------------

write_positive_auditor()
{
    local output="$1"

    cat > "$output" <<'PY'
#!/usr/bin/env python3
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
unknown = sum(
    1 for _, status, _ in unique
    if status not in {"SUCCESS", "FAILURE"}
)
total = len(unique)

lines = [
    f"SUCCESS={success}",
    f"FAILURE={failure}",
    f"UNKNOWN={unknown}",
    f"TOTAL_RESULTS={total}",
]

for prop, status, desc in unique:
    lines.append(
        f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}"
    )

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if total < 1:
    raise SystemExit("NO_PROPERTY_RESULTS")
if failure != 0:
    raise SystemExit(f"FAILURE_RESULTS={failure}")
if unknown != 0:
    raise SystemExit(f"UNKNOWN_RESULTS={unknown}")
if success != total:
    raise SystemExit(
        f"SUCCESS_TOTAL_MISMATCH={success}/{total}"
    )
PY

    chmod 0755 "$output"
}

write_expected_failure_auditor()
{
    local output="$1"

    cat > "$output" <<'PY'
#!/usr/bin/env python3
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
    item = (prop, status, desc)

    if item not in seen:
        seen.add(item)
        unique.append(item)

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

target_failures = sum(
    1 for _, status, _ in target
    if status == "FAILURE"
)

other_failures = sum(
    1
    for prop, status, desc in unique
    if status == "FAILURE"
    and marker not in prop
    and marker not in desc
)

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
    f"TOTAL_RESULTS={len(unique)}",
    f"TARGET_PROPERTY={target_property}",
]

for prop, status, desc in unique:
    lines.append(
        f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}"
    )

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if len(unique) < 1:
    raise SystemExit("NO_PROPERTY_RESULTS")
if len(target) != 1:
    raise SystemExit(f"TARGET_RECORD_COUNT={len(target)}")
if target_failures != 1:
    raise SystemExit(
        f"TARGET_FAILURE_COUNT={target_failures}"
    )
if other_failures != 0:
    raise SystemExit(
        f"OTHER_FAILURE_COUNT={other_failures}"
    )
if unknown != 0:
    raise SystemExit(f"UNKNOWN_COUNT={unknown}")
if not target_property:
    raise SystemExit("TARGET_PROPERTY_MISSING")
PY

    chmod 0755 "$output"
}

write_reachability_parser()
{
    local output="$1"

    cat > "$output" <<'PY'
#!/usr/bin/env python3
import re
import sys
from collections import defaultdict, deque
from pathlib import Path

(
    graph_path,
    loops_path,
    undefined_path,
    reachable_out,
    loops_out,
    unwind_out,
    required_csv,
) = sys.argv[1:]

graph_text = Path(graph_path).read_text(
    encoding="utf-8", errors="replace"
)
loops_text = Path(loops_path).read_text(
    encoding="utf-8", errors="replace"
)
undefined_text = Path(undefined_path).read_text(
    encoding="utf-8", errors="replace"
)

edges = defaultdict(set)

for line in graph_text.splitlines():
    match = re.fullmatch(
        r"(\S+)\s+->\s+(\S+)",
        line.strip(),
    )
    if match:
        edges[match.group(1)].add(match.group(2))

reachable = set()
queue = deque(["main"])

while queue:
    function = queue.popleft()

    if function in reachable:
        continue

    reachable.add(function)

    for target in sorted(edges.get(function, set())):
        if target not in reachable:
            queue.append(target)

required = {
    item for item in required_csv.split(",")
    if item
}

missing = sorted(required - reachable)

if missing:
    raise SystemExit(
        "REQUIRED_REACHABLE_FUNCTIONS_MISSING="
        + ",".join(missing)
    )

loop_records = []
current_id = None

for line in loops_text.splitlines():
    match_loop = re.fullmatch(
        r"Loop\s+(\S+):",
        line.strip(),
    )

    if match_loop:
        current_id = match_loop.group(1)
        continue

    if current_id is not None:
        match_function = re.search(
            r"\bfunction\s+(\S+)\s*$",
            line,
        )

        if match_function:
            loop_records.append(
                (current_id, match_function.group(1))
            )
            current_id = None

reachable_loops = sorted(
    (loop_id, owner)
    for loop_id, owner in loop_records
    if owner in reachable
)

if not reachable_loops:
    raise SystemExit("NO_REACHABLE_LOOPS")

loop_ids = [
    loop_id for loop_id, _ in reachable_loops
]

if len(loop_ids) != len(set(loop_ids)):
    raise SystemExit("DUPLICATE_REACHABLE_LOOP_IDS")

undefined = []

for raw_line in undefined_text.splitlines():
    line = raw_line.strip()

    if not line:
        continue
    if line.startswith("Reading GOTO program"):
        continue

    undefined.append(line)

allowed_undefined = {
    "nondet_int16_t",
    "nondet_unsigned",
}

unexpected = sorted(
    name for name in undefined
    if name not in allowed_undefined
    and not name.startswith("__CPROVER_")
)

if unexpected:
    raise SystemExit(
        "UNEXPECTED_UNDEFINED_FUNCTIONS="
        + ",".join(unexpected)
    )

Path(reachable_out).write_text(
    "\n".join(sorted(reachable)) + "\n",
    encoding="utf-8",
)

Path(loops_out).write_text(
    "LOOP_ID\tOWNER_FUNCTION\n"
    + "".join(
        f"{loop_id}\t{owner}\n"
        for loop_id, owner in reachable_loops
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
print(
    "UNEXPECTED_UNDEFINED_FUNCTION_COUNT="
    + str(len(unexpected))
)
print(f"UNWINDSET={unwindset}")
PY

    chmod 0755 "$output"
}

run_cbmc_timed()
{
    local resource_file="$1"
    local stdout_file="$2"
    local stderr_file="$3"
    shift 3

    local rc

    set +e

    if [ -n "$TIME_TOOL" ]; then
        "$TIME_TOOL" -v -o "$resource_file" \
            timeout --signal=TERM --kill-after=60s 21600s \
            "$@" >"$stdout_file" 2>"$stderr_file"
        rc=$?
    else
        timeout --signal=TERM --kill-after=60s 21600s \
            "$@" >"$stdout_file" 2>"$stderr_file"
        rc=$?
        echo "RESOURCE_TOOL=UNAVAILABLE" > "$resource_file"
    fi

    set -e
    return "$rc"
}

write_command()
{
    local output="$1"
    shift

    {
        printf 'COMMAND:'
        printf ' %q' "$@"
        printf '\n'
    } > "$output"
}

freeze_run()
{
    local run="$1"
    local manifest_name="$2"

    (
        cd "$run"

        find . -type f \
            ! -name "$manifest_name" \
            -print0 |
        sort -z |
        xargs -0 sha256sum > "$manifest_name"

        sha256sum -c "$manifest_name"
    )

    find "$run" -type f -exec chmod 0444 {} +
    find "$run" -type f -name 'executed_runner.sh' -exec chmod 0555 {} +
    find "$run" -type f -name '*.py' -exec chmod 0555 {} +
    find "$run" -type f -name '*.sh' -exec chmod 0555 {} +
    find "$run" -type d -exec chmod 0555 {} +
}

# ===========================================================================
# B6.5 — Five positive CBMC proofs
# ===========================================================================

echo
echo "============================================================"
echo "B6.5 — FIVE POSITIVE CBMC PROOFS"
echo "============================================================"

ACTIVE_RUN="$B65"

mkdir -p \
    "$B65/results" \
    "$B65/commands" \
    "$B65/logs" \
    "$B65/exit_codes" \
    "$B65/resource_usage" \
    "$B65/frozen_inputs" \
    "$B65/support"

cp "$(readlink -f "$0")" "$B65/executed_runner.sh"

write_positive_auditor \
    "$B65/support/audit_positive_json.py"

cp "$FAMILY/SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256" \
    "$B65/frozen_inputs/B6_3_ARTIFACT_MANIFEST.sha256"
cp "$PREFLIGHT/SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256" \
    "$B65/frozen_inputs/B6_4_ARTIFACT_MANIFEST.sha256"
cp "$PREFLIGHT/SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt" \
    "$B65/frozen_inputs/B6_4_PREFLIGHT_SUMMARY.txt"

B65_SUMMARY="$B65/SUB_T6_B6_5_POSITIVE_EXECUTION_SUMMARY.txt"
B65_BINDING="$B65/SUB_T6_B6_5_EXECUTION_INPUT_BINDING.txt"
B65_MANIFEST="SUB_T6_B6_5_ARTIFACT_MANIFEST.sha256"

cat > "$B65_BINDING" <<EOF
SUB-T6 B6.5 POSITIVE EXECUTION INPUT BINDING

CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CBMC_VERSION=$CBMC_VERSION
FROZEN_HARNESS_FAMILY=$FAMILY
FROZEN_GOTO_PREFLIGHT=$PREFLIGHT
POSITIVE_CASE_COUNT=5

This gate executes only the five frozen positive models.
Reachability and expected-failure models are not executed in B6.5.

CBMC_PROOF_EXECUTION=YES
REACHABILITY_EXECUTION=NO
EXPECTED_FAILURE_EXECUTION=NO
PRODUCTION_SOURCE_MODIFICATION=NO
BATCH5_MODIFICATION=NO
EOF

printf '%s\n' \
    "SUB-T6 B6.5 POSITIVE EXECUTION SUMMARY" \
    "" \
    "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "CBMC_VERSION=$CBMC_VERSION" \
    "" \
    "CASE|EXIT|SUCCESS|FAILURE|UNKNOWN|TOTAL_RESULTS|EXPECTED_MARKERS|FOUND_MARKERS|VERDICT" \
    > "$B65_SUMMARY"

POSITIVE_CASES=(
    "callsite_precondition"
    "callsite_exactness"
    "callsite_frame"
    "sub_reduce_handoff"
    "tomsg_precondition"
)

for case_name in "${POSITIVE_CASES[@]}"; do
    goto_file="$PREFLIGHT/build/${case_name}.goto"
    goto_sum="$goto_file.sha256"
    unwind_file="$PREFLIGHT/inspection/${case_name}_frozen_unwindset.txt"

    result_json="$B65/results/${case_name}_cbmc_result.json"
    result_stderr="$B65/logs/${case_name}_cbmc_stderr.txt"
    exit_file="$B65/exit_codes/${case_name}_cbmc_exit_code.txt"
    resource_file="$B65/resource_usage/${case_name}_resource_usage.txt"
    command_file="$B65/commands/${case_name}_cbmc_command.txt"
    parsed_file="$B65/results/${case_name}_parsed_result.txt"
    marker_file="$B65/results/${case_name}_expected_marker_audit.txt"

    [ -s "$goto_file" ] ||
        die "positive GOTO binary missing: $goto_file"
    [ -f "$goto_sum" ] ||
        die "positive GOTO checksum missing: $goto_sum"
    [ -s "$unwind_file" ] ||
        die "positive unwindset missing: $unwind_file"

    sha256sum -c "$goto_sum"

    unwindset="$(tr -d '\r\n' < "$unwind_file")"
    [ -n "$unwindset" ] ||
        die "positive unwindset empty: $case_name"

    cp "$goto_sum" \
        "$B65/frozen_inputs/${case_name}_goto.sha256"
    cp "$unwind_file" \
        "$B65/frozen_inputs/${case_name}_frozen_unwindset.txt"

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

    write_command "$command_file" "${cmd[@]}"

    echo "B6.5 CASE=$case_name STATUS=RUNNING"

    set +e
    run_cbmc_timed \
        "$resource_file" \
        "$result_json" \
        "$result_stderr" \
        "${cmd[@]}"
    rc=$?
    set -e

    printf '%s\n' "$rc" > "$exit_file"

    [ "$rc" -eq 0 ] ||
        die "positive CBMC execution failed for $case_name with exit $rc"

    [ -s "$result_json" ] ||
        die "positive CBMC JSON empty: $case_name"

    python3 \
        "$B65/support/audit_positive_json.py" \
        "$result_json" \
        "$parsed_file"

    case "$case_name" in
        callsite_precondition)
            expected_markers=(
                "SUB_T6_T6_1"
                "SUB_T6_T6_2_LOWER"
                "SUB_T6_T6_2_UPPER"
                "SUB_T6_T6_2_ANCHOR"
            )
            ;;
        callsite_exactness)
            expected_markers=(
                "SUB_T6_T6_3"
            )
            ;;
        callsite_frame)
            expected_markers=(
                "SUB_T6_T6_4_ANCHOR"
                "SUB_T6_T6_4_SB"
                "SUB_T6_T6_4_SNAPSHOT"
                "SUB_T6_T6_4_GUARD"
            )
            ;;
        sub_reduce_handoff)
            expected_markers=(
                "SUB_T6_T6_5_SUB"
                "SUB_T6_T6_5_REDUCE_LOWER"
                "SUB_T6_T6_5_REDUCE_UPPER"
            )
            ;;
        tomsg_precondition)
            expected_markers=(
                "SUB_T6_T6_6_SUB_ANCHOR"
                "SUB_T6_T6_6_PRE_LOWER"
                "SUB_T6_T6_6_PRE_UPPER"
                "SUB_T6_T6_6_CONST_INPUT"
            )
            ;;
        *)
            die "unknown positive case: $case_name"
            ;;
    esac

    expected_count="${#expected_markers[@]}"
    found_count=0
    : > "$marker_file"

    for marker in "${expected_markers[@]}"; do
        if grep -Fq "$marker" "$parsed_file"; then
            echo "$marker=FOUND" >> "$marker_file"
            found_count=$((found_count + 1))
        else
            echo "$marker=MISSING" >> "$marker_file"
        fi
    done

    [ "$found_count" -eq "$expected_count" ] ||
        die "positive theorem marker missing for $case_name"

    success_count="$(awk -F= '/^SUCCESS=/{print $2}' "$parsed_file")"
    failure_count="$(awk -F= '/^FAILURE=/{print $2}' "$parsed_file")"
    unknown_count="$(awk -F= '/^UNKNOWN=/{print $2}' "$parsed_file")"
    total_count="$(awk -F= '/^TOTAL_RESULTS=/{print $2}' "$parsed_file")"

    [ "$failure_count" -eq 0 ] ||
        die "positive failure result found: $case_name"
    [ "$unknown_count" -eq 0 ] ||
        die "positive unknown result found: $case_name"
    [ "$success_count" -eq "$total_count" ] ||
        die "not all positive properties succeeded: $case_name"

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
        >> "$B65_SUMMARY"

    echo \
      "B6.5 CASE=$case_name STATUS=PASS SUCCESS=$success_count TOTAL=$total_count MARKERS=$found_count/$expected_count"
done

positive_failure_total="$(
    awk -F'|' '
      /^callsite_|^sub_reduce_|^tomsg_/ {
        sum += $4
      }
      END {print sum+0}
    ' "$B65_SUMMARY"
)"

positive_unknown_total="$(
    awk -F'|' '
      /^callsite_|^sub_reduce_|^tomsg_/ {
        sum += $5
      }
      END {print sum+0}
    ' "$B65_SUMMARY"
)"

{
    echo
    echo "=== B6.5 FINAL VERDICT ==="
    echo "POSITIVE_CASE_COUNT=5"
    echo "ZERO_EXIT_CASE_COUNT=$(grep -l '^0$' "$B65/exit_codes"/*_cbmc_exit_code.txt | wc -l)"
    echo "RESULT_JSON_COUNT=$(find "$B65/results" -maxdepth 1 -type f -name '*_cbmc_result.json' | wc -l)"
    echo "RESULT_CHECKSUM_COUNT=$(find "$B65/results" -maxdepth 1 -type f -name '*_cbmc_result.json.sha256' | wc -l)"
    echo "PARSED_RESULT_COUNT=$(find "$B65/results" -maxdepth 1 -type f -name '*_parsed_result.txt' | wc -l)"
    echo "MARKER_AUDIT_COUNT=$(find "$B65/results" -maxdepth 1 -type f -name '*_expected_marker_audit.txt' | wc -l)"
    echo "FAILED_PROPERTY_TOTAL=$positive_failure_total"
    echo "UNKNOWN_PROPERTY_TOTAL=$positive_unknown_total"
    echo "ALL_POSITIVE_CBMC_EXITS_ZERO=PASS"
    echo "ALL_POSITIVE_PROPERTIES_SUCCESS=PASS"
    echo "ALL_EXPECTED_T6_MARKERS_PRESENT=PASS"
    echo "T6_7_COMPLETE_SLICE_SAFETY=PASS"
    echo "B6_5_STATUS=PASS"
    echo
    echo "=== OPERATION BOUNDARY ==="
    echo "CBMC_PROOF_EXECUTION=YES"
    echo "REACHABILITY_EXECUTION=NO"
    echo "EXPECTED_FAILURE_EXECUTION=NO"
    echo "PRODUCTION_SOURCE_MODIFICATION=NO"
    echo "BATCH5_MODIFICATION=NO"
} >> "$B65_SUMMARY"

[ "$positive_failure_total" -eq 0 ] ||
    die "aggregate positive failure count is nonzero"
[ "$positive_unknown_total" -eq 0 ] ||
    die "aggregate positive unknown count is nonzero"

freeze_run "$B65" "$B65_MANIFEST"

echo "B6_5_STATUS=PASS"
ACTIVE_RUN=""

# ===========================================================================
# B6.6 — Reachability and non-vacuity
# ===========================================================================

echo
echo "============================================================"
echo "B6.6 — REACHABILITY AND NON-VACUITY"
echo "============================================================"

ACTIVE_RUN="$B66"

mkdir -p \
    "$B66/control_family/harnesses" \
    "$B66/control_family/support" \
    "$B66/build" \
    "$B66/inspection" \
    "$B66/companion_proof_results" \
    "$B66/coverage_results" \
    "$B66/commands" \
    "$B66/logs" \
    "$B66/exit_codes" \
    "$B66/resource_usage" \
    "$B66/frozen_inputs" \
    "$B66/support"

cp "$(readlink -f "$0")" "$B66/executed_runner.sh"

write_positive_auditor \
    "$B66/support/audit_positive_json.py"
write_reachability_parser \
    "$B66/support/derive_reachable_unwindset.py"

cat > "$B66/control_family/support/sub00r_b6_cover_neutral_companion.h" <<'EOF'
#ifndef SUB00R_B6_COVER_NEUTRAL_COMPANION_H
#define SUB00R_B6_COVER_NEUTRAL_COMPANION_H

/*
 * B6.6 proof-only companion transformation.
 *
 * Cover statements are observational and are neutralised only in the
 * separately named companion GOTO binary used to prove loop completion,
 * memory safety and all ordinary assertions. The untouched original model
 * is used for --cover cover.
 */
#define __CPROVER_cover(condition) ((void)0)

#endif
EOF

cat > "$B66/control_family/harnesses/sub_t6_reachability_harness.c" <<'EOF'
/* SUB-T6 B6.6 reachability and boundary model. */
#include "sub00r_b6_harness_common.h"

extern unsigned nondet_unsigned(void);

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  mlk_poly sub_result;
  unsigned i;
  unsigned k;

  sub_t6_check_machine_model();

  k = nondet_unsigned();
  __CPROVER_assume(k < MLKEM_N);

  sub_t6_assume_callsite_inputs(&v, &sb);

  v_before = v;
  sb_before = sb;

  mlk_poly_sub(&v, &sb);
  sub_result = v;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)sub_result.coeffs[i] == expected,
        "SUB_T6_REACH_ANCHOR_EXACT: subtraction must remain exact");
  }

  __CPROVER_cover(
      v_before.coeffs[k] == 0 &&
      sb_before.coeffs[k] == 26631 &&
      sub_result.coeffs[k] == -26631);

  __CPROVER_cover(
      v_before.coeffs[k] == 3328 &&
      sb_before.coeffs[k] == -26631 &&
      sub_result.coeffs[k] == 29959);

  __CPROVER_cover(
      v_before.coeffs[k] == 0 &&
      sb_before.coeffs[k] == 0 &&
      sub_result.coeffs[k] == 0);

  __CPROVER_cover(sb_before.coeffs[k] > 0);
  __CPROVER_cover(sb_before.coeffs[k] < 0);

  __CPROVER_cover(sub_result.coeffs[k] < 0);
  __CPROVER_cover(sub_result.coeffs[k] == 0);
  __CPROVER_cover(
      sub_result.coeffs[k] > 0 &&
      sub_result.coeffs[k] < SUB_T6_FIPS_Q);
  __CPROVER_cover(
      sub_result.coeffs[k] >= SUB_T6_FIPS_Q);

  __CPROVER_cover(k == 0u);
  __CPROVER_cover(k == 127u);
  __CPROVER_cover(k == 255u);

  mlk_poly_reduce(&v);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        v.coeffs[i] >= 0,
        "SUB_T6_REACH_REDUCE_LOWER: reduced coefficient must be nonnegative");
    __CPROVER_assert(
        v.coeffs[i] < SUB_T6_FIPS_Q,
        "SUB_T6_REACH_REDUCE_UPPER: reduced coefficient must be below q");
  }

  return 0;
}
EOF

grep -q 'SUB_T6_REACH_ANCHOR_EXACT' \
    "$B66/control_family/harnesses/sub_t6_reachability_harness.c"
grep -q 'SUB_T6_REACH_REDUCE_LOWER' \
    "$B66/control_family/harnesses/sub_t6_reachability_harness.c"
grep -q 'SUB_T6_REACH_REDUCE_UPPER' \
    "$B66/control_family/harnesses/sub_t6_reachability_harness.c"

cover_count="$(
    grep -c '__CPROVER_cover(' \
        "$B66/control_family/harnesses/sub_t6_reachability_harness.c"
)"

[ "$cover_count" -eq 12 ] ||
    die "reachability harness cover count is not 12"

if grep -RInE \
    '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)' \
    "$B66/control_family"; then
    die "false assumption detected in reachability family"
fi

if grep -RInE \
    '__CPROVER_assume\([^;]*(INT16_MIN|INT16_MAX)' \
    "$B66/control_family"; then
    die "representability assumption detected in reachability family"
fi

cat > "$B66/control_family/SUB_T6_B6_6_CONTROL_FAMILY_FREEZE.md" <<EOF
# SUB-T6 B6.6 Reachability Control Family

Status: FROZEN before GOTO construction.

Cover goals: 12

The goals cover:
- lower and upper subtraction boundaries;
- neutral subtraction;
- positive and negative source coefficients;
- negative, zero, canonical-positive and >=q post-subtraction classes;
- symbolic target indices 0, 127 and 255.

The companion model neutralises covers and proves all ordinary assertions
and unwinding assertions. The untouched original model is used for explicit
coverage execution.
EOF

(
    cd "$B66/control_family"

    find . -type f \
        ! -name 'SUB_T6_B6_6_CONTROL_FAMILY_MANIFEST.sha256' \
        -print0 |
    sort -z |
    xargs -0 sha256sum \
        > SUB_T6_B6_6_CONTROL_FAMILY_MANIFEST.sha256

    sha256sum -c \
        SUB_T6_B6_6_CONTROL_FAMILY_MANIFEST.sha256
)

find "$B66/control_family" -type f -exec chmod 0444 {} +
find "$B66/control_family" -type d -exec chmod 0555 {} +

REACH_HARNESS="$B66/control_family/harnesses/sub_t6_reachability_harness.c"
NEUTRAL_HEADER="$B66/control_family/support/sub00r_b6_cover_neutral_companion.h"

ORIGINAL_GOTO="$B66/build/reachability_original.goto"
COMPANION_GOTO="$B66/build/reachability_cover_neutral.goto"

original_build_cmd=(
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
    "$REACH_HARNESS"
    "$SRC/src/poly.c"
    "$FAMILY/support/sub00r_b6_optblocker_zero.c"
    -o "$ORIGINAL_GOTO"
)

companion_build_cmd=(
    goto-cc
    -std=c90
    -DMLK_CONFIG_PARAMETER_SET=768
    -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00r_b6
    -DMLK_CONFIG_NO_ASM=1
    -DMLK_CONFIG_CUSTOM_ZEROIZE=1
    -include "$FAMILY/support/sub00r_b6_fail_closed_zeroize.h"
    -include "$FAMILY/support/sub00r_b6_verify_pragma_scope.h"
    -include "$NEUTRAL_HEADER"
    -I"$SRC"
    -I"$SRC/src"
    -I"$FAMILY/support"
    "$REACH_HARNESS"
    "$SRC/src/poly.c"
    "$FAMILY/support/sub00r_b6_optblocker_zero.c"
    -o "$COMPANION_GOTO"
)

write_command \
    "$B66/commands/reachability_original_build_command.txt" \
    "${original_build_cmd[@]}"
write_command \
    "$B66/commands/reachability_companion_build_command.txt" \
    "${companion_build_cmd[@]}"

set +e
"${original_build_cmd[@]}" \
    >"$B66/logs/reachability_original_build_stdout.txt" \
    2>"$B66/logs/reachability_original_build_stderr.txt"
rc_original_build=$?
"${companion_build_cmd[@]}" \
    >"$B66/logs/reachability_companion_build_stdout.txt" \
    2>"$B66/logs/reachability_companion_build_stderr.txt"
rc_companion_build=$?
set -e

printf '%s\n' "$rc_original_build" \
    > "$B66/exit_codes/reachability_original_build_exit_code.txt"
printf '%s\n' "$rc_companion_build" \
    > "$B66/exit_codes/reachability_companion_build_exit_code.txt"

[ "$rc_original_build" -eq 0 ] ||
    die "original reachability GOTO build failed"
[ "$rc_companion_build" -eq 0 ] ||
    die "companion reachability GOTO build failed"

sha256sum "$ORIGINAL_GOTO" > "$ORIGINAL_GOTO.sha256"
sha256sum "$COMPANION_GOTO" > "$COMPANION_GOTO.sha256"

for model in original companion; do
    if [ "$model" = "original" ]; then
        goto_file="$ORIGINAL_GOTO"
    else
        goto_file="$COMPANION_GOTO"
    fi

    goto-instrument --validate-goto-binary "$goto_file" \
        >"$B66/inspection/${model}_validate_goto_binary.txt" 2>&1

    goto-instrument --show-loops "$goto_file" \
        >"$B66/inspection/${model}_show_loops.txt" 2>&1

    goto-instrument --reachable-call-graph "$goto_file" \
        >"$B66/inspection/${model}_reachable_call_graph.txt" 2>&1

    goto-instrument --list-undefined-functions "$goto_file" \
        >"$B66/inspection/${model}_undefined_functions.txt" 2>&1

    python3 \
        "$B66/support/derive_reachable_unwindset.py" \
        "$B66/inspection/${model}_reachable_call_graph.txt" \
        "$B66/inspection/${model}_show_loops.txt" \
        "$B66/inspection/${model}_undefined_functions.txt" \
        "$B66/inspection/${model}_reachable_functions.txt" \
        "$B66/inspection/${model}_reachable_loops.tsv" \
        "$B66/inspection/${model}_unwindset.txt" \
        "main,mlk_sub00r_b6_poly_sub,mlk_sub00r_b6_poly_reduce" \
        > "$B66/inspection/${model}_reachability_parser_output.txt"
done

cmp \
    "$B66/inspection/original_unwindset.txt" \
    "$B66/inspection/companion_unwindset.txt" \
    > "$B66/inspection/unwindset_comparison.txt"

unwindset="$(
    tr -d '\r\n' \
        < "$B66/inspection/original_unwindset.txt"
)"

[ -n "$unwindset" ] ||
    die "reachability unwindset is empty"

companion_json="$B66/companion_proof_results/reachability_companion_cbmc_result.json"
companion_stderr="$B66/logs/reachability_companion_cbmc_stderr.txt"
companion_exit="$B66/exit_codes/reachability_companion_cbmc_exit_code.txt"
companion_resource="$B66/resource_usage/reachability_companion_resource_usage.txt"
companion_command="$B66/commands/reachability_companion_cbmc_command.txt"
companion_parsed="$B66/companion_proof_results/reachability_companion_parsed_result.txt"
companion_marker_audit="$B66/companion_proof_results/reachability_companion_marker_audit.txt"

companion_cmd=(
    cbmc
    "$COMPANION_GOTO"
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

write_command "$companion_command" "${companion_cmd[@]}"

echo "B6.6 PHASE=COMPANION_PROOF STATUS=RUNNING"

set +e
run_cbmc_timed \
    "$companion_resource" \
    "$companion_json" \
    "$companion_stderr" \
    "${companion_cmd[@]}"
rc_companion=$?
set -e

printf '%s\n' "$rc_companion" > "$companion_exit"

[ "$rc_companion" -eq 0 ] ||
    die "reachability companion proof failed with exit $rc_companion"

python3 \
    "$B66/support/audit_positive_json.py" \
    "$companion_json" \
    "$companion_parsed"

reach_markers=(
    "SUB_T6_REACH_ANCHOR_EXACT"
    "SUB_T6_REACH_REDUCE_LOWER"
    "SUB_T6_REACH_REDUCE_UPPER"
)

reach_found=0
: > "$companion_marker_audit"

for marker in "${reach_markers[@]}"; do
    if grep -Fq "$marker" "$companion_parsed"; then
        echo "$marker=FOUND" >> "$companion_marker_audit"
        reach_found=$((reach_found + 1))
    else
        echo "$marker=MISSING" >> "$companion_marker_audit"
    fi
done

[ "$reach_found" -eq 3 ] ||
    die "reachability companion theorem marker missing"

sha256sum "$companion_json" > "$companion_json.sha256"

coverage_stdout="$B66/coverage_results/reachability_coverage_result.txt"
coverage_stderr="$B66/logs/reachability_coverage_stderr.txt"
coverage_exit="$B66/exit_codes/reachability_coverage_exit_code.txt"
coverage_resource="$B66/resource_usage/reachability_coverage_resource_usage.txt"
coverage_command="$B66/commands/reachability_coverage_command.txt"
coverage_parsed="$B66/coverage_results/reachability_coverage_parsed.txt"

coverage_cmd=(
    cbmc
    "$ORIGINAL_GOTO"
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
    --unwindset "$unwindset"
    --slice-formula
    --sat-solver minisat2
    --cover cover
)

write_command "$coverage_command" "${coverage_cmd[@]}"

echo "B6.6 PHASE=ORIGINAL_MODEL_COVERAGE STATUS=RUNNING"

set +e
run_cbmc_timed \
    "$coverage_resource" \
    "$coverage_stdout" \
    "$coverage_stderr" \
    "${coverage_cmd[@]}"
rc_coverage=$?
set -e

printf '%s\n' "$rc_coverage" > "$coverage_exit"

[ "$rc_coverage" -eq 0 ] ||
    die "reachability coverage failed with exit $rc_coverage"
[ -s "$coverage_stdout" ] ||
    die "reachability coverage output is empty"

coverage_values="$(
    awk '
      /^\*\* [0-9]+ of [0-9]+ covered/ {
        covered=$2
        total=$4
      }
      END {
        if(covered != "" && total != "")
          print covered, total
      }
    ' "$coverage_stdout"
)"

[ -n "$coverage_values" ] ||
    die "reachability coverage summary not found"

read -r satisfied total <<< "$coverage_values"

failed="$(
    grep -Ec ':[[:space:]]+FAILED$' \
        "$coverage_stdout" || true
)"
satisfied_lines="$(
    grep -Ec ':[[:space:]]+SATISFIED$' \
        "$coverage_stdout" || true
)"

{
    echo "EXPECTED=12"
    echo "SUMMARY_SATISFIED=$satisfied"
    echo "SATISFIED_LINES=$satisfied_lines"
    echo "FAILED_LINES=$failed"
    echo "TOTAL=$total"
} > "$coverage_parsed"

[ "$total" -eq 12 ] ||
    die "reachability cover total is not 12"
[ "$satisfied" -eq 12 ] ||
    die "not all reachability covers were satisfied"
[ "$satisfied_lines" -eq 12 ] ||
    die "reachability SATISFIED line count is not 12"
[ "$failed" -eq 0 ] ||
    die "one or more reachability covers failed"

sha256sum "$coverage_stdout" > "$coverage_stdout.sha256"

B66_SUMMARY="$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt"
B66_MANIFEST="SUB_T6_B6_6_ARTIFACT_MANIFEST.sha256"

companion_success="$(
    awk -F= '/^SUCCESS=/{print $2}' "$companion_parsed"
)"
companion_failure="$(
    awk -F= '/^FAILURE=/{print $2}' "$companion_parsed"
)"
companion_unknown="$(
    awk -F= '/^UNKNOWN=/{print $2}' "$companion_parsed"
)"

cat > "$B66_SUMMARY" <<EOF
SUB-T6 B6.6 REACHABILITY AND NON-VACUITY SUMMARY

CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CBMC_VERSION=$CBMC_VERSION

EXPECTED_COVER_GOALS=12
COMPANION_EXIT=$rc_companion
COMPANION_SUCCESS=$companion_success
COMPANION_FAILURE=$companion_failure
COMPANION_UNKNOWN=$companion_unknown
COMPANION_MARKERS_FOUND=$reach_found
COVERAGE_EXIT=$rc_coverage
COVERAGE_SATISFIED=$satisfied
COVERAGE_FAILED=$failed
COVERAGE_TOTAL=$total

LOWER_SUBTRACTION_BOUNDARY=REACHABLE
UPPER_SUBTRACTION_BOUNDARY=REACHABLE
NEUTRAL_SUBTRACTION=REACHABLE
POSITIVE_SOURCE=REACHABLE
NEGATIVE_SOURCE=REACHABLE
POSTSUB_NEGATIVE=REACHABLE
POSTSUB_ZERO=REACHABLE
POSTSUB_CANONICAL_POSITIVE=REACHABLE
POSTSUB_GREATER_OR_EQUAL_Q=REACHABLE
INDEX_0=REACHABLE
INDEX_127=REACHABLE
INDEX_255=REACHABLE

COMPANION_LOOP_COMPLETENESS=PASS
COMPANION_ALL_PROPERTIES_SUCCESS=PASS
ORIGINAL_MODEL_ALL_COVERS_SATISFIED=PASS
SAME_UNWINDSET_RETAINED=PASS
B6_6_STATUS=PASS

COMPANION_MODEL_CREATION=YES
COMPANION_PROOF_EXECUTION=YES
ORIGINAL_MODEL_COVERAGE_EXECUTION=YES
FROZEN_POSITIVE_HARNESSES_MODIFIED=NO
PRODUCTION_SOURCE_MODIFICATION=NO
BATCH5_MODIFICATION=NO
EOF

freeze_run "$B66" "$B66_MANIFEST"

echo "B6_6_STATUS=PASS"
ACTIVE_RUN=""

# ===========================================================================
# B6.7 — Three isolated expected-failure controls
# ===========================================================================

echo
echo "============================================================"
echo "B6.7 — THREE ISOLATED EXPECTED-FAILURE CONTROLS"
echo "============================================================"

ACTIVE_RUN="$B67"

mkdir -p \
    "$B67/control_family/harnesses" \
    "$B67/build" \
    "$B67/inspection" \
    "$B67/full_model_results" \
    "$B67/targeted_witnesses" \
    "$B67/commands" \
    "$B67/logs" \
    "$B67/exit_codes" \
    "$B67/resource_usage" \
    "$B67/frozen_inputs" \
    "$B67/support"

cp "$(readlink -f "$0")" "$B67/executed_runner.sh"

write_expected_failure_auditor \
    "$B67/support/audit_expected_failure_json.py"
write_reachability_parser \
    "$B67/support/derive_reachable_unwindset.py"

cat > "$B67/control_family/harnesses/sub_t6_ef_false_overflow_harness.c" <<'EOF'
/* EF-T6-1: deliberately false overflow-existence claim. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  unsigned i;
  int overflow_exists;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  v_before = v;
  sb_before = sb;
  overflow_exists = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)v_before.coeffs[i] -
        (int32_t)sb_before.coeffs[i];

    if (d < INT16_MIN || d > INT16_MAX)
    {
      overflow_exists = 1;
    }
  }

  mlk_poly_sub(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == expected,
        "SUB_T6_EF_T6_1_ANCHOR: actual subtraction must be exact");
  }

  __CPROVER_assert(
      overflow_exists,
      "SUB_T6_EF_T6_1_EXPECTED_FAILURE: some subtraction exceeds int16_t");

  return 0;
}
EOF

cat > "$B67/control_family/harnesses/sub_t6_ef_false_canonicalisation_failure_harness.c" <<'EOF'
/* EF-T6-2: deliberately false post-reduction noncanonical claim. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  unsigned i;
  int outside_exists;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  mlk_poly_sub(&v, &sb);
  mlk_poly_reduce(&v);

  outside_exists = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        v.coeffs[i] >= 0,
        "SUB_T6_EF_T6_2_ANCHOR_LOWER: reduced output must be nonnegative");
    __CPROVER_assert(
        v.coeffs[i] < SUB_T6_FIPS_Q,
        "SUB_T6_EF_T6_2_ANCHOR_UPPER: reduced output must be below q");

    if (v.coeffs[i] < 0 ||
        v.coeffs[i] >= SUB_T6_FIPS_Q)
    {
      outside_exists = 1;
    }
  }

  __CPROVER_assert(
      outside_exists,
      "SUB_T6_EF_T6_2_EXPECTED_FAILURE: reduction leaves a noncanonical coefficient");

  return 0;
}
EOF

cat > "$B67/control_family/harnesses/sub_t6_ef_false_tomsg_incompatibility_harness.c" <<'EOF'
/* EF-T6-3: deliberately false downstream incompatibility claim. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly reduced_before_tomsg;
  uint8_t message[MLKEM_INDCPA_MSGBYTES];
  unsigned i;
  int incompatible;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  mlk_poly_sub(&v, &sb);
  mlk_poly_reduce(&v);

  reduced_before_tomsg = v;
  incompatible = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        v.coeffs[i] >= 0,
        "SUB_T6_EF_T6_3_ANCHOR_LOWER: tomsg input must be nonnegative");
    __CPROVER_assert(
        v.coeffs[i] < SUB_T6_FIPS_Q,
        "SUB_T6_EF_T6_3_ANCHOR_UPPER: tomsg input must be below q");

    if (v.coeffs[i] < 0 ||
        v.coeffs[i] >= SUB_T6_FIPS_Q)
    {
      incompatible = 1;
    }
  }

  mlk_poly_tomsg(message, &v);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        v.coeffs[i] == reduced_before_tomsg.coeffs[i],
        "SUB_T6_EF_T6_3_CONST_INPUT: tomsg must preserve the polynomial");
  }

  __CPROVER_assert(
      incompatible,
      "SUB_T6_EF_T6_3_EXPECTED_FAILURE: tomsg canonical-input precondition is violated");

  return 0;
}
EOF

EF_CASES=(
    "ef_false_overflow"
    "ef_false_canonicalisation_failure"
    "ef_false_tomsg_incompatibility"
)

EF_HARNESSES=(
    "sub_t6_ef_false_overflow_harness.c"
    "sub_t6_ef_false_canonicalisation_failure_harness.c"
    "sub_t6_ef_false_tomsg_incompatibility_harness.c"
)

EF_MARKERS=(
    "SUB_T6_EF_T6_1_EXPECTED_FAILURE"
    "SUB_T6_EF_T6_2_EXPECTED_FAILURE"
    "SUB_T6_EF_T6_3_EXPECTED_FAILURE"
)

EF_NEEDS_TOMSG=(
    "no"
    "no"
    "yes"
)

for marker in "${EF_MARKERS[@]}"; do
    count="$(
        grep -RFl "$marker" \
            "$B67/control_family/harnesses" |
        wc -l
    )"

    [ "$count" -eq 1 ] ||
        die "expected-failure marker count is not one: $marker"
done

if grep -RInE \
    '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)' \
    "$B67/control_family"; then
    die "false assumption detected in expected-failure family"
fi

if grep -RInE \
    '__CPROVER_assume\([^;]*(INT16_MIN|INT16_MAX)' \
    "$B67/control_family"; then
    die "representability assumption detected in expected-failure family"
fi

cat > "$B67/control_family/SUB_T6_B6_7_CONTROL_FAMILY_FREEZE.md" <<EOF
# SUB-T6 B6.7 Expected-Failure Control Family

Status: FROZEN before GOTO construction.

Controls:
1. EF-T6-1: falsely assert that an allowed subtraction exceeds int16_t.
2. EF-T6-2: falsely assert that actual reduction leaves a noncanonical value.
3. EF-T6-3: falsely assert that the actual reduced input is incompatible with
   mlk_poly_tomsg after executing the real consumer.

Acceptance requires exactly one registered target failure per full model,
zero unrelated failures, zero unknown properties and one targeted
counterexample witness per control.
EOF

(
    cd "$B67/control_family"

    find . -type f \
        ! -name 'SUB_T6_B6_7_CONTROL_FAMILY_MANIFEST.sha256' \
        -print0 |
    sort -z |
    xargs -0 sha256sum \
        > SUB_T6_B6_7_CONTROL_FAMILY_MANIFEST.sha256

    sha256sum -c \
        SUB_T6_B6_7_CONTROL_FAMILY_MANIFEST.sha256
)

find "$B67/control_family" -type f -exec chmod 0444 {} +
find "$B67/control_family" -type d -exec chmod 0555 {} +

B67_SUMMARY="$B67/SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt"
B67_MANIFEST="SUB_T6_B6_7_ARTIFACT_MANIFEST.sha256"

printf '%s\n' \
    "SUB-T6 B6.7 EXPECTED-FAILURE CONTROL SUMMARY" \
    "" \
    "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "CBMC_VERSION=$CBMC_VERSION" \
    "" \
    "CASE|FULL_EXIT|SUCCESS|TARGET_FAILURE|OTHER_FAILURE|UNKNOWN|TARGET_PROPERTY|WITNESS_EXIT|WITNESS_MARKER|VERDICT" \
    > "$B67_SUMMARY"

for idx in "${!EF_CASES[@]}"; do
    case_name="${EF_CASES[$idx]}"
    harness_name="${EF_HARNESSES[$idx]}"
    marker="${EF_MARKERS[$idx]}"
    need_tomsg="${EF_NEEDS_TOMSG[$idx]}"

    harness="$B67/control_family/harnesses/$harness_name"
    goto_file="$B67/build/${case_name}.goto"

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

    if [ "$need_tomsg" = "yes" ]; then
        build_cmd+=("$SRC/src/compress.c")
    fi

    build_cmd+=(
        "$FAMILY/support/sub00r_b6_optblocker_zero.c"
        -o "$goto_file"
    )

    write_command \
        "$B67/commands/${case_name}_goto_build_command.txt" \
        "${build_cmd[@]}"

    set +e
    "${build_cmd[@]}" \
        >"$B67/logs/${case_name}_goto_build_stdout.txt" \
        2>"$B67/logs/${case_name}_goto_build_stderr.txt"
    rc_build=$?
    set -e

    printf '%s\n' "$rc_build" \
        > "$B67/exit_codes/${case_name}_goto_build_exit_code.txt"

    [ "$rc_build" -eq 0 ] ||
        die "expected-failure GOTO build failed: $case_name"

    sha256sum "$goto_file" > "$goto_file.sha256"

    goto-instrument --validate-goto-binary "$goto_file" \
        >"$B67/inspection/${case_name}_validate_goto_binary.txt" 2>&1
    goto-instrument --show-loops "$goto_file" \
        >"$B67/inspection/${case_name}_show_loops.txt" 2>&1
    goto-instrument --reachable-call-graph "$goto_file" \
        >"$B67/inspection/${case_name}_reachable_call_graph.txt" 2>&1
    goto-instrument --list-undefined-functions "$goto_file" \
        >"$B67/inspection/${case_name}_undefined_functions.txt" 2>&1

    required_functions="main,mlk_sub00r_b6_poly_sub"

    if [ "$case_name" != "ef_false_overflow" ]; then
        required_functions="${required_functions},mlk_sub00r_b6_poly_reduce"
    fi

    if [ "$need_tomsg" = "yes" ]; then
        required_functions="${required_functions},mlk_sub00r_b6_poly_tomsg"
    fi

    python3 \
        "$B67/support/derive_reachable_unwindset.py" \
        "$B67/inspection/${case_name}_reachable_call_graph.txt" \
        "$B67/inspection/${case_name}_show_loops.txt" \
        "$B67/inspection/${case_name}_undefined_functions.txt" \
        "$B67/inspection/${case_name}_reachable_functions.txt" \
        "$B67/inspection/${case_name}_reachable_loops.tsv" \
        "$B67/inspection/${case_name}_frozen_unwindset.txt" \
        "$required_functions" \
        > "$B67/inspection/${case_name}_reachability_parser_output.txt"

    unwindset="$(
        tr -d '\r\n' \
            < "$B67/inspection/${case_name}_frozen_unwindset.txt"
    )"

    [ -n "$unwindset" ] ||
        die "expected-failure unwindset empty: $case_name"

    full_json="$B67/full_model_results/${case_name}_full_model_result.json"
    full_stderr="$B67/logs/${case_name}_full_model_stderr.txt"
    full_exit="$B67/exit_codes/${case_name}_full_model_exit_code.txt"
    full_resource="$B67/resource_usage/${case_name}_full_model_resource_usage.txt"
    full_command="$B67/commands/${case_name}_full_model_command.txt"
    parsed="$B67/full_model_results/${case_name}_parsed_result.txt"
    isolation="$B67/full_model_results/${case_name}_failure_isolation_audit.txt"

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

    write_command "$full_command" "${full_cmd[@]}"

    echo "B6.7 CASE=$case_name PHASE=FULL_MODEL STATUS=RUNNING"

    set +e
    run_cbmc_timed \
        "$full_resource" \
        "$full_json" \
        "$full_stderr" \
        "${full_cmd[@]}"
    rc_full=$?
    set -e

    printf '%s\n' "$rc_full" > "$full_exit"

    [ "$rc_full" -eq 10 ] ||
        die "expected-failure full model returned $rc_full for $case_name; expected 10"

    [ -s "$full_json" ] ||
        die "expected-failure JSON empty: $case_name"

    python3 \
        "$B67/support/audit_expected_failure_json.py" \
        "$full_json" \
        "$parsed" \
        "$marker"

    success_count="$(awk -F= '/^SUCCESS=/{print $2}' "$parsed")"
    target_failure="$(awk -F= '/^TARGET_FAILURE=/{print $2}' "$parsed")"
    other_failure="$(awk -F= '/^OTHER_FAILURE=/{print $2}' "$parsed")"
    unknown_count="$(awk -F= '/^UNKNOWN=/{print $2}' "$parsed")"
    target_property="$(sed -n 's/^TARGET_PROPERTY=//p' "$parsed")"

    [ -n "$target_property" ] ||
        die "expected-failure target property missing: $case_name"

    {
        echo "MARKER=$marker"
        echo "TARGET_PROPERTY=$target_property"
        echo "TARGET_FAILURE=$target_failure"
        echo "OTHER_FAILURE=$other_failure"
        echo "UNKNOWN=$unknown_count"
    } > "$isolation"

    sha256sum "$full_json" > "$full_json.sha256"

    witness_stdout="$B67/targeted_witnesses/${case_name}_targeted_witness.txt"
    witness_stderr="$B67/logs/${case_name}_targeted_witness_stderr.txt"
    witness_exit="$B67/exit_codes/${case_name}_targeted_witness_exit_code.txt"
    witness_resource="$B67/resource_usage/${case_name}_targeted_witness_resource_usage.txt"
    witness_command="$B67/commands/${case_name}_targeted_witness_command.txt"

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

    write_command "$witness_command" "${witness_cmd[@]}"

    echo "B6.7 CASE=$case_name PHASE=TARGETED_WITNESS STATUS=RUNNING"

    set +e
    run_cbmc_timed \
        "$witness_resource" \
        "$witness_stdout" \
        "$witness_stderr" \
        "${witness_cmd[@]}"
    rc_witness=$?
    set -e

    printf '%s\n' "$rc_witness" > "$witness_exit"

    [ "$rc_witness" -eq 10 ] ||
        die "targeted witness returned $rc_witness for $case_name; expected 10"
    [ -s "$witness_stdout" ] ||
        die "targeted witness empty: $case_name"

    grep -Fq "$marker" "$witness_stdout" ||
        die "registered marker absent from targeted witness: $case_name"
    grep -q 'Violated property' "$witness_stdout" ||
        die "violation heading absent from targeted witness: $case_name"
    grep -q 'VERIFICATION FAILED' "$witness_stdout" ||
        die "verification-failed verdict absent from targeted witness: $case_name"

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
        >> "$B67_SUMMARY"

    echo \
      "B6.7 CASE=$case_name STATUS=PASS TARGET_FAILURE=1 OTHER_FAILURE=0 UNKNOWN=0 WITNESS=PASS"
done

target_failure_total="$(
    awk -F'|' '
      /^ef_/ {sum += $4}
      END {print sum+0}
    ' "$B67_SUMMARY"
)"

other_failure_total="$(
    awk -F'|' '
      /^ef_/ {sum += $5}
      END {print sum+0}
    ' "$B67_SUMMARY"
)"

unknown_total="$(
    awk -F'|' '
      /^ef_/ {sum += $6}
      END {print sum+0}
    ' "$B67_SUMMARY"
)"

witness_marker_total="$(
    awk -F'|' '
      /^ef_/ {sum += $9}
      END {print sum+0}
    ' "$B67_SUMMARY"
)"

[ "$target_failure_total" -eq 3 ] ||
    die "aggregate expected target-failure count is not three"
[ "$other_failure_total" -eq 0 ] ||
    die "unexpected failed properties found in expected-failure controls"
[ "$unknown_total" -eq 0 ] ||
    die "unknown properties found in expected-failure controls"
[ "$witness_marker_total" -eq 3 ] ||
    die "targeted witness marker count is not three"

{
    echo
    echo "=== B6.7 FINAL VERDICT ==="
    echo "EXPECTED_FAILURE_CASE_COUNT=3"
    echo "FULL_MODEL_EXPECTED_EXIT_COUNT=$(grep -l '^10$' "$B67/exit_codes"/*_full_model_exit_code.txt | wc -l)"
    echo "TARGET_FAILURE_TOTAL=$target_failure_total"
    echo "UNEXPECTED_FAILURE_TOTAL=$other_failure_total"
    echo "UNKNOWN_PROPERTY_TOTAL=$unknown_total"
    echo "TARGET_PROPERTY_COUNT=$(find "$B67/full_model_results" -maxdepth 1 -type f -name '*_failure_isolation_audit.txt' | wc -l)"
    echo "TARGETED_WITNESS_EXPECTED_EXIT_COUNT=$(grep -l '^10$' "$B67/exit_codes"/*_targeted_witness_exit_code.txt | wc -l)"
    echo "TARGETED_WITNESS_MARKER_COUNT=$witness_marker_total"
    echo "EF_T6_1_FALSE_OVERFLOW=REJECTED_AS_EXPECTED"
    echo "EF_T6_2_FALSE_CANONICALISATION_FAILURE=REJECTED_AS_EXPECTED"
    echo "EF_T6_3_FALSE_DOWNSTREAM_INCOMPATIBILITY=REJECTED_AS_EXPECTED"
    echo "ALL_NON_TARGET_PROPERTIES_SUCCESS=PASS"
    echo "EXPECTED_FAILURE_ISOLATION=PASS"
    echo "COUNTEREXAMPLE_WITNESSES_CAPTURED=PASS"
    echo "B6_7_STATUS=PASS"
    echo
    echo "=== OPERATION BOUNDARY ==="
    echo "EXPECTED_FAILURE_EXECUTION=YES"
    echo "MUTATION_EXECUTION=NO"
    echo "PRODUCTION_SOURCE_MODIFICATION=NO"
    echo "BATCH5_MODIFICATION=NO"
} >> "$B67_SUMMARY"

freeze_run "$B67" "$B67_MANIFEST"

echo "B6_7_STATUS=PASS"
ACTIVE_RUN=""

# ===========================================================================
# Combined package
# ===========================================================================

tar -C "$B6" -czf "$PACKAGE" \
    "05_POSITIVE_EXECUTION/$(basename "$B65")" \
    "06_REACHABILITY/$(basename "$B66")" \
    "07_EXPECTED_FAILURES/$(basename "$B67")"

SUCCESS=1
trap - EXIT

echo
echo "============================================================"
echo "FINAL COMBINED B6.5+B6.6+B6.7 SUMMARY"
echo "============================================================"

grep -E \
  'POSITIVE_CASE_COUNT=|ZERO_EXIT_CASE_COUNT=|RESULT_JSON_COUNT=|RESULT_CHECKSUM_COUNT=|PARSED_RESULT_COUNT=|MARKER_AUDIT_COUNT=|FAILED_PROPERTY_TOTAL=|UNKNOWN_PROPERTY_TOTAL=|ALL_POSITIVE_CBMC_EXITS_ZERO=|ALL_POSITIVE_PROPERTIES_SUCCESS=|ALL_EXPECTED_T6_MARKERS_PRESENT=|T6_7_COMPLETE_SLICE_SAFETY=|B6_5_STATUS=' \
  "$B65_SUMMARY"

grep -E \
  'EXPECTED_COVER_GOALS=|COMPANION_EXIT=|COMPANION_SUCCESS=|COMPANION_FAILURE=|COMPANION_UNKNOWN=|COMPANION_MARKERS_FOUND=|COVERAGE_EXIT=|COVERAGE_SATISFIED=|COVERAGE_FAILED=|COVERAGE_TOTAL=|COMPANION_LOOP_COMPLETENESS=|COMPANION_ALL_PROPERTIES_SUCCESS=|ORIGINAL_MODEL_ALL_COVERS_SATISFIED=|SAME_UNWINDSET_RETAINED=|B6_6_STATUS=' \
  "$B66_SUMMARY"

grep -E \
  'EXPECTED_FAILURE_CASE_COUNT=|FULL_MODEL_EXPECTED_EXIT_COUNT=|TARGET_FAILURE_TOTAL=|UNEXPECTED_FAILURE_TOTAL=|UNKNOWN_PROPERTY_TOTAL=|TARGET_PROPERTY_COUNT=|TARGETED_WITNESS_EXPECTED_EXIT_COUNT=|TARGETED_WITNESS_MARKER_COUNT=|EF_T6_1_FALSE_OVERFLOW=|EF_T6_2_FALSE_CANONICALISATION_FAILURE=|EF_T6_3_FALSE_DOWNSTREAM_INCOMPATIBILITY=|ALL_NON_TARGET_PROPERTIES_SUCCESS=|EXPECTED_FAILURE_ISOLATION=|COUNTEREXAMPLE_WITNESSES_CAPTURED=|B6_7_STATUS=' \
  "$B67_SUMMARY"

echo
echo "--- Combined execution package ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$PACKAGE"
sha256sum "$PACKAGE"

echo
echo "B65_POSITIVE_CASE_COUNT=5"
echo "B65_ALL_POSITIVE_EXITS_ZERO=PASS"
echo "B65_ALL_PROPERTIES_SUCCESS=PASS"
echo "B65_ALL_T6_MARKERS_PRESENT=PASS"
echo "B65_STATUS=PASS"
echo "B66_REACHABILITY_COVER_COUNT=12"
echo "B66_ALL_COVERS_SATISFIED=PASS"
echo "B66_COMPANION_PROOF=PASS"
echo "B66_STATUS=PASS"
echo "B67_EXPECTED_FAILURE_CASE_COUNT=3"
echo "B67_TARGET_FAILURE_TOTAL=3"
echo "B67_UNEXPECTED_FAILURE_TOTAL=0"
echo "B67_COUNTEREXAMPLE_WITNESS_COUNT=3"
echo "B67_STATUS=PASS"
echo "B65_B66_B67_CBMC_PROOF_EXECUTION=YES"
echo "B65_B66_B67_PRODUCTION_MODIFIED=NO"
echo "B65_B66_B67_BATCH5_MODIFIED=NO"
echo "B65_B66_B67_UPLOAD_REQUIRED=YES"
echo "B65_B66_B67_STATUS=PASS"
