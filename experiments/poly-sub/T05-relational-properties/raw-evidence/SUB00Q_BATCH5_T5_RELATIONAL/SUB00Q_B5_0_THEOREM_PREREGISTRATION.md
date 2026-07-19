# SUB-T5 / B5.0 — Frozen Theorem and Assumption Preregistration

Official theorem:
Coefficient-Locality, Frame Preservation, Cross-Coefficient Non-Interference, and Determinism of mlk_poly_sub.

Model:
Two sequential executions use distinct complete objects R1, R2, A1, A2, B1, and B2. R1 is initialized from A1 and R2 from A2. Both calls use the same later-bound frozen ML-KEM-768 production implementation.

Canonical domain:
For every i in [0,255], 0 <= A1[i], A2[i], B1[i], B2[i] < 3329. Therefore subtraction lies in [-3328,3328]. No independent INT16 representability or result-shaped assumptions are permitted.

Registered assumptions:
Valid complete polynomial objects; mutual separation of call operands, snapshots, and guards; sequential single-threaded execution; symbolic k and j in [0,255]; same frozen source and build model. Arbitrary aliasing and concurrency are outside scope.

Frozen obligations:
T5.1 A1, A2, B1, B2, snapshots, and guards remain unchanged.
T5.2 A1[k]=A2[k] and B1[k]=B2[k] imply R1[k]=R2[k], even when non-target coefficients differ.
T5.3 Inputs differing only at j imply R1[i]=R2[i] for every i != j.
T5.4 At j, each result equals its matching mathematical subtraction, and the widened int32_t relational difference is exact.
T5.5 Identical complete inputs imply identical complete outputs.
T5.6 Only R1 and R2 may change among explicitly modelled harness-owned polynomial objects.

Required reachability:
k=0,127,255; j=0,255; genuinely different non-target coefficients; locally equal but globally different inputs; identical complete inputs.

Expected-failure controls:
Reject false off-target influence and false nondeterminism.

Mutation controls:
Use adjacent or preceding coefficients, write into B, and skip coefficient 255. Semantic mutation kills require relevant assertion failures; compilation failure alone is insufficient.

Permitted claims:
Only the six registered frame, locality, non-interference, exact-effect, determinism, and harness-observed destination-boundary claims.

Non-claims:
No unrestricted whole-memory theorem, arbitrary-aliasing correctness, thread safety, constant-time or leakage result, out-of-domain correctness, whole-library/program correctness, universal novelty claim, or proof-by-preregistration.

Gate order:
B5.0 preregistration; B5.1 source/build binding; B5.2 harness freeze; B5.3 structural audit; B5.4 GOTO preflight; B5.5 positive execution; B5.6 reachability; B5.7 expected failures; B5.8 mutations; B5.9 final package.

B5.0 execution status:
CBMC execution NO. GOTO creation NO. Production-source modification NO. Earlier-batch modification NO.

Any amendment requires a separately versioned correction record and checksum.
