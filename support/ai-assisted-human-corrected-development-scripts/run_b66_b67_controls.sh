#!/usr/bin/env bash
set -euo pipefail
umask 0022

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
SRC="$ROOT/source/mlkem"

FAMILY="$B6/03_HARNESS_FREEZE/frozen_harness_family_v1"
PREFLIGHT="$B6/04_GOTO_PREFLIGHT/B6_4_GOTO_PREFLIGHT_MLKEM768"
B65="$B6/05_POSITIVE_EXECUTION/B6_5_POSITIVE_EXECUTION_MLKEM768_RUN4_TOMSG_PRAGMA_RECOVERY_V3"

B66="$B6/06_REACHABILITY/B6_6_REACHABILITY_MLKEM768_RUN1"
B67="$B6/07_EXPECTED_FAILURES/B6_7_EXPECTED_FAILURES_MLKEM768_RUN1"

PACKAGE="$HOME/Downloads/SUB_T6_B6_6_7_CONTROLS.tar.gz"

EXPECTED_POLYC_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_POLYH_SHA="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_COMPRESSC_SHA="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESSH_SHA="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"

echo "============================================================"
echo "SUB-T6 COMBINED B6.6 + B6.7 CONTROL EXECUTION"
echo "============================================================"
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "ROOT=$ROOT"
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
    "$ROOT" "$B6" "$SRC" "$FAMILY" "$PREFLIGHT" "$B65" \
    "$B6/06_REACHABILITY" "$B6/07_EXPECTED_FAILURES"
do
    [ -d "$path" ] || die "required directory missing: $path"
done

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
echo "--- Revalidating frozen B6.3, B6.4 and B6.5 evidence ---"

(
    cd "$FAMILY"
    sha256sum -c SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256
)

(
    cd "$PREFLIGHT"
    sha256sum -c SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256
)

(
    cd "$B65"
    sha256sum -c SUB_T6_B6_5_POSITIVE_RECOVERY_ARTIFACT_MANIFEST.sha256
)

grep -q '^B6_4_STATUS=PASS$' \
    "$PREFLIGHT/SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt" ||
    die "B6.4 PASS verdict missing"

grep -q '^B6_5_STATUS=PASS$' \
    "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt" ||
    die "B6.5 PASS verdict missing"

grep -q '^ALL_FIVE_POSITIVE_CASES_SUCCESS=PASS$' \
    "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt" ||
    die "B6.5 all-five-positive verdict missing"

KNOWN_GOOD_WRAP_ADAPTER="$B65/recovery_support/sub00r_b6_compress_intended_wrap_scope.h"

[ -f "$KNOWN_GOOD_WRAP_ADAPTER" ] ||
    die "known-good B6.5 wrap adapter missing"

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

target = [
    item for item in unique
    if marker in item[0] or marker in item[2]
]

target_failures = sum(
    1 for _, status, _ in target
    if status == "FAILURE"
)

other_failures = sum(
    1 for prop, status, desc in unique
    if status == "FAILURE"
    and marker not in prop
    and marker not in desc
)

unknown = sum(
    1 for _, status, _ in unique
    if status not in {"SUCCESS", "FAILURE"}
)

