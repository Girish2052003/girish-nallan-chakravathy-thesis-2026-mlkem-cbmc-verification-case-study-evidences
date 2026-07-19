#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

PREREG="${B4}/SUB00N_B4_0_THEOREM_PREREGISTRATION.md"
PREREG_HASH="${PREREG}.sha256"

DISCOVERY="${B4}/SUB00N_B4_0_DISCOVERY_PACKET.txt"
DISCOVERY_HASH="${DISCOVERY}.sha256"
DISCOVERY_TMP="${B4}/.SUB00N_B4_0_DISCOVERY_PACKET.tmp"

echo "============================================================"
echo "SUB00N / BATCH 4 — CANONICAL-DOMAIN FREEZE"
echo "============================================================"
echo "ROOT=${ROOT}"
echo "B4=${B4}"
echo

if [ ! -d "${ROOT}" ]; then
    echo "ERROR: Campaign root does not exist:"
    echo "${ROOT}"
    exit 1
fi

if [ -e "${B4}" ]; then
    echo "ERROR: Batch-4 directory already exists."
    echo "Nothing was overwritten:"
    echo "${B4}"
    exit 1
fi

# This pattern is deliberately restricted to Batch-4 CBMC/GOTO jobs.
# It does not match or interact with Batch 3.
ACTIVE_B4="$(
    pgrep -af \
      '(^|/)(cbmc|goto-cc|goto-clang|goto-instrument)([[:space:]]|.*)(SUB00N|sub_t4|batch4_canonical)' \
      || true
)"

if [ -n "${ACTIVE_B4}" ]; then
    echo "ERROR: A possible Batch-4 verification process is already running:"
    printf '%s\n' "${ACTIVE_B4}"
    exit 1
fi

mkdir "${B4}"

cat > "${PREREG}" <<'EOF'
# SUB00N / BATCH 4 — SUB-T4 Theorem Pre-Registration

## 1. Campaign identity

Repository: mlkem-native

Frozen commit:

    d9613cf60de3132d32475c102d8c2781d84feb34

Target production function:

    mlk_poly_sub

Target implementation family:

    Portable production C

Polynomial parameters independently bound for this experiment:

    FIPS_N = 256
    FIPS_Q = 3329
    coefficient type = int16_t

This batch is isolated from Batch 3. No Batch-3 artefact, process,
result, directory, theorem statement, or execution package may be
modified by Batch 4.

## 2. Scientific role

SUB-T4 is a canonical-domain representability and range theorem.

It is not claimed as a newly discovered mathematical identity.

Its purpose is to connect the canonical ML-KEM coefficient domain to
the lower-level production mlk_poly_sub representability condition.

The theorem is supplementary evidence and must not replace the
co-primary SUB-T1 or SUB-T2 results.

## 3. Frozen input domain

Let A and B be independent valid polynomial objects.

For every coefficient index i:

    0 <= A[i] < FIPS_Q
    0 <= B[i] < FIPS_Q

Because FIPS_Q = 3329, this means:

    0 <= A[i] <= 3328
    0 <= B[i] <= 3328

No separate assumption that A[i] - B[i] fits in int16_t is permitted.

Representability must follow from the canonical-domain assumptions.

## 4. Production execution

Create independent production and snapshot objects:

    R = A
    SAVED_A = A
    SAVED_B = B

Execute the genuine production operation:

    mlk_poly_sub(&R, &B)

No replacement subtraction model may be used for the positive theorem.

No mlk_poly_sub function contract may be used as an abstraction in
the mandatory MODE-A execution.

## 5. Primary SUB-T4 claims

For every coefficient index i, prove:

    R[i] = (int32_t)SAVED_A[i] - (int32_t)SAVED_B[i]

and:

    -(FIPS_Q - 1) <= R[i]
    R[i] <= FIPS_Q - 1

which binds concretely to:

    -3328 <= R[i] <= 3328

Also prove that the mathematical difference is representable in
int16_t:

    INT16_MIN
        <= (int32_t)SAVED_A[i] - (int32_t)SAVED_B[i]
        <= INT16_MAX

