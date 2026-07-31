# BR-AF4-T3 claim limitations

T3 does not introduce a new principle of modular arithmetic or a new
Barrett-reduction algorithm.

The result is an implementation-specific CBMC characterization of the exact
quotient expression and the resulting 21-cell partition for the examined
frozen `mlkem-native` C implementation.

The signed-right-shift result is scoped to the semantics represented by the
recorded CBMC environment.

The deterministic Python enumeration is an independent cross-check. The
authoritative formal evidence is the CBMC result.

A frozen-repository overlap audit has been recorded. A documented external
literature search is still required before using a qualified originality
statement such as “to the author’s knowledge.”

No unconditional world-first claim is made.

M1 and M2 generated additional non-T3 failures beyond their intended P10
failure. Their exact identities and traces must be reviewed before final T3
freeze and accurately recorded rather than guessed.
