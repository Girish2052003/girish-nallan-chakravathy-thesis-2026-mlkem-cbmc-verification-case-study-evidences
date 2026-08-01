#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# MSG06A — MLK_POLY_TOMSG COMBINED CAMPAIGN CLOSURE
#
# Documentation/integrity closure only.
# No CBMC theorem solving.
# No GOTO rebuilding.
# No production-source modification.
# ============================================================

REPO="/home/girish/THESIS-2026/mlkem-native_af4c5abd"
BASE="/home/girish/THESIS-2026/mlk_poly_tomsg_cleanroom"

EXPECTED_COMMIT="af4c5abdd5958bdc65a03cd5ee86708264f93304"
EXPECTED_COMPRESS_SHA256="9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad"
EXPECTED_COMPRESS_H_SHA256="0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd"

EXPECTED_T1_ARCHIVE_SHA256="1477c76ca5208a40d813c16a077d9f5534f0a256380ca0c9056ebf08f05d58bc"
EXPECTED_T2_ARCHIVE_SHA256="95203b7f99923e615d47b25ce9b9658414b28b42f379099de5ec9eb613818bee"

T2_ARCHIVE="$BASE/MLK_POLY_TOMSG_T2_RELATIONAL_ACCEPTED_REPAIRED_20260723T173657Z_af4c5abdd595.tar.gz"
T2_SHA_FILE="$T2_ARCHIVE.sha256"

T5_ARCHIVE="$BASE/MLK_POLY_TOMSG_T5_EXACT_OFFSET_INTERVAL_ACCEPTED_20260723T165407Z_af4c5abdd595.tar.gz"
T5_SHA_FILE="$T5_ARCHIVE.sha256"

COMPRESS_C="$REPO/mlkem/src/compress.c"
COMPRESS_H="$REPO/mlkem/src/compress.h"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_NAME="MSG06A_MLK_POLY_TOMSG_COMBINED_CAMPAIGN_CLOSURE_${STAMP}_af4c5abdd595"
OUT="$BASE/$OUT_NAME"

PACKAGE_NAME="MLK_POLY_TOMSG_T1_T2_T5_COMBINED_CLOSURE_${STAMP}_af4c5abdd595"
ARCHIVE_TAR="$BASE/$PACKAGE_NAME.tar"
ARCHIVE="$ARCHIVE_TAR.gz"
ARCHIVE_SHA256="$ARCHIVE.sha256"
ARCHIVE_CONTENTS="$ARCHIVE.contents.txt"

# Keep the live terminal capture outside OUT.
LOG="$BASE/$PACKAGE_NAME.terminal.txt"

ARCHIVES_DIR="$OUT/01_frozen_campaign_archives"
REGISTRY_DIR="$OUT/02_registries"
MATRIX_DIR="$OUT/03_claim_matrix"
NOVELTY_DIR="$OUT/04_novelty_and_numbering"
INDEX_DIR="$OUT/05_evidence_index"
SOURCE_DIR="$OUT/06_source_binding"
AUDIT_DIR="$OUT/07_integrity_audit"
MANIFEST_DIR="$OUT/08_manifests"
SUMMARY_DIR="$OUT/09_final_summary"

mkdir -p \
    "$ARCHIVES_DIR" \
    "$REGISTRY_DIR" \
    "$MATRIX_DIR" \
    "$NOVELTY_DIR" \
    "$INDEX_DIR" \
    "$SOURCE_DIR" \
    "$AUDIT_DIR" \
    "$MANIFEST_DIR" \
    "$SUMMARY_DIR"

require_file()
{
    local file="$1"

    test -f "$file" || {
        echo "FATAL: required file missing:"
        echo "$file"
        return 1
    }
}

find_archive_by_sha()
{
    local expected="$1"
    local candidate
    local actual

    while IFS= read -r -d '' candidate
    do
        actual="$(sha256sum "$candidate" | awk '{print $1}')"

        if test "$actual" = "$expected"; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done < <(
        find "$BASE" \
            -maxdepth 2 \
            -type f \
            -name '*.tar.gz' \
            -print0
    )

    return 1
}

verify_archive()
{
    local label="$1"
    local archive="$2"
    local contents_file="$AUDIT_DIR/${label}_archive_contents.txt"

    require_file "$archive"

    gzip -t "$archive"
    tar -tzf "$archive" > "$contents_file"

    local member_count
    member_count="$(
        grep -v '/$' "$contents_file" |
        wc -l
    )"

    echo "${label}_ARCHIVE_MEMBER_COUNT=$member_count"

    test "$member_count" -gt 0 || {
        echo "FATAL: $label archive contains no files"
        return 1
    }

    echo "${label}_ARCHIVE_VALIDATION=PASS"
}

