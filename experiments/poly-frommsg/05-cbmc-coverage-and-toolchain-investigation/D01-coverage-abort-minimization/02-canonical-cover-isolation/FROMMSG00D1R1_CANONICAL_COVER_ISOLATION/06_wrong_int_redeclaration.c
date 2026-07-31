void __CPROVER_cover(int condition);

int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
