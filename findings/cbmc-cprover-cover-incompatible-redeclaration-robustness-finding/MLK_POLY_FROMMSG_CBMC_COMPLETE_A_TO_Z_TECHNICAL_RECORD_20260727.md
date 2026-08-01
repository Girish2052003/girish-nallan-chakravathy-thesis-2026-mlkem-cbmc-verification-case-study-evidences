# A-to-Z Technical Record of the `mlk_poly_frommsg` CBMC Case Study

**Author:** Girish Nallan Chakravathy  
**Research context:** MSc thesis case study on AI-assisted formal methods for post-quantum cryptography implementations  
**Target project:** `mlkem-native`  
**Primary target function:** `mlk_poly_frommsg`  
**Main investigation dates:** 24–25 July 2026  
**Record prepared:** 27 July 2026  
**Status:** Complete internal technical record of the investigation and its defensible findings

> **Scope boundary.** This file documents the technical work performed in this chat: the verification objective, native-proof investigation, model construction, direct-body proof, unwind calibration, non-vacuity controls, mutations, coverage crash, minimisation, canonical controls, cross-version reproduction, discovery chronology, novelty boundaries, evidence integrity, limitations, and thesis significance.  
>
> It intentionally excludes the later administrative requests to draft an email to the supervisor, create a supervisor-facing attachment, or organise files for sending. Those were communication and packaging requests, not technical findings.

---

## 1. Executive summary

This case study produced **two separate and complementary results**.

First, a clean-room, direct-body CBMC campaign proved a selected semantic property of the real `mlk_poly_frommsg` production implementation at the frozen `mlkem-native` commit:

```text
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

For every 32-byte message and every coefficient index `k` in `[0,255]`, the output coefficient is exactly:

- `0` when the corresponding message bit is `0`; and
- `MLKEM_Q_HALF`, equal to `1665`, when the corresponding message bit is `1`.

The authoritative proof retained the real production body and the required helper functions. It used exact loop-unwind calibration, repeated successful runs, explicit reachability witnesses, and two mutation controls. It did **not** modify the production source, replace the target with a function contract, introduce contract havoc, or use `__CPROVER_assume` to force the theorem.

Second, while investigating a failed non-vacuity/coverage route, the case study isolated a deterministic **CBMC robustness and type-handling defect**. Canonical `__CPROVER_cover` usage works normally. However, manually redeclaring this built-in with an incompatible `_Bool` or `int` parameter and running `--cover cover` causes the affected tested CBMC versions to terminate through an internal `not_exprt` Boolean-expression invariant instead of issuing a controlled incompatible-declaration diagnostic.

The precise defect was isolated on:

```text
24 July 2026 at 16:38:26 UTC
```

and the same controlled differential was reproduced in the tested official Diffblue Docker image tags:

```text
diffblue/cbmc:6.9.0
diffblue/cbmc:6.10.0
```

later that day.

The combined scientific conclusion is therefore **not** that ML-KEM is defective. It is that:

1. the selected `mlk_poly_frommsg` direct-body theorem holds in the frozen model; and
2. a separate malformed-built-in coverage path exposes a reproducible CBMC robustness problem in the tested environments.

---

## 2. The one-paragraph answer: what we actually found

> We proved a selected exact semantic property of the real `mlk_poly_frommsg` production body: for every symbolic 32-byte message and every symbolic coefficient index from 0 to 255, the output coefficient is exactly `0` or `MLKEM_Q_HALF` according to the corresponding input bit. Separately, we independently discovered and minimised a CBMC robustness/type-handling defect: canonical `__CPROVER_cover` usage succeeds, but incompatible manual `_Bool` or `int` redeclarations cause coverage instrumentation to terminate through an internal `not_exprt` Boolean invariant rather than issuing a controlled diagnostic. The result was reproduced locally and in the tested CBMC 6.9.0 and 6.10.0 Docker image tags. This is not evidence of an ML-KEM vulnerability, a SAT/SMT solver defect, a general coverage failure, unsound proof success, a security vulnerability, or major severity.

---

## 3. Research questions answered by this investigation

The technical investigation effectively answered the following questions.

### 3.1 Implementation question

Does the real frozen `mlk_poly_frommsg` body implement the selected bit-to-coefficient relation for every input message and every output index?

**Answer:** Yes, for the frozen source, model, constants, architecture, and CBMC configuration used in the authoritative campaign.

### 3.2 Native-proof failure question

Did the repository-native proof failure establish a defect in the production function?

**Answer:** No. The native route encountered processing errors and quantified-property handling problems. Its default-SAT trace was inadmissible as a production counterexample because essential universal quantifiers were ignored and contract instrumentation havoced permitted output memory.

### 3.3 Tool-localisation question

Could the observed coverage failure be separated from ML-KEM?

**Answer:** Yes. It was reduced to a tiny standalone program independent of `mlkem-native`.

### 3.4 Canonical-control question

Was ordinary canonical `__CPROVER_cover` usage broken?

**Answer:** No. Eight canonical control executions completed normally.

### 3.5 Precise trigger question

What exact condition triggered the internal failure?

**Answer:** Manually replacing the built-in declaration with an incompatible `_Bool` or `int` parameter, followed by coverage instrumentation.

### 3.6 Cross-version question

Was the behaviour confined to the original local binary?

**Answer:** No. The same controlled pattern was reproduced in the tested official Docker image tags for CBMC 6.9.0 and 6.10.0.

### 3.7 Novelty question

Can this be called a novel finding?

**Answer:** It can be called an **independently discovered and minimised finding in this case study**. A targeted public search did not reveal an obvious exact match at the time of investigation, but worldwide first discovery or definitive novelty must not be claimed without maintainer confirmation and a more exhaustive issue/commit search.

---

## 4. Frozen experimental context

### 4.1 Source revision and worktree

```text
Frozen mlkem-native commit:
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

Primary worktree:

```text
/home/girish/THESIS-2026/_cbmc_work/mlkem-native_frommsg_native_20260724T131455Z
```

Campaign root:

```text
/home/girish/THESIS-2026/mlk_poly_frommsg_cleanroom
```

Production source:

```text
mlkem/src/compress.c
```

Production header:

```text
mlkem/src/compress.h
```

### 4.2 Frozen source and harness hashes

```text
compress.c SHA-256:
9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad

compress.h SHA-256:
0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

clean-room T1 harness SHA-256:
657afc885742ee6bbef421dbf336c07ed0b40f95a92ff251ffb56122dc285266
```

### 4.3 Local tool identities

```text
CBMC:
6.9.0 (cbmc-6.9.0)

GCC:
13.3.0

Litani:
1.29.0
```

Tool hashes:

```text
/usr/bin/gcc:
1b99826121ae6682a634e5efe09bd3e3df58ce58e0b28f849114ab5b89139c26

/usr/bin/goto-cc:
a06fe9002795381c7213f474065bbae7150e5e556fc5a45bc317249177759c71

/usr/bin/goto-instrument:
b6deeb37fe2112504c064ff260231a209b4211bc6e998de85972570a8b7d22ad

/usr/bin/cbmc:
1dd8e1f7c1621c7e6e305f98222da0372a1b42e65d597d1941847a052e7ef6a1
```

### 4.4 ML-KEM constants relevant to the theorem

```text
MLKEM_N = 256
MLKEM_INDCPA_MSGBYTES = 32
MLKEM_Q = 3329
MLKEM_Q_HALF = 1665
```

The mapping is complete because:

```text
32 bytes × 8 bits per byte = 256 bits = 256 polynomial coefficients
```

---

## 5. What `mlk_poly_frommsg` does

The production function maps a 32-byte message into an ML-KEM polynomial. Structurally, the relevant computation is:

```c
for (i = 0; i < MLKEM_N / 8; i++)
{
  for (j = 0; j < 8; j++)
  {
    uint8_t mask = mlk_value_barrier_u8((uint8_t)(1u << j));

    r->coeffs[8 * i + j] =
      mlk_ct_sel_int16(
        MLKEM_Q_HALF,
        0,
        msg[i] & mask);
  }
}
```

For byte `msg[i]` and bit position `j`:

- `mask` isolates one bit;
- `msg[i] & mask` is zero or nonzero;
- `mlk_ct_sel_int16` selects `0` or `MLKEM_Q_HALF`;
- output index `8*i+j` covers every coefficient from `0` to `255`.

The exact theorem therefore reflects the implementation structure directly rather than checking only a coarse range.

---

## 6. The exact T1 theorem

For every symbolic message and every symbolic `uint8_t k`:

```c
r.coeffs[(unsigned)k] ==
  ((((msg[(unsigned)k / 8u] >>
       ((unsigned)k % 8u)) &
      1u) != 0u)
    ? MLKEM_Q_HALF
    : 0)
```

Mathematically:

\[
\forall msg \in \{0,\ldots,255\}^{32},\;
\forall k \in \{0,\ldots,255\}:
\]

\[
r[k] =
\begin{cases}
1665, & \text{if bit } k \text{ of } msg \text{ is } 1,\\
0, & \text{if bit } k \text{ of } msg \text{ is } 0.
\end{cases}
\]

### 6.1 Why `k` is universally covered

The harness declares an uninitialised:

```c
uint8_t k;
```

CBMC treats it as nondeterministic. Its complete C type range is already exactly `[0,255]`, so no additional range assumption is needed.

If the assertion succeeds for symbolic `k`, it must hold for every representable `uint8_t` value.

### 6.2 Why every message is covered

The local array:

```c
uint8_t msg[MLKEM_INDCPA_MSGBYTES];
```

is symbolic. The proof is not a test-vector check. It covers all representable 32-byte messages in the model.

### 6.3 Why the theorem is stronger than a range check

A range postcondition such as:

```text
0 <= coefficient < MLKEM_Q
```

would permit many values not produced by the intended function.

T1 requires the output to be exactly one of two values and exactly correlated with the corresponding message bit.

---

## 7. Why the investigation began with the native proof

The repository-native proof configuration used function contracts, loop contracts, dynamic frames, and Bitwuzla. Relevant configuration included:

```make
CHECK_FUNCTION_CONTRACTS=mlk_poly_frommsg
USE_FUNCTION_CONTRACTS=mlk_ct_sel_int16
USE_FUNCTION_CONTRACTS+=mlk_value_barrier_u8
APPLY_LOOP_CONTRACTS=on
USE_DYNAMIC_FRAMES=1
CBMCFLAGS=--bitwuzla
```

The native contract broadly required valid/non-aliasing objects and coefficient range preservation.

The native harness was minimal:

```c
void harness(void)
{
  mlk_poly *a;
  uint8_t *msg;

  mlk_poly_frommsg(a, msg);
}
```

The native proof did not produce an ordinary clean success. The investigation therefore had to separate several possibilities:

1. a production-code defect;
2. a wrong or overly strong contract;
3. a loop-contract issue;
4. dynamic-frame instrumentation;
5. quantified formula handling;
6. a solver/backend integration issue;
7. a GOTO-model problem;
8. orchestration or wrapper-status misreporting;
9. a custom harness error.

This separation is central to the case study: **a failed verification workflow is not automatically a failed program**.

---

## 8. Native result triage

The native XML result contained:

```text
CPROVER_STATUS=ERROR
RESULT_RECORD_COUNT=419
RESULT_STATUS_SUCCESS=335
RESULT_STATUS_ERROR=84
RESULT_STATUS_FAILURE=0
```

The first problematic property was:

```text
mlk_poly_frommsg.postcondition.1
```

Additional errors involved contract/dynamic-frame machinery.

### 8.1 Meaning of `ERROR` versus `FAILURE`

A `FAILURE` result normally means a property was disproved under the model and a meaningful counterexample may exist.

An `ERROR` status means processing did not complete normally. It does not by itself establish that the program violates the property.

The native result therefore established:

> The selected native verification route failed to process all obligations successfully.

It did **not** establish:

> The real `mlk_poly_frommsg` production body is incorrect.

---

## 9. Litani and exit-propagation investigation

The exact native Litani job was recovered. The evidence showed that:

- the direct CBMC command returned processing-error status `6`;
- the immediate wrapper recorded a nonzero result;
- the proof job was failed;
- an outer invocation could nevertheless return status `0`.

This was treated as a **local workflow status-propagation/false-green observation**.

It demonstrated that the following must all be inspected:

- raw command return code;
- wrapper return code;
- job status;
- XML overall status;
- individual property statuses;
- trace availability.

A top-level `make` or orchestration return code alone was insufficient as verification evidence.

This finding is useful for the thesis workflow, but it is distinct from the later minimal CBMC robustness defect.

---

## 10. Solver and property bisection

The next stage separated a simple control property from the quantified postcondition.

### 10.1 Control property

```text
mlk_poly_frommsg.single_top_level_call.1
```

This passed with Bitwuzla and with the default SAT route:

```text
RETURN_CODE=0
CPROVER_STATUS=SUCCESS
RESULT_STATUS_SUCCESS=1
```

This established that:

- CBMC could read the final model;
- the target function and selected property infrastructure existed;
- the entire toolchain was not universally broken;
- the failure was path/property specific.

### 10.2 Quantified postcondition with Bitwuzla

The quantified postcondition produced:

```text
RETURN_CODE=6
CPROVER_STATUS=ERROR
```

No admissible program counterexample was generated.

### 10.3 Quantified postcondition with default SAT

The default SAT route produced a verification failure, but emitted repeated warnings:

```text
ignoring forall
```

The postcondition and related invariant logic relied on universal quantification over coefficient indices. Ignoring these quantifiers changed the proof problem.

The resulting trace could not be accepted as proof of a production defect.

### 10.4 Z3 and CVC5 routes

Additional Z3 and CVC5 tests also ended in processing errors rather than producing a clean solver-independent counterexample.

### 10.5 Safe conclusion from solver bisection

> The quantified native contract route was unresolved in the tested proof stack. The evidence did not isolate the issue to one solver and did not establish a production-code violation.

---

## 11. Why the default-SAT counterexample was rejected

The trace was inspected rather than trusted automatically.

Contract instrumentation’s permitted write-set handling could havoc the output coefficients. A coefficient such as index 192 appeared with an arbitrary value around:

```text
20644
```

This did not mean the real production loop computed 20644.

The trace was inadmissible because:

1. the backend explicitly warned that it ignored essential `forall` expressions;
2. the intended property depended on those universal statements;
3. the dynamic-frame/contract abstraction permitted nondeterministic output assignment;
4. the resulting value arose in the abstraction, not necessarily from execution of the real function body.

This is one of the most important scientific decisions in the case study:

> A counterexample is not automatically authoritative when the tool explicitly reports that it has discarded essential semantics.

---

## 12. Decision to create a clean-room direct-body proof

The native contract route was useful evidence about the workflow, but it could not answer the implementation question cleanly.

The investigation therefore changed from:

> Can this broad contract be discharged through the full native contract stack?

to:

> Does the actual production body implement the exact bit-to-coefficient relation?

This direct-body theorem served as a differential control:

- direct-body failure would implicate the implementation, theorem, or concrete model;
- direct-body success alongside contract-stack failure would localise concern toward contracts, quantifiers, instrumentation, backend integration, or model construction.

---

## 13. Clean-room T1 harness

The harness was independently constructed rather than copied from the repository’s native proof harness:

```c
/*
 * Clean-room CBMC harness for mlk_poly_frommsg.
 *
 * FROMMSG-T1:
 * For every message and every coefficient index k in [0, 255],
 * the output coefficient is MLKEM_Q_HALF when message bit k is one
 * and zero when message bit k is zero.
 */

#include <assert.h>
#include <stdint.h>

#include "compress.h"

#if MLKEM_N != 256
#error "FROMMSG-T1 requires MLKEM_N == 256"
#endif

#if MLKEM_INDCPA_MSGBYTES != 32
#error "FROMMSG-T1 requires a 32-byte message"
#endif

void harness(void)
{
  mlk_poly r;
  uint8_t msg[MLKEM_INDCPA_MSGBYTES];
  uint8_t k;
  uint8_t bit;

  mlk_poly_frommsg(&r, msg);

  bit = (uint8_t)((msg[(unsigned)k / 8u] >>
                   ((unsigned)k % 8u)) &
                  1u);

  assert(
    r.coeffs[(unsigned)k] ==
    (bit != 0u ? MLKEM_Q_HALF : 0));
}
```

