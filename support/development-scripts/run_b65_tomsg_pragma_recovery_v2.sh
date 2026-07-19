#!/usr/bin/env bash
set -euo pipefail
umask 0022

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
SRC="$ROOT/source/mlkem"

FAMILY="$B6/03_HARNESS_FREEZE/frozen_harness_family_v1"
PREFLIGHT="$B6/04_GOTO_PREFLIGHT/B6_4_GOTO_PREFLIGHT_MLKEM768"
POS_PARENT="$B6/05_POSITIVE_EXECUTION"

RUN="$POS_PARENT/B6_5_POSITIVE_EXECUTION_MLKEM768_RUN3_TOMSG_PRAGMA_RECOVERY_V2"
PACKAGE="$HOME/Downloads/SUB_T6_B6_5_POSITIVE_RECOVERY.tar.gz"

EXPECTED_POLYC_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_POLYH_SHA="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_COMPRESSC_SHA="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESSH_SHA="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"

EXPECTED_FAILED_PROPERTY="mlk_scalar_compress_d1.overflow.3"
EXPECTED_FAILED_DESCRIPTION="arithmetic overflow on unsigned + in d0 + ((uint32_t)1u << 30)"

echo "============================================================"
echo "SUB-T6 B6.5 TOMSG PRAGMA-SCOPE RECOVERY"
echo "============================================================"
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "ROOT=$ROOT"
echo "FAMILY=$FAMILY"
echo "PREFLIGHT=$PREFLIGHT"
echo "RUN=$RUN"
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

    if [ "$SUCCESS" -ne 1 ] && [ -d "$RUN" ]; then
        stamp="$(date -u +%Y%m%dT%H%M%SZ)"
        chmod -R u+rwX "$RUN" 2>/dev/null || true
        failed="${RUN}_FAILED_${stamp}"
        mv "$RUN" "$failed" 2>/dev/null || true
        echo "FAILED_RECOVERY_PRESERVED=$failed" >&2
    fi

    exit "$rc"
}
trap cleanup EXIT

for path in \
    "$ROOT" "$B6" "$SRC" "$FAMILY" "$PREFLIGHT" "$POS_PARENT"
do
    [ -d "$path" ] || die "required directory missing: $path"
done

[ ! -e "$RUN" ] || die "recovery run already exists: $RUN"
[ ! -e "$PACKAGE" ] || die "recovery package already exists: $PACKAGE"

for tool in \
    sha256sum cbmc goto-cc goto-instrument timeout python3 \
    find sort grep awk sed wc readlink tar cmp tr stat
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

mapfile -t FAILED_RUNS < <(
    find "$POS_PARENT" \
        -maxdepth 1 \
        -type d \
        -name 'B6_5_POSITIVE_EXECUTION_MLKEM768_RUN1_FAILED_*' \
        -printf '%T@ %p\n' |
    sort -nr |
    awk '{sub(/^[^ ]+ /, ""); print}'
)

[ "${#FAILED_RUNS[@]}" -ge 1 ] ||
    die "preserved failed B6.5 RUN1 not found"

FAILED_RUN="${FAILED_RUNS[0]}"
echo "FAILED_RUN1=$FAILED_RUN"

for path in \
    "$FAILED_RUN/results" \
    "$FAILED_RUN/commands" \
    "$FAILED_RUN/logs" \
    "$FAILED_RUN/resource_usage" \
    "$FAILED_RUN/exit_codes"
do
    [ -d "$path" ] || die "failed RUN1 evidence directory missing: $path"
done

mkdir -p \
    "$RUN/carried_forward_run1/results" \
    "$RUN/carried_forward_run1/commands" \
    "$RUN/carried_forward_run1/logs" \
    "$RUN/carried_forward_run1/resource_usage" \
    "$RUN/carried_forward_run1/exit_codes" \
    "$RUN/original_failure_control" \
    "$RUN/recovery_support" \
    "$RUN/recovery_build" \
    "$RUN/recovery_inspection" \
    "$RUN/recovery_results" \
    "$RUN/recovery_commands" \
    "$RUN/recovery_logs" \
    "$RUN/recovery_resource_usage" \
    "$RUN/recovery_exit_codes" \
    "$RUN/frozen_inputs"

cp "$(readlink -f "$0")" "$RUN/executed_recovery_runner.sh"

cat > "$RUN/recovery_support/audit_positive_json.py" <<'PY'
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])

