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

SOURCE="$WT/mlkem/src/poly.c"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT04D_T4_MUTATIONS_$STAMP"
CAPTURE="$OUT/MONT04D_TERMINAL_CAPTURE_$STAMP.txt"

BUILD_TIMEOUT=600
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

restore_source()
{
    cp "$OUT/PRISTINE_poly.c" "$SOURCE"

    [[ "$(hash_file "$SOURCE")" == "$EXPECTED_POLY_C" ]]
}

restore_pristine_gotos()
{
    mkdir -p "$H14_DIR/gotos" "$H235_DIR/gotos"

    cp "$OUT/PRISTINE_H14.goto" "$H14_GOTO"
    cp "$OUT/PRISTINE_H235.goto" "$H235_GOTO"

    [[ "$(hash_file "$H14_GOTO")" == "$EXPECTED_H14_GOTO_HASH" &&
       "$(hash_file "$H235_GOTO")" == "$EXPECTED_H235_GOTO_HASH" ]]
}

cleanup()
{
    restore_source >/dev/null 2>&1 || true
    restore_pristine_gotos >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

discover_r4_capture()
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
                -name 'MONT04C_R4_TERMINAL_CAPTURE_*.txt' |
            head -n 1
        )"

        [[ -n "$capture" && -f "$capture" ]] || continue

        if ! grep -Fxq \
                "MONT04C_R4_SAFETY_UNWINDING_GATE=PASS_2_OF_2" \
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
                "MONT_T4_STATUS=PROVISIONAL_ACCEPT_PENDING_MUTATION_PACKAGE" \
                "$capture" ||
           ! grep -Fxq "MONT_T4_THEOREM_DOMAIN_CHANGED=NO" "$capture" ||
           ! grep -Fxq "MONT_T4_THEOREM_WEAKENED=NO" "$capture" ||
           ! grep -Fxq "MONT04C_R4_CAPTURE_END=YES" "$capture"
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
            -name 'MONT04C_R4_T4_SAFETY_UNWINDING_*' \
            -printf '%T@ %p\n' |
        sort -nr |
        cut -d' ' -f2-
    )

    return 1
}

validate_worktree_status()
{
    local phase="$1"

    python3 - "$WT" "$phase" <<'PY'
from pathlib import Path
import subprocess
import sys

wt = Path(sys.argv[1])
phase = sys.argv[2]

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

print(f"T4_WORKTREE_{phase}_STATUS_LINE_COUNT={len(lines)}")
print(
    f"T4_WORKTREE_{phase}_UNEXPECTED_STATUS_COUNT="
    f"{len(unexpected)}"
)

for index, line in enumerate(unexpected, start=1):
    print(f"T4_WORKTREE_{phase}_UNEXPECTED_{index}={line}")

raise SystemExit(0 if not unexpected else 1)
PY
}

apply_mutation()
{
    local mutation="$1"

    restore_source ||
        fail "SOURCE_RESTORE_BEFORE_${mutation}=FAIL" 30

    python3 - "$SOURCE" "$mutation" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
mutation = sys.argv[2]
text = path.read_text()

start_marker = "MLK_STATIC_TESTABLE void mlk_poly_tomont_c"
end_marker = "\nMLK_INTERNAL_API"

start = text.find(start_marker)
if start < 0:
    raise SystemExit("mlk_poly_tomont_c start marker not found")

end = text.find(end_marker, start)
if end < 0:
    raise SystemExit("mlk_poly_tomont_c end marker not found")

before = text[:start]
block = text[start:end]
after = text[end:]

factor_line = (
    "  const int16_t f = 1353; "
    "/* check-magic: 1353 == signed_mod(2^32, MLKEM_Q) */\n"
)

assignment_line = (
    "    r->coeffs[i] = mlk_fqmul(r->coeffs[i], f);\n"
)

if block.count(factor_line) != 1:
    raise SystemExit(
        f"factor line count={block.count(factor_line)}, expected 1"
    )

if block.count(assignment_line) != 1:
    raise SystemExit(
        f"assignment line count={block.count(assignment_line)}, expected 1"
    )

if mutation == "M1_WRONG_R2_FACTOR":
    replacement = (
        "  const int16_t f = 1354; "
        "/* intentional mutant: wrong Montgomery R^2 factor */\n"
    )
    block = block.replace(factor_line, replacement, 1)

elif mutation == "M2_NEXT_COEFFICIENT_CROSSTALK":
    replacement = (
        "    r->coeffs[i] = mlk_fqmul(\n"
        "        r->coeffs[(i + 1u) % MLKEM_N], f);\n"
    )
    block = block.replace(assignment_line, replacement, 1)

elif mutation == "M3_ZERO_ALL_OUTPUTS":
    replacement = "    r->coeffs[i] = 0;\n"
    block = block.replace(assignment_line, replacement, 1)

else:
    raise SystemExit(f"unknown mutation: {mutation}")

path.write_text(before + block + after)
print(f"MUTATION_APPLIED={mutation}")
PY

    [[ "$(hash_file "$SOURCE")" != "$EXPECTED_POLY_C" ]] ||
        fail "MUTATED_SOURCE_HASH_UNCHANGED_${mutation}=FAIL" 31

    echo "${mutation}_SOURCE_SHA256=$(hash_file "$SOURCE")"
}

