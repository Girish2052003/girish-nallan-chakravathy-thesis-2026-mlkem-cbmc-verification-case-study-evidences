#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  echo
  echo "FATAL: $*" >&2
  exit 1
}

trap 'rc=$?; echo; echo "IMPORT_ABORTED: exit=$rc line=$LINENO" >&2; exit "$rc"' ERR

PKG="$HOME/THESIS-2026/FROMMSG_GITHUB_CLASSIFIED_ADD_ONLY_CORRECTED_2026-07-31"
REPO="$HOME/THESIS-2026/CLASSIFICATION GIT/MLKEM_CBMC_FULL_CLASSIFIED_BASELINE_2026-07-19"

DEST_REL="experiments/poly-frommsg"
DEST="$REPO/$DEST_REL"

EXPECTED_FILES=29651
BRANCH="import/frommsg-classified-20260731"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
AUDIT="$HOME/THESIS-2026/FROMMSG_GITHUB_IMPORT_AUDIT_$STAMP"

mkdir -p "$AUDIT"

exec > >(tee "$AUDIT/terminal_capture.txt") 2>&1

echo "============================================================"
echo "FROMMSG SAFE GITHUB IMPORT"
echo "============================================================"
echo "UTC_STAMP=$STAMP"
echo "PACKAGE=$PKG"
echo "REPOSITORY=$REPO"
echo "DESTINATION=$DEST_REL"
echo "IMPORT_BRANCH=$BRANCH"
echo "AUDIT_DIRECTORY=$AUDIT"
echo

for tool in git git-lfs rsync python3 sha256sum find sort tee
do
  command -v "$tool" >/dev/null 2>&1 ||
    fail "missing required tool: $tool"
done

git lfs version

[[ -d "$PKG/$DEST_REL" ]] ||
  fail "package root missing: $PKG/$DEST_REL"

[[ -d "$REPO/.git" ]] ||
  fail "Git repository missing: $REPO/.git"

[[ ! -e "$DEST" ]] ||
  fail "destination already exists: $DEST"

echo
echo "===== 1. REPOSITORY IDENTITY AND CLEANLINESS ====="

TOP="$(git -C "$REPO" rev-parse --show-toplevel)"

[[ "$TOP" == "$REPO" ]] ||
  fail "unexpected repository top-level: $TOP"

CURRENT_BRANCH="$(git -C "$REPO" branch --show-current)"

[[ "$CURRENT_BRANCH" == "main" ]] ||
  fail "expected branch main, found: $CURRENT_BRANCH"

REMOTE_URL="$(git -C "$REPO" remote get-url origin)"

echo "REPOSITORY_TOP=$TOP"
echo "CURRENT_BRANCH=$CURRENT_BRANCH"
echo "ORIGIN=$REMOTE_URL"

if [[ -n "$(git -C "$REPO" status --porcelain=v1 --untracked-files=all)" ]]
then
  git -C "$REPO" status --short --untracked-files=all
  fail "repository is not clean"
fi

echo "WORKTREE_CLEAN=PASS"

echo
echo "===== 2. REMOTE SYNCHRONISATION GATE ====="

git -C "$REPO" fetch --prune origin

git -C "$REPO" show-ref --verify --quiet refs/remotes/origin/main ||
  fail "origin/main is unavailable"

read -r AHEAD BEHIND < <(
  git -C "$REPO" rev-list --left-right --count HEAD...origin/main
)

echo "LOCAL_AHEAD_OF_ORIGIN_MAIN=$AHEAD"
echo "LOCAL_BEHIND_ORIGIN_MAIN=$BEHIND"

[[ "$AHEAD" == "0" && "$BEHIND" == "0" ]] ||
  fail "local main and origin/main are not identical"

echo "MAIN_SYNC=PASS"

BASE_COMMIT="$(git -C "$REPO" rev-parse HEAD)"
BACKUP_TAG="pre-frommsg-import-$STAMP"

echo "BASE_COMMIT=$BASE_COMMIT"

git -C "$REPO" show-ref --verify --quiet "refs/heads/$BRANCH" &&
  fail "local import branch already exists: $BRANCH"

git -C "$REPO" ls-remote --exit-code --heads origin "$BRANCH" \
  >/dev/null 2>&1 &&
  fail "remote import branch already exists: $BRANCH"

git -C "$REPO" tag -a "$BACKUP_TAG" "$BASE_COMMIT" \
  -m "Backup before classified mlk_poly_frommsg import"

