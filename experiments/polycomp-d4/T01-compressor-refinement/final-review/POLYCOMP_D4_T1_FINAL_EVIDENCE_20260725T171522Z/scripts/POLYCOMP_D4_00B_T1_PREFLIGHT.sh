#!/usr/bin/env bash
set -uo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"

CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"
STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_00B_MANIFEST_REGISTRY_T1_PREFLIGHT"

WORK_ROOT="${HOME}/THESIS-2026/_cbmc_work"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

WORK_REPO="${WORK_ROOT}/mlkem-native_polycomp_d4_t1_${UTC_STAMP}"

PROOF_NAME="polycomp_d4_t1_packed_refinement"
PROOF_DIR="${WORK_REPO}/proofs/cbmc/${PROOF_NAME}"

HARNESS_NAME="polycomp_d4_t1_packed_refinement_harness"
HARNESS_FILE="${PROOF_DIR}/${HARNESS_NAME}.c"
MAKEFILE="${PROOF_DIR}/Makefile"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_00B_T1_PREFLIGHT_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

SOURCE_MANIFEST="${STAGE_DIR}/POLYCOMP_D4_00B_GIT_OBJECT_MANIFEST_${UTC_STAMP}.txt"
SOURCE_MANIFEST_HASH="${SOURCE_MANIFEST}.sha256"

DERIVATION_FILE="${STAGE_DIR}/POLYCOMP_D4_00B_FINITE_DOMAIN_DERIVATION_${UTC_STAMP}.txt"
DERIVATION_HASH="${DERIVATION_FILE}.sha256"

REGISTRY_FILE="${STAGE_DIR}/POLYCOMP_D4_THEOREM_REGISTRY_V1_${UTC_STAMP}.txt"
REGISTRY_HASH="${REGISTRY_FILE}.sha256"

RESULT_JSON="${STAGE_DIR}/POLYCOMP_D4_T1_PREFLIGHT_RESULT_${UTC_STAMP}.json"

FAIL=0
PROOF_RUN_EXIT=99

mkdir -p "$STAGE_DIR" "$WORK_ROOT"

