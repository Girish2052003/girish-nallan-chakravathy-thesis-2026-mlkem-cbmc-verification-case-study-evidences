# Negative, inconclusive, excluded and conflicting evidence ledger

This ledger prevents a passing-result narrative from suppressing contrary, unresolved, invalid, partially preserved or internally conflicting evidence. `EVIDENCE_SOURCE_CONFLICT` records are resolved under the evidence hierarchy: the frozen source and raw tool evidence control over a stale or inaccurate narrative summary.

## Boundary-category vocabulary and namespace

This file is a **27-row material-boundary ledger**, not a second copy of the 257-row substantive property/control ledger. Its `Category` column has sixteen permitted values. Three names (`MEANINGFUL_NEGATIVE`, `ABSTRACTION_LIMITED_INCONCLUSIVE`, and `RESOURCE_LIMITED_INCONCLUSIVE`) intentionally coincide with property-result labels because those boundary rows directly preserve the same scientific outcome. The remaining category names describe preservation, exclusion, controls, conflict resolution, scope, reporting, or provenance and are not additional property-result classes.

| Category | Definition |
|---|---|
| `MEANINGFUL_NEGATIVE` | Registered candidate proposition contradicted within its recorded domain/model; retains the same scientific status as the matching property-result classification. |
| `ABSTRACTION_LIMITED_INCONCLUSIVE` | No production-level acceptance/refutation because the retained abstraction is insufficient. |
| `RESOURCE_LIMITED_INCONCLUSIVE` | No completed verdict within the retained resource boundary; not success or failure. |
| `EVIDENCE_SOURCE_CONFLICT` | Retained sources materially disagree; the evidence hierarchy resolves the fact and the stale/lower-authority wording cannot strengthen the claim. |
| `PARTIAL_PRESERVATION` | Required supporting/raw evidence is incompletely retained; this boundary category is distinct from the property-result class `SUPPORTED_WITH_PARTIAL_PRESERVATION`. |
| `SUPERSEDED_REPAIRED_FAILURE` | Earlier invalid/unsuccessful attempt later repaired; retained for provenance, while only accepted repaired evidence supports the final claim. |
| `NOT_TESTED` | Planned check was deferred or not executed to a verdict; do not recode as success or failure. |
| `EXCLUDED_TEMPLATE` | Incomplete placeholder/template excluded from accepted evidence. |
| `EXPECTED_FAILURE_CONTROL` | Deliberately stronger/false control expected to fail; intended failure is evidential sensitivity/boundary evidence, not a production defect. |
| `SUPPORTING_ONLY` | Supporting replay/observation that is not a complete replication, matched run, or additional independent accepted result. |
| `OUT_OF_SCOPE` | Assurance dimension deliberately outside the registered model/campaign; no conclusion about that dimension follows. |
| `NOT_ESTABLISHED` | Evidence does not justify the named stronger conclusion. |
| `COUNTING_BOUNDARY` | Mechanical/tool count must not be converted into an equal count of independent scientific claims/theorems. |
| `NOT_CLAIMED` | Stronger proposition is deliberately excluded from accepted wording; absence of the claim is neither support nor refutation. |
| `EXCLUDED_INVALID` | Material lacking required authentic evidence is excluded from the accepted corpus and cannot upgrade a scientific result. |
| `NOT_DEMONSTRABLE` | Available evidence cannot demonstrate the stronger causal/attribution/efficiency/superiority claim; this is a reporting boundary, not a result for the underlying properties. |

### Boundary-ID grammar

`NEG-`, `LIM-`, `EXC-`, `CTRL-`, `INC-`, `REP-`, and `CONFLICT-` are navigation mnemonics only. The `Category` column is authoritative. `LIM-` deliberately spans several categories, so category must never be inferred from the prefix alone.

### Boundary-to-substantive-scope relationship

