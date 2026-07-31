void __CPROVER_cover(_Bool condition);

int main(void)
{
  _Bool b;
  __CPROVER_cover(b);
  return 0;
}