section()
{
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

mark_fail()
{
    printf 'GATE_FAILURE: %s\n' "$1"
    FAIL=1
}

main()
{
    local head
    local status_before
    local status_after
    local tracked_count
    local manifest_count
    local manifest_error_count
    local symlink_count

    section "POLYCOMP-D4-00B — MANIFEST REPAIR / REGISTRY / T1 PREFLIGHT"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'CAMPAIGN_ROOT=%s\n' "$CAMPAIGN_ROOT"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'PROOF_NAME=%s\n' "$PROOF_NAME"

    section "00B.1 — RECONFIRM AUTHORITATIVE SOURCE"

    if [[ ! -d "$AUTHORITATIVE_SOURCE_PATH" ]]; then
        mark_fail "authoritative source directory is missing"
        return 20
    fi

    if ! GIT_OPTIONAL_LOCKS=0 \
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
        rev-parse --is-inside-work-tree >/dev/null 2>&1
    then
        mark_fail "authoritative source is not a Git worktree"
        return 21
    fi

    head="$(
        GIT_OPTIONAL_LOCKS=0 \
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
        rev-parse HEAD 2>/dev/null || true
    )"

    printf 'AUTHORITATIVE_HEAD=%s\n' "$head"

    if [[ "$head" != "$EXPECTED_COMMIT" ]]; then
        mark_fail "authoritative HEAD differs from EXPECTED_COMMIT"
        return 22
    fi

    status_before="$(
        GIT_OPTIONAL_LOCKS=0 \
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
        status --porcelain=v1 --untracked-files=all 2>/dev/null ||
        true
    )"

    if [[ -n "$status_before" ]]; then
        printf '%s\n' "$status_before"
        mark_fail "authoritative source is not clean"
        return 23
    fi

    printf 'AUTHORITATIVE_SOURCE_BINDING=PASS\n'
    printf 'AUTHORITATIVE_WORKTREE_BEFORE=CLEAN\n'

    section "00B.2 — REPAIRED GIT-OBJECT SOURCE MANIFEST"

    tracked_count="$(
        GIT_OPTIONAL_LOCKS=0 \
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
        ls-files |
        wc -l |
        tr -d ' '
    )"

    printf 'TRACKED_FILE_COUNT=%s\n' "$tracked_count"

    : > "$SOURCE_MANIFEST"

    while IFS= read -r -d '' record
    do
        metadata="${record%%$'\t'*}"
        relative_path="${record#*$'\t'}"

        read -r mode object_id stage_number <<< "$metadata"

        if [[ "$mode" == "160000" ]]; then
            printf '%s  %s  GITLINK  %s\n' \
                "$mode" \
                "$object_id" \
                "$relative_path" >> "$SOURCE_MANIFEST"
            continue
        fi

        content_sha256="$(
            GIT_OPTIONAL_LOCKS=0 \
            git -C "$AUTHORITATIVE_SOURCE_PATH" \
            cat-file blob "$object_id" 2>/dev/null |
            sha256sum |
            awk '{print $1}'
        )"

        if [[ -z "$content_sha256" ]]; then
            printf '%s  %s  ERROR  %s\n' \
                "$mode" \
                "$object_id" \
                "$relative_path" >> "$SOURCE_MANIFEST"
        else
            printf '%s  %s  %s  %s\n' \
                "$mode" \
                "$object_id" \
                "$content_sha256" \
                "$relative_path" >> "$SOURCE_MANIFEST"
        fi
    done < <(
        GIT_OPTIONAL_LOCKS=0 \
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
        ls-files -s -z
    )

    manifest_count="$(
        wc -l < "$SOURCE_MANIFEST" |
        tr -d ' '
    )"

    manifest_error_count="$(
        awk '$3 == "ERROR" { count++ } END { print count + 0 }' \
            "$SOURCE_MANIFEST"
    )"

    symlink_count="$(
        awk '$1 == "120000" { count++ } END { print count + 0 }' \
            "$SOURCE_MANIFEST"
    )"

    sha256sum "$SOURCE_MANIFEST" > "$SOURCE_MANIFEST_HASH"

    printf 'REPAIRED_MANIFEST=%s\n' "$SOURCE_MANIFEST"
    printf 'REPAIRED_MANIFEST_ENTRY_COUNT=%s\n' "$manifest_count"
    printf 'REPAIRED_MANIFEST_ERROR_COUNT=%s\n' "$manifest_error_count"
    printf 'TRACKED_SYMLINK_COUNT=%s\n' "$symlink_count"
    printf 'REPAIRED_MANIFEST_SHA256=%s\n' \
        "$(awk '{print $1}' "$SOURCE_MANIFEST_HASH")"

    if [[ "$manifest_count" != "$tracked_count" ]]; then
        mark_fail "repaired manifest count differs from tracked-file count"
    fi

    if [[ "$manifest_error_count" != "0" ]]; then
        mark_fail "repaired manifest contains hashing errors"
    fi

    printf '\n--- committed symbolic-link records ---\n'

    awk '$1 == "120000" { print }' "$SOURCE_MANIFEST" |
        sed -n '1,80p'

    if [[ "$manifest_count" == "$tracked_count" &&
          "$manifest_error_count" == "0" ]]
    then
        printf 'REPAIRED_SOURCE_MANIFEST_STATUS=PASS\n'
    fi

    section "00B.3 — INDEPENDENT FINITE-DOMAIN DERIVATION"

    python3 - "$DERIVATION_FILE" <<'PY'
import sys
from pathlib import Path

output_path = Path(sys.argv[1])

Q = 3329


