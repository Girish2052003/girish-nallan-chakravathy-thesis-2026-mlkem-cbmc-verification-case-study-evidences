#!/usr/bin/env python3
"""
PA-05 Step 1: Collect exact production call-site context for mlk_poly_add.

Run from the root of the frozen mlkem-native repository:

    python3 collect_pa05_mlk_poly_add_callsite_context.py

The script does not modify production source. It creates one Markdown bundle
containing the exact call sites, enclosing caller functions, nearby source,
relevant type/parameter declarations, formal annotations, and build metadata.

That bundle is the deterministic input for generating PA-05A/PA-05B/PA-05C
caller-context CBMC harnesses.
"""

from __future__ import annotations

import datetime as _dt
import hashlib
import os
from pathlib import Path
import re
import subprocess
import sys
from typing import Iterable

EXPECTED_COMMIT = "d9613cf60de3132d32475c102d8c2781d84feb34"
TARGET_CALL = "mlk_poly_add("

REPO_ROOT = Path.cwd()
SRC_ROOT = REPO_ROOT / "mlkem" / "src"


def run(command: list[str], *, check: bool = True) -> str:
    result = subprocess.run(
        command,
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if check and result.returncode != 0:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {' '.join(command)}\n"
            f"{result.stdout}"
        )
    return result.stdout.rstrip()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def numbered(lines: list[str], start_line: int = 1) -> str:
    width = len(str(start_line + len(lines)))
    return "\n".join(
        f"{start_line + index:>{width}} | {line}"
        for index, line in enumerate(lines)
    )


def strip_comments_and_strings(text: str) -> str:
    """
    Preserve line count and character positions approximately while replacing
    comments and string/character literal contents with spaces.
    """
    output: list[str] = []
    i = 0
    state = "code"

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""

        if state == "code":
            if ch == "/" and nxt == "*":
                output.extend("  ")
                i += 2
                state = "block_comment"
                continue
            if ch == "/" and nxt == "/":
                output.extend("  ")
                i += 2
                state = "line_comment"
                continue
            if ch == '"':
                output.append(" ")
                i += 1
                state = "string"
                continue
            if ch == "'":
                output.append(" ")
                i += 1
                state = "char"
                continue
            output.append(ch)
            i += 1
            continue

        if state == "block_comment":
            if ch == "*" and nxt == "/":
                output.extend("  ")
                i += 2
                state = "code"
            else:
                output.append("\n" if ch == "\n" else " ")
                i += 1
            continue

        if state == "line_comment":
            if ch == "\n":
                output.append("\n")
                state = "code"
            else:
                output.append(" ")
            i += 1
            continue

        if state in {"string", "char"}:
            delimiter = '"' if state == "string" else "'"
            if ch == "\\" and i + 1 < len(text):
                output.extend("  ")
                i += 2
                continue
            if ch == delimiter:
                output.append(" ")
                i += 1
                state = "code"
                continue
            output.append("\n" if ch == "\n" else " ")
            i += 1
            continue

    return "".join(output)


