# Complete Rendered Property, Control, Diagnostic and Candidate Catalogue

**Repository evidence layer for the complete V5 property/control corpus**

This catalogue is the exhaustive human-readable companion to `02_COMPLETE_PROPERTY_LEDGER.csv`. The ledger remains authoritative for record identity, classification, domain, evidence mapping and bounded conclusion; this catalogue makes the mathematics, semantic role, principal-claim relationship, native-baseline relationship and thesis projection readable without changing those classifications.

The thesis appendices are deliberately a **compact projection** of this evidence layer. Appendix 1 enumerates the formally supported subset; Appendix 2 preserves the exceptional negative, inconclusive and preservation-limited findings. Controls, documented guarantees, construction invariants and diagnostics remain in the repository even where the appendices omit them for compactness. A difference in depth is therefore intentional; a difference in scientific meaning is not.

The complete ledger contains **257 substantive records**. Of these, **220** are formally supported property/obligation records (`SUPPORTED` or `SUPPORTED_WITH_PARTIAL_PRESERVATION`). The remaining 37 records have different evidential roles and remain explicitly classified rather than being converted into supported claims.

## Evidence interpretation rule

A record classified `SUPPORTED` means that the encoded property received the retained formal-tool support under its pinned production source, harness, assumptions and recorded analysis configuration, with the accompanying reachability/feasibility/non-vacuity fields used to interpret that result. It does **not** mean unrestricted correctness of the function, complete ML-KEM correctness, cryptographic security, or a machine-checked proof of the prose in this document.

A control, documented guarantee or construction invariant can strengthen the interpretation of a supported property without becoming another supported target theorem. A meaningful negative establishes a boundary by contradicting its candidate proposition. An abstraction-limited or resource-limited candidate remains unresolved. Evidence preservation status is reported independently of the logical status of the proposition.

## Authority order

When two retained sources disagree, this catalogue follows the repository evidence policy: source/build identity and manifests; exact generated artefact; exact executed command and raw formal-tool output; reachability/non-vacuity/mutation evidence; contemporaneous run record; later summary or interpretation. A checksum establishes file identity, not scientific validity.

## Publication-state and row-level path-status reconciliation

The frozen RC2 source ledger originally carried `resolved_public_evidence_path = UNRESOLVED_UNTIL_FINALIZER`, blank `public_evidence_sha256`, and `public_path_resolution_status = PENDING` for the substantive records. Those values were historical pre-finalization metadata, not statements that the repository itself is unpublished.

In the installed evidence suite, the live repository finalizer resolves the authoritative row-level public paths and verifies their SHA-256 identities against the archived evidence entries. The complete traceability blocks are then synchronized to those finalized ledger values. Historical pre-finalization values remain documented in the retained closure/audit reports rather than being misreported as current state. Blank public-file hashes are never inferred or reconstructed; a public hash is populated only from an actual finalizer hash match. Installed-state resolution counts are recorded in `03A_POST_INSTALL_PATH_RESOLUTION.md`.

## Relationship to Chapter 4 and the appendices

Chapter 4 reports one principal bounded claim per unassisted case so that the results chapter remains readable. `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv` records the intended compression action: retain one principal claim/domain/outcome in Chapter 4 while subordinate properties remain in the repository/appendix. The principal claim is therefore a **case-level synthesis**, not a claim that one selected property is more “proved” than every other supported property.

The thesis methodology uses **primary**, **formally supported**, and **principal** in different senses. A primary property is the focal candidate selected within an investigation. Formal support is the evidential status assigned to a bounded relation or obligation after its mapped formal-tool evidence and acceptance criteria are evaluated. A principal case-level claim is applied only after run closure and scientific evaluation as a compact Chapter-4 reporting designation for an accepted result or selected set of accepted results. The principal designation does not alter row classifications, suppress supported/contrary/unresolved findings, create a separate theorem class, or imply mathematical novelty or authorship.


The selection rule used in this catalogue is:

1. identify the semantic or compositional relation that best represents the target verification question;
2. retain its exact domain and representation boundary;
3. treat range, frame, locality, algebraic, caller and sequential properties as support or strengthening unless they are themselves the semantic centre of the case;
4. treat reachability, admissibility, oracle, configuration and construction records as evidential controls rather than theorem counts;
5. preserve meaningful negatives and inconclusive candidates as boundaries on the principal claim; and
6. choose no wording stronger than the surviving evidence permits.

This rule is consistent with the principal statements in `03_FORMAL_CLAIM_CATALOGUE.md`, the principal-case rows in `09_MASTER_PROVENANCE_MATRIX.csv`, and the compression mapping in `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv`.

## Common notation

$$
q=3329,\qquad n=256,\qquad 0\le i<n.
$$

For an integer $x$,

$$
\operatorname{canon}_q(x)\in\{0,\ldots,q-1\},\qquad \operatorname{canon}_q(x)\equiv x\pmod q.
$$

`before`/`after`, `initial`/`mid`/`final`, and superscripts `(1)`/`(2)` denote the registered pre/post states, sequential states, or paired executions for the local case. Every symbol remains case-specific.

## Source correction register

One evidence-verified transcription correction is required before repository installation: the pre-installation public `main` ledger audited on 16 August 2026 carried `PR-C04-013` with the Case-4 production offset written as `2^25`, while the retained MSG-T5 evidence records `1073741824 = 2^30`. The exact Case-4 admissible interval contains $2^{30}$, not $2^{25}$. The supplied `PR-C04-013_LEDGER_CORRECTION.patch` updates the CSV and Markdown ledger twins, and the Case-4 traceability block in this catalogue already uses the corrected relation. Case 8 independently and correctly uses $2^{25}=33554432$ for its Barrett offset.

## Catalogue structure

The master file gives the cross-case synthesis and principal-claim mapping. Every record is then documented in a dedicated renderable case file under `03A_RENDERED_CATALOGUE_CASES/`. The split is purely presentational: the manifest and validation report check that the union of the 18 case files contains the exact 257-record ledger set once and only once.


