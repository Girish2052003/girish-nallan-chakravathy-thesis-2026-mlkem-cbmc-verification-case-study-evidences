#!/usr/bin/env bash
set -uo pipefail
shopt -s nullglob

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t4_20260726T024145Z"
CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"

POSITIVE_PROOF="${WORK_REPO}/proofs/cbmc/polycomp_d4_t4_projection_distortion"
POSITIVE_HARNESS="${POSITIVE_PROOF}/polycomp_d4_t4_projection_distortion_harness.c"
POSITIVE_MAKEFILE="${POSITIVE_PROOF}/Makefile"
POSITIVE_GOTO="${POSITIVE_PROOF}/gotos/polycomp_d4_t4_projection_distortion_harness.goto"

EXPECTED_POSITIVE_HARNESS_SHA256="f9b385228c2bed2eb5c5f8be075f0a12c604cba5e8265fd632aab49d525dae1c"
EXPECTED_POSITIVE_MAKEFILE_SHA256="0044f48f8df604a7c1504b9b2cd4c8ec566fa3403c483cf93771a2eafcf796e2"
EXPECTED_POSITIVE_GOTO_SHA256="e9c0f8031f3e7edbcdde441743f12d87cb0b23d09853c2d3458fae04db1483eb"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_T4_00B_WITNESS_FIXED_IDEMPOTENCE_LOCALITY"

WITNESS_PROOF_NAME="polycomp_d4_t4_sharp_witness_${UTC_STAMP}"
WITNESS_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${WITNESS_PROOF_NAME}"
WITNESS_HARNESS_NAME="polycomp_d4_t4_sharp_witness_harness"
WITNESS_HARNESS="${WITNESS_PROOF_DIR}/${WITNESS_HARNESS_NAME}.c"
WITNESS_GOTO="${WITNESS_PROOF_DIR}/gotos/${WITNESS_HARNESS_NAME}.goto"

FIXED_PROOF_NAME="polycomp_d4_t4_fixed_point_characterization_${UTC_STAMP}"
FIXED_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${FIXED_PROOF_NAME}"
FIXED_HARNESS_NAME="polycomp_d4_t4_fixed_point_characterization_harness"
FIXED_HARNESS="${FIXED_PROOF_DIR}/${FIXED_HARNESS_NAME}.c"
FIXED_GOTO="${FIXED_PROOF_DIR}/gotos/${FIXED_HARNESS_NAME}.goto"

IDEMP_PROOF_NAME="polycomp_d4_t4_projection_idempotence_${UTC_STAMP}"
IDEMP_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${IDEMP_PROOF_NAME}"
IDEMP_HARNESS_NAME="polycomp_d4_t4_projection_idempotence_harness"
IDEMP_HARNESS="${IDEMP_PROOF_DIR}/${IDEMP_HARNESS_NAME}.c"
IDEMP_GOTO="${IDEMP_PROOF_DIR}/gotos/${IDEMP_HARNESS_NAME}.goto"

LOCALITY_PROOF_NAME="polycomp_d4_t4_coordinate_locality_${UTC_STAMP}"
LOCALITY_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${LOCALITY_PROOF_NAME}"
LOCALITY_HARNESS_NAME="polycomp_d4_t4_coordinate_locality_harness"
LOCALITY_HARNESS="${LOCALITY_PROOF_DIR}/${LOCALITY_HARNESS_NAME}.c"
LOCALITY_GOTO="${LOCALITY_PROOF_DIR}/gotos/${LOCALITY_HARNESS_NAME}.goto"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_T4_00B_WITNESS_FIXED_IDEMPOTENCE_LOCALITY_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

FAIL=0
mkdir -p "$STAGE_DIR"

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

write_makefile()
{
    local proof_dir="$1"
    local proof_name="$2"
    local harness_name="$3"

    cat > "${proof_dir}/Makefile" <<MAKEFILE_EOF
include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = ${harness_name}
PROOF_UID = ${proof_name}

DEFINES +=
INCLUDES +=
REMOVE_FUNCTION_BODY +=

CHECK_FUNCTION_CONTRACTS =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

PROOF_SOURCES += \$(PROOFDIR)/\$(HARNESS_FILE).c
PROJECT_SOURCES += \$(SRCDIR)/mlkem/src/compress.c

UNWINDSET +=
CBMCFLAGS = --smt2
EXTERNAL_SAT_SOLVER =

FUNCTION_NAME = mlk_poly_compress_d4_c
CBMC_OBJECT_BITS = 8

include ../Makefile.common
MAKEFILE_EOF
}

