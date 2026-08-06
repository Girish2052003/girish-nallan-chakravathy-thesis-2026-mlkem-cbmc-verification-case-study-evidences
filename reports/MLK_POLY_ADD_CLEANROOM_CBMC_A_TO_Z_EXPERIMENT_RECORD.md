# Independent FIPS-Domain CBMC Verification of `mlk_poly_add`

## Complete A-to-Z Experiment Record

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Document type:** Self-contained technical experiment record  
**Target project:** `pq-code-package/mlkem-native`  
**Target function:** `mlk_poly_add`  
**Repository commit:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Selected parameter set:** ML-KEM-768  
**Verification tool:** CBMC 6.9.0  
**GOTO compiler:** `goto-cc` 6.9.0  
**Successful run timestamp:** `2026-07-16T01:32:25Z`  
**Successful results directory:** `cleanroom_results/mlk_poly_add_768_20260716T013225Z`  
**Final status:** `VERIFICATION SUCCESSFUL`  
**Reported result:** `0 of 341 failed`

---

## 1. Executive Summary

This experiment independently produced and evaluated a CBMC harness for the production
`mlk_poly_add` function in `mlkem-native`. The original repository harness for this function was
not inspected, copied, invoked, or used as an input to the generated harness. The experiment was
grounded in:

1. the production function body;
2. the production type and constant definitions;
3. ordinary source comments and API documentation;
4. selected call-site locations;
5. FIPS 203 mathematical semantics for ML-KEM polynomial representations and addition; and
6. a controlled CBMC build that directly executed the production C implementation.

The generated harness models arbitrary symbolic polynomials whose coefficients are unsigned
canonical representatives in `Z_q`, where `q = 3329`. It calls the real two-argument in-place
`mlk_poly_add` implementation and checks:

- exact coefficient-wise integer addition;
- the derived output interval `[0, 2q-2]`;
- correspondence with polynomial addition modulo `q`;
- preservation of read-only operands;
- commutativity;
- additive identity;
- parameter binding to `n = 256` and `q = 3329`; and
- CBMC-generated memory, pointer, bounds, overflow, conversion, shift, and loop-unwinding
  obligations enabled by the verification command.

The first run built successfully but failed one harness-infrastructure property because a
nondeterministic helper was declared without a body. The target implementation and all explicit
semantic properties already passed in that run. The harness was repaired by giving the helper a
small body returning an uninitialised local `int16_t`, preserving symbolic nondeterminism while
eliminating the missing-body property. No production code, assumptions, target assertions, or
semantic properties were weakened.

The corrected run completed successfully:

```text
** 0 of 341 failed (1 iterations)
VERIFICATION SUCCESSFUL

build_exit=0
cbmc_text_exit=0
cbmc_json_exit=0
final_status=VERIFICATION_SUCCESSFUL
```

The defensible conclusion is:

> Under the stated canonical-input assumptions, repository commit, ML-KEM-768 build
> configuration, portable C implementation, and enabled CBMC checks, the reachable execution of
> `mlk_poly_add` satisfies the specified exact-addition, range, modulo-`q`, frame,
> commutativity, identity, and safety properties for all symbolic inputs permitted by the
> harness.

This result is strong but property-specific. It is not a proof of the entire ML-KEM
implementation, every internal non-canonical coefficient representation, native assembly
backends, side-channel resistance, or all possible aliasing conditions.

---

## 2. Experiment Objective

The experiment addressed the following practical research question:

> Can a usable CBMC verification harness for `mlk_poly_add` be derived independently from
> FIPS 203, production C code, types, constants, and ordinary implementation context without
> viewing the repository's original harness?

The experiment had two connected goals:

1. **Harness-generation goal:** produce an independently authored candidate harness that is
   meaningfully different in structure from a minimal direct contract wrapper.
2. **Verification goal:** determine whether CBMC can prove the selected functional and safety
   properties against the real production implementation.

The experiment did not seek to prove the complete ML-KEM scheme. It focused on one small,
well-scoped production function and a clearly declared input domain.

---

## 3. Target Identification

### 3.1 Repository

```text
Repository path:
/home/girish/THESIS-2026/mlkem-native

Remote:
https://github.com/pq-code-package/mlkem-native.git

Branch:
main

Commit:
d9613cf60de3132d32475c102d8c2781d84feb34
```

The runner verifies the current Git commit before building. A mismatch causes the experiment to
stop rather than silently verifying a different revision.

### 3.2 Target function

The production function is located in:

```text
mlkem/src/poly.c
```

The supplied source location was:

```text
line 229: void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
```

The executable body is:

```c
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;
  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] = (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }
}
```

The function is destructive: `r` is both an input and the output accumulator. The second operand
`b` is read-only.

### 3.3 Production representation

The production type is:

```c
typedef struct
{
  int16_t coeffs[MLKEM_N];
} MLK_ALIGN mlk_poly;
```

The supplied parameter definitions are:

```c
#define MLKEM_N 256
#define MLKEM_Q 3329
```

Therefore, each production polynomial contains 256 signed 16-bit coefficients.

### 3.4 Located production call sites

The clean-room input collection located the following production references:

```text
mlkem/src/poly_k.c:278: mlk_poly_add(&r->vec[i], &b->vec[i]);
mlkem/src/indcpa.c:571: mlk_poly_add(v, epp);
mlkem/src/indcpa.c:572: mlk_poly_add(v, k);
```

Only locations were collected at this stage. Full surrounding call-site context was not used in
the successful canonical-domain experiment. Consequently, the current proof does not claim to
characterise every internal bound present at every production call site.

---

## 4. FIPS 203 Basis

The experiment used the following FIPS 203 facts.

### 4.1 Ring parameters

FIPS 203 fixes:

```text
n = 256
q = 3329
```

It defines:

```text
R_q = Z_q[X] / (X^n + 1)
```

and represents a polynomial by a length-256 coefficient array.

### 4.2 Modular representation

