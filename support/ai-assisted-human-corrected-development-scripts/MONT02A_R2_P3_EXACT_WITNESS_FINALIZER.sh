#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H_SHA256="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_T1_CAPTURE_SHA256="866ba00a16a8d46595c4abe04456f7f3360600ac0c34ad826a34741c035b8813"
EXPECTED_TIMEOUT_CAPTURE_SHA256="357e891022deb9377ca03caa695dcbacb6fb389824c771719715fd967598d2ce"
EXPECTED_SHARD_CAPTURE_SHA256="8e417faf0e756b2cc01c4cd165662bc06742813639fa2b07eca5137d1eb16786"

EXPECTED_A_HARNESS_SHA256="b63d2c34e4395de62e71484d6e46462c028962750afbbd2cd1f2dd12420e7144"
EXPECTED_A_GOTO_SHA256="422d8bda32008a1d99732999147f75230e7efab61e1716986ef5259ee02dd412"
EXPECTED_B_HARNESS_SHA256="219a9a8e41d0066b2068f8bef0f149aa76aabb8d48dda8f365f2bc08f65df503"
EXPECTED_B_GOTO_SHA256="148d35e8a0fa9b09a58a674b7a403917a278ed9846f04a1cc75779e6f03eb8aa"

AUTHORITATIVE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WORKTREE="$ROOT/MONT_WORKTREE_af4c5abd"
T1_CAPTURE="$ROOT/MONT01B_R1_M2_M3_20260726T151104Z/MONT01B_R1_TERMINAL_CAPTURE_20260726T151104Z.txt"
T1_MAKEFILE="$WORKTREE/proofs/cbmc/mont_t1_exact_refinement/Makefile"

TIMEOUT_OUT="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_20260726T170048Z"
TIMEOUT_CAPTURE="$TIMEOUT_OUT/MONT02A_FULL_T2_CAPTURE_20260726T170048Z.txt"
TIMEOUT_B_LOG="$TIMEOUT_OUT/B_CBMC.log"
TIMEOUT_B_RC="$TIMEOUT_OUT/B_CBMC.rc"

SHARD_OUT="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_20260726T175148Z"
SHARD_CAPTURE="$SHARD_OUT/MONT02A_R1_SHARDED_CAPTURE_20260726T175148Z.txt"

A_DIR="$WORKTREE/proofs/cbmc/mont_t2a_arbitrary_pair"
A_NAME="mont_t2a_arbitrary_pair_harness"
A_C="$A_DIR/$A_NAME.c"
A_MK="$A_DIR/Makefile"
A_GOTO="$A_DIR/gotos/$A_NAME.goto"

B_DIR="$WORKTREE/proofs/cbmc/mont_t2b_fibre_translation"
B_NAME="mont_t2b_fibre_translation_harness"
B_C="$B_DIR/$B_NAME.c"
B_MK="$B_DIR/Makefile"
B_GOTO="$B_DIR/gotos/$B_NAME.goto"

C1_DIR="$WORKTREE/proofs/cbmc/mont_t2c1_same_fibre_control"
C1_NAME="mont_t2c1_same_fibre_control_harness"
C1_C="$C1_DIR/$C1_NAME.c"
C1_MK="$C1_DIR/Makefile"
C1_GOTO="$C1_DIR/gotos/$C1_NAME.goto"

C2_DIR="$WORKTREE/proofs/cbmc/mont_t2c2_translation_control"
C2_NAME="mont_t2c2_translation_control_harness"
C2_C="$C2_DIR/$C2_NAME.c"
C2_MK="$C2_DIR/Makefile"
C2_GOTO="$C2_DIR/gotos/$C2_NAME.goto"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_$STAMP"
CAPTURE="$OUT/MONT02A_R2_P3_FINALIZER_CAPTURE_$STAMP.txt"
PER_SHARD_TIMEOUT=1200
PARALLEL_SHARDS=2

