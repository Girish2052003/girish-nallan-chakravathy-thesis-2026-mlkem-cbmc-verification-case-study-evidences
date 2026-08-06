#include "vector.h"

extern int nondet_int(void);

int main(void)
{
  int left[4];
  int right[4];
  int result[4];
  int i;

  for (i = 0; i < 4; ++i)
  {
    left[i] = nondet_int();
    right[i] = nondet_int();
  }

  __CPROVER_assume(left[0] >= -100);
  vector_subtract(result, left, right);
  __CPROVER_assert(result[0] == left[0] - right[0], "coefficient zero follows subtraction");
  return 0;
}
