#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# SUB-00K
#
# Combined mutation execution, per-mutant audit, and frozen verdict for the
# accepted SUB-00J ML-KEM-768 mutation preflight.
#
# This runner executes the three already-built and validated mutant GOTO
# models sequentially. Each mutant is independently revalidated immediately
# before execution. All three runs are attempted even if one result is
# unexpected. Evidence is packaged on every exit path.
#
# Expected scientific outcome:
#   M1_ADD_INSTEAD_OF_SUB      -> main.assertion.8 FAILURE
#   M2_SKIP_COEFFICIENT_255    -> main.assertion.8 FAILURE at coefficient 255
#   M3_ORACLE_PLUS_ONE         -> main.assertion.8 FAILURE
#
# A crash, timeout, malformed JSON, missing central property, only unrelated
# failures, an inadmissible witness, or an unwinding failure does not count as
# a killed mutant.
###############################################################################

BASE="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
PREFLIGHT="${BASE}/SUB00J_MUTATION_PREFLIGHT_PRAGMA_SCOPED_MLKEM768"
PREFLIGHT_PACKAGE="${BASE}/SUB00J_MUTATION_PREFLIGHT_PRAGMA_SCOPED_MLKEM768.tar.gz"

EXPECTED_PREFLIGHT_PACKAGE_SHA256="c4dc21bd092f45737470aa05bc2b4a99b475c53d8cc731f22fb389c2fc6b4ac6"
EXPECTED_PREFLIGHT_MANIFEST_SHA256="0cb2671a8358e630658dc7da141f93ef575d05e8f990d1520338c45eaca491fb"
EXPECTED_PREFLIGHT_STATUS_SHA256="43f1628dd14626ea7ff87d79a28bd92118e844822d49dbb11efb1fb3e6e34938"
EXPECTED_MUTATION_AUDIT_SHA256="440fc52ee7da0377e4bcc2da0421081d4810ecd80aaf2db42a10f0a7b93a76a3"
EXPECTED_MUTATION_PROTOCOL_SHA256="c6e5f96a2dd284673bc1e55c56ccf551736acd18f881e4ed7b024c13341f2e29"

OUT="${BASE}/SUB00K_COMBINED_MUTATION_EXECUTION_MLKEM768_RUN1"
PACKAGE="${BASE}/SUB00K_COMBINED_MUTATION_EXECUTION_MLKEM768_RUN1.tar.gz"
PACKAGE_HASH="${PACKAGE}.sha256"
MANIFEST="${OUT}/SUB00K_ARTIFACT_MANIFEST.sha256"
OVERALL_VERDICT="${OUT}/MUTATION_VERDICT.txt"

SCRIPT_PATH="$(readlink -f "$0")"
STEP="initialization"
PACKAGED=0

fail()
{
  echo "ERROR: $*" >&2
  return 1
}

hash_of()
{
  sha256sum "$1" | awk '{print $1}'
}

verify_hash()
{
  local expected="$1"
  local file="$2"
  local actual

  test -f "${file}" || {
    echo "Missing required file: ${file}" >&2
    return 1
  }

  actual="$(hash_of "${file}")"

  if test "${actual}" != "${expected}"
  then
    echo "Integrity mismatch" >&2
    echo "Expected: ${expected}" >&2
    echo "Actual:   ${actual}" >&2
    echo "File:     ${file}" >&2
    return 1
  fi
}

write_command()
{
  local file="$1"
  shift

  {
    printf 'COMMAND:'
    printf ' %q' "$@"
    printf '\n'
  } >"${file}"
}

