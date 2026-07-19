# Reproducibility

Frozen commands and evidence are retained within the case directories:

- VC-SR1 solver command:
  `03_vc_sr1_reachable_only/build/vc_sr1_solver_command.txt`
- VC-SR1 unwind plan:
  `03_vc_sr1_reachable_only/properties/vc_sr1_unwind_plan.tsv`
- M4 solver command:
  `04_mutation_reduce/build/m4_solver_command.txt`
- M5 solver command:
  `05_mutation_assertion/build/m5_solver_command.txt`
- Frozen source manifest:
  `00_campaign_metadata/frozen_tracked_entries.sha256.tsv`

Each accepted case contains hashes, raw JSON results, resource records,
classification records and a case-level manifest.
