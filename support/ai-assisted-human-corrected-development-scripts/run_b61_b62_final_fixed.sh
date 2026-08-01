#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
SRC="$ROOT/source/mlkem/src"
BIND="$B6/01_CALLCHAIN_BINDING"
ASSUME="$B6/02_ASSUMPTION_AUDIT"
PREREG="$B6/00_PREREGISTRATION/SUB_T6_B6_0_PREREGISTRATION.json"

echo "=== FINAL COMBINED B6.1 + B6.2 FIXED-SOURCE BINDING ==="
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "ROOT=$ROOT"
echo "BIND=$BIND"
echo "ASSUME=$ASSUME"

test -d "$SRC"
test -d "$BIND"
test -d "$ASSUME"
test -f "$PREREG"

python3 -m json.tool "$PREREG" >/dev/null
grep -F '"status": "FROZEN"' "$PREREG" >/dev/null

if [ -e "$BIND/B6_1_2_COMBINED_FREEZE_MANIFEST.json" ]; then
    echo "COMPLETED_FREEZE_ALREADY_EXISTS=YES"
    exit 1
fi

# Preserve any root-level partial outputs from the two failed combined scripts.
FAILED3="$BIND/FAILED_ATTEMPT_3_WRONG_CONTRACT_FILE"
mkdir -p "$FAILED3"

find "$BIND" -maxdepth 1 -type f \
  \( -name 'B6_1_*' -o -name 'B6_2_*' \) \
  -print0 |
while IFS= read -r -d '' file; do
    mv "$file" "$FAILED3/"
done

find "$ASSUME" -maxdepth 1 -type f \
  \( -name 'B6_1_*' -o -name 'B6_2_*' \) \
  -print0 |
while IFS= read -r -d '' file; do
    mv "$file" "$FAILED3/"
done

cat > "$FAILED3/FAILURE_REASON.txt" <<'EOF'
The second recovery script searched for mlk_poly_decompress_dv in compress.h.
The exact source inspection established that the macro, inline function,
contract and implementation are in poly_k.h at lines 143-174, with the
canonical-output postcondition at line 165. The failed script stopped before
CBMC, GOTO construction, harness construction or proof-result production.
This was a wrong-file parser error, not a source, contract or theorem failure.
EOF

INDCPA="$SRC/indcpa.c"
POLY_C="$SRC/poly.c"
POLY_H="$SRC/poly.h"
COMPRESS_C="$SRC/compress.c"
COMPRESS_H="$SRC/compress.h"
PARAMS="$SRC/params.h"
POLY_K_C="$SRC/poly_k.c"
POLY_K_H="$SRC/poly_k.h"

for file in \
  "$INDCPA" "$POLY_C" "$POLY_H" "$COMPRESS_C" \
  "$COMPRESS_H" "$PARAMS" "$POLY_K_C" "$POLY_K_H"
do
    test -f "$file"
done

# Exact immutable source-hash verification.
check_hash()
{
    local file="$1"
    local expected="$2"
    local actual
    actual="$(sha256sum "$file" | awk '{print $1}')"

    if [ "$actual" != "$expected" ]; then
        echo "SOURCE_HASH_MISMATCH=$file"
        echo "EXPECTED=$expected"
        echo "ACTUAL=$actual"
        exit 1
    fi
}

check_hash "$INDCPA" \
  "ffc9cd09fb9a5926c8540b52181b064e7ae46b3d117e10ca51ac0d0ca940f6bd"
check_hash "$POLY_C" \
  "f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
check_hash "$POLY_H" \
  "f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
check_hash "$COMPRESS_C" \
  "9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
check_hash "$COMPRESS_H" \
  "0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"
check_hash "$PARAMS" \
  "450fe3e0e50496921920473ae4321660f178c23d51f1453f3c537ee63c4158cb"
check_hash "$POLY_K_C" \
  "7dea24a0591b0fb033f7a8be214d687fbde11541c274a114ac3067af12b87c32"
