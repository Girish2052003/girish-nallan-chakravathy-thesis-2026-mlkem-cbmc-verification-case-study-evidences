#!/usr/bin/env bash
set -euo pipefail
umask 0022

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
SRC="$ROOT/source/mlkem"

B60="$B6/00_PREREGISTRATION"
B61="$B6/01_CALLCHAIN_BINDING"
B62="$B6/02_ASSUMPTION_AUDIT"
B63="$B6/03_HARNESS_FREEZE/frozen_harness_family_v1"
B64="$B6/04_GOTO_PREFLIGHT/B6_4_GOTO_PREFLIGHT_MLKEM768"
B65="$B6/05_POSITIVE_EXECUTION/B6_5_POSITIVE_EXECUTION_MLKEM768_RUN4_TOMSG_PRAGMA_RECOVERY_V3"
B66="$B6/06_REACHABILITY/B6_6_REACHABILITY_MLKEM768_RUN1"
B67="$B6/07_EXPECTED_FAILURES/B6_7_EXPECTED_FAILURES_MLKEM768_RUN1"

B68="$B6/08_MUTATIONS/B6_8_MUTATION_SENSITIVITY_MLKEM768_RUN1"
B69="$B6/09_FINAL_EVIDENCE/B6_9_FINAL_EVIDENCE_FREEZE"

PACKAGE="$HOME/Downloads/SUB_T6_FINAL_EVIDENCE_2026-07-18.tar.gz"
PACKAGE_SHA="$PACKAGE.sha256"

EXPECTED_POLYC_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_POLYH_SHA="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_COMPRESSC_SHA="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESSH_SHA="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"
EXPECTED_INDCPA_SHA="ffc9cd09fb9a5926c8540b52181b064e7ae46b3d117e10ca51ac0d0ca940f6bd"
EXPECTED_POLYKH_SHA="09bdfd4a19a9cb495832a78d0f099a6c949c40014472b33fb54d66bb56e660e0"
EXPECTED_PARAMS_SHA="450fe3e0e50496921920473ae4321660f178c23d51f1453f3c537ee63c4158cb"
EXPECTED_CBMCH_SHA="12fe62f76060aa2cdd41de6170e0c787c516ae753ed32579c9c39b1af55130fb"

echo "============================================================"
echo "SUB-T6 FINAL OPERATION: B6.8 MUTATIONS + B6.9 FREEZE"
echo "============================================================"
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "ROOT=$ROOT"
echo "B6=$B6"
echo "B68=$B68"
echo "B69=$B69"
echo "PACKAGE=$PACKAGE"

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

SUCCESS=0
ACTIVE_RUN=""

cleanup()
{
    rc=$?

    if [ "$SUCCESS" -ne 1 ] && [ -n "$ACTIVE_RUN" ] && [ -d "$ACTIVE_RUN" ]; then
        stamp="$(date -u +%Y%m%dT%H%M%SZ)"
        chmod -R u+rwX "$ACTIVE_RUN" 2>/dev/null || true
        failed="${ACTIVE_RUN}_FAILED_${stamp}"
        mv "$ACTIVE_RUN" "$failed" 2>/dev/null || true
        echo "FAILED_ATTEMPT_PRESERVED=$failed" >&2
    fi

    exit "$rc"
}
trap cleanup EXIT

for tool in \
    sha256sum cbmc goto-cc goto-instrument timeout python3 \
    find sort grep awk sed wc readlink tar cmp tr stat diff
do
    command -v "$tool" >/dev/null 2>&1 ||
        die "required tool missing: $tool"
done

TIME_TOOL=""
if [ -x /usr/bin/time ]; then
    TIME_TOOL="/usr/bin/time"
fi

CBMC_VERSION="$(cbmc --version | sed -n '1p')"
GOTOCC_VERSION="$(goto-cc --version 2>&1 | sed -n '1p')"
GOTOINSTRUMENT_VERSION="$(goto-instrument --version 2>&1 | sed -n '1p')"

echo "$CBMC_VERSION" | grep -q '6\.9\.0' ||
    die "CBMC is not frozen version 6.9.0"
echo "$GOTOCC_VERSION" | grep -q '6\.9\.0' ||
    die "goto-cc is not frozen version 6.9.0"
echo "$GOTOINSTRUMENT_VERSION" | grep -q '6\.9\.0' ||
    die "goto-instrument is not frozen version 6.9.0"

for path in \
    "$ROOT" "$B6" "$SRC" \
    "$B60" "$B61" "$B62" "$B63" "$B64" "$B65" "$B66" "$B67"
do
    [ -d "$path" ] || die "required directory missing: $path"
done

mkdir -p "$B6/08_MUTATIONS" "$B6/09_FINAL_EVIDENCE"

check_hash()
{
    local file="$1"
    local expected="$2"
    local actual

    [ -f "$file" ] || die "required file missing: $file"
    actual="$(sha256sum "$file" | awk '{print $1}')"

    [ "$actual" = "$expected" ] ||
        die "hash mismatch: $file"
}

check_manifest()
{
    local dir="$1"
    local manifest="$2"

    [ -f "$dir/$manifest" ] ||
        die "manifest missing: $dir/$manifest"

    (
        cd "$dir"
        sha256sum -c "$manifest"
    )
}

freeze_run()
{
    local run="$1"
    local manifest="$2"

    (
        cd "$run"

        find . -type f \
            ! -name "$manifest" \
            -print0 |
        sort -z |
        xargs -0 sha256sum > "$manifest"

        sha256sum -c "$manifest"
    )

    find "$run" -type f -exec chmod 0444 {} +
    find "$run" -type f -name '*.py' -exec chmod 0555 {} +
    find "$run" -type f -name '*.sh' -exec chmod 0555 {} +
    find "$run" -type d -exec chmod 0555 {} +
}

verify_completed_run()
{
    local run="$1"
    local manifest="$2"
    local summary="$3"
    local verdict="$4"

    [ -d "$run" ] || return 1

    check_manifest "$run" "$manifest"

    [ -f "$run/$summary" ] ||
        die "completed-run summary missing: $run/$summary"

    grep -q "^${verdict}$" "$run/$summary" ||
        die "completed-run verdict missing: $verdict"

    return 0
}

write_command()
{
    local output="$1"
    shift

    {
        printf 'COMMAND:'
        printf ' %q' "$@"
        printf '\n'
    } > "$output"
}

echo
echo "--- Revalidating frozen source and B6.0-B6.7 evidence ---"

check_hash "$SRC/src/poly.c" "$EXPECTED_POLYC_SHA"
check_hash "$SRC/src/poly.h" "$EXPECTED_POLYH_SHA"
check_hash "$SRC/src/compress.c" "$EXPECTED_COMPRESSC_SHA"
check_hash "$SRC/src/compress.h" "$EXPECTED_COMPRESSH_SHA"
check_hash "$SRC/src/indcpa.c" "$EXPECTED_INDCPA_SHA"
check_hash "$SRC/src/poly_k.h" "$EXPECTED_POLYKH_SHA"
check_hash "$SRC/src/params.h" "$EXPECTED_PARAMS_SHA"
check_hash "$SRC/src/cbmc.h" "$EXPECTED_CBMCH_SHA"

check_hash \
    "$B60/SUB_T6_B6_0_PREREGISTRATION.json" \
    "1f5abb6572ca03a7e6517b8c20155a14216e166e3633b99b8c13e37dc37b7619"

check_hash \
    "$B60/SUB_T6_B6_0_PREREGISTRATION.md" \
    "a2db903138eefa7ce53c542a903862f68f1634fda436bd29a2d06ab681d5dd20"

check_hash \
    "$B61/B6_1_BINDING.json" \
    "8012f5802c08fba2303ba8624a3b04df8c746c406e903d01b0446d9bce6223a3"

check_hash \
    "$B61/B6_1_BINDING.md" \
    "a44c8263a02293a794204461a90fbf21dd6d89bd144cafbf4dcaa3aee1c19a83"

