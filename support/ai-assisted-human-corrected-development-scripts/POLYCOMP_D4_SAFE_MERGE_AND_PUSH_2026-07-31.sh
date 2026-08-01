#!/usr/bin/env bash

set -Eeuo pipefail

SOURCE='/home/girish/THESIS-2026/MLK_POLYCOMP_D4_LOSSLESS_CLASSIFIED_REPO_OVERLAY_2026-07-31'
REPO='/home/girish/THESIS-2026/CLASSIFICATION GIT/MLKEM_CBMC_FULL_CLASSIFIED_BASELINE_2026-07-19'

BACKUP='/home/girish/THESIS-2026/CLASSIFICATION GIT/MLKEM_CBMC_FULL_CLASSIFIED_BASELINE_2026-07-19_PRE_POLYCOMP_D4_MERGE_20260731T024415Z.tar.gz'

EXPECTED_OVERLAY_FILES=1059
EXPECTED_ORIGINAL_ROWS=1545

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_DIR="/tmp/polycomp_d4_publish_${STAMP}"

BUNDLE='/home/girish/THESIS-2026/CLASSIFICATION GIT/MLKEM_CBMC_PRE_POLYCOMP_D4_GIT_HISTORY_'"${STAMP}"'.bundle'

PRE_MERGE_BRANCH="safety/pre-polycomp-d4-merge-${STAMP}"
PRE_REBASE_BRANCH="safety/polycomp-d4-before-reconcile-${STAMP}"
FINAL_REBASE_BRANCH="safety/polycomp-d4-before-final-reconcile-${STAMP}"

mkdir -p "$LOG_DIR"

fail() {
    echo
    echo "============================================================"
    echo "POLYCOMP_D4_PIPELINE=STOPPED_SAFELY"
    echo "REASON=$1"
    echo "NO_FORCE_PUSH_WAS_USED=YES"
    echo "LOG_DIRECTORY=$LOG_DIR"
    echo "============================================================"
    exit 1
}

trap 'fail "Unexpected command failure near script line $LINENO"' ERR

echo "============================================================"
echo "POLYCOMP-D4 LOSSLESS MERGE AND GITHUB PUBLICATION"
echo "============================================================"
echo "SOURCE=$SOURCE"
echo "REPOSITORY=$REPO"
echo "BACKUP=$BACKUP"
echo "LOG_DIRECTORY=$LOG_DIR"

# ------------------------------------------------------------------
# GATE 1: Starting-state checks
# ------------------------------------------------------------------

echo
echo "===== GATE 1: STARTING-STATE CHECK ====="

[ -d "$SOURCE" ] || fail "Source overlay directory does not exist."
[ -d "$REPO" ] || fail "Repository directory does not exist."
[ -f "$BACKUP" ] || fail "Pre-merge repository backup does not exist."
[ -f "$BACKUP.sha256" ] || fail "Backup SHA-256 sidecar does not exist."

git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null ||
    fail "Target is not a Git repository."

CURRENT_BRANCH="$(git -C "$REPO" branch --show-current)"
CURRENT_HEAD="$(git -C "$REPO" rev-parse HEAD)"
STATUS_LINES="$(git -C "$REPO" status --porcelain | wc -l)"
SOURCE_FILES="$(find "$SOURCE" -type f | wc -l)"
SOURCE_SYMLINKS="$(find "$SOURCE" -type l | wc -l)"
SOURCE_OTHER="$(
    find "$SOURCE" \
        ! -type f \
        ! -type d \
        ! -type l |
    wc -l
)"

echo "CURRENT_BRANCH=$CURRENT_BRANCH"
echo "CURRENT_HEAD=$CURRENT_HEAD"
echo "WORKING_TREE_CHANGE_LINES=$STATUS_LINES"
echo "SOURCE_FILES=$SOURCE_FILES"
echo "SOURCE_SYMLINKS=$SOURCE_SYMLINKS"
echo "SOURCE_OTHER_OBJECTS=$SOURCE_OTHER"

[ "$CURRENT_BRANCH" = "main" ] ||
    fail "Current branch is not main."

[ "$STATUS_LINES" -eq 0 ] ||
    fail "Repository working tree is not clean."

[ "$SOURCE_FILES" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Overlay does not contain the expected 1,059 files."

[ "$SOURCE_SYMLINKS" -eq 0 ] ||
    fail "Overlay unexpectedly contains symbolic links."

[ "$SOURCE_OTHER" -eq 0 ] ||
    fail "Overlay contains unsupported filesystem objects."

echo "STARTING_STATE_GATE=PASS"

# ------------------------------------------------------------------
# GATE 2: Verify existing backup and create verified Git bundle
# ------------------------------------------------------------------

echo
echo "===== GATE 2: BACKUP AND GIT-HISTORY VERIFICATION ====="

sha256sum -c "$BACKUP.sha256" |
tee "$LOG_DIR/backup_sha256_check.txt"

tar -tzf "$BACKUP" >/dev/null

REPO_NAME="$(basename "$REPO")"

BACKUP_GIT_ENTRIES="$(
    tar -tzf "$BACKUP" |
    grep -cE "^${REPO_NAME}/\.git($|/)" ||
    true
)"

