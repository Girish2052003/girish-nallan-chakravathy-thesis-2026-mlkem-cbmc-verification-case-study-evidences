# REUSE and Licensing Policy

## ML-KEM CBMC Verification Case-Study Evidence

**Repository author and research contributor:** Girish Nallan Chakravathy
**Year:** 2026

This document explains how copyright, licensing, attribution, provenance and REUSE metadata are handled throughout this research repository.

It is an operational and explanatory companion to `LICENSE.md`.

It does **not** replace, rewrite, modify or add conditions to:

* Creative Commons Attribution 4.0 International (`CC-BY-4.0`);
* Apache License 2.0 (`Apache-2.0`);
* any upstream or third-party licence;
* any applicable file-level licence expression; or
* rights and limitations provided by applicable law.

Where this document and an applicable legal licence differ, the applicable legal licence controls.

---

# 1. Repository licensing position

This repository contains material with different origins, copyright holders and legal characteristics.

It therefore does **not** apply one licence indiscriminately to every file.

The repository adopts the following default position:

### Author-created non-software research material

Original non-software research material created by **Girish Nallan Chakravathy**, where no more specific licence applies, is licensed under:

**Creative Commons Attribution 4.0 International**

`SPDX-License-Identifier: CC-BY-4.0`

---

### Author-created research software

Original research software created by **Girish Nallan Chakravathy**, where no more specific licence applies, is licensed under:

**Apache License 2.0**

`SPDX-License-Identifier: Apache-2.0`

---

### Third-party and upstream material

Third-party and upstream material remains governed by its **original applicable licence or licence expression**.

It is not relicensed merely because it is stored, copied, archived, tested, analysed or referenced in this repository.

---

# 2. Supersession of the earlier pre-licensing position

Earlier evidence-package documentation stated that the evidence-spine package did not itself select or impose repository-level software, documentation or data licensing terms.

That statement described the repository **before a deliberate licensing decision had been made**.

The licensing decision has now been made.

Accordingly, for repository releases adopting the present policy:

* original author-created non-software research material defaults to `CC-BY-4.0`;
* original author-created research software defaults to `Apache-2.0`;
* third-party and upstream material retains its original licensing; and
* ambiguous or unclassified material receives **no automatic new licence merely from its location in the repository**.

The previous pre-licensing statement must not be interpreted as overriding this later licensing decision.

---

# 3. Fundamental ownership rule

**Presence in this repository does not determine ownership.**

A file does not become the property of Girish Nallan Chakravathy merely because it:

* appears in this repository;
* appears beneath an author-created directory;
* was copied during an experiment;
* was included in a frozen snapshot;
* was produced during execution of a research script;
* was referenced by an evidence index;
* was renamed;
* was compressed into an archive;
* was moved between directories;
* was committed to Git;
* was included in a GitHub release; or
* was incorporated into the research evidence corpus.

Copyright and licensing are determined by the actual provenance and applicable legal rights of the material.

No repository structure, metadata operation or publication action is intended to transfer third-party ownership.

---

# 4. No automatic relicensing

Moving, copying or grouping a file does **not** automatically change its licence.

In particular:

* upstream files do not become `Apache-2.0` merely because they are stored beside author-created scripts;
* upstream documentation does not become `CC-BY-4.0` merely because it appears within a research archive;
* author-created material does not acquire an upstream licence merely because it interacts with upstream software;
* generated output does not automatically acquire the licence of the program that generated it;
* repository-level defaults do not override a more specific valid file-level licence; and
* Git history, directory location or release packaging does not by itself change ownership or licensing.

A licensing change requires a lawful basis and must be expressed intentionally and unambiguously.

---

# 5. Author-created research material

Subject to any more specific file-level licensing information, original non-software research material authored by **Girish Nallan Chakravathy** is classified under `CC-BY-4.0`.

This may include:

* research documentation;
* methodological records;
* experiment descriptions;
* evidence indexes;
* evidence ledgers;
* survival ledgers;
* provenance records;
* case-study summaries;
* original analytical tables;
* original explanatory figures;
* original annotations;
* original interpretations;
* research metadata;
* original structured research records;
* original dataset structure;
* experiment-control documentation;
* evidence-classification records;
* manifests authored for the research;
* original explanatory README material; and
* original selection, arrangement and presentation of research evidence to the extent such material is legally protectable.

This classification applies only to rights actually held by Girish Nallan Chakravathy.

It does not create ownership over underlying facts, third-party material or material that is not legally subject to copyright or related rights.

---

# 6. Author-created research software

Subject to any more specific file-level licensing information, original research software authored by **Girish Nallan Chakravathy** is classified under `Apache-2.0`.

This may include independently authored:

* CBMC verification harnesses;
* verification-support code;
* campaign runners;
* experiment orchestration scripts;
* evidence-processing scripts;
* validation scripts;
* integrity-checking utilities;
* manifest-generation utilities;
* analysis programs;
* research automation;
* reporting utilities; and
* other original software created specifically for this research.

This default applies only where Girish Nallan Chakravathy has the legal authority to license the relevant software.

It must not be applied automatically to code copied from, adapted from or governed by an upstream project.

---

# 7. Third-party and upstream material

All third-party material must retain its legally applicable copyright and licensing information.

This includes, as applicable:

* upstream source code;
* upstream documentation;
* frozen upstream source snapshots;
* test material;
* libraries;
* examples;
* third-party scripts;
* incorporated utilities;
* copied configuration;
* patches containing third-party source context;
* generated files containing protectable third-party content;
* vendored dependencies; and
* other externally authored material.

Third-party material must retain, where applicable:

* copyright notices;
* SPDX copyright notices;
* SPDX licence identifiers;
* SPDX licence expressions;
* licence files;
* NOTICE files;
* attribution statements;
* modification notices;
* authorship information; and
* other notices required by the applicable licence.

No third-party material is relicensed by this document.

---

# 8. `mlkem-native` and frozen upstream snapshots

Material originating from `mlkem-native` remains governed by the licensing information applicable to that upstream material.

The frozen `mlkem-native` source snapshot retained in this repository exists to preserve:

* exact experimental provenance;
* implementation identity;
* reproducibility;
* research auditability;
* source-to-evidence binding; and
* the implementation context against which verification was performed.

Its inclusion does not mean that Girish Nallan Chakravathy:

* authored `mlkem-native`;
* acquired copyright in `mlkem-native`;
* owns its upstream source code;
* replaced its licences;
* obtained exclusive rights to it;
* represents its maintainers;
* represents its copyright holders; or
* received endorsement from them.

The applicable upstream copyright notices, SPDX identifiers and licence files remain controlling for the upstream files.

Where an upstream file offers a choice among multiple licences, that original licence expression must be preserved accurately rather than silently replaced with one repository default.

---

# 9. Author-created material located inside an upstream-related research area

A directory may contain both:

1. upstream or third-party material; and
2. independently authored research material.

Directory location alone must therefore never be used as proof of ownership.

An independently authored verification harness, script, annotation or research record may retain its author-created licence even when it operates against an upstream implementation.

Conversely, an upstream source file does not become author-created merely because it has been copied into an experiment directory.

Classification must follow provenance.

---

# 10. Modified third-party files

Modification does not erase upstream ownership.

Where a third-party file has been modified for this research:

* the original copyright information must be preserved where required;
* the original licence must remain applicable to the extent required by that licence;
* modification notices must be added where required;
* the researcher's contribution must not be presented as authorship of the original work; and
* any additional copyright claim must be limited to rights actually arising from the researcher's protectable modifications.

Where Apache-2.0 applies to an upstream file, modified files must carry the change notices required by Apache-2.0.

Where another upstream licence applies, its own modification and redistribution rules must be followed instead.

---

# 11. Mixed-authorship files

A file containing protectable contributions from more than one rights holder must not be reduced to a misleading single-owner statement.

Where technically and legally appropriate, licensing information should identify:

* the relevant upstream copyright holder or holders;
* Girish Nallan Chakravathy for original protectable contributions;
* the applicable licence expression; and
* modification or provenance information where required.

If different portions of a file are governed differently and ordinary whole-file metadata would be misleading, SPDX snippet information or another valid REUSE-compatible method should be used where appropriate.

---

# 12. Snippets and copied fragments

Copying only part of a third-party file does not automatically remove the third-party licensing obligations attached to protectable copied material.

Where a protectable third-party code or documentation fragment is incorporated into another file, the relevant provenance and licence must be examined.

A copied fragment must not be relabelled as wholly author-created merely because:

* identifiers were renamed;
* formatting changed;
* comments were added;
* whitespace changed;
* surrounding code was rewritten;
* it was embedded inside a larger author-created file; or
* the file itself received a new name.

Where REUSE snippet metadata is appropriate, it should be used to represent the relevant rights accurately.

---

# 13. Independently written material performing the same function

Functional similarity alone does not establish copying.

A genuinely independently authored research harness, script, explanation or implementation should be classified according to its actual provenance.

However, independence must not be assumed merely because a file lacks an upstream copyright header.

Where provenance is uncertain, the file must be reviewed before a new author-created licence is assigned.

---

# 14. Ambiguous provenance

**Uncertainty must not be resolved in favour of claiming ownership.**

If the provenance of a file cannot be established confidently:

1. do not assign Girish Nallan Chakravathy as sole copyright holder merely by assumption;
2. do not apply `CC-BY-4.0` or `Apache-2.0` merely because the file is present in this repository;
3. inspect Git history, upstream source, experiment records and available provenance evidence;
4. preserve any existing copyright or licensing information;
5. classify the material conservatively; and
6. obtain appropriate institutional, supervisory or legal guidance where a material uncertainty remains.

An unresolved file must not silently pass a release-licensing audit as author-created material.

---

# 15. Generated research artefacts

This repository contains machine-generated evidence such as:

* CBMC output;
* solver output;
* verification logs;
* coverage output;
* mutation-testing output;
* shell output;
* build output;
* diagnostic output;
* JSON result files;
* generated reports;
* generated manifests;
* hash listings;
* execution records; and
* other automatically produced artefacts.

Creation by a computer program does not automatically establish a new copyright owner or licence.

For generated material:

* embedded third-party material retains applicable third-party rights;
* tool licences do not automatically become licences for every output produced by the tool;
* facts and purely mechanical values are not claimed merely because they were generated during the study;
* any protectable original annotation, selection, arrangement or presentation is licensed only to the extent that Girish Nallan Chakravathy holds the relevant rights; and
* no ownership claim is made beyond rights that legally exist.

