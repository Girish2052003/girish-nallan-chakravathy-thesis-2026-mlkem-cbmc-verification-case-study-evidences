#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
SRC="$ROOT/source/mlkem/src"
BIND="$B6/01_CALLCHAIN_BINDING"
ASSUME="$B6/02_ASSUMPTION_AUDIT"
PREREG="$B6/00_PREREGISTRATION/SUB_T6_B6_0_PREREGISTRATION.json"

echo "=== COMBINED B6.1 + B6.2 ROBUST RECOVERY V2 ==="
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

# Refuse to overwrite a genuinely completed freeze.
if [ -e "$BIND/B6_1_2_COMBINED_FREEZE_MANIFEST.json" ]; then
  echo "COMPLETED_FREEZE_ALREADY_EXISTS=YES"
  exit 1
fi

# Preserve any partial files from the declaration-lookup failure.
FAILED2="$BIND/FAILED_ATTEMPT_2_DECLARATION_LOOKUP"
mkdir -p "$FAILED2"

for f in \
  "$BIND/B6_1_SOURCE_HASHES.txt" \
  "$BIND/B6_1_CONTRACT_EXTRACTION.txt" \
  "$BIND/B6_1_BINDING.json" \
  "$BIND/B6_1_BINDING.md" \
  "$ASSUME/B6_2_ASSUMPTION_AUDIT.json" \
  "$ASSUME/B6_2_ASSUMPTION_AUDIT.md" \
  "$BIND/B6_1_2_FINAL_SHA256.txt"
do
  if [ -e "$f" ]; then
    mv "$f" "$FAILED2/"
  fi
done

cat > "$FAILED2/FAILURE_REASON.txt" <<'EOF'
The first combined B6.1+B6.2 script correctly discovered the actual helper
mlk_poly_decompress_dv, but its parser required a literal declaration matching
"void mlk_poly_decompress_dv(". The source exposes the symbol using formatting
or macro/contract syntax not matched by that narrow regular expression.
The script stopped before CBMC, GOTO construction, harness construction, or
proof-result production. This is a parser failure, not a source or theorem
failure.
EOF

python3 - "$ROOT" "$B6" <<'PY'
import datetime
import hashlib
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
b6 = Path(sys.argv[2])
src = root / "source/mlkem/src"
bind = b6 / "01_CALLCHAIN_BINDING"
assume_dir = b6 / "02_ASSUMPTION_AUDIT"
prereg_path = b6 / "00_PREREGISTRATION/SUB_T6_B6_0_PREREGISTRATION.json"

freeze_time = datetime.datetime.now(
    datetime.timezone.utc
).replace(microsecond=0).isoformat().replace("+00:00", "Z")

with prereg_path.open(encoding="utf-8") as handle:
    prereg = json.load(handle)

if prereg.get("status") != "FROZEN":
    raise SystemExit("PREREGISTRATION_NOT_FROZEN")

outputs = {
    "source_hashes": bind / "B6_1_SOURCE_HASHES.txt",
    "extraction": bind / "B6_1_CONTRACT_EXTRACTION.txt",
    "binding_json": bind / "B6_1_BINDING.json",
    "binding_md": bind / "B6_1_BINDING.md",
    "audit_json": assume_dir / "B6_2_ASSUMPTION_AUDIT.json",
    "audit_md": assume_dir / "B6_2_ASSUMPTION_AUDIT.md",
    "manifest": bind / "B6_1_2_COMBINED_FREEZE_MANIFEST.json",
    "hashes": bind / "B6_1_2_FINAL_SHA256.txt",
}

for path in outputs.values():
    if path.exists():
        raise SystemExit(f"REFUSING_TO_OVERWRITE={path}")

source_files = {
    "indcpa.c": src / "indcpa.c",
    "poly.c": src / "poly.c",
    "poly.h": src / "poly.h",
    "compress.c": src / "compress.c",
    "compress.h": src / "compress.h",
    "params.h": src / "params.h",
    "poly_k.c": src / "poly_k.c",
    "poly_k.h": src / "poly_k.h",
}

