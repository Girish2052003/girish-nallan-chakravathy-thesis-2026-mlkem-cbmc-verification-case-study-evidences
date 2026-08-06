#include <assert.h>

extern int nondet_int(void);
extern void vector_subtract(int result[4], const int left[4], const int right[4]);

int main(void)
{
  int result[4];
  int left[4];
  int right[4];
  int i = nondet_int();

  /* __CPROVER_assume(0); is only comment text and must be ignored. */
  const char *example = "__CPROVER_assert(0, hidden string)";
  (void)example;

  __CPROVER_assume(i >= 0 && i < 4);
  vector_subtract(result, left, right);
  __CPROVER_assert(result[i] == left[i] - right[i], "component subtraction");
  assert(i < 4);
  return 0;
}
