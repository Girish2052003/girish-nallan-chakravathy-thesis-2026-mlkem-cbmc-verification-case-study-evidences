# A–Z Verification Record and Professor Evidence Narrative

## `mlk_poly_sub`, `mlk_poly_reduce`, and the related `mlk_poly_add` record

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Record date:** 17 July 2026  
**Repository:** `pq-code-package/mlkem-native`  
**Frozen commit:** `d9613cf60de3132d32475c102d8c2781d84feb34`  
**Primary verification tool:** CBMC 6.9.0  
**Primary executed configuration:** ML-KEM-768  
**Execution platform:** x86-64 Ubuntu virtual machine  
**Primary production target:** portable C in `mlkem/src/poly.c`  

---

## 1. Purpose and authority boundary

This record documents the complete reasoning, experiment design, failure
analysis, corrected environment model, successful proof evidence, non-vacuity
checks, mutation testing, boundary design, prior-art audit, and final claim
boundary developed for the `mlk_poly_sub` case study. It also records the
separate `mlk_poly_add` PA-02 campaign so that the two case studies are not
confused.

The packet is authoritative for the artefacts it contains and independently
audited through SUB-00K. Preserved terminal output records the expected SUB-00L
result—SUB-T2 pass, valid boundaries pass, and invalid boundaries rejected—while
the raw SUB-00L archive was intentionally omitted. Accordingly, the SUB-00L
verdict is recorded from preserved terminal output rather than independently
re-audited from raw JSON in this packet. No missing result has been invented.

---

## 2. Executive result

### 2.1 `mlk_poly_sub` campaign

The campaign established the following independently audited results for the
frozen ML-KEM-768 portable-C model:

| Evidence item | Result | Meaning |
|---|---:|---|
| SUB-T0 repository baseline | Existing | Exact signed subtraction contract; not a new contribution |
| SUB-T1 semantic composition | **PASS** | Production subtraction followed by production reduction equals an independent canonical modular oracle |
| SUB-00I non-vacuity | **8/8 covered** | The assumptions and extreme scenarios are reachable; the theorem is not vacuous |
| SUB-00K mutation sensitivity | **3/3 killed** | Three deliberate faults were rejected by the intended semantic assertion |
| SUB-T2 relational theorem | Terminal-output record: **PASS** | `N(A-B)=N(N(A)-N(B))`; raw SUB-00L archive intentionally omitted |
| Valid boundary control | Terminal-output record: **PASS** | `INT16_MIN` and `INT16_MAX` differences normalize to expected residues |
| Invalid boundary controls | Terminal-output record: **REJECTED** | Differences `-32769` and `32768` are outside the permitted direct-subtraction domain |

The strongest independently audited semantic conclusion is:

> For every pair of distinct 256-coefficient polynomial objects whose direct
> coefficient differences are representable in `int16_t`, the retained
> production execution `mlk_poly_sub` followed by `mlk_poly_reduce` returns,
> coefficient by coefficient, the unique unsigned-canonical representative in
> `[0,3329)` equal to the independent specification-side modular oracle.

### 2.2 `mlk_poly_add` PA-02 campaign

The separate PA-02 record reports five successful focused CBMC campaigns:

| Sub-campaign | Verified property | Recorded result |
|---|---|---:|
| PA-02A | Exact signed coefficient-wise addition | PASS |
| PA-02B | Modulo-`q` refinement for signed/non-canonical representatives | PASS |
| PA-02C | Read-only operand preservation and local write-footprint guards | PASS |
| PA-02D | Relational commutativity | PASS |
| PA-02E | Additive identity over the complete `int16_t` domain | PASS |

The correct statement is that the complete planned PA-02 property suite was
verified for the pinned portable-C implementation under ML-KEM-768 and the
stated assumptions. It is not correct to claim that `mlk_poly_add` is proved
correct in every possible compilation, caller, architecture, aliasing pattern,
or future repository revision.

---

## 3. Production context

`mlk_poly_sub` is the destructive two-argument accumulator form used by
`mlkem-native`:

