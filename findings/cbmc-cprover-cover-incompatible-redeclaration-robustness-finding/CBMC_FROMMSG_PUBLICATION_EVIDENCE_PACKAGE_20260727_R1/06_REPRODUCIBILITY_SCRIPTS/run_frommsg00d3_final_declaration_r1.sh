#!/usr/bin/env bash
set -Eeuo pipefail
ulimit -c 0 || true

CAMPAIGN="$HOME/THESIS-2026/mlk_poly_frommsg_cleanroom"

PREVIOUS_D2_STAGE="$CAMPAIGN/FROMMSG00D2_CROSS_VERSION_20260724T171137Z"
DEV_SOURCE="$CAMPAIGN/FROMMSG00D2_BUILD_WORK_20260724T171137Z/cbmc-develop"

T1_PACKET="$CAMPAIGN/FROMSGT1_FINAL_PACKAGE/FROMSGT1_AUTHORITATIVE_FINAL_20260724T160742Z.tar.gz"
D2_PACKET="$CAMPAIGN/FROMMSG00D2_FINAL_PACKAGE/FROMMSG00D2_CROSS_VERSION_FINAL_20260724T171137Z.tar.gz"
D2R1_PACKET="$CAMPAIGN/FROMMSG00D2R1_FINAL_PACKAGE/FROMMSG00D2R1_FINAL_20260724T172546Z.tar.gz"

EXPECTED_T1_SHA256="b656a34aa124ee183bf36cea8d4543d35888ae8436ba8efe94f64cdd4e83b404"
EXPECTED_D2_SHA256="32bbd306cb3bd3e9cc65ede8b01f16da87950dde747f0601bd414c837a046c71"
EXPECTED_D2R1_SHA256="619d7715ed4429e106e447ee935195ad3eef852c195ccadc54a46c7f22c38784"
EXPECTED_DEV_COMMIT="f71fdad8e4b0416b0f2ab471670caee893fb8b4c"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
DEV_SHORT="${EXPECTED_DEV_COMMIT:0:12}"

STAGE="$CAMPAIGN/FROMMSG00D3_FINAL_DECLARATION_${STAMP}"
PACKAGE_DIR="$CAMPAIGN/FROMMSG00D3_FINAL_PACKAGE"
BUILD_DIR="$STAGE/develop-build"
REPRO_DIR="$STAGE/minimal-reproducer"
REPORT_DIR="$STAGE/reports"
PRIOR_DIR="$STAGE/prior-frozen-packets"
RUNNER_CONTEXT="$STAGE/develop-runner-image"
LOG="$STAGE/FROMMSG00D3_${STAMP}.txt"
MATRIX="$STAGE/DEVELOP_RESULT_MATRIX.tsv"
DEV_IMAGE="girish-cbmc-develop-${DEV_SHORT}:${STAMP}"

mkdir -p \
  "$STAGE" \
  "$PACKAGE_DIR" \
  "$BUILD_DIR" \
  "$REPRO_DIR" \
  "$REPORT_DIR" \
  "$PRIOR_DIR" \
  "$RUNNER_CONTEXT"

fatal()
{
  echo "FATAL=$1"
  exit 1
}

on_error()
{
  local rc="$?"
  local line="$1"
  echo "UNEXPECTED_ERROR_RETURN_CODE=$rc"
  echo "UNEXPECTED_ERROR_LINE=$line"
  exit "$rc"
}

# No global ERR trap: several diagnostic and counterexample commands
# intentionally return non-zero and are classified explicitly.

need_tool()
{
  command -v "$1" >/dev/null 2>&1 || fatal "MISSING_TOOL_$1"
}

need_file()
{
  [ -f "$1" ] || fatal "MISSING_FILE=$1"
}

verify_hash()
{
  local file="$1"
  local expected="$2"
  local label="$3"
  local actual

  need_file "$file"
  actual="$(sha256sum "$file" | awk '{print $1}')"

  echo "EXPECTED_${label}_SHA256=$expected"
  echo "ACTUAL_${label}_SHA256=$actual"

  [ "$actual" = "$expected" ] || fatal "${label}_HASH_MISMATCH"
}

for tool in docker git timeout sha256sum python3 tar cmake awk grep sed find sort xargs cp
do
  need_tool "$tool"
done

docker info >/dev/null 2>&1 || fatal "DOCKER_NOT_AVAILABLE"

