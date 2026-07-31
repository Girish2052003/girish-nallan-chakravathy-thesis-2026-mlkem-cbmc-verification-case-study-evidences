# PKCHECK-01B actual-body admission proof.
#
# No production polyvector semantic body is replaced by a contract.
# The default SAT backend is used because the local SMT2/Z3 route failed
# independently of the verification conditions.

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = pkcheck_01b_actual_body_harness

PROOF_UID = pkcheck_01b_actual_body

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=
UNWINDSET += mlk_polyvec_frombytes.0:3
UNWINDSET += mlk_poly_frombytes_c.0:128
UNWINDSET += mlk_polyvec_reduce.0:3
UNWINDSET += mlk_poly_reduce_c.0:256
UNWINDSET += mlk_polyvec_tobytes.0:3
UNWINDSET += mlk_poly_tobytes_c.0:128

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c

# Actual target and actual semantic dependencies.
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/kem.c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly_k.c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly.c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/compress.c

# These contracts are exact enough for the present purpose:
# - mlk_ct_memcmp: return==0 iff every compared byte is equal.
# - mlk_zeroize: frame/write-set abstraction for cleanup only.
USE_FUNCTION_CONTRACTS = mlk_ct_memcmp
USE_FUNCTION_CONTRACTS += mlk_zeroize

USE_DYNAMIC_FRAMES = 1

# Deliberately do NOT set APPLY_LOOP_CONTRACTS.
# Exact semantic loops are fully unwound instead.
EXTERNAL_SAT_SOLVER =
CBMCFLAGS += --unwind 400 --unwinding-assertions

FUNCTION_NAME = mlk_check_pk
CBMC_OBJECT_BITS = 10

EXPENSIVE = true

include ../Makefile.common
