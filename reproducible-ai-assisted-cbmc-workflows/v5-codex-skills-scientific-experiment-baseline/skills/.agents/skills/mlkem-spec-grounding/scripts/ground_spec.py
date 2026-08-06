#!/usr/bin/env python3
"""Deterministic local specification-grounding utility.

This utility performs bounded lexical retrieval over a supplied local specification
corpus. It does not infer verification properties, assumptions, assertions, or
scientific conclusions.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Sequence

SKILL_NAME = "mlkem-spec-grounding"
SKILL_VERSION = "1.0.0-rc1"
SCHEMA_VERSION = "1.0"
SUPPORTED_TEXT_EXTENSIONS = {".txt", ".md", ".rst", ".tex"}
SUPPORTED_EXTENSIONS = SUPPORTED_TEXT_EXTENSIONS | {".pdf"}
EXIT_OK = 0
EXIT_INCOMPLETE = 2
EXIT_INPUT_ERROR = 3
EXIT_EXTRACTION_ERROR = 4
EXIT_INTERNAL_ERROR = 5


class InputError(ValueError):
    """Raised when a request or path violates the input contract."""


class ExtractionError(RuntimeError):
    """Raised when no usable specification material can be extracted."""


@dataclass(frozen=True)
class SourceLine:
    line: int
    text: str
    page: int | None = None


@dataclass(frozen=True)
class SourceDocument:
    relative_path: str
    sha256: str
    size_bytes: int
    media_type: str
    lines: tuple[SourceLine, ...]
    page_count: int | None
    extraction_method: str


@dataclass(frozen=True)
class Query:
    query_id: str
    text: str
    mode: str
    required: bool


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def stable_json_write(path: Path, payload: Any) -> None:
    path.write_text(
        json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def normalise_for_match(text: str, case_sensitive: bool) -> str:
    return text if case_sensitive else text.casefold()


def tokenise(text: str, case_sensitive: bool) -> list[str]:
    value = normalise_for_match(text, case_sensitive)
    return re.findall(r"[A-Za-z0-9]+", value)


def parse_request(path: Path) -> tuple[dict[str, Any], list[Query], dict[str, Any]]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise InputError(f"Request file not found: {path}") from exc
    except json.JSONDecodeError as exc:
        raise InputError(f"Request file is not valid JSON: {exc}") from exc

    if not isinstance(payload, dict):
        raise InputError("Request root must be a JSON object.")
    if payload.get("schema_version") != SCHEMA_VERSION:
        raise InputError(
            f"schema_version must be {SCHEMA_VERSION!r}; received {payload.get('schema_version')!r}."
        )

    request_id = payload.get("request_id")
    if not isinstance(request_id, str) or not request_id.strip():
        raise InputError("request_id must be a non-empty string.")

    target = payload.get("target")
    if not isinstance(target, dict):
        raise InputError("target must be an object.")
    symbol = target.get("symbol")
    if not isinstance(symbol, str) or not symbol.strip():
        raise InputError("target.symbol must be a non-empty string.")
    source_file = target.get("source_file")
    if source_file is not None and (not isinstance(source_file, str) or not source_file.strip()):
        raise InputError("target.source_file must be null or a non-empty string.")

    raw_queries = payload.get("queries")
    if not isinstance(raw_queries, list) or not raw_queries:
        raise InputError(
            "queries must be a non-empty array. Codex/researcher must supply the grounding concepts."
        )

    allowed_modes = {"literal", "all_terms", "any_term"}
    seen_ids: set[str] = set()
    queries: list[Query] = []
    for index, raw in enumerate(raw_queries):
        if not isinstance(raw, dict):
            raise InputError(f"queries[{index}] must be an object.")
        query_id = raw.get("id")
        text = raw.get("text")
        mode = raw.get("mode", "literal")
        required = raw.get("required", True)
        if not isinstance(query_id, str) or not query_id.strip():
            raise InputError(f"queries[{index}].id must be a non-empty string.")
        if query_id in seen_ids:
            raise InputError(f"Duplicate query id: {query_id}")
        seen_ids.add(query_id)
        if not isinstance(text, str) or not text.strip():
            raise InputError(f"queries[{index}].text must be a non-empty string.")
        if mode not in allowed_modes:
            raise InputError(
                f"queries[{index}].mode must be one of {sorted(allowed_modes)}; received {mode!r}."
            )
        if not isinstance(required, bool):
            raise InputError(f"queries[{index}].required must be true or false.")
        if mode in {"all_terms", "any_term"} and not tokenise(text, False):
            raise InputError(f"queries[{index}].text contains no searchable terms.")
        queries.append(Query(query_id.strip(), text.strip(), mode, required))

    raw_options = payload.get("options", {})
    if raw_options is None:
        raw_options = {}
    if not isinstance(raw_options, dict):
        raise InputError("options must be an object when supplied.")

    options = {
        "case_sensitive": raw_options.get("case_sensitive", False),
        "context_lines": raw_options.get("context_lines", 3),
        "max_matches_per_query": raw_options.get("max_matches_per_query", 25),
    }
    if not isinstance(options["case_sensitive"], bool):
        raise InputError("options.case_sensitive must be true or false.")
    if not isinstance(options["context_lines"], int) or not 0 <= options["context_lines"] <= 50:
        raise InputError("options.context_lines must be an integer from 0 through 50.")
    if (
        not isinstance(options["max_matches_per_query"], int)
        or not 1 <= options["max_matches_per_query"] <= 1000
    ):
        raise InputError("options.max_matches_per_query must be an integer from 1 through 1000.")

    canonical = {
        "schema_version": SCHEMA_VERSION,
        "request_id": request_id.strip(),
        "target": {
            "symbol": symbol.strip(),
            "source_file": source_file.strip() if isinstance(source_file, str) else None,
        },
        "queries": [
            {
                "id": query.query_id,
                "mode": query.mode,
                "required": query.required,
                "text": query.text,
            }
            for query in queries
        ],
        "options": options,
    }
    return canonical, queries, options


def ensure_safe_paths(spec_root: Path, output_dir: Path) -> tuple[Path, Path]:
    root = spec_root.expanduser().resolve()
    output = output_dir.expanduser().resolve()
    if not root.is_dir():
        raise InputError(f"Specification root is not a directory: {root}")
    try:
        output.relative_to(root)
    except ValueError:
        pass
    else:
        raise InputError(
            "Output directory must not be inside the specification root; otherwise generated evidence "
            "could be re-ingested as source material on a later run."
        )
    return root, output


def iter_source_files(spec_root: Path) -> tuple[list[Path], list[dict[str, Any]]]:
    accepted: list[Path] = []
    skipped: list[dict[str, Any]] = []
    for path in sorted(spec_root.rglob("*"), key=lambda item: item.as_posix()):
        if path.is_symlink():
            skipped.append(
                {
                    "path": path.relative_to(spec_root).as_posix(),
                    "reason": "symlink_not_followed",
                }
            )
            continue
        if not path.is_file():
            continue
        suffix = path.suffix.casefold()
        if suffix not in SUPPORTED_EXTENSIONS:
            skipped.append(
                {
                    "path": path.relative_to(spec_root).as_posix(),
                    "reason": "unsupported_extension",
                }
            )
            continue
        accepted.append(path)
    return accepted, skipped


def read_text_document(path: Path, spec_root: Path) -> SourceDocument:
    raw = path.read_bytes()
    text = raw.decode("utf-8-sig", errors="replace")
    lines = tuple(
        SourceLine(line=index, text=value.rstrip("\r"), page=None)
        for index, value in enumerate(text.splitlines(), start=1)
    )
    media_types = {
        ".txt": "text/plain",
        ".md": "text/markdown",
        ".rst": "text/x-rst",
        ".tex": "application/x-tex",
    }
    return SourceDocument(
        relative_path=path.relative_to(spec_root).as_posix(),
        sha256=hashlib.sha256(raw).hexdigest(),
        size_bytes=len(raw),
        media_type=media_types[path.suffix.casefold()],
        lines=lines,
        page_count=None,
        extraction_method="utf-8-text",
    )


def read_pdf_document(path: Path, spec_root: Path) -> SourceDocument:
    executable = shutil.which("pdftotext")
    if executable is None:
        raise ExtractionError("pdftotext is not installed; PDF file could not be extracted.")
    completed = subprocess.run(
        [executable, "-layout", str(path), "-"],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if completed.returncode != 0:
        stderr = completed.stderr.decode("utf-8", errors="replace").strip()
        raise ExtractionError(f"pdftotext failed with exit {completed.returncode}: {stderr}")

    text = completed.stdout.decode("utf-8", errors="replace")
    pages = text.split("\f")
    if pages and not pages[-1].strip():
        pages = pages[:-1]
    source_lines: list[SourceLine] = []
    line_no = 1
    for page_no, page_text in enumerate(pages, start=1):
        for value in page_text.splitlines():
            source_lines.append(SourceLine(line=line_no, text=value.rstrip("\r"), page=page_no))
            line_no += 1
    return SourceDocument(
        relative_path=path.relative_to(spec_root).as_posix(),
        sha256=sha256_file(path),
        size_bytes=path.stat().st_size,
        media_type="application/pdf",
        lines=tuple(source_lines),
        page_count=len(pages),
        extraction_method="pdftotext-layout",
    )


def load_documents(
    paths: Sequence[Path], spec_root: Path
) -> tuple[list[SourceDocument], list[dict[str, Any]]]:
    documents: list[SourceDocument] = []
    failures: list[dict[str, Any]] = []
    for path in paths:
        try:
            if path.suffix.casefold() == ".pdf":
                document = read_pdf_document(path, spec_root)
            else:
                document = read_text_document(path, spec_root)
            documents.append(document)
        except (OSError, ExtractionError) as exc:
            failures.append(
                {
                    "path": path.relative_to(spec_root).as_posix(),
                    "reason": str(exc),
                }
            )
    return documents, failures


def line_matches(line: str, query: Query, case_sensitive: bool) -> bool:
    candidate = normalise_for_match(line, case_sensitive)
    query_text = normalise_for_match(query.text, case_sensitive)
    if query.mode == "literal":
        return query_text in candidate
    query_terms = tokenise(query.text, case_sensitive)
    candidate_terms = set(tokenise(line, case_sensitive))
    if query.mode == "all_terms":
        return all(term in candidate_terms for term in query_terms)
    if query.mode == "any_term":
        return any(term in candidate_terms for term in query_terms)
    raise AssertionError(f"Unhandled query mode: {query.mode}")


def find_nearest_heading(lines: Sequence[SourceLine], match_index: int) -> dict[str, Any] | None:
    markdown_heading = re.compile(r"^\s{0,3}#{1,6}\s+\S")
    numbered_heading = re.compile(
        r"^\s*(?:section\s+)?(?:\d+(?:\.\d+)*|algorithm\s+\d+|appendix\s+[A-Za-z])\b",
        re.IGNORECASE,
    )
    for index in range(match_index, max(-1, match_index - 80), -1):
        value = lines[index].text.strip()
        if markdown_heading.match(value) or numbered_heading.match(value):
            return {
                "line": lines[index].line,
                "page": lines[index].page,
                "text": value,
            }
    return None


def merge_windows(windows: list[tuple[int, int, list[int]]]) -> list[tuple[int, int, list[int]]]:
    if not windows:
        return []
    windows.sort(key=lambda item: (item[0], item[1]))
    merged: list[tuple[int, int, list[int]]] = []
    current_start, current_end, current_matches = windows[0]
    for start, end, matches in windows[1:]:
        if start <= current_end + 1:
            current_end = max(current_end, end)
            current_matches = sorted(set(current_matches + matches))
        else:
            merged.append((current_start, current_end, current_matches))
            current_start, current_end, current_matches = start, end, matches
    merged.append((current_start, current_end, current_matches))
    return merged


def build_query_result(
    query: Query,
    documents: Sequence[SourceDocument],
    case_sensitive: bool,
    context_lines: int,
    max_matches: int,
) -> dict[str, Any]:
    passages: list[dict[str, Any]] = []
    raw_match_count = 0
    truncated = False

    for document in documents:
        matching_indexes = [
            index
            for index, source_line in enumerate(document.lines)
            if line_matches(source_line.text, query, case_sensitive)
        ]
        raw_match_count += len(matching_indexes)
        windows: list[tuple[int, int, list[int]]] = []
        for index in matching_indexes:
            start = max(0, index - context_lines)
            end = min(len(document.lines) - 1, index + context_lines)
            windows.append((start, end, [index]))
        for start, end, match_indexes in merge_windows(windows):
            if len(passages) >= max_matches:
                truncated = True
                break
            selected = document.lines[start : end + 1]
            start_page = selected[0].page if selected else None
            end_page = selected[-1].page if selected else None
            citation = f"{document.relative_path}:L{selected[0].line}-L{selected[-1].line}"
            if start_page is not None:
                page_label = f"p.{start_page}" if start_page == end_page else f"pp.{start_page}-{end_page}"
                citation += f" ({page_label})"
            passages.append(
                {
                    "citation": citation,
                    "document_sha256": document.sha256,
                    "end_line": selected[-1].line,
                    "end_page": end_page,
                    "heading": find_nearest_heading(document.lines, match_indexes[0]),
                    "matched_lines": [document.lines[item].line for item in match_indexes],
                    "path": document.relative_path,
                    "start_line": selected[0].line,
                    "start_page": start_page,
                    "text": "\n".join(line.text for line in selected),
                }
            )
        if truncated:
            break

    return {
        "id": query.query_id,
        "matched": bool(passages),
        "mode": query.mode,
        "passage_count": len(passages),
        "passages": passages,
        "raw_matching_line_count": raw_match_count,
        "required": query.required,
        "text": query.text,
        "truncated": truncated,
    }


def determine_status(
    query_results: Sequence[dict[str, Any]], skipped: Sequence[dict[str, Any]], failures: Sequence[dict[str, Any]]
) -> tuple[str, list[str]]:
    warnings: list[str] = []
    missing_required = [item["id"] for item in query_results if item["required"] and not item["matched"]]
    missing_optional = [item["id"] for item in query_results if not item["required"] and not item["matched"]]
    truncated = [item["id"] for item in query_results if item["truncated"]]
    if missing_required:
        warnings.append("Required queries without matches: " + ", ".join(missing_required))
    if missing_optional:
        warnings.append("Optional queries without matches: " + ", ".join(missing_optional))
    if truncated:
        warnings.append("Query results truncated at configured limit: " + ", ".join(truncated))
    if skipped:
        warnings.append(f"Skipped {len(skipped)} source path(s); inspect source_manifest.json.")
    if failures:
        warnings.append(f"Failed to extract {len(failures)} source file(s); inspect source_manifest.json.")

    if missing_required:
        return "INCOMPLETE", warnings
    if warnings:
        return "COMPLETE_WITH_WARNINGS", warnings
    return "COMPLETE", warnings


def render_markdown(report: dict[str, Any]) -> str:
    target = report["request"]["target"]
    lines: list[str] = [
        "# ML-KEM Specification Grounding Report",
        "",
        f"- **Skill:** `{SKILL_NAME}` `{SKILL_VERSION}`",
        f"- **Request ID:** `{report['request']['request_id']}`",
        f"- **Status:** `{report['status']}`",
        f"- **Target symbol:** `{target['symbol']}`",
        f"- **Target source file:** `{target['source_file'] or 'not supplied'}`",
        "- **Semantic authority:** None. This report contains lexical retrieval evidence only.",
        "",
        "## Boundary statement",
        "",
        "The utility did not select a theorem, infer assumptions, write assertions, rank properties, or declare implementation correctness.",
        "",
    ]
    if report["warnings"]:
        lines.extend(["## Warnings", ""])
        for warning in report["warnings"]:
            lines.append(f"- {warning}")
        lines.append("")

    lines.extend(["## Query results", ""])
    for result in report["query_results"]:
        lines.extend(
            [
                f"### `{result['id']}` — {result['text']}",
                "",
                f"- Required: `{str(result['required']).lower()}`",
                f"- Mode: `{result['mode']}`",
                f"- Matched: `{str(result['matched']).lower()}`",
                f"- Passages: `{result['passage_count']}`",
                f"- Raw matching lines: `{result['raw_matching_line_count']}`",
                f"- Truncated: `{str(result['truncated']).lower()}`",
                "",
            ]
        )
        if not result["passages"]:
            lines.extend(["No matching passage was found.", ""])
            continue
        for number, passage in enumerate(result["passages"], start=1):
            lines.append(f"#### Passage {number}")
            lines.append("")
            lines.append(f"- Citation: `{passage['citation']}`")
            lines.append(f"- Source SHA-256: `{passage['document_sha256']}`")
            if passage["heading"]:
                lines.append(f"- Nearest heading: `{passage['heading']['text']}`")
            lines.extend(["", "```text", passage["text"], "```", ""])

    lines.extend(
        [
            "## Interpretation limit",
            "",
            "A match means only that the supplied lexical query matched the supplied local corpus. A non-match does not show that the concept is absent from the specification; different wording, extraction limits, or missing source material may explain it.",
            "",
        ]
    )
    return "\n".join(lines)


def execute(request_file: Path, spec_root: Path, output_dir: Path) -> int:
    canonical_request, queries, options = parse_request(request_file)
    root, output = ensure_safe_paths(spec_root, output_dir)
    source_paths, skipped = iter_source_files(root)
    documents, extraction_failures = load_documents(source_paths, root)
    if not documents:
        raise ExtractionError(
            "No supported specification document could be extracted. Supported types: "
            + ", ".join(sorted(SUPPORTED_EXTENSIONS))
        )

    query_results = [
        build_query_result(
            query,
            documents,
            options["case_sensitive"],
            options["context_lines"],
            options["max_matches_per_query"],
        )
        for query in queries
    ]
    status, warnings = determine_status(query_results, skipped, extraction_failures)

    source_manifest = {
        "schema_version": SCHEMA_VERSION,
        "skill": {"name": SKILL_NAME, "version": SKILL_VERSION},
        "spec_root_label": root.name,
        "documents": [
            {
                "extraction_method": document.extraction_method,
                "line_count": len(document.lines),
                "media_type": document.media_type,
                "page_count": document.page_count,
                "path": document.relative_path,
                "sha256": document.sha256,
                "size_bytes": document.size_bytes,
            }
            for document in documents
        ],
        "extraction_failures": extraction_failures,
        "skipped_paths": skipped,
    }
    report = {
        "schema_version": SCHEMA_VERSION,
        "skill": {"name": SKILL_NAME, "version": SKILL_VERSION},
        "status": status,
        "semantic_authority": "NONE",
        "timestamp_policy": "omitted_for_byte_reproducibility",
        "request": canonical_request,
        "corpus_summary": {
            "documents_extracted": len(documents),
            "documents_failed": len(extraction_failures),
            "paths_skipped": len(skipped),
            "source_manifest_sha256": None,
        },
        "warnings": warnings,
        "query_results": query_results,
        "limitations": [
            "Lexical retrieval does not establish semantic relevance or theorem validity.",
            "No-match results may reflect different terminology or incomplete source material.",
            "PDF line numbers refer to deterministic pdftotext extraction; page numbers are also recorded when available.",
        ],
    }

    output.mkdir(parents=True, exist_ok=True)
    stable_json_write(output / "source_manifest.json", source_manifest)
    report["corpus_summary"]["source_manifest_sha256"] = sha256_file(output / "source_manifest.json")
    stable_json_write(output / "grounding_report.json", report)
    (output / "grounding_report.md").write_text(render_markdown(report), encoding="utf-8")
    stable_json_write(output / "canonical_request.json", canonical_request)

    return EXIT_INCOMPLETE if status == "INCOMPLETE" else EXIT_OK


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Deterministically locate and cite lexical specification passages supplied by Codex/researcher. "
            "The utility does not propose verification properties."
        )
    )
    parser.add_argument("--request", required=True, type=Path, help="Path to request JSON.")
    parser.add_argument("--spec-root", required=True, type=Path, help="Local specification corpus directory.")
    parser.add_argument("--output-dir", required=True, type=Path, help="Output evidence directory outside spec root.")
    parser.add_argument("--version", action="version", version=f"%(prog)s {SKILL_VERSION}")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        return execute(args.request, args.spec_root, args.output_dir)
    except InputError as exc:
        print(f"INPUT_ERROR: {exc}", file=sys.stderr)
        return EXIT_INPUT_ERROR
    except ExtractionError as exc:
        print(f"EXTRACTION_ERROR: {exc}", file=sys.stderr)
        return EXIT_EXTRACTION_ERROR
    except Exception as exc:  # Defensive final boundary; details remain visible.
        print(f"INTERNAL_ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        return EXIT_INTERNAL_ERROR


if __name__ == "__main__":
    raise SystemExit(main())
