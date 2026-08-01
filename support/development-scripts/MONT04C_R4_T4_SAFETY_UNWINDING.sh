#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

EXPECTED_H14_HARNESS_HASH="2a4489df76b97cc03126f272f854bcfd3aa5b74f0268fffce77658d48a42194b"
EXPECTED_H14_MAKEFILE_HASH="5177e1bdfd24c068ef28326e9ab7e2eafc532b13f2c039d05ffa8903afb97768"
EXPECTED_H14_GOTO_HASH="9afe1a455c89e28e595e0bc51f997f086e466e69d178066f15d8fb26943a2857"

EXPECTED_H235_HARNESS_HASH="662a52e12e01ceeae630b2ea31e678465bba65cf34392fcc8e900198ee933d16"
EXPECTED_H235_MAKEFILE_HASH="e8207c332522362c04999d36a2365096cd83bfbfe7b949b8570722cfa4758855"
EXPECTED_H235_GOTO_HASH="3a6194b2787992287ca77403d0f5f28d6f907837cd7a83cb171cff6cff267564"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WT="$ROOT/MONT_T4_WORKTREE_af4c5abd_20260726T225651Z"

H14_DIR="$WT/proofs/cbmc/mont_t4_p1_p4_roundtrip_zero"
H14_STEM="mont_t4_p1_p4_roundtrip_zero_harness"
H14_HARNESS="$H14_DIR/$H14_STEM.c"
H14_MAKEFILE="$H14_DIR/Makefile"
H14_GOTO="$H14_DIR/gotos/$H14_STEM.goto"

H235_DIR="$WT/proofs/cbmc/mont_t4_p2_p3_p5_bijection_locality"
H235_STEM="mont_t4_p2_p3_p5_bijection_locality_harness"
H235_HARNESS="$H235_DIR/$H235_STEM.c"
H235_MAKEFILE="$H235_DIR/Makefile"
H235_GOTO="$H235_DIR/gotos/$H235_STEM.goto"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT04C_R4_T4_SAFETY_UNWINDING_$STAMP"
CAPTURE="$OUT/MONT04C_R4_TERMINAL_CAPTURE_$STAMP.txt"

SAFETY_TIMEOUT=1800
UNWIND_BOUND=257

mkdir -p "$OUT"

section()
{
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

fail()
{
    echo "$1"
    exit "$2"
}

hash_file()
{
    sha256sum "$1" | awk '{print $1}'
}

discover_r3_capture()
{
    local directory
    local capture
    local sidecar
    local actual
    local recorded

    while IFS= read -r directory
    do
        capture="$(
            find "$directory" -maxdepth 1 -type f \
                -name 'MONT04C_R3_TERMINAL_CAPTURE_*.txt' |
            head -n 1
        )"

        [[ -n "$capture" && -f "$capture" ]] || continue

        if ! grep -Fxq \
                "MONT04C_R3_NONVACUITY_GATE=PASS_6_OF_6" \
                "$capture" ||
           ! grep -Fxq \
                "MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5" \
                "$capture" ||
           ! grep -Fxq \
                "MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1" \
                "$capture" ||
           ! grep -Fxq \
                "MONT_T4_NONVACUITY_WITNESSES=PASS_6_OF_6" \
                "$capture" ||
           ! grep -Fxq \
                "MONT_T4_STATUS=FUNCTIONAL_AND_NONVACUITY_ACCEPTED" \
                "$capture" ||
           ! grep -Fxq "MONT_T4_THEOREM_DOMAIN_CHANGED=NO" "$capture" ||
           ! grep -Fxq "MONT_T4_THEOREM_WEAKENED=NO" "$capture" ||
           ! grep -Fxq "MONT04C_R3_CAPTURE_END=YES" "$capture"
        then
            continue
        fi

        sidecar="${capture}.sha256"
        [[ -f "$sidecar" ]] || continue

        actual="$(hash_file "$capture")"
        recorded="$(awk 'NR == 1 {print $1}' "$sidecar")"

        [[ "$actual" == "$recorded" ]] || continue

        printf '%s\n' "$capture"
        return 0

    done < <(
        find "$ROOT" -maxdepth 1 -type d \
            -name 'MONT04C_R3_T4_NONVACUITY_*' \
            -printf '%T@ %p\n' |
        sort -nr |
        cut -d' ' -f2-
    )

    return 1
}