data = json.loads(src.read_text(encoding="utf-8"))
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

lines = [
    f"SUCCESS={success}",
    f"FAILURE={failure}",
    f"UNKNOWN={unknown}",
    f"TOTAL_RESULTS={len(unique)}",
]

for prop, status, desc in unique:
    lines.append(
        f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}"
    )

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if not unique:
    raise SystemExit("NO_PROPERTY_RESULTS")
if failure != 0:
    raise SystemExit(f"FAILURE_RESULTS={failure}")
if unknown != 0:
    raise SystemExit(f"UNKNOWN_RESULTS={unknown}")
if success != len(unique):
    raise SystemExit(
        f"SUCCESS_TOTAL_MISMATCH={success}/{len(unique)}"
    )
PY
chmod 0755 "$RUN/recovery_support/audit_positive_json.py"

cat > "$RUN/recovery_support/classify_original_tomsg_failure.py" <<'PY'
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
expected_property = sys.argv[3]
expected_description = sys.argv[4]

data = json.loads(src.read_text(encoding="utf-8"))
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
    key = (
        str(rec.get("property", "")),
        str(rec.get("status", "")),
        str(rec.get("description", "")),
    )
    if key not in seen:
        seen.add(key)
        unique.append(rec)

failures = [
    rec for rec in unique
    if str(rec.get("status", "")) == "FAILURE"
]
unknown = [
    rec for rec in unique
    if str(rec.get("status", ""))
    not in {"SUCCESS", "FAILURE"}
]

if len(failures) != 1:
    raise SystemExit(
        f"ORIGINAL_FAILURE_COUNT={len(failures)}"
    )

failure = failures[0]
prop = str(failure.get("property", ""))
desc = str(failure.get("description", ""))

if prop != expected_property:
    raise SystemExit(
        f"UNEXPECTED_FAILED_PROPERTY={prop}"
    )

if desc != expected_description:
    raise SystemExit(
        f"UNEXPECTED_FAILED_DESCRIPTION={desc}"
    )

trace = failure.get("trace", [])
u_values = []
d0_values = []

for step in trace:
    if not isinstance(step, dict):
        continue

    lhs = str(step.get("lhs", ""))
    value = step.get("value", {})
    data_value = ""

    if isinstance(value, dict):
        data_value = str(value.get("data", ""))

    if lhs == "u":
        u_values.append(data_value)

    if lhs == "d0":
        d0_values.append(data_value)

lines = [
    f"TOTAL_RESULTS={len(unique)}",
    f"SUCCESS={sum(1 for rec in unique if rec.get('status') == 'SUCCESS')}",
    f"FAILURE={len(failures)}",
    f"UNKNOWN={len(unknown)}",
    f"FAILED_PROPERTY={prop}",
    f"FAILED_DESCRIPTION={desc}",
    f"SOURCE_FILE={failure.get('sourceLocation', {}).get('file', '')}",
    f"SOURCE_LINE={failure.get('sourceLocation', {}).get('line', '')}",
    f"TRACE_STEP_COUNT={len(trace)}",
    f"LAST_U_VALUE={u_values[-1] if u_values else ''}",
    f"LAST_D0_VALUE={d0_values[-1] if d0_values else ''}",
]

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if unknown:
    raise SystemExit(
        f"ORIGINAL_UNKNOWN_COUNT={len(unknown)}"
    )
PY
chmod 0755 "$RUN/recovery_support/classify_original_tomsg_failure.py"

cat > "$RUN/recovery_support/derive_reachable_unwindset.py" <<'PY'
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
    "main",
    "mlk_sub00r_b6_poly_sub",
    "mlk_sub00r_b6_poly_reduce",
    "mlk_sub00r_b6_poly_tomsg",
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

undefined = []

for raw_line in undefined_text.splitlines():
    line = raw_line.strip()

    if not line:
        continue
    if line.startswith("Reading GOTO program"):
        continue

    undefined.append(line)

verification_only_helpers = {
    "array_abs_bound",
    "array_bound",
    "cassert",
}

reachable_verification_helpers = sorted(
    verification_only_helpers & reachable
)

if reachable_verification_helpers:
    raise SystemExit(
        "VERIFICATION_HELPERS_REACHABLE_FROM_MAIN="
        + ",".join(reachable_verification_helpers)
    )

