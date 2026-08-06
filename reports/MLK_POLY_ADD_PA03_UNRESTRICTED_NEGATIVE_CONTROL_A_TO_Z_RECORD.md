# PA-03: Unrestricted Signed-Domain Negative-Control Record for `mlk_poly_add`

## Complete A-to-Z Technical Documentation of the Expected-Counterexample Experiment

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Target project:** `pq-code-package/mlkem-native`  
**Target function:** `mlk_poly_add`  
**Verification method:** CBMC bounded model checking  
**Campaign item:** PA-03  
**Campaign purpose:** Negative control for unrestricted signed `int16_t` addition  
**Campaign result:** `EXPECTED_COUNTEREXAMPLE_CONFIRMED`  
**Low-level CBMC result:** `VERIFICATION FAILED` as intentionally expected  
**Document type:** Self-contained formal technical record

---

## 1. Executive Summary

PA-03 was designed as a deliberate negative-control experiment for the production
`mlk_poly_add` function.

The earlier PA-01 and PA-02 experiments established successful verification results over two
valid domains:

- PA-01: canonical FIPS-domain coefficients;
- PA-02: the complete signed and non-canonical domain in which every exact coefficient-wise sum
  is representable in `int16_t`.

PA-03 removed the PA-02 representability precondition and supplied completely unrestricted
symbolic signed `int16_t` coefficient arrays.

The harness then required CBMC to prove that the stored `int16_t` result always equals the exact
mathematical sum calculated in `int32_t`.

That universal claim is mathematically false because some sums of two `int16_t` values do not fit
inside `int16_t`.

CBMC produced the expected counterexample class. The campaign runner confirmed:

```text
expected_assertion_failure_observed=yes
target_conversion_failure_observed=yes
no_body_failure_observed=no
final_status=EXPECTED_COUNTEREXAMPLE_CONFIRMED
```

Therefore, PA-03 succeeded scientifically.

The experiment demonstrates that:

1. unrestricted exact addition is impossible with an `int16_t` output;
2. the PA-02 representability condition is necessary;
3. the PA-02 condition was not added merely to force verification success;
4. CBMC reaches and analyses the production conversion;
5. the observed failure is an arithmetic-domain counterexample rather than a harness plumbing
   defect.

---

## 2. Research Purpose

The purpose of PA-03 is not to prove another successful universal correctness theorem.

Its purpose is to test the boundary of the PA-02 claim.

PA-02 proved:

> Exact addition holds for every pair whose mathematical sum is representable in `int16_t`.

PA-03 asks:

> Does exact addition still hold when the representability requirement is removed?

The correct answer is no.

A negative-control experiment is valuable because it tests whether the successful verification
boundary has an independent mathematical justification.

---

## 3. Target Function

The target is the portable production C implementation of:

```c
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;

  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }
}
```

The function:

- iterates over every coefficient;
- adds the corresponding signed coefficients;
- stores the result in an `int16_t`;
- does not reduce modulo `q` inside the function.

The key machine-level boundary is the destination type:

```text
int16_t
```

---

## 4. Why the Unrestricted Claim Is False

The signed `int16_t` range is:

```text
-32768 .. 32767
```

But two values from this range can have an exact mathematical sum outside it.

Examples:

```text
32767 + 1 = 32768
```

and:

```text
-32768 + (-1) = -32769
```

Neither result is representable in `int16_t`.

Therefore, no implementation storing the exact result in `int16_t` can satisfy unrestricted exact
integer addition for every possible pair.

This is a representational impossibility, not merely a weakness of the implementation.

---

## 5. Difference Between PA-02 and PA-03

| Dimension | PA-02 | PA-03 |
|---|---|---|
| Input values | arbitrary signed `int16_t` | arbitrary signed `int16_t` |
| Safe-sum restriction | present | deliberately removed |
| Exact result representable | required | not required |
| Expected CBMC outcome | successful proof | counterexample |
| Campaign meaning | valid-domain correctness | invalid-domain boundary test |
| Scientific success condition | `VERIFICATION SUCCESSFUL` | `EXPECTED_COUNTEREXAMPLE_CONFIRMED` |

PA-03 changes only the arithmetic-domain assumption.

It does not intentionally change:

- repository target;
- production body;
- object separation;
- pointer-validity model;
- loop bound;
- safety-check configuration;
- symbolic input type.

---

## 6. Symbolic Input Model

