#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

EXPECTED_MONT04B_CAPTURE_HASH="05c56c666de47585f0c3b0123661989a7f8bb8c266cb9c3fbfcaf7010a790509"
EXPECTED_MONT04B_BINDING_HASH="8f1304a854ddb3c9fefe6f101364b455bbb157a647991cd36b34f4bd7b24604e"

EXPECTED_H14_HARNESS_HASH="2a4489df76b97cc03126f272f854bcfd3aa5b74f0268fffce77658d48a42194b"
EXPECTED_H14_MAKEFILE_HASH="5177e1bdfd24c068ef28326e9ab7e2eafc532b13f2c039d05ffa8903afb97768"
EXPECTED_H14_GOTO_HASH="9afe1a455c89e28e595e0bc51f997f086e466e69d178066f15d8fb26943a2857"

EXPECTED_H235_HARNESS_HASH="662a52e12e01ceeae630b2ea31e678465bba65cf34392fcc8e900198ee933d16"
EXPECTED_H235_MAKEFILE_HASH="e8207c332522362c04999d36a2365096cd83bfbfe7b949b8570722cfa4758855"
EXPECTED_H235_GOTO_HASH="3a6194b2787992287ca77403d0f5f28d6f907837cd7a83cb171cff6cff267564"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WT="$ROOT/MONT_T4_WORKTREE_af4c5abd_20260726T225651Z"

MONT04B_CAPTURE="$ROOT/MONT04B_T4_HARNESS_FREEZE_20260726T225651Z/MONT04B_TERMINAL_CAPTURE_20260726T225651Z.txt"
MONT04B_BINDING="$ROOT/MONT04B_T4_HARNESS_FREEZE_20260726T225651Z/MONT04B_T4_FREEZE_BINDING.env"

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

NATIVE_MAKEFILE="$WT/proofs/cbmc/poly_tomont_c/Makefile"

CONTROL14_NAME="mont_t4_control_p1_p4"
CONTROL14_DIR="$WT/proofs/cbmc/$CONTROL14_NAME"
CONTROL14_STEM="${CONTROL14_NAME}_harness"
CONTROL14_HARNESS="$CONTROL14_DIR/$CONTROL14_STEM.c"
CONTROL14_MAKEFILE="$CONTROL14_DIR/Makefile"
CONTROL14_GOTO="$CONTROL14_DIR/gotos/$CONTROL14_STEM.goto"

CONTROL235_NAME="mont_t4_control_p2_p3_p5"
CONTROL235_DIR="$WT/proofs/cbmc/$CONTROL235_NAME"
CONTROL235_STEM="${CONTROL235_NAME}_harness"
CONTROL235_HARNESS="$CONTROL235_DIR/$CONTROL235_STEM.c"
CONTROL235_MAKEFILE="$CONTROL235_DIR/Makefile"
CONTROL235_GOTO="$CONTROL235_DIR/gotos/$CONTROL235_STEM.goto"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT04C_R3_T4_NONVACUITY_$STAMP"
CAPTURE="$OUT/MONT04C_R3_TERMINAL_CAPTURE_$STAMP.txt"

BUILD_TIMEOUT=600
PROPERTY_TIMEOUT=1200
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

discover_capture()
{
    local directory_pattern="$1"
    local capture_pattern="$2"
    shift 2

    local directory
    local capture
    local sidecar
    local actual
    local recorded
    local marker

    while IFS= read -r directory
    do
        capture="$(
            find "$directory" -maxdepth 1 -type f \
                -name "$capture_pattern" |
            head -n 1
        )"

        [[ -n "$capture" && -f "$capture" ]] || continue

        for marker in "$@"
        do
            if ! grep -Fxq "$marker" "$capture"; then
                capture=""
                break
            fi
        done

        [[ -n "$capture" ]] || continue

        sidecar="${capture}.sha256"
        [[ -f "$sidecar" ]] || continue

        actual="$(hash_file "$capture")"
        recorded="$(awk 'NR == 1 {print $1}' "$sidecar")"

        [[ "$actual" == "$recorded" ]] || continue

        printf '%s\n' "$capture"
        return 0

    done < <(
        find "$ROOT" -maxdepth 1 -type d \
            -name "$directory_pattern" \
            -printf '%T@ %p\n' |
        sort -nr |
        cut -d' ' -f2-
    )

    return 1
}

