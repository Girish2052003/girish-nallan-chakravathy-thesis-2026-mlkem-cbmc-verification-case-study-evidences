#!/usr/bin/env bash
set -Eeuo pipefail
PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
REPO_ROOT="$(pwd -P)"
RUN_DIR="$PACKAGE_ROOT/evidence/run_1"
EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_TREE="54805daff6a91a010c05467ea678117c42a71559"

[ ! -e "$RUN_DIR" ] || { echo 'ERROR: evidence/run_1 already exists; exactly one run is permitted.' >&2; exit 2; }
for t in git cbmc goto-cc goto-instrument gcc python3 sha256sum find sort xargs date uname; do command -v "$t" >/dev/null || { echo "ERROR: missing $t" >&2; exit 2; }; done
[ -f mlkem/src/verify.h ] || { echo 'ERROR: run from mlkem-native repository root.' >&2; exit 2; }
COMMIT="$(git rev-parse HEAD)"; TREE="$(git rev-parse 'HEAD^{tree}')"; STATUS="$(git status --porcelain=v1)"
[ "$COMMIT" = "$EXPECTED_COMMIT" ] || { echo "ERROR: authoritative commit must be $EXPECTED_COMMIT; actual $COMMIT" >&2; exit 3; }
[ "$TREE" = "$EXPECTED_TREE" ] || { echo "ERROR: authoritative tree must be $EXPECTED_TREE; actual $TREE" >&2; exit 3; }
[ -z "$STATUS" ] || { echo 'ERROR: repository is not clean.' >&2; exit 3; }
cbmc --version | grep -q '6\.9\.0' || { echo 'ERROR: CBMC 6.9.0 required.' >&2; exit 3; }
goto-cc --version | grep -q '6\.9\.0' || { echo 'ERROR: goto-cc 6.9.0 required.' >&2; exit 3; }
goto-instrument --version | grep -q '6\.9\.0' || { echo 'ERROR: goto-instrument 6.9.0 required.' >&2; exit 3; }

mkdir -p "$RUN_DIR"
trap 'echo RUN_INCOMPLETE > "$RUN_DIR/RUN_INCOMPLETE.txt"' ERR
{
 echo "campaign=MLK_POLY_Zerorize_SKILL ASSISTED"; echo 'technical_target=mlk_zeroize'; echo 'run_index=1';
 echo "authoritative_commit=$COMMIT"; echo "authoritative_tree=$TREE"; echo "utc_started=$(date -u +%Y-%m-%dT%H:%M:%SZ)";
 echo "repo_root=$REPO_ROOT"; echo "uname=$(uname -a)";
} > "$RUN_DIR/identity.txt"
cbmc --version > "$RUN_DIR/cbmc_version.txt" 2>&1
goto-cc --version > "$RUN_DIR/goto_cc_version.txt" 2>&1
goto-instrument --version > "$RUN_DIR/goto_instrument_version.txt" 2>&1
gcc --version > "$RUN_DIR/gcc_version.txt" 2>&1
python3 --version > "$RUN_DIR/python_version.txt" 2>&1
python3 - <<'PY_ENV' > "$RUN_DIR/environment.json"
import json,platform,sys
print(json.dumps({'platform':platform.platform(),'machine':platform.machine(),'byteorder':sys.byteorder,'python':platform.python_version(),'language_mode':'C90','parameter_set':768,'host_bytes':16,'authoritative_commit':'af4c5abdd5958bdc65a03cd5ee86708264f93304','authoritative_tree':'54805daff6a91a010c05467ea678117c42a71559'},indent=2))
PY_ENV
cp "$PACKAGE_ROOT/manifests/MANIFEST.sha256" "$RUN_DIR/package_manifest_before_run.sha256"
sha256sum mlkem/src/verify.h mlkem/src/common.h mlkem/src/cbmc.h mlkem/src/sys.h mlkem/src/params.h mlkem/mlkem_native_config.h > "$RUN_DIR/production_source_sha256.txt"
python3 "$PACKAGE_ROOT/runner/audit_repository_distinctness.py" "$REPO_ROOT" "$RUN_DIR/repository_distinctness.json"

COMMON_CPP=(-std=c90 -I. -Imlkem -Imlkem/src -DMLK_CONFIG_PARAMETER_SET=768 -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sa_zero)
COMMON_CHECKS=(--function main --object-bits 10 --bounds-check --pointer-check --pointer-overflow-check --conversion-check --signed-overflow-check --unsigned-overflow-check --div-by-zero-check --undefined-shift-check --unwind 17 --unwinding-assertions --slice-formula --json-ui)

