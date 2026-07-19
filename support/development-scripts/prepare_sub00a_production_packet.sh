#!/usr/bin/env bash
set -euo pipefail

REPO="/home/girish/THESIS-2026/mlkem-native"
COMMIT="d9613cf60de3132d32475c102d8c2781d84feb34"

ROOT="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom"
CASE_DIR="${ROOT}/SUB00A_${COMMIT:0:12}"
SOURCE_DIR="${CASE_DIR}/source"

PACKET="${CASE_DIR}/SUB00A_PRODUCTION_INPUT_PACKET.txt"
SOURCE_MANIFEST="${CASE_DIR}/SUB00A_SOURCE_MANIFEST.sha256"
PACKET_HASH="${PACKET}.sha256"

echo "Checking frozen repository..."

test -d "${REPO}/.git" || {
    echo "ERROR: Repository not found: ${REPO}"
    exit 1
}

ACTUAL_COMMIT="$(git -C "${REPO}" rev-parse HEAD)"

test "${ACTUAL_COMMIT}" = "${COMMIT}" || {
    echo "ERROR: Wrong commit."
    echo "Expected: ${COMMIT}"
    echo "Actual:   ${ACTUAL_COMMIT}"
    exit 1
}

# Tracked files must be unchanged.
# Untracked poly_add evidence is allowed because it will not enter the export.
git -C "${REPO}" diff --quiet -- || {
    echo "ERROR: Tracked working-tree files have modifications."
    exit 1
}

git -C "${REPO}" diff --cached --quiet -- || {
    echo "ERROR: Staged tracked modifications exist."
    exit 1
}

if [ -e "${CASE_DIR}" ]; then
    echo "ERROR: Clean-room directory already exists:"
    echo "${CASE_DIR}"
    echo "Nothing was overwritten."
    exit 1
fi

mkdir -p "${SOURCE_DIR}"

echo "Exporting only files tracked at the frozen commit..."

git -C "${REPO}" archive --format=tar "${COMMIT}" |
    tar -xf - -C "${SOURCE_DIR}"

# These deletions affect only the new clean-room copy.
rm -rf \
    "${SOURCE_DIR}/proofs" \
    "${SOURCE_DIR}/test" \
    "${SOURCE_DIR}/tests" \
    "${SOURCE_DIR}/examples"

# Remove any remaining tracked file explicitly named as a harness.
find "${SOURCE_DIR}" -type f -iname '*harness*' -delete

# Confirm that no proof directory or harness file remains.
if find "${SOURCE_DIR}" \
    \( -path '*/proofs/*' -o -type f -iname '*harness*' \) \
    -print -quit | grep -q .; then
    echo "ERROR: Forbidden proof/harness material remains."
    exit 1
fi

emit_full_file()
{
    local relative_path="$1"
    local absolute_path="${SOURCE_DIR}/${relative_path}"

    if [ -f "${absolute_path}" ]; then
        echo
        echo "================================================================"
        echo "FULL FILE: ${relative_path}"
        echo "================================================================"
        nl -ba "${absolute_path}"
    else
        echo
        echo "MISSING OPTIONAL FILE: ${relative_path}"
    fi
}

emit_file_slice()
{
    local relative_path="$1"
    local first_line="$2"
    local last_line="$3"
    local absolute_path="${SOURCE_DIR}/${relative_path}"

    if [ -f "${absolute_path}" ]; then
        echo
        echo "================================================================"
        echo "FILE SLICE: ${relative_path}:${first_line}-${last_line}"
        echo "================================================================"
        nl -ba "${absolute_path}" |
            sed -n "${first_line},${last_line}p"
    else
        echo
        echo "MISSING FILE: ${relative_path}"
    fi
}

{
    echo "================================================================"
    echo "SUB-00A BLIND PRODUCTION INPUT PACKET"
    echo "================================================================"
    echo
    echo "Repository: ${REPO}"
    echo "Frozen commit: ${COMMIT}"
    echo "Branch at collection: $(git -C "${REPO}" branch --show-current)"
    echo "Collection time UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "CBMC: $(cbmc --version 2>&1 | head -n 1)"
    echo "goto-cc: $(goto-cc --version 2>&1 | head -n 1)"
    echo "Compiler: $(cc --version 2>&1 | head -n 1)"
    echo "Architecture: $(uname -m)"
    echo
    echo "CLEAN-ROOM RESTRICTION:"
    echo "No repository proof harness, proof report, proof Makefile,"
    echo "proof JSON output or dedicated poly_sub proof source was"
    echo "included in this source-only export."
    echo
    echo "INITIAL-DISCOVERY DISCLOSURE NOTE:"
    echo "The initial discovery grep accidentally matched untracked"
    echo "poly_add-era logs. Those logs exposed generic CBMC safety"
    echo "success lines for poly_sub and poly_reduce. Consequently,"
    echo "basic overflow, bounds and pointer-safety checks are not"
    echo "eligible for novelty claims in the poly_sub campaign."
    echo
    echo "================================================================"
    echo "SOURCE-ONLY FILE INVENTORY"
    echo "================================================================"

    find "${SOURCE_DIR}/mlkem/src" \
        -maxdepth 3 \
        -type f \
        -printf '%P\n' |
        LC_ALL=C sort

    emit_full_file "mlkem/src/poly.c"
    emit_full_file "mlkem/src/poly.h"
    emit_full_file "mlkem/src/params.h"
    emit_full_file "mlkem/src/common.h"
    emit_full_file "mlkem/src/verify.h"
    emit_full_file "mlkem/src/indcpa.h"
    emit_full_file "mlkem/src/sys.h"
    emit_full_file "mlkem/src/config.h"
    emit_full_file "mlkem/src/namespace.h"
    emit_full_file "mlkem/src/native/api.h"

    # Only the production context surrounding the subtraction caller.
    emit_file_slice "mlkem/src/indcpa.c" 540 645

} > "${PACKET}"

echo "Hashing the clean-room source snapshot..."

find "${SOURCE_DIR}" -type f -print0 |
    LC_ALL=C sort -z |
    xargs -0 sha256sum > "${SOURCE_MANIFEST}"

sha256sum "${PACKET}" > "${PACKET_HASH}"

echo
echo "CLEAN-ROOM PACKET CREATED SUCCESSFULLY"
echo
echo "Upload these three files:"
echo "1. ${PACKET}"
echo "2. ${PACKET_HASH}"
echo "3. ${SOURCE_MANIFEST}"
echo
echo "Do not open the repository proofs directory."
