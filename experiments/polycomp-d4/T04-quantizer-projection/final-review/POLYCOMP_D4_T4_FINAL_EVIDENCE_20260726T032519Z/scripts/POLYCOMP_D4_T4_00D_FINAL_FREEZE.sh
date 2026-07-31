#!/usr/bin/env bash
set -uo pipefail
shopt -s nullglob

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t4_20260726T024145Z"
CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"

STAGE_00A="${CAMPAIGN_ROOT}/POLYCOMP_D4_T4_00A_BOOTSTRAP_PROJECTION_DISTORTION"
STAGE_00B="${CAMPAIGN_ROOT}/POLYCOMP_D4_T4_00B_WITNESS_FIXED_IDEMPOTENCE_LOCALITY"
STAGE_00C="${CAMPAIGN_ROOT}/POLYCOMP_D4_T4_00C_NONVACUITY_MUTATION_DETECTION"

POSITIVE_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_projection_distortion"
WITNESS_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_sharp_witness_20260726T024847Z"
FIXED_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_fixed_point_characterization_20260726T024847Z"
IDEMP_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_projection_idempotence_20260726T024847Z"
LOCALITY_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_coordinate_locality_20260726T024847Z"
CODEBOOK_MUT_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_mutation_codebook_20260726T031711Z"
DIST_MUT_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_mutation_distortion_20260726T031711Z"

POSITIVE_HARNESS="${POSITIVE_PROOF}/polycomp_d4_t4_projection_distortion_harness.c"
POSITIVE_MAKEFILE="${POSITIVE_PROOF}/Makefile"
POSITIVE_GOTO="${POSITIVE_PROOF}/gotos/polycomp_d4_t4_projection_distortion_harness.goto"

WITNESS_HARNESS="${WITNESS_PROOF}/polycomp_d4_t4_sharp_witness_harness.c"
WITNESS_GOTO="${WITNESS_PROOF}/gotos/polycomp_d4_t4_sharp_witness_harness.goto"

FIXED_HARNESS="${FIXED_PROOF}/polycomp_d4_t4_fixed_point_characterization_harness.c"
FIXED_GOTO="${FIXED_PROOF}/gotos/polycomp_d4_t4_fixed_point_characterization_harness.goto"

IDEMP_HARNESS="${IDEMP_PROOF}/polycomp_d4_t4_projection_idempotence_harness.c"
IDEMP_GOTO="${IDEMP_PROOF}/gotos/polycomp_d4_t4_projection_idempotence_harness.goto"

LOCALITY_HARNESS="${LOCALITY_PROOF}/polycomp_d4_t4_coordinate_locality_harness.c"
LOCALITY_GOTO="${LOCALITY_PROOF}/gotos/polycomp_d4_t4_coordinate_locality_harness.goto"

CODEBOOK_MUT_HARNESS="${CODEBOOK_MUT_PROOF}/polycomp_d4_t4_mutation_codebook_harness.c"
CODEBOOK_MUT_GOTO="${CODEBOOK_MUT_PROOF}/gotos/polycomp_d4_t4_mutation_codebook_harness.goto"

DIST_MUT_HARNESS="${DIST_MUT_PROOF}/polycomp_d4_t4_mutation_distortion_harness.c"
DIST_MUT_GOTO="${DIST_MUT_PROOF}/gotos/polycomp_d4_t4_mutation_distortion_harness.goto"

EXPECTED_POSITIVE_HARNESS_SHA256="f9b385228c2bed2eb5c5f8be075f0a12c604cba5e8265fd632aab49d525dae1c"
EXPECTED_POSITIVE_MAKEFILE_SHA256="0044f48f8df604a7c1504b9b2cd4c8ec566fa3403c483cf93771a2eafcf796e2"
EXPECTED_POSITIVE_GOTO_SHA256="e9c0f8031f3e7edbcdde441743f12d87cb0b23d09853c2d3458fae04db1483eb"