need_file "$PREVIOUS_D2_STAGE/result_matrix.tsv"
need_file "$DEV_SOURCE/CMakeLists.txt"
need_file "$DEV_SOURCE/COMPILING.md"
need_file "$DEV_SOURCE/src/util/std_expr.h"

verify_hash "$T1_PACKET" "$EXPECTED_T1_SHA256" "T1_PACKET"
verify_hash "$D2_PACKET" "$EXPECTED_D2_SHA256" "D2_PACKET"
verify_hash "$D2R1_PACKET" "$EXPECTED_D2R1_SHA256" "D2R1_PACKET"

ACTUAL_DEV_COMMIT="$(git -C "$DEV_SOURCE" rev-parse HEAD)"
ACTUAL_DEV_TREE="$(git -C "$DEV_SOURCE" rev-parse 'HEAD^{tree}')"
INITIAL_DEV_STATUS="$(git -C "$DEV_SOURCE" status --porcelain)"

echo "EXPECTED_DEV_COMMIT=$EXPECTED_DEV_COMMIT"
echo "ACTUAL_DEV_COMMIT=$ACTUAL_DEV_COMMIT"
echo "ACTUAL_DEV_TREE=$ACTUAL_DEV_TREE"
echo "INITIAL_DEVELOP_STATUS_BEGIN"
printf '%s\n' "$INITIAL_DEV_STATUS"
echo "INITIAL_DEVELOP_STATUS_END"

[ "$ACTUAL_DEV_COMMIT" = "$EXPECTED_DEV_COMMIT" ] || fatal "DEVELOP_COMMIT_MISMATCH"
[ -z "$INITIAL_DEV_STATUS" ] || fatal "DEVELOP_SOURCE_NOT_CLEAN"

cp "$T1_PACKET" "$PRIOR_DIR/"
cp "$D2_PACKET" "$PRIOR_DIR/"
cp "$D2R1_PACKET" "$PRIOR_DIR/"

cat >"$REPRO_DIR/01_canonical.c" <<'EOF'
int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
EOF

cat >"$REPRO_DIR/02_wrong_bool.c" <<'EOF'
void __CPROVER_cover(_Bool condition);

int main(void)
{
  __CPROVER_cover((_Bool)1);
  return 0;
}
EOF

cat >"$REPRO_DIR/03_wrong_int.c" <<'EOF'
void __CPROVER_cover(int condition);

int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
EOF

cat >"$REPRO_DIR/README.md" <<'EOF'
# Minimal reproducer

Canonical control:

```c
int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
```

Malformed `_Bool` declaration:

```c
void __CPROVER_cover(_Bool condition);

int main(void)
{
  __CPROVER_cover((_Bool)1);
  return 0;
}
```

Malformed `int` declaration:

```c
void __CPROVER_cover(int condition);

int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
```

The investigated behaviour is an internal invariant termination after
`--cover cover`, rather than a controlled incompatible-declaration diagnostic.
EOF

classify()
{
  local rc="$1"
  local invariant_count="$2"

  if [ "$rc" -ne 0 ] && [ "$invariant_count" -gt 0 ]; then
    echo "INTERNAL_INVARIANT_CRASH"
    return
  fi

  case "$rc" in
    0) echo "NORMAL_SUCCESS" ;;
    6) echo "CONTROLLED_PROCESSING_ERROR" ;;
    10) echo "CONTROLLED_VERIFICATION_FAILURE" ;;
    124) echo "TIMEOUT" ;;
    134|139) echo "FATAL_SIGNAL_WITHOUT_MATCHED_INVARIANT" ;;
    *) echo "OTHER_RETURN_CODE_$rc" ;;
  esac
}

