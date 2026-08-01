#!/usr/bin/env bash

set -u

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

EXPECTED_COMPRESS_C_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESS_H_SHA256="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"

EXPECTED_PATH_AMENDMENT_SHA256="0f739b77285edb9fd512eb899a1c7ba0cc98ad6673e3848a89a3ebb0f89d34c3"

EXPECTED_BASE_HARNESS_SHA256="5ce480427d7792b3dca091ac198b43562c4d4dfd6c9d96dae5a73e7ef1e72b55"
EXPECTED_BASE_GOTO_SHA256="51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d"
EXPECTED_POSITIVE_JSON_SHA256="3b32112c5537a95d470b0b866c1edf6cb1f8c3be408188c9fc2cdbf91fab40ee"

EXPECTED_POSITIVE_PROPERTY_COUNT=521
EXPECTED_COMPANION_PROPERTY_COUNT=522
EXPECTED_COVER_GOAL_COUNT=12
EXPECTED_MUTANT_COUNT=8

SOURCE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
COMPRESS_C="$SOURCE/mlkem/src/compress.c"
COMPRESS_H="$SOURCE/mlkem/src/compress.h"

CAMPAIGN="$HOME/THESIS-2026/mlk_poly_tomsg_cleanroom"

PATH_BIND_OUT="$CAMPAIGN/MSG00CDE_af4c5abdd595"
PATH_AMENDMENT="$PATH_BIND_OUT/MSG00CDE_PATH_BINDING_AMENDMENT.md"

BASE_OUT="$CAMPAIGN/MSG01G_R1_T1_FROZEN_EXECUTION_INPUT_V1_af4c5abdd595"
BASE="$BASE_OUT/frozen_candidate_v1"
BASE_HARNESS="$BASE/harness/msg_t1_exact_fips_candidate_v4.c"
BASE_GOTO="$BASE/build/msg_t1_exact_fips_v4_direct_pragma.goto"
BASE_SUMMARY="$BASE/MSG01G_R1_FREEZE_SUMMARY.txt"
BASE_FREEZE_RECORD="$BASE/MSG01G_R1_CANDIDATE_FREEZE_RECORD.md"
BASE_EXEC_PLAN="$BASE/MSG01G_R1_EXECUTION_PLAN.md"
BASE_CORRECTION="$BASE/MSG01G_R1_AUDIT_CORRECTION_RECORD.md"
BASE_MANIFEST="$BASE/MSG01G_R1_ARTIFACT_MANIFEST.sha256"
BASE_MANIFEST_SHA="$BASE_MANIFEST.sha256"

POSITIVE="$CAMPAIGN/MSG01H_T1_AUTHORITATIVE_POSITIVE_RUN1_af4c5abdd595"
POSITIVE_JSON="$POSITIVE/results/msg_t1_positive_cbmc_result.json"
POSITIVE_ALL="$POSITIVE/results/msg_t1_positive_all_properties.tsv"
POSITIVE_PARSED="$POSITIVE/results/msg_t1_positive_parsed_summary.txt"
POSITIVE_SUMMARY="$POSITIVE/MSG01H_POSITIVE_EXECUTION_SUMMARY.txt"
POSITIVE_RESULT="$POSITIVE/MSG01H_POSITIVE_EXECUTION_RESULT.md"
POSITIVE_BINDING="$POSITIVE/MSG01H_EXECUTION_INPUT_BINDING.md"
POSITIVE_COMMAND="$POSITIVE/commands/msg_t1_positive_cbmc_command.txt"
POSITIVE_MANIFEST="$POSITIVE/MSG01H_ARTIFACT_MANIFEST.sha256"
POSITIVE_MANIFEST_SHA="$POSITIVE_MANIFEST.sha256"

I_R1_OUT="$CAMPAIGN/MSG01I_R1_T1_REACHABILITY_CONTROL_FREEZE_V1_af4c5abdd595"
I_R1_FAMILY="$I_R1_OUT/frozen_reachability_family_v1"
I_R1_CORRECTION="$I_R1_FAMILY/MSG01I_R1_PARSER_CORRECTION_RECORD.md"
I_R1_FREEZE="$I_R1_FAMILY/MSG01I_R1_REACHABILITY_FAMILY_FREEZE_RECORD.md"

J_R1="$CAMPAIGN/MSG01J_R1_T1_REACHABILITY_NONVACUITY_RUN1_af4c5abdd595"
J_R1_CORRECTION="$J_R1/MSG01J_R1_DERIVATION_CORRECTION_RECORD.md"

J_R2="$CAMPAIGN/MSG01J_R2_T1_REACHABILITY_NONVACUITY_RUN1_af4c5abdd595"
J_R2_CORRECTION="$J_R2/MSG01J_R2_UNWINDING_INTERPRETATION_RECORD.md"

NONVAC="$CAMPAIGN/MSG01J_R3_T1_REACHABILITY_NONVACUITY_FINAL_af4c5abdd595"
NONVAC_SUMMARY="$NONVAC/MSG01J_R3_REACHABILITY_SUMMARY.txt"
NONVAC_RESULT="$NONVAC/MSG01J_R3_REACHABILITY_RESULT.md"
NONVAC_CORRECTION="$NONVAC/MSG01J_R3_LOOP_CLASSIFICATION_RECORD.md"
NONVAC_COMPANION_AUDIT="$NONVAC/inspection/accepted_companion_audit.txt"
NONVAC_COVERAGE="$NONVAC/coverage/original_model_coverage.txt"
NONVAC_COVERAGE_PARSED="$NONVAC/coverage/original_model_coverage_parsed_summary.txt"
NONVAC_CONTROL_MATRIX="$NONVAC/new_controls/final_unwind_control_matrix.tsv"
NONVAC_CONTROL_SUMMARY="$NONVAC/new_controls/final_unwind_control_summary.txt"
NONVAC_MANIFEST="$NONVAC/MSG01J_R3_ARTIFACT_MANIFEST.sha256"
NONVAC_MANIFEST_SHA="$NONVAC_MANIFEST.sha256"

MUT_FREEZE_OUT="$CAMPAIGN/MSG01K_R1_T1_MUTATION_FAMILY_FREEZE_V1_af4c5abdd595"
MUT_FAMILY="$MUT_FREEZE_OUT/frozen_mutation_family_v1"
MUT_PLAN="$MUT_FAMILY/MUTATION_PLAN.tsv"
MUT_WITNESS="$MUT_FAMILY/SEMANTIC_WITNESS_REPORT.txt"
MUT_FREEZE_MATRIX="$MUT_FAMILY/MUTATION_FREEZE_MATRIX.tsv"
MUT_FREEZE_SUMMARY="$MUT_FAMILY/MSG01K_R1_MUTATION_FAMILY_FREEZE_SUMMARY.txt"
MUT_FREEZE_RECORD="$MUT_FAMILY/MSG01K_R1_MUTATION_FAMILY_FREEZE_RECORD.md"
MUT_PERMISSION_CORRECTION="$MUT_FAMILY/MSG01K_R1_PERMISSION_CORRECTION_RECORD.md"
MUT_FREEZE_MANIFEST="$MUT_FREEZE_OUT/MSG01K_R1_ARTIFACT_MANIFEST.sha256"
MUT_FREEZE_MANIFEST_SHA="$MUT_FREEZE_MANIFEST.sha256"

MUT_EXEC="$CAMPAIGN/MSG01L_R1_T1_MUTATION_EXECUTION_RUN1_af4c5abdd595"
MUT_EXEC_MATRIX="$MUT_EXEC/results/MUTATION_EXECUTION_MATRIX.tsv"
MUT_EXEC_SUMMARY="$MUT_EXEC/MSG01L_R1_MUTATION_EXECUTION_SUMMARY.txt"
MUT_EXEC_RESULT="$MUT_EXEC/MSG01L_R1_MUTATION_EXECUTION_RESULT.md"
MUT_EXEC_MANIFEST="$MUT_EXEC/MSG01L_R1_ARTIFACT_MANIFEST.sha256"
MUT_EXEC_MANIFEST_SHA="$MUT_EXEC_MANIFEST.sha256"