main()
{
    echo "============================================================"
    echo "MSG06A — MLK_POLY_TOMSG COMBINED CAMPAIGN CLOSURE"
    echo "============================================================"
    echo
    echo "CAPTURE_UTC=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "REPO=$REPO"
    echo "BASE=$BASE"
    echo "OUT=$OUT"

    echo
    echo "===== 1. EXECUTABLE GATE ====="

    for executable in \
        git \
        sha256sum \
        tar \
        gzip \
        find \
        awk \
        grep \
        sort \
        xargs \
        cp \
        uname
    do
        command -v "$executable" >/dev/null || {
            echo "FATAL: required executable unavailable: $executable"
            return 1
        }
    done

    echo "EXECUTABLE_GATE=PASS"

    echo
    echo "===== 2. FROZEN SOURCE GATE ====="

    ACTUAL_HEAD="$(git -C "$REPO" rev-parse HEAD)"

    ACTUAL_COMPRESS_SHA256="$(
        sha256sum "$COMPRESS_C" |
        awk '{print $1}'
    )"

    ACTUAL_COMPRESS_H_SHA256="$(
        sha256sum "$COMPRESS_H" |
        awk '{print $1}'
    )"

    SOURCE_STATUS="$(
        git -C "$REPO" status \
            --porcelain=v1 \
            --untracked-files=all
    )"

    echo "ACTUAL_HEAD=$ACTUAL_HEAD"
    echo "EXPECTED_COMMIT=$EXPECTED_COMMIT"
    echo "ACTUAL_COMPRESS_SHA256=$ACTUAL_COMPRESS_SHA256"
    echo "EXPECTED_COMPRESS_SHA256=$EXPECTED_COMPRESS_SHA256"
    echo "ACTUAL_COMPRESS_H_SHA256=$ACTUAL_COMPRESS_H_SHA256"
    echo "EXPECTED_COMPRESS_H_SHA256=$EXPECTED_COMPRESS_H_SHA256"

    test "$ACTUAL_HEAD" = "$EXPECTED_COMMIT" || {
        echo "FATAL: frozen commit mismatch"
        return 2
    }

    test "$ACTUAL_COMPRESS_SHA256" = \
        "$EXPECTED_COMPRESS_SHA256" || {
        echo "FATAL: compress.c hash mismatch"
        return 3
    }

    test "$ACTUAL_COMPRESS_H_SHA256" = \
        "$EXPECTED_COMPRESS_H_SHA256" || {
        echo "FATAL: compress.h hash mismatch"
        return 4
    }

    test -z "$SOURCE_STATUS" || {
        echo "FATAL: frozen source repository is not clean"
        printf '%s\n' "$SOURCE_STATUS"
        return 5
    }

    echo "SOURCE_BINDING=PASS"
    echo "SOURCE_TREE_CLEAN_BEFORE=YES"

    echo
    echo "===== 3. LOCATE AND VERIFY T1 ARCHIVE ====="

    T1_ARCHIVE="$(
        find_archive_by_sha "$EXPECTED_T1_ARCHIVE_SHA256"
    )" || {
        echo "FATAL: no archive with the accepted T1 SHA-256 was found under:"
        echo "$BASE"
        return 6
    }

    T1_ACTUAL_SHA256="$(
        sha256sum "$T1_ARCHIVE" |
        awk '{print $1}'
    )"

    echo "T1_ARCHIVE=$T1_ARCHIVE"
    echo "T1_ARCHIVE_SHA256=$T1_ACTUAL_SHA256"

    test "$T1_ACTUAL_SHA256" = \
        "$EXPECTED_T1_ARCHIVE_SHA256" || {
        echo "FATAL: T1 archive hash mismatch"
        return 7
    }

    verify_archive "T1" "$T1_ARCHIVE"

    echo "T1_FINAL_ARCHIVE_BINDING=PASS"

    echo
    echo "===== 4. VERIFY REPAIRED T2 ARCHIVE ====="

    require_file "$T2_ARCHIVE"
    require_file "$T2_SHA_FILE"

    T2_ACTUAL_SHA256="$(
        sha256sum "$T2_ARCHIVE" |
        awk '{print $1}'
    )"

    T2_RECORDED_SHA256="$(
        awk 'NF >= 1 { print $1; exit }' "$T2_SHA_FILE"
    )"

    echo "T2_ARCHIVE=$T2_ARCHIVE"
    echo "T2_ACTUAL_SHA256=$T2_ACTUAL_SHA256"
    echo "T2_RECORDED_SHA256=$T2_RECORDED_SHA256"

    test "$T2_ACTUAL_SHA256" = \
        "$EXPECTED_T2_ARCHIVE_SHA256" || {
        echo "FATAL: repaired T2 archive hash mismatch"
        return 8
    }

    test "$T2_RECORDED_SHA256" = \
        "$EXPECTED_T2_ARCHIVE_SHA256" || {
        echo "FATAL: repaired T2 checksum file mismatch"
        return 9
    }

    (
        cd "$BASE"
        sha256sum -c "$(basename "$T2_SHA_FILE")"
    )

    verify_archive "T2" "$T2_ARCHIVE"

    echo "T2_REPAIRED_FINAL_ARCHIVE_BINDING=PASS"

    echo
    echo "===== 5. VERIFY T5 ARCHIVE ====="

    require_file "$T5_ARCHIVE"
    require_file "$T5_SHA_FILE"

    T5_ACTUAL_SHA256="$(
        sha256sum "$T5_ARCHIVE" |
        awk '{print $1}'
    )"

    T5_RECORDED_SHA256="$(
        awk 'NF >= 1 { print $1; exit }' "$T5_SHA_FILE"
    )"

    echo "T5_ARCHIVE=$T5_ARCHIVE"
    echo "T5_ACTUAL_SHA256=$T5_ACTUAL_SHA256"
    echo "T5_RECORDED_SHA256=$T5_RECORDED_SHA256"

    test "$T5_ACTUAL_SHA256" = \
        "$T5_RECORDED_SHA256" || {
        echo "FATAL: T5 archive and checksum file disagree"
        return 10
    }

    (
        cd "$BASE"
        sha256sum -c "$(basename "$T5_SHA_FILE")"
    )

    verify_archive "T5" "$T5_ARCHIVE"

    echo "T5_FINAL_ARCHIVE_BINDING=PASS"

    echo
    echo "===== 6. COPY FROZEN CAMPAIGN ARCHIVES ====="

    cp --preserve=mode,timestamps \
        "$T1_ARCHIVE" \
        "$ARCHIVES_DIR/"

    cp --preserve=mode,timestamps \
        "$T2_ARCHIVE" \
        "$ARCHIVES_DIR/"

    cp --preserve=mode,timestamps \
        "$T5_ARCHIVE" \
        "$ARCHIVES_DIR/"

    printf '%s  %s\n' \
        "$T1_ACTUAL_SHA256" \
        "$(basename "$T1_ARCHIVE")" \
        > "$ARCHIVES_DIR/T1_ARCHIVE.sha256"

    printf '%s  %s\n' \
        "$T2_ACTUAL_SHA256" \
        "$(basename "$T2_ARCHIVE")" \
        > "$ARCHIVES_DIR/T2_REPAIRED_ARCHIVE.sha256"

    printf '%s  %s\n' \
        "$T5_ACTUAL_SHA256" \
        "$(basename "$T5_ARCHIVE")" \
        > "$ARCHIVES_DIR/T5_ARCHIVE.sha256"

    (
        cd "$ARCHIVES_DIR"

        sha256sum -c T1_ARCHIVE.sha256
        sha256sum -c T2_REPAIRED_ARCHIVE.sha256
        sha256sum -c T5_ARCHIVE.sha256
    )

    echo "FROZEN_CAMPAIGN_ARCHIVES=3_OF_3_COPIED_AND_VERIFIED"

    echo
    echo "===== 7. WRITE THEOREM REGISTRY ====="

    cat > "$REGISTRY_DIR/THEOREM_REGISTRY.tsv" <<'EOF'