---

# 16. AI-assisted or automatically assisted material

Use of an AI system, code generator, verification tool, formatter, compiler, solver or other automated system does not by itself determine copyright ownership.

Material involving automated assistance must be classified according to:

* actual provenance;
* human-authored contributions;
* incorporated third-party material;
* applicable tool or service terms where relevant;
* applicable law; and
* rights that the repository author is legally entitled to license.

This repository does not claim copyright merely because an output was produced during this research.

Where substantial original human-authored selection, arrangement, analysis, annotation or other protectable contribution exists, only those rights that legally belong to the author are included within the applicable repository licence.

---

# 17. Facts, mathematical statements and cryptographic values

This repository does not attempt to create copyright protection over material that is not subject to copyright merely because it is included in the research corpus.

This includes, where applicable:

* mathematical truths;
* mathematical relationships;
* factual observations;
* experimental facts;
* raw numerical values;
* cryptographic hashes;
* Git object identifiers;
* checksums;
* timestamps as facts;
* tool exit codes;
* parameter values;
* verification-status facts; and
* other purely factual information.

Original protectable expression, organisation, annotation or selection surrounding such information may nevertheless be subject to the applicable author-created licence.

---

# 18. Research collections and database rights

Where the author holds copyright, sui generis database rights or other legally applicable rights in an original research collection, those author-held rights are licensed under `CC-BY-4.0` unless otherwise stated.

This does not transfer ownership of individual third-party items contained within the collection.

A database or evidence collection may therefore contain:

* author-created protectable structure;
* public-domain or non-copyrightable facts;
* machine-generated material;
* separately licensed third-party material; and
* other material having independent rights.

Each layer retains its appropriate legal status.

---

# 19. Research evidence identity and provenance

The evidential meaning of an artefact may depend upon its exact identity.

Relevant identifiers may include:

* repository path;
* filename;
* release tag;
* Git commit identifier;
* upstream revision;
* manifest entry;
* cryptographic checksum;
* evidence index identifier;
* campaign identifier;
* experiment identifier; and
* associated provenance record.

Licensing permission does not authorise false statements about evidence identity.

A modified, regenerated, reconstructed or independently reproduced file must not be represented falsely as the byte-identical research artefact associated with a recorded checksum, release or provenance statement.

---

# 20. Modification and provenance

Where material is changed, users must comply with the applicable licence's change-identification requirements.

For `CC-BY-4.0` material, applicable attribution and modification-identification obligations are governed by CC BY 4.0.

For `Apache-2.0` material, applicable redistribution, notice-retention and modified-file requirements are governed by Apache-2.0.

For third-party material, the relevant third-party licence governs.

This policy does not replace those legal requirements.

---

# 21. Attribution of author-created research material

Author-created research material licensed under `CC-BY-4.0` must be attributed as required by that licence when the licence applies to the use in question.

The designated research author is:

**Girish Nallan Chakravathy**

The repository is the identified source of the research material.

Where reasonably practicable, attribution should preserve:

* the author's name;
* the title or identity of the research repository or relevant research work;
* the applicable licence;
* the source location;
* the relevant release, version or commit when necessary for reproducibility; and
* an indication of modifications where required.

The precise presentation of attribution may vary according to the medium and context, subject to the requirements of the applicable licence.

---

# 22. `CITATION.cff`

`CITATION.cff` provides the **preferred scholarly citation** for the repository.

Researchers, students, educators, authors and other scholarly users are requested to use that citation, or an equivalent citation correctly adapted to the citation style required by their institution or publisher.

The essential scholarly objective is that the research contribution and repository source remain identifiable.

`CITATION.cff` does not replace a copyright licence.

Likewise, a copyright licence does not eliminate normal scholarly citation obligations.

---

# 23. Citation versus legal attribution

Citation and legal attribution overlap but are not identical.

For material licensed under `CC-BY-4.0`, attribution required by that licence is a legal licence condition when the licence governs the relevant use.

For author-created software under `Apache-2.0`, the Apache licence itself determines the legally binding copyright, licence, redistribution, notice and modification obligations.

A scholarly publication making substantive use of research methodology, findings, evidence or analysis should additionally follow applicable academic citation standards.

This policy does not falsely represent an academic citation rule as an additional condition inserted into Apache-2.0.

---

# 24. Academic integrity

Open licensing permits reuse; it does not transfer authorship.

Nothing in this repository authorises:

* plagiarism;
* false authorship;
* fabricated attribution;
* falsification of research evidence;
* removal of attribution where retention is legally required;
* misrepresentation of provenance;
* presentation of modified evidence as unchanged original evidence;
* deceptive use of research results;
* fabricated association with the author;
* false claims of endorsement;
* research misconduct; or
* violation of applicable academic or professional integrity requirements.

Such matters may involve copyright law, licence compliance, academic rules, professional standards or other legal and ethical frameworks depending on the circumstances.

The existence of an open licence does not excuse conduct that is independently prohibited by those frameworks.

---

# 25. No authorship transfer through reuse

A person who lawfully reuses or adapts material may obtain rights in their own qualifying contribution where applicable.

That does not make them the original author of the underlying material.

Similarly:

* citing this repository does not make the citing person a co-author;
* modifying this repository does not transfer original authorship;
* redistributing this repository does not transfer original ownership;
* forking the repository does not transfer original ownership; and
* extending the research does not erase the provenance of the earlier research.

---

# 26. No endorsement

Reuse, redistribution, modification, citation or discussion of this repository does not imply endorsement by:

* Girish Nallan Chakravathy;
* Tampere University;
* any supervisor;
* `mlkem-native`;
* upstream developers;
* third-party copyright holders;
* verification-tool developers; or
* any other referenced organisation or person.

Names may be used for legitimate attribution, provenance, citation and identification as permitted by the applicable licence and law.

They must not be used to create a false impression of sponsorship, approval or official status.

---

# 27. No false institutional attribution

The presence of Tampere University or other institutional references in research documentation must not be interpreted as:

* institutional ownership of all repository material;
* institutional certification of the software;
* institutional endorsement of derivative work;
* institutional security approval; or
* institutional guarantee of the research conclusions.

Institutional rights, marks and policies remain independent of the repository licences.

---

# 28. Licence files

The root `LICENSES/` directory must contain the complete licence text for every licence that is actually referenced by the licensing information of covered repository files.

Examples include, where actually applicable:

```text
LICENSES/CC-BY-4.0.txt
LICENSES/Apache-2.0.txt
```

Additional licence files must be included where third-party files in the repository use additional SPDX licences.

A licence must not be placed in `LICENSES/` merely as decoration or speculation if no covered file actually uses that licence.

The licence texts must remain unmodified except where the applicable licence or SPDX rules expressly permit replaceable portions.

---

# 29. Root `LICENSE.md`

`LICENSE.md` provides the repository-level licensing, attribution and rights notice.

It explains the default treatment of author-created research material and software and the separation of third-party rights.

It does not override a more specific valid licence attached to a file or component.

It must be read together with:

* file-level SPDX information;
* `REUSE.toml` where used;
* the `LICENSES/` directory;
* preserved third-party licence and NOTICE files;
* `CITATION.cff`; and
* this document.

---

# 30. Machine-readable licensing

The repository should use REUSE-compatible machine-readable licensing information so that licensing is not dependent solely upon human interpretation of directory names.

Every file covered by the applicable REUSE specification must have complete licensing information associated with it through an accepted REUSE mechanism.

Where practical, file-level comment headers are preferred because they remain attached to a file when it is copied or moved.

---

# 31. Preferred SPDX form for author-created documentation

Where the file format supports comments, original author-created non-software research material may use an appropriate comment header equivalent to:

```text
SPDX-FileCopyrightText: 2026 Girish Nallan Chakravathy
SPDX-License-Identifier: CC-BY-4.0
```

The exact comment syntax must match the relevant file format.

The SPDX information must describe the actual rights in the file and must not be inserted where it would falsely imply sole ownership of third-party content.

---

# 32. Preferred SPDX form for author-created software

Where the file format supports comments, independently authored research software may use an appropriate comment header equivalent to:

```text
SPDX-FileCopyrightText: 2026 Girish Nallan Chakravathy
SPDX-License-Identifier: Apache-2.0
```

The header must not be added automatically to:

* upstream code;
* modified third-party files without provenance review;
* mixed-authorship files where the statement would be incomplete;
* generated outputs whose rights are uncertain; or
* files governed by another licence.

---

# 33. Uncommentable files

For files that cannot practically contain licensing comments, an adjacent `.license` file may be used where appropriate.

For example:

```text
figure.png
figure.png.license
```

The `.license` file should contain the applicable copyright and SPDX licence information.

This mechanism must describe the actual provenance of the associated file rather than applying an assumed repository default.

---

# 34. `REUSE.toml`

`REUSE.toml` may be used for groups of files where adding individual comment headers or adjacent `.license` files is impractical or undesirable.

It is particularly useful for:

* large evidence directories;
* generated research records;
* groups of files with identical verified provenance; and
* formats that are inconvenient to modify.

`REUSE.toml` rules must be:

* path-specific;
* provenance-verified;
* narrow enough to avoid capturing unrelated material; and
* reviewed before a release freeze.

Broad wildcard rules must not be used to claim Girish Nallan Chakravathy as copyright holder over upstream or otherwise ambiguous material.

---

# 35. Conservative use of REUSE precedence

REUSE precedence mechanisms must be used cautiously.

An `override` rule must not be used merely to suppress inconvenient upstream licensing information.

Where file-level licensing information is valid, it should normally remain authoritative.

An override should be used only when the resulting metadata has been independently verified as correct for every affected file.

Licensing metadata exists to describe rights accurately, not to force heterogeneous files into a simpler repository-wide classification.

---

# 36. No simultaneous `REUSE.toml` and deprecated DEP5 classification

The repository should use the current REUSE mechanism consistently.

Where `REUSE.toml` is adopted, `.reuse/dep5` must not simultaneously be used as a competing licensing-classification mechanism.

Legacy DEP5 information, if inherited historically, should be reviewed and migrated deliberately rather than allowed to create conflicting metadata.

---

# 37. Preserved upstream SPDX information

Existing valid upstream SPDX information should be retained.

It must not be replaced with:

```text
SPDX-FileCopyrightText: 2026 Girish Nallan Chakravathy
SPDX-License-Identifier: Apache-2.0
```

merely because the upstream file is part of this research repository.

Where an upstream file has been genuinely modified and an additional copyright notice is legally appropriate, the researcher's contribution may be documented separately without deleting the upstream information.

---

# 38. Multiple licences and licence expressions

Some files may legitimately be offered under more than one licence.

Such licensing must be represented using the correct SPDX licence expression.

For example, a file legitimately offered under either of two licences may use an `OR` expression.

An upstream `OR` choice must not silently become `AND`.

An upstream `AND` requirement must not silently become `OR`.

Repository simplification must never alter the legal meaning of a third-party licence expression.

---

# 39. No licence guessing from file extension

Licensing must not be inferred solely from file type.

For example:

* `.c` does not automatically mean `Apache-2.0`;
* `.md` does not automatically mean `CC-BY-4.0`;
* `.json` does not automatically mean research data;
* `.txt` does not automatically mean documentation;
* `.log` does not automatically mean unprotected output;
* `.py` does not automatically mean author-created code; and
* `.pdf` does not automatically indicate ownership by the repository author.

Provenance controls classification.

---

# 40. No licence guessing from directory name

Similarly, directory names do not determine ownership.

Names such as:

```text
evidence/
results/
scripts/
harnesses/
reports/
upstream/
archive/
experiments/
```

may be useful organisational indicators but are not themselves legal licence declarations.

Machine-readable licensing metadata and verified provenance must determine the applicable classification.

---

# 41. Renamed files

Renaming a file must not remove its licensing information or provenance.

Where a file is renamed:

* applicable copyright information must remain associated with it;
* its licence must remain unchanged unless a lawful deliberate relicensing occurs;
* provenance records should remain traceable where scientifically relevant; and
* the rename must not create a false impression of new authorship.

---

# 42. Moved files

Moving a file between directories must not silently alter its licence.

If a move causes the file to fall under a different `REUSE.toml` path rule, the resulting licensing metadata must be reviewed.

A repository restructuring must therefore include a licensing-regression check.

---

# 43. Duplicated files

A copied file normally retains the rights and licensing applicable to its source.

A duplicate must not receive a new copyright statement merely because it has a new path.

Where duplicates exist for scientific preservation reasons, their licensing metadata should remain consistent with the provenance of the underlying content.

---

# 44. Archives and compressed packages

Packaging material in:

* `.zip`;
* `.tar`;
* `.tar.gz`;
* release assets; or
* other archive formats

does not change the licences applicable to the files contained inside.

Where an archive contains third-party material, its applicable upstream notices and licence information must be preserved as required.

An archive created by Girish Nallan Chakravathy may itself contain original organisation or metadata without transferring ownership of the files packaged inside it.

---

# 45. Git history and releases

A Git commit, tag or release records repository state.

It does not itself transfer ownership or relicense files.

Release documentation should therefore preserve the distinction among:

* author-created research material;
* author-created software;
* third-party material; and
* generated evidence.

A release tag must not be interpreted as assigning one licence universally to every object reachable from that tag.

---

# 46. Forks and mirrors

Forking, cloning or mirroring this repository does not alter original authorship or ownership.

A downstream fork must comply with the applicable licences for material it copies, modifies or redistributes.

A fork must not falsely represent itself as the unchanged authoritative research repository or original evidence release where it has been modified.

---

# 47. Authoritative research release identity

Where this repository identifies a particular tagged release or commit as the authoritative research evidence release, that statement concerns **scientific provenance**, not exclusive control over downstream reuse.

Others may make lawful copies or modifications under the applicable licences.

However, a modified copy must not be falsely represented as byte-identical to an authoritative research release.

Cryptographic hashes and recorded commit identifiers may be used to distinguish the original release from later modifications.

---

# 48. `NOTICE` files

Any upstream `NOTICE` file must be preserved where required by the applicable upstream licence.

Where author-created Apache-2.0 software is accompanied by a repository `NOTICE` file, redistribution obligations relating to that NOTICE are governed by Apache-2.0.

A NOTICE file may contain legitimate attribution information.

It must not be used to insert additional restrictions that purport to modify Apache-2.0.

---

# 49. Upstream NOTICE and repository NOTICE

An author-created repository NOTICE must not overwrite or erase a required upstream NOTICE.

Where both apply, the relevant attribution notices must remain distinguishable.

A repository NOTICE must not imply that upstream authors have endorsed this research.

---

# 50. Public-domain and equivalent material

Material identified as public-domain material, `CC0-1.0`, `0BSD`, `MIT-0`, a `LicenseRef` representing an applicable public-domain dedication, or another distinct legal category must retain the correct classification.

It must not automatically be converted into `CC-BY-4.0` or `Apache-2.0`.

Author-created annotations surrounding such material may have independent licensing without changing the status of the underlying material.

---

# 51. Licence references not present in SPDX

Where a third-party licence does not have a standard SPDX identifier, an appropriate `LicenseRef-...` identifier may be used in accordance with the applicable REUSE and SPDX rules.

The corresponding licence text must be preserved as required.

A custom `LicenseRef` must not be invented merely to impose additional restrictions on otherwise standard-licensed author-created material without a deliberate legal licensing decision.

---