echo "BACKUP_GIT_ENTRIES=$BACKUP_GIT_ENTRIES"

[ "$BACKUP_GIT_ENTRIES" -gt 0 ] ||
    fail "Repository backup does not contain Git metadata."

echo "Creating fresh Git-history bundle..."

git -C "$REPO" bundle create "$BUNDLE" --all

git -C "$REPO" bundle verify "$BUNDLE" \
    > "$LOG_DIR/bundle_verify.txt" 2>&1 ||
    {
        cat "$LOG_DIR/bundle_verify.txt"
        fail "Git bundle verification failed."
    }

cat "$LOG_DIR/bundle_verify.txt"

sha256sum "$BUNDLE" > "$BUNDLE.sha256"

BUNDLE_MAIN_MATCH="$(
    git bundle list-heads "$BUNDLE" |
    grep -c "^${CURRENT_HEAD} refs/heads/main$" ||
    true
)"

echo "BUNDLE=$BUNDLE"
echo "BUNDLE_SIZE=$(du -h "$BUNDLE" | cut -f1)"
echo "BUNDLE_CONTAINS_CURRENT_MAIN=$BUNDLE_MAIN_MATCH"
cat "$BUNDLE.sha256"

[ "$BUNDLE_MAIN_MATCH" -eq 1 ] ||
    fail "Git bundle does not contain the current main commit."

echo "BACKUP_AND_GIT_HISTORY_GATE=PASS"

# ------------------------------------------------------------------
# GATE 3: Verify source overlay
# ------------------------------------------------------------------

echo
echo "===== GATE 3: SOURCE OVERLAY VERIFICATION ====="

(
    cd "$SOURCE"
    bash support/development-scripts/verify_polycomp_d4_classification.sh
) > "$LOG_DIR/source_overlay_verifier.log" 2>&1

tail -n 25 "$LOG_DIR/source_overlay_verifier.log"

grep -q "^ORIGINAL_FILE_ROWS=${EXPECTED_ORIGINAL_ROWS}$" \
    "$LOG_DIR/source_overlay_verifier.log" ||
    fail "Original-file accounting did not report 1,545 rows."

grep -q '^MISSING_RETAINED_TARGETS=0$' \
    "$LOG_DIR/source_overlay_verifier.log" ||
    fail "The source overlay has missing retained targets."

grep -q '^HASH_DIFFERENT_RETAINED_TARGETS=0$' \
    "$LOG_DIR/source_overlay_verifier.log" ||
    fail "The source overlay has hash-different retained targets."

grep -q '^POLYCOMP_D4_CLASSIFICATION_VERIFY=PASS$' \
    "$LOG_DIR/source_overlay_verifier.log" ||
    fail "Source-overlay classification verification failed."

echo "SOURCE_OVERLAY_GATE=PASS"

# ------------------------------------------------------------------
# GATE 4: Repeat collision audit immediately before writing
# ------------------------------------------------------------------

echo
echo "===== GATE 4: FINAL PRE-MERGE COLLISION AUDIT ====="

NEW_FILES=0
EXACT_COLLISIONS=0
DIFFERENT_COLLISIONS=0
TYPE_CONFLICTS=0

: > "$LOG_DIR/different_collisions.txt"
: > "$LOG_DIR/exact_collisions.txt"
: > "$LOG_DIR/type_conflicts.txt"

while IFS= read -r -d '' SRC; do
    REL="${SRC#"$SOURCE"/}"
    DST="$REPO/$REL"

    if [ -e "$DST" ] || [ -L "$DST" ]; then
        if [ -f "$SRC" ] && [ -f "$DST" ]; then
            if cmp -s -- "$SRC" "$DST"; then
                EXACT_COLLISIONS=$((EXACT_COLLISIONS + 1))
                printf '%s\n' "$REL" \
                    >> "$LOG_DIR/exact_collisions.txt"
            else
                DIFFERENT_COLLISIONS=$((DIFFERENT_COLLISIONS + 1))
                printf '%s\n' "$REL" \
                    >> "$LOG_DIR/different_collisions.txt"
            fi
        else
            TYPE_CONFLICTS=$((TYPE_CONFLICTS + 1))
            printf '%s\n' "$REL" \
                >> "$LOG_DIR/type_conflicts.txt"
        fi
    else
        NEW_FILES=$((NEW_FILES + 1))
    fi
done < <(find "$SOURCE" -type f -print0)

while IFS= read -r -d '' SRC_DIR; do
    REL="${SRC_DIR#"$SOURCE"/}"
    DST="$REPO/$REL"

    if [ -e "$DST" ] && [ ! -d "$DST" ]; then
        TYPE_CONFLICTS=$((TYPE_CONFLICTS + 1))
        printf 'DIRECTORY_CONFLICT\t%s\n' "$REL" \
            >> "$LOG_DIR/type_conflicts.txt"
    fi
done < <(find "$SOURCE" -mindepth 1 -type d -print0)