build_mutant()
{
    local tag="$1"
    local proof_dir="$2"
    local goto_file="$3"

    make -C "$proof_dir" MLKEM_K=3 clean \
        >"$OUT/${tag}_CLEAN.log" 2>&1 || true

    timeout "$BUILD_TIMEOUT" \
        make -C "$proof_dir" MLKEM_K=3 goto \
        >"$OUT/${tag}_BUILD.log" 2>&1

    local rc=$?

    echo "${tag}_BUILD_RC=$rc"

    if [[ "$rc" -ne 0 || ! -f "$goto_file" ]]; then
        echo "${tag}_GOTO_PRESENT=NO"
        tail -n 140 "$OUT/${tag}_BUILD.log" || true
        return 1
    fi

    echo "${tag}_GOTO_PRESENT=YES"
    echo "${tag}_MUTANT_GOTO_SHA256=$(hash_file "$goto_file")"

    return 0
}

find_property_id()
{
    local goto_file="$1"
    local description="$2"
    local show_file="$3"

    cbmc --show-properties "$goto_file" >"$show_file" 2>&1
    local show_rc=$?

    [[ "$show_rc" -eq 0 ]] || return 1

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

run_expected_rejection()
{
    local tag="$1"
    local goto_file="$2"
    local description="$3"
    local property_id="$4"
    local log="$OUT/${tag}_CBMC.log"

    timeout "$PROPERTY_TIMEOUT" cbmc \
        --flush \
        --object-bits 8 \
        --reachability-slice \
        --slice-formula \
        --unwind "$UNWIND_BOUND" \
        --unwinding-assertions \
        --trace \
        --property "$property_id" \
        "$goto_file" >"$log" 2>&1

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

target_failures = [
    line for line in failure_lines
    if f"{description}: FAILURE" in line
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
    rc == 10
    and "VERIFICATION FAILED" in text
    and "VERIFICATION SUCCESSFUL" not in text
    and not error_present
    and len(failure_lines) == 1
    and len(target_failures) == 1
):
    verdict = "EXPECTEDLY_REJECTED"
    audit_pass = True
elif (
    rc == 0
    and "VERIFICATION SUCCESSFUL" in text
):
    verdict = "MUTANT_SURVIVED"
    audit_pass = False
else:
    verdict = "TOOL_OR_AUDIT_FAILURE"
    audit_pass = False

print(f"{tag}_DIRECT_RC={rc}")
print(f"{tag}_FAILURE_COUNT={len(failure_lines)}")
print(f"{tag}_TARGET_FAILURE_COUNT={len(target_failures)}")
print(f"{tag}_VERDICT={verdict}")
print(f"{tag}_REJECTION_AUDIT={'PASS' if audit_pass else 'FAIL'}")

raise SystemExit(0 if audit_pass else 1)
PY
}

reject_property()
{
    local tag="$1"
    local goto_file="$2"
    local description="$3"

    local show_file="$OUT/${tag}_SHOW_PROPERTIES.log"
    local property_id

    property_id="$(
        find_property_id "$goto_file" "$description" "$show_file"
    )" ||
        return 1

    run_expected_rejection \
        "$tag" \
        "$goto_file" \
        "$description" \
        "$property_id"
}

