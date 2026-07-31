#!/usr/bin/env bash
set -uo pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

AUTHORITATIVE_SOURCE_PATH="${HOME}/THESIS-2026/mlkem-native_af4c5abd"
WORK_REPO="${HOME}/THESIS-2026/_cbmc_work/mlkem-native_polycomp_d4_t1_20260725T152707Z"

POSITIVE_PROOF_DIR="${WORK_REPO}/proofs/cbmc/polycomp_d4_t1_packed_refinement"
POSITIVE_HARNESS="${POSITIVE_PROOF_DIR}/polycomp_d4_t1_packed_refinement_harness.c"
POSITIVE_GOTO="${POSITIVE_PROOF_DIR}/gotos/polycomp_d4_t1_packed_refinement_harness.goto"

EXPECTED_HARNESS_SHA256="90deb2c5942fe71af658552a608efa3179715d267396c25be6e0fb469637e21d"
EXPECTED_GOTO_SHA256="cebb58e934cdff4c717bcef0273a937d22f4a4c08f1ace957da81ac25f3800b7"

POSITIVE_UNWINDSET="harness.0:257,harness.1:257,mlk_poly_compress_d4_c.0:33,mlk_poly_compress_d4_c.1:33"
RELATIONAL_UNWINDSET="harness.0:257,mlk_poly_compress_d4_c.0:33,mlk_poly_compress_d4_c.1:33"

CAMPAIGN_ROOT="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom"
STAGE_DIR="${CAMPAIGN_ROOT}/POLYCOMP_D4_00G_T1_RELATIONAL_PACKING"

UTC_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

CAPTURE_FILE="${STAGE_DIR}/POLYCOMP_D4_00G_T1_RELATIONAL_PACKING_${UTC_STAMP}.txt"
CAPTURE_HASH_FILE="${CAPTURE_FILE}.sha256"

REL_PROOF_NAME="polycomp_d4_t1_relational_nibble_locality_${UTC_STAMP}"
REL_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${REL_PROOF_NAME}"
REL_HARNESS_NAME="polycomp_d4_t1_relational_nibble_locality_harness"
REL_HARNESS="${REL_PROOF_DIR}/${REL_HARNESS_NAME}.c"
REL_MAKEFILE="${REL_PROOF_DIR}/Makefile"
REL_GOTO="${REL_PROOF_DIR}/gotos/${REL_HARNESS_NAME}.goto"
REL_RUNNER_LOG="${STAGE_DIR}/RELATIONAL_RUNNER_${UTC_STAMP}.txt"
REL_RUNNER_JSON="${STAGE_DIR}/RELATIONAL_RUNNER_${UTC_STAMP}.json"
REL_LOOPS="${STAGE_DIR}/RELATIONAL_LOOPS_${UTC_STAMP}.txt"
REL_PROPERTIES="${STAGE_DIR}/RELATIONAL_PROPERTIES_${UTC_STAMP}.txt"

REL_SEM_JSON="${STAGE_DIR}/RELATIONAL_SEMANTIC_${UTC_STAMP}.json"
REL_SEM_STDERR="${STAGE_DIR}/RELATIONAL_SEMANTIC_STDERR_${UTC_STAMP}.txt"
REL_SEM_SUMMARY="${STAGE_DIR}/RELATIONAL_SEMANTIC_SUMMARY_${UTC_STAMP}.txt"

REL_STRICT_JSON="${STAGE_DIR}/RELATIONAL_STRICT_${UTC_STAMP}.json"
REL_STRICT_STDERR="${STAGE_DIR}/RELATIONAL_STRICT_STDERR_${UTC_STAMP}.txt"
REL_STRICT_SUMMARY="${STAGE_DIR}/RELATIONAL_STRICT_SUMMARY_${UTC_STAMP}.txt"

REL_REACH_GOTO="${STAGE_DIR}/RELATIONAL_END_REACHABILITY_${UTC_STAMP}.goto"
REL_REACH_JSON="${STAGE_DIR}/RELATIONAL_END_REACHABILITY_${UTC_STAMP}.json"
REL_REACH_STDERR="${STAGE_DIR}/RELATIONAL_END_REACHABILITY_STDERR_${UTC_STAMP}.txt"
REL_REACH_SUMMARY="${STAGE_DIR}/RELATIONAL_END_REACHABILITY_SUMMARY_${UTC_STAMP}.txt"

