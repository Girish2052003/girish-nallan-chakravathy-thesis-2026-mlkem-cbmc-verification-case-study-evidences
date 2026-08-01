#!/usr/bin/env bash

set -Eeuo pipefail
umask 022

REPO="/home/girish/THESIS-2026/CLASSIFICATION GIT/MLKEM_CBMC_FULL_CLASSIFIED_BASELINE_2026-07-19"

EXPERIMENT_ROOT="experiments/zeroize"
PROVENANCE_ROOT="provenance/zeroize"
ORIGINAL_ARCHIVE="$PROVENANCE_ROOT/frozen-baseline/mlk_zeroize_cleanroom.zip"

EXPECTED_BASE_HEAD="e1dc17404966d130682b8e9a54dfee5d198bab08"
EXPECTED_ARCHIVE_SIZE=1647737
EXPECTED_ARCHIVE_SHA256="5d3b4a93b2fa51e08a2ee165a01edcd67ebb5d52d29ebfebb8b4e075691d1b2f"

EXPECTED_IMPORTED_FILES=350
EXPECTED_PACKAGE_CHECKSUMS=348
EXPECTED_REPOSITORY_CHECKSUMS=51323
EXPECTED_TOTAL_STAGED_PATHS=354

COMMIT_MESSAGE="Add ML-KEM zeroize verification campaign evidence"

AUDIT="$HOME/THESIS-2026/ZEROIZE_PUSH_CONTINUATION_$(date -u +%Y%m%dT%H%M%SZ)"

export REPO EXPERIMENT_ROOT PROVENANCE_ROOT AUDIT

mkdir -p "$AUDIT"
cd "$REPO"

trap '
    rc=$?
    echo
    echo "============================================================"
    echo " SAFE STOP — STATUS $rc"
    echo "============================================================"
    printf "CURRENT_HEAD="
    git rev-parse HEAD 2>/dev/null || true
    git status --branch --short 2>/dev/null || true
    echo "AUDIT_DIRECTORY=$AUDIT"
    exit "$rc"
' ERR

echo "============================================================"
echo " ZEROIZE SAFE STAGED-STATE CONTINUATION"
echo "============================================================"

echo
echo "===== 1. MAIN-BRANCH AND BASELINE VERIFICATION ====="

CURRENT_BRANCH="$(git branch --show-current)"
CURRENT_HEAD="$(git rev-parse HEAD)"

git fetch origin

REMOTE_HEAD="$(git rev-parse origin/main)"

printf 'CURRENT_BRANCH=%s\n' "$CURRENT_BRANCH"
printf 'CURRENT_HEAD=%s\n' "$CURRENT_HEAD"
printf 'REMOTE_HEAD=%s\n' "$REMOTE_HEAD"

if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "FAIL: Current branch is not main."
    exit 1
fi

if [ "$CURRENT_HEAD" != "$EXPECTED_BASE_HEAD" ]; then
    echo "FAIL: A local commit was unexpectedly created."
    exit 1
fi

if [ "$REMOTE_HEAD" != "$EXPECTED_BASE_HEAD" ]; then
    echo "FAIL: GitHub main changed unexpectedly."
    exit 1
fi

echo "MAIN_BRANCH_CONFIRMED=PASS"
echo "SEPARATE_BRANCH_CREATED=NO"
echo "NOTHING_COMMITTED_OR_PUSHED_YET=YES"

echo
echo "===== 2. VERIFY STAGED FILE COUNTS ====="

IMPORTED_ON_DISK="$(
    find \
        "$EXPERIMENT_ROOT" \
        "$PROVENANCE_ROOT" \
        -type f |
    wc -l
)"

STAGED_IMPORTED="$(
    git diff \
        --cached \
        --name-only \
        --diff-filter=A \
        -- \
        "$EXPERIMENT_ROOT" \
        "$PROVENANCE_ROOT" |
    wc -l
)"

TOTAL_STAGED="$(
    git diff --cached --name-only |
    wc -l
)"

ADDED="$(
    git diff --cached --name-only --diff-filter=A |
    wc -l
)"