FIPS 203 treats elements of `Z_q` as an abstract modular data type. Assignments to modular
variables imply reduction modulo `q`, while the standard does not prescribe a unique concrete
machine representation or reduction strategy.

This distinction is essential: the mathematical result is modulo `q`, but an efficient C
implementation may temporarily store a congruent non-canonical representative.

### 4.3 Coordinate-wise addition

FIPS 203 specifies that addition of polynomial and NTT representations is coordinate-wise.
For two coefficient arrays `a` and `b`, the mathematical coefficient result is:

```text
(a[i] + b[i]) mod q
```

for every index `i`.

### 4.4 Algorithmic use

K-PKE.Encrypt, Algorithm 14, performs polynomial additions when forming the encryption
polynomial. The production `mlk_poly_add` operation is therefore connected to a concrete
algorithmic use in the standard rather than being an isolated utility with no specification
context.

### 4.5 Reference

National Institute of Standards and Technology (2024), *Module-Lattice-Based
Key-Encapsulation Mechanism Standard*, FIPS 203, DOI: `10.6028/NIST.FIPS.203`.

Relevant sections include:

- Section 2.3: mathematical symbols and `n`, `q`, and `R_q`;
- Section 2.4.1: modular data types and implicit reduction;
- Section 2.4.4: polynomial and NTT coefficient-array representations;
- Section 2.4.5: coordinate-wise polynomial and NTT addition;
- Algorithm 14: K-PKE.Encrypt.

---

## 5. Clean-Room and Provenance Boundary

### 5.1 Information intentionally used

The harness was derived from:

- repository identity and commit;
- `mlk_poly_add` production body;
- function declaration and ordinary comments;
- `mlk_poly` type;
- `MLKEM_N` and `MLKEM_Q`;
- relevant build and namespace information;
- production call-site locations;
- FIPS 203;
- CBMC and `goto-cc` availability.

### 5.2 Information intentionally excluded

The following were not intentionally inspected before harness generation:

- the repository's existing `mlk_poly_add` harness;
- existing CBMC result logs for that harness;
- existing counterexample traces;
- existing repair plans;
- proof-result JSON files;
- generated harnesses from earlier experiments;
- the original harness's exact assertions and assumptions.

### 5.3 Important contamination disclosure

The source extraction unintentionally included repository-embedded formal annotations:

- the existing `__contract__` declaration in `poly.h`;
- existing `requires`, `ensures`, and `assigns` clauses;
- existing `__loop__` annotations and loop invariants in `poly.c`.

Therefore, the strictest accurate classification is:

> **Original-harness-blind, but not completely formal-artefact-blind.**

This limitation must be disclosed. The current experiment cannot honestly be called a perfectly
blind clean-room generation with respect to all formal artefacts.

However:

- the original harness itself was not viewed;
- the generated harness was not a copy of the embedded contract;
- the final harness uses a separate canonical FIPS input profile;
- the final harness adds relational and metamorphic properties;
- embedded contracts and loop annotations were disabled during the direct BMC run because the
  build did not define the repository's `CBMC` preprocessing mode.

### 5.4 What can be claimed about independence

A defensible statement is:

> The harness was independently authored without viewing or invoking the repository's original
> `mlk_poly_add` harness. Its structure, canonical-domain assumptions, modulo-`q` refinement,
> frame checks, commutativity check, and identity check provide evidence of independent design.
> Absolute uniqueness relative to an unseen original harness has not yet been established.

Absolute novelty cannot be proven merely by not looking at the original harness. A post-freeze
comparison may later establish exact syntactic and semantic differences, but that comparison
must occur only after preserving the current harness and result hashes.

---

## 6. Harness Design

### 6.1 Symbolic inputs

The harness creates two `mlk_poly` objects, `a` and `b`. Each coefficient is populated using a
local function that returns an uninitialised `int16_t`. In CBMC, the uninitialised local is a
symbolic value.

```c
static int16_t cleanroom_nondet_int16(void)
{
  int16_t value;
  return value;
}
```

This design avoids a missing-body property while retaining symbolic input generation.

### 6.2 Canonical FIPS input domain

For every coefficient:

```text
0 <= a[i] < q
0 <= b[i] < q
```

With `q = 3329`, each coefficient is one of the 3329 unsigned canonical representatives of
`Z_q`.

The harness does not test a single sample. It symbolically covers all input arrays satisfying
these assumptions.

### 6.3 Derived arithmetic safety

From the canonical assumptions:

```text
0 <= a[i] <= q - 1
0 <= b[i] <= q - 1
```

Therefore:

```text
0 <= a[i] + b[i] <= 2q - 2
```

For `q = 3329`:

```text
0 <= a[i] + b[i] <= 6656
```

Since `6656 < INT16_MAX`, the implementation's cast to `int16_t` is safe in this domain.

This overflow-safety condition is derived mathematically from the input assumptions rather than
inserted as an arbitrary independent assumption.

### 6.4 Distinct objects and aliasing

The harness allocates separate automatic objects and constructs each test call so that the
accumulator and the read-only operand are disjoint:

```text
sum_ab and b
sum_ba and a
identity_result and zero
```

No pointer-separation assumption is injected. Disjointness follows from the object construction.

### 6.5 Frozen input copies

The harness stores:

```text
a_before = a
b_before = b
```

before target calls. These frozen copies support exact post-state checks and frame conditions.

### 6.6 Three target executions

The harness directly invokes the real target three times:

```c
mlk_poly_add(&sum_ab, &b);
mlk_poly_add(&sum_ba, &a);
mlk_poly_add(&identity_result, &zero);
```

These calls support ordinary functional checking and relational/metamorphic checking.

---

## 7. Assumption Ledger

### A1. Repository revision

The target repository must be at:

```text
d9613cf60de3132d32475c102d8c2781d84feb34
```

The runner treats a mismatch as an error.

### A2. Parameter set and constants

The run selects ML-KEM-768 with:

```text
-DMLK_CONFIG_PARAMETER_SET=768
```

The harness asserts rather than assumes:

```text
MLKEM_N == 256
MLKEM_Q == 3329
```

A configuration drift must produce a visible property failure.

### A3. Canonical input coefficients

For each `i`:

```text
0 <= a[i] < 3329
0 <= b[i] < 3329
```

This is the principal semantic restriction of the current proof.

### A4. Distinct target-call objects

The arguments are distinct automatic objects by construction. The experiment does not cover an
illegal call in which `r` and `b` designate the same object.

### A5. Portable C path

The experiment does not enable the native arithmetic backend. The proof applies to the portable C
implementation compiled from `mlkem/src/poly.c`.

### A6. Direct execution rather than contract replacement

The build does not define the repository's `CBMC` preprocessing mode. Existing source contracts
and loop annotations are therefore not used as replacements for target execution in this run.

### A7. Finite loop bound

The relevant loops process 256 coefficients. The CBMC command uses:

```text
--unwind 257
--unwinding-assertions
```

The unwinding assertion prevents a successful result if an additional unexplored iteration is
required.

### A8. Tool semantics

The result relies on CBMC 6.9.0 and its modelling of C, symbolic uninitialised local variables,
instrumented safety checks, and SAT-based bounded model checking.

---

## 8. Explicit Verification Properties

### P0. FIPS parameter binding

```text
MLKEM_N == 256
MLKEM_Q == 3329
```

Purpose: ensure that the experiment is not silently run against incompatible ring parameters.

### P1. Exact accumulator semantics

For every coefficient:

```text
sum_ab[i] == a_before[i] + b_before[i]
```

This proves the implementation-level unreduced addition in the canonical domain.

### P2. Derived output lower bound

```text
sum_ab[i] >= 0
```

### P3. Derived output upper bound

```text
sum_ab[i] <= 2q - 2
```

For the selected parameters:

```text
sum_ab[i] <= 6656
```

### P4. FIPS modulo-`q` refinement

```text
sum_ab[i] mod q == (a_before[i] + b_before[i]) mod q
```

This connects the stored implementation representative to FIPS polynomial addition.

Because the canonical sum is nonnegative in this harness, C's remainder operation agrees with the
intended nonnegative modulo representative.

### P5. Read-only input frame

```text
a[i] == a_before[i]
b[i] == b_before[i]
zero[i] == 0
```

The calls must not modify the objects supplied as read-only operands.

### P6. Commutativity

```text
a + b == b + a
```

This is checked by two separate target executions and comparison of resulting coefficients.

### P7. Additive identity

```text
a + 0 == a
```

This is checked by a third target execution.

---

## 9. Tool-Generated Safety Properties

The runner enables:

```text
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
```

For the reached `mlk_poly_add` function, the output explicitly reported success for:

- loop-counter overflow checking;
- upper bounds of `r->coeffs[i]`;
- upper bounds of `b->coeffs[i]`;
- signed addition overflow;
- `int16_t` conversion overflow;
- null-pointer dereference checks;
- invalid-pointer checks;
- deallocated-object checks;
- dead-object checks;
- outside-object-bounds checks;
- invalid-integer-address checks.

The result included target-specific property identifiers under:

```text
PQCP_MLKEM_NATIVE_MLKEM768_poly_add
```

This confirms that the production target body was present in the GOTO model and instrumented.

---

## 10. Build Configuration

### 10.1 GOTO build

The corrected runner builds:

```bash
goto-cc   -I.   -Imlkem   -Imlkem/src   -DMLK_CONFIG_PARAMETER_SET=768   cleanroom_mlk_poly_add_fips_relational_harness_v2.c   mlkem/src/poly.c   -o <results-directory>/cleanroom_poly_add.goto
```

### 10.2 Important configuration decisions

- `mlkem/src/poly.c` is compiled directly.
- `MLK_CONFIG_PARAMETER_SET=768` selects the tested namespace/configuration.
- `MLK_BUILD_INTERNAL` is not redundantly supplied on the command line.
- the `CBMC` preprocessing macro is not defined;
- native arithmetic is not enabled;
- no existing harness is linked;
- no production source code is modified.

### 10.3 CBMC text run

```bash
cbmc <goto-model>   --function main   --bounds-check   --pointer-check   --pointer-overflow-check   --signed-overflow-check   --unsigned-overflow-check   --conversion-check   --div-by-zero-check   --undefined-shift-check   --unwind 257   --unwinding-assertions   --trace
```

### 10.4 CBMC JSON run

A second invocation repeats the same verification configuration using:

```text
--json-ui
```

This provides a machine-readable result and an independent exit status.

---

## 11. Experiment Chronology

### 11.1 Preflight

The following conditions were confirmed:

```text
Repository commit:
d9613cf60de3132d32475c102d8c2781d84feb34

CBMC:
6.9.0 (cbmc-6.9.0)

goto-cc:
6.9.0

Architecture:
x86_64

Operating system:
Linux
```

The original Git working tree was clean before adding the experimental files.

### 11.2 Harness version 1

The first harness declared:

```c
extern int16_t cleanroom_nondet_int16(void);
```

The GOTO build succeeded. CBMC then reported one failure:

```text
no body for callee cleanroom_nondet_int16
```

Summary:

```text
build_exit=0
cbmc_text_exit=10
cbmc_json_exit=10
final_status=FAILED_OR_INCONCLUSIVE
```

The run reported:

```text
1 of 342 failed
VERIFICATION FAILED
```

Critically, all explicit semantic assertions and target-specific `mlk_poly_add` properties were
already `SUCCESS`. The failure was not evidence of a defect in `mlk_poly_add`; it was a harness
plumbing defect.

### 11.3 Root-cause classification

The failure was classified as:

```text
HARNESS_INFRASTRUCTURE_DEFECT:
symbolic helper declared but not defined while no-body checking remained active
```

The following inappropriate responses were rejected:

- disabling no-body checking merely to hide the property;
- weakening target assertions;
- narrowing inputs further;
- modifying production code;
- deleting the failed run.

