#include <stddef.h>
#include <stdint.h>

#include "src/verify.h"

#define ZERO_T1_HOST_BYTES 16u

size_t nondet_size_t(void);
uint8_t nondet_uint8_t(void);

void harness(void)
{
  uint8_t buffer[ZERO_T1_HOST_BYTES];

  size_t offset;
  size_t length;
  size_t end;
  size_t witness;
  size_t i;

  uint8_t before;

  for (i = 0u; i < ZERO_T1_HOST_BYTES; i++)
  {
    buffer[i] = nondet_uint8_t();
  }

  offset = nondet_size_t();
  length = nondet_size_t();
  witness = nondet_size_t();

  __CPROVER_assume(offset < ZERO_T1_HOST_BYTES);
  __CPROVER_assume(length > 0u);
  __CPROVER_assume(length <= ZERO_T1_HOST_BYTES - offset);

  end = offset + length;

  __CPROVER_assume(witness >= offset);
  __CPROVER_assume(witness < end);

  before = buffer[witness];

  __CPROVER_assume(before != 0u);

  mlk_zeroize(&buffer[offset], length);

  /*
   * Intentionally false. The selected nonzero byte cannot retain its
   * previous value after exact zeroization.
   */
  __CPROVER_assert(
      buffer[witness] == before,
      "ZERO-T1.FAIL-CONTROL: selected nonzero byte is falsely claimed retained");
}