expected_hashes = {
    "indcpa.c": "ffc9cd09fb9a5926c8540b52181b064e7ae46b3d117e10ca51ac0d0ca940f6bd",
    "poly.c": "f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722",
    "poly.h": "f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef",
    "compress.c": "9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad",
    "compress.h": "0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd",
    "params.h": "450fe3e0e50496921920473ae4321660f178c23d51f1453f3c537ee63c4158cb",
    "poly_k.c": "7dea24a0591b0fb033f7a8be214d687fbde11541c274a114ac3067af12b87c32",
    "poly_k.h": "09bdfd4a19a9cb495832a78d0f099a6c949c40014472b33fb54d66bb56e660e0",
}

def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()

for name, path in source_files.items():
    if not path.is_file():
        raise SystemExit(f"SOURCE_FILE_MISSING={path}")
    actual = sha256(path)
    if actual != expected_hashes[name]:
        raise SystemExit(
            f"SOURCE_HASH_MISMATCH={name} "
            f"EXPECTED={expected_hashes[name]} ACTUAL={actual}"
        )

outputs["source_hashes"].write_text(
    "".join(
        f"{expected_hashes[name]}  {path}\n"
        for name, path in source_files.items()
    ),
    encoding="utf-8",
)

texts = {
    name: path.read_text(encoding="utf-8", errors="replace")
    for name, path in source_files.items()
}
lines = {name: text.splitlines() for name, text in texts.items()}

def normalize(text: str) -> str:
    return re.sub(r"\s+", " ", text)

def find_line(file_lines, needle, start, end):
    for line_no in range(start, end + 1):
        if needle in file_lines[line_no - 1]:
            return line_no
    raise SystemExit(f"REQUIRED_LINE_NOT_FOUND={needle}")

def range_text(file_lines, start, end):
    start = max(1, start)
    end = min(len(file_lines), end)
    return "\n".join(
        f"{line_no:6d}  {file_lines[line_no - 1]}"
        for line_no in range(start, end + 1)
    )

def symbol_occurrences(file_lines, symbol):
    return [
        line_no
        for line_no, line in enumerate(file_lines, start=1)
        if symbol in line
    ]

def find_contract_window(
    file_lines,
    symbol,
    required_terms,
    before=45,
    after=30,
):
    occurrences = symbol_occurrences(file_lines, symbol)
    if not occurrences:
        raise SystemExit(f"SYMBOL_NOT_FOUND={symbol}")

    for line_no in occurrences:
        start = max(1, line_no - before)
        end = min(len(file_lines), line_no + after)
        raw = "\n".join(file_lines[start - 1:end])
        compact = normalize(raw)

        if all(term in compact for term in required_terms):
            return line_no, start, end, raw

    raise SystemExit(
        f"CONTRACT_WINDOW_NOT_FOUND={symbol} "
        f"OCCURRENCES={occurrences}"
    )

# Discover the actual helper used to produce v.
unpack_region = "\n".join(lines["indcpa.c"][134:183])

helper_match = re.search(
    r"\b(mlk_[A-Za-z0-9_]*decompress[A-Za-z0-9_]*)\s*\(\s*v(?:\s*,|\s*\))",
    unpack_region,
)
if helper_match is None:
    raise SystemExit("V_DECOMPRESSION_HELPER_NOT_FOUND")

v_helper = helper_match.group(1)

helper_line, helper_start, helper_end, helper_contract = find_contract_window(
    lines["compress.h"],
    v_helper,
    ["ensures(array_bound(", "MLKEM_N", "MLKEM_Q"],
    before=60,
    after=40,
)

sub_line, sub_start, sub_end, sub_contract = find_contract_window(
    lines["poly.h"],
    "mlk_poly_sub",
    ["INT16_MAX", "INT16_MIN", "old(*r)", "memory_no_alias"],
    before=35,
    after=25,
)

