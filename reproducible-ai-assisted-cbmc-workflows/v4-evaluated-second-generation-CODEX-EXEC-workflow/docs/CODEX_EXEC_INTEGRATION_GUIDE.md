# Controlled Codex Exec Backend

## 1. Architectural position

The workflow orchestrator remains the control plane. `codex_exec` is an alternative execution backend for the existing LLM-authored stages; it does not replace stage ordering, immutable prompt packages, handoff manifests, deterministic semantic gates, CBMC execution, experiment logging, or claim-boundary enforcement.

The original OpenAI Responses API path remains available through:

```json
"execution_backend": "responses_api"
```

The controlled Codex path is selected through:

```json
"execution_backend": "codex_exec"
```

## 2. Preserved Codex capability

The backend launches the installed Codex CLI in non-interactive execution mode. Codex receives the complete stage prompt, materialised primary-evidence files, the selected repository working directory, a writable sandbox, the selected model, and the stage-specific JSON schema. It may inspect the repository, execute commands, reason across files, and create artifacts inside the declared mutable paths.

The architecture limits authority rather than capability. A Codex response becomes an authoritative candidate only after process success, timeout checks, workspace-boundary checks, execution-control integrity checks, output-size checks, JSON parsing, and JSON-schema validation all pass.

## 3. Command construction

The pinned template expects Codex CLI `0.144.4`. The emitted command has this controlled form:

```text
codex exec
  --json
  --color never
  --strict-config
  --ephemeral
  --sandbox workspace-write
  --cd <workflow-root>
  --output-schema <stage-schema.json>
  --output-last-message <attempt-last-message.json>
  --model <configured-model>
  --skip-git-repo-check
  --ignore-user-config
  --config approval_policy="never"
  --config model_reasoning_effort="high"
  -
```

Optional `--ignore-rules` and controlled `--add-dir` arguments are emitted only when explicitly configured. Every `--add-dir` must resolve inside a declared mutable root. A concrete model identifier is mandatory; unresolved template placeholders fail before launch.

## 4. Terminal observability

Codex standard output and standard error are streamed live with a stage prefix:

```text
[CODEX:02_spec_extraction] ...
```

The parent process captures both streams in temporary parent-controlled files and copies them into the stage evidence directory after process termination. This design prevents the child process from silently replacing the preserved stream logs while retaining live terminal visibility.

Each attempt records:

- `command.json`: exact argument vector, working directory, model, reasoning controls, prompt hash, sandbox, environment-variable names, boundary roots, and lock metadata;
- `events.jsonl`: Codex JSONL standard-output event stream;
- `stderr.log`: complete Codex diagnostic stream;
- `last_message.json`: final Codex message written through `--output-last-message`;
- `change_boundary.json`: before/after workspace decision, forbidden symlink decision, control-evidence integrity decision, and rollback result.

Each stage also records:

- `output_schema.json`;
- `input_materialization.json`;
- `runtime_provenance.json`;
- `execution_summary.json`;
- `llm_call_validation.json`.

## 5. Primary-evidence preservation

The existing LLM client may transmit evidence as inline text or as base64 file attachments. The Codex backend consumes the exact prepared API-input structure rather than a text-only approximation.

Every `input_file` data URI is decoded byte-for-byte into the stage evidence directory. The prompt identifies the materialised path, byte length, MIME type, and SHA-256 digest. The input manifest records the same values. Binary evidence is therefore not silently omitted from the Codex path.

## 6. Deterministic write boundary

The default mutable roots are:

```text
runs/
reports/
workspace/
artifacts/
```

All project paths outside those roots are treated as immutable during a Codex attempt. The backend snapshots regular files, directories, modes, and symlinks outside the mutable roots. Any addition, deletion, content modification, type change, mode change, or symlink change outside the allowlist fails the attempt.

Before execution, the backend creates a private backup of the guarded tree. When an unauthorised change is detected, the backend removes the changed entry, restores the original entry, re-snapshots the guarded tree, and records whether rollback was complete. A security failure stops retries.

Symlinks are forbidden inside mutable roots. Existing mutable-root symlinks block launch. Symlinks created during an attempt fail the attempt and are removed. This prevents a mutable path from being used as an unrecorded indirection into another project path. External filesystem containment still relies on the Codex `workspace-write` sandbox and the operating system; the deterministic snapshot governs the workflow project tree.

