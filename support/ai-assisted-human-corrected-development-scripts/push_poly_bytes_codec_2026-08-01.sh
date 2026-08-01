#!/usr/bin/env bash

set -Eeuo pipefail
umask 022

SOURCE="/home/girish/THESIS-2026/MLK_POLY_BYTES_CODEC_CLASSIFIED_MERGE_READY_2026-08-01"

REPO="/home/girish/THESIS-2026/CLASSIFICATION GIT/MLKEM_CBMC_FULL_CLASSIFIED_BASELINE_2026-07-19"

EXPERIMENT_ROOT="experiments/poly-bytes-codec"
PROVENANCE_ROOT="provenance/poly-bytes-codec"

PACKAGE_SUMS="$PROVENANCE_ROOT/SHA256SUMS"
PACKAGE_SUMS_HASH="$PROVENANCE_ROOT/SHA256SUMS.sha256"

ORIGINAL_ARCHIVE="$PROVENANCE_ROOT/frozen-baseline/mlk_poly_bytes_codec_cleanroom.zip"

EXPECTED_BASE_HEAD="eaa50f0167ffeeb3987a33db5ecfb168cf87771e"

EXPECTED_PACKAGE_FILES=186
EXPECTED_PACKAGE_CHECKSUMS=184
EXPECTED_ORIGINAL_ARCHIVE_SIZE=1258205
EXPECTED_ORIGINAL_ARCHIVE_SHA256="5253f83c32e7980364ae853b950989c522e5609f66e9302ea10ddc9eacc0051c"

EXPECTED_STAGED_ADDITIONS=186
EXPECTED_METADATA_MODIFICATIONS=4
EXPECTED_TOTAL_STAGED_PATHS=190

COMMIT_MESSAGE="Add ML-KEM polynomial byte-codec composition evidence"

AUDIT="$HOME/THESIS-2026/POLY_BYTES_CODEC_PUSH_AUDIT_$(date -u +%Y%m%dT%H%M%SZ)"

export SOURCE
export REPO
export EXPERIMENT_ROOT
export PROVENANCE_ROOT
export PACKAGE_SUMS
export PACKAGE_SUMS_HASH
export ORIGINAL_ARCHIVE
export AUDIT

mkdir -p "$AUDIT"

trap '
    rc=$?
    echo
    echo "============================================================"
    echo " SAFE STOP — STATUS $rc"
    echo "============================================================"
    echo "No force push, deletion command, or git add . was used."
    echo "AUDIT_DIRECTORY=$AUDIT"
    exit "$rc"
' ERR

echo "================================================================"
echo " POLY BYTE-CODEC CONTROLLED IMPORT, COMMIT, AND GITHUB PUSH"
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
    stat \
    unzip
do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "FAIL_MISSING_COMMAND=$command_name"
        exit 1
    fi

    echo "FOUND_COMMAND=$command_name"
done

git --version
git lfs version
python3 --version

echo
echo "===== 2. SOURCE STRUCTURE GATE ====="

test -d "$SOURCE"
test -d "$SOURCE/$EXPERIMENT_ROOT"
test -d "$SOURCE/$PROVENANCE_ROOT"
test -f "$SOURCE/$PACKAGE_SUMS"
test -f "$SOURCE/$PACKAGE_SUMS_HASH"
test -f "$SOURCE/$ORIGINAL_ARCHIVE"

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

echo "ACTUAL_TOP_LEVEL:"
printf '%s\n' "$ACTUAL_TOP_LEVEL"

if [ "$ACTUAL_TOP_LEVEL" != "$EXPECTED_TOP_LEVEL" ]; then
    echo "FAIL: Unexpected top-level package content."
    exit 1
fi

echo "SOURCE_TOP_LEVEL_STRUCTURE=PASS"

echo
echo "===== 3. COMPLETE SOURCE INVENTORY ====="

SOURCE_FILE_COUNT="$(find "$SOURCE" -type f | wc -l)"
SOURCE_DIRECTORY_COUNT="$(find "$SOURCE" -type d | wc -l)"
SOURCE_SYMLINK_COUNT="$(find "$SOURCE" -type l | wc -l)"

SOURCE_NESTED_GIT_COUNT="$(
    find "$SOURCE" \
        \( -name '.git' -o -path '*/.git/*' \) \
        -print |
    wc -l
)"

