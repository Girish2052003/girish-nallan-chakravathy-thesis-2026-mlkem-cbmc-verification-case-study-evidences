#!/usr/bin/env bash

set -u

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

EXPECTED_ORIGINAL_GOTO_SHA256="63291a6ba949254bffb56cdc899e4567edcd1502bde091038c70988dfa94705c"
EXPECTED_COMPANION_GOTO_SHA256="540df0b0c8f751cd5d4e2d981f6ab587f84bba442b848999e159c3af32e18200"

EXPECTED_POSITIVE_JSON_SHA256="3b32112c5537a95d470b0b866c1edf6cb1f8c3be408188c9fc2cdbf91fab40ee"
EXPECTED_COMPANION_JSON_SHA256="d78f0cbc052ded4bed75cec905c5321c2e0176b78316ce08ff4ff7c1acef249d"

EXPECTED_U1_JSON_SHA256="29b6861a0fb7739f4c843172c0943deec53fe6cf3aed9c8aebecf7b1d73e4dc3"
EXPECTED_U2_JSON_SHA256="ff715a91c2f4a1e0719c0df348b27e6da0a4d55bdfca233eb82ff0783f654144"
EXPECTED_U3_JSON_SHA256="d78f0cbc052ded4bed75cec905c5321c2e0176b78316ce08ff4ff7c1acef249d"

EXPECTED_FAILURE_PARSER_SHA256="057d261390942e9d928928bbeba4d2b346b354bf0e6738774b37b1bca7544fd2"

EXPECTED_UNWINDSET="main.0:257,main.1:257,mlk_msg01i_poly_tomsg.0:257,mlk_msg01i_poly_tomsg.1:257,mlk_msg01i_poly_tomsg.2:257"

SOURCE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
COMPRESS_C="$SOURCE/mlkem/src/compress.c"

CAMPAIGN="$HOME/THESIS-2026/mlk_poly_tomsg_cleanroom"

POSITIVE="$CAMPAIGN/MSG01H_T1_AUTHORITATIVE_POSITIVE_RUN1_af4c5abdd595"
POSITIVE_JSON="$POSITIVE/results/msg_t1_positive_cbmc_result.json"
POSITIVE_SUMMARY="$POSITIVE/MSG01H_POSITIVE_EXECUTION_SUMMARY.txt"
POSITIVE_MANIFEST="$POSITIVE/MSG01H_ARTIFACT_MANIFEST.sha256"
POSITIVE_MANIFEST_SHA="$POSITIVE_MANIFEST.sha256"

CONTROL_OUT="$CAMPAIGN/MSG01I_R1_T1_REACHABILITY_CONTROL_FREEZE_V1_af4c5abdd595"
FAMILY="$CONTROL_OUT/frozen_reachability_family_v1"

ORIGINAL_GOTO="$FAMILY/build/msg_t1_reachability_original.goto"
COMPANION_GOTO="$FAMILY/build/msg_t1_reachability_companion.goto"
UNWINDSET_FILE="$FAMILY/inspection/companion_unwindset.txt"

CONTROL_SUMMARY="$FAMILY/MSG01I_R1_REACHABILITY_PREFLIGHT_SUMMARY.txt"
CONTROL_FREEZE="$FAMILY/MSG01I_R1_REACHABILITY_FAMILY_FREEZE_RECORD.md"
COVER_MAP="$FAMILY/MSG01I_R1_COVER_GOAL_MAP.md"

CONTROL_MANIFEST="$CONTROL_OUT/MSG01I_R1_ARTIFACT_MANIFEST.sha256"
CONTROL_MANIFEST_SHA="$CONTROL_MANIFEST.sha256"

R1="$CAMPAIGN/MSG01J_R1_T1_REACHABILITY_NONVACUITY_RUN1_af4c5abdd595"
COMPANION_JSON="$R1/companion_results/companion_cbmc_result.json"
COMPANION_EXIT_FILE="$R1/companion_results/companion_cbmc_exit_code.txt"

R2="$CAMPAIGN/MSG01J_R2_T1_REACHABILITY_NONVACUITY_RUN1_af4c5abdd595"

U1_DIR="$R2/insufficient_unwind_controls/U1_MAIN_ASSUMPTION_LOOP"
U2_DIR="$R2/insufficient_unwind_controls/U2_MAIN_ASSERTION_LOOP"
U3_DIR="$R2/insufficient_unwind_controls/U3_TARGET_LOOP_0"

U1_JSON="$U1_DIR/result.json"
U2_JSON="$U2_DIR/result.json"
U3_JSON="$U3_DIR/result.json"

U1_EXIT="$U1_DIR/exit_code.txt"
U2_EXIT="$U2_DIR/exit_code.txt"
U3_EXIT="$U3_DIR/exit_code.txt"

U1_PARSED="$U1_DIR/parsed_summary.txt"
U2_PARSED="$U2_DIR/parsed_summary.txt"
U3_PARSED="$U3_DIR/parsed_summary.txt"

INPUT_FAILURE_PARSER="$R2/support/parse_unwind_expected_failure.py"

OUT="$CAMPAIGN/MSG01J_R3_T1_REACHABILITY_NONVACUITY_FINAL_af4c5abdd595"

FROZEN_INPUTS="$OUT/frozen_inputs"
INSPECTION="$OUT/inspection"
COMMANDS="$OUT/commands"
REUSED="$OUT/reused_controls"
NEW_CONTROLS="$OUT/new_controls"
COVERAGE="$OUT/coverage"
LOGS="$OUT/logs"
RESOURCE="$OUT/resource_usage"
SUPPORT="$OUT/support"
PROVENANCE="$OUT/provenance"

FAILURE_PARSER="$SUPPORT/parse_unwind_expected_failure.py"

LOOP_INVENTORY="$INSPECTION/fresh_loop_inventory.txt"
LOOP_MAP="$INSPECTION/target_loop_source_map.txt"
SOURCE_EXCERPT="$INSPECTION/compress_c_lines_716_732.txt"
U3_CLASSIFICATION="$INSPECTION/target_loop_0_classification.txt"

COMPANION_AUDIT="$INSPECTION/accepted_companion_audit.txt"
CONTROL_MATRIX="$NEW_CONTROLS/final_unwind_control_matrix.tsv"
CONTROL_SUMMARY="$NEW_CONTROLS/final_unwind_control_summary.txt"

COVERAGE_STDOUT="$COVERAGE/original_model_coverage.txt"
COVERAGE_STDERR="$LOGS/original_model_coverage_stderr.txt"
COVERAGE_RESOURCE="$RESOURCE/original_model_coverage_resource_usage.txt"
COVERAGE_EXIT_FILE="$COVERAGE/original_model_coverage_exit_code.txt"
COVERAGE_COMMAND="$COMMANDS/original_model_coverage_command.txt"
COVERAGE_PARSED="$COVERAGE/original_model_coverage_parsed_summary.txt"

