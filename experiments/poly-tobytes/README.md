# `mlk_poly_tobytes` CBMC clean-room evidence

This directory is the add-only GitHub classification of the uploaded
`mlk_poly_tobytes_cleanroom.zip` campaign.

## Frozen target

- Public wrapper: `mlk_poly_tobytes`
- Portable body: `mlk_poly_tobytes_c`
- Source commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Frozen theorem families: 4
- Frozen semantic obligations: 19
- Final family-closure status recorded by the supplied evidence: PASS

## Folder map

- `00-campaign-setup/` — theorem freeze, source identity, scope, verification
  intent, and the single retained mlkem-native source worktree snapshot.
- `T01-exact-arithmetic-byteencode12-refinement/` — PBYTES-T1 positive,
  reachability, validation, unwind, non-vacuity, mutation, and closure evidence.
- `T02-successor-and-carry-transition-partition/` — PBYTES-T2 successor and
  carry-transition evidence.
- `T03-canonical-image-and-invalid-codeword-exclusion/` — PBYTES-T3 canonical
  image and invalid-codeword evidence.
- `T04-arithmetic-recoverability-and-collision-freedom/` — PBYTES-T4
  recoverability and injectivity/collision-freedom evidence.
- `05-complete-19-obligation-closure/` — the supplied index binding all four
  theorem-family closures.
- `99-release-bundles/` — original immutable `.tar.gz` evidence packages and
  their supplied SHA-256 sidecars.
- `inventory-and-integrity/` — original-file inventory, path mapping,
  duplicate ledger, manifest validation, and classified-tree hash manifest.

## Scope boundary

The supplied campaign explicitly excludes native-backend semantic correctness,
constant-time or side-channel correctness, `mlk_poly_frombytes` correctness,
compression/decompression correctness, out-of-domain behaviour, and complete
ML-KEM correctness. The evidence is property-specific and assumption-dependent.

## Preservation rule

No context-bound evidence file was discarded merely because another path had
the same SHA-256 digest. Identical files can legitimately occur in a raw run,
a closure package, and a source snapshot, and the supplied manifests bind those
paths. Git itself stores identical content as shared blob objects.

The only path adaptation is the worktree metadata file:

`PBYTES_01A_WORKTREE_RUN1_af4c5abd/.git`

was retained byte-for-byte as:

`00-campaign-setup/source-snapshot/mlkem-native-af4c5abd/_worktree_git_pointer.txt`

This prevents a nested `.git` pointer from interfering with the parent GitHub
repository while preserving its original evidence bytes and SHA-256 digest.
