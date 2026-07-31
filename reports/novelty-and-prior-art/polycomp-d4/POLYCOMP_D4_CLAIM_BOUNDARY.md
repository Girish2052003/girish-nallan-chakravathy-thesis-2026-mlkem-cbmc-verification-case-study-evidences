# POLYCOMP-D4 claim boundary

The supplied verdicts describe bounded clean-room CBMC campaigns for the pinned portable-C ML-KEM-768 implementation. They do not claim new ML-KEM mathematics or universal implementation correctness.

Across T1–T4, the evidence does **not** establish:

- equivalence with AVX2, native assembly, or other optimized backends;
- correctness of assembly implementations;
- constant-time or side-channel security;
- end-to-end ML-KEM correctness;
- correctness of unrelated functions;
- correctness for other parameter configurations, including ML-KEM-1024's different compression configuration;
- T1 behavior outside the canonical coefficient precondition;
- T4 behavior outside the canonical coefficient domain.

T2 explicitly notes existing HOL Light work relating to the AVX2 assembly implementation and does not claim decompression correctness was previously absent. T3 and T4 similarly avoid claims that compression, decompression, round-trip, quantization, or error-bound properties were absent from all other tests, proofs, backends, or formal developments.
