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
SCRIPT = ROOT / "scripts" / "ground_spec.py"
FIXTURES = Path(__file__).resolve().parent / "fixtures"
SPEC = FIXTURES / "spec"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class GroundSpecCliTests(unittest.TestCase):
    maxDiff = None

    def run_cli(self, request: Path, spec_root: Path, output_dir: Path) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                "python3",
                str(SCRIPT),
                "--request",
                str(request),
                "--spec-root",
                str(spec_root),
                "--output-dir",
                str(output_dir),
            ],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

    def test_valid_request_writes_expected_outputs(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(FIXTURES / "request_valid.json", SPEC, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            expected = {
                "canonical_request.json",
                "source_manifest.json",
                "grounding_report.json",
                "grounding_report.md",
            }
            self.assertEqual({p.name for p in out.iterdir()}, expected)
            report = json.loads((out / "grounding_report.json").read_text())
            self.assertEqual(report["status"], "COMPLETE_WITH_WARNINGS")
            self.assertEqual(report["semantic_authority"], "NONE")
            self.assertTrue(all(item["matched"] for item in report["query_results"]))
            self.assertIn("ignore.bin", (out / "source_manifest.json").read_text())

    def test_required_miss_returns_exit_2_and_report(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(FIXTURES / "request_required_miss.json", SPEC, out)
            self.assertEqual(result.returncode, 2, result.stderr)
            report = json.loads((out / "grounding_report.json").read_text())
            self.assertEqual(report["status"], "INCOMPLETE")
            self.assertFalse(report["query_results"][0]["matched"])

    def test_optional_miss_is_warning_not_failure(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out = Path(temp) / "out"
            result = self.run_cli(FIXTURES / "request_optional_miss.json", SPEC, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads((out / "grounding_report.json").read_text())
            self.assertEqual(report["status"], "COMPLETE_WITH_WARNINGS")

    def test_byte_reproducibility(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            out1 = Path(temp) / "out1"
            out2 = Path(temp) / "out2"
            result1 = self.run_cli(FIXTURES / "request_valid.json", SPEC, out1)
            result2 = self.run_cli(FIXTURES / "request_valid.json", SPEC, out2)
            self.assertEqual(result1.returncode, 0, result1.stderr)
            self.assertEqual(result2.returncode, 0, result2.stderr)
            for name in [
                "canonical_request.json",
                "source_manifest.json",
                "grounding_report.json",
                "grounding_report.md",
            ]:
                self.assertEqual(sha256(out1 / name), sha256(out2 / name), name)

    def test_output_inside_spec_root_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            copied_spec = Path(temp) / "spec"
            shutil.copytree(SPEC, copied_spec)
            out = copied_spec / "generated"
            result = self.run_cli(FIXTURES / "request_valid.json", copied_spec, out)
            self.assertEqual(result.returncode, 3)
            self.assertIn("must not be inside", result.stderr)

    def test_malformed_json_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "bad.json"
            request.write_text("{broken", encoding="utf-8")
            result = self.run_cli(request, SPEC, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("not valid JSON", result.stderr)

    def test_empty_queries_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "bad.json"
            request.write_text(
                json.dumps(
                    {
                        "schema_version": "1.0",
                        "request_id": "empty-queries",
                        "target": {"symbol": "mlk_poly_sub"},
                        "queries": [],
                    }
                ),
                encoding="utf-8",
            )
            result = self.run_cli(request, SPEC, Path(temp) / "out")
            self.assertEqual(result.returncode, 3)
            self.assertIn("non-empty array", result.stderr)

    def test_unsupported_only_corpus_returns_extraction_error(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            spec = Path(temp) / "spec"
            spec.mkdir()
            (spec / "blob.bin").write_bytes(b"not a supported document")
            result = self.run_cli(FIXTURES / "request_valid.json", spec, Path(temp) / "out")
            self.assertEqual(result.returncode, 4)
            self.assertIn("No supported specification document", result.stderr)

    def test_symlink_is_not_followed(self) -> None:
        if not hasattr(os, "symlink"):
            self.skipTest("symlinks unavailable")
        with tempfile.TemporaryDirectory() as temp:
            spec = Path(temp) / "spec"
            spec.mkdir()
            shutil.copy2(SPEC / "sample_spec.md", spec / "sample_spec.md")
            outside = Path(temp) / "outside.txt"
            outside.write_text("secret lexical phrase 3329", encoding="utf-8")
            (spec / "external.txt").symlink_to(outside)
            out = Path(temp) / "out"
            result = self.run_cli(FIXTURES / "request_valid.json", spec, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            manifest = json.loads((out / "source_manifest.json").read_text())
            self.assertIn(
                {"path": "external.txt", "reason": "symlink_not_followed"},
                manifest["skipped_paths"],
            )
            self.assertNotIn("secret lexical phrase", (out / "grounding_report.md").read_text())

    def test_any_term_and_case_sensitive_modes(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            request = Path(temp) / "request.json"
            request.write_text(
                json.dumps(
                    {
                        "schema_version": "1.0",
                        "request_id": "modes",
                        "target": {"symbol": "mlk_poly_sub"},
                        "queries": [
                            {"id": "any", "text": "absent 3329", "mode": "any_term", "required": True},
                            {"id": "case", "text": "POLYNOMIAL SUBTRACTION", "mode": "literal", "required": False},
                        ],
                        "options": {"case_sensitive": True, "context_lines": 0, "max_matches_per_query": 10},
                    }
                ),
                encoding="utf-8",
            )
            out = Path(temp) / "out"
            result = self.run_cli(request, SPEC, out)
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads((out / "grounding_report.json").read_text())
            by_id = {item["id"]: item for item in report["query_results"]}
            self.assertTrue(by_id["any"]["matched"])
            self.assertFalse(by_id["case"]["matched"])


if __name__ == "__main__":
    unittest.main()
