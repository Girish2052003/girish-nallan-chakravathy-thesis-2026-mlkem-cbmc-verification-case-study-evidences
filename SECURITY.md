# Security Policy

## ML-KEM CBMC Verification Case-Study Evidence

This repository accompanies research on AI-assisted formal verification of
post-quantum cryptographic implementation code.

Its primary purpose is scientific evidence preservation, reproducibility,
provenance, auditability and research communication. It is not a production
cryptographic library, security product, certification authority or source of
deployment-ready cryptographic assurance.

## 1. Purpose of this policy

This policy explains how to report security-sensitive issues associated with
the repository without unnecessarily exposing potentially sensitive technical
details.

Relevant reports may concern, for example:

- a vulnerability in author-created research software or validation tooling;
- a security-relevant defect in a verification harness;
- a reproducibility problem that could materially change a reported security
  conclusion;
- accidental disclosure of credentials, tokens, secrets or private data;
- an integrity problem affecting retained evidence;
- a security-sensitive inconsistency between a research claim and its
  supporting artefact;
- an issue in repository infrastructure that could affect the authenticity or
  provenance of the evidence.

## 2. Reporting a security-sensitive issue

Do not publish exploit details, credentials, secrets or other genuinely
security-sensitive information in a public GitHub issue.

Where GitHub private vulnerability reporting is available for this repository,
use that mechanism for security-sensitive reports.

If a suitable private reporting mechanism is not available, contact the
repository maintainer through an appropriate contact method associated with
the maintainer's GitHub profile before publishing sensitive technical details.

Ordinary documentation errors, broken links, reproducibility questions and
non-sensitive research corrections may be reported through normal GitHub
issues.

## 3. Information useful in a report

Where applicable, a report should include:

- the affected file, script, harness, commit or release;
- the relevant repository path;
- a clear description of the issue;
- the conditions required to reproduce it;
- the observed and expected behaviour;
- the potential scientific or security impact;
- commands, logs or other evidence supporting the report;
- whether the issue affects author-created material, third-party material or
  both;
- whether public disclosure could create additional risk.

Please avoid including unnecessary personal data or unrelated confidential
information.

## 4. Research evidence and frozen artefacts

Some directories contain frozen source snapshots, historical campaign
artefacts, raw verification output, manifests, hashes and other records whose
scientific value depends on preserving their historical identity.

A security report does not automatically justify modifying those historical
artefacts.

Where a genuine defect is discovered in frozen evidence, the preferred
approach is normally to preserve the original artefact and add an auditable
correction, qualification, superseding record or new evidence package as
appropriate.

Historical evidence should not be silently rewritten in a way that obscures
what was actually executed, observed or retained at the recorded point in
time.

## 5. Third-party and upstream software

This repository contains or preserves third-party and upstream material.

The presence of such material in this repository does not make the repository
author its security maintainer.

If a reported issue originates entirely in an upstream project, the reporter
may also need to follow that project's own security-reporting process.

When appropriate, this repository may record the relationship between an
upstream issue and the research evidence retained here without claiming
ownership or maintenance responsibility for the upstream software.

## 6. Cryptographic and formal-verification scope

A successful bounded verification result is evidence for the property,
assumptions, model, domain and bounds actually checked.

It must not be interpreted automatically as proof that:

- the complete cryptographic system is secure;
- every possible implementation behaviour has been verified;
- the software is free from all vulnerabilities;
- the implementation is suitable for production deployment;
- a bounded result establishes unrestricted mathematical correctness; or
- the repository constitutes certification, accreditation or a security
  guarantee.

Security reports should therefore distinguish between:

1. an implementation vulnerability;
2. a modelling or harness defect;
3. a verification-tool or configuration issue;
4. an evidence-integrity problem; and
5. a disagreement about the interpretation or scope of a research result.

## 7. Evidence integrity

Reports concerning possible evidence manipulation, hash mismatches,
misidentified source versions, broken provenance, incorrect repository
locators or inconsistent retained artefacts are particularly important.

Such reports should identify the affected evidence record as precisely as
possible.

Repository corrections should preserve a traceable relationship between:

- the original record;
- the discovered problem;
- the corrective action;
- any superseding evidence; and
- the resulting scientific interpretation.

## 8. Coordinated disclosure

Where an issue presents a credible security risk, reasonable efforts should be
made to avoid unnecessary public disclosure before the affected maintainers
have had an opportunity to understand the report.

This repository does not promise a fixed response, remediation or disclosure
timeline.

The appropriate handling of a report depends on its severity, reproducibility,
scope, ownership and relationship to third-party software.

## 9. No suppression of legitimate scientific criticism

This security policy is not intended to prevent responsible criticism,
replication, falsification, independent analysis or publication of legitimate
research findings.

Security-sensitive information should be handled responsibly, but disagreement
with the thesis, methodology or interpretation is not itself a security
incident.

## 10. Relationship to licensing and provenance

Security reporting does not change copyright ownership, licensing,
attribution, authorship or provenance.

For those matters, refer to:

- `LICENSE.md`;
- `REUSE_AND_LICENSING.md`;
- `REUSE.toml`;
- `LICENSES/`; and
- `CITATION.cff`.

## 11. Research status

This repository is a research evidence repository.

Its contents are provided for research, verification, reproducibility,
education and scientific scrutiny under the applicable licences and
third-party terms.

No security guarantee, deployment warranty or certification is created by
publication of the repository or by this security policy.