def spec_compress_d4(value: int) -> int:
    return ((value * 16 + Q // 2) // Q) % 16


def spec_decompress_d4(value: int) -> int:
    return ((value * Q) + 8) >> 4


def modular_distance(left: int, right: int) -> int:
    difference = abs(left - right)
    return min(difference, Q - difference)


image = [spec_decompress_d4(value) for value in range(16)]

fixed_points = [
    value
    for value in range(Q)
    if spec_decompress_d4(spec_compress_d4(value)) == value
]

errors = [
    modular_distance(
        value,
        spec_decompress_d4(spec_compress_d4(value)),
    )
    for value in range(Q)
]

maximum_error = max(errors)

maximum_error_witnesses = [
    value
    for value, error in enumerate(errors)
    if error == maximum_error
]

retraction_values = [
    spec_compress_d4(spec_decompress_d4(value))
    for value in range(16)
]

projection_idempotent = all(
    spec_decompress_d4(
        spec_compress_d4(
            spec_decompress_d4(spec_compress_d4(value))
        )
    )
    == spec_decompress_d4(spec_compress_d4(value))
    for value in range(Q)
)

intervals = {}

for compressed in range(16):
    members = [
        value
        for value in range(Q)
        if spec_compress_d4(value) == compressed
    ]

    ranges = []

    start = members[0]
    previous = members[0]

    for value in members[1:]:
        if value == previous + 1:
            previous = value
            continue

        ranges.append((start, previous))
        start = value
        previous = value

    ranges.append((start, previous))
    intervals[compressed] = ranges


expected_image = [
    0,
    208,
    416,
    624,
    832,
    1040,
    1248,
    1456,
    1665,
    1873,
    2081,
    2289,
    2497,
    2705,
    2913,
    3121,
]

assert image == expected_image
assert fixed_points == expected_image
assert maximum_error == 104
assert retraction_values == list(range(16))
assert projection_idempotent

with output_path.open("w", encoding="utf-8") as output:
    output.write("POLYCOMP-D4 FINITE-DOMAIN DERIVATION\n")
    output.write("STATUS=PASS\n")
    output.write(f"Q={Q}\n")
    output.write("DOMAIN=0..3328\n")
    output.write("COMPRESSED_DOMAIN=0..15\n")
    output.write(
        "DECOMPRESSED_IMAGE="
        + ",".join(str(value) for value in image)
        + "\n"
    )
    output.write(
        "FIXED_POINTS="
        + ",".join(str(value) for value in fixed_points)
        + "\n"
    )
    output.write(f"MAXIMUM_MODULAR_ERROR={maximum_error}\n")
    output.write(
        "MAXIMUM_ERROR_WITNESSES="
        + ",".join(str(value) for value in maximum_error_witnesses)
        + "\n"
    )
    output.write(
        f"MAXIMUM_ERROR_WITNESS_COUNT={len(maximum_error_witnesses)}\n"
    )
    output.write("SCALAR_RETRACTION=PASS\n")
    output.write("PROJECTION_IDEMPOTENCE=PASS\n")
    output.write("\nQUANTIZATION_INTERVALS\n")

    for compressed in range(16):
        formatted_ranges = ",".join(
            f"{start}..{end}"
            for start, end in intervals[compressed]
        )
        output.write(
            f"COMPRESSED_{compressed}={formatted_ranges}\n"
        )
PY

    derivation_exit=$?

    if [[ "$derivation_exit" -ne 0 ]]; then
        mark_fail "independent finite-domain derivation failed"
    else
        sha256sum "$DERIVATION_FILE" > "$DERIVATION_HASH"

        printf 'DERIVATION_FILE=%s\n' "$DERIVATION_FILE"
        printf 'DERIVATION_SHA256=%s\n' \
            "$(awk '{print $1}' "$DERIVATION_HASH")"

        cat "$DERIVATION_FILE"
    fi

    section "00B.4 — FOUR-THEOREM REGISTRY FREEZE"

    cat > "$REGISTRY_FILE" <<'REGISTRY'
POLYCOMP-D4 THEOREM REGISTRY
REGISTRY_VERSION=1.0
REGISTRY_STATE=FROZEN_FOR_INITIAL_CBMC CAMPAIGN
PARAMETER_SET=ML-KEM-768
MLKEM_K=3
PORTABLE_IMPLEMENTATION=YES
PRODUCTION_SOURCE_MODIFICATION=FORBIDDEN

T1_ID=POLYCOMP-D4-T1
T1_NAME=Portable-C packed compressor refinement
T1_DOMAIN=All canonical 256-coefficient polynomials
T1_PRIMARY_CLAIM=All 128 produced bytes equal an independent ByteEncode_4(Compress_4(A)) specification
T1_OBLIGATIONS=full-byte-refinement;coordinate-to-nibble;pair-packing;complete-overwrite-independence;relational-nibble-locality

T2_ID=POLYCOMP-D4-T2
T2_NAME=Portable-C unpacked decompressor refinement
T2_DOMAIN=All 128-byte arrays
T2_PRIMARY_CLAIM=All 256 coefficients equal an independent Decompress_4(ByteDecode_4(B)) specification
T2_OBLIGATIONS=full-polynomial-refinement;exact-nibble-extraction;exact-scalar-decompression;image-membership;relational-byte-locality

T3_ID=POLYCOMP-D4-T3
T3_NAME=Exact compressed-domain retraction
T3_DOMAIN=All 128-byte arrays
T3_PRIMARY_CLAIM=compress_d4(decompress_d4(B)) equals B byte-for-byte
T3_OBLIGATIONS=byte-identity;nibble-preservation;cycle-stability

T4_ID=POLYCOMP-D4-T4
T4_NAME=Quantizer projection and sharp modular distortion
T4_DOMAIN=All canonical 256-coefficient polynomials
T4_PRIMARY_CLAIM=decompress_d4(compress_d4(A)) is the D4 projection with sharp modular error at most 104
T4_OBLIGATIONS=exact-composition;image-characterization;sharp-error-bound;error-witness;fixed-point-characterization;projection-idempotence;coordinate-locality

COMMON_ASSURANCE=commit-binding;portable-body-binding;no-source-modification;full-unwinding;memory-safety;arithmetic-safety;reachability;coverage-non-vacuity;mutation;hash-freeze;reproducibility

NOVELTY_BOUNDARY=New repository-level CBMC semantic and relational proof obligations; not new FIPS mathematics
REGISTRY

    sha256sum "$REGISTRY_FILE" > "$REGISTRY_HASH"

    printf 'REGISTRY_FILE=%s\n' "$REGISTRY_FILE"
    printf 'REGISTRY_SHA256=%s\n' \
        "$(awk '{print $1}' "$REGISTRY_HASH")"

    cat "$REGISTRY_FILE"

    section "00B.5 — ISOLATED EXACT-COMMIT WORK REPOSITORY"

    if [[ -e "$WORK_REPO" ]]; then
        mark_fail "work-repository path already exists"
        return 30
    fi

    if ! git clone \
        --quiet \
        --no-hardlinks \
        "$AUTHORITATIVE_SOURCE_PATH" \
        "$WORK_REPO"
    then
        mark_fail "local isolated clone failed"
        return 31
    fi

    if ! git -C "$WORK_REPO" \
        checkout --quiet --detach "$EXPECTED_COMMIT"
    then
        mark_fail "could not detach work repository at expected commit"
        return 32
    fi

    printf 'WORK_REPO_HEAD=%s\n' \
        "$(git -C "$WORK_REPO" rev-parse HEAD)"

    if [[ "$(git -C "$WORK_REPO" rev-parse HEAD)" != "$EXPECTED_COMMIT" ]]
    then
        mark_fail "work repository is bound to the wrong commit"
        return 33
    fi

    for relative_path in \
        mlkem/src/compress.c \
        mlkem/src/compress.h \
        mlkem/src/params.h \
        mlkem/src/poly.h \
        mlkem/src/cbmc.h \
        mlkem/src/verify.h
    do
        authoritative_hash="$(
            sha256sum "$AUTHORITATIVE_SOURCE_PATH/$relative_path" |
            awk '{print $1}'
        )"

        work_hash="$(
            sha256sum "$WORK_REPO/$relative_path" |
            awk '{print $1}'
        )"

        printf 'SOURCE_BINDING %s AUTH=%s WORK=%s\n' \
            "$relative_path" \
            "$authoritative_hash" \
            "$work_hash"

        if [[ "$authoritative_hash" != "$work_hash" ]]; then
            mark_fail "source binding mismatch for $relative_path"
        fi
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 34
    fi

    printf 'ISOLATED_SOURCE_BINDING=PASS\n'

    section "00B.6 — ORIGINAL T1 POSITIVE HARNESS CREATION"

    mkdir -p "$PROOF_DIR"

    cat > "$HARNESS_FILE" <<'HARNESS'
