#include "vector.h"

void vector_subtract(int result[4], const int left[4], const int right[4])
{
  int i;
  for (i = 0; i < 4; ++i)
  {
    result[i] = left[i] - right[i];
  }
}
