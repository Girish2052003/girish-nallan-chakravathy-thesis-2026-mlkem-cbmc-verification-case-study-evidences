# Deduplication policy

1. Every original archive file is SHA-256 inventoried before classification.
2. Campaign-stage records, harnesses, manifests, result outputs, mutation
   evidence and run-specific proof artifacts are retained in their scientific
   context, even when an empty or identical output occurs in more than one run.
3. A tracked-source file is omitted from a copied worktree only when its path
   and SHA-256 match the frozen source snapshot.
4. Generated `examples/*/mlkem_native/` source/dependency copies are treated as
   high-confidence build mirrors and are not repeated in the active tree.
5. Files that differ from or are additional to the frozen source snapshot are
   retained as `workspace-delta` evidence, including changed production source,
   proof harnesses, GOTO binaries, build logs and proof logs.
6. Frozen family packages and the complete original ZIP are retained under
   provenance. Therefore, omitted mirrors remain byte-for-byte recoverable.
7. No result was upgraded, corrected or reinterpreted during classification.
