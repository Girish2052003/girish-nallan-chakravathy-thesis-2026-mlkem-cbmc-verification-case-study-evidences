# Frozen source binding

```text
Repository: pq-code-package/mlkem-native
Commit:     af4c5abdd5958bdc65a03cd5ee86708264f93304
Tree:       54805daff6a91a010c05467ea678117c42a71559
Target:     mlkem/src/verify.h :: mlk_zeroize
```

The main runner refuses every other commit or tree. Source files are hashed into
the accepted run. Production source is not patched by this package.

Acceptance additionally requires `body_binding.json=PASS` for both theorem models.
