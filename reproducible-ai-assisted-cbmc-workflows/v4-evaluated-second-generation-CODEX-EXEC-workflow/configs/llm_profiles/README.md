# LLM profiles

- `active_thesis_model.json` is the single mutable model/control profile used by
  real API experiment configurations.
- `PROFILE_TEMPLATE.json` is the release baseline example.

The active profile is intentionally treated as an experiment input rather than
immutable program code. Each run snapshots it, records its SHA-256, and freezes
the resolved settings in `run_config.resolved.json`.

Never put an API key in either file. Use only the `api_key_env` field.