run_theorem() {
 local label="$1" harness="$2" fail_token="$3" out="$RUN_DIR/$1" rc
 mkdir -p "$out"; cp "$harness" "$out/harness.c"
 printf '%q ' gcc "${COMMON_CPP[@]}" -E -P "$harness" > "$out/preprocess_command.txt"; echo >> "$out/preprocess_command.txt"
 gcc "${COMMON_CPP[@]}" -E -P "$harness" > "$out/preprocessed.c" 2> "$out/preprocess.stderr"
 printf '%q ' goto-cc "${COMMON_CPP[@]}" "$harness" -o "$out/proof_model.goto" > "$out/proof_build_command.txt"; echo >> "$out/proof_build_command.txt"
 set +e; goto-cc "${COMMON_CPP[@]}" "$harness" -o "$out/proof_model.goto" > "$out/proof_build.log" 2>&1; rc=$?; set -e; echo "$rc" > "$out/proof_build_exit_code.txt"; [ "$rc" -eq 0 ]
 printf '%q ' goto-cc "${COMMON_CPP[@]}" -DSKILL_COVER_MODE=1 "$harness" -o "$out/cover_model.goto" > "$out/cover_build_command.txt"; echo >> "$out/cover_build_command.txt"
 set +e; goto-cc "${COMMON_CPP[@]}" -DSKILL_COVER_MODE=1 "$harness" -o "$out/cover_model.goto" > "$out/cover_build.log" 2>&1; rc=$?; set -e; echo "$rc" > "$out/cover_build_exit_code.txt"; [ "$rc" -eq 0 ]
 printf '%q ' goto-cc "${COMMON_CPP[@]}" -DSKILL_FAIL_CONTROL=1 "$harness" -o "$out/fail_control_model.goto" > "$out/fail_control_build_command.txt"; echo >> "$out/fail_control_build_command.txt"
 set +e; goto-cc "${COMMON_CPP[@]}" -DSKILL_FAIL_CONTROL=1 "$harness" -o "$out/fail_control_model.goto" > "$out/fail_control_build.log" 2>&1; rc=$?; set -e; echo "$rc" > "$out/fail_control_build_exit_code.txt"; [ "$rc" -eq 0 ]
 goto-instrument --show-goto-functions "$out/proof_model.goto" > "$out/proof_functions.txt" 2>&1
 goto-instrument --show-goto-functions "$out/cover_model.goto" > "$out/cover_functions.txt" 2>&1
 goto-instrument --show-goto-functions "$out/fail_control_model.goto" > "$out/fail_control_functions.txt" 2>&1
 goto-instrument --show-symbol-table "$out/proof_model.goto" > "$out/proof_symbols.txt" 2>&1
 goto-instrument --show-loops "$out/proof_model.goto" > "$out/proof_loops.txt" 2>&1
 goto-instrument --show-loops "$out/cover_model.goto" > "$out/cover_loops.txt" 2>&1
 goto-instrument --show-properties "$out/proof_model.goto" > "$out/proof_properties.txt" 2>&1
 goto-instrument --show-properties "$out/cover_model.goto" > "$out/cover_properties.txt" 2>&1
 goto-instrument --show-properties "$out/fail_control_model.goto" > "$out/fail_control_properties.txt" 2>&1
 python3 "$PACKAGE_ROOT/runner/audit_body_binding.py" "$out/proof_functions.txt" "$out/preprocessed.c" "$out/body_binding.json"
 printf '%q ' cbmc "$out/proof_model.goto" "${COMMON_CHECKS[@]}" > "$out/proof_command.txt"; echo >> "$out/proof_command.txt"
 set +e; cbmc "$out/proof_model.goto" "${COMMON_CHECKS[@]}" > "$out/proof.json" 2> "$out/proof.stderr"; rc=$?; set -e; echo "$rc" > "$out/proof_exit_code.txt"; [ "$rc" -eq 0 ]
 printf '%q ' cbmc "$out/cover_model.goto" "${COMMON_CHECKS[@]}" --trace > "$out/cover_command.txt"; echo >> "$out/cover_command.txt"
 set +e; cbmc "$out/cover_model.goto" "${COMMON_CHECKS[@]}" --trace > "$out/cover.json" 2> "$out/cover.stderr"; rc=$?; set -e; echo "$rc" > "$out/cover_exit_code.txt"; [ "$rc" -eq 10 ]
 printf '%q ' cbmc "$out/fail_control_model.goto" "${COMMON_CHECKS[@]}" --trace > "$out/fail_control_command.txt"; echo >> "$out/fail_control_command.txt"
 set +e; cbmc "$out/fail_control_model.goto" "${COMMON_CHECKS[@]}" --trace > "$out/fail_control.json" 2> "$out/fail_control.stderr"; rc=$?; set -e; echo "$rc" > "$out/fail_control_exit_code.txt"; [ "$rc" -eq 10 ]; grep -q "$fail_token" "$out/fail_control.json"
 (cd "$out" && find . -type f ! -name sha256.txt -print0 | sort -z | xargs -0 sha256sum) > "$out/sha256.txt"
}

run_theorem SA_ZERO_T1 "$PACKAGE_ROOT/harnesses/sa_zero_t1_secret_history_convergence_harness.c" SA_ZERO_T1_FC_SECRET_DIFFERENCE_PERSISTS
run_theorem SA_ZERO_T2 "$PACKAGE_ROOT/harnesses/sa_zero_t2_recontamination_recovery_harness.c" SA_ZERO_T2_FC_RECONTAMINATION_PERSISTS
python3 "$PACKAGE_ROOT/runner/summarize_results.py" "$RUN_DIR"
[ -z "$(git status --porcelain=v1)" ] || { echo 'ERROR: repository changed during campaign.' >&2; exit 21; }
rm -f "$RUN_DIR/RUN_INCOMPLETE.txt"
echo "utc_completed=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$RUN_DIR/identity.txt"
(cd "$RUN_DIR" && find . -type f ! -name RUN_MANIFEST.sha256 -print0 | sort -z | xargs -0 sha256sum) > "$RUN_DIR/RUN_MANIFEST.sha256"
echo RUN_1_ACCEPTED
