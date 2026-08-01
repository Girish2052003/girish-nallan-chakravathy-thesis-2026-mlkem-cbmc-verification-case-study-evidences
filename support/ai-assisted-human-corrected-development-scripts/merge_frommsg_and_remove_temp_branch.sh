#!/usr/bin/env bash
set -Eeuo pipefail

fail() {
  echo
  echo "FATAL: $*" >&2
  exit 1
}

trap 'rc=$?; echo; echo "BRANCH_CLEANUP_ABORTED: exit=$rc line=$LINENO" >&2; exit "$rc"' ERR

REPO="$HOME/THESIS-2026/CLASSIFICATION GIT/MLKEM_CBMC_FULL_CLASSIFIED_BASELINE_2026-07-19"

TEMP_BRANCH="import/frommsg-classified-20260731"
EXPECTED_COMMIT="ce76154c47465dbe58d83b434d20c5486eb9472e"
EXPECTED_ROOT="experiments/poly-frommsg"
EXPECTED_FILES=29651

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
AUDIT="$HOME/THESIS-2026/FROMMSG_SINGLE_MAIN_BRANCH_AUDIT_$STAMP"

mkdir -p "$AUDIT"
exec > >(tee "$AUDIT/terminal_capture.txt") 2>&1

echo "============================================================"
echo "FROMMSG LOSSLESS MERGE AND TEMPORARY BRANCH REMOVAL"
echo "============================================================"
echo "REPOSITORY=$REPO"
echo "TEMP_BRANCH=$TEMP_BRANCH"
echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
echo "AUDIT_DIRECTORY=$AUDIT"
echo

for tool in git git-lfs awk python3 tee
do
  command -v "$tool" >/dev/null 2>&1 ||
    fail "missing required tool: $tool"
done

[[ -d "$REPO/.git" ]] ||
  fail "Git repository not found"

echo
echo "===== 1. CLEAN-WORKTREE GATE ====="

if [[ -n "$(
  git -C "$REPO" status \
    --porcelain=v1 \
    --untracked-files=all
)" ]]
then
  git -C "$REPO" status --short --untracked-files=all
  fail "repository contains uncommitted changes"
fi

echo "WORKTREE_CLEAN=PASS"

echo
echo "===== 2. FETCH CURRENT GITHUB STATE ====="

git -C "$REPO" fetch --prune origin

git -C "$REPO" show-ref --verify --quiet refs/remotes/origin/main ||
  fail "origin/main is unavailable"

REMOTE_TEMP_COMMIT="$(
  git -C "$REPO" ls-remote \
    --heads origin "refs/heads/$TEMP_BRANCH" |
    awk '{print $1}'
)"

echo "REMOTE_TEMP_COMMIT=$REMOTE_TEMP_COMMIT"

[[ "$REMOTE_TEMP_COMMIT" == "$EXPECTED_COMMIT" ]] ||
  fail "temporary GitHub branch does not contain the expected commit"

git -C "$REPO" cat-file -e "$EXPECTED_COMMIT^{commit}" ||
  fail "expected commit object is unavailable locally"

echo "TEMPORARY_BRANCH_COMMIT=PASS"

echo
echo "===== 3. VERIFY ALL FROMMSG EVIDENCE EXISTS IN COMMIT ====="

FROMMSG_FILE_COUNT="$(
  git -C "$REPO" ls-tree \
    -r \
    --name-only \
    "$EXPECTED_COMMIT" \
    -- "$EXPECTED_ROOT" |
    wc -l
)"

echo "FROMMSG_FILE_COUNT=$FROMMSG_FILE_COUNT"

[[ "$FROMMSG_FILE_COUNT" == "$EXPECTED_FILES" ]] ||
  fail "expected $EXPECTED_FILES files, found $FROMMSG_FILE_COUNT"

python3 - "$REPO" "$EXPECTED_COMMIT" "$EXPECTED_ROOT" "$EXPECTED_FILES" <<'PY'
from __future__ import annotations

import subprocess
import sys

