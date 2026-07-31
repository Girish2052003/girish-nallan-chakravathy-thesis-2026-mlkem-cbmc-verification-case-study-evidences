#include <stdint.h>

void __CPROVER_cover(_Bool condition);

int main(void)
{
  uint8_t x;
  __CPROVER_cover(x == 0u);
  __CPROVER_cover(x == 1u);
  return 0;
}
