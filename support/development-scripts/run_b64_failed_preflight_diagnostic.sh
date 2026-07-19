#!/usr/bin/env bash
set -euo pipefail
umask 0022

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
FAMILY="$B6/03_HARNESS_FREEZE/frozen_harness_family_v1"
PREFLIGHT_PARENT="$B6/04_GOTO_PREFLIGHT"
DIAG="$PREFLIGHT_PARENT/B6_4_RECOVERY_DIAGNOSTIC"
PACKAGE="$HOME/Downloads/SUB_T6_B6_4_FAILED_PREFLIGHT_DIAGNOSTIC.tar.gz"

echo "=== SUB-T6 B6.4 FAILED-PREFLIGHT DIAGNOSTIC ==="
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "FAMILY=$FAMILY"
echo "PREFLIGHT_PARENT=$PREFLIGHT_PARENT"
echo "DIAG=$DIAG"
echo "PACKAGE=$PACKAGE"

test -d "$FAMILY"
test -d "$PREFLIGHT_PARENT"
test -f "$FAMILY/SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256"

if [ -e "$DIAG" ]; then
    echo "DIAGNOSTIC_ALREADY_EXISTS=$DIAG"
    exit 1
fi

if [ -e "$PACKAGE" ]; then
    echo "PACKAGE_ALREADY_EXISTS=$PACKAGE"
    exit 1
fi

mapfile -t FAILED_DIRS < <(
    find "$PREFLIGHT_PARENT" \
        -maxdepth 1 \
        -type d \
        -name 'B6_4_GOTO_PREFLIGHT_MLKEM768_FAILED_*' \
        -printf '%T@ %p\n' |
    sort -nr |
    awk '{sub(/^[^ ]+ /, ""); print}'
)

if [ "${#FAILED_DIRS[@]}" -lt 1 ]; then
    echo "FAILED_PREFLIGHT_DIRECTORY_FOUND=NO"
    exit 1
fi

FAILED="${FAILED_DIRS[0]}"
echo "FAILED_PREFLIGHT_DIRECTORY=$FAILED"

mkdir -p "$DIAG"

{
    echo "=== B6.3 FROZEN FAMILY VERIFICATION ==="
    stat -c 'MODE=%a TYPE=%F FILE=%n' \
      "$FAMILY" \
      "$FAMILY/SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256"

    (
      cd "$FAMILY"
      sha256sum -c SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256
    )
} > "$DIAG/B6_3_FROZEN_FAMILY_VERIFICATION.txt" 2>&1

{
    echo "=== FAILED PREFLIGHT INVENTORY ==="
    find "$FAILED" -maxdepth 4 -printf '%m %y %s %p\n' | sort
} > "$DIAG/FAILED_PREFLIGHT_INVENTORY.txt"

for name in \
  callsite_precondition_show_loops.txt \
  callsite_precondition_reachable_call_graph.txt \
  callsite_precondition_list_goto_functions.txt \
  callsite_precondition_show_goto_functions.txt \
  callsite_precondition_undefined_functions.txt \
  callsite_precondition_calls_and_arguments.txt \
  callsite_precondition_validate_goto_binary.txt \
  callsite_precondition_goto_build_stdout.txt \
  callsite_precondition_goto_build_stderr.txt \
  callsite_precondition_goto_build_command.txt \
  callsite_precondition_goto_build_exit_code.txt
do
    match="$(
      find "$FAILED" -type f -name "$name" -print -quit
    )"

    if [ -n "$match" ]; then
        cp -a "$match" "$DIAG/$name"
    else
        printf 'MISSING=%s\n' "$name" \
          > "$DIAG/${name}.MISSING.txt"
    fi
done

GOTO="$(
  find "$FAILED/build" \
      -maxdepth 1 \
      -type f \
      -name 'callsite_precondition.goto' \
      -print -quit 2>/dev/null || true
)"

if [ -z "$GOTO" ]; then
    echo "CALLSITE_PRECONDITION_GOTO_FOUND=NO"
    exit 1
fi

echo "CALLSITE_PRECONDITION_GOTO=$GOTO"
cp -a "$GOTO.sha256" "$DIAG/" 2>/dev/null || true

goto-instrument --validate-goto-binary "$GOTO" \
  > "$DIAG/FRESH_validate_goto_binary.txt" 2>&1

goto-instrument --show-loops "$GOTO" \
  > "$DIAG/FRESH_show_loops.txt" 2>&1

goto-instrument --reachable-call-graph "$GOTO" \
  > "$DIAG/FRESH_reachable_call_graph.txt" 2>&1

goto-instrument --list-goto-functions "$GOTO" \
  > "$DIAG/FRESH_list_goto_functions.txt" 2>&1

