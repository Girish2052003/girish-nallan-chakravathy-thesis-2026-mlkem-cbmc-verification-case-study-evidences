#!/usr/bin/env bash
set -euo pipefail
umask 022

ROOT="${ROOT:-$HOME/THESIS-2026}"
REPO="${REPO:-$ROOT/mlkem-native_af4c5abd}"
EXPECTED_COMMIT="${EXPECTED_COMMIT:-af4c5abdd5958bdc65a03cd5ee86708264f93304}"

FREEZE="${FREEZE:-$ROOT/mlk_poly_frombytes_cleanroom/PFB_00C_THEOREM_FREEZE_af4c5abd}"
OUT="${OUT:-/tmp/PFB_00C_THEOREM_FREEZE.txt}"
FROZEN_AT_UTC="${FROZEN_AT_UTC:-$(date -u +%Y%m%dT%H%M%SZ)}"

export FREEZE FROZEN_AT_UTC

SOURCE_FILES=(
  mlkem/src/compress.c
  mlkem/src/compress.h
  mlkem/src/params.h
)

required_commands=(
  git sha256sum cbmc goto-cc goto-instrument cc python3
  find sort xargs tee awk sed
)

for cmd in "${required_commands[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'MISSING_REQUIRED_COMMAND=%s\n' "$cmd" >&2
    exit 1
  fi
done

if ! git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "AUTHORITATIVE_REPOSITORY_NOT_FOUND=$REPO" >&2
  exit 1
fi

cd "$REPO"

for source_file in "${SOURCE_FILES[@]}"; do
  if [ ! -f "$source_file" ]; then
    echo "REQUIRED_SOURCE_FILE_NOT_FOUND=$REPO/$source_file" >&2
    exit 1
  fi
done

exec > >(tee "$OUT") 2>&1

echo "============================================================"
echo "PFB-00C — POLY_FROMBYTES THEOREM FREEZE"
echo "============================================================"

echo
echo "============================================================"
echo "PART 1 — AUTHORITATIVE SOURCE RE-BINDING"
echo "============================================================"

echo "PWD=$(pwd)"
echo "HEAD=$(git rev-parse HEAD)"
echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
echo "TREE=$(git rev-parse HEAD^{tree})"

test "$(git rev-parse HEAD)" = "$EXPECTED_COMMIT"

if [ -n "$(git status --porcelain=v1)" ]; then
  echo "AUTHORITATIVE_TREE_CLEAN=NO"
  git status --porcelain=v1
  exit 1
else
  echo "AUTHORITATIVE_TREE_CLEAN=YES"
fi

if [ -e "$FREEZE" ]; then
  echo "FREEZE_DIRECTORY_ALREADY_EXISTS=$FREEZE"
  echo "REFUSING_TO_OVERWRITE=YES"
  exit 1
fi

mkdir -p \
  "$FREEZE/registry" \
  "$FREEZE/input_evidence" \
  "$FREEZE/source_binding"

echo
echo "============================================================"
echo "PART 2 — COPY DISCOVERY EVIDENCE"
echo "============================================================"

for FILE in \
  /tmp/PFB_00B1_DEPENDENCY_OVERLAP_COMPLETION.txt \
  /tmp/PFB_00B2_PRECISION_PRIOR_OVERLAP_AUDIT.txt
do
  if [ -f "$FILE" ]; then
    cp "$FILE" "$FREEZE/input_evidence/"
    echo "COPIED_EVIDENCE=$FILE"
  else
    echo "EVIDENCE_NOT_PRESENT=$FILE"
  fi
done

cat > "$FREEZE/registry/PFB_THEOREM_REGISTRY_V1.md" <<'EOF_REGISTRY'
# PFB Theorem Registry V1

## Frozen target

- Campaign: PFB
- Public target: `mlk_poly_frombytes`
- Portable body: `mlk_poly_frombytes_c`
- Source commit: `af4c5abdd5958bdc65a03cd5ee86708264f93304`
- Initial configuration: portable ML-KEM-768
- Core theorem families: 4
- Primary semantic obligations: 11
- Native semantic claim: excluded

## Independent arithmetic notation

For block `i`:

```text
W[i] =
    a[3*i]
  + 256*a[3*i + 1]
  + 65536*a[3*i + 2]

even(i) = W[i] mod 4096
odd(i)  = floor(W[i] / 4096)

pack12(x,y) = x + 4096*y
```

The oracle shall use widened arithmetic, division and remainder. It shall not
call `mlk_poly_frombytes`, `mlk_poly_frombytes_c`, or copy the production
shift-and-mask expression.

## PFB-T1 — Exact raw-decoding semantics

1. **PFB-T1.P1** — For every block `i`, output coefficient `2*i` equals
   `W[i] mod 4096`.
2. **PFB-T1.P2** — For every block `i`, output coefficient `2*i+1` equals
   `floor(W[i] / 4096)`.

Supporting lemma, not separately counted:

```text
r[2*i] + 4096*r[2*i+1] = W[i]
```

## PFB-T2 — Exact single-bit influence and block locality

1. **PFB-T2.P1** — Flipping bit `j` of the first byte toggles exactly bit `j`
   of the even coefficient.
2. **PFB-T2.P2** — Flipping low-nibble bit `j` of the second byte toggles
   exactly even-coefficient bit `8+j`.
3. **PFB-T2.P3** — Flipping high-nibble bit `j` of the second byte toggles
   exactly odd-coefficient bit `j`.
4. **PFB-T2.P4** — Flipping bit `j` of the third byte toggles exactly
   odd-coefficient bit `4+j`.
5. **PFB-T2.P5** — Arbitrarily changing one three-byte block leaves every
   other coefficient pair unchanged.

## PFB-T3 — Arbitrary differential conservation

1. **PFB-T3.P1** — For a selected block and two arbitrary inputs, the XOR of
   the packed output pairs equals the XOR of the corresponding 24-bit input
   words.
2. **PFB-T3.P2** — For every block, the three input bytes differ if and only
   if the corresponding output coefficient pair differs.

Full-array injectivity is a supporting consequence and is not separately
counted.

## PFB-T4 — Full raw-domain inverse and bijection

The independent raw encoder is defined for `0 <= x,y < 4096` as:

```text
c0 = x mod 256
c1 = floor(x / 256) + 16*(y mod 16)
c2 = floor(y / 16)
```

It shall not call production `mlk_poly_tobytes`.

1. **PFB-T4.P1** — For every arbitrary 384-byte array, independently
   raw-encoding the real decoded polynomial reproduces all original bytes.
2. **PFB-T4.P2** — For every raw polynomial with coefficients in `[0,4096)`,
   real decoding of its independent raw encoding reproduces all coefficients.

## Count

* T1: 2
* T2: 5
* T3: 2
* T4: 2
* Total: 11
EOF_REGISTRY

cat > "$FREEZE/registry/PFB_SCOPE_AND_NONCLAIMS_V1.md" <<'EOF_SCOPE'
# PFB Scope and Nonclaims V1

## Proof target

Positive semantic harnesses shall call the public `mlk_poly_frombytes`
wrapper in a portable configuration whose GOTO call graph reaches the real
`mlk_poly_frombytes_c` body.

Calling only the file-local portable body and claiming public-wrapper
correctness is prohibited.

## Permitted assumptions

* Input is a valid local 384-byte array.
* Output is a valid local `mlk_poly` object.
* Input and output do not alias.
* Selected block and bit indices are in their recorded ranges.
* T2 inputs satisfy only their declared differential relation.
* T4.P2 raw coefficients lie in `[0,4096)`.

No canonical-below-q assumption is permitted for T1, T2, T3, or T4.P1.

## Forbidden proof transformations

* No production-source modification in positive theorem runs.
* No contract replacement of `mlk_poly_frombytes`.
* No contract replacement of `mlk_poly_frombytes_c`.
* No native backend silently selected.
* No target stubbing or body removal.
* No target function call inside an independent oracle.
* No production `mlk_poly_tobytes` used as the T4 raw encoder.
* No production shift-and-mask expression copied into the T1 oracle.
* No assumption of the expected output relation.
* No contradictory, result-shaped, or vacuous assumptions.
* No generic frame, determinism, or safety property counted as a new family.

## Mandatory assurance controls