### 13.1 Important absence of assumptions

The final theorem harness contained:

```text
__CPROVER_assume count: 0
```

No assumption restricted `msg` or forced the desired output.

### 13.2 No source modification

The production worktree remained clean, and the campaign recorded:

```text
PRODUCTION_SOURCE_MODIFIED=NO
```

### 13.3 No target replacement

The final model retained the actual target and helper bodies and recorded no contract-havoc markers.

---

## 14. Direct GOTO-model construction: failed and successful attempts

### 14.1 P0: first linked direct model

The first custom linked model failed validation because unrelated annotation/contract symbols remained dangling, including an example such as:

```text
mlk_poly_reduce::r
```

This was a model-construction failure before theorem solving.

### 14.2 P0R1: prune attempt

Applying:

```text
--drop-unused-functions
```

did not completely remove unrelated annotation symbols. Validation still aborted, with another example such as:

```text
mlk_poly_invntt_tomont::r
```

Again, the theorem had not been disproved.

### 14.3 P0R2: annotation-disabled direct-body model

The successful strategy compiled the required translation unit with the CBMC annotation path disabled, while retaining the production computation.

Key checks:

```text
CBMC_DEFINE_COUNT=0
PREPROCESSED_CONTRACT_MARKER_COUNT=0
PREPROCESSED_TARGET_ASSIGNMENT_COUNT=1
HARNESS_COMPILE_RETURN_CODE=0
SOURCE_COMPILE_RETURN_CODE=0
VALIDATION_RETURN_CODE=0
GOTO_MODEL_VALIDATION=PASS
DANGLING_CONTRACT_SYMBOL_COUNT=0
CONTRACT_HAVOC_MARKER_COUNT=0
```

Retained functions:

```text
harness
mlk_poly_frommsg
mlk_ct_sel_int16
mlk_value_barrier_u8
```

The actual production assignment remained visible:

```c
r->coeffs[8*i+j] =
  mlk_ct_sel_int16(
    (3329+1)/2,
    0,
    msg[i] & mask);
```

### 14.4 Important model hashes

```text
source GOTO:
80fa8ed5df96a8df6dc9ae5cc1d47ca62993eb45b206e5b3cf371fc36ff7dd15

direct pruned GOTO:
7c2de4baa9e780e1c438fb2fd7931299d430fdbad9d4a92e2f8eaffc3e4d6b52
```

---

## 15. Loop mapping

The final direct model exposed three relevant loop identifiers:

```text
mlk_poly_frommsg.0  inner bit loop
mlk_poly_frommsg.1  outer byte loop
mlk_poly_frommsg.2  helper/assertion macro loop
```

The exact unwind set was:

```text
mlk_poly_frommsg.0:9,
mlk_poly_frommsg.1:33,
mlk_poly_frommsg.2:2
```

The extra iteration beyond the number of body executions is expected in CBMC unwinding: it is used to check the loop-exit condition and associated unwinding assertion.

---

## 16. Exact unwind calibration

### 16.1 Exact-bound result

```text
CPROVER_STATUS=SUCCESS
RESULT_COUNT=36
SUCCESS_COUNT=36
FAILURE_COUNT=0
ERROR_COUNT=0
HARNESS_ASSERTION_SUCCESS_COUNT=1
UNWIND_FAILURE_COUNT=0
```

### 16.2 Inner-loop low-bound control

Reducing the inner bound deliberately caused:

```text
RETURN_CODE=10
sole failing property:
mlk_poly_frommsg.unwind.0
```

The semantic T1 assertion was not the failing property.

### 16.3 Outer-loop low-bound control

Reducing the outer bound deliberately caused:

```text
RETURN_CODE=10
sole failing property:
mlk_poly_frommsg.unwind.1
```

### 16.4 Why the low-bound controls matter

These controls demonstrated that:

- the identified loop IDs were correct;
- unwinding assertions were active;
- the chosen exact bounds were meaningfully sufficient;
- success did not result from silently truncating loop execution.

---

## 17. Authoritative T1 proof

The final direct-body theorem returned:

```text
FINAL_PROOF_RETURN_CODE=0
CPROVER_STATUS=SUCCESS
RESULT_COUNT=36
SUCCESS_COUNT=36
FAILURE_COUNT=0
ERROR_COUNT=0
NON_SUCCESS_COUNT=0
HARNESS_ASSERTION_SUCCESS_COUNT=1
UNWIND_FAILURE_COUNT=0
```

Two authoritative runs had identical property/status sets:

```text
REPEATED_RESULT_SET_MATCH=PASS
```

Final campaign summary:

```text
EXACT_BOUND_PROOF=PASS
LOW_BOUND_CALIBRATION=PASS
REPEATED_PROOF=PASS
FUNCTION_RETURN_REACHABLE=PASS
BIT_ZERO_REACHABLE=PASS
BIT_ONE_REACHABLE=PASS
MUTATION_ALWAYS_ZERO_REJECTED=PASS
MUTATION_ALWAYS_HALF_REJECTED=PASS
CONTRACT_HAVOC_PRESENT=NO
PRODUCTION_SOURCE_MODIFIED=NO
MAIN_RETURN_CODE=0
```

---

## 18. Non-vacuity and reachability controls

A successful assertion may be vacuous if the call or assertion site is unreachable. Three deliberate-failure witnesses were therefore used.

### 18.1 Function-return reachability

A deliberately false assertion after `mlk_poly_frommsg` failed with a trace and no unwinding failure.

This demonstrated that:

- the target call executed;
- the function returned;
- the post-call assertion site was reachable.

### 18.2 Bit-zero reachability

A targeted false witness demonstrated a reachable state where the selected message bit was zero.

### 18.3 Bit-one reachability

A corresponding witness demonstrated a reachable state where the selected message bit was one.

### 18.4 Correct interpretation

These intentional failures are positive non-vacuity evidence. Their role is understood from:

- the dedicated harness;
- the property ID;
- the expected failing condition;
- trace presence;
- absence of unwind failures.

---

## 19. Mutation controls

### 19.1 False “always zero” theorem

```c
assert(r.coeffs[k] == 0);
```

CBMC rejected it. A concrete trace included a case such as:

```text
k = 72
r.coeffs[72] = 1665
```

### 19.2 False “always half” theorem

```c
assert(r.coeffs[k] == MLKEM_Q_HALF);
```

CBMC rejected it. A trace included a zero-output case such as:

```text
k = 0
r.coeffs[0] = 0
```

### 19.3 What mutations demonstrate

The model was sensitive to both sides of the intended theorem and did not merely force all coefficients to one constant.

---

## 20. What T1 proves

Under the frozen source, model, constants, architecture, and toolchain, T1 establishes that:

- all 32-byte messages are considered symbolically;
- every index from `0` to `255` is considered symbolically;
- the selected output coefficient exactly matches the corresponding message bit;
- the mapped loops are fully unwound;
- the function can return;
- both bit branches are reachable;
- plausible false constant-output theorems are rejected;
- no source modification occurred;
- no target contract replacement or contract havoc was used;
- no assumption forced the theorem.

---

## 21. What T1 does not prove

T1 does not prove:

- complete ML-KEM correctness;
- complete correctness of every behavior of `mlk_poly_frommsg`;
- every memory-safety property under every calling context;
- timing or side-channel security;
- correctness under every compiler and architecture;
- correctness of all callers;
- correctness of the native contract framework;
- equivalence to every normative statement in FIPS 203;
- unbounded mathematics outside the finite C domains modelled.

The correct thesis wording is:

> The selected exact binary-embedding property was proved for the frozen production implementation and direct-body model.

The incorrect wording would be:

> ML-KEM was completely proved correct.

---

## 22. The initial coverage/non-vacuity crash

The first coverage route used a command of the form:

```bash
cbmc \
  --flush \
  --object-bits 9 \
  --no-standard-checks \
  --no-unwinding-assertions \
  --unwindset \
  mlk_poly_frommsg.0:9,mlk_poly_frommsg.1:33,mlk_poly_frommsg.2:2 \
  --cover cover \
  --show-test-suite \
  --xml-ui \
  NONVACUITY.goto
```