allowed_undefined = {
    "nondet_int16_t",
} | verification_only_helpers

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
    for loop_id, _ in reachable_loops
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
print(
    "VERIFICATION_ONLY_UNDEFINED_HELPER_COUNT="
    + str(len(verification_only_helpers & set(undefined)))
)
print(
    "VERIFICATION_ONLY_HELPERS_REACHABLE_FROM_MAIN="
    + str(len(reachable_verification_helpers))
)
print(f"UNWINDSET={unwindset}")
PY
chmod 0755 "$RUN/recovery_support/derive_reachable_unwindset.py"

cat > "$RUN/recovery_support/sub00r_b6_compress_intended_wrap_scope.h" <<'EOF'
#ifndef SUB00R_B6_COMPRESS_INTENDED_WRAP_SCOPE_H
#define SUB00R_B6_COMPRESS_INTENDED_WRAP_SCOPE_H

/*
 * Verification adapter correction:
 *
 * The frozen production compress.h contains function-local CBMC pragmas
 * guarded by #ifdef CBMC. They disable unsigned-overflow only around
 * compression helpers whose modulo-2^32 or modulo-2^64 wrap is explicitly
 * intended by the production source.
 *
 * The general SUB-T6 preinclude deliberately leaves CBMC undefined after
 * loading verify.h. Therefore compress.h must be loaded once under CBMC
 * before the harness and compress.c include it through the normal guard.
 *
 * This header does not replace, copy or modify production logic.
 */

#ifdef CBMC
#error "SUB00R compress pragma adapter requires CBMC initially undefined"
#endif

#define CBMC 1
#include "compress.h"
#undef CBMC

#endif
EOF

# ---------------------------------------------------------------------------
# Validate and preserve the original single failure.
# ---------------------------------------------------------------------------

ORIGINAL_TOMSG_JSON="$FAILED_RUN/results/tomsg_precondition_cbmc_result.json"

[ -s "$ORIGINAL_TOMSG_JSON" ] ||
    die "original tomsg failure JSON missing"

python3 \
    "$RUN/recovery_support/classify_original_tomsg_failure.py" \
    "$ORIGINAL_TOMSG_JSON" \
    "$RUN/original_failure_control/ORIGINAL_TOMSG_FAILURE_CLASSIFICATION.txt" \
    "$EXPECTED_FAILED_PROPERTY" \
    "$EXPECTED_FAILED_DESCRIPTION"

cp "$ORIGINAL_TOMSG_JSON" \
    "$RUN/original_failure_control/tomsg_precondition_original_failure.json"
cp "$FAILED_RUN/commands/tomsg_precondition_cbmc_command.txt" \
    "$RUN/original_failure_control/"
cp "$FAILED_RUN/resource_usage/tomsg_precondition_resource_usage.txt" \
    "$RUN/original_failure_control/"

sha256sum \
    "$RUN/original_failure_control/tomsg_precondition_original_failure.json" \
    > "$RUN/original_failure_control/tomsg_precondition_original_failure.json.sha256"

# Verify the source itself declares this scoped exception.
grep -nF '#pragma CPROVER check disable "unsigned-overflow"' \
    "$SRC/src/compress.h" \
    > "$RUN/original_failure_control/PRODUCTION_PRAGMA_EVIDENCE.txt"

grep -nF 'uint32_t d0 = (uint32_t)u * 1290168;' \
    "$SRC/src/compress.h" \
    >> "$RUN/original_failure_control/PRODUCTION_PRAGMA_EVIDENCE.txt"

grep -nF 'return (uint8_t)((d0 + ((uint32_t)1u << 30)) >> 31);' \
    "$SRC/src/compress.h" \
    >> "$RUN/original_failure_control/PRODUCTION_PRAGMA_EVIDENCE.txt"

grep -nF '#pragma CPROVER check pop' \
    "$SRC/src/compress.h" \
    | sed -n '1p' \
    >> "$RUN/original_failure_control/PRODUCTION_PRAGMA_EVIDENCE.txt"

pragma_disable_line="$(
    grep -nF '#pragma CPROVER check disable "unsigned-overflow"' \
        "$SRC/src/compress.h" |
    sed -n '1s/:.*//p'
)"

d1_function_line="$(
    grep -nF 'static MLK_INLINE uint8_t mlk_scalar_compress_d1' \
        "$SRC/src/compress.h" |
    sed -n '1s/:.*//p'
)"