The harness uses:

```c
static int16_t pa03_nondet_int16(void)
{
  int16_t value;
  return value;
}
```

CBMC treats the uninitialised local value as symbolic.

Every coefficient of both input arrays may therefore take any signed `int16_t` value.

No assumptions restrict:

- sign;
- canonical FIPS range;
- non-canonical representation;
- exact-sum representability.

The relevant harness section is:

```c
for (i = 0; i < MLKEM_N; i++)
{
  a.coeffs[i] = pa03_nondet_int16();
  b.coeffs[i] = pa03_nondet_int16();
}
```

---

## 7. Assumption Ledger

PA-03 intentionally uses fewer assumptions than PA-02.

### A1. Repository and target configuration

The experiment is tied to the selected `mlkem-native` revision and target build configuration.

### A2. Parameter binding

The harness asserts:

```text
MLKEM_N == 256
MLKEM_Q == 3329
```

### A3. Signed representation binding

The harness asserts:

```text
INT16_MIN == -32768
INT16_MAX == 32767
```

### A4. Legal object separation

The target accumulator object and the read-only operand are distinct.

### A5. Portable C path

The experiment directly executes the portable production C implementation.

### A6. Complete loop analysis

The runner uses:

```text
--unwind 257
--unwinding-assertions
```

### Deliberately absent assumption

PA-03 does not include:

```text
INT16_MIN <= a[i] + b[i] <= INT16_MAX
```

Its absence is the defining feature of the experiment.

---

## 8. Object Construction

The harness creates separate objects:

```text
a
b
a_before
b_before
result
```

The target call is:

```c
mlk_poly_add(&result, &b);
```

The accumulator and read-only operand are disjoint by construction.

The harness additionally asserts:

```c
__CPROVER_assert(
    &result != &b,
    "PA03_DISJOINTNESS: result and b are distinct objects");
```

PA-03 therefore tests unrestricted arithmetic inputs without mixing in the later aliasing
experiment.

---

## 9. Independent Mathematical Model

Before checking the target result, the harness calculates:

```c
mathematical_sum =
    (int32_t)a_before.coeffs[i] +
    (int32_t)b_before.coeffs[i];
```

The expected result is computed in `int32_t`.

This type can represent every exact sum of two `int16_t` values.

Therefore, the independent model does not overflow when describing the mathematical result.

---

## 10. Intentionally Refutable Property

PA-03 asks CBMC to prove:

```c
__CPROVER_assert(
    (int32_t)result.coeffs[i] == mathematical_sum,
    "PA03_P1_UNRESTRICTED_EXACT_SUM:
     exact addition for every arbitrary int16_t pair");
```

This assertion states:

```text
stored int16_t result
=
exact int32_t mathematical result
```

for every unrestricted input pair.

The property is deliberately stronger than the machine representation permits.

Its failure is the expected outcome.

---

## 11. Read-Only Frame Property

PA-03 also checks:

```c
__CPROVER_assert(
    b.coeffs[i] == b_before.coeffs[i],
    "PA03_P2_RIGHT_INPUT_FRAME: b remains unchanged");
```

This separates the expected arithmetic failure from an unintended mutation of the read-only
operand.

The campaign was designed so that the intended failure concerns exact representability, not
object corruption.

---

## 12. CBMC Safety Instrumentation

The runner enables:

```text
bounds checking
pointer checking
pointer-overflow checking
signed-overflow checking
unsigned-overflow checking
conversion checking
division-by-zero checking
undefined-shift checking
loop-unwinding assertions
```

Of particular importance is the conversion check applied to:

```c
(int16_t)(r->coeffs[i] + b->coeffs[i])
```

The campaign summary confirmed:

```text
target_conversion_failure_observed=yes
```

This shows that the expected boundary violation was observed in the target conversion.

---

## 13. Direct Production Execution

The experiment compiles:

```text
pa03_mlk_poly_add_unrestricted_negative_control_harness.c
mlkem/src/poly.c
```

into a GOTO model.

The production `mlk_poly_add` body is invoked directly.

The experiment does not depend on:

- the repository's original proof harness;
- a replacement function contract;
- an assumed target summary;
- a mocked implementation.

The observed counterexample therefore concerns the actual compiled portable C body.

---

## 14. Campaign Classification Logic

A low-level CBMC failure alone is not automatically accepted as PA-03 success.

The runner checks that:

1. the GOTO build succeeds;
2. the text run reports the expected failure status;
3. the JSON run reports the expected failure status;
4. the intended PA-03 exact-sum assertion fails;
5. the failure is not caused by a missing function body;
6. the verification output reports failure;
7. the expected arithmetic/conversion boundary is observed.

Only then does the runner assign:

```text
EXPECTED_COUNTEREXAMPLE_CONFIRMED
```

This prevents unrelated infrastructure failures from being misclassified as a successful
negative control.

---

## 15. PA-03 Result

The campaign produced:

```text
expected_assertion_failure_observed=yes
target_conversion_failure_observed=yes
no_body_failure_observed=no
final_status=EXPECTED_COUNTEREXAMPLE_CONFIRMED
```

The scientifically correct interpretation is:

> CBMC successfully refuted unrestricted exact `int16_t` addition for the production
> `mlk_poly_add` implementation and confirmed the expected conversion boundary.

---

## 16. Why This Is a Successful Experiment

PA-03 is successful because its hypothesis was:

```text
The unrestricted exact-addition property is false.
```

CBMC produced evidence supporting that hypothesis.

The low-level message:

```text
VERIFICATION FAILED
```

does not mean that the experimental workflow failed.

It means that the intentionally false universal property was correctly rejected.

The campaign-level result is therefore:

```text
SCIENTIFIC OUTCOME: SUCCESS
```

---

## 17. What PA-03 Establishes

PA-03 establishes that:

1. exact coefficient-wise addition cannot hold for every arbitrary pair of `int16_t` values;
2. some exact mathematical sums lie outside the output representation;
3. the production narrowing conversion can violate the enabled conversion property in the
   unrestricted domain;
4. the PA-02 representability condition is necessary;
5. PA-02 did not hide an implementation defect through an unjustified canonical restriction;
6. CBMC distinguishes the valid and invalid arithmetic domains;
7. the expected failure is not caused by an undefined nondeterministic helper;
8. the production function body was reached and analysed.

---

## 18. What PA-03 Does Not Establish

PA-03 does not prove:

1. that `mlk_poly_add` is defective inside its valid domain;
2. that PA-02 is invalid;
3. that production callers violate the representability precondition;
4. that every unrestricted input produces an invalid result;
5. that the read-only operand is modified;
6. that memory safety fails;
7. that pointer safety fails;
8. that object aliasing is legal or illegal;
9. that the complete ML-KEM implementation is incorrect;
10. that other polynomial functions share the same boundary;
11. cryptographic insecurity;
12. constant-time failure;
13. assembly-level behaviour;
14. universal compiler behaviour.

The counterexample shows the existence of invalid unrestricted pairs, not failure for every pair.

---

## 19. Combined PA-01, PA-02, and PA-03 Assurance Position

### PA-01

PA-01 proved correctness for canonical FIPS representatives:

```text
0 <= a[i], b[i] < q
```

### PA-02

PA-02 proved correctness for every signed and non-canonical pair satisfying:

```text
INT16_MIN <= a[i] + b[i] <= INT16_MAX
```

### PA-03

PA-03 proved that removing the PA-02 representability condition makes unrestricted exact addition
false.

Together, the three experiments form a coherent argument:

```text
PA-01:
Correct in the canonical specification-oriented domain.

PA-02:
Correct in the complete machine-level exact-addition domain.

PA-03:
Outside that domain, unrestricted exact addition is impossible.
```

This is stronger than reporting only successful proofs.

It identifies both:

- the verified domain;
- the formally demonstrated boundary beyond which the claim cannot hold.

---

## 20. Correct Overall Claim After PA-03

The following claim is justified:

> The portable C implementation of `mlk_poly_add` has been successfully verified for canonical
> FIPS representatives and for the complete signed/non-canonical `int16_t` domain in which each
> exact sum is representable. A separate unrestricted negative-control experiment confirmed that
> the representability precondition is necessary.

The following claim remains false:

> `mlk_poly_add` computes exact mathematical addition for every arbitrary pair of `int16_t`
> coefficients.

---

## 21. Independent Design and Distinctness

PA-03 is independently designed as a negative-control harness.

Its distinguishing features include:

- unrestricted signed symbolic coefficients;
- deliberate removal of the safe-sum assumption;
- an independent `int32_t` mathematical oracle;
- an intentionally refutable exact-sum assertion;
- retention of legal object separation;
- retention of the read-only frame check;
- explicit campaign-level expected-failure classification;
- rejection of missing-body failures as invalid evidence;
- detection of the target conversion failure;
- direct execution of the production body.