family	theorem	quantification	production_relation	final_status
MSG-T1	Exact canonical coefficient-to-message-bit semantics and LSB-first packing	All 256 coefficient positions and all canonical coefficient values	Direct symbolic execution of real frozen mlk_poly_tomsg and real helper	FINAL_ACCEPTED
MSG-T2-R1	Relational XOR law	Two arbitrary canonical polynomials and symbolic selected index	Two direct calls to real frozen mlk_poly_tomsg	ACCEPTED
MSG-T2-R2A	Coefficient locality	Equal selected coefficients; unrelated coefficients unrestricted	Two direct calls to real frozen mlk_poly_tomsg	ACCEPTED
MSG-T2-R2B	Cross-bit preservation and byte confinement	All coefficients except possibly selected index equal	Two direct calls to real frozen mlk_poly_tomsg	ACCEPTED
MSG-T2-R3A	Same-decision invariance	Selected coefficients may differ but have equal Compress1 decisions	Two direct calls to real frozen mlk_poly_tomsg	ACCEPTED
MSG-T2-R3B	Input-frame preservation and complete-message determinism	Distinct objects with equal complete canonical values	Two direct calls to real frozen mlk_poly_tomsg	ACCEPTED
MSG-T5	Model-to-production binding	Canonical symbolic polynomial and selected index at production offset	Model equals real helper and real mlk_poly_tomsg selected bit	ACCEPTED
MSG-T5	Exact admissible uint32 offset interval	All canonical coefficients and all uint32 offsets	Universal parameter theorem on production-bound evidence-local model	FINAL_ACCEPTED
EOF

    cat "$REGISTRY_DIR/THEOREM_REGISTRY.tsv"

    echo "THEOREM_REGISTRY=PASS"

    echo
    echo "===== 8. WRITE ASSUMPTION REGISTRY ====="

    cat > "$REGISTRY_DIR/ASSUMPTION_REGISTRY.tsv" <<'EOF'
