#!/usr/bin/env bash
set -euo pipefail
umask 077

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B4="${ROOT}/SUB00N_BATCH4_CANONICAL_DOMAIN"

PREREG="${B4}/SUB00N_B4_0_THEOREM_PREREGISTRATION.md"
PREREG_HASH="${PREREG}.sha256"

PARENT_BINDING="${B4}/SUB00N_B4_3_AUTHORITATIVE_PARENT_BINDING.md"
PARENT_BINDING_HASH="${PARENT_BINDING}.sha256"

COMMAND_EXTRACTION="${B4}/SUB00N_B4_3_SUCCESSFUL_COMMAND_EXTRACTION.txt"
COMMAND_EXTRACTION_HASH="${COMMAND_EXTRACTION}.sha256"

SOURCE_POLY="${ROOT}/source/mlkem/src/poly.c"

PARENT_ADAPTER="${ROOT}/sub00f_mode_a_execution_freeze_v1/adapter/sub00e_r1_fail_closed_zeroize.h"
PARENT_PRAGMA="${ROOT}/SUB00G_R2_T1_PRAGMA_SCOPED_PREFLIGHT_MLKEM768/build/sub00g_r2_verify_pragma_scope.h"
PARENT_OPTBLOCKER="${ROOT}/SUB00G_R2_T1_PRAGMA_SCOPED_PREFLIGHT_MLKEM768/build/sub00g_r2_optblocker_zero.c"

FINAL="${B4}/frozen_harness_family_v1"
STAGE="${B4}/.frozen_harness_family_v1.tmp.$$"

HARNESSES="${STAGE}/harnesses"
SUPPORT="${STAGE}/support"

POSITIVE="${HARNESSES}/sub_t4_canonical_domain_harness.c"
COVERAGE="${HARNESSES}/sub_t4_reachability_harness.c"
INVALID_UPPER="${HARNESSES}/sub_t4_invalid_upper_harness.c"
INVALID_LOWER="${HARNESSES}/sub_t4_invalid_lower_harness.c"

ADAPTER="${SUPPORT}/sub00n_b4_fail_closed_zeroize.h"
PRAGMA="${SUPPORT}/sub00n_b4_verify_pragma_scope.h"
OPTBLOCKER="${SUPPORT}/sub00n_b4_optblocker_zero.c"

FREEZE="${STAGE}/SUB00N_B4_4_HARNESS_FAMILY_FREEZE.md"
BUILD_PLAN="${STAGE}/SUB00N_B4_4_BUILD_PLAN.md"
VALIDATION="${STAGE}/SUB00N_B4_4_VALIDATION.txt"
MANIFEST="${STAGE}/SUB00N_B4_4_ARTIFACT_MANIFEST.sha256"

cleanup()
{
    rc=$?
    if [ "${rc}" -ne 0 ] && [ -d "${STAGE}" ]; then
        rm -rf "${STAGE}"
    fi
    exit "${rc}"
}
trap cleanup EXIT

echo "============================================================"
echo "SUB00N / BATCH 4 — B4.4 HARNESS FAMILY FREEZE"
echo "============================================================"
echo "ROOT=${ROOT}"
echo "B4=${B4}"
echo

if [ -e "${FINAL}" ]; then
    echo "ERROR: Frozen Batch-4 harness family already exists."
    echo "Nothing was overwritten:"
    echo "${FINAL}"
    exit 1
fi

if [ -e "${STAGE}" ]; then
    echo "ERROR: Staging directory unexpectedly exists:"
    echo "${STAGE}"
    exit 1
fi

for required in \
    "${PREREG}" \
    "${PREREG_HASH}" \
    "${PARENT_BINDING}" \
    "${PARENT_BINDING_HASH}" \
    "${COMMAND_EXTRACTION}" \
    "${COMMAND_EXTRACTION_HASH}" \
    "${SOURCE_POLY}" \
    "${PARENT_ADAPTER}" \
    "${PARENT_PRAGMA}" \
    "${PARENT_OPTBLOCKER}"
do
    if [ ! -f "${required}" ]; then
        echo "ERROR: Required frozen input missing:"
        echo "${required}"
        exit 1
    fi
done

echo "=== B4.4-A: PARENT INTEGRITY ==="

sha256sum -c "${PREREG_HASH}"
sha256sum -c "${PARENT_BINDING_HASH}"
sha256sum -c "${COMMAND_EXTRACTION_HASH}"

