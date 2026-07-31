# Merge guide

This directory is a repository overlay, not a replacement repository.

From the extracted overlay root, copy its contents into the root of the already-created Git repository:

```bash
rsync -a --info=progress2 ./ /path/to/your/existing-repository/
```

Then inspect before committing:

```bash
cd /path/to/your/existing-repository
git status --short
bash support/development-scripts/verify_barrett_reduce_classification.sh
git add docs experiments provenance reports support upstream
git status
git commit -m "Add classified BR-AF4 Barrett-reduction CBMC evidence"
```

Do not delete the existing `poly-add`, `poly-sub`, upstream, or provenance material. This overlay adds a new `experiments/barrett-reduce` sibling campaign and campaign-specific supporting records.