### 11.4 Harness version 2 repair

The helper was changed to:

```c
static int16_t cleanroom_nondet_int16(void)
{
  int16_t value;
  return value;
}
```

This preserves symbolic input generation and supplies a valid function body.

The runner was also corrected to remove the unnecessary command-line definition of
`MLK_BUILD_INTERNAL`, eliminating a harmless redefinition warning.

No semantic property or input assumption was weakened.

### 11.5 Successful version 2 run

The corrected run produced:

```text
** 0 of 341 failed (1 iterations)
VERIFICATION SUCCESSFUL
```

Summary:

```text
build_exit=0
cbmc_text_exit=0
cbmc_json_exit=0
final_status=VERIFICATION_SUCCESSFUL
```

Results directory:

```text
cleanroom_results/mlk_poly_add_768_20260716T013225Z
```

---

## 12. Result Interpretation

### 12.1 Meaning of `0 of 341 failed`

CBMC generated and evaluated 341 reported properties in the GOTO model. None was reported as
failed.

This includes:

- explicit harness assertions;
- safety properties instrumented in the harness;
- safety properties instrumented in `mlk_poly_add`;
- additional reported properties associated with other compiled functions.

### 12.2 Important reachability caution

The GOTO model contains the complete compiled `poly.c`, and the output may list properties for
functions not called from `main`. A `SUCCESS` label on an unreachable function property may be
vacuous.

Therefore, the following claim would be too strong:

> CBMC proved all 341 properties for every function in `poly.c`.

The correct interpretation is:

> Zero reported properties failed, and the target-specific `mlk_poly_add` properties and explicit
> harness assertions succeeded on the reachable execution from `main`.

### 12.3 Meaning of `1 iterations`

The message does not mean that only one concrete polynomial pair was tested. The coefficients
were symbolic. CBMC reasoned over every assignment satisfying the assumptions.

The iteration count concerns the verification engine's solving process, not the number of unit
test inputs.

### 12.4 Text and JSON agreement

Both CBMC invocations returned exit code zero:

```text
cbmc_text_exit=0
cbmc_json_exit=0
```

This agreement reduces the risk that success was inferred from a single presentation format or
misread console output.

---

## 13. What Was Proved

Within the exact experiment boundary, the following statement is supported:

For every pair of 256-coefficient polynomials `a` and `b` satisfying:

```text
0 <= a[i] < 3329
0 <= b[i] < 3329
```

for all indices `i`, and for the distinct-object calls constructed by the harness:

1. `mlk_poly_add` terminates within the verified loop bound;
2. each result coefficient equals the exact mathematical integer sum;
3. each result coefficient is in `[0, 6656]`;
4. the result cannot overflow the target `int16_t` representation in this domain;
5. reducing each stored result modulo 3329 yields FIPS coefficient addition in `Z_q`;
6. read-only operands remain unchanged;
7. reversing operand order produces the same coefficient array;
8. adding the zero polynomial leaves the accumulator unchanged;
9. reached target array accesses are within bounds;
10. reached target pointer dereferences satisfy the enabled pointer checks;
11. reached target signed arithmetic and narrowing conversion satisfy the enabled overflow checks;
12. the parameter binding matches FIPS 203; and
13. the target body was executed directly rather than replaced by the existing function contract.

This is a genuine universal symbolic result over the declared input domain, not a finite set of
hand-picked examples.

---

## 14. What Was Not Proved

The experiment does not establish:

1. correctness for every arbitrary pair of `int16_t` coefficient arrays;
2. correctness for all signed or non-canonical internal representatives;
3. the exact bounds at every production call site;
4. legality or correctness when `r` aliases `b`;
5. the native arithmetic backend;
6. architecture-specific assembly;
7. constant-time behaviour or side-channel resistance;
8. absence of data-dependent timing;
9. full correctness of `poly.c`;
10. correctness of NTT, inverse NTT, reduction, compression, encoding, or decoding;
11. end-to-end correctness of K-PKE or ML-KEM;
12. cryptographic security of ML-KEM;
13. equivalence across compilers or all C implementation-defined behaviours;
14. all parameter sets, because only ML-KEM-768 was actually executed in the reported successful
    run;
15. absolute syntactic novelty relative to the unseen original repository harness; or
16. perfect clean-room independence from all formal annotations, because embedded source contracts
    and invariants were accidentally exposed during input collection.

These limitations do not invalidate the proof. They define its sound scope.

---

## 15. Distinctness From the Existing `mlkem-native` Harness

### 15.1 Evidence of distinct design

The generated harness is characterised by:

- a canonical FIPS coefficient domain;
- asserted FIPS parameter binding;
- three independent target calls;
- frozen input copies;
- exact unreduced integer semantics;
- a modulo-`q` refinement property;
- derived `[0, 2q-2]` bounds;
- read-only operand frame checks;
- a commutativity relation;
- an additive-identity relation;
- a dedicated reproducibility runner;
- text and JSON verification runs; and
- commit and hash recording.

This is more than a direct wrapper around a single postcondition.

### 15.2 Relationship to the exposed source contract

The exposed repository contract stated, in essence:

- operands must be disjoint;
- each sum must fit in `int16_t`;
- the result equals the old accumulator plus `b`;
- only `r` is assigned.

The new harness independently adds:

- a specific FIPS canonical input profile;
- a mathematically derived overflow bound rather than a per-element fit assumption;
- modulo-`q` refinement;
- parameter binding;
- explicit input-frame assertions;
- commutativity;
- identity;
- dual text/JSON evidence generation;
- direct target execution with embedded contracts disabled.

### 15.3 Exact novelty status

The strongest honest conclusion is:

> The generated harness is independently authored and structurally distinct in several documented
> ways. It was produced without viewing the original repository harness. Because that harness
> remains unseen, absolute non-overlap cannot yet be proven. Because source-level contracts and
> invariants were visible, the experiment is not perfectly blind to every existing formal idea.

A later comparison should be performed only after freezing:

- the v2 harness;
- its SHA-256 hash;
- the runner;
- the complete result directory;
- the result archive hash.

That comparison can then classify:

- exact assertion overlap;
- assumption overlap;
- structural overlap;
- property-family overlap;
- unique properties in each harness;
- differences in build and evidence generation.

---

## 16. Validity and Vacuity Analysis

### 16.1 Assumption satisfiability

The assumptions are satisfiable. The all-zero polynomials are one concrete witness:

```text
a[i] = 0
b[i] = 0
```

for every coefficient.

### 16.2 Nontrivial symbolic domain

The input domain is not limited to zero. Every coefficient may independently take any value in
`0..3328`, subject to CBMC's symbolic model.

### 16.3 Target reachability

The harness directly calls `mlk_poly_add` three times. The CBMC output includes target-specific
properties for the namespaced ML-KEM-768 function, confirming inclusion and instrumentation of
the target.

### 16.4 Future coverage hardening

Future variants may add `__CPROVER_cover` goals to explicitly demonstrate solver reachability of
nontrivial cases, for example:

```c
__CPROVER_cover(a.coeffs[0] == 3328 && b.coeffs[0] == 3328);
__CPROVER_cover(sum_ab.coeffs[0] > MLKEM_Q);
```

These cover goals would not strengthen the correctness proof but would improve the evidence that
interesting states are reachable.

---

## 17. Reproducibility Controls

The runner records:

- UTC timestamp;
- repository path;
- expected commit;
- actual commit;
- parameter set;
- Git working-tree status;
- CBMC version;
- `goto-cc` version;
- harness SHA-256;
- copied harness source;
- exact build command;
- build log;
- build exit code;
- exact CBMC command;
- text result;
- text exit code;
- JSON result;
- JSON stderr;
- JSON exit code;
- final summary.

The result directory naming convention is:

```text
cleanroom_results/mlk_poly_add_<parameter-set>_<UTC timestamp>
```

The runner stops on:

- unsupported parameter set;
- missing required tools;
- wrong working directory;
- missing harness;
- repository commit mismatch;
- GOTO build failure.

---

## 18. Artifact Inventory

### 18.1 Generated harness

```text
cleanroom_mlk_poly_add_fips_relational_harness_v2.c
```

Reference SHA-256 of the generated file supplied with this record:

```text
307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e
```

### 18.2 Generated runner

```text
run_cleanroom_mlk_poly_add_cbmc_v2.sh
```

Reference SHA-256:

```text
eeb5b1c1a88689e9219d704ec56fcc97b44ec8676ac1c391106adcd4243980f6
```

### 18.3 Assumption ledger

```text
cleanroom_mlk_poly_add_assumption_ledger.md
```

Reference SHA-256:

```text
0fe09bf2c991fbbc1e788206523928bf67544c626c5c3094b09b6c88e8784f40
```

### 18.4 Successful result directory

```text
cleanroom_results/mlk_poly_add_768_20260716T013225Z
```

The local result directory should contain at least:

```text
experiment_identity.txt
cbmc_version.txt
goto_cc_version.txt
harness_sha256.txt
cleanroom_mlk_poly_add_fips_relational_harness_v2.c
build_command.txt
goto_cc_build.log
goto_cc_build.exit
cleanroom_poly_add.goto
cbmc_command.txt
cbmc_output.txt
cbmc.exit
cbmc_output.json
cbmc_json_stderr.txt
cbmc_json.exit
summary.txt
```

The result-directory and archive hashes must be taken from the local machine after freezing.
They are not invented in this record.

---

## 19. Recommended Evidence-Freezing Commands

```bash
cd ~/THESIS-2026/mlkem-native

RESULT_DIR="cleanroom_results/mlk_poly_add_768_20260716T013225Z"

sha256sum   cleanroom_mlk_poly_add_fips_relational_harness_v2.c   run_cleanroom_mlk_poly_add_cbmc_v2.sh   "$RESULT_DIR/cbmc_output.txt"   "$RESULT_DIR/cbmc_output.json"   > "$RESULT_DIR/final_evidence_sha256.txt"

tar -czf   cleanroom_mlk_poly_add_768_SUCCESS_20260716T013225Z.tar.gz   "$RESULT_DIR"   cleanroom_mlk_poly_add_fips_relational_harness_v2.c   run_cleanroom_mlk_poly_add_cbmc_v2.sh

sha256sum   cleanroom_mlk_poly_add_768_SUCCESS_20260716T013225Z.tar.gz
```

The generated archive hash should be copied into the thesis experiment ledger and version-control
notes.

---

## 20. Professor-Ready Technical Claim

The following wording is suitable for a progress report:

> An independently authored CBMC harness was evaluated against the production
> `mlk_poly_add` implementation in `mlkem-native` commit
> `d9613cf60de3132d32475c102d8c2781d84feb34` using CBMC 6.9.0 and the
> ML-KEM-768 configuration. The harness modelled arbitrary unsigned canonical FIPS-domain
> coefficients and directly executed the portable C implementation. It asserted exact in-place
> coefficient addition, the derived output interval `[0, 2q-2]`, modulo-`q`
> correspondence with FIPS polynomial addition, preservation of read-only operands,
> commutativity, additive identity, and FIPS parameter binding. CBMC also instrumented selected
> bounds, pointer, overflow, conversion, shift, and loop-unwinding checks. The corrected run
> reported zero failures among 341 reported properties and returned
> `VERIFICATION SUCCESSFUL` in both text and JSON modes. The result is limited to the
> declared canonical input domain, portable C backend, selected commit, and build
> configuration. It does not establish complete correctness for every non-canonical internal
> representation or the full ML-KEM implementation.

The clean-room qualification should be stated separately:

> The repository's original harness was not viewed or used. However, source-level function
> contracts and loop invariants were accidentally included in the code extraction, so the
> experiment is original-harness-blind rather than perfectly blind to all existing formal
> artefacts.

---

## 21. Research Value

This experiment demonstrates a complete small-scale formal-verification workflow:

1. identify a production cryptographic function;
2. collect specification and implementation evidence;
3. define a controlled verification boundary;
4. generate a candidate harness;
5. bind the harness to a repository revision and parameter set;
6. execute the real production body;
7. classify a failed first run;
8. repair a harness-infrastructure defect;
9. preserve the failed and successful evidence;
10. obtain a successful symbolic result;
11. distinguish proved claims from unsupported global claims; and
12. document threats to validity and reproducibility.

The failed first run is useful evidence rather than wasted work. It records a realistic
harness-generation failure mode:

```text
undefined symbolic helper body
```

The repair shows that the workflow can distinguish:

- an implementation defect;
- an over-strong property;
- an invalid assumption;
- a configuration problem; and
- a harness plumbing defect.

In this case, the evidence supported the final category.

---

## 22. Recommended Follow-On Experiments

### 22.1 Production-context domain

Inspect the complete surrounding code for:

```text
poly_k.c around line 278
indcpa.c around lines 571-572
```

Derive call-site-specific coefficient bounds and create an additional harness for the real
internal representation domain.

### 22.2 Wider safe `int16_t` domain

Generate arbitrary signed coefficients and assume only:

```text
INT16_MIN <= a[i] + b[i] <= INT16_MAX
```

Then verify exact addition and implementation safety over the full function-contract-valid
domain.

This experiment would be broader than the current canonical FIPS profile.

### 22.3 Boundary-directed symbolic profiles

Create dedicated profiles for:

```text
a[i] = 0, b[i] = 0
a[i] = q-1, b[i] = q-1
a[i] = q-1, b[i] = 1
a[i] = 0, b[i] = q-1
```

Although already contained in the symbolic canonical domain, explicit cover goals can make the
evidence easier to present.

### 22.4 Parameter-set replication

Run the same frozen harness under:

```text
ML-KEM-512
ML-KEM-768
ML-KEM-1024
```

Since `n` and `q` are common, identical results may be expected for this function, but they should
be measured rather than assumed.

### 22.5 Native-backend experiment

If a native `poly_add` implementation is configured, perform a separate backend-specific run and
record tool-support limitations.

### 22.6 Post-freeze original-harness comparison

After preserving hashes, compare the independent harness with the repository harness and report:

- shared properties;
- unique properties;
- different assumptions;
- different symbolic input construction;
- different proof modes;
- different reproducibility evidence;
- whether the repository harness is narrower or broader.

### 22.7 Mutation sanity checks

Temporarily verify intentionally incorrect copies outside the production tree, such as:

```text
replace + with -
skip coefficient 255
write to b instead of r
```

CBMC should produce failures. Mutation checks provide evidence that the harness is capable of
detecting relevant defects rather than succeeding trivially.

Production source must remain untouched in the canonical experiment.

---

## 23. Final Conclusion

The experiment successfully produced and evaluated an independently authored, FIPS-domain,
relational CBMC harness for `mlk_poly_add`.

The production GOTO build succeeded. The initial verification failure was traced to an undefined
symbolic helper in the harness, not to the target function. The helper was repaired without
weakening the proof obligations. The corrected ML-KEM-768 run using CBMC 6.9.0 reported:

```text
0 of 341 failed
VERIFICATION SUCCESSFUL
```

The evidence supports the conclusion that `mlk_poly_add` correctly performs safe, exact,
coefficient-wise in-place addition for every pair of canonical FIPS-domain inputs represented by
the harness, and that the stored result is congruent to FIPS polynomial addition modulo `q`.

The phrase “`mlk_poly_add` is proved correct” is acceptable only when immediately qualified by:

- the canonical input assumptions;
- the selected properties;
- the portable C backend;
- the exact repository commit;
- the ML-KEM-768 configuration;
- the CBMC 6.9.0 model;
- the finite but fully asserted loop unwind; and
- the absence of a claim about the complete ML-KEM implementation.

The final proof status is therefore:

```text
VERIFIED WITHIN THE DECLARED HARNESS CONTRACT AND EXPERIMENT CONFIGURATION
```

---

# Appendix A — Complete Corrected Harness

