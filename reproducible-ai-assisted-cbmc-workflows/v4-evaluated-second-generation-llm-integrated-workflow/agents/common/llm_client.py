"""
llm_client.py

Shared LLM client wrapper for the thesis agent workflow.

Purpose
-------
This module gives every LLM-backed agent one safe, reproducible API pathway.

It supports:
- Real OpenAI Responses API calls.
- Mock mode when no API key is available.
- Disabled mode for deterministic baseline runs.
- Prompt/package preservation through RunLayout.
- Raw response saving.
- Strict JSON extraction.
- Optional JSON-schema validation.
- Retry on malformed JSON.
- File attachment support for local evidence files.
- No API key logging.
- Stage-aware output storage:
    prompt_package/
    llm_authoritative/
    validation/

Trust boundary
--------------
This wrapper does not claim that LLM output is true, proven, or verified.
It only records the LLM-authored candidate output for a workflow stage.

Formal evidence must come from deterministic tools such as CBMC and logged outputs.
"""

from __future__ import annotations

import base64
import hashlib
import json
import mimetypes
import os
import re
import time
import traceback
try:
    import fcntl  # POSIX file locking for concurrent initial stages
except ImportError:  # pragma: no cover - Windows fallback
    fcntl = None  # type: ignore
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple, Union


JsonDict = Dict[str, Any]
PathLike = Union[str, Path]


# ---------------------------------------------------------------------------
# Optional imports
# ---------------------------------------------------------------------------

try:
    from openai import OpenAI  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    OpenAI = None  # type: ignore


try:
    import jsonschema  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    jsonschema = None  # type: ignore


# ---------------------------------------------------------------------------
# General helpers
# ---------------------------------------------------------------------------

def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def ensure_dir(path: PathLike) -> Path:
    p = Path(path)
    p.mkdir(parents=True, exist_ok=True)
    return p


def atomic_write_text(path: PathLike, text: str, encoding: str = "utf-8") -> Path:
    p = Path(path)
    ensure_dir(p.parent)
    tmp = p.with_suffix(p.suffix + ".tmp")
    tmp.write_text(text, encoding=encoding)
    tmp.replace(p)
    return p


def atomic_write_json(path: PathLike, data: Mapping[str, Any], indent: int = 2) -> Path:
    return atomic_write_text(
        path,
        json.dumps(data, indent=indent, ensure_ascii=False, sort_keys=False) + "\n",
    )


def read_text_safely(path: PathLike, *, max_chars: Optional[int] = None) -> str:
    p = Path(path)
    text = p.read_text(encoding="utf-8", errors="replace")
    if max_chars is not None and len(text) > max_chars:
        return text[:max_chars] + "\n\n[TRUNCATED_BY_LLM_CLIENT_MAX_CHARS]\n"
    return text


SECRET_KEY_NAMES = {
    "api_key", "openai_api_key", "access_token", "refresh_token", "id_token",
    "authorization", "proxy_authorization", "password", "client_secret", "secret_key",
}

def _is_secret_key(key: Any) -> bool:
    normalized = str(key).strip().lower().replace("-", "_")
    return (
        normalized in SECRET_KEY_NAMES
        or normalized.endswith("_api_key")
        or normalized.endswith("_access_token")
        or normalized.endswith("_refresh_token")
        or normalized.endswith("_client_secret")
        or normalized.endswith("_password")
    )

def redact_secrets(value: Any) -> Any:
    """Recursively redact credentials while preserving numeric usage metrics.

    Fields such as input_tokens, output_tokens, and total_tokens are evidence,
    not credentials, and therefore must remain available for cost/reproducibility
    analysis.
    """
    if isinstance(value, dict):
        redacted = {}
        for k, v in value.items():
            redacted[k] = "[REDACTED]" if _is_secret_key(k) else redact_secrets(v)
        return redacted
    if isinstance(value, list):
        return [redact_secrets(v) for v in value]
    if isinstance(value, str):
        value = re.sub(r"sk-[A-Za-z0-9_\-]{12,}", "sk-[REDACTED]", value)
        value = re.sub(r"Bearer\s+[A-Za-z0-9_\-\.]{12,}", "Bearer [REDACTED]", value)
    return value


def path_metadata(path: PathLike) -> JsonDict:
    p = Path(path)
    stat = p.stat()
    return {
        "path": str(p),
        "name": p.name,
        "suffix": p.suffix,
        "size_bytes": stat.st_size,
        "modified_time_utc": datetime.fromtimestamp(stat.st_mtime, timezone.utc).isoformat(),
    }


def reserve_run_input_budget(
    layout: Any,
    *,
    stage: str,
    attempt: int,
    request_bytes: int,
    estimated_input_tokens: int,
    max_total_input_tokens_estimate: int,
) -> Path:
    """Atomically reserve run-level input budget before an API call is sent."""
    run_dir = Path(getattr(layout, "run_dir", getattr(layout, "root", "."))).resolve()
    ledger_path = run_dir / "runtime_input_budget_ledger.json"
    lock_path = run_dir / ".runtime_input_budget.lock"
    ensure_dir(run_dir)
    with lock_path.open("a+", encoding="utf-8") as lock_file:
        if fcntl is not None:
            fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX)
        try:
            if ledger_path.is_file():
                try:
                    ledger = json.loads(ledger_path.read_text(encoding="utf-8"))
                except Exception:
                    raise ValueError("runtime_input_budget_ledger_corrupt")
            else:
                ledger = {
                    "schema_version": "runtime_input_budget_ledger.v1",
                    "created_utc": utc_now_iso(),
                    "max_total_input_tokens_estimate": max_total_input_tokens_estimate,
                    "reserved_input_tokens_estimate": 0,
                    "requests": [],
                }
            prior = int(ledger.get("reserved_input_tokens_estimate") or 0)
            proposed = prior + int(estimated_input_tokens)
            if proposed > max_total_input_tokens_estimate:
                raise ValueError(
                    "run_input_token_budget_exceeded: "
                    f"{proposed} estimated tokens > {max_total_input_tokens_estimate}"
                )
            row = {
                "created_utc": utc_now_iso(),
                "stage": stage,
                "attempt": attempt,
                "request_bytes": request_bytes,
                "estimated_input_tokens": estimated_input_tokens,
                "cumulative_estimated_input_tokens": proposed,
            }
            ledger["max_total_input_tokens_estimate"] = max_total_input_tokens_estimate
            ledger["reserved_input_tokens_estimate"] = proposed
            ledger.setdefault("requests", []).append(row)
            atomic_write_json(ledger_path, ledger)
            return ledger_path
        finally:
            if fcntl is not None:
                fcntl.flock(lock_file.fileno(), fcntl.LOCK_UN)


# ---------------------------------------------------------------------------
# Modes/config
# ---------------------------------------------------------------------------

class LLMMode(str, Enum):
    """
    LLM execution modes.

    real:
        Perform an actual OpenAI API call.

    mock:
        Do not call the API. Return a schema-shaped mock object.
        Useful for testing pipeline wiring without spending API credits.

    disabled:
        Do not call the API and do not generate authoritative content.
        Useful for deterministic baseline runs.
    """

    REAL = "real"
    MOCK = "mock"
    DISABLED = "disabled"