package_evidence()
{
  local final_rc="$1"

  if test "${PACKAGED}" -eq 1
  then
    return
  fi
  PACKAGED=1

  if test -d "${OUT}"
  then
    {
      echo "FINAL_WRAPPER_EXIT_CODE=${final_rc}"
      echo "LAST_STEP=${STEP}"
    } >"${OUT}/wrapper_status.txt"

    (
      cd "${OUT}"
      find . -type f \
        ! -name "$(basename "${MANIFEST}")" \
        -print0 |
        LC_ALL=C sort -z |
        xargs -0 -r sha256sum
    ) >"${MANIFEST}"

    rm -f "${PACKAGE}" "${PACKAGE_HASH}"

    tar \
      --sort=name \
      --mtime='UTC 1970-01-01' \
      --owner=0 \
      --group=0 \
      --numeric-owner \
      -C "${BASE}" \
      -cf - \
      "$(basename "${OUT}")" |
      gzip -n >"${PACKAGE}"

    sha256sum "${PACKAGE}" >"${PACKAGE_HASH}"

    echo
    echo "============================================================"
    echo "SUB-00K COMBINED MUTATION EVIDENCE PACKAGED"
    echo "============================================================"
    echo "Last step: ${STEP}"
    echo

    if test -f "${OVERALL_VERDICT}"
    then
      cat "${OVERALL_VERDICT}"
      echo
    fi

    echo "Upload:"
    echo "1. ${PACKAGE}"
    echo "2. ${PACKAGE_HASH}"
    cat "${PACKAGE_HASH}"
  fi
}

on_exit()
{
  local rc="$?"
  trap - EXIT
  package_evidence "${rc}"
  exit "${rc}"
}
trap on_exit EXIT

for tool in \
  sha256sum goto-instrument cbmc timeout tar gzip python3 readlink cmp
do
  command -v "${tool}" >/dev/null 2>&1 ||
    fail "required tool unavailable: ${tool}"
done

test -x /usr/bin/time || fail "/usr/bin/time is unavailable"
test -f "${SCRIPT_PATH}" || fail "unable to resolve executing runner"
test -d "${BASE}" || fail "campaign directory missing: ${BASE}"
test -d "${PREFLIGHT}" || fail "accepted SUB-00J directory missing: ${PREFLIGHT}"

test ! -e "${OUT}" || fail "versioned output already exists: ${OUT}"
test ! -e "${PACKAGE}" || fail "versioned package already exists: ${PACKAGE}"
test ! -e "${PACKAGE_HASH}" || fail "versioned sidecar already exists"

mkdir -p "${OUT}/parent" "${OUT}/mutants"

STEP="record environment"
{
  date -u
  uname -a
  echo
  goto-instrument --version
  cbmc --version
} >"${OUT}/environment.txt" 2>&1

STEP="verify accepted SUB-00J package and metadata"
verify_hash "${EXPECTED_PREFLIGHT_PACKAGE_SHA256}" "${PREFLIGHT_PACKAGE}"
verify_hash \
  "${EXPECTED_PREFLIGHT_MANIFEST_SHA256}" \
  "${PREFLIGHT}/SUB00J_ARTIFACT_MANIFEST.sha256"
verify_hash \
  "${EXPECTED_PREFLIGHT_STATUS_SHA256}" \
  "${PREFLIGHT}/PREFLIGHT_STATUS.txt"
verify_hash \
  "${EXPECTED_MUTATION_AUDIT_SHA256}" \
  "${PREFLIGHT}/MUTATION_AUDIT.json"
verify_hash \
  "${EXPECTED_MUTATION_PROTOCOL_SHA256}" \
  "${PREFLIGHT}/SUB00J_MUTATION_PROTOCOL.md"

(
  cd "${PREFLIGHT}"
  sha256sum --check SUB00J_ARTIFACT_MANIFEST.sha256
) >"${OUT}/parent/sub00j_manifest_check.txt" 2>&1

grep -Fxq "PREFLIGHT_FINAL_EXIT_CODE=0" \
  "${PREFLIGHT}/PREFLIGHT_STATUS.txt" ||
  fail "SUB-00J preflight did not exit zero"

grep -Fxq "PREFLIGHT_VERDICT=PASS" \
  "${PREFLIGHT}/PREFLIGHT_STATUS.txt" ||
  fail "SUB-00J preflight verdict is not PASS"

grep -Fxq "THEOREM_OR_MUTANT_SOLVER_EXECUTED=NO" \
  "${PREFLIGHT}/PREFLIGHT_STATUS.txt" ||
  fail "SUB-00J preflight unexpectedly records solver execution"

# Every recorded SUB-00J command must have exited zero.
while IFS= read -r -d '' exit_file
do
  grep -Fxq "0" "${exit_file}" ||
    fail "SUB-00J command failed: ${exit_file}"
done < <(find "${PREFLIGHT}/build" -name '*.exit_code' -print0 | LC_ALL=C sort -z)

