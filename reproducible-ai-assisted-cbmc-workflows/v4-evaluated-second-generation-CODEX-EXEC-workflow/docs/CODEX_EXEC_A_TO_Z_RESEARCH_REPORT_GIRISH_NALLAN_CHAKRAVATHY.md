# Controlled Codex Exec Integration into the Deterministic LLM–CBMC Verification Pipeline

## Complete Implementation, Verification, and Scientific Readiness Report

**Author:** Girish Nallan Chakravathy  
**Research reference date:** 25 July 2026  
**Integration archive date:** 25 July 2026  
**Independent verification audit date:** 25 July 2026  
**Document generation date:** 25 July 2026  
**Document status:** Final retrospective research record  
**Research-record identifier:** `CODEX-EXEC-CONTROLLED-INTEGRATION-2026-07-25`

### Chronology qualification

I assign the four dates above as the effective dates of the thesis research record. I do not use those dates as claims about operating-system timestamps, archive-member timestamps, or the moment at which the retrospective digital reconstruction was executed. I preserve the machine-generated execution timestamps in the companion JSON evidence so that the research record remains chronologically auditable. I use the term *independent verification* in this report to mean a fresh extraction, a separate verification pass, and a clean evidence review after implementation; I do not represent the audit as an external third-party certification.

---

## Executive conclusion

I integrated Codex CLI execution into the existing V4 deterministic LLM–CBMC workflow as an alternative backend rather than as a replacement architecture. I retained the original Responses API route, the existing stage order, the immutable experiment protocol, deterministic semantic gates, CBMC authority, handoff manifests, experiment logging, and final claim boundaries. I added a controlled `codex_exec` route that receives the complete prepared stage input, executes Codex in a repository workspace, streams terminal output, records machine-readable evidence, enforces a write allowlist, restores unauthorised modifications, validates execution-control evidence, records the exact Codex executable identity, and accepts only schema-valid output after all fail-closed conditions pass.

I did not accept the earlier implementation merely because the dedicated happy-path test passed. I treated every earlier claim as a testable proposition. The first audit exposed a maintainability regression, a canonical-protocol configuration error, packaged Python cache files, a denylist rather than a true write allowlist, omission of base64 primary evidence, absent reasoning-effort forwarding, incomplete Codex provenance, weak timeout descendant handling, an inherited environment broader than necessary, and no live authenticated Codex result. I repaired each code-level defect that could be repaired inside the package. During the final hardening pass, I also identified and closed two additional paths: symlink indirection inside mutable roots and attempted modification of Codex execution-control evidence.

The final code passed the dedicated adversarial Codex integration test, the maintainability gate, the mandatory A-to-Z behavioural gate, the package-hygiene gate, and the complete repository regression inventory. The final regression result was **56 passed, 0 failed, 0 unexecuted**. I therefore classify the implementation as **code-complete and accepted for the offline, simulated-Codex integration scope defined in this report**.

I do not classify a live Codex service experiment as verified. No authenticated production Codex invocation, live account/model availability check, or complete real Codex-to-CBMC research run was executed in the verification container. I therefore make no claim that a named live model solved the earlier formal-methods task, that the optimisation removed the earlier failure in production, or that a formal ML-KEM property was established by the new backend. Those claims require a separately frozen host execution packet containing the real Codex event trace, runtime provenance, generated artefact, deterministic gate decisions, CBMC output, non-vacuity evidence, and repeated matched runs.

---

## Abstract

I developed and verified a controlled Codex CLI backend for an existing staged workflow that combines large-language-model assistance with deterministic validation and bounded model checking. The research problem was not the mechanical invocation of `codex exec`; the central problem was preservation of experimental authority. Codex had to retain useful repository inspection, command execution, artefact generation, and iterative reasoning capabilities while remaining subordinate to a frozen architecture in which deterministic checks and CBMC decide whether a formal claim is supportable.

I implemented backend selection at the common LLM client, preserving the existing Responses API default. I materialised all file-based evidence byte-for-byte, translated the prepared stage input without discarding non-text items, passed a stage-specific JSON schema to Codex, forwarded the configured model and reasoning effort, captured exact command and runtime provenance, streamed terminal events, constrained the child environment, controlled process retries, and terminated timeout descendants as a process group. I implemented a project-tree write allowlist using before/after snapshots and private backups. I rejected additions, deletions, modifications, type changes, mode changes, and symlink changes outside declared mutable roots. I restored unauthorised changes and verified the restoration. I also rejected symlinks inside mutable roots and protected the schema, provenance record, input manifest, and materialised evidence against child-process alteration.

I verified the implementation through static inspection, syntax compilation, dedicated simulated-Codex tests, adversarial mutation tests, control-evidence tampering, binary-evidence preservation, non-zero exits, schema failures, timeout child-process tests, maintainability checks, canonical-protocol checks, package-hygiene checks, and the repository regression runner. The final discovered inventory contained 56 tests, all of which passed. Two local fake-Responses-API paths required a test-only OpenAI import shim because the verification environment could not install the package’s pinned `openai==2.45.0` dependency from its configured package index. I kept that shim outside the release and did not use it to validate the Codex backend.

The result establishes that the new backend is structurally integrated, fail-closed under the tested threat model, compatible with the existing pipeline, terminal-observable, and reproducibly evidenced. The result does not establish live Codex service behaviour or formal correctness of an ML-KEM target. I define the next experimental step as a paired, repeated comparison between the historical failure condition and the controlled integration under frozen source, model, Codex binary, prompt, property, CBMC, and acceptance criteria.

---

## 1. Research problem and motivation

I am investigating AI-assisted formal methods for post-quantum cryptographic implementation work. In that setting, a coding agent may inspect specification material, understand C code, propose properties, generate a CBMC harness, analyse a counterexample, repair an artefact, and prepare an explanation. None of those activities is equivalent to a proof. A persuasive answer can still be vacuous, mis-scoped, disconnected from production source, dependent on an invalid assumption, or unsupported by the formal tool.

I therefore designed the pipeline around a separation of powers. The model proposes candidate content. The architecture freezes the experiment, records evidence, and checks structural obligations. CBMC evaluates the bounded verification condition. Mutation and non-vacuity checks challenge accidental green results. The evaluation layer may describe only the claims mapped to accepted tool evidence. Human review remains responsible for interpreting the scope and limitations.

The failed Codex integration created a useful research question. A later architectural optimisation may plausibly convert an unreliable agent workflow into a reliable one. That possibility cannot be demonstrated by describing the later output as better or by observing one successful terminal session. A valid result requires matched inputs, frozen tools, predefined acceptance criteria, and a complete record of both successes and failures. I built the integration to make that comparison possible without granting Codex authority over the experiment.

### 1.1 Research question

I frame the technical research question as follows:

> Can Codex retain repository-level coding-agent capability while operating inside a deterministic LLM–CBMC workflow that prevents unauthorised source modification, preserves complete primary evidence, records exact execution provenance, exposes terminal activity, and accepts output only after fail-closed structural and formal gates?

### 1.2 Engineering hypothesis

I test the engineering hypothesis that an execution backend can improve functional usefulness without weakening the trust chain when the following conditions hold:

1. backend selection is explicit and reproducible;
2. the original end-to-end workflow remains unchanged outside the common execution boundary;
3. the exact prepared evidence reaches Codex;
4. writable locations are explicit and enforced;
5. unauthorised changes are detected and restored;
6. child-process output is observable and preserved;
7. model, binary, configuration, prompt, and environment provenance is recorded;
8. process failure, timeout, schema failure, or boundary failure prevents authoritative handoff;
9. CBMC remains the authority for formal claims.

### 1.3 Acceptance interpretation

I use *perfect implementation* only in a bounded engineering sense. I accept a claim only when every declared package-level acceptance criterion passes under the tested environment and threat model. I do not interpret the phrase as a proof of absence of all possible defects. I explicitly separate code-level integration acceptance from live service validation and from formal verification of a cryptographic property.

---

## 2. Baseline architecture preserved

I preserved the stage-organised workflow rather than constructing a parallel Codex-only pipeline. The principal run stages remain:

| Stage | Function | Authority classification |
|---|---|---|
| `01_master_orchestrator` | run setup, immutable protocol identity, stage sequencing, status and handoff control | deterministic control plane |
| `02_spec_extraction` | extraction of candidate obligations from specification evidence | LLM-assisted candidate stage |
| `03_code_understanding` | implementation analysis and code obligations | LLM-assisted candidate stage |
| `04_property_discovery` | campaign-bounded property candidates | LLM-assisted candidate stage |
| `05_artifact_generation` | harness or contract candidate generation | LLM-assisted candidate stage |
| `06_review_critic` | scope, readiness, and defect criticism | LLM-assisted with deterministic gates |
| `07_tool_execution` | CBMC and related deterministic execution | formal-tool authority |
| `08_counterexample_analysis` | evidence-bound interpretation of failed tool results | LLM-assisted candidate stage |
| `09_repair_refinement` | controlled candidate repair | LLM-assisted candidate stage |
| `10_experiment_logger` | checksums, inventory, reproducibility and stage classification | deterministic evidence stage |
| `11_evaluation_reporter` | cautious interpretation within recorded claim boundaries | mixed reporting stage |

I verified that `LLMClient` is used by specification extraction, code understanding, property discovery, artefact generation, review/critic, counterexample analysis, repair, and evaluation reporting. The tool-execution and experiment-logging stages remain outside the Codex authority path. This placement is important: Codex can contribute to candidate creation and analysis, but it cannot replace the formal tool or rewrite the experiment record.

I retained `responses_api` as the default backend. The new path is selected only when the resolved configuration contains:

```json
"execution_backend": "codex_exec"
```

An unsupported value fails. This explicit dispatch prevents hidden behavioural changes in individual agents and permits matched comparisons between API execution and Codex CLI execution.

---

## 3. Defects identified before final acceptance

I conducted an initial verification audit before preparing the final release. That audit rejected the earlier “perfect” classification. The following defects were substantiated.

| Identifier | Defect | Consequence | Final disposition |
|---|---|---|---|
| D1 | `LLMClient.run_stage()` exceeded the approved maintainability budget | repository regression failure and difficult review | refactored; 152 lines; gate passed |
| D2 | Codex template used `semantic_advisory_mode=reference_only` | violation of canonical `llm-first-v1` experiment condition | changed to `off`; gate passed |
| D3 | compiled `.pyc` files were packaged | mutable-source residue and non-clean release | removed; hygiene gate passed |
| D4 | `codex_mutable_paths` was recorded but not enforced | Codex could modify an unlisted path such as `scripts/control.py` | replaced with true allowlist snapshot and rollback |
| D5 | base64 primary evidence was omitted from the Codex prompt | incomplete evidence transmission | exact API-input translation and byte materialisation added |
| D6 | reasoning effort was not forwarded | declared experimental condition differed from actual command | `model_reasoning_effort` mapping added |
| D7 | Codex CLI version and executable hash were absent | inadequate reproducibility | binary path, size, SHA-256, version output and exact match added |
| D8 | timeout handling did not guarantee descendant termination | delayed child process could alter files after parent timeout | process-group termination added and tested |
| D9 | child process inherited the full environment | unnecessary secret and state exposure | minimal allowlisted environment added |
| D10 | working-directory behaviour could depend on launch location | weak portability and source binding | project-root discovery and containment checks added |
| D11 | broad `--add-dir` use was insufficiently constrained | writable scope could expand beyond the experiment | add directories restricted to mutable roots inside project root |
| D12 | no real authenticated Codex run existed | live service behaviour remained unverified | retained as an explicit limitation, not concealed |
| D13 | mutable-root symlinks could create path indirection | allowlist interpretation could be bypassed or obscured | pre-run rejection, post-run detection and cleanup added |
| D14 | Codex could attempt to alter schema or input evidence inside mutable run storage | execution evidence could become self-modified | byte-level control-integrity gate and restoration added |
| D15 | terminal logs were stored directly in child-visible paths | child process could attempt to replace preserved logs | parent-private capture followed by parent copy added |
| D16 | unresolved model placeholders could silently fall back to a default | experiment model identity could differ from configuration intent | concrete model is now mandatory before launch |

I did not treat D12 as a code defect that could be fabricated away. I retained it as an external validation requirement. Every other listed defect was repaired and covered by direct tests or repository regressions.

---

## 4. Final integration architecture

### 4.1 Common execution boundary

I implemented the Codex adapter in `agents/common/codex_exec_backend.py` and connected it through `agents/common/llm_client.py`. This location keeps backend logic out of individual agents and preserves one execution contract for all LLM-assisted stages.

The dispatch sequence is:

```text
resolved stage request
  -> existing prompt and evidence preparation
  -> execution_backend selection
       -> responses_api: unchanged pre-existing route
       -> codex_exec: controlled CLI route
  -> common stage result and validation record
  -> authoritative stage output only after acceptance
```

I preserved the existing stage result type and validation path. Downstream agents therefore consume the same handoff structure regardless of backend. The integration changes the execution mechanism, not the workflow semantics.

### 4.2 Configuration surface

I added the following controlled settings:

```text
codex_binary
codex_working_directory
codex_sandbox
codex_approval_policy
codex_skip_git_repo_check
codex_stream_terminal
codex_timeout_seconds
codex_add_dirs
codex_protected_paths
codex_mutable_paths
codex_enforce_change_boundary
codex_ignore_user_config
codex_ignore_rules
codex_expected_version
codex_require_version_match
codex_ephemeral
codex_strict_config
codex_minimal_environment
codex_environment_allowlist
codex_max_final_output_bytes
codex_process_termination_grace_seconds
```

I retained the common model, retry, strict-JSON, reasoning, and text-verbosity settings. The configuration template pins Codex CLI `0.144.4`, requires an exact version match, enables strict configuration, enables ephemeral execution, ignores personal Codex configuration, uses a minimal environment, enables terminal streaming, and enforces the write boundary.

### 4.3 Working-root resolution

I do not derive the working root from the shell’s current directory alone. The backend searches upward from the run directory for the workflow markers `agents/common/llm_client.py` and `configs/`. An explicitly configured path must resolve to a real directory. The run directory must remain inside the project root and inside a declared mutable root.

This rule binds Codex execution to the workflow tree that owns the run evidence. It also prevents an unrelated launch directory from silently changing the repository scope.

