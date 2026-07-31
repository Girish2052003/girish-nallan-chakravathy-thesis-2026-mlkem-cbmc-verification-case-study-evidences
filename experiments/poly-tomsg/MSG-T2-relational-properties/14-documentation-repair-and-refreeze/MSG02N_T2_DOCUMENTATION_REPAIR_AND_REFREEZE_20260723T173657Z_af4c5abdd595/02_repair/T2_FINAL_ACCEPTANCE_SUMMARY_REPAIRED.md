# ML-KEM `mlk_poly_tomsg` MSG-T2 Relational Property Family — Final Acceptance

## Accepted properties

The frozen ML-KEM-768 portable-C `mlk_poly_tomsg` implementation satisfies the accepted MSG-T2 relational family:

1. **R1 — relational XOR law:** the XOR of selected output bits equals the XOR of the independent `Compress1` decisions.
2. **R2A — coefficient locality:** equal selected coefficients imply equal selected output bits, while unrelated coefficients remain unrestricted.
3. **R2B — cross-bit preservation:** if all coefficients except possibly `k` are equal, every output bit except possibly bit `k` remains equal. This also proves byte confinement.
4. **R3A — same-decision invariance:** different selected coefficients in the same `Compress1` class produce equal selected output bits.
5. **R3B — input-frame preservation and complete-message determinism:** equal complete polynomial values in distinct objects remain unchanged and produce equal 32-byte messages in distinct output arrays.

## Accepted evidence

```text
Positive successful property records: 2622
Positive failures:                    0
Positive UNKNOWN results:             0
Reachability goals:                   43 / 43
Expected-failure mutations:           5 / 5
Validated frozen GOTO binaries:       15 / 15
```

The 2,622 successful property records include generated C-safety properties and are not 2,622 separate mathematical theorems.

## Scope

The claims apply to:

- frozen commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`;
- ML-KEM-768 portable C;
- canonical coefficients `0 <= u < 3329`;
- valid and appropriately non-aliasing objects;
- CBMC 6.9.0 and the recorded finite C model;
- the accepted verification adapters and complete loop bounds.

They do not prove all of ML-KEM, noncanonical behavior, assembly or object-code equivalence, constant-time behavior, side-channel resistance, injectivity, or every possible property of `mlk_poly_tomsg`.

## Repair boundary

This document repairs only the MSG02M Markdown-generation defect caused by an unquoted shell heredoc interpreting Markdown backticks as command substitution.

```text
CBMC_SOLVING_EXECUTED=NO
GOTO_REBUILD_EXECUTED=NO
PRODUCTION_SOURCE_MODIFIED=NO
AUTHORITATIVE_RESULT_REPLACED=NO
DOCUMENTATION_REPAIR_ONLY=YES
```

## Final status

```text
MSG_T2_RELATIONAL_XOR=ACCEPTED
MSG_T2_COEFFICIENT_LOCALITY=ACCEPTED
MSG_T2_CROSS_BIT_PRESERVATION=ACCEPTED
MSG_T2_BYTE_CONFINEMENT=ACCEPTED_VIA_STRONGER_R2B
MSG_T2_SAME_DECISION_INVARIANCE=ACCEPTED
MSG_T2_INPUT_FRAME_PRESERVATION=ACCEPTED
MSG_T2_COMPLETE_MESSAGE_DETERMINISM=ACCEPTED
MSG_T2_RELATIONAL_PROPERTY_FAMILY=FINAL_ACCEPTED
```