printf 'SOURCE_FILE_COUNT=%s\n' "$SOURCE_FILE_COUNT"
printf 'SOURCE_DIRECTORY_COUNT=%s\n' "$SOURCE_DIRECTORY_COUNT"
printf 'SOURCE_SYMLINK_COUNT=%s\n' "$SOURCE_SYMLINK_COUNT"
printf 'SOURCE_NESTED_GIT_METADATA_COUNT=%s\n' \
    "$SOURCE_NESTED_GIT_COUNT"

if [ "$SOURCE_FILE_COUNT" -ne "$EXPECTED_PACKAGE_FILES" ]; then
    echo "FAIL: Expected exactly $EXPECTED_PACKAGE_FILES files."
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

echo "COMPLETE_SOURCE_INVENTORY=PASS"

echo
echo "===== 4. LARGE-FILE AND SENSITIVE-FILENAME GATE ====="

find "$SOURCE" \
    -type f \
    -size +50M \
    -printf '%s\t%P\n' \
    > "$AUDIT/source_files_over_50MiB.tsv"

FILES_OVER_50_MIB="$(
    wc -l < "$AUDIT/source_files_over_50MiB.tsv"
)"

printf 'SOURCE_FILES_OVER_50_MIB=%s\n' "$FILES_OVER_50_MIB"

if [ "$FILES_OVER_50_MIB" -ne 0 ]; then
    echo "FAIL: Unexpected file above 50 MiB:"
    cat "$AUDIT/source_files_over_50MiB.tsv"
    exit 1
fi

find "$SOURCE" \
    -type f \
    \( \
        -name '.env' -o \
        -name '.env.*' -o \
        -name 'id_rsa' -o \
        -name 'id_ed25519' -o \
        -name '*.pem' -o \
        -name '*.p12' -o \
        -name '*.pfx' -o \
        -name '*.kdbx' \
    \) \
    -printf '%P\n' \
    > "$AUDIT/sensitive_filename_candidates.txt"

if [ -s "$AUDIT/sensitive_filename_candidates.txt" ]; then
    echo "FAIL: Potential sensitive files require review:"
    cat "$AUDIT/sensitive_filename_candidates.txt"
    exit 1
fi

echo "LARGE_FILE_GATE=PASS"
echo "SENSITIVE_FILENAME_GATE=PASS"
echo "NEW_GIT_LFS_RULE_REQUIRED=NO"

echo
echo "===== 5. VERIFY PACKAGE CHECKSUMS ====="

cd "$SOURCE/$PROVENANCE_ROOT"

sha256sum -c SHA256SUMS.sha256

cd "$SOURCE"

PACKAGE_CHECKSUM_ENTRY_COUNT="$(
    wc -l < "$PACKAGE_SUMS"
)"

printf 'PACKAGE_CHECKSUM_ENTRY_COUNT=%s\n' \
    "$PACKAGE_CHECKSUM_ENTRY_COUNT"

if [ "$PACKAGE_CHECKSUM_ENTRY_COUNT" -ne \
     "$EXPECTED_PACKAGE_CHECKSUMS" ]; then
    echo "FAIL: Expected $EXPECTED_PACKAGE_CHECKSUMS checksum entries."
    exit 1
fi

sha256sum -c "$PACKAGE_SUMS" \
    > "$AUDIT/source_package_checksums.log"

SOURCE_CHECKSUM_OK_COUNT="$(
    python3 - "$AUDIT/source_package_checksums.log" <<'PY'
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

printf 'SOURCE_CHECKSUM_OK_COUNT=%s\n' \
    "$SOURCE_CHECKSUM_OK_COUNT"

if [ "$SOURCE_CHECKSUM_OK_COUNT" -ne \
     "$EXPECTED_PACKAGE_CHECKSUMS" ]; then
    echo "FAIL: Source package checksum verification failed."
    exit 1
fi

echo "SOURCE_PACKAGE_INTEGRITY=PASS"

echo
echo "===== 6. VERIFY FROZEN ORIGINAL ZIP ====="

SOURCE_ORIGINAL_ARCHIVE="$SOURCE/$ORIGINAL_ARCHIVE"

ARCHIVE_SIZE="$(stat -c '%s' "$SOURCE_ORIGINAL_ARCHIVE")"

ARCHIVE_SHA256="$(
    sha256sum "$SOURCE_ORIGINAL_ARCHIVE" |
    awk '{print $1}'
)"

