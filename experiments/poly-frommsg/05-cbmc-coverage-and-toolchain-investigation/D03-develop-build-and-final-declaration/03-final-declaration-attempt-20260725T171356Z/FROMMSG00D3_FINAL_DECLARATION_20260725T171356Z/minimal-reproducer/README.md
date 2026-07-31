# Minimal reproducer

Canonical control:

```c
int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
```

Malformed `_Bool` declaration:

```c
void __CPROVER_cover(_Bool condition);

int main(void)
{
  __CPROVER_cover((_Bool)1);
  return 0;
}
```

Malformed `int` declaration:

```c
void __CPROVER_cover(int condition);

int main(void)
{
  __CPROVER_cover(1);
  return 0;
}
```

The investigated behaviour is an internal invariant termination after
`--cover cover`, rather than a controlled incompatible-declaration diagnostic.
