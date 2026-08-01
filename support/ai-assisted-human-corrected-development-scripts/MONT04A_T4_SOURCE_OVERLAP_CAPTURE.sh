#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT04A_T4_SOURCE_CAPTURE_$STAMP"
CAPTURE="$OUT/MONT04A_TERMINAL_CAPTURE_$STAMP.txt"

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

{
    section "MONT-04A — POLY_TOMONT PORTABLE-C SOURCE / OVERLAP CAPTURE"
    echo "UTC_TIME=$STAMP"
    echo "AUTHORITATIVE_SOURCE=$AUTH"
    echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
    echo "OUTPUT_DIRECTORY=$OUT"

    section "G0 — AUTHORITATIVE SOURCE BINDING"

    AUTH_IS_WORKTREE="$(git -C "$AUTH" rev-parse --is-inside-work-tree 2>/dev/null || true)"
    AUTH_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null || true)"
    AUTH_STATUS="$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

    echo "AUTHORITATIVE_IS_WORKTREE=$AUTH_IS_WORKTREE"
    echo "AUTHORITATIVE_HEAD=$AUTH_HEAD"
    echo "AUTHORITATIVE_STATUS_BEGIN"
    printf '%s\n' "$AUTH_STATUS"
    echo "AUTHORITATIVE_STATUS_END"

    [[ "$AUTH_IS_WORKTREE" == "true" &&
       "$AUTH_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$AUTH_STATUS" ]] ||
        fail "AUTHORITATIVE_SOURCE_GATE=FAIL" 20

    POLY_H_HASH="$(hash_file "$AUTH/mlkem/src/poly.h")"
    POLY_C_HASH="$(hash_file "$AUTH/mlkem/src/poly.c")"

    echo "POLY_H_SHA256=$POLY_H_HASH"
    echo "POLY_C_SHA256=$POLY_C_HASH"

    [[ "$POLY_H_HASH" == "$EXPECTED_POLY_H" &&
       "$POLY_C_HASH" == "$EXPECTED_POLY_C" ]] ||
        fail "SOURCE_HASH_GATE=FAIL" 21

    echo "AUTHORITATIVE_SOURCE_GATE=PASS"
    echo "SOURCE_HASH_GATE=PASS"

    section "G1 — EXACT TARGET DEFINITION AND CONSTANT"

    TARGET_FILE="$AUTH/mlkem/src/poly.c"

    TARGET_DEF_COUNT="$(
        grep -Ec \
            '^[[:space:]]*MLK_STATIC_TESTABLE void mlk_poly_tomont_c[[:space:]]*\(' \
            "$TARGET_FILE" || true
    )"

    F_CONSTANT_COUNT="$(
        grep -Ec \
            'const int16_t f = 1353;.*2\^32.*MLKEM_Q' \
            "$TARGET_FILE" || true
    )"

    TARGET_CALL_COUNT="$(
        grep -Ec \
            'r->coeffs\[i\][[:space:]]*=[[:space:]]*mlk_fqmul\(r->coeffs\[i\],[[:space:]]*f\);' \
            "$TARGET_FILE" || true
    )"

    echo "POLY_TOMONT_C_DEFINITION_COUNT=$TARGET_DEF_COUNT"
    echo "POLY_TOMONT_F1353_COUNT=$F_CONSTANT_COUNT"
    echo "POLY_TOMONT_COEFFICIENT_FQMUL_COUNT=$TARGET_CALL_COUNT"

    [[ "$TARGET_DEF_COUNT" -eq 1 &&
       "$F_CONSTANT_COUNT" -eq 1 &&
       "$TARGET_CALL_COUNT" -eq 1 ]] ||
        fail "TARGET_SOURCE_SHAPE_GATE=FAIL" 22

    TARGET_LINE="$(
        grep -n \
            '^[[:space:]]*MLK_STATIC_TESTABLE void mlk_poly_tomont_c' \
            "$TARGET_FILE" |
        head -n 1 |
        cut -d: -f1
    )"

    START_LINE=$((TARGET_LINE - 12))
    END_LINE=$((TARGET_LINE + 45))

    if [[ "$START_LINE" -lt 1 ]]; then
        START_LINE=1
    fi

    echo "POLY_TOMONT_C_DEFINITION_LINE=$TARGET_LINE"
    echo "POLY_TOMONT_C_SOURCE_CONTEXT_BEGIN"
    nl -ba "$TARGET_FILE" |
        sed -n "${START_LINE},${END_LINE}p"
    echo "POLY_TOMONT_C_SOURCE_CONTEXT_END"
    echo "TARGET_SOURCE_SHAPE_GATE=PASS"

    section "G2 — SCALAR COMPANION CONTEXT"

    FQMUL_LINE="$(
        grep -n \
            '^[[:space:]]*static MLK_INLINE int16_t mlk_fqmul' \
            "$TARGET_FILE" |
        head -n 1 |
        cut -d: -f1
    )"

    [[ -n "$FQMUL_LINE" ]] ||
        fail "FQMUL_DEFINITION_GATE=FAIL" 23

    FQ_START=$((FQMUL_LINE - 12))
    FQ_END=$((FQMUL_LINE + 28))

    if [[ "$FQ_START" -lt 1 ]]; then
        FQ_START=1
    fi

    echo "FQMUL_DEFINITION_LINE=$FQMUL_LINE"
    echo "FQMUL_SOURCE_CONTEXT_BEGIN"
    nl -ba "$TARGET_FILE" |
        sed -n "${FQ_START},${FQ_END}p"
    echo "FQMUL_SOURCE_CONTEXT_END"

    MONT_LINE="$(
        grep -n \
            '^[[:space:]]*static MLK_ALWAYS_INLINE int16_t mlk_montgomery_reduce' \
            "$AUTH/mlkem/src/poly.h" |
        head -n 1 |
        cut -d: -f1
    )"

    [[ -n "$MONT_LINE" ]] ||
        fail "MONTGOMERY_REDUCE_DEFINITION_GATE=FAIL" 24

    MONT_START=$((MONT_LINE - 10))
    MONT_END=$((MONT_LINE + 46))

    if [[ "$MONT_START" -lt 1 ]]; then
        MONT_START=1
    fi

    echo "MONTGOMERY_REDUCE_DEFINITION_LINE=$MONT_LINE"
    echo "MONTGOMERY_REDUCE_SOURCE_CONTEXT_BEGIN"
    nl -ba "$AUTH/mlkem/src/poly.h" |
        sed -n "${MONT_START},${MONT_END}p"
    echo "MONTGOMERY_REDUCE_SOURCE_CONTEXT_END"
    echo "SCALAR_COMPANION_CAPTURE_GATE=PASS"

    section "G3 — EXISTING CBMC HARNESS OVERLAP"

    NATIVE_C_DIR="$AUTH/proofs/cbmc/poly_tomont_c"
    WRAPPER_DIR="$AUTH/proofs/cbmc/poly_tomont"

    if [[ -d "$NATIVE_C_DIR" ]]; then
        echo "NATIVE_POLY_TOMONT_C_DIRECTORY_PRESENT=YES"
        find "$NATIVE_C_DIR" -maxdepth 2 -type f -print |
            sort
        echo "NATIVE_POLY_TOMONT_C_FILES_END"

        for file in "$NATIVE_C_DIR"/*.c "$NATIVE_C_DIR"/Makefile
        do
            [[ -f "$file" ]] || continue
            echo "NATIVE_FILE_BEGIN=$file"
            sed -n '1,240p' "$file"
            echo "NATIVE_FILE_END=$file"
            echo "NATIVE_FILE_SHA256=$(hash_file "$file")"
        done
    else
        echo "NATIVE_POLY_TOMONT_C_DIRECTORY_PRESENT=NO"
    fi

    if [[ -d "$WRAPPER_DIR" ]]; then
        echo "NATIVE_POLY_TOMONT_WRAPPER_DIRECTORY_PRESENT=YES"
        find "$WRAPPER_DIR" -maxdepth 2 -type f -print |
            sort
        echo "NATIVE_POLY_TOMONT_WRAPPER_FILES_END"

        for file in "$WRAPPER_DIR"/*.c "$WRAPPER_DIR"/Makefile
        do
            [[ -f "$file" ]] || continue
            echo "WRAPPER_FILE_BEGIN=$file"
            sed -n '1,240p' "$file"
            echo "WRAPPER_FILE_END=$file"
            echo "WRAPPER_FILE_SHA256=$(hash_file "$file")"
        done
    else
        echo "NATIVE_POLY_TOMONT_WRAPPER_DIRECTORY_PRESENT=NO"
    fi

    EXPLICIT_ASSERTION_COUNT="$(
        {
            grep -R -h -E \
                '__CPROVER_assert[[:space:]]*\(' \
                "$NATIVE_C_DIR" "$WRAPPER_DIR" 2>/dev/null || true
        } |
        wc -l
    )"

    TARGET_CALL_REFERENCE_COUNT="$(
        {
            grep -R -h -E \
                'mlk_poly_tomont_c[[:space:]]*\(' \
                "$NATIVE_C_DIR" "$WRAPPER_DIR" 2>/dev/null || true
        } |
        wc -l
    )"

    echo "EXISTING_TOMONT_EXPLICIT_ASSERTION_COUNT=$EXPLICIT_ASSERTION_COUNT"
    echo "EXISTING_TOMONT_TARGET_CALL_REFERENCE_COUNT=$TARGET_CALL_REFERENCE_COUNT"
    echo "CBMC_OVERLAP_CAPTURE_GATE=PASS"

    section "G4 — HOL LIGHT / NATIVE PROOF OVERLAP"

    echo "TOMONT_HOL_REFERENCE_BEGIN"
    grep -R -n -E \
        'poly_tomont|tomont|1353|Montgomery' \
        "$AUTH/proofs/hol_light" \
        "$AUTH/mlkem/src/native" \
        2>/dev/null |
        head -n 500 || true
    echo "TOMONT_HOL_REFERENCE_END"

    HOL_TOMONT_REFERENCE_COUNT="$(
        {
            grep -R -h -E \
                'poly_tomont|tomont' \
                "$AUTH/proofs/hol_light" \
                "$AUTH/mlkem/src/native" \
                2>/dev/null || true
        } |
        wc -l
    )"

    echo "HOL_OR_NATIVE_TOMONT_REFERENCE_COUNT=$HOL_TOMONT_REFERENCE_COUNT"
    echo "HOL_NATIVE_OVERLAP_CAPTURE_GATE=PASS"

    section "G5 — CBMC BUILD CONTRACT"

    COMMON="$AUTH/proofs/cbmc/Makefile.common"

    [[ -f "$COMMON" ]] ||
        fail "CBMC_MAKEFILE_COMMON_PRESENT=NO" 25

    echo "MAKEFILE_COMMON=$COMMON"
    grep -n -E \
        'HARNESS_FILE|HARNESS_GOTO|^goto:|^_goto:|CHECK_FUNCTION_CONTRACTS|USE_FUNCTION_CONTRACTS|FUNCTION_NAME' \
        "$COMMON" |
        head -n 240 || true

    echo "CBMC_BUILD_CONTRACT_CAPTURE_GATE=PASS"

    section "G6 — TOOL SNAPSHOT"

    cbmc --version || true
    goto-cc --version || true
    make --version | head -n 2 || true
    cc --version | head -n 2 || true

    section "G7 — FREEZE EXACT OLD MONT-T4 PROMISE"

    REGISTRY="$OUT/MONT04A_T4_FROZEN_REGISTRY.txt"

    cat >"$REGISTRY" <<'EOF'
MONT-T4 — PORTABLE-C ROUND TRIP, BIJECTION AND LOCALITY
========================================================

Target:
  mlk_poly_tomont_c

Supporting scalar functions:
  mlk_fqmul
  mlk_montgomery_reduce

Input domain:
  Every polynomial coefficient is an arbitrary int16_t value unless a
  narrower domain is explicitly inherent in a relational premise.

T4-P1 — De-Montgomery round trip
  For every coefficient i:
    canonical_q(montgomery_reduce(T(A)[i]))
      ==
    canonical_q(A_before[i])

T4-P2 — Residue-vector equivalence preservation
  For two arbitrary int16_t polynomials A and D:
    (for every i, A[i] == D[i] mod q)
      implies
    (for every i, T(A)[i] == T(D)[i] mod q)

T4-P3 — Residue-vector equivalence reflection
  For two arbitrary int16_t polynomials A and D:
    (for every i, T(A)[i] == T(D)[i] mod q)
      implies
    (for every i, A[i] == D[i] mod q)

T4-P4 — Zero-support preservation
  For every coefficient i:
    T(A)[i] == 0 mod q
      iff
    A_before[i] == 0 mod q

T4-P5 — Coefficient locality and no cross-talk
  For two arbitrary polynomials A and D and an arbitrary valid index k:
    A[k] == D[k]
      implies
    T(A)[k] == T(D)[k]
  regardless of differences at every other coefficient.

NOVELTY BOUNDARY
================
The basic forward representation congruence:
  T(A)[i] == A[i] * R mod q
may be proved only as a supporting lemma.

It is not the T4 headline novelty because corresponding native/HOL proof
coverage already exists for basic conversion congruence and bounds.

The headline T4 contribution is:
  de-Montgomery round trip
  residue-vector equivalence preservation and reflection
  zero-support preservation
  two-execution coefficient locality/no cross-talk

ASSURANCE GATES — NOT COUNTED AS EXTRA THEOREMS
===============================================
  source and commit binding
  target-call reachability
  assumption satisfiability
  assertion reachability
  CBMC safety and unwinding checks
  false controls
  T4-specific mutations
  K=2, K=3 and K=4 reproduction where relevant
  evidence hashing
  production-source integrity

NO-WEAKENING RULE
=================
No T4 property may be removed, narrowed, replaced by a scalar-only theorem,
or accepted solely because T1-T3 passed.
EOF

    echo "MONT04A_T4_REGISTRY_SHA256=$(hash_file "$REGISTRY")"

    REQUIRED_REGISTRY_MARKERS=(
        "T4-P1 — De-Montgomery round trip"
        "T4-P2 — Residue-vector equivalence preservation"
        "T4-P3 — Residue-vector equivalence reflection"
        "T4-P4 — Zero-support preservation"
        "T4-P5 — Coefficient locality and no cross-talk"
        "No T4 property may be removed"
    )

    MISSING=0

    for marker in "${REQUIRED_REGISTRY_MARKERS[@]}"
    do
        if ! grep -Fq "$marker" "$REGISTRY"; then
            echo "MONT04A_REGISTRY_MISSING=$marker"
            MISSING=$((MISSING + 1))
        fi
    done

    echo "MONT04A_REGISTRY_MISSING_COUNT=$MISSING"

    [[ "$MISSING" -eq 0 ]] ||
        fail "MONT04A_REGISTRY_FREEZE_GATE=FAIL" 26

    section "G8 — FINAL READ-ONLY INTEGRITY"

    FINAL_HEAD="$(git -C "$AUTH" rev-parse HEAD 2>/dev/null || true)"
    FINAL_STATUS="$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"
    FINAL_POLY_H="$(hash_file "$AUTH/mlkem/src/poly.h")"
    FINAL_POLY_C="$(hash_file "$AUTH/mlkem/src/poly.c")"

    [[ "$FINAL_HEAD" == "$EXPECTED_COMMIT" &&
       -z "$FINAL_STATUS" &&
       "$FINAL_POLY_H" == "$EXPECTED_POLY_H" &&
       "$FINAL_POLY_C" == "$EXPECTED_POLY_C" ]] ||
        fail "FINAL_READ_ONLY_INTEGRITY_GATE=FAIL" 27

    echo "FINAL_READ_ONLY_INTEGRITY_GATE=PASS"
    echo "MONT_T4_TARGET=mlk_poly_tomont_c"
    echo "MONT_T4_PROPERTY_COUNT=5"
    echo "MONT_T4_THEOREM_WEAKENED=NO"
    echo "MONT_T4_SOURCE_MODIFIED=NO"
    echo "MONT04A_CAPTURE_GATE=PASS"
    echo "NEXT_GATE=MONT-04B_HARNESS_FREEZE"
    echo "MONT04A_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