printf 'ORIGINAL_ARCHIVE_SIZE=%s\n' "$ARCHIVE_SIZE"
printf 'ORIGINAL_ARCHIVE_SHA256=%s\n' "$ARCHIVE_SHA256"

if [ "$ARCHIVE_SIZE" -ne "$EXPECTED_ORIGINAL_ARCHIVE_SIZE" ]; then
    echo "FAIL: Frozen ZIP size differs from the classification audit."
    exit 1
fi

if [ "$ARCHIVE_SHA256" != "$EXPECTED_ORIGINAL_ARCHIVE_SHA256" ]; then
    echo "FAIL: Frozen ZIP SHA-256 differs from the classification audit."
    exit 1
fi

unzip -tqq "$SOURCE_ORIGINAL_ARCHIVE"

echo "FROZEN_ORIGINAL_ZIP_INTEGRITY=PASS"

echo
echo "===== 7. REPOSITORY AND MAIN-BRANCH GATE ====="

test -d "$REPO/.git"

cd "$REPO"

REPOSITORY_TOPLEVEL="$(git rev-parse --show-toplevel)"
CURRENT_BRANCH="$(git branch --show-current)"
CURRENT_HEAD="$(git rev-parse HEAD)"

printf 'REPOSITORY_TOPLEVEL=%s\n' "$REPOSITORY_TOPLEVEL"
printf 'CURRENT_BRANCH=%s\n' "$CURRENT_BRANCH"
printf 'CURRENT_HEAD=%s\n' "$CURRENT_HEAD"

if [ "$REPOSITORY_TOPLEVEL" != "$REPO" ]; then
    echo "FAIL: Configured repository path is not the Git top level."
    exit 1
fi

if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "FAIL: Current branch is not main."
    exit 1
fi

if [ "$CURRENT_HEAD" != "$EXPECTED_BASE_HEAD" ]; then
    echo "FAIL: Local HEAD differs from the previously verified commit."
    exit 1
fi

echo "MAIN_BRANCH_CONFIRMED=PASS"
echo "SEPARATE_BRANCH_CREATED=NO"

echo
echo "===== 8. CLEAN AND SYNCHRONIZED REPOSITORY GATE ====="

git status --branch --short

if [ -n "$(git status --porcelain)" ]; then
    echo "FAIL: Repository is not clean before import."
    git status --short
    exit 1
fi

git fetch origin

REMOTE_HEAD="$(git rev-parse origin/main)"

read -r LOCAL_ONLY_BEFORE REMOTE_ONLY_BEFORE <<< "$(
    git rev-list --left-right --count HEAD...origin/main
)"

printf 'REMOTE_HEAD=%s\n' "$REMOTE_HEAD"
printf 'LOCAL_ONLY_COMMITS_BEFORE=%s\n' "$LOCAL_ONLY_BEFORE"
printf 'REMOTE_ONLY_COMMITS_BEFORE=%s\n' "$REMOTE_ONLY_BEFORE"

if [ "$REMOTE_HEAD" != "$EXPECTED_BASE_HEAD" ]; then
    echo "FAIL: GitHub main differs from the verified base commit."
    exit 1
fi

if [ "$LOCAL_ONLY_BEFORE" -ne 0 ] ||
   [ "$REMOTE_ONLY_BEFORE" -ne 0 ]; then
    echo "FAIL: Local main and origin/main are not synchronized."
    exit 1
fi

echo "REPOSITORY_CLEAN_BEFORE_IMPORT=PASS"
echo "LOCAL_REMOTE_SYNCHRONIZATION=PASS"

echo
echo "===== 9. DESTINATION-COLLISION AUDIT ====="

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


results = {
    "new": [],
    "same": [],
    "different": [],
    "type_collision": [],
}

source_files = []

for root in roots:
    source_files.extend(
        path
        for path in (source / root).rglob("*")
        if path.is_file() and not path.is_symlink()
    )

for source_file in sorted(source_files):
    relative = source_file.relative_to(source)
    destination = repo / relative
    source_hash = sha256(source_file)

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
            {"path": relative.as_posix()}
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

