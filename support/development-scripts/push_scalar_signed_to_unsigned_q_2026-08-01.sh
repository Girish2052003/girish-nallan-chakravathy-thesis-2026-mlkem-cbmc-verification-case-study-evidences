#!/usr/bin/env bash

set -euo pipefail
umask 022

SOURCE="/home/girish/THESIS-2026/MLK_SCALAR_SIGNED_TO_UNSIGNED_Q_CLASSIFIED_MERGE_READY_2026-08-01"

REPO="/home/girish/THESIS-2026/CLASSIFICATION GIT/MLKEM_CBMC_FULL_CLASSIFIED_BASELINE_2026-07-19"

EXPERIMENT_ROOT="experiments/scalar-signed-to-unsigned-q"
PROVENANCE_ROOT="provenance/scalar-signed-to-unsigned-q"

ARCHIVE="$PROVENANCE_ROOT/frozen-baseline/mlk_scalar_signed_to_unsigned_q_cleanroom.zip"

PACKAGE_SUMS="$PROVENANCE_ROOT/SHA256SUMS"
PACKAGE_SUMS_HASH="$PROVENANCE_ROOT/SHA256SUMS.sha256"

EXPECTED_PACKAGE_FILES=1486
EXPECTED_PACKAGE_SUMS=1484
EXPECTED_ARCHIVE_SIZE=119320741
EXPECTED_ARCHIVE_SHA256="1939e441b3d3d10b6445a83f7497d927d37c93ae111dcb2ae0cfab6af92bb40c"

COMMIT_MESSAGE="Add ML-KEM scalar signed-to-unsigned-q verification campaign evidence"

AUDIT="$HOME/THESIS-2026/SCALAR_SIGNED_TO_UNSIGNED_Q_PUSH_AUDIT_$(date -u +%Y%m%dT%H%M%SZ)"

export SOURCE
export REPO
export EXPERIMENT_ROOT
export PROVENANCE_ROOT
export ARCHIVE
export PACKAGE_SUMS
export PACKAGE_SUMS_HASH
export AUDIT

mkdir -p "$AUDIT"

echo "================================================================"
echo " ML-KEM SCALAR SIGNED-TO-UNSIGNED-Q CONTROLLED IMPORT AND PUSH"
echo "================================================================"

printf 'SOURCE=%s\n' "$SOURCE"
printf 'REPOSITORY=%s\n' "$REPO"
printf 'AUDIT_DIRECTORY=%s\n' "$AUDIT"

echo
echo "===== 1. REQUIRED TOOL GATE ====="

for command_name in \
    git \
    git-lfs \
    rsync \
    sha256sum \
    python3 \
    tree \
    stat
do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "FAIL_MISSING_COMMAND=$command_name"
        exit 1
    fi

    echo "FOUND_COMMAND=$command_name"
done

git lfs version

echo
echo "===== 2. SOURCE STRUCTURE GATE ====="

test -d "$SOURCE"
test -d "$SOURCE/$EXPERIMENT_ROOT"
test -d "$SOURCE/$PROVENANCE_ROOT"
test -f "$SOURCE/$PACKAGE_SUMS"
test -f "$SOURCE/$PACKAGE_SUMS_HASH"
test -f "$SOURCE/$ARCHIVE"

ACTUAL_TOP_LEVEL="$(
    find "$SOURCE" \
        -mindepth 1 \
        -maxdepth 1 \
        -printf '%f\n' |
    LC_ALL=C sort
)"

EXPECTED_TOP_LEVEL="$(
    printf '%s\n' experiments provenance |
    LC_ALL=C sort
)"

printf '%s\n' "$ACTUAL_TOP_LEVEL"

if [ "$ACTUAL_TOP_LEVEL" != "$EXPECTED_TOP_LEVEL" ]; then
    echo "FAIL: Unexpected top-level item in classified package."
    exit 1
fi

echo "SOURCE_TOP_LEVEL_STRUCTURE=PASS"

echo
echo "===== 3. SOURCE FILE COUNT AND SPECIAL-FILE GATE ====="

SOURCE_FILE_COUNT="$(
    find "$SOURCE" -type f | wc -l
)"

SOURCE_SYMLINK_COUNT="$(
    find "$SOURCE" -type l | wc -l
)"

SOURCE_NESTED_GIT_COUNT="$(
    find "$SOURCE" \
        \( -name '.git' -o -path '*/.git/*' \) \
        -print |
    wc -l
)"

printf 'SOURCE_FILE_COUNT=%s\n' "$SOURCE_FILE_COUNT"
printf 'SOURCE_SYMLINK_COUNT=%s\n' "$SOURCE_SYMLINK_COUNT"
printf 'SOURCE_NESTED_GIT_METADATA_COUNT=%s\n' \
    "$SOURCE_NESTED_GIT_COUNT"

if [ "$SOURCE_FILE_COUNT" -ne "$EXPECTED_PACKAGE_FILES" ]; then
    echo "FAIL: Expected $EXPECTED_PACKAGE_FILES source files."
    exit 1
fi

if [ "$SOURCE_SYMLINK_COUNT" -ne 0 ]; then
    echo "FAIL: Source package contains symlinks."
    find "$SOURCE" -type l -printf '%P -> %l\n'
    exit 1
fi

