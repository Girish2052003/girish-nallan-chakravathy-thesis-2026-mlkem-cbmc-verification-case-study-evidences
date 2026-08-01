# Human Review Checklist

Run: `run_001_mlk_poly_add_fresh_baseline`
Target: `ML-KEM` / `mlk_poly_add`

## Mandatory Guardrail

- [ ] Confirm the thesis does not claim full automatic proof of ML-KEM.
- [ ] Confirm the report says artifacts are candidate formal-verification artifacts.
- [ ] Confirm CBMC results are interpreted only for selected harness/properties/assumptions.
- [ ] Confirm human review is explicitly stated as necessary.

## Specification Grounding

- [ ] Check that every assumption is supported by the selected specification excerpt or code context.
- [ ] Check that constants such as polynomial size and modulus are correct for the selected target.
- [ ] Check that unsupported assumptions are not silently used to make CBMC pass.
- [ ] Review Agent 2 v2 spec parsing quality score: `0.705`.
- [ ] Review algorithm extraction coverage and confirm parsed algorithm steps match the selected FIPS/spec section.
- [ ] Review symbol extraction coverage and confirm symbols such as q, n, k, eta, du/dv are not misused.
- [ ] Review parameter extraction confidence and confirm numerical values are correct for the selected parameter set.
- [ ] Review human-review status for extracted spec claims.

## Code Grounding

- [ ] Check that the harness calls the correct target function.
- [ ] Check that pointer parameters are initialized safely.
- [ ] Check that all required headers/source files are included in the CBMC command.
- [ ] Check that loop unwinding matches the implementation loop bound.

## Properties

