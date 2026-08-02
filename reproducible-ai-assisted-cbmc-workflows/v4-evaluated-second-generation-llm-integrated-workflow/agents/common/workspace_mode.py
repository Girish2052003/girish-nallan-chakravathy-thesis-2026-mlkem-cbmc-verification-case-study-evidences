"""Private mutable-only workspace compatibility helpers.

This research edition has one workspace behaviour: editable source, ordinary
configs, and in-tree ``runs/<run_id>`` outputs.  The optional legacy
``workspace_mode`` field is accepted only when it selects mutable operation.
"""
from __future__ import annotations

from typing import Any, Mapping

MUTABLE_WORKSPACE = "mutable_workspace"
_MUTABLE_ALIASES = {"", "mutable", "mutable_workspace", "workspace", "private"}
_VERIFIED_ALIASES = {"verified", "verified_release", "frozen", "release"}


def normalise_workspace_mode(config: Mapping[str, Any]) -> str:
    raw = str(config.get("workspace_mode") or "").strip().lower()
    if raw in _MUTABLE_ALIASES:
        return MUTABLE_WORKSPACE
    if raw in _VERIFIED_ALIASES:
        raise ValueError(
            "verified_release is not supported by this mutable-only edition. "
            "Remove workspace_mode or use mutable_workspace."
        )
    raise ValueError("workspace_mode may be omitted or set to 'mutable_workspace'.")


def mutable_workspace_enabled(config: Mapping[str, Any]) -> bool:
    normalise_workspace_mode(config)
    return True
