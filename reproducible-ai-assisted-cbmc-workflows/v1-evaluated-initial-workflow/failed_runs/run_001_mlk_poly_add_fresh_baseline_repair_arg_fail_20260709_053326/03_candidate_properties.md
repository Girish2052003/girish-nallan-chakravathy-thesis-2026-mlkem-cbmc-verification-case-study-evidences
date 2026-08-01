# 03 Candidate Properties

**Agent:** Property Discovery Agent v2
**Agent version:** `2.0-fips-aware`
**Target scheme:** ML-KEM
**Target function:** `mlk_poly_add`
**Verification tool:** CBMC

> Scientific guardrail: these are candidate properties only. CBMC/formal tools and human review remain the authority. No full ML-KEM proof is claimed.

## Agent 2 v2 Rich Input Usage
- Algorithm blocks: 0
- Symbols: 6
- Parameters: 4
- Equations/constraints: 85
- Pre/post conditions: 33
- Spec-to-code hints: 5

## First Harness Selection
- **P21** `parameter_consistency` (high): Parsed specification parameters/constants should match implementation macros/constants before using them in CBMC assumptions. Tracked parameters: human_review_required=True.
- **P58** `spec_code_alignment` (high): Agent 2 v2 spec-to-code hint should be checked: mlk_poly_add.
- **P59** `spec_code_alignment` (high): Agent 2 v2 spec-to-code hint should be checked: {"candidate_meanings": ["Error/noise vector or polynomial in ML-KEM/K-PKE descriptions."], "group": "candidate_field_mappings", "possible_code_fields": ["coeffs", "vec", "polyvec", "bytes"], "spec_symbol": "e"}.
- **P60** `spec_code_alignment` (high): Agent 2 v2 spec-to-code hint should be checked: true.
- **P61** `spec_code_alignment` (high): Agent 2 v2 spec-to-code hint should be checked: These hints are not proof obligations by themselves..
- **P62** `spec_code_alignment` (high): Agent 2 v2 spec-to-code hint should be checked: They are bridge material for the Property Discovery and Artifact Generation agents..
- **P2** `output_pointer_validity` (high): Output/in-out pointer `r` must be valid and writable when `mlk_poly_add` writes through it.
- **P1** `input_pointer_validity` (high): Input pointer `b` must be valid and readable when `mlk_poly_add` is called.

## Candidate Properties
### P4 — array_bounds [high]

All detected array accesses in `mlk_poly_add` should stay within valid bounds.

- **Source basis:** code
- **Confidence:** high
- **CBMC/check relevance:** --bounds-check, --unwind, --unwinding-assertions
- **Candidate assumptions:**
  - CBMC unwind bound must cover loop condition `i < MLKEM_N`. (derived_from_code_loop_candidate)
- **Candidate assertions/checks:**
  - Use CBMC pointer/bounds checks with sufficient unwinding and valid harness object setup.

### P1 — input_pointer_validity [high]

Input pointer `b` must be valid and readable when `mlk_poly_add` is called.

- **Source basis:** code
- **Confidence:** high
- **CBMC/check relevance:** --pointer-check
- **Candidate assumptions:**
  - `b` must refer to a valid object for `mlk_poly_add`. (code_required_precondition_candidate)
  - `r` must refer to a valid object for `mlk_poly_add`. (code_required_precondition_candidate)
- **Candidate assertions/checks:**
  - Use CBMC pointer/bounds checks with sufficient unwinding and valid harness object setup.

### P5 — loop_bound [high]

Loop `i < MLKEM_N` in `mlk_poly_add` should be unwound sufficiently and should not drive array indices outside valid bounds.

- **Source basis:** code
- **Confidence:** high
- **CBMC/check relevance:** --bounds-check, --unwind, --unwinding-assertions
- **Candidate assumptions:**
  - CBMC unwind bound must cover loop condition `i < MLKEM_N`. (derived_from_code_loop_candidate)
- **Candidate assertions/checks:**
  - Use CBMC pointer/bounds checks with sufficient unwinding and valid harness object setup.

### P3 — memory_safety [high]

All pointer field/dereference accesses inside `mlk_poly_add` should be memory-safe under documented harness assumptions.