repo = sys.argv[1]
commit = sys.argv[2]
root = sys.argv[3] + "/"
expected = int(sys.argv[4])

parent = subprocess.check_output(
    ["git", "-C", repo, "rev-parse", f"{commit}^"],
    text=True,
).strip()

output = subprocess.check_output(
    [
        "git",
        "-C",
        repo,
        "diff",
        "--name-status",
        "-z",
        parent,
        commit,
    ]
)

parts = [part for part in output.split(b"\0") if part]

if len(parts) % 2 != 0:
    raise SystemExit("MALFORMED_COMMIT_DIFF")

records = []

for index in range(0, len(parts), 2):
    status = parts[index].decode("utf-8", "surrogateescape")
    path = parts[index + 1].decode("utf-8", "surrogateescape")
    records.append((status, path))

if len(records) != expected:
    raise SystemExit(
        f"COMMIT_FILE_COUNT_MISMATCH "
        f"expected={expected} actual={len(records)}"
    )

non_additions = [
    (status, path)
    for status, path in records
    if status != "A"
]

if non_additions:
    raise SystemExit(
        f"COMMIT_CONTAINS_NON_ADDITIONS "
        f"first={non_additions[:10]}"
    )

outside = [
    path
    for _status, path in records
    if not path.startswith(root)
]

if outside:
    raise SystemExit(
        f"COMMIT_CONTAINS_OUTSIDE_PATHS "
        f"first={outside[:10]}"
    )

print(f"VERIFIED_ADDITION_COUNT={len(records)}")
print("MODIFIED_EXISTING_FILES=0")
print("DELETED_EXISTING_FILES=0")
print("OUTSIDE_FROMMSG_ROOT=0")
print("COMMIT_SCOPE=PASS")
PY

echo
echo "===== 4. VERIFY FAST-FORWARD RELATION ====="

REMOTE_MAIN_BEFORE="$(
  git -C "$REPO" rev-parse origin/main
)"

echo "REMOTE_MAIN_BEFORE=$REMOTE_MAIN_BEFORE"

if [[ "$REMOTE_MAIN_BEFORE" != "$EXPECTED_COMMIT" ]]
then
  git -C "$REPO" merge-base --is-ancestor \
    "$REMOTE_MAIN_BEFORE" "$EXPECTED_COMMIT" ||
    fail "expected commit is not a fast-forward descendant of origin/main"

  echo "MAIN_REQUIRES_FAST_FORWARD=YES"
else
  echo "MAIN_ALREADY_CONTAINS_FROMMSG=YES"
fi

echo "FAST_FORWARD_SAFETY=PASS"

echo
echo "===== 5. SWITCH LOCAL REPOSITORY TO MAIN ====="

git -C "$REPO" switch main

LOCAL_MAIN_BEFORE="$(
  git -C "$REPO" rev-parse HEAD
)"

echo "LOCAL_MAIN_BEFORE=$LOCAL_MAIN_BEFORE"

git -C "$REPO" merge-base --is-ancestor \
  "$LOCAL_MAIN_BEFORE" "$EXPECTED_COMMIT" ||
  fail "local main is not an ancestor of the expected commit"

echo
echo "===== 6. FAST-FORWARD LOCAL MAIN ====="

git -C "$REPO" merge --ff-only "$EXPECTED_COMMIT"

LOCAL_MAIN_AFTER="$(
  git -C "$REPO" rev-parse HEAD
)"

echo "LOCAL_MAIN_AFTER=$LOCAL_MAIN_AFTER"

[[ "$LOCAL_MAIN_AFTER" == "$EXPECTED_COMMIT" ]] ||
  fail "local main did not reach the expected commit"

echo "LOCAL_MAIN_FAST_FORWARD=PASS"

echo
echo "===== 7. VERIFY MAIN BEFORE PUSH ====="

MAIN_FROMMSG_COUNT="$(
  git -C "$REPO" ls-tree \
    -r \
    --name-only \
    main \
    -- "$EXPECTED_ROOT" |
    wc -l
)"