The representability result must be a proved consequence rather than
a harness assumption.

## 6. Supporting integrity claims

The Batch-4 positive harness must additionally check:

1. FIPS_N == 256.
2. FIPS_Q == 3329.
3. int16_t has exactly 16 value bits plus sign representation
   consistent with the frozen CBMC model.
4. int32_t has width 32.
5. The source polynomial B is unchanged.
6. The saved snapshots of A and B are unchanged.
7. All relevant loops are fully unwound.
8. Unwinding assertions are enabled.
9. Standard bounds, pointer, arithmetic, shift and conversion checks
   are enabled.
10. No production source file is changed.

These supporting claims are not separate novelty claims.

## 7. Required satisfiability controls

The Batch-4 execution package must show reachable admissible inputs
for at least:

    maximum positive difference:
        A[i] = 3328
        B[i] = 0
        difference = 3328

    maximum negative difference:
        A[i] = 0
        B[i] = 3328
        difference = -3328

    zero difference:
        A[i] = B[i]

    an interior positive difference

    an interior negative difference

Coverage results must be labelled as reachability evidence, not as
additional mathematical theorem proofs.

## 8. Frozen expected-failure controls

### B4-NC1 — Stricter upper bound must fail

The deliberately false universal claim:

    R[i] <= 3327

must be falsifiable by an admissible canonical witness with:

    A[i] = 3328
    B[i] = 0

Expected classification:

    KILLED_BY_UPPER_BOUND_WITNESS

### B4-NC2 — Stricter lower bound must fail

The deliberately false universal claim:

    R[i] >= -3327

must be falsifiable by an admissible canonical witness with:

    A[i] = 0
    B[i] = 3328

Expected classification:

    KILLED_BY_LOWER_BOUND_WITNESS

These negative controls must be isolated from the positive theorem
model and must not modify the successful positive result.

## 9. Prohibited experiment shortcuts

The positive theorem must not:

1. Assume the final range directly.
2. Assume subtraction representability directly.
3. Replace mlk_poly_sub with harness-side arithmetic.
4. use the existing mlk_poly_sub contract as the proof body.
5. disable unwinding assertions.
6. silently use loop-contract abstraction in MODE-A.
7. restrict all coefficients to a few concrete examples.
8. describe SUB-T4 as a world-first mathematical theorem.
9. modify Batch 3.
10. modify the frozen SUB-T1 or SUB-T2 evidence.

## 10. Evidence mode

Mandatory primary evidence:

    MODE-A
    genuine production bodies
    no function-contract abstraction
    no silent loop-contract abstraction
    complete explicit loop execution
    unwinding assertions enabled

Any later MODE-B loop-contract-assisted replication must be labelled
complementary and must not replace MODE-A.

## 11. Novelty wording restriction

Permitted wording:

    canonical-domain representability theorem
    FIPS-domain-to-production-contract bridge
    independently authored CBMC verification artefact
    derived boundary property checked against production C

Prohibited wording:

    newly discovered arithmetic law
    first proof in the world
    completely novel theorem
    no one has ever proved this

## 12. Freeze rule

This preregistered theorem, domain, range, controls and expected
classifications must not be silently changed after hashing.

Any correction requires:

    a new version identifier
    a reason-for-change record
    a new SHA-256 hash
EOF

sha256sum "${PREREG}" > "${PREREG_HASH}"

DISCOVERY_FAIL=0