run_safety()
{
    local tag="$1"
    local goto_file="$2"
    local log="$OUT/${tag}_SAFETY.log"

    timeout "$SAFETY_TIMEOUT" cbmc \
        --flush \
        --object-bits 8 \
        --no-assertions \
        --bounds-check \
        --pointer-check \
        --div-by-zero-check \
        --conversion-check \
        --float-overflow-check \
        --nan-check \
        --pointer-overflow-check \
        --signed-overflow-check \
        --unsigned-overflow-check \
        --undefined-shift-check \
        --unwind "$UNWIND_BOUND" \
        --unwinding-assertions \
        --trace \
        "$goto_file" >"$log" 2>&1

    local rc=$?

    echo "T4_${tag}_SAFETY_KEY_RESULTS_BEGIN"
    grep -E \
        'unwinding assertion|array bounds|pointer dereference|division by zero|overflow|undefined shift|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR|Out of memory' \
        "$log" || true
    echo "T4_${tag}_SAFETY_KEY_RESULTS_END"

    python3 - "$tag" "$rc" "$log" <<'PY'
from pathlib import Path
import re
import sys

tag = sys.argv[1]
rc = int(sys.argv[2])
text = Path(sys.argv[3]).read_text(errors="replace")
lower = text.lower()

failure_lines = [
    line for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]

success_lines = [
    line for line in text.splitlines()
    if re.search(r": SUCCESS\s*$", line)
]

unwinding_success_lines = [
    line for line in success_lines
    if "unwinding assertion" in line.lower()
]

theorem_result_lines = [
    line for line in text.splitlines()
    if "MONT-T4.P" in line or "MONT-T4.SUPPORT" in line
]

error_present = (
    "VERIFICATION ERROR" in text
    or "\nERROR:" in text
    or "Caught exception" in text
    or "Out of memory" in text
)

if rc == 124:
    verdict = "TIMEOUT_INCONCLUSIVE"
    audit_pass = False
elif (
    rc == 0
    and "VERIFICATION SUCCESSFUL" in text
    and "VERIFICATION FAILED" not in text
    and not failure_lines
    and not error_present
    and len(success_lines) > 0
    and len(unwinding_success_lines) > 0
    and len(theorem_result_lines) == 0
):
    verdict = "PASS"
    audit_pass = True
elif (
    rc == 10
    and "VERIFICATION FAILED" in text
    and not error_present
):
    verdict = "GENERATED_PROPERTY_FAILURE"
    audit_pass = False
else:
    verdict = "TOOL_OR_AUDIT_FAILURE"
    audit_pass = False

print(f"T4_{tag}_SAFETY_DIRECT_RC={rc}")
print(f"T4_{tag}_GENERATED_SUCCESS_COUNT={len(success_lines)}")
print(
    f"T4_{tag}_UNWINDING_SUCCESS_COUNT="
    f"{len(unwinding_success_lines)}"
)
print(f"T4_{tag}_FAILURE_COUNT={len(failure_lines)}")
print(
    f"T4_{tag}_THEOREM_RESULT_LINE_COUNT="
    f"{len(theorem_result_lines)}"
)
print(f"T4_{tag}_SAFETY_VERDICT={verdict}")
print(
    f"T4_{tag}_SAFETY_AUDIT="
    f"{'PASS' if audit_pass else 'FAIL'}"
)

raise SystemExit(0 if audit_pass else 1)
PY
}