CORRECTION_RECORD="$OUT/MSG01J_R3_LOOP_CLASSIFICATION_RECORD.md"
RESULT_RECORD="$OUT/MSG01J_R3_REACHABILITY_RESULT.md"
SUMMARY="$OUT/MSG01J_R3_REACHABILITY_SUMMARY.txt"

MASTER="$OUT/MSG01J_R3_TERMINAL_CAPTURE.txt"
MANIFEST="$OUT/MSG01J_R3_ARTIFACT_MANIFEST.sha256"
MANIFEST_SHA="$MANIFEST.sha256"

if [ -e "$OUT" ]; then
    echo "OUTPUT_DIRECTORY_ALREADY_EXISTS=$OUT"
    echo "CAPTURE_STATUS=1"
    exit 1
fi

mkdir -p \
    "$FROZEN_INPUTS" \
    "$INSPECTION" \
    "$COMMANDS" \
    "$REUSED" \
    "$NEW_CONTROLS" \
    "$COVERAGE" \
    "$LOGS" \
    "$RESOURCE" \
    "$SUPPORT" \
    "$PROVENANCE"

{
echo "============================================================"
echo "MSG-01J-R3 — COMPLETE MSG-T1 REACHABILITY/NON-VACUITY"
echo "============================================================"
echo
echo "CAPTURE_UTC=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
echo "SOURCE=$SOURCE"
echo "FAMILY=$FAMILY"
echo "OUT=$OUT"
echo

echo "============================================================"
echo "A. FROZEN SOURCE, MODEL AND PRIOR-RESULT BINDING"
echo "============================================================"

SOURCE_HEAD=$(git -C "$SOURCE" rev-parse HEAD)
SOURCE_STATUS=$(git -C "$SOURCE" status --porcelain=v1)

ORIGINAL_SHA=$(sha256sum "$ORIGINAL_GOTO" | awk '{print $1}')
COMPANION_SHA=$(sha256sum "$COMPANION_GOTO" | awk '{print $1}')
POSITIVE_JSON_SHA=$(sha256sum "$POSITIVE_JSON" | awk '{print $1}')
COMPANION_JSON_SHA=$(sha256sum "$COMPANION_JSON" | awk '{print $1}')

U1_SHA=$(sha256sum "$U1_JSON" | awk '{print $1}')
U2_SHA=$(sha256sum "$U2_JSON" | awk '{print $1}')
U3_SHA=$(sha256sum "$U3_JSON" | awk '{print $1}')

PARSER_SHA=$(sha256sum "$INPUT_FAILURE_PARSER" | awk '{print $1}')

U1_RECORDED_EXIT=$(tr -d '\r\n' < "$U1_EXIT")
U2_RECORDED_EXIT=$(tr -d '\r\n' < "$U2_EXIT")
U3_RECORDED_EXIT=$(tr -d '\r\n' < "$U3_EXIT")

COMPANION_RECORDED_EXIT=$(
    tr -d '\r\n' < "$COMPANION_EXIT_FILE"
)

UNWINDSET=$(tr -d '\r\n' < "$UNWINDSET_FILE")

echo "SOURCE_HEAD=$SOURCE_HEAD"
echo "ORIGINAL_GOTO_SHA256=$ORIGINAL_SHA"
echo "COMPANION_GOTO_SHA256=$COMPANION_SHA"
echo "POSITIVE_JSON_SHA256=$POSITIVE_JSON_SHA"
echo "COMPANION_JSON_SHA256=$COMPANION_JSON_SHA"
echo "U1_JSON_SHA256=$U1_SHA"
echo "U2_JSON_SHA256=$U2_SHA"
echo "U3_JSON_SHA256=$U3_SHA"
echo "EXPECTED_FAILURE_PARSER_SHA256=$PARSER_SHA"
echo "UNWINDSET=$UNWINDSET"

[ "$SOURCE_HEAD" = "$EXPECTED_COMMIT" ] || {
    echo "SOURCE_HEAD_BINDING=FAIL"
    exit 2
}

[ -z "$SOURCE_STATUS" ] || {
    echo "SOURCE_WORKTREE_CLEAN=FAIL"
    printf '%s\n' "$SOURCE_STATUS"
    exit 3
}

[ "$ORIGINAL_SHA" = "$EXPECTED_ORIGINAL_GOTO_SHA256" ] || {
    echo "ORIGINAL_GOTO_BINDING=FAIL"
    exit 4
}

[ "$COMPANION_SHA" = "$EXPECTED_COMPANION_GOTO_SHA256" ] || {
    echo "COMPANION_GOTO_BINDING=FAIL"
    exit 5
}

[ "$POSITIVE_JSON_SHA" = "$EXPECTED_POSITIVE_JSON_SHA256" ] || {
    echo "POSITIVE_JSON_BINDING=FAIL"
    exit 6
}

[ "$COMPANION_JSON_SHA" = "$EXPECTED_COMPANION_JSON_SHA256" ] || {
    echo "COMPANION_JSON_BINDING=FAIL"
    exit 7
}

[ "$COMPANION_RECORDED_EXIT" = "0" ] || {
    echo "COMPANION_EXIT_BINDING=FAIL"
    exit 8
}

[ "$U1_SHA" = "$EXPECTED_U1_JSON_SHA256" ] &&
[ "$U2_SHA" = "$EXPECTED_U2_JSON_SHA256" ] &&
[ "$U3_SHA" = "$EXPECTED_U3_JSON_SHA256" ] || {
    echo "PRIOR_CONTROL_JSON_BINDING=FAIL"
    exit 9
}

[ "$U1_RECORDED_EXIT" = "10" ] &&
[ "$U2_RECORDED_EXIT" = "10" ] &&
[ "$U3_RECORDED_EXIT" = "0" ] || {
    echo "PRIOR_CONTROL_EXIT_BINDING=FAIL"
    exit 10
}

[ "$PARSER_SHA" = "$EXPECTED_FAILURE_PARSER_SHA256" ] || {
    echo "EXPECTED_FAILURE_PARSER_BINDING=FAIL"
    exit 11
}

[ "$UNWINDSET" = "$EXPECTED_UNWINDSET" ] || {
    echo "UNWINDSET_BINDING=FAIL"
    exit 12
}

grep -Fxq \
    "MSG_T1_POSITIVE_RESULT=PASS" \
    "$POSITIVE_SUMMARY" || {
        echo "POSITIVE_RESULT_STATUS_BINDING=FAIL"
        exit 13
    }

grep -Fxq \
    "CONTROL_FAMILY_STATUS=FROZEN_READY_FOR_REACHABILITY_EXECUTION" \
    "$FAMILY/MSG01I_R1_REACHABILITY_PREFLIGHT_SUMMARY.txt" || {
        echo "CONTROL_FAMILY_STATUS_BINDING=FAIL"
        exit 14
    }

grep -Fxq \
    "EXPECTED_FAILURE_AUDIT=PASS" \
    "$U1_PARSED" || {
        echo "U1_RESULT_BINDING=FAIL"
        exit 15
    }

grep -Fxq \
    "EXPECTED_FAILURE_AUDIT=PASS" \
    "$U2_PARSED" || {
        echo "U2_RESULT_BINDING=FAIL"
        exit 16
    }

echo "SOURCE_HEAD_BINDING=PASS"
echo "SOURCE_WORKTREE_CLEAN=PASS"
echo "ORIGINAL_GOTO_BINDING=PASS"
echo "COMPANION_GOTO_BINDING=PASS"
echo "POSITIVE_RESULT_BINDING=PASS"
echo "COMPANION_RESULT_BINDING=PASS"
echo "PRIOR_CONTROL_JSON_BINDING=PASS"
echo "PRIOR_CONTROL_EXIT_BINDING=PASS"
echo "EXPECTED_FAILURE_PARSER_BINDING=PASS"
echo "UNWINDSET_BINDING=PASS"

echo
echo "============================================================"
echo "B. VERIFY FROZEN MANIFESTS AND LOCK"
echo "============================================================"

(
    cd "$POSITIVE" || exit 1

    sha256sum -c \
        "$(basename "$POSITIVE_MANIFEST_SHA")"

    sha256sum -c \
        "$(basename "$POSITIVE_MANIFEST")"
)

POSITIVE_MANIFEST_EXIT=$?

(
    cd "$CONTROL_OUT" || exit 1

    sha256sum -c \
        "$(basename "$CONTROL_MANIFEST_SHA")"

    sha256sum -c \
        "$(basename "$CONTROL_MANIFEST")"
)

CONTROL_MANIFEST_EXIT=$?

[ "$POSITIVE_MANIFEST_EXIT" -eq 0 ] || {
    echo "POSITIVE_MANIFEST_VERIFICATION=FAIL"
    exit 17
}

[ "$CONTROL_MANIFEST_EXIT" -eq 0 ] || {
    echo "CONTROL_MANIFEST_VERIFICATION=FAIL"
    exit 18
}

BAD_FILE_MODE_COUNT=0

while IFS= read -r -d '' FILE; do
    MODE=$(stat -c '%a' "$FILE")

    if [ "$MODE" != "444" ]; then
        BAD_FILE_MODE_COUNT=$((BAD_FILE_MODE_COUNT + 1))
        echo "BAD_CONTROL_FILE_MODE=$MODE $FILE"
    fi
done < <(find "$CONTROL_OUT" -type f -print0)

BAD_DIRECTORY_MODE_COUNT=0

while IFS= read -r -d '' DIRECTORY; do
    MODE=$(stat -c '%a' "$DIRECTORY")

    if [ "$MODE" != "555" ]; then
        BAD_DIRECTORY_MODE_COUNT=$((BAD_DIRECTORY_MODE_COUNT + 1))
        echo "BAD_CONTROL_DIRECTORY_MODE=$MODE $DIRECTORY"
    fi
done < <(find "$CONTROL_OUT" -type d -print0)

[ "$BAD_FILE_MODE_COUNT" -eq 0 ] &&
[ "$BAD_DIRECTORY_MODE_COUNT" -eq 0 ] || {
    echo "CONTROL_FAMILY_READ_ONLY_LOCK=FAIL"
    exit 19
}

echo "POSITIVE_MANIFEST_VERIFICATION=PASS"
echo "CONTROL_MANIFEST_VERIFICATION=PASS"
echo "CONTROL_FAMILY_READ_ONLY_LOCK=PASS"

echo
echo "============================================================"
echo "C. COPY FROZEN PROVENANCE"
echo "============================================================"

cp -- "$POSITIVE_SUMMARY" \
    "$FROZEN_INPUTS/MSG01H_POSITIVE_EXECUTION_SUMMARY.txt"

cp -- "$FAMILY/MSG01I_R1_REACHABILITY_PREFLIGHT_SUMMARY.txt" \
    "$FROZEN_INPUTS/MSG01I_R1_REACHABILITY_PREFLIGHT_SUMMARY.txt"

cp -- "$CONTROL_FREEZE" \
    "$FROZEN_INPUTS/MSG01I_R1_REACHABILITY_FAMILY_FREEZE_RECORD.md"

cp -- "$COVER_MAP" \
    "$FROZEN_INPUTS/MSG01I_R1_COVER_GOAL_MAP.md"

cp -- "$CONTROL_MANIFEST" \
    "$FROZEN_INPUTS/MSG01I_R1_ARTIFACT_MANIFEST.sha256"

cp -- "$CONTROL_MANIFEST_SHA" \
    "$FROZEN_INPUTS/MSG01I_R1_ARTIFACT_MANIFEST.sha256.sha256"

cp -- "$UNWINDSET_FILE" \
    "$FROZEN_INPUTS/frozen_unwindset.txt"

cp -- "$R2/MSG01J_R2_TERMINAL_CAPTURE.txt" \
    "$PROVENANCE/MSG01J_R2_terminal_capture.txt"

cp -- "$INPUT_FAILURE_PARSER" "$FAILURE_PARSER"
chmod 0755 "$FAILURE_PARSER"

echo "FROZEN_PROVENANCE_COPY=PASS"

echo
echo "============================================================"
echo "D. BIND TARGET LOOP IDS TO EXACT SOURCE STATEMENTS"
echo "============================================================"

goto-instrument \
    --show-loops \
    "$COMPANION_GOTO" \
    > "$LOOP_INVENTORY" 2>&1

SHOW_LOOPS_EXIT=$?

echo "SHOW_LOOPS_EXIT=$SHOW_LOOPS_EXIT"
cat "$LOOP_INVENTORY"

[ "$SHOW_LOOPS_EXIT" -eq 0 ] || {
    echo "FRESH_LOOP_INVENTORY=FAIL"
    exit 20
}

nl -ba "$COMPRESS_C" |
sed -n '716,732p' |
tee "$SOURCE_EXCERPT"

python3 - \
    "$LOOP_INVENTORY" \
    "$LOOP_MAP" <<'PY'
import re
import sys
from pathlib import Path

inventory_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])

