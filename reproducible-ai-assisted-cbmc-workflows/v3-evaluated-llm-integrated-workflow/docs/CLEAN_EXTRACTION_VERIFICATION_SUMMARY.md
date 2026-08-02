# Clean-Extraction Verification Summary

The release candidate was packaged, extracted into a new directory, installed into a new virtual environment from `requirements.txt`, and tested from that untouched extraction.

## Passed gates

- all packaged-file SHA-256 checks;
- pinned dependency installation;
- Python compilation and all production CLIs;
- strict schemas and canonical configuration;
- historical Blockers 3–8 integration suite;
- frozen eight-session architecture conformance;
- deployment/API/formal-build safety gate;
- P01–P26 native-contract strategy suite;
- contract-aware repair and claim-boundary suite;
- orchestrator-level P12 native-loop and P19 analysis-only routing;
- exactly 26 property configuration fragments.

Every suite returned exit code `0` when run sequentially. Two process-heavy tests were initially killed with signal `-9` only when six suites were intentionally launched in parallel in the constrained sandbox; both passed immediately when rerun sequentially. This resource event is not represented as a software pass or failure.

## External experiment boundary

No university API key was used. The sandbox did not contain real `cbmc`, `goto-cc`, or `goto-instrument` binaries. The local operational preflight must pass on the Ubuntu experiment machine before a real campaign.
