#include <stdint.h>
#include <limits.h>

#define AC_SR1_Q 3329
#define AC_SR1_INVNTT_BOUND (8 * AC_SR1_Q)

extern int16_t nondet_int16_t(void);

void __CPROVER_assume(_Bool condition);
void __CPROVER_assert(_Bool condition, const char *description);

_Static_assert(AC_SR1_Q == 3329,
               "Unexpected ML-KEM modulus");

_Static_assert(AC_SR1_INVNTT_BOUND == 26632,
               "Unexpected inverse-NTT bound");

int main(void)
{
    /*
     * v models an arbitrary ciphertext-decompressed coefficient:
     *     0 <= v < q
     *
     * sb models an arbitrary inverse-NTT output coefficient:
     *     |sb| < 8q
     */
    int16_t v = nondet_int16_t();
    int16_t sb = nondet_int16_t();

    __CPROVER_assume((int32_t)v >= 0);
    __CPROVER_assume((int32_t)v < (int32_t)AC_SR1_Q);

    __CPROVER_assume(
        (int32_t)sb > -(int32_t)AC_SR1_INVNTT_BOUND);

    __CPROVER_assume(
        (int32_t)sb < (int32_t)AC_SR1_INVNTT_BOUND);

    /*
     * Widen both operands before subtraction.
     */
    int32_t difference =
        (int32_t)v - (int32_t)sb;

    /*
     * Exact range implied by the repository-recorded bounds.
     */
    __CPROVER_assert(
        difference >= -26631,
        "AC_SR1_EXACT_LOWER_BOUND");

    __CPROVER_assert(
        difference <= 29959,
        "AC_SR1_EXACT_UPPER_BOUND");

    /*
     * Required signed-representability implication.
     */
    __CPROVER_assert(
        difference >= (int32_t)INT16_MIN,
        "AC_SR1_IMPLIES_INT16_MIN");

    __CPROVER_assert(
        difference <= (int32_t)INT16_MAX,
        "AC_SR1_IMPLIES_INT16_MAX");

    return 0;
}
