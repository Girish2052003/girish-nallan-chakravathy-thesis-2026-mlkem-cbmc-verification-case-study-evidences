# ML-KEM `mlk_zeroize` CBMC campaign evidence

This directory contains the classified evidence for the **Source-Level Zeroization and Release-Handoff Verification** campaign at pinned mlkem-native commit `af4c5abdd5958bdc65a03cd5ee86708264f93304` using ML-KEM-768 and CBMC 6.9.0.

## Campaign structure

- `00-campaign-setup/`: body-binding preflight, source binding, assumptions, theorem registry and shared command records.
- `T01-exact-slice-erasure-and-prestate-independence/`: exact selected-slice erasure, pre-state independence and expected-failure control.
- `T02-frame-confinement-and-zero-length-identity/`: prefix/suffix/unrelated-object frame properties and zero-length identity.
- `T03-relational-and-compositional-zeroization-laws/`: idempotence, adjacent composition, commutativity and overlap-union laws.
- `T04-zero-before-release-handoff/`: preserved failed Run1 and accepted default/custom `MLK_FREE` release-handoff Run2.
- `V01-mutation-sensitivity/`: locked eight-mutant plan and execution evidence.
- `campaign-closure/`: final property matrix, package audits, preserved verifier-parser failure and final campaign verdict.

The supplied campaign reports 16 of 16 accepted core properties and 8 of 8 selected mutants killed. These are source-reported results preserved from the supplied evidence; this classification process did not rerun CBMC.