success = sum(
    1 for _, status, _ in unique
    if status == "SUCCESS"
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

if not unique:
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

write_reachable_parser()
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
    allowed_undefined_csv,
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
    loop_match = re.fullmatch(
        r"Loop\s+(\S+):",
        line.strip(),
    )

    if loop_match:
        current_id = loop_match.group(1)
        continue

    if current_id is not None:
        function_match = re.search(
            r"\bfunction\s+(\S+)\s*$",
            line,
        )

        if function_match:
            loop_records.append(
                (current_id, function_match.group(1))
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

allowed_undefined = {
    item for item in allowed_undefined_csv.split(",")
    if item
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

contract_helpers = {
    "array_abs_bound",
    "array_bound",
    "cassert",
}

bad_reachable_helpers = sorted(
    contract_helpers & reachable
)
bad_undefined_helpers = sorted(
    contract_helpers & set(undefined)
)

if bad_reachable_helpers:
    raise SystemExit(
        "CONTRACT_HELPERS_REACHABLE="
        + ",".join(bad_reachable_helpers)
    )

if bad_undefined_helpers:
    raise SystemExit(
        "CONTRACT_HELPERS_UNDEFINED="
        + ",".join(bad_undefined_helpers)
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
print("CONTRACT_HELPERS_REACHABLE=0")
print("CONTRACT_HELPERS_UNDEFINED=0")
print(f"UNWINDSET={unwindset}")
PY

    chmod 0755 "$output"
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
    local manifest="$2"

    (
        cd "$run"

        find . -type f \
            ! -name "$manifest" \
            -print0 |
        sort -z |
        xargs -0 sha256sum > "$manifest"

        sha256sum -c "$manifest"
    )

    find "$run" -type f -exec chmod 0444 {} +
    find "$run" -type f -name '*.py' -exec chmod 0555 {} +
    find "$run" -type f -name '*.sh' -exec chmod 0555 {} +
    find "$run" -type d -exec chmod 0555 {} +
}

verify_completed_run()
{
    local run="$1"
    local manifest="$2"
    local summary="$3"
    local verdict="$4"

    [ -d "$run" ] || return 1
    [ -f "$run/$manifest" ] || die "existing run manifest missing: $run"
    [ -f "$run/$summary" ] || die "existing run summary missing: $run"

    (
        cd "$run"
        sha256sum -c "$manifest"
    )

    grep -q "^${verdict}$" "$run/$summary" ||
        die "existing run verdict missing: $verdict"

    return 0
}

# ===========================================================================
# B6.6
# ===========================================================================

if verify_completed_run \
    "$B66" \
    "SUB_T6_B6_6_ARTIFACT_MANIFEST.sha256" \
    "SUB_T6_B6_6_REACHABILITY_SUMMARY.txt" \
    "B6_6_STATUS=PASS"
then
    echo "B6_6_EXISTING_FROZEN_RUN_REUSED=YES"
else
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
        "$B66/companion_results" \
        "$B66/coverage_results" \
        "$B66/commands" \
        "$B66/logs" \
        "$B66/exit_codes" \
        "$B66/resource_usage" \
        "$B66/support" \
        "$B66/frozen_inputs"

    cp "$(readlink -f "$0")" "$B66/executed_runner.sh"

    write_positive_auditor \
        "$B66/support/audit_positive_json.py"
    write_reachable_parser \
        "$B66/support/derive_reachable_unwindset.py"

    cat > "$B66/control_family/support/sub00r_b6_cover_neutral_companion.h" <<'EOF'
#ifndef SUB00R_B6_COVER_NEUTRAL_COMPANION_H
#define SUB00R_B6_COVER_NEUTRAL_COMPANION_H

/*
 * Proof-only companion transformation.
 * The untouched original GOTO model is used for --cover cover.
 */
#define __CPROVER_cover(condition) ((void)0)

#endif
EOF

    cat > "$B66/control_family/harnesses/sub_t6_reachability_harness.c" <<'EOF'
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

    REACH_HARNESS="$B66/control_family/harnesses/sub_t6_reachability_harness.c"
    NEUTRAL_HEADER="$B66/control_family/support/sub00r_b6_cover_neutral_companion.h"

    cover_count="$(
        grep -c '__CPROVER_cover(' "$REACH_HARNESS"
    )"

    [ "$cover_count" -eq 12 ] ||
        die "B6.6 cover count is not 12"

    for marker in \
        SUB_T6_REACH_ANCHOR_EXACT \
        SUB_T6_REACH_REDUCE_LOWER \
        SUB_T6_REACH_REDUCE_UPPER
    do
        grep -q "$marker" "$REACH_HARNESS" ||
            die "B6.6 anchor missing: $marker"
    done

    if grep -RInE \
        '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)' \
        "$B66/control_family"; then
        die "false assumption detected in B6.6"
    fi

    cat > "$B66/control_family/SUB_T6_B6_6_CONTROL_FAMILY_FREEZE.md" <<EOF
# SUB-T6 B6.6 reachability control family

Status: FROZEN before GOTO construction.

Cover goals: 12.

The untouched original model is used for coverage. A separately named
cover-neutral companion proves all ordinary assertions and unwinding
assertions with the same reachable-loop unwindset.
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

    ORIGINAL_GOTO="$B66/build/reachability_original.goto"
    COMPANION_GOTO="$B66/build/reachability_companion.goto"

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
        die "B6.6 original GOTO build failed"

    [ "$rc_companion_build" -eq 0 ] ||
        die "B6.6 companion GOTO build failed"

    sha256sum "$ORIGINAL_GOTO" > "$ORIGINAL_GOTO.sha256"
    sha256sum "$COMPANION_GOTO" > "$COMPANION_GOTO.sha256"

    for model in original companion; do
        if [ "$model" = "original" ]; then
            goto_file="$ORIGINAL_GOTO"
        else
            goto_file="$COMPANION_GOTO"
        fi

        goto-instrument --validate-goto-binary "$goto_file" \
            >"$B66/inspection/${model}_validate.txt" 2>&1

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
            "nondet_int16_t,nondet_unsigned" \
            > "$B66/inspection/${model}_parser_output.txt"
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
        die "B6.6 unwindset is empty"

    companion_json="$B66/companion_results/reachability_companion_result.json"
    companion_stderr="$B66/logs/reachability_companion_stderr.txt"
    companion_exit="$B66/exit_codes/reachability_companion_exit_code.txt"
    companion_resource="$B66/resource_usage/reachability_companion_resource.txt"
    companion_command="$B66/commands/reachability_companion_cbmc_command.txt"
    companion_parsed="$B66/companion_results/reachability_companion_parsed.txt"
    companion_marker_audit="$B66/companion_results/reachability_companion_marker_audit.txt"

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

    if [ -n "$TIME_TOOL" ]; then
        "$TIME_TOOL" -v -o "$companion_resource" \
            timeout --signal=TERM --kill-after=60s 21600s \
            "${companion_cmd[@]}" \
            >"$companion_json" \
            2>"$companion_stderr"
        rc_companion=$?
    else
        timeout --signal=TERM --kill-after=60s 21600s \
            "${companion_cmd[@]}" \
            >"$companion_json" \
            2>"$companion_stderr"
        rc_companion=$?
        echo "RESOURCE_TOOL=UNAVAILABLE" > "$companion_resource"
    fi

    set -e

    printf '%s\n' "$rc_companion" > "$companion_exit"

    [ "$rc_companion" -eq 0 ] ||
        die "B6.6 companion proof returned $rc_companion"

    python3 \
        "$B66/support/audit_positive_json.py" \
        "$companion_json" \
        "$companion_parsed"

    companion_found=0
    : > "$companion_marker_audit"

    for marker in \
        SUB_T6_REACH_ANCHOR_EXACT \
        SUB_T6_REACH_REDUCE_LOWER \
        SUB_T6_REACH_REDUCE_UPPER
    do
        if grep -Fq "$marker" "$companion_parsed"; then
            echo "$marker=FOUND" >> "$companion_marker_audit"
            companion_found=$((companion_found + 1))
        else
            echo "$marker=MISSING" >> "$companion_marker_audit"
        fi
    done

    [ "$companion_found" -eq 3 ] ||
        die "B6.6 companion marker audit failed"

    sha256sum "$companion_json" > "$companion_json.sha256"

    coverage_stdout="$B66/coverage_results/reachability_coverage_result.txt"
    coverage_stderr="$B66/logs/reachability_coverage_stderr.txt"
    coverage_exit="$B66/exit_codes/reachability_coverage_exit_code.txt"
    coverage_resource="$B66/resource_usage/reachability_coverage_resource.txt"
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

    echo "B6.6 PHASE=ORIGINAL_COVERAGE STATUS=RUNNING"

    set +e

    if [ -n "$TIME_TOOL" ]; then
        "$TIME_TOOL" -v -o "$coverage_resource" \
            timeout --signal=TERM --kill-after=60s 21600s \
            "${coverage_cmd[@]}" \
            >"$coverage_stdout" \
            2>"$coverage_stderr"
        rc_coverage=$?
    else
        timeout --signal=TERM --kill-after=60s 21600s \
            "${coverage_cmd[@]}" \
            >"$coverage_stdout" \
            2>"$coverage_stderr"
        rc_coverage=$?
        echo "RESOURCE_TOOL=UNAVAILABLE" > "$coverage_resource"
    fi

    set -e

    printf '%s\n' "$rc_coverage" > "$coverage_exit"

    [ "$rc_coverage" -eq 0 ] ||
        die "B6.6 coverage returned $rc_coverage"

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
        die "B6.6 coverage summary missing"

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
        die "B6.6 coverage total is not 12"

    [ "$satisfied" -eq 12 ] ||
        die "B6.6 not all covers satisfied"

    [ "$satisfied_lines" -eq 12 ] ||
        die "B6.6 SATISFIED line count is not 12"

    [ "$failed" -eq 0 ] ||
        die "B6.6 one or more covers failed"

    sha256sum "$coverage_stdout" > "$coverage_stdout.sha256"

    companion_success="$(
        awk -F= '/^SUCCESS=/{print $2}' "$companion_parsed"
    )"

    companion_failure="$(
        awk -F= '/^FAILURE=/{print $2}' "$companion_parsed"
    )"

    companion_unknown="$(
        awk -F= '/^UNKNOWN=/{print $2}' "$companion_parsed"
    )"

    B66_SUMMARY="$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt"

    cat > "$B66_SUMMARY" <<EOF