first_pop_line="$(
    grep -nF '#pragma CPROVER check pop' \
        "$SRC/src/compress.h" |
    sed -n '1s/:.*//p'
)"

[ -n "$pragma_disable_line" ] ||
    die "production unsigned-overflow disable pragma missing"
[ -n "$d1_function_line" ] ||
    die "production d1 function missing"
[ -n "$first_pop_line" ] ||
    die "production pragma pop missing"

[ "$pragma_disable_line" -lt "$d1_function_line" ] ||
    die "production disable pragma does not precede d1"
[ "$first_pop_line" -gt "$d1_function_line" ] ||
    die "production pragma pop does not follow d1"

# ---------------------------------------------------------------------------
# Carry forward and re-audit the four already successful proofs.
# ---------------------------------------------------------------------------

PRIOR_CASES=(
    "callsite_precondition"
    "callsite_exactness"
    "callsite_frame"
    "sub_reduce_handoff"
)

for case_name in "${PRIOR_CASES[@]}"; do
    json="$FAILED_RUN/results/${case_name}_cbmc_result.json"
    exit_file="$FAILED_RUN/exit_codes/${case_name}_cbmc_exit_code.txt"

    [ -s "$json" ] ||
        die "prior positive JSON missing: $case_name"
    [ -f "$exit_file" ] ||
        die "prior positive exit code missing: $case_name"
    [ "$(tr -d '\r\n' < "$exit_file")" = "0" ] ||
        die "prior positive exit is not zero: $case_name"

    cp "$json" \
        "$RUN/carried_forward_run1/results/"
    cp "$exit_file" \
        "$RUN/carried_forward_run1/exit_codes/"

    for category in commands logs resource_usage; do
        find "$FAILED_RUN/$category" \
            -maxdepth 1 \
            -type f \
            -name "${case_name}_*" \
            -exec cp -a {} "$RUN/carried_forward_run1/$category/" \;
    done

    python3 \
        "$RUN/recovery_support/audit_positive_json.py" \
        "$json" \
        "$RUN/carried_forward_run1/results/${case_name}_reparsed_result.txt"

    sha256sum "$json" \
        > "$RUN/carried_forward_run1/results/${case_name}_cbmc_result.json.sha256"

    echo "PRIOR_CASE=$case_name REAUDIT=PASS"
done

cat > "$RUN/carried_forward_run1/CARRIED_FORWARD_PROVENANCE.txt" <<EOF
SOURCE_FAILED_RUN1=$FAILED_RUN
CARRIED_FORWARD_CASE_COUNT=4
CARRIED_FORWARD_POLICY=Full CBMC JSON, exit code, commands, logs and resource usage are copied from the preserved RUN1 and independently reparsed.
TOMSG_ORIGINAL_FAILURE_CARRIED_FORWARD_SEPARATELY=YES
EOF

# ---------------------------------------------------------------------------
# Build corrected tomsg GOTO using production-declared pragma scope.
# ---------------------------------------------------------------------------

TOMSG_HARNESS="$FAMILY/harnesses/sub_t6_tomsg_precondition_harness.c"
CORRECTED_GOTO="$RUN/recovery_build/tomsg_precondition_corrected.goto"

build_cmd=(
    goto-cc
    -std=c90
    -DMLK_CONFIG_PARAMETER_SET=768
    -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00r_b6
    -DMLK_CONFIG_NO_ASM=1
    -DMLK_CONFIG_CUSTOM_ZEROIZE=1
    -include "$FAMILY/support/sub00r_b6_fail_closed_zeroize.h"
    -include "$FAMILY/support/sub00r_b6_verify_pragma_scope.h"
    -include "$RUN/recovery_support/sub00r_b6_compress_intended_wrap_scope.h"
    -I"$SRC"
    -I"$SRC/src"
    -I"$FAMILY/support"
    -I"$RUN/recovery_support"
    "$TOMSG_HARNESS"
    "$SRC/src/poly.c"
    "$SRC/src/compress.c"
    "$FAMILY/support/sub00r_b6_optblocker_zero.c"
    -o "$CORRECTED_GOTO"
)

{
    printf 'COMMAND:'
    printf ' %q' "${build_cmd[@]}"
    printf '\n'
} > "$RUN/recovery_commands/tomsg_corrected_goto_build_command.txt"