- **Source basis:** code
- **Confidence:** high
- **CBMC/check relevance:** --bounds-check, --pointer-check
- **Candidate assumptions:**
  - `b` must refer to a valid object for `mlk_poly_add`. (code_required_precondition_candidate)
  - `r` must refer to a valid object for `mlk_poly_add`. (code_required_precondition_candidate)
  - CBMC unwind bound must cover loop condition `i < MLKEM_N`. (derived_from_code_loop_candidate)
- **Candidate assertions/checks:**
  - Use CBMC pointer/bounds checks with sufficient unwinding and valid harness object setup.

### P2 — output_pointer_validity [high]

Output/in-out pointer `r` must be valid and writable when `mlk_poly_add` writes through it.

- **Source basis:** code
- **Confidence:** high
- **CBMC/check relevance:** --pointer-check
- **Candidate assumptions:**
  - `b` must refer to a valid object for `mlk_poly_add`. (code_required_precondition_candidate)
  - `r` must refer to a valid object for `mlk_poly_add`. (code_required_precondition_candidate)
- **Candidate assertions/checks:**
  - Use CBMC pointer/bounds checks with sufficient unwinding and valid harness object setup.

### P21 — parameter_consistency [high]

Parsed specification parameters/constants should match implementation macros/constants before using them in CBMC assumptions. Tracked parameters: human_review_required=True.

- **Source basis:** agent2v2_parameters_plus_code
- **Confidence:** high
- **CBMC/check relevance:** assert/static check constants, review macros/headers
- **Agent 2 v2 evidence items:** 4
- **Candidate assertions/checks:**
  - Check that spec parameters such as n and q match code macros/constants before using them in assumptions/assertions.

### P58 — spec_code_alignment [high]

Agent 2 v2 spec-to-code hint should be checked: mlk_poly_add.

- **Source basis:** agent2v2_spec_to_code_hint
- **Confidence:** medium
- **CBMC/check relevance:** traceability check, critic review
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - Confirm selected FIPS algorithm/spec section corresponds to the selected C target function.

### P59 — spec_code_alignment [high]

Agent 2 v2 spec-to-code hint should be checked: {"candidate_meanings": ["Error/noise vector or polynomial in ML-KEM/K-PKE descriptions."], "group": "candidate_field_mappings", "possible_code_fields": ["coeffs", "vec", "polyvec", "bytes"], "spec_symbol": "e"}.

- **Source basis:** agent2v2_spec_to_code_hint
- **Confidence:** medium
- **CBMC/check relevance:** traceability check, critic review
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - Confirm selected FIPS algorithm/spec section corresponds to the selected C target function.

### P60 — spec_code_alignment [high]

Agent 2 v2 spec-to-code hint should be checked: true.

- **Source basis:** agent2v2_spec_to_code_hint
- **Confidence:** medium
- **CBMC/check relevance:** traceability check, critic review
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - Confirm selected FIPS algorithm/spec section corresponds to the selected C target function.

### P61 — spec_code_alignment [high]

Agent 2 v2 spec-to-code hint should be checked: These hints are not proof obligations by themselves..

- **Source basis:** agent2v2_spec_to_code_hint
- **Confidence:** medium
- **CBMC/check relevance:** traceability check, critic review
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - Confirm selected FIPS algorithm/spec section corresponds to the selected C target function.

### P62 — spec_code_alignment [high]

Agent 2 v2 spec-to-code hint should be checked: They are bridge material for the Property Discovery and Artifact Generation agents..

- **Source basis:** agent2v2_spec_to_code_hint
- **Confidence:** medium
- **CBMC/check relevance:** traceability check, critic review
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - Confirm selected FIPS algorithm/spec section corresponds to the selected C target function.

### P9 — aliasing [medium]

Pointer aliasing behavior for `mlk_poly_add` should be documented before adding non-aliasing assumptions.

- **Source basis:** code_plus_human_review
- **Confidence:** medium
- **CBMC/check relevance:** consider pointer aliasing assumptions only if justified
- **Candidate assumptions:**
  - Do not add non-aliasing assumptions unless implementation/spec context justifies them. (must_not_invent)

### P23 — equation_conformance [medium]

