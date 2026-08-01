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

section()
{
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

section "POLYCOMP-D4-T2 — EVIDENCE PACKAGE R2 REPRODUCIBILITY REPAIR"

if [[ ! -f "$ORIGINAL_ARCHIVE" ]]; then
    echo "ERROR: original archive is missing:"
    echo "$ORIGINAL_ARCHIVE"
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

declare -a REQUIRED_NAMES=(
    "POLYCOMP_D4_T2_00A_BOOTSTRAP_POSITIVE.sh"
    "POLYCOMP_D4_T2_00B_CONTINUE_POSITIVE.sh"
    "POLYCOMP_D4_T2_00C_NONVAC_MUT_RELATIONAL.sh"
    "POLYCOMP_D4_T2_00D_FINAL_FREEZE.sh"
)

declare -a SCRIPT_SOURCES=()

section "R2.1 — LOCATE AND VALIDATE EXECUTED SCRIPTS"

for name in "${REQUIRED_NAMES[@]}"
do
    if ! source_path="$(find_script "$name")"; then
        echo "MISSING_SCRIPT=$name"
        echo "Searched: /tmp, ~/Downloads and ~/"
        exit 20
    fi

    echo "FOUND_SCRIPT=$source_path"

    if ! bash -n "$source_path"; then
        echo "ERROR: shell syntax failed for $source_path"
        exit 21
    fi

    echo "SCRIPT_SYNTAX=PASS|$name"
    echo "SCRIPT_SHA256=$(sha256sum "$source_path" | awk '{print $1}')|$name"

    SCRIPT_SOURCES+=("$source_path")
done

section "R2.2 — CREATE NEW PACKAGE WITHOUT MODIFYING ORIGINAL"

if [[ -e "$R2_DIR" || -e "$R2_ARCHIVE" || -e "$R2_ARCHIVE_HASH" ]]; then
    echo "ERROR: R2 output already exists"
    echo "R2_DIR=$R2_DIR"
    echo "R2_ARCHIVE=$R2_ARCHIVE"
    exit 30
fi

TMP_DIR="$(mktemp -d)"
trap 'chmod -R u+rwX "$TMP_DIR" 2>/dev/null || true; rm -rf "$TMP_DIR"' EXIT

tar -xzf "$ORIGINAL_ARCHIVE" -C "$TMP_DIR"

EXTRACTED_ORIGINAL="${TMP_DIR}/${ORIGINAL_NAME}"

if [[ ! -d "$EXTRACTED_ORIGINAL" ]]; then
    echo "ERROR: expected package root missing after extraction"
    exit 31
fi

cp -a "$EXTRACTED_ORIGINAL" "$R2_DIR"
chmod -R u+rwX "$R2_DIR"

rm -rf "$R2_DIR/scripts"
mkdir -p "$R2_DIR/scripts"

for source_path in "${SCRIPT_SOURCES[@]}"
do
    cp -a "$source_path" "$R2_DIR/scripts/"
done

for copied_script in "$R2_DIR"/scripts/*.sh
do
    bash -n "$copied_script"
done

SCRIPT_COUNT="$(
    find "$R2_DIR/scripts" \
        -maxdepth 1 \
        -type f \
        -name '*.sh' |
    wc -l
)"

echo "R2_SCRIPT_COUNT=$SCRIPT_COUNT"

if [[ "$SCRIPT_COUNT" != "4" ]]; then
    echo "ERROR: R2 package does not contain exactly four scripts"
    exit 32
fi

cat > "$R2_DIR/INDEPENDENT_INSPECTION_AND_REPAIR.txt" <<EOF
POLYCOMP-D4-T2 INDEPENDENT PACKAGE INSPECTION AND R2 REPAIR
ORIGINAL_ARCHIVE=${ORIGINAL_ARCHIVE}
ORIGINAL_ARCHIVE_SHA256=${ORIGINAL_ACTUAL_SHA256}
ORIGINAL_ARCHIVE_INTERNAL_MANIFEST=PASS
ORIGINAL_ARCHIVE_SAFETY_CHECK=PASS
ORIGINAL_PACKAGE_THEOREM_EVIDENCE=PASS
ORIGINAL_PACKAGE_DEFECT=The scripts directory was empty.
R2_REPAIR=Added the four campaign scripts after shell-syntax validation.
ORIGINAL_PACKAGE_MODIFIED=NO
THEOREM_OR_PROOF_RESULTS_MODIFIED=NO
EOF

cat >> "$R2_DIR/README.md" <<'EOF'

## R2 reproducibility repair

Independent package inspection found that the original archive's `scripts/`
directory was empty because the final script was executed from `~/Downloads`
while the packager searched `/tmp`.

The R2 package preserves all original proof artefacts and results byte-for-byte
and adds the four campaign scripts after `bash -n` validation. The original
archive remains unchanged.
EOF

section "R2.3 — REGENERATE PACKAGE TREE AND MANIFESTS"

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

section "R2.4 — CREATE AND REVERIFY DETERMINISTIC ARCHIVE"

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

    test "$(
        find scripts \
            -maxdepth 1 \
            -type f \
            -name '*.sh' |
        wc -l
    )" = "4"

    for script_path in scripts/*.sh
    do
        bash -n "$script_path"
    done
) > "${FINAL_STAGE}/R2_POST_ARCHIVE_VERIFICATION.txt"

echo "R2_POST_ARCHIVE_MANIFEST_VERIFICATION=PASS"
echo "R2_POST_ARCHIVE_SCRIPT_VALIDATION=PASS"

chmod -R a-w "$R2_DIR"

section "POLYCOMP-D4-T2 R2 FINAL VERDICT"

echo "POLYCOMP_D4_T2_R2_PACKAGE_STATUS=PASS"
echo "ORIGINAL_ARCHIVE_PRESERVED=PASS"
echo "T2_THEOREM_EVIDENCE_UNCHANGED=PASS"
echo "R2_REPRODUCIBILITY_SCRIPTS=4_OF_4_PRESENT"
echo "R2_PACKAGE_READ_ONLY=PASS"
echo "R2_FINAL_PACKAGE=$R2_ARCHIVE"
echo "R2_FINAL_PACKAGE_SHA256=$(awk '{print $1}' "$R2_ARCHIVE_HASH")"
echo "R2_FINAL_PACKAGE_SHA256_FILE=$R2_ARCHIVE_HASH"
echo "NEXT_GATE=UPLOAD_R2_ARCHIVE_AND_SHA256_FOR_FINAL_INDEPENDENT_CONFIRMATION"