It terminated with:

```text
Invariant check failed
File: ../src/util/std_expr.h:2382
function: not_exprt
Condition: as_const(*this).op().is_boolean()
Reason: Precondition
```

Local status:

```text
134
```

At that point, it was correct to record a **candidate internal CBMC failure**, but not yet correct to call it a general coverage defect.

The final T1 proof remained valid because its accepted non-vacuity evidence used deliberate assertion witnesses rather than the crashing coverage route.

---

## 23. D1 minimisation: the first standalone result

The first minimisation matrix tested:

- the full ML-KEM GOTO model;
- a symbolic Boolean cover;
- an explicit true Boolean;
- an integer true expression;
- a comparison;
- an expression shaped like the original theorem.

Every tested command aborted with the same invariant.

This established that:

- the crash was reproducible outside the large ML-KEM model;
- the target production function was unnecessary to trigger it;
- `--show-test-suite` was unnecessary;
- `--cover cover` alone could trigger it.

However, every standalone source manually declared:

```c
void __CPROVER_cover(_Bool condition);
```

That declaration was a confounder.

The D1 result therefore did not yet establish that canonical coverage was defective.

---

## 24. The decisive D1R1 canonical-versus-redeclared isolation

The expected built-in interface is:

```c
void __CPROVER_cover(__CPROVER_bool condition);
```

D1R1 tested canonical and malformed cases separately.

### 24.1 Canonical sources

The following all worked:

1. no manual declaration, constant expression;
2. no manual declaration, comparison expression;
3. `__CPROVER_bool` variable;
4. C `_Bool` variable passed to the canonical built-in without redeclaring the function.

Each was tested with:

```text
--cover cover
```

and:

```text
--cover cover --show-test-suite
```

Result:

```text
CANONICAL_ABORT_COUNT=0
CANONICAL_NORMAL_COUNT=8
```

### 24.2 Malformed declarations

Wrong `_Bool` form:

```c
void __CPROVER_cover(_Bool condition);
```

Wrong `int` form:

```c
void __CPROVER_cover(int condition);
```

Each was tested with and without `--show-test-suite`.

Result:

```text
WRONG_DECL_ABORT_COUNT=4
REDECLARATION_INDUCED_ABORT_FOUND=YES
ROBUSTNESS_DEFECT_CANDIDATE=YES
GENERAL_COVERAGE_DEFECT_CANDIDATE=NO
```

### 24.3 Symbol-table evidence

Canonical source:

```text
Symbol: __CPROVER_cover
Type: void (__CPROVER_bool)
```

Wrong `_Bool` source:

```text
Symbol: __CPROVER_cover
Type: void (_Bool)
```

Wrong `int` source:

```text
Symbol: __CPROVER_cover
Type: void (signed int)
```

The user declaration replaced the built-in type in the symbol model. Coverage processing later reached an internal precondition requiring a proper Boolean operand.

### 24.4 Corrected scientific interpretation

The initial broad interpretation:

> CBMC’s ordinary coverage function is broken.

was rejected.

The corrected and evidence-supported finding became:

> Canonical coverage works. CBMC has a robustness/type-handling defect when the coverage built-in is manually redeclared with an incompatible parameter type.

Correcting the interpretation after identifying a confounder is a strength of the investigation.

---

## 25. Minimal standalone reproducers

### 25.1 Canonical control

```c
int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
```

Command:

```bash
cbmc 01_canonical.c --function main --cover cover
```

Observed category:

```text
normal return
coverage objective SATISFIED
no internal invariant
```

### 25.2 Wrong `_Bool` declaration

```c
void __CPROVER_cover(_Bool condition);

int main(void)
{
  __CPROVER_cover((_Bool)1);
  return 0;
}
```

Command:

```bash
cbmc 02_wrong_bool.c --function main --cover cover
```

Affected observed category:

```text
fatal termination
Invariant check failed
not_exprt
operand.is_boolean()
```

### 25.3 Wrong `int` declaration

```c
void __CPROVER_cover(int condition);

int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
```

Command:

```bash
cbmc 03_wrong_int.c --function main --cover cover
```

Affected observed category:

```text
fatal termination
Invariant check failed
not_exprt
operand.is_boolean()
```

---

## 26. Cross-version Docker reproduction

### 26.1 Tested image tag: `diffblue/cbmc:6.9.0`

Environment binding:

```text
Image ID:
sha256:67d7d400d0d442c38671a8b5d93eaea9036baf8d4853e518a805c07ba8fdcd01

Repository digest:
diffblue/cbmc@sha256:258f13485446fd53b164caedea6aa88a71bba980be1a93141eb92ea93eb914a5

Reported version:
6.9.0

CBMC binary SHA-256:
6e9f0789673e2df4a5993b01bf33f4a5191fe639d1fa196f46cb8e7f73086fc4
```

Result pattern:

```text
CANONICAL_COVER           return 0
CANONICAL_TESTSUITE       return 0
WRONG_BOOL_COVER          fatal return 139 + invariant
WRONG_BOOL_TESTSUITE      fatal return 139 + invariant
WRONG_INT_COVER           fatal return 139 + invariant
WRONG_INT_TESTSUITE       fatal return 139 + invariant
```

Invariant location:

```text
std_expr.h:2382
function: not_exprt
condition: operand.is_boolean()
```

### 26.2 Tested image tag: `diffblue/cbmc:6.10.0`

Environment binding:

```text
Image ID:
sha256:1e9e9a4548d425ff9ba1a9ef86b4fad7cc0f1ff846239e38359df255b6f187bf

Repository digest:
diffblue/cbmc@sha256:5289f91abddb700d2e4c614018032d078b15aff297328b1a3ae14f73a53efa28

Reported version:
6.10.0

CBMC binary SHA-256:
39e5ac5e2a1b379576d711797b2dd0fb104f382cd8e543109b73436e29052db0
```

Result pattern:

```text
CANONICAL_COVER           return 0
CANONICAL_TESTSUITE       return 0
WRONG_BOOL_COVER          fatal return 139 + invariant
WRONG_BOOL_TESTSUITE      fatal return 139 + invariant
WRONG_INT_COVER           fatal return 139 + invariant
WRONG_INT_TESTSUITE       fatal return 139 + invariant
```

Invariant location:

```text
std_expr.h:2392
function: not_exprt
condition: operand.is_boolean()
```

### 26.3 Why local status 134 and Docker status 139 do not invalidate the match

Signal/exit-code presentation can differ through local wrappers and container boundaries.

The stable diagnostic fingerprint was:

- fatal nonzero termination;
- `Invariant check failed`;
- `not_exprt`;
- failed Boolean operand precondition;
- malformed declarations affected;
- canonical controls unaffected.

The finding therefore relies on the controlled differential and invariant fingerprint, not one mandatory numeric return code.

### 26.4 Version terminology caution

The evidence directly supports:

> Docker image tag `diffblue/cbmc:6.10.0`, reporting CBMC 6.10.0.

It does not require calling 6.10.0 the latest GitHub release. Image-tag evidence, image ID, digest, reported version, and binary hash are the authoritative bindings used here.

---

## 27. Exact discovery timeline

All timestamps are UTC and derive from captured logs.

