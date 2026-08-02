# Final Trust-Chain Pipeline Release — 2026-07-15

## Release status

- **Implementation promises:** 38/38 complete.
- **Clean local regression suite:** 53/53 passed.
- **Run 001:** 246 files byte-identical to the uploaded baseline.
- **Run 002:** 192 files byte-identical to the uploaded baseline.
- **Real CBMC 6.9.0 host gate:** mandatory before starting new experiments; it could not run in the builder container because the three CBMC binaries were absent.

The pipeline preserves the trust boundary: the LLM proposes a complete candidate, deterministic checks establish identity and tool readiness, and CBMC decides verification outcomes. User force/manual execution controls remain available and are explicitly recorded.

## CBMC entry-binding hotfix

The first Ubuntu host run passed all ordinary regressions but exposed a defect in the synthetic real-CBMC acceptance fixture: its proof harnesses had no `main`, and `goto-cc` had not been given the intended entry function. This package binds `harness`, `loop_harness`, `hybrid_harness`, or `f` explicitly with `--function` before transformation. See `release_evidence/CBMC_ENTRY_BINDING_HOTFIX.md`.

## One-time Ubuntu setup

```bash
cd "$HOME/THESIS-2026"
unzip "$HOME/Downloads/thesis-pipeline.zip"
python3 -m venv venv
source venv/bin/activate
cd thesis-pipeline

python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Ensure these commands resolve to CBMC 6.9.0:

```bash
goto-cc --version
goto-instrument --version
cbmc --version
```

## Mandatory final host acceptance

Run exactly:

```bash
./RUN_FINAL_ACCEPTANCE_UBUNTU.sh
```

Do not start a paid/API experiment unless the final line is:

```text
FINAL TRUST-CHAIN ACCEPTANCE: PASS
```

This command runs all 53 local regressions again and then performs real CBMC 6.9.0 grammar, function-contract, loop-contract, hybrid-transformation, malformed-input, and exact property-listing acceptance.

## Start a new experiment

Create a new config from the relevant template and give it a **new run_id**. Never reuse or edit the frozen Run 001 or Run 002 directories.

For live console output:

```bash
source "$HOME/THESIS-2026/venv/bin/activate"
cd "$HOME/THESIS-2026/thesis-pipeline"
PYTHONUNBUFFERED=1 python -u agents/master_orchestrator.py \
  --config configs/YOUR_NEW_CONFIG.json \
  --strict-outputs \
  --stop-on-optional-failure
```

The orchestrator now streams child output directly, so a separate watcher is optional. `./watch_run.sh` remains available.

## Evidence

See `release_evidence/` for:

- the 38-requirement compliance matrix;
- the preserved 51-test evidence plus the final 52-test hotfix result and logs;
- frozen Run 001/Run 002 checksum comparisons;
- the real-CBMC host-gate status;
- the final release status.
