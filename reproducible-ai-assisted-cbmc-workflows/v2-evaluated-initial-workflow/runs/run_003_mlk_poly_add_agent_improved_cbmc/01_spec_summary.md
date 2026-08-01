# Specification Extraction Summary v2

Generated: `2026-07-09T04:01:33+00:00`

## Scientific Guardrail

The extracted specification items are candidate verification inputs. They must not be treated as a complete proof or as a replacement for formal-tool checking and human review.

## Target

- Scheme: `ML-KEM`
- Function: `mlk_poly_add`
- Tool: `CBMC`
- Mode: `auto_search`
- Source: `/home/girish/thesis-agent-workflow/inputs/specs/fips203_clean.txt`

## Selected / Candidate Sections

- `MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM` lines 1475-1531 score=125.1 terms=['add', 'K-PKE', 'KEM', 'ML', 'ML-KEM', 'n', 'poly', 'polynomial', 'q']
- `MODULE-LATTICE-BASED KEY-ENCAPSULATION MECHANISM` lines 1570-1617 score=101.6 terms=['KEM', 'ML', 'ML-KEM', 'n', 'q']
- `Appendix C - Differences From the CRYSTALS-Kyber Submission` lines 3638-3684 score=99.7 terms=['add', 'K-PKE', 'KEM', 'ML', 'ML-KEM', 'n', 'q']

## Extracted Constants

```json
{
  "th": 256
}
```

## Algorithm Blocks Parsed

- None detected.

## Symbol Table Preview

- `A`: Matrix or public matrix-like object in ML-KEM/K-PKE descriptions.
- `constants`: 𝑛 = 256 and 𝑞 = 3329.
- `e`: Error/noise vector or polynomial in ML-KEM/K-PKE descriptions.
- `KEM`: use of the number-theoretic transform (NTT). The NTT, IND-CCA2-secure KEM. However, a combined KEM
- `step`: ML-KEM.KeyGen and ML-KEM.Encaps. In pseudocode, this randomness
- `variables`: 𝑘, 𝜂1 , 𝜂2 , 𝑑𝑢 , and 𝑑𝑣 . The values of these variables in each parameter

## Input Assumptions / Preconditions

- set are given in Table 2 of Section 8. In addition to these five variable parameters, there are also
- (as specified in ML-KEM.Encaps) shall be performed by the cryptographic module.
- implementation may replace the given set of steps with any mathematically equivalent set of
- produces the correct output for every input (where “input” includes the specified input as well
- If further key derivation is needed, the final symmetric keys shall be derived from this 256-bit
- regarding combined KEMs is given in SP 800-227 [1].
- Randomness generation. Two algorithms in this standard require the generation of randomness
- must be generated for every such invocation. These random bytes shall be generated using an
- Input checking. The algorithms ML-KEM.Encaps and ML-KEM.Decaps require input checking.
- retained in memory after the algorithm terminates. All other data shall be destroyed prior to
- scheme (specified in this document) that result in differing input-output behavior of the main
- the input-output behavior of these three algorithms (see “Implementations” and Section 3.3
- As this standard requires the use of NIST-approved randomness generation, this step is
- - This specification includes explicit input checking steps that were not part of the third-round
- specification [4]. For example, ML-KEM.Encaps requires that the byte array containing the

## Output Guarantees / Postconditions

- attack model than the PKE scheme. As a result, ML-KEM is believed to satisfy so-called IND-CCA2
- of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming
- both ML-KEM.Encaps and ML-KEM.Decaps will each output a 256-bit value. Moreover, if no
- produces the correct output for every input (where “input” includes the specified input as well
- Implementers shall ensure that ML-KEM.Encaps and ML-KEM.Decaps are only executed on
- shall ensure that intermediate data is destroyed as soon as it is no longer needed. In particular,
- for ML-KEM.KeyGen, ML-KEM.Encaps, and ML-KEM.Decaps, only the designated output can be
- scheme (specified in this document) that result in differing input-output behavior of the main
- the input-output behavior of these three algorithms (see “Implementations” and Section 3.3

## Candidate Safety Properties

- None detected.

## Candidate Functional Properties

- Candidate equation/constraint from specification: of corruption or interference, the process in Figure 1 will result in 𝐾 ′ = 𝐾 with overwhelming
- Candidate equation/constraint from specification: two constants: 𝑛 = 256 and 𝑞 = 3329.

## Uncertainties

- No algorithm-like block was detected. The selected section may be prose-only or converted text may need cleanup.
- Mapping between FIPS-level symbols/algorithms and implementation function 'mlk_poly_add' requires Code Understanding Agent and human review.

## Traceability Files

- `selected_spec_excerpt.txt`
- `01_spec_sections_index.json`
- `01_algorithm_blocks.json`
- `01_symbol_table.json`
- `01_parameter_table.json`
- `01_equations_constraints.json`
- `01_preconditions_postconditions.json`
- `01_spec_to_code_hints.json`

## Thesis-Safe Meaning

This agent parsed specification material into structured candidate verification inputs. These outputs are designed for Agent 4 and Agent 5, but they still require human review before strong correctness claims are made.