* Exact commit, tree and source-hash binding.
* GOTO call-graph binding.
* Public-wrapper and portable-body reachability.
* Complete loop unwinding.
* Unwinding assertions.
* Bounds, pointer, overflow, conversion and shift checks.
* Assertion reachability.
* Boundary-value reachability.
* Input-frame preservation.
* Output canaries.
* Complete output overwrite.
* Nonconstant-output witnesses.
* Targeted source-mutation sensitivity.
* Deterministic evidence and hash freezing.

## Cross-campaign controls, not primary PFB claims

* Canonical round trips.
* Production normalization correctness.
* Normalization idempotence.
* Representative multiplicity.
* Same-residue quotient equivalence.
* Canonical encoder-image characterization.

## Nonclaims

* Native AArch64 or x86-64 semantic correctness.
* Constant-time execution or side-channel resistance.
* Correctness of production `mlk_poly_tobytes`.
* Correctness of `mlk_poly_reduce`.
* Complete FIPS ByteDecode12 refinement including modular normalization.
* Complete ML-KEM correctness.
* Mathematical or worldwide first-ever novelty.
EOF_SCOPE

cat > "$FREEZE/registry/PFB_OVERLAP_DECISION_V1.md" <<'EOF_OVERLAP'
# PFB Prior-Campaign Overlap Decision V1

## Retained as primary PFB obligations

* Exact real-decoder even-field semantics.
* Exact real-decoder odd-field semantics.
* Four exact input-bit routing directions.
* Arbitrary one-block locality.
* Arbitrary differential conservation.
* Exact changed-block support.
* Full raw-domain right inverse.
* Full raw-domain left inverse.

## Supporting lemmas only

* 24-bit conservation identity.
* Complete vector equality as the aggregate of T1.P1 and T1.P2.
* Full-array injectivity.
* Unique raw-domain preimage.
* Complete 3072-bit information preservation.

## Rejected as duplicate primary claims

* One-subtraction canonicalization.
* Scalar or composition idempotence.
* Canonical representative collision necessity or sufficiency.
* Barrett quotient-cell characterization.
* Canonical encoder-image characterization.
* Canonical polynomial injectivity.
* Canonical round trips.
* Quotient-equivalence classes after normalization.

## Novelty boundary

The PFB contribution is repository-level semantic and relational CBMC evidence
for the real public decoder over the complete raw 12-bit domain. It does not
claim new ByteDecode mathematics or worldwide first-ever formal verification.
EOF_OVERLAP

python3 - <<'PY'
import json
import os
from pathlib import Path

freeze = Path(os.environ["FREEZE"])

intent = {
    "schema": "PFB-verification-intent-v1",
    "campaign": "PFB",
    "frozen_at_utc": os.environ["FROZEN_AT_UTC"],
    "source_commit": "af4c5abdd5958bdc65a03cd5ee86708264f93304",
    "target_public_function": "mlk_poly_frombytes",
    "portable_body": "mlk_poly_frombytes_c",
    "initial_configuration": "portable ML-KEM-768",
    "native_backend": "excluded",
    "theorem_family_count": 4,
    "primary_obligation_count": 11,
    "families": {
        "PFB-T1": [
            "PFB-T1.P1",
            "PFB-T1.P2",
        ],
        "PFB-T2": [
            "PFB-T2.P1",
            "PFB-T2.P2",
            "PFB-T2.P3",
            "PFB-T2.P4",
            "PFB-T2.P5",
        ],
        "PFB-T3": [
            "PFB-T3.P1",
            "PFB-T3.P2",
        ],
        "PFB-T4": [
            "PFB-T4.P1",
            "PFB-T4.P2",
        ],
    },
    "primary_novelty_classification": (
        "repository-level semantic and relational CBMC obligations"
    ),
    "independent_oracle_rules": [
        "T1 uses widened arithmetic, division, and remainder",
        "no oracle calls mlk_poly_frombytes or mlk_poly_frombytes_c",
        "T4 uses an independent raw encoder over [0,4096)",
        "T4 does not call production mlk_poly_tobytes",
        "no oracle assumes the expected output relationship",
    ],
    "cross_campaign_controls_not_primary": [
        "canonical round trip",
        "production normalization",
        "normalization idempotence",
        "representative multiplicity",
        "same-residue quotient equivalence",
        "canonical encoder-image characterization",
    ],
    "mathematical_world_first_claim": False,
}

