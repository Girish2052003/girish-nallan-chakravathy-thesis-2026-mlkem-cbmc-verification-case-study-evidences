#!/usr/bin/env bash
set -uo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"
REGISTRY_SOURCE="${CAMPAIGN_ROOT}/POLYCOMP_D4_00B_MANIFEST_REGISTRY_T1_PREFLIGHT/POLYCOMP_D4_THEOREM_REGISTRY_V1_20260725T152707Z.txt"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t3_${UTC_STAMP}"
STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_T3_00A_BOOTSTRAP_POSITIVE"

PROOF_NAME="polycomp_d4_t3_compressed_domain_retraction"
PROOF_DIR="${WORK_REPO}/proofs/cbmc/${PROOF_NAME}"
HARNESS_NAME="polycomp_d4_t3_compressed_domain_retraction_harness"
HARNESS_FILE="${PROOF_DIR}/${HARNESS_NAME}.c"
MAKEFILE="${PROOF_DIR}/Makefile"
GOTO_FILE="${PROOF_DIR}/gotos/${HARNESS_NAME}.goto"

SOURCE_CAPTURE="${STAGE_DIR}/T3_SOURCE_CAPTURE_${UTC_STAMP}.txt"
OVERLAP_CAPTURE="${STAGE_DIR}/T3_NATIVE_OVERLAP_CAPTURE_${UTC_STAMP}.txt"
FINITE_DERIVATION="${STAGE_DIR}/T3_FINITE_DERIVATION_${UTC_STAMP}.txt"
REGISTRY_EXTRACT="${STAGE_DIR}/T3_REGISTRY_EXTRACT_${UTC_STAMP}.txt"

RUNNER_LOG="${STAGE_DIR}/T3_RUNNER_${UTC_STAMP}.txt"
RUNNER_JSON="${STAGE_DIR}/T3_RUNNER_${UTC_STAMP}.json"

LOOP_REPORT="${STAGE_DIR}/T3_LOOP_REPORT_${UTC_STAMP}.txt"
LOOP_MAP="${STAGE_DIR}/T3_LOOP_MAP_${UTC_STAMP}.txt"
PROPERTY_REPORT="${STAGE_DIR}/T3_PROPERTY_REPORT_${UTC_STAMP}.txt"

SEMANTIC_JSON="${STAGE_DIR}/T3_SEMANTIC_RESULT_${UTC_STAMP}.json"
SEMANTIC_STDERR="${STAGE_DIR}/T3_SEMANTIC_STDERR_${UTC_STAMP}.txt"
SEMANTIC_SUMMARY="${STAGE_DIR}/T3_SEMANTIC_SUMMARY_${UTC_STAMP}.txt"

STRICT_JSON="${STAGE_DIR}/T3_STRICT_RESULT_${UTC_STAMP}.json"
STRICT_STDERR="${STAGE_DIR}/T3_STRICT_STDERR_${UTC_STAMP}.txt"
STRICT_SUMMARY="${STAGE_DIR}/T3_STRICT_SUMMARY_${UTC_STAMP}.txt"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_T3_00A_BOOTSTRAP_POSITIVE_${UTC_STAMP}.txt"
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

