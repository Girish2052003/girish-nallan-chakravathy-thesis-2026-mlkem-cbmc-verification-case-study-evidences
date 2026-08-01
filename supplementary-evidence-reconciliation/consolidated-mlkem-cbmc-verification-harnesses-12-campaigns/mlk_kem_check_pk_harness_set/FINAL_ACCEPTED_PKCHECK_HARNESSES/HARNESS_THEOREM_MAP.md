# Accepted PKCHECK Harnesses

## Campaign count

- Theorem families: 4
- Principal proved theorem claims: 7
- Final closure harnesses: 5
- Total accepted campaign harnesses, including historical T1: 6
- Final successful selected CBMC properties: 142

## Harness mapping

1. `01_T1_ORIGINAL_ZERO_CONTEXT_REJECTION.c`
   - Historical actual-body T1 harness.
   - Exhaustive malformed position and value.
   - Surrounding polynomial coefficients fixed to zero.
   - Superseded in strength by T1-R2.

2. `02_T1_R2_ARBITRARY_CONTEXT_REJECTION.c`
   - Final malformed-rejection harness.
   - Arbitrary malformed position.
   - Every malformed value from 3329 through 4095.
   - Arbitrary surrounding public-key bytes.
   - Arbitrary public-seed suffix.

3. `03_T1_R3_CANONICAL_ACCEPTANCE.c`
   - Final canonical-acceptance harness.
   - Every encoded coefficient constrained to the canonical domain.
   - Acceptance required unless allocation fails.

4. `04_T2_FRAME_AND_RELATIONAL.c`
   - Proved first-input preservation.
   - Proved second-input preservation.
   - Proved redzone preservation.
   - Two-call seed equality was abstraction-limited and is not counted as proved.

5. `05_T3_PREFIX_ONLY_ACCESS.c`
   - Proved that the verified checker model does not access beyond
     `MLKEM_POLYVECBYTES`.
   - Resolves the practical seed-suffix dependency question from T2.

6. `06_T4_CALLER_GUARD_DOMINANCE.c`
   - Concrete `mlk_enc_derand` caller body.
   - Deterministic validation-failure stub.
   - Proved failure propagation and four-buffer preservation.
