#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
FREEZE="$ROOT/sub00f_mode_a_execution_freeze_v1"
HARNESSES="$FREEZE/harnesses"
OUT="/home/girish/SUB00L_BATCH2_BUILD_CONTEXT.txt"

EXPECTED_HASHES=(
"ca54ad2d875f104cf6daca915bcfb71e491c3f899b3d877b70439868d80d1037  sub_t2_relational_harness.c"
"132c34161c8230eb14e86acc0cae3af52fbf6eb429a8e55233080337dc4415d7  sub_cov_reachability_harness.c"
"8f8d3a87cca7bfe5938f0db5ce0d8fe1829c03c3366d40a3aa17a084e7b48d6b  sub_boundary_valid_extremes_harness.c"
"8469f8c5a40a1da2fdd95b05eb6c5c5e8783128196989f19bf437886e4ed6a9d  sub_boundary_invalid_lower_harness.c"
"4db500d2d8c7a1d79dda38ec466aa79ed2b48f9cec46fa932ad4be7012a7e623  sub_boundary_invalid_upper_harness.c"
)

HARNESS_PATTERN='sub_t2_relational|sub_cov_reachability|sub_boundary_valid_extremes|sub_boundary_invalid_lower|sub_boundary_invalid_upper'

{
    echo "============================================================"
    echo "SUB00L BATCH 2 — FROZEN BUILD-CONTEXT EXTRACTION"
    echo "============================================================"
    echo "TIMESTAMP=$(date --iso-8601=seconds)"
    echo "ROOT=$ROOT"
    echo "FREEZE=$FREEZE"
    echo "HARNESSES=$HARNESSES"

    echo
    echo "=== GATE B2.1-A: PROCESS CLEANLINESS ==="

    SELF_PID="$$"
    PARENT_PID="$PPID"

    PROCESS_LINES="$(
        pgrep -af \
          'cbmc|goto-cc|goto-gcc|goto-clang|sub_t2_relational|sub_cov_reachability|sub_boundary_' \
          2>/dev/null |
        awk -v self="$SELF_PID" -v parent="$PARENT_PID" \
          '$1 != self && $1 != parent'
    )"

    if [ -z "$PROCESS_LINES" ]; then
        echo "PASS NO_RELATED_EXECUTION_RUNNING"
    else
        echo "FAIL RELATED_PROCESS_FOUND"
        printf '%s\n' "$PROCESS_LINES"
    fi

    echo
    echo "=== GATE B2.1-B: REVERIFY FROZEN HARNESS HASHES ==="

    HASH_FAILURES=0

    for entry in "${EXPECTED_HASHES[@]}"; do
        expected="${entry%%  *}"
        name="${entry#*  }"
        path="$HARNESSES/$name"

        if [ ! -f "$path" ]; then
            echo "FAIL MISSING=$path"
            HASH_FAILURES=$((HASH_FAILURES + 1))
            continue
        fi

        actual="$(sha256sum "$path" | awk '{print $1}')"

        echo "HARNESS=$name"
        echo "EXPECTED_SHA256=$expected"
        echo "ACTUAL_SHA256=$actual"

        if [ "$actual" = "$expected" ]; then
            echo "HASH_STATUS=PASS"
        else
            echo "HASH_STATUS=FAIL"
            HASH_FAILURES=$((HASH_FAILURES + 1))
        fi

        if [ -w "$path" ]; then
            echo "READ_ONLY_STATUS=FAIL_WRITABLE"
            HASH_FAILURES=$((HASH_FAILURES + 1))
        else
            echo "READ_ONLY_STATUS=PASS"
        fi

        echo
    done

    echo "HARNESS_HASH_FAILURES=$HASH_FAILURES"

    echo
    echo "=== GATE B2.1-C: COMPLETE FREEZE INVENTORY ==="

    find "$FREEZE" -maxdepth 6 -type f \
      -printf '%TY-%Tm-%Td %TH:%TM:%TS  %10s  %m  %p\n' |
      sort

    echo
    echo "=== GATE B2.1-D: CANDIDATE GOTO MODELS ==="

    GOTO_COUNT=0

    while IFS= read -r model; do
        [ -n "$model" ] || continue
        echo "GOTO_MODEL=$model"
        file "$model" 2>/dev/null || true
        sha256sum "$model"
        GOTO_COUNT=$((GOTO_COUNT + 1))
    done < <(
        find "$ROOT" -maxdepth 8 -type f -name '*.goto' 2>/dev/null |
        grep -E "$HARNESS_PATTERN" |
        sort || true
    )

    echo "MATCHING_GOTO_MODEL_COUNT=$GOTO_COUNT"

    echo
    echo "=== GATE B2.1-E: COMMAND AND BUILD-RECIPE FILES ==="

    find "$FREEZE" "$ROOT" -maxdepth 8 -type f \
      \( -iname '*command*.txt' \
         -o -iname '*build*.txt' \
         -o -iname '*recipe*.txt' \
         -o -iname '*compile*.txt' \
         -o -iname '*execution*.txt' \
         -o -iname '*model*.txt' \
         -o -iname '*preflight*.txt' \
         -o -iname '*manifest*.md' \
         -o -iname '*manifest*.json' \
         -o -iname 'Makefile' \
         -o -iname '*.mk' \) \
      -print 2>/dev/null |
      sort |
      while IFS= read -r file_path; do
          if grep -Iq . "$file_path" 2>/dev/null; then
              if grep -qiE \
                "$HARNESS_PATTERN|goto-cc|goto-gcc|goto-clang|cbmc|MLKEM_K|MLKEM768|CFLAGS|CPPFLAGS|include" \
                "$file_path" 2>/dev/null; then

                  echo
                  echo "------------------------------------------------------------"
                  echo "BUILD_CONTEXT_FILE=$file_path"
                  echo "SHA256=$(sha256sum "$file_path" | awk '{print $1}')"
                  echo "------------------------------------------------------------"

                  grep -nEi \
                    "$HARNESS_PATTERN|goto-cc|goto-gcc|goto-clang|cbmc|MLKEM_K|MLKEM768|CFLAGS|CPPFLAGS|(^|[[:space:]])-I|(^|[[:space:]])-D" \
                    "$file_path" 2>/dev/null |
                    head -200 || true
              fi
          fi
      done

    echo
    echo "=== GATE B2.1-F: DIRECT REFERENCES TO FIVE HARNESSES ==="

    for harness in \
      sub_t2_relational_harness.c \
      sub_cov_reachability_harness.c \
      sub_boundary_valid_extremes_harness.c \
      sub_boundary_invalid_lower_harness.c \
      sub_boundary_invalid_upper_harness.c
    do
        echo
        echo "HARNESS_REFERENCE_SEARCH=$harness"

        grep -RInsF \
          "$harness" \
          "$FREEZE" "$ROOT" \
          --exclude='*.goto' \
          --exclude='*.json' \
          --exclude='cbmc_result.json' \
          2>/dev/null |
          head -100 || echo "NO_REFERENCE_FOUND"
    done

    echo
    echo "=== GATE B2.1-G: AVAILABLE COMPILERS ==="

    for tool in cbmc goto-cc goto-gcc goto-clang gcc clang make cmake ninja; do
        printf '%-12s ' "$tool"

        if command -v "$tool" >/dev/null 2>&1; then
            command -v "$tool"
        else
            echo "NOT_FOUND"
        fi
    done

    echo
    echo "=== GATE B2.1-H: REPOSITORY IDENTITIES ==="

    find "$ROOT" -maxdepth 7 -type d -name '.git' -print 2>/dev/null |
      while IFS= read -r gitdir; do
          repo="${gitdir%/.git}"

          echo
          echo "REPOSITORY=$repo"

          git -C "$repo" rev-parse HEAD 2>/dev/null |
            sed 's/^/HEAD=/' || echo "HEAD=UNAVAILABLE"

          git -C "$repo" status --porcelain=v1 2>/dev/null |
            sed 's/^/STATUS=/' || true
      done

    echo
    echo "============================================================"
    echo "BUILD-CONTEXT EXTRACTION COMPLETE"
    echo "NO CBMC THEOREM OR CONTROL EXECUTION WAS PERFORMED"
    echo "NO SOURCE OR HARNESS WAS MODIFIED"
    echo "============================================================"
} | tee "$OUT"

echo
echo "BUILD_CONTEXT_OUTPUT=$OUT"
sha256sum "$OUT"
