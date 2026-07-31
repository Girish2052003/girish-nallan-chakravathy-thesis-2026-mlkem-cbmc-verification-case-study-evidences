# Chain of Custody

## Root source identity

```text
COMMIT=af4c5abdd5958bdc65a03cd5ee86708264f93304
COMPRESS_C_SHA256=9201bea6ddd1d7622cc6496d2f745fee52397d203392f75a3d6e52a400de5bad
COMPRESS_H_SHA256=0f357a30e7ea37351854dc550e502e5a7eaf80184896bf92b40073175706e0dd
```

## Frozen theorem inputs

```text
HARNESS_SHA256=5ce480427d7792b3dca091ac198b43562c4d4dfd6c9d96dae5a73e7ef1e72b55
GOTO_SHA256=51d559dcafd6668d5a7e0ed979bac481bf311cf292f4a46d66b6fcd2d04fbf5d
```

## Positive result

```text
POSITIVE_JSON_SHA256=3b32112c5537a95d470b0b866c1edf6cb1f8c3be408188c9fc2cdbf91fab40ee
```

## Authoritative stages

1. MSG-01G-R1 — candidate freeze;
2. MSG-01H — positive proof;
3. MSG-01J-R3 — reachability and non-vacuity;
4. MSG-01K-R1 — mutation-family freeze;
5. MSG-01L-R1 — mutation execution;
6. MSG-01M-R1 — corrected non-solving consolidation.

Every stage’s manifest and manifest self-hash were independently rechecked
before this consolidation was written. Every accepted frozen evidence root was
also checked for its read-only lock.

The full raw results remain in their original locked stage directories. This
consolidation package is a theorem record, integrity index and small-record
snapshot; it does not silently replace the original raw evidence.