classify_positive()
{
    local json_file="$1"
    local summary_file="$2"
    local require_all="$3"

    python3 - \
        "$json_file" \
        "$summary_file" \
        "$require_all" <<'PY'
import json
import sys
from pathlib import Path

json_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
require_all = sys.argv[3] == "yes"

description = (
    "POLYCOMP-D4-T3: compressing the real D4 decompression "
    "reconstructs every original input byte"
)

try:
    payload = json.loads(
        json_path.read_text(encoding="utf-8")
    )
except Exception as error:
    summary_path.write_text(
        "JSON_PARSE_STATUS=FAIL\n"
        f"JSON_PARSE_ERROR={type(error).__name__}: {error}\n",
        encoding="utf-8",
    )
    print(summary_path.read_text(encoding="utf-8"), end="")
    raise SystemExit(2)

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

target_results = [
    item
    for item in results
    if str(item.get("description", "")) == description
]

target_success = (
    len(target_results) == 1
    and target_results[0].get("status") == "SUCCESS"
)

cprover_success = (
    bool(statuses)
    and all(
        status.lower() == "success"
        for status in statuses
    )
)

all_success = (
    bool(results)
    and all(
        item.get("status") == "SUCCESS"
        for item in results
    )
)

accepted = (
    target_success
    and cprover_success
    and not errors
    and (all_success if require_all else True)
)

lines = [
    "JSON_PARSE_STATUS=PASS",
    f"PROPERTY_RESULT_COUNT={len(results)}",
    "CPROVER_STATUSES="
    + (",".join(statuses) if statuses else "<MISSING>"),
    f"ERROR_MESSAGE_COUNT={len(errors)}",
    f"T3_RETRACTION_RESULT_COUNT={len(target_results)}",
]

for index, item in enumerate(target_results):
    lines.append(
        f"T3_RETRACTION_RESULT_{index}="
        f"{item.get('status', '')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

lines.append(
    "T3_COMPRESSED_DOMAIN_RETRACTION="
    + ("PASS" if target_success else "FAIL")
)

if require_all:
    lines.append(
        "ALL_REPORTED_PROPERTIES="
        + ("PASS" if all_success else "FAIL")
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

main()
{
    section "POLYCOMP-D4-T3-00A — COMPRESSED-DOMAIN RETRACTION BOOTSTRAP"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "T3-00A.1 — AUTHORITATIVE SOURCE BINDING"

    if [[ ! -d "$AUTHORITATIVE_SOURCE_PATH" ]]; then
        mark_fail "authoritative source directory is missing"
        return 20
    fi

    AUTHORITATIVE_HEAD="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            rev-parse HEAD 2>/dev/null ||
        true
    )"

    printf 'AUTHORITATIVE_HEAD=%s\n' "$AUTHORITATIVE_HEAD"

    if [[ "$AUTHORITATIVE_HEAD" != "$EXPECTED_COMMIT" ]]; then
        mark_fail "authoritative source commit mismatch"
    fi

    AUTHORITATIVE_STATUS="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" \
            status --porcelain=v1 --untracked-files=all \
            2>/dev/null ||
        true
    )"

    if [[ -n "$AUTHORITATIVE_STATUS" ]]; then
        printf '%s\n' "$AUTHORITATIVE_STATUS"
        mark_fail "authoritative source is dirty"
    else
        printf 'AUTHORITATIVE_WORKTREE=CLEAN\n'
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 21
    fi

    printf 'AUTHORITATIVE_SOURCE_BINDING=PASS\n'

    section "T3-00A.2 — FRESH ISOLATED WORK REPOSITORY"

    git clone \
        --no-hardlinks \
        "$AUTHORITATIVE_SOURCE_PATH" \
        "$WORK_REPO"

    CLONE_EXIT=$?
    printf 'CLONE_EXIT=%s\n' "$CLONE_EXIT"

    if [[ "$CLONE_EXIT" -ne 0 ]]; then
        mark_fail "isolated repository clone failed"
        return 30
    fi

    git -C "$WORK_REPO" \
        checkout --detach "$EXPECTED_COMMIT"

    CHECKOUT_EXIT=$?
    printf 'CHECKOUT_EXIT=%s\n' "$CHECKOUT_EXIT"

    WORK_HEAD="$(
        git -C "$WORK_REPO" rev-parse HEAD
    )"

    printf 'WORK_REPO_HEAD=%s\n' "$WORK_HEAD"

    if [[ "$CHECKOUT_EXIT" -ne 0 ||
          "$WORK_HEAD" != "$EXPECTED_COMMIT" ]]
    then
        mark_fail "isolated repository binding failed"
        return 31
    fi

    printf 'ISOLATED_WORK_REPOSITORY=PASS\n'

    section "T3-00A.3 — EXACT SOURCE AND CONTRACT CAPTURE"

    {
        printf '=== COMPRESSOR AND DECOMPRESSOR REFERENCES ===\n'
        grep -RIn \
            --exclude-dir=.git \
            -E 'mlk_poly_(compress|decompress)_d4(_c)?' \
            "$WORK_REPO/mlkem/src" \
            "$WORK_REPO/test" \
            "$WORK_REPO/proofs" \
            2>/dev/null ||
            true

        printf '\n=== COMPRESS.C D4 CONTEXT ===\n'
        grep -n -B 18 -A 65 \
            'mlk_poly_compress_d4_c' \
            "$WORK_REPO/mlkem/src/compress.c" ||
            true

        grep -n -B 18 -A 55 \
            'mlk_poly_decompress_d4_c' \
            "$WORK_REPO/mlkem/src/compress.c" ||
            true

        printf '\n=== COMPRESS.H SCALAR CONTEXT ===\n'
        grep -n -B 14 -A 38 \
            'mlk_scalar_compress_d4' \
            "$WORK_REPO/mlkem/src/compress.h" ||
            true

        grep -n -B 14 -A 30 \
            'mlk_scalar_decompress_d4' \
            "$WORK_REPO/mlkem/src/compress.h" ||
            true

        printf '\n=== PARAMETER DEFINITIONS ===\n'
        grep -n \
            -E '#define MLKEM_(N|Q|POLYCOMPRESSEDBYTES_D4)' \
            "$WORK_REPO/mlkem/src/params.h" ||
            true
    } > "$SOURCE_CAPTURE"

    printf 'SOURCE_CAPTURE=%s\n' "$SOURCE_CAPTURE"
    printf 'SOURCE_CAPTURE_SHA256=%s\n' "$(
        sha256sum "$SOURCE_CAPTURE" |
        awk '{print $1}'
    )"

    if ! grep -q 'mlk_poly_compress_d4_c' "$SOURCE_CAPTURE"; then
        mark_fail "compressor source capture is incomplete"
    fi

    if ! grep -q 'mlk_poly_decompress_d4_c' "$SOURCE_CAPTURE"; then
        mark_fail "decompressor source capture is incomplete"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 40
    fi

    printf 'T3_SOURCE_CAPTURE=PASS\n'

    section "T3-00A.4 — NATIVE PROOF AND TEST OVERLAP CAPTURE"

    {
        printf 'POLYCOMP-D4-T3 OVERLAP SEARCH\n'
        printf 'Search intent: compressed-domain round trip, retraction, or compress-after-decompress identity.\n\n'

        grep -RIn \
            --exclude-dir=.git \
            -E \
            'compress.*decompress|decompress.*compress|round.?trip|retract|reconstruct.*byte|ByteEncode.*ByteDecode' \
            "$WORK_REPO/proofs" \
            "$WORK_REPO/test" \
            2>/dev/null ||
            true
    } > "$OVERLAP_CAPTURE"

    OVERLAP_MATCH_COUNT="$(
        grep -Ec \
            '^[^[:space:]].*:[0-9]+:' \
            "$OVERLAP_CAPTURE" ||
        true
    )"

    printf 'NATIVE_OVERLAP_MATCH_COUNT=%s\n' \
        "$OVERLAP_MATCH_COUNT"

    printf 'NATIVE_OVERLAP_CAPTURE=%s\n' \
        "$OVERLAP_CAPTURE"

    printf 'NATIVE_OVERLAP_CAPTURE_SHA256=%s\n' "$(
        sha256sum "$OVERLAP_CAPTURE" |
        awk '{print $1}'
    )"

    printf 'NATIVE_OVERLAP_CAPTURE=PASS\n'

    section "T3-00A.5 — FROZEN FINITE-DOMAIN DERIVATION"

    python3 - "$FINITE_DERIVATION" <<'PY'
