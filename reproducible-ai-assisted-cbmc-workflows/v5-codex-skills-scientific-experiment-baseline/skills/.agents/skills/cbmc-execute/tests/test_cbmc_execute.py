#!/usr/bin/env python3
from __future__ import annotations

import copy
import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import tempfile
import unittest

try:
    import jsonschema
except Exception:  # pragma: no cover
    jsonschema = None

ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "execute_cbmc.py"
FIXTURE_WORKSPACE = ROOT / "tests" / "fixtures" / "workspace"
MOCK_CBMC = ROOT / "tests" / "fixtures" / "bin" / "cbmc"
EPOCH = "1785715200"


def digest(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class ExecuteCBMCTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = pathlib.Path(tempfile.mkdtemp(prefix="cbmc-execute-test-"))
        self.workspace = self.tmp / "workspace"
        shutil.copytree(FIXTURE_WORKSPACE, self.workspace)
        self.request_path = self.tmp / "request.json"
        self.output = self.tmp / "out"

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def base_request(self, mode: str = "pass") -> dict:
        return {
            "schema_version": "1.0",
            "request_id": "test-run-001",
            "working_directory": ".",
            "analysis_sources": ["src/demo.c", "src/harness.c"],
            "tracked_inputs": ["include/demo.h", "src/demo.c", "src/harness.c"],
            "analysis": {"options": ["-I", "include", "--trace"], "timeout_seconds": 5},
            "inventory": {"enabled": True, "options": ["-I", "include"], "timeout_seconds": 5},
            "execution_environment": {"MOCK_CBMC_MODE": mode},
            "clock": {"mode": "source_date_epoch"}
        }

    def run_skill(self, request: dict, output: pathlib.Path | None = None, cbmc: pathlib.Path = MOCK_CBMC):
        self.request_path.write_text(json.dumps(request), encoding="utf-8")
        env = os.environ.copy()
        env["SOURCE_DATE_EPOCH"] = EPOCH
        return subprocess.run(
            ["python3", str(SCRIPT), "--request", str(self.request_path),
             "--workspace-root", str(self.workspace), "--output-dir", str(output or self.output),
             "--cbmc-path", str(cbmc)],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env, timeout=20
        )

    def load_summary(self, output: pathlib.Path | None = None) -> dict:
        return json.loads(((output or self.output) / "execution_summary.json").read_text())

    def test_01_pass_result_and_inventory(self):
        r = self.run_skill(self.base_request())
        self.assertEqual(r.returncode, 0, r.stderr)
        s = self.load_summary()
        self.assertEqual(s["tool_outcome"], "PASS_REPORTED_BY_CBMC")
        self.assertEqual(s["analysis"]["parsed_summary"]["property_counts"]["success"], 1)
        inv = json.loads((self.output / "property_inventory.json").read_text())
        self.assertTrue(inv["available"])
        self.assertEqual(inv["properties"][0]["property_id"], "main.assertion.1")

    def test_02_failure_result_is_evidence_not_wrapper_crash(self):
        r = self.run_skill(self.base_request("fail"))
        self.assertEqual(r.returncode, 0, r.stderr)
        s = self.load_summary()
        self.assertEqual(s["tool_outcome"], "FAIL_REPORTED_BY_CBMC")
        self.assertEqual(s["analysis"]["exit_code"], 10)
        self.assertEqual(s["analysis"]["parsed_summary"]["trace_property_ids"], ["main.assertion.1"])

    def test_03_tool_error_is_incomplete_and_raw_evidence_preserved(self):
        r = self.run_skill(self.base_request("tool_error"))
        self.assertEqual(r.returncode, 2)
        s = self.load_summary()
        self.assertEqual(s["tool_outcome"], "TOOL_ERROR")
        self.assertEqual(s["report_status"], "INCOMPLETE")
        self.assertIn("synthetic stderr", (self.output / "analysis.stderr.txt").read_text())

    def test_04_timeout_kills_process_group(self):
        req = self.base_request("sleep")
        req["analysis"]["timeout_seconds"] = 1
        r = self.run_skill(req)
        self.assertEqual(r.returncode, 2)
        self.assertEqual(self.load_summary()["tool_outcome"], "TIMEOUT")

    def test_05_malformed_json_is_preserved(self):
        r = self.run_skill(self.base_request("malformed"))
        self.assertEqual(r.returncode, 2)
        s = self.load_summary()
        self.assertEqual(s["tool_outcome"], "UNPARSEABLE_JSON")
        self.assertIn("{not-json", (self.output / "analysis.stdout.json").read_text())

    def test_06_inventory_failure_does_not_replace_analysis_result(self):
        r = self.run_skill(self.base_request("inventory_malformed"))
        self.assertEqual(r.returncode, 0)
        s = self.load_summary()
        self.assertEqual(s["tool_outcome"], "PASS_REPORTED_BY_CBMC")
        self.assertEqual(s["report_status"], "COMPLETE_WITH_WARNINGS")

    def test_07_expected_hash_mismatch_stops_before_execution(self):
        req = self.base_request()
        req["expected_sha256"] = {"src/harness.c": "0" * 64}
        r = self.run_skill(req)
        self.assertEqual(r.returncode, 4)
        self.assertFalse(self.output.exists())
        self.assertIn("IDENTITY_ERROR", r.stderr)

    def test_08_path_traversal_rejected(self):
        req = self.base_request()
        req["tracked_inputs"][0] = "../outside.h"
        r = self.run_skill(req)
        self.assertEqual(r.returncode, 3)
        self.assertFalse(self.output.exists())

    def test_09_symlink_input_rejected(self):
        target = self.workspace / "include" / "demo.h"
        original = target.read_bytes()
        target.unlink()
        outside = self.tmp / "outside.h"
        outside.write_bytes(original)
        target.symlink_to(outside)
        r = self.run_skill(self.base_request())
        self.assertEqual(r.returncode, 3)
        self.assertFalse(self.output.exists())

    def test_10_output_inside_workspace_rejected(self):
        r = self.run_skill(self.base_request(), self.workspace / "evidence")
        self.assertEqual(r.returncode, 3)
        self.assertFalse((self.workspace / "evidence").exists())

    def test_11_existing_output_refused(self):
        self.output.mkdir()
        sentinel = self.output / "sentinel"
        sentinel.write_text("keep")
        r = self.run_skill(self.base_request())
        self.assertEqual(r.returncode, 3)
        self.assertEqual(sentinel.read_text(), "keep")

    def test_12_shell_and_hidden_argument_syntax_rejected(self):
        for bad in ["--foo;rm", "@hidden.args", "$(touch x)"]:
            with self.subTest(bad=bad):
                out = self.tmp / ("out-" + hashlib.sha256(bad.encode()).hexdigest()[:8])
                req = self.base_request()
                req["analysis"]["options"] = [bad]
                r = self.run_skill(req, out)
                self.assertEqual(r.returncode, 3)
                self.assertFalse(out.exists())

    def test_13_conflicting_ui_and_uncontrolled_output_options_rejected(self):
        for bad_options in [["--json-ui"], ["--xml-ui"], ["--outfile", "x.goto"]]:
            with self.subTest(options=bad_options):
                out = self.tmp / ("out-" + str(len(list(self.tmp.glob('out-*')))))
                req = self.base_request()
                req["analysis"]["options"] = bad_options
                r = self.run_skill(req, out)
                self.assertEqual(r.returncode, 3)
                self.assertFalse(out.exists())

    def test_14_controlled_coverage_artifact_capture(self):
        req = self.base_request()
        req["analysis"]["options"] += ["--symex-coverage-report", "{artifact_dir}/coverage.xml"]
        r = self.run_skill(req)
        self.assertEqual(r.returncode, 0, r.stderr)
        artifact = self.output / "artifacts" / "coverage.xml"
        self.assertTrue(artifact.is_file())
        m = json.loads((self.output / "execution_artifact_manifest.json").read_text())
        self.assertTrue(m["declared_artifacts"][0]["exists"])

    def test_15_source_mutation_detected(self):
        req = self.base_request("mutate")
        req["execution_environment"]["MOCK_MUTATE_PATH"] = str(self.workspace / "src" / "demo.c")
        r = self.run_skill(req)
        self.assertEqual(r.returncode, 5)
        s = self.load_summary()
        self.assertEqual(s["tool_outcome"], "SOURCE_MUTATION_DETECTED")
        self.assertFalse(s["source_integrity"]["unchanged"])

    def test_16_reproducible_evidence_with_fixed_clock(self):
        req = self.base_request()
        out1, out2 = self.tmp / "repeat-a", self.tmp / "repeat-b"
        r1 = self.run_skill(req, out1)
        r2 = self.run_skill(req, out2)
        self.assertEqual((r1.returncode, r2.returncode), (0, 0))
        compare = [
            "execution_summary.json", "property_inventory.json", "source_manifest.before.json",
            "source_manifest.after.json", "source_integrity_comparison.json", "analysis.stdout.json",
            "analysis.stderr.txt", "inventory.stdout.json", "inventory.stderr.txt", "invocation_manifest.json"
        ]
        for name in compare:
            self.assertEqual((out1 / name).read_bytes(), (out2 / name).read_bytes(), name)

    @unittest.skipIf(jsonschema is None, "jsonschema not installed")
    def test_17_generated_outputs_validate_against_schemas(self):
        r = self.run_skill(self.base_request())
        self.assertEqual(r.returncode, 0, r.stderr)
        pairs = [
            ("references/OUTPUT_SCHEMA.json", "execution_summary.json"),
            ("references/SOURCE_MANIFEST_SCHEMA.json", "source_manifest.before.json"),
            ("references/SOURCE_MANIFEST_SCHEMA.json", "source_manifest.after.json"),
            ("references/PROPERTY_INVENTORY_SCHEMA.json", "property_inventory.json"),
            ("references/INVOCATION_MANIFEST_SCHEMA.json", "invocation_manifest.json"),
        ]
        for schema_rel, output_name in pairs:
            schema = json.loads((ROOT / schema_rel).read_text())
            value = json.loads((self.output / output_name).read_text())
            jsonschema.Draft202012Validator(schema).validate(value)
        input_schema = json.loads((ROOT / "references/INPUT_SCHEMA.json").read_text())
        jsonschema.Draft202012Validator(input_schema).validate(self.base_request())

    def test_18_static_boundary_no_network_model_or_shell_execution(self):
        text = SCRIPT.read_text()
        for forbidden in ["import requests", "import urllib", "import socket", "openai", "anthropic", "shell=True", "os.system("]:
            self.assertNotIn(forbidden, text)
        self.assertIn("shell=False", text)
        self.assertIn("semantic_authority", text)


if __name__ == "__main__":
    unittest.main(verbosity=2)
