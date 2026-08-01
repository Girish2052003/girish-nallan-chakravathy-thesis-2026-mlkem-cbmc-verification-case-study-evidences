#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT03A_SOURCE_CAPTURE_$STAMP"
CAPTURE="$OUT/MONT03A_TERMINAL_CAPTURE_$STAMP.txt"

mkdir -p "$OUT"

section() {
  printf '\n============================================================\n'
  printf '%s\n' "$1"
  printf '============================================================\n'
}

print_context() {
  local file="$1"
  local line="$2"
  local start end
  start=$((line > 20 ? line - 20 : 1))
  end=$((line + 35))
  printf '\n--- %s:%s context ---\n' "$file" "$line"
  nl -ba "$AUTH/$file" | sed -n "${start},${end}p"
}

{
  section "MONT-03A — FQMUL SOURCE / CONTRACT / NATIVE-OVERLAP CAPTURE"
  echo "UTC_TIME=$STAMP"
  echo "AUTHORITATIVE_SOURCE=$AUTH"
  echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"

  section "G0 — SOURCE BINDING"
  if ! git -C "$AUTH" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "AUTHORITATIVE_GIT_GATE=FAIL"
    exit 20
  fi

  echo "AUTHORITATIVE_GIT_GATE=PASS"
  echo "AUTHORITATIVE_GIT_DIR=$(git -C "$AUTH" rev-parse --git-dir)"

  HEAD="$(git -C "$AUTH" rev-parse HEAD)"
  STATUS="$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all)"
  POLY_H="$(sha256sum "$AUTH/mlkem/src/poly.h" | awk '{print $1}')"
  POLY_C="$(sha256sum "$AUTH/mlkem/src/poly.c" | awk '{print $1}')"

  echo "AUTHORITATIVE_HEAD=$HEAD"
  echo "AUTHORITATIVE_STATUS_BEGIN"
  printf '%s\n' "$STATUS"
  echo "AUTHORITATIVE_STATUS_END"
  echo "POLY_H_SHA256=$POLY_H"
  echo "POLY_C_SHA256=$POLY_C"

  [[ "$HEAD" == "$EXPECTED_COMMIT" ]] || { echo "COMMIT_GATE=FAIL"; exit 21; }
  [[ -z "$STATUS" ]] || { echo "CLEAN_GATE=FAIL"; exit 22; }
  [[ "$POLY_H" == "$EXPECTED_POLY_H" ]] || { echo "POLY_H_GATE=FAIL"; exit 23; }
  [[ "$POLY_C" == "$EXPECTED_POLY_C" ]] || { echo "POLY_C_GATE=FAIL"; exit 24; }
  echo "SOURCE_BINDING_GATE=PASS"

  section "G1 — EXACT FQMUL AND REDUCTION LOCATIONS"
  mapfile -t FQMUL_MATCHES < <(git -C "$AUTH" grep -n -E 'mlk_fqmul[[:space:]]*\(' -- 'mlkem/src/*.c' 'mlkem/src/*.h' || true)
  mapfile -t MONT_MATCHES < <(git -C "$AUTH" grep -n -E 'mlk_montgomery_reduce[[:space:]]*\(' -- 'mlkem/src/*.c' 'mlkem/src/*.h' || true)

  echo "FQMUL_MATCH_COUNT=${#FQMUL_MATCHES[@]}"
  printf '%s\n' "${FQMUL_MATCHES[@]}"
  echo "MONT_REDUCE_MATCH_COUNT=${#MONT_MATCHES[@]}"
  printf '%s\n' "${MONT_MATCHES[@]}"

  (( ${#FQMUL_MATCHES[@]} > 0 )) || { echo "FQMUL_LOCATION_GATE=FAIL"; exit 25; }

  section "G2 — SOURCE CONTEXT"
  declare -A SEEN=()
  for entry in "${FQMUL_MATCHES[@]}" "${MONT_MATCHES[@]}"; do
    file="${entry%%:*}"
    rest="${entry#*:}"
    line="${rest%%:*}"
    key="$file:$line"
    [[ -n "${SEEN[$key]+x}" ]] && continue
    SEEN[$key]=1
    print_context "$file" "$line"
  done

  section "G3 — CONSTANTS AND TYPE CONTRACTS"
  git -C "$AUTH" grep -n -E 'MLKEM_Q|MONT|QINV|typedef.*int16|fqmul|montgomery' -- \
    'mlkem/src/*.h' 'mlkem/src/*.c' | head -n 240 || true

  section "G4 — NATIVE PROOF / HARNESS OVERLAP"
  NATIVE_COUNT="$(git -C "$AUTH" grep -n -i -E 'mlk_fqmul|fqmul' -- proofs 2>/dev/null | wc -l)"
  echo "NATIVE_FQMUL_REFERENCE_COUNT=$NATIVE_COUNT"
  git -C "$AUTH" grep -n -i -E 'mlk_fqmul|fqmul' -- proofs 2>/dev/null | head -n 240 || true

  section "G5 — CBMC BUILD CONTRACT"
  COMMON="$AUTH/proofs/cbmc/Makefile.common"
  if [[ -f "$COMMON" ]]; then
    echo "MAKEFILE_COMMON=$COMMON"
    grep -nE 'HARNESS_FILE|HARNESS_GOTO|^goto:|goto[^:]*:' "$COMMON" | head -n 160 || true
  else
    echo "MAKEFILE_COMMON_MISSING=YES"
  fi

  section "G6 — TOOL SNAPSHOT"
  cbmc --version 2>&1 | head -n 5 || true
  goto-cc --version 2>&1 | head -n 5 || true
  make --version 2>&1 | head -n 2 || true
  cc --version 2>&1 | head -n 3 || true

  section "G7 — FROZEN T3 FAMILY"
  cat <<'EOF'
MONT-T3.TARGET=mlk_fqmul
MONT-T3.P1=independent_multiplication_semantic_refinement
MONT-T3.P2=exact_commutativity
MONT-T3.P3=zero_annihilation_and_zero_product_reflection
MONT-T3.P4=Montgomery_one_identity_after_normalization
MONT-T3.P5=distributivity_after_normalization
MONT-T3.P6=associativity_after_normalization
MONT-T3.NO_WEAKENING=YES
MONT-T3.SEPARATE_DETACHED_WORKTREE=REQUIRED
MONT-T3.NATIVE_SOURCE_MODIFICATION=FORBIDDEN
EOF

  echo "MONT03A_CAPTURE_GATE=PASS"
  echo "NEXT_GATE=MONT-03B_HARNESS_FREEZE"
} 2>&1 | tee "$CAPTURE"

RC="${PIPESTATUS[0]}"
sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$RC"
exit "$RC"
