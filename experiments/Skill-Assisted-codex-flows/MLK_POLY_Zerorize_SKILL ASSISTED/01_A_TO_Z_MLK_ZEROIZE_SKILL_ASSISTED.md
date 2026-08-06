# `mlk_zeroize` Skill-Assisted CBMC Corpus — AF4C5ABD-Only Record

## Campaign identity

```text
Folder:                MLK_POLY_Zerorize_SKILL ASSISTED
Technical target:      mlk_zeroize
Authoritative commit:  af4c5abdd5958bdc65a03cd5ee86708264f93304
Authoritative tree:    54805daff6a91a010c05467ea678117c42a71559
Runs occurred:         1
CBMC/GOTO:             6.9.0
Build context:         ML-KEM-768
Harness host:          16 writable bytes
Language:              C90
```

## Source policy

Every theorem, harness, command, ledger, evidence manifest, and final status in
this corpus refers exclusively to the commit and tree above. The runner rejects
all other source states before creating `evidence/run_1`. No result from another
commit may be copied into this corpus.

## New theorem SA-ZERO-T1

Two objects are equal outside one symbolic non-empty wipe interval and may have
arbitrarily different secret histories inside it. After equal real
`mlk_zeroize` calls, selected bytes are zero, outer frames are preserved, and
the complete post-state objects are identical.

## New theorem SA-ZERO-T2

A symbolic outer interval is wiped, a symbolic non-empty subrange is rewritten
with arbitrary data containing a nonzero witness, and only that subrange is
wiped again. The complete original interval must return to zero, the original
outer frame must remain unchanged, the second-call frame must remain unchanged,
and the rewritten witness must be erased.

## Preconditions and assumptions

- exact source commit and tree shown above;
- tracked repository state clean before execution;
- valid writable, non-aliasing slices inside the 16-byte harness objects;
- satisfiable symbolic bounds and explicit nontrivial witnesses;
- real `mlk_zeroize` body retained, without stubs or contract replacement;
- CBMC, `goto-cc`, and `goto-instrument` 6.9.0;
- unwind 17 with unwinding assertions enabled;
- the theorem concerns the C abstract-machine state, not physical remanence.

## Postconditions

The assertion inventory includes exact erasure, frame preservation, whole-object
history convergence, complete recovery after recontamination, and erasure of a
concrete rewritten witness.

## Reachability and feasibility

Separate coverage models require satisfiable assumption states, nonzero or
difference witnesses, every target return, the recontamination step, and the
final assertion block. Unsatisfied cover goals prevent final acceptance.

## Sensitivity

Each theorem has one deliberately false claim. It must fail with CBMC exit 10
at the named property. Compile failures and unrelated failures are rejected.

## Evidence produced

The sole run stores source hashes, tool versions, exact source identity, terminal transcript, exact checkout/build/proof commands,
preprocessed harnesses, three GOTO models per theorem, function/symbol/loop and
property inventories, body-binding JSON, proof JSON, coverage JSON, fail-control traces, exit
codes, theorem hashes, repository-distinctness audit, final status, and a full
run SHA-256 manifest.

## Acceptance markings

```text
RUNS OCCURED               1
Selected-claim mapping     YES
Target reachability        YES
Assertion reachability     YES
Assumption feasibility     YES
Evidence completeness      COMPLETE
Repository distinctness    SUPPORTED
Contamination              NONE KNOWN
```

The static matrix is a required acceptance target. The authoritative issuance
is `evidence/run_1/final_status.json`, generated only after every gate passes at
commit `af4c5abdd5958bdc65a03cd5ee86708264f93304` and tree `54805daff6a91a010c05467ea678117c42a71559`.
