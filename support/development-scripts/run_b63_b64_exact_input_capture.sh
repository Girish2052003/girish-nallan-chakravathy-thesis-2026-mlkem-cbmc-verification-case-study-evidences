#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B5="$ROOT/SUB00Q_BATCH5_T5_RELATIONAL"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"

PREREG="$B6/00_PREREGISTRATION"
BIND="$B6/01_CALLCHAIN_BINDING"
ASSUME="$B6/02_ASSUMPTION_AUDIT"
HFREEZE="$B6/03_HARNESS_FREEZE"
PREFLIGHT="$B6/04_GOTO_PREFLIGHT"
SRC="$ROOT/source/mlkem/src"

CAPTURE="$HFREEZE/B6_3_4_INPUT_CAPTURE"
TAR="$HOME/Downloads/SUB_T6_B6_3_4_INPUT_CAPTURE.tar.gz"
TERMINAL_LOG="$HOME/B63_B64_INPUT_CAPTURE_terminal_output.txt"

echo "=== SUB-T6 COMBINED B6.3+B6.4 EXACT INPUT CAPTURE ==="
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "ROOT=$ROOT"
echo "B5=$B5"
echo "B6=$B6"
echo "CAPTURE=$CAPTURE"
echo "TAR=$TAR"

test -d "$ROOT"
test -d "$B5"
test -d "$B6"
test -d "$HFREEZE"
test -d "$PREFLIGHT"
test -d "$SRC"

test -f "$PREREG/SUB_T6_B6_0_PREREGISTRATION.json"
test -f "$BIND/B6_1_BINDING.json"
test -f "$ASSUME/B6_2_ASSUMPTION_AUDIT.json"

python3 -m json.tool \
  "$PREREG/SUB_T6_B6_0_PREREGISTRATION.json" >/dev/null
python3 -m json.tool \
  "$BIND/B6_1_BINDING.json" >/dev/null
python3 -m json.tool \
  "$ASSUME/B6_2_ASSUMPTION_AUDIT.json" >/dev/null

grep -F '"status": "FROZEN"' \
  "$PREREG/SUB_T6_B6_0_PREREGISTRATION.json" >/dev/null
grep -F '"status": "FROZEN"' \
  "$BIND/B6_1_BINDING.json" >/dev/null
grep -F '"status": "FROZEN"' \
  "$ASSUME/B6_2_ASSUMPTION_AUDIT.json" >/dev/null

if [ -e "$CAPTURE" ]; then
    echo "CAPTURE_ALREADY_EXISTS=$CAPTURE"
    exit 1
fi

if [ -e "$TAR" ]; then
    echo "TAR_ALREADY_EXISTS=$TAR"
    exit 1
fi

mkdir -p \
  "$CAPTURE/00_CONTROL" \
  "$CAPTURE/01_BATCH5_SELECTED" \
  "$CAPTURE/02_SOURCE_SELECTED" \
  "$CAPTURE/03_DISCOVERY"

# Copy already frozen Batch-6 controls.
cp -a \
  "$PREREG/SUB_T6_B6_0_PREREGISTRATION.json" \
  "$PREREG/SUB_T6_B6_0_PREREGISTRATION.md" \
  "$BIND/B6_1_BINDING.json" \
  "$BIND/B6_1_BINDING.md" \
  "$BIND/B6_1_CONTRACT_EXTRACTION.txt" \
  "$BIND/B6_1_2_COMBINED_FREEZE_MANIFEST.json" \
  "$ASSUME/B6_2_ASSUMPTION_AUDIT.json" \
  "$ASSUME/B6_2_ASSUMPTION_AUDIT.md" \
  "$CAPTURE/00_CONTROL/"

# Copy exact source files needed to design and audit the slice.
for name in \
  indcpa.c \
  poly.c \
  poly.h \
  poly_k.c \
  poly_k.h \
  compress.c \
  compress.h \
  params.h \
  cbmc.h \
  verify.h
do
    test -f "$SRC/$name"
    cp -a "$SRC/$name" "$CAPTURE/02_SOURCE_SELECTED/$name"
done

python3 - "$B5" "$CAPTURE" <<'PY'
import hashlib
import json
import os
import re
import shutil
import sys
from pathlib import Path

b5 = Path(sys.argv[1])
capture = Path(sys.argv[2])
selected_root = capture / "01_BATCH5_SELECTED"
discovery = capture / "03_DISCOVERY"