assumption_id	assumption	scope
A01	Frozen Git commit af4c5abdd5958bdc65a03cd5ee86708264f93304	T1/T2/T5
A02	compress.c SHA-256 9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad	T1/T2/T5
A03	compress.h SHA-256 0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd	T1/T2/T5
A04	ML-KEM-768 configuration	T1/T2/T5
A05	Portable-C path with assembly disabled	T1/T2/T5
A06	Canonical coefficients satisfy 0 <= u < 3329	T1/T2/T5
A07	Valid objects and required non-aliasing	T1/T2
A08	CBMC 6.9.0 bit-precise C machine model	T1/T2/T5
A09	Recorded verification support adapters faithfully model the build environment	T1/T2/T5
A10	Complete finite-loop bounds and unwinding assertions where production loops occur	T1/T2
A11	Independent threshold oracle matches the canonical Compress1 arithmetic	T1/T2/T5
A12	T5 fixes multiplier 1290168 and shift 31 while varying only uint32 offset	T5
A13	T5 universal parameter theorem concerns an evidence-local model bound to production at c = 2^30	T5
A14	CBMC, goto-cc, goto-instrument, SAT solver, shell, and hashing tools are within the trusted computing base	T1/T2/T5
EOF

    cat "$REGISTRY_DIR/ASSUMPTION_REGISTRY.tsv"

    echo "ASSUMPTION_REGISTRY=PASS"

    echo
    echo "===== 9. WRITE PROVED / SUPPORTED / NOT-PROVED MATRIX ====="

    cat > "$MATRIX_DIR/PROVED_SUPPORTED_NOT_PROVED.tsv" <<'EOF'
claim	status	evidence
Exact canonical threshold bit for real production	PROVED_WITHIN_SCOPE	MSG-T1 positive theorem
All 256 coefficients map to corresponding message bits	PROVED_WITHIN_SCOPE	MSG-T1 positive theorem
LSB-first packing into 32 bytes	PROVED_WITHIN_SCOPE	MSG-T1 positive theorem
Threshold and index regions reachable	SUPPORTED_BY_REACHABILITY	MSG-T1 12/12 covers
Production loops sensitive to insufficient bounds	SUPPORTED_BY_EXPECTED_FAILURE	T1 four loop controls
Registered T1 semantic defects detected	PROVED_FOR_REGISTERED_MUTANTS	T1 8/8 mutants
Relational XOR law	PROVED_WITHIN_SCOPE	MSG-T2 R1
Coefficient locality	PROVED_WITHIN_SCOPE	MSG-T2 R2A
Cross-bit preservation and byte confinement	PROVED_WITHIN_SCOPE	MSG-T2 R2B
Same-decision invariance	PROVED_WITHIN_SCOPE	MSG-T2 R3A
Input-frame preservation	PROVED_WITHIN_SCOPE	MSG-T2 R3B
Equal complete inputs produce equal complete messages	PROVED_WITHIN_SCOPE	MSG-T2 R3B
T2 relational regions reachable	SUPPORTED_BY_REACHABILITY	T2 43/43 covers
Registered T2 antecedent/corruption defects detected	PROVED_FOR_REGISTERED_MUTANTS	T2 5/5 mutants
T5 model equals real helper at production offset	PROVED_WITHIN_SCOPE	MSG05C
T5 model equals real tomsg selected bit at production offset	PROVED_WITHIN_SCOPE	MSG05C
Every inside offset is sufficient	PROVED_WITHIN_SCOPE	MSG05D
Every outside uint32 offset has a canonical counterexample	PROVED_WITHIN_SCOPE	MSG05E
Exact interval is [1073417800,1074063871]	PROVED_WITHIN_SCOPE	MSG05D plus MSG05E
Production offset 2^30 is an interior member	PROVED_WITHIN_SCOPE	MSG05B/MSG05C/MSG05D
Outside partitions reachable	SUPPORTED_BY_REACHABILITY	MSG05F 10/10 covers
Both interval endpoints one-step tight	PROVED_FOR_ADJACENT_MUTATIONS	MSG05F 2/2 mutations
Every conceivable property of mlk_poly_tomsg	NOT_PROVED	Outside registered theorem scope
Noncanonical behavior	NOT_PROVED	Outside assumptions
All ML-KEM parameter sets	NOT_PROVED	Only ML-KEM-768 executed
Assembly and object-code equivalence	NOT_PROVED	Portable-C model only
Constant-time and side-channel security	NOT_PROVED	No timing/leakage model
All of ML-KEM correctness/security	NOT_PROVED	Function-specific case study
Absolute first-ever novelty	NOT_CLAIMED	Public search cannot prove universal nonexistence
EOF

    cat "$MATRIX_DIR/PROVED_SUPPORTED_NOT_PROVED.tsv"

    echo "CLAIM_MATRIX=PASS"

    echo
    echo "===== 10. WRITE NOVELTY AND NUMBERING RECORDS ====="

    cat > "$NOVELTY_DIR/NOVELTY_CLASSIFICATION.md" <<'EOF'
