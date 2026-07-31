# ML-KEM `mlk_poly_tomsg` Combined MSG-T1 / MSG-T2 / MSG-T5 Campaign Closure

## Final combined conclusion

The frozen ML-KEM-768 portable-C `mlk_poly_tomsg` campaign contains three differentiated accepted theorem families:

1. **MSG-T1 — exact fixed-production semantics**
   - exact canonical coefficient-to-bit relation;
   - all 256 output positions;
   - correct least-significant-bit-first packing.

2. **MSG-T2 — relational, locality, confinement, frame, and determinism**
   - relational XOR law;
   - coefficient locality;
   - cross-bit preservation and byte confinement;
   - same-decision invariance;
   - input-frame preservation;
   - complete-message determinism.

3. **MSG-T5 — exact admissible offset interval**
   - source-faithful parameterized model;
   - formal production-offset binding;
   - universal inside-interval sufficiency;
   - universal outside-interval necessity;
   - exact interval `[1073417800,1074063871]`;
   - production offset `2^30` is an interior member.

## Combined hardening evidence

```text
Main positive successful property records: 3696
Registered reachability goals:             65 / 65
Registered semantic mutations:             15 / 15 rejected
T1 cover-neutral companion:                522 / 522 successful
T1 insufficient-bound controls:            4 accepted
T2 frozen GOTO revalidation:               15 / 15
T5 frozen GOTO revalidation:                6 / 6
```

Property-record counts include generated C-safety checks and are not counts of independent mathematical theorems.

## Correct proof statement

Selected strong functional and relational properties of the frozen `mlk_poly_tomsg` implementation are proved within the registered assumptions and finite CBMC model.

## Explicit non-claims

The campaign does not prove:

- every property of `mlk_poly_tomsg`;
- noncanonical behavior;
- every ML-KEM parameter set;
- assembly or object-code equivalence;
- complete ML-KEM correctness or security;
- constant-time or side-channel resistance;
- universal mutation completeness;
- absolute first-ever novelty.

## Novelty position

The standard `Compress1` mathematics and broad verification of `mlkem-native` are not new.

The independently authored theorem obligations, exact T5 parameter characterization, falsification controls, correction history, and evidence architecture are distinct from the frozen native proof obligations inspected.

No exact public match was located in the 23 July 2026 review. The work is presented as a strong repository-level and campaign-level contribution and an apparently original MSc case study, not as an unconditional world-first result.