echo "MAIN_FROMMSG_FILE_COUNT=$MAIN_FROMMSG_COUNT"

[[ "$MAIN_FROMMSG_COUNT" == "$EXPECTED_FILES" ]] ||
  fail "main does not contain all expected FROMMSG files"

if git -C "$REPO" show-ref --verify --quiet \
  "refs/heads/$TEMP_BRANCH"
then
  git -C "$REPO" diff --quiet main "$TEMP_BRANCH" ||
    fail "local main and temporary branch do not have identical trees"

  echo "LOCAL_MAIN_TEMP_TREE_IDENTITY=PASS"
fi

if [[ -n "$(
  git -C "$REPO" status \
    --porcelain=v1 \
    --untracked-files=all
)" ]]
then
  git -C "$REPO" status --short --untracked-files=all
  fail "worktree is not clean before main push"
fi

git -C "$REPO" fsck --full

echo "PRE_PUSH_GIT_INTEGRITY=PASS"

echo
echo "===== 8. FINAL REMOTE RACE CHECK ====="

git -C "$REPO" fetch --prune origin

REMOTE_MAIN_RACECHECK="$(
  git -C "$REPO" rev-parse origin/main
)"

echo "REMOTE_MAIN_RACECHECK=$REMOTE_MAIN_RACECHECK"

[[ "$REMOTE_MAIN_RACECHECK" == "$REMOTE_MAIN_BEFORE" ]] ||
  fail "origin/main changed while checks were running"

echo "REMOTE_MAIN_UNCHANGED=PASS"

echo
echo "===== 9. PUSH MAIN TO GITHUB ====="

git -C "$REPO" push origin main

REMOTE_MAIN_AFTER="$(
  git -C "$REPO" ls-remote \
    --heads origin refs/heads/main |
    awk '{print $1}'
)"

echo "REMOTE_MAIN_AFTER=$REMOTE_MAIN_AFTER"

[[ "$REMOTE_MAIN_AFTER" == "$EXPECTED_COMMIT" ]] ||
  fail "GitHub main does not equal the expected FROMMSG commit"

echo "MAIN_REMOTE_PUSH=PASS"
echo "REMOTE_MAIN_COMMIT_MATCH=PASS"

echo
echo "===== 10. DELETE TEMPORARY GITHUB BRANCH ====="

# This is safe because GitHub main was already verified at the same commit.
git -C "$REPO" push origin --delete "$TEMP_BRANCH"

REMOTE_TEMP_AFTER="$(
  git -C "$REPO" ls-remote \
    --heads origin "refs/heads/$TEMP_BRANCH" |
    awk '{print $1}'
)"

[[ -z "$REMOTE_TEMP_AFTER" ]] ||
  fail "temporary GitHub branch still exists"

echo "REMOTE_TEMP_BRANCH_DELETED=PASS"

echo
echo "===== 11. DELETE TEMPORARY LOCAL BRANCH ====="

if git -C "$REPO" show-ref --verify --quiet \
  "refs/heads/$TEMP_BRANCH"
then
  git -C "$REPO" branch -d "$TEMP_BRANCH"
fi

if git -C "$REPO" show-ref --verify --quiet \
  "refs/heads/$TEMP_BRANCH"
then
  fail "temporary local branch still exists"
fi

echo "LOCAL_TEMP_BRANCH_DELETED=PASS"

echo
echo "===== 12. PRUNE AND VERIFY ONLY MAIN REMAINS ON GITHUB ====="

git -C "$REPO" fetch --prune origin

mapfile -t REMOTE_BRANCHES < <(
  git -C "$REPO" ls-remote --heads origin |
    awk '{
      sub("refs/heads/", "", $2)
      print $2
    }' |
    sort
)

printf 'REMOTE_BRANCH=%s\n' "${REMOTE_BRANCHES[@]}"

if [[ "${#REMOTE_BRANCHES[@]}" -ne 1 ]] ||
   [[ "${REMOTE_BRANCHES[0]}" != "main" ]]
