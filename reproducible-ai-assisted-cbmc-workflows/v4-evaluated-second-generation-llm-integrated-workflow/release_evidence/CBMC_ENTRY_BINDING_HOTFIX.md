# Real CBMC Acceptance Entry-Binding Hotfix — 2026-07-15

## Trigger

The first Ubuntu host acceptance passed all 51 ordinary regressions, then
`goto-instrument --dfcc harness` aborted in `nondet_static` while processing the
synthetic function-contract fixture.

## Root cause

The synthetic sources intentionally have no C `main`. The acceptance script
compiled them without binding the intended proof harness as the GOTO entry
function. The generated model therefore lacked the entry identity required by
the subsequent DFCC/static-initialization path.

## Correction

Every synthetic `goto-cc` invocation now supplies an explicit entry:

- function-contract fixture: `--function harness`
- loop-contract fixture: `--function loop_harness`
- hybrid fixture: `--function hybrid_harness`
- malformed single-function fixtures: `--function f`

A new regression, `verify_real_cbmc_acceptance_entry_binding.py`, executes the
complete acceptance script against instrumented fake CBMC tools and rejects any
missing or incorrect entry binding.

## Claim boundary

This hotfix corrects the acceptance fixture. It does not claim that the real
CBMC gate has passed until `./RUN_FINAL_ACCEPTANCE_UBUNTU.sh` completes on the
Ubuntu host and prints `FINAL TRUST-CHAIN ACCEPTANCE: PASS`.