```c
/*
 * Clean-room, FIPS-domain, relational CBMC harness for mlk_poly_add
 *
 * Target repository:
 *   pq-code-package/mlkem-native
 * Target commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 *
 * Research scope:
 *   - independently authored harness;
 *   - does not require or invoke an existing mlk_poly_add harness;
 *   - exercises the real two-argument in-place implementation;
 *   - uses canonical FIPS 203 representatives: 0 <= coefficient < q;
 *   - checks implementation-level addition and its modulo-q meaning;
 *   - adds relational/metamorphic checks (commutativity and identity);
 *   - keeps all target-call objects disjoint by construction.
 *
 * Important limitation:
 *   This is a FIPS-canonical input-domain harness. It does not yet cover
 *   every non-canonical signed int16_t representation that production
 *   call sites may use internally.
 *
 * Integration:
 *   Compile this harness with the repository's production poly.c and the
 *   same configuration/include flags used by the selected ML-KEM build.
 *   Do not enable function-contract replacement or loop-contract
 *   transformation for the clean-room BMC run.
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

/*
 * A local automatic object without an initializer is nondeterministic in CBMC.
 * Providing a function body avoids CBMC's "no body for callee" property while
 * preserving symbolic input generation.
 */
static int16_t cleanroom_nondet_int16(void)
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

  mlk_poly sum_ab;
  mlk_poly sum_ba;

  mlk_poly zero;
  mlk_poly identity_result;

  unsigned i;
  int32_t expected_integer_sum;
  int32_t expected_fips_residue;

  /*
   * Bind the experiment to the FIPS 203 ring parameters used by this
   * target. These are assertions, not assumptions: a configuration drift
   * must make the experiment fail visibly.
   */
  __CPROVER_assert(MLKEM_N == 256,
                   "PARAMETER_BINDING: MLKEM_N must equal FIPS n=256");
  __CPROVER_assert(MLKEM_Q == 3329,
                   "PARAMETER_BINDING: MLKEM_Q must equal FIPS q=3329");

  /*
   * Generate two arbitrary polynomials using unsigned canonical
   * representatives of Z_q. The bounds imply:
   *
   *   0 <= a[i] + b[i] <= 2*q - 2 = 6656,
   *
   * so the implementation's in-place int16_t result cannot overflow.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    a.coeffs[i] = cleanroom_nondet_int16();
    b.coeffs[i] = cleanroom_nondet_int16();

    __CPROVER_assume(a.coeffs[i] >= 0);
    __CPROVER_assume(a.coeffs[i] < MLKEM_Q);

    __CPROVER_assume(b.coeffs[i] >= 0);
    __CPROVER_assume(b.coeffs[i] < MLKEM_Q);

    zero.coeffs[i] = 0;
  }

  /*
   * Freeze the mathematical inputs before any target call.
   */
  a_before = a;
  b_before = b;

  /*
   * Three distinct-object experiments:
   *
   *   sum_ab          := a + b
   *   sum_ba          := b + a
   *   identity_result := a + 0
   *
   * Every output object is disjoint from its read-only operand.
   */
  sum_ab = a;
  sum_ba = b;
  identity_result = a;

  mlk_poly_add(&sum_ab, &b);
  mlk_poly_add(&sum_ba, &a);
  mlk_poly_add(&identity_result, &zero);

  for (i = 0; i < MLKEM_N; i++)
  {
    expected_integer_sum =
        (int32_t)a_before.coeffs[i] + (int32_t)b_before.coeffs[i];

    expected_fips_residue = expected_integer_sum % (int32_t)MLKEM_Q;

    /*
     * P1: Exact accumulator semantics before modular normalization.
     */
    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] == expected_integer_sum,
        "P1_EXACT_SUM: output coefficient equals the mathematical integer sum");

    /*
     * P2: Derived implementation bound for canonical FIPS inputs.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] >= 0,
        "P2_LOWER_BOUND: canonical-input sum is nonnegative");

    __CPROVER_assert(
        (int32_t)sum_ab.coeffs[i] <=
            (2 * (int32_t)MLKEM_Q) - 2,
        "P2_UPPER_BOUND: canonical-input sum is at most 2*q-2");

    /*
     * P3: Refinement to FIPS polynomial addition.
     *
     * mlk_poly_add intentionally need not reduce its stored coefficient.
     * Its residue modulo q must nevertheless equal FIPS addition in Z_q.
     */
    __CPROVER_assert(
        ((int32_t)sum_ab.coeffs[i] % (int32_t)MLKEM_Q) ==
            expected_fips_residue,
        "P3_FIPS_RESIDUE: stored sum represents coefficient addition modulo q");

    /*
     * P4: Read-only operands and frozen inputs are not modified.
     */
    __CPROVER_assert(
        a.coeffs[i] == a_before.coeffs[i],
        "P4_LEFT_INPUT_FRAME: read-only use of a leaves a unchanged");

    __CPROVER_assert(
        b.coeffs[i] == b_before.coeffs[i],
        "P4_RIGHT_INPUT_FRAME: read-only use of b leaves b unchanged");

    __CPROVER_assert(
        zero.coeffs[i] == 0,
        "P4_ZERO_FRAME: zero operand remains unchanged");

    /*
     * P5: Relational/metamorphic commutativity.
     */
    __CPROVER_assert(
        sum_ab.coeffs[i] == sum_ba.coeffs[i],
        "P5_COMMUTATIVITY: a+b equals b+a coefficient-wise");

    /*
     * P6: Relational/metamorphic additive identity.
     */
    __CPROVER_assert(
        identity_result.coeffs[i] == a_before.coeffs[i],
        "P6_IDENTITY: a+0 equals a coefficient-wise");
  }

  return 0;
}
```

---

# Appendix B — Complete Corrected Runner

