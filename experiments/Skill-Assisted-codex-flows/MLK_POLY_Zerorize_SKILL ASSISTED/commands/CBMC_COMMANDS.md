# Authoritative command model

Source preparation:

```bash
git checkout --detach af4c5abdd5958bdc65a03cd5ee86708264f93304
test "$(git rev-parse HEAD^{tree})" = "54805daff6a91a010c05467ea678117c42a71559"
```

For each harness, the runner builds proof, coverage, and expected-failure GOTO
models with C90, ML-KEM-768, and namespace `mlk_sa_zero`. Positive CBMC checks
include bounds, pointer, pointer-overflow, conversion, signed/unsigned overflow,
division-by-zero, undefined-shift, unwind 17, unwinding assertions, formula
slicing, and JSON output. Reachability uses a separately compiled `SKILL_COVER_MODE` model. Each named marker is encoded as a deliberately false assertion `!marker`; CBMC exit 10 and failure of every exact marker prove feasibility and reachability. Unrelated failures are forbidden.