echo "LOCAL_BACKUP_TAG=$BACKUP_TAG"

git -C "$REPO" switch -c "$BRANCH"

echo "IMPORT_BRANCH_CREATED=PASS"

echo
echo "===== 3. PACKAGE INVENTORY, SAFETY AND HASH MANIFEST ====="

python3 - "$PKG" "$REPO" "$DEST_REL" "$EXPECTED_FILES" "$AUDIT" <<'PY'
from __future__ import annotations

import hashlib
import os
from pathlib import Path
import sys

pkg = Path(sys.argv[1])
repo = Path(sys.argv[2])
dest_rel = Path(sys.argv[3])
expected = int(sys.argv[4])
audit = Path(sys.argv[5])

root = pkg / dest_rel

files: list[tuple[str, Path, int]] = []
symlinks: list[str] = []
unsafe: list[str] = []
collisions: list[str] = []

for path in root.rglob("*"):
    relative = path.relative_to(pkg).as_posix()

    if path.is_symlink():
        symlinks.append(relative)
        continue

    if not path.is_file():
        continue

    parts = Path(relative).parts

    if not relative.startswith("experiments/poly-frommsg/"):
        unsafe.append(relative)

    if ".git" in parts or relative.startswith("/") or ".." in parts:
        unsafe.append(relative)

    if "\n" in relative or "\r" in relative or "\t" in relative:
        unsafe.append(relative)

    if os.path.lexists(repo / relative):
        collisions.append(relative)

    files.append((relative, path, path.stat().st_size))

if len(files) != expected:
    raise SystemExit(
        f"PACKAGE_FILE_COUNT_MISMATCH "
        f"expected={expected} actual={len(files)}"
    )

if symlinks:
    raise SystemExit(
        f"PACKAGE_SYMLINKS_PRESENT "
        f"count={len(symlinks)} first={symlinks[:5]}"
    )

if unsafe:
    raise SystemExit(
        f"PACKAGE_UNSAFE_PATHS "
        f"count={len(unsafe)} first={unsafe[:5]}"
    )

if collisions:
    raise SystemExit(
        f"DESTINATION_COLLISIONS "
        f"count={len(collisions)} first={collisions[:5]}"
    )

files.sort(key=lambda item: item[0])

manifest = audit / "package_sha256_manifest.tsv"
largest_report = audit / "package_largest_files.tsv"

total_bytes = 0
maximum_size = 0
maximum_path = ""

with manifest.open("w", encoding="utf-8", newline="\n") as output:
    output.write("sha256\tsize_bytes\trelative_path\n")

    for relative, path, size in files:
        digest = hashlib.sha256()

        with path.open("rb") as source:
            for chunk in iter(
                lambda: source.read(8 * 1024 * 1024),
                b"",
            ):
                digest.update(chunk)

        output.write(
            f"{digest.hexdigest()}\t{size}\t{relative}\n"
        )

        total_bytes += size

        if size > maximum_size:
            maximum_size = size
            maximum_path = relative

with largest_report.open(
    "w",
    encoding="utf-8",
    newline="\n",
) as output:
    output.write("size_bytes\trelative_path\n")

    for relative, _path, size in sorted(
        files,
        key=lambda item: item[2],
        reverse=True,
    )[:30]:
        output.write(f"{size}\t{relative}\n")

if maximum_size >= 50 * 1024 * 1024:
    raise SystemExit(
        f"UNEXPECTED_FILE_AT_OR_ABOVE_50_MIB "
        f"size={maximum_size} path={maximum_path}"
    )

print(f"PACKAGE_FILE_COUNT={len(files)}")
print(f"PACKAGE_TOTAL_BYTES={total_bytes}")
print(f"PACKAGE_MAX_FILE_BYTES={maximum_size}")
print(f"PACKAGE_MAX_FILE={maximum_path}")
print(f"PACKAGE_SYMLINK_COUNT={len(symlinks)}")
print(f"PACKAGE_UNSAFE_PATH_COUNT={len(unsafe)}")
print(
    "PACKAGE_DESTINATION_COLLISION_COUNT="
    f"{len(collisions)}"
)
print(f"PACKAGE_MANIFEST={manifest}")
print("PACKAGE_AUDIT=PASS")
PY

echo
echo "===== 4. COPY — ADD ONLY ====="

mkdir -p "$REPO/experiments"

rsync -a --itemize-changes -- \
  "$PKG/$DEST_REL/" \
  "$DEST/" \
  | tee "$AUDIT/rsync_itemized_changes.txt"

