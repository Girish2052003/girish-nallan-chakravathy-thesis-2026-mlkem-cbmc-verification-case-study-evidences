# ML-KEM Native `mlk_zeroize` CBMC Verification Campaign

## Complete Technical Record, Proof Rationale, Evidence Summary, Distinctness Analysis, and Novelty Assessment

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Campaign:** Source-Level Zeroization and Release-Handoff Verification  
**Target implementation:** `pq-code-package/mlkem-native`  
**Pinned commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Pinned tree:** `54805daff6a91a010c05467ea678117c42a71559`  
**Primary parameter configuration:** ML-KEM-768  
**Verification tool:** CBMC/GOTO tools 6.9.0  
**Record date:** 28 July 2026  
**Campaign classification:** `PASS`, subject to the bounded scope and qualifications stated in this record

---

## 1. Executive verdict

This campaign developed and executed a clean-room, source-bound CBMC verification suite for the real `mlk_zeroize` implementation and its `MLK_FREE` release-handoff boundary in the pinned `mlkem-native` source tree.

The campaign did **not** modify the authoritative production implementation. The harnesses, configuration wrappers, expected-failure controls, mutation models, manifests, and evidence packages were maintained in a separate campaign workspace.

Four theorem families were selected and completed:

1. **ZERO-T1 — exact slice erasure and pre-state independence**;
2. **ZERO-T2 — frame confinement and zero-length identity**;
3. **ZERO-T3 — relational and compositional laws**;
4. **ZERO-T4 — default and custom release handoff**.

The final core result was:

```text
ZERO-T1: 3/3 core properties accepted
ZERO-T2: 4/4 core properties accepted
ZERO-T3: 4/4 core properties accepted
ZERO-T4: 5/5 core properties accepted
TOTAL:   16/16 core properties accepted
```

The accepted suite was then evaluated against eight locked, deliberately faulty local mutation models and release sequences:

```text
TOTAL_MUTANTS=8
KILLED_MUTANTS=8
SURVIVED_MUTANTS=0
ERROR_MUTANTS=0
MUTATION_SCORE_PERCENT=100.00
ZERO_V1_RUN1_CLASSIFICATION=PASS
```

The correct final technical claim is:

> For the pinned `mlkem-native` commit and the documented bounded harness domains, CBMC verified the real source-level `mlk_zeroize` implementation across exact erasure, frame confinement, compositional behaviour, and default/custom release-handoff properties. The selected property suite also rejected all eight locked mutation models.

The campaign does **not** establish universal physical erasure, register or cache clearing, optimized-binary retention, correctness for every object size, correctness for every possible external allocator, or detection of every possible defect.

### Correction of target terminology

This record concerns **`mlk_zeroize`**. It does not concern `mlk_canon`, `poly_canon`, or a polynomial canonicalisation function. Any earlier accidental use of “poly canon” was a naming mistake and is not part of the proof claim.

---

## 2. Motivation and standards basis

### 2.1 FIPS 203 requirement

FIPS 203 requires destruction of sensitive intermediate data. Section 3.3 states that intermediate data shall be destroyed as soon as it is no longer needed and that, subject to stated exceptions, only designated outputs may remain after ML-KEM operations terminate (NIST, 2024).

This requirement is implementation-oriented. It is not satisfied merely by proving the mathematical correctness of ML-KEM encapsulation and decapsulation. It also requires assurance about the implementation mechanism responsible for overwriting and releasing sensitive storage.

The target source explicitly links `mlk_zeroize` to this requirement. In the pinned `verify.h`, the function is documented as “Force-zeroize a buffer” and as being used to implement FIPS 203 Section 3.3. The same source states that this helper is not present in the original Kyber reference implementation.

### 2.2 Why this target was technically important

The repository’s zeroization helper is small, but the security-relevant question is larger than the single `memset` call. A useful assurance argument has to answer all of the following:

- Does every selected byte become zero?
- Is that result independent of the secret pre-state?
- Are bytes outside the selected range preserved?
- Is the zero-length case an identity operation?
- Do repeated and partitioned calls behave consistently?
- Is zeroization completed before memory is released to a custom allocator/free hook?
- Is the release hook called exactly once for a non-null allocation and not called for a null pointer?
- Would the suite detect realistic local defects such as removing the wipe, using the wrong fill byte, changing the length, changing the pointer, releasing before wiping, or releasing twice?

The four theorem families were designed to answer those questions without pretending to prove physical-memory destruction.

---

## 3. Authoritative source and implementation under analysis

### 3.1 Frozen source identity

The authoritative repository was frozen at:

```text
Repository: pq-code-package/mlkem-native
Commit:     af4c5abdd5958bdc65a03cd5ee86708264f93304
Tree:       54805daff6a91a010c05467ea678117c42a71559
```

The campaign repeatedly checked:

```text
git rev-parse HEAD
git rev-parse HEAD^{tree}
git status --short
```

The required conditions were:

- commit equals the frozen commit;
- tree equals the frozen tree;
- `git status --short` is empty before and after each accepted run.

### 3.2 Production implementation

For the GCC/Clang inline-assembly branch at the pinned commit, `mlk_zeroize` has the following semantic structure:

```c
static MLK_INLINE void mlk_zeroize(void *ptr, size_t len)
__contract__(
  requires(memory_no_alias(ptr, len))
  assigns(memory_slice(ptr, len)))
{
  mlk_memset(ptr, 0, len);
  __asm__ volatile("" : : "r"(ptr) : "memory");
}
```

The operational meaning is:

1. call the configured `mlk_memset` implementation with fill value zero;
2. execute an empty inline-assembly compiler barrier carrying a `memory` clobber.

### 3.3 Native contract limitation relevant to this campaign

The source contract states:

- a non-aliasing requirement for the writable memory region;
- an `assigns` frame for the selected slice.

It does **not** contain a functional postcondition equivalent to:

```text
forall i in [0, len): ((uint8_t *)ptr)[i] == 0
```

Therefore, the local source annotation alone does not express the full all-zero functional theorem proved in ZERO-T1. This is a contract-scope gap, not evidence that the implementation is defective.

### 3.4 `MLK_ALLOC` and `MLK_FREE`

The pinned `common.h` provides two allocation/free branches.

