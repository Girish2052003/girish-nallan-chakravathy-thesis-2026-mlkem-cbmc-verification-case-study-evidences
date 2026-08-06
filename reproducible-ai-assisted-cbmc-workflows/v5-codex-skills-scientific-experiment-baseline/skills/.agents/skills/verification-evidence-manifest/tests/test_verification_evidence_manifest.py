from __future__ import annotations

import copy
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
from unittest import mock

import jsonschema

SKILL = Path(__file__).resolve().parents[1]
SCRIPT = SKILL / "scripts" / "build_evidence_manifest.py"
FIXTURE = SKILL / "tests" / "fixtures" / "run-workspace"
REQUEST_EXAMPLE = SKILL / "examples" / "request.example.json"
REFS = SKILL / "references"

spec = importlib.util.spec_from_file_location("skill8_impl", SCRIPT)
impl = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(impl)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class Skill8Tests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.run_root = self.root / "run"
        shutil.copytree(FIXTURE, self.run_root)
        self.req = json.loads(REQUEST_EXAMPLE.read_text())

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def write_request(self, req=None) -> Path:
        path = self.root / "request.json"
        path.write_text(json.dumps(self.req if req is None else req, sort_keys=True, indent=2) + "\n")
        return path

    def run_cli(self, req=None, out_name="out"):
        request = self.write_request(req)
        out = self.root / out_name
        cp = subprocess.run([sys.executable, str(SCRIPT), "--request", str(request), "--run-root", str(self.run_root), "--output-dir", str(out)], text=True, capture_output=True)
        return cp, out

    def load(self, out: Path, name: str):
        return json.loads((out / name).read_text())

    def codes(self, out: Path):
        return [x["code"] for x in self.load(out, "missing_evidence_warnings.json")["warnings"]]

    # 01
    def test_01_complete_manifest(self):
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 0, cp.stderr)
        m = self.load(out, "manifest.json")
        self.assertEqual(m["manifest_status"], "COMPLETE")
        self.assertEqual(m["semantic_authority"], "NONE")
        self.assertEqual(m["gate_authority"], "NONE")

    # 02
    def test_02_required_file_missing_is_incomplete(self):
        (self.run_root / "harness/harness.c").unlink()
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 2)
        self.assertEqual(self.load(out, "manifest.json")["manifest_status"], "INCOMPLETE")
        self.assertIn("MISSING_REQUIRED_ARTIFACT", self.codes(out))

    # 03
    def test_03_optional_file_missing_is_warning(self):
        (self.run_root / "repairs/iteration-1.json").unlink()
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 0)
        self.assertEqual(self.load(out, "manifest.json")["manifest_status"], "COMPLETE_WITH_WARNINGS")
        self.assertIn("MISSING_OPTIONAL_ARTIFACT", self.codes(out))

    # 04
    def test_04_required_hash_mismatch_is_incomplete(self):
        self.req["artifacts"][3]["expected_sha256"] = "0" * 64
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 2)
        self.assertIn("REQUIRED_HASH_MISMATCH", self.codes(out))

    # 05
    def test_05_optional_hash_mismatch_is_warning(self):
        self.req["artifacts"][7]["expected_sha256"] = "0" * 64
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 0)
        self.assertIn("OPTIONAL_HASH_MISMATCH", self.codes(out))

    # 06
    def test_06_missing_required_role_is_incomplete(self):
        self.req["required_roles"].append("INTEGRITY_AUDIT")
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 2)
        self.assertIn("MISSING_REQUIRED_ROLE", self.codes(out))

    # 07
    def test_07_source_revision_preserved(self):
        cp, out = self.run_cli()
        m = self.load(out, "manifest.json")
        self.assertEqual(m["source_revision"]["kind"], "GIT_COMMIT")
        self.assertEqual(m["source_revision"]["evidence_path"], "source/revision.txt")

    # 08
    def test_08_property_record_preserved_unverified(self):
        cp, out = self.run_cli()
        p = self.load(out, "property_inventory.json")["records"][0]
        self.assertEqual(p["authority"], "CODEX_SUPPLIED_UNVERIFIED")
        self.assertIn("result[i]", p["statement"])

    # 09
    def test_09_final_status_preserved_unverified(self):
        cp, out = self.run_cli()
        s = self.load(out, "manifest.json")["final_status_supplied_by_codex"]
        self.assertEqual(s["value"], "CANDIDATE_RUN_COMPLETED")
        self.assertEqual(s["authority"], "CODEX_SUPPLIED_UNVERIFIED")

    # 10
    def test_10_harness_assumption_inventory(self):
        cp, out = self.run_cli()
        f = self.load(out, "harness_claim_inventory.json")["files"][0]
        self.assertEqual(len(f["assumptions"]), 1)
        self.assertEqual(f["assumptions"][0]["condition_normalized"], "i >= 0 && i < 4")

    # 11
    def test_11_harness_assertion_inventory(self):
        cp, out = self.run_cli()
        f = self.load(out, "harness_claim_inventory.json")["files"][0]
        self.assertEqual(len(f["assertions"]), 2)
        self.assertEqual({x["function"] for x in f["assertions"]}, {"__CPROVER_assert", "assert"})

    # 12
    def test_12_comments_and_strings_do_not_create_claims(self):
        cp, out = self.run_cli()
        f = self.load(out, "harness_claim_inventory.json")["files"][0]
        calls = [x["raw_call"] for x in f["assumptions"] + f["assertions"]]
        self.assertFalse(any("hidden string" in x for x in calls))
        self.assertFalse(any("assume(0)" in x for x in calls))

    # 13
    def test_13_custom_claim_functions(self):
        h = self.run_root / "harness/harness.c"
        h.write_text(h.read_text() + "\nvoid extra(int x){ MY_ASSUME(x); MY_ASSERT(x); }\n")
        self.req["artifacts"][3]["expected_sha256"] = sha(h)
        self.req["harness_parsing"]["assume_functions"] = ["MY_ASSUME"]
        self.req["harness_parsing"]["assert_functions"] = ["MY_ASSERT"]
        cp, out = self.run_cli()
        f = self.load(out, "harness_claim_inventory.json")["files"][0]
        self.assertEqual(len(f["assumptions"]), 1)
        self.assertEqual(len(f["assertions"]), 1)

    # 14
    def test_14_harness_parsing_can_be_disabled(self):
        self.req["harness_parsing"]["enabled"] = False
        cp, out = self.run_cli()
        self.assertEqual(self.load(out, "harness_claim_inventory.json")["files"], [])

    # 15
    def test_15_json_pointer_extraction(self):
        cp, out = self.run_cli()
        fields = {x["label"]: x for x in self.load(out, "extracted_field_index.json")["fields"]}
        self.assertEqual(fields["cbmc_version"]["value"], "6.9.0")
        self.assertEqual(fields["failed_properties"]["value"], 0)

    # 16
    def test_16_json_pointer_missing_is_warning(self):
        self.req["artifacts"][1]["extract_json_fields"].append({"label":"missing","json_pointer":"/does/not/exist"})
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 0)
        self.assertIn("JSON_POINTER_NOT_FOUND", self.codes(out))

    # 17
    def test_17_malformed_json_is_warning(self):
        p = self.run_root / "skills/spec/grounding_report.json"
        p.write_text("{not json\n")
        self.req["artifacts"][7]["expected_sha256"] = sha(p)
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 0)
        self.assertIn("JSON_PARSE_FAILED", self.codes(out))

    # 18
    def test_18_root_json_pointer(self):
        self.req["artifacts"][1]["extract_json_fields"] = [{"label":"whole","json_pointer":""}]
        cp, out = self.run_cli()
        field = self.load(out, "extracted_field_index.json")["fields"][0]
        self.assertTrue(field["found"])
        self.assertIsInstance(field["value"], dict)

    # 19
    def test_19_skill_records_are_caller_declared(self):
        cp, out = self.run_cli()
        obj = self.load(out, "skill_use_records.json")
        self.assertIn("cbmc-execute", obj["skills"])
        self.assertEqual(obj["records_are"], "CALLER_DECLARED_ARTIFACT_LABELS_NOT_INFERRED_INVOCATIONS")

    # 20
    def test_20_iteration_index(self):
        cp, out = self.run_cli()
        obj = self.load(out, "iteration_index.json")
        self.assertEqual(set(obj["iterations"]), {"0", "1"})
        self.assertEqual(obj["records_are"], "CALLER_DECLARED_ITERATION_LABELS_NOT_INFERRED_REPAIRS")

    # 21
    def test_21_unlisted_file_warning(self):
        (self.run_root / "extra.txt").write_text("unlisted\n")
        cp, out = self.run_cli()
        self.assertIn("UNLISTED_FILES_PRESENT", self.codes(out))
        unlisted = self.load(out, "missing_evidence_warnings.json")["unlisted_files"]
        self.assertEqual(unlisted[0]["path"], "extra.txt")

    # 22
    def test_22_unlisted_scan_can_be_disabled(self):
        (self.run_root / "extra.txt").write_text("unlisted\n")
        self.req["scan_policy"]["report_unlisted_files"] = False
        cp, out = self.run_cli()
        self.assertNotIn("UNLISTED_FILES_PRESENT", self.codes(out))

    # 23
    def test_23_unlisted_scan_truncation(self):
        (self.run_root / "extra.txt").write_text("unlisted\n")
        self.req["scan_policy"]["max_files"] = 1
        (self.run_root / "extra2.txt").write_text("unlisted2\n")
        cp, out = self.run_cli()
        self.assertIn("UNLISTED_SCAN_TRUNCATED", self.codes(out))

    # 24
    def test_24_property_provenance_missing_warning(self):
        self.req["property_records"][0]["provenance"]["path"] = "missing/property.md"
        cp, out = self.run_cli()
        self.assertIn("PROPERTY_PROVENANCE_MISSING", self.codes(out))

    # 25
    def test_25_property_line_out_of_range_warning(self):
        self.req["property_records"][0]["provenance"]["line_end"] = 999
        cp, out = self.run_cli()
        self.assertIn("PROPERTY_PROVENANCE_LINE_OUT_OF_RANGE", self.codes(out))

    # 26
    def test_26_binary_opaque_artifact_is_hashed(self):
        cp, out = self.run_cli()
        entries = {x["path"]: x for x in self.load(out, "input_file_manifest.before.json")}
        self.assertEqual(entries["cbmc/raw.bin"]["actual_sha256"], "3d1f57c984978ef98a18378c8166c1cb8ede02c03eeb6aee7e2f121dfeee3e56")

    # 27
    def test_27_oversized_harness_parse_warning(self):
        self.req["scan_policy"]["max_text_parse_bytes"] = 10
        cp, out = self.run_cli()
        self.assertIn("HARNESS_PARSE_SKIPPED_SIZE", self.codes(out))

    # 28
    def test_28_path_traversal_rejected(self):
        self.req["artifacts"][0]["path"] = "../revision.txt"
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 3)
        self.assertFalse(out.exists())

    # 29
    def test_29_absolute_path_rejected(self):
        self.req["artifacts"][0]["path"] = "/tmp/revision.txt"
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 3)
        self.assertFalse(out.exists())

    # 30
    def test_30_direct_symlink_rejected(self):
        real = self.run_root / "source/revision.txt"
        link = self.run_root / "source/link.txt"
        link.symlink_to(real)
        self.req["artifacts"][0]["path"] = "source/link.txt"
        self.req["source_revision"]["evidence_path"] = "source/link.txt"
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 3)

    # 31
    def test_31_parent_symlink_rejected(self):
        target = self.run_root / "source"
        link = self.run_root / "linked-source"
        link.symlink_to(target, target_is_directory=True)
        self.req["artifacts"][0]["path"] = "linked-source/revision.txt"
        self.req["source_revision"]["evidence_path"] = "linked-source/revision.txt"
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 3)

    # 32
    def test_32_output_inside_run_root_rejected(self):
        request = self.write_request()
        out = self.run_root / "evidence"
        cp = subprocess.run([sys.executable, str(SCRIPT), "--request", str(request), "--run-root", str(self.run_root), "--output-dir", str(out)], text=True, capture_output=True)
        self.assertEqual(cp.returncode, 3)

    # 33
    def test_33_existing_output_rejected(self):
        out = self.root / "out"
        out.mkdir()
        cp, _ = self.run_cli(out_name="out")
        self.assertEqual(cp.returncode, 3)

    # 34
    def test_34_duplicate_artifact_path_rejected(self):
        self.req["artifacts"].append(copy.deepcopy(self.req["artifacts"][0]))
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 3)
        self.assertFalse(out.exists())

    # 35
    def test_35_unknown_request_field_rejected(self):
        self.req["mystery"] = True
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 3)

    # 36
    def test_36_invalid_role_rejected(self):
        self.req["artifacts"][0]["role"] = "PROOF_VALID"
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 3)

    # 37
    def test_37_source_revision_evidence_binding_rejected(self):
        self.req["source_revision"]["evidence_path"] = "environment/environment.json"
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 3)

    # 38
    def test_38_input_mutation_detected(self):
        request_path = self.write_request()
        out = self.root / "out"
        original = impl.make_input_manifest
        calls = {"n": 0}
        def wrapper(request, root):
            calls["n"] += 1
            if calls["n"] == 2:
                (root / "harness/harness.c").write_text((root / "harness/harness.c").read_text() + "\n/* changed */\n")
            return original(request, root)
        with mock.patch.object(impl, "make_input_manifest", side_effect=wrapper):
            rc = impl.build_manifest(request_path, self.run_root, out)
        self.assertEqual(rc, 2)
        self.assertIn("INPUT_MUTATION_DETECTED", self.codes(out))

    # 39
    def test_39_input_files_unchanged_in_normal_run(self):
        before = {p.relative_to(self.run_root).as_posix(): sha(p) for p in self.run_root.rglob("*") if p.is_file()}
        cp, out = self.run_cli()
        after = {p.relative_to(self.run_root).as_posix(): sha(p) for p in self.run_root.rglob("*") if p.is_file()}
        self.assertEqual(before, after)
        self.assertTrue(self.load(out, "input_integrity_comparison.json")["unchanged"])

    # 40
    def test_40_byte_for_byte_reproducibility(self):
        cp1, out1 = self.run_cli(out_name="out1")
        cp2, out2 = self.run_cli(out_name="out2")
        files1 = {p.relative_to(out1).as_posix(): p.read_bytes() for p in out1.rglob("*") if p.is_file()}
        files2 = {p.relative_to(out2).as_posix(): p.read_bytes() for p in out2.rglob("*") if p.is_file()}
        self.assertEqual(files1, files2)

    # 41
    def test_41_all_json_schemas_validate(self):
        cp, out = self.run_cli()
        mappings = {
            "INPUT_SCHEMA.json": self.req,
            "FILE_MANIFEST_SCHEMA.json": self.load(out, "input_file_manifest.before.json"),
            "INTEGRITY_SCHEMA.json": self.load(out, "input_integrity_comparison.json"),
            "HARNESS_CLAIM_SCHEMA.json": self.load(out, "harness_claim_inventory.json"),
            "PROPERTY_INVENTORY_SCHEMA.json": self.load(out, "property_inventory.json"),
            "EXTRACTED_FIELD_SCHEMA.json": self.load(out, "extracted_field_index.json"),
            "SKILL_USE_SCHEMA.json": self.load(out, "skill_use_records.json"),
            "ITERATION_SCHEMA.json": self.load(out, "iteration_index.json"),
            "WARNINGS_SCHEMA.json": self.load(out, "missing_evidence_warnings.json"),
            "MANIFEST_SCHEMA.json": self.load(out, "manifest.json"),
            "GENERATED_ARTIFACT_SCHEMA.json": self.load(out, "generated_artifact_manifest.json"),
        }
        for name, instance in mappings.items():
            jsonschema.Draft202012Validator(json.loads((REFS / name).read_text())).validate(instance)

    # 42
    def test_42_generated_artifact_hashes_validate(self):
        cp, out = self.run_cli()
        mf = self.load(out, "generated_artifact_manifest.json")
        for entry in mf["files"]:
            p = out / entry["path"]
            self.assertEqual(sha(p), entry["sha256"])
            self.assertEqual(p.stat().st_size, entry["size_bytes"])

    # 43
    def test_43_no_external_execution_network_or_model_code(self):
        text = SCRIPT.read_text()
        forbidden = ["subprocess", "os.system", "shell=True", "requests.", "urllib.request", "openai", "socket."]
        for token in forbidden:
            self.assertNotIn(token, text)

    # 44
    def test_44_no_scientific_acceptance_status(self):
        cp, out = self.run_cli()
        all_text = "\n".join(p.read_text(errors="ignore") for p in out.rglob("*") if p.is_file())
        for token in ["PROOF_VALID", "IMPLEMENTATION_CORRECT", "SCIENTIFICALLY_ACCEPTED", '"ACCEPTED"', '"REJECTED"']:
            self.assertNotIn(token, all_text)

    # 45
    def test_45_generic_non_mlkem_target(self):
        cp, out = self.run_cli()
        self.assertEqual(self.load(out, "manifest.json")["target"]["symbol"], "vector_subtract")
        self.assertNotIn("mlk_poly", (out / "manifest.md").read_text())

    # 46
    def test_46_manifest_markdown_has_mandatory_caveat(self):
        cp, out = self.run_cli()
        text = (out / "manifest.md").read_text()
        self.assertIn("evidence-manifest completeness only", text)
        self.assertIn("does not establish theorem validity", text)

    # 47
    def test_47_expected_hash_can_be_null_without_claim(self):
        self.req["artifacts"][10]["expected_sha256"] = None
        cp, out = self.run_cli()
        entry = {x["path"]: x for x in self.load(out, "input_file_manifest.before.json")}["cbmc/raw.bin"]
        self.assertIsNone(entry["hash_match"])
        self.assertEqual(cp.returncode, 0)

    # 48
    def test_48_empty_property_records_supported(self):
        self.req["property_records"] = []
        cp, out = self.run_cli()
        self.assertEqual(self.load(out, "property_inventory.json")["records"], [])

    # 49
    def test_49_not_supplied_source_revision_supported(self):
        self.req["source_revision"] = {"kind":"NOT_SUPPLIED","value":None,"evidence_path":None}
        self.req["required_roles"].remove("SOURCE_REVISION_EVIDENCE")
        self.req["artifacts"][0]["required"] = False
        cp, out = self.run_cli()
        self.assertEqual(cp.returncode, 0)
        self.assertEqual(self.load(out, "manifest.json")["source_revision"]["kind"], "NOT_SUPPLIED")

    # 50
    def test_50_generated_at_is_caller_supplied_not_wall_clock(self):
        cp, out = self.run_cli()
        self.assertEqual(self.load(out, "manifest.json")["generated_at_utc"], self.req["generated_at_utc"])
        self.assertNotIn("datetime.now", SCRIPT.read_text())


if __name__ == "__main__":
    unittest.main()