reduce_line, reduce_start, reduce_end, reduce_contract = find_contract_window(
    lines["poly.h"],
    "mlk_poly_reduce",
    ["ensures(array_bound(", "MLKEM_N", "MLKEM_Q"],
    before=40,
    after=25,
)

invntt_line, invntt_start, invntt_end, invntt_contract = find_contract_window(
    lines["poly.h"],
    "mlk_poly_invntt_tomont",
    ["ensures(array_abs_bound(", "MLK_INVNTT_BOUND"],
    before=40,
    after=25,
)

tomsg_line, tomsg_start, tomsg_end, tomsg_contract = find_contract_window(
    lines["compress.h"],
    "mlk_poly_tomsg",
    ["requires(array_bound(", "MLKEM_N", "MLKEM_Q"],
    before=40,
    after=30,
)

call_invntt = find_line(
    lines["indcpa.c"],
    "mlk_poly_invntt_tomont(sb);",
    590,
    635,
)
call_sub = find_line(
    lines["indcpa.c"],
    "mlk_poly_sub(v, sb);",
    590,
    635,
)
call_reduce = find_line(
    lines["indcpa.c"],
    "mlk_poly_reduce(v);",
    590,
    635,
)
call_tomsg = find_line(
    lines["indcpa.c"],
    "mlk_poly_tomsg(m, v);",
    590,
    635,
)

sub_norm = normalize(sub_contract)
reduce_norm = normalize(reduce_contract)
invntt_norm = normalize(invntt_contract)
tomsg_norm = normalize(tomsg_contract)
helper_norm = normalize(helper_contract)

checks = {
    "source_tree_has_no_symlinks":
        not any(path.is_symlink() for path in src.rglob("*")),
    "parameter_MLKEM_N_256":
        "#define MLKEM_N 256" in texts["params.h"],
    "parameter_MLKEM_Q_3329":
        "#define MLKEM_Q 3329" in texts["params.h"],
    "poly_layout_int16_256":
        "int16_t coeffs[MLKEM_N]" in texts["poly.h"],
    "invntt_bound_definition":
        "#define MLK_INVNTT_BOUND (8 * MLKEM_Q)" in texts["poly.h"],
    "unpack_ciphertext_symbol":
        "static void mlk_unpack_ciphertext" in texts["indcpa.c"],
    "v_decompression_helper_call":
        v_helper in unpack_region,
    "v_helper_canonical_postcondition":
        "ensures(array_bound(" in helper_norm
        and "MLKEM_N" in helper_norm
        and "MLKEM_Q" in helper_norm,
    "sub_object_separation_contract":
        "memory_no_alias" in sub_norm,
    "sub_destination_assigns_contract":
        "assigns(object_whole(r))" in sub_norm,
    "sub_upper_representability_contract":
        "(int32_t) r->coeffs[k0] - b->coeffs[k0] <= INT16_MAX"
        in sub_norm,
    "sub_lower_representability_contract":
        "(int32_t) r->coeffs[k1] - b->coeffs[k1] >= INT16_MIN"
        in sub_norm,
    "sub_exactness_postcondition":
        "r->coeffs[k] == old(*r).coeffs[k] - b->coeffs[k]"
        in sub_norm,
    "invntt_absolute_bound_postcondition":
        "ensures(array_abs_bound(" in invntt_norm
        and "MLK_INVNTT_BOUND" in invntt_norm,
    "reduce_canonical_postcondition":
        "ensures(array_bound(" in reduce_norm
        and "MLKEM_N" in reduce_norm
        and "MLKEM_Q" in reduce_norm,
    "tomsg_canonical_precondition":
        "requires(array_bound(" in tomsg_norm
        and "MLKEM_N" in tomsg_norm
        and "MLKEM_Q" in tomsg_norm,
    "caller_allocates_v":
        "MLK_ALLOC(v, mlk_poly, 1, context);" in texts["indcpa.c"],
    "caller_allocates_sb":
        "MLK_ALLOC(sb, mlk_poly, 1, context);" in texts["indcpa.c"],
    "production_call_order":
        call_invntt < call_sub < call_reduce < call_tomsg,
}