The default branch uses stack-backed storage. Its `MLK_FREE` expansion zeroizes the backing array and then sets the exposed pointer to `NULL`.

The custom branch checks for a non-null pointer, zeroizes the allocation, invokes the configured custom free hook, and then sets the pointer to `NULL`.

ZERO-T4 was designed to verify this handoff sequence explicitly rather than infer it from macro text alone.

---

## 4. Native CBMC baseline and the verification gap

The native CBMC proof infrastructure states that:

- proofs are organised by function;
- each proved function has an eponymous proof directory;
- specifications are embedded in source contracts and loop annotations;
- native harnesses are intended mainly as boilerplate and do not add new specifications;
- the principal stated scope is absence of selected classes of undefined behaviour, including memory and type safety.

At the pinned commit, the repository already contained extensive CBMC proof directories for arithmetic, polynomial, KEM, Keccak, comparison, and conditional-move functions. The proof index did not provide a dedicated `zeroize` theorem directory containing the four functional property families developed here.

The important distinction is therefore not “the repository had no formal verification.” It had substantial formal verification. The distinction is narrower and defensible:

> The native proof organisation did not provide this clean-room, dedicated functional suite for exact zeroization, frame confinement, compositional laws, release handoff, expected-failure controls, and mutation sensitivity for `mlk_zeroize`.

This campaign complements rather than replaces the native assurance work.

---

## 5. Verification methodology

### 5.1 Clean-room boundary

The campaign used an external workspace under:

```text
~/THESIS-2026/mlk_zeroize_cleanroom/
```

The production repository was treated as read-only evidence. Harnesses and wrappers were built outside the source tree.

### 5.2 Terminal-first evidence policy

Most stages were evaluated from direct terminal output. File upload or archive inspection was reserved for critical gates such as:

- source and build binding;
- final harness freeze;
- mutation evidence;
- final campaign packaging.

### 5.3 Verification-intent firewall

The campaign followed a deterministic integrity discipline:

1. freeze the target, theorem family, allowed assumptions, source commit, tool version, and forbidden transformations;
2. generate or write candidate harnesses outside the repository;
3. apply deterministic checks before accepting any CBMC success.

The deterministic checks included:

- source hash and commit binding;
- clean repository status;
- target-call presence;
- target-body presence;
- zero-valued `memset` presence;
- compiler-barrier parsing evidence;
- assertion presence;
- assumption census;
- rejection of `assume(false)` and contradictory assumptions;
- absence of target replacement, stubbing, or function-contract substitution;
- expected-failure controls;
- non-vacuity witnesses;
- mutation sensitivity;
- evidence hashes and reproducible archives.

### 5.4 CBMC configuration

The positive and expected-failure runs used the following principal settings:

```text
--function harness
--object-bits 10
--bounds-check
--pointer-check
--pointer-overflow-check
--conversion-check
--signed-overflow-check
--unsigned-overflow-check
--unwind 17
--unwinding-assertions
--slice-formula
--trace
```

The positive models were expected to return exit code `0`. Expected-failure and mutant models were expected to return exit code `10` with the planned assertion failure.

### 5.5 Composite body binding

A significant implementation detail was the treatment of the compiler barrier.

The raw GOTO model retained evidence of:

- the real `mlk_zeroize` symbol;
- `memset(ptr, 0, len)`;
- parsing of the inline-assembly statement and memory clobber.

After CPROVER library instrumentation, the semantically empty assembly statement was not always printed in the reduced function dump. The library-linked model still retained:

- the harness;
- calls from the harness to `mlk_zeroize`;
- the real target function;
- the zero-valued `memset` call;
- no contract replacement or stub.

The final binding rule therefore used two complementary witnesses:

- **raw GOTO:** source branch, real zero overwrite, and compiler-barrier parsing;
- **library-linked GOTO submitted to CBMC:** reachable harness, real target, real zero overwrite, and no target replacement.

This corrected an earlier overly strict evidence parser that incorrectly required the semantically empty barrier to remain visible after library instrumentation.

---

## 6. Campaign chronology

### 6.1 ZERO-00A — provenance and native-overlap analysis

The initial stage established:

- the exact target source location;
- the FIPS 203 motivation;
- the real implementation branches;
- the native contract scope;
- the absence of an equivalent dedicated theorem family in the native proof structure;
- the requirement that the campaign remain distinct from the native harness approach.

### 6.2 ZERO-00B — direct body-binding feasibility

The preflight proved that the toolchain could:

- preprocess the selected inline-assembly branch;
- compile the harness and target into a GOTO program;
- retain the real `mlk_zeroize` symbol;
- retain the zero-valued `memset` call;
- parse the compiler barrier;
- produce a semantic counterexample for an intentionally false retained-byte assertion.

This stage established feasibility and sensitivity but was not itself a theorem-family result.

### 6.3 ZERO-00C — theorem, assumption, and source freeze

The source binding, theorem registry, and assumption registry were frozen and hashed before the positive theorem campaign.

Recorded registry hashes included:

```text
source_binding.txt:      755eb784...
theorem_registry.md:    f72f5012...
assumption_registry.md: 0b64fd8f...
```

The initial T1 body-binding script failed because `--drop-unused-functions` removed all functions from a GOTO program that had no registered entry point. This was diagnosed as a GOTO-pruning configuration error, not a theorem failure.

The recovery used the pre-pruning library-linked GOTO object with `--function harness`, preserving the target body for verification.

### 6.4 ZERO-T1 through ZERO-T4

The four families were then executed and frozen independently. Every accepted family included:

- a positive harness;
- implementation-body binding;
- safety checks;
- diagnostic non-vacuity assertions;
- at least one expected-failure control;
- evidence hashes;
- a freeze package with an internal manifest.

### 6.5 ZERO-V1 — mutation sensitivity

The locked mutation plan defined eight local fault models. Each mutant was required to:

- differ textually from its paired reference;
- compile successfully;
- pass library instrumentation;
- retain a reachable mutant function;
- return CBMC exit `10`;
- fail the planned detector;
- produce exactly one failed property;
- avoid timeout or tool-error classification.

All eight were killed.

### 6.6 ZERO-FINAL — final packaging

The final packaging stage revalidated:

- authoritative source commit and tree;
- freeze-package SHA-256 files;
- internal package manifests;
- V1 plan hashes;
- mutation classifications;
- property matrix count;
- nested archive checks;
- final archive re-extraction and file count;
- final source integrity.

The first final-packaging attempt stopped because a multi-line `awk` expression was not accepted by the installed `awk` implementation. This produced parser false negatives for the planned detector checks. The theorem and mutation results were unaffected.

A second packaging run replaced the detector parser with a portable `grep` pipeline and reported all required final gates as passing.

The final archive itself was not independently opened in the retained record after creation. The external `.sha256` and `.verify.txt` files remain the authoritative final-package integrity records.

---

## 7. Why exactly four theorem families were selected

The theorem count was deliberately kept nominal. The aim was not to create many overlapping claims, but to cover four different assurance layers that cannot safely be collapsed into one another.

### 7.1 Why T1 was necessary

T1 asks the most direct functional question:

> Does the selected memory interval become zero for arbitrary initial contents?

Without T1, the campaign could establish memory safety while never proving that sensitive bytes were actually overwritten.

### 7.2 Why the campaign could not stop at T1

A function may zero the requested range but also overwrite adjacent bytes. T1 alone cannot establish confinement.

For example, a faulty implementation that wipes `len + 1` bytes can satisfy selected-byte zero assertions while corrupting the suffix. T2 is therefore logically independent and necessary.

### 7.3 Why the campaign could not stop at T2

T1 and T2 together describe a single invocation. They do not establish how multiple calls compose.

Real callers may:

- zero the same interval repeatedly;
- divide a region into adjacent slices;
- zero independent disjoint slices in either order;
- zero overlapping regions.

T3 proves that these calling patterns are semantically coherent within the bounded model. It also improves detector diversity by checking relational equivalence between executions rather than only unary postconditions.

### 7.4 Why the campaign could not stop at T3

T1–T3 prove memory-state properties at and after calls to `mlk_zeroize`. They do not prove that an allocation is wiped **before** it is exposed to a release hook.

A defective `MLK_FREE` sequence could call the custom free function first and zero memory afterward. T1–T3 could all remain true when `mlk_zeroize` is considered in isolation, while the release boundary still violates the intended security order.

T4 was therefore necessary to connect the function-level proof to the actual allocation-release boundary.

### 7.5 Why more than four core families were not selected

Additional theorem families would have increased campaign size without necessarily increasing conceptual coverage. The chosen four provide a compact assurance decomposition:

| Layer | Question |
|---|---|
| T1 | Did the selected bytes become zero? |
| T2 | Did only the permitted bytes change, including the zero-length case? |
| T3 | Do repeated, partitioned, disjoint, and overlapping calls compose correctly? |
| T4 | Is zeroization correctly integrated into allocation release? |

Machine-code retention, physical erasure, cache/register clearing, and all-size universal proofs would require different methods and trusted models. They were excluded rather than being represented by weak or misleading CBMC claims.

---

## 8. ZERO-T1 — exact erasure and pre-state independence

### 8.1 Purpose

ZERO-T1 proves the core functional effect of `mlk_zeroize`.

### 8.2 Bounded domain

The theorem used a 16-byte host object with symbolic values satisfying:

```text
0 <= offset < 16
1 <= length <= 16 - offset
```

The initial bytes were nondeterministic. Therefore, within that bounded host domain, CBMC considered all possible 8-bit values for every byte and all valid non-empty symbolic intervals.

### 8.3 Core properties

#### ZERO-T1.P1

Every selected byte in arbitrary buffer A becomes zero.

#### ZERO-T1.P2

Every selected byte in independently initialised arbitrary buffer B becomes zero.

#### ZERO-T1.P3

Selected post-state is independent of pre-state.

P3 is a relational corollary: two independently initialised buffers subjected to the same valid wipe interval have equal selected post-states because both selected regions become zero.

### 8.4 Non-vacuity diagnostics

#### ZERO-T1.NV1

A selected byte constrained to be nonzero before execution becomes zero.

#### ZERO-T1.NV2

The selected witness byte differs from its nonzero pre-state after execution.

These diagnostics prevent the positive result from being explained by an already-zero witness.

### 8.5 Result

```text
CBMC exit:              0
Failed properties:      0 of 101
Result:                 VERIFICATION SUCCESSFUL
Expected-failure exit:  10
Classification:         ZERO_T1_RUN1_CLASSIFICATION=PASS
```

### 8.6 What T1 established

Within the 16-byte bounded host domain, for every valid non-empty symbolic interval and arbitrary initial byte values, the real source-level implementation overwrites every selected byte with zero.

### 8.7 What T1 did not establish

T1 did not independently prove:

- preservation of bytes outside the interval;
- zero-length identity;
- multi-call composition;
- release ordering;
- machine-code retention of the wipe;
- physical erasure.

---

## 9. ZERO-T2 — frame confinement and zero-length identity

### 9.1 Purpose

ZERO-T2 proves that the implementation does not alter storage outside its permitted frame and behaves correctly for a zero-length request.

### 9.2 Bounded domain

The theorem used a 16-byte host with symbolic values satisfying:

```text
0 <= offset < 16
0 <= length <= 16 - offset
```

Unlike T1, the length domain included zero.

### 9.3 Core properties

#### ZERO-T2.P1 — prefix preservation

Every byte before the selected interval remains unchanged.

#### ZERO-T2.P2 — suffix preservation

Every byte at or after the end of the selected interval remains unchanged.

#### ZERO-T2.P3 — unrelated-object preservation

A separate live object remains unchanged.

#### ZERO-T2.P4 — zero-length identity

A zero-length invocation preserves the complete host object.

### 9.4 Diagnostic properties

- `ZERO-T2.NV1`: a concrete prefix guard remains reachable and unchanged;
- `ZERO-T2.NV2`: a concrete suffix guard remains reachable and unchanged;
- `ZERO-T2.NV3`: the concrete middle interval is genuinely wiped.

The third witness prevents the frame proof from passing because the implementation did nothing.

### 9.5 Result

```text
Positive CBMC exit:     0
Failed properties:      0 of 109
Positive result:        VERIFICATION SUCCESSFUL
Fail-control exit:      10
Fail-control result:    1 of 77 failed
Classification:         ZERO_T2_RUN1_CLASSIFICATION=PASS
```

