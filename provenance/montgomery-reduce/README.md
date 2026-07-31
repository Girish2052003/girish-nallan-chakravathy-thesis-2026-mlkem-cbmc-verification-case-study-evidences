# Montgomery Campaign Provenance

The base worktree is preserved as the structural source snapshot. The T3 and T4 worktrees are represented as deltas: only files that are new or changed at the same relative path are retained. Identical same-path source files are recorded in the duplicate ledger rather than copied again.

Worktree `.git` pointer files are quarantined as ordinary text under `quarantined-git-pointers/` so they cannot create nested Git worktree behaviour inside the evidence repository.
