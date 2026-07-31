#include <stdint.h>

void __CPROVER_cover(_Bool condition);

int main(void)
{
  int16_t r[256];
  uint8_t msg[32];
  uint8_t k;
  uint8_t bit;
  int16_t expected;

  bit = (uint8_t)((msg[(unsigned)k / 8u] >>
                   ((unsigned)k % 8u)) &
                  1u);

  expected = (bit != 0u ? 1665 : 0);

  __CPROVER_cover(1);
  __CPROVER_cover(bit == 0u);
  __CPROVER_cover(bit == 1u);
  __CPROVER_cover(r[(unsigned)k] == expected);

  return 0;
}