| Timestamp | Stage | Established result |
|---|---|---|
| 24 Jul 2026 13:50:27 | Native result triage | 419 results: 335 `SUCCESS`, 84 `ERROR`, overall `CPROVER_STATUS=ERROR`. |
| 24 Jul 2026 13:55:17 | Native root-cause extraction | Quantified postcondition/native proof path identified as the problem area. |
| 24 Jul 2026 approximately 13:58–14:10 | Litani job recovery | Direct and wrapper failure recovered; outer status could appear green. |
| 24 Jul 2026 14:39:19 | Solver/property bisection | Control passed; quantified postcondition failed to process or was semantically degraded. |
| 24 Jul 2026 15:00:30 | Counterexample gate | Default-SAT trace rejected because `forall` was ignored and contract state was havoced. |
| 24 Jul 2026 15:27:23 | P0 preflight | Initial direct-model attempt recorded. |
| 24 Jul 2026 15:36:16 | P0R2 | Annotation-disabled direct-body model validated. |
| 24 Jul 2026 15:54:19 | Authoritative R2 | Exact bounds and deliberate low-bound calibrations succeeded. |
| 24 Jul 2026 16:07:42 | Final T1 R3 | Proof, reachability, branch witnesses, and mutation controls completed. |
| 24 Jul 2026 16:25:05 | D1 minimisation | Standalone crash obtained, but `_Bool` redeclaration remained a confounder. |
| **24 Jul 2026 16:38:26** | **D1R1 decisive isolation** | **Eight canonical cases succeeded and four incompatible redeclaration cases crashed. Precise defect isolated.** |
| 24 Jul 2026 17:11:37 | D2 cross-version campaign | Same differential reproduced in Docker image tags 6.9.0 and 6.10.0. |
| 24–25 Jul 2026 | Pinned `develop` attempts | Source pinned, but no completed develop result matrix was obtained. |

### 27.1 Best discovery-date wording

> The precise incompatible-built-in redeclaration defect was isolated on 24 July 2026 at 16:38:26 UTC, and cross-version Docker confirmation was completed later that day at 17:11:37 UTC.

The earlier 16:25:05 result was a preliminary standalone reproduction but still contained an unrecognised confounder.

---

## 28. Pinned `develop` investigation

A source checkout was pinned to:

```text
commit:
f71fdad8e4b0416b0f2ab471670caee893fb8b4c

tree:
8dd3936e80d629e2d98e053e1eea3f563ad9e1c0
```

No completed `develop` test matrix was preserved in the accepted evidence.

### 28.1 Failed build attempt 1

The command used:

```text
--progress=plain
```

with a Docker builder that did not support the option. Compilation did not start.

### 28.2 Failed build attempt 2

A legacy-builder fallback encountered BuildKit-only Dockerfile syntax:

```text
RUN --mount=type=cache,...
```

Again, the CBMC source was not tested.

### 28.3 Failed build attempt 3

A fresh build mounted the authoritative source read-only. CBMC’s ANSI-C library check attempted to create temporary files in the source tree:

```text
__libcheck.c
__libcheck.i
```

and failed with:

```text
Read-only file system
```

This was an experiment-build design problem, not evidence that the `develop` source was affected or fixed.

### 28.4 Safe status

```text
Docker tag 6.9.0 affected: confirmed
Docker tag 6.10.0 affected: confirmed
Pinned develop status: unresolved
```

No develop-status claim should be made from the frozen evidence.

---

## 29. Supported defect mechanism

The canonical built-in expects an internal Boolean parameter:

```c
void __CPROVER_cover(__CPROVER_bool condition);
```

The malformed source replaces it with a C `_Bool` or `int` function type.

The evidence supports this chain:

```text
incompatible manual built-in declaration
        ↓
__CPROVER_cover symbol receives _Bool or signed-int parameter type
        ↓
coverage instrumentation processes the malformed call
        ↓
an expression not recognised as internal Boolean reaches not_exprt
        ↓
not_exprt checks operand.is_boolean()
        ↓
internal invariant terminates the tool
```

Expected robust behaviours could include:

- rejecting the incompatible declaration during type checking;
- preserving the built-in declaration and reporting a conflict;
- normalising the expression safely;
- returning a controlled processing error.

The evidence does not dictate the exact maintainer fix. It demonstrates that internal invariant termination is an undesirable response to user input.

---

## 30. Why this remains a defect even though the source is malformed

Both statements are true:

1. the reproducer misdeclares a CBMC built-in; and
2. CBMC terminates through an internal invariant instead of a controlled diagnostic.

Robust verification tools must expect invalid or malformed inputs and handle them safely.

The malformed trigger lowers likely severity because canonical users can avoid it. It does not make the internal abort correct or desirable.

---

## 31. Why this is not a solver defect

The confirmed failure occurs in expression/type/coverage processing and identifies an internal C++ invariant:

```text
not_exprt
operand.is_boolean()
```

The evidence does not show:

- a SAT solver returning the wrong satisfiability result;
- an SMT solver returning an invalid model;
- a well-formed formula being solved incorrectly;
- a solver-specific disagreement explaining the minimal coverage crash.

The safe classification is:

```text
CBMC robustness/type-handling defect in coverage instrumentation
```

not:

```text
SAT/SMT solver defect
```

---

## 32. Why this is not an ML-KEM defect

The minimal crash reproducer contains no ML-KEM code.

The direct-body T1 campaign separately showed that the selected production computation satisfies the exact theorem.

Therefore, the observed internal coverage failure is not evidence that:

- `mlk_poly_frommsg` computed an incorrect coefficient;
- the ML-KEM algorithm is vulnerable;
- the `mlkem-native` production body caused the invariant.

The original ML-KEM context helped expose the tool problem, but the final tool defect is independent of ML-KEM.

---

## 33. Severity assessment

### 33.1 Factors limiting severity

- canonical usage works;
- the trigger requires an incompatible manual declaration;
- no unsound successful proof was demonstrated;
- no security boundary bypass was shown;
- no arbitrary code execution or disclosure was shown;
- no valid production counterexample was hidden;
- the issue is avoidable by using the built-in correctly.

### 33.2 Factors supporting reportability

- deterministic reproduction;
- tiny standalone program;
- affected pattern in more than one tested version/image;
- internal invariant rather than controlled diagnostic;
- automated verification pipelines may crash;
- maintainers can add a small regression test;
- expected behaviour is clear.

### 33.3 Correct severity wording

> This is a reproducible, maintainer-reportable robustness/type-validation defect. Major or security severity has not been established.

---

## 34. Novelty analysis

### 34.1 What is genuinely original in this case study

The original contribution includes:

1. selecting a real ML-KEM production function;
2. constructing an exact clean-room theorem distinct from the native range contract;
3. auditing the native proof at property and backend level;
4. rejecting a semantically inadmissible counterexample;
5. building a validated real-body GOTO model;
6. calibrating exact unwinding through deliberate insufficient bounds;
7. proving the theorem repeatedly;
8. demonstrating return and both output branches as reachable;
9. rejecting two false mutations;
10. separating a coverage crash from the production model;
11. identifying the wrong built-in declaration as a confounder;
12. adding canonical controls;
13. isolating the precise malformed-declaration trigger;
14. reproducing the controlled differential in two Docker image tags;
15. preserving hashes, commands, outputs, symbols, traces, and limitations.

Even if another person has previously encountered the same underlying bug, this investigative chain is independently produced work.

### 34.2 Safe use of “independently discovered”

It is safe to state:

> The defect was independently discovered and minimised during this case study.

This says how the finding arose. It does not claim global priority.

### 34.3 Targeted public-search result

A targeted public search using combinations of terms such as:

```text
__CPROVER_cover
not_exprt
is_boolean
Invariant check failed
incompatible declaration
```

did not reveal an obvious exact public issue at the time of the investigation.

This is supporting context only. Search results cannot prove universal absence.

### 34.4 Why worldwide first discovery cannot be claimed

The defect could exist in:

- a differently worded issue;
- a closed or unindexed issue;
- a pull request;
- a commit message;
- a mailing-list discussion;
- a private report;
- maintainer knowledge;
- another language or platform;
- a later report.

Maintainer feedback is the strongest way to determine whether the report is new or a duplicate.

### 34.5 Recommended novelty wording

> The original contribution is the independently conducted differential investigation: a selected semantic property of the real `mlk_poly_frommsg` body was verified, while the surrounding failure was minimised to an incompatible declaration of `__CPROVER_cover` that triggers an internal CBMC invariant in affected tested versions. A targeted public search did not reveal an obvious exact match, but worldwide first discovery is not claimed without maintainer confirmation.

### 34.6 Wording that must not be used

Do not claim:

- “This is the first discovery in the world.”
- “Nobody has reported it before.”
- “This is a confirmed zero-day.”
- “The maintainers confirmed it.”
- “This is a major security flaw.”
- “A solver vulnerability was found.”

---

## 35. Findings ledger