build_goto()
{
    local proof_name="$1"
    local goto_file="$2"
    local label="$3"

    local runner_log="${STAGE_DIR}/${label}_RUNNER_${UTC_STAMP}.txt"
    local runner_json="${STAGE_DIR}/${label}_RUNNER_${UTC_STAMP}.json"

    (
        cd "$WORK_REPO/proofs/cbmc" || exit 90

        MLKEM_K=3 \
        ./run-cbmc-proofs.py \
            --summarize \
            -j1 \
            -p "$proof_name" \
            --output-result-json "$runner_json"
    ) > "$runner_log" 2>&1

    local runner_exit=$?

    printf '%s_RUNNER_EXIT=%s\n' "$label" "$runner_exit"
    printf '%s_RUNNER_LOG=%s\n' "$label" "$runner_log"
    printf '%s_RUNNER_JSON=%s\n' "$label" "$runner_json"
    printf '%s_RUNNER_NONZERO_ACCEPTABLE_WHEN_GOTO_EXISTS=YES\n' "$label"

    tail -n 80 "$runner_log" 2>/dev/null || true

    if [[ ! -f "$goto_file" ]]; then
        mark_fail "$label runner did not produce GOTO"
        return 1
    fi

    printf '%s_GOTO_FILE=%s\n' "$label" "$goto_file"
    printf '%s_GOTO_SIZE=%s\n' "$label" "$(stat -c '%s' "$goto_file")"
    printf '%s_GOTO_SHA256=%s\n' "$label" "$(
        sha256sum "$goto_file" |
        awk '{print $1}'
    )"

    return 0
}

derive_unwindset()
{
    local goto_file="$1"
    local label="$2"
    local expected_harness_loops="$3"

    local loop_report="${STAGE_DIR}/${label}_LOOP_REPORT_${UTC_STAMP}.txt"
    local loop_map="${STAGE_DIR}/${label}_LOOP_MAP_${UTC_STAMP}.txt"

    goto-instrument \
        --show-loops \
        "$goto_file" \
        > "$loop_report" 2>&1

    local discovery_exit=$?

    printf '%s_LOOP_DISCOVERY_EXIT=%s\n' "$label" "$discovery_exit"
    printf '%s_LOOP_REPORT=%s\n' "$label" "$loop_report"

    cat "$loop_report"

    if [[ "$discovery_exit" -ne 0 ]]; then
        mark_fail "$label loop discovery failed"
        return 1
    fi

    python3 - \
        "$loop_report" \
        "$loop_map" \
        "$expected_harness_loops" <<'PY'
import re
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
map_path = Path(sys.argv[2])
expected_harness_loops = int(sys.argv[3])

text = report_path.read_text(
    encoding="utf-8",
    errors="replace",
)

loop_ids = re.findall(
    r"^Loop ([^:]+):$",
    text,
    flags=re.MULTILINE,
)

harness = sorted(
    item
    for item in loop_ids
    if item.startswith("harness.")
)

compressor = sorted(
    item
    for item in loop_ids
    if item.startswith("mlk_poly_compress_d4_c.")
)

decompressor = sorted(
    item
    for item in loop_ids
    if item.startswith("mlk_poly_decompress_d4_c.")
)

expected_production = {
    "mlk_poly_compress_d4_c.0",
    "mlk_poly_compress_d4_c.1",
    "mlk_poly_decompress_d4_c.0",
}

unexpected = [
    item
    for item in loop_ids
    if (
        not item.startswith("harness.")
        and item not in expected_production
    )
]

bounds = []

for loop_id in harness:
    bounds.append(
        (
            loop_id,
            257,
            "256-coefficient harness loop",
        )
    )

for loop_id in compressor:
    if loop_id.endswith(".0"):
        bounds.append(
            (
                loop_id,
                129,
                "portable-C compressor inner loop",
            )
        )
    elif loop_id.endswith(".1"):
        bounds.append(
            (
                loop_id,
                257,
                "portable-C compressor outer loop",
            )
        )

for loop_id in decompressor:
    bounds.append(
        (
            loop_id,
            129,
            "portable-C decompressor loop",
        )
    )

unwindset = ",".join(
    f"{loop_id}:{bound}"
    for loop_id, bound, _ in bounds
)

accepted = (
    len(harness) == expected_harness_loops
    and set(compressor) == {
        "mlk_poly_compress_d4_c.0",
        "mlk_poly_compress_d4_c.1",
    }
    and set(decompressor) == {
        "mlk_poly_decompress_d4_c.0",
    }
    and not unexpected
    and len(loop_ids) == expected_harness_loops + 3
)

lines = [
    f"TOTAL_LOOP_COUNT={len(loop_ids)}",
    f"HARNESS_LOOP_COUNT={len(harness)}",
    f"EXPECTED_HARNESS_LOOP_COUNT={expected_harness_loops}",
    f"COMPRESSOR_LOOP_COUNT={len(compressor)}",
    f"DECOMPRESSOR_LOOP_COUNT={len(decompressor)}",
    f"UNEXPECTED_LOOP_COUNT={len(unexpected)}",
]

for loop_id in loop_ids:
    lines.append(f"DISCOVERED_LOOP={loop_id}")

for loop_id, bound, reason in bounds:
    lines.append(
        f"LOOP_BOUND={loop_id}|{bound}|{reason}"
    )

lines.append(f"UNWINDSET={unwindset}")
lines.append(
    "LOOP_MAP_STATUS="
    + ("PASS" if accepted else "FAIL")
)

map_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(map_path.read_text(encoding="utf-8"), end="")

if not accepted:
    raise SystemExit(1)
PY

    local parse_exit=$?

    printf '%s_LOOP_PARSE_EXIT=%s\n' "$label" "$parse_exit"
    printf '%s_LOOP_MAP=%s\n' "$label" "$loop_map"

    if [[ "$parse_exit" -ne 0 ]]; then
        mark_fail "$label loop inventory mismatch"
        return 1
    fi

    CURRENT_UNWINDSET="$(
        sed -n 's/^UNWINDSET=//p' "$loop_map"
    )"

    printf '%s_UNWINDSET=%s\n' "$label" "$CURRENT_UNWINDSET"

    if [[ -z "$CURRENT_UNWINDSET" ]]; then
        mark_fail "$label unwindset is empty"
        return 1
    fi

    return 0
}