The expected-failure control falsely claimed that an untouched prefix byte had changed. CBMC rejected that claim.

### 9.6 Why T2 was distinct from T1

T1 proves **effect**. T2 proves **confinement**. A length-plus-one mutant demonstrates why these are separate obligations: it can zero all requested bytes and still violate the suffix frame.

---

## 10. ZERO-T3 — relational and compositional behaviour

### 10.1 Purpose

ZERO-T3 verifies semantic laws for multiple zeroization calls.

### 10.2 Core properties

#### ZERO-T3.P1 — idempotence

Applying zeroization twice to the same interval produces the same final object as applying it once.

#### ZERO-T3.P2 — adjacent partition equivalence

Zeroizing two adjacent non-empty partitions produces the same final object as zeroizing their combined interval.

#### ZERO-T3.P3 — disjoint commutativity

For two valid disjoint intervals, applying the two zeroizations in either order produces the same final object.

#### ZERO-T3.P4 — overlapping-union equivalence

Zeroizing two overlapping valid intervals produces the same final object as zeroizing their union.

### 10.3 Non-vacuity diagnostics

Each relational theorem constrained at least one relevant witness byte to be nonzero before execution and proved that the relevant executions actually wiped it:

- `ZERO-T3.NV1` for idempotence;
- `ZERO-T3.NV2` for both adjacent partitions;
- `ZERO-T3.NV3` for both disjoint intervals;
- `ZERO-T3.NV4` for the overlapping intervals.

This is important because a no-op implementation can satisfy several relational equivalences trivially. The witness assertions rule out that explanation in the selected executions.

### 10.4 Result

```text
Positive CBMC exit:     0
Failed properties:      0 of 181
Positive result:        VERIFICATION SUCCESSFUL
Fail-control exit:      10
Fail-control result:    1 of 77 failed
Classification:         ZERO_T3_RUN1_CLASSIFICATION=PASS
```

The expected-failure control falsely claimed that the one-application and two-application outputs differed. CBMC rejected the claim.

### 10.5 Qualification

The direct T3 expected-failure control exercised idempotence. Detector sensitivity for adjacent partition omission was subsequently demonstrated by mutation M8. The final mutation campaign therefore supplied additional evidence for T3.P2.

---

## 11. ZERO-T4 — default and custom release handoff

### 11.1 Purpose

ZERO-T4 connects the real `mlk_zeroize` body to the repository’s `MLK_FREE` release sequence.

### 11.2 Default-branch properties

The default wrapper imported the authoritative native CBMC configuration and removed only its custom allocator selection, causing `common.h` to instantiate the repository’s unmodified stack-backed allocation macros.

#### ZERO-T4.P1

Default `MLK_FREE` zeroizes the full eight-byte backing allocation.

#### ZERO-T4.P2

Default `MLK_FREE` sets the exposed pointer to `NULL`.

#### ZERO-T4.NV1

An explicitly nonzero backing byte is wiped.

Result:

```text
CBMC exit:          0
Failed properties:  0 of 92
Result:             VERIFICATION SUCCESSFUL
```

### 11.3 Custom-branch properties

The custom wrapper imported the complete native CBMC configuration, removed only the generic CBMC allocation/free macro definitions, and replaced them with observational harness hooks at the documented configuration boundary.

The custom free hook did not call, replace, or simulate `mlk_zeroize`. It only observed memory at hook entry and recorded call count and size.

#### ZERO-T4.P3

The custom free hook observes the complete allocation as all zero.

#### ZERO-T4.P4

The custom free hook executes exactly once for non-null memory.

#### ZERO-T4.P5

The custom free hook is not called for a null pointer.

Diagnostics established:

- the custom allocator returned the intended live backing object;
- the hook received the full allocation size;
- the exposed pointer became `NULL`;
- null input remained null.

The GOTO harness block established the order:

```text
mlk_zeroize call:       line 51
custom free hook call:  line 53
```

Therefore, zeroization occurred before the release observer.

Result:

```text
CBMC exit:          0
Failed properties:  0 of 124
Result:             VERIFICATION SUCCESSFUL
```

### 11.4 Expected-failure controls

Four intentionally false claims were rejected:

- FC1 denied the all-zero handoff;
- FC2 claimed that the non-null free hook ran twice;
- FC3 denied pointer reset;
- FC4 claimed that null input invoked the free hook.

```text
Expected-failure exit: 10
Failed controls:       4 of 112
Result:                VERIFICATION FAILED
```

### 11.5 T4 Run1 failure and correction

T4 Run1 failed during GOTO compilation, before CBMC execution.

The causes were:

1. the native CBMC configuration already enabled custom allocation, so the intended default harness did not declare the stack-backed `mlk_alloc_secret` object;
2. the custom harness redefined `MLK_CUSTOM_ALLOC` and `MLK_CUSTOM_FREE` before including a configuration that already defined them, and `-Werror` rejected the redefinitions.

The failure was classified as:

```text
HARNESS_CONFIGURATION_COMPILE_FAILURE
```

Run2 used workspace-only configuration wrappers. The authoritative repository remained unchanged. The corrected run passed all T4 properties and controls.

This failed attempt was preserved rather than deleted, supporting transparent research reporting.

---

## 12. Assumptions and trusted boundary

The frozen assumption registry is authoritative. The operational assumptions underlying the campaign are summarised below.

### 12.1 Source and tool assumptions

1. The analysed source is exactly the pinned commit and tree.
2. CBMC, `goto-cc`, and `goto-instrument` version 6.9.0 implement their documented semantics correctly.
3. GCC-compatible preprocessing selects the same source branches evidenced by the raw GOTO model.
4. The selected environment uses the inline-assembly `mlk_zeroize` branch rather than Windows `SecureZeroMemory` or a user-supplied custom zeroizer.

### 12.2 Memory-domain assumptions

5. Pointers supplied to the target refer to valid writable C objects for the selected length.
6. The selected memory slice satisfies the source contract’s no-alias requirement.
7. T1–T3 use 16-byte host objects and valid symbolic offsets and lengths.
8. T4 uses eight-byte release objects.
9. Objects used as unrelated frame witnesses are distinct live C objects.

### 12.3 Harness assumptions

