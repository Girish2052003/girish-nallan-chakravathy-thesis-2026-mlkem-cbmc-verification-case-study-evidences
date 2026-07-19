# SUB-00F Mode-A Harness and Execution-Manifest Freeze

## 1. Frozen identity

- Repository commit:
  `d9613cf60de3132d32475c102d8c2781d84feb34`
- Parameter set:
  `MLK_CONFIG_PARAMETER_SET=768`
- Namespace embedded in the validated GOTO models:
  `mlk_sub00e_r1`
- Portable-C configuration:
  `MLK_CONFIG_NO_ASM=1`
- Integration hook:
  `MLK_CONFIG_CUSTOM_ZEROIZE=1`
- CBMC/goto-cc/goto-instrument:
  `6.9.0`
- Machine:
  x86_64 Linux, 8-bit byte, 16-bit short/int16_t, 32-bit int/int32_t,
  64-bit pointer, arithmetic signed right shift as asserted by each
  positive theorem harness.

## 2. Freeze status

This package freezes the independently authored Mode-A ML-KEM-768
artefacts and exact execution commands.

At package creation time:

- no CBMC theorem command has been executed;
- no coverage command has been executed;
- no production source has been modified;
- no theorem harness has been modified;
- no target function contract is used as an abstraction;
- no source loop contract is applied;
- production `mlk_poly_sub` and `mlk_poly_reduce` bodies remain present;
- the repository's existing dedicated `poly_sub_harness.c` remains unopened.

The validated original GOTO binaries are the authoritative execution
inputs. The reachable-only binaries created in SUB-00E-R2 were used only
to determine reachable loop identifiers and are not used as proof inputs.

## 3. Frozen theorem candidates

### SUB-T1 semantic theorem candidate

For arbitrary int16 coefficient arrays A and B satisfying only direct
subtraction representability, production `poly_sub` followed by
production `poly_reduce` must produce the canonical coefficient in
`[0,3329)` equal to the independently computed shifted unsigned
modular oracle.

### SUB-T2 relational theorem candidate

The frozen relational claim is:

`N(A-B) = N(N(A)-N(B))`

where all operations on both paths use retained production bodies and
the initial direct subtraction is representable in int16_t.

These descriptions remain theorem candidates until their exact frozen
CBMC commands complete successfully and their outputs are reviewed.

## 4. Fixed safety and model-checking options

Every verification runner freezes:

```
--function main
--object-bits 8
--bounds-check
--pointer-check
--pointer-overflow-check
--pointer-primitive-check
--signed-overflow-check
--unsigned-overflow-check
--conversion-check
--undefined-shift-check
--div-by-zero-check
--unwinding-assertions
--slice-formula
--sat-solver minisat2
--trace
--json-ui
```

Coverage additionally freezes:

```
--cover cover
```

Each command is limited by the external wrapper to 21,600 seconds,
with a 60-second termination grace period. GNU `time -v` records
resource use. The raw CBMC exit code, JSON output, stderr, command,
environment and hashes are retained.

## 5. Unwinding policy

Loops over all 256 coefficients are frozen at 257 unwindings, including
the terminating condition. Debug-bound loops over a one-element scalar
are frozen at 2 unwindings.

Every reachable loop identifier found in SUB-00E-R2 is explicitly
listed in the corresponding runner's `--unwindset`. Unwinding
assertions remain enabled; therefore, an insufficient bound is a
verification failure rather than a silent truncation.

Exact frozen unwindsets:

- SUB-T1:
  `main.0:257,main.1:257,main.2:257,main.3:257,mlk_barrett_reduce.0:2,mlk_sub00e_r1_poly_sub.0:257,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2`
- SUB-T2:
  `main.0:257,main.1:257,main.2:257,main.3:257,main.4:257,main.5:257,main.6:257,main.7:257,mlk_barrett_reduce.0:2,mlk_sub00e_r1_poly_sub.0:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257`
- Coverage:
  `main.0:257,main.1:257,mlk_sub00e_r1_poly_sub.0:257,mlk_barrett_reduce.0:2,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2`
