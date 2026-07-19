#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
T3FREEZE="$ROOT/SUB00N_BATCH3_T3_HARNESS_FREEZE_V1"
GATE_LOG="/home/girish/SUB00N_T3_FINAL_START_GATE_VALID.txt"

fail() {
    echo "T3_START_GATE=FAIL"
    echo "REASON=$1"
    exit 1
}

{
    echo "SUB00N T3 FINAL START GATE"
    echo "TIMESTAMP=$(date --iso-8601=seconds)"
    echo "T3FREEZE=$T3FREEZE"
    echo

    [ -d "$T3FREEZE" ] ||
        fail "SUB00N freeze directory missing"

    [ -f "$T3FREEZE/FREEZE_VALIDATION.txt" ] ||
        fail "FREEZE_VALIDATION.txt missing"

    [ -f "$T3FREEZE/SUB00N_ARTIFACT_MANIFEST.sha256" ] ||
        fail "SUB00N artifact manifest missing"

    ACTIVE="$(
        pgrep -af 'cbmc|goto-cc|goto-gcc|goto-clang' 2>/dev/null || true
    )"

    if [ -n "$ACTIVE" ]; then
        printf '%s\n' "$ACTIVE"
        fail "formal-tool process still running"
    fi

    echo "PROCESS_CLEANLINESS=PASS"

    echo
    echo "=== FREEZE VALIDATION ==="
    cat "$T3FREEZE/FREEZE_VALIDATION.txt"

    grep -qx 'STATIC_FREEZE_VALIDATION=PASS' \
        "$T3FREEZE/FREEZE_VALIDATION.txt" ||
        fail "static freeze validation did not pass"

    grep -qx 'CBMC_EXECUTION_PERFORMED=NO' \
        "$T3FREEZE/FREEZE_VALIDATION.txt" ||
        fail "unexpected CBMC execution recorded"

    grep -qx 'PRODUCTION_SOURCE_MODIFIED=NO' \
        "$T3FREEZE/FREEZE_VALIDATION.txt" ||
        fail "production-source integrity condition missing"

    echo
    echo "=== MANIFEST VERIFICATION ==="

    (
        cd "$T3FREEZE"
        sha256sum -c SUB00N_ARTIFACT_MANIFEST.sha256
    ) || fail "SUB00N manifest verification failed"

    echo
    echo "T3_START_GATE=PASS"
    echo "SUB00O_GOTO_PREFLIGHT_MAY_BEGIN=YES"
} 2>&1 | tee "$GATE_LOG"

sha256sum "$GATE_LOG"
