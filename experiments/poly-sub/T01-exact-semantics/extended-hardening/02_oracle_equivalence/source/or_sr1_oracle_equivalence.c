#include <stdint.h>
#include <limits.h>

#define OR_SR1_Q 3329
#define OR_SR1_SHIFT_MULTIPLIER 10
#define OR_SR1_SHIFT \
    (OR_SR1_SHIFT_MULTIPLIER * OR_SR1_Q)

extern int32_t nondet_int32_t(void);

void __CPROVER_assume(_Bool condition);
void __CPROVER_assert(_Bool condition, const char *description);

_Static_assert(
    OR_SR1_Q == 3329,
    "Unexpected ML-KEM modulus");

_Static_assert(
    OR_SR1_SHIFT == 33290,
    "Unexpected oracle shift");

int main(void)
{
    int32_t d = nondet_int32_t();

    /*
     * VC-SR1 permits every mathematical difference representable
     * as an int16_t value.
     */
    __CPROVER_assume(d >= (int32_t)INT16_MIN);
    __CPROVER_assume(d <= (int32_t)INT16_MAX);

    /*
     * Shifted-oracle formulation used by VC-SR1.
     *
     * Since d + 10q is in [522, 66057], the addition is safe in
     * int32_t and the conversion to uint32_t preserves the value.
     */
    int32_t shifted_signed =
        d + (int32_t)OR_SR1_SHIFT;

    uint32_t shifted =
        (uint32_t)shifted_signed;

    uint32_t shifted_oracle =
        shifted % (uint32_t)OR_SR1_Q;

    /*
     * Independent normalized-remainder formulation.
     *
     * C signed remainder has the sign of d, so d % q lies within
     * [-3328, 3328]. Adding q makes the value positive before the
     * final remainder operation.
     */
    int32_t signed_remainder =
        d % (int32_t)OR_SR1_Q;

    int32_t normalized_oracle =
        (signed_remainder + (int32_t)OR_SR1_Q)
        % (int32_t)OR_SR1_Q;

    __CPROVER_assert(
        shifted_signed >= 522,
        "OR_SR1_SHIFTED_SIGNED_LOWER_BOUND");

    __CPROVER_assert(
        shifted_signed <= 66057,
        "OR_SR1_SHIFTED_SIGNED_UPPER_BOUND");

    __CPROVER_assert(
        shifted == (uint32_t)shifted_signed,
        "OR_SR1_UINT32_CONVERSION_PRESERVES_VALUE");

    __CPROVER_assert(
        shifted_oracle < (uint32_t)OR_SR1_Q,
        "OR_SR1_SHIFTED_ORACLE_CANONICAL_RANGE");

    __CPROVER_assert(
        normalized_oracle >= 0,
        "OR_SR1_NORMALIZED_ORACLE_LOWER_BOUND");

    __CPROVER_assert(
        normalized_oracle < (int32_t)OR_SR1_Q,
        "OR_SR1_NORMALIZED_ORACLE_UPPER_BOUND");

    __CPROVER_assert(
        shifted_oracle == (uint32_t)normalized_oracle,
        "OR_SR1_ORACLE_EQUIVALENCE");

    return 0;
}
