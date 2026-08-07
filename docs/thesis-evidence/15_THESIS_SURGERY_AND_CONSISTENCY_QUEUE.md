# Thesis surgery and global consistency queue

This file records the prose changes that remain pending until the RQ2 release-classification finalizer and combined internal-consistency validator have been run. It prevents the evidence work from being lost when Chapter 4 is compressed.

## Locked evidence-first order

1. install this documentation overlay without moving or renaming raw evidence;
2. run the repository-authoritative release-classification finalizer;
3. obtain a strict validation PASS;
4. review the generated path and checksum audits;
5. freeze the versioned evidence release; and
6. only then revise Chapter 4 from the validated ledgers.

## Chapter 4 structural surgery

- Replace the current Table 4.2 with the compact fourteen-row view in `09_MASTER_PROVENANCE_MATRIX.csv`; do not add a second competing case table.
- Use selective mathematical statements from `03_FORMAL_CLAIM_CATALOGUE.md` for the principal semantic claims only.
- Keep the 257-row substantive inventory in `02_COMPLETE_PROPERTY_LEDGER.csv` and the repository/appendix rather than printing it in the thesis body.
- Keep repository-relative distinctness in Chapter 4 and published-assurance interpretation in Chapter 5.
- Use one evidence locator per case instead of repeating long repository paths.
- Compress repeated case-closing classification paragraphs only after their claim, domain, outcome, limitation and evidence locator survive in the replacement table.
- Preserve every record in `06_NEGATIVE_INCONCLUSIVE_AND_EXCLUDED_EVIDENCE.csv`.
- Run the loss check in `07_CHAPTER4_CLAIM_SURVIVAL_LEDGER.csv` after every compression pass.

## Global thesis consistency corrections

1. Replace the Chapter 1 statement that Chapter 4 reports “human-assisted” outcomes with:

   > Chapter 4 reports supported, meaningful-negative, repaired, abstraction-limited and resource-limited outcomes rather than only passing results.

2. In the thesis-structure paragraph, replace “autonomous and human-assisted activity” with:

   > autonomy, intervention records and assistance configurations.

3. Correct the Section 4.3.2 typo `undifferated` to `undifferentiated`.

4. In the skill-available table, replace `successful proof-property records` with `successful CBMC property records` or `successful reported verification-property records`.

5. Retain historical `T1`, `T2`, `PA-*` and filenames for traceability, but use property/claim/obligation terminology in ordinary prose rather than stating that mathematical theorems were proved.

## Page-budget conflict disclosure

The current formatted Chapter 4 was observed to occupy approximately thirty thesis pages, above the locked twenty-five-page ceiling. The additional evidence material must therefore **replace and compress**, not accumulate on top of, the existing prose. Valuable supported, negative, inconclusive and integrity-related information must not be removed merely to conceal page pressure. Full subordinate inventories remain in the validated repository and appendix layer.

## Completion condition

This queue is complete only when the revised thesis has been checked against every row of the survival ledger and every retained negative/limit record, and the public evidence release cited by Chapters 4–6 is frozen and verifiable.

## RQ2 architectural-development surgery extension

Before Chapter 4 surgery:

1. preserve `v1.0.0` unchanged;
2. install and finalise the RQ2 addendum;
3. obtain combined strict PASS;
4. freeze `v1.1.0`; and
5. reconstruct Chapter 4 from the combined evidence spine.

RQ2-specific controls:

- Section 4.2.1 becomes the principal empirical RQ2 result section and is backed by files 20–29.
- The two preserved V4 directory states are one V4 architecture generation; the Codex state is a utility/backend increment.
- The 53/53 and 56/56 counts are engineering/regression evidence, not semantic verification outcomes.
- Section 4.6 remains a secondary capability-distillation probe.
- Section 4.7.5 gives a concise factual architecture synthesis; causal interpretation belongs in Chapter 5.

The existing V5 surgery rules remain in force: make principal claims mathematically precise where useful, expose genuine native baselines and repository-relative distinctness, preserve all negative/inconclusive/partial evidence, use public evidence locators, and relocate subordinate detail rather than deleting it under page pressure.
