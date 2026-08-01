#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

EXPECTED_MONT04B_CAPTURE_HASH="05c56c666de47585f0c3b0123661989a7f8bb8c266cb9c3fbfcaf7010a790509"
EXPECTED_BINDING_HASH="8f1304a854ddb3c9fefe6f101364b455bbb157a647991cd36b34f4bd7b24604e"

EXPECTED_H235_HARNESS_HASH="662a52e12e01ceeae630b2ea31e678465bba65cf34392fcc8e900198ee933d16"
EXPECTED_H235_MAKEFILE_HASH="e8207c332522362c04999d36a2365096cd83bfbfe7b949b8570722cfa4758855"
EXPECTED_H235_GOTO_HASH="3a6194b2787992287ca77403d0f5f28d6f907837cd7a83cb171cff6cff267564"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WT="$ROOT/MONT_T4_WORKTREE_af4c5abd_20260726T225651Z"

MONT04B_CAPTURE="$ROOT/MONT04B_T4_HARNESS_FREEZE_20260726T225651Z/MONT04B_TERMINAL_CAPTURE_20260726T225651Z.txt"
MONT04B_BINDING="$ROOT/MONT04B_T4_HARNESS_FREEZE_20260726T225651Z/MONT04B_T4_FREEZE_BINDING.env"

H235_DIR="$WT/proofs/cbmc/mont_t4_p2_p3_p5_bijection_locality"
H235_STEM="mont_t4_p2_p3_p5_bijection_locality_harness"
H235_HARNESS="$H235_DIR/$H235_STEM.c"
H235_MAKEFILE="$H235_DIR/Makefile"
H235_GOTO="$H235_DIR/gotos/$H235_STEM.goto"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT04C_R2_H235_SHARDS_$STAMP"
CAPTURE="$OUT/MONT04C_R2_TERMINAL_CAPTURE_$STAMP.txt"

PROPERTY_TIMEOUT=1800
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

discover_successful_r1_capture()
{
    local directory capture sidecar actual recorded

    while IFS= read -r directory
    do
        capture="$(
            find "$directory" -maxdepth 1 -type f \
                -name 'MONT04C_R1_TERMINAL_CAPTURE_*.txt' |
            head -n 1
        )"

        [[ -n "$capture" && -f "$capture" ]] || continue

        if ! grep -Fxq \
                "MONT04C_R1_H14_PROPERTY_SHARD_GATE=PASS_3_OF_3" \
                "$capture" ||
           ! grep -Fxq "MONT_T4_P1_VERIFIED=YES" "$capture" ||
           ! grep -Fxq "MONT_T4_P4_VERIFIED=YES" "$capture" ||
           ! grep -Fxq \
                "MONT_T4_SUPPORTING_FORWARD_LEMMA_VERIFIED=YES" \
                "$capture" ||
           ! grep -Fxq "MONT_T4_THEOREM_DOMAIN_CHANGED=NO" "$capture" ||
           ! grep -Fxq "MONT_T4_THEOREM_WEAKENED=NO" "$capture" ||
           ! grep -Fxq "MONT04C_R1_CAPTURE_END=YES" "$capture"
        then
            continue
        fi

        actual="$(hash_file "$capture")"
        sidecar="${capture}.sha256"

        [[ -f "$sidecar" ]] || continue
        recorded="$(awk 'NR == 1 {print $1}' "$sidecar")"
        [[ "$recorded" == "$actual" ]] || continue

        printf '%s\n' "$capture"
        return 0

    done < <(
        find "$ROOT" -maxdepth 1 -type d \
            \( -name 'MONT04C_R1_H14_SHARDS_*' \
               -o -name 'MONT04C_R1_H14_PROPERTY_SHARDS_*' \) \
            -printf '%T@ %p\n' |
        sort -nr |
        cut -d' ' -f2-
    )

    return 1
}

find_property_id()
{
    local description="$1"
    local show_file="$2"

    python3 - "$description" "$show_file" <<'PY'
from pathlib import Path
import re
import sys

description = sys.argv[1]
text = Path(sys.argv[2]).read_text(errors="replace")

blocks = re.split(r"(?m)^Property\s+", text)
matches = []

for block in blocks[1:]:
    first_line, _, rest = block.partition("\n")
    property_id = first_line.rstrip(":").strip()

    if description in rest:
        matches.append(property_id)

if len(matches) != 1:
    raise SystemExit(
        f"property match count={len(matches)} for {description}"
    )

print(matches[0])
PY
}

run_one_property()
{
    local tag="$1"
    local description="$2"
    local property_id="$3"
    local log

    log="$OUT/${tag}.log"

    timeout "$PROPERTY_TIMEOUT" cbmc \
        --flush \
        --object-bits 8 \
        --reachability-slice \
        --slice-formula \
        --unwind "$UNWIND_BOUND" \
        --unwinding-assertions \
        --trace \
        --property "$property_id" \
        "$H235_GOTO" >"$log" 2>&1

    local rc=$?

    echo "${tag}_PROPERTY_ID=$property_id"
    echo "${tag}_PROPERTY_DESCRIPTION=$description"

    echo "${tag}_KEY_RESULTS_BEGIN"
    grep -E \
        'MONT-T4\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR|Out of memory' \
        "$log" || true
    echo "${tag}_KEY_RESULTS_END"

    python3 - "$tag" "$description" "$rc" "$log" <<'PY'
from pathlib import Path
import re
import sys

tag = sys.argv[1]
description = sys.argv[2]
rc = int(sys.argv[3])
text = Path(sys.argv[4]).read_text(errors="replace")

failure_lines = [
    line for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]

target_success = f"{description}: SUCCESS" in text

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
    and target_success
    and not failure_lines
    and not error_present
):
    verdict = "PASS"
    audit_pass = True