@dataclass
class LLMClientConfig:
    """
    Configuration for the shared LLM client.
    """

    mode: LLMMode = LLMMode.MOCK
    model: str = "REPLACE_WITH_AVAILABLE_MODEL"
    api_key_env: str = "OPENAI_API_KEY"

    # Provider and Responses API settings
    provider: str = "openai"
    temperature: Optional[float] = None
    max_output_tokens: Optional[int] = None
    preflight_max_output_tokens: int = 256
    reasoning_mode: Optional[str] = None
    reasoning_effort: Optional[str] = None
    reasoning_summary: Optional[str] = None
    text_verbosity: Optional[str] = None
    store: bool = False

    # OpenAI client routing/settings
    base_url: Optional[str] = None
    organization: Optional[str] = None
    project: Optional[str] = None
    timeout_seconds: Optional[float] = None

    # Retry/validation behaviour
    max_retries: int = 2
    retry_sleep_seconds: float = 2.0
    schema_retry_enabled: bool = True
    schema_retry_max_retries: Optional[int] = None
    incomplete_response_retry_enabled: bool = False
    incomplete_response_retry_max_retries: int = 0
    provider_error_retry_enabled: bool = True
    provider_error_retry_max_retries: Optional[int] = None
    require_json_object: bool = True
    strict_json_object_only: bool = True
    validate_with_jsonschema: bool = True
    allow_minimal_schema_validation: bool = False
    semantic_advisory_mode: str = "off"
    max_request_bytes: int = 450_000
    max_retry_growth_percent: int = 10
    max_stage_input_tokens_estimate: int = 120_000
    max_total_input_tokens_estimate: int = 600_000

    # File/evidence behaviour
    max_inline_file_chars: int = 120_000
    # Primary evidence must never be silently shortened in a real thesis run.
    # The per-run max_inline_file_chars value remains an operational limit, but
    # exceeding it is a fail-closed error rather than an invitation to truncate.
    fail_on_primary_evidence_truncation: bool = True
    attach_files_as_base64: bool = False
    # If False, text/code files are inlined in the prompt package.
    # If True, file inputs are encoded for the Responses API input_file mechanism.

    # Safety/logging
    save_raw_response: bool = True
    save_prompt_text: bool = True
    save_call_metadata: bool = True
    redact_secrets_in_logs: bool = True

    @classmethod
    def from_mapping(cls, data: Optional[Mapping[str, Any]]) -> "LLMClientConfig":
        if not data:
            return cls()

        mode_value = str(data.get("mode", data.get("llm_mode", cls.mode.value))).lower()
        if mode_value not in {m.value for m in LLMMode}:
            raise ValueError(f"Unsupported llm mode: {mode_value}")

        reasoning = data.get("reasoning") if isinstance(data.get("reasoning"), Mapping) else {}
        text_cfg = data.get("text") if isinstance(data.get("text"), Mapping) else {}
        client_cfg = data.get("client") if isinstance(data.get("client"), Mapping) else {}
        retry_policy = data.get("retry_policy") if isinstance(data.get("retry_policy"), Mapping) else {}

        def retry_block(name: str) -> Mapping[str, Any]:
            value = retry_policy.get(name)
            return value if isinstance(value, Mapping) else {}

        schema_retry = retry_block("schema")
        incomplete_retry = retry_block("incomplete_response")
        provider_retry = retry_block("provider_error")

        def optional_retry_limit(block: Mapping[str, Any], fallback: Optional[int]) -> Optional[int]:
            value = block.get("max_retries", fallback)
            if value is None:
                return None
            parsed = int(value)
            if parsed < 0:
                raise ValueError("retry_policy max_retries must be non-negative")
            return parsed

        def optional_text(value: Any) -> Optional[str]:
            if value is None:
                return None
            text = str(value).strip()
            return text or None

        fail_closed_primary = bool(
            data.get(
                "fail_on_primary_evidence_truncation",
                cls.fail_on_primary_evidence_truncation,
            )
        )
        if not fail_closed_primary:
            raise ValueError(
                "fail_on_primary_evidence_truncation cannot be disabled for this workflow."
            )

        return cls(
            mode=LLMMode(mode_value),
            model=str(data.get("model", cls.model)),
            api_key_env=str(data.get("api_key_env", cls.api_key_env)),
            provider=str(data.get("provider", cls.provider)).strip().lower(),
            temperature=data.get("temperature", cls.temperature),
            max_output_tokens=data.get("max_output_tokens", cls.max_output_tokens),
            preflight_max_output_tokens=int(
                data.get("preflight_max_output_tokens", cls.preflight_max_output_tokens)
            ),
            reasoning_mode=optional_text(
                reasoning.get("mode", data.get("reasoning_mode", cls.reasoning_mode))
            ),
            reasoning_effort=optional_text(
                reasoning.get("effort", data.get("reasoning_effort", cls.reasoning_effort))
            ),
            reasoning_summary=optional_text(
                reasoning.get("summary", data.get("reasoning_summary", cls.reasoning_summary))
            ),
            text_verbosity=optional_text(
                text_cfg.get("verbosity", data.get("text_verbosity", cls.text_verbosity))
            ),
            store=bool(data.get("store", cls.store)),
            base_url=optional_text(client_cfg.get("base_url", data.get("base_url", cls.base_url))),
            organization=optional_text(
                client_cfg.get("organization", data.get("organization", cls.organization))
            ),
            project=optional_text(client_cfg.get("project", data.get("project", cls.project))),
            timeout_seconds=(
                float(client_cfg.get("timeout_seconds", data.get("timeout_seconds")))
                if client_cfg.get("timeout_seconds", data.get("timeout_seconds")) is not None
                else cls.timeout_seconds
            ),
            max_retries=int(data.get("max_retries", cls.max_retries)),
            retry_sleep_seconds=float(data.get("retry_sleep_seconds", cls.retry_sleep_seconds)),
            schema_retry_enabled=bool(schema_retry.get("enabled", cls.schema_retry_enabled)),
            schema_retry_max_retries=optional_retry_limit(
                schema_retry, int(data.get("max_retries", cls.max_retries))
            ),
            incomplete_response_retry_enabled=bool(
                incomplete_retry.get("enabled", cls.incomplete_response_retry_enabled)
            ),
            incomplete_response_retry_max_retries=int(
                optional_retry_limit(
                    incomplete_retry, cls.incomplete_response_retry_max_retries
                ) or 0
            ),
            provider_error_retry_enabled=bool(
                provider_retry.get("enabled", cls.provider_error_retry_enabled)
            ),
            provider_error_retry_max_retries=optional_retry_limit(
                provider_retry, int(data.get("max_retries", cls.max_retries))
            ),
            require_json_object=bool(data.get("require_json_object", cls.require_json_object)),
            strict_json_object_only=bool(data.get("strict_json_object_only", cls.strict_json_object_only)),
            validate_with_jsonschema=bool(data.get("validate_with_jsonschema", cls.validate_with_jsonschema)),
            allow_minimal_schema_validation=bool(
                data.get("allow_minimal_schema_validation", cls.allow_minimal_schema_validation)
            ),
            semantic_advisory_mode=str(data.get("semantic_advisory_mode", cls.semantic_advisory_mode)).strip().lower(),
            max_request_bytes=int(data.get("max_request_bytes", cls.max_request_bytes)),
            max_retry_growth_percent=int(data.get("max_retry_growth_percent", cls.max_retry_growth_percent)),
            max_stage_input_tokens_estimate=int(data.get("max_stage_input_tokens_estimate", cls.max_stage_input_tokens_estimate)),
            max_total_input_tokens_estimate=int(data.get("max_total_input_tokens_estimate", cls.max_total_input_tokens_estimate)),
            max_inline_file_chars=int(data.get("max_inline_file_chars", cls.max_inline_file_chars)),
            fail_on_primary_evidence_truncation=fail_closed_primary,
            attach_files_as_base64=bool(data.get("attach_files_as_base64", cls.attach_files_as_base64)),
            save_raw_response=bool(data.get("save_raw_response", cls.save_raw_response)),
            save_prompt_text=bool(data.get("save_prompt_text", cls.save_prompt_text)),
            save_call_metadata=bool(data.get("save_call_metadata", cls.save_call_metadata)),
            redact_secrets_in_logs=bool(data.get("redact_secrets_in_logs", cls.redact_secrets_in_logs)),
        )


def retry_limit(config: LLMClientConfig, category: str) -> int:
    """Return the explicit retry limit for one failure category."""
    if category == "schema_or_json":
        limit = config.max_retries if config.schema_retry_max_retries is None else config.schema_retry_max_retries
        return int(limit) if config.schema_retry_enabled else 0
    if category == "incomplete_response":
        return int(config.incomplete_response_retry_max_retries) if config.incomplete_response_retry_enabled else 0
    if category == "provider_error":
        limit = config.max_retries if config.provider_error_retry_max_retries is None else config.provider_error_retry_max_retries
        return int(limit) if config.provider_error_retry_enabled else 0
    return 0


def retry_policy_record(config: LLMClientConfig) -> JsonDict:
    return {
        "schema_or_json": {"enabled": config.schema_retry_enabled, "max_retries": retry_limit(config, "schema_or_json")},
        "incomplete_response": {"enabled": config.incomplete_response_retry_enabled, "max_retries": retry_limit(config, "incomplete_response")},
        "provider_error": {"enabled": config.provider_error_retry_enabled, "max_retries": retry_limit(config, "provider_error")},
        "max_retry_growth_percent": config.max_retry_growth_percent,
        "legacy_max_retries_default": config.max_retries,
    }


def classify_retry_category(exc: BaseException) -> str:
    if isinstance(exc, IncompleteResponseError):
        return "incomplete_response"
    if isinstance(exc, (JSONExtractionError, SchemaValidationError)):
        return "schema_or_json"
    return "provider_error"


def retry_is_allowed(config: LLMClientConfig, category: str, retries_already_used: int) -> bool:
    return retries_already_used < retry_limit(config, category)


def max_configured_retries(config: LLMClientConfig) -> int:
    return max(retry_limit(config, category) for category in (
        "schema_or_json", "incomplete_response", "provider_error"
    ))


def build_openai_client_kwargs(config: LLMClientConfig, api_key: str) -> JsonDict:
    """Build the same OpenAI client arguments for preflight and runtime."""
    if config.provider != "openai":
        raise ValueError(f"Unsupported LLM provider: {config.provider!r}")
    kwargs: JsonDict = {"api_key": api_key}
    for key, value in (
        ("base_url", config.base_url),
        ("organization", config.organization),
        ("project", config.project),
    ):
        if value is not None:
            kwargs[key] = value
    if config.timeout_seconds is not None:
        kwargs["timeout"] = config.timeout_seconds
    return kwargs


def build_responses_control_payload(
    config: LLMClientConfig,
    *,
    max_output_tokens_override: Optional[int] = None,
) -> JsonDict:
    """Build model controls shared by the live preflight and every real stage."""
    payload: JsonDict = {"store": bool(config.store)}

    if config.temperature is not None:
        payload["temperature"] = config.temperature

    max_tokens = (
        max_output_tokens_override
        if max_output_tokens_override is not None
        else config.max_output_tokens
    )
    if max_tokens is not None:
        payload["max_output_tokens"] = int(max_tokens)

    reasoning: JsonDict = {}
    if config.reasoning_mode is not None:
        reasoning["mode"] = config.reasoning_mode
    if config.reasoning_effort is not None:
        reasoning["effort"] = config.reasoning_effort
    if config.reasoning_summary is not None:
        reasoning["summary"] = config.reasoning_summary
    if reasoning:
        payload["reasoning"] = reasoning

    if config.text_verbosity is not None:
        payload["text"] = {"verbosity": config.text_verbosity}

    return payload


