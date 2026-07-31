# BR-AF4-T5 Novelty Boundary

T5 does not claim a new Barrett-reduction algorithm or a new principle of
integer or modular arithmetic.

T5 characterizes the complete rounding-offset parameter interval for the
specific fixed arithmetic structure:

- multiplier 20159;
- modulus 3329;
- arithmetic right shift by 26;
- all int16_t inputs;
- offset design domain 0 through 2^26-1.

The target result is the exact interval of offsets that produce the centered
representative modulo 3329 for every int16_t input.

A frozen-repository overlap audit is recorded in this stage. An external
literature audit remains required before any qualified originality statement.
No unconditional world-first claim is made.
