#!/usr/bin/env bash
set -uo pipefail
shopt -s nullglob

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t2_20260725T172440Z"
CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"

STAGE_00A="${CAMPAIGN_ROOT}/POLYCOMP_D4_T2_00A_BOOTSTRAP_POSITIVE"
STAGE_00B="${CAMPAIGN_ROOT}/POLYCOMP_D4_T2_00B_CONTINUE_POSITIVE"
STAGE_00C="${CAMPAIGN_ROOT}/POLYCOMP_D4_T2_00C_NONVAC_MUT_RELATIONAL"

POSITIVE_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t2_decompress_refinement"
SWAP_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t2_mutation_nibble_swap_20260725T173345Z"
ROUND_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t2_mutation_rounding_minus_one_20260725T173345Z"
RELATIONAL_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t2_relational_byte_locality_20260725T173345Z"

POSITIVE_HARNESS="${POSITIVE_PROOF}/polycomp_d4_t2_decompress_refinement_harness.c"
POSITIVE_MAKEFILE="${POSITIVE_PROOF}/Makefile"
POSITIVE_GOTO="${POSITIVE_PROOF}/gotos/polycomp_d4_t2_decompress_refinement_harness.goto"

SWAP_HARNESS="${SWAP_PROOF}/polycomp_d4_t2_mutation_nibble_swap_harness.c"
SWAP_GOTO="${SWAP_PROOF}/gotos/polycomp_d4_t2_mutation_nibble_swap_harness.goto"

ROUND_HARNESS="${ROUND_PROOF}/polycomp_d4_t2_mutation_rounding_minus_one_harness.c"
ROUND_GOTO="${ROUND_PROOF}/gotos/polycomp_d4_t2_mutation_rounding_minus_one_harness.goto"

RELATIONAL_HARNESS="${RELATIONAL_PROOF}/polycomp_d4_t2_relational_byte_locality_harness.c"
RELATIONAL_GOTO="${RELATIONAL_PROOF}/gotos/polycomp_d4_t2_relational_byte_locality_harness.goto"

EXPECTED_POSITIVE_HARNESS_SHA256="9db3ca1461eadd68521a29595cd9c190042fd1236c3f6a88c97406d54fa1092e"
EXPECTED_POSITIVE_MAKEFILE_SHA256="bbf7ec804a2ad5520a61a1d633109ce0c2150ab3d3d6f07fd7580fe3281a2332"
EXPECTED_POSITIVE_GOTO_SHA256="7a091cfe8f06136809b195ff928f5b22c34b1dd0be6e7a93fdb4c8e5c6a2991b"

EXPECTED_SWAP_HARNESS_SHA256="b6a3bb3d12e314c88b472ebd1ed78c87e77d3d4033324639522d04c9591fbf5e"
EXPECTED_SWAP_GOTO_SHA256="126bd614f91b106917e89bc92b5f6b42c38ca80bab8173db774c4422808304d2"

EXPECTED_ROUND_HARNESS_SHA256="88fab1b8a10cee4a01713424cd71f7cc1c77e3d065d89543c040af386691b976"
EXPECTED_ROUND_GOTO_SHA256="41816d5d427a66c67985b795d1d910264a75494d34cfe339e1e331a1fb8fe31f"

EXPECTED_RELATIONAL_HARNESS_SHA256="829c83f18c801aad663d71a3857d6b0340df76841dbe80918674cf8fbb11b80d"
EXPECTED_RELATIONAL_GOTO_SHA256="9303382dc7a038efec70371758d66f9ea5190c6042036a4a64dc2d52022fddc0"

FINITE_DERIVATION="${STAGE_00A}/T2_FINITE_DERIVATION_20260725T172440Z.txt"
REGISTRY_EXTRACT="${STAGE_00A}/T2_REGISTRY_EXTRACT_20260725T172440Z.txt"

POSITIVE_SEMANTIC_JSON="${STAGE_00B}/T2_SEMANTIC_RESULT_20260725T172831Z.json"
POSITIVE_STRICT_JSON="${STAGE_00B}/T2_STRICT_RESULT_20260725T172831Z.json"
POSITIVE_LOOP_MAP="${STAGE_00B}/T2_LOOP_MAP_20260725T172831Z.txt"

COVERAGE_JSON="${STAGE_00C}/T2_LOCATION_COVERAGE_20260725T173345Z.json"
POSITIVE_REACH_JSON="${STAGE_00C}/T2_POSITIVE_END_REACHABILITY_20260725T173345Z.json"
SWAP_JSON="${STAGE_00C}/T2_SWAP_RESULT_20260725T173345Z.json"
ROUND_JSON="${STAGE_00C}/T2_ROUND_RESULT_20260725T173345Z.json"
RELATIONAL_SEMANTIC_JSON="${STAGE_00C}/T2_RELATIONAL_SEMANTIC_20260725T173345Z.json"
RELATIONAL_STRICT_JSON="${STAGE_00C}/T2_RELATIONAL_STRICT_20260725T173345Z.json"
RELATIONAL_REACH_JSON="${STAGE_00C}/T2_RELATIONAL_END_REACHABILITY_20260725T173345Z.json"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