text = inventory_path.read_text(
    encoding="utf-8",
    errors="replace",
)

records = {}

lines = text.splitlines()

for index, line in enumerate(lines):
    match = re.match(
        r"^Loop ([^:]+):$",
        line.strip(),
    )

    if not match:
        continue

    loop_id = match.group(1)
    source_line = None
    function = None

    for following in lines[index + 1:index + 6]:
        location = re.search(
            r"\bline\s+([0-9]+)\s+function\s+(\S+)",
            following,
        )

        if location:
            source_line = int(location.group(1))
            function = location.group(2)
            break

    if source_line is not None:
        records[loop_id] = (
            source_line,
            function,
        )

expected = {
    "mlk_msg01i_poly_tomsg.0": (
        720,
        "mlk_msg01i_poly_tomsg",
    ),
    "mlk_msg01i_poly_tomsg.1": (
        728,
        "mlk_msg01i_poly_tomsg",
    ),
    "mlk_msg01i_poly_tomsg.2": (
        722,
        "mlk_msg01i_poly_tomsg",
    ),
}

for loop_id, expected_value in expected.items():
    actual = records.get(loop_id)

    if actual != expected_value:
        raise SystemExit(
            f"LOOP_SOURCE_MAPPING_MISMATCH="
            f"{loop_id}:{actual}"
        )