Every boundary ID is cross-referenced in [`06_BOUNDARY_TO_SUBSTANTIVE_SCOPE_CROSSWALK.csv`](06_BOUNDARY_TO_SUBSTANTIVE_SCOPE_CROSSWALK.csv). The crosswalk distinguishes direct substantive-property relationships from property-family, auxiliary-control, excluded-artefact, case-level, native-comparison, historical-repair, and shared-RQ2 relationships. `NO_SINGLE_PROPERTY_ROW` is an explicit relationship state rather than a missing value.

| Record | Case | Item | Category | Observed evidence | Final treatment |
|---|---|---|---|---|---|
| NEG-C01-PA03 | 1 | PA-03 unrestricted signed exact addition | MEANINGFUL_NEGATIVE | Expected counterexample when mathematical sum is not int16_t-representable. | Retain as a domain-boundary result; it does not refute PA-02A. |
| NEG-C01-PA04B | 1 | PA-04B unrestricted alias doubling | MEANINGFUL_NEGATIVE | Expected finite-width/conversion counterexample. | Retain as an out-of-contract aliasing diagnostic; do not authorize production aliasing. |
| LIM-C01-PA02B | 1 | PA-02B final raw verdict | PARTIAL_PRESERVATION | Harness and reporting remain, but final raw verdict marker is not fully retained. | Report property with partial-preservation qualification. |
| LIM-C01-PA06 | 1 | Complete PA-06 15-unit parameter matrix | PARTIAL_PRESERVATION | A-to-Z report records replication; complete raw matrix not retained. | Do not claim complete raw preservation of all units. |
| LIM-C01-PA07 | 1 | Complete PA-07 mutant–harness matrix | PARTIAL_PRESERVATION | Baseline and documentation retained; complete matrix absent. | Mutation conclusion remains qualified. |
| LIM-C01-PA08 | 1 | Executed PA-08 result directory | PARTIAL_PRESERVATION | Harnesses/runner retained without complete executed raw results. | Do not claim complete executed PA-08 preservation. |
| LIM-C02-T3M | 2 | SUB-T3 mutation analysis | NOT_TESTED | Deferred rather than executed. | Do not recode as success or failure. |
| EXC-C02-T4TPL | 2 | Professor-facing T4 template with @@RUN4_HASH@@ | EXCLUDED_TEMPLATE | Unresolved placeholder. | Excluded from final hash evidence; does not replace valid raw campaign records. |
| LIM-C03-REPLAY | 3 | Later-revision VC-SR1 replay | SUPPORTING_ONLY | Positive relation repeated without every original control. | Supporting cross-revision evidence, not complete replication or another matched run. |
| LIM-C06-BACKEND | 6 | D4 backend equivalence | OUT_OF_SCOPE | Only pinned portable-C implementation checked. | No assembly/native-backend equivalence claim. |
| LIM-C08-NOVELTY | 8 | Worldwide Barrett novelty | NOT_ESTABLISHED | Repository-relative distinctness supported; wider prior assurance exists. | No first-ever mathematical or formal-proof claim. |
| LIM-C09-PHYSICAL | 9 | Universal physical remanence elimination | OUT_OF_SCOPE | CBMC supports the C abstract-machine poststate only. | No compiler/hardware/physical-erasure conclusion. |
| LIM-C10-COUNT | 10 | 1,046 emitted CBMC properties | COUNTING_BOUNDARY | Includes indexed obligations and tool-generated safety checks. | Do not report as 1,046 independent theorems or scientific claims. |
| LIM-C11-CANON | 11 | Arbitrary-byte modulo-q canonicalization | NOT_CLAIMED | Production relation is raw 12-bit unpacking. | Explicitly exclude general canonical decoding claim. |
| INC-C13-SEED | 13 | Two-call seed noninterference | ABSTRACTION_LIMITED_INCONCLUSIVE | Counterexample arose in a lower abstraction lacking the required relational guarantee. | No production-defect conclusion; local accepted claims remain. |
| INC-C14-T2 | 14 | MONT-T2 relational fibre family | RESOURCE_LIMITED_INCONCLUSIVE | No completed verdict or counterexample after researcher-reported >~6.5h continuous execution. | Candidate retained unresolved. |
| INC-C14-T3 | 14 | MONT-T3 normalized multiplication family | RESOURCE_LIMITED_INCONCLUSIVE | No completed verdict or counterexample after researcher-reported >~6.5h continuous execution. | Candidate retained unresolved. |
| INC-C14-T4 | 14 | MONT-T4 polynomial conversion family | RESOURCE_LIMITED_INCONCLUSIVE | No completed verdict or counterexample after researcher-reported >~6.5h continuous execution. | Candidate retained unresolved. |
| EXC-C14-SYN | 14 | Synthetic/manual T2–T4 success summaries and mutation claims | EXCLUDED_INVALID | Not backed by authentic completed CBMC records. | Excluded from accepted evidence. |
| LIM-RQ2-ATTR | RQ2 | Every skill output incorporated / individual skill causation | NOT_DEMONSTRABLE | All nine invoked and produced outputs in 4/4; configuration-level inspection recorded; complete per-invocation decision provenance absent. | Report collective configuration contribution and positive bounded mechanical usefulness for Skills 2–5; do not claim individual causal effectiveness. |
| LIM-RQ2-EFF | RQ2 | Time/token/quota efficiency comparison | NOT_DEMONSTRABLE | No balanced comparable telemetry. | No numerical efficiency or superiority claim. |
| REP-C01-PA01V1 | 1 | Initial PA-01 V1 artefact missing a symbolic-input helper body | SUPERSEDED_REPAIRED_FAILURE | The first artefact did not produce a valid verification result because a required helper body was absent. | Retain as autonomous repair history; only the repaired V2 result supports the accepted PA-01 claims. |
| CTRL-C02-T4LOW | 2 | SUB-T4 false stronger lower bound | EXPECTED_FAILURE_CONTROL | The deliberately strengthened lower bound excluded the attainable -3328 endpoint and failed as intended. | Retain as boundary-tightness/non-vacuity control; not a defect in the production function. |
| CTRL-C02-T4UP | 2 | SUB-T4 false stronger upper bound | EXPECTED_FAILURE_CONTROL | The deliberately strengthened upper bound excluded the attainable 3328 endpoint and failed as intended. | Retain as boundary-tightness/non-vacuity control; not a defect in the production function. |
| CONFLICT-C04-NATIVE-DIR | 4 | Retained MSG-T1 summary statement that no dedicated public poly_tomsg proof directory was located | EVIDENCE_SOURCE_CONFLICT | The frozen af4c5abd source tree contains `proofs/cbmc/poly_tomsg/poly_tomsg_harness.c` and its Makefile. | Frozen source controls. The native one-call harness is recorded as present; distinctness rests on the generated semantic/relational suite, not harness absence. |
| CONFLICT-C05-NATIVE-HARNESS | 5 | Retained FROMMSG summary wording stating no matching native harness or exact T1–T4 registry was identified | EVIDENCE_SOURCE_CONFLICT | The frozen af4c5abd source tree contains `proofs/cbmc/poly_frommsg/poly_frommsg_harness.c`; no identical generated T1–T4 suite is asserted by the census. | Wording qualified. Native one-call harness presence is acknowledged; only the exact multi-property suite remains repository-distinct within the inspected corpus. |
| CONFLICT-C07-NATIVE-DIR | 7 | Retained CANON summary statement that no eponymous scalar_signed_to_unsigned_q proof directory existed | EVIDENCE_SOURCE_CONFLICT | The frozen af4c5abd source tree contains `proofs/cbmc/scalar_signed_to_unsigned_q/scalar_signed_to_unsigned_q_harness.c` and its Makefile. | Frozen source controls. The directory and native one-call harness are recorded as present; distinctness rests on the seventeen generated semantic properties and controls. |

## Master-catalogue coverage rule

The master catalogue must expose the complete set of 27 unique boundary IDs. Case 12 records `None recorded for this investigation`. The two `NOT_DEMONSTRABLE` RQ2 rows apply jointly to all four skill-available investigations and are therefore repeated in each corresponding master section; repetition does not create additional boundary-ledger rows.