def line_for_offset(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def find_enclosing_top_level_block(
    source_text: str, target_offset: int
) -> tuple[int, int]:
    """
    Return 1-based inclusive start/end lines of the top-level brace block
    containing target_offset. For a C source call site, this is the enclosing
    function body plus a conservative signature/annotation prefix.
    """
    cleaned = strip_comments_and_strings(source_text)

    stack: list[int] = []
    containing_open: int | None = None

    for index, ch in enumerate(cleaned):
        if index > target_offset:
            break
        if ch == "{":
            stack.append(index)
        elif ch == "}" and stack:
            stack.pop()

    if not stack:
        raise RuntimeError("Could not locate enclosing brace block.")

    # The first open brace in the active stack is the top-level enclosing block.
    containing_open = stack[0]

    depth = 0
    close_offset: int | None = None
    for index in range(containing_open, len(cleaned)):
        ch = cleaned[index]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                close_offset = index
                break

    if close_offset is None:
        raise RuntimeError("Could not locate end of enclosing brace block.")

    open_line = line_for_offset(source_text, containing_open)
    close_line = line_for_offset(source_text, close_offset)

    lines = source_text.splitlines()

    # Extend upward to include multiline signature, attributes, and contracts.
    start_line = open_line
    cursor = open_line - 1
    while cursor > 0:
        previous = lines[cursor - 1].strip()
        if not previous:
            start_line = cursor
            cursor -= 1
            continue
        if previous.startswith("#"):
            break
        if previous.endswith(";") and "__contract__" not in previous:
            break
        if previous == "}":
            break
        start_line = cursor
        cursor -= 1

    return start_line, close_line


def find_calls() -> list[tuple[Path, int, str, int]]:
    calls: list[tuple[Path, int, str, int]] = []

    for path in sorted(SRC_ROOT.rglob("*.c")):
        text = path.read_text(encoding="utf-8")
        for line_number, line in enumerate(text.splitlines(), start=1):
            stripped = line.strip()
            if TARGET_CALL not in line:
                continue
            # Exclude the function definition itself.
            if re.search(r"\bvoid\s+mlk_poly_add\s*\(", line):
                continue
            # Exclude obvious comments.
            if stripped.startswith("//") or stripped.startswith("*"):
                continue

            line_start_offset = sum(
                len(item) + 1 for item in text.splitlines()[: line_number - 1]
            )
            call_offset = line_start_offset + line.index(TARGET_CALL)
            calls.append((path, line_number, line.rstrip(), call_offset))

    return calls


def extract_window(path: Path, center: int, radius: int = 80) -> tuple[int, list[str]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    start = max(1, center - radius)
    end = min(len(lines), center + radius)
    return start, lines[start - 1 : end]


def grep_patterns(paths: Iterable[Path], patterns: list[str]) -> str:
    sections: list[str] = []
    for path in paths:
        if not path.exists():
            continue
        lines = path.read_text(encoding="utf-8").splitlines()
        matches: list[str] = []
        for index, line in enumerate(lines, start=1):
            if any(pattern in line for pattern in patterns):
                matches.append(f"{path.relative_to(REPO_ROOT)}:{index}: {line}")
        if matches:
            sections.extend(matches)
    return "\n".join(sections)


def main() -> int:
    if not SRC_ROOT.is_dir():
        print(
            "ERROR: run this script from the mlkem-native repository root.",
            file=sys.stderr,
        )
        return 2

    actual_commit = run(["git", "rev-parse", "HEAD"])
    if actual_commit != EXPECTED_COMMIT:
        print("ERROR: repository commit mismatch.", file=sys.stderr)
        print(f"Expected: {EXPECTED_COMMIT}", file=sys.stderr)
        print(f"Actual:   {actual_commit}", file=sys.stderr)
        return 3

    calls = find_calls()
    if len(calls) != 3:
        print(
            f"ERROR: expected exactly 3 production mlk_poly_add calls, "
            f"found {len(calls)}.",
            file=sys.stderr,
        )
        for path, line_number, line, _ in calls:
            print(f"  {path}:{line_number}: {line}", file=sys.stderr)
        return 4

    timestamp = _dt.datetime.now(_dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    output_path = REPO_ROOT / f"PA05_MLK_POLY_ADD_CALLSITE_CONTEXT_{timestamp}.md"

    relevant_headers = [
        SRC_ROOT / "poly.h",
        SRC_ROOT / "poly_k.h",
        SRC_ROOT / "params.h",
        SRC_ROOT / "common.h",
        SRC_ROOT / "indcpa.h",
    ]

    report: list[str] = []
    report.append("# PA-05 `mlk_poly_add` Production Call-Site Context Bundle")
    report.append("")
    report.append("## 1. Collection Identity")
    report.append("")
    report.append(f"- Repository root: `{REPO_ROOT}`")
    report.append(f"- Commit: `{actual_commit}`")
    report.append("- Parameter-set analysis target: `ML-KEM-768`")
    report.append(f"- Production calls found: `{len(calls)}`")
    report.append("- Production source modified: `No`")
    report.append("")
    report.append("## 2. Git Status")
    report.append("")
    report.append("```text")
    report.append(run(["git", "status", "--short"], check=False) or "(clean)")
    report.append("```")
    report.append("")
    report.append("## 3. All `mlk_poly_add` References")
    report.append("")
    report.append("```text")
    report.append(
        run(
            [
                "git",
                "grep",
                "-n",
                r"mlk_poly_add",
                "--",
                "mlkem/src",
            ],
            check=False,
        )
    )
    report.append("```")
    report.append("")

    for call_index, (path, line_number, line, call_offset) in enumerate(
        calls, start=1
    ):
        relative = path.relative_to(REPO_ROOT)
        text = path.read_text(encoding="utf-8")
        source_lines = text.splitlines()
        function_start, function_end = find_enclosing_top_level_block(
            text, call_offset
        )
        window_start, window_lines = extract_window(path, line_number, 80)

        report.append(
            f"## 4.{call_index}. Call Site {call_index}: "
            f"`{relative}:{line_number}`"
        )
        report.append("")
        report.append("### Exact call")
        report.append("")
        report.append("```c")
        report.append(line.strip())
        report.append("```")
        report.append("")
        report.append("### Enclosing production function")
        report.append("")
        report.append("```c")
        report.append(
            numbered(
                source_lines[function_start - 1 : function_end],
                function_start,
            )
        )
        report.append("```")
        report.append("")
        report.append("### Local context window")
        report.append("")
        report.append("```c")
        report.append(numbered(window_lines, window_start))
        report.append("```")
        report.append("")

    report.append("## 5. Relevant Type, Parameter, and Contract Lines")
    report.append("")
    report.append("```text")
    report.append(
        grep_patterns(
            relevant_headers + [SRC_ROOT / "poly.c", SRC_ROOT / "poly_k.c",
                                SRC_ROOT / "indcpa.c"],
            [
                "typedef struct",
                "mlk_poly",
                "mlk_polyvec",
                "MLKEM_N",
                "MLKEM_Q",
                "MLKEM_K",
                "__contract__",
                "__loop__",
                "requires(",
                "ensures(",
                "assigns(",
                "invariant(",
                "mlk_poly_add",
            ],
        )
    )
    report.append("```")
    report.append("")

    report.append("## 6. Relevant Header Files")
    report.append("")
    for header in relevant_headers:
        if not header.exists():
            continue
        report.append(f"### `{header.relative_to(REPO_ROOT)}`")
        report.append("")
        report.append("```c")
        report.append(header.read_text(encoding="utf-8").rstrip())
        report.append("```")
        report.append("")

    report.append("## 7. Source File Hashes")
    report.append("")
    report.append("```text")
    for path in sorted(
        {
            *(call[0] for call in calls),
            *(header for header in relevant_headers if header.exists()),
            SRC_ROOT / "poly.c",
        }
    ):
        if path.exists():
            report.append(
                f"{sha256_file(path)}  {path.relative_to(REPO_ROOT)}"
            )
    report.append("```")
    report.append("")

    report.append("## 8. Next Deterministic PA-05 Action")
    report.append("")
    report.append(
        "Use this bundle to derive one caller-context verification unit for "
        "each production call. No coefficient bound, aliasing condition, or "
        "caller precondition should be guessed before analysing these exact "
        "functions and their producer operations."
    )
    report.append("")

    output_path.write_text("\n".join(report), encoding="utf-8")

    print("PA-05 context collection completed.")
    print(f"Output: {output_path.name}")
    print(f"SHA-256: {sha256_file(output_path)}")
    print("")
    print("Upload or paste the generated Markdown bundle for PA-05 harness generation.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
