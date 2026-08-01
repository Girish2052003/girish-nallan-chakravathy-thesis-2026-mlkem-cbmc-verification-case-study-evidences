# Complete A-to-Z Technical, Assurance, and Novelty Record of the `mlk_poly_tomsg` MSG-T1 CBMC Verification Campaign

**Researcher:** Girish Nallan Chakravathy  
**Institutional context:** MSc thesis, Tampere University  
**Case study:** AI-assisted generation and human-controlled verification of candidate CBMC artefacts for selected ML-KEM C code  
**Target implementation:** `mlkem-native`  
**Target function:** `mlk_poly_tomsg`  
**Completed theorem:** MSG-T1 — exact canonical-domain message-decoding functional refinement  
**Primary formal tool:** CBMC 6.9.0  
**Integrated record date:** 23 July 2026  
**Authoritative source commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Nature of this document:** first-person technical research record, not a conversational explanation  
**Evidence cut-off:** completion and locking of MSG-01M-R2; MSG-T2, MSG-T3, and MSG-T4 remain future work

---

# Executive summary

I completed a source-bound, assumption-explicit, non-vacuity-hardened, mutation-tested CBMC campaign for the portable-C implementation of:

```c
mlk_poly_tomsg(msg, &a);
```

The completed theorem establishes that, for every canonical ML-KEM polynomial coefficient and every corresponding output bit, the actual frozen production implementation produces exactly the one-bit compression and packing result required by the registered independent oracle.

For every coefficient index:

```text
k ∈ {0, ..., 255}
```

under the canonical-domain assumption:

```text
0 <= a.coeffs[k] < 3329
```

the proved relation is:

```text
((msg[k >> 3] >> (k & 7)) & 1)
    ==
((a.coeffs[k] >= 833) && (a.coeffs[k] <= 2496))
```

Equivalently:

```text
coefficient 0..832      -> output bit 0
coefficient 833..2496   -> output bit 1
coefficient 2497..3328  -> output bit 0
```

with coefficient `k` packed into bit position:

```text
k & 7
```

of byte:

```text
k >> 3
```

The final evidence consists of:

```text
Positive MSG-T1 properties:       521 / 521 SUCCESS
Companion properties:             522 / 522 SUCCESS
Registered coverage goals:         12 / 12 SATISFIED
Relevant loop-sensitivity controls: 4 / 4 PASS
Frozen non-equivalent mutants:      8
Killed mutants:                     8 / 8
Surviving mutants:                  0
Unexpected mutant failures:         0
Unknown mutant properties:          0
Final package manifest:             PASS
Final package lock:                 PASS
Final archive verification:         PASS
Final capture status:               0
```

The final archive is:

```text
/home/girish/THESIS-2026/mlk_poly_tomsg_cleanroom/
MSG01M_R2_T1_FINAL_EVIDENCE_CONSOLIDATION_af4c5abdd595.tar.gz
```

with SHA-256:

```text
1477c76ca5208a40d813c16a077d9f5534f0a256380ca0c9056ebf08f05d58bc
```

The final campaign status is:

```text
MSG_T1_CORE_PROOF_CAMPAIGN=PASS
FINAL_CONSOLIDATION_AUDIT=PASS
FINAL_EVIDENCE_CONSOLIDATION=PASS
CAMPAIGN_STATUS=COMPLETE_WITHIN_FROZEN_MSG_T1_SCOPE
CAPTURE_STATUS=0
```

The strongest honest conclusion is:

> For `mlkem-native` commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`, under the frozen ML-KEM-768 portable-C build, canonical coefficient domain, object assumptions, verification adapters, machine model, safety checks, and complete finite-loop model recorded by the campaign, CBMC found no counterexample to the exact `mlk_poly_tomsg` functional-refinement property. The positive result is additionally supported by explicit reachability and non-vacuity evidence and by successful detection of all eight frozen non-equivalent implementation and oracle/assertion mutants.

This is a strong, property-specific proof result. It is not a proof of all ML-KEM, all possible inputs, all backends, all compiler outputs, or all security properties.

---

# 1. Research purpose and trust boundary

The research purpose was not simply to invoke an existing repository command. I investigated whether an LLM-assisted workflow could help a human researcher move from implementation and specification context to useful candidate formal-verification artefacts while maintaining a strict separation between generated suggestions and authoritative formal evidence.

The practical workflow became:

```text
FIPS and source context
        ↓
candidate theorem and assumptions
        ↓
clean-room harness and independent oracle
        ↓
source/build/path binding
        ↓
GOTO model construction
        ↓
structural inspection
        ↓
freeze before property solving
        ↓
authoritative positive CBMC execution
        ↓
deterministic result parsing
        ↓
reachability and non-vacuity controls
        ↓
loop-bound sensitivity controls
        ↓
implementation and oracle/assertion mutants
        ↓
manifests, locks, and final archive
        ↓
professor-facing theorem and limitations record
```

The central trust boundary was:

> The LLM did not prove `mlk_poly_tomsg`. It proposed candidate properties, harness code, scripts, diagnoses, repairs, and documentation. A claim was accepted only after deterministic source checks, GOTO construction and validation, structural model inspection, CBMC execution, raw-result parsing, reachability controls, mutation analysis, manifest verification, and evidence locking.

This distinction is essential because several generated scripts and classifiers were wrong. Those errors were discovered by terminal execution and exact artefact inspection. They were preserved as correction evidence rather than hidden.

---

# 2. Technical context

The completed campaign used:

```text
Standard:               NIST FIPS 203
Algorithm:              ML-KEM
Parameter set:          ML-KEM-768
Polynomial degree:      MLKEM_N = 256
Modulus:                MLKEM_Q = 3329
Message length:         32 bytes
Implementation path:    portable C
Assembly path:          disabled
C model:                C90 plus fixed-width integer types
CBMC:                   6.9.0
goto-cc:                6.9.0
goto-instrument:        6.9.0
SAT solver:             minisat2
Object bits:            8
```

The authoritative source repository was:

```text
/home/girish/THESIS-2026/mlkem-native_af4c5abd
```

at commit:

```text
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

