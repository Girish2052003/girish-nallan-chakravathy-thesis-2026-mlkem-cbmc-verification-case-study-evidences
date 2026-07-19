/*
 * PA-07 controlled mutant implementations for mlk_poly_add.
 *
 * IMPORTANT:
 *   This file is not production source and must never replace or modify
 *   mlkem/src/poly.c. The PA-07 runner compiles it only into temporary
 *   CBMC GOTO models.
 *
 * Compile with exactly one mutation identifier:
 *
 *   PA07_MUTATION_ID=1  addition replaced by subtraction
 *   PA07_MUTATION_ID=2  loop starts at coefficient 1
 *   PA07_MUTATION_ID=3  final coefficient is skipped
 *   PA07_MUTATION_ID=4  only the first half is processed
 *   PA07_MUTATION_ID=5  result is written into b instead of r
 *
 * Target repository commit:
 *   d9613cf60de3132d32475c102d8c2781d84feb34
 */

#include <stdint.h>

#include "mlkem/src/poly.h"

#ifndef PA07_MUTATION_ID
#error PA07_MUTATION_ID must be defined
#endif

#if PA07_MUTATION_ID < 1 || PA07_MUTATION_ID > 5
#error PA07_MUTATION_ID must be between 1 and 5
#endif

void mlk_poly_add(mlk_poly *r, const mlk_poly *b)
{
  unsigned i;

#if PA07_MUTATION_ID == 1

  /*
   * M1 — arithmetic operator mutation:
   *      + is replaced by -.
   */
  for (i = 0; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] - b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 2

  /*
   * M2 — lower-bound mutation:
   *      processing begins at coefficient 1, leaving coefficient 0
   *      unchanged.
   */
  for (i = 1; i < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 3

  /*
   * M3 — upper-bound mutation:
   *      coefficient MLKEM_N-1 is never processed.
   */
  for (i = 0; i + 1u < MLKEM_N; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 4

  /*
   * M4 — truncation mutation:
   *      only the first half of the polynomial is processed.
   */
  for (i = 0; i < MLKEM_N / 2u; i++)
  {
    r->coeffs[i] =
        (int16_t)(r->coeffs[i] + b->coeffs[i]);
  }

#elif PA07_MUTATION_ID == 5

  /*
   * M5 — destination mutation:
   *      the computed result is written into the read-only operand b
   *      rather than into the accumulator r.
   *
   * The harness objects themselves are not declared const. The cast is
   * used only to model this deliberate wrong-destination implementation.
   */
  {
    mlk_poly *mutable_b;

    mutable_b = (mlk_poly *)b;

    for (i = 0; i < MLKEM_N; i++)
    {
      mutable_b->coeffs[i] =
          (int16_t)(r->coeffs[i] + b->coeffs[i]);
    }
  }

#endif
}
