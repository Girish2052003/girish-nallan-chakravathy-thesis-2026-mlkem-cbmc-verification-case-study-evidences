# Evidence Index

## Core control and defect packets

### Direct-body T1 semantic control

`03_FROZEN_CORE_EVIDENCE/FROMSGT1_AUTHORITATIVE_FINAL_20260724T160742Z.tar.gz`

SHA-256:

`b656a34aa124ee183bf36cea8d4543d35888ae8436ba8efe94f64cdd4e83b404`

Contains the model-construction evidence, exact unwind calibration, authoritative repeated proof runs, reachability witnesses, mutation controls, commands, XML results and manifest.

### Official CBMC release comparison

`03_FROZEN_CORE_EVIDENCE/FROMMSG00D2_CROSS_VERSION_FINAL_20260724T171137Z.tar.gz`

SHA-256:

`32bbd306cb3bd3e9cc65ede8b01f16da87950dde747f0601bd414c837a046c71`

Contains the minimal canonical and malformed programs, official CBMC 6.9.0/6.10.0 Docker executions, symbol tables, exact commands, outputs, image identities and binary bindings.

### Prior develop-build audit packet

`03_FROZEN_CORE_EVIDENCE/FROMMSG00D2R1_FINAL_20260724T172546Z.tar.gz`

SHA-256:

`619d7715ed4429e106e447ee935195ad3eef852c195ccadc54a46c7f22c38784`

Preserves the prior failed build attempt and confirms why no pinned-`develop` result is claimed from that run.

## Native proof-stack investigation

- `04_NATIVE_WORKFLOW_EVIDENCE/FROMMSG00A5_LITANI_JOB_RECOVERY_20260724T135834Z.txt`
- `04_NATIVE_WORKFLOW_EVIDENCE/FROMMSG00A7_COUNTEREXAMPLE_GATE_20260724T150030Z.tar.gz`

These preserve the native workflow failure/recovery and inadmissible quantified-counterexample investigation. They are supporting context, not the minimal defect claim itself.

## Selected raw campaign logs

The raw logs under `05_SELECTED_RAW_LOGS/` preserve the native-result triage, root-cause extraction, selected solver/property bisection, direct-model construction and canonical-versus-redeclared isolation outputs.

## Reproducibility scripts

The scripts under `06_REPRODUCIBILITY_SCRIPTS/` preserve all three final develop-build campaign revisions, including failed build designs and the corrected writable-copy approach. They are included for audit transparency, not as proof that a final pinned-`develop` execution succeeded.
