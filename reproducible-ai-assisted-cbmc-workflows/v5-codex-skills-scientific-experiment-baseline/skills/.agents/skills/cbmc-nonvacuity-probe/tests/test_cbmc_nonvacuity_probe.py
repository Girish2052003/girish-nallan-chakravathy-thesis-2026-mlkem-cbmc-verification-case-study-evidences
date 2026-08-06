#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

import jsonschema

SKILL_ROOT = Path(__file__).resolve().parents[1]
SCRIPT = SKILL_ROOT / "scripts" / "run_nonvacuity_probe.py"
FIXTURE_REPO = SKILL_ROOT / "tests" / "fixtures" / "repository"
FAKE_CBMC = SKILL_ROOT / "tests" / "fixtures" / "bin" / "cbmc"
REFERENCES = SKILL_ROOT / "references"


def sha(path: Path) -> str:
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


def load_json(path: Path):
    return json.loads(path.read_text())


class ProbeTestCase(unittest.TestCase):
    def setUp(self):
        self.tmp_obj = tempfile.TemporaryDirectory(prefix="skill07-test-")
        self.tmp = Path(self.tmp_obj.name)
        self.repo = self.tmp / "repo"
        shutil.copytree(FIXTURE_REPO, self.repo)
        self.request_path = self.tmp / "request.json"
        self.output = self.tmp / "evidence"

    def tearDown(self):
        self.tmp_obj.cleanup()

    def request(self, mode="reached", required=True):
        tracked = []
        for rel, role in [
            ("harness.c", "candidate-harness"),
            ("src/vector.c", "production-source"),
            ("include/vector.h", "header"),
        ]:
            tracked.append({"path": rel, "sha256": sha(self.repo / rel), "role": role})
        return {
            "schema_version": "1.0",
            "skill_version": "1.0.0-rc1",
            "target_symbol": "vector_subtract",
            "tracked_inputs": tracked,
            "analysis_source_files": ["harness.c", "src/vector.c"],
            "build_context": {
                "include_dirs": ["include"],
                "defines": [],
                "undefines": [],
                "extra_arguments": ["--unwind", "5"],
                "entry_function": "main",
            },
            "cbmc": {
                "executable": str(FAKE_CBMC),
                "timeout_seconds": 2,
                "environment": {"FAKE_CBMC_MODE": mode},
            },
            "probes": [
                {
                    "id": "target-reached",
                    "kind": "TARGET_CALL_REACHABILITY",
                    "source_path": "harness.c",
                    "anchor_line": "vector_subtract(result, left, right);",
                    "occurrence": 1,
                    "insertion_position": "before",
                    "required": required,
                    "note": "Exact caller-selected target call.",
                }
            ],
            "notes": "Synthetic fixture only.",
        }

    def run_request(self, req, output=None):
        self.request_path.write_text(json.dumps(req, indent=2) + "\n")
        output = output or self.output
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--request", str(self.request_path), "--probe-root", str(self.repo), "--output-dir", str(output)],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    def test_01_reached_probe(self):
        cp = self.run_request(self.request("reached"))
        self.assertEqual(cp.returncode, 0, cp.stderr)
        result = load_json(self.output / "probes/target-reached/probe_result.json")
        self.assertEqual(result["reachability_status"], "REACHED_REPORTED_BY_CBMC")
        self.assertEqual(result["semantic_authority"], "NONE")

    def test_02_unreached_probe(self):
        cp = self.run_request(self.request("unreached"))
        self.assertEqual(cp.returncode, 0, cp.stderr)
        result = load_json(self.output / "probes/target-reached/probe_result.json")
        self.assertEqual(result["reachability_status"], "NOT_REACHED_REPORTED_BY_CBMC")

    def test_03_covered_token(self):
        cp = self.run_request(self.request("covered"))
        self.assertEqual(cp.returncode, 0)
        self.assertEqual(load_json(self.output / "probes/target-reached/probe_result.json")["reachability_status"], "REACHED_REPORTED_BY_CBMC")

    def test_04_uncovered_token(self):
        cp = self.run_request(self.request("uncovered"))
        self.assertEqual(cp.returncode, 0)
        self.assertEqual(load_json(self.output / "probes/target-reached/probe_result.json")["reachability_status"], "NOT_REACHED_REPORTED_BY_CBMC")

    def test_05_authoritative_inputs_unchanged(self):
        before = {p: sha(self.repo / p) for p in ["harness.c", "src/vector.c", "include/vector.h"]}
        cp = self.run_request(self.request())
        self.assertEqual(cp.returncode, 0)
        after = {p: sha(self.repo / p) for p in before}
        self.assertEqual(before, after)
        integrity = load_json(self.output / "authoritative_integrity_comparison.json")
        self.assertTrue(integrity["authoritative_inputs_unchanged"])

    def test_06_companion_contains_exact_probe(self):
        cp = self.run_request(self.request())
        self.assertEqual(cp.returncode, 0)
        text = (self.output / "probes/target-reached/companion/harness.c").read_text()
        self.assertEqual(text.count("__CPROVER_cover(1);"), 1)
        self.assertIn("V5_NONVACUITY_PROBE_BEGIN:target-reached", text)

    def test_07_after_insertion(self):
        req = self.request()
        req["probes"][0]["insertion_position"] = "after"
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 0)
        text = (self.output / "probes/target-reached/companion/harness.c").read_text()
        self.assertLess(text.index("vector_subtract(result, left, right);"), text.index("__CPROVER_cover(1);"))

    def test_08_occurrence_selection(self):
        with (self.repo / "harness.c").open("a") as f:
            f.write("\nint second(void) { vector_subtract((int*)0, (int*)0, (int*)0); return 0; }\n")
        req = self.request()
        req["tracked_inputs"][0]["sha256"] = sha(self.repo / "harness.c")
        req["probes"][0]["anchor_line"] = "int second(void) { vector_subtract((int*)0, (int*)0, (int*)0); return 0; }"
        req["probes"][0]["kind"] = "CUSTOM_ANCHOR_REACHABILITY"
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 0, cp.stderr)

    def test_09_assertion_location_probe(self):
        req = self.request()
        req["probes"][0].update({
            "id": "assertion-location",
            "kind": "ASSERTION_LOCATION_REACHABILITY",
            "anchor_line": "__CPROVER_assert(result[0] == left[0] - right[0], \"component zero\");",
        })
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 0, cp.stderr)

    def test_10_feasible_execution_probe(self):
        req = self.request()
        req["probes"][0].update({"id": "feasible-end", "kind": "FEASIBLE_EXECUTION", "anchor_line": "return 0;"})
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 0, cp.stderr)

    def test_11_missing_anchor_is_incomplete(self):
        req = self.request()
        req["probes"][0]["anchor_line"] = "missing_call();"
        req["probes"][0]["kind"] = "CUSTOM_ANCHOR_REACHABILITY"
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 3)
        self.assertTrue((self.output / "runtime_error.txt").exists())

    def test_12_target_probe_requires_lexical_target_call(self):
        req = self.request()
        req["probes"][0]["anchor_line"] = "return 0;"
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_13_assertion_probe_requires_assertion_anchor(self):
        req = self.request()
        req["probes"][0]["kind"] = "ASSERTION_LOCATION_REACHABILITY"
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_14_hash_mismatch_rejected(self):
        req = self.request()
        req["tracked_inputs"][0]["sha256"] = "0" * 64
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_15_path_traversal_rejected(self):
        req = self.request()
        req["tracked_inputs"][0]["path"] = "../harness.c"
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_16_symlink_input_rejected(self):
        target = self.repo / "harness-real.c"
        (self.repo / "harness.c").rename(target)
        (self.repo / "harness.c").symlink_to(target.name)
        req = self.request()
        req["tracked_inputs"][0]["sha256"] = sha(target)
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_17_output_inside_probe_root_rejected(self):
        req = self.request()
        cp = self.run_request(req, self.repo / "evidence")
        self.assertEqual(cp.returncode, 2)

    def test_18_existing_output_rejected(self):
        self.output.mkdir()
        cp = self.run_request(self.request())
        self.assertEqual(cp.returncode, 2)

    def test_19_duplicate_probe_id_rejected(self):
        req = self.request()
        req["probes"].append(dict(req["probes"][0]))
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_20_unknown_request_field_rejected(self):
        req = self.request()
        req["mystery"] = True
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_21_forbidden_coverage_argument_rejected(self):
        req = self.request()
        req["build_context"]["extra_arguments"] = ["--cover", "location"]
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_22_shell_like_argument_rejected(self):
        req = self.request()
        req["build_context"]["extra_arguments"] = ["--unwind", "5;touch-x"]
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_23_secret_environment_rejected(self):
        req = self.request()
        req["cbmc"]["environment"]["API_KEY"] = "nope"
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_24_wrong_executable_basename_rejected(self):
        req = self.request()
        req["cbmc"]["executable"] = "/usr/bin/python3"
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 2)

    def test_25_malformed_json_is_incomplete(self):
        cp = self.run_request(self.request("malformed"))
        self.assertEqual(cp.returncode, 3)
        result = load_json(self.output / "probes/target-reached/probe_result.json")
        self.assertEqual(result["reachability_status"], "INDETERMINATE")
        self.assertFalse(result["stdout_json_parsed"])

    def test_26_tool_error_is_incomplete(self):
        cp = self.run_request(self.request("toolerror"))
        self.assertEqual(cp.returncode, 3)
        result = load_json(self.output / "probes/target-reached/probe_result.json")
        self.assertEqual(result["reachability_status"], "TOOL_ERROR")
        self.assertIn("synthetic stderr", (self.output / "probes/target-reached/cbmc.stderr.txt").read_text())

    def test_27_timeout_is_incomplete(self):
        req = self.request("timeout")
        req["cbmc"]["timeout_seconds"] = 1
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 3)
        result = load_json(self.output / "probes/target-reached/probe_result.json")
        self.assertEqual(result["reachability_status"], "TIMEOUT")

    def test_28_ambiguous_required_probe_is_incomplete(self):
        cp = self.run_request(self.request("ambiguous"))
        self.assertEqual(cp.returncode, 3)
        self.assertEqual(load_json(self.output / "probes/target-reached/probe_result.json")["reachability_status"], "INDETERMINATE")

    def test_29_ambiguous_optional_probe_allows_complete_report(self):
        cp = self.run_request(self.request("ambiguous", required=False))
        self.assertEqual(cp.returncode, 0)
        report = load_json(self.output / "nonvacuity_probe_report.json")
        self.assertEqual(report["report_status"], "COMPLETE")

    def test_30_source_mutation_detected(self):
        req = self.request("mutate")
        req["cbmc"]["environment"]["AUTHORITATIVE_MUTATE_PATH"] = str(self.repo / "harness.c")
        cp = self.run_request(req)
        self.assertEqual(cp.returncode, 5)
        integrity = load_json(self.output / "authoritative_integrity_comparison.json")
        self.assertFalse(integrity["authoritative_inputs_unchanged"])

    def test_31_command_uses_no_shell_and_preserves_options(self):
        cp = self.run_request(self.request())
        self.assertEqual(cp.returncode, 0)
        argv = load_json(self.output / "probes/target-reached/cbmc.argv.json")
        self.assertIn("--unwind", argv)
        self.assertIn("--cover", argv)
        self.assertIn("cover", argv)
        self.assertIn("--show-test-suite", argv)
        self.assertIn("--json-ui", argv)
        self.assertEqual(argv.count("--cover"), 1)

    def test_32_byte_reproducibility(self):
        req = self.request()
        out1 = self.tmp / "evidence-a"
        out2 = self.tmp / "evidence-b"
        cp1 = self.run_request(req, out1)
        cp2 = self.run_request(req, out2)
        self.assertEqual((cp1.returncode, cp2.returncode), (0, 0))
        ignored = {"nonvacuity_probe_artifact_manifest.json"}
        files1 = {p.relative_to(out1).as_posix(): p.read_bytes() for p in out1.rglob("*") if p.is_file() and p.name not in ignored}
        files2 = {p.relative_to(out2).as_posix(): p.read_bytes() for p in out2.rglob("*") if p.is_file() and p.name not in ignored}
        self.assertEqual(files1, files2)

    def test_33_json_schema_validation(self):
        cp = self.run_request(self.request())
        self.assertEqual(cp.returncode, 0)
        pairs = [
            (REFERENCES / "INPUT_SCHEMA.json", self.output / "canonical_request.json"),
            (REFERENCES / "PROBE_RESULT_SCHEMA.json", self.output / "probes/target-reached/probe_result.json"),
            (REFERENCES / "REPORT_SCHEMA.json", self.output / "nonvacuity_probe_report.json"),
            (REFERENCES / "MANIFEST_SCHEMA.json", self.output / "authoritative_input_manifest.before.json"),
            (REFERENCES / "MANIFEST_SCHEMA.json", self.output / "nonvacuity_probe_artifact_manifest.json"),
            (REFERENCES / "INTEGRITY_SCHEMA.json", self.output / "authoritative_integrity_comparison.json"),
            (REFERENCES / "COMPANION_MANIFEST_SCHEMA.json", self.output / "probes/target-reached/companion_manifest.json"),
        ]
        for schema_path, data_path in pairs:
            jsonschema.Draft202012Validator(load_json(schema_path)).validate(load_json(data_path))

    def test_34_artifact_manifest_hashes(self):
        cp = self.run_request(self.request())
        self.assertEqual(cp.returncode, 0)
        manifest = load_json(self.output / "nonvacuity_probe_artifact_manifest.json")
        for item in manifest["files"]:
            path = self.output / item["path"]
            self.assertEqual(sha(path), item["sha256"])
            self.assertEqual(path.stat().st_size, item["size_bytes"])

    def test_35_static_no_network_model_or_shell_true(self):
        text = SCRIPT.read_text()
        for forbidden in ["import requests", "import urllib", "import socket", "openai", "anthropic", "shell=True", "os.system("]:
            self.assertNotIn(forbidden, text)
        self.assertIn("shell=False", text)

    def test_36_forbidden_scientific_statuses_absent(self):
        output = "\n".join(p.read_text(errors="ignore") for p in [SCRIPT, SKILL_ROOT / "SKILL.md"])
        for forbidden in ["PROOF_VALID", "IMPLEMENTATION_CORRECT", "THEOREM_CORRECT", '"ACCEPTED"', '"REJECTED"']:
            self.assertNotIn(forbidden, output)


if __name__ == "__main__":
    unittest.main(verbosity=2)