## Result-class inventory

| Classification | Records | Interpretation |
|---|---:|---|
| `SUPPORTED` | 215 | Formal-tool support for the bounded property/obligation. |
| `RESOURCE_LIMITED_INCONCLUSIVE` | 16 | No completed verdict within the retained resource boundary. |
| `SUPPORTING_CONTROL` | 7 | Configuration, admissibility, oracle or construction control. |
| `SUPPORTED_DIAGNOSTIC` | 6 | Supported diagnostic relation whose domain must not be promoted to the ordinary production contract. |
| `SUPPORTED_WITH_PARTIAL_PRESERVATION` | 5 | Supported result with an explicit surviving-evidence preservation limitation. |
| `ASSUMED_FROM_DOCUMENTED_GUARANTEE` | 4 | Documented producer/caller guarantee used as a premise. |
| `MEANINGFUL_NEGATIVE` | 2 | Candidate contradicted within its registered domain/model. |
| `SUPPORTED_BY_CONSTRUCTION` | 1 | Invariant fixed by the registered harness construction. |
| `ABSTRACTION_LIMITED_INCONCLUSIVE` | 1 | No production-level acceptance/refutation because the encoded abstraction is insufficient. |

## Case index

| Case | Target | Locator | Ledger records | Supported subset | Chapter 4 | Detail file |
|---|---|---|---:|---:|---|---|
| Case 1 — Polynomial Addition | `mlk_poly_add` | `LOC-C01-UA` | 51 | 36 | §4.3.1 | [`CASE_01_POLYNOMIAL_ADDITION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_01_POLYNOMIAL_ADDITION.md) |
| Case 2 — Polynomial Subtraction | `mlk_poly_sub` | `LOC-C02-UA` | 24 | 24 | §4.3.2 | [`CASE_02_POLYNOMIAL_SUBTRACTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_02_POLYNOMIAL_SUBTRACTION.md) |
| Case 3 — Sequential Subtraction and Reduction | `mlk_poly_sub → mlk_poly_reduce` | `LOC-C03-UA` | 3 | 1 | §4.3.3 | [`CASE_03_SEQUENTIAL_SUBTRACTION_REDUCTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_03_SEQUENTIAL_SUBTRACTION_REDUCTION.md) |
| Case 4 — Message Extraction | `mlk_poly_tomsg` | `LOC-C04-UA` | 13 | 13 | §4.4.1 | [`CASE_04_MESSAGE_EXTRACTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_04_MESSAGE_EXTRACTION.md) |
| Case 5 — Message Embedding | `mlk_poly_frommsg` | `LOC-C05-UA` | 13 | 13 | §4.4.2 | [`CASE_05_MESSAGE_EMBEDDING.md`](03A_RENDERED_CATALOGUE_CASES/CASE_05_MESSAGE_EMBEDDING.md) |
| Case 6 — D4 Compression and Decompression | `D4 portable-C compressor/decompressor` | `LOC-C06-UA` | 18 | 18 | §4.4.3 | [`CASE_06_D4_COMPRESSION_DECOMPRESSION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_06_D4_COMPRESSION_DECOMPRESSION.md) |
| Case 7 — Signed-to-Canonical Conversion | `mlk_scalar_signed_to_unsigned_q` | `LOC-C07-UA` | 17 | 17 | §4.4.4 | [`CASE_07_SIGNED_TO_CANONICAL.md`](03A_RENDERED_CATALOGUE_CASES/CASE_07_SIGNED_TO_CANONICAL.md) |
| Case 8 — Barrett Reduction | `mlk_barrett_reduce` | `LOC-C08-UA` | 23 | 23 | §4.4.5 | [`CASE_08_BARRETT_REDUCTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_08_BARRETT_REDUCTION.md) |
| Case 9 — Zeroisation | `mlk_zeroize` | `LOC-C09-UA` | 16 | 16 | §4.5.1 | [`CASE_09_ZEROISATION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_09_ZEROISATION.md) |
| Case 10 — Polynomial Serialisation | `mlk_poly_tobytes` | `LOC-C10-UA` | 19 | 19 | §4.5.2 | [`CASE_10_POLYNOMIAL_SERIALISATION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_10_POLYNOMIAL_SERIALISATION.md) |
| Case 11 — Polynomial Deserialisation | `mlk_poly_frombytes` | `LOC-C11-UA` | 11 | 11 | §4.5.3 | [`CASE_11_POLYNOMIAL_DESERIALISATION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_11_POLYNOMIAL_DESERIALISATION.md) |
| Case 12 — Direct Codec Composition | `mlk_poly_tobytes ↔ mlk_poly_frombytes` | `LOC-C12-UA` | 2 | 2 | §4.5.4 | [`CASE_12_DIRECT_CODEC_COMPOSITION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_12_DIRECT_CODEC_COMPOSITION.md) |
| Case 13 — Public-Key Validation | `mlk_kem_check_pk` | `LOC-C13-UA` | 16 | 12 | §4.5.5 | [`CASE_13_PUBLIC_KEY_VALIDATION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_13_PUBLIC_KEY_VALIDATION.md) |
| Case 14 — Montgomery Reduction | `mlk_montgomery_reduce; candidate mlk_fqmul / mlk_poly_tomont_c extensions` | `LOC-C14-UA` | 21 | 5 | §4.5.6 | [`CASE_14_MONTGOMERY_REDUCTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_14_MONTGOMERY_REDUCTION.md) |
| Skill-Available Addition | `mlk_poly_add` | `LOC-SA-ADD` | 3 | 3 | §4.6 | [`SKILL_AVAILABLE_ADDITION.md`](03A_RENDERED_CATALOGUE_CASES/SKILL_AVAILABLE_ADDITION.md) |
| Skill-Available Subtraction | `mlk_poly_sub` | `LOC-SA-SUB` | 2 | 2 | §4.6 | [`SKILL_AVAILABLE_SUBTRACTION.md`](03A_RENDERED_CATALOGUE_CASES/SKILL_AVAILABLE_SUBTRACTION.md) |
| Skill-Available Barrett Reduction | `mlk_barrett_reduce` | `LOC-SA-BR` | 3 | 3 | §4.6 | [`SKILL_AVAILABLE_BARRETT.md`](03A_RENDERED_CATALOGUE_CASES/SKILL_AVAILABLE_BARRETT.md) |
| Skill-Available Zeroisation | `mlk_zeroize` | `LOC-SA-ZERO` | 2 | 2 | §4.6 | [`SKILL_AVAILABLE_ZEROISATION.md`](03A_RENDERED_CATALOGUE_CASES/SKILL_AVAILABLE_ZEROISATION.md) |