set +e
"${build_cmd[@]}" \
    >"$RUN/recovery_logs/tomsg_corrected_goto_build_stdout.txt" \
    2>"$RUN/recovery_logs/tomsg_corrected_goto_build_stderr.txt"
rc_build=$?
set -e

printf '%s\n' "$rc_build" \
    > "$RUN/recovery_exit_codes/tomsg_corrected_goto_build_exit_code.txt"

[ "$rc_build" -eq 0 ] ||
    die "corrected tomsg GOTO build failed"

[ -s "$CORRECTED_GOTO" ] ||
    die "corrected tomsg GOTO binary missing"

sha256sum "$CORRECTED_GOTO" > "$CORRECTED_GOTO.sha256"

goto-instrument --validate-goto-binary "$CORRECTED_GOTO" \
    >"$RUN/recovery_inspection/tomsg_corrected_validate_goto_binary.txt" 2>&1

goto-instrument --show-loops "$CORRECTED_GOTO" \
    >"$RUN/recovery_inspection/tomsg_corrected_show_loops.txt" 2>&1

goto-instrument --reachable-call-graph "$CORRECTED_GOTO" \
    >"$RUN/recovery_inspection/tomsg_corrected_reachable_call_graph.txt" 2>&1

goto-instrument --list-undefined-functions "$CORRECTED_GOTO" \
    >"$RUN/recovery_inspection/tomsg_corrected_undefined_functions.txt" 2>&1

python3 \
    "$RUN/recovery_support/derive_reachable_unwindset.py" \
    "$RUN/recovery_inspection/tomsg_corrected_reachable_call_graph.txt" \
    "$RUN/recovery_inspection/tomsg_corrected_show_loops.txt" \
    "$RUN/recovery_inspection/tomsg_corrected_undefined_functions.txt" \
    "$RUN/recovery_inspection/tomsg_corrected_reachable_functions.txt" \
    "$RUN/recovery_inspection/tomsg_corrected_reachable_loops.tsv" \
    "$RUN/recovery_inspection/tomsg_corrected_unwindset.txt" \
    > "$RUN/recovery_inspection/tomsg_corrected_reachability_parser_output.txt"

cmp \
    "$PREFLIGHT/inspection/tomsg_precondition_frozen_unwindset.txt" \
    "$RUN/recovery_inspection/tomsg_corrected_unwindset.txt" \
    > "$RUN/recovery_inspection/tomsg_unwindset_comparison.txt"

unwindset="$(
    tr -d '\r\n' \
        < "$RUN/recovery_inspection/tomsg_corrected_unwindset.txt"
)"

[ -n "$unwindset" ] ||
    die "corrected tomsg unwindset is empty"

show_cmd=(
    cbmc
    "$CORRECTED_GOTO"
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
    printf ' %q' "${show_cmd[@]}"
    printf '\n'
} > "$RUN/recovery_commands/tomsg_corrected_show_properties_command.txt"

"${show_cmd[@]}" \
    >"$RUN/recovery_inspection/tomsg_corrected_show_properties.txt" \
    2>"$RUN/recovery_inspection/tomsg_corrected_show_properties_stderr.txt"

if grep -Fq "$EXPECTED_FAILED_PROPERTY" \
    "$RUN/recovery_inspection/tomsg_corrected_show_properties.txt"; then
    die "production-disabled unsigned-overflow property still present"
fi

for marker in \
    SUB_T6_T6_6_SUB_ANCHOR \
    SUB_T6_T6_6_PRE_LOWER \
    SUB_T6_T6_6_PRE_UPPER \
    SUB_T6_T6_6_CONST_INPUT
do
    grep -Fq "$marker" \
        "$RUN/recovery_inspection/tomsg_corrected_show_properties.txt" ||
        die "corrected GOTO missing theorem marker: $marker"
done

corrected_property_count="$(
    grep -Ec '^Property[[:space:]]+' \
        "$RUN/recovery_inspection/tomsg_corrected_show_properties.txt" ||
    true
)"

[ "$corrected_property_count" -ge 1 ] ||
    die "corrected tomsg property inventory is empty"

# ---------------------------------------------------------------------------
# Execute only the corrected fifth proof.
# ---------------------------------------------------------------------------

