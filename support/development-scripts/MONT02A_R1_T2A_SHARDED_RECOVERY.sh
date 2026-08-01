#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H_SHA256="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_T1_CAPTURE_SHA256="866ba00a16a8d46595c4abe04456f7f3360600ac0c34ad826a34741c035b8813"
EXPECTED_PREVIOUS_CAPTURE_SHA256="357e891022deb9377ca03caa695dcbacb6fb389824c771719715fd967598d2ce"

EXPECTED_A_HARNESS_SHA256="b63d2c34e4395de62e71484d6e46462c028962750afbbd2cd1f2dd12420e7144"
EXPECTED_B_HARNESS_SHA256="219a9a8e41d0066b2068f8bef0f149aa76aabb8d48dda8f365f2bc08f65df503"
EXPECTED_A_GOTO_SHA256="422d8bda32008a1d99732999147f75230e7efab61e1716986ef5259ee02dd412"
EXPECTED_B_GOTO_SHA256="148d35e8a0fa9b09a58a674b7a403917a278ed9846f04a1cc75779e6f03eb8aa"

AUTHORITATIVE="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WORKTREE="$ROOT/MONT_WORKTREE_af4c5abd"
T1_CAPTURE="$ROOT/MONT01B_R1_M2_M3_20260726T151104Z/MONT01B_R1_TERMINAL_CAPTURE_20260726T151104Z.txt"

PREVIOUS_OUT="$ROOT/MONT02A_FULL_T2_FUNCTIONAL_20260726T170048Z"
PREVIOUS_CAPTURE="$PREVIOUS_OUT/MONT02A_FULL_T2_CAPTURE_20260726T170048Z.txt"
PREVIOUS_B_LOG="$PREVIOUS_OUT/B_CBMC.log"
PREVIOUS_B_RC="$PREVIOUS_OUT/B_CBMC.rc"

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
CAPTURE="$OUT/MONT02A_R1_SHARDED_CAPTURE_$STAMP.txt"
PER_PROPERTY_TIMEOUT=1200
PARALLEL_PROPERTIES=2

mkdir -p "$OUT"

section() {
  printf '\n============================================================\n'
  printf '%s\n' "$1"
  printf '============================================================\n'
}

hash_file() {
  sha256sum "$1" | awk '{print $1}'
}