SUB-T6 B6.6 REACHABILITY AND NON-VACUITY SUMMARY

CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CBMC_VERSION=$CBMC_VERSION
B6_5_POSITIVE_EVIDENCE=$B65

EXPECTED_COVER_GOALS=12
COMPANION_EXIT=$rc_companion
COMPANION_SUCCESS=$companion_success
COMPANION_FAILURE=$companion_failure
COMPANION_UNKNOWN=$companion_unknown
COMPANION_MARKERS_FOUND=$companion_found
COVERAGE_EXIT=$rc_coverage
COVERAGE_SATISFIED=$satisfied
COVERAGE_FAILED=$failed
COVERAGE_TOTAL=$total

LOWER_SUBTRACTION_BOUNDARY=REACHABLE
UPPER_SUBTRACTION_BOUNDARY=REACHABLE
NEUTRAL_SUBTRACTION=REACHABLE
POSITIVE_SB=REACHABLE
NEGATIVE_SB=REACHABLE
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

PRODUCTION_SOURCE_MODIFICATION=NO
FROZEN_POSITIVE_HARNESS_MODIFICATION=NO
BATCH5_MODIFICATION=NO
EOF

    cp "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_ARTIFACT_MANIFEST.sha256" \
        "$B66/frozen_inputs/"
    cp "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt" \
        "$B66/frozen_inputs/"

    freeze_run \
        "$B66" \
        "SUB_T6_B6_6_ARTIFACT_MANIFEST.sha256"

    echo "B6_6_STATUS=PASS"
    ACTIVE_RUN=""
