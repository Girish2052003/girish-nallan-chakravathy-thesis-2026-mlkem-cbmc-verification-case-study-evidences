#!/usr/bin/env python3
"""Central LLM-profile resolution and reproducibility helpers.

The user-authored experiment config may point to one shared profile with
``llm_profile``.  The profile is resolved exactly once by the common config
contract, optional run-specific operational overrides are applied, and the
resolved mapping is embedded in the normalized config used by all agents.

A run-resolved config carries ``_llm_profile.frozen = true``.  Frozen configs
never re-read the mutable source profile, which prevents a profile edit from
silently changing an experiment that is already in progress or being resumed.
"""

from __future__ import annotations

import copy
import hashlib
import json
import os
import re
from pathlib import Path
from typing import Any, Dict, Mapping, Optional, Tuple, Union

JsonDict = Dict[str, Any]
PathLike = Union[str, Path]
PROFILE_SCHEMA_VERSION = "thesis_llm_profile.v1"
RESOLVED_PROFILE_SCHEMA_VERSION = "resolved_llm_profile.v1"

# Per-run overrides are deliberately restricted to operational controls.  The
# model, reasoning, verbosity, storage, endpoint, and token budget stay in the
# one authoritative profile so a future model switch is genuinely one-place.
ALLOWED_OPERATIONAL_OVERRIDES = frozenset({
    "max_retries",
    "retry_sleep_seconds",
    "require_json_object",
    "validate_with_jsonschema",
    "max_inline_file_chars",
    "attach_files_as_base64",
    "save_raw_response",
    "save_prompt_text",
    "save_call_metadata",
    "redact_secrets_in_logs",
})

_ENV_NAME_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
_SAFE_OPTION_RE = re.compile(r"^[A-Za-z0-9_.:-]{1,64}$")


class LLMProfileError(ValueError):
    """Raised when a central LLM profile is missing, malformed, or ambiguous."""


def canonical_json_bytes(value: Any) -> bytes:
    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")


def canonical_json_sha256(value: Any) -> str:
    return hashlib.sha256(canonical_json_bytes(value)).hexdigest()


def file_sha256(path: PathLike) -> str:
    digest = hashlib.sha256()
    with Path(path).open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _resolve_path(value: Any, project_root: Path) -> Path:
    text = os.path.expandvars(os.path.expanduser(str(value).strip()))
    if not text:
        raise LLMProfileError("llm_profile must be a non-empty path string.")
    candidate = Path(text)
    if not candidate.is_absolute():
        candidate = project_root / candidate
    return candidate.resolve()


def _read_json_object(path: Path) -> JsonDict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise LLMProfileError(f"LLM profile does not exist: {path}") from exc
    except json.JSONDecodeError as exc:
        raise LLMProfileError(
            f"LLM profile is not valid JSON: {path} "
            f"(line {exc.lineno}, column {exc.colno}: {exc.msg})"
        ) from exc
    if not isinstance(value, dict):
        raise LLMProfileError(f"LLM profile root must be a JSON object: {path}")
    return dict(value)


def _nonempty_safe_option(value: Any, label: str) -> Optional[str]:
    if value is None:
        return None
    text = str(value).strip()
    if not text:
        raise LLMProfileError(f"{label} must be a non-empty string when provided.")
    if not _SAFE_OPTION_RE.fullmatch(text):
        raise LLMProfileError(
            f"{label} contains unsupported characters or exceeds 64 characters: {text!r}"
        )
    return text