SWAP_PROOF_NAME="polycomp_d4_t1_mutation_swap_nibbles_${UTC_STAMP}"
SWAP_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${SWAP_PROOF_NAME}"
SWAP_HARNESS_NAME="polycomp_d4_t1_mutation_swap_nibbles_harness"
SWAP_HARNESS="${SWAP_PROOF_DIR}/${SWAP_HARNESS_NAME}.c"
SWAP_GOTO="${SWAP_PROOF_DIR}/gotos/${SWAP_HARNESS_NAME}.goto"
SWAP_RUNNER_LOG="${STAGE_DIR}/SWAP_RUNNER_${UTC_STAMP}.txt"
SWAP_RUNNER_JSON="${STAGE_DIR}/SWAP_RUNNER_${UTC_STAMP}.json"
SWAP_LOOPS="${STAGE_DIR}/SWAP_LOOPS_${UTC_STAMP}.txt"
SWAP_JSON="${STAGE_DIR}/SWAP_MUTATION_RESULT_${UTC_STAMP}.json"
SWAP_STDERR="${STAGE_DIR}/SWAP_MUTATION_STDERR_${UTC_STAMP}.txt"
SWAP_SUMMARY="${STAGE_DIR}/SWAP_MUTATION_SUMMARY_${UTC_STAMP}.txt"

ROUND_PROOF_NAME="polycomp_d4_t1_mutation_rounding_minus_one_${UTC_STAMP}"
ROUND_PROOF_DIR="${WORK_REPO}/proofs/cbmc/${ROUND_PROOF_NAME}"
ROUND_HARNESS_NAME="polycomp_d4_t1_mutation_rounding_minus_one_harness"
ROUND_HARNESS="${ROUND_PROOF_DIR}/${ROUND_HARNESS_NAME}.c"
ROUND_GOTO="${ROUND_PROOF_DIR}/gotos/${ROUND_HARNESS_NAME}.goto"
ROUND_RUNNER_LOG="${STAGE_DIR}/ROUND_RUNNER_${UTC_STAMP}.txt"
ROUND_RUNNER_JSON="${STAGE_DIR}/ROUND_RUNNER_${UTC_STAMP}.json"
ROUND_LOOPS="${STAGE_DIR}/ROUND_LOOPS_${UTC_STAMP}.txt"
ROUND_JSON="${STAGE_DIR}/ROUND_MUTATION_RESULT_${UTC_STAMP}.json"
ROUND_STDERR="${STAGE_DIR}/ROUND_MUTATION_STDERR_${UTC_STAMP}.txt"
ROUND_SUMMARY="${STAGE_DIR}/ROUND_MUTATION_SUMMARY_${UTC_STAMP}.txt"

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
    local expected_goto="$2"
    local runner_log="$3"
    local runner_json="$4"

    (
        cd "$WORK_REPO/proofs/cbmc" || exit 70

        MLKEM_K=3 \
        ./run-cbmc-proofs.py \
            --summarize \
            -j1 \
            -p "$proof_name" \
            --output-result-json "$runner_json"
    ) > "$runner_log" 2>&1

    local runner_exit=$?

    printf 'RUNNER_PROOF=%s\n' "$proof_name"
    printf 'RUNNER_EXIT=%s\n' "$runner_exit"
    printf 'RUNNER_LOG=%s\n' "$runner_log"
    printf 'RUNNER_JSON=%s\n' "$runner_json"
    printf '%s\n' \
        'RUNNER_NONZERO_IS_NOT_DECISIVE_DURING_GOTO_CREATION=YES'

    tail -n 90 "$runner_log" 2>/dev/null || true

    if [[ ! -f "$expected_goto" ]]; then
        mark_fail "runner did not produce GOTO for $proof_name"
        return 1
    fi

    printf 'GOTO_FILE=%s\n' "$expected_goto"
    printf 'GOTO_SIZE=%s\n' \
        "$(stat -c '%s' "$expected_goto" 2>/dev/null || printf unknown)"
    printf 'GOTO_SHA256=%s\n' \
        "$(sha256sum "$expected_goto" | awk '{print $1}')"

    return 0
}

check_loops()
{
    local goto_file="$1"
    local report_file="$2"
    local expected_total="$3"
    local expected_harness="$4"

    goto-instrument \
        --show-loops \
        "$goto_file" \
        > "$report_file" 2>&1

    local loop_exit=$?

    printf 'LOOP_DISCOVERY_EXIT=%s\n' "$loop_exit"
    printf 'LOOP_REPORT=%s\n' "$report_file"

    cat "$report_file"

    if [[ "$loop_exit" -ne 0 ]]; then
        mark_fail "loop discovery failed"
        return 1
    fi

    local total
    local harness_count
    local compressor_count

    total="$(grep -c '^Loop ' "$report_file" || true)"
    harness_count="$(grep -c '^Loop harness\.' "$report_file" || true)"
    compressor_count="$(
        grep -c '^Loop mlk_poly_compress_d4_c\.' "$report_file" ||
        true
    )"

    printf 'TOTAL_LOOP_COUNT=%s\n' "$total"
    printf 'HARNESS_LOOP_COUNT=%s\n' "$harness_count"
    printf 'COMPRESSOR_LOOP_COUNT=%s\n' "$compressor_count"

    if [[ "$total" != "$expected_total" ||
          "$harness_count" != "$expected_harness" ||
          "$compressor_count" != "2" ]]
    then
        mark_fail "unexpected loop inventory"
        return 1
    fi

    printf 'LOOP_INVENTORY=PASS\n'
    return 0
}

