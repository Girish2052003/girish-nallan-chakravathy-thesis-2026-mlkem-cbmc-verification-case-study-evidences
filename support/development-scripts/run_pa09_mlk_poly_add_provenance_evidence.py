#!/usr/bin/env python3
"""
PA-09 Stage 1: strict novelty and provenance evidence collection for the
independently authored mlk_poly_add verification campaign.

Run from the frozen mlkem-native repository root:

    python3 run_pa09_mlk_poly_add_provenance_evidence.py

This script does not make the final semantic novelty judgement by itself.
It creates a deterministic evidence bundle for that judgement.

The script:

  * verifies the frozen repository revision and production poly.c identity;
  * verifies the exact hashes of all required PA-01 through PA-08 authored
    source artefacts;
  * reads original repository artefacts directly from the frozen Git commit;
  * collects the original proofs/cbmc/poly_add directory and every tracked
    file that directly references mlk_poly_add or poly_add;
  * records contracts, assertions, assumptions, loop annotations, and target
    references;
  * computes exact and mechanical text-similarity comparisons;
  * embeds all relevant repository and authored artefacts in one Markdown
    evidence bundle;
  * emits a summary whose successful status is:

        PA09_EVIDENCE_BUNDLE_READY_FOR_SEMANTIC_AUDIT

The final PA-09 conclusion must be issued only after semantic review of the
generated evidence bundle. Textual difference is not automatically proof of
intellectual independence, and textual similarity is not automatically proof
of copying.
"""

from __future__ import annotations

import csv
import datetime as dt
import difflib
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
from typing import Any

EXPECTED_COMMIT = "d9613cf60de3132d32475c102d8c2781d84feb34"
EXPECTED_POLY_C_SHA256 = (
    "f427dda46e29d53d3e33d683c9a8483bade3568eff43fb97b868a21bfd07c722"
)

