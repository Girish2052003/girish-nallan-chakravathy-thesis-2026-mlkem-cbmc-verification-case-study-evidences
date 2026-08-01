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
FAILED_CAPTURE="$HFREEZE/FAILED_ATTEMPT_1_TOO_BROAD_SELECTION"
TAR="$HOME/Downloads/SUB_T6_B6_3_4_INPUT_CAPTURE.tar.gz"

echo "=== SUB-T6 B6.3+B6.4 INPUT-CAPTURE RECOVERY V2 ==="
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "ROOT=$ROOT"
echo "B5=$B5"
echo "B6=$B6"
echo "CAPTURE=$CAPTURE"
echo "FAILED_CAPTURE=$FAILED_CAPTURE"
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

grep -F '"status": "FROZEN"' \
  "$PREREG/SUB_T6_B6_0_PREREGISTRATION.json" >/dev/null
grep -F '"status": "FROZEN"' \
  "$BIND/B6_1_BINDING.json" >/dev/null
grep -F '"status": "FROZEN"' \
  "$ASSUME/B6_2_ASSUMPTION_AUDIT.json" >/dev/null

# Preserve the partial directory created by the over-broad selection attempt.
if [ -d "$CAPTURE" ]; then
    if [ -e "$FAILED_CAPTURE" ]; then
        echo "FAILED_CAPTURE_DESTINATION_ALREADY_EXISTS=$FAILED_CAPTURE"
        exit 1
    fi

    mv "$CAPTURE" "$FAILED_CAPTURE"

    cat > "$FAILED_CAPTURE/FAILURE_REASON.txt" <<'EOF'
The first B6.3+B6.4 input-capture script selected 501 Batch-5 files and
failed closed because its selection policy was too broad. It stopped before
archive creation, harness construction, GOTO construction, CBMC execution,
or proof-result production. The partial capture is retained unchanged as
failed-attempt evidence.
EOF
fi

if [ -e "$TAR" ]; then
    echo "ARCHIVE_ALREADY_EXISTS=$TAR"
    exit 1
fi

mkdir -p \
  "$CAPTURE/00_CONTROL" \
  "$CAPTURE/01_BATCH5_SELECTED" \
  "$CAPTURE/02_SOURCE_SELECTED" \
  "$CAPTURE/03_DISCOVERY"

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
import re
import shutil
import sys
from pathlib import Path

b5 = Path(sys.argv[1])
capture = Path(sys.argv[2])
selected_root = capture / "01_BATCH5_SELECTED"
discovery = capture / "03_DISCOVERY"

MAX_SELECTED = 160
MAX_FILE_SIZE = 2 * 1024 * 1024

text_exts = {
    ".c", ".h", ".sh", ".py", ".json", ".txt", ".md",
    ".mk", ".cmake", ".yml", ".yaml",
}
excluded_exts = {
    ".zip", ".gz", ".tgz", ".tar", ".bz2", ".xz",
    ".goto", ".gb", ".o", ".a", ".so", ".png", ".jpg", ".pdf",
}

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def score(path: Path) -> tuple[int, str]:
    rel = str(path.relative_to(b5))
    rel_lower = rel.lower()
    base = path.name.lower()
    suffix = path.suffix.lower()

    points = 0

    if "sub_t5" in base or "sub-t5" in base:
        points += 120
    if "harness" in base:
        points += 100
    if suffix == ".sh":
        points += 90
    if "command" in base or "cmd" in base:
        points += 80
    if "build" in base or "compile" in base:
        points += 75
    if "manifest" in base:
        points += 70
    if "cbmc" in base or "goto" in base:
        points += 65
    if "support" in base or "zeroize" in base or "pragma" in base:
        points += 60
    if "freeze" in rel_lower or "final" in rel_lower:
        points += 45
    if "positive" in rel_lower or "execution" in rel_lower:
        points += 35
    if suffix in {".c", ".h"}:
        points += 20
    if suffix in {".json", ".txt", ".md", ".mk", ".cmake"}:
        points += 10
    if "mutation" in rel_lower or "mutant" in rel_lower:
        points -= 35
    if "counterexample" in rel_lower:
        points -= 15

    return points, rel

all_files = sorted(path for path in b5.rglob("*") if path.is_file())

full_inventory = []
candidates = []

for path in all_files:
    rel = str(path.relative_to(b5))
    suffix = path.suffix.lower()
    size = path.stat().st_size

    full_inventory.append({
        "relative_path": rel,
        "size": size,
        "suffix": suffix,
    })

    if suffix in excluded_exts:
        continue
    if size > MAX_FILE_SIZE:
        continue
    if suffix not in text_exts:
        continue

    points, _ = score(path)

    if points >= 55:
        candidates.append((points, rel, path))