check_hash \
    "$B61/B6_1_CONTRACT_EXTRACTION.txt" \
    "3c45d72836b1787344660185fee3cbfaa27a05ba7091dc287ee031dcd68a4ef3"

check_hash \
    "$B61/B6_1_SOURCE_HASHES.txt" \
    "d0558e40b136f688e80d02d0d76638e3bd4284ca7202fdc7beb7a0391f15868d"

check_hash \
    "$B62/B6_2_ASSUMPTION_AUDIT.json" \
    "347de49cdea6a5036c1afd6304846918568297db3b087268dbb73ff958a21183"

check_hash \
    "$B62/B6_2_ASSUMPTION_AUDIT.md" \
    "3c2d19929f6bffb830681e82ac5d60035a3dac855de0c73fb4b9bbf599f39073"

check_manifest \
    "$B63" \
    "SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256"

check_manifest \
    "$B64" \
    "SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256"

check_manifest \
    "$B65" \
    "SUB_T6_B6_5_POSITIVE_RECOVERY_ARTIFACT_MANIFEST.sha256"

check_manifest \
    "$B66" \
    "SUB_T6_B6_6_ARTIFACT_MANIFEST.sha256"

check_manifest \
    "$B67" \
    "SUB_T6_B6_7_ARTIFACT_MANIFEST.sha256"

grep -q '^B6_4_STATUS=PASS$' \
    "$B64/SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt" ||
    die "B6.4 PASS verdict missing"

grep -q '^B6_5_STATUS=PASS$' \
    "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt" ||
    die "B6.5 PASS verdict missing"

grep -q '^B6_6_STATUS=PASS$' \
    "$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt" ||
    die "B6.6 PASS verdict missing"

grep -q '^B6_7_STATUS=PASS$' \
    "$B67/SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt" ||
    die "B6.7 PASS verdict missing"

KNOWN_GOOD_WRAP_ADAPTER="$B65/recovery_support/sub00r_b6_compress_intended_wrap_scope.h"

[ -f "$KNOWN_GOOD_WRAP_ADAPTER" ] ||
    die "known-good B6.5 wrap adapter missing"

# ===========================================================================
# B6.8 — mutation sensitivity
# ===========================================================================

if verify_completed_run \
    "$B68" \
    "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256" \
    "SUB_T6_B6_8_MUTATION_SUMMARY.txt" \
    "B6_8_STATUS=PASS"
then
    echo "B6_8_EXISTING_FROZEN_RUN_REUSED=YES"
else
    echo
    echo "============================================================"
    echo "B6.8 — MANDATORY MUTATION SENSITIVITY"
    echo "============================================================"

    [ ! -e "$B68" ] ||
        die "non-final B6.8 directory already exists: $B68"

    ACTIVE_RUN="$B68"

    mkdir -p \
        "$B68/mutation_family/original_bindings" \
        "$B68/mutation_family/mutants/M6_1_ADDITION" \
        "$B68/mutation_family/mutants/M6_2_REMOVE_REDUCE" \
        "$B68/mutation_family/mutants/M6_3_MODIFY_SB" \
        "$B68/mutation_family/mutants/M6_4_SKIP_255" \
        "$B68/build" \
        "$B68/inspection" \
        "$B68/results" \
        "$B68/witnesses" \
        "$B68/commands" \
        "$B68/logs" \
        "$B68/exit_codes" \
        "$B68/resource_usage" \
        "$B68/support" \
        "$B68/frozen_inputs"

    cp "$(readlink -f "$0")" "$B68/executed_runner.sh"

    python3 - \
        "$B60/SUB_T6_B6_0_PREREGISTRATION.json" \
        "$B68/mutation_family/B6_8_PREREGISTRATION_BINDING_AUDIT.txt" <<'PY'
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
out = Path(sys.argv[2])

data = json.loads(src.read_text(encoding="utf-8"))

expected = {
    "M6.1": {
        "detector": ["T6.3"],
        "mutation": "replace subtraction with addition",
    },
    "M6.2": {
        "detector": ["T6.6"],
        "mutation": "remove mlk_poly_reduce",
    },
    "M6.3": {
        "detector": ["T6.4"],
        "mutation": "modify source operand sb",
    },
    "M6.4": {
        "detector": ["T6.3", "T6.5"],
        "mutation": "skip coefficient 255",
    },
}

actual = data.get("mandatory_mutants")

lines = [
    f"PREREGISTRATION_STATUS={data.get('status', '')}",
    f"MANDATORY_MUTANT_COUNT={len(actual or {})}",
]

for mutant_id in sorted(expected):
    passed = (actual or {}).get(mutant_id) == expected[mutant_id]
    lines.append(
        f"{mutant_id}_EXACT_BINDING="
        + ("PASS" if passed else "FAIL")
    )
    lines.append(
        f"{mutant_id}_ACTUAL="
        + json.dumps((actual or {}).get(mutant_id), sort_keys=True)
    )
    lines.append(
        f"{mutant_id}_EXPECTED="
        + json.dumps(expected[mutant_id], sort_keys=True)
    )

out.write_text("\n".join(lines) + "\n", encoding="utf-8")

if data.get("status") != "FROZEN":
    raise SystemExit("PREREGISTRATION_NOT_FROZEN")

if actual != expected:
    raise SystemExit("MANDATORY_MUTANT_PREREGISTRATION_MISMATCH")
PY

    cp "$KNOWN_GOOD_WRAP_ADAPTER" \
        "$B68/support/sub00r_b6_compress_intended_wrap_scope.h"

    cp "$B67/support/derive_reachable_unwindset.py" \
        "$B68/support/derive_reachable_unwindset.py"

    chmod 0755 "$B68/support/derive_reachable_unwindset.py"

    cat > "$B68/support/audit_mutant_json.py" <<'PY'
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
markers = [m for m in sys.argv[3].split(",") if m]

data = json.loads(src.read_text(encoding="utf-8"))
records = []

def walk(obj):
    if isinstance(obj, dict):
        if "property" in obj and "status" in obj:
            records.append(obj)
        for value in obj.values():
            walk(value)
    elif isinstance(obj, list):
        for value in obj:
            walk(value)

walk(data)

seen = set()
unique = []

for rec in records:
    item = (
        str(rec.get("property", "")),
        str(rec.get("status", "")),
        str(rec.get("description", "")),
    )
    if item not in seen:
        seen.add(item)
        unique.append(item)

def matches_marker(item):
    prop, _, desc = item
    return any(marker in prop or marker in desc for marker in markers)

target_records = [item for item in unique if matches_marker(item)]
target_failures = [
    item for item in target_records
    if item[1] == "FAILURE"
]
other_failures = [
    item for item in unique
    if item[1] == "FAILURE" and not matches_marker(item)
]
unknown = [
    item for item in unique
    if item[1] not in {"SUCCESS", "FAILURE"}
]
success = [
    item for item in unique
    if item[1] == "SUCCESS"
]

marker_presence = {
    marker: any(
        marker in prop or marker in desc
        for prop, _, desc in unique
    )
    for marker in markers
}

target_property = (
    target_failures[0][0]
    if target_failures
    else ""
)

target_marker = ""

if target_failures:
    prop, _, desc = target_failures[0]
    for marker in markers:
        if marker in prop or marker in desc:
            target_marker = marker
            break

lines = [
    f"SUCCESS={len(success)}",
    f"TARGET_FAILURE={len(target_failures)}",
    f"OTHER_FAILURE={len(other_failures)}",
    f"UNKNOWN={len(unknown)}",
    f"TOTAL_RESULTS={len(unique)}",
    f"TARGET_PROPERTY={target_property}",
    f"TARGET_MARKER={target_marker}",
    f"EXPECTED_MARKER_COUNT={len(markers)}",
    f"PRESENT_MARKER_COUNT={sum(marker_presence.values())}",
]