bind_properties()
{
    local goto_file="$1"
    local label="$2"
    shift 2
    local descriptions=("$@")

    local report="${STAGE_DIR}/${label}_PROPERTY_REPORT_${UTC_STAMP}.txt"

    cbmc \
        "$goto_file" \
        --show-properties \
        > "$report" 2>&1

    local property_exit=$?

    printf '%s_PROPERTY_REPORT_EXIT=%s\n' "$label" "$property_exit"
    printf '%s_PROPERTY_REPORT=%s\n' "$label" "$report"

    if [[ "$property_exit" -ne 0 ]]; then
        mark_fail "$label property report failed"
        return 1
    fi

    local description
    local count
    local index=0

    for description in "${descriptions[@]}"
    do
        count="$(
            grep -F -c "$description" "$report" ||
            true
        )"

        printf '%s_PROPERTY_%s_COUNT=%s\n' \
            "$label" "$index" "$count"

        if [[ "$count" != "1" ]]; then
            mark_fail "$label property $index was not bound exactly once"
        fi

        index=$((index + 1))
    done

    if [[ "$FAIL" -ne 0 ]]; then
        return 1
    fi

    printf '%s_PROPERTY_BINDING=PASS\n' "$label"
    return 0
}

parse_success()
{
    local json_file="$1"
    local summary_file="$2"
    shift 2
    local descriptions=("$@")

    python3 - \
        "$json_file" \
        "$summary_file" \
        "${descriptions[@]}" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
descriptions = sys.argv[3:]

payload = json.loads(
    json_path.read_text(encoding="utf-8")
)

entries = payload if isinstance(payload, list) else [payload]

results = []
statuses = []
errors = []

for entry in entries:
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

target_matches = {}

for description in descriptions:
    target_matches[description] = [
        item
        for item in results
        if str(item.get("description", "")) == description
    ]

targets_success = all(
    len(matches) == 1
    and matches[0].get("status") == "SUCCESS"
    for matches in target_matches.values()
)

all_success = (
    bool(results)
    and all(
        item.get("status") == "SUCCESS"
        for item in results
    )
)

cprover_success = (
    bool(statuses)
    and all(
        status.lower() == "success"
        for status in statuses
    )
)

accepted = (
    targets_success
    and all_success
    and cprover_success
    and not errors
)

lines = [
    "JSON_PARSE_STATUS=PASS",
    f"PROPERTY_RESULT_COUNT={len(results)}",
    "CPROVER_STATUSES="
    + (",".join(statuses) if statuses else "<MISSING>"),
    f"ERROR_MESSAGE_COUNT={len(errors)}",
]

for index, description in enumerate(descriptions):
    matches = target_matches[description]

    lines.append(
        f"TARGET_{index}_COUNT={len(matches)}"
    )

    if matches:
        lines.append(
            f"TARGET_{index}_RESULT="
            f"{matches[0].get('status', '')}|"
            f"{matches[0].get('property', '')}|"
            f"{description}"
        )

lines.extend(
    [
        "TARGET_PROPERTIES="
        + ("PASS" if targets_success else "FAIL"),
        "ALL_REPORTED_PROPERTIES="
        + ("PASS" if all_success else "FAIL"),
    ]
)

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")

if not accepted:
    raise SystemExit(1)
PY
}