echo "RSYNC_COPY=COMPLETE"

echo
echo "===== 5. BYTE-FOR-BYTE POST-COPY VERIFICATION ====="

python3 - "$REPO" "$DEST_REL" "$EXPECTED_FILES" \
  "$AUDIT/package_sha256_manifest.tsv" "$AUDIT" <<'PY'
from __future__ import annotations

import csv
import hashlib
from pathlib import Path
import sys

repo = Path(sys.argv[1])
dest_rel = Path(sys.argv[2])
expected = int(sys.argv[3])
manifest_path = Path(sys.argv[4])
audit = Path(sys.argv[5])

expected_rows: dict[str, tuple[str, int]] = {}

with manifest_path.open(
    "r",
    encoding="utf-8",
    newline="",
) as source:
    reader = csv.DictReader(source, delimiter="\t")

    for row in reader:
        expected_rows[row["relative_path"]] = (
            row["sha256"],
            int(row["size_bytes"]),
        )

actual_paths = sorted(
    path.relative_to(repo).as_posix()
    for path in (repo / dest_rel).rglob("*")
    if path.is_file() and not path.is_symlink()
)

if len(actual_paths) != expected:
    raise SystemExit(
        f"DESTINATION_FILE_COUNT_MISMATCH "
        f"expected={expected} actual={len(actual_paths)}"
    )

missing = sorted(set(expected_rows) - set(actual_paths))
extra = sorted(set(actual_paths) - set(expected_rows))

if missing or extra:
    raise SystemExit(
        f"DESTINATION_PATH_SET_MISMATCH "
        f"missing={missing[:5]} extra={extra[:5]}"
    )

result_path = audit / "destination_sha256_validation.tsv"

with result_path.open(
    "w",
    encoding="utf-8",
    newline="\n",
) as output:
    output.write(
        "status\tsha256\tsize_bytes\trelative_path\n"
    )

    for relative in actual_paths:
        path = repo / relative

        expected_hash, expected_size = expected_rows[relative]
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

print(f"DESTINATION_FILE_COUNT={len(actual_paths)}")
print(f"DESTINATION_VALIDATION_FILE={result_path}")
print("BYTE_FOR_BYTE_COPY_VALIDATION=PASS")
PY

echo
echo "===== 6. GIT WORKTREE SCOPE GATE ====="

python3 - "$REPO" "$DEST_REL" "$EXPECTED_FILES" <<'PY'
from __future__ import annotations

import subprocess
import sys

repo, prefix, expected_value = sys.argv[1:]
expected = int(expected_value)

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
    record
    for record in output.split(b"\0")
    if record
]

wrong: list[str] = []

for record in records:
    text = record.decode("utf-8", "surrogateescape")

    if not text.startswith("?? "):
        wrong.append(text)
        continue

    path = text[3:]

    if not path.startswith(prefix + "/"):
        wrong.append(text)

if wrong:
    raise SystemExit(
        f"UNEXPECTED_WORKTREE_CHANGES "
        f"count={len(wrong)} first={wrong[:10]}"
    )

if len(records) != expected:
    raise SystemExit(
        f"UNTRACKED_COUNT_MISMATCH "
        f"expected={expected} actual={len(records)}"
    )

print(f"UNTRACKED_FROMMSG_FILES={len(records)}")
print("WORKTREE_SCOPE=PASS")
PY

echo
echo "===== 7. STAGE ONLY THE FROMMSG TREE ====="

git -C "$REPO" add -- "$DEST_REL"

python3 - "$REPO" "$DEST_REL" "$EXPECTED_FILES" <<'PY'
from __future__ import annotations

import subprocess
import sys

repo, prefix, expected_value = sys.argv[1:]
expected = int(expected_value)

output = subprocess.check_output(
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
    path.decode("utf-8", "surrogateescape")
    for path in output.split(b"\0")
    if path
]

wrong = [
    path
    for path in paths
    if not path.startswith(prefix + "/")
]

if wrong:
    raise SystemExit(
        f"STAGED_OUTSIDE_EXPECTED_ROOT "
        f"count={len(wrong)} first={wrong[:10]}"
    )

if len(paths) != expected:
    raise SystemExit(
        f"STAGED_FILE_COUNT_MISMATCH "
        f"expected={expected} actual={len(paths)}"
    )

deleted = subprocess.check_output(
    [
        "git",
        "-C",
        repo,
        "diff",
        "--cached",
        "--diff-filter=D",
        "--name-only",
        "-z",
    ]
)