Parsed FIPS equation/constraint `comments submitted on the draft ML-KEM, domain separation was added to K-PKE.KeyGen to` may define a candidate check for `mlk_poly_add` if involved symbols map to code variables.

- **Source basis:** agent2v2_equation_constraint_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert equation relation, pre-state copies if needed
- **Agent 2 v2 evidence items:** 1
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - After `mlk_poly_add`, check whether `r->coeffs[i]` matches intended expression `(int16_t)(r->coeffs[i] + b->coeffs[i])` under documented assumptions.

### P24 — equation_conformance [medium]

Parsed FIPS equation/constraint `Additionally, FIPS 203 ipd had inadvertently swapped the indices of matrix 𝐀̂ in K-PKE.KeyGen and` may define a candidate check for `mlk_poly_add` if involved symbols map to code variables.

- **Source basis:** agent2v2_equation_constraint_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert equation relation, pre-state copies if needed
- **Agent 2 v2 evidence items:** 1
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - After `mlk_poly_add`, check whether `r->coeffs[i]` matches intended expression `(int16_t)(r->coeffs[i] + b->coeffs[i])` under documented assumptions.

### P16 — functional_correctness [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 102, "extraction_method": "prepost_keyword_regex", "section_title": "Input checking. The algorithms ML-KEM.Encaps and ML-KEM.Decaps require input checking.", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 102, "text": "Implementers shall ensure that ML-KEM.Encaps and ML-KEM.Decaps are only executed on"}], "guarantee": "Implementers shall ensure that ML-KEM.Encaps and ML-KEM.Decaps are only executed on", "human_review_required": true, "source": "postcondition_keyword_extraction"}

- **Source basis:** spec
- **Confidence:** low
- **CBMC/check relevance:** assert functional relation
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - After `mlk_poly_add`, check whether `r->coeffs[i]` matches intended expression `(int16_t)(r->coeffs[i] + b->coeffs[i])` under documented assumptions.

### P17 — functional_correctness [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 106, "extraction_method": "prepost_keyword_regex", "section_title": "inputs that have been checked, as described in Section 7.", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 106, "text": "shall ensure that intermediate data is destroyed as soon as it is no longer needed. In particular,"}], "guarantee": "shall ensure that intermediate data is destroyed as soon as it is no longer needed. In particular,", "human_review_required": true, "source": "postcondition_keyword_extraction"}

- **Source basis:** spec
- **Confidence:** low
- **CBMC/check relevance:** assert functional relation
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - After `mlk_poly_add`, check whether `r->coeffs[i]` matches intended expression `(int16_t)(r->coeffs[i] + b->coeffs[i])` under documented assumptions.

### P18 — functional_correctness [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 107, "extraction_method": "prepost_keyword_regex", "section_title": "inputs that have been checked, as described in Section 7.", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 107, "text": "for ML-KEM.KeyGen, ML-KEM.Encaps, and ML-KEM.Decaps, only the designated output can be"}], "guarantee": "for ML-KEM.KeyGen, ML-KEM.Encaps, and ML-KEM.Decaps, only the designated output can be", "human_review_required": true, "source": "postcondition_keyword_extraction"}

- **Source basis:** spec
- **Confidence:** low
- **CBMC/check relevance:** assert functional relation
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - After `mlk_poly_add`, check whether `r->coeffs[i]` matches intended expression `(int16_t)(r->coeffs[i] + b->coeffs[i])` under documented assumptions.

### P19 — functional_correctness [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 120, "extraction_method": "prepost_keyword_regex", "section_title": "Appendix C - Differences From the CRYSTALS-Kyber Submission", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 120, "text": "scheme (specified in this document) that result in differing input-output behavior of the main"}], "guarantee": "scheme (specified in this document) that result in differing input-output behavior of the main", "human_review_required": true, "source": "postcondition_keyword_extraction"}

- **Source basis:** spec
- **Confidence:** low
- **CBMC/check relevance:** assert functional relation
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - After `mlk_poly_add`, check whether `r->coeffs[i]` matches intended expression `(int16_t)(r->coeffs[i] + b->coeffs[i])` under documented assumptions.

