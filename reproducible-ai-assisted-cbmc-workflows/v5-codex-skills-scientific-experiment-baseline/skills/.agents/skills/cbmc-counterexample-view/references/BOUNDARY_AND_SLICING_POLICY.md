# Boundary and Slicing Policy

## Authority

`semantic_authority` is always `NONE`.

The skill performs only:

- exact hash binding;
- exact failed-property selection;
- JSON field normalization;
- literal and exact-field matching;
- bounded context inclusion;
- deterministic truncation from the oldest selected steps when a maximum is exceeded;
- evidence hashing and rendering.

## Selection anchors

A visible step can be selected because it is:

- a literal target-variable match;
- an exact target-function match;
- an exact source-file match;
- a function call or return when requested;
- an assumption step when requested;
- a location step when requested;
- the failed assertion/property step;
- the trace endpoint;
- part of the unfocused tail;
- bounded context around another selected step.

Hidden steps are excluded by default.

## No semantic slicing claim

The selection is not program slicing, taint analysis, dependence analysis, symbolic-state reconstruction, root-cause analysis, or theorem reasoning. A selected trace can omit relevant information. The raw trace remains authoritative.

## Latest observed assignments

The field `latest_observed_assignments` means only the last assignment to each rendered LHS found among selected steps. It must never be described as the complete final program state.

## Forbidden conclusions

The skill may not state or encode that:

- the harness is wrong;
- an assumption is too weak or too strong;
- the implementation contains a defect;
- CBMC produced a false positive;
- an arithmetic overflow caused the failure;
- a coefficient or pointer value is invalid;
- a specific code or assertion change should be made.