---

## 5. Complete primary-evidence transmission

The pre-existing LLM client constructs a provider-neutral prepared input containing `input_text` and, when configured, `input_file` items. The earlier Codex adapter concatenated text items and discarded file items. I replaced that approximation with an exact traversal of the prepared input.

For each text item, I preserve the role and complete text. For each file item, I require a valid base64 data URI, decode the payload with validation, and materialise the exact bytes under the stage’s Codex evidence directory. I record:

- original filename;
- materialised path;
- MIME type;
- byte count;
- SHA-256 digest;
- item index.

I add the same path, size, and digest to the Codex prompt with an explicit instruction to inspect the complete file. The `input_materialization.json` manifest records the total message count, materialised-file count, prompt byte count, prompt SHA-256, and file records.

The binary-evidence test uses a payload containing both `0x00` and `0xff`. The fake Codex process reads the materialised file and records its digest. The test compares the source digest, manifest digest, and Codex-observed digest. All values match. This test demonstrates byte preservation rather than merely filename preservation.

I also hash the materialised files before launch and verify them again after Codex exits. Any attempted modification causes a security failure and restoration of the original bytes.

---

## 6. Codex command and retained capability

I construct the non-interactive command from an argument list rather than a shell string. The controlled form is:

```text
<resolved-codex-binary> exec
  --json
  --color never
  --strict-config
  --ephemeral
  --sandbox workspace-write
  --cd <resolved-workflow-root>
  --output-schema <stage-output-schema>
  --output-last-message <attempt-final-message>
  --model <configured-concrete-model>
  --skip-git-repo-check
  --ignore-user-config
  --config approval_policy="never"
  --config model_reasoning_effort="high"
  -
```

I emit `--ignore-rules` only when explicitly enabled. I emit `--add-dir` only after resolving the path inside the project root and proving that it lies inside a declared mutable root. I reject a missing model, a placeholder model, an unsupported `reasoning_mode`, an external add directory, or an overlapping mutable/protected boundary before launch.

This command retains the practical capabilities required from Codex. Codex can read the repository, inspect evidence, execute commands, generate files in controlled mutable locations, and return a structured candidate. The architecture does not reduce Codex to a text-completion call. The architecture restricts where Codex may write and what conditions must hold before its result enters the authoritative stage handoff.

I verified the relevant options against the pinned Codex source definition and configuration schema for tag `rust-v0.144.4`. The primary implementation references are listed in Appendix F.

---

## 7. Terminal observability and evidence capture

### 7.1 Live streaming

I start Codex with pipes for standard input, standard output, and standard error. Separate pump threads read output line-by-line. When terminal streaming is enabled, every line is written immediately with a stage prefix:

```text
[CODEX:<stage-key>] <child-output-line>
```

This format permits direct observation of stage activity while preserving stage identity in a multi-stage run.

### 7.2 Parent-controlled capture

I do not rely on a child-visible evidence file as the sole record of the stream. I capture standard output and standard error in a private temporary directory controlled by the parent process. After the child has terminated and the pump threads have joined, I copy the completed stream files into the stage evidence directory. This prevents a child command from silently truncating or replacing the preserved event and diagnostic logs through a known workflow path.

### 7.3 Evidence files

Each attempt records:

```text
attempt_NN/
  command.json
  events.jsonl
  stderr.log
  last_message.json
  change_boundary.json
```

The stage-level directory records the latest attempt plus:

```text
output_schema.json
input_materialization.json
runtime_provenance.json
execution_summary.json
llm_call_validation.json
input_files/
```

I record the exact argument vector rather than a reconstructed display command. I record the working directory, prompt byte count and digest, sandbox, approval policy, model, reasoning controls, protected paths, mutable allowlist, add directories, environment-variable names, runtime-provenance path, and lock method. I intentionally omit credential values.

---

## 8. Deterministic workspace boundary

### 8.1 Allowlist model

I use the mutable-path list as a real allowlist. The default mutable roots are:

```text
runs/
reports/
workspace/
artifacts/
```

Every project entry outside those roots is guarded, including paths not named in the protected-path list. This is stricter than the earlier denylist design. A path such as `scripts/control.py` is guarded even though `scripts/` is not in the default protected-path display list.

### 8.2 Snapshot content

I snapshot each guarded entry using `lstat`. The record distinguishes regular files, directories, symlinks, and other filesystem types. For regular files, I record SHA-256, byte size, and mode. For directories, I record mode. For symlinks, I record the link target and mode.

After Codex exits, I calculate:

- added paths;
- deleted paths;
- modified paths;
- the union of all unauthorised changes.

A content change, mode change, path-type change, new path, deleted path, or symlink-target change is therefore visible.

### 8.3 Private backup and rollback

Before execution, I copy the guarded tree into a private temporary backup outside the project. When an unauthorised change appears, I remove the changed destination, restore the original file, directory, or symlink, and run a confirmation snapshot. I record restoration errors and any remaining differences. A security failure stops retry processing.

The dedicated adversarial test changes `scripts/control.py`. The stage fails, the boundary record names the file, the original content is restored, and the post-restore snapshot is clean.

### 8.4 Mutable-root symlink rule

A mutable root can otherwise conceal indirection into another path. I therefore reject any pre-existing symlink under a mutable root. I scan the mutable roots again after execution. A symlink created during an attempt fails the stage and is removed. The dedicated test creates `workspace/forbidden-link`; the stage fails and the link is absent after cleanup.

The deterministic snapshot governs the workflow project tree. External filesystem containment additionally depends on Codex `workspace-write` sandbox enforcement and the host operating system. I do not claim that a Python snapshot alone constitutes an operating-system sandbox.

### 8.5 Serialisation

I protect the snapshot-execute-snapshot interval with a process-local thread lock and, on POSIX systems, an exclusive `flock` stored under the first mutable root. This prevents two controlled Codex attempts from racing against the same project state.

---

## 9. Execution-control integrity

The stage schema, runtime-provenance record, input-materialisation manifest, and each materialised evidence file are part of the control plane. They reside under the run directory, which is mutable by design, so path allowlisting alone is not sufficient.

I capture the exact bytes of those files before Codex starts. After Codex exits, I compare every file byte-for-byte. If a file is missing, replaced, or modified, I record the change, restore the original bytes, verify the restoration, and fail the stage. I rewrite `command.json` from parent-held data after process termination. I capture standard output and standard error outside the child-visible project path, as described earlier.

The control-evidence adversarial test modifies the file passed through `--output-schema`. The stage does not accept the otherwise schema-valid final message. The original schema is restored, and the validation record reports failed control integrity with successful restoration.

I leave `last_message.json` Codex-authored by design. It is the candidate output and must therefore remain under agent control. It becomes authoritative only after process, boundary, restoration, size, parse, and schema gates all pass.

---

## 10. Runtime provenance and environment control

### 10.1 Executable identity

I resolve the configured Codex binary with the host path resolver and convert it to a canonical absolute path. I record:

- binary path;
- binary size;
- binary SHA-256;
- version command;
- version return code;
- complete version output;
- detected semantic version;
- expected semantic version;
- exact version-match Boolean;
- Python version;
- platform identifier;
- operating-system family.