10. Nondeterministic bytes model arbitrary 8-bit pre-state values.
11. Non-vacuity constraints requiring selected witnesses to be nonzero are satisfiable.
12. The unwinding bound of 17 is sufficient for loops over the 16-byte and eight-byte harness objects; unwinding assertions are enabled to detect insufficient unwinding.
13. The custom allocator model in T4 returns one live, sufficiently sized eight-byte object for the non-null path.
14. The custom free hook is an observer at the documented configuration boundary and does not itself alter the state before observation.

### 12.4 Abstraction assumptions

15. The proof concerns C abstract-machine memory state.
16. The raw GOTO parsing of the inline assembly is evidence that the compiler barrier was accepted by the verification frontend; CBMC does not prove retention across every optimizing production compiler and machine-code pipeline.
17. The mutation models are selected local fault models, not an exhaustive fault universe.

### 12.5 Forbidden proof shortcuts

The campaign did not permit:

- `__CPROVER_assume(false)`;
- contradictory assumptions used to make the harness unreachable;
- removal of the target call;
- replacement of `mlk_zeroize` by a stub or uninterpreted function;
- `--replace-call-with-contract` or equivalent target-body abstraction;
- production-source modification;
- counting compile errors, timeouts, or tool failures as killed mutants;
- accepting a positive result without an expected-failure or mutation sensitivity check.

---

## 13. Did this campaign prove `mlk_zeroize`?

### 13.1 Answer

**Yes, within the stated bounded source-level theorem domains.**

The campaign proved more than “the harness compiled” and more than “CBMC did not find a memory-safety error.” It proved explicit functional assertions over the real target body:

- selected bytes become zero;
- the selected result is independent of arbitrary pre-state;
- prefix, suffix, and unrelated objects are preserved;
- zero-length calls preserve the object;
- repeated and partitioned calls satisfy four compositional laws;
- default and custom release sequences wipe before release and satisfy pointer/call-count properties.

### 13.2 Why this is a proof rather than a sample test

For the bounded harness objects, CBMC symbolically analysed all values satisfying the assumptions, rather than executing a finite list of hand-written examples. Nondeterministic bytes and symbolic offsets/lengths represent all values in their bounded bit-vector domains. Unwinding assertions were used to guard the loop bound.

### 13.3 Why the word “bounded” remains essential

The host objects were fixed at 16 bytes for T1–T3 and eight bytes for T4. The result is exhaustive over those bounded models, but it is not a quantified theorem over arbitrary mathematical `size_t` lengths and arbitrary object sizes.

### 13.4 What was not proved

The campaign did not prove:

- physical destruction of DRAM contents;
- erasure of CPU registers, caches, swap, compiler temporaries, allocator metadata, or forensic remnants;
- absence of copies elsewhere in the program;
- that every optimizer preserves the wiping operation in every binary;
- the Windows `SecureZeroMemory` branch;
- every user-provided custom zeroization implementation;
- all possible custom allocator behaviours;
- end-to-end destruction of every intermediate value in every ML-KEM API path;
- cryptographic IND-CCA security of ML-KEM;
- correctness of a polynomial canonicalisation function.

### 13.5 Professor-ready formulation

Use this wording:

> The case study provides bounded CBMC proofs of source-level zeroization and release-handoff properties for the real `mlk_zeroize` implementation at the pinned `mlkem-native` commit. The proofs are exhaustive over the documented finite harness domains and include body-binding, non-vacuity, expected-failure, and selected mutation-sensitivity evidence. They do not constitute a physical-erasure or all-binaries theorem.

---

## 14. Distinctness from the native `mlkem-native` proof harnesses

### 14.1 Native approach

The native repository describes its CBMC harnesses as function-organised boilerplate supporting specifications embedded in source contracts and loop annotations. Its principal published C-level claim concerns memory safety and type safety.

### 14.2 This campaign’s approach

The clean-room suite adds an independent verification intent and explicit assertions not supplied by the local `mlk_zeroize` source contract.

The suite is distinct in the following ways.

#### 14.2.1 New functional postconditions

The campaign asserts the all-zero post-state directly. The source contract only constrains aliasing and the assignable slice.

#### 14.2.2 Relational two-execution properties

T1.P3 and all T3 core properties compare two executions or two equally initialised objects. These are not merely restatements of memory safety.

#### 14.2.3 Explicit frame theorems

T2 verifies prefix, suffix, unrelated-object, and zero-length preservation through direct assertions.

#### 14.2.4 Release-boundary instrumentation

T4 introduces observational custom allocator/free hooks solely at the documented configuration boundary and verifies the order between wiping and release.

#### 14.2.5 Non-vacuity and sensitivity

Every family uses concrete or symbolic witnesses to demonstrate that the selected memory was actually changed when expected.

#### 14.2.6 Expected-failure controls

Deliberately false assertions were required to fail. A successful positive proof without a sensitive negative control was not accepted.

#### 14.2.7 Mutation campaign

Eight locked mutants were compiled and model-checked. Compile failures and tool failures were excluded from the killed count.

#### 14.2.8 Independent evidence packaging

Each theorem family was frozen with source binding, harness source, body dumps, CBMC output, verdict, command record, and SHA-256 manifest.

### 14.3 No disguised production rewrite

The campaign did not modify the C90 implementation in the authoritative repository to make the theorem pass. Workspace-only harnesses and configuration wrappers altered the verification environment, not the production target.

### 14.4 Precise distinctness claim

> The contribution is not a reimplementation of the native harness in another language or with renamed assertions. It is a separate, property-driven verification suite that extends the assurance question from native memory/type safety and local contract checking to explicit functional zeroization, relational composition, release ordering, negative controls, and mutation sensitivity.

---

## 15. Mutation-sensitivity campaign

### 15.1 Acceptance rule

A mutant counted as killed only when all of the following held:

1. the mutant differed from its paired reference;
2. compile exit was `0`;
3. library-instrumentation exit was `0`;
4. the mutant function existed and was called;
5. CBMC exit was `10`;
6. the planned detector assertion failed;
7. exactly one property failed;
8. the result was not a timeout, compile error, or tool error.

### 15.2 Mutants and detectors