check_hash "$POLY_K_H" \
  "09bdfd4a19a9cb495832a78d0f099a6c949c40014472b33fb54d66bb56e660e0"

# Exact source anchors: no symbol-discovery regex.
grep -nF '#define mlk_poly_decompress_dv MLK_NAMESPACE_K(poly_decompress_dv)' \
  "$POLY_K_H" | grep -F '143:' >/dev/null

grep -nF 'static MLK_INLINE void mlk_poly_decompress_dv(' \
  "$POLY_K_H" | grep -F '159:' >/dev/null

grep -nF 'ensures(array_bound(r->coeffs, 0, MLKEM_N, 0, MLKEM_Q)))' \
  "$POLY_K_H" | grep -F '165:' >/dev/null

grep -nF 'mlk_poly_decompress_dv(v, c + MLKEM_POLYVECCOMPRESSEDBYTES_DU);' \
  "$INDCPA" | grep -F '151:' >/dev/null

grep -nF 'mlk_poly_invntt_tomont(sb);' \
  "$INDCPA" | grep -F '623:' >/dev/null
grep -nF 'mlk_poly_sub(v, sb);' \
  "$INDCPA" | grep -F '625:' >/dev/null
grep -nF 'mlk_poly_reduce(v);' \
  "$INDCPA" | grep -F '626:' >/dev/null
grep -nF 'mlk_poly_tomsg(m, v);' \
  "$INDCPA" | grep -F '628:' >/dev/null

SOURCE_HASHES="$BIND/B6_1_SOURCE_HASHES.txt"
EXTRACT="$BIND/B6_1_CONTRACT_EXTRACTION.txt"
BIND_JSON="$BIND/B6_1_BINDING.json"
BIND_MD="$BIND/B6_1_BINDING.md"
AUDIT_JSON="$ASSUME/B6_2_ASSUMPTION_AUDIT.json"
AUDIT_MD="$ASSUME/B6_2_ASSUMPTION_AUDIT.md"
MANIFEST="$BIND/B6_1_2_COMBINED_FREEZE_MANIFEST.json"
FINAL_HASHES="$BIND/B6_1_2_FINAL_SHA256.txt"

for output in \
  "$SOURCE_HASHES" "$EXTRACT" "$BIND_JSON" "$BIND_MD" \
  "$AUDIT_JSON" "$AUDIT_MD" "$MANIFEST" "$FINAL_HASHES"
do
    if [ -e "$output" ]; then
        echo "REFUSING_TO_OVERWRITE=$output"
        exit 1
    fi
done

{
    sha256sum \
      "$INDCPA" "$POLY_C" "$POLY_H" "$COMPRESS_C" \
      "$COMPRESS_H" "$PARAMS" "$POLY_K_C" "$POLY_K_H"
} > "$SOURCE_HASHES"

print_range()
{
    local label="$1"
    local file="$2"
    local start="$3"
    local end="$4"

    echo
    echo "========================================================================"
    echo "SECTION=$label"
    echo "FILE=$file"
    echo "RANGE=${start}-${end}"
    echo "FILE_SHA256=$(sha256sum "$file" | awk '{print $1}')"
    echo "CONTENT_BEGIN"
    nl -ba "$file" | sed -n "${start},${end}p"
    echo "CONTENT_END"
}

