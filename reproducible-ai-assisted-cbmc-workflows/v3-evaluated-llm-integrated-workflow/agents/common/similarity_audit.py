"""Shared anti-copy similarity screening for generated and repaired artefacts.

This is a heuristic risk screen only.  It deliberately excludes implementation
source files unless the user explicitly configures them as proof/reference
artefacts.  A low score is not proof of originality and a high score requires
human review.
"""
from __future__ import annotations

import csv
import difflib
import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Mapping, Sequence, Tuple

JsonDict = Dict[str, Any]


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def normalize_code(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.DOTALL)
    text = re.sub(r"//.*", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def normalized_lines(text: str) -> List[str]:
    rows: List[str] = []
    for line in text.splitlines():
        line = re.sub(r"/\*.*?\*/", " ", line)
        line = re.sub(r"//.*", " ", line)
        line = re.sub(r"\s+", " ", line).strip()
        if line:
            rows.append(line)
    return rows


def _jaccard(a: Sequence[str], b: Sequence[str]) -> float:
    sa, sb = set(a), set(b)
    if not sa and not sb:
        return 0.0
    return len(sa & sb) / max(1, len(sa | sb))


def explicit_prohibited_reference_files(config: Mapping[str, Any]) -> List[Path]:
    """Resolve only explicitly configured proof/template comparison material."""
    ag = config.get("artifact_generation") if isinstance(config.get("artifact_generation"), Mapping) else {}
    values: List[Path] = []
    for raw in ag.get("proof_reference_files", []) or []:
        p = Path(str(raw)).expanduser().resolve()
        if p.is_file():
            values.append(p)
    for raw in ag.get("proof_reference_dirs", []) or []:
        root = Path(str(raw)).expanduser().resolve()
        if root.is_dir():
            for pattern in ("*.c", "*.h", "*.inc", "*.json", "*.md"):
                values.extend(sorted(root.rglob(pattern)))
    seen = set()
    out: List[Path] = []
    for p in values:
        key = str(p.resolve())
        if key not in seen:
            seen.add(key)
            out.append(p.resolve())
    return out[:300]


def audit_candidate_files(
    candidate_files: Iterable[Path],
    reference_files: Iterable[Path],
    *,
    high_threshold: float = 0.72,
    moderate_threshold: float = 0.50,
) -> Tuple[JsonDict, List[JsonDict]]:
    candidates = [Path(p).resolve() for p in candidate_files if Path(p).is_file()]
    references = [Path(p).resolve() for p in reference_files if Path(p).is_file()]
    rows: List[JsonDict] = []
    max_score = 0.0
    highest: JsonDict | None = None

    for candidate in candidates:
        ctext = candidate.read_text(encoding="utf-8", errors="replace")
        cnorm = normalize_code(ctext)
        clines = normalized_lines(ctext)
        for reference in references:
            rtext = reference.read_text(encoding="utf-8", errors="replace")
            rnorm = normalize_code(rtext)
            rlines = normalized_lines(rtext)
            seq = difflib.SequenceMatcher(None, cnorm, rnorm).ratio()
            jac = _jaccard(clines, rlines)
            score = max(seq, jac)
            row = {
                "candidate_path": str(candidate),
                "candidate_sha256": sha256_file(candidate),
                "reference_path": str(reference),
                "reference_sha256": sha256_file(reference),
                "sequence_similarity": round(seq, 4),
                "line_jaccard": round(jac, 4),
                "combined_similarity": round(score, 4),
            }
            rows.append(row)
            if highest is None or score > float(highest["combined_similarity"]):
                highest = dict(row)
            max_score = max(max_score, score)

    if max_score >= high_threshold:
        risk, action, human = "high_similarity_risk", "block_or_require_major_revision_before_tool", True
    elif max_score >= moderate_threshold:
        risk, action, human = "moderate_similarity_risk", "human_review_required", True
    else:
        risk, action, human = "low_similarity_risk", "record_and_continue", False

    audit: JsonDict = {
        "schema_version": "independence_audit.v2.shared_repair_aware",
        "created_utc": utc_now_iso(),
        "candidate_files": [str(p) for p in candidates],
        "candidate_file_count": len(candidates),
        "reference_files": [str(p) for p in references],
        "reference_file_count": len(references),
        "highest_similarity": highest,
        "max_similarity_score": round(max_score, 4),
        "copying_risk": risk,
        "requires_human_similarity_review": human,
        "recommended_action": action,
        "audit_complete": True,
        "limitations": [
            "Heuristic similarity screening is not proof of novelty or legal originality.",
            "Required identifiers, types, macros, constants and CBMC primitives may legitimately overlap.",
            "Implementation source is primary evidence and is not a prohibited-copy source unless explicitly configured as one.",
        ],
        "trust_boundary": "deterministic_similarity_risk_screen_not_formal_truth",
    }
    return audit, rows


def write_audit(audit_path: Path, csv_path: Path, audit: Mapping[str, Any], rows: Sequence[Mapping[str, Any]]) -> Tuple[Path, Path]:
    audit_path.parent.mkdir(parents=True, exist_ok=True)
    audit_path.write_text(json.dumps(dict(audit), indent=2, sort_keys=True) + "\n", encoding="utf-8")
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "candidate_path", "candidate_sha256", "reference_path", "reference_sha256",
        "sequence_similarity", "line_jaccard", "combined_similarity",
    ]
    with csv_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: row.get(k, "") for k in fields})
    return audit_path, csv_path
