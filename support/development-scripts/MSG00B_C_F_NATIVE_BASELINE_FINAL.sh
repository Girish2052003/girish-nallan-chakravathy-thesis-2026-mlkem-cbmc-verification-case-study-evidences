#!/usr/bin/env bash

set -Eeuo pipefail

REPO="/home/girish/THESIS-2026/mlkem-native_af4c5abd"
EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

ROOT="$HOME/THESIS-2026/mlk_poly_tomsg_cleanroom/MSG00_af4c5ab"
STAGE="$ROOT/MSG00B_C_F_NATIVE_BASELINE_MLKEM768_RUN1"
WORK_STAGE="${STAGE}.INPROGRESS"

INVENTORY="$HOME/THESIS-2026/MSG00A_R2_af4c5ab_poly_tomsg_inventory.txt"
PROOF="$REPO/proofs/cbmc/poly_tomsg"
GOTO="$PROOF/gotos/poly_tomsg_harness.goto"

UTC_START="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

echo "============================================================"
echo "MSG-00B/C/F: OVERLAP + FIPS ORACLE + NATIVE BASELINE"
echo "============================================================"
echo "REPO=$REPO"
echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
echo "STAGE=$STAGE"
echo

# -----------------------------------------------------------------------------
# 0. Non-mutating preflight
# -----------------------------------------------------------------------------
[ -d "$REPO" ] || fail "repository directory does not exist: $REPO"
git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1 || \
  fail "repository path is not a valid Git worktree: $REPO"

ACTUAL_COMMIT="$(git -C "$REPO" rev-parse HEAD)"
[ "$ACTUAL_COMMIT" = "$EXPECTED_COMMIT" ] || \
  fail "commit mismatch: actual=$ACTUAL_COMMIT expected=$EXPECTED_COMMIT"

WORKTREE_STATE="$(git -C "$REPO" status --porcelain=v1)"
[ -z "$WORKTREE_STATE" ] || {
  echo "ERROR: tracked worktree is not clean" >&2
  git -C "$REPO" status --short >&2
  exit 1
}

[ -f "$INVENTORY" ] || fail "accepted MSG-00A inventory is missing: $INVENTORY"
[ -d "$PROOF" ] || fail "native proof directory is missing: $PROOF"
[ ! -e "$STAGE" ] || fail "final stage already exists: $STAGE"
[ ! -e "$WORK_STAGE" ] || fail "stale in-progress stage already exists: $WORK_STAGE"

for TOOL in git sha256sum python3 make cbmc goto-cc goto-instrument litani; do
  command -v "$TOOL" >/dev/null 2>&1 || fail "required tool unavailable: $TOOL"
done

echo "PREFLIGHT_COMMIT_BINDING=PASS"
echo "PREFLIGHT_WORKTREE_CLEAN=PASS"
echo "PREFLIGHT_INVENTORY=PASS"
echo "PREFLIGHT_TOOLS=PASS"

mkdir -p \
  "$WORK_STAGE/00_source_binding" \
  "$WORK_STAGE/01_source_snapshot" \
  "$WORK_STAGE/02_overlap_audit" \
  "$WORK_STAGE/03_fips_oracle" \
  "$WORK_STAGE/04_native_baseline/logs" \
  "$WORK_STAGE/05_goto_inspection"

on_exit() {
  local rc=$?
  trap - EXIT
  if [ "$rc" -ne 0 ] && [ -d "$WORK_STAGE" ]; then
    {
      echo "STAGE_STATUS=FAILED"
      echo "EXIT_CODE=$rc"
      echo "UTC_FAILURE=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
      echo "FINAL_STAGE_NOT_CREATED=YES"
      echo "INPROGRESS_STAGE=$WORK_STAGE"
    } > "$WORK_STAGE/FAILURE.txt"
    echo
    echo "FAILED: evidence retained only at:"
    echo "$WORK_STAGE"
  fi
  exit "$rc"
}
trap on_exit EXIT

cp -- "$INVENTORY" "$WORK_STAGE/00_source_binding/"