RESULT_JSON="$RUN/recovery_results/tomsg_precondition_corrected_cbmc_result.json"
RESULT_STDERR="$RUN/recovery_logs/tomsg_precondition_corrected_cbmc_stderr.txt"
RESULT_EXIT="$RUN/recovery_exit_codes/tomsg_precondition_corrected_cbmc_exit_code.txt"
RESULT_RESOURCE="$RUN/recovery_resource_usage/tomsg_precondition_corrected_resource_usage.txt"
RESULT_COMMAND="$RUN/recovery_commands/tomsg_precondition_corrected_cbmc_command.txt"
RESULT_PARSED="$RUN/recovery_results/tomsg_precondition_corrected_parsed_result.txt"
MARKER_AUDIT="$RUN/recovery_results/tomsg_precondition_corrected_marker_audit.txt"

proof_cmd=(
    cbmc
    "$CORRECTED_GOTO"
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
    printf ' %q' "${proof_cmd[@]}"
    printf '\n'
} > "$RESULT_COMMAND"

echo "B6.5 RECOVERY CASE=tomsg_precondition STATUS=RUNNING"

set +e

if [ -n "$TIME_TOOL" ]; then
    "$TIME_TOOL" -v -o "$RESULT_RESOURCE" \
        timeout --signal=TERM --kill-after=60s 21600s \
        "${proof_cmd[@]}" \
        >"$RESULT_JSON" \
        2>"$RESULT_STDERR"
    rc_proof=$?
else
    timeout --signal=TERM --kill-after=60s 21600s \
        "${proof_cmd[@]}" \
        >"$RESULT_JSON" \
        2>"$RESULT_STDERR"
    rc_proof=$?
    echo "RESOURCE_TOOL=UNAVAILABLE" > "$RESULT_RESOURCE"
fi

set -e

printf '%s\n' "$rc_proof" > "$RESULT_EXIT"

[ "$rc_proof" -eq 0 ] ||
    die "corrected tomsg proof returned exit $rc_proof"

[ -s "$RESULT_JSON" ] ||
    die "corrected tomsg result JSON is empty"

python3 \
    "$RUN/recovery_support/audit_positive_json.py" \
    "$RESULT_JSON" \
    "$RESULT_PARSED"

expected_markers=(
    "SUB_T6_T6_6_SUB_ANCHOR"
    "SUB_T6_T6_6_PRE_LOWER"
    "SUB_T6_T6_6_PRE_UPPER"
    "SUB_T6_T6_6_CONST_INPUT"
)

found_markers=0
: > "$MARKER_AUDIT"

for marker in "${expected_markers[@]}"; do
    if grep -Fq "$marker" "$RESULT_PARSED"; then
        echo "$marker=FOUND" >> "$MARKER_AUDIT"
        found_markers=$((found_markers + 1))
    else
        echo "$marker=MISSING" >> "$MARKER_AUDIT"
    fi
done

[ "$found_markers" -eq 4 ] ||
    die "corrected tomsg theorem marker count is not four"

corrected_success="$(
    awk -F= '/^SUCCESS=/{print $2}' "$RESULT_PARSED"
)"
corrected_failure="$(
    awk -F= '/^FAILURE=/{print $2}' "$RESULT_PARSED"
)"
corrected_unknown="$(
    awk -F= '/^UNKNOWN=/{print $2}' "$RESULT_PARSED"
)"
corrected_total="$(
    awk -F= '/^TOTAL_RESULTS=/{print $2}' "$RESULT_PARSED"
)"

[ "$corrected_failure" -eq 0 ] ||
    die "corrected tomsg proof has failed properties"
[ "$corrected_unknown" -eq 0 ] ||
    die "corrected tomsg proof has unknown properties"
[ "$corrected_success" -eq "$corrected_total" ] ||
    die "not all corrected tomsg properties succeeded"

sha256sum "$RESULT_JSON" > "$RESULT_JSON.sha256"

# ---------------------------------------------------------------------------
# Consolidated five-case verdict.
# ---------------------------------------------------------------------------

SUMMARY="$RUN/SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt"

cat > "$SUMMARY" <<EOF
SUB-T6 B6.5 POSITIVE EXECUTION — TOMSG PRAGMA-SCOPE RECOVERY

CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CBMC_VERSION=$CBMC_VERSION
GOTOCC_VERSION=$GOTOCC_VERSION
GOTOINSTRUMENT_VERSION=$GOTOINSTRUMENT_VERSION