if [ "$SOURCE_NESTED_GIT_COUNT" -ne 0 ]; then
    echo "FAIL: Source package contains nested Git metadata."
    exit 1
fi

echo "SOURCE_SPECIAL_FILE_SAFETY=PASS"

echo
echo "===== 4. VERIFY CLASSIFIED PACKAGE CHECKSUMS ====="

cd "$SOURCE/$PROVENANCE_ROOT"

sha256sum -c SHA256SUMS.sha256

cd "$SOURCE"

PACKAGE_SUM_COUNT="$(
    wc -l < "$PACKAGE_SUMS"
)"

printf 'PACKAGE_CHECKSUM_ENTRY_COUNT=%s\n' "$PACKAGE_SUM_COUNT"

if [ "$PACKAGE_SUM_COUNT" -ne "$EXPECTED_PACKAGE_SUMS" ]; then
    echo "FAIL: Expected $EXPECTED_PACKAGE_SUMS package checksum entries."
    exit 1
fi

sha256sum -c "$PACKAGE_SUMS" \
    > "$AUDIT/source_package_checksum_verification.log"

SOURCE_CHECKSUM_OK_COUNT="$(
    python3 - "$AUDIT/source_package_checksum_verification.log" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

count = sum(
    1
    for line in path.read_text(
        encoding="utf-8",
        errors="replace",
    ).splitlines()
    if line.endswith(": OK")
)

print(count)
PY
)"

printf 'SOURCE_CHECKSUM_OK_COUNT=%s\n' \
    "$SOURCE_CHECKSUM_OK_COUNT"

if [ "$SOURCE_CHECKSUM_OK_COUNT" -ne "$EXPECTED_PACKAGE_SUMS" ]; then
    echo "FAIL: One or more classified-package checksums failed."
    exit 1
fi

echo "SOURCE_PACKAGE_INTEGRITY=PASS"

echo
echo "===== 5. VERIFY FROZEN ORIGINAL ARCHIVE ====="

SOURCE_ARCHIVE="$SOURCE/$ARCHIVE"

ACTUAL_ARCHIVE_SIZE="$(
    stat -c '%s' "$SOURCE_ARCHIVE"
)"

ACTUAL_ARCHIVE_SHA256="$(
    sha256sum "$SOURCE_ARCHIVE" |
    awk '{print $1}'
)"

printf 'ARCHIVE_SIZE=%s\n' "$ACTUAL_ARCHIVE_SIZE"
printf 'ARCHIVE_SHA256=%s\n' "$ACTUAL_ARCHIVE_SHA256"

if [ "$ACTUAL_ARCHIVE_SIZE" -ne "$EXPECTED_ARCHIVE_SIZE" ]; then
    echo "FAIL: Frozen archive size does not match classification audit."
    exit 1
fi

if [ "$ACTUAL_ARCHIVE_SHA256" != "$EXPECTED_ARCHIVE_SHA256" ]; then
    echo "FAIL: Frozen archive SHA-256 does not match classification audit."
    exit 1
fi

echo "FROZEN_ORIGINAL_ARCHIVE_IDENTITY=PASS"

echo
echo "===== 6. REPOSITORY IDENTITY AND CLEANLINESS ====="

test -d "$REPO/.git"

cd "$REPO"

REPO_TOPLEVEL="$(git rev-parse --show-toplevel)"
REPO_BRANCH="$(git branch --show-current)"

printf 'REPOSITORY_TOPLEVEL=%s\n' "$REPO_TOPLEVEL"
printf 'REPOSITORY_BRANCH=%s\n' "$REPO_BRANCH"
printf 'LOCAL_HEAD_BEFORE=%s\n' "$(git rev-parse HEAD)"

if [ "$REPO_TOPLEVEL" != "$REPO" ]; then
    echo "FAIL: Configured path is not the Git repository top level."
    exit 1
fi

if [ "$REPO_BRANCH" != "main" ]; then
    echo "FAIL: Repository is not on main."
    exit 1
fi

git status --branch --short

if [ -n "$(git status --porcelain)" ]; then
    echo "FAIL: Repository is not clean before import."
    exit 1
fi

echo "REPOSITORY_CLEAN_BEFORE_IMPORT=PASS"

echo
echo "===== 7. LOCAL-REMOTE SYNCHRONIZATION ====="

git fetch origin

read -r LEFT_COUNT RIGHT_COUNT <<< "$(
    git rev-list --left-right --count HEAD...origin/main
)"

printf 'LOCAL_ONLY_COMMITS=%s\n' "$LEFT_COUNT"
printf 'REMOTE_ONLY_COMMITS=%s\n' "$RIGHT_COUNT"

if [ "$LEFT_COUNT" -ne 0 ] || [ "$RIGHT_COUNT" -ne 0 ]; then
    echo "FAIL: Local main and origin/main are not synchronized."
    exit 1
fi

BASE_HEAD="$(git rev-parse HEAD)"
REMOTE_BASE_HEAD="$(git rev-parse origin/main)"

printf 'BASE_HEAD=%s\n' "$BASE_HEAD"
printf 'REMOTE_BASE_HEAD=%s\n' "$REMOTE_BASE_HEAD"

echo "LOCAL_REMOTE_SYNCHRONIZATION=PASS"

echo
echo "===== 8. DESTINATION-COLLISION AUDIT ====="

