#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  echo
  echo "FATAL: $*" >&2
  exit 1
}

trap 'rc=$?; echo; echo "RESUME_ABORTED: exit=$rc line=$LINENO" >&2; exit "$rc"' ERR

PKG="$HOME/THESIS-2026/FROMMSG_GITHUB_CLASSIFIED_ADD_ONLY_CORRECTED_2026-07-31"
REPO="$HOME/THESIS-2026/CLASSIFICATION GIT/MLKEM_CBMC_FULL_CLASSIFIED_BASELINE_2026-07-19"

DEST_REL="experiments/poly-frommsg"
DEST="$REPO/$DEST_REL"

AUDIT="$HOME/THESIS-2026/FROMMSG_GITHUB_IMPORT_AUDIT_20260731T180028Z"
MANIFEST="$AUDIT/package_sha256_manifest.tsv"

EXPECTED_FILES=29651
EXPECTED_VISIBLE=29579
EXPECTED_IGNORED=72
BRANCH="import/frommsg-classified-20260731"

RESUME_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RESUME_LOG="$AUDIT/resume_terminal_capture_$RESUME_STAMP.txt"

mkdir -p "$AUDIT"

exec > >(tee "$RESUME_LOG") 2>&1

echo "============================================================"
echo "FROMMSG SAFE IMPORT — RESUME AFTER IGNORE-RULE DIAGNOSIS"
echo "============================================================"
echo "UTC_TIME=$RESUME_STAMP"
echo "PACKAGE=$PKG"
echo "REPOSITORY=$REPO"
echo "DESTINATION=$DEST_REL"
echo "AUDIT_DIRECTORY=$AUDIT"
echo "RESUME_LOG=$RESUME_LOG"
echo

for tool in git git-lfs python3 sha256sum find sort awk tee
do
  command -v "$tool" >/dev/null 2>&1 ||
    fail "missing required tool: $tool"
done

[[ -d "$PKG/$DEST_REL" ]] ||
  fail "package source tree is missing"

[[ -d "$REPO/.git" ]] ||
  fail "Git repository is missing"

[[ -d "$DEST" ]] ||
  fail "copied destination tree is missing"

[[ -f "$MANIFEST" ]] ||
  fail "package SHA-256 manifest is missing: $MANIFEST"

echo
echo "===== 1. BRANCH AND REPOSITORY STATE ====="

TOP="$(git -C "$REPO" rev-parse --show-toplevel)"
CURRENT_BRANCH="$(git -C "$REPO" branch --show-current)"

echo "REPOSITORY_TOP=$TOP"
echo "CURRENT_BRANCH=$CURRENT_BRANCH"

[[ "$TOP" == "$REPO" ]] ||
  fail "unexpected repository top-level"

[[ "$CURRENT_BRANCH" == "$BRANCH" ]] ||
  fail "expected branch $BRANCH, found $CURRENT_BRANCH"

git -C "$REPO" fetch --prune origin

git -C "$REPO" show-ref --verify --quiet refs/remotes/origin/main ||
  fail "origin/main is unavailable"

LOCAL_HEAD="$(git -C "$REPO" rev-parse HEAD)"
REMOTE_MAIN="$(git -C "$REPO" rev-parse origin/main)"

echo "LOCAL_HEAD=$LOCAL_HEAD"
echo "ORIGIN_MAIN=$REMOTE_MAIN"

[[ "$LOCAL_HEAD" == "$REMOTE_MAIN" ]] ||
  fail "import branch no longer begins exactly at origin/main"

git -C "$REPO" diff --quiet ||
  fail "tracked unstaged changes already exist"

git -C "$REPO" diff --cached --quiet ||
  fail "staged changes already exist"

TRACKED_DEST_COUNT="$(
  git -C "$REPO" ls-files -z -- "$DEST_REL" |
    python3 -c 'import sys; print(len([x for x in sys.stdin.buffer.read().split(b"\0") if x]))'
)"

echo "ALREADY_TRACKED_DESTINATION_FILES=$TRACKED_DEST_COUNT"

[[ "$TRACKED_DEST_COUNT" == "0" ]] ||
  fail "destination unexpectedly contains tracked files"

echo "PRE_RESUME_REPOSITORY_STATE=PASS"

echo
echo "===== 2. CLASSIFY VISIBLE AND IGNORED FILES ====="

git -C "$REPO" \
  ls-files --others --exclude-standard -- "$DEST_REL" \
  | sort \
  > "$AUDIT/untracked_visible_files.txt"