@dataclass
class LLMStageRequest:
    """
    One LLM-backed workflow-stage request.
    """

    stage: str
    prompt_text: str
    output_filename: str

    # JSON schema is optional but strongly recommended.
    json_schema: Optional[JsonDict] = None

    # Evidence categories. They are transmitted and recorded separately.
    primary_evidence_files: List[PathLike] = field(default_factory=list)
    prior_authoritative_context_files: List[PathLike] = field(default_factory=list)
    trusted_deterministic_fact_files: List[PathLike] = field(default_factory=list)
    prior_authoritative_context_bundle: Optional[JsonDict] = None
    trusted_deterministic_facts_bundle: Optional[JsonDict] = None
    deterministic_reference_bundle: Optional[JsonDict] = None
    extra_prompt_metadata: JsonDict = field(default_factory=dict)

    # Optional mock object for pipeline tests.
    mock_response_content: Optional[JsonDict] = None

    # If true, rejected/malformed outputs are still saved as raw response but not handed off.
    allow_invalid_json_save: bool = True


@dataclass
class LLMStageResult:
    """
    Result returned by run_stage().
    """

    stage: str
    mode: str
    success: bool
    llm_call_executed: bool
    output_path: Optional[str]
    raw_response_path: Optional[str]
    validation_path: Optional[str]
    prompt_path: Optional[str]
    metadata_path: Optional[str]
    attempts: int
    error: Optional[str] = None
    parsed_json: Optional[JsonDict] = None
    validation: Optional[JsonDict] = None

    def to_dict(self) -> JsonDict:
        return asdict(self)


def record_llm_stage_failure(stage_status: JsonDict, result: "LLMStageResult") -> None:
    """Store an LLM result and expose failures through authoritative errors.

    The orchestrator diagnoses failures from ``errors`` or a top-level ``error``
    field, so keeping the cause only inside ``llm_result`` hides the root cause.
    """
    stage_status["llm_result"] = result.to_dict()
    if result.success:
        return
    record = {
        "type": "LLMStageError",
        "message": result.error or "LLM stage failed without a populated error message.",
        "validation_path": result.validation_path,
        "attempts": int(result.attempts or 0),
        "llm_call_executed": bool(result.llm_call_executed),
    }
    errors = stage_status.setdefault("errors", [])
    if not isinstance(errors, list):
        stage_status["errors"] = errors = []
    duplicate = any(
        isinstance(item, dict)
        and item.get("type") == record["type"]
        and item.get("message") == record["message"]
        and item.get("validation_path") == record["validation_path"]
        for item in errors
    )
    if not duplicate:
        errors.append(record)


# ---------------------------------------------------------------------------
# JSON extraction / validation
# ---------------------------------------------------------------------------

class JSONExtractionError(ValueError):
    pass


class SchemaValidationError(ValueError):
    pass


class IncompleteResponseError(RuntimeError):
    """Provider returned an incomplete response with no final stage output."""

    def __init__(self, *, status: str, reason: str, details: Any = None):
        self.status = status
        self.reason = reason
        self.details = details
        super().__init__(f"Provider response incomplete: status={status!r}, reason={reason!r}")


def extract_json_object(text: str, *, strict: bool = True) -> JsonDict:
    """Extract exactly one JSON object in strict mode.

    Reduced/manual mode may opt into legacy fenced or embedded-object recovery,
    but reviewed thesis mode accepts no surrounding prose or second object.
    """
    stripped = text.strip()

    # Direct JSON.
    try:
        data = json.loads(stripped)
        if isinstance(data, dict):
            return data
        raise JSONExtractionError(f"Expected JSON object, got {type(data).__name__}")
    except json.JSONDecodeError as exc:
        if strict:
            raise JSONExtractionError(
                "Strict structured output requires the entire response to be exactly one JSON object: "
                + str(exc)
            ) from exc

    # Reduced/manual compatibility: fenced code block.
    fence_match = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", stripped, re.DOTALL | re.IGNORECASE)
    if fence_match:
        candidate = fence_match.group(1)
        try:
            data = json.loads(candidate)
            if isinstance(data, dict):
                return data
            raise JSONExtractionError(f"Expected JSON object in fenced block, got {type(data).__name__}")
        except json.JSONDecodeError as exc:
            raise JSONExtractionError(f"Invalid JSON in fenced block: {exc}") from exc

    # Bracket matching fallback.
    first = stripped.find("{")
    last = stripped.rfind("}")
    if first != -1 and last != -1 and last > first:
        candidate = stripped[first:last + 1]
        try:
            data = json.loads(candidate)
            if isinstance(data, dict):
                return data
            raise JSONExtractionError(f"Expected JSON object in embedded object, got {type(data).__name__}")
        except json.JSONDecodeError as exc:
            raise JSONExtractionError(f"Could not parse embedded JSON object: {exc}") from exc

    raise JSONExtractionError("No parseable JSON object found in response.")


_OPENAI_STRUCTURED_OUTPUT_UNSUPPORTED_KEYWORDS = {
    "oneOf",
    "allOf",
    "not",
    "dependentRequired",
    "dependentSchemas",
    "if",
    "then",
    "else",
    "minLength",
    "maxLength",
    "uniqueItems",
    "contains",
    "minContains",
    "maxContains",
    "unevaluatedProperties",
    "propertyNames",
}


def validate_openai_structured_output_schema(schema: Optional[JsonDict]) -> JsonDict:
    """Validate the provider's constrained Structured Outputs schema subset.

    This prevents deterministic schema defects from consuming API attempts.
    """
    if schema is None:
        return {
            "schema_preflight_enabled": False,
            "valid": True,
            "errors": [],
            "metrics": {},
            "reason": "No structured-output schema was supplied.",
        }

    errors: List[str] = []
    metrics: JsonDict = {
        "object_property_count": 0,
        "enum_value_count": 0,
        "schema_string_budget_chars": 0,
        "maximum_nesting_depth": 0,
    }
    supported_types = {"string", "number", "boolean", "integer", "object", "array", "null"}

    def render_path(parts: Tuple[Union[str, int], ...]) -> str:
        if not parts:
            return "$"
        rendered = "$"
        for part in parts:
            rendered += f"[{part}]" if isinstance(part, int) else f".{part}"
        return rendered

    def add_budget(value: Any) -> None:
        if isinstance(value, str):
            metrics["schema_string_budget_chars"] += len(value)

    def walk(node: Any, path: Tuple[Union[str, int], ...], depth: int) -> None:
        metrics["maximum_nesting_depth"] = max(metrics["maximum_nesting_depth"], depth)
        here = render_path(path)
        if not isinstance(node, dict):
            errors.append(f"{here}: schema node must be an object")
            return

        for keyword in sorted(_OPENAI_STRUCTURED_OUTPUT_UNSUPPORTED_KEYWORDS.intersection(node)):
            errors.append(f"{here}: unsupported Structured Outputs keyword {keyword!r}")

        declared_type = node.get("type")
        if isinstance(declared_type, str):
            declared_types = [declared_type]
        elif isinstance(declared_type, list) and declared_type:
            declared_types = declared_type
        elif "$ref" in node or "anyOf" in node:
            declared_types = []
        else:
            errors.append(f"{here}: missing or invalid schema type")
            declared_types = []
        invalid_types = [value for value in declared_types if value not in supported_types]
        if invalid_types:
            errors.append(f"{here}: unsupported schema type(s): {invalid_types!r}")

        if path == ():
            if "anyOf" in node:
                errors.append("$: root schema must not use anyOf")
            if declared_type != "object":
                errors.append("$: root schema must have type 'object'")

        enum_values = node.get("enum")
        if enum_values is not None:
            if not isinstance(enum_values, list):
                errors.append(f"{here}.enum: must be an array")
            else:
                metrics["enum_value_count"] += len(enum_values)
                enum_string_chars = 0
                for value in enum_values:
                    add_budget(value)
                    if isinstance(value, str):
                        enum_string_chars += len(value)
                if len(enum_values) > 250 and enum_string_chars > 15000:
                    errors.append(
                        f"{here}.enum: string values exceed 15000 characters for an enum with more than 250 values"
                    )
        if "const" in node:
            add_budget(node.get("const"))

        if "object" in declared_types:
            properties = node.get("properties")
            if properties is not None:
                if not isinstance(properties, dict):
                    errors.append(f"{here}.properties: must be an object")
                    properties = {}
                metrics["object_property_count"] += len(properties)
                if node.get("additionalProperties") is not False:
                    errors.append(f"{here}: object schema must set additionalProperties to false")
                required = node.get("required")
                if not isinstance(required, list) or set(required) != set(properties):
                    errors.append(f"{here}: required fields must exactly match object properties")
                for name, child in properties.items():
                    add_budget(name)
                    walk(child, path + ("properties", name), depth + 1)

        if "array" in declared_types:
            items = node.get("items")
            if not isinstance(items, dict):
                errors.append(f"{here}: array schema must define one object-valued items schema")
            else:
                walk(items, path + ("items",), depth + 1)

        branches = node.get("anyOf")
        if branches is not None:
            if not isinstance(branches, list) or not branches:
                errors.append(f"{here}.anyOf: must be a non-empty array")
            else:
                for index, branch in enumerate(branches):
                    walk(branch, path + ("anyOf", index), depth + 1)

        for definitions_key in ("$defs", "definitions"):
            definitions = node.get(definitions_key)
            if definitions is not None:
                if not isinstance(definitions, dict):
                    errors.append(f"{here}.{definitions_key}: must be an object")
                else:
                    for name, child in definitions.items():
                        add_budget(name)
                        walk(child, path + (definitions_key, name), depth + 1)

    walk(schema, (), 1)
    if metrics["object_property_count"] > 5000:
        errors.append(
            f"$: object property count {metrics['object_property_count']} exceeds the Structured Outputs limit of 5000"
        )
    if metrics["maximum_nesting_depth"] > 10:
        errors.append(
            f"$: nesting depth {metrics['maximum_nesting_depth']} exceeds the Structured Outputs limit of 10"
        )
    if metrics["schema_string_budget_chars"] > 120000:
        errors.append(
            f"$: schema string budget {metrics['schema_string_budget_chars']} exceeds the limit of 120000"
        )
    if metrics["enum_value_count"] > 1000:
        errors.append(
            f"$: enum value count {metrics['enum_value_count']} exceeds the Structured Outputs limit of 1000"
        )

    return {
        "schema_preflight_enabled": True,
        "validator": "local_openai_structured_outputs_subset.v1",
        "valid": not errors,
        "errors": errors,
        "metrics": metrics,
        "claim_boundary": "Local compatibility preflight only; provider acceptance and output correctness are not claimed.",
    }