{
    echo "=== EXACT LOOP/CALL DIAGNOSIS ==="

    echo
    echo "--- All loop IDs mentioning SUB-T6 slice functions ---"
    awk '
      /^Loop[[:space:]]+/ {
        id=$2
        sub(/:$/, "", id)
        if(id ~ /^main\./ ||
           id ~ /^sub_t6_assume_callsite_inputs\./ ||
           id ~ /^mlk_sub00r_b6_poly_sub\./ ||
           id ~ /^mlk_poly_reduce_c\./ ||
           id ~ /^mlk_sub00r_b6_poly_tomsg\./)
          print id
      }
    ' "$DIAG/FRESH_show_loops.txt" | sort -u

    echo
    echo "--- Reachable call-graph mentions ---"
    grep -nE \
      '(^|[^A-Za-z0-9_])(main|sub_t6_assume_callsite_inputs|mlk_sub00r_b6_poly_sub|mlk_poly_reduce_c|mlk_sub00r_b6_poly_reduce|mlk_sub00r_b6_poly_tomsg)([^A-Za-z0-9_]|$)' \
      "$DIAG/FRESH_reachable_call_graph.txt" || true

    echo
    echo "--- Function-list mentions ---"
    grep -nE \
      'main|sub_t6_assume_callsite_inputs|mlk_sub00r_b6_poly_sub|mlk_poly_reduce_c|mlk_sub00r_b6_poly_reduce|mlk_sub00r_b6_poly_tomsg' \
      "$DIAG/FRESH_list_goto_functions.txt" || true

    echo
    echo "--- Key Boolean findings ---"

    if grep -q 'mlk_poly_reduce_c' "$DIAG/FRESH_show_loops.txt"; then
        echo "REDUCE_LOOP_PRESENT_IN_GLOBAL_SHOW_LOOPS=YES"
    else
        echo "REDUCE_LOOP_PRESENT_IN_GLOBAL_SHOW_LOOPS=NO"
    fi

    if grep -qE \
      '(^|[^A-Za-z0-9_])mlk_sub00r_b6_poly_reduce([^A-Za-z0-9_]|$)|(^|[^A-Za-z0-9_])mlk_poly_reduce_c([^A-Za-z0-9_]|$)' \
      "$DIAG/FRESH_reachable_call_graph.txt"; then
        echo "REDUCE_PRESENT_IN_REACHABLE_CALL_GRAPH=YES"
    else
        echo "REDUCE_PRESENT_IN_REACHABLE_CALL_GRAPH=NO"
    fi

    if grep -qE \
      '(^|[^A-Za-z0-9_])mlk_sub00r_b6_poly_sub([^A-Za-z0-9_]|$)' \
      "$DIAG/FRESH_reachable_call_graph.txt"; then
        echo "SUB_PRESENT_IN_REACHABLE_CALL_GRAPH=YES"
    else
        echo "SUB_PRESENT_IN_REACHABLE_CALL_GRAPH=NO"
    fi
} | tee "$DIAG/EXACT_LOOP_CALL_DIAGNOSIS.txt"

{
    echo "DIAGNOSTIC_SCHEMA=sub-t6-b6.4-failed-preflight-diagnostic-v1"
    echo "CREATED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "FAILED_PREFLIGHT_DIRECTORY=$FAILED"
    echo "B6_3_HARNESS_FAMILY_FROZEN=YES"
    echo "GOTO_BINARY_CONSTRUCTED=YES"
    echo "GOTO_BINARY_VALIDATED=YES"
    echo "CBMC_PROOF_EXECUTED=NO"
    echo "PRODUCTION_MODIFIED=NO"
    echo "BATCH5_MODIFIED=NO"
    echo "DIAGNOSTIC_READ_ONLY_WITH_RESPECT_TO_FROZEN_ARTIFACTS=YES"
} > "$DIAG/DIAGNOSTIC_MANIFEST.txt"

(
  cd "$DIAG"
  find . -type f \
      ! -name 'DIAGNOSTIC_SHA256.txt' \
      -print0 |
  sort -z |
  xargs -0 sha256sum > DIAGNOSTIC_SHA256.txt
  sha256sum -c DIAGNOSTIC_SHA256.txt
)

tar -C "$PREFLIGHT_PARENT" \
  -czf "$PACKAGE" \
  "$(basename "$DIAG")"

echo
echo "--- Diagnostic package ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$PACKAGE"
sha256sum "$PACKAGE"

echo
echo "B6_3_HARNESS_FAMILY_FROZEN=YES"
echo "B6_4_FAILED_PREFLIGHT_PRESERVED=YES"
echo "B6_4_CALLSITE_GOTO_CONSTRUCTED=YES"
echo "B6_4_CALLSITE_GOTO_VALIDATED=YES"
echo "B6_4_CBMC_PROOF_EXECUTED=NO"
echo "B6_4_PRODUCTION_MODIFIED=NO"
echo "B6_4_BATCH5_MODIFIED=NO"
echo "B6_4_DIAGNOSTIC_PACKAGE_CREATED=YES"
echo "B6_4_DIAGNOSTIC_UPLOAD_REQUIRED=YES"
echo "B6_4_DIAGNOSTIC_STATUS=PASS"