cp -a "${PREFLIGHT}/PREFLIGHT_STATUS.txt" "${OUT}/parent/"
cp -a "${PREFLIGHT}/SUB00J_ARTIFACT_MANIFEST.sha256" "${OUT}/parent/"
cp -a "${PREFLIGHT}/MUTATION_AUDIT.json" "${OUT}/parent/"
cp -a "${PREFLIGHT}/SUB00J_MUTATION_PROTOCOL.md" "${OUT}/parent/"
cp -a "${SCRIPT_PATH}" "${OUT}/executed_runner.sh"

{
  echo "Accepted SUB-00J package:"
  sha256sum "${PREFLIGHT_PACKAGE}"
  echo
  echo "Executing runner:"
  sha256sum "${SCRIPT_PATH}"
} >"${OUT}/parent_and_runner_hashes.txt"

run_mutant()
{
  local mutant_id="$1"
  local expected_model_sha="$2"
  local expected_inventory_sha="$3"
  local expected_property_count="$4"
  local namespace="$5"

  local preflight_dir="${PREFLIGHT}/build/${mutant_id}"
  local model="${preflight_dir}/${mutant_id}.goto"
  local inventory="${preflight_dir}/property_inventory.txt"
  local frozen_command="${PREFLIGHT}/future_expected_failure_commands/${mutant_id}_EXPECTED_FAILURE_COMMAND.txt"
  local result_dir="${OUT}/mutants/${mutant_id}"

  local json_file="${result_dir}/cbmc_result.json"
  local stderr_file="${result_dir}/cbmc_stderr.txt"
  local resource_file="${result_dir}/resource_usage.txt"
  local exit_file="${result_dir}/cbmc_exit_code.txt"
  local command_file="${result_dir}/cbmc_command.txt"
  local summary_file="${result_dir}/independent_summary.json"
  local classification_file="${result_dir}/CLASSIFICATION.txt"

  local unwindset="main.0:257,main.1:257,main.2:257,main.3:257,mlk_barrett_reduce.0:2,${namespace}_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2"

  mkdir -p "${result_dir}/frozen_inputs"

  {
    echo "MUTANT_ID=${mutant_id}"
    echo "EXPECTED_MODEL_SHA256=${expected_model_sha}"
    echo "EXPECTED_PROPERTY_INVENTORY_SHA256=${expected_inventory_sha}"
    echo "EXPECTED_PROPERTY_COUNT=${expected_property_count}"
    echo "EXPECTED_CENTRAL_PROPERTY=main.assertion.8"
    echo "NAMESPACE=${namespace}"
    echo "EXACT_UNWINDSET=${unwindset}"
  } >"${result_dir}/RUN_IDENTITY.txt"

  STEP="verify ${mutant_id} frozen inputs"

  verify_hash "${expected_model_sha}" "${model}" || {
    echo "MODEL_INTEGRITY=FAIL" >"${classification_file}"
    return 0
  }

  verify_hash "${expected_inventory_sha}" "${inventory}" || {
    echo "PROPERTY_INVENTORY_INTEGRITY=FAIL" >"${classification_file}"
    return 0
  }

  grep -Fq \
    "SUB_T1_SEMANTIC: output must equal independent canonical oracle" \
    "${inventory}" || {
      echo "CENTRAL_PROPERTY_INVENTORY=ABSENT" >"${classification_file}"
      return 0
    }

  grep -q '^Property main.assertion.8:$' "${inventory}" || {
    echo "CENTRAL_PROPERTY_ID=ABSENT" >"${classification_file}"
    return 0
  }

  cp -a "${model}" "${result_dir}/frozen_inputs/"
  cp -a "${inventory}" "${result_dir}/frozen_inputs/"
  cp -a "${preflight_dir}/MODEL_RECORD.txt" "${result_dir}/frozen_inputs/"
  cp -a "${frozen_command}" "${result_dir}/frozen_inputs/"

  STEP="final validation ${mutant_id}"
  set +e
  goto-instrument \
    --validate-goto-binary \
    "${model}" \
    >"${result_dir}/final_validation.txt" \
    2>&1
  local validate_rc="$?"
  set -e

  printf '%s\n' "${validate_rc}" \
    >"${result_dir}/final_validation_exit_code.txt"

  if test "${validate_rc}" -ne 0
  then
    {
      echo "MUTANT_CLASSIFICATION=NOT_KILLED_VALIDATION_FAILED"
      echo "FINAL_VALIDATION_EXIT_CODE=${validate_rc}"
    } >"${classification_file}"
    return 0
  fi

  local command=(
    cbmc
    "${model}"
    --function main
    --object-bits 8
    --bounds-check
    --pointer-check
    --pointer-overflow-check
    --pointer-primitive-check
    --signed-overflow-check
    --unsigned-overflow-check
    --conversion-check
    --undefined-shift-check
    --div-by-zero-check
    --unwinding-assertions
    --unwindset "${unwindset}"
    --slice-formula
    --sat-solver minisat2
    --trace
    --json-ui
  )

  write_command "${command_file}" "${command[@]}"

  if ! cmp -s "${command_file}" "${frozen_command}"
  then
    diff -u "${frozen_command}" "${command_file}" \
      >"${result_dir}/command_diff.txt" || true
    {
      echo "MUTANT_CLASSIFICATION=NOT_KILLED_COMMAND_MISMATCH"
      echo "FROZEN_COMMAND_MATCH=NO"
    } >"${classification_file}"
    return 0
  fi

  echo "FROZEN_COMMAND_MATCH=YES" \
    >"${result_dir}/command_match.txt"

  STEP="execute ${mutant_id}"
  set +e
  /usr/bin/time -v \
    -o "${resource_file}" \
    timeout \
    --signal=TERM \
    --kill-after=60s \
    21600s \
    "${command[@]}" \
    >"${json_file}" \
    2>"${stderr_file}"
  local cbmc_rc="$?"
  set -e

  printf '%s\n' "${cbmc_rc}" >"${exit_file}"

  # Confirm the model remained byte-identical after execution.
  verify_hash "${expected_model_sha}" "${model}" || {
    {
      echo "MUTANT_CLASSIFICATION=NOT_KILLED_MODEL_CHANGED_AFTER_RUN"
      echo "RAW_CBMC_EXIT_CODE=${cbmc_rc}"
    } >"${classification_file}"
    return 0
  }

  STEP="audit ${mutant_id} result"
  python3 - \
    "${mutant_id}" \
    "${expected_property_count}" \
    "${json_file}" \
    "${exit_file}" \
    "${summary_file}" \
    "${classification_file}" <<'PY'
import json
import re
import sys
from pathlib import Path

mutant_id = sys.argv[1]
expected_property_count = int(sys.argv[2])
json_path = Path(sys.argv[3])
exit_path = Path(sys.argv[4])
summary_path = Path(sys.argv[5])
classification_path = Path(sys.argv[6])

raw_exit = int(exit_path.read_text(encoding="utf-8").strip())

def parse_int(value):
    if isinstance(value, int):
        return value
    text = str(value).strip()
    match = re.fullmatch(r"(-?\d+)(?:[uUlL]+)?", text)
    if not match:
        raise ValueError(f"unsupported integer value: {value!r}")
    return int(match.group(1))

parse_error = ""
status_values = []
results = []

try:
    data = json.loads(json_path.read_text(encoding="utf-8"))

    if not isinstance(data, list):
        raise TypeError("top-level JSON value is not a list")

    for item in data:
        if not isinstance(item, dict):
            continue
        if "cProverStatus" in item:
            status_values.append(str(item["cProverStatus"]))
        if isinstance(item.get("result"), list):
            results.extend(
                result for result in item["result"]
                if isinstance(result, dict)
            )
except Exception as exc:
    parse_error = f"{type(exc).__name__}: {exc}"

central = next(
    (
        result for result in results
        if result.get("property") == "main.assertion.8"
    ),
    None,
)

failures = [
    result for result in results
    if str(result.get("status", "")).upper() == "FAILURE"
]

unwinding_failures = [
    result
    for result in failures
    if (
        "unwind" in str(result.get("property", "")).lower()
        or "unwinding" in str(result.get("description", "")).lower()
    )
]

trace = central.get("trace", []) if isinstance(central, dict) else []

def extract_array(name):
    values = [None] * 256
    pattern = re.compile(
        rf"^{re.escape(name)}\.coeffs\[(\d+)l\]$"
    )

    for step in trace:
        if step.get("stepType") != "assignment":
            continue
        match = pattern.fullmatch(str(step.get("lhs", "")))
        if match:
            index = int(match.group(1))
            values[index] = parse_int(
                step.get("value", {}).get("data")
            )

    return values

def extract_last_scalar_l(index):
    pattern = re.compile(rf"^L\.coeffs\[{index}l\]$")
    found = None

    for step in trace:
        if step.get("stepType") != "assignment":
            continue
        if pattern.fullmatch(str(step.get("lhs", ""))):
            found = parse_int(step.get("value", {}).get("data"))

    return found

a_values = []
b_values = []
arrays_complete = False
all_differences_representable = False
minimum_difference = None
maximum_difference = None
witness_error = ""

if trace:
    try:
        a_values = extract_array("A0")
        b_values = extract_array("B0")
        arrays_complete = all(
            value is not None for value in a_values + b_values
        )

        if arrays_complete:
            differences = [
                a_value - b_value
                for a_value, b_value in zip(a_values, b_values)
            ]
            all_differences_representable = all(
                -32768 <= difference <= 32767
                for difference in differences
            )
            minimum_difference = min(differences)
            maximum_difference = max(differences)
    except Exception as exc:
        witness_error = f"{type(exc).__name__}: {exc}"

m2_index_255_confirmed = None
m2_details = {}

if mutant_id == "M2_SKIP_COEFFICIENT_255" and arrays_complete:
    a255 = a_values[255]
    b255 = b_values[255]
    expected255 = (a255 - b255 + 10 * 3329) % 3329
    actual255 = extract_last_scalar_l(255)

    m2_index_255_confirmed = (
        actual255 is not None and actual255 != expected255
    )

    m2_details = {
        "a255": a255,
        "b255": b255,
        "difference255": a255 - b255,
        "expected_canonical255": expected255,
        "actual_final_l255": actual255,
        "mismatch_at_255": m2_index_255_confirmed,
    }

central_status = (
    str(central.get("status", "")).upper()
    if isinstance(central, dict)
    else "MISSING"
)

central_description = (
    str(central.get("description", ""))
    if isinstance(central, dict)
    else ""
)

status_failure_present = any(
    status.lower() == "failure" for status in status_values
)

killed = (
    parse_error == ""
    and raw_exit == 10
    and len(results) == expected_property_count
    and status_failure_present
    and central_status == "FAILURE"
    and (
        "output must equal independent canonical oracle"
        in central_description
    )
    and len(trace) > 0
    and arrays_complete
    and all_differences_representable
    and len(unwinding_failures) == 0
    and (
        mutant_id != "M2_SKIP_COEFFICIENT_255"
        or m2_index_255_confirmed is True
    )
)

classification = (
    "KILLED_BY_INTENDED_SEMANTIC_ASSERTION"
    if killed
    else "NOT_KILLED_OR_NOT_YET_CLASSIFIABLE"
)

summary = {
    "mutant_id": mutant_id,
    "classification": classification,
    "raw_cbmc_exit_code": raw_exit,
    "json_parse_error": parse_error or None,
    "cprover_statuses": status_values,
    "expected_property_count": expected_property_count,
    "actual_property_count": len(results),
    "total_failures": len(failures),
    "failing_properties": [
        {
            "property": result.get("property"),
            "description": result.get("description"),
        }
        for result in failures
    ],
    "central_property": {
        "property": (
            central.get("property")
            if isinstance(central, dict) else None
        ),
        "status": central_status,
        "description": central_description,
        "trace_steps": len(trace),
    },
    "unwinding_failure_count": len(unwinding_failures),
    "witness": {
        "error": witness_error or None,
        "input_arrays_complete": arrays_complete,
        "all_direct_differences_int16_representable":
            all_differences_representable,
        "minimum_direct_difference": minimum_difference,
        "maximum_direct_difference": maximum_difference,
    },
    "m2_coefficient_255": m2_details or None,
}

summary_path.write_text(
    json.dumps(summary, indent=2) + "\n",
    encoding="utf-8",
)

classification_path.write_text(
    "\n".join(
        [
            f"MUTANT_ID={mutant_id}",
            f"MUTANT_CLASSIFICATION={classification}",
            f"RAW_CBMC_EXIT_CODE={raw_exit}",
            f"ACTUAL_PROPERTY_COUNT={len(results)}",
            f"CENTRAL_PROPERTY_STATUS={central_status}",
            f"ADMISSIBLE_WITNESS={'YES' if arrays_complete and all_differences_representable else 'NO'}",
            f"UNWINDING_FAILURES={len(unwinding_failures)}",
            (
                "COEFFICIENT_255_MISMATCH="
                + (
                    "YES"
                    if m2_index_255_confirmed is True
                    else "NO"
                    if m2_index_255_confirmed is False
                    else "NOT_APPLICABLE"
                )
            ),
        ]
    )
    + "\n",
    encoding="utf-8",
)
PY

  return 0
}