output_path.write_text(
    "LOOP_ID\tSOURCE_LINE\tROLE\n"
    "mlk_msg01i_poly_tomsg.0\t720\t"
    "mlk_assert_bound macro-origin loop\n"
    "mlk_msg01i_poly_tomsg.1\t728\t"
    "inner j loop\n"
    "mlk_msg01i_poly_tomsg.2\t722\t"
    "outer i loop\n",
    encoding="utf-8",
)

print("TARGET_LOOP_SOURCE_MAPPING=PASS")
print(
    "TARGET_LOOP_0_SOURCE_LINE=720"
)
print(
    "TARGET_LOOP_1_SOURCE_LINE=728"
)
print(
    "TARGET_LOOP_2_SOURCE_LINE=722"
)
PY

LOOP_MAPPING_EXIT=$?

echo "LOOP_MAPPING_EXIT=$LOOP_MAPPING_EXIT"
cat "$LOOP_MAP"

[ "$LOOP_MAPPING_EXIT" -eq 0 ] || {
    echo "TARGET_LOOP_SOURCE_MAPPING=FAIL"
    exit 21
}

LINE720=$(sed -n '720p' "$COMPRESS_C")
LINE722=$(sed -n '722p' "$COMPRESS_C")
LINE728=$(sed -n '728p' "$COMPRESS_C")

echo "SOURCE_LINE_720=$LINE720"
echo "SOURCE_LINE_722=$LINE722"
echo "SOURCE_LINE_728=$LINE728"

printf '%s\n' "$LINE720" |
grep -Eq 'mlk_assert_bound' || {
    echo "TARGET_LOOP_0_SOURCE_CLASSIFICATION=FAIL"
    exit 22
}

printf '%s\n' "$LINE722" |
grep -Eq 'for[[:space:]]*\([[:space:]]*i' || {
    echo "TARGET_OUTER_LOOP_SOURCE_CLASSIFICATION=FAIL"
    exit 23
}

printf '%s\n' "$LINE728" |
grep -Eq 'for[[:space:]]*\([[:space:]]*j' || {
    echo "TARGET_INNER_LOOP_SOURCE_CLASSIFICATION=FAIL"
    exit 24
}

[ "$U3_SHA" = "$COMPANION_JSON_SHA" ] || {
    echo "TARGET_LOOP_0_BOUND1_RESULT_EQUIVALENCE=FAIL"
    exit 25
}

{
echo "TARGET_LOOP_0_ID=mlk_msg01i_poly_tomsg.0"
echo "TARGET_LOOP_0_SOURCE_LINE=720"
echo "TARGET_LOOP_0_SOURCE_STATEMENT=$LINE720"
echo "TARGET_LOOP_0_BOUND1_CBMC_EXIT=$U3_RECORDED_EXIT"
echo "TARGET_LOOP_0_BOUND1_JSON_SHA256=$U3_SHA"
echo "FULL_COMPANION_JSON_SHA256=$COMPANION_JSON_SHA"
echo "TARGET_LOOP_0_BOUND1_RESULT_EQUIVALENCE=PASS"
echo "TARGET_LOOP_0_CLASSIFICATION=MACRO_ORIGIN_BOUND1_SUFFICIENT"
echo
echo "TARGET_LOOP_1_ID=mlk_msg01i_poly_tomsg.1"
echo "TARGET_LOOP_1_SOURCE_LINE=728"
echo "TARGET_LOOP_1_CLASSIFICATION=INNER_ALGORITHMIC_LOOP"
echo
echo "TARGET_LOOP_2_ID=mlk_msg01i_poly_tomsg.2"
echo "TARGET_LOOP_2_SOURCE_LINE=722"
echo "TARGET_LOOP_2_CLASSIFICATION=OUTER_ALGORITHMIC_LOOP"
} | tee "$U3_CLASSIFICATION"

echo "TARGET_LOOP_CLASSIFICATION=PASS"

echo
echo "============================================================"
echo "E. AUDIT ACCEPTED 522/522 COMPANION RESULT"
echo "============================================================"

python3 - \
    "$COMPANION_JSON" \
    "$COMPANION_AUDIT" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])

data = json.loads(
    json_path.read_text(
        encoding="utf-8",
        errors="strict",
    )
)

records = {}
all_strings = []


def walk(value):
    if isinstance(value, dict):
        property_id = value.get("property")
        status = value.get("status")

        if isinstance(property_id, str) and isinstance(status, str):
            description = value.get("description", "")

            if not isinstance(description, str):
                description = str(description)

            records[property_id] = {
                "status": status.upper(),
                "description": description,
            }

        for key, item in value.items():
            all_strings.append(str(key))
            walk(item)

    elif isinstance(value, list):
        for item in value:
            walk(item)

    elif isinstance(value, str):
        all_strings.append(value)


walk(data)

success = sum(
    record["status"] == "SUCCESS"
    for record in records.values()
)

failure = sum(
    record["status"] == "FAILURE"
    for record in records.values()
)

unknown = len(records) - success - failure

anchor = [
    record
    for record in records.values()
    if (
        "MSG_T1_REACH_ANCHOR_EXACT:"
        in record["description"]
    )
]

verification_success = any(
    "VERIFICATION SUCCESSFUL" in item
    for item in all_strings
)

audit_pass = (
    len(records) == 522
    and success == 522
    and failure == 0
    and unknown == 0
    and len(anchor) == 1
    and anchor[0]["status"] == "SUCCESS"
    and verification_success
)