run_semantic_and_strict()
{
    local goto_file="$1"
    local label="$2"
    local unwindset="$3"
    shift 3
    local descriptions=("$@")

    local semantic_json="${STAGE_DIR}/${label}_SEMANTIC_${UTC_STAMP}.json"
    local semantic_stderr="${STAGE_DIR}/${label}_SEMANTIC_STDERR_${UTC_STAMP}.txt"
    local semantic_summary="${STAGE_DIR}/${label}_SEMANTIC_SUMMARY_${UTC_STAMP}.txt"

    local strict_json="${STAGE_DIR}/${label}_STRICT_${UTC_STAMP}.json"
    local strict_stderr="${STAGE_DIR}/${label}_STRICT_STDERR_${UTC_STAMP}.txt"
    local strict_summary="${STAGE_DIR}/${label}_STRICT_SUMMARY_${UTC_STAMP}.txt"

    cbmc \
        "$goto_file" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$unwindset" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$semantic_json" \
        2> "$semantic_stderr"

    local semantic_exit=$?

    printf '%s_SEMANTIC_CBMC_EXIT=%s\n' "$label" "$semantic_exit"
    printf '%s_SEMANTIC_JSON=%s\n' "$label" "$semantic_json"
    printf '%s_SEMANTIC_JSON_SHA256=%s\n' "$label" "$(
        sha256sum "$semantic_json" |
        awk '{print $1}'
    )"

    cat "$semantic_stderr" 2>/dev/null || true

    parse_success \
        "$semantic_json" \
        "$semantic_summary" \
        "${descriptions[@]}"

    local semantic_parse_exit=$?

    printf '%s_SEMANTIC_PARSE_EXIT=%s\n' \
        "$label" "$semantic_parse_exit"

    if [[ "$semantic_exit" -ne 0 ||
          "$semantic_parse_exit" -ne 0 ]]
    then
        mark_fail "$label semantic verification failed"
        return 1
    fi

    printf '%s_SEMANTIC=PASS\n' "$label"

    cbmc \
        "$goto_file" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$unwindset" \
        --unwinding-assertions \
        --bounds-check \
        --pointer-check \
        --div-by-zero-check \
        --signed-overflow-check \
        --unsigned-overflow-check \
        --undefined-shift-check \
        --conversion-check \
        --pointer-overflow-check \
        --trace \
        --json-ui \
        > "$strict_json" \
        2> "$strict_stderr"

    local strict_exit=$?

    printf '%s_STRICT_CBMC_EXIT=%s\n' "$label" "$strict_exit"
    printf '%s_STRICT_JSON=%s\n' "$label" "$strict_json"
    printf '%s_STRICT_JSON_SHA256=%s\n' "$label" "$(
        sha256sum "$strict_json" |
        awk '{print $1}'
    )"

    cat "$strict_stderr" 2>/dev/null || true

    parse_success \
        "$strict_json" \
        "$strict_summary" \
        "${descriptions[@]}"

    local strict_parse_exit=$?

    printf '%s_STRICT_PARSE_EXIT=%s\n' \
        "$label" "$strict_parse_exit"

    if [[ "$strict_exit" -ne 0 ||
          "$strict_parse_exit" -ne 0 ]]
    then
        mark_fail "$label strict verification failed"
        return 1
    fi

    printf '%s_STRICT=PASS\n' "$label"

    return 0
}