| ID | Fault model | Primary detector | Result |
|---|---|---|---|
| M1 | Remove the wipe | ZERO-T1.P1 | KILLED |
| M2 | Fill with byte value one | ZERO-T1.P1 | KILLED |
| M3 | Wipe `len - 1` bytes | ZERO-T1.P1 | KILLED |
| M4 | Start at `ptr + 1` | ZERO-T1.P1 | KILLED |
| M5 | Wipe `len + 1` bytes | ZERO-T2.P2 | KILLED |
| M6 | Release observer before wipe | ZERO-T4.P3 | KILLED |
| M7 | Invoke release observer twice | ZERO-T4.P4 | KILLED |
| M8 | Omit second adjacent partition | ZERO-T3.P2 | KILLED |

### 15.3 Mutation result

Every mutant compiled and retained a reachable mutant function. Each planned detector failed, each run produced exactly one failed property, and each mutant was classified `KILLED`.

The 100% mutation score applies only to these eight selected models. It does not imply that the suite detects every possible defect.

---

## 16. Evidence and reproducibility record

### 16.1 Principal freeze archives

The campaign created independent freeze packages for T1, T2, T3, T4, and V1.

Recorded package hashes included:

```text
ZERO-T1_FREEZE_v1_af4c5abd.tar.gz
SHA-256: a3fcd0dc7ec6513eaf96f2f9142c7d49db0443b413f7bea12d88583e8c38bc3b

ZERO-T2_FREEZE_v1_af4c5abd.tar.gz
SHA-256: 980c7191e65becf755c675895f1584c96d7cdc418e2e3be59d3d9ee956510fd2

ZERO-T3_FREEZE_v1_af4c5abd.tar.gz
SHA-256: a39d8e903a88275b3a947f9fcae914533fb66e58d1e78655235b1fd7c3effc5a

ZERO-T4_FREEZE_v1_af4c5abd.tar.gz
SHA-256: 8b044d5120a7a9fd5d7143e877168691d9a76640bff6fafd852d5c53c633704b
```

The final campaign archive hash is stored in:

```text
ZERO-FINAL_CAMPAIGN_v1_af4c5abd.tar.gz.sha256
```

It was not reproduced in the terminal excerpt used to prepare this record and is therefore not invented here.

### 16.2 Required final-package contents

The final archive was designed to contain:

- nested T1–T4 and V1 freeze archives and checksum files;
- package and internal-manifest audit records;
- source, theorem, assumption, and mutation registries;
- theorem-family verdicts;
- property and mutation result matrices;
- preserved unsuccessful-attempt classifications;
- package index;
- final campaign verdict;
- complete campaign manifest.

### 16.3 Reproducibility boundary

Reproduction requires:

- the pinned source commit;
- a compatible Linux environment;
- CBMC, `goto-cc`, and `goto-instrument` 6.9.0;
- GCC-compatible preprocessing;
- the recorded configuration macros and command flags.

Tool or environment changes may alter GOTO binary hashes even if the semantic results remain equivalent.

---

## 17. Failure history and research transparency

The campaign preserved technically meaningful failed attempts.

### 17.1 GOTO pruning failure

An early body-binding stage used `--drop-unused-functions` without a registered entry point. The reduced GOTO model contained no target body. The failure was correctly reclassified as a build/instrumentation error.

### 17.2 Overly strict barrier gate

The real zero-valued `memset` remained in the library-linked GOTO model, while the semantically empty compiler barrier was no longer printed after instrumentation. Requiring the barrier in both dumps caused a parser false negative. The corrected composite gate used raw and library-linked evidence for their appropriate purposes.

### 17.3 T4 allocator configuration failure

T4 Run1 failed because of conflicting native CBMC custom-allocation macros. Run2 used isolated workspace configuration wrappers and passed.

### 17.4 Final packaging `awk` failure

The first final evidence audit used a non-portable multi-line `awk` expression. The verifier rejected the expression and misclassified valid detector matches. A portable `grep` pipeline corrected the audit without rerunning or changing the theorem results.

### 17.5 Why preserving these failures matters

Preserving failed attempts demonstrates that:

- failures were not hidden;
- implementation counterexamples were distinguished from harness and parser defects;
- corrections were narrow and evidence-driven;
- accepted results were not selected by deleting inconvenient artefacts.

---

## 18. Novelty assessment

### 18.1 Novelty question

The relevant novelty question is not whether memory zeroization, CBMC, ML-KEM, relational verification, or mutation testing existed separately. All of those ideas have prior art.

The narrower question is:

> Was an equivalent, publicly documented CBMC theorem suite already present for the real `mlkem-native` `mlk_zeroize` and `MLK_FREE` implementation boundary, covering exact erasure, frame confinement, four compositional laws, release handoff, expected-failure controls, and mutation sensitivity?

### 18.2 Search and audit basis

The novelty review used the following sources and search classes as of 28 July 2026:

- the pinned `mlkem-native` source and CBMC proof index;
- exact searches for `mlk_zeroize`, `MLK_FREE`, CBMC, formal verification, and zeroization;
- FIPS 203 and ACVP materials;
- ML-KEM formal-verification literature and artefacts;
- general secure-memory-erasure and secure-clear work;
- related verified ML-KEM implementations.

### 18.3 What already existed

The review found substantial related work:

1. **FIPS 203** already requires destruction of intermediate values.
2. **`mlkem-native`** already includes the `mlk_zeroize` implementation, compiler barrier, allocation macros, source contracts, and extensive CBMC/HOL Light verification.
3. **Native CBMC proofs** already cover many C functions and focus on memory/type safety and source contracts.
4. **Formal ML-KEM work** already proves cryptographic correctness and security, including machine-checked EasyCrypt and Jasmin results.
5. **General secure-erasure work** already studies secure clearing, compiler elimination of wipes, and formal erasure protocols.
6. **ACVP guidance** explicitly states that FIPS 203 Section 3.3 zeroization is not tested by the ACVP server.
7. **LibMLKEM** explicitly notes that its intermediate values were not sanitised at the time described, showing that zeroization assurance is not automatically supplied by algorithmic functional verification.

Therefore, the broad claim “formal verification of zeroization is new” would be false.

### 18.4 Repository-relative novelty

Repository-relative novelty is **strongly supported**.

The basis is:

- the pinned `mlk_zeroize` contract lacks an all-zero `ensures` clause;
- the native CBMC documentation states that harnesses are boilerplate and specifications are embedded in source annotations;
- the pinned proof index does not expose an equivalent dedicated `zeroize` proof family;
- the clean-room suite adds explicit functional, relational, release-order, negative-control, and mutation obligations.

