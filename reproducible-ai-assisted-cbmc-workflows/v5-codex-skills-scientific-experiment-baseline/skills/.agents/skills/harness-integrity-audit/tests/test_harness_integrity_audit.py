from __future__ import annotations

import ast
import copy
import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "audit_harness_integrity.py"
spec = importlib.util.spec_from_file_location("harness_integrity", SCRIPT)
mod = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(mod)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def finding(report: dict, check_id: str) -> dict:
    return next(x for x in report["findings"] if x["check_id"] == check_id)


class Case:
    def __init__(self, td: str):
        self.root = Path(td)
        self.audit_root = self.root / "repository"
        shutil.copytree(ROOT / "tests" / "fixtures" / "repository", self.audit_root)
        self.request = json.loads((ROOT / "tests" / "fixtures" / "request_valid.json").read_text())
        self.request_path = self.root / "request.json"
        self.output = self.root / "output"
        self.refresh_all_hashes()

    @property
    def harness(self) -> Path:
        return self.audit_root / self.request["harness"]["path"]

    def write_request(self):
        self.request_path.write_text(json.dumps(self.request, sort_keys=True, indent=2) + "\n", encoding="utf-8")

    def refresh_path_hash(self, rel: str):
        value = sha(self.audit_root / rel)
        if self.request["harness"]["path"] == rel:
            self.request["harness"]["expected_sha256"] = value
        for key in ("production_files", "actual_build_inputs"):
            for rec in self.request[key]:
                if rec["path"] == rel:
                    rec["expected_sha256"] = value
        diag = self.request.get("diagnostics", {}).get("undefined_functions")
        if diag and diag["path"] == rel:
            diag["expected_sha256"] = value

    def refresh_all_hashes(self):
        paths = {self.request["harness"]["path"]}
        paths.update(x["path"] for x in self.request["production_files"])
        paths.update(x["path"] for x in self.request["actual_build_inputs"])
        diag = self.request.get("diagnostics", {}).get("undefined_functions")
        if diag: paths.add(diag["path"])
        for rel in paths:
            if (self.audit_root / rel).exists(): self.refresh_path_hash(rel)
        self.write_request()

    def append_harness(self, text: str, refresh: bool = True):
        self.harness.write_text(self.harness.read_text() + text, encoding="utf-8")
        if refresh: self.refresh_path_hash(self.request["harness"]["path"]); self.write_request()

    def replace_harness(self, old: str, new: str, refresh: bool = True):
        self.harness.write_text(self.harness.read_text().replace(old, new), encoding="utf-8")
        if refresh: self.refresh_path_hash(self.request["harness"]["path"]); self.write_request()

    def run(self, output: Path | None = None):
        return mod.run(self.request_path, self.audit_root, output or self.output)

    def report(self, output: Path | None = None):
        return json.loads(((output or self.output) / "harness_integrity_audit_report.json").read_text())


