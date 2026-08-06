# Option and security policy

The wrapper receives options as a JSON string array and invokes CBMC with `shell=False`.

It rejects:

- shell/control syntax, redirection, command substitution, pipes, and newlines;
- argument-file tokens beginning with `@`;
- caller-supplied `--json-ui`, XML UI modes, interfaces, `--show-properties`, version, or help modes;
- uncontrolled output options such as `--outfile` and exported GOTO/model files;
- arbitrary coverage destinations;
- source/input paths containing `..`, absolute request paths, symlinks, or paths outside the workspace;
- output directories inside the workspace or existing output directories;
- executable names other than `cbmc` and symlinked executables;
- secret-like environment variable names.

The only permitted tool-created artifact path in RC1 is:

```text
--symex-coverage-report {artifact_dir}/coverage.xml
```

Only files declared under `tracked_inputs` receive before/after SHA-256 protection. Include all harnesses, production sources, headers, generated includes, contracts, and build inputs that must be bound to the run.