(audit / "destination_collision_audit.json").write_text(
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

if summary["source_file_count"] != 186:
    raise SystemExit(
        "FAIL: Collision audit did not inspect all 186 files."
    )

if summary["new_file_count"] != 186:
    raise SystemExit(
        "FAIL: Not all package destinations are new."
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
    echo "FAIL: experiments/poly-bytes-codec already exists."
    exit 1
fi

if [ -e "$REPO/$PROVENANCE_ROOT" ]; then
    echo "FAIL: provenance/poly-bytes-codec already exists."
    exit 1
fi

echo "EXPERIMENT_DESTINATION_IS_NEW=PASS"
echo "PROVENANCE_DESTINATION_IS_NEW=PASS"

echo
echo "===== 10. CONTROLLED COPY PREVIEW ====="

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

printf 'EXPERIMENT_DRY_RUN_LINES='
wc -l < "$AUDIT/rsync_experiment_dry_run.log"

printf 'PROVENANCE_DRY_RUN_LINES='
wc -l < "$AUDIT/rsync_provenance_dry_run.log"

echo "RSYNC_DRY_RUN=PASS"
echo "RSYNC_DELETE_OPTION_USED=NO"

echo
echo "===== 11. CONTROLLED COPY ====="

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
echo "EXISTING_REPOSITORY_FILES_DELETED=0"

echo
echo "===== 12. BYTE-FOR-BYTE POST-IMPORT VERIFICATION ====="

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


source_files = {}
destination_files = {}

for root in roots:
    for path in (source / root).rglob("*"):
        if path.is_file() and not path.is_symlink():
            source_files[
                path.relative_to(source).as_posix()
            ] = path

    for path in (repo / root).rglob("*"):
        if path.is_file() and not path.is_symlink():
            destination_files[
                path.relative_to(repo).as_posix()
            ] = path

missing = sorted(set(source_files) - set(destination_files))
extra = sorted(set(destination_files) - set(source_files))
different = []

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
    len(source_files) != 186
    or len(destination_files) != 186
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
echo "===== 13. VERIFY PACKAGE CHECKSUMS INSIDE REPOSITORY ====="

cd "$REPO/$PROVENANCE_ROOT"

sha256sum -c SHA256SUMS.sha256

cd "$REPO"

sha256sum -c "$PACKAGE_SUMS" \
    > "$AUDIT/repository_package_checksums.log"

REPOSITORY_PACKAGE_OK_COUNT="$(
    python3 - "$AUDIT/repository_package_checksums.log" <<'PY'
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

printf 'REPOSITORY_PACKAGE_OK_COUNT=%s\n' \
    "$REPOSITORY_PACKAGE_OK_COUNT"

if [ "$REPOSITORY_PACKAGE_OK_COUNT" -ne \
     "$EXPECTED_PACKAGE_CHECKSUMS" ]; then
    echo "FAIL: Imported package checksum verification failed."
    exit 1
fi

echo "IMPORTED_PACKAGE_INTEGRITY=PASS"

echo
echo "===== 14. STAGE ONLY THE CLASSIFIED TREES ====="

cd "$REPO"

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

if [ "$STAGED_IMPORTED_COUNT" -ne \
     "$EXPECTED_PACKAGE_FILES" ]; then
    echo "FAIL: Expected exactly 186 staged imported files."
    exit 1
fi

echo "ALL_CLASSIFIED_FILES_STAGED=PASS"

echo
echo "===== 15. CONFIRM NO NEW LFS OR GITATTRIBUTES CHANGE ====="

CODEC_FILTER="$(
    git check-attr filter -- "$ORIGINAL_ARCHIVE" |
    awk -F': ' '{print $3}'
)"

printf 'ORIGINAL_ARCHIVE_GIT_FILTER=%s\n' "$CODEC_FILTER"

if [ "$CODEC_FILTER" = "lfs" ]; then
    echo "FAIL: The small codec archive unexpectedly matches Git LFS."
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

echo "GITATTRIBUTES_UNCHANGED=PASS"
echo "NEW_CODEC_LFS_OBJECT_ADDED=NO"

echo
echo "===== 16. REFRESH REPOSITORY TREE INVENTORIES ====="

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
echo "===== 17. REGENERATE REPOSITORY-WIDE SHA256SUMS ====="

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

with (repo / "SHA256SUMS").open(
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
                f"FAIL: Tracked path is not a file: {relative}"
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
echo "===== 18. VERIFY REPOSITORY-WIDE CHECKSUMS ====="

sha256sum -c SHA256SUMS.sha256

sha256sum -c SHA256SUMS \
    > "$AUDIT/repository_wide_checksums.log"

EXPECTED_REPOSITORY_CHECKSUM_COUNT="$(
    wc -l < SHA256SUMS
)"

REPOSITORY_CHECKSUM_OK_COUNT="$(
    python3 - "$AUDIT/repository_wide_checksums.log" <<'PY'
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

printf 'EXPECTED_REPOSITORY_CHECKSUM_COUNT=%s\n' \
    "$EXPECTED_REPOSITORY_CHECKSUM_COUNT"

printf 'REPOSITORY_CHECKSUM_OK_COUNT=%s\n' \
    "$REPOSITORY_CHECKSUM_OK_COUNT"

if [ "$REPOSITORY_CHECKSUM_OK_COUNT" -ne \
     "$EXPECTED_REPOSITORY_CHECKSUM_COUNT" ]; then
    echo "FAIL: Repository-wide checksum verification failed."
    exit 1
fi

echo "REPOSITORY_WIDE_CHECKSUMS=PASS"

echo
echo "===== 19. EXACT STAGED-SCOPE AUDIT ====="

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

required_metadata = {
    "SHA256SUMS",
    "SHA256SUMS.sha256",
    "repo_tracked_tree.txt",
    "repo_visual_tree.txt",
}

unexpected = sorted(
    path
    for path in paths
    if path not in required_metadata
    and not path.startswith(allowed_roots)
)

metadata_changes = {
    path
    for path in paths
    if path in required_metadata
}

summary = {
    "total_staged_path_count": len(paths),
    "metadata_change_count": len(metadata_changes),
    "unexpected_staged_path_count": len(unexpected),
    "unexpected": unexpected,
}

(audit / "staged_scope_audit.json").write_text(
    json.dumps(summary, indent=2) + "\n",
    encoding="utf-8",
)

print(f"TOTAL_STAGED_PATH_COUNT={len(paths)}")
print(f"METADATA_CHANGE_COUNT={len(metadata_changes)}")
print(f"UNEXPECTED_STAGED_PATH_COUNT={len(unexpected)}")

for path in unexpected:
    print(f"UNEXPECTED_STAGED_PATH={path}")

if len(paths) != 190:
    raise SystemExit(
        "FAIL: Expected exactly 190 staged paths."
    )

if metadata_changes != required_metadata:
    raise SystemExit(
        "FAIL: Repository metadata change set is incorrect."
    )

if unexpected:
    raise SystemExit(
        "FAIL: Unexpected staged paths detected."
    )

print("EXACT_STAGED_SCOPE=PASS")
PY

echo
echo "===== 20. CHANGE-TYPE AND RESIDUE AUDIT ====="

STAGED_ADDITIONS="$(
    git diff --cached --name-only --diff-filter=A |
    wc -l
)"