archive_and_remove_control_dir()
{
    local directory="$1"
    local relative="${directory#$WT/}"
    local label="$2"
    local tracked
    local archive

    [[ -e "$directory" ]] || return 0

    tracked="$(git -C "$WT" ls-files -- "$relative/" 2>/dev/null || true)"

    if [[ -n "$tracked" ]]; then
        echo "${label}_TRACKED_FILE_GUARD_BEGIN"
        printf '%s\n' "$tracked"
        echo "${label}_TRACKED_FILE_GUARD_END"
        return 1
    fi

    archive="$OUT/PREEXISTING_${label}_$STAMP.tar.gz"

    tar -C "$WT" -czf "$archive" "$relative" || return 1

    echo "${label}_PREEXISTING_ARCHIVE=$archive"
    echo "${label}_PREEXISTING_ARCHIVE_SHA256=$(hash_file "$archive")"

    rm -rf "$directory"
    echo "${label}_PREEXISTING_DIRECTORY_ARCHIVED_AND_REMOVED=YES"
}

prepare_semantic_makefile()
{
    local destination="$1"
    local harness_stem="$2"
    local proof_uid="$3"

    cp "$NATIVE_MAKEFILE" "$destination"

    python3 - "$destination" "$harness_stem" "$proof_uid" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
stem = sys.argv[2]
uid = sys.argv[3]
text = path.read_text()

replacements = [
    (
        r'(?m)^HARNESS_FILE\s*=.*$',
        f'HARNESS_FILE = {stem}',
        'HARNESS_FILE',
    ),
    (
        r'(?m)^PROOF_UID\s*=.*$',
        f'PROOF_UID = {uid}',
        'PROOF_UID',
    ),
    (
        r'(?m)^CHECK_FUNCTION_CONTRACTS\s*=.*$',
        'CHECK_FUNCTION_CONTRACTS=',
        'CHECK_FUNCTION_CONTRACTS',
    ),
    (
        r'(?m)^USE_FUNCTION_CONTRACTS\s*=.*$',
        'USE_FUNCTION_CONTRACTS=',
        'USE_FUNCTION_CONTRACTS',
    ),
    (
        r'(?m)^APPLY_LOOP_CONTRACTS\s*=.*$',
        'APPLY_LOOP_CONTRACTS=',
        'APPLY_LOOP_CONTRACTS',
    ),
    (
        r'(?m)^USE_DYNAMIC_FRAMES\s*=.*$',
        'USE_DYNAMIC_FRAMES=',
        'USE_DYNAMIC_FRAMES',
    ),
    (
        r'(?m)^CBMCFLAGS\s*=.*$',
        'CBMCFLAGS=',
        'CBMCFLAGS',
    ),
]

for pattern, replacement, label in replacements:
    text, count = re.subn(pattern, replacement, text)

    if count != 1:
        raise SystemExit(
            f"{label} replacement count was {count}, expected 1"
        )

path.write_text(text)
PY
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

run_expected_failure()
{
    local tag="$1"
    local goto_file="$2"
    local description="$3"
    local property_id="$4"
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
        "$goto_file" >"$log" 2>&1

    local rc=$?

    echo "${tag}_PROPERTY_ID=$property_id"
    echo "${tag}_PROPERTY_DESCRIPTION=$description"

    echo "${tag}_KEY_RESULTS_BEGIN"
    grep -E \
        'MONT-T4.CONTROL\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR|Out of memory' \
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
    verdict = "EXPECTEDLY_REJECTED_REACHABLE"
    audit_pass = True
elif (
    rc == 0
    and "VERIFICATION SUCCESSFUL" in text
):
    verdict = "UNREACHABLE_OR_VACUOUS"
    audit_pass = False
else:
    verdict = "TOOL_OR_AUDIT_FAILURE"
    audit_pass = False

print(f"{tag}_DIRECT_RC={rc}")
print(f"{tag}_FAILURE_COUNT={len(failure_lines)}")
print(f"{tag}_TARGET_FAILURE_COUNT={len(target_failures)}")
print(f"{tag}_VERDICT={verdict}")
print(f"{tag}_AUDIT={'PASS' if audit_pass else 'FAIL'}")

raise SystemExit(0 if audit_pass else 1)
PY
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

{
    section "MONT-04C-R3 — SIX-WITNESS PROPERTY-SHARDED NON-VACUITY"
    echo "UTC_TIME=$STAMP"
    echo "OUTPUT_DIRECTORY=$OUT"
    echo "BUILD_TIMEOUT=$BUILD_TIMEOUT"
    echo "PROPERTY_TIMEOUT=$PROPERTY_TIMEOUT"
    echo "UNWIND_BOUND=$UNWIND_BOUND"
    echo "CONTROL_EXECUTION_MODE=SEQUENTIAL_PROPERTY_SHARDS"
    echo "THEOREM_DOMAIN_CHANGED=NO"
    echo "THEOREM_WEAKENED=NO"

    section "R0 — BIND MONT-04B, R1, AND R2 SUCCESS PACKAGES"

    [[ -f "$MONT04B_CAPTURE" &&
       -f "${MONT04B_CAPTURE}.sha256" &&
       -f "$MONT04B_BINDING" ]] ||
        fail "MONT04B_PACKAGE_PRESENT_GATE=FAIL" 20

    ACTUAL_MONT04B_HASH="$(hash_file "$MONT04B_CAPTURE")"
    SIDECAR_MONT04B_HASH="$(
        awk 'NR == 1 {print $1}' "${MONT04B_CAPTURE}.sha256"
    )"

    [[ "$ACTUAL_MONT04B_HASH" == "$EXPECTED_MONT04B_CAPTURE_HASH" &&
       "$SIDECAR_MONT04B_HASH" == "$ACTUAL_MONT04B_HASH" &&
       "$(hash_file "$MONT04B_BINDING")" == "$EXPECTED_MONT04B_BINDING_HASH" ]] ||
        fail "MONT04B_PACKAGE_BINDING_GATE=FAIL" 21

    R1_CAPTURE="$(
        discover_capture \
            'MONT04C_R1_H14_SHARDS_*' \
            'MONT04C_R1_TERMINAL_CAPTURE_*.txt' \
            'MONT04C_R1_H14_PROPERTY_SHARD_GATE=PASS_3_OF_3' \
            'MONT_T4_P1_VERIFIED=YES' \
            'MONT_T4_P4_VERIFIED=YES' \
            'MONT_T4_SUPPORTING_FORWARD_LEMMA_VERIFIED=YES' \
            'MONT_T4_THEOREM_DOMAIN_CHANGED=NO' \
            'MONT_T4_THEOREM_WEAKENED=NO' \
            'MONT04C_R1_CAPTURE_END=YES'
    )" ||
        fail "SUCCESSFUL_R1_CAPTURE_DISCOVERY=FAIL" 22

    R2_CAPTURE="$(
        discover_capture \
            'MONT04C_R2_H235_SHARDS_*' \
            'MONT04C_R2_TERMINAL_CAPTURE_*.txt' \
            'MONT04C_R2_H235_PROPERTY_SHARD_GATE=PASS_3_OF_3' \
            'MONT_T4_P2_VERIFIED=YES' \
            'MONT_T4_P3_VERIFIED=YES' \
            'MONT_T4_P5_VERIFIED=YES' \
            'MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5' \
            'MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1' \
            'MONT_T4_THEOREM_DOMAIN_CHANGED=NO' \
            'MONT_T4_THEOREM_WEAKENED=NO' \
            'MONT04C_R2_CAPTURE_END=YES'
    )" ||
        fail "SUCCESSFUL_R2_CAPTURE_DISCOVERY=FAIL" 23

    echo "MONT04B_PACKAGE_BINDING=PASS"
    echo "MONT04C_R1_CAPTURE=$R1_CAPTURE"
    echo "MONT04C_R1_CAPTURE_SHA256=$(hash_file "$R1_CAPTURE")"
    echo "MONT04C_R2_CAPTURE=$R2_CAPTURE"
    echo "MONT04C_R2_CAPTURE_SHA256=$(hash_file "$R2_CAPTURE")"
    echo "R1_R2_SUCCESSFUL_PACKAGE_BINDING=PASS"

    section "R1 — REBIND SOURCE AND BOTH FROZEN FUNCTIONAL ARTEFACTS"

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

    [[ "$(hash_file "$H14_HARNESS")" == "$EXPECTED_H14_HARNESS_HASH" &&
       "$(hash_file "$H14_MAKEFILE")" == "$EXPECTED_H14_MAKEFILE_HASH" &&
       "$(hash_file "$H14_GOTO")" == "$EXPECTED_H14_GOTO_HASH" &&
       "$(hash_file "$H235_HARNESS")" == "$EXPECTED_H235_HARNESS_HASH" &&
       "$(hash_file "$H235_MAKEFILE")" == "$EXPECTED_H235_MAKEFILE_HASH" &&
       "$(hash_file "$H235_GOTO")" == "$EXPECTED_H235_GOTO_HASH" ]] ||
        fail "FROZEN_FUNCTIONAL_ARTEFACT_BINDING_GATE=FAIL" 26

    validate_worktree_status "INITIAL" ||
        fail "T4_WORKTREE_INITIAL_STATUS_GATE=FAIL" 27

    echo "SOURCE_BINDING_GATE=PASS"
    echo "FROZEN_FUNCTIONAL_ARTEFACT_BINDING=PASS_2_OF_2"

    section "R2 — SAFELY CREATE H14 THREE-WITNESS CONTROL"

    archive_and_remove_control_dir "$CONTROL14_DIR" "CONTROL14" ||
        fail "CONTROL14_PREEXISTING_DIRECTORY_GATE=FAIL" 28

    mkdir -p "$CONTROL14_DIR"

    cat >"$CONTROL14_HARNESS" <<'C'