then
  fail "GitHub still contains branches other than main; no unknown branches were deleted"
fi

echo "REMOTE_BRANCH_COUNT=1"
echo "ONLY_REMOTE_BRANCH=main"

echo
echo "===== 13. FINAL LOSSLESS VERIFICATION ====="

FINAL_LOCAL_BRANCH="$(
  git -C "$REPO" branch --show-current
)"

FINAL_LOCAL_HEAD="$(
  git -C "$REPO" rev-parse HEAD
)"

FINAL_REMOTE_MAIN="$(
  git -C "$REPO" ls-remote \
    --heads origin refs/heads/main |
    awk '{print $1}'
)"

FINAL_FROMMSG_COUNT="$(
  git -C "$REPO" ls-tree \
    -r \
    --name-only \
    "$FINAL_REMOTE_MAIN" \
    -- "$EXPECTED_ROOT" |
    wc -l
)"

echo "FINAL_LOCAL_BRANCH=$FINAL_LOCAL_BRANCH"
echo "FINAL_LOCAL_HEAD=$FINAL_LOCAL_HEAD"
echo "FINAL_REMOTE_MAIN=$FINAL_REMOTE_MAIN"
echo "FINAL_FROMMSG_FILE_COUNT=$FINAL_FROMMSG_COUNT"

[[ "$FINAL_LOCAL_BRANCH" == "main" ]] ||
  fail "final local branch is not main"

[[ "$FINAL_LOCAL_HEAD" == "$EXPECTED_COMMIT" ]] ||
  fail "final local main commit mismatch"

[[ "$FINAL_REMOTE_MAIN" == "$EXPECTED_COMMIT" ]] ||
  fail "final GitHub main commit mismatch"

[[ "$FINAL_FROMMSG_COUNT" == "$EXPECTED_FILES" ]] ||
  fail "final FROMMSG evidence count mismatch"

if [[ -n "$(
  git -C "$REPO" status \
    --porcelain=v1 \
    --untracked-files=all
)" ]]
then
  git -C "$REPO" status --short --untracked-files=all
  fail "final worktree is not clean"
fi

{
  echo "UTC_TIME=$STAMP"
  echo "FINAL_LOCAL_BRANCH=$FINAL_LOCAL_BRANCH"
  echo "FINAL_LOCAL_HEAD=$FINAL_LOCAL_HEAD"
  echo "FINAL_REMOTE_MAIN=$FINAL_REMOTE_MAIN"
  echo "FINAL_REMOTE_BRANCH_COUNT=1"
  echo "FINAL_REMOTE_BRANCH=main"
  echo "FROMMSG_FILES=$FINAL_FROMMSG_COUNT"
  echo "TEMPORARY_REMOTE_BRANCH_DELETED=YES"
  echo "TEMPORARY_LOCAL_BRANCH_DELETED=YES"
  echo "LOSSLESS_MERGE=PASS"
  echo "FINAL_STATUS=PASS"
} > "$AUDIT/FINAL_SINGLE_MAIN_BRANCH_SUMMARY.txt"

echo
echo "============================================================"
echo "FROMMSG_LOSSLESS_MERGE=PASS"
echo "MAIN_REMOTE_PUSH=PASS"
echo "REMOTE_MAIN_COMMIT_MATCH=PASS"
echo "FROMMSG_FILES_PRESERVED=$FINAL_FROMMSG_COUNT"
echo "TEMP_REMOTE_BRANCH_DELETED=PASS"
echo "TEMP_LOCAL_BRANCH_DELETED=PASS"
echo "REMOTE_BRANCH_COUNT=1"
echo "ONLY_REMOTE_BRANCH=main"
echo "FINAL_BRANCH=main"
echo "FINAL_HEAD=$FINAL_LOCAL_HEAD"
echo "FINAL_SUMMARY=$AUDIT/FINAL_SINGLE_MAIN_BRANCH_SUMMARY.txt"
echo "============================================================"
