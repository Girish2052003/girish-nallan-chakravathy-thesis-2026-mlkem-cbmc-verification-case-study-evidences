# BR-AF4-T5 claim limitations

T5 fixes:

- modulus 3329;
- multiplier 20159;
- arithmetic right shift by 26;
- all int16_t inputs;
- offset design domain 0 through 2^26-1.

It does not characterize arbitrary multipliers and offsets simultaneously,
different shifts, different moduli, different input domains or all possible
Barrett-reduction designs.

The arithmetic facts are classical. The contribution is the complete
implementation-specific offset-parameter characterization and its CBMC
evidence for the examined frozen arithmetic structure.

The signed-right-shift result is limited to the semantics represented by the
recorded CBMC environment.

Deterministic interval intersection and enumeration are independent
cross-checks. The authoritative formal evidence is the CBMC execution.

A documented external literature search remains required before using a
qualified originality statement. No unconditional world-first claim is made.