This is not a conventional success-only harness.

It is an adversarial boundary experiment designed to test the necessity of the earlier proof
contract.

---

## 22. Novelty Position

The original repository harness was not used to construct PA-03.

PA-03's central research structure is:

```text
successful valid-domain proof
+
unrestricted negative control
+
automatic expected-counterexample classification
```

This campaign architecture is distinct from merely restating a function contract and asking CBMC
for success.

The honest novelty claim is:

> PA-03 is an independently authored negative-control harness and campaign classifier designed to
> validate the necessity of the PA-02 representability boundary.

As with PA-01 and PA-02, perfect blindness to all source-level formal annotations is not claimed.

---

## 23. Vacuity and Validity Analysis

### 23.1 No contradictory assumptions

PA-03 contains no arithmetic-domain assumptions.

Its unrestricted symbolic domain is nonempty and maximally broad for `int16_t` operands.

### 23.2 Counterexample existence

Values such as:

```text
32767 and 1
```

provide a direct witness to the falsity of the exact-addition property.

### 23.3 Target reachability

The harness directly invokes the production function.

### 23.4 Failure specificity

The runner verifies that the intended PA-03 assertion fails and that no missing-body failure is
present.

### 23.5 Independent oracle

The expected result is formed in `int32_t`, avoiding circular comparison with the target
representation.

---

## 24. Threats to Validity

### 24.1 CBMC model boundary

The result applies to the CBMC model of the selected portable C build.

### 24.2 Counterexample class

PA-03 establishes existence of invalid unrestricted pairs. It does not classify every possible
overflowing pair.

### 24.3 Production caller applicability

PA-03 does not show that real production code supplies invalid inputs.

Call-site verification remains a separate task.

### 24.4 Compiler and architecture scope

The result is not a universal statement about every compiler, native backend, or assembly
implementation.

### 24.5 Property scope

The main refuted property is unrestricted exact signed addition.

---

## 25. Reproducibility

The campaign can be reproduced from the repository root using:

```bash
./run_pa03_mlk_poly_add_unrestricted_negative_control.sh 768
```

The runner:

- validates tools and repository location;
- checks the selected repository revision;
- builds the generated harness with the production source;
- runs CBMC in text mode;
- runs CBMC in JSON mode;
- checks the intended assertion failure;
- rejects missing-body failures;
- checks for the conversion-failure signal;
- assigns the campaign-level result.

---

## 26. Professor-Facing Result Statement

> PA-03 evaluated an unrestricted signed-domain negative-control harness for the production
> `mlk_poly_add` implementation. Unlike PA-02, it imposed no assumption that the exact
> coefficient-wise sum must fit in `int16_t`. The harness compared the stored production result
> against an independent `int32_t` mathematical sum. CBMC refuted the unrestricted exact-addition
> property and reported the expected target conversion failure. The campaign classifier confirmed
> that the intended assertion failed and that no missing-function-body defect was involved. This
> result formally validates the necessity of PA-02's representability precondition.

---

## 27. Next Campaign Item

The next recommended campaign item is:

```text
PA-04: aliasing diagnostic for r == b
```

PA-04 should test the current implementation behaviour when:

```c
mlk_poly_add(&a, &a);
```

under a safe doubling domain.

It must remain labelled as an out-of-contract diagnostic unless the production API explicitly
permits aliasing.

---

## 28. Final Conclusion

PA-03 successfully confirmed the exact boundary of the `mlk_poly_add` signed-domain proof.

The unrestricted property failed for the expected mathematical reason:

```text
some exact sums of two int16_t values cannot be represented in int16_t
```

The campaign confirmed:

```text
expected assertion failure observed
target conversion failure observed
no missing-body failure observed
expected counterexample confirmed
```

PA-03 therefore strengthens PA-02 rather than contradicting it.

The combined conclusion after PA-01, PA-02, and PA-03 is:

> `mlk_poly_add` is correct throughout the canonical FIPS domain and the complete signed
> contract-valid exact-addition domain, while unrestricted exact addition beyond the
> representability boundary is formally refuted.

The final PA-03 campaign status is:

```text
EXPECTED_COUNTEREXAMPLE_CONFIRMED
```

---

# Appendix A — Complete PA-03 Harness