ORIGINAL_FAILED_RUN1=$FAILED_RUN
ORIGINAL_TOMSG_TOTAL_RESULTS=885
ORIGINAL_TOMSG_SUCCESS=884
ORIGINAL_TOMSG_FAILURE=1
ORIGINAL_TOMSG_UNKNOWN=0
ORIGINAL_FAILED_PROPERTY=$EXPECTED_FAILED_PROPERTY
ORIGINAL_FAILED_DESCRIPTION=$EXPECTED_FAILED_DESCRIPTION

ROOT_CAUSE=The general verification preinclude undefines CBMC before compress.h is processed, so the production-declared function-local unsigned-overflow exception was not activated.
REPAIR=Load the unchanged production compress.h once under CBMC through a recovery-only preinclude, thereby activating only its own scoped pragmas.
PRODUCTION_SOURCE_MODIFICATION=NO
FROZEN_B6_3_HARNESS_MODIFICATION=NO
FROZEN_B6_4_PREFLIGHT_MODIFICATION=NO

CARRIED_FORWARD_POSITIVE_CASE_COUNT=4
CARRIED_FORWARD_CASE_1=callsite_precondition
CARRIED_FORWARD_CASE_2=callsite_exactness
CARRIED_FORWARD_CASE_3=callsite_frame
CARRIED_FORWARD_CASE_4=sub_reduce_handoff
ALL_CARRIED_FORWARD_RESULTS_REPARSED=PASS

CORRECTED_TOMSG_GOTO_BUILD_EXIT=$rc_build
CORRECTED_TOMSG_PROPERTY_COUNT=$corrected_property_count
ORIGINAL_FAILED_PROPERTY_ABSENT_AFTER_PRODUCTION_PRAGMA_SCOPE=PASS
VERIFICATION_ONLY_UNDEFINED_HELPERS_AUDITED_UNREACHABLE=PASS
CORRECTED_TOMSG_UNWINDSET_UNCHANGED=PASS
CORRECTED_TOMSG_CBMC_EXIT=$rc_proof
CORRECTED_TOMSG_SUCCESS=$corrected_success
CORRECTED_TOMSG_FAILURE=$corrected_failure
CORRECTED_TOMSG_UNKNOWN=$corrected_unknown
CORRECTED_TOMSG_TOTAL_RESULTS=$corrected_total
CORRECTED_TOMSG_MARKERS_FOUND=$found_markers

POSITIVE_CASE_COUNT=5
ALL_FIVE_POSITIVE_CASES_SUCCESS=PASS
T6_1_OBJECT_VALIDITY_AND_SEPARATION=PASS
T6_2_REPRESENTABILITY_DERIVATION=PASS
T6_3_CALLSITE_EXACTNESS=PASS
T6_4_CALLER_FRAME_PRESERVATION=PASS
T6_5_SUB_REDUCE_HANDOFF=PASS
T6_6_TOMSG_PRECONDITION_AND_CONST_INPUT=PASS
T6_7_COMPLETE_SLICE_SAFETY=PASS
B6_5_STATUS=PASS

CBMC_PROOF_EXECUTION=YES
REACHABILITY_EXECUTION=NO
EXPECTED_FAILURE_EXECUTION=NO
PRODUCTION_SOURCE_MODIFICATION=NO
BATCH5_MODIFICATION=NO
EOF

cat > "$RUN/SUB_T6_B6_5_RECOVERY_RATIONALE.md" <<EOF
# SUB-T6 B6.5 tomsg verification-adapter recovery

