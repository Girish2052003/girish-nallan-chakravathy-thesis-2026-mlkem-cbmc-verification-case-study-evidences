from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

import jsonschema

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "generate_harness_scaffold.py"
FIXTURES = Path(__file__).resolve().parent / "fixtures"
REPO = FIXTURES / "repo"
VALID = FIXTURES / "request_valid.json"
NO_COMPILE = FIXTURES / "request_no_compile.json"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


class HarnessScaffoldTests(unittest.TestCase):
    maxDiff = None

    def run_cli(self, request: Path, repo: Path, output_dir: Path) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(SCRIPT), "--request", str(request), "--repo-root", str(repo), "--output-dir", str(output_dir)],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

    def write_modified(self, base: Path, dest: Path, mutate) -> None:
        raw = read_json(base)
        mutate(raw)
        dest.write_text(json.dumps(raw, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    def test_01_valid_request_generates_neutral_compilable_scaffold(self) -> None:
        before = {p.relative_to(REPO).as_posix(): sha256(p) for p in REPO.rglob("*") if p.is_file()}
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(VALID, REPO, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            expected = {
                "canonical_request.json", "source_manifest.json", "mlk_poly_sub_harness.c",
                "compile_check.argv.json", "compile_check.command.txt", "compile_check.stdout.txt",
                "compile_check.stderr.txt", "compile_check.result.json", "scaffold_report.json",
                "scaffold_report.md", "scaffold_artifact_manifest.json",
            }
            self.assertEqual({p.name for p in out.iterdir()}, expected)
            report = read_json(out / "scaffold_report.json")
            self.assertEqual(report["status"], "COMPLETE")
            self.assertEqual(report["semantic_authority"], "NONE")
            self.assertEqual(report["generated_content_class"], "NEUTRAL_WIRING_ONLY")
            self.assertEqual(report["compile_check"]["status"], "PASSED")
            checks = report["scaffold"]["static_checks"]
            self.assertEqual(checks["target_call_count"], 1)
            self.assertEqual(checks["assumption_statement_count"], 0)
            self.assertEqual(checks["assertion_statement_count"], 0)
            self.assertEqual(checks["initializer_count"], 0)
            self.assertTrue(checks["passes_neutrality_checks"])
            text = (out / "mlk_poly_sub_harness.c").read_text(encoding="utf-8")
            self.assertEqual(text.count("mlk_poly_sub("), 1)
            self.assertIn("V5_CODEX_ASSUMPTIONS_BEGIN", text)
            self.assertIn("V5_CODEX_ASSERTIONS_BEGIN", text)
            self.assertNotIn("__CPROVER_assume", text)
            self.assertNotIn("__CPROVER_assert", text)
        after = {p.relative_to(REPO).as_posix(): sha256(p) for p in REPO.rglob("*") if p.is_file()}
        self.assertEqual(before, after)

    def test_02_no_compile_mode_is_complete_and_writes_no_compile_files(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(NO_COMPILE, REPO, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            report = read_json(out / "scaffold_report.json")
            self.assertEqual(report["status"], "COMPLETE")
            self.assertEqual(report["compile_check"]["status"], "NOT_REQUESTED")
            self.assertFalse((out / "compile_check.argv.json").exists())

    def test_03_required_compile_failure_is_incomplete(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["harness"]["includes"].append({"style": "quoted", "value": "missing_header.h"}))
            out = Path(temp) / "out"
            result = self.run_cli(request, REPO, out)
            self.assertEqual(result.returncode, 2, result.stderr)
            report = read_json(out / "scaffold_report.json")
            self.assertEqual(report["status"], "INCOMPLETE")
            self.assertEqual(report["compile_check"]["status"], "FAILED")
            self.assertTrue(report["incomplete_reasons"])
            self.assertTrue((out / "compile_check.stderr.txt").read_bytes())

    def test_04_optional_compile_failure_is_warning(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            def mutate(r):
                r["harness"]["includes"].append({"style": "quoted", "value": "missing_header.h"})
                r["compile_check"]["required"] = False
            self.write_modified(VALID, request, mutate)
            out = Path(temp) / "out"
            result = self.run_cli(request, REPO, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            report = read_json(out / "scaffold_report.json")
            self.assertEqual(report["status"], "COMPLETE_WITH_WARNINGS")
            self.assertEqual(report["compile_check"]["status"], "FAILED")

    def test_05_repeated_run_at_same_paths_is_byte_reproducible(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            first = self.run_cli(VALID, REPO, out)
            self.assertEqual(first.returncode, 0, first.stderr)
            snapshot = {p.relative_to(out).as_posix(): p.read_bytes() for p in out.rglob("*") if p.is_file()}
            shutil.rmtree(out)
            second = self.run_cli(VALID, REPO, out)
            self.assertEqual(second.returncode, 0, second.stderr)
            snapshot2 = {p.relative_to(out).as_posix(): p.read_bytes() for p in out.rglob("*") if p.is_file()}
            self.assertEqual(snapshot, snapshot2)

    def test_06_hash_mismatch_is_incomplete_and_no_scaffold_is_generated(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            def mutate(r):
                r["source_bindings"][0]["expected_sha256"] = "0" * 64
            self.write_modified(VALID, request, mutate)
            out = Path(temp) / "out"
            result = self.run_cli(request, REPO, out)
            self.assertEqual(result.returncode, 2, result.stderr)
            report = read_json(out / "scaffold_report.json")
            self.assertFalse(report["scaffold"]["generated"])
            self.assertFalse((out / "mlk_poly_sub_harness.c").exists())

    def test_07_source_path_traversal_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["source_bindings"].__setitem__(0, {"path": "../poly.h", "expected_sha256": "0" * 64}))
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("unsafe path", result.stderr.lower())

    def test_08_source_symlink_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            repo = Path(temp) / "repo"
            shutil.copytree(REPO, repo)
            (repo / "linked.c").symlink_to(repo / "src" / "poly.c")
            request = Path(temp) / "request.json"
            raw = read_json(VALID)
            raw["target"]["source_file"] = "linked.c"
            raw["source_bindings"] = [{"path": "linked.c", "expected_sha256": sha256(repo / "src" / "poly.c")}]
            request.write_text(json.dumps(raw), encoding="utf-8")
            result = self.run_cli(request, repo, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("symlink", result.stderr.lower())

    def test_09_output_inside_repository_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            repo = Path(temp) / "repo"
            shutil.copytree(REPO, repo)
            result = self.run_cli(VALID, repo, repo / "evidence")
            self.assertEqual(result.returncode, 3)
            self.assertIn("outside", result.stderr.lower())

    def test_10_existing_output_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            out.mkdir()
            result = self.run_cli(VALID, REPO, out)
            self.assertEqual(result.returncode, 3)
            self.assertIn("already exists", result.stderr.lower())

    def test_11_invalid_target_symbol_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["target"].__setitem__("symbol", "mlk_poly_sub; system"))
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)

    def test_12_initializer_or_statement_in_type_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["harness"]["declarations"][0].__setitem__("type", "mlk_poly = {0}"))
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)

    def test_13_target_argument_code_injection_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["target"]["arguments"].__setitem__(0, "&r); __CPROVER_assume(0"))
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)

    def test_14_duplicate_declaration_names_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["harness"]["declarations"][1].__setitem__("name", "r"))
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("duplicate", result.stderr.lower())

    def test_15_undeclared_argument_object_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["target"]["arguments"].__setitem__(0, "&unknown"))
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("undeclared", result.stderr.lower())

    def test_16_undeclared_return_capture_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["target"].__setitem__("return_capture", {"mode": "assign", "variable": "result"}))
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)

    def test_17_unsafe_include_path_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["harness"]["includes"].__setitem__(0, {"style": "quoted", "value": "../poly.h"}))
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)

    def test_18_nonallowlisted_compiler_argument_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            self.write_modified(VALID, request, lambda r: r["compile_check"]["extra_args"].append("-fplugin=/tmp/x.so"))
            result = self.run_cli(request, REPO, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("allowlisted", result.stderr.lower())

    def test_19_output_json_validates_against_all_schemas(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(VALID, REPO, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            pairs = [
                ("canonical_request.json", "INPUT_SCHEMA.json"),
                ("scaffold_report.json", "OUTPUT_SCHEMA.json"),
                ("source_manifest.json", "SOURCE_MANIFEST_SCHEMA.json"),
                ("scaffold_artifact_manifest.json", "ARTIFACT_MANIFEST_SCHEMA.json"),
                ("compile_check.result.json", "COMPILE_CHECK_SCHEMA.json"),
            ]
            for data_name, schema_name in pairs:
                jsonschema.Draft202012Validator(read_json(ROOT / "references" / schema_name)).validate(read_json(out / data_name))

    def test_20_artifact_manifest_hashes_every_listed_artifact(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(VALID, REPO, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            manifest = read_json(out / "scaffold_artifact_manifest.json")
            for item in manifest["artifacts"]:
                p = out / item["path"]
                self.assertTrue(p.is_file())
                self.assertEqual(item["sha256"], sha256(p))
                self.assertEqual(item["size_bytes"], p.stat().st_size)

    def test_21_static_implementation_has_no_network_model_or_shell_execution(self) -> None:
        text = SCRIPT.read_text(encoding="utf-8")
        forbidden = ["import requests", "import urllib", "import socket", "import openai", "os.system(", "shell=True"]
        for token in forbidden:
            self.assertNotIn(token, text)
        self.assertIn("shell=False", text)


if __name__ == "__main__":
    unittest.main(verbosity=2)