## Case 1 — Polynomial Addition

**Target:** `mlk_poly_add` · **Locator:** `LOC-C01-UA` · **Chapter 4:** §4.3.1 · **Records:** 51 · **Supported subset:** 36

**Verification question.** Does the unchanged production addition routine realise coefficient-wise addition on its legitimate representation domains, preserve the state that is not authorised to change, and remain compatible with the production caller bounds examined by the campaign?

**Principal synthesis.** PA-01 supports exact/range/modulo/frame/algebraic relations for canonical inputs; PA-02 extends exact and modulo refinement to every signed/non-canonical pair whose sum is int16_t-representable. The retained caller, parameter and alias-diagnostic properties remain separately qualified.

**Why this synthesis was selected.** Exact addition is the semantic centre of the target; the range and modulo relations make the representation meaning explicit, while frame, algebraic, caller and cross-parameter records establish that the same value relation is not being obtained by violating object or finite-width conditions. The unrestricted signed and aliasing negatives are therefore boundary evidence, not competing principal claims.


**Case notation carried over from the appendix/evidence definition layer:**


$$
R=\operatorname{Add}(A,B)
$$


**Principal mathematics:**


$$
0\le A_i,B_i<q\;\Longrightarrow\; R_i=A_i+B_i,\qquad 0\le R_i\le2q-2
$$


$$
\operatorname{canon}_q(R_i)=\operatorname{canon}_q(A_i+B_i)
$$


$$
A_i+B_i\in\mathrm{int16}\;\Longrightarrow\;R_i=\operatorname{int32}(A_i)+\operatorname{int32}(B_i)
$$


**Native baseline.** Native `poly_add` production source, contract/annotations and repository CBMC harness; contract overlaps exact addition/range/non-aliasing obligations.

**Additional campaign assurance.** External PA suite covering exact/modular/frame/algebraic, negative-domain, alias diagnostic, caller, parameter, mutation, vacuity and provenance work.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `NEG-C01-PA03` (MEANINGFUL_NEGATIVE); `NEG-C01-PA04B` (MEANINGFUL_NEGATIVE); `LIM-C01-PA02B` (PARTIAL_PRESERVATION); `LIM-C01-PA06` (PARTIAL_PRESERVATION); `LIM-C01-PA07` (PARTIAL_PRESERVATION); `LIM-C01-PA08` (PARTIAL_PRESERVATION); `REP-C01-PA01V1` (SUPERSEDED_REPAIRED_FAILURE).


**Complete case evidence:** [`CASE_01_POLYNOMIAL_ADDITION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_01_POLYNOMIAL_ADDITION.md)


## Case 2 — Polynomial Subtraction

**Target:** `mlk_poly_sub` · **Locator:** `LOC-C02-UA` · **Chapter 4:** §4.3.2 · **Records:** 24 · **Supported subset:** 24

**Verification question.** How does the unchanged subtraction routine behave as an exact finite-width operation, as a modular operation after normalisation, and under relational dependency, frame and caller-oriented observations?

**Principal synthesis.** The subtraction campaign supports independent-oracle normalization, normalization compatibility, exact/modular cancellation, the SUB-T4 canonical exact-difference bridge with tight range [-3328,3328], frame/locality/determinism and the registered production-slice obligations.

**Why this synthesis was selected.** The principal claim is intentionally broader than a single raw equality because the case was designed around the connection between exact subtraction, modular normalisation and dependency behaviour. Cancellation, locality, determinism and production-slice records are subordinate strengthening evidence; the tight canonical-domain bridge is what prevents representability from being silently assumed.


**Case notation carried over from the appendix/evidence definition layer:**


$$
R=\operatorname{Sub}(A,B)
$$


$$
\operatorname{Norm}(X)\text{ denotes the registered production normalisation composition}
$$


**Principal mathematics:**


$$
\operatorname{Norm}(A-B)=\operatorname{canon}_q(A-B)
$$


$$
\operatorname{Norm}(A-B)=\operatorname{Norm}(\operatorname{Norm}(A)-\operatorname{Norm}(B))
$$


$$
0\le A_i,B_i<q\;\Longrightarrow\;R_i=A_i-B_i\in[-3328,3328]
$$


**Native baseline.** Native `poly_sub` source contract and repository CBMC harness primarily encode direct subtraction pre/post and safety boundary.

**Additional campaign assurance.** Independent-oracle sub→reduce refinement, normalization compatibility, cancellation, boundary, locality, determinism and production-slice T6 properties.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `LIM-C02-T3M` (NOT_TESTED); `EXC-C02-T4TPL` (EXCLUDED_TEMPLATE); `CTRL-C02-T4LOW` (EXPECTED_FAILURE_CONTROL); `CTRL-C02-T4UP` (EXPECTED_FAILURE_CONTROL).


**Complete case evidence:** [`CASE_02_POLYNOMIAL_SUBTRACTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_02_POLYNOMIAL_SUBTRACTION.md)


## Case 3 — Sequential Subtraction and Reduction

**Target:** `mlk_poly_sub → mlk_poly_reduce` · **Locator:** `LOC-C03-UA` · **Chapter 4:** §4.3.3 · **Records:** 3 · **Supported subset:** 1

**Verification question.** Do the two unchanged production functions compose correctly across their intermediate representation, rather than merely being acceptable when considered one at a time?