Important source hashes were:

```text
compress.c:
9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad

compress.h:
0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd
```

The source/path-binding amendment had SHA-256:

```text
0f739b77285edb9fd512eb899a1c7ba0cc98ad6673e3848a89a3ebb0f89d34c3
```

The authoritative worktree was required to remain clean. Mutations were created only in isolated campaign copies.

---

# 3. Clean-room origin of the theorem

The first property-development stage used an accepted clean-room source packet with SHA-256:

```text
e557c98ff5d3e3735d9f9f59c67a030e87ea0f4898b92d120856321a74ba7f45
```

The packet contained 341 tracked source entries. The initial discovery input excluded paths containing:

```text
proofs/
tests/
test/
examples/
*harness*
```

This exclusion had a narrow purpose: the first theorem and harness architecture were to be derived from production code, FIPS-level behavior, data structures, constants, and research goals rather than by copying an existing repository harness.

This clean-room restriction does not mean upstream verification was absent. After the independent candidate was developed, I deliberately inspected the upstream contracts and proof directories to determine overlap and novelty. This two-stage process allowed both independent generation and honest prior-art comparison.

---

# 4. What upstream `mlkem-native` already proves

The public `mlkem-native` project already has a substantial formal-verification framework.

The upstream project states that its C code is proved memory-safe and type-safe with CBMC. It embeds function contracts and loop invariants in the C source. It also reports object-code-level functional-correctness, memory-safety, and secret-independent-timing proofs for supported AArch64 and x86-64 assembly using HOL Light and the `s2n-bignum` infrastructure.

The public CBMC proof documentation describes its harnesses as boilerplate around specifications embedded in the C source and presents the C proof goal primarily as absence of selected classes of undefined behavior, memory unsafety, and type unsafety.

Consequently, I do **not** claim:

- the first formal verification of ML-KEM;
- the first CBMC verification of `mlkem-native`;
- the first memory-safety proof of the implementation;
- the first type-safety proof of the implementation;
- the first proof involving `mlk_indcpa_dec`;
- the first proof of a polynomial loop;
- the first use of function contracts or loop invariants in `mlkem-native`;
- the first AI-assisted formal-verification workflow.

The research contribution must be expressed at the level of the independently authored functional theorem, its executable harness, its non-vacuity and mutation controls, and its evidence architecture.

---

# 5. Why `mlk_poly_tomsg` was selected

The previous subtraction and production-slice work established that, under registered caller bounds:

```c
mlk_poly_sub(&v, &sb);
mlk_poly_reduce(&v);
mlk_poly_tomsg(m, &v);
```

could be modeled with:

- signed-representable subtraction;
- exact subtraction;
- source-frame preservation;
- real canonical reduction;
- canonical input to `mlk_poly_tomsg`;
- preservation of the polynomial input by `mlk_poly_tomsg`;
- bounded C safety checks.

However, that work did not isolate and package the strongest direct theorem for the exact 256-bit message mapping performed by `mlk_poly_tomsg`.

MSG-T1 was therefore selected to prove the implementation-level refinement:

```text
canonical polynomial
        ↓
Compress_1 per coefficient
        ↓
least-significant-bit-first message packing
        ↓
32-byte output
```

This made MSG-T1 a logical extension of the earlier production-slice work rather than a disconnected micro-function exercise.

---

# 6. Production implementation checked

The frozen portable-C target has the structure:

```c
void mlk_poly_tomsg(uint8_t msg[MLKEM_INDCPA_MSGBYTES],
                    const mlk_poly *r)
{
    unsigned i;

    mlk_assert_bound(r, MLKEM_N, 0, MLKEM_Q);

    for (i = 0; i < MLKEM_N / 8; i++)
    {
        unsigned j;
        msg[i] = 0;

        for (j = 0; j < 8; j++)
        {
            uint32_t t =
                mlk_scalar_compress_d1(r->coeffs[8 * i + j]);

            msg[i] |= (uint8_t)(t << j);
        }
    }
}
```

The reachable compression helper used arithmetic of the form:

```c
uint32_t d0 = (uint32_t)u * 1290168;
return (uint8_t)((d0 + ((uint32_t)1u << 30)) >> 31);
```

The MSG-T1 model retained the actual target and helper bodies. They were not replaced by assumed function contracts.

---

# 7. Exact mathematical oracle

For canonical:

```text
u ∈ {0, ..., 3328}
```

and:

```text
q = 3329
```

the registered one-bit oracle was derived from the FIPS-style compression expression:

```text
Compress1(u) = ((2*u + floor(q/2)) / q) mod 2
```

using integer division.

The resulting threshold partition is:

```text
0 <= u <= 832       -> 0
833 <= u <= 2496    -> 1
2497 <= u <= 3328   -> 0
```

The arithmetic expression and threshold implementation were exhaustively compared over every canonical value:

```text
inputs checked: 3329
mismatches:     0
```

The oracle-validation log had SHA-256:

```text
b89dfb5453b55639c52110bf22d1280795970f246ae66caa90747ed5f69b557e
```

This prevented the central proof from relying solely on an unvalidated threshold shortcut.

---

# 8. Formal MSG-T1 theorem

Let `a` be a valid `mlk_poly` object with:

```text
0 <= a.coeffs[k] < 3329
```

for every:

```text
k ∈ {0, ..., 255}
```

Let `msg` be valid 32-byte output storage.

After execution of:

```c
mlk_poly_tomsg(msg, &a);
```

the theorem requires:

```text
((msg[k >> 3] >> (k & 7)) & 1)
    ==
Compress1(a.coeffs[k])
```

for every flat index `k`.

Using the independently validated threshold oracle, this is:

```text
((msg[k >> 3] >> (k & 7)) & 1)
    ==
((a.coeffs[k] >= 833) && (a.coeffs[k] <= 2496))
```

The theorem simultaneously checks:

1. the correct coefficient is read;
2. the correct one-bit compression class is produced;
3. the correct byte is selected;
4. the correct bit position is used;
5. earlier and later bits are not shifted into the wrong position;
6. all 256 coefficient/bit positions are covered by the universal assertion.

---

# 9. MSG-T1 assumptions

The theorem is conditional on the following frozen assumptions and model choices.

## 9.1 Canonical input domain

For all coefficients:

```text
0 <= a[k] < 3329
```

The theorem does not cover noncanonical representations.

## 9.2 Parameter and configuration assumptions

```text
ML-KEM parameter set: 768
MLKEM_N:              256
MLKEM_Q:              3329
message bytes:        32
```

## 9.3 Object assumptions

The harness models:

- a valid polynomial object;
- valid 32-byte output storage;
- the registered harness-owned object separation;
- a successful execution path.

It does not prove allocator failure handling or every external caller.

## 9.4 Backend assumptions

The proof targets:

- portable C;
- no native assembly arithmetic path;
- the frozen compilation namespace;
- the frozen support adapters.

## 9.5 Verification-model assumptions

The conclusion depends on:

- CBMC 6.9.0;
- the selected C and machine model;
- the exact GOTO model;
- the recorded verification checks;
- the model-derived loop inventory;
- the complete finite unwind set;
- the selected SAT solver;
- the frozen source and harness hashes.

## 9.6 Intentional unsigned wrap

The production `mlk_scalar_compress_d1` arithmetic includes an unsigned addition for which modular wrap is intended.

The accepted direct pragma scope disabled only the intended addition-wrap property:

```text
mlk_scalar_compress_d1.overflow.3
```

while retaining the other relevant conversion/overflow properties:

```text
mlk_scalar_compress_d1.overflow.1
mlk_scalar_compress_d1.overflow.2
```

This was not a blanket suppression of arithmetic checks.

---

# 10. Frozen harness identity

The accepted frozen harness was:

```text
msg_t1_exact_fips_candidate_v4.c
```

with SHA-256:

```text
5ce480427d7792b3dca091ac198b43562c4d4dfd6c9d96dae5a73e7ef1e72b55
```

The accepted positive GOTO model had SHA-256:

```text
51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d
```

The candidate was frozen before authoritative property solving in:

```text
MSG01G_R1_T1_FROZEN_EXECUTION_INPUT_V1_af4c5abdd595/
frozen_candidate_v1
```

The freeze status was:

```text
CANDIDATE_STATUS=FROZEN_READY_FOR_POSITIVE_EXECUTION
```

---

# 11. Why the new harness is genuinely distinct from upstream

The distinction is not based on changing a filename or namespace. It is based on proof intent, assertions, oracle construction, model treatment, controls, and evidence architecture.

## 11.1 Upstream public proof boundary

At the time of the novelty review, the current public `proofs/cbmc` directory listed many function-specific proof directories, including `indcpa_dec`, `barrett_reduce`, `poly_add`, compression functions, and decompression functions. I did not locate a dedicated public `poly_tomsg` proof directory in that listing.

The current public `mlk_poly_tomsg` source body contains:

- the canonical-input bound assertion;
- loop invariants and decreases clauses;
- the actual compression and bit-packing implementation.

In the inspected source, it does not expose a dedicated function-level postcondition stating the exact 256-bit output relation to `Compress1`.

This does **not** mean upstream provides no assurance for the function. The source is included within the project’s broader C safety-verification framework, and a higher-level `indcpa_dec` proof directory exists. The precise distinction is that I did not locate the same dedicated all-bit functional theorem and evidence campaign in the public proof tree inspected.

## 11.2 Independent functional oracle

The campaign harness introduced a separately validated `Compress1` threshold oracle. The proof did not merely check that outputs were in bounds or that the function executed safely.

## 11.3 Exact all-bit postcondition

The central assertion quantified over every flat output bit and linked it to the corresponding input coefficient.

## 11.4 Explicit boundary properties

The frozen inventory required named checks for:

```text
0
832
833
2496
2497
3328
```

covering both threshold transitions and the canonical endpoints.

## 11.5 Explicit packing relation

The harness checked:

```text
byte = k >> 3
bit  = k & 7
```

rather than treating the output as an uninterpreted 32-byte object.

## 11.6 Executable-body inspection

The campaign audited that the GOTO path contained:

```text
main
  -> independent oracle
  -> actual mlk_poly_tomsg body
       -> actual mlk_scalar_compress_d1 body
```

No target or helper contract was accepted as a body substitute.

## 11.7 Operational non-vacuity

The campaign added:

- a cover-bearing original model;
- a cover-neutral companion;
- threshold and interior reachability goals;
- low, middle, and high output-index goals;
- insufficient-unwind controls for actual multi-iteration loops.

## 11.8 Mutation sensitivity

The campaign froze and killed:

- four implementation mutants;
- four oracle/assertion mutants.

## 11.9 Evidence identity

The campaign maintained its own:

- source and path hashes;
- harness hash;
- GOTO hash;
- command;
- loop inventory;
- raw JSON;
- deterministic parser;
- mutation family;
- manifests;
- read-only locks;
- final archive.

The correct description is:

> an independently authored, exact functional-refinement and assurance-evaluation harness for the frozen production `mlk_poly_tomsg` implementation.