MODIFIED="$(
    git diff --cached --name-only --diff-filter=M |
    wc -l
)"

DELETED="$(
    git diff --cached --name-only --diff-filter=D |
    wc -l
)"

RENAMED="$(
    git diff --cached --name-only --diff-filter=R |
    wc -l
)"

printf 'IMPORTED_FILES_ON_DISK=%s\n' "$IMPORTED_ON_DISK"
printf 'STAGED_IMPORTED_FILES=%s\n' "$STAGED_IMPORTED"
printf 'TOTAL_STAGED_PATHS=%s\n' "$TOTAL_STAGED"
printf 'STAGED_ADDITIONS=%s\n' "$ADDED"
printf 'STAGED_MODIFICATIONS=%s\n' "$MODIFIED"
printf 'STAGED_DELETIONS=%s\n' "$DELETED"
printf 'STAGED_RENAMES=%s\n' "$RENAMED"

if [ "$IMPORTED_ON_DISK" -ne "$EXPECTED_IMPORTED_FILES" ] ||
   [ "$STAGED_IMPORTED" -ne "$EXPECTED_IMPORTED_FILES" ] ||
   [ "$TOTAL_STAGED" -ne "$EXPECTED_TOTAL_STAGED_PATHS" ] ||
   [ "$ADDED" -ne 350 ] ||
   [ "$MODIFIED" -ne 4 ] ||
   [ "$DELETED" -ne 0 ] ||
   [ "$RENAMED" -ne 0 ]; then
    echo "FAIL: Staged counts differ from the verified state."
    exit 1
fi

echo "STAGED_COUNTS=PASS"

echo
echo "===== 3. EXACT STAGED-SCOPE VERIFICATION ====="

python3 <<'PY'
from __future__ import annotations

import os
import subprocess

repo = os.environ["REPO"]

raw = subprocess.check_output(
    [
        "git",
        "-C",
        repo,
        "diff",
        "--cached",
        "--name-only",
        "-z",
    ]
)

paths = [
    os.fsdecode(item)
    for item in raw.split(b"\0")
    if item
]

allowed_roots = (
    os.environ["EXPERIMENT_ROOT"] + "/",
    os.environ["PROVENANCE_ROOT"] + "/",
)

allowed_metadata = {
    "SHA256SUMS",
    "SHA256SUMS.sha256",
    "repo_tracked_tree.txt",
    "repo_visual_tree.txt",
}

unexpected = sorted(
    path
    for path in paths
    if path not in allowed_metadata
    and not path.startswith(allowed_roots)
)

metadata = {
    path
    for path in paths
    if path in allowed_metadata
}

print(f"TOTAL_STAGED_PATHS={len(paths)}")
print(f"METADATA_PATHS={len(metadata)}")
print(f"UNEXPECTED_STAGED_PATHS={len(unexpected)}")

for path in unexpected:
    print(f"UNEXPECTED={path}")

if len(paths) != 354:
    raise SystemExit("FAIL: Expected exactly 354 staged paths.")

if metadata != allowed_metadata:
    raise SystemExit("FAIL: Repository metadata set is incorrect.")

if unexpected:
    raise SystemExit("FAIL: Unexpected staged paths detected.")

print("EXACT_STAGED_SCOPE=PASS")
PY

echo
echo "===== 4. CONFLICT AND RESIDUE VERIFICATION ====="

UNMERGED="$(git ls-files --unmerged | wc -l)"
UNSTAGED="$(git diff --name-only | wc -l)"
UNTRACKED="$(git ls-files --others --exclude-standard | wc -l)"

printf 'UNMERGED_INDEX_ENTRIES=%s\n' "$UNMERGED"
printf 'UNSTAGED_PATHS=%s\n' "$UNSTAGED"
printf 'UNTRACKED_PATHS=%s\n' "$UNTRACKED"

if [ "$UNMERGED" -ne 0 ] ||
   [ "$UNSTAGED" -ne 0 ] ||
   [ "$UNTRACKED" -ne 0 ]; then
    echo "FAIL: Repository residues or conflicts remain."
    exit 1