mkdir -p "$OUT"

section() {
  printf '\n============================================================\n'
  printf '%s\n' "$1"
  printf '============================================================\n'
}

hash_file() {
  sha256sum "$1" | awk '{print $1}'
}

create_makefile() {
  local output_file="$1"
  local harness_name="$2"
  local proof_uid="$3"

  cp "$T1_MAKEFILE" "$output_file"

  python3 - "$output_file" "$harness_name" "$proof_uid" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
new_name = sys.argv[2]
new_uid = sys.argv[3]
text = path.read_text()

old_name = "mont_t1_exact_refinement_harness"
old_uid = "MONT-T1 full-domain exact refinement"

if old_name not in text:
    raise SystemExit("old harness token missing")

text = text.replace(old_name, new_name)
text = text.replace(old_uid, new_uid)
text = text.replace("CBMCFLAGS = --smt2", "CBMCFLAGS =")

if old_name in text or new_name not in text:
    raise SystemExit("Makefile patch validation failed")

path.write_text(text)
PY
}

build_goto() {
  local proof_dir="$1"
  local log_file="$2"

  make -C "$proof_dir" MLKEM_K=3 clean > "$log_file.clean" 2>&1 || true
  timeout 300 make -C "$proof_dir" MLKEM_K=3 goto > "$log_file" 2>&1
  return $?
}

run_full_cbmc() {
  local goto_file="$1"
  local log_file="$2"

  timeout "$PER_SHARD_TIMEOUT" cbmc \
    --flush \
    --object-bits 8 \
    --slice-formula \
    --conversion-check \
    --float-overflow-check \
    --nan-check \
    --pointer-overflow-check \
    --unsigned-overflow-check \
    "$goto_file" > "$log_file" 2>&1

  return $?
}

show_properties() {
  local goto_file="$1"
  local output_file="$2"
  cbmc --show-properties "$goto_file" > "$output_file" 2>&1
}

find_property_id() {
  local show_file="$1"
  local description="$2"

  python3 - "$show_file" "$description" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(errors="replace")
target = sys.argv[2]
current = None
matches = []

for line in text.splitlines():
    match = re.match(r"^Property\s+([^:]+):\s*$", line)
    if match:
        current = match.group(1)
        continue
    if current is not None and target in line:
        matches.append(current)

if len(matches) != 1:
    print(f"PROPERTY_LOOKUP_COUNT={len(matches)}", file=sys.stderr)
    raise SystemExit(2)

print(matches[0])
PY
}

run_control_property() {
  local goto_file="$1"
  local property_id="$2"
  local log_file="$3"

  timeout 600 cbmc \
    --flush \
    --object-bits 8 \
    --slice-formula \
    --conversion-check \
    --float-overflow-check \
    --nan-check \
    --pointer-overflow-check \
    --unsigned-overflow-check \
    --property "$property_id" \
    --trace \
    "$goto_file" > "$log_file" 2>&1

  return $?
}