{
    section "MONT-04D — T4-SPECIFIC THREE-MUTANT / SIX-DETECTION GATE"
    echo "UTC_TIME=$STAMP"
    echo "OUTPUT_DIRECTORY=$OUT"
    echo "BUILD_TIMEOUT=$BUILD_TIMEOUT"
    echo "PROPERTY_TIMEOUT=$PROPERTY_TIMEOUT"
    echo "UNWIND_BOUND=$UNWIND_BOUND"
    echo "MUTATION_EXECUTION_MODE=ISOLATED_SEQUENTIAL"
    echo "THEOREM_DOMAIN_CHANGED=NO"
    echo "THEOREM_WEAKENED=NO"

    section "D0 — BIND ACCEPTED GATE C AND FROZEN ARTEFACTS"

    R4_CAPTURE="$(discover_r4_capture)" ||
        fail "SUCCESSFUL_R4_CAPTURE_DISCOVERY=FAIL" 20

    echo "MONT04C_R4_CAPTURE=$R4_CAPTURE"
    echo "MONT04C_R4_CAPTURE_SHA256=$(hash_file "$R4_CAPTURE")"
    echo "MONT04C_R4_SUCCESSFUL_PACKAGE_BINDING=PASS"

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

    validate_worktree_status "INITIAL" ||
        fail "T4_WORKTREE_INITIAL_STATUS_GATE=FAIL" 25

    cp "$SOURCE" "$OUT/PRISTINE_poly.c"
    cp "$H14_GOTO" "$OUT/PRISTINE_H14.goto"
    cp "$H235_GOTO" "$OUT/PRISTINE_H235.goto"

    echo "SOURCE_BINDING_GATE=PASS"
    echo "FROZEN_ARTEFACT_BINDING=PASS_2_OF_2"

    section "D1 — M1 WRONG R^2 FACTOR: DETECT BY P1 + SUPPORT"

    apply_mutation "M1_WRONG_R2_FACTOR"

    build_mutant "M1_H14" "$H14_DIR" "$H14_GOTO" ||
        fail "M1_BUILD_GATE=FAIL" 26

    M1_PASS=0

    reject_property \
        "M1_P1" \
        "$H14_GOTO" \
        "MONT-T4.P1.de_Montgomery_round_trip" &&
        M1_PASS=$((M1_PASS + 1))

    reject_property \
        "M1_SUPPORT" \
        "$H14_GOTO" \
        "MONT-T4.SUPPORT.forward_representation_congruence" &&
        M1_PASS=$((M1_PASS + 1))

    echo "M1_DETECTION_PASS_COUNT=$M1_PASS"

    [[ "$M1_PASS" -eq 2 ]] ||
        fail "M1_FINAL_RC=1" 27

    restore_source ||
        fail "M1_SOURCE_RESTORE_GATE=FAIL" 28

    cp "$OUT/PRISTINE_H14.goto" "$H14_GOTO"

    [[ "$(hash_file "$H14_GOTO")" == "$EXPECTED_H14_GOTO_HASH" ]] ||
        fail "M1_H14_GOTO_RESTORE_GATE=FAIL" 29

    echo "M1_DETECTED_BY=P1_AND_SUPPORT"
    echo "M1_FINAL_RC=0"

    section "D2 — M2 NEXT-COEFFICIENT CROSS-TALK: DETECT BY P2 + P3 + P5"

    apply_mutation "M2_NEXT_COEFFICIENT_CROSSTALK"

    build_mutant "M2_H235" "$H235_DIR" "$H235_GOTO" ||
        fail "M2_BUILD_GATE=FAIL" 30

    M2_PASS=0

    reject_property \
        "M2_P2" \
        "$H235_GOTO" \
        "MONT-T4.P2.residue_equivalence_preservation_stronger_local_form" &&
        M2_PASS=$((M2_PASS + 1))

    reject_property \
        "M2_P3" \
        "$H235_GOTO" \
        "MONT-T4.P3.residue_equivalence_reflection_stronger_local_form" &&
        M2_PASS=$((M2_PASS + 1))

    reject_property \
        "M2_P5" \
        "$H235_GOTO" \
        "MONT-T4.P5.coefficient_locality_no_cross_talk" &&
        M2_PASS=$((M2_PASS + 1))

    echo "M2_DETECTION_PASS_COUNT=$M2_PASS"

    [[ "$M2_PASS" -eq 3 ]] ||
        fail "M2_FINAL_RC=1" 31

    restore_source ||
        fail "M2_SOURCE_RESTORE_GATE=FAIL" 32

    cp "$OUT/PRISTINE_H235.goto" "$H235_GOTO"

    [[ "$(hash_file "$H235_GOTO")" == "$EXPECTED_H235_GOTO_HASH" ]] ||
        fail "M2_H235_GOTO_RESTORE_GATE=FAIL" 33

    echo "M2_DETECTED_BY=P2_P3_P5"
    echo "M2_FINAL_RC=0"

    section "D3 — M3 ZERO ALL OUTPUTS: DETECT BY P4"

    apply_mutation "M3_ZERO_ALL_OUTPUTS"

    build_mutant "M3_H14" "$H14_DIR" "$H14_GOTO" ||
        fail "M3_BUILD_GATE=FAIL" 34

    reject_property \
        "M3_P4" \
        "$H14_GOTO" \
        "MONT-T4.P4.zero_support_preservation" ||
        fail "M3_FINAL_RC=1" 35

    restore_source ||
        fail "M3_SOURCE_RESTORE_GATE=FAIL" 36

    cp "$OUT/PRISTINE_H14.goto" "$H14_GOTO"

    [[ "$(hash_file "$H14_GOTO")" == "$EXPECTED_H14_GOTO_HASH" ]] ||
        fail "M3_H14_GOTO_RESTORE_GATE=FAIL" 37

    echo "M3_DETECTED_BY=P4"
    echo "M3_FINAL_RC=0"

    section "D4 — FINAL RESTORE AND INTEGRITY"

    restore_source ||
        fail "FINAL_SOURCE_RESTORE_GATE=FAIL" 38

    restore_pristine_gotos ||
        fail "FINAL_GOTO_RESTORE_GATE=FAIL" 39

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
        fail "FINAL_INTEGRITY_GATE=FAIL" 40

    FINAL_AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all
    )"

    [[ -z "$FINAL_AUTH_STATUS" ]] ||
        fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 41

    validate_worktree_status "FINAL" ||
        fail "T4_WORKTREE_FINAL_STATUS_GATE=FAIL" 42

    section "D5 — FINAL MONT-T4 AND MONTGOMERY CAMPAIGN ACCEPTANCE"

    BINDING="$OUT/MONT04D_FINAL_T4_BINDING.env"

    cat >"$BINDING" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H=$EXPECTED_POLY_H
