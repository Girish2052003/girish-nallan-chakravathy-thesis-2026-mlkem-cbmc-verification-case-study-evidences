#!/usr/bin/env bash
set -euo pipefail

DIR="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
SOURCE_STAGE="${DIR}/sub00e_r1_goto_model_inspection_v2"

PARENT_PACKET="${DIR}/SUB00E_R1_GOTO_MODEL_INSPECTION_PACKET.txt"
PARENT_PACKET_SIDECAR="${PARENT_PACKET}.sha256"
ARTIFACT_MANIFEST="${DIR}/SUB00E_R1_GOTO_ARTIFACT_MANIFEST.sha256"
ADAPTER_MANIFEST="${DIR}/SUB00E_R1_BUILD_ADAPTER_MANIFEST.sha256"

EXPECTED_PARENT_PACKET_SHA256="becc00cb6280f405548cc535f38875bb3e476901cbb11392fc2ed38b8b3262d5"
EXPECTED_ARTIFACT_MANIFEST_SHA256="cf0baf1e79da927fd055019eecd0d2d7cd6d084a5f8d7c957ac8b5691b66e5e9"
EXPECTED_ADAPTER_MANIFEST_SHA256="d7b574ab6ad03d7cbddf162158d81f3b3a4e63bccb0be24a6dedee86a4dddf34"

OUT_DIR="${DIR}/sub00e_r2_validation_reachability_audit_v1"
PACKET="${DIR}/SUB00E_R2_VALIDATION_REACHABILITY_AUDIT_PACKET.txt"
PACKET_HASH="${PACKET}.sha256"
AUDIT_MANIFEST="${DIR}/SUB00E_R2_VALIDATION_REACHABILITY_AUDIT_MANIFEST.sha256"

HARNESSES=(
  "sub_t1_semantic_harness"
  "sub_t2_relational_harness"
  "sub_cov_reachability_harness"
  "sub_boundary_valid_extremes_harness"
  "sub_boundary_invalid_lower_harness"
  "sub_boundary_invalid_upper_harness"
)

fail()
{
  echo "ERROR: $*" >&2
  exit 1
}

run_capture()
{
  local output="$1"
  shift

  set +e
  "$@" >"${output}" 2>&1
  local rc=$?
  set -e

  printf '%s\n' "${rc}" >"${output}.exit_code"
}

write_command()
{
  local output="$1"
  shift

  {
    printf 'COMMAND:'
    printf ' %q' "$@"
    printf '\n'
  } >"${output}"
}

command -v sha256sum >/dev/null 2>&1 || fail "sha256sum is unavailable"
command -v goto-instrument >/dev/null 2>&1 || fail "goto-instrument is unavailable"

test -d "${DIR}" || fail "campaign directory is missing: ${DIR}"
test -d "${SOURCE_STAGE}" || fail "SUB-00E-R1 model directory is missing: ${SOURCE_STAGE}"
test -f "${PARENT_PACKET}" || fail "SUB-00E-R1 packet is missing"
test -f "${PARENT_PACKET_SIDECAR}" || fail "SUB-00E-R1 packet sidecar is missing"
test -f "${ARTIFACT_MANIFEST}" || fail "SUB-00E-R1 artifact manifest is missing"
test -f "${ADAPTER_MANIFEST}" || fail "SUB-00E-R1 adapter manifest is missing"

test ! -e "${OUT_DIR}" || fail "audit directory already exists: ${OUT_DIR}"
test ! -e "${PACKET}" || fail "audit packet already exists: ${PACKET}"
test ! -e "${PACKET_HASH}" || fail "audit packet sidecar already exists: ${PACKET_HASH}"
test ! -e "${AUDIT_MANIFEST}" || fail "audit manifest already exists: ${AUDIT_MANIFEST}"

ACTUAL_PARENT_PACKET_SHA256="$(sha256sum "${PARENT_PACKET}" | awk '{print $1}')"
ACTUAL_ARTIFACT_MANIFEST_SHA256="$(sha256sum "${ARTIFACT_MANIFEST}" | awk '{print $1}')"
ACTUAL_ADAPTER_MANIFEST_SHA256="$(sha256sum "${ADAPTER_MANIFEST}" | awk '{print $1}')"

test "${ACTUAL_PARENT_PACKET_SHA256}" = "${EXPECTED_PARENT_PACKET_SHA256}" || {
  echo "Expected packet: ${EXPECTED_PARENT_PACKET_SHA256}" >&2
  echo "Actual packet:   ${ACTUAL_PARENT_PACKET_SHA256}" >&2
  fail "SUB-00E-R1 packet integrity verification failed"
}