create_p3_shard() {
  local shard="$1"
  local a_relation="$2"
  local b_relation="$3"

  local dir="$WORKTREE/proofs/cbmc/mont_t2a_p3_witness_${shard}"
  local name="mont_t2a_p3_witness_${shard}_harness"
  local source="$dir/$name.c"
  local makefile="$dir/Makefile"

  rm -rf "$dir"
  mkdir -p "$dir"

  cat > "$source" <<C
#include <stdint.h>
#include <limits.h>
#include "../../../mlkem/src/poly.h"

#define MONT_R ((int64_t)65536)
#define MONT_Q ((int64_t)MLKEM_Q)
#define MONT_QINV_UNSIGNED ((int64_t)62209)
#define DOMAIN_LIMIT ((int64_t)INT32_MAX - (((int64_t)1 << 15) * (int64_t)MLKEM_Q))

extern int32_t nondet_int32_t(void);

/*
 * Independent signed Montgomery witness. All arithmetic is int64_t and
 * remains far inside its range on the full source-contract domain.
 */
static int64_t mont_signed_witness(int32_t value)
{
  int64_t low;
  int64_t raw;

  low = (int64_t)value % MONT_R;
  if (low < 0)
  {
    low += MONT_R;
  }

  raw = (low * MONT_QINV_UNSIGNED) % MONT_R;
  if (raw >= (MONT_R / 2))
  {
    raw -= MONT_R;
  }

  return raw;
}

void harness(void)
{
  int32_t a = nondet_int32_t();
  int32_t b = nondet_int32_t();
  int16_t ra;
  int16_t rb;
  int64_t ta;
  int64_t tb;
  int64_t input_delta;
  int64_t output_delta;
  int64_t scaled_difference;
  int64_t exact_q_multiple;

  __CPROVER_assume((int64_t)a < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)a > -DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b < DOMAIN_LIMIT);
  __CPROVER_assume((int64_t)b > -DOMAIN_LIMIT);

  __CPROVER_assume((int64_t)a ${a_relation} 0);
  __CPROVER_assume((int64_t)b ${b_relation} 0);

  ra = mlk_montgomery_reduce(a);
  rb = mlk_montgomery_reduce(b);

  ta = mont_signed_witness(a);
  tb = mont_signed_witness(b);

  input_delta = (int64_t)b - (int64_t)a;
  output_delta = (int64_t)rb - (int64_t)ra;
  scaled_difference = output_delta * MONT_R - input_delta;
  exact_q_multiple = -MONT_Q * (tb - ta);

  /*
   * Stronger exact-witness encoding of the original locked theorem:
   *
   *   R*(reduce(b)-reduce(a)) - (b-a) is an exact multiple of q.
   *
   * Exact equality to q times an independently computed witness directly
   * implies the original modulo-congruence assertion without assuming T1.
   */
  __CPROVER_assert(
      scaled_difference == exact_q_multiple,
      "MONT-T2A.P3.arbitrary_pair_scaled_congruence");
}
C

  create_makefile "$makefile" "$name" "MONT-T2A P3 exact witness shard $shard"

  printf '%s|%s|%s|%s|%s\n' \
    "$shard" "$dir" "$name" "$source" "$makefile"
}

run_p3_shard() {
  local shard="$1"
  local dir="$2"
  local name="$3"
  local source="$4"
  local makefile="$5"

  local evidence="$OUT/P3_$shard"
  local goto_file="$dir/gotos/$name.goto"
  local rc_file="$evidence/rc.txt"

  mkdir -p "$evidence"

  build_goto "$dir" "$evidence/build.log"
  local build_rc=$?
  echo "$build_rc" > "$evidence/build.rc"

  if [[ ! -f "$goto_file" ]]; then
    echo "127" > "$rc_file"
    echo "P3_SHARD_RESULT=$shard|BUILD_RC=$build_rc|GOTO_PRESENT=NO" > "$evidence/summary.txt"
    return 0
  fi

  run_full_cbmc "$goto_file" "$evidence/cbmc.log"
  local cbmc_rc=$?
  echo "$cbmc_rc" > "$rc_file"

  local failure_count
  failure_count="$(grep -Ec ': FAILURE$' "$evidence/cbmc.log" || true)"

  local property_success=0
  if grep -Fq \
      'MONT-T2A.P3.arbitrary_pair_scaled_congruence: SUCCESS' \
      "$evidence/cbmc.log"; then
    property_success=1
  fi

  local success_marker=0
  if grep -Fq 'VERIFICATION SUCCESSFUL' "$evidence/cbmc.log"; then
    success_marker=1
  fi

  local pass=no
  if [[ "$cbmc_rc" -eq 0 && "$failure_count" -eq 0 && "$property_success" -eq 1 && "$success_marker" -eq 1 ]]; then
    pass=yes
  fi

  {
    echo "P3_SHARD=$shard"
    echo "P3_SHARD_HARNESS_SHA256=$(hash_file "$source")"
    echo "P3_SHARD_MAKEFILE_SHA256=$(hash_file "$makefile")"
    echo "P3_SHARD_GOTO_SHA256=$(hash_file "$goto_file")"
    echo "P3_SHARD_CBMC_RC=$cbmc_rc"
    echo "P3_SHARD_FAILURE_COUNT=$failure_count"
    echo "P3_SHARD_PROPERTY_SUCCESS=$property_success"
    echo "P3_SHARD_VERIFICATION_SUCCESSFUL=$success_marker"
    echo "P3_SHARD_AUDIT=${pass^^}"
  } > "$evidence/summary.txt"

  return 0
}

