# V4 architectural identity and utility-increment audit

The re-uploaded V1–V4 archive was compared byte-for-byte between the two preserved V4 directory states. This audit implements the study-history clarification that they represent **one V4 architectural generation**.

- Baseline state files: **1484**
- Codex-integration state files: **1484**
- Relative file-path sets: **identical**
- Byte-identical files: **1483**
- Differing files: **1**
- Sole differing file: `agents/common/llm_client.py`
- Baseline SHA-256: `bade13de596bf9b2e3f1ec3d376c8b45af2dcc1277054a27218db5f38fdcd318`
- Codex-state SHA-256: `a04e5964be2901816159307642ee9409ec80b54d6637aa84a65572ff2b768f66`
- Shared `agents/common/codex_exec_backend.py` SHA-256: `890da7b41fd01bfef8ab7d9e3c7066fdc87982d089f49f59207892d087bc0819`
- Shared Codex backend byte identity: **YES**

The two preserved snapshots already contain the same `agents/common/codex_exec_backend.py` implementation byte-for-byte; the sole source difference is `agents/common/llm_client.py`. That client delta adds/configures Codex backend selection and dispatch while preserving the remainder of the V4 snapshot. The integration documentation positions Codex as an alternative backend inside the existing staged architecture rather than as a replacement architecture.

**Scientific classification:** `SAME_V4_ARCHITECTURE_WITH_UTILITY_BACKEND_INCREMENT`.

This file-level result does not claim that runtime conditions or reasoning behaviour were identical; it establishes the correct architecture-generation classification of the preserved source snapshots.