git -C "$REPO" \
  ls-files --others --ignored --exclude-standard -- "$DEST_REL" \
  | sort \
  > "$AUDIT/untracked_ignored_files.txt"

VISIBLE_COUNT="$(wc -l < "$AUDIT/untracked_visible_files.txt")"
IGNORED_COUNT="$(wc -l < "$AUDIT/untracked_ignored_files.txt")"
COMBINED_COUNT="$((VISIBLE_COUNT + IGNORED_COUNT))"

echo "VISIBLE_UNTRACKED_COUNT=$VISIBLE_COUNT"
echo "IGNORED_UNTRACKED_COUNT=$IGNORED_COUNT"
echo "COMBINED_UNTRACKED_COUNT=$COMBINED_COUNT"

[[ "$VISIBLE_COUNT" == "$EXPECTED_VISIBLE" ]] ||
  fail "unexpected visible-untracked count"

[[ "$IGNORED_COUNT" == "$EXPECTED_IGNORED" ]] ||
  fail "unexpected ignored-file count"

[[ "$COMBINED_COUNT" == "$EXPECTED_FILES" ]] ||
  fail "visible plus ignored files do not equal package file count"

echo
echo "===== 3. RECORD EXACT IGNORE RULES ====="

: > "$AUDIT/ignored_file_rule_explanations.txt"

while IFS= read -r path
do
  [[ -n "$path" ]] || continue

  git -C "$REPO" check-ignore -v -- "$path" \
    >> "$AUDIT/ignored_file_rule_explanations.txt"
done < "$AUDIT/untracked_ignored_files.txt"

echo "IGNORED_FILE_LIST=$AUDIT/untracked_ignored_files.txt"
echo "IGNORE_RULE_REPORT=$AUDIT/ignored_file_rule_explanations.txt"

echo
echo "First ignored-file rule explanations:"
head -n 25 "$AUDIT/ignored_file_rule_explanations.txt" || true

echo
echo "===== 4. EXACT FILE-SET COMPARISON ====="

python3 - "$REPO" "$DEST_REL" "$EXPECTED_FILES" \
  "$AUDIT/untracked_visible_files.txt" \
  "$AUDIT/untracked_ignored_files.txt" <<'PY'
from __future__ import annotations

from pathlib import Path
import sys

repo = Path(sys.argv[1])
dest_rel = Path(sys.argv[2])
expected = int(sys.argv[3])
visible_file = Path(sys.argv[4])
ignored_file = Path(sys.argv[5])

actual = {
    path.relative_to(repo).as_posix()
    for path in (repo / dest_rel).rglob("*")
    if path.is_file() and not path.is_symlink()
}

visible = {
    line
    for line in visible_file.read_text(
        encoding="utf-8",
        errors="surrogateescape",
    ).splitlines()
    if line
}

ignored = {
    line
    for line in ignored_file.read_text(
        encoding="utf-8",
        errors="surrogateescape",
    ).splitlines()
    if line
}

if visible & ignored:
    raise SystemExit(
        f"VISIBLE_IGNORED_OVERLAP={len(visible & ignored)}"
    )

combined = visible | ignored

missing_from_git_classification = sorted(actual - combined)
not_present_on_disk = sorted(combined - actual)

if len(actual) != expected:
    raise SystemExit(
        f"FILESYSTEM_COUNT_MISMATCH "
        f"expected={expected} actual={len(actual)}"
    )

if missing_from_git_classification:
    raise SystemExit(
        "FILES_MISSING_FROM_GIT_CLASSIFICATION "
        f"count={len(missing_from_git_classification)} "
        f"first={missing_from_git_classification[:10]}"
    )

if not_present_on_disk:
    raise SystemExit(
        "CLASSIFIED_PATHS_NOT_ON_DISK "
        f"count={len(not_present_on_disk)} "
        f"first={not_present_on_disk[:10]}"
    )

wrong_root = sorted(
    path
    for path in combined
    if not path.startswith("experiments/poly-frommsg/")
)

if wrong_root:
    raise SystemExit(
        f"OUTSIDE_DESTINATION_ROOT "
        f"count={len(wrong_root)} first={wrong_root[:10]}"
    )

print(f"FILESYSTEM_FILE_COUNT={len(actual)}")
print(f"VISIBLE_PATH_COUNT={len(visible)}")
print(f"IGNORED_PATH_COUNT={len(ignored)}")
print("VISIBLE_PLUS_IGNORED_EQUALS_FILESYSTEM=PASS")
print("ALL_PATHS_INSIDE_FROMMSG_ROOT=PASS")
PY

