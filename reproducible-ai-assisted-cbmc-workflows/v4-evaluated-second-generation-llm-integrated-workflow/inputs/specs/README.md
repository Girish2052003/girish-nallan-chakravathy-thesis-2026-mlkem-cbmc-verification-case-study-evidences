# Specification inputs

Included:
- `fips203.pdf` — original archival specification source.
- `fips203_clean.txt` — full clean text conversion already usable by the LLM.

You may freely create and edit `fips203_llm_ready.md`, then reference it in `inputs.spec_paths`. UTF-8 Markdown is supported; no pipeline-code patch is required.

All shipped configs allow up to 250,000 characters per primary evidence file and still fail closed rather than silently truncating evidence.
