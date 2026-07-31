# POLYCOMP-D4 classified overlay merge guide

This directory is a merge overlay for the existing thesis evidence repository. It contains no `.git` directory and no deletion instructions.

Recommended controlled workflow:

1. Verify the overlay in its extracted directory:

   ```bash
   bash support/development-scripts/verify_polycomp_d4_classification.sh
   ```

2. Run a read-only collision audit against the destination repository before copying.
3. Create a full pre-merge repository backup, including `.git` and untracked files.
4. Merge with `rsync` without `--delete`; refuse or review any existing-path collision.
5. Compare all overlay files to destination files byte-for-byte.
6. Stage only the new POLYCOMP-D4 paths.
7. Audit staged additions, large files, nested Git metadata, symlinks, Git links, and credentials.
8. Commit locally, regenerate repository inventories, reconcile any intentional GitHub-only commits, and push normally without force-pushing.

The authoritative original-to-retained accounting is in `provenance/polycomp-d4-classification/original-to-retained-map.tsv`.
