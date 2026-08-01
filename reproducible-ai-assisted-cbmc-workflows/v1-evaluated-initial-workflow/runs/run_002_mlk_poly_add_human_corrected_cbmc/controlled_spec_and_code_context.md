# Controlled Context for run_002_mlk_poly_add_human_corrected_cbmc

## Target function

Function: mlk_poly_add

Signature:
void mlk_poly_add(mlk_poly *r, const mlk_poly *b)

## Implementation behaviour

The function performs destructive in-place coefficient-wise addition:

for i in 0..MLKEM_N-1:
    r->coeffs[i] = (int16_t)(r->coeffs[i] + b->coeffs[i])

## Relevant constants

MLKEM_N = 256

## Contract-level assumptions from poly.h

- r must refer to a valid mlk_poly object.
- b must refer to a valid mlk_poly object.
- r and b must be disjoint objects.
- For every coefficient k, (int32_t)old(r.coeffs[k]) + b.coeffs[k] must be <= INT16_MAX.
- For every coefficient k, (int32_t)old(r.coeffs[k]) + b.coeffs[k] must be >= INT16_MIN.

## Checked local property

For every k in 0..MLKEM_N-1, after mlk_poly_add(&r, &b):

r.coeffs[k] == old_r.coeffs[k] + b.coeffs[k]

under the stated no-overflow preconditions.

## Scope limitation

This is a local implementation-level CBMC harness for mlk_poly_add only.
It is not a proof of full ML-KEM, full FIPS 203 conformance, or full mlkem-native correctness.
