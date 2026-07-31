# PBYTES-T3 closure evidence

This directory records the closure evidence for PBYTES-T3:
the exact canonical image and invalid-codeword exclusion theorem
for the portable `mlk_poly_tobytes` implementation.

The evidence contains:

- five frozen T3 obligations;
- four successful positive CBMC models;
- 430 successful positive properties;
- independent arithmetic decoding without `mlk_poly_frombytes`;
- sixteen concrete non-vacuity witnesses;
- six insufficient-unwind controls;
- five targeted production-code semantic mutants;
- source, commit, command, result and SHA-256 bindings.

The theorem establishes that:

1. actual output blocks decode to canonical even fields;
2. actual output blocks decode to canonical odd fields;
3. every canonical block is realizable;
4. blocks containing invalid fields are excluded;
5. a full output array is in the image exactly when all 256
   independently decoded fields are canonical.

The evidence does not establish native-backend correctness,
timing or side-channel behaviour, decoder correctness, or complete
ML-KEM correctness.
