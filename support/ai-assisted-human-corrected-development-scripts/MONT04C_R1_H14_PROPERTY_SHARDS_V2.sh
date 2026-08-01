#!/usr/bin/env bash
set -u -o pipefail

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_POLY_H="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_POLY_C="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

AUTH="$HOME/THESIS-2026/mlkem-native_af4c5abd"
ROOT="$HOME/THESIS-2026/mlk_montgomery_cleanroom"
WT="$ROOT/MONT_T4_WORKTREE_af4c5abd_20260726T225651Z"

B_DIR="$ROOT/MONT04B_T4_HARNESS_FREEZE_20260726T225651Z"
B_CAPTURE="$B_DIR/MONT04B_TERMINAL_CAPTURE_20260726T225651Z.txt"
B_BINDING="$B_DIR/MONT04B_T4_FREEZE_BINDING.env"

H14_DIR="$WT/proofs/cbmc/mont_t4_p1_p4_roundtrip_zero"
H14_STEM="mont_t4_p1_p4_roundtrip_zero_harness"
H14_HARNESS="$H14_DIR/$H14_STEM.c"
H14_MAKEFILE="$H14_DIR/Makefile"
H14_GOTO="$H14_DIR/gotos/$H14_STEM.goto"

EXPECTED_B_CAPTURE="05c56c666de47585f0c3b0123661989a7f8bb8c266cb9c3fbfcaf7010a790509"
EXPECTED_B_BINDING="8f1304a854ddb3c9fefe6f101364b455bbb157a647991cd36b34f4bd7b24604e"
EXPECTED_HARNESS="2a4489df76b97cc03126f272f854bcfd3aa5b74f0268fffce77658d48a42194b"
EXPECTED_MAKEFILE="5177e1bdfd24c068ef28326e9ab7e2eafc532b13f2c039d05ffa8903afb97768"
EXPECTED_GOTO="9afe1a455c89e28e595e0bc51f997f086e466e69d178066f15d8fb26943a2857"

TIMEOUT_SECONDS=1800
UNWIND=257
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/MONT04C_R1_H14_SHARDS_$STAMP"
CAPTURE="$OUT/MONT04C_R1_TERMINAL_CAPTURE_$STAMP.txt"
mkdir -p "$OUT"

section(){ printf '\n============================================================\n%s\n============================================================\n' "$1"; }
hash(){ sha256sum "$1" | awk '{print $1}'; }
fail(){ echo "$1"; exit "$2"; }

property_id()
{
  local description="$1"
  python3 - "$description" "$OUT/H14_SHOW_PROPERTIES.txt" <<'PY'
from pathlib import Path
import re, sys
desc=sys.argv[1]
text=Path(sys.argv[2]).read_text(errors="replace")
blocks=re.split(r"(?m)^Property\s+", text)
matches=[]
for block in blocks[1:]:
    head, _, body=block.partition("\n")
    pid=head.rstrip(":").strip()
    if desc in body:
        matches.append(pid)
if len(matches)!=1:
    raise SystemExit(f"match_count={len(matches)} description={desc}")
print(matches[0])
PY
}

run_shard()
{
  local tag="$1"
  local desc="$2"
  local pid="$3"
  local log="$OUT/${tag}.log"
  timeout "$TIMEOUT_SECONDS" cbmc \
    --flush \
    --object-bits 8 \
    --reachability-slice \
    --slice-formula \
    --unwind "$UNWIND" \
    --trace \
    --property "$pid" \
    "$H14_GOTO" >"$log" 2>&1
  local rc=$?

  echo "${tag}_PROPERTY_ID=$pid"
  echo "${tag}_PROPERTY_DESCRIPTION=$desc"
  echo "${tag}_KEY_RESULTS_BEGIN"
  grep -E 'MONT-T4\.|VERIFICATION SUCCESSFUL|VERIFICATION FAILED|: FAILURE$|VERIFICATION ERROR|Out of memory' "$log" || true
  echo "${tag}_KEY_RESULTS_END"

  python3 - "$tag" "$desc" "$rc" "$log" <<'PY'
from pathlib import Path
import re, sys
tag,desc=sys.argv[1],sys.argv[2]
rc=int(sys.argv[3])
text=Path(sys.argv[4]).read_text(errors="replace")
fails=[x for x in text.splitlines() if re.search(r": FAILURE\s*$",x)]
target=f"{desc}: SUCCESS" in text
err=("VERIFICATION ERROR" in text or "\nERROR:" in text or
     "Caught exception" in text or "Out of memory" in text)
if rc==124:
    verdict="TIMEOUT_INCONCLUSIVE"; ok=False
elif rc==0 and "VERIFICATION SUCCESSFUL" in text and "VERIFICATION FAILED" not in text and target and not fails and not err:
    verdict="PASS"; ok=True
elif rc==10 and "VERIFICATION FAILED" in text and not err:
    verdict="COUNTEREXAMPLE"; ok=False
else:
    verdict="TOOL_OR_AUDIT_FAILURE"; ok=False
print(f"{tag}_DIRECT_RC={rc}")
print(f"{tag}_FAILURE_COUNT={len(fails)}")
print(f"{tag}_TARGET_SUCCESS={'YES' if target else 'NO'}")
print(f"{tag}_VERDICT={verdict}")
print(f"{tag}_AUDIT={'PASS' if ok else 'FAIL'}")
raise SystemExit(0 if ok else 1)
PY
}

