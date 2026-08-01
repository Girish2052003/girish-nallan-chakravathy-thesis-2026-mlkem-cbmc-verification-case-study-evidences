#!/usr/bin/env bash

set -u

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

EXPECTED_COMPRESS_C_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESS_H_SHA256="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"

EXPECTED_BASE_HARNESS_SHA256="5ce480427d7792b3dca091ac198b43562c4d4dfd6c9d96dae5a73e7ef1e72b55"
EXPECTED_BASE_GOTO_SHA256="51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d"
EXPECTED_POSITIVE_JSON_SHA256="3b32112c5537a95d470b0b866c1edf6cb1f8c3be408188c9fc2cdbf91fab40ee"

EXPECTED_ZEROIZE_SHA256="b71285ddfe229382a0402461f023defcf80a4941aaf35c3db732086ff312779a"
EXPECTED_VERIFY_SCOPE_SHA256="0aacacb9a12ef28be9044ee3593930e69e67fcf1b107ed81ccbde9f047edb489"
EXPECTED_DIRECT_WRAP_SHA256="7820ea424366906c1a10271579500c2eee94372c03e589560f82a046d545c42b"
EXPECTED_OPTBLOCKER_SHA256="3338ed52257c20fe3edb62bf0a4ceb16680c20332b04d19e1a2fdbf6dc3aefb2"

EXPECTED_MUTANT_COUNT=8
EXPECTED_IMPLEMENTATION_MUTANT_COUNT=4
EXPECTED_ORACLE_ASSERTION_MUTANT_COUNT=4

SOURCE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
COMPRESS_C="$SOURCE/mlkem/src/compress.c"
COMPRESS_H="$SOURCE/mlkem/src/compress.h"

CAMPAIGN="$HOME/THESIS-2026/mlk_poly_tomsg_cleanroom"

BASE_OUT="$CAMPAIGN/MSG01G_R1_T1_FROZEN_EXECUTION_INPUT_V1_af4c5abdd595"
BASE="$BASE_OUT/frozen_candidate_v1"

BASE_HARNESS="$BASE/harness/msg_t1_exact_fips_candidate_v4.c"
BASE_GOTO="$BASE/build/msg_t1_exact_fips_v4_direct_pragma.goto"

BASE_ZEROIZE="$BASE/support/msg01f_fail_closed_zeroize.h"
BASE_VERIFY_SCOPE="$BASE/support/msg01f_verify_pragma_scope.h"
BASE_DIRECT_WRAP="$BASE/support/msg01f_compress_direct_wrap_scope.h"
BASE_OPTBLOCKER="$BASE/support/msg01f_optblocker_zero.c"

BASE_MANIFEST="$BASE/MSG01G_R1_ARTIFACT_MANIFEST.sha256"
BASE_MANIFEST_SHA="$BASE_MANIFEST.sha256"

POSITIVE="$CAMPAIGN/MSG01H_T1_AUTHORITATIVE_POSITIVE_RUN1_af4c5abdd595"
POSITIVE_JSON="$POSITIVE/results/msg_t1_positive_cbmc_result.json"
POSITIVE_SUMMARY="$POSITIVE/MSG01H_POSITIVE_EXECUTION_SUMMARY.txt"
POSITIVE_MANIFEST="$POSITIVE/MSG01H_ARTIFACT_MANIFEST.sha256"
POSITIVE_MANIFEST_SHA="$POSITIVE_MANIFEST.sha256"

NONVAC="$CAMPAIGN/MSG01J_R3_T1_REACHABILITY_NONVACUITY_FINAL_af4c5abdd595"
NONVAC_SUMMARY="$NONVAC/MSG01J_R3_REACHABILITY_SUMMARY.txt"
NONVAC_RESULT="$NONVAC/MSG01J_R3_REACHABILITY_RESULT.md"
NONVAC_MANIFEST="$NONVAC/MSG01J_R3_ARTIFACT_MANIFEST.sha256"
NONVAC_MANIFEST_SHA="$NONVAC_MANIFEST.sha256"

FREEZE_OUT="$CAMPAIGN/MSG01K_T1_MUTATION_FAMILY_FREEZE_V1_af4c5abdd595"
FAMILY="$FREEZE_OUT/frozen_mutation_family_v1"

EXEC_OUT="$CAMPAIGN/MSG01L_T1_MUTATION_EXECUTION_RUN1_af4c5abdd595"

FAMILY_SUPPORT="$FAMILY/support"
MUTANTS="$FAMILY/mutants"
FAMILY_PROVENANCE="$FAMILY/provenance"
FAMILY_INSPECTION="$FAMILY/inspection"

MUTATION_GENERATOR="$FAMILY_SUPPORT/generate_mutation_family.py"
MODEL_DERIVER="$FAMILY_SUPPORT/derive_mutant_model.py"

MUTATION_PLAN="$FAMILY/MUTATION_PLAN.tsv"
WITNESS_REPORT="$FAMILY/SEMANTIC_WITNESS_REPORT.txt"
FREEZE_MATRIX="$FAMILY/MUTATION_FREEZE_MATRIX.tsv"
FREEZE_SUMMARY="$FAMILY/MSG01K_MUTATION_FAMILY_FREEZE_SUMMARY.txt"
FREEZE_RECORD="$FAMILY/MSG01K_MUTATION_FAMILY_FREEZE_RECORD.md"

FREEZE_MANIFEST="$FREEZE_OUT/MSG01K_ARTIFACT_MANIFEST.sha256"
FREEZE_MANIFEST_SHA="$FREEZE_MANIFEST.sha256"

EXEC_COMMANDS="$EXEC_OUT/commands"
EXEC_RESULTS="$EXEC_OUT/results"
EXEC_LOGS="$EXEC_OUT/logs"
EXEC_RESOURCE="$EXEC_OUT/resource_usage"
EXEC_SUPPORT="$EXEC_OUT/support"
EXEC_PROVENANCE="$EXEC_OUT/provenance"

RESULT_PARSER="$EXEC_SUPPORT/parse_mutation_result.py"
EXEC_MATRIX="$EXEC_RESULTS/MUTATION_EXECUTION_MATRIX.tsv"
EXEC_SUMMARY="$EXEC_OUT/MSG01L_MUTATION_EXECUTION_SUMMARY.txt"
EXEC_RESULT_RECORD="$EXEC_OUT/MSG01L_MUTATION_EXECUTION_RESULT.md"

MASTER="$EXEC_OUT/MSG01K_L_COMBINED_TERMINAL_CAPTURE.txt"
EXEC_MANIFEST="$EXEC_OUT/MSG01L_ARTIFACT_MANIFEST.sha256"
EXEC_MANIFEST_SHA="$EXEC_MANIFEST.sha256"

if [ -e "$FREEZE_OUT" ]; then
    echo "FREEZE_OUTPUT_ALREADY_EXISTS=$FREEZE_OUT"
    echo "CAPTURE_STATUS=1"
    exit 1
fi

if [ -e "$EXEC_OUT" ]; then
    echo "EXECUTION_OUTPUT_ALREADY_EXISTS=$EXEC_OUT"
    echo "CAPTURE_STATUS=1"
    exit 1
fi

mkdir -p \
    "$FAMILY_SUPPORT" \
    "$MUTANTS" \
    "$FAMILY_PROVENANCE" \
    "$FAMILY_INSPECTION" \
    "$EXEC_COMMANDS" \
    "$EXEC_RESULTS" \
    "$EXEC_LOGS" \
    "$EXEC_RESOURCE" \
    "$EXEC_SUPPORT" \
    "$EXEC_PROVENANCE"

