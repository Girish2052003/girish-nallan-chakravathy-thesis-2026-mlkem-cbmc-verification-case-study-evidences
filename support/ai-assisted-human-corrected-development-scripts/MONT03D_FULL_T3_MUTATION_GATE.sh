#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

EXPECTED_P1_HARNESS="39a09f51f8db8687f6fa7a6288dd53f86c7ddeb7f1294f999298eebd835753a6"
EXPECTED_P1_MAKEFILE="ab4e8c7a2e17706673eda399a31f899ee6bbf09bacb981102299833c728fdceb"
EXPECTED_P1_GOTO="808e1089d26e7cf8939f2c7db2016ee30b22ca52188faf0ab77bf326cca5a5db"

EXPECTED_P23_HARNESS="5294f922b0295a00285b33c1ca482983c70cf8b30e30aaaf1ef2b4193d9ca9d1"
EXPECTED_P23_MAKEFILE="306e7db336168c35e696e5965d11c942669a490fbc27ca38fdbd8b9810734467"
EXPECTED_P23_GOTO="e1355402a0b350de1546c31fb62139ba679d7baf2363d49c140f989c52b944e6"

EXPECTED_P4_HARNESS="b42a1a606cb7023d23e549a479dc6765ba0fbe6b515f19fcdb2846c4761ecce8"
EXPECTED_P4_MAKEFILE="dd7ccad9fb60c92d745ccc5f043e0061ee2e3951a199e9f6400504afad7def10"
EXPECTED_P4_GOTO="570863436b766af32879ba79dc9432457663a1c01bf41dfbd66e7b3d66a1f82a"

EXPECTED_P5_HARNESS="8cd5bd1808eabb07f68021617f2c6193b7e366c066306ed4ecaf90bd8727d213"
EXPECTED_P5_MAKEFILE="432c5d3ebab4d39d0380baa45580502f84434b76d4f803f9d96704d2858f5c4b"
EXPECTED_P5_GOTO="cef5836ae92cbec3ad9116a0b20fdd7031319933bc88fbe870bbd00b960fce9a"

EXPECTED_P6_HARNESS="41a026e8203c7b043456da03ce195dc1eb55a1d8ab1583b40cdae87492b420ca"
EXPECTED_P6_MAKEFILE="a5eaed22970ab46cc9882380a3cd046ea2ef638131c10fb89c907aba6288760c"
EXPECTED_P6_GOTO="f7cc950236e7f475efa04915c7981c6d6df49af60f2f8cf253535852e488908d"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WT="$ROOT/MONT_T3_WORKTREE_af4c5abd"

P1_DIR="$WT/proofs/cbmc/mont_t3_p1_refinement"
P23_DIR="$WT/proofs/cbmc/mont_t3_p2_p3_relational"
P4_DIR="$WT/proofs/cbmc/mont_t3_p4_montgomery_one"
P5_DIR="$WT/proofs/cbmc/mont_t3_p5_distributivity"
P6_DIR="$WT/proofs/cbmc/mont_t3_p6_associativity"

P1_STEM="mont_t3_p1_refinement_harness"
P23_STEM="mont_t3_p2_p3_relational_harness"
P4_STEM="mont_t3_p4_montgomery_one_harness"
P5_STEM="mont_t3_p5_distributivity_harness"
P6_STEM="mont_t3_p6_associativity_harness"

SOURCE="$WT/mlkem/src/poly.c"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT03D_T3_MUTATIONS_$STAMP"
CAPTURE="$OUT/MONT03D_TERMINAL_CAPTURE_$STAMP.txt"

BUILD_TIMEOUT=420
PROPERTY_TIMEOUT=300

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

