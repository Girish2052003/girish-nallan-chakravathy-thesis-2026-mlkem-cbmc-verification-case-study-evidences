# Terminology and claim policy

## Required ordinary prose

Use **candidate verification property**, **property family**, **verification obligation**, **CBMC-supported bounded verification claim**, **meaningful-negative result**, **abstraction-limited result**, and **resource-limited unresolved property family**.

Historical filenames and identifiers containing `THEOREM`, `T1`, `T2`, etc. are retained only for evidence traceability. They do not require the thesis to call the result a theorem in the mathematical-science sense.

## Prohibited transformations

Do not write that a function or ML-KEM was “proved correct” without the exact property/domain/model qualifier. Do not convert:

- a property-record count into a count of independent theorems;
- repository distinctness into global novelty;
- a skill invocation into individual-skill causation;
- a resource-limited run into success or failure;
- a source-level zero poststate into universal physical erasure;
- raw 12-bit decoding into arbitrary-byte modulo-q canonicalization.

## Preferred sentence

> Codex generated a candidate verification property, and CBMC supported the corresponding bounded claim for the unchanged production implementation under the recorded input domain, source revision and analysis configuration.

## Skill table replacement

Replace **successful proof-property records** with **successful CBMC property records** or **successful reported verification-property records**.

## Classification namespaces and definition-before-use policy

The repository uses multiple independent classification namespaces. They must not be merged by typography or by similar wording.

1. `02_COMPLETE_PROPERTY_LEDGER.csv` owns the **nine-value property-result namespace**. The complete definitions and counts are stated before first classified use in `03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md`.
2. `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv` owns the **sixteen-value material-boundary category namespace**. File 06 and 03A define every category before the case-level boundary listings.
3. Evidence completeness (`COMPLETE`, `PARTIAL`), experimental condition (`UA`/`SA`, `UNASSISTED`/`SKILL_AVAILABLE`), repository distinctness, path resolution, integrity fields, native-census codes, literature-relationship codes, and principal-claim roles are separate field-local namespaces. None changes a property result merely by appearing beside it.

### Material boundary record

A **Material boundary record** is one of the 27 rows in file 06. It records evidence that materially bounds interpretation: contrary evidence, unresolved work, preservation limits, exclusions, expected-failure controls, supporting-only replay, scope/novelty/counting/claim limits, repair provenance, source conflicts, or shared RQ2 attribution/efficiency limits. It is not one of the 257 substantive property/control rows unless the boundary-to-substantive crosswalk explicitly identifies a corresponding property or property family.

The complete boundary-category vocabulary is:

`MEANINGFUL_NEGATIVE`, `ABSTRACTION_LIMITED_INCONCLUSIVE`, `RESOURCE_LIMITED_INCONCLUSIVE`, `EVIDENCE_SOURCE_CONFLICT`, `PARTIAL_PRESERVATION`, `SUPERSEDED_REPAIRED_FAILURE`, `NOT_TESTED`, `EXCLUDED_TEMPLATE`, `EXPECTED_FAILURE_CONTROL`, `SUPPORTING_ONLY`, `OUT_OF_SCOPE`, `NOT_ESTABLISHED`, `COUNTING_BOUNDARY`, `NOT_CLAIMED`, `EXCLUDED_INVALID`, and `NOT_DEMONSTRABLE`.

Their reusable definitions are authoritative in file 06 and repeated in 03A before first case-level use.

### Preservation crosswalk

`PARTIAL_PRESERVATION` is a material-boundary/preservation category. `SUPPORTED_WITH_PARTIAL_PRESERVATION` is a substantive property-result classification. The first states that preservation is incomplete; the second states that the bounded property is supported while carrying an explicit preservation qualification. They are not synonyms and must not be substituted.

### Boundary identifier prefixes

`NEG-`, `LIM-`, `EXC-`, `CTRL-`, `INC-`, `REP-`, and `CONFLICT-` are identifier/navigation prefixes, not category values. The file-06 `Category` field always controls. In particular, no category may be inferred from `LIM-` alone.

### Evidence-completeness vocabulary

`COMPLETE` means the registered evidence-preservation criterion for the case is satisfied; it does not mean all planned work was executed or that every result is positive. `PARTIAL` means one or more registered subordinate preservation expectations are incomplete; the scientific status of each retained property remains separately classified.

### Locator and condition vocabulary

`UA` means the unassisted V5 condition and `SA` means the skill-available V5 condition. `UNASSISTED` and `SKILL_AVAILABLE` are the corresponding condition metadata values where used. These labels identify experimental condition rather than result. `SKILL_AVAILABLE` does not by itself demonstrate individual-skill causation.

### Distinctness and comparison vocabulary

`SUPPORTED_WITHIN_INSPECTED_CORPUS` is repository-relative only and does not establish global novelty or first-ever proof. Native-census codes in file 17 and literature relationship/exact-match codes in file 05 are field-local comparison metadata; their companion row text controls their meaning and they must not be converted into property results, boundary categories, worldwide absence, or novelty claims.

### Definition-before-use rule

For public reader-facing synthesis files, a controlled label must either (a) be defined before first use in that file, or (b) be explicitly identified as a field-local code with a direct link to its authoritative vocabulary before first use. Validators must fail closed when the nine property-result values, sixteen boundary categories, 27 boundary IDs, eighteen material-boundary section fields, shared skill limitations, or the preservation crosswalk drift.
