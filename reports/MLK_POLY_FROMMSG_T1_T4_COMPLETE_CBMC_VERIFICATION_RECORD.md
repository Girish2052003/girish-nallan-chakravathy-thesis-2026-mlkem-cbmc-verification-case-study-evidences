# `mlk_poly_frommsg` Clean-Room CBMC Verification Record

## Complete T1–T4 Campaign, Proof Meaning, Assumptions, Native-Proof Distinctness, Evidence, and Novelty Assessment

**Codex execution configuration:** CLI `0.144.4`; model `GPT 5.6 sol`; reasoning level `high`.

**Target implementation:** `mlkem-native` portable C  
**Primary target function:** `mlk_poly_frommsg`  
**Composed production function in T3:** `mlk_poly_tomsg`  
**Frozen repository commit:** `af4c5abdd5958bdc65a03cd5ee86708264f93304`  
**Parameter set:** ML-KEM-768 (`MLKEM_K=3`)  
**Verification tool:** CBMC 6.9.0  
**Authoritative source root:** `/home/girish/THESIS-2026/mlkem-native_af4c5abd`  
**Campaign root:** `/home/girish/THESIS-2026/mlk_poly_frommsg_cleanroom`  
**Workflow:** AI-assisted candidate artefact generation, deterministic execution and integrity checks, CBMC decision, documented acceptance controls, and SHA-256 evidence freezing  
**Record date:** 25 July 2026

---

# Executive conclusion

This record documents a clean-room, bounded C-level CBMC verification campaign for the real `mlk_poly_frommsg` implementation in `mlkem-native` at the frozen commit:

```text
af4c5abdd5958bdc65a03cd5ee86708264f93304
```

The campaign established the four theorem families fixed for the `mlk_poly_frommsg` study:

| Registry item | Purpose | Final status |
|---|---|---|
| FROMMSG-T1 | Exact binary embedding and coordinate semantics | Authoritative PASS |
| FROMMSG-T2 | Relational bit locality and Boolean preservation | Authoritative PASS |
| FROMMSG-T3 | Production codec inversion and codebook fixed point | Authoritative PASS |
| FROMMSG-T4 | Codebook support, weight, and metric preservation | Authoritative PASS according to the final decisive closure output |

The strongest defensible technical conclusion is:

> For the frozen ML-KEM-768 portable-C implementation at commit `af4c5abd`, under the recorded CBMC 6.9.0 model, flags, assumptions, and complete loop unwinding, `mlk_poly_frommsg` was proved functionally correct with respect to the registered exact message-to-polynomial specification. Every bit of every symbolic 32-byte message is mapped, in least-significant-bit-first order, to its corresponding polynomial coefficient as either `0` or `MLKEM_Q_HALF = 1665`. Separate relational, compositional, global-support, popcount, Hamming-distance, and scaled-distance properties were also proved. The positive proofs were strengthened by reachability checks, semantic mutation rejection, source binding, fresh-clone reruns, property and loop binding, parser validation, and cryptographic evidence manifests.

This is not a test over selected messages. The message arrays were symbolic. Subject to the stated assumptions, CBMC reasoned over every value in the finite 256-bit message domain and every relevant symbolic coordinate.

The result is nevertheless scoped. It is **not** a proof of:

- the complete ML-KEM cryptosystem;
- IND-CCA security;
- the ML-KEM decryption-failure probability;
- all functions in `mlkem-native`;
- every repository commit or parameter/backend configuration;
- compiler-generated binary equivalence;
- constant-time behaviour;
- microarchitectural, power, electromagnetic, or fault-injection resistance;
- global first-ever mathematical novelty.

The novelty conclusion is intentionally narrower:

> The underlying bit-embedding mathematics is elementary and is not new. Broader verified Kyber/ML-KEM implementations and specifications already exist and may logically entail equivalent encoding facts. A scoped public search conducted for this record did not identify an artefact matching the exact combination of the frozen `mlkem-native` C function at commit `af4c5abd`, CBMC verification of the T1–T4 unary, relational, compositional, support, weight, and metric registry, and the campaign’s clean-room, reachability, semantic-mutation, source-binding, parser-recovery, fresh-clone, and evidence-freezing controls. The defensible novelty position is therefore **repository-distinct and potentially novel as a CBMC case-study artefact and evidence methodology**, not first-ever mathematical or ML-KEM verification novelty.

---

# 1. Research purpose and verification boundary

The campaign was designed to answer a focused implementation-level question:

> Can the real frozen `mlk_poly_frommsg` C implementation be shown, using CBMC and independently constructed clean-room harnesses, to satisfy exact semantic properties that are stronger and more explicit than the broad native C safety and coefficient-bound proof?

The objective was not satisfied merely by obtaining `VERIFICATION SUCCESSFUL`. A green result can be misleading when:

- the intended function body is absent;
- a function is replaced by a contract;
- a loop is incompletely unwound;
- assumptions make the assertion unreachable;
- an assertion is tautological;
- the harness reproduces the target algorithm instead of checking it;
- the wrong source tree or commit is compiled;
- a parser misclassifies an incomplete or erroneous result;
- a mutation is too weak to be rejected;
- evidence files are changed after execution.

The proof process therefore combined semantic verification with deterministic evidence-integrity controls.

The campaign boundary was deliberately local:

```text
FIPS 203 / ML-KEM context
        +
one frozen mlkem-native portable-C implementation
        +
mlk_poly_frommsg
        +
mlk_poly_tomsg only where needed for T3
        +
CBMC 6.9.0
        +
selected exact C-level properties
```

No claim was made that this local proof substitutes for full scheme verification.

---

# 2. Target function and exact specification

## 2.1 Relevant constants

For the selected configuration:

```text
MLKEM_N                  = 256
MLKEM_INDCPA_MSGBYTES    = 32
MLKEM_Q                  = 3329
MLKEM_Q_HALF             = (MLKEM_Q + 1) / 2 = 1665
```

A 32-byte message has exactly 256 bits, matching the 256 polynomial coefficients.

## 2.2 Coordinate-bit definition

For message `m` and coefficient coordinate `k`:

\[
\operatorname{byte}(k)=\left\lfloor k/8\right\rfloor,
\qquad
\operatorname{offset}(k)=k\bmod 8.
\]

The selected bit is:

\[
\operatorname{bit}(m,k)
=
\left(
m[\operatorname{byte}(k)]
\gg \operatorname{offset}(k)
\right)\mathbin{\&}1.
\]

The ordering is least-significant-bit first inside each byte:

```text
coefficient 8*i + 0  <- bit 0 of message byte i
coefficient 8*i + 1  <- bit 1 of message byte i
...
coefficient 8*i + 7  <- bit 7 of message byte i
```

## 2.3 Exact functional specification

The intended codebook mapping is:

\[
\operatorname{frommsg}(m)[k]
=
\begin{cases}
1665, & \operatorname{bit}(m,k)=1,\\
0,    & \operatorname{bit}(m,k)=0.
\end{cases}
\]

Equivalently:

\[
\operatorname{frommsg}(m)[k]
=
1665\cdot \operatorname{bit}(m,k).
\]

This exact equation is the foundational T1 specification.

## 2.4 Production-loop map

The audited GOTO models identified:

```text
mlk_poly_frommsg.0 = inner j loop, 8 body iterations
mlk_poly_frommsg.1 = outer i loop, 32 body iterations
```

The proofs used termination-check unwind counts:

```text
mlk_poly_frommsg.0:9
mlk_poly_frommsg.1:33
```

T3 additionally bound the two `mlk_poly_tomsg` loops:

```text
mlk_poly_tomsg.0:9
mlk_poly_tomsg.1:33
```

T4 added one harness-side 32-iteration global counting loop, also using a termination-check bound of 33.

CBMC unwinding assertions were enabled. This matters because an assertion can appear to pass when CBMC has only explored a truncated loop. An unwinding assertion checks that the chosen bound is sufficient to force loop termination.