It should not be described as:

> a completely unrelated implementation, a replacement for upstream verification, or proof that upstream did no verification of the function.

---

# 12. Frozen property markers

The accepted property inventory required seven named MSG-T1 markers:

1. polynomial degree equals 256;
2. message size equals 32 bytes;
3. lower-zero boundary;
4. lower-one boundary;
5. upper-one boundary;
6. upper-zero boundary;
7. exact equality of every output bit to the independent `Compress1` oracle.

The exact theorem marker was:

```text
MSG_T1_EXACT:
every output bit must equal the independent Compress1 oracle
```

The full CBMC inventory also included generated safety properties. Therefore, the `521` positive results must not be described as 521 independent mathematical theorems.

---

# 13. Structural model evidence

The frozen reachable path was:

```text
main
  -> msg_t1_threshold_oracle
  -> mlk_msg01f_poly_tomsg
       -> mlk_scalar_compress_d1
```

The five reachable loop identifiers were:

```text
main.0
main.1
mlk_msg01f_poly_tomsg.0
mlk_msg01f_poly_tomsg.1
mlk_msg01f_poly_tomsg.2
```

The frozen positive unwind set was:

```text
main.0:257,
main.1:257,
mlk_msg01f_poly_tomsg.0:257,
mlk_msg01f_poly_tomsg.1:257,
mlk_msg01f_poly_tomsg.2:257
```

Later source mapping classified the production loops as:

```text
target loop .0 -> macro-origin bound-check loop
target loop .1 -> inner j loop
target loop .2 -> outer i loop
```

The macro-origin loop was complete with bound one. The inner and outer production loops required multi-iteration bounds and were tested with insufficient-bound controls.

---

# 14. Positive execution

The authoritative positive execution was MSG-01H.

It produced:

```text
CBMC_EXIT=0
PROPERTY_RECORD_COUNT=521
SUCCESS_COUNT=521
FAILURE_COUNT=0
UNKNOWN_COUNT=0
VERIFICATION SUCCESSFUL
```

The raw positive JSON had SHA-256:

```text
3b32112c5537a95d470b0b866c1edf6cb1f8c3be408188c9fc2cdbf91fab40ee
```

The accepted conclusion at this stage was deliberately limited:

> CBMC found no counterexample to the frozen exact theorem and enabled safety checks under the frozen assumptions, source, build, model, and unwind set.

A positive result alone was not treated as sufficient evidence of non-vacuity.

---

# 15. Reachability and non-vacuity evidence

## 15.1 Cover-neutral companion

The assertion-preserving companion executed without cover instructions and returned:

```text
PROPERTY_RECORD_COUNT=522
SUCCESS_COUNT=522
FAILURE_COUNT=0
UNKNOWN_COUNT=0
```

This established that removal of the cover instrumentation did not invalidate the remaining theorem and safety properties.

## 15.2 Twelve reachability goals

The original model registered these twelve cover classes:

1. coefficient `0` reaches output class `0`;
2. coefficient `832` reaches the lower-zero boundary;
3. coefficient `833` reaches the lower-one boundary;
4. coefficient `2496` reaches the upper-one boundary;
5. coefficient `2497` reaches the upper-zero boundary;
6. coefficient `3328` reaches output class `0`;
7. an interior lower-zero value is reachable;
8. an interior one-region value is reachable;
9. an interior upper-zero value is reachable;
10. output index `0` is reachable;
11. output index `127` is reachable;
12. output index `255` is reachable.

The final result was:

```text
COVERAGE_SATISFIED=12
COVERAGE_TOTAL=12
COVERAGE_FAILED_LINE_COUNT=0
ORIGINAL_MODEL_ALL_12_COVERS_SATISFIED=PASS
```

These goals demonstrate that the canonical range, both threshold transitions, all three result regions, and low/middle/high output positions are represented in the model.

## 15.3 Loop-bound sensitivity controls

The campaign reused or executed five loop classifications:

```text
U1  main assumption loop:       insufficient bound rejected
U2  main assertion loop:        insufficient bound rejected
U3  target macro-origin loop:   bound one sufficient
U4  target inner loop:          insufficient bound rejected
U5  target outer loop:          insufficient bound rejected
```

The four genuinely multi-iteration loops produced the expected unwind failures under deliberately insufficient bounds.

U3 was important because the first expectation was wrong. Its bound-one result was byte-for-byte identical to the accepted full-bound companion result. Source mapping showed that the loop originated from the bound-check macro and was complete with bound one. It was correctly reclassified rather than forced to fail.

The final summary recorded:

```text
PASSED_MULTI_ITERATION_CONTROL_COUNT=4
ALL_ALGORITHMIC_LOOP_SENSITIVITY_CONTROLS=PASS
```

---

# 16. Mutation sensitivity

## 16.1 Freeze-before-solving rule

All mutants were:

- generated in isolated copies;
- assigned an explicit non-equivalence witness;
- checked for exactly one registered changed file;
- compiled to GOTO;
- validated;
- structurally audited;
- given a model-derived unwind set;
- frozen and locked before expected-failure solving.

This prevented post-result mutation editing.

## 16.2 Implementation mutants

### I1 — output-byte initialization mutation

```text
msg[i] = 0
```

was changed to:

```text
msg[i] = 1
```

Witness: all-zero coefficients should produce zero, but the forced low bit produces one.

### I2 — reversed coefficient order within a byte

The implementation read:

```text
r->coeffs[8*i + (7-j)]
```

instead of:

```text
r->coeffs[8*i + j]
```

Witness: coefficient 0 in the one-region and coefficient 7 in a zero-region.

### I3 — rotated output-bit position

The compressed bit was shifted to the next position instead of position `j`.