create_control() {
  local base_source="$1"
  local base_makefile="$2"
  local old_name="$3"
  local old_uid="$4"
  local control_dir="$5"
  local control_name="$6"
  local control_uid="$7"
  local marker="$8"
  local assertion_text="$9"

  rm -rf "$control_dir"
  mkdir -p "$control_dir"

  local control_source="$control_dir/$control_name.c"
  local control_makefile="$control_dir/Makefile"

  cp "$base_source" "$control_source"
  cp "$base_makefile" "$control_makefile"

  python3 - "$control_source" "$marker" "$assertion_text" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
marker = sys.argv[2]
replacement = sys.argv[3]
text = path.read_text()

if text.count(marker) != 1:
    raise SystemExit("control marker count invalid")

path.write_text(text.replace(marker, replacement, 1))
PY

  python3 - "$control_makefile" "$old_name" "$control_name" "$old_uid" "$control_uid" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
old_name, new_name, old_uid, new_uid = sys.argv[2:]
text = path.read_text()

if old_name not in text:
    raise SystemExit("old harness token missing")

text = text.replace(old_name, new_name)
text = text.replace(old_uid, new_uid)
text = text.replace("CBMCFLAGS = --smt2", "CBMCFLAGS =")

if old_name in text or new_name not in text:
    raise SystemExit("control Makefile validation failed")

path.write_text(text)
PY
}