- [ ] Review `P4` (array_bounds): All detected array accesses in `mlk_poly_add` should stay within valid bounds.
- [ ] Review `P1` (input_pointer_validity): Input pointer `b` must be valid and readable when `mlk_poly_add` is called.
- [ ] Review `P5` (loop_bound): Loop `i < MLKEM_N` in `mlk_poly_add` should be unwound sufficiently and should not drive array indices outside valid bounds.
- [ ] Review `P3` (memory_safety): All pointer field/dereference accesses inside `mlk_poly_add` should be memory-safe under documented harness assumptions.
- [ ] Review `P2` (output_pointer_validity): Output/in-out pointer `r` must be valid and writable when `mlk_poly_add` writes through it.
- [ ] Review `P21` (parameter_consistency): Parsed specification parameters/constants should match implementation macros/constants before using them in CBMC assumptions. Tracked parameters: human_review_required=True.
- [ ] Review `P58` (spec_code_alignment): Agent 2 v2 spec-to-code hint should be checked: mlk_poly_add.
- [ ] Review `P59` (spec_code_alignment): Agent 2 v2 spec-to-code hint should be checked: {"candidate_meanings": ["Error/noise vector or polynomial in ML-KEM/K-PKE descriptions."], "group": "candidate_field_mappings", "possible_code_fields": ["coeffs", "vec", "polyvec", "bytes"], "spec_symbol": "e"}.
- [ ] Review `P60` (spec_code_alignment): Agent 2 v2 spec-to-code hint should be checked: true.
- [ ] Review `P61` (spec_code_alignment): Agent 2 v2 spec-to-code hint should be checked: These hints are not proof obligations by themselves..
- [ ] Review `P62` (spec_code_alignment): Agent 2 v2 spec-to-code hint should be checked: They are bridge material for the Property Discovery and Artifact Generation agents..
- [ ] Review `P9` (aliasing): Pointer aliasing behavior for `mlk_poly_add` should be documented before adding non-aliasing assumptions.
- [ ] Review `P23` (equation_conformance): Parsed FIPS equation/constraint `comments submitted on the draft ML-KEM, domain separation was added to K-PKE.KeyGen to` may define a candidate check for `mlk_poly_add` if involved symbols map to code variables.
- [ ] Review `P24` (equation_conformance): Parsed FIPS equation/constraint `Additionally, FIPS 203 ipd had inadvertently swapped the indices of matrix 𝐀̂ in K-PKE.KeyGen and` may define a candidate check for `mlk_poly_add` if involved symbols map to code variables.
- [ ] Review `P16` (functional_correctness): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 102, "extraction_method": "prepost_keyword_regex", "section_title": "Input checking. The algorithms ML-KEM.Encaps and ML-KEM.Decaps require input checking.", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 102, "text": "Implementers shall ensure that ML-KEM.Encaps and ML-KEM.Decaps are only executed on"}], "guarantee": "Implementers shall ensure that ML-KEM.Encaps and ML-KEM.Decaps are only executed on", "human_review_required": true, "source": "postcondition_keyword_extraction"}
- [ ] Review `P17` (functional_correctness): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 106, "extraction_method": "prepost_keyword_regex", "section_title": "inputs that have been checked, as described in Section 7.", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 106, "text": "shall ensure that intermediate data is destroyed as soon as it is no longer needed. In particular,"}], "guarantee": "shall ensure that intermediate data is destroyed as soon as it is no longer needed. In particular,", "human_review_required": true, "source": "postcondition_keyword_extraction"}
- [ ] Review `P18` (functional_correctness): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 107, "extraction_method": "prepost_keyword_regex", "section_title": "inputs that have been checked, as described in Section 7.", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 107, "text": "for ML-KEM.KeyGen, ML-KEM.Encaps, and ML-KEM.Decaps, only the designated output can be"}], "guarantee": "for ML-KEM.KeyGen, ML-KEM.Encaps, and ML-KEM.Decaps, only the designated output can be", "human_review_required": true, "source": "postcondition_keyword_extraction"}
- [ ] Review `P19` (functional_correctness): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 120, "extraction_method": "prepost_keyword_regex", "section_title": "Appendix C - Differences From the CRYSTALS-Kyber Submission", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 120, "text": "scheme (specified in this document) that result in differing input-output behavior of the main"}], "guarantee": "scheme (specified in this document) that result in differing input-output behavior of the main", "human_review_required": true, "source": "postcondition_keyword_extraction"}
- [ ] Review `P20` (functional_correctness): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 122, "extraction_method": "prepost_keyword_regex", "section_title": "Appendix C - Differences From the CRYSTALS-Kyber Submission", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 122, "text": "the input-output behavior of these three algorithms (see “Implementations” and Section 3.3"}], "guarantee": "the input-output behavior of these three algorithms (see “Implementations” and Section 3.3", "human_review_required": true, "source": "postcondition_keyword_extraction"}
- [ ] Review `P63` (functional_correctness): For `mlk_poly_add`, each output update should match selected addition/sum behavior under documented preconditions.
- [ ] Review `P7` (functional_update_shape): The writes performed by `mlk_poly_add` should match the intended function-level update shape under documented assumptions.
- [ ] Review `P8` (helper_contract): Helper calls/macros used by `mlk_poly_add` must be included, stubbed, or given documented contracts before CBMC results are trusted.
- [ ] Review `P6` (integer_overflow): Arithmetic/bit operations in `mlk_poly_add` should not trigger undefined or unintended overflow under documented assumptions.
- [ ] Review `P10` (modular_arithmetic): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.55, "evidence": [{"confidence": 0.62, "end_line": 23, "extraction_method": "math_constraint_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 23, "text": "of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming"}], "formal_tool_hint": "CBMC", "human_review_required": true, "priority": "medium", "property": "Candidate equation/constraint from specification: of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming", "type": "assignment_or_equation"}
- [ ] Review `P11` (modular_arithmetic): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.55, "evidence": [{"confidence": 0.62, "end_line": 41, "extraction_method": "math_constraint_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 41, "text": "two constants: 𝑛 = 256 and 𝑞 = 3329."}], "formal_tool_hint": "CBMC", "human_review_required": true, "priority": "medium", "property": "Candidate equation/constraint from specification: two constants: 𝑛 = 256 and 𝑞 = 3329.", "type": "assignment_or_equation"}
- [ ] Review `P12` (modular_arithmetic): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 3, "extraction_method": "prepost_keyword_regex", "section_title": "", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 3, "text": "attack model than the PKE scheme. As a result, ML-KEM is believed to satisfy so-called IND-CCA2"}], "guarantee": "attack model than the PKE scheme. As a result, ML-KEM is believed to satisfy so-called IND-CCA2", "human_review_required": true, "source": "postcondition_keyword_extraction"}
- [ ] Review `P13` (modular_arithmetic): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 23, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 23, "text": "of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming"}], "guarantee": "of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming", "human_review_required": true, "source": "postcondition_keyword_extraction"}
- [ ] Review `P14` (modular_arithmetic): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 44, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 44, "text": "both ML-KEM.Encaps and ML-KEM.Decaps will each output a 256-bit value. Moreover, if no"}], "guarantee": "both ML-KEM.Encaps and ML-KEM.Decaps will each output a 256-bit value. Moreover, if no", "human_review_required": true, "source": "postcondition_keyword_extraction"}
- [ ] Review `P15` (modular_arithmetic): For `mlk_poly_add`, candidate spec-derived property: {"confidence": 0.66, "evidence": [{"confidence": 0.66, "end_line": 80, "extraction_method": "prepost_keyword_regex", "section_title": "MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM", "source_file": "/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt", "start_line": 80, "text": "produces the correct output for every input (where “input” includes the specified input as well"}], "guarantee": "produces the correct output for every input (where “input” includes the specified input as well", "human_review_required": true, "source": "postcondition_keyword_extraction"}
- [ ] Review `P40` (postcondition_validity): Parsed specification postcondition `attack model than the PKE scheme. As a result, ML-KEM is believed to satisfy so-called IND-CCA2` should be treated as a candidate assertion for `mlk_poly_add` only after evidence review.

## Failures / Limitations

- [ ] Inspect `assertion_not_aligned_with_parsed_algorithm` from `review_critic_agent`: Check whether this assertion is implementation-derived only, or add explicit spec/algorithm evidence before relying on it.
- [ ] Inspect `signed_overflow_risk_in_functional_assertion` from `review_critic_agent`: Separate memory-safety checking from arithmetic correctness, or add carefully justified coefficient preconditions before checking equality.
- [ ] Inspect `aliasing_not_discussed` from `review_critic_agent`: Decide whether aliases like r == a or r == b are allowed by the implementation contract, and document the choice.
- [ ] Inspect `repair_limitation` from `repair_agent`: Inspect repair notes and perform human-guided correction.

## Final Decision

- [ ] Accept this run as useful evidence.
- [ ] Accept only after manual correction.
- [ ] Reject this run from final evaluation.
- [ ] Rerun after repairing tool/harness/configuration issues.

Reviewer notes:

```text

```