| ID | Finding | Status | Interpretation |
|---|---|---|---|
| F1 | Native `mlk_poly_frommsg` campaign did not complete normally | Confirmed locally | Native contract/quantifier/tool path unresolved |
| F2 | Outer workflow could obscure inner failure status | Confirmed locally | Multi-layer status auditing is required |
| F3 | Simple control property passed while quantified postcondition errored | Confirmed | Failure is property/path specific |
| F4 | Default SAT ignored essential `forall` constructs | Confirmed | Counterexample semantics were degraded |
| F5 | Contract write-set abstraction havoced output coefficients | Confirmed in trace | Arbitrary output was not real production computation |
| F6 | Initial direct GOTO models contained dangling unrelated annotation symbols | Confirmed | Model construction failed before theorem solving |
| F7 | Annotation-disabled direct model validated and retained real bodies | Confirmed | Valid direct-body control established |
| F8 | Exact T1 theorem passed | Proved for frozen model | Selected semantic property established |
| F9 | Low inner/outer bounds failed expected unwind properties | Confirmed | Loop mapping and exact bound calibrated |
| F10 | Return, bit-zero, and bit-one states were reachable | Confirmed | Proof was non-vacuous for these gates |
| F11 | Always-zero and always-half mutations were rejected | Confirmed | Proof setup distinguishes both cases |
| F12 | Initial coverage crash used a wrong built-in declaration | Confirmed | First broad interpretation contained a confounder |
| F13 | Canonical coverage cases worked | Confirmed | No general canonical coverage defect |
| F14 | `_Bool` and `int` redeclarations triggered internal invariant | Confirmed | Robustness/type-handling defect |
| F15 | Same differential reproduced in Docker tags 6.9.0 and 6.10.0 | Confirmed | Cross-version tested-image evidence |
| F16 | Pinned `develop` affected/fixed state | Unresolved | No develop claim permitted |
| F17 | Global novelty/first discovery | Unresolved | Independent discovery only; confirmation pending |

---

## 36. Explicitly excluded claims

The final evidence does **not** establish:

```text
ML-KEM implementation vulnerability:        NO
Incorrect mlk_poly_frommsg computation:     NO EVIDENCE
SAT solver defect:                          NO
SMT solver defect:                          NO
General canonical coverage failure:        NO
Unsound verification success:              NO
CBMC security vulnerability:                NOT ESTABLISHED
Major severity:                             NOT ESTABLISHED
Pinned develop affected or fixed:           UNRESOLVED
Worldwide first discovery:                  NOT ESTABLISHED
Maintainer confirmation:                    NO
```

These exclusions should accompany any strong presentation of the result.

---

## 37. Evidence integrity

### 37.1 Authoritative T1 packet

```text
FROMSGT1_AUTHORITATIVE_FINAL_20260724T160742Z.tar.gz

SHA-256:
b656a34aa124ee183bf36cea8d4543d35888ae8436ba8efe94f64cdd4e83b404
```

Manifest:

```text
a56f42a7e43825ed7444225503f6a1e05d223c22c58a0a37383a73be0a354c04
```

Independent audit summary:

```text
Archive members: 164
Regular files: 160
Unsafe paths: 0
Symlinks: 0
Duplicate members: 0
Manifest entries verified: 159/159
Internal hash mismatches: 0
```

### 37.2 Cross-version Docker packet

```text
FROMMSG00D2_CROSS_VERSION_FINAL_20260724T171137Z.tar.gz

SHA-256:
32bbd306cb3bd3e9cc65ede8b01f16da87950dde747f0601bd414c837a046c71
```

Independent audit summary:

```text
Archive members: 106
Regular files: 105
Unsafe paths: 0
Symlinks: 0
Duplicate paths: 0
Manifest entries verified: 104/104
Internal hash mismatches: 0
```

### 37.3 Prior develop-build audit packet

```text
FROMMSG00D2R1_FINAL_20260724T172546Z.tar.gz

SHA-256:
619d7715ed4429e106e447ee935195ad3eef852c195ccadc54a46c7f22c38784
```

This preserves a failed build attempt. It is not a completed develop-result packet.

### 37.4 Initial coverage GOTO hash

```text
NONVACUITY.goto:
02eebdb23fd20a62319af97a7c2adc6d2e1fac3822f36975652a200b7a8b3bdf
```

---

## 38. Trust boundaries used in the investigation

### 38.1 Evidence authority order

The campaign effectively used this authority hierarchy:

1. frozen source and binary hashes;
2. exact executed command;
3. raw stdout and stderr;
4. XML property-level result statuses;
5. GOTO symbol/body/loop inspection;
6. counterexample traces, only if semantically admissible;
7. positive and negative controls;
8. summary scripts;
9. outer orchestration status.

### 38.2 Items deliberately not trusted alone

The investigation did not trust, by itself:

- top-level `make` return code;
- dashboard colour;
- overall XML status without property counts;
- a trace generated after `forall` was ignored;
- contract-replaced execution as proof of the production body;
- a success without unwind calibration;
- a success without reachability controls;
- a crash without a canonical control;
- a version name without image identity and binary hash;
- the word “novel” without caveats.

---

## 39. Assumptions of the T1 theorem

The direct-body result depends on:

- the frozen commit and source hashes;
- `MLKEM_N == 256`;
- `MLKEM_INDCPA_MSGBYTES == 32`;
- the frozen C/GOTO model;
- the retained real target and helper functions;
- the selected CBMC architecture/object configuration;
- complete unwinding of the identified loops;
- CBMC’s model of the relevant C integer and memory semantics.

The proof is universal over the finite domains encoded by the C types, but it remains configuration-specific.

---

## 40. Why the native result and T1 result are not contradictory

The two campaigns used different models and properties.

### Native route

- broad range postcondition;
- function contracts;
- loop contracts;
- dynamic frames;
- helper contract replacement;
- universally quantified array predicates;
- solver/backend processing problems.

### Direct-body T1 route

- actual target and helper bodies;
- no annotation contracts;
- exact single-index symbolic theorem;
- finite concrete C domains;
- fully unwound loops;
- no generated universal quantifier object;
- successful proof and controls.

Therefore, both can be true:

```text
native contract route unresolved
```

and:

```text
direct-body exact theorem proved
```

T1 does not prove that the native contract system should succeed. The native failure does not refute T1.

---

## 41. Mistakes, confounders, and corrections

A complete research record must include what went wrong.

### 41.1 Initial false-green risk

The outer workflow could return success while the inner proof command failed.

**Correction:** inspect raw command, wrapper, job, XML, and property statuses.

### 41.2 Inadmissible counterexample risk

Default SAT emitted a trace after warning that it ignored `forall`.

**Correction:** reject the trace as production-defect evidence and inspect contract havoc.

### 41.3 Dangling annotation model failures

Initial direct GOTO models inherited unrelated annotation symbols.

**Correction:** construct an annotation-disabled real-body translation unit and validate it.

### 41.4 Brittle unwind-output parser

An early script expected a fixed count of properties with “unwind” in the name. Exact-bound simplification meant those properties were not emitted as expected.

**Correction:** calibrate exact and deliberately insufficient bounds directly rather than relying on a fragile name-count assumption.

### 41.5 Incorrect `__CPROVER_cover` redeclaration

The first non-vacuity/minimisation sources declared:

```c
void __CPROVER_cover(_Bool condition);
```

This caused the internal invariant and confounded the first interpretation.

**Correction:** run canonical built-in controls and separate malformed declaration tests.

### 41.6 Initial overbroad tool claim

The first crash could have been described as a general coverage failure.

**Correction:** reject that claim after canonical usage passed. Narrow the finding to incompatible built-in redeclaration handling.

### 41.7 Defect-classifier return-code assumption

A script initially treated only status `134` as the internal abort. Docker runs presented status `139`.

**Correction:** classify by fatal nonzero termination plus the invariant fingerprint, not a single wrapper-level code.

### 41.8 Develop-build script failures

Build attempts failed due to:

- unsupported `--progress` option;
- BuildKit-only Dockerfile instructions under a legacy builder;
- read-only source mounting while CBMC’s build generated temporary source-tree files.

**Correction:** record develop status as unresolved. Do not convert build-environment failures into a source-version conclusion.