{
    echo "B6.1 SUB-T6 CALL-CHAIN AND CONTRACT EXTRACTION"
    echo "CREATED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "STATUS=FROZEN"
    echo "V_PRODUCER_HELPER=mlk_poly_decompress_dv"
    echo "V_PRODUCER_CONTRACT_FILE=$POLY_K_H"
    echo "V_PRODUCER_CONTRACT_RANGE=143-165"

    print_range \
      "PARAMETERS_MLKEM_N_AND_Q" \
      "$PARAMS" 18 26

    print_range \
      "POLYNOMIAL_TYPE_AND_INVNTT_BOUND" \
      "$POLY_H" 20 48

    print_range \
      "V_PRODUCER_NATIVE_CONTRACT" \
      "$POLY_K_H" 143 174

    print_range \
      "UNPACK_CIPHERTEXT_CALLS_V_PRODUCER" \
      "$INDCPA" 137 152

    print_range \
      "MLK_INDCPA_DEC_ALLOCATIONS_AND_PRODUCTION_SLICE" \
      "$INDCPA" 596 632

    print_range \
      "MLK_POLY_REDUCE_CONTRACT" \
      "$POLY_H" 145 181

    print_range \
      "MLK_POLY_SUB_CONTRACT" \
      "$POLY_H" 210 235

    print_range \
      "MLK_POLY_INVNTT_TOMONT_CONTRACT" \
      "$POLY_H" 255 292

    print_range \
      "MLK_POLY_TOMSG_CONTRACT" \
      "$COMPRESS_H" 568 600

    print_range \
      "MLK_POLY_SUB_IMPLEMENTATION" \
      "$POLY_C" 238 262

    print_range \
      "MLK_POLY_REDUCE_IMPLEMENTATION" \
      "$POLY_C" 175 225

    print_range \
      "MLK_POLY_TOMSG_IMPLEMENTATION" \
      "$COMPRESS_C" 708 731
} > "$EXTRACT"

python3 - \
  "$PREREG" "$SRC" "$SOURCE_HASHES" "$EXTRACT" \
  "$BIND_JSON" "$BIND_MD" "$AUDIT_JSON" "$AUDIT_MD" \
  "$MANIFEST" "$FINAL_HASHES" "$B6" <<'PY'
import datetime
import hashlib
import json
import sys
from pathlib import Path

(
    prereg_path,
    src_path,
    source_hashes_path,
    extract_path,
    bind_json_path,
    bind_md_path,
    audit_json_path,
    audit_md_path,
    manifest_path,
    final_hashes_path,
    b6_path,
) = map(Path, sys.argv[1:])

with prereg_path.open(encoding="utf-8") as handle:
    prereg = json.load(handle)

if prereg.get("status") != "FROZEN":
    raise SystemExit("PREREGISTRATION_NOT_FROZEN")

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

freeze_time = datetime.datetime.now(
    datetime.timezone.utc
).replace(microsecond=0).isoformat().replace("+00:00", "Z")

MLKEM_N = 256
MLKEM_Q = 3329
MLK_INVNTT_BOUND = 8 * MLKEM_Q

v_min = 0
v_max = MLKEM_Q - 1
sb_min = -(MLK_INVNTT_BOUND - 1)
sb_max = MLK_INVNTT_BOUND - 1
derived_min = v_min - sb_max
derived_max = v_max - sb_min
int16_min = -32768
int16_max = 32767

assert derived_min == -26631
assert derived_max == 29959
assert int16_min <= derived_min
assert derived_max <= int16_max

binding = {
    "schema": "sub-t6-b6.1-binding-v3",
    "status": "FROZEN",
    "freeze_time_utc": freeze_time,
    "authoritative_source_root": str(src_path),
    "source_repository_type": "frozen-cleanroom-copy-not-git-working-tree",
    "source_symlink_count": 0,
    "v_upstream_interface": {
        "wrapper": "mlk_unpack_ciphertext",
        "producer_helper": "mlk_poly_decompress_dv",
        "contract_file": str(src_path / "poly_k.h"),
        "macro_line": 143,
        "function_line": 159,
        "postcondition_line": 165,
        "contract_range": [143, 165],
        "bound": "0 <= v[i] < MLKEM_Q",
        "binding_method": "exact fixed source file, line and hash binding",
    },
    "sb_upstream_interface": {
        "producer": "mlk_poly_invntt_tomont",
        "bound": "abs(sb[i]) < MLK_INVNTT_BOUND",
        "MLK_INVNTT_BOUND": MLK_INVNTT_BOUND,
    },
    "production_calls": {
        "mlk_poly_invntt_tomont": 623,
        "mlk_poly_sub": 625,
        "mlk_poly_reduce": 626,
        "mlk_poly_tomsg": 628,
    },
    "failed_attempts_preserved": [
        "FAILED_ATTEMPT_1_LITERAL_PATTERN",
        "FAILED_ATTEMPT_2_DECLARATION_LOOKUP",
        "FAILED_ATTEMPT_3_WRONG_CONTRACT_FILE",
    ],
    "execution_state": {
        "cbmc_executed": False,
        "goto_constructed": False,
        "harness_constructed": False,
        "production_modified": False,
        "batch5_modified": False,
        "results_observed": False,
    },
}

