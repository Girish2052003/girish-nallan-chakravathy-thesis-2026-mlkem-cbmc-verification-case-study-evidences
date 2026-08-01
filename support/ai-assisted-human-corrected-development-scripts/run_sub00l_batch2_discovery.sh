#!/usr/bin/env bash
set -uo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
FROZEN="$ROOT/sub00f_mode_a_execution_freeze_v1/harnesses"
PARENT="$ROOT/SUB00K_COMBINED_MUTATION_EXECUTION_MLKEM768_RUN1"
OUT="/home/girish/SUB00L_BATCH2_DISCOVERY.txt"
MANIFEST_CHECK="/home/girish/SUB00K_PARENT_MANIFEST_CHECK_FOR_SUB00L.txt"

EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

HARNESSES=(
  "sub_t2_relational_harness.c"
  "sub_cov_reachability_harness.c"
  "sub_boundary_valid_extremes_harness.c"
  "sub_boundary_invalid_lower_harness.c"
  "sub_boundary_invalid_upper_harness.c"
)

{
    echo "============================================================"
    echo "SUB00L BATCH 2 — FROZEN INPUT DISCOVERY"
    echo "============================================================"
    echo "TIMESTAMP=$(date --iso-8601=seconds)"
    echo "ROOT=$ROOT"
    echo "FROZEN=$FROZEN"
    echo "PARENT=$PARENT"
    echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"

    echo
    echo "=== GATE B2.0-A: REQUIRED DIRECTORIES ==="

    for d in "$ROOT" "$FROZEN" "$PARENT"; do
        if [ -d "$d" ]; then
            echo "PASS DIRECTORY_EXISTS=$d"
        else
            echo "FAIL DIRECTORY_MISSING=$d"
        fi
    done

    echo
    echo "=== GATE B2.0-B: TOOL IDENTITY ==="

    printf 'CBMC_PATH='
    command -v cbmc || true

    printf 'CBMC_VERSION='
    cbmc --version 2>&1 | head -1 || true

    printf 'GCC_VERSION='
    gcc --version 2>&1 | head -1 || true

    printf 'PYTHON_VERSION='
    python3 --version 2>&1 || true

    echo
    echo "=== GATE B2.0-C: PROCESS CLEANLINESS ==="

    pgrep -af \
      'run_sub00k|run_sub00l|sub_t2_relational|sub_cov_reachability|sub_boundary_|cbmc' \
      || echo "PASS NO_RELATED_PROCESS_RUNNING"

    echo
    echo "=== GATE B2.0-D: FROZEN HARNESS PRESENCE AND HASHES ==="

    for h in "${HARNESSES[@]}"; do
        file="$FROZEN/$h"

        echo
        echo "------------------------------------------------------------"
        echo "HARNESS=$h"
        echo "PATH=$file"

        if [ ! -f "$file" ]; then
            echo "STATUS=MISSING"
            continue
        fi

        echo "STATUS=PRESENT"
        stat --printf='SIZE_BYTES=%s\nMODIFIED=%y\nMODE=%A\n' "$file"
        sha256sum "$file"
    done

    echo
    echo "=== GATE B2.0-E: ASSERTION / ASSUMPTION / COVER INVENTORY ==="

    for h in "${HARNESSES[@]}"; do
        file="$FROZEN/$h"

        [ -f "$file" ] || continue

        echo
        echo "------------------------------------------------------------"
        echo "HARNESS=$h"
        echo "------------------------------------------------------------"

        grep -nE \
          '__CPROVER_(assume|assert|cover)|mlk_poly_(sub|reduce)|INT16_(MIN|MAX)|MLKEM_(N|Q)' \
          "$file" 2>/dev/null || echo "NO_MATCHING_LINES"
    done

    echo
    echo "=== GATE B2.0-F: FUNCTION DEFINITIONS ==="

    for h in "${HARNESSES[@]}"; do
        file="$FROZEN/$h"

        [ -f "$file" ] || continue

        echo
        echo "HARNESS=$h"

        grep -nE \
          '^[[:space:]]*(static[[:space:]]+)?(void|int|int16_t|int32_t|uint16_t|uint32_t)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(' \
          "$file" 2>/dev/null || true
    done

    echo
    echo "=== GATE B2.0-G: PARENT SUB00K VERDICT ==="

    if [ -f "$PARENT/MUTATION_VERDICT.txt" ]; then
        cat "$PARENT/MUTATION_VERDICT.txt"
    else
        echo "FAIL MISSING_MUTATION_VERDICT"
    fi

    echo
    echo "=== GATE B2.0-H: PARENT MANIFEST PRESENCE ==="

    if [ -f "$PARENT/SUB00K_ARTIFACT_MANIFEST.sha256" ]; then
        echo "PASS SUB00K_MANIFEST_PRESENT"
        sha256sum "$PARENT/SUB00K_ARTIFACT_MANIFEST.sha256"
    else
        echo "FAIL SUB00K_MANIFEST_MISSING"
    fi

    echo
    echo "=== GATE B2.0-I: CAMPAIGN COMMIT REFERENCES ==="

    grep -RnsF \
      "$EXPECTED_COMMIT" \
      "$ROOT/sub00f_mode_a_execution_freeze_v1" \
      "$PARENT" \
      --exclude='cbmc_result.json' \
      --exclude='*.goto' \
      2>/dev/null | head -40 || echo "NO_COMMIT_REFERENCE_FOUND"

    echo
    echo "============================================================"
    echo "DISCOVERY COMPLETE"
    echo "NO CBMC THEOREM EXECUTION WAS PERFORMED"
    echo "NO HARNESS OR PRODUCTION SOURCE WAS MODIFIED"
    echo "============================================================"
} | tee "$OUT"

echo
echo "DISCOVERY_OUTPUT=$OUT"
sha256sum "$OUT"

echo
echo "=== INDEPENDENT SUB00K MANIFEST CHECK ==="

if [ -f "$PARENT/SUB00K_ARTIFACT_MANIFEST.sha256" ]; then
    (
        cd "$PARENT" || exit 1
        sha256sum -c SUB00K_ARTIFACT_MANIFEST.sha256
    ) >"$MANIFEST_CHECK" 2>&1

    CHECK_EXIT=$?

    echo "SUB00K_MANIFEST_CHECK_EXIT=$CHECK_EXIT"
    echo "SUB00K_MANIFEST_CHECK_FILE=$MANIFEST_CHECK"

    if [ "$CHECK_EXIT" -eq 0 ]; then
        echo "SUB00K_PARENT_INTEGRITY=PASS"
    else
        echo "SUB00K_PARENT_INTEGRITY=FAIL"
        grep -E 'FAILED|WARNING|not found' "$MANIFEST_CHECK" | tail -30
    fi
else
    echo "SUB00K_PARENT_INTEGRITY=NOT_CHECKED_MANIFEST_MISSING"
fi