elif (
    rc == 10
    and "VERIFICATION FAILED" in text
    and not error_present
):
    verdict = "COUNTEREXAMPLE"
    audit_pass = False
else:
    verdict = "TOOL_OR_AUDIT_FAILURE"
    audit_pass = False

print(f"{tag}_DIRECT_RC={rc}")
print(f"{tag}_FAILURE_COUNT={len(failure_lines)}")
print(f"{tag}_TARGET_SUCCESS={'YES' if target_success else 'NO'}")
print(f"{tag}_VERDICT={verdict}")
print(f"{tag}_AUDIT={'PASS' if audit_pass else 'FAIL'}")

raise SystemExit(0 if audit_pass else 1)
PY
}

{
    section "MONT-04C-R2 — H235 THEOREM-PRESERVING PROPERTY SHARDS"
    echo "UTC_TIME=$STAMP"
    echo "OUTPUT_DIRECTORY=$OUT"
    echo "PROPERTY_TIMEOUT=$PROPERTY_TIMEOUT"
    echo "UNWIND_BOUND=$UNWIND_BOUND"
    echo "FROZEN_GOTO_REUSED=YES"
    echo "THEOREM_DOMAIN_CHANGED=NO"
    echo "THEOREM_WEAKENED=NO"
    echo "EXECUTION_MODE=SEQUENTIAL"

    section "R0 — BIND MONT-04B AND SUCCESSFUL H14 SHARD PACKAGE"

    [[ -f "$MONT04B_CAPTURE" &&
       -f "${MONT04B_CAPTURE}.sha256" &&
       -f "$MONT04B_BINDING" ]] ||
        fail "MONT04B_PACKAGE_PRESENT_GATE=FAIL" 20

    ACTUAL_CAPTURE_HASH="$(hash_file "$MONT04B_CAPTURE")"
    SIDECAR_CAPTURE_HASH="$(
        awk 'NR == 1 {print $1}' "${MONT04B_CAPTURE}.sha256"
    )"

    [[ "$ACTUAL_CAPTURE_HASH" == "$EXPECTED_MONT04B_CAPTURE_HASH" &&
       "$SIDECAR_CAPTURE_HASH" == "$ACTUAL_CAPTURE_HASH" ]] ||
        fail "MONT04B_CAPTURE_BINDING_GATE=FAIL" 21

    [[ "$(hash_file "$MONT04B_BINDING")" == "$EXPECTED_BINDING_HASH" ]] ||
        fail "MONT04B_BINDING_FILE_HASH_GATE=FAIL" 22

    R1_CAPTURE="$(discover_successful_r1_capture)" ||
        fail "SUCCESSFUL_R1_CAPTURE_DISCOVERY=FAIL" 23

    echo "MONT04B_PACKAGE_BINDING=PASS"
    echo "MONT04C_R1_CAPTURE=$R1_CAPTURE"
    echo "MONT04C_R1_CAPTURE_SHA256=$(hash_file "$R1_CAPTURE")"
    echo "MONT04C_R1_SUCCESSFUL_PACKAGE_BINDING=PASS"

    section "R1 — REBIND SOURCE AND FROZEN H235 ARTEFACTS"

    AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null || true)"
    WT_HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null || true)"
    AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all \
            2>/dev/null || true
    )"

    [[ "$AUTH_HEAD" == "$EXPECTED_COMMIT" &&
       "$WT_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$AUTH_STATUS" ]] ||
        fail "COMMIT_OR_AUTHORITATIVE_CLEAN_GATE=FAIL" 24

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] ||
        fail "SOURCE_BINDING_GATE=FAIL" 25

    [[ -f "$H235_HARNESS" &&
       -f "$H235_MAKEFILE" &&
       -f "$H235_GOTO" ]] ||
        fail "H235_FROZEN_ARTEFACT_PRESENT_GATE=FAIL" 26

    [[ "$(hash_file "$H235_HARNESS")" == "$EXPECTED_H235_HARNESS_HASH" &&
       "$(hash_file "$H235_MAKEFILE")" == "$EXPECTED_H235_MAKEFILE_HASH" &&
       "$(hash_file "$H235_GOTO")" == "$EXPECTED_H235_GOTO_HASH" ]] ||
        fail "H235_FROZEN_ARTEFACT_HASH_GATE=FAIL" 27

    echo "SOURCE_AND_H235_BINDING=PASS"

    section "R2 — PROPERTY-ID DISCOVERY"

    SHOW_FILE="$OUT/H235_SHOW_PROPERTIES.txt"

    cbmc --show-properties "$H235_GOTO" >"$SHOW_FILE" 2>&1
    SHOW_RC=$?

    echo "H235_SHOW_PROPERTIES_RC=$SHOW_RC"

    [[ "$SHOW_RC" -eq 0 ]] ||
        fail "H235_SHOW_PROPERTIES_GATE=FAIL" 28

    P2_DESC="MONT-T4.P2.residue_equivalence_preservation_stronger_local_form"
    P3_DESC="MONT-T4.P3.residue_equivalence_reflection_stronger_local_form"
    P5_DESC="MONT-T4.P5.coefficient_locality_no_cross_talk"

    P2_ID="$(find_property_id "$P2_DESC" "$SHOW_FILE")" ||
        fail "P2_PROPERTY_ID_DISCOVERY=FAIL" 29

    P3_ID="$(find_property_id "$P3_DESC" "$SHOW_FILE")" ||
        fail "P3_PROPERTY_ID_DISCOVERY=FAIL" 30

    P5_ID="$(find_property_id "$P5_DESC" "$SHOW_FILE")" ||
        fail "P5_PROPERTY_ID_DISCOVERY=FAIL" 31

    echo "P2_PROPERTY_ID=$P2_ID"
    echo "P3_PROPERTY_ID=$P3_ID"
    echo "P5_PROPERTY_ID=$P5_ID"
    echo "PROPERTY_ID_DISCOVERY=PASS_3_OF_3"

    section "R3 — P2 RESIDUE-EQUIVALENCE PRESERVATION SHARD"

    run_one_property \
        "T4_P2_SHARD" \
        "$P2_DESC" \
        "$P2_ID" ||
        fail "T4_P2_SHARD_GATE=FAIL" 32

    section "R4 — P3 RESIDUE-EQUIVALENCE REFLECTION SHARD"

    run_one_property \
        "T4_P3_SHARD" \
        "$P3_DESC" \
        "$P3_ID" ||
        fail "T4_P3_SHARD_GATE=FAIL" 33

    section "R5 — P5 COEFFICIENT LOCALITY SHARD"

    run_one_property \
        "T4_P5_SHARD" \
        "$P5_DESC" \
        "$P5_ID" ||
        fail "T4_P5_SHARD_GATE=FAIL" 34

    section "R6 — FINAL INTEGRITY AND H235 SHARD VERDICT"

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$H235_HARNESS")" == "$EXPECTED_H235_HARNESS_HASH" &&
       "$(hash_file "$H235_MAKEFILE")" == "$EXPECTED_H235_MAKEFILE_HASH" &&
       "$(hash_file "$H235_GOTO")" == "$EXPECTED_H235_GOTO_HASH" ]] ||
        fail "FINAL_INTEGRITY_GATE=FAIL" 35

    FINAL_AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all
    )"

    [[ -z "$FINAL_AUTH_STATUS" ]] ||
        fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 36

    BINDING="$OUT/MONT04C_R2_H235_SHARD_BINDING.env"

    cat >"$BINDING" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