lines = [
    "JSON_PARSE=PASS",
    f"PROPERTY_RECORD_COUNT={len(records)}",
    f"SUCCESS_COUNT={success}",
    f"FAILURE_COUNT={failure}",
    f"UNKNOWN_COUNT={unknown}",
    f"ANCHOR_MATCH_COUNT={len(anchor)}",
    (
        "ANCHOR_STATUS=SUCCESS"
        if len(anchor) == 1
        and anchor[0]["status"] == "SUCCESS"
        else "ANCHOR_STATUS=NOT_SUCCESS"
    ),
    (
        "VERIFICATION_SUCCESS_MESSAGE_PRESENT="
        + ("YES" if verification_success else "NO")
    ),
    (
        "ACCEPTED_COMPANION_RESULT_AUDIT=PASS"
        if audit_pass
        else "ACCEPTED_COMPANION_RESULT_AUDIT=FAIL"
    ),
]

output_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print("\n".join(lines))

raise SystemExit(0 if audit_pass else 20)
PY

COMPANION_AUDIT_EXIT=$?

echo "COMPANION_AUDIT_EXIT=$COMPANION_AUDIT_EXIT"
cat "$COMPANION_AUDIT"

[ "$COMPANION_AUDIT_EXIT" -eq 0 ] || {
    echo "ACCEPTED_COMPANION_RESULT_GATE=FAIL"
    exit 26
}

echo "ACCEPTED_COMPANION_RESULT_GATE=PASS"

echo
echo "============================================================"
echo "F. REUSE U1/U2 AND CLASSIFY U3"
echo "============================================================"

cp -a "$U1_DIR" "$REUSED/U1_MAIN_ASSUMPTION_LOOP"
cp -a "$U2_DIR" "$REUSED/U2_MAIN_ASSERTION_LOOP"
cp -a "$U3_DIR" "$REUSED/U3_TARGET_LOOP_0_BOUND1_SUFFICIENT"

printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "CONTROL" \
    "LOOP" \
    "EXPECTED_RESULT" \
    "CBMC_EXIT" \
    "FAILURE_COUNT" \
    "AUDIT" \
    > "$CONTROL_MATRIX"

for ITEM in \
    "U1_MAIN_ASSUMPTION_LOOP|main.0|$U1_EXIT|$U1_PARSED" \
    "U2_MAIN_ASSERTION_LOOP|main.1|$U2_EXIT|$U2_PARSED"
do
    IFS='|' read -r LABEL LOOP EXIT_PATH PARSED_PATH <<< "$ITEM"

    EXIT_VALUE=$(tr -d '\r\n' < "$EXIT_PATH")

    FAILURE_COUNT=$(
        awk -F= \
            '$1=="FAILURE_COUNT" {print $2}' \
            "$PARSED_PATH"
    )

    AUDIT=$(
        awk -F= \
            '$1=="EXPECTED_FAILURE_AUDIT" {print $2}' \
            "$PARSED_PATH"
    )

    [ "$EXIT_VALUE" = "10" ] &&
    [ "$FAILURE_COUNT" -ge 1 ] &&
    [ "$AUDIT" = "PASS" ] || {
        echo "REUSED_CONTROL_GATE=FAIL $LABEL"
        exit 27
    }

    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$LABEL" \
        "$LOOP" \
        "UNWIND_FAILURE" \
        "$EXIT_VALUE" \
        "$FAILURE_COUNT" \
        "$AUDIT" \
        >> "$CONTROL_MATRIX"
done

printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "U3_TARGET_LOOP_0" \
    "mlk_msg01i_poly_tomsg.0" \
    "BOUND1_SUFFICIENT" \
    "$U3_RECORDED_EXIT" \
    "0" \
    "PASS" \
    >> "$CONTROL_MATRIX"

echo "REUSED_U1_CONTROL=PASS"
echo "REUSED_U2_CONTROL=PASS"
echo "U3_SINGLE_BOUND_CLASSIFICATION=PASS"

echo
echo "============================================================"
echo "G. EXECUTE TWO REMAINING TARGET-LOOP CONTROLS"
echo "============================================================"

NEW_LABELS=(
    "U4_TARGET_INNER_LOOP"
    "U5_TARGET_OUTER_LOOP"
)

NEW_LOOPS=(
    "mlk_msg01i_poly_tomsg.1"
    "mlk_msg01i_poly_tomsg.2"
)

NEW_CONTROL_PASS_COUNT=0

for INDEX in "${!NEW_LABELS[@]}"; do
    LABEL="${NEW_LABELS[$INDEX]}"
    REDUCED_LOOP="${NEW_LOOPS[$INDEX]}"

    RUN_DIR="$NEW_CONTROLS/$LABEL"
    mkdir -p "$RUN_DIR"

    REDUCED_UNWINDSET=$(
        python3 - "$UNWINDSET" "$REDUCED_LOOP" <<'PY'
import sys

full = sys.argv[1]
target = sys.argv[2]

entries = []

for entry in full.split(","):
    loop_id, bound = entry.rsplit(":", 1)

    if loop_id == target:
        bound = "1"

    entries.append(
        f"{loop_id}:{bound}"
    )

print(",".join(entries))
PY
    )

    COMMAND_FILE="$COMMANDS/${LABEL}_command.txt"
    JSON_FILE="$RUN_DIR/result.json"
    STDERR_FILE="$LOGS/${LABEL}_stderr.txt"
    RESOURCE_FILE="$RESOURCE/${LABEL}_resource_usage.txt"
    EXIT_FILE="$RUN_DIR/exit_code.txt"
    PARSED_FILE="$RUN_DIR/parsed_summary.txt"

    CMD=(
        cbmc
        "$COMPANION_GOTO"
        --function main
        --object-bits 8
        --bounds-check
        --pointer-check
        --pointer-overflow-check
        --pointer-primitive-check
        --signed-overflow-check
        --unsigned-overflow-check
        --conversion-check
        --undefined-shift-check
        --div-by-zero-check
        --unwinding-assertions
        --unwindset "$REDUCED_UNWINDSET"
        --slice-formula
        --sat-solver minisat2
        --all-properties
        --trace
        --json-ui
    )

    {
        printf '%q ' "${CMD[@]}"
        printf '\n'
    } > "$COMMAND_FILE"

    echo
    echo "--- $LABEL ---"
    echo "REDUCED_LOOP=$REDUCED_LOOP"
    echo "REDUCED_UNWINDSET=$REDUCED_UNWINDSET"
    echo "COMMAND=$(cat "$COMMAND_FILE")"

    set +e

    /usr/bin/time \
        -v \
        -o "$RESOURCE_FILE" \
        "${CMD[@]}" \
        >"$JSON_FILE" \
        2>"$STDERR_FILE"

    CONTROL_EXIT=$?

    set -e

    printf '%s\n' "$CONTROL_EXIT" > "$EXIT_FILE"

    echo "CBMC_EXIT=$CONTROL_EXIT"
    echo "RESULT_JSON_SIZE_BYTES=$(wc -c < "$JSON_FILE")"
    echo "RESULT_JSON_SHA256=$(sha256sum "$JSON_FILE" | awk '{print $1}')"

    cat "$STDERR_FILE"

    [ -s "$JSON_FILE" ] || {
        echo "CONTROL_JSON_NONEMPTY=FAIL"
        exit 28
    }

    python3 \
        "$FAILURE_PARSER" \
        "$JSON_FILE" \
        "$LABEL" \
        "$PARSED_FILE"

    PARSER_EXIT=$?

    echo "EXPECTED_FAILURE_PARSER_EXIT=$PARSER_EXIT"
    cat "$PARSED_FILE"

    FAILURE_COUNT=$(
        awk -F= \
            '$1=="FAILURE_COUNT" {print $2}' \
            "$PARSED_FILE"
    )

    UNWIND_FAILURE_COUNT=$(
        awk -F= \
            '$1=="UNWIND_FAILURE_COUNT" {print $2}' \
            "$PARSED_FILE"
    )

    NON_UNWIND_FAILURE_COUNT=$(
        awk -F= \
            '$1=="NON_UNWIND_FAILURE_COUNT" {print $2}' \
            "$PARSED_FILE"
    )

    AUDIT=$(
        awk -F= \
            '$1=="EXPECTED_FAILURE_AUDIT" {print $2}' \
            "$PARSED_FILE"
    )

    [ "$CONTROL_EXIT" -eq 10 ] || {
        echo "EXPECTED_FAILURE_EXIT_GATE=FAIL"
        exit 29
    }

    [ "$PARSER_EXIT" -eq 0 ] &&
    [ "$FAILURE_COUNT" -ge 1 ] &&
    [ "$UNWIND_FAILURE_COUNT" -ge 1 ] &&
    [ "$NON_UNWIND_FAILURE_COUNT" -eq 0 ] &&
    [ "$AUDIT" = "PASS" ] || {
        echo "EXPECTED_FAILURE_RESULT_GATE=FAIL"
        exit 30
    }

    NEW_CONTROL_PASS_COUNT=$((NEW_CONTROL_PASS_COUNT + 1))

    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$LABEL" \
        "$REDUCED_LOOP" \
        "UNWIND_FAILURE" \
        "$CONTROL_EXIT" \
        "$FAILURE_COUNT" \
        "$AUDIT" \
        >> "$CONTROL_MATRIX"

    echo "EXPECTED_FAILURE_CONTROL=PASS"
