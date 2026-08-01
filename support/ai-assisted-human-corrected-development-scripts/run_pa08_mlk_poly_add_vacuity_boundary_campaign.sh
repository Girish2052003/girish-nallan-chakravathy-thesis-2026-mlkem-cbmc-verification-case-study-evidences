#!/usr/bin/env bash
#
# PA-08: Vacuity, reachability, loop-endpoint, and arithmetic-boundary
#        hardening campaign for mlk_poly_add.
#
# PA-08A:
#   Successful proof of exact legal boundaries, target completion,
#   coefficient 0, and coefficient MLKEM_N-1.
#
# PA-08B:
#   Expected-failure reachability sentinels after canonical and signed-valid
#   target calls. The sentinel failures demonstrate satisfiable assumptions
#   and post-target path reachability.
#
# PA-08C:
#   Positive just-outside boundary:
#       INT16_MAX + 1
#
# PA-08D:
#   Negative just-outside boundary:
#       INT16_MIN - 1
#
# Expected final status:
#   PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED
#
# Production source is never modified.
#
# Run from the frozen mlkem-native repository root:
#
#   chmod +x run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh
#   ./run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh
#

set -uo pipefail

CAMPAIGN_ID="PA-08"
CAMPAIGN_SCOPE="vacuity_reachability_loop_endpoint_and_boundary_hardening"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="768"

HARNESS_A="pa08a_mlk_poly_add_boundary_hardening_harness.c"
HARNESS_B="pa08b_mlk_poly_add_reachability_sentinel_harness.c"
HARNESS_C="pa08c_mlk_poly_add_upper_outside_boundary_harness.c"
HARNESS_D="pa08d_mlk_poly_add_lower_outside_boundary_harness.c"

POLY_C_EXPECTED_SHA256="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa08_mlk_poly_add_hardening_${TIMESTAMP}"

for tool in git cbmc goto-cc sha256sum tee grep awk; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

for file in \
  "mlkem/src/poly.c" \
  "mlkem/src/poly.h" \
  "${HARNESS_A}" \
  "${HARNESS_B}" \
  "${HARNESS_C}" \
  "${HARNESS_D}"; do
  if [ ! -f "${file}" ]; then
    echo "ERROR: required file missing: ${file}" >&2
    exit 2
  fi
done

CURRENT_COMMIT="$(git rev-parse HEAD)"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  echo "ERROR: repository commit mismatch." >&2
  echo "Expected: ${EXPECTED_COMMIT}" >&2
  echo "Actual:   ${CURRENT_COMMIT}" >&2
  exit 3
fi

if ! git diff --quiet -- mlkem/src/poly.c; then
  echo "ERROR: production mlkem/src/poly.c has tracked modifications." >&2
  exit 4
fi

POLY_C_ACTUAL_SHA256="$(sha256sum mlkem/src/poly.c | awk '{print $1}')"

if [ "${POLY_C_ACTUAL_SHA256}" != "${POLY_C_EXPECTED_SHA256}" ]; then
  echo "ERROR: production poly.c hash mismatch." >&2
  echo "Expected: ${POLY_C_EXPECTED_SHA256}" >&2
  echo "Actual:   ${POLY_C_ACTUAL_SHA256}" >&2
  exit 5
fi

mkdir -p "${OUT_DIR}"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected final status: PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Production poly.c hash: ${POLY_C_ACTUAL_SHA256}"
  echo "Production source modified: no"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1

for harness in "${HARNESS_A}" "${HARNESS_B}" "${HARNESS_C}" "${HARNESS_D}"; do
  sha256sum "${harness}" >> "${OUT_DIR}/harness_sha256.txt"
  cp "${harness}" "${OUT_DIR}/"
done

sha256sum mlkem/src/poly.c > "${OUT_DIR}/production_poly_c_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
cp "$0" "${OUT_DIR}/"

COMMON_CBMC_OPTIONS=(
  --function main
  --bounds-check
  --pointer-check
  --pointer-overflow-check
  --signed-overflow-check
  --unsigned-overflow-check
  --conversion-check
  --div-by-zero-check
  --undefined-shift-check
  --unwind 257
  --unwinding-assertions
)

