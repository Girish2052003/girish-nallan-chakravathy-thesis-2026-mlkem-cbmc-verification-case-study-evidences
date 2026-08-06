# Evidence execution boundary

The package-generation environment did not contain `cbmc`, `goto-cc`, or `goto-instrument`. Therefore no fabricated GOTO binary, solver transcript, property count, or `VERIFICATION SUCCESSFUL` line is included.

`runner/run_skill_assisted_campaign.sh` is the authoritative one-run collector for Girish's Ubuntu VM with CBMC 6.9.0. It creates the raw evidence and computes the final acceptance matrix from actual exit codes and coverage output.