STAGED_MODIFICATIONS="$(
    git diff --cached --name-only --diff-filter=M |
    wc -l
)"

STAGED_DELETIONS="$(
    git diff --cached --name-only --diff-filter=D |
    wc -l
)"

STAGED_RENAMES="$(
    git diff --cached --name-only --diff-filter=R |
    wc -l
)"

UNMERGED_ENTRIES="$(
    git ls-files --unmerged |
    wc -l
)"

UNSTAGED_PATHS="$(
    git diff --name-only |
    wc -l
)"

UNTRACKED_PATHS="$(
    git ls-files --others --exclude-standard |
    wc -l
)"

printf 'STAGED_ADDITIONS=%s\n' "$STAGED_ADDITIONS"
printf 'STAGED_MODIFICATIONS=%s\n' "$STAGED_MODIFICATIONS"
printf 'STAGED_DELETIONS=%s\n' "$STAGED_DELETIONS"
printf 'STAGED_RENAMES=%s\n' "$STAGED_RENAMES"
printf 'UNMERGED_ENTRIES=%s\n' "$UNMERGED_ENTRIES"
printf 'UNSTAGED_PATHS=%s\n' "$UNSTAGED_PATHS"
printf 'UNTRACKED_PATHS=%s\n' "$UNTRACKED_PATHS"

if [ "$STAGED_ADDITIONS" -ne "$EXPECTED_STAGED_ADDITIONS" ] ||
   [ "$STAGED_MODIFICATIONS" -ne "$EXPECTED_METADATA_MODIFICATIONS" ] ||
   [ "$STAGED_DELETIONS" -ne 0 ] ||
   [ "$STAGED_RENAMES" -ne 0 ] ||
   [ "$UNMERGED_ENTRIES" -ne 0 ] ||
   [ "$UNSTAGED_PATHS" -ne 0 ] ||
   [ "$UNTRACKED_PATHS" -ne 0 ]; then
    echo "FAIL: Change-type or repository-residue audit failed."
    exit 1
