#!/usr/bin/env bash
set -euo pipefail
umask 0022

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
B5="$ROOT/SUB00Q_BATCH5_T5_RELATIONAL"
B6="$ROOT/SUB00R_BATCH6_T6_CALLSITE_INTEGRATION"
SRC="$ROOT/source/mlkem"

PREREG="$B6/00_PREREGISTRATION/SUB_T6_B6_0_PREREGISTRATION.json"
BIND="$B6/01_CALLCHAIN_BINDING/B6_1_BINDING.json"
ASSUME="$B6/02_ASSUMPTION_AUDIT/B6_2_ASSUMPTION_AUDIT.json"

B5_FAMILY="$B5/frozen_harness_family_v1"
FAMILY_PARENT="$B6/03_HARNESS_FREEZE"
FAMILY="$FAMILY_PARENT/frozen_harness_family_v1"

PREFLIGHT_PARENT="$B6/04_GOTO_PREFLIGHT"
PREFLIGHT="$PREFLIGHT_PARENT/B6_4_GOTO_PREFLIGHT_MLKEM768"

PACKAGE="$HOME/Downloads/SUB_T6_B6_3_4_HARNESS_GOTO_PREFLIGHT.tar.gz"

EXPECTED_POLYC_SHA="f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
EXPECTED_POLYH_SHA="f24f980110953c1d361e04137e13e2f85f76db776903f85c98f24900e85f7aef"
EXPECTED_COMPRESSC_SHA="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESSH_SHA="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"

echo "============================================================"
echo "SUB-T6 COMBINED B6.3 HARNESS FREEZE + B6.4 GOTO PREFLIGHT"
echo "============================================================"
echo "DATE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "ROOT=$ROOT"
echo "B5_FAMILY=$B5_FAMILY"
echo "FAMILY=$FAMILY"
echo "PREFLIGHT=$PREFLIGHT"
echo "PACKAGE=$PACKAGE"

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

SUCCESS=0
FAMILY_FROZEN=0

cleanup()
{
    rc=$?

    if [ "$SUCCESS" -ne 1 ]; then
        stamp="$(date -u +%Y%m%dT%H%M%SZ)"

        if [ -d "$PREFLIGHT" ]; then
            chmod -R u+rwX "$PREFLIGHT" 2>/dev/null || true
            failed_preflight="${PREFLIGHT}_FAILED_${stamp}"
            mv "$PREFLIGHT" "$failed_preflight" 2>/dev/null || true
            echo "FAILED_PREFLIGHT_PRESERVED=$failed_preflight" >&2
        fi

        if [ -d "$FAMILY" ] && [ "$FAMILY_FROZEN" -ne 1 ]; then
            chmod -R u+rwX "$FAMILY" 2>/dev/null || true
            failed_family="${FAMILY}_FAILED_${stamp}"
            mv "$FAMILY" "$failed_family" 2>/dev/null || true
            echo "FAILED_FAMILY_PRESERVED=$failed_family" >&2
        fi
    fi

    exit "$rc"
}
trap cleanup EXIT

for path in \
    "$ROOT" "$B5" "$B6" "$SRC" "$B5_FAMILY" \
    "$FAMILY_PARENT" "$PREFLIGHT_PARENT"
do
    [ -d "$path" ] || die "required directory missing: $path"
done

for file in "$PREREG" "$BIND" "$ASSUME"; do
    [ -f "$file" ] || die "frozen control missing: $file"
    python3 -m json.tool "$file" >/dev/null
    grep -F '"status": "FROZEN"' "$file" >/dev/null ||
        die "control is not frozen: $file"
done

[ ! -e "$FAMILY" ] || die "B6.3 family already exists: $FAMILY"
[ ! -e "$PREFLIGHT" ] || die "B6.4 preflight already exists: $PREFLIGHT"
[ ! -e "$PACKAGE" ] || die "output package already exists: $PACKAGE"

for tool in \
    sha256sum goto-cc goto-instrument cbmc gcc python3 \
    awk grep sed find sort wc readlink tar
do
    command -v "$tool" >/dev/null 2>&1 ||
        die "required tool missing: $tool"
done

CBMC_VERSION="$(cbmc --version | sed -n '1p')"
GOTOCC_VERSION="$(goto-cc --version 2>&1 | sed -n '1p')"
GOTOINSTRUMENT_VERSION="$(goto-instrument --version 2>&1 | sed -n '1p')"

echo "$CBMC_VERSION" | grep -q '6\.9\.0' ||
    die "CBMC is not frozen version 6.9.0"
echo "$GOTOCC_VERSION" | grep -q '6\.9\.0' ||
    die "goto-cc is not frozen version 6.9.0"
echo "$GOTOINSTRUMENT_VERSION" | grep -q '6\.9\.0' ||
    die "goto-instrument is not frozen version 6.9.0"