MONT04B_CAPTURE_SHA256=$EXPECTED_MONT04B_CAPTURE_HASH
MONT04B_BINDING_SHA256=$EXPECTED_BINDING_HASH
MONT04C_R1_CAPTURE=$R1_CAPTURE
MONT04C_R1_CAPTURE_SHA256=$(hash_file "$R1_CAPTURE")
H235_HARNESS_SHA256=$EXPECTED_H235_HARNESS_HASH
H235_MAKEFILE_SHA256=$EXPECTED_H235_MAKEFILE_HASH
H235_GOTO_SHA256=$EXPECTED_H235_GOTO_HASH
P2_PROPERTY_ID=$P2_ID
P3_PROPERTY_ID=$P3_ID
P5_PROPERTY_ID=$P5_ID
T4_P2_SHARD=PASS
T4_P3_SHARD=PASS
T4_P5_SHARD=PASS
T4_THEOREM_DOMAIN_CHANGED=NO
T4_THEOREM_WEAKENED=NO
EOF

    echo "MONT04C_R2_BINDING_FILE=$BINDING"
    echo "MONT04C_R2_BINDING_SHA256=$(hash_file "$BINDING")"
    echo "FINAL_SOURCE_INTEGRITY=PASS"
    echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
    echo "FINAL_H235_FROZEN_ARTEFACT_INTEGRITY=PASS"
    echo "MONT04C_R2_H235_PROPERTY_SHARD_GATE=PASS_3_OF_3"
    echo "MONT_T4_P2_VERIFIED=YES"
    echo "MONT_T4_P3_VERIFIED=YES"
    echo "MONT_T4_P5_VERIFIED=YES"
    echo "MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5"
    echo "MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1"
    echo "MONT_T4_STRONGER_LOCAL_P2_P3_FORMS=VERIFIED"
    echo "MONT_T4_THEOREM_DOMAIN_CHANGED=NO"
    echo "MONT_T4_THEOREM_WEAKENED=NO"
    echo "NEXT_GATE=MONT-04C-R3_SIX_WITNESS_NONVACUITY"
    echo "MONT04C_R2_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