### 41.9 Packaging warning in an early D1 archive

An early archive reported:

```text
tar: .: file changed as we read it
```

**Correction:** do not treat that archive as the final publication packet; use later clean packets.

---

## 42. Scientific value of the workflow

### 42.1 Differential localisation

The production theorem succeeded while the malformed coverage workflow failed. This localised the failure away from the selected production computation.

### 42.2 Counterexample admissibility gate

The investigation showed that traces must be checked against warnings and abstraction semantics.

### 42.3 Control-rich formal verification

The result was strengthened through:

- exact-bound positive control;
- insufficient-bound negative controls;
- repeated proof;
- return reachability;
- both branch witnesses;
- mutation rejection;
- canonical tool controls;
- malformed variants;
- cross-version repetition.

### 42.4 Minimisation

A large cryptographic verification failure was reduced to a tiny standalone program. This makes the finding understandable, reproducible, and potentially suitable for a maintainer regression test.

### 42.5 Honest correction

The final claim became narrower after finding the harness confounder. This is a hallmark of reliable research rather than a weakness.

---

## 43. Contribution to the thesis

The contribution is not merely:

> “CBMC crashed.”

The contribution is the complete evidence-driven process:

1. investigate a native high-assurance proof;
2. inspect property-level failures;
3. recover hidden command/status information;
4. bisect properties and backends;
5. reject an invalid counterexample;
6. design an exact clean-room theorem;
7. preserve source/model binding;
8. calibrate loops;
9. prove the selected property;
10. demonstrate non-vacuity;
11. reject false mutants;
12. isolate a separate tool failure;
13. detect the minimisation confounder;
14. add canonical controls;
15. reproduce across versions;
16. limit all claims precisely.

This directly supports a thesis about the usefulness and limitations of AI-assisted formal-verification artifact generation combined with deterministic human review and formal-tool checking.

---

## 44. Threats to validity

### 44.1 Internal validity

Potential threats:

- harness errors;
- wrong loop IDs;
- insufficient unwinding;
- source modification;
- contract replacement;
- unreachable assertions;
- parser mistakes;
- wrapper-status mistakes.

Controls used:

- source hashes and clean worktree;
- GOTO-body inspection;
- exact and low-bound calibration;
- repeated runs;
- reachability witnesses;
- mutations;
- raw-output and XML parsing.

### 44.2 Construct validity

T1 checks one selected property, not complete correctness.

The robustness reproducer checks malformed built-in handling, not canonical coverage in general.

### 44.3 External validity

The result is tied to tested binaries, image tags, configurations, and a frozen source revision. Other CBMC revisions may differ.

### 44.4 Conclusion validity

The cross-version result is strong for the two tested Docker image tags. Develop status and global novelty remain unresolved.

### 44.5 Researcher/tool-assistance validity

Scripts and AI-assisted reasoning helped generate hypotheses and commands, but the final authority was the frozen source, executed tool output, controls, and human interpretation.

---

## 45. Recommended thesis wording

### 45.1 Case-study result

> A clean-room direct-body CBMC campaign established the selected exact binary-embedding property of `mlk_poly_frommsg` for the frozen source revision. During non-vacuity analysis, a separate CBMC failure was minimised to an incompatible manual redeclaration of `__CPROVER_cover`. Canonical coverage usage succeeded, whereas `_Bool` and `int` redeclarations caused an internal `not_exprt` Boolean-expression invariant in the tested CBMC 6.9.0 and 6.10.0 Docker image tags. The evidence therefore localises the failure to tool robustness/type handling rather than the ML-KEM production computation.

### 45.2 Novelty statement

> The investigation independently developed an exact direct-body theorem, an admissibility gate for native counterexamples, an unwind and non-vacuity control suite, and a minimal cross-version reproducer for an incompatible-built-in robustness failure. A targeted public search did not identify an obvious exact matching report, but worldwide first discovery is not claimed without maintainer confirmation.

### 45.3 Limitation statement

> The implementation result is property-specific and configuration-specific. The robustness issue requires malformed use of a CBMC built-in and does not demonstrate a solver defect, a general canonical-coverage failure, unsound success, a security vulnerability, or major severity. Pinned `develop` status was unresolved.

---

## 46. Likely examiner questions and defensible answers

### Q1. Did you prove all of `mlk_poly_frommsg` correct?

No. One exact semantic property was proved for all messages and indices in the frozen model.

### Q2. Did you prove ML-KEM correct?

No. The result is function- and property-specific.

### Q3. Did CBMC find an ML-KEM bug?

No. The native route failed to process correctly, and the direct body passed the selected theorem.

### Q4. Why reject the default-SAT trace?

The backend warned that it ignored essential universal quantifiers, and contract instrumentation havoced output state. The trace was not a faithful execution of the intended proof.

### Q5. Why is the coverage crash a CBMC defect if the declaration was wrong?

Malformed input should receive a controlled diagnostic, not reach an internal invariant.

### Q6. Is canonical coverage broken?

No. Canonical cases passed.

### Q7. Is this a solver defect?

No evidence supports that classification.

### Q8. Why are mutations important?

They show that the model can reject plausible false alternatives and is not vacuously proving a constant output.

### Q9. Why deliberately lower unwind bounds?

To verify the loop mapping and show that insufficient bounds fail exactly the expected unwinding assertions.

### Q10. Was the production source changed?

No. Source hashes and clean-worktree checks were preserved.

### Q11. Was the function replaced by a contract?

No. The final GOTO body retained the target and helper implementations.

### Q12. Is the defect novel?

It was independently discovered in this work, and a targeted public search did not reveal an obvious exact match. Global priority remains unconfirmed.

### Q13. Why not claim a serious vulnerability?

No security impact, unsound proof success, or exploitability was shown. The trigger is malformed use of a built-in.

### Q14. What is the most important methodological lesson?

Verification evidence must be interpreted at the property, model, trace, and control level. Neither a green wrapper nor a red tool output is sufficient by itself.

---

## 47. Evidence directory map

| Stage/directory | Purpose |
|---|---|
| `FROMMSG00A3_NATIVE_RESULT_TRIAGE` | Parse native result structure and property counts |
| `FROMMSG00A4_NATIVE_ERROR_ROOT_CAUSE` | Extract native processing-error details |
| `FROMMSG00A5_LITANI_JOB_RECOVERY` | Recover exact job, command, and return propagation |
| `FROMMSG00A6_SOLVER_PROPERTY_BISECTION` | Compare control and quantified property across routes |
| `FROMMSG00A7_COUNTEREXAMPLE_GATE` | Inspect and reject inadmissible counterexample |
| `FROMMSG00A8_*` | Additional backend tests |
| `FROMSGT1P0_DIRECT_BODY_PREFLIGHT` | Initial direct model |
| `FROMSGT1P0R1_*` | Pruned direct model attempt |
| `FROMSGT1P0R2_ANNOTATION_DISABLED_MODEL` | Validated real-body model |
| `FROMSGT1_AUTHORITATIVE_COMBINED_R2` | Exact and low-bound proof calibration |
| `FROMSGT1_AUTHORITATIVE_FINAL_R3` | Final proof, reachability, and mutation controls |
| `FROMMSG00D1_COVERAGE_ABORT_MINIMIZATION` | Initial standalone crash reduction |
| `FROMMSG00D1R1_CANONICAL_COVER_ISOLATION` | Decisive canonical/malformed separation |
| `FROMMSG00D2_CROSS_VERSION_*` | Docker image-tag comparison |
| `FROMMSG00D2R1_*` | Failed pinned-develop build audit |
| `FROMMSG00D3_*` | Later develop-build attempts; no accepted develop matrix |

---

## 48. Principal artifact hashes

