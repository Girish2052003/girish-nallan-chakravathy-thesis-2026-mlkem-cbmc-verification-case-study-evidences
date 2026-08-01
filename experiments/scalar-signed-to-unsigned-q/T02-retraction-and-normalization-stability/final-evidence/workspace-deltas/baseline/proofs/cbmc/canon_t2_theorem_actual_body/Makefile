include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = canon_t2_theorem_harness

PROOF_UID = CANON-T2 theorem-only actual-body proof

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=
UNWINDSET +=

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly.c

# Actual-body policy: no theorem-bearing contract substitution.
CHECK_FUNCTION_CONTRACTS =
CHECK_FUNCTION_CONTRACTS_REC =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

# Default SAT backend is authoritative for this campaign.
EXTERNAL_SAT_SOLVER =
CBMCFLAGS =

CBMC_OBJECT_BITS = 8

include ../Makefile.common