EXPECTED_WITNESS_HARNESS_SHA256="40d27b75240e706f787588036a04a22c05dbb0af0ec03535bf0e6a70b3a7e13d"
EXPECTED_WITNESS_GOTO_SHA256="126ef34338a0ea64a72140f0f09a07c946659fbd36d3a1d32e9832dd5a956cda"

EXPECTED_FIXED_HARNESS_SHA256="9aca8dd8a1e16b969deb6cf2fa0ace521149e523c3c9003171345a897eeab83d"
EXPECTED_FIXED_GOTO_SHA256="da603bee77516f5f09e1eb529eeefa1dec7d5f412cc64d712bbaeb464d74930c"

EXPECTED_IDEMP_HARNESS_SHA256="2cf6a4a2ed3a1478a33490554e287347730e86b6343c9775ea62b625dd75be99"
EXPECTED_IDEMP_GOTO_SHA256="19197be2f2c9ba7da6b5243cae2b687479b22275d291394d7738efe3fc976e4e"

EXPECTED_LOCALITY_HARNESS_SHA256="ce2c744230eb74c35a8228771c1e90bbdbd407f4bd11066782ebbcf22841af76"
EXPECTED_LOCALITY_GOTO_SHA256="7803688fc57b7804fa29c51217c94ce5da579baa9658d87a3329c781cbe0362a"

EXPECTED_CODEBOOK_MUT_HARNESS_SHA256="173043608fa6e489be5641c5a17cae564542ddb14da72f20705ccf9c1e8008d0"
EXPECTED_CODEBOOK_MUT_GOTO_SHA256="e072c73bd621c8cf10f5f07fe62d1a868547c9fd980b55300260f8996fb1af85"

EXPECTED_DIST_MUT_HARNESS_SHA256="8751147e8ffb0ffb6a4d8a28b4d37323d349ce3163fb0b266b87984646cb41c9"
EXPECTED_DIST_MUT_GOTO_SHA256="a1e883f21acfe2d8593f872f5452d99a32653be8e9d50bc794341797a1310492"

FINITE_DERIVATION="${STAGE_00A}/T4_FINITE_DERIVATION_20260726T024145Z.txt"
REGISTRY_EXTRACT="${STAGE_00A}/T4_REGISTRY_EXTRACT_20260726T024145Z.txt"
SOURCE_CAPTURE="${STAGE_00A}/T4_SOURCE_CAPTURE_20260726T024145Z.txt"
OVERLAP_CAPTURE="${STAGE_00A}/T4_NATIVE_OVERLAP_CAPTURE_20260726T024145Z.txt"
POSITIVE_LOOP_MAP="${STAGE_00A}/T4_LOOP_MAP_20260726T024145Z.txt"
POSITIVE_SEMANTIC_JSON="${STAGE_00A}/T4_SEMANTIC_RESULT_20260726T024145Z.json"
POSITIVE_STRICT_JSON="${STAGE_00A}/T4_STRICT_RESULT_20260726T024145Z.json"

WITNESS_SEMANTIC_JSON="${STAGE_00B}/T4_WITNESS_SEMANTIC_20260726T024847Z.json"
WITNESS_STRICT_JSON="${STAGE_00B}/T4_WITNESS_STRICT_20260726T024847Z.json"
FIXED_SEMANTIC_JSON="${STAGE_00B}/T4_FIXED_SEMANTIC_20260726T024847Z.json"
FIXED_STRICT_JSON="${STAGE_00B}/T4_FIXED_STRICT_20260726T024847Z.json"
IDEMP_SEMANTIC_JSON="${STAGE_00B}/T4_IDEMP_SEMANTIC_20260726T024847Z.json"
IDEMP_STRICT_JSON="${STAGE_00B}/T4_IDEMP_STRICT_20260726T024847Z.json"
LOCALITY_SEMANTIC_JSON="${STAGE_00B}/T4_LOCALITY_SEMANTIC_20260726T024847Z.json"
LOCALITY_STRICT_JSON="${STAGE_00B}/T4_LOCALITY_STRICT_20260726T024847Z.json"

