# Contributing

## ML-KEM CBMC Verification Case-Study Evidence

Thank you for taking an interest in this research repository.

This repository is primarily a preserved scientific evidence corpus rather
than a conventional collaborative software project. Contributions are
therefore evaluated not only for technical correctness but also for their
effect on provenance, reproducibility, historical identity and research
traceability.

## 1. Appropriate contributions

Useful contributions may include:

- reporting a factual error;
- identifying a broken repository locator;
- identifying a hash or provenance inconsistency;
- reporting a reproducibility problem;
- identifying an incorrect or ambiguous research statement;
- improving documentation without altering the meaning of retained evidence;
- identifying a problem in an author-created harness, script or validator;
- providing independently reproduced results;
- identifying a mismatch between a claim and its supporting evidence;
- suggesting clearer explanations of limitations or assumptions;
- identifying licensing or attribution inaccuracies; or
- reporting security-sensitive issues in accordance with `SECURITY.md`.

## 2. Scientific evidence must remain historically truthful

Many files in this repository record what actually occurred during a specific
research campaign.

Examples include:

- raw CBMC output;
- verification harnesses;
- command records;
- terminal captures;
- manifests;
- checksums;
- coverage evidence;
- mutation evidence;
- provenance records;
- source snapshots;
- generated evidence packages; and
- release-specific records.

Historical evidence must not be silently rewritten merely because a later
version could be cleaner, more accurate or easier to understand.

If a historical artefact contains an error, the preferred approach is to:

1. preserve the original artefact;
2. identify the error explicitly;
3. add a correction or superseding record;
4. preserve the relationship between the old and new records; and
5. update the scientific interpretation where necessary.

The repository should continue to distinguish between what originally
happened and what was learned or corrected later.

## 3. Frozen upstream source

Directories containing frozen upstream source snapshots are retained for
provenance and reproducibility.

Do not modify a frozen upstream file solely to:

- improve formatting;
- add repository-author copyright notices;
- add new SPDX headers;
- modernise code;
- satisfy a linter;
- alter an upstream licence expression;
- make a historical snapshot match a newer upstream version; or
- make a repository-wide tool report appear cleaner.

If additional metadata is required, prefer an external provenance or
repository-level record where that can be done accurately without changing
the frozen bytes.

## 4. No manufactured authorship or ownership

The presence of a file in this repository does not imply that the repository
author created or owns it.

Contributions must preserve the distinction between:

- author-created research material;
- author-created research software;
- third-party source;
- upstream project material;
- generated output;
- factual or mechanical records; and
- mixed-rights artefacts.

Do not assign the repository author as copyright holder merely to simplify
licensing metadata.

Do not replace an upstream licence with a repository-level licence unless the
legal basis for doing so is clear and valid.

Refer to `LICENSE.md` and `REUSE_AND_LICENSING.md` for the repository's
licensing and provenance rules.

## 5. Verification claims

A contribution that changes or challenges a verification claim should identify
the exact scope of the claim.

Where relevant, include:

- the target function or component;
- the property being checked;
- the verification harness;
- assumptions;
- input domain;
- relevant bounds;
- CBMC or other tool version;
- command line;
- configuration;
- result;
- supporting raw artefact; and
- reason the existing interpretation should change.

Counts of generated CBMC properties, checks or tool records must not be
presented as counts of independent mathematical theorems or independent
experiments unless that interpretation is separately justified.

## 6. Reproducibility reports

A reproducibility report should provide enough information for the result to
be investigated.

Where possible, include:

- operating environment;
- tool versions;
- repository commit;
- relevant release;
- exact commands;
- relevant input files;
- observed output;
- expected output; and
- any environmental difference that may affect reproduction.

Do not replace retained historical results merely because a newer environment
produces a different result.

Both results may be scientifically relevant and should be distinguished.

## 7. Corrections to evidence

A proposed correction should answer four questions:

1. What existing record is affected?
2. What is wrong with it?
3. What evidence demonstrates the problem?
4. What new record or interpretation should supersede it?

Where practical, corrections should be additive and auditable rather than
destructive.

## 8. Pull requests