if deleted:
    raise SystemExit("STAGED_DELETIONS_PRESENT")

print(f"STAGED_FROMMSG_FILES={len(paths)}")
print("STAGED_OUTSIDE_FROMMSG=0")
print("STAGED_DELETIONS=0")
print("STAGING_SCOPE=PASS")
PY

git -C "$REPO" diff --cached --stat --summary \
  > "$AUDIT/staged_diff_stat.txt"

echo "STAGED_DIFF_STAT=$AUDIT/staged_diff_stat.txt"

git -C "$REPO" diff --cached --stat=120,20 |
  tail -n 25

echo
echo "===== 8. COMMIT ====="

COMMIT_MESSAGE="Add classified mlk_poly_frommsg CBMC evidence"

git -C "$REPO" commit -m "$COMMIT_MESSAGE"

COMMIT="$(git -C "$REPO" rev-parse HEAD)"

echo "IMPORT_COMMIT=$COMMIT"

python3 - "$REPO" "$DEST_REL" "$EXPECTED_FILES" <<'PY'
from __future__ import annotations

import subprocess
import sys

repo, prefix, expected_value = sys.argv[1:]
expected = int(expected_value)

output = subprocess.check_output(
    [
        "git",
        "-C",
        repo,
        "diff-tree",
        "--no-commit-id",
        "--name-only",
        "-r",
        "-z",
        "HEAD",
    ]
)

paths = [
    path.decode("utf-8", "surrogateescape")
    for path in output.split(b"\0")
    if path
]

wrong = [
    path
    for path in paths
    if not path.startswith(prefix + "/")
]

if wrong:
    raise SystemExit(
        f"COMMIT_CONTAINS_UNEXPECTED_PATHS "
        f"count={len(wrong)} first={wrong[:10]}"
    )

if len(paths) != expected:
    raise SystemExit(
        f"COMMIT_FILE_COUNT_MISMATCH "
        f"expected={expected} actual={len(paths)}"
    )

print(f"COMMIT_FROMMSG_FILES={len(paths)}")
print("COMMIT_SCOPE=PASS")
PY

[[ -z "$(git -C "$REPO" status --porcelain=v1 --untracked-files=all)" ]] ||
  fail "worktree is not clean after commit"

echo "POST_COMMIT_WORKTREE_CLEAN=PASS"

echo
echo "===== 9. LOCAL REPOSITORY INTEGRITY ====="

git -C "$REPO" fsck --full

git -C "$REPO" count-objects -vH |
  tee "$AUDIT/git_count_objects.txt"

echo "GIT_FSCK=PASS"

echo
echo "===== 10. PUSH IMPORT BRANCH TO GITHUB ====="

git -C "$REPO" push --set-upstream origin "$BRANCH"

REMOTE_COMMIT="$(
  git -C "$REPO" ls-remote --heads origin "$BRANCH" |
    awk '{print $1}'
)"

echo "LOCAL_IMPORT_COMMIT=$COMMIT"
echo "REMOTE_IMPORT_COMMIT=$REMOTE_COMMIT"

[[ "$REMOTE_COMMIT" == "$COMMIT" ]] ||
  fail "remote branch commit does not match local commit"

echo "REMOTE_BRANCH_VERIFICATION=PASS"

{
  echo "UTC_STAMP=$STAMP"
  echo "PACKAGE=$PKG"
  echo "REPOSITORY=$REPO"
  echo "BASE_COMMIT=$BASE_COMMIT"
  echo "BACKUP_TAG=$BACKUP_TAG"
  echo "IMPORT_BRANCH=$BRANCH"
  echo "IMPORT_COMMIT=$COMMIT"
  echo "REMOTE_IMPORT_COMMIT=$REMOTE_COMMIT"
  echo "EXPECTED_FILES=$EXPECTED_FILES"
  echo "FINAL_STATUS=PASS"
} > "$AUDIT/FINAL_IMPORT_SUMMARY.txt"

echo
echo "============================================================"
echo "FROMMSG_IMPORT_BRANCH_PUSH=PASS"
echo "MAIN_BRANCH_MODIFIED=NO"
echo "IMPORT_BRANCH=$BRANCH"
echo "IMPORT_COMMIT=$COMMIT"
echo "AUDIT_DIRECTORY=$AUDIT"
echo "FINAL_SUMMARY=$AUDIT/FINAL_IMPORT_SUMMARY.txt"
echo "============================================================"