---

# 3. AI use, execution controls, and proof authority

The campaign used an AI-assisted workflow, but AI-generated explanations were not treated as proof authority.

| Component | Recorded function |
|---|---|
| Candidate-generation stage | Produced theorem registries, harnesses, shell scripts, parsers, mutations, and candidate interpretations |
| Shell and Python integrity checks | Bound commits, files, hashes, property IDs, loop IDs, counts, and result lineage |
| Git | Bound each campaign to the expected source commit and detected tracked source changes |
| CBMC 6.9.0 | Symbolically executed the GOTO model and decided verification conditions |
| Documented acceptance controls | Distinguished theorem failures from harness, tool, parser, or evidence failures |
| SHA-256 manifests | Froze accepted evidence artefacts after execution |

The methodological statement is:

> Candidate formal-verification artefacts were generated and refined before deterministic validation and CBMC execution. Acceptance depended on recorded integrity checks, result classification, and tool evidence; language-model explanations were not treated as proof results.

This distinction is central to the thesis contribution. The workflow evaluates the usefulness and risks of AI-assisted artefact generation without transferring proof authority to AI-generated text.

---

# 4. Native `mlkem-native` verification audit

## 4.1 Why the native audit was necessary

The repository already contains substantial formal-verification infrastructure. A new campaign could not be described as distinct without first determining:

- what the native harness calls;
- which source contracts are enforced;
- which helper functions are replaced by contracts;
- whether production loop contracts are applied;
- what semantic state the native loop invariants retain;
- whether the native harness already asserts the exact bit mapping;
- whether the proposed clean-room theorem is only a renamed native theorem.

## 4.2 Native verification scope

The upstream project publicly describes its C-level CBMC effort primarily as memory-safety and type-safety verification, built using function contracts and loop invariants. The repository separately describes functional-correctness and constant-time proofs for supported assembly through HOL Light.

The native C proof is therefore a strong and important verification effort, but its published top-level scope is not identical to this campaign’s exact `mlk_poly_frommsg` semantic registry.

## 4.3 Native `mlk_poly_frommsg` contract and loop invariants

At the audited frozen commit, the relevant native proof tracked broad output bounds. In simplified mathematical form, it established a condition such as:

\[
0 \le r.\mathrm{coeffs}[k] < 3329.
\]

The loop invariants retained processed-prefix bounds. They did not retain the exact input/output relation:

\[
r[k]=1665\cdot\operatorname{bit}(m,k).
\]

The difference is substantial:

```text
Native bound:
r[k] may be any integer in 0..3328.

Exact semantic theorem:
r[k] must be exactly 0 or 1665,
and that choice must equal one specific input bit.
```

The native harness did not add the T1–T4 assertions developed here.

## 4.4 Native instrumentation

The native campaign was observed to:

- enforce the broad `mlk_poly_frommsg` contract;
- replace `mlk_ct_sel_int16` with its contract;
- replace `mlk_value_barrier_u8` with its contract;
- apply the production loop contracts;
- introduce dynamic-frame contract infrastructure.

This was appropriate for the native proof purpose. It was not accepted as a direct proof of the clean-room exact semantic theorem because the retained loop invariants did not encode the bit-to-coefficient equation.

## 4.5 Native execution error

The native audit recorded:

```text
Declared properties:             419
Properties marked SUCCESS:       335
Properties marked FAILURE:         0
Properties marked ERROR:          84
Overall CPROVER status:          ERROR
```

The correct interpretation was:

```text
Native theorem disproved:             NO
84 implementation bugs established:  NO
Native execution accepted:            NO
Failure class:                        tool/solver/backend execution error
Exact backend root cause:             not recoverable from the capture
```

`FAILURE` and `ERROR` were not conflated:

```text
FAILURE = CBMC found a counterexample to a property.
ERROR   = CBMC did not complete a valid decision for that property.
```

The native result contained zero `FAILURE` records. The unresolved properties spanned unrelated categories, which was consistent with a global execution/backend problem rather than 84 independent defects in `mlk_poly_frommsg`.

The failed result was preserved. It was not silently converted into a proof or hidden from the evidence history.

---

# 5. Why the new harness family is genuinely distinct

## 5.1 No production-source modification

The campaign did not modify the tracked production implementation. Source state was checked before and after accepted runs.

## 5.2 Real production calls

The clean-room harnesses called:

```c
mlk_poly_frommsg(...)
```

and, for T3:

```c
mlk_poly_tomsg(...)
```

The target logic was not copied into a replacement function.

## 5.3 No target reimplementation

Static checks rejected candidate harnesses containing a new definition or macro replacement of the target function.

Specification-side calculations were permitted, for example:

- extracting a selected message bit;
- counting message popcount;
- counting nonzero coefficients;
- counting pairwise coefficient differences;
- summing absolute coefficient differences.

These calculations define the expected property. They do not replace the production function.

## 5.4 No contradictory assumption

The harnesses were checked for `assume(false)`-style contradictions.

Reachability companions then established that meaningful execution classes actually existed.

## 5.5 No target/helper contract substitution in semantic runs

The new semantic campaigns did not configure target or helper contract replacement as a substitute for executing the intended production bodies.

## 5.6 Native-harness non-identity

Where the native harness file was available, the new harness was checked as bytewise non-identical.

More importantly, the new harness was semantically distinct. Its assertions included:

- exact coordinate equations;
- relational one-bit locality;
- two-execution coefficient relations;
- real `frommsg`/`tomsg` composition;
- full-message popcount equality;
- pairwise Hamming-distance equality;
- scaled coefficient-space distance.

These were not boilerplate invocations of the native bound contract.

## 5.7 Repository-level distinctness conclusion

The campaign established:

```text
Exact semantic specification distinct from native broad bound:  YES
Native harness copied:                                         NO
Native theorem merely renamed:                                 NO
Production function body bypassed:                             NO
Production source modified:                                    NO
Repository-level campaign distinctness:                        PASS
```

This supports a repository-distinct claim. It does not by itself prove global research novelty.

---

# 6. Why exactly four theorem families were selected

The four-theorem registry was chosen as a deliberate coverage ladder:

```text
T1 — What does one execution compute?
T2 — How does the result change when the input changes?
T3 — Does the real production decoder invert the codeword?
T4 — What global support, weight, and metric structure is preserved?
```

The four levels represent four materially different verification perspectives:

| Verification view | Registry item | Main contribution |
|---|---|---|
| Unary and local | T1 | Complete coordinate-level extensional meaning |
| Relational | T2 | Exact sensitivity and locality across two executions |
| Compositional | T3 | Interaction of two real production functions |
| Global and aggregate | T4 | Whole-message support, weight, Hamming, and scaled-distance structure |

Four was selected to avoid both under-coverage and theorem inflation.

A fifth item built only by renaming a direct corollary would add little research value. Additional checks can still be retained as:

- subproperties;
- corollaries;
- mutations;
- reachability witnesses;
- implementation-safety properties;
- or a separate campaign for another function.

They should not automatically become a new theorem family.

---

# 7. FROMMSG-T1 — Exact binary embedding and coordinate semantics

## 7.1 Purpose

T1 established the exact extensional meaning of one execution of `mlk_poly_frommsg`.

The harness used:

- one symbolic 32-byte message;
- one symbolic coefficient coordinate `k`;
- the assumption `k < MLKEM_N`;
- one real production call;
- direct LSB-first extraction of the corresponding input bit.

## 7.2 Central theorem

For every possible 32-byte message `m` and every coordinate `k` in `[0,255]`:

\[
r[k]=1665\cdot\operatorname{bit}(m,k).
\]

Equivalent forms are:

\[
r[k]\in\{0,1665\},
\]

\[
r[k]=1665
\iff
\operatorname{bit}(m,k)=1,
\]

\[
r[k]=0
\iff
\operatorname{bit}(m,k)=0.
\]