def validate_json_schema(
    instance: JsonDict, schema: Optional[JsonDict], *, allow_minimal_fallback: bool = False
) -> JsonDict:
    """
    Validate JSON against a schema if jsonschema is installed.

    If jsonschema is unavailable, performs a minimal required-field check.
    """
    if schema is None:
        return {
            "schema_validation_enabled": False,
            "valid": True,
            "reason": "No schema provided.",
        }

    if jsonschema is not None:
        try:
            jsonschema.validate(instance=instance, schema=schema)
            return {
                "schema_validation_enabled": True,
                "validator": "jsonschema",
                "valid": True,
                "errors": [],
            }
        except Exception as exc:
            return {
                "schema_validation_enabled": True,
                "validator": "jsonschema",
                "valid": False,
                "errors": [str(exc)],
            }

    if not allow_minimal_fallback:
        return {
            "schema_validation_enabled": True,
            "validator": "jsonschema_unavailable_fail_closed",
            "valid": False,
            "errors": [
                "The jsonschema package is required for reviewed/real structured output validation."
            ],
            "reduced_validation": False,
        }

    # Explicit reduced/manual fallback: only check top-level required fields.
    missing = []
    required = schema.get("required", [])
    if isinstance(required, list):
        for field in required:
            if field not in instance:
                missing.append(field)

    return {
        "schema_validation_enabled": True,
        "validator": "minimal_required_fields_fallback",
        "valid": not missing,
        "errors": [f"Missing required field: {m}" for m in missing],
        "warning": "Reduced validation explicitly enabled; install jsonschema for full validation.",
        "reduced_validation": True,
    }


# ---------------------------------------------------------------------------
# Prompt building helpers
# ---------------------------------------------------------------------------

PRIMARY_EVIDENCE_TRUNCATION_MARKER = "[TRUNCATED_BY_LLM_CLIENT_MAX_CHARS]"


class PrimaryEvidenceCompletenessError(ValueError):
    """Raised before an API call when raw primary evidence would be incomplete."""


def _sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def _normalise_usage(value: Any) -> JsonDict:
    """Return provider usage as a plain mapping when possible."""
    if value is None:
        return {}
    if hasattr(value, "model_dump"):
        try:
            dumped = value.model_dump()
            return dumped if isinstance(dumped, dict) else {"value": dumped}
        except Exception:
            pass
    if isinstance(value, Mapping):
        return dict(value)
    return {"value": str(value)}


def build_primary_evidence_transmission_manifest(
    files: Sequence[PathLike],
    *,
    config: LLMClientConfig,
) -> JsonDict:
    """Describe exactly whether every raw primary file can be sent in full.

    Text-inline mode is audited using the same UTF-8-with-replacement decoding
    and per-file character limit used by build_responses_api_input().  Base64
    attachment mode transmits the original bytes and therefore has no inline
    character truncation.
    """
    entries: List[JsonDict] = []
    for value in files:
        path = Path(value).expanduser()
        entry: JsonDict = {
            "path": str(path),
            "exists": path.is_file(),
            "transport": "input_file_base64" if config.attach_files_as_base64 else "inline_input_text",
            "max_inline_file_chars": config.max_inline_file_chars,
        }
        if not path.is_file():
            entry.update({
                "complete": False,
                "truncated": False,
                "error": "Primary evidence file is missing or is not a regular file.",
            })
            entries.append(entry)
            continue

        raw = path.read_bytes()
        entry["size_bytes"] = len(raw)
        entry["original_file_sha256"] = _sha256_bytes(raw)

        if config.attach_files_as_base64:
            entry.update({
                "original_char_count": None,
                "transmitted_char_count": None,
                "transmitted_content_sha256": entry["original_file_sha256"],
                "truncated": False,
                "complete": True,
            })
        else:
            text = raw.decode("utf-8", errors="replace")
            truncated = len(text) > config.max_inline_file_chars
            transmitted = (
                text[: config.max_inline_file_chars]
                + "\n\n"
                + PRIMARY_EVIDENCE_TRUNCATION_MARKER
                + "\n"
                if truncated
                else text
            )
            entry.update({
                "original_char_count": len(text),
                "transmitted_char_count": len(transmitted),
                "original_decoded_text_sha256": _sha256_bytes(text.encode("utf-8")),
                "transmitted_content_sha256": _sha256_bytes(transmitted.encode("utf-8")),
                "truncated": truncated,
                "complete": not truncated,
            })
        entries.append(entry)

    incomplete = [entry for entry in entries if not entry.get("complete")]
    return {
        "schema_version": "primary_evidence_transmission_manifest.v1",
        "category": "raw_primary_evidence",
        "trust_boundary": "highest_priority_for_stage_claims",
        "file_count": len(entries),
        "complete_file_count": len(entries) - len(incomplete),
        "incomplete_file_count": len(incomplete),
        "all_primary_evidence_complete": not incomplete,
        "fail_on_primary_evidence_truncation": config.fail_on_primary_evidence_truncation,
        "files": entries,
    }


def enforce_primary_evidence_completeness(manifest: Mapping[str, Any]) -> None:
    """Fail before network transmission when any primary file is incomplete."""
    if bool(manifest.get("all_primary_evidence_complete")):
        return
    details: List[str] = []
    for entry in manifest.get("files", []) if isinstance(manifest.get("files"), list) else []:
        if isinstance(entry, Mapping) and not entry.get("complete"):
            reason = "missing" if not entry.get("exists") else "would be truncated"
            details.append(f"{entry.get('path')}: {reason}")
    raise PrimaryEvidenceCompletenessError(
        "Raw primary evidence is incomplete; API call blocked before transmission. "
        + "; ".join(details)
    )