python3 <<'PY'
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path

source = Path(os.environ["SOURCE"]).resolve()
repo = Path(os.environ["REPO"]).resolve()
audit = Path(os.environ["AUDIT"]).resolve()

roots = (
    Path(os.environ["EXPERIMENT_ROOT"]),
    Path(os.environ["PROVENANCE_ROOT"]),
)

results: dict[str, list[dict[str, str]]] = {
    "new": [],
    "same": [],
    "different": [],
    "type_collision": [],
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for block in iter(
            lambda: handle.read(1024 * 1024),
            b"",
        ):
            digest.update(block)

    return digest.hexdigest()


source_files: list[Path] = []

for root in roots:
    source_files.extend(
        path
        for path in (source / root).rglob("*")
        if path.is_file() and not path.is_symlink()
    )

for src in sorted(source_files):
    relative = src.relative_to(source)
    destination = repo / relative
    source_hash = sha256(src)

    if not destination.exists():
        results["new"].append(
            {
                "path": relative.as_posix(),
                "source_sha256": source_hash,
            }
        )
        continue

    if not destination.is_file() or destination.is_symlink():
        results["type_collision"].append(
            {
                "path": relative.as_posix(),
                "destination": str(destination),
            }
        )
        continue

    destination_hash = sha256(destination)

    if source_hash == destination_hash:
        results["same"].append(
            {
                "path": relative.as_posix(),
                "sha256": source_hash,
            }
        )
    else:
        results["different"].append(
            {
                "path": relative.as_posix(),
                "source_sha256": source_hash,
                "destination_sha256": destination_hash,
            }
        )

summary = {
    "source_file_count": len(source_files),
    "new_file_count": len(results["new"]),
    "same_file_count": len(results["same"]),
    "different_file_count": len(results["different"]),
    "type_collision_count": len(results["type_collision"]),
}

(audit / "preimport_collision_audit.json").write_text(
    json.dumps(
        {
            "summary": summary,
            "results": results,
        },
        indent=2,
    )
    + "\n",
    encoding="utf-8",
)

for key, value in summary.items():
    print(f"{key.upper()}={value}")

if summary["source_file_count"] != 1486:
    raise SystemExit(
        "FAIL: Collision audit did not inspect 1486 files."
    )

if summary["new_file_count"] != 1486:
    raise SystemExit(
        "FAIL: Not all classified files have new destinations."
    )

if (
    results["same"]
    or results["different"]
    or results["type_collision"]
):
    raise SystemExit(
        "FAIL: Repository destination collision detected."
    )

print("DESTINATION_COLLISION_AUDIT=PASS")
PY

if [ -e "$REPO/$EXPERIMENT_ROOT" ]; then
    echo "FAIL: Experiment destination already exists."
    exit 1
fi

if [ -e "$REPO/$PROVENANCE_ROOT" ]; then
    echo "FAIL: Provenance destination already exists."
    exit 1
fi

echo "NEW_EXPERIMENT_DESTINATION=PASS"
echo "NEW_PROVENANCE_DESTINATION=PASS"

echo
echo "===== 9. CONFIGURE EXACT GIT LFS PATH ====="

cd "$REPO"

git lfs install --local

ATTRIBUTE_BEFORE="$(
    git check-attr filter -- "$ARCHIVE" |
    awk -F': ' '{print $3}'
)"

printf 'LFS_FILTER_BEFORE=%s\n' "$ATTRIBUTE_BEFORE"

if [ "$ATTRIBUTE_BEFORE" != "lfs" ]; then
    git lfs track "$ARCHIVE"
fi

ATTRIBUTE_AFTER="$(
    git check-attr filter -- "$ARCHIVE" |
    awk -F': ' '{print $3}'
)"

printf 'LFS_FILTER_AFTER=%s\n' "$ATTRIBUTE_AFTER"

if [ "$ATTRIBUTE_AFTER" != "lfs" ]; then
    echo "FAIL: Frozen archive was not assigned to Git LFS."
    exit 1
fi

echo "EXACT_ARCHIVE_LFS_TRACKING=PASS"

echo
echo "===== 10. CONTROLLED COPY — NO DELETE OPTION USED ====="

mkdir -p \
    "$REPO/experiments" \
    "$REPO/provenance"

rsync \
    -a \
    --checksum \
    --itemize-changes \
    --dry-run \
    "$SOURCE/$EXPERIMENT_ROOT/" \
    "$REPO/$EXPERIMENT_ROOT/" \
    > "$AUDIT/rsync_experiment_dry_run.log"

rsync \
    -a \
    --checksum \
    --itemize-changes \
    --dry-run \
    "$SOURCE/$PROVENANCE_ROOT/" \
    "$REPO/$PROVENANCE_ROOT/" \
    > "$AUDIT/rsync_provenance_dry_run.log"

rsync \
    -a \
    --checksum \
    --itemize-changes \
    "$SOURCE/$EXPERIMENT_ROOT/" \
    "$REPO/$EXPERIMENT_ROOT/" \
    > "$AUDIT/rsync_experiment_import.log"

rsync \
    -a \
    --checksum \
    --itemize-changes \
    "$SOURCE/$PROVENANCE_ROOT/" \
    "$REPO/$PROVENANCE_ROOT/" \
    > "$AUDIT/rsync_provenance_import.log"