build_and_run()
{
  local label="$1"
  local harness="$2"
  local result_dir="${OUT_DIR}/${label}"
  local goto_model="${result_dir}/${label}.goto"

  local build_exit=-1
  local text_exit=-1
  local json_exit=-1

  mkdir -p "${result_dir}"

  local build_command=(
    goto-cc
    -I.
    -Imlkem
    -Imlkem/src
    -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
    "${harness}"
    mlkem/src/poly.c
    -o "${goto_model}"
  )

  printf '%q ' "${build_command[@]}" > "${result_dir}/build_command.txt"
  printf '\n' >> "${result_dir}/build_command.txt"

  echo
  echo "============================================================"
  echo "PA-08 UNIT: ${label}"
  echo "============================================================"

  "${build_command[@]}" 2>&1 | tee "${result_dir}/goto_cc_build.log"
  build_exit=${PIPESTATUS[0]}
  echo "${build_exit}" > "${result_dir}/goto_cc_build.exit"

  if [ "${build_exit}" -eq 0 ]; then
    local text_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --trace
    )

    printf '%q ' "${text_command[@]}" > "${result_dir}/cbmc_command.txt"
    printf '\n' >> "${result_dir}/cbmc_command.txt"

    "${text_command[@]}" 2>&1 | tee "${result_dir}/cbmc_output.txt"
    text_exit=${PIPESTATUS[0]}
    echo "${text_exit}" > "${result_dir}/cbmc.exit"

    local json_command=(
      cbmc
      "${goto_model}"
      "${COMMON_CBMC_OPTIONS[@]}"
      --json-ui
    )

    printf '%q ' "${json_command[@]}" > "${result_dir}/cbmc_json_command.txt"
    printf '\n' >> "${result_dir}/cbmc_json_command.txt"

    echo "Running JSON verification silently..."
    "${json_command[@]}" > "${result_dir}/cbmc_output.json" 2> \
      "${result_dir}/cbmc_json_stderr.txt"
    json_exit=$?
    echo "${json_exit}" > "${result_dir}/cbmc_json.exit"
  fi

  echo "${build_exit} ${text_exit} ${json_exit}"
}

marker_has_status()
{
  local output_file="$1"
  local marker="$2"
  local status="$3"

  grep -F "${marker}" "${output_file}" | grep -q "${status}"
}

unexpected_failure_exists()
{
  local allow_conversion="$1"
  local output_file="$2"
  shift 2

  local line
  local allowed="no"

  while IFS= read -r line; do
    allowed="no"

    for marker in "$@"; do
      if printf '%s\n' "${line}" | grep -Fq "${marker}"; then
        allowed="yes"
      fi
    done

    if [ "${allow_conversion}" = "yes" ] &&
       printf '%s\n' "${line}" | \
         grep -Fq "arithmetic overflow on signed type conversion"; then
      allowed="yes"
    fi

    if [ "${allowed}" = "no" ]; then
      return 0
    fi
  done < <(grep "FAILURE" "${output_file}" || true)

  return 1
}

read -r A_BUILD A_TEXT A_JSON < <(
  build_and_run "pa08a_boundary_proof" "${HARNESS_A}" |
    tee /dev/stderr | tail -n 1
)

A_VERIFIED="no"

if [ "${A_BUILD}" -eq 0 ] &&
   [ "${A_TEXT}" -eq 0 ] &&
   [ "${A_JSON}" -eq 0 ] &&
   grep -q "VERIFICATION SUCCESSFUL" \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" &&
   ! grep -q "FAILURE" \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B1_CANONICAL_LOWER_BOUNDARY" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B2_CANONICAL_UPPER_BOUNDARY" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B3_SIGNED_MIN_DIRECT" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_B6_SIGNED_MAX_DIRECT" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_R1_CANONICAL_TARGET_COMPLETED" \
     "SUCCESS" &&
   marker_has_status \
     "${OUT_DIR}/pa08a_boundary_proof/cbmc_output.txt" \
     "PA08A_R2_SIGNED_TARGET_COMPLETED" \
     "SUCCESS"; then
  A_VERIFIED="yes"
fi

read -r B_BUILD B_TEXT B_JSON < <(
  build_and_run "pa08b_reachability_sentinels" "${HARNESS_B}" |
    tee /dev/stderr | tail -n 1
)

B_CANONICAL_REACHABLE="no"
B_SIGNED_REACHABLE="no"
B_NO_BODY_FAILURE="no"
B_UNEXPECTED_FAILURE="yes"

if [ -f "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" ]; then
  if marker_has_status \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" \
       "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET" \
       "FAILURE"; then
    B_CANONICAL_REACHABLE="yes"
  fi

  if marker_has_status \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" \
       "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET" \
       "FAILURE"; then
    B_SIGNED_REACHABLE="yes"
  fi

  if grep -q "no body for callee" \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt"; then
    B_NO_BODY_FAILURE="yes"
  fi

  if ! unexpected_failure_exists \
       "no" \
       "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" \
       "PA08B_R1_CANONICAL_PATH_REACHABLE_AFTER_TARGET" \
       "PA08B_R2_SIGNED_PATH_REACHABLE_AFTER_TARGET"; then
    B_UNEXPECTED_FAILURE="no"
  fi
fi

B_CONFIRMED="no"