bind_json_path.write_text(
    json.dumps(binding, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

bind_md_path.write_text(
    f"""# SUB-T6 B6.1 Call-Chain Binding

Status: `FROZEN`

## Exact upstream producer for v

`mlk_unpack_ciphertext` calls:

```c
mlk_poly_decompress_dv(v, c + MLKEM_POLYVECCOMPRESSEDBYTES_DU);
```

The authoritative native contract is bound to:

```text
File: {src_path / "poly_k.h"}
Macro line: 143
Function line: 159
Canonical-output postcondition line: 165
SHA-256: 09bdfd4a19a9cb495832a78d0f099a6c949c40014472b33fb54d66bb56e660e0
```

The postcondition establishes:

```text
0 <= v[i] < MLKEM_Q
```

## Exact production slice

```c
mlk_poly_invntt_tomont(sb);  /* indcpa.c:623 */
mlk_poly_sub(v, sb);          /* indcpa.c:625 */
mlk_poly_reduce(v);           /* indcpa.c:626 */
mlk_poly_tomsg(m, v);         /* indcpa.c:628 */
```

All three earlier failed parser/search attempts are retained. They were not
CBMC failures and produced no proof results.
""",
    encoding="utf-8",
)

audit = {
    "schema": "sub-t6-b6.2-assumption-audit-v3",
    "status": "FROZEN",
    "freeze_time_utc": freeze_time,
    "MLKEM_N": MLKEM_N,
    "MLKEM_Q": MLKEM_Q,
    "MLK_INVNTT_BOUND": MLK_INVNTT_BOUND,
    "v_interval": [v_min, v_max],
    "sb_interval": [sb_min, sb_max],
    "derived_subtraction_interval": [derived_min, derived_max],
    "int16_interval": [int16_min, int16_max],
    "int16_containment": True,
    "representability_is_assumed": False,
    "representability_is_derived": True,
    "conclusion_shaped_assumptions_permitted": False,
    "execution_state": {
        "cbmc_executed": False,
        "goto_constructed": False,
        "harness_constructed": False,
    },
}

audit_json_path.write_text(
    json.dumps(audit, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

audit_md_path.write_text(
    f"""# SUB-T6 B6.2 Arithmetic and Assumption Audit

Status: `FROZEN`

```text
0 <= v[i] <= {v_max}
{sb_min} <= sb[i] <= {sb_max}

minimum = {v_min} - {sb_max} = {derived_min}
maximum = {v_max} - ({sb_min}) = {derived_max}

[{derived_min}, {derived_max}]
is contained in
[{int16_min}, {int16_max}]
```

Representability is derived from the exact upstream contracts. It is not an
independent assumption.
""",
    encoding="utf-8",
)

manifest_files = [
    source_hashes_path,
    extract_path,
    bind_json_path,
    bind_md_path,
    audit_json_path,
    audit_md_path,
]

for failure_dir_name in [
    "FAILED_ATTEMPT_1_LITERAL_PATTERN",
    "FAILED_ATTEMPT_2_DECLARATION_LOOKUP",
    "FAILED_ATTEMPT_3_WRONG_CONTRACT_FILE",
]:
    failure_dir = b6_path / "01_CALLCHAIN_BINDING" / failure_dir_name
    if failure_dir.exists():
        manifest_files.extend(
            sorted(path for path in failure_dir.rglob("*") if path.is_file())
        )

manifest = {
    "schema": "sub-t6-b6.1-b6.2-combined-freeze-v3",
    "freeze_status": "FROZEN",
    "freeze_time_utc": freeze_time,
    "b6_1_status": "PASS",
    "b6_2_status": "PASS",
    "v_producer_helper": "mlk_poly_decompress_dv",
    "v_contract_file": str(src_path / "poly_k.h"),
    "v_contract_postcondition_line": 165,
    "derived_min": derived_min,
    "derived_max": derived_max,
    "int16_containment": "PASS",
    "failed_attempt_count": 3,
    "files": {
        str(path.relative_to(b6_path)): sha256(path)
        for path in manifest_files
    },
    "execution_state": {
        "cbmc_executed": False,
        "goto_constructed": False,
        "harness_constructed": False,
        "production_modified": False,
        "batch5_modified": False,
        "results_observed": False,
    },
}

manifest_path.write_text(
    json.dumps(manifest, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

final_files = manifest_files + [manifest_path]
final_hashes_path.write_text(
    "".join(f"{sha256(path)}  {path}\n" for path in final_files),
    encoding="utf-8",
)

print("V_PRODUCER_HELPER=mlk_poly_decompress_dv")
print("V_CONTRACT_FILE=poly_k.h")
print("V_CONTRACT_POSTCONDITION_LINE=165")
print(f"DERIVED_MIN={derived_min}")
print(f"DERIVED_MAX={derived_max}")
print("INT16_CONTAINMENT=PASS")
print("FAILED_ATTEMPT_COUNT=3")
print("B61_STATUS=PASS")
print("B62_STATUS=PASS")
PY

python3 -m json.tool "$BIND_JSON" >/dev/null
python3 -m json.tool "$AUDIT_JSON" >/dev/null
python3 -m json.tool "$MANIFEST" >/dev/null

find "$BIND" "$ASSUME" -type f -exec chmod 444 {} +
find "$BIND" "$ASSUME" -type d -exec chmod 555 {} +

echo
echo "--- Combined freeze summary ---"

python3 - "$MANIFEST" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    d = json.load(handle)

print("MANIFEST_SCHEMA=" + d["schema"])
print("FREEZE_STATUS=" + d["freeze_status"])
print("B61_STATUS=" + d["b6_1_status"])
print("B62_STATUS=" + d["b6_2_status"])
print("V_PRODUCER_HELPER=" + d["v_producer_helper"])
print("V_CONTRACT_FILE=" + d["v_contract_file"])
print(
    "V_CONTRACT_POSTCONDITION_LINE="
    + str(d["v_contract_postcondition_line"])
)
print("DERIVED_MIN=" + str(d["derived_min"]))
print("DERIVED_MAX=" + str(d["derived_max"]))
print("INT16_CONTAINMENT=" + d["int16_containment"])
print("FAILED_ATTEMPT_COUNT=" + str(d["failed_attempt_count"]))

for key, value in d["execution_state"].items():
    print(key.upper() + "=" + str(value).upper())
PY

echo
echo "--- Frozen permissions ---"

stat -c 'MODE=%a TYPE=%F FILE=%n' \
  "$BIND" \
  "$ASSUME" \
  "$BIND_JSON" \
  "$BIND_MD" \
  "$AUDIT_JSON" \
  "$AUDIT_MD" \
  "$MANIFEST" \
  "$FINAL_HASHES"

echo
echo "B61_SOURCE_AND_CONTRACT_BINDING=PASS"
echo "B62_ARITHMETIC_AND_ASSUMPTION_AUDIT=PASS"
echo "B61_B62_FILES_READ_ONLY=YES"
echo "B61_B62_DIRECTORIES_READ_ONLY=YES"
echo "B61_B62_CBMC_EXECUTED=NO"
echo "B61_B62_GOTO_CONSTRUCTED=NO"
echo "B61_B62_HARNESS_CONSTRUCTED=NO"
echo "B61_B62_PRODUCTION_MODIFIED=NO"
echo "B61_B62_BATCH5_MODIFIED=NO"
echo "B61_B62_STATUS=PASS"
