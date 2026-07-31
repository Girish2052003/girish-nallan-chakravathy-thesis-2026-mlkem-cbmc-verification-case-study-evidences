# ML-KEM  T2 Relational Property Family — Final Acceptance

## Frozen implementation binding

- Repository: `/home/girish/THESIS-2026/mlkem-native_af4c5abd`
- Commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Production source: `mlkem/src/compress.c`
- Production source SHA-256: `9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad`
- Header SHA-256: `0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd`
- Parameter set: ML-KEM-768
- CBMC toolchain: 6.9.0
- Production repository modified during campaign: no

## Accepted theorem family

### T2.1 — Relational XOR law

For arbitrary canonical polynomials \(A\) and \(B\), and arbitrary coefficient
position \(k\), the output XOR bit produced by two executions of the frozen
production implementation equals the XOR of the independently specified
Compress1 decisions for \(A[k]\) and \(B[k]\).

### T2.2A — Coefficient locality

For arbitrary canonical \(A\), \(B\), and \(k\):

\[
A[k] = B[k]
\Longrightarrow
\operatorname{bit}_k(\operatorname{tomsg}(A))
=
\operatorname{bit}_k(\operatorname{tomsg}(B)).
\]

Every coefficient pair outside \(k\) remains unrestricted.

### T2.2B — Cross-bit and byte preservation

When every coefficient pair outside \(k\) is equal, changing coefficient \(k\)
cannot change any output bit \(j \ne k\). Therefore:

- all output bytes outside byte \(\lfloor k/8 \rfloor\) are preserved; and
- the seven non-selected bits in byte \(\lfloor k/8 \rfloor\) are preserved.

This accepted theorem is the campaign's byte-confinement evidence.

### T2.3A — Same-decision invariance

For arbitrary canonical \(A\), \(B\), and \(k\), equal independent Compress1
decisions at \(A[k]\) and \(B[k]\) imply equal production output bits at \(k\).
The selected coefficient values need not be numerically equal, and all other
coefficient pairs remain unrestricted.

### T2.3B — Input-frame preservation and determinism

Two distinct polynomial objects containing the same arbitrary canonical
polynomial value:

- remain unchanged after their respective production calls; and
- produce equal complete 32-byte messages in separate destination objects.

## Evidence hardening

- Positive proof results: 5 accepted
- Successful positive CBMC properties: 2,622
- Reachability goals: 43 of 43 satisfied
- Expected-failure mutations: 5 of 5 rejected
- Mutation UNKNOWN results: 0
- Revalidated GOTO binaries: 15

## Assumptions and scope

The accepted claims are bounded C-level functional claims under the following
scope:

- every polynomial coefficient is canonical:
  \(0 \leq u < 3329\);
- ML-KEM-768 configuration;
- frozen commit `af4c5abdd5958bdc65a03cd5ee86708264f93304`;
- CBMC 6.9.0 modelling and the recorded explicit unwind bounds;
- evidence-local support wrappers used to build the production implementation;
- no modification of `compress.c` or the frozen source repository.

## Explicit non-claims

This campaign does not establish:

- timing non-interference;
- constant-time execution;
- cache, power, electromagnetic, speculative-execution, or other leakage
  resistance;
- correctness outside the canonical coefficient assumptions;
- correctness of every ML-KEM parameter set;
- correctness of the complete ML-KEM implementation;
- equivalence for assembly-optimised implementations;
- an unbounded theorem independently of CBMC's recorded C model.

The expected-failure mutations establish proof sensitivity. They do not replace
the positive proofs and do not imply that every unequal input produces a
different output.