fi

if ! git diff --quiet -- .gitattributes; then
    echo "FAIL: Unexpected unstaged .gitattributes change."
    exit 1
fi

if ! git diff --cached --quiet -- .gitattributes; then
    echo "FAIL: Unexpected staged .gitattributes change."
    exit 1
fi

echo "NO_UNMERGED_ENTRIES=PASS"
echo "NO_UNSTAGED_RESIDUES=PASS"
echo "NO_UNTRACKED_RESIDUES=PASS"
echo "GITATTRIBUTES_UNCHANGED=PASS"

echo
echo "===== 5. VERIFY ZEROIZE PACKAGE CHECKSUMS AGAIN ====="

cd "$REPO/$PROVENANCE_ROOT"
sha256sum -c SHA256SUMS.sha256

cd "$REPO"

PACKAGE_ENTRY_COUNT="$(
    wc -l < "$PROVENANCE_ROOT/SHA256SUMS"
)"

printf 'PACKAGE_CHECKSUM_ENTRY_COUNT=%s\n' "$PACKAGE_ENTRY_COUNT"

if [ "$PACKAGE_ENTRY_COUNT" -ne "$EXPECTED_PACKAGE_CHECKSUMS" ]; then
    echo "FAIL: Package checksum-entry count changed."
    exit 1
fi

sha256sum -c "$PROVENANCE_ROOT/SHA256SUMS" \
    > "$AUDIT/package_checksum_verification.log"

PACKAGE_OK="$(
    python3 - "$AUDIT/package_checksum_verification.log" <<'PY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text(
    encoding="utf-8",
    errors="replace",
)

print(sum(
    line.endswith(": OK")
    for line in text.splitlines()
))
PY
)"

printf 'PACKAGE_CHECKSUM_OK_COUNT=%s\n' "$PACKAGE_OK"

if [ "$PACKAGE_OK" -ne "$EXPECTED_PACKAGE_CHECKSUMS" ]; then
    echo "FAIL: Zeroize package checksum verification failed."
    exit 1
fi

echo "ZEROIZE_PACKAGE_INTEGRITY=PASS"

echo
echo "===== 6. VERIFY ORIGINAL FROZEN ZIP AGAIN ====="

ARCHIVE_SIZE="$(stat -c '%s' "$ORIGINAL_ARCHIVE")"
ARCHIVE_SHA256="$(sha256sum "$ORIGINAL_ARCHIVE" | awk '{print $1}')"

printf 'ORIGINAL_ARCHIVE_SIZE=%s\n' "$ARCHIVE_SIZE"
printf 'ORIGINAL_ARCHIVE_SHA256=%s\n' "$ARCHIVE_SHA256"

if [ "$ARCHIVE_SIZE" -ne "$EXPECTED_ARCHIVE_SIZE" ] ||
   [ "$ARCHIVE_SHA256" != "$EXPECTED_ARCHIVE_SHA256" ]; then
    echo "FAIL: Frozen original ZIP identity changed."
    exit 1
fi

echo "FROZEN_ORIGINAL_ZIP=PASS"

echo
echo "===== 7. VERIFY REPOSITORY-WIDE CHECKSUMS AGAIN ====="

sha256sum -c SHA256SUMS.sha256

REPOSITORY_ENTRY_COUNT="$(wc -l < SHA256SUMS)"

printf 'REPOSITORY_CHECKSUM_ENTRY_COUNT=%s\n' \
    "$REPOSITORY_ENTRY_COUNT"

if [ "$REPOSITORY_ENTRY_COUNT" -ne \
     "$EXPECTED_REPOSITORY_CHECKSUMS" ]; then
    echo "FAIL: Repository checksum-entry count changed."
    exit 1
fi

sha256sum -c SHA256SUMS \
    > "$AUDIT/repository_checksum_verification.log"

REPOSITORY_OK="$(
    python3 - "$AUDIT/repository_checksum_verification.log" <<'PY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text(
    encoding="utf-8",
    errors="replace",
)