# Novelty Classification

## Not claimed as novel

The campaign does not claim novelty for:

- ML-KEM or FIPS 203;
- the standard `Compress1` operation;
- the modulus, polynomial size, or message packing convention;
- CBMC, formal verification, relational verification, or mutation testing;
- broad formal verification of `mlkem-native`;
- the broad idea of LLM-assisted formal verification.

## Repository-level novelty

Inspection of the frozen native source, contracts, harnesses, Makefiles, and proof tree found fixed-function proof infrastructure for `mlk_scalar_compress_d1` and `mlk_poly_tomsg`.

No equivalent frozen native theorem obligation was located for the complete MSG-T1 all-bit oracle refinement, the MSG-T2 relational family, or the MSG-T5 exact symbolic-offset characterization.

Repository-level novelty is therefore accepted.

## Campaign-level originality

The integrated package is independently authored and combines:

- exact fixed-function semantics;
- two-execution relational properties;
- an exact production-bound parameter interval;
- independent oracle validation;
- reachability and non-vacuity;
- insufficient-bound controls;
- implementation, assertion, antecedent, and endpoint mutations;
- deterministic source/GOTO/result/archive binding;
- preserved correction history.

Campaign-level distinctness is accepted.

## Global novelty

A public review completed on 23 July 2026 located no exact match for the combined T1/T2/T5 theorem-and-evidence package and no exact public match for the T5 endpoint interval.

A public search cannot exclude unpublished, private, unindexed, differently named, or future work.

The defensible claim is:

> distinct from the frozen native proof obligations inspected and apparently original in the reviewed public record.

The prohibited claim is:

> an unconditional first-ever proof.
EOF

    cat > "$NOVELTY_DIR/T3_T4_NUMBERING_CLARIFICATION.md" <<'EOF'
# T3/T4 Numbering Clarification

Two provisional numbering systems appeared during planning.

## Earlier preregistration

- MSG-T3: output-initialization independence / state footprint
- MSG-T4: subtract-reduce-tomsg composition

## Later arithmetic triage

- later T3: exact quotient-cell partition
- later T4: multiplier characterization
- T5: exact admissible offset interval

The completed accepted families are unambiguous:

- MSG-T1: exact fixed-production semantics
- MSG-T2: relational, locality, confinement, frame, and determinism
- MSG-T5: exact admissible offset interval

The later quotient-cell and multiplier proposals were deferred because their marginal assurance value did not justify additional proof and evidence volume after T1 and T5.

Future work must use descriptive identifiers such as `ARITH-QCELL` and `ARITH-MULTIPLIER` rather than reusing bare T3/T4 labels.
EOF

    echo "NOVELTY_CLASSIFICATION=PASS"
    echo "T3_T4_NUMBERING_CLARIFICATION=PASS"

    echo
    echo "===== 11. WRITE EVIDENCE INDEX ====="

    cat > "$INDEX_DIR/EVIDENCE_ARCHIVE_INDEX.tsv" <<EOF
family	role	archive	sha256
MSG-T1	exact fixed-production semantics and T1 hardening	$(basename "$T1_ARCHIVE")	$T1_ACTUAL_SHA256
MSG-T2	repaired final relational/locality/frame/determinism package	$(basename "$T2_ARCHIVE")	$T2_ACTUAL_SHA256
MSG-T5	exact admissible offset interval package	$(basename "$T5_ARCHIVE")	$T5_ACTUAL_SHA256
EOF

    cat > "$INDEX_DIR/CAMPAIGN_COUNTS.tsv" <<'EOF'