main()
{
    section "POLYCOMP-D4-T4-00B — SHARP WITNESS, FIXED POINTS, IDEMPOTENCE AND LOCALITY"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "T4-00B.1 — POSITIVE ARTEFACT REBINDING"

    for required in \
        "$POSITIVE_HARNESS" \
        "$POSITIVE_MAKEFILE" \
        "$POSITIVE_GOTO"
    do
        if [[ ! -f "$required" ]]; then
            mark_fail "required positive artefact missing: $required"
        fi
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
        mark_fail "T4 production source is modified"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_BEFORE=CLEAN\n'
    fi

    POSITIVE_HARNESS_HASH="$(
        sha256sum "$POSITIVE_HARNESS" |
        awk '{print $1}'
    )"

    POSITIVE_MAKEFILE_HASH="$(
        sha256sum "$POSITIVE_MAKEFILE" |
        awk '{print $1}'
    )"

    POSITIVE_GOTO_HASH="$(
        sha256sum "$POSITIVE_GOTO" |
        awk '{print $1}'
    )"

    printf 'POSITIVE_HARNESS_SHA256=%s\n' "$POSITIVE_HARNESS_HASH"
    printf 'POSITIVE_MAKEFILE_SHA256=%s\n' "$POSITIVE_MAKEFILE_HASH"
    printf 'POSITIVE_GOTO_SHA256=%s\n' "$POSITIVE_GOTO_HASH"

    if [[ "$POSITIVE_HARNESS_HASH" != "$EXPECTED_POSITIVE_HARNESS_SHA256" ||
          "$POSITIVE_MAKEFILE_HASH" != "$EXPECTED_POSITIVE_MAKEFILE_SHA256" ||
          "$POSITIVE_GOTO_HASH" != "$EXPECTED_POSITIVE_GOTO_SHA256" ]]
    then
        mark_fail "positive T4 artefact hash mismatch"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 21
    fi

    printf 'T4_POSITIVE_ARTEFACT_REBINDING=PASS\n'

    section "T4-00B.2 — SHARP BOUND WITNESS"

    mkdir -p "$WITNESS_PROOF_DIR"

    cat > "$WITNESS_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T4 sharp modular-distortion witness.
 *
 * Every input coefficient is the concrete canonical value 104.
 * The real D4 projection maps each coefficient to zero, so the modular
 * distortion is exactly 104. This proves the verified upper bound is sharp.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input;
  uint8_t compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly projected;
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    input.coeffs[i] = 104;
  }

  mlk_poly_compress_d4_c(
      compressed,
      &input);

  mlk_poly_decompress_d4_c(
      &projected,
      compressed);

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        projected.coeffs[i] == 0 &&
        (int32_t)input.coeffs[i] -
            (int32_t)projected.coeffs[i] == 104,
        "POLYCOMP-D4-T4 sharpness: canonical witness 104 attains modular distortion exactly 104");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$WITNESS_PROOF_DIR" \
        "$WITNESS_PROOF_NAME" \
        "$WITNESS_HARNESS_NAME"

    printf 'WITNESS_HARNESS=%s\n' "$WITNESS_HARNESS"
    printf 'WITNESS_HARNESS_SHA256=%s\n' "$(
        sha256sum "$WITNESS_HARNESS" |
        awk '{print $1}'
    )"

    if [[ "$(
        grep -Ec '^[[:space:]]*mlk_poly_compress_d4_c[[:space:]]*\(' "$WITNESS_HARNESS" || true
    )" != "1" ||
          "$(
        grep -Ec '^[[:space:]]*mlk_poly_decompress_d4_c[[:space:]]*\(' "$WITNESS_HARNESS" || true
    )" != "1" ||
          "$(
        grep -Ec '^[[:space:]]*__CPROVER_assert[[:space:]]*\(' "$WITNESS_HARNESS" || true
    )" != "1" ||
          "$(
        grep -c '__CPROVER_assume' "$WITNESS_HARNESS" || true
    )" != "0" ]]
    then
        mark_fail "witness static firewall failed"
        return 30
    fi

    printf 'T4_WITNESS_STATIC_FIREWALL=PASS\n'

    build_goto \
        "$WITNESS_PROOF_NAME" \
        "$WITNESS_GOTO" \
        "T4_WITNESS" ||
        return 31

    derive_unwindset \
        "$WITNESS_GOTO" \
        "T4_WITNESS" \
        "2" ||
        return 32

    WITNESS_UNWINDSET="$CURRENT_UNWINDSET"

    bind_properties \
        "$WITNESS_GOTO" \
        "T4_WITNESS" \
        "POLYCOMP-D4-T4 sharpness: canonical witness 104 attains modular distortion exactly 104" ||
        return 33

    run_semantic_and_strict \
        "$WITNESS_GOTO" \
        "T4_WITNESS" \
        "$WITNESS_UNWINDSET" \
        "POLYCOMP-D4-T4 sharpness: canonical witness 104 attains modular distortion exactly 104" ||
        return 34

    printf 'T4_SHARP_BOUND_WITNESS=PASS\n'

    section "T4-00B.3 — FIXED-POINT CHARACTERIZATION"

    mkdir -p "$FIXED_PROOF_DIR"

    cat > "$FIXED_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T4 fixed-point characterization.
 *
 * For every canonical coefficient:
 *
 *   projection(a) == a
 *
 * if and only if a belongs to the exact D4 codebook.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void __CPROVER_assume(
    _Bool condition);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