{
echo "============================================================"
echo "MSG-01K/L — FREEZE AND EXECUTE MSG-T1 MUTATION FAMILY"
echo "============================================================"
echo
echo "CAPTURE_UTC=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
echo "SOURCE=$SOURCE"
echo "BASE=$BASE"
echo "NONVAC=$NONVAC"
echo "FREEZE_OUT=$FREEZE_OUT"
echo "EXEC_OUT=$EXEC_OUT"
echo

echo "============================================================"
echo "A. AUTHORITATIVE EVIDENCE AND SOURCE BINDING"
echo "============================================================"

SOURCE_HEAD=$(git -C "$SOURCE" rev-parse HEAD)
SOURCE_STATUS=$(git -C "$SOURCE" status --porcelain=v1)

COMPRESS_C_SHA=$(sha256sum "$COMPRESS_C" | awk '{print $1}')
COMPRESS_H_SHA=$(sha256sum "$COMPRESS_H" | awk '{print $1}')

BASE_HARNESS_SHA=$(sha256sum "$BASE_HARNESS" | awk '{print $1}')
BASE_GOTO_SHA=$(sha256sum "$BASE_GOTO" | awk '{print $1}')
POSITIVE_JSON_SHA=$(sha256sum "$POSITIVE_JSON" | awk '{print $1}')

ZEROIZE_SHA=$(sha256sum "$BASE_ZEROIZE" | awk '{print $1}')
VERIFY_SCOPE_SHA=$(sha256sum "$BASE_VERIFY_SCOPE" | awk '{print $1}')
DIRECT_WRAP_SHA=$(sha256sum "$BASE_DIRECT_WRAP" | awk '{print $1}')
OPTBLOCKER_SHA=$(sha256sum "$BASE_OPTBLOCKER" | awk '{print $1}')

echo "SOURCE_HEAD=$SOURCE_HEAD"
echo "COMPRESS_C_SHA256=$COMPRESS_C_SHA"
echo "COMPRESS_H_SHA256=$COMPRESS_H_SHA"
echo "BASE_HARNESS_SHA256=$BASE_HARNESS_SHA"
echo "BASE_GOTO_SHA256=$BASE_GOTO_SHA"
echo "POSITIVE_JSON_SHA256=$POSITIVE_JSON_SHA"
echo "ZEROIZE_SHA256=$ZEROIZE_SHA"
echo "VERIFY_SCOPE_SHA256=$VERIFY_SCOPE_SHA"
echo "DIRECT_WRAP_SHA256=$DIRECT_WRAP_SHA"
echo "OPTBLOCKER_SHA256=$OPTBLOCKER_SHA"

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

[ "$BASE_HARNESS_SHA" = "$EXPECTED_BASE_HARNESS_SHA256" ] || {
    echo "BASE_HARNESS_BINDING=FAIL"
    exit 6
}

[ "$BASE_GOTO_SHA" = "$EXPECTED_BASE_GOTO_SHA256" ] || {
    echo "BASE_GOTO_BINDING=FAIL"
    exit 7
}

[ "$POSITIVE_JSON_SHA" = "$EXPECTED_POSITIVE_JSON_SHA256" ] || {
    echo "POSITIVE_JSON_BINDING=FAIL"
    exit 8
}

[ "$ZEROIZE_SHA" = "$EXPECTED_ZEROIZE_SHA256" ] &&
[ "$VERIFY_SCOPE_SHA" = "$EXPECTED_VERIFY_SCOPE_SHA256" ] &&
[ "$DIRECT_WRAP_SHA" = "$EXPECTED_DIRECT_WRAP_SHA256" ] &&
[ "$OPTBLOCKER_SHA" = "$EXPECTED_OPTBLOCKER_SHA256" ] || {
    echo "SUPPORT_BINDING=FAIL"
    exit 9
}

grep -Fxq \
    "MSG_T1_POSITIVE_RESULT=PASS" \
    "$POSITIVE_SUMMARY" || {
        echo "POSITIVE_RESULT_STATUS_BINDING=FAIL"
        exit 10
    }

grep -Fxq \
    "REACHABILITY_AND_NONVACUITY_RESULT=PASS" \
    "$NONVAC_SUMMARY" || {
        echo "NONVACUITY_STATUS_BINDING=FAIL"
        exit 11
    }

grep -Fxq \
    "CAMPAIGN_STATUS=POSITIVE_AND_NONVACUITY_PASS_PENDING_MUTATIONS" \
    "$NONVAC_SUMMARY" || {
        echo "PRE_MUTATION_CAMPAIGN_STATUS_BINDING=FAIL"
        exit 12
    }

echo "SOURCE_HEAD_BINDING=PASS"
echo "SOURCE_WORKTREE_CLEAN=PASS"
echo "PRODUCTION_SOURCE_BINDING=PASS"
echo "BASE_HARNESS_BINDING=PASS"
echo "BASE_GOTO_BINDING=PASS"
echo "POSITIVE_RESULT_BINDING=PASS"
echo "NONVACUITY_RESULT_BINDING=PASS"
echo "SUPPORT_BINDING=PASS"

echo
echo "============================================================"
echo "B. VERIFY ALL PRE-MUTATION MANIFESTS"
echo "============================================================"

(
    cd "$BASE" || exit 1
    sha256sum -c "$(basename "$BASE_MANIFEST_SHA")"
    sha256sum -c "$(basename "$BASE_MANIFEST")"
)
BASE_MANIFEST_EXIT=$?

(
    cd "$POSITIVE" || exit 1
    sha256sum -c "$(basename "$POSITIVE_MANIFEST_SHA")"
    sha256sum -c "$(basename "$POSITIVE_MANIFEST")"
)
POSITIVE_MANIFEST_EXIT=$?

(
    cd "$NONVAC" || exit 1
    sha256sum -c "$(basename "$NONVAC_MANIFEST_SHA")"
    sha256sum -c "$(basename "$NONVAC_MANIFEST")"
)
NONVAC_MANIFEST_EXIT=$?

[ "$BASE_MANIFEST_EXIT" -eq 0 ] || {
    echo "BASE_MANIFEST_VERIFICATION=FAIL"
    exit 13
}

[ "$POSITIVE_MANIFEST_EXIT" -eq 0 ] || {
    echo "POSITIVE_MANIFEST_VERIFICATION=FAIL"
    exit 14
}

[ "$NONVAC_MANIFEST_EXIT" -eq 0 ] || {
    echo "NONVACUITY_MANIFEST_VERIFICATION=FAIL"
    exit 15
}

echo "BASE_MANIFEST_VERIFICATION=PASS"
echo "POSITIVE_MANIFEST_VERIFICATION=PASS"
echo "NONVACUITY_MANIFEST_VERIFICATION=PASS"

echo
echo "============================================================"
echo "C. COPY SHARED SUPPORT AND PROVENANCE"
echo "============================================================"

cp -- "$BASE_ZEROIZE" \
    "$FAMILY_SUPPORT/msg01f_fail_closed_zeroize.h"

cp -- "$BASE_VERIFY_SCOPE" \
    "$FAMILY_SUPPORT/msg01f_verify_pragma_scope.h"

cp -- "$BASE_DIRECT_WRAP" \
    "$FAMILY_SUPPORT/msg01f_compress_direct_wrap_scope.h"

cp -- "$BASE_OPTBLOCKER" \
    "$FAMILY_SUPPORT/msg01f_optblocker_zero.c"

cp -- "$POSITIVE_SUMMARY" \
    "$FAMILY_PROVENANCE/MSG01H_POSITIVE_EXECUTION_SUMMARY.txt"

cp -- "$NONVAC_SUMMARY" \
    "$FAMILY_PROVENANCE/MSG01J_R3_REACHABILITY_SUMMARY.txt"

cp -- "$NONVAC_RESULT" \
    "$FAMILY_PROVENANCE/MSG01J_R3_REACHABILITY_RESULT.md"

cp -- "$BASE_MANIFEST" \
    "$FAMILY_PROVENANCE/MSG01G_R1_ARTIFACT_MANIFEST.sha256"

cp -- "$POSITIVE_MANIFEST" \
    "$FAMILY_PROVENANCE/MSG01H_ARTIFACT_MANIFEST.sha256"

cp -- "$NONVAC_MANIFEST" \
    "$FAMILY_PROVENANCE/MSG01J_R3_ARTIFACT_MANIFEST.sha256"

echo "SHARED_SUPPORT_AND_PROVENANCE_COPY=PASS"

echo
echo "============================================================"
echo "D. WRITE FAIL-CLOSED MUTATION GENERATOR"
echo "============================================================"

cat > "$MUTATION_GENERATOR" <<'PY'
#!/usr/bin/env python3

import difflib
import filecmp
import re
import shutil
import sys
from pathlib import Path

if len(sys.argv) != 8:
    raise SystemExit(
        "usage: generator BASE_HARNESS COMPRESS_C COMPRESS_H "
        "MUTANTS PLAN WITNESS INSPECTION"
    )

base_harness = Path(sys.argv[1])
base_c = Path(sys.argv[2])
base_h = Path(sys.argv[3])
mutants_root = Path(sys.argv[4])
plan_path = Path(sys.argv[5])
witness_path = Path(sys.argv[6])
inspection_root = Path(sys.argv[7])

specs = [
    {
        "id": "I1_INIT_ONE",
        "category": "IMPLEMENTATION",
        "changed": "compress.c",
        "witness": "all coefficients 0; output bit 0 becomes 1",
        "secondary": "NONE",
    },
    {
        "id": "I2_REVERSE_COEFF_WITHIN_BYTE",
        "category": "IMPLEMENTATION",
        "changed": "compress.c",
        "witness": "coefficient 0=833 and coefficient 7=0",
        "secondary": "NONE",
    },
    {
        "id": "I3_ROTATE_OUTPUT_BIT_LEFT",
        "category": "IMPLEMENTATION",
        "changed": "compress.c",
        "witness": "coefficient 0=833 and all other coefficients 0",
        "secondary": "NONE",
    },
    {
        "id": "I4_INVERT_D1_RESULT",
        "category": "IMPLEMENTATION",
        "changed": "compress.h",
        "witness": "canonical coefficient 0",
        "secondary": "NONE",
    },
    {
        "id": "O1_LOWER_THRESHOLD_PLUS_ONE",
        "category": "ORACLE_ASSERTION",
        "changed": "harness.c",
        "witness": "canonical coefficient 833",
        "secondary": "MSG_T1_ORACLE: lower-one boundary",
    },
    {
        "id": "O2_UPPER_THRESHOLD_MINUS_ONE",
        "category": "ORACLE_ASSERTION",
        "changed": "harness.c",
        "witness": "canonical coefficient 2496",
        "secondary": "MSG_T1_ORACLE: upper-one boundary",
    },
    {
        "id": "O3_REVERSE_ASSERTION_BIT_ORDER",
        "category": "ORACLE_ASSERTION",
        "changed": "harness.c",
        "witness": "coefficient 0=833 and coefficient 7=0",
        "secondary": "NONE",
    },
    {
        "id": "O4_SHIFT_EXPECTED_COEFFICIENT",
        "category": "ORACLE_ASSERTION",
        "changed": "harness.c",
        "witness": "coefficient 0=833 and coefficient 1=0",
        "secondary": "NONE",
    },
]

def function_span(text: str, signature_fragment: str):
    start = text.find(signature_fragment)
    if start < 0:
        raise SystemExit(
            f"FUNCTION_SIGNATURE_NOT_FOUND={signature_fragment}"
        )

    brace = text.find("{", start)
    if brace < 0:
        raise SystemExit(
            f"FUNCTION_OPEN_BRACE_NOT_FOUND={signature_fragment}"
        )

    depth = 0

    for index in range(brace, len(text)):
        char = text[index]

        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1

            if depth == 0:
                return start, index + 1

    raise SystemExit(
        f"FUNCTION_CLOSE_BRACE_NOT_FOUND={signature_fragment}"
    )

def regex_replace_once(
    text: str,
    pattern: str,
    replacement: str,
    label: str,
):
    updated, count = re.subn(
        pattern,
        replacement,
        text,
        count=1,
        flags=re.MULTILINE,
    )

    if count != 1:
        raise SystemExit(
            f"MUTATION_PATTERN_COUNT_{label}={count}"
        )

    return updated

def replace_in_function(
    text: str,
    signature_fragment: str,
    pattern: str,
    replacement: str,
    label: str,
):
    start, end = function_span(
        text,
        signature_fragment,
    )

    before = text[:start]
    function = text[start:end]
    after = text[end:]

    mutated = regex_replace_once(
        function,
        pattern,
        replacement,
        label,
    )

    return before + mutated + after

base_harness_text = base_harness.read_text(
    encoding="utf-8",
    errors="strict",
)

base_c_text = base_c.read_text(
    encoding="utf-8",
    errors="strict",
)

base_h_text = base_h.read_text(
    encoding="utf-8",
    errors="strict",
)

if (
    "return (uint8_t)((u >= 833) && (u <= 2496));"
    not in base_harness_text
):
    raise SystemExit(
        "BASE_ORACLE_BINDING=FAIL"
    )

if (
    "MSG_T1_EXACT: every output bit must equal "
    "the independent Compress1 oracle"
    not in base_harness_text
):
    raise SystemExit(
        "BASE_EXACT_ASSERTION_BINDING=FAIL"
    )

if "void mlk_poly_tomsg(" not in base_c_text:
    raise SystemExit(
        "BASE_TARGET_FUNCTION_BINDING=FAIL"
    )

if "mlk_scalar_compress_d1(" not in base_h_text:
    raise SystemExit(
        "BASE_D1_FUNCTION_BINDING=FAIL"
    )

for spec in specs:
    mutant_id = spec["id"]
    root = mutants_root / mutant_id

    harness_dir = root / "harness"
    source_dir = root / "source" / "mlkem" / "src"
    diff_dir = root / "diffs"
    metadata_dir = root / "metadata"
    build_dir = root / "build"
    inspection_dir = root / "inspection"
    command_dir = root / "commands"

    for directory in (
        harness_dir,
        source_dir,
        diff_dir,
        metadata_dir,
        build_dir,
        inspection_dir,
        command_dir,
    ):
        directory.mkdir(
            parents=True,
            exist_ok=False,
        )

    harness_path = (
        harness_dir
        / "msg_t1_exact_fips_mutant.c"
    )

    c_path = source_dir / "compress.c"
    h_path = source_dir / "compress.h"

    shutil.copy2(base_harness, harness_path)
    shutil.copy2(base_c, c_path)
    shutil.copy2(base_h, h_path)

    harness_text = base_harness_text
    c_text = base_c_text
    h_text = base_h_text

    if mutant_id == "I1_INIT_ONE":
        c_text = replace_in_function(
            c_text,
            "void mlk_poly_tomsg(",
            r"msg\s*\[\s*i\s*\]\s*=\s*0\s*;",
            "msg[i] = 1;",
            mutant_id,
        )

    elif mutant_id == "I2_REVERSE_COEFF_WITHIN_BYTE":
        c_text = replace_in_function(
            c_text,
            "void mlk_poly_tomsg(",
            r"r->coeffs\s*\[\s*8\s*\*\s*i\s*\+\s*j\s*\]",
            "r->coeffs[8 * i + (7u - j)]",
            mutant_id,
        )

    elif mutant_id == "I3_ROTATE_OUTPUT_BIT_LEFT":
        c_text = replace_in_function(
            c_text,
            "void mlk_poly_tomsg(",
            r"t\s*<<\s*j",
            "t << ((j + 1u) & 7u)",
            mutant_id,
        )

    elif mutant_id == "I4_INVERT_D1_RESULT":
        h_text = replace_in_function(
            h_text,
            "mlk_scalar_compress_d1(",
            (
                r"return\s+\(uint8_t\)"
                r"\(\(d0\s*\+\s*\(\(uint32_t\)1u\s*<<\s*30\)\)"
                r"\s*>>\s*31\)\s*;"
            ),
            (
                "return (uint8_t)((((d0 + "
                "((uint32_t)1u << 30)) >> 31) ^ 1u));"
            ),
            mutant_id,
        )

    elif mutant_id == "O1_LOWER_THRESHOLD_PLUS_ONE":
        harness_text = regex_replace_once(
            harness_text,
            (
                r"return\s+\(uint8_t\)"
                r"\(\(u\s*>=\s*833\)\s*&&\s*"
                r"\(u\s*<=\s*2496\)\)\s*;"
            ),
            (
                "return (uint8_t)"
                "((u >= 834) && (u <= 2496));"
            ),
            mutant_id,
        )

    elif mutant_id == "O2_UPPER_THRESHOLD_MINUS_ONE":
        harness_text = regex_replace_once(
            harness_text,
            (
                r"return\s+\(uint8_t\)"
                r"\(\(u\s*>=\s*833\)\s*&&\s*"
                r"\(u\s*<=\s*2496\)\)\s*;"
            ),
            (
                "return (uint8_t)"
                "((u >= 833) && (u <= 2495));"
            ),
            mutant_id,
        )

    elif mutant_id == "O3_REVERSE_ASSERTION_BIT_ORDER":
        harness_text = regex_replace_once(
            harness_text,
            (
                r"\(uint8_t\)\(\(msg\[k\s*>>\s*3\]\s*>>\s*"
                r"\(k\s*&\s*7u\)\)\s*&\s*1u\)"
            ),
            (
                "(uint8_t)((msg[k >> 3] >> "
                "(7u - (k & 7u))) & 1u)"
            ),
            mutant_id,
        )

    elif mutant_id == "O4_SHIFT_EXPECTED_COEFFICIENT":
        harness_text = regex_replace_once(
            harness_text,
            (
                r"msg_t1_threshold_oracle\s*"
                r"\(\s*a\.coeffs\[k\]\s*\)\s*;"
            ),
            (
                "msg_t1_threshold_oracle("
                "a.coeffs[(k + 1u) & 255u]);"
            ),
            mutant_id,
        )

    else:
        raise SystemExit(
            f"UNKNOWN_MUTANT={mutant_id}"
        )

    harness_path.write_text(
        harness_text,
        encoding="utf-8",
    )

    c_path.write_text(
        c_text,
        encoding="utf-8",
    )

    h_path.write_text(
        h_text,
        encoding="utf-8",
    )

    changed = []

    if not filecmp.cmp(
        base_harness,
        harness_path,
        shallow=False,
    ):
        changed.append("harness.c")

    if not filecmp.cmp(
        base_c,
        c_path,
        shallow=False,
    ):
        changed.append("compress.c")

    if not filecmp.cmp(
        base_h,
        h_path,
        shallow=False,
    ):
        changed.append("compress.h")

    if changed != [spec["changed"]]:
        raise SystemExit(
            f"UNEXPECTED_CHANGED_FILES_{mutant_id}="
            + ",".join(changed)
        )

    pairs = [
        (
            "harness.c",
            base_harness,
            harness_path,
        ),
        (
            "compress.c",
            base_c,
            c_path,
        ),
        (
            "compress.h",
            base_h,
            h_path,
        ),
    ]

    for name, original, mutated in pairs:
        original_lines = original.read_text(
            encoding="utf-8",
            errors="strict",
        ).splitlines(
            keepends=True,
        )

        mutated_lines = mutated.read_text(
            encoding="utf-8",
            errors="strict",
        ).splitlines(
            keepends=True,
        )

        diff = "".join(
            difflib.unified_diff(
                original_lines,
                mutated_lines,
                fromfile=f"authoritative/{name}",
                tofile=f"{mutant_id}/{name}",
            )
        )

        (diff_dir / f"{name}.diff").write_text(
            diff,
            encoding="utf-8",
        )

    metadata = (
        f"MUTANT_ID={mutant_id}\n"
        f"CATEGORY={spec['category']}\n"
        f"CHANGED_FILE={spec['changed']}\n"
        f"WITNESS={spec['witness']}\n"
        f"EXPECTED_SECONDARY_MARKER={spec['secondary']}\n"
        "EXPECTED_CBMC_EXIT=10\n"
        "EXPECTED_EXACT_ASSERTION_FAILURE=YES\n"
        "EXPECTED_UNWIND_FAILURE=NO\n"
    )

    (
        metadata_dir
        / "mutation_metadata.txt"
    ).write_text(
        metadata,
        encoding="utf-8",
    )

plan_lines = [
    (
        "MUTANT_ID\tCATEGORY\tCHANGED_FILE\t"
        "WITNESS\tEXPECTED_SECONDARY_MARKER"
    )
]

for spec in specs:
    plan_lines.append(
        "\t".join(
            [
                spec["id"],
                spec["category"],
                spec["changed"],
                spec["witness"],
                spec["secondary"],
            ]
        )
    )

plan_path.write_text(
    "\n".join(plan_lines) + "\n",
    encoding="utf-8",
)

def reference_bit(u: int) -> int:
    return int(833 <= u <= 2496)

witnesses = []

# I1
assert reference_bit(0) == 0
mutated_i1_bit0 = 1
assert mutated_i1_bit0 != reference_bit(0)
witnesses.append(
    "I1_INIT_ONE=PASS: input coefficient 0 yields forced bit 1"
)

# I2
coeffs = [0] * 8
coeffs[0] = 833
coeffs[7] = 0
reference = reference_bit(coeffs[0])
mutated = reference_bit(coeffs[7])
assert reference == 1 and mutated == 0
witnesses.append(
    "I2_REVERSE_COEFF_WITHIN_BYTE=PASS: "
    "coefficient 0=833, coefficient 7=0"
)

# I3
coeffs = [0] * 8
coeffs[0] = 833
reference_bit0 = reference_bit(coeffs[0])
mutated_bit0 = 0
assert reference_bit0 == 1 and mutated_bit0 == 0
witnesses.append(
    "I3_ROTATE_OUTPUT_BIT_LEFT=PASS: "
    "coefficient 0=833 moves its one-bit away from bit 0"
)

# I4
assert reference_bit(0) == 0
mutated_i4 = reference_bit(0) ^ 1
assert mutated_i4 == 1
witnesses.append(
    "I4_INVERT_D1_RESULT=PASS: coefficient 0 is inverted"
)

# O1
reference = reference_bit(833)
mutated = int(834 <= 833 <= 2496)
assert reference == 1 and mutated == 0
witnesses.append(
    "O1_LOWER_THRESHOLD_PLUS_ONE=PASS: coefficient 833"
)

# O2
reference = reference_bit(2496)
mutated = int(833 <= 2496 <= 2495)
assert reference == 1 and mutated == 0
witnesses.append(
    "O2_UPPER_THRESHOLD_MINUS_ONE=PASS: coefficient 2496"
)

# O3
bits = [0] * 8
bits[0] = reference_bit(833)
bits[7] = reference_bit(0)
reference = bits[0]
mutated = bits[7]
assert reference == 1 and mutated == 0
witnesses.append(
    "O3_REVERSE_ASSERTION_BIT_ORDER=PASS: "
    "bit 0 differs from bit 7"
)

# O4
coeffs = [833, 0]
reference_actual = reference_bit(coeffs[0])
mutated_expected = reference_bit(coeffs[1])
assert reference_actual == 1 and mutated_expected == 0
witnesses.append(
    "O4_SHIFT_EXPECTED_COEFFICIENT=PASS: "
    "coefficient 0=833, coefficient 1=0"
)

witness_path.write_text(
    "SEMANTIC_WITNESS_COUNT=8\n"
    + "\n".join(witnesses)
    + "\nALL_MUTANTS_NON_EQUIVALENT_BY_WITNESS=PASS\n",
    encoding="utf-8",
)

inspection_root.mkdir(
    parents=True,
    exist_ok=True,
)

(inspection_root / "generator_summary.txt").write_text(
    "MUTANT_COUNT=8\n"
    "IMPLEMENTATION_MUTANT_COUNT=4\n"
    "ORACLE_ASSERTION_MUTANT_COUNT=4\n"
    "CHANGED_FILE_SET_AUDIT=PASS\n"
    "SEMANTIC_WITNESS_AUDIT=PASS\n",
    encoding="utf-8",
)

print("BASE_ORACLE_BINDING=PASS")
print("BASE_EXACT_ASSERTION_BINDING=PASS")
print("BASE_TARGET_FUNCTION_BINDING=PASS")
print("BASE_D1_FUNCTION_BINDING=PASS")
print("MUTANT_COUNT=8")
print("IMPLEMENTATION_MUTANT_COUNT=4")
print("ORACLE_ASSERTION_MUTANT_COUNT=4")
print("CHANGED_FILE_SET_AUDIT=PASS")
print("SEMANTIC_WITNESS_AUDIT=PASS")
print("MUTATION_GENERATION=PASS")
PY

chmod 0755 "$MUTATION_GENERATOR"

echo "MUTATION_GENERATOR_WRITTEN=PASS"
sha256sum "$MUTATION_GENERATOR"

echo
echo "============================================================"
echo "E. GENERATE EIGHT NON-EQUIVALENT MUTANTS"
echo "============================================================"

python3 \
    "$MUTATION_GENERATOR" \
    "$BASE_HARNESS" \
    "$COMPRESS_C" \
    "$COMPRESS_H" \
    "$MUTANTS" \
    "$MUTATION_PLAN" \
    "$WITNESS_REPORT" \
    "$FAMILY_INSPECTION"

GENERATOR_EXIT=$?

echo "MUTATION_GENERATOR_EXIT=$GENERATOR_EXIT"

[ "$GENERATOR_EXIT" -eq 0 ] || {
    echo "MUTATION_GENERATION_GATE=FAIL"
    exit 16
}

echo
echo "--- Mutation plan ---"
column -t -s $'\t' "$MUTATION_PLAN" 2>/dev/null ||
cat "$MUTATION_PLAN"

echo
echo "--- Semantic witness report ---"
cat "$WITNESS_REPORT"

MUTANT_COUNT=$(
    tail -n +2 "$MUTATION_PLAN" |
    grep -Ec '.' ||
    true
)

IMPLEMENTATION_COUNT=$(
    awk -F '\t' \
        'NR > 1 && $2 == "IMPLEMENTATION" {count++}
         END {print count + 0}' \
        "$MUTATION_PLAN"
)

ORACLE_COUNT=$(
    awk -F '\t' \
        'NR > 1 && $2 == "ORACLE_ASSERTION" {count++}
         END {print count + 0}' \
        "$MUTATION_PLAN"
)

[ "$MUTANT_COUNT" -eq "$EXPECTED_MUTANT_COUNT" ] &&
[ "$IMPLEMENTATION_COUNT" -eq "$EXPECTED_IMPLEMENTATION_MUTANT_COUNT" ] &&
[ "$ORACLE_COUNT" -eq "$EXPECTED_ORACLE_ASSERTION_MUTANT_COUNT" ] || {
    echo "MUTATION_FAMILY_CARDINALITY=FAIL"
    exit 17
}

echo "MUTATION_FAMILY_CARDINALITY=PASS"

echo
echo "============================================================"
echo "F. WRITE MODEL-DERIVATION AUDITOR"
echo "============================================================"

cat > "$MODEL_DERIVER" <<'PY'
#!/usr/bin/env python3

import re
import sys
from collections import defaultdict, deque
from pathlib import Path

if len(sys.argv) != 7:
    raise SystemExit(
        "usage: derive CALL_GRAPH LOOPS UNDEFINED "
        "FUNCTIONS_OUT LOOPS_OUT UNWIND_OUT"
    )

call_path = Path(sys.argv[1])
loops_path = Path(sys.argv[2])
undefined_path = Path(sys.argv[3])
functions_out = Path(sys.argv[4])
loops_out = Path(sys.argv[5])
unwind_out = Path(sys.argv[6])

call_text = call_path.read_text(
    encoding="utf-8",
    errors="replace",
)

loops_text = loops_path.read_text(
    encoding="utf-8",
    errors="replace",
)

undefined_text = undefined_path.read_text(
    encoding="utf-8",
    errors="replace",
)

edges = defaultdict(set)

for line in call_text.splitlines():
    match = re.fullmatch(
        r"(\S+)\s*->\s*(\S+)",
        line.strip(),
    )

    if match:
        caller, callee = match.groups()
        edges[caller].add(callee)

reachable = set()
queue = deque(["main"])

while queue:
    function = queue.popleft()

    if function in reachable:
        continue

    reachable.add(function)

    for callee in sorted(edges.get(function, set())):
        if callee not in reachable:
            queue.append(callee)

expected_functions = {
    "main",
    "msg_t1_threshold_oracle",
    "mlk_msg01k_poly_tomsg",
    "mlk_scalar_compress_d1",
}

if reachable != expected_functions:
    raise SystemExit(
        "REACHABLE_FUNCTION_SET_MISMATCH="
        + ",".join(sorted(reachable))
    )

unexpected_undefined = []

for raw_line in undefined_text.splitlines():
    name = raw_line.strip()

    if not name:
        continue

    if name.startswith("Reading GOTO program"):
        continue

    if not name.startswith("__CPROVER_"):
        unexpected_undefined.append(name)

if unexpected_undefined:
    raise SystemExit(
        "UNEXPECTED_UNDEFINED_FUNCTIONS="
        + ",".join(sorted(unexpected_undefined))
    )

records = []
lines = loops_text.splitlines()

for index, line in enumerate(lines):
    match = re.match(
        r"^Loop ([^:]+):\s*$",
        line.strip(),
    )

    if not match:
        continue

    loop_id = match.group(1)
    owner = None

    for following in lines[index + 1:index + 6]:
        owner_match = re.search(
            r"\bfunction\s+(\S+)",
            following,
        )

        if owner_match:
            owner = owner_match.group(1)
            break

    if owner is None:
        raise SystemExit(
            "LOOP_OWNER_NOT_FOUND="
            + loop_id
        )

    records.append((loop_id, owner))

reachable_loops = sorted(
    (loop_id, owner)
    for loop_id, owner in records
    if owner in reachable
)

expected_loop_ids = {
    "main.0",
    "main.1",
    "mlk_msg01k_poly_tomsg.0",
    "mlk_msg01k_poly_tomsg.1",
    "mlk_msg01k_poly_tomsg.2",
}

actual_loop_ids = {
    loop_id
    for loop_id, _ in reachable_loops
}

if actual_loop_ids != expected_loop_ids:
    raise SystemExit(
        "REACHABLE_LOOP_SET_MISMATCH="
        + ",".join(sorted(actual_loop_ids))
    )

functions_out.write_text(
    "\n".join(sorted(reachable)) + "\n",
    encoding="utf-8",
)

loops_out.write_text(
    "LOOP_ID\tOWNER_FUNCTION\n"
    + "".join(
        f"{loop_id}\t{owner}\n"
        for loop_id, owner in reachable_loops
    ),
    encoding="utf-8",
)

unwindset = ",".join(
    f"{loop_id}:257"
    for loop_id, _ in reachable_loops
)

unwind_out.write_text(
    unwindset + "\n",
    encoding="utf-8",
)

print("REACHABLE_FUNCTION_COUNT=4")
print("REACHABLE_LOOP_COUNT=5")
print("UNEXPECTED_UNDEFINED_FUNCTION_COUNT=0")
print(f"UNWINDSET={unwindset}")
print("MUTANT_MODEL_DERIVATION=PASS")
PY

chmod 0755 "$MODEL_DERIVER"

echo "MODEL_DERIVER_WRITTEN=PASS"
sha256sum "$MODEL_DERIVER"

echo
echo "============================================================"
echo "G. BUILD, VALIDATE AND FREEZE ALL MUTANT GOTO MODELS"
echo "============================================================"

printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "MUTANT_ID" \
    "CATEGORY" \
    "CHANGED_FILE" \
    "GOTO_SHA256" \
    "UNWINDSET" \
    "EXPECTED_SECONDARY_MARKER" \
    > "$FREEZE_MATRIX"

BUILT_MUTANT_COUNT=0

while IFS=$'\t' read -r \
    MUTANT_ID \
    CATEGORY \
    CHANGED_FILE \
    WITNESS \
    EXPECTED_SECONDARY
do
    [ "$MUTANT_ID" = "MUTANT_ID" ] && continue

    ROOT="$MUTANTS/$MUTANT_ID"
    HARNESS="$ROOT/harness/msg_t1_exact_fips_mutant.c"
    MUTANT_C="$ROOT/source/mlkem/src/compress.c"
    MUTANT_H="$ROOT/source/mlkem/src/compress.h"
    BUILD="$ROOT/build"
    INSPECT="$ROOT/inspection"
    COMMANDS="$ROOT/commands"

    GOTO="$BUILD/msg_t1_${MUTANT_ID}.goto"
    BUILD_LOG="$INSPECT/build_log.txt"
    BUILD_COMMAND="$COMMANDS/goto_build_command.txt"

    VALIDATE_LOG="$INSPECT/validate_goto.txt"
    FUNCTIONS="$INSPECT/functions.txt"
    UNDEFINED="$INSPECT/undefined_functions.txt"
    CALL_GRAPH="$INSPECT/reachable_call_graph.txt"
    LOOPS="$INSPECT/loops.txt"
    BODIES="$INSPECT/goto_functions.txt"

    REACHABLE_FUNCTIONS="$INSPECT/reachable_functions.txt"
    REACHABLE_LOOPS="$INSPECT/reachable_loops.tsv"
    UNWINDSET_FILE="$INSPECT/frozen_unwindset.txt"
    DERIVATION_OUTPUT="$INSPECT/model_derivation_output.txt"

    PROPERTIES="$INSPECT/cbmc_show_properties.txt"
    PROPERTIES_STDERR="$INSPECT/cbmc_show_properties_stderr.txt"
    PROPERTIES_COMMAND="$COMMANDS/cbmc_show_properties_command.txt"

    BUILD_CMD=(
        goto-cc
        -std=c90
        -DMLK_CONFIG_PARAMETER_SET=768
        -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_msg01k
        -DMLK_CONFIG_NO_ASM=1
        -DMLK_CONFIG_CUSTOM_ZEROIZE=1
        -include "$FAMILY_SUPPORT/msg01f_fail_closed_zeroize.h"
        -include "$FAMILY_SUPPORT/msg01f_verify_pragma_scope.h"
        -include "$FAMILY_SUPPORT/msg01f_compress_direct_wrap_scope.h"
        -I"$ROOT/source/mlkem/src"
        -I"$SOURCE/mlkem"
        -I"$SOURCE/mlkem/src"
        -I"$FAMILY_SUPPORT"
        "$HARNESS"
        "$MUTANT_C"
        "$FAMILY_SUPPORT/msg01f_optblocker_zero.c"
        -o "$GOTO"
    )

    {
        printf '%q ' "${BUILD_CMD[@]}"
        printf '\n'
    } > "$BUILD_COMMAND"

    echo
    echo "--- Build mutant $MUTANT_ID ---"
    echo "CATEGORY=$CATEGORY"
    echo "CHANGED_FILE=$CHANGED_FILE"
    echo "WITNESS=$WITNESS"
    cat "$BUILD_COMMAND"

    "${BUILD_CMD[@]}" \
        >"$BUILD_LOG" 2>&1

    BUILD_EXIT=$?

    echo "GOTO_BUILD_EXIT=$BUILD_EXIT"
    cat "$BUILD_LOG"

    [ "$BUILD_EXIT" -eq 0 ] &&
    [ -s "$GOTO" ] || {
        echo "MUTANT_GOTO_BUILD=FAIL $MUTANT_ID"
        exit 18
    }

    goto-instrument \
        --validate-goto-binary \
        "$GOTO" \
        >"$VALIDATE_LOG" 2>&1

    VALIDATE_EXIT=$?

    echo "GOTO_VALIDATE_EXIT=$VALIDATE_EXIT"
    cat "$VALIDATE_LOG"

    [ "$VALIDATE_EXIT" -eq 0 ] || {
        echo "MUTANT_GOTO_VALIDATION=FAIL $MUTANT_ID"
        exit 19
    }

    goto-instrument --list-goto-functions "$GOTO" \
        >"$FUNCTIONS" 2>&1

    goto-instrument --list-undefined-functions "$GOTO" \
        >"$UNDEFINED" 2>&1

    goto-instrument --reachable-call-graph "$GOTO" \
        >"$CALL_GRAPH" 2>&1

    goto-instrument --show-loops "$GOTO" \
        >"$LOOPS" 2>&1

    goto-instrument --show-goto-functions "$GOTO" \
        >"$BODIES" 2>&1

    python3 \
        "$MODEL_DERIVER" \
        "$CALL_GRAPH" \
        "$LOOPS" \
        "$UNDEFINED" \
        "$REACHABLE_FUNCTIONS" \
        "$REACHABLE_LOOPS" \
        "$UNWINDSET_FILE" \
        >"$DERIVATION_OUTPUT"

    DERIVATION_EXIT=$?

    echo "MODEL_DERIVATION_EXIT=$DERIVATION_EXIT"
    cat "$DERIVATION_OUTPUT"

    [ "$DERIVATION_EXIT" -eq 0 ] || {
        echo "MUTANT_MODEL_DERIVATION_GATE=FAIL $MUTANT_ID"
        exit 20
    }

    if [ "$CATEGORY" = "IMPLEMENTATION" ]; then
        grep -Fq "$MUTANT_C" "$BODIES" || {
            echo "MUTATED_IMPLEMENTATION_PATH_BINDING=FAIL $MUTANT_ID"
            exit 21
        }
    else
        grep -Fq "$HARNESS" "$BODIES" || {
            echo "MUTATED_HARNESS_PATH_BINDING=FAIL $MUTANT_ID"
            exit 22
        }
    fi

    UNWINDSET=$(
        tr -d '\r\n' < "$UNWINDSET_FILE"
    )

    SHOW_CMD=(
        cbmc
        "$GOTO"
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
        --unwindset "$UNWINDSET"
        --show-properties
    )

    {
        printf '%q ' "${SHOW_CMD[@]}"
        printf '\n'
    } > "$PROPERTIES_COMMAND"

    "${SHOW_CMD[@]}" \
        >"$PROPERTIES" \
        2>"$PROPERTIES_STDERR"

    SHOW_EXIT=$?

    echo "SHOW_PROPERTIES_EXIT=$SHOW_EXIT"
    cat "$PROPERTIES_STDERR"

    [ "$SHOW_EXIT" -eq 0 ] || {
        echo "MUTANT_PROPERTY_INVENTORY=FAIL $MUTANT_ID"
        exit 23
    }

    EXPECTED_MARKERS=(
        "MSG_T1_MODEL: polynomial degree must be 256"
        "MSG_T1_MODEL: message size must be 32 bytes"
        "MSG_T1_ORACLE: lower-zero boundary"
        "MSG_T1_ORACLE: lower-one boundary"
        "MSG_T1_ORACLE: upper-one boundary"
        "MSG_T1_ORACLE: upper-zero boundary"
        "MSG_T1_EXACT: every output bit must equal the independent Compress1 oracle"
    )

    FOUND_MARKERS=0

    for MARKER in "${EXPECTED_MARKERS[@]}"; do
        if grep -Fq "$MARKER" "$PROPERTIES"; then
            FOUND_MARKERS=$((FOUND_MARKERS + 1))
        else
            echo "MUTANT_EXPECTED_MARKER_MISSING=$MARKER"
            exit 24
        fi
    done

    [ "$FOUND_MARKERS" -eq 7 ] || {
        echo "MUTANT_MARKER_COUNT_GATE=FAIL $MUTANT_ID"
        exit 25
    }

    GOTO_SHA=$(sha256sum "$GOTO" | awk '{print $1}')

    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$MUTANT_ID" \
        "$CATEGORY" \
        "$CHANGED_FILE" \
        "$GOTO_SHA" \
        "$UNWINDSET" \
        "$EXPECTED_SECONDARY" \
        >> "$FREEZE_MATRIX"

    BUILT_MUTANT_COUNT=$((BUILT_MUTANT_COUNT + 1))

    echo "MUTANT_GOTO_BUILD=PASS"
    echo "MUTANT_GOTO_VALIDATION=PASS"
    echo "MUTANT_MODEL_DERIVATION=PASS"
    echo "MUTANT_PROPERTY_INVENTORY=PASS"
    echo "MUTANT_FREEZE_PREFLIGHT=PASS"
done < "$MUTATION_PLAN"

[ "$BUILT_MUTANT_COUNT" -eq "$EXPECTED_MUTANT_COUNT" ] || {
    echo "BUILT_MUTANT_COUNT_GATE=FAIL"
    exit 26
}

echo
echo "--- Mutation freeze matrix ---"
column -t -s $'\t' "$FREEZE_MATRIX" 2>/dev/null ||
cat "$FREEZE_MATRIX"

echo "BUILT_MUTANT_COUNT=$BUILT_MUTANT_COUNT"
echo "ALL_MUTANT_MODELS_PREFLIGHT=PASS"

echo
echo "============================================================"
echo "H. WRITE AND LOCK MUTATION-FAMILY FREEZE"
echo "============================================================"

cat > "$FREEZE_RECORD" <<EOF
# MSG-01K — MSG-T1 Mutation-Family Freeze

Status: **FROZEN BEFORE MUTANT PROPERTY SOLVING**

## Authoritative baseline

- source commit: \`$EXPECTED_COMMIT\`
- positive GOTO SHA-256: \`$EXPECTED_BASE_GOTO_SHA256\`
- positive JSON SHA-256: \`$EXPECTED_POSITIVE_JSON_SHA256\`
- positive result: 521/521 successful;
- reachability/non-vacuity result: PASS.

## Frozen mutation family

- four implementation mutants;
- four oracle/assertion mutants;
- eight independent semantic witnesses;
- one intentionally changed file per mutant;
- actual target and helper bodies retained;
- same four-function reachable path;
- same five-loop structure;
- full derived unwindset for each model;
- all seven MSG-T1 markers retained.

## Execution acceptance rule

Every mutant must:

1. return CBMC exit 10;
2. fail the exact MSG-T1 assertion;
3. produce no unknown property status;
4. produce no unwinding failure at the frozen full bounds;
5. produce no failure outside the exact assertion and any explicitly
   registered boundary assertion.

The authoritative source, positive proof and non-vacuity evidence remain
unchanged.
EOF

{
echo "MSG-01K MUTATION FAMILY FREEZE SUMMARY"
echo
echo "SOURCE_HEAD_BINDING=PASS"
echo "SOURCE_WORKTREE_CLEAN=PASS"
echo "BASE_MANIFEST_VERIFICATION=PASS"
echo "POSITIVE_MANIFEST_VERIFICATION=PASS"
echo "NONVACUITY_MANIFEST_VERIFICATION=PASS"
echo
echo "MUTANT_COUNT=$MUTANT_COUNT"
echo "IMPLEMENTATION_MUTANT_COUNT=$IMPLEMENTATION_COUNT"
echo "ORACLE_ASSERTION_MUTANT_COUNT=$ORACLE_COUNT"
echo "SEMANTIC_WITNESS_COUNT=8"
echo "ALL_MUTANTS_NON_EQUIVALENT_BY_WITNESS=PASS"
echo "CHANGED_FILE_SET_AUDIT=PASS"
echo
echo "BUILT_MUTANT_COUNT=$BUILT_MUTANT_COUNT"
echo "ALL_MUTANT_GOTO_VALIDATIONS=PASS"
echo "ALL_MUTANT_MODEL_DERIVATIONS=PASS"
echo "ALL_MUTANT_PROPERTY_INVENTORIES=PASS"
echo
echo "MUTATION_FAMILY_STATUS=FROZEN_READY_FOR_EXPECTED_FAILURE_EXECUTION"
echo "MUTANT_PROPERTY_SOLVING_EXECUTED=NO"
} | tee "$FREEZE_SUMMARY"

(
    cd "$FREEZE_OUT" || exit 1

    find . \
        -type f \
        ! -name 'MSG01K_ARTIFACT_MANIFEST.sha256' \
        ! -name 'MSG01K_ARTIFACT_MANIFEST.sha256.sha256' \
        -print0 |
    sort -z |
    xargs -0 sha256sum \
        > "$(basename "$FREEZE_MANIFEST")"

    sha256sum -c \
        "$(basename "$FREEZE_MANIFEST")"

    sha256sum \
        "$(basename "$FREEZE_MANIFEST")" \
        > "$(basename "$FREEZE_MANIFEST_SHA")"
)

FREEZE_MANIFEST_EXIT=$?

[ "$FREEZE_MANIFEST_EXIT" -eq 0 ] || {
    echo "MUTATION_FREEZE_MANIFEST_VERIFICATION=FAIL"
    exit 27
}

find "$FREEZE_OUT" -type f -exec chmod 0444 {} +
find "$FREEZE_OUT" -type d -exec chmod 0555 {} +

echo "MUTATION_FREEZE_MANIFEST_VERIFICATION=PASS"
echo "MUTATION_FREEZE_FILE_MODE=0444"
echo "MUTATION_FREEZE_DIRECTORY_MODE=0555"
echo "MUTATION_FAMILY_LOCK=PASS"

echo
echo "============================================================"
echo "I. VERIFY LOCKED FREEZE BEFORE EXECUTION"
echo "============================================================"

(
    cd "$FREEZE_OUT" || exit 1
    sha256sum -c "$(basename "$FREEZE_MANIFEST_SHA")"
    sha256sum -c "$(basename "$FREEZE_MANIFEST")"
)

LOCKED_FREEZE_VERIFY_EXIT=$?

[ "$LOCKED_FREEZE_VERIFY_EXIT" -eq 0 ] || {
    echo "LOCKED_MUTATION_FREEZE_VERIFICATION=FAIL"
    exit 28
}

cp -- "$FREEZE_SUMMARY" \
    "$EXEC_PROVENANCE/MSG01K_MUTATION_FAMILY_FREEZE_SUMMARY.txt"

cp -- "$FREEZE_RECORD" \
    "$EXEC_PROVENANCE/MSG01K_MUTATION_FAMILY_FREEZE_RECORD.md"

cp -- "$FREEZE_MANIFEST" \
    "$EXEC_PROVENANCE/MSG01K_ARTIFACT_MANIFEST.sha256"

cp -- "$FREEZE_MANIFEST_SHA" \
    "$EXEC_PROVENANCE/MSG01K_ARTIFACT_MANIFEST.sha256.sha256"

cp -- "$POSITIVE_SUMMARY" \
    "$EXEC_PROVENANCE/MSG01H_POSITIVE_EXECUTION_SUMMARY.txt"

cp -- "$NONVAC_SUMMARY" \
    "$EXEC_PROVENANCE/MSG01J_R3_REACHABILITY_SUMMARY.txt"

echo "LOCKED_MUTATION_FREEZE_VERIFICATION=PASS"
echo "EXECUTION_PROVENANCE_COPY=PASS"

echo
echo "============================================================"
echo "J. WRITE MUTATION RESULT PARSER"
echo "============================================================"

cat > "$RESULT_PARSER" <<'PY'
#!/usr/bin/env python3

import csv
import json
import sys
from pathlib import Path

if len(sys.argv) != 6:
    raise SystemExit(
        "usage: parser RESULT.json MUTANT_ID "
        "EXPECTED_SECONDARY ALL.tsv SUMMARY.txt"
    )

json_path = Path(sys.argv[1])
mutant_id = sys.argv[2]
expected_secondary = sys.argv[3]
all_path = Path(sys.argv[4])
summary_path = Path(sys.argv[5])

data = json.loads(
    json_path.read_text(
        encoding="utf-8",
        errors="strict",
    )
)

records = {}


def walk(value):
    if isinstance(value, dict):
        property_id = value.get("property")
        status = value.get("status")

        if isinstance(property_id, str) and isinstance(status, str):
            description = value.get("description", "")
            location = value.get("sourceLocation", {})

            if not isinstance(description, str):
                description = str(description)

            if not isinstance(location, dict):
                location = {}

            records[property_id] = {
                "property": property_id,
                "status": status.upper(),
                "description": description,
                "file": str(location.get("file", "")),
                "line": str(location.get("line", "")),
                "function": str(location.get("function", "")),
            }

        for item in value.values():
            walk(item)

    elif isinstance(value, list):
        for item in value:
            walk(item)


walk(data)

if not records:
    raise SystemExit("NO_PROPERTY_RECORDS")

ordered = [
    records[property_id]
    for property_id in sorted(records)
]

with all_path.open(
    "w",
    encoding="utf-8",
    newline="",
) as handle:
    writer = csv.writer(
        handle,
        delimiter="\t",
        lineterminator="\n",
    )

    writer.writerow(
        [
            "PROPERTY",
            "STATUS",
            "DESCRIPTION",
            "FILE",
            "LINE",
            "FUNCTION",
        ]
    )

    for record in ordered:
        writer.writerow(
            [
                record["property"],
                record["status"],
                record["description"].replace("\n", " "),
                record["file"],
                record["line"],
                record["function"],
            ]
        )

success = [
    record
    for record in ordered
    if record["status"] == "SUCCESS"
]

failures = [
    record
    for record in ordered
    if record["status"] == "FAILURE"
]

unknown = [
    record
    for record in ordered
    if record["status"] not in {
        "SUCCESS",
        "FAILURE",
    }
]

exact_marker = (
    "MSG_T1_EXACT: every output bit must equal "
    "the independent Compress1 oracle"
)

exact_failures = [
    record
    for record in failures
    if exact_marker in record["description"]
]

secondary_failures = []

if expected_secondary != "NONE":
    secondary_failures = [
        record
        for record in failures
        if expected_secondary in record["description"]
    ]

unwind_failures = [
    record
    for record in failures
    if "unwind" in (
        record["property"]
        + " "
        + record["description"]
    ).lower()
]

allowed_failures = []

for record in failures:
    allowed = exact_marker in record["description"]

    if expected_secondary != "NONE":
        allowed = (
            allowed
            or expected_secondary in record["description"]
        )

    if allowed:
        allowed_failures.append(record)

unexpected_failures = [
    record
    for record in failures
    if record not in allowed_failures
]

audit_pass = (
    len(ordered) > 0
    and len(failures) >= 1
    and len(exact_failures) >= 1
    and len(unknown) == 0
    and len(unwind_failures) == 0
    and len(unexpected_failures) == 0
    and (
        expected_secondary == "NONE"
        or len(secondary_failures) >= 1
    )
)

lines = [
    f"MUTANT_ID={mutant_id}",
    "JSON_PARSE=PASS",
    f"PROPERTY_RECORD_COUNT={len(ordered)}",
    f"SUCCESS_COUNT={len(success)}",
    f"FAILURE_COUNT={len(failures)}",
    f"UNKNOWN_COUNT={len(unknown)}",
    f"EXACT_ASSERTION_FAILURE_COUNT={len(exact_failures)}",
    f"EXPECTED_SECONDARY_MARKER={expected_secondary}",
    f"EXPECTED_SECONDARY_FAILURE_COUNT={len(secondary_failures)}",
    f"UNWIND_FAILURE_COUNT={len(unwind_failures)}",
    f"UNEXPECTED_FAILURE_COUNT={len(unexpected_failures)}",
]

for index, record in enumerate(
    failures,
    start=1,
):
    lines.extend(
        [
            f"FAILURE_{index}_PROPERTY={record['property']}",
            f"FAILURE_{index}_DESCRIPTION={record['description']}",
            f"FAILURE_{index}_FUNCTION={record['function']}",
            f"FAILURE_{index}_FILE={record['file']}",
            f"FAILURE_{index}_LINE={record['line']}",
        ]
    )

lines.append(
    "MUTATION_EXPECTED_FAILURE_AUDIT=PASS"
    if audit_pass
    else "MUTATION_EXPECTED_FAILURE_AUDIT=FAIL"
)

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print("\n".join(lines))

raise SystemExit(0 if audit_pass else 20)
PY

chmod 0755 "$RESULT_PARSER"

echo "MUTATION_RESULT_PARSER_WRITTEN=PASS"
sha256sum "$RESULT_PARSER"

echo
echo "============================================================"
echo "K. EXECUTE ALL EIGHT FROZEN MUTANTS"
echo "============================================================"

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "MUTANT_ID" \
    "CATEGORY" \
    "CBMC_EXIT" \
    "FAILURE_COUNT" \
    "EXACT_FAILURE_COUNT" \
    "SECONDARY_FAILURE_COUNT" \
    "UNEXPECTED_FAILURE_COUNT" \
    "AUDIT" \
    > "$EXEC_MATRIX"

EXECUTED_MUTANT_COUNT=0
KILLED_MUTANT_COUNT=0

while IFS=$'\t' read -r \
    MUTANT_ID \
    CATEGORY \
    CHANGED_FILE \
    GOTO_SHA \
    UNWINDSET \
    EXPECTED_SECONDARY
do
    [ "$MUTANT_ID" = "MUTANT_ID" ] && continue

    GOTO="$MUTANTS/$MUTANT_ID/build/msg_t1_${MUTANT_ID}.goto"

    ACTUAL_GOTO_SHA=$(
        sha256sum "$GOTO" |
        awk '{print $1}'
    )

    [ "$ACTUAL_GOTO_SHA" = "$GOTO_SHA" ] || {
        echo "FROZEN_MUTANT_GOTO_BINDING=FAIL $MUTANT_ID"
        exit 29
    }

    RUN_DIR="$EXEC_RESULTS/$MUTANT_ID"
    mkdir -p "$RUN_DIR"

    COMMAND_FILE="$EXEC_COMMANDS/${MUTANT_ID}_cbmc_command.txt"
    JSON_FILE="$RUN_DIR/result.json"
    STDERR_FILE="$EXEC_LOGS/${MUTANT_ID}_stderr.txt"
    RESOURCE_FILE="$EXEC_RESOURCE/${MUTANT_ID}_resource_usage.txt"
    EXIT_FILE="$RUN_DIR/exit_code.txt"
    ALL_TSV="$RUN_DIR/all_properties.tsv"
    PARSED="$RUN_DIR/parsed_summary.txt"

    CMD=(
        cbmc
        "$GOTO"
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
        --unwindset "$UNWINDSET"
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
    echo "--- Execute mutant $MUTANT_ID ---"
    echo "CATEGORY=$CATEGORY"
    echo "EXPECTED_SECONDARY_MARKER=$EXPECTED_SECONDARY"
    echo "FROZEN_GOTO_SHA256=$ACTUAL_GOTO_SHA"
    echo "COMMAND=$(cat "$COMMAND_FILE")"

    set +e

    /usr/bin/time \
        -v \
        -o "$RESOURCE_FILE" \
        "${CMD[@]}" \
        >"$JSON_FILE" \
        2>"$STDERR_FILE"

    CBMC_EXIT=$?

    set -e

    printf '%s\n' "$CBMC_EXIT" > "$EXIT_FILE"

    echo "CBMC_EXIT=$CBMC_EXIT"
    echo "RESULT_JSON_SIZE_BYTES=$(wc -c < "$JSON_FILE")"
    echo "RESULT_JSON_SHA256=$(sha256sum "$JSON_FILE" | awk '{print $1}')"

    cat "$STDERR_FILE"

    [ -s "$JSON_FILE" ] || {
        echo "MUTANT_RESULT_JSON_NONEMPTY=FAIL $MUTANT_ID"
        exit 30
    }

    python3 \
        "$RESULT_PARSER" \
        "$JSON_FILE" \
        "$MUTANT_ID" \
        "$EXPECTED_SECONDARY" \
        "$ALL_TSV" \
        "$PARSED"

    PARSER_EXIT=$?

    echo "MUTATION_RESULT_PARSER_EXIT=$PARSER_EXIT"
    cat "$PARSED"

    FAILURE_COUNT=$(
        awk -F= \
            '$1=="FAILURE_COUNT" {print $2}' \
            "$PARSED"
    )

    EXACT_FAILURE_COUNT=$(
        awk -F= \
            '$1=="EXACT_ASSERTION_FAILURE_COUNT" {print $2}' \
            "$PARSED"
    )

    SECONDARY_FAILURE_COUNT=$(
        awk -F= \
            '$1=="EXPECTED_SECONDARY_FAILURE_COUNT" {print $2}' \
            "$PARSED"
    )

    UNWIND_FAILURE_COUNT=$(
        awk -F= \
            '$1=="UNWIND_FAILURE_COUNT" {print $2}' \
            "$PARSED"
    )

    UNEXPECTED_FAILURE_COUNT=$(
        awk -F= \
            '$1=="UNEXPECTED_FAILURE_COUNT" {print $2}' \
            "$PARSED"
    )

    UNKNOWN_COUNT=$(
        awk -F= \
            '$1=="UNKNOWN_COUNT" {print $2}' \
            "$PARSED"
    )

    AUDIT=$(
        awk -F= \
            '$1=="MUTATION_EXPECTED_FAILURE_AUDIT" {print $2}' \
            "$PARSED"
    )

    [ "$CBMC_EXIT" -eq 10 ] || {
        echo "MUTANT_EXPECTED_EXIT_GATE=FAIL $MUTANT_ID"
        exit 31
    }

    [ "$PARSER_EXIT" -eq 0 ] &&
    [ "$FAILURE_COUNT" -ge 1 ] &&
    [ "$EXACT_FAILURE_COUNT" -ge 1 ] &&
    [ "$UNKNOWN_COUNT" -eq 0 ] &&
    [ "$UNWIND_FAILURE_COUNT" -eq 0 ] &&
    [ "$UNEXPECTED_FAILURE_COUNT" -eq 0 ] &&
    [ "$AUDIT" = "PASS" ] || {
        echo "MUTANT_EXPECTED_FAILURE_GATE=FAIL $MUTANT_ID"
        exit 32
    }

    if [ "$EXPECTED_SECONDARY" != "NONE" ]; then
        [ "$SECONDARY_FAILURE_COUNT" -ge 1 ] || {
            echo "MUTANT_SECONDARY_FAILURE_GATE=FAIL $MUTANT_ID"
            exit 33
        }
    fi

    EXECUTED_MUTANT_COUNT=$((EXECUTED_MUTANT_COUNT + 1))
    KILLED_MUTANT_COUNT=$((KILLED_MUTANT_COUNT + 1))

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$MUTANT_ID" \
        "$CATEGORY" \
        "$CBMC_EXIT" \
        "$FAILURE_COUNT" \
        "$EXACT_FAILURE_COUNT" \
        "$SECONDARY_FAILURE_COUNT" \
        "$UNEXPECTED_FAILURE_COUNT" \
        "$AUDIT" \
        >> "$EXEC_MATRIX"

    echo "MUTANT_KILLED_BY_MSG_T1_EXACT=PASS"
done < "$FREEZE_MATRIX"

[ "$EXECUTED_MUTANT_COUNT" -eq "$EXPECTED_MUTANT_COUNT" ] &&
[ "$KILLED_MUTANT_COUNT" -eq "$EXPECTED_MUTANT_COUNT" ] || {
    echo "MUTATION_EXECUTION_CARDINALITY=FAIL"
    exit 34
}

echo
echo "--- Mutation execution matrix ---"
column -t -s $'\t' "$EXEC_MATRIX" 2>/dev/null ||
cat "$EXEC_MATRIX"

echo "EXECUTED_MUTANT_COUNT=$EXECUTED_MUTANT_COUNT"
echo "KILLED_MUTANT_COUNT=$KILLED_MUTANT_COUNT"
echo "SURVIVING_MUTANT_COUNT=$((EXECUTED_MUTANT_COUNT - KILLED_MUTANT_COUNT))"
echo "ALL_EIGHT_MUTANTS_KILLED=PASS"

echo
echo "============================================================"
echo "L. POST-EXECUTION INTEGRITY"
echo "============================================================"

SOURCE_HEAD_AFTER=$(git -C "$SOURCE" rev-parse HEAD)
SOURCE_STATUS_AFTER=$(git -C "$SOURCE" status --porcelain=v1)

COMPRESS_C_SHA_AFTER=$(sha256sum "$COMPRESS_C" | awk '{print $1}')
COMPRESS_H_SHA_AFTER=$(sha256sum "$COMPRESS_H" | awk '{print $1}')
BASE_HARNESS_SHA_AFTER=$(sha256sum "$BASE_HARNESS" | awk '{print $1}')
BASE_GOTO_SHA_AFTER=$(sha256sum "$BASE_GOTO" | awk '{print $1}')
POSITIVE_JSON_SHA_AFTER=$(sha256sum "$POSITIVE_JSON" | awk '{print $1}')

(
    cd "$FREEZE_OUT" || exit 1
    sha256sum -c "$(basename "$FREEZE_MANIFEST_SHA")"
    sha256sum -c "$(basename "$FREEZE_MANIFEST")"
)
POST_FREEZE_MANIFEST_EXIT=$?

(
    cd "$BASE" || exit 1
    sha256sum -c "$(basename "$BASE_MANIFEST_SHA")"
    sha256sum -c "$(basename "$BASE_MANIFEST")"
)
POST_BASE_MANIFEST_EXIT=$?

(
    cd "$POSITIVE" || exit 1
    sha256sum -c "$(basename "$POSITIVE_MANIFEST_SHA")"
    sha256sum -c "$(basename "$POSITIVE_MANIFEST")"
)
POST_POSITIVE_MANIFEST_EXIT=$?

(
    cd "$NONVAC" || exit 1
    sha256sum -c "$(basename "$NONVAC_MANIFEST_SHA")"
    sha256sum -c "$(basename "$NONVAC_MANIFEST")"
)
POST_NONVAC_MANIFEST_EXIT=$?

[ "$SOURCE_HEAD_AFTER" = "$EXPECTED_COMMIT" ] &&
[ -z "$SOURCE_STATUS_AFTER" ] &&
[ "$COMPRESS_C_SHA_AFTER" = "$EXPECTED_COMPRESS_C_SHA256" ] &&
[ "$COMPRESS_H_SHA_AFTER" = "$EXPECTED_COMPRESS_H_SHA256" ] &&
[ "$BASE_HARNESS_SHA_AFTER" = "$EXPECTED_BASE_HARNESS_SHA256" ] &&
[ "$BASE_GOTO_SHA_AFTER" = "$EXPECTED_BASE_GOTO_SHA256" ] &&
[ "$POSITIVE_JSON_SHA_AFTER" = "$EXPECTED_POSITIVE_JSON_SHA256" ] &&
[ "$POST_FREEZE_MANIFEST_EXIT" -eq 0 ] &&
[ "$POST_BASE_MANIFEST_EXIT" -eq 0 ] &&
[ "$POST_POSITIVE_MANIFEST_EXIT" -eq 0 ] &&
[ "$POST_NONVAC_MANIFEST_EXIT" -eq 0 ] || {
    echo "POST_EXECUTION_INPUT_INTEGRITY=FAIL"
    printf '%s\n' "$SOURCE_STATUS_AFTER"
    exit 35
}

echo "POST_EXECUTION_INPUT_INTEGRITY=PASS"

echo
echo "============================================================"
echo "M. WRITE AUTHORITATIVE MUTATION RESULT"
echo "============================================================"

cat > "$EXEC_RESULT_RECORD" <<EOF
# MSG-01L — Authoritative MSG-T1 Mutation-Sensitivity Result

## Frozen baseline

- source commit: \`$EXPECTED_COMMIT\`;
- positive GOTO SHA-256: \`$EXPECTED_BASE_GOTO_SHA256\`;
- positive JSON SHA-256: \`$EXPECTED_POSITIVE_JSON_SHA256\`;
- authoritative positive result: PASS;
- authoritative reachability/non-vacuity result: PASS.

## Mutation family

\`\`\`text
TOTAL_MUTANTS=8
IMPLEMENTATION_MUTANTS=4
ORACLE_ASSERTION_MUTANTS=4
SEMANTIC_WITNESSES=8
\`\`\`

Every mutant changed exactly one registered file and was frozen before solving.

## Execution result

\`\`\`text
EXECUTED_MUTANTS=$EXECUTED_MUTANT_COUNT
KILLED_MUTANTS=$KILLED_MUTANT_COUNT
SURVIVING_MUTANTS=0
\`\`\`

Each mutant returned CBMC exit 10 and failed the registered exact MSG-T1
functional assertion. No mutant failed an unwinding assertion at the frozen
full bounds, and no unexpected property failure was accepted.

## Supported conclusion

The accepted positive result is sensitive to the registered implementation,
oracle and coefficient/bit-mapping semantics. The evidence therefore rejects
the possibility that the exact assertion passes merely because it is
disconnected from those selected semantic details.

This is mutation sensitivity for the eight frozen mutants. It is not a claim
of completeness over every possible source, oracle or harness mutation.
EOF

{
echo "MSG-01L AUTHORITATIVE MUTATION EXECUTION SUMMARY"
echo
echo "SOURCE_HEAD_BINDING=PASS"
echo "BASE_MANIFEST_VERIFICATION=PASS"
echo "POSITIVE_MANIFEST_VERIFICATION=PASS"
echo "NONVACUITY_MANIFEST_VERIFICATION=PASS"
echo "MUTATION_FREEZE_MANIFEST_VERIFICATION=PASS"
echo "MUTATION_FAMILY_LOCK=PASS"
echo
echo "TOTAL_MUTANT_COUNT=$EXPECTED_MUTANT_COUNT"
echo "IMPLEMENTATION_MUTANT_COUNT=$EXPECTED_IMPLEMENTATION_MUTANT_COUNT"
echo "ORACLE_ASSERTION_MUTANT_COUNT=$EXPECTED_ORACLE_ASSERTION_MUTANT_COUNT"
echo "SEMANTIC_WITNESS_COUNT=8"
echo "ALL_MUTANTS_NON_EQUIVALENT_BY_WITNESS=PASS"
echo
echo "EXECUTED_MUTANT_COUNT=$EXECUTED_MUTANT_COUNT"
echo "KILLED_MUTANT_COUNT=$KILLED_MUTANT_COUNT"
echo "SURVIVING_MUTANT_COUNT=0"
echo "ALL_EIGHT_MUTANTS_KILLED=PASS"
echo
echo "ALL_MUTANTS_FAILED_MSG_T1_EXACT=PASS"
echo "ALL_MUTANTS_UNWIND_FAILURE_COUNT_ZERO=PASS"
echo "ALL_MUTANTS_UNEXPECTED_FAILURE_COUNT_ZERO=PASS"
echo
echo "POST_EXECUTION_INPUT_INTEGRITY=PASS"
echo "MUTATION_SENSITIVITY_RESULT=PASS"
echo
echo "MSG_T1_CORE_PROOF_CAMPAIGN=PASS"
echo "CAMPAIGN_STATUS=POSITIVE_NONVACUITY_AND_MUTATION_SENSITIVITY_PASS"
echo "FINAL_EVIDENCE_CONSOLIDATION_PENDING=YES"
} | tee "$EXEC_SUMMARY"

nl -ba "$EXEC_RESULT_RECORD"

echo
echo "MSG01K_L_COMPLETE"

} 2>&1 | tee "$MASTER"

CAPTURE_STATUS=${PIPESTATUS[0]}

(
    cd "$EXEC_OUT" || exit 1

    find . \
        -type f \
        ! -name 'MSG01L_ARTIFACT_MANIFEST.sha256' \
        ! -name 'MSG01L_ARTIFACT_MANIFEST.sha256.sha256' \
        -print0 |
    sort -z |
    xargs -0 sha256sum \
        > "$(basename "$EXEC_MANIFEST")"

    sha256sum -c \
        "$(basename "$EXEC_MANIFEST")"

    sha256sum \
        "$(basename "$EXEC_MANIFEST")" \
        > "$(basename "$EXEC_MANIFEST_SHA")"
)

EXEC_MANIFEST_EXIT=$?

if [ "$EXEC_MANIFEST_EXIT" -ne 0 ]; then
    echo "MUTATION_EXECUTION_MANIFEST_VERIFICATION=FAIL"

    if [ "$CAPTURE_STATUS" -eq 0 ]; then
        CAPTURE_STATUS=36
    fi
else
    echo "MUTATION_EXECUTION_MANIFEST_VERIFICATION=PASS"
fi

if [ "$CAPTURE_STATUS" -eq 0 ]; then
    find "$EXEC_OUT" -type f -exec chmod 0444 {} +
    find "$EXEC_OUT" -type d -exec chmod 0555 {} +

    echo "MUTATION_EXECUTION_FILE_MODE=0444"
    echo "MUTATION_EXECUTION_DIRECTORY_MODE=0555"
    echo "MUTATION_EXECUTION_EVIDENCE_LOCK=PASS"
fi

echo
echo "============================================================"
echo "MSG-01K/L OUTPUTS"
echo "============================================================"
echo "FREEZE_OUT=$FREEZE_OUT"
echo "FAMILY=$FAMILY"
echo "MUTATION_PLAN=$MUTATION_PLAN"
echo "WITNESS_REPORT=$WITNESS_REPORT"
echo "FREEZE_MATRIX=$FREEZE_MATRIX"
echo "FREEZE_SUMMARY=$FREEZE_SUMMARY"
echo "FREEZE_MANIFEST=$FREEZE_MANIFEST"
echo
echo "EXEC_OUT=$EXEC_OUT"
echo "EXEC_MATRIX=$EXEC_MATRIX"
echo "EXEC_RESULT_RECORD=$EXEC_RESULT_RECORD"
echo "EXEC_SUMMARY=$EXEC_SUMMARY"
echo "EXEC_MANIFEST=$EXEC_MANIFEST"
echo "MASTER=$MASTER"
echo "CAPTURE_STATUS=$CAPTURE_STATUS"

exit "$CAPTURE_STATUS"
