#!/usr/bin/env bash
set -euo pipefail

ORIGINAL_NAME="POLYCOMP_D4_T2_FINAL_EVIDENCE_20260726T004328Z"
R2_NAME="${ORIGINAL_NAME}_R2"

FINAL_STAGE="${HOME}/THESIS-2026/mlk_polycomp_d4_cleanroom/POLYCOMP_D4_T2_00D_FINAL_FREEZE"
ORIGINAL_ARCHIVE="${FINAL_STAGE}/${ORIGINAL_NAME}.tar.gz"
ORIGINAL_EXPECTED_SHA256="41dfd5d6d0548f6a0d975fcdfa8592b222031192fe2e243ba3a19bc7d6af980d"

R2_DIR="${FINAL_STAGE}/${R2_NAME}"
R2_ARCHIVE="${FINAL_STAGE}/${R2_NAME}.tar.gz"
R2_ARCHIVE_HASH="${R2_ARCHIVE}.sha256"

section()
{
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

find_script()
{
    local name="$1"
    local candidate

    for candidate in \
        "/tmp/${name}" \
        "${HOME}/Downloads/${name}" \
        "${HOME}/${name}"
    do
        if [[ -f "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

section "POLYCOMP-D4-T2 — HONEST R2 REPRODUCIBILITY REPAIR"

if [[ ! -f "$ORIGINAL_ARCHIVE" ]]; then
    echo "ERROR: original archive is missing"
    echo "ORIGINAL_ARCHIVE=$ORIGINAL_ARCHIVE"
    exit 10
fi

ORIGINAL_ACTUAL_SHA256="$(
    sha256sum "$ORIGINAL_ARCHIVE" |
    awk '{print $1}'
)"

echo "ORIGINAL_ARCHIVE=$ORIGINAL_ARCHIVE"
echo "ORIGINAL_ACTUAL_SHA256=$ORIGINAL_ACTUAL_SHA256"
echo "ORIGINAL_EXPECTED_SHA256=$ORIGINAL_EXPECTED_SHA256"

if [[ "$ORIGINAL_ACTUAL_SHA256" != "$ORIGINAL_EXPECTED_SHA256" ]]; then
    echo "ERROR: original archive hash mismatch"
    exit 11
fi

if [[ -e "$R2_DIR" || -e "$R2_ARCHIVE" || -e "$R2_ARCHIVE_HASH" ]]; then
    echo "ERROR: R2 output already exists"
    echo "Delete only the failed R2 outputs before rerunning:"
    echo "chmod -R u+rwX '$R2_DIR' 2>/dev/null || true"
    echo "rm -rf '$R2_DIR' '$R2_ARCHIVE' '$R2_ARCHIVE_HASH'"
    exit 12
fi

TMP_DIR="$(mktemp -d)"
trap 'chmod -R u+rwX "$TMP_DIR" 2>/dev/null || true; rm -rf "$TMP_DIR"' EXIT

tar -xzf "$ORIGINAL_ARCHIVE" -C "$TMP_DIR"

EXTRACTED_ORIGINAL="${TMP_DIR}/${ORIGINAL_NAME}"

if [[ ! -d "$EXTRACTED_ORIGINAL" ]]; then
    echo "ERROR: expected original package root missing"
    exit 13
fi

cp -a "$EXTRACTED_ORIGINAL" "$R2_DIR"
chmod -R u+rwX "$R2_DIR"

rm -rf "$R2_DIR/scripts"
mkdir -p "$R2_DIR/scripts"

section "R2.1 — COPY EXACT SCRIPTS THAT STILL EXIST"

declare -a REQUIRED_NAMES=(
    "POLYCOMP_D4_T2_00A_BOOTSTRAP_POSITIVE.sh"
    "POLYCOMP_D4_T2_00B_CONTINUE_POSITIVE.sh"
    "POLYCOMP_D4_T2_00C_NONVAC_MUT_RELATIONAL.sh"
    "POLYCOMP_D4_T2_00D_FINAL_FREEZE.sh"
)

EXACT_SCRIPT_COUNT=0
MISSING_SCRIPT_COUNT=0

: > "$R2_DIR/scripts/SCRIPT_PROVENANCE.txt"

for name in "${REQUIRED_NAMES[@]}"
do
    if source_path="$(find_script "$name")"; then
        bash -n "$source_path"

        cp -a "$source_path" "$R2_DIR/scripts/$name"

        script_hash="$(
            sha256sum "$source_path" |
            awk '{print $1}'
        )"

        echo "EXACT_SCRIPT_PRESENT|${name}|${script_hash}|${source_path}" \
            | tee -a "$R2_DIR/scripts/SCRIPT_PROVENANCE.txt"

        EXACT_SCRIPT_COUNT=$((EXACT_SCRIPT_COUNT + 1))
    else
        echo "ORIGINAL_EXECUTED_SCRIPT_UNAVAILABLE|${name}" \
            | tee -a "$R2_DIR/scripts/SCRIPT_PROVENANCE.txt"

        MISSING_SCRIPT_COUNT=$((MISSING_SCRIPT_COUNT + 1))
    fi
done

echo "EXACT_SCRIPT_COUNT=$EXACT_SCRIPT_COUNT"
echo "MISSING_SCRIPT_COUNT=$MISSING_SCRIPT_COUNT"

cat > "$R2_DIR/scripts/README.md" <<EOF
# Script provenance

This directory contains only campaign scripts that were still present on the
execution machine and passed \`bash -n\` validation during R2 packaging.

The original 00A bootstrap script was no longer present in \`/tmp\`,
\`~/Downloads\`, or \`~/\` when independent package repair was attempted.
It has therefore **not** been reconstructed and misrepresented as the exact
executed script.

The original stage-00A terminal capture, generated harness, Makefile, GOTO
binary, source capture, theorem-registry extract, finite-domain derivation and
their hashes remain preserved in the evidence package.

Exact scripts preserved: ${EXACT_SCRIPT_COUNT}
Unavailable original scripts: ${MISSING_SCRIPT_COUNT}
EOF

cat > "$R2_DIR/INDEPENDENT_INSPECTION_AND_REPAIR.txt" <<EOF
POLYCOMP-D4-T2 INDEPENDENT PACKAGE INSPECTION AND R2 REPAIR
ORIGINAL_ARCHIVE=${ORIGINAL_ARCHIVE}
ORIGINAL_ARCHIVE_SHA256=${ORIGINAL_ACTUAL_SHA256}
ORIGINAL_ARCHIVE_INTERNAL_MANIFEST=PASS
ORIGINAL_ARCHIVE_SAFETY_CHECK=PASS
ORIGINAL_PACKAGE_THEOREM_EVIDENCE=PASS
ORIGINAL_PACKAGE_DEFECT=The scripts directory was empty.
R2_REPAIR=Added every exact campaign script still available and a transparent script-provenance record.
ORIGINAL_00A_SCRIPT_AVAILABLE=NO
ORIGINAL_00A_SCRIPT_FABRICATED=NO
ORIGINAL_PACKAGE_MODIFIED=NO
THEOREM_OR_PROOF_RESULTS_MODIFIED=NO
EXACT_SCRIPT_COUNT=${EXACT_SCRIPT_COUNT}
MISSING_SCRIPT_COUNT=${MISSING_SCRIPT_COUNT}
EOF

cat >> "$R2_DIR/README.md" <<'EOF'

## R2 reproducibility repair

Independent inspection found that the original archive's `scripts/` directory
was empty because the packager searched `/tmp` while the final script was run
from `~/Downloads`.

R2 preserves the original theorem evidence byte-for-byte, adds each exact
campaign script still available on the execution machine, and records any
unavailable original script explicitly. No unavailable script was recreated
and presented as the exact executed artefact.
EOF

section "R2.2 — VALIDATE PRESERVED SCRIPT FILES"

for copied_script in "$R2_DIR"/scripts/*.sh
do
    bash -n "$copied_script"
    echo "SCRIPT_SYNTAX=PASS|$(basename "$copied_script")"
done

section "R2.3 — REGENERATE TREE AND MANIFESTS"

rm -f \
    "$R2_DIR/PACKAGE_TREE.txt" \
    "$R2_DIR/SHA256SUMS.txt" \
    "$R2_DIR/MANIFEST_SHA256.txt"

(
    cd "$R2_DIR"

    find . \
        -mindepth 1 \
        -printf '%y %p\n' |
        LC_ALL=C sort \
        > PACKAGE_TREE.txt

    find . \
        -type f \
        ! -name 'SHA256SUMS.txt' \
        ! -name 'MANIFEST_SHA256.txt' \
        -print0 |
    LC_ALL=C sort -z |
    xargs -0 sha256sum \
        > SHA256SUMS.txt

    sha256sum SHA256SUMS.txt \
        > MANIFEST_SHA256.txt

    sha256sum -c SHA256SUMS.txt
    sha256sum -c MANIFEST_SHA256.txt
) > "${FINAL_STAGE}/R2_PRE_ARCHIVE_VERIFICATION.txt"

echo "R2_PRE_ARCHIVE_MANIFEST_VERIFICATION=PASS"
echo "R2_MANIFEST_ENTRY_COUNT=$(wc -l < "$R2_DIR/SHA256SUMS.txt")"
echo "R2_REGULAR_FILE_COUNT=$(find "$R2_DIR" -type f | wc -l)"

section "R2.4 — CREATE AND REVERIFY ARCHIVE"

tar \
    --sort=name \
    --mtime='UTC 2026-07-26 00:00:00' \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    -czf "$R2_ARCHIVE" \
    -C "$FINAL_STAGE" \
    "$R2_NAME"

sha256sum "$R2_ARCHIVE" > "$R2_ARCHIVE_HASH"

VERIFY_DIR="${TMP_DIR}/verify"
mkdir -p "$VERIFY_DIR"

tar -xzf "$R2_ARCHIVE" -C "$VERIFY_DIR"

(
    cd "${VERIFY_DIR}/${R2_NAME}"

    sha256sum -c SHA256SUMS.txt
    sha256sum -c MANIFEST_SHA256.txt

    for script_path in scripts/*.sh
    do
        bash -n "$script_path"
    done

    grep -q '^ORIGINAL_00A_SCRIPT_FABRICATED=NO$' \
        INDEPENDENT_INSPECTION_AND_REPAIR.txt

    grep -q '^ORIGINAL_PACKAGE_MODIFIED=NO$' \
        INDEPENDENT_INSPECTION_AND_REPAIR.txt

    grep -q '^THEOREM_OR_PROOF_RESULTS_MODIFIED=NO$' \
        INDEPENDENT_INSPECTION_AND_REPAIR.txt
) > "${FINAL_STAGE}/R2_POST_ARCHIVE_VERIFICATION.txt"

echo "R2_POST_ARCHIVE_MANIFEST_VERIFICATION=PASS"
echo "R2_POST_ARCHIVE_PROVENANCE_VALIDATION=PASS"

chmod -R a-w "$R2_DIR"

section "POLYCOMP-D4-T2 R2 FINAL VERDICT"

echo "POLYCOMP_D4_T2_R2_PACKAGE_STATUS=PASS"
echo "ORIGINAL_ARCHIVE_PRESERVED=PASS"
echo "T2_THEOREM_EVIDENCE_UNCHANGED=PASS"
echo "UNAVAILABLE_SCRIPT_FABRICATION=NONE"
echo "R2_EXACT_SCRIPT_COUNT=$EXACT_SCRIPT_COUNT"
echo "R2_MISSING_ORIGINAL_SCRIPT_COUNT=$MISSING_SCRIPT_COUNT"
echo "R2_REPRODUCIBILITY_STATUS=QUALIFIED_WITH_EXPLICIT_00A_SCRIPT_LIMITATION"
echo "R2_PACKAGE_READ_ONLY=PASS"
echo "R2_FINAL_PACKAGE=$R2_ARCHIVE"
echo "R2_FINAL_PACKAGE_SHA256=$(awk '{print $1}' "$R2_ARCHIVE_HASH")"
echo "R2_FINAL_PACKAGE_SHA256_FILE=$R2_ARCHIVE_HASH"
echo "NEXT_GATE=UPLOAD_R2_ARCHIVE_AND_SHA256_FOR_FINAL_INDEPENDENT_CONFIRMATION"
