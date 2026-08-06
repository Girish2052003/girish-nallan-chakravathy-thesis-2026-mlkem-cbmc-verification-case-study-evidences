/* SA-ZERO-T1: whole-object secret-history convergence. */
#include <stddef.h>
#include <stdint.h>
#include "mlkem/src/verify.h"

#define SA_ZERO_HOST_BYTES 16U
#ifdef SKILL_COVER_MODE
#define SA_COVER(c, id) __CPROVER_assert(!(c), id)
#else
#define SA_COVER(c, id) ((void)(c))
#endif

static uint8_t nondet_u8(void) { uint8_t x; return x; }
static size_t nondet_size(void) { size_t x; return x; }

int main(void)
{
  uint8_t left[SA_ZERO_HOST_BYTES];
  uint8_t right[SA_ZERO_HOST_BYTES];
  uint8_t left_before[SA_ZERO_HOST_BYTES];
  uint8_t right_before[SA_ZERO_HOST_BYTES];
  size_t offset;
  size_t length;
  size_t end;
  unsigned i;
  unsigned target_calls;
  int assumptions_feasible;
  int difference_witness;
  int target_1_reached;
  int target_2_reached;
  int assertion_block_reached;

  offset = nondet_size();
  length = nondet_size();
  __CPROVER_assume(offset < SA_ZERO_HOST_BYTES);
  __CPROVER_assume(length >= 1U);
  __CPROVER_assume(length <= SA_ZERO_HOST_BYTES - offset);
  end = offset + length;

  for (i = 0U; i < SA_ZERO_HOST_BYTES; i++)
  {
    left[i] = nondet_u8();
    right[i] = nondet_u8();
    if (((size_t)i < offset) || ((size_t)i >= end))
      right[i] = left[i];
    left_before[i] = left[i];
    right_before[i] = right[i];
  }
  __CPROVER_assume(left[offset] != right[offset]);

  target_calls = 0U;
  assumptions_feasible = 1;
  difference_witness = (left[offset] != right[offset]);
  target_1_reached = 0;
  target_2_reached = 0;
  assertion_block_reached = 0;
  SA_COVER(assumptions_feasible, "SA_ZERO_T1_ASSUMPTIONS_FEASIBLE");
  SA_COVER(difference_witness, "SA_ZERO_T1_NONTRIVIAL_SECRET_DIFFERENCE");

  mlk_zeroize(left + offset, length);
  target_calls++;
  target_1_reached = (target_calls == 1U);
  SA_COVER(target_1_reached, "SA_ZERO_T1_TARGET_1_REACHED");

  mlk_zeroize(right + offset, length);
  target_calls++;
  target_2_reached = (target_calls == 2U);
  SA_COVER(target_2_reached, "SA_ZERO_T1_TARGET_2_REACHED");

  assertion_block_reached = 1;
  SA_COVER(assertion_block_reached, "SA_ZERO_T1_ASSERTION_BLOCK_REACHED");
  __CPROVER_assert(target_calls == 2U, "SA_ZERO_T1_TARGET_CALL_COUNT");

  for (i = 0U; i < SA_ZERO_HOST_BYTES; i++)
  {
    if (((size_t)i >= offset) && ((size_t)i < end))
    {
      __CPROVER_assert(left[i] == 0U, "SA_ZERO_T1_LEFT_SELECTED_BYTES_ZERO");
      __CPROVER_assert(right[i] == 0U, "SA_ZERO_T1_RIGHT_SELECTED_BYTES_ZERO");
    }
    else
    {
      __CPROVER_assert(left[i] == left_before[i], "SA_ZERO_T1_LEFT_OUTER_FRAME_PRESERVED");
      __CPROVER_assert(right[i] == right_before[i], "SA_ZERO_T1_RIGHT_OUTER_FRAME_PRESERVED");
    }
    __CPROVER_assert(left[i] == right[i], "SA_ZERO_T1_WHOLE_OBJECT_SECRET_HISTORY_CONVERGENCE");
  }

#ifdef SKILL_FAIL_CONTROL
  __CPROVER_assert(left[offset] != right[offset], "SA_ZERO_T1_FC_SECRET_DIFFERENCE_PERSISTS");
#endif
  return 0;
}