# 52. Ethical expectations do not modify open licences

The repository is released to support:

* education;
* learning;
* reproducibility;
* scientific verification;
* criticism;
* independent replication;
* further research;
* improvement;
* extension; and
* advancement of knowledge.

Users are expected to behave responsibly and follow applicable research, academic and professional standards.

However, this statement of purpose does not secretly add an “ethical use only,” “educational use only,” “non-commercial use only,” or similar field-of-use restriction to `CC-BY-4.0` or `Apache-2.0`.

The legal permissions remain those granted by the applicable licences.

---

# 53. No royalty requirement

The author does not require royalties for lawful exercise of rights granted under `CC-BY-4.0` or `Apache-2.0`.

No payment is required merely for exercising those licensed rights in accordance with their terms.

The work is shared in the spirit of scholarly contribution and further development.

Attribution, provenance and applicable licence compliance remain important even though no royalty is requested.

---

# 54. No forced co-authorship

Proper citation or attribution does not entitle Girish Nallan Chakravathy to automatic co-authorship of subsequent independent research.

Likewise, lawful reuse does not entitle a downstream user to claim original authorship of Girish Nallan Chakravathy's contribution.

Authorship of later scholarly work must be determined according to the actual contribution and applicable academic standards.

---

# 55. No ownership by citation

Citing a third-party project, publication, repository or author does not transfer ownership of that third-party material to this repository.

Similarly, citation of this repository by another researcher does not transfer ownership of this repository's original material to that researcher.

Citation identifies provenance; licensing governs permissions.

---

# 56. No implied waiver

Failure to object immediately to a particular reuse, omission, misattribution or suspected infringement must not be interpreted as a voluntary relicensing of the repository.

Nothing in this explanatory policy intentionally waives rights except where an applicable licence or law provides otherwise.

The rights and remedies of each relevant rights holder remain governed by the applicable licence and law.

---

# 57. Non-compliance

Permissions under the applicable licences depend upon their respective terms.

Consequences of licence non-compliance, including termination, reinstatement, notice obligations or remedies, are determined by the applicable licence and law.

This document does not invent additional penalties.

Nothing in this policy prevents an affected rights holder from pursuing remedies lawfully available for infringement or other legally actionable conduct.

Nothing in this policy promises that litigation will occur in every case.

---

# 58. Correction of licensing errors

If a licensing or attribution error is discovered in the repository:

1. preserve evidence of the affected state where required for research integrity;
2. determine the correct provenance;
3. correct the licensing metadata;
4. restore missing upstream attribution or licence information where necessary;
5. document material corrections where appropriate;
6. avoid rewriting historical evidence in a manner that falsely suggests the error never occurred; and
7. ensure future releases contain the corrected information.

Correcting metadata does not erase the historical provenance of an earlier research release.

---

# 59. Contributions from other people

A contribution supplied by another person must not automatically receive a copyright statement naming Girish Nallan Chakravathy.

Before incorporation, the repository should establish:

* who authored the contribution;
* what licence applies;
* whether the contributor had authority to submit it;
* whether the contribution contains third-party material; and
* what attribution must be preserved.

Contributor information should be retained where appropriate.

---

# 60. External material obtained for research

Files downloaded or copied from external repositories, websites, publications, tool distributions or other sources must not be treated as author-created merely because they were gathered during this research.

Before redistribution, their applicable rights and licences must be considered.

The evidence repository must preserve sufficient provenance to distinguish externally sourced material from original research contributions.

---

# 61. Licence compatibility and incorporation

Before third-party code is copied into author-created software rather than merely invoked, linked, tested or analysed separately, the applicable licence must be reviewed.

No assumption should be made that two licences are compatible merely because both are open-source licences.

Where incorporation creates a combined or derivative work, applicable licence obligations must be evaluated before release.

---

# 62. No silent conversion of upstream licensing

The following practices are prohibited by this repository policy:

* deleting an upstream licence header and replacing it with an author-created header;
* removing an upstream copyright holder because a file was modified;
* assigning `Apache-2.0` solely because the surrounding directory uses Apache-2.0;
* assigning `CC-BY-4.0` solely because a file forms part of the thesis evidence;
* replacing a multi-licence upstream expression with a different licence without authority;
* treating a copied upstream file as newly authored because its filename changed; or
* using REUSE metadata to conceal or contradict known provenance.

---

# 63. Evidence preservation is not ownership assertion

Preserving an exact upstream source file, tool output, licence file, manifest or third-party artefact for research reproducibility is not an assertion that the repository author created that artefact.

The purpose of preservation is scientific traceability.

Ownership and provenance must remain distinguishable throughout the evidence corpus.

---

# 64. README descriptions are not licences

Descriptions in `README.md`, thesis prose, evidence summaries, release notes or GitHub interface text do not override the applicable licence.

Statements such as:

* "my repository";
* "my evidence";
* "my experiment";
* "my case study"; or
* "my research corpus"

describe the research context and must not be interpreted as claims of copyright ownership over every third-party component contained within that research environment.

---

# 65. Thesis text and repository material

Material reproduced from the thesis into this repository must be assessed according to the rights applicable to that material.

Original author-created research text placed in the repository may be licensed under `CC-BY-4.0` where the author has authority to do so.