{
  section "MONT-04C-R1 — H14 THEOREM-PRESERVING PROPERTY SHARDS"
  echo "UTC_TIME=$STAMP"
  echo "OUTPUT_DIRECTORY=$OUT"
  echo "TIMEOUT_SECONDS=$TIMEOUT_SECONDS"
  echo "UNWIND=$UNWIND"
  echo "FROZEN_GOTO_REUSED=YES"
  echo "THEOREM_DOMAIN_CHANGED=NO"

  section "R0 — EXACT EVIDENCE AND SOURCE BINDING"
  [[ -f "$B_CAPTURE" && -f "$B_CAPTURE.sha256" && -f "$B_BINDING" ]] || fail "MONT04B_PACKAGE_PRESENT=NO" 20
  [[ "$(hash "$B_CAPTURE")" == "$EXPECTED_B_CAPTURE" ]] || fail "MONT04B_CAPTURE_HASH_GATE=FAIL" 21
  [[ "$(awk 'NR==1{print $1}' "$B_CAPTURE.sha256")" == "$EXPECTED_B_CAPTURE" ]] || fail "MONT04B_SIDECAR_GATE=FAIL" 22
  [[ "$(hash "$B_BINDING")" == "$EXPECTED_B_BINDING" ]] || fail "MONT04B_BINDING_HASH_GATE=FAIL" 23

  [[ "$(git -C "$AUTH" rev-parse HEAD)" == "$EXPECTED_COMMIT" &&
     "$(git -C "$WT" rev-parse HEAD)" == "$EXPECTED_COMMIT" ]] || fail "COMMIT_GATE=FAIL" 24
  [[ -z "$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all)" ]] || fail "AUTHORITATIVE_CLEAN_GATE=FAIL" 25
  [[ "$(hash "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
     "$(hash "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
     "$(hash "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
     "$(hash "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" ]] || fail "SOURCE_HASH_GATE=FAIL" 26
  [[ "$(hash "$H14_HARNESS")" == "$EXPECTED_HARNESS" &&
     "$(hash "$H14_MAKEFILE")" == "$EXPECTED_MAKEFILE" &&
     "$(hash "$H14_GOTO")" == "$EXPECTED_GOTO" ]] || fail "H14_ARTEFACT_HASH_GATE=FAIL" 27
  echo "MONT04B_PACKAGE_BINDING=PASS"
  echo "SOURCE_AND_H14_BINDING=PASS"

  section "R1 — PROPERTY-ID DISCOVERY"
  cbmc --show-properties "$H14_GOTO" >"$OUT/H14_SHOW_PROPERTIES.txt" 2>&1
  [[ "$?" -eq 0 ]] || fail "SHOW_PROPERTIES_GATE=FAIL" 28

  P1_DESC="MONT-T4.P1.de_Montgomery_round_trip"
  P4_DESC="MONT-T4.P4.zero_support_preservation"
  S_DESC="MONT-T4.SUPPORT.forward_representation_congruence"
  P1_ID="$(property_id "$P1_DESC")" || fail "P1_ID_DISCOVERY=FAIL" 29
  P4_ID="$(property_id "$P4_DESC")" || fail "P4_ID_DISCOVERY=FAIL" 30
  S_ID="$(property_id "$S_DESC")" || fail "SUPPORT_ID_DISCOVERY=FAIL" 31
  echo "P1_PROPERTY_ID=$P1_ID"
  echo "P4_PROPERTY_ID=$P4_ID"
  echo "SUPPORT_PROPERTY_ID=$S_ID"
  echo "PROPERTY_ID_DISCOVERY=PASS_3_OF_3"

  section "R2 — P1 ROUND-TRIP SHARD"
  run_shard "T4_P1_SHARD" "$P1_DESC" "$P1_ID" || fail "T4_P1_SHARD_GATE=FAIL" 32

  section "R3 — P4 ZERO-SUPPORT SHARD"
  run_shard "T4_P4_SHARD" "$P4_DESC" "$P4_ID" || fail "T4_P4_SHARD_GATE=FAIL" 33

  section "R4 — SUPPORTING FORWARD-CONGRUENCE SHARD"
  run_shard "T4_SUPPORT_SHARD" "$S_DESC" "$S_ID" || fail "T4_SUPPORT_SHARD_GATE=FAIL" 34

  section "R5 — FINAL INTEGRITY"
  [[ "$(hash "$AUTH/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
     "$(hash "$AUTH/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
     "$(hash "$WT/mlkem/src/poly.h")" == "$EXPECTED_POLY_H" &&
     "$(hash "$WT/mlkem/src/poly.c")" == "$EXPECTED_POLY_C" &&
     "$(hash "$H14_HARNESS")" == "$EXPECTED_HARNESS" &&
     "$(hash "$H14_MAKEFILE")" == "$EXPECTED_MAKEFILE" &&
     "$(hash "$H14_GOTO")" == "$EXPECTED_GOTO" ]] || fail "FINAL_INTEGRITY_GATE=FAIL" 35
  [[ -z "$(git -C "$AUTH" status --porcelain=v1 --untracked-files=all)" ]] || fail "FINAL_AUTHORITATIVE_CLEAN_GATE=FAIL" 36

  BIND="$OUT/MONT04C_R1_H14_BINDING.env"
  cat >"$BIND" <<EOF
MONT04B_CAPTURE_SHA256=$EXPECTED_B_CAPTURE
MONT04B_BINDING_SHA256=$EXPECTED_B_BINDING
H14_HARNESS_SHA256=$EXPECTED_HARNESS
H14_MAKEFILE_SHA256=$EXPECTED_MAKEFILE
H14_GOTO_SHA256=$EXPECTED_GOTO
P1_PROPERTY_ID=$P1_ID
P4_PROPERTY_ID=$P4_ID
SUPPORT_PROPERTY_ID=$S_ID
MONT04C_R1_H14_PROPERTY_SHARD_GATE=PASS_3_OF_3
MONT_T4_THEOREM_DOMAIN_CHANGED=NO
MONT_T4_THEOREM_WEAKENED=NO
EOF
  echo "MONT04C_R1_BINDING_FILE=$BIND"
  echo "MONT04C_R1_BINDING_SHA256=$(hash "$BIND")"
  echo "FINAL_SOURCE_INTEGRITY=PASS"
  echo "FINAL_AUTHORITATIVE_CLEAN_GATE=PASS"
  echo "FINAL_H14_FROZEN_ARTEFACT_INTEGRITY=PASS"
  echo "MONT04C_R1_H14_PROPERTY_SHARD_GATE=PASS_3_OF_3"
  echo "MONT_T4_P1_VERIFIED=YES"
  echo "MONT_T4_P4_VERIFIED=YES"
  echo "MONT_T4_SUPPORTING_FORWARD_LEMMA_VERIFIED=YES"
  echo "MONT_T4_THEOREM_DOMAIN_CHANGED=NO"
  echo "MONT_T4_THEOREM_WEAKENED=NO"
  echo "NEXT_GATE=MONT-04C-R2_H235_PROPERTY_SHARDS"
  echo "MONT04C_R1_CAPTURE_END=YES"
} 2>&1 | tee "$CAPTURE"

RC="${PIPESTATUS[0]}"
sha256sum "$CAPTURE" | tee "$CAPTURE.sha256"
echo "CAPTURE_FILE=$CAPTURE"
echo "CAPTURE_HASH_FILE=$CAPTURE.sha256"
echo "SCRIPT_EXIT=$RC"
exit "$RC"
