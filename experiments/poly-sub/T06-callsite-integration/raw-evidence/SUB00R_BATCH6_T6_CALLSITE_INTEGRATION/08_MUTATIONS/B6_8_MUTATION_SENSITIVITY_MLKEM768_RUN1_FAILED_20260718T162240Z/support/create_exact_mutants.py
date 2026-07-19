#!/usr/bin/env python3
from pathlib import Path
import hashlib
import sys

(
    poly_path,
    tomsg_harness_path,
    output_root,
) = sys.argv[1:]

poly_file = Path(poly_path)
harness_file = Path(tomsg_harness_path)
root = Path(output_root)

poly = poly_file.read_text(encoding="utf-8")
tomsg = harness_file.read_text(encoding="utf-8")

expected_poly_sha = (
    "f427dda46e29d53d3e33d683c9a8483b"
    "ade3568eff43fb97b868a21bfd07c722"
)

actual_poly_sha = hashlib.sha256(
    poly_file.read_bytes()
).hexdigest()

if actual_poly_sha != expected_poly_sha:
    raise SystemExit(
        f"ORIGINAL_POLY_SHA_MISMATCH={actual_poly_sha}"
    )

start = poly.index(
    "void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)"
)
end = poly.index(
    '\n}\n\n#include "zetas.inc"',
    start,
) + 2

segment = poly[start:end]

assignment = (
    "    r->coeffs[i] = "
    "(int16_t)(r->coeffs[i] - b->coeffs[i]);"
)

if segment.count(assignment) != 1:
    raise SystemExit(
        "SUBTRACTION_ASSIGNMENT_COUNT="
        + str(segment.count(assignment))
    )

loop_header = "  for (i = 0; i < MLKEM_N; i++)"

if segment.count(loop_header) != 1:
    raise SystemExit(
        "SUB_LOOP_HEADER_COUNT="
        + str(segment.count(loop_header))
    )

m61_segment = segment.replace(
    assignment,
    (
        "    r->coeffs[i] = "
        "(int16_t)(r->coeffs[i] + b->coeffs[i]);"
    ),
    1,
)

m61 = poly[:start] + m61_segment + poly[end:]

m63_segment = segment.replace(
    assignment,
    assignment + "\n    ((mlk_poly *)b)->coeffs[i] = 0;",
    1,
)

m63 = poly[:start] + m63_segment + poly[end:]

m64_segment = segment.replace(
    loop_header,
    "  for (i = 0; i < MLKEM_N - 1u; i++)",
    1,
)

m64 = poly[:start] + m64_segment + poly[end:]

reduce_call = "  mlk_poly_reduce(&v);\n\n"

if tomsg.count(reduce_call) != 1:
    raise SystemExit(
        "TOMSG_REDUCE_CALL_COUNT="
        + str(tomsg.count(reduce_call))
    )

m62 = tomsg.replace(reduce_call, "", 1)

outputs = {
    "M6_1_ADDITION/poly.c": m61,
    "M6_2_REMOVE_REDUCE/sub_t6_tomsg_precondition_no_reduce_harness.c": m62,
    "M6_3_MODIFY_SB/poly.c": m63,
    "M6_4_SKIP_255/poly.c": m64,
}

for relative, content in outputs.items():
    output = root / relative
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(content, encoding="utf-8")

print("M6_1_EXACT_OPERATOR_REPLACEMENTS=1")
print("M6_2_EXACT_CALL_REMOVALS=1")
print("M6_3_EXACT_SOURCE_WRITES_INSERTED=1")
print("M6_4_EXACT_LOOP_BOUND_REPLACEMENTS=1")
print("MUTANT_CREATION_STATUS=PASS")