create_control_makefile() {
  local source_makefile="$1"
  local output_makefile="$2"
  local old_name="$3"
  local new_name="$4"
  local old_uid="$5"
  local new_uid="$6"

  cp "$source_makefile" "$output_makefile"

  python3 - "$output_makefile" "$old_name" "$new_name" "$old_uid" "$new_uid" <<'PY'
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

build_goto() {
  local dir="$1"
  local log="$2"

  make -C "$dir" MLKEM_K=3 clean > "$log.clean" 2>&1 || true
  timeout 300 make -C "$dir" MLKEM_K=3 goto > "$log" 2>&1
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

{
  section "MONT-02A-R1 — T2-A PROPERTY-SHARDED RECOVERY + BOTH CONTROLS"

  echo "UTC_TIME=$STAMP"
  echo "OUTPUT_DIRECTORY=$OUT"
  echo "PER_PROPERTY_TIMEOUT=$PER_PROPERTY_TIMEOUT"
  echo "PARALLEL_PROPERTIES=$PARALLEL_PROPERTIES"

  section "R0 — SOURCE, T1, PRIOR RUN, AND ARTEFACT BINDING"

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

  if [[ ! -f "$T1_CAPTURE" || "$(hash_file "$T1_CAPTURE")" != "$EXPECTED_T1_CAPTURE_SHA256" ]]; then
    echo "T1_BINDING_GATE=FAIL"
    exit 22
  fi

  if [[ ! -f "$PREVIOUS_CAPTURE" || "$(hash_file "$PREVIOUS_CAPTURE")" != "$EXPECTED_PREVIOUS_CAPTURE_SHA256" ]]; then
    echo "PREVIOUS_CAPTURE_BINDING=FAIL"
    exit 23
  fi

  for file in "$A_C" "$A_MK" "$A_GOTO" "$B_C" "$B_MK" "$B_GOTO" "$PREVIOUS_B_LOG" "$PREVIOUS_B_RC"; do
    if [[ ! -f "$file" ]]; then
      echo "REQUIRED_FILE_MISSING=$file"
      exit 24
    fi
  done

  if [[ "$(hash_file "$A_C")" != "$EXPECTED_A_HARNESS_SHA256" || "$(hash_file "$B_C")" != "$EXPECTED_B_HARNESS_SHA256" || "$(hash_file "$A_GOTO")" != "$EXPECTED_A_GOTO_SHA256" || "$(hash_file "$B_GOTO")" != "$EXPECTED_B_GOTO_SHA256" ]]; then
    echo "T2_ARTEFACT_BINDING=FAIL"
    exit 25
  fi

  echo "COMMIT_AND_CLEAN_GATE=PASS"
  echo "SOURCE_BINDING_GATE=PASS"
  echo "ACCEPTED_T1_BINDING_GATE=PASS"
  echo "PRIOR_TIMEOUT_CAPTURE_BINDING=PASS"
  echo "T2_ARTEFACT_BINDING=PASS"

  section "R1 — BIND ALREADY SUCCESSFUL T2-B"

  BRC="$(cat "$PREVIOUS_B_RC")"
  B_MISSING=0

  for marker in \
    "MONT-T2B.P1.shifted_input_same_low_word: SUCCESS" \
    "MONT-T2B.P2.general_fibre_translation: SUCCESS" \
    "MONT-T2B.P3.exact_output_delta_equals_k: SUCCESS" \
    "MONT-T2B.P4.zero_shift_identity: SUCCESS" \
    "MONT-T2B.P5.nonzero_shift_changes_output: SUCCESS"; do
    if ! grep -Fq "$marker" "$PREVIOUS_B_LOG"; then
      echo "T2_B_MISSING=$marker"
      B_MISSING=$((B_MISSING + 1))
    fi
  done

  if [[ "$BRC" -ne 0 || "$B_MISSING" -ne 0 ]] || ! grep -Fq "VERIFICATION SUCCESSFUL" "$PREVIOUS_B_LOG"; then
    echo "T2_B_PRIOR_RESULT_BINDING=FAIL"
    exit 26
  fi

  cp "$PREVIOUS_B_LOG" "$OUT/BOUND_B_CBMC.log"
  cp "$PREVIOUS_B_RC" "$OUT/BOUND_B_CBMC.rc"
  echo "T2_B_FUNCTIONAL_AUDIT=PASS"
  echo "T2_B_PRIOR_RESULT_REUSED=YES"

  section "R2 — ENUMERATE EVERY T2-A PROPERTY"

  show_properties "$A_GOTO" "$OUT/A_SHOW_PROPERTIES.log"
  SHOW_RC=$?
  echo "T2_A_SHOW_PROPERTIES_RC=$SHOW_RC"

  if [[ "$SHOW_RC" -ne 0 ]]; then
    tail -n 100 "$OUT/A_SHOW_PROPERTIES.log" || true
    exit 27
  fi

  python3 - "$OUT/A_SHOW_PROPERTIES.log" "$OUT/A_PROPERTY_IDS.txt" <<'PY'
from pathlib import Path
import re
import sys

source = Path(sys.argv[1]).read_text(errors="replace")
output = Path(sys.argv[2])
ids = []

for line in source.splitlines():
    match = re.match(r"^Property\s+([^:]+):\s*$", line)
    if match:
        ids.append(match.group(1))

if not ids:
    raise SystemExit("no property IDs parsed")

if len(ids) != len(set(ids)):
    raise SystemExit("duplicate property IDs parsed")

output.write_text("\n".join(ids) + "\n")
print(f"T2_A_ENUMERATED_PROPERTY_COUNT={len(ids)}")
PY

  ENUM_RC=$?
  echo "T2_A_PROPERTY_ENUMERATION_RC=$ENUM_RC"

  if [[ "$ENUM_RC" -ne 0 ]]; then
    exit 28
  fi

  REQUIRED_DESCRIPTIONS=(
    "MONT-T2A.P1.first_low_word_normalized"
    "MONT-T2A.P2.second_low_word_normalized"
    "MONT-T2A.P3.arbitrary_pair_scaled_congruence"
    "MONT-T2A.P4.same_low_word_input_delta_divisible_by_R"
    "MONT-T2A.P5.same_low_word_exact_output_delta"
    "MONT-T2A.P6.same_fibre_injectivity"
  )

  REQUIRED_MISSING=0
  for description in "${REQUIRED_DESCRIPTIONS[@]}"; do
    if grep -Fq "$description" "$OUT/A_SHOW_PROPERTIES.log"; then
      echo "T2_A_REQUIRED_PROPERTY_PRESENT=$description"
    else
      echo "T2_A_REQUIRED_PROPERTY_MISSING=$description"
      REQUIRED_MISSING=$((REQUIRED_MISSING + 1))
    fi
  done

  if [[ "$REQUIRED_MISSING" -ne 0 ]]; then
    exit 29
  fi

  section "R3 — CHECK EVERY ORIGINAL T2-A PROPERTY INDIVIDUALLY"

  mkdir -p "$OUT/A_PROPERTY_LOGS"

  python3 - \
    "$A_GOTO" \
    "$OUT/A_PROPERTY_IDS.txt" \
    "$OUT/A_PROPERTY_LOGS" \
    "$PER_PROPERTY_TIMEOUT" \
    "$PARALLEL_PROPERTIES" <<'PY'
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
import hashlib
import json
import subprocess
import sys

GOTO = Path(sys.argv[1])
IDS_FILE = Path(sys.argv[2])
LOG_DIR = Path(sys.argv[3])
TIMEOUT = int(sys.argv[4])
WORKERS = int(sys.argv[5])

property_ids = [line.strip() for line in IDS_FILE.read_text().splitlines() if line.strip()]
LOG_DIR.mkdir(parents=True, exist_ok=True)

base = [
    "cbmc",
    "--flush",
    "--object-bits", "8",
    "--slice-formula",
    "--conversion-check",
    "--float-overflow-check",
    "--nan-check",
    "--pointer-overflow-check",
    "--unsigned-overflow-check",
]

def run_one(property_id):
    digest = hashlib.sha256(property_id.encode()).hexdigest()[:20]
    log_path = LOG_DIR / f"{digest}.log"
    command = base + ["--property", property_id, str(GOTO)]
    try:
        with log_path.open("w") as handle:
            completed = subprocess.run(
                command,
                stdout=handle,
                stderr=subprocess.STDOUT,
                timeout=TIMEOUT,
                check=False,
                text=True,
            )
        rc = completed.returncode
        timed_out = False
    except subprocess.TimeoutExpired:
        rc = 124
        timed_out = True
        with log_path.open("a") as handle:
            handle.write("\nPROPERTY_RUN_TIMEOUT\n")

    text = log_path.read_text(errors="replace")
    successful = (
        rc == 0
        and "VERIFICATION SUCCESSFUL" in text
        and "VERIFICATION FAILED" not in text
        and "VERIFICATION ERROR" not in text
    )

    return {
        "property_id": property_id,
        "return_code": rc,
        "timed_out": timed_out,
        "successful": successful,
        "log": str(log_path),
    }

results = []
with ThreadPoolExecutor(max_workers=WORKERS) as pool:
    futures = {pool.submit(run_one, prop): prop for prop in property_ids}
    for future in as_completed(futures):
        result = future.result()
        results.append(result)
        print(
            "PROPERTY_RESULT="
            f"{result['property_id']}|RC={result['return_code']}|"
            f"PASS={'YES' if result['successful'] else 'NO'}"
        )

results.sort(key=lambda item: item["property_id"])
(Path(LOG_DIR) / "results.json").write_text(json.dumps(results, indent=2) + "\n")

passed = sum(1 for item in results if item["successful"])
timeouts = sum(1 for item in results if item["return_code"] == 124)
failures = len(results) - passed - timeouts

print(f"T2_A_PROPERTY_TOTAL={len(results)}")
print(f"T2_A_PROPERTY_PASS_COUNT={passed}")
print(f"T2_A_PROPERTY_TIMEOUT_COUNT={timeouts}")
print(f"T2_A_PROPERTY_FAILURE_COUNT={failures}")

raise SystemExit(0 if passed == len(results) else 4)
PY

  SHARD_RC=$?
  echo "T2_A_PROPERTY_SHARD_AUDIT_RC=$SHARD_RC"

  if [[ "$SHARD_RC" -ne 0 ]]; then
    echo "T2_A_FUNCTIONAL_AUDIT=INCOMPLETE_OR_FAILED"
    exit 30
  fi

  echo "T2_A_ALL_ORIGINAL_PROPERTIES_CHECKED=YES"
  echo "T2_A_FUNCTIONAL_AUDIT=PASS"

  section "R4 — CREATE TWO DISTINCT NON-VACUITY CONTROLS"

  rm -rf "$C1_DIR" "$C2_DIR"
  mkdir -p "$C1_DIR" "$C2_DIR"

  cp "$A_C" "$C1_C"
  cp "$B_C" "$C2_C"

  create_control_makefile "$A_MK" "$C1_MK" "$A_NAME" "$C1_NAME" "MONT-T2A arbitrary-pair relational laws" "MONT-T2 C1 same-fibre control"
  create_control_makefile "$B_MK" "$C2_MK" "$B_NAME" "$C2_NAME" "MONT-T2B affine fibre laws" "MONT-T2 C2 translation control"

  python3 - "$C1_C" "$C2_C" <<'PY'
from pathlib import Path
import sys

c1 = Path(sys.argv[1])
c2 = Path(sys.argv[2])

s1 = c1.read_text()
m1 = "    /* C1_CONTROL */"
if s1.count(m1) != 1:
    raise SystemExit("C1 marker count invalid")
s1 = s1.replace(
    m1,
    '''    __CPROVER_assert(
        0,
        "MONT-T2.C1.same_fibre_branch_reachable");''',
)
c1.write_text(s1)

s2 = c2.read_text()
m2 = "  /* C2_CONTROL */"
if s2.count(m2) != 1:
    raise SystemExit("C2 marker count invalid")
s2 = s2.replace(
    m2,
    '''  __CPROVER_assert(
      0,
      "MONT-T2.C2.translation_path_reachable");''',
)
c2.write_text(s2)
PY

  CONTROL_PATCH_RC=$?
  echo "CONTROL_PATCH_RC=$CONTROL_PATCH_RC"
  if [[ "$CONTROL_PATCH_RC" -ne 0 ]]; then
    exit 31
  fi

  build_goto "$C1_DIR" "$OUT/C1_BUILD.log"
  C1_BUILD_RC=$?
  build_goto "$C2_DIR" "$OUT/C2_BUILD.log"
  C2_BUILD_RC=$?

  echo "C1_GOTO_BUILD_RC=$C1_BUILD_RC"
  echo "C2_GOTO_BUILD_RC=$C2_BUILD_RC"

  if [[ "$C1_BUILD_RC" -ne 0 || ! -f "$C1_GOTO" ]]; then
    echo "C1_GOTO_GATE=FAIL"
    tail -n 100 "$OUT/C1_BUILD.log" || true
    exit 32
  fi

  if [[ "$C2_BUILD_RC" -ne 0 || ! -f "$C2_GOTO" ]]; then
    echo "C2_GOTO_GATE=FAIL"
    tail -n 100 "$OUT/C2_BUILD.log" || true
    exit 33
  fi

  show_properties "$C1_GOTO" "$OUT/C1_SHOW_PROPERTIES.log"
  show_properties "$C2_GOTO" "$OUT/C2_SHOW_PROPERTIES.log"

  C1_PROPERTY_ID="$(find_property_id "$OUT/C1_SHOW_PROPERTIES.log" "MONT-T2.C1.same_fibre_branch_reachable")"
  C1_LOOKUP_RC=$?
  C2_PROPERTY_ID="$(find_property_id "$OUT/C2_SHOW_PROPERTIES.log" "MONT-T2.C2.translation_path_reachable")"
  C2_LOOKUP_RC=$?

  echo "C1_CONTROL_PROPERTY_ID=$C1_PROPERTY_ID"
  echo "C2_CONTROL_PROPERTY_ID=$C2_PROPERTY_ID"

  if [[ "$C1_LOOKUP_RC" -ne 0 || "$C2_LOOKUP_RC" -ne 0 ]]; then
    echo "CONTROL_PROPERTY_LOOKUP=FAIL"
    exit 34
  fi

  section "R5 — RUN BOTH CONTROL PROPERTIES"

  run_control_property "$C1_GOTO" "$C1_PROPERTY_ID" "$OUT/C1_CBMC.log" &
  P1=$!
  run_control_property "$C2_GOTO" "$C2_PROPERTY_ID" "$OUT/C2_CBMC.log" &
  P2=$!

  wait "$P1"
  C1_RC=$?
  wait "$P2"
  C2_RC=$?

  echo "C1_DIRECT_RC=$C1_RC"
  echo "C2_DIRECT_RC=$C2_RC"

  C1_FAILURES="$(grep -Ec ': FAILURE$' "$OUT/C1_CBMC.log" || true)"
  C2_FAILURES="$(grep -Ec ': FAILURE$' "$OUT/C2_CBMC.log" || true)"

  if [[ "$C1_RC" -ne 10 || "$C1_FAILURES" -ne 1 ]] || ! grep -Fq "MONT-T2.C1.same_fibre_branch_reachable: FAILURE" "$OUT/C1_CBMC.log"; then
    echo "C1_NONVACUITY_AUDIT=FAIL"
    exit 35
  fi

  if [[ "$C2_RC" -ne 10 || "$C2_FAILURES" -ne 1 ]] || ! grep -Fq "MONT-T2.C2.translation_path_reachable: FAILURE" "$OUT/C2_CBMC.log"; then
    echo "C2_NONVACUITY_AUDIT=FAIL"
    exit 36
  fi

  echo "C1_NONVACUITY_AUDIT=PASS"
  echo "C2_NONVACUITY_AUDIT=PASS"

  section "R6 — FINAL INTEGRITY AND GATE-A ACCEPTANCE"

  FINAL_AUTH_STATUS="$(git -C "$AUTHORITATIVE" status --porcelain=v1 --untracked-files=all 2>/dev/null || true)"

  if [[ -n "$FINAL_AUTH_STATUS" || "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.h")" != "$EXPECTED_POLY_H_SHA256" || "$(hash_file "$WORKTREE/mlkem/src/poly.h")" != "$EXPECTED_POLY_H_SHA256" || "$(hash_file "$AUTHORITATIVE/mlkem/src/poly.c")" != "$EXPECTED_POLY_C_SHA256" || "$(hash_file "$WORKTREE/mlkem/src/poly.c")" != "$EXPECTED_POLY_C_SHA256" ]]; then
    echo "FINAL_SOURCE_INTEGRITY=FAIL"
    exit 37
  fi

  T1_HASH="$(hash_file "$T1_CAPTURE")"

  cat > "$OUT/MONT02A_GATE_A_BINDING.env" <<EOF
EXPECTED_COMMIT=$EXPECTED_COMMIT
EXPECTED_POLY_H_SHA256=$EXPECTED_POLY_H_SHA256
EXPECTED_POLY_C_SHA256=$EXPECTED_POLY_C_SHA256
T1_CAPTURE_SHA256=$T1_HASH
A_HARNESS_SHA256=$(hash_file "$A_C")
A_MAKEFILE_SHA256=$(hash_file "$A_MK")
A_GOTO_SHA256=$(hash_file "$A_GOTO")
B_HARNESS_SHA256=$(hash_file "$B_C")
B_MAKEFILE_SHA256=$(hash_file "$B_MK")
B_GOTO_SHA256=$(hash_file "$B_GOTO")
MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS
EOF

  echo "FINAL_SOURCE_INTEGRITY=PASS"
  echo "MONT02A_FULL_T2_FUNCTIONAL_GATE=PASS"
  echo "MONT_T2_A_ARBITRARY_PAIR_LAWS=PASS"
  echo "MONT_T2_B_AFFINE_FIBRE_LAWS=PASS"
  echo "MONT_T2_C1_NONVACUITY=PASS"
  echo "MONT_T2_C2_NONVACUITY=PASS"
  echo "MONT_T2_STATUS=FUNCTIONAL_AND_NONVACUITY_ACCEPTED_PENDING_T2_MUTATIONS"
  echo "NEXT_GATE=MONT-02B_T2_SPECIFIC_MUTATIONS"
  echo "MONT02A_R1_CAPTURE_END=YES"

  find "$OUT" -type f -print0 | sort -z | xargs -0 sha256sum > "$OUT/FILE_MANIFEST.sha256"

} 2>&1 | tee "$CAPTURE"

RC="${PIPESTATUS[0]}"
sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"

echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$RC"

exit "$RC"