```c
void mlk_poly_sub(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;
  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] = (int16_t)(r->coeffs[i] - b->coeffs[i]);
  }
}
```

The production contract already requires distinct valid objects and requires
each mathematical difference to remain inside the signed 16-bit interval. It
ensures exact signed subtraction and assigns only the writable polynomial.
That local contract is the pre-existing SUB-T0 theorem.

In decryption, production code executes:

```c
mlk_poly_sub(v, sb);
mlk_poly_reduce(v);
mlk_poly_tomsg(m, v);
```

The case study therefore targeted the meaningful production composition
`sub -> reduce`, not merely the local subtraction statement.

---

## 4. Frozen constants and machine model

The independent harness family freezes:

```text
FIPS_N = 256
FIPS_Q = 3329
```

The CBMC machine-model assertions bind the proof to the recorded environment:

```text
short / int16_t width = 16 bits
int / int32_t width   = 32 bits
pointer width          = 64 bits
signed right shift     = arithmetic/sign-preserving
```

The production portable-C path was selected with native assembly disabled.
The proof does not claim compiler-to-machine-code equivalence or properties
of native assembly backends.

---

## 5. Principal assumptions

The semantic assumptions are deliberately narrow:

1. `r` and `b` are distinct valid polynomial objects.
2. Each polynomial contains 256 signed 16-bit coefficients.
3. For every coefficient `i`, the mathematical direct difference satisfies:

   ```text
   -32768 <= (int32_t)A[i] - (int32_t)B[i] <= 32767
   ```

4. The zero-valued namespaced optimization-blocker object used by the portable
   value-barrier implementation is modelled as volatile 64-bit zero.
5. The recorded x86-64 C machine model and arithmetic signed shift apply.
6. The verification target is the pinned commit and ML-KEM-768 configuration.

No assumption states the desired canonical result, forces the two relational
paths equal, or restricts the inputs to canonical residues. Arbitrary negative
and non-canonical `int16_t` representatives remain within the domain whenever
the direct difference is representable.

---

## 6. Independent theorem definitions

### 6.1 SUB-T1 — semantic composition anchor

For each coefficient:

```c
int32_t d = (int32_t)saved_a.coeffs[i]
          - (int32_t)saved_b.coeffs[i];
uint32_t shifted = (uint32_t)(d + 10 * 3329);
uint32_t expected = shifted % 3329u;
```

The production path is:

```c
L = saved_a;
LB = saved_b;
mlk_poly_sub(&L, &LB);
mlk_poly_reduce(&L);
```

The required conclusions are:

```text
0 <= L[i] < 3329
L[i] == expected
```

Frame assertions require the read-only operand and saved source objects to
remain unchanged. SUB-T1 is the semantic anchor because its oracle is separate
from the production reduction logic.

### 6.2 SUB-T2 — relational normalization compatibility

Left path:

```text
L=A; LB=B; sub(L,LB); reduce(L)
```

Right path:

```text
RA=A; RB=B; reduce(RA); reduce(RB); sub(RA,RB); reduce(RA)
```

Required relation:

```text
L[i] == RA[i]
0 <= L[i], RA[i] < 3329
```

Mathematically:

```text
N(A-B) = N(N(A)-N(B))
```

SUB-T2 is valuable because it checks representative independence and
compatibility between two production compositions. It is not sufficient by
itself: identical defects in both paths can preserve equality. SUB-T1 remains
mandatory.

---

## 7. Harness family

Six positive/control harnesses were frozen before theorem execution:

1. `sub_t1_semantic_harness.c`
2. `sub_t2_relational_harness.c`
3. `sub_cov_reachability_harness.c`
4. `sub_boundary_valid_extremes_harness.c`
5. `sub_boundary_invalid_lower_harness.c`
6. `sub_boundary_invalid_upper_harness.c`

The coverage harness records reachability of positive, negative, and zero
differences; positive and negative non-canonical inputs; exact `INT16_MIN` and
`INT16_MAX` differences; and unconditional reachability after the production
composition.

The boundary harnesses distinguish the contract-valid endpoints from the two
first invalid mathematical differences:

```text
valid lower:   -32768 - 0  = -32768 -> canonical 522
valid upper:    32767 - 0  =  32767 -> canonical 2806
invalid lower: -32768 - 1  = -32769
invalid upper:  32767 - -1 =  32768
```

---

## 8. Clean-room and distinctness controls

The theorem architecture and custom harness family were frozen before opening
the dedicated repository `poly_sub` harness. The architecture prohibited
copying, transforming, renaming, or using the repository harness as a template.
A previously exposed Makefile was disclosed, and the theorem statements were
recorded as pre-dating that exposure.

After the custom artefacts were frozen, the repository proof was inspected.
Its harness is only:

```c
#include "poly.h"
void harness(void)
{
  mlk_poly *r, *b;
  mlk_poly_sub(r, b);
}
```

Its Makefile checks the existing `mlk_poly_sub` function contract and applies
loop contracts. It does not call `mlk_poly_reduce`, define an independent
canonical oracle, compare two normalization paths, provide the thesis frame
relations, test reachability, or execute mutation controls.

Therefore the custom `poly_sub` artefacts are genuinely distinct from the
frozen repository's dedicated proof in architecture, property scope, and
execution mode. This does not mean that modular subtraction or the algebraic
identity are new mathematics.

---

## 9. Verification mode and CBMC configuration

Mode A retains the production bodies and does not abstract `mlk_poly_sub` or
`mlk_poly_reduce` with their contracts. Source loop contracts are not applied.
Relevant loops are explicitly unwound and checked with unwinding assertions.

The principal safety options are:

```text
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
--slice-formula
--sat-solver minisat2
--trace
--json-ui
```

The accepted SUB-T1 unwind set is:

```text
main.0:257
main.1:257
main.2:257
main.3:257
mlk_barrett_reduce.0:2
mlk_sub00g_r2_poly_sub.0:257
mlk_poly_reduce_c.0:257
mlk_poly_reduce_c.1:257
mlk_scalar_signed_to_unsigned_q.0:2
mlk_scalar_signed_to_unsigned_q.1:2
```

The planned SUB-T2 run contains eight 256-iteration harness loops plus the
same production-helper loops. The reviewed SUB-00L runner records the exact
T2 and boundary unwind sets.

---

## 10. Environment-model corrections

### 10.1 Initial T1 run invalidated

The first actual T1 execution reported six failures, including range and oracle
assertions. The result was not treated as a production counterexample. Audit
showed two missing environment details:

1. the zero-valued namespaced volatile optimization blocker was absent and
   therefore unconstrained in the model;
2. the source's intentional scoped conversion-check suppression was inactive.

Classification:

```text
INCOMPLETE ENVIRONMENT/BUILD MODEL
Theorem proved: no
Theorem falsified: no
```

### 10.2 Global `-DCBMC=1` correction rejected

A first attempted correction globally defined `CBMC`. That activated unrelated
SHAKE/FIPS202 contracts. GOTO validation aborted because contract expressions
referred to missing parameter symbols in the limited model. No theorem solver
run occurred.

### 10.3 Accepted scoped correction

The final solution included `cbmc.h` while `CBMC` was undefined, then defined
`CBMC` only while parsing `verify.h` to activate its narrow conversion pragma,
and immediately undefined it again. Function and loop contracts therefore
remained no-ops. A separate translation unit defined the namespaced blocker as
volatile 64-bit zero.

This corrected model validated, contained no `contract::` or unrelated SHAKE
symbols, retained the production call path, and exposed the expected loop set.

---

## 11. SUB-T1 result

The accepted body-level T1 run produced:

```text
Raw CBMC exit code:    0
CProver status:         success
Solver result:          UNSATISFIABLE
Properties reported:   361
Successful:            361
Failed:                0
Other:                 0
```

All twelve theorem/frame assertions and all eight machine-model assertions
reported success. The confirmed reachable T1 call chain contributed 89
properties: 20 explicit assertions, 21 array-bound checks, 24 overflow or
conversion checks, and 24 pointer checks. The other 272 properties belonged to
unrelated functions retained in the full `poly.c` GOTO model and are not
presented as extra T1 evidence.