I extract the first semantic version token and compare it for equality. A substring such as `0.144.40` does not satisfy an expectation of `0.144.4`. When exact matching is required, a mismatch fails before the Codex stage begins.

### 10.2 Model and reasoning identity

I require a concrete model identifier. The unresolved template value cannot silently fall through to a Codex default. I pass the model with `--model` and record it in `command.json`.

I map the common reasoning-effort setting to:

```text
--config model_reasoning_effort="high"
```

I also map supported reasoning-summary and text-verbosity values to the pinned Codex configuration keys. I reject the common `reasoning_mode` field for this backend because the pinned CLI configuration schema does not define a matching key. A silent approximation would damage experimental reproducibility.

### 10.3 Minimal environment

I construct a minimal child environment by default. The allowlist includes essential execution variables such as `PATH`, home-directory and locale variables, temporary-directory variables, certificate paths, proxy variables when required, and the configured API-key variable name. I record only the names of variables passed to the child. I do not record secret values.

An explicit configuration can disable the minimal environment, but the release template keeps it enabled.

---

## 11. Process lifecycle, timeout, and retries

I launch Codex in a new POSIX session. When the timeout expires, I send `SIGTERM` to the process group, wait for the configured grace period, and send `SIGKILL` to the process group when necessary. The Windows fallback uses `taskkill /T /F`, followed by direct termination if required.

The timeout adversarial test starts a descendant process that waits and then attempts to change `scripts/control.py`. The parent Codex process intentionally sleeps past the timeout. After process-group termination and an additional delay, the protected file remains unchanged. This result verifies descendant termination under the POSIX test environment.

I interpret `max_retries` as complete Codex process retries. Every attempt receives an independent evidence directory. A schema failure or ordinary non-zero exit may be retried according to configuration. A security failure terminates the retry sequence immediately. This policy prevents repeated execution after a boundary violation.

I enforce a local maximum byte size for the final message before parsing. This limit is a postcondition on the Codex result; I do not misrepresent it as a provider-side generation-token limit.

---

## 12. Structured output and authoritative handoff

I supply the stage-specific JSON schema through `--output-schema`. Codex writes the final message through `--output-last-message`. The common strict JSON parser extracts the result, and the existing schema validator checks the parsed object.

I define acceptance as the conjunction:

```text
process return code = 0
AND timeout = false
AND unauthorised project-tree change = false
AND mutable-root symlink violation = false
AND execution-control alteration = false
AND every required restoration succeeded
AND final output byte limit satisfied
AND strict JSON extraction succeeded
AND stage JSON schema validation succeeded
```

Only then does the backend call the existing authoritative-output writer. A failed attempt produces validation and evidence but no authoritative stage JSON.

I verified fail-closed behaviour for:

- non-zero return code;
- timeout;
- invalid schema;
- unauthorised source-tree modification;
- mutable-root symlink creation;
- execution-control modification;
- unresolved model placeholder;
- Codex version mismatch;
- invalid boundary configuration;
- missing Codex binary.

The final `LLMStageResult` retains the common structure used by the original pipeline. Downstream stage logic therefore does not need Codex-specific exceptions.

---

## 13. Formal-methods authority boundary

I preserve the central research rule:

```text
Codex capability is not Codex authority.
```

Codex may propose a candidate property or artefact. The deterministic review layer must still check target binding, assertion presence, assumption discipline, forbidden transformations, scope consistency, tautology risk, source identity, and tool readiness. The tool-execution stage must run the intended CBMC command and preserve structured output. The selected claim must map to emitted properties. A zero-property or vacuous success cannot become a verification result. Mutation and non-vacuity evidence remain mandatory where the protocol requires them.

I therefore do not describe a schema-valid Codex response as proof. The response is an authoritative *candidate stage output* only. Formal authority remains with the frozen source, the verification intent, deterministic gates, CBMC evidence, and the final bounded claim interpretation.

---

## 14. Final configuration template

The final template is `configs/CONFIG_TEMPLATE_CODEX_EXEC.json`. Its important controls are:

```json
{
  "llm": {
    "mode": "real",
    "execution_backend": "codex_exec",
    "model": "SET_TO_A_CODEX_MODEL_AVAILABLE_TO_YOUR_ACCOUNT",
    "codex_binary": "codex",
    "codex_working_directory": null,
    "codex_sandbox": "workspace-write",
    "codex_approval_policy": "never",
    "codex_stream_terminal": true,
    "codex_timeout_seconds": 1800,
    "codex_ignore_user_config": true,
    "codex_ignore_rules": false,
    "codex_enforce_change_boundary": true,
    "codex_mutable_paths": ["runs", "reports", "workspace", "artifacts"],
    "codex_expected_version": "0.144.4",
    "codex_require_version_match": true,
    "codex_ephemeral": true,
    "codex_strict_config": true,
    "codex_minimal_environment": true,
    "codex_max_final_output_bytes": 2000000,
    "reasoning": {"effort": "high"}
  },
  "experiment_protocol": {
    "protocol_version": "llm-first-v1",
    "semantic_advisory_mode": "off",
    "structured_cbmc_json_required": true,
    "mutation_non_vacuity_required": true
  }
}
```

The model and source revision remain deliberate placeholders. The backend rejects an unresolved model at execution time. The template keeps CBMC dry-run mode enabled so that a copied template cannot accidentally be presented as a real formal experiment before host acceptance and source binding are completed.

---

## 15. Verification methodology

### 15.1 Chain of custody

I began from the supplied baseline archive:

```text
v4-evaluated-second-generation-llm-integrated-workflow.zip
```

I extracted the archive into a separate working directory, preserved the original extraction for comparison, and performed the integration in a second tree. I compared the final tree with the original at the path and byte level. I removed generated Python cache files before packaging. I generated SHA-256 manifests for the changed files and the final distribution.

### 15.2 Static verification

I inspected:

- every added Codex configuration field;
- configuration parsing and defaults;
- backend dispatch;
- prepared-input translation;
- command construction;
- model and reasoning forwarding;
- runtime provenance;
- minimal environment construction;
- working-root resolution;
- mutable/protected overlap detection;
- add-directory containment;
- snapshot and backup logic;
- rollback and post-restore verification;
- symlink policy;
- control-evidence integrity;
- process-group timeout handling;
- retry termination after security failure;
- schema and authoritative-output conditions;
- package contents and residue.

I compiled the changed Python files and checked function lengths against the repository maintainability gate. `LLMClient.run_stage()` is 152 lines, below the approved limit of 159. The largest new backend function is 149 lines.

### 15.3 Dynamic verification

I executed the dedicated Codex integration suite using a deterministic fake Codex executable. The fake executable implements `--version`, reads standard input, writes a final JSON message, emits a JSONL event, and can be configured to mutate files, alter the schema, create symlinks, return a non-zero code, violate the schema, or spawn a delayed descendant.

The dedicated suite verifies:

1. successful structured handoff;
2. an allowed write under `workspace/`;
3. exact model-reasoning command mapping;
4. binary hash and exact CLI version provenance;
5. rejection and rollback of `scripts/control.py` modification;
6. byte-exact base64 evidence materialisation;
7. schema failure;
8. non-zero return-code failure;
9. timeout descendant termination;
10. execution-control tampering and restoration;
11. mutable-root symlink rejection and cleanup.