The first tomsg run completed normally and produced 884 successful properties
and one failure: \`$EXPECTED_FAILED_PROPERTY\`.

The failure was generated by the command-line unsigned-overflow check at
\`compress.h:66\`. It was not one of the SUB-T6 theorem assertions.

The unchanged production \`compress.h\` places
\`mlk_scalar_compress_d1\` inside a CBMC push/disable/pop region for
\`unsigned-overflow\`. The source documents this modular arithmetic as
intentional. The general SUB-T6 preinclude had loaded \`verify.h\` under
\`CBMC\` and then undefined the macro before \`compress.h\` was processed.
Consequently, the production-declared scoped pragma was accidentally omitted.

The recovery does not alter production code or the frozen harness. It
preincludes the same frozen production \`compress.h\` once while \`CBMC\` is
defined. This activates only the pragma already present in the source. The
reachable call graph and model-derived unwindset remain unchanged. The
original counterexample is retained as a configuration-control artefact.
EOF

cp "$FAMILY/SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256" \
    "$RUN/frozen_inputs/"
cp "$PREFLIGHT/SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256" \
    "$RUN/frozen_inputs/"
cp "$PREFLIGHT/SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt" \
    "$RUN/frozen_inputs/"
cp "$PREFLIGHT/inspection/tomsg_precondition_frozen_unwindset.txt" \
    "$RUN/frozen_inputs/"

MANIFEST="SUB_T6_B6_5_POSITIVE_RECOVERY_ARTIFACT_MANIFEST.sha256"

(
    cd "$RUN"

    find . -type f \
        ! -name "$MANIFEST" \
        -print0 |
    sort -z |
    xargs -0 sha256sum > "$MANIFEST"

    sha256sum -c "$MANIFEST"
)

find "$RUN" -type f -exec chmod 0444 {} +
find "$RUN" -type f -name '*.py' -exec chmod 0555 {} +
find "$RUN" -type f -name '*.sh' -exec chmod 0555 {} +
chmod 0555 "$RUN/executed_recovery_runner.sh"
find "$RUN" -type d -exec chmod 0555 {} +

tar -C "$POS_PARENT" \
    -czf "$PACKAGE" \
    "$(basename "$RUN")"

SUCCESS=1
trap - EXIT

echo
echo "============================================================"
echo "FINAL B6.5 RECOVERY SUMMARY"
echo "============================================================"

grep -E \
  'ORIGINAL_TOMSG_TOTAL_RESULTS=|ORIGINAL_TOMSG_SUCCESS=|ORIGINAL_TOMSG_FAILURE=|ORIGINAL_TOMSG_UNKNOWN=|ORIGINAL_FAILED_PROPERTY=|PRODUCTION_SOURCE_MODIFICATION=|FROZEN_B6_3_HARNESS_MODIFICATION=|FROZEN_B6_4_PREFLIGHT_MODIFICATION=|CARRIED_FORWARD_POSITIVE_CASE_COUNT=|ALL_CARRIED_FORWARD_RESULTS_REPARSED=|CORRECTED_TOMSG_GOTO_BUILD_EXIT=|CORRECTED_TOMSG_PROPERTY_COUNT=|ORIGINAL_FAILED_PROPERTY_ABSENT_AFTER_PRODUCTION_PRAGMA_SCOPE=|CORRECTED_TOMSG_UNWINDSET_UNCHANGED=|CORRECTED_TOMSG_CBMC_EXIT=|CORRECTED_TOMSG_SUCCESS=|CORRECTED_TOMSG_FAILURE=|CORRECTED_TOMSG_UNKNOWN=|CORRECTED_TOMSG_TOTAL_RESULTS=|CORRECTED_TOMSG_MARKERS_FOUND=|POSITIVE_CASE_COUNT=|ALL_FIVE_POSITIVE_CASES_SUCCESS=|T6_1_OBJECT_VALIDITY_AND_SEPARATION=|T6_2_REPRESENTABILITY_DERIVATION=|T6_3_CALLSITE_EXACTNESS=|T6_4_CALLER_FRAME_PRESERVATION=|T6_5_SUB_REDUCE_HANDOFF=|T6_6_TOMSG_PRECONDITION_AND_CONST_INPUT=|T6_7_COMPLETE_SLICE_SAFETY=|B6_5_STATUS=' \
  "$SUMMARY"

echo
echo "--- B6.5 recovery package ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$PACKAGE"
sha256sum "$PACKAGE"

echo
echo "B65_ORIGINAL_SINGLE_FAILURE_CLASSIFIED=PASS"
echo "B65_ROOT_CAUSE_VERIFICATION_ADAPTER_SCOPE=CONFIRMED"
echo "B65_PRODUCTION_DECLARED_PRAGMA_RESTORED=YES"
echo "B65_VERIFICATION_ONLY_HELPERS_UNREACHABLE=PASS"
echo "B65_PRODUCTION_SOURCE_MODIFIED=NO"
echo "B65_FROZEN_HARNESS_MODIFIED=NO"
echo "B65_PRIOR_POSITIVE_CASES_REUSED=4"
echo "B65_CORRECTED_TOMSG_PROOF=PASS"
echo "B65_ALL_FIVE_POSITIVE_CASES=PASS"
echo "B65_UPLOAD_REQUIRED=YES"
echo "B65_STATUS=PASS"