failed = [name for name, passed in checks.items() if not passed]
if failed:
    raise SystemExit("SEMANTIC_CHECKS_FAILED=" + ",".join(failed))

MLKEM_Q = 3329
MLK_INVNTT_BOUND = 8 * MLKEM_Q
v_min, v_max = 0, MLKEM_Q - 1
sb_min, sb_max = -(MLK_INVNTT_BOUND - 1), MLK_INVNTT_BOUND - 1
derived_min = v_min - sb_max
derived_max = v_max - sb_min
int16_min, int16_max = -32768, 32767

if [derived_min, derived_max] != [-26631, 29959]:
    raise SystemExit("DERIVED_INTERVAL_MISMATCH")
if not (int16_min <= derived_min and derived_max <= int16_max):
    raise SystemExit("INT16_CONTAINMENT_FAILURE")

sections = [
    ("PARAMETERS_MLKEM_N_AND_Q", "params.h", 18, 26),
    ("POLYNOMIAL_TYPE_AND_BOUND", "poly.h", 20, 48),
    ("UNPACK_CIPHERTEXT_AND_V_PRODUCER_CALL", "indcpa.c", 135, 183),
    ("MLK_INDCPA_DEC_ALLOCATIONS_AND_CALLSITE", "indcpa.c", 596, 632),
    ("V_DECOMPRESSION_HELPER_CONTRACT", "compress.h", helper_start, helper_end),
    ("MLK_POLY_REDUCE_CONTRACT", "poly.h", reduce_start, reduce_end),
    ("MLK_POLY_SUB_CONTRACT", "poly.h", sub_start, sub_end),
    ("MLK_POLY_INVNTT_CONTRACT", "poly.h", invntt_start, invntt_end),
    ("MLK_POLY_TOMSG_CONTRACT", "compress.h", tomsg_start, tomsg_end),
    ("MLK_POLY_SUB_IMPLEMENTATION", "poly.c", 238, 262),
    ("MLK_POLY_REDUCE_IMPLEMENTATION", "poly.c", 175, 225),
    ("MLK_POLY_INVNTT_IMPLEMENTATION", "poly.c", 510, 573),
    ("MLK_POLY_TOMSG_IMPLEMENTATION", "compress.c", 708, 731),
]

extract = [
    "B6.1 SUB-T6 CALL-CHAIN AND CONTRACT EXTRACTION",
    f"CREATED_UTC={freeze_time}",
    "STATUS=FROZEN",
    f"V_PRODUCER_HELPER={v_helper}",
    f"V_HELPER_SYMBOL_LINE={helper_line}",
    f"SUB_SYMBOL_LINE={sub_line}",
    f"REDUCE_SYMBOL_LINE={reduce_line}",
    f"INVNTT_SYMBOL_LINE={invntt_line}",
    f"TOMSG_SYMBOL_LINE={tomsg_line}",
    "",
]

for label, file_name, start, end in sections:
    path = source_files[file_name]
    extract.extend([
        "=" * 72,
        f"SECTION={label}",
        f"FILE={path}",
        f"RANGE={start}-{end}",
        f"FILE_SHA256={expected_hashes[file_name]}",
        "CONTENT_BEGIN",
        range_text(lines[file_name], start, end),
        "CONTENT_END",
        "",
    ])

outputs["extraction"].write_text(
    "\n".join(extract) + "\n",
    encoding="utf-8",
)