echo "PARENT_INTEGRITY=PASS"
echo

ACTIVE_B4="$(
    pgrep -af \
      '(^|/)(cbmc|goto-cc|goto-clang|goto-instrument)([[:space:]]|.*)(SUB00N|sub_t4|batch4_canonical)' \
      || true
)"

if [ -n "${ACTIVE_B4}" ]; then
    echo "ERROR: Possible Batch-4 verification process is running:"
    printf '%s\n' "${ACTIVE_B4}"
    exit 1
fi

mkdir -p "${HARNESSES}" "${SUPPORT}"

# ------------------------------------------------------------------
# Frozen support inputs
# ------------------------------------------------------------------

cp "${PARENT_ADAPTER}" "${ADAPTER}"
cp "${PARENT_PRAGMA}" "${PRAGMA}"
cp "${PARENT_OPTBLOCKER}" "${OPTBLOCKER}"

# Create Batch-4-local namespace labels while preserving the previously
# validated pragma-scoping design.
sed -i \
    -e 's/mlk_sub00g_r2/mlk_sub00n_b4/g' \
    -e 's/sub00g_r2/sub00n_b4/g' \
    -e 's/SUB00G_R2/SUB00N_B4/g' \
    "${PRAGMA}" "${OPTBLOCKER}"

# ------------------------------------------------------------------
# 1. Positive theorem harness
# ------------------------------------------------------------------

cat > "${POSITIVE}" <<'EOF'
/*
 * SUB-T4 positive theorem:
 *
 * Canonical ML-KEM coefficients imply that production subtraction:
 *
 *   - is automatically representable in int16_t;
 *   - equals the mathematical coefficient-wise difference; and
 *   - lies in the exact interval [-3328, 3328].
 *
 * No direct subtraction-representability assumption is permitted.
 */

#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

extern int16_t nondet_int16_t(void);

static void sub_t4_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T4_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T4_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T4_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T4_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T4_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T4_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T4_MODEL: signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T4_MODEL: negative odd shift must preserve sign");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A0;
  mlk_poly saved_B0;
  mlk_poly R;
  mlk_poly RB;
  mlk_poly RB_before_sub;
  unsigned i;

  sub_t4_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T4_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T4_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = nondet_int16_t();
    B0.coeffs[i] = nondet_int16_t();
  }

  saved_A0 = A0;
  saved_B0 = B0;

  /*
   * These are the only mathematical-domain assumptions.
   *
   * There is intentionally no assumption that A-B is int16_t
   * representable. SUB-T4 must prove that consequence.
   */
  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assume(saved_A0.coeffs[i] >= 0);
    __CPROVER_assume(saved_A0.coeffs[i] < FIPS_Q);
    __CPROVER_assume(saved_B0.coeffs[i] >= 0);
    __CPROVER_assume(saved_B0.coeffs[i] < FIPS_Q);
  }

  R = A0;
  RB = B0;
  RB_before_sub = RB;

  mlk_poly_sub(&R, &RB);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t mathematical_difference;

    mathematical_difference =
        (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];

    __CPROVER_assert(
        mathematical_difference >= (int32_t)INT16_MIN,
        "SUB_T4_REPRESENTABILITY: canonical difference must be above INT16_MIN");

    __CPROVER_assert(
        mathematical_difference <= (int32_t)INT16_MAX,
        "SUB_T4_REPRESENTABILITY: canonical difference must be below INT16_MAX");

    __CPROVER_assert(
        mathematical_difference >= -(int32_t)(FIPS_Q - 1),
        "SUB_T4_RANGE: mathematical difference must be at least -3328");

    __CPROVER_assert(
        mathematical_difference <= (int32_t)(FIPS_Q - 1),
        "SUB_T4_RANGE: mathematical difference must be at most 3328");

    __CPROVER_assert(
        (int32_t)R.coeffs[i] == mathematical_difference,
        "SUB_T4_EXACTNESS: production output must equal mathematical difference");

    __CPROVER_assert(
        R.coeffs[i] >= -(FIPS_Q - 1),
        "SUB_T4_PRODUCTION_RANGE: output must be at least -3328");

    __CPROVER_assert(
        R.coeffs[i] <= FIPS_Q - 1,
        "SUB_T4_PRODUCTION_RANGE: output must be at most 3328");

    __CPROVER_assert(
        RB.coeffs[i] == RB_before_sub.coeffs[i],
        "SUB_T4_FRAME: production subtraction must not modify RB");

    __CPROVER_assert(
        RB.coeffs[i] == saved_B0.coeffs[i],
        "SUB_T4_FRAME: final RB must equal saved B0");

    __CPROVER_assert(
        A0.coeffs[i] == saved_A0.coeffs[i],
        "SUB_T4_FRAME: original A0 must remain unchanged");

    __CPROVER_assert(
        B0.coeffs[i] == saved_B0.coeffs[i],
        "SUB_T4_FRAME: original B0 must remain unchanged");
  }

  return 0;
}
EOF