fi

# ===========================================================================
# B6.7
# ===========================================================================

if verify_completed_run \
    "$B67" \
    "SUB_T6_B6_7_ARTIFACT_MANIFEST.sha256" \
    "SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt" \
    "B6_7_STATUS=PASS"
then
    echo "B6_7_EXISTING_FROZEN_RUN_REUSED=YES"
else
    echo
    echo "============================================================"
    echo "B6.7 — EXPECTED-FAILURE CONTROLS"
    echo "============================================================"

    ACTIVE_RUN="$B67"

    mkdir -p \
        "$B67/control_family/harnesses" \
        "$B67/control_family/support" \
        "$B67/build" \
        "$B67/inspection" \
        "$B67/full_results" \
        "$B67/witnesses" \
        "$B67/commands" \
        "$B67/logs" \
        "$B67/exit_codes" \
        "$B67/resource_usage" \
        "$B67/support" \
        "$B67/frozen_inputs"

    cp "$(readlink -f "$0")" "$B67/executed_runner.sh"

    write_expected_failure_auditor \
        "$B67/support/audit_expected_failure_json.py"

    write_reachable_parser \
        "$B67/support/derive_reachable_unwindset.py"

    cp "$KNOWN_GOOD_WRAP_ADAPTER" \
        "$B67/control_family/support/sub00r_b6_compress_intended_wrap_scope.h"

    cat > "$B67/control_family/harnesses/sub_t6_ef_false_overflow_harness.c" <<'EOF'
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
      "SUB_T6_EF_T6_1_EXPECTED_FAILURE: some allowed subtraction exceeds int16_t");

  return 0;
}
EOF

    cat > "$B67/control_family/harnesses/sub_t6_ef_false_canonicalisation_failure_harness.c" <<'EOF'
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
      "SUB_T6_EF_T6_3_EXPECTED_FAILURE: reduced tomsg input is incompatible");

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

    EF_NEEDS_REDUCE=(
        "no"
        "yes"
        "yes"
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
            die "B6.7 marker count is not one: $marker"
    done

    if grep -RInE \
        '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)' \
        "$B67/control_family"; then
        die "false assumption detected in B6.7"
    fi

    cat > "$B67/control_family/SUB_T6_B6_7_CONTROL_FAMILY_FREEZE.md" <<EOF
# SUB-T6 B6.7 expected-failure control family

Status: FROZEN before GOTO construction.

Controls:
1. False overflow-existence claim.
2. False post-reduction noncanonical-existence claim.
3. False reduced-input incompatibility claim after actual mlk_poly_tomsg.

The third control uses the exact known-good intended-wrap adapter frozen in
B6.5. Acceptance requires exactly one registered target failure, no unrelated
failure, no unknown property and one targeted counterexample per control.
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

    printf '%s\n' \
        "SUB-T6 B6.7 EXPECTED-FAILURE SUMMARY" \
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
        need_reduce="${EF_NEEDS_REDUCE[$idx]}"
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
        )

        if [ "$need_tomsg" = "yes" ]; then
            build_cmd+=(
                -include "$B67/control_family/support/sub00r_b6_compress_intended_wrap_scope.h"
            )
        fi

        build_cmd+=(
            -I"$SRC"
            -I"$SRC/src"
            -I"$FAMILY/support"
            -I"$B67/control_family/support"
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
            die "B6.7 GOTO build failed: $case_name"

        sha256sum "$goto_file" > "$goto_file.sha256"

        goto-instrument --validate-goto-binary "$goto_file" \
            >"$B67/inspection/${case_name}_validate.txt" 2>&1

        goto-instrument --show-loops "$goto_file" \
            >"$B67/inspection/${case_name}_show_loops.txt" 2>&1

        goto-instrument --reachable-call-graph "$goto_file" \
            >"$B67/inspection/${case_name}_reachable_call_graph.txt" 2>&1

        goto-instrument --list-undefined-functions "$goto_file" \
            >"$B67/inspection/${case_name}_undefined_functions.txt" 2>&1

        required="main,mlk_sub00r_b6_poly_sub"

        if [ "$need_reduce" = "yes" ]; then
            required="${required},mlk_sub00r_b6_poly_reduce"
        fi

        if [ "$need_tomsg" = "yes" ]; then
            required="${required},mlk_sub00r_b6_poly_tomsg"
        fi

        python3 \
            "$B67/support/derive_reachable_unwindset.py" \
            "$B67/inspection/${case_name}_reachable_call_graph.txt" \
            "$B67/inspection/${case_name}_show_loops.txt" \
            "$B67/inspection/${case_name}_undefined_functions.txt" \
            "$B67/inspection/${case_name}_reachable_functions.txt" \
            "$B67/inspection/${case_name}_reachable_loops.tsv" \
            "$B67/inspection/${case_name}_unwindset.txt" \
            "$required" \
            "nondet_int16_t" \
            > "$B67/inspection/${case_name}_parser_output.txt"

        if [ "$need_tomsg" = "yes" ]; then
            mapfile -t scalar_helpers < <(
                grep '^mlk_scalar_compress_' \
                    "$B67/inspection/${case_name}_reachable_functions.txt" \
                    || true
            )

            [ "${#scalar_helpers[@]}" -eq 1 ] ||
                die "B6.7 tomsg scalar-helper count is not one"

            [ "${scalar_helpers[0]}" = "mlk_scalar_compress_d1" ] ||
                die "B6.7 reachable scalar helper is not d1"

            {
                echo "REACHABLE_SCALAR_COMPRESS_HELPER=mlk_scalar_compress_d1"
                echo "OTHER_REACHABLE_SCALAR_COMPRESS_HELPERS=0"
                echo "KNOWN_GOOD_B6_5_ADAPTER_REUSED=YES"
            } > "$B67/inspection/${case_name}_scalar_scope_audit.txt"
        fi

        unwindset="$(
            tr -d '\r\n' \
                < "$B67/inspection/${case_name}_unwindset.txt"
        )"

        [ -n "$unwindset" ] ||
            die "B6.7 unwindset empty: $case_name"

        show_cmd=(
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

        write_command \
            "$B67/commands/${case_name}_show_properties_command.txt" \
            "${show_cmd[@]}"

        "${show_cmd[@]}" \
            >"$B67/inspection/${case_name}_show_properties.txt" \
            2>"$B67/inspection/${case_name}_show_properties_stderr.txt"

        marker_count="$(
            grep -Fc "$marker" \
                "$B67/inspection/${case_name}_show_properties.txt" \
                || true
        )"

        [ "$marker_count" -eq 1 ] ||
            die "B6.7 target marker inventory count is not one: $case_name"

        if [ "$need_tomsg" = "yes" ]; then
            if grep -Fq 'mlk_scalar_compress_d1.overflow.3' \
                "$B67/inspection/${case_name}_show_properties.txt"; then
                die "B6.7 known intended-wrap property reappeared"
            fi
        fi

        full_json="$B67/full_results/${case_name}_full_result.json"
        full_stderr="$B67/logs/${case_name}_full_stderr.txt"
        full_exit="$B67/exit_codes/${case_name}_full_exit_code.txt"
        full_resource="$B67/resource_usage/${case_name}_full_resource.txt"
        full_command="$B67/commands/${case_name}_full_command.txt"
        parsed="$B67/full_results/${case_name}_parsed.txt"
        isolation="$B67/full_results/${case_name}_isolation_audit.txt"

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

        if [ -n "$TIME_TOOL" ]; then
            "$TIME_TOOL" -v -o "$full_resource" \
                timeout --signal=TERM --kill-after=60s 21600s \
                "${full_cmd[@]}" \
                >"$full_json" \
                2>"$full_stderr"
            rc_full=$?
        else
            timeout --signal=TERM --kill-after=60s 21600s \
                "${full_cmd[@]}" \
                >"$full_json" \
                2>"$full_stderr"
            rc_full=$?
            echo "RESOURCE_TOOL=UNAVAILABLE" > "$full_resource"
        fi

        set -e

        printf '%s\n' "$rc_full" > "$full_exit"

        [ "$rc_full" -eq 10 ] ||
            die "B6.7 full model returned $rc_full: $case_name"

        python3 \
            "$B67/support/audit_expected_failure_json.py" \
            "$full_json" \
            "$parsed" \
            "$marker"

        success_count="$(
            awk -F= '/^SUCCESS=/{print $2}' "$parsed"
        )"

        target_failure="$(
            awk -F= '/^TARGET_FAILURE=/{print $2}' "$parsed"
        )"

        other_failure="$(
            awk -F= '/^OTHER_FAILURE=/{print $2}' "$parsed"
        )"

        unknown_count="$(
            awk -F= '/^UNKNOWN=/{print $2}' "$parsed"
        )"

        target_property="$(
            sed -n 's/^TARGET_PROPERTY=//p' "$parsed"
        )"

        {
            echo "MARKER=$marker"
            echo "TARGET_PROPERTY=$target_property"
            echo "TARGET_FAILURE=$target_failure"
            echo "OTHER_FAILURE=$other_failure"
            echo "UNKNOWN=$unknown_count"
        } > "$isolation"

        sha256sum "$full_json" > "$full_json.sha256"

        witness_stdout="$B67/witnesses/${case_name}_witness.txt"
        witness_stderr="$B67/logs/${case_name}_witness_stderr.txt"
        witness_exit="$B67/exit_codes/${case_name}_witness_exit_code.txt"
        witness_resource="$B67/resource_usage/${case_name}_witness_resource.txt"
        witness_command="$B67/commands/${case_name}_witness_command.txt"

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

        write_command \
            "$witness_command" \
            "${witness_cmd[@]}"

        echo "B6.7 CASE=$case_name PHASE=TARGETED_WITNESS STATUS=RUNNING"

        set +e

        if [ -n "$TIME_TOOL" ]; then
            "$TIME_TOOL" -v -o "$witness_resource" \
                timeout --signal=TERM --kill-after=60s 21600s \
                "${witness_cmd[@]}" \
                >"$witness_stdout" \
                2>"$witness_stderr"
            rc_witness=$?
        else
            timeout --signal=TERM --kill-after=60s 21600s \
                "${witness_cmd[@]}" \
                >"$witness_stdout" \
                2>"$witness_stderr"
            rc_witness=$?
            echo "RESOURCE_TOOL=UNAVAILABLE" > "$witness_resource"
        fi

        set -e

        printf '%s\n' "$rc_witness" > "$witness_exit"

        [ "$rc_witness" -eq 10 ] ||
            die "B6.7 witness returned $rc_witness: $case_name"

        grep -Fq "$marker" "$witness_stdout" ||
            die "B6.7 witness marker missing: $case_name"

        grep -q 'Violated property' "$witness_stdout" ||
            die "B6.7 witness violation heading missing: $case_name"

        grep -q 'VERIFICATION FAILED' "$witness_stdout" ||
            die "B6.7 witness verdict missing: $case_name"

        sha256sum "$witness_stdout" > "$witness_stdout.sha256"

        printf '%s|%s|%s|%s|%s|%s|%s|%s|1|PASS\n' \
            "$case_name" \
            "$rc_full" \
            "$success_count" \
            "$target_failure" \
            "$other_failure" \
            "$unknown_count" \
            "$target_property" \
            "$rc_witness" \
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

    witness_total="$(
        awk -F'|' '
          /^ef_/ {sum += $9}
          END {print sum+0}
        ' "$B67_SUMMARY"
    )"

    [ "$target_failure_total" -eq 3 ] ||
        die "B6.7 target-failure total is not three"

    [ "$other_failure_total" -eq 0 ] ||
        die "B6.7 unrelated failures detected"

    [ "$unknown_total" -eq 0 ] ||
        die "B6.7 unknown properties detected"

    [ "$witness_total" -eq 3 ] ||
        die "B6.7 witness total is not three"

    {
        echo
        echo "EXPECTED_FAILURE_CASE_COUNT=3"
        echo "FULL_MODEL_EXPECTED_EXIT_COUNT=$(grep -l '^10$' "$B67/exit_codes"/*_full_exit_code.txt | wc -l)"
        echo "TARGET_FAILURE_TOTAL=$target_failure_total"
        echo "UNEXPECTED_FAILURE_TOTAL=$other_failure_total"
        echo "UNKNOWN_PROPERTY_TOTAL=$unknown_total"
        echo "TARGETED_WITNESS_EXPECTED_EXIT_COUNT=$(grep -l '^10$' "$B67/exit_codes"/*_witness_exit_code.txt | wc -l)"
        echo "TARGETED_WITNESS_MARKER_COUNT=$witness_total"
        echo "EF_T6_1_FALSE_OVERFLOW=REJECTED_AS_EXPECTED"
        echo "EF_T6_2_FALSE_CANONICALISATION_FAILURE=REJECTED_AS_EXPECTED"
        echo "EF_T6_3_FALSE_TOMSG_INCOMPATIBILITY=REJECTED_AS_EXPECTED"
        echo "ALL_NON_TARGET_PROPERTIES_SUCCESS=PASS"
        echo "EXPECTED_FAILURE_ISOLATION=PASS"
        echo "COUNTEREXAMPLE_WITNESSES_CAPTURED=PASS"
        echo "KNOWN_GOOD_B6_5_WRAP_ADAPTER_REUSED=YES"
        echo "B6_7_STATUS=PASS"
        echo
        echo "PRODUCTION_SOURCE_MODIFICATION=NO"
        echo "FROZEN_POSITIVE_HARNESS_MODIFICATION=NO"
        echo "BATCH5_MODIFICATION=NO"
    } >> "$B67_SUMMARY"

    cp "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_ARTIFACT_MANIFEST.sha256" \
        "$B67/frozen_inputs/"
    cp "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt" \
        "$B67/frozen_inputs/"
    cp "$KNOWN_GOOD_WRAP_ADAPTER" \
        "$B67/frozen_inputs/B6_5_KNOWN_GOOD_WRAP_ADAPTER.h"

    freeze_run \
        "$B67" \
        "SUB_T6_B6_7_ARTIFACT_MANIFEST.sha256"

    echo "B6_7_STATUS=PASS"
    ACTIVE_RUN=""