**Principal synthesis.** For each i, reduce(sub(A,B))_i=canon_q(int32(A_i)-int32(B_i)) within the signed-representable difference domain.

**Why this synthesis was selected.** The sequential equality is the only substantive semantic claim in this case and is therefore the principal claim by construction. The admissibility and oracle records exist to justify the domain and reference relation; they are controls and are not counted as additional mathematical properties.


**Case notation carried over from the appendix/evidence definition layer:**


$$
R=\operatorname{Reduce}(\operatorname{Sub}(A,B))
$$


**Principal mathematics:**


$$
R_i=\operatorname{canon}_q\!\left(\operatorname{int32}(A_i)-\operatorname{int32}(B_i)\right)
$$


**Native baseline.** Native separate `poly_sub` and `poly_reduce` artefacts/contracts.

**Additional campaign assurance.** Direct sequential composition against independent canonical oracle with admissibility/oracle controls and implementation/assertion mutants.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `LIM-C03-REPLAY` (SUPPORTING_ONLY).


**Complete case evidence:** [`CASE_03_SEQUENTIAL_SUBTRACTION_REDUCTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_03_SEQUENTIAL_SUBTRACTION_REDUCTION.md)


## Case 4 — Message Extraction

**Target:** `mlk_poly_tomsg` · **Locator:** `LOC-C04-UA` · **Chapter 4:** §4.4.1 · **Records:** 13 · **Supported subset:** 13

**Verification question.** Which canonical coefficients produce message bit 1, how are the 256 decisions packed into 32 bytes, and how tightly is the frozen machine-level decision expression characterised?

**Principal synthesis.** bit_k(tomsg(A))=1 iff 833<=A_k<=2496 for canonical A_k; the 256 bits are packed LSB-first into 32 bytes. The exact accepted arithmetic-offset interval is [1073417800,1074063871].

**Why this synthesis was selected.** The coefficient decision and complete packing relation are the externally meaningful semantics of message extraction. Locality and XOR relations strengthen that semantics across executions; the offset-interval family explains the exact frozen arithmetic implementation. The implementation-parameter characterisation is important evidence, but it is subordinate to the message-bit semantics and must remain tied to the pinned multiplier and shift.


**Case notation carried over from the appendix/evidence definition layer:**


$$
O(u)=\begin{cases}1,&833\le u\le2496,\\0,&\text{otherwise},\end{cases}
$$


$$
\operatorname{bit}(m,k)\text{ denotes bit }k\text{ in the production LSB-first message layout}
$$


**Principal mathematics:**


$$
\operatorname{bit}(\operatorname{ToMsg}(A),k)=O(A_k)
$$


$$
\mathcal C_{\mathrm{adm}}=[1073417800,1074063871],\qquad c_{\mathrm{prod}}=1073741824=2^{30}\in\mathcal C_{\mathrm{adm}}
$$


**Native baseline.** Native `poly_tomsg` one-call contract/harness and helper implementation.

**Additional campaign assurance.** Exact every-bit decision and packing, relational locality/XOR, and exact arithmetic-offset interval characterization.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `CONFLICT-C04-NATIVE-DIR` (EVIDENCE_SOURCE_CONFLICT).


**Complete case evidence:** [`CASE_04_MESSAGE_EXTRACTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_04_MESSAGE_EXTRACTION.md)


## Case 5 — Message Embedding

**Target:** `mlk_poly_frommsg` · **Locator:** `LOC-C05-UA` · **Chapter 4:** §4.4.2 · **Records:** 13 · **Supported subset:** 13

**Verification question.** Does the unchanged production routine embed every message bit into the intended two-value polynomial codebook, and does that codebook support the correct message-originating reverse composition and metric relations?

**Principal synthesis.** frommsg(m)_k=1665*bit_k(m), and tomsg(frommsg(m))=m for every 32-byte message m.

**Why this synthesis was selected.** The exact bit-to-codeword map and message-originating round trip are the central semantic statements. Toggle, support, popcount and distance relations explain the structure induced by that map and provide relational strengthening; they do not expand the domain to arbitrary polynomial-originating inputs.


**Case notation carried over from the appendix/evidence definition layer:**


$$
h=\frac{q+1}{2}=1665
$$


**Principal mathematics:**


$$
\operatorname{FromMsg}(m)_k=1665\,\operatorname{bit}(m,k)
$$


$$
\operatorname{ToMsg}(\operatorname{FromMsg}(m))=m
$$


**Native baseline.** Native `poly_frommsg` source contract/loop annotations and call harness.

**Additional campaign assurance.** Exact codebook embedding, one-bit relations, message-originating round trip, support/weight/distance laws.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `CONFLICT-C05-NATIVE-HARNESS` (EVIDENCE_SOURCE_CONFLICT).


**Complete case evidence:** [`CASE_05_MESSAGE_EMBEDDING.md`](03A_RENDERED_CATALOGUE_CASES/CASE_05_MESSAGE_EMBEDDING.md)


## Case 6 — D4 Compression and Decompression

**Target:** `D4 portable-C compressor/decompressor` · **Locator:** `LOC-C06-UA` · **Chapter 4:** §4.4.3 · **Records:** 18 · **Supported subset:** 18

**Verification question.** Do the production D4 encoder and decoder implement the intended scalar transformations and packing, and what exact relation remains when the intentionally lossy canonical-domain composition is analysed?

**Principal synthesis.** `Comp4(Decomp4(B))=B` for every compressed byte array `B`; `Proj4(A)=Decomp4(Comp4(A))` is a coordinatewise projection onto the 16-value codebook with `dist_q(A_i,Proj4(A)_i)<=104`, and 104 is attainable.

**Why this synthesis was selected.** Compression is deliberately lossy, so an unrestricted identity would be the wrong principal statement. The selected claim therefore pairs exact compressed-domain retraction with the canonical-domain projection and its sharp error bound. Per-direction refinements, packing, image, fixed-point, idempotence and locality records are the evidence that makes those compositions interpretable.


**Case notation carried over from the appendix/evidence definition layer:**