REQUIRED_AUTHORED: dict[str, str] = {
    "cleanroom_mlk_poly_add_fips_relational_harness_v2.c":
        "307dce610586398ad3d7196790e28e9ee0656ee8b879741cfff81fd72b3a550e",
    "run_cleanroom_mlk_poly_add_cbmc_v2.sh":
        "eeb5b1c1a88689e9219d704ec56fcc97b44ec8676ac1c391106adcd4243980f6",
    "pa02_mlk_poly_add_full_signed_contract_valid_harness.c":
        "e83d521e23f93c2435058598be5ef245bb02c554a4b7992dd8844418720c2ce2",
    "run_pa02_mlk_poly_add_full_signed_cbmc.sh":
        "7068aa8be8e763e7622b7a5767031eb1fa6f4a557f4b9a0507befbb0c346ffee",
    "pa03_mlk_poly_add_unrestricted_negative_control_harness.c":
        "37f9893284959fc9406d7e4bee06848b7c4e9e1cf717fe3c0d699ac5ca0f2487",
    "run_pa03_mlk_poly_add_unrestricted_negative_control.sh":
        "d2a628b547ceae17713b995a99244c9bfef761b8993be060eb71518627317f5d",
    "pa04a_mlk_poly_add_alias_safe_doubling_harness.c":
        "d03869edcf12179e98feff2d1ddb84025474a13ac133fc140040615eddd6d4a4",
    "pa04b_mlk_poly_add_alias_unrestricted_negative_control_harness.c":
        "de2e0689d3470cf992533912e6689ac223d8408967b42e8082ac46af8545e528",
    "run_pa04_mlk_poly_add_aliasing_campaign.sh":
        "df15493e874057bc7e35516af8043be86399c131bc7f4a8ab99bd3744666a82c",
    "pa05a_mlk_poly_add_polyvec_production_callsite_harness.c":
        "ef23dd1db28254c88fcf9216759dce7cade46138dc5fc6c2e56a59bcf101a87e",
    "pa05b_mlk_poly_add_indcpa_epp_callsite_harness.c":
        "8241d0631bb02aa7191e741fae1f2785e03e7c016b3a510dc74d7908c34ce7bc",
    "pa05c_mlk_poly_add_indcpa_k_sequential_callsite_harness.c":
        "8fd2643b21675324cc2de2e9e65dd2deacd50f796ab288cab71cf1882f0fb6e0",
    "run_pa05_mlk_poly_add_production_callsites.sh":
        "3547108f805d9a89e5c5121249de1c6e7d7db48a20636ecc5dd702f22b78a34d",
    "pa06a_mlk_poly_add_polyvec_cross_parameter_harness.c":
        "0941baf262a7a15c1f8be69a6c571c2727d4ab5de0ff16d0f3a364c8e3cb2ddd",
    "pa06b_mlk_poly_add_indcpa_epp_cross_parameter_harness.c":
        "e639524d557a13410d47ad7e1078955332a758d23fd46c1d444a7f77ba327644",
    "pa06c_mlk_poly_add_indcpa_sequential_cross_parameter_harness.c":
        "b008285e11c0e05286338657b4529087e605a92f95f5689a0d1e279a46821b44",
    "run_pa06_mlk_poly_add_cross_parameter_campaign.sh":
        "7e88e942c81893a25f23c54ad3f4ee9115f5e4df1a849d924df7bbe8df967014",
    "pa07_mlk_poly_add_mutant_implementation.c":
        "4a0a231c050013cd73fbb7b5a07237218decb1a58ae3f9007a465adaa35b01ff",
    "run_pa07_mlk_poly_add_mutation_sensitivity.sh":
        "905f081214b6f64e192b5d7744368e4b09957b511acfce8cea805002320701ce",
    "pa08a_mlk_poly_add_boundary_hardening_harness.c":
        "1f7967136b275110519ba247f182d7f11ab4d36288493bd5e571d7a2dc584dee",
    "pa08b_mlk_poly_add_reachability_sentinel_harness.c":
        "38fbbd821e2ac13c4a85fca813425b4cbafe15ec9f72ca54b85fce5599fc6428",
    "pa08c_mlk_poly_add_upper_outside_boundary_harness.c":
        "36f2a6c423e1303570d25019db0d538e13a1f50135ae0f11e798636537fb891d",
    "pa08d_mlk_poly_add_lower_outside_boundary_harness.c":
        "6e484118e522d54c67d043e2a9d209df8a64e3af290666bc3d74cbb8b5c425ed",
    "run_pa08_mlk_poly_add_vacuity_boundary_campaign.sh":
        "ff76bd70e3c876712a978127d10fc1f17788b1dda5818a8bbbc56c24e2f77859",
}

OPTIONAL_REPORTS = [
    "MLK_POLY_ADD_CLEANROOM_CBMC_A_TO_Z_EXPERIMENT_RECORD.md",
    "MLK_POLY_ADD_PA02_FULL_SIGNED_DOMAIN_CBMC_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA03_UNRESTRICTED_NEGATIVE_CONTROL_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA04_ALIASING_DIAGNOSTIC_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA05_PRODUCTION_CALLSITE_VERIFICATION_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA06_CROSS_PARAMETER_REPLICATION_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA07_MUTATION_SENSITIVITY_A_TO_Z_RECORD.md",
    "MLK_POLY_ADD_PA08_VACUITY_REACHABILITY_BOUNDARIES_A_TO_Z_RECORD.md",
]

MANDATORY_REPOSITORY_PATHS = {
    "mlkem/src/poly.c",
    "mlkem/src/poly.h",
    "mlkem/src/poly_k.c",
    "mlkem/src/poly_k.h",
    "mlkem/src/indcpa.c",
    "proofs/cbmc/README.md",
    "SOUNDNESS.md",
}

TARGET_RE = re.compile(
    r"\bmlk_poly_add\b|\bpoly_add\b|MLK_NAMESPACE\s*\(\s*poly_add\s*\)",
    re.IGNORECASE,
)

