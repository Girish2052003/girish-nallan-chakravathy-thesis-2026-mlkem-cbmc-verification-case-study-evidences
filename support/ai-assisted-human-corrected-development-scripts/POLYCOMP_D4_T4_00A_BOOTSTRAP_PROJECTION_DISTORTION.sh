#!/usr/bin/env bash
set -uo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"
REGISTRY_SOURCE="${CAMPAIGN_ROOT}/POLYCOMP_D4_00B_MANIFEST_REGISTRY_T1_PREFLIGHT/POLYCOMP_D4_THEOREM_REGISTRY_V1_20260725T152707Z.txt"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t4_${UTC_STAMP}"
STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_T4_00A_BOOTSTRAP_PROJECTION_DISTORTION"

PROOF_NAME="polycomp_d4_t4_projection_distortion"
PROOF_DIR="${WORK_REPO}/proofs/cbmc/${PROOF_NAME}"
HARNESS_NAME="polycomp_d4_t4_projection_distortion_harness"
HARNESS_FILE="${PROOF_DIR}/${HARNESS_NAME}.c"
MAKEFILE="${PROOF_DIR}/Makefile"
GOTO_FILE="${PROOF_DIR}/gotos/${HARNESS_NAME}.goto"

SOURCE_CAPTURE="${STAGE_DIR}/T4_SOURCE_CAPTURE_${UTC_STAMP}.txt"
OVERLAP_CAPTURE="${STAGE_DIR}/T4_NATIVE_OVERLAP_CAPTURE_${UTC_STAMP}.txt"
FINITE_DERIVATION="${STAGE_DIR}/T4_FINITE_DERIVATION_${UTC_STAMP}.txt"
REGISTRY_EXTRACT="${STAGE_DIR}/T4_REGISTRY_EXTRACT_${UTC_STAMP}.txt"

RUNNER_LOG="${STAGE_DIR}/T4_RUNNER_${UTC_STAMP}.txt"
RUNNER_JSON="${STAGE_DIR}/T4_RUNNER_${UTC_STAMP}.json"

LOOP_REPORT="${STAGE_DIR}/T4_LOOP_REPORT_${UTC_STAMP}.txt"
LOOP_MAP="${STAGE_DIR}/T4_LOOP_MAP_${UTC_STAMP}.txt"
PROPERTY_REPORT="${STAGE_DIR}/T4_PROPERTY_REPORT_${UTC_STAMP}.txt"

SEMANTIC_JSON="${STAGE_DIR}/T4_SEMANTIC_RESULT_${UTC_STAMP}.json"
SEMANTIC_STDERR="${STAGE_DIR}/T4_SEMANTIC_STDERR_${UTC_STAMP}.txt"
SEMANTIC_SUMMARY="${STAGE_DIR}/T4_SEMANTIC_SUMMARY_${UTC_STAMP}.txt"

STRICT_JSON="${STAGE_DIR}/T4_STRICT_RESULT_${UTC_STAMP}.json"
STRICT_STDERR="${STAGE_DIR}/T4_STRICT_STDERR_${UTC_STAMP}.txt"
STRICT_SUMMARY="${STAGE_DIR}/T4_STRICT_SUMMARY_${UTC_STAMP}.txt"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_T4_00A_BOOTSTRAP_PROJECTION_DISTORTION_${UTC_STAMP}.txt"
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