Witness: coefficient 0 in the one-region with the remaining byte coefficients in zero-regions.

### I4 — inverted compression result

The one-bit result of `mlk_scalar_compress_d1` was XORed with one.

Witness: canonical coefficient zero.

## 16.3 Oracle/assertion mutants

### O1 — lower threshold moved upward

```text
833 -> 834
```

Witness: coefficient `833`.

### O2 — upper threshold moved downward

```text
2496 -> 2495
```

Witness: coefficient `2496`.

### O3 — assertion-side bit order reversed

The assertion compared against bit:

```text
7 - (k & 7)
```

instead of:

```text
k & 7
```

Witness: differing bit classes at positions 0 and 7.

### O4 — expected coefficient shifted

The assertion used:

```text
a.coeffs[(k + 1) & 255]
```

instead of:

```text
a.coeffs[k]
```

Witness: coefficient 0 in the one-region and coefficient 1 in a zero-region.

## 16.4 Equivalent-mutant avoidance

Candidate mutations such as a multiplier change by `±1` were not accepted merely because they looked different in source code. Analysis showed that some small arithmetic changes remain observationally equivalent over the canonical domain.

The final family used only mutants with explicit semantic witnesses demonstrating non-equivalence under the modeled interface.

## 16.5 Mutation result

Every mutant returned expected CBMC failure exit `10` and failed the exact MSG-T1 assertion.

The final matrix recorded:

```text
EXECUTED_MUTANT_COUNT=8
KILLED_MUTANT_COUNT=8
SURVIVING_MUTANT_COUNT=0
ALL_EIGHT_MUTANTS_KILLED=PASS

ALL_MUTANTS_FAILED_MSG_T1_EXACT=PASS
ALL_MUTANTS_UNWIND_FAILURE_COUNT_ZERO=PASS
ALL_MUTANTS_UNEXPECTED_FAILURE_COUNT_ZERO=PASS
```

The mutants were not counted as killed if they failed only because of insufficient unwinding or an unrelated property.

---

# 17. Complete correction history

The correction history is part of the scientific evidence because it shows where generated artefacts or interpretations were wrong.

## 17.1 Candidate pragma recovery

The production compression helper’s unsigned wrap policy was initially lost when `compress.h` was included with `CBMC` undefined.

An attempted repair defining `CBMC` activated unwanted contract helpers. The accepted repair kept contract macros erased and directly applied the narrow pragma scope around `compress.h`.

## 17.2 MSG-01G property-inventory false rejection

The first candidate-freeze audit rejected every `mlk_scalar_compress_d1.*overflow` property.

The corrected audit distinguished:

```text
required:
overflow.1
overflow.2

intentionally absent:
overflow.3
```

Classification:

```text
PROPERTY_INVENTORY_AUDIT_FALSE_REJECTION
FUNCTIONAL_COUNTEREXAMPLE=NO
CBMC_PROPERTY_SOLVING_EXECUTED=NO
```

## 17.3 MSG-01I raw-call-graph false rejection

The original reachability model contained the cover primitive and the companion did not. A raw function-set comparison therefore failed.

The corrected audit normalized instrumentation-only differences and compared the actual theorem path.

## 17.4 MSG-01J static unwind-property derivation error

An early script attempted to derive symbolic unwinding-property identifiers from `--show-properties`.

This was invalid because the static property inventory does not necessarily enumerate the dynamic unwind properties expected by that script.

## 17.5 MSG-01J-R1 post-proof unwind-ID false rejection

The companion proof itself passed:

```text
522 / 522 SUCCESS
```

but a parser expected guessed identifiers such as:

```text
main.unwind.0
```

and rejected the run when they were absent.

A diagnostic established that no standalone full-bound unwind records were present because the complete loops terminated before reaching the unwind limit.

## 17.6 MSG-01J-R2 macro-loop expectation error

The target loop `.0` was incorrectly expected to fail at bound one.

Its result was byte-identical to the full-bound companion. Source mapping showed that it was a macro-origin loop for which bound one was sufficient.

The corrected R3 stage tested the actual inner and outer multi-iteration production loops and completed all covers.

## 17.7 MSG-01K permission-preservation failure

The first mutation generator used:

```python
shutil.copy2()
```

which preserved the frozen source files’ read-only mode. The generator then failed when attempting to write isolated mutants.

No mutant GOTO was built and no mutation solving ran.

The R1 generator used byte-only copying and explicitly writable isolated copies while leaving authoritative evidence read-only.

## 17.8 MSG-01M lock-root false rejection

The first consolidation script checked the outer MSG-01G-R1 container as if every file and directory were part of the frozen lock boundary.

The actual frozen boundary was:

```text
frozen_candidate_v1
```

The correction verified the real frozen root instead of weakening its lock.

## 17.9 MSG-01M-R1 post-tee status-location false rejection

The R1 consolidation looked for:

```text
CAPTURE_STATUS=15
```

inside a capture created by `tee`, even though the status was printed after the pipeline had closed.

The R2 correction validated only lines that actually existed inside the preserved capture.

## 17.10 Scientific interpretation

None of these script or parser defects was presented as an implementation counterexample. None was repaired by weakening the theorem, deleting an unexpected failure, editing the production source, or modifying the accepted positive harness after solving.

The failed attempts were preserved and classified.

---

# 18. Final evidence consolidation

MSG-01M-R2 reverified:

- source commit;
- clean worktree;
- source hashes;
- path amendment;
- harness hash;
- positive GOTO hash;
- positive JSON hash;
- five authoritative package manifests;
- five authoritative frozen-root locks;
- positive property cardinality;
- companion property cardinality;
- coverage cardinality;
- loop-control cardinality;
- mutation-family cardinality;
- killed-mutant cardinality;
- correction-record cardinality;
- frozen source/harness snapshot;
- package digest table;
- mutant-result hash table;
- final evidence matrix.