OUT="$CAMPAIGN/MSG01M_T1_FINAL_EVIDENCE_CONSOLIDATION_af4c5abdd595"
ARCHIVE="$CAMPAIGN/MSG01M_T1_FINAL_EVIDENCE_CONSOLIDATION_af4c5abdd595.tar.gz"
ARCHIVE_SHA="$ARCHIVE.sha256"
ARCHIVE_LISTING="$CAMPAIGN/MSG01M_T1_FINAL_EVIDENCE_CONSOLIDATION_af4c5abdd595.archive_listing.txt"

RECORDS="$OUT/records"
RECORDS_BASE="$RECORDS/01_candidate_freeze"
RECORDS_POS="$RECORDS/02_positive_proof"
RECORDS_NONVAC="$RECORDS/03_nonvacuity"
RECORDS_MUT_FREEZE="$RECORDS/04_mutation_freeze"
RECORDS_MUT_EXEC="$RECORDS/05_mutation_execution"
CORRECTIONS="$OUT/corrections"
AUDIT="$OUT/audit"
SNAPSHOT="$OUT/frozen_snapshot"
MANIFESTS="$OUT/source_manifests"

THEOREM="$OUT/FINAL_MSG_T1_THEOREM_RECORD.md"
BOUNDARIES="$OUT/ASSURANCE_BOUNDARIES.md"
HISTORY="$OUT/CAMPAIGN_HISTORY_AND_CORRECTIONS.md"
CHAIN="$OUT/CHAIN_OF_CUSTODY.md"
README="$OUT/README.md"

EVIDENCE_MATRIX="$AUDIT/EVIDENCE_MATRIX.tsv"
PACKAGE_DIGESTS="$AUDIT/AUTHORITATIVE_PACKAGE_DIGESTS.tsv"
MUTANT_HASHES="$AUDIT/MUTANT_RESULT_HASHES.tsv"
FINAL_AUDIT="$AUDIT/FINAL_CONSOLIDATION_AUDIT.txt"
FINAL_SUMMARY="$OUT/MSG01M_FINAL_CAMPAIGN_SUMMARY.txt"

MASTER="$OUT/MSG01M_TERMINAL_CAPTURE.txt"
FINAL_MANIFEST="$OUT/MSG01M_ARTIFACT_MANIFEST.sha256"
FINAL_MANIFEST_SHA="$FINAL_MANIFEST.sha256"

if [ -e "$OUT" ]; then
    echo "OUTPUT_DIRECTORY_ALREADY_EXISTS=$OUT"
    echo "CAPTURE_STATUS=1"
    exit 1
fi

if [ -e "$ARCHIVE" ] || [ -e "$ARCHIVE_SHA" ]; then
    echo "ARCHIVE_ALREADY_EXISTS=$ARCHIVE"
    echo "CAPTURE_STATUS=1"
    exit 1
fi

mkdir -p \
    "$RECORDS_BASE" \
    "$RECORDS_POS" \
    "$RECORDS_NONVAC" \
    "$RECORDS_MUT_FREEZE" \
    "$RECORDS_MUT_EXEC" \
    "$CORRECTIONS" \
    "$AUDIT" \
    "$SNAPSHOT/source" \
    "$SNAPSHOT/harness" \
    "$MANIFESTS"

verify_manifest_pair()
{
    local root="$1"
    local manifest="$2"
    local self_hash="$3"
    local label="$4"

    (
        cd "$root" || exit 1
        sha256sum -c "$(basename "$self_hash")"
        sha256sum -c "$(basename "$manifest")"
    )

    local status=$?

    if [ "$status" -ne 0 ]; then
        echo "${label}_MANIFEST_VERIFICATION=FAIL"
        return 1
    fi

    echo "${label}_MANIFEST_VERIFICATION=PASS"
    return 0
}

verify_read_only_tree()
{
    local root="$1"
    local label="$2"
    local bad_files=0
    local bad_dirs=0

    while IFS= read -r -d '' file; do
        local mode
        mode=$(stat -c '%a' "$file")

        if [ "$mode" != "444" ]; then
            echo "${label}_BAD_FILE_MODE=$mode $file"
            bad_files=$((bad_files + 1))
        fi
    done < <(find "$root" -type f -print0)

    while IFS= read -r -d '' directory; do
        local mode
        mode=$(stat -c '%a' "$directory")

        if [ "$mode" != "555" ]; then
            echo "${label}_BAD_DIRECTORY_MODE=$mode $directory"
            bad_dirs=$((bad_dirs + 1))
        fi
    done < <(find "$root" -type d -print0)

    echo "${label}_BAD_FILE_MODE_COUNT=$bad_files"
    echo "${label}_BAD_DIRECTORY_MODE_COUNT=$bad_dirs"

    if [ "$bad_files" -ne 0 ] || [ "$bad_dirs" -ne 0 ]; then
        echo "${label}_READ_ONLY_LOCK=FAIL"
        return 1
    fi

    echo "${label}_READ_ONLY_LOCK=PASS"
    return 0
}

copy_required()
{
    local source_file="$1"
    local destination_file="$2"
    local label="$3"

    [ -f "$source_file" ] || {
        echo "REQUIRED_RECORD_MISSING=$label $source_file"
        return 1
    }

    cp -- "$source_file" "$destination_file" || {
        echo "REQUIRED_RECORD_COPY=FAIL $label"
        return 1
    }

    echo "REQUIRED_RECORD_COPY=PASS $label"
    return 0
}