TEXT_SUFFIXES = {
    ".c", ".h", ".cc", ".cpp", ".hpp", ".i",
    ".md", ".txt", ".rst", ".json", ".yaml", ".yml",
    ".toml", ".sh", ".py", ".cmake",
}

ANNOTATION_PATTERNS = (
    "__CPROVER_assert",
    "__CPROVER_assume",
    "__contract__",
    "__loop__",
    "requires(",
    "ensures(",
    "assigns(",
    "invariant(",
    "decreases(",
)

REPO_ROOT = Path.cwd()


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
    return result.stdout.rstrip("\n")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def git_file_bytes(path: str) -> bytes:
    result = subprocess.run(
        ["git", "show", f"{EXPECTED_COMMIT}:{path}"],
        cwd=REPO_ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"Unable to read frozen repository path {path}:\n"
            f"{result.stderr.decode('utf-8', errors='replace')}"
        )
    return result.stdout


def git_file_text(path: str) -> str:
    return git_file_bytes(path).decode("utf-8", errors="replace")


def git_tree_paths(prefix: str | None = None) -> list[str]:
    command = ["git", "ls-tree", "-r", "--name-only", EXPECTED_COMMIT]
    if prefix:
        command.extend(["--", prefix])
    output = run(command)
    return sorted(line for line in output.splitlines() if line)


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", " ", text)
    return text


def normalized_text(text: str) -> str:
    return re.sub(r"\s+", "", strip_comments(text).lower())


def token_stream(text: str) -> list[str]:
    return re.findall(
        r"[A-Za-z_][A-Za-z0-9_]*|"
        r"0[xX][0-9A-Fa-f]+|\d+|"
        r"==|!=|<=|>=|\+\+|--|&&|\|\||<<|>>|->|"
        r"[{}()\[\];,+\-*/%<>=!&|^~?:.]",
        strip_comments(text),
    )


def significant_lines(text: str) -> set[str]:
    lines: set[str] = set()
    for raw in strip_comments(text).splitlines():
        line = re.sub(r"\s+", " ", raw.strip())
        if len(line) < 8:
            continue
        if line.startswith("#include"):
            continue
        if line in {"return 0;", "return;", "{", "}"}:
            continue
        lines.add(line)
    return lines


def jaccard(first: set[str], second: set[str]) -> float:
    union = first | second
    if not union:
        return 1.0
    return len(first & second) / len(union)


def mechanical_classification(
    exact_binary: bool,
    exact_normalized: bool,
    sequence_ratio: float,
    token_jaccard: float,
    line_jaccard: float,
) -> str:
    if exact_binary:
        return "exact-binary-duplicate"
    if exact_normalized:
        return "normalized-text-duplicate"
    if sequence_ratio >= 0.85 or token_jaccard >= 0.80:
        return "high-mechanical-similarity-review-required"
    if sequence_ratio >= 0.55 or token_jaccard >= 0.55 or line_jaccard >= 0.45:
        return "moderate-structural-overlap"
    return "low-mechanical-overlap"


def fenced(path: str, text: str) -> str:
    suffix = Path(path).suffix.lower()
    language = {
        ".c": "c",
        ".h": "c",
        ".cc": "cpp",
        ".cpp": "cpp",
        ".sh": "bash",
        ".py": "python",
        ".json": "json",
        ".md": "markdown",
        ".yaml": "yaml",
        ".yml": "yaml",
        ".toml": "toml",
    }.get(suffix, "text")

    fence = "```"
    while fence in text:
        fence += "`"
    return f"{fence}{language}\n{text.rstrip()}\n{fence}"


def write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    if not rows:
        path.write_text("", encoding="utf-8")
        return

    fields = list(rows[0].keys())
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def collect_annotation_lines(
    origin: str,
    path: str,
    text: str,
) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        if TARGET_RE.search(line) or any(pattern in line for pattern in ANNOTATION_PATTERNS):
            rows.append({
                "origin": origin,
                "path": path,
                "line": line_number,
                "text": line.rstrip(),
            })
    return rows