echo
echo "===== 5. REPEAT BYTE-FOR-BYTE MANIFEST VALIDATION ====="

python3 - "$REPO" "$DEST_REL" "$EXPECTED_FILES" "$MANIFEST" "$AUDIT" <<'PY'
from __future__ import annotations

import csv
import hashlib
from pathlib import Path
import sys

repo = Path(sys.argv[1])
dest_rel = Path(sys.argv[2])
expected_count = int(sys.argv[3])
manifest_path = Path(sys.argv[4])
audit = Path(sys.argv[5])

expected: dict[str, tuple[str, int]] = {}

with manifest_path.open(
    "r",
    encoding="utf-8",
    newline="",
) as source:
    reader = csv.DictReader(source, delimiter="\t")

    for row in reader:
        expected[row["relative_path"]] = (
            row["sha256"],
            int(row["size_bytes"]),
        )

if len(expected) != expected_count:
    raise SystemExit(
        f"MANIFEST_ENTRY_COUNT_MISMATCH "
        f"expected={expected_count} actual={len(expected)}"
    )

actual_paths = sorted(
    path.relative_to(repo).as_posix()
    for path in (repo / dest_rel).rglob("*")
    if path.is_file() and not path.is_symlink()
)

if len(actual_paths) != expected_count:
    raise SystemExit(
        f"DESTINATION_FILE_COUNT_MISMATCH "
        f"expected={expected_count} actual={len(actual_paths)}"
    )

missing = sorted(set(expected) - set(actual_paths))
extra = sorted(set(actual_paths) - set(expected))

if missing or extra:
    raise SystemExit(
        f"MANIFEST_PATH_SET_MISMATCH "
        f"missing={missing[:10]} extra={extra[:10]}"
    )

result_file = audit / "resume_sha256_validation.tsv"

with result_file.open(
    "w",
    encoding="utf-8",
    newline="\n",
) as output:
    output.write(
        "status\tsha256\tsize_bytes\trelative_path\n"
    )

    for number, relative in enumerate(actual_paths, start=1):
        path = repo / relative
        expected_hash, expected_size = expected[relative]
        actual_size = path.stat().st_size

        if actual_size != expected_size:
            raise SystemExit(
                f"SIZE_MISMATCH path={relative} "
                f"expected={expected_size} actual={actual_size}"
            )

        digest = hashlib.sha256()

        with path.open("rb") as source:
            for chunk in iter(
                lambda: source.read(8 * 1024 * 1024),
                b"",
            ):
                digest.update(chunk)

        actual_hash = digest.hexdigest()

        if actual_hash != expected_hash:
            raise SystemExit(
                f"SHA256_MISMATCH path={relative} "
                f"expected={expected_hash} actual={actual_hash}"
            )

        output.write(
            f"PASS\t{actual_hash}\t"
            f"{actual_size}\t{relative}\n"
        )

        if number % 2500 == 0:
            print(
                f"SHA256_PROGRESS={number}/{expected_count}"
            )

print(f"SHA256_VALIDATED_FILES={len(actual_paths)}")
print(f"SHA256_VALIDATION_REPORT={result_file}")
print("BYTE_FOR_BYTE_REVALIDATION=PASS")
PY

echo
echo "===== 6. VERIFY NO UNRELATED WORKTREE CHANGES ====="

python3 - "$REPO" "$DEST_REL" <<'PY'
from __future__ import annotations

import subprocess
import sys

repo = sys.argv[1]
prefix = sys.argv[2] + "/"

output = subprocess.check_output(
    [
        "git",
        "-C",
        repo,
        "status",
        "--porcelain=v1",
        "-z",
        "--untracked-files=all",
    ]
)

records = [
    record.decode("utf-8", "surrogateescape")
    for record in output.split(b"\0")
    if record
]

wrong = []

for record in records:
    if not record.startswith("?? "):
        wrong.append(record)
        continue

    path = record[3:]

    if not path.startswith(prefix):
        wrong.append(record)

if wrong:
    raise SystemExit(
        f"UNRELATED_WORKTREE_CHANGES "
        f"count={len(wrong)} first={wrong[:10]}"
    )

print(f"VISIBLE_WORKTREE_RECORDS={len(records)}")
print("WORKTREE_SCOPE_BEFORE_STAGING=PASS")
PY