## 7.3 Symbolic coverage

The proof did not fix one coordinate or enumerate selected messages.

Because `m` was symbolic and `k` was symbolic under only `k < 256`, the assertion quantified over the complete finite message and coordinate domains represented by the C model.

## 7.4 Result

The authoritative T1 closure recorded:

```text
Verification conditions:        67/67 SUCCESS
Reachability witnesses:          4/4 expected counterexamples
Semantic mutations:              4/4 expected counterexamples
Final status:                    CLOSED — AUTHORITATIVE PASS
```

Authoritative closure directory:

```text
/home/girish/THESIS-2026/mlk_poly_frommsg_cleanroom/
FROMMSG_T1_AUTHORITATIVE_CLOSURE/
RUN_20260724T144449Z_EXECUTION_RECOVERY
```

## 7.5 Meaning

T1 is the foundational functional-correctness theorem for the selected exact specification.

For the question:

> Does the frozen C function convert every message bit into the correct polynomial coefficient?

T1 answers yes within the recorded C-level model and assumptions.

## 7.6 Why T1 was not the entire campaign

T1 does not directly exercise:

- two related executions;
- exact one-bit locality;
- preservation of all unaffected coordinates;
- the real decoder;
- whole-message weight and distance calculations.

Those perspectives were added by T2–T4.

---

# 8. FROMMSG-T2 — Relational bit locality and Boolean preservation

## 8.1 Purpose

T2 moved from a unary theorem to a relational theorem over two production executions.

It checked whether flipping exactly one symbolic input bit:

- changes exactly the corresponding output coefficient;
- changes no other coefficient;
- produces the exact expected ordered coefficient pair.

## 8.2 Input relation

Two symbolic messages `m1` and `m2` were constrained to be equal except for one symbolic bit coordinate `k`, where the bit was flipped.

A separate symbolic coordinate `j` selected the output position to observe.

Two real production calls were executed:

```c
mlk_poly_frommsg(&r1, m1);
mlk_poly_frommsg(&r2, m2);
```

## 8.3 Central theorem

\[
r_1[j]\neq r_2[j]
\iff
j=k.
\]

This is exact locality.

## 8.4 Registered properties

### T2-P1 — Exact toggle pair

At the flipped coordinate:

\[
(r_1[k],r_2[k])
\in
\{(0,1665),(1665,0)\}.
\]

### T2-P2 — Constant sum

\[
r_1[k]+r_2[k]=1665.
\]

### T2-P3 — Difference exactly at the flipped coordinate

\[
r_1[j]\neq r_2[j]
\iff
j=k.
\]

### T2-P4 — Boolean-complement preservation

The output pair preserves the fact that the corresponding input bits are complements.

## 8.5 Result

The authoritative T2 closure recorded:

```text
Verification conditions:        79/79 SUCCESS
Named semantic properties:       4/4 SUCCESS
Reachability witnesses:          5/5 expected counterexamples
Semantic mutations:              4/4 expected counterexamples
Final status:                    CLOSED — AUTHORITATIVE PASS
```

Authoritative closure directory:

```text
/home/girish/THESIS-2026/mlk_poly_frommsg_cleanroom/
FROMMSG_T2_AUTHORITATIVE_CLOSURE/
RUN_20260724T150425Z
```

## 8.6 Why T2 was useful even though T1 implies it mathematically

T2 is a mathematical consequence of T1, but the separate CBMC campaign was still valuable.

It independently exercised:

- two message objects;
- two production calls;
- relational assumptions;
- a symbolic flipped coordinate;
- an independent symbolic observation coordinate;
- unchanged-frame behaviour for every unaffected output coefficient.

A harness can contain indexing, object-binding, or relational-assumption errors that a unary harness does not expose. T2 therefore strengthened engineering confidence and provided a distinct case-study artefact.

---

# 9. FROMMSG-T3 — Production codec inversion and codebook fixed point

## 9.1 Purpose

T3 introduced the real production decoder:

```text
mlk_poly_tomsg
```

The central question was:

> Does the real production decoder exactly recover every symbolic message after the real production encoder has produced its codeword?

## 9.2 Composition

The positive harness executed:

```c
mlk_poly_frommsg(&encoded1, input);
mlk_poly_tomsg(decoded, &encoded1);
mlk_poly_frommsg(&encoded2, decoded);
```

This gave both message round-trip and codebook fixed-point properties.

## 9.3 Central theorems

### Exact message round trip

For every symbolic 32-byte message `m`:

\[
\operatorname{tomsg}(\operatorname{frommsg}(m))=m.
\]

### Codebook fixed point

\[
\operatorname{frommsg}
\left(
\operatorname{tomsg}(\operatorname{frommsg}(m))
\right)
=
\operatorname{frommsg}(m).
\]

The second theorem is restricted to the codebook generated by `frommsg`. It is not a claim that an arbitrary polynomial survives `frommsg(tomsg(\cdot))`.

## 9.4 Registered properties

### T3-P1 — Exact selected-byte round trip

\[
decoded[byte\_index]=input[byte\_index].
\]

The selected byte index was symbolic.

### T3-P2 — Exact selected-bit round trip

The selected decoded LSB-first bit equals the matching selected input bit.

### T3-P3 — Codebook fixed point

For a symbolic coefficient coordinate:

\[
encoded2.coeffs[k]=encoded1.coeffs[k].
\]

### T3-P4 — Exact codebook decoding relation

The selected decoded bit is one exactly when the corresponding `encoded1` coefficient equals `MLKEM_Q_HALF`.

## 9.5 Composition and body binding

Before accepting the theorem, the GOTO model was checked for:

- one first `mlk_poly_frommsg` call;
- one `mlk_poly_tomsg` call;
- one second `mlk_poly_frommsg` call;
- both production function bodies;
- two `frommsg` loops;
- two `tomsg` loops;
- exact commit and clean source state.

Final accepted binding run:

```text
/home/girish/THESIS-2026/mlk_poly_frommsg_cleanroom/
FROMMSG_T3_CODEC_COMPOSITION_BINDING_FINAL_CLASSIFICATION/
RUN_20260724T152416Z
```

Binding artefacts included:

```text
Loop-list SHA-256:
e3efa1bce9fc0145c957a361ab3669315681014195c81028f03e9fee23832831

Binding capture SHA-256:
5e0755372a4d18a71283c930ea08455ba6649b276f529c903ce3da52b7532cd2

Binding summary SHA-256:
f2710a293ead9fc81e24ec6afffb0edd271e5142a473db1317a9a71cfbbbd6d0

Binding manifest SHA-256:
f6c8652e7e29a7fa8d9fde26c9742c3020232f6f75c071824c395294f6862beb
```

## 9.6 Positive preflight

The original positive run produced:

```text
CBMC exit:                   0
CPROVER status:              SUCCESS
Verification records:        140
SUCCESS records:             140
T3-P1:                       SUCCESS
T3-P2:                       SUCCESS
T3-P3:                       SUCCESS
T3-P4:                       SUCCESS
```

The original wrapper nevertheless contained a malformed shell counter, so its outer gate was not trusted.

The CBMC result itself was preserved. A recovery stage:

- verified the frozen hashes;
- regenerated the loop classification correctly;
- reparsed the frozen XML;
- confirmed 140/140 `SUCCESS`;
- did not rebuild or rerun CBMC;
- produced a trustworthy recovered gate.

Accepted positive recovery directory:

```text
/home/girish/THESIS-2026/mlk_poly_frommsg_cleanroom/
FROMMSG_T3_CODEC_INVERSION_PREFLIGHT_RECOVERY/
RUN_20260724T153142Z
```

Recovery evidence included:

```text
Recovery capture SHA-256:
6508a5f3405a9f0d74c1fe1742f015862302c52af59d64fc73ee5890bd27fbd8

Recovery summary SHA-256:
98aa20a60dfc2cfcf66601b7a5488436d4a3c005b1a5a3ad050b175c4b6fb23e

Recovery parser SHA-256:
7260862da2530341f451eef7fb0b5105443273dfef140d37fae45aa7d82c221d

Recovery manifest SHA-256:
c805eb7d556bee4b3b625261887491e09deb7aa87b4883196f2dad7de2c8dc25
```

## 9.7 T3 non-vacuity and mutations

Six reachability witnesses covered:

1. full composition execution;
2. selected input bit equal to zero;
3. selected input bit equal to one;
4. the final message bit;
5. the first coefficient;
6. the final coefficient.

Five deliberately false semantic mutations were rejected:

1. altered byte round trip;
2. wrong MSB-first bit interpretation;
3. shifted fixed-point coordinate;
4. wrong codebook amplitude;
5. false fixed point after corrupting the decoded message.

The integrated preflight result was:

```text
Positive recheck:             PASS
Reachability witnesses:       6/6
Rejected mutations:           5/5
T3 preflight integrity:       PASS
Source modified:              NO
```

## 9.8 Authoritative fresh-clone closure

Final accepted run:

```text
/home/girish/THESIS-2026/mlk_poly_frommsg_cleanroom/
FROMMSG_T3_AUTHORITATIVE_CLOSURE/
RUN_20260724T154928Z
```

The fresh clone:

- checked out the exact commit;
- copied frozen harnesses and Makefiles;
- rebuilt positive, reachability, and mutation GOTO binaries;
- rebound all production loops and named properties;
- reran the positive theorem;
- reran all six witnesses;
- reran all five mutations;
- confirmed unchanged tracked source;
- froze a final manifest.

Authoritative result:

```text
Positive CBMC exit:                 0
Positive CPROVER status:            SUCCESS
Positive verification records:      140
Positive SUCCESS records:           140
Positive named properties:          4/4 SUCCESS
Reachability witnesses:             6/6
Rejected semantic mutations:        5/5
Final classification:               PASS
```

Key T3 evidence:

```text
Verification-intent SHA-256:
a1cf39685de393a743c8efcc23de647b29268d7983b4a71c029f46f090112b91

Authoritative capture SHA-256:
74ac251cf670e07da070904b47d7a7c69eeb8227a464dd9ade99bb9acbf41957

Authoritative summary SHA-256:
85fd387e10620daf953dd8d3946fccd89cb47572255143985139ef4f92bc5a62

Authoritative positive XML SHA-256:
ee165deca335a5bfee9c941619e027349c29d1929b49441053a1b3fb5ebbc945

Authoritative manifest SHA-256:
f1123e13fedb4223bde0fb8d49fe209f0f634c1c09eafe5f7f7397a09aa748a8
```

## 9.9 What T3 proves and does not prove

T3 proves exact inversion on the `frommsg` codebook.

It does not prove:

- that `tomsg` is injective over arbitrary polynomials;
- that arbitrary non-codebook polynomials are fixed points;
- full encryption/decryption correctness;
- constant-time behaviour.

## 9.10 Why T3 did not make T4 unnecessary

T3 is compositional. It establishes that the production decoder recovers the message.

It does not directly establish:

- the number of nonzero codeword coefficients;
- equality between message popcount and codeword weight;
- pairwise Hamming-distance preservation;
- scaled coefficient-space distance;
- zero, maximum, and intermediate global-distance reachability.

A round trip can also fail to expose some jointly consistent representation errors if an encoder and decoder make compatible mistakes. T1 constrains the exact representation, while T4 adds whole-domain relational and aggregate checks.

---

# 10. FROMMSG-T4 — Codebook support, weight, and metric preservation

## 10.1 Purpose

T4 completed the preplanned registry by moving from local and compositional properties to global codebook geometry.

Two completely arbitrary symbolic messages were encoded by two real production calls.

One integrated positive harness, one build, one GOTO binary, and one CBMC execution covered all four T4 components. They were not split into separate theorem campaigns.

## 10.2 T4.1 — Coordinate support preservation

For an arbitrary symbolic coordinate `k`:

\[
r_1[k]\neq r_2[k]
\iff
\operatorname{bit}(m_1,k)\neq\operatorname{bit}(m_2,k).
\]

The assertion also checked the exact ordered coefficient pair against the two corresponding bits.

This generalized the single-bit T2 relation to two arbitrary messages.

## 10.3 T4.2 — Global codebook-weight preservation

Define:

\[
\operatorname{wt}(m)
=
\text{number of one bits in the 256-bit message},
\]

and:

\[
\operatorname{nzw}(r)
=
\text{number of nonzero coefficients in the polynomial}.
\]

T4 proved for both arbitrary symbolic messages:

\[
\operatorname{nzw}(\operatorname{frommsg}(m))
=
\operatorname{wt}(m).
\]

## 10.4 T4.3 — Global Hamming-metric preservation

Define message Hamming distance:

\[
d_H(m_1,m_2)
=
\#\{k:\operatorname{bit}(m_1,k)\neq\operatorname{bit}(m_2,k)\}.
\]

Define codeword support distance:

\[
d_C(r_1,r_2)
=
\#\{k:r_1[k]\neq r_2[k]\}.
\]

T4 proved:

\[
d_C(\operatorname{frommsg}(m_1),
    \operatorname{frommsg}(m_2))
=
d_H(m_1,m_2).
\]

## 10.5 T4.4 — Scaled absolute-distance preservation

The codeword coefficients are `0` or `1665`. Every differing coordinate therefore contributes an absolute difference of `1665`.

T4 proved:

\[
\sum_{k=0}^{255}
\left|
r_1[k]-r_2[k]
\right|
=
1665\cdot d_H(m_1,m_2).
\]

## 10.6 Positive preflight result

The decisive integrated positive output recorded:

```text
T3 authoritative lineage:                  PASS
Build and final GOTO:                      PASS
Named property binding count:              4
Production frommsg loops:                  2
Harness global counting loops:             1
CBMC exit:                                 0
CPROVER status:                            SUCCESS
T4-P1 coordinate support:                  SUCCESS
T4-P2 global weight:                       SUCCESS
T4-P3 global Hamming metric:               SUCCESS
T4-P4 global scaled distance:              SUCCESS
Positive classification:                   PASS
Source integrity:                          UNCHANGED
Capture exit:                              0
```

## 10.7 Integrated non-vacuity witnesses

One companion harness and one companion GOTO binary contained ten reachability properties:

1. full execution;
2. selected coordinate bit pair `00`;
3. selected coordinate bit pair `11`;
4. selected coordinate bit pair `01`;
5. selected coordinate bit pair `10`;
6. zero codebook weight;
7. maximum codebook weight;
8. zero Hamming distance;
9. one-bit Hamming distance;
10. maximum Hamming distance.

Each witness used a deliberately false assertion after the relevant assumptions. The expected counterexample showed that the corresponding state class was reachable.

## 10.8 Integrated semantic mutations

Six deliberately false alternatives were rejected:

1. inverted coordinate-support equivalence;
2. wrong codebook amplitude (`1664` instead of `1665`);
3. cross-message weight equality;
4. weight off by one;
5. Hamming distance off by one;
6. wrong scaled-distance factor.

The decisive integrity output recorded:

```text
Frozen positive capture hash check:       PASS
Frozen positive manifest check:           PASS
Frozen manifest self-hash check:           PASS
Positive XML recheck:                      PASS
Companion build:                           PASS
Companion property binding count:          16
Reachability witnesses:                    10/10
Rejected semantic mutations:                6/6
T4 preflight integrity:                    PASS
Source integrity:                          UNCHANGED
Capture exit:                              0
```

## 10.9 Authoritative fresh-clone closure

The final decisive closure output recorded:

```text
Accepted T4 preflight lineage:                PASS
Fresh clone and exact checkout:               PASS
Positive harness byte match:                  YES
Positive Makefile byte match:                 YES
Companion harness byte match:                 YES
Companion Makefile byte match:                YES
Positive build and GOTO:                      PASS
Companion build and GOTO:                     PASS
Positive property binding count:              4
Companion property binding count:             16
Positive CBMC exit:                           0
Positive CPROVER status:                      SUCCESS
T4-P1:                                       SUCCESS
T4-P2:                                       SUCCESS
T4-P3:                                       SUCCESS
T4-P4:                                       SUCCESS
Authoritative positive classification:        PASS
Reachability witnesses:                       10/10
Rejected semantic mutations:                   6/6
Final T4 classification:                      PASS
Fresh worktree source:                        UNCHANGED
Authoritative source:                         UNCHANGED
Capture exit:                                 0
```

## 10.10 Evidence-completeness note for T4

The exact final T4 authoritative capture path and SHA-256 were not included in the retained source material available when this record was generated.

The decisive closure lines establish the reported status, but the following values should be inserted from the retained local run before the public evidence package or thesis appendix is frozen:

```text
T4 authoritative run directory:      [INSERT FROM LOCAL RUN]
T4 authoritative capture SHA-256:    [INSERT]
T4 authoritative summary SHA-256:    [INSERT]
T4 verification-intent SHA-256:      [INSERT]
T4 authoritative manifest SHA-256:   [INSERT]
```

This is an evidence-packaging gap, not a reported theorem failure. It must not be silently replaced with invented values.

## 10.11 Why T4 was required after T3

Stopping at T3 would have left the campaign strong but incomplete relative to the preplanned four-view registry.

T4 added:

- arbitrary-pair generalization beyond T2’s exactly-one-bit relation;
- full 256-bit popcount preservation;
- full codeword nonzero-weight preservation;
- pairwise message/codeword Hamming isometry;
- scaled coefficient-space distance;
- explicit zero, one, and maximum distance reachability;
- global aggregation logic independent of the T3 decoder composition.

T4 also prevented the campaign from being characterized only as:

- one local equation;
- one single-bit perturbation;
- and one encoder/decoder round trip.

The final registry now covers local meaning, relational behaviour, composition, and global structure.

---

# 11. Are T2–T4 mathematically independent of T1?

No. The registry should not claim mathematical independence where it does not exist.

The exact T1 equation logically implies many later statements:

- T2 locality follows from applying T1 to two messages;
- T4 weight and distance statements follow by summing the T1 coordinate relation;
- part of T3 follows from T1 plus the exact semantics of `mlk_poly_tomsg`.

The separate CBMC campaigns remain justified because they are **verification artefact and implementation cross-checks**, not claims of four unrelated mathematical discoveries.

They exercise different:

- object counts;
- input relations;
- production-call compositions;
- property computations;
- loops;
- indexing expressions;
- output abstractions;
- reachability classes;
- mutation families.

The proper description is:

> T1–T4 form a layered assurance suite. T1 is the foundational exact semantic theorem. T2–T4 independently instantiate relational, compositional, and global consequences against the concrete production implementation and therefore provide additional implementation-level and artefact-level assurance.

---

# 12. Complete assumption register

## 12.1 Source and configuration assumptions

The accepted claim is bound to:

```text
Repository:      mlkem-native
Commit:          af4c5abdd5958bdc65a03cd5ee86708264f93304
Parameter set:   ML-KEM-768
Backend:         portable C path used by the proof build
Tool:            CBMC 6.9.0
```

The result is not automatically transferable to later commits or different backends.

## 12.2 Valid object assumptions

The harnesses supplied:

- valid message arrays of exactly 32 bytes;
- valid `mlk_poly` output objects;
- separately allocated stack objects;
- symbolic values in those objects where required.

The campaign did not attempt to prove behaviour for invalid pointers, undersized arrays, or intentionally overlapping message/output storage outside the actual harness model.

## 12.3 Coordinate assumptions

Symbolic indices were constrained to valid ranges, for example:

```c
__CPROVER_assume(k < MLKEM_N);
```

T3 additionally constrained selected byte, bit, and coefficient indices to their valid ranges.

These assumptions define the meaningful function domain. They are not contradictory assumptions.

## 12.4 T2 relational assumption

T2 assumed two messages were identical except for exactly one selected flipped bit.

The theorem therefore applies to that relation. T4 later removed the exactly-one-bit restriction by using two arbitrary messages.

## 12.5 T3 domain

T3’s inverse theorem begins with an arbitrary message, applies `frommsg`, and then applies `tomsg`.

The fixed-point theorem concerns polynomials in the image/codebook of `frommsg`.

No claim was made for arbitrary non-codebook polynomials.

## 12.6 T4 global computations

T4 used transparent specification-side helper calculations:

- explicit eight-term byte popcount;
- explicit nonzero-coefficient counting;
- explicit coefficient inequality counting;
- signed `int32_t` difference followed by absolute value;
- `uint32_t` aggregate counts and distances.

The maximum relevant values are small:

```text
maximum bit weight:                    256
maximum Hamming distance:              256
maximum scaled distance:               1665 * 256 = 426240
```

These are within `uint32_t`.

## 12.7 Loop completeness assumption

The proof depends on the recorded loop identities and bounds.

Unwinding assertions were enabled. Acceptance required the unwinding checks to succeed.

## 12.8 CBMC model assumption

The result is relative to CBMC’s C semantics, GOTO transformation, solver translation, built-in models, and implementation correctness.

Formal verification tools are not logically infallible. Tool soundness and modelling are part of the trust base.

## 12.9 Build-binding assumption

The evidence checks establish that the expected commit, harness, Makefile, and GOTO artefacts were used according to the recorded scripts and hashes.

The result assumes the operating system, filesystem, compiler/tool executables, and hash tool behaved correctly.

## 12.10 Absence of side-channel claim

The semantic C-level proof does not establish source-level or binary-level constant time.

This boundary is particularly important for `poly_frommsg`, which has a known history of compiler-introduced timing concerns in other implementations. The campaign’s semantic correctness result must not be presented as a timing-security proof.

---

# 13. Non-vacuity strategy

A positive assertion can pass because the path to the assertion is impossible.

The campaign used reachability companions to reduce this risk.

The pattern was:

```c
__CPROVER_assume(relevant_state_condition);
__CPROVER_assert(0, "REACHABILITY_WITNESS");
```

Expected result:

```text
CBMC exit:               10
Global CPROVER status:   FAILURE
Selected property:       FAILURE
Classification:          expected counterexample — PASS
```

The selected assertion’s failure is evidence that CBMC found a state satisfying the assumptions and reached the assertion.

Reachability was checked across:

- zero and one bits;
- first and final coordinates;
- full composition;
- all four selected bit-pair combinations;
- zero, one, and maximum Hamming distance;
- zero and maximum codeword weight.

This does not prove every line or branch is reachable, but it directly addresses the central semantic classes used by the theorem family.

---

# 14. Semantic mutation strategy

Mutation testing asked whether the proof framework would reject deliberately false specifications.

Examples included:

- wrong amplitude;
- wrong bit order;
- shifted coordinate;
- off-by-one weight;
- off-by-one Hamming distance;
- wrong scaled-distance factor;
- corrupted-message false fixed point;
- cross-message weight substitution.

A mutation was accepted as killed only when:

```text
CBMC exit:               10
Global CPROVER status:   FAILURE
Selected mutation:       FAILURE
Parser classification:   expected failure — PASS
```

The purpose was not to measure a conventional mutation score over production code. It was to establish that the harness, assumptions, source binding, and parser were capable of rejecting nearby false semantic claims.

---

# 15. Result-classification discipline

Every abnormal result was classified into one of five categories:

1. **Theorem failure**  
   CBMC produced a valid counterexample to the intended positive property.

2. **Harness or property-design failure**  
   The assertion, assumptions, property binding, or mutation was incorrectly designed.

