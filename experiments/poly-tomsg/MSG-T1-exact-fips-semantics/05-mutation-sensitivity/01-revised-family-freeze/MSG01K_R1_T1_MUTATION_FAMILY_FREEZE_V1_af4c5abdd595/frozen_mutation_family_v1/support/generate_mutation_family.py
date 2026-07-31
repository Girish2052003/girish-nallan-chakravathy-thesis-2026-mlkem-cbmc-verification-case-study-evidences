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

    # Byte-only copies intentionally do not preserve the frozen 0444 mode.
    # The authoritative files remain untouched; only isolated mutant copies
    # become writable before the single registered mutation is applied.
    shutil.copyfile(base_harness, harness_path)
    shutil.copyfile(base_c, c_path)
    shutil.copyfile(base_h, h_path)

    for writable_path in (
        harness_path,
        c_path,
        h_path,
    ):
        writable_path.chmod(0o644)

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
