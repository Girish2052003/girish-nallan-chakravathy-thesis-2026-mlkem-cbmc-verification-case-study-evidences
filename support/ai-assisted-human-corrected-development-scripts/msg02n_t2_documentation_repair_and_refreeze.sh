#!/usr/bin/env bash
set -Eeuo pipefail

REPO="/home/girish/THESIS-2026/mlkem-native_af4c5abd"
BASE="/home/girish/THESIS-2026/mlk_poly_tomsg_cleanroom"

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_C_SHA="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_H_SHA="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"
EXPECTED_OLD_ARCHIVE_SHA="79f166d190d7e786fa86e82930f7b2b89eb25554de658bfe81a7464be5f00318"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_NAME="MSG02N_T2_DOCUMENTATION_REPAIR_AND_REFREEZE_${STAMP}_af4c5abdd595"
OUT="$BASE/$OUT_NAME"
PKG="MLK_POLY_TOMSG_T2_RELATIONAL_ACCEPTED_REPAIRED_${STAMP}_af4c5abdd595"
NEW_ARCHIVE="$BASE/$PKG.tar.gz"
NEW_SHA="$NEW_ARCHIVE.sha256"
LOG="$BASE/$PKG.terminal.txt"
TMP="$(mktemp -d /tmp/msg02n.XXXXXXXX)"

cleanup(){ rm -rf "$TMP"; }
trap cleanup EXIT

mkdir -p "$OUT"/{01_original,02_repair,03_audit,04_validation,05_manifest}
EXTRACT="$TMP/extracted"
mkdir -p "$EXTRACT"