3. **Build, tool, solver, or resource failure**  
   The proof did not complete because of compilation, unsupported options, backend errors, timeout, or resources.

4. **Parser or evidence-infrastructure failure**  
   The CBMC result may be valid, but the wrapper, counter, parser, or gate misclassified it.

5. **Source, hash, or evidence-binding failure**  
   The proof could not be tied to the intended source or frozen artefact.

No non-theorem failure was allowed to be described as an implementation counterexample.

---

# 16. Preserved failures and recoveries

The campaign retained its failed infrastructure attempts.

## 16.1 Native solver/backend error

The native 419-property run ended with 84 `ERROR` records and no `FAILURE` records.

Classification:

```text
Tool/backend execution error
Not an implementation counterexample
Not an accepted proof
```

## 16.2 T3 exact function-list grep false red

An initial anchored function-list check rejected valid binding evidence because the textual matching assumption was too strict.

Classification:

```text
Evidence-infrastructure false red
```

## 16.3 Unsupported `goto-instrument --list-functions`

CBMC 6.9.0 did not support the attempted interface, returning exit 64.

Classification:

```text
Tool-interface failure
```

## 16.4 T3 structural-recovery arithmetic typo

A shell arithmetic counter used malformed command substitution and could have produced a misleading gate.

Classification:

```text
Parser/evidence-infrastructure false green
```

The structural evidence was retained, but the classifier was rejected.

## 16.5 T3 positive wrapper counter failure

The original positive proof produced a valid:

```text
CBMC_EXIT=0
CPROVER_STATUS=SUCCESS
140/140 SUCCESS
```

but the wrapper used malformed arithmetic:

```bash
REQUIRED_LOOP_PASS_COUNT=$(
    (REQUIRED_LOOP_PASS_COUNT + 1)
)
```

The shell emitted `command not found` and an empty counter, but later printed a pass line.

Classification:

```text
CBMC semantic proof:                    valid
Outer wrapper/gate:                     invalid false green
Production theorem failure:             NO
```

A recovery stage revalidated the frozen hashes, regenerated the loop classification, and reparsed the XML without rerunning CBMC.

This incident is valuable evidence for the deterministic integrity firewall: proof-result parsers and shell gates can fail independently of CBMC.

---

# 17. Scope of the `mlk_poly_frommsg` proof

## 17.1 Correct answer

Yes, relative to the exact specification, source, configuration, assumptions, and CBMC model recorded in this campaign.

The strongest direct reason is T1:

\[
\forall m\in\{0,1\}^{256},
\forall k\in\{0,\ldots,255\},
\quad
\operatorname{frommsg}(m)[k]
=
1665\cdot\operatorname{bit}(m,k).
\]

This completely characterizes every coefficient produced by the function for every possible message in the fixed model.

T2, T3, and T4 then separately verified important consequences and interactions against the concrete production code.

## 17.2 Required wording

Use:

> Functional correctness of the frozen `mlk_poly_frommsg` C implementation was proved with respect to the registered exact message-to-polynomial specification under the stated CBMC model and assumptions.

Also acceptable:

> CBMC verified the complete T1–T4 semantic registry for `mlk_poly_frommsg` at the frozen ML-KEM-768 commit.

Avoid:

> All of `mlkem-native` was proved.

Avoid:

> ML-KEM was proved correct.

Avoid:

> The compiled implementation was proved constant-time.

Avoid:

> The function was mathematically proved for every possible platform and compiler.

## 17.3 Why the bounded result is still complete for the fixed function model

CBMC is a bounded model checker, but the relevant arrays and loops have fixed finite sizes.

Because:

- all 32 message bytes were symbolic;
- all valid coordinate choices were symbolic;
- the fixed loops were completely unwound;
- unwinding assertions succeeded;

the proof is exhaustive for the represented finite function executions, rather than a partial sample of the message space.

The word “bounded” remains necessary because the guarantee is tied to:

- this program;
- these fixed data sizes;
- these loop bounds;
- this C model;
- this configuration;
- this toolchain.

---

# 18. What exactly was proved across T1–T4?

## 18.1 Codebook membership

Every output coefficient is exactly:

```text
0 or 1665
```

## 18.2 Exact LSB-first coordinate mapping

Each coefficient corresponds to one exact input bit in LSB-first byte order.

## 18.3 Injectivity

T2/T4 support preservation implies:

\[
m_1\neq m_2
\Rightarrow
\operatorname{frommsg}(m_1)
\neq
\operatorname{frommsg}(m_2).
\]

## 18.4 One-bit locality

Flipping one message bit changes exactly one coefficient.

## 18.5 Production left inverse

\[
\operatorname{tomsg}(\operatorname{frommsg}(m))=m.
\]

## 18.6 Codebook fixed point

\[
\operatorname{frommsg}
(
\operatorname{tomsg}(\operatorname{frommsg}(m))
)
=
\operatorname{frommsg}(m).
\]

## 18.7 Weight preservation

\[
\operatorname{nzw}(\operatorname{frommsg}(m))
=
\operatorname{popcount}(m).
\]

## 18.8 Hamming isometry over support

\[
d_C(\operatorname{frommsg}(m_1),
    \operatorname{frommsg}(m_2))
=
d_H(m_1,m_2).
\]

## 18.9 Scaled \(L_1\) isometry

\[
\|
\operatorname{frommsg}(m_1)
-
\operatorname{frommsg}(m_2)
\|_1
=
1665\cdot d_H(m_1,m_2).
\]

These are implementation-level theorems for the frozen code, not new mathematical properties of binary embeddings.

---

# 19. Campaign registry

| Theorem | Core statement | Positive result | Non-vacuity | Mutations | Status |
|---|---|---:|---:|---:|---|
| T1 | Exact coordinate equation | 67/67 VCs | 4/4 | 4/4 | Closed |
| T2 | One-bit relational locality | 79/79 VCs; 4/4 named | 5/5 | 4/4 | Closed |
| T3 | Codec inversion and fixed point | 140/140 VCs; 4/4 named | 6/6 | 5/5 | Closed |
| T4 | Support, weight, Hamming, and scaled distance | 4/4 named positive properties; global success | 10/10 | 6/6 | Closed from decisive output |

Cumulative integrity controls included:

```text
Exact commit binding
Tracked-source cleanliness
Fresh-clone authoritative reruns
Real production bodies
No target reimplementation
No target/helper contract substitution
Named property binding
Production loop binding
Complete unwinding assertions
Reachability witnesses
Semantic mutation rejection
XML result parsing
Hash manifests
Preserved failed runs and recovery records
```

---

# 20. Novelty audit

## 20.1 Meaning of novelty in this record

Novelty has four different levels:

1. **Mathematical novelty**  
   Is the bit embedding or its Hamming consequences a new mathematical result?

2. **Global formal-verification novelty**  
   Is this the first formal proof of an ML-KEM implementation or equivalent encoding function anywhere?

3. **Repository-level novelty**  
   Is this a new theorem/harness/evidence campaign relative to the audited native repository?

4. **Methodological/case-study novelty**  
   Is the combination of AI-assisted artefact generation, deterministic integrity firewall, clean-room constraints, non-vacuity, mutation, fresh-clone, and evidence freezing a potentially new research artefact?

These levels must not be conflated.

## 20.2 Search date and scope

A scoped public search was conducted on 25 July 2026.

Search classes included:

```text
"mlk_poly_frommsg" verification
"mlk_poly_frommsg" CBMC
"poly_frommsg" CBMC Kyber
"MLKEM_Q_HALF" CBMC
frommsg Hamming distance ML-KEM formal verification
mlkem-native proofs/cbmc poly_frommsg
ML-KEM verified implementation EasyCrypt Jasmin
ML-KEM verified implementation F* hax
```

Sources reviewed included:

- the public `mlkem-native` repository and its formal-verification description;
- current public source/coverage views of `compress.c`;
- NIST FIPS 203;
- CRYPTO 2024’s machine-checked ML-KEM correctness/security artefact;
- the TCHES 2023 verified Kyber implementation work;
- IEEE Security & Privacy 2025’s high-performance verified ML-KEM work;
- the F*/hax verified `rust-libcrux`/ML-KEM project descriptions;
- general web and code-index searches for the exact function and theorem terminology.

A web search is not a proof that no unpublished, unindexed, differently named, or private proof exists.

## 20.3 Findings against mathematical novelty

The exact mapping:

\[
b\mapsto
\begin{cases}
0,&b=0,\\
(q+1)/2,&b=1
\end{cases}
\]

is part of the established Kyber/ML-KEM implementation design.

Weight, support, injectivity, and scaled Hamming consequences are elementary consequences of that mapping.

Therefore:

```text
First-ever mathematical theorem:  NOT CLAIMED
```

## 20.4 Findings against global ML-KEM verification novelty

Prior work already provides much broader verified results.

### Verified Kyber implementations

The 2023 TCHES work reports formally verified Jasmin implementations of Kyber, functionally correct with respect to an EasyCrypt specification.

### Verified ML-KEM correctness and security

The CRYPTO 2024 work reports machine-checked ML-KEM correctness and IND-CCA security in EasyCrypt and two verified Jasmin implementations that are functionally equivalent to the ML-KEM specification and constant-time.

### High-performance verified ML-KEM

The 2025 IEEE Security & Privacy work reports a formally verified high-performance ML-KEM implementation using EasyCrypt/Jasmin and equivalence reasoning.

### F*/hax implementations

The `rust-libcrux`/ML-KEM ecosystem reports verification for panic freedom, correctness, secret independence, serialization, arithmetic, and higher-level algorithms using hax and F*.

Consequently:

```text
First formally verified ML-KEM implementation:       NO
First formal proof that ML-KEM encoding works:       NOT ESTABLISHED
First proof from which equivalent facts may follow:  NO
```

## 20.5 Findings against the native repository

The public `mlkem-native` description states that its C CBMC campaign proves memory safety and type safety using contracts and loop invariants.

The audited `mlk_poly_frommsg` proof at the frozen commit retained broad coefficient bounds, not the exact T1–T4 semantic assertions.

No matching native harness or exact T1–T4 registry was identified.

Therefore:

```text
Distinct from audited native harness:      YES
Distinct from audited native theorem:      YES
New repository-level semantic campaign:    YES
```

## 20.6 Exact public-match search

The scoped search did not find a public result matching all of the following:

```text
Target:
  exact mlkem-native C function mlk_poly_frommsg

Source binding:
  commit af4c5abdd5958bdc65a03cd5ee86708264f93304

Tool:
  CBMC

Semantic registry:
  exact coordinate embedding
  relational one-bit locality
  production frommsg/tomsg inversion
  codebook fixed point
  global weight preservation
  Hamming-metric preservation
  scaled absolute-distance preservation

Evidence controls:
  clean-room non-copying
  target body retention
  no contract substitution
  complete unwinding
  property/loop binding
  non-vacuity witnesses
  semantic mutations
  parser-failure recovery
  fresh-clone closure
  SHA-256 evidence freezing
```

This supports a potential case-study novelty claim, not an absolute priority claim.

## 20.7 Novelty verdict

| Novelty category | Verdict |
|---|---|
| New mathematics | No |
| First verified Kyber/ML-KEM implementation | No |
| First globally existing proof of any equivalent encoding fact | Cannot be claimed |
| Distinct from native `mlkem-native` CBMC harness/contract at the frozen commit | Yes |
| New clean-room T1–T4 semantic artefact set for this repository/commit | Supported |
| Potentially novel CBMC case-study and evidence package | Plausible and defensible with cautious wording |
| Global first-ever exact campaign | Not established by search alone |

## 20.8 Professor-safe novelty claim

Recommended wording:

> The contribution is not a new mathematical encoding theorem and is not presented as the first formal verification of ML-KEM. Its novelty lies in constructing and evaluating a repository-distinct, clean-room CBMC semantic-verification campaign for the frozen `mlkem-native` `mlk_poly_frommsg` implementation. The campaign combines exact unary, relational, compositional, and global metric properties with deterministic source binding, non-vacuity, semantic mutation, fresh-clone reproduction, parser-recovery, and cryptographic evidence freezing. A scoped search found no public artefact matching this exact implementation, theorem registry, tool, and evidence methodology; therefore the contribution is described as potentially novel at the case-study and artefact level rather than globally first-ever.

Shorter version:

> Based on the scoped search, this work presents a repository-distinct and potentially novel CBMC case-study artefact for exact semantic verification of `mlk_poly_frommsg`; it does not claim new mathematics or the first formal verification of ML-KEM.

## 20.9 Claims that must not be used

Do not state:

> This is the first proof of `poly_frommsg` in the world.

Do not state:

> No one has ever proved these properties.

Do not state:

> This work proved more than the EasyCrypt/Jasmin ML-KEM verification.

Do not state:

> The T1–T4 mathematical results are novel.

Do not state:

> Search results prove nonexistence.

---

# 21. Threats to validity

## 21.1 Internal validity

Potential internal threats include:

- errors in harness assertions;
- errors in specification-side helper calculations;
- incorrect property-ID matching;
- incorrect loop-ID matching;
- wrapper/parser bugs;
- accidental use of the wrong worktree;
- incomplete evidence copying.

Controls included named bindings, exact hashes, mutations, recoveries, and fresh clones.

## 21.2 Construct validity

The selected properties operationalize one aspect of correctness: message-to-codeword semantics.

They do not operationalize all security or correctness concerns of ML-KEM.

## 21.3 External validity

The result is specific to:

- one repository;
- one commit;
- ML-KEM-768;
- the portable-C proof path;
- one CBMC version and environment.

Generalization to other functions, commits, parameter sets, and implementations requires new evidence.

## 21.4 Tool validity

CBMC, `goto-cc`, `goto-instrument`, the solver, compiler frontend, and built-in models are part of the trusted computing base.

The campaign did not verify CBMC itself.

## 21.5 Novelty-search validity

Search limitations include:

- unpublished work;
- differently named theorems;
- private repositories;
- unindexed code;
- proof consequences not exposed as standalone theorem names;
- new publications appearing after the search date.

The novelty statement is therefore scoped and dated.

## 21.6 AI-related validity

The AI could propose:

- incorrect assumptions;
- vacuous assertions;
- unsupported claims;
- brittle shell scripts;
- wrong parser logic.

The recorded T3 false-green wrapper incidents demonstrate that this risk is real.

The deterministic firewall and documented acceptance controls are therefore necessary parts of the research design.

---

# 22. Reproducibility and evidence checklist

A final public evidence package should include, for each theorem family:

```text
verification intent
source commit record
source hash manifest
harness source
Makefile/build configuration
GOTO binary
property-binding output
loop-binding output
CBMC command and flags
positive result XML/JSON
stderr capture
reachability harness and results
mutation harness and results
parser source
terminal capture
summary
SHA-256 manifest
manifest self-hash
documented acceptance note
```

Campaign-wide package additions:

```text
T1–T4 theorem registry
native-audit report
failure and recovery register
claim-boundary statement
novelty-search protocol and date
README describing proof meaning
CITATION.cff
environment/tool versions
```

Before repository publication, insert the missing T4 final evidence identifiers noted in Section 10.10.

---

# 23. Final theorem registry

```text
FROMMSG-T1
Exact binary embedding and coordinate semantics
STATUS: CLOSED — AUTHORITATIVE PASS

FROMMSG-T2
Relational bit locality and Boolean preservation
STATUS: CLOSED — AUTHORITATIVE PASS

FROMMSG-T3
Production codec inversion and codebook fixed point
STATUS: CLOSED — AUTHORITATIVE PASS

FROMMSG-T4
Codebook support, weight, and metric preservation
STATUS: CLOSED — AUTHORITATIVE PASS FROM FINAL DECISIVE OUTPUT
FINAL CAPTURE HASH: TO BE INSERTED FROM LOCAL EVIDENCE
```

