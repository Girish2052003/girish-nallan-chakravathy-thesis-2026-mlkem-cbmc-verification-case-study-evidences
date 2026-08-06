/* SA-ZERO-T2: recovery after symbolic subrange recontamination. */
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
  uint8_t host[SA_ZERO_HOST_BYTES];
  uint8_t original[SA_ZERO_HOST_BYTES];
  uint8_t before_second[SA_ZERO_HOST_BYTES];
  size_t outer_offset;
  size_t outer_length;
  size_t outer_end;
  size_t relative_offset;
  size_t repair_length;
  size_t repair_start;
  size_t repair_end;
  unsigned i;
  unsigned target_calls;
  int assumptions_feasible;
  int initial_nonzero;
  int target_1_reached;
  int recontamination_reached;
  int recontamination_nonzero;
  int target_2_reached;
  int assertion_block_reached;

  outer_offset = nondet_size();
  outer_length = nondet_size();
  relative_offset = nondet_size();
  repair_length = nondet_size();
  __CPROVER_assume(outer_offset < SA_ZERO_HOST_BYTES);
  __CPROVER_assume(outer_length >= 1U);
  __CPROVER_assume(outer_length <= SA_ZERO_HOST_BYTES - outer_offset);
  __CPROVER_assume(relative_offset < outer_length);
  __CPROVER_assume(repair_length >= 1U);
  __CPROVER_assume(repair_length <= outer_length - relative_offset);

  outer_end = outer_offset + outer_length;
  repair_start = outer_offset + relative_offset;
  repair_end = repair_start + repair_length;

  for (i = 0U; i < SA_ZERO_HOST_BYTES; i++)
  {
    host[i] = nondet_u8();
    original[i] = host[i];
  }
  __CPROVER_assume(host[outer_offset] != 0U);

  target_calls = 0U;
  assumptions_feasible = 1;
  initial_nonzero = (host[outer_offset] != 0U);
  target_1_reached = 0;
  recontamination_reached = 0;
  recontamination_nonzero = 0;
  target_2_reached = 0;
  assertion_block_reached = 0;
  SA_COVER(assumptions_feasible, "SA_ZERO_T2_ASSUMPTIONS_FEASIBLE");
  SA_COVER(initial_nonzero, "SA_ZERO_T2_INITIAL_NONZERO_WITNESS");

  mlk_zeroize(host + outer_offset, outer_length);
  target_calls++;
  target_1_reached = (target_calls == 1U);
  SA_COVER(target_1_reached, "SA_ZERO_T2_TARGET_1_REACHED");
  __CPROVER_assert(host[outer_offset] == 0U, "SA_ZERO_T2_FIRST_ERASURE_WITNESS_ZERO");

  for (i = 0U; i < SA_ZERO_HOST_BYTES; i++)
    if (((size_t)i >= repair_start) && ((size_t)i < repair_end))
      host[i] = nondet_u8();
  __CPROVER_assume(host[repair_start] != 0U);
  recontamination_reached = 1;
  recontamination_nonzero = (host[repair_start] != 0U);
  SA_COVER(recontamination_reached, "SA_ZERO_T2_RECONTAMINATION_REACHED");
  SA_COVER(recontamination_nonzero, "SA_ZERO_T2_NONZERO_RECONTAMINATION_WITNESS");

  for (i = 0U; i < SA_ZERO_HOST_BYTES; i++)
    before_second[i] = host[i];

  mlk_zeroize(host + repair_start, repair_length);
  target_calls++;
  target_2_reached = (target_calls == 2U);
  SA_COVER(target_2_reached, "SA_ZERO_T2_TARGET_2_REACHED");

  assertion_block_reached = 1;
  SA_COVER(assertion_block_reached, "SA_ZERO_T2_ASSERTION_BLOCK_REACHED");
  __CPROVER_assert(target_calls == 2U, "SA_ZERO_T2_TARGET_CALL_COUNT");

  for (i = 0U; i < SA_ZERO_HOST_BYTES; i++)
  {
    if (((size_t)i >= outer_offset) && ((size_t)i < outer_end))
      __CPROVER_assert(host[i] == 0U, "SA_ZERO_T2_OUTER_INTERVAL_FULL_RECOVERY");
    else
      __CPROVER_assert(host[i] == original[i], "SA_ZERO_T2_ORIGINAL_OUTER_FRAME_PRESERVED");

    if (((size_t)i < repair_start) || ((size_t)i >= repair_end))
      __CPROVER_assert(host[i] == before_second[i], "SA_ZERO_T2_SECOND_CALL_FRAME_PRESERVED");
  }

  __CPROVER_assert(before_second[repair_start] != 0U, "SA_ZERO_T2_RECONTAMINATION_WITNESS_WAS_NONZERO");
  __CPROVER_assert(host[repair_start] == 0U, "SA_ZERO_T2_RECONTAMINATION_WITNESS_REERASED");
#ifdef SKILL_FAIL_CONTROL
  __CPROVER_assert(host[repair_start] != 0U, "SA_ZERO_T2_FC_RECONTAMINATION_PERSISTS");
#endif
  return 0;
}