/*
 * POLYCOMP-D4-T1 positive semantic preflight.
 *
 * Clean-room property harness.
 *
 * This harness does not modify mlkem-native production code and does not
 * reproduce the native CBMC harness. It executes the portable-C compressor
 * and compares every produced byte against a division-based mathematical
 * specification.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assume(_Bool condition);
void __CPROVER_assert(_Bool condition, const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

static uint8_t polycomp_d4_spec_compress_scalar(int16_t value)
{
  uint32_t numerator;

  /*
   * Independent specification:
   *
   *   round(16 * value / q) mod 16
   *
   * Production uses a multiplication by a precomputed constant and shift.
   * This specification deliberately uses exact integer division instead.
   */
  numerator =
      ((uint32_t)(uint16_t)value * (uint32_t)16u) +
      (uint32_t)(MLKEM_Q / 2);

  return (uint8_t)(
      (numerator / (uint32_t)MLKEM_Q) %
      (uint32_t)16u);
}

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input;
  uint8_t actual[MLKEM_POLYCOMPRESSEDBYTES_D4];

  unsigned i;

  uint8_t expected_low;
  uint8_t expected_high;
  uint8_t expected_byte;

  /*
   * Domain required by the production compressor:
   * every coefficient is unsigned canonical modulo q.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(input.coeffs[i] >= 0);
    __CPROVER_assume(input.coeffs[i] < MLKEM_Q);
  }

  /*
   * Execute the real portable-C implementation.
   * No wrapper dispatch and no native backend are involved.
   */
  mlk_poly_compress_d4_c(actual, &input);

  /*
   * Full 128-byte packed refinement.
   *
   * Byte i contains:
   *   low nibble  = Compress_4(input[2*i])
   *   high nibble = Compress_4(input[2*i+1])
   */
  for (i = 0; i < MLKEM_POLYCOMPRESSEDBYTES_D4; i++)
  {
    expected_low =
        polycomp_d4_spec_compress_scalar(
            input.coeffs[2u * i]);

    expected_high =
        polycomp_d4_spec_compress_scalar(
            input.coeffs[2u * i + 1u]);

    expected_byte =
        (uint8_t)(
            expected_low |
            (uint8_t)(expected_high << 4));

    __CPROVER_assert(
        actual[i] == expected_byte,
        "POLYCOMP-D4-T1: every packed byte equals the independent specification");
  }