The four-theorem registry is complete.

No T5 is required merely to restate a corollary.

The next campaign activity is administrative:

```text
FROMMSG-FINAL
Campaign registry closure
Cross-theorem evidence binding
Failure-history inclusion
Final SHA-256 package freeze
Professor/thesis summary extraction
```

---

# 24. Final claim statement

The final claim adopted for the thesis and evidence repository is:

> A clean-room CBMC verification campaign was constructed and executed for `mlk_poly_frommsg` in the frozen ML-KEM-768 portable-C implementation of `mlkem-native` at commit `af4c5abd`. The campaign proved exact LSB-first binary embedding, relational one-bit locality, production `frommsg`/`tomsg` inversion on the generated codebook, codebook fixed-point behaviour, global nonzero-weight preservation, pairwise Hamming-metric preservation, and scaled coefficient-distance preservation. The proofs used symbolic messages, complete loop unwinding with unwinding assertions, real production bodies, deterministic source and property binding, explicit reachability witnesses, semantic mutation rejection, fresh-clone reruns, and cryptographically frozen evidence. The result is a bounded C-level functional-correctness result for the registered theorem family, not a proof of the complete ML-KEM system or a claim of new mathematics. The artefact is demonstrably distinct from the audited native repository harness and is presented as a potentially novel CBMC case-study and evidence-methodology contribution, subject to the stated scoped-search limitation.

---

# 25. Reference and novelty-audit sources

## Standards and target repository

1. National Institute of Standards and Technology (2024), **FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard**. DOI: `10.6028/NIST.FIPS.203`.  
   https://csrc.nist.gov/pubs/fips/203/final

2. PQ Code Package, **mlkem-native: Secure, fast, and portable C90 implementation of ML-KEM / FIPS 203**.  
   https://github.com/pq-code-package/mlkem-native

3. `mlkem-native` public source/coverage view showing `mlk_poly_frommsg` and processed-prefix range invariants in `compress.c`.  
   https://storage.googleapis.com/oss-fuzz-coverage/liboqs/reports-by-target/20260513/fuzz_test_kem/linux/src/liboqs/src/kem/ml_kem/mlkem-native_ml-kem-1024_x86_64/mlkem/src/compress.c.html

## CBMC documentation

4. CBMC documentation, **CBMC is a bounded model checker for C**.  
   https://diffblue.github.io/cbmc/

5. CBMC training documentation, **What is loop unwinding?**  
   https://model-checking.github.io/cbmc-training/faq/loop-unwinding.html

6. CBMC training documentation, **Property checking**.  
   https://model-checking.github.io/cbmc-training/cbmc/overview/checking-properties.html

## Broader verified Kyber and ML-KEM work

7. Almeida, J.B. et al. (2023), **Formally Verifying Kyber Episode IV: Implementation Correctness**, *IACR Transactions on Cryptographic Hardware and Embedded Systems*, 2023(3), pp. 164–193. DOI: `10.46586/tches.v2023.i3.164-193`.

8. Almeida, J.B. et al. (2024), **Formally Verifying Kyber Episode V: Machine-Checked IND-CCA Security and Correctness of ML-KEM in EasyCrypt**, *Advances in Cryptology – CRYPTO 2024*. DOI: `10.1007/978-3-031-68379-4_12`.  
   Artifact: https://artifacts.iacr.org/crypto/2024/a3/

9. Almeida, J.B. et al. (2025), **Faster Verification of Faster Implementations: Combining Deductive and Circuit-Based Reasoning in EasyCrypt**, *2025 IEEE Symposium on Security and Privacy*, pp. 3820–3838. DOI: `10.1109/SP61157.2025.00214`.

10. PQ Code Package, **rust-libcrux**, describing ML-KEM verification using hax and F*.  
    https://github.com/pq-code-package/rust-libcrux

## Timing-security boundary

11. Purnal, A. (2024), **Compiler-introduced timing leak in Kyber reference implementation**, NIST PQC Forum.  
    https://groups.google.com/a/list.nist.gov/g/pqc-forum/c/hqbtIGFKIpU/m/s1tyRWbtBAAJ

The timing-leak source is included only to reinforce that semantic functional correctness and constant-time security are separate claims.

---

# Appendix A — Concise professor-facing answer

## Did the campaign prove `mlk_poly_frommsg`?

Yes, with the following precise scope:

```text
Function:
  mlk_poly_frommsg

Implementation:
  mlkem-native portable C

Commit:
  af4c5abdd5958bdc65a03cd5ee86708264f93304

Configuration:
  ML-KEM-768

Tool:
  CBMC 6.9.0

Specification:
  exact LSB-first mapping of every message bit to coefficient 0 or 1665

Additional verified views:
  one-bit locality
  production codec inversion
  codebook fixed point
  global weight preservation
  Hamming isometry
  scaled absolute-distance preservation
```

The proof does not extend automatically beyond this boundary.

## Is it novel?

```text
New mathematics:                          No
First formal ML-KEM verification:         No
Distinct from native repository theorem:  Yes
Distinct clean-room CBMC harness family:  Yes
Potentially novel case-study artefact:     Yes, with cautious wording
Global first-ever exact priority:          Not established
```

## Why four?

```text
T1 = exact unary meaning
T2 = relational sensitivity/locality
T3 = production composition/inversion
T4 = global codebook geometry
```

Together they provide a balanced assurance ladder without manufacturing a fifth theorem from a direct corollary.

---

# Appendix B — Evidence items explicitly known in this record

## T1

```text
Closure:
FROMMSG_T1_AUTHORITATIVE_CLOSURE/
RUN_20260724T144449Z_EXECUTION_RECOVERY

67/67 verification conditions successful
4/4 reachability witnesses
4/4 semantic mutations
```

## T2

```text
Closure:
FROMMSG_T2_AUTHORITATIVE_CLOSURE/
RUN_20260724T150425Z

79/79 verification conditions successful
4/4 named semantic properties
5/5 reachability witnesses
4/4 semantic mutations
```

## T3

```text
Closure:
FROMMSG_T3_AUTHORITATIVE_CLOSURE/
RUN_20260724T154928Z

140/140 verification records successful
4/4 named semantic properties
6/6 reachability witnesses
5/5 semantic mutations

Capture:
74ac251cf670e07da070904b47d7a7c69eeb8227a464dd9ade99bb9acbf41957

Summary:
85fd387e10620daf953dd8d3946fccd89cb47572255143985139ef4f92bc5a62

Intent:
a1cf39685de393a743c8efcc23de647b29268d7983b4a71c029f46f090112b91

Positive XML:
ee165deca335a5bfee9c941619e027349c29d1929b49441053a1b3fb5ebbc945

Manifest:
f1123e13fedb4223bde0fb8d49fe209f0f634c1c09eafe5f7f7397a09aa748a8
```

## T4

```text
4/4 positive semantic properties successful
10/10 reachability witnesses
6/6 semantic mutations rejected
fresh-clone closure passed
source unchanged
capture exit 0

Exact final run path and hashes:
to be inserted from retained local evidence
```

---

# Appendix C — Interpretation of PASS

A theorem-family PASS means:

```text
Expected source commit bound
Expected harness and build configuration used
Expected function body present
Expected named property present
Expected loops identified
Required unwinding assertions successful
Positive property had no CBMC counterexample
Global result status successful
Reachability companions produced expected witnesses
False semantic mutations produced counterexamples
Tracked production source remained unchanged
Accepted evidence was frozen
```

It does not mean:

```text
all possible unstated properties are true
all toolchain components are formally verified
all ML-KEM security properties are proved
the result applies to all future code
the proof is globally mathematically novel
```