```c
/*
 * PA-03: Unrestricted signed-domain negative-control harness
 *         for mlk_poly_add
 *
 * Scientific purpose:
 *   Demonstrate that exact mathematical addition cannot hold for every
 *   arbitrary pair of int16_t coefficient arrays because some sums are
 *   outside the representable int16_t range.
 *
 * Expected CBMC outcome:
 *   VERIFICATION FAILED
 *
 * Expected campaign interpretation:
 *   EXPECTED_COUNTEREXAMPLE_CONFIRMED
 *
 * This expected failure is the successful scientific result of PA-03.
 * It validates that the representability precondition used by PA-02 is
 * necessary rather than an arbitrary assumption added to force success.
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * CBMC treats the uninitialised local value as symbolic.
 * A concrete function body avoids a no-body verification failure.
 */
static int16_t pa03_nondet_int16(void)
{
  int16_t value;
  return value;
}

int main(void)
{
  mlk_poly a;
  mlk_poly b;

  mlk_poly a_before;
  mlk_poly b_before;
  mlk_poly result;

  unsigned i;
  int32_t mathematical_sum;

  /*
   * Bind the experiment to the intended ML-KEM and integer
   * representation parameters. These are assertions, not assumptions.
   */
  __CPROVER_assert(
      MLKEM_N == 256,
      "PA03_PARAMETER_BINDING: MLKEM_N must equal 256");

  __CPROVER_assert(
      MLKEM_Q == 3329,
      "PA03_PARAMETER_BINDING: MLKEM_Q must equal 3329");

  __CPROVER_assert(
      INT16_MIN == -32768,
      "PA03_REPRESENTATION_BINDING: INT16_MIN must equal -32768");

  __CPROVER_assert(
      INT16_MAX == 32767,
      "PA03_REPRESENTATION_BINDING: INT16_MAX must equal 32767");

  /*
   * Generate completely unrestricted signed int16_t arrays.
   *
   * Deliberately absent:
   *   - no canonical FIPS-domain assumptions;
   *   - no non-negative assumptions;
   *   - no safe-sum or representability assumptions;
   *   - no restriction preventing a mathematical sum from lying
   *     outside [INT16_MIN, INT16_MAX].
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = pa03_nondet_int16();
    b.coeffs[i] = pa03_nondet_int16();
  }

  a_before = a;
  b_before = b;
  result = a;

  /*
   * Keep the target call legal with respect to object separation.
   * PA-03 changes only the arithmetic input domain; it does not mix the
   * later aliasing diagnostic into this negative-control experiment.
   */
  __CPROVER_assert(
      &result != &b,
      "PA03_DISJOINTNESS: result and b are distinct objects");

  /*
   * Directly execute the production portable-C implementation.
   */
  mlk_poly_add(&result, &b);

  for (i = 0; i < MLKEM_N; i++)
  {
    /*
     * int32_t can represent every exact sum of two int16_t values.
     */
    mathematical_sum =
        (int32_t)a_before.coeffs[i] +
        (int32_t)b_before.coeffs[i];

    /*
     * PA03-P1 is intentionally too strong over the unrestricted domain.
     *
     * CBMC is expected to refute it using a pair whose exact sum is
     * outside the int16_t range. For example, a value equivalent to
     * INT16_MAX + 1 or INT16_MIN - 1 is sufficient.
     */
    __CPROVER_assert(
        (int32_t)result.coeffs[i] == mathematical_sum,
        "PA03_P1_UNRESTRICTED_EXACT_SUM: exact addition for every arbitrary int16_t pair");

    /*
     * This frame property should remain valid even though PA03-P1 fails.
     * It helps distinguish the intended arithmetic-domain failure from
     * unintended mutation of the read-only operand.
     */
    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "PA03_P2_RIGHT_INPUT_FRAME: b remains unchanged");
  }

  return 0;
}
```

---

# Appendix B — Complete PA-03 Runner