done

[ "$NEW_CONTROL_PASS_COUNT" -eq 2 ] || {
    echo "NEW_TARGET_CONTROL_FAMILY=FAIL"
    exit 31
}

{
echo "REUSED_MULTI_ITERATION_CONTROL_COUNT=2"
echo "NEW_MULTI_ITERATION_CONTROL_COUNT=2"
echo "TOTAL_MULTI_ITERATION_CONTROL_COUNT=4"
echo "PASSED_MULTI_ITERATION_CONTROL_COUNT=4"
echo "TARGET_LOOP_0_BOUND1_SUFFICIENT_CONTROL=PASS"
echo "ALL_ALGORITHMIC_LOOP_SENSITIVITY_CONTROLS=PASS"
} | tee "$CONTROL_SUMMARY"

echo
echo "--- Final unwind-control matrix ---"
column -t -s $'\t' "$CONTROL_MATRIX" 2>/dev/null ||
cat "$CONTROL_MATRIX"

echo
echo "============================================================"
echo "H. EXECUTE UNTOUCHED ORIGINAL-MODEL COVERAGE"
echo "============================================================"

goto-instrument \
    --validate-goto-binary \
    "$ORIGINAL_GOTO" \
    >"$LOGS/pre_coverage_goto_validation.txt" 2>&1

PRE_COVERAGE_VALIDATE_EXIT=$?

echo "PRE_COVERAGE_GOTO_VALIDATE_EXIT=$PRE_COVERAGE_VALIDATE_EXIT"
cat "$LOGS/pre_coverage_goto_validation.txt"

[ "$PRE_COVERAGE_VALIDATE_EXIT" -eq 0 ] || {
    echo "PRE_COVERAGE_GOTO_VALIDATION=FAIL"
    exit 32
}

echo "PRE_COVERAGE_GOTO_VALIDATION=PASS"

COVERAGE_CMD=(
    cbmc
    "$ORIGINAL_GOTO"
    --function main
    --object-bits 8
    --bounds-check
    --pointer-check
    --pointer-overflow-check
    --pointer-primitive-check
    --signed-overflow-check
    --unsigned-overflow-check
    --conversion-check
    --undefined-shift-check
    --div-by-zero-check
    --no-unwinding-assertions
    --unwindset "$UNWINDSET"
    --slice-formula
    --sat-solver minisat2
    --cover cover
)

{
    printf '%q ' "${COVERAGE_CMD[@]}"
    printf '\n'
} > "$COVERAGE_COMMAND"

echo "--- Exact untouched original-model coverage command ---"
cat "$COVERAGE_COMMAND"

echo "ORIGINAL_MODEL_COVERAGE_STATUS=RUNNING"

set +e

/usr/bin/time \
    -v \
    -o "$COVERAGE_RESOURCE" \
    "${COVERAGE_CMD[@]}" \
    >"$COVERAGE_STDOUT" \
    2>"$COVERAGE_STDERR"

COVERAGE_EXIT=$?

set -e

printf '%s\n' "$COVERAGE_EXIT" > "$COVERAGE_EXIT_FILE"

echo "ORIGINAL_MODEL_COVERAGE_EXIT=$COVERAGE_EXIT"
echo "COVERAGE_OUTPUT_SIZE_BYTES=$(wc -c < "$COVERAGE_STDOUT")"
echo "COVERAGE_OUTPUT_SHA256=$(sha256sum "$COVERAGE_STDOUT" | awk '{print $1}')"

echo
echo "--- Coverage stderr ---"
cat "$COVERAGE_STDERR"

echo
echo "--- Coverage resource usage ---"
cat "$COVERAGE_RESOURCE"

echo
echo "--- Complete coverage output ---"
cat "$COVERAGE_STDOUT"

[ "$COVERAGE_EXIT" -eq 0 ] || {
    echo "ORIGINAL_MODEL_COVERAGE_EXIT_GATE=FAIL"
    exit 33
}

[ -s "$COVERAGE_STDOUT" ] || {
    echo "ORIGINAL_MODEL_COVERAGE_OUTPUT_NONEMPTY=FAIL"
    exit 34
}