echo "NEW_FILES=$NEW_FILES"
echo "EXACT_COLLISIONS=$EXACT_COLLISIONS"
echo "DIFFERENT_COLLISIONS=$DIFFERENT_COLLISIONS"
echo "TYPE_CONFLICTS=$TYPE_CONFLICTS"

[ "$NEW_FILES" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Not all 1,059 overlay paths are new."

[ "$EXACT_COLLISIONS" -eq 0 ] ||
    fail "Unexpected existing paths were detected."

[ "$DIFFERENT_COLLISIONS" -eq 0 ] ||
    fail "Different-content destination collisions were detected."

[ "$TYPE_CONFLICTS" -eq 0 ] ||
    fail "File/directory type conflicts were detected."

echo "PRE_MERGE_COLLISION_GATE=PASS"

# ------------------------------------------------------------------
# GATE 5: Create safety branch and protected merge
# ------------------------------------------------------------------

echo
echo "===== GATE 5: PROTECTED MERGE ====="

git -C "$REPO" branch "$PRE_MERGE_BRANCH" main

echo "PRE_MERGE_SAFETY_BRANCH=$PRE_MERGE_BRANCH"
echo "PRE_MERGE_SAFETY_HEAD=$(git -C "$REPO" rev-parse "$PRE_MERGE_BRANCH")"

rsync -aH \
    --ignore-existing \
    --itemize-changes \
    --out-format='%i|%n%L' \
    --exclude='.git/' \
    "$SOURCE"/ "$REPO"/ |
tee "$LOG_DIR/rsync_merge.log"

COPIED_FILES="$(
    grep -c '^>f' "$LOG_DIR/rsync_merge.log" ||
    true
)"

echo "RSYNC_COPIED_FILES=$COPIED_FILES"

[ "$COPIED_FILES" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Rsync did not copy exactly 1,059 files."

echo "PROTECTED_MERGE_GATE=PASS"

# ------------------------------------------------------------------
# GATE 6: Byte-for-byte post-merge verification
# ------------------------------------------------------------------

echo
echo "===== GATE 6: BYTE-FOR-BYTE POST-MERGE CHECK ====="

EXACT_FILES=0
MISSING_FILES=0
DIFFERENT_FILES=0

: > "$LOG_DIR/missing_after_merge.txt"
: > "$LOG_DIR/different_after_merge.txt"

while IFS= read -r -d '' SRC; do
    REL="${SRC#"$SOURCE"/}"
    DST="$REPO/$REL"

    if [ ! -f "$DST" ]; then
        MISSING_FILES=$((MISSING_FILES + 1))
        printf '%s\n' "$REL" \
            >> "$LOG_DIR/missing_after_merge.txt"
    elif cmp -s -- "$SRC" "$DST"; then
        EXACT_FILES=$((EXACT_FILES + 1))
    else
        DIFFERENT_FILES=$((DIFFERENT_FILES + 1))
        printf '%s\n' "$REL" \
            >> "$LOG_DIR/different_after_merge.txt"
    fi
done < <(find "$SOURCE" -type f -print0)

echo "EXACT_MATCHING_FILES=$EXACT_FILES"
echo "MISSING_FILES=$MISSING_FILES"
echo "DIFFERENT_FILES=$DIFFERENT_FILES"

[ "$EXACT_FILES" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Not all merged files match the source overlay."

[ "$MISSING_FILES" -eq 0 ] ||
    fail "Merged repository has missing POLYCOMP-D4 files."

[ "$DIFFERENT_FILES" -eq 0 ] ||
    fail "Merged repository contains byte-different POLYCOMP-D4 files."

(
    cd "$REPO"
    bash support/development-scripts/verify_polycomp_d4_classification.sh
) > "$LOG_DIR/repository_verifier_after_merge.log" 2>&1

tail -n 25 "$LOG_DIR/repository_verifier_after_merge.log"

grep -q '^POLYCOMP_D4_CLASSIFICATION_VERIFY=PASS$' \
    "$LOG_DIR/repository_verifier_after_merge.log" ||
    fail "Repository classification verifier failed after the merge."

echo "POST_MERGE_BYTE_GATE=PASS"

# ------------------------------------------------------------------
# GATE 7: Stage only POLYCOMP-D4 additions
# ------------------------------------------------------------------

echo
echo "===== GATE 7: CONTROLLED STAGING ====="

cd "$REPO"

git add -- \
    docs/POLYCOMP_D4_DEDUPLICATION_POLICY.md \
    docs/POLYCOMP_D4_FOLDER_CLASSIFICATION.md \
    docs/POLYCOMP_D4_MERGE_GUIDE.md \
    experiments/polycomp-d4 \
    provenance/polycomp-d4-classification \
    provenance/frozen-baseline/polycomp-d4 \
    reports/campaign-overviews/polycomp-d4 \
    reports/novelty-and-prior-art/polycomp-d4 \
    support/development-scripts/verify_polycomp_d4_classification.sh \
    upstream/mlkem-native/polycomp-d4-af4c5abd-source-binding

git diff --cached --name-status \
    > "$LOG_DIR/staged_polycomp_files.tsv"

STAGED_TOTAL="$(wc -l < "$LOG_DIR/staged_polycomp_files.tsv")"
STAGED_ADDED="$(
    awk '$1 == "A" {n++} END {print n+0}' \
        "$LOG_DIR/staged_polycomp_files.tsv"
)"
STAGED_MODIFIED="$(
    awk '$1 == "M" {n++} END {print n+0}' \
        "$LOG_DIR/staged_polycomp_files.tsv"
)"
STAGED_DELETED="$(
    awk '$1 == "D" {n++} END {print n+0}' \
        "$LOG_DIR/staged_polycomp_files.tsv"
)"
STAGED_OTHER="$(
    awk '$1 != "A" && $1 != "M" && $1 != "D" {n++} END {print n+0}' \
        "$LOG_DIR/staged_polycomp_files.tsv"
)"

