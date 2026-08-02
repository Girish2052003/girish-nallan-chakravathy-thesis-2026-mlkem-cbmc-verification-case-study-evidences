"""Shared evidence-category helpers for LLM-backed workflow stages.

The categories are deliberately distinct so the exact API request preserves the
architecture's evidence hierarchy:

1. raw primary evidence (specification, implementation, raw tool output),
2. previous authoritative candidate-stage context,
3. trusted deterministic measured facts (logger/evaluator only),
4. deterministic advisory references.
"""
from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Sequence, Union

PathLike = Union[str, Path]
JsonDict = Dict[str, Any]


def existing_unique_paths(values: Iterable[PathLike]) -> List[Path]:
    out: List[Path] = []
    seen = set()
    for value in values:
        if value is None:
            continue
        p = Path(value).expanduser().resolve()
        key = str(p)
        if key in seen or not p.exists() or not p.is_file():
            continue
        seen.add(key)
        out.append(p)
    return out


def canonical_raw_evidence_files(
    config: Mapping[str, Any],
    *,
    include_specs: bool = True,
    include_code: bool = True,
) -> List[Path]:
    inputs = config.get("inputs", {})
    if not isinstance(inputs, Mapping):
        return []
    values: List[PathLike] = []
    if include_specs:
        for key in ("spec_paths", "specs"):
            item = inputs.get(key)
            if isinstance(item, list):
                values.extend(item)
        for key in ("primary_spec", "spec_path", "spec_file"):
            if inputs.get(key):
                values.append(inputs[key])
    if include_code:
        for key in ("code_paths", "source_files", "implementation_files", "headers"):
            item = inputs.get(key)
            if isinstance(item, list):
                values.extend(item)
        for key in ("primary_source", "source_file", "code_path"):
            if inputs.get(key):
                values.append(inputs[key])
    return existing_unique_paths(values)


def without_keys(data: Mapping[str, Any], *keys: str) -> JsonDict:
    blocked = set(keys)
    return {str(k): v for k, v in data.items() if k not in blocked}


EVIDENCE_HIERARCHY = [
    "raw_primary_evidence",
    "repository_comments_contracts_assertions",
    "raw_formal_tool_output_for_tool_questions",
    "previous_authoritative_candidate_stage_outputs",
    "trusted_deterministic_measured_facts",
    "deterministic_advisory_references",
    "unsupported_model_inference",
]
