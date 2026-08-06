# Tests

Run from the skill root:

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

The suite uses only synthetic C fixtures. It verifies normal output, strict scientific labels, missing and duplicate targets, source-hash mismatch, no-build warnings, preprocessing through explicit and compile-database modes, byte reproducibility, path isolation, symlink refusal, malformed input, shell-syntax rejection, output overwrite refusal, and unsupported source rejection.

Codex explicit/implicit activation tests are separately defined in `references/INVOCATION_TESTS.md` and remain pending until Codex CLI is installed.
