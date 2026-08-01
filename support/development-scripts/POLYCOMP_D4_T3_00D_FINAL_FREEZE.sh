#!/usr/bin/env bash
set -uo pipefail
shopt -s nullglob

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t3_20260726T020556Z"
CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"

STAGE_00A="${CAMPAIGN_ROOT}/POLYCOMP_D4_T3_00A_BOOTSTRAP_POSITIVE"
STAGE_00B="${CAMPAIGN_ROOT}/POLYCOMP_D4_T3_00B_CORRECTED_LOOP_PREFLIGHT"
STAGE_00C="${CAMPAIGN_ROOT}/POLYCOMP_D4_T3_00C_NONVAC_MUT_NIBBLE_CYCLE"

POSITIVE_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t3_compressed_domain_retraction"
NIBBLE_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t3_nibble_preservation_20260726T022113Z"
CYCLE_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t3_cycle_stability_20260726T022113Z"
DECOMP_MUT_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t3_mutation_decompress_side_20260726T022113Z"
COMP_MUT_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t3_mutation_compress_side_20260726T022113Z"

POSITIVE_HARNESS="${POSITIVE_PROOF}/polycomp_d4_t3_compressed_domain_retraction_harness.c"
POSITIVE_MAKEFILE="${POSITIVE_PROOF}/Makefile"
POSITIVE_GOTO="${POSITIVE_PROOF}/gotos/polycomp_d4_t3_compressed_domain_retraction_harness.goto"

NIBBLE_HARNESS="${NIBBLE_PROOF}/polycomp_d4_t3_nibble_preservation_harness.c"
NIBBLE_GOTO="${NIBBLE_PROOF}/gotos/polycomp_d4_t3_nibble_preservation_harness.goto"

CYCLE_HARNESS="${CYCLE_PROOF}/polycomp_d4_t3_cycle_stability_harness.c"
CYCLE_GOTO="${CYCLE_PROOF}/gotos/polycomp_d4_t3_cycle_stability_harness.goto"

DECOMP_MUT_HARNESS="${DECOMP_MUT_PROOF}/polycomp_d4_t3_mutation_decompress_side_harness.c"
DECOMP_MUT_GOTO="${DECOMP_MUT_PROOF}/gotos/polycomp_d4_t3_mutation_decompress_side_harness.goto"

COMP_MUT_HARNESS="${COMP_MUT_PROOF}/polycomp_d4_t3_mutation_compress_side_harness.c"
COMP_MUT_GOTO="${COMP_MUT_PROOF}/gotos/polycomp_d4_t3_mutation_compress_side_harness.goto"

EXPECTED_POSITIVE_HARNESS_SHA256="caf64341e43db7abf668241e4012d4ab1064536fd3237d0577826e4728c7ea8f"
EXPECTED_POSITIVE_MAKEFILE_SHA256="02ef8132f84ade6447e7139d1ea1840443e349eb88a6fef74983a54f6ef21654"
EXPECTED_POSITIVE_GOTO_SHA256="6d35b9b1dac6fabf8f7fd207e9f9b116912e0351f30a543066dfd48d98bcc9c8"

EXPECTED_NIBBLE_HARNESS_SHA256="29ed3bbd3d6572ffc0992985fe9a9442f54bbd671318f9b853401af9832c8994"
EXPECTED_NIBBLE_GOTO_SHA256="d12a0d4ca4e5e81961c9cda150a6283d5e71321f7a8d21ec7e1c3958b48875f6"

EXPECTED_CYCLE_HARNESS_SHA256="5ac30c62a14830d387890b9870f842f76be6b4905268a00ea7bc83420f320893"
EXPECTED_CYCLE_GOTO_SHA256="7044abdb19858f9488e3ec80c2dee0334ca8127d1a8ecee2413aaea57f01670a"

EXPECTED_DECOMP_MUT_HARNESS_SHA256="8bff7c7616e8cbe2eaa4c2d535345d95715b882c7e95995a6a400897253eb02b"
EXPECTED_DECOMP_MUT_GOTO_SHA256="53ce0d3b70b18a61e11b50cb9c921436f23fed360be2a049190a6cec83805a43"

EXPECTED_COMP_MUT_HARNESS_SHA256="ae8ba5c834488f43a9b7eb0154415c7d4a843418ffcb2130fe378805d89e62a1"
EXPECTED_COMP_MUT_GOTO_SHA256="7f52b0da2dfaf78817bf5e9b3dbfc487f4a5e36feb4e4857d801fcaa551b9d8f"