import sys
from pathlib import Path

Q = 3329

def decompress4(v: int) -> int:
    return (Q * v + 8) // 16

def compress4(u: int) -> int:
    return ((16 * u + (Q // 2)) // Q) % 16

codebook = [decompress4(v) for v in range(16)]

scalar_rows = []
scalar_ok = True

for v in range(16):
    recovered = compress4(decompress4(v))
    scalar_rows.append((v, decompress4(v), recovered))

    if recovered != v:
        scalar_ok = False

byte_failures = []

for byte in range(256):
    low = byte & 0x0F
    high = byte >> 4

    recovered_low = compress4(decompress4(low))
    recovered_high = compress4(decompress4(high))

    reconstructed = recovered_low | (recovered_high << 4)

    if reconstructed != byte:
        byte_failures.append(
            (byte, reconstructed)
        )

lines = [
    "POLYCOMP-D4-T3 FINITE-DOMAIN DERIVATION",
    "Q=3329",
    "D=4",
    "BYTE_DOMAIN=0..255",
    "NIBBLE_DOMAIN=0..15",
    "DECOMPRESS4(v)=floor((3329*v+8)/16)",
    "COMPRESS4(u)=floor((16*u+1664)/3329) mod 16",
    "CODEBOOK=" + ",".join(map(str, codebook)),
]

for v, decompressed, recovered in scalar_rows:
    lines.append(
        f"NIBBLE={v}|DECOMPRESSED={decompressed}|"
        f"RECOMPRESSED={recovered}"
    )

lines.extend(
    [
        "SCALAR_RETRACTION="
        + ("PASS" if scalar_ok else "FAIL"),
        f"BYTE_RETRACTION_FAILURE_COUNT={len(byte_failures)}",
        "ALL_256_PACKED_BYTES_RECONSTRUCT="
        + ("PASS" if not byte_failures else "FAIL"),
        "STATUS="
        + (
            "PASS"
            if scalar_ok and not byte_failures
            else "FAIL"
        ),
    ]
)

Path(sys.argv[1]).write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(Path(sys.argv[1]).read_text(encoding="utf-8"), end="")

if not scalar_ok or byte_failures:
    raise SystemExit(1)
PY

    DERIVATION_EXIT=$?

    printf 'FINITE_DERIVATION_EXIT=%s\n' \
        "$DERIVATION_EXIT"

    printf 'FINITE_DERIVATION=%s\n' \
        "$FINITE_DERIVATION"

    printf 'FINITE_DERIVATION_SHA256=%s\n' "$(
        sha256sum "$FINITE_DERIVATION" |
        awk '{print $1}'
    )"

    if [[ "$DERIVATION_EXIT" -ne 0 ]]; then
        mark_fail "T3 finite-domain derivation failed"
        return 50
    fi

    printf 'T3_FINITE_DOMAIN_DERIVATION=PASS\n'

    section "T3-00A.6 — FROZEN THEOREM REGISTRY EXTRACTION"

    if [[ ! -f "$REGISTRY_SOURCE" ]]; then
        mark_fail "frozen theorem registry is missing"
        return 60
    fi

    {
        printf 'REGISTRY_SOURCE=%s\n' "$REGISTRY_SOURCE"
        printf 'REGISTRY_SOURCE_SHA256=%s\n' "$(
            sha256sum "$REGISTRY_SOURCE" |
            awk '{print $1}'
        )"

        grep -n '^T3_' "$REGISTRY_SOURCE" ||
            true
    } > "$REGISTRY_EXTRACT"

    cat "$REGISTRY_EXTRACT"

    printf 'T3_REGISTRY_EXTRACT=%s\n' "$REGISTRY_EXTRACT"
    printf 'T3_REGISTRY_EXTRACT_SHA256=%s\n' "$(
        sha256sum "$REGISTRY_EXTRACT" |
        awk '{print $1}'
    )"

    if ! grep -q 'T3_ID=POLYCOMP-D4-T3' "$REGISTRY_EXTRACT"; then
        mark_fail "T3 theorem ID is absent from the frozen registry"
    fi

    if ! grep -Eiq \
        'retraction|compress.*decompress|decompress.*compress' \
        "$REGISTRY_EXTRACT"
    then
        mark_fail "T3 retraction claim is absent from the frozen registry"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 61
    fi

    printf 'T3_REGISTRY_BINDING=PASS\n'

    section "T3-00A.7 — CLEAN-ROOM POSITIVE HARNESS CREATION"

    mkdir -p "$PROOF_DIR"

    cat > "$HARNESS_FILE" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T3 compressed-domain retraction.
 *
 * Domain: every possible 128-byte array.
 *
 * Claim:
 *   mlk_poly_compress_d4_c(
 *       mlk_poly_decompress_d4_c(input))
 *   reconstructs input byte-for-byte.
 *
 * The harness calls both real portable-C production functions and contains
 * no assumptions. The intermediate polynomial and output byte array are
 * uninitialized before the calls.
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
  uint8_t input[MLKEM_POLYCOMPRESSEDBYTES_D4];
  mlk_poly intermediate;
  uint8_t reconstructed[MLKEM_POLYCOMPRESSEDBYTES_D4];
  unsigned i;

  mlk_poly_decompress_d4_c(
      &intermediate,
      input);

  mlk_poly_compress_d4_c(
      reconstructed,
      &intermediate);

  for (i = 0;
       i < MLKEM_POLYCOMPRESSEDBYTES_D4;
       i++)
  {
    __CPROVER_assert(
        reconstructed[i] == input[i],
        "POLYCOMP-D4-T3: compressing the real D4 decompression reconstructs every original input byte");
  }
