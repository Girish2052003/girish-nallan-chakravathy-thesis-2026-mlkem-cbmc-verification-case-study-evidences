# PBCODEC-CV1 clean-room direct-composition validation

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = pbcodec_cv1_nonvacuity_harness
PROOF_UID = pbcodec_cv1_nonvacuity

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=
UNWINDSET +=

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/compress.c

CHECK_FUNCTION_CONTRACTS =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

EXTERNAL_SAT_SOLVER =
CBMCFLAGS =

FUNCTION_NAME = mlk_poly_tobytes
CBMC_OBJECT_BITS = 9

include ../Makefile.common

CBMCFLAGS += --unwindset harness.0:257,mlk_poly_tobytes_c.0:129,mlk_poly_frombytes_c.0:129
CBMCFLAGS += --unwinding-assertions
CBMCFLAGS += --bounds-check
CBMCFLAGS += --pointer-check
CBMCFLAGS += --pointer-overflow-check
CBMCFLAGS += --signed-overflow-check
CBMCFLAGS += --unsigned-overflow-check
CBMCFLAGS += --conversion-check
CBMCFLAGS += --undefined-shift-check
CBMCFLAGS += --div-by-zero-check
