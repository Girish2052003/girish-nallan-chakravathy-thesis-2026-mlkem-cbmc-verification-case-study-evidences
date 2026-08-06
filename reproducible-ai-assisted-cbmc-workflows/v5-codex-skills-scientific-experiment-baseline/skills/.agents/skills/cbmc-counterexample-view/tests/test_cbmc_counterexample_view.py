from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "build_counterexample_view.py"
spec = importlib.util.spec_from_file_location("counterexample_view", SCRIPT)
mod = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(mod)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def base_trace():
    return [
        {"stepType": "function-call", "function": "main", "calledFunction": "target", "sourceLocation": {"file": "harness.c", "line": "10", "function": "main"}},
        {"stepType": "assignment", "lhs": "target::x", "value": "1", "sourceLocation": {"file": "target.c", "line": "3", "function": "target"}},
        {"stepType": "assumption", "condition": "x >= 0", "sourceLocation": {"file": "harness.c", "line": "8", "function": "main"}},
        {"stepType": "assignment", "hidden": True, "lhs": "symex::tmp", "value": "99", "sourceLocation": {"file": "target.c", "line": "3", "function": "target"}},
        {"stepType": "assignment", "lhs": "observed", "value": "1", "sourceLocation": {"file": "harness.c", "line": "12", "function": "main"}},
        {"stepType": "assertion", "property": "main.assertion.1", "condition": "observed == 2", "sourceLocation": {"file": "harness.c", "line": "13", "function": "main"}},
        {"stepType": "function-return", "function": "main", "sourceLocation": {"file": "harness.c", "line": "15", "function": "main"}},
    ]


def base_doc():
    return [
        {"messageType": "STATUS-MESSAGE", "messageText": "Building error trace"},
        {"result": [{"property": "main.assertion.1", "status": "FAILURE", "description": "demo failure", "sourceLocation": {"file": "harness.c", "line": "13", "function": "main"}, "trace": base_trace()}]},
        {"cProverStatus": "failure"},
    ]


class Case:
    def __init__(self, td: str, document=None):
        self.root = Path(td)
        self.input_root = self.root / "input"
        self.input_root.mkdir()
        self.trace = self.input_root / "analysis.json"
        self.document = base_doc() if document is None else document
        self.trace.write_text(json.dumps(self.document, sort_keys=True, indent=2) + "\n", encoding="utf-8")
        self.request = {
            "schema_version": "1.0",
            "request_id": "test-001",
            "trace_source": {"path": "analysis.json", "expected_sha256": sha(self.trace), "format": "cbmc-json-ui"},
            "failed_property_id": "main.assertion.1",
            "selection": {
                "target_variables": ["observed"],
                "target_function": "target",
                "source_files": [],
                "context_steps": 0,
                "max_selected_steps": 100,
                "tail_steps_when_unfocused": 20,
                "include_hidden_steps": False,
                "include_function_steps": True,
                "include_assumption_steps": True,
                "include_location_steps": False,
            },
        }
        self.request_path = self.root / "request.json"
        self.output = self.root / "output"
        self.write_request()

    def write_request(self):
        self.request_path.write_text(json.dumps(self.request, sort_keys=True, indent=2) + "\n", encoding="utf-8")

    def refresh_hash(self):
        self.request["trace_source"]["expected_sha256"] = sha(self.trace)
        self.write_request()

    def run(self, output=None):
        return mod.run(self.request_path, self.input_root, output or self.output)


