#!/usr/bin/env bash

set -u
set -o pipefail

REPO="/home/girish/THESIS-2026/mlkem-native_af4c5abd"
EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"

ROOT="$HOME/THESIS-2026/mlk_poly_tomsg_cleanroom/MSG00_af4c5ab"
STAGE="$ROOT/MSG00B_C_F_NATIVE_BASELINE_MLKEM768_RUN1"

INVENTORY="$HOME/THESIS-2026/MSG00A_R2_af4c5ab_poly_tomsg_inventory.txt"
PROOF="$REPO/proofs/cbmc/poly_tomsg"
GOTO="$PROOF/gotos/poly_tomsg_harness.goto"

echo "============================================================"
echo "MSG-00B/C/F: SAFE PREFLIGHT VALIDATION"
echo "============================================================"
echo "REPO=$REPO"
echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
echo "STAGE=$STAGE"
echo

if [ ! -d "$REPO" ]; then
  echo "ERROR: repository directory does not exist"
  echo "EXPECTED_REPO=$REPO"
  exit 1
fi

if ! git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: repository path is not a valid Git worktree"
  echo "REPO=$REPO"
  exit 1
fi

cd "$REPO" || {
  echo "ERROR: could not enter repository"
  exit 1
}

ACTUAL_COMMIT="$(git rev-parse HEAD)"
WORKTREE_STATE="$(git status --porcelain=v1)"

echo "ACTUAL_COMMIT=$ACTUAL_COMMIT"

if [ "$ACTUAL_COMMIT" != "$EXPECTED_COMMIT" ]; then
  echo "ERROR: commit mismatch"
  echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
  exit 1
fi

echo "COMMIT_BINDING=PASS"

if [ -n "$WORKTREE_STATE" ]; then
  echo "ERROR: tracked worktree is not clean"
  git status --short
  exit 1
fi

echo "WORKTREE_CLEAN=PASS"

if [ ! -f "$INVENTORY" ]; then
  echo "ERROR: accepted MSG-00A inventory is missing"
  echo "EXPECTED_FILE=$INVENTORY"
  exit 1
fi

echo "INVENTORY_PRESENT=PASS"

if [ -e "$STAGE" ]; then
  echo "ERROR: stage already exists; refusing to overwrite evidence"
  echo "EXISTING_STAGE=$STAGE"
  echo
  echo "STAGE_CONTENT_PREVIEW:"
  find "$STAGE" -maxdepth 2 -type f -printf '%P\n' 2>/dev/null |
    sort |
    head -n 40
  exit 1
fi

echo "STAGE_ABSENT=PASS"

for TOOL in cbmc goto-cc goto-instrument python3 git sha256sum; do
  if ! command -v "$TOOL" >/dev/null 2>&1; then
    echo "ERROR: required tool is unavailable: $TOOL"
    exit 1
  fi
done

echo "REQUIRED_TOOLS=PASS"

if [ ! -d "$PROOF" ]; then
  echo "ERROR: native poly_tomsg proof directory is missing"
  echo "EXPECTED_PROOF=$PROOF"
  exit 1
fi

echo "NATIVE_PROOF_DIRECTORY=PASS"

if [ -f "$GOTO" ]; then
  echo "EXISTING_NATIVE_GOTO=YES"
  ls -lh "$GOTO"
else
  echo "EXISTING_NATIVE_GOTO=NO"
  echo "NOTE: the native GOTO may need to be built by the main campaign."
fi

echo
echo "CBMC_VERSION=$(cbmc --version | head -n 1)"
echo "GOTO_CC_VERSION=$(goto-cc --version | head -n 1)"
echo "GOTO_INSTRUMENT_VERSION=$(goto-instrument --version | head -n 1)"
echo
echo "MSG00B_C_F_SAFE_PREFLIGHT=PASS"