CBMC_VERSION="$(cbmc --version 2>&1 | sed -n '1p')"
GOTO_CC_VERSION="$(goto-cc --version 2>&1 | sed -n '1p')"
GOTO_INSTRUMENT_VERSION="$(goto-instrument --version 2>&1 | sed -n '1p')"
LITANI_PATH="$(command -v litani)"

{
  echo "STAGE_ID=MSG00B_C_F_NATIVE_BASELINE_MLKEM768_RUN1"
  echo "UTC_START=$UTC_START"
  echo "REPO=$REPO"
  echo "ACTUAL_COMMIT=$ACTUAL_COMMIT"
  echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
  echo "COMMIT_BINDING=PASS"
  echo "WORKTREE_CLEAN_BEFORE=YES"
  echo "CBMC_VERSION=$CBMC_VERSION"
  echo "GOTO_CC_VERSION=$GOTO_CC_VERSION"
  echo "GOTO_INSTRUMENT_VERSION=$GOTO_INSTRUMENT_VERSION"
  echo "LITANI_PATH=$LITANI_PATH"
  echo "PARAMETER_CONFIGURATION=MLKEM768"
  echo "MLKEM_K=3"
  echo "FIPS_N=256"
  echo "FIPS_Q=3329"
} | tee "$WORK_STAGE/00_source_binding/STAGE_BINDING.txt"

# -----------------------------------------------------------------------------
# 1. Freeze relevant source and proof configuration
# -----------------------------------------------------------------------------
echo
echo "=== FREEZING RELEVANT SOURCE AND PROOF FILES ==="

FILES=(
  "mlkem/src/compress.c"
  "mlkem/src/compress.h"
  "mlkem/src/poly.c"
  "mlkem/src/poly.h"
  "mlkem/src/params.h"
  "mlkem/src/common.h"
  "mlkem/src/indcpa.c"
  "proofs/cbmc/Makefile.common"
  "proofs/cbmc/Makefile_params.common"
  "proofs/cbmc/poly_tomsg/Makefile"
  "proofs/cbmc/poly_tomsg/poly_tomsg_harness.c"
  "proofs/cbmc/scalar_compress_d1/Makefile"
  "proofs/cbmc/scalar_compress_d1/scalar_compress_d1_harness.c"
)

for FILE in "${FILES[@]}"; do
  DEST="$WORK_STAGE/01_source_snapshot/$FILE"
  mkdir -p "$(dirname "$DEST")"
  git -C "$REPO" show "$EXPECTED_COMMIT:$FILE" > "$DEST" || \
    fail "could not freeze repository file: $FILE"
done

(
  cd "$WORK_STAGE/01_source_snapshot"
  find . -type f ! -name 'SOURCE_SNAPSHOT.sha256' -print0 |
    sort -z |
    xargs -0 sha256sum
) > "$WORK_STAGE/01_source_snapshot/SOURCE_SNAPSHOT.sha256"

(
  cd "$WORK_STAGE/01_source_snapshot"
  sha256sum -c SOURCE_SNAPSHOT.sha256
) > "$WORK_STAGE/01_source_snapshot/SOURCE_SNAPSHOT_VALIDATION.txt"

echo "SOURCE_SNAPSHOT=COMPLETE"
echo "SOURCE_SNAPSHOT_VALIDATION=PASS"

# -----------------------------------------------------------------------------
# 2. Repository-native overlap audit
# -----------------------------------------------------------------------------
echo
echo "=== REPOSITORY-NATIVE OVERLAP AUDIT ==="