#endif
}
HARNESS

    cat > "$MAKEFILE" <<'MAKEFILE_EOF'
# POLYCOMP-D4-T1 clean-room semantic preflight

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = polycomp_d4_t1_packed_refinement_harness

PROOF_UID = polycomp_d4_t1_packed_refinement

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=

#
# Execute implementation and harness loops directly.
# Do not replace the implementation with a function contract.
#
CHECK_FUNCTION_CONTRACTS =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/compress.c

#
# 257 is sufficient for the 256-iteration canonical-domain loop.
# It also completely covers the compressor's 32- and 8-iteration loops
# and the 128-iteration postcondition loop.
#
UNWINDSET +=
CBMCFLAGS = --smt2
CBMCFLAGS += --unwind 257
CBMCFLAGS += --unwinding-assertions

EXTERNAL_SAT_SOLVER =

FUNCTION_NAME = mlk_poly_compress_d4_c
CBMC_OBJECT_BITS = 8

include ../Makefile.common
MAKEFILE_EOF

    printf 'HARNESS_FILE=%s\n' "$HARNESS_FILE"
    printf 'HARNESS_SHA256=%s\n' \
        "$(sha256sum "$HARNESS_FILE" | awk '{print $1}')"

    printf 'MAKEFILE=%s\n' "$MAKEFILE"
    printf 'MAKEFILE_SHA256=%s\n' \
        "$(sha256sum "$MAKEFILE" | awk '{print $1}')"

    printf '\n--- generated clean-room harness ---\n'
    sed -n '1,260p' "$HARNESS_FILE"

    printf '\n--- generated proof Makefile ---\n'
    sed -n '1,220p' "$MAKEFILE"

    section "00B.7 — PRE-RUN FIREWALL CHECKS"

    production_status="$(
        git -C "$WORK_REPO" \
        status --porcelain=v1 -- \
        mlkem/src 2>/dev/null ||
        true
    )"

    if [[ -n "$production_status" ]]; then
        printf '%s\n' "$production_status"
        mark_fail "production-source files changed in work repository"
        return 40
    fi

    printf 'PRODUCTION_SOURCE_MODIFICATION_CHECK=PASS\n'

    target_call_count="$(
        grep -c \
            'mlk_poly_compress_d4_c(actual, &input)' \
            "$HARNESS_FILE" ||
        true
    )"

    assertion_count="$(
        grep -c '__CPROVER_assert' "$HARNESS_FILE" ||
        true
    )"

    assume_false_count="$(
        grep -Ec \
            '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)[[:space:]]*\)' \
            "$HARNESS_FILE" ||
        true
    )"

    printf 'TARGET_CALL_COUNT=%s\n' "$target_call_count"
    printf 'ASSERTION_OCCURRENCE_COUNT=%s\n' "$assertion_count"
    printf 'ASSUME_FALSE_COUNT=%s\n' "$assume_false_count"

    if [[ "$target_call_count" != "1" ]]; then
        mark_fail "expected exactly one portable-C target call"
    fi

    if [[ "$assertion_count" -lt 1 ]]; then
        mark_fail "semantic assertion is missing"
    fi

    if [[ "$assume_false_count" != "0" ]]; then
        mark_fail "assume(false)-like construct detected"
    fi

    if grep -Eq \
        'USE_FUNCTION_CONTRACTS[[:space:]]*=[^[:space:]]+' \
        "$MAKEFILE"
    then
        mark_fail "function-contract replacement is enabled"
    fi

    if grep -Eq \
        'APPLY_LOOP_CONTRACTS[[:space:]]*=[[:space:]]*on' \
        "$MAKEFILE"
    then
        mark_fail "loop-contract abstraction is enabled"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 41
    fi

    printf 'T1_PREFLIGHT_FIREWALL=PASS\n'

    section "00B.8 — CBMC T1 SEMANTIC PREFLIGHT"

    printf 'COMMAND_BEGIN\n'
    printf 'cd %q\n' "$WORK_REPO/proofs/cbmc"
    printf 'MLKEM_K=3 ./run-cbmc-proofs.py --summarize -j1 -p %q --output-result-json %q\n' \
        "$PROOF_NAME" \
        "$RESULT_JSON"
    printf 'COMMAND_END\n'

    (
        cd "$WORK_REPO/proofs/cbmc" || exit 70

        MLKEM_K=3 \
        ./run-cbmc-proofs.py \
            --summarize \
            -j1 \
            -p "$PROOF_NAME" \
            --output-result-json "$RESULT_JSON"
    )

    PROOF_RUN_EXIT=$?

    printf 'T1_CBMC_RUN_EXIT=%s\n' "$PROOF_RUN_EXIT"

    if [[ "$PROOF_RUN_EXIT" -ne 0 ]]; then
        mark_fail "T1 CBMC semantic preflight did not complete successfully"
    fi

    if [[ -f "$RESULT_JSON" ]]; then
        printf 'RESULT_JSON=%s\n' "$RESULT_JSON"
        printf 'RESULT_JSON_SIZE=%s\n' \
            "$(stat -c '%s' "$RESULT_JSON" 2>/dev/null || printf unknown)"
        printf 'RESULT_JSON_SHA256=%s\n' \
            "$(sha256sum "$RESULT_JSON" | awk '{print $1}')"

        printf '\n--- result JSON tail ---\n'
        tail -n 120 "$RESULT_JSON" || true
    else
        printf 'RESULT_JSON=NOT_CREATED\n'
        mark_fail "CBMC runner did not create result JSON"
    fi

    section "00B.9 — POST-RUN SOURCE IMMUTABILITY"

    production_status="$(
        git -C "$WORK_REPO" \
        status --porcelain=v1 -- \
        mlkem/src 2>/dev/null ||
        true
    )"

    if [[ -n "$production_status" ]]; then
        printf '%s\n' "$production_status"
        mark_fail "production source changed during proof execution"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_AFTER=CLEAN\n'
    fi

    status_after="$(
        GIT_OPTIONAL_LOCKS=0 \
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
        status --porcelain=v1 --untracked-files=all 2>/dev/null ||
        true
    )"

    if [[ -n "$status_after" ]]; then
        printf '%s\n' "$status_after"
        mark_fail "authoritative source became dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE_AFTER=CLEAN\n'
    fi

    printf 'AUTHORITATIVE_HEAD_AFTER=%s\n' "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD
    )"

    section "POLYCOMP-D4-00B / T1 PREFLIGHT VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_00B_STATUS=PASS\n'
        printf 'T1_POSITIVE_PREFLIGHT_STATUS=PASS\n'
        printf 'NEXT_GATE=T1_NONVACUITY_AND_MUTATION_PREFLIGHT\n'
    else
        printf 'POLYCOMP_D4_00B_STATUS=FAIL\n'
        printf 'T1_POSITIVE_PREFLIGHT_STATUS=NOT_ACCEPTED\n'
        printf 'NEXT_GATE=DIAGNOSE_WITHOUT_CHANGING_AUTHORITATIVE_SOURCE\n'
    fi

    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'PROOF_DIR=%s\n' "$PROOF_DIR"
    printf 'HARNESS_FILE=%s\n' "$HARNESS_FILE"
    printf 'MAKEFILE=%s\n' "$MAKEFILE"
    printf 'SOURCE_MANIFEST=%s\n' "$SOURCE_MANIFEST"
    printf 'DERIVATION_FILE=%s\n' "$DERIVATION_FILE"
    printf 'REGISTRY_FILE=%s\n' "$REGISTRY_FILE"
    printf 'RESULT_JSON=%s\n' "$RESULT_JSON"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-00B CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
