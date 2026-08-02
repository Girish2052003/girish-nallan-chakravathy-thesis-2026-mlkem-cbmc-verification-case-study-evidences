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


def redact_secrets(value: Any) -> Any:
    """
    Recursively redact likely secret values before writing logs.
    """
    if isinstance(value, dict):
        redacted = {}
        for k, v in value.items():
            key = str(k).lower()
            if any(x in key for x in ["api_key", "secret", "token", "authorization", "password"]):
                redacted[k] = "[REDACTED]"
            else:
                redacted[k] = redact_secrets(v)
        return redacted
    if isinstance(value, list):
        return [redact_secrets(v) for v in value]
    if isinstance(value, str):
        # Redact obvious API-key looking strings without being OpenAI-specific only.
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

    # Responses API settings
    temperature: Optional[float] = None
    max_output_tokens: Optional[int] = None

    # Retry/validation behaviour
    max_retries: int = 2
    retry_sleep_seconds: float = 2.0
    require_json_object: bool = True
    validate_with_jsonschema: bool = True

    # File/evidence behaviour
    max_inline_file_chars: int = 120_000
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

        return cls(
            mode=LLMMode(mode_value),
            model=str(data.get("model", cls.model)),
            api_key_env=str(data.get("api_key_env", cls.api_key_env)),
            temperature=data.get("temperature", cls.temperature),
            max_output_tokens=data.get("max_output_tokens", cls.max_output_tokens),
            max_retries=int(data.get("max_retries", cls.max_retries)),
            retry_sleep_seconds=float(data.get("retry_sleep_seconds", cls.retry_sleep_seconds)),
            require_json_object=bool(data.get("require_json_object", cls.require_json_object)),
            validate_with_jsonschema=bool(data.get("validate_with_jsonschema", cls.validate_with_jsonschema)),
            max_inline_file_chars=int(data.get("max_inline_file_chars", cls.max_inline_file_chars)),
            attach_files_as_base64=bool(data.get("attach_files_as_base64", cls.attach_files_as_base64)),
            save_raw_response=bool(data.get("save_raw_response", cls.save_raw_response)),
            save_prompt_text=bool(data.get("save_prompt_text", cls.save_prompt_text)),
            save_call_metadata=bool(data.get("save_call_metadata", cls.save_call_metadata)),
            redact_secrets_in_logs=bool(data.get("redact_secrets_in_logs", cls.redact_secrets_in_logs)),
        )


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


# ---------------------------------------------------------------------------
# JSON extraction / validation
# ---------------------------------------------------------------------------

class JSONExtractionError(ValueError):
    pass


class SchemaValidationError(ValueError):
    pass


def extract_json_object(text: str) -> JsonDict:
    """
    Extract a JSON object from an LLM response.

    Accepts:
    - pure JSON object
    - fenced ```json blocks
    - text with the first parseable JSON object embedded

    Returns a dict only.
    """
    stripped = text.strip()

    # Direct JSON.
    try:
        data = json.loads(stripped)
        if isinstance(data, dict):
            return data
        raise JSONExtractionError(f"Expected JSON object, got {type(data).__name__}")
    except json.JSONDecodeError:
        pass

    # Fenced code block.
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


def validate_json_schema(instance: JsonDict, schema: Optional[JsonDict]) -> JsonDict:
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

    # Minimal fallback: only check top-level required fields.
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
        "warning": "Install jsonschema for full validation: pip install jsonschema",
    }


# ---------------------------------------------------------------------------
# Prompt building helpers
# ---------------------------------------------------------------------------

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


def with_json_retry_instruction(prompt: str, schema: Optional[JsonDict], previous_error: str) -> str:
    schema_text = json.dumps(schema, indent=2, ensure_ascii=False) if schema else "{}"
    return f"""
{prompt}

[RETRY INSTRUCTION]
Your previous response could not be parsed or validated as the required JSON object.

Validation/parsing error:
{previous_error}

Return only a valid JSON object matching the required schema below. Do not include Markdown fences or explanatory prose.

Schema:
{schema_text}
""".strip()