static _Bool t4_is_codebook_value(
    int16_t value)
{
  return
      value == 0 ||
      value == 208 ||
      value == 416 ||
      value == 624 ||
      value == 832 ||
      value == 1040 ||
      value == 1248 ||
      value == 1456 ||
      value == 1665 ||
      value == 1873 ||
      value == 2081 ||
      value == 2289 ||
      value == 2497 ||
      value == 2705 ||
      value == 2913 ||
      value == 3121;
}

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input;
  uint8_t compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly projected;
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(
        input.coeffs[i] >= 0 &&
        input.coeffs[i] < MLKEM_Q);
  }

  mlk_poly_compress_d4_c(
      compressed,
      &input);

  mlk_poly_decompress_d4_c(
      &projected,
      compressed);

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        (projected.coeffs[i] == input.coeffs[i]) ==
            t4_is_codebook_value(input.coeffs[i]),
        "POLYCOMP-D4-T4 fixed points: a canonical coefficient is unchanged exactly when it is a D4 codebook value");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$FIXED_PROOF_DIR" \
        "$FIXED_PROOF_NAME" \
        "$FIXED_HARNESS_NAME"

    printf 'FIXED_HARNESS=%s\n' "$FIXED_HARNESS"
    printf 'FIXED_HARNESS_SHA256=%s\n' "$(
        sha256sum "$FIXED_HARNESS" |
        awk '{print $1}'
    )"

    if [[ "$(
        grep -Ec '^[[:space:]]*mlk_poly_compress_d4_c[[:space:]]*\(' "$FIXED_HARNESS" || true
    )" != "1" ||
          "$(
        grep -Ec '^[[:space:]]*mlk_poly_decompress_d4_c[[:space:]]*\(' "$FIXED_HARNESS" || true
    )" != "1" ||
          "$(
        grep -Ec '^[[:space:]]*__CPROVER_assert[[:space:]]*\(' "$FIXED_HARNESS" || true
    )" != "1" ||
          "$(
        grep -Ec '^[[:space:]]*__CPROVER_assume[[:space:]]*\(' "$FIXED_HARNESS" || true
    )" != "1" ]]
    then
        mark_fail "fixed-point static firewall failed"
        return 40
    fi

    printf 'T4_FIXED_POINT_STATIC_FIREWALL=PASS\n'

    build_goto \
        "$FIXED_PROOF_NAME" \
        "$FIXED_GOTO" \
        "T4_FIXED" ||
        return 41

    derive_unwindset \
        "$FIXED_GOTO" \
        "T4_FIXED" \
        "2" ||
        return 42

    FIXED_UNWINDSET="$CURRENT_UNWINDSET"

    bind_properties \
        "$FIXED_GOTO" \
        "T4_FIXED" \
        "POLYCOMP-D4-T4 fixed points: a canonical coefficient is unchanged exactly when it is a D4 codebook value" ||
        return 43

    run_semantic_and_strict \
        "$FIXED_GOTO" \
        "T4_FIXED" \
        "$FIXED_UNWINDSET" \
        "POLYCOMP-D4-T4 fixed points: a canonical coefficient is unchanged exactly when it is a D4 codebook value" ||
        return 44

    printf 'T4_FIXED_POINT_CHARACTERIZATION=PASS\n'

    section "T4-00B.4 — PROJECTION IDEMPOTENCE"

    mkdir -p "$IDEMP_PROOF_DIR"

    cat > "$IDEMP_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T4 projection idempotence.
 *
 * For every canonical polynomial:
 *
 *   Q(Q(A)) == Q(A),
 *
 * where Q is the real portable-C compress/decompress projection.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void __CPROVER_assume(
    _Bool condition);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input;
  uint8_t first_compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly first_projection;
  uint8_t second_compressed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly second_projection;
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(
        input.coeffs[i] >= 0 &&
        input.coeffs[i] < MLKEM_Q);
  }

  mlk_poly_compress_d4_c(
      first_compressed,
      &input);

  mlk_poly_decompress_d4_c(
      &first_projection,
      first_compressed);

  mlk_poly_compress_d4_c(
      second_compressed,
      &first_projection);

  mlk_poly_decompress_d4_c(
      &second_projection,
      second_compressed);

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assert(
        second_projection.coeffs[i] ==
            first_projection.coeffs[i],
        "POLYCOMP-D4-T4 idempotence: applying the real D4 projection twice equals applying it once");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$IDEMP_PROOF_DIR" \
        "$IDEMP_PROOF_NAME" \
        "$IDEMP_HARNESS_NAME"

    printf 'IDEMP_HARNESS=%s\n' "$IDEMP_HARNESS"
    printf 'IDEMP_HARNESS_SHA256=%s\n' "$(
        sha256sum "$IDEMP_HARNESS" |
        awk '{print $1}'
    )"

    if [[ "$(
        grep -Ec '^[[:space:]]*mlk_poly_compress_d4_c[[:space:]]*\(' "$IDEMP_HARNESS" || true
    )" != "2" ||
          "$(
        grep -Ec '^[[:space:]]*mlk_poly_decompress_d4_c[[:space:]]*\(' "$IDEMP_HARNESS" || true
    )" != "2" ||
          "$(
        grep -Ec '^[[:space:]]*__CPROVER_assert[[:space:]]*\(' "$IDEMP_HARNESS" || true
    )" != "1" ||
          "$(
        grep -Ec '^[[:space:]]*__CPROVER_assume[[:space:]]*\(' "$IDEMP_HARNESS" || true
    )" != "1" ]]
    then
        mark_fail "idempotence static firewall failed"
        return 50
    fi

    printf 'T4_IDEMPOTENCE_STATIC_FIREWALL=PASS\n'

    build_goto \
        "$IDEMP_PROOF_NAME" \
        "$IDEMP_GOTO" \
        "T4_IDEMP" ||
        return 51

    derive_unwindset \
        "$IDEMP_GOTO" \
        "T4_IDEMP" \
        "2" ||
        return 52

    IDEMP_UNWINDSET="$CURRENT_UNWINDSET"

    bind_properties \
        "$IDEMP_GOTO" \
        "T4_IDEMP" \
        "POLYCOMP-D4-T4 idempotence: applying the real D4 projection twice equals applying it once" ||
        return 53

    run_semantic_and_strict \
        "$IDEMP_GOTO" \
        "T4_IDEMP" \
        "$IDEMP_UNWINDSET" \
        "POLYCOMP-D4-T4 idempotence: applying the real D4 projection twice equals applying it once" ||
        return 54

    printf 'T4_PROJECTION_IDEMPOTENCE=PASS\n'

    section "T4-00B.5 — RELATIONAL COORDINATE LOCALITY"

    mkdir -p "$LOCALITY_PROOF_DIR"

    cat > "$LOCALITY_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T4 relational coordinate locality.
 *
 * For two canonical polynomials A and B and any valid coordinate k:
 *
 *   A[k] == B[k]  implies  Q(A)[k] == Q(B)[k].
 *
 * Both complete real portable-C projections are executed.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assert(
    _Bool condition,
    const char *description);