for marker in markers:
    lines.append(
        f"MARKER_{marker}="
        + ("PRESENT" if marker_presence[marker] else "MISSING")
    )

for prop, status, desc in unique:
    lines.append(
        f"PROPERTY={prop}|STATUS={status}|DESCRIPTION={desc}"
    )

dst.write_text("\n".join(lines) + "\n", encoding="utf-8")

if not unique:
    raise SystemExit("NO_PROPERTY_RESULTS")
if not markers:
    raise SystemExit("NO_EXPECTED_MARKERS")
if not all(marker_presence.values()):
    missing = [
        marker for marker, present in marker_presence.items()
        if not present
    ]
    raise SystemExit(
        "EXPECTED_MARKERS_MISSING=" + ",".join(missing)
    )
if len(target_failures) < 1:
    raise SystemExit("TARGET_FAILURE_COUNT=0")
if other_failures:
    raise SystemExit(
        f"OTHER_FAILURE_COUNT={len(other_failures)}"
    )
if unknown:
    raise SystemExit(
        f"UNKNOWN_COUNT={len(unknown)}"
    )
if not target_property:
    raise SystemExit("TARGET_PROPERTY_MISSING")
if not target_marker:
    raise SystemExit("TARGET_MARKER_MISSING")
PY

    chmod 0755 "$B68/support/audit_mutant_json.py"

    cat > "$B68/support/create_exact_mutants.py" <<'PY'
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
PY

    chmod 0755 "$B68/support/create_exact_mutants.py"

    ORIGINAL_TOMSG_HARNESS="$B63/harnesses/sub_t6_tomsg_precondition_harness.c"

    python3 \
        "$B68/support/create_exact_mutants.py" \
        "$SRC/src/poly.c" \
        "$ORIGINAL_TOMSG_HARNESS" \
        "$B68/mutation_family/mutants" \
        > "$B68/mutation_family/MUTANT_CREATION_AUDIT.txt"

    cp "$SRC/src/poly.c" \
        "$B68/mutation_family/original_bindings/poly.c.original"

    cp "$ORIGINAL_TOMSG_HARNESS" \
        "$B68/mutation_family/original_bindings/sub_t6_tomsg_precondition_harness.c.original"

    sha256sum \
        "$B68/mutation_family/original_bindings/poly.c.original" \
        "$B68/mutation_family/original_bindings/sub_t6_tomsg_precondition_harness.c.original" \
        > "$B68/mutation_family/original_bindings/ORIGINAL_BINDING_SHA256.txt"

    diff -u \
        "$SRC/src/poly.c" \
        "$B68/mutation_family/mutants/M6_1_ADDITION/poly.c" \
        > "$B68/mutation_family/mutants/M6_1_ADDITION/M6_1.diff" || true

    diff -u \
        "$ORIGINAL_TOMSG_HARNESS" \
        "$B68/mutation_family/mutants/M6_2_REMOVE_REDUCE/sub_t6_tomsg_precondition_no_reduce_harness.c" \
        > "$B68/mutation_family/mutants/M6_2_REMOVE_REDUCE/M6_2.diff" || true

    diff -u \
        "$SRC/src/poly.c" \
        "$B68/mutation_family/mutants/M6_3_MODIFY_SB/poly.c" \
        > "$B68/mutation_family/mutants/M6_3_MODIFY_SB/M6_3.diff" || true

    diff -u \
        "$SRC/src/poly.c" \
        "$B68/mutation_family/mutants/M6_4_SKIP_255/poly.c" \
        > "$B68/mutation_family/mutants/M6_4_SKIP_255/M6_4.diff" || true

    [ "$(grep -c '^[-+]    r->coeffs\\[i\\] = (int16_t)(r->coeffs\\[i\\] [+-] b->coeffs\\[i\\]);$' \
        "$B68/mutation_family/mutants/M6_1_ADDITION/M6_1.diff")" -eq 2 ] ||
        die "M6.1 diff is not the exact operator mutation"

    [ "$(grep -c '^-[[:space:]]*mlk_poly_reduce(&v);$' \
        "$B68/mutation_family/mutants/M6_2_REMOVE_REDUCE/M6_2.diff")" -eq 1 ] ||
        die "M6.2 diff is not the exact reduce-call removal"

    [ "$(grep -c '^+[[:space:]]*((mlk_poly \\*)b)->coeffs\\[i\\] = 0;$' \
        "$B68/mutation_family/mutants/M6_3_MODIFY_SB/M6_3.diff")" -eq 1 ] ||
        die "M6.3 diff is not the exact sb write"

    [ "$(grep -c '^[-+]  for (i = 0; i < MLKEM_N' \
        "$B68/mutation_family/mutants/M6_4_SKIP_255/M6_4.diff")" -eq 2 ] ||
        die "M6.4 diff is not the exact loop-bound mutation"

    cat > "$B68/mutation_family/SUB_T6_B6_8_MUTATION_FAMILY_FREEZE.md" <<EOF
# SUB-T6 B6.8 mutation family freeze

Status: FROZEN before mutant GOTO construction and CBMC execution.

Mandatory mutants:
- M6.1: replace the production subtraction operator with addition.
- M6.2: remove only mlk_poly_reduce from a mutation copy of the frozen
  T6.6 harness.
- M6.3: insert one write to the source operand sb after the actual
  subtraction assignment.
- M6.4: alter only the mlk_poly_sub loop bound to skip coefficient 255.

Registered detectors:
- M6.1 -> T6.3
- M6.2 -> T6.6
- M6.3 -> T6.4
- M6.4 -> T6.3 and T6.5