{
    echo "============================================================"
    echo "SUB00N / BATCH 4 — READ-ONLY BUILD DISCOVERY"
    echo "============================================================"
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "ROOT=${ROOT}"
    echo "B4=${B4}"
    echo

    echo "=== B4.0-A: BATCH-3 ISOLATION DECLARATION ==="
    echo "BATCH3_TOUCHED=NO"
    echo "BATCH3_PROCESS_ACTION=NONE"
    echo "BATCH3_DIRECTORY_ACTION=NONE"
    echo "BATCH3_RESULT_ACTION=NONE"
    echo

    echo "=== B4.0-B: TOOL ENVIRONMENT ==="

    if command -v cbmc >/dev/null 2>&1; then
        echo "CBMC_PATH=$(command -v cbmc)"
        echo "CBMC_VERSION=$(cbmc --version 2>&1 | head -n 1)"
    else
        echo "CBMC_FOUND=NO"
        DISCOVERY_FAIL=1
    fi

    if command -v goto-cc >/dev/null 2>&1; then
        echo "GOTO_CC_PATH=$(command -v goto-cc)"
    elif command -v goto-clang >/dev/null 2>&1; then
        echo "GOTO_CLANG_PATH=$(command -v goto-clang)"
    else
        echo "GOTO_COMPILER_FOUND=NO"
        DISCOVERY_FAIL=1
    fi

    echo "CC_PATH=$(command -v cc 2>/dev/null || echo NOT_FOUND)"
    echo "HOST=$(uname -a)"
    echo

    echo "=== B4.0-C: FROZEN COMMIT REFERENCES ==="

    COMMIT_COUNT="$(
        grep -RIl \
          --exclude-dir=.git \
          --exclude-dir="${B4##*/}" \
          'd9613cf60de3132d32475c102d8c2781d84feb34' \
          "${ROOT}" 2>/dev/null |
        wc -l
    )"

    echo "FILES_REFERENCING_FROZEN_COMMIT=${COMMIT_COUNT}"

    if [ "${COMMIT_COUNT}" -eq 0 ]; then
        echo "FROZEN_COMMIT_REFERENCE=FAIL"
        DISCOVERY_FAIL=1
    else
        echo "FROZEN_COMMIT_REFERENCE=PASS"
    fi
    echo

    echo "=== B4.0-D: PORTABLE POLY.C CANDIDATES ==="

    mapfile -t POLY_C_FILES < <(
        find "${ROOT}" -type f \
          -path '*/mlkem/src/poly.c' \
          ! -path '*/proofs/*' \
          ! -path "${B4}/*" \
          -print |
        sort
    )

    if [ "${#POLY_C_FILES[@]}" -eq 0 ]; then
        echo "POLY_C_FOUND=NO"
        DISCOVERY_FAIL=1
    else
        echo "POLY_C_FOUND=YES"
        printf '%s\n' "${POLY_C_FILES[@]}"
    fi
    echo

    echo "=== B4.0-E: PRODUCTION FUNCTION LOCATIONS ==="

    if [ "${#POLY_C_FILES[@]}" -gt 0 ]; then
        for f in "${POLY_C_FILES[@]}"; do
            echo
            echo "--- FILE: ${f}"
            grep -n -A18 -B6 \
              'mlk_poly_sub' "${f}" |
              head -n 80 || true
        done
    else
        echo "FUNCTION_LOCATION_UNAVAILABLE=YES"
    fi
    echo

    echo "=== B4.0-F: FROZEN HARNESS CANDIDATES ==="

    mapfile -t HARNESS_FILES < <(
        find "${ROOT}" -type f \
          \( -name 'sub_t1_semantic_harness.c' \
             -o -name 'sub_t2_relational_harness.c' \) \
          ! -path "${B4}/*" \
          -print |
        sort
    )

    if [ "${#HARNESS_FILES[@]}" -eq 0 ]; then
        echo "REFERENCE_HARNESSES_FOUND=NO"
        DISCOVERY_FAIL=1
    else
        echo "REFERENCE_HARNESSES_FOUND=YES"
        for f in "${HARNESS_FILES[@]}"; do
            stat --printf='MODE=%A SIZE=%s PATH=%n\n' "${f}"
            sha256sum "${f}"
        done
    fi
    echo

    echo "=== B4.0-G: HARNESS STRUCTURE EXCERPTS ==="

    if [ "${#HARNESS_FILES[@]}" -gt 0 ]; then
        for f in "${HARNESS_FILES[@]}"; do
            echo
            echo "--- FILE: ${f}"
            grep -nE \
              '^[[:space:]]*#include|__CPROVER_|mlk_poly_sub|mlk_poly_reduce|MLKEM_N|MLKEM_Q|FIPS_N|FIPS_Q|int main|void harness' \
              "${f}" |
              head -n 120 || true
        done
    fi
    echo

    echo "=== B4.0-H: MODE-A MANIFEST CANDIDATES ==="

    mapfile -t MODE_A_FILES < <(
        find "${ROOT}" -type f \
          \( -name 'SUB00F_MODE_A_EXECUTION_MANIFEST.md' \
             -o -iname '*MODE*A*EXECUTION*MANIFEST*' \) \
          ! -path "${B4}/*" \
          -print |
        sort -u
    )

    if [ "${#MODE_A_FILES[@]}" -eq 0 ]; then
        echo "MODE_A_MANIFEST_FOUND=NO"
        DISCOVERY_FAIL=1
    else
        echo "MODE_A_MANIFEST_FOUND=YES"
        for f in "${MODE_A_FILES[@]}"; do
            stat --printf='MODE=%A SIZE=%s PATH=%n\n' "${f}"
            sha256sum "${f}"
        done
    fi
    echo

    echo "=== B4.0-I: PRIOR MODE-A COMMAND EXCERPTS ==="

    grep -RInE \
      --exclude-dir=.git \
      --exclude-dir=proofs \
      --exclude-dir="${B4##*/}" \
      --include='*.sh' \
      --include='*.txt' \
      --include='*.md' \
      'goto-cc|goto-clang|goto-instrument|(^|[[:space:]])cbmc([[:space:]]|$)|--function|--unwind|--unwindset|--unwinding-assertions|--conversion-check|--signed-overflow-check' \
      "${ROOT}" 2>/dev/null |
      grep -Ei \
        'SUB00F|MODE.?A|SUB.?T1|sub_t1|semantic' |
      head -n 160 || true

    echo

    echo "=== B4.0-J: PREREGISTRATION INTEGRITY ==="
    cat "${PREREG_HASH}"

    if sha256sum -c "${PREREG_HASH}"; then
        echo "PREREGISTRATION_HASH_CHECK=PASS"
    else
        echo "PREREGISTRATION_HASH_CHECK=FAIL"
        DISCOVERY_FAIL=1
    fi

    echo
    echo "=== B4.0-K: SCIENTIFIC ACTION RECORD ==="
    echo "CBMC_THEOREM_EXECUTED=NO"
    echo "GOTO_MODEL_CREATED=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "EXISTING_HARNESS_MODIFIED=NO"
    echo "BATCH3_MODIFIED=NO"
    echo "SUB_T1_RESULT_MODIFIED=NO"
    echo "SUB_T2_RESULT_MODIFIED=NO"
    echo

    if [ "${DISCOVERY_FAIL}" -eq 0 ]; then
        echo "SUB00N_B4_0_DISCOVERY_VERDICT=PASS"
    else
        echo "SUB00N_B4_0_DISCOVERY_VERDICT=FAIL"
    fi
} > "${DISCOVERY_TMP}" 2>&1

mv "${DISCOVERY_TMP}" "${DISCOVERY}"
sha256sum "${DISCOVERY}" > "${DISCOVERY_HASH}"

chmod a-w \
    "${PREREG}" \
    "${PREREG_HASH}" \
    "${DISCOVERY}" \
    "${DISCOVERY_HASH}"

cat "${DISCOVERY}"

echo
echo "============================================================"
echo "SUB00N / BATCH 4 — CREATED ARTEFACTS"
echo "============================================================"
stat --printf='MODE=%A SIZE=%s PATH=%n\n' \
    "${PREREG}" \
    "${PREREG_HASH}" \
    "${DISCOVERY}" \
    "${DISCOVERY_HASH}"

echo
echo "=== SHA-256 ==="
cat "${PREREG_HASH}"
cat "${DISCOVERY_HASH}"

echo
if [ "${DISCOVERY_FAIL}" -eq 0 ]; then
    echo "BATCH4_FREEZE_GATE=PASS"
    echo "NO_CBMC_EXECUTION_OCCURRED=YES"
    exit 0
else
    echo "BATCH4_FREEZE_GATE=FAIL"
    echo "NO_CBMC_EXECUTION_OCCURRED=YES"
    exit 1
fi