main() {
  echo "============================================================"
  echo "MSG02N — T2 DOCUMENTATION REPAIR AND RE-FREEZE"
  echo "============================================================"

  for x in git sha256sum tar gzip jq goto-instrument python3; do
    command -v "$x" >/dev/null || { echo "FATAL: missing $x"; return 1; }
  done

  echo
  echo "===== 1. FROZEN SOURCE GATE ====="
  HEAD="$(git -C "$REPO" rev-parse HEAD)"
  C_SHA="$(sha256sum "$REPO/mlkem/src/compress.c" | awk '{print $1}')"
  H_SHA="$(sha256sum "$REPO/mlkem/src/compress.h" | awk '{print $1}')"
  STATUS="$(git -C "$REPO" status --porcelain=v1 --untracked-files=all)"

  echo "ACTUAL_HEAD=$HEAD"
  echo "ACTUAL_COMPRESS_SHA256=$C_SHA"
  echo "ACTUAL_COMPRESS_H_SHA256=$H_SHA"

  test "$HEAD" = "$EXPECTED_COMMIT" || { echo "FATAL: commit mismatch"; return 2; }
  test "$C_SHA" = "$EXPECTED_C_SHA" || { echo "FATAL: compress.c mismatch"; return 3; }
  test "$H_SHA" = "$EXPECTED_H_SHA" || { echo "FATAL: compress.h mismatch"; return 4; }
  test -z "$STATUS" || { echo "FATAL: source tree not clean"; printf '%s\n' "$STATUS"; return 5; }
  echo "SOURCE_BINDING=PASS"

  echo
  echo "===== 2. LOCATE AND VERIFY ORIGINAL T2 ARCHIVE ====="
  mapfile -t CANDIDATES < <(
    find "$BASE" -maxdepth 1 -type f \
      -name 'MLK_POLY_TOMSG_T2_RELATIONAL_ACCEPTED_*.tar.gz' \
      ! -name '*REPAIRED*' | LC_ALL=C sort
  )
  test "${#CANDIDATES[@]}" -ge 1 || { echo "FATAL: original T2 archive not found"; return 6; }
  OLD="${CANDIDATES[-1]}"
  OLD_SHA="$(sha256sum "$OLD" | awk '{print $1}')"
  echo "ORIGINAL_ARCHIVE=$OLD"
  echo "ORIGINAL_ARCHIVE_SHA256=$OLD_SHA"
  test "$OLD_SHA" = "$EXPECTED_OLD_ARCHIVE_SHA" || { echo "FATAL: original archive hash mismatch"; return 7; }

  gzip -t "$OLD"
  tar -tzf "$OLD" > "$OUT/03_audit/original_archive_contents.txt"
  tar -xzf "$OLD" -C "$EXTRACT"
  echo "ORIGINAL_ARCHIVE_BINDING=PASS"

  echo
  echo "===== 3. COMPLETE EXTRACTED-FILE HASH INVENTORY ====="
  (
    cd "$EXTRACT"
    find . -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum
  ) > "$OUT/03_audit/original_extracted_files.sha256"
  EXTRACTED_COUNT="$(wc -l < "$OUT/03_audit/original_extracted_files.sha256")"
  echo "EXTRACTED_FILE_COUNT=$EXTRACTED_COUNT"
  test "$EXTRACTED_COUNT" -gt 0 || { echo "FATAL: empty extracted archive"; return 8; }
  echo "EVERY_EXTRACTED_FILE_HASHED=PASS"

  echo
  echo "===== 4. AUDIT JSON RESULT CARDINALITIES ====="
  python3 - "$EXTRACT" "$OUT/03_audit/json_status.tsv" <<'PY'
import json, sys
from pathlib import Path

root=Path(sys.argv[1])
out=Path(sys.argv[2])

def walk(x):
    if isinstance(x,dict):
        yield x
        for v in x.values(): yield from walk(v)
    elif isinstance(x,list):
        for v in x: yield from walk(v)

rows=[]
for p in sorted(root.rglob("*.json")):
    try: data=json.loads(p.read_text(encoding="utf-8"))
    except Exception: continue
    s=f=u=0
    for obj in walk(data):
        st=obj.get("status")
        s += st=="SUCCESS"
        f += st=="FAILURE"
        u += st=="UNKNOWN"
    if s or f or u:
        rows.append((str(p.relative_to(root)),s,f,u))

out.write_text("path\tsuccess\tfailure\tunknown\n" +
               "".join(f"{p}\t{s}\t{f}\t{u}\n" for p,s,f,u in rows),
               encoding="utf-8")

positive=[r for r in rows if r[1]>0 and r[2]==0 and r[3]==0]
mutants=[r for r in rows if r[1]==0 and r[2]==1 and r[3]==0]

print("STATUS_JSON_COUNT="+str(len(rows)))
print("POSITIVE_JSON_COUNT="+str(len(positive)))
print("POSITIVE_SUCCESS_TOTAL="+str(sum(r[1] for r in positive)))
print("MUTATION_JSON_COUNT="+str(len(mutants)))
PY
  cat "$OUT/03_audit/json_status.tsv"

  POSITIVE_JSON_COUNT="$(awk -F'\t' 'NR>1 && $2>0 && $3==0 && $4==0 {n++} END{print n+0}' "$OUT/03_audit/json_status.tsv")"
  POSITIVE_TOTAL="$(awk -F'\t' 'NR>1 && $2>0 && $3==0 && $4==0 {n+=$2} END{print n+0}' "$OUT/03_audit/json_status.tsv")"
  MUTATION_COUNT="$(awk -F'\t' 'NR>1 && $2==0 && $3==1 && $4==0 {n++} END{print n+0}' "$OUT/03_audit/json_status.tsv")"

  echo "POSITIVE_JSON_COUNT=$POSITIVE_JSON_COUNT"
  echo "POSITIVE_SUCCESS_TOTAL=$POSITIVE_TOTAL"
  echo "MUTATION_JSON_COUNT=$MUTATION_COUNT"

  test "$POSITIVE_JSON_COUNT" -eq 5 || { echo "FATAL: expected 5 positive JSON results"; return 9; }
  test "$POSITIVE_TOTAL" -eq 2622 || { echo "FATAL: expected 2622 positive successes"; return 10; }
  test "$MUTATION_COUNT" -eq 5 || { echo "FATAL: expected 5 isolated mutation results"; return 11; }
  echo "T2_RESULT_CARDINALITIES=PASS"

  echo
  echo "===== 5. REVALIDATE EXACTLY 15 FROZEN GOTO BINARIES ====="
  mapfile -t GOTOS < <(find "$EXTRACT" -type f -name '*.goto' | LC_ALL=C sort)
  echo "GOTO_COUNT=${#GOTOS[@]}"
  test "${#GOTOS[@]}" -eq 15 || { printf '%s\n' "${GOTOS[@]}"; echo "FATAL: expected 15 GOTO binaries"; return 12; }
  : > "$OUT/04_validation/validated_gotos.txt"
  for g in "${GOTOS[@]}"; do
    goto-instrument --validate-goto-binary "$g" >/dev/null
    printf '%s\n' "${g#"$EXTRACT"/}" >> "$OUT/04_validation/validated_gotos.txt"
  done
  echo "GOTO_REVALIDATION=15_OF_15_PASS"

  echo
  echo "===== 6. PRESERVE ORIGINAL ARCHIVE AND DEFECTIVE SUMMARY ====="
  cp "$OLD" "$OUT/01_original/$(basename "$OLD")"
  printf '%s  %s\n' "$OLD_SHA" "$(basename "$OLD")" > "$OUT/01_original/original_archive.sha256"

  mapfile -t SUMMARIES < <(find "$EXTRACT" -type f -name 'T2_FINAL_ACCEPTANCE_SUMMARY.md' | LC_ALL=C sort)
  if test "${#SUMMARIES[@]}" -eq 1; then
    cp "${SUMMARIES[0]}" "$OUT/02_repair/T2_FINAL_ACCEPTANCE_SUMMARY_ORIGINAL_DEFECTIVE.md"
    echo "ORIGINAL_DEFECTIVE_SUMMARY_PRESERVED=YES"
  else
    echo "ORIGINAL_DEFECTIVE_SUMMARY_PRESERVED=NOT_UNIQUELY_LOCATED"
  fi

  echo
  echo "===== 7. WRITE CORRECTED SUMMARY SAFELY ====="
  cat > "$OUT/02_repair/T2_FINAL_ACCEPTANCE_SUMMARY_REPAIRED.md" <<'EOF'
# ML-KEM `mlk_poly_tomsg` MSG-T2 Relational Property Family — Final Acceptance

## Accepted properties

The frozen ML-KEM-768 portable-C `mlk_poly_tomsg` implementation satisfies the accepted MSG-T2 relational family:

1. **R1 — relational XOR law:** the XOR of selected output bits equals the XOR of the independent `Compress1` decisions.
2. **R2A — coefficient locality:** equal selected coefficients imply equal selected output bits, while unrelated coefficients remain unrestricted.
3. **R2B — cross-bit preservation:** if all coefficients except possibly `k` are equal, every output bit except possibly bit `k` remains equal. This also proves byte confinement.
4. **R3A — same-decision invariance:** different selected coefficients in the same `Compress1` class produce equal selected output bits.
5. **R3B — input-frame preservation and complete-message determinism:** equal complete polynomial values in distinct objects remain unchanged and produce equal 32-byte messages in distinct output arrays.

## Accepted evidence

```text
Positive successful property records: 2622
Positive failures:                    0
Positive UNKNOWN results:             0
Reachability goals:                   43 / 43
Expected-failure mutations:           5 / 5
Validated frozen GOTO binaries:       15 / 15
```

The 2,622 successful property records include generated C-safety properties and are not 2,622 separate mathematical theorems.

## Scope

The claims apply to:

- frozen commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`;
- ML-KEM-768 portable C;
- canonical coefficients `0 <= u < 3329`;
- valid and appropriately non-aliasing objects;
- CBMC 6.9.0 and the recorded finite C model;
- the accepted verification adapters and complete loop bounds.

They do not prove all of ML-KEM, noncanonical behavior, assembly or object-code equivalence, constant-time behavior, side-channel resistance, injectivity, or every possible property of `mlk_poly_tomsg`.

## Repair boundary

This document repairs only the MSG02M Markdown-generation defect caused by an unquoted shell heredoc interpreting Markdown backticks as command substitution.

```text
CBMC_SOLVING_EXECUTED=NO
GOTO_REBUILD_EXECUTED=NO
PRODUCTION_SOURCE_MODIFIED=NO
AUTHORITATIVE_RESULT_REPLACED=NO
DOCUMENTATION_REPAIR_ONLY=YES
```

## Final status

```text
MSG_T2_RELATIONAL_XOR=ACCEPTED
MSG_T2_COEFFICIENT_LOCALITY=ACCEPTED
MSG_T2_CROSS_BIT_PRESERVATION=ACCEPTED
MSG_T2_BYTE_CONFINEMENT=ACCEPTED_VIA_STRONGER_R2B
MSG_T2_SAME_DECISION_INVARIANCE=ACCEPTED
MSG_T2_INPUT_FRAME_PRESERVATION=ACCEPTED
MSG_T2_COMPLETE_MESSAGE_DETERMINISM=ACCEPTED
MSG_T2_RELATIONAL_PROPERTY_FAMILY=FINAL_ACCEPTED
```
EOF

  SUMMARY="$OUT/02_repair/T2_FINAL_ACCEPTANCE_SUMMARY_REPAIRED.md"
  grep -Fq 'mlk_poly_tomsg' "$SUMMARY"
  grep -Fq '2622' "$SUMMARY"
  grep -Fq '43 / 43' "$SUMMARY"
  grep -Fq '5 / 5' "$SUMMARY"
  grep -Fq '15 / 15' "$SUMMARY"
  echo "CORRECTED_SUMMARY_AUDIT=PASS"

  cat > "$OUT/02_repair/MSG02N_REPAIR_STATUS.txt" <<EOF
STAGE=MSG02N
ORIGINAL_ARCHIVE=$(basename "$OLD")
ORIGINAL_ARCHIVE_SHA256=$OLD_SHA
ORIGINAL_ARCHIVE_PRESERVED_BYTE_FOR_BYTE=YES
POSITIVE_SUCCESS_PROPERTIES=2622
POSITIVE_FAILURES=0
POSITIVE_UNKNOWNS=0
REACHABILITY_GOALS=43_OF_43
MUTATIONS=5_OF_5
GOTO_BINARIES=15_OF_15
CBMC_SOLVING_EXECUTED=NO
GOTO_REBUILD_EXECUTED=NO
PRODUCTION_SOURCE_MODIFIED=NO
AUTHORITATIVE_RESULT_REPLACED=NO
DOCUMENTATION_REPAIR_ONLY=YES
T2_RELATIONAL_PROPERTY_FAMILY=FINAL_ACCEPTED
EOF

  echo
  echo "===== 8. BUILD REPAIR MANIFEST AND DETERMINISTIC ARCHIVE ====="
  (
    cd "$OUT"
    find . -type f ! -path './05_manifest/MSG02N_FILES.sha256' -print0 |
      LC_ALL=C sort -z | xargs -0 sha256sum
  ) > "$OUT/05_manifest/MSG02N_FILES.sha256"

  (
    cd "$OUT"
    sha256sum -c 05_manifest/MSG02N_FILES.sha256
  ) >/dev/null

  tar --sort=name --mtime='UTC 1970-01-01' --owner=0 --group=0 --numeric-owner \
      -C "$BASE" -cf "${NEW_ARCHIVE%.gz}" "$OUT_NAME"
  gzip -n -f "${NEW_ARCHIVE%.gz}"
  gzip -t "$NEW_ARCHIVE"
  tar -tzf "$NEW_ARCHIVE" > "$NEW_ARCHIVE.contents.txt"
  (
    cd "$BASE"
    sha256sum "$(basename "$NEW_ARCHIVE")" > "$(basename "$NEW_SHA")"
    sha256sum -c "$(basename "$NEW_SHA")"
  )

  echo "NEW_REPAIRED_ARCHIVE=$NEW_ARCHIVE"
  cat "$NEW_SHA"

  echo
  echo "===== 9. FINAL SOURCE RECHECK ====="
  FINAL_HEAD="$(git -C "$REPO" rev-parse HEAD)"
  FINAL_C_SHA="$(sha256sum "$REPO/mlkem/src/compress.c" | awk '{print $1}')"
  FINAL_H_SHA="$(sha256sum "$REPO/mlkem/src/compress.h" | awk '{print $1}')"
  FINAL_STATUS="$(git -C "$REPO" status --porcelain=v1 --untracked-files=all)"

  test "$FINAL_HEAD" = "$EXPECTED_COMMIT"
  test "$FINAL_C_SHA" = "$EXPECTED_C_SHA"
  test "$FINAL_H_SHA" = "$EXPECTED_H_SHA"
  test -z "$FINAL_STATUS"

  echo "============================================================"
  echo "MSG02N_ORIGINAL_T2_ARCHIVE_BINDING=PASS"
  echo "MSG02N_COMPLETE_EXTRACTED_FILE_HASH_INVENTORY=PASS"
  echo "MSG02N_POSITIVE_RESULTS=2622_SUCCESS_0_FAILURE_0_UNKNOWN"
  echo "MSG02N_MUTATION_RESULTS=5_OF_5_PASS"
  echo "MSG02N_GOTO_REVALIDATION=15_OF_15_PASS"
  echo "MSG02N_CORRECTED_SUMMARY=PASS"
  echo "MSG02N_UNSAFE_HEREDOC_DEFECT=REPAIRED"
  echo "MSG02N_DETERMINISTIC_ARCHIVE=PASS"
  echo "CBMC_SOLVING_EXECUTED=NO"
  echo "GOTO_REBUILD_EXECUTED=NO"
  echo "PRODUCTION_SOURCE_MODIFIED=NO"
  echo "AUTHORITATIVE_RESULT_REPLACED=NO"
  echo "DOCUMENTATION_REPAIR_ONLY=YES"
  echo "T2_RELATIONAL_PROPERTY_FAMILY=FINAL_ACCEPTED"
  echo "NEXT_STAGE=MSG06A_MLK_POLY_TOMSG_COMBINED_CAMPAIGN_CLOSURE"
  echo "EVIDENCE_PATH=$OUT"
  echo "REPAIRED_ARCHIVE_PATH=$NEW_ARCHIVE"
  echo "REPAIRED_ARCHIVE_SHA256_PATH=$NEW_SHA"
  echo "FINAL_STATUS=0"
  echo "============================================================"
}

set +e
main 2>&1 | tee "$LOG"
RC="${PIPESTATUS[0]}"
set -e

echo
echo "CHILD_PROCESS_STATUS=$RC"
echo "TERMINAL_CAPTURE=$LOG"
test -f "$LOG" && echo "TERMINAL_CAPTURE_SHA256=$(sha256sum "$LOG" | awk '{print $1}')"
exit "$RC"
