#!/usr/bin/env bash
set -euo pipefail

DIR="/home/girish/THESIS-2026/mlk_poly_sub_cleanroom/SUB00A_d9613cf60de3"
SRC="${DIR}/source"
HARNESS_DIR="${DIR}/harness_drafts_v1"

ARCH="${DIR}/SUB00C_INDEPENDENT_HARNESS_ARCHITECTURE.md"
MANIFEST="${DIR}/SUB00C_HARNESS_DRAFT_MANIFEST.sha256"

OUT="${DIR}/SUB00D_BUILD_CONTEXT_DISCOVERY.txt"
HASH="${OUT}.sha256"

EXPECTED_ARCH_SHA256="a1d11264cf27038fed35ccddced2c6f79c5e28f42382e5000ce7fe7a44689d84"

test -d "${DIR}" || {
    echo "ERROR: Missing campaign directory: ${DIR}"
    exit 1
}

test -d "${SRC}" || {
    echo "ERROR: Missing source-only export: ${SRC}"
    exit 1
}

test -d "${HARNESS_DIR}" || {
    echo "ERROR: Missing harness draft directory: ${HARNESS_DIR}"
    exit 1
}

test -f "${ARCH}" || {
    echo "ERROR: Missing SUB-00C architecture file."
    exit 1
}

test -f "${MANIFEST}" || {
    echo "ERROR: Missing draft source manifest."
    exit 1
}

ACTUAL_ARCH_SHA256="$(sha256sum "${ARCH}" | awk '{print $1}')"

test "${ACTUAL_ARCH_SHA256}" = "${EXPECTED_ARCH_SHA256}" || {
    echo "ERROR: SUB-00C architecture integrity failure."
    echo "Expected: ${EXPECTED_ARCH_SHA256}"
    echo "Actual:   ${ACTUAL_ARCH_SHA256}"
    exit 1
}

test ! -e "${OUT}" || {
    echo "ERROR: Discovery output already exists:"
    echo "${OUT}"
    exit 1
}

echo "Verifying all six draft harnesses..."

(
    cd "${HARNESS_DIR}"
    sha256sum --check "${MANIFEST}"
)