COVERAGE_VALUES=$(
    awk '
        /^\*\* [0-9]+ of [0-9]+ covered/ {
            covered=$2
            total=$4
        }

        END {
            if(covered != "" && total != "")
                print covered, total
        }
    ' "$COVERAGE_STDOUT"
)

[ -n "$COVERAGE_VALUES" ] || {
    echo "COVERAGE_SUMMARY_PARSE=FAIL"
    exit 35
}

read -r COVERED TOTAL <<< "$COVERAGE_VALUES"

SATISFIED_LINES=$(
    grep -Ec \
        ':[[:space:]]+SATISFIED$' \
        "$COVERAGE_STDOUT" ||
    true
)

FAILED_LINES=$(
    grep -Ec \
        ':[[:space:]]+FAILED$' \
        "$COVERAGE_STDOUT" ||
    true
)

{
echo "EXPECTED_COVER_GOALS=12"
echo "SUMMARY_COVERED=$COVERED"
echo "SUMMARY_TOTAL=$TOTAL"
echo "SATISFIED_LINE_COUNT=$SATISFIED_LINES"
echo "FAILED_LINE_COUNT=$FAILED_LINES"
echo "COVERAGE_EXIT=$COVERAGE_EXIT"
} | tee "$COVERAGE_PARSED"

[ "$TOTAL" -eq 12 ] || {
    echo "COVERAGE_TOTAL_GATE=FAIL"
    exit 36
}

[ "$COVERED" -eq 12 ] || {
    echo "COVERAGE_SATISFIED_SUMMARY_GATE=FAIL"
    exit 37
}

[ "$SATISFIED_LINES" -eq 12 ] || {
    echo "COVERAGE_SATISFIED_LINE_GATE=FAIL"
    exit 38
}

[ "$FAILED_LINES" -eq 0 ] || {
    echo "COVERAGE_FAILED_LINE_GATE=FAIL"
    exit 39
}

echo "ORIGINAL_MODEL_COVERAGE_EXIT_GATE=PASS"
echo "COVERAGE_TOTAL_GATE=PASS"
echo "COVERAGE_SATISFIED_SUMMARY_GATE=PASS"
echo "COVERAGE_SATISFIED_LINE_GATE=PASS"
echo "COVERAGE_FAILED_LINE_GATE=PASS"
echo "ORIGINAL_MODEL_ALL_12_COVERS_SATISFIED=PASS"

echo
echo "============================================================"
echo "I. POST-EXECUTION INPUT INTEGRITY"
echo "============================================================"

SOURCE_HEAD_AFTER=$(git -C "$SOURCE" rev-parse HEAD)
SOURCE_STATUS_AFTER=$(git -C "$SOURCE" status --porcelain=v1)

ORIGINAL_SHA_AFTER=$(sha256sum "$ORIGINAL_GOTO" | awk '{print $1}')
COMPANION_SHA_AFTER=$(sha256sum "$COMPANION_GOTO" | awk '{print $1}')
POSITIVE_JSON_SHA_AFTER=$(sha256sum "$POSITIVE_JSON" | awk '{print $1}')
COMPANION_JSON_SHA_AFTER=$(sha256sum "$COMPANION_JSON" | awk '{print $1}')
UNWINDSET_AFTER=$(tr -d '\r\n' < "$UNWINDSET_FILE")

(
    cd "$CONTROL_OUT" || exit 1

    sha256sum -c \
        "$(basename "$CONTROL_MANIFEST_SHA")"

    sha256sum -c \
        "$(basename "$CONTROL_MANIFEST")"
)

POST_CONTROL_MANIFEST_EXIT=$?

(
    cd "$POSITIVE" || exit 1

    sha256sum -c \
        "$(basename "$POSITIVE_MANIFEST_SHA")"

    sha256sum -c \
        "$(basename "$POSITIVE_MANIFEST")"
)

POST_POSITIVE_MANIFEST_EXIT=$?

[ "$SOURCE_HEAD_AFTER" = "$EXPECTED_COMMIT" ] &&
[ -z "$SOURCE_STATUS_AFTER" ] &&
[ "$ORIGINAL_SHA_AFTER" = "$EXPECTED_ORIGINAL_GOTO_SHA256" ] &&
[ "$COMPANION_SHA_AFTER" = "$EXPECTED_COMPANION_GOTO_SHA256" ] &&
[ "$POSITIVE_JSON_SHA_AFTER" = "$EXPECTED_POSITIVE_JSON_SHA256" ] &&
[ "$COMPANION_JSON_SHA_AFTER" = "$EXPECTED_COMPANION_JSON_SHA256" ] &&
[ "$UNWINDSET_AFTER" = "$EXPECTED_UNWINDSET" ] &&
[ "$POST_CONTROL_MANIFEST_EXIT" -eq 0 ] &&
[ "$POST_POSITIVE_MANIFEST_EXIT" -eq 0 ] || {
    echo "POST_EXECUTION_INPUT_INTEGRITY=FAIL"
    printf '%s\n' "$SOURCE_STATUS_AFTER"
    exit 40
}

echo "POST_EXECUTION_INPUT_INTEGRITY=PASS"

echo
echo "============================================================"
echo "J. WRITE FINAL NON-VACUITY RESULT"
echo "============================================================"

cat > "$CORRECTION_RECORD" <<EOF
# MSG-01J-R3 — Target-Loop Classification Correction

The failed MSG-01J-R2 stage assumed that reducing every loop bound to one must
produce an unwinding failure.

The exact frozen GOTO/source mapping is:

\`\`\`text
mlk_msg01i_poly_tomsg.0 -> compress.c:720 -> mlk_assert_bound macro site
mlk_msg01i_poly_tomsg.1 -> compress.c:728 -> inner j loop
mlk_msg01i_poly_tomsg.2 -> compress.c:722 -> outer i loop
\`\`\`

Reducing loop .0 from 257 to 1 returned CBMC exit 0 and produced the exact same
JSON SHA-256 as the accepted full-bound companion execution:

\`\`\`text
$EXPECTED_COMPANION_JSON_SHA256
\`\`\`

It is therefore classified as a macro-origin loop for which bound one is
sufficient in this frozen model. It is not treated as a failed expected-failure
control.

The four multi-iteration loops are checked using U1, U2, U4 and U5.
EOF

cat > "$RESULT_RECORD" <<EOF
# MSG-01J-R3 — Authoritative Reachability and Non-Vacuity Result

## Accepted full-bound companion

\`\`\`text
CBMC_EXIT=0
PROPERTY_RECORD_COUNT=522
SUCCESS_COUNT=522
FAILURE_COUNT=0
UNKNOWN_COUNT=0
ANCHOR_STATUS=SUCCESS
\`\`\`

## Loop-bound sensitivity

\`\`\`text
MULTI_ITERATION_CONTROL_COUNT=4
PASSED_MULTI_ITERATION_CONTROL_COUNT=4
TARGET_LOOP_0_BOUND1_SUFFICIENT=PASS
\`\`\`

Insufficient bounds were detected for:

- both harness loops;
- the production inner loop;
- the production outer loop.

The macro-origin target loop at source line 720 was shown to be complete with
bound one.

## Untouched original-model coverage

\`\`\`text
COVERAGE_EXIT=$COVERAGE_EXIT
COVERED=$COVERED
TOTAL=$TOTAL
SATISFIED_LINES=$SATISFIED_LINES
FAILED_LINES=$FAILED_LINES
\`\`\`

All twelve boundary, region and output-position goals were satisfied after the
actual production \`mlk_poly_tomsg\` execution.

## Supported conclusion

The authoritative positive MSG-T1 result is non-vacuous for the registered
canonical input classes and selected output positions. The full-bound
companion succeeded, insufficient bounds were detected for every
multi-iteration reachable loop, and all twelve original-model coverage goals
were satisfiable.

Mutation-sensitivity controls remain the final MSG-T1 campaign gate.
EOF

{
echo "MSG-01J-R3 FINAL REACHABILITY/NON-VACUITY SUMMARY"
echo
echo "SOURCE_HEAD_BINDING=PASS"
echo "POSITIVE_MANIFEST_VERIFICATION=PASS"
echo "CONTROL_MANIFEST_VERIFICATION=PASS"
echo "CONTROL_FAMILY_READ_ONLY_LOCK=PASS"
echo
echo "ACCEPTED_COMPANION_JSON_SHA256=$EXPECTED_COMPANION_JSON_SHA256"
echo "COMPANION_CBMC_EXIT=0"
echo "COMPANION_PROPERTY_RECORD_COUNT=522"
echo "COMPANION_SUCCESS_COUNT=522"
echo "COMPANION_FAILURE_COUNT=0"
echo "COMPANION_UNKNOWN_COUNT=0"
echo "COMPANION_ANCHOR_STATUS=SUCCESS"
echo "ACCEPTED_COMPANION_RESULT_AUDIT=PASS"
echo
echo "TARGET_LOOP_SOURCE_MAPPING=PASS"
echo "TARGET_LOOP_0_CLASSIFICATION=MACRO_ORIGIN_BOUND1_SUFFICIENT"
echo "TARGET_LOOP_0_BOUND1_RESULT_EQUIVALENCE=PASS"
echo
echo "REUSED_MULTI_ITERATION_CONTROL_COUNT=2"
echo "NEW_MULTI_ITERATION_CONTROL_COUNT=2"
echo "TOTAL_MULTI_ITERATION_CONTROL_COUNT=4"
echo "PASSED_MULTI_ITERATION_CONTROL_COUNT=4"
echo "ALL_ALGORITHMIC_LOOP_SENSITIVITY_CONTROLS=PASS"
echo
echo "ORIGINAL_MODEL_COVERAGE_EXIT=$COVERAGE_EXIT"
echo "EXPECTED_COVER_GOALS=12"
echo "COVERAGE_SATISFIED=$COVERED"
echo "COVERAGE_TOTAL=$TOTAL"
echo "COVERAGE_SATISFIED_LINE_COUNT=$SATISFIED_LINES"
echo "COVERAGE_FAILED_LINE_COUNT=$FAILED_LINES"
echo "ORIGINAL_MODEL_ALL_12_COVERS_SATISFIED=PASS"
echo
echo "POST_EXECUTION_INPUT_INTEGRITY=PASS"
echo "REACHABILITY_AND_NONVACUITY_RESULT=PASS"
echo
echo "COMPANION_PROOF_EXECUTION=REUSED_ACCEPTED_RUN"
echo "NEW_INSUFFICIENT_UNWIND_CONTROL_EXECUTION=YES"
echo "ORIGINAL_MODEL_COVERAGE_EXECUTION=YES"
echo "MUTATION_EXECUTION=NO"
echo "CAMPAIGN_STATUS=POSITIVE_AND_NONVACUITY_PASS_PENDING_MUTATIONS"
} | tee "$SUMMARY"

nl -ba "$CORRECTION_RECORD"
nl -ba "$RESULT_RECORD"

echo
echo "MSG01J_R3_COMPLETE"

} 2>&1 | tee "$MASTER"

CAPTURE_STATUS=${PIPESTATUS[0]}

(
    cd "$OUT" || exit 1

    find . \
        -type f \
        ! -name 'MSG01J_R3_ARTIFACT_MANIFEST.sha256' \
        ! -name 'MSG01J_R3_ARTIFACT_MANIFEST.sha256.sha256' \
        -print0 |
    sort -z |
    xargs -0 sha256sum \
        > "$(basename "$MANIFEST")"

    sha256sum -c "$(basename "$MANIFEST")"

    sha256sum "$(basename "$MANIFEST")" \
        > "$(basename "$MANIFEST_SHA")"
)

MANIFEST_EXIT=$?

if [ "$MANIFEST_EXIT" -ne 0 ]; then
    echo "REACHABILITY_MANIFEST_VERIFICATION=FAIL"

    if [ "$CAPTURE_STATUS" -eq 0 ]; then
        CAPTURE_STATUS=41
    fi
else
    echo "REACHABILITY_MANIFEST_VERIFICATION=PASS"
fi

if [ "$CAPTURE_STATUS" -eq 0 ]; then
    find "$OUT" -type f -exec chmod 0444 {} +
    find "$OUT" -type d -exec chmod 0555 {} +

    echo "REACHABILITY_FILE_MODE=0444"
    echo "REACHABILITY_DIRECTORY_MODE=0555"
    echo "REACHABILITY_EVIDENCE_LOCK=PASS"
fi

echo
echo "============================================================"
echo "MSG-01J-R3 OUTPUTS"
echo "============================================================"
echo "OUT=$OUT"
echo "LOOP_MAP=$LOOP_MAP"
echo "U3_CLASSIFICATION=$U3_CLASSIFICATION"
echo "COMPANION_AUDIT=$COMPANION_AUDIT"
echo "CONTROL_MATRIX=$CONTROL_MATRIX"
echo "CONTROL_SUMMARY=$CONTROL_SUMMARY"
echo "COVERAGE_STDOUT=$COVERAGE_STDOUT"
echo "COVERAGE_PARSED=$COVERAGE_PARSED"
echo "CORRECTION_RECORD=$CORRECTION_RECORD"
echo "RESULT_RECORD=$RESULT_RECORD"
echo "SUMMARY=$SUMMARY"
echo "MANIFEST=$MANIFEST"
echo "MASTER=$MASTER"
echo "CAPTURE_STATUS=$CAPTURE_STATUS"

exit "$CAPTURE_STATUS"