Third-party quotations, figures, tables or extracts contained in academic material do not automatically become CC BY merely because the surrounding author-created text is CC BY.

Their original rights remain unaffected.

---

# 66. Quotations and externally reproduced material

Where a document contains third-party quotations or reproduced material used under citation, permission, exception, limitation or another lawful basis, the repository's CC BY default applies only to the author's own licensable contribution.

A CC BY statement on the surrounding document must not be interpreted as granting rights in third-party material that the author is not entitled to license.

Where practical, such exceptions should be identified clearly.

---

# 67. Trademarks and project names

Copyright licences do not automatically grant trademark rights.

Names such as project names, product names, organisational names, logos and marks remain subject to applicable trademark and related law.

Use for accurate citation, provenance and identification must not be converted into a false claim of endorsement or affiliation.

---

# 68. Security claims

The presence of formal verification evidence does not constitute:

* a warranty;
* a certification;
* a guarantee of complete correctness;
* a guarantee of absence of vulnerabilities;
* a production-security approval; or
* a claim that all possible behaviours have been verified.

The scientific meaning of each verification result remains limited by its documented:

* property;
* assumptions;
* domain;
* verification bound;
* harness;
* implementation;
* tool configuration; and
* retained evidence.

Licensing permission does not enlarge those scientific claims.

---

# 69. Reuse of verification conclusions

Users may reuse author-created research analysis according to its applicable licence.

They remain responsible for representing the original scope accurately.

A user must not falsely attribute a stronger conclusion to Girish Nallan Chakravathy than the research evidence supports.

Where analysis is changed or extended, the resulting interpretation should be distinguished from the original research conclusion.

---

# 70. Separation of legal and scientific provenance

The repository maintains two related but distinct forms of provenance:

### Legal provenance

Identifies:

* copyright holders;
* licences;
* licence expressions;
* attribution requirements; and
* third-party rights.

### Scientific provenance

Identifies:

* source revision;
* experiment;
* harness;
* command;
* output;
* evidence record;
* checksum;
* release; and
* research conclusion.

Neither replaces the other.

A scientifically traceable artefact can still require third-party licensing information.

A correctly licensed artefact can still be scientifically unusable if its experimental provenance has been lost.

Both must therefore be preserved.

---

# 71. Required release audit

Before a research release is frozen, licensing and reuse must be audited.

At minimum, the release audit should establish that:

1. all covered files have licensing information through a valid REUSE mechanism;
2. required licence texts are present in `LICENSES/`;
3. no licence text is included without an actual corresponding use;
4. author-created documentation is correctly classified;
5. author-created software is correctly classified;
6. upstream files retain upstream licensing;
7. mixed and modified files have been reviewed;
8. required modification notices are present;
9. required NOTICE files are preserved;
10. unknown-provenance files have been investigated;
11. `REUSE.toml` rules do not accidentally capture upstream material;
12. file moves and renames have not changed licensing unintentionally;
13. archive contents retain their applicable licences;
14. repository citation information is current;
15. no repository wording falsely asserts ownership over third-party material; and
16. machine-readable licensing validation passes where the REUSE tooling is used.

A release must not be declared licensing-clean solely because the repository is publicly visible.

---

# 72. Public availability does not equal unrestricted ownership

Publication on GitHub makes material accessible.

It does not mean:

* all copyrights have been waived;
* all material is public domain;
* every file has the same licence;
* attribution may be removed;
* provenance may be falsified;
* third-party licence requirements disappear; or
* public visibility transfers ownership.

Reuse permission comes from the applicable licence, legal exception or other lawful basis.

---

# 73. Forking does not erase citation provenance

A downstream Git fork naturally records technical ancestry in many circumstances, but a Git fork alone should not be treated as a substitute for scholarly citation where the research contribution is substantively used in academic work.

For scholarly use, users should cite the research repository through `CITATION.cff` or an appropriate equivalent scholarly citation.

---

# 74. Reference to repository releases

Where reproducibility matters, citation should identify the relevant:

* release;
* tag;
* commit; or
* other stable research identifier

when available.

This enables another researcher to distinguish the cited evidence state from later repository development.

---

# 75. Preservation of checksums and provenance identifiers

Users may reproduce cryptographic hashes and provenance identifiers when identifying research evidence.

They should not alter an artefact and continue presenting the original checksum as though it authenticated the modified artefact.

A checksum identifies particular bytes; it is not a transferable certification label.

---

# 76. Relationship between licences

The author-created licensing defaults perform different roles.

### `CC-BY-4.0`

Used for applicable original non-software research material and author-held research collection/database rights.

It enables broad reuse and adaptation while imposing the attribution conditions contained in CC BY 4.0.

### `Apache-2.0`

Used for applicable independently authored research software.

It provides software-specific permissions and conditions, including applicable redistribution, notice and modification requirements.

Neither licence applies automatically to third-party material.

---

# 77. No additional hidden conditions

The repository does not impose undisclosed licence terms through:

* README prose;
* issue comments;
* commit messages;
* academic-integrity statements;
* repository descriptions;
* this policy;
* citation requests; or
* informal communications.

Legally binding licence permissions and conditions remain those of the applicable licence and law unless separate terms are expressly and validly agreed.

This protects both the author and downstream users from ambiguity.

---

# 78. Separate agreements