{
    echo "============================================================"
    echo "SUB-00D BUILD-CONTEXT DISCOVERY"
    echo "============================================================"
    echo
    echo "Frozen commit:"
    echo "d9613cf60de3132d32475c102d8c2781d84feb34"
    echo
    echo "SUB-00C architecture SHA-256:"
    echo "${ACTUAL_ARCH_SHA256}"
    echo
    echo "Collection time UTC:"
    date -u +%Y-%m-%dT%H:%M:%SZ

    echo
    echo "============================================================"
    echo "DRAFT HARNESS INTEGRITY"
    echo "============================================================"
    (
        cd "${HARNESS_DIR}"
        sha256sum --check "${MANIFEST}"
    )

    echo
    echo "============================================================"
    echo "TOOL ENVIRONMENT"
    echo "============================================================"
    cbmc --version 2>&1 | head -n 10
    echo
    goto-cc --version 2>&1 | head -n 10
    echo
    cc --version 2>&1 | head -n 10
    echo
    uname -a
    echo
    getconf LONG_BIT 2>/dev/null || true

    echo
    echo "============================================================"
    echo "HOST PREPROCESSOR MACHINE MACROS"
    echo "============================================================"
    printf '\n' |
        cc -dM -E - 2>/dev/null |
        grep -E \
          '__BYTE_ORDER__|__ORDER_LITTLE_ENDIAN__|__ORDER_BIG_ENDIAN__|__SIZEOF_POINTER__|__SIZEOF_INT__|__SIZEOF_SHORT__|__CHAR_BIT__' |
        LC_ALL=C sort || true

    echo
    echo "============================================================"
    echo "SOURCE ROOT INVENTORY"
    echo "============================================================"
    find "${SRC}" -maxdepth 2 -type f -printf '%P\n' |
        LC_ALL=C sort

    echo
    echo "============================================================"
    echo "CONFIGURATION AND BUILD FILES"
    echo "============================================================"
    find "${SRC}" -type f \
        \( -iname 'Makefile*' \
        -o -iname '*.mk' \
        -o -iname 'CMakeLists.txt' \
        -o -iname '*config*.h' \
        -o -iname '*config*.c' \
        -o -iname '*config*.in' \
        \) \
        -printf '%P\n' |
        LC_ALL=C sort

    echo
    echo "============================================================"
    echo "CONFIGURATION INCLUDE LOCATIONS"
    echo "============================================================"
    grep -RInE \
        --exclude-dir=proofs \
        --exclude-dir=tests \
        --exclude-dir=test \
        --exclude-dir=examples \
        '#[[:space:]]*include[[:space:]]+["<][^">]*config[^">]*[">]' \
        "${SRC}" 2>/dev/null || true

    echo
    echo "============================================================"
    echo "REQUIRED CONFIGURATION MACROS"
    echo "============================================================"
    grep -RInE \
        --exclude-dir=proofs \
        --exclude-dir=tests \
        --exclude-dir=test \
        --exclude-dir=examples \
        'MLK_CONFIG_PARAMETER_SET|MLK_CONFIG_NAMESPACE_PREFIX|MLK_CONFIG_NO_ASM|MLK_CONFIG_MULTILEVEL|MLK_CONFIG_USE_NATIVE_BACKEND_ARITH|MLK_CONFIG_INTERNAL_API_QUALIFIER|MLK_CONFIG_FILE' \
        "${SRC}" 2>/dev/null |
        head -n 1000 || true

    echo
    echo "============================================================"
    echo "NATIVE POLY REDUCE SELECTION"
    echo "============================================================"
    grep -RInE \
        --exclude-dir=proofs \
        --exclude-dir=tests \
        --exclude-dir=test \
        --exclude-dir=examples \
        'MLK_USE_NATIVE_POLY_REDUCE|MLK_CONFIG_NO_ASM|mlk_poly_reduce_native' \
        "${SRC}/mlkem" 2>/dev/null |
        head -n 500 || true

    echo
    echo "============================================================"
    echo "POLY SOURCE INCLUDE DEPENDENCIES"
    echo "============================================================"
    grep -nE '^[[:space:]]*#[[:space:]]*include' \
        "${SRC}/mlkem/src/poly.c" \
        "${SRC}/mlkem/src/poly.h" 2>/dev/null || true

    echo
    echo "============================================================"
    echo "CANDIDATE PUBLIC CONFIG FILE CONTENTS"
    echo "============================================================"

    while IFS= read -r file
    do
        case "${file}" in
            */proofs/*|*/tests/*|*/test/*|*/examples/*)
                continue
                ;;
        esac

        echo
        echo "------------------------------------------------------------"
        echo "FILE: ${file#${SRC}/}"
        echo "------------------------------------------------------------"
        nl -ba "${file}" | sed -n '1,400p'
    done < <(
        find "${SRC}" -type f \
            \( -iname 'mlkem_native_config.h' \
            -o -iname 'mlkem_native_config.h.in' \
            -o -iname '*default*config*.h' \
            -o -iname 'config.h' \
            \) |
            LC_ALL=C sort
    )

    echo
    echo "============================================================"
    echo "DRAFT HARNESS INCLUDE AND CALL SUMMARY"
    echo "============================================================"

    for file in \
        sub_t1_semantic_harness.c \
        sub_t2_relational_harness.c \
        sub_cov_reachability_harness.c \
        sub_boundary_valid_extremes_harness.c \
        sub_boundary_invalid_lower_harness.c \
        sub_boundary_invalid_upper_harness.c
    do
        echo
        echo "FILE: ${file}"
        grep -nE \
            '#include|mlk_poly_sub|mlk_poly_reduce|__CPROVER_assume|__CPROVER_assert|__CPROVER_cover' \
            "${HARNESS_DIR}/${file}" || true
    done

    echo
    echo "============================================================"
    echo "DISCOVERY STATUS"
    echo "============================================================"
    echo
    echo "No CBMC theorem proof was executed."
    echo "No existing repository poly_sub harness was inspected."
    echo "No existing proof Makefile was copied."
    echo "No harness source was modified."

} > "${OUT}"

sha256sum "${OUT}" > "${HASH}"

echo
echo "============================================================"
echo "SUB-00D BUILD-CONTEXT DISCOVERY COMPLETED"
echo "============================================================"
echo
cat "${HASH}"
echo
echo "Upload:"
echo "1. ${OUT}"
echo "2. ${HASH}"
echo
echo "Do not run CBMC theorem proofs yet."
echo "Do not open proofs/cbmc/poly_sub/poly_sub_harness.c."