print(sum(
    line.endswith(": OK")
    for line in text.splitlines()
))
PY
)"

printf 'REPOSITORY_CHECKSUM_OK_COUNT=%s\n' "$REPOSITORY_OK"

if [ "$REPOSITORY_OK" -ne "$EXPECTED_REPOSITORY_CHECKSUMS" ]; then
    echo "FAIL: Repository-wide checksum verification failed."
    exit 1
fi

echo "REPOSITORY_WIDE_CHECKSUMS=PASS"

echo
echo "===== 8. NON-DESTRUCTIVE WHITESPACE ADVISORY ====="

WHITESPACE_FILE="$AUDIT/staged_whitespace_advisory.txt"

if git diff --cached --check > "$WHITESPACE_FILE" 2>&1; then
    WHITESPACE_STATUS=0
else
    WHITESPACE_STATUS=$?
fi

printf 'GIT_DIFF_CHECK_STATUS=%s\n' "$WHITESPACE_STATUS"

if grep -Eiq '^(fatal|error):' "$WHITESPACE_FILE"; then
    echo "FAIL: Git produced a fatal diff-check error."
    cat "$WHITESPACE_FILE"
    exit 1
fi

if [ "$WHITESPACE_STATUS" -ne 0 ] &&
   [ ! -s "$WHITESPACE_FILE" ]; then
    echo "FAIL: Diff check failed without a diagnostic."
    exit 1
fi

WHITESPACE_DIAGNOSTICS="$(
    python3 - "$WHITESPACE_FILE" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(
    encoding="utf-8",
    errors="replace",
)

print(sum(
    bool(re.match(r"^.+:\d+: .+$", line))
    for line in text.splitlines()
))
PY
)"

printf 'RECORDED_WHITESPACE_DIAGNOSTICS=%s\n' \
    "$WHITESPACE_DIAGNOSTICS"

if [ -s "$WHITESPACE_FILE" ]; then
    echo "FIRST_WHITESPACE_DIAGNOSTICS:"
    sed -n '1,5p' "$WHITESPACE_FILE"
fi

echo "WHITESPACE_WARNINGS_ARE_ADVISORY=YES"
echo "RAW_EVIDENCE_MODIFIED=NO"

echo
echo "===== 9. FINAL PRE-COMMIT VERIFICATION ====="

git status --short > "$AUDIT/pre_commit_status.txt"
git lfs status > "$AUDIT/pre_commit_lfs_status.txt"

echo "STAGED_CHANGE_TYPE_COUNTS:"
git diff --cached --name-status |
    cut -f1 |
    LC_ALL=C sort |
    uniq -c

echo
echo "STAGED_TOP-LEVEL_COUNTS:"
git diff --cached --name-only |
    awk -F/ '{print $1}' |
    LC_ALL=C sort |
    uniq -c

echo
echo "STAGED_SHORTSTAT:"
git diff --cached --shortstat

echo
echo "============================================================"
echo " PRE-COMMIT SAFETY PASSED"
echo "============================================================"
echo "CURRENT_BRANCH=main"
echo "SEPARATE_BRANCH_CREATED=NO"
echo "CLASSIFIED_FILES_STAGED=350"
echo "PACKAGE_CHECKSUMS_VERIFIED=348"
echo "REPOSITORY_CHECKSUMS_VERIFIED=51323"
echo "DELETIONS=0"
echo "RENAMES=0"
echo "UNMERGED_ENTRIES=0"
echo "UNSTAGED_RESIDUES=0"
echo "UNTRACKED_RESIDUES=0"
echo "RAW_EVIDENCE_PRESERVED_BYTE_EXACT=YES"
echo "NOTHING_COMMITTED_OR_PUSHED_YET=YES"

echo
read -r -p "Type exactly PUSH to commit and upload to GitHub: " CONFIRMATION

if [ "$CONFIRMATION" != "PUSH" ]; then
    echo "PUSH_CANCELLED=YES"
    echo "No commit or push was performed."
    exit 0
fi

echo
echo "===== 10. FINAL REMOTE RACE CHECK ====="

git fetch origin