The runtime was approximately 18 minutes 38 seconds with peak resident memory
about 1.78 GB.

A distributed runner path typo (`mlkem_poly_sub_cleanroom` versus
`mlk_poly_sub_cleanroom`) was corrected before execution. A line-by-line
comparison showed that path spelling was the only change; theorem, model,
flags, and result were unchanged. The correction is disclosed in the review.

---

## 12. Non-vacuity and coverage

The coverage run initially printed zero goals because the wrapper expected
theorem-mode JSON keys (`result`, `cProverStatus`). CBMC coverage mode instead
used `goals`, `goalsCovered`, `totalGoals`, and `tests`. Independent parsing of
the raw JSON found:

```text
8 of 8 covered (100.0%)
Generated test-suite witnesses: 3
```

The third witness covered all goals simultaneously. It contained complete
256-coefficient input arrays and included:

```text
index 61:  A=8326,   B=-24441, A-B=32767, reduced=2806
index 252: A=-32768, B=0,      A-B=-32768, reduced=522
```

This demonstrates that the assumptions are satisfiable, the production
composition is reachable, non-canonical scenarios occur, and the extreme
valid differences are reachable. Coverage is non-vacuity evidence, not a
replacement for the T1 correctness proof.

---

## 13. Mutation sensitivity

Three isolated, preregistered mutants were built and validated before solver
execution:

1. subtraction replaced by addition;
2. coefficient 255 skipped;
3. independent oracle shifted by one.

All three were killed by the intended central semantic assertion:

```text
MUTATION_BATCH_VERDICT=PASS_3_OF_3_KILLED
MUTATION_SENSITIVITY_PERCENT=100
```

M1 also produced a signed-conversion overflow failure because the deliberate
addition fault can exceed the original subtraction domain. The mutant still
counted only because the independent semantic assertion also failed.

M2 produced the exact intended location:

```text
A[255]              = 1
B[255]              = -9986
A[255]-B[255]       = 9987
Expected canonical  = 0
Actual final L[255] = 1
```

M3 kept production source unchanged and demonstrated that the equality
assertion was active rather than trivially satisfied.

The 100% score applies only to these three preregistered mutants; it is not a
claim of universal fault detection.

---

## 14. SUB-T2 and boundary status

The frozen SUB-T2 and boundary harnesses, their reviewed combined runner, and
the planned exact classification rules are included. Preserved terminal output records:

```text
SUB-T2:                  PASS
Valid boundary control:  PASS
Invalid lower control:   REJECTED AS EXPECTED
Invalid upper control:   REJECTED AS EXPECTED
```

The raw SUB-00L archive was intentionally not supplied for packet assembly.
Therefore this record does not state a raw property count, model hash, or trace
for these four cases. This is the only major evidence-completeness limitation
in the `poly_sub` packet.

---

## 15. Novelty and prior-art conclusion

The documented audit compared the artefacts against the frozen repository,
current public `mlkem-native` scope, indexed public code, Kyber/ML-KEM
formal-verification literature, Jasmin/EasyCrypt work, F*/hax work, HOL Light
assembly proofs, and other formal-reference projects.

No equivalent prior body-level CBMC artefact was identified for either:

1. production subtraction followed by unsigned-canonical reduction against an
   independent modular oracle; or
2. the relational property `N(A-B)=N(N(A)-N(B))`.

This is a qualified, date-stamped negative search result. It does not prove
global absence. Prior and broader functional-correctness proofs of Kyber and
ML-KEM exist in other implementations and proof systems.

Permitted wording:

> To the best of the documented repository, indexed public-code, and
> literature search conducted on 17 July 2026, no equivalent prior body-level
> CBMC proof was identified for the two stated `mlkem-native` C properties.
> The contribution is a newly authored and experimentally evaluated CBMC
> verification artefact and evidence campaign, not a new mathematical theorem
> or a world-first proof.

---