validate_worktree_status()
{
    python3 - "$WT" <<'PY'
from pathlib import Path
import subprocess
import sys

wt = Path(sys.argv[1])

allowed_prefixes = (
    "?? proofs/cbmc/mont_t4_p1_p4_roundtrip_zero/",
    "?? proofs/cbmc/mont_t4_p2_p3_p5_bijection_locality/",
    "?? proofs/cbmc/mont_t4_control_p1_p4/",
    "?? proofs/cbmc/mont_t4_control_p2_p3_p5/",
)

result = subprocess.run(
    [
        "git",
        "-C",
        str(wt),
        "status",
        "--porcelain=v1",
        "--untracked-files=all",
    ],
    check=True,
    capture_output=True,
    text=True,
)

lines = [
    line
    for line in result.stdout.splitlines()
    if line.strip()
]

unexpected = [
    line
    for line in lines
    if not line.startswith(allowed_prefixes)
]

print(f"T4_WORKTREE_STATUS_LINE_COUNT={len(lines)}")
print(f"T4_WORKTREE_UNEXPECTED_STATUS_COUNT={len(unexpected)}")

for index, line in enumerate(unexpected, start=1):
    print(f"T4_WORKTREE_UNEXPECTED_{index}={line}")

raise SystemExit(0 if not unexpected else 1)
PY
}

{
    section "MONT-04C-R4 — GENERATED SAFETY + LOOP-UNWINDING AUDIT"
    echo "UTC_TIME=$STAMP"
    echo "OUTPUT_DIRECTORY=$OUT"
    echo "SAFETY_TIMEOUT=$SAFETY_TIMEOUT"
    echo "UNWIND_BOUND=$UNWIND_BOUND"
    echo "THEOREM_ASSERTIONS_DISABLED_FOR_THIS_GATE=YES"
    echo "FROZEN_GOTO_REUSED=YES"
    echo "THEOREM_RESULTS_REUSED_FROM_R1_R2=YES"
    echo "THEOREM_DOMAIN_CHANGED=NO"
    echo "THEOREM_WEAKENED=NO"

    section "R0 — BIND SUCCESSFUL FUNCTIONAL + NON-VACUITY PACKAGE"

    R3_CAPTURE="$(discover_r3_capture)" ||
        fail "SUCCESSFUL_R3_CAPTURE_DISCOVERY=FAIL" 20

    echo "MONT04C_R3_CAPTURE=$R3_CAPTURE"
    echo "MONT04C_R3_CAPTURE_SHA256=$(hash_file "$R3_CAPTURE")"
    echo "MONT04C_R3_SUCCESSFUL_PACKAGE_BINDING=PASS"

    section "R1 — REBIND SOURCE AND BOTH FROZEN GOTO PROGRAMS"

    AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null || true)"
    WT_HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null || true)"
    AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all \
            2>/dev/null || true
    )"

    [[ "$AUTH_HEAD" == "$EXPECTED_COMMIT" &&
       "$WT_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$AUTH_STATUS" ]] ||
        fail "COMMIT_OR_AUTHORITATIVE_CLEAN_GATE=FAIL" 21

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "SOURCE_BINDING_GATE=FAIL" 22

    [[ -f "$H14_HARNESS" &&
       -f "$H14_MAKEFILE" &&
       -f "$H14_GOTO" &&
       -f "$H235_HARNESS" &&
       -f "$H235_MAKEFILE" &&
       -f "$H235_GOTO" ]] ||
        fail "FROZEN_ARTEFACT_PRESENT_GATE=FAIL" 23

    [[ "$(hash_file "$H14_HARNESS")" == "$EXPECTED_H14_HARNESS_HASH" &&
       "$(hash_file "$H14_MAKEFILE")" == "$EXPECTED_H14_MAKEFILE_HASH" &&
       "$(hash_file "$H14_GOTO")" == "$EXPECTED_H14_GOTO_HASH" &&
       "$(hash_file "$H235_HARNESS")" == "$EXPECTED_H235_HARNESS_HASH" &&
       "$(hash_file "$H235_MAKEFILE")" == "$EXPECTED_H235_MAKEFILE_HASH" &&
       "$(hash_file "$H235_GOTO")" == "$EXPECTED_H235_GOTO_HASH" ]] ||
        fail "FROZEN_ARTEFACT_HASH_GATE=FAIL" 24

    validate_worktree_status ||
        fail "T4_WORKTREE_STATUS_GATE=FAIL" 25

    echo "SOURCE_BINDING_GATE=PASS"
    echo "FROZEN_ARTEFACT_BINDING=PASS_2_OF_2"

    section "R2 — H14 GENERATED SAFETY AND UNWINDING"

    run_safety "H14" "$H14_GOTO" ||
        fail "T4_H14_SAFETY_UNWINDING_GATE=FAIL" 26

    echo "T4_H14_SAFETY_UNWINDING_GATE=PASS"

    section "R3 — H235 GENERATED SAFETY AND UNWINDING"

    run_safety "H235" "$H235_GOTO" ||
        fail "T4_H235_SAFETY_UNWINDING_GATE=FAIL" 27

    echo "T4_H235_SAFETY_UNWINDING_GATE=PASS"

    section "R4 — FINAL INTEGRITY AND GATE-C COMPLETION"

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$H14_HARNESS")" == "$EXPECTED_H14_HARNESS_HASH" &&
       "$(hash_file "$H14_MAKEFILE")" == "$EXPECTED_H14_MAKEFILE_HASH" &&
       "$(hash_file "$H14_GOTO")" == "$EXPECTED_H14_GOTO_HASH" &&
       "$(hash_file "$H235_HARNESS")" == "$EXPECTED_H235_HARNESS_HASH" &&
       "$(hash_file "$H235_MAKEFILE")" == "$EXPECTED_H235_MAKEFILE_HASH" &&
       "$(hash_file "$H235_GOTO")" == "$EXPECTED_H235_GOTO_HASH" ]] ||
        fail "FINAL_INTEGRITY_GATE=FAIL" 28

    FINAL_AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all
    )"

    [[ -z "$FINAL_AUTH_STATUS" ]] ||
        fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 29

    validate_worktree_status ||
        fail "FINAL_T4_WORKTREE_STATUS_GATE=FAIL" 30

    BINDING="$OUT/MONT04C_R4_T4_SAFETY_UNWINDING_BINDING.env"

    cat >"$BINDING" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H=$EXPECTED_POLY_H
