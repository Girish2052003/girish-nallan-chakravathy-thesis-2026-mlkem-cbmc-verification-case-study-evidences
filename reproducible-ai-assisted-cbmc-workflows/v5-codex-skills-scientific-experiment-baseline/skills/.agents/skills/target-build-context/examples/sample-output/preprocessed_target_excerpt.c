/* preprocessed lines 405-417; lexical excerpt only */
#define LOCAL_ADJUSTMENT 0
void helper_touch(poly *r)
{
    r->coeffs[0] = r->coeffs[0] + 0;
}
void mlk_poly_sub(poly *r, const poly *a, const poly *b)
{
    unsigned i;
    for (i = 0; i < 4; i++) {
        r->coeffs[i] = a->coeffs[i] - b->coeffs[i];
    }
    helper_touch(r);
}
