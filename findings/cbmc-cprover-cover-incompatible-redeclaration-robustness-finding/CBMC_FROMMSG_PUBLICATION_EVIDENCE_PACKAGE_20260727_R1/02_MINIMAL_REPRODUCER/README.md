# Minimal reproducer commands

Canonical control:

```sh
cbmc 01_canonical.c --function main --cover cover
```

Malformed `_Bool` declaration:

```sh
cbmc 02_wrong_bool.c --function main --cover cover
```

Malformed `int` declaration:

```sh
cbmc 03_wrong_int.c --function main --cover cover
```

Also test the malformed variants with `--show-test-suite`; the official-release evidence shows that this flag is not required for the internal invariant.
