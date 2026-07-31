# Add-only import instructions

From the root of the existing evidence repository:

```bash
unzip PBYTES_GITHUB_CLASSIFIED_ADD_ONLY_2026-07-31.zip

git status --short
find experiments/poly-tobytes -type f | wc -l
sha256sum -c experiments/poly-tobytes/inventory-and-integrity/CLASSIFIED_TREE_SHA256.txt

git add experiments/poly-tobytes
git status --short
```

The archive contains only the new `experiments/poly-tobytes/` subtree. It does
not overwrite `experiments/poly-add/`, `experiments/poly-sub/`, repository-root
documentation, or the existing upstream snapshot.