```text
T1 authoritative packet:
b656a34aa124ee183bf36cea8d4543d35888ae8436ba8efe94f64cdd4e83b404

T1 manifest:
a56f42a7e43825ed7444225503f6a1e05d223c22c58a0a37383a73be0a354c04

cross-version packet:
32bbd306cb3bd3e9cc65ede8b01f16da87950dde747f0601bd414c837a046c71

develop-build audit packet:
619d7715ed4429e106e447ee935195ad3eef852c195ccadc54a46c7f22c38784

source compress.c:
9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad

source compress.h:
0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

T1 harness:
657afc885742ee6bbef421dbf336c07ed0b40f95a92ff251ffb56122dc285266

direct source GOTO:
80fa8ed5df96a8df6dc9ae5cc1d47ca62993eb45b206e5b3cf371fc36ff7dd15

direct pruned GOTO:
7c2de4baa9e780e1c438fb2fd7931299d430fdbad9d4a92e2f8eaffc3e4d6b52

initial non-vacuity GOTO:
02eebdb23fd20a62319af97a7c2adc6d2e1fac3822f36975652a200b7a8b3bdf
```

---

## 49. Recommended maintainer-report content

A future maintainer report should contain only the minimal necessary technical material:

1. canonical control;
2. `_Bool` reproducer;
3. optional `int` reproducer;
4. exact command;
5. expected controlled diagnostic;
6. actual invariant;
7. affected image tags, image IDs/digests, and binary hashes;
8. statement that canonical coverage works;
9. statement that `--show-test-suite` is not required;
10. explicit non-claims about solvers, ML-KEM, security, and severity.

A concise issue title could be:

```text
Internal invariant when __CPROVER_cover is redeclared with an incompatible parameter type
```

---

## 50. Future technical work

Future work, not completed findings:

1. complete a build/test of a current pinned `develop` revision;
2. search closed issues, pull requests, and commit history more exhaustively;
3. submit the minimal report to maintainers;
4. obtain duplicate/new/fixed classification;
5. add a regression test;
6. investigate the preferred implementation fix;
7. continue the separate quantified-contract investigation;
8. compare native contract results after any relevant CBMC fix;
9. preserve maintainer feedback as thesis evidence.

---

## 51. Final scientific classification

```text
DIRECT_BODY_T1_SELECTED_PROPERTY:
PROVED_IN_FROZEN_CAMPAIGN

OFFICIAL_CBMC_6_9_0_DOCKER_TAG:
ROBUSTNESS_PATTERN_REPRODUCED

OFFICIAL_CBMC_6_10_0_DOCKER_TAG:
ROBUSTNESS_PATTERN_REPRODUCED

PINNED_DEVELOP_STATUS:
UNRESOLVED

MINIMAL_STANDALONE_REPRODUCER:
YES

MATCHING_CANONICAL_CONTROL:
YES

INCOMPATIBLE_BOOL_VARIANT:
YES

INCOMPATIBLE_INT_VARIANT:
YES

COVER_ONLY_REPRODUCTION:
YES

SHOW_TEST_SUITE_REQUIRED:
NO

INTERNAL_NOT_EXPR_BOOLEAN_INVARIANT:
YES

SOLVER_DEFECT_ESTABLISHED:
NO

MLKEM_IMPLEMENTATION_DEFECT_ESTABLISHED:
NO

GENERAL_CANONICAL_COVERAGE_DEFECT_ESTABLISHED:
NO

UNSOUND_SUCCESS_ESTABLISHED:
NO

SECURITY_VULNERABILITY_ESTABLISHED:
NO

MAJOR_SEVERITY_ESTABLISHED:
NO

GLOBAL_FIRST_DISCOVERY_ESTABLISHED:
NO

MAINTAINER_CONFIRMATION:
NO
```

---

## 52. Strongest supported claim

> In the tested CBMC 6.9.0 and 6.10.0 Docker image tags, canonical `__CPROVER_cover` usage succeeds normally, whereas manually redeclaring that built-in with an incompatible `_Bool` or `int` parameter and requesting `--cover cover` causes an internal `not_exprt` Boolean-expression invariant instead of a controlled incompatible-declaration diagnostic. A separate frozen direct-body campaign proved the selected `mlk_poly_frommsg` binary-embedding property, so the internal coverage failure is not evidence of an ML-KEM implementation defect. The defect was independently isolated during this case study on 24 July 2026 at 16:38:26 UTC and cross-version confirmed later that day; worldwide first discovery is not claimed without maintainer confirmation.

---

## Appendix A. Compact result matrices

### A.1 Direct-body theorem

```text
Exact-bound proof                 PASS
Inner low-bound calibration       PASS: unwind.0 failed
Outer low-bound calibration       PASS: unwind.1 failed
Repeated authoritative proof      PASS
Function return reachable         PASS
Bit zero reachable                PASS
Bit one reachable                 PASS
Always-zero mutant rejected       PASS
Always-half mutant rejected       PASS
Contract havoc                    ABSENT
__CPROVER_assume                   ABSENT
Production modification           ABSENT
```

### A.2 Local canonical isolation

```text
Canonical cover/test-suite cases          8 normal
Incompatible redeclaration cases          4 internal aborts
Canonical abort count                     0
Wrong declaration abort count             4
General canonical coverage defect         NO
Redeclaration robustness defect           YES
```

### A.3 Docker comparison

```text
Environment                  Canonical cases       Wrong declaration cases
diffblue/cbmc:6.9.0          2/2 normal            4/4 fatal invariant
diffblue/cbmc:6.10.0         2/2 normal            4/4 fatal invariant
```

---

## Appendix B. Terminology

### `__CPROVER_bool`

CBMC’s internal Boolean type used by built-ins such as `__CPROVER_cover`.

### `_Bool`

The C language Boolean type. A `_Bool` value can be passed to the canonical built-in after normal type handling, but manually redefining the built-in itself with `_Bool` changes its symbol type.

### Contract havoc

Nondeterministic assignment to memory allowed by a function contract’s write set. It models effects permitted by the contract and must not be confused with computation by the real body.

### Direct-body proof

Verification that retains and executes/symbolically interprets the implementation body rather than replacing the target with a contract abstraction.

### Unwinding assertion

A CBMC property checking that a configured loop unwind bound was sufficient.

### Non-vacuity

Evidence that a proof is not succeeding merely because the target path or assertion is unreachable.

### Mutation control

A deliberately false alternative theorem used to confirm that the model and proof setup can reject incorrect claims.

### Processing error

A tool failure to construct or solve the verification problem normally. It is not automatically a program-property violation.

### Inadmissible counterexample

A trace that cannot support the claimed conclusion because essential semantics were ignored or abstracted away.

---

## Appendix C. Decision log

| Decision | Reason |
|---|---|
| Do not call the native XML `ERROR` a program bug | No ordinary valid failure trace was established |
| Reject default-SAT counterexample | Essential universal quantifiers were ignored |
| Build a clean-room theorem | Needed a direct production-body control |
| Disable annotation path for P0R2 | Unrelated dangling contract symbols prevented a valid model |
| Use symbolic `uint8_t k` | Exactly covers all 256 coefficient indices |
| Use low-bound runs | Demonstrates exact loop mapping and sufficient bounds |
| Add reachability witnesses | Prevents vacuous interpretation |
| Add mutations | Demonstrates proof sensitivity |
| Replace crashing cover witnesses with assertion witnesses for final T1 | Coverage route was not yet understood |
| Run D1 minimisation | Separate tool failure from ML-KEM |
| Add D1R1 canonical controls | Detect the built-in redeclaration confounder |
| Reject general coverage-defect claim | Canonical coverage worked |
| Classify as robustness/type handling | Matches the isolated trigger and invariant |
| Avoid solver claim | Failure is in expression/coverage processing |
| Avoid global novelty claim | Public search and maintainer status are incomplete |
| Mark develop unresolved | No completed accepted develop matrix exists |

---

## Appendix D. Publication-safe summary

> The `mlk_poly_frommsg` case study produced a successful property-specific direct-body proof and a separate tool-robustness finding. The proof established the exact message-bit to coefficient mapping for all messages and indices in the frozen model, with exact unwind, reachability, repetition, and mutation controls. The tool finding was reduced to incompatible manual declarations of `__CPROVER_cover`, which triggered an internal Boolean-expression invariant under coverage instrumentation in the tested CBMC 6.9.0 and 6.10.0 Docker image tags, while canonical controls succeeded. The work does not claim an ML-KEM flaw, a solver flaw, a general canonical coverage failure, a security vulnerability, major severity, or worldwide first discovery.

---

**End of technical record.**