echo "CONTROLLED_IMPORT=COMPLETE"

echo
echo "===== 11. BYTE-FOR-BYTE POST-IMPORT AUDIT ====="

python3 <<'PY'
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path

source = Path(os.environ["SOURCE"]).resolve()
repo = Path(os.environ["REPO"]).resolve()
audit = Path(os.environ["AUDIT"]).resolve()

roots = (
    Path(os.environ["EXPERIMENT_ROOT"]),
    Path(os.environ["PROVENANCE_ROOT"]),
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for block in iter(
            lambda: handle.read(1024 * 1024),
            b"",
        ):
            digest.update(block)

    return digest.hexdigest()


source_files: dict[str, Path] = {}
destination_files: dict[str, Path] = {}

for root in roots:
    for path in (source / root).rglob("*"):
        if path.is_file() and not path.is_symlink():
            relative = path.relative_to(source).as_posix()
            source_files[relative] = path

    for path in (repo / root).rglob("*"):
        if path.is_file() and not path.is_symlink():
            relative = path.relative_to(repo).as_posix()
            destination_files[relative] = path

missing = sorted(set(source_files) - set(destination_files))
extra = sorted(set(destination_files) - set(source_files))
different: list[dict[str, str]] = []

for relative in sorted(set(source_files) & set(destination_files)):
    source_hash = sha256(source_files[relative])
    destination_hash = sha256(destination_files[relative])

    if source_hash != destination_hash:
        different.append(
            {
                "path": relative,
                "source_sha256": source_hash,
                "destination_sha256": destination_hash,
            }
        )

summary = {
    "source_file_count": len(source_files),
    "destination_file_count": len(destination_files),
    "missing_file_count": len(missing),
    "extra_file_count": len(extra),
    "different_file_count": len(different),
}

(audit / "post_import_byte_verification.json").write_text(
    json.dumps(
        {
            "summary": summary,
            "missing": missing,
            "extra": extra,
            "different": different,
        },
        indent=2,
    )
    + "\n",
    encoding="utf-8",
)

for key, value in summary.items():
    print(f"{key.upper()}={value}")

if (
    len(source_files) != 1486
    or len(destination_files) != 1486
    or missing
    or extra
    or different
):
    raise SystemExit(
        "FAIL: Post-import byte verification failed."
    )

print("POST_IMPORT_BYTE_VERIFICATION=PASS")
PY

echo
echo "===== 12. VERIFY PACKAGE CHECKSUMS INSIDE REPOSITORY ====="

cd "$REPO/$PROVENANCE_ROOT"

sha256sum -c SHA256SUMS.sha256

cd "$REPO"

sha256sum -c "$PACKAGE_SUMS" \
    > "$AUDIT/repository_package_checksum_verification.log"

REPOSITORY_PACKAGE_OK_COUNT="$(
    python3 - "$AUDIT/repository_package_checksum_verification.log" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

count = sum(
    1
    for line in path.read_text(
        encoding="utf-8",
        errors="replace",
    ).splitlines()
    if line.endswith(": OK")
)

print(count)
PY
)"

printf 'REPOSITORY_PACKAGE_OK_COUNT=%s\n' \
    "$REPOSITORY_PACKAGE_OK_COUNT"

if [ "$REPOSITORY_PACKAGE_OK_COUNT" -ne "$EXPECTED_PACKAGE_SUMS" ]; then
    echo "FAIL: Imported package checksum verification failed."
    exit 1
fi

echo "IMPORTED_PACKAGE_INTEGRITY=PASS"

echo
echo "===== 13. STAGE ONLY CLASSIFIED TREES AND LFS RULE ====="

cd "$REPO"

git add -- .gitattributes

git add -f -- \
    "$EXPERIMENT_ROOT" \
    "$PROVENANCE_ROOT"

STAGED_IMPORTED_COUNT="$(
    git diff \
        --cached \
        --name-only \
        --diff-filter=A \
        -- \
        "$EXPERIMENT_ROOT" \
        "$PROVENANCE_ROOT" |
    wc -l
)"

printf 'STAGED_IMPORTED_FILE_COUNT=%s\n' \
    "$STAGED_IMPORTED_COUNT"

if [ "$STAGED_IMPORTED_COUNT" -ne "$EXPECTED_PACKAGE_FILES" ]; then
    echo "FAIL: Expected exactly $EXPECTED_PACKAGE_FILES staged imports."
    exit 1
fi

echo "ALL_CLASSIFIED_FILES_STAGED=PASS"

echo
echo "===== 14. VERIFY STAGED LFS POINTER AND FULL OBJECT ====="

REPO_ARCHIVE="$REPO/$ARCHIVE"

WORKTREE_ARCHIVE_SIZE="$(
    stat -c '%s' "$REPO_ARCHIVE"
)"

WORKTREE_ARCHIVE_SHA256="$(
    sha256sum "$REPO_ARCHIVE" |
    awk '{print $1}'
)"

printf 'WORKTREE_ARCHIVE_SIZE=%s\n' \
    "$WORKTREE_ARCHIVE_SIZE"

printf 'WORKTREE_ARCHIVE_SHA256=%s\n' \
    "$WORKTREE_ARCHIVE_SHA256"