test "${ACTUAL_ARTIFACT_MANIFEST_SHA256}" = "${EXPECTED_ARTIFACT_MANIFEST_SHA256}" || {
  echo "Expected artifact manifest: ${EXPECTED_ARTIFACT_MANIFEST_SHA256}" >&2
  echo "Actual artifact manifest:   ${ACTUAL_ARTIFACT_MANIFEST_SHA256}" >&2
  fail "SUB-00E-R1 artifact-manifest integrity verification failed"
}

test "${ACTUAL_ADAPTER_MANIFEST_SHA256}" = "${EXPECTED_ADAPTER_MANIFEST_SHA256}" || {
  echo "Expected adapter manifest: ${EXPECTED_ADAPTER_MANIFEST_SHA256}" >&2
  echo "Actual adapter manifest:   ${ACTUAL_ADAPTER_MANIFEST_SHA256}" >&2
  fail "SUB-00E-R1 adapter-manifest integrity verification failed"
}

echo "Verifying SUB-00E-R1 packet sidecar..."
(
  cd "${DIR}"
  sha256sum --check "$(basename "${PARENT_PACKET_SIDECAR}")"
)

echo "Verifying the complete SUB-00E-R1 artifact manifest..."
(
  cd "${DIR}"
  sha256sum --check "$(basename "${ARTIFACT_MANIFEST}")"
)

echo "Verifying the fail-closed adapter manifest..."
(
  cd "${DIR}"
  sha256sum --check "$(basename "${ADAPTER_MANIFEST}")"
)

HELP_FILE="$(mktemp)"
trap 'rm -f "${HELP_FILE}"' EXIT

goto-instrument --help >"${HELP_FILE}" 2>&1 || true

for required_option in \
  "--validate-goto-binary" \
  "--reachable-call-graph" \
  "--list-undefined-functions" \
  "--drop-unused-functions" \
  "--show-loops" \
  "--show-properties" \
  "--show-goto-functions"
do
  grep -q -- "${required_option}" "${HELP_FILE}" ||
    fail "goto-instrument does not advertise required option: ${required_option}"
done

mkdir -p "${OUT_DIR}"

VALIDATION_FAILURES=0
SLICE_FAILURES=0
ADAPTER_REACHABILITY_FAILURES=0

