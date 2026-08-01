include ../Makefile_params.common

HARNESS_ENTRY = harness
HARNESS_FILE = canon_t4_theorem_harness

PROOF_UID = CANON-T4 theorem-only actual-body Barrett composition

DEFINES +=
INCLUDES +=

REMOVE_FUNCTION_BODY +=
UNWINDSET +=

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/poly.c

# Both theorem-bearing functions must execute their actual bodies.
CHECK_FUNCTION_CONTRACTS =
CHECK_FUNCTION_CONTRACTS_REC =
USE_FUNCTION_CONTRACTS =
APPLY_LOOP_CONTRACTS =
USE_DYNAMIC_FRAMES =

EXTERNAL_SAT_SOLVER =
CBMCFLAGS =

CBMC_OBJECT_BITS = 8

include ../Makefile.common