{
  echo "============================================================"
  echo "REPOSITORY-NATIVE POLY_TOMSG OVERLAP AUDIT"
  echo "============================================================"
  echo "COMMIT=$EXPECTED_COMMIT"
  echo

  echo "=== NATIVE PROOF CONFIGURATION ==="
  git -C "$REPO" show \
    "$EXPECTED_COMMIT:proofs/cbmc/poly_tomsg/Makefile"

  echo
  echo "=== ALL POLY_TOMSG PROOF REFERENCES ==="
  git -C "$REPO" grep -n -E \
    'mlk_poly_tomsg|poly_tomsg|mlk_scalar_compress_d1' \
    "$EXPECTED_COMMIT" -- proofs/cbmc || true

  echo
  echo "=== ALL RELEVANT ASSERTION OR ENSURES REFERENCES ==="
  git -C "$REPO" grep -n -E \
    'ByteEncode_1|Compress_1|expected_bit|coefficient locality|non.interference|complete overwrite|determinism' \
    "$EXPECTED_COMMIT" -- proofs mlkem || true

  echo
  echo "=== NATIVE HARNESS ==="
  git -C "$REPO" show \
    "$EXPECTED_COMMIT:proofs/cbmc/poly_tomsg/poly_tomsg_harness.c"

  echo
  echo "=== FUNCTION CONTRACT ==="
  git -C "$REPO" show "$EXPECTED_COMMIT:mlkem/src/compress.h" |
    grep -n -A28 -B10 'void mlk_poly_tomsg' || true

  echo
  echo "=== SCALAR COMPRESS_D1 CONTRACT ==="
  git -C "$REPO" show "$EXPECTED_COMMIT:mlkem/src/compress.h" |
    grep -n -A28 -B10 'mlk_scalar_compress_d1' || true

  echo
  echo "=== PRODUCTION BODY ==="
  git -C "$REPO" show "$EXPECTED_COMMIT:mlkem/src/compress.c" |
    grep -n -A36 -B10 'void mlk_poly_tomsg' || true
} > "$WORK_STAGE/02_overlap_audit/REPOSITORY_NATIVE_OVERLAP.txt"

grep -n -E \
  'HARNESS_|CHECK_FUNCTION_CONTRACTS|USE_FUNCTION_CONTRACTS|APPLY_LOOP_CONTRACTS|USE_DYNAMIC_FRAMES|CBMCFLAGS|mlk_poly_tomsg|poly_tomsg|ensures|expected_bit|locality|non.interference|overwrite|determinism' \
  "$WORK_STAGE/02_overlap_audit/REPOSITORY_NATIVE_OVERLAP.txt" |
  head -n 220 \
  > "$WORK_STAGE/02_overlap_audit/OVERLAP_KEY_LINES.txt" || true

cat > "$WORK_STAGE/02_overlap_audit/PRELIMINARY_BOUNDARY.md" <<'BOUNDARY'
# Preliminary repository-native overlap boundary

This finding is limited to the frozen mlkem-native commit and does not claim
universal literature novelty.

## Native proof already present

The frozen repository contains:

- a CBMC harness that invokes `mlk_poly_tomsg`;
- a function-contract proof configuration for `mlk_poly_tomsg`;
- canonical-domain and separation preconditions in the production contract;
- an assigns clause for the 32-byte output;
- a scalar `mlk_scalar_compress_d1` arithmetic contract;
- loop-contract instrumentation and ordinary CBMC safety checks.

## Candidate research properties not directly stated by that native contract

The inspected `mlk_poly_tomsg` contract does not directly state:

- whole-message equality with an independently implemented FIPS oracle;
- exact coefficient-to-byte and coefficient-to-bit mapping;
- relational coefficient locality;
- cross-bit non-interference;
- independence from the initial output-buffer contents;
- complete overwrite demonstrated by a two-run relational property;
- full subtract-reduce-decode composition.

These candidate properties require separate harnesses and CBMC proof obligations.
BOUNDARY

echo "REPOSITORY_OVERLAP_AUDIT=RECORDED"

# -----------------------------------------------------------------------------
# 3. Exhaustive FIPS Compress_1 oracle validation
# -----------------------------------------------------------------------------
echo
echo "=== EXHAUSTIVELY CHECKING THE FIPS COMPRESS_1 ORACLE ==="

cat > "$WORK_STAGE/03_fips_oracle/check_fips_compress1.py" <<'PY'
#!/usr/bin/env python3

from pathlib import Path

Q = 3329


def exact_rational_round(x: int) -> int:
    """Round 2*x/Q to nearest integer; Q is odd, so no tie is possible."""
    if not 0 <= x < Q:
        raise ValueError(f"non-canonical coefficient: {x}")

    quotient, remainder = divmod(2 * x, Q)
    rounded = quotient + (1 if 2 * remainder > Q else 0)
    return rounded % 2