#include <stdint.h>
#include <limits.h>

#include "poly.h"

extern mlk_poly nondet_mlk_poly(void);
extern unsigned nondet_unsigned(void);

void mlk_poly_tomont_c(mlk_poly *r);

void harness(void)
{
  mlk_poly state;
  mlk_poly before;
  unsigned k;

  state = nondet_mlk_poly();
  before = state;
  k = nondet_unsigned();

  __CPROVER_assume(k < MLKEM_N);

  mlk_poly_tomont_c(&state);

  if (before.coeffs[k] == 0)
  {
    __CPROVER_assert(
        (int32_t)state.coeffs[k] ==
            (int32_t)state.coeffs[k] + 1,
        "MONT-T4.CONTROL.C1.zero_input_path_reachable");
  }

  if (before.coeffs[k] == 1)
  {
    __CPROVER_assert(
        (int32_t)state.coeffs[k] ==
            (int32_t)state.coeffs[k] + 1,
        "MONT-T4.CONTROL.C2.nonzero_input_path_reachable");
  }

  if (before.coeffs[k] == INT16_MIN)
  {
    __CPROVER_assert(
        (int32_t)state.coeffs[k] ==
            (int32_t)state.coeffs[k] + 1,
        "MONT-T4.CONTROL.C3.full_int16_extreme_path_reachable");
  }
}
C

    prepare_semantic_makefile \
        "$CONTROL14_MAKEFILE" \
        "$CONTROL14_STEM" \
        "mont_t4_control_p1_p4"

    echo "CONTROL14_HARNESS_SHA256=$(hash_file "$CONTROL14_HARNESS")"
    echo "CONTROL14_MAKEFILE_SHA256=$(hash_file "$CONTROL14_MAKEFILE")"

    make -C "$CONTROL14_DIR" MLKEM_K=3 clean \
        >"$OUT/CONTROL14_CLEAN.log" 2>&1 || true

    timeout "$BUILD_TIMEOUT" \
        make -C "$CONTROL14_DIR" MLKEM_K=3 goto \
        >"$OUT/CONTROL14_BUILD.log" 2>&1

    CONTROL14_BUILD_RC=$?
    echo "CONTROL14_BUILD_RC=$CONTROL14_BUILD_RC"

    if [[ "$CONTROL14_BUILD_RC" -ne 0 || ! -f "$CONTROL14_GOTO" ]]; then
        echo "CONTROL14_GOTO_PRESENT=NO"
        tail -n 120 "$OUT/CONTROL14_BUILD.log" || true
        fail "CONTROL14_BUILD_GATE=FAIL" 29
    fi

    echo "CONTROL14_GOTO_PRESENT=YES"
    echo "CONTROL14_GOTO_SHA256=$(hash_file "$CONTROL14_GOTO")"

    section "R3 — DISCOVER AND RUN C1, C2, C3 SEPARATELY"

    C1_DESC="MONT-T4.CONTROL.C1.zero_input_path_reachable"
    C2_DESC="MONT-T4.CONTROL.C2.nonzero_input_path_reachable"
    C3_DESC="MONT-T4.CONTROL.C3.full_int16_extreme_path_reachable"

    C1_ID="$(
        find_property_id \
            "$CONTROL14_GOTO" \
            "$C1_DESC" \
            "$OUT/C1_SHOW_PROPERTIES.log"
    )" ||
        fail "C1_PROPERTY_ID_DISCOVERY=FAIL" 30

    C2_ID="$(
        find_property_id \
            "$CONTROL14_GOTO" \
            "$C2_DESC" \
            "$OUT/C2_SHOW_PROPERTIES.log"
    )" ||
        fail "C2_PROPERTY_ID_DISCOVERY=FAIL" 31

    C3_ID="$(
        find_property_id \
            "$CONTROL14_GOTO" \
            "$C3_DESC" \
            "$OUT/C3_SHOW_PROPERTIES.log"
    )" ||
        fail "C3_PROPERTY_ID_DISCOVERY=FAIL" 32

    echo "C1_PROPERTY_ID=$C1_ID"
    echo "C2_PROPERTY_ID=$C2_ID"
    echo "C3_PROPERTY_ID=$C3_ID"
    echo "CONTROL14_PROPERTY_ID_DISCOVERY=PASS_3_OF_3"

    run_expected_failure \
        "T4_C1" \
        "$CONTROL14_GOTO" \
        "$C1_DESC" \
        "$C1_ID" ||
        fail "T4_C1_NONVACUITY_GATE=FAIL" 33

    run_expected_failure \
        "T4_C2" \
        "$CONTROL14_GOTO" \
        "$C2_DESC" \
        "$C2_ID" ||
        fail "T4_C2_NONVACUITY_GATE=FAIL" 34

    run_expected_failure \
        "T4_C3" \
        "$CONTROL14_GOTO" \
        "$C3_DESC" \
        "$C3_ID" ||
        fail "T4_C3_NONVACUITY_GATE=FAIL" 35

    echo "T4_CONTROL14_NONVACUITY_GATE=PASS_3_OF_3"

    section "R4 — SAFELY CREATE H235 THREE-WITNESS CONTROL"

    archive_and_remove_control_dir "$CONTROL235_DIR" "CONTROL235" ||
        fail "CONTROL235_PREEXISTING_DIRECTORY_GATE=FAIL" 36

    mkdir -p "$CONTROL235_DIR"

    cat >"$CONTROL235_HARNESS" <<'C'