{
  section "MONT-02A-R2 — FINALIZE FULL T2-A P3 + BOTH CONTROLS"

  echo "UTC_TIME=$STAMP"
  echo "OUTPUT_DIRECTORY=$OUT"
  echo "P3_ENCODING=EXACT_Q_MULTIPLE_WITNESS"
  echo "P3_DOMAIN_PARTITION=FOUR_EXHAUSTIVE_SIGN_QUADRANTS"
  echo "PER_SHARD_TIMEOUT=$PER_SHARD_TIMEOUT"
  echo "PARALLEL_SHARDS=$PARALLEL_SHARDS"

  section "R0 — BIND SOURCE, T1, PRIOR 19/20 RESULT, AND T2-B"

  AUTH_HEAD="$(git -C "$AUTHORITATIVE" rev-parse HEAD 2>/dev/null || true)"
  WT_HEAD="$(git -C "$WORKTREE" rev-parse HEAD 2>/dev/null || true)"
  AUTH_STATUS="$(git -C "$AUTHORITATIVE" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

  if [[ "$AUTH_HEAD" != "$EXPECTED_COMMIT" || "$WT_HEAD" != "$EXPECTED_COMMIT" || -n "$AUTH_STATUS" ]]; then
    echo "COMMIT_OR_CLEAN_GATE=FAIL"
    exit 20
  fi

  if [[ "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")" != "$EXPECTED_POLY_H_SHA256" || "$(hash_file "$WORKTREE/mlkem/src/poly.h")" != "$EXPECTED_POLY_H_SHA256" || "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")" != "$EXPECTED_POLY_C_SHA256" || "$(hash_file "$WORKTREE/mlkem/src/poly.c")" != "$EXPECTED_POLY_C_SHA256" ]]; then
    echo "SOURCE_BINDING_GATE=FAIL"
    exit 21
  fi

  for required_file in "$T1_CAPTURE" "$TIMEOUT_CAPTURE" "$SHARD_CAPTURE" "$TIMEOUT_B_LOG" "$TIMEOUT_B_RC" "$A_C" "$A_MK" "$A_GOTO" "$B_C" "$B_MK" "$B_GOTO" "$T1_MAKEFILE"; do
    if [[ ! -f "$required_file" ]]; then
      echo "REQUIRED_FILE_MISSING=$required_file"
      exit 22
    fi
  done

  if [[ "$(hash_file "$T1_CAPTURE")" != "$EXPECTED_T1_CAPTURE_SHA256" || "$(hash_file "$TIMEOUT_CAPTURE")" != "$EXPECTED_TIMEOUT_CAPTURE_SHA256" || "$(hash_file "$SHARD_CAPTURE")" != "$EXPECTED_SHARD_CAPTURE_SHA256" ]]; then
    echo "PRIOR_CAPTURE_BINDING_GATE=FAIL"
    exit 23
  fi

  if [[ "$(hash_file "$A_C")" != "$EXPECTED_A_HARNESS_SHA256" || "$(hash_file "$A_GOTO")" != "$EXPECTED_A_GOTO_SHA256" || "$(hash_file "$B_C")" != "$EXPECTED_B_HARNESS_SHA256" || "$(hash_file "$B_GOTO")" != "$EXPECTED_B_GOTO_SHA256" ]]; then
    echo "T2_ARTEFACT_BINDING_GATE=FAIL"
    exit 24
  fi

  SHARD_MARKERS=(
    'T2_A_PROPERTY_TOTAL=20'
    'T2_A_PROPERTY_PASS_COUNT=19'
    'T2_A_PROPERTY_TIMEOUT_COUNT=1'
    'T2_A_PROPERTY_FAILURE_COUNT=0'
    'PROPERTY_RESULT=harness.assertion.3|RC=124|PASS=NO'
  )

  marker_failures=0
  for marker in "${SHARD_MARKERS[@]}"; do
    if grep -Fxq "$marker" "$SHARD_CAPTURE"; then
      echo "PRIOR_SHARD_MARKER_PRESENT=$marker"
    else
      echo "PRIOR_SHARD_MARKER_MISSING=$marker"
      marker_failures=$((marker_failures + 1))
    fi
  done

  if [[ "$marker_failures" -ne 0 ]]; then
    echo "PRIOR_19_OF_20_BINDING=FAIL"
    exit 25
  fi

  BRC="$(cat "$TIMEOUT_B_RC")"
  if [[ "$BRC" != "0" ]] || ! grep -Fq 'VERIFICATION SUCCESSFUL' "$TIMEOUT_B_LOG"; then
    echo "T2_B_BINDING_GATE=FAIL"
    exit 26
  fi

  B_REQUIRED=(
    'MONT-T2B.P1.shifted_input_same_low_word: SUCCESS'
    'MONT-T2B.P2.general_fibre_translation: SUCCESS'
    'MONT-T2B.P3.exact_output_delta_equals_k: SUCCESS'
    'MONT-T2B.P4.zero_shift_identity: SUCCESS'
    'MONT-T2B.P5.nonzero_shift_changes_output: SUCCESS'
  )

  for marker in "${B_REQUIRED[@]}"; do
    if ! grep -Fq "$marker" "$TIMEOUT_B_LOG"; then
      echo "T2_B_REQUIRED_MARKER_MISSING=$marker"
      exit 27
    fi
  done

  echo "COMMIT_AND_CLEAN_GATE=PASS"
  echo "SOURCE_BINDING_GATE=PASS"
  echo "ACCEPTED_T1_BINDING_GATE=PASS"
  echo "T2_A_PRIOR_19_OF_20_BINDING=PASS"
  echo "T2_B_FUNCTIONAL_AUDIT=PASS"

  cp "$TIMEOUT_CAPTURE" "$OUT/BOUND_TIMEOUT_CAPTURE.txt"
  cp "$SHARD_CAPTURE" "$OUT/BOUND_19_OF_20_SHARD_CAPTURE.txt"
  cp "$T1_CAPTURE" "$OUT/BOUND_ACCEPTED_T1_CAPTURE.txt"

  section "R1 — FREEZE EQUIVALENT-STRONGER P3 ENCODING"

  cat > "$OUT/MONT02A_P3_ENCODING_REGISTRY.md" <<EOF