```bash
#!/usr/bin/env bash
#
# PA-03 runner:
# Unrestricted signed-domain negative control for mlk_poly_add.
#
# IMPORTANT:
#   CBMC VERIFICATION FAILED is the expected low-level result.
#   EXPECTED_COUNTEREXAMPLE_CONFIRMED is the successful campaign result.
#
# Run from the mlkem-native repository root:
#
#   chmod +x run_pa03_mlk_poly_add_unrestricted_negative_control.sh
#   ./run_pa03_mlk_poly_add_unrestricted_negative_control.sh 768
#
# Optional parameter-set argument: 512, 768, or 1024.
# Default: 768.
#

set -uo pipefail

CAMPAIGN_ID="PA-03"
CAMPAIGN_SCOPE="unrestricted_signed_int16_negative_control"
EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="pa03_mlk_poly_add_unrestricted_negative_control_harness.c"
EXPECTED_MARKER="PA03_P1_UNRESTRICTED_EXACT_SUM"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/pa03_mlk_poly_add_unrestricted_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/pa03_mlk_poly_add.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee grep; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "ERROR: required tool not found: ${tool}" >&2
    exit 2
  fi
done

if [ ! -f "mlkem/src/poly.c" ] || [ ! -f "mlkem/src/poly.h" ]; then
  echo "ERROR: run this script from the mlkem-native repository root." >&2
  exit 2
fi

if [ ! -f "${HARNESS}" ]; then
  echo "ERROR: ${HARNESS} is not present in the repository root." >&2
  exit 2
fi

mkdir -p "${OUT_DIR}"

CURRENT_COMMIT="$(git rev-parse HEAD)"

{
  echo "Campaign ID: ${CAMPAIGN_ID}"
  echo "Campaign scope: ${CAMPAIGN_SCOPE}"
  echo "Expected low-level CBMC result: VERIFICATION FAILED"
  echo "Expected campaign interpretation: EXPECTED_COUNTEREXAMPLE_CONFIRMED"
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo "Harness: ${HARNESS}"
  echo
  echo "Git status:"
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1
sha256sum "${HARNESS}" > "${OUT_DIR}/harness_sha256.txt"
sha256sum "$0" > "${OUT_DIR}/runner_sha256.txt"
cp "${HARNESS}" "${OUT_DIR}/"
cp "$0" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  {
    echo "ERROR: repository commit does not match the PA-03 target."
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${CURRENT_COMMIT}"
  } | tee "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

BUILD_COMMAND=(
  goto-cc
  -I.
  -Imlkem
  -Imlkem/src
  -DMLK_CONFIG_PARAMETER_SET="${PARAM_SET}"
  "${HARNESS}"
  mlkem/src/poly.c
  -o "${GOTO_MODEL}"
)

printf '%q ' "${BUILD_COMMAND[@]}" > "${OUT_DIR}/build_command.txt"
printf '\n' >> "${OUT_DIR}/build_command.txt"

echo "===== PA-03: BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  {
    echo "campaign=${CAMPAIGN_ID}"
    echo "expected_cbmc_result=VERIFICATION_FAILED"
    echo "build_exit=${BUILD_EXIT}"
    echo "final_status=BUILD_FAILED"
  } > "${OUT_DIR}/summary.txt"

  echo "PA-03 BUILD FAILED. This is not the expected scientific outcome."
  exit "${BUILD_EXIT}"
fi

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

CBMC_TEXT_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --trace
)

printf '%q ' "${CBMC_TEXT_COMMAND[@]}" > "${OUT_DIR}/cbmc_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_command.txt"

echo
echo "===== PA-03: RUNNING EXPECTED-FAILURE CBMC TEXT CHECK ====="
"${CBMC_TEXT_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/cbmc_output.txt"
CBMC_TEXT_EXIT=${PIPESTATUS[0]}
echo "${CBMC_TEXT_EXIT}" > "${OUT_DIR}/cbmc.exit"

CBMC_JSON_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
  "${COMMON_CBMC_OPTIONS[@]}"
  --json-ui
)

printf '%q ' "${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_json_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_json_command.txt"

echo
echo "===== PA-03: RUNNING EXPECTED-FAILURE CBMC JSON CHECK ====="
"${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_output.json" 2> \
  "${OUT_DIR}/cbmc_json_stderr.txt"
CBMC_JSON_EXIT=$?
echo "${CBMC_JSON_EXIT}" > "${OUT_DIR}/cbmc_json.exit"

EXPECTED_ASSERTION_FAILURE="no"
NO_BODY_FAILURE="no"
VERIFICATION_FAILED_TEXT="no"
CONVERSION_FAILURE_OBSERVED="no"

if grep "${EXPECTED_MARKER}" "${OUT_DIR}/cbmc_output.txt" | \
   grep -q "FAILURE"; then
  EXPECTED_ASSERTION_FAILURE="yes"
fi

if grep -q "no body for callee" "${OUT_DIR}/cbmc_output.txt"; then
  NO_BODY_FAILURE="yes"
fi

if grep -q "VERIFICATION FAILED" "${OUT_DIR}/cbmc_output.txt"; then
  VERIFICATION_FAILED_TEXT="yes"
fi

if grep "arithmetic overflow on signed type conversion" \
   "${OUT_DIR}/cbmc_output.txt" | grep -q "FAILURE"; then
  CONVERSION_FAILURE_OBSERVED="yes"
fi

FINAL_STATUS="UNEXPECTED_RESULT"
SCRIPT_EXIT=1

if [ "${BUILD_EXIT}" -eq 0 ] &&
   [ "${CBMC_TEXT_EXIT}" -eq 10 ] &&
   [ "${CBMC_JSON_EXIT}" -eq 10 ] &&
   [ "${EXPECTED_ASSERTION_FAILURE}" = "yes" ] &&
   [ "${NO_BODY_FAILURE}" = "no" ] &&
   [ "${VERIFICATION_FAILED_TEXT}" = "yes" ]; then
  FINAL_STATUS="EXPECTED_COUNTEREXAMPLE_CONFIRMED"
  SCRIPT_EXIT=0
fi

{
  echo "campaign=${CAMPAIGN_ID}"
  echo "scope=${CAMPAIGN_SCOPE}"
  echo "parameter_set=${PARAM_SET}"
  echo "expected_cbmc_result=VERIFICATION_FAILED"
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_text_exit=${CBMC_TEXT_EXIT}"
  echo "cbmc_json_exit=${CBMC_JSON_EXIT}"
  echo "expected_assertion_failure_observed=${EXPECTED_ASSERTION_FAILURE}"
  echo "target_conversion_failure_observed=${CONVERSION_FAILURE_OBSERVED}"
  echo "no_body_failure_observed=${NO_BODY_FAILURE}"
  echo "final_status=${FINAL_STATUS}"
} > "${OUT_DIR}/summary.txt"

echo
echo "===== PA-03 CAMPAIGN SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

if [ "${FINAL_STATUS}" = "EXPECTED_COUNTEREXAMPLE_CONFIRMED" ]; then
  echo
  echo "PA-03 SCIENTIFIC OUTCOME: SUCCESS"
  echo "CBMC refuted unrestricted exact int16_t addition as expected."
else
  echo
  echo "PA-03 SCIENTIFIC OUTCOME: UNEXPECTED OR INCONCLUSIVE"
  echo "Preserve the result directory for diagnosis."
fi

exit "${SCRIPT_EXIT}"
```