keywords = (
    "harness", "build", "compile", "command", "run", "manifest",
    "support", "zeroize", "pragma", "cbmc", "goto", "t5", "sub_t5",
    "makefile", "cmake",
)
extensions = {
    ".c", ".h", ".sh", ".py", ".json", ".txt", ".md",
    ".mk", ".cmake", ".yml", ".yaml",
}
max_file_size = 2 * 1024 * 1024

all_files = sorted(p for p in b5.rglob("*") if p.is_file())
selected = []

for path in all_files:
    rel = path.relative_to(b5)
    rel_lower = str(rel).lower()
    name_lower = path.name.lower()

    include = (
        path.suffix.lower() in {".c", ".h", ".sh", ".mk"}
        or any(word in name_lower for word in keywords)
        or any(word in rel_lower for word in keywords)
    )

    if include and path.stat().st_size <= max_file_size:
        selected.append(path)

if not selected:
    raise SystemExit("NO_BATCH5_FILES_SELECTED")

# Keep the capture bounded and fail closed if the prior batch is unexpectedly huge.
if len(selected) > 300:
    raise SystemExit(f"TOO_MANY_SELECTED_BATCH5_FILES={len(selected)}")

for path in selected:
    rel = path.relative_to(b5)
    dst = selected_root / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, dst)

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

inventory = []
for path in selected:
    inventory.append({
        "relative_path": str(path.relative_to(b5)),
        "size": path.stat().st_size,
        "sha256": sha256(path),
    })

(discovery / "BATCH5_SELECTED_INVENTORY.json").write_text(
    json.dumps(
        {
            "schema": "sub-t6-b6.3-b6.4-input-capture-v1",
            "batch5_root": str(b5),
            "selected_file_count": len(inventory),
            "selected_files": inventory,
        },
        indent=2,
        sort_keys=True,
    ) + "\n",
    encoding="utf-8",
)

(discovery / "BATCH5_SELECTED_PATHS.txt").write_text(
    "".join(item["relative_path"] + "\n" for item in inventory),
    encoding="utf-8",
)

# Extract exact build/tool command evidence without executing anything.
text_extensions = {
    ".c", ".h", ".sh", ".py", ".json", ".txt", ".md",
    ".mk", ".cmake", ".yml", ".yaml",
}
patterns = re.compile(
    r"goto-cc|goto-clang|goto-instrument|\bcbmc\b|"
    r"--function|--unwind|--unwinding-assertions|"
    r"-DMLKEM|-DMLK_|(?:^|\s)-I\S*|"
    r"poly\.c|compress\.c|sub_t5|harness",
    re.IGNORECASE,
)

hits = []
for path in selected:
    if path.suffix.lower() not in text_extensions:
        continue
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        continue
    for line_number, line in enumerate(text.splitlines(), start=1):
        if patterns.search(line):
            hits.append(
                f"{path.relative_to(b5)}:{line_number}:{line}"
            )

(discovery / "BUILD_AND_CBMC_COMMAND_HITS.txt").write_text(
    "\n".join(hits) + ("\n" if hits else ""),
    encoding="utf-8",
)

# Harness and support candidates get their own concise map.
candidate_pattern = re.compile(
    r"harness|support|zeroize|pragma|run.*\.sh|build.*\.sh|"
    r"compile.*\.sh|command|manifest",
    re.IGNORECASE,
)

candidates = [
    item for item in inventory
    if candidate_pattern.search(item["relative_path"])
    or Path(item["relative_path"]).suffix.lower() in {".c", ".h", ".sh"}
]

(discovery / "HARNESS_BUILD_SUPPORT_CANDIDATES.json").write_text(
    json.dumps(
        {
            "candidate_count": len(candidates),
            "candidates": candidates,
        },
        indent=2,
        sort_keys=True,
    ) + "\n",
    encoding="utf-8",
)

print(f"BATCH5_TOTAL_FILE_COUNT={len(all_files)}")
print(f"BATCH5_SELECTED_FILE_COUNT={len(selected)}")
print(f"BUILD_COMMAND_HIT_COUNT={len(hits)}")
print(f"HARNESS_BUILD_SUPPORT_CANDIDATE_COUNT={len(candidates)}")
PY

# Human-readable Batch-5 tree and exact tool versions.
{
    echo "=== BATCH5 DIRECTORY TREE ==="
    find "$B5" -maxdepth 4 -printf '%y %m %s %p\n' | sort
} > "$CAPTURE/03_DISCOVERY/BATCH5_TREE_MAXDEPTH4.txt"

