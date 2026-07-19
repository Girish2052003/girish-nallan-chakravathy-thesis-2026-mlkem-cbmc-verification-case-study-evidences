/* SUB-T6 positive harness: T6.4. */
#include "sub00r_b6_harness_common.h"

int main(void)
{
  mlk_poly v;
  mlk_poly sb;
  mlk_poly v_before;
  mlk_poly sb_before;
  mlk_poly sb_witness;
  mlk_poly guard;
  mlk_poly guard_before;
  unsigned i;

  sub_t6_check_machine_model();
  sub_t6_assume_callsite_inputs(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    guard.coeffs[i] = (int16_t)(255 - (int)i);
  }

  v_before = v;
  sb_before = sb;
  sb_witness = sb_before;
  guard_before = guard;

  mlk_poly_sub(&v, &sb);

  for (i = 0u; i < MLKEM_N; i++)
  {
    int32_t expected;

    expected = (int32_t)v_before.coeffs[i] -
               (int32_t)sb_before.coeffs[i];

    __CPROVER_assert((int32_t)v.coeffs[i] == expected,
                     "SUB_T6_T6_4_ANCHOR: production subtraction must be exact");
    __CPROVER_assert(sb.coeffs[i] == sb_before.coeffs[i],
                     "SUB_T6_T6_4_SB: source sb must remain unchanged");
    __CPROVER_assert(sb_before.coeffs[i] == sb_witness.coeffs[i],
                     "SUB_T6_T6_4_SNAPSHOT: saved sb snapshot must remain unchanged");
    __CPROVER_assert(guard.coeffs[i] == guard_before.coeffs[i],
                     "SUB_T6_T6_4_GUARD: unrelated caller-owned guard must remain unchanged");
  }

  return 0;
}
