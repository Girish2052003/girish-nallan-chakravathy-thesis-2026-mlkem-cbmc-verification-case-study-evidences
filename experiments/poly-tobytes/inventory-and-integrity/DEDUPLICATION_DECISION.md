# Deduplication and preservation decision

## Inventory-first result

- Original regular files: **3,839**
- Distinct SHA-256 contents: **1,899**
- Exact-duplicate SHA-256 groups: **489**
- Additional duplicate path instances: **1,940**
- Empty log/result files: **406**
- Theoretical byte saving from unsafe global path deletion: **79,537,945 bytes**

## Decision

No global content-hash deletion was applied. The duplicate ledger is complete,
but repeated bytes were retained when their paths belong to different raw runs,
mutation cases, closure packets, source examples, or supplied SHA-256 manifests.
Deleting those paths would make the published evidence tree less faithful and
can invalidate path-based review even though the bytes exist elsewhere.

This is intentional scientific deduplication: one source worktree is retained,
transport archives are isolated under `99-release-bundles/`, the outer ZIP
wrapper is removed, and dangerous nested Git metadata is neutralised without
changing its bytes. Exact-content repetition remains only where provenance or
packet completeness requires it.

For every repeated hash and path, see `EXACT_DUPLICATE_INSTANCES.tsv`.
