/* Generated neutral harness scaffold.
 * No assumptions, assertions, properties, contracts, or initializers were inserted.
 * Codex remains responsible for every scientifically meaningful addition.
 */
#include "poly.h"

int main(void)
{
  mlk_poly r;
  mlk_poly a;
  mlk_poly b;

  /* V5_CODEX_INPUT_PREPARATION_BEGIN */
  /* CODEX: insert task-justified input preparation or nondeterministic setup here. */
  /* V5_CODEX_INPUT_PREPARATION_END */

  /* V5_CODEX_ASSUMPTIONS_BEGIN */
  /* CODEX: insert only explicitly justified assumptions here. */
  /* V5_CODEX_ASSUMPTIONS_END */

  /* V5_TARGET_CALL_BEGIN */
  mlk_poly_sub(&r, &a, &b);
  /* V5_TARGET_CALL_END */

  /* V5_CODEX_ASSERTIONS_BEGIN */
  /* CODEX: insert the selected verification property here. */
  /* V5_CODEX_ASSERTIONS_END */

  return 0;
}