class CounterexampleViewTests(unittest.TestCase):
    def test_01_valid_view(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            self.assertEqual(c.run(), 0)
            report = json.loads((c.output / "counterexample_view_report.json").read_text())
            self.assertEqual(report["view_outcome"], "COUNTEREXAMPLE_VIEW_CREATED")
            self.assertEqual(report["semantic_authority"], "NONE")
            self.assertEqual(report["failed_property"]["property_id"], "main.assertion.1")

    def test_02_hidden_steps_excluded_by_default(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.run()
            compact = json.loads((c.output / "compact_trace.json").read_text())
            self.assertNotIn(3, [s["original_index"] for s in compact["selected_steps"]])
            self.assertEqual(compact["selection"]["visible_step_count"], 6)

    def test_03_hidden_steps_can_be_included(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.request["selection"]["include_hidden_steps"] = True
            c.request["selection"]["target_variables"].append("symex::tmp")
            c.write_request(); c.run()
            compact = json.loads((c.output / "compact_trace.json").read_text())
            self.assertIn(3, [s["original_index"] for s in compact["selected_steps"]])

    def test_04_nested_result_shape(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td, {"result": [{"property": "main.assertion.1", "status": "failed", "trace": base_trace()}]})
            self.assertEqual(c.run(), 0)

    def test_05_standalone_failure_record_shape(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td, {"property": "main.assertion.1", "status": "violated", "description": "x", "trace": base_trace()})
            self.assertEqual(c.run(), 0)

    def test_06_property_not_found(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.request["failed_property_id"] = "missing.property"
            c.write_request()
            with self.assertRaises(mod.ContractError): c.run()
            self.assertFalse(c.output.exists())

    def test_07_nonfailed_property_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            d = base_doc(); d[1]["result"][0]["status"] = "SUCCESS"
            c = Case(td, d)
            with self.assertRaises(mod.ContractError): c.run()

    def test_08_trace_absent_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            d = base_doc(); del d[1]["result"][0]["trace"]
            c = Case(td, d)
            with self.assertRaises(mod.ContractError): c.run()

    def test_09_ambiguous_duplicate_trace_records_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            rec = base_doc()[1]["result"][0]
            c = Case(td, {"result": [copy.deepcopy(rec), copy.deepcopy(rec)]})
            with self.assertRaises(mod.ContractError): c.run()

    def test_10_hash_mismatch_rejected_before_output(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.request["trace_source"]["expected_sha256"] = "0" * 64
            c.write_request()
            with self.assertRaises(mod.ContractError): c.run()
            self.assertFalse(c.output.exists())

    def test_11_path_traversal_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.request["trace_source"]["path"] = "../analysis.json"
            c.write_request()
            with self.assertRaises(mod.ContractError): c.run()

    def test_12_symlink_input_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            link = c.input_root / "linked.json"
            link.symlink_to(c.trace)
            c.request["trace_source"]["path"] = "linked.json"
            c.request["trace_source"]["expected_sha256"] = sha(c.trace)
            c.write_request()
            with self.assertRaises(mod.ContractError): c.run()

    def test_13_output_inside_input_root_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            with self.assertRaises(mod.ContractError): c.run(c.input_root / "evidence")

    def test_14_existing_output_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.output.mkdir()
            with self.assertRaises(mod.ContractError): c.run()

    def test_15_malformed_input_json_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.trace.write_text("{bad", encoding="utf-8")
            c.refresh_hash()
            with self.assertRaises(mod.ContractError): c.run()

    def test_16_unknown_request_field_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.request["choose_root_cause"] = True; c.write_request()
            with self.assertRaises(mod.ContractError): c.run()

    def test_17_focus_and_latest_observed_assignment(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.run()
            compact = json.loads((c.output / "compact_trace.json").read_text())
            latest = compact["latest_observed_assignments"]
            self.assertEqual(latest, [{"lhs": "observed", "original_index": 4, "source_location": {"file": "harness.c", "function": "main", "line": "12"}, "value": "1"}])
            reasons = {r for s in compact["selected_steps"] for r in s["selection_reasons"]}
            self.assertIn("TARGET_VARIABLE_LITERAL_MATCH", reasons)
            self.assertIn("ASSUMPTION_STEP", reasons)
            self.assertIn("FAILURE_STEP", reasons)

    def test_18_unfocused_tail_is_bounded(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            s = c.request["selection"]
            s["target_variables"] = []; s["target_function"] = None; s["source_files"] = []
            s["include_function_steps"] = False; s["include_assumption_steps"] = False
            s["tail_steps_when_unfocused"] = 2; s["context_steps"] = 0
            c.write_request(); c.run()
            compact = json.loads((c.output / "compact_trace.json").read_text())
            indices = [x["original_index"] for x in compact["selected_steps"]]
            self.assertEqual(indices, [5, 6])

    def test_19_selection_truncation_warns(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.request["selection"]["max_selected_steps"] = 2
            c.write_request(); c.run()
            report = json.loads((c.output / "counterexample_view_report.json").read_text())
            self.assertEqual(report["report_status"], "COMPLETE_WITH_WARNINGS")
            self.assertTrue(any("truncated" in w.lower() for w in report["warnings"]))

    def test_20_byte_reproducibility_same_input(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            out1 = c.root / "out1"; out2 = c.root / "out2"
            c.run(out1); c.run(out2)
            files1 = sorted(p.relative_to(out1).as_posix() for p in out1.rglob("*") if p.is_file())
            files2 = sorted(p.relative_to(out2).as_posix() for p in out2.rglob("*") if p.is_file())
            self.assertEqual(files1, files2)
            for rel in files1:
                self.assertEqual((out1 / rel).read_bytes(), (out2 / rel).read_bytes(), rel)

    def test_21_json_schema_validation(self):
        import jsonschema
        mapping = {
            "INPUT_SCHEMA.json": ROOT / "examples/request.example.json",
            "SELECTED_PROPERTY_SCHEMA.json": ROOT / "examples/sample-output/selected_property.json",
            "INPUT_MANIFEST_SCHEMA.json": ROOT / "examples/sample-output/input_manifest.json",
            "TRACE_INDEX_SCHEMA.json": ROOT / "examples/sample-output/trace_index.json",
            "COMPACT_TRACE_SCHEMA.json": ROOT / "examples/sample-output/compact_trace.json",
            "OUTPUT_SCHEMA.json": ROOT / "examples/sample-output/counterexample_view_report.json",
            "ARTIFACT_MANIFEST_SCHEMA.json": ROOT / "examples/sample-output/counterexample_view_artifact_manifest.json",
        }
        for schema_name, instance_path in mapping.items():
            schema = json.loads((ROOT / "references" / schema_name).read_text())
            instance = json.loads(instance_path.read_text())
            jsonschema.Draft202012Validator(schema).validate(instance)

    def test_22_artifact_manifest_hashes(self):
        manifest = json.loads((ROOT / "examples/sample-output/counterexample_view_artifact_manifest.json").read_text())
        for entry in manifest["artifacts"]:
            p = ROOT / "examples/sample-output" / entry["path"]
            self.assertTrue(p.is_file())
            self.assertEqual(sha(p), entry["sha256"])
            self.assertEqual(p.stat().st_size, entry["size_bytes"])

    def test_23_static_no_network_model_subprocess_or_shell(self):
        text = SCRIPT.read_text(encoding="utf-8")
        forbidden = ["import socket", "import requests", "import urllib", "import http", "import subprocess", "import openai", "os.system(", "shell=True", "Popen(", "subprocess."]
        for token in forbidden:
            self.assertNotIn(token, text)

    def test_24_raw_input_unchanged(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); before = c.trace.read_bytes(); c.run()
            self.assertEqual(before, c.trace.read_bytes())

    def test_25_unknown_step_type_warns_without_diagnosis(self):
        with tempfile.TemporaryDirectory() as td:
            d = base_doc(); d[1]["result"][0]["trace"].insert(1, {"lhs": "mystery", "value": 7})
            c = Case(td, d); c.run()
            report_text = (c.output / "counterexample_view_report.json").read_text().lower()
            self.assertIn("unknown", report_text)
            for forbidden in ["root_cause", "repair_recommendation", "implementation_defect", "harness_is_wrong"]:
                self.assertNotIn(forbidden, report_text)

    def test_26_empty_trace_creates_warned_view(self):
        with tempfile.TemporaryDirectory() as td:
            d = base_doc(); d[1]["result"][0]["trace"] = []
            c = Case(td, d); self.assertEqual(c.run(), 0)
            report = json.loads((c.output / "counterexample_view_report.json").read_text())
            self.assertEqual(report["report_status"], "COMPLETE_WITH_WARNINGS")
            self.assertEqual(report["trace_counts"]["selected"], 0)


if __name__ == "__main__":
    unittest.main(verbosity=2)