It explicitly recorded:

```text
CBMC_SOLVING_EXECUTED=NO
GOTO_REBUILD_EXECUTED=NO
SOURCE_MUTATION_EXECUTED=NO
FINAL_RAW_EVIDENCE_REPLACED=NO
```

The consolidation was an integrity and documentation stage, not a new proof run.

The final package was:

- manifested;
- verified;
- changed to file mode `0444`;
- changed to directory mode `0555`;
- archived deterministically;
- gzip-tested;
- tar-listed;
- SHA-256 hashed.

---

# 19. Did I prove MSG-T1 is “really true”?

## 19.1 Yes, within the frozen theorem scope

The answer is **yes**, provided the statement is qualified correctly.

For every symbolic canonical 256-coefficient input in the frozen ML-KEM-768 portable-C model, CBMC proved the exact coefficient-to-bit relation for all 256 output bits under the recorded assumptions and verification checks.

The result is supported by:

```text
positive theorem solving
AND
complete-loop treatment
AND
threshold and index reachability
AND
cover-neutral companion success
AND
insufficient-bound sensitivity
AND
eight killed non-equivalent mutants
AND
source/model/result binding
```

It is therefore much stronger than saying:

```text
the program compiled
```

or:

```text
some examples passed
```

or:

```text
the function was memory-safe
```

## 19.2 What “proved” means here

The solver established unsatisfiability of a counterexample formula for the frozen finite model. In practical terms:

> No input satisfying the frozen assumptions can violate the exact assertion in that model.

Because all relevant loops have fixed finite bounds and the campaign checked complete unwind treatment, this is not merely evidence for a few sampled executions.

## 19.3 What “proved” does not mean

It does not establish:

- correctness for noncanonical coefficients;
- correctness for every future source revision;
- correctness of native assembly alternatives;
- correctness of ML-KEM-512 or ML-KEM-1024 builds;
- compiler-to-machine-code refinement;
- complete decryption correctness;
- IND-CCA security;
- constant-time execution;
- absence of cache, power, electromagnetic, speculative, or fault leakage;
- every conceivable functional property of `mlk_poly_tomsg`;
- completeness against every possible mutant.

The exact statement “MSG-T1 is proved” must always be followed by:

```text
within the frozen source, build, canonical domain,
machine model, assumptions, checks, and finite loop model
```

---

# 20. Proved, supported, planned, and not proved

| Claim | Status |
|---|---|
| Canonical coefficients map to the correct threshold bit | **proved within MSG-T1 scope** |
| Every one of 256 coefficients maps to its corresponding flat output bit | **proved within MSG-T1 scope** |
| Least-significant-bit-first packing is correct | **proved within MSG-T1 scope** |
| Threshold boundaries 832/833 and 2496/2497 are reachable | **supported by explicit covers** |
| Canonical endpoints 0 and 3328 are reachable | **supported by explicit covers** |
| Low, middle, and high flat indices are reachable | **supported by explicit covers** |
| Positive assertion set remains valid without cover instructions | **proved in companion model** |
| Actual multi-iteration loops are sensitive to insufficient bounds | **supported by four expected-failure controls** |
| Exact theorem detects eight registered semantic defects | **proved for the frozen mutant family** |
| Input polynomial preservation | **proved in earlier SUB-T6 scope; not the central new MSG-T1 assertion** |
| Relational locality and determinism, MSG-T2 | **planned, not yet proved** |
| Output initialization independence/footprint, MSG-T3 | **planned, not yet proved** |
| `sub → reduce → tomsg` exact composition, MSG-T4 | **planned as a separate theorem family** |
| Noncanonical-input correctness | **not proved** |
| Constant-time or side-channel security | **not proved** |
| Full ML-KEM correctness | **not proved** |

---

# 21. Novelty review methodology

The novelty review was performed on 23 July 2026.

The public search and inspection covered:

- the current official `mlkem-native` repository and README;
- the current public `proofs/cbmc` function-directory listing;
- the current public `mlk_poly_tomsg` source;
- NIST FIPS 203;
- public reporting on `mlkem-native` verification;
- public ML-KEM formal-verification projects;
- searches for `mlk_poly_tomsg`, `poly_tomsg`, `Compress1`, `ByteEncode1`, CBMC, functional verification, mutation testing, non-vacuity, and AI-assisted harness generation;
- recent AI-assisted formal-verification literature.

A public search can establish what was located. It cannot mathematically prove that no unpublished, private, unindexed, differently named, or future work exists.

---

# 22. Novelty findings

## 22.1 Not novel: the mathematics

The following are standard or directly derived from FIPS 203 and the implementation:

- the `Compress1` operation;
- the message-decoding role of one-bit compression and byte encoding;
- the canonical modulus `3329`;
- 256 coefficients and 32 output bytes;
- least-significant-bit-first packing;
- the implementation’s compression constants and loops.

I do not claim the threshold theorem itself as a new mathematical discovery.

## 22.2 Not novel: broad ML-KEM verification

Formal verification of ML-KEM and `mlkem-native` already exists. The upstream project publicly reports broad CBMC safety proofs for C and HOL Light proofs for supported assembly.

Other public work also studies high-assurance and formally verified ML-KEM implementations.

## 22.3 Not novel: AI-assisted formal verification in general

LLM-assisted generation of specifications, proofs, assertions, code, and harnesses is an active research area. Recent work also studies non-vacuity and mutation-guided improvement, especially for hardware or proof-oriented languages.

Therefore, the broad idea:

```text
use an LLM and then use a formal tool
```

is not novel.

## 22.4 Potentially original: the exact MSG-T1 case-study artefact

I did not locate a public source documenting this exact combination:

1. a dedicated CBMC theorem for the frozen production `mlk_poly_tomsg` C body;
2. an independently authored all-256-bit postcondition;
3. a separately validated `Compress1` threshold oracle;
4. explicit bit-to-byte packing equality;
5. threshold endpoint and interior reachability goals;
6. low, middle, and high flat-index covers;
7. a cover-neutral companion;
8. operational insufficient-unwind controls;
9. four implementation mutants;
10. four oracle/assertion mutants;
11. explicit equivalent-mutant avoidance;
12. freeze-before-solving mutation evidence;
13. deterministic source, harness, GOTO, command, and result binding;
14. preserved failed attempts and correction taxonomy;
15. locked stage manifests and a deterministic final archive;
16. use of the campaign to evaluate the usefulness and failure modes of LLM-assisted candidate artefact generation.

The current public upstream proof listing inspected did not show a dedicated `poly_tomsg` CBMC proof directory. The public source body inspected had input-bound and loop annotations but no visible dedicated exact-output postcondition equivalent to MSG-T1.

This supports a claim that the **exact campaign artefact and evidence architecture are distinct from the public upstream proof structure inspected**.

It does not support a claim that nobody has ever reasoned about the function, that no higher-level proof reaches it, or that the implementation lacked all prior formal assurance.

---

# 23. Novelty potency assessment

| Novelty dimension | Assessment | Basis |
|---|---|---|
| Mathematical novelty | low | the compression and packing relation is standard |
| New cryptographic algorithm | none | no new algorithm was proposed |
| New implementation | none | the campaign checks upstream production code |
| New dedicated functional theorem for the inspected function/revision | moderate to strong | no exact public match located; upstream visible source lacks the same explicit postcondition |
| New harness artefact | strong within the case study | independently authored, clean-room-origin, exact all-bit oracle relation |
| New assurance controls | strong as an integrated package | covers, loop sensitivity, two-sided mutations, equivalent-mutant screening |
| New reproducibility/evidence architecture | strong within MSc scope | source/GOTO/result binding, manifests, locks, correction preservation |
| New AI evaluation evidence | moderate to strong | concrete record of generated-script failures and deterministic repair |
| Universal “first ever” potency | unsupported | public search cannot prove universal nonexistence |
| MSc thesis contribution potency | strong if carefully framed | clear artefact, empirical evidence, failures, repairs, limits, and reproducibility |

The contribution is strongest as a **verification-engineering and AI-assistance case study**, not as a new cryptographic theorem.

---

# 24. Defensible novelty claim

The recommended claim is:

> This thesis presents an independently authored and reproducibly packaged CBMC functional-refinement campaign for the frozen portable-C `mlk_poly_tomsg` implementation. The campaign checks the exact canonical coefficient-to-message-bit relation against a separately validated `Compress1` oracle and strengthens the positive result with explicit reachability, loop-bound sensitivity, implementation mutations, oracle/assertion mutations, deterministic source/model/result binding, and preservation of failed generated artefacts. A public review completed on 23 July 2026 found no exact match for this combined theorem-and-evidence package. The result is therefore presented as a distinct and apparently original MSc case-study contribution, not as an absolute first-ever claim.

A shorter thesis claim is:

> The originality lies not in discovering the `Compress1` mathematics, but in constructing and evaluating a new, independently authored, falsification-resistant CBMC artefact and evidence workflow for the exact production `mlk_poly_tomsg` mapping.

---

# 25. Claims that must not be used

The following wording would overclaim:

```text
I produced the first formal proof of ML-KEM.
```

```text
I proved all of mlkem-native correct.
```

```text
Nobody has ever proved mlk_poly_tomsg.
```

```text
The upstream repository has no proof of this function.
```

```text
MSG-T1 proves constant-time execution.
```

```text
521 properties mean 521 new theorems.
```

```text
Killing eight mutants proves detection of every possible defect.
```

```text
A successful CBMC run proves correctness independently of assumptions.
```

---

# 26. Recommended professor-facing result statement

> I verified a property-specific exact functional refinement of `mlk_poly_tomsg` in `mlkem-native` at commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`. For every canonical 256-coefficient input polynomial, the frozen portable-C implementation produces the exact 32-byte least-significant-bit-first encoding of the independently validated one-bit ML-KEM compression classes. The positive CBMC model returned 521 successful properties with no failures or unknowns. An assertion-preserving companion returned 522 successful properties. All twelve registered boundary, region, and index cover goals were satisfied. Four multi-iteration loop controls detected insufficient bounds, and all eight frozen non-equivalent implementation and oracle/assertion mutants were killed by the exact functional assertion. The final evidence package was manifest-verified, locked, and archived. The claim remains conditional on the frozen source, canonical input domain, portable-C build, machine model, verification adapters, safety checks, and complete finite-loop model.

---

# 27. Contribution to the thesis research questions

## RQ1 — Candidate artefact generation

The campaign demonstrates that an LLM-assisted workflow can help produce:

- a property decomposition;
- an independent oracle;
- a CBMC harness;
- build and support adapters;
- structural audits;
- expected-failure controls;
- mutants;
- deterministic parsers;
- evidence manifests;
- a theorem record.

It also demonstrates that generated artefacts require repeated deterministic correction.

## RQ2 — Lessons from high-assurance PQC workflows

The work adopts practices consistent with high-assurance cryptographic engineering:

- frozen source;
- explicit assumptions;
- narrow claims;
- executable-body inspection;
- complete-loop reasoning;
- independent specification checks;
- negative controls;
- provenance;
- reproducible evidence.

## RQ3 — Usefulness and failure modes

The campaign provides direct evidence of usefulness:

- rapid candidate theorem development;
- generation of detailed scripts;
- structured diagnosis;
- broad mutation design;
- documentation assistance.

It also provides direct evidence of failure modes:

- incorrect pragma handling;
- brittle property-name assumptions;
- confusion between static properties and dynamic unwind failures;
- incorrect loop classification;
- permission-preserving copy mistakes;
- incorrect lock boundaries;
- incorrect assumptions about `tee` capture content;
- risk of overclaiming novelty.

This mixed record is scientifically more useful than reporting only successful generations.

---

# 28. Reproducibility record

Important frozen identities include:

```text
SOURCE_COMMIT:
af4c5abdd5958bdc65a03cd5ee86708264f93304