def main() -> int:
    if not (REPO_ROOT / ".git").is_dir():
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

    current_poly = REPO_ROOT / "mlkem" / "src" / "poly.c"
    if not current_poly.is_file():
        print("ERROR: production mlkem/src/poly.c is missing.", file=sys.stderr)
        return 4

    tracked_poly_diff = subprocess.run(
        ["git", "diff", "--quiet", "--", "mlkem/src/poly.c"],
        cwd=REPO_ROOT,
        check=False,
    ).returncode
    if tracked_poly_diff != 0:
        print(
            "ERROR: production mlkem/src/poly.c has tracked modifications.",
            file=sys.stderr,
        )
        return 4

    current_poly_hash = sha256_file(current_poly)
    frozen_poly_hash = sha256_bytes(git_file_bytes("mlkem/src/poly.c"))

    if current_poly_hash != EXPECTED_POLY_C_SHA256:
        print("ERROR: working-tree poly.c hash mismatch.", file=sys.stderr)
        print(f"Expected: {EXPECTED_POLY_C_SHA256}", file=sys.stderr)
        print(f"Actual:   {current_poly_hash}", file=sys.stderr)
        return 5

    if frozen_poly_hash != EXPECTED_POLY_C_SHA256:
        print("ERROR: frozen-commit poly.c hash mismatch.", file=sys.stderr)
        print(f"Expected: {EXPECTED_POLY_C_SHA256}", file=sys.stderr)
        print(f"Actual:   {frozen_poly_hash}", file=sys.stderr)
        return 5

    authored_manifest: list[dict[str, Any]] = []
    missing: list[str] = []
    mismatched: list[str] = []

    for filename, expected_hash in REQUIRED_AUTHORED.items():
        path = REPO_ROOT / filename
        if not path.is_file():
            missing.append(filename)
            authored_manifest.append({
                "file": filename,
                "present": "no",
                "expected_sha256": expected_hash,
                "actual_sha256": "",
                "hash_verified": "no",
                "size_bytes": 0,
            })
            continue

        actual_hash = sha256_file(path)
        verified = actual_hash == expected_hash
        if not verified:
            mismatched.append(filename)

        authored_manifest.append({
            "file": filename,
            "present": "yes",
            "expected_sha256": expected_hash,
            "actual_sha256": actual_hash,
            "hash_verified": "yes" if verified else "no",
            "size_bytes": path.stat().st_size,
        })

    if missing or mismatched:
        print("ERROR: PA-01 through PA-08 artefact freeze failed.", file=sys.stderr)
        if missing:
            print("Missing files:", file=sys.stderr)
            for filename in missing:
                print(f"  {filename}", file=sys.stderr)
        if mismatched:
            print("Hash mismatches:", file=sys.stderr)
            for filename in mismatched:
                print(f"  {filename}", file=sys.stderr)
        return 6

    proof_directory_paths = git_tree_paths("proofs/cbmc/poly_add")
    if not proof_directory_paths:
        print(
            "ERROR: frozen repository contains no proofs/cbmc/poly_add directory.",
            file=sys.stderr,
        )
        return 7

    all_repo_paths = git_tree_paths()
    direct_reference_rows: list[dict[str, Any]] = []
    direct_reference_paths: set[str] = set()

    for path in all_repo_paths:
        suffix = Path(path).suffix.lower()
        if suffix not in TEXT_SUFFIXES and Path(path).name not in {
            "Makefile",
            "CMakeLists.txt",
        }:
            continue

        try:
            text = git_file_text(path)
        except RuntimeError:
            continue

        for line_number, line in enumerate(text.splitlines(), start=1):
            if TARGET_RE.search(line):
                direct_reference_paths.add(path)
                direct_reference_rows.append({
                    "path": path,
                    "line": line_number,
                    "text": line.rstrip(),
                })

    repository_paths = (
        set(proof_directory_paths)
        | direct_reference_paths
        | MANDATORY_REPOSITORY_PATHS
    )
    repository_paths = {
        path for path in repository_paths
        if path in set(all_repo_paths)
    }

    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out_dir = (
        REPO_ROOT
        / "cleanroom_results"
        / f"pa09_mlk_poly_add_provenance_{timestamp}"
    )
    authored_dir = out_dir / "authored_artifacts"
    repository_dir = out_dir / "repository_artifacts"
    optional_dir = out_dir / "optional_reports"

    authored_dir.mkdir(parents=True, exist_ok=False)
    repository_dir.mkdir(parents=True)
    optional_dir.mkdir(parents=True)

    for filename in REQUIRED_AUTHORED:
        shutil.copy2(REPO_ROOT / filename, authored_dir / filename)

    optional_manifest: list[dict[str, Any]] = []
    optional_search_roots = [
        REPO_ROOT,
        REPO_ROOT.parent,
        Path.home() / "Downloads",
    ]

    for filename in OPTIONAL_REPORTS:
        found: Path | None = None
        for root in optional_search_roots:
            candidate = root / filename
            if candidate.is_file():
                found = candidate
                break

        if found is None:
            optional_manifest.append({
                "file": filename,
                "present": "no",
                "sha256": "",
                "size_bytes": 0,
                "source_path": "",
            })
            continue

        shutil.copy2(found, optional_dir / filename)
        optional_manifest.append({
            "file": filename,
            "present": "yes",
            "sha256": sha256_file(found),
            "size_bytes": found.stat().st_size,
            "source_path": str(found),
        })

    repository_manifest: list[dict[str, Any]] = []
    repository_texts: dict[str, str] = {}

    for path in sorted(repository_paths):
        data = git_file_bytes(path)
        destination = repository_dir / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)

        text = data.decode("utf-8", errors="replace")
        repository_texts[path] = text
        repository_manifest.append({
            "path": path,
            "sha256": sha256_bytes(data),
            "size_bytes": len(data),
            "line_count": len(text.splitlines()),
            "in_original_poly_add_proof_directory":
                "yes" if path in proof_directory_paths else "no",
            "contains_direct_target_reference":
                "yes" if path in direct_reference_paths else "no",
        })

    authored_c_paths = [
        REPO_ROOT / filename
        for filename in REQUIRED_AUTHORED
        if filename.endswith(".c")
    ]

    comparisons: list[dict[str, Any]] = []
    exact_binary_duplicates = 0
    normalized_duplicates = 0

    for authored_path in authored_c_paths:
        authored_bytes = authored_path.read_bytes()
        authored_text = authored_bytes.decode("utf-8", errors="replace")
        authored_hash = sha256_bytes(authored_bytes)
        authored_normalized = normalized_text(authored_text)
        authored_tokens = token_stream(authored_text)
        authored_token_set = set(authored_tokens)
        authored_lines = significant_lines(authored_text)

        for repository_path, repository_text in repository_texts.items():
            if Path(repository_path).suffix.lower() not in TEXT_SUFFIXES:
                continue

            repository_bytes = git_file_bytes(repository_path)
            repository_hash = sha256_bytes(repository_bytes)
            repository_normalized = normalized_text(repository_text)
            repository_tokens = token_stream(repository_text)
            repository_token_set = set(repository_tokens)
            repository_lines = significant_lines(repository_text)

            exact_binary = authored_hash == repository_hash
            exact_normalized = (
                bool(authored_normalized)
                and authored_normalized == repository_normalized
            )
            sequence_ratio = difflib.SequenceMatcher(
                None,
                " ".join(authored_tokens),
                " ".join(repository_tokens),
                autojunk=False,
            ).ratio()
            token_j = jaccard(authored_token_set, repository_token_set)
            line_j = jaccard(authored_lines, repository_lines)

            if exact_binary:
                exact_binary_duplicates += 1
            if exact_normalized:
                normalized_duplicates += 1

            comparisons.append({
                "authored_file": authored_path.name,
                "repository_file": repository_path,
                "authored_sha256": authored_hash,
                "repository_sha256": repository_hash,
                "exact_binary_duplicate": "yes" if exact_binary else "no",
                "exact_normalized_text_duplicate":
                    "yes" if exact_normalized else "no",
                "token_sequence_ratio": round(sequence_ratio, 6),
                "token_jaccard": round(token_j, 6),
                "significant_line_jaccard": round(line_j, 6),
                "mechanical_classification": mechanical_classification(
                    exact_binary,
                    exact_normalized,
                    sequence_ratio,
                    token_j,
                    line_j,
                ),
            })

    comparisons.sort(
        key=lambda row: (
            float(row["token_sequence_ratio"]),
            float(row["token_jaccard"]),
            float(row["significant_line_jaccard"]),
        ),
        reverse=True,
    )

    annotation_rows: list[dict[str, Any]] = []

    for path, text in repository_texts.items():
        annotation_rows.extend(
            collect_annotation_lines("repository", path, text)
        )

    for filename in REQUIRED_AUTHORED:
        authored_path = REPO_ROOT / filename
        if authored_path.suffix.lower() not in {".c", ".h", ".sh"}:
            continue
        annotation_rows.extend(
            collect_annotation_lines(
                "authored",
                filename,
                authored_path.read_text(encoding="utf-8", errors="replace"),
            )
        )

    run_summary_manifest: list[dict[str, Any]] = []
    cleanroom_results = REPO_ROOT / "cleanroom_results"
    if cleanroom_results.is_dir():
        for summary_path in sorted(cleanroom_results.rglob("summary.txt")):
            if out_dir in summary_path.parents:
                continue
            relative = summary_path.relative_to(REPO_ROOT).as_posix()
            lower = relative.lower()
            if not any(f"pa0{number}" in lower for number in range(1, 9)):
                continue
            data = summary_path.read_bytes()
            run_summary_manifest.append({
                "path": relative,
                "sha256": sha256_bytes(data),
                "size_bytes": len(data),
            })

    write_csv(out_dir / "authored_manifest.csv", authored_manifest)
    write_csv(out_dir / "optional_report_manifest.csv", optional_manifest)
    write_csv(out_dir / "repository_manifest.csv", repository_manifest)
    write_csv(out_dir / "direct_target_references.csv", direct_reference_rows)
    write_csv(out_dir / "mechanical_comparison_matrix.csv", comparisons)
    write_csv(out_dir / "annotation_catalog.csv", annotation_rows)
    write_csv(out_dir / "prior_run_summary_manifest.csv", run_summary_manifest)

    for filename, value in [
        ("authored_manifest.json", authored_manifest),
        ("optional_report_manifest.json", optional_manifest),
        ("repository_manifest.json", repository_manifest),
        ("direct_target_references.json", direct_reference_rows),
        ("mechanical_comparison_matrix.json", comparisons),
        ("annotation_catalog.json", annotation_rows),
        ("prior_run_summary_manifest.json", run_summary_manifest),
    ]:
        (out_dir / filename).write_text(
            json.dumps(value, indent=2),
            encoding="utf-8",
        )

    history = run([
        "git",
        "log",
        "--date=iso-strict",
        "--format=%H%x09%ad%x09%an%x09%s",
        "--",
        "proofs/cbmc/poly_add",
        "mlkem/src/poly.c",
        "mlkem/src/poly.h",
    ], check=False)
    (out_dir / "repository_target_history.txt").write_text(
        history + "\n",
        encoding="utf-8",
    )

    git_status = run(["git", "status", "--short"], check=False)
    (out_dir / "git_status.txt").write_text(
        git_status + "\n",
        encoding="utf-8",
    )

    high_similarity = [
        row for row in comparisons
        if row["mechanical_classification"]
        == "high-mechanical-similarity-review-required"
    ]

    bundle: list[str] = []
    bundle.append("# PA-09 `mlk_poly_add` Provenance Evidence Bundle")
    bundle.append("")
    bundle.append("## 1. Audit Identity")
    bundle.append("")
    bundle.append(f"- Repository root: `{REPO_ROOT}`")
    bundle.append(f"- Frozen commit: `{actual_commit}`")
    bundle.append(f"- Production `poly.c` SHA-256: `{current_poly_hash}`")
    bundle.append("- Production source modified: `No`")
    bundle.append(
        f"- Required authored artefacts hash-verified: "
        f"`{len(authored_manifest)}`"
    )
    bundle.append(
        f"- Files in original `proofs/cbmc/poly_add`: "
        f"`{len(proof_directory_paths)}`"
    )
    bundle.append(
        f"- Frozen repository artefacts collected: "
        f"`{len(repository_manifest)}`"
    )
    bundle.append(
        f"- Mechanical authored/repository comparisons: "
        f"`{len(comparisons)}`"
    )
    bundle.append(
        f"- Exact binary duplicates found: `{exact_binary_duplicates}`"
    )
    bundle.append(
        f"- Exact normalized-text duplicates found: "
        f"`{normalized_duplicates}`"
    )
    bundle.append(
        f"- High mechanical similarity pairs requiring semantic review: "
        f"`{len(high_similarity)}`"
    )
    bundle.append("")
    bundle.append("## 2. Interpretation Boundary")
    bundle.append("")
    bundle.append(
        "This bundle establishes artefact identity, frozen repository "
        "content, and mechanical overlap. It does not treat a similarity "
        "score as a final semantic provenance judgement. The final PA-09 "
        "conclusion must separately distinguish inevitable overlap, "
        "contract-derived overlap, architectural overlap, and evidence of "
        "copying or independent extension."
    )
    bundle.append("")
    bundle.append("## 3. Authored Artefact Freeze")
    bundle.append("")
    bundle.append("| File | Hash verified | SHA-256 | Size |")
    bundle.append("|---|---|---|---:|")
    for row in authored_manifest:
        bundle.append(
            f"| `{row['file']}` | {row['hash_verified']} | "
            f"`{row['actual_sha256']}` | {row['size_bytes']} |"
        )
    bundle.append("")
    bundle.append("## 4. Original Repository `poly_add` Proof Directory")
    bundle.append("")
    for path in proof_directory_paths:
        bundle.append(f"- `{path}`")
    bundle.append("")
    bundle.append("## 5. Repository Candidate Manifest")
    bundle.append("")
    bundle.append(
        "| Path | Original proof directory | Direct target reference | SHA-256 |"
    )
    bundle.append("|---|---|---|---|")
    for row in repository_manifest:
        bundle.append(
            f"| `{row['path']}` | "
            f"{row['in_original_poly_add_proof_directory']} | "
            f"{row['contains_direct_target_reference']} | "
            f"`{row['sha256']}` |"
        )
    bundle.append("")
    bundle.append("## 6. Direct Target References")
    bundle.append("")
    bundle.append("```text")
    for row in direct_reference_rows:
        bundle.append(f"{row['path']}:{row['line']}: {row['text']}")
    bundle.append("```")
    bundle.append("")
    bundle.append("## 7. Highest Mechanical Similarities")
    bundle.append("")
    bundle.append(
        "These values are discovery aids. They are not the final novelty "
        "classification."
    )
    bundle.append("")
    bundle.append(
        "| Authored file | Repository file | Sequence | Token Jaccard | "
        "Line Jaccard | Classification |"
    )
    bundle.append("|---|---|---:|---:|---:|---|")
    for row in comparisons[:100]:
        bundle.append(
            f"| `{row['authored_file']}` | "
            f"`{row['repository_file']}` | "
            f"{row['token_sequence_ratio']:.3f} | "
            f"{row['token_jaccard']:.3f} | "
            f"{row['significant_line_jaccard']:.3f} | "
            f"{row['mechanical_classification']} |"
        )
    bundle.append("")
    bundle.append("## 8. Annotation and Property Catalogue")
    bundle.append("")
    bundle.append("```text")
    for row in annotation_rows:
        bundle.append(
            f"{row['origin']}:{row['path']}:{row['line']}: {row['text']}"
        )
    bundle.append("```")
    bundle.append("")
    bundle.append("## 9. Required Semantic Audit Questions")
    bundle.append("")
    bundle.append(
        "1. What does the original repository harness contain, and what "
        "does it delegate to source contracts?"
    )
    bundle.append(
        "2. Which assumptions and postconditions are shared because both "
        "artefacts target the same function contract?"
    )
    bundle.append(
        "3. Which PA properties are direct restatements or refinements of "
        "the repository contract?"
    )
    bundle.append(
        "4. Which PA properties are absent from the original harness and "
        "source contract?"
    )
    bundle.append(
        "5. Are the negative controls, alias diagnostics, caller proofs, "
        "cross-parameter runs, mutation campaign, and anti-vacuity sentinels "
        "structurally original additions?"
    )
    bundle.append(
        "6. Is any assertion wording, helper implementation, control-flow "
        "layout, or harness scaffolding copied verbatim?"
    )
    bundle.append(
        "7. Which overlap is inevitable or source-contract-derived rather "
        "than evidence of copying?"
    )
    bundle.append(
        "8. What claim is supportable: exact uniqueness, independent "
        "authorship, original-harness blindness, or source-contract-informed "
        "extension?"
    )
    bundle.append("")
    bundle.append("## 10. Frozen Repository Artefact Contents")
    bundle.append("")
    for path in sorted(repository_texts):
        bundle.append(f"### `{path}`")
        bundle.append("")
        bundle.append(fenced(path, repository_texts[path]))
        bundle.append("")
    bundle.append("## 11. Authored PA-01 Through PA-08 Artefact Contents")
    bundle.append("")
    for filename in REQUIRED_AUTHORED:
        path = REPO_ROOT / filename
        text = path.read_text(encoding="utf-8", errors="replace")
        bundle.append(f"### `{filename}`")
        bundle.append("")
        bundle.append(fenced(filename, text))
        bundle.append("")
    bundle.append("## 12. Deterministic Stage-1 Status")
    bundle.append("")
    bundle.append("```text")
    bundle.append("PA09_EVIDENCE_BUNDLE_READY_FOR_SEMANTIC_AUDIT")
    bundle.append("```")
    bundle.append("")

    bundle_path = out_dir / "PA09_PROVENANCE_EVIDENCE_BUNDLE.md"
    bundle_path.write_text("\n".join(bundle), encoding="utf-8")

    summary: dict[str, Any] = {
        "campaign": "PA-09",
        "scope": "strict_novelty_and_provenance_evidence_collection",
        "production_source_modified": "no",
        "authored_artifacts_required": len(REQUIRED_AUTHORED),
        "authored_artifacts_hash_verified": len(authored_manifest),
        "original_poly_add_proof_files": len(proof_directory_paths),
        "repository_artifacts_collected": len(repository_manifest),
        "mechanical_comparisons": len(comparisons),
        "exact_binary_duplicates": exact_binary_duplicates,
        "exact_normalized_text_duplicates": normalized_duplicates,
        "high_similarity_pairs_for_semantic_review": len(high_similarity),
        "annotation_catalog_generated": "yes",
        "semantic_audit_required": "yes",
        "bundle_file": bundle_path.name,
        "final_status": "PA09_EVIDENCE_BUNDLE_READY_FOR_SEMANTIC_AUDIT",
    }

    with (out_dir / "summary.txt").open("w", encoding="utf-8") as handle:
        for key, value in summary.items():
            handle.write(f"{key}={value}\n")

    (out_dir / "summary.json").write_text(
        json.dumps(summary, indent=2),
        encoding="utf-8",
    )

    print("PA-09 deterministic provenance evidence collection completed.")
    print("")
    for key, value in summary.items():
        print(f"{key}={value}")
    print(f"results_directory={out_dir}")
    print("")
    print("Upload PA09_PROVENANCE_EVIDENCE_BUNDLE.md for semantic audit.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