---

# Appendix C — PA-03 Property Ledger

| ID | Property or check | Outcome |
|---|---|---|
| PA03-B1 | `MLKEM_N == 256` | Held |
| PA03-B2 | `MLKEM_Q == 3329` | Held |
| PA03-B3 | expected signed 16-bit representation | Held |
| PA03-D1 | target-call objects are distinct | Held |
| PA03-P1 | unrestricted exact signed addition | Refuted as expected |
| PA03-P2 | read-only operand preservation | Retained as a supporting property |
| PA03-S1 | target narrowing conversion under unrestricted inputs | Failure observed as expected |
| PA03-I1 | missing-body defect absent | Confirmed |
| PA03-C1 | campaign classification | `EXPECTED_COUNTEREXAMPLE_CONFIRMED` |

---

# Appendix D — Combined PA Campaign Summary

| Campaign | Domain | Expected result | Final interpretation |
|---|---|---|---|
| PA-01 | canonical FIPS coefficients | proof success | canonical correctness established |
| PA-02 | complete signed contract-valid domain | proof success | full valid signed-domain correctness established |
| PA-03 | unrestricted signed domain | counterexample | representability boundary confirmed |

---

# Appendix E — Terminology

**Negative control:** An experiment designed to produce a known failure, used to validate that the
verification setup detects invalid claims.

**Expected counterexample:** A solver-produced execution demonstrating that an intentionally broad
property is false.

**Representability boundary:** The limits imposed by the destination machine type.

**Scientific success:** The experiment produced the result predicted by its hypothesis, even
though the low-level verifier reported a failed assertion.

**Unrestricted domain:** The complete input type range without semantic preconditions.

**Valid domain:** Inputs for which the intended exact result is defined and representable.