## 16. What was proved about `mlk_poly_add`

The PA-02 suite evaluated the real portable `mlk_poly_add` body without
modifying the production C. Separate external harnesses compiled the pinned
`poly.c` source. The original monolithic harness exhausted the initial VM
memory budget and produced no verdict. The obligation was decomposed into five
focused harnesses without reducing polynomial length, replacing symbolic
coefficients with samples, stubbing the target, omitting full unwinding, or
disabling the selected safety checks.

The record reports five of five successful sub-campaigns. Genuinely supported:

1. exact sum for every coefficient pair whose mathematical sum is representable
   as `int16_t`;
2. correct ring-`Z_q` refinement for signed and non-canonical representatives;
3. preservation of the read-only operand and local guards;
4. commutativity of two production executions under the valid domain;
5. additive identity for every signed `int16_t` polynomial without semantic
   input assumptions;
6. the enabled safety and complete-unwinding properties in each focused model.

The PA-02 record notes that complete terminal summaries were available for A, C, and
E, while B and D were represented by explicit successful verdicts rather than
their raw result directories in the retained evidence set. The campaign was not independently
reproduced on a second machine.

Therefore the honest answer to “was `mlk_poly_add` really proved?” is:

> Yes, the planned PA-02 property suite was proved for the pinned portable-C
> implementation under ML-KEM-768 and its stated assumptions. No, this is not
> an unrestricted proof of every possible use or the complete ML-KEM scheme.

The PA-02 custom suite is distinct from repository infrastructure because it
is an externally supplied, separately hashed harness family that directly
compiles the pinned production source. The PA-02 record does not claim a
complete textual-similarity or worldwide novelty audit.

---

## 17. Claims that are not supported

The evidence does not establish:

- correctness of the entire ML-KEM implementation;
- cryptographic IND-CCA security;
- constant-time or side-channel security;
- equivalence of all compiler-generated machine code;
- native/assembly correctness from these C proofs;
- behavior for aliasing calls excluded by the harness boundary;
- arithmetic results outside the representable direct-sum or difference
  domains;
- correctness at repository commits other than the pinned commit;
- a world-first or globally unique proof;
- new mathematics.

---

## 18. Failure handling and scientific trust

The campaign preserves failed and invalidated attempts rather than deleting
them:

- source/model construction failure from missing zeroize configuration;
- invalidated T1 run from incomplete environment modelling;
- preproof GOTO validator crash from globally activating unrelated contracts;
- corrected scoped preflight;
- coverage-wrapper JSON parser defect;
- runner path spelling correction.

Each failure changed the environment model or evidence-processing logic, not
the theorem after observing a counterexample. Frozen originals, replacement
versions, hashes, and reasons for change were retained.

---

## 19. Reproducibility chain

The packet contains:

- theorem preregistration and independent harness architecture;
- source identity and 341-entry source manifest;
- six frozen harnesses and frozen GOTO models;
- corrected adapters;
- exact runners and commands;
- unwind sets and property inventories;
- raw T1 JSON;
- raw coverage JSON and witnesses;
- mutation models, commands, JSON, and traces;
- failure archives and validator diagnostics;
- novelty audit and search log;
- all original source archives and extracted raw evidence;
- recursive packet SHA-256 manifest.

The raw SUB-00L execution archive is the explicit exception.

---

## 20. Major chain-of-custody hashes