for pair in \
    "$SRC/src/poly.c:$EXPECTED_POLYC_SHA" \
    "$SRC/src/poly.h:$EXPECTED_POLYH_SHA" \
    "$SRC/src/compress.c:$EXPECTED_COMPRESSC_SHA" \
    "$SRC/src/compress.h:$EXPECTED_COMPRESSH_SHA"
do
    file="${pair%%:*}"
    expected="${pair#*:}"
    [ -f "$file" ] || die "source file missing: $file"
    actual="$(sha256sum "$file" | awk '{print $1}')"
    [ "$actual" = "$expected" ] ||
        die "source hash mismatch: $file"
done

echo
echo "--- Validating exact Batch-5 build infrastructure ---"
(
    cd "$B5_FAMILY"
    sha256sum -c SUB00Q_B5_2_ARTIFACT_MANIFEST.sha256
    bash scripts/validate_frozen_family.sh
)

B5_OPTBLOCKER="$B5_FAMILY/support/sub00q_b5_optblocker_zero.c"
[ -f "$B5_OPTBLOCKER" ] ||
    die "validated Batch-5 opt-blocker support source missing"

mkdir -p "$FAMILY/harnesses" "$FAMILY/support" "$FAMILY/scripts"

cat > "$FAMILY/support/sub00r_b6_harness_common.h" <<'EOF'
#ifndef SUB00R_B6_HARNESS_COMMON_H
#define SUB00R_B6_HARNESS_COMMON_H

#include <limits.h>
#include <stdint.h>
#include "poly.h"
#include "compress.h"

#define SUB_T6_FIPS_N 256u
#define SUB_T6_FIPS_Q 3329
#define SUB_T6_INVNTT_BOUND (8 * SUB_T6_FIPS_Q)

extern int16_t nondet_int16_t(void);

static void sub_t6_check_machine_model(void)
{
  __CPROVER_assert(CHAR_BIT == 8,
                   "SUB_T6_MODEL: CHAR_BIT must be 8");
  __CPROVER_assert(sizeof(short) * CHAR_BIT == 16u,
                   "SUB_T6_MODEL: short width must be 16");
  __CPROVER_assert(sizeof(int) * CHAR_BIT == 32u,
                   "SUB_T6_MODEL: int width must be 32");
  __CPROVER_assert(sizeof(int16_t) * CHAR_BIT == 16u,
                   "SUB_T6_MODEL: int16_t width must be 16");
  __CPROVER_assert(sizeof(int32_t) * CHAR_BIT == 32u,
                   "SUB_T6_MODEL: int32_t width must be 32");
  __CPROVER_assert(sizeof(void *) * CHAR_BIT == 64u,
                   "SUB_T6_MODEL: pointer width must be 64");
  __CPROVER_assert(((int32_t)-1 >> 1) == (int32_t)-1,
                   "SUB_T6_MODEL: signed right shift must be arithmetic");
  __CPROVER_assert(((int32_t)-3 >> 1) == (int32_t)-2,
                   "SUB_T6_MODEL: negative odd shift must preserve sign");
  __CPROVER_assert(MLKEM_N == SUB_T6_FIPS_N,
                   "SUB_T6_PARAMETER: MLKEM_N must equal 256");
  __CPROVER_assert(MLKEM_Q == SUB_T6_FIPS_Q,
                   "SUB_T6_PARAMETER: MLKEM_Q must equal 3329");
  __CPROVER_assert(MLK_INVNTT_BOUND == SUB_T6_INVNTT_BOUND,
                   "SUB_T6_PARAMETER: inverse-NTT bound must equal 26632");
}

static void sub_t6_assume_callsite_inputs(mlk_poly *v, mlk_poly *sb)
{
  unsigned i;

  for (i = 0u; i < MLKEM_N; i++)
  {
    v->coeffs[i] = nondet_int16_t();
    sb->coeffs[i] = nondet_int16_t();

    __CPROVER_assume(v->coeffs[i] >= 0);
    __CPROVER_assume(v->coeffs[i] < SUB_T6_FIPS_Q);
    __CPROVER_assume(sb->coeffs[i] > -SUB_T6_INVNTT_BOUND);
    __CPROVER_assume(sb->coeffs[i] < SUB_T6_INVNTT_BOUND);
  }
}

#endif /* SUB00R_B6_HARNESS_COMMON_H */
EOF

cat > "$FAMILY/support/sub00r_b6_fail_closed_zeroize.h" <<'EOF'
#ifndef SUB00R_B6_FAIL_CLOSED_ZEROIZE_H
#define SUB00R_B6_FAIL_CLOSED_ZEROIZE_H

#include <stddef.h>

static void mlk_zeroize(void *ptr, size_t len)
{
  (void)ptr;
  (void)len;
  __CPROVER_assert(
      0,
      "SUB_T6_ADAPTER: mlk_zeroize must be unreachable from this slice");
}