LOCAL_BEFORE_COMMIT="$(git rev-parse HEAD)"
REMOTE_BEFORE_COMMIT="$(git rev-parse origin/main)"

printf 'LOCAL_HEAD_BEFORE_COMMIT=%s\n' "$LOCAL_BEFORE_COMMIT"
printf 'REMOTE_HEAD_BEFORE_COMMIT=%s\n' "$REMOTE_BEFORE_COMMIT"

if [ "$LOCAL_BEFORE_COMMIT" != "$EXPECTED_BASE_HEAD" ] ||
   [ "$REMOTE_BEFORE_COMMIT" != "$EXPECTED_BASE_HEAD" ]; then
    echo "FAIL: Local or remote main changed before commit."
    exit 1
fi

echo "REMOTE_RACE_CHECK=PASS"

echo
echo "===== 11. CREATE COMMIT ====="

git commit -m "$COMMIT_MESSAGE"

NEW_COMMIT="$(git rev-parse HEAD)"

printf 'NEW_COMMIT=%s\n' "$NEW_COMMIT"

COMMITTED_PATHS="$(
    git diff-tree \
        --no-commit-id \
        --name-only \
        -r \
        HEAD |
    wc -l
)"

printf 'COMMITTED_PATH_COUNT=%s\n' "$COMMITTED_PATHS"

if [ "$COMMITTED_PATHS" -ne "$EXPECTED_TOTAL_STAGED_PATHS" ]; then
    echo "FAIL: Commit does not contain exactly 354 paths."
    exit 1
fi

git lfs fsck

echo "LOCAL_COMMIT_VERIFICATION=PASS"

echo
echo "===== 12. PUSH TO GITHUB MAIN ====="

git push origin main

echo
echo "===== 13. VERIFY GITHUB REMOTE ====="

git fetch origin

REMOTE_AFTER="$(git rev-parse origin/main)"

read -r LOCAL_ONLY REMOTE_ONLY <<< "$(
    git rev-list --left-right --count HEAD...origin/main
)"

printf 'LOCAL_COMMIT=%s\n' "$NEW_COMMIT"
printf 'REMOTE_COMMIT=%s\n' "$REMOTE_AFTER"
printf 'LOCAL_ONLY_COMMITS=%s\n' "$LOCAL_ONLY"
printf 'REMOTE_ONLY_COMMITS=%s\n' "$REMOTE_ONLY"

if [ "$REMOTE_AFTER" != "$NEW_COMMIT" ] ||
   [ "$LOCAL_ONLY" -ne 0 ] ||
   [ "$REMOTE_ONLY" -ne 0 ]; then
    echo "FAIL: GitHub main verification failed."
    exit 1
fi

echo "REMOTE_COMMIT_VERIFICATION=PASS"

echo
echo "===== 14. FINAL CLEANLINESS ====="

git status --branch --short

if [ -n "$(git status --porcelain)" ]; then
    echo "FAIL: Repository is not clean after push."
    git status --short
    exit 1
fi

git lfs status

echo
echo "============================================================"
echo " SUCCESS: ZEROIZE CAMPAIGN PUSHED SAFELY"
echo "============================================================"
echo "PUSHED_COMMIT=$NEW_COMMIT"
echo "REMOTE_COMMIT=$REMOTE_AFTER"
echo "CURRENT_BRANCH=main"
echo "SEPARATE_BRANCH_CREATED=NO"
echo "CLASSIFIED_FILES_IMPORTED=350"
echo "PACKAGE_CHECKSUMS_VERIFIED=348"
echo "COMMITTED_PATHS=$COMMITTED_PATHS"
echo "DELETIONS=0"
echo "RENAMES=0"
echo "UNMERGED_ENTRIES=0"
echo "UNSTAGED_RESIDUES=0"
echo "UNTRACKED_RESIDUES=0"
echo "RAW_EVIDENCE_PRESERVED_BYTE_EXACT=YES"
echo "REMOTE_VERIFIED=YES"
echo "WORKTREE_CLEAN=YES"
echo "AUDIT_DIRECTORY=$AUDIT"