| Artefact | SHA-256 |
|---|---|
| `SUB00A_PRODUCTION_INPUT_PACKET.txt` | `e557c98ff5d3e3735d9f9f59c67a030e87ea0f4898b92d120856321a74ba7f45` |
| `SUB00B_CORRECTED_THEOREM_EXPERIMENT_PREREGISTRATION.md` | `0a5c9f8faccd2b28b1ed3c85ca7a9fe1a66044518df2e05c35a86a28d4ed4e79` |
| `SUB00C_INDEPENDENT_HARNESS_ARCHITECTURE.md` | `a1d11264cf27038fed35ccddced2c6f79c5e28f42382e5000ce7fe7a44689d84` |
| `SUB00F_MODE_A_EXECUTION_FREEZE_PACKAGE.tar.gz` | `4836c959359967029a112dd12a3c380ee2e3141e2b0a1ff1a4537d3d8b7cb4e8` |
| `SUB00G_T1_MODE_A_MLKEM768_RUN1.tar.gz` | `b2967bdac006e81f0e2b7064fa4e60ee164c27d88d6e7443c801710c699e723d` |
| `SUB00G_R1_PREPROOF_VALIDATOR_CRASH_EVIDENCE.tar.gz` | `39af6a2a697be87b3b1d203092774d55d657b0290893c4e4cba17ccfa1367021` |
| `SUB00G_R2_T1_PRAGMA_SCOPED_PREFLIGHT_MLKEM768.tar.gz` | `210106eb8337b7cee98ec275d4398bf879c41b434789d441d83c01249a1abfbf` |
| `SUB00H_T1_PRAGMA_SCOPED_MODE_A_MLKEM768_RUN1.tar.gz` | `054ca49dc569642c4e1395b9f0027dca01da440a6b8653885a1d448ba0ca9a96` |
| `SUB00I_COVERAGE_NONVACUITY_PRAGMA_SCOPED_MLKEM768_RUN1.tar.gz` | `02dc578425a8851f532667717c3c080ea756f10f0ef859662a6e736b60bcaae5` |
| `SUB00J_MUTATION_PREFLIGHT_PRAGMA_SCOPED_MLKEM768.tar.gz` | `c4dc21bd092f45737470aa05bc2b4a99b475c53d8cc731f22fb389c2fc6b4ac6` |
| `SUB00K_COMBINED_MUTATION_EXECUTION_MLKEM768_RUN1.tar.gz` | `0566a7295baef9db6c8259b79d849008863376ad9c5ba4e86a80caa8da7884f8` |
| `POLY_SUB_FINAL_NOVELTY_PRIOR_ART_AUDIT_2026-07-17.md` | `f5db665cd6617a1e10d87491201ca5e202772efe2f3e20d11d83e7d4abf38da8` |
| `PA-02_mlk_poly_add_complete_verification_record.md` | `c467b744fe83cd6048ce38627b4757a3ae41f4c508a503c6cd4781ec11d6c081` |


---

## 21. Final professor-facing summary

The `mlk_poly_sub` case study developed an independent, body-level CBMC
verification campaign for production ML-KEM polynomial arithmetic. The local
repository contract was retained as a baseline, while a stronger semantic
composition theorem compared production subtraction followed by canonical
reduction against an independent modular oracle. The successful theorem was
supported by complete loop unwinding, machine-model and frame assertions,
100% reachability of eight preregistered coverage goals, valid signed-boundary
witnesses, and a three-mutant sensitivity experiment in which every intended
fault was rejected by the central semantic assertion. A separate relational
normalization theorem and boundary controls were frozen and recorded as
successful in preserved terminal output, although their raw SUB-00L archive was
intentionally omitted from this assembled packet. A documented prior-art audit found
substantial related verification of Kyber and ML-KEM but did not identify an
equivalent body-level CBMC artefact for the two exact frozen-C properties. The
contribution is therefore the independently authored verification artefact,
experimental controls, failure analysis, and reproducible provenance—not a
new algebraic identity or a world-first claim.

The separate `mlk_poly_add` PA-02 record reports five focused successful CBMC
proofs for exact signed addition, modular refinement, frame behavior,
commutativity, and additive identity. Those results establish the planned
property suite under its documented scope, not unrestricted correctness of the
whole implementation.

---

## 22. Recommended next thesis work

The `poly_sub` campaign should now be treated as closed except for later
addition of the omitted raw SUB-00L archive. The next case study should use a
different arithmetic structure—preferably Barrett reduction or Montgomery
reduction—rather than merely repeating near-identical addition/subtraction
properties. The same method should be retained: frozen source identity, prior
contract baseline, preregistered distinct property, body-level verification,
non-vacuity, negative controls, mutation sensitivity, and qualified novelty
audit.