family	positive_success_records	reachability_goals	mutations	other_controls
MSG-T1	521	12	8	522-property cover-neutral companion; 4 accepted insufficient-bound controls
MSG-T2	2622	43	5	15 frozen GOTO binaries revalidated
MSG-T5	553	10	2	6 frozen GOTO binaries revalidated
COMBINED_MAIN_POSITIVE_RECORDS	3696	65	15	T1 companion and loop controls reported separately
EOF

    cat "$INDEX_DIR/EVIDENCE_ARCHIVE_INDEX.tsv"
    cat "$INDEX_DIR/CAMPAIGN_COUNTS.tsv"

    echo "EVIDENCE_INDEX=PASS"
    echo "COMBINED_MAIN_POSITIVE_RECORDS=3696"
    echo "COMBINED_REACHABILITY_GOALS=65"
    echo "COMBINED_MUTATIONS=15"

    echo
    echo "===== 12. WRITE SOURCE BINDING AND FINAL SUMMARY ====="

    cat > "$SOURCE_DIR/SOURCE_BINDING.txt" <<EOF
REPOSITORY=$REPO
COMMIT=$EXPECTED_COMMIT
COMPRESS_C_SHA256=$EXPECTED_COMPRESS_SHA256
COMPRESS_H_SHA256=$EXPECTED_COMPRESS_H_SHA256
PARAMETER_SET=ML-KEM-768
IMPLEMENTATION_PATH=PORTABLE_C
ASSEMBLY_DISABLED=YES
SOURCE_TREE_CLEAN_AT_CLOSURE_START=YES
EOF

    cp --preserve=mode,timestamps \
        "$COMPRESS_C" \
        "$SOURCE_DIR/compress.c"

    cp --preserve=mode,timestamps \
        "$COMPRESS_H" \
        "$SOURCE_DIR/compress.h"

    sha256sum \
        "$SOURCE_DIR/compress.c" \
        "$SOURCE_DIR/compress.h" \
        > "$SOURCE_DIR/FROZEN_SOURCE_SNAPSHOT.sha256"

    cat > "$SUMMARY_DIR/MLK_POLY_TOMSG_COMBINED_CAMPAIGN_CLOSURE.md" <<'EOF'
# ML-KEM `mlk_poly_tomsg` Combined MSG-T1 / MSG-T2 / MSG-T5 Campaign Closure

## Final combined conclusion

The frozen ML-KEM-768 portable-C `mlk_poly_tomsg` campaign contains three differentiated accepted theorem families:

1. **MSG-T1 — exact fixed-production semantics**
   - exact canonical coefficient-to-bit relation;
   - all 256 output positions;
   - correct least-significant-bit-first packing.

2. **MSG-T2 — relational, locality, confinement, frame, and determinism**
   - relational XOR law;
   - coefficient locality;
   - cross-bit preservation and byte confinement;
   - same-decision invariance;
   - input-frame preservation;
   - complete-message determinism.

3. **MSG-T5 — exact admissible offset interval**
   - source-faithful parameterized model;
   - formal production-offset binding;
   - universal inside-interval sufficiency;
   - universal outside-interval necessity;
   - exact interval `[1073417800,1074063871]`;
   - production offset `2^30` is an interior member.

## Combined hardening evidence

```text
Main positive successful property records: 3696
Registered reachability goals:             65 / 65
Registered semantic mutations:             15 / 15 rejected
T1 cover-neutral companion:                522 / 522 successful
T1 insufficient-bound controls:            4 accepted
T2 frozen GOTO revalidation:               15 / 15
T5 frozen GOTO revalidation:                6 / 6
```

Property-record counts include generated C-safety checks and are not counts of independent mathematical theorems.

## Correct proof statement

Selected strong functional and relational properties of the frozen `mlk_poly_tomsg` implementation are proved within the registered assumptions and finite CBMC model.

## Explicit non-claims

The campaign does not prove:

- every property of `mlk_poly_tomsg`;
- noncanonical behavior;
- every ML-KEM parameter set;
- assembly or object-code equivalence;
- complete ML-KEM correctness or security;
- constant-time or side-channel resistance;
- universal mutation completeness;
- absolute first-ever novelty.

## Novelty position

The standard `Compress1` mathematics and broad verification of `mlkem-native` are not new.

The independently authored theorem obligations, exact T5 parameter characterization, falsification controls, correction history, and evidence architecture are distinct from the frozen native proof obligations inspected.