$$
C_4(u)=\operatorname{Round}\!\left(\frac{16u}{q}\right)\bmod16
$$


$$
D_4(t)=\operatorname{Round}\!\left(\frac{qt}{16}\right),\qquad0\le t<16
$$


$$
\operatorname{Proj}_4=\operatorname{Decomp}_4\circ\operatorname{Comp}_4
$$


**Principal mathematics:**


$$
\operatorname{Comp}_4(\operatorname{Decomp}_4(B))=B
$$


$$
\operatorname{Proj}_4(A)=\operatorname{Decomp}_4(\operatorname{Comp}_4(A))
$$


$$
\operatorname{dist}_q(A_i,\operatorname{Proj}_4(A)_i)\le104
$$


**Native baseline.** Native D4 proof directories/contracts and wider repository/backend assurance.

**Additional campaign assurance.** Four-family exact compressor/decompressor refinement, exact byte-domain retraction and canonical-domain projection with sharp error 104.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `LIM-C06-BACKEND` (OUT_OF_SCOPE).


**Complete case evidence:** [`CASE_06_D4_COMPRESSION_DECOMPRESSION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_06_D4_COMPRESSION_DECOMPRESSION.md)


## Case 7 — Signed-to-Canonical Conversion

**Target:** `mlk_scalar_signed_to_unsigned_q` · **Locator:** `LOC-C07-UA` · **Chapter 4:** §4.4.4 · **Records:** 17 · **Supported subset:** 17

**Verification question.** Does the actual production conversion map the registered signed representative domain to the canonical residue domain with the expected fibre and algebraic behaviour, and does it compose correctly with the actual Barrett body?

**Principal synthesis.** `SignedToCanon` maps `D_s={-(q-1),...,q-1}` to `[0,q)`, with the recorded fibre, idempotence, fixed-point and algebraic laws; `CanonAfterBarrett(a)=canon_q(a)` for every `int16_t` input `a`.

**Why this synthesis was selected.** The principal claim combines the function’s representation-conversion purpose with the strongest actual-body composition exercised by the campaign. Fibre, fixed-point and algebra laws expose the structure of the map; the Barrett composition demonstrates compatibility with a production reduction path. None of these records licenses arbitrary-integer reduction.


**Case notation carried over from the appendix/evidence definition layer:**


$$
D_s=\{-(q-1),\ldots,q-1\}=\{-3328,\ldots,3328\}
$$


$$
U=\{0,\ldots,q-1\}
$$


$$
F=\operatorname{SignedToCanon}
$$


**Principal mathematics:**


$$
F:D_s\to U,\qquad F(x)=\operatorname{canon}_q(x)
$$


$$
\operatorname{CanonAfterBarrett}(a)=F(\operatorname{Barrett}(a))=\operatorname{canon}_q(a)
$$


**Native baseline.** A dedicated eponymous `proofs/cbmc/scalar_signed_to_unsigned_q/` one-call harness exists in the frozen repository, together with the production helper and its exact source contract/semantics.

**Additional campaign assurance.** Exact fibre/normalizer/algebra laws and actual-body Barrett-to-canonical composition.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `CONFLICT-C07-NATIVE-DIR` (EVIDENCE_SOURCE_CONFLICT).


**Complete case evidence:** [`CASE_07_SIGNED_TO_CANONICAL.md`](03A_RENDERED_CATALOGUE_CASES/CASE_07_SIGNED_TO_CANONICAL.md)


## Case 8 — Barrett Reduction

**Target:** `mlk_barrett_reduce` · **Locator:** `LOC-C08-UA` · **Chapter 4:** §4.4.5 · **Records:** 23 · **Supported subset:** 23

**Verification question.** Does the unchanged Barrett implementation equal an independent centred-remainder oracle for every machine input, and how tightly can its quotient cells, multiplier and offset parameters be characterised?

**Principal synthesis.** For every `int16_t` input `a`, `Barrett(a)=Centered_q(a)`, `-1664<=Barrett(a)<=1664`, and `Barrett(a)≡a (mod q)`, with the registered fixed-point, quotient-cell, multiplier and offset-characterisation properties.

**Why this synthesis was selected.** Independent-oracle equality over the complete machine domain is the semantic anchor. Range and congruence state what representative is returned; fixed-point, quotient-cell, multiplier and offset families then explain why the frozen implementation realises that anchor. Parameter uniqueness is implementation characterisation, not a worldwide novelty claim.


**Case notation carried over from the appendix/evidence definition layer:**


$$
R(a)=\operatorname{Barrett}(a)
$$


$$
C(a)=\operatorname{Centered}_q(a)
$$


$$
t(a)=\frac{a-C(a)}{q}
$$


**Principal mathematics:**


$$
\forall a\in\mathrm{int16}:\quad R(a)=C(a)
$$


$$
-1664\le R(a)\le1664,\qquad R(a)\equiv a\pmod q
$$


$$
B_{\mathrm{prod}}=33554432=2^{25}\in[33548599,33560264]
$$


**Native baseline.** Native Barrett harness is essentially a symbolic call relying on the repository contract/range boundary.

**Additional campaign assurance.** Independent centered oracle plus 23 range, congruence, fibre, quotient-cell, multiplier and offset properties.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `LIM-C08-NOVELTY` (NOT_ESTABLISHED).


**Complete case evidence:** [`CASE_08_BARRETT_REDUCTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_08_BARRETT_REDUCTION.md)


## Case 9 — Zeroisation

**Target:** `mlk_zeroize` · **Locator:** `LOC-C09-UA` · **Chapter 4:** §4.5.1 · **Records:** 16 · **Supported subset:** 16

**Verification question.** Does the production operation erase exactly the authorised byte interval in the encoded C memory state, preserve everything outside that interval, and compose predictably under repeated, partitioned and release-handoff use?

**Principal synthesis.** For a valid selected interval I, Z_I(M) sets exactly the selected bytes to zero while preserving the registered frame; the recorded idempotence, partition, commutativity and release-handoff relations also hold.