void __CPROVER_assume(
    _Bool condition);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void mlk_poly_decompress_d4_c(
    mlk_poly *r,
    const uint8_t a[MLKEM_POLYCOMPRESSEDBYTES_D4]);

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly input_a;
  mlk_poly input_b;
  uint8_t compressed_a[MLKEM_POLYCOMPRESSEDBYTES_D4];
  uint8_t compressed_b[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly projected_a;
  mlk_poly projected_b;
  unsigned i;
  unsigned k;

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(
        input_a.coeffs[i] >= 0 &&
        input_a.coeffs[i] < MLKEM_Q &&
        input_b.coeffs[i] >= 0 &&
        input_b.coeffs[i] < MLKEM_Q);
  }

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(
      input_a.coeffs[k] ==
      input_b.coeffs[k]);

  mlk_poly_compress_d4_c(
      compressed_a,
      &input_a);

  mlk_poly_decompress_d4_c(
      &projected_a,
      compressed_a);

  mlk_poly_compress_d4_c(
      compressed_b,
      &input_b);

  mlk_poly_decompress_d4_c(
      &projected_b,
      compressed_b);

  __CPROVER_assert(
      projected_a.coeffs[k] ==
          projected_b.coeffs[k],
      "POLYCOMP-D4-T4 locality: equal canonical input coefficients at one coordinate produce equal projected coefficients there");