# MONT-T2A.P3 Solver Encoding Recovery

Original locked theorem:

\`R * (reduce(b) - reduce(a)) - (b - a) ≡ 0 (mod q)\`.

Recovery encoding checked directly by CBMC:

\`R * (reduce(b) - reduce(a)) - (b - a) = -q * (t_b - t_a)\`,

where \`t_a\` and \`t_b\` are independently computed signed Montgomery
witnesses from the canonical low words of \`a\` and \`b\`.

The recovery equality is strictly stronger as an encoding because equality
to an explicit multiple of \`q\` directly implies the original congruence.
It does not assume MONT-T1 and does not narrow the source-contract domain.

The full domain is partitioned exhaustively into:

1. \`a >= 0, b >= 0\`
2. \`a >= 0, b < 0\`
3. \`a < 0, b >= 0\`
4. \`a < 0, b < 0\`

The four quadrants are disjoint and their union is the complete signed input
pair domain. Every quadrant retains the original full contract bounds.
EOF

  echo "P3_ENCODING_REGISTRY_SHA256=$(hash_file "$OUT/MONT02A_P3_ENCODING_REGISTRY.md")"

  section "R2 — CREATE AND BUILD FOUR EXHAUSTIVE P3 SHARDS"

  mapfile -t SHARD_ROWS < <(
    create_p3_shard "PP" ">=" ">="
    create_p3_shard "PN" ">=" "<"
    create_p3_shard "NP" "<" ">="
    create_p3_shard "NN" "<" "<"
  )

  for row in "${SHARD_ROWS[@]}"; do
    IFS='|' read -r shard dir name source makefile <<< "$row"
    echo "P3_SHARD_CREATED=$shard"
    echo "P3_${shard}_HARNESS_SHA256=$(hash_file "$source")"
    echo "P3_${shard}_MAKEFILE_SHA256=$(hash_file "$makefile")"
  done

  section "R3 — RUN P3 SHARDS TWO AT A TIME"

  run_p3_shard ${SHARD_ROWS[0]//|/ } &
  P0=$!
  run_p3_shard ${SHARD_ROWS[1]//|/ } &
  P1=$!
  wait "$P0" || true
  wait "$P1" || true

  run_p3_shard ${SHARD_ROWS[2]//|/ } &
  P2=$!
  run_p3_shard ${SHARD_ROWS[3]//|/ } &
  P3=$!
  wait "$P2" || true
  wait "$P3" || true

  p3_pass_count=0
  for shard in PP PN NP NN; do
    summary="$OUT/P3_$shard/summary.txt"
    if [[ ! -f "$summary" ]]; then
      echo "P3_${shard}_SUMMARY_PRESENT=NO"
      continue
    fi

    cat "$summary"

    if grep -Fxq 'P3_SHARD_AUDIT=YES' "$summary"; then
      p3_pass_count=$((p3_pass_count + 1))
    fi
  done

  echo "P3_EXHAUSTIVE_SHARD_COUNT=4"
  echo "P3_EXHAUSTIVE_PASS_COUNT=$p3_pass_count"

  if [[ "$p3_pass_count" -ne 4 ]]; then
    echo "T2_A_P3_EXACT_WITNESS_GATE=FAIL"
    exit 28
  fi

  echo "T2_A_P3_EXACT_WITNESS_GATE=PASS"
  echo "T2_A_P3_ORIGINAL_CONGRUENCE=PROVED_BY_EXACT_MULTIPLE_WITNESS"

  section "R4 — CREATE BOTH ORIGINAL DISTINCT CONTROLS"

  create_control \
    "$A_C" "$A_MK" "$A_NAME" \
    'MONT-T2A arbitrary-pair relational laws' \
    "$C1_DIR" "$C1_NAME" 'MONT-T2 C1 same-fibre control' \
    '    /* C1_CONTROL */' \
    $'    __CPROVER_assert(\n        0,\n        "MONT-T2.CONTROL.C1.same_fibre_branch_reachable");'

  create_control \
    "$B_C" "$B_MK" "$B_NAME" \
    'MONT-T2B affine fibre laws' \
    "$C2_DIR" "$C2_NAME" 'MONT-T2 C2 translation control' \
    '  /* C2_CONTROL */' \
    $'  __CPROVER_assert(\n      0,\n      "MONT-T2.CONTROL.C2.translation_path_reachable");'

  echo "C1_HARNESS_SHA256=$(hash_file "$C1_C")"
  echo "C2_HARNESS_SHA256=$(hash_file "$C2_C")"

  section "R5 — BUILD AND RUN CONTROL PROPERTIES ONLY"

  build_goto "$C1_DIR" "$OUT/C1_BUILD.log"
  C1_BUILD_RC=$?
  build_goto "$C2_DIR" "$OUT/C2_BUILD.log"
  C2_BUILD_RC=$?

  echo "C1_BUILD_RC=$C1_BUILD_RC"
  echo "C2_BUILD_RC=$C2_BUILD_RC"

  if [[ ! -f "$C1_GOTO" || ! -f "$C2_GOTO" ]]; then
    echo "CONTROL_GOTO_GATE=FAIL"
    exit 29
  fi

  show_properties "$C1_GOTO" "$OUT/C1_PROPERTIES.txt"
  show_properties "$C2_GOTO" "$OUT/C2_PROPERTIES.txt"

  C1_ID="$(find_property_id "$OUT/C1_PROPERTIES.txt" 'MONT-T2.CONTROL.C1.same_fibre_branch_reachable')"
  C2_ID="$(find_property_id "$OUT/C2_PROPERTIES.txt" 'MONT-T2.CONTROL.C2.translation_path_reachable')"

  echo "C1_PROPERTY_ID=$C1_ID"
  echo "C2_PROPERTY_ID=$C2_ID"

  run_control_property "$C1_GOTO" "$C1_ID" "$OUT/C1_CBMC.log"
  C1_RC=$?
  run_control_property "$C2_GOTO" "$C2_ID" "$OUT/C2_CBMC.log"
  C2_RC=$?

  C1_FAILURES="$(grep -Ec ': FAILURE$' "$OUT/C1_CBMC.log" || true)"
  C2_FAILURES="$(grep -Ec ': FAILURE$' "$OUT/C2_CBMC.log" || true)"

  C1_EXPECTED="$(grep -Ec 'MONT-T2.CONTROL.C1.same_fibre_branch_reachable: FAILURE$' "$OUT/C1_CBMC.log" || true)"
  C2_EXPECTED="$(grep -Ec 'MONT-T2.CONTROL.C2.translation_path_reachable: FAILURE$' "$OUT/C2_CBMC.log" || true)"

  echo "C1_DIRECT_RC=$C1_RC"
  echo "C1_FAILURE_COUNT=$C1_FAILURES"
  echo "C1_EXPECTED_FAILURE_COUNT=$C1_EXPECTED"
  echo "C2_DIRECT_RC=$C2_RC"
  echo "C2_FAILURE_COUNT=$C2_FAILURES"
  echo "C2_EXPECTED_FAILURE_COUNT=$C2_EXPECTED"

  if [[ "$C1_RC" -ne 10 || "$C1_FAILURES" -ne 1 || "$C1_EXPECTED" -ne 1 ]]; then
    echo "C1_NONVACUITY_AUDIT=FAIL"
    exit 30
  fi

  if [[ "$C2_RC" -ne 10 || "$C2_FAILURES" -ne 1 || "$C2_EXPECTED" -ne 1 ]]; then
    echo "C2_NONVACUITY_AUDIT=FAIL"
    exit 31
  fi

  echo "C1_NONVACUITY_AUDIT=PASS"
  echo "C2_NONVACUITY_AUDIT=PASS"

  section "R6 — FINAL FULL-POWER GATE-A VERDICT"

  FINAL_AUTH_H="$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")"
  FINAL_WORK_H="$(hash_file "$WORKTREE/mlkem/src/poly.h")"
  FINAL_AUTH_C="$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")"
  FINAL_WORK_C="$(hash_file "$WORKTREE/mlkem/src/poly.c")"

  if [[ "$FINAL_AUTH_H" != "$EXPECTED_POLY_H_SHA256" || "$FINAL_WORK_H" != "$EXPECTED_POLY_H_SHA256" || "$FINAL_AUTH_C" != "$EXPECTED_POLY_C_SHA256" || "$FINAL_WORK_C" != "$EXPECTED_POLY_C_SHA256" ]]; then
    echo "FINAL_SOURCE_INTEGRITY=FAIL"
    exit 32
  fi

  echo "FINAL_SOURCE_INTEGRITY=PASS"

  A_MAKEFILE_SHA256="$(hash_file "$A_MK")"
  B_MAKEFILE_SHA256="$(hash_file "$B_MK")"

  cat > "$OUT/MONT02A_GATE_A_BINDING.env" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H_SHA256=$EXPECTED_POLY_H_SHA256
EXPECTED_POLY_C_SHA256=$EXPECTED_POLY_C_SHA256
T1_CAPTURE_SHA256=$EXPECTED_T1_CAPTURE_SHA256
A_HARNESS_SHA256=$EXPECTED_A_HARNESS_SHA256
A_MAKEFILE_SHA256=$A_MAKEFILE_SHA256
A_GOTO_SHA256=$EXPECTED_A_GOTO_SHA256
B_HARNESS_SHA256=$EXPECTED_B_HARNESS_SHA256
B_MAKEFILE_SHA256=$B_MAKEFILE_SHA256
B_GOTO_SHA256=$EXPECTED_B_GOTO_SHA256
T2_A_PRIOR_PROPERTY_PASS_COUNT=19
T2_A_P3_EXHAUSTIVE_SIGN_SHARDS=4
T2_A_P3_EXACT_WITNESS_GATE=PASS
T2_B_FUNCTIONAL_AUDIT=PASS
C1_NONVACUITY_AUDIT=PASS
C2_NONVACUITY_AUDIT=PASS
MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS
EOF

  echo "GATE_A_BINDING_SHA256=$(hash_file "$OUT/MONT02A_GATE_A_BINDING.env")"
  echo "T2_A_ALL_ORIGINAL_PROPERTIES_CHECKED=YES"
  echo "T2_A_FUNCTIONAL_AUDIT=PASS"
  echo "T2_B_FUNCTIONAL_AUDIT=PASS"
  echo "C1_NONVACUITY_AUDIT=PASS"
  echo "C2_NONVACUITY_AUDIT=PASS"
  echo "MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS"
  echo "NEXT_GATE=MONT-02B_T2_SPECIFIC_MUTATIONS"

  find "$OUT" -type f -print0 | sort -z | xargs -0 sha256sum > "$OUT/MONT02A_R2_FILE_MANIFEST.sha256"

  echo "MONT02A_R2_CAPTURE_END=YES"

} 2>&1 | tee "$CAPTURE"

SCRIPT_RC="${PIPESTATUS[0]}"

sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"

echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$SCRIPT_RC"

exit "$SCRIPT_RC"