cleanup()
{
    restore_source >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

discover_gate_c()
{
    local directory capture hash_file_path actual recorded

    while IFS= read -r directory
    do
        capture="$(find "$directory" -maxdepth 1 -type f \
            -name 'MONT03C_TERMINAL_CAPTURE_*.txt' | head -n 1)"

        [[ -n "$capture" && -f "$capture" ]] || continue

        if grep -Fxq "MONT03C_FUNCTIONAL_GATE=PASS_5_OF_5" "$capture" &&
           grep -Fxq "MONT03C_NONVACUITY_GATE=PASS_7_OF_7" "$capture" &&
           grep -Fxq "MONT_T3_THEOREM_FAMILIES_VERIFIED=6_OF_6" "$capture" &&
           grep -Fxq "MONT_T3_DIRECT_ASSERTIONS_VERIFIED=9_OF_9" "$capture" &&
           grep -Fxq "MONT_T3_THEOREM_WEAKENED=NO" "$capture" &&
           grep -Fxq "MONT_T3_STATUS=PROVISIONAL_ACCEPT_PENDING_MUTATION_PACKAGE" "$capture" &&
           grep -Fxq "MONT03C_CAPTURE_END=YES" "$capture"
        then
            actual="$(hash_file "$capture")"
            hash_file_path="${capture}.sha256"

            if [[ -f "$hash_file_path" ]]; then
                recorded="$(awk 'NR == 1 {print $1}' "$hash_file_path")"
                [[ "$recorded" == "$actual" ]] || continue
            fi

            printf '%s\n' "$capture"
            return 0
        fi
    done < <(
        find "$ROOT" -maxdepth 1 -type d \
            -name 'MONT03C_FUNCTIONAL_NONVACUITY_*' \
            -printf '%T@ %p\n' |
        sort -nr |
        cut -d' ' -f2-
    )

    return 1
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

start_marker = "static MLK_INLINE int16_t mlk_fqmul"
start = text.find(start_marker)
if start < 0:
    raise SystemExit("mlk_fqmul start marker not found")

end = text.find("\n}\n", start)
if end < 0:
    raise SystemExit("mlk_fqmul end marker not found")
end += 3

before = text[:start]
block = text[start:end]
after = text[end:]

original_call = (
    "  res = mlk_montgomery_reduce((int32_t)a * (int32_t)b);\n"
)
original_return = "  return res;\n"

if block.count(original_call) != 1:
    raise SystemExit(
        f"original multiplication line count={block.count(original_call)}"
    )
if block.count(original_return) != 1:
    raise SystemExit(
        f"original return line count={block.count(original_return)}"
    )

if mutation == "M1_MUL_TO_ADD":
    replacement = (
        "  res = mlk_montgomery_reduce((int32_t)a + (int32_t)b);\n"
    )
    block = block.replace(original_call, replacement, 1)

elif mutation == "M2_NONLINEAR_ASYMMETRIC_BIAS":
    replacement = (
        "  res = mlk_montgomery_reduce(\n"
        "      ((int32_t)a * (int32_t)b) + ((int32_t)a * (int32_t)a));\n"
    )
    block = block.replace(original_call, replacement, 1)

elif mutation == "M3_ZERO_CASE_CORRUPTION":
    replacement = (
        "  return (a == 0 || b == 0) ? (int16_t)1 : res;\n"
    )
    block = block.replace(original_return, replacement, 1)

elif mutation == "M4_NEGATED_OUTPUT":
    replacement = "  return (int16_t)(-res);\n"
    block = block.replace(original_return, replacement, 1)

else:
    raise SystemExit(f"unknown mutation: {mutation}")

path.write_text(before + block + after)
print(f"MUTATION_APPLIED={mutation}")
PY

    [[ "$(hash_file "$SOURCE")" != "$EXPECTED_POLY_C" ]] ||
        fail "MUTATED_SOURCE_HASH_UNCHANGED_${mutation}=FAIL" 31

    echo "${mutation}_SOURCE_SHA256=$(hash_file "$SOURCE")"
}

find_property_id()
{
    local goto_file="$1"
    local description="$2"
    local show_log="$3"

    cbmc --show-properties "$goto_file" >"$show_log" 2>&1
    local show_rc=$?

    [[ "$show_rc" -eq 0 ]] || return 1

    python3 - "$show_log" "$description" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(errors="replace")
description = sys.argv[2]

matches = []
for line in text.splitlines():
    if description in line:
        match = re.search(r"\[([^\]]+)\]", line)
        if match:
            matches.append(match.group(1))

if len(matches) != 1:
    raise SystemExit(
        f"property description match count={len(matches)} for {description}"
    )

print(matches[0])
PY
}

build_and_reject()
{
    local check_tag="$1"
    local proof_dir="$2"
    local stem="$3"
    local description="$4"

    local goto_file="$proof_dir/gotos/$stem.goto"
    local build_log="$OUT/${check_tag}_BUILD.log"
    local show_log="$OUT/${check_tag}_SHOW_PROPERTIES.log"
    local cbmc_log="$OUT/${check_tag}_CBMC.log"

    make -C "$proof_dir" MLKEM_K=3 clean \
        >"$OUT/${check_tag}_CLEAN.log" 2>&1 || true

    timeout "$BUILD_TIMEOUT" make -C "$proof_dir" MLKEM_K=3 goto \
        >"$build_log" 2>&1
    local build_rc=$?

    echo "${check_tag}_BUILD_RC=$build_rc"

    if [[ "$build_rc" -ne 0 || ! -f "$goto_file" ]]; then
        echo "${check_tag}_GOTO_PRESENT=NO"
        tail -n 100 "$build_log" || true
        return 1
    fi

    echo "${check_tag}_GOTO_PRESENT=YES"
    echo "${check_tag}_MUTANT_GOTO_SHA256=$(hash_file "$goto_file")"

    local property_id
    property_id="$(find_property_id "$goto_file" "$description" "$show_log")" ||
        return 1

    echo "${check_tag}_PROPERTY_ID=$property_id"
    echo "${check_tag}_PROPERTY_DESCRIPTION=$description"

    timeout "$PROPERTY_TIMEOUT" cbmc \
        --flush \
        --object-bits 8 \
        --slice-formula \
        --conversion-check \
        --float-overflow-check \
        --nan-check \
        --pointer-overflow-check \
        --unsigned-overflow-check \
        --unwinding-assertions \
        --trace \
        --property "$property_id" \
        "$goto_file" >"$cbmc_log" 2>&1
    local cbmc_rc=$?

    grep -E \
        'MONT-T3\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR' \
        "$cbmc_log" || true

    python3 - "$check_tag" "$cbmc_rc" "$cbmc_log" "$description" <<'PY'
from pathlib import Path
import re
import sys

tag = sys.argv[1]
rc = int(sys.argv[2])
text = Path(sys.argv[3]).read_text(errors="replace")
description = sys.argv[4]

failure_lines = [
    line for line in text.splitlines()
    if re.search(r": FAILURE\s*$", line)
]

target_failures = [
    line for line in failure_lines
    if f"{description}: FAILURE" in line
]

error_present = (
    "VERIFICATION ERROR" in text or
    "\nERROR:" in text or
    "Caught exception" in text
)

success = (
    rc == 10 and
    "VERIFICATION FAILED" in text and
    "VERIFICATION SUCCESSFUL" not in text and
    not error_present and
    len(failure_lines) == 1 and
    len(target_failures) == 1
)

print(f"{tag}_CBMC_RC={rc}")
print(f"{tag}_FAILURE_COUNT={len(failure_lines)}")
print(f"{tag}_TARGET_FAILURE_COUNT={len(target_failures)}")
print(f"{tag}_REJECTION_AUDIT={'PASS' if success else 'FAIL'}")

raise SystemExit(0 if success else 1)
PY
}

restore_pristine_gotos()
{
    local tag dir stem expected

    while IFS='|' read -r tag dir stem expected
    do
        rm -rf "$dir/gotos"
        mkdir -p "$dir/gotos"
        cp "$OUT/PRISTINE_${tag}.goto" "$dir/gotos/${stem}.goto"

        [[ "$(hash_file "$dir/gotos/${stem}.goto")" == "$expected" ]] ||
            return 1
    done <<EOF
P1|$P1_DIR|$P1_STEM|$EXPECTED_P1_GOTO
P23|$P23_DIR|$P23_STEM|$EXPECTED_P23_GOTO
P4|$P4_DIR|$P4_STEM|$EXPECTED_P4_GOTO
P5|$P5_DIR|$P5_STEM|$EXPECTED_P5_GOTO
P6|$P6_DIR|$P6_STEM|$EXPECTED_P6_GOTO
EOF

    return 0
}

{
    section "MONT-03D — T3-SPECIFIC FOUR-MUTANT / SIX-DETECTION GATE"
    echo "UTC_TIME=$STAMP"
    echo "WORKTREE=$WT"
    echo "OUTPUT_DIRECTORY=$OUT"
    echo "BUILD_TIMEOUT=$BUILD_TIMEOUT"
    echo "PROPERTY_TIMEOUT=$PROPERTY_TIMEOUT"

    section "D0 — BIND SOURCE, FROZEN ARTEFACTS, AND SUCCESSFUL GATE C"

    GATE_C_CAPTURE="$(discover_gate_c)" ||
        fail "MONT03C_SUCCESSFUL_CAPTURE_DISCOVERY=FAIL" 20

    echo "MONT03C_CAPTURE=$GATE_C_CAPTURE"
    echo "MONT03C_CAPTURE_SHA256=$(hash_file "$GATE_C_CAPTURE")"
    echo "MONT03C_SUCCESSFUL_CAPTURE_BINDING=PASS"

    AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null || true)"
    WT_HEAD="$(git -C "$WT" rev-parse HEAD 2>/dev/null || true)"
    AUTH_STATUS="$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

    [[ "$AUTH_HEAD" == "$EXPECTED_COMMIT" &&
       "$WT_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$AUTH_STATUS" ]] ||
        fail "COMMIT_OR_AUTHORITATIVE_CLEAN_GATE=FAIL" 21

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$SOURCE")" == "$EXPECTED_POLY_C" ]] ||
        fail "SOURCE_BINDING_GATE=FAIL" 22

    declare -a TAGS=("P1" "P23" "P4" "P5" "P6")
    declare -a DIRS=("$P1_DIR" "$P23_DIR" "$P4_DIR" "$P5_DIR" "$P6_DIR")
    declare -a STEMS=("$P1_STEM" "$P23_STEM" "$P4_STEM" "$P5_STEM" "$P6_STEM")
    declare -a EXPECTED_H=(
        "$EXPECTED_P1_HARNESS"
        "$EXPECTED_P23_HARNESS"
        "$EXPECTED_P4_HARNESS"
        "$EXPECTED_P5_HARNESS"
        "$EXPECTED_P6_HARNESS"
    )
    declare -a EXPECTED_M=(
        "$EXPECTED_P1_MAKEFILE"
        "$EXPECTED_P23_MAKEFILE"
        "$EXPECTED_P4_MAKEFILE"
        "$EXPECTED_P5_MAKEFILE"
        "$EXPECTED_P6_MAKEFILE"
    )
    declare -a EXPECTED_G=(
        "$EXPECTED_P1_GOTO"
        "$EXPECTED_P23_GOTO"
        "$EXPECTED_P4_GOTO"
        "$EXPECTED_P5_GOTO"
        "$EXPECTED_P6_GOTO"
    )

    for i in "${!TAGS[@]}"
    do
        harness="${DIRS[$i]}/${STEMS[$i]}.c"
        makefile="${DIRS[$i]}/Makefile"
        goto_file="${DIRS[$i]}/gotos/${STEMS[$i]}.goto"

        [[ -f "$harness" && -f "$makefile" && -f "$goto_file" ]] ||
            fail "T3_${TAGS[$i]}_ARTEFACT_PRESENT_GATE=FAIL" 23

        [[ "$(hash_file "$harness")" == "${EXPECTED_H[$i]}" &&
           "$(hash_file "$makefile")" == "${EXPECTED_M[$i]}" &&
           "$(hash_file "$goto_file")" == "${EXPECTED_G[$i]}" ]] ||
            fail "T3_${TAGS[$i]}_ARTEFACT_HASH_GATE=FAIL" 24

        cp "$goto_file" "$OUT/PRISTINE_${TAGS[$i]}.goto"
        echo "T3_${TAGS[$i]}_FROZEN_ARTEFACT_BINDING=PASS"
    done

    cp "$SOURCE" "$OUT/PRISTINE_poly.c"
    echo "COMMIT_AND_SOURCE_BINDING=PASS"
    echo "T3_FROZEN_ARTEFACT_BINDING=PASS_5_OF_5"

    section "D1 — MUTANT M1: MULTIPLICATION REPLACED BY ADDITION"

    apply_mutation "M1_MUL_TO_ADD"

    build_and_reject \
        "M1_P1" \
        "$P1_DIR" \
        "$P1_STEM" \
        "MONT-T3.P1.2.independent_exact_multiplication_refinement" ||
        fail "M1_FINAL_RC=1" 25

    echo "M1_FINAL_RC=0"
    echo "M1_DETECTED_BY=P1_INDEPENDENT_SEMANTIC_REFINEMENT"

    section "D2 — MUTANT M2: NONLINEAR ASYMMETRIC FIRST-OPERAND BIAS"

    apply_mutation "M2_NONLINEAR_ASYMMETRIC_BIAS"

    M2_PASS=0

    build_and_reject \
        "M2_P2" \
        "$P23_DIR" \
        "$P23_STEM" \
        "MONT-T3.P2.exact_commutativity" &&
        M2_PASS=$((M2_PASS + 1))

    build_and_reject \
        "M2_P5" \
        "$P5_DIR" \
        "$P5_STEM" \
        "MONT-T3.P5.distributivity_after_normalization" &&
        M2_PASS=$((M2_PASS + 1))

    build_and_reject \
        "M2_P6" \
        "$P6_DIR" \
        "$P6_STEM" \
        "MONT-T3.P6.associativity_after_normalization" &&
        M2_PASS=$((M2_PASS + 1))

    echo "M2_DETECTION_PASS_COUNT=$M2_PASS"

    [[ "$M2_PASS" -eq 3 ]] ||
        fail "M2_FINAL_RC=1" 26

    echo "M2_FINAL_RC=0"
    echo "M2_DETECTED_BY=P2_P5_P6"

    section "D3 — MUTANT M3: ZERO CASE RETURNS ONE"

    apply_mutation "M3_ZERO_CASE_CORRUPTION"

    build_and_reject \
        "M3_P3" \
        "$P23_DIR" \
        "$P23_STEM" \
        "MONT-T3.P3.1.left_zero_annihilation_full_first_operand_domain" ||
        fail "M3_FINAL_RC=1" 27

    echo "M3_FINAL_RC=0"
    echo "M3_DETECTED_BY=P3_ZERO_ANNIHILATION"

    section "D4 — MUTANT M4: NEGATED FQMUL OUTPUT"

    apply_mutation "M4_NEGATED_OUTPUT"

    build_and_reject \
        "M4_P4" \
        "$P4_DIR" \
        "$P4_STEM" \
        "MONT-T3.P4.Montgomery_one_identity_after_normalization" ||
        fail "M4_FINAL_RC=1" 28

    echo "M4_FINAL_RC=0"
    echo "M4_DETECTED_BY=P4_MONTGOMERY_ONE_IDENTITY"

    section "D5 — RESTORE PRISTINE SOURCE AND ALL FROZEN GOTO BINARIES"

    restore_source ||
        fail "FINAL_SOURCE_RESTORE_GATE=FAIL" 29

    restore_pristine_gotos ||
        fail "FINAL_GOTO_RESTORE_GATE=FAIL" 30

    [[ "$(hash_file "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
       "$(hash_file "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
       "$(hash_file "$SOURCE")" == "$EXPECTED_POLY_C" ]] ||
        fail "FINAL_SOURCE_INTEGRITY=FAIL" 31

    FINAL_AUTH_STATUS="$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all)"
    [[ -z "$FINAL_AUTH_STATUS" ]] ||
        fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 32

    for i in "${!TAGS[@]}"
    do
        goto_file="${DIRS[$i]}/gotos/${STEMS[$i]}.goto"

        [[ "$(hash_file "$goto_file")" == "${EXPECTED_G[$i]}" ]] ||
            fail "FINAL_T3_${TAGS[$i]}_GOTO_INTEGRITY=FAIL" 33
    done

    section "D6 — FINAL FULL-POWER T3 ACCEPTANCE"

    BINDING="$OUT/MONT03D_FINAL_T3_BINDING.env"

    cat >"$BINDING" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H=$EXPECTED_POLY_H