#endif
}
HARNESS_EOF

    cat > "$MAKEFILE" <<'MAKEFILE_EOF'
include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = polycomp_d4_t3_compressed_domain_retraction_harness
PROOF_UID = polycomp_d4_t3_compressed_domain_retraction

DEFINES +=
INCLUDES +=
REMOVE_FUNCTION_BODY +=

CHECK_FUNCTION_CONTRACTS =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/compress.c

UNWINDSET +=
CBMCFLAGS = --smt2
EXTERNAL_SAT_SOLVER =

FUNCTION_NAME = mlk_poly_compress_d4_c
CBMC_OBJECT_BITS = 8

include ../Makefile.common
MAKEFILE_EOF

    HARNESS_HASH="$(
        sha256sum "$HARNESS_FILE" |
        awk '{print $1}'
    )"

    MAKEFILE_HASH="$(
        sha256sum "$MAKEFILE" |
        awk '{print $1}'
    )"

    DECOMPRESS_CALL_COUNT="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_decompress_d4_c[[:space:]]*\(' \
            "$HARNESS_FILE" ||
        true
    )"

    COMPRESS_CALL_COUNT="$(
        grep -Ec \
            '^[[:space:]]*mlk_poly_compress_d4_c[[:space:]]*\(' \
            "$HARNESS_FILE" ||
        true
    )"

    ASSERT_SITE_COUNT="$(
        grep -Ec \
            '^[[:space:]]*__CPROVER_assert[[:space:]]*\(' \
            "$HARNESS_FILE" ||
        true
    )"

    ASSUME_COUNT="$(
        grep -c '__CPROVER_assume' "$HARNESS_FILE" ||
        true
    )"

    printf 'PROOF_NAME=%s\n' "$PROOF_NAME"
    printf 'PROOF_DIR=%s\n' "$PROOF_DIR"
    printf 'HARNESS_FILE=%s\n' "$HARNESS_FILE"
    printf 'MAKEFILE=%s\n' "$MAKEFILE"
    printf 'HARNESS_SHA256=%s\n' "$HARNESS_HASH"
    printf 'MAKEFILE_SHA256=%s\n' "$MAKEFILE_HASH"
    printf 'DECOMPRESS_ACTUAL_CALL_COUNT=%s\n' "$DECOMPRESS_CALL_COUNT"
    printf 'COMPRESS_ACTUAL_CALL_COUNT=%s\n' "$COMPRESS_CALL_COUNT"
    printf 'ASSERT_ACTUAL_SITE_COUNT=%s\n' "$ASSERT_SITE_COUNT"
    printf 'ASSUME_COUNT=%s\n' "$ASSUME_COUNT"

    if [[ "$DECOMPRESS_CALL_COUNT" != "1" ]]; then
        mark_fail "T3 harness does not call the real decompressor exactly once"
    fi

    if [[ "$COMPRESS_CALL_COUNT" != "1" ]]; then
        mark_fail "T3 harness does not call the real compressor exactly once"
    fi

    if [[ "$ASSERT_SITE_COUNT" != "1" ]]; then
        mark_fail "T3 harness does not contain exactly one actual assertion site"
    fi

    if [[ "$ASSUME_COUNT" != "0" ]]; then
        mark_fail "T3 positive harness unexpectedly contains assumptions"
    fi

    if grep -Eq \
        '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)[[:space:]]*\)' \
        "$HARNESS_FILE"
    then
        mark_fail "T3 positive harness contains assume(false)"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 70
    fi

    printf 'T3_POSITIVE_STATIC_FIREWALL=PASS\n'

    section "T3-00A.8 — GOTO BUILD"

    (
        cd "$WORK_REPO/proofs/cbmc" || exit 80

        MLKEM_K=3 \
        ./run-cbmc-proofs.py \
            --summarize \
            -j1 \
            -p "$PROOF_NAME" \
            --output-result-json "$RUNNER_JSON"
    ) > "$RUNNER_LOG" 2>&1

    RUNNER_EXIT=$?

    printf 'RUNNER_EXIT=%s\n' "$RUNNER_EXIT"
    printf 'RUNNER_LOG=%s\n' "$RUNNER_LOG"
    printf 'RUNNER_JSON=%s\n' "$RUNNER_JSON"
    printf 'RUNNER_EXIT_IS_NOT_DECISIVE_WHEN_GOTO_EXISTS=YES\n'

    tail -n 140 "$RUNNER_LOG" 2>/dev/null || true

    if [[ ! -f "$GOTO_FILE" ]]; then
        mark_fail "runner did not produce the T3 GOTO binary"
        return 80
    fi

    GOTO_HASH="$(
        sha256sum "$GOTO_FILE" |
        awk '{print $1}'
    )"

    printf 'GOTO_FILE=%s\n' "$GOTO_FILE"
    printf 'GOTO_SIZE=%s\n' "$(stat -c '%s' "$GOTO_FILE")"
    printf 'GOTO_SHA256=%s\n' "$GOTO_HASH"
    printf 'T3_GOTO_BUILD=PASS\n'

    section "T3-00A.9 — LOOP INVENTORY AND COMPLETE UNWINDSET"

    goto-instrument \
        --show-loops \
        "$GOTO_FILE" \
        > "$LOOP_REPORT" 2>&1

    LOOP_DISCOVERY_EXIT=$?

    printf 'LOOP_DISCOVERY_EXIT=%s\n' "$LOOP_DISCOVERY_EXIT"
    printf 'LOOP_REPORT=%s\n' "$LOOP_REPORT"

    cat "$LOOP_REPORT"

    if [[ "$LOOP_DISCOVERY_EXIT" -ne 0 ]]; then
        mark_fail "T3 loop discovery failed"
        return 90
    fi

    python3 - \
        "$LOOP_REPORT" \
        "$LOOP_MAP" <<'PY'