fi

[ -d "$B66" ] || die "B6.6 final run missing"
[ -d "$B67" ] || die "B6.7 final run missing"

verify_completed_run \
    "$B66" \
    "SUB_T6_B6_6_ARTIFACT_MANIFEST.sha256" \
    "SUB_T6_B6_6_REACHABILITY_SUMMARY.txt" \
    "B6_6_STATUS=PASS"

verify_completed_run \
    "$B67" \
    "SUB_T6_B6_7_ARTIFACT_MANIFEST.sha256" \
    "SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt" \
    "B6_7_STATUS=PASS"

if [ -e "$PACKAGE" ]; then
    die "combined B6.6+B6.7 package already exists: $PACKAGE"
fi

tar -C "$B6" \
    -czf "$PACKAGE" \
    "06_REACHABILITY/$(basename "$B66")" \
    "07_EXPECTED_FAILURES/$(basename "$B67")"

SUCCESS=1
trap - EXIT

echo
echo "============================================================"
echo "FINAL B6.6+B6.7 SUMMARY"
echo "============================================================"

grep -E \
  'EXPECTED_COVER_GOALS=|COMPANION_EXIT=|COMPANION_SUCCESS=|COMPANION_FAILURE=|COMPANION_UNKNOWN=|COMPANION_MARKERS_FOUND=|COVERAGE_EXIT=|COVERAGE_SATISFIED=|COVERAGE_FAILED=|COVERAGE_TOTAL=|COMPANION_LOOP_COMPLETENESS=|COMPANION_ALL_PROPERTIES_SUCCESS=|ORIGINAL_MODEL_ALL_COVERS_SATISFIED=|SAME_UNWINDSET_RETAINED=|B6_6_STATUS=' \
  "$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt"