# ------------------------------------------------------------------
# 2. Reachability harness
# ------------------------------------------------------------------

cat > "${COVERAGE}" <<'EOF'
/*
 * SUB-T4 canonical-domain reachability harness.
 *
 * These are satisfiability controls, not additional theorem claims.
 */

#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

extern int16_t nondet_int16_t(void);

static void sub_t4_cov_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T4_COV_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T4_COV_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T4_COV_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T4_COV_MODEL: pointer width must be 64");
}

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_A0;
  mlk_poly saved_B0;
  mlk_poly R;
  mlk_poly RB;
  unsigned i;
  int has_maximum_positive;
  int has_maximum_negative;
  int has_zero;
  int has_interior_positive;
  int has_interior_negative;

  sub_t4_cov_check_machine_model();

  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T4_COV_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T4_COV_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = nondet_int16_t();
    B0.coeffs[i] = nondet_int16_t();

    __CPROVER_assume(A0.coeffs[i] >= 0);
    __CPROVER_assume(A0.coeffs[i] < FIPS_Q);
    __CPROVER_assume(B0.coeffs[i] >= 0);
    __CPROVER_assume(B0.coeffs[i] < FIPS_Q);
  }

  saved_A0 = A0;
  saved_B0 = B0;
  R = A0;
  RB = B0;

  mlk_poly_sub(&R, &RB);

  has_maximum_positive = 0;
  has_maximum_negative = 0;
  has_zero = 0;
  has_interior_positive = 0;
  has_interior_negative = 0;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)saved_A0.coeffs[i] -
        (int32_t)saved_B0.coeffs[i];

    if (d == (int32_t)(FIPS_Q - 1))
    {
      has_maximum_positive = 1;
    }

    if (d == -(int32_t)(FIPS_Q - 1))
    {
      has_maximum_negative = 1;
    }

    if (d == 0)
    {
      has_zero = 1;
    }

    if (d > 0 && d < (int32_t)(FIPS_Q - 1))
    {
      has_interior_positive = 1;
    }

    if (d < 0 && d > -(int32_t)(FIPS_Q - 1))
    {
      has_interior_negative = 1;
    }

    __CPROVER_assert(
        (int32_t)R.coeffs[i] == d,
        "SUB_T4_COV_EXACTNESS: production output must equal mathematical difference");

    __CPROVER_assert(
        RB.coeffs[i] == saved_B0.coeffs[i],
        "SUB_T4_COV_FRAME: RB must remain unchanged");
  }

  __CPROVER_cover(has_maximum_positive);
  __CPROVER_cover(has_maximum_negative);
  __CPROVER_cover(has_zero);
  __CPROVER_cover(has_interior_positive);
  __CPROVER_cover(has_interior_negative);

  return 0;
}
EOF

# ------------------------------------------------------------------
# 3. Expected-failure upper-bound control
# ------------------------------------------------------------------

cat > "${INVALID_UPPER}" <<'EOF'
/*
 * SUB-T4 negative control B4-NC1.
 *
 * The admissible canonical witness A[0]=3328, B[0]=0 produces 3328.
 * Therefore, the deliberately stricter universal bound <=3327 must fail.
 */

