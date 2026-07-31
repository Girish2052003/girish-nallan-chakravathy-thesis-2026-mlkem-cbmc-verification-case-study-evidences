# Clean-room functional proof.
# Production mlkem-native C files are not modified.

include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = mont_t2b_fibre_translation_harness

PROOF_UID = MONT-T2B affine fibre laws

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=
UNWINDSET +=

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly.c

# Do not replace mlk_montgomery_reduce with its weak native contract.
# The actual function body must execute in this functional harness.
CHECK_FUNCTION_CONTRACTS =
USE_FUNCTION_CONTRACTS =

APPLY_LOOP_CONTRACTS = on
USE_DYNAMIC_FRAMES = 1

EXTERNAL_SAT_SOLVER =
CBMCFLAGS =

FUNCTION_NAME = mlk_montgomery_reduce
CBMC_OBJECT_BITS = 8

include ../Makefile.common