- Valid boundary:
  `main.0:257,main.1:257,main.2:257,mlk_barrett_reduce.0:2,mlk_poly_reduce_c.0:257,mlk_poly_reduce_c.1:257,mlk_scalar_signed_to_unsigned_q.0:2,mlk_scalar_signed_to_unsigned_q.1:2,mlk_sub00e_r1_poly_sub.0:257`
- Invalid lower and upper controls:
  `main.0:257,mlk_sub00e_r1_poly_sub.0:257`

## 6. Frozen run order and expected classification

1. `run_01_sub_t1_mode_a_mlkem768.sh`
   - Positive theorem candidate.
   - Success is not assumed.
2. `run_02_sub_t2_mode_a_mlkem768.sh`
   - Positive relational theorem candidate.
   - Must not compensate for a failed SUB-T1.
3. `run_03_sub_boundary_valid_mode_a_mlkem768.sh`
   - Positive deterministic boundary control.
4. `run_04_sub_coverage_mode_a_mlkem768.sh`
   - Every frozen cover goal must be reviewed individually.
5. `run_05_sub_invalid_lower_mode_a_mlkem768.sh`
   - Negative control; intended failure must be confirmed from the
     actual property identifier and trace.
6. `run_06_sub_invalid_upper_mode_a_mlkem768.sh`
   - Negative control; intended failure must be confirmed from the
     actual property identifier and trace.

Only the first script is authorized immediately after acceptance of this
freeze. Later scripts require review of the preceding evidence.

## 7. Fail-closed zeroization adapter

The adapter is not a zeroization proof or a production implementation.
It contains a deliberately false assertion. SUB-00E-R2 established that
`mlk_zeroize` is not reachable from any selected harness. Any later
unexpected reachable call therefore fails closed.

## 8. Novelty and provenance boundary

The safe current language is:

> independently derived relational theorem candidate and independently
> authored CBMC artefact candidate.

No world-first claim is made. CBMC success cannot establish novelty.
Equivalent repository, public-code and literature artefacts must be
audited after this execution-manifest freeze. The prior accidental
Makefile exposure remains disclosed. The existing repository harness was
not used to author or repair these frozen artefacts.

## 9. Deferred work

The following are deliberately outside this freeze:

- Mode-B loop-contract-assisted evidence;
- ML-KEM-512 and ML-KEM-1024 configuration replications;
- mutation experiments;
- repository/public-code/literature novelty audit;
- any theorem repair prompted by actual counterexamples.

Any later correction must receive a new version, preserve this package,
and state exactly why it was introduced.

## 10. Parent evidence hashes

- SUB-00C architecture:
  `a1d11264cf27038fed35ccddced2c6f79c5e28f42382e5000ce7fe7a44689d84`
- SUB-00D build context:
  `9714f50795c722290060868e6b786b30ad7b1b13b267ee82f6c2dd1e3dd109c2`
- SUB-00E-R1 inspection packet:
  `becc00cb6280f405548cc535f38875bb3e476901cbb11392fc2ed38b8b3262d5`
- SUB-00E-R1 artifact manifest:
  `cf0baf1e79da927fd055019eecd0d2d7cd6d084a5f8d7c957ac8b5691b66e5e9`
- SUB-00E-R1 adapter manifest:
  `d7b574ab6ad03d7cbddf162158d81f3b3a4e63bccb0be24a6dedee86a4dddf34`
- SUB-00E-R2 audit packet:
  `8ed69dc32ab3d1d29a39fd3d38b21c135b1598f111895d93e3eaae9b11a99585`
- SUB-00E-R2 audit manifest:
  `569f73b5456de37ec101f9bd21cccea44be4767577a68a20c7477cc8f6d0b599`

## 11. Final instruction

Do not edit a frozen harness, model, adapter or runner in place.

The first authorized next action after independent hash review is:

```
execution/run_01_sub_t1_mode_a_mlkem768.sh
```