#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_B0;
  mlk_poly R;
  mlk_poly RB;
  unsigned i;

  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T4_NC1_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T4_NC1_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T4_NC1_MODEL: int32_t width must be 32");
  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T4_NC1_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T4_NC1_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = 0;
    B0.coeffs[i] = 0;
  }

  A0.coeffs[0] = (int16_t)(FIPS_Q - 1);
  B0.coeffs[0] = 0;

  R = A0;
  RB = B0;
  saved_B0 = RB;

  mlk_poly_sub(&R, &RB);

  __CPROVER_assert(
      A0.coeffs[0] >= 0 && A0.coeffs[0] < FIPS_Q,
      "SUB_T4_NC1_ADMISSIBILITY: A witness must be canonical");

  __CPROVER_assert(
      B0.coeffs[0] >= 0 && B0.coeffs[0] < FIPS_Q,
      "SUB_T4_NC1_ADMISSIBILITY: B witness must be canonical");

  __CPROVER_assert(
      R.coeffs[0] == (int16_t)(FIPS_Q - 1),
      "SUB_T4_NC1_WITNESS: production output must reach 3328");

  __CPROVER_assert(
      RB.coeffs[0] == saved_B0.coeffs[0],
      "SUB_T4_NC1_FRAME: RB must remain unchanged");

  __CPROVER_assert(
      R.coeffs[0] <= FIPS_Q - 2,
      "SUB_T4_NC1_INTENDED_FAILURE: false stricter upper bound 3327");

  return 0;
}
EOF

# ------------------------------------------------------------------
# 4. Expected-failure lower-bound control
# ------------------------------------------------------------------

cat > "${INVALID_LOWER}" <<'EOF'
/*
 * SUB-T4 negative control B4-NC2.
 *
 * The admissible canonical witness A[0]=0, B[0]=3328 produces -3328.
 * Therefore, the deliberately stricter universal bound >=-3327 must fail.
 */

#include <limits.h>
#include <stdint.h>
#include "poly.h"

#define FIPS_N 256u
#define FIPS_Q 3329

int main(void)
{
  mlk_poly A0;
  mlk_poly B0;
  mlk_poly saved_B0;
  mlk_poly R;
  mlk_poly RB;
  unsigned i;

  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T4_NC2_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T4_NC2_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T4_NC2_MODEL: int32_t width must be 32");
  __CPROVER_assert(MLKEM_N == FIPS_N,
                   "SUB_T4_NC2_PARAMETER: MLKEM_N must equal FIPS_N");
  __CPROVER_assert(MLKEM_Q == FIPS_Q,
                   "SUB_T4_NC2_PARAMETER: MLKEM_Q must equal FIPS_Q");

  for (i = 0u; i < MLKEM_N; i++)
  {
    A0.coeffs[i] = 0;
    B0.coeffs[i] = 0;
  }

  A0.coeffs[0] = 0;
  B0.coeffs[0] = (int16_t)(FIPS_Q - 1);

  R = A0;
  RB = B0;
  saved_B0 = RB;

  mlk_poly_sub(&R, &RB);

  __CPROVER_assert(
      A0.coeffs[0] >= 0 && A0.coeffs[0] < FIPS_Q,
      "SUB_T4_NC2_ADMISSIBILITY: A witness must be canonical");

  __CPROVER_assert(
      B0.coeffs[0] >= 0 && B0.coeffs[0] < FIPS_Q,
      "SUB_T4_NC2_ADMISSIBILITY: B witness must be canonical");

  __CPROVER_assert(
      R.coeffs[0] == -(int16_t)(FIPS_Q - 1),
      "SUB_T4_NC2_WITNESS: production output must reach -3328");

  __CPROVER_assert(
      RB.coeffs[0] == saved_B0.coeffs[0],
      "SUB_T4_NC2_FRAME: RB must remain unchanged");

  __CPROVER_assert(
      R.coeffs[0] >= -(FIPS_Q - 2),
      "SUB_T4_NC2_INTENDED_FAILURE: false stricter lower bound -3327");

  return 0;
}
EOF

# ------------------------------------------------------------------
# Freeze description
# ------------------------------------------------------------------

cat > "${FREEZE}" <<EOF
# SUB00N B4.4 — Frozen SUB-T4 Harness Family

## Campaign root