fi

echo "CHANGE_TYPE_COUNTS=PASS"
echo "NO_DELETIONS=PASS"
echo "NO_RENAMES=PASS"
echo "NO_UNMERGED_ENTRIES=PASS"
echo "NO_UNSTAGED_RESIDUES=PASS"
echo "NO_UNTRACKED_RESIDUES=PASS"

echo
echo "===== 21. OVERSIZED NORMAL-GIT-BLOB AUDIT ====="

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

oversized = []

for path in paths:
    size = int(
        subprocess.check_output(
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
    )

    if size >= limit:
        oversized.append((path, size))

print(
    "OVERSIZED_STAGED_NORMAL_BLOB_COUNT="
    f"{len(oversized)}"
)

for path, size in oversized:
    print(f"OVERSIZED_BLOB={size}\t{path}")

if oversized:
    raise SystemExit(
        "FAIL: Oversized normal Git blob remains staged."
    )

print("NORMAL_GIT_BLOB_SIZE_POLICY=PASS")
PY

echo
echo "===== 22. SAFE ADVISORY WHITESPACE AUDIT ====="

WHITESPACE_FILE="$AUDIT/staged_whitespace_advisory.txt"

if git diff --cached --check \
    > "$WHITESPACE_FILE" 2>&1
then
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

WHITESPACE_DIAGNOSTIC_COUNT="$(
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
    "$WHITESPACE_DIAGNOSTIC_COUNT"

if [ -s "$WHITESPACE_FILE" ]; then
    echo "FIRST_WHITESPACE_DIAGNOSTICS:"
    sed -n '1,5p' "$WHITESPACE_FILE"
fi

echo "WHITESPACE_WARNINGS_ARE_ADVISORY=YES"
echo "RAW_EVIDENCE_MODIFIED=NO"

echo
echo "===== 23. FINAL PRE-COMMIT SUMMARY ====="

git status --short \
    > "$AUDIT/pre_commit_git_status.txt"

git lfs status \
    > "$AUDIT/pre_commit_lfs_status.txt"

echo "STAGED_CHANGE_TYPE_COUNTS:"
git diff --cached --name-status |
    cut -f1 |
    LC_ALL=C sort |
    uniq -c

echo
echo "STAGED_TOP_LEVEL_COUNTS:"
git diff --cached --name-only |
    awk -F/ '{print $1}' |
    LC_ALL=C sort |
    uniq -c

echo
echo "STAGED_SHORTSTAT:"
git diff --cached --shortstat

FINAL_STAGED_PATH_COUNT="$(
    git diff --cached --name-only |
    wc -l
)"

printf 'FINAL_STAGED_PATH_COUNT=%s\n' \
    "$FINAL_STAGED_PATH_COUNT"

if [ "$FINAL_STAGED_PATH_COUNT" -ne \
     "$EXPECTED_TOTAL_STAGED_PATHS" ]; then
    echo "FAIL: Final staged path count changed unexpectedly."
    exit 1
fi

echo
echo "================================================================"
echo " PRE-COMMIT SAFETY PASSED"
echo "================================================================"
echo "CURRENT_BRANCH=main"
echo "SEPARATE_BRANCH_CREATED=NO"
echo "CLASSIFIED_FILES_FOUND=186"
echo "PACKAGE_CHECKSUMS_VERIFIED=184"
echo "DESTINATION_COLLISIONS=0"
echo "BYTE_DIFFERENCES_AFTER_IMPORT=0"
echo "STAGED_ADDITIONS=186"
echo "STAGED_METADATA_MODIFICATIONS=4"
echo "STAGED_DELETIONS=0"
echo "STAGED_RENAMES=0"
echo "UNMERGED_ENTRIES=0"
echo "UNSTAGED_RESIDUES=0"
echo "UNTRACKED_RESIDUES=0"
echo "NEW_GIT_LFS_OBJECTS=0"
echo "RAW_EVIDENCE_PRESERVED_BYTE_EXACT=YES"
echo "NOTHING_COMMITTED_OR_PUSHED_YET=YES"

echo
read -r -p "Type exactly PUSH to commit and upload to GitHub: " CONFIRMATION