EXPECTED_POLY_C=$EXPECTED_POLY_C
T4_WORKTREE=$WT
MONT04C_R3_CAPTURE=$R3_CAPTURE
MONT04C_R3_CAPTURE_SHA256=$(hash_file "$R3_CAPTURE")
H14_HARNESS_SHA256=$EXPECTED_H14_HARNESS_HASH
H14_MAKEFILE_SHA256=$EXPECTED_H14_MAKEFILE_HASH
H14_GOTO_SHA256=$EXPECTED_H14_GOTO_HASH
H235_HARNESS_SHA256=$EXPECTED_H235_HARNESS_HASH
H235_MAKEFILE_SHA256=$EXPECTED_H235_MAKEFILE_HASH
H235_GOTO_SHA256=$EXPECTED_H235_GOTO_HASH
T4_H14_SAFETY_UNWINDING=PASS
T4_H235_SAFETY_UNWINDING=PASS
MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5
MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1
MONT_T4_NONVACUITY_WITNESSES=PASS_6_OF_6
MONT_T4_SAFETY_UNWINDING_GATE=PASS_2_OF_2
MONT_T4_THEOREM_DOMAIN_CHANGED=NO
MONT_T4_THEOREM_WEAKENED=NO
EOF

    echo "MONT04C_R4_BINDING_FILE=$BINDING"
    echo "MONT04C_R4_BINDING_SHA256=$(hash_file "$BINDING")"
    echo "FINAL_SOURCE_INTEGRITY=PASS"
    echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
    echo "FINAL_FROZEN_ARTEFACT_INTEGRITY=PASS_2_OF_2"
    echo "T4_H14_SAFETY_UNWINDING_GATE=PASS"
    echo "T4_H235_SAFETY_UNWINDING_GATE=PASS"
    echo "MONT04C_R4_SAFETY_UNWINDING_GATE=PASS_2_OF_2"
    echo "MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5"
    echo "MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1"
    echo "MONT_T4_NONVACUITY_WITNESSES=PASS_6_OF_6"
    echo "MONT_T4_THEOREM_DOMAIN_CHANGED=NO"
    echo "MONT_T4_THEOREM_WEAKENED=NO"
    echo "MONT_T4_STATUS=PROVISIONAL_ACCEPT_PENDING_MUTATION_PACKAGE"
    echo "NEXT_GATE=MONT-04D_T4_SPECIFIC_MUTATIONS"
    echo "MONT04C_R4_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