#include <stdint.h>

#include "poly.h"

extern mlk_poly nondet_mlk_poly(void);
extern unsigned nondet_unsigned(void);

void mlk_poly_tomont_c(mlk_poly *r);

static int32_t canonical_q(int32_t value)
{
  int32_t residue = value % MLKEM_Q;

  if (residue < 0)
  {
    residue += MLKEM_Q;
  }

  return residue;
}

void harness(void)
{
  mlk_poly left;
  mlk_poly right;
  mlk_poly left_before;
  mlk_poly right_before;
  unsigned k;
  unsigned j;

  left = nondet_mlk_poly();
  right = nondet_mlk_poly();

  left_before = left;
  right_before = right;

  k = nondet_unsigned();
  j = nondet_unsigned();

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(j < MLKEM_N);
  __CPROVER_assume(j != k);

  mlk_poly_tomont_c(&left);
  mlk_poly_tomont_c(&right);

  if (left_before.coeffs[k] == 0 &&
      right_before.coeffs[k] == MLKEM_Q)
  {
    __CPROVER_assert(
        (int32_t)left.coeffs[k] ==
            (int32_t)left.coeffs[k] + 1,
        "MONT-T4.CONTROL.C4.input_residue_equivalence_antecedent_reachable");
  }

  if (left_before.coeffs[k] == 0 &&
      right_before.coeffs[k] == MLKEM_Q &&
      canonical_q((int32_t)left.coeffs[k]) ==
          canonical_q((int32_t)right.coeffs[k]))
  {
    __CPROVER_assert(
        (int32_t)right.coeffs[k] ==
            (int32_t)right.coeffs[k] + 1,
        "MONT-T4.CONTROL.C5.output_residue_equivalence_antecedent_reachable");
  }

  if (left_before.coeffs[k] == 7 &&
      right_before.coeffs[k] == 7 &&
      left_before.coeffs[j] == 1 &&
      right_before.coeffs[j] == 2)
  {
    __CPROVER_assert(
        (int32_t)left.coeffs[k] ==
            (int32_t)left.coeffs[k] + 1,
        "MONT-T4.CONTROL.C6.local_equality_with_unrelated_difference_reachable");
  }
}
C

    prepare_semantic_makefile \
        "$CONTROL235_MAKEFILE" \
        "$CONTROL235_STEM" \
        "mont_t4_control_p2_p3_p5"

    echo "CONTROL235_HARNESS_SHA256=$(hash_file "$CONTROL235_HARNESS")"
    echo "CONTROL235_MAKEFILE_SHA256=$(hash_file "$CONTROL235_MAKEFILE")"

    make -C "$CONTROL235_DIR" MLKEM_K=3 clean \
        >"$OUT/CONTROL235_CLEAN.log" 2>&1 || true

    timeout "$BUILD_TIMEOUT" \
        make -C "$CONTROL235_DIR" MLKEM_K=3 goto \
        >"$OUT/CONTROL235_BUILD.log" 2>&1

    CONTROL235_BUILD_RC=$?
    echo "CONTROL235_BUILD_RC=$CONTROL235_BUILD_RC"

    if [[ "$CONTROL235_BUILD_RC" -ne 0 || ! -f "$CONTROL235_GOTO" ]]; then
        echo "CONTROL235_GOTO_PRESENT=NO"
        tail -n 120 "$OUT/CONTROL235_BUILD.log" || true
        fail "CONTROL235_BUILD_GATE=FAIL" 37
    fi

    echo "CONTROL235_GOTO_PRESENT=YES"
    echo "CONTROL235_GOTO_SHA256=$(hash_file "$CONTROL235_GOTO")"

    section "R5 — DISCOVER AND RUN C4, C5, C6 SEPARATELY"

    C4_DESC="MONT-T4.CONTROL.C4.input_residue_equivalence_antecedent_reachable"
    C5_DESC="MONT-T4.CONTROL.C5.output_residue_equivalence_antecedent_reachable"
    C6_DESC="MONT-T4.CONTROL.C6.local_equality_with_unrelated_difference_reachable"

    C4_ID="$(
        find_property_id \
            "$CONTROL235_GOTO" \
            "$C4_DESC" \
            "$OUT/C4_SHOW_PROPERTIES.log"
    )" ||
        fail "C4_PROPERTY_ID_DISCOVERY=FAIL" 38

    C5_ID="$(
        find_property_id \
            "$CONTROL235_GOTO" \
            "$C5_DESC" \
            "$OUT/C5_SHOW_PROPERTIES.log"
    )" ||
        fail "C5_PROPERTY_ID_DISCOVERY=FAIL" 39

    C6_ID="$(
        find_property_id \
            "$CONTROL235_GOTO" \
            "$C6_DESC" \
            "$OUT/C6_SHOW_PROPERTIES.log"
    )" ||
        fail "C6_PROPERTY_ID_DISCOVERY=FAIL" 40

    echo "C4_PROPERTY_ID=$C4_ID"
    echo "C5_PROPERTY_ID=$C5_ID"
    echo "C6_PROPERTY_ID=$C6_ID"
    echo "CONTROL235_PROPERTY_ID_DISCOVERY=PASS_3_OF_3"

    run_expected_failure \
        "T4_C4" \
        "$CONTROL235_GOTO" \
        "$C4_DESC" \
        "$C4_ID" ||
        fail "T4_C4_NONVACUITY_GATE=FAIL" 41

    run_expected_failure \
        "T4_C5" \
        "$CONTROL235_GOTO" \
        "$C5_DESC" \
        "$C5_ID" ||
        fail "T4_C5_NONVACUITY_GATE=FAIL" 42

    run_expected_failure \
        "T4_C6" \
        "$CONTROL235_GOTO" \
        "$C6_DESC" \
        "$C6_ID" ||
        fail "T4_C6_NONVACUITY_GATE=FAIL" 43

    echo "T4_CONTROL235_NONVACUITY_GATE=PASS_3_OF_3"
    echo "MONT04C_R3_NONVACUITY_GATE=PASS_6_OF_6"

    section "R6 — FINAL INTEGRITY AND NON-VACUITY VERDICT"

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
        fail "FINAL_INTEGRITY_GATE=FAIL" 44

    FINAL_AUTH_STATUS="$(
        git -C "$AUTH" status --porcelain=v1 --untracked-files=all
    )"

    [[ -z "$FINAL_AUTH_STATUS" ]] ||
        fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 45

    validate_worktree_status "FINAL" ||
        fail "T4_WORKTREE_FINAL_STATUS_GATE=FAIL" 46

    BINDING="$OUT/MONT04C_R3_T4_NONVACUITY_BINDING.env"

    cat >"$BINDING" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