Nothing prevents a rights holder from entering into a separate written agreement concerning material for which that rights holder has authority.

A separate agreement does not automatically change the terms applying to other users or third-party material.

No informal assumption of special permission should be made where no such permission has been expressly granted.

---

# 79. Rights that cannot be licensed by the repository author

Nothing in this repository grants rights that Girish Nallan Chakravathy does not possess.

This includes, where applicable:

* third-party copyright;
* third-party patent rights;
* third-party trademark rights;
* privacy rights;
* publicity or personality rights;
* confidential information rights;
* institutional rights; and
* other rights controlled by another person or entity.

Users remain responsible for identifying rights outside the scope of the applicable copyright licence.

---

# 80. Applicable legal exceptions and limitations

Nothing in this policy is intended to restrict a use that is lawful without permission under an applicable copyright exception, limitation or other legal rule.

Likewise, the repository does not claim exclusive rights in material for which such rights do not legally exist.

---

# 81. Repository licensing hierarchy

When determining the applicable licensing information for a file, use the following hierarchy cautiously and together with the applicable REUSE rules:

1. legally valid file-specific licence information;
2. applicable file-level SPDX identifier or licence expression;
3. applicable adjacent `.license` metadata;
4. verified `REUSE.toml` licensing information;
5. applicable component-specific or directory-specific licence information;
6. applicable upstream copyright and licensing information;
7. repository defaults for verified author-created material; and
8. applicable law.

The hierarchy must not be used mechanically to override stronger evidence of actual provenance.

A specific erroneous label does not become legally correct merely because it is specific.

---

# 82. Conflict resolution

Where two licensing indicators conflict:

1. do not guess;
2. preserve the conflicting evidence;
3. identify the file's provenance;
4. inspect the original upstream source where relevant;
5. inspect relevant Git history and research records;
6. determine whether one statement concerns a snippet rather than the whole file;
7. determine whether a licence choice or combined expression applies;
8. correct machine-readable metadata only after the rights position is established; and
9. seek qualified guidance where a material unresolved legal uncertainty remains.

Scientific release pressure must not be used as justification for silently selecting the more convenient licence.

---

# 83. Authoritative legal texts

The authoritative legal conditions are the complete applicable licence texts.

For author-created material, these include:

```text
LICENSES/CC-BY-4.0.txt
LICENSES/Apache-2.0.txt
```

For third-party material, every additional licence referenced by covered files must likewise have the appropriate licence text preserved in accordance with the applicable REUSE and upstream requirements.

Summaries in this document are provided for clarity and do not replace those legal texts.

---

# 84. Repository citation and gratitude principle

This repository is shared without a royalty requirement because its purpose is to contribute to:

* education;
* formal verification research;
* post-quantum cryptography research;
* reproducible science;
* independent scrutiny;
* methodological improvement; and
* future research.

The author welcomes legitimate reuse, replication, criticism, extension and improvement.

The central reciprocal expectation is simple:

**preserve the provenance of the work and give appropriate credit.**

Where CC BY 4.0 applies, attribution is governed by that licence.

Where scholarly research makes substantive use of the repository, users should provide an appropriate scholarly citation to the repository, preferably using `CITATION.cff`.

Where third-party material is involved, its authors and rights holders must continue to receive every notice, attribution and licensing treatment to which they are entitled.

---

# 85. Core principle

The repository follows one overarching rule:

> **Licence what the author actually owns, preserve what belongs to others, identify every file as accurately as practicable, never use repository structure to manufacture ownership, and never allow reuse to erase scientific or legal provenance.**

Users are encouraged to:

**study the work, learn from it, reproduce it, verify it, challenge it, extend it, improve it and build upon it — while respecting the licences, authorship and provenance of everyone whose work is represented here.**

---

# 86. Final licensing summary

| Material                                                                       | Default treatment                                                                       |
| ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| Original non-software research material authored by Girish Nallan Chakravathy  | `CC-BY-4.0`                                                                             |
| Original research software authored by Girish Nallan Chakravathy               | `Apache-2.0`                                                                            |
| Original research collection/database rights held by Girish Nallan Chakravathy | `CC-BY-4.0`, unless otherwise stated                                                    |
| Third-party or upstream material                                               | Original applicable licence                                                             |
| Modified third-party material                                                  | Applicable upstream licence plus appropriate modification/provenance information        |
| Mixed-authorship material                                                      | File/snippet-specific verified licensing                                                |
| Generated evidence                                                             | Classified according to actual rights and provenance; no automatic ownership assumption |
| Public-domain/non-copyrightable material                                       | No new ownership created merely by repository inclusion                                 |
| Ambiguous material                                                             | No automatic author-created licence; review required                                    |

---

# 87. Associated repository files

This policy should be interpreted together with:

```text
LICENSE.md
CITATION.cff
LICENSES/
REUSE.toml
```

where those files are present and applicable, together with all preserved upstream licence, copyright and NOTICE information.

---

**Repository author and research contributor:**
Girish Nallan Chakravathy

**Author-created non-software research material:**
`CC-BY-4.0`

**Author-created research software:**
`Apache-2.0`

**Third-party material:**
Original applicable licence or licence expression

**Primary principle:**
Reuse is welcomed. Proper provenance, applicable attribution and licence compliance must be preserved.

