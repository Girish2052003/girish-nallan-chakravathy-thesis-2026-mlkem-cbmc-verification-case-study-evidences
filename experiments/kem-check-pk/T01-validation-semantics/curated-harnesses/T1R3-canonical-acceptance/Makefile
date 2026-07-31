# PKCHECK-T1R3 canonical-encoding acceptance.
#
# The target and polynomial serialization/reduction dependencies remain
# concrete. Only mlk_ct_memcmp and mlk_zeroize use their repository contracts.
# Non-DFCC contract replacement is used to avoid dynamic-frame memory overhead.

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = pkcheck_t1_r3_canonical_acceptance_harness

PROOF_UID = pkcheck_t1_r3_canonical_acceptance

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=

UNWINDSET += mlk_polyvec_frombytes.0:3
UNWINDSET += mlk_poly_frombytes_c.0:128
UNWINDSET += mlk_polyvec_reduce.0:3
UNWINDSET += mlk_poly_reduce_c.0:256
UNWINDSET += mlk_polyvec_tobytes.0:3
UNWINDSET += mlk_poly_tobytes_c.0:128
UNWINDSET += mlk_check_pk.0:1
UNWINDSET += mlk_check_pk.1:1

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c

PROJECT_SOURCES += $(SRCDIR)/mlkem/src/kem.c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly_k.c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly.c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/compress.c

USE_FUNCTION_CONTRACTS = mlk_ct_memcmp
USE_FUNCTION_CONTRACTS += mlk_zeroize

# Deliberately no USE_DYNAMIC_FRAMES and no loop-contract abstraction.
EXTERNAL_SAT_SOLVER =

FUNCTION_NAME = mlk_check_pk
CBMC_OBJECT_BITS = 10

EXPENSIVE = true

include ../Makefile.common