classify_relational_success()
{
    local result_json="$1"
    local summary_file="$2"
    local require_all_success="$3"

    python3 - \
        "$result_json" \
        "$summary_file" \
        "$require_all_success" <<'PY'
import json
import sys
from collections import Counter
from pathlib import Path

result_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
require_all_success = sys.argv[3] == "yes"

try:
    payload = json.loads(result_path.read_text(encoding="utf-8"))
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

for entry in entries:
    if not isinstance(entry, dict):
        continue

    if "cProverStatus" in entry:
        statuses.append(str(entry["cProverStatus"]))

    result = entry.get("result")

    if isinstance(result, list):
        results.extend(
            item for item in result
            if isinstance(item, dict)
        )

counts = Counter(
    str(item.get("status", "UNKNOWN"))
    for item in results
)

relation = {
    str(item.get("property", "")): item
    for item in results
    if str(item.get("property", ""))
    in {"harness.assertion.1", "harness.assertion.2"}
}

relation_ok = (
    len(relation) == 2
    and all(
        item.get("status") == "SUCCESS"
        for item in relation.values()
    )
)

all_ok = (
    bool(results)
    and all(
        item.get("status") == "SUCCESS"
        for item in results
    )
)

lines = [
    "JSON_PARSE_STATUS=PASS",
    f"PROPERTY_RESULT_COUNT={len(results)}",
    "CPROVER_STATUSES="
    + (",".join(statuses) if statuses else "<NOT_EXTRACTED>"),
]

for status, count in sorted(counts.items()):
    lines.append(f"STATUS_{status}={count}")

for property_id in (
    "harness.assertion.1",
    "harness.assertion.2",
):
    item = relation.get(property_id)

    if item is None:
        lines.append(f"{property_id}=MISSING")
    else:
        lines.append(
            f"{property_id}="
            f"{item.get('status', '')}|"
            f"{item.get('description', '')}"
        )

lines.append(
    "RELATIONAL_NIBBLE_LOCALITY="
    + ("PASS" if relation_ok else "FAIL")
)

if require_all_success:
    lines.append(
        "ALL_REPORTED_PROPERTIES="
        + ("PASS" if all_ok else "FAIL")
    )

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")

accepted = relation_ok and (
    all_ok if require_all_success else True
)

if not accepted:
    raise SystemExit(1)
PY
}