binding = {
    "schema": "sub-t6-b6.1-binding-v2",
    "status": "FROZEN",
    "freeze_time_utc": freeze_time,
    "authoritative_source_root": str(src),
    "source_repository_type": "frozen-cleanroom-copy-not-git-working-tree",
    "source_symlink_count": 0,
    "source_hashes": expected_hashes,
    "v_upstream_interface": {
        "wrapper": "mlk_unpack_ciphertext",
        "producer_helper": v_helper,
        "contract_file": str(source_files["compress.h"]),
        "contract_symbol_line": helper_line,
        "contract_range": [helper_start, helper_end],
        "bound": "0 <= v[i] < MLKEM_Q",
        "binding_method":
            "actual helper call plus semantic contract-window matching",
    },
    "sb_upstream_interface": {
        "producer": "mlk_poly_invntt_tomont",
        "bound": "abs(sb[i]) < MLK_INVNTT_BOUND",
        "MLK_INVNTT_BOUND": MLK_INVNTT_BOUND,
    },
    "production_calls": {
        "mlk_poly_invntt_tomont": call_invntt,
        "mlk_poly_sub": call_sub,
        "mlk_poly_reduce": call_reduce,
        "mlk_poly_tomsg": call_tomsg,
    },
    "semantic_checks": checks,
    "failed_attempts_preserved": [
        "FAILED_ATTEMPT_1_LITERAL_PATTERN",
        "FAILED_ATTEMPT_2_DECLARATION_LOOKUP",
    ],
    "cbmc_executed": False,
    "goto_constructed": False,
    "harness_constructed": False,
    "production_modified": False,
    "batch5_modified": False,
}

