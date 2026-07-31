HARNESS_ENTRY = harness
HARNESS_FILE = pkcheck_t3_prefix_access_harness

PROOF_UID = pkcheck_t3_prefix_access
PROOF_DESCRIPTION = mlk_kem_check_pk public-seed suffix non-access

PROJECT = mlkem

# ML-KEM-768
MLKEM_K = 3

INCLUDES +=

REMOVE_FUNCTION_BODY +=

# The two MLK_FREE do-while(0) cleanup loops each execute once.
UNWINDSET += mlk_check_pk.0:1
UNWINDSET += mlk_check_pk.1:1

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/kem.c

USE_FUNCTION_CONTRACTS += mlk_polyvec_frombytes
USE_FUNCTION_CONTRACTS += mlk_polyvec_reduce
USE_FUNCTION_CONTRACTS += mlk_polyvec_tobytes
USE_FUNCTION_CONTRACTS += mlk_ct_memcmp
USE_FUNCTION_CONTRACTS += mlk_zeroize

APPLY_LOOP_CONTRACTS = on

EXTERNAL_SAT_SOLVER =

include ../Makefile.common