if [ "$WORKTREE_ARCHIVE_SIZE" -ne "$EXPECTED_ARCHIVE_SIZE" ] ||
   [ "$WORKTREE_ARCHIVE_SHA256" != "$EXPECTED_ARCHIVE_SHA256" ]; then
    echo "FAIL: Imported frozen archive identity changed."
    exit 1
fi

POINTER_FILE="$AUDIT/staged_archive_lfs_pointer.txt"

git show ":$ARCHIVE" > "$POINTER_FILE"

cat "$POINTER_FILE"

grep -Fx \
    'version https://git-lfs.github.com/spec/v1' \
    "$POINTER_FILE"

grep -Fx \
    "oid sha256:$EXPECTED_ARCHIVE_SHA256" \
    "$POINTER_FILE"

grep -Fx \
    "size $EXPECTED_ARCHIVE_SIZE" \
    "$POINTER_FILE"

STAGED_ARCHIVE_BLOB_SIZE="$(
    git cat-file -s ":$ARCHIVE"
)"

printf 'STAGED_ARCHIVE_POINTER_SIZE=%s\n' \
    "$STAGED_ARCHIVE_BLOB_SIZE"

if [ "$STAGED_ARCHIVE_BLOB_SIZE" -ge 1024 ]; then
    echo "FAIL: Frozen archive is not staged as a small LFS pointer."
    exit 1
fi

GIT_DIRECTORY="$(git rev-parse --absolute-git-dir)"

LOCAL_LFS_OBJECT="$GIT_DIRECTORY/lfs/objects/${EXPECTED_ARCHIVE_SHA256:0:2}/${EXPECTED_ARCHIVE_SHA256:2:2}/$EXPECTED_ARCHIVE_SHA256"

printf 'LOCAL_LFS_OBJECT=%s\n' "$LOCAL_LFS_OBJECT"

if [ ! -f "$LOCAL_LFS_OBJECT" ]; then
    echo "FAIL: Full archive is absent from local Git LFS storage."
    exit 1
fi

LOCAL_LFS_OBJECT_SIZE="$(
    stat -c '%s' "$LOCAL_LFS_OBJECT"
)"

LOCAL_LFS_OBJECT_SHA256="$(
    sha256sum "$LOCAL_LFS_OBJECT" |
    awk '{print $1}'
)"

printf 'LOCAL_LFS_OBJECT_SIZE=%s\n' \
    "$LOCAL_LFS_OBJECT_SIZE"

printf 'LOCAL_LFS_OBJECT_SHA256=%s\n' \
    "$LOCAL_LFS_OBJECT_SHA256"

if [ "$LOCAL_LFS_OBJECT_SIZE" -ne "$EXPECTED_ARCHIVE_SIZE" ] ||
   [ "$LOCAL_LFS_OBJECT_SHA256" != "$EXPECTED_ARCHIVE_SHA256" ]; then
    echo "FAIL: Local Git LFS object identity mismatch."
    exit 1
fi

git lfs ls-files --long \
    > "$AUDIT/git_lfs_files_before_commit.txt"

grep -F -- "$ARCHIVE" \
    "$AUDIT/git_lfs_files_before_commit.txt"

echo "LFS_ARCHIVE_STAGING=PASS"

echo
echo "===== 15. REFRESH REPOSITORY TREE INVENTORIES ====="

git ls-files |
    LC_ALL=C sort \
    > repo_tracked_tree.txt

tree \
    -a \
    --noreport \
    --charset=UTF-8 \
    -I '.git' \
    . \
    > repo_visual_tree.txt

git add -- \
    repo_tracked_tree.txt \
    repo_visual_tree.txt

printf 'TOTAL_TRACKED_PATH_COUNT='
git ls-files | wc -l

echo "REPOSITORY_TREE_INVENTORIES=REFRESHED"

echo
echo "===== 16. REGENERATE REPOSITORY-WIDE SHA256SUMS ====="

python3 <<'PY'
from __future__ import annotations

import hashlib
import os
import subprocess
from pathlib import Path

repo = Path(os.environ["REPO"]).resolve()

raw = subprocess.check_output(
    ["git", "-C", str(repo), "ls-files", "-z"]
)

tracked_paths = sorted(
    os.fsdecode(item)
    for item in raw.split(b"\0")
    if item
)

excluded = {
    "SHA256SUMS",
    "SHA256SUMS.sha256",
}

inventory_paths = [
    path
    for path in tracked_paths
    if path not in excluded
]

output_path = repo / "SHA256SUMS"

with output_path.open(
    "w",
    encoding="utf-8",
    newline="\n",
) as output:
    for relative in inventory_paths:
        if "\n" in relative or "\\" in relative:
            raise SystemExit(
                f"FAIL: Unsupported checksum path: {relative!r}"
            )

        absolute = repo / relative

        if not absolute.is_file():
            raise SystemExit(
                f"FAIL: Tracked path is not a regular file: {relative}"
            )

        digest = hashlib.sha256()

        with absolute.open("rb") as source:
            for block in iter(
                lambda: source.read(1024 * 1024),
                b"",
            ):
                digest.update(block)

        output.write(
            f"{digest.hexdigest()}  {relative}\n"
        )

print(
    f"REPOSITORY_SHA256_ENTRY_COUNT={len(inventory_paths)}"
)
PY

