int main(void)
{
  int x;
  __CPROVER_cover(x == 0);
  return 0;
}