\`${ROOT}\`

## Frozen commit

\`d9613cf60de3132d32475c102d8c2781d84feb34\`

## Parameter configuration

- \`MLK_CONFIG_PARAMETER_SET=768\`
- \`MLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00n_b4\`
- \`MLK_CONFIG_NO_ASM=1\`
- \`MLK_CONFIG_CUSTOM_ZEROIZE=1\`

## Harnesses

1. \`harnesses/sub_t4_canonical_domain_harness.c\`
   - Positive canonical-domain range and representability theorem.
2. \`harnesses/sub_t4_reachability_harness.c\`
   - Five satisfiability and reachability goals.
3. \`harnesses/sub_t4_invalid_upper_harness.c\`
   - Deliberately false stricter upper bound.
4. \`harnesses/sub_t4_invalid_lower_harness.c\`
   - Deliberately false stricter lower bound.

## Positive-theorem assumption boundary

The positive harness assumes only:

- every A coefficient is in \`[0,3329)\`;
- every B coefficient is in \`[0,3329)\`.

It does not assume that subtraction is representable.

The representability and exact \`[-3328,3328]\` bounds are assertions.

## Production binding

Every harness calls the genuine production \`mlk_poly_sub\` body from:

\`${SOURCE_POLY}\`

No replacement subtraction implementation is present in a harness.

## Support artefacts

The previously validated fail-closed adapter, pragma-scope header and
optimization-blocker source were copied into this package.

The pragma-scope namespace was changed mechanically from
\`mlk_sub00g_r2\` to \`mlk_sub00n_b4\`.

## Execution boundary

At this freeze stage:

- no GOTO model was created;
- no CBMC theorem was executed;
- no coverage command was executed;
- no production source was modified;
- no Batch-3 artefact or process was touched.

Exact reachable loop identifiers and unwindsets will be frozen only
after the four GOTO models are built and inspected.
EOF

cat > "${BUILD_PLAN}" <<EOF
# SUB00N B4.4 — Frozen Build Plan

## Authoritative compiler family

\`goto-cc 6.9.0\`

## Common build configuration

\`\`\`text
-std=c90
-DMLK_CONFIG_PARAMETER_SET=768
-DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00n_b4
-DMLK_CONFIG_NO_ASM=1
-DMLK_CONFIG_CUSTOM_ZEROIZE=1
-include ${ADAPTER}
-include ${PRAGMA}
-I${ROOT}/source/mlkem
-I${ROOT}/source/mlkem/src
<selected Batch-4 harness>
${SOURCE_POLY}
${OPTBLOCKER}
-o <case-specific GOTO output>
\`\`\`

## Model inspection requirement

Each case must separately record:

- exact compiler command;
- compiler exit code;
- GOTO validation;
- symbol table;
- GOTO functions;
- reachable call graph;
- undefined functions;
- reachable loop identifiers;
- property inventory;
- GOTO hash.

## Execution order

1. Positive SUB-T4 theorem.
2. Reachability campaign.
3. Stricter-upper expected-failure control.
4. Stricter-lower expected-failure control.

Negative-control results must never overwrite or compensate for the
positive theorem result.
EOF

# ------------------------------------------------------------------
# Structural validation
# ------------------------------------------------------------------

FAIL=0

{
    echo "============================================================"
    echo "SUB00N / BATCH 4 — B4.4 STRUCTURAL VALIDATION"
    echo "============================================================"
    echo "DATE_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo

    echo "=== V1: FILE PRESENCE ==="

    for file in \
        "${POSITIVE}" \
        "${COVERAGE}" \
        "${INVALID_UPPER}" \
        "${INVALID_LOWER}" \
        "${ADAPTER}" \
        "${PRAGMA}" \
        "${OPTBLOCKER}" \
        "${FREEZE}" \
        "${BUILD_PLAN}"
    do
        if [ -s "${file}" ]; then
            echo "PRESENT=$(basename "${file}")"
        else
            echo "MISSING_OR_EMPTY=${file}"
            FAIL=1
        fi
    done
    echo

    echo "=== V2: POSITIVE-HARNESS DOMAIN ==="

    POS_ASSUME_COUNT="$(
        grep -c '__CPROVER_assume' "${POSITIVE}" || true
    )"

    echo "POSITIVE_ASSUME_LINE_COUNT=${POS_ASSUME_COUNT}"

    if [ "${POS_ASSUME_COUNT}" -eq 4 ]; then
        echo "CANONICAL_ASSUMPTION_COUNT=PASS"
    else
        echo "CANONICAL_ASSUMPTION_COUNT=FAIL"
        FAIL=1
    fi

    if grep -n '__CPROVER_assume.*INT16' "${POSITIVE}"; then
        echo "DIRECT_REPRESENTABILITY_ASSUMPTION=FOUND_FAIL"
        FAIL=1
    else
        echo "DIRECT_REPRESENTABILITY_ASSUMPTION=ABSENT_PASS"
    fi

    if grep -q 'SUB_T4_REPRESENTABILITY' "${POSITIVE}" &&
       grep -q 'SUB_T4_PRODUCTION_RANGE' "${POSITIVE}" &&
       grep -q 'SUB_T4_EXACTNESS' "${POSITIVE}"; then
        echo "PRIMARY_ASSERTION_FAMILIES=PASS"
    else
        echo "PRIMARY_ASSERTION_FAMILIES=FAIL"
        FAIL=1
    fi
    echo

    echo "=== V3: PRODUCTION-BODY CALLS ==="

    for file in \
        "${POSITIVE}" \
        "${COVERAGE}" \
        "${INVALID_UPPER}" \
        "${INVALID_LOWER}"
    do
        CALL_COUNT="$(
            grep -Ec 'mlk_poly_sub[[:space:]]*\(' "${file}" || true
        )"

        echo "$(basename "${file}")_PRODUCTION_SUB_CALLS=${CALL_COUNT}"

        if [ "${CALL_COUNT}" -ne 1 ]; then
            FAIL=1
        fi
    done
    echo

    echo "=== V4: COVERAGE GOALS ==="

    COVER_COUNT="$(
        grep -c '__CPROVER_cover' "${COVERAGE}" || true
    )"

    echo "COVERAGE_GOAL_COUNT=${COVER_COUNT}"

    if [ "${COVER_COUNT}" -eq 5 ]; then
        echo "COVERAGE_GOAL_COUNT_CHECK=PASS"
    else
        echo "COVERAGE_GOAL_COUNT_CHECK=FAIL"
        FAIL=1
    fi

    grep -n '__CPROVER_cover' "${COVERAGE}" || true
    echo

    echo "=== V5: EXPECTED-FAILURE ASSERTIONS ==="

    UPPER_COUNT="$(
        grep -c 'SUB_T4_NC1_INTENDED_FAILURE' "${INVALID_UPPER}" || true
    )"

    LOWER_COUNT="$(
        grep -c 'SUB_T4_NC2_INTENDED_FAILURE' "${INVALID_LOWER}" || true
    )"

    echo "UPPER_INTENDED_FAILURE_ASSERTION_COUNT=${UPPER_COUNT}"
    echo "LOWER_INTENDED_FAILURE_ASSERTION_COUNT=${LOWER_COUNT}"

    if [ "${UPPER_COUNT}" -eq 1 ] &&
       [ "${LOWER_COUNT}" -eq 1 ]; then
        echo "NEGATIVE_CONTROL_ASSERTION_CHECK=PASS"
    else
        echo "NEGATIVE_CONTROL_ASSERTION_CHECK=FAIL"
        FAIL=1
    fi
    echo

    echo "=== V6: SUPPORT NAMESPACE ==="

    if grep -RIn 'mlk_sub00g_r2\|sub00g_r2\|SUB00G_R2' \
        "${PRAGMA}" "${OPTBLOCKER}"; then
        echo "OLD_NAMESPACE_REMAINS=YES_FAIL"
        FAIL=1
    else
        echo "OLD_NAMESPACE_REMAINS=NO_PASS"
    fi

    if grep -RIn 'mlk_sub00n_b4\|sub00n_b4\|SUB00N_B4' \
        "${PRAGMA}" "${OPTBLOCKER}" >/dev/null 2>&1; then
        echo "BATCH4_NAMESPACE_PRESENT=YES"
    else
        echo "BATCH4_NAMESPACE_PRESENT=NO_INFORMATIONAL"
    fi
    echo

    echo "=== V7: PROHIBITED REDUCTION CALL ==="

    if grep -RIn 'mlk_poly_reduce[[:space:]]*(' "${HARNESSES}"; then
        echo "UNEXPECTED_REDUCTION_CALL=FOUND_FAIL"
        FAIL=1
    else
        echo "UNEXPECTED_REDUCTION_CALL=ABSENT_PASS"
    fi
    echo

    echo "=== V8: SOURCE AND PARENT HASHES ==="
    echo "SOURCE_POLY_SHA256=$(sha256sum "${SOURCE_POLY}" | awk '{print $1}')"
    echo "PARENT_ADAPTER_SHA256=$(sha256sum "${PARENT_ADAPTER}" | awk '{print $1}')"
    echo "COPIED_ADAPTER_SHA256=$(sha256sum "${ADAPTER}" | awk '{print $1}')"
    echo "PARENT_PRAGMA_SHA256=$(sha256sum "${PARENT_PRAGMA}" | awk '{print $1}')"
    echo "BATCH4_PRAGMA_SHA256=$(sha256sum "${PRAGMA}" | awk '{print $1}')"
    echo "PARENT_OPTBLOCKER_SHA256=$(sha256sum "${PARENT_OPTBLOCKER}" | awk '{print $1}')"
    echo "BATCH4_OPTBLOCKER_SHA256=$(sha256sum "${OPTBLOCKER}" | awk '{print $1}')"
    echo

    if cmp -s "${PARENT_ADAPTER}" "${ADAPTER}"; then
        echo "FAIL_CLOSED_ADAPTER_BYTE_IDENTICAL=YES"
    else
        echo "FAIL_CLOSED_ADAPTER_BYTE_IDENTICAL=NO_FAIL"
        FAIL=1
    fi
    echo

    echo "=== V9: SCIENTIFIC ACTION RECORD ==="
    echo "CBMC_THEOREM_EXECUTED=NO"
    echo "COVERAGE_EXECUTED=NO"
    echo "GOTO_MODEL_CREATED=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "PARENT_HARNESS_MODIFIED=NO"
    echo "BATCH3_TOUCHED=NO"
    echo "BATCH3_PROCESS_ACTION=NONE"
    echo "SUB_T1_RESULT_MODIFIED=NO"
    echo "SUB_T2_RESULT_MODIFIED=NO"
    echo

    if [ "${FAIL}" -eq 0 ]; then
        echo "SUB00N_B4_4_STRUCTURAL_VALIDATION=PASS"
    else
        echo "SUB00N_B4_4_STRUCTURAL_VALIDATION=FAIL"
    fi
} > "${VALIDATION}"

if [ "${FAIL}" -ne 0 ]; then
    cat "${VALIDATION}"
    echo
    echo "BATCH4_HARNESS_FAMILY_FREEZE_GATE=FAIL"
    exit 1
fi

# Create a manifest covering every frozen file except the manifest itself.
(
    cd "${STAGE}"
    find . -type f \
        ! -name "$(basename "${MANIFEST}")" \
        -print0 |
    sort -z |
    xargs -0 sha256sum
) > "${MANIFEST}"

chmod a-w \
    "${POSITIVE}" \
    "${COVERAGE}" \
    "${INVALID_UPPER}" \
    "${INVALID_LOWER}" \
    "${ADAPTER}" \
    "${PRAGMA}" \
    "${OPTBLOCKER}" \
    "${FREEZE}" \
    "${BUILD_PLAN}" \
    "${VALIDATION}" \
    "${MANIFEST}"

mv "${STAGE}" "${FINAL}"
chmod 0555 "${FINAL}" "${FINAL}/harnesses" "${FINAL}/support"

trap - EXIT

echo "============================================================"
echo "SUB00N / BATCH 4 — B4.4 FROZEN HARNESS FAMILY"
echo "============================================================"
echo "FINAL=${FINAL}"
echo

cat "${FINAL}/SUB00N_B4_4_VALIDATION.txt"

echo
echo "=== FROZEN FILES ==="

find "${FINAL}" -type f -maxdepth 2 -print0 |
sort -z |
xargs -0 stat --printf='MODE=%A SIZE=%s PATH=%n\n'

echo
echo "=== HARNESS SHA-256 ==="

sha256sum \
    "${FINAL}/harnesses/sub_t4_canonical_domain_harness.c" \
    "${FINAL}/harnesses/sub_t4_reachability_harness.c" \
    "${FINAL}/harnesses/sub_t4_invalid_upper_harness.c" \
    "${FINAL}/harnesses/sub_t4_invalid_lower_harness.c"

echo
echo "=== FULL MANIFEST VERIFICATION ==="

(
    cd "${FINAL}"
    sha256sum -c "$(basename "${MANIFEST}")"
)

echo
echo "BATCH4_HARNESS_FAMILY_FREEZE_GATE=PASS"
echo "NO_CBMC_EXECUTION_OCCURRED=YES"
echo "BATCH3_TOUCHED=NO"