### P20 — functional_correctness [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 122, "extraction_method": "prepost_keyword_regex", "section_title": "Appendix C - Differences From the CRYSTALS-Kyber Submission", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 122, "text": "the input-output behavior of these three algorithms (see “Implementations” and Section 3.3"}], "guarantee": "the input-output behavior of these three algorithms (see “Implementations” and Section 3.3", "human_review_required": true, "source": "postcondition_keyword_extraction"}

- **Source basis:** spec
- **Confidence:** low
- **CBMC/check relevance:** assert functional relation
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - After `mlk_poly_add`, check whether `r->coeffs[i]` matches intended expression `(int16_t)(r->coeffs[i] + b->coeffs[i])` under documented assumptions.

### P63 — functional_correctness [medium]

For `mlk_poly_add`, each output update should match selected addition/sum behavior under documented preconditions.

- **Source basis:** matched_spec_algorithm_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert functional relation
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - After `mlk_poly_add`, check whether `r->coeffs[i]` matches intended expression `(int16_t)(r->coeffs[i] + b->coeffs[i])` under documented assumptions.

### P7 — functional_update_shape [medium]

The writes performed by `mlk_poly_add` should match the intended function-level update shape under documented assumptions.

- **Source basis:** code_plus_spec
- **Confidence:** medium
- **CBMC/check relevance:** assert output relation
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - After `mlk_poly_add`, check whether `r->coeffs[i]` matches intended expression `(int16_t)(r->coeffs[i] + b->coeffs[i])` under documented assumptions.

### P8 — helper_contract [medium]

Helper calls/macros used by `mlk_poly_add` must be included, stubbed, or given documented contracts before CBMC results are trusted.

- **Source basis:** code
- **Confidence:** medium
- **CBMC/check relevance:** include helper source or safe stub
- **Candidate assertions/checks:**
  - Include helper source files in CBMC or document safe helper stubs/contracts.

### P6 — integer_overflow [medium]

Arithmetic/bit operations in `mlk_poly_add` should not trigger undefined or unintended overflow under documented assumptions.

- **Source basis:** code_plus_spec_needed
- **Confidence:** medium
- **CBMC/check relevance:** --signed-overflow-check, --unsigned-overflow-check
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - Use CBMC signed/unsigned overflow checks; separate this from functional equality assertions.

### P10 — modular_arithmetic [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.55, "evidence": [{"confidence": 0.62, "end_line": 23, "extraction_method": "math_constraint_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 23, "text": "of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming"}], "formal_tool_hint": "CBMC", "human_review_required": true, "priority": "medium", "property": "Candidate equation/constraint from specification: of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming", "type": "assignment_or_equation"}

- **Source basis:** spec_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert modular relation, overflow checks, review arithmetic width
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P11 — modular_arithmetic [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.55, "evidence": [{"confidence": 0.62, "end_line": 41, "extraction_method": "math_constraint_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 41, "text": "two constants: 𝑛 = 256 and 𝑞 = 3329."}], "formal_tool_hint": "CBMC", "human_review_required": true, "priority": "medium", "property": "Candidate equation/constraint from specification: two constants: 𝑛 = 256 and 𝑞 = 3329.", "type": "assignment_or_equation"}

- **Source basis:** spec_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert modular relation, overflow checks, review arithmetic width
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P12 — modular_arithmetic [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 3, "extraction_method": "prepost_keyword_regex", "section_title": "", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 3, "text": "attack model than the PKE scheme. As a result, ML-KEM is believed to satisfy so-called IND-CCA2"}], "guarantee": "attack model than the PKE scheme. As a result, ML-KEM is believed to satisfy so-called IND-CCA2", "human_review_required": true, "source": "postcondition_keyword_extraction"}

- **Source basis:** spec_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert modular relation, overflow checks, review arithmetic width
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P13 — modular_arithmetic [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 23, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 23, "text": "of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming"}], "guarantee": "of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming", "human_review_required": true, "source": "postcondition_keyword_extraction"}

- **Source basis:** spec_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert modular relation, overflow checks, review arithmetic width
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P14 — modular_arithmetic [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 44, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 44, "text": "both ML-KEM.Encaps and ML-KEM.Decaps will each output a 256-bit value. Moreover, if no"}], "guarantee": "both ML-KEM.Encaps and ML-KEM.Decaps will each output a 256-bit value. Moreover, if no", "human_review_required": true, "source": "postcondition_keyword_extraction"}