A defensible statement is:

> At the pinned commit, this campaign added a distinct dedicated verification layer for `mlk_zeroize` that was not represented by the local source contract or by an equivalent native proof family.

### 18.5 Methodological novelty

Methodological novelty is **high for the case study** because the contribution is the integrated assurance structure:

- direct real-body binding;
- exact erasure;
- frame preservation;
- relational composition;
- release handoff;
- non-vacuity witnesses;
- expected-failure controls;
- eight-mutant sensitivity evaluation;
- immutable source and theorem registries;
- reproducible freeze archives;
- preservation of failed harness and verifier attempts.

Individual elements are established techniques. Their application as one clean-room property campaign to this target is the novel contribution.

### 18.6 Worldwide first claim

A worldwide “first ever” claim cannot be proven conclusively from web and repository searching. Unpublished work, private industrial proofs, unindexed theses, and newly released artefacts may exist.

The strongest responsible wording is:

> To the best of the documented repository audit and literature search conducted up to 28 July 2026, no publicly available equivalent was identified that applies CBMC to the real `mlkem-native` `mlk_zeroize` and `MLK_FREE` boundary with the same combined coverage of exact erasure, frame confinement, compositional laws, release handoff, negative controls, and mutation sensitivity.

This is a **scoped novelty conclusion**, not an absolute historical proof.

### 18.7 Novelty potency rating

| Dimension | Assessment | Basis |
|---|---|---|
| Repository-relative novelty | High | No equivalent native theorem family or all-zero postcondition identified at the pinned commit |
| Property novelty for this target | High | New explicit T1–T4 property decomposition |
| Methodological novelty | High | Combined body binding, negative controls, mutations, and evidence firewall |
| General zeroization concept novelty | Low | Secure clearing and erasure are established topics |
| General CBMC concept novelty | Low | CBMC property checking is established |
| Worldwide first-claim confidence | Moderate | Strong search result, but absolute absence cannot be proved |
| Thesis contribution strength | Strong | Narrow, reproducible, evidence-backed extension of assurance for a production PQC implementation |

### 18.8 Recommended novelty claim for the thesis

> This case study contributes a clean-room, property-driven CBMC verification campaign for the source-level `mlk_zeroize` implementation and `MLK_FREE` release boundary in a pinned `mlkem-native` revision. Unlike the native contract-focused proof structure, the campaign checks explicit exact-erasure, frame, relational-composition, and release-handoff properties, and evaluates their sensitivity against expected-failure controls and eight locked mutants. A repository audit and scoped literature search did not identify a publicly available equivalent with the same target and combined property coverage as of 28 July 2026.

### 18.9 Claims that should not be used

Do not write:

- “This is the first formal proof of zeroization.”
- “No one has ever verified ML-KEM zeroization.”
- “`mlk_zeroize` is universally correct.”
- “The proof guarantees physical memory erasure.”
- “The 100% mutation score proves all defects will be detected.”
- “The native repository had no proof or formal verification.”

---

## 19. Threats to validity

### 19.1 Construct validity

The properties model source-level memory state. Physical erasure and machine-code retention are different constructs and remain outside the proof.

### 19.2 Internal validity

Harness mistakes can invalidate a proof campaign. This risk was reduced through body-binding gates, expected-failure controls, mutation models, source cleanliness checks, and preserved failure history.

### 19.3 External validity

The fixed host sizes limit generalisation to arbitrary object sizes. ML-KEM-768 was the principal build configuration. Although `mlk_zeroize` itself is parameter-independent, the campaign does not automatically establish every build configuration or platform branch.

### 19.4 Tool validity

CBMC 6.9.0, its C frontend, library models, and solvers are part of the trusted computing base. Different versions may behave differently.

### 19.5 Novelty validity

The novelty search cannot rule out unpublished or unindexed work. The report therefore uses “no publicly available equivalent was identified” rather than an absolute first claim.

### 19.6 Mutation validity

The eight mutants were deliberately selected and killed, but they do not represent a complete or statistically sampled defect population.

---

## 20. Contributions suitable for thesis reporting

The campaign supports the following contributions.

1. A frozen verification-intent and source-binding method for a security-hygiene helper in a production ML-KEM implementation.
2. A four-family decomposition of zeroization assurance into effect, confinement, composition, and release handoff.
3. New clean-room CBMC harnesses and assertions distinct from the native contract-only specification of `mlk_zeroize`.
4. Composite raw/library GOTO body-binding evidence for an inline-assembly zeroization branch.
5. Non-vacuity and expected-failure controls for every theorem family.
6. Workspace-only configuration wrappers that verify both default and custom `MLK_FREE` branches without production-source modification.
7. An eight-mutant sensitivity evaluation with strict killed-mutant classification rules.
8. Reproducible theorem-family archives and a cross-package final evidence structure.
9. Transparent preservation and classification of harness, pruning, parser, and packaging failures.
10. A scoped novelty assessment separating target-specific contribution from broad prior art.

---

## 21. Final property matrix

| Family | ID | Accepted claim | Status |
|---|---|---|---|
| T1 | ZERO-T1.P1 | Selected bytes in arbitrary buffer A become zero | ACCEPTED |
| T1 | ZERO-T1.P2 | Selected bytes in arbitrary buffer B become zero | ACCEPTED |
| T1 | ZERO-T1.P3 | Selected post-state is independent of pre-state | ACCEPTED |
| T2 | ZERO-T2.P1 | Prefix bytes remain unchanged | ACCEPTED |
| T2 | ZERO-T2.P2 | Suffix bytes remain unchanged | ACCEPTED |
| T2 | ZERO-T2.P3 | Unrelated object remains unchanged | ACCEPTED |
| T2 | ZERO-T2.P4 | Zero-length invocation preserves the object | ACCEPTED |
| T3 | ZERO-T3.P1 | Repeated zeroization is idempotent | ACCEPTED |
| T3 | ZERO-T3.P2 | Adjacent partitions equal their combined interval | ACCEPTED |
| T3 | ZERO-T3.P3 | Disjoint zeroizations commute | ACCEPTED |
| T3 | ZERO-T3.P4 | Overlapping zeroizations equal zeroization of their union | ACCEPTED |
| T4 | ZERO-T4.P1 | Default `MLK_FREE` wipes its full backing allocation | ACCEPTED |
| T4 | ZERO-T4.P2 | Default `MLK_FREE` resets the exposed pointer | ACCEPTED |
| T4 | ZERO-T4.P3 | Custom free observes all-zero memory | ACCEPTED |
| T4 | ZERO-T4.P4 | Custom free executes exactly once for non-null memory | ACCEPTED |
| T4 | ZERO-T4.P5 | Custom free is not called for null memory | ACCEPTED |

