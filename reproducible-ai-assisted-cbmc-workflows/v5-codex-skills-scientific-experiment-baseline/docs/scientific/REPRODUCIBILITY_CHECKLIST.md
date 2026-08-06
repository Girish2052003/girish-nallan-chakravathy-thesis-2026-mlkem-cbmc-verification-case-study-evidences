# Reproducibility Checklist

Before an experimental run:

- verify the outer package SHA-256;
- verify `manifests/SHA256SUMS`;
- verify every skill's internal `SHA256SUMS`;
- verify the V1–V4 publication manifests;
- record source revision, specification package, environment and tool versions;
- freeze Condition-A and Condition-B inputs;
- declare sandbox, internet and resource policies;
- confirm the withheld anti-copy corpus is inaccessible to Codex.

During a run:

- capture Codex events and exact commands;
- preserve all generated/modified artefacts;
- preserve raw CBMC stdout, stderr and structured output;
- record skill discovery and invocation without forcing a sequence;
- do not expose acceptance/rejection feedback from the post-run evaluator.

After a run:

- freeze artefacts before anti-copy analysis;
- verify source/workspace integrity;
- execute the common evaluation rubric;
- separate tool completion, emitted-property status, selected-property coverage, non-vacuity, mutation evidence and scientific interpretation;
- preserve failed, incomplete and unresolved runs.