{
    echo "=== TOOL VERSION CAPTURE ==="
    echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    for tool in cbmc goto-cc goto-clang goto-instrument gcc clang python3; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo
            echo "TOOL=$tool"
            echo "PATH=$(command -v "$tool")"
            "$tool" --version 2>&1 | sed -n '1,5p' || true
        else
            echo
            echo "TOOL=$tool"
            echo "AVAILABLE=NO"
        fi
    done
} > "$CAPTURE/03_DISCOVERY/TOOL_VERSIONS.txt"

# Record source hashes and current modes.
{
    echo "=== SELECTED SOURCE HASHES ==="
    sha256sum "$CAPTURE/02_SOURCE_SELECTED/"*
    echo
    echo "=== FROZEN CONTROL MODES ==="
    stat -c 'MODE=%a TYPE=%F FILE=%n' \
      "$PREREG" "$BIND" "$ASSUME" \
      "$PREREG/SUB_T6_B6_0_PREREGISTRATION.json" \
      "$BIND/B6_1_BINDING.json" \
      "$ASSUME/B6_2_ASSUMPTION_AUDIT.json"
} > "$CAPTURE/03_DISCOVERY/SOURCE_HASHES_AND_CONTROL_MODES.txt"

python3 - "$CAPTURE" <<'PY'
import datetime
import hashlib
import json
import sys
from pathlib import Path

capture = Path(sys.argv[1])

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

files = sorted(
    path for path in capture.rglob("*")
    if path.is_file()
    and path.name not in {
        "CAPTURE_MANIFEST.json",
        "CAPTURE_SHA256.txt",
    }
)

manifest = {
    "schema": "sub-t6-b6.3-b6.4-exact-input-capture-v1",
    "status": "CAPTURED_NOT_FROZEN",
    "created_utc": datetime.datetime.now(
        datetime.timezone.utc
    ).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
    "purpose": (
        "Bind the exact Batch-5 harness/build infrastructure and "
        "authoritative Batch-6 source/contracts before generating "
        "SUB-T6 harnesses or constructing GOTO models."
    ),
    "execution_state": {
        "cbmc_executed": False,
        "goto_constructed": False,
        "harness_constructed": False,
        "production_modified": False,
        "batch5_modified": False,
        "results_observed": False,
    },
    "file_count": len(files),
    "files": {
        str(path.relative_to(capture)): {
            "size": path.stat().st_size,
            "sha256": sha256(path),
        }
        for path in files
    },
}

(capture / "CAPTURE_MANIFEST.json").write_text(
    json.dumps(manifest, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

hash_targets = sorted(
    path for path in capture.rglob("*")
    if path.is_file()
    and path.name != "CAPTURE_SHA256.txt"
)

(capture / "CAPTURE_SHA256.txt").write_text(
    "".join(f"{sha256(path)}  {path}\n" for path in hash_targets),
    encoding="utf-8",
)

print(f"CAPTURE_FILE_COUNT={len(hash_targets)}")
print("CAPTURE_MANIFEST_STATUS=PASS")
PY

python3 -m json.tool "$CAPTURE/CAPTURE_MANIFEST.json" >/dev/null
python3 -m json.tool \
  "$CAPTURE/03_DISCOVERY/BATCH5_SELECTED_INVENTORY.json" >/dev/null
python3 -m json.tool \
  "$CAPTURE/03_DISCOVERY/HARNESS_BUILD_SUPPORT_CANDIDATES.json" >/dev/null

# Create a portable archive. Capture remains writable because it is not yet a freeze.
tar -C "$HFREEZE" \
  -czf "$TAR" \
  "$(basename "$CAPTURE")"

echo
echo "--- Capture summary ---"
python3 - "$CAPTURE/CAPTURE_MANIFEST.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    d = json.load(handle)

print("CAPTURE_SCHEMA=" + d["schema"])
print("CAPTURE_STATUS=" + d["status"])
print("CAPTURE_FILE_COUNT=" + str(d["file_count"]))

for key, value in d["execution_state"].items():
    print(key.upper() + "=" + str(value).upper())
PY

echo
echo "--- Archive ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$TAR"
sha256sum "$TAR"

echo
echo "B63_B64_EXACT_INPUT_CAPTURE=PASS"
echo "B63_B64_HARNESS_CONSTRUCTED=NO"
echo "B63_B64_GOTO_CONSTRUCTED=NO"
echo "B63_B64_CBMC_EXECUTED=NO"
echo "B63_B64_PRODUCTION_MODIFIED=NO"
echo "B63_B64_BATCH5_MODIFIED=NO"
echo "B63_B64_RESULTS_OBSERVED=NO"
echo "B63_B64_UPLOAD_REQUIRED=YES"
echo "B63_B64_STATUS=PASS"