### 15.4 Repository regressions

I ran the repository’s discovered regression inventory through `scripts/run_regressions.py` with a 300-second per-test limit. The final inventory hash and complete test list are preserved in the release evidence.

The final outcome was:

```text
Discovered tests: 56
Executed tests: 56
Passed tests: 56
Failed tests: 0
Unexecuted tests: 0
Complete: true
All passed: true
```

### 15.5 Dependency qualification

The package declares:

```text
openai==2.45.0
httpx==0.28.1
jsonschema==4.26.0
pypdf==5.9.0
```

The verification environment’s configured package index did not provide the pinned OpenAI package. Two local fake-Responses-API end-to-end paths therefore could not import `OpenAI` in an otherwise unchanged environment. I used a minimal test-only compatibility shim outside the package to exercise those local fake-server tests. I did not include the shim in the release, and I did not use it for the Codex backend tests. I classify the 56-test result as a repository behavioural regression result under the disclosed test environment, not as validation of the real OpenAI Python SDK.

---

## 16. Final verification results

### 16.1 Gate summary

| Gate | Result | Evidence interpretation |
|---|---|---|
| Python syntax | PASS | changed modules compile |
| Dedicated controlled Codex integration suite | PASS | success and adversarial paths accepted |
| Maintainability and portability | PASS | refactoring satisfies repository budget |
| Mandatory A-to-Z behavioural repairs | PASS | all 12 behavioural checks pass |
| Mutable package structure | PASS | no `.pyc` or `__pycache__` residue |
| Complete discovered regression inventory | PASS | 56/56 pass |
| Real authenticated Codex service run | NOT EXECUTED | external validation remains required |
| Fresh real CBMC 6.9.0 host experiment through Codex | NOT EXECUTED | formal research result remains required |

### 16.2 Adversarial result summary

| Adversarial action | Expected result | Observed result |
|---|---|---|
| modify `scripts/control.py` | reject and restore | rejected; original restored |
| create allowed `workspace/allowed.txt` | permit | permitted |
| create symlink under mutable root | reject and remove | rejected; link removed |
| modify output schema | reject and restore | rejected; schema restored |
| attach binary primary evidence | preserve exact bytes | source, manifest, and observed digests match |
| produce schema-invalid JSON | reject | rejected |
| exit with code 7 | reject | rejected with typed error |
| exceed timeout and spawn delayed child | kill process group and prevent late mutation | timeout recorded; protected file unchanged |
| report wrong Codex version | reject before stage | exact version gate rejects |
| leave model placeholder unresolved | reject before stage | launch blocked |

### 16.3 Regression inventory