```bash
#!/usr/bin/env bash
#
# Build and verify the independently authored mlk_poly_add harness.
#
# Run this script from the root of the mlkem-native repository:
#
#   chmod +x run_cleanroom_mlk_poly_add_cbmc_v2.sh
#   ./run_cleanroom_mlk_poly_add_cbmc_v2.sh 768
#
# The optional first argument is 512, 768, or 1024. The default is 768.
#

set -uo pipefail

EXPECTED_COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"
PARAM_SET="${1:-768}"
HARNESS="cleanroom_mlk_poly_add_fips_relational_harness_v2.c"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="cleanroom_results/mlk_poly_add_${PARAM_SET}_${TIMESTAMP}"
GOTO_MODEL="${OUT_DIR}/cleanroom_poly_add.goto"

case "${PARAM_SET}" in
  512|768|1024) ;;
  *)
    echo "ERROR: parameter set must be 512, 768, or 1024." >&2
    exit 2
    ;;
esac

for tool in git cbmc goto-cc sha256sum tee; do
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
  echo "UTC timestamp: ${TIMESTAMP}"
  echo "Repository: $(pwd)"
  echo "Expected commit: ${EXPECTED_COMMIT}"
  echo "Actual commit: ${CURRENT_COMMIT}"
  echo "Parameter set: ${PARAM_SET}"
  echo
  git status --short
} > "${OUT_DIR}/experiment_identity.txt"

cbmc --version > "${OUT_DIR}/cbmc_version.txt" 2>&1
goto-cc --version > "${OUT_DIR}/goto_cc_version.txt" 2>&1
sha256sum "${HARNESS}" > "${OUT_DIR}/harness_sha256.txt"
cp "${HARNESS}" "${OUT_DIR}/"

if [ "${CURRENT_COMMIT}" != "${EXPECTED_COMMIT}" ]; then
  echo "ERROR: repository commit does not match the clean-room target." | tee \
    "${OUT_DIR}/commit_mismatch.txt"
  echo "Expected: ${EXPECTED_COMMIT}" | tee -a "${OUT_DIR}/commit_mismatch.txt"
  echo "Actual:   ${CURRENT_COMMIT}" | tee -a "${OUT_DIR}/commit_mismatch.txt"
  exit 3
fi

# Deliberately do NOT define the preprocessor macro CBMC here.
# This keeps the repository's embedded __contract__ and __loop__ annotations
# disabled while the target C body is directly bounded-model-checked.
#
# common.h already defines MLK_BUILD_INTERNAL for this source build.
# Do not redefine it on the command line, which only creates a warning.
# Native arithmetic remains disabled because
# MLK_CONFIG_USE_NATIVE_BACKEND_ARITH is not defined.
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

echo "===== BUILDING GOTO MODEL ====="
"${BUILD_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/goto_cc_build.log"
BUILD_EXIT=${PIPESTATUS[0]}
echo "${BUILD_EXIT}" > "${OUT_DIR}/goto_cc_build.exit"

if [ "${BUILD_EXIT}" -ne 0 ]; then
  echo "BUILD FAILED. Send goto_cc_build.log back for diagnosis."
  exit "${BUILD_EXIT}"
fi

CBMC_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
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
  --trace
)

printf '%q ' "${CBMC_COMMAND[@]}" > "${OUT_DIR}/cbmc_command.txt"
printf '\n' >> "${OUT_DIR}/cbmc_command.txt"

echo
echo "===== RUNNING CBMC ====="
"${CBMC_COMMAND[@]}" 2>&1 | tee "${OUT_DIR}/cbmc_output.txt"
CBMC_EXIT=${PIPESTATUS[0]}
echo "${CBMC_EXIT}" > "${OUT_DIR}/cbmc.exit"

# Create a machine-readable second result. Its exit code should agree with
# the text run. This second invocation omits --trace to keep JSON smaller.
CBMC_JSON_COMMAND=(
  cbmc
  "${GOTO_MODEL}"
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
  --json-ui
)

"${CBMC_JSON_COMMAND[@]}" > "${OUT_DIR}/cbmc_output.json" 2> \
  "${OUT_DIR}/cbmc_json_stderr.txt"
CBMC_JSON_EXIT=$?
echo "${CBMC_JSON_EXIT}" > "${OUT_DIR}/cbmc_json.exit"

{
  echo "build_exit=${BUILD_EXIT}"
  echo "cbmc_text_exit=${CBMC_EXIT}"
  echo "cbmc_json_exit=${CBMC_JSON_EXIT}"
  if [ "${BUILD_EXIT}" -eq 0 ] &&
     [ "${CBMC_EXIT}" -eq 0 ] &&
     [ "${CBMC_JSON_EXIT}" -eq 0 ]; then
    echo "final_status=VERIFICATION_SUCCESSFUL"
  else
    echo "final_status=FAILED_OR_INCONCLUSIVE"
  fi
} > "${OUT_DIR}/summary.txt"

echo
echo "===== SUMMARY ====="
cat "${OUT_DIR}/summary.txt"
echo "Results directory: ${OUT_DIR}"

exit "${CBMC_EXIT}"
```

---

# Appendix C — Compact Result Record

```text
Target:
mlk_poly_add

Repository:
pq-code-package/mlkem-native

Commit:
d9613cf60de3132d32475c102d8c2781d84feb34

Parameter set:
ML-KEM-768

Tool:
CBMC 6.9.0

GOTO compiler:
goto-cc 6.9.0

Successful run:
2026-07-16T01:32:25Z

Results directory:
cleanroom_results/mlk_poly_add_768_20260716T013225Z

Build:
SUCCESS

CBMC text exit:
0

CBMC JSON exit:
0

Reported properties:
341

Reported failures:
0

Final result:
VERIFICATION SUCCESSFUL
```

---

# Appendix D — Experiment Evidence Checklist

- [x] repository identity recorded;
- [x] exact commit recorded;
- [x] target function identified;
- [x] production type identified;
- [x] `n` and `q` identified;
- [x] FIPS semantics identified;
- [x] clean-room exclusions declared;
- [x] contamination limitation declared;
- [x] assumptions documented;
- [x] properties documented;
- [x] production body directly executed;
- [x] portable backend selected;
- [x] loop unwinding assertion enabled;
- [x] text CBMC result recorded;
- [x] JSON CBMC result recorded;
- [x] first failed run retained;
- [x] root cause classified;
- [x] repair documented;
- [x] production code unchanged;
- [x] properties not weakened;
- [x] successful run obtained;
- [x] scope limitations documented;
- [ ] local successful archive SHA-256 inserted into the thesis ledger;
- [ ] full production call-site bounds analysed;
- [ ] ML-KEM-512 replication completed;
- [ ] ML-KEM-1024 replication completed;
- [ ] post-freeze comparison with original repository harness completed;
- [ ] mutation-sensitivity experiment completed.

---

# Appendix E — Terminology

**Assumption:** A restriction on the symbolic input space. CBMC proves properties only for
executions satisfying the assumptions.

**Assertion:** A property that CBMC attempts to prove. A successful assertion means no violating
execution was found within the verified model and bounds.

**Canonical representative:** An integer in `0..q-1` used to represent an element of
`Z_q`.

**CBMC:** A bounded model checker for C and C++ that converts program behaviour and properties
into solver constraints.

**Clean-room generation:** Independent artefact creation without using the original target
artefact as design input. The current experiment is original-harness-blind but not completely
formal-artefact-blind.

**Frame condition:** A property describing which objects remain unchanged.

**GOTO model:** CBMC's intermediate representation created by `goto-cc`.

**Metamorphic property:** A relation between multiple executions, such as commutativity or
identity.

**Modulo-`q` refinement:** A connection between a concrete stored integer and the abstract
mathematical element it represents in `Z_q`.

**Symbolic input:** A value left unconstrained except for explicit assumptions, allowing CBMC to
reason over all permitted values.

**Unwinding assertion:** A check that the supplied loop bound is sufficient; it prevents a false
success caused by truncating a loop too early.
