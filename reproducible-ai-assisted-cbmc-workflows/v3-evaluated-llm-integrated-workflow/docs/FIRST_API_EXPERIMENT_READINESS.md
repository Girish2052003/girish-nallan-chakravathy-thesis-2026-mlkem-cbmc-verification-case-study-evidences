# First API Experiment Readiness Checklist

The first full experiment is authorized only after all mandatory items pass for the exact reviewed configuration.

## A. Local package gate

- [ ] Package SHA-256 manifest reports `OK` for every file.
- [ ] `./bootstrap_ubuntu.sh` completes successfully.
- [ ] `./verify_release.sh` ends with `FINAL DEPLOYMENT VERIFICATION PASSED`.
- [ ] Installation is in `~/thesis-agent-workflow-refactored-test`, not directly over the live project.
- [ ] The previous live project has been backed up.

## B. Exact experiment inputs

- [ ] A unique `run_id` is used.
- [ ] `project_root` and `output_root` are correct.
- [ ] The FIPS/controlled specification files are the intended files.
- [ ] The implementation `.c`, `.h`, and `.inc` files are the intended files.
- [ ] `tool_execution.source_files` lists all required C translation units.
- [ ] `include_paths`, defines, stubs, working directory, unwind, and extra CBMC arguments are explicit.
- [ ] The configured Git repository path exists.
- [ ] `provenance.source_revision` exactly matches repository `HEAD`.
- [ ] Any uncommitted repository changes are understood and recorded.

## C. Trust and cost controls

- [ ] `llm.mode` is `real`.
- [ ] The configured model is intentionally selected and available to the university project.
- [ ] The API key exists only in the environment variable.
- [ ] `max_iterations` is `0` for the first run.
- [ ] `tool_execution.dry_run` is `false`.
- [ ] `tool_execution.force_run` is `false`.
- [ ] `tool_execution.require_gate_approval` is `true`.
- [ ] No proof harness or human-corrected harness is accidentally included in raw implementation inputs.
- [ ] Comparison/prohibited-copy directories contain only artefacts intended for similarity screening.

## D. Mandatory live operational preflight

Run:

```bash
source .venv/bin/activate
export OPENAI_API_KEY='YOUR_REAL_KEY'
python preflight_first_api.py \
  --config configs/YOUR_FIRST_API_PREFLIGHT.json \
  --report preflight_reports/YOUR_FIRST_API_PREFLIGHT.json
```

The preflight must report all of the following:

- [ ] configuration contract passed;
- [ ] input/formal-build paths passed;
- [ ] Git revision provenance passed;
- [ ] one tiny live Responses API request succeeded for the configured model;
- [ ] one tiny real CBMC assertion check reported `VERIFICATION SUCCESSFUL`;
- [ ] run-ID uniqueness and cost controls passed;
- [ ] `approved_for_one_controlled_first_experiment` is `true` in the JSON report.

The live API probe contains no thesis source/specification evidence. It only checks connectivity and configured-model access. It has a small API cost.

## E. Human review immediately before the orchestrator

- [ ] Read the normalized config one final time.
- [ ] Confirm the chosen target function and property scope.
- [ ] Confirm that no secret appears in config/source files.
- [ ] Confirm the run directory does not already exist.
- [ ] Preserve the successful preflight JSON report.

## Authorization rule

Only after Sections A–E pass should the first full command be run:

```bash
python agents/master_orchestrator.py \
  --config configs/YOUR_FIRST_API_PREFLIGHT.json
```

A passing preflight authorizes one controlled run for that exact configuration. Changing the model, code revision, inputs, target, formal-build settings, or run configuration requires a new preflight.