---

## 22. Final conclusion

The campaign established a bounded, source-level functional assurance argument for `mlk_zeroize` and its `MLK_FREE` release integration at a frozen `mlkem-native` revision.

T1 proved the zeroing effect. T2 proved confinement. T3 proved coherent multi-call semantics. T4 proved that zeroization was correctly integrated into both default and observational custom release sequences. The campaign did not stop at T1 or T2 because a correct wipe can still corrupt adjacent storage, compose incorrectly, or occur after sensitive memory has already been exposed to a release hook.

The accepted property suite was sensitive to all eight locked fault models, and the evidence process preserved both positive results and failed verification-engineering attempts.

The result is novel in the defensible repository-relative and case-study sense: it supplies an explicit functional and release-handoff theorem suite not expressed by the pinned local `mlk_zeroize` contract and not identified as an equivalent native proof family. A scoped search did not identify a public equivalent with the same target and combined coverage. An absolute worldwide first claim is not warranted.

The final result should therefore be presented as a **new bounded verification artefact and methodology contribution for a specific production PQC implementation**, not as a universal theorem of physical erasure.

---

## References

Amazon Science (2026) ‘Verifying and optimizing post-quantum cryptography at Amazon’. Available at: https://www.amazon.science/blog/verifying-and-optimizing-post-quantum-cryptography-at-amazon (Accessed: 28 July 2026).

Almeida, J.B. et al. (2024) ‘Formally Verifying Kyber: Episode V: Machine-checked IND-CCA security and correctness of ML-KEM in EasyCrypt’, *Advances in Cryptology – CRYPTO 2024*. Artifact available at: https://artifacts.iacr.org/crypto/2024/a3/ (Accessed: 28 July 2026).

Diffblue and Amazon Web Services (2026) *CBMC: C Bounded Model Checker*. Available at: https://github.com/diffblue/cbmc (Accessed: 28 July 2026).

Kroening, D., Schrammel, P. and Tautschnig, M. (2023) ‘CBMC: The C Bounded Model Checker’, arXiv:2302.02384. Available at: https://arxiv.org/abs/2302.02384 (Accessed: 28 July 2026).

National Institute of Standards and Technology (2024) *Module-Lattice-Based Key-Encapsulation Mechanism Standard*. FIPS 203. Gaithersburg, MD: NIST. https://doi.org/10.6028/NIST.FIPS.203.

National Institute of Standards and Technology (2026) *ACVP ML-KEM JSON Specification*. Available at: https://pages.nist.gov/ACVP/draft-celi-acvp-ml-kem.html (Accessed: 28 July 2026).

Ojeda, M. (2020) ‘secure_clear’, ISO/IEC JTC1/SC22/WG14 N2505/N2599. Available at: https://open-std.org/jtc1/sc22/wg14/www/docs/n2505.htm (Accessed: 28 July 2026).

PQ Code Package Project (2026) *mlkem-native: secure, fast, and portable C90 implementation of ML-KEM/FIPS 203*, commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`. Available at: https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304 (Accessed: 28 July 2026).

PQ Code Package Project (2026) *mlkem-native CBMC proof infrastructure*, commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`. Available at: https://github.com/pq-code-package/mlkem-native/tree/af4c5abdd5958bdc65a03cd5ee86708264f93304/proofs/cbmc (Accessed: 28 July 2026).

PQ Code Package Project (2026) *`verify.h` at pinned commit*. Available at: https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/mlkem/src/verify.h (Accessed: 28 July 2026).

PQ Code Package Project (2026) *`common.h` at pinned commit*. Available at: https://raw.githubusercontent.com/pq-code-package/mlkem-native/af4c5abdd5958bdc65a03cd5ee86708264f93304/mlkem/src/common.h (Accessed: 28 July 2026).

Rod Chapman et al. (2024–2026) *LibMLKEM — a formal reference implementation of FIPS 203 ML-KEM*. Available at: https://github.com/awslabs/LibMLKEM (Accessed: 28 July 2026).

---

## Appendix A — concise professor-facing verdict

> The case study verified `mlk_zeroize`, not a polynomial canonicalisation function. The authoritative source was pinned to commit `af4c5abd…` and was clean before and after accepted runs. CBMC 6.9.0 proved 16 core properties across exact erasure, frame confinement, relational composition, and release handoff in documented 16-byte and eight-byte bounded models. Positive runs retained the real target body and zero-valued `memset`, while expected-failure controls and eight successful mutant kills demonstrated sensitivity. No production source was modified. The result is a bounded source-level theorem and does not claim physical-memory or all-binaries erasure. A repository audit and scoped literature search found no public equivalent with the same target and combined property coverage, supporting a strong target-specific novelty claim but not an absolute worldwide-first claim.

## Appendix B — result counts

```text
ZERO-T1 positive:          0 of 101 failed
ZERO-T2 positive:          0 of 109 failed
ZERO-T3 positive:          0 of 181 failed
ZERO-T4 default positive:  0 of 92 failed
ZERO-T4 custom positive:   0 of 124 failed
ZERO-T4 fail controls:     4 of 112 failed as intended
ZERO-V1 mutants:           8/8 killed
ZERO-V1 mutation score:    100.00% over the locked set
```

## Appendix C — final claim-control checklist

Before using a sentence in the thesis, check that it satisfies all five conditions:

1. **Target:** says `mlk_zeroize`/`MLK_FREE`, not `poly_canon`.
2. **Level:** says source-level C abstract-machine state.
3. **Domain:** says bounded 16-byte/eight-byte harness domains where relevant.
4. **Binding:** states that the real target body was retained and production source was unmodified.
5. **Novelty:** uses “no publicly available equivalent was identified” rather than “first ever”.
