include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = canon_t1_harness

PROOF_UID = CANON-T1 actual-body equivalence and fibre theorem

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=
UNWINDSET +=

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly.c

# CANON actual-body policy:
CHECK_FUNCTION_CONTRACTS =
CHECK_FUNCTION_CONTRACTS_REC =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

# Use CBMC's default SAT backend for the authoritative first run.
EXTERNAL_SAT_SOLVER =
CBMCFLAGS =

CBMC_OBJECT_BITS = 8

include ../Makefile.common
