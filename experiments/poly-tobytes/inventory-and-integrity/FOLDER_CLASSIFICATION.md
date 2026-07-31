# Folder classification rationale

The supplied theorem registry is the authoritative classification basis.

| GitHub folder | Frozen family | Scientific meaning |
|---|---|---|
| `T01-exact-arithmetic-byteencode12-refinement` | PBYTES-T1 | Exact arithmetic ByteEncode12 refinement, six obligations |
| `T02-successor-and-carry-transition-partition` | PBYTES-T2 | Exact successor and carry-transition partition, four obligations |
| `T03-canonical-image-and-invalid-codeword-exclusion` | PBYTES-T3 | Canonical image and invalid-codeword exclusion, five obligations |
| `T04-arithmetic-recoverability-and-collision-freedom` | PBYTES-T4 | Arithmetic recoverability and collision freedom, four obligations |
| `05-complete-19-obligation-closure` | Family closure | Index and records binding all 19 frozen obligations |

Within each theorem family, `raw-evidence/` contains chronological run packets
and `closure-evidence/` contains the supplied frozen or final family package.
Original packet names are retained to preserve stage identity and source-commit
binding.