grep -E \
  'EXPECTED_FAILURE_CASE_COUNT=|FULL_MODEL_EXPECTED_EXIT_COUNT=|TARGET_FAILURE_TOTAL=|UNEXPECTED_FAILURE_TOTAL=|UNKNOWN_PROPERTY_TOTAL=|TARGETED_WITNESS_EXPECTED_EXIT_COUNT=|TARGETED_WITNESS_MARKER_COUNT=|EF_T6_1_FALSE_OVERFLOW=|EF_T6_2_FALSE_CANONICALISATION_FAILURE=|EF_T6_3_FALSE_TOMSG_INCOMPATIBILITY=|ALL_NON_TARGET_PROPERTIES_SUCCESS=|EXPECTED_FAILURE_ISOLATION=|COUNTEREXAMPLE_WITNESSES_CAPTURED=|KNOWN_GOOD_B6_5_WRAP_ADAPTER_REUSED=|B6_7_STATUS=' \
  "$B67/SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt"

echo
echo "--- Combined control package ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$PACKAGE"
sha256sum "$PACKAGE"

echo
echo "B66_COVER_GOAL_COUNT=12"
echo "B66_ALL_COVERS_SATISFIED=PASS"
echo "B66_COMPANION_PROOF=PASS"
echo "B66_STATUS=PASS"
echo "B67_EXPECTED_FAILURE_CASE_COUNT=3"
echo "B67_TARGET_FAILURE_TOTAL=3"
echo "B67_UNEXPECTED_FAILURE_TOTAL=0"
echo "B67_COUNTEREXAMPLE_WITNESS_COUNT=3"
echo "B67_KNOWN_GOOD_WRAP_ADAPTER_REUSED=YES"
echo "B67_STATUS=PASS"
echo "B66_B67_PRODUCTION_MODIFIED=NO"
echo "B66_B67_FROZEN_POSITIVE_HARNESSES_MODIFIED=NO"
echo "B66_B67_BATCH5_MODIFIED=NO"
echo "B66_B67_UPLOAD_REQUIRED=YES"
echo "B66_B67_STATUS=PASS"
