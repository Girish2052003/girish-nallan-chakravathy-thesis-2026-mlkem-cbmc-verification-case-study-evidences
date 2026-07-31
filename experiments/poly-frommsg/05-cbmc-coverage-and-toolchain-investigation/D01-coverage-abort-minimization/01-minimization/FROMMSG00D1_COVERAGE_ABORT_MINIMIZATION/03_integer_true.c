void __CPROVER_cover(_Bool condition);

int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