echo
echo "===== 7. FORCE-STAGE VERIFIED TREE INCLUDING 72 IGNORED FILES ====="

git -C "$REPO" add -f -- "$DEST_REL"

echo "GIT_ADD_FORCE_COMPLETED=PASS"

echo
echo "===== 8. STAGED INDEX SCOPE AND COUNT GATE ====="

python3 - "$REPO" "$DEST_REL" "$EXPECTED_FILES" <<'PY'
from __future__ import annotations

import subprocess
import sys

repo = sys.argv[1]
prefix = sys.argv[2] + "/"
expected = int(sys.argv[3])

name_output = subprocess.check_output(
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
    item.decode("utf-8", "surrogateescape")
    for item in name_output.split(b"\0")
    if item
]

if len(paths) != expected:
    raise SystemExit(
        f"STAGED_FILE_COUNT_MISMATCH "
        f"expected={expected} actual={len(paths)}"
    )

wrong_root = sorted(
    path for path in paths
    if not path.startswith(prefix)
)

if wrong_root:
    raise SystemExit(
        f"STAGED_OUTSIDE_FROMMSG "
        f"count={len(wrong_root)} first={wrong_root[:10]}"
    )

status_output = subprocess.check_output(
    [
        "git",
        "-C",
        repo,
        "diff",
        "--cached",
        "--name-status",
    ],
    text=True,
)

non_additions = [
    line
    for line in status_output.splitlines()
    if line and not line.startswith("A\t")
]

if non_additions:
    raise SystemExit(
        f"STAGED_NON_ADDITIONS "
        f"count={len(non_additions)} "
        f"first={non_additions[:10]}"
    )

index_output = subprocess.check_output(
    [
        "git",
        "-C",
        repo,
        "ls-files",
        "-z",
        "--",
        sys.argv[2],
    ]
)

index_paths = [
    item
    for item in index_output.split(b"\0")
    if item
]

if len(index_paths) != expected:
    raise SystemExit(
        f"INDEX_FILE_COUNT_MISMATCH "
        f"expected={expected} actual={len(index_paths)}"
    )

print(f"STAGED_FILE_COUNT={len(paths)}")
print(f"INDEX_FILE_COUNT={len(index_paths)}")
print("STAGED_OUTSIDE_FROMMSG=0")
print("STAGED_MODIFICATIONS=0")
print("STAGED_DELETIONS=0")
print("STAGING_SCOPE=PASS")
PY

git -C "$REPO" diff --cached --stat --summary \
  > "$AUDIT/resume_staged_diff_stat.txt"

git -C "$REPO" diff --cached --stat=120,20 |
  tail -n 30

echo
echo "===== 9. GIT LFS INSPECTION ====="

git -C "$REPO" lfs status |
  tee "$AUDIT/git_lfs_status_before_commit.txt"

git -C "$REPO" lfs ls-files --name-only \
  | grep "^$DEST_REL/" \
  > "$AUDIT/frommsg_lfs_paths.txt" || true

FROMMSG_LFS_COUNT="$(
  wc -l < "$AUDIT/frommsg_lfs_paths.txt"
)"

echo "FROMMSG_LFS_TRACKED_FILE_COUNT=$FROMMSG_LFS_COUNT"
echo "FROMMSG_LFS_PATH_REPORT=$AUDIT/frommsg_lfs_paths.txt"

git -C "$REPO" write-tree \
  > "$AUDIT/staged_tree_object.txt"

echo "INDEX_WRITE_TREE=PASS"

echo
echo "===== 10. COMMIT THE IMPORT BRANCH ====="

COMMIT_MESSAGE="Add classified mlk_poly_frommsg CBMC evidence"

git -C "$REPO" commit -m "$COMMIT_MESSAGE"

COMMIT="$(git -C "$REPO" rev-parse HEAD)"

echo "IMPORT_COMMIT=$COMMIT"

echo
echo "===== 11. VERIFY THE CREATED COMMIT ====="

python3 - "$REPO" "$DEST_REL" "$EXPECTED_FILES" <<'PY'
from __future__ import annotations

import subprocess
import sys

repo = sys.argv[1]
prefix = sys.argv[2] + "/"
expected = int(sys.argv[3])

output = subprocess.check_output(
    [
        "git",
        "-C",
        repo,
        "diff-tree",
        "--no-commit-id",
        "--name-status",
        "-r",
        "HEAD",
    ],
    text=True,
)