if [ "${B_BUILD}" -eq 0 ] &&
   [ "${B_TEXT}" -eq 10 ] &&
   [ "${B_JSON}" -eq 10 ] &&
   grep -q "VERIFICATION FAILED" \
     "${OUT_DIR}/pa08b_reachability_sentinels/cbmc_output.txt" &&
   [ "${B_CANONICAL_REACHABLE}" = "yes" ] &&
   [ "${B_SIGNED_REACHABLE}" = "yes" ] &&
   [ "${B_NO_BODY_FAILURE}" = "no" ] &&
   [ "${B_UNEXPECTED_FAILURE}" = "no" ]; then
  B_CONFIRMED="yes"
fi

check_outside_boundary()
{
  local label="$1"
  local harness="$2"
  local exact_marker="$3"

  local build_exit
  local text_exit
  local json_exit
  local exact_failure="no"
  local conversion_failure="no"
  local no_body_failure="no"
  local unexpected_failure="yes"
  local confirmed="no"

  read -r build_exit text_exit json_exit < <(
    build_and_run "${label}" "${harness}" |
      tee /dev/stderr | tail -n 1
  )

  local output_file="${OUT_DIR}/${label}/cbmc_output.txt"

  if [ -f "${output_file}" ]; then
    if marker_has_status "${output_file}" "${exact_marker}" "FAILURE"; then
      exact_failure="yes"
    fi

    if grep -F "arithmetic overflow on signed type conversion" \
         "${output_file}" | grep -q "FAILURE"; then
      conversion_failure="yes"
    fi

    if grep -q "no body for callee" "${output_file}"; then
      no_body_failure="yes"
    fi

    if ! unexpected_failure_exists \
         "yes" \
         "${output_file}" \
         "${exact_marker}"; then
      unexpected_failure="no"
    fi
  fi

  if [ "${build_exit}" -eq 0 ] &&
     [ "${text_exit}" -eq 10 ] &&
     [ "${json_exit}" -eq 10 ] &&
     grep -q "VERIFICATION FAILED" "${output_file}" &&
     [ "${exact_failure}" = "yes" ] &&
     [ "${conversion_failure}" = "yes" ] &&
     [ "${no_body_failure}" = "no" ] &&
     [ "${unexpected_failure}" = "no" ]; then
    confirmed="yes"
  fi

  {
    echo "label=${label}"
    echo "build_exit=${build_exit}"
    echo "cbmc_text_exit=${text_exit}"
    echo "cbmc_json_exit=${json_exit}"
    echo "exact_assertion_failure_observed=${exact_failure}"
    echo "conversion_failure_observed=${conversion_failure}"
    echo "no_body_failure_observed=${no_body_failure}"
    echo "unexpected_failure_observed=${unexpected_failure}"
    echo "boundary_confirmed=${confirmed}"
  } > "${OUT_DIR}/${label}/summary.txt"

  cat "${OUT_DIR}/${label}/summary.txt"

  printf '%s\n' "${confirmed}"
}

C_CONFIRMED="$(
  check_outside_boundary \
    "pa08c_positive_outside_boundary" \
    "${HARNESS_C}" \
    "PA08C_P1_POSITIVE_JUST_OUTSIDE_EXACT_SUM" |
    tee /dev/stderr | tail -n 1
)"

D_CONFIRMED="$(
  check_outside_boundary \
    "pa08d_negative_outside_boundary" \
    "${HARNESS_D}" \
    "PA08D_P1_NEGATIVE_JUST_OUTSIDE_EXACT_SUM" |
    tee /dev/stderr | tail -n 1
)"

FINAL_STATUS="UNEXPECTED_OR_INCONCLUSIVE"
SCRIPT_EXIT=1

if [ "${A_VERIFIED}" = "yes" ] &&
   [ "${B_CONFIRMED}" = "yes" ] &&
   [ "${C_CONFIRMED}" = "yes" ] &&
   [ "${D_CONFIRMED}" = "yes" ]; then
  FINAL_STATUS="PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "production_source_modified=no"
  echo "pa08a_boundary_and_endpoint_proof_verified=${A_VERIFIED}"
  echo "pa08b_canonical_path_reachable=${B_CANONICAL_REACHABLE}"
  echo "pa08b_signed_valid_path_reachable=${B_SIGNED_REACHABLE}"
  echo "pa08b_only_expected_sentinel_failures=$([ "${B_UNEXPECTED_FAILURE}" = "no" ] && echo yes || echo no)"
  echo "pa08c_positive_just_outside_boundary_confirmed=${C_CONFIRMED}"
  echo "pa08d_negative_just_outside_boundary_confirmed=${D_CONFIRMED}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-08 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "PA08_VACUITY_REACHABILITY_BOUNDARIES_CONFIRMED" ]; then
  echo
  echo "PA-08 SCIENTIFIC OUTCOME: SUCCESS"
  echo "Valid assumptions were shown reachable after target execution."
  echo "Exact legal lower and upper boundaries were verified."
  echo "Both nearest out-of-range boundaries were rejected as expected."
  echo "Production source remained unchanged."
else
  echo
  echo "PA-08 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the complete result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