echo "STAGED_TOTAL=$STAGED_TOTAL"
echo "STAGED_ADDED=$STAGED_ADDED"
echo "STAGED_MODIFIED=$STAGED_MODIFIED"
echo "STAGED_DELETED=$STAGED_DELETED"
echo "STAGED_OTHER=$STAGED_OTHER"

[ "$STAGED_TOTAL" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Staged-file count is not 1,059."

[ "$STAGED_ADDED" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Not all staged files are additions."

[ "$STAGED_MODIFIED" -eq 0 ] ||
    fail "Existing repository files were unexpectedly modified."

[ "$STAGED_DELETED" -eq 0 ] ||
    fail "Existing repository files were unexpectedly deleted."

[ "$STAGED_OTHER" -eq 0 ] ||
    fail "Unexpected rename or special staged status detected."

echo "CONTROLLED_STAGING_GATE=PASS"

# ------------------------------------------------------------------
# GATE 8: Security, size and Git-metadata scan
# ------------------------------------------------------------------

echo
echo "===== GATE 8: PRE-COMMIT PUBLICATION SCAN ====="

NESTED_GIT_REPORT="$LOG_DIR/nested_git_paths.txt"
SPECIAL_MODE_REPORT="$LOG_DIR/special_modes.txt"
LARGE_REPORT="$LOG_DIR/files_at_least_100m.txt"
SECRET_REPORT="$LOG_DIR/credential_matches.txt"
SECRET_ERRORS="$LOG_DIR/credential_scan_errors.txt"

: > "$NESTED_GIT_REPORT"
: > "$SPECIAL_MODE_REPORT"
: > "$LARGE_REPORT"
: > "$SECRET_REPORT"
: > "$SECRET_ERRORS"

git diff --cached --name-only |
grep -E '(^|/)\.git($|/)' \
    > "$NESTED_GIT_REPORT" ||
true

NESTED_GIT_COUNT="$(wc -l < "$NESTED_GIT_REPORT")"

STAGED_SYMLINKS=0
STAGED_GITLINKS=0
UNEXPECTED_MODES=0
FILES_AT_LEAST_100M=0

while IFS= read -r -d '' PATHNAME; do
    MODE="$(
        git ls-files -s -- "$PATHNAME" |
        awk 'NR == 1 {print $1}'
    )"

    case "$MODE" in
        100644|100755)
            ;;
        120000)
            STAGED_SYMLINKS=$((STAGED_SYMLINKS + 1))
            printf 'SYMLINK\t%s\n' "$PATHNAME" \
                >> "$SPECIAL_MODE_REPORT"
            ;;
        160000)
            STAGED_GITLINKS=$((STAGED_GITLINKS + 1))
            printf 'GITLINK\t%s\n' "$PATHNAME" \
                >> "$SPECIAL_MODE_REPORT"
            ;;
        *)
            UNEXPECTED_MODES=$((UNEXPECTED_MODES + 1))
            printf 'MODE_%s\t%s\n' "$MODE" "$PATHNAME" \
                >> "$SPECIAL_MODE_REPORT"
            ;;
    esac

    FILE_SIZE="$(stat -c '%s' -- "$PATHNAME")"

    if [ "$FILE_SIZE" -ge $((100 * 1024 * 1024)) ]; then
        FILES_AT_LEAST_100M=$((FILES_AT_LEAST_100M + 1))
        printf '%s\t%s\n' "$FILE_SIZE" "$PATHNAME" \
            >> "$LARGE_REPORT"
    fi
done < <(
    git diff --cached \
        --diff-filter=A \
        --name-only \
        -z
)

KEY_PATTERN='-----BEGIN ([A-Z0-9 ]+ )?PRIVATE KEY-----|-----BEGIN PGP PRIVATE KEY BLOCK-----'

TOKEN_PATTERN='(^|[^A-Za-z0-9_])(AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[A-Za-z0-9-]{10,})([^A-Za-z0-9_-]|$)'

TEXT_FILES_SCANNED=0
SCAN_ERRORS=0