sha256sum SHA256SUMS > SHA256SUMS.sha256

git add -- \
    SHA256SUMS \
    SHA256SUMS.sha256

echo "REPOSITORY_SHA256_INVENTORY=REFRESHED"

echo
echo "===== 17. VERIFY REPOSITORY-WIDE CHECKSUMS ====="

sha256sum -c SHA256SUMS.sha256

sha256sum -c SHA256SUMS \
    > "$AUDIT/repository_wide_checksum_verification.log"

EXPECTED_REPOSITORY_SUM_COUNT="$(
    wc -l < SHA256SUMS
)"

REPOSITORY_SUM_OK_COUNT="$(
    python3 - "$AUDIT/repository_wide_checksum_verification.log" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

count = sum(
    1
    for line in path.read_text(
        encoding="utf-8",
        errors="replace",
    ).splitlines()
    if line.endswith(": OK")
)

print(count)
PY
)"

printf 'EXPECTED_REPOSITORY_CHECKSUM_COUNT=%s\n' \
    "$EXPECTED_REPOSITORY_SUM_COUNT"

printf 'REPOSITORY_CHECKSUM_OK_COUNT=%s\n' \
    "$REPOSITORY_SUM_OK_COUNT"

if [ "$REPOSITORY_SUM_OK_COUNT" -ne "$EXPECTED_REPOSITORY_SUM_COUNT" ]; then
    echo "FAIL: Repository-wide checksum verification failed."
    exit 1
fi

echo "REPOSITORY_WIDE_CHECKSUMS=PASS"

echo
echo "===== 18. EXACT STAGED-SCOPE AUDIT ====="

python3 <<'PY'
from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

repo = Path(os.environ["REPO"]).resolve()
audit = Path(os.environ["AUDIT"]).resolve()

raw = subprocess.check_output(
    [
        "git",
        "-C",
        str(repo),
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
    ".gitattributes",
    "repo_tracked_tree.txt",
    "repo_visual_tree.txt",
    "SHA256SUMS",
    "SHA256SUMS.sha256",
}

unexpected = sorted(
    path
    for path in paths
    if path not in allowed_metadata
    and not path.startswith(allowed_roots)
)

metadata_changes = sorted(
    path
    for path in paths
    if path in allowed_metadata
)

summary = {
    "total_staged_path_count": len(paths),
    "metadata_change_count": len(metadata_changes),
    "unexpected_staged_path_count": len(unexpected),
    "metadata_changes": metadata_changes,
    "unexpected": unexpected,
}

(audit / "staged_scope_audit.json").write_text(
    json.dumps(summary, indent=2) + "\n",
    encoding="utf-8",
)

print(f"TOTAL_STAGED_PATH_COUNT={len(paths)}")
print(f"METADATA_CHANGE_COUNT={len(metadata_changes)}")
print(f"UNEXPECTED_STAGED_PATH_COUNT={len(unexpected)}")

for path in metadata_changes:
    print(f"METADATA_CHANGE={path}")

for path in unexpected:
    print(f"UNEXPECTED_STAGED_PATH={path}")

expected_total = 1486 + len(metadata_changes)

if len(paths) != expected_total:
    raise SystemExit(
        "FAIL: Total staged count does not equal imports plus metadata."
    )

if unexpected:
    raise SystemExit(
        "FAIL: Unexpected staged paths detected."
    )

required_metadata = {
    "repo_tracked_tree.txt",
    "repo_visual_tree.txt",
    "SHA256SUMS",
    "SHA256SUMS.sha256",
}

if not required_metadata.issubset(set(metadata_changes)):
    raise SystemExit(
        "FAIL: Required repository inventories are not all staged."
    )

print("EXACT_STAGED_SCOPE=PASS")
PY

echo
echo "===== 19. CHANGE-TYPE AND RESIDUE AUDIT ====="

STAGED_ADDITION_COUNT="$(
    git diff --cached --name-only --diff-filter=A |
    wc -l
)"

STAGED_DELETION_COUNT="$(
    git diff --cached --name-only --diff-filter=D |
    wc -l
)"

STAGED_RENAME_COUNT="$(
    git diff --cached --name-only --diff-filter=R |
    wc -l
)"

UNMERGED_INDEX_ENTRY_COUNT="$(
    git ls-files --unmerged |
    wc -l
)"

UNSTAGED_CHANGE_COUNT="$(
    git diff --name-only |
    wc -l
)"

UNTRACKED_FILE_COUNT="$(
    git ls-files --others --exclude-standard |
    wc -l
)"

printf 'STAGED_ADDITION_COUNT=%s\n' "$STAGED_ADDITION_COUNT"
printf 'STAGED_DELETION_COUNT=%s\n' "$STAGED_DELETION_COUNT"
printf 'STAGED_RENAME_COUNT=%s\n' "$STAGED_RENAME_COUNT"
printf 'UNMERGED_INDEX_ENTRY_COUNT=%s\n' \
    "$UNMERGED_INDEX_ENTRY_COUNT"
printf 'UNSTAGED_CHANGE_COUNT=%s\n' "$UNSTAGED_CHANGE_COUNT"
printf 'UNTRACKED_FILE_COUNT=%s\n' "$UNTRACKED_FILE_COUNT"

