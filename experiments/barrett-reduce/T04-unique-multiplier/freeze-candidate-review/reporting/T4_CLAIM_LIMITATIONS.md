# BR-AF4-T4 claim limitations

T4 proves uniqueness only within the explicitly defined nonnegative
numerator-safe design domain:

    0 <= multiplier <= 64513.

The theorem fixes:

- modulus 3329;
- offset 2^25;
- arithmetic right shift by 26;
- the complete int16_t input domain;
- signed-int32 numerator representability.

It does not prove uniqueness among negative multipliers, different offsets,
different shifts, wider intermediate types, different input domains or every
possible Barrett-reduction design.

The mathematical reasoning uses classical integer and modular arithmetic.
The research contribution is the implementation-specific parameter-space
characterization and CBMC evidence for the frozen C implementation.

The signed-right-shift claim is scoped to the semantics represented by the
recorded CBMC environment.

The deterministic discovery is an independent cross-check. The authoritative
formal evidence is the CBMC execution.

A documented external literature search remains required before a qualified
“to the author's knowledge” originality statement is used. No unconditional
world-first claim is made.