if [ "$CONFIRMATION" != "PUSH" ]; then
    echo
    echo "PUSH_CANCELLED=YES"
    echo "No commit or push was performed."
    echo "The verified files remain safely staged."
    exit 0
fi

echo
echo "===== 24. FINAL REMOTE RACE CHECK ====="

git fetch origin

LOCAL_BEFORE_COMMIT="$(git rev-parse HEAD)"
REMOTE_BEFORE_COMMIT="$(git rev-parse origin/main)"

printf 'LOCAL_HEAD_BEFORE_COMMIT=%s\n' \
    "$LOCAL_BEFORE_COMMIT"

printf 'REMOTE_HEAD_BEFORE_COMMIT=%s\n' \
    "$REMOTE_BEFORE_COMMIT"

if [ "$LOCAL_BEFORE_COMMIT" != "$EXPECTED_BASE_HEAD" ]; then
    echo "FAIL: Local HEAD changed during validation."
    exit 1
fi

if [ "$REMOTE_BEFORE_COMMIT" != "$EXPECTED_BASE_HEAD" ]; then
    echo "FAIL: GitHub main changed during validation."
    exit 1
fi

echo "FINAL_REMOTE_RACE_CHECK=PASS"

echo
echo "===== 25. CREATE COMMIT ====="

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

if [ "$COMMITTED_PATH_COUNT" -ne \
     "$EXPECTED_TOTAL_STAGED_PATHS" ]; then
    echo "FAIL: Commit does not contain exactly 190 paths."
    exit 1
fi

git lfs fsck

echo "LOCAL_COMMIT_VERIFICATION=PASS"

echo
echo "===== 26. PUSH TO GITHUB MAIN ====="

git push origin main

echo
echo "===== 27. VERIFY GITHUB REMOTE ====="

git fetch origin

REMOTE_COMMIT="$(git rev-parse origin/main)"

read -r LOCAL_ONLY_AFTER REMOTE_ONLY_AFTER <<< "$(
    git rev-list --left-right --count HEAD...origin/main
)"

printf 'LOCAL_COMMIT=%s\n' "$NEW_COMMIT"
printf 'REMOTE_COMMIT=%s\n' "$REMOTE_COMMIT"
printf 'LOCAL_ONLY_COMMITS_AFTER_PUSH=%s\n' "$LOCAL_ONLY_AFTER"
printf 'REMOTE_ONLY_COMMITS_AFTER_PUSH=%s\n' "$REMOTE_ONLY_AFTER"

if [ "$REMOTE_COMMIT" != "$NEW_COMMIT" ]; then
    echo "FAIL: GitHub main does not match the local commit."
    exit 1
fi

if [ "$LOCAL_ONLY_AFTER" -ne 0 ] ||
   [ "$REMOTE_ONLY_AFTER" -ne 0 ]; then
    echo "FAIL: Local and remote main differ after push."
    exit 1
fi

echo "REMOTE_COMMIT_VERIFICATION=PASS"

echo
echo "===== 28. FINAL REPOSITORY CLEANLINESS ====="

git status --branch --short

if [ -n "$(git status --porcelain)" ]; then
    echo "FAIL: Repository is not clean after push."
    git status --short
    exit 1
fi

git lfs status

echo
echo "================================================================"
echo " SUCCESS: POLY BYTE-CODEC CAMPAIGN PUSHED SAFELY"
echo "================================================================"
echo "PUSHED_COMMIT=$NEW_COMMIT"
echo "REMOTE_COMMIT=$REMOTE_COMMIT"
echo "CURRENT_BRANCH=main"
echo "SEPARATE_BRANCH_CREATED=NO"
echo "CLASSIFIED_FILES_IMPORTED=186"
echo "PACKAGE_CHECKSUMS_VERIFIED=184"
echo "COMMITTED_PATHS=$COMMITTED_PATH_COUNT"
echo "DELETIONS=0"
echo "RENAMES=0"
echo "UNMERGED_ENTRIES=0"
echo "UNSTAGED_RESIDUES=0"
echo "UNTRACKED_RESIDUES=0"
echo "NEW_GIT_LFS_OBJECTS=0"
echo "RAW_EVIDENCE_PRESERVED_BYTE_EXACT=YES"
echo "REMOTE_VERIFIED=YES"
echo "WORKTREE_CLEAN=YES"
echo "AUDIT_DIRECTORY=$AUDIT"
echo
echo "The extracted source package was intentionally not deleted."