if [ "$STAGED_ADDITION_COUNT" -ne "$EXPECTED_PACKAGE_FILES" ]; then
    echo "FAIL: Expected exactly $EXPECTED_PACKAGE_FILES additions."
    exit 1
fi

if [ "$STAGED_DELETION_COUNT" -ne 0 ]; then
    echo "FAIL: Staged deletion detected."
    exit 1
fi

if [ "$STAGED_RENAME_COUNT" -ne 0 ]; then
    echo "FAIL: Staged rename detected."
    exit 1
fi

if [ "$UNMERGED_INDEX_ENTRY_COUNT" -ne 0 ]; then
    echo "FAIL: Unmerged Git index entries detected."
    exit 1
fi

if [ "$UNSTAGED_CHANGE_COUNT" -ne 0 ]; then
    echo "FAIL: Unstaged repository changes remain."
    git diff --name-only
    exit 1
fi

if [ "$UNTRACKED_FILE_COUNT" -ne 0 ]; then
    echo "FAIL: Untracked repository files remain."
    git ls-files --others --exclude-standard
    exit 1
fi

echo "NO_DELETIONS=PASS"
echo "NO_RENAMES=PASS"
echo "NO_UNMERGED_ENTRIES=PASS"
echo "NO_UNSTAGED_RESIDUES=PASS"
echo "NO_UNTRACKED_RESIDUES=PASS"

echo
echo "===== 20. OVERSIZED NORMAL-GIT-BLOB AUDIT ====="

python3 <<'PY'
from __future__ import annotations

import os
import subprocess

repo = os.environ["REPO"]
limit = 95 * 1024 * 1024

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

oversized: list[tuple[str, int]] = []

for path in paths:
    size_text = subprocess.check_output(
        [
            "git",
            "-C",
            repo,
            "cat-file",
            "-s",
            f":{path}",
        ],
        text=True,
    ).strip()

    size = int(size_text)

    if size >= limit:
        oversized.append((path, size))

print(
    "OVERSIZED_STAGED_NORMAL_BLOB_COUNT="
    f"{len(oversized)}"
)

for path, size in oversized:
    print(f"OVERSIZED_NORMAL_BLOB={size}\t{path}")

if oversized:
    raise SystemExit(
        "FAIL: Oversized normal Git blob remains staged."
    )

print("NORMAL_GIT_BLOB_SIZE_POLICY=PASS")
PY

echo
echo "===== 21. ADVISORY RAW-EVIDENCE WHITESPACE AUDIT ====="

set +e

git diff --cached --check \
    > "$AUDIT/staged_whitespace_advisory.txt" 2>&1

WHITESPACE_STATUS=$?

set -e

printf 'GIT_DIFF_CHECK_STATUS=%s\n' "$WHITESPACE_STATUS"

WHITESPACE_DIAGNOSTIC_COUNT="$(
    python3 - "$AUDIT/staged_whitespace_advisory.txt" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])

text = path.read_text(
    encoding="utf-8",
    errors="replace",
)

count = sum(
    1
    for line in text.splitlines()
    if re.match(r"^.+:\d+: .+$", line)
)

print(count)
PY
)"

printf 'RECORDED_WHITESPACE_DIAGNOSTIC_COUNT=%s\n' \
    "$WHITESPACE_DIAGNOSTIC_COUNT"

echo "WHITESPACE_WARNINGS_ARE_ADVISORY_FOR_RAW_EVIDENCE=YES"
echo "RAW_EVIDENCE_WAS_NOT_MODIFIED=YES"

echo
echo "===== 22. FINAL PRE-COMMIT SUMMARY ====="

git status --short \
    > "$AUDIT/pre_commit_git_status.txt"

git lfs status \
    > "$AUDIT/pre_commit_git_lfs_status.txt"

echo "STAGED_CHANGE_TYPE_COUNTS:"
git diff --cached --name-status |
    cut -f1 |
    LC_ALL=C sort |
    uniq -c

echo
echo "STAGED_SHORTSTAT:"
git diff --cached --shortstat

echo
echo "STAGED_TOP-LEVEL_COUNTS:"
git diff --cached --name-only |
    awk -F/ '{print $1}' |
    LC_ALL=C sort |
    uniq -c

FINAL_STAGED_PATH_COUNT="$(
    git diff --cached --name-only |
    wc -l
)"

printf 'FINAL_STAGED_PATH_COUNT=%s\n' \
    "$FINAL_STAGED_PATH_COUNT"

echo
echo "================================================================"
echo " PRE-COMMIT SAFETY PASSED"
echo "================================================================"
echo "CLASSIFIED_FILES_FOUND=$EXPECTED_PACKAGE_FILES"
echo "PACKAGE_CHECKSUMS_VERIFIED=$EXPECTED_PACKAGE_SUMS"
echo "DESTINATION_COLLISIONS=0"
echo "BYTE_DIFFERENCES_AFTER_IMPORT=0"
echo "STAGED_ADDITIONS=$EXPECTED_PACKAGE_FILES"
echo "STAGED_DELETIONS=0"
echo "STAGED_RENAMES=0"
echo "UNMERGED_ENTRIES=0"
echo "UNSTAGED_RESIDUES=0"
echo "UNTRACKED_RESIDUES=0"
echo "LFS_POINTER_VERIFIED=YES"
echo "FULL_LFS_OBJECT_VERIFIED=YES"
echo "RAW_EVIDENCE_PRESERVED_BYTE_EXACT=YES"
echo "BASE_HEAD=$BASE_HEAD"
echo "NOTHING_COMMITTED_OR_PUSHED_YET=YES"