def integer_formula(x: int) -> int:
    """Equivalent integer realization for canonical x."""
    if not 0 <= x < Q:
        raise ValueError(f"non-canonical coefficient: {x}")
    return ((2 * x + Q // 2) // Q) % 2


def threshold_oracle(x: int) -> int:
    """Independent threshold partition for q=3329 and d=1."""
    if not 0 <= x < Q:
        raise ValueError(f"non-canonical coefficient: {x}")
    return 1 if 833 <= x <= 2496 else 0


def main() -> None:
    rows = []
    mismatches = []

    for x in range(Q):
        rational = exact_rational_round(x)
        formula = integer_formula(x)
        threshold = threshold_oracle(x)
        rows.append((x, rational, formula, threshold))

        if not (rational == formula == threshold):
            mismatches.append((x, rational, formula, threshold))

    output = Path(__file__).with_name("compress1_exhaustive.tsv")
    with output.open("w", encoding="utf-8") as handle:
        handle.write(
            "coefficient\texact_rational_round\tinteger_formula\tthreshold_oracle\n"
        )
        for row in rows:
            handle.write(f"{row[0]}\t{row[1]}\t{row[2]}\t{row[3]}\n")

    boundaries = {
        0: 0,
        832: 0,
        833: 1,
        2496: 1,
        2497: 0,
        3328: 0,
    }

    for x, expected in boundaries.items():
        actual = exact_rational_round(x)
        if actual != expected:
            raise AssertionError(
                f"boundary failure: x={x}, expected={expected}, actual={actual}"
            )

    if mismatches:
        raise AssertionError(
            f"oracle mismatch count={len(mismatches)}; first={mismatches[0]}"
        )

    ones = sum(exact_rational_round(x) for x in range(Q))
    zeros = Q - ones

    print("FIPS_Q=3329")
    print("CANONICAL_DOMAIN_SIZE=3329")
    print("INTEGER_FORMULA=((2*x + 1664) // 3329) mod 2")
    print("ZERO_INTERVAL_1=0..832")
    print("ONE_INTERVAL=833..2496")
    print("ZERO_INTERVAL_2=2497..3328")
    print("CRITICAL_BOUNDARIES=832,833,2496,2497")
    print(f"ZERO_COUNT={zeros}")
    print(f"ONE_COUNT={ones}")
    print("RATIONAL_INTEGER_THRESHOLD_EQUIVALENCE=PASS")
    print("BOUNDARY_CHECK=PASS")
    print("FIPS_ORACLE_EXHAUSTIVE=PASS")


if __name__ == "__main__":
    main()
PY

if ! python3 "$WORK_STAGE/03_fips_oracle/check_fips_compress1.py" \
  2>&1 | tee "$WORK_STAGE/03_fips_oracle/oracle_validation.log"; then
  fail "FIPS Compress_1 oracle validation failed"
fi

grep -q '^FIPS_ORACLE_EXHAUSTIVE=PASS$' \
  "$WORK_STAGE/03_fips_oracle/oracle_validation.log" || \
  fail "oracle log does not contain the required PASS marker"

cat > "$WORK_STAGE/03_fips_oracle/FIPS_ORACLE_D1.md" <<'ORACLE'
# Independent FIPS 203 `Compress_1` oracle

For canonical `x` in `0..3328`, the d=1 compression bit is:

```text
Compress_1(x) = round((2 / 3329) * x) mod 2
```

An exact integer realization is:

```text
((2*x + 1664) // 3329) mod 2
```

For `q = 3329`, this is equivalent to:

```text
0, when x is in 0..832
1, when x is in 833..2496
0, when x is in 2497..3328
```

The accompanying Python program exhaustively compares an exact rational-rounding
implementation, the integer formula, and the threshold partition for all 3329
canonical coefficients. It also checks the critical boundaries 832/833 and
2496/2497.
ORACLE

echo "FIPS_ORACLE=PASS"

# -----------------------------------------------------------------------------
# 4. Native ML-KEM-768 CBMC baseline
# -----------------------------------------------------------------------------
echo
echo "=== BUILDING AND RUNNING THE NATIVE ML-KEM-768 CBMC BASELINE ==="

{
  echo "PREBUILD_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "PROOF=$PROOF"
  echo "GOTO=$GOTO"
  if [ -d "$PROOF/gotos" ]; then
    find "$PROOF/gotos" -maxdepth 1 -type f -printf '%f\t%s bytes\n' | sort
  else
    echo "NO_PREEXISTING_GOTO_DIRECTORY"
  fi
} > "$WORK_STAGE/04_native_baseline/PREBUILD_STATE.txt"

make -C "$PROOF" MLKEM_K=3 veryclean \
  2>&1 | tee "$WORK_STAGE/04_native_baseline/native_veryclean.log"

if ! make -C "$PROOF" MLKEM_K=3 result \
  2>&1 | tee "$WORK_STAGE/04_native_baseline/native_result_build.log"; then
  if [ -d "$PROOF/logs" ]; then
    cp -a "$PROOF/logs/." "$WORK_STAGE/04_native_baseline/logs/" || true
  fi
  fail "native make result command failed"
fi

[ -s "$PROOF/logs/result.txt" ] || fail "native result.txt was not generated"
[ -s "$GOTO" ] || fail "native final GOTO binary was not generated: $GOTO"

cp -a "$PROOF/logs/." "$WORK_STAGE/04_native_baseline/logs/"
cp -- "$PROOF/logs/result.txt" \
  "$WORK_STAGE/04_native_baseline/NATIVE_RESULT.txt"

tail -n 30 "$PROOF/logs/result.txt" \
  > "$WORK_STAGE/04_native_baseline/NATIVE_RESULT_TAIL.txt"

if ! grep -q 'VERIFICATION SUCCESSFUL' "$PROOF/logs/result.txt"; then
  fail "native CBMC baseline did not report VERIFICATION SUCCESSFUL"
fi

if grep -q 'VERIFICATION FAILED' "$PROOF/logs/result.txt"; then
  fail "native CBMC baseline reported VERIFICATION FAILED"
fi

{
  echo "NATIVE_COMMAND=make -C $PROOF MLKEM_K=3 result"
  echo "NATIVE_GOTO=$GOTO"
  echo "NATIVE_GOTO_SHA256=$(sha256sum "$GOTO" | awk '{print $1}')"
  echo "NATIVE_RESULT_MARKER=VERIFICATION SUCCESSFUL"
  echo "NATIVE_BASELINE=PASS"
} | tee "$WORK_STAGE/04_native_baseline/NATIVE_BASELINE_SUMMARY.txt"

# -----------------------------------------------------------------------------
# 5. Final GOTO inspection
# -----------------------------------------------------------------------------
echo
echo "=== INSPECTING THE NATIVE GOTO BINARY ==="

cp -- "$GOTO" "$WORK_STAGE/05_goto_inspection/poly_tomsg_harness.goto"
sha256sum "$WORK_STAGE/05_goto_inspection/poly_tomsg_harness.goto" \
  > "$WORK_STAGE/05_goto_inspection/poly_tomsg_harness.goto.sha256"

goto-instrument --show-goto-functions "$GOTO" \
  > "$WORK_STAGE/05_goto_inspection/GOTO_FUNCTIONS.txt" 2>&1

cbmc "$GOTO" --show-properties \
  > "$WORK_STAGE/05_goto_inspection/GOTO_PROPERTIES.txt" 2>&1

grep -n -E '(^|::)(harness|mlk_poly_tomsg|mlk_scalar_compress_d1)(\(|$|::)' \
  "$WORK_STAGE/05_goto_inspection/GOTO_FUNCTIONS.txt" \
  > "$WORK_STAGE/05_goto_inspection/GOTO_KEY_FUNCTIONS.txt" || true

grep -q 'mlk_poly_tomsg' \
  "$WORK_STAGE/05_goto_inspection/GOTO_FUNCTIONS.txt" || \
  fail "mlk_poly_tomsg was not found in the final GOTO function listing"

grep -q 'harness' \
  "$WORK_STAGE/05_goto_inspection/GOTO_FUNCTIONS.txt" || \
  fail "harness was not found in the final GOTO function listing"

PROPERTY_LINE_COUNT="$(grep -c '\[' "$WORK_STAGE/05_goto_inspection/GOTO_PROPERTIES.txt" || true)"

{
  echo "GOTO_EXISTS=PASS"
  echo "GOTO_NONEMPTY=PASS"
  echo "HARNESS_SYMBOL_PRESENT=PASS"
  echo "MLK_POLY_TOMSG_SYMBOL_PRESENT=PASS"
  echo "PROPERTY_LIST_BRACKET_LINE_COUNT=$PROPERTY_LINE_COUNT"
  echo "GOTO_INSPECTION=PASS"
} | tee "$WORK_STAGE/05_goto_inspection/GOTO_INSPECTION_SUMMARY.txt"

# -----------------------------------------------------------------------------
# 6. Final integrity checks and atomic stage freeze
# -----------------------------------------------------------------------------
POST_WORKTREE_STATE="$(git -C "$REPO" status --porcelain=v1)"
if [ -n "$POST_WORKTREE_STATE" ]; then
  {
    echo "ERROR: repository worktree changed during native baseline"
    git -C "$REPO" status --short
  } | tee "$WORK_STAGE/00_source_binding/WORKTREE_AFTER_ERROR.txt"
  exit 1
fi

UTC_END="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

{
  echo "STAGE_ID=MSG00B_C_F_NATIVE_BASELINE_MLKEM768_RUN1"
  echo "UTC_START=$UTC_START"
  echo "UTC_END=$UTC_END"
  echo "COMMIT_BINDING=PASS"
  echo "WORKTREE_CLEAN_BEFORE=YES"
  echo "WORKTREE_CLEAN_AFTER=YES"
  echo "SOURCE_SNAPSHOT=PASS"
  echo "REPOSITORY_OVERLAP_AUDIT=RECORDED"
  echo "FIPS_ORACLE_EXHAUSTIVE=PASS"
  echo "NATIVE_CBMC_BASELINE=PASS"
  echo "NATIVE_GOTO_INSPECTION=PASS"
  echo "FINAL_STATUS=PASS"
} | tee "$WORK_STAGE/STAGE_SUMMARY.txt"

(
  cd "$WORK_STAGE"
  find . -type f ! -name 'ARTIFACT_MANIFEST.sha256' -print0 |
    sort -z |
    xargs -0 sha256sum
) > "$WORK_STAGE/ARTIFACT_MANIFEST.sha256"

(
  cd "$WORK_STAGE"
  sha256sum -c ARTIFACT_MANIFEST.sha256
) > "$WORK_STAGE/ARTIFACT_MANIFEST_VALIDATION.txt"

grep -q ': OK$' "$WORK_STAGE/ARTIFACT_MANIFEST_VALIDATION.txt" || \
  fail "artifact-manifest validation produced no OK records"

mv -- "$WORK_STAGE" "$STAGE"
trap - EXIT

FINAL_FILE_COUNT="$(find "$STAGE" -type f | wc -l | tr -d ' ')"
FINAL_MANIFEST_SHA256="$(sha256sum "$STAGE/ARTIFACT_MANIFEST.sha256" | awk '{print $1}')"

echo
echo "============================================================"
echo "MSG-00B/C/F COMPLETE"
echo "============================================================"
echo "FINAL_STAGE=$STAGE"
echo "FINAL_FILE_COUNT=$FINAL_FILE_COUNT"
echo "ARTIFACT_MANIFEST_SHA256=$FINAL_MANIFEST_SHA256"
echo "COMMIT_BINDING=PASS"
echo "FIPS_ORACLE_EXHAUSTIVE=PASS"
echo "NATIVE_CBMC_BASELINE=PASS"
echo "NATIVE_GOTO_INSPECTION=PASS"
echo "FINAL_STATUS=PASS"