descriptions = (
    "POLYCOMP-D4-T4: every projected coefficient belongs to the exact D4 codebook",
    "POLYCOMP-D4-T4: every canonical coefficient has modular projection distortion at most 104",
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

target_results = {}

for description in descriptions:
    target_results[description] = [
        item
        for item in results
        if str(item.get("description", "")) == description
    ]

target_success = all(
    len(matches) == 1
    and matches[0].get("status") == "SUCCESS"
    for matches in target_results.values()
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
]

for index, description in enumerate(descriptions):
    matches = target_results[description]

    lines.append(
        f"T4_TARGET_{index}_COUNT={len(matches)}"
    )

    if matches:
        lines.append(
            f"T4_TARGET_{index}_RESULT="
            f"{matches[0].get('status', '')}|"
            f"{matches[0].get('property', '')}|"
            f"{description}"
        )

lines.append(
    "T4_PROJECTION_AND_DISTORTION="
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
    section "POLYCOMP-D4-T4-00A — QUANTIZER PROJECTION AND DISTORTION BOOTSTRAP"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "T4-00A.1 — AUTHORITATIVE SOURCE BINDING"

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

    section "T4-00A.2 — FRESH ISOLATED WORK REPOSITORY"

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

    section "T4-00A.3 — EXACT SOURCE AND CONTRACT CAPTURE"

    {
        printf '=== PRODUCTION FUNCTION REFERENCES ===\n'

        grep -RIn \
            --exclude-dir=.git \
            -E 'mlk_poly_(compress|decompress)_d4(_c)?' \
            "$WORK_REPO/mlkem/src" \
            "$WORK_REPO/test" \
            "$WORK_REPO/proofs" \
            2>/dev/null ||
            true

        printf '\n=== COMPRESSOR CONTEXT ===\n'

        grep -n -B 18 -A 70 \
            'mlk_poly_compress_d4_c' \
            "$WORK_REPO/mlkem/src/compress.c" ||
            true

        printf '\n=== DECOMPRESSOR CONTEXT ===\n'

        grep -n -B 18 -A 55 \
            'mlk_poly_decompress_d4_c' \
            "$WORK_REPO/mlkem/src/compress.c" ||
            true

        printf '\n=== SCALAR D4 CONTEXT ===\n'

        grep -n -B 18 -A 45 \
            'mlk_scalar_compress_d4' \
            "$WORK_REPO/mlkem/src/compress.h" ||
            true

        grep -n -B 18 -A 35 \
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

    if ! grep -q 'mlk_scalar_compress_d4' "$SOURCE_CAPTURE"; then
        mark_fail "scalar compressor source capture is incomplete"
    fi

    if ! grep -q 'mlk_scalar_decompress_d4' "$SOURCE_CAPTURE"; then
        mark_fail "scalar decompressor source capture is incomplete"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 40
    fi

    printf 'T4_SOURCE_CAPTURE=PASS\n'

    section "T4-00A.4 — NATIVE PROOF AND TEST OVERLAP CAPTURE"

    {
        printf 'POLYCOMP-D4-T4 OVERLAP SEARCH\n'
        printf 'Search intent: projection, quantization error, distortion, codebook, fixed points and idempotence.\n\n'

        grep -RIn \
            --exclude-dir=.git \
            -E \
            'quantiz|distort|codebook|fixed.?point|idempoten|compress.*decompress|decompress.*compress|round.?trip' \
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

    section "T4-00A.5 — COMPLETE FINITE CANONICAL-DOMAIN DERIVATION"

    python3 - "$FINITE_DERIVATION" <<'PY'
import sys
from pathlib import Path

Q = 3329
D = 4

def compress4(u: int) -> int:
    return ((16 * u + (Q // 2)) // Q) % 16

def decompress4(v: int) -> int:
    return (Q * v + 8) // 16

def project(u: int) -> int:
    return decompress4(compress4(u))

def modular_distance(a: int, b: int) -> int:
    ordinary = abs(a - b)
    return min(ordinary, Q - ordinary)

codebook = [
    decompress4(v)
    for v in range(16)
]

maximum_distance = -1
maximum_witnesses = []
fixed_points = []
image_values = set()
idempotence_failures = []

for u in range(Q):
    projected = project(u)
    image_values.add(projected)

    distance = modular_distance(
        u,
        projected,
    )

    if distance > maximum_distance:
        maximum_distance = distance
        maximum_witnesses = [
            (u, projected, compress4(u), distance)
        ]
    elif distance == maximum_distance:
        maximum_witnesses.append(
            (u, projected, compress4(u), distance)
        )

    if projected == u:
        fixed_points.append(u)

    if project(projected) != projected:
        idempotence_failures.append(
            (u, projected, project(projected))
        )

image_ok = sorted(image_values) == codebook
fixed_iff_codebook = fixed_points == codebook
distortion_ok = maximum_distance == 104
idempotence_ok = not idempotence_failures

lines = [
    "POLYCOMP-D4-T4 FINITE CANONICAL-DOMAIN DERIVATION",
    "Q=3329",
    "D=4",
    "CANONICAL_DOMAIN=0..3328",
    "NIBBLE_DOMAIN=0..15",
    "COMPRESS4(u)=floor((16*u+1664)/3329) mod 16",
    "DECOMPRESS4(v)=floor((3329*v+8)/16)",
    "PROJECT4(u)=DECOMPRESS4(COMPRESS4(u))",
    "MODULAR_DISTANCE(a,b)=min(abs(a-b),3329-abs(a-b))",
    "CODEBOOK=" + ",".join(map(str, codebook)),
    "IMAGE_VALUES=" + ",".join(map(str, sorted(image_values))),
    "IMAGE_EQUALS_CODEBOOK="
    + ("PASS" if image_ok else "FAIL"),
    f"MAXIMUM_MODULAR_DISTORTION={maximum_distance}",
    "DISTORTION_BOUND_104="
    + ("PASS" if distortion_ok else "FAIL"),
    f"MAXIMUM_WITNESS_COUNT={len(maximum_witnesses)}",
]

for index, (
    original,
    projected,
    nibble,
    distance,
) in enumerate(maximum_witnesses):
    lines.append(
        f"MAXIMUM_WITNESS_{index}="
        f"INPUT={original}|"
        f"CODE={nibble}|"
        f"PROJECTED={projected}|"
        f"DISTANCE={distance}"
    )

lines.extend(
    [
        "FIXED_POINTS=" + ",".join(map(str, fixed_points)),
        "FIXED_POINTS_EQUAL_CODEBOOK="
        + ("PASS" if fixed_iff_codebook else "FAIL"),
        f"IDEMPOTENCE_FAILURE_COUNT={len(idempotence_failures)}",
        "IDEMPOTENCE="
        + ("PASS" if idempotence_ok else "FAIL"),
        "STATUS="
        + (
            "PASS"
            if (
                image_ok
                and distortion_ok
                and fixed_iff_codebook
                and idempotence_ok
            )
            else "FAIL"
        ),
    ]
)

Path(sys.argv[1]).write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(
    Path(sys.argv[1]).read_text(encoding="utf-8"),
    end="",
)

if not (
    image_ok
    and distortion_ok
    and fixed_iff_codebook
    and idempotence_ok
):
    raise SystemExit(1)
PY

    DERIVATION_EXIT=$?

    printf 'FINITE_DERIVATION_EXIT=%s\n' "$DERIVATION_EXIT"
    printf 'FINITE_DERIVATION=%s\n' "$FINITE_DERIVATION"
    printf 'FINITE_DERIVATION_SHA256=%s\n' "$(
        sha256sum "$FINITE_DERIVATION" |
        awk '{print $1}'
    )"

    if [[ "$DERIVATION_EXIT" -ne 0 ]]; then
        mark_fail "T4 finite canonical-domain derivation failed"
        return 50
    fi

    printf 'T4_FINITE_CANONICAL_DOMAIN_DERIVATION=PASS\n'

    section "T4-00A.6 — FROZEN THEOREM REGISTRY EXTRACTION"

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

        grep -n '^T4_' "$REGISTRY_SOURCE" ||
            true
    } > "$REGISTRY_EXTRACT"

    cat "$REGISTRY_EXTRACT"

    printf 'T4_REGISTRY_EXTRACT=%s\n' "$REGISTRY_EXTRACT"
    printf 'T4_REGISTRY_EXTRACT_SHA256=%s\n' "$(
        sha256sum "$REGISTRY_EXTRACT" |
        awk '{print $1}'
    )"

    if ! grep -q 'T4_ID=POLYCOMP-D4-T4' "$REGISTRY_EXTRACT"; then
        mark_fail "T4 theorem ID is absent from the frozen registry"
    fi

    if ! grep -Eiq \
        'quantiz|projection|distortion|codebook|fixed|idempoten|locality' \
        "$REGISTRY_EXTRACT"
    then
        mark_fail "T4 obligations are absent from the frozen registry"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 61
    fi

    printf 'T4_REGISTRY_BINDING=PASS\n'

    section "T4-00A.7 — CLEAN-ROOM PROJECTION/DISTORTION HARNESS"

    mkdir -p "$PROOF_DIR"

    cat > "$HARNESS_FILE" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T4 quantizer projection and distortion.
 *
 * Domain:
 *   every polynomial whose 256 coefficients satisfy
 *   0 <= coeff < 3329.
 *
 * Construction:
 *   projected = decompress_d4(compress_d4(input)).
 *
 * Claims:
 *   1. Every projected coefficient belongs to the exact 16-value D4 codebook.
 *   2. The modular distance from each input coefficient to its projection
 *      is at most 104.
 *
 * Both real portable-C production functions are called. No production source
 * is modified. The only assumptions define the frozen canonical domain.
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
    int32_t difference =
        (int32_t)input.coeffs[i] -
        (int32_t)projected.coeffs[i];

    int32_t modular_distance;

    if (difference < 0)
    {
      difference = -difference;
    }

    modular_distance = difference;

    if (modular_distance > MLKEM_Q / 2)
    {
      modular_distance =
          MLKEM_Q - modular_distance;
    }

    __CPROVER_assert(
        t4_is_codebook_value(
            projected.coeffs[i]),
        "POLYCOMP-D4-T4: every projected coefficient belongs to the exact D4 codebook");

    __CPROVER_assert(
        modular_distance <= 104,
        "POLYCOMP-D4-T4: every canonical coefficient has modular projection distortion at most 104");
  }
#endif
}
HARNESS_EOF

    cat > "$MAKEFILE" <<'MAKEFILE_EOF'
include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = polycomp_d4_t4_projection_distortion_harness
PROOF_UID = polycomp_d4_t4_projection_distortion

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

    ASSUME_SITE_COUNT="$(
        grep -Ec \
            '^[[:space:]]*__CPROVER_assume[[:space:]]*\(' \
            "$HARNESS_FILE" ||
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
    printf 'ASSUME_ACTUAL_SITE_COUNT=%s\n' "$ASSUME_SITE_COUNT"

    if [[ "$DECOMPRESS_CALL_COUNT" != "1" ]]; then
        mark_fail "T4 harness does not call the real decompressor exactly once"
    fi

    if [[ "$COMPRESS_CALL_COUNT" != "1" ]]; then
        mark_fail "T4 harness does not call the real compressor exactly once"
    fi

    if [[ "$ASSERT_SITE_COUNT" != "2" ]]; then
        mark_fail "T4 harness does not contain exactly two assertion sites"
    fi

    if [[ "$ASSUME_SITE_COUNT" != "1" ]]; then
        mark_fail "T4 harness does not contain exactly one canonical-domain assumption site"
    fi

    if grep -Eq \
        '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)[[:space:]]*\)' \
        "$HARNESS_FILE"
    then
        mark_fail "T4 harness contains assume(false)"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 70
    fi

    printf 'T4_POSITIVE_STATIC_FIREWALL=PASS\n'

    section "T4-00A.8 — GOTO BUILD"

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
        mark_fail "runner did not produce the T4 GOTO binary"
        return 80
    fi

    GOTO_HASH="$(
        sha256sum "$GOTO_FILE" |
        awk '{print $1}'
    )"

    printf 'GOTO_FILE=%s\n' "$GOTO_FILE"
    printf 'GOTO_SIZE=%s\n' "$(stat -c '%s' "$GOTO_FILE")"
    printf 'GOTO_SHA256=%s\n' "$GOTO_HASH"
    printf 'T4_GOTO_BUILD=PASS\n'

    section "T4-00A.9 — LOOP INVENTORY AND COMPLETE UNWINDSET"

    goto-instrument \
        --show-loops \
        "$GOTO_FILE" \
        > "$LOOP_REPORT" 2>&1

    LOOP_DISCOVERY_EXIT=$?

    printf 'LOOP_DISCOVERY_EXIT=%s\n' "$LOOP_DISCOVERY_EXIT"
    printf 'LOOP_REPORT=%s\n' "$LOOP_REPORT"

    cat "$LOOP_REPORT"

    if [[ "$LOOP_DISCOVERY_EXIT" -ne 0 ]]; then
        mark_fail "T4 loop discovery failed"
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

harness = sorted(
    loop_id
    for loop_id in loop_ids
    if loop_id.startswith("harness.")
)

compressor = sorted(
    loop_id
    for loop_id in loop_ids
    if loop_id.startswith("mlk_poly_compress_d4_c.")
)

decompressor = sorted(
    loop_id
    for loop_id in loop_ids
    if loop_id.startswith("mlk_poly_decompress_d4_c.")
)

expected = set(harness + compressor + decompressor)

unexpected = [
    loop_id
    for loop_id in loop_ids
    if loop_id not in expected
]

bounds = []

for loop_id in harness:
    bounds.append(
        (
            loop_id,
            257,
            "256-coefficient harness domain or assertion loop",
        )
    )

for loop_id in compressor:
    if loop_id.endswith(".0"):
        bounds.append(
            (
                loop_id,
                129,
                "portable-C compressor inner/packing loop",
            )
        )
    elif loop_id.endswith(".1"):
        bounds.append(
            (
                loop_id,
                257,
                "portable-C compressor coefficient/outer loop",
            )
        )

for loop_id in decompressor:
    bounds.append(
        (
            loop_id,
            129,
            "128-byte portable-C decompressor loop",
        )
    )

unwindset = ",".join(
    f"{loop_id}:{bound}"
    for loop_id, bound, _ in bounds
)

accepted = (
    len(loop_ids) == 5
    and len(harness) == 2
    and len(compressor) == 2
    and len(decompressor) == 1
    and not unexpected
    and {
        "mlk_poly_compress_d4_c.0",
        "mlk_poly_compress_d4_c.1",
        "mlk_poly_decompress_d4_c.0",
    }.issubset(set(loop_ids))
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
        mark_fail "unexpected T4 loop inventory"
        return 91
    fi

    UNWINDSET="$(
        sed -n 's/^UNWINDSET=//p' "$LOOP_MAP"
    )"

    printf 'CONSTRUCTED_UNWINDSET=%s\n' "$UNWINDSET"

    if [[ -z "$UNWINDSET" ]]; then
        mark_fail "constructed T4 unwindset is empty"
        return 92
    fi

    printf 'T4_LOOP_COMPLETENESS_PLAN=PASS\n'

    section "T4-00A.10 — PROPERTY BINDING"

    cbmc \
        "$GOTO_FILE" \
        --show-properties \
        > "$PROPERTY_REPORT" 2>&1

    PROPERTY_EXIT=$?

    printf 'PROPERTY_REPORT_EXIT=%s\n' "$PROPERTY_EXIT"
    printf 'PROPERTY_REPORT=%s\n' "$PROPERTY_REPORT"

    grep -n -B 5 -A 10 \
        'POLYCOMP-D4-T4:' \
        "$PROPERTY_REPORT" ||
        true

    CODEBOOK_PROPERTY_COUNT="$(
        grep -c \
            'POLYCOMP-D4-T4: every projected coefficient belongs to the exact D4 codebook' \
            "$PROPERTY_REPORT" ||
        true
    )"

    DISTORTION_PROPERTY_COUNT="$(
        grep -c \
            'POLYCOMP-D4-T4: every canonical coefficient has modular projection distortion at most 104' \
            "$PROPERTY_REPORT" ||
        true
    )"

    printf 'T4_CODEBOOK_PROPERTY_COUNT=%s\n' \
        "$CODEBOOK_PROPERTY_COUNT"

    printf 'T4_DISTORTION_PROPERTY_COUNT=%s\n' \
        "$DISTORTION_PROPERTY_COUNT"

    if [[ "$PROPERTY_EXIT" -ne 0 ]]; then
        mark_fail "T4 property report failed"
    fi

    if [[ "$CODEBOOK_PROPERTY_COUNT" != "1" ]]; then
        mark_fail "T4 codebook property was not bound exactly once"
    fi

    if [[ "$DISTORTION_PROPERTY_COUNT" != "1" ]]; then
        mark_fail "T4 distortion property was not bound exactly once"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 100
    fi

    printf 'T4_PROPERTY_BINDING=PASS\n'

    section "T4-00A.11 — DIRECT SEMANTIC PREFLIGHT"

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
        "yes"

    SEMANTIC_PARSE_EXIT=$?

    printf 'SEMANTIC_PARSE_EXIT=%s\n' "$SEMANTIC_PARSE_EXIT"
    printf 'SEMANTIC_SUMMARY=%s\n' "$SEMANTIC_SUMMARY"

    if [[ "$SEMANTIC_EXIT" -ne 0 ||
          "$SEMANTIC_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "T4 semantic preflight failed"
        return 110
    fi

    printf 'T4_SEMANTIC_UNWINDING_PREFLIGHT=PASS\n'

    section "T4-00A.12 — STRICT SAFETY PLUS SEMANTIC PREFLIGHT"

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
        mark_fail "T4 strict preflight failed"
        return 120
    fi

    printf 'T4_STRICT_SAFETY_SEMANTIC_PREFLIGHT=PASS\n'

    section "T4-00A.13 — POST-RUN SOURCE IMMUTABILITY"

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

    section "POLYCOMP-D4-T4-00A VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_T4_00A_STATUS=PASS\n'
        printf 'T4_SOURCE_CAPTURE=PASS\n'
        printf 'T4_FINITE_CANONICAL_DOMAIN_DERIVATION=PASS\n'
        printf 'T4_REGISTRY_BINDING=PASS\n'
        printf 'T4_POSITIVE_STATIC_FIREWALL=PASS\n'
        printf 'T4_GOTO_BUILD=PASS\n'
        printf 'T4_LOOP_COMPLETENESS_PLAN=PASS\n'
        printf 'T4_PROPERTY_BINDING=PASS\n'
        printf 'T4_CODEBOOK_PROJECTION=PASS\n'
        printf 'T4_MODULAR_DISTORTION_BOUND_104=PASS\n'
        printf 'T4_SEMANTIC_UNWINDING_PREFLIGHT=PASS\n'
        printf 'T4_STRICT_SAFETY_SEMANTIC_PREFLIGHT=PASS\n'
        printf 'T4_THEOREM_STATUS=PROJECTION_DISTORTION_PREFLIGHT_VERIFIED_NOT_FINAL\n'
        printf 'NEXT_GATE=T4_BOUND_WITNESS_FIXED_POINTS_IDEMPOTENCE_AND_LOCALITY\n'
    else
        printf 'POLYCOMP_D4_T4_00A_STATUS=FAIL\n'
        printf 'T4_THEOREM_STATUS=NOT_VERIFIED\n'
        printf 'NEXT_GATE=CLASSIFY_EXACT_T4_BUILD_LOOP_OR_CBMC_FAILURE\n'
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
printf 'FINAL POLYCOMP-D4-T4-00A CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
