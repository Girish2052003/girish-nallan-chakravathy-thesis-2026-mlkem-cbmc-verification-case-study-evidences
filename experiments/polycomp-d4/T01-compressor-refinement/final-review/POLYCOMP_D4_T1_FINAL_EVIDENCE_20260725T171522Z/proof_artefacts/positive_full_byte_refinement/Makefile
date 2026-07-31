# POLYCOMP-D4-T1 clean-room semantic preflight

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = polycomp_d4_t1_packed_refinement_harness

PROOF_UID = polycomp_d4_t1_packed_refinement

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=

#
# Execute implementation and harness loops directly.
# Do not replace the implementation with a function contract.
#
CHECK_FUNCTION_CONTRACTS =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/compress.c

#
# 257 is sufficient for the 256-iteration canonical-domain loop.
# It also completely covers the compressor's 32- and 8-iteration loops
# and the 128-iteration postcondition loop.
#
UNWINDSET +=
CBMCFLAGS = --smt2
CBMCFLAGS += --unwind 257
CBMCFLAGS += --unwinding-assertions

EXTERNAL_SAT_SOLVER =

FUNCTION_NAME = mlk_poly_compress_d4_c
CBMC_OBJECT_BITS = 8

include ../Makefile.common