- **Source basis:** spec_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert modular relation, overflow checks, review arithmetic width
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P15 — modular_arithmetic [medium]

For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 80, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 80, "text": "produces the correct output for every input (where “input” includes the specified input as well"}], "guarantee": "produces the correct output for every input (where “input” includes the specified input as well", "human_review_required": true, "source": "postcondition_keyword_extraction"}

- **Source basis:** spec_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert modular relation, overflow checks, review arithmetic width
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P40 — postcondition_validity [medium]

Parsed specification postcondition `attack model than the PKE scheme. As a result, ML-KEM is believed to satisfy so-called IND-CCA2` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P41 — postcondition_validity [medium]

Parsed specification postcondition `of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P42 — postcondition_validity [medium]

Parsed specification postcondition `both ML-KEM.Encaps and ML-KEM.Decaps will each output a 256-bit value. Moreover, if no` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P43 — postcondition_validity [medium]

Parsed specification postcondition `produces the correct output for every input (where “input” includes the specified input as well` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P44 — postcondition_validity [medium]

Parsed specification postcondition `Implementers shall ensure that ML-KEM.Encaps and ML-KEM.Decaps are only executed on` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P45 — postcondition_validity [medium]

Parsed specification postcondition `shall ensure that intermediate data is destroyed as soon as it is no longer needed. In particular,` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P46 — postcondition_validity [medium]

Parsed specification postcondition `for ML-KEM.KeyGen, ML-KEM.Encaps, and ML-KEM.Decaps, only the designated output can be` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P47 — postcondition_validity [medium]

Parsed specification postcondition `scheme (specified in this document) that result in differing input-output behavior of the main` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P48 — postcondition_validity [medium]

Parsed specification postcondition `the input-output behavior of these three algorithms (see “Implementations” and Section 3.3` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P49 — postcondition_validity [medium]

Parsed specification postcondition `achieving IND-CCA2 security. The scheme K-PKE is not IND-CCA2-secure and shall not be used as` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P50 — postcondition_validity [medium]

Parsed specification postcondition `random values required for key generation (as specified in ML-KEM.KeyGen) and encapsulation` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P51 — postcondition_validity [medium]

Parsed specification postcondition `(as specified in ML-KEM.Encaps) shall be performed by the cryptographic module.` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P52 — postcondition_validity [medium]

Parsed specification postcondition `If further key derivation is needed, the final symmetric keys shall be derived from this 256-bit` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P53 — postcondition_validity [medium]

Parsed specification postcondition `must be generated for every such invocation. These random bytes shall be generated using an` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P54 — postcondition_validity [medium]

Parsed specification postcondition `this RBG shall have a security strength of at least 128 bits for ML-KEM-512, at least 192 bits for` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P57 — postcondition_validity [medium]

Parsed specification postcondition `retained in memory after the algorithm terminates. All other data shall be destroyed prior to` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert documented postcondition
- **Agent 2 v2 evidence items:** 1
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P25 — precondition_validity [medium]

Parsed specification precondition `set are given in Table 2 of Section 8. In addition to these five variable parameters, there are also` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P26 — precondition_validity [medium]

Parsed specification precondition `(as specified in ML-KEM.Encaps) shall be performed by the cryptographic module.` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P27 — precondition_validity [medium]

Parsed specification precondition `implementation may replace the given set of steps with any mathematically equivalent set of` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P28 — precondition_validity [medium]

Parsed specification precondition `produces the correct output for every input (where “input” includes the specified input as well` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P29 — precondition_validity [medium]

Parsed specification precondition `If further key derivation is needed, the final symmetric keys shall be derived from this 256-bit` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P30 — precondition_validity [medium]

Parsed specification precondition `regarding combined KEMs is given in SP 800-227 [1].` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P31 — precondition_validity [medium]

Parsed specification precondition `Randomness generation. Two algorithms in this standard require the generation of randomness` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P32 — precondition_validity [medium]

Parsed specification precondition `must be generated for every such invocation. These random bytes shall be generated using an` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P33 — precondition_validity [medium]

Parsed specification precondition `Input checking. The algorithms ML-KEM.Encaps and ML-KEM.Decaps require input checking.` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P34 — precondition_validity [medium]

Parsed specification precondition `retained in memory after the algorithm terminates. All other data shall be destroyed prior to` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P35 — precondition_validity [medium]

Parsed specification precondition `scheme (specified in this document) that result in differing input-output behavior of the main` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P36 — precondition_validity [medium]

Parsed specification precondition `the input-output behavior of these three algorithms (see “Implementations” and Section 3.3` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P37 — precondition_validity [medium]

Parsed specification precondition `As this standard requires the use of NIST-approved randomness generation, this step is` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P38 — precondition_validity [medium]

Parsed specification precondition `- This specification includes explicit input checking steps that were not part of the third-round` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P39 — precondition_validity [medium]

Parsed specification precondition `specification [4]. For example, ML-KEM.Encaps requires that the byte array containing the` should be treated as a candidate assumption for `mlk_poly_add` only after evidence review.

- **Source basis:** agent2v2_prepost_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** document and justify assumptions
- **Agent 2 v2 evidence items:** 1

### P22 — range_safety [medium]

Parsed FIPS equation/constraint `20, there was an additional step that performed the operation 𝑚 <- 𝐻(𝑚). The purpose` may define a candidate check for `mlk_poly_add` if involved symbols map to code variables.

- **Source basis:** agent2v2_equation_constraint_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert range property, __CPROVER_assume only if justified
- **Agent 2 v2 evidence items:** 1
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P64 — range_safety [medium]

For `mlk_poly_add`, output coefficient range should match selected reduction/modulus rule if explicitly supported by parsed spec and code.

- **Source basis:** matched_spec_algorithm_plus_code
- **Confidence:** medium
- **CBMC/check relevance:** assert range property, __CPROVER_assume only if justified
- **Agent 2 v2 evidence items:** 5
- **Candidate assumptions:**
  - Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. (needs_human_and_spec_confirmation)
- **Candidate assertions/checks:**
  - If the function promises range preservation, assert the documented output range.

### P65 — tool_compatibility [medium]

The CBMC harness for `mlk_poly_add` should include all required headers, helper sources, or safe stubs so verification results are meaningful.

- **Source basis:** code_plus_tool
- **Confidence:** medium
- **CBMC/check relevance:** compile harness, include required headers/sources

## Assumption Bank
- **loop_unwinding_bound**: CBMC unwind bound must cover loop condition `i < MLKEM_N`. — `derived_from_code_loop_candidate`
- **pointer_object_validity**: `b` must refer to a valid object for `mlk_poly_add`. — `code_required_precondition_candidate`
- **pointer_object_validity**: `r` must refer to a valid object for `mlk_poly_add`. — `code_required_precondition_candidate`
- **aliasing_policy**: Do not add non-aliasing assumptions unless implementation/spec context justifies them. — `must_not_invent`
- **coefficient_range_precondition**: Coefficient input ranges may be needed before overflow/range/modular assertions can be meaningful. — `needs_human_and_spec_confirmation`
- **spec_extracted_assumption**: {"assumption": "set are given in Table 2 of Section 8. In addition to these five variable parameters, there are also", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 40, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 40, "text": "set are given in Table 2 of Section 8. In addition to these five variable parameters, there are also"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "(as specified in ML-KEM.Encaps) shall be performed by the cryptographic module.", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 76, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 76, "text": "(as specified in ML-KEM.Encaps) shall be performed by the cryptographic module."}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "implementation may replace the given set of steps with any mathematically equivalent set of", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 78, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 78, "text": "implementation may replace the given set of steps with any mathematically equivalent set of"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "produces the correct output for every input (where “input” includes the specified input as well", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 80, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 80, "text": "produces the correct output for every input (where “input” includes the specified input as well"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "If further key derivation is needed, the final symmetric keys shall be derived from this 256-bit", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 86, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 86, "text": "If further key derivation is needed, the final symmetric keys shall be derived from this 256-bit"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "regarding combined KEMs is given in SP 800-227 [1].", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 92, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 92, "text": "regarding combined KEMs is given in SP 800-227 [1]."}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "Randomness generation. Two algorithms in this standard require the generation of randomness", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 93, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 93, "text": "Randomness generation. Two algorithms in this standard require the generation of randomness"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "must be generated for every such invocation. These random bytes shall be generated using an", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 97, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 97, "text": "must be generated for every such invocation. These random bytes shall be generated using an"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "Input checking. The algorithms ML-KEM.Encaps and ML-KEM.Decaps require input checking.", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 101, "extraction_method": "prepost_keyword_regex", "section_title": "Input checking. The algorithms ML-KEM.Encaps and ML-KEM.Decaps require input checking.", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 101, "text": "Input checking. The algorithms ML-KEM.Encaps and ML-KEM.Decaps require input checking."}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "retained in memory after the algorithm terminates. All other data shall be destroyed prior to", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 108, "extraction_method": "prepost_keyword_regex", "section_title": "inputs that have been checked, as described in Section 7.", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 108, "text": "retained in memory after the algorithm terminates. All other data shall be destroyed prior to"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "scheme (specified in this document) that result in differing input-output behavior of the main", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 120, "extraction_method": "prepost_keyword_regex", "section_title": "Appendix C - Differences From the CRYSTALS-Kyber Submission", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 120, "text": "scheme (specified in this document) that result in differing input-output behavior of the main"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "the input-output behavior of these three algorithms (see “Implementations” and Section 3.3", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 122, "extraction_method": "prepost_keyword_regex", "section_title": "Appendix C - Differences From the CRYSTALS-Kyber Submission", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 122, "text": "the input-output behavior of these three algorithms (see “Implementations” and Section 3.3"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "As this standard requires the use of NIST-approved randomness generation, this step is", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 139, "extraction_method": "prepost_keyword_regex", "section_title": "Appendix C - Differences From the CRYSTALS-Kyber Submission", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 139, "text": "As this standard requires the use of NIST-approved randomness generation, this step is"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "- This specification includes explicit input checking steps that were not part of the third-round", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 141, "extraction_method": "prepost_keyword_regex", "section_title": "Appendix C - Differences From the CRYSTALS-Kyber Submission", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 141, "text": "- This specification includes explicit input checking steps that were not part of the third-round"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **spec_extracted_assumption**: {"assumption": "specification [4]. For example, ML-KEM.Encaps requires that the byte array containing the", "confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 142, "extraction_method": "prepost_keyword_regex", "section_title": "Appendix C - Differences From the CRYSTALS-Kyber Submission", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 142, "text": "specification [4]. For example, ML-KEM.Encaps requires that the byte array containing the"}], "human_review_required": true, "source": "precondition_keyword_extraction"} — `needs_review`
- **agent2v2_precondition_candidate**: set are given in Table 2 of Section 8. In addition to these five variable parameters, there are also — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: (as specified in ML-KEM.Encaps) shall be performed by the cryptographic module. — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: implementation may replace the given set of steps with any mathematically equivalent set of — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: produces the correct output for every input (where “input” includes the specified input as well — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: If further key derivation is needed, the final symmetric keys shall be derived from this 256-bit — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: regarding combined KEMs is given in SP 800-227 [1]. — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: Randomness generation. Two algorithms in this standard require the generation of randomness — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: must be generated for every such invocation. These random bytes shall be generated using an — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: Input checking. The algorithms ML-KEM.Encaps and ML-KEM.Decaps require input checking. — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: retained in memory after the algorithm terminates. All other data shall be destroyed prior to — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: scheme (specified in this document) that result in differing input-output behavior of the main — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: the input-output behavior of these three algorithms (see “Implementations” and Section 3.3 — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: As this standard requires the use of NIST-approved randomness generation, this step is — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: - This specification includes explicit input checking steps that were not part of the third-round — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_precondition_candidate**: specification [4]. For example, ML-KEM.Encaps requires that the byte array containing the — `extracted_from_fips_aware_parser_needs_review`
- **agent2v2_parameter_candidate**: Parsed parameter `human_review_required` has candidate value `True`. — `must_match_code_before_use`

## CBMC Property Plan
- **target_function_for_harness_call:** mlk_poly_add
- **suggested_harness_function:** harness_mlk_poly_add
- **unwind_guess:** 256
- **Recommended checks:** --bounds-check, --unwind, --unwinding-assertions, --pointer-check, assert/static check constants, review macros/headers, traceability check, critic review, consider pointer aliasing assumptions only if justified, assert equation relation, pre-state copies if needed, assert functional relation, assert output relation, include helper source or safe stub, --signed-overflow-check, --unsigned-overflow-check, assert modular relation, overflow checks, review arithmetic width, assert documented postcondition, document and justify assumptions, assert range property, __CPROVER_assume only if justified, compile harness, include required headers/sources

## Consistency Checks
- **constant_N_consistency** [missing_in_spec / medium]: Constant/parameter N found in code as 256, but not in spec/rich parameters.
- **constant_q_consistency** [missing_in_spec / medium]: Constant/parameter q found in code as 3329, but not in spec/rich parameters.
- **constant_k_consistency** [missing_both / medium]: Constant/parameter k was not found in spec/rich parameters or code summaries.
- **target_function_consistency** [match / info]: Spec target function=mlk_poly_add, code detected function=mlk_poly_add.
- **agent2v2_relevant_algorithm_available** [missing_or_uncertain / medium]: Agent 2 v2 relevant algorithm blocks detected: 0.

## Spec-Code Traceability
- Properties with Agent 2 v2 evidence: P21, P58, P59, P60, P61, P62, P23, P24, P40, P41, P42, P43, P44, P45, P46, P47, P48, P49, P50, P51, P52, P53, P54, P57, P25, P26, P27, P28, P29, P30, P31, P32, P33, P34, P35, P36, P37, P38, P39, P22, P64
- Properties without code evidence: None

## Rejected / Deferred Properties
- **rejected_scope_too_broad**: Full ML-KEM key generation, encapsulation, or decapsulation correctness for the entire implementation. — Too broad for selected function-level experiment focused on `mlk_poly_add`.
- **rejected_overclaim**: The LLM-agent workflow proves the ML-KEM implementation correct. — Scientifically unsafe overclaim. Agents generate candidate artifacts; formal tools and human review remain the authority.
- **deferred_specialized_security_property**: Constant-time/side-channel security is fully verified by CBMC harness generation alone. — Constant-time verification needs specialized modeling/tooling and is outside first CBMC prototype unless scoped separately.
- **inherited_rejection_or_unsupported_claim**: The selected implementation is correct. — Code understanding is not formal proof; correctness must be checked by formal tools and human review.
- **inherited_rejection_or_unsupported_claim**: The full ML-KEM implementation is automatically proved by this workflow. — The thesis scope is selected components and candidate artifacts, not full automatic ML-KEM proof.
- **inherited_rejection_or_unsupported_claim**: All input ranges are known from code alone. — Input bounds usually require specification context, type definitions, and human confirmation.

## Uncertainties
- Spec uncertainty: {"severity": "medium", "suggested_action": "Use a cleaned FIPS text source and ensure algorithm headings/Input/Output lines are preserved.", "uncertainty": "No algorithm-like block was detected. The selected section may be prose-only or converted text may need cleanup."}
- Spec uncertainty: {"severity": "normal", "suggested_action": "Use Agent 3 and Agent 4 to connect extracted spec facts to actual code behavior.", "uncertainty": "Mapping between FIPS-level symbols/algorithms and implementation function 'mlk_poly_add' requires Code Understanding Agent and human review."}
- Code uncertainty: The exact struct/type definition used by the function signature was not confidently resolved from the provided headers/source.
- Code uncertainty: This code summary is not a proof. Later CBMC execution and human review must validate candidate properties and assumptions.
- Consistency issue: Constant/parameter N found in code as 256, but not in spec/rich parameters.
- Consistency issue: Constant/parameter q found in code as 3329, but not in spec/rich parameters.
- Consistency issue: Constant/parameter k was not found in spec/rich parameters or code summaries.
- Consistency issue: Agent 2 v2 relevant algorithm blocks detected: 0.
- No Agent 2 v2 algorithm blocks were available; property discovery falls back to legacy spec summary + code summary.
- Every candidate property still requires Critic Agent review, CBMC/tool execution, and human confirmation.

## Quality Flags
- **medium / agent2v2_algorithm_blocks_missing**: Rich FIPS algorithm blocks were not available; Agent 4 v2 used fallback logic.
- **medium / many_uncertainties**: Several uncertainties remain; keep first CBMC target narrow.