while IFS= read -r -d '' PATHNAME; do
    BLOB="$(git rev-parse --verify ":$PATHNAME")"
    TMP_FILE="$(mktemp)"
    TMP_MATCHES="$(mktemp)"

    if ! git cat-file blob "$BLOB" > "$TMP_FILE" \
        2>> "$SECRET_ERRORS"; then
        SCAN_ERRORS=$((SCAN_ERRORS + 1))
        rm -f "$TMP_FILE" "$TMP_MATCHES"
        continue
    fi

    if grep -Iq . -- "$TMP_FILE"; then
        TEXT_FILES_SCANNED=$((TEXT_FILES_SCANNED + 1))

        if LC_ALL=C grep -nE -- \
            "$KEY_PATTERN|$TOKEN_PATTERN" \
            "$TMP_FILE" > "$TMP_MATCHES"
        then
            GREP_EXIT=0
        else
            GREP_EXIT=$?
        fi

        if [ "$GREP_EXIT" -eq 0 ]; then
            while IFS= read -r MATCH; do
                printf '%s:%s\n' "$PATHNAME" "$MATCH" \
                    >> "$SECRET_REPORT"
            done < "$TMP_MATCHES"
        elif [ "$GREP_EXIT" -gt 1 ]; then
            SCAN_ERRORS=$((SCAN_ERRORS + 1))
            printf 'GREP_ERROR_%s\t%s\n' \
                "$GREP_EXIT" "$PATHNAME" \
                >> "$SECRET_ERRORS"
        fi
    fi

    rm -f "$TMP_FILE" "$TMP_MATCHES"
done < <(
    git diff --cached \
        --diff-filter=A \
        --name-only \
        -z
)

SECRET_MATCHES="$(wc -l < "$SECRET_REPORT")"
SECRET_ERROR_LINES="$(wc -l < "$SECRET_ERRORS")"

echo "NESTED_GIT_PATHS=$NESTED_GIT_COUNT"
echo "STAGED_SYMLINKS=$STAGED_SYMLINKS"
echo "STAGED_GITLINKS=$STAGED_GITLINKS"
echo "UNEXPECTED_FILE_MODES=$UNEXPECTED_MODES"
echo "FILES_AT_LEAST_100_MIB=$FILES_AT_LEAST_100M"
echo "TEXT_FILES_SCANNED=$TEXT_FILES_SCANNED"
echo "BOUNDARY_AWARE_SECRET_MATCHES=$SECRET_MATCHES"
echo "SECRET_SCAN_ERRORS=$SCAN_ERRORS"
echo "SECRET_ERROR_REPORT_LINES=$SECRET_ERROR_LINES"

[ "$NESTED_GIT_COUNT" -eq 0 ] ||
    fail "Nested Git metadata paths were staged."

[ "$STAGED_SYMLINKS" -eq 0 ] ||
    fail "Symbolic links were staged."

[ "$STAGED_GITLINKS" -eq 0 ] ||
    fail "Gitlinks or submodules were staged."

[ "$UNEXPECTED_MODES" -eq 0 ] ||
    fail "Unexpected Git file modes were staged."

[ "$FILES_AT_LEAST_100M" -eq 0 ] ||
    fail "At least one staged file is 100 MiB or larger."

[ "$SECRET_MATCHES" -eq 0 ] ||
    {
        cat "$SECRET_REPORT"
        fail "Potential credential material was detected."
    }

[ "$SCAN_ERRORS" -eq 0 ] ||
    fail "Credential scan encountered errors."

[ "$SECRET_ERROR_LINES" -eq 0 ] ||
    fail "Credential error report is not empty."

echo "PRE_COMMIT_PUBLICATION_GATE=PASS"

# ------------------------------------------------------------------
# GATE 9: Commit POLYCOMP-D4 evidence
# ------------------------------------------------------------------

echo
echo "===== GATE 9: COMMIT EVIDENCE ====="

git commit \
    -m "Add classified POLYCOMP-D4 CBMC evidence" \
    -m "Add losslessly classified POLYCOMP-D4 compressor, decompressor, retraction and quantizer-projection evidence, including raw campaign stages, immutable final packages, provenance ledgers, reports, verification scripts and bound source material."

EVIDENCE_COMMIT_BEFORE_REBASE="$(git rev-parse HEAD)"

git branch "$PRE_REBASE_BRANCH" "$EVIDENCE_COMMIT_BEFORE_REBASE"

echo "EVIDENCE_COMMIT_BEFORE_REBASE=$EVIDENCE_COMMIT_BEFORE_REBASE"
echo "PRE_REBASE_SAFETY_BRANCH=$PRE_REBASE_BRANCH"

EVIDENCE_TOTAL="$(
    git diff-tree \
        --no-commit-id \
        --name-only \
        -r \
        "$EVIDENCE_COMMIT_BEFORE_REBASE" |
    wc -l
)"

EVIDENCE_ADDED="$(
    git diff-tree \
        --no-commit-id \
        --diff-filter=A \
        --name-only \
        -r \
        "$EVIDENCE_COMMIT_BEFORE_REBASE" |
    wc -l
)"

EVIDENCE_MODIFIED="$(
    git diff-tree \
        --no-commit-id \
        --diff-filter=M \
        --name-only \
        -r \
        "$EVIDENCE_COMMIT_BEFORE_REBASE" |
    wc -l
)"

EVIDENCE_DELETED="$(
    git diff-tree \
        --no-commit-id \
        --diff-filter=D \
        --name-only \
        -r \
        "$EVIDENCE_COMMIT_BEFORE_REBASE" |
    wc -l
)"