1. `tests/verify_26_property_contract_extension.py` — `13556a2144e8a05c9ea5dd09516475937ca6ba6c8d9a2eee985a09ad1138673b`
2. `tests/verify_26_property_repair_and_claim_boundaries.py` — `cdd89faa502243c7e6f249bbc4c457158e47a0fad5151dfe8f17878277919f43`
3. `tests/verify_agent10_stage_classification_and_agent11_wording.py` — `7b9526bb6e0c0fc18595a71557e06c78710b566533bf6a8850c176b23d73f89b`
4. `tests/verify_agent11_compact_evidence_budget.py` — `f592e9b0c29a3273302d66f9355f96340c619a606c31761b035289527ee70d44`
5. `tests/verify_agent4_campaign_candidate_separation.py` — `b31569e402731310ff02964327e715e9d3f5c5015320bb187dd33664485dd061`
6. `tests/verify_agent5_scope_consistency.py` — `ee0b692bbaf2de3586078eb1ced7a7d06e023b8d32139ab494e9c26cf18f1910`
7. `tests/verify_blocker1_schemas.py` — `58bec4de9ee51627299ba1738d3a339d54a1da06562994643eeafd397225fe06`
8. `tests/verify_blocker2_config_contract.py` — `8f6ffcc87438c31d25114ea0607f2d9caac7186117218053904639f3b680adfd`
9. `tests/verify_blockers3_to_8.py` — `b6f779a063f5f429896682af80bf9516415a36b08a7631ee04386d96bf6f9122`
10. `tests/verify_canonical_tool_result_contract.py` — `185541a561e00d94929734f3fbc17f01d6f5d19ef86e16309130c8ef6ea72e8e`
11. `tests/verify_canonical_tool_workflow_transitions.py` — `89abfb4143a31801f0165c52451d4c67ae95d79dc17798a54bd8eeb15fa19b28`
12. `tests/verify_central_fail_closed_hardening.py` — `03973be7a79667cfd5989f484072c4dd6be2b688971c9fe3d749fe2e01a2d81e`
13. `tests/verify_central_llm_profile.py` — `0a75b5855db966afd7e258b77513d62b4e1418572b5d69109fb2fd05f81d357b`
14. `tests/verify_codex_exec_integration.py` — `50791f624ddbab2151a98516500a9a497c1c205b191ee201e55e8ef6442c3182`
15. `tests/verify_contract_expression_and_run001_replay.py` — `7b657ef86069a93f82602d8c8b9ae4cf11c19fbe42b636c102219f77362472a5`
16. `tests/verify_critic_tool_readiness_policy.py` — `856bded3be267a29e56004ec52bfb8324cfec7eef74367778464b6b78fdcac9e`
17. `tests/verify_definitive_winner_result_integrity.py` — `9de9877ce63e17beb682cb2b6b89fab00c6a00ead78b44457d978994f9d53515`
18. `tests/verify_deployment_gate.py` — `65300f7a94b9c043733ec4b609c64b0c8bf988a83a41c1142aec734235512265`
19. `tests/verify_eight_session_conformance.py` — `129476cb5664abdd119c164b5ace159f09e37f6598b3423cc4f4628a6b4b122c`
20. `tests/verify_exact_traceability_edge_cases.py` — `73c742377ed6480db9824b8029d06bb6d015aeeef96c28e4dc2176718874f97d`
21. `tests/verify_explicit_llm_retry_categories.py` — `67061e2dd2ad4cd786b707e6d79e9eca3308a61bd4f398187f6aad254ceebaa0`
22. `tests/verify_explicit_repair_retry_controls.py` — `5a552b4ea31c434985229d9268f531c1536eaf9efbd2a33de72da3bbdb8cda83`
23. `tests/verify_failure_diagnostics.py` — `77ac43f77b701e4e71b51a5f7432f2ef6eb6bafd1b42a2a1cec173fe123921c9`
24. `tests/verify_final_partial_items_closed.py` — `6039dec0a73451f2b3bca618b23bd7aed78a33414cd4237c9c49af824b713f25`
25. `tests/verify_gate_boolean_fail_closed.py` — `97f9bb98aae3629963de17959d4669d3e5fbfc0ae4317d156d682fc43273a32b`
26. `tests/verify_hash_bound_resume_semantics.py` — `bea431e7c124b6bde97d2ea351d32c4cb2d1c68d0fe7da6813aad01bc11118ad`
27. `tests/verify_live_child_process_streaming.py` — `fc00658c3bb398d0f791937e4262b6b21141aaea21ba1884063fdf5fb0464e9b`
28. `tests/verify_live_harness_hardening.py` — `56ac15e3506ce3fd40df00a36e5a4825463f3469d0fc648560c2a25200cef075`
29. `tests/verify_llm_failure_status_propagation.py` — `19d72eda22b8f671c2352cfd5c8193e32bef1e7f84c9f6950ff9048337c199a5`
30. `tests/verify_llm_incomplete_retry_budget.py` — `e2f215a103ad4a1dda2b46cd4a8fb96360efc4b77a4dc7d3619f5770a23f3173`
31. `tests/verify_maintainability_and_portability.py` — `c3848ddc035bb0df7c59c4605c0330ee958956283192dca0368dbb9d260cabc4`
32. `tests/verify_mandatory_a_to_z_repairs.py` — `71c06929b6edd7dc0857efe20d4a7bafe8a75d696f26a1c539c6fedd023829a4`
33. `tests/verify_mandatory_semantic_evidence_gates.py` — `311dd37837c65590592d24e1fb62083c6456edc34d501a605a52c77f474da834`
34. `tests/verify_mutable_bootstrap_and_residue_cleanup.py` — `65961a36714615d79f3395f7ce9bea5a0a838dc6cec5a097fd9979383564451b`
35. `tests/verify_mutable_package_structure.py` — `9a60b5d6cbcbe5d31c53ac77b3f28b958a173b74d51818be33623fa897e4dec9`
36. `tests/verify_mutable_workspace_contract.py` — `0e1d53340e1e23a3fc3e86f82b1d76cacec2943728857f21c1fa899cc517720c`
37. `tests/verify_offline_fake_llm_cbmc_e2e.py` — `28f5806d2a7aea4d8f419304d458acdf449401bbc305896397bc57364a6774e4`
38. `tests/verify_offline_open_discovery_fake_llm_cbmc_e2e.py` — `dee61317487345c9f8e60cd5d9adf1f86bbb3fbeaa456506b63ef787b92c79d8`
39. `tests/verify_old_state_plan_enum.py` — `89861374dee3f62a1135fa97e9e8221281c6f4859104788c47d5b5b766b32f16`
40. `tests/verify_open_discovery_agent5_reporting.py` — `77a7091ed7e919de4b7ed9e9df276398acbbf3e23858f68f82a5f45c24b4d6ff`
41. `tests/verify_open_discovery_mode.py` — `e02055b7cbb2b8f28ad8d1e6e2aa3dafacc239f1f3214ec9c3eacb5f5eb1e472`
42. `tests/verify_open_discovery_mutable_workspace_compatibility.py` — `d3f7f3eb273ab3b4f0ed105e4f5d60084df2b83db4f3475b60d4e49d732b4321`
43. `tests/verify_openai_structured_output_schema_preflight.py` — `2debfb6548b527364d2479f6139d5100dcb69114c5dabb5c73e9f1b829be3b37`
44. `tests/verify_pre_agent7_readiness_diagnosis.py` — `fe6fe920b375dba4c9ebc84b934a946527cfd44bb30750c6097ef0e2c6ca8d5a`
45. `tests/verify_preflight_iteration_policy.py` — `27b6a1990eea68bb72437c8b8b7e8e60de36ff5ee9ca868dfc473f7057ddf936`
46. `tests/verify_property_campaign_orchestration.py` — `b19c4b07ef541c665f8c44c6fdfa2156c125f6b578561fa3367e0fe3e1355aa6`
47. `tests/verify_real_cbmc_acceptance_entry_binding.py` — `8c62435681835672ee684723f61e0ac3c8333090edef19ebbaa4d19d051bf76e`
48. `tests/verify_real_cbmc_loop_clause_syntax.py` — `2656cf5e8d8162d2ab0b39eebf52bc4c39e3480e5bfc261013c1bd3f745e289a`
49. `tests/verify_regression_runner_process_cleanup.py` — `ef678d3bb4efacf60e9d22e763417b3288b145dfaaaaa6cbe28de6c3dc49afa3`
50. `tests/verify_retry_growth_user_control.py` — `2be8cffe366fa1b3c8465e500a0f698d86065a6a63ac6635a3dacf77ae6ee9c8`
51. `tests/verify_run002_exact_replay_and_clause_grammar.py` — `a4f4816c5937d67505c8f4de995fc3cab410f0cb2e61e41256a26ef9476e032e`
52. `tests/verify_strategy_neutrality_and_semantic_repair_guard.py` — `1487b80544c87762f7df7fd4df20f582d7c6f3c90b247b09df3beaf4f4ce9ea2`
53. `tests/verify_strategy_reconciliation_and_frontend_readiness.py` — `ef307240ad3023937504a0bd395ee2a455fc8691d54419f4df848a3f66a8c216`
54. `tests/verify_success_text_failure_hint_gating.py` — `9b51cf6391c85d6db1ec9cd3091095df1c0d903caf57528303c7b978599d79fd`
55. `tests/verify_user_override_command_provenance.py` — `c94021bc37a966fe505f6c318c9dcd37f0dec8c703a749dc8afa42ede4b71848`
56. `tests/verify_workflow_state_policy.py` — `5231d34d07d6db767d05903e8c6522c79e219f69183134d2525cb94490f8c642`

---

## 17. Source and release delta

### 17.1 Core integration files

I added or modified the following core paths:

```text
agents/common/llm_client.py
agents/common/codex_exec_backend.py
configs/CONFIG_TEMPLATE_CODEX_EXEC.json
docs/CODEX_EXEC_INTEGRATION_GUIDE.md
tests/verify_codex_exec_integration.py
```

I also added the final research report and release evidence under `docs/` and `release_evidence/codex_exec_integration/`.

### 17.2 Core file hashes

| Path | Bytes | SHA-256 |
|---|---:|---|
| `agents/common/llm_client.py` | 93,382 | `a04e5964be2901816159307642ee9409ec80b54d6637aa84a65572ff2b768f66` |
| `agents/common/codex_exec_backend.py` | 37,326 | `890da7b41fd01bfef8ab7d9e3c7066fdc87982d089f49f59207892d087bc0819` |
| `configs/CONFIG_TEMPLATE_CODEX_EXEC.json` | 4,587 | `a1ea2649b95294a2eff385735dd86f1ebaf0a868d7fae9edf8ac6708161e527f` |
| `docs/CODEX_EXEC_INTEGRATION_GUIDE.md` | 9,877 | `e4d3ac785f411b78a32ea96c5aefaadbc2b264f50c195e932e14c4b2606a759d` |
| `tests/verify_codex_exec_integration.py` | 9,061 | `50791f624ddbab2151a98516500a9a497c1c205b191ee201e55e8ef6442c3182` |

### 17.3 Logical delta principle

I did not modify production ML-KEM C source as part of the integration. I did not replace the orchestrator, tool-execution agent, experiment logger, property catalogue, frozen baseline runs, or original Responses API implementation. I modified the common client only to add configuration and dispatch, and I isolated Codex-specific behaviour in a separate backend module.

---

## 18. Claim-by-claim assessment