STEP="execute and audit M1"
run_mutant \
  "M1_ADD_INSTEAD_OF_SUB" \
  "4d21f9651557fedbae44a21f67f6c4c551a0e0792bc0e6ea7bbee1cc88fe7a31" \
  "9c28a695a7434b3f11b84eb1070241bcdc49993d2fae744a83763198e7dfd0f1" \
  "361" \
  "mlk_sub00j_add"

STEP="execute and audit M2"
run_mutant \
  "M2_SKIP_COEFFICIENT_255" \
  "af2986a09db0bba4ee775913acbea542bb6fc9189f62e95c6aa0dd59d8aff2ae" \
  "73a8474750ac3860568c5b956cd7b0984407434290d07b9ec8bca9bbd784dd90" \
  "362" \
  "mlk_sub00j_skip"

STEP="execute and audit M3"
run_mutant \
  "M3_ORACLE_PLUS_ONE" \
  "b5b6099730af2e85b11bb9da0ae95248d08dc151d2b4b9776b56417b6e3380c9" \
  "bec3f20ce48777f23ab75d85e616de9dedeedfd9d5dfd8ce689661f35b0906cd" \
  "362" \
  "mlk_sub00j_oracle"

STEP="freeze combined mutation verdict"
python3 - "${OUT}/mutants" "${OVERALL_VERDICT}" <<'PY'
import sys
from pathlib import Path