The frozen production tree and frozen positive harness family are not edited.
EOF

    (
        cd "$B68/mutation_family"

        find . -type f \
            ! -name 'SUB_T6_B6_8_MUTATION_FAMILY_MANIFEST.sha256' \
            -print0 |
        sort -z |
        xargs -0 sha256sum \
            > SUB_T6_B6_8_MUTATION_FAMILY_MANIFEST.sha256

        sha256sum -c \
            SUB_T6_B6_8_MUTATION_FAMILY_MANIFEST.sha256
    )

    find "$B68/mutation_family" -type f -exec chmod 0444 {} +
    find "$B68/mutation_family" -type d -exec chmod 0555 {} +

    CASES=(
        "m6_1_addition_t6_3"
        "m6_2_remove_reduce_t6_6"
        "m6_3_modify_sb_t6_4"
        "m6_4_skip_255_t6_3"
        "m6_4_skip_255_t6_5"
    )

    HARNESSES=(
        "$B63/harnesses/sub_t6_callsite_exactness_harness.c"
        "$B68/mutation_family/mutants/M6_2_REMOVE_REDUCE/sub_t6_tomsg_precondition_no_reduce_harness.c"
        "$B63/harnesses/sub_t6_callsite_frame_harness.c"
        "$B63/harnesses/sub_t6_callsite_exactness_harness.c"
        "$B63/harnesses/sub_t6_sub_reduce_handoff_harness.c"
    )

    POLY_SOURCES=(
        "$B68/mutation_family/mutants/M6_1_ADDITION/poly.c"
        "$SRC/src/poly.c"
        "$B68/mutation_family/mutants/M6_3_MODIFY_SB/poly.c"
        "$B68/mutation_family/mutants/M6_4_SKIP_255/poly.c"
        "$B68/mutation_family/mutants/M6_4_SKIP_255/poly.c"
    )

    EXPECTED_MARKERS=(
        "SUB_T6_T6_3"
        "SUB_T6_T6_6_PRE_LOWER,SUB_T6_T6_6_PRE_UPPER"
        "SUB_T6_T6_4_SB"
        "SUB_T6_T6_3"
        "SUB_T6_T6_5_SUB"
    )

    REQUIRED_FUNCTIONS=(
        "main,mlk_sub00r_b6_poly_sub"
        "main,mlk_sub00r_b6_poly_sub,mlk_sub00r_b6_poly_tomsg"
        "main,mlk_sub00r_b6_poly_sub"
        "main,mlk_sub00r_b6_poly_sub"
        "main,mlk_sub00r_b6_poly_sub,mlk_sub00r_b6_poly_reduce"
    )

    NEED_TOMSG=(
        "no"
        "yes"
        "no"
        "no"
        "no"
    )

    FORBID_REDUCE=(
        "no"
        "yes"
        "no"
        "no"
        "no"
    )

    SUMMARY="$B68/SUB_T6_B6_8_MUTATION_SUMMARY.txt"

    printf '%s\n' \
        "SUB-T6 B6.8 MUTATION SENSITIVITY SUMMARY" \
        "" \
        "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        "CBMC_VERSION=$CBMC_VERSION" \
        "" \
        "CASE|FULL_EXIT|SUCCESS|TARGET_FAILURE|OTHER_FAILURE|UNKNOWN|TARGET_PROPERTY|TARGET_MARKER|WITNESS_EXIT|VERDICT" \
        > "$SUMMARY"

    for idx in "${!CASES[@]}"; do
        case_name="${CASES[$idx]}"
        harness="${HARNESSES[$idx]}"
        poly_source="${POLY_SOURCES[$idx]}"
        markers="${EXPECTED_MARKERS[$idx]}"
        required="${REQUIRED_FUNCTIONS[$idx]}"
        need_tomsg="${NEED_TOMSG[$idx]}"
        forbid_reduce="${FORBID_REDUCE[$idx]}"

        goto_file="$B68/build/${case_name}.goto"

        build_cmd=(
            goto-cc
            -std=c90
            -DMLK_CONFIG_PARAMETER_SET=768
            -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00r_b6
            -DMLK_CONFIG_NO_ASM=1
            -DMLK_CONFIG_CUSTOM_ZEROIZE=1
            -include "$B63/support/sub00r_b6_fail_closed_zeroize.h"
            -include "$B63/support/sub00r_b6_verify_pragma_scope.h"
        )

        if [ "$need_tomsg" = "yes" ]; then
            build_cmd+=(
                -include "$B68/support/sub00r_b6_compress_intended_wrap_scope.h"
            )
        fi

        build_cmd+=(
            -I"$SRC"
            -I"$SRC/src"
            -I"$B63/support"
            -I"$B68/support"
            "$harness"
            "$poly_source"
        )

        if [ "$need_tomsg" = "yes" ]; then
            build_cmd+=("$SRC/src/compress.c")
        fi

        build_cmd+=(
            "$B63/support/sub00r_b6_optblocker_zero.c"
            -o "$goto_file"
        )

        write_command \
            "$B68/commands/${case_name}_goto_build_command.txt" \
            "${build_cmd[@]}"

        set +e
        "${build_cmd[@]}" \
            >"$B68/logs/${case_name}_goto_build_stdout.txt" \
            2>"$B68/logs/${case_name}_goto_build_stderr.txt"
        rc_build=$?
        set -e

        printf '%s\n' "$rc_build" \
            > "$B68/exit_codes/${case_name}_goto_build_exit_code.txt"

        [ "$rc_build" -eq 0 ] ||
            die "mutant GOTO build failed: $case_name"

        [ -s "$goto_file" ] ||
            die "mutant GOTO binary missing: $case_name"

        sha256sum "$goto_file" > "$goto_file.sha256"

        goto-instrument --validate-goto-binary "$goto_file" \
            >"$B68/inspection/${case_name}_validate.txt" 2>&1

        goto-instrument --show-loops "$goto_file" \
            >"$B68/inspection/${case_name}_show_loops.txt" 2>&1

        goto-instrument --reachable-call-graph "$goto_file" \
            >"$B68/inspection/${case_name}_reachable_call_graph.txt" 2>&1

        goto-instrument --list-undefined-functions "$goto_file" \
            >"$B68/inspection/${case_name}_undefined_functions.txt" 2>&1

        python3 \
            "$B68/support/derive_reachable_unwindset.py" \
            "$B68/inspection/${case_name}_reachable_call_graph.txt" \
            "$B68/inspection/${case_name}_show_loops.txt" \
            "$B68/inspection/${case_name}_undefined_functions.txt" \
            "$B68/inspection/${case_name}_reachable_functions.txt" \
            "$B68/inspection/${case_name}_reachable_loops.tsv" \
            "$B68/inspection/${case_name}_unwindset.txt" \
            "$required" \
            "nondet_int16_t" \
            > "$B68/inspection/${case_name}_parser_output.txt"

        if [ "$forbid_reduce" = "yes" ]; then
            if grep -Fxq 'mlk_sub00r_b6_poly_reduce' \
                "$B68/inspection/${case_name}_reachable_functions.txt"; then
                die "M6.2 reduce remains reachable"
            fi

            echo "MLK_POLY_REDUCE_REACHABLE=NO" \
                > "$B68/inspection/${case_name}_removed_call_audit.txt"
        fi

        if [ "$need_tomsg" = "yes" ]; then
            mapfile -t scalar_helpers < <(
                grep '^mlk_scalar_compress_' \
                    "$B68/inspection/${case_name}_reachable_functions.txt" \
                    || true
            )

            [ "${#scalar_helpers[@]}" -eq 1 ] ||
                die "M6.2 scalar-compress helper count is not one"

            [ "${scalar_helpers[0]}" = "mlk_scalar_compress_d1" ] ||
                die "M6.2 reachable scalar helper is not d1"

            {
                echo "REACHABLE_SCALAR_COMPRESS_HELPER=mlk_scalar_compress_d1"
                echo "OTHER_REACHABLE_SCALAR_COMPRESS_HELPERS=0"
                echo "KNOWN_GOOD_B6_5_ADAPTER_REUSED=YES"
            } > "$B68/inspection/${case_name}_scalar_scope_audit.txt"
        fi

        unwindset="$(
            tr -d '\r\n' \
                < "$B68/inspection/${case_name}_unwindset.txt"
        )"

        [ -n "$unwindset" ] ||
            die "mutant unwindset empty: $case_name"

        show_cmd=(
            cbmc
            "$goto_file"
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
            --unwindset "$unwindset"
            --show-properties
        )

        write_command \
            "$B68/commands/${case_name}_show_properties_command.txt" \
            "${show_cmd[@]}"

        "${show_cmd[@]}" \
            >"$B68/inspection/${case_name}_show_properties.txt" \
            2>"$B68/inspection/${case_name}_show_properties_stderr.txt"

        IFS=',' read -r -a marker_array <<< "$markers"

        for marker in "${marker_array[@]}"; do
            grep -Fq "$marker" \
                "$B68/inspection/${case_name}_show_properties.txt" ||
                die "mutant property inventory missing marker: $case_name / $marker"
        done

        if [ "$need_tomsg" = "yes" ]; then
            if grep -Fq 'mlk_scalar_compress_d1.overflow.3' \
                "$B68/inspection/${case_name}_show_properties.txt"; then
                die "known intended-wrap property reappeared in M6.2"
            fi
        fi

        full_json="$B68/results/${case_name}_full_result.json"
        full_stderr="$B68/logs/${case_name}_full_stderr.txt"
        full_exit="$B68/exit_codes/${case_name}_full_exit_code.txt"
        full_resource="$B68/resource_usage/${case_name}_full_resource.txt"
        full_command="$B68/commands/${case_name}_full_command.txt"
        parsed="$B68/results/${case_name}_parsed.txt"

        full_cmd=(
            cbmc
            "$goto_file"
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
            --unwindset "$unwindset"
            --slice-formula
            --sat-solver minisat2
            --trace
            --json-ui
        )

        write_command "$full_command" "${full_cmd[@]}"

        echo "B6.8 CASE=$case_name PHASE=FULL_MODEL STATUS=RUNNING"

        set +e

        if [ -n "$TIME_TOOL" ]; then
            "$TIME_TOOL" -v -o "$full_resource" \
                timeout --signal=TERM --kill-after=60s 21600s \
                "${full_cmd[@]}" \
                >"$full_json" \
                2>"$full_stderr"
            rc_full=$?
        else
            timeout --signal=TERM --kill-after=60s 21600s \
                "${full_cmd[@]}" \
                >"$full_json" \
                2>"$full_stderr"
            rc_full=$?
            echo "RESOURCE_TOOL=UNAVAILABLE" > "$full_resource"
        fi

        set -e

        printf '%s\n' "$rc_full" > "$full_exit"

        [ "$rc_full" -eq 10 ] ||
            die "mutant full model returned $rc_full: $case_name"

        [ -s "$full_json" ] ||
            die "mutant result JSON missing: $case_name"

        python3 \
            "$B68/support/audit_mutant_json.py" \
            "$full_json" \
            "$parsed" \
            "$markers"

        success_count="$(
            awk -F= '/^SUCCESS=/{print $2}' "$parsed"
        )"

        target_failure="$(
            awk -F= '/^TARGET_FAILURE=/{print $2}' "$parsed"
        )"

        other_failure="$(
            awk -F= '/^OTHER_FAILURE=/{print $2}' "$parsed"
        )"

        unknown_count="$(
            awk -F= '/^UNKNOWN=/{print $2}' "$parsed"
        )"

        target_property="$(
            sed -n 's/^TARGET_PROPERTY=//p' "$parsed"
        )"

        target_marker="$(
            sed -n 's/^TARGET_MARKER=//p' "$parsed"
        )"

        sha256sum "$full_json" > "$full_json.sha256"

        witness_stdout="$B68/witnesses/${case_name}_witness.txt"
        witness_stderr="$B68/logs/${case_name}_witness_stderr.txt"
        witness_exit="$B68/exit_codes/${case_name}_witness_exit_code.txt"
        witness_resource="$B68/resource_usage/${case_name}_witness_resource.txt"
        witness_command="$B68/commands/${case_name}_witness_command.txt"

        witness_cmd=(
            cbmc
            "$goto_file"
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
            --unwindset "$unwindset"
            --slice-formula
            --sat-solver minisat2
            --property "$target_property"
            --trace
        )

        write_command \
            "$witness_command" \
            "${witness_cmd[@]}"

        echo "B6.8 CASE=$case_name PHASE=TARGETED_WITNESS STATUS=RUNNING"

        set +e

        if [ -n "$TIME_TOOL" ]; then
            "$TIME_TOOL" -v -o "$witness_resource" \
                timeout --signal=TERM --kill-after=60s 21600s \
                "${witness_cmd[@]}" \
                >"$witness_stdout" \
                2>"$witness_stderr"
            rc_witness=$?
        else
            timeout --signal=TERM --kill-after=60s 21600s \
                "${witness_cmd[@]}" \
                >"$witness_stdout" \
                2>"$witness_stderr"
            rc_witness=$?
            echo "RESOURCE_TOOL=UNAVAILABLE" > "$witness_resource"
        fi

        set -e

        printf '%s\n' "$rc_witness" > "$witness_exit"

        [ "$rc_witness" -eq 10 ] ||
            die "mutant witness returned $rc_witness: $case_name"

        grep -Fq "$target_marker" "$witness_stdout" ||
            die "mutant target marker missing from witness: $case_name"

        grep -q 'Violated property' "$witness_stdout" ||
            die "mutant witness violation heading missing: $case_name"

        grep -q 'VERIFICATION FAILED' "$witness_stdout" ||
            die "mutant witness verdict missing: $case_name"

        sha256sum "$witness_stdout" > "$witness_stdout.sha256"

        printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|KILLED\n' \
            "$case_name" \
            "$rc_full" \
            "$success_count" \
            "$target_failure" \
            "$other_failure" \
            "$unknown_count" \
            "$target_property" \
            "$target_marker" \
            "$rc_witness" \
            >> "$SUMMARY"

        echo \
          "B6.8 CASE=$case_name STATUS=KILLED TARGET_FAILURE=$target_failure OTHER_FAILURE=0 UNKNOWN=0 WITNESS=PASS"
    done

    detector_run_count="$(
        awk -F'|' '/^m6_/ {count++} END {print count+0}' "$SUMMARY"
    )"

    other_failure_total="$(
        awk -F'|' '/^m6_/ {sum += $5} END {print sum+0}' "$SUMMARY"
    )"

    unknown_total="$(
        awk -F'|' '/^m6_/ {sum += $6} END {print sum+0}' "$SUMMARY"
    )"

    witness_exit_count="$(
        grep -l '^10$' "$B68/exit_codes"/*_witness_exit_code.txt |
        wc -l
    )"

    full_exit_count="$(
        grep -l '^10$' "$B68/exit_codes"/*_full_exit_code.txt |
        wc -l
    )"

    [ "$detector_run_count" -eq 5 ] ||
        die "B6.8 detector-run count is not five"

    [ "$full_exit_count" -eq 5 ] ||
        die "B6.8 full expected-failure exit count is not five"

    [ "$witness_exit_count" -eq 5 ] ||
        die "B6.8 witness expected-failure exit count is not five"

    [ "$other_failure_total" -eq 0 ] ||
        die "B6.8 unrelated failures detected"

    [ "$unknown_total" -eq 0 ] ||
        die "B6.8 unknown properties detected"

    grep -q '^m6_1_addition_t6_3|.*|KILLED$' "$SUMMARY" ||
        die "M6.1 was not killed by T6.3"

    grep -q '^m6_2_remove_reduce_t6_6|.*|KILLED$' "$SUMMARY" ||
        die "M6.2 was not killed by T6.6"

    grep -q '^m6_3_modify_sb_t6_4|.*|KILLED$' "$SUMMARY" ||
        die "M6.3 was not killed by T6.4"

    grep -q '^m6_4_skip_255_t6_3|.*|KILLED$' "$SUMMARY" ||
        die "M6.4 was not killed by T6.3"

    grep -q '^m6_4_skip_255_t6_5|.*|KILLED$' "$SUMMARY" ||
        die "M6.4 was not killed by T6.5"

    check_hash "$SRC/src/poly.c" "$EXPECTED_POLYC_SHA"
    check_hash "$ORIGINAL_TOMSG_HARNESS" \
        "$(sha256sum "$B68/mutation_family/original_bindings/sub_t6_tomsg_precondition_harness.c.original" | awk '{print $1}')"

    {
        echo
        echo "MANDATORY_MUTANT_COUNT=4"
        echo "DETECTOR_EXECUTION_COUNT=$detector_run_count"
        echo "FULL_MODEL_EXPECTED_EXIT_COUNT=$full_exit_count"
        echo "TARGETED_WITNESS_EXPECTED_EXIT_COUNT=$witness_exit_count"
        echo "UNRELATED_FAILURE_TOTAL=$other_failure_total"
        echo "UNKNOWN_PROPERTY_TOTAL=$unknown_total"
        echo "M6_1_ADDITION=KILLED_BY_T6_3"
        echo "M6_2_REMOVE_REDUCE=KILLED_BY_T6_6"
        echo "M6_3_MODIFY_SB=KILLED_BY_T6_4"
        echo "M6_4_SKIP_255=KILLED_BY_T6_3_AND_T6_5"
        echo "MUTATION_SCORE=4/4"
        echo "ALL_MUTANTS_COMPILED=PASS"
        echo "ALL_MUTANT_GOTO_MODELS_VALID=PASS"
        echo "ALL_REGISTERED_DETECTORS_FIRED=PASS"
        echo "ALL_COUNTEREXAMPLE_WITNESSES_CAPTURED=PASS"
        echo "PRODUCTION_SOURCE_MODIFICATION=NO"
        echo "FROZEN_POSITIVE_HARNESS_MODIFICATION=NO"
        echo "BATCH5_MODIFICATION=NO"
        echo "B6_8_STATUS=PASS"
    } >> "$SUMMARY"

    cp "$B60/SUB_T6_B6_0_PREREGISTRATION.json" \
        "$B68/frozen_inputs/"
    cp "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt" \
        "$B68/frozen_inputs/"
    cp "$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt" \
        "$B68/frozen_inputs/"
    cp "$B67/SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt" \
        "$B68/frozen_inputs/"

    freeze_run \
        "$B68" \
        "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256"

    echo "B6_8_STATUS=PASS"
    ACTIVE_RUN=""
fi

# ===========================================================================
# B6.9 — final evidence freeze
# ===========================================================================

if verify_completed_run \
    "$B69" \
    "SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256" \
    "SUB_T6_B6_9_FINAL_CAMPAIGN_SUMMARY.txt" \
    "SUB_T6_CAMPAIGN_STATUS=PASS"
then
    echo "B6_9_EXISTING_FROZEN_RUN_REUSED=YES"
else
    echo
    echo "============================================================"
    echo "B6.9 — FINAL EVIDENCE FREEZE"
    echo "============================================================"

    [ ! -e "$B69" ] ||
        die "non-final B6.9 directory already exists: $B69"

    ACTIVE_RUN="$B69"

    mkdir -p \
        "$B69/stage_summaries" \
        "$B69/stage_manifests" \
        "$B69/source_binding" \
        "$B69/campaign_manifest"

    cp "$(readlink -f "$0")" "$B69/executed_finalizer.sh"

    check_manifest \
        "$B68" \
        "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256"

    grep -q '^B6_8_STATUS=PASS$' \
        "$B68/SUB_T6_B6_8_MUTATION_SUMMARY.txt" ||
        die "B6.8 PASS verdict missing"

    cp "$B60/SUB_T6_B6_0_PREREGISTRATION.json" \
        "$B69/stage_summaries/"
    cp "$B60/SUB_T6_B6_0_PREREGISTRATION.md" \
        "$B69/stage_summaries/"
    cp "$B61/B6_1_BINDING.json" \
        "$B69/stage_summaries/"
    cp "$B62/B6_2_ASSUMPTION_AUDIT.json" \
        "$B69/stage_summaries/"
    cp "$B64/SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt" \
        "$B69/stage_summaries/"
    cp "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_SUMMARY.txt" \
        "$B69/stage_summaries/"
    cp "$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt" \
        "$B69/stage_summaries/"
    cp "$B67/SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt" \
        "$B69/stage_summaries/"
    cp "$B68/SUB_T6_B6_8_MUTATION_SUMMARY.txt" \
        "$B69/stage_summaries/"

    cp "$B63/SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256" \
        "$B69/stage_manifests/"
    cp "$B64/SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256" \
        "$B69/stage_manifests/"
    cp "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_ARTIFACT_MANIFEST.sha256" \
        "$B69/stage_manifests/"
    cp "$B66/SUB_T6_B6_6_ARTIFACT_MANIFEST.sha256" \
        "$B69/stage_manifests/"
    cp "$B67/SUB_T6_B6_7_ARTIFACT_MANIFEST.sha256" \
        "$B69/stage_manifests/"
    cp "$B68/SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256" \
        "$B69/stage_manifests/"

    {
        sha256sum "$SRC/src/poly.c"
        sha256sum "$SRC/src/poly.h"
        sha256sum "$SRC/src/compress.c"
        sha256sum "$SRC/src/compress.h"
        sha256sum "$SRC/src/indcpa.c"
        sha256sum "$SRC/src/poly_k.h"
        sha256sum "$SRC/src/params.h"
        sha256sum "$SRC/src/cbmc.h"
    } > "$B69/source_binding/SUB_T6_FINAL_SOURCE_BINDING.sha256"

    positive_total="$(
        {
            grep -h '^TOTAL_RESULTS=' \
                "$B65/carried_forward_run1/results/"*_reparsed_result.txt
            grep '^TOTAL_RESULTS=' \
                "$B65/recovery_results/tomsg_precondition_corrected_parsed_result.txt"
        } |
        awk -F= '{sum += $2} END {print sum+0}'
    )"

    companion_total="$(
        awk -F= '/^COMPANION_SUCCESS=/{print $2}' \
            "$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt"
    )"

    cover_total="$(
        awk -F= '/^COVERAGE_SATISFIED=/{print $2}' \
            "$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt"
    )"

    ef_total="$(
        awk -F= '/^TARGET_FAILURE_TOTAL=/{print $2}' \
            "$B67/SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt"
    )"

    mutation_score="$(
        awk -F= '/^MUTATION_SCORE=/{print $2}' \
            "$B68/SUB_T6_B6_8_MUTATION_SUMMARY.txt"
    )"

    detector_count="$(
        awk -F= '/^DETECTOR_EXECUTION_COUNT=/{print $2}' \
            "$B68/SUB_T6_B6_8_MUTATION_SUMMARY.txt"
    )"

    [ "$positive_total" -eq 2343 ] ||
        die "final positive-property total is not 2343"

    [ "$companion_total" -eq 365 ] ||
        die "final companion-property total is not 365"

    [ "$cover_total" -eq 12 ] ||
        die "final cover total is not 12"

    [ "$ef_total" -eq 3 ] ||
        die "final expected-failure total is not 3"

    [ "$mutation_score" = "4/4" ] ||
        die "final mutation score is not 4/4"

    [ "$detector_count" -eq 5 ] ||
        die "final detector execution count is not 5"

    b66_failure="$(
        awk -F= '/^COMPANION_FAILURE=/{print $2}'             "$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt"
    )"

    b66_unknown="$(
        awk -F= '/^COMPANION_UNKNOWN=/{print $2}'             "$B66/SUB_T6_B6_6_REACHABILITY_SUMMARY.txt"
    )"

    b67_unrelated="$(
        awk -F= '/^UNEXPECTED_FAILURE_TOTAL=/{print $2}'             "$B67/SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt"
    )"

    b67_unknown="$(
        awk -F= '/^UNKNOWN_PROPERTY_TOTAL=/{print $2}'             "$B67/SUB_T6_B6_7_EXPECTED_FAILURE_SUMMARY.txt"
    )"

    b68_unrelated="$(
        awk -F= '/^UNRELATED_FAILURE_TOTAL=/{print $2}'             "$B68/SUB_T6_B6_8_MUTATION_SUMMARY.txt"
    )"

    b68_unknown="$(
        awk -F= '/^UNKNOWN_PROPERTY_TOTAL=/{print $2}'             "$B68/SUB_T6_B6_8_MUTATION_SUMMARY.txt"
    )"

    [ "$b66_failure" -eq 0 ] ||
        die "final B6.6 companion failure total is not zero"

    [ "$b66_unknown" -eq 0 ] ||
        die "final B6.6 companion unknown total is not zero"

    [ "$b67_unrelated" -eq 0 ] ||
        die "final B6.7 unrelated failure total is not zero"

    [ "$b67_unknown" -eq 0 ] ||
        die "final B6.7 unknown total is not zero"

    [ "$b68_unrelated" -eq 0 ] ||
        die "final B6.8 unrelated failure total is not zero"

    [ "$b68_unknown" -eq 0 ] ||
        die "final B6.8 unknown total is not zero"

    (
        cd "$B6"

        find \
            00_PREREGISTRATION \
            01_CALLCHAIN_BINDING \
            02_ASSUMPTION_AUDIT \
            03_HARNESS_FREEZE \
            04_GOTO_PREFLIGHT \
            05_POSITIVE_EXECUTION \
            06_REACHABILITY \
            07_EXPECTED_FAILURES \
            08_MUTATIONS \
            -type f \
            -print0 |
        sort -z |
        xargs -0 sha256sum \
            > "$B69/campaign_manifest/SUB_T6_B6_0_TO_B6_8_CONTENT_MANIFEST.sha256"
    )

    campaign_file_count="$(
        wc -l \
            < "$B69/campaign_manifest/SUB_T6_B6_0_TO_B6_8_CONTENT_MANIFEST.sha256"
    )"

    {
        echo "B6_0_PREREGISTRATION_HASH_BINDING=PASS"
        echo "B6_1_CALLCHAIN_BINDING_HASH_BINDING=PASS"
        echo "B6_2_ASSUMPTION_AUDIT_HASH_BINDING=PASS"
        echo "B6_3_MANIFEST_ENTRIES=$(wc -l < "$B63/SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256")"
        echo "B6_4_MANIFEST_ENTRIES=$(wc -l < "$B64/SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256")"
        echo "B6_5_MANIFEST_ENTRIES=$(wc -l < "$B65/SUB_T6_B6_5_POSITIVE_RECOVERY_ARTIFACT_MANIFEST.sha256")"
        echo "B6_6_MANIFEST_ENTRIES=$(wc -l < "$B66/SUB_T6_B6_6_ARTIFACT_MANIFEST.sha256")"
        echo "B6_7_MANIFEST_ENTRIES=$(wc -l < "$B67/SUB_T6_B6_7_ARTIFACT_MANIFEST.sha256")"
        echo "B6_8_MANIFEST_ENTRIES=$(wc -l < "$B68/SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256")"
        echo "CAMPAIGN_CONTENT_FILE_COUNT=$campaign_file_count"
        echo "ALL_STAGE_MANIFESTS_REVALIDATED=PASS"
    } > "$B69/SUB_T6_B6_9_STAGE_MANIFEST_AUDIT.txt"

    cat > "$B69/SUB_T6_B6_9_FINAL_CAMPAIGN_SUMMARY.txt" <<EOF
SUB-T6 FINAL CAMPAIGN SUMMARY

FREEZE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TOOL_MODEL=$CBMC_VERSION
PARAMETER_SET=ML-KEM-768
MLKEM_N=256
MLKEM_Q=3329
MLK_INVNTT_BOUND=26632

THEOREM_ID=SUB-T6
THEOREM_TITLE=Production Call-Site Contract Satisfaction and Subtract-Reduce Handoff Correctness of mlk_poly_sub in mlk_indcpa_dec

PRODUCTION_SLICE=mlk_poly_sub(v,sb); mlk_poly_reduce(v); mlk_poly_tomsg(m,v)
CALLER_V_DOMAIN=0 <= v[i] < 3329
CALLER_SB_DOMAIN=-26632 < sb[i] < 26632
DERIVED_SUBTRACTION_RANGE=[-26631,29959]
SIGNED_INT16_RANGE=[-32768,32767]

B6_0_PREREGISTRATION=PASS
B6_1_CALLCHAIN_BINDING=PASS
B6_2_ASSUMPTION_AUDIT=PASS
B6_3_HARNESS_FREEZE=PASS
B6_4_GOTO_PREFLIGHT=PASS
B6_5_POSITIVE_EXECUTION=PASS
B6_6_REACHABILITY_NONVACUITY=PASS
B6_7_EXPECTED_FAILURE_CONTROLS=PASS
B6_8_MUTATION_SENSITIVITY=PASS
B6_9_FINAL_EVIDENCE_FREEZE=PASS

T6_1_OBJECT_VALIDITY_AND_SEPARATION=PASS
T6_2_REPRESENTABILITY_DERIVATION=PASS
T6_3_CALLSITE_EXACTNESS=PASS
T6_4_CALLER_FRAME_PRESERVATION=PASS
T6_5_SUB_REDUCE_HANDOFF=PASS
T6_6_TOMSG_PRECONDITION_AND_CONST_INPUT=PASS
T6_7_COMPLETE_BOUNDED_SLICE_SAFETY=PASS

POSITIVE_CBMC_SUCCESS_TOTAL=$positive_total
POSITIVE_CBMC_FAILURE_TOTAL=0
POSITIVE_CBMC_UNKNOWN_TOTAL=0
REACHABILITY_COMPANION_SUCCESS_TOTAL=$companion_total
REACHABILITY_COVER_SATISFIED_TOTAL=$cover_total
EXPECTED_FAILURE_TARGET_TOTAL=$ef_total
EXPECTED_FAILURE_UNRELATED_TOTAL=0
EXPECTED_FAILURE_UNKNOWN_TOTAL=0
MANDATORY_MUTATION_SCORE=$mutation_score
MUTATION_DETECTOR_EXECUTION_COUNT=$detector_count
MUTATION_UNRELATED_FAILURE_TOTAL=0
MUTATION_UNKNOWN_TOTAL=0

M6_1_ADDITION=KILLED_BY_T6_3
M6_2_REMOVE_REDUCE=KILLED_BY_T6_6
M6_3_MODIFY_SB=KILLED_BY_T6_4
M6_4_SKIP_255=KILLED_BY_T6_3_AND_T6_5

CLAIM=Under the frozen ML-KEM-768 source, registered caller-domain assumptions, successful-allocation object model, CBMC 6.9.0 machine model, complete registered unwindsets and required safety checks, the actual bounded production functions satisfy T6.1 through T6.7.
NONCLAIM_COMPLETE_KPKE_DECRYPT=YES
NONCLAIM_CORRECT_PLAINTEXT_FOR_EVERY_CIPHERTEXT=YES
NONCLAIM_UPSTREAM_NTT_BASEMUL_DECOMPRESSION_CORRECTNESS=YES
NONCLAIM_ALLOCATOR_OOM_CORRECTNESS=YES
NONCLAIM_CONSTANT_TIME_OR_SIDE_CHANNEL_FREEDOM=YES
NONCLAIM_WHOLE_LIBRARY_END_TO_END_MLKEM_CORRECTNESS=YES
NONCLAIM_UNBOUNDED_OR_UNREGISTERED_CONFIGURATION_CORRECTNESS=YES

PRODUCTION_SOURCE_MODIFICATION=NO
FROZEN_POSITIVE_HARNESS_MODIFICATION=NO
BATCH5_MODIFICATION=NO
FAILED_ATTEMPTS_PRESERVED=YES
ALL_STAGE_MANIFESTS_REVALIDATED=PASS
CAMPAIGN_CONTENT_FILE_COUNT=$campaign_file_count
SUB_T6_CAMPAIGN_STATUS=PASS
EOF

    cat > "$B69/SUB_T6_B6_9_PROFESSOR_VERDICT.md" <<EOF
# SUB-T6 final verification verdict

## Verdict

The SUB-T6 campaign passed for the frozen ML-KEM-768 configuration.

Under the registered caller interfaces:

- \(0 \le v[i] < 3329\);
- \(-26632 < sb[i] < 26632\);
- valid, complete, distinct polynomial objects on the successful-allocation
  path;

CBMC 6.9.0 verified the selected production slice:

\`\`\`c
mlk_poly_sub(v, sb);
mlk_poly_reduce(v);
mlk_poly_tomsg(m, v);
\`\`\`

The campaign established exact subtraction, signed-16-bit representability,
source/frame preservation, canonical subtract-to-reduce handoff, downstream
\`mlk_poly_tomsg\` input compatibility and bounded slice safety.

## Evidence totals

- Positive CBMC properties: **$positive_total successful, 0 failed, 0 unknown**
- Reachability companion: **$companion_total successful**
- Non-vacuity goals: **$cover_total/$cover_total satisfied**
- Expected-failure controls: **$ef_total/$ef_total isolated and witnessed**
- Mandatory mutation score: **$mutation_score**
- Mutation detector executions: **$detector_count/$detector_count killed**

## Mutation sensitivity

- Addition in place of subtraction was detected by T6.3.
- Removal of reduction was detected by T6.6.
- Modification of \`sb\` was detected by T6.4.
- Skipping coefficient 255 was detected independently by T6.3 and T6.5.

## Scope boundary

This is a property-specific bounded proof of the registered integration slice.
It is not a proof of complete K-PKE decryption, every upstream cryptographic
operation, allocator failure paths, constant-time behaviour, side-channel
freedom, whole-library correctness or end-to-end ML-KEM correctness.
EOF

    cat > "$B69/SUB_T6_B6_9_FINAL_EVIDENCE_INDEX.txt" <<EOF
SUB-T6 FINAL EVIDENCE INDEX

1. Preregistration:
   $B60

2. Production call-chain binding:
   $B61

3. Assumption and arithmetic audit:
   $B62

4. Frozen positive harness family:
   $B63

5. GOTO preflight:
   $B64

6. Positive CBMC execution:
   $B65

7. Reachability and non-vacuity:
   $B66

8. Expected-failure controls:
   $B67

9. Mutation sensitivity:
   $B68

10. Final evidence freeze:
    $B69

FINAL_STATUS=PASS
EOF

    freeze_run \
        "$B69" \
        "SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256"

    echo "B6_9_STATUS=PASS"
    ACTIVE_RUN=""
fi

check_manifest \
    "$B68" \
    "SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256"

check_manifest \
    "$B69" \
    "SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256"

grep -q '^B6_8_STATUS=PASS$' \
    "$B68/SUB_T6_B6_8_MUTATION_SUMMARY.txt" ||
    die "final B6.8 verdict missing"

grep -q '^SUB_T6_CAMPAIGN_STATUS=PASS$' \
    "$B69/SUB_T6_B6_9_FINAL_CAMPAIGN_SUMMARY.txt" ||
    die "final campaign verdict missing"

FINAL_ARCHIVE_ROOT="$(basename "$B6")"
FINAL_ARCHIVE_B68_MANIFEST="$FINAL_ARCHIVE_ROOT/08_MUTATIONS/B6_8_MUTATION_SENSITIVITY_MLKEM768_RUN1/SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256"
FINAL_ARCHIVE_B69_MANIFEST="$FINAL_ARCHIVE_ROOT/09_FINAL_EVIDENCE/B6_9_FINAL_EVIDENCE_FREEZE/SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256"

validate_final_package()
{
    local archive="$1"

    [ -f "$archive" ] ||
        die "final package missing: $archive"

    tar -tzf "$archive" >/dev/null ||
        die "final package is not a valid gzip tar"

    python3 - "$archive" <<'PY'
import sys
import tarfile

archive = sys.argv[1]

with tarfile.open(archive, "r:gz") as tar:
    bad = []

    for member in tar.getmembers():
        name = member.name

        if name.startswith("/"):
            bad.append("ABSOLUTE:" + name)
        if ".." in name.split("/"):
            bad.append("DOTDOT:" + name)
        if member.issym() or member.islnk():
            bad.append("LINK:" + name)

    if bad:
        raise SystemExit(
            "UNSAFE_FINAL_PACKAGE=" + ",".join(bad)
        )
PY

    tar -xOf "$archive" "$FINAL_ARCHIVE_B68_MANIFEST" |
        cmp - "$B68/SUB_T6_B6_8_ARTIFACT_MANIFEST.sha256"         >/dev/null ||
        die "final package B6.8 manifest binding failed"

    tar -xOf "$archive" "$FINAL_ARCHIVE_B69_MANIFEST" |
        cmp - "$B69/SUB_T6_B6_9_ARTIFACT_MANIFEST.sha256"         >/dev/null ||
        die "final package B6.9 manifest binding failed"
}

if [ -e "$PACKAGE" ]; then
    validate_final_package "$PACKAGE"

    if [ ! -e "$PACKAGE_SHA" ]; then
        sha256sum "$PACKAGE" > "$PACKAGE_SHA"
    fi

    expected_package_sha="$(
        awk '{print $1}' "$PACKAGE_SHA"
    )"

    actual_package_sha="$(
        sha256sum "$PACKAGE" | awk '{print $1}'
    )"

    [ "$actual_package_sha" = "$expected_package_sha" ] ||
        die "existing final package SHA-256 mismatch"

    echo "FINAL_EXISTING_PACKAGE_REUSED=YES"
else
    [ ! -e "$PACKAGE_SHA" ] ||
        die "orphan final package sidecar already exists"

    tar -C "$ROOT"         -czf "$PACKAGE"         "$FINAL_ARCHIVE_ROOT"

    validate_final_package "$PACKAGE"
    sha256sum "$PACKAGE" > "$PACKAGE_SHA"
fi

SUCCESS=1
trap - EXIT

echo
echo "============================================================"
echo "FINAL SUB-T6 CAMPAIGN VERDICT"
echo "============================================================"

grep -E \
  'MANDATORY_MUTANT_COUNT=|DETECTOR_EXECUTION_COUNT=|FULL_MODEL_EXPECTED_EXIT_COUNT=|TARGETED_WITNESS_EXPECTED_EXIT_COUNT=|UNRELATED_FAILURE_TOTAL=|UNKNOWN_PROPERTY_TOTAL=|M6_1_ADDITION=|M6_2_REMOVE_REDUCE=|M6_3_MODIFY_SB=|M6_4_SKIP_255=|MUTATION_SCORE=|ALL_REGISTERED_DETECTORS_FIRED=|ALL_COUNTEREXAMPLE_WITNESSES_CAPTURED=|B6_8_STATUS=' \
  "$B68/SUB_T6_B6_8_MUTATION_SUMMARY.txt"

grep -E \
  'B6_0_PREREGISTRATION=|B6_1_CALLCHAIN_BINDING=|B6_2_ASSUMPTION_AUDIT=|B6_3_HARNESS_FREEZE=|B6_4_GOTO_PREFLIGHT=|B6_5_POSITIVE_EXECUTION=|B6_6_REACHABILITY_NONVACUITY=|B6_7_EXPECTED_FAILURE_CONTROLS=|B6_8_MUTATION_SENSITIVITY=|B6_9_FINAL_EVIDENCE_FREEZE=|POSITIVE_CBMC_SUCCESS_TOTAL=|POSITIVE_CBMC_FAILURE_TOTAL=|POSITIVE_CBMC_UNKNOWN_TOTAL=|REACHABILITY_COMPANION_SUCCESS_TOTAL=|REACHABILITY_COVER_SATISFIED_TOTAL=|EXPECTED_FAILURE_TARGET_TOTAL=|MANDATORY_MUTATION_SCORE=|MUTATION_DETECTOR_EXECUTION_COUNT=|PRODUCTION_SOURCE_MODIFICATION=|FROZEN_POSITIVE_HARNESS_MODIFICATION=|ALL_STAGE_MANIFESTS_REVALIDATED=|SUB_T6_CAMPAIGN_STATUS=' \
  "$B69/SUB_T6_B6_9_FINAL_CAMPAIGN_SUMMARY.txt"

echo
echo "--- Final evidence package ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$PACKAGE"
cat "$PACKAGE_SHA"

echo
echo "SUB_T6_B6_8_MANDATORY_MUTANTS=4"
echo "SUB_T6_B6_8_MUTATION_SCORE=4/4"
echo "SUB_T6_B6_8_DETECTOR_RUNS=5/5"
echo "SUB_T6_B6_8_STATUS=PASS"
echo "SUB_T6_B6_9_ALL_STAGES_FROZEN=PASS"
echo "SUB_T6_B6_9_EXACT_TOTALS_AUDITED=PASS"
echo "SUB_T6_B6_9_FINAL_PACKAGE_PATH_SAFETY=PASS"
echo "SUB_T6_B6_9_FINAL_PACKAGE_MANIFEST_BINDING=PASS"
echo "SUB_T6_B6_9_FINAL_PACKAGE_CREATED=YES"
echo "SUB_T6_PRODUCTION_MODIFIED=NO"
echo "SUB_T6_FROZEN_POSITIVE_HARNESSES_MODIFIED=NO"
echo "SUB_T6_FINAL_UPLOAD_REQUIRED=YES"
echo "SUB_T6_CAMPAIGN_STATUS=PASS"
