include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = polycomp_d4_t2_relational_byte_locality_harness
PROOF_UID = polycomp_d4_t2_relational_byte_locality_20260725T173345Z

DEFINES +=
INCLUDES +=
REMOVE_FUNCTION_BODY +=

CHECK_FUNCTION_CONTRACTS =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/compress.c

UNWINDSET +=
CBMCFLAGS = --smt2
EXTERNAL_SAT_SOLVER =

FUNCTION_NAME = mlk_poly_decompress_d4_c
CBMC_OBJECT_BITS = 8

include ../Makefile.common