# ---------------------------------------------------------------------------
# OpenAI Responses API adapter
# ---------------------------------------------------------------------------

def _response_to_text(response: Any) -> str:
    """
    Extract text from an OpenAI Responses API object.

    The SDK shape can evolve, so this tries several safe patterns.
    """
    # Newer SDKs expose output_text.
    text = getattr(response, "output_text", None)
    if isinstance(text, str) and text.strip():
        return text

    # Fallback: dict/model dump.
    if hasattr(response, "model_dump"):
        data = response.model_dump()
    elif hasattr(response, "to_dict"):
        data = response.to_dict()
    else:
        data = response

    # Search likely text fields recursively.
    found: List[str] = []

    def walk(x: Any) -> None:
        if isinstance(x, dict):
            # Common content shape.
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

    # Last resort: dump the object. This may be useful for debugging but likely not JSON.
    try:
        return json.dumps(data, ensure_ascii=False)
    except Exception:
        return str(response)


def _response_to_serialisable(response: Any) -> Any:
    if hasattr(response, "model_dump"):
        return response.model_dump()
    if hasattr(response, "to_dict"):
        return response.to_dict()
    try:
        json.dumps(response)
        return response
    except Exception:
        return {"repr": repr(response), "text": _response_to_text(response)}


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
        cfg = (
            run_config.get("llm")
            or run_config.get("llm_config")
            or run_config.get("openai")
            or {}
        )
        return cls(cfg)

    def run_stage(self, layout: Any, request: LLMStageRequest) -> LLMStageResult:
        """
        Execute one LLM-backed stage and write all records to the RunLayout folders.

        The layout object is expected to be compatible with agents.common.run_layout.RunLayout.
        """
        cfg = self.config
        stage = request.stage

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
                "deterministic_reference_provided": request.deterministic_reference_bundle is not None,
                "require_json_object": cfg.require_json_object,
                "schema_provided": request.json_schema is not None,
                "attach_files_as_base64": cfg.attach_files_as_base64,
                "extra": request.extra_prompt_metadata,
            },
            deterministic_reference_bundle=request.deterministic_reference_bundle,
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

    def _run_stage_real(
        self,
        layout: Any,
        request: LLMStageRequest,
        prompt_path: Optional[str],
        metadata_path: Optional[str],
    ) -> LLMStageResult:
        cfg = self.config
        stage = request.stage

        api_key = os.environ.get(cfg.api_key_env)
        if not api_key:
            validation = {
                "schema_version": "llm_stage_validation.v1",
                "created_utc": utc_now_iso(),
                "stage": stage,
                "mode": cfg.mode.value,
                "valid": False,
                "llm_call_executed": False,
                "error": f"Missing API key environment variable: {cfg.api_key_env}",
            }
            validation_path = layout.write_validation_json(stage, "llm_call_validation.json", validation)
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
                error=f"Missing API key environment variable: {cfg.api_key_env}",
                validation=validation,
            )

        if OpenAI is None:
            validation = {
                "schema_version": "llm_stage_validation.v1",
                "created_utc": utc_now_iso(),
                "stage": stage,
                "mode": cfg.mode.value,
                "valid": False,
                "llm_call_executed": False,
                "error": "OpenAI Python package is not installed. Install with: pip install openai",
            }
            validation_path = layout.write_validation_json(stage, "llm_call_validation.json", validation)
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
                error="OpenAI package not installed",
                validation=validation,
            )

        client = OpenAI(api_key=api_key)

        attempts = 0
        last_error: Optional[str] = None
        current_prompt = request.prompt_text
        raw_response_path: Optional[Path] = None

        for attempt_idx in range(cfg.max_retries + 1):
            attempts = attempt_idx + 1
            try:
                api_input = build_responses_api_input(
                    current_prompt,
                    request.primary_evidence_files,
                    prior_authoritative_context_files=request.prior_authoritative_context_files,
                    trusted_deterministic_fact_files=request.trusted_deterministic_fact_files,
                    prior_authoritative_context_bundle=request.prior_authoritative_context_bundle,
                    trusted_deterministic_facts_bundle=request.trusted_deterministic_facts_bundle,
                    deterministic_reference_bundle=request.deterministic_reference_bundle,
                    config=cfg,
                )

                request_payload: JsonDict = {
                    "model": cfg.model,
                    "input": api_input,
                    "store": False,
                }

                if cfg.temperature is not None:
                    request_payload["temperature"] = cfg.temperature
                if cfg.max_output_tokens is not None:
                    request_payload["max_output_tokens"] = cfg.max_output_tokens

                # Ask for JSON when possible, but still parse defensively.
                if request.json_schema is not None:
                    request_payload["text"] = {
                        "format": {
                            "type": "json_schema",
                            "name": f"{stage}_schema",
                            "schema": request.json_schema,
                            "strict": True,
                        }
                    }
                elif cfg.require_json_object:
                    request_payload["text"] = {
                        "format": {
                            "type": "json_object",
                        }
                    }

                # Preserve the exact redacted payload sent on every attempt.
                redacted_payload = redact_secrets(request_payload) if cfg.redact_secrets_in_logs else request_payload
                payload_bytes = json.dumps(redacted_payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
                request_snapshot_path = layout.prompt_package_dir(stage) / "api_requests" / f"attempt_{attempts:02d}_request.json"
                atomic_write_json(request_snapshot_path, {
                    "schema_version": "exact_api_request_snapshot.v1",
                    "created_utc": utc_now_iso(),
                    "stage": stage,
                    "attempt": attempts,
                    "retry": attempts > 1,
                    "retry_reason": last_error if attempts > 1 else None,
                    "request_sha256": hashlib.sha256(payload_bytes).hexdigest(),
                    "api_payload": redacted_payload,
                    "evidence_categories": {
                        "raw_primary_evidence_files": [str(Path(x)) for x in request.primary_evidence_files],
                        "previous_authoritative_context_files": [str(Path(x)) for x in request.prior_authoritative_context_files],
                        "trusted_deterministic_fact_files": [str(Path(x)) for x in request.trusted_deterministic_fact_files],
                        "previous_authoritative_context_bundle_present": request.prior_authoritative_context_bundle is not None,
                        "trusted_deterministic_facts_bundle_present": request.trusted_deterministic_facts_bundle is not None,
                        "deterministic_advisory_bundle_present": request.deterministic_reference_bundle is not None,
                    },
                    "secret_policy": "API key is supplied through the client constructor and is never stored in this payload snapshot.",
                })

                started = time.time()
                response = client.responses.create(**request_payload)
                elapsed = time.time() - started

                response_text = _response_to_text(response)
                response_serialisable = _response_to_serialisable(response)

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
                    "usage": getattr(response, "usage", None).model_dump() if hasattr(getattr(response, "usage", None), "model_dump") else getattr(response, "usage", None),
                    "response_text": response_text,
                    "response_object": response_serialisable,
                }
                if cfg.redact_secrets_in_logs:
                    raw_record = redact_secrets(raw_record)
                atomic_write_json(raw_response_path, raw_record)

                parsed = extract_json_object(response_text)
                schema_result = validate_json_schema(parsed, request.json_schema)

                if not schema_result.get("valid", False):
                    last_error = "Schema validation failed: " + json.dumps(schema_result, ensure_ascii=False)
                    if attempt_idx < cfg.max_retries:
                        current_prompt = with_json_retry_instruction(
                            request.prompt_text,
                            request.json_schema,
                            last_error,
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
                    "schema_validation": schema_result,
                    "model": cfg.model,
                    "elapsed_seconds_last_attempt": elapsed,
                    "final_request_snapshot_path": str(request_snapshot_path),
                    "final_response_path": str(raw_response_path),
                    "request_sha256": hashlib.sha256(payload_bytes).hexdigest(),
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

                if attempt_idx < cfg.max_retries:
                    current_prompt = with_json_retry_instruction(
                        request.prompt_text,
                        request.json_schema,
                        last_error,
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
    "make_llm_client",
    "extract_json_object",
    "validate_json_schema",
    "build_primary_evidence_manifest",
    "build_evidence_manifest",
    "inline_text_evidence_block",
    "inline_categorised_file_block",
]