run_expected_mutation_failure()
{
    local label="$1"
    local goto_file="$2"
    local result_json="$3"
    local stderr_file="$4"
    local summary_file="$5"

    cbmc \
        "$goto_file" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$POSITIVE_UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$result_json" \
        2> "$stderr_file"

    local cbmc_exit=$?

    printf '%s_CBMC_EXIT=%s\n' "$label" "$cbmc_exit"
    printf '%s_JSON=%s\n' "$label" "$result_json"
    printf '%s_JSON_SHA256=%s\n' \
        "$label" \
        "$(sha256sum "$result_json" | awk '{print $1}')"

    cat "$stderr_file" 2>/dev/null || true

    python3 - \
        "$result_json" \
        "$summary_file" \
        "$label" <<'PY'
import json
import sys
from pathlib import Path

result_path = Path(sys.argv[1])
summary_path = Path(sys.argv[2])
label = sys.argv[3]

try:
    payload = json.loads(result_path.read_text(encoding="utf-8"))
except Exception as error:
    summary_path.write_text(
        "MUTATION_PARSE_STATUS=FAIL\n"
        f"MUTATION_PARSE_ERROR={type(error).__name__}: {error}\n",
        encoding="utf-8",
    )
    print(summary_path.read_text(encoding="utf-8"), end="")
    raise SystemExit(2)

entries = payload if isinstance(payload, list) else [payload]
results = []
statuses = []

for entry in entries:
    if not isinstance(entry, dict):
        continue

    if "cProverStatus" in entry:
        statuses.append(str(entry["cProverStatus"]))

    result = entry.get("result")

    if isinstance(result, list):
        results.extend(
            item for item in result
            if isinstance(item, dict)
        )

semantic = [
    item for item in results
    if str(item.get("property", "")) == "harness.assertion.1"
]

production = [
    item for item in results
    if str(item.get("property", ""))
    == "mlk_poly_compress_d4_c.assertion.1"
]

semantic_failure = (
    len(semantic) == 1
    and semantic[0].get("status") == "FAILURE"
)

production_success = (
    not production
    or all(
        item.get("status") == "SUCCESS"
        for item in production
    )
)

lines = [
    "MUTATION_PARSE_STATUS=PASS",
    f"MUTATION_LABEL={label}",
    "CPROVER_STATUSES="
    + (",".join(statuses) if statuses else "<NOT_EXTRACTED>"),
    f"PROPERTY_RESULT_COUNT={len(results)}",
    f"SEMANTIC_RESULT_COUNT={len(semantic)}",
]

for index, item in enumerate(semantic):
    lines.append(
        f"SEMANTIC_RESULT_{index}="
        f"{item.get('status', '')}|"
        f"{item.get('property', '')}|"
        f"{item.get('description', '')}"
    )

lines.append(
    f"{label}_DETECTED="
    + (
        "PASS"
        if semantic_failure and production_success
        else "FAIL"
    )
)

summary_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(summary_path.read_text(encoding="utf-8"), end="")

if not (semantic_failure and production_success):
    raise SystemExit(1)
PY

    local parse_exit=$?

    printf '%s_PARSE_EXIT=%s\n' "$label" "$parse_exit"
    printf '%s_SUMMARY=%s\n' "$label" "$summary_file"

    tail -n 100 "$result_json" 2>/dev/null || true

    if [[ "$cbmc_exit" -eq 0 ]]; then
        mark_fail "$label unexpectedly verified"
    fi

    if [[ "$parse_exit" -ne 0 ]]; then
        mark_fail "$label was not detected at the semantic property"
    fi

    return "$parse_exit"
}

main()
{
    section "POLYCOMP-D4-00G — T1 RELATIONAL LOCALITY AND PACKING MUTATIONS"

    printf 'UTC_TIME=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'EXPECTED_COMMIT=%s\n' "$EXPECTED_COMMIT"
    printf 'AUTHORITATIVE_SOURCE_PATH=%s\n' "$AUTHORITATIVE_SOURCE_PATH"
    printf 'WORK_REPO=%s\n' "$WORK_REPO"
    printf 'POSITIVE_HARNESS=%s\n' "$POSITIVE_HARNESS"
    printf 'POSITIVE_GOTO=%s\n' "$POSITIVE_GOTO"
    printf 'STAGE_DIR=%s\n' "$STAGE_DIR"

    section "00G.1 — POSITIVE ARTEFACT AND SOURCE REBINDING"

    if [[ ! -f "$POSITIVE_HARNESS" ||
          ! -f "$POSITIVE_GOTO" ]]
    then
        mark_fail "positive harness or GOTO is missing"
        return 20
    fi

    AUTH_HEAD="$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD 2>/dev/null ||
        true
    )"

    WORK_HEAD="$(
        git -C "$WORK_REPO" rev-parse HEAD 2>/dev/null ||
        true
    )"

    printf 'AUTHORITATIVE_HEAD=%s\n' "$AUTH_HEAD"
    printf 'WORK_REPO_HEAD=%s\n' "$WORK_HEAD"

    if [[ "$AUTH_HEAD" != "$EXPECTED_COMMIT" ||
          "$WORK_HEAD" != "$EXPECTED_COMMIT" ]]
    then
        mark_fail "commit binding differs"
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
        mark_fail "work production source is modified"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_BEFORE=CLEAN\n'
    fi

    HARNESS_HASH="$(sha256sum "$POSITIVE_HARNESS" | awk '{print $1}')"
    GOTO_HASH="$(sha256sum "$POSITIVE_GOTO" | awk '{print $1}')"

    printf 'POSITIVE_HARNESS_SHA256=%s\n' "$HARNESS_HASH"
    printf 'POSITIVE_GOTO_SHA256=%s\n' "$GOTO_HASH"

    if [[ "$HARNESS_HASH" != "$EXPECTED_HARNESS_SHA256" ||
          "$GOTO_HASH" != "$EXPECTED_GOTO_SHA256" ]]
    then
        mark_fail "positive artefact hash mismatch"
    fi

    if [[ "$FAIL" -ne 0 ]]; then
        return 21
    fi

    printf 'POSITIVE_ARTEFACT_REBINDING=PASS\n'

    section "00G.2 — RELATIONAL NIBBLE-LOCALITY HARNESS"

    mkdir -p "$REL_PROOF_DIR"

    cat > "$REL_HARNESS" <<'HARNESS_EOF'