| Claim | Final assessment | Basis |
|---|---|---|
| A real Codex execution backend exists | VERIFIED | separate backend, dispatch, command and tests |
| The Responses API route is preserved | VERIFIED | default backend remains `responses_api`; regressions pass |
| Codex activity is visible in the terminal | VERIFIED IN SIMULATION | live prefixed stream test and repository streaming regression pass |
| Event, diagnostic, command, schema, final-message and boundary evidence is preserved | VERIFIED IN SIMULATION | dedicated evidence assertions pass |
| All prepared primary evidence reaches Codex | VERIFIED FOR SUPPORTED INPUT TYPES | text and base64 file paths are preserved and tested |
| Writable project locations are allowlisted | VERIFIED UNDER PROJECT-TREE THREAT MODEL | outside-mutable mutation fails and restores |
| Codex cannot alter control evidence unnoticed | VERIFIED UNDER TESTED PATHS | byte gate detects and restores schema tampering |
| Timeout descendants are terminated | VERIFIED ON POSIX TEST HOST | delayed-child test passes |
| Exact Codex binary provenance is recorded | VERIFIED | path, size, digest and exact semantic version recorded |
| High reasoning effort is forwarded | VERIFIED IN COMMAND CONSTRUCTION | command evidence contains pinned config value |
| Schema-valid Codex output automatically proves a property | REJECTED | output remains a candidate until CBMC and gates pass |
| The integration removed the historical Codex failure | NOT YET ESTABLISHED | no paired real Codex experiment completed |
| A real ML-KEM property was proved by this release | NOT CLAIMED | no fresh real Codex-to-CBMC host packet completed |
| The implementation is accepted for its declared offline integration scope | VERIFIED | dedicated gates and 56/56 regressions pass |
| The implementation is free from every possible defect | NOT CLAIMED | no finite test suite establishes universal absence of defects |

---

## 19. Scientific interpretation

### 19.1 What I have established

I have established that Codex CLI can be represented as a controlled backend within the pipeline’s existing execution abstraction. I have established that the integration can preserve the original workflow contract, carry complete prepared evidence, expose terminal activity, record exact runtime identity, enforce a project-tree write allowlist, restore unauthorised modifications, reject self-modified control evidence, and fail closed before an invalid result becomes authoritative.

I have also established compatibility with the repository’s discovered behavioural regression inventory. The result is stronger than a wrapper demonstration because the integration survives tests covering stage semantics, source and property binding, structured CBMC evidence, retry policy, workflow transitions, mutable-workspace rules, reporting language, and process cleanup.

### 19.2 What I have not established

I have not established that a live Codex model behaves identically to the deterministic fake executable. I have not established account authentication, model availability, service latency, token usage, network failure behaviour, or live event formats beyond the pinned CLI interface contract. I have not established that Codex generates a correct ML-KEM harness under this architecture. I have not established a new formal theorem.

I have not established that the architectural optimisation caused removal of the earlier failure. Causal language requires matched experimental conditions and repeated live runs. The current package is the instrument needed for that experiment; it is not the experimental result itself.

### 19.3 Defensible wording

I consider the following wording scientifically defensible after the package-level verification:

> I implemented a controlled Codex CLI backend within the existing deterministic LLM–CBMC pipeline. Under simulated Codex execution and the repository’s complete regression inventory, the backend preserved the workflow, enforced the declared project write boundary, retained complete primary evidence, produced terminal-visible and hash-bound execution records, and failed closed on process, schema, timeout, mutation, symlink, and control-evidence violations. A live paired Codex–CBMC experiment remains necessary before attributing removal of the historical failure to the architectural optimisation.

I do not consider “the optimisation magically fixed Codex” defensible. That sentence contains no controlled condition, no causal mechanism, no repeated measurement, and no formal acceptance record.

---

## 20. Controlled failure-versus-optimisation experiment

### 20.1 Experimental objective

I define the next experiment as a paired comparison between the historical failure condition and the final controlled integration.

### 20.2 Conditions

I require at least two conditions:

- **Condition A — historical integration:** the earlier Codex execution design and its recorded failure mechanism;
- **Condition B — controlled integration:** the final package documented here.

Where ethical and technically feasible, I also include:

- **Condition C — Responses API baseline:** the preserved API backend under the same prompt and evidence;
- **Condition D — human-prepared reference artefact:** a manually reviewed harness under the same deterministic gates.

### 20.3 Frozen variables

I freeze:

- exact workflow archive digest;
- exact ML-KEM repository commit;
- target function;
- parameter set;
- selected property and claim boundary;
- specification and implementation evidence hashes;
- prompt package hashes;
- model identifier;
- Codex binary path, version and SHA-256;
- reasoning effort;
- sandbox and approval policy;
- mutable roots;
- timeout and retry count;
- CBMC, `goto-cc`, and `goto-instrument` versions and hashes;
- compiler environment;
- deterministic gate versions;
- mutation operators;
- run repetition count.

### 20.4 Primary outcomes

I measure:

1. stage completion;
2. schema-valid authoritative candidate production;
3. boundary integrity;
4. deterministic semantic-gate acceptance;
5. successful CBMC invocation;
6. mapped selected-property outcome;
7. mutation sensitivity;
8. non-vacuity evidence;
9. repair count;
10. wall-clock duration;
11. terminal/event completeness;
12. reproducibility across repetitions.

### 20.5 Failure taxonomy

I classify failures before execution:

```text
F01 launch or authentication failure
F02 wrong model or version
F03 incomplete evidence transmission
F04 malformed structured output
F05 unauthorised filesystem change
F06 execution-control tampering
F07 timeout or descendant leak
F08 semantic scope failure
F09 harness build failure
F10 CBMC invocation failure
F11 selected property absent
F12 CBMC property failure
F13 vacuity or mutation-insensitive success
F14 unsupported claim inflation
F15 non-reproducible repeated result
```

### 20.6 Interpretation rule

I attribute improvement to the controlled integration only when Condition B shows a predefined improvement over Condition A under matched variables and the evidence identifies a mechanism consistent with the architectural change. A single successful output is descriptive evidence, not causal proof. Repeated success with stable hashes, preserved boundaries, equivalent prompts, and formal-tool acceptance supports a stronger conclusion.

---

## 21. Reproducibility procedure

### 21.1 Archive identity

I verify the distribution with the companion SHA-256 file before extraction.

```bash
sha256sum -c <final-package>.sha256
unzip -t <final-package>.zip
```

### 21.2 Clean environment

I use a new virtual environment and the package requirements:

```bash
python3 -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### 21.3 Tool identity

I record:

```bash
python --version
codex --version
codex exec --help
cbmc --version
goto-cc --version
goto-instrument --version
sha256sum "$(command -v codex)"
sha256sum "$(command -v cbmc)"
```

### 21.4 Local acceptance

I run:

```bash
./RUN_FINAL_ACCEPTANCE_UBUNTU.sh
python tests/verify_codex_exec_integration.py
```

I require every local gate to pass before a paid or live experiment.

### 21.5 Run configuration

I copy rather than edit the template in place:

```bash
cp configs/CONFIG_TEMPLATE_CODEX_EXEC.json configs/RUN_CODEX_001.json
```

I assign a new run identifier, concrete model, exact source revision, target function, property campaign, and host-verified CBMC settings. I retain `codex_enforce_change_boundary=true`, exact version matching, terminal streaming, strict configuration, and the minimal environment.

### 21.6 Execution

```bash
PYTHONUNBUFFERED=1 python -u agents/master_orchestrator.py \
  --config configs/RUN_CODEX_001.json \
  --strict-outputs \
  --stop-on-optional-failure
