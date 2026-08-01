# ML-KEM scalar signed-to-unsigned canonicalization classification audit

## Integrity and inventory

- ZIP integrity: **PASS**
- Archive entries discovered: **53,747**
- Original files SHA-256 inventoried: **43,815**
- Original directories: **9,932**
- Uncompressed file bytes: **463,951,142**
- Unique SHA-256 contents: **1,868**
- Exact duplicate groups: **1,142**
- Duplicate instances beyond the first: **41,947**
- Repeated byte content: **406,106,781 bytes**

## Classification result

- Retained original files: **1,467**
- Omitted high-confidence source/worktree mirrors: **42,348**
- Unclassified files: **0**
- Destination collisions: **0**
- Symlinks: **0**
- Nested `.git` metadata: **0**

The active repository tree retains campaign definitions, source binding,
harnesses, positive runs, final theorem evidence, mutation evidence, proof-only
workspace deltas, frozen family packages, and campaign closure. Full tracked
source mirrors and generated example-local copies are not repeated.

Every omitted file remains byte-for-byte recoverable from:

`provenance/scalar-signed-to-unsigned-q/frozen-baseline/mlk_scalar_signed_to_unsigned_q_cleanroom.zip`

The complete original-to-retained decision for all 43,815 files is in
`provenance/scalar-signed-to-unsigned-q/classification/original-to-retained-map.tsv`.

## Scientific campaign structure

- T1: exact fibres and equivalence classes;
- T2: retraction and normalization stability;
- T3: modular-arithmetic compatibility;
- T4: actual-body Barrett composition and canonicalization;
- campaign closure: supplied final results and claim boundary.

The supplied closure reports 17/17 semantic properties, 41/41 non-vacuity
coverage goals and 12/12 targeted mutants, with all four theorem families
classified as accepted. **This classification process did not independently
rerun CBMC**, so those results are preserved as source-reported evidence rather
than newly reproduced claims.

## Final active layout

```text
experiments/scalar-signed-to-unsigned-q/
├── 00-campaign-setup/
├── T01-exact-fibres-and-equivalence-classes/
├── T02-retraction-and-normalization-stability/
├── T03-modular-arithmetic-compatibility/
├── T04-barrett-composition-and-canonicalization/
└── campaign-closure/

provenance/scalar-signed-to-unsigned-q/
├── classification/
├── frozen-baseline/
├── frozen-family-packages/
└── source-snapshot/
```