/*
 * POLYCOMP-D4-T1 relational nibble locality.
 *
 * If two canonical input polynomials agree at one symbolic coefficient k,
 * then the corresponding packed output nibble must be equal.
 */

#include <stdint.h>

#include "compress.h"

void __CPROVER_assume(_Bool condition);
void __CPROVER_assert(_Bool condition, const char *description);

void mlk_poly_compress_d4_c(
    uint8_t r[MLKEM_POLYCOMPRESSEDBYTES_D4],
    const mlk_poly *a);

void harness(void)
{
#if MLKEM_K != 4
  mlk_poly left_input;
  mlk_poly right_input;

  uint8_t left_output[MLKEM_POLYCOMPRESSEDBYTES_D4];
  uint8_t right_output[MLKEM_POLYCOMPRESSEDBYTES_D4];

  unsigned i;
  unsigned k;
  unsigned byte_index;

  for (i = 0; i < MLKEM_N; i++)
  {
    __CPROVER_assume(left_input.coeffs[i] >= 0);
    __CPROVER_assume(left_input.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(right_input.coeffs[i] >= 0);
    __CPROVER_assume(right_input.coeffs[i] < MLKEM_Q);
  }

  __CPROVER_assume(k < MLKEM_N);
  __CPROVER_assume(
      left_input.coeffs[k] == right_input.coeffs[k]);

  mlk_poly_compress_d4_c(left_output, &left_input);
  mlk_poly_compress_d4_c(right_output, &right_input);

  byte_index = k / 2u;

  if ((k & 1u) == 0u)
  {
    __CPROVER_assert(
        (left_output[byte_index] & (uint8_t)0x0Fu) ==
            (right_output[byte_index] & (uint8_t)0x0Fu),
        "POLYCOMP-D4-T1 locality: equal even coefficient gives equal low nibble");
  }
  else
  {
    __CPROVER_assert(
        (left_output[byte_index] & (uint8_t)0xF0u) ==
            (right_output[byte_index] & (uint8_t)0xF0u),
        "POLYCOMP-D4-T1 locality: equal odd coefficient gives equal high nibble");
  }
#endif
}
HARNESS_EOF

    write_makefile \
        "$REL_PROOF_DIR" \
        "$REL_PROOF_NAME" \
        "$REL_HARNESS_NAME"

    printf 'RELATIONAL_HARNESS=%s\n' "$REL_HARNESS"
    printf 'RELATIONAL_HARNESS_SHA256=%s\n' \
        "$(sha256sum "$REL_HARNESS" | awk '{print $1}')"
    printf 'RELATIONAL_MAKEFILE_SHA256=%s\n' \
        "$(sha256sum "$REL_MAKEFILE" | awk '{print $1}')"

    printf 'RELATIONAL_TARGET_CALL_COUNT=%s\n' "$(
        grep -c 'mlk_poly_compress_d4_c(' "$REL_HARNESS" |
        awk '{print $1 - 1}'
    )"

    if grep -Eq \
        '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)[[:space:]]*\)' \
        "$REL_HARNESS"
    then
        mark_fail "relational harness contains assume(false)"
        return 30
    fi

    printf 'RELATIONAL_STATIC_FIREWALL=PASS\n'

    section "00G.3 — RELATIONAL GOTO BUILD AND LOOP BINDING"

    build_goto \
        "$REL_PROOF_NAME" \
        "$REL_GOTO" \
        "$REL_RUNNER_LOG" \
        "$REL_RUNNER_JSON" ||
        return 31

    check_loops \
        "$REL_GOTO" \
        "$REL_LOOPS" \
        "3" \
        "1" ||
        return 32

    cbmc "$REL_GOTO" --show-properties > "$REL_PROPERTIES" 2>&1

    REL_PROPERTY_EXIT=$?

    printf 'RELATIONAL_PROPERTY_REPORT_EXIT=%s\n' \
        "$REL_PROPERTY_EXIT"
    printf 'RELATIONAL_PROPERTIES=%s\n' "$REL_PROPERTIES"

    grep -n -B 4 -A 8 \
        'POLYCOMP-D4-T1 locality' \
        "$REL_PROPERTIES" ||
        true

    if [[ "$REL_PROPERTY_EXIT" -ne 0 ||
          "$(grep -c 'POLYCOMP-D4-T1 locality' "$REL_PROPERTIES" || true)" != "2" ]]
    then
        mark_fail "two relational locality properties were not bound"
        return 33
    fi

    printf 'RELATIONAL_PROPERTY_BINDING=PASS\n'

    section "00G.4 — RELATIONAL SEMANTIC PROOF"

    cbmc \
        "$REL_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$RELATIONAL_UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$REL_SEM_JSON" \
        2> "$REL_SEM_STDERR"

    REL_SEM_EXIT=$?

    printf 'RELATIONAL_SEMANTIC_CBMC_EXIT=%s\n' "$REL_SEM_EXIT"
    printf 'RELATIONAL_SEMANTIC_JSON_SHA256=%s\n' \
        "$(sha256sum "$REL_SEM_JSON" | awk '{print $1}')"

    cat "$REL_SEM_STDERR" 2>/dev/null || true

    classify_relational_success \
        "$REL_SEM_JSON" \
        "$REL_SEM_SUMMARY" \
        "no"

    REL_SEM_PARSE_EXIT=$?

    printf 'RELATIONAL_SEMANTIC_PARSE_EXIT=%s\n' \
        "$REL_SEM_PARSE_EXIT"

    if [[ "$REL_SEM_EXIT" -ne 0 ||
          "$REL_SEM_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "relational semantic proof did not verify"
        return 40
    fi

    printf 'T1_RELATIONAL_NIBBLE_LOCALITY_SEMANTIC=PASS\n'

    section "00G.5 — RELATIONAL STRICT PROOF"

    cbmc \
        "$REL_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$RELATIONAL_UNWINDSET" \
        --unwinding-assertions \
        --bounds-check \
        --pointer-check \
        --div-by-zero-check \
        --signed-overflow-check \
        --undefined-shift-check \
        --conversion-check \
        --pointer-overflow-check \
        --trace \
        --json-ui \
        > "$REL_STRICT_JSON" \
        2> "$REL_STRICT_STDERR"

    REL_STRICT_EXIT=$?

    printf 'RELATIONAL_STRICT_CBMC_EXIT=%s\n' "$REL_STRICT_EXIT"
    printf 'RELATIONAL_STRICT_JSON_SHA256=%s\n' \
        "$(sha256sum "$REL_STRICT_JSON" | awk '{print $1}')"

    cat "$REL_STRICT_STDERR" 2>/dev/null || true

    classify_relational_success \
        "$REL_STRICT_JSON" \
        "$REL_STRICT_SUMMARY" \
        "yes"

    REL_STRICT_PARSE_EXIT=$?

    printf 'RELATIONAL_STRICT_PARSE_EXIT=%s\n' \
        "$REL_STRICT_PARSE_EXIT"

    if [[ "$REL_STRICT_EXIT" -ne 0 ||
          "$REL_STRICT_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "relational strict proof did not verify"
        return 41
    fi

    printf 'T1_RELATIONAL_NIBBLE_LOCALITY_STRICT=PASS\n'

    section "00G.6 — RELATIONAL END REACHABILITY"

    goto-instrument \
        --insert-final-assert-false harness \
        "$REL_GOTO" \
        "$REL_REACH_GOTO" \
        > "${STAGE_DIR}/REL_REACH_INSTRUMENT_STDOUT_${UTC_STAMP}.txt" \
        2> "${STAGE_DIR}/REL_REACH_INSTRUMENT_STDERR_${UTC_STAMP}.txt"

    if [[ "$?" -ne 0 || ! -f "$REL_REACH_GOTO" ]]; then
        mark_fail "could not build relational reachability mutant"
        return 42
    fi

    cbmc \
        "$REL_REACH_GOTO" \
        --object-bits 8 \
        --slice-formula \
        --unwind 1 \
        --unwindset "$RELATIONAL_UNWINDSET" \
        --unwinding-assertions \
        --no-standard-checks \
        --trace \
        --json-ui \
        > "$REL_REACH_JSON" \
        2> "$REL_REACH_STDERR"

    REL_REACH_EXIT=$?

    printf 'RELATIONAL_REACHABILITY_CBMC_EXIT=%s\n' \
        "$REL_REACH_EXIT"

    python3 - \
        "$REL_REACH_JSON" \
        "$REL_REACH_SUMMARY" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(
    Path(sys.argv[1]).read_text(encoding="utf-8")
)

entries = payload if isinstance(payload, list) else [payload]
results = []

for entry in entries:
    if (
        isinstance(entry, dict)
        and isinstance(entry.get("result"), list)
    ):
        results.extend(
            item
            for item in entry["result"]
            if isinstance(item, dict)
        )

by_id = {
    str(item.get("property", "")): item
    for item in results
}

first_ok = (
    by_id.get("harness.assertion.1", {}).get("status")
    == "SUCCESS"
)

second_ok = (
    by_id.get("harness.assertion.2", {}).get("status")
    == "SUCCESS"
)

inserted = [
    item
    for property_id, item in by_id.items()
    if (
        property_id.startswith("harness.assertion.")
        and property_id
        not in {"harness.assertion.1", "harness.assertion.2"}
        and item.get("status") == "FAILURE"
    )
]

lines = [
    "RELATIONAL_REACHABILITY_PARSE_STATUS=PASS",
    f"FIRST_RELATIONAL_ASSERTION_SUCCESS={first_ok}",
    f"SECOND_RELATIONAL_ASSERTION_SUCCESS={second_ok}",
    f"INSERTED_FINAL_FAILURE_COUNT={len(inserted)}",
]

accepted = first_ok and second_ok and bool(inserted)

lines.append(
    "RELATIONAL_END_REACHABILITY="
    + ("PASS" if accepted else "FAIL")
)

Path(sys.argv[2]).write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)

print(
    Path(sys.argv[2]).read_text(encoding="utf-8"),
    end="",
)

if not accepted:
    raise SystemExit(1)
PY

    REL_REACH_PARSE_EXIT=$?

    printf 'RELATIONAL_REACHABILITY_PARSE_EXIT=%s\n' \
        "$REL_REACH_PARSE_EXIT"

    if [[ "$REL_REACH_EXIT" -eq 0 ||
          "$REL_REACH_PARSE_EXIT" -ne 0 ]]
    then
        mark_fail "relational end reachability was not established"
        return 43
    fi

    printf 'T1_RELATIONAL_END_REACHABILITY=PASS\n'

    section "00G.7 — NIBBLE-SWAP MUTATION"

    mkdir -p "$SWAP_PROOF_DIR"

    python3 - "$POSITIVE_HARNESS" "$SWAP_HARNESS" <<'PY'
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text(encoding="utf-8")

needle = """            expected_low |
            (uint8_t)(expected_high << 4));"""

replacement = """            expected_high |
            (uint8_t)(expected_low << 4));"""

if source.count(needle) != 1:
    raise SystemExit("nibble-swap insertion point is not unique")

Path(sys.argv[2]).write_text(
    source.replace(needle, replacement),
    encoding="utf-8",
)
PY

    if [[ "$?" -ne 0 ]]; then
        mark_fail "could not create nibble-swap mutant"
        return 50
    fi

    write_makefile \
        "$SWAP_PROOF_DIR" \
        "$SWAP_PROOF_NAME" \
        "$SWAP_HARNESS_NAME"

    printf 'SWAP_HARNESS_SHA256=%s\n' \
        "$(sha256sum "$SWAP_HARNESS" | awk '{print $1}')"

    grep -n -B 5 -A 8 \
        'expected_high |' \
        "$SWAP_HARNESS" ||
        true

    build_goto \
        "$SWAP_PROOF_NAME" \
        "$SWAP_GOTO" \
        "$SWAP_RUNNER_LOG" \
        "$SWAP_RUNNER_JSON" ||
        return 51

    check_loops "$SWAP_GOTO" "$SWAP_LOOPS" "4" "2" ||
        return 52

    run_expected_mutation_failure \
        "NIBBLE_SWAP_MUTATION" \
        "$SWAP_GOTO" \
        "$SWAP_JSON" \
        "$SWAP_STDERR" \
        "$SWAP_SUMMARY" ||
        return 53

    printf 'T1_NIBBLE_SWAP_MUTATION_DETECTION=PASS\n'

    section "00G.8 — ROUNDING-BOUNDARY MUTATION"

    mkdir -p "$ROUND_PROOF_DIR"

    python3 - "$POSITIVE_HARNESS" "$ROUND_HARNESS" <<'PY'
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text(encoding="utf-8")

needle = """      (uint32_t)(MLKEM_Q / 2);"""

replacement = """      (uint32_t)((MLKEM_Q / 2) - 1);"""

if source.count(needle) != 1:
    raise SystemExit("rounding mutation insertion point is not unique")

Path(sys.argv[2]).write_text(
    source.replace(needle, replacement),
    encoding="utf-8",
)
PY

    if [[ "$?" -ne 0 ]]; then
        mark_fail "could not create rounding mutant"
        return 60
    fi

    write_makefile \
        "$ROUND_PROOF_DIR" \
        "$ROUND_PROOF_NAME" \
        "$ROUND_HARNESS_NAME"

    printf 'ROUND_HARNESS_SHA256=%s\n' \
        "$(sha256sum "$ROUND_HARNESS" | awk '{print $1}')"

    grep -n -B 4 -A 7 \
        'MLKEM_Q / 2) - 1' \
        "$ROUND_HARNESS" ||
        true

    build_goto \
        "$ROUND_PROOF_NAME" \
        "$ROUND_GOTO" \
        "$ROUND_RUNNER_LOG" \
        "$ROUND_RUNNER_JSON" ||
        return 61

    check_loops "$ROUND_GOTO" "$ROUND_LOOPS" "4" "2" ||
        return 62

    run_expected_mutation_failure \
        "ROUNDING_MINUS_ONE_MUTATION" \
        "$ROUND_GOTO" \
        "$ROUND_JSON" \
        "$ROUND_STDERR" \
        "$ROUND_SUMMARY" ||
        return 63

    printf 'ROUNDING_WITNESS_3225_JSON_OCCURRENCES=%s\n' "$(
        grep -c '"data": "3225"' "$ROUND_JSON" ||
        true
    )"

    printf 'T1_ROUNDING_BOUNDARY_MUTATION_DETECTION=PASS\n'

    section "00G.9 — POST-RUN IMMUTABILITY"

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
        mark_fail "work production source became dirty"
    else
        printf 'WORK_REPO_PRODUCTION_SOURCE_AFTER=CLEAN\n'
    fi

    printf 'AUTHORITATIVE_HEAD_AFTER=%s\n' "$(
        git -C "$AUTHORITATIVE_SOURCE_PATH" rev-parse HEAD
    )"

    printf 'WORK_REPO_HEAD_AFTER=%s\n' "$(
        git -C "$WORK_REPO" rev-parse HEAD
    )"

    section "POLYCOMP-D4-00G VERDICT"

    if [[ "$FAIL" -eq 0 ]]; then
        printf 'POLYCOMP_D4_00G_STATUS=PASS\n'
        printf 'T1_RELATIONAL_NIBBLE_LOCALITY=PASS\n'
        printf 'T1_RELATIONAL_END_REACHABILITY=PASS\n'
        printf 'T1_NIBBLE_SWAP_MUTATION_DETECTION=PASS\n'
        printf 'T1_ROUNDING_BOUNDARY_MUTATION_DETECTION=PASS\n'
        printf 'T1_THEOREM_STATUS=ALL_REGISTERED_T1_OBLIGATIONS_CHECKED\n'
        printf 'NEXT_GATE=T1_FINAL_EVIDENCE_FREEZE_AND_PACKAGE\n'
    else
        printf 'POLYCOMP_D4_00G_STATUS=FAIL\n'
        printf 'T1_THEOREM_STATUS=NOT_FINAL\n'
        printf 'NEXT_GATE=CLASSIFY_EXACT_RELATIONAL_OR_MUTATION_FAILURE\n'
    fi

    printf 'RELATIONAL_HARNESS=%s\n' "$REL_HARNESS"
    printf 'RELATIONAL_GOTO=%s\n' "$REL_GOTO"
    printf 'RELATIONAL_SEMANTIC_JSON=%s\n' "$REL_SEM_JSON"
    printf 'RELATIONAL_STRICT_JSON=%s\n' "$REL_STRICT_JSON"
    printf 'RELATIONAL_REACHABILITY_JSON=%s\n' "$REL_REACH_JSON"

    printf 'SWAP_HARNESS=%s\n' "$SWAP_HARNESS"
    printf 'SWAP_GOTO=%s\n' "$SWAP_GOTO"
    printf 'SWAP_JSON=%s\n' "$SWAP_JSON"

    printf 'ROUND_HARNESS=%s\n' "$ROUND_HARNESS"
    printf 'ROUND_GOTO=%s\n' "$ROUND_GOTO"
    printf 'ROUND_JSON=%s\n' "$ROUND_JSON"

    return "$FAIL"
}

main 2>&1 | tee "$CAPTURE_FILE"
MAIN_EXIT=${PIPESTATUS[0]}

sync

sha256sum "$CAPTURE_FILE" > "$CAPTURE_HASH_FILE"

printf '\n============================================================\n'
printf 'FINAL POLYCOMP-D4-00G CAPTURE HASH\n'
printf '============================================================\n'

cat "$CAPTURE_HASH_FILE"

printf 'CAPTURE_FILE=%s\n' "$CAPTURE_FILE"
printf 'CAPTURE_HASH_FILE=%s\n' "$CAPTURE_HASH_FILE"
printf 'SCRIPT_EXIT=%s\n' "$MAIN_EXIT"

exit "$MAIN_EXIT"