COMPRESS_C_SHA256:
9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad

COMPRESS_H_SHA256:
0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd

BASE_HARNESS_SHA256:
5ce480427d7792b3dca091ac198b43562c4d4dfd6c9d96dae5a73e7ef1e72b55

BASE_GOTO_SHA256:
51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d

POSITIVE_JSON_SHA256:
3b32112c5537a95d470b0b866c1edf6cb1f8c3be408188c9fc2cdbf91fab40ee

FINAL_ARCHIVE_SHA256:
1477c76ca5208a40d813c16a077d9f5534f0a256380ca0c9056ebf08f05d58bc
```

Authoritative stage sequence:

```text
MSG-00CDE   source and path binding
MSG-01F     accepted candidate recovery
MSG-01G-R1  frozen positive execution input
MSG-01H     authoritative positive execution
MSG-01I-R1  frozen reachability-control family
MSG-01J-R3  final reachability and non-vacuity result
MSG-01K-R1  frozen mutation family
MSG-01L-R1  authoritative mutation execution
MSG-01M-R2  final evidence consolidation
```

---

# 29. Remaining work

MSG-T1 is closed. It should not be rerun or altered unless a deliberate new revision-replay campaign is registered.

The preregistered wider theorem family remains:

```text
MSG-T1  exact canonical-domain functional refinement       COMPLETE
MSG-T2  relational locality, separability, determinism     NOT YET PROVED
MSG-T3  initialization independence and state footprint    NOT YET PROVED
MSG-T4  subtract–reduce–tomsg exact composition             NOT YET PROVED
```

Possible future strengthening includes:

- a fresh replay against a later source revision;
- ML-KEM-512 and ML-KEM-1024 builds;
- a separately registered relational theorem;
- output-buffer initialization-independence checks;
- explicit input-frame checks in the same dedicated campaign;
- a composition theorem beginning before reduction;
- comparison with a second formal tool;
- compiler or object-code refinement;
- side-channel analysis using appropriate tools.

---

# 30. Final integrated verdict

## 30.1 What is proved

> Under the frozen MSG-T1 assumptions, the actual ML-KEM-768 portable-C `mlk_poly_tomsg` body produces, for every canonical input coefficient and every output position, the exact independently specified one-bit compression and least-significant-bit-first packing result. CBMC returned no counterexample, the relevant loops were completely treated, all registered coverage goals were satisfiable, and all eight frozen non-equivalent semantic mutants were rejected.

## 30.2 What is not proved

The work does not prove:

- all of ML-KEM;
- complete K-PKE decryption;
- every property of `mlk_poly_tomsg`;
- noncanonical inputs;
- all parameter sets;
- native assembly paths;
- compiled object-code equivalence;
- constant-time behavior;
- side-channel resistance;
- fault resistance;
- universal mutation completeness;
- universal novelty.

## 30.3 Final novelty position

> The MSG-T1 mathematics is not new. The publicly known existence of formal verification for ML-KEM and `mlkem-native` is not new. The defensible original contribution is the exact independently authored functional harness and the integrated assurance campaign built around it: separate oracle validation, all-bit refinement checking, operational non-vacuity, loop-bound sensitivity, implementation and oracle/assertion mutation testing, equivalent-mutant screening, deterministic evidence binding, correction preservation, and final locked packaging. No exact public match for this combined artefact was located in the review completed on 23 July 2026. This supports a carefully qualified claim of a distinct and apparently original MSc case-study contribution, not a claim of absolute priority.

---

# References

Amazon Science (2026) *Verifying and optimizing post-quantum cryptography at Amazon*. Published 7 April 2026.

Becker, H., Chapman, R. and Kostic, D. (2026) *Verifying and optimizing post-quantum cryptography at Amazon*. Amazon Science.

CBMC Project (2026) *Writing a good proof*. CBMC training documentation.

Kan, S., Kan, S. and Ertel, S. (2026) ‘Harnessing Code Agents for Automatic Software Verification’, arXiv:2607.06341.

Kroening, D., Schrammel, P. and Tautschnig, M. (2023) ‘CBMC: The C Bounded Model Checker’, arXiv:2302.02384.

Misu, M.R.H., Lopes, C.V., Ma, I. and Noble, J. (2024) ‘Towards AI-Assisted Synthesis of Verified Dafny Methods’, arXiv:2402.00247.

National Institute of Standards and Technology (2024) *FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard*. Gaithersburg, MD: NIST. DOI: 10.6028/NIST.FIPS.203.

pq-code-package (2026) *mlkem-native: Secure, fast, and portable C90 implementation of ML-KEM / FIPS 203*. Public source repository and CBMC proof documentation, inspected 23 July 2026.

Tessolve (2026) *Evaluating AI-Generated Formal Verification Harnesses for RTL Using an Open-Source, Non-Vacuity-Aware Flow*. Verification Futures 2026 UK.

---

# End-of-record declaration

This document records the completed MSG-T1 work as an evidence-bound research result. It does not replace the raw CBMC JSON, GOTO binaries, commands, manifests, correction records, or final archive. Where this narrative and the frozen machine-readable evidence disagree, the frozen source, commands, raw results, and verified manifests are authoritative.
