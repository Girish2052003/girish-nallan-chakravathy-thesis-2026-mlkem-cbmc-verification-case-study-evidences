# Central LLM Profile Guide

## One-place control file

All real API experiment configurations now reference:

```text
configs/llm_profiles/active_thesis_model.json
```

Change the model and model-level controls in this file only. Every LLM-backed
agent and the live preflight receive the resolved profile through the common
configuration contract.

The API key is **not** stored in this file. The profile records only the name of
the environment variable:

```json
"api_key_env": "OPENAI_API_KEY"
```

## Current quality-first profile

```json
{
  "profile_schema_version": "thesis_llm_profile.v1",
  "provider": "openai",
  "mode": "real",
  "model": "gpt-5.4-mini",
  "api_key_env": "OPENAI_API_KEY",
  "reasoning": {
    "effort": "xhigh"
  },
  "text": {
    "verbosity": "high"
  },
  "max_output_tokens": 32000,
  "preflight_max_output_tokens": 256,
  "store": false,
  "max_retries": 2,
  "retry_sleep_seconds": 2.0
}
```

`reasoning.mode` is intentionally omitted for GPT-5.4 mini. A future model that
supports an explicit mode can add it in the same profile:

```json
"reasoning": {
  "mode": "standard",
  "effort": "high"
}
```

The pipeline passes safe, non-empty future effort strings through to the API.
The live preflight is the authority for whether a selected model accepts the
chosen model/control combination. An unsupported combination fails before the
full thesis workflow is started.

## Experiment files

Real-run configs contain:

```json
"llm_profile": "configs/llm_profiles/active_thesis_model.json"
```

They may also contain `llm_overrides`, but only for approved run-specific
operational settings such as evidence inlining limits. Model, reasoning,
verbosity, storage, endpoint routing, and output-token budget cannot be
overridden there. This prevents different agents or experiments from silently
using different model settings.

Example preserving the larger evidence limit in run 002:

```json
"llm_overrides": {
  "max_retries": 2,
  "max_inline_file_chars": 200000,
  "attach_files_as_base64": false
}
```

## Per-run reproducibility

At run setup, the orchestrator:

1. copies the source profile into the Stage 1 input snapshot;
2. writes `llm_profile.resolved.json` in the run folder;
3. embeds the resolved settings and SHA-256 metadata in
   `run_config.resolved.json`; and
4. marks the resolved profile as frozen.

Agents loading a frozen run config do not re-read the mutable global profile.
Therefore, changing the central profile affects new runs only and cannot alter
an experiment already in progress or being resumed.

## Safe future model switch

Edit only:

```bash
nano configs/llm_profiles/active_thesis_model.json
```

For example:

```json
"model": "gpt-5.6",
"reasoning": {
  "mode": "standard",
  "effort": "high"
}
```

Then validate locally without an API call:

```bash
python tests/verify_central_llm_profile.py
```

Run the controlled live preflight before any full experiment:

```bash
python preflight_first_api.py \
  --config configs/poly_add_api_run_001.json \
  --report preflight_reports/poly_add_api_run_001.json
```

Do not launch the orchestrator unless the preflight approves the exact selected
profile and experiment configuration.

## Package-manifest policy

The shared active profile and named experiment configurations are deliberately
mutable scientific inputs, so they are not pinned in `PACKAGE_MANIFEST.sha256`.
The immutable profile template, resolver, request-building code, regression
tests, and this guide are pinned by the package manifest. Every actual run still
records the exact active profile bytes, resolved settings, and SHA-256 values in
its own run directory before any LLM-backed stage executes.