echo "EVIDENCE_COMMIT_TOTAL=$EVIDENCE_TOTAL"
echo "EVIDENCE_COMMIT_ADDED=$EVIDENCE_ADDED"
echo "EVIDENCE_COMMIT_MODIFIED=$EVIDENCE_MODIFIED"
echo "EVIDENCE_COMMIT_DELETED=$EVIDENCE_DELETED"

[ "$EVIDENCE_TOTAL" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Evidence commit does not contain exactly 1,059 files."

[ "$EVIDENCE_ADDED" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Evidence commit does not contain exactly 1,059 additions."

[ "$EVIDENCE_MODIFIED" -eq 0 ] ||
    fail "Evidence commit unexpectedly modified existing files."

[ "$EVIDENCE_DELETED" -eq 0 ] ||
    fail "Evidence commit unexpectedly deleted files."

echo "EVIDENCE_COMMIT_GATE=PASS"

# ------------------------------------------------------------------
# GATE 10: Reconcile with current GitHub main
# ------------------------------------------------------------------

echo
echo "===== GATE 10: GITHUB RECONCILIATION ====="

git fetch origin main

AHEAD_BEFORE="$(git rev-list --count origin/main..main)"
BEHIND_BEFORE="$(git rev-list --count main..origin/main)"

echo "AHEAD_BEFORE_REBASE=$AHEAD_BEFORE"
echo "BEHIND_BEFORE_REBASE=$BEHIND_BEFORE"

if [ "$BEHIND_BEFORE" -gt 0 ]; then
    echo "GitHub has newer commits. Rebasing safely..."

    if ! git rebase origin/main; then
        git rebase --abort || true
        fail "Rebase conflict encountered. Original evidence commit remains on $PRE_REBASE_BRANCH."
    fi
fi

echo "POST_REBASE_BEHIND=$(git rev-list --count main..origin/main)"
echo "GITHUB_RECONCILIATION_GATE=PASS"

# ------------------------------------------------------------------
# GATE 11: Regenerate repository inventories
# ------------------------------------------------------------------

echo
echo "===== GATE 11: REGENERATE REPOSITORY INVENTORIES ====="

command -v tree >/dev/null ||
    fail "The tree command is not installed."

git -c core.quotepath=false ls-files |
LC_ALL=C sort > repo_tracked_tree.txt

tree -a -I '.git' . > repo_visual_tree.txt

git add -- \
    repo_tracked_tree.txt \
    repo_visual_tree.txt

INVENTORY_STAGED_TOTAL="$(
    git diff --cached --name-only |
    wc -l
)"

INVENTORY_STAGED_MODIFIED="$(
    git diff --cached \
        --diff-filter=M \
        --name-only |
    wc -l
)"

INVENTORY_STAGED_ADDED="$(
    git diff --cached \
        --diff-filter=A \
        --name-only |
    wc -l
)"

INVENTORY_STAGED_DELETED="$(
    git diff --cached \
        --diff-filter=D \
        --name-only |
    wc -l
)"

echo "INVENTORY_STAGED_TOTAL=$INVENTORY_STAGED_TOTAL"
echo "INVENTORY_STAGED_MODIFIED=$INVENTORY_STAGED_MODIFIED"
echo "INVENTORY_STAGED_ADDED=$INVENTORY_STAGED_ADDED"
echo "INVENTORY_STAGED_DELETED=$INVENTORY_STAGED_DELETED"

[ "$INVENTORY_STAGED_TOTAL" -eq 2 ] ||
    fail "Inventory regeneration staged unexpected files."

[ "$INVENTORY_STAGED_MODIFIED" -eq 2 ] ||
    fail "Both inventory files were not staged as modifications."

[ "$INVENTORY_STAGED_ADDED" -eq 0 ] ||
    fail "Inventory files unexpectedly appear as additions."

[ "$INVENTORY_STAGED_DELETED" -eq 0 ] ||
    fail "Inventory regeneration staged deletions."

EXPECTED_TRACKED="$LOG_DIR/expected_tracked_files.txt"

git -c core.quotepath=false ls-files |
LC_ALL=C sort > "$EXPECTED_TRACKED"

cmp -s "$EXPECTED_TRACKED" repo_tracked_tree.txt ||
    fail "repo_tracked_tree.txt does not match the Git index."

POLYCOMP_TRACKED_COUNT="$(
    grep -cE \
        '^(docs/POLYCOMP_D4_|experiments/polycomp-d4/|provenance/polycomp-d4-classification/|provenance/frozen-baseline/polycomp-d4/|reports/campaign-overviews/polycomp-d4/|reports/novelty-and-prior-art/polycomp-d4/|support/development-scripts/verify_polycomp_d4_classification\.sh$|upstream/mlkem-native/polycomp-d4-af4c5abd-source-binding/)' \
        repo_tracked_tree.txt ||
    true
)"

echo "POLYCOMP_TRACKED_FILE_COUNT=$POLYCOMP_TRACKED_COUNT"
echo "GIT_INDEX_FILE_COUNT=$(wc -l < "$EXPECTED_TRACKED")"
echo "VISUAL_TREE_SUMMARY=$(tail -n 1 repo_visual_tree.txt)"