candidates.sort(key=lambda item: (-item[0], item[1]))

selected = candidates[:MAX_SELECTED]
omitted = candidates[MAX_SELECTED:]

if not selected:
    raise SystemExit("NO_RELEVANT_BATCH5_FILES_SELECTED")

for points, rel, path in selected:
    dst = selected_root / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, dst)

selected_inventory = [
    {
        "score": points,
        "relative_path": rel,
        "size": path.stat().st_size,
        "sha256": sha256(path),
    }
    for points, rel, path in selected
]

omitted_inventory = [
    {
        "score": points,
        "relative_path": rel,
        "size": path.stat().st_size,
    }
    for points, rel, path in omitted
]

(discovery / "BATCH5_FULL_FILE_INVENTORY.json").write_text(
    json.dumps(
        {
            "batch5_root": str(b5),
            "total_file_count": len(full_inventory),
            "files": full_inventory,
        },
        indent=2,
        sort_keys=True,
    ) + "\n",
    encoding="utf-8",
)

(discovery / "BATCH5_SELECTED_INVENTORY.json").write_text(
    json.dumps(
        {
            "schema": "sub-t6-b6.3-b6.4-ranked-selection-v2",
            "selection_cap": MAX_SELECTED,
            "candidate_count": len(candidates),
            "selected_file_count": len(selected_inventory),
            "omitted_candidate_count": len(omitted_inventory),
            "selected_files": selected_inventory,
            "omitted_candidates": omitted_inventory,
        },
        indent=2,
        sort_keys=True,
    ) + "\n",
    encoding="utf-8",
)

(discovery / "BATCH5_SELECTED_PATHS.txt").write_text(
    "".join(
        f"{item['score']:03d} {item['relative_path']}\n"
        for item in selected_inventory
    ),
    encoding="utf-8",
)

(discovery / "BATCH5_OMITTED_CANDIDATE_PATHS.txt").write_text(
    "".join(
        f"{item['score']:03d} {item['relative_path']}\n"
        for item in omitted_inventory
    ),
    encoding="utf-8",
)

(discovery / "SELECTION_POLICY.txt").write_text(
    "\n".join([
        "Purpose: capture exact Batch-5 harness/build evidence without copying the entire batch.",
        f"Maximum selected files: {MAX_SELECTED}",
        f"Maximum individual file size: {MAX_FILE_SIZE}",
        "Archives, binaries, objects and images are excluded.",
        "Files are ranked by exact harness, script, command, build, manifest, CBMC/GOTO,",
        "support-header, final-freeze and positive-execution indicators.",
        "Every omitted candidate remains listed in BATCH5_OMITTED_CANDIDATE_PATHS.txt.",
        "This capture does not construct a harness, GOTO model, or CBMC result.",
        "",
    ]),
    encoding="utf-8",
)

# Extract command/config evidence only from selected files.
command_re = re.compile(
    r"goto-cc|goto-clang|goto-instrument|\bcbmc\b|"
    r"--function|--unwind|--unwinding-assertions|"
    r"-DMLKEM|-DMLK_|(?:^|\s)-I\S*|"
    r"poly\.c|compress\.c|harness",
    re.IGNORECASE,
)

hits = []
for _, rel, path in selected:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        continue

    for line_no, line in enumerate(text.splitlines(), start=1):
        if command_re.search(line):
            hits.append(f"{rel}:{line_no}:{line}")

(discovery / "BUILD_AND_CBMC_COMMAND_HITS.txt").write_text(
    "\n".join(hits) + ("\n" if hits else ""),
    encoding="utf-8",
)

print(f"BATCH5_TOTAL_FILE_COUNT={len(all_files)}")
print(f"BATCH5_RELEVANT_CANDIDATE_COUNT={len(candidates)}")
print(f"BATCH5_SELECTED_FILE_COUNT={len(selected_inventory)}")
print(f"BATCH5_OMITTED_CANDIDATE_COUNT={len(omitted_inventory)}")
print(f"BUILD_COMMAND_HIT_COUNT={len(hits)}")
print("RANKED_SELECTION_STATUS=PASS")
PY

{
    echo "=== BATCH5 DIRECTORY TREE ==="
    find "$B5" -maxdepth 5 -printf '%y %m %s %p\n' | sort
} > "$CAPTURE/03_DISCOVERY/BATCH5_TREE_MAXDEPTH5.txt"

