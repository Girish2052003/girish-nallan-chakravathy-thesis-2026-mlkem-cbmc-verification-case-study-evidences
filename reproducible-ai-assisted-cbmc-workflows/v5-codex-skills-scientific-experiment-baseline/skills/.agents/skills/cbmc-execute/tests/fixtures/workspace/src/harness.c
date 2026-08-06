#include <assert.h>
#include "demo.h"
int main(void) {
  int x;
  assert(add_one(x) == x + 1);
  return 0;
}
