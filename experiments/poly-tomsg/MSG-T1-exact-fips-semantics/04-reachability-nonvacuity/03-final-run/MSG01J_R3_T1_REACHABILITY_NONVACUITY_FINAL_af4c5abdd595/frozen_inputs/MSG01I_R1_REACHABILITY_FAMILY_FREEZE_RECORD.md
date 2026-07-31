# MSG-01I-R1 — Reachability Control-Family Freeze

Status: **FROZEN BEFORE REACHABILITY EXECUTION**

## Original model

- SHA-256: `63291a6ba949254bffb56cdc899e4567edcd1502bde091038c70988dfa94705c`
- cover goals: 12
- raw reachable functions: 5, including `__CPROVER_cover`

## Companion model

- SHA-256: `540df0b0c8f751cd5d4e2d981f6ab587f84bba442b848999e159c3af32e18200`
- cover instructions neutralised
- raw reachable functions: 4

## Normalised production path

```text
main
 ├── msg_t1_reach_oracle
 └── mlk_msg01i_poly_tomsg
      └── mlk_scalar_compress_d1
```

## Frozen unwindset

```text
main.0:257,main.1:257,mlk_msg01i_poly_tomsg.0:257,mlk_msg01i_poly_tomsg.1:257,mlk_msg01i_poly_tomsg.2:257
```

The next stage must prove every ordinary companion property and then require
all 12 untouched-original-model cover goals to be SATISFIED.