[ "$POLYCOMP_TRACKED_COUNT" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Repository inventory does not list all 1,059 POLYCOMP-D4 files."

git commit \
    -m "Refresh repository inventories after POLYCOMP-D4 integration" \
    -m "Regenerate the tracked-file listing and visual repository tree after adding the classified POLYCOMP-D4 CBMC evidence."

echo "INVENTORY_COMMIT=$(git rev-parse HEAD)"
echo "INVENTORY_COMMIT_GATE=PASS"

# ------------------------------------------------------------------
# GATE 12: Final remote race check and optional second reconciliation
# ------------------------------------------------------------------

echo
echo "===== GATE 12: FINAL REMOTE-DIVERGENCE CHECK ====="

git fetch origin main

FINAL_BEHIND="$(git rev-list --count main..origin/main)"

echo "FINAL_BEHIND_BEFORE_PUSH=$FINAL_BEHIND"

if [ "$FINAL_BEHIND" -gt 0 ]; then
    git branch "$FINAL_REBASE_BRANCH" main

    echo "FINAL_REBASE_SAFETY_BRANCH=$FINAL_REBASE_BRANCH"

    if ! git rebase origin/main; then
        git rebase --abort || true
        fail "Final reconciliation conflict encountered before push."
    fi

    # Recreate inventories because GitHub gained new files.
    git -c core.quotepath=false ls-files |
    LC_ALL=C sort > repo_tracked_tree.txt

    tree -a -I '.git' . > repo_visual_tree.txt

    git add -- \
        repo_tracked_tree.txt \
        repo_visual_tree.txt

    if ! git diff --cached --quiet; then
        git commit --amend --no-edit
    fi
fi

FINAL_BEHIND="$(git rev-list --count main..origin/main)"
FINAL_AHEAD="$(git rev-list --count origin/main..main)"
FINAL_MERGE_BASE="$(git merge-base main origin/main)"
REMOTE_HEAD_BEFORE_PUSH="$(git rev-parse origin/main)"

echo "FINAL_AHEAD_BEFORE_PUSH=$FINAL_AHEAD"
echo "FINAL_BEHIND_BEFORE_PUSH=$FINAL_BEHIND"
echo "REMOTE_HEAD_BEFORE_PUSH=$REMOTE_HEAD_BEFORE_PUSH"
echo "FINAL_MERGE_BASE=$FINAL_MERGE_BASE"

[ "$FINAL_BEHIND" -eq 0 ] ||
    fail "Local main remains behind GitHub."

[ "$FINAL_AHEAD" -eq 2 ] ||
    fail "Expected exactly two unpublished POLYCOMP-D4 commits."

[ "$FINAL_MERGE_BASE" = "$REMOTE_HEAD_BEFORE_PUSH" ] ||
    fail "GitHub main is not a direct ancestor of local main."

[ "$(git status --porcelain | wc -l)" -eq 0 ] ||
    fail "Working tree is not clean before the push."

echo "FINAL_REMOTE_DIVERGENCE_GATE=PASS"

# ------------------------------------------------------------------
# GATE 13: Final commit and classification audits
# ------------------------------------------------------------------

echo
echo "===== GATE 13: FINAL LOCAL AUDIT ====="

FINAL_INVENTORY_COMMIT="$(git rev-parse HEAD)"
FINAL_EVIDENCE_COMMIT="$(git rev-parse HEAD~1)"

FINAL_EVIDENCE_TOTAL="$(
    git diff-tree \
        --no-commit-id \
        --name-only \
        -r \
        "$FINAL_EVIDENCE_COMMIT" |
    wc -l
)"

FINAL_EVIDENCE_ADDED="$(
    git diff-tree \
        --no-commit-id \
        --diff-filter=A \
        --name-only \
        -r \
        "$FINAL_EVIDENCE_COMMIT" |
    wc -l
)"

FINAL_EVIDENCE_MODIFIED="$(
    git diff-tree \
        --no-commit-id \
        --diff-filter=M \
        --name-only \
        -r \
        "$FINAL_EVIDENCE_COMMIT" |
    wc -l
)"

FINAL_EVIDENCE_DELETED="$(
    git diff-tree \
        --no-commit-id \
        --diff-filter=D \
        --name-only \
        -r \
        "$FINAL_EVIDENCE_COMMIT" |
    wc -l
)"

FINAL_INVENTORY_TOTAL="$(
    git diff-tree \
        --no-commit-id \
        --name-only \
        -r \
        "$FINAL_INVENTORY_COMMIT" |
    wc -l
)"

FINAL_INVENTORY_MODIFIED="$(
    git diff-tree \
        --no-commit-id \
        --diff-filter=M \
        --name-only \
        -r \
        "$FINAL_INVENTORY_COMMIT" |
    wc -l
)"