records = [
    line
    for line in output.splitlines()
    if line
]

if len(records) != expected:
    raise SystemExit(
        f"COMMIT_RECORD_COUNT_MISMATCH "
        f"expected={expected} actual={len(records)}"
    )

non_additions = [
    line
    for line in records
    if not line.startswith("A\t")
]

if non_additions:
    raise SystemExit(
        f"COMMIT_NON_ADDITIONS "
        f"count={len(non_additions)} "
        f"first={non_additions[:10]}"
    )

wrong_root = []

for line in records:
    _, path = line.split("\t", 1)

    if not path.startswith(prefix):
        wrong_root.append(path)

if wrong_root:
    raise SystemExit(
        f"COMMIT_PATHS_OUTSIDE_FROMMSG "
        f"count={len(wrong_root)} first={wrong_root[:10]}"
    )

print(f"COMMIT_ADDED_FILE_COUNT={len(records)}")
print("COMMIT_ONLY_ADDITIONS=PASS")
print("COMMIT_SCOPE=PASS")
PY

if [[ -n "$(
  git -C "$REPO" status \
    --porcelain=v1 \
    --untracked-files=all
)" ]]
then
  git -C "$REPO" status --short --untracked-files=all
  fail "worktree is not clean after commit"
fi

echo "POST_COMMIT_WORKTREE_CLEAN=PASS"

echo
echo "===== 12. LOCAL GIT OBJECT INTEGRITY ====="

git -C "$REPO" fsck --full

git -C "$REPO" count-objects -vH \
  | tee "$AUDIT/git_count_objects_after_commit.txt"

echo "GIT_FSCK=PASS"

echo
echo "===== 13. CONFIRM REMOTE IMPORT BRANCH IS ABSENT ====="

if git -C "$REPO" \
  ls-remote --exit-code --heads origin "$BRANCH" \
  >/dev/null 2>&1
then
  fail "remote import branch already exists unexpectedly"
fi

echo "REMOTE_IMPORT_BRANCH_ABSENT=PASS"

echo
echo "===== 14. PUSH ONLY THE IMPORT BRANCH ====="

git -C "$REPO" push --set-upstream origin "$BRANCH"

REMOTE_COMMIT="$(
  git -C "$REPO" ls-remote --heads origin "$BRANCH" |
    awk '{print $1}'
)"

echo "LOCAL_IMPORT_COMMIT=$COMMIT"
echo "REMOTE_IMPORT_COMMIT=$REMOTE_COMMIT"

[[ "$REMOTE_COMMIT" == "$COMMIT" ]] ||
  fail "remote branch commit does not equal local commit"

echo "REMOTE_COMMIT_MATCH=PASS"

echo
echo "===== 15. WRITE FINAL RESUME SUMMARY ====="

{
  echo "UTC_TIME=$RESUME_STAMP"
  echo "PACKAGE=$PKG"
  echo "REPOSITORY=$REPO"
  echo "DESTINATION=$DEST_REL"
  echo "IMPORT_BRANCH=$BRANCH"
  echo "VISIBLE_UNTRACKED_FILES=$VISIBLE_COUNT"
  echo "IGNORED_UNTRACKED_FILES=$IGNORED_COUNT"
  echo "TOTAL_IMPORTED_FILES=$EXPECTED_FILES"
  echo "IMPORT_COMMIT=$COMMIT"
  echo "REMOTE_IMPORT_COMMIT=$REMOTE_COMMIT"
  echo "MAIN_BRANCH_MODIFIED=NO"
  echo "FINAL_STATUS=PASS"
} > "$AUDIT/FINAL_RESUME_IMPORT_SUMMARY.txt"

echo
echo "============================================================"
echo "FROMMSG_IMPORT_BRANCH_PUSH=PASS"
echo "MAIN_BRANCH_MODIFIED=NO"
echo "VISIBLE_FILES=$VISIBLE_COUNT"
echo "IGNORED_FILES_FORCE_ADDED=$IGNORED_COUNT"
echo "TOTAL_IMPORTED_FILES=$EXPECTED_FILES"
echo "IMPORT_BRANCH=$BRANCH"
echo "IMPORT_COMMIT=$COMMIT"
echo "REMOTE_IMPORT_COMMIT=$REMOTE_COMMIT"
echo "FINAL_SUMMARY=$AUDIT/FINAL_RESUME_IMPORT_SUMMARY.txt"
echo "============================================================"
