from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "analyze_target_context.py"
FIXTURES = Path(__file__).resolve().parent / "fixtures"
REPO = FIXTURES / "repo"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class TargetBuildContextCliTests(unittest.TestCase):
    maxDiff = None

    def run_cli(self, request: Path, repo: Path, output_dir: Path) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                "python3",
                str(SCRIPT),
                "--request",
                str(request),
                "--repo-root",
                str(repo),
                "--output-dir",
                str(output_dir),
            ],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

    def test_valid_request_writes_expected_outputs_and_boundaries(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(FIXTURES / "request_valid.json", REPO, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(
                {p.name for p in out.iterdir()},
                {
                    "canonical_request.json",
                    "source_manifest.json",
                    "compile_context.json",
                    "target_context.json",
                    "target_context.md",
                    "preprocessed_target_excerpt.c",
                    "preprocess_stdout.sha256",
                },
            )
            report = json.loads((out / "target_context.json").read_text())
            self.assertEqual(report["status"], "COMPLETE")
            self.assertEqual(report["semantic_authority"], "NONE")
            self.assertEqual(report["analysis_nature"], "LEXICAL_AND_BUILD_STRUCTURAL_ONLY")
            self.assertEqual(len(report["definitions"]), 1)
            self.assertEqual(report["definitions"][0]["path"], "src/poly.c")
            self.assertEqual(report["direct_callers"][0]["caller"], "use_sub")
            self.assertEqual(report["direct_callees"][0]["symbol"], "helper_touch")
            self.assertEqual(report["loops"][0]["bound_classification"], "NOT_INFERRED")
            self.assertTrue(all(x["bounds_classification"] == "NOT_INFERRED" for x in report["array_expressions"]))
            self.assertTrue(all(x["validity_classification"] == "NOT_INFERRED" for x in report["pointer_expressions"]))
            self.assertNotIn("correct", (out / "target_context.md").read_text().lower().split("status:")[0])

    def test_missing_target_returns_incomplete_report(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(FIXTURES / "request_missing.json", REPO, out)
            self.assertEqual(result.returncode, 2, result.stderr)
            report = json.loads((out / "target_context.json").read_text())
            self.assertEqual(report["status"], "INCOMPLETE")
            self.assertIn("found 0", " ".join(report["incomplete_reasons"]))

    def test_no_build_context_is_warning_not_failure(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(FIXTURES / "request_no_build.json", REPO, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads((out / "target_context.json").read_text())
            self.assertEqual(report["status"], "COMPLETE_WITH_WARNINGS")
            self.assertEqual(report["build_summary"]["preprocessing"]["status"], "NOT_REQUESTED")

    def test_byte_reproducibility(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out1 = Path(temp) / "out1"
            out2 = Path(temp) / "out2"
            first = self.run_cli(FIXTURES / "request_valid.json", REPO, out1)
            second = self.run_cli(FIXTURES / "request_valid.json", REPO, out2)
            self.assertEqual(first.returncode, 0, first.stderr)
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertEqual({p.name for p in out1.iterdir()}, {p.name for p in out2.iterdir()})
            for path in sorted(out1.iterdir()):
                self.assertEqual(sha256(path), sha256(out2 / path.name), path.name)

    def test_output_inside_repository_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            repo = Path(temp) / "repo"
            shutil.copytree(REPO, repo)
            result = self.run_cli(FIXTURES / "request_no_build.json", repo, repo / "generated")
            self.assertEqual(result.returncode, 3)
            self.assertIn("must not be inside", result.stderr)

    def test_malformed_json_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "bad.json"
            request.write_text("{broken", encoding="utf-8")
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("not valid JSON", result.stderr)

    def test_source_path_escape_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "bad.json"
            request.write_text(json.dumps({
                "schema_version": "1.0",
                "request_id": "escape",
                "target": {"symbol": "mlk_poly_sub", "source_file": "../outside.c"},
                "build": {"mode": "none"},
            }), encoding="utf-8")
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("must not escape", result.stderr)

    def test_symlink_source_is_rejected(self) -> None:
        if not hasattr(os, "symlink"):
            self.skipTest("symlinks unavailable")
        with tempfile.TemporaryDirectory() as temp:
            repo = Path(temp) / "repo"
            shutil.copytree(REPO, repo)
            outside = Path(temp) / "outside.c"
            outside.write_text("void linked_target(void) {}\n", encoding="utf-8")
            (repo / "src" / "linked.c").symlink_to(outside)
            request = Path(temp) / "request.json"
            request.write_text(json.dumps({
                "schema_version": "1.0",
                "request_id": "symlink",
                "target": {"symbol": "linked_target", "source_file": "src/linked.c"},
                "scope": {"source_files": ["src/linked.c"]},
                "build": {"mode": "none"},
            }), encoding="utf-8")
            result = self.run_cli(request, repo, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("symlink", result.stderr.lower())

    def test_expected_hash_mismatch_is_incomplete(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            raw = json.loads((FIXTURES / "request_no_build.json").read_text())
            raw["target"]["expected_sha256"] = "0" * 64
            request.write_text(json.dumps(raw), encoding="utf-8")
            out = Path(temp) / "out"
            result = self.run_cli(request, REPO, out)
            self.assertEqual(result.returncode, 2, result.stderr)
            report = json.loads((out / "target_context.json").read_text())
            self.assertIn("SHA-256 mismatch", " ".join(report["incomplete_reasons"]))

    def test_duplicate_definitions_are_incomplete(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            request.write_text(json.dumps({
                "schema_version": "1.0",
                "request_id": "duplicate",
                "target": {"symbol": "duplicated_target"},
                "scope": {"source_files": ["a.c", "b.c"]},
                "build": {"mode": "none"},
            }), encoding="utf-8")
            out = Path(temp) / "out"
            result = self.run_cli(request, FIXTURES / "duplicate", out)
            self.assertEqual(result.returncode, 2, result.stderr)
            report = json.loads((out / "target_context.json").read_text())
            self.assertIn("found 2", " ".join(report["incomplete_reasons"]))

    def test_compile_commands_arguments_mode_succeeds(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            repo = Path(temp) / "repo"
            shutil.copytree(REPO, repo)
            shutil.copy2(FIXTURES / "compile-db" / "compile_commands.json", repo / "compile_commands.json")
            request = Path(temp) / "request.json"
            request.write_text(json.dumps({
                "schema_version": "1.0",
                "request_id": "compdb",
                "target": {"symbol": "mlk_poly_sub", "source_file": "src/poly.c"},
                "scope": {"source_files": ["include/poly.h", "src/poly.c", "src/use_poly.c"]},
                "build": {"mode": "compile_commands", "compile_commands_file": "compile_commands.json"},
                "options": {"preprocess": True, "preprocess_required": True},
            }), encoding="utf-8")
            out = Path(temp) / "out"
            result = self.run_cli(request, repo, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            compile_context = json.loads((out / "compile_context.json").read_text())
            self.assertEqual(compile_context["mode"], "compile_commands")
            self.assertEqual(compile_context["preprocessing"]["status"], "SUCCEEDED")

    def test_compile_commands_shell_syntax_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            repo = Path(temp) / "repo"
            shutil.copytree(REPO, repo)
            (repo / "compile_commands.json").write_text(json.dumps([{
                "directory": ".",
                "file": "src/poly.c",
                "command": "gcc -Iinclude -c src/poly.c; touch escaped"
            }]), encoding="utf-8")
            request = Path(temp) / "request.json"
            request.write_text(json.dumps({
                "schema_version": "1.0",
                "request_id": "unsafe-compdb",
                "target": {"symbol": "mlk_poly_sub", "source_file": "src/poly.c"},
                "scope": {"source_files": ["include/poly.h", "src/poly.c", "src/use_poly.c"]},
                "build": {"mode": "compile_commands", "compile_commands_file": "compile_commands.json"},
                "options": {"preprocess": True},
            }), encoding="utf-8")
            result = self.run_cli(request, repo, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("shell syntax", result.stderr)
            self.assertFalse((repo / "escaped").exists())

    def test_existing_output_directory_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            out.mkdir()
            result = self.run_cli(FIXTURES / "request_no_build.json", REPO, out)
            self.assertEqual(result.returncode, 3)
            self.assertIn("already exists", result.stderr)

    def test_unsupported_explicit_scope_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            repo = Path(temp) / "repo"
            shutil.copytree(REPO, repo)
            (repo / "notes.txt").write_text("not source", encoding="utf-8")
            request = Path(temp) / "request.json"
            request.write_text(json.dumps({
                "schema_version": "1.0",
                "request_id": "unsupported",
                "target": {"symbol": "mlk_poly_sub"},
                "scope": {"source_files": ["notes.txt"]},
                "build": {"mode": "none"},
            }), encoding="utf-8")
            result = self.run_cli(request, repo, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("unsupported source extension", result.stderr)


if __name__ == "__main__":
    unittest.main()