COVERAGE_JSON="${STAGE_00C}/T4_LOCATION_COVERAGE_20260726T031711Z.json"
REACHABILITY_JSON="${STAGE_00C}/T4_POSITIVE_END_REACHABILITY_20260726T031711Z.json"
CODEBOOK_MUT_JSON="${STAGE_00C}/T4_CODEBOOK_MUT_RESULT_20260726T031711Z.json"
DIST_MUT_JSON="${STAGE_00C}/T4_DIST_MUT_RESULT_20260726T031711Z.json"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
FINAL_STAGE="${CAMPAIGN_ROOT}/POLYCOMP_D4_T4_00D_FINAL_FREEZE"
PACKAGE_NAME="POLYCOMP_D4_T4_FINAL_EVIDENCE_${UTC_STAMP}"
PACKAGE_DIR="${FINAL_STAGE}/${PACKAGE_NAME}"
ARCHIVE="${FINAL_STAGE}/${PACKAGE_NAME}.tar.gz"
ARCHIVE_HASH="${ARCHIVE}.sha256"

VALIDATION_FILE="${FINAL_STAGE}/T4_FINAL_VALIDATION_${UTC_STAMP}.txt"
CAPTURE_FILE="${FINAL_STAGE}/POLYCOMP_D4_T4_00D_FINAL_FREEZE_${UTC_STAMP}.txt"
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
    section "POLYCOMP-D4-T4-00D — FINAL EVIDENCE FREEZE"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'PACKAGE_DIR=%s\n' "$PACKAGE_DIR"
    printf 'ARCHIVE=%s\n' "$ARCHIVE"

    section "T4-00D.1 — SOURCE AND ARTEFACT BINDING"

    require_dir "$AUTHORITATIVE_SOURCE_PATH"
    require_dir "$WORK_REPO"

    for required in \
        "$POSITIVE_HARNESS" "$POSITIVE_MAKEFILE" "$POSITIVE_GOTO" \
        "$WITNESS_HARNESS" "$WITNESS_GOTO" \
        "$FIXED_HARNESS" "$FIXED_GOTO" \
        "$IDEMP_HARNESS" "$IDEMP_GOTO" \
        "$LOCALITY_HARNESS" "$LOCALITY_GOTO" \
        "$CODEBOOK_MUT_HARNESS" "$CODEBOOK_MUT_GOTO" \
        "$DIST_MUT_HARNESS" "$DIST_MUT_GOTO"
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

    verify_hash "$WITNESS_HARNESS" "$EXPECTED_WITNESS_HARNESS_SHA256" "WITNESS_HARNESS"
    verify_hash "$WITNESS_GOTO" "$EXPECTED_WITNESS_GOTO_SHA256" "WITNESS_GOTO"

    verify_hash "$FIXED_HARNESS" "$EXPECTED_FIXED_HARNESS_SHA256" "FIXED_HARNESS"
    verify_hash "$FIXED_GOTO" "$EXPECTED_FIXED_GOTO_SHA256" "FIXED_GOTO"

    verify_hash "$IDEMP_HARNESS" "$EXPECTED_IDEMP_HARNESS_SHA256" "IDEMP_HARNESS"
    verify_hash "$IDEMP_GOTO" "$EXPECTED_IDEMP_GOTO_SHA256" "IDEMP_GOTO"

    verify_hash "$LOCALITY_HARNESS" "$EXPECTED_LOCALITY_HARNESS_SHA256" "LOCALITY_HARNESS"
    verify_hash "$LOCALITY_GOTO" "$EXPECTED_LOCALITY_GOTO_SHA256" "LOCALITY_GOTO"

    verify_hash "$CODEBOOK_MUT_HARNESS" "$EXPECTED_CODEBOOK_MUT_HARNESS_SHA256" "CODEBOOK_MUT_HARNESS"
    verify_hash "$CODEBOOK_MUT_GOTO" "$EXPECTED_CODEBOOK_MUT_GOTO_SHA256" "CODEBOOK_MUT_GOTO"

    verify_hash "$DIST_MUT_HARNESS" "$EXPECTED_DIST_MUT_HARNESS_SHA256" "DIST_MUT_HARNESS"
    verify_hash "$DIST_MUT_GOTO" "$EXPECTED_DIST_MUT_GOTO_SHA256" "DIST_MUT_GOTO"

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

    printf 'T4_FINAL_SOURCE_AND_ARTEFACT_BINDING=PASS\n'

    section "T4-00D.2 — REQUIRED EVIDENCE INVENTORY"

    for required_file in \
        "$FINITE_DERIVATION" \
        "$REGISTRY_EXTRACT" \
        "$SOURCE_CAPTURE" \
        "$OVERLAP_CAPTURE" \
        "$POSITIVE_LOOP_MAP" \
        "$POSITIVE_SEMANTIC_JSON" \
        "$POSITIVE_STRICT_JSON" \
        "$WITNESS_SEMANTIC_JSON" \
        "$WITNESS_STRICT_JSON" \
        "$FIXED_SEMANTIC_JSON" \
        "$FIXED_STRICT_JSON" \
        "$IDEMP_SEMANTIC_JSON" \
        "$IDEMP_STRICT_JSON" \
        "$LOCALITY_SEMANTIC_JSON" \
        "$LOCALITY_STRICT_JSON" \
        "$COVERAGE_JSON" \
        "$REACHABILITY_JSON" \
        "$CODEBOOK_MUT_JSON" \
        "$DIST_MUT_JSON"
    do
        require_file "$required_file"
    done

    for required_dir in \
        "$STAGE_00A" \
        "$STAGE_00B" \
        "$STAGE_00C" \
        "$POSITIVE_PROOF" \
        "$WITNESS_PROOF" \
        "$FIXED_PROOF" \
        "$IDEMP_PROOF" \
        "$LOCALITY_PROOF" \
        "$CODEBOOK_MUT_PROOF" \
        "$DIST_MUT_PROOF"
    do
        require_dir "$required_dir"
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 30
    fi

    printf 'T4_REQUIRED_EVIDENCE_INVENTORY=PASS\n'

    section "T4-00D.3 — EXACT EXECUTED SCRIPT INVENTORY"

    declare -a SCRIPT_NAMES=(
        "POLYCOMP_D4_T4_00A_BOOTSTRAP_PROJECTION_DISTORTION.sh"
        "POLYCOMP_D4_T4_00B_WITNESS_FIXED_IDEMPOTENCE_LOCALITY.sh"
        "POLYCOMP_D4_T4_00C_NONVACUITY_MUTATION_DETECTION.sh"
        "POLYCOMP_D4_T4_00D_FINAL_FREEZE.sh"
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
        mark_fail "all four exact T4 scripts are required before final freeze"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 31
    fi

    printf 'T4_EXACT_EXECUTED_SCRIPT_INVENTORY=PASS\n'

    section "T4-00D.4 — MACHINE VALIDATION OF FINAL CLAIMS"

    python3 - \
        "$FINITE_DERIVATION" \
        "$REGISTRY_EXTRACT" \
        "$POSITIVE_LOOP_MAP" \
        "$POSITIVE_SEMANTIC_JSON" \
        "$POSITIVE_STRICT_JSON" \
        "$WITNESS_SEMANTIC_JSON" \
        "$WITNESS_STRICT_JSON" \
        "$FIXED_SEMANTIC_JSON" \
        "$FIXED_STRICT_JSON" \
        "$IDEMP_SEMANTIC_JSON" \
        "$IDEMP_STRICT_JSON" \
        "$LOCALITY_SEMANTIC_JSON" \
        "$LOCALITY_STRICT_JSON" \
        "$COVERAGE_JSON" \
        "$REACHABILITY_JSON" \
        "$CODEBOOK_MUT_JSON" \
        "$DIST_MUT_JSON" \
        "$VALIDATION_FILE" <<'PY'
import json
import sys
from pathlib import Path

(
    derivation_path,
    registry_path,
    loop_map_path,
    positive_semantic_path,
    positive_strict_path,
    witness_semantic_path,
    witness_strict_path,
    fixed_semantic_path,
    fixed_strict_path,
    idemp_semantic_path,
    idemp_strict_path,
    locality_semantic_path,
    locality_strict_path,
    coverage_path,
    reachability_path,
    codebook_mut_path,
    dist_mut_path,
    validation_path,
) = map(Path, sys.argv[1:])

CODEBOOK = (
    "POLYCOMP-D4-T4: every projected coefficient belongs "
    "to the exact D4 codebook"
)

DISTORTION = (
    "POLYCOMP-D4-T4: every canonical coefficient has modular "
    "projection distortion at most 104"
)

WITNESS = (
    "POLYCOMP-D4-T4 sharpness: canonical witness 104 attains "
    "modular distortion exactly 104"
)

FIXED = (
    "POLYCOMP-D4-T4 fixed points: a canonical coefficient is "
    "unchanged exactly when it is a D4 codebook value"
)

IDEMP = (
    "POLYCOMP-D4-T4 idempotence: applying the real D4 projection "
    "twice equals applying it once"
)

LOCALITY = (
    "POLYCOMP-D4-T4 locality: equal canonical input coefficients at "
    "one coordinate produce equal projected coefficients there"
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

    assert not errors
    assert results
    assert all(item.get("status") == "SUCCESS" for item in results)
    assert statuses
    assert all(status.lower() == "success" for status in statuses)

derivation = derivation_path.read_text(encoding="utf-8")

for required in (
    "CANONICAL_DOMAIN=0..3328",
    "IMAGE_EQUALS_CODEBOOK=PASS",
    "MAXIMUM_MODULAR_DISTORTION=104",
    "DISTORTION_BOUND_104=PASS",
    "MAXIMUM_WITNESS_COUNT=17",
    "FIXED_POINTS_EQUAL_CODEBOOK=PASS",
    "IDEMPOTENCE_FAILURE_COUNT=0",
    "IDEMPOTENCE=PASS",
    "STATUS=PASS",
):
    assert required in derivation, required

registry = registry_path.read_text(encoding="utf-8")

for required in (
    "T4_ID=POLYCOMP-D4-T4",
    "T4_DOMAIN=All canonical 256-coefficient polynomials",
    "exact-composition",
    "image-characterization",
    "sharp-error-bound",
    "error-witness",
    "fixed-point-characterization",
    "projection-idempotence",
    "coordinate-locality",
):
    assert required in registry, required

loop_map = loop_map_path.read_text(encoding="utf-8")

for required in (
    "TOTAL_LOOP_COUNT=5",
    "HARNESS_LOOP_COUNT=2",
    "COMPRESSOR_LOOP_COUNT=2",
    "DECOMPRESSOR_LOOP_COUNT=1",
    "UNEXPECTED_LOOP_COUNT=0",
    "LOOP_MAP_STATUS=PASS",
    "UNWINDSET=harness.0:257,harness.1:257,mlk_poly_compress_d4_c.0:129,mlk_poly_compress_d4_c.1:257,mlk_poly_decompress_d4_c.0:129",
):
    assert required in loop_map, required

require_description(positive_semantic_path, CODEBOOK, "SUCCESS")
require_description(positive_semantic_path, DISTORTION, "SUCCESS")
require_all_success(positive_strict_path, 194)

require_description(witness_semantic_path, WITNESS, "SUCCESS")
require_all_success(witness_strict_path, 190)

require_description(fixed_semantic_path, FIXED, "SUCCESS")
require_all_success(fixed_strict_path, 190)

require_description(idemp_semantic_path, IDEMP, "SUCCESS")
require_all_success(idemp_strict_path, 189)

require_description(locality_semantic_path, LOCALITY, "SUCCESS")
require_all_success(locality_strict_path, 192)

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

assert len(goals) == 36
assert reported_covered == 36
assert reported_total == 36
assert all(
    str(goal.get("status", "")).lower() == "satisfied"
    for goal in goals
)

reach_mapping, reach_results, _, _ = by_description(
    reachability_path
)

for description in (CODEBOOK, DISTORTION):
    matches = reach_mapping.get(description, [])
    assert len(matches) == 1
    assert matches[0].get("status") == "SUCCESS"

assert any(
    item.get("status") == "FAILURE"
    and str(item.get("description", ""))
    not in {CODEBOOK, DISTORTION}
    for item in reach_results
)

for mutation_path, failed, succeeded in (
    (codebook_mut_path, CODEBOOK, DISTORTION),
    (dist_mut_path, DISTORTION, CODEBOOK),
):
    mapping, results, statuses, errors = by_description(
        mutation_path
    )

    fail_matches = mapping.get(failed, [])
    success_matches = mapping.get(succeeded, [])

    assert len(fail_matches) == 1
    assert fail_matches[0].get("status") == "FAILURE"

    assert len(success_matches) == 1
    assert success_matches[0].get("status") == "SUCCESS"

    assert not errors
    assert any(status.lower() == "failure" for status in statuses)

    assert all(
        item.get("status") == "SUCCESS"
        for item in results
        if str(item.get("description", ""))
        not in {failed, succeeded}
    )

lines = [
    "T4_FINAL_MACHINE_VALIDATION=PASS",
    "T4_DOMAIN=ALL_CANONICAL_256_COEFFICIENT_POLYNOMIALS",
    "FINITE_CANONICAL_DOMAIN=3329/3329 CHECKED",
    "PROJECTION_IMAGE=EXACT_16_VALUE_D4_CODEBOOK",
    "SHARP_MODULAR_DISTORTION_BOUND=104",
    "FINITE_MAXIMUM_WITNESSES=17",
    "POSITIVE_SEMANTIC_PROPERTIES=2/2 SUCCESS",
    "POSITIVE_STRICT_PROPERTIES=194/194 SUCCESS",
    "SHARP_WITNESS_SEMANTIC=SUCCESS",
    "SHARP_WITNESS_STRICT_PROPERTIES=190/190 SUCCESS",
    "FIXED_POINT_CHARACTERIZATION_SEMANTIC=SUCCESS",
    "FIXED_POINT_STRICT_PROPERTIES=190/190 SUCCESS",
    "PROJECTION_IDEMPOTENCE_SEMANTIC=SUCCESS",
    "IDEMPOTENCE_STRICT_PROPERTIES=189/189 SUCCESS",
    "COORDINATE_LOCALITY_SEMANTIC=SUCCESS",
    "LOCALITY_STRICT_PROPERTIES=192/192 SUCCESS",
    "LOCATION_COVERAGE=36/36 SATISFIED",
    "POSITIVE_END_REACHABILITY=PASS",
    "CODEBOOK_MEMBERSHIP_MUTATION_DETECTED=PASS",
    "DISTORTION_BOUND_MUTATION_DETECTED=PASS",
    "ALL_REGISTERED_T4_OBLIGATIONS=CHECKED",
]

validation_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(validation_path.read_text(encoding="utf-8"), end="")
PY

    VALIDATION_EXIT=$?

    printf 'T4_FINAL_VALIDATION_EXIT=%s\n' "$VALIDATION_EXIT"
    printf 'T4_FINAL_VALIDATION_FILE=%s\n' "$VALIDATION_FILE"

    if [[ "$VALIDATION_EXIT" -ne 0 ]]; then
        mark_fail "T4 final machine validation failed"
        return 40
    fi

    printf 'T4_FINAL_MACHINE_VALIDATION=PASS\n'

    section "T4-00D.5 — PACKAGE ASSEMBLY"

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
        "$PACKAGE_DIR/campaign_stages/00A_PROJECTION_AND_DISTORTION"

    copy_directory \
        "$STAGE_00B" \
        "$PACKAGE_DIR/campaign_stages/00B_WITNESS_FIXED_IDEMPOTENCE_LOCALITY"

    copy_directory \
        "$STAGE_00C" \
        "$PACKAGE_DIR/campaign_stages/00C_COVERAGE_REACHABILITY_MUTATIONS"

    copy_directory \
        "$POSITIVE_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/positive_projection_distortion"

    copy_directory \
        "$WITNESS_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/sharp_witness"

    copy_directory \
        "$FIXED_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/fixed_point_characterization"

    copy_directory \
        "$IDEMP_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/projection_idempotence"

    copy_directory \
        "$LOCALITY_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/coordinate_locality"

    copy_directory \
        "$CODEBOOK_MUT_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/mutation_codebook_membership"

    copy_directory \
        "$DIST_MUT_PROOF" \
        "$PACKAGE_DIR/proof_artefacts/mutation_distortion_bound"

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

    printf 'T4_PACKAGE_ASSEMBLY=PASS\n'

    section "T4-00D.6 — FINAL VERDICT AND SCOPE"

    cat > "$PACKAGE_DIR/T4_FINAL_VERDICT.md" <<'VERDICT_EOF'
# POLYCOMP-D4-T4 Final Verification Verdict

## Status

**Accepted within the registered bounded portable-C verification scope.**

## Bound implementation

- Repository: `mlkem-native`
- Commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Configuration: ML-KEM-768 (`MLKEM_K=3`)
- Production functions:
  - `mlk_poly_compress_d4_c`
  - `mlk_poly_decompress_d4_c`
- Production source modification: none
- Verification tool: CBMC 6.9.0

## Input domain

Every 256-coefficient polynomial satisfying:

```text
0 <= coefficient < 3329
```

The assumptions in the positive, fixed-point, idempotence and locality
harnesses define only this frozen canonical domain and the registered
relational coordinate premise.

## Projection

```text
Q(A) = decompress_d4(compress_d4(A))
```

using the real pinned portable-C implementation.

## Verified obligations

1. Every projected coefficient belongs to the exact D4 codebook:
   `0, 208, 416, 624, 832, 1040, 1248, 1456, 1665, 1873, 2081,
   2289, 2497, 2705, 2913, 3121`.
2. Every canonical coefficient has modular projection distortion at most 104.
3. The bound is sharp: canonical coefficient 104 is projected to zero and
   attains modular distance exactly 104.
4. A canonical coefficient is fixed by the projection exactly when it is a
   D4 codebook value.
5. The projection is idempotent: `Q(Q(A)) = Q(A)`.
6. Coordinate locality: equal canonical coefficients at coordinate `k`
   yield equal projected coefficients at `k`.
7. The finite canonical domain 0 through 3328 was exhaustively checked.
8. There are 17 finite witnesses attaining the sharp distance 104.
9. Positive strict checks: 194 of 194 successful.
10. Sharp-witness strict checks: 190 of 190 successful.
11. Fixed-point strict checks: 190 of 190 successful.
12. Idempotence strict checks: 189 of 189 successful.
13. Locality strict checks: 192 of 192 successful.
14. Location coverage: 36 of 36 goals satisfied.
15. Positive end-of-harness reachability.
16. Isolated non-codebook mutation detected while the distortion assertion
    remained successful.
17. Isolated excessive-distortion mutation detected while codebook
    membership remained successful.

## Novelty boundary

This package establishes a clean-room CBMC theorem family for the pinned
portable-C D4 projection. It does not claim that quantization, compression,
decompression, error bounds, or related properties were absent from every
other test, proof, implementation backend, or formal development.

## Excluded claims

This package does not establish:

- equivalence with AVX2 or other native/assembly backends;
- correctness of assembly implementations;
- constant-time or side-channel security;
- behavior outside the canonical coefficient domain;
- end-to-end ML-KEM correctness;
- correctness of unrelated functions or other parameter configurations.
VERDICT_EOF

    cat > "$PACKAGE_DIR/T4_FINAL_VERDICT.json" <<JSON_EOF
{
  "theorem_id": "POLYCOMP-D4-T4",
  "status": "accepted_within_registered_bounded_scope",
  "repository_commit": "${EXPECTED_COMMIT}",
  "configuration": "ML-KEM-768",
  "mlkem_k": 3,
  "production_source_modified": false,
  "input_domain": "all canonical 256-coefficient polynomials",
  "projection": "decompress_d4(compress_d4(A))",
  "codebook_size": 16,
  "sharp_modular_distortion_bound": 104,
  "finite_maximum_witness_count": 17,
  "positive_strict_properties": {
    "successful": 194,
    "total": 194
  },
  "witness_strict_properties": {
    "successful": 190,
    "total": 190
  },
  "fixed_point_strict_properties": {
    "successful": 190,
    "total": 190
  },
  "idempotence_strict_properties": {
    "successful": 189,
    "total": 189
  },
  "locality_strict_properties": {
    "successful": 192,
    "total": 192
  },
  "coverage": {
    "satisfied": 36,
    "total": 36
  },
  "mutations_detected": [
    "isolated_codebook_membership_fault",
    "isolated_distortion_bound_fault"
  ],
  "exact_script_count": 4
}
JSON_EOF

    cat > "$PACKAGE_DIR/README.md" <<'README_EOF'
# POLYCOMP-D4-T4 Evidence Package

This package contains the clean-room CBMC evidence for the portable-C D4
quantizer projection theorem family.

Recommended reading order:

1. `T4_FINAL_VERDICT.md`
2. `FINAL_VALIDATION.txt`
3. `SHA256SUMS.txt`
4. `scripts/SCRIPT_PROVENANCE.txt`
5. `metadata/`
6. `campaign_stages/`
7. `proof_artefacts/`

The package preserves the finite derivation, source/overlap captures, all
semantic and strict result JSON, loop reports, coverage, reachability,
isolated mutation evidence, exact executed scripts, harnesses and GOTO files.
README_EOF

    printf 'T4_FINAL_VERDICT_WRITTEN=PASS\n'

    section "T4-00D.7 — PACKAGE TREE, SAFETY AND MANIFEST"

    SYMLINK_COUNT="$(
        find "$PACKAGE_DIR" -type l | wc -l
    )"

    printf 'PACKAGE_SYMLINK_COUNT=%s\n' "$SYMLINK_COUNT"

    if [[ "$SYMLINK_COUNT" != "0" ]]; then
        mark_fail "package contains symlinks"
        return 60
    fi

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
        return 61
    fi

    if [[ "$PACKAGED_SCRIPT_COUNT" != "4" ]]; then
        mark_fail "final package does not contain all four exact scripts"
        return 62
    fi

    printf 'T4_PACKAGE_MANIFEST_VERIFICATION=PASS\n'
    printf 'T4_PACKAGED_SCRIPT_COMPLETENESS=PASS\n'

    section "T4-00D.8 — DETERMINISTIC ARCHIVE AND EXTRACTION CHECK"

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
        mark_fail "could not create T4 archive"
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

        test "$(
            find . -type l | wc -l
        )" = "0"

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
    printf 'POST_ARCHIVE_SYMLINK_CHECK=PASS\n'
    printf 'TEMPORARY_EXTRACTION_CLEANUP=PASS\n'

    section "T4-00D.9 — FINAL SOURCE IMMUTABILITY AND READ-ONLY FREEZE"

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

    section "POLYCOMP-D4-T4-00D FINAL VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_T4_00D_STATUS=PASS\n'
        printf 'T4_FINAL_EVIDENCE_FREEZE=PASS\n'
        printf 'T4_FINAL_THEOREM_STATUS=ACCEPTED_WITHIN_REGISTERED_BOUNDED_SCOPE\n'
        printf 'ALL_REGISTERED_T4_OBLIGATIONS=VERIFIED\n'
        printf 'EXACT_EXECUTED_SCRIPTS=4_OF_4_PACKAGED\n'
        printf 'FINAL_PACKAGE=%s\n' "$ARCHIVE"
        printf 'FINAL_PACKAGE_SHA256_FILE=%s\n' "$ARCHIVE_HASH"
        printf 'NEXT_GATE=INDEPENDENT_BYTE_LEVEL_PACKAGE_INSPECTION\n'
    else
        printf 'POLYCOMP_D4_T4_00D_STATUS=FAIL\n'
        printf 'T4_FINAL_EVIDENCE_FREEZE=NOT_ACCEPTED\n'
    fi

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-T4-00D CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