**Why this synthesis was selected.** Exact erasure and frame preservation must be read together: either alone would leave a material gap. Idempotence, partition, overlap, commutativity and release-handoff records strengthen the operational meaning of the post-state. The principal claim remains explicitly source-level and does not assert physical-remanence elimination.


**Case notation carried over from the appendix/evidence definition layer:**


$$
Z_I(M)\text{ is the post-state after zeroising interval }I
$$


**Principal mathematics:**


$$
Z_I(M)[j]=\begin{cases}0,&j\in I,\\M[j],&j\notin I,\end{cases}
$$


$$
Z_I(Z_I(M))=Z_I(M)
$$


**Native baseline.** The production `mlk_zeroize` implementation and its assigns/non-alias contract are present in `mlkem/src/verify.h`, and `MLK_FREE` integration is present in `mlkem/src/common.h`; no dedicated eponymous `proofs/cbmc/zeroize/` directory exists in the frozen proof tree.

**Additional campaign assurance.** Exact effect/frame, zero-length, relational partition/commutativity/idempotence and release-handoff properties.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `LIM-C09-PHYSICAL` (OUT_OF_SCOPE).


**Complete case evidence:** [`CASE_09_ZEROISATION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_09_ZEROISATION.md)


## Case 10 — Polynomial Serialisation

**Target:** `mlk_poly_tobytes` · **Locator:** `LOC-C10-UA` · **Chapter 4:** §4.5.2 · **Records:** 19 · **Supported subset:** 19

**Verification question.** Does the unchanged serializer place each canonical 12-bit coefficient pair into the exact three-byte layout, cover the whole 384-byte result, and preserve injectivity over canonical polynomials?

**Principal synthesis.** Each canonical coefficient pair (c0,c1) is encoded as the 24-bit word c0+4096*c1 in the specified 3-byte layout; the complete 384-byte encoding is injective on canonical polynomials.

**Why this synthesis was selected.** The pair-level packed-word equation is the compact semantic description of the byte layout, while whole-polynomial injectivity establishes that the complete canonical encoding loses no information. Carry-boundary, locality, overwrite and inversion records ensure that this summary is not inferred from only a few byte positions.


**Case notation carried over from the appendix/evidence definition layer:**


$$
c_0=P_{2i},\quad c_1=P_{2i+1},\quad0\le c_0,c_1<q
$$


$$
b_0=B_{3i},\quad b_1=B_{3i+1},\quad b_2=B_{3i+2}
$$


$$
W=b_0+2^8b_1+2^{16}b_2
$$


**Principal mathematics:**


$$
W=c_0+2^{12}c_1
$$


$$
\operatorname{ToBytes}(P)=\operatorname{ToBytes}(Q)\Longleftrightarrow P=Q\quad\text{for canonical }P,Q
$$


**Native baseline.** Native tobytes contract establishes canonical preconditions/assigns/safety but not the full exact byte postcondition suite.

**Additional campaign assurance.** Nineteen exact layout, carry-boundary, image and injectivity obligations.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `LIM-C10-COUNT` (COUNTING_BOUNDARY).


**Complete case evidence:** [`CASE_10_POLYNOMIAL_SERIALISATION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_10_POLYNOMIAL_SERIALISATION.md)


## Case 11 — Polynomial Deserialisation

**Target:** `mlk_poly_frombytes` · **Locator:** `LOC-C11-UA` · **Chapter 4:** §4.5.3 · **Records:** 11 · **Supported subset:** 11

**Verification question.** What does the production decoder actually compute from each three-byte block, including non-canonical 12-bit values, and which routing, locality and inversion relations follow from that raw representation?

**Principal synthesis.** Each 3-byte word W_i is decoded to (W_i mod 4096, floor(W_i/4096)); the relation is raw 12-bit unpacking, not modulo-q canonicalization.

**Why this synthesis was selected.** The raw 12-bit decoding equation is selected precisely because the production routine does not canonicalise arbitrary segments modulo q. Routing, locality, XOR and inversion properties characterise that raw decoder more completely; they are subordinate to, and constrained by, the same representation boundary.


**Case notation carried over from the appendix/evidence definition layer:**


$$
(b_0,b_1,b_2)\text{ is one input block}
$$


$$
W=b_0+2^8b_1+2^{16}b_2
$$


$$
D=\operatorname{FromBytes}
$$


**Principal mathematics:**


$$
D(B)_{2i}=W\bmod2^{12},\qquad D(B)_{2i+1}=\left\lfloor\frac{W}{2^{12}}\right\rfloor
$$


$$
0\le D(B)_j\le4095
$$


**Native baseline.** Native frombytes contract/range/safety artefacts.

**Additional campaign assurance.** Eleven exact raw-unpacking, bit-routing, locality, XOR/injectivity and raw-domain inversion properties.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `LIM-C11-CANON` (NOT_CLAIMED).


**Complete case evidence:** [`CASE_11_POLYNOMIAL_DESERIALISATION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_11_POLYNOMIAL_DESERIALISATION.md)


## Case 12 — Direct Codec Composition

**Target:** `mlk_poly_tobytes ↔ mlk_poly_frombytes` · **Locator:** `LOC-C12-UA` · **Chapter 4:** §4.5.4 · **Records:** 2 · **Supported subset:** 2

**Verification question.** Are the two unchanged production wrappers directly compatible when composed on the domains where an exact round trip is semantically justified?

**Principal synthesis.** frombytes(tobytes(p))=p for canonical p; tobytes(frombytes(b))=b for b in the canonical encoder image.

**Why this synthesis was selected.** The direct two-function compositions are themselves the verification object. They were selected because separate serializer and decoder results do not automatically establish domain compatibility. The canonical-image restriction on the byte-originating direction is part of the principal claim, not an incidental caveat.


**Case notation carried over from the appendix/evidence definition layer:**


$$
\operatorname{ToBytes}\text{ and }\operatorname{FromBytes}\text{ denote the two production transformations}
$$


**Principal mathematics:**


$$
\operatorname{FromBytes}(\operatorname{ToBytes}(P))=P\quad(P\text{ canonical})
$$


$$
\operatorname{ToBytes}(\operatorname{FromBytes}(B))=B\quad(B\in\operatorname{im}(\operatorname{ToBytes}))
$$


**Native baseline.** Native serializer and deserializer are verified separately; no equivalent direct two-wrapper semantic composition was identified in the inspected tree.

**Additional campaign assurance.** Direct canonical-polynomial and canonical-image byte composition obligations with bridge controls.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Complete case evidence:** [`CASE_12_DIRECT_CODEC_COMPOSITION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_12_DIRECT_CODEC_COMPOSITION.md)