FINAL_STAGE="${CAMPAIGN_ROOT}/POLYCOMP_D4_T2_00D_FINAL_FREEZE"
PACKAGE_NAME="POLYCOMP_D4_T2_FINAL_EVIDENCE_${UTC_STAMP}"
PACKAGE_DIR="${FINAL_STAGE}/${PACKAGE_NAME}"
ARCHIVE="${FINAL_STAGE}/${PACKAGE_NAME}.tar.gz"
ARCHIVE_HASH="${ARCHIVE}.sha256"

CAPTURE_FILE="${FINAL_STAGE}/POLYCOMP_D4_T2_00D_FINAL_FREEZE_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"
VALIDATION_FILE="${FINAL_STAGE}/T2_FINAL_VALIDATION_${UTC_STAMP}.txt"

FAIL=0
mkdir -p "$FINAL_STAGE"

section() {
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

mark_fail() {
    printf 'GATE_FAILURE: %s\n' "$1"
    FAIL=1
}

require_file() {
    if [[ ! -f "$1" ]]; then
        mark_fail "required file missing: $1"
        return 1
    fi
    return 0
}

require_dir() {
    if [[ ! -d "$1" ]]; then
        mark_fail "required directory missing: $1"
        return 1
    fi
    return 0
}

verify_hash() {
    local path="$1"
    local expected="$2"
    local label="$3"
    local actual

    actual="$(sha256sum "$path" | awk '{print $1}')"
    printf '%s_SHA256=%s\n' "$label" "$actual"

    if [[ "$actual" != "$expected" ]]; then
        mark_fail "$label hash mismatch"
        return 1
    fi
    return 0
}

copy_directory() {
    local source="$1"
    local destination="$2"

    require_dir "$source" || return 1
    mkdir -p "$destination"
    cp -a "$source"/. "$destination"/
}

main() {
    section "POLYCOMP-D4-T2-00D — FINAL EVIDENCE FREEZE"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'PACKAGE_DIR=%s\n' "$PACKAGE_DIR"
    printf 'ARCHIVE=%s\n' "$ARCHIVE"

    section "T2-00D.1 — SOURCE AND ARTEFACT BINDING"

    require_dir "$AUTHORITATIVE_SOURCE_PATH"
    require_dir "$WORK_REPO"

    for required in \
        "$POSITIVE_HARNESS" \
        "$POSITIVE_MAKEFILE" \
        "$POSITIVE_GOTO" \
        "$SWAP_HARNESS" \
        "$SWAP_GOTO" \
        "$ROUND_HARNESS" \
        "$ROUND_GOTO" \
        "$RELATIONAL_HARNESS" \
        "$RELATIONAL_GOTO"
    do
        require_file "$required"
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 20
    fi

    AUTHORITATIVE_HEAD="$(git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD 2>/dev/null || true)"
    WORK_HEAD="$(git -C "$WORK_REPO" rev-parse HEAD 2>/dev/null || true)"

    printf 'AUTHORITATIVE_HEAD=%s\n' "$AUTHORITATIVE_HEAD"
    printf 'WORK_REPO_HEAD=%s\n' "$WORK_HEAD"

    if [[ "$AUTHORITATIVE_HEAD" != "$EXPECTED_COMMIT" ]]; then
        mark_fail "authoritative source commit mismatch"
    fi

    if [[ "$WORK_HEAD" != "$EXPECTED_COMMIT" ]]; then
        mark_fail "work repository commit mismatch"
    fi

    if [[ -n "$(git -C "$AUTHORITATIVE_SOURCE_PATH" status --porcelain=v1 --untracked-files=all)" ]]; then
        mark_fail "authoritative source is dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE_BEFORE=CLEAN\n'
    fi

    if [[ -n "$(git -C "$WORK_REPO" status --porcelain=v1 -- mlkem/src)" ]]; then
        mark_fail "work-repository production source is modified"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_BEFORE=CLEAN\n'
    fi

    verify_hash "$POSITIVE_HARNESS" "$EXPECTED_POSITIVE_HARNESS_SHA256" "POSITIVE_HARNESS"
    verify_hash "$POSITIVE_MAKEFILE" "$EXPECTED_POSITIVE_MAKEFILE_SHA256" "POSITIVE_MAKEFILE"
    verify_hash "$POSITIVE_GOTO" "$EXPECTED_POSITIVE_GOTO_SHA256" "POSITIVE_GOTO"
    verify_hash "$SWAP_HARNESS" "$EXPECTED_SWAP_HARNESS_SHA256" "SWAP_HARNESS"
    verify_hash "$SWAP_GOTO" "$EXPECTED_SWAP_GOTO_SHA256" "SWAP_GOTO"
    verify_hash "$ROUND_HARNESS" "$EXPECTED_ROUND_HARNESS_SHA256" "ROUND_HARNESS"
    verify_hash "$ROUND_GOTO" "$EXPECTED_ROUND_GOTO_SHA256" "ROUND_GOTO"
    verify_hash "$RELATIONAL_HARNESS" "$EXPECTED_RELATIONAL_HARNESS_SHA256" "RELATIONAL_HARNESS"
    verify_hash "$RELATIONAL_GOTO" "$EXPECTED_RELATIONAL_GOTO_SHA256" "RELATIONAL_GOTO"

    for relpath in \
        mlkem/src/compress.c \
        mlkem/src/compress.h \
        mlkem/src/params.h \
        mlkem/src/poly.h \
        mlkem/src/cbmc.h \
        mlkem/src/verify.h
    do
        AUTH_HASH="$(sha256sum "${AUTHORITATIVE_SOURCE_PATH}/${relpath}" | awk '{print $1}')"
        WORK_HASH="$(sha256sum "${WORK_REPO}/${relpath}" | awk '{print $1}')"

        printf 'SOURCE_BINDING %s AUTH=%s WORK=%s\n' \
            "$relpath" "$AUTH_HASH" "$WORK_HASH"

        if [[ "$AUTH_HASH" != "$WORK_HASH" ]]; then
            mark_fail "source binding mismatch for $relpath"
        fi
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 21
    fi

    printf 'T2_FINAL_SOURCE_AND_ARTEFACT_BINDING=PASS\n'

    section "T2-00D.2 — REQUIRED EVIDENCE INVENTORY"

    for required_file in \
        "$FINITE_DERIVATION" \
        "$REGISTRY_EXTRACT" \
        "$POSITIVE_SEMANTIC_JSON" \
        "$POSITIVE_STRICT_JSON" \
        "$POSITIVE_LOOP_MAP" \
        "$COVERAGE_JSON" \
        "$POSITIVE_REACH_JSON" \
        "$SWAP_JSON" \
        "$ROUND_JSON" \
        "$RELATIONAL_SEMANTIC_JSON" \
        "$RELATIONAL_STRICT_JSON" \
        "$RELATIONAL_REACH_JSON"
    do
        require_file "$required_file"
    done

    for required_dir in \
        "$STAGE_00A" \
        "$STAGE_00B" \
        "$STAGE_00C" \
        "$POSITIVE_PROOF" \
        "$SWAP_PROOF" \
        "$ROUND_PROOF" \
        "$RELATIONAL_PROOF"
    do
        require_dir "$required_dir"
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 30
    fi

    printf 'T2_REQUIRED_EVIDENCE_INVENTORY=PASS\n'

    section "T2-00D.3 — MACHINE VALIDATION OF FINAL CLAIMS"

    python3 - \
        "$FINITE_DERIVATION" \
        "$REGISTRY_EXTRACT" \
        "$POSITIVE_SEMANTIC_JSON" \
        "$POSITIVE_STRICT_JSON" \
        "$POSITIVE_LOOP_MAP" \
        "$COVERAGE_JSON" \
        "$POSITIVE_REACH_JSON" \
        "$SWAP_JSON" \
        "$ROUND_JSON" \
        "$RELATIONAL_SEMANTIC_JSON" \
        "$RELATIONAL_STRICT_JSON" \
        "$RELATIONAL_REACH_JSON" \
        "$VALIDATION_FILE" <<'PY'
import json
import sys
from pathlib import Path

(
    derivation_path,
    registry_path,
    positive_semantic_path,
    positive_strict_path,
    loop_map_path,
    coverage_path,
    positive_reach_path,
    swap_path,
    round_path,
    relational_semantic_path,
    relational_strict_path,
    relational_reach_path,
    validation_path,
) = map(Path, sys.argv[1:])

def load(path):
    return json.loads(path.read_text(encoding="utf-8"))

def entries(payload):
    return payload if isinstance(payload, list) else [payload]

def parse_properties(path):
    results = []
    statuses = []
    errors = []

    for entry in entries(load(path)):
        if not isinstance(entry, dict):
            continue

        if "cProverStatus" in entry:
            statuses.append(str(entry["cProverStatus"]))

        if isinstance(entry.get("result"), list):
            results.extend(
                item
                for item in entry["result"]
                if isinstance(item, dict)
            )

        if (
            entry.get("messageType") == "ERROR"
            and isinstance(entry.get("messageText"), str)
        ):
            errors.append(entry["messageText"])

    return results, statuses, errors

def by_property(path):
    results, statuses, errors = parse_properties(path)
    return (
        {
            str(item.get("property", "")): item
            for item in results
        },
        results,
        statuses,
        errors,
    )

def require_property(path, property_id, status):
    mapping, _, _, _ = by_property(path)
    item = mapping.get(property_id)

    assert item is not None, (
        str(path),
        property_id,
        "missing",
    )

    assert item.get("status") == status, (
        str(path),
        property_id,
        item.get("status"),
        status,
    )

def require_all_success(path, expected_count):
    _, results, statuses, errors = by_property(path)

    assert len(results) == expected_count, (
        str(path),
        len(results),
        expected_count,
    )

    assert not errors, (str(path), errors)

    assert all(
        item.get("status") == "SUCCESS"
        for item in results
    ), str(path)

    assert statuses, str(path)

    assert all(
        status.lower() == "success"
        for status in statuses
    ), (str(path), statuses)

derivation = derivation_path.read_text(encoding="utf-8")

for required in (
    "STATUS=PASS",
    "NIBBLE_DOMAIN=0..15",
    "DECOMPRESS4(v)=floor((3329*v+8)/16)",
    "CODEBOOK=0,208,416,624,832,1040,1248,1456,1665,1873,2081,2289,2497,2705,2913,3121",
    "IMAGE_RANGE=0..3121",
    "SCALAR_RETRACTION=PASS",
):
    assert required in derivation, required

registry = registry_path.read_text(encoding="utf-8")

for required in (
    "T2_ID=POLYCOMP-D4-T2",
    "T2_NAME=Portable-C unpacked decompressor refinement",
    "T2_DOMAIN=All 128-byte arrays",
    "full-polynomial-refinement",
    "exact-nibble-extraction",
    "exact-scalar-decompression",
    "image-membership",
    "relational-byte-locality",
):
    assert required in registry, required

loop_map = loop_map_path.read_text(encoding="utf-8")

for required in (
    "TOTAL_LOOP_COUNT=2",
    "HARNESS_LOOP_COUNT=1",
    "DECOMPRESSOR_LOOP_COUNT=1",
    "UNEXPECTED_LOOP_COUNT=0",
    "UNWINDSET=harness.0:257,mlk_poly_decompress_d4_c.0:129",
    "LOOP_MAP_STATUS=PASS",
):
    assert required in loop_map, required

require_property(
    positive_semantic_path,
    "harness.assertion.1",
    "SUCCESS",
)

require_property(
    positive_semantic_path,
    "harness.assertion.2",
    "SUCCESS",
)

require_property(
    positive_semantic_path,
    "mlk_poly_decompress_d4_c.assertion.1",
    "SUCCESS",
)

require_all_success(
    positive_strict_path,
    86,
)

coverage_payload = load(coverage_path)

goals = []
reported_covered = None
reported_total = None

for entry in entries(coverage_payload):
    if not isinstance(entry, dict):
        continue

    if isinstance(entry.get("goals"), list):
        goals.extend(
            goal
            for goal in entry["goals"]
            if isinstance(goal, dict)
        )

    if isinstance(entry.get("goalsCovered"), int):
        reported_covered = entry["goalsCovered"]

    if isinstance(entry.get("totalGoals"), int):
        reported_total = entry["totalGoals"]

assert len(goals) == 20, len(goals)
assert reported_covered == 20, reported_covered
assert reported_total == 20, reported_total

assert all(
    str(goal.get("status", "")).lower() == "satisfied"
    for goal in goals
)

positive_reach_map, _, _, _ = by_property(
    positive_reach_path
)

assert (
    positive_reach_map[
        "harness.assertion.1"
    ]["status"]
    == "SUCCESS"
)

assert (
    positive_reach_map[
        "harness.assertion.2"
    ]["status"]
    == "SUCCESS"
)

assert any(
    property_id.startswith("harness.assertion.")
    and property_id not in {
        "harness.assertion.1",
        "harness.assertion.2",
    }
    and item.get("status") == "FAILURE"
    for property_id, item in positive_reach_map.items()
)

for mutation_path in (
    swap_path,
    round_path,
):
    mutation_map, _, statuses, _ = by_property(
        mutation_path
    )

    assert (
        mutation_map[
            "harness.assertion.1"
        ]["status"]
        == "FAILURE"
    )

    assert (
        mutation_map[
            "harness.assertion.2"
        ]["status"]
        == "SUCCESS"
    )

    assert (
        mutation_map[
            "mlk_poly_decompress_d4_c.assertion.1"
        ]["status"]
        == "SUCCESS"
    )

    assert any(
        status.lower() == "failure"
        for status in statuses
    )

assert '"data": "8"' in round_path.read_text(
    encoding="utf-8"
)

require_property(
    relational_semantic_path,
    "harness.assertion.1",
    "SUCCESS",
)

require_property(
    relational_semantic_path,
    "harness.assertion.2",
    "SUCCESS",
)

require_property(
    relational_semantic_path,
    "mlk_poly_decompress_d4_c.assertion.1",
    "SUCCESS",
)

require_all_success(
    relational_strict_path,
    84,
)

relational_reach_map, _, _, _ = by_property(
    relational_reach_path
)

assert (
    relational_reach_map[
        "harness.assertion.1"
    ]["status"]
    == "SUCCESS"
)

assert (
    relational_reach_map[
        "harness.assertion.2"
    ]["status"]
    == "SUCCESS"
)

assert any(
    property_id.startswith("harness.assertion.")
    and property_id not in {
        "harness.assertion.1",
        "harness.assertion.2",
    }
    and item.get("status") == "FAILURE"
    for property_id, item in relational_reach_map.items()
)

lines = [
    "T2_FINAL_MACHINE_VALIDATION=PASS",
    "T2_DOMAIN=ALL_128_BYTE_ARRAYS",
    "POSITIVE_SEMANTIC_PROPERTIES=3/3 SUCCESS",
    "POSITIVE_STRICT_PROPERTIES=86/86 SUCCESS",
    "POSITIVE_LOOP_INVENTORY=2 EXPECTED LOOPS",
    "POSITIVE_UNWINDSET=harness.0:257,mlk_poly_decompress_d4_c.0:129",
    "LOCATION_COVERAGE=20/20 SATISFIED",
    "POSITIVE_END_REACHABILITY=PASS",
    "NIBBLE_SWAP_MUTATION_DETECTED=PASS",
    "ROUNDING_MINUS_ONE_MUTATION_DETECTED=PASS",
    "ROUNDING_WITNESS_NIBBLE_8=PRESENT",
    "RELATIONAL_SEMANTIC_PROPERTIES=3/3 SUCCESS",
    "RELATIONAL_STRICT_PROPERTIES=84/84 SUCCESS",
    "RELATIONAL_BYTE_LOCALITY=PASS",
    "RELATIONAL_END_REACHABILITY=PASS",
    "ALL_REGISTERED_T2_OBLIGATIONS=CHECKED",
]

validation_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(
    validation_path.read_text(encoding="utf-8"),
    end="",
)
PY

    VALIDATION_EXIT=$?

    printf 'T2_FINAL_VALIDATION_EXIT=%s\n' "$VALIDATION_EXIT"
    printf 'T2_FINAL_VALIDATION_FILE=%s\n' "$VALIDATION_FILE"

    if [[ "$VALIDATION_EXIT" -ne 0 ]]; then
        mark_fail "T2 final machine validation failed"
        return 40
    fi

    printf 'T2_FINAL_MACHINE_VALIDATION=PASS\n'

    section "T2-00D.4 — PACKAGE ASSEMBLY"

    if [[ -e "$PACKAGE_DIR" ]]; then
        mark_fail "new package path already exists"
        return 50
    fi

    mkdir -p \
        "$PACKAGE_DIR/source_binding" \
        "$PACKAGE_DIR/campaign_stages" \
        "$PACKAGE_DIR/proof_artefacts" \
        "$PACKAGE_DIR/metadata" \
        "$PACKAGE_DIR/scripts"

    cp -a \
        "$VALIDATION_FILE" \
        "$PACKAGE_DIR/FINAL_VALIDATION.txt"

    for relpath in \
        mlkem/src/compress.c \
        mlkem/src/compress.h \
        mlkem/src/params.h \
        mlkem/src/poly.h \
        mlkem/src/cbmc.h \
        mlkem/src/verify.h
    do
        mkdir -p \
            "$PACKAGE_DIR/source_binding/$(dirname "$relpath")"

        cp -a \
            "${AUTHORITATIVE_SOURCE_PATH}/${relpath}" \
            "$PACKAGE_DIR/source_binding/${relpath}"
    done

    copy_directory \
        "$STAGE_00A" \
        "$PACKAGE_DIR/campaign_stages/00A_BOOTSTRAP_AND_SOURCE_ANALYSIS"

    copy_directory \
        "$STAGE_00B" \
        "$PACKAGE_DIR/campaign_stages/00B_POSITIVE_SEMANTIC_AND_STRICT"

    copy_directory \
        "$STAGE_00C" \
        "$PACKAGE_DIR/campaign_stages/00C_NONVACUITY_MUTATIONS_RELATIONAL"

    copy_directory \
        "$POSITIVE_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/positive_decompressor_refinement"

    copy_directory \
        "$SWAP_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/mutation_nibble_swap"

    copy_directory \
        "$ROUND_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/mutation_rounding_minus_one"

    copy_directory \
        "$RELATIONAL_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/relational_byte_locality"

    for script_path in \
        /tmp/POLYCOMP_D4_T2_00A_BOOTSTRAP_POSITIVE.sh \
        /tmp/POLYCOMP_D4_T2_00B_CONTINUE_POSITIVE.sh \
        /tmp/POLYCOMP_D4_T2_00C_NONVAC_MUT_RELATIONAL.sh \
        /tmp/POLYCOMP_D4_T2_00D_FINAL_FREEZE.sh
    do
        if [[ -f "$script_path" ]]; then
            cp -a "$script_path" "$PACKAGE_DIR/scripts/"
        fi
    done

    git -C "$AUTHORITATIVE_SOURCE_PATH" \
        show -s --format=fuller "$EXPECTED_COMMIT" \
        > "$PACKAGE_DIR/metadata/GIT_COMMIT.txt"

    git -C "$AUTHORITATIVE_SOURCE_PATH" \
        remote -v \
        > "$PACKAGE_DIR/metadata/GIT_REMOTES.txt"

    {
        printf 'CBMC='
        cbmc --version 2>&1 || true

        printf 'GOTO_CC='
        goto-cc --version 2>&1 || true

        printf 'GOTO_INSTRUMENT='
        goto-instrument --version 2>&1 || true

        printf 'GCC='
        gcc --version 2>&1 | head -n 1 || true

        printf 'PYTHON='
        python3 --version 2>&1 || true

        printf 'MAKE='
        make --version 2>&1 | head -n 1 || true
    } > "$PACKAGE_DIR/metadata/TOOL_VERSIONS.txt"

    printf 'T2_PACKAGE_ASSEMBLY=PASS\n'

    section "T2-00D.5 — FINAL VERDICT AND LIMITATIONS"

    cat > "$PACKAGE_DIR/T2_FINAL_VERDICT.md" <<'VERDICT_EOF'
# POLYCOMP-D4-T2 Final Verification Verdict

## Status

**Accepted within the registered bounded portable-C verification scope.**

## Bound implementation

- Repository: `mlkem-native`
- Commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Configuration: ML-KEM-768 (`MLKEM_K=3`)
- Production target: `mlk_poly_decompress_d4_c`
- Production source modification: none
- Verification tool: CBMC 6.9.0

## Input domain

Every possible 128-byte input array is admitted. The positive harness contains
no input assumptions.

## Primary refinement theorem

For every byte index `i` in `0..127`, let:

```text
low  = input[i] & 0x0F
high = input[i] >> 4
```

and define:

```text
Decompress4(v) = floor((3329*v + 8) / 16).
```

The verified implementation satisfies:

```text
output.coeffs[2*i]     = Decompress4(low)
output.coeffs[2*i + 1] = Decompress4(high)
```

for every output coefficient.

## Verified obligations

1. Full 256-coefficient refinement.
2. Exact low-nibble extraction.
3. Exact high-nibble extraction.
4. Exact scalar decompression.
5. Canonical image membership.
6. Complete output overwrite independence.
7. Complete bounded loop plan:
   - harness loop: 257;
   - production decompressor loop: 129.
8. Positive strict checks: 86 of 86 successful.
9. Location coverage: 20 of 20 goals satisfied.
10. Positive end-of-harness reachability.
11. Nibble-extraction swap mutation detected.
12. Rounding constant `8` changed to `7` detected.
13. Relational byte locality:
    - equal input byte implies equal decoded low coefficient;
    - equal input byte implies equal decoded high coefficient.
14. Relational strict checks: 84 of 84 successful.
15. Relational end-of-harness reachability.

## Codebook

The exact decompressor image is:

```text
0, 208, 416, 624, 832, 1040, 1248, 1456,
1665, 1873, 2081, 2289, 2497, 2705, 2913, 3121
```

## Novelty boundary

The repository already contains HOL Light verification relating to the AVX2
assembly implementation. This package makes no claim that decompression
correctness was previously absent.

The contribution represented here is a separate clean-room CBMC campaign for
the pinned portable-C implementation, including full-polynomial refinement,
strict C-level checks, non-vacuity evidence, targeted mutation evidence and
relational byte locality.

## Excluded claims

This package does not establish:

- portable-C equivalence with the AVX2 or other native backend;
- correctness of assembly implementations;
- constant-time or side-channel security;
- compressor correctness except through separately frozen T1 evidence;
- end-to-end ML-KEM correctness;
- correctness of unrelated repository functions;
- ML-KEM-1024's different compression configuration.
VERDICT_EOF

    cat > "$PACKAGE_DIR/T2_FINAL_VERDICT.json" <<JSON_EOF
{
  "theorem_id": "POLYCOMP-D4-T2",
  "status": "accepted_within_registered_bounded_scope",
  "repository_commit": "${EXPECTED_COMMIT}",
  "configuration": "ML-KEM-768",
  "mlkem_k": 3,
  "target": "mlk_poly_decompress_d4_c",
  "production_source_modified": false,
  "input_domain": "all 128-byte arrays",
  "output_coefficients": 256,
  "positive_semantic_properties": {
    "successful": 3,
    "total": 3
  },
  "positive_strict_properties": {
    "successful": 86,
    "total": 86
  },
  "coverage": {
    "satisfied": 20,
    "total": 20
  },
  "relational_semantic_properties": {
    "successful": 3,
    "total": 3
  },
  "relational_strict_properties": {
    "successful": 84,
    "total": 84
  },
  "mutations_detected": [
    "nibble_extraction_swap",
    "rounding_constant_8_to_7"
  ],
  "relational_property": "equal input byte implies equality of both corresponding decompressed coefficients",
  "novelty_boundary": "portable-C CBMC campaign; no claim of novelty over existing AVX2 HOL Light verification"
}
JSON_EOF

    cat > "$PACKAGE_DIR/README.md" <<'README_EOF'
# POLYCOMP-D4-T2 Evidence Package

This package contains the clean-room CBMC evidence for the portable-C D4
decompressor refinement theorem.

Recommended reading order:

1. `T2_FINAL_VERDICT.md`
2. `FINAL_VALIDATION.txt`
3. `SHA256SUMS.txt`
4. `metadata/`
5. `campaign_stages/`
6. `proof_artefacts/`

The failed static-count gate in stage 00A is retained as diagnostic provenance.
It counted the `__CPROVER_assert` declaration in addition to the two real
assertion calls. Stage 00B corrected that parser without altering the harness
or production source.
README_EOF

    printf 'T2_FINAL_VERDICT_WRITTEN=PASS\n'

    section "T2-00D.6 — PACKAGE TREE AND SHA-256 MANIFEST"

    (
        cd "$PACKAGE_DIR" || exit 70

        find . \
            -mindepth 1 \
            -printf '%y %p\n' |
            LC_ALL=C sort
    ) > "$PACKAGE_DIR/PACKAGE_TREE.txt"

    (
        cd "$PACKAGE_DIR" || exit 71

        find . \
            -type f \
            ! -name 'SHA256SUMS.txt' \
            ! -name 'MANIFEST_SHA256.txt' \
            -print0 |
        LC_ALL=C sort -z |
        xargs -0 sha256sum
    ) > "$PACKAGE_DIR/SHA256SUMS.txt"

    (
        cd "$PACKAGE_DIR" || exit 72
        sha256sum SHA256SUMS.txt
    ) > "$PACKAGE_DIR/MANIFEST_SHA256.txt"

    PACKAGE_FILE_COUNT="$(
        find "$PACKAGE_DIR" -type f | wc -l
    )"

    MANIFEST_ENTRY_COUNT="$(
        wc -l < "$PACKAGE_DIR/SHA256SUMS.txt"
    )"

    printf 'PACKAGE_FILE_COUNT=%s\n' "$PACKAGE_FILE_COUNT"
    printf 'MANIFEST_ENTRY_COUNT=%s\n' "$MANIFEST_ENTRY_COUNT"

    if [[ "$MANIFEST_ENTRY_COUNT" -lt 40 ]]; then
        mark_fail "package contains unexpectedly few files"
        return 60
    fi

    (
        cd "$PACKAGE_DIR" || exit 73
        sha256sum -c SHA256SUMS.txt
        sha256sum -c MANIFEST_SHA256.txt
    ) > "$FINAL_STAGE/PRE_ARCHIVE_VERIFICATION_${UTC_STAMP}.txt" 2>&1

    PRE_ARCHIVE_EXIT=$?

    printf 'PRE_ARCHIVE_VERIFY_EXIT=%s\n' "$PRE_ARCHIVE_EXIT"

    if [[ "$PRE_ARCHIVE_EXIT" -ne 0 ]]; then
        cat "$FINAL_STAGE/PRE_ARCHIVE_VERIFICATION_${UTC_STAMP}.txt"
        mark_fail "pre-archive verification failed"
        return 61
    fi

    printf 'T2_PACKAGE_MANIFEST_VERIFICATION=PASS\n'

    section "T2-00D.7 — DETERMINISTIC ARCHIVE AND EXTRACTION CHECK"

    tar \
        --sort=name \
        --mtime='UTC 2026-07-25 00:00:00' \
        --owner=0 \
        --group=0 \
        --numeric-owner \
        -czf "$ARCHIVE" \
        -C "$FINAL_STAGE" \
        "$PACKAGE_NAME"

    TAR_EXIT=$?

    printf 'TAR_EXIT=%s\n' "$TAR_EXIT"

    if [[ "$TAR_EXIT" -ne 0 || ! -f "$ARCHIVE" ]]; then
        mark_fail "could not create T2 archive"
        return 70
    fi

    sha256sum "$ARCHIVE" > "$ARCHIVE_HASH"

    printf 'ARCHIVE_SIZE=%s\n' "$(stat -c '%s' "$ARCHIVE")"
    printf 'ARCHIVE_SHA256=%s\n' "$(awk '{print $1}' "$ARCHIVE_HASH")"

    VERIFY_DIR="${FINAL_STAGE}/verify_${UTC_STAMP}"

    rm -rf "$VERIFY_DIR"
    mkdir -p "$VERIFY_DIR"

    tar -xzf "$ARCHIVE" -C "$VERIFY_DIR"

    EXTRACTED_PACKAGE="${VERIFY_DIR}/${PACKAGE_NAME}"

    (
        cd "$EXTRACTED_PACKAGE" || exit 80
        sha256sum -c SHA256SUMS.txt
        sha256sum -c MANIFEST_SHA256.txt
    ) > "$FINAL_STAGE/POST_ARCHIVE_VERIFICATION_${UTC_STAMP}.txt" 2>&1

    POST_ARCHIVE_EXIT=$?

    printf 'POST_ARCHIVE_VERIFY_EXIT=%s\n' "$POST_ARCHIVE_EXIT"

    if [[ "$POST_ARCHIVE_EXIT" -ne 0 ]]; then
        cat "$FINAL_STAGE/POST_ARCHIVE_VERIFICATION_${UTC_STAMP}.txt"
        mark_fail "post-archive verification failed"
        return 71
    fi

    chmod -R u+rwX "$VERIFY_DIR" 2>/dev/null || true
    rm -rf "$VERIFY_DIR"

    if [[ -e "$VERIFY_DIR" ]]; then
        mark_fail "temporary extraction cleanup failed"
        return 72
    fi

    printf 'POST_ARCHIVE_MANIFEST_VERIFICATION=PASS\n'
    printf 'TEMPORARY_EXTRACTION_CLEANUP=PASS\n'

    section "T2-00D.8 — FINAL SOURCE IMMUTABILITY AND READ-ONLY FREEZE"

    if [[ -n "$(git -C "$AUTHORITATIVE_SOURCE_PATH" status --porcelain=v1 --untracked-files=all)" ]]; then
        mark_fail "authoritative source became dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE_AFTER=CLEAN\n'
    fi

    if [[ -n "$(git -C "$WORK_REPO" status --porcelain=v1 -- mlkem/src)" ]]; then
        mark_fail "work-repository production source became dirty"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_AFTER=CLEAN\n'
    fi

    printf 'AUTHORITATIVE_HEAD_AFTER=%s\n' "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD
    )"

    printf 'WORK_REPO_HEAD_AFTER=%s\n' "$(
        git -C "$WORK_REPO" rev-parse HEAD
    )"

    if [[ "$FAIL" -eq 0 ]]; then
        chmod -R a-w "$PACKAGE_DIR"
        printf 'PACKAGE_READ_ONLY_FREEZE=PASS\n'
    fi

    section "POLYCOMP-D4-T2-00D FINAL VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_T2_00D_STATUS=PASS\n'
        printf 'T2_FINAL_EVIDENCE_FREEZE=PASS\n'
        printf 'T2_FINAL_THEOREM_STATUS=ACCEPTED_WITHIN_REGISTERED_BOUNDED_SCOPE\n'
        printf 'ALL_REGISTERED_T2_OBLIGATIONS=VERIFIED\n'
        printf 'FINAL_PACKAGE=%s\n' "$ARCHIVE"
        printf 'FINAL_PACKAGE_SHA256_FILE=%s\n' "$ARCHIVE_HASH"
        printf 'NEXT_GATE=INDEPENDENT_BYTE_LEVEL_PACKAGE_INSPECTION\n'
    else
        printf 'POLYCOMP_D4_T2_00D_STATUS=FAIL\n'
        printf 'T2_FINAL_EVIDENCE_FREEZE=NOT_ACCEPTED\n'
    fi

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-T2-00D CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