class HarnessIntegrityAuditTests(unittest.TestCase):
    def test_01_clean_audit(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            self.assertEqual(c.run(), 0)
            report = c.report()
            self.assertEqual(report["report_status"], "COMPLETE")
            self.assertEqual(report["semantic_authority"], "NONE")
            self.assertEqual(report["gate_authority"], "NONE")
            self.assertTrue(all(x["status"] == "CHECKED" for x in report["findings"]))

    def test_02_missing_target_call_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.replace_harness("  vector_subtract(result, left, right);\n", "")
            c.run(); f = finding(c.report(), "EXPECTED_TARGET_CALL")
            self.assertEqual(f["status"], "WARNING")
            self.assertEqual(f["evidence"]["lexical_call_count"], 0)

    def test_03_target_definition_replacement_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.append_harness("\nvoid vector_subtract(int r[4], const int a[4], const int b[4]) { r[0] = 0; }\n")
            c.run(); f = finding(c.report(), "TARGET_REPLACEMENT_OR_STUB_PATTERN")
            self.assertEqual(f["status"], "WARNING")
            self.assertTrue(any(x["kind"] == "TARGET_DEFINITION_OUTSIDE_AUTHORITATIVE_FILE" for x in f["evidence"]["patterns"]))

    def test_04_target_macro_replacement_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.append_harness("\n#define vector_subtract fake_vector_subtract\n")
            c.run(); f = finding(c.report(), "TARGET_REPLACEMENT_OR_STUB_PATTERN")
            self.assertEqual(f["status"], "WARNING")
            self.assertTrue(any(x["kind"] == "TARGET_MACRO_DEFINITION_IN_HARNESS" for x in f["evidence"]["patterns"]))

    def test_05_no_user_assertion_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.replace_harness('  __CPROVER_assert(result[0] == left[0] - right[0], "coefficient zero follows subtraction");\n', "")
            c.run(); self.assertEqual(finding(c.report(), "USER_ASSERTION_PRESENCE")["status"], "WARNING")

    def test_06_assume_false_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.append_harness("\nvoid extra(void) { __CPROVER_assume(0); }\n")
            c.run(); f = finding(c.report(), "OBVIOUS_FALSE_ASSUMPTION")
            self.assertEqual(f["status"], "WARNING")
            self.assertEqual(f["evidence"]["items"][0]["obvious_truth_classification"], "FALSE")

    def test_07_reflexive_false_assumption_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.append_harness("\nvoid extra(void) { int x; __CPROVER_assume(x != x); }\n")
            c.run(); self.assertEqual(finding(c.report(), "OBVIOUS_FALSE_ASSUMPTION")["status"], "WARNING")

    def test_08_constant_false_if_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.append_harness("\nvoid extra(void) { if (0) { vector_subtract(0, 0, 0); } }\n")
            c.run(); self.assertEqual(finding(c.report(), "OBVIOUS_CONSTANT_FALSE_CONTROL")["status"], "WARNING")

    def test_09_constant_false_for_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.append_harness("\nvoid extra(void) { int i; for (i = 0; 1 == 0; ++i) { } }\n")
            c.run(); self.assertEqual(finding(c.report(), "OBVIOUS_CONSTANT_FALSE_CONTROL")["status"], "WARNING")

    def test_10_duplicate_assertion_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.append_harness("\nvoid extra(void) { int x; __CPROVER_assert(x == x, \"a\"); __CPROVER_assert(x==x, \"b\"); }\n")
            c.run(); self.assertEqual(finding(c.report(), "DUPLICATE_ASSERTION_PATTERN")["status"], "WARNING")

    def test_11_trivial_true_assertion_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.append_harness("\nvoid extra(void) { __CPROVER_assert(1, \"always\"); }\n")
            c.run(); f = finding(c.report(), "OBVIOUS_TRIVIAL_ASSERTION_PATTERN")
            self.assertEqual(f["status"], "WARNING")
            self.assertEqual(f["evidence"]["items"][-1]["obvious_truth_classification"], "TRUE")

    def test_12_trivial_false_assertion_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.append_harness("\nvoid extra(void) { __CPROVER_assert(2 < 1, \"false\"); }\n")
            c.run(); self.assertEqual(finding(c.report(), "OBVIOUS_TRIVIAL_ASSERTION_PATTERN")["status"], "WARNING")

    def test_13_assertion_identical_to_assumption_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.append_harness("\nvoid extra(void) { int x; __CPROVER_assume(x >= 0); __CPROVER_assert(x>=0, \"same\"); }\n")
            c.run(); self.assertEqual(finding(c.report(), "ASSERTION_IDENTICAL_TO_ASSUMPTION_PATTERN")["status"], "WARNING")

    def test_14_production_hash_mismatch_is_evidence_not_contract_failure(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.request["production_files"][0]["expected_sha256"] = "0" * 64
            c.write_request()
            self.assertEqual(c.run(), 0)
            self.assertEqual(finding(c.report(), "PRODUCTION_SOURCE_HASH_BINDING")["status"], "WARNING")

    def test_15_harness_hash_mismatch_is_evidence(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.request["harness"]["expected_sha256"] = "0" * 64
            c.write_request(); self.assertEqual(c.run(), 0)
            self.assertEqual(finding(c.report(), "HARNESS_HASH_BINDING")["status"], "WARNING")

    def test_16_unexpected_build_input_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            (c.audit_root / "extra.c").write_text("int extra(void) { return 0; }\n")
            c.request["actual_build_inputs"].append({"path":"extra.c","expected_sha256":sha(c.audit_root/"extra.c"),"role":"unexpected_source"})
            c.write_request(); c.run()
            f = finding(c.report(), "BUILD_INPUT_ALLOWLIST_COMPARISON")
            self.assertEqual(f["status"], "WARNING"); self.assertEqual(f["evidence"]["unexpected"], ["extra.c"])

    def test_17_missing_allowed_build_input_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.request["allowed_build_inputs"].append("missing.c"); c.write_request(); c.run()
            self.assertEqual(finding(c.report(), "BUILD_INPUT_ALLOWLIST_COMPARISON")["status"], "WARNING")

    def test_18_undefined_function_diagnostic_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            p = c.audit_root / c.request["diagnostics"]["undefined_functions"]["path"]
            p.write_text("mystery_function\nanother_missing\n")
            c.refresh_path_hash(c.request["diagnostics"]["undefined_functions"]["path"]); c.write_request(); c.run()
            f = finding(c.report(), "UNDEFINED_FUNCTION_DIAGNOSTIC")
            self.assertEqual(f["status"], "WARNING")
            self.assertEqual(f["evidence"]["functions"], ["another_missing", "mystery_function"])

    def test_19_missing_diagnostic_is_not_checkable(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.request["diagnostics"] = {}; c.write_request(); c.run()
            self.assertEqual(finding(c.report(), "UNDEFINED_FUNCTION_DIAGNOSTIC")["status"], "NOT_CHECKABLE")

    def test_20_diagnostic_hash_mismatch_warning(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.request["diagnostics"]["undefined_functions"]["expected_sha256"] = "0"*64; c.write_request(); c.run()
            self.assertEqual(finding(c.report(), "UNDEFINED_FUNCTION_DIAGNOSTIC")["status"], "WARNING")

    def test_21_comments_and_literals_do_not_trigger_patterns(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.append_harness('\n/* __CPROVER_assume(0); __CPROVER_assert(1,"x"); if(0){} */\nconst char *note = "vector_subtract(0,0,0) __CPROVER_assume(0)";\n')
            c.run(); report = c.report()
            self.assertEqual(finding(report, "OBVIOUS_FALSE_ASSUMPTION")["status"], "CHECKED")
            self.assertEqual(finding(report, "OBVIOUS_CONSTANT_FALSE_CONTROL")["status"], "CHECKED")
            self.assertEqual(finding(report, "EXPECTED_TARGET_CALL")["evidence"]["lexical_call_count"], 1)

    def test_22_function_declaration_is_not_counted_as_call(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            c.replace_harness("  vector_subtract(result, left, right);\n", "")
            c.append_harness("\nvoid vector_subtract(int result[4], const int left[4], const int right[4]);\n")
            c.run(); self.assertEqual(finding(c.report(), "EXPECTED_TARGET_CALL")["evidence"]["lexical_call_count"], 0)

    def test_23_disabled_checks_become_not_checkable(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            for k in c.request["checks"]: c.request["checks"][k] = False
            c.write_request(); c.run(); report = c.report()
            ids = {"EXPECTED_TARGET_CALL","TARGET_REPLACEMENT_OR_STUB_PATTERN","ASSUMPTION_INVENTORY","USER_ASSERTION_PRESENCE","OBVIOUS_FALSE_ASSUMPTION","OBVIOUS_CONSTANT_FALSE_CONTROL","DUPLICATE_ASSERTION_PATTERN","OBVIOUS_TRIVIAL_ASSERTION_PATTERN","ASSERTION_IDENTICAL_TO_ASSUMPTION_PATTERN","BUILD_INPUT_ALLOWLIST_COMPARISON","UNDEFINED_FUNCTION_DIAGNOSTIC"}
            self.assertTrue(all(finding(report, x)["status"] == "NOT_CHECKABLE" for x in ids))

    def test_24_path_traversal_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.request["harness"]["path"] = "../harness.c"; c.write_request()
            with self.assertRaises(mod.ContractError): c.run()
            self.assertFalse(c.output.exists())

    def test_25_symlink_input_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            link = c.audit_root / "linked.c"; link.symlink_to(c.audit_root / "harness.c")
            c.request["harness"]["path"] = "linked.c"; c.request["harness"]["expected_sha256"] = sha(c.audit_root/"harness.c")
            c.write_request()
            with self.assertRaises(mod.ContractError): c.run()

    def test_26_output_inside_audit_root_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td)
            with self.assertRaises(mod.ContractError): c.run(c.audit_root / "evidence")

    def test_27_existing_output_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.output.mkdir()
            with self.assertRaises(mod.ContractError): c.run()

    def test_28_malformed_and_unknown_request_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.request["automatic_rejection"] = True; c.write_request()
            with self.assertRaises(mod.ContractError): c.run()
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); c.request_path.write_text("{bad")
            with self.assertRaises(mod.ContractError): c.run()

    def test_29_byte_reproducibility(self):
        with tempfile.TemporaryDirectory() as td:
            c = Case(td); out1=c.root/"out1"; out2=c.root/"out2"; c.run(out1); c.run(out2)
            files1=sorted(p.relative_to(out1).as_posix() for p in out1.rglob("*") if p.is_file())
            files2=sorted(p.relative_to(out2).as_posix() for p in out2.rglob("*") if p.is_file())
            self.assertEqual(files1, files2)
            for rel in files1: self.assertEqual((out1/rel).read_bytes(), (out2/rel).read_bytes(), rel)

    def test_30_json_schema_validation(self):
        import jsonschema
        sample = ROOT / "examples" / "sample-output"
        mapping = {
            "INPUT_SCHEMA.json": ROOT / "examples" / "request.example.json",
            "AUDIT_REPORT_SCHEMA.json": sample / "harness_integrity_audit_report.json",
            "SOURCE_MANIFEST_SCHEMA.json": sample / "source_manifest.json",
            "INVENTORY_SCHEMA.json": sample / "assumption_inventory.json",
            "TARGET_BINDING_SCHEMA.json": sample / "target_binding_report.json",
            "FINDINGS_SCHEMA.json": sample / "findings.json",
            "ARTIFACT_MANIFEST_SCHEMA.json": sample / "harness_integrity_audit_artifact_manifest.json",
        }
        for schema_name, instance_path in mapping.items():
            schema=json.loads((ROOT/"references"/schema_name).read_text()); instance=json.loads(instance_path.read_text())
            jsonschema.Draft202012Validator(schema).validate(instance)
        inv=json.loads((ROOT/"references"/"INVENTORY_SCHEMA.json").read_text())
        jsonschema.Draft202012Validator(inv).validate(json.loads((sample/"assertion_inventory.json").read_text()))

    def test_31_artifact_manifest_hashes(self):
        sample=ROOT/"examples"/"sample-output"
        manifest=json.loads((sample/"harness_integrity_audit_artifact_manifest.json").read_text())
        for e in manifest["artifacts"]:
            p=sample/e["path"]; self.assertTrue(p.is_file()); self.assertEqual(sha(p),e["sha256"]); self.assertEqual(p.stat().st_size,e["size_bytes"])

    def test_32_static_no_network_model_subprocess_or_shell(self):
        tree=ast.parse(SCRIPT.read_text())
        forbidden_modules={"socket","urllib","http","requests","subprocess","openai","anthropic","boto3"}
        imports=set()
        for node in ast.walk(tree):
            if isinstance(node, ast.Import): imports.update(a.name.split('.')[0] for a in node.names)
            elif isinstance(node, ast.ImportFrom) and node.module: imports.add(node.module.split('.')[0])
        self.assertFalse(imports & forbidden_modules)
        text=SCRIPT.read_text()
        self.assertNotIn("os.system(", text); self.assertNotIn("shell=True", text); self.assertNotIn("Popen(", text)

    def test_33_raw_inputs_unchanged(self):
        with tempfile.TemporaryDirectory() as td:
            c=Case(td); before={p.relative_to(c.audit_root).as_posix():sha(p) for p in c.audit_root.rglob('*') if p.is_file()}
            c.run(); after={p.relative_to(c.audit_root).as_posix():sha(p) for p in c.audit_root.rglob('*') if p.is_file()}
            self.assertEqual(before,after)

    def test_34_only_allowed_finding_status_vocabulary(self):
        with tempfile.TemporaryDirectory() as td:
            c=Case(td); c.run(); report=c.report()
            self.assertLessEqual({x["status"] for x in report["findings"]},{"CHECKED","WARNING","NOT_CHECKABLE"})
            serialized=json.dumps(report).upper()
            for forbidden in ["PROOF_VALID","ACCEPTED","REJECTED","IMPLEMENTATION_CORRECT"]:
                self.assertNotIn(forbidden,serialized)

    def test_35_general_non_mlkem_target(self):
        with tempfile.TemporaryDirectory() as td:
            c=Case(td); c.run(); report=c.report()
            self.assertEqual(report["target_symbol"],"vector_subtract")
            self.assertEqual(finding(report,"EXPECTED_TARGET_CALL")["status"],"CHECKED")


if __name__ == "__main__":
    unittest.main()
