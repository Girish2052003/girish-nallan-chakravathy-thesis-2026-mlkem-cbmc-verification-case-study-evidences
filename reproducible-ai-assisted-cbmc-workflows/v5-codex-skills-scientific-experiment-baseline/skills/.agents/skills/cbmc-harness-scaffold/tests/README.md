# Test suite

Run from the skill root:

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

The suite covers neutral scaffold generation, syntax-only compilation, source binding, path and symlink containment, code-injection rejection, no-overwrite behavior, compile-failure preservation, schema validation, artefact hashing, and byte-for-byte repeatability at fixed paths.