#endif /* SUB00R_B6_FAIL_CLOSED_ZEROIZE_H */
EOF

cat > "$FAMILY/support/sub00r_b6_verify_pragma_scope.h" <<'EOF'
#ifndef SUB00R_B6_VERIFY_PRAGMA_SCOPE_H
#define SUB00R_B6_VERIFY_PRAGMA_SCOPE_H

#ifdef CBMC
#error "SUB00R B6 requires CBMC to be initially undefined"
#endif

#include "common.h"
#include "cbmc.h"

#define CBMC 1
#include "verify.h"
#undef CBMC

#endif /* SUB00R_B6_VERIFY_PRAGMA_SCOPE_H */
EOF

cp "$B5_OPTBLOCKER" "$FAMILY/support/sub00r_b6_optblocker_zero.c"

cat > "$FAMILY/harnesses/sub_t6_callsite_precondition_harness.c" <<'EOF'
/* SUB-T6 positive harness: T6.1 and T6.2. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  unsigned i;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  __CPROVER_assert((void *)&v != (void *)&sb,
                   "SUB_T6_T6_1: v and sb must be distinct objects");
  __CPROVER_assert(sizeof(v) == sizeof(mlk_poly),
                   "SUB_T6_T6_1: v must be a complete polynomial object");
  __CPROVER_assert(sizeof(sb) == sizeof(mlk_poly),
                   "SUB_T6_T6_1: sb must be a complete polynomial object");

  v_before = v;
  sb_before = sb;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)v_before.coeffs[i] -
        (int32_t)sb_before.coeffs[i];

    __CPROVER_assert(d >= INT16_MIN,
                     "SUB_T6_T6_2_LOWER: subtraction must fit int16_t");
    __CPROVER_assert(d <= INT16_MAX,
                     "SUB_T6_T6_2_UPPER: subtraction must fit int16_t");
  }

  mlk_poly_sub(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t d;

    d = (int32_t)v_before.coeffs[i] -
        (int32_t)sb_before.coeffs[i];

    __CPROVER_assert((int32_t)v.coeffs[i] == d,
                     "SUB_T6_T6_2_ANCHOR: actual call must realize derived subtraction");
  }

  return 0;
}
EOF

cat > "$FAMILY/harnesses/sub_t6_callsite_exactness_harness.c" <<'EOF'
/* SUB-T6 positive harness: T6.3. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  unsigned i;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  v_before = v;
  sb_before = sb;

  mlk_poly_sub(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert(
        (int32_t)v.coeffs[i] == expected,
        "SUB_T6_T6_3: production result must equal widened caller-domain subtraction");
  }

  return 0;
}
EOF

cat > "$FAMILY/harnesses/sub_t6_callsite_frame_harness.c" <<'EOF'
/* SUB-T6 positive harness: T6.4. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  mlk_poly sb_witness;
  mlk_poly guard;
  mlk_poly guard_before;
  unsigned i;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    guard.coeffs[i] = (int16_t)(255 - (int)i);
  }

  v_before = v;
  sb_before = sb;
  sb_witness = sb_before;
  guard_before = guard;

  mlk_poly_sub(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert((int32_t)v.coeffs[i] == expected,
                     "SUB_T6_T6_4_ANCHOR: production subtraction must be exact");
    __CPROVER_assert(sb.coeffs[i] == sb_before.coeffs[i],
                     "SUB_T6_T6_4_SB: source sb must remain unchanged");
    __CPROVER_assert(sb_before.coeffs[i] == sb_witness.coeffs[i],
                     "SUB_T6_T6_4_SNAPSHOT: saved sb snapshot must remain unchanged");
    __CPROVER_assert(guard.coeffs[i] == guard_before.coeffs[i],
                     "SUB_T6_T6_4_GUARD: unrelated caller-owned guard must remain unchanged");
  }

  return 0;
}
EOF

cat > "$FAMILY/harnesses/sub_t6_sub_reduce_handoff_harness.c" <<'EOF'
/* SUB-T6 positive harness: T6.5. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  mlk_poly sub_result;
  unsigned i;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  v_before = v;
  sb_before = sb;

  mlk_poly_sub(&v, &sb);
  sub_result = v;

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert((int32_t)sub_result.coeffs[i] == expected,
                     "SUB_T6_T6_5_SUB: handoff input must be the exact subtraction");
  }

  mlk_poly_reduce(&v);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(v.coeffs[i] >= 0,
                     "SUB_T6_T6_5_REDUCE_LOWER: reduction output must be nonnegative");
    __CPROVER_assert(v.coeffs[i] < SUB_T6_FIPS_Q,
                     "SUB_T6_T6_5_REDUCE_UPPER: reduction output must be below q");
  }

  return 0;
}
EOF

cat > "$FAMILY/harnesses/sub_t6_tomsg_precondition_harness.c" <<'EOF'
/* SUB-T6 positive harness: T6.6 and T6.7 slice boundary. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  mlk_poly reduced_before_tomsg;
  uint8_t message[MLKEM_INDCPA_MSGBYTES];
  unsigned i;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  v_before = v;
  sb_before = sb;

  mlk_poly_sub(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert((int32_t)v.coeffs[i] == expected,
                     "SUB_T6_T6_6_SUB_ANCHOR: subtraction before reduction must be exact");
  }

  mlk_poly_reduce(&v);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(v.coeffs[i] >= 0,
                     "SUB_T6_T6_6_PRE_LOWER: tomsg input must be nonnegative");
    __CPROVER_assert(v.coeffs[i] < SUB_T6_FIPS_Q,
                     "SUB_T6_T6_6_PRE_UPPER: tomsg input must be below q");
  }

  reduced_before_tomsg = v;
  mlk_poly_tomsg(message, &v);

  for (i = 0u; i < MLKEM_N; i++)
  {
    __CPROVER_assert(v.coeffs[i] == reduced_before_tomsg.coeffs[i],
                     "SUB_T6_T6_6_CONST_INPUT: tomsg must preserve its polynomial input");
  }

  return 0;
}
EOF

cat > "$FAMILY/scripts/validate_frozen_family.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

FAMILY="$(cd "$(dirname "$0")/.." && pwd)"
H="$FAMILY/harnesses"
S="$FAMILY/support"

EXPECTED_HARNESS_COUNT=5

count="$(find "$H" -maxdepth 1 -type f -name '*.c' | wc -l)"
[ "$count" -eq "$EXPECTED_HARNESS_COUNT" ]

[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_callsite_precondition_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_callsite_exactness_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_callsite_frame_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_sub_reduce_handoff_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_sub(&v, &sb);' "$H/sub_t6_tomsg_precondition_harness.c")" -eq 1 ]

[ "$(grep -c 'mlk_poly_reduce(&v);' "$H/sub_t6_sub_reduce_handoff_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_reduce(&v);' "$H/sub_t6_tomsg_precondition_harness.c")" -eq 1 ]
[ "$(grep -c 'mlk_poly_tomsg(message, &v);' "$H/sub_t6_tomsg_precondition_harness.c")" -eq 1 ]

if grep -RInE '__CPROVER_assume[[:space:]]*\([[:space:]]*(0|false)' "$FAMILY"; then
    echo "ERROR: false assumption detected"
    exit 1
fi

if grep -RInE '__CPROVER_assume\([^;]*(INT16_MIN|INT16_MAX)' "$FAMILY"; then
    echo "ERROR: representability assumption detected"
    exit 1
fi

if grep -RInE 'void[[:space:]]+mlk_poly_(sub|reduce|tomsg)[[:space:]]*\(' "$H"; then
    echo "ERROR: local production-function replacement detected"
    exit 1
fi

if grep -RInF 'r->coeffs[i] = (int16_t)(r->coeffs[i] - b->coeffs[i])' "$H"; then
    echo "ERROR: copied production subtraction body detected"
    exit 1
fi

grep -q 'SUB_T6_T6_1' "$H/sub_t6_callsite_precondition_harness.c"
grep -q 'SUB_T6_T6_2' "$H/sub_t6_callsite_precondition_harness.c"
grep -q 'SUB_T6_T6_3' "$H/sub_t6_callsite_exactness_harness.c"
grep -q 'SUB_T6_T6_4' "$H/sub_t6_callsite_frame_harness.c"
grep -q 'SUB_T6_T6_5' "$H/sub_t6_sub_reduce_handoff_harness.c"
grep -q 'SUB_T6_T6_6' "$H/sub_t6_tomsg_precondition_harness.c"

test -f "$S/sub00r_b6_fail_closed_zeroize.h"
test -f "$S/sub00r_b6_verify_pragma_scope.h"
test -f "$S/sub00r_b6_optblocker_zero.c"
test -f "$S/sub00r_b6_harness_common.h"

echo "HARNESS_COUNT=$count"
echo "TARGET_CALL_STRUCTURE=PASS"
echo "POSITIVE_ASSUMPTION_AUDIT=PASS"
echo "NO_LOCAL_PRODUCTION_REPLACEMENT=PASS"
echo "NO_COPIED_PRODUCTION_BODY=PASS"
echo "PROPERTY_LABEL_COVERAGE=PASS"
echo "STATIC_VALIDATION=PASS"
EOF
chmod 0755 "$FAMILY/scripts/validate_frozen_family.sh"

cat > "$FAMILY/SUB_T6_B6_3_HARNESS_FAMILY_FREEZE.md" <<EOF
# SUB-T6 B6.3 — Frozen Call-Site Integration Harness Family

## Status

FROZEN after static validation.

## Positive harnesses

1. sub_t6_callsite_precondition_harness.c — T6.1 and T6.2.
2. sub_t6_callsite_exactness_harness.c — T6.3.
3. sub_t6_callsite_frame_harness.c — T6.4.
4. sub_t6_sub_reduce_handoff_harness.c — T6.5.
5. sub_t6_tomsg_precondition_harness.c — T6.6 and the T6.7 slice boundary.

## Exact production functions

- mlk_poly_sub from frozen source/mlkem/src/poly.c.
- mlk_poly_reduce from frozen source/mlkem/src/poly.c.
- mlk_poly_tomsg from frozen source/mlkem/src/compress.c.

## Domain model

- 0 <= v[i] < 3329.
- -26632 < sb[i] < 26632.
- Signed-16 representability is asserted after widened subtraction; it is not assumed.
- Complete distinct automatic objects instantiate the successful allocation path.
- Allocator correctness and out-of-memory behavior are not proved.

## Support provenance

The zero opt-blocker support translation unit is copied byte-for-byte from the
validated frozen Batch-5 family. Its source and copied hashes are recorded.
The Batch-6 common, pragma and fail-closed zeroize support files are new
Batch-6 artefacts.

## Boundary

This family contains no modified production source and is not CBMC proof
evidence. GOTO construction and model inspection occur in B6.4.
EOF

cat > "$FAMILY/SUB_T6_B6_3_BUILD_PLAN.md" <<EOF
# SUB-T6 B6.3 — Frozen Build Plan

Toolchain: goto-cc 6.9.0
Language mode: C90
Parameter set: ML-KEM-768
Namespace prefix: mlk_sub00r_b6
Assembly: disabled
Zeroization model: fail closed

Cases 1–4 compile the selected harness, poly.c and the validated zero
opt-blocker support source. The tomsg case additionally compiles compress.c.

Each case is linked into a separate GOTO binary. B6.4 derives loop IDs from
the constructed model and inventories properties without running proof solving.
EOF

{
    echo "B5_OPTBLOCKER_SOURCE=$B5_OPTBLOCKER"
    echo "B5_OPTBLOCKER_SHA256=$(sha256sum "$B5_OPTBLOCKER" | awk '{print $1}')"
    echo "B6_OPTBLOCKER_COPY=$FAMILY/support/sub00r_b6_optblocker_zero.c"
    echo "B6_OPTBLOCKER_SHA256=$(sha256sum "$FAMILY/support/sub00r_b6_optblocker_zero.c" | awk '{print $1}')"
} > "$FAMILY/SUB_T6_B6_3_SUPPORT_PROVENANCE.txt"

B5_OPT_SHA="$(sha256sum "$B5_OPTBLOCKER" | awk '{print $1}')"
B6_OPT_SHA="$(sha256sum "$FAMILY/support/sub00r_b6_optblocker_zero.c" | awk '{print $1}')"
[ "$B5_OPT_SHA" = "$B6_OPT_SHA" ] ||
    die "copied opt-blocker source differs from validated Batch-5 source"

bash "$FAMILY/scripts/validate_frozen_family.sh"

(
    cd "$FAMILY"
    find . -type f \
        ! -name 'SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256' \
        -print0 |
    sort -z |
    xargs -0 sha256sum > SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256
    sha256sum -c SUB_T6_B6_3_ARTIFACT_MANIFEST.sha256
)

find "$FAMILY" -type f -exec chmod 0444 {} +
chmod 0555 "$FAMILY/scripts/validate_frozen_family.sh"
find "$FAMILY" -type d -exec chmod 0555 {} +
FAMILY_FROZEN=1

echo
echo "B6_3_HARNESS_FAMILY_FROZEN=YES"

mkdir -p \
    "$PREFLIGHT/build" \
    "$PREFLIGHT/commands" \
    "$PREFLIGHT/logs" \
    "$PREFLIGHT/inspection" \
    "$PREFLIGHT/exit_codes"

RUNNER_PATH="$(readlink -f "$0")"
cp "$RUNNER_PATH" "$PREFLIGHT/executed_runner.sh"

CASES=(
    "callsite_precondition"
    "callsite_exactness"
    "callsite_frame"
    "sub_reduce_handoff"
    "tomsg_precondition"
)

HARNESSES=(
    "sub_t6_callsite_precondition_harness.c"
    "sub_t6_callsite_exactness_harness.c"
    "sub_t6_callsite_frame_harness.c"
    "sub_t6_sub_reduce_handoff_harness.c"
    "sub_t6_tomsg_precondition_harness.c"
)

NEEDS_REDUCE=(
    "no"
    "no"
    "no"
    "yes"
    "yes"
)

NEEDS_TOMSG=(
    "no"
    "no"
    "no"
    "no"
    "yes"
)

SUMMARY="$PREFLIGHT/SUB_T6_B6_4_PREFLIGHT_SUMMARY.txt"
FREEZE="$PREFLIGHT/SUB_T6_B6_4_EXECUTION_INPUT_FREEZE.md"
MANIFEST="$PREFLIGHT/SUB_T6_B6_4_ARTIFACT_MANIFEST.sha256"

cat > "$FREEZE" <<EOF
# SUB-T6 B6.4 — Execution Input Freeze

Captured UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)

Source root: $SRC
poly.c SHA-256: $EXPECTED_POLYC_SHA
poly.h SHA-256: $EXPECTED_POLYH_SHA
compress.c SHA-256: $EXPECTED_COMPRESSC_SHA
compress.h SHA-256: $EXPECTED_COMPRESSH_SHA

Harness root: $FAMILY
Harness count: 5

CBMC: $CBMC_VERSION
goto-cc: $GOTOCC_VERSION
goto-instrument: $GOTOINSTRUMENT_VERSION

This stage constructs and inspects GOTO binaries and inventories properties.
It does not execute positive proof solving, reachability proof solving,
expected-failure controls, or mutations.
EOF

printf '%s\n' \
    "SUB-T6 B6.4 GOTO PREFLIGHT SUMMARY" \
    "" \
    "CAPTURED_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "CBMC_VERSION=$CBMC_VERSION" \
    "GOTOCC_VERSION=$GOTOCC_VERSION" \
    "GOTOINSTRUMENT_VERSION=$GOTOINSTRUMENT_VERSION" \
    "POLYC_SHA256=$EXPECTED_POLYC_SHA" \
    "POLYH_SHA256=$EXPECTED_POLYH_SHA" \
    "COMPRESSC_SHA256=$EXPECTED_COMPRESSC_SHA" \
    "COMPRESSH_SHA256=$EXPECTED_COMPRESSH_SHA" \
    "" \
    "CASE|GOTO_SHA256|LOOP_IDS|UNWINDSET|PROPERTY_COUNT" \
    > "$SUMMARY"

for idx in "${!CASES[@]}"
do
    case_name="${CASES[$idx]}"
    harness_name="${HARNESSES[$idx]}"
    need_reduce="${NEEDS_REDUCE[$idx]}"
    need_tomsg="${NEEDS_TOMSG[$idx]}"

    harness="$FAMILY/harnesses/$harness_name"
    goto_file="$PREFLIGHT/build/${case_name}.goto"
    command_file="$PREFLIGHT/commands/${case_name}_goto_build_command.txt"
    stdout_file="$PREFLIGHT/logs/${case_name}_goto_build_stdout.txt"
    stderr_file="$PREFLIGHT/logs/${case_name}_goto_build_stderr.txt"
    exit_file="$PREFLIGHT/exit_codes/${case_name}_goto_build_exit_code.txt"

    [ -f "$harness" ] || die "harness missing: $harness"

    cmd=(
        goto-cc
        -std=c90
        -DMLK_CONFIG_PARAMETER_SET=768
        -DMLK_CONFIG_NAMESPACE_PREFIX=mlk_sub00r_b6
        -DMLK_CONFIG_NO_ASM=1
        -DMLK_CONFIG_CUSTOM_ZEROIZE=1
        -include "$FAMILY/support/sub00r_b6_fail_closed_zeroize.h"
        -include "$FAMILY/support/sub00r_b6_verify_pragma_scope.h"
        -I"$SRC"
        -I"$SRC/src"
        -I"$FAMILY/support"
        "$harness"
        "$SRC/src/poly.c"
    )

    if [ "$need_tomsg" = "yes" ]; then
        cmd+=("$SRC/src/compress.c")
    fi

    cmd+=(
        "$FAMILY/support/sub00r_b6_optblocker_zero.c"
        -o "$goto_file"
    )

    {
        printf 'COMMAND:'
        printf ' %q' "${cmd[@]}"
        printf '\n'
    } > "$command_file"

    set +e
    "${cmd[@]}" >"$stdout_file" 2>"$stderr_file"
    rc=$?
    set -e
    printf '%s\n' "$rc" > "$exit_file"

    [ "$rc" -eq 0 ] ||
        die "goto-cc failed for $case_name; inspect $stderr_file"
    [ -s "$goto_file" ] ||
        die "GOTO binary missing or empty for $case_name"

    sha256sum "$goto_file" > "$goto_file.sha256"

    goto-instrument --validate-goto-binary "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_validate_goto_binary.txt" 2>&1

    goto-instrument --show-loops "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_show_loops.txt" 2>&1

    goto-instrument --list-goto-functions "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_list_goto_functions.txt" 2>&1

    goto-instrument --show-goto-functions "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_show_goto_functions.txt" 2>&1

    goto-instrument --list-symbols "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_list_symbols.txt" 2>&1

    goto-instrument --list-undefined-functions "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_undefined_functions.txt" 2>&1

    goto-instrument --list-calls-args "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_calls_and_arguments.txt" 2>&1

    goto-instrument --reachable-call-graph "$goto_file" \
        >"$PREFLIGHT/inspection/${case_name}_reachable_call_graph.txt" 2>&1

    grep -q 'mlk_sub00r_b6_poly_sub' \
        "$PREFLIGHT/inspection/${case_name}_reachable_call_graph.txt" ||
        die "production poly_sub not reachable in $case_name"

    if [ "$need_reduce" = "yes" ]; then
        grep -q 'mlk_sub00r_b6_poly_reduce' \
            "$PREFLIGHT/inspection/${case_name}_reachable_call_graph.txt" ||
            die "production poly_reduce not reachable in $case_name"
    fi

    if [ "$need_tomsg" = "yes" ]; then
        grep -q 'mlk_sub00r_b6_poly_tomsg' \
            "$PREFLIGHT/inspection/${case_name}_reachable_call_graph.txt" ||
            die "production poly_tomsg not reachable in $case_name"
    fi

    mapfile -t loop_ids < <(
        awk '
          /^Loop[[:space:]]+/ {
            id=$2
            sub(/:$/, "", id)
            if(id ~ /^main\./ ||
               id ~ /^sub_t6_assume_callsite_inputs\./ ||
               id ~ /^mlk_sub00r_b6_poly_sub\./ ||
               id ~ /^mlk_poly_reduce_c\./ ||
               id ~ /^mlk_sub00r_b6_poly_tomsg\./)
              print id
          }
        ' "$PREFLIGHT/inspection/${case_name}_show_loops.txt" |
        sort -u
    )

    [ "${#loop_ids[@]}" -ge 3 ] ||
        die "too few slice-relevant loop IDs for $case_name"

    sub_loop_count=0
    input_loop_count=0
    reduce_loop_count=0
    tomsg_loop_count=0
    unwindset=""
    loop_csv=""

    for loop_id in "${loop_ids[@]}"
    do
        case "$loop_id" in
            sub_t6_assume_callsite_inputs.*)
                input_loop_count=$((input_loop_count + 1))
                ;;
            mlk_sub00r_b6_poly_sub.*)
                sub_loop_count=$((sub_loop_count + 1))
                ;;
            mlk_poly_reduce_c.*)
                reduce_loop_count=$((reduce_loop_count + 1))
                ;;
            mlk_sub00r_b6_poly_tomsg.*)
                tomsg_loop_count=$((tomsg_loop_count + 1))
                ;;
        esac

        if [ -n "$unwindset" ]; then
            unwindset="${unwindset},"
            loop_csv="${loop_csv},"
        fi

        unwindset="${unwindset}${loop_id}:257"
        loop_csv="${loop_csv}${loop_id}"
    done

    [ "$input_loop_count" -eq 1 ] ||
        die "expected one input-domain loop in $case_name"
    [ "$sub_loop_count" -eq 1 ] ||
        die "expected one production sub loop in $case_name"

    if [ "$need_reduce" = "yes" ]; then
        [ "$reduce_loop_count" -eq 1 ] ||
            die "expected one reduction loop in $case_name"
    else
        [ "$reduce_loop_count" -eq 0 ] ||
            die "unexpected reachable reduction loop in $case_name"
    fi

    if [ "$need_tomsg" = "yes" ]; then
        [ "$tomsg_loop_count" -ge 2 ] ||
            die "expected nested tomsg loops in $case_name"
    else
        [ "$tomsg_loop_count" -eq 0 ] ||
            die "unexpected reachable tomsg loop in $case_name"
    fi

    printf '%s\n' "$unwindset" \
        > "$PREFLIGHT/inspection/${case_name}_frozen_unwindset.txt"

    property_cmd=(
        cbmc
        "$goto_file"
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
        --unwindset "$unwindset"
        --show-properties
    )

    {
        printf 'COMMAND:'
        printf ' %q' "${property_cmd[@]}"
        printf '\n'
    } > "$PREFLIGHT/commands/${case_name}_show_properties_command.txt"

    "${property_cmd[@]}" \
        >"$PREFLIGHT/inspection/${case_name}_show_properties.txt" \
        2>"$PREFLIGHT/inspection/${case_name}_show_properties_stderr.txt"

    property_count="$(
        grep -Ec '^Property[[:space:]]+' \
            "$PREFLIGHT/inspection/${case_name}_show_properties.txt" || true
    )"

    [ "$property_count" -ge 1 ] ||
        die "no properties discovered for $case_name"

    goto_sha="$(awk '{print $1}' "$goto_file.sha256")"

    printf '%s|%s|%s|%s|%s\n' \
        "$case_name" \
        "$goto_sha" \
        "$loop_csv" \
        "$unwindset" \
        "$property_count" \
        >> "$SUMMARY"

    echo \
      "CASE=$case_name BUILD=PASS VALIDATE=PASS LOOPS=$loop_csv PROPERTIES=$property_count"
done

{
    echo
    echo "=== PREFLIGHT VERDICT ==="
    echo "CASE_COUNT=${#CASES[@]}"
    echo "GOTO_BINARY_COUNT=$(find "$PREFLIGHT/build" -maxdepth 1 -type f -name '*.goto' | wc -l)"
    echo "GOTO_CHECKSUM_COUNT=$(find "$PREFLIGHT/build" -maxdepth 1 -type f -name '*.goto.sha256' | wc -l)"
    echo "BUILD_EXIT_ZERO_COUNT=$(grep -l '^0$' "$PREFLIGHT/exit_codes"/*_goto_build_exit_code.txt | wc -l)"
    echo "CASE_SPECIFIC_UNWINDSET_COUNT=$(find "$PREFLIGHT/inspection" -maxdepth 1 -type f -name '*_frozen_unwindset.txt' | wc -l)"
    echo "POSITIVE_HARNESS_COUNT=5"
    echo "ALL_GOTO_BUILDS=PASS"
    echo "ALL_GOTO_BINARY_VALIDATIONS=PASS"
    echo "ALL_REQUIRED_PRODUCTION_CALL_GRAPHS=REACHABLE"
    echo "ALL_LOOP_IDS_DERIVED_FROM_GOTO_MODELS=PASS"
    echo "ALL_PROPERTY_INVENTORIES_PRESENT=PASS"
    echo "B6_4_STATUS=PASS"
    echo
    echo "=== OPERATION BOUNDARY ==="
    echo "GOTO_MODEL_CREATION=YES"
    echo "CBMC_PROOF_EXECUTION=NO"
    echo "PRODUCTION_SOURCE_MODIFICATION=NO"
    echo "BATCH5_MODIFICATION=NO"
} >> "$SUMMARY"

(
    cd "$PREFLIGHT"
    find . -type f \
        ! -name "$(basename "$MANIFEST")" \
        -print0 |
    sort -z |
    xargs -0 sha256sum > "$MANIFEST"
    sha256sum -c "$MANIFEST"
)

find "$PREFLIGHT" -type f -exec chmod 0444 {} +
chmod 0555 "$PREFLIGHT/executed_runner.sh"
find "$PREFLIGHT" -type d -exec chmod 0555 {} +

tar -C "$B6" -czf "$PACKAGE" \
    "03_HARNESS_FREEZE/frozen_harness_family_v1" \
    "04_GOTO_PREFLIGHT/B6_4_GOTO_PREFLIGHT_MLKEM768"

SUCCESS=1
trap - EXIT

echo
echo "=== FINAL COMBINED B6.3+B6.4 SUMMARY ==="
grep -E \
  'CASE_COUNT=|GOTO_BINARY_COUNT=|GOTO_CHECKSUM_COUNT=|BUILD_EXIT_ZERO_COUNT=|CASE_SPECIFIC_UNWINDSET_COUNT=|POSITIVE_HARNESS_COUNT=|ALL_GOTO_BUILDS=|ALL_GOTO_BINARY_VALIDATIONS=|ALL_REQUIRED_PRODUCTION_CALL_GRAPHS=|ALL_LOOP_IDS_DERIVED_FROM_GOTO_MODELS=|ALL_PROPERTY_INVENTORIES_PRESENT=|B6_4_STATUS=|GOTO_MODEL_CREATION=|CBMC_PROOF_EXECUTION=|PRODUCTION_SOURCE_MODIFICATION=|BATCH5_MODIFICATION=' \
  "$SUMMARY"

echo
echo "--- Package ---"
stat -c 'FILE=%n SIZE=%s MODE=%a' "$PACKAGE"
sha256sum "$PACKAGE"

echo
echo "B63_HARNESS_COUNT=5"
echo "B63_STATIC_VALIDATION=PASS"
echo "B63_HARNESS_FAMILY_FROZEN=YES"
echo "B64_GOTO_BINARY_COUNT=5"
echo "B64_ALL_GOTO_BUILDS=PASS"
echo "B64_ALL_GOTO_VALIDATIONS=PASS"
echo "B64_ALL_REQUIRED_CALLS_REACHABLE=PASS"
echo "B64_ALL_UNWINDSETS_MODEL_DERIVED=PASS"
echo "B64_ALL_PROPERTY_INVENTORIES=PASS"
echo "B63_B64_GOTO_CONSTRUCTED=YES"
echo "B63_B64_CBMC_PROOF_EXECUTED=NO"
echo "B63_B64_PRODUCTION_MODIFIED=NO"
echo "B63_B64_BATCH5_MODIFIED=NO"
echo "B63_B64_UPLOAD_REQUIRED=YES"
echo "B63_B64_STATUS=PASS"
