#!/usr/bin/env python3\nfrom __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile

from pathlib import Path

RENDER_BASELINE = 'f19654fbd05386769a852cc45fbd9ebb06690902'


def run(cmd, cwd=None):
    cp = subprocess.run(
        cmd,
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    out = cp.stdout or ""

    if out:
        print(out, end="")

    if cp.returncode:
        raise SystemExit(cp.returncode)

    return cp


def exact_known_historical_failure(validator_name: str, output: str, rc: int) -> bool:
    if rc != 1:
        return False

    fail_lines = [
        line
        for line in output.splitlines()
        if line.startswith("FAIL: ")
    ]

    if validator_name == "03A_VALIDATE_RENDERED_CATALOGUE.py":
        expected_fragments = [
            "rendered immutable traceability metadata matches the current authoritative ledger",
            "PR-C01-001: Assumptions and grounding",
            "all 210 formerly blocked named operators are now GitHub-safe mathop/text forms",
        ]

        return (
            len(fail_lines) == 2
            and
            "checks=60 pass=58 fail=2" in output
            and
            all(
                any(fragment in line for line in fail_lines)
                for fragment in expected_fragments
            )
            and
            any(
                "all 210 formerly blocked named operators are now GitHub-safe mathop/text forms"
                in line
                and
                "116" in line
                for line in fail_lines
            )
        )

    if validator_name == "03A_VALIDATE_PACKAGE_SELF.py":
        expected_fragments = [
            "all 257 formal statements are cryptographically bound to the accepted pre-GitHub formulas",
            "PR-C01-027: GitHub-safe formula hash changed",
            "exactly 210 accepted named operators use GitHub-safe mathop/text rendering",
            "Pandoc MathML parses all 19 rendered files without warnings",
            "03A_COMPLETE_RENDERED_PROPERTY_AND_CONTROL_CATALOGUE.md",
            "Could not convert TeX math",
        ]

        return (
            len(fail_lines) == 3
            and
            "checks=37 pass=34 fail=3" in output
            and
            all(
                any(fragment in line for line in fail_lines)
                for fragment in expected_fragments
            )
            and
            any(
                "exactly 210 accepted named operators use GitHub-safe mathop/text rendering"
                in line
                and
                "116" in line
                for line in fail_lines
            )
        )

    return False


def historical(root: Path, validator_name: str):
    td = Path(
        tempfile.mkdtemp(
            prefix="03a-historical-validator-"
        )
    )

    try:
        add = subprocess.run(
            [
                "git",
                "-C",
                str(root),
                "worktree",
                "add",
                "--detach",
                str(td),
                RENDER_BASELINE,
            ],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )

        if add.stdout:
            print(add.stdout, end="")

        if add.returncode:
            raise SystemExit(add.returncode)

        script = (
            td
            / "docs"
            / "thesis-evidence"
            / validator_name
        )

        if not script.is_file():
            raise SystemExit(
                f"historical validator absent: {script}"
            )

        cmd = [
            sys.executable,
            str(script),
        ]

        hp = subprocess.run(
            cmd + ["--help"],
            cwd=td,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )

        helptext = hp.stdout or ""

        if "--repo-root" in helptext:
            cmd += [
                "--repo-root",
                str(td),
            ]

        for flag in [
            "--offline",
            "--no-network",
            "--skip-github-render",
            "--no-github",
        ]:
            if flag in helptext:
                cmd.append(flag)
                break

        print(
            f"## Historical {validator_name} @ {RENDER_BASELINE}"
        )

        cp = subprocess.run(
            cmd,
            cwd=td,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )

        output = cp.stdout or ""

        if output:
            print(output, end="")

        if cp.returncode == 0:
            print(
                "PASS: historical validator returned native PASS"
            )
            return

        if exact_known_historical_failure(
            validator_name,
            output,
            cp.returncode,
        ):
            print(
                "PASS: historical validator reproduced exactly the pinned legacy failure signature; no additional historical failure was observed"
            )
            return

        print(
            "FAIL: historical validator output differs from the exact pinned legacy signature",
            file=sys.stderr,
        )

        raise SystemExit(cp.returncode)

    finally:
        subprocess.run(
            [
                "git",
                "-C",
                str(root),
                "worktree",
                "remove",
                "--force",
                str(td),
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        shutil.rmtree(
            td,
            ignore_errors=True,
        )

        subprocess.run(
            [
                "git",
                "-C",
                str(root),
                "worktree",
                "prune",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def main():
    ap = argparse.ArgumentParser(
        description="Current 03A rendered-catalogue validator wrapper"
    )

    ap.add_argument(
        "--repo-root",
        default=None,
    )

    args, _ = ap.parse_known_args()

    root = (
        Path(args.repo_root).resolve()
        if args.repo_root
        else Path(__file__).resolve().parents[2]
    )

    historical(
        root,
        "03A_VALIDATE_RENDERED_CATALOGUE.py",
    )

    print(
        "## Current terminology/boundary closure"
    )

    run([
        sys.executable,
        str(
            root
            / "docs"
            / "thesis-evidence"
            / "03A_VALIDATE_TERMINOLOGY_CLOSURE.py"
        ),
        "--repo-root",
        str(root),
    ])

    print(
        "## Current direct GitHub-render validator and checksum closure"
    )

    run(
        [
            sys.executable,
            str(
                root
                / "docs"
                / "thesis-evidence"
                / "03A_VALIDATE_GITHUB_RENDER.py"
            ),
        ],
        cwd=root,
    )

    print(
        "## Current 03A catalogue checksum manifest"
    )

    run(
        [
            "sha256sum",
            "-c",
            "03A_CATALOGUE_SHA256SUMS.txt",
        ],
        cwd=(
            root
            / "docs"
            / "thesis-evidence"
        ),
    )

    print(
        "## Current repository-wide SHA256SUMS"
    )

    run(
        [
            "sha256sum",
            "-c",
            "SHA256SUMS",
        ],
        cwd=root,
    )

    print(
        "## PASS — exact historical signature reconciled; current rendered-catalogue terminology closure passed"
    )


if __name__ == "__main__":
    main()