import re
import sys
from pathlib import Path

report_path = Path(sys.argv[1])
map_path = Path(sys.argv[2])

text = report_path.read_text(
    encoding="utf-8",
    errors="replace",
)

loop_ids = re.findall(
    r"^Loop ([^:]+):$",
    text,
    flags=re.MULTILINE,
)

harness = [
    loop_id
    for loop_id in loop_ids
    if loop_id.startswith("harness.")
]

compressor = [
    loop_id
    for loop_id in loop_ids
    if loop_id.startswith("mlk_poly_compress_d4_c.")
]

decompressor = [
    loop_id
    for loop_id in loop_ids
    if loop_id.startswith("mlk_poly_decompress_d4_c.")
]

expected = set(harness + compressor + decompressor)
unexpected = [
    loop_id
    for loop_id in loop_ids
    if loop_id not in expected
]

bounds = []

for loop_id in harness:
    bounds.append(
        (loop_id, 129, "128-byte harness comparison loop")
    )

for loop_id in compressor:
    bounds.append(
        (loop_id, 129, "128-byte portable-C compressor loop")
    )

for loop_id in decompressor:
    bounds.append(
        (loop_id, 129, "128-byte portable-C decompressor loop")
    )

unwindset = ",".join(
    f"{loop_id}:{bound}"
    for loop_id, bound, _ in bounds
)