EXPECTED_POLY_C=$EXPECTED_POLY_C
MONT03C_CAPTURE=$GATE_C_CAPTURE
MONT03C_CAPTURE_SHA256=$(hash_file "$GATE_C_CAPTURE")
M1_MUL_TO_ADD=REJECTED_BY_P1
M2_NONLINEAR_ASYMMETRIC_BIAS=REJECTED_BY_P2_P5_P6
M3_ZERO_CASE_CORRUPTION=REJECTED_BY_P3
M4_NEGATED_OUTPUT=REJECTED_BY_P4
MONT03D_MUTATION_GATE=PASS_4_OF_4
MONT03D_TARGETED_DETECTION_GATE=PASS_6_OF_6
MONT_T3_THEOREM_WEAKENED=NO
MONT_T3_STATUS=ACCEPTED_FOR_PINNED_COMMIT
EOF

    echo "MONT03D_BINDING_FILE=$BINDING"
    echo "MONT03D_BINDING_SHA256=$(hash_file "$BINDING")"
    echo "FINAL_SOURCE_INTEGRITY=PASS"
    echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
    echo "FINAL_FROZEN_GOTO_INTEGRITY=PASS_5_OF_5"
    echo "MONT03D_T3_MUTATION_GATE=PASS_4_OF_4"
    echo "MONT03D_TARGETED_DETECTION_GATE=PASS_6_OF_6"
    echo "MONT_T3_FUNCTIONAL_GATE=PASS_5_OF_5"
    echo "MONT_T3_NONVACUITY_GATE=PASS_7_OF_7"
    echo "MONT_T3_MUTATION_SENSITIVITY=PASS_4_OF_4"
    echo "MONT_T3_THEOREM_FAMILIES_COVERED_BY_MUTATION_DETECTION=6_OF_6"
    echo "MONT_T3_SOURCE_BINDING=PASS"
    echo "MONT_T3_THEOREM_WEAKENED=NO"
    echo "MONT_T3_STATUS=ACCEPTED_FOR_PINNED_COMMIT"
    echo "NEXT_CAMPAIGN=MONT-T4"
    echo "MONT03D_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