def summarise_responses_api_input(api_input: Sequence[Mapping[str, Any]]) -> JsonDict:
    """Hash and count the exact Responses API input without storing extra copies."""
    input_texts: List[str] = []
    input_files: List[JsonDict] = []
    for message in api_input:
        content = message.get("content", []) if isinstance(message, Mapping) else []
        if not isinstance(content, list):
            continue
        for item in content:
            if not isinstance(item, Mapping):
                continue
            item_type = str(item.get("type") or "")
            if item_type == "input_text" and isinstance(item.get("text"), str):
                input_texts.append(str(item["text"]))
            elif item_type == "input_file":
                file_data = str(item.get("file_data") or "")
                input_files.append({
                    "filename": item.get("filename"),
                    "file_data_chars": len(file_data),
                    "file_data_sha256": _sha256_bytes(file_data.encode("utf-8")),
                })
    combined_text = "".join(input_texts)
    canonical = json.dumps(list(api_input), ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return {
        "schema_version": "responses_api_input_summary.v1",
        "input_text_block_count": len(input_texts),
        "input_text_chars": len(combined_text),
        "input_text_utf8_bytes": len(combined_text.encode("utf-8")),
        "input_text_sha256": _sha256_bytes(combined_text.encode("utf-8")),
        "input_file_count": len(input_files),
        "input_files": input_files,
        "canonical_input_sha256": _sha256_bytes(canonical.encode("utf-8")),
        "contains_primary_truncation_marker": PRIMARY_EVIDENCE_TRUNCATION_MARKER in combined_text,
    }


def build_primary_evidence_manifest(files: Sequence[PathLike]) -> JsonDict:
    entries = []
    for f in files:
        p = Path(f)
        if p.exists() and p.is_file():
            entries.append(path_metadata(p))
        else:
            entries.append({
                "path": str(p),
                "exists": False,
                "warning": "Primary evidence file was listed but not found.",
            })
    return {
        "files": entries,
        "evidence_priority": "primary",
        "note": "Primary evidence outranks deterministic advisory material.",
    }




def build_evidence_manifest(files: Sequence[PathLike], *, category: str, trust_boundary: str) -> JsonDict:
    entries = []
    for f in files:
        p = Path(f)
        if p.exists() and p.is_file():
            meta = path_metadata(p)
            meta["sha256"] = hashlib.sha256(p.read_bytes()).hexdigest()
            entries.append(meta)
        else:
            entries.append({"path": str(p), "exists": False, "warning": "Listed evidence file was not found."})
    return {
        "files": entries,
        "category": category,
        "trust_boundary": trust_boundary,
    }


def _json_context_block(title: str, value: Optional[JsonDict], *, max_chars: int) -> str:
    if value is None:
        return ""
    text = json.dumps(value, ensure_ascii=False, indent=2)
    if len(text) > max_chars:
        text = text[:max_chars] + "\n[TRUNCATED_BY_LLM_CLIENT_CONTEXT_LIMIT]"
    return f"\n\n===== {title} BEGIN =====\n{text}\n===== {title} END ====="


def inline_categorised_file_block(
    files: Sequence[PathLike], *, category: str, trust_boundary: str, max_chars: int
) -> str:
    blocks: List[str] = []
    for f in files:
        p = Path(f)
        if not p.exists() or not p.is_file():
            blocks.append(f"\n[{category.upper()}_FILE_MISSING] path: {p}\n")
            continue
        text = read_text_safely(p, max_chars=max_chars)
        blocks.append("\n".join([
            "",
            f"===== {category.upper()} FILE BEGIN =====",
            f"trust_boundary: {trust_boundary}",
            f"path: {p}",
            f"name: {p.name}",
            f"size_bytes: {p.stat().st_size}",
            "----- content begin -----",
            text,
            "----- content end -----",
            f"===== {category.upper()} FILE END =====",
            "",
        ]))
    return "\n".join(blocks)

def inline_text_evidence_block(files: Sequence[PathLike], *, max_chars: int) -> str:
    """
    Create a prompt block containing text/code evidence.

    This is useful when not using file attachments.
    """
    blocks = []
    for f in files:
        p = Path(f)
        if not p.exists() or not p.is_file():
            blocks.append(f"\n[PRIMARY_EVIDENCE_FILE_MISSING]\npath: {p}\n")
            continue

        text = read_text_safely(p, max_chars=max_chars)
        blocks.append(
            "\n".join([
                "",
                "===== PRIMARY EVIDENCE FILE BEGIN =====",
                f"path: {p}",
                f"name: {p.name}",
                f"size_bytes: {p.stat().st_size}",
                "----- content begin -----",
                text,
                "----- content end -----",
                "===== PRIMARY EVIDENCE FILE END =====",
                "",
            ])
        )
    return "\n".join(blocks)


def _compact_validation_error(previous_error: str, *, max_chars: int = 384) -> str:
    text = str(previous_error).strip().replace("\n\n", "\n")
    return text if len(text) <= max_chars else text[:max_chars] + "... [COMPACTED]"


def retry_request_size_limit(first_request_size: int, growth_percent: int) -> int:
    """Return the configured retry-size ceiling using exact integer arithmetic.

    ``growth_percent`` is deliberately user controlled.  Zero forbids request
    growth; values such as 100 or 150 permit 2x or 2.5x the first request.
    There is no hidden upper percentage ceiling in production code.
    """
    if isinstance(first_request_size, bool) or not isinstance(first_request_size, int) or first_request_size < 0:
        raise ValueError("first_request_size must be a non-negative integer")
    if isinstance(growth_percent, bool) or not isinstance(growth_percent, int) or growth_percent < 0:
        raise ValueError("max_retry_growth_percent must be a non-negative integer")
    return first_request_size + (first_request_size * growth_percent) // 100


def with_json_retry_instruction(prompt: str, schema: Optional[JsonDict], previous_error: str) -> str:
    """Append a bounded correction note without repeating the full schema."""
    required = []
    if isinstance(schema, Mapping):
        required = [str(x) for x in schema.get("required", []) if isinstance(x, str)]
    required_note = ", ".join(required[:8]) or "the API-supplied JSON schema"
    note = (
        "[JSON RETRY] Return one JSON object only. "
        f"Required fields include: {required_note}. "
        f"Correct this defect: {_compact_validation_error(previous_error)}"
    )
    # Cap added text relative to the original prompt.  The complete schema and
    # full error remain available in the API control and validation records.
    added_cap = max(128, min(640, max(1, len(prompt) // 50)))
    if len(note) > added_cap:
        note = note[: max(0, added_cap - 15)] + "... [COMPACTED]"
    return prompt.rstrip() + "\n\n" + note


# ---------------------------------------------------------------------------
# OpenAI Responses API adapter
# ---------------------------------------------------------------------------

def _response_data(response: Any) -> Any:
    if hasattr(response, "model_dump"):
        return response.model_dump()
    if hasattr(response, "to_dict"):
        return response.to_dict()
    return response

def _response_status(response: Any) -> tuple[str, str, Any]:
    data = _response_data(response)
    status = str(getattr(response, "status", "") or (data.get("status") if isinstance(data, Mapping) else "") or "")
    details = getattr(response, "incomplete_details", None)
    if details is None and isinstance(data, Mapping):
        details = data.get("incomplete_details")
    reason = ""
    if isinstance(details, Mapping):
        reason = str(details.get("reason") or details.get("type") or "")
    elif details is not None:
        reason = str(getattr(details, "reason", "") or details)
    return status.lower(), reason, details

def _response_to_text(response: Any) -> str:
    """Extract final output text; never reinterpret the provider envelope as stage JSON."""
    status, reason, details = _response_status(response)
    if status == "incomplete":
        raise IncompleteResponseError(status=status, reason=reason or "unspecified", details=details)

    text = getattr(response, "output_text", None)
    if isinstance(text, str) and text.strip():
        return text

    data = _response_data(response)
    found: List[str] = []
    def walk(x: Any) -> None:
        if isinstance(x, dict):
            if x.get("type") in {"output_text", "text"} and isinstance(x.get("text"), str):
                found.append(x["text"])
            for v in x.values():
                walk(v)
        elif isinstance(x, list):
            for item in x:
                walk(item)
    walk(data)
    if found:
        return "\n".join(found)
    raise JSONExtractionError("Provider response contained no final output text; envelope retained only as diagnostic evidence.")


def _response_to_serialisable(response: Any) -> Any:
    if hasattr(response, "model_dump"):
        return response.model_dump()
    if hasattr(response, "to_dict"):
        return response.to_dict()
    try:
        json.dumps(response)
        return response
    except Exception:
        # Preserve a diagnostic representation only.  Never reinterpret an
        # incomplete/non-text provider envelope as stage output.
        return {"repr": repr(response)}


def build_responses_api_input(
    prompt_text: str,
    primary_evidence_files: Sequence[PathLike],
    *,
    prior_authoritative_context_files: Sequence[PathLike] = (),
    trusted_deterministic_fact_files: Sequence[PathLike] = (),
    prior_authoritative_context_bundle: Optional[JsonDict] = None,
    trusted_deterministic_facts_bundle: Optional[JsonDict] = None,
    deterministic_reference_bundle: Optional[JsonDict] = None,
    config: LLMClientConfig,
) -> List[JsonDict]:
    """Build the exact Responses API input while preserving evidence categories."""
    hierarchy = """
[EVIDENCE HIERARCHY AND TRUST RULE]
1. Raw specification/source/build evidence and raw formal-tool output outrank all summaries.
2. Previous LLM-stage outputs are candidate context, not proof.
3. Trusted deterministic facts are authoritative only for measured/logged facts.
4. Deterministic references are fallible advisory hints. Verify them independently.
5. Unsupported inference is lowest priority. Mark uncertainty rather than inventing.
""".strip()

    context_text = prompt_text + "\n\n" + hierarchy
    context_text += _json_context_block(
        "PREVIOUS AUTHORITATIVE CANDIDATE-STAGE CONTEXT (NOT FORMAL TRUTH)",
        prior_authoritative_context_bundle,
        max_chars=config.max_inline_file_chars,
    )
    context_text += inline_categorised_file_block(
        prior_authoritative_context_files,
        category="previous_authoritative_candidate_context",
        trust_boundary="candidate_context_not_formal_truth",
        max_chars=config.max_inline_file_chars,
    )
    context_text += _json_context_block(
        "TRUSTED DETERMINISTIC MEASURED FACTS",
        trusted_deterministic_facts_bundle,
        max_chars=config.max_inline_file_chars,
    )
    context_text += inline_categorised_file_block(
        trusted_deterministic_fact_files,
        category="trusted_deterministic_measured_facts",
        trust_boundary="authoritative_for_logged_measured_facts_only",
        max_chars=config.max_inline_file_chars,
    )
    context_text += _json_context_block(
        "DETERMINISTIC ADVISORY REFERENCES (FALLIBLE; DO NOT COPY BLINDLY)",
        deterministic_reference_bundle,
        max_chars=config.max_inline_file_chars,
    )

    if not config.attach_files_as_base64:
        context_text += inline_categorised_file_block(
            primary_evidence_files,
            category="raw_primary_evidence",
            trust_boundary="highest_priority_for_stage_claims",
            max_chars=config.max_inline_file_chars,
        )
        return [{"role": "user", "content": [{"type": "input_text", "text": context_text}]}]

    content: List[JsonDict] = [{"type": "input_text", "text": context_text}]
    for f in primary_evidence_files:
        p = Path(f)
        if not p.exists() or not p.is_file():
            content.append({"type": "input_text", "text": f"[RAW_PRIMARY_EVIDENCE_FILE_MISSING] path: {p}"})
            continue
        raw = p.read_bytes()
        b64 = base64.b64encode(raw).decode("ascii")
        mime = mimetypes.guess_type(p.name)[0] or "application/octet-stream"
        content.append({
            "type": "input_file",
            "filename": p.name,
            "file_data": f"data:{mime};base64,{b64}",
        })
    return [{"role": "user", "content": content}]


# ---------------------------------------------------------------------------
# Main LLM client
# ---------------------------------------------------------------------------

class LLMClient:
    """
    Shared LLM client for all LLM-backed agents.
    """

    def __init__(self, config: Optional[Union[LLMClientConfig, Mapping[str, Any]]] = None):
        if config is None:
            self.config = LLMClientConfig()
        elif isinstance(config, LLMClientConfig):
            self.config = config
        else:
            self.config = LLMClientConfig.from_mapping(config)

    @classmethod
    def from_run_config(cls, run_config: Mapping[str, Any]) -> "LLMClient":
        """
        Build from a run config.

        Supports any of:
        - run_config["llm"]
        - run_config["llm_config"]
        - run_config["openai"]
        """
        cfg = dict(
            run_config.get("llm")
            or run_config.get("llm_config")
            or run_config.get("openai")
            or {}
        )
        protocol = run_config.get("experiment_protocol")
        if isinstance(protocol, Mapping):
            cfg["semantic_advisory_mode"] = str(protocol.get("semantic_advisory_mode") or "off")
            budget = protocol.get("prompt_budget")
            if isinstance(budget, Mapping):
                cfg["max_request_bytes"] = int(budget.get("max_request_bytes", 450_000))
                cfg["max_retry_growth_percent"] = int(budget.get("max_retry_growth_percent", 10))
                cfg["max_stage_input_tokens_estimate"] = int(budget.get("max_stage_input_tokens_estimate", 120_000))
                cfg["max_total_input_tokens_estimate"] = int(budget.get("max_total_input_tokens_estimate", 600_000))
        return cls(cfg)

    def run_stage(self, layout: Any, request: LLMStageRequest) -> LLMStageResult:
        """
        Execute one LLM-backed stage and write all records to the RunLayout folders.

        The layout object is expected to be compatible with agents.common.run_layout.RunLayout.
        """
        cfg = self.config
        stage = request.stage
        if cfg.semantic_advisory_mode not in {"off", "reference_only", "baseline_only"}:
            raise ValueError(f"Unsupported semantic_advisory_mode: {cfg.semantic_advisory_mode!r}")
        effective_deterministic_reference = (
            request.deterministic_reference_bundle
            if cfg.semantic_advisory_mode == "reference_only"
            else None
        )

        # ------------------------------------------------------------------
        # 1. Prompt package preservation
        # ------------------------------------------------------------------
        primary_evidence_manifest = build_evidence_manifest(
            request.primary_evidence_files,
            category="raw_primary_evidence",
            trust_boundary="highest_priority_for_stage_claims",
        )
        prior_context_manifest = build_evidence_manifest(
            request.prior_authoritative_context_files,
            category="previous_authoritative_candidate_context",
            trust_boundary="candidate_context_not_formal_truth",
        )
        trusted_facts_manifest = build_evidence_manifest(
            request.trusted_deterministic_fact_files,
            category="trusted_deterministic_measured_facts",
            trust_boundary="authoritative_for_logged_measured_facts_only",
        )

        prompt_outputs = layout.write_prompt_package(
            stage,
            prompt_text=request.prompt_text,
            prompt_filename=f"{stage}_prompt.txt" if not stage.startswith("agent") else f"{stage}.txt",
            metadata={
                "stage": stage,
                "mode": cfg.mode.value,
                "model": cfg.model,
                "created_utc": utc_now_iso(),
                "primary_evidence_file_count": len(request.primary_evidence_files),
                "prior_authoritative_context_file_count": len(request.prior_authoritative_context_files),
                "trusted_deterministic_fact_file_count": len(request.trusted_deterministic_fact_files),
                "prior_authoritative_context_provided": request.prior_authoritative_context_bundle is not None,
                "trusted_deterministic_facts_provided": request.trusted_deterministic_facts_bundle is not None,
                "semantic_advisory_mode": cfg.semantic_advisory_mode,
                "deterministic_reference_provided": effective_deterministic_reference is not None,
                "require_json_object": cfg.require_json_object,
                "schema_provided": request.json_schema is not None,
                "attach_files_as_base64": cfg.attach_files_as_base64,
                "extra": request.extra_prompt_metadata,
            },
            deterministic_reference_bundle=effective_deterministic_reference,
            prior_authoritative_context_bundle=request.prior_authoritative_context_bundle,
            trusted_deterministic_facts_bundle=request.trusted_deterministic_facts_bundle,
            primary_evidence_manifest=primary_evidence_manifest,
            prior_authoritative_context_manifest=prior_context_manifest,
            trusted_deterministic_facts_manifest=trusted_facts_manifest,
        )

        prompt_path = str(prompt_outputs.get("prompt")) if prompt_outputs.get("prompt") else None
        metadata_path = str(prompt_outputs.get("prompt_metadata")) if prompt_outputs.get("prompt_metadata") else None

        # ------------------------------------------------------------------
        # 2. Disabled mode
        # ------------------------------------------------------------------
        if cfg.mode == LLMMode.DISABLED:
            validation = {
                "schema_version": "llm_stage_validation.v1",
                "created_utc": utc_now_iso(),
                "stage": stage,
                "valid": False,
                "llm_call_executed": False,
                "mode": cfg.mode.value,
                "reason": "LLM mode is disabled. No authoritative LLM output was generated.",
            }
            validation_path = layout.write_validation_json(
                stage,
                "llm_call_validation.json",
                validation,
            )

            return LLMStageResult(
                stage=stage,
                mode=cfg.mode.value,
                success=False,
                llm_call_executed=False,
                output_path=None,
                raw_response_path=None,
                validation_path=str(validation_path),
                prompt_path=prompt_path,
                metadata_path=metadata_path,
                attempts=0,
                error="LLM disabled",
                validation=validation,
            )

        # ------------------------------------------------------------------
        # 3. Mock mode
        # ------------------------------------------------------------------
        if cfg.mode == LLMMode.MOCK:
            mock_content = request.mock_response_content or self._schema_shaped_mock(
                stage=stage,
                schema=request.json_schema,
            )
            output_path = layout.write_llm_authoritative_json(
                stage,
                request.output_filename,
                mock_content,
            )
            raw_response_path = layout.llm_authoritative_dir(stage) / "api_responses" / "attempt_01_response.json"
            atomic_write_json(raw_response_path, {
                "schema_version": "raw_llm_response.v1",
                "created_utc": utc_now_iso(),
                "mode": cfg.mode.value,
                "llm_call_executed": False,
                "mock": True,
                "content": mock_content,
            })

            schema_result = validate_json_schema(mock_content, request.json_schema)
            validation = {
                "schema_version": "llm_stage_validation.v1",
                "created_utc": utc_now_iso(),
                "stage": stage,
                "mode": cfg.mode.value,
                "llm_call_executed": False,
                "valid": bool(schema_result.get("valid")),
                "schema_validation": schema_result,
                "note": "Mock mode validates pipeline wiring only. It is not an API-backed result.",
            }
            validation_path = layout.write_validation_json(stage, "llm_call_validation.json", validation)

            return LLMStageResult(
                stage=stage,
                mode=cfg.mode.value,
                success=bool(schema_result.get("valid")),
                llm_call_executed=False,
                output_path=str(output_path),
                raw_response_path=str(raw_response_path),
                validation_path=str(validation_path),
                prompt_path=prompt_path,
                metadata_path=metadata_path,
                attempts=1,
                parsed_json=mock_content,
                validation=validation,
            )

        # ------------------------------------------------------------------
        # 4. Real API mode
        # ------------------------------------------------------------------
        if cfg.mode == LLMMode.REAL:
            return self._run_stage_real(layout, request, prompt_path, metadata_path)

        raise ValueError(f"Unhandled LLM mode: {cfg.mode}")

    # ----------------------------------------------------------------------
    # Real API implementation
    # ----------------------------------------------------------------------

    def _nonexecuted_real_failure(
        self,
        layout: Any,
        request: LLMStageRequest,
        prompt_path: Optional[str],
        metadata_path: Optional[str],
        *,
        error: str,
        result_error: Optional[str] = None,
        extra_validation: Optional[JsonDict] = None,
    ) -> LLMStageResult:
        cfg = self.config
        validation: JsonDict = {
            "schema_version": "llm_stage_validation.v1",
            "created_utc": utc_now_iso(),
            "stage": request.stage,
            "mode": cfg.mode.value,
            "valid": False,
            "llm_call_executed": False,
            "error": error,
        }
        if extra_validation:
            validation.update(extra_validation)
        validation_path = layout.write_validation_json(
            request.stage, "llm_call_validation.json", validation
        )
        return LLMStageResult(
            stage=request.stage,
            mode=cfg.mode.value,
            success=False,
            llm_call_executed=False,
            output_path=None,
            raw_response_path=None,
            validation_path=str(validation_path),
            prompt_path=prompt_path,
            metadata_path=metadata_path,
            attempts=0,
            error=result_error or error,
            validation=validation,
        )

    def _run_stage_real(
        self,
        layout: Any,
        request: LLMStageRequest,
        prompt_path: Optional[str],
        metadata_path: Optional[str],
    ) -> LLMStageResult:
        cfg = self.config
        stage = request.stage
        effective_deterministic_reference = (
            request.deterministic_reference_bundle
            if cfg.semantic_advisory_mode == "reference_only"
            else None
        )

        api_key = os.environ.get(cfg.api_key_env)
        if not api_key:
            return self._nonexecuted_real_failure(
                layout, request, prompt_path, metadata_path,
                error=f"Missing API key environment variable: {cfg.api_key_env}",
            )

        primary_transmission_manifest = build_primary_evidence_transmission_manifest(
            request.primary_evidence_files,
            config=cfg,
        )
        primary_transmission_path = layout.prompt_package_dir(stage) / "primary_evidence_transmission_manifest.json"
        atomic_write_json(primary_transmission_path, primary_transmission_manifest)

        if cfg.fail_on_primary_evidence_truncation and not primary_transmission_manifest.get(
            "all_primary_evidence_complete", False
        ):
            error = (
                "Raw primary evidence completeness check failed; the real API call was not sent. "
                "Increase the approved max_inline_file_chars operational override, narrow the configured "
                "primary evidence deliberately, or use an exact attachment transport."
            )
            return self._nonexecuted_real_failure(
                layout, request, prompt_path, metadata_path, error=error,
                extra_validation={
                    "primary_evidence_transmission_manifest": str(primary_transmission_path),
                    "primary_evidence_complete": False,
                },
            )

        if OpenAI is None:
            return self._nonexecuted_real_failure(
                layout, request, prompt_path, metadata_path,
                error="OpenAI Python package is not installed. Install with: pip install openai",
                result_error="OpenAI package not installed",
            )

        schema_preflight = validate_openai_structured_output_schema(request.json_schema)
        if not schema_preflight.get("valid", False):
            diagnostic = "; ".join(str(item) for item in schema_preflight.get("errors", []))
            return self._nonexecuted_real_failure(
                layout, request, prompt_path, metadata_path,
                error="OpenAI Structured Outputs schema preflight failed: " + diagnostic,
                result_error="Invalid structured-output schema",
                extra_validation={"structured_output_schema_preflight": schema_preflight},
            )

        client = OpenAI(**build_openai_client_kwargs(cfg, api_key))

        attempts = 0
        last_error: Optional[str] = None
        current_prompt = request.prompt_text
        raw_response_path: Optional[Path] = None
        first_request_size: Optional[int] = None
        previous_request_size: Optional[int] = None
        retry_category: Optional[str] = None
        retry_history: List[JsonDict] = []
        configured_retry_policy = retry_policy_record(cfg)

        for attempt_idx in range(max_configured_retries(cfg) + 1):
            attempts = attempt_idx + 1
            try:
                api_input = build_responses_api_input(
                    current_prompt,
                    request.primary_evidence_files,
                    prior_authoritative_context_files=request.prior_authoritative_context_files,
                    trusted_deterministic_fact_files=request.trusted_deterministic_fact_files,
                    prior_authoritative_context_bundle=request.prior_authoritative_context_bundle,
                    trusted_deterministic_facts_bundle=request.trusted_deterministic_facts_bundle,
                    deterministic_reference_bundle=effective_deterministic_reference,
                    config=cfg,
                )

                input_summary = summarise_responses_api_input(api_input)
                if input_summary.get("contains_primary_truncation_marker"):
                    raise PrimaryEvidenceCompletenessError(
                        "Primary-evidence truncation marker reached the exact API input; call blocked."
                    )

                request_payload: JsonDict = {
                    "model": cfg.model,
                    "input": api_input,
                }
                request_payload.update(build_responses_control_payload(cfg))

                # Merge verbosity with the stage's strict structured-output format.
                # Never replace the json_schema object when verbosity is configured.
                text_options: JsonDict = dict(request_payload.get("text") or {})
                if request.json_schema is not None:
                    text_options["format"] = {
                        "type": "json_schema",
                        "name": f"{stage}_schema",
                        "schema": request.json_schema,
                        "strict": True,
                    }
                elif cfg.require_json_object:
                    text_options["format"] = {
                        "type": "json_object",
                    }
                if text_options:
                    request_payload["text"] = text_options

                # Preserve the exact redacted payload sent on every attempt.
                redacted_payload = redact_secrets(request_payload) if cfg.redact_secrets_in_logs else request_payload
                payload_bytes = json.dumps(redacted_payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
                request_size = len(payload_bytes)
                if request_size > cfg.max_request_bytes:
                    raise ValueError(
                        f"request_budget_exceeded: {request_size} bytes > {cfg.max_request_bytes} bytes"
                    )
                if first_request_size is None:
                    first_request_size = request_size
                else:
                    allowed = retry_request_size_limit(first_request_size, cfg.max_retry_growth_percent)
                    if request_size > allowed:
                        raise ValueError(
                            f"retry_request_growth_exceeded: {request_size} bytes > {allowed} bytes "
                            f"({cfg.max_retry_growth_percent}% over first request)"
                        )
                estimated_input_tokens = max(1, (request_size + 3) // 4)
                if estimated_input_tokens > cfg.max_stage_input_tokens_estimate:
                    raise ValueError(
                        "stage_input_token_budget_exceeded: "
                        f"{estimated_input_tokens} estimated tokens > {cfg.max_stage_input_tokens_estimate}"
                    )
                budget_ledger_path = reserve_run_input_budget(
                    layout,
                    stage=stage,
                    attempt=attempts,
                    request_bytes=request_size,
                    estimated_input_tokens=estimated_input_tokens,
                    max_total_input_tokens_estimate=cfg.max_total_input_tokens_estimate,
                )
                request_snapshot_path = layout.prompt_package_dir(stage) / "api_requests" / f"attempt_{attempts:02d}_request.json"
                atomic_write_json(request_snapshot_path, {
                    "schema_version": "exact_api_request_snapshot.v1",
                    "created_utc": utc_now_iso(),
                    "stage": stage,
                    "attempt": attempts,
                    "retry": attempts > 1,
                    "retry_category": retry_category if attempts > 1 else None,
                    "retry_reason": last_error if attempts > 1 else None,
                    "retry_policy": configured_retry_policy,
                    "previous_request_size_bytes": previous_request_size,
                    "request_sha256": hashlib.sha256(payload_bytes).hexdigest(),
                    "prompt_sha256": hashlib.sha256(current_prompt.encode("utf-8")).hexdigest(),
                    "request_size_bytes": request_size,
                    "request_growth_bytes": (request_size - previous_request_size) if previous_request_size is not None else 0,
                    "estimated_input_tokens": estimated_input_tokens,
                    "runtime_input_budget_ledger": str(budget_ledger_path),
                    "api_payload": redacted_payload,
                    "primary_evidence_transmission": {
                        "manifest_path": str(primary_transmission_path),
                        "all_primary_evidence_complete": primary_transmission_manifest.get(
                            "all_primary_evidence_complete", False
                        ),
                    },
                    "exact_input_summary": input_summary,
                    "evidence_categories": {
                        "raw_primary_evidence_files": [str(Path(x)) for x in request.primary_evidence_files],
                        "previous_authoritative_context_files": [str(Path(x)) for x in request.prior_authoritative_context_files],
                        "trusted_deterministic_fact_files": [str(Path(x)) for x in request.trusted_deterministic_fact_files],
                        "previous_authoritative_context_bundle_present": request.prior_authoritative_context_bundle is not None,
                        "trusted_deterministic_facts_bundle_present": request.trusted_deterministic_facts_bundle is not None,
                        "semantic_advisory_mode": cfg.semantic_advisory_mode,
                        "deterministic_advisory_bundle_present": effective_deterministic_reference is not None,
                    },
                    "secret_policy": "API key is supplied through the client constructor and is never stored in this payload snapshot.",
                })

                previous_request_size = request_size
                started = time.time()
                response = client.responses.create(**request_payload)
                elapsed = time.time() - started

                response_serialisable = _response_to_serialisable(response)
                status, incomplete_reason, incomplete_details = _response_status(response)
                response_text = ""
                response_error: Optional[str] = None
                try:
                    response_text = _response_to_text(response)
                except IncompleteResponseError as exc:
                    response_error = f"{type(exc).__name__}: {exc}"
                except JSONExtractionError as exc:
                    response_error = f"{type(exc).__name__}: {exc}"

                raw_response_path = layout.llm_authoritative_dir(stage) / "api_responses" / f"attempt_{attempts:02d}_response.json"
                raw_record = {
                    "schema_version": "raw_llm_response.v2.per_attempt",
                    "created_utc": utc_now_iso(),
                    "mode": cfg.mode.value,
                    "llm_call_executed": True,
                    "model": cfg.model,
                    "attempt": attempts,
                    "elapsed_seconds": elapsed,
                    "request_snapshot_path": str(request_snapshot_path),
                    "request_sha256": hashlib.sha256(payload_bytes).hexdigest(),
                    "response_id": getattr(response, "id", None),
                    "usage": _normalise_usage(getattr(response, "usage", None)),
                    "exact_input_summary": input_summary,
                    "primary_evidence_transmission_manifest": str(primary_transmission_path),
                    "provider_status": status,
                    "incomplete_reason": incomplete_reason or None,
                    "incomplete_details": incomplete_details,
                    "response_text": response_text,
                    "response_error": response_error,
                    "response_object": response_serialisable,
                }
                if cfg.redact_secrets_in_logs:
                    raw_record = redact_secrets(raw_record)
                atomic_write_json(raw_response_path, raw_record)

                if response_error:
                    if status == "incomplete":
                        raise IncompleteResponseError(
                            status=status, reason=incomplete_reason or "unspecified", details=incomplete_details
                        )
                    raise JSONExtractionError(response_error)

                parsed = extract_json_object(
                    response_text, strict=cfg.strict_json_object_only
                )
                schema_result = validate_json_schema(
                    parsed,
                    request.json_schema,
                    allow_minimal_fallback=cfg.allow_minimal_schema_validation,
                )

                if not schema_result.get("valid", False):
                    last_error = "Schema validation failed: " + json.dumps(schema_result, ensure_ascii=False)
                    if retry_is_allowed(cfg, "schema_or_json", attempt_idx):
                        retry_category = "schema_or_json"
                        retry_history.append({
                            "attempt": attempts, "category": retry_category,
                            "diagnostic": last_error, "request_size_bytes": request_size,
                            "model": cfg.model,
                        })
                        current_prompt = with_json_retry_instruction(
                            request.prompt_text, request.json_schema, last_error
                        )
                        time.sleep(cfg.retry_sleep_seconds)
                        continue

                    validation = {
                        "schema_version": "llm_stage_validation.v1",
                        "created_utc": utc_now_iso(),
                        "stage": stage,
                        "mode": cfg.mode.value,
                        "llm_call_executed": True,
                        "valid": False,
                        "attempts": attempts,
                        "retry_policy": configured_retry_policy,
                        "retry_history": retry_history,
                        "schema_validation": schema_result,
                        "error": last_error,
                    }
                    validation_path = layout.write_validation_json(stage, "llm_call_validation.json", validation)

                    if request.allow_invalid_json_save:
                        invalid_path = layout.llm_authoritative_dir(stage) / ("invalid_" + request.output_filename)
                        atomic_write_json(invalid_path, parsed)

                    return LLMStageResult(
                        stage=stage,
                        mode=cfg.mode.value,
                        success=False,
                        llm_call_executed=True,
                        output_path=None,
                        raw_response_path=str(raw_response_path),
                        validation_path=str(validation_path),
                        prompt_path=prompt_path,
                        metadata_path=metadata_path,
                        attempts=attempts,
                        error=last_error,
                        parsed_json=parsed,
                        validation=validation,
                    )

                output_path = layout.write_llm_authoritative_json(
                    stage,
                    request.output_filename,
                    parsed,
                )

                validation = {
                    "schema_version": "llm_stage_validation.v1",
                    "created_utc": utc_now_iso(),
                    "stage": stage,
                    "mode": cfg.mode.value,
                    "llm_call_executed": True,
                    "valid": True,
                    "attempts": attempts,
                    "retry_policy": configured_retry_policy,
                    "retry_history": retry_history,
                    "schema_validation": schema_result,
                    "model": cfg.model,
                    "elapsed_seconds_last_attempt": elapsed,
                    "final_request_snapshot_path": str(request_snapshot_path),
                    "final_response_path": str(raw_response_path),
                    "request_sha256": hashlib.sha256(payload_bytes).hexdigest(),
                    "primary_evidence_complete": True,
                    "primary_evidence_transmission_manifest": str(primary_transmission_path),
                    "exact_input_summary": input_summary,
                    "provider_usage": _normalise_usage(getattr(response, "usage", None)),
                }
                validation_path = layout.write_validation_json(stage, "llm_call_validation.json", validation)

                return LLMStageResult(
                    stage=stage,
                    mode=cfg.mode.value,
                    success=True,
                    llm_call_executed=True,
                    output_path=str(output_path),
                    raw_response_path=str(raw_response_path),
                    validation_path=str(validation_path),
                    prompt_path=prompt_path,
                    metadata_path=metadata_path,
                    attempts=attempts,
                    parsed_json=parsed,
                    validation=validation,
                )

            except Exception as exc:
                last_error = f"{type(exc).__name__}: {exc}"
                error_record = {
                    "schema_version": "llm_call_error.v1",
                    "created_utc": utc_now_iso(),
                    "stage": stage,
                    "mode": cfg.mode.value,
                    "attempt": attempts,
                    "error": last_error,
                    "traceback": traceback.format_exc(),
                }
                if cfg.redact_secrets_in_logs:
                    error_record = redact_secrets(error_record)
                layout.write_validation_json(stage, f"llm_call_error_attempt_{attempts:02d}.json", error_record)

                non_retryable_input_error = any(
                    marker in last_error.lower()
                    for marker in (
                        "context_length_exceeded", "maximum context length",
                        "input is too long", "too many tokens",
                        "primaryevidencecompletenesserror", "request_budget_exceeded",
                        "retry_request_growth_exceeded", "stage_input_token_budget_exceeded",
                        "run_input_token_budget_exceeded",
                        "invalid_json_schema", "invalid schema for response_format",
                        "structured outputs schema preflight failed",
                    )
                )
                category = classify_retry_category(exc)
                if not non_retryable_input_error and retry_is_allowed(cfg, category, attempt_idx):
                    retry_category = category
                    retry_history.append({
                        "attempt": attempts, "category": category,
                        "diagnostic": last_error,
                        "request_size_bytes": previous_request_size,
                        "model": cfg.model,
                    })
                    current_prompt = with_json_retry_instruction(
                        request.prompt_text, request.json_schema, last_error
                    )
                    time.sleep(cfg.retry_sleep_seconds)
                    continue
                break

        validation = {
            "schema_version": "llm_stage_validation.v1",
            "created_utc": utc_now_iso(),
            "stage": stage,
            "mode": cfg.mode.value,
            "llm_call_executed": True,
            "valid": False,
            "attempts": attempts,
            "retry_policy": configured_retry_policy,
            "retry_history": retry_history,
            "error": last_error or "Unknown LLM failure",
        }
        validation_path = layout.write_validation_json(stage, "llm_call_validation.json", validation)

        return LLMStageResult(
            stage=stage,
            mode=cfg.mode.value,
            success=False,
            llm_call_executed=True,
            output_path=None,
            raw_response_path=str(raw_response_path) if raw_response_path else None,
            validation_path=str(validation_path),
            prompt_path=prompt_path,
            metadata_path=metadata_path,
            attempts=attempts,
            error=last_error,
            validation=validation,
        )

    # ----------------------------------------------------------------------
    # Mock generation
    # ----------------------------------------------------------------------

    def _schema_shaped_mock(self, *, stage: str, schema: Optional[JsonDict]) -> JsonDict:
        """
        Generate a simple schema-shaped mock object.

        This is intentionally marked as mock output and must not be treated as
        API-backed evidence.
        """
        if schema is None:
            return {
                "stage": stage,
                "mock": True,
                "status": "mock_output_without_schema",
                "claims": [],
                "limitations": [
                    "This is mock output for pipeline testing only.",
                    "No LLM/API call was executed.",
                ],
            }

        properties = schema.get("properties", {})
        required = schema.get("required", [])

        def mock_for_schema(s: Any, name: str = "field") -> Any:
            if not isinstance(s, dict):
                return None
            t = s.get("type")
            if isinstance(t, list):
                # Pick the first non-null type.
                t = next((x for x in t if x != "null"), t[0] if t else "string")

            if t == "string":
                return f"mock_{name}"
            if t == "integer":
                return 0
            if t == "number":
                return 0.0
            if t == "boolean":
                return False
            if t == "array":
                item_schema = s.get("items", {"type": "string"})
                return [mock_for_schema(item_schema, name=f"{name}_item")]
            if t == "object" or "properties" in s:
                return {
                    k: mock_for_schema(v, name=k)
                    for k, v in s.get("properties", {}).items()
                    if k in s.get("required", s.get("properties", {}).keys())
                }
            return f"mock_{name}"

        result = {
            k: mock_for_schema(properties.get(k, {"type": "string"}), name=k)
            for k in required
        }

        # Add standard fields if schema does not require them.
        result.setdefault("stage", stage)
        result.setdefault("mock", True)
        result.setdefault("llm_call_executed", False)
        result.setdefault("limitations", ["Mock output only; no API call was executed."])
        return result


# ---------------------------------------------------------------------------
# Convenience factory
# ---------------------------------------------------------------------------

def make_llm_client(run_config: Optional[Mapping[str, Any]] = None) -> LLMClient:
    """
    Convenience factory used by agents.
    """
    if run_config:
        return LLMClient.from_run_config(run_config)
    return LLMClient()


__all__ = [
    "LLMClient",
    "LLMClientConfig",
    "LLMMode",
    "LLMStageRequest",
    "LLMStageResult",
    "IncompleteResponseError",
    "reserve_run_input_budget",
    "retry_request_size_limit",
    "make_llm_client",
    "extract_json_object",
    "validate_json_schema",
    "build_primary_evidence_manifest",
    "build_evidence_manifest",
    "build_openai_client_kwargs",
    "build_responses_control_payload",
    "build_responses_api_input",
    "build_primary_evidence_transmission_manifest",
    "enforce_primary_evidence_completeness",
    "summarise_responses_api_input",
    "PrimaryEvidenceCompletenessError",
    "inline_text_evidence_block",
    "inline_categorised_file_block",
]
