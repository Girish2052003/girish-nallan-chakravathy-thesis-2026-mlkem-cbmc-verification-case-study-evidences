"""
run_layout.py

Shared run-folder layout and handoff registry for the thesis agent workflow.

Design goals:
- No root-level dumping of stage outputs.
- No duplicate copies of the same output file.
- Every output lives once inside its producing stage folder.
- Downstream agents discover inputs through handoff_manifest.json, not hardcoded paths.
- Deterministic outputs are kept as advisory references, not authoritative outputs.
- LLM outputs are kept separately as authoritative candidate stage outputs.
- Tool outputs, validation outputs, rendered outputs, and final reports remain clearly separated.

Expected run layout:

runs/run_001/
  run_config.resolved.json
  workflow_plan.json
  run_manifest.json
  status.json
  events.jsonl
  stages/
    02_spec_extraction/
      deterministic_reference/
      prompt_package/
      llm_authoritative/
      validation/
      handoff/
        handoff_manifest.json
      stage_manifest.json
  final/

This module is intentionally dependency-light.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Optional, Union

from agents.common.experiment_protocol import logical_path

JsonDict = Dict[str, Any]
PathLike = Union[str, Path]


@dataclass(frozen=True)
class StageSpec:
    """Static metadata for one workflow stage."""

    stage_id: str
    stage_key: str
    stage_name: str
    stage_type: str  # deterministic_only | llm_backed | mixed | tool_execution
    description: str = ""


DEFAULT_STAGES: List[StageSpec] = [
    StageSpec("01", "01_master_orchestrator", "Master Orchestrator", "deterministic_only", "Controls run setup, stage order, manifests, and status."),
    StageSpec("02", "02_spec_extraction", "Specification Extraction Agent", "llm_backed", "Extracts specification-level facts. LLM output is authoritative stage candidate output."),
    StageSpec("03", "03_code_understanding", "Code Understanding Agent", "llm_backed", "Extracts implementation-level facts. LLM output is authoritative stage candidate output."),
    StageSpec("04", "04_property_discovery", "Property Discovery Agent", "llm_backed", "Proposes candidate CBMC-style properties from spec/code evidence."),
    StageSpec("05", "05_artifact_generation", "Formal Artefact Generation Agent", "mixed", "LLM generates the candidate artefact plan; Python renders and validates controlled concrete files."),
    StageSpec("06", "06_review_critic", "Review / Critic Agent", "llm_backed", "Reviews candidate properties and artefacts before tool execution."),
    StageSpec("07", "07_tool_execution", "Formal Tool Execution Agent", "tool_execution", "Runs CBMC and records exact tool evidence."),
    StageSpec("08", "08_counterexample_analysis", "Counterexample Analysis Agent", "llm_backed", "Explains CBMC failures/success boundaries and proposes repair directions."),
    StageSpec("09", "09_repair_refinement", "Repair / Refinement Agent", "mixed", "LLM proposes candidate repairs; Python controls patch application and records lineage."),
    StageSpec("10", "10_experiment_logger", "Experiment Logger Agent", "deterministic_only", "Indexes files, checksums, run evidence, and human notes."),
    StageSpec("11", "11_evaluation_reporter", "Evaluation Reporter Agent", "mixed", "Python computes facts; LLM may produce cautious thesis-facing interpretation."),
]


def utc_now_iso() -> str:
    """Return a timezone-aware UTC timestamp."""
    return datetime.now(timezone.utc).isoformat()


def ensure_dir(path: PathLike) -> Path:
    """Create a directory and return it as a Path."""
    p = Path(path)
    p.mkdir(parents=True, exist_ok=True)
    return p


def atomic_write_text(path: PathLike, text: str, encoding: str = "utf-8") -> Path:
    """Write text atomically enough for normal local workflow use."""
    p = Path(path)
    ensure_dir(p.parent)
    tmp = p.with_suffix(p.suffix + ".tmp")
    tmp.write_text(text, encoding=encoding)
    tmp.replace(p)
    return p



def atomic_update_pointer(link_path: PathLike, target_path: PathLike) -> Path:
    """Atomically update a latest-manifest pointer without copying the manifest.

    On POSIX systems this creates a relative symbolic link, so the immutable
    iteration manifest remains the single physical JSON file.  A tiny JSON
    pointer is used only when symbolic links are unavailable; readers resolve
    either representation transparently.
    """
    link = Path(link_path)
    target = Path(target_path).resolve()
    ensure_dir(link.parent)
    if not target.exists() or not target.is_file():
        raise FileNotFoundError(f"Cannot point to missing canonical manifest: {target}")

    tmp = link.with_name(link.name + ".pointer_tmp")
    try:
        if tmp.exists() or tmp.is_symlink():
            tmp.unlink()
        relative_target = os.path.relpath(target, start=link.parent.resolve())
        os.symlink(relative_target, tmp)
        os.replace(tmp, link)
        return link
    except (OSError, NotImplementedError):
        if tmp.exists() or tmp.is_symlink():
            tmp.unlink()
        pointer = {
            "schema_version": "manifest_pointer.v1",
            "canonical_manifest": os.path.relpath(target, start=link.parent.resolve()),
            "pointer_only": True,
        }
        return atomic_write_json(link, pointer)


def read_json_following_pointer(path: PathLike) -> JsonDict:
    """Read a JSON manifest and transparently follow a fallback pointer file."""
    p = Path(path)
    data = read_json(p)
    if data.get("schema_version") == "manifest_pointer.v1" and data.get("pointer_only") is True:
        target = resolve_relative(p.parent, str(data.get("canonical_manifest") or ""))
        if not target.exists() or not target.is_file():
            raise FileNotFoundError(f"Manifest pointer target is missing: {target}")
        return read_json(target)
    return data

def atomic_write_json(path: PathLike, data: Mapping[str, Any], indent: int = 2) -> Path:
    """Write JSON with stable formatting."""
    return atomic_write_text(path, json.dumps(data, indent=indent, ensure_ascii=False, sort_keys=False) + "\n")


def read_json(path: PathLike) -> JsonDict:
    """Read JSON as dict."""
    p = Path(path)
    with p.open("r", encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError(f"Expected JSON object in {p}, got {type(data).__name__}")
    return data


def sha256_file(path: PathLike) -> str:
    """Return SHA-256 hex digest for a file."""
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def relative_to(base: PathLike, target: PathLike) -> str:
    """Return POSIX relative path from base directory to target path."""
    base_p = Path(base).resolve()
    target_p = Path(target).resolve()
    return os.path.relpath(target_p, base_p).replace(os.sep, "/")


def resolve_relative(base: PathLike, rel_or_abs: PathLike) -> Path:
    """Resolve a path that may be relative to base."""
    p = Path(rel_or_abs)
    if p.is_absolute():
        return p.resolve()
    return (Path(base) / p).resolve()


@dataclass
class RunLayout:
    """
    Provides stable folders and manifest/handoff helpers for a run.

    Use this in every agent instead of writing outputs directly into run_dir.
    """

    run_dir: Path
    stages: List[StageSpec] = field(default_factory=lambda: list(DEFAULT_STAGES))
    create: bool = True
    active_iteration: Optional[int] = None
    active_reason: Optional[str] = None

    def __post_init__(self) -> None:
        self.run_dir = Path(self.run_dir).resolve()
        if self.active_iteration is None:
            raw_iteration = os.environ.get("THESIS_ITERATION")
            if raw_iteration not in {None, ""}:
                try:
                    self.active_iteration = int(raw_iteration)
                except ValueError as exc:
                    raise ValueError(f"Invalid THESIS_ITERATION value: {raw_iteration!r}") from exc
        if self.active_iteration is not None and self.active_iteration < 0:
            raise ValueError("active_iteration must be >= 0")
        if self.active_reason is None:
            self.active_reason = os.environ.get("THESIS_REPAIR_REASON") or None
        if self.create:
            self.initialise_run_dirs()

    @property
    def stages_dir(self) -> Path:
        return self.run_dir / "stages"

    @property
    def final_dir(self) -> Path:
        return self.run_dir / "final"

    @property
    def run_manifest_path(self) -> Path:
        return self.run_dir / "run_manifest.json"

    @property
    def events_path(self) -> Path:
        return self.run_dir / "events.jsonl"

    @property
    def status_path(self) -> Path:
        return self.run_dir / "status.json"

    def _run_protocol_context(self) -> JsonDict:
        config_path = self.run_dir / "run_config.resolved.json"
        if not config_path.is_file():
            return {
                "experiment_protocol_sha256": None,
                "experiment_protocol_version": None,
                "semantic_advisory_mode": None,
                "property_discovery_mode": None,
            }
        try:
            config = read_json(config_path)
            protocol = config.get("experiment_protocol", {})
            if not isinstance(protocol, Mapping):
                protocol = {}
            discovery = config.get("property_discovery", {})
            if not isinstance(discovery, Mapping):
                discovery = {}
            return {
                "experiment_protocol_sha256": protocol.get("protocol_sha256"),
                "experiment_protocol_version": protocol.get("protocol_version"),
                "semantic_advisory_mode": protocol.get("semantic_advisory_mode"),
                "property_discovery_mode": discovery.get("mode"),
            }
        except Exception:
            return {
                "experiment_protocol_sha256": None,
                "experiment_protocol_version": None,
                "semantic_advisory_mode": None,
                "property_discovery_mode": None,
            }

    def protocol_context(self) -> JsonDict:
        """Public immutable protocol metadata for every stage status/report."""
        return dict(self._run_protocol_context())

    def _logical_path(self, path: PathLike) -> str:
        return logical_path(path, (("$RUN_DIR", self.run_dir), ("$WORKFLOW_ROOT", self.run_dir.parent.parent)))

    def get_stage(self, stage: str) -> StageSpec:
        """Accept '02', '02_spec_extraction', or suffix such as 'spec_extraction'."""
        normalized = stage.strip().lower()
        for spec in self.stages:
            suffix = spec.stage_key.split("_", 1)[-1].lower()
            if normalized in {spec.stage_id.lower(), spec.stage_key.lower(), suffix}:
                return spec
        matches = [s for s in self.stages if s.stage_key.lower().endswith(normalized)]
        if len(matches) == 1:
            return matches[0]
        known = ", ".join(s.stage_key for s in self.stages)
        raise KeyError(f"Unknown stage '{stage}'. Known stages: {known}")

    def stage_dir(self, stage: str) -> Path:
        return self.stages_dir / self.get_stage(stage).stage_key

    def is_iteration_sensitive(self, stage: str) -> bool:
        return self.get_stage(stage).stage_key in {
            "06_review_critic",
            "07_tool_execution",
            "08_counterexample_analysis",
            "09_repair_refinement",
        }

    def iteration_dir(self, stage: str, iteration: Optional[int] = None) -> Path:
        selected = self.active_iteration if iteration is None else iteration
        if selected is None:
            raise ValueError(f"No active iteration is set for stage {stage}")
        if selected < 0:
            raise ValueError("iteration must be >= 0")
        return self.stage_dir(stage) / "iterations" / f"iteration_{selected:02d}"

    def _output_root(self, stage: str) -> Path:
        if self.active_iteration is not None and self.is_iteration_sensitive(stage):
            return self.iteration_dir(stage)
        return self.stage_dir(stage)

    # Standard stage subfolders. Iteration-sensitive stages write immutable
    # evidence below iterations/iteration_XX while root handoffs remain latest pointers.
    def control_dir(self, stage: str) -> Path: return self._output_root(stage) / "control"
    def logs_dir(self, stage: str) -> Path: return self._output_root(stage) / "logs"
    def deterministic_reference_dir(self, stage: str) -> Path: return self._output_root(stage) / "deterministic_reference"
    def prohibited_copy_reference_dir(self, stage: str) -> Path: return self._output_root(stage) / "prohibited_copy_reference"
    def prompt_package_dir(self, stage: str) -> Path: return self._output_root(stage) / "prompt_package"
    def llm_authoritative_dir(self, stage: str) -> Path: return self._output_root(stage) / "llm_authoritative"
    def rendered_outputs_dir(self, stage: str) -> Path: return self._output_root(stage) / "rendered_outputs"
    def tool_inputs_dir(self, stage: str) -> Path: return self._output_root(stage) / "tool_inputs"
    def tool_outputs_dir(self, stage: str) -> Path: return self._output_root(stage) / "tool_outputs"
    def diagnostics_dir(self, stage: str) -> Path: return self._output_root(stage) / "diagnostics"
    def validation_dir(self, stage: str) -> Path: return self._output_root(stage) / "validation"
    def evidence_index_dir(self, stage: str) -> Path: return self._output_root(stage) / "evidence_index"
    def human_review_dir(self, stage: str) -> Path: return self._output_root(stage) / "human_review"

    # Root handoff and stage manifests intentionally remain stable latest pointers.
    def handoff_dir(self, stage: str) -> Path: return self.stage_dir(stage) / "handoff"

    def stage_manifest_path(self, stage: str) -> Path:
        return self.stage_dir(stage) / "stage_manifest.json"

    def iteration_stage_manifest_path(self, stage: str) -> Optional[Path]:
        if self.active_iteration is None or not self.is_iteration_sensitive(stage):
            return None
        return self.iteration_dir(stage) / "stage_manifest.json"

    def handoff_manifest_path(self, stage: str) -> Path:
        return self.handoff_dir(stage) / "handoff_manifest.json"

    def iteration_handoff_manifest_path(self, stage: str) -> Optional[Path]:
        if self.active_iteration is None or not self.is_iteration_sensitive(stage):
            return None
        return self.iteration_dir(stage) / "handoff" / "handoff_manifest.json"

    def initialise_run_dirs(self) -> None:
        ensure_dir(self.run_dir)
        ensure_dir(self.stages_dir)
        ensure_dir(self.final_dir)
        for spec in self.stages:
            sdir = ensure_dir(self.stages_dir / spec.stage_key)
            ensure_dir(sdir / "handoff")
            if spec.stage_type == "deterministic_only":
                subdirs = ["control", "logs", "diagnostics", "handoff"]
            elif spec.stage_type == "tool_execution":
                subdirs = ["tool_inputs", "tool_outputs", "diagnostics", "validation", "handoff"]
            elif spec.stage_type == "mixed":
                subdirs = ["deterministic_reference", "prompt_package", "llm_authoritative", "validation", "evidence_index", "human_review", "handoff"]
                if spec.stage_key == "05_artifact_generation":
                    subdirs += ["prohibited_copy_reference", "rendered_outputs"]
                elif spec.stage_key == "09_repair_refinement":
                    subdirs += ["rendered_outputs"]
            else:
                subdirs = ["deterministic_reference", "prompt_package", "llm_authoritative", "validation", "handoff"]
                if spec.stage_key == "05_artifact_generation":
                    subdirs += ["prohibited_copy_reference", "rendered_outputs"]
            for subdir in subdirs:
                ensure_dir(sdir / subdir)
        self.write_run_manifest()

    def write_run_manifest(self, extra: Optional[Mapping[str, Any]] = None) -> Path:
        data: JsonDict = {
            "schema_version": "run_manifest.v1",
            "created_or_updated_utc": utc_now_iso(),
            "run_dir": str(self.run_dir),
            "run_dir_logical": "$RUN_DIR",
            **self._run_protocol_context(),
            "layout_policy": {
                "one_file_one_location": True,
                "root_level_stage_outputs_allowed": False,
                "handoff_uses_manifest_pointers": True,
                "deterministic_reference_is_authoritative": False,
                "llm_output_is_authoritative_stage_candidate": True,
                "formal_truth_not_claimed_by_llm": True,
            },
            "stages": [asdict(s) for s in self.stages],
        }
        if extra:
            data.update(dict(extra))
        return atomic_write_json(self.run_manifest_path, data)

    def default_trust_boundary(self, spec: StageSpec) -> JsonDict:
        if spec.stage_type == "deterministic_only":
            return {
                "deterministic_output": "authoritative_for_control_or_logging_only",
                "llm_output": "not_applicable",
                "formal_truth": "not_claimed",
            }
        if spec.stage_type == "tool_execution":
            return {
                "tool_output": "primary_formal_tool_evidence_under_recorded_assumptions",
                "llm_output": "not_applicable",
                "full_correctness": "not_claimed",
            }
        if spec.stage_type == "mixed":
            if spec.stage_key in {"05_artifact_generation", "09_repair_refinement"}:
                return {
                    "deterministic_control": "rendering_validation_or_patch_application_only",
                    "deterministic_reference": "advisory_only_not_authoritative",
                    "llm_output": "authoritative_stage_candidate_not_formal_truth",
                    "formal_truth": "not_claimed",
                }
            return {
                "deterministic_facts": "primary_for_measured_counts_and_file_evidence",
                "llm_output": "candidate_interpretation_only",
                "formal_truth": "not_claimed",
            }
        return {
            "deterministic_reference": "advisory_only_not_authoritative",
            "llm_output": "authoritative_stage_candidate_not_formal_truth",
            "primary_evidence": "raw_spec_code_or_tool_outputs_outweigh_hints",
            "formal_truth": "not_claimed_by_llm",
        }

    def write_stage_manifest(
        self,
        stage: str,
        *,
        primary_evidence_inputs: Optional[Iterable[PathLike]] = None,
        deterministic_reference_outputs: Optional[Mapping[str, PathLike]] = None,
        prompt_package_outputs: Optional[Mapping[str, PathLike]] = None,
        llm_authoritative_outputs: Optional[Mapping[str, PathLike]] = None,
        validation_outputs: Optional[Mapping[str, PathLike]] = None,
        rendered_outputs: Optional[Mapping[str, PathLike]] = None,
        tool_outputs: Optional[Mapping[str, PathLike]] = None,
        diagnostics_outputs: Optional[Mapping[str, PathLike]] = None,
        notes: Optional[Mapping[str, Any]] = None,
    ) -> Path:
        spec = self.get_stage(stage)
        sdir = self.stage_dir(stage)

        def merge_discovered(
            supplied: Optional[Mapping[str, PathLike]],
            directory: Path,
            *,
            prefix: str,
        ) -> Dict[str, PathLike]:
            """Merge explicitly named outputs with every physical file in a canonical output directory.

            This makes stage manifests complete for exact per-attempt API request/response
            snapshots without requiring every agent to duplicate discovery logic.
            """
            merged: Dict[str, PathLike] = dict(supplied or {})
            represented = {str(Path(v).resolve()) for v in merged.values()}
            if directory.exists():
                for candidate in sorted(directory.rglob("*")):
                    if not candidate.is_file():
                        continue
                    resolved = str(candidate.resolve())
                    if resolved in represented:
                        continue
                    rel = candidate.relative_to(directory).as_posix()
                    safe_key = re.sub(r"[^A-Za-z0-9_.-]+", "__", rel)
                    key = f"{prefix}__{safe_key}"
                    suffix = 2
                    while key in merged:
                        key = f"{prefix}__{safe_key}__{suffix}"
                        suffix += 1
                    merged[key] = candidate
                    represented.add(resolved)
            return merged

        prompt_package_outputs = merge_discovered(
            prompt_package_outputs, self.prompt_package_dir(stage), prefix="prompt_package"
        )
        llm_authoritative_outputs = merge_discovered(
            llm_authoritative_outputs, self.llm_authoritative_dir(stage), prefix="llm_authoritative"
        )
        validation_outputs = merge_discovered(
            validation_outputs, self.validation_dir(stage), prefix="validation"
        )

        def rel_map(m: Optional[Mapping[str, PathLike]]) -> Dict[str, str]:
            return {k: relative_to(sdir, v) for k, v in (m or {}).items()}
        data: JsonDict = {
            "schema_version": "stage_manifest.v1",
            "updated_utc": utc_now_iso(),
            "stage_id": spec.stage_id,
            "stage_key": spec.stage_key,
            "stage_name": spec.stage_name,
            "stage_type": spec.stage_type,
            "description": spec.description,
            "trust_boundary": self.default_trust_boundary(spec),
            **self._run_protocol_context(),
            "primary_evidence_inputs": [str(Path(p)) for p in (primary_evidence_inputs or [])],
            "primary_evidence_inputs_logical": [self._logical_path(p) for p in (primary_evidence_inputs or [])],
            "deterministic_reference_outputs": rel_map(deterministic_reference_outputs),
            "prompt_package_outputs": rel_map(prompt_package_outputs),
            "llm_authoritative_outputs": rel_map(llm_authoritative_outputs),
            "rendered_outputs": rel_map(rendered_outputs),
            "tool_outputs": rel_map(tool_outputs),
            "validation_outputs": rel_map(validation_outputs),
            "diagnostics_outputs": rel_map(diagnostics_outputs),
            "handoff_manifest": relative_to(sdir, self.handoff_manifest_path(stage)),
            "iteration": self.active_iteration if self.is_iteration_sensitive(stage) else None,
            "iteration_reason": self.active_reason if self.is_iteration_sensitive(stage) else None,
            "notes": dict(notes or {}),
        }
        iteration_path = self.iteration_stage_manifest_path(stage)
        if iteration_path is not None:
            canonical_path = atomic_write_json(iteration_path, data)
            return atomic_update_pointer(self.stage_manifest_path(stage), canonical_path)
        return atomic_write_json(self.stage_manifest_path(stage), data)

    def write_handoff_manifest(
        self,
        stage: str,
        *,
        outputs: Mapping[str, PathLike],
        authoritative_source: str,
        next_stage_consumers: Optional[Iterable[str]] = None,
        notes: Optional[Mapping[str, Any]] = None,
    ) -> Path:
        spec = self.get_stage(stage)
        sdir = self.stage_dir(stage)
        resolved_outputs: Dict[str, str] = {}
        checksums: Dict[str, str] = {}
        for key, path in outputs.items():
            real_path = Path(path).resolve()
            if not real_path.exists():
                raise FileNotFoundError(f"Cannot hand off missing output '{key}' for {spec.stage_key}: {real_path}")
            resolved_outputs[key] = relative_to(sdir, real_path)
            if real_path.is_file():
                checksums[key] = sha256_file(real_path)
        data: JsonDict = {
            "schema_version": "handoff_manifest.v1",
            "created_utc": utc_now_iso(),
            "stage_id": spec.stage_id,
            "stage_key": spec.stage_key,
            "stage_name": spec.stage_name,
            "stage_type": spec.stage_type,
            "authoritative_source": authoritative_source,
            **self._run_protocol_context(),
            "handoff_outputs": resolved_outputs,
            "checksums_sha256": checksums,
            "next_stage_consumers": list(next_stage_consumers or []),
            "trust_boundary": self.default_trust_boundary(spec),
            "iteration": self.active_iteration if self.is_iteration_sensitive(stage) else None,
            "iteration_reason": self.active_reason if self.is_iteration_sensitive(stage) else None,
            "notes": dict(notes or {}),
        }
        ensure_dir(self.handoff_dir(stage))
        iteration_path = self.iteration_handoff_manifest_path(stage)
        if iteration_path is not None:
            canonical_path = atomic_write_json(iteration_path, data)
            return atomic_update_pointer(self.handoff_manifest_path(stage), canonical_path)
        return atomic_write_json(self.handoff_manifest_path(stage), data)

    def read_handoff_manifest(self, stage: str) -> JsonDict:
        path = self.handoff_manifest_path(stage)
        if not path.exists():
            raise FileNotFoundError(f"Missing handoff manifest for stage {stage}: {path}")
        return read_json_following_pointer(path)

    def get_handoff(self, producer_stage: str, output_key: str) -> Path:
        manifest = self.read_handoff_manifest(producer_stage)
        outputs = manifest.get("handoff_outputs", {})
        if output_key not in outputs:
            available = ", ".join(sorted(outputs.keys()))
            raise KeyError(f"Stage '{producer_stage}' has no handoff output '{output_key}'. Available: {available}")
        return resolve_relative(self.stage_dir(producer_stage), outputs[output_key])

    def list_handoff_outputs(self, producer_stage: str) -> Dict[str, Path]:
        manifest = self.read_handoff_manifest(producer_stage)
        return {k: resolve_relative(self.stage_dir(producer_stage), v) for k, v in manifest.get("handoff_outputs", {}).items()}

    def write_prompt_package(
        self,
        stage: str,
        *,
        prompt_text: str,
        prompt_filename: str,
        metadata: Optional[Mapping[str, Any]] = None,
        deterministic_reference_bundle: Optional[Mapping[str, Any]] = None,
        prior_authoritative_context_bundle: Optional[Mapping[str, Any]] = None,
        trusted_deterministic_facts_bundle: Optional[Mapping[str, Any]] = None,
        primary_evidence_manifest: Optional[Mapping[str, Any]] = None,
        prior_authoritative_context_manifest: Optional[Mapping[str, Any]] = None,
        trusted_deterministic_facts_manifest: Optional[Mapping[str, Any]] = None,
    ) -> Dict[str, Path]:
        pdir = self.prompt_package_dir(stage)
        ensure_dir(pdir)
        outputs: Dict[str, Path] = {}
        outputs["prompt"] = atomic_write_text(pdir / prompt_filename, prompt_text)
        if metadata is not None:
            outputs["prompt_metadata"] = atomic_write_json(pdir / "prompt_metadata.json", {"schema_version": "prompt_metadata.v1", "created_utc": utc_now_iso(), **dict(metadata)})
        if deterministic_reference_bundle is not None:
            outputs["deterministic_reference_bundle"] = atomic_write_json(pdir / "deterministic_reference_bundle.json", {"schema_version": "deterministic_reference_bundle.v1", "created_utc": utc_now_iso(), "trust_boundary": "advisory_only_not_authoritative", "content": deterministic_reference_bundle})
        if prior_authoritative_context_bundle is not None:
            outputs["prior_authoritative_context_bundle"] = atomic_write_json(pdir / "prior_authoritative_context_bundle.json", {"schema_version": "prior_authoritative_context_bundle.v1", "created_utc": utc_now_iso(), "trust_boundary": "previous_candidate_stage_context_not_formal_truth", "content": prior_authoritative_context_bundle})
        if trusted_deterministic_facts_bundle is not None:
            outputs["trusted_deterministic_facts_bundle"] = atomic_write_json(pdir / "trusted_deterministic_facts_bundle.json", {"schema_version": "trusted_deterministic_facts_bundle.v1", "created_utc": utc_now_iso(), "trust_boundary": "authoritative_for_measured_logged_facts_not_semantic_truth", "content": trusted_deterministic_facts_bundle})
        if primary_evidence_manifest is not None:
            outputs["primary_evidence_manifest"] = atomic_write_json(pdir / "primary_evidence_manifest.json", {"schema_version": "primary_evidence_manifest.v1", "created_utc": utc_now_iso(), "priority": "primary_evidence", "content": primary_evidence_manifest})
        if prior_authoritative_context_manifest is not None:
            outputs["prior_authoritative_context_manifest"] = atomic_write_json(pdir / "prior_authoritative_context_manifest.json", {"schema_version": "prior_authoritative_context_manifest.v1", "created_utc": utc_now_iso(), "priority": "previous_authoritative_candidate_context", "content": prior_authoritative_context_manifest})
        if trusted_deterministic_facts_manifest is not None:
            outputs["trusted_deterministic_facts_manifest"] = atomic_write_json(pdir / "trusted_deterministic_facts_manifest.json", {"schema_version": "trusted_deterministic_facts_manifest.v1", "created_utc": utc_now_iso(), "priority": "trusted_measured_facts", "content": trusted_deterministic_facts_manifest})
        return outputs

    def write_deterministic_reference_json(self, stage: str, filename: str, data: Mapping[str, Any]) -> Path:
        return atomic_write_json(self.deterministic_reference_dir(stage) / filename, {"schema_version": "deterministic_reference.v1", "created_utc": utc_now_iso(), "trust_boundary": "advisory_only_not_authoritative", "content": dict(data)})

    def write_llm_authoritative_json(self, stage: str, filename: str, data: Mapping[str, Any]) -> Path:
        return atomic_write_json(self.llm_authoritative_dir(stage) / filename, {"schema_version": "llm_authoritative_stage_output.v1", "created_utc": utc_now_iso(), "trust_boundary": "authoritative_stage_candidate_not_formal_truth", "content": dict(data)})

    def write_validation_json(self, stage: str, filename: str, data: Mapping[str, Any]) -> Path:
        return atomic_write_json(self.validation_dir(stage) / filename, {"schema_version": "validation_record.v1", "created_utc": utc_now_iso(), "content": dict(data)})

    def log_event(self, *, event_type: str, stage: Optional[str] = None, message: str = "", data: Optional[Mapping[str, Any]] = None) -> None:
        event: JsonDict = {"timestamp_utc": utc_now_iso(), "event_type": event_type, "stage": stage, "message": message, "data": dict(data or {})}
        ensure_dir(self.events_path.parent)
        with self.events_path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(event, ensure_ascii=False) + "\n")


def export_flat_index_only(run_dir: PathLike, export_dir: PathLike) -> Path:
    """
    Export a flat index of outputs without copying all files.
    This creates a Markdown index with links/paths to stage outputs.
    """
    layout = RunLayout(Path(run_dir), create=False)
    out_dir = ensure_dir(export_dir)
    lines: List[str] = [
        "# Flat Run Index",
        "",
        "This export is an index only. It does not duplicate stage output files.",
        "",
    ]
    for spec in layout.stages:
        hpath = layout.handoff_manifest_path(spec.stage_key)
        lines.append(f"## {spec.stage_key} — {spec.stage_name}")
        lines.append("")
        if not hpath.exists():
            lines.append("_No handoff manifest found._")
            lines.append("")
            continue
        manifest = read_json(hpath)
        for key, rel_path in manifest.get("handoff_outputs", {}).items():
            abs_path = resolve_relative(layout.stage_dir(spec.stage_key), rel_path)
            lines.append(f"- `{key}` → `{abs_path}`")
        lines.append("")
    index_path = out_dir / "flat_run_index.md"
    atomic_write_text(index_path, "\n".join(lines))
    return index_path