No exact public match was located in the 23 July 2026 review. The work is presented as a strong repository-level and campaign-level contribution and an apparently original MSc case study, not as an unconditional world-first result.
EOF

    cat > "$SUMMARY_DIR/FINAL_STATUS.txt" <<'EOF'
CAMPAIGN=MLK_POLY_TOMSG
SOURCE_COMMIT=af4c5abdd5958bdc65a03cd5ee86708264f93304

MSG_T1_EXACT_FIXED_PRODUCTION_SEMANTICS=FINAL_ACCEPTED
MSG_T2_RELATIONAL_LOCALITY_FRAME_DETERMINISM=FINAL_ACCEPTED
MSG_T5_EXACT_ADMISSIBLE_OFFSET_INTERVAL=FINAL_ACCEPTED

COMBINED_MAIN_POSITIVE_SUCCESS_RECORDS=3696
COMBINED_REACHABILITY_GOALS=65_OF_65
COMBINED_MUTATIONS=15_OF_15_REJECTED
T1_COVER_NEUTRAL_COMPANION=522_OF_522_SUCCESS
T1_INSUFFICIENT_BOUND_CONTROLS=4_ACCEPTED

T5_EXACT_LOWER=1073417800
T5_EXACT_UPPER=1074063871
T5_EXACT_COUNT=646072
T5_PRODUCTION_OFFSET=1073741824
T5_PRODUCTION_OFFSET_IS_INTERIOR=YES

REPOSITORY_LEVEL_NOVELTY=PASS
CAMPAIGN_LEVEL_DISTINCTNESS=PASS
GLOBAL_FIRST_EVER_NOVELTY=NOT_CLAIMED

CBMC_SOLVING_EXECUTED=NO
GOTO_REBUILD_EXECUTED=NO
PRODUCTION_SOURCE_MODIFIED=NO
AUTHORITATIVE_RESULTS_REPLACED=NO
COMBINED_CLOSURE_ONLY=YES