echo
read -r -p "Type exactly PUSH to commit and upload to GitHub: " CONFIRMATION

if [ "$CONFIRMATION" != "PUSH" ]; then
    echo
    echo "PUSH_CANCELLED=YES"
    echo "No commit or push was performed."
    echo "Files remain safely staged."
    exit 0
fi

echo
echo "===== 23. FINAL REMOTE RACE-CHECK ====="

git fetch origin

CURRENT_LOCAL_HEAD="$(git rev-parse HEAD)"
CURRENT_REMOTE_HEAD="$(git rev-parse origin/main)"

printf 'LOCAL_HEAD_BEFORE_COMMIT=%s\n' \
    "$CURRENT_LOCAL_HEAD"

printf 'REMOTE_HEAD_BEFORE_COMMIT=%s\n' \
    "$CURRENT_REMOTE_HEAD"

if [ "$CURRENT_LOCAL_HEAD" != "$BASE_HEAD" ]; then
    echo "FAIL: Local HEAD changed during validation."
    exit 1
fi

if [ "$CURRENT_REMOTE_HEAD" != "$REMOTE_BASE_HEAD" ]; then
    echo "FAIL: GitHub main changed during validation."
    exit 1
fi

echo "FINAL_REMOTE_RACE_CHECK=PASS"

echo
echo "===== 24. CREATE COMMIT ====="

git commit -m "$COMMIT_MESSAGE"

NEW_COMMIT="$(git rev-parse HEAD)"

printf 'NEW_COMMIT=%s\n' "$NEW_COMMIT"

COMMITTED_PATH_COUNT="$(
    git diff-tree \
        --no-commit-id \
        --name-only \
        -r \
        HEAD |
    wc -l
)"

printf 'COMMITTED_PATH_COUNT=%s\n' \
    "$COMMITTED_PATH_COUNT"

if [ "$COMMITTED_PATH_COUNT" -ne "$FINAL_STAGED_PATH_COUNT" ]; then
    echo "FAIL: Committed path count differs from staged path count."
    exit 1
fi

git lfs fsck

echo "LOCAL_COMMIT_AND_LFS=PASS"

echo
echo "===== 25. PUSH TO GITHUB ====="

git push origin main

echo
echo "===== 26. VERIFY GITHUB REMOTE ====="

git fetch origin

REMOTE_COMMIT="$(git rev-parse origin/main)"

read -r LEFT_AFTER RIGHT_AFTER <<< "$(
    git rev-list --left-right --count HEAD...origin/main
)"

printf 'LOCAL_COMMIT=%s\n' "$NEW_COMMIT"
printf 'REMOTE_COMMIT=%s\n' "$REMOTE_COMMIT"
printf 'LOCAL_ONLY_COMMITS_AFTER_PUSH=%s\n' "$LEFT_AFTER"
printf 'REMOTE_ONLY_COMMITS_AFTER_PUSH=%s\n' "$RIGHT_AFTER"

if [ "$REMOTE_COMMIT" != "$NEW_COMMIT" ]; then
    echo "FAIL: GitHub main does not match the new local commit."
    exit 1
fi

if [ "$LEFT_AFTER" -ne 0 ] || [ "$RIGHT_AFTER" -ne 0 ]; then
    echo "FAIL: Local and remote branches differ after push."
    exit 1
fi

echo "REMOTE_COMMIT_VERIFICATION=PASS"

echo
echo "===== 27. FINAL REPOSITORY CLEANLINESS ====="

git status --branch --short

FINAL_PORCELAIN="$(
    git status --porcelain
)"

if [ -n "$FINAL_PORCELAIN" ]; then
    echo "FAIL: Repository is not clean after push."
    printf '%s\n' "$FINAL_PORCELAIN"
    exit 1
fi

git lfs status

echo
echo "================================================================"
echo " SUCCESS: SCALAR SIGNED-TO-UNSIGNED-Q CAMPAIGN PUSHED SAFELY"
echo "================================================================"
echo "PUSHED_COMMIT=$NEW_COMMIT"
echo "REMOTE_COMMIT=$REMOTE_COMMIT"
echo "CLASSIFIED_FILES_IMPORTED=$EXPECTED_PACKAGE_FILES"
echo "PACKAGE_CHECKSUMS_VERIFIED=$EXPECTED_PACKAGE_SUMS"
echo "COMMITTED_PATHS=$COMMITTED_PATH_COUNT"
echo "DELETIONS=0"
echo "RENAMES=0"
echo "UNMERGED_ENTRIES=0"
echo "UNSTAGED_RESIDUES=0"
echo "UNTRACKED_RESIDUES=0"
echo "LFS_ARCHIVE_INCLUDED=YES"
echo "RAW_EVIDENCE_PRESERVED_BYTE_EXACT=YES"
echo "REMOTE_VERIFIED=YES"
echo "WORKTREE_CLEAN=YES"
echo "AUDIT_DIRECTORY=$AUDIT"
echo
echo "The extracted source directory was intentionally not deleted."
