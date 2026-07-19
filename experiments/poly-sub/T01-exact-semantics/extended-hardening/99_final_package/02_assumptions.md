# Assumptions

The central semantic proof assumes that every coefficientwise mathematical
difference is representable as a signed 16-bit C value.

AC-SR1 separately establishes that the frozen production decryption callsite
satisfies this requirement:

- decompressed `v[i]` is in `[0,3329)`;
- inverse-NTT `sb[i]` has absolute value below `26632`;
- therefore `v[i] - sb[i]` is in `[-26631,29959]`;
- this interval is representable by `int16_t`.

The proof also depends on the recorded C machine model, ML-KEM-768
configuration, safety-check options and complete loop bounds.