run_case()
{
  local case_name="$1"
  local source_file="$2"
  shift 2

  local out="$STAGE/${case_name}.stdout.txt"
  local err="$STAGE/${case_name}.stderr.txt"
  local combined="$STAGE/${case_name}.combined.txt"
  local command_file="$STAGE/${case_name}.command.txt"
  local meta="$STAGE/${case_name}.meta.txt"
  local rc invariant_count coverage_count classification

  local command=(
    docker run
    --rm
    --network none
    --read-only
    --tmpfs /tmp:rw,nosuid,nodev,size=64m
    --mount "type=bind,source=$REPRO_DIR,target=/work,readonly"
    --workdir /work
    --entrypoint cbmc
    "$DEV_IMAGE"
    "$(basename "$source_file")"
    --function main
    "$@"
  )

  {
    printf '%q ' "${command[@]}"
    printf '\n'
  } >"$command_file"

  echo
  echo "============================================================"
  echo "CASE=$case_name"
  echo "COMMAND=$(cat "$command_file")"
  echo "============================================================"

  set +e
  timeout \
    --signal=TERM \
    --kill-after=10s \
    300s \
    "${command[@]}" \
    >"$out" \
    2>"$err"
  rc="$?"
  set -e

  {
    cat "$out"
    cat "$err"
  } >"$combined"

  invariant_count="$(
    grep -Eic \
      'Invariant check failed|not_exprt|is_boolean|std_expr\.h' \
      "$combined" || true
  )"

  coverage_count="$(
    grep -Eic \
      'coverage results|SATISFIED' \
      "$combined" || true
  )"

  classification="$(classify "$rc" "$invariant_count")"

  {
    echo "CASE=$case_name"
    echo "RETURN_CODE=$rc"
    echo "CLASSIFICATION=$classification"
    echo "INVARIANT_MARKER_COUNT=$invariant_count"
    echo "COVERAGE_SUCCESS_MARKER_COUNT=$coverage_count"
    echo "STDOUT_SIZE=$(wc -c < "$out")"
    echo "STDERR_SIZE=$(wc -c < "$err")"
  } >"$meta"

  cat "$meta"

  echo "----- DECISIVE OUTPUT -----"
  grep -nE \
    'Invariant check failed|not_exprt|is_boolean|std_expr\.h|coverage results|SATISFIED|VERIFICATION|error:|incompatible' \
    "$combined" | tail -n 100 || true

  printf '%s\t%s\t%s\t%s\t%s\n' \
    "$case_name" \
    "$rc" \
    "$classification" \
    "$invariant_count" \
    "$coverage_count" \
    >>"$MATRIX"

  sha256sum \
    "$source_file" \
    "$out" \
    "$err" \
    "$combined" \
    "$command_file" \
    "$meta" \
    >"$STAGE/${case_name}.sha256"
}

