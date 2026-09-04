#!/usr/bin/env python3
"""
GitHub-rendering compatibility validator for the 03A catalogue.

Static validation (offline):
    python3 docs/thesis-evidence/03A_VALIDATE_GITHUB_RENDER.py

Static + live GitHub Markdown REST rendering:
    python3 docs/thesis-evidence/03A_VALIDATE_GITHUB_RENDER.py --live

The live check uses GitHub's public Markdown rendering endpoint in GFM mode and
requires no token for public-resource rendering according to GitHub's REST docs.
It is a live Markdown-to-HTML transport/render smoke test, not a browser-side
MathJax macro-policy oracle. Macro-policy compatibility is enforced by the static
fail-closed scan. It does not publish or modify repository content.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

E = Path(__file__).resolve().parent
ROOT = E.parent.parent
MASTER = E / "03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md"
CASES = E / "03A_RENDERED_CATALOGUE_CASES"
REPO_CONTEXT = "Girish2052003/girish-nallan-chakravathy-thesis-2026-mlkem-cbmc-verification-case-study-evidences"
API_URL = "https://api.github.com/markdown"
API_VERSION = "2026-03-10"


def extract_math(text: str) -> list[str]:
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    text = re.sub(r"`[^`\n]*`", "", text)
    out: list[str] = []
    spans: list[tuple[int, int]] = []
    for m in re.finditer(r"\$\$(.*?)\$\$", text, flags=re.S):
        out.append(m.group(1))
        spans.append((m.start(), m.end()))
    chars = list(text)
    for a, b in spans:
        chars[a:b] = " " * (b - a)
    masked = "".join(chars)
    out.extend(m.group(1) for m in re.finditer(r"(?<!\$)\$(?!\$)([^\n$]+?)(?<!\$)\$(?!\$)", masked))
    return out


def static_check(files: list[Path]) -> tuple[bool, list[str]]:
    problems: list[str] = []
    mathop_total = 0
    expr_total = 0
    forbidden_patterns = {
        "operatorname": r"\\operatorname\{",
        "newcommand": r"\\newcommand\b",
        "renewcommand": r"\\renewcommand\b",
        "DeclareMathOperator": r"\\DeclareMathOperator\b",
        "def": r"\\def\b",
        "require": r"\\require\b",
    }

    for p in files:
        text = p.read_text(encoding="utf-8")
        exprs = extract_math(text)
        expr_total += len(exprs)
        for expr in exprs:
            mathop_total += expr.count(r"\mathop{\text{")
            if expr.count("{") != expr.count("}"):
                problems.append(f"{p}: unbalanced braces in math expression: {expr[:120]!r}")
            begins = re.findall(r"\\begin\{([^}]+)\}", expr)
            ends = re.findall(r"\\end\{([^}]+)\}", expr)
            if begins != ends:
                problems.append(f"{p}: unbalanced environments begin={begins!r} end={ends!r}")
            for name, pattern in forbidden_patterns.items():
                if re.search(pattern, expr):
                    problems.append(f"{p}: forbidden/risky GitHub math macro {name} in {expr[:120]!r}")

    if len(files) != 19:
        problems.append(f"expected 19 rendered files; got {len(files)}")
    if mathop_total != 116:
        problems.append(f"expected 116 GitHub-safe named-operator forms; got {mathop_total}")

    print(f"STATIC files={len(files)} math_expressions={expr_total} github_safe_named_operators={mathop_total}")
    return not problems, problems


def github_render(text: str) -> str:
    """Render Markdown through GitHub with bounded transient-error retries.

    Retry is limited to transport/service conditions that can reasonably be
    temporary. Semantic/rendering failures are never converted into PASS.
    """
    payload = json.dumps(
        {
            "text": text,
            "mode": "gfm",
            "context": REPO_CONTEXT,
        }
    ).encode("utf-8")

    transient_http = {
        429,
        500,
        502,
        503,
        504,
    }

    max_attempts = 5

    for attempt in range(1, max_attempts + 1):
        headers = {
            "Accept": "text/html",
            "Content-Type": "application/json",
            "User-Agent": "03A-GitHub-Render-Validator",
            "X-GitHub-Api-Version": API_VERSION,
        }

        github_token = os.environ.get(
            "GITHUB_TOKEN",
            "",
        ).strip()

        if github_token:
            headers["Authorization"] = (
                f"Bearer {github_token}"
            )

        req = urllib.request.Request(
            API_URL,
            data=payload,
            method="POST",
            headers=headers,
        )

        try:
            with urllib.request.urlopen(
                req,
                timeout=45,
            ) as resp:
                if resp.status != 200:
                    raise RuntimeError(
                        "GitHub Markdown API returned "
                        f"HTTP {resp.status}"
                    )

                return resp.read().decode(
                    "utf-8",
                    errors="replace",
                )

        except urllib.error.HTTPError as exc:
            if (
                exc.code not in transient_http
                or attempt == max_attempts
            ):
                raise

            retry_after = None

            if exc.headers is not None:
                retry_after = exc.headers.get(
                    "Retry-After"
                )

            if (
                retry_after is not None
                and retry_after.isdigit()
            ):
                delay = min(
                    max(int(retry_after), 1),
                    30,
                )
            else:
                delay = min(
                    2 ** attempt,
                    16,
                )

            print(
                "LIVE RETRY: "
                f"HTTP {exc.code}; "
                f"attempt {attempt}/{max_attempts}; "
                f"retrying in {delay}s"
            )

            time.sleep(delay)

        except (
            urllib.error.URLError,
            TimeoutError,
        ) as exc:
            if attempt == max_attempts:
                raise

            delay = min(
                2 ** attempt,
                16,
            )

            print(
                "LIVE RETRY: "
                f"{type(exc).__name__}: {exc}; "
                f"attempt {attempt}/{max_attempts}; "
                f"retrying in {delay}s"
            )

            time.sleep(delay)

    raise RuntimeError(
        "GitHub Markdown API retry loop exhausted"
    )


def live_check(files: list[Path]) -> tuple[bool, list[str]]:
    r"""Run a live GitHub Markdown REST transport/render smoke test.

    Important boundary: GitHub's REST Markdown endpoint is a Markdown-to-HTML
    service. It does not promise to execute or expose the browser-side MathJax
    macro-policy layer. Therefore this live gate MUST NOT use a known-bad
    ``\operatorname`` expression as a sensitivity oracle. Macro-policy safety is
    established by the static fail-closed scan above, which rejects
    ``\operatorname`` and custom-definition macros and requires the exact
    GitHub-safe ``\mathop{\text{...}}`` normalization.

    The live gate instead verifies that GitHub accepts each complete document in
    GFM mode, returns non-empty HTML, and does not return an explicit math-macro
    error if one is surfaced by the service.
    """
    problems: list[str] = []

    # Positive control only. The REST API is not a valid negative-control oracle
    # for browser-side MathJax policy, but it must at least accept the normalized
    # form used by this catalogue.
    try:
        good_html = github_render(r"$\mathop{\text{P}}(A)=1$")
    except Exception as exc:
        return False, [f"GitHub render positive-control request failed: {exc}"]

    good_lower = good_html.lower()
    if not good_html.strip():
        problems.append("GitHub Markdown REST endpoint returned empty HTML for the mathop/text positive control.")
    if "macros are not allowed" in good_lower or "the following macros are not allowed" in good_lower:
        problems.append("GitHub Markdown REST endpoint rejected the GitHub-safe mathop/text positive control.")
    if problems:
        return False, problems

    print("LIVE CONTROL PASS: GitHub Markdown REST endpoint accepted mathop/text positive control")

    for p in files:
        try:
            html = github_render(p.read_text(encoding="utf-8"))
        except Exception as exc:
            problems.append(f"{p}: live render request failed: {exc}")
            continue
        lowered = html.lower()
        if "the following macros are not allowed" in lowered or "macros are not allowed" in lowered:
            problems.append(f"{p}: GitHub REST response exposed a blocked-macro rendering error")
        if not html.strip():
            problems.append(f"{p}: GitHub returned empty HTML")
        else:
            print(
                f"LIVE PASS: {p.relative_to(ROOT)} "
                f"bytes_in={p.stat().st_size} bytes_html={len(html.encode('utf-8'))}"
            )
    return not problems, problems


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--live", action="store_true", help="also POST every rendered file to GitHub's Markdown API")
    args = parser.parse_args()

    files = [MASTER] + sorted(CASES.glob("*.md"))
    if not all(p.is_file() for p in files):
        print("FAIL: one or more rendered catalogue files are missing", file=sys.stderr)
        return 1

    ok, problems = static_check(files)
    if problems:
        print("\nSTATIC PROBLEMS")
        for problem in problems:
            print("-", problem)
    if not ok:
        return 1
    print("STATIC GITHUB-MATH COMPATIBILITY: PASS")

    if args.live:
        live_ok, live_problems = live_check(files)
        if live_problems:
            print("\nLIVE PROBLEMS")
            for problem in live_problems:
                print("-", problem)
        if not live_ok:
            return 1
        print("LIVE GITHUB MARKDOWN API SMOKE: PASS (19/19); macro policy = STATIC GATE")
    else:
        print("LIVE GITHUB MARKDOWN RENDERING: NOT RUN (use --live before push)")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