echo "FINAL_EVIDENCE_COMMIT=$FINAL_EVIDENCE_COMMIT"
echo "FINAL_EVIDENCE_TOTAL=$FINAL_EVIDENCE_TOTAL"
echo "FINAL_EVIDENCE_ADDED=$FINAL_EVIDENCE_ADDED"
echo "FINAL_EVIDENCE_MODIFIED=$FINAL_EVIDENCE_MODIFIED"
echo "FINAL_EVIDENCE_DELETED=$FINAL_EVIDENCE_DELETED"

echo "FINAL_INVENTORY_COMMIT=$FINAL_INVENTORY_COMMIT"
echo "FINAL_INVENTORY_TOTAL=$FINAL_INVENTORY_TOTAL"
echo "FINAL_INVENTORY_MODIFIED=$FINAL_INVENTORY_MODIFIED"

[ "$FINAL_EVIDENCE_TOTAL" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Final evidence commit does not contain exactly 1,059 files."

[ "$FINAL_EVIDENCE_ADDED" -eq "$EXPECTED_OVERLAY_FILES" ] ||
    fail "Final evidence commit does not contain exactly 1,059 additions."

[ "$FINAL_EVIDENCE_MODIFIED" -eq 0 ] ||
    fail "Final evidence commit modified existing files."

[ "$FINAL_EVIDENCE_DELETED" -eq 0 ] ||
    fail "Final evidence commit deleted files."

[ "$FINAL_INVENTORY_TOTAL" -eq 2 ] ||
    fail "Final inventory commit does not contain exactly two files."

[ "$FINAL_INVENTORY_MODIFIED" -eq 2 ] ||
    fail "Final inventory commit does not modify both inventory files."

git -c core.quotepath=false ls-files |
LC_ALL=C sort > "$EXPECTED_TRACKED"

cmp -s "$EXPECTED_TRACKED" repo_tracked_tree.txt ||
    fail "Final tracked-tree inventory does not match Git."

(
    cd "$REPO"
    bash support/development-scripts/verify_polycomp_d4_classification.sh
) > "$LOG_DIR/final_repository_verifier.log" 2>&1

tail -n 25 "$LOG_DIR/final_repository_verifier.log"

grep -q '^POLYCOMP_D4_CLASSIFICATION_VERIFY=PASS$' \
    "$LOG_DIR/final_repository_verifier.log" ||
    fail "Final POLYCOMP-D4 classification verification failed."

echo "FINAL_LOCAL_AUDIT_GATE=PASS"

echo
echo "===== COMMITS READY FOR GITHUB ====="

git log \
    --reverse \
    --format='COMMIT=%H%nDATE=%aI%nSUBJECT=%s%n' \
    origin/main..main

# ------------------------------------------------------------------
# GATE 14: Push normally — never force push
# ------------------------------------------------------------------

echo
echo "===== GATE 14: PUSHING TO GITHUB ====="

if ! git push --porcelain origin main |
     tee "$LOG_DIR/git_push.log"; then
    fail "Normal GitHub push failed. No force-push was attempted."
fi

echo "GITHUB_PUSH_COMMAND=PASS"

# ------------------------------------------------------------------
# GATE 15: Verify local and GitHub synchronization
# ------------------------------------------------------------------

echo
echo "===== GATE 15: POST-PUSH VERIFICATION ====="

git fetch origin main

LOCAL_AFTER="$(git rev-parse main)"
REMOTE_AFTER="$(git rev-parse origin/main)"
AHEAD_AFTER="$(git rev-list --count origin/main..main)"
BEHIND_AFTER="$(git rev-list --count main..origin/main)"
STATUS_AFTER="$(git status --porcelain | wc -l)"

echo "LOCAL_AFTER=$LOCAL_AFTER"
echo "REMOTE_AFTER=$REMOTE_AFTER"
echo "AHEAD_AFTER=$AHEAD_AFTER"
echo "BEHIND_AFTER=$BEHIND_AFTER"
echo "WORKING_TREE_CHANGE_LINES_AFTER=$STATUS_AFTER"

[ "$LOCAL_AFTER" = "$REMOTE_AFTER" ] ||
    fail "Local and GitHub commit hashes differ after push."

[ "$AHEAD_AFTER" -eq 0 ] ||
    fail "Local main remains ahead after push."

[ "$BEHIND_AFTER" -eq 0 ] ||
    fail "Local main remains behind after push."

[ "$STATUS_AFTER" -eq 0 ] ||
    fail "Working tree is not clean after push."

echo
echo "============================================================"
echo "POLYCOMP_D4_GITHUB_PUBLICATION=PASS"
echo "============================================================"
echo "FINAL_GITHUB_COMMIT=$REMOTE_AFTER"
echo "EVIDENCE_COMMIT=$FINAL_EVIDENCE_COMMIT"
echo "INVENTORY_COMMIT=$FINAL_INVENTORY_COMMIT"
echo "PRE_MERGE_BACKUP=$BACKUP"
echo "GIT_HISTORY_BUNDLE=$BUNDLE"
echo "PIPELINE_LOGS=$LOG_DIR"
echo
echo "===== FINAL BRANCH STATUS ====="
git status -sb
echo
echo "===== FINAL THREE COMMITS ====="
git log -3 \
    --format='COMMIT=%H%nDATE=%aI%nSUBJECT=%s%n'