main()
{
  echo "============================================================"
  echo "FROMMSG-00D3 — FINAL DEVELOP GATE AND DECLARATION"
  echo "============================================================"
  echo "UTC_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "STAGE=$STAGE"
  echo "DEVELOP_SOURCE=$DEV_SOURCE"
  echo "DEVELOP_COMMIT=$EXPECTED_DEV_COMMIT"
  echo

  echo "===== VERIFY PRIOR OFFICIAL-RELEASE MATRIX ====="

  python3 - "$PREVIOUS_D2_STAGE/result_matrix.tsv" <<'PY'
import csv
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
rows = list(csv.DictReader(path.open(), delimiter="\t"))

required = {
    ("OFFICIAL_6_9_0", "CANONICAL_COVER"),
    ("OFFICIAL_6_9_0", "CANONICAL_TESTSUITE"),
    ("OFFICIAL_6_9_0", "WRONG_BOOL_COVER"),
    ("OFFICIAL_6_9_0", "WRONG_BOOL_TESTSUITE"),
    ("OFFICIAL_6_9_0", "WRONG_INT_COVER"),
    ("OFFICIAL_6_9_0", "WRONG_INT_TESTSUITE"),
    ("OFFICIAL_6_10_0", "CANONICAL_COVER"),
    ("OFFICIAL_6_10_0", "CANONICAL_TESTSUITE"),
    ("OFFICIAL_6_10_0", "WRONG_BOOL_COVER"),
    ("OFFICIAL_6_10_0", "WRONG_BOOL_TESTSUITE"),
    ("OFFICIAL_6_10_0", "WRONG_INT_COVER"),
    ("OFFICIAL_6_10_0", "WRONG_INT_TESTSUITE"),
}

seen = {(r["ENVIRONMENT"], r["CASE"]) for r in rows}
missing = sorted(required - seen)

if missing:
    raise SystemExit(f"MISSING_PRIOR_CASES={missing!r}")

for environment in ("OFFICIAL_6_9_0", "OFFICIAL_6_10_0"):
    env_rows = [r for r in rows if r["ENVIRONMENT"] == environment]
    canonical = [r for r in env_rows if r["CASE"].startswith("CANONICAL_")]
    malformed = [r for r in env_rows if r["CASE"].startswith("WRONG_")]

    if len(canonical) != 2:
        raise SystemExit(f"{environment}_CANONICAL_COUNT={len(canonical)}")

    if not all(
        r["RETURN_CODE"] == "0" and int(r["INVARIANT_MARKERS"]) == 0
        for r in canonical
    ):
        raise SystemExit(f"{environment}_CANONICAL_CONTROL_FAILED")

    if len(malformed) != 4:
        raise SystemExit(f"{environment}_MALFORMED_COUNT={len(malformed)}")

    if not all(
        int(r["RETURN_CODE"]) != 0 and int(r["INVARIANT_MARKERS"]) > 0
        for r in malformed
    ):
        raise SystemExit(f"{environment}_MALFORMED_CRASH_NOT_CONFIRMED")

    print(f"{environment}_PRIOR_EVIDENCE=PASS")
PY

  echo
  echo "===== FRESH CONTAINER BUILD OF PINNED DEVELOP ====="

  docker pull ubuntu:24.04 \
    >"$STAGE/ubuntu_pull.stdout.txt" \
    2>"$STAGE/ubuntu_pull.stderr.txt"

  cat >"$STAGE/develop_build.command.txt" <<EOF
docker run --rm --network bridge \
  --mount type=bind,source=$DEV_SOURCE,target=/src,readonly \
  --mount type=bind,source=$BUILD_DIR,target=/build \
  ubuntu:24.04 /bin/bash -lc '<captured in develop_build_inner.sh>'
EOF

  cat >"$STAGE/develop_build_inner.sh" <<'INNER'
#!/usr/bin/env bash
set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  cmake \
  ninja-build \
  flex \
  bison \
  git \
  curl \
  patch \
  pkg-config \
  libxml2-dev \
  zlib1g-dev

rm -rf /build/*
cmake \
  -S /src \
  -B /build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DWITH_JBMC=OFF

cmake \
  --build /build \
  --target cbmc \
  --parallel 2

find /build -type f -name cbmc -perm -111 -print
INNER

  chmod +x "$STAGE/develop_build_inner.sh"

  set +e
  timeout \
    --signal=TERM \
    --kill-after=30s \
    7200s \
    docker run \
      --rm \
      --network bridge \
      --mount "type=bind,source=$DEV_SOURCE,target=/src,readonly" \
      --mount "type=bind,source=$BUILD_DIR,target=/build" \
      --mount "type=bind,source=$STAGE/develop_build_inner.sh,target=/develop_build_inner.sh,readonly" \
      ubuntu:24.04 \
      /bin/bash /develop_build_inner.sh \
      >"$STAGE/develop_build.stdout.txt" \
      2>"$STAGE/develop_build.stderr.txt"
  BUILD_RC="$?"
  set -e

  echo "DEVELOP_BUILD_RETURN_CODE=$BUILD_RC"

  if [ "$BUILD_RC" -ne 0 ]; then
    echo "----- BUILD STDOUT TAIL -----"
    tail -n 200 "$STAGE/develop_build.stdout.txt" || true
    echo "----- BUILD STDERR TAIL -----"
    tail -n 200 "$STAGE/develop_build.stderr.txt" || true
    fatal "PINNED_DEVELOP_BUILD_FAILED"
  fi

  DEVELOP_CBMC="$(
    find "$BUILD_DIR" -type f -name cbmc -perm -111 | head -n 1
  )"

  [ -n "$DEVELOP_CBMC" ] || fatal "DEVELOP_CBMC_BINARY_NOT_FOUND"

  echo "DEVELOP_CBMC_BINARY=$DEVELOP_CBMC"
  "$DEVELOP_CBMC" --version \
    >"$STAGE/develop_cbmc.version.txt"
  sha256sum "$DEVELOP_CBMC" \
    >"$STAGE/develop_cbmc.binary.sha256"
  ldd "$DEVELOP_CBMC" \
    >"$STAGE/develop_cbmc.ldd.txt" || true

  cp "$DEVELOP_CBMC" "$RUNNER_CONTEXT/cbmc"
  chmod +x "$RUNNER_CONTEXT/cbmc"

  cat >"$RUNNER_CONTEXT/Dockerfile" <<'DOCKERFILE'
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gcc \
      libstdc++6 \
      libxml2 \
      zlib1g && \
    rm -rf /var/lib/apt/lists/*

COPY cbmc /usr/local/bin/cbmc

ENTRYPOINT ["/usr/local/bin/cbmc"]
DOCKERFILE

  DOCKER_BUILDKIT=0 \
  docker build \
    --no-cache \
    --tag "$DEV_IMAGE" \
    "$RUNNER_CONTEXT" \
    >"$STAGE/develop_runner_build.stdout.txt" \
    2>"$STAGE/develop_runner_build.stderr.txt"

  docker image inspect "$DEV_IMAGE" \
    >"$STAGE/develop_runner_image.inspect.json"

  echo "DEVELOP_RUNNER_IMAGE=$DEV_IMAGE"
  echo "DEVELOP_RUNNER_IMAGE_ID=$(
    docker image inspect --format '{{.Id}}' "$DEV_IMAGE"
  )"

  docker run \
    --rm \
    --network none \
    --entrypoint /bin/sh \
    "$DEV_IMAGE" \
    -lc '
      cbmc --version
      sha256sum "$(command -v cbmc)"
      uname -a
      cat /etc/os-release
    ' >"$STAGE/develop_environment.txt" 2>&1

  printf \
    'CASE\tRETURN_CODE\tCLASSIFICATION\tINVARIANT_MARKERS\tCOVERAGE_MARKERS\n' \
    >"$MATRIX"

  echo
  echo "===== PINNED DEVELOP TEST MATRIX ====="

  run_case \
    "CANONICAL_COVER" \
    "$REPRO_DIR/01_canonical.c" \
    --cover cover

  run_case \
    "CANONICAL_TESTSUITE" \
    "$REPRO_DIR/01_canonical.c" \
    --cover cover \
    --show-test-suite

  run_case \
    "WRONG_BOOL_BASELINE" \
    "$REPRO_DIR/02_wrong_bool.c"

  run_case \
    "WRONG_BOOL_COVER" \
    "$REPRO_DIR/02_wrong_bool.c" \
    --cover cover

  run_case \
    "WRONG_BOOL_TESTSUITE" \
    "$REPRO_DIR/02_wrong_bool.c" \
    --cover cover \
    --show-test-suite

  run_case \
    "WRONG_INT_BASELINE" \
    "$REPRO_DIR/03_wrong_int.c"

  run_case \
    "WRONG_INT_COVER" \
    "$REPRO_DIR/03_wrong_int.c" \
    --cover cover

  run_case \
    "WRONG_INT_TESTSUITE" \
    "$REPRO_DIR/03_wrong_int.c" \
    --cover cover \
    --show-test-suite

  echo
  echo "===== DEVELOP RESULT MATRIX ====="
  column -t -s $'\t' "$MATRIX" 2>/dev/null || cat "$MATRIX"

  echo
  echo "===== FINAL CLASSIFICATION AND PROFESSOR REPORT ====="

  python3 \
    - \
    "$MATRIX" \
    "$REPORT_DIR" \
    "$EXPECTED_DEV_COMMIT" \
    "$ACTUAL_DEV_TREE" \
    "$EXPECTED_T1_SHA256" \
    "$EXPECTED_D2_SHA256" \
    "$EXPECTED_D2R1_SHA256" <<'PY'
import csv
import pathlib
import sys

matrix = pathlib.Path(sys.argv[1])
report_dir = pathlib.Path(sys.argv[2])
develop_commit = sys.argv[3]
develop_tree = sys.argv[4]
t1_hash = sys.argv[5]
d2_hash = sys.argv[6]
d2r1_hash = sys.argv[7]

rows = list(csv.DictReader(matrix.open(), delimiter="\t"))

required_cases = {
    "CANONICAL_COVER",
    "CANONICAL_TESTSUITE",
    "WRONG_BOOL_BASELINE",
    "WRONG_BOOL_COVER",
    "WRONG_BOOL_TESTSUITE",
    "WRONG_INT_BASELINE",
    "WRONG_INT_COVER",
    "WRONG_INT_TESTSUITE",
}

if {r["CASE"] for r in rows} != required_cases:
    raise SystemExit("DEVELOP_CASE_SET_MISMATCH")

canonical = [
    r for r in rows
    if r["CASE"] in {"CANONICAL_COVER", "CANONICAL_TESTSUITE"}
]

baselines = [
    r for r in rows
    if r["CASE"] in {"WRONG_BOOL_BASELINE", "WRONG_INT_BASELINE"}
]

malformed_cover = [
    r for r in rows
    if r["CASE"] in {
        "WRONG_BOOL_COVER",
        "WRONG_BOOL_TESTSUITE",
        "WRONG_INT_COVER",
        "WRONG_INT_TESTSUITE",
    }
]

canonical_pass = (
    len(canonical) == 2
    and all(
        r["RETURN_CODE"] == "0"
        and r["CLASSIFICATION"] == "NORMAL_SUCCESS"
        and int(r["INVARIANT_MARKERS"]) == 0
        for r in canonical
    )
)

baselines_controlled = (
    len(baselines) == 2
    and all(
        int(r["INVARIANT_MARKERS"]) == 0
        and r["CLASSIFICATION"] in {
            "NORMAL_SUCCESS",
            "CONTROLLED_PROCESSING_ERROR",
            "CONTROLLED_VERIFICATION_FAILURE",
        }
        for r in baselines
    )
)

develop_crash_count = sum(
    r["CLASSIFICATION"] == "INTERNAL_INVARIANT_CRASH"
    for r in malformed_cover
)

develop_controlled_count = sum(
    int(r["INVARIANT_MARKERS"]) == 0
    and r["CLASSIFICATION"] in {
        "NORMAL_SUCCESS",
        "CONTROLLED_PROCESSING_ERROR",
        "CONTROLLED_VERIFICATION_FAILURE",
    }
    for r in malformed_cover
)

if canonical_pass and baselines_controlled and develop_crash_count == 4:
    develop_status = "AFFECTED"
    classification = (
        "OFFICIAL_6_9_0_6_10_0_AND_PINNED_DEVELOP_AFFECTED"
    )
    claim = (
        "A current cross-version CBMC robustness and type-handling "
        "defect is established in the tested official CBMC 6.9.0 "
        "and 6.10.0 images and pinned develop commit "
        f"{develop_commit}. Canonical __CPROVER_cover usage succeeds. "
        "However, incompatible manual _Bool or int redeclarations "
        "remain controlled without coverage instrumentation but cause "
        "an internal not_exprt Boolean-expression invariant when "
        "--cover cover processes the malformed built-in call, instead "
        "of producing a controlled incompatible-declaration diagnostic."
    )
    filing = "FILE_CBMC_ISSUE=YES"
elif (
    canonical_pass
    and baselines_controlled
    and develop_crash_count == 0
    and develop_controlled_count == 4
):
    develop_status = "NOT_AFFECTED_CONTROLLED"
    classification = (
        "OFFICIAL_6_9_0_AND_6_10_0_AFFECTED_PINNED_DEVELOP_FIXED"
    )
    claim = (
        "A released-version CBMC robustness and type-handling defect "
        "is established in the tested official CBMC 6.9.0 and 6.10.0 "
        "images. Canonical __CPROVER_cover usage succeeds, while "
        "incompatible _Bool or int redeclarations cause an internal "
        "not_exprt Boolean-expression invariant during coverage "
        "instrumentation. Pinned develop commit "
        f"{develop_commit} handles the malformed cases without that "
        "internal crash, indicating that the issue appears fixed on "
        "the tested develop revision."
    )
    filing = "FILE_CBMC_ISSUE=YES_INCLUDE_DEVELOP_RESULT"
else:
    develop_status = "MIXED_OR_INCOMPLETE"
    classification = "OFFICIAL_RELEASES_AFFECTED_DEVELOP_MIXED"
    claim = (
        "The defect remains established in the tested official CBMC "
        "6.9.0 and 6.10.0 images. The pinned develop matrix is mixed "
        "and does not support a claim that develop is either affected "
        "or fixed."
    )
    filing = "FILE_CBMC_ISSUE=YES_RELEASE_EVIDENCE_SUFFICIENT"

classification_file = report_dir / "FINAL_SCIENTIFIC_CLASSIFICATION.txt"

classification_file.write_text(
    "\n".join([
        "OFFICIAL_6_9_0_STATUS=AFFECTED",
        "OFFICIAL_6_10_0_STATUS=AFFECTED",
        f"PINNED_DEVELOP_STATUS={develop_status}",
        f"FINAL_CLASSIFICATION={classification}",
        f"DEVELOP_COMMIT={develop_commit}",
        f"DEVELOP_TREE={develop_tree}",
        filing,
        "",
        "STRONGEST_SUPPORTED_CLAIM_BEGIN",
        claim,
        "STRONGEST_SUPPORTED_CLAIM_END",
        "",
        "MINIMAL_STANDALONE_REPRODUCER=YES",
        "MATCHING_CANONICAL_CONTROL=YES",
        "MALFORMED_BASELINE_CONTROL=YES",
        "COVERAGE_TRIGGER_ISOLATED=YES",
        "SOLVER_DEFECT_ESTABLISHED=NO",
        "MLKEM_IMPLEMENTATION_DEFECT_ESTABLISHED=NO",
        "GENERAL_CANONICAL_COVERAGE_DEFECT_ESTABLISHED=NO",
        "UNSOUND_SUCCESS_ESTABLISHED=NO",
        "SECURITY_VULNERABILITY_ESTABLISHED=NO",
        "MAJOR_SEVERITY_ESTABLISHED=NO",
        "",
    ])
)

memo = report_dir / "PROFESSOR_FINDING_MEMO.md"
memo.write_text(
    f"""# CBMC Verification-Stack Finding

## Executive finding

{claim}

## Evidence

- Tiny standalone reproducer independent of ML-KEM.
- Canonical working coverage control.
- Incompatible `_Bool` and `int` declaration variants.
- Baseline runs without coverage instrumentation.
- Coverage-only and coverage-plus-test-suite runs.
- Official CBMC 6.9.0 and 6.10.0 container evidence.
- Fresh container build from pinned develop commit `{develop_commit}`.
- Exact commands, stdout, stderr, return codes and hashes.
- SHA-256-bound prior evidence packets.
- Separate direct-body `mlk_poly_frommsg` semantic proof control.

## Differential control

The separately frozen T1 campaign proved the selected direct-body
`mlk_poly_frommsg` binary-embedding theorem with explicit complete-unwind
calibration, repeated proof runs, reachability witnesses and mutation
controls. The robustness finding therefore must not be described as an
ML-KEM implementation failure.

## Scope

This establishes a CBMC robustness/type-handling defect in the affected tested
versions. It does not establish a solver defect, an ML-KEM vulnerability,
general failure of canonical coverage, unsound verification success, a
security vulnerability, or major severity.

## Evidence bindings

- T1 packet SHA-256: `{t1_hash}`
- Official-release packet SHA-256: `{d2_hash}`
- Prior build-audit packet SHA-256: `{d2r1_hash}`
- Develop commit: `{develop_commit}`
- Develop tree: `{develop_tree}`
"""
)

email = report_dir / "PROFESSOR_EMAIL_DRAFT.txt"
email.write_text(
    f"""Subject: Reproducible CBMC robustness finding

Dear Professor,

I completed the controlled cross-version investigation of the verification
failure observed during the mlk_poly_frommsg case study.

{claim}

The result is supported by a minimal standalone reproducer, matching canonical
controls, malformed baseline controls, official container evidence, a fresh
build from a pinned develop commit, exact commands and outputs, binary and
packet hashes, and a frozen evidence archive.

I am not interpreting the result as a solver defect, an ML-KEM vulnerability,
a general canonical-coverage failure, unsound verification success, or a
major-severity issue. A separate direct-body CBMC campaign proved the selected
mlk_poly_frommsg semantic theorem and acts as the differential implementation
control.

Kind regards,
Girish Nallan Chakravathy
"""
)

issue = report_dir / "CBMC_ISSUE_DRAFT.md"
issue.write_text(
    f"""# Internal invariant when `__CPROVER_cover` is redeclared with an incompatible type

## Summary

{claim}

## Minimal reproducer

```c
void __CPROVER_cover(_Bool condition);

int main(void)
{{
  __CPROVER_cover((_Bool)1);
  return 0;
}}
```

## Command

```sh
cbmc reproducer.c --function main --cover cover
```

## Expected behaviour

A controlled diagnostic rejecting the incompatible declaration.

## Actual behaviour

```text
Invariant check failed
function: not_exprt
Condition: as_const(*this).op().is_boolean()
```

## Canonical control

```c
int main(void)
{{
  __CPROVER_cover(1);
  return 0;
}}
```

The canonical control returns normally and reports the coverage goal as
satisfied.

## Scope

This is a robustness/type-handling report, not a solver, ML-KEM, security, or
general canonical-coverage claim.

## Pinned develop commit

`{develop_commit}`
"""
)

print(classification_file.read_text())
PY

  FINAL_DEV_STATUS="$(git -C "$DEV_SOURCE" status --porcelain)"
  echo "FINAL_DEVELOP_STATUS_BEGIN"
  printf '%s\n' "$FINAL_DEV_STATUS"
  echo "FINAL_DEVELOP_STATUS_END"

  [ "$FINAL_DEV_STATUS" = "$INITIAL_DEV_STATUS" ] ||
    fatal "DEVELOP_SOURCE_CHANGED"

  echo
  echo "FROMMSG00D3_TECHNICAL_CAMPAIGN_COMPLETE=YES"
}

set +e
main 2>&1 | tee "$LOG"
MAIN_RC="${PIPESTATUS[0]}"
set -e

sha256sum "$LOG" >"${LOG}.sha256"

echo
echo "MAIN_RETURN_CODE=$MAIN_RC"

if [ "$MAIN_RC" -ne 0 ]; then
  DIAG_MANIFEST="$PACKAGE_DIR/FROMMSG00D3_DIAGNOSTIC_MANIFEST_${STAMP}.txt"
  DIAG_PACKET="$PACKAGE_DIR/FROMMSG00D3_DIAGNOSTIC_${STAMP}.tar.gz"

  find "$STAGE" -type f -print0 |
    sort -z |
    xargs -0 sha256sum >"$DIAG_MANIFEST"

  tar -czf "$DIAG_PACKET" \
    -C "$CAMPAIGN" \
    "$(basename "$STAGE")" \
    -C "$PACKAGE_DIR" \
    "$(basename "$DIAG_MANIFEST")"

  sha256sum "$DIAG_MANIFEST" "$DIAG_PACKET"

  echo "FINAL_PACKET=NOT_CREATED"
  echo "DIAGNOSTIC_PACKET=$DIAG_PACKET"
  exit "$MAIN_RC"
fi

FINAL_MANIFEST="$PACKAGE_DIR/FROMMSG00D3_FINAL_MANIFEST_${STAMP}.txt"
FINAL_PACKET="$PACKAGE_DIR/FROMMSG00D3_PROFESSOR_DECLARATION_FINAL_${STAMP}.tar.gz"
FINAL_LISTING="$PACKAGE_DIR/FROMMSG00D3_ARCHIVE_LIST_${STAMP}.txt"

find "$STAGE" -type f -print0 |
  sort -z |
  xargs -0 sha256sum >"$FINAL_MANIFEST"

tar -czf "$FINAL_PACKET" \
  -C "$CAMPAIGN" \
  "$(basename "$STAGE")" \
  -C "$PACKAGE_DIR" \
  "$(basename "$FINAL_MANIFEST")"

tar -tzf "$FINAL_PACKET" >"$FINAL_LISTING"

python3 - "$FINAL_LISTING" <<'PY'
import pathlib
import sys

listing = pathlib.Path(sys.argv[1])
members = [line.strip() for line in listing.read_text().splitlines() if line.strip()]

unsafe = []
for member in members:
    p = pathlib.PurePosixPath(member)
    if p.is_absolute() or ".." in p.parts:
        unsafe.append(member)

if unsafe:
    raise SystemExit(f"UNSAFE_ARCHIVE_MEMBERS={unsafe!r}")

print(f"ARCHIVE_MEMBER_COUNT={len(members)}")
print("ARCHIVE_PATH_SAFETY=PASS")
PY

sha256sum "$FINAL_MANIFEST" "$FINAL_PACKET" "$FINAL_LISTING"

echo
echo "============================================================"
echo "FINAL PROFESSOR DECLARATION PACKAGE CREATED"
echo "============================================================"
echo "CLASSIFICATION_FILE=$REPORT_DIR/FINAL_SCIENTIFIC_CLASSIFICATION.txt"
echo "PROFESSOR_MEMO=$REPORT_DIR/PROFESSOR_FINDING_MEMO.md"
echo "PROFESSOR_EMAIL=$REPORT_DIR/PROFESSOR_EMAIL_DRAFT.txt"
echo "CBMC_ISSUE_DRAFT=$REPORT_DIR/CBMC_ISSUE_DRAFT.md"
echo "DEVELOP_MATRIX=$MATRIX"
echo "FINAL_PACKET=$FINAL_PACKET"
echo "FINAL_PACKET_SIZE=$(wc -c < "$FINAL_PACKET")"
echo "UPLOAD_ONLY_THIS_FILE=$FINAL_PACKET"