## Case 13 — Public-Key Validation

**Target:** `mlk_kem_check_pk` · **Locator:** `LOC-C13-UA` · **Chapter 4:** §4.5.5 · **Records:** 16 · **Supported subset:** 12

**Verification question.** Does the production checker make the expected canonicality decision, respect its memory footprint and frames, and integrate with the caller guard, while keeping stronger relational claims separate when the encoded abstraction is insufficient?

**Principal synthesis.** The registered malformed/canonical field decisions, input/frame obligations, prefix-only footprint and caller guard are supported; the two-call seed-noninterference relation remains abstraction-limited and inconclusive.

**Why this synthesis was selected.** No single arithmetic equality captures validation. The principal claim is therefore a deliberately composite boundary: decision semantics, frame/footprint obligations and caller use are all needed to describe the checked behaviour. The two-call seed-noninterference candidate is excluded from the supported principal claim because the retained abstraction cannot justify a production-level verdict.


**Case notation carried over from the appendix/evidence definition layer:**


$$
\operatorname{CheckPK}(P)\text{ denotes the production validation result}
$$


$$
\mathrm{ACCEPT},\mathrm{REJECT},\mathrm{OOM}\text{ denote the registered semantic result classes}
$$


**Principal mathematics:**


$$
\operatorname{decoded}_{12}(P,i)\ge q\;\Longrightarrow\;\operatorname{CheckPK}(P)\in\{\mathrm{REJECT},\mathrm{OOM}\}
$$


$$
\bigl(\forall i:\operatorname{decoded}_{12}(P,i)<q\bigr)\;\Longrightarrow\;\operatorname{CheckPK}(P)\in\{\mathrm{ACCEPT},\mathrm{OOM}\}
$$


**Native baseline.** Native short check_pk harness and contracts, with lower-level replacement structure.

**Additional campaign assurance.** Actual-body/contract/stub-backed functional, frame, footprint and caller-guard investigations, retaining one abstraction-limited relation.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `INC-C13-SEED` (ABSTRACTION_LIMITED_INCONCLUSIVE).


