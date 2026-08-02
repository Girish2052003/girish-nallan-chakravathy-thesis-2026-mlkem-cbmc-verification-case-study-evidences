# Central LLM Profile Guide

## One place for model control

Real experiment configurations reference:

```text
configs/llm_profiles/active_thesis_model.json
```

The API key is never stored in the profile. The profile stores only the environment-variable name, normally `OPENAI_API_KEY`.

The controlled main profile currently uses:

```json
{
  "provider": "openai",
  "mode": "real",
  "model": "gpt-5.4-mini",
  "reasoning": {"effort": "none"},
  "text": {"verbosity": "medium"},
  "max_output_tokens": 16000,
  "preflight_max_output_tokens": 256,
  "store": false,
  "max_retries": 1
}
```

Run-specific `llm_overrides` may adjust approved evidence-transport limits, but cannot silently replace the model, reasoning, verbosity, storage, or endpoint controls.

## Frozen per-run profile

At run setup, the orchestrator copies the profile into Stage 1, writes `llm_profile.resolved.json`, records its SHA-256, and freezes the resolved values. A resumed run does not reread the mutable global profile.

## Safe model-change procedure

1. Edit the profile only before a new experiment.
2. Validate the central profile behaviour:

```bash
python tests/verify_central_llm_profile.py
```

3. Run the zero-cost local preflight on the ordinary editable experiment config:

```bash
python preflight_first_api.py \
  --config configs/CONFIG_TEMPLATE_FIRST_API_PREFLIGHT.json \
  --local-only \
  --normalized-config configs/first_api.normalized.json \
  --report reports/first_api.preflight.json
```

`--normalized-config` is optional. It writes a normalized copy and adds no authorization or binding. Local-only mode constructs no provider client and makes no API request.

4. Review the local report, including input completeness, prompt-size estimate, model settings, source revision, CBMC availability, and run-directory checks.

5. Only when a paid provider-access check is deliberately required, run:

```bash
python preflight_first_api.py \
  --config configs/CONFIG_TEMPLATE_FIRST_API_PREFLIGHT.json \
  --live-api-probe \
  --acknowledge-paid-probe \
  --normalized-config configs/first_api.normalized.json \
  --report reports/first_api.live-probe.json
```

The live probe may incur API cost. It is optional and must never be confused with zero-cost local preflight.

6. Launch either the original ordinary config or the reviewed normalized copy:

```bash
python agents/master_orchestrator.py \
  --config configs/first_api.normalized.json \
  --strict-outputs
```

Results are written to `runs/<run_id>/` inside this mutable workspace. Use a new `run_id` for every official experiment, and do not edit the profile or experiment inputs while a run is active.
