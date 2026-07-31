# BR-AF4 T1-T5 claim boundary

The package contains five distinct implementation-specific theorem families
and 23 named research properties.

It does not claim five new principles of mathematics. The underlying integer
and modular arithmetic is classical.

The contribution is the construction and reproducible CBMC checking of a
full-domain theorem family for the exact frozen mlkem-native C implementation
and its Barrett parameters.

The results are limited to:

- frozen commit af4c5abdd5958bdc65a03cd5ee86708264f93304;
- modulus 3329;
- int16_t inputs;
- the recorded CBMC 6.9.0 environment;
- the recorded signed-right-shift semantics;
- the explicitly declared multiplier and offset design spaces.

No unconditional world-first claim is made.

A documented external literature audit must be completed before using the
qualified statement “to the author's knowledge, no prior work reports this
exact theorem suite for the examined frozen implementation.”
