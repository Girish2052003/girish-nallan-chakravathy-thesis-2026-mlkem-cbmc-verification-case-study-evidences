HARNESS_FILE = pkcheck_t4_guard_dominance_harness
HARNESS_ENTRY = harness

PROOF_UID = pkcheck_t4_guard_dominance
PROOF_DESCRIPTION = mlk_kem_enc_derand public-key validation guard dominance

PROJECT = mlkem
MLKEM_K = 3

INCLUDES +=

# Replace only the internal lower public-key checker with the harness stub.
# The internal mlk_enc_derand target body remains concrete.
REMOVE_FUNCTION_BODY += mlk_check_pk

UNWINDSET += mlk_enc_derand.0:1
UNWINDSET += mlk_enc_derand.1:1

PROOF_SOURCES += $(PROOFDIR)/$(HARNESS_FILE).c
PROJECT_SOURCES += $(SRCDIR)/mlkem/src/kem.c

USE_FUNCTION_CONTRACTS += mlk_zeroize
APPLY_LOOP_CONTRACTS = on

EXTERNAL_SAT_SOLVER =

include ../Makefile.common