for base in "${HARNESSES[@]}"
do
  one_source="${SOURCE_STAGE}/${base}"
  model="${one_source}/${base}_mlkem768.goto"
  one_out="${OUT_DIR}/${base}"
  sliced="${one_out}/${base}_reachable_only.goto"

  test -s "${model}" || fail "source GOTO model is missing or empty: ${model}"
  mkdir -p "${one_out}"

  sha256sum "${model}" >"${one_out}/source_model.sha256"
  stat "${model}" >"${one_out}/source_model.stat.txt"

  VALIDATE_CMD=(
    goto-instrument
    --validate-goto-binary
    "${model}"
  )
  write_command "${one_out}/validate_original.command.txt" "${VALIDATE_CMD[@]}"
  run_capture "${one_out}/validate_original.txt" "${VALIDATE_CMD[@]}"

  validate_rc="$(cat "${one_out}/validate_original.txt.exit_code")"
  if test "${validate_rc}" -ne 0
  then
    VALIDATION_FAILURES=$((VALIDATION_FAILURES + 1))
  fi

  REACHABLE_CMD=(
    goto-instrument
    --reachable-call-graph
    "${model}"
  )
  write_command "${one_out}/reachable_call_graph.command.txt" "${REACHABLE_CMD[@]}"
  run_capture "${one_out}/reachable_call_graph.txt" "${REACHABLE_CMD[@]}"

  reachable_rc="$(cat "${one_out}/reachable_call_graph.txt.exit_code")"
  if test "${reachable_rc}" -ne 0
  then
    VALIDATION_FAILURES=$((VALIDATION_FAILURES + 1))
  fi

  if grep -Eq '(^|[^[:alnum:]_])mlk_zeroize([^[:alnum:]_]|$)' \
      "${one_out}/reachable_call_graph.txt"
  then
    printf '%s\n' "REACHABLE" >"${one_out}/zeroize_reachability.status.txt"
    ADAPTER_REACHABILITY_FAILURES=$((ADAPTER_REACHABILITY_FAILURES + 1))
  else
    printf '%s\n' "NOT_REACHABLE" >"${one_out}/zeroize_reachability.status.txt"
  fi

  UNDEFINED_CMD=(
    goto-instrument
    --list-undefined-functions
    "${model}"
  )
  write_command "${one_out}/undefined_functions.command.txt" "${UNDEFINED_CMD[@]}"
  run_capture "${one_out}/undefined_functions.txt" "${UNDEFINED_CMD[@]}"

  undefined_rc="$(cat "${one_out}/undefined_functions.txt.exit_code")"
  if test "${undefined_rc}" -ne 0
  then
    VALIDATION_FAILURES=$((VALIDATION_FAILURES + 1))
  fi

  DROP_CMD=(
    goto-instrument
    --drop-unused-functions
    "${model}"
    "${sliced}"
  )
  write_command "${one_out}/drop_unused_functions.command.txt" "${DROP_CMD[@]}"
  run_capture "${one_out}/drop_unused_functions.txt" "${DROP_CMD[@]}"

  drop_rc="$(cat "${one_out}/drop_unused_functions.txt.exit_code")"
  if test "${drop_rc}" -ne 0 || test ! -s "${sliced}"
  then
    SLICE_FAILURES=$((SLICE_FAILURES + 1))
    continue
  fi

  sha256sum "${sliced}" >"${one_out}/reachable_only_model.sha256"
  stat "${sliced}" >"${one_out}/reachable_only_model.stat.txt"

  VALIDATE_SLICED_CMD=(
    goto-instrument
    --validate-goto-binary
    "${sliced}"
  )
  write_command "${one_out}/validate_reachable_only.command.txt" \
    "${VALIDATE_SLICED_CMD[@]}"
  run_capture "${one_out}/validate_reachable_only.txt" \
    "${VALIDATE_SLICED_CMD[@]}"

  sliced_validate_rc="$(cat "${one_out}/validate_reachable_only.txt.exit_code")"
  if test "${sliced_validate_rc}" -ne 0
  then
    VALIDATION_FAILURES=$((VALIDATION_FAILURES + 1))
  fi

  SHOW_LOOPS_CMD=(
    goto-instrument
    --show-loops
    "${sliced}"
  )
  write_command "${one_out}/reachable_only_loops.command.txt" \
    "${SHOW_LOOPS_CMD[@]}"
  run_capture "${one_out}/reachable_only_loops.txt" \
    "${SHOW_LOOPS_CMD[@]}"

  SHOW_PROPERTIES_CMD=(
    goto-instrument
    --show-properties
    "${sliced}"
  )
  write_command "${one_out}/reachable_only_properties.command.txt" \
    "${SHOW_PROPERTIES_CMD[@]}"
  run_capture "${one_out}/reachable_only_properties.txt" \
    "${SHOW_PROPERTIES_CMD[@]}"

  SHOW_FUNCTIONS_CMD=(
    goto-instrument
    --show-goto-functions
    "${sliced}"
  )
  write_command "${one_out}/reachable_only_functions.command.txt" \
    "${SHOW_FUNCTIONS_CMD[@]}"
  run_capture "${one_out}/reachable_only_functions.txt" \
    "${SHOW_FUNCTIONS_CMD[@]}"
done