outputs["binding_json"].write_text(
    json.dumps(binding, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

outputs["binding_md"].write_text(
    f"""# SUB-T6 B6.1 Call-Chain Binding

Status: `FROZEN`

Authoritative source root:

`{src}`

Bound production sequence:

```c
mlk_poly_invntt_tomont(sb);  /* line {call_invntt} */
mlk_poly_sub(v, sb);          /* line {call_sub} */
mlk_poly_reduce(v);           /* line {call_reduce} */
mlk_poly_tomsg(m, v);         /* line {call_tomsg} */
```

`mlk_unpack_ciphertext` produces `v` through `{v_helper}`. Its native
contract window establishes canonical output:

```text
0 <= v[i] < MLKEM_Q
```

The native `mlk_poly_invntt_tomont` contract establishes:

```text
abs(sb[i]) < MLK_INVNTT_BOUND
MLK_INVNTT_BOUND = 26632
```

The two earlier parser/pattern failures are retained as evidence. Neither was
a CBMC or source failure.

No CBMC, GOTO construction, harness construction, production modification,
or Batch-5 modification occurred in B6.1.
""",
    encoding="utf-8",
)

audit = {
    "schema": "sub-t6-b6.2-assumption-audit-v2",
    "status": "FROZEN",
    "freeze_time_utc": freeze_time,
    "v_interval": [v_min, v_max],
    "sb_interval": [sb_min, sb_max],
    "derived_subtraction_interval": [derived_min, derived_max],
    "int16_interval": [int16_min, int16_max],
    "int16_containment": True,
    "representability_is_assumed": False,
    "representability_is_derived": True,
    "conclusion_shaped_assumptions_permitted": False,
    "cbmc_executed": False,
    "goto_constructed": False,
    "harness_constructed": False,
}

outputs["audit_json"].write_text(
    json.dumps(audit, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

outputs["audit_md"].write_text(
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

Representability is derived, not assumed.

No CBMC, GOTO construction, or harness construction occurred in B6.2.
""",
    encoding="utf-8",
)

manifest_files = [
    outputs["source_hashes"],
    outputs["extraction"],
    outputs["binding_json"],
    outputs["binding_md"],
    outputs["audit_json"],
    outputs["audit_md"],
]

for failure_dir_name in [
    "FAILED_ATTEMPT_1_LITERAL_PATTERN",
    "FAILED_ATTEMPT_2_DECLARATION_LOOKUP",
]:
    failure_dir = bind / failure_dir_name
    if failure_dir.exists():
        manifest_files.extend(
            sorted(path for path in failure_dir.rglob("*") if path.is_file())
        )

manifest = {
    "schema": "sub-t6-b6.1-b6.2-combined-freeze-v2",
    "freeze_status": "FROZEN",
    "freeze_time_utc": freeze_time,
    "b6_1_status": "PASS",
    "b6_2_status": "PASS",
    "v_producer_helper": v_helper,
    "semantic_check_count": len(checks),
    "semantic_failed_check_count": 0,
    "derived_min": derived_min,
    "derived_max": derived_max,
    "int16_containment": "PASS",
    "failed_attempts_preserved": True,
    "files": {
        str(path.relative_to(b6)): sha256(path)
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

outputs["manifest"].write_text(
    json.dumps(manifest, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)

final_files = manifest_files + [outputs["manifest"]]
outputs["hashes"].write_text(
    "".join(f"{sha256(path)}  {path}\n" for path in final_files),
    encoding="utf-8",
)

print(f"V_PRODUCER_HELPER={v_helper}")
print(f"V_HELPER_SYMBOL_LINE={helper_line}")
print(f"V_HELPER_CONTRACT_RANGE={helper_start}-{helper_end}")
print(f"CALL_INVNTT_LINE={call_invntt}")
print(f"CALL_SUB_LINE={call_sub}")
print(f"CALL_REDUCE_LINE={call_reduce}")
print(f"CALL_TOMSG_LINE={call_tomsg}")
print(f"SEMANTIC_CHECK_COUNT={len(checks)}")
print("SEMANTIC_FAILED_CHECK_COUNT=0")
print(f"DERIVED_MIN={derived_min}")
print(f"DERIVED_MAX={derived_max}")
print("INT16_CONTAINMENT=PASS")
print("FAILED_ATTEMPTS_PRESERVED=YES")
print("B61_STATUS=PASS")
print("B62_STATUS=PASS")
PY

python3 -m json.tool "$BIND/B6_1_BINDING.json" >/dev/null
python3 -m json.tool "$ASSUME/B6_2_ASSUMPTION_AUDIT.json" >/dev/null
python3 -m json.tool "$BIND/B6_1_2_COMBINED_FREEZE_MANIFEST.json" >/dev/null

find "$BIND" "$ASSUME" -type f -exec chmod 444 {} +
find "$BIND" "$ASSUME" -type d -exec chmod 555 {} +

echo
echo "--- Combined freeze summary ---"
python3 - "$BIND/B6_1_2_COMBINED_FREEZE_MANIFEST.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    d = json.load(handle)

print("MANIFEST_SCHEMA=" + d["schema"])
print("FREEZE_STATUS=" + d["freeze_status"])
print("B61_STATUS=" + d["b6_1_status"])
print("B62_STATUS=" + d["b6_2_status"])
print("V_PRODUCER_HELPER=" + d["v_producer_helper"])
print("SEMANTIC_CHECK_COUNT=" + str(d["semantic_check_count"]))
print("SEMANTIC_FAILED_CHECK_COUNT=" + str(d["semantic_failed_check_count"]))
print("DERIVED_MIN=" + str(d["derived_min"]))
print("DERIVED_MAX=" + str(d["derived_max"]))
print("INT16_CONTAINMENT=" + d["int16_containment"])
print(
    "FAILED_ATTEMPTS_PRESERVED="
    + str(d["failed_attempts_preserved"]).upper()
)
for key, value in d["execution_state"].items():
    print(key.upper() + "=" + str(value).upper())
PY

echo
echo "--- Frozen permissions ---"
stat -c 'MODE=%a TYPE=%F FILE=%n' \
  "$BIND" \
  "$ASSUME" \
  "$BIND/B6_1_BINDING.json" \
  "$BIND/B6_1_BINDING.md" \
  "$ASSUME/B6_2_ASSUMPTION_AUDIT.json" \
  "$ASSUME/B6_2_ASSUMPTION_AUDIT.md" \
  "$BIND/B6_1_2_COMBINED_FREEZE_MANIFEST.json" \
  "$BIND/B6_1_2_FINAL_SHA256.txt"

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