## 7. Execution-control integrity

The schema, runtime-provenance record, input manifest, and every materialised primary-evidence file are captured as trusted byte sequences before launch. After Codex exits, the backend compares those files byte-for-byte. Any attempted alteration fails the stage and the original bytes are restored before validation evidence is finalised.

The command record is rewritten from parent-held data after process termination. Standard-output and standard-error evidence is also parent-controlled. The final-message file remains Codex-authored by design and is accepted only after all other gates and schema validation pass.

## 8. Process lifecycle and retries

On POSIX systems, Codex starts in a new process session. A timeout terminates the entire process group with `SIGTERM`, followed by `SIGKILL` when the configured grace period expires. The Windows path uses `taskkill /T /F` with a direct-kill fallback.

The backend serialises Codex attempts through an in-process lock and a POSIX file lock stored in a mutable root. This prevents concurrent attempts from invalidating the same project snapshot.

`max_retries` controls complete Codex process retries. Schema errors and ordinary non-zero return codes may be retried. Security failures do not retry. Every attempt receives a separate evidence directory.

## 9. Provenance controls

Before each stage, the backend resolves the actual Codex executable and records:

- canonical binary path;
- byte size;
- SHA-256 digest;
- exact `codex --version` command;
- return code and output;
- detected semantic version;
- expected semantic version and exact match result;
- Python version, platform, and operating-system family.

When `codex_require_version_match` is enabled, a version mismatch fails before Codex execution. The child process receives a minimal allowlisted environment by default. Credential values are never written to command evidence; only environment-variable names are recorded.

## 10. Formal-verification authority

Codex may propose a harness, property, repair, explanation, or verification plan. Codex does not establish the truth of a formal claim. The deterministic semantic gates must accept the artifact, the tool-execution stage must run CBMC, the selected property must map to emitted structured tool evidence, and mutation/non-vacuity requirements must be satisfied before the evaluation layer may describe a property as verified.

## 11. Configuration procedure

```bash
cp configs/CONFIG_TEMPLATE_CODEX_EXEC.json configs/RUN_CODEX_001.json
```

The copied configuration requires at least:

1. a new `run_id`;
2. a concrete Codex model available to the authenticated account;
3. an exact source revision;
4. the intended target function and property campaign;
5. a review of mutable and protected paths;
6. `tool_execution.dry_run=false` only when the real CBMC host gate has passed.

Authentication and environment checks:

```bash
codex login
codex --version
codex exec --help
./RUN_FINAL_ACCEPTANCE_UBUNTU.sh
```

Execution:

```bash
PYTHONUNBUFFERED=1 python -u agents/master_orchestrator.py \
  --config configs/RUN_CODEX_001.json \
  --strict-outputs \
  --stop-on-optional-failure
```

Credentials must remain in the environment or the Codex authentication store and must not be written into run JSON.

## 12. Verification status and limitation

The backend has passed the dedicated simulated-Codex adversarial suite and the complete discovered repository regression inventory. The simulation covers successful structured handoff, allowed writes, forbidden writes and rollback, binary evidence materialisation, schema failure, non-zero exit, timeout descendant termination, execution-control tampering, forbidden mutable symlinks, exact version provenance, and reasoning-effort forwarding.

A real authenticated Codex service run was not performed in the build environment. Consequently, the release verifies the integration logic and fail-closed controls but does not claim live model availability, account authentication, live service behaviour, or an end-to-end real Codex-to-CBMC research result. Those claims require a separately frozen host execution packet.

## 13. Failure-versus-optimisation experiment

A later successful run must not be described as proof that an optimisation removed an earlier Codex flaw unless the comparison freezes the source snapshot, target function, property, deterministic baseline, Codex binary hash and version, model identifier, reasoning effort, prompt hashes, configuration, event traces, file-change evidence, schema decisions, CBMC outputs, and mutation/non-vacuity results.

The defensible experimental claim is conditional: under matched inputs and recorded execution conditions, the controlled integration either did or did not eliminate the previously observed failure mode. The evidence packet, rather than the apparent quality of a generated answer, determines that conclusion.