{
    echo "=== TOOL VERSION CAPTURE ==="
    echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    for tool in cbmc goto-cc goto-clang goto-instrument gcc clang python3; do
        echo
        echo "TOOL=$tool"

        if command -v "$tool" >/dev/null 2>&1; then
            echo "AVAILABLE=YES"
            echo "PATH=$(command -v "$tool")"
            "$tool" --version 2>&1 | sed -n '1,5p' || true
        else
            echo "AVAILABLE=NO"
        fi
    done
} > "$CAPTURE/03_DISCOVERY/TOOL_VERSIONS.txt"

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

python3 - "$CAPTURE" "$FAILED_CAPTURE" <<'PY'
import datetime
import hashlib
import json
import sys
from pathlib import Path

capture = Path(sys.argv[1])
failed_capture = Path(sys.argv[2])

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

files = sorted(
    path for path in capture.rglob("*")
    if path.is_file()
    and path.name not in {"CAPTURE_MANIFEST.json", "CAPTURE_SHA256.txt"}
)

manifest = {
    "schema": "sub-t6-b6.3-b6.4-exact-input-capture-v2",
    "status": "CAPTURED_NOT_FROZEN",
    "created_utc": datetime.datetime.now(
        datetime.timezone.utc
    ).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
    "failed_attempt_preserved": failed_capture.exists(),
    "failed_attempt_path": str(failed_capture),
    "purpose": (
        "Capture exact prior successful harness/build conventions and "
        "authoritative SUB-T6 controls before harness construction."
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
    if path.is_file() and path.name != "CAPTURE_SHA256.txt"
)

(capture / "CAPTURE_SHA256.txt").write_text(
    "".join(f"{sha256(path)}  {path}\n" for path in hash_targets),
    encoding="utf-8",
)

print(f"CAPTURE_FILE_COUNT={len(hash_targets)}")
print(
    "FAILED_ATTEMPT_PRESERVED="
    + str(failed_capture.exists()).upper()
)
print("CAPTURE_MANIFEST_STATUS=PASS")
PY

python3 -m json.tool "$CAPTURE/CAPTURE_MANIFEST.json" >/dev/null
python3 -m json.tool \
  "$CAPTURE/03_DISCOVERY/BATCH5_FULL_FILE_INVENTORY.json" >/dev/null
python3 -m json.tool \
  "$CAPTURE/03_DISCOVERY/BATCH5_SELECTED_INVENTORY.json" >/dev/null

tar -C "$HFREEZE" \
  -czf "$TAR" \
  "$(basename "$CAPTURE")"

echo
echo "--- Capture summary ---"
python3 - \
  "$CAPTURE/CAPTURE_MANIFEST.json" \
  "$CAPTURE/03_DISCOVERY/BATCH5_SELECTED_INVENTORY.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    manifest = json.load(handle)

with open(sys.argv[2], encoding="utf-8") as handle:
    selection = json.load(handle)

print("CAPTURE_SCHEMA=" + manifest["schema"])
print("CAPTURE_STATUS=" + manifest["status"])
print("CAPTURE_FILE_COUNT=" + str(manifest["file_count"]))
print(
    "FAILED_ATTEMPT_PRESERVED="
    + str(manifest["failed_attempt_preserved"]).upper()
)
print(
    "BATCH5_RELEVANT_CANDIDATE_COUNT="
    + str(selection["candidate_count"])
)
print(
    "BATCH5_SELECTED_FILE_COUNT="
    + str(selection["selected_file_count"])
)
print(
    "BATCH5_OMITTED_CANDIDATE_COUNT="
    + str(selection["omitted_candidate_count"])
)

for key, value in manifest["execution_state"].items():
    print(key.upper() + "=" + str(value).upper())
PY

echo
echo "--- Archive ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$TAR"
sha256sum "$TAR"

echo
echo "B63_B64_FAILED_ATTEMPT_PRESERVED=YES"
echo "B63_B64_RANKED_CAPTURE=PASS"
echo "B63_B64_HARNESS_CONSTRUCTED=NO"
echo "B63_B64_GOTO_CONSTRUCTED=NO"
echo "B63_B64_CBMC_EXECUTED=NO"
echo "B63_B64_PRODUCTION_MODIFIED=NO"
echo "B63_B64_BATCH5_MODIFIED=NO"
echo "B63_B64_RESULTS_OBSERVED=NO"
echo "B63_B64_UPLOAD_REQUIRED=YES"
echo "B63_B64_STATUS=PASS"