FINITE_DERIVATION="${STAGE_00A}/T3_FINITE_DERIVATION_20260726T020556Z.txt"
REGISTRY_EXTRACT="${STAGE_00A}/T3_REGISTRY_EXTRACT_20260726T020556Z.txt"
SOURCE_CAPTURE="${STAGE_00A}/T3_SOURCE_CAPTURE_20260726T020556Z.txt"
OVERLAP_CAPTURE="${STAGE_00A}/T3_NATIVE_OVERLAP_CAPTURE_20260726T020556Z.txt"

POSITIVE_SEMANTIC_JSON="${STAGE_00B}/T3_SEMANTIC_RESULT_20260726T021122Z.json"
POSITIVE_STRICT_JSON="${STAGE_00B}/T3_STRICT_RESULT_20260726T021122Z.json"
POSITIVE_LOOP_MAP="${STAGE_00B}/T3_LOOP_MAP_20260726T021122Z.txt"

COVERAGE_JSON="${STAGE_00C}/T3_LOCATION_COVERAGE_20260726T022113Z.json"
POSITIVE_REACH_JSON="${STAGE_00C}/T3_POSITIVE_END_REACHABILITY_20260726T022113Z.json"

NIBBLE_SEMANTIC_JSON="${STAGE_00C}/T3_NIBBLE_SEMANTIC_20260726T022113Z.json"
NIBBLE_STRICT_JSON="${STAGE_00C}/T3_NIBBLE_STRICT_20260726T022113Z.json"

CYCLE_SEMANTIC_JSON="${STAGE_00C}/T3_CYCLE_SEMANTIC_20260726T022113Z.json"
CYCLE_STRICT_JSON="${STAGE_00C}/T3_CYCLE_STRICT_20260726T022113Z.json"

DECOMP_MUT_JSON="${STAGE_00C}/T3_DECOMP_MUT_RESULT_20260726T022113Z.json"
COMP_MUT_JSON="${STAGE_00C}/T3_COMP_MUT_RESULT_20260726T022113Z.json"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

FINAL_STAGE="${CAMPAIGN_ROOT}/POLYCOMP_D4_T3_00D_FINAL_FREEZE"
PACKAGE_NAME="POLYCOMP_D4_T3_FINAL_EVIDENCE_${UTC_STAMP}"
PACKAGE_DIR="${FINAL_STAGE}/${PACKAGE_NAME}"
ARCHIVE="${FINAL_STAGE}/${PACKAGE_NAME}.tar.gz"
ARCHIVE_HASH="${ARCHIVE}.sha256"

VALIDATION_FILE="${FINAL_STAGE}/T3_FINAL_VALIDATION_${UTC_STAMP}.txt"
CAPTURE_FILE="${FINAL_STAGE}/POLYCOMP_D4_T3_00D_FINAL_FREEZE_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

FAIL=0
mkdir -p "$FINAL_STAGE"

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

require_file()
{
    if [[ ! -f "$1" ]]; then
        mark_fail "required file missing: $1"
        return 1
    fi
    return 0
}

require_dir()
{
    if [[ ! -d "$1" ]]; then
        mark_fail "required directory missing: $1"
        return 1
    fi
    return 0
}