mutants_root = Path(sys.argv[1])
verdict_path = Path(sys.argv[2])

mutant_ids = [
    "M1_ADD_INSTEAD_OF_SUB",
    "M2_SKIP_COEFFICIENT_255",
    "M3_ORACLE_PLUS_ONE",
]

killed = []
not_killed = []

for mutant_id in mutant_ids:
    classification_path = (
        mutants_root / mutant_id / "CLASSIFICATION.txt"
    )

    if not classification_path.exists():
        not_killed.append(f"{mutant_id}: MISSING_CLASSIFICATION")
        continue

    text = classification_path.read_text(encoding="utf-8")

    if (
        "MUTANT_CLASSIFICATION="
        "KILLED_BY_INTENDED_SEMANTIC_ASSERTION"
        in text
    ):
        killed.append(mutant_id)
    else:
        first_line = next(
            (
                line for line in text.splitlines()
                if "CLASSIFICATION" in line
                or line.endswith("=FAIL")
                or line.endswith("=ABSENT")
            ),
            "UNCLASSIFIED",
        )
        not_killed.append(f"{mutant_id}: {first_line}")

overall = (
    "PASS_3_OF_3_KILLED"
    if len(killed) == 3
    else "NOT_PASSED"
)

lines = [
    f"MUTATION_BATCH_VERDICT={overall}",
    "MUTANTS_GENERATED=3",
    "MUTANTS_EXECUTED_OR_ATTEMPTED=3",
    f"MUTANTS_KILLED_BY_INTENDED_ASSERTION={len(killed)}",
    f"MUTATION_SENSITIVITY_PERCENT={100 if len(killed) == 3 else round(len(killed) * 100 / 3, 2)}",
    "SUB_T1_RESULT_MODIFIED=NO",
    "NOVELTY_ESTABLISHED_BY_MUTATION_TESTING=NO",
    "",
    "KILLED_MUTANTS:",
]

lines.extend(killed or ["NONE"])
lines.append("")
lines.append("NOT_KILLED_OR_UNCLASSIFIED:")
lines.extend(not_killed or ["NONE"])

verdict_path.write_text(
    "\n".join(lines) + "\n",
    encoding="utf-8",
)
PY

if grep -Fxq \
  "MUTATION_BATCH_VERDICT=PASS_3_OF_3_KILLED" \
  "${OVERALL_VERDICT}"
then
  FINAL_RC=0
else
  FINAL_RC=10
fi

STEP="SUB-00K combined mutation batch complete"
exit "${FINAL_RC}"