accepted = (
    len(loop_ids) == 3
    and len(harness) == 1
    and len(compressor) == 1
    and len(decompressor) == 1
    and not unexpected
)

lines = [
    f"TOTAL_LOOP_COUNT={len(loop_ids)}",
    f"HARNESS_LOOP_COUNT={len(harness)}",
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

    LOOP_PARSE_EXIT=$?

    printf 'LOOP_PARSE_EXIT=%s\n' "$LOOP_PARSE_EXIT"
    printf 'LOOP_MAP=%s\n' "$LOOP_MAP"

    if [[ "$LOOP_PARSE_EXIT" -ne 0 ]]; then
        mark_fail "unexpected T3 loop inventory"
        return 91
    fi

    UNWINDSET="$(
        sed -n 's/^UNWINDSET=//p' "$LOOP_MAP"
    )"

    printf 'CONSTRUCTED_UNWINDSET=%s\n' "$UNWINDSET"

    if [[ -z "$UNWINDSET" ]]; then
        mark_fail "constructed T3 unwindset is empty"
        return 92
    fi

    printf 'T3_LOOP_COMPLETENESS_PLAN=PASS\n'

    section "T3-00A.10 — PROPERTY BINDING"

    cbmc \
        "$GOTO_FILE" \
        --show-properties \
        > "$PROPERTY_REPORT" 2>&1

    PROPERTY_EXIT=$?

    printf 'PROPERTY_REPORT_EXIT=%s\n' "$PROPERTY_EXIT"
    printf 'PROPERTY_REPORT=%s\n' "$PROPERTY_REPORT"

    grep -n -B 5 -A 10 \
        'POLYCOMP-D4-T3:' \
        "$PROPERTY_REPORT" ||
        true

    T3_PROPERTY_COUNT="$(
        grep -c \
            'POLYCOMP-D4-T3: compressing the real D4 decompression reconstructs every original input byte' \
            "$PROPERTY_REPORT" ||
        true
    )"

    printf 'T3_RETRACTION_PROPERTY_COUNT=%s\n' "$T3_PROPERTY_COUNT"

    if [[ "$PROPERTY_EXIT" -ne 0 ]]; then
        mark_fail "T3 property report failed"
    fi

    if [[ "$T3_PROPERTY_COUNT" != "1" ]]; then
        mark_fail "T3 retraction property was not bound exactly once"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 100
    fi

    printf 'T3_PROPERTY_BINDING=PASS\n'

    section "T3-00A.11 — DIRECT SEMANTIC PREFLIGHT"

    cbmc \
        "$GOTO_FILE" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$SEMANTIC_JSON" \
        2> "$SEMANTIC_STDERR"

    SEMANTIC_EXIT=$?

    printf 'SEMANTIC_CBMC_EXIT=%s\n' "$SEMANTIC_EXIT"
    printf 'SEMANTIC_JSON=%s\n' "$SEMANTIC_JSON"
    printf 'SEMANTIC_STDERR=%s\n' "$SEMANTIC_STDERR"
    printf 'SEMANTIC_JSON_SHA256=%s\n' "$(
        sha256sum "$SEMANTIC_JSON" |
        awk '{print $1}'
    )"

    cat "$SEMANTIC_STDERR" 2>/dev/null || true

    classify_positive \
        "$SEMANTIC_JSON" \
        "$SEMANTIC_SUMMARY" \
        "no"

    SEMANTIC_PARSE_EXIT=$?

    printf 'SEMANTIC_PARSE_EXIT=%s\n' "$SEMANTIC_PARSE_EXIT"
    printf 'SEMANTIC_SUMMARY=%s\n' "$SEMANTIC_SUMMARY"

    if [[ "$SEMANTIC_EXIT" -ne 0 ||
          "$SEMANTIC_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "T3 semantic preflight failed"
        return 110
    fi

    printf 'T3_SEMANTIC_UNWINDING_PREFLIGHT=PASS\n'

    section "T3-00A.12 — STRICT SAFETY PLUS SEMANTIC PREFLIGHT"

    cbmc \
        "$GOTO_FILE" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$UNWINDSET" \
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
        > "$STRICT_JSON" \
        2> "$STRICT_STDERR"

    STRICT_EXIT=$?

    printf 'STRICT_CBMC_EXIT=%s\n' "$STRICT_EXIT"
    printf 'STRICT_JSON=%s\n' "$STRICT_JSON"
    printf 'STRICT_STDERR=%s\n' "$STRICT_STDERR"
    printf 'STRICT_JSON_SHA256=%s\n' "$(
        sha256sum "$STRICT_JSON" |
        awk '{print $1}'
    )"

    cat "$STRICT_STDERR" 2>/dev/null || true

    classify_positive \
        "$STRICT_JSON" \
        "$STRICT_SUMMARY" \
        "yes"

    STRICT_PARSE_EXIT=$?

    printf 'STRICT_PARSE_EXIT=%s\n' "$STRICT_PARSE_EXIT"
    printf 'STRICT_SUMMARY=%s\n' "$STRICT_SUMMARY"

    if [[ "$STRICT_EXIT" -ne 0 ||
          "$STRICT_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "T3 strict preflight failed"
        return 120
    fi

    printf 'T3_STRICT_SAFETY_SEMANTIC_PREFLIGHT=PASS\n'

    section "T3-00A.13 — POST-RUN SOURCE IMMUTABILITY"

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
        mark_fail "T3 production source became dirty"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_AFTER=CLEAN\n'
    fi

    printf 'AUTHORITATIVE_HEAD_AFTER=%s\n' "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD
    )"

    printf 'WORK_REPO_HEAD_AFTER=%s\n' "$(
        git -C "$WORK_REPO" rev-parse HEAD
    )"

    section "POLYCOMP-D4-T3-00A VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_T3_00A_STATUS=PASS\n'
        printf 'T3_SOURCE_CAPTURE=PASS\n'
        printf 'T3_FINITE_DOMAIN_DERIVATION=PASS\n'
        printf 'T3_REGISTRY_BINDING=PASS\n'
        printf 'T3_POSITIVE_STATIC_FIREWALL=PASS\n'
        printf 'T3_GOTO_BUILD=PASS\n'
        printf 'T3_LOOP_COMPLETENESS_PLAN=PASS\n'
        printf 'T3_PROPERTY_BINDING=PASS\n'
        printf 'T3_SEMANTIC_UNWINDING_PREFLIGHT=PASS\n'
        printf 'T3_STRICT_SAFETY_SEMANTIC_PREFLIGHT=PASS\n'
        printf 'T3_THEOREM_STATUS=POSITIVE_PREFLIGHT_VERIFIED_NOT_FINAL\n'
        printf 'NEXT_GATE=T3_COVERAGE_REACHABILITY_AND_ONE_SIDED_MUTATIONS\n'
    else
        printf 'POLYCOMP_D4_T3_00A_STATUS=FAIL\n'
        printf 'T3_THEOREM_STATUS=NOT_VERIFIED\n'
        printf 'NEXT_GATE=CLASSIFY_EXACT_T3_BUILD_OR_CBMC_FAILURE\n'
    fi

    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'HARNESS_FILE=%s\n' "$HARNESS_FILE"
    printf 'HARNESS_SHA256=%s\n' "$HARNESS_HASH"
    printf 'MAKEFILE=%s\n' "$MAKEFILE"
    printf 'MAKEFILE_SHA256=%s\n' "$MAKEFILE_HASH"
    printf 'GOTO_FILE=%s\n' "$GOTO_FILE"
    printf 'GOTO_SHA256=%s\n' "$GOTO_HASH"
    printf 'UNWINDSET=%s\n' "$UNWINDSET"
    printf 'SOURCE_CAPTURE=%s\n' "$SOURCE_CAPTURE"
    printf 'OVERLAP_CAPTURE=%s\n' "$OVERLAP_CAPTURE"
    printf 'FINITE_DERIVATION=%s\n' "$FINITE_DERIVATION"
    printf 'REGISTRY_EXTRACT=%s\n' "$REGISTRY_EXTRACT"
    printf 'SEMANTIC_JSON=%s\n' "$SEMANTIC_JSON"
    printf 'STRICT_JSON=%s\n' "$STRICT_JSON"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-T3-00A CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