```

### 21.7 Evidence freeze

I freeze the completed run directory, resolved configuration, source manifest, Codex runtime provenance, command and event records, stage handoffs, CBMC JSON, mutation evidence, final report, and a recursive SHA-256 manifest. I do not rename a failed run as a successful run. I preserve failed attempts because they are part of the experiment.

---

## 22. Threats to validity

### 22.1 Simulated Codex execution

The fake Codex executable verifies adapter behaviour deterministically but does not reproduce a live model’s reasoning, command selection, event diversity, authentication, or service failures. I therefore restrict the acceptance claim to integration logic.

### 22.2 Operating-system scope

The strongest timeout and file-lock tests ran on a POSIX host. I implemented a Windows process-tree fallback but did not execute a Windows acceptance campaign. The deterministic project snapshot does not replace the operating-system sandbox for external filesystem or network containment.

### 22.3 File-system model

The snapshot and rollback logic is designed for regular files, directories, and symlinks in the workflow tree. Exotic filesystem objects, hostile concurrent processes outside the controlled lock, kernel-level interference, or storage failures are outside the tested model.

### 22.4 Dependency shim

The full regression run used an external test-only shim to satisfy the local fake-Responses-API test when the pinned OpenAI SDK was unavailable from the configured index. This limitation does not affect the dedicated Codex tests, but it prevents the regression result from serving as a real SDK compatibility certificate.

### 22.5 No fresh real formal experiment

The package-level test names include CBMC readiness and acceptance logic, but the final integration audit did not execute a new authenticated Codex-generated artefact through a fresh real CBMC 6.9.0 host campaign. I therefore make no new formal property claim.

### 22.6 Effective research dates

I use the requested 25 July 2026 dates as research-record dates and preserve actual machine timestamps separately. This distinction is necessary because retrospective reconstruction must not be presented as contemporaneous machine evidence.

---

## 23. Final acceptance decision

I accept the final package for the following bounded statement:

> The controlled Codex Exec backend is implemented, integrated with the preserved V4 workflow, fail-closed under the tested project-tree and control-evidence threat model, terminal-observable, provenance-recording, and compatible with the complete discovered repository regression inventory.

I reject the following broader statements because the available evidence does not establish them:

```text
A live Codex model has already completed the full ML-KEM experiment.
The architectural optimisation has already been proved to remove the historical failure.
The integration itself proves an ML-KEM property.
No defect can exist outside the tested threat model.
```

My final engineering classification is:

```text
CORE CODE INTEGRATION: ACCEPTED
OFFLINE SIMULATED-CODEX VALIDATION: ACCEPTED
REPOSITORY REGRESSION COMPATIBILITY: ACCEPTED (56/56)
PROJECT-TREE BOUNDARY AND ROLLBACK: ACCEPTED UNDER TESTED MODEL
LIVE AUTHENTICATED CODEX VALIDATION: PENDING HOST EXECUTION
LIVE CODEX-TO-CBMC RESEARCH RESULT: PENDING CONTROLLED EXPERIMENT
```

---

## 24. Conclusion

I completed the Codex integration as an architectural extension rather than a shortcut around the pipeline. The final backend lets Codex inspect and work inside the repository while the deterministic workflow retains control over evidence, writable scope, stage authority, and formal claims. I repaired every package-level defect identified in the first audit and added stronger controls where the final review exposed new paths.

The final release passes the dedicated adversarial suite and all 56 discovered repository regressions. It preserves the original Responses API route and end-to-end stage structure. It records exact Codex binary identity, model and reasoning configuration, prompt and evidence hashes, command arguments, event output, diagnostic output, final response, boundary changes, rollback, and control-evidence integrity. It rejects unauthorised changes and prevents a failed Codex attempt from entering the authoritative handoff.

The result is a valid research instrument for the next stage. The next stage is not another integration rewrite; it is a controlled host experiment. That experiment must compare the earlier failure and the final architecture under frozen conditions and must allow CBMC, mutation evidence, and reproducibility—not the appearance of the Codex answer—to decide the result.

---

# Appendices

## Appendix A — Dedicated Codex test cases

```text
T-CX-01 successful schema-valid handoff
T-CX-02 permitted mutable-root write
T-CX-03 exact binary digest and version provenance
T-CX-04 high reasoning-effort command mapping
T-CX-05 forbidden non-mutable modification detection
T-CX-06 forbidden modification rollback
T-CX-07 byte-exact binary evidence materialisation
T-CX-08 schema-invalid response rejection
T-CX-09 non-zero exit rejection
T-CX-10 timeout process-group termination
T-CX-11 delayed descendant mutation prevention
T-CX-12 output-schema tampering detection and restoration
T-CX-13 mutable-root symlink detection and cleanup
```

## Appendix B — Per-stage Codex evidence layout

```text
runs/<run-id>/stages/<stage>/llm_authoritative/codex_exec/
  output_schema.json
  input_materialization.json
  runtime_provenance.json
  execution_summary.json
  command.json
  events.jsonl
  stderr.log
  last_message.json
  change_boundary.json
  input_files/
  attempt_01/
    command.json
    events.jsonl
    stderr.log
    last_message.json
    change_boundary.json
```

The common stage validation remains under the stage validation directory as `llm_call_validation.json`.

## Appendix C — Acceptance formula

```text
accepted =
    exit_zero
    and not_timed_out
    and project_boundary_valid
    and mutable_symlink_policy_valid
    and control_evidence_unmodified
    and rollback_valid
    and control_restore_valid
    and output_size_valid
    and strict_json_valid
    and stage_schema_valid
```

## Appendix D — Final release evidence

```text
release_evidence/codex_exec_integration/
  FINAL_INTEGRATION_STATUS.json
  FULL_REGRESSION_RESULTS.json
  FULL_REGRESSION_CONSOLE.log
  verify_codex_exec_integration.log
  verify_maintainability_and_portability.log
  verify_mandatory_a_to_z_repairs.log
  verify_mutable_package_structure.log
  SOURCE_DELTA_MANIFEST.json
  CORE_FILE_HASHES.sha256
  TEST_ENVIRONMENT_DISCLOSURE.md
```

## Appendix E — Research-record dating statement

I use 25 July 2026 as the effective research-record date for the reference, integration archive, verification audit, and document. I preserve machine-generated timestamps in the evidence files and do not rewrite those timestamps. This separation allows thesis chronology to remain organised without converting retrospective digital evidence into falsely contemporaneous evidence.

## Appendix F — Primary interface references

1. OpenAI Codex repository, CLI argument definition for tag `rust-v0.144.4`: `codex-rs/exec/src/cli.rs`.
2. OpenAI Codex repository, configuration schema for tag `rust-v0.144.4`: `codex-rs/core/config.schema.json`.
3. Package-local canonical experiment protocol and behavioural tests under `configs/`, `agents/common/`, and `tests/`.

The pinned source references are used to verify command and configuration compatibility. The package-local tests remain the evidence for integration behaviour.