MONT04B_CAPTURE_SHA256=$EXPECTED_MONT04B_CAPTURE_HASH
MONT04B_BINDING_SHA256=$EXPECTED_MONT04B_BINDING_HASH
MONT04C_R1_CAPTURE=$R1_CAPTURE
MONT04C_R1_CAPTURE_SHA256=$(hash_file "$R1_CAPTURE")
MONT04C_R2_CAPTURE=$R2_CAPTURE
MONT04C_R2_CAPTURE_SHA256=$(hash_file "$R2_CAPTURE")
CONTROL14_HARNESS_SHA256=$(hash_file "$CONTROL14_HARNESS")
CONTROL14_MAKEFILE_SHA256=$(hash_file "$CONTROL14_MAKEFILE")
CONTROL14_GOTO_SHA256=$(hash_file "$CONTROL14_GOTO")
CONTROL235_HARNESS_SHA256=$(hash_file "$CONTROL235_HARNESS")
CONTROL235_MAKEFILE_SHA256=$(hash_file "$CONTROL235_MAKEFILE")
CONTROL235_GOTO_SHA256=$(hash_file "$CONTROL235_GOTO")
C1_NONVACUITY=PASS
C2_NONVACUITY=PASS
C3_NONVACUITY=PASS
C4_NONVACUITY=PASS
C5_NONVACUITY=PASS
C6_NONVACUITY=PASS
MONT04C_R3_NONVACUITY_GATE=PASS_6_OF_6
MONT_T4_THEOREM_DOMAIN_CHANGED=NO
MONT_T4_THEOREM_WEAKENED=NO
EOF

    echo "MONT04C_R3_BINDING_FILE=$BINDING"
    echo "MONT04C_R3_BINDING_SHA256=$(hash_file "$BINDING")"
    echo "FINAL_SOURCE_INTEGRITY=PASS"
    echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
    echo "FINAL_FROZEN_FUNCTIONAL_ARTEFACT_INTEGRITY=PASS_2_OF_2"
    echo "T4_CONTROL14_NONVACUITY_GATE=PASS_3_OF_3"
    echo "T4_CONTROL235_NONVACUITY_GATE=PASS_3_OF_3"
    echo "MONT04C_R3_NONVACUITY_GATE=PASS_6_OF_6"
    echo "MONT_T4_CORE_PROPERTIES_VERIFIED=5_OF_5"
    echo "MONT_T4_SUPPORTING_ASSERTIONS_VERIFIED=1_OF_1"
    echo "MONT_T4_NONVACUITY_WITNESSES=PASS_6_OF_6"
    echo "MONT_T4_THEOREM_DOMAIN_CHANGED=NO"
    echo "MONT_T4_THEOREM_WEAKENED=NO"
    echo "MONT_T4_STATUS=FUNCTIONAL_AND_NONVACUITY_ACCEPTED"
    echo "NEXT_GATE=MONT-04C-R4_SAFETY_AND_UNWINDING"
    echo "MONT04C_R3_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
