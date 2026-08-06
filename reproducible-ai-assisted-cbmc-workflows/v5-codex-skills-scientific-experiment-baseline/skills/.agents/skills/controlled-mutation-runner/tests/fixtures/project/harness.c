#include "math_ops.h"
int main(void)
{
  int value = compute(2, 1);
  __CPROVER_assert(value == 3, "compute property");
  return 0;
}
