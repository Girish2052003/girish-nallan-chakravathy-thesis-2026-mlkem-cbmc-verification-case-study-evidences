# Test suite

Run from the skill root:

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

The fixtures are synthetic and intentionally do not reproduce FIPS 203 text. They test retrieval mechanics, not cryptographic correctness.
