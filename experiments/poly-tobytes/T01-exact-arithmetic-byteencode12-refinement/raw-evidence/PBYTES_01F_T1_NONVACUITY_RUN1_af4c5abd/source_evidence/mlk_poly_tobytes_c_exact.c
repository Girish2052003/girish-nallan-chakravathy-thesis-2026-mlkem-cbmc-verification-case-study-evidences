MLK_STATIC_TESTABLE void mlk_poly_tobytes_c(uint8_t r[MLKEM_POLYBYTES],
                                            const mlk_poly *a)
__contract__(
  requires(memory_no_alias(r, MLKEM_POLYBYTES))
  requires(memory_no_alias(a, sizeof(mlk_poly)))
  requires(array_bound(a->coeffs, 0, MLKEM_N, 0, MLKEM_Q))
  assigns(memory_slice(r, MLKEM_POLYBYTES))
)
{
  unsigned i;
  mlk_assert_bound(a, MLKEM_N, 0, MLKEM_Q);

  for (i = 0; i < MLKEM_N / 2; i++)
  __loop__(invariant(i <= MLKEM_N / 2)
           decreases(MLKEM_N / 2 - i))
  {
    /* The conversion to uint16_t is safe since we assume that
     * the coefficients of `a` are non-negative. */
    const uint16_t t0 = (uint16_t)a->coeffs[2 * i];
    const uint16_t t1 = (uint16_t)a->coeffs[2 * i + 1];
    /*
     * t0 and t1 are both < MLKEM_Q, so contain at most 12 bits each of
     * significant data, so these can be packed into 24 bits or exactly
     * 3 bytes, as follows.
     */

    /* Least significant bits 0 - 7 of t0. */
    r[3 * i + 0] = (uint8_t)(t0 & 0xFF);

    /*
     * Most significant bits 8 - 11 of t0 become the least significant
     * nibble of the second byte. The least significant 4 bits
     * of t1 become the upper nibble of the second byte.
     *
     * The conversion to uint8_t does not alter the value.
     */
    r[3 * i + 1] = (uint8_t)((t0 >> 8) | ((t1 << 4) & 0xF0));

    /* Bits 4 - 11 of t1 become the third byte. The conversion to uint8_t
     * does not alter the value because t1 is 12-bit wide. */
    r[3 * i + 2] = (uint8_t)(t1 >> 4);
  }
}
