/*
 * DETERMINISTIC ADVISORY TEMPLATE ONLY — DO NOT TREAT AS AUTHORITATIVE.
 * This file is stored as deterministic/prohibited-copy reference material.
 * The LLM must independently generate an artefact plan from primary evidence.
 *
 * Target function: mlk_poly_add
 * Candidate property: Array-index safety for coefficient-wise in-place addition loop
 */

#include <assert.h>
#include <stdint.h>
#include "params.h"
#include "poly.h"

void harness(void)
{
  /*
   * Advisory sketch only:
   * - allocate target inputs using real implementation types,
   * - state explicit assumptions,
   * - snapshot old state before in-place mutation,
   * - call mlk_poly_add,
   * - assert the selected local property.
   *
   * This template intentionally omits final assertions because Agent 5's
   * authoritative plan must be produced by the LLM and reviewed later.
   */
}