EXPECTED_POLY_C=$EXPECTED_POLY_C
T4_WORKTREE=$WT
MONT04C_R4_CAPTURE=$R4_CAPTURE
MONT04C_R4_CAPTURE_SHA256=$(hash_file "$R4_CAPTURE")
H14_HARNESS_SHA256=$EXPECTED_H14_HARNESS_HASH
H14_MAKEFILE_SHA256=$EXPECTED_H14_MAKEFILE_HASH
H14_GOTO_SHA256=$EXPECTED_H14_GOTO_HASH
H235_HARNESS_SHA256=$EXPECTED_H235_HARNESS_HASH
H235_MAKEFILE_SHA256=$EXPECTED_H235_MAKEFILE_HASH
H235_GOTO_SHA256=$EXPECTED_H235_GOTO_HASH
M1_WRONG_R2_FACTOR=REJECTED_BY_P1_AND_SUPPORT
M2_NEXT_COEFFICIENT_CROSSTALK=REJECTED_BY_P2_P3_P5
M3_ZERO_ALL_OUTPUTS=REJECTED_BY_P4
MONT04D_T4_MUTATION_GATE=PASS_3_OF_3
MONT04D_TARGETED_DETECTION_GATE=PASS_6_OF_6
MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5
MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1
MONT_T4_NONVACUITY_WITNESSES=PASS_6_OF_6
MONT_T4_SAFETY_UNWINDING_GATE=PASS_2_OF_2
MONT_T4_THEOREM_FAMILIES_COVERED_BY_MUTATION_DETECTION=5_OF_5
MONT_T4_SUPPORTING_ASSERTION_MUTATION_COVERED=YES
MONT_T4_THEOREM_DOMAIN_CHANGED=NO
MONT_T4_THEOREM_WEAKENED=NO
MONT_T4_STATUS=ACCEPTED_FOR_PINNED_COMMIT
MONTGOMERY_CAMPAIGN_STATUS=COMPLETE_T1_T2_T3_T4
EOF

    echo "MONT04D_BINDING_FILE=$BINDING"
    echo "MONT04D_BINDING_SHA256=$(hash_file "$BINDING")"
    echo "FINAL_SOURCE_INTEGRITY=PASS"
    echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
    echo "FINAL_FROZEN_ARTEFACT_INTEGRITY=PASS_2_OF_2"
    echo "MONT04D_T4_MUTATION_GATE=PASS_3_OF_3"
    echo "MONT04D_TARGETED_DETECTION_GATE=PASS_6_OF_6"
    echo "MONT_T4_MUTATION_SENSITIVITY=PASS_3_OF_3"
    echo "MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5"
    echo "MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1"
    echo "MONT_T4_NONVACUITY_WITNESSES=PASS_6_OF_6"
    echo "MONT_T4_SAFETY_UNWINDING_GATE=PASS_2_OF_2"
    echo "MONT_T4_THEOREM_FAMILIES_COVERED_BY_MUTATION_DETECTION=5_OF_5"
    echo "MONT_T4_SUPPORTING_ASSERTION_MUTATION_COVERED=YES"
    echo "MONT_T4_THEOREM_DOMAIN_CHANGED=NO"
    echo "MONT_T4_THEOREM_WEAKENED=NO"
    echo "MONT_T4_STATUS=ACCEPTED_FOR_PINNED_COMMIT"
    echo "MONTGOMERY_CAMPAIGN_STATUS=COMPLETE_T1_T2_T3_T4"
    echo "NEXT_GATE=MONT-FINAL-EVIDENCE-PACKAGING"
    echo "MONT04D_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