**Complete case evidence:** [`CASE_13_PUBLIC_KEY_VALIDATION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_13_PUBLIC_KEY_VALIDATION.md)


## Case 14 — Montgomery Reduction

**Target:** `mlk_montgomery_reduce; candidate mlk_fqmul / mlk_poly_tomont_c extensions` · **Locator:** `LOC-C14-UA` · **Chapter 4:** §4.5.6 · **Records:** 21 · **Supported subset:** 5

**Verification question.** What exact bounded relation is supported for the production Montgomery reduction over its legal source domain, and which stronger relational, multiplication and polynomial-conversion propositions remained unresolved?

**Principal synthesis.** MONT-T1: reduce(a)=independent_oracle(a) over the complete legal source domain, with exact reconstruction, unique signed-16 decomposition and sharp image [-32767,32767]. MONT-T2–T4 remain resource-limited and inconclusive.

**Why this synthesis was selected.** Only MONT-T1 obtained completed supporting evidence, so only its exact oracle equality, reconstruction and sharp image can anchor the principal accepted claim. MONT-T2–T4 are retained because they define scientifically meaningful extensions, but their resource-limited status is itself part of the case conclusion and prevents them from being folded into the supported claim.


**Case notation carried over from the appendix/evidence definition layer:**


$$
M(a)=\operatorname{MontRed}(a),\qquad R_M=2^{16}
$$


$$
-2038398974\le a\le2038398974
$$


**Principal mathematics:**


$$
M(a)=\operatorname{MontOracle}(a)
$$


$$
a=R_M M(a)+qt
$$


$$
-32767\le M(a)\le32767
$$


**Native baseline.** Native `montgomery_reduce`, `fqmul` and `poly_tomont_c` harnesses/contracts; optimized assembly has separate proof-oriented assurance.

**Additional campaign assurance.** T1 independent exact oracle/decomposition/sharp-image suite; T2–T4 stronger relational/multiplication/polynomial candidate designs.

**Distinctness boundary.** `SUPPORTED_FOR_T1; CANDIDATE_LEVEL_ONLY_FOR_T2_T4` — Does not establish global novelty or first-ever proof.


**Material boundary records.** `INC-C14-T2` (RESOURCE_LIMITED_INCONCLUSIVE); `INC-C14-T3` (RESOURCE_LIMITED_INCONCLUSIVE); `INC-C14-T4` (RESOURCE_LIMITED_INCONCLUSIVE); `EXC-C14-SYN` (EXCLUDED_INVALID).


**Complete case evidence:** [`CASE_14_MONTGOMERY_REDUCTION.md`](03A_RENDERED_CATALOGUE_CASES/CASE_14_MONTGOMERY_REDUCTION.md)


## Skill-Available Addition

**Target:** `mlk_poly_add` · **Locator:** `LOC-SA-ADD` · **Chapter 4:** §4.6 · **Records:** 3 · **Supported subset:** 3

**Verification question.** Which additional multi-execution addition relations were supported in the secondary skill-available investigation?

**Principal synthesis.** All nine skills invoked/outputs produced in 4/4; configuration-level inspection; Skills 2–5 positive bounded mechanical usefulness; individual incorporation/causation not demonstrable.

**Why this synthesis was selected.** These are secondary relational additions, not replacements for the unassisted Case 1 principal claim. Their value is that they exercise different multi-execution invariants under the recorded finite-width conditions.


**Principal mathematics:**


$$
(x+b)-(y+b)=x-y
$$


$$
\operatorname{Add}(a,b)=\operatorname{Add}(\operatorname{Add}(a,p),q)\quad(p+q=b)
$$


**Native baseline.** Same native addition baseline as Case 1.

**Additional campaign assurance.** Translation/equality and disjoint-support multi-execution relations.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — No causal attribution to any individual skill.


**Complete case evidence:** [`SKILL_AVAILABLE_ADDITION.md`](03A_RENDERED_CATALOGUE_CASES/SKILL_AVAILABLE_ADDITION.md)


## Skill-Available Subtraction

**Target:** `mlk_poly_sub` · **Locator:** `LOC-SA-SUB` · **Chapter 4:** §4.6 · **Records:** 2 · **Supported subset:** 2

**Verification question.** Which additional relational subtraction laws were supported in the secondary skill-available investigation?

**Principal synthesis.** All nine skills invoked/outputs produced in 4/4; configuration-level inspection; Skills 2–5 positive bounded mechanical usefulness; individual incorporation/causation not demonstrable.

**Why this synthesis was selected.** These relations are complementary multi-call laws. They are kept separate from the unassisted subtraction case because the secondary investigation had a different experimental condition and did not redefine the principal Case 2 result.


**Principal mathematics:**


$$
\operatorname{Sub}(a,b)-\operatorname{Sub}(a,c)=c-b
$$


$$
\operatorname{Sub}(\operatorname{Sub}(a,b),c)=\operatorname{Sub}(a,b+c)
$$


**Native baseline.** Same native subtraction baseline as Case 2.

**Additional campaign assurance.** Common-minuend reversal and sequential subtrahend aggregation.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — No causal attribution to any individual skill.


**Complete case evidence:** [`SKILL_AVAILABLE_SUBTRACTION.md`](03A_RENDERED_CATALOGUE_CASES/SKILL_AVAILABLE_SUBTRACTION.md)


## Skill-Available Barrett Reduction

**Target:** `mlk_barrett_reduce` · **Locator:** `LOC-SA-BR` · **Chapter 4:** §4.6 · **Records:** 3 · **Supported subset:** 3

**Verification question.** Which additional relational and compositional Barrett laws were supported in the secondary skill-available investigation?

**Principal synthesis.** All nine skills invoked/outputs produced in 4/4; configuration-level inspection; Skills 2–5 positive bounded mechanical usefulness; individual incorporation/causation not demonstrable.

**Why this synthesis was selected.** The secondary properties strengthen algebraic behaviour around the already established Barrett function. They do not alter the unassisted full-domain oracle claim and cannot be used as a causal efficiency comparison.


**Principal mathematics:**


$$
R(-a)=-R(a)
$$


$$
R(R(a)+R(b))=\operatorname{Centered}_q(a+b)
$$


**Native baseline.** Same native Barrett baseline as Case 8.

**Additional campaign assurance.** Sign conjugacy/quotient reversal and centered-addition closure.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — Incremental benefit and skill causation remain inconclusive.


**Complete case evidence:** [`SKILL_AVAILABLE_BARRETT.md`](03A_RENDERED_CATALOGUE_CASES/SKILL_AVAILABLE_BARRETT.md)


## Skill-Available Zeroisation

**Target:** `mlk_zeroize` · **Locator:** `LOC-SA-ZERO` · **Chapter 4:** §4.6 · **Records:** 2 · **Supported subset:** 2

**Verification question.** Which additional relational zeroisation histories were supported in the secondary skill-available investigation?

**Principal synthesis.** All nine skills invoked/outputs produced in 4/4; configuration-level inspection; Skills 2–5 positive bounded mechanical usefulness; individual incorporation/causation not demonstrable.

**Why this synthesis was selected.** The secondary relations ask history-sensitive questions that are not needed to state the core Case 9 wipe/frame result. They are retained as complementary relational evidence under the skill-available condition.


**Principal mathematics:**


$$
Z_I(M_1)|_I=Z_I(M_2)|_I=0
$$


$$
\varnothing\ne J\subseteq I\;\Longrightarrow\;M_{\mathrm{final}}|_I=0
$$


**Native baseline.** Same corrected native baseline as Case 9: production zeroize source/contracts exist, but no dedicated eponymous native `proofs/cbmc/zeroize/` directory exists.

**Additional campaign assurance.** Secret-history convergence and recontamination recovery.

**Distinctness boundary.** `SUPPORTED_WITHIN_INSPECTED_CORPUS` — No causal attribution to any individual skill.


**Complete case evidence:** [`SKILL_AVAILABLE_ZEROISATION.md`](03A_RENDERED_CATALOGUE_CASES/SKILL_AVAILABLE_ZEROISATION.md)


## Appendix and Chapter-4 reconciliation rule

The catalogue is intentionally deeper than the thesis appendices. The consistency requirement is semantic: every Appendix-1 supported statement must map to one supported ledger record; every Appendix-2 negative/inconclusive statement must retain the same non-supported classification; every Chapter-4 principal claim must be recoverable from the mapped property families without importing a stronger domain or conclusion. The validation report checks these populations and mappings mechanically.


## Native-baseline and distinctness rule

Repository-relative distinctness is not inferred from the absence of a filename. The frozen native census controls when a retained narrative conflicts with the source tree. The catalogue therefore states what the native repository actually contains, what overlap is necessary, what the campaign added, and the precise limit of the distinctness claim. It never converts `SUPPORTED_WITHIN_INSPECTED_CORPUS` into a worldwide novelty statement.


## Final reading rule

For a thesis claim, start with the Chapter-4 principal synthesis, use the appendix for the concise supported-property inventory, and use this catalogue when the exact property, mathematical relation, evidence status, domain, principal-claim role, native comparison or archive trace is required. The deeper evidence is authoritative for detail; the thesis is authoritative for the final scientific interpretation within its stated scope.