#endif
}
HARNESS_EOF

    write_makefile \
        "$LOCALITY_PROOF_DIR" \
        "$LOCALITY_PROOF_NAME" \
        "$LOCALITY_HARNESS_NAME"

    printf 'LOCALITY_HARNESS=%s\n' "$LOCALITY_HARNESS"
    printf 'LOCALITY_HARNESS_SHA256=%s\n' "$(
        sha256sum "$LOCALITY_HARNESS" |
        awk '{print $1}'
    )"

    if [[ "$(
        grep -Ec '^[[:space:]]*mlk_poly_compress_d4_c[[:space:]]*\(' "$LOCALITY_HARNESS" || true
    )" != "2" ||
          "$(
        grep -Ec '^[[:space:]]*mlk_poly_decompress_d4_c[[:space:]]*\(' "$LOCALITY_HARNESS" || true
    )" != "2" ||
          "$(
        grep -Ec '^[[:space:]]*__CPROVER_assert[[:space:]]*\(' "$LOCALITY_HARNESS" || true
    )" != "1" ||
          "$(
        grep -Ec '^[[:space:]]*__CPROVER_assume[[:space:]]*\(' "$LOCALITY_HARNESS" || true
    )" != "3" ]]
    then
        mark_fail "locality static firewall failed"
        return 60
    fi

    printf 'T4_LOCALITY_STATIC_FIREWALL=PASS\n'

    build_goto \
        "$LOCALITY_PROOF_NAME" \
        "$LOCALITY_GOTO" \
        "T4_LOCALITY" ||
        return 61

    derive_unwindset \
        "$LOCALITY_GOTO" \
        "T4_LOCALITY" \
        "1" ||
        return 62

    LOCALITY_UNWINDSET="$CURRENT_UNWINDSET"

    bind_properties \
        "$LOCALITY_GOTO" \
        "T4_LOCALITY" \
        "POLYCOMP-D4-T4 locality: equal canonical input coefficients at one coordinate produce equal projected coefficients there" ||
        return 63

    run_semantic_and_strict \
        "$LOCALITY_GOTO" \
        "T4_LOCALITY" \
        "$LOCALITY_UNWINDSET" \
        "POLYCOMP-D4-T4 locality: equal canonical input coefficients at one coordinate produce equal projected coefficients there" ||
        return 64

    printf 'T4_COORDINATE_LOCALITY=PASS\n'

    section "T4-00B.6 — POST-RUN SOURCE IMMUTABILITY"

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
        mark_fail "T4 production source became dirty"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_AFTER=CLEAN\n'
    fi

    printf 'AUTHORITATIVE_HEAD_AFTER=%s\n' "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD
    )"

    printf 'WORK_REPO_HEAD_AFTER=%s\n' "$(
        git -C "$WORK_REPO" rev-parse HEAD
    )"

    section "POLYCOMP-D4-T4-00B VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_T4_00B_STATUS=PASS\n'
        printf 'T4_SHARP_BOUND_WITNESS=PASS\n'
        printf 'T4_FIXED_POINT_CHARACTERIZATION=PASS\n'
        printf 'T4_PROJECTION_IDEMPOTENCE=PASS\n'
        printf 'T4_COORDINATE_LOCALITY=PASS\n'
        printf 'T4_THEOREM_STATUS=ALL_REGISTERED_STRUCTURAL_OBLIGATIONS_CHECKED\n'
        printf 'NEXT_GATE=T4_COVERAGE_REACHABILITY_AND_MUTATION_DETECTION\n'
    else
        printf 'POLYCOMP_D4_T4_00B_STATUS=FAIL\n'
        printf 'T4_THEOREM_STATUS=NOT_FINAL\n'
        printf 'NEXT_GATE=CLASSIFY_EXACT_T4_WITNESS_FIXED_IDEMPOTENCE_OR_LOCALITY_FAILURE\n'
    fi

    printf 'WITNESS_HARNESS=%s\n' "$WITNESS_HARNESS"
    printf 'WITNESS_GOTO=%s\n' "$WITNESS_GOTO"
    printf 'FIXED_HARNESS=%s\n' "$FIXED_HARNESS"
    printf 'FIXED_GOTO=%s\n' "$FIXED_GOTO"
    printf 'IDEMP_HARNESS=%s\n' "$IDEMP_HARNESS"
    printf 'IDEMP_GOTO=%s\n' "$IDEMP_GOTO"
    printf 'LOCALITY_HARNESS=%s\n' "$LOCALITY_HARNESS"
    printf 'LOCALITY_GOTO=%s\n' "$LOCALITY_GOTO"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-T4-00B CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