def validate_profile(profile: Mapping[str, Any], *, source: Optional[Path] = None) -> None:
    where = f" in {source}" if source else ""
    version = str(profile.get("profile_schema_version") or "").strip()
    if version != PROFILE_SCHEMA_VERSION:
        raise LLMProfileError(
            f"LLM profile_schema_version must be {PROFILE_SCHEMA_VERSION!r}{where}; "
            f"found {version!r}."
        )

    provider = str(profile.get("provider") or "openai").strip().lower()
    if provider != "openai":
        raise LLMProfileError(f"Only provider 'openai' is supported{where}; found {provider!r}.")

    mode = str(profile.get("mode") or "").strip().lower()
    if mode not in {"real", "mock", "disabled"}:
        raise LLMProfileError(f"LLM profile mode must be real, mock, or disabled{where}.")

    model = str(profile.get("model") or "").strip()
    if not model:
        raise LLMProfileError(f"LLM profile model must be a non-empty string{where}.")
    placeholders = ("REPLACE_WITH", "SET_TO_", "CHOOSE_", "YOUR_MODEL")
    if any(token in model.upper() for token in placeholders):
        raise LLMProfileError(f"LLM profile model still contains placeholder text{where}: {model!r}")

    key_env = str(profile.get("api_key_env") or "").strip()
    if not _ENV_NAME_RE.fullmatch(key_env):
        raise LLMProfileError(
            f"LLM profile api_key_env must be a valid environment-variable name{where}."
        )

    for secret_key in ("api_key", "token", "secret", "password", "authorization"):
        if secret_key in profile:
            raise LLMProfileError(
                f"Secret-like field {secret_key!r} is forbidden in an LLM profile{where}; "
                "use api_key_env only."
            )

    reasoning = profile.get("reasoning")
    if reasoning is not None:
        if not isinstance(reasoning, Mapping):
            raise LLMProfileError(f"LLM profile reasoning must be an object{where}.")
        _nonempty_safe_option(reasoning.get("mode"), "reasoning.mode")
        _nonempty_safe_option(reasoning.get("effort"), "reasoning.effort")
        summary = _nonempty_safe_option(reasoning.get("summary"), "reasoning.summary")
        if summary is not None and summary not in {"auto", "concise", "detailed"}:
            raise LLMProfileError(
                f"reasoning.summary must be auto, concise, or detailed{where}; found {summary!r}."
            )

    text_cfg = profile.get("text")
    if text_cfg is not None:
        if not isinstance(text_cfg, Mapping):
            raise LLMProfileError(f"LLM profile text must be an object{where}.")
        verbosity = _nonempty_safe_option(text_cfg.get("verbosity"), "text.verbosity")
        if verbosity is not None and verbosity not in {"low", "medium", "high"}:
            raise LLMProfileError(
                f"text.verbosity must be low, medium, or high{where}; found {verbosity!r}."
            )

    if "store" in profile and not isinstance(profile.get("store"), bool):
        raise LLMProfileError(f"LLM profile store must be a JSON boolean{where}.")

    for key in ("max_output_tokens", "preflight_max_output_tokens", "max_retries", "max_inline_file_chars"):
        if key not in profile or profile.get(key) is None:
            continue
        value = profile.get(key)
        if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
            raise LLMProfileError(f"LLM profile {key} must be a positive integer{where}.")

    client = profile.get("client")
    if client is not None:
        if not isinstance(client, Mapping):
            raise LLMProfileError(f"LLM profile client must be an object{where}.")
        for key in ("base_url", "organization", "project"):
            if key in client and client.get(key) is not None and not str(client.get(key)).strip():
                raise LLMProfileError(f"client.{key} must be a non-empty string when provided{where}.")
        timeout = client.get("timeout_seconds")
        if timeout is not None:
            if isinstance(timeout, bool) or not isinstance(timeout, (int, float)) or timeout <= 0:
                raise LLMProfileError(f"client.timeout_seconds must be a positive number{where}.")


def _resolved_mapping(profile: Mapping[str, Any]) -> JsonDict:
    resolved = copy.deepcopy(dict(profile))
    resolved.pop("profile_schema_version", None)
    return resolved


def _validate_overrides(overrides: Any) -> JsonDict:
    if overrides in (None, {}):
        return {}
    if not isinstance(overrides, Mapping):
        raise LLMProfileError("llm_overrides must be an object when provided.")
    unknown = sorted(set(overrides) - set(ALLOWED_OPERATIONAL_OVERRIDES))
    if unknown:
        raise LLMProfileError(
            "llm_overrides may contain only run-specific operational fields. "
            f"Move these central fields into the shared profile: {unknown}"
        )
    return copy.deepcopy(dict(overrides))