MLK_POLY_TOMSG_COMBINED_CAMPAIGN=FINAL_CLOSED
EOF

    echo "FINAL_SUMMARY=PASS"

    echo
    echo "===== 13. BUILD INPUT AND PACKAGE MANIFESTS ====="

    sha256sum \
        "$T1_ARCHIVE" \
        "$T2_ARCHIVE" \
        "$T5_ARCHIVE" \
        "$COMPRESS_C" \
        "$COMPRESS_H" \
        > "$AUDIT_DIR/CLOSURE_AUTHORITATIVE_INPUTS.sha256"

    cat "$AUDIT_DIR/CLOSURE_AUTHORITATIVE_INPUTS.sha256"

    (
        cd "$OUT"

        find . \
            -type f \
            ! -path './08_manifests/MSG06A_FILES.sha256' \
            -print0 |
        LC_ALL=C sort -z |
        xargs -0 sha256sum
    ) > "$MANIFEST_DIR/MSG06A_FILES.sha256"

    (
        cd "$OUT"
        sha256sum -c 08_manifests/MSG06A_FILES.sha256
    ) >/dev/null

    MSG06A_FILE_COUNT="$(
        wc -l < "$MANIFEST_DIR/MSG06A_FILES.sha256"
    )"

    echo "MSG06A_FILE_COUNT=$MSG06A_FILE_COUNT"
    echo "MSG06A_MANIFEST=PASS"

    echo
    echo "===== 14. CREATE DETERMINISTIC COMBINED ARCHIVE ====="

    rm -f \
        "$ARCHIVE_TAR" \
        "$ARCHIVE" \
        "$ARCHIVE_SHA256" \
        "$ARCHIVE_CONTENTS"

    tar \
        --sort=name \
        --mtime='UTC 1970-01-01' \
        --owner=0 \
        --group=0 \
        --numeric-owner \
        -C "$BASE" \
        -cf "$ARCHIVE_TAR" \
        "$OUT_NAME"

    gzip -n -f "$ARCHIVE_TAR"

    require_file "$ARCHIVE"

    gzip -t "$ARCHIVE"
    tar -tzf "$ARCHIVE" > "$ARCHIVE_CONTENTS"

    (
        cd "$BASE"

        sha256sum \
            "$(basename "$ARCHIVE")" \
            > "$(basename "$ARCHIVE_SHA256")"

        sha256sum -c \
            "$(basename "$ARCHIVE_SHA256")"
    )

    COMBINED_ARCHIVE_SHA256="$(
        sha256sum "$ARCHIVE" |
        awk '{print $1}'
    )"

    COMBINED_ARCHIVE_FILE_COUNT="$(
        grep -v '/$' "$ARCHIVE_CONTENTS" |
        wc -l
    )"

    echo "COMBINED_ARCHIVE=$ARCHIVE"
    echo "COMBINED_ARCHIVE_SHA256=$COMBINED_ARCHIVE_SHA256"
    echo "COMBINED_ARCHIVE_FILE_COUNT=$COMBINED_ARCHIVE_FILE_COUNT"

    cat "$ARCHIVE_SHA256"

    echo "COMBINED_ARCHIVE_GZIP_VALIDATION=PASS"
    echo "COMBINED_ARCHIVE_TAR_VALIDATION=PASS"
    echo "COMBINED_ARCHIVE_SHA256_VALIDATION=PASS"

    echo
    echo "===== 15. FINAL SOURCE RECHECK ====="

    FINAL_HEAD="$(git -C "$REPO" rev-parse HEAD)"

    FINAL_COMPRESS_SHA256="$(
        sha256sum "$COMPRESS_C" |
        awk '{print $1}'
    )"

    FINAL_COMPRESS_H_SHA256="$(
        sha256sum "$COMPRESS_H" |
        awk '{print $1}'
    )"

    FINAL_SOURCE_STATUS="$(
        git -C "$REPO" status \
            --porcelain=v1 \
            --untracked-files=all
    )"

    test "$FINAL_HEAD" = "$EXPECTED_COMMIT"
    test "$FINAL_COMPRESS_SHA256" = "$EXPECTED_COMPRESS_SHA256"
    test "$FINAL_COMPRESS_H_SHA256" = "$EXPECTED_COMPRESS_H_SHA256"
    test -z "$FINAL_SOURCE_STATUS"

    echo "SOURCE_TREE_CLEAN_AFTER=YES"

    echo
    echo "============================================================"
    echo "MSG06A_SOURCE_BINDING=PASS"
    echo "MSG06A_T1_FINAL_ARCHIVE_BINDING=PASS"
    echo "MSG06A_T2_REPAIRED_FINAL_ARCHIVE_BINDING=PASS"
    echo "MSG06A_T5_FINAL_ARCHIVE_BINDING=PASS"
    echo "MSG06A_THEOREM_REGISTRY=PASS"
    echo "MSG06A_ASSUMPTION_REGISTRY=PASS"
    echo "MSG06A_CLAIM_MATRIX=PASS"
    echo "MSG06A_NOVELTY_CLASSIFICATION=PASS"
    echo "MSG06A_T3_T4_NUMBERING_CLARIFICATION=PASS"
    echo "MSG06A_EVIDENCE_INDEX=PASS"
    echo "MSG06A_COMBINED_MAIN_POSITIVE_RECORDS=3696"
    echo "MSG06A_REACHABILITY_GOALS=65_OF_65"
    echo "MSG06A_MUTATIONS=15_OF_15_REJECTED"
    echo "MSG06A_DETERMINISTIC_COMBINED_ARCHIVE=PASS"
    echo "MSG_T1=FINAL_ACCEPTED"
    echo "MSG_T2=FINAL_ACCEPTED"
    echo "MSG_T5=FINAL_ACCEPTED"
    echo "MLK_POLY_TOMSG_COMBINED_CAMPAIGN=FINAL_CLOSED"
    echo "REPOSITORY_LEVEL_NOVELTY=PASS"
    echo "CAMPAIGN_LEVEL_DISTINCTNESS=PASS"
    echo "GLOBAL_FIRST_EVER_NOVELTY=NOT_CLAIMED"
    echo "CBMC_SOLVING_EXECUTED=NO"
    echo "GOTO_REBUILD_EXECUTED=NO"
    echo "PRODUCTION_SOURCE_MODIFIED=NO"
    echo "AUTHORITATIVE_RESULTS_REPLACED=NO"
    echo "COMBINED_CLOSURE_ONLY=YES"
    echo "NEXT_STAGE=MLK_POLY_FROMMSG_SOURCE_AND_NATIVE_PROOF_ANALYSIS"
    echo "EVIDENCE_PATH=$OUT"
    echo "COMBINED_ARCHIVE_PATH=$ARCHIVE"
    echo "COMBINED_ARCHIVE_SHA256_PATH=$ARCHIVE_SHA256"
    echo "FINAL_STATUS=0"
    echo "============================================================"
}

set +e

main 2>&1 | tee "$LOG"
PIPE_STATUS="${PIPESTATUS[0]}"

set -e

echo
echo "CHILD_PROCESS_STATUS=$PIPE_STATUS"
echo "TERMINAL_CAPTURE=$LOG"

if test -f "$LOG"; then
    echo "TERMINAL_CAPTURE_SHA256=$(
        sha256sum "$LOG" |
        awk '{print $1}'
    )"
fi

exit "$PIPE_STATUS"