verify_hash()
{
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

copy_directory()
{
    local source="$1"
    local destination="$2"

    require_dir "$source" || return 1
    mkdir -p "$destination"
    cp -a "$source"/. "$destination"/
}

find_script()
{
    local name="$1"
    local candidate

    for candidate in \
        "${HOME}/Downloads/${name}" \
        "/tmp/${name}" \
        "${HOME}/${name}"
    do
        if [[ -f "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

main()
{
    section "POLYCOMP-D4-T3-00D — FINAL EVIDENCE FREEZE"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'PACKAGE_DIR=%s\n' "$PACKAGE_DIR"
    printf 'ARCHIVE=%s\n' "$ARCHIVE"

    section "T3-00D.1 — SOURCE AND ARTEFACT BINDING"

    require_dir "$AUTHORITATIVE_SOURCE_PATH"
    require_dir "$WORK_REPO"

    for required in \
        "$POSITIVE_HARNESS" \
        "$POSITIVE_MAKEFILE" \
        "$POSITIVE_GOTO" \
        "$NIBBLE_HARNESS" \
        "$NIBBLE_GOTO" \
        "$CYCLE_HARNESS" \
        "$CYCLE_GOTO" \
        "$DECOMP_MUT_HARNESS" \
        "$DECOMP_MUT_GOTO" \
        "$COMP_MUT_HARNESS" \
        "$COMP_MUT_GOTO"
    do
        require_file "$required"
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 20
    fi

    AUTHORITATIVE_HEAD="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD 2>/dev/null ||
        true
    )"

    WORK_HEAD="$(
        git -C "$WORK_REPO" rev-parse HEAD 2>/dev/null ||
        true
    )"

    printf 'AUTHORITATIVE_HEAD=%s\n' "$AUTHORITATIVE_HEAD"
    printf 'WORK_REPO_HEAD=%s\n' "$WORK_HEAD"

    if [[ "$AUTHORITATIVE_HEAD" != "$EXPECTED_COMMIT" ||
          "$WORK_HEAD" != "$EXPECTED_COMMIT" ]]
    then
        mark_fail "repository commit mismatch"
    fi

    if [[ -n "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            status --porcelain=v1 --untracked-files=all
    )" ]]
    then
        mark_fail "authoritative source is dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE_BEFORE=CLEAN\n'
    fi

    if [[ -n "$(
        git -C "$WORK_REPO" \
            status --porcelain=v1 -- mlkem/src
    )" ]]
    then
        mark_fail "work-repository production source is modified"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_BEFORE=CLEAN\n'
    fi

    verify_hash "$POSITIVE_HARNESS" "$EXPECTED_POSITIVE_HARNESS_SHA256" "POSITIVE_HARNESS"
    verify_hash "$POSITIVE_MAKEFILE" "$EXPECTED_POSITIVE_MAKEFILE_SHA256" "POSITIVE_MAKEFILE"
    verify_hash "$POSITIVE_GOTO" "$EXPECTED_POSITIVE_GOTO_SHA256" "POSITIVE_GOTO"

    verify_hash "$NIBBLE_HARNESS" "$EXPECTED_NIBBLE_HARNESS_SHA256" "NIBBLE_HARNESS"
    verify_hash "$NIBBLE_GOTO" "$EXPECTED_NIBBLE_GOTO_SHA256" "NIBBLE_GOTO"

    verify_hash "$CYCLE_HARNESS" "$EXPECTED_CYCLE_HARNESS_SHA256" "CYCLE_HARNESS"
    verify_hash "$CYCLE_GOTO" "$EXPECTED_CYCLE_GOTO_SHA256" "CYCLE_GOTO"

    verify_hash "$DECOMP_MUT_HARNESS" "$EXPECTED_DECOMP_MUT_HARNESS_SHA256" "DECOMP_MUT_HARNESS"
    verify_hash "$DECOMP_MUT_GOTO" "$EXPECTED_DECOMP_MUT_GOTO_SHA256" "DECOMP_MUT_GOTO"

    verify_hash "$COMP_MUT_HARNESS" "$EXPECTED_COMP_MUT_HARNESS_SHA256" "COMP_MUT_HARNESS"
    verify_hash "$COMP_MUT_GOTO" "$EXPECTED_COMP_MUT_GOTO_SHA256" "COMP_MUT_GOTO"

    for relpath in \
        mlkem/src/compress.c \
        mlkem/src/compress.h \
        mlkem/src/params.h \
        mlkem/src/poly.h \
        mlkem/src/cbmc.h \
        mlkem/src/verify.h
    do
        AUTH_HASH="$(
            sha256sum "${AUTHORITATIVE_SOURCE_PATH}/${relpath}" |
            awk '{print $1}'
        )"

        WORK_HASH="$(
            sha256sum "${WORK_REPO}/${relpath}" |
            awk '{print $1}'
        )"

        printf 'SOURCE_BINDING %s AUTH=%s WORK=%s\n' \
            "$relpath" "$AUTH_HASH" "$WORK_HASH"

        if [[ "$AUTH_HASH" != "$WORK_HASH" ]]; then
            mark_fail "source binding mismatch for $relpath"
        fi
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 21
    fi

    printf 'T3_FINAL_SOURCE_AND_ARTEFACT_BINDING=PASS\n'

    section "T3-00D.2 — REQUIRED EVIDENCE INVENTORY"

    for required_file in \
        "$FINITE_DERIVATION" \
        "$REGISTRY_EXTRACT" \
        "$SOURCE_CAPTURE" \
        "$OVERLAP_CAPTURE" \
        "$POSITIVE_SEMANTIC_JSON" \
        "$POSITIVE_STRICT_JSON" \
        "$POSITIVE_LOOP_MAP" \
        "$COVERAGE_JSON" \
        "$POSITIVE_REACH_JSON" \
        "$NIBBLE_SEMANTIC_JSON" \
        "$NIBBLE_STRICT_JSON" \
        "$CYCLE_SEMANTIC_JSON" \
        "$CYCLE_STRICT_JSON" \
        "$DECOMP_MUT_JSON" \
        "$COMP_MUT_JSON"
    do
        require_file "$required_file"
    done

    for required_dir in \
        "$STAGE_00A" \
        "$STAGE_00B" \
        "$STAGE_00C" \
        "$POSITIVE_PROOF" \
        "$NIBBLE_PROOF" \
        "$CYCLE_PROOF" \
        "$DECOMP_MUT_PROOF" \
        "$COMP_MUT_PROOF"
    do
        require_dir "$required_dir"
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 30
    fi

    printf 'T3_REQUIRED_EVIDENCE_INVENTORY=PASS\n'

    section "T3-00D.3 — EXACT EXECUTED SCRIPT INVENTORY"

    declare -a SCRIPT_NAMES=(
        "POLYCOMP_D4_T3_00A_BOOTSTRAP_POSITIVE.sh"
        "POLYCOMP_D4_T3_00B_CORRECTED_LOOP_PREFLIGHT.sh"
        "POLYCOMP_D4_T3_00C_NONVAC_MUT_NIBBLE_CYCLE.sh"
        "POLYCOMP_D4_T3_00D_FINAL_FREEZE.sh"
    )

    declare -a SCRIPT_PATHS=()

    for name in "${SCRIPT_NAMES[@]}"
    do
        if ! source_path="$(find_script "$name")"; then
            mark_fail "exact executed script unavailable: $name"
            continue
        fi

        if ! bash -n "$source_path"; then
            mark_fail "script syntax validation failed: $source_path"
            continue
        fi

        printf 'SCRIPT_PRESENT=%s\n' "$source_path"
        printf 'SCRIPT_SHA256=%s|%s\n' \
            "$(sha256sum "$source_path" | awk '{print $1}')" \
            "$name"

        SCRIPT_PATHS+=("$source_path")
    done

    printf 'EXACT_SCRIPT_COUNT=%s\n' "${#SCRIPT_PATHS[@]}"

    if [[ "${#SCRIPT_PATHS[@]}" -ne 4 ]]; then
        mark_fail "all four exact T3 scripts are required before final freeze"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 31
    fi

    printf 'T3_EXACT_EXECUTED_SCRIPT_INVENTORY=PASS\n'

    section "T3-00D.4 — MACHINE VALIDATION OF FINAL CLAIMS"

    python3 - \
        "$FINITE_DERIVATION" \
        "$REGISTRY_EXTRACT" \
        "$POSITIVE_SEMANTIC_JSON" \
        "$POSITIVE_STRICT_JSON" \
        "$POSITIVE_LOOP_MAP" \
        "$COVERAGE_JSON" \
        "$POSITIVE_REACH_JSON" \
        "$NIBBLE_SEMANTIC_JSON" \
        "$NIBBLE_STRICT_JSON" \
        "$CYCLE_SEMANTIC_JSON" \
        "$CYCLE_STRICT_JSON" \
        "$DECOMP_MUT_JSON" \
        "$COMP_MUT_JSON" \
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
    nibble_semantic_path,
    nibble_strict_path,
    cycle_semantic_path,
    cycle_strict_path,
    decomp_mut_path,
    comp_mut_path,
    validation_path,
) = map(Path, sys.argv[1:])

MAIN_DESCRIPTION = (
    "POLYCOMP-D4-T3: compressing the real D4 decompression "
    "reconstructs every original input byte"
)

LOW_DESCRIPTION = (
    "POLYCOMP-D4-T3 nibble preservation: "
    "every low nibble is preserved"
)

HIGH_DESCRIPTION = (
    "POLYCOMP-D4-T3 nibble preservation: "
    "every high nibble is preserved"
)

CYCLE_DESCRIPTION = (
    "POLYCOMP-D4-T3 cycle stability: a second real "
    "decompression-compression cycle is byte-stable"
)

def load(path):
    return json.loads(path.read_text(encoding="utf-8"))

def entries(payload):
    return payload if isinstance(payload, list) else [payload]

def parse(path):
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

def by_description(path):
    results, statuses, errors = parse(path)

    mapping = {}

    for item in results:
        description = str(item.get("description", ""))
        mapping.setdefault(description, []).append(item)

    return mapping, results, statuses, errors

def require_description(path, description, status):
    mapping, _, _, _ = by_description(path)
    matches = mapping.get(description, [])

    assert len(matches) == 1, (
        str(path),
        description,
        len(matches),
    )

    assert matches[0].get("status") == status, (
        str(path),
        description,
        matches[0].get("status"),
        status,
    )

def require_all_success(path, expected_count):
    _, results, statuses, errors = by_description(path)

    assert len(results) == expected_count, (
        str(path),
        len(results),
        expected_count,
    )

    assert not errors, (str(path), errors)
    assert results
    assert all(item.get("status") == "SUCCESS" for item in results)
    assert statuses
    assert all(status.lower() == "success" for status in statuses)

derivation = derivation_path.read_text(encoding="utf-8")

for required in (
    "BYTE_DOMAIN=0..255",
    "NIBBLE_DOMAIN=0..15",
    "SCALAR_RETRACTION=PASS",
    "BYTE_RETRACTION_FAILURE_COUNT=0",
    "ALL_256_PACKED_BYTES_RECONSTRUCT=PASS",
    "STATUS=PASS",
):
    assert required in derivation, required

registry = registry_path.read_text(encoding="utf-8")

for required in (
    "T3_ID=POLYCOMP-D4-T3",
    "T3_NAME=Exact compressed-domain retraction",
    "T3_DOMAIN=All 128-byte arrays",
    "byte-identity",
    "nibble-preservation",
    "cycle-stability",
):
    assert required in registry, required

loop_map = loop_map_path.read_text(encoding="utf-8")

for required in (
    "TOTAL_LOOP_COUNT=4",
    "HARNESS_LOOP_COUNT=1",
    "COMPRESSOR_LOOP_COUNT=2",
    "DECOMPRESSOR_LOOP_COUNT=1",
    "UNEXPECTED_LOOP_COUNT=0",
    "LOOP_LOCATION_BINDING=PASS",
    "LOOP_MAP_STATUS=PASS",
    "UNWINDSET=harness.0:129,mlk_poly_compress_d4_c.0:129,mlk_poly_compress_d4_c.1:257,mlk_poly_decompress_d4_c.0:129",
):
    assert required in loop_map, required

require_description(
    positive_semantic_path,
    MAIN_DESCRIPTION,
    "SUCCESS",
)

require_all_success(
    positive_strict_path,
    186,
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

assert len(goals) == 25, len(goals)
assert reported_covered == 25, reported_covered
assert reported_total == 25, reported_total

assert all(
    str(goal.get("status", "")).lower() == "satisfied"
    for goal in goals
)

reach_mapping, _, _, _ = by_description(
    positive_reach_path
)

main_reach = reach_mapping.get(MAIN_DESCRIPTION, [])
assert len(main_reach) == 1
assert main_reach[0].get("status") == "SUCCESS"

_, reach_results, _, _ = by_description(
    positive_reach_path
)

assert any(
    item.get("status") == "FAILURE"
    and str(item.get("description", "")) != MAIN_DESCRIPTION
    for item in reach_results
)

require_description(
    nibble_semantic_path,
    LOW_DESCRIPTION,
    "SUCCESS",
)

require_description(
    nibble_semantic_path,
    HIGH_DESCRIPTION,
    "SUCCESS",
)

require_all_success(
    nibble_strict_path,
    187,
)

require_description(
    cycle_semantic_path,
    CYCLE_DESCRIPTION,
    "SUCCESS",
)

require_all_success(
    cycle_strict_path,
    186,
)

for mutation_path in (
    decomp_mut_path,
    comp_mut_path,
):
    mutation_mapping, mutation_results, statuses, errors = (
        by_description(mutation_path)
    )

    matches = mutation_mapping.get(MAIN_DESCRIPTION, [])

    assert len(matches) == 1
    assert matches[0].get("status") == "FAILURE"
    assert not errors
    assert any(status.lower() == "failure" for status in statuses)

    assert all(
        item.get("status") == "SUCCESS"
        for item in mutation_results
        if str(item.get("description", "")) != MAIN_DESCRIPTION
    )

lines = [
    "T3_FINAL_MACHINE_VALIDATION=PASS",
    "T3_DOMAIN=ALL_128_BYTE_ARRAYS",
    "FINITE_NIBBLE_RETRACTION=16/16 PASS",
    "FINITE_BYTE_RETRACTION=256/256 PASS",
    "POSITIVE_SEMANTIC_MAIN_PROPERTY=SUCCESS",
    "POSITIVE_STRICT_PROPERTIES=186/186 SUCCESS",
    "LOOP_INVENTORY=4/4 EXPECTED",
    "LOCATION_COVERAGE=25/25 SATISFIED",
    "POSITIVE_END_REACHABILITY=PASS",
    "NIBBLE_SEMANTIC_PROPERTIES=2/2 SUCCESS",
    "NIBBLE_STRICT_PROPERTIES=187/187 SUCCESS",
    "CYCLE_SEMANTIC_PROPERTY=SUCCESS",
    "CYCLE_STRICT_PROPERTIES=186/186 SUCCESS",
    "DECOMPRESSION_SIDE_MUTATION_DETECTED=PASS",
    "COMPRESSION_SIDE_MUTATION_DETECTED=PASS",
    "ALL_REGISTERED_T3_OBLIGATIONS=CHECKED",
]

validation_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(validation_path.read_text(encoding="utf-8"), end="")
PY

    VALIDATION_EXIT=$?

    printf 'T3_FINAL_VALIDATION_EXIT=%s\n' "$VALIDATION_EXIT"
    printf 'T3_FINAL_VALIDATION_FILE=%s\n' "$VALIDATION_FILE"

    if [[ "$VALIDATION_EXIT" -ne 0 ]]; then
        mark_fail "T3 final machine validation failed"
        return 40
    fi

    printf 'T3_FINAL_MACHINE_VALIDATION=PASS\n'

    section "T3-00D.5 — PACKAGE ASSEMBLY"

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

    cp -a "$VALIDATION_FILE" "$PACKAGE_DIR/FINAL_VALIDATION.txt"

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
        "$PACKAGE_DIR/campaign_stages/00A_BOOTSTRAP_SOURCE_AND_FINITE_DERIVATION"

    copy_directory \
        "$STAGE_00B" \
        "$PACKAGE_DIR/campaign_stages/00B_CORRECTED_LOOP_POSITIVE_PREFLIGHT"

    copy_directory \
        "$STAGE_00C" \
        "$PACKAGE_DIR/campaign_stages/00C_NONVACUITY_MUTATIONS_NIBBLE_CYCLE"

    copy_directory \
        "$POSITIVE_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/positive_compressed_domain_retraction"

    copy_directory \
        "$NIBBLE_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/nibble_preservation"

    copy_directory \
        "$CYCLE_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/cycle_stability"

    copy_directory \
        "$DECOMP_MUT_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/mutation_decompression_side"

    copy_directory \
        "$COMP_MUT_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/mutation_compression_side"

    : > "$PACKAGE_DIR/scripts/SCRIPT_PROVENANCE.txt"

    for source_path in "${SCRIPT_PATHS[@]}"
    do
        name="$(basename "$source_path")"
        cp -a "$source_path" "$PACKAGE_DIR/scripts/$name"

        printf 'EXACT_SCRIPT|%s|%s|%s\n' \
            "$name" \
            "$(sha256sum "$source_path" | awk '{print $1}')" \
            "$source_path" \
            >> "$PACKAGE_DIR/scripts/SCRIPT_PROVENANCE.txt"
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

    printf 'T3_PACKAGE_ASSEMBLY=PASS\n'

    section "T3-00D.6 — FINAL VERDICT AND SCOPE"

    cat > "$PACKAGE_DIR/T3_FINAL_VERDICT.md" <<'VERDICT_EOF'
# POLYCOMP-D4-T3 Final Verification Verdict

## Status

**Accepted within the registered bounded portable-C verification scope.**

## Bound implementation

- Repository: `mlkem-native`
- Commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Configuration: ML-KEM-768 (`MLKEM_K=3`)
- Production functions:
  - `mlk_poly_decompress_d4_c`
  - `mlk_poly_compress_d4_c`
- Production source modification: none
- Verification tool: CBMC 6.9.0

## Input domain

Every possible 128-byte compressed input array is admitted. The positive,
nibble-preservation and cycle-stability harnesses contain no assumptions.

## Primary theorem

For every 128-byte input array `B`:

```text
mlk_poly_compress_d4_c(
    mlk_poly_decompress_d4_c(B)
) = B
```

byte-for-byte.

## Verified obligations

1. Exact 128-byte identity after the real decompression/compression cycle.
2. Low-nibble preservation for every byte.
3. High-nibble preservation for every byte.
4. Cycle stability under a second real decompression/compression cycle.
5. Exact four-loop inventory and complete unwind bounds:
   - harness comparison loop: 129;
   - compressor inner loop: 129;
   - compressor outer loop: 257;
   - decompressor loop: 129.
6. Positive strict checks: 186 of 186 successful.
7. Location coverage: 25 of 25 goals satisfied.
8. Positive end-of-harness reachability.
9. Nibble strict checks: 187 of 187 successful.
10. Cycle strict checks: 186 of 186 successful.
11. Decompression-side coefficient-swap fault detected.
12. Compression-side output-nibble-swap fault detected.

## Finite-domain support

The independent finite derivation confirms:

- all 16 D4 nibbles satisfy scalar retraction;
- all 256 possible packed bytes reconstruct exactly.

## Novelty boundary

This package establishes a clean-room CBMC composition theorem for the pinned
portable-C implementation. It does not claim that compression, decompression,
round-trip properties, or implementation correctness were absent from all
other repository tests, proofs, backends, or formal developments.

## Excluded claims

This package does not establish:

- equivalence with AVX2 or other native/assembly backends;
- correctness of assembly implementations;
- constant-time or side-channel security;
- arbitrary-polynomial compressor correctness outside the separate T1 scope;
- arbitrary-polynomial decompressor refinement outside the separate T2 scope;
- end-to-end ML-KEM correctness;
- correctness of unrelated functions or other parameter configurations.
VERDICT_EOF

    cat > "$PACKAGE_DIR/T3_FINAL_VERDICT.json" <<JSON_EOF
{
  "theorem_id": "POLYCOMP-D4-T3",
  "status": "accepted_within_registered_bounded_scope",
  "repository_commit": "${EXPECTED_COMMIT}",
  "configuration": "ML-KEM-768",
  "mlkem_k": 3,
  "production_source_modified": false,
  "input_domain": "all 128-byte arrays",
  "primary_claim": "compress_d4(decompress_d4(B)) equals B byte-for-byte",
  "positive_strict_properties": {
    "successful": 186,
    "total": 186
  },
  "coverage": {
    "satisfied": 25,
    "total": 25
  },
  "nibble_strict_properties": {
    "successful": 187,
    "total": 187
  },
  "cycle_strict_properties": {
    "successful": 186,
    "total": 186
  },
  "mutations_detected": [
    "decompression_side_coefficient_swap",
    "compression_side_output_nibble_swap"
  ],
  "exact_script_count": 4
}
JSON_EOF

    cat > "$PACKAGE_DIR/README.md" <<'README_EOF'
# POLYCOMP-D4-T3 Evidence Package

This package contains the clean-room CBMC evidence for the portable-C D4
compressed-domain retraction theorem.

Recommended reading order:

1. `T3_FINAL_VERDICT.md`
2. `FINAL_VALIDATION.txt`
3. `SHA256SUMS.txt`
4. `scripts/SCRIPT_PROVENANCE.txt`
5. `metadata/`
6. `campaign_stages/`
7. `proof_artefacts/`

Stage 00A's rejected three-loop expectation is retained as diagnostic
provenance. Stage 00B corrected the firewall after source inspection showed
that the production compressor contains an outer loop and an inner loop.
Neither the positive harness nor production source was changed by that repair.
README_EOF

    printf 'T3_FINAL_VERDICT_WRITTEN=PASS\n'

    section "T3-00D.7 — PACKAGE TREE AND MANIFEST"

    (
        cd "$PACKAGE_DIR" || exit 70

        find . \
            -mindepth 1 \
            -printf '%y %p\n' |
            LC_ALL=C sort \
            > PACKAGE_TREE.txt

        find . \
            -type f \
            ! -name 'SHA256SUMS.txt' \
            ! -name 'MANIFEST_SHA256.txt' \
            -print0 |
        LC_ALL=C sort -z |
        xargs -0 sha256sum \
            > SHA256SUMS.txt

        sha256sum SHA256SUMS.txt \
            > MANIFEST_SHA256.txt

        sha256sum -c SHA256SUMS.txt
        sha256sum -c MANIFEST_SHA256.txt
    ) > "${FINAL_STAGE}/PRE_ARCHIVE_VERIFICATION_${UTC_STAMP}.txt" 2>&1

    PRE_ARCHIVE_EXIT=$?

    PACKAGE_FILE_COUNT="$(find "$PACKAGE_DIR" -type f | wc -l)"
    MANIFEST_ENTRY_COUNT="$(wc -l < "$PACKAGE_DIR/SHA256SUMS.txt")"
    PACKAGED_SCRIPT_COUNT="$(
        find "$PACKAGE_DIR/scripts" \
            -maxdepth 1 \
            -type f \
            -name '*.sh' |
        wc -l
    )"

    printf 'PACKAGE_FILE_COUNT=%s\n' "$PACKAGE_FILE_COUNT"
    printf 'MANIFEST_ENTRY_COUNT=%s\n' "$MANIFEST_ENTRY_COUNT"
    printf 'PACKAGED_SCRIPT_COUNT=%s\n' "$PACKAGED_SCRIPT_COUNT"
    printf 'PRE_ARCHIVE_VERIFY_EXIT=%s\n' "$PRE_ARCHIVE_EXIT"

    if [[ "$PRE_ARCHIVE_EXIT" -ne 0 ]]; then
        cat "${FINAL_STAGE}/PRE_ARCHIVE_VERIFICATION_${UTC_STAMP}.txt"
        mark_fail "pre-archive verification failed"
        return 60
    fi

    if [[ "$PACKAGED_SCRIPT_COUNT" != "4" ]]; then
        mark_fail "final package does not contain all four exact scripts"
        return 61
    fi

    printf 'T3_PACKAGE_MANIFEST_VERIFICATION=PASS\n'
    printf 'T3_PACKAGED_SCRIPT_COMPLETENESS=PASS\n'

    section "T3-00D.8 — DETERMINISTIC ARCHIVE AND EXTRACTION CHECK"

    tar \
        --sort=name \
        --mtime='UTC 2026-07-26 00:00:00' \
        --owner=0 \
        --group=0 \
        --numeric-owner \
        -czf "$ARCHIVE" \
        -C "$FINAL_STAGE" \
        "$PACKAGE_NAME"

    TAR_EXIT=$?

    printf 'TAR_EXIT=%s\n' "$TAR_EXIT"

    if [[ "$TAR_EXIT" -ne 0 || ! -f "$ARCHIVE" ]]; then
        mark_fail "could not create T3 archive"
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

        test "$(
            find scripts \
                -maxdepth 1 \
                -type f \
                -name '*.sh' |
            wc -l
        )" = "4"

        for script_path in scripts/*.sh
        do
            bash -n "$script_path"
        done
    ) > "${FINAL_STAGE}/POST_ARCHIVE_VERIFICATION_${UTC_STAMP}.txt" 2>&1

    POST_ARCHIVE_EXIT=$?

    printf 'POST_ARCHIVE_VERIFY_EXIT=%s\n' "$POST_ARCHIVE_EXIT"

    if [[ "$POST_ARCHIVE_EXIT" -ne 0 ]]; then
        cat "${FINAL_STAGE}/POST_ARCHIVE_VERIFICATION_${UTC_STAMP}.txt"
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
    printf 'POST_ARCHIVE_SCRIPT_VALIDATION=PASS\n'
    printf 'TEMPORARY_EXTRACTION_CLEANUP=PASS\n'

    section "T3-00D.9 — FINAL SOURCE IMMUTABILITY AND READ-ONLY FREEZE"

    if [[ -n "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            status --porcelain=v1 --untracked-files=all
    )" ]]
    then
        mark_fail "authoritative source became dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE_AFTER=CLEAN\n'
    fi

    if [[ -n "$(
        git -C "$WORK_REPO" \
            status --porcelain=v1 -- mlkem/src
    )" ]]
    then
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

    section "POLYCOMP-D4-T3-00D FINAL VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_T3_00D_STATUS=PASS\n'
        printf 'T3_FINAL_EVIDENCE_FREEZE=PASS\n'
        printf 'T3_FINAL_THEOREM_STATUS=ACCEPTED_WITHIN_REGISTERED_BOUNDED_SCOPE\n'
        printf 'ALL_REGISTERED_T3_OBLIGATIONS=VERIFIED\n'
        printf 'EXACT_EXECUTED_SCRIPTS=4_OF_4_PACKAGED\n'
        printf 'FINAL_PACKAGE=%s\n' "$ARCHIVE"
        printf 'FINAL_PACKAGE_SHA256_FILE=%s\n' "$ARCHIVE_HASH"
        printf 'NEXT_GATE=INDEPENDENT_BYTE_LEVEL_PACKAGE_INSPECTION\n'
    else
        printf 'POLYCOMP_D4_T3_00D_STATUS=FAIL\n'
        printf 'T3_FINAL_EVIDENCE_FREEZE=NOT_ACCEPTED\n'
    fi

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-T3-00D CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