{
echo "============================================================"
echo "MSG-01M — FINAL MSG-T1 EVIDENCE CONSOLIDATION"
echo "============================================================"
echo
echo "CONSOLIDATION_UTC=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
echo "SOURCE=$SOURCE"
echo "OUT=$OUT"
echo "CBMC_SOLVING_EXECUTED=NO"
echo "GOTO_REBUILD_EXECUTED=NO"
echo "SOURCE_MUTATION_EXECUTED=NO"
echo

echo "============================================================"
echo "A. SOURCE AND PRIMARY HASH BINDING"
echo "============================================================"

SOURCE_HEAD=$(git -C "$SOURCE" rev-parse HEAD)
SOURCE_STATUS=$(git -C "$SOURCE" status --porcelain=v1)

COMPRESS_C_SHA=$(sha256sum "$COMPRESS_C" | awk '{print $1}')
COMPRESS_H_SHA=$(sha256sum "$COMPRESS_H" | awk '{print $1}')
PATH_AMENDMENT_SHA=$(sha256sum "$PATH_AMENDMENT" | awk '{print $1}')
BASE_HARNESS_SHA=$(sha256sum "$BASE_HARNESS" | awk '{print $1}')
BASE_GOTO_SHA=$(sha256sum "$BASE_GOTO" | awk '{print $1}')
POSITIVE_JSON_SHA=$(sha256sum "$POSITIVE_JSON" | awk '{print $1}')

echo "SOURCE_HEAD=$SOURCE_HEAD"
echo "COMPRESS_C_SHA256=$COMPRESS_C_SHA"
echo "COMPRESS_H_SHA256=$COMPRESS_H_SHA"
echo "PATH_AMENDMENT_SHA256=$PATH_AMENDMENT_SHA"
echo "BASE_HARNESS_SHA256=$BASE_HARNESS_SHA"
echo "BASE_GOTO_SHA256=$BASE_GOTO_SHA"
echo "POSITIVE_JSON_SHA256=$POSITIVE_JSON_SHA"

[ "$SOURCE_HEAD" = "$EXPECTED_COMMIT" ] || {
    echo "SOURCE_HEAD_BINDING=FAIL"
    exit 2
}

[ -z "$SOURCE_STATUS" ] || {
    echo "SOURCE_WORKTREE_CLEAN=FAIL"
    printf '%s\n' "$SOURCE_STATUS"
    exit 3
}

[ "$COMPRESS_C_SHA" = "$EXPECTED_COMPRESS_C_SHA256" ] || {
    echo "COMPRESS_C_BINDING=FAIL"
    exit 4
}

[ "$COMPRESS_H_SHA" = "$EXPECTED_COMPRESS_H_SHA256" ] || {
    echo "COMPRESS_H_BINDING=FAIL"
    exit 5
}

[ "$PATH_AMENDMENT_SHA" = "$EXPECTED_PATH_AMENDMENT_SHA256" ] || {
    echo "PATH_AMENDMENT_BINDING=FAIL"
    exit 6
}

[ "$BASE_HARNESS_SHA" = "$EXPECTED_BASE_HARNESS_SHA256" ] || {
    echo "BASE_HARNESS_BINDING=FAIL"
    exit 7
}

[ "$BASE_GOTO_SHA" = "$EXPECTED_BASE_GOTO_SHA256" ] || {
    echo "BASE_GOTO_BINDING=FAIL"
    exit 8
}

[ "$POSITIVE_JSON_SHA" = "$EXPECTED_POSITIVE_JSON_SHA256" ] || {
    echo "POSITIVE_JSON_BINDING=FAIL"
    exit 9
}

echo "SOURCE_HEAD_BINDING=PASS"
echo "SOURCE_WORKTREE_CLEAN=PASS"
echo "PRODUCTION_SOURCE_BINDING=PASS"
echo "PATH_BINDING_AMENDMENT=PASS"
echo "BASE_HARNESS_BINDING=PASS"
echo "BASE_GOTO_BINDING=PASS"
echo "POSITIVE_JSON_BINDING=PASS"

echo
echo "============================================================"
echo "B. VERIFY ALL FIVE AUTHORITATIVE PACKAGE MANIFESTS"
echo "============================================================"

verify_manifest_pair \
    "$BASE" \
    "$BASE_MANIFEST" \
    "$BASE_MANIFEST_SHA" \
    "MSG01G_R1" || exit 10

verify_manifest_pair \
    "$POSITIVE" \
    "$POSITIVE_MANIFEST" \
    "$POSITIVE_MANIFEST_SHA" \
    "MSG01H" || exit 11

verify_manifest_pair \
    "$NONVAC" \
    "$NONVAC_MANIFEST" \
    "$NONVAC_MANIFEST_SHA" \
    "MSG01J_R3" || exit 12

verify_manifest_pair \
    "$MUT_FREEZE_OUT" \
    "$MUT_FREEZE_MANIFEST" \
    "$MUT_FREEZE_MANIFEST_SHA" \
    "MSG01K_R1" || exit 13

verify_manifest_pair \
    "$MUT_EXEC" \
    "$MUT_EXEC_MANIFEST" \
    "$MUT_EXEC_MANIFEST_SHA" \
    "MSG01L_R1" || exit 14

echo "ALL_AUTHORITATIVE_MANIFESTS=PASS"

echo
echo "============================================================"
echo "C. VERIFY AUTHORITATIVE READ-ONLY LOCKS"
echo "============================================================"

verify_read_only_tree "$BASE_OUT" "MSG01G_R1" || exit 15
verify_read_only_tree "$POSITIVE" "MSG01H" || exit 16
verify_read_only_tree "$NONVAC" "MSG01J_R3" || exit 17
verify_read_only_tree "$MUT_FREEZE_OUT" "MSG01K_R1" || exit 18
verify_read_only_tree "$MUT_EXEC" "MSG01L_R1" || exit 19

echo "ALL_AUTHORITATIVE_READ_ONLY_LOCKS=PASS"

echo
echo "============================================================"
echo "D. RE-AUDIT ACCEPTED RESULT CARDINALITIES"
echo "============================================================"

POSITIVE_PROPERTY_COUNT=$(
    tail -n +2 "$POSITIVE_ALL" |
    grep -Ec '.' ||
    true
)

POSITIVE_NON_SUCCESS_COUNT=$(
    awk -F '\t' \
        'NR > 1 && $2 != "SUCCESS" {count++}
         END {print count + 0}' \
        "$POSITIVE_ALL"
)

COMPANION_PROPERTY_COUNT=$(
    awk -F= \
        '$1=="PROPERTY_RECORD_COUNT" {print $2}' \
        "$NONVAC_COMPANION_AUDIT"
)

COMPANION_SUCCESS_COUNT=$(
    awk -F= \
        '$1=="SUCCESS_COUNT" {print $2}' \
        "$NONVAC_COMPANION_AUDIT"
)

COMPANION_FAILURE_COUNT=$(
    awk -F= \
        '$1=="FAILURE_COUNT" {print $2}' \
        "$NONVAC_COMPANION_AUDIT"
)

COMPANION_UNKNOWN_COUNT=$(
    awk -F= \
        '$1=="UNKNOWN_COUNT" {print $2}' \
        "$NONVAC_COMPANION_AUDIT"
)

COVERED=$(
    awk -F= \
        '$1=="SUMMARY_COVERED" {print $2}' \
        "$NONVAC_COVERAGE_PARSED"
)

COVER_TOTAL=$(
    awk -F= \
        '$1=="SUMMARY_TOTAL" {print $2}' \
        "$NONVAC_COVERAGE_PARSED"
)

COVER_FAILED=$(
    awk -F= \
        '$1=="FAILED_LINE_COUNT" {print $2}' \
        "$NONVAC_COVERAGE_PARSED"
)

UNWIND_CONTROL_ROWS=$(
    tail -n +2 "$NONVAC_CONTROL_MATRIX" |
    grep -Ec '.' ||
    true
)

MUTATION_PLAN_ROWS=$(
    tail -n +2 "$MUT_PLAN" |
    grep -Ec '.' ||
    true
)

MUTATION_FREEZE_ROWS=$(
    tail -n +2 "$MUT_FREEZE_MATRIX" |
    grep -Ec '.' ||
    true
)

MUTATION_EXEC_ROWS=$(
    tail -n +2 "$MUT_EXEC_MATRIX" |
    grep -Ec '.' ||
    true
)

MUTATION_KILLED_COUNT=$(
    awk -F '\t' \
        'NR > 1 &&
         $3 == "10" &&
         $5 >= 1 &&
         $7 == "0" &&
         $8 == "PASS" {count++}
         END {print count + 0}' \
        "$MUT_EXEC_MATRIX"
)

echo "POSITIVE_PROPERTY_COUNT=$POSITIVE_PROPERTY_COUNT"
echo "POSITIVE_NON_SUCCESS_COUNT=$POSITIVE_NON_SUCCESS_COUNT"
echo "COMPANION_PROPERTY_COUNT=$COMPANION_PROPERTY_COUNT"
echo "COMPANION_SUCCESS_COUNT=$COMPANION_SUCCESS_COUNT"
echo "COMPANION_FAILURE_COUNT=$COMPANION_FAILURE_COUNT"
echo "COMPANION_UNKNOWN_COUNT=$COMPANION_UNKNOWN_COUNT"
echo "COVERAGE_SATISFIED=$COVERED"
echo "COVERAGE_TOTAL=$COVER_TOTAL"
echo "COVERAGE_FAILED_LINE_COUNT=$COVER_FAILED"
echo "UNWIND_CONTROL_ROW_COUNT=$UNWIND_CONTROL_ROWS"
echo "MUTATION_PLAN_ROW_COUNT=$MUTATION_PLAN_ROWS"
echo "MUTATION_FREEZE_ROW_COUNT=$MUTATION_FREEZE_ROWS"
echo "MUTATION_EXECUTION_ROW_COUNT=$MUTATION_EXEC_ROWS"
echo "MUTATION_KILLED_COUNT=$MUTATION_KILLED_COUNT"

[ "$POSITIVE_PROPERTY_COUNT" -eq "$EXPECTED_POSITIVE_PROPERTY_COUNT" ] &&
[ "$POSITIVE_NON_SUCCESS_COUNT" -eq 0 ] || {
    echo "POSITIVE_CARDINALITY_AUDIT=FAIL"
    exit 20
}

[ "$COMPANION_PROPERTY_COUNT" -eq "$EXPECTED_COMPANION_PROPERTY_COUNT" ] &&
[ "$COMPANION_SUCCESS_COUNT" -eq "$EXPECTED_COMPANION_PROPERTY_COUNT" ] &&
[ "$COMPANION_FAILURE_COUNT" -eq 0 ] &&
[ "$COMPANION_UNKNOWN_COUNT" -eq 0 ] || {
    echo "COMPANION_CARDINALITY_AUDIT=FAIL"
    exit 21
}

[ "$COVERED" -eq "$EXPECTED_COVER_GOAL_COUNT" ] &&
[ "$COVER_TOTAL" -eq "$EXPECTED_COVER_GOAL_COUNT" ] &&
[ "$COVER_FAILED" -eq 0 ] || {
    echo "COVERAGE_CARDINALITY_AUDIT=FAIL"
    exit 22
}

[ "$UNWIND_CONTROL_ROWS" -eq 5 ] || {
    echo "UNWIND_CONTROL_CARDINALITY_AUDIT=FAIL"
    exit 23
}

[ "$MUTATION_PLAN_ROWS" -eq "$EXPECTED_MUTANT_COUNT" ] &&
[ "$MUTATION_FREEZE_ROWS" -eq "$EXPECTED_MUTANT_COUNT" ] &&
[ "$MUTATION_EXEC_ROWS" -eq "$EXPECTED_MUTANT_COUNT" ] &&
[ "$MUTATION_KILLED_COUNT" -eq "$EXPECTED_MUTANT_COUNT" ] || {
    echo "MUTATION_CARDINALITY_AUDIT=FAIL"
    exit 24
}

echo "POSITIVE_CARDINALITY_AUDIT=PASS"
echo "COMPANION_CARDINALITY_AUDIT=PASS"
echo "COVERAGE_CARDINALITY_AUDIT=PASS"
echo "UNWIND_CONTROL_CARDINALITY_AUDIT=PASS"
echo "MUTATION_CARDINALITY_AUDIT=PASS"

echo
echo "============================================================"
echo "E. VERIFY ACCEPTED STATUS LINES"
echo "============================================================"

grep -Fxq \
    "CANDIDATE_STATUS=FROZEN_READY_FOR_POSITIVE_EXECUTION" \
    "$BASE_SUMMARY" || {
        echo "BASE_STATUS_AUDIT=FAIL"
        exit 25
    }

grep -Fxq \
    "MSG_T1_POSITIVE_RESULT=PASS" \
    "$POSITIVE_SUMMARY" || {
        echo "POSITIVE_STATUS_AUDIT=FAIL"
        exit 26
    }

grep -Fxq \
    "REACHABILITY_AND_NONVACUITY_RESULT=PASS" \
    "$NONVAC_SUMMARY" || {
        echo "NONVACUITY_STATUS_AUDIT=FAIL"
        exit 27
    }

grep -Fxq \
    "MUTATION_FAMILY_STATUS=FROZEN_READY_FOR_EXPECTED_FAILURE_EXECUTION" \
    "$MUT_FREEZE_SUMMARY" || {
        echo "MUTATION_FREEZE_STATUS_AUDIT=FAIL"
        exit 28
    }

grep -Fxq \
    "MUTATION_SENSITIVITY_RESULT=PASS" \
    "$MUT_EXEC_SUMMARY" || {
        echo "MUTATION_EXECUTION_STATUS_AUDIT=FAIL"
        exit 29
    }

grep -Fxq \
    "MSG_T1_CORE_PROOF_CAMPAIGN=PASS" \
    "$MUT_EXEC_SUMMARY" || {
        echo "CORE_CAMPAIGN_STATUS_AUDIT=FAIL"
        exit 30
    }

grep -Fxq \
    "CAMPAIGN_STATUS=POSITIVE_NONVACUITY_AND_MUTATION_SENSITIVITY_PASS" \
    "$MUT_EXEC_SUMMARY" || {
        echo "FINAL_CAMPAIGN_STATUS_AUDIT=FAIL"
        exit 31
    }

echo "BASE_STATUS_AUDIT=PASS"
echo "POSITIVE_STATUS_AUDIT=PASS"
echo "NONVACUITY_STATUS_AUDIT=PASS"
echo "MUTATION_FREEZE_STATUS_AUDIT=PASS"
echo "MUTATION_EXECUTION_STATUS_AUDIT=PASS"
echo "CORE_CAMPAIGN_STATUS_AUDIT=PASS"
echo "FINAL_CAMPAIGN_STATUS_AUDIT=PASS"

echo
echo "============================================================"
echo "F. COPY AUTHORITATIVE SMALL RECORDS"
echo "============================================================"

copy_required "$PATH_AMENDMENT" \
    "$RECORDS_BASE/MSG00CDE_PATH_BINDING_AMENDMENT.md" \
    "PATH_BINDING_AMENDMENT" || exit 32

copy_required "$BASE_SUMMARY" \
    "$RECORDS_BASE/MSG01G_R1_FREEZE_SUMMARY.txt" \
    "BASE_SUMMARY" || exit 33

copy_required "$BASE_FREEZE_RECORD" \
    "$RECORDS_BASE/MSG01G_R1_CANDIDATE_FREEZE_RECORD.md" \
    "BASE_FREEZE_RECORD" || exit 34

copy_required "$BASE_EXEC_PLAN" \
    "$RECORDS_BASE/MSG01G_R1_EXECUTION_PLAN.md" \
    "BASE_EXECUTION_PLAN" || exit 35

copy_required "$POSITIVE_SUMMARY" \
    "$RECORDS_POS/MSG01H_POSITIVE_EXECUTION_SUMMARY.txt" \
    "POSITIVE_SUMMARY" || exit 36

copy_required "$POSITIVE_RESULT" \
    "$RECORDS_POS/MSG01H_POSITIVE_EXECUTION_RESULT.md" \
    "POSITIVE_RESULT" || exit 37

copy_required "$POSITIVE_BINDING" \
    "$RECORDS_POS/MSG01H_EXECUTION_INPUT_BINDING.md" \
    "POSITIVE_BINDING" || exit 38

copy_required "$POSITIVE_COMMAND" \
    "$RECORDS_POS/msg_t1_positive_cbmc_command.txt" \
    "POSITIVE_COMMAND" || exit 39

copy_required "$POSITIVE_PARSED" \
    "$RECORDS_POS/msg_t1_positive_parsed_summary.txt" \
    "POSITIVE_PARSED_SUMMARY" || exit 40

copy_required "$NONVAC_SUMMARY" \
    "$RECORDS_NONVAC/MSG01J_R3_REACHABILITY_SUMMARY.txt" \
    "NONVACUITY_SUMMARY" || exit 41

copy_required "$NONVAC_RESULT" \
    "$RECORDS_NONVAC/MSG01J_R3_REACHABILITY_RESULT.md" \
    "NONVACUITY_RESULT" || exit 42

copy_required "$NONVAC_COMPANION_AUDIT" \
    "$RECORDS_NONVAC/accepted_companion_audit.txt" \
    "COMPANION_AUDIT" || exit 43

copy_required "$NONVAC_COVERAGE_PARSED" \
    "$RECORDS_NONVAC/original_model_coverage_parsed_summary.txt" \
    "COVERAGE_PARSED_SUMMARY" || exit 44

copy_required "$NONVAC_CONTROL_MATRIX" \
    "$RECORDS_NONVAC/final_unwind_control_matrix.tsv" \
    "UNWIND_CONTROL_MATRIX" || exit 45

copy_required "$NONVAC_CONTROL_SUMMARY" \
    "$RECORDS_NONVAC/final_unwind_control_summary.txt" \
    "UNWIND_CONTROL_SUMMARY" || exit 46

copy_required "$MUT_PLAN" \
    "$RECORDS_MUT_FREEZE/MUTATION_PLAN.tsv" \
    "MUTATION_PLAN" || exit 47

copy_required "$MUT_WITNESS" \
    "$RECORDS_MUT_FREEZE/SEMANTIC_WITNESS_REPORT.txt" \
    "MUTATION_WITNESS_REPORT" || exit 48

copy_required "$MUT_FREEZE_MATRIX" \
    "$RECORDS_MUT_FREEZE/MUTATION_FREEZE_MATRIX.tsv" \
    "MUTATION_FREEZE_MATRIX" || exit 49

copy_required "$MUT_FREEZE_SUMMARY" \
    "$RECORDS_MUT_FREEZE/MSG01K_R1_MUTATION_FAMILY_FREEZE_SUMMARY.txt" \
    "MUTATION_FREEZE_SUMMARY" || exit 50

copy_required "$MUT_FREEZE_RECORD" \
    "$RECORDS_MUT_FREEZE/MSG01K_R1_MUTATION_FAMILY_FREEZE_RECORD.md" \
    "MUTATION_FREEZE_RECORD" || exit 51

copy_required "$MUT_EXEC_MATRIX" \
    "$RECORDS_MUT_EXEC/MUTATION_EXECUTION_MATRIX.tsv" \
    "MUTATION_EXECUTION_MATRIX" || exit 52

copy_required "$MUT_EXEC_SUMMARY" \
    "$RECORDS_MUT_EXEC/MSG01L_R1_MUTATION_EXECUTION_SUMMARY.txt" \
    "MUTATION_EXECUTION_SUMMARY" || exit 53

copy_required "$MUT_EXEC_RESULT" \
    "$RECORDS_MUT_EXEC/MSG01L_R1_MUTATION_EXECUTION_RESULT.md" \
    "MUTATION_EXECUTION_RESULT" || exit 54

echo "AUTHORITATIVE_SMALL_RECORD_COPY=PASS"

echo
echo "============================================================"
echo "G. COPY CORRECTION HISTORY"
echo "============================================================"

copy_required "$BASE_CORRECTION" \
    "$CORRECTIONS/01_MSG01G_R1_AUDIT_CORRECTION.md" \
    "MSG01G_R1_CORRECTION" || exit 55

copy_required "$I_R1_CORRECTION" \
    "$CORRECTIONS/02_MSG01I_R1_PARSER_CORRECTION.md" \
    "MSG01I_R1_CORRECTION" || exit 56

copy_required "$J_R1_CORRECTION" \
    "$CORRECTIONS/03_MSG01J_R1_DERIVATION_CORRECTION.md" \
    "MSG01J_R1_CORRECTION" || exit 57

copy_required "$J_R2_CORRECTION" \
    "$CORRECTIONS/04_MSG01J_R2_UNWINDING_INTERPRETATION.md" \
    "MSG01J_R2_CORRECTION" || exit 58

copy_required "$NONVAC_CORRECTION" \
    "$CORRECTIONS/05_MSG01J_R3_LOOP_CLASSIFICATION.md" \
    "MSG01J_R3_CORRECTION" || exit 59

copy_required "$MUT_PERMISSION_CORRECTION" \
    "$CORRECTIONS/06_MSG01K_R1_PERMISSION_CORRECTION.md" \
    "MSG01K_R1_CORRECTION" || exit 60

CORRECTION_RECORD_COUNT=$(
    find "$CORRECTIONS" -maxdepth 1 -type f |
    wc -l
)

echo "CORRECTION_RECORD_COUNT=$CORRECTION_RECORD_COUNT"

[ "$CORRECTION_RECORD_COUNT" -eq 6 ] || {
    echo "CORRECTION_RECORD_CARDINALITY=FAIL"
    exit 61
}

echo "CORRECTION_RECORD_CARDINALITY=PASS"

echo
echo "============================================================"
echo "H. CREATE FROZEN SOURCE/HARNESS SNAPSHOT"
echo "============================================================"

cp -- "$COMPRESS_C" "$SNAPSHOT/source/compress.c"
cp -- "$COMPRESS_H" "$SNAPSHOT/source/compress.h"
cp -- "$BASE_HARNESS" \
    "$SNAPSHOT/harness/msg_t1_exact_fips_candidate_v4.c"

SNAPSHOT_COMPRESS_C_SHA=$(
    sha256sum "$SNAPSHOT/source/compress.c" |
    awk '{print $1}'
)

SNAPSHOT_COMPRESS_H_SHA=$(
    sha256sum "$SNAPSHOT/source/compress.h" |
    awk '{print $1}'
)

SNAPSHOT_HARNESS_SHA=$(
    sha256sum "$SNAPSHOT/harness/msg_t1_exact_fips_candidate_v4.c" |
    awk '{print $1}'
)

[ "$SNAPSHOT_COMPRESS_C_SHA" = "$EXPECTED_COMPRESS_C_SHA256" ] &&
[ "$SNAPSHOT_COMPRESS_H_SHA" = "$EXPECTED_COMPRESS_H_SHA256" ] &&
[ "$SNAPSHOT_HARNESS_SHA" = "$EXPECTED_BASE_HARNESS_SHA256" ] || {
    echo "FROZEN_SNAPSHOT_BINDING=FAIL"
    exit 62
}

echo "FROZEN_SNAPSHOT_BINDING=PASS"

echo
echo "============================================================"
echo "I. COPY MANIFESTS AND CREATE PACKAGE DIGEST TABLE"
echo "============================================================"

cp -- "$BASE_MANIFEST" "$MANIFESTS/MSG01G_R1_ARTIFACT_MANIFEST.sha256"
cp -- "$BASE_MANIFEST_SHA" "$MANIFESTS/MSG01G_R1_ARTIFACT_MANIFEST.sha256.sha256"

cp -- "$POSITIVE_MANIFEST" "$MANIFESTS/MSG01H_ARTIFACT_MANIFEST.sha256"
cp -- "$POSITIVE_MANIFEST_SHA" "$MANIFESTS/MSG01H_ARTIFACT_MANIFEST.sha256.sha256"

cp -- "$NONVAC_MANIFEST" "$MANIFESTS/MSG01J_R3_ARTIFACT_MANIFEST.sha256"
cp -- "$NONVAC_MANIFEST_SHA" "$MANIFESTS/MSG01J_R3_ARTIFACT_MANIFEST.sha256.sha256"

cp -- "$MUT_FREEZE_MANIFEST" "$MANIFESTS/MSG01K_R1_ARTIFACT_MANIFEST.sha256"
cp -- "$MUT_FREEZE_MANIFEST_SHA" "$MANIFESTS/MSG01K_R1_ARTIFACT_MANIFEST.sha256.sha256"

cp -- "$MUT_EXEC_MANIFEST" "$MANIFESTS/MSG01L_R1_ARTIFACT_MANIFEST.sha256"
cp -- "$MUT_EXEC_MANIFEST_SHA" "$MANIFESTS/MSG01L_R1_ARTIFACT_MANIFEST.sha256.sha256"

printf '%s\t%s\t%s\t%s\n' \
    "STAGE" \
    "DIRECTORY" \
    "MANIFEST_SHA256" \
    "MANIFEST_SELF_HASH_SHA256" \
    > "$PACKAGE_DIGESTS"

for ENTRY in \
    "MSG01G_R1|$BASE_OUT|$BASE_MANIFEST|$BASE_MANIFEST_SHA" \
    "MSG01H|$POSITIVE|$POSITIVE_MANIFEST|$POSITIVE_MANIFEST_SHA" \
    "MSG01J_R3|$NONVAC|$NONVAC_MANIFEST|$NONVAC_MANIFEST_SHA" \
    "MSG01K_R1|$MUT_FREEZE_OUT|$MUT_FREEZE_MANIFEST|$MUT_FREEZE_MANIFEST_SHA" \
    "MSG01L_R1|$MUT_EXEC|$MUT_EXEC_MANIFEST|$MUT_EXEC_MANIFEST_SHA"
do
    IFS='|' read -r STAGE ROOT MANIFEST SELF_HASH <<< "$ENTRY"

    printf '%s\t%s\t%s\t%s\n' \
        "$STAGE" \
        "$ROOT" \
        "$(sha256sum "$MANIFEST" | awk '{print $1}')" \
        "$(sha256sum "$SELF_HASH" | awk '{print $1}')" \
        >> "$PACKAGE_DIGESTS"
done

cat "$PACKAGE_DIGESTS"
echo "AUTHORITATIVE_PACKAGE_DIGEST_TABLE=PASS"

echo
echo "============================================================"
echo "J. CREATE MUTANT RESULT HASH TABLE"
echo "============================================================"

printf '%s\t%s\t%s\t%s\t%s\n' \
    "MUTANT_ID" \
    "RESULT_JSON_SHA256" \
    "CBMC_EXIT" \
    "EXACT_FAILURE_COUNT" \
    "AUDIT" \
    > "$MUTANT_HASHES"

for RESULT_DIR in "$MUT_EXEC"/results/*; do
    [ -d "$RESULT_DIR" ] || continue

    MUTANT_ID=$(basename "$RESULT_DIR")
    RESULT_JSON="$RESULT_DIR/result.json"
    EXIT_FILE="$RESULT_DIR/exit_code.txt"
    PARSED="$RESULT_DIR/parsed_summary.txt"

    [ -f "$RESULT_JSON" ] &&
    [ -f "$EXIT_FILE" ] &&
    [ -f "$PARSED" ] || {
        echo "MUTANT_RESULT_RECORD_INCOMPLETE=$MUTANT_ID"
        exit 63
    }

    CBMC_EXIT=$(tr -d '\r\n' < "$EXIT_FILE")

    EXACT_FAILURE_COUNT=$(
        awk -F= \
            '$1=="EXACT_ASSERTION_FAILURE_COUNT" {print $2}' \
            "$PARSED"
    )

    MUTANT_AUDIT=$(
        awk -F= \
            '$1=="MUTATION_EXPECTED_FAILURE_AUDIT" {print $2}' \
            "$PARSED"
    )

    printf '%s\t%s\t%s\t%s\t%s\n' \
        "$MUTANT_ID" \
        "$(sha256sum "$RESULT_JSON" | awk '{print $1}')" \
        "$CBMC_EXIT" \
        "$EXACT_FAILURE_COUNT" \
        "$MUTANT_AUDIT" \
        >> "$MUTANT_HASHES"
done

MUTANT_HASH_ROW_COUNT=$(
    tail -n +2 "$MUTANT_HASHES" |
    grep -Ec '.' ||
    true
)

[ "$MUTANT_HASH_ROW_COUNT" -eq "$EXPECTED_MUTANT_COUNT" ] || {
    echo "MUTANT_RESULT_HASH_CARDINALITY=FAIL"
    exit 64
}

echo "MUTANT_RESULT_HASH_CARDINALITY=PASS"
cat "$MUTANT_HASHES"

echo
echo "============================================================"
echo "K. WRITE FINAL EVIDENCE MATRIX"
echo "============================================================"

printf '%s\t%s\t%s\t%s\t%s\n' \
    "EVIDENCE_CLASS" \
    "AUTHORITATIVE_STAGE" \
    "ACCEPTANCE_RESULT" \
    "KEY_COUNT" \
    "BOUND_ARTIFACT" \
    > "$EVIDENCE_MATRIX"

printf '%s\t%s\t%s\t%s\t%s\n' \
    "SOURCE_AND_MODEL_FREEZE" \
    "MSG01G_R1" \
    "PASS" \
    "4 reachable functions; 5 reachable loops" \
    "$BASE_GOTO_SHA" \
    >> "$EVIDENCE_MATRIX"

printf '%s\t%s\t%s\t%s\t%s\n' \
    "POSITIVE_EXACT_PROOF" \
    "MSG01H" \
    "PASS" \
    "$POSITIVE_PROPERTY_COUNT/$POSITIVE_PROPERTY_COUNT successful properties" \
    "$POSITIVE_JSON_SHA" \
    >> "$EVIDENCE_MATRIX"

printf '%s\t%s\t%s\t%s\t%s\n' \
    "COMPANION_SAFETY_AND_ANCHOR" \
    "MSG01J_R3" \
    "PASS" \
    "$COMPANION_SUCCESS_COUNT/$COMPANION_PROPERTY_COUNT successful properties" \
    "$(sha256sum "$NONVAC_COMPANION_AUDIT" | awk '{print $1}')" \
    >> "$EVIDENCE_MATRIX"

printf '%s\t%s\t%s\t%s\t%s\n' \
    "REACHABILITY_AND_NONVACUITY" \
    "MSG01J_R3" \
    "PASS" \
    "$COVERED/$COVER_TOTAL cover goals satisfied; 4 multi-iteration sensitivity controls" \
    "$(sha256sum "$NONVAC_COVERAGE" | awk '{print $1}')" \
    >> "$EVIDENCE_MATRIX"

printf '%s\t%s\t%s\t%s\t%s\n' \
    "MUTATION_FAMILY_FREEZE" \
    "MSG01K_R1" \
    "PASS" \
    "$MUTATION_FREEZE_ROWS frozen non-equivalent mutants" \
    "$(sha256sum "$MUT_FREEZE_MATRIX" | awk '{print $1}')" \
    >> "$EVIDENCE_MATRIX"

printf '%s\t%s\t%s\t%s\t%s\n' \
    "MUTATION_SENSITIVITY" \
    "MSG01L_R1" \
    "PASS" \
    "$MUTATION_KILLED_COUNT/$MUTATION_EXEC_ROWS mutants killed; 0 survivors" \
    "$(sha256sum "$MUT_EXEC_MATRIX" | awk '{print $1}')" \
    >> "$EVIDENCE_MATRIX"

column -t -s $'\t' "$EVIDENCE_MATRIX" 2>/dev/null ||
cat "$EVIDENCE_MATRIX"

echo "FINAL_EVIDENCE_MATRIX=PASS"

echo
echo "============================================================"
echo "L. WRITE PROFESSOR-READY THEOREM AND BOUNDARIES"
echo "============================================================"

cat > "$THEOREM" <<EOF
# Final MSG-T1 Theorem Record — \`mlk_poly_tomsg\`

## Authoritative implementation

- repository: \`$SOURCE\`;
- commit: \`$EXPECTED_COMMIT\`;
- production source:
  - \`mlkem/src/compress.c\`, SHA-256 \`$EXPECTED_COMPRESS_C_SHA256\`;
  - \`mlkem/src/compress.h\`, SHA-256 \`$EXPECTED_COMPRESS_H_SHA256\`;
- frozen harness SHA-256: \`$EXPECTED_BASE_HARNESS_SHA256\`;
- frozen positive GOTO SHA-256: \`$EXPECTED_BASE_GOTO_SHA256\`;
- parameter-set build used by the campaign: ML-KEM-768;
- C model: C90, no assembly path, recorded custom zeroisation support.

## Proved functional property

Let \`a\` be a valid ML-KEM polynomial object with 256 coefficients satisfying

\`\`\`text
0 <= a.coeffs[k] < 3329
\`\`\`

for every index \`k\` in \`0..255\`.

After execution of the frozen production \`mlk_poly_tomsg(msg, &a)\` body, every
output bit satisfies

\`\`\`text
((msg[k >> 3] >> (k & 7)) & 1)
    ==
((a.coeffs[k] >= 833) && (a.coeffs[k] <= 2496))
\`\`\`

for every \`k\` in \`0..255\`.

Equivalently, the output bit is zero for coefficients \`0..832\`, one for
coefficients \`833..2496\`, and zero for coefficients \`2497..3328\`. The
coefficient-to-message mapping is the frozen least-significant-bit-first
packing relation used by the harness.

## Authoritative evidence

### Frozen model

MSG-01G-R1 froze and validated the candidate before positive solving.

### Positive proof

MSG-01H returned:

\`\`\`text
CBMC_EXIT=0
PROPERTY_RECORD_COUNT=$POSITIVE_PROPERTY_COUNT
SUCCESS_COUNT=$POSITIVE_PROPERTY_COUNT
FAILURE_COUNT=0
UNKNOWN_COUNT=0
\`\`\`

The exact every-bit assertion succeeded together with the recorded safety
checks.

### Reachability and non-vacuity

MSG-01J-R3 established:

\`\`\`text
COMPANION_PROPERTY_RECORD_COUNT=$COMPANION_PROPERTY_COUNT
COMPANION_SUCCESS_COUNT=$COMPANION_SUCCESS_COUNT
COVERAGE_SATISFIED=$COVERED
COVERAGE_TOTAL=$COVER_TOTAL
COVERAGE_FAILED_LINE_COUNT=$COVER_FAILED
\`\`\`

The registered witnesses include both threshold transitions, the minimum and
maximum canonical coefficients, interior witnesses for all three output
regions, and flat output indices 0, 127 and 255.

Insufficient bounds were detected for all four multi-iteration reachable
loops. The macro-origin loop was separately classified as complete with bound
one.

### Mutation sensitivity

MSG-01K-R1 froze eight non-equivalent mutants before solving. MSG-01L-R1
executed and killed all eight:

\`\`\`text
TOTAL_MUTANTS=$MUTATION_EXEC_ROWS
KILLED_MUTANTS=$MUTATION_KILLED_COUNT
SURVIVING_MUTANTS=0
\`\`\`

Every mutant failed the registered exact functional assertion. No mutant was
accepted because of an unwinding failure or unrelated property failure.

## Final verdict

Within the frozen build, harness, canonical coefficient domain, assumptions,
safety checks and complete-loop model recorded by this campaign, CBMC found no
counterexample to the exact \`mlk_poly_tomsg\` refinement property.

The positive result is supported by explicit reachability/non-vacuity evidence
and sensitivity to the eight frozen implementation and oracle/assertion
mutants.

\`\`\`text
MSG_T1_CORE_PROOF_CAMPAIGN=PASS
\`\`\`
EOF

cat > "$BOUNDARIES" <<'EOF'
# MSG-T1 Assurance Boundaries

The campaign proves one property-specific theorem. It does not prove every
property of ML-KEM or every property of `mlk_poly_tomsg`.

## Included

- the frozen production `mlk_poly_tomsg` implementation path;
- the production `mlk_scalar_compress_d1` helper reached by that path;
- all 256 canonical coefficients;
- all 32 output bytes and all 256 output bits;
- exact canonical Compress1 threshold semantics;
- least-significant-bit-first packing;
- recorded memory, pointer, arithmetic, conversion, shift and division checks;
- complete treatment of all reachable multi-iteration loops;
- twelve registered non-vacuity witnesses;
- eight frozen mutation-sensitivity controls.

## Excluded

- coefficients outside `0..3328`;
- mathematical claims for non-canonical polynomial representations;
- complete ML-KEM encapsulation, decapsulation or decryption correctness;
- correctness of functions not in the frozen reachable call path;
- every ML-KEM parameter-set build;
- assembly implementations or alternative configuration paths;
- constant-time, timing, cache, power, electromagnetic or other side-channel
  properties;
- compiler-machine-code equivalence;
- universal completeness over every possible implementation, oracle, harness
  or assertion mutation;
- a claim that the entire mlkem-native repository is formally verified;
- a claim of universal novelty or “first proof”.

The theorem is conditional on the frozen source, build configuration, harness,
assumptions, CBMC semantics and recorded verification options.
EOF

cat > "$HISTORY" <<'EOF'
# MSG-T1 Campaign History and Correction Record

## Clean-room and source binding

The campaign began by binding the clean-room work to the authoritative
mlkem-native source commit and production source hashes. The path-binding
amendment records that the critical files were byte-identical across the
examined source locations.

## Candidate development

Early candidates were rejected at preflight for static-audit, namespace or
structural reasons. These were not functional counterexamples.

MSG-01F produced the accepted direct-pragma candidate. MSG-01G initially
misclassified retained arithmetic checks; MSG-01G-R1 corrected that audit and
froze the accepted candidate before solving.

## Positive proof

MSG-01H executed the frozen positive model and obtained an all-success result.

## Reachability and non-vacuity

MSG-01I initially compared raw call graphs without accounting for the original
model’s cover primitive. MSG-01I-R1 corrected that instrumentation-aware
comparison.

MSG-01J attempted to derive symbolic-execution unwinding properties from a
static inventory. MSG-01J-R1 corrected the derivation but still expected
standalone full-bound unwind records. Diagnostic evidence showed no such
records because the full bounds were not reached.

MSG-01J-R2 introduced insufficient-bound controls. One macro-origin loop was
incorrectly expected to fail at bound one. MSG-01J-R3 bound every target loop
to its exact source statement, classified that loop correctly, completed the
remaining controls and obtained twelve-of-twelve coverage.

## Mutation sensitivity

The first combined MSG-01K/L attempt used permission-preserving copies of
read-only frozen files. Mutation generation stopped before any mutant model
was built or solved.

MSG-01K-R1 corrected the isolated-copy method while preserving all
authoritative frozen inputs. It froze eight validated non-equivalent mutants
before solving. MSG-01L-R1 then killed all eight with the exact MSG-T1
assertion.

## Scientific treatment of corrections

Rejected attempts are preserved as provenance. No rejected result is presented
as a theorem failure. No accepted theorem was obtained by deleting a failing
property, weakening the canonical domain, suppressing an unexpected
counterexample, changing the authoritative production source, or bypassing a
failed mutation.
EOF

cat > "$CHAIN" <<EOF
# Chain of Custody

## Root source identity

\`\`\`text
COMMIT=$EXPECTED_COMMIT
COMPRESS_C_SHA256=$EXPECTED_COMPRESS_C_SHA256
COMPRESS_H_SHA256=$EXPECTED_COMPRESS_H_SHA256
\`\`\`

## Frozen theorem inputs

\`\`\`text
HARNESS_SHA256=$EXPECTED_BASE_HARNESS_SHA256
GOTO_SHA256=$EXPECTED_BASE_GOTO_SHA256
\`\`\`

## Positive result

\`\`\`text
POSITIVE_JSON_SHA256=$EXPECTED_POSITIVE_JSON_SHA256
\`\`\`

## Authoritative stages

1. MSG-01G-R1 — candidate freeze;
2. MSG-01H — positive proof;
3. MSG-01J-R3 — reachability and non-vacuity;
4. MSG-01K-R1 — mutation-family freeze;
5. MSG-01L-R1 — mutation execution;
6. MSG-01M — non-solving consolidation.

Every stage’s manifest and manifest self-hash were independently rechecked
before this consolidation was written. Every accepted source evidence tree was
also checked for its read-only lock.

The full raw results remain in their original locked stage directories. This
consolidation package is a theorem record, integrity index and small-record
snapshot; it does not silently replace the original raw evidence.
EOF

cat > "$README" <<'EOF'
# MSG-01M Final Evidence Consolidation

This directory is the final non-solving consolidation package for theorem
MSG-T1 concerning `mlk_poly_tomsg`.

Start with:

1. `FINAL_MSG_T1_THEOREM_RECORD.md`;
2. `ASSURANCE_BOUNDARIES.md`;
3. `audit/EVIDENCE_MATRIX.tsv`;
4. `CHAIN_OF_CUSTODY.md`;
5. `CAMPAIGN_HISTORY_AND_CORRECTIONS.md`.

The `records/` directory contains copies of the small authoritative summaries,
result records, execution command and matrices. The `source_manifests/`
directory contains copies of the five accepted stage manifests and their
self-hashes. The `frozen_snapshot/` directory contains the exact production
source/header and theorem harness snapshot.

This package contains no new CBMC solving result. It re-verifies and binds the
accepted evidence generated by MSG-01G-R1, MSG-01H, MSG-01J-R3, MSG-01K-R1 and
MSG-01L-R1.
EOF

echo "FINAL_THEOREM_RECORD_WRITTEN=PASS"
echo "ASSURANCE_BOUNDARIES_WRITTEN=PASS"
echo "CAMPAIGN_HISTORY_WRITTEN=PASS"
echo "CHAIN_OF_CUSTODY_WRITTEN=PASS"
echo "README_WRITTEN=PASS"

echo
echo "============================================================"
echo "M. WRITE FINAL AUDIT AND CAMPAIGN SUMMARY"
echo "============================================================"

{
echo "MSG-01M FINAL CONSOLIDATION AUDIT"
echo
echo "SOURCE_HEAD_BINDING=PASS"
echo "SOURCE_WORKTREE_CLEAN=PASS"
echo "PRODUCTION_SOURCE_BINDING=PASS"
echo "PATH_BINDING_AMENDMENT=PASS"
echo
echo "MSG01G_R1_MANIFEST_VERIFICATION=PASS"
echo "MSG01H_MANIFEST_VERIFICATION=PASS"
echo "MSG01J_R3_MANIFEST_VERIFICATION=PASS"
echo "MSG01K_R1_MANIFEST_VERIFICATION=PASS"
echo "MSG01L_R1_MANIFEST_VERIFICATION=PASS"
echo "ALL_AUTHORITATIVE_MANIFESTS=PASS"
echo
echo "ALL_AUTHORITATIVE_READ_ONLY_LOCKS=PASS"
echo
echo "POSITIVE_PROPERTY_COUNT=$POSITIVE_PROPERTY_COUNT"
echo "POSITIVE_NON_SUCCESS_COUNT=$POSITIVE_NON_SUCCESS_COUNT"
echo "COMPANION_PROPERTY_COUNT=$COMPANION_PROPERTY_COUNT"
echo "COMPANION_SUCCESS_COUNT=$COMPANION_SUCCESS_COUNT"
echo "COMPANION_FAILURE_COUNT=$COMPANION_FAILURE_COUNT"
echo "COMPANION_UNKNOWN_COUNT=$COMPANION_UNKNOWN_COUNT"
echo "COVERAGE_SATISFIED=$COVERED"
echo "COVERAGE_TOTAL=$COVER_TOTAL"
echo "COVERAGE_FAILED_LINE_COUNT=$COVER_FAILED"
echo "UNWIND_CONTROL_ROW_COUNT=$UNWIND_CONTROL_ROWS"
echo "MUTATION_EXECUTION_ROW_COUNT=$MUTATION_EXEC_ROWS"
echo "MUTATION_KILLED_COUNT=$MUTATION_KILLED_COUNT"
echo
echo "POSITIVE_CARDINALITY_AUDIT=PASS"
echo "COMPANION_CARDINALITY_AUDIT=PASS"
echo "COVERAGE_CARDINALITY_AUDIT=PASS"
echo "UNWIND_CONTROL_CARDINALITY_AUDIT=PASS"
echo "MUTATION_CARDINALITY_AUDIT=PASS"
echo
echo "CORRECTION_RECORD_COUNT=$CORRECTION_RECORD_COUNT"
echo "CORRECTION_RECORD_CARDINALITY=PASS"
echo "FROZEN_SNAPSHOT_BINDING=PASS"
echo "AUTHORITATIVE_PACKAGE_DIGEST_TABLE=PASS"
echo "MUTANT_RESULT_HASH_CARDINALITY=PASS"
echo "FINAL_EVIDENCE_MATRIX=PASS"
echo
echo "CBMC_SOLVING_EXECUTED=NO"
echo "GOTO_REBUILD_EXECUTED=NO"
echo "SOURCE_MUTATION_EXECUTED=NO"
echo "FINAL_CONSOLIDATION_AUDIT=PASS"
} | tee "$FINAL_AUDIT"

{
echo "MSG-01M FINAL MSG-T1 CAMPAIGN SUMMARY"
echo
echo "THEOREM=Exact canonical-domain mlk_poly_tomsg functional refinement"
echo "SOURCE_COMMIT=$EXPECTED_COMMIT"
echo
echo "CANDIDATE_FREEZE=PASS"
echo "POSITIVE_EXACT_PROOF=PASS"
echo "REACHABILITY_AND_NONVACUITY=PASS"
echo "MUTATION_FAMILY_FREEZE=PASS"
echo "MUTATION_SENSITIVITY=PASS"
echo
echo "POSITIVE_PROPERTIES=$POSITIVE_PROPERTY_COUNT/$POSITIVE_PROPERTY_COUNT"
echo "COMPANION_PROPERTIES=$COMPANION_SUCCESS_COUNT/$COMPANION_PROPERTY_COUNT"
echo "COVERAGE_GOALS=$COVERED/$COVER_TOTAL"
echo "MUTANTS_KILLED=$MUTATION_KILLED_COUNT/$MUTATION_EXEC_ROWS"
echo "SURVIVING_MUTANTS=0"
echo
echo "MSG_T1_CORE_PROOF_CAMPAIGN=PASS"
echo "FINAL_CONSOLIDATION_AUDIT=PASS"
echo "FINAL_EVIDENCE_CONSOLIDATION=PASS"
echo "CAMPAIGN_STATUS=COMPLETE_WITHIN_FROZEN_MSG_T1_SCOPE"
echo
echo "CBMC_SOLVING_EXECUTED=NO"
echo "FINAL_RAW_EVIDENCE_REPLACED=NO"
echo "FINAL_ARCHIVE_CREATION_PENDING=YES"
} | tee "$FINAL_SUMMARY"

nl -ba "$THEOREM"
nl -ba "$BOUNDARIES"

echo
echo "MSG01M_CONTENT_COMPLETE"

} 2>&1 | tee "$MASTER"

CAPTURE_STATUS=${PIPESTATUS[0]}

if [ "$CAPTURE_STATUS" -eq 0 ]; then
    (
        cd "$OUT" || exit 1

        find . \
            -type f \
            ! -name 'MSG01M_ARTIFACT_MANIFEST.sha256' \
            ! -name 'MSG01M_ARTIFACT_MANIFEST.sha256.sha256' \
            -print0 |
        sort -z |
        xargs -0 sha256sum \
            > "$(basename "$FINAL_MANIFEST")"

        sha256sum -c \
            "$(basename "$FINAL_MANIFEST")"

        sha256sum \
            "$(basename "$FINAL_MANIFEST")" \
            > "$(basename "$FINAL_MANIFEST_SHA")"
    )

    FINAL_MANIFEST_EXIT=$?

    if [ "$FINAL_MANIFEST_EXIT" -ne 0 ]; then
        echo "FINAL_CONSOLIDATION_MANIFEST_VERIFICATION=FAIL"
        CAPTURE_STATUS=65
    else
        echo "FINAL_CONSOLIDATION_MANIFEST_VERIFICATION=PASS"

        find "$OUT" -type f -exec chmod 0444 {} +
        find "$OUT" -type d -exec chmod 0555 {} +

        echo "FINAL_CONSOLIDATION_FILE_MODE=0444"
        echo "FINAL_CONSOLIDATION_DIRECTORY_MODE=0555"
        echo "FINAL_CONSOLIDATION_EVIDENCE_LOCK=PASS"
    fi
fi

if [ "$CAPTURE_STATUS" -eq 0 ]; then
    tar \
        --sort=name \
        --mtime='UTC 2026-07-23 00:00:00' \
        --owner=0 \
        --group=0 \
        --numeric-owner \
        -cf - \
        -C "$CAMPAIGN" \
        "$(basename "$OUT")" |
    gzip -n > "$ARCHIVE"

    ARCHIVE_PIPE_STATUSES=("${PIPESTATUS[@]}")
    ARCHIVE_CREATE_EXIT="${ARCHIVE_PIPE_STATUSES[0]}"
    GZIP_CREATE_EXIT="${ARCHIVE_PIPE_STATUSES[1]}"

    if [ "$ARCHIVE_CREATE_EXIT" -ne 0 ] ||
       [ "$GZIP_CREATE_EXIT" -ne 0 ] ||
       [ ! -s "$ARCHIVE" ]; then
        echo "FINAL_ARCHIVE_CREATION=FAIL"
        CAPTURE_STATUS=66
    else
        gzip -t "$ARCHIVE"
        GZIP_TEST_EXIT=$?

        tar -tzf "$ARCHIVE" \
            > "$ARCHIVE_LISTING"

        TAR_LIST_EXIT=$?

        if [ "$GZIP_TEST_EXIT" -ne 0 ] ||
           [ "$TAR_LIST_EXIT" -ne 0 ]; then
            echo "FINAL_ARCHIVE_VERIFICATION=FAIL"
            CAPTURE_STATUS=67
        else
            sha256sum "$ARCHIVE" > "$ARCHIVE_SHA"
            chmod 0444 "$ARCHIVE" "$ARCHIVE_SHA" "$ARCHIVE_LISTING"
            echo "FINAL_ARCHIVE_CREATION=PASS"
            echo "FINAL_ARCHIVE_VERIFICATION=PASS"
            echo "FINAL_ARCHIVE_SHA256=$(sha256sum "$ARCHIVE" | awk '{print $1}')"
            echo "FINAL_ARCHIVE_FILE_MODE=0444"
        fi
    fi
fi

echo
echo "============================================================"
echo "MSG-01M OUTPUTS"
echo "============================================================"
echo "OUT=$OUT"
echo "THEOREM=$THEOREM"
echo "BOUNDARIES=$BOUNDARIES"
echo "HISTORY=$HISTORY"
echo "CHAIN=$CHAIN"
echo "EVIDENCE_MATRIX=$EVIDENCE_MATRIX"
echo "PACKAGE_DIGESTS=$PACKAGE_DIGESTS"
echo "MUTANT_HASHES=$MUTANT_HASHES"
echo "FINAL_AUDIT=$FINAL_AUDIT"
echo "FINAL_SUMMARY=$FINAL_SUMMARY"
echo "FINAL_MANIFEST=$FINAL_MANIFEST"
echo "MASTER=$MASTER"
echo "ARCHIVE=$ARCHIVE"
echo "ARCHIVE_SHA=$ARCHIVE_SHA"
echo "ARCHIVE_LISTING=$ARCHIVE_LISTING"
echo "CAPTURE_STATUS=$CAPTURE_STATUS"

exit "$CAPTURE_STATUS"