{
  echo "============================================================"
  echo "SUB-00E-R2 VALIDATION AND REACHABILITY AUDIT"
  echo "============================================================"
  echo
  echo "Frozen commit:"
  echo "d9613cf60de3132d32475c102d8c2781d84feb34"
  echo
  echo "Parent SUB-00E-R1 packet SHA-256:"
  echo "${ACTUAL_PARENT_PACKET_SHA256}"
  echo
  echo "Parent SUB-00E-R1 artifact-manifest SHA-256:"
  echo "${ACTUAL_ARTIFACT_MANIFEST_SHA256}"
  echo
  echo "Parent adapter-manifest SHA-256:"
  echo "${ACTUAL_ADAPTER_MANIFEST_SHA256}"
  echo
  echo "Audit time UTC:"
  date -u +%Y-%m-%dT%H:%M:%SZ
  echo
  echo "STATUS:"
  echo "Validation, reachability and reachable-loop inspection only."
  echo "No CBMC theorem proof command was executed."
  echo "No coverage command was executed."
  echo "No production source file was modified."
  echo "No theorem harness was modified."
  echo "No original GOTO model was modified."
  echo "The existing repository poly_sub harness remained unopened."
  echo
  echo "Correct binary-validation failures: ${VALIDATION_FAILURES}"
  echo "Reachable-only model construction failures: ${SLICE_FAILURES}"
  echo "Unexpected reachable mlk_zeroize findings: ${ADAPTER_REACHABILITY_FAILURES}"

  echo
  echo "============================================================"
  echo "WHY THIS AUDIT EXISTS"
  echo "============================================================"
  echo
  echo "SUB-00E-R1 used --validate-goto-model as a standalone action."
  echo "That flag enables additional checks but is not the validation-only action."
  echo "This audit uses --validate-goto-binary, which checks the input GOTO"
  echo "binary and exits."
  echo
  echo "Reachable-only copies are inspection artefacts created with"
  echo "--drop-unused-functions. They do not replace the original frozen"
  echo "models and are not theorem-proof results."

  for base in "${HARNESSES[@]}"
  do
    one_out="${OUT_DIR}/${base}"
    sliced="${one_out}/${base}_reachable_only.goto"

    echo
    echo "============================================================"
    echo "MODEL: ${base}"
    echo "============================================================"

    echo
    echo "Source model SHA-256:"
    cat "${one_out}/source_model.sha256"

    echo
    echo "Correct original-binary validation command:"
    cat "${one_out}/validate_original.command.txt"
    echo "Exit code:"
    cat "${one_out}/validate_original.txt.exit_code"
    echo "Output:"
    cat "${one_out}/validate_original.txt"

    echo
    echo "Reachable call graph command:"
    cat "${one_out}/reachable_call_graph.command.txt"
    echo "Exit code:"
    cat "${one_out}/reachable_call_graph.txt.exit_code"
    echo "Zeroize status:"
    cat "${one_out}/zeroize_reachability.status.txt"
    echo "Reachable call graph:"
    cat "${one_out}/reachable_call_graph.txt"

    echo
    echo "Undefined-function audit command:"
    cat "${one_out}/undefined_functions.command.txt"
    echo "Exit code:"
    cat "${one_out}/undefined_functions.txt.exit_code"
    echo "Undefined functions:"
    cat "${one_out}/undefined_functions.txt"

    echo
    echo "Drop-unused-functions command:"
    cat "${one_out}/drop_unused_functions.command.txt"
    echo "Exit code:"
    cat "${one_out}/drop_unused_functions.txt.exit_code"
    echo "Output:"
    cat "${one_out}/drop_unused_functions.txt"

    if test ! -s "${sliced}"
    then
      echo
      echo "REACHABLE-ONLY MODEL STATUS: NOT CONSTRUCTED"
      continue
    fi

    echo
    echo "REACHABLE-ONLY MODEL STATUS: CONSTRUCTED"
    echo "Reachable-only model SHA-256:"
    cat "${one_out}/reachable_only_model.sha256"

    echo
    echo "Reachable-only binary validation:"
    cat "${one_out}/validate_reachable_only.command.txt"
    echo "Exit code:"
    cat "${one_out}/validate_reachable_only.txt.exit_code"
    echo "Output:"
    cat "${one_out}/validate_reachable_only.txt"

    echo
    echo "Reachable-only loop identifiers:"
    cat "${one_out}/reachable_only_loops.txt"

    echo
    echo "Reachable-only property identifiers:"
    cat "${one_out}/reachable_only_properties.txt"

    echo
    echo "Reachable-only relevant function markers:"
    grep -n -E \
      '(^|[^[:alnum:]_])(main|nondet_int16_t|mlk_zeroize|mlk_sub00e_r1_poly_sub|mlk_sub00e_r1_poly_reduce|mlk_poly_reduce_c|mlk_barrett_reduce|mlk_scalar_signed_to_unsigned_q)([^[:alnum:]_]|$)' \
      "${one_out}/reachable_only_functions.txt" | head -n 1600 || true
  done

  echo
  echo "============================================================"
  echo "AUDIT VERDICT BOUNDARY"
  echo "============================================================"
  echo
  echo "A validation pass is not a theorem proof."
  echo "A reachable-only model is not a substitute for the original model."
  echo "No SUB-T1 or SUB-T2 success may be reported from this audit."
  echo "Do not open proofs/cbmc/poly_sub/poly_sub_harness.c."
} >"${PACKET}"

(
  cd "${DIR}"

  find "$(basename "${OUT_DIR}")" -type f -print0 |
    LC_ALL=C sort -z |
    xargs -0 sha256sum
) >"${AUDIT_MANIFEST}"

sha256sum "${PACKET}" >"${PACKET_HASH}"

echo
echo "============================================================"
echo "SUB-00E-R2 AUDIT COMPLETED"
echo "============================================================"
echo
echo "Correct binary-validation failures: ${VALIDATION_FAILURES}"
echo "Reachable-only model construction failures: ${SLICE_FAILURES}"
echo "Unexpected reachable mlk_zeroize findings: ${ADAPTER_REACHABILITY_FAILURES}"
echo
cat "${PACKET_HASH}"
echo
echo "Upload these three files:"
echo "1. ${PACKET}"
echo "2. ${PACKET_HASH}"
echo "3. ${AUDIT_MANIFEST}"
echo
echo "Do not run CBMC theorem proofs yet."
echo "Do not open proofs/cbmc/poly_sub/poly_sub_harness.c."

if test "${VALIDATION_FAILURES}" -ne 0 ||
   test "${SLICE_FAILURES}" -ne 0 ||
   test "${ADAPTER_REACHABILITY_FAILURES}" -ne 0
then
  echo
  echo "One or more structural audit gates did not pass."
  echo "The packet preserves the exact evidence for review."
  exit 2
fi