A pull request should have a narrow and clearly stated purpose.

The description should identify:

- what is being changed;
- why the change is necessary;
- whether scientific evidence is affected;
- whether frozen upstream material is affected;
- whether hashes or provenance are affected;
- whether licensing or attribution is affected; and
- what validation has been performed.

Large unrelated changes should not be bundled into a single pull request.

## 9. Evidence-affecting pull requests

A pull request that changes substantive research evidence requires additional
care.

Such a contribution should explain:

- whether the existing evidence remains valid;
- whether the change corrects, supplements or supersedes it;
- which thesis or research claims are affected;
- whether repository indexes require updating;
- whether recorded hashes require a new record rather than replacement;
- whether historical releases remain unchanged; and
- how traceability is preserved.

Historical release tags should not be retargeted merely because a later
correction or improvement exists.

## 10. Generated files

Do not manually edit a generated artefact and present the result as though it
were generated by the original process.

If a generated file must be regenerated:

- identify the generator;
- preserve or record the command;
- record the relevant tool version;
- explain why regeneration is necessary; and
- distinguish the regenerated artefact from the historical original where
  that distinction matters scientifically.

## 11. Artificial-intelligence assistance

Where AI assistance materially contributes to a proposed research artefact,
analysis, script, harness, interpretation or substantial documentation
change, the contribution should disclose that assistance where relevant to
research transparency.

AI assistance does not transfer authorship or ownership of third-party
material and does not remove the contributor's responsibility to verify the
accuracy of the contribution.

See `AI-ASSITANCE-NOTICE.md` for the repository's research-disclosure
position.

## 12. Citation is not contribution ownership

Scholarly citation, repository attribution, software licensing, copyright
ownership and research authorship are separate matters.

The repository's preferred scholarly citation is recorded in `CITATION.cff`.

Contributing an issue, pull request, correction or discussion does not by
itself create co-authorship of the associated thesis or research publication.

Any scholarly authorship decision must be based on the actual intellectual
contribution and the applicable academic authorship practices.

## 13. Third-party contributions

A contributor must have the right to submit material that they contribute.

Do not submit:

- confidential material without permission;
- proprietary source without authorization;
- material copied from another project without preserving applicable rights
  and attribution;
- credentials or secrets;
- personal data that is not necessary for the research purpose; or
- material whose provenance cannot be explained when provenance is relevant.

## 14. Licensing of contributions

Contributions must be compatible with the licensing and provenance structure
of the repository.

A contribution must not silently relicense existing third-party material.

Where the contribution adds original material, its licensing should be stated
clearly and consistently with the applicable repository policy.

Where a contribution modifies third-party material, the original applicable
licence and attribution must continue to be respected.

See:

- `LICENSE.md`;
- `REUSE_AND_LICENSING.md`;
- `REUSE.toml`; and
- `LICENSES/`.

## 15. Security-sensitive contributions

Do not submit a public pull request containing active credentials, private
keys, tokens, unpublished vulnerability details or other sensitive security
information.

Follow `SECURITY.md` instead.

## 16. Academic disagreement

Independent criticism is welcome.

A contribution does not need to agree with the thesis conclusions.

Challenges to a result are most useful when they identify:

- the exact claim being challenged;
- the evidence involved;
- the competing interpretation; and
- the technical or empirical basis for the disagreement.

The purpose of the evidence corpus is to make such scrutiny possible.

## 17. Acceptance of contributions

Submission of a contribution does not guarantee that it will be merged.

A proposed change may be declined where, for example, it:

- damages historical evidence identity;
- removes necessary provenance;
- creates unsupported ownership claims;
- weakens reproducibility;
- duplicates an existing record without benefit;
- changes a scientific claim without adequate evidence;
- introduces licensing uncertainty; or
- falls outside the purpose of the repository.

A valid correction may instead be recorded through another auditable
mechanism where modifying the original artefact would be inappropriate.

## 18. Core contribution principle

The central rule for contributing to this repository is:

> Improve the research record without rewriting its history.

Technical improvements, corrections and criticism are welcome when they
preserve the distinction between original evidence, later corrections,
third-party material and subsequent interpretation.