def resolve_llm_configuration(
    raw_config: Mapping[str, Any],
    *,
    project_root: Path,
) -> Tuple[Optional[JsonDict], Optional[JsonDict], Optional[Path]]:
    """Resolve legacy inline settings or a shared profile.

    Returns ``(resolved_llm, metadata, source_profile_path)``.  For legacy
    inline configurations, metadata and source path are ``None``.
    """

    profile_meta = raw_config.get("_llm_profile")
    embedded_llm = raw_config.get("llm")
    if isinstance(profile_meta, Mapping) and bool(profile_meta.get("frozen")):
        if not isinstance(embedded_llm, Mapping):
            raise LLMProfileError("Frozen run config is missing its embedded resolved llm object.")
        resolved = copy.deepcopy(dict(embedded_llm))
        expected = str(profile_meta.get("resolved_llm_sha256") or "").strip()
        actual = canonical_json_sha256(resolved)
        if not expected or expected != actual:
            raise LLMProfileError(
                "Frozen run config resolved LLM hash mismatch; the embedded profile may have been modified."
            )
        return resolved, copy.deepcopy(dict(profile_meta)), None

    profile_ref = raw_config.get("llm_profile")
    overrides = raw_config.get("llm_overrides")

    if profile_ref not in (None, ""):
        if embedded_llm not in (None, {}):
            raise LLMProfileError(
                "Configuration must not contain both llm_profile and an inline llm object. "
                "Use llm_overrides only for approved run-specific operational fields."
            )
        profile_path = _resolve_path(profile_ref, project_root)
        profile = _read_json_object(profile_path)
        validate_profile(profile, source=profile_path)
        resolved = _resolved_mapping(profile)
        approved_overrides = _validate_overrides(overrides)
        resolved.update(approved_overrides)
        metadata: JsonDict = {
            "schema_version": RESOLVED_PROFILE_SCHEMA_VERSION,
            "profile_schema_version": profile.get("profile_schema_version"),
            "source_path": str(profile_path),
            "source_sha256": file_sha256(profile_path),
            "resolved_llm_sha256": canonical_json_sha256(resolved),
            "operational_overrides": approved_overrides,
            "frozen": False,
        }
        return resolved, metadata, profile_path

    if overrides not in (None, {}):
        raise LLMProfileError("llm_overrides requires llm_profile.")

    if embedded_llm is None:
        return None, None, None
    if not isinstance(embedded_llm, Mapping):
        raise LLMProfileError("Inline llm configuration must be an object.")
    return copy.deepcopy(dict(embedded_llm)), None, None


def frozen_profile_metadata(metadata: Mapping[str, Any], *, snapshot_path: PathLike) -> JsonDict:
    result = copy.deepcopy(dict(metadata))
    result["frozen"] = True
    result["snapshot_path"] = str(Path(snapshot_path).resolve())
    return result


def resolved_profile_record(
    *,
    resolved_llm: Mapping[str, Any],
    metadata: Optional[Mapping[str, Any]],
) -> JsonDict:
    meta = copy.deepcopy(dict(metadata or {}))
    return {
        "schema_version": RESOLVED_PROFILE_SCHEMA_VERSION,
        "resolved_llm": copy.deepcopy(dict(resolved_llm)),
        "resolved_llm_sha256": canonical_json_sha256(dict(resolved_llm)),
        "source_profile": meta,
        "secret_policy": "API credential values are never stored; only api_key_env is recorded.",
    }


__all__ = [
    "ALLOWED_OPERATIONAL_OVERRIDES",
    "LLMProfileError",
    "PROFILE_SCHEMA_VERSION",
    "RESOLVED_PROFILE_SCHEMA_VERSION",
    "canonical_json_bytes",
    "canonical_json_sha256",
    "file_sha256",
    "frozen_profile_metadata",
    "resolve_llm_configuration",
    "resolved_profile_record",
    "validate_profile",
]