path = freeze / "registry" / "verification_intent.json"
path.write_text(
    json.dumps(intent, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)
PY

{
  echo "SCHEMA=PFB-source-binding-v1"
  echo "FROZEN_AT_UTC=$FROZEN_AT_UTC"
  echo "PWD=$(pwd)"
  echo "HEAD=$(git rev-parse HEAD)"
  echo "TREE=$(git rev-parse HEAD^{tree})"
  echo "AUTHORITATIVE_TREE_STATUS_COUNT=$(git status --porcelain=v1 | wc -l)"

  echo
  echo "GIT_BLOB_IDENTITIES"
  git ls-tree HEAD -- \
    "${SOURCE_FILES[@]}"

  echo
  echo "SHA256_IDENTITIES"
  sha256sum \
    "${SOURCE_FILES[@]}"

  echo
  echo "TOOL_ENVIRONMENT"
  cbmc --version
  goto-cc --version
  goto-instrument --version
  cc --version | sed -n '1,4p'
  python3 --version
} > "$FREEZE/source_binding/SOURCE_IDENTITY.txt"

cat > "$FREEZE/PFB_00C_FREEZE_REPORT.txt" <<EOF_REPORT
PFB_00C_STATUS=FROZEN
FROZEN_AT_UTC=$FROZEN_AT_UTC
SOURCE_COMMIT=$EXPECTED_COMMIT
SOURCE_TREE=$(git rev-parse HEAD^{tree})
AUTHORITATIVE_TREE_STATUS_COUNT=$(git status --porcelain=v1 | wc -l)
THEOREM_FAMILY_COUNT=4
PRIMARY_OBLIGATION_COUNT=11
NATIVE_BACKEND_CLAIM=EXCLUDED
HARNESS_CREATED=NO
CBMC_SEMANTIC_PROOF_EXECUTED=NO
PRODUCTION_SOURCE_MODIFIED=NO
FREEZE_DIRECTORY=$FREEZE
EOF_REPORT

(
  cd "$FREEZE"

  find . \
    -type f \
    ! -name SHA256SUMS.txt \
    -print0 \
  | sort -z \
  | xargs -0 sha256sum \
  > SHA256SUMS.txt
)

echo
echo "============================================================"
echo "PART 3 — FROZEN FILE INVENTORY"
echo "============================================================"

find "$FREEZE" -type f -printf '%P\n' | sort

echo
echo "============================================================"
echo "PART 4 — FROZEN CONTENT"
echo "============================================================"

for FILE in \
  "$FREEZE/registry/PFB_THEOREM_REGISTRY_V1.md" \
  "$FREEZE/registry/PFB_SCOPE_AND_NONCLAIMS_V1.md" \
  "$FREEZE/registry/PFB_OVERLAP_DECISION_V1.md" \
  "$FREEZE/registry/verification_intent.json" \
  "$FREEZE/source_binding/SOURCE_IDENTITY.txt" \
  "$FREEZE/PFB_00C_FREEZE_REPORT.txt" \
  "$FREEZE/SHA256SUMS.txt"
do
  echo
  echo "------------------------------------------------------------"
  echo "FILE=$FILE"
  echo "SHA256=$(sha256sum "$FILE" | awk '{print $1}')"
  echo "------------------------------------------------------------"
  cat "$FILE"
done

echo
echo "============================================================"
echo "PFB-00C RESULT"
echo "============================================================"

echo "HEAD=$(git rev-parse HEAD)"
echo "TREE=$(git rev-parse HEAD^{tree})"
echo "AUTHORITATIVE_TREE_STATUS_COUNT=$(git status --porcelain=v1 | wc -l)"
echo "FREEZE_DIRECTORY=$FREEZE"
echo "THEOREM_FAMILY_COUNT=4"
echo "PRIMARY_OBLIGATION_COUNT=11"
echo "SHA256SUMS_SHA256=$(sha256sum "$FREEZE/SHA256SUMS.txt" | awk '{print $1}')"
echo "OUTPUT_FILE=$OUT"

echo
echo "============================================================"
echo "PFB-00C COMPLETE"
echo "THEOREM REGISTRY FROZEN"
echo "NO HARNESS CREATED"
echo "NO CBMC SEMANTIC PROOF EXECUTED"
echo "NO PRODUCTION SOURCE MODIFIED"
echo "============================================================"
